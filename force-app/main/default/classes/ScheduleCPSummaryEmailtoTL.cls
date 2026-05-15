global class ScheduleCPSummaryEmailtoTL implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date fifteenDaysBefore = System.today()-15;
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        Map<String,list<Broker__c>> summaryDescVsCPlistMap = new Map<String,list<Broker__c>>();
        List<Broker__c> cplist = [SELECT Id,Name FROM Broker__c WHERE RecordTypeId =: CPRecordTypeId and RERA_Valid_till__c != null /*and CC_Valid_till__c != null  //Commented by Prashant as discussed with team to discard use of CC. 12/12/25.*/]; 
        system.debug('cplist -> '+cplist);
        list<Contact> dummyContact = [Select id from Contact limit 1];
		
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        /*
        for(Broker__c br: cplist){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: 'shraddha.shahari@runwalgroup.in'];
          
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea[0].id);
            }
            String htmlBody = buildEmailBody(rf.Name_of_New_Customer__c,rf.Referral_Amount_Due__c);
            email.setToAddresses(new String[] {rf.Booking__r.Future_Correspondence_Contact_Email__c});
            email.setHtmlBody(htmlBody);
            email.WhatId = rf.Id;            
            email.setSaveAsActivity(true);
            email.setSubject('Credit Note Payout');
            emails.add(email); 
        }
        
        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
            } catch (Exception ex) {
                system.debug('Error in sending emails: ' + ex.getMessage() + ' stack ' + ex.getStackTraceString());
            }
        }*/
    }
}