//Written by Prashant/Vinay to Automatically populate cp category based on walkin customer and booking counts. 20-03-25
global class BatchforP1toP4CategoryAutomation implements Database.Batchable<sObject>, Database.AllowsCallouts 
{
    public String segmentName;
    public String currentYear;
    
    global BatchforP1toP4CategoryAutomation(String segmentName,String currentYear){
        this.segmentName = segmentName;
        this.currentYear = currentYear;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
            String query = 'SELECT Id, Category__c, Channel_Partner__c, End_Date__c, Project__c, Segment__c, Start_Date__c FROM CP_Category__c WHERE Segment__c =: segmentName AND Relevant_FY__c =: currentYear';
            System.debug('Final Query: ' + query); 
            return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<CP_Category__c> cpclist)
    {  
       List<Date> startDates = new List<Date>();
        List<Date> endDates = new List<Date>();
        List<String> channelPartners = new List<String>();
        Map<Id, CP_Category__c> latestCpCategoryMap = new Map<Id, CP_Category__c>();

        if (!cpclist.isEmpty()) {
            for (CP_Category__c cpc : cpclist) {
                startDates.add(cpc.Start_Date__c);
                endDates.add(cpc.End_Date__c);
                if(!channelPartners.contains(cpc.Channel_Partner__c)){
                    channelPartners.add(cpc.Channel_Partner__c);
                }
                if (!latestCpCategoryMap.containsKey(cpc.Channel_Partner__c) || 
                    cpc.End_Date__c > latestCpCategoryMap.get(cpc.Channel_Partner__c).End_Date__c) {
                        latestCpCategoryMap.put(cpc.Channel_Partner__c, cpc);
                    }
            }
        }

        startDates.sort();
        endDates.sort();

        System.debug('Sorted startDates --> ' + startDates);
        System.debug('Sorted endDates --> ' + endDates);

        Date leastStartDate = startDates[0];
        Date atMostEndDate = endDates[endDates.size() - 1];

        System.debug('Least startDate --> ' + leastStartDate);
        System.debug('At most endDate --> ' + atMostEndDate);
        Map<Id, List<Booking__c>> cpcIdvsBkListMap = new Map<Id, List<Booking__c>>();
        Map<Id, List<Opportunity>> cpcIdvsOppListMap = new Map<Id, List<Opportunity>>();
        Map<Id, Integer> cpcIdvsBksizeMap = new Map<Id, Integer>();
        Map<Id, Integer> cpcIdvsOppsizeMap = new Map<Id, Integer>();
        Map<Id, Integer> cpcIdvslst60daysBksizeMap = new Map<Id, Integer>();
        Map<Id, Integer> cpcIdvslst60daysOppsizeMap = new Map<Id, Integer>();
        Date sixtyDaysAgo = Date.today().addDays(-60);
        System.debug('Date 60 days ago: ' + sixtyDaysAgo);
        
		//Get walkin customer list.
        list<Opportunity> opplist = [SELECT Id,RW_Project__r.Name,CreatedDate,RW_Walkin_Channel_Partner__c,First_Site_Visit_Date__c,RW_Project__r.Segment__c FROM Opportunity WHERE 
                                    First_Site_Visit_Date__c >= :leastStartDate 
                                    and First_Site_Visit_Date__c <= :atMostEndDate 
                                    and RW_Project__r.Segment__c =: segmentName AND RW_Walkin_Channel_Partner__c =: channelPartners];
        
        
        system.debug('opplist size'+opplist.size());
        system.debug('cpclist size'+cpclist.size());
        
        //Get last 60 days customer list.
        list<Opportunity> lst60daysopplist = [SELECT Id,RW_Project__r.Name,CreatedDate,RW_Walkin_Channel_Partner__c,First_Site_Visit_Date__c,RW_Project__r.Segment__c FROM Opportunity WHERE 
                                    First_Site_Visit_Date__c >=: sixtyDaysAgo
                                    and RW_Project__r.Segment__c =: segmentName AND RW_Walkin_Channel_Partner__c =: channelPartners];
        
        
        //Get booking list.
        list<Booking__c> bklist = [SELECT Id,Project__r.Name,Status__c,Booking_Date__c,BrokerIId__c,Project__r.Segment__c FROM Booking__c WHERE
                                   Project__r.Segment__c =: segmentName 
                                   and DAY_ONLY(Booking_Date__c) >= :leastStartDate 
                                    and DAY_ONLY(Booking_Date__c) <= :atMostEndDate 
                                   AND Status__c = 'Booking Confirmed'
                                  AND BrokerIId__c =: channelPartners];
        system.debug('bklist size'+bklist.size());
        
        //Get last 60 days booking list.
        list<Booking__c> lst60daysbklist = [SELECT Id,Project__r.Name,Status__c,Booking_Date__c,BrokerIId__c,Project__r.Segment__c FROM Booking__c WHERE
                                   Project__r.Segment__c =: segmentName  
                                    and DAY_ONLY(Booking_Date__c) >= : sixtyDaysAgo 
                                   AND Status__c = 'Booking Confirmed'
                                  AND BrokerIId__c =: channelPartners];
        
        //Assign cp category id vs walkin customer counts map.
        if (!cpclist.isEmpty() && (!opplist.isEmpty() || !bklist.isEmpty())) {
             for (CP_Category__c cpc : cpclist) {
                 integer customercnt = 0;
                 for (Opportunity opp : opplist) {
                     if (opp.First_Site_Visit_Date__c >= cpc.Start_Date__c && opp.First_Site_Visit_Date__c <= cpc.End_Date__c && opp.RW_Walkin_Channel_Partner__c == cpc.Channel_Partner__c) {  
                         customercnt++;
                    }
                 }
                 cpcIdvsOppsizeMap.put(cpc.Id, customercnt);
                 
                 integer bookingcnt = 0;
                 for (Booking__c bk : bklist) {
                     if (bk.Booking_Date__c >= cpc.Start_Date__c && bk.Booking_Date__c <= cpc.End_Date__c && bk.BrokerIId__c == cpc.Channel_Partner__c) {  
                         bookingcnt++;
                    } 
                 }
                 cpcIdvsBksizeMap.put(cpc.Id, bookingcnt);
             }
         }
        system.debug('cpcIdvsOppsizeMap'+cpcIdvsOppsizeMap);
        
        //Assign cp category id vs walkin customer counts and booking count for last 60 days map.
        if (!latestCpCategoryMap.values().isEmpty() && (!lst60daysopplist.isEmpty() || !lst60daysbklist.isEmpty())) {
             for (CP_Category__c cpc : latestCpCategoryMap.values()) {
                 integer lst60dayscustomercnt = 0;
                 for (Opportunity opp : lst60daysopplist) {
                     if (opp.RW_Walkin_Channel_Partner__c == cpc.Channel_Partner__c) {  
                         lst60dayscustomercnt++;
                    }
                 }
                 cpcIdvslst60daysOppsizeMap.put(cpc.id,lst60dayscustomercnt);

                 integer lst60daysbookingcnt = 0;
                 for (Booking__c bk : lst60daysbklist) {
                     if (bk.BrokerIId__c == cpc.Channel_Partner__c) {  
                         lst60daysbookingcnt++;
                    } 
                 }
                 cpcIdvslst60daysBksizeMap.put(cpc.id,lst60daysbookingcnt);
             }
         }
        
        
        
        //Assign cp category id vs booking counts map.
        /*if (!cpclist.isEmpty() && !bklist.isEmpty()) { // Commented by Vinay 
             for (CP_Category__c cpc : cpclist) {
                 integer bookingcnt = 0;
                 for (Booking__c bk : bklist) {
                     if (bk.Booking_Date__c >= cpc.Start_Date__c && bk.Booking_Date__c <= cpc.End_Date__c && bk.BrokerIId__c == cpc.Channel_Partner__c) {  
                         bookingcnt++;
                        if (!cpcIdvsBkListMap.containsKey(cpc.Id)) { 
                            cpcIdvsBkListMap.put(cpc.Id, new List<Booking__c>());
                        }                        
                        cpcIdvsBkListMap.get(cpc.Id).add(bk);
                    } else {
                        //system.debug('Opportunity ' + opp.Id + ' does not match CP_Category__c ' + cpc.Id);
                    }
                 }
                 cpcIdvsBksizeMap.put(cpc.Id, bookingcnt);
             }
         }*/
        system.debug('cpcIdvsBksizeMap'+cpcIdvsBksizeMap);
        
        /*

//walkinCustomerCount = opplist.size();
//walkinCustomerCount = 25; //For testing purpose.
list<Booking__c> bklist = [SELECT Id,Project__r.Name,Status__c FROM Booking__c WHERE
Project__r.Segment__c =: segmentName 
and DAY_ONLY(CreatedDate) >= :leastStartDate 
and DAY_ONLY(CreatedDate) <= :atMostEndDate 
AND Status__c = 'Booking Confirmed'];
system.debug('bklist'+bklist);
system.debug('bklist size'+bklist.size());
bookingsCount = bklist.size();
//bookingsCount = 4; //For testing purpose.
//        
*/
        
        //Assign CP Category using CP Category Tier Classification custom settings.
        
        list<CP_Category_Tier_Classification__c> cpCategoryTierCS = [select id,Name,Year__c,P1_walkin_max__c,P1_booking_min__c,P1_booking_max__c,
                                                                     P1_walkin_min__c,P2_booking_max__c,P2_booking_min__c,P2_walkin_max__c,P2_walkin_min__c,
                                                                     P3_booking_max__c,P3_booking_min__c,P3_walkin_max__c,P3_walkin_min__c,P4_booking_max__c,
                                                                     P4_booking_min__c,P4_walkin_max__c,P4_walkin_min__c from CP_Category_Tier_Classification__c
                                                                     where Name =: segmentName and Year__c =: currentYear];
        system.debug('cpCategoryTierCS'+cpCategoryTierCS);
        list<CP_Category__c> cplisttoUpdate = new list<CP_Category__c>();
        Map<Id,Integer> cpcIdvsCustomerCategoryCountMap = new Map<Id,Integer>();
        Map<Id,Integer> cpcIdvsBookingCategoryCountMap = new Map<Id,Integer>();
        for (Id cpcId : cpcIdvsOppsizeMap.keySet()) {
            System.debug('CP_Category__c Id: ' + cpcId + ' -> Opportunity Count: ' + cpcIdvsOppsizeMap.get(cpcId));
            Integer walkinCustomerCount = cpcIdvsOppsizeMap.get(cpcId);
            Integer tempWalkinCnt = 0;
            //cpc.Id = cpcIds[0];
            //Assign CP Category based on Walkin counts
            if(walkinCustomerCount >= cpCategoryTierCS[0].P4_walkin_min__c  && (walkinCustomerCount <= cpCategoryTierCS[0].P4_walkin_max__c || cpCategoryTierCS[0].P4_walkin_max__c == null )){	
                system.debug('Inside P4 Walkins');
                tempWalkinCnt = 4;
            } else if(walkinCustomerCount >= cpCategoryTierCS[0].P3_walkin_min__c  && (walkinCustomerCount <= cpCategoryTierCS[0].P3_walkin_max__c || cpCategoryTierCS[0].P3_walkin_max__c == null )){	
                system.debug('Inside P3 Walkins');
                tempWalkinCnt = 3;
            } else if(walkinCustomerCount >= cpCategoryTierCS[0].P2_walkin_min__c  && (walkinCustomerCount <= cpCategoryTierCS[0].P2_walkin_max__c || cpCategoryTierCS[0].P2_walkin_max__c == null )){	
                system.debug('Inside P2 Walkins');
                tempWalkinCnt = 2;
            } else if(walkinCustomerCount >= cpCategoryTierCS[0].P1_walkin_min__c  && (walkinCustomerCount <= cpCategoryTierCS[0].P1_walkin_max__c || cpCategoryTierCS[0].P1_walkin_max__c == null )){	
                system.debug('Inside P1 Walkins');
                tempWalkinCnt = 1;
            } 
            cpcIdvsCustomerCategoryCountMap.put(cpcId,tempWalkinCnt);
        }
        
        for (Id cpcId : cpcIdvsBksizeMap.keySet()) {
            Integer bookingsCount = cpcIdvsBksizeMap.get(cpcId);
            Integer tempBookingCnt = 0;
            if(bookingsCount >= cpCategoryTierCS[0].P4_booking_min__c  && (bookingsCount <= cpCategoryTierCS[0].P4_booking_max__c || cpCategoryTierCS[0].P4_booking_max__c == null )){	
                system.debug('Inside P4 Bookings');
                tempBookingCnt = 4;
            } else if(bookingsCount >= cpCategoryTierCS[0].P3_booking_min__c  && (bookingsCount <= cpCategoryTierCS[0].P3_booking_max__c || cpCategoryTierCS[0].P3_booking_max__c == null )){	
                system.debug('Inside P3 Bookings');
                tempBookingCnt = 3;
            } else if(bookingsCount >= cpCategoryTierCS[0].P2_booking_min__c  && (bookingsCount <= cpCategoryTierCS[0].P2_booking_max__c || cpCategoryTierCS[0].P2_booking_max__c == null )){	
                system.debug('Inside P2 Bookings');
                tempBookingCnt = 2;
            } else if(bookingsCount >= cpCategoryTierCS[0].P1_booking_min__c  && (bookingsCount <= cpCategoryTierCS[0].P1_booking_max__c || cpCategoryTierCS[0].P1_booking_max__c == null )){	
                system.debug('Inside P1 Bookings');
                tempBookingCnt = 1;
            }   
            CP_Category__c cpc = new CP_Category__c();
            cpc.Id = cpcId;
            if(tempBookingCnt < cpcIdvsCustomerCategoryCountMap.get(cpcId)){
                cpc.Category__c = 'P'+ tempBookingCnt;
            }else{
                cpc.Category__c = 'P'+ cpcIdvsCustomerCategoryCountMap.get(cpcId);
            }
            if(cpcIdvslst60daysOppsizeMap.get(cpcId) > 0){
                cpc.Walkin_Active__c = true;
            }
            if(cpcIdvslst60daysBksizeMap.get(cpcId) > 0){
                cpc.Booking_Active__c = true;
            }
            system.debug('cp category'+ cpc.Category__c);
            
            cplisttoUpdate.add(cpc);
        }
        if(!cplisttoUpdate.isEmpty()){
            Database.SaveResult[] wiList = Database.update(cplisttoUpdate, false);

            for(Database.SaveResult sr : wiList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ':' + err.getMessage());
                    }
                }
            }
        }
        
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}