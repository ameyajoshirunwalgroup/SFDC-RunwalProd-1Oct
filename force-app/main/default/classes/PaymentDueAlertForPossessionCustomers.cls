global class PaymentDueAlertForPossessionCustomers implements Database.Batchable <sObject>, Schedulable, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        List<Booking__c> bkgList = new List<Booking__c>();
        
        if(!Test.isRunningTest()){
            bkgList = [SELECT Id, Name, Unit_No__r.Name, RW_Project_Name__c, FBL5N__c, RW_Total_Demand_Outstanding__c, 
                                    Primary_Applicant_Name__c, Opportunity__r.RW_Mobile_No__c, Project__r.Outstanding_Amount_Limit__c,
                                    RW_Country_Phone_Code__c, Primary_Applicant_Email__c FROM Booking__c WHERE 
                                    Opportunity__r.StageName = 'Unit Booked' AND Status__c  = 'Booking Confirmed' AND Demanded_Principal__c >= 95 AND
                                    Date_of_Occupation_Certificate__c != null AND Date_of_Occupation_Certificate__c <= TODAY];
        }else{
            bkgList = [SELECT Id, Name, Unit_No__r.Name, RW_Project_Name__c, FBL5N__c, RW_Total_Demand_Outstanding__c, 
                                    Primary_Applicant_Name__c, Opportunity__r.RW_Mobile_No__c, Project__r.Outstanding_Amount_Limit__c,
                                    RW_Country_Phone_Code__c, Primary_Applicant_Email__c FROM Booking__c];
        }
        
        
        List<String> bkgIdsFiltered = new List<String>();
        for(Booking__c bkg : bkgList){
            if(bkg.Project__r.Outstanding_Amount_Limit__c != null && bkg.FBL5N__c >= bkg.Project__r.Outstanding_Amount_Limit__c){
                bkgIdsFiltered.add(bkg.Id);
            }
        }
        System.debug('bkgIdsFiltered: ' + bkgIdsFiltered);
        return Database.getQueryLocator([SELECT Id, Name, Unit_No__r.Name, RW_Project_Name__c, FBL5N__c, RW_Total_Demand_Outstanding__c, 
                                    Primary_Applicant_Name__c, Opportunity__r.RW_Mobile_No__c, Project__r.Outstanding_Amount_Limit__c,
                                    RW_Country_Phone_Code__c, Primary_Applicant_Email__c, Project__c FROM Booking__c WHERE Id =: bkgIdsFiltered]);
    }
    
    global void execute(Database.BatchableContext BC, List<Booking__c> bkgs){
        List<String> oppIds = System.label.Opportunity_Ids_to_skip_Payment_due_alert.split(','); //Added by Vinay 02-07-2025
        List<String> projects = System.label.Payment_Due_Alert_Excluded_Projects.split(','); //Added by Vinay 02-07-2025
        for(Booking__c bkg : bkgs){
            if(!oppIds.contains(bkg.Opportunity__c) && !projects.contains(bkg.Project__c)){ // Added if condition by Vinay 02-07-2025
                Decimal demOut = bkg.FBL5N__c;
                List<String> args = new String[]{'0','number','##,##,##,###.##'};
                    String amount = String.format(demOut.format(), args);
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,bkg.Primary_Applicant_Name__c, amount, null, null, null, null, null, null, bkg.RW_Country_Phone_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'Payment Due Alert Possession Customers');     
                }
            }
        }        
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        PaymentDueAlertForPossessionCustomers b = new PaymentDueAlertForPossessionCustomers();
        Database.executeBatch(b, 100);
    }
	
}