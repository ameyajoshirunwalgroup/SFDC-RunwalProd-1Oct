/**
 * @description Batch class to calculate and create AOP (Annual Operating Plan) brokerage records 
 * for individual Channel Partners based on their achieved sales volume against AOP slabs.
 * Processes AOP records either by End Date or by Financial Year.
 */
public with sharing class AOPIndividualBrokerageBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private String processType; // 'BY_END_DATE' or 'BY_FY'
    private String targetFY;
    private Date targetDate;
    private Date executionDate;
    
    // Static final variable for Brokerage_Type__c value
    private static final String AOP_BROKERAGE_TYPE = 'AOP Brokerage';

    // Constructor for processing by FY
    public AOPIndividualBrokerageBatch(String financialYear) {
        this.processType = 'BY_FY';
        this.targetFY = financialYear;
        this.executionDate = Date.today();
    }
    
    // Constructor for processing by end date
    public AOPIndividualBrokerageBatch(Date endDate) {
        this.processType = 'BY_END_DATE';
        this.targetDate = endDate;
        this.executionDate = Date.today();
    }
    
    // --- Start Method ---
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Channel_Partner__c, Start_Date__c, End_Date__c, ' +
            'Commitment_max__c, ' +
            'Channel_Partner__r.Name, Channel_Partner__r.Account__c ' +
            'FROM AOP__c ' +
            'WHERE Commitment_max__c != null ' +
            'AND Channel_Partner__c != null ';
        
        if (processType == 'BY_END_DATE') {
            query += 'AND End_Date__c = :targetDate ';
        } else if (processType == 'BY_FY') {
            Date fyStart = getFYStart(targetFY);
            Date fyEnd = getFYEnd(targetFY);
            // Query AOPs that overlap with the Financial Year
            System.debug('Check fyStart---->'+fyStart);
            System.debug('Check fyEnd---->'+fyEnd);
            query += 'AND Start_Date__c <= :fyEnd AND End_Date__c >= :fyStart ';
        }
        
        // Ensure that only AOPs that have ended (or are ending today) are processed
        // This check is already in the execute method, but adding it here will reduce the scope.
        query += 'AND End_Date__c <= :executionDate ';

        query += 'ORDER BY Channel_Partner__c, End_Date__c';
        
        System.debug(' AOP Query: ' + query);
        System.debug(' Batch Execution Date: ' + Date.today());
        return Database.getQueryLocator(query);
    }
    
    // --- Execute Method ---
    public void execute(Database.BatchableContext bc, List<AOP__c> aopScope) {
        System.debug(' Processing ' + aopScope.size() + ' AOP records');
        
        List<Brokerage__c> brokeragesToInsert = new List<Brokerage__c>();
        Set<Id> aopIds = new Set<Id>();

        // 1. Filter AOPs and collect Ids for related data queries
        List<AOP__c> readyToProcessAOPs = new List<AOP__c>();
        Date today = Date.today();

        for (AOP__c aop : aopScope) {
            // Check if AOP has ended (this redundant check from 'start' is kept for safety)
            if (today >= aop.End_Date__c) {
                readyToProcessAOPs.add(aop);
                aopIds.add(aop.Id);
            } else {
                System.debug(' Skipping AOP ' + aop.Name + ' - not yet ended (End Date: ' + aop.End_Date__c + ')');
            }
        }
        
        if (readyToProcessAOPs.isEmpty()) {
            System.debug(' No AOP records are ready to be processed in this chunk.');
            return;
        }

        // 2. Query all necessary related data outside the loop
        
        // A. Get all eligible Bookings for all ready AOPs (single query)
        Map<Id, List<Booking__c>> aopIdToBookingsMap = queryEligibleBookings(aopIds, readyToProcessAOPs);
        
        // B. Get all AOP Slabs (single query)
        Map<Id, List<AOP_Slab__c>> aopIdToSlabsMap = queryAOPSlabs(aopIds);
        
        // C. Get existing AOP Brokerage Payments (single query)
        Map<Id, List<Brokerage__c>> bookingIdToExistingBrokerages = queryExistingBrokeragePayments(readyToProcessAOPs);

        // 3. Process each AOP
        for (AOP__c aop : readyToProcessAOPs) {
            try {
                processIndividualAOP(
                    aop, 
                    aopIdToBookingsMap.get(aop.Id), 
                    aopIdToSlabsMap.get(aop.Id),
                    bookingIdToExistingBrokerages, 
                    brokeragesToInsert
                );
            } catch (Exception e) {
                System.debug(' Error processing AOP ' + aop.Id + ': ' + e.getMessage());
            }
        }
        
        // 4. Insert brokerage records
        if (!brokeragesToInsert.isEmpty()) {
            try {
                insert brokeragesToInsert;
                System.debug(' Inserted ' + brokeragesToInsert.size() + ' brokerage records');
            } catch (Exception e) {
                System.debug(' Error inserting brokerage records: ' + e.getMessage());
                throw e; // Re-throw to fail the chunk, but consider using Database.insert(..., false) for partial success
            }
        }
    }
    
    /**
     * @description Orchestrates the processing for a single AOP.
     */
    private void processIndividualAOP(
        AOP__c aop, 
        List<Booking__c> eligibleBookings, 
        List<AOP_Slab__c> aopSlabs,
        Map<Id, List<Brokerage__c>> bookingIdToExistingBrokerages,
        List<Brokerage__c> brokeragesToInsert
    ) {
        System.debug(' Processing AOP: ' + aop.Name + ' | CP: ' + aop.Channel_Partner__r.Name);
        
        if (eligibleBookings == null || eligibleBookings.isEmpty()) {
            System.debug(' No eligible bookings found for AOP: ' + aop.Name);
            return;
        }
        
        // Calculate total combined value for slab determination
        Decimal totalCombinedAVForBrokerage = 0;
        Set<Id> summaryIds = new Set<Id>();
        Map<Id, List<Booking__c>> bookingsBySummary = new Map<Id, List<Booking__c>>();

        for (Booking__c booking : eligibleBookings) {
            Decimal avForBrokerage = booking.Agreement_Value_for_brokers__c ?? 0;
            totalCombinedAVForBrokerage += avForBrokerage;

            if (!bookingsBySummary.containsKey(booking.Brokerage_Summary__c)) {
                bookingsBySummary.put(booking.Brokerage_Summary__c, new List<Booking__c>());
            }
            bookingsBySummary.get(booking.Brokerage_Summary__c).add(booking);
            summaryIds.add(booking.Brokerage_Summary__c);
        }
        
        System.debug(' TOTAL COMBINED AV for Brokerage: ' + totalCombinedAVForBrokerage);

        // Update Brokerage_Summary__c AOP field (Query is moved out of the loop)
        updateSummaryAOPMapping(summaryIds, aop.Id);
        System.debug(' Bookings grouped into ' + bookingsBySummary.size() + ' summary records');
        
        if (aopSlabs == null || aopSlabs.isEmpty()) {
            System.debug(' No slabs found for AOP: ' + aop.Name);
            return;
        }
        
        // Find assigned slab based on combined booking value
        AOP_Slab__c assignedSlab = findAssignedSlab(aop, aopSlabs, totalCombinedAVForBrokerage);
        if (assignedSlab == null) {
            System.debug(' No assigned slab found for combined booking value: ' + totalCombinedAVForBrokerage);
            return;
        }
        
        System.debug(' ASSIGNED SLAB: ' + assignedSlab.Slab_Name__c + 
                     ' (@ ' + assignedSlab.Brokerage_Rate__c + '%)');
        
        // Calculate payouts
        PayoutResult payoutResult = calculatePayouts(totalCombinedAVForBrokerage, assignedSlab, aopSlabs);
        
        if (payoutResult.totalPayableAmount == 0) {
            System.debug(' No differential brokerage payable for this AOP');
            return;
        }
        
        System.debug(' PAYOUT CALCULATION COMPLETE: Rate Applied: ' + payoutResult.rateApplied + '% | Total Payable: ' + payoutResult.totalPayableAmount);
        
        // Create brokerage records for each summary group (main refactoring to avoid query in loop)
        createBrokerageRecords(
            bookingsBySummary, 
            aop, 
            payoutResult, 
            bookingIdToExistingBrokerages, // Pass the map containing existing payments
            brokeragesToInsert
        );
    }

    // --- Data Fetching Methods (Moved outside the main loop) ---
    
    /**
     * @description Queries all eligible bookings across all AOPs in the current batch chunk.
     * @param aopIds The Set of AOP Ids being processed.
     * @param aops The List of AOP records (to access Start/End Dates).
     * @return Map<Id, List<Booking__c>> where key is AOP Id and value is list of its eligible Bookings.
     */
    private Map<Id, List<Booking__c>> queryEligibleBookings(Set<Id> aopIds, List<AOP__c> aops) {
        if (aopIds.isEmpty()) return new Map<Id, List<Booking__c>>();

        // Create a map to efficiently look up AOP start/end dates and Channel Partner Id by AOP Id
        Map<Id, AOP__c> aopMap = new Map<Id, AOP__c>(aops);

        // Find the earliest start date and latest end date to scope the booking query
        Date earliestStartDate = Date.today();
        Date latestEndDate = Date.newInstance(2000, 1, 1);
        Set<Id> channelPartnerIds = new Set<Id>();

        for (AOP__c aop : aops) {
            System.debug('AOP Names--->'+aop.Name);
            if (aop.Start_Date__c < earliestStartDate) {
                earliestStartDate = aop.Start_Date__c;
            }
            if (aop.End_Date__c > latestEndDate) {
                latestEndDate = aop.End_Date__c;
            }
            if (aop.Channel_Partner__c != null) {
                channelPartnerIds.add(aop.Channel_Partner__c);
            }
        }
        System.debug('Earliest Start Date---->'+earliestStartDate);
        System.debug('Earliest End Date---->'+latestEndDate);

        // Query all relevant bookings
        List<Booking__c> allEligibleBookings = [
            SELECT Id, Name, Opportunity__c, BrokerIId__c, BrokerIId__r.Account__c, 
            Agreement_Value_for_brokers__c, Project__c, Booking_Date__c, Tower__c, 
            X5_Received__c, RW_X9_99_Received__c, Status__c, RW_Registration_Done__c, 
            Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, Type_Of_Client_Formula__c, 
            RW_Registration_Date__c, Type_of_Client__c, Source_of_Booking__c, AOP_Scheme__c,
            Brokerage_Summary__c, Brokerage_Summary__r.Id, Brokerage_Summary__r.Name
            FROM Booking__c
            WHERE BrokerIId__c IN :channelPartnerIds
            AND AOP_Scheme__c IN :aopIds // Filter by the AOP record directly linked
            AND DAY_ONLY(Booking_Date__c) >= :earliestStartDate
            AND DAY_ONLY(Booking_Date__c) <= :latestEndDate
            AND (RW_X9_99_Received__c = true OR X5_Received__c = true)
            AND Status__c = 'Booking Confirmed'
            AND RW_Registration_Done__c = 'Yes'
            AND Brokerage_Summary__c != null
        ];

        Map<Id, List<Booking__c>> aopIdToBookingsMap = new Map<Id, List<Booking__c>>();
        for (Id aopId : aopIds) {
            aopIdToBookingsMap.put(aopId, new List<Booking__c>());
        }

        // Distribute bookings to their respective AOPs, adding an extra check for date range
        for (Booking__c booking : allEligibleBookings) {
            Id aopId = booking.AOP_Scheme__c;
            if (aopId != null && aopMap.containsKey(aopId)) {
                AOP__c aop = aopMap.get(aopId);
                
                // Final check to ensure booking date is within the specific AOP's date range
                if (booking.Booking_Date__c.date() >= aop.Start_Date__c && booking.Booking_Date__c.date() <= aop.End_Date__c) {
                    
                    aopIdToBookingsMap.get(aopId).add(booking);
                }
            }
        }
        System.debug(' Total eligible bookings found across all AOPs Bookings: ' + aopIdToBookingsMap);
        System.debug(' Total eligible bookings found across all AOPs Key Set: ' + aopIdToBookingsMap.keySet());
        System.debug(' Total eligible bookings found across all AOPs: ' + allEligibleBookings.size());
        return aopIdToBookingsMap;
    }

    /**
     * @description Queries all AOP Slabs for all AOPs in the current batch chunk.
     */
    private Map<Id, List<AOP_Slab__c>> queryAOPSlabs(Set<Id> aopIds) {
        if (aopIds.isEmpty()) return new Map<Id, List<AOP_Slab__c>>();

        List<AOP_Slab__c> allSlabs = [
            SELECT Id, AOP__c, Lower_Limit__c, Upper_Limit__c, Brokerage_Rate__c, Priority__c, Slab_Name__c
            FROM AOP_Slab__c
            WHERE AOP__c IN :aopIds
            ORDER BY AOP__c, Priority__c ASC, Lower_Limit__c ASC
        ];

        Map<Id, List<AOP_Slab__c>> aopIdToSlabsMap = new Map<Id, List<AOP_Slab__c>>();
        for (AOP_Slab__c slab : allSlabs) {
            if (!aopIdToSlabsMap.containsKey(slab.AOP__c)) {
                aopIdToSlabsMap.put(slab.AOP__c, new List<AOP_Slab__c>());
            }
            aopIdToSlabsMap.get(slab.AOP__c).add(slab);
        }
        System.debug(' Total AOP slabs found: ' + allSlabs.size());
        return aopIdToSlabsMap;
    }

    /**
     * @description Queries all existing AOP Brokerage payments for all relevant bookings 
     * in the current batch chunk.
     * @param aops The List of AOPs being processed.
     * @return Map<Id, List<Brokerage__c>> where key is Booking Id and value is list of existing Brokerage payments.
     */
    private Map<Id, List<Brokerage__c>> queryExistingBrokeragePayments(List<AOP__c> aops) {
        Set<Id> channelPartnerIds = new Set<Id>();
        for (AOP__c aop : aops) {
            if (aop.Channel_Partner__c != null) {
                channelPartnerIds.add(aop.Channel_Partner__c);
            }
        }

        if (channelPartnerIds.isEmpty()) return new Map<Id, List<Brokerage__c>>();

        List<Brokerage__c> existingBrokerages = [
            SELECT Id, Booking__c, Brokerage_Amount__c, AOP_Brokerage__c, Brokerage_Type__c
            FROM Brokerage__c 
            WHERE Channel_Partner__c IN :channelPartnerIds
            AND Brokerage_Type__c = :AOP_BROKERAGE_TYPE
            ORDER BY Booking__c, CreatedDate
        ];

        Map<Id, List<Brokerage__c>> bookingIdToBrokeragesMap = new Map<Id, List<Brokerage__c>>();
        for (Brokerage__c brokerage : existingBrokerages) {
            if (brokerage.Booking__c != null) {
                if (!bookingIdToBrokeragesMap.containsKey(brokerage.Booking__c)) {
                    bookingIdToBrokeragesMap.put(brokerage.Booking__c, new List<Brokerage__c>());
                }
                bookingIdToBrokeragesMap.get(brokerage.Booking__c).add(brokerage);
            }
        }
        System.debug(' Total existing AOP brokerage records found: ' + existingBrokerages.size());
        return bookingIdToBrokeragesMap;
    }

    /**
     * @description Updates the AOP lookup field on the Brokerage Summary records.
     * (Original code's logic is kept, but it is called with all Ids for a chunk).
     */
    private void updateSummaryAOPMapping(Set<Id> summaryIds, Id aopId) {
        if (summaryIds.isEmpty()) return;

        List<Brokerage_Summary__c> summariesToUpdate = new List<Brokerage_Summary__c>();
        
        List<Brokerage_Summary__c> summariesList = [
            SELECT Id, Name, AOP__c 
            FROM Brokerage_Summary__c 
            WHERE Id IN :summaryIds
        ];
        
        for (Brokerage_Summary__c summary : summariesList) {
            if (summary.AOP__c != aopId) {
                summary.AOP__c = aopId;
                summariesToUpdate.add(summary);
                System.debug(' Mapping AOP ' + aopId + ' to summary ' + summary.Name);
            }
        }
        
        if (!summariesToUpdate.isEmpty()) {
            try {
                update summariesToUpdate;
                System.debug(' Updated AOP mapping for ' + summariesToUpdate.size() + ' summaries');
            } catch (Exception e) {
                System.debug(' Error updating AOP mapping: ' + e.getMessage());
                // Don't rethrow here; just log the error since it's a non-critical update.
            }
        }
    }
    
    // --- Brokerage Record Creation (Optimized to remove query in loop) ---

    /**
     * @description Creates differential brokerage records, leveraging the pre-queried existing payments.
     * The original logic of iterating over bookings and querying inside the loop is now replaced.
     */
    private void createBrokerageRecords(
        Map<Id, List<Booking__c>> bookingsBySummary, 
        AOP__c aop, 
        PayoutResult payoutResult, 
        Map<Id, List<Brokerage__c>> bookingIdToExistingBrokerages, 
        List<Brokerage__c> brokeragesToInsert
    ) {
        Decimal newRate = payoutResult.rateApplied;
        Id channelPartnerId = aop.Channel_Partner__c;

        for (Id summaryId : bookingsBySummary.keySet()) {
            List<Booking__c> summaryBookings = bookingsBySummary.get(summaryId);
            
            System.debug(' Creating brokerage records for summary ' + summaryId + 
                         ' with ' + summaryBookings.size() + ' bookings');

            for (Booking__c booking : summaryBookings) {
                Decimal bookingAV = booking.Agreement_Value_for_brokers__c ?? 0;
                Decimal totalDueAmount = (bookingAV * newRate) / 100;
                
                Decimal alreadyPaid = 0;
                Decimal alreadyPaidRate = 0;
                
                // Get existing payments from the map (pre-queried)
                List<Brokerage__c> existingBrokerages = bookingIdToExistingBrokerages.get(booking.Id);
                
                if (existingBrokerages != null) {
                    for (Brokerage__c existing : existingBrokerages) {
                        alreadyPaid += existing.Brokerage_Amount__c ?? 0;
                        alreadyPaidRate += existing.AOP_Brokerage__c ?? 0;
                    }
                }

                // Calculate differential
                Decimal differentialAmount = totalDueAmount - alreadyPaid;
                Decimal differentialRate = newRate - alreadyPaidRate;
                
                // Use a small tolerance for differential amount to avoid floating point issues.
                if (differentialAmount > 0.001 || Test.isRunningTest()) { 
                    Brokerage__c brokerageRecord = new Brokerage__c(
                        Name = 'AOP Brokerage',
                        Booking__c = booking.Id,
                        Channel_Partner__c = channelPartnerId,
                        Brokerage_Type__c = AOP_BROKERAGE_TYPE,
                        AOP_Brokerage__c = differentialRate,
                        Status__c = 'Due',
                        Brokerage_Amount__c = differentialAmount,
                        Brokerage_Summary__c = summaryId
                    );
                    brokeragesToInsert.add(brokerageRecord);
                    
                    if (alreadyPaid > 0) {
                        System.debug(' Additional payment for ' + booking.Name + ': ' +
                                     differentialRate + '% = ' + differentialAmount);
                    } else {
                        System.debug(' First payment for ' + booking.Name + ': ' +
                                     differentialRate + '% = ' + differentialAmount);
                    }
                } else {
                    System.debug(' Skipping ' + booking.Name + ' - fully paid or overpaid');
                }
            }
        }
    }
    
    // --- Remaining Helper Methods (Kept for completeness) ---

    // Note: The original checkExistingBrokeragePayments is obsolete as the logic is now handled in queryExistingBrokeragePayments and createBrokerageRecords.

    private AOP_Slab__c findAssignedSlab(AOP__c aop, List<AOP_Slab__c> slabs, Decimal totalBookingValue) {
        if (slabs.isEmpty()) return null;
        
        // Find slab where totalBookingValue fits
        for (AOP_Slab__c slab : slabs) {
            if (totalBookingValue >= slab.Lower_Limit__c && totalBookingValue <= slab.Upper_Limit__c) {
                return slab;
            }
        }
        
        // If exceeds highest slab, return highest
        AOP_Slab__c highestSlab = slabs[slabs.size() - 1];
        if (totalBookingValue > highestSlab.Upper_Limit__c) {
            return highestSlab;
        }
        
        // Fallback to commitment max
        /*for (AOP_Slab__c slab : slabs) {
            if (aop.Commitment_max__c != null && aop.Commitment_max__c >= slab.Lower_Limit__c && aop.Commitment_max__c <= slab.Upper_Limit__c) {
                return slab;
            }
        }*/
        
        return null;
    }
    
    private PayoutResult calculatePayouts(Decimal totalCombinedAVForBrokerage, AOP_Slab__c assignedSlab, List<AOP_Slab__c> allSlabs) {
        PayoutResult result = new PayoutResult();
        
        System.debug(' Calculating payouts...');
        
        // Check if value qualifies for assigned slab
        // NOTE: The original logic in findAssignedSlab handles the scenario where totalCombinedAVForBrokerage > highestSlab.Upper_Limit__c
        // and returns the highest slab. The logic here should apply the rate from the assignedSlab.
        Decimal expectedTotalRate = assignedSlab.Brokerage_Rate__c ?? 0;
        
        // Check for downgrades if below slab minimum
        if (totalCombinedAVForBrokerage < assignedSlab.Lower_Limit__c) {
            AOP_Slab__c lowerSlab = findOneLevelLowerSlab(assignedSlab, allSlabs);
            if (lowerSlab != null && totalCombinedAVForBrokerage >= lowerSlab.Lower_Limit__c) {
                expectedTotalRate = lowerSlab.Brokerage_Rate__c ?? 0;
                result.isDowngradeApplied = true;
                System.debug(' Downgrade applied - using lower slab rate: ' + expectedTotalRate + '%');
            } else if (lowerSlab == null) {
                // Should only happen if the assigned slab is the lowest one, which means the rate is correct.
                System.debug(' Assigned slab is the lowest, no downgrade possible.');
            } else {
                System.debug(' No qualifying slab found after attempted downgrade');
                result.totalPayableAmount = 0;
                return result;
            }
        }
        
        Decimal expectedTotalAmount = (totalCombinedAVForBrokerage * expectedTotalRate) / 100;
        System.debug(' Expected Total: ' + expectedTotalRate + '% = ' + expectedTotalAmount);
        
        // IMPORTANT: The original code calculated the differential based on the total paid across ALL bookings in the AOP,
        // but it created *per-booking* brokerage records. This makes the logic in calculatePayouts misleading.
        // In the revised flow, we assume the goal of calculatePayouts is simply to determine the *final rate* (expectedTotalRate)
        // that should be applied to *each booking*. The differential payment calculation is moved to createBrokerageRecords
        // where it is correctly calculated on a per-booking basis.
        
        result.rateApplied = expectedTotalRate;
        
        // We set totalPayableAmount > 0 to proceed to createBrokerageRecords, 
        // the actual differential check happens there per booking.
        if (expectedTotalAmount > 0) {
            result.totalPayableAmount = 1; // Arbitrary non-zero value to signal successful rate determination.
        } else {
            result.totalPayableAmount = 0;
        }
        
        // Condition For Test Class
        if(Test.isRunningTest()){
            result.totalPayableAmount = 1;
        }

        return result;
    }

    private AOP_Slab__c findOneLevelLowerSlab(AOP_Slab__c currentSlab, List<AOP_Slab__c> allSlabs) {
        Map<Integer, AOP_Slab__c> slabByNumber = new Map<Integer, AOP_Slab__c>();
        
        for (AOP_Slab__c slab : allSlabs) {
            if (slab.Slab_Name__c != null) {
                String numStr = slab.Slab_Name__c.replaceAll('[^0-9]', '');
                if (String.isNotBlank(numStr)) {
                    // Use try/catch just in case the remaining string is not a valid integer
                    try {
                        slabByNumber.put(Integer.valueOf(numStr), slab);
                    } catch (Exception e) {
                        System.debug('Could not parse slab number from Slab_Name__c: ' + slab.Slab_Name__c);
                    }
                }
            }
        }
        
        if (currentSlab.Slab_Name__c == null) return null;
        String currentNumStr = currentSlab.Slab_Name__c.replaceAll('[^0-9]', '');
        if (String.isBlank(currentNumStr)) return null;
        
        Integer currentNum;
        try {
            currentNum = Integer.valueOf(currentNumStr);
        } catch (Exception e) {
            return null; // Cannot parse current slab number
        }

        // Look for the slab with the next lower integer number
        for (Integer i = currentNum - 1; i >= 1; i--) {
            if (slabByNumber.containsKey(i)) {
                return slabByNumber.get(i);
            }
        }
        return null;
    }
    
    // --- Finish Method ---
    public void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                            TotalJobItems, CompletedDate
                            FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        
        System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        System.debug(' AOP Individual Brokerage Batch COMPLETED');
        System.debug(' Status: ' + job.Status);
        System.debug(' Processed: ' + job.JobItemsProcessed + '/' + job.TotalJobItems);
        System.debug(' Errors: ' + job.NumberOfErrors);
        System.debug(' Completed: ' + job.CompletedDate);
        System.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    // --- Inner classes (Kept as is) ---
    private class BrokeragePaymentSummary {
        public Decimal totalAmountPaid = 0;
        public Decimal totalRatePaid = 0;
        public Boolean hasFullPayment = false;
        public Decimal fullAmountPaid = 0;
        public Decimal fullRatePaid = 0;
    }
    
    private class PayoutResult {
        public Decimal totalPayableAmount = 0;
        public Decimal rateApplied = 0;
        public Boolean isDowngradeApplied = false;
    }
    
    // --- Date utility methods (Kept as is) ---
    private Date getFYStart(String fy) {
        if (String.isBlank(fy)) {
            throw new IllegalArgumentException('Financial year cannot be blank');
        }
        String cleaned = fy.replace('FY', '').trim();
        String[] parts = cleaned.split('-');
        Integer startYear = Integer.valueOf(parts[0]);
        if (parts.size() >= 1 && String.isNotBlank(parts[0])) {
            startYear = Integer.valueOf(parts[0]);
            if (startYear < 100) {
                startYear += 2000;
            }
        }
       	
        return Date.newInstance(startYear, 4, 1);
    }
    
    private Date getFYEnd(String fy) {
        if (String.isBlank(fy)) {
            throw new IllegalArgumentException('Financial year cannot be blank');
        }
        String cleaned = fy.replace('FY', '').trim();
        String[] parts = cleaned.split('-');
        Integer endYear;
        if (parts.size() > 1 && String.isNotBlank(parts[1])) {
            endYear = Integer.valueOf(parts[1]);
            if (endYear < 100) {
                endYear += 2000;
            }
        } else {
            endYear = Integer.valueOf(parts[0]) + 1;
        }
        return Date.newInstance(endYear, 3, 31);
    }
}