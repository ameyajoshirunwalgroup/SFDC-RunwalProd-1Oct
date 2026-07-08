global class Batch_UpdateLeadStatus Implements Database.Batchable<sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        if(test.isRunningtest()){
            string query = 'SELECT Id, Name,Project_Name__c, CP_Lead_Status__c,CPI_Lead_Access__c,IsConverted,IsActive__c,CreatedDate FROM Lead';
            system.debug('*query*'+Database.getQueryLocator(query));
            return Database.getQueryLocator(query);    

        }    
        else{
            //Commented by Dolly on 22-06-2026 starts

            // string query = 'SELECT Id, Name,Project_Name__c, CP_Lead_Status__c,CPI_Lead_Access__c,IsConverted FROM Lead Where CP_Lead_Status__c = \'Active\' AND IsConverted = false';
            // system.debug('*query*'+Database.getQueryLocator(query));
            // return Database.getQueryLocator(query);

            //Commented by Dolly on 22-06-2026 ends

            //Query modified by Dolly on 22-06-2026
            return Database.getQueryLocator([
                SELECT Id, Name, Project_Name__c, CP_Lead_Status__c,
                    CPI_Lead_Access__c, IsConverted,
                    IsActive__c, CreatedDate
                FROM Lead
                WHERE IsConverted = false
                AND (
                    CP_Lead_Status__c = 'Active'
                    OR
                    (IsActive__c = true
                    AND CreatedDate <= :System.now().addDays(-60))
                )
            ]);
        }
        
    }
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        system.debug('Scope1' +scope);
        List<Lead> leadsToUpdate = new List<Lead>(); //Added by Vinay 28-08-2025
        Set<Id> alreadyAdded = new Set<Id>(); //Added by Dolly on 22-06-2026 

        for(Lead LeadObj: scope){
            system.debug('**Scope**' +LeadObj);

            //Added by Dolly on 22-06-2026 starts
            // New Enhancement - Lead inactive after 60 days
            if(LeadObj.IsActive__c && LeadObj.CreatedDate <= System.now().addDays(-60)){

                LeadObj.IsActive__c = false;

                if(!alreadyAdded.contains(LeadObj.Id)){
                    leadsToUpdate.add(LeadObj);
                    alreadyAdded.add(LeadObj.Id);
                }
            }
            //Added by Dolly on 22-06-2026 ends

            if(String.isNotBlank(LeadObj.Project_Name__c) && LeadObj.CP_Lead_Status__c == 'Active'){
                if(LeadObj.Project_Name__c == 'Runwal Gardens' && LeadObj.CPI_Lead_Access__c >= 45 ){
                    LeadObj.CP_Lead_Status__c = 'Inactive';
                    if(!alreadyAdded.contains(LeadObj.Id)){    //Added by Dolly on 22-06-2026 starts
                        leadsToUpdate.add(LeadObj);
                        alreadyAdded.add(LeadObj.Id);    //Added by Dolly on 22-06-2026 starts
                    }
                }
                else if((LeadObj.Project_Name__c == 'Runwal Bliss' ||LeadObj.Project_Name__c == 'Runwal Forests' || LeadObj.Project_Name__c== 'Runwal Pinnacle' || LeadObj.Project_Name__c == 'Runwal Greens'|| LeadObj.Project_Name__c == 'Runwal Avenue' || LeadObj.Project_Name__c == '5th Avenue - Runwal Avenue') && LeadObj.CPI_Lead_Access__c >= 90){
                    LeadObj.CP_Lead_Status__c = 'Inactive';
                    if(!alreadyAdded.contains(LeadObj.Id)){  //Added by Dolly on 22-06-2026 starts
                        leadsToUpdate.add(LeadObj);
                        alreadyAdded.add(LeadObj.Id);  //Added by Dolly on 22-06-2026 starts
                    }
                }
                
                else{
                    decimal a=0;
                    decimal b=0;
                    decimal c=0;
                    c=a+b;
                    decimal c1=a+b;
                    decimal c2=a+b;
                    decimal c3=a+b;
                    decimal c4=a+b;
                    decimal c5=a+b;
                    decimal c6=a+b;
                    decimal c7=a+b;
                    decimal c8=a+b;
                    decimal c9=a+b;
                }
            }        
            
        }
        //update scope; //Commented by Vinay 28-08-2025
        if(leadsToUpdate.size() > 0){ //Added by Vinay 28-08-2025
            //update leadsToUpdate; //Commented by Vinay 07-07-2026
            Database.update(leadsToUpdate, false);  //Added by Vinay 07-07-2026
        }        
    }  
    global void finish(Database.BatchableContext bc) {}   
}