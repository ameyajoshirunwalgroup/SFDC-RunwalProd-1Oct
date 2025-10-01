global class PaymentDueWhatsAppAlertSchedule implements Database.Batchable <sObject>, Schedulable, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name,Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c, RW_Mobile_No__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, Booking__r.RW_Country_Phone_Code__c,
                                             Booking__r.Primary_Applicant_Email__c FROM Opportunity WHERE Payment_Due_Alert_Date__c =: Date.today() AND StageName = 'Unit Booked' AND Booking__r.RW_Project_Name__c != 'Runwal MyCity' AND ((Booking__r.FBL5N__c >= 50000 AND Booking__r.RW_Project_Name__c != 'Runwal Gardens')  OR (Booking__r.FBL5N__c >= 25000 AND Booking__r.RW_Project_Name__c = 'Runwal Gardens'))]);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        List<String> oppIds = System.label.Opportunity_Ids_to_skip_Payment_due_alert.split(','); //Added by Vinay 30-05-2025
        for(Opportunity opp : opps){
            if(!oppIds.contains(opp.Id)){ // Added if condition by Vinay 30-05-2025
                
                Decimal demOut = opp.Booking__r.FBL5N__c;
                List<String> args = new String[]{'0','number','##,##,##,###.##'};
                    String amount = String.format(demOut.format(), args);
                if(!Test.isRunningTest()){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Id,opp.Booking__r.Primary_Applicant_Name__c,opp.Booking__r.Unit_No__r.Name,amount, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, System.label.Payment_Due_Alert_WhatsApp);
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Id,opp.Booking__r.Primary_Applicant_Name__c,opp.Booking__r.Unit_No__r.Name,amount, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, 'payment_outstanding_alert_7g');
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        PaymentDueWhatsAppAlertSchedule b = new PaymentDueWhatsAppAlertSchedule();
        Database.executeBatch(b, 100);
    }

    /*@InvocableMethod(label='Send Payment Due Alert on WhatsApp')
    public static void sendAlertToWhatsApp(List<String> crns){
        
        
        List<Opportunity> opps = [SELECT Id, Name,Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c, RW_Mobile_No__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, Booking__r.RW_Country_Phone_Code__c,
                                             Booking__r.Primary_Applicant_Email__c FROM Opportunity WHERE Payment_Due_Alert_Date__c =: Date.today()];
        for(Opportunity opp : opps){
            Decimal demOut = opp.Booking__r.FBL5N__c;
            List<String> args = new String[]{'0','number','##,##,##,###.##'};
            String amount = String.format(demOut.format(), args);
            SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Booking__r.Primary_Applicant_Name__c,opp.Booking__r.Unit_No__r.Name,amount, null, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, 'payment_outstanding_alert_7g');
        }
    }*/
    
}