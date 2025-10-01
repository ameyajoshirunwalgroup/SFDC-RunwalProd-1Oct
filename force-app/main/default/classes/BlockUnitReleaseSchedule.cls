global class BlockUnitReleaseSchedule implements Database.Batchable <Blocking_Unit_Information__c>, Schedulable{

    global Iterable<Blocking_Unit_Information__c> start(Database.BatchableContext BC){
        
        Date dt1 = Date.today() - Integer.valueof(System.label.Blocking_Release_Days);
        Date dt2 = Date.today() - Integer.valueof(System.label.Blocking_Release_Days_for_Approval);
        
        List<Blocking_Unit_Information__c> blksToTrigger = new List<Blocking_Unit_Information__c>();
        List<Blocking_Unit_Information__c> blks = [SELECT Id, Opportunity__c, Blocked_Date__c, Opportunity__r.Booking__c, Opportunity__r.StageName, Opportunity__r.Blocked_Date__c, Approval_Status__c, Project_Unit__c, CreatedBy.Email, CreatedBy.Manager.Email, Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email FROM Blocking_Unit_Information__c WHERE Active__c = true];
        
        return blks;
    }
    
    global void execute(Database.BatchableContext BC, List<Blocking_Unit_Information__c> blks){
        
        Date dt1 = Date.today();
        Date dt2 = Date.today();
        
        if(!Test.isRunningTest()){
            dt1 = Date.today() - Integer.valueof(System.label.Blocking_Release_Days);
        	dt2 = Date.today() - Integer.valueof(System.label.Blocking_Release_Days_for_Approval);
        }
        
        
        Set<String> oppIds = new Set<String>();
        Set<String> unitIds = new Set<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Project_Unit__c> unitList = new List<Project_Unit__c>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        EmailTemplate template1 = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Blocking_Release_Remainder'];
        EmailTemplate template2 = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Blocking_Release_Approval_Remainder'];
        
        List<Blocking_Unit_Information__c> blksToUpdate = new List<Blocking_Unit_Information__c>();
        String orgEmail = Utility.getOrgWideEmailAddress();
        for(Blocking_Unit_Information__c blk : blks){
            /*if((blk.Approval_Status__c == null || blk.Approval_Status__c == 'Approved') && blk.Blocked_Date__c <= dt1 && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                blk.Active__c = false;
                blksToUpdate.add(blk);
            }else if(blk.Blocked_Date__c <= dt2 && blk.Approval_Status__c == 'Pending' && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                blk.Active__c = false;
                blksToUpdate.add(blk);
            }*/
            if((blk.Approval_Status__c == null || blk.Approval_Status__c == 'Approved') && blk.Blocked_Date__c <= dt1 && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                blk.Active__c = false;
                blksToUpdate.add(blk);
            }
            /*if((blk.Approval_Status__c == null || blk.Approval_Status__c == 'Approved') && blk.Blocked_Date__c <= (dt1 + 1) && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                List<String> toAdrd = new List<String>();
                toAdrd.add(blk.CreatedBy.Email);
                if(blk.CreatedBy.Email != null){
                    toAdrd.add(blk.CreatedBy.Email);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template1.Id);
                mail.setTargetObjectId(Userinfo.getUserId());
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(blk.Id);
                mail.setOrgWideEmailAddressId(orgEmail);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setCcAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in','birendra.hati@runwalgroup.in'});
                mail.setToAddresses(toAdrd);
                mails.add(mail);
            }else if(blk.Blocked_Date__c <= (dt2 + 1) && blk.Approval_Status__c == 'Pending' && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                List<String> toAdrd = new List<String>();
                toAdrd.add(blk.CreatedBy.Email);
                toAdrd.add(blk.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
                if(blk.CreatedBy.Email != null){
                    toAdrd.add(blk.CreatedBy.Email);
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template2.Id);
                mail.setTargetObjectId(Userinfo.getUserId());
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(blk.Id);
                mail.setOrgWideEmailAddressId(orgEmail);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setCcAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in','birendra.hati@runwalgroup.in'});
                mail.setToAddresses(toAdrd);
                mails.add(mail);
            }*/
            if((blk.Approval_Status__c == null || blk.Approval_Status__c == 'Approved') && blk.Blocked_Date__c <= (dt1 + 1) && blk.Opportunity__r.Booking__c == null && (blk.Opportunity__r.StageName == 'Unit Blocked' || blk.Opportunity__r.StageName == 'Qualification')){
                List<String> toAdrd = new List<String>();
                toAdrd.add(blk.CreatedBy.Email);
                if(blk.CreatedBy.Email != null){
                    toAdrd.add(blk.CreatedBy.Email);
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template1.Id);
                mail.setTargetObjectId(Userinfo.getUserId());
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setWhatId(blk.Id);
                mail.setOrgWideEmailAddressId(orgEmail);
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
                mail.setCcAddresses(new List<String>{'shraddha.shahari@runwalgroup.in'});
                mail.setToAddresses(toAdrd);
                mails.add(mail);
            }
        }
        if(mails.size() > 0){
            try{
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            }catch(Exception e){
                system.debug('Exception: '+e);
            }
        }
        
        
        update blksToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        BlockUnitReleaseSchedule b = new BlockUnitReleaseSchedule();
        Database.executeBatch(b, 100);
    }
}