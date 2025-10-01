global class ReceiptLetterAlert implements Database.Batchable <sObject>, Database.AllowsCallouts, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, RW_Booking__c, RW_Booking__r.Opportunity__c, RW_Booking__r.Opportunity__r.RW_Mobile_No__c, RW_Booking__r.RW_Country_Phone_Code__c, RW_Booking__r.Primary_Applicant_Name__c, RW_Document_Type__c FROM RW_Payment_Details__c WHERE CreatedDate = TODAY]);
    }
    
    global void execute(Database.BatchableContext bc, list <RW_Payment_Details__c> receipts){
        if(receipts.size() > 0){
            List<RW_Payment_Details__c> recs = new List<RW_Payment_Details__c>();
            for(RW_Payment_Details__c recp : receipts){
                if(recp.RW_Document_Type__c == 'DS'){ //Credit Note
                    if(!recs.contains(recp)){
                        recs.add(recp);
                    }
                }
            }
            
            for(RW_Payment_Details__c recp : receipts){
                if(recp.RW_Document_Type__c == 'DF' || recp.RW_Document_Type__c == 'DZ'){// Payment Receipt
                    String recpLink = 'id='+recp.Id+'&doc=recp';
					if(!Test.isRunningTest()){ 
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,recp.RW_Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,recpLink,recp.RW_Booking__r.RW_Country_Phone_Code__c,recp.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Receipt Letter');
                    }
                }
            }
            
            if(recs.size() > 0){
                List<String> oppIds = new List<String>();
                for(RW_Payment_Details__c recp : recs){
                    if(!oppIds.contains(recp.RW_Booking__r.Opportunity__c)){
                        oppIds.add(recp.RW_Booking__r.Opportunity__c);
                    }   
                }
                
                if(oppIds.size() > 0){
                    List<Opportunity> opps = [SELECT Id, RW_Mobile_No__c, Booking__r.Primary_Applicant_Name__c, Booking__r.RW_Country_Phone_Code__c FROM Opportunity WHERE Id =: oppIds];
                    for(Opportunity opp : opps){
                        if(!Test.isRunningTest()){
                            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,opp.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'Credit Note');
                        }
                    }
                }   
            }
            
            
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext dc) {
        ReceiptLetterAlert b = new ReceiptLetterAlert();
        Database.executeBatch(b, 20);
    }

}