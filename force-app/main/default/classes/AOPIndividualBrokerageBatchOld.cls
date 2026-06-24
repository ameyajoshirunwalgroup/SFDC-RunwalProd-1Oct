public with sharing class AOPIndividualBrokerageBatchOld implements Database.Batchable<SObject>, Database.Stateful {
    
    private String processType; // 'BY_END_DATE' or 'BY_FY'
    private String targetFY;
    private Date targetDate;
    private Date executionDate;
    
    // Constructor for processing by FY
    public AOPIndividualBrokerageBatchOld(String financialYear) {
        this.processType = 'BY_FY';
        this.targetFY = financialYear;
        this.executionDate = Date.today();
    }
    
    // Constructor for processing by end date
    public AOPIndividualBrokerageBatchOld(Date endDate) {
        this.processType = 'BY_END_DATE';
        this.targetDate = endDate;
        this.executionDate = Date.today();
    }
    
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
            query += 'AND Start_Date__c <= :fyEnd AND End_Date__c >= :fyStart ';
        }
        
        query += 'ORDER BY Channel_Partner__c, End_Date__c';
        
        System.debug(' AOP Query: ' + query);
        System.debug(' Batch Execution Date: ' + Date.today());
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<AOP__c> aopScope) {
        System.debug('️ Processing ' + aopScope.size() + ' AOP records');
        
        List<Brokerage__c> brokeragesToInsert = new List<Brokerage__c>();
        
        for (AOP__c aop : aopScope) {
            try {
                // Only process if AOP has ended or is on last day
                if (Date.today() >= aop.End_Date__c) {
                    processIndividualAOP(aop, brokeragesToInsert);
                } else {
                    System.debug(' Skipping AOP ' + aop.Name + ' - not yet ended (End Date: ' + aop.End_Date__c + ')');
                }
            } catch (Exception e) {
                System.debug(' Error processing AOP ' + aop.Id + ': ' + e.getMessage());
            }
        }
        
        // Insert brokerage records
        if (!brokeragesToInsert.isEmpty()) {
            try {
                insert brokeragesToInsert;
                System.debug(' Inserted ' + brokeragesToInsert.size() + ' brokerage records');
            } catch (Exception e) {
                System.debug(' Error inserting brokerage records: ' + e.getMessage());
                throw e;
            }
        }
    }
    
    private void processIndividualAOP(AOP__c aop, List<Brokerage__c> brokerages) {
        System.debug(' Processing AOP: ' + aop.Name + ' | CP: ' + aop.Channel_Partner__r.Name);
        System.debug(' AOP Period: ' + aop.Start_Date__c + ' to ' + aop.End_Date__c);
        System.debug(' Max Commitment: ' + aop.Commitment_max__c);
        
        // Get eligible bookings for this AOP period
        DateTime aopStartDateTime = DateTime.newInstance(aop.Start_Date__c, Time.newInstance(0, 0, 0, 0));
        DateTime aopEndDateTime = DateTime.newInstance(aop.End_Date__c, Time.newInstance(23, 59, 59, 999));
        
        List<Booking__c> eligibleBookings = [
            SELECT Id, Name, Opportunity__c, BrokerIId__c, BrokerIId__r.Account__c, 
            Agreement_Value_for_brokers__c, Project__c, Booking_Date__c, Tower__c, 
            X5_Received__c, RW_X9_99_Received__c, Status__c, RW_Registration_Done__c, 
            Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, Type_Of_Client_Formula__c, 
            RW_Registration_Date__c, Type_of_Client__c, Source_of_Booking__c, AOP_Scheme__c,
            Brokerage_Summary__c, Brokerage_Summary__r.Id, Brokerage_Summary__r.Name
            FROM Booking__c
            WHERE BrokerIId__c = :aop.Channel_Partner__c
            AND BrokerIId__c != null
            AND AOP_Scheme__c = :aop.Id
            AND DAY_ONLY(Booking_Date__c) >= :aop.Start_Date__c
            AND DAY_ONLY(Booking_Date__c) <= :aop.End_Date__c
            AND (RW_X9_99_Received__c = true OR X5_Received__c = true)
            AND Status__c = 'Booking Confirmed'
            AND RW_Registration_Done__c = 'Yes'
            AND Brokerage_Summary__c != null
        ];
        
        System.debug(' Found ' + eligibleBookings.size() + ' eligible bookings');
        
        if (eligibleBookings.isEmpty()) {
            System.debug('️ No eligible bookings found for AOP: ' + aop.Name);
            return;
        }
        
        // Calculate total combined value for slab determination
        Decimal totalCombinedBookingValue = 0;
        Decimal totalCombinedAVForBrokerage = 0;
        
        for (Booking__c booking : eligibleBookings) {
            Decimal avForBrokerage = booking.Agreement_Value_for_brokers__c ?? 0;
            totalCombinedBookingValue += avForBrokerage;
            totalCombinedAVForBrokerage += avForBrokerage;
        }
        
        System.debug(' TOTAL COMBINED VALUES:');
        System.debug('   Combined Booking Value: ' + totalCombinedBookingValue);
        System.debug('   Combined AV for Brokerage: ' + totalCombinedAVForBrokerage);
        
        // Group bookings by Brokerage Summary
        Map<Id, List<Booking__c>> bookingsBySummary = new Map<Id, List<Booking__c>>();
        Map<Id, Brokerage_Summary__c> summaryMap = new Map<Id, Brokerage_Summary__c>();
        Set<Id> summaryIds = new Set<Id>();
        
        for (Booking__c booking : eligibleBookings) {
            if (!bookingsBySummary.containsKey(booking.Brokerage_Summary__c)) {
                bookingsBySummary.put(booking.Brokerage_Summary__c, new List<Booking__c>());
            }
            bookingsBySummary.get(booking.Brokerage_Summary__c).add(booking);
            summaryIds.add(booking.Brokerage_Summary__c);
        }
        
        // Query and update summary AOP mapping
        List<Brokerage_Summary__c> summariesList = [
            SELECT Id, Name, AOP__c 
            FROM Brokerage_Summary__c 
            WHERE Id IN :summaryIds
        ];
        
        for (Brokerage_Summary__c summary : summariesList) {
            summaryMap.put(summary.Id, summary);
        }
        
        updateSummaryAOPMapping(summaryMap.values(), aop.Id);
        System.debug(' Bookings grouped into ' + bookingsBySummary.size() + ' summary records');
        
        // Get AOP slabs
        List<AOP_Slab__c> aopSlabs = [
            SELECT Id, AOP__c, Lower_Limit__c, Upper_Limit__c, Brokerage_Rate__c, Priority__c, Slab_Name__c
            FROM AOP_Slab__c
            WHERE AOP__c = :aop.Id
            ORDER BY Priority__c ASC, Lower_Limit__c ASC
        ];
        
        if (aopSlabs.isEmpty()) {
            System.debug(' No slabs found for AOP: ' + aop.Name);
            return;
        }
        
        // Find assigned slab based on combined booking value
        AOP_Slab__c assignedSlab = findAssignedSlab(aop, aopSlabs, totalCombinedBookingValue);
        if (assignedSlab == null) {
            System.debug(' No assigned slab found for combined booking value: ' + totalCombinedBookingValue);
            return;
        }
        
        System.debug(' ASSIGNED SLAB: ' + assignedSlab.Slab_Name__c + 
                     ' (' + assignedSlab.Lower_Limit__c + '-' + assignedSlab.Upper_Limit__c + 
                     ' @ ' + assignedSlab.Brokerage_Rate__c + '%)');
        
        // Check existing brokerage payments
        BrokeragePaymentSummary paymentSummary = checkExistingBrokeragePayments(aop, eligibleBookings);
        
        // Calculate payouts
        PayoutResult payoutResult = calculatePayouts(totalCombinedBookingValue, totalCombinedAVForBrokerage, 
                                                     assignedSlab, aopSlabs, paymentSummary);
        
        if (payoutResult.totalPayableAmount == 0) {
            System.debug('️ No brokerage payable for this AOP');
            return;
        }
        
        System.debug(' PAYOUT CALCULATION COMPLETE:');
        System.debug('   Rate Applied: ' + payoutResult.rateApplied + '%');
        System.debug('   Total Payable: ' + payoutResult.totalPayableAmount);
        
        // Create brokerage records for each summary group
        for (Id summaryId : bookingsBySummary.keySet()) {
            List<Booking__c> summaryBookings = bookingsBySummary.get(summaryId);
            System.debug(' Creating brokerage records for summary ' + summaryId + 
                         ' with ' + summaryBookings.size() + ' bookings');
            
            createBrokerageRecords(summaryBookings, aop, payoutResult, brokerages, summaryId);
        }
    }
    
    private void updateSummaryAOPMapping(List<Brokerage_Summary__c> summaries, Id aopId) {
        List<Brokerage_Summary__c> summariesToUpdate = new List<Brokerage_Summary__c>();
        
        for (Brokerage_Summary__c summary : summaries) {
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
            }
        }
    }
    
    private BrokeragePaymentSummary checkExistingBrokeragePayments(AOP__c aop, List<Booking__c> eligibleBookings) {
        BrokeragePaymentSummary summary = new BrokeragePaymentSummary();
        
        Set<Id> bookingIds = new Set<Id>();
        for (Booking__c booking : eligibleBookings) {
            bookingIds.add(booking.Id);
        }
        
        List<Brokerage__c> existingBrokerages = [
            SELECT Id, Booking__c, Brokerage__c, Brokerage_Amount__c, Brokerage_Type__c, 
            Channel_Partner__c, CreatedDate, Name, AOP_Brokerage__c
            FROM Brokerage__c 
            WHERE Channel_Partner__c = :aop.Channel_Partner__c
            AND Booking__c IN :bookingIds
            AND Brokerage_Type__c = 'AOP Brokerage'
            ORDER BY CreatedDate
        ];
        
        System.debug(' Found ' + existingBrokerages.size() + ' existing AOP brokerage records');
        
        for (Brokerage__c brokerage : existingBrokerages) {
            Decimal amount = brokerage.Brokerage_Amount__c ?? 0;
            Decimal rate = brokerage.AOP_Brokerage__c ?? 0;
            
            summary.totalAmountPaid += amount;
            summary.totalRatePaid += rate;
            summary.hasFullPayment = true;
            summary.fullAmountPaid += amount;
            summary.fullRatePaid += rate;
            
            System.debug('    ' + brokerage.Name + ' | Type: ' + brokerage.Brokerage_Type__c + 
                         ' | Rate: ' + rate + '% | Amount: ' + amount);
        }
        
        System.debug(' Payment Summary:');
        System.debug('   Total Paid: ' + summary.totalAmountPaid + ' (' + summary.totalRatePaid + '%)');
        System.debug('   Has Payments: ' + summary.hasFullPayment);
        
        return summary;
    }
    
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
        for (AOP_Slab__c slab : slabs) {
            if (aop.Commitment_max__c >= slab.Lower_Limit__c && aop.Commitment_max__c <= slab.Upper_Limit__c) {
                return slab;
            }
        }
        
        return null;
    }
    
    private PayoutResult calculatePayouts(Decimal totalCombinedBookingValue, Decimal totalCombinedAVForBrokerage, 
                                          AOP_Slab__c assignedSlab, List<AOP_Slab__c> allSlabs, 
                                          BrokeragePaymentSummary paymentSummary) {
                                              PayoutResult result = new PayoutResult();
                                              
                                              System.debug(' Calculating payouts...');
                                              System.debug('   Assigned slab: ' + assignedSlab.Lower_Limit__c + '-' + assignedSlab.Upper_Limit__c);
                                              System.debug('   Combined booking value: ' + totalCombinedBookingValue);
                                              
                                              // Check if value qualifies for assigned slab
                                              Boolean qualifiesForAssignedSlab = totalCombinedBookingValue >= assignedSlab.Upper_Limit__c;
                                              Decimal expectedTotalRate = assignedSlab.Brokerage_Rate__c ?? 0;
                                              
                                              // Check for downgrades if below slab minimum
                                              if (!qualifiesForAssignedSlab && totalCombinedBookingValue < assignedSlab.Lower_Limit__c) {
                                                  AOP_Slab__c lowerSlab = findOneLevelLowerSlab(assignedSlab, allSlabs);
                                                  if (lowerSlab != null && totalCombinedBookingValue >= lowerSlab.Lower_Limit__c && 
                                                      totalCombinedBookingValue <= lowerSlab.Upper_Limit__c) {
                                                          expectedTotalRate = lowerSlab.Brokerage_Rate__c ?? 0;
                                                          result.isDowngradeApplied = true;
                                                          System.debug('️ Downgrade applied - using lower slab rate: ' + expectedTotalRate + '%');
                                                      } else {
                                                          System.debug('️ No qualifying slab found');
                                                          result.totalPayableAmount = 0;
                                                          return result;
                                                      }
                                              }
                                              
                                              Decimal expectedTotalAmount = (totalCombinedAVForBrokerage * expectedTotalRate) / 100;
                                              System.debug('   Expected Total: ' + expectedTotalRate + '% = ' + expectedTotalAmount);
                                              
                                              // Calculate differential payment
                                              Decimal totalPaidSoFar = paymentSummary.totalAmountPaid;
                                              Decimal differentialAmount = expectedTotalAmount - totalPaidSoFar;
                                              
                                              if (differentialAmount <= 0) {
                                                  System.debug(' Payment already complete');
                                                  result.totalPayableAmount = 0;
                                                  return result;
                                              }
                                              
                                              // Determine if this is a differential payment (slab upgrade scenario)
                                              result.rateApplied = expectedTotalRate;
                                              result.totalPayableAmount = differentialAmount;
                                              
                                              System.debug('   New Payment: ' + differentialAmount + ' (Already paid: ' + totalPaidSoFar + ')');
                                              
                                              return result;
                                          }
    
    private AOP_Slab__c findOneLevelLowerSlab(AOP_Slab__c currentSlab, List<AOP_Slab__c> allSlabs) {
        Map<Integer, AOP_Slab__c> slabByNumber = new Map<Integer, AOP_Slab__c>();
        
        for (AOP_Slab__c slab : allSlabs) {
            if (slab.Slab_Name__c != null) {
                String numStr = slab.Slab_Name__c.replaceAll('[^0-9]', '');
                if (String.isNotBlank(numStr)) {
                    slabByNumber.put(Integer.valueOf(numStr), slab);
                }
            }
        }
        
        if (currentSlab.Slab_Name__c == null) return null;
        String currentNumStr = currentSlab.Slab_Name__c.replaceAll('[^0-9]', '');
        if (String.isBlank(currentNumStr)) return null;
        
        Integer currentNum = Integer.valueOf(currentNumStr);
        
        for (Integer i = currentNum - 1; i >= 1; i--) {
            if (slabByNumber.containsKey(i)) {
                return slabByNumber.get(i);
            }
        }
        return null;
    }
    
    private void createBrokerageRecords(List<Booking__c> bookings, AOP__c aop, PayoutResult payoutResult, 
                                        List<Brokerage__c> brokerages, Id summaryId) {
                                            
                                            // Get existing brokerage for these bookings
                                            Set<Id> bookingIds = new Set<Id>();
                                            for (Booking__c booking : bookings) {
                                                bookingIds.add(booking.Id);
                                            }
                                            
                                            Map<Id, Decimal> paidAmountByBooking = new Map<Id, Decimal>();
                                            Map<Id, Decimal> paidRateByBooking = new Map<Id, Decimal>();
                                            
                                            List<Brokerage__c> existingBrokerages = [
                                                SELECT Id, Booking__c, AOP_Brokerage__c, Brokerage_Amount__c, Brokerage_Type__c
                                                FROM Brokerage__c 
                                                WHERE Channel_Partner__c = :aop.Channel_Partner__c
                                                AND Booking__c IN :bookingIds
                                                AND Brokerage_Type__c = 'AOP Brokerage'
                                            ];
                                            
                                            for (Brokerage__c existing : existingBrokerages) {
                                                Decimal paidAmount = paidAmountByBooking.get(existing.Booking__c) ?? 0;
                                                Decimal paidRate = paidRateByBooking.get(existing.Booking__c) ?? 0;
                                                
                                                paidAmountByBooking.put(existing.Booking__c, paidAmount + (existing.Brokerage_Amount__c ?? 0));
                                                paidRateByBooking.put(existing.Booking__c, paidRate + (existing.AOP_Brokerage__c ?? 0));
                                            }
                                            
                                            // Create brokerage records
                                            for (Booking__c booking : bookings) {
                                                Decimal bookingAV = booking.Agreement_Value_for_brokers__c ?? 0;
                                                Decimal newRate = payoutResult.rateApplied;
                                                Decimal totalDueAmount = (bookingAV * newRate) / 100;
                                                
                                                Decimal alreadyPaid = paidAmountByBooking.get(booking.Id) ?? 0;
                                                Decimal alreadyPaidRate = paidRateByBooking.get(booking.Id) ?? 0;
                                                
                                                // Calculate differential
                                                Decimal differentialAmount = totalDueAmount - alreadyPaid;
                                                Decimal differentialRate = newRate - alreadyPaidRate;
                                                
                                                if (differentialAmount > 0) {
                                                    Brokerage__c brokerageRecord = new Brokerage__c(
                                                        Name = 'AOP Brokerage',
                                                        Booking__c = booking.Id,
                                                        Channel_Partner__c = aop.Channel_Partner__c,
                                                        Brokerage_Type__c = 'AOP Brokerage',
                                                        AOP_Brokerage__c = differentialRate,
                                                        Status__c = 'Due',
                                                        Brokerage_Amount__c = differentialAmount,
                                                        Brokerage_Summary__c = summaryId
                                                    );
                                                    brokerages.add(brokerageRecord);
                                                    
                                                    if (alreadyPaid > 0) {
                                                        System.debug(' Additional payment for ' + booking.Name + ': ' + 
                                                                     differentialRate + '% = ' + differentialAmount + 
                                                                     ' (Total Due: ' + totalDueAmount + ', Previously Paid: ' + alreadyPaid + ')');
                                                    } else {
                                                        System.debug(' First payment for ' + booking.Name + ': ' + 
                                                                     differentialRate + '% = ' + differentialAmount);
                                                    }
                                                } else {
                                                    System.debug(' Skipping ' + booking.Name + ' - fully paid');
                                                }
                                            }
                                        }
    
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
    
    // Inner classes
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
    
    // Date utility methods
    private Date getFYStart(String fy) {
        if (String.isBlank(fy)) {
            throw new IllegalArgumentException('Financial year cannot be blank');
        }
        String cleaned = fy.replace('FY', '').trim();
        String[] parts = cleaned.split('-');
        Integer startYear = Integer.valueOf(parts[0]);
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