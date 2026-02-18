global class PaymentDueAlertSchedule implements Database.Batchable <sObject>, Schedulable, Database.AllowsCallouts{
    public List<String> crnNums;
    
    public PaymentDueAlertSchedule(List<String> crn){
       this.crnNums = crn;
    }
    
    public PaymentDueAlertSchedule(){
        this.crnNums = crnNums;
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(crnNums != null && crnNums.size() > 0){
            /*return Database.getQueryLocator([SELECT Id, Unit_No__r.Name, RW_Project_Name__c, FBL5N__c, RW_Total_Demand_Outstanding__c, Primary_Applicant_Name__c, Primary_Applicant_Email__c FROM Booking__c 
                                       WHERE Opportunity__r.SAP_Customer_Number__c =: crnNums AND RW_Project_Name__c != 'Runwal MyCity']);*/
            return Database.getQueryLocator([SELECT Id, Name, Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, RW_Mobile_No__c,
                                             Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Email__c, RW_Project__c FROM Opportunity 
                                             WHERE SAP_Customer_Number__c =: crnNums AND 
                                             Booking__r.RW_Project_Name__c != 'Runwal MyCity']);   
        }else{
            /*return Database.getQueryLocator([SELECT Id, Unit_No__r.Name, RW_Project_Name__c, FBL5N__c, RW_Total_Demand_Outstanding__c, Primary_Applicant_Name__c, Primary_Applicant_Email__c FROM Booking__c 
                                       WHERE FBL5N__c >= 50000 AND Status__c IN ('Processed','Booking Received','Booking Confirmed','Unit Booked') AND RW_Project_Name__c != 'Runwal MyCity']);*/
            
            if(System.label.Payment_Due_Alert_All_Customers == 'true'){
                
                List<Opportunity> oppList = [SELECT Id, Name,Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, RW_Mobile_No__c, Booking__r.Project__r.Outstanding_Amount_Limit__c,
                                             Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Email__c, RW_Project__c FROM Opportunity 
                                             WHERE StageName = 'Unit Booked' AND Booking__r.Status__c  = 'Booking Confirmed'];
                
                List<String> oppIdsFiltered = new List<String>();
                for(Opportunity opp : oppList){
                    if(opp.Booking__r.Project__r.Outstanding_Amount_Limit__c != null && opp.Booking__r.FBL5N__c >= opp.Booking__r.Project__r.Outstanding_Amount_Limit__c){
                        oppIdsFiltered.add(opp.Id);
                    }
                }
                return Database.getQueryLocator([SELECT Id, Name, Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, RW_Mobile_No__c,
                                             Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Email__c, RW_Project__c FROM Opportunity 
                                             WHERE Id =: oppIdsFiltered]);
                /*return Database.getQueryLocator([SELECT Id, Name,Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, RW_Mobile_No__c,
                                             Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Email__c FROM Opportunity 
                                             WHERE StageName = 'Unit Booked' AND Booking__r.Status__c  = 'Booking Confirmed' AND Booking__r.RW_Project_Name__c != 'Runwal MyCity' AND ((Booking__r.FBL5N__c >= 50000 AND Booking__r.RW_Project_Name__c != 'Runwal Gardens')  OR (Booking__r.FBL5N__c >= 25000 AND Booking__r.RW_Project_Name__c = 'Runwal Gardens'))]);*/
            }else{
                List<RW_Demand__c> demands = [SELECT Id, Booking__c FROM RW_Demand__c WHERE RW_Demand_Status__c IN ('Due','Partial') AND Due_Date__c <: Date.today()];
                
                Set<String> bkgIds = new Set<String>();
                for(RW_Demand__c dem : demands){
                    bkgIds.add(dem.Booking__c);
                }
                
                Set<String> oppIds = new Set<String>();
                List<Booking__c> bkgs = [SELECT Id, Opportunity__c, FBL5N__c, Project__r.Outstanding_Amount_Limit__c FROM Booking__c WHERE Id =: bkgIds AND Status__c = 'Booking Confirmed' AND Opportunity__r.StageName = 'Unit Booked'];
                for(Booking__c bkg : bkgs){
                    if(bkg.Project__r.Outstanding_Amount_Limit__c != null && bkg.FBL5N__c >= bkg.Project__r.Outstanding_Amount_Limit__c){
                        oppIds.add(bkg.Opportunity__c);
                    }
                }
                System.debug('oppIds: ' + oppIds.size());
                return Database.getQueryLocator([SELECT Id, Name, Booking__c, Booking__r.Unit_No__r.Name, Booking__r.RW_Project_Name__c, Booking__r.FBL5N__c,
                                             Booking__r.RW_Total_Demand_Outstanding__c, Booking__r.Primary_Applicant_Name__c, RW_Mobile_No__c,
                                             Booking__r.RW_Country_Phone_Code__c, Booking__r.Primary_Applicant_Email__c, RW_Project__c FROM Opportunity 
                                             WHERE Id =: oppIds]);
            }
            
        }
      
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> opps){
        list <Messaging.SingleEmailMessage> mails = new list <Messaging.SingleEmailMessage>();
        System.debug('opp: ' + opps.size());
        List<String> oppIds = System.label.Opportunity_Ids_to_skip_Payment_due_alert.split(','); //Added by Vinay 30-05-2025
        List<String> projects = System.label.Payment_Due_Alert_Excluded_Projects.split(','); //Added by Vinay 02-07-2025
        for(Opportunity opp : opps){
            if(opp.Booking__c != null && !oppIds.contains(opp.Id) && !projects.contains(opp.RW_Project__c)){ // Added !oppIds.contains(opp.Id) by Vinay 30-05-2025 //Added !projects.contains(opp.Booking__r.RW_Project_Name__c) by Vinay 02-07-2025
                Decimal demOut = opp.Booking__r.FBL5N__c;
                List<String> args = new String[]{'0','number','##,##,##,###.##'};
                String amount = String.format(demOut.format(), args);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{opp.Booking__r.Primary_Applicant_Email__c});
                mail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                mail.setSubject('PAYMENT DUE ALERT - RUNWAL');
                String body = 'Dear ' + opp.Booking__r.Primary_Applicant_Name__c + ', <br/><br/>';
                body += 'Kindly note you have an outstanding due against your unit "' + opp.Booking__r.Unit_No__r.Name + '", in "' + opp.Booking__r.RW_Project_Name__c + '" Project.<br/><br/>';
                body += 'The current outstanding amount is RS. ' +  amount +'.<br/><br/>';
                body += 'Kindly make your payment on or before due date to avoid additional charges.<br/><br/>Regards,<br/>Team Runwal.';
                mail.sethtmlbody(body);
                mails.add(mail);
                if(!Test.isRunningTest()){
					SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(opp.Id,opp.Booking__r.Primary_Applicant_Name__c, opp.Booking__r.Unit_No__r.Name, amount, null, null, null, null, null, opp.Booking__r.RW_Country_Phone_Code__c, opp.RW_Mobile_No__c, 'Payment Due Alert WhatsApp');     
                    
                }
                
            }
            
        }
        if(mails.size() > 0){
            //Messaging.SendEmailResult[] result = Messaging.sendEmail(mails, false);
        	//System.debug('result' + result);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){

    }
    
    global void execute(SchedulableContext dc) {

        PaymentDueAlertSchedule b = new PaymentDueAlertSchedule();

        Database.executeBatch(b, 100);
    }
}