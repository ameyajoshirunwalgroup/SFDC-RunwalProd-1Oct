global class LeadsFromMagicBricksBatch implements Database.Batchable <sObject>, Database.AllowsCallouts {
  
    global final DateTime previousFireTime;
    global final DateTime currentFireTime;
    
    global LeadsFromMagicBricksBatch(DateTime previous, DateTime current){
        previousFireTime = previous;
        currentFireTime  = current;
    }
    
    global List<Lead> start(Database.BatchableContext BC) {
        //Make HTTP Call out to MagicBricks
        return LeadsFromMagicBricksCallout.getLeads(previousFireTime, currentFireTime);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
      //saveLeadsToSalesforce(scope);
    List < Lead > leadList = new List < Lead > ();
        for (lead l: scope) {
          System.debug('L from loop:' + l);
            database.DMLOptions dmo = new database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerUserEmail = true;
            l.setOptions(dmo);
            //leadList.add(l); //Commented by Vinay 28-08-2025
            if(!String.isBlank(l.RW_Project__c)){ //Added by Vinay 28-08-2025
                leadList.add(l);
            }else{
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                log.request__c = 'RW_Mobile_No__c: ' +  l.RW_Mobile_No__c + ', Email: ' + l.Email + ', Name: ' + l.LastName + ', Integration_Source__c: MagicBricks';
                log.API_name__c = 'Lead Creation Error';
                log.response__c = 'Project is missing';
                log.Status__c='Failure';
                log.Error_Type__c='Data Error';
                log.Error_Reason__c = 'Project is missing';
                insert log;
            }
            try {
                List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if (dupList.isEmpty()) {
                    try {
                        Database.saveResult[] srList = Database.insert(leadList, true);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                try {
                                  System.debug('Here: 1');
                                    // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                    // this is so that the complete form info is saved somewhere
                                    Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                    enquiryMap.put(sr.getId(), l);
                                    Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                    whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                                    task t = [Select Id, new_lead_created__c from task where id = : whoIDMap.get(sr.getId()).Id];
                                    t.new_lead_created__c = true;
                                    upsert t;
                                } catch (Exception ex) {
                                    System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                                }
                            } else {
                                // Operation failed, so get all errors  
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }

                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                    }
                }
            } catch (GlobalException g) {

            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {}  
}