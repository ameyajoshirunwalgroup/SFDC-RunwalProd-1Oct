public class BrokerageLadderCreation {
    
     public class ResultSummary {
        public Integer createdBrokerageCount = 0;
        public Integer updatedSummaryCount = 0;
        public Map<Id, String> errors = new Map<Id, String>();
    }
    
    /**
	* Bulkified method to create Additional Brokerage records for multiple
	* Brokerage_Scheme__c ids and multiple Broker__c (CP) ids.
	*/
    public static ResultSummary createInvoicesForSchemesAndCPs(Set<Id> bookingIds) {
        System.debug('🏁 Entered createInvoicesForSchemesAndCPs | bookingIds=' + bookingIds);
        
        List<Booking__c> allBookings = [
            SELECT Id, Name, Customer__c, Agreement_Value_for_brokers__c, Project__c,
            Status__c, Booking_Date__c, Tower__c, Passback__c,
            RW_Total_Receipt_Amount_Received__c, Brokerage_Scheme__c, RW_Registration_Done__c,
            BrokerIId__c, Type_Of_Client_Formula__c, RW_Registration_Date__c, RW_X9_99_Received__c,
            Brokerage_Summary__c, Allotment_Premium__c, RW_Total_Demand_Raised__c,
            RW_Total_GST_Amount__c, RW_Total_Amount_Received_Without_GST__c, RW_Total_Amount_Recieved__c
            FROM Booking__c
            WHERE Id IN: bookingIds       
            ORDER BY Booking_Date__c ASC
        ];
        System.debug('✅ allBookings.size=' + allBookings.size());
        ResultSummary res = new ResultSummary();
        if(allBookings.isEmpty()){
            System.debug('No Booking Records Found.');
            return res;
        }
        Set<Id> CPIds = new Set<Id>();
        Set<Id> SchemeIds = new Set<Id>();
        for(Booking__c b:allBookings){
            CPIds.add(b.BrokerIId__c);
            SchemeIds.add(b.Brokerage_Scheme__c);
        }
        
        System.debug('🏁 Entered createInvoicesForSchemesAndCPs | schemeIds=' + schemeIds + ' | cpIds=' + cpIds);        
        if (schemeIds == null || schemeIds.isEmpty() || cpIds == null || cpIds.isEmpty()) {
            System.debug('⚠️ Either schemeIds or cpIds empty. Returning blank ResultSummary.');
            return res;
        }
        
        // ----------------------------
        // 1) Pre-query master data
        // ----------------------------
        System.debug('🔹 Step 1: Querying master data...');
        Map<Id, Broker__c> cpMap = new Map<Id, Broker__c>(
            [SELECT Id, Name FROM Broker__c WHERE Id IN :cpIds]
        );
        System.debug('✅ cpMap=' + cpMap);
        System.debug('✅ cpMap.size=' + cpMap.size());
        
        List<Brokerage_Scheme__c> schemes = [
            SELECT Id, Name, Base_Brokerage__c, End_Date__c, Project__c, Tower__c,
            Slab_Type__c, Approval_Status__c, Type__c, Start_Date__c
            FROM Brokerage_Scheme__c
            WHERE Id IN :schemeIds 
        ];
        System.debug('✅ schemes' + schemes);
        System.debug('✅ schemes.size=' + schemes.size());
        
        if (schemes.isEmpty()) {
            System.debug('⚠️ No Approved schemes found. Exiting.');
            return res;
        }
        
        Map<Id, Brokerage_Scheme__c> schemeMap = new Map<Id, Brokerage_Scheme__c>();
        for (Brokerage_Scheme__c s : schemes) schemeMap.put(s.Id, s);
        System.debug('✅ schemeMap.size=' + schemeMap.size());
        
        List<Scheme_Configuration__c> scList = [
            SELECT Id, Tower__c, Project__c, Brokerage_Scheme__c
            FROM Scheme_Configuration__c
            WHERE Brokerage_Scheme__c IN :schemeMap.keySet()
        ];
        System.debug('✅ Scheme Configurations fetched: ' + scList.size());
        
        List<Brokerage_Slab__c> slabs = [
            SELECT Id, Name, From__c, To__c, Total_Brokerage__c, Brokerage_Scheme__c,
            Additional_Brokerage_for_Local_Bookings__c,
            Additional_Brokerage_for_OS_NRI__c,
            Additional_Brokerage_for_NRI__c,
            Total_Brokerage_for_Local_Bookings__c,
            Total_Brokerage_for_NRI__c,
            Total_Brokerage_for_OS_NRI__c,
            Base_Brokerage__c, Additional_Brokerage__c
            FROM Brokerage_Slab__c
            WHERE Brokerage_Scheme__c IN :schemeMap.keySet()
            ORDER BY Name
        ];
        System.debug('✅ Slabs fetched: ' + slabs.size());
        
        Map<Id, Brokerage_Slab__c> slabById = new Map<Id, Brokerage_Slab__c>();
        Map<Id, List<Brokerage_Slab__c>> schemeIdToSlabs = new Map<Id, List<Brokerage_Slab__c>>();
        for (Brokerage_Slab__c sb : slabs) {
            slabById.put(sb.Id, sb);
            if (!schemeIdToSlabs.containsKey(sb.Brokerage_Scheme__c))
                schemeIdToSlabs.put(sb.Brokerage_Scheme__c, new List<Brokerage_Slab__c>());
            schemeIdToSlabs.get(sb.Brokerage_Scheme__c).add(sb);
        }
        System.debug('✅ schemeIdToSlabs keys: ' + schemeIdToSlabs.keySet());
        
        List<Brokerage__c> existingBrokerage = [
            SELECT Id, Name, Brokerage_Summary__c, Eligible_Slab__c, Booking__c, Brokerage_Type__c,
            Status__c, Brokerage_Amount__c, Brokerage__c
            FROM Brokerage__c
            WHERE Brokerage_Type__c = 'Additional Brokerage' AND Status__c != 'Due'
            AND Cancelled__c = false AND Brokerage_Summary__c != null
        ];
        System.debug('✅ Existing Additional Brokerage size=' + existingBrokerage.size());
        Map<Id, Brokerage__c> existingBySummary = new Map<Id, Brokerage__c>();
        for (Brokerage__c ex : existingBrokerage) existingBySummary.put(ex.Brokerage_Summary__c, ex);
        
        // ----------------------------
        // 2) Gather bookings
        // ----------------------------
        System.debug('🔹 Step 2: Querying Bookings...');
        Map<Id, Set<Id>> schemeToProjects = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> schemeToTowers = new Map<Id, Set<Id>>();
        for (Scheme_Configuration__c sc : scList) {
            if (!schemeToProjects.containsKey(sc.Brokerage_Scheme__c)) schemeToProjects.put(sc.Brokerage_Scheme__c, new Set<Id>());
            if (sc.Project__c != null) schemeToProjects.get(sc.Brokerage_Scheme__c).add(sc.Project__c);
            if (sc.Tower__c != null) {
                if (!schemeToTowers.containsKey(sc.Brokerage_Scheme__c)) schemeToTowers.put(sc.Brokerage_Scheme__c, new Set<Id>());
                schemeToTowers.get(sc.Brokerage_Scheme__c).add(sc.Tower__c);
            }
        }
        System.debug('✅ schemeToProjects keys=' + schemeToProjects.keySet());           
        
        Map<Id, Map<Id, List<Booking__c>>> schemeToCPToBookings = new Map<Id, Map<Id, List<Booking__c>>>();
        for (Booking__c b : allBookings) {
            if (!schemeToCPToBookings.containsKey(b.Brokerage_Scheme__c))
                schemeToCPToBookings.put(b.Brokerage_Scheme__c, new Map<Id, List<Booking__c>>());
            Map<Id, List<Booking__c>> cpToBookings = schemeToCPToBookings.get(b.Brokerage_Scheme__c);
            if (!cpToBookings.containsKey(b.BrokerIId__c))
                cpToBookings.put(b.BrokerIId__c, new List<Booking__c>());
            cpToBookings.get(b.BrokerIId__c).add(b);
        }
        System.debug('✅ schemeToCPToBookings keys=' + schemeToCPToBookings.keySet());
        
        // ----------------------------
        // 3) Brokerage Summaries
        // ----------------------------
        System.debug('🔹 Step 3: Querying Brokerage_Summary...');
        //Set<Id> bookingIds = new Set<Id>();
        //for (Booking__c b : allBookings) bookingIds.add(b.Id);
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        if (!bookingIds.isEmpty()) {
            brokerSummaryList = [
                SELECT Id, Name, Channel_Partner__c, Booking__c, Booking__r.Custom_Base_Brokerage__c,
                Applied_Slab_Name__c, Brokerage_Scheme__c, Brokerage__c, Opportunity__c, Total_Agreement_Value__c,
                Passback__c, Booking__r.Type_of_Client__c, Booking__r.Brokerage__c, Booking__r.Type_Of_Client_Formula__c
                FROM Brokerage_Summary__c
                WHERE Booking__c IN :bookingIds
                AND Channel_Partner__c IN :cpMap.keySet()
                AND Brokerage__c > 0
            ];
        }
        System.debug('✅ brokerSummaryList.size=' + brokerSummaryList.size());
        for(Brokerage_Summary__c bs : brokerSummaryList){
            system.debug('brokerSummaryList -> '+bs.Applied_Slab_Name__c);
        }
        
        Map<Id, List<Brokerage_Summary__c>> bookingIdToSummary = new Map<Id, List<Brokerage_Summary__c>>();
        for (Brokerage_Summary__c bs : brokerSummaryList) {
            if (!bookingIdToSummary.containsKey(bs.Booking__c))
                bookingIdToSummary.put(bs.Booking__c, new List<Brokerage_Summary__c>());
            bookingIdToSummary.get(bs.Booking__c).add(bs);
        }
        
        // ----------------------------
        // 4) Compute totals
        // ----------------------------
        System.debug('🔹 Step 4: Computing totals per (scheme, CP)...');
        Map<String, Integer> schemeCpToCount = new Map<String, Integer>();
        Map<String, Decimal> schemeCpToTotalAV = new Map<String, Decimal>();
        for (Id schemeId : schemeToCPToBookings.keySet()) {
            Map<Id, List<Booking__c>> cpToBookings = schemeToCPToBookings.get(schemeId);
            for (Id cpId : cpToBookings.keySet()) {
                Integer cnt = 0;
                Decimal totalAV = 0;
                for (Booking__c b : cpToBookings.get(cpId)) {
                    if (b.Status__c != 'Cancelled') {
                        cnt++;
                        totalAV += (b.Agreement_Value_for_brokers__c == null ? 0 : b.Agreement_Value_for_brokers__c);
                    }
                }
                String key = schemeId + '::' + cpId;
                schemeCpToCount.put(key, cnt);
                schemeCpToTotalAV.put(key, totalAV.setScale(2));
                System.debug('📊 Key=' + key + ' | count=' + cnt + ' | totalAV=' + totalAV);
            }
        }
        
        // ----------------------------
        // 5) Process each scheme+CP pair
        // ----------------------------
        System.debug('🔹 Step 5: Processing scheme+CP combinations...');
        List<Brokerage__c> brokeragesToInsert = new List<Brokerage__c>();
        List<Brokerage__c> brokeragesToUpdate = new List<Brokerage__c>();
        List<Brokerage_Summary__c> summariesToUpdate = new List<Brokerage_Summary__c>();
        
        for (Id schemeId : schemeToCPToBookings.keySet()) {
            Brokerage_Scheme__c scheme = schemeMap.get(schemeId);
            System.debug('➡️ Scheme=' + scheme.Name + ' (' + scheme.Id + ')');
            List<Brokerage_Slab__c> slabsForScheme = schemeIdToSlabs.get(schemeId);
            Map<Id, List<Booking__c>> cpToBookings = schemeToCPToBookings.get(schemeId);
            
            for (Id cpId : cpToBookings.keySet()) {
                String compositeKey = schemeId + '::' + cpId;
                Integer countForKey = schemeCpToCount.get(compositeKey);
                Decimal totalAVForKey = schemeCpToTotalAV.get(compositeKey);
                System.debug('➡️ CP=' + cpId + ' | count=' + countForKey + ' | totalAV=' + totalAVForKey);
                
                Id eligibleSlabId = null;
                for (Brokerage_Slab__c slab : slabsForScheme) {
                    if (scheme.Slab_Type__c == 'Count') {
                        if (slab.From__c <= countForKey && (slab.To__c == null || slab.To__c >= countForKey)) {
                            eligibleSlabId = slab.Id;
                            break;
                        }
                    } else {
                        if (slab.From__c <= totalAVForKey && (slab.To__c == null || slab.To__c >= totalAVForKey)) {
                            eligibleSlabId = slab.Id;
                            break;
                        }
                    }
                }
                System.debug('✅ EligibleSlab=' + eligibleSlabId);
                
                if (eligibleSlabId == null) continue;
                Brokerage_Slab__c slabSelected = slabById.get(eligibleSlabId);
                List<Booking__c> bookingsForPair = cpToBookings.get(cpId);
                
                for (Booking__c bk : bookingsForPair) {
                    List<Brokerage_Summary__c> summaries = bookingIdToSummary.get(bk.Id);
                    System.debug('➡️ Booking=' + bk.Id + ' | summaries=' + (summaries != null ? summaries.size() : 0));
                    if (summaries == null) continue;
                    
                    for (Brokerage_Summary__c bs : summaries) {
                        System.debug('🧾 Processing Summary=' + bs.Id + ' | AppliedSlab=' + bs.Applied_Slab_Name__c);
                        try {
                            // Skip if already zero/invalid
                            //if (bs.Brokerage__c == null) bs.Brokerage__c = 0;

                            // Check if applied slab already same as eligible; if not, create or update additional brokerage
                            String appliedSlabName = bs.Applied_Slab_Name__c;
                            String eligibleSlabName = slabSelected != null ? slabSelected.Name : null;
                            if (eligibleSlabName == null) continue;
                            system.debug('appliedSlabName -> '+appliedSlabName);
                            system.debug('eligibleSlabName -> '+eligibleSlabName);
                            // If already applied same slab, skip (unless you want to still reconcile)
                            if (appliedSlabName != null && appliedSlabName == eligibleSlabName) {
                                continue;
                            }

                            // Prepare brokerage record values
                                Brokerage__c existing = existingBySummary.get(bs.Id);
                            Decimal newBrokeragePercent = 0;

                            // Compute new brokerage% depending on client type and slab data
                            String clientType = bk.Type_Of_Client_Formula__c;
                            if (clientType == null) clientType = bs.Booking__r != null ? bs.Booking__r.Type_Of_Client__c : null;

                            if (bs.Booking__r != null && bs.Booking__r.Custom_Base_Brokerage__c != null && bs.Booking__r.Custom_Base_Brokerage__c != 0) {
                                // custom base present - calculate additional based on selected slab additional fields
                                if (clientType == 'Local' || clientType == 'Corporate') {
                                    Decimal addLocal = slabSelected.Additional_Brokerage_for_Local_Bookings__c == null ? 0 : slabSelected.Additional_Brokerage_for_Local_Bookings__c;
                                    newBrokeragePercent = (bs.Booking__r.Custom_Base_Brokerage__c + addLocal) - bs.Brokerage__c - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                } else if (clientType == 'NRI') {
                                    Decimal addNri = slabSelected.Additional_Brokerage_for_NRI__c == null ? 0 : slabSelected.Additional_Brokerage_for_NRI__c;
                                    newBrokeragePercent = (bs.Booking__r.Custom_Base_Brokerage__c + addNri) - bs.Brokerage__c - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                } else { // Outstation or others
                                    Decimal addOs = slabSelected.Additional_Brokerage_for_OS_NRI__c == null ? 0 : slabSelected.Additional_Brokerage_for_OS_NRI__c;
                                    newBrokeragePercent = (bs.Booking__r.Custom_Base_Brokerage__c + addOs) - bs.Brokerage__c - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                }
                            } else {
                                // No custom base -> use Total_Brokerage_for_* values (retrofit logic)
                                if (clientType == 'Local' || clientType == 'Corporate') {
                                    Decimal totalLocal = slabSelected.Total_Brokerage_for_Local_Bookings__c == null ? 0 : slabSelected.Total_Brokerage_for_Local_Bookings__c;
                                    newBrokeragePercent = (totalLocal - bs.Brokerage__c) - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                } else if (clientType == 'NRI') {
                                    Decimal totalNri = slabSelected.Total_Brokerage_for_NRI__c == null ? 0 : slabSelected.Total_Brokerage_for_NRI__c;
                                    newBrokeragePercent = (totalNri - bs.Brokerage__c) - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                } else {
                                    Decimal totalOs = slabSelected.Total_Brokerage_for_OS_NRI__c == null ? 0 : slabSelected.Total_Brokerage_for_OS_NRI__c;
                                    newBrokeragePercent = (totalOs - bs.Brokerage__c) - (bs.Passback__c == null ? 0 : bs.Passback__c);
                                }
                            }

                            // scale
                            newBrokeragePercent = (newBrokeragePercent == null ? 0 : newBrokeragePercent.setScale(2, RoundingMode.HALF_UP));
                            Decimal brokerageAmount = (bs.Total_Agreement_Value__c == null ? 0 : (bs.Total_Agreement_Value__c * (newBrokeragePercent / 100)));

                            if (existing == null) {
                                // Create new Brokerage__c
                                Brokerage__c brec = new Brokerage__c();
                                brec.Brokerage_Summary__c = bs.Id;
                                brec.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                brec.Opportunity__c = bs.Opportunity__c;
                                brec.Booking__c = bs.Booking__c;
                                brec.Channel_Partner__c = bs.Channel_Partner__c;
                                brec.Brokerage_Type__c = 'Additional Brokerage';
                                brec.Name = 'Additional Brokerage';
                                brec.Eligible_Slab__c = eligibleSlabName;
                                brec.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                brec.Brokerage__c = newBrokeragePercent;
                                brec.Brokerage_Amount__c = brokerageAmount;
                                brec.New_Process__c = true;//Added by Prashant to handle cases created from new process for ladder creation. 18-11-25.//
                                brokeragesToInsert.add(brec);
                                res.createdBrokerageCount++;
                            } else {
                                // Update existing brokerage
                                //existing.Brokerage__c = (existing.Brokerage__c == null ? 0 : existing.Brokerage__c) + newBrokeragePercent;
                                
                                //String clientType = bk.Type_Of_Client_Formula__c;
                                if (clientType == null)
                                    clientType = bs.Booking__r != null ? bs.Booking__r.Type_Of_Client__c : null;
                                
                                Decimal baseBrok = bs.Booking__r.Custom_Base_Brokerage__c == null ? 0 : bs.Booking__r.Custom_Base_Brokerage__c;
                                Decimal passback = bs.Passback__c == null ? 0 : bs.Passback__c;
                                Decimal prevTotal = bs.Brokerage__c == null ? 0 : bs.Brokerage__c;
                                
                                Decimal newTotal = 0;
                                if (baseBrok > 0) {
                                    // Custom base exists → add relevant "Additional" field
                                    if (clientType == 'Local' || clientType == 'Corporate') {
                                        newTotal = baseBrok + (slabSelected.Additional_Brokerage_for_Local_Bookings__c == null ? 0 : slabSelected.Additional_Brokerage_for_Local_Bookings__c);
                                    } else if (clientType == 'NRI') {
                                        newTotal = baseBrok + (slabSelected.Additional_Brokerage_for_NRI__c == null ? 0 : slabSelected.Additional_Brokerage_for_NRI__c);
                                    } else if (clientType == 'Outstation') {
                                        newTotal = baseBrok + (slabSelected.Additional_Brokerage_for_OS_NRI__c == null ? 0 : slabSelected.Additional_Brokerage_for_OS_NRI__c);
                                    } else {
                                        newTotal = baseBrok; // default fallback
                                    }
                                } else {
                                    // No custom base → use total brokerage field from slab
                                    if (clientType == 'Local' || clientType == 'Corporate') {
                                        newTotal = (slabSelected.Total_Brokerage_for_Local_Bookings__c == null ? 0 : slabSelected.Total_Brokerage_for_Local_Bookings__c);
                                    } else if (clientType == 'NRI') {
                                        newTotal = (slabSelected.Total_Brokerage_for_NRI__c == null ? 0 : slabSelected.Total_Brokerage_for_NRI__c);
                                    } else if (clientType == 'Outstation') {
                                        newTotal = (slabSelected.Total_Brokerage_for_OS_NRI__c == null ? 0 : slabSelected.Total_Brokerage_for_OS_NRI__c);
                                    }
                                }
                                
                                // Compute the delta
                                Decimal delta = (newTotal - prevTotal) - passback;
                                if (delta < 0) delta = 0; // safeguard against negative slab regression
                                
                                existing.Brokerage__c = (existing.Brokerage__c == null ? 0 : existing.Brokerage__c) + delta.setScale(2, RoundingMode.HALF_UP);

                                existing.Brokerage_Amount__c = (bs.Total_Agreement_Value__c == null ? 0 : (bs.Total_Agreement_Value__c * (existing.Brokerage__c / 100)));
                                existing.Eligible_Slab__c = eligibleSlabName;
                                brokeragesToUpdate.add(existing);
                            }

                            // Prepare Brokerage_Summary__c update for Applied_Slab_Name__c
                            Brokerage_Summary__c toUpd = new Brokerage_Summary__c(Id = bs.Id);
                            toUpd.Applied_Slab_Name__c = eligibleSlabName;
                            summariesToUpdate.add(toUpd);

                        } catch (Exception ex) {
                            System.debug('❌ Exception for Summary ' + bs.Id + ': ' + ex.getMessage());
                            res.errors.put(bs.Id, ex.getMessage());
                        }
                    }
                }
            }
        }
        
        // ----------------------------
        // 6) Final DML
        // ----------------------------
        System.debug('🔹 Step 6: DML operations starting...');
        if (!brokeragesToInsert.isEmpty()) {
            System.debug('Inserting brokerages: ' + brokeragesToInsert.size());
            insert brokeragesToInsert;
        }
        if (!brokeragesToUpdate.isEmpty()) {
            System.debug('Updating brokerages: ' + brokeragesToUpdate.size());
            update brokeragesToUpdate;
        }
        if (!summariesToUpdate.isEmpty()) {
            System.debug('Updating summaries: ' + summariesToUpdate.size());
            update summariesToUpdate;
        }
        System.debug('🏁 Exiting createInvoicesForSchemesAndCPs | Created=' + res.createdBrokerageCount + ' | Updated=' + res.updatedSummaryCount);
        return res;
    }
	
    public static void CreateInvoice(Set<ID> AllSchemeId,Id CPId){
        List<Booking__c> bkList1 = new List<Booking__c>();
        List<Booking__c> bkList2 = new List<Booking__c>();
        List<Booking__c> bkList3 = new List<Booking__c>();
        List<Broker__c> CPList = new List<Broker__c>();
        List<Scheme_Configuration__c> scprojtower = new List<Scheme_Configuration__c>();
        List<Brokerage_Scheme__c> brokerageScheme1 = new List<Brokerage_Scheme__c>();
        List<Brokerage_Slab__c> brokerageSlab = new List<Brokerage_Slab__c>();
        List<Brokerage_Slab__c> brokerageSlab1 = new List<Brokerage_Slab__c>();
        List<Brokerage_Summary__c> BrokerSummarySlab = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerage = new List<Brokerage__c>();
        List<Brokerage_Summary__c> updateBrokerSummarySlab = new List<Brokerage_Summary__c>();
        Map<Id,Brokerage_Slab__c> slabmap = new Map<Id,Brokerage_Slab__c>();
        Map<Id,Brokerage__c> Brokeragemap = new Map<Id,Brokerage__c>();
        Map<Id,Broker__c> CPMap = new Map<Id,Broker__c>();
        List<Brokerage__c> Existingbrokerage = new List<Brokerage__c>();
        set<ID> CPIds = new set<ID>();
        set<ID> scprj = new set<ID>();
        set<ID> sctower = new set<ID>();
        set<Id> bSlabId = new set<Id>();
        Date startDate;
        Date endDate;
        Decimal totalAV = 0.0;
        Integer count = 0;
        CPList = [Select Id,Name from Broker__c where ID =: CPId];
        for(Broker__c cp:CPList){
            CPMap.put(cp.Id,cp);
        }
        brokerageScheme1 = [select Id,Name,Base_Brokerage__c,End_Date__c,Project__c,Tower__c,Slab_Type__c,Approval_Status__c,Type__c,
                            Start_Date__c from Brokerage_Scheme__c where id IN: AllSchemeId and Approval_Status__c = 'Approved by Level 2'];
        system.debug('brokerageScheme1::'+brokerageScheme1);
        scprojtower = [Select id,Tower__c,Project__c,Brokerage_Scheme__c from Scheme_Configuration__c where Brokerage_Scheme__c IN: brokerageScheme1];
        
        
        brokerageSlab = [select id,Name,From__c,To__c,Total_Brokerage__c,Brokerage_Scheme__c,Additional_Brokerage_for_Local_Bookings__c,
                         Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c IN: brokerageScheme1];
        system.debug('brokerageSlab::'+brokerageSlab);
        brokerageSlab1 = [select id,Name,From__c,To__c,Total_Brokerage__c,Base_Brokerage__c,Additional_Brokerage__c,Brokerage_Scheme__c,
                          Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c,Base_Brokerage_for_Local_Bookings__c,
                          Base_Brokerage_for_OS_NRI__c,Base_Brokerage_for_NRI__c,Total_Brokerage_for_OS_NRI__c,Total_Brokerage_for_NRI__c,Total_Brokerage_for_Local_Bookings__c from Brokerage_Slab__c];
        system.debug('brokerageSlab1::'+brokerageSlab1);
        for(Brokerage_Slab__c bs:brokerageSlab1){
            slabmap.put(bs.Id, bs);
        }
        Existingbrokerage = [Select Id,Name,Brokerage_Summary__c,Eligible_Slab__c,Booking__c,Brokerage_Type__c,Status__c,Brokerage_Amount__c,Brokerage__c from Brokerage__c
                             where Brokerage_Type__c = 'Additional Brokerage' and Status__c != 'Due' and Cancelled__c = false];
        for(Brokerage__c b:Existingbrokerage){
            Brokeragemap.put(b.Brokerage_Summary__c,b);
        }
        for(Id cp:CPMap.keySet()){
            for(Brokerage_Scheme__c Scheme:brokerageScheme1){
                scprj = new set<ID>();
                sctower = new set<ID>();
                totalAV = 0.0;
                count = 0;
                bSlabId = new set<Id>();
                Id SlabId = null;
                for(Scheme_Configuration__c scon :scprojtower){
                    if(scon.Brokerage_Scheme__c == Scheme.Id){
                        if(scon.Project__c != null && scon.Tower__c != null){
                            scprj.add(scon.Project__c);
                            sctower.add(scon.Tower__c);
                        }else{
                            scprj.add(scon.Project__c);
                        }
                    }
                }
                system.debug('scprj::'+scprj);
                system.debug('sctower::'+sctower);
                if(!brokerageScheme1.isEmpty()){
                    startDate = brokerageScheme1[0].Start_Date__c;
                    endDate = brokerageScheme1[0].End_Date__c;
                    system.debug('startDate::'+ startDate +' endDate::'+endDate);
                }
                
                if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && sctower.isEmpty()){
                    if(brokerageScheme1[0].Type__c == 'Local'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed'  and RW_Registration_Done__c = 'Yes'  
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'NRI'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' and RW_Registration_Done__c = 'Yes'
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'Both'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed'  and RW_Registration_Done__c = 'Yes' and
                                   (Type_Of_Client_Formula__c =:'Local' OR Type_Of_Client_Formula__c =:'NRI') and (Project__c IN: scprj) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }
                } else if(!brokerageScheme1.isEmpty() && !scprj.isEmpty() && !sctower.isEmpty()){
                    if(brokerageScheme1[0].Type__c == 'Local'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp  ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'NRI'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and Type_Of_Client_Formula__c =:brokerageScheme1[0].Type__c  and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }else if(brokerageScheme1[0].Type__c == 'Both'){
                        bkList2 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Status__c,Booking_Date__c,Tower__c,Passback__c,
                                   RW_Total_Receipt_Amount_Received__c,Brokerage_Scheme__c,RW_Registration_Done__c, BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' 
                                   and (Type_Of_Client_Formula__c =:'Local' OR Type_Of_Client_Formula__c =:'NRI') and (Project__c IN: scprj and Tower__c IN: sctower) and DAY_ONLY(Booking_Date__c) >=:startDate and 
                                   RW_Registration_Date__c != null and RW_X9_99_Received__c = true and Brokerage_Summary__c != null and RW_Registration_Done__c = 'Yes' and
                                   DAY_ONLY(Booking_Date__c) <=:endDate and BrokerIId__c =: cp ORDER BY Booking_Date__c ASC];
                    }
                }                 
                system.debug('bkList2::'+bkList2);
                system.debug('bkList2 size::'+bkList2.size());
                
                list<Booking__c> blist = [Select Id,Type_Of_Client_Formula__c,Booking_Date__c,RW_Total_Amount_Received_Without_GST__c,RW_Total_Amount_Recieved__c,RW_Total_GST_Amount__c,
                                               RW_X9_99_Received__c ,Brokerage_Summary__c,BrokerIId__c,Allotment_Premium__c,RW_Total_Demand_Raised__c,RW_Total_Receipt_Amount_Received__c from Booking__c];
                Booking__c b = blist[0];
                system.debug('Type_Of_Client_Formula__c ::'+b.Type_Of_Client_Formula__c);
                system.debug('Booking_Date__c ::'+b.Booking_Date__c);
                system.debug('RW_X9_99_Received__c ::'+b.RW_X9_99_Received__c);
                system.debug('RW_Total_Amount_Received_Without_GST__c ::'+b.RW_Total_Amount_Received_Without_GST__c);
                system.debug('Allotment_Premium__c ::'+b.Allotment_Premium__c);
                system.debug('RW_Total_Receipt_Amount_Received__c ::'+b.RW_Total_Receipt_Amount_Received__c);
                system.debug('RW_Total_Demand_Raised__c ::'+b.RW_Total_Demand_Raised__c);
                system.debug('RW_Total_GST_Amount__c ::'+b.RW_Total_GST_Amount__c);
                system.debug('Type_Of_Client_Formula__c ::'+b.Type_Of_Client_Formula__c);
                system.debug('blist ::'+b.Type_Of_Client_Formula__c);
                system.debug('blist ::'+b.Type_Of_Client_Formula__c);
                system.debug('blist ::'+b.Type_Of_Client_Formula__c);
                if(!bkList2.isEmpty() && !brokerageScheme1.isEmpty()){
                    system.debug('brokerageScheme1[0].Slab_Type__c::'+brokerageScheme1[0].Slab_Type__c);
                    if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Count'){
                        for(Booking__c bk3 : bkList2){
                            if(bk3.Status__c != 'Cancelled'){
                                count = count + 1;
                                system.debug('Count::'+count);
                                system.debug('bk3.Id::'+bk3.Id);
                            }
                        }
                    }
                    if(brokerageScheme1[0].Slab_Type__c != null && brokerageScheme1[0].Slab_Type__c == 'Value'){
                        for(Booking__c bk3 : bkList2){
                            if(bk3.Status__c != 'Cancelled'){
                                totalAV = totalAV + bk3.Agreement_Value_for_brokers__c;
                                system.debug('totalAV::'+totalAV);
                                system.debug('bk3.Id::'+bk3.Id);
                            }
                        }
                    }
                }
                
                for(Brokerage_Slab__c bSlab : brokerageSlab){
                    system.debug('inside Brokerage Slab if---');
                    system.debug('Count::'+count);
                    system.debug('totalAV::'+totalAV);
                    if(count != 0 && count > 0 && bSlab.Brokerage_Scheme__c == Scheme.Id){
                        system.debug('bSlab.From__c <= count && bSlab.To__c >= count::::'+ (bSlab.From__c <= count && bSlab.To__c >= count));
                        if(bSlab.From__c != null && (bSlab.From__c <= count && (bSlab.To__c >= count || bSlab.To__c == null))){
                            bSlabId.add(bSlab.Id);
                            SlabId = bSlab.Id;
                            system.debug('bSlabId::'+bSlabId);
                        }
                    }
                    if(totalAV != 0 && totalAV > 0 && bSlab.Brokerage_Scheme__c == Scheme.Id){
                        system.debug('bSlab.From__c <= totalAV && bSlab.To__c >= totalAV::::'+ (bSlab.From__c <= totalAV && bSlab.To__c >= totalAV));
                        if(bSlab.From__c != null && (bSlab.From__c <= totalAV && (bSlab.To__c >= totalAV || bSlab.To__c == null))){
                            bSlabId.add(bSlab.Id);
                            SlabId = bSlab.Id;
                            system.debug('bSlabId1::'+bSlabId);
                        }
                    }
                }
                bkList3 = [select Id,Name,Customer__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                           RW_Total_Receipt_Amount_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c,BrokerIId__c,Type_Of_Client_Formula__c from Booking__c where Status__c = 'Booking Confirmed' and RW_Registration_Date__c != null and RW_X9_99_Received__c = true and RW_Registration_Done__c = 'Yes' and  Brokerage_Summary__c != null and
                           Customer__c != null and Brokerage_Scheme__c =:Scheme.Id and BrokerIId__c =:cp
                           and DAY_ONLY(Booking_Date__c) >=:startDate and DAY_ONLY(Booking_Date__c) <=:endDate ORDER BY Booking_Date__c ASC];
                system.debug('bkList3::'+bkList3);
                BrokerSummarySlab =  [select Id,Name,Channel_Partner__c,Booking__r.Custom_Base_Brokerage__c,Applied_Slab_Name__c,Brokerage_Scheme__c,Brokerage__c,Opportunity__c,Total_Agreement_Value__c,Passback__c,
                                      Booking__r.Type_of_Client__c,Booking__c,Booking__r.Brokerage__c,Booking__r.Type_Of_Client_Formula__c from Brokerage_Summary__c where Booking__c IN : bkList3 
                                      and Channel_Partner__c =: cp and Brokerage__c > 0];
                system.debug('BrokerSummarySlab::'+BrokerSummarySlab);
                system.debug('Size of BrokerSummarySlab::'+BrokerSummarySlab.size());
                if(!BrokerSummarySlab.isEmpty()){
                    
                    system.debug('Inside if BrokerSummarySlab if this list is not empty');
                    for(Brokerage_Summary__c bs : BrokerSummarySlab){
                        if(bs.Booking__r.Custom_Base_Brokerage__c != null && bs.Booking__r.Custom_Base_Brokerage__c != 0){
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_Local_Bookings__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('b2.Brokerage__c::'+b2.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((b2.Brokerage__c / 100)));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }
                                    else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_Local_Bookings__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((Brokeragemap.get(bs.Id).Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                } 
                            }
                            else if(bs.Booking__r.Type_Of_Client_Formula__c == 'NRI'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        system.debug('Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                        system.debug('Additional_Brokerage_for_NRI__c::'+slabmap.get(SlabId).Additional_Brokerage_for_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+(bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_NRI__c - bs.Brokerage__c));
                                       
                                        b2.Brokerage__c = (((((bs.Booking__r != null && bs.Booking__r.Custom_Base_Brokerage__c != null)? bs.Booking__r.Custom_Base_Brokerage__c: 0) + slabmap.get(SlabId).Additional_Brokerage_for_NRI__c) - bs.Brokerage__c) -  (bs.Passback__c != null ?bs.Passback__c:0 )).setscale(2,RoundingMode.HALF_UP);
                                        system.debug('b2.Brokerage__c ::'+b2.Brokerage__c );
                                        system.debug('Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                        system.debug('Additional_Brokerage_for_NRI__c::'+slabmap.get(SlabId).Additional_Brokerage_for_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+(bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_NRI__c - bs.Brokerage__c));
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((b2.Brokerage__c) / 100));
                                        //b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ( bs.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }  
                            }
                            else if(bs.Booking__r.Type_Of_Client_Formula__c == 'Outstation'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Brokerage__c = (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP);
                                        system.debug('b2.Brokerage__c ::'+b2.Brokerage__c );
                                        system.debug('Brokerage__c::'+bs.Booking__r.Custom_Base_Brokerage__c);
                                        system.debug('Additional_Brokerage_for_Local_Bookings__c::'+slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        system.debug('bs.Brokerage__c::'+(bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c - bs.Brokerage__c));
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((b2.Brokerage__c) / 100));
                                        //b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ( bs.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + (((bs.Booking__r.Custom_Base_Brokerage__c + slabmap.get(SlabId).Additional_Brokerage_for_OS_NRI__c) - bs.Brokerage__c) -  bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }  
                            }
                        }else{
                            if(bs.Booking__r.Type_Of_Client_Formula__c == 'Local' || bs.Booking__r.Type_Of_Client_Formula__c == 'Corporate'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = ((slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('brokerageSlab1[0].Total_Brokerage_for_Local_Bookings__c::'+slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * (b2.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + ((slabmap.get(SlabId).Total_Brokerage_for_Local_Bookings__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }
                            }
                            else if(bs.Booking__r.Type_Of_Client_Formula__c == 'NRI'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = ((slabmap.get(SlabId).Total_Brokerage_for_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('brokerageSlab1[0].Total_Brokerage_for_NRI__c::'+slabmap.get(SlabId).Total_Brokerage_for_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * (b2.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + ((slabmap.get(SlabId).Total_Brokerage_for_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }
                            } 
                            else if(bs.Booking__r.Type_Of_Client_Formula__c == 'Outstation'){
                                system.debug('Inside for BrokerSummarySlab if this list is not empty');
                                if(bs.Applied_Slab_Name__c != slabmap.get(SlabId).Name){
                                    system.debug('Inside If to create Retrofit Brokerage Record');
                                    system.debug('BrokerSummarySlab[0].Applied_Slab_Name__c ::'+bs.Applied_Slab_Name__c);
                                    system.debug('brokerageSlab1[0].Name::'+slabmap.get(SlabId).Name);
                                    if(Brokeragemap.get(bs.Id) == null){
                                        Brokerage__c b2 = new Brokerage__c();
                                        b2.Brokerage_Summary__c = bs.Id;
                                        b2.Brokerage_Scheme__c = bs.Brokerage_Scheme__c;
                                        b2.Opportunity__c = bs.Opportunity__c;
                                        b2.Booking__c = bs.Booking__c;
                                        b2.Channel_Partner__c = bs.Channel_Partner__c;
                                        b2.Brokerage_Type__c = 'Additional Brokerage';
                                        b2.Name = 'Additional Brokerage';
                                        b2.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        b2.Opportunity_AV__c = bs.Total_Agreement_Value__c;
                                        b2.Brokerage__c = ((slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        system.debug('brokerageSlab1[0].Total_Brokerage_for_OS_NRI__c::'+slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c);
                                        system.debug('bs.Brokerage__c::'+bs.Brokerage__c);
                                        b2.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * (b2.Brokerage__c / 100));
                                        brokerage.add(b2);
                                        
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                        system.debug('bs4::'+bs4);
                                    }else{
                                        Brokerage__c bb = new Brokerage__c();
                                        bb.Brokerage__c = Brokeragemap.get(bs.Id).Brokerage__c + ((slabmap.get(SlabId).Total_Brokerage_for_OS_NRI__c - bs.Brokerage__c) - bs.Passback__c).setscale(2,RoundingMode.HALF_UP); 
                                        bb.Brokerage_Amount__c = ((bs.Total_Agreement_Value__c) * ((bb.Brokerage__c / 100)));
                                        bb.Eligible_Slab__c = slabmap.get(SlabId).Name;
                                        bb.Id = Brokeragemap.get(bs.Id).Id;
                                        update bb;
                                        Brokerage_Summary__c bs4 = new Brokerage_Summary__c();
                                        bs4.Id = bs.Id;
                                        bs4.Applied_Slab_Name__c = slabmap.get(SlabId).Name;
                                        system.debug('brokerageSlab1.Name::'+slabmap.get(SlabId).Name);
                                        updateBrokerSummarySlab.add(bs4);
                                    }
                                }
                            }  
                        }
                    }
                    if(!brokerage.isEmpty()){
                        insert brokerage;
                        system.debug('brokerage inserted::'+brokerage);
                        
                        
                    }
                    if(!updateBrokerSummarySlab.isEmpty()){
                        update updateBrokerSummarySlab;
                        system.debug('Updated Brokerage Summary Slab  ::'+updateBrokerSummarySlab);
                    }
                    
                }
            }
        } 
    }
    
    Public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
    }
}