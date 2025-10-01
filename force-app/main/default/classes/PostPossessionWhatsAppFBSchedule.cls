global class PostPossessionWhatsAppFBSchedule implements Database.Batchable <Booking__c>, Database.AllowsCallouts, Schedulable{
	
    global Iterable <Booking__c> start(Database.BatchableContext bc){
        
        /*Date dt = System.today() - 60;
        Date dt60 = System.today() - 60;
        Date dt120 = System.today() - 120;
        Date dt180 = System.today() - 180;
        Date dt270 = System.today() - 270;
        Date dt360 = System.today() - 360;
        system.debug('date: ' + dt);*/
        
        List<Date> frequency = new List<Date>{(Date.today() - 60), (Date.today() - 90), (Date.today() - 120), (Date.today() - 150), (Date.today() - 180), (Date.today() - 210), (Date.today() - 240), (Date.today() - 270), (Date.today() - 300), (Date.today() - 330), (Date.today() - 360)};
        
        /*List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__c, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE RW_Key_handover_date__c =: dt];*/ //Commented by coServe 14-08-2024
        
        /*List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__c, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE (RW_Key_handover_date__c =: dt60 OR RW_Key_handover_date__c =: dt120 OR
                                 RW_Key_handover_date__c =: dt180 OR RW_Key_handover_date__c =: dt270 OR RW_Key_handover_date__c =: dt360)];*/ //Added by coServe 14-08-2024
        List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__c, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE RW_Key_handover_date__c =: frequency];
        return bkgs;
    }
    global void execute(Database.BatchableContext bc, list <Booking__c> bkgs){
        System.debug('bkgs: ' + bkgs);
        for(Booking__c bkg : bkgs){
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(bkg.Opportunity__c, bkg.Primary_Applicant_Name__c, null, null, null, null, null, null, null, bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'post_60_days');
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        /*Date dt = System.today() - 60;
        Date dt60 = System.today() - 60;
        Date dt120 = System.today() - 120;
        Date dt180 = System.today() - 180;
        Date dt270 = System.today() - 270;
        Date dt360 = System.today() - 360;
        system.debug('date: ' + dt);*/
        
        List<Date> frequency = new List<Date>{(Date.today() - 60), (Date.today() - 90), (Date.today() - 120), (Date.today() - 150), (Date.today() - 180), (Date.today() - 210), (Date.today() - 240), (Date.today() - 270), (Date.today() - 300), (Date.today() - 330), (Date.today() - 360)};
        
        /*List<Booking__c> bkgs = [SELECT Id, Name, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE RW_Key_handover_date__c =: dt];*/ //Commented by coServe 14-08-2024
        
        /*List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__c, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE (RW_Key_handover_date__c =: dt60 OR RW_Key_handover_date__c =: dt120 OR
                                 RW_Key_handover_date__c =: dt180 OR RW_Key_handover_date__c =: dt270 OR RW_Key_handover_date__c =: dt360)];*/ //Added by coServe 14-08-2024
        List<Booking__c> bkgs = [SELECT Id, Name, Opportunity__c, Primary_Applicant_Name__c, RW_Country_Phone_Code__c, Opportunity__r.RW_Mobile_No__c
                                 FROM Booking__c WHERE RW_Key_handover_date__c =: frequency];
        
        System.debug('bkgList: ' + bkgs);
        String bookings;
        for(Booking__c bk : bkgs){
            if(bookings == null){
                bookings = bk.Name;
            }else{
                bookings += ', ' + bk.Name;
            }
        }
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email    from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'vinay.kumar.os@runwalgroup.in','shraddha.shahari@runwalgroup.in'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('PostPossessionWhatsAppFBSchedule ' + a.Status);
        String message = 'records processed ' + a.TotalJobItems +   'with '+ a.NumberOfErrors + ' failures.<br/><br/>';
        message += 'Bookings: ' + bookings;
        mail.setHtmlBody(message);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    global void execute(SchedulableContext dc) {
        PostPossessionWhatsAppFBSchedule b = new PostPossessionWhatsAppFBSchedule();
        Database.executeBatch(b, 20);
    }
}