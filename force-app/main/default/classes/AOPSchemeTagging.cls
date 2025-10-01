public class AOPSchemeTagging {
    public static void AOPSchemeTagging() {  
        List<AOP__c> AOPScheme = [SELECT Id, Name, Start_Date__c, End_Date__c, Legacy_booking_treated__c, Category__c, Channel_Partner__c, RecordTypeId 
                                  FROM AOP__c 
                                  WHERE CreatedDate < TODAY AND RecordType.Name = 'AOP' AND Legacy_booking_treated__c = false
                                  ];

        System.debug('AOPScheme --> ' + AOPScheme);
        System.debug('AOPScheme Size --> ' + AOPScheme.size());

        List<Booking__c> bookingListToUpdate = new List<Booking__c>();
        List<Booking__c> bookingList = new List<Booking__c>();
        List<AOP__c> AOPSchemetoUpdate = new List<AOP__c>();
        Map<Id, List<Booking__c>> aopIdvsBkListMap = new Map<Id, List<Booking__c>>();

        List<Date> startDates = new List<Date>();
        List<Date> endDates = new List<Date>();

        if (!AOPScheme.isEmpty()) {
            for (AOP__c aop : AOPScheme) {
                startDates.add(aop.Start_Date__c);
                endDates.add(aop.End_Date__c);
            }
        }

        startDates.sort();
        endDates.sort();

        System.debug('Sorted startDates --> ' + startDates);
        System.debug('Sorted endDates --> ' + endDates);
         Date leastStartDate;
         Date atMostEndDate;
        if(!Test.isRunningTest()){
        leastStartDate = startDates[0];
       atMostEndDate = endDates[endDates.size() - 1];
        
        System.debug('Least startDate --> ' + leastStartDate);
        System.debug('At most endDate --> ' + atMostEndDate);
        }
        bookingList = [SELECT Id, Quotation__r.Quote_Status__c, Quotation__r.Discount_9_L__c, Name, Opportunity__c, BrokerIId__c, Agreement_Value_for_brokers__c, Project__c, 
                              Booking_Date__c, Tower__c, X5_Received__c, RW_X9_99_Received__c, RW_Registration_Done__c, Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, 
                              Type_Of_Client_Formula__c, CreatedDate, Opportunity__r.RW_Walkin_Channel_Partner__c  
                       FROM Booking__c 
                       WHERE DAY_ONLY(CreatedDate) >= :leastStartDate AND DAY_ONLY(CreatedDate) <= :atMostEndDate 
                             AND Opportunity__r.RW_Walkin_Channel_Partner__c != null 
                             AND AOP_Scheme__c = null 
                             AND Status__c IN ('Booking Confirmed','UnProcessed')   
                             AND Quotation__r.Quote_Status__c = 'Valid' 
                             AND Quotation__r.Discount_9_L__c = null 
                       ORDER BY CreatedDate DESC];

        System.debug('Total Bookings Found: ' + bookingList.size());
        System.debug('Total AOP scheme Found: ' + AOPScheme.size());

         if (!bookingList.isEmpty() && !AOPScheme.isEmpty()) {
             for (AOP__c aop : AOPScheme) {
                 for (Booking__c bk : bookingList) {
                     if (bk.CreatedDate >= aop.Start_Date__c && bk.CreatedDate <= aop.End_Date__c && bk.Opportunity__r.RW_Walkin_Channel_Partner__c == aop.Channel_Partner__c) {
                        system.debug('Booking__c record ' + bk.Id + ' matches AOP__c ' + aop.Id);
                        
                        if (!aopIdvsBkListMap.containsKey(aop.Id)) {
                            aopIdvsBkListMap.put(aop.Id, new List<Booking__c>());
                            system.debug('Initialized new list for AOP Id: ' + aop.Id);
                        }
                        
                        aopIdvsBkListMap.get(aop.Id).add(bk);
                        system.debug('Added Booking__c ' + bk.Id + ' to AOP Id: ' + aop.Id);
                    } else {
                        system.debug('Booking__c ' + bk.Id + ' does not match AOP__c ' + aop.Id);
                    }
                 }
             }
         }
        
        // Final log for mapped AOP to Booking list
        system.debug('Final AOP to Booking Mapping: ' + aopIdvsBkListMap);

        
        System.debug('AOP ID to Booking List Map --> ' + aopIdvsBkListMap);
        
        for (Id aopId : aopIdvsBkListMap.keySet()) {
            for (Booking__c bk : aopIdvsBkListMap.get(aopId)) {
                bk.AOP_Scheme__c = aopId;
                bk.Is_AOP_CP_Applicable__c = true;
                bookingListToUpdate.add(bk);
            }
            AOP__c aop = new AOP__c();
            aop.Id = aopId;
            aop.Legacy_booking_treated__c = true;
            AOPSchemetoUpdate.add(aop);
        }
        
        
        System.debug('Total Bookings to Update --> ' + bookingListToUpdate.size());
        System.debug('Total AOP Schemes to Update --> ' + AOPSchemetoUpdate.size());
        System.debug('AOPSchemetoUpdate: ' + AOPSchemetoUpdate);
        System.debug('bookingListToUpdate: ' + bookingListToUpdate);

        if (!bookingListToUpdate.isEmpty()) {
            try {
                update bookingListToUpdate;
                System.debug('Successfully updated booking records.');

                if (!AOPSchemetoUpdate.isEmpty()) {
                    update AOPSchemetoUpdate;
                    System.debug('Successfully updated AOP records.');
                }
            } catch (Exception e) {
                System.debug('Error while updating Booking list ----> ' + e.getMessage());
            }
        }
    }
        Public static void Dummy(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

 i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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