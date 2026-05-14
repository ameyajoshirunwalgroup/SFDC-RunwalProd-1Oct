@RestResource(urlMapping='/tataWebhook/*') 
global class TataWebhook {
    
    @HttpPost
    global static void createTask(){
        
        String jsonBody;
        String oppId;
        try{
            RestRequest req = RestContext.request;
            jsonBody = req.requestBody.toString();
            //CallData data = new CallData();
            
            Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
            
            String agentNumber;
            if(data.get('answered_agent') != null && data.get('answered_agent') != ''){
                String answeredAgent = JSON.serialize(data.get('answered_agent'));
                Answered_Agent answeredAgentDetails = (Answered_Agent)JSON.deserialize(answeredAgent, Answered_Agent.class );
                agentNumber = answeredAgentDetails.agent_number;
            }else if(data.get('missed_agent') != null && data.get('missed_agent') != ''){
                String missedAgent = JSON.serialize(data.get('missed_agent'));
                missedAgent = missedAgent.replace('[','');
                missedAgent = missedAgent.replace(']','');
                Missed_Agent missedAgentDetails = (Missed_Agent)JSON.deserialize(missedAgent, Missed_Agent.class );
                agentNumber = missedAgentDetails.agent_number;
            }
            
            //data = (CallData)JSON.deserialize(jsonBody, CallData.class );
            if(agentNumber != null){
                agentNumber = agentNumber.replace('+','');
                if(agentNumber.subString(0,1) == '0'){
                    agentNumber = '91' + agentNumber;
                }
            }
            
            String updatedMobile;
            updatedMobile = String.valueOf(data.get('customer_no_with_prefix')).deleteWhitespace();
            updatedMobile = updatedMobile.replace('+','');
            
            while(updatedMobile.subString(0,1) == '0'){
                updatedMobile = updatedMobile.subString(1,updatedMobile.length());
            }
            
            if(updatedMobile.subString(0,1) == '(' && updatedMobile.contains(')')){
                updatedMobile = updatedMobile.replace('(', '');
                updatedMobile = updatedMobile.replace(')', '');
                updatedMobile = '1' + updatedMobile;
            }else if(updatedMobile.subString(3,4) == '-'){
                updatedMobile = updatedMobile.replace('-', '');
                updatedMobile = '1' + updatedMobile;
            }
            //Added by Vinay 06-05-2025 Strat
            /*List<String> mobileNums = new List<String>();
mobileNums.add(updatedMobile);
if(updatedMobile.length() == 12 && updatedMobile.subString(0,2) == '91'){ 
mobileNums.add(updatedMobile.subString(2,12));
}*/
            //Added by Vinay 06-05-2025 End
            String taskWhatId;
            String taskWhoId;
            String leadAccountName;
            String rmName;
            String projectName; //Added by Vinay 17-12-2025
            if(data.get('recordId') != null && data.get('recordId') != 'null' && data.get('recordId') != '' && data.get('recordId') != '$recordId'){
                Id recId = String.valueOf(data.get('recordId')); 
                String objName = recId.getSObjectType().getDescribe().getName();
                if(objName == 'Opportunity'){
                    List<Opportunity> oppList = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,StageName,RW_RM_Name__c,RW_Project__r.Name FROM Opportunity WHERE Id =: recId]; //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
                    taskWhatId = recId;
                    leadAccountName = oppList[0].Name;
                    rmName = oppList[0].RW_RM_Name__c;
                    oppId = recId;
                    projectName = oppList[0].RW_Project__r.Name; //Added by Vinay 17-12-2025
                }else if(objName == 'Account'){
                    List<Account> accList =  [SELECT Id,Name,RM_Name__c,Project_Name__r.Name From Account WHERE Id =: recId];
                    taskWhatId = recId;
                    leadAccountName = accList[0].Name;
                    rmName = accList[0].RM_Name__c;
                    projectName = accList[0].Project_Name__r.Name; //Added by Vinay 17-12-2025
                }else if(objName == 'Lead'){
                    List<Lead> leadList = [SELECT Id,Name,Campaign_Code__c,LeadSource,Lead_Sub_Source__c,RW_Project__c,RDS_Country__c,RDS_Country_Code__c,RW_Project__r.Name FROM Lead WHERE Id =: recId];
                    taskWhoId = recId;
                    leadAccountName = leadList[0].Name;
                    projectName = leadList[0].RW_Project__r.Name; //Added by Vinay 17-12-2025
                }
            }else{
                List<String> projects = System.label.TATA_CTI_Projects.split(','); //Added by Vinay 17-10-2025
                //List<Opportunity> oppList = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_RM_Name__c FROM Opportunity WHERE RW_Project__r.Name = '7 Mahalaxmi' AND (RW_Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile )]; //Commented by Vinay 06-05-2025
                //List<Opportunity> oppList = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_RM_Name__c FROM Opportunity WHERE RW_Project__r.Name = '7 Mahalaxmi' AND (RW_Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile )]; //Added by Vinay 06-05-2025 //Commented by Vinay 17-10-2025
                List<Opportunity> oppList = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,StageName,RW_RM_Name__c,RW_Project__r.Name FROM Opportunity WHERE RW_Project__r.Name =: projects AND (RW_Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile )]; //Added by Vinay 17-10-2025 //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
                List<Opportunity> bookedOppList = new List<Opportunity>();
                if(oppList.size() > 1){
                    for(Opportunity opp : oppList){
                        if(opp.StageName == 'Unit Booked'){
                            bookedOppList.add(opp);
                        }
                    }
                }
                if(bookedOppList.size() > 0){
                    taskWhatId = bookedOppList[0].Id;
                    leadAccountName = bookedOppList[0].Name;
                    rmName = bookedOppList[0].RW_RM_Name__c;
                    oppId = bookedOppList[0].Id;
                    projectName = bookedOppList[0].RW_Project__r.Name; //Added by Vinay 17-12-2025
                }else if(oppList.size() > 0){
                    taskWhatId = oppList[0].Id;
                    leadAccountName = oppList[0].Name;
                    rmName = oppList[0].RW_RM_Name__c;
                    oppId = oppList[0].Id;
                    projectName = oppList[0].RW_Project__r.Name; //Added by Vinay 17-12-2025
                }
                
                if(oppList.size() == 0){
                    //List<Account> accList =  [SELECT Id, Name, RM_Name__c From Account WHERE Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile ORDER BY CreatedDate desc]; //Commented by Vinay 06-05-2025
                    List<Account> accList =  [SELECT Id,Name,RM_Name__c,Project_Name__r.Name From Account WHERE Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile OR RW_Secondary_Mobile_No__pc =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile ORDER BY CreatedDate desc]; //Added by Vinay 06-05-2025
                    if(accList.size() > 0){
                        taskWhatId = accList[0].Id;
                        leadAccountName = accList[0].Name;
                        rmName = accList[0].RM_Name__c;
                        projectName = accList[0].Project_Name__r.Name; //Added by Vinay 17-12-2025
                    }else{
                        //List<Lead> leadList = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile) AND IsConverted= false ORDER BY CreatedDate desc]; //Commented by Vinay 06-05-2025
                        List<Lead> leadList = [SELECT Id,Name,Campaign_Code__c,LeadSource,Lead_Sub_Source__c,RW_Project__c,RDS_Country__c,RDS_Country_Code__c,RW_Project__r.Name FROM Lead WHERE (RW_Mobile_No__c =: updatedMobile OR Mobile_No_with_Country_Code__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile) AND IsConverted= false ORDER BY CreatedDate desc]; //Added by Vinay 06-05-2025
                        if(leadList.size() > 0){
                            taskWhoId = leadList[0].Id;
                            leadAccountName = leadList[0].Name;
                            projectName = leadList[0].RW_Project__r.Name; //Added by Vinay 17-12-2025
                        }
                    }
                }
            }
            //List<User> usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c, Tata_CTI_Agent_Number__c FROM User WHERE Tata_CTI_Agent_Number__c != null AND Tata_CTI_Agent_Number__c =: data.answered_agent_number];
            Id CRMRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
            
            Task t = new Task();
            t.status = 'In-Progress';
            t.Task_Type__c = 'CRM Call';
            t.Priority = 'Normal';
            t.RecordTypeId = CRMRecordTypeId;
            t.CallType__c = String.valueOf(data.get('direction'));
            t.Voice_Log_URL__c = String.valueOf(data.get('recording_url'));
            t.WhatId = taskWhatId;
            t.WhoId = taskWhoId;
            if(data.get('call_status') == 'Missed' || data.get('call_status') == 'missed'){
                t.Subject = 'Missed Call';
                t.status = 'Completed';
            }else{
                t.Subject = 'CRM Call';
            }
            if(data.get('direction') == 'inbound'){
                t.CallType__c = 'Inbound';
                t.Type_Of_Meeting__c = 'Inbound';
                t.Communication_Type__c = 'Inbound Call';
                agentNumber = String.valueOf(data.get('call_to_number'));
            }
            if(data.get('direction') == 'outbound' || data.get('direction') == 'click_to_call' || data.get('direction') == 'clicktocall'){
                t.CallType__c = 'Outbound';
                t.Type_Of_Meeting__c = 'Outbound';
                t.Communication_Type__c = 'Outbound Call';
            }
            Boolean ownerAssigned = false;
            if(agentNumber != null){
                List<User> usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c, Tata_CTI_Agent_Number__c FROM User WHERE Tata_CTI_Agent_Number__c != null AND Tata_CTI_Agent_Number__c =: agentNumber AND IsActive = true];
                if(usr.size() > 0){
                    t.OwnerId = usr[0].Id;
                    ownerAssigned = true;
                }
            }
            if(rmName != null){
                List<User> usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c, Tata_CTI_Agent_Number__c FROM User WHERE Tata_CTI_Agent_Number__c != null AND Name =: rmName AND IsActive = true];
                if(usr.size() > 0){
                    t.OwnerId = usr[0].Id;
                    ownerAssigned = true;
                }
            }
            if(ownerAssigned == false){
                //t.OwnerId = System.label.Default_Agent_for_TATA; //Commented by Vinay 17-12-2025
                if(projectName == 'Runwal Woods'){  //Added by Vinay 17-12-2025
                    t.OwnerId = System.label.Default_Agent_for_TATA_Runwal_Woods;
                }else{
                    t.OwnerId = System.label.Default_Agent_for_TATA;
                }
            }
            t.Remarks__c = String.valueOf(data.get('call_to_number'));
            t.CallDurationInSeconds = (data.get('duration') != null && data.get('duration') != '')? Integer.valueOf(data.get('duration')) : null;
            t.Lead_Account_Name__c = leadAccountName;
            t.Disposition_Type__c = String.valueOf(data.get('call_status'));
            if((data.get('call_status') == 'Missed' || data.get('call_status') == 'missed') && t.CallType__c == 'Inbound'){ // Added by Vinay 16-01-2025
                t.Disposition_Type__c = 'Not Answered';
            }else if((data.get('call_status') == 'Missed' || data.get('call_status') == 'missed') && t.CallType__c == 'Outbound'){ // Added by Vinay 16-01-2025
                t.Disposition_Type__c = 'Fail';
                t.Subject = 'CRM Call';
            }
            if(data.get('reason_key') != null){ // Added by Vinay 07-01-2025 
                t.CallDisposition = String.valueOf(data.get('reason_key')); 
            }
            if(data.get('reason_key') == 'Extension_Not_Registered'){ // Added by Vinay 16-01-2025 
                t.Disposition_Type__c = 'Fail'; 
            }
            //t.Campaign_Name_from_CTI__c = String.valueOf(data.get('campaign_name'));
            t.CallObject = String.valueOf(data.get('call_id'));
            //String endStamp = String.valueOf(data.get('end_stamp'));
            //Datetime dt = Datetime.valueOf(endStamp);
            //t.Call_Time__c = dt.format('h:mm a');
            t.Call_Time__c = Datetime.valueOf(String.valueOf(data.get('end_stamp'))).format('h:mm a');
            insert t;
        }catch(exception e){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.Opportunity__c = (oppId != '')? oppId : null;
            log.request__c = jsonBody;
            log.API_name__c = 'Tata Webhook';
            log.response__c = e.getMessage();
            log.Status__c='Failure';
            log.Error_Type__c='Data Error';
            log.Error_Reason__c = e.getMessage();
            insert log;
        }
        //return t.Id;
    }
    /*global class CallData{
public String uuid;
public String call_to_number;
public String caller_id_number;
//public String date;
//public String call_flow;
public String dept_name;
public String ivr_name;
public String call_id;
//public String billing_circle;
public String agent_number;
public String agent_name;
public String customer_no_with_prefix;
public String start_stamp;
public String direction;
public String answered_agent_number;
public String call_status;
public String customer_ring_time;
public String answer_stamp;
public String end_stamp;
public String hangup_cause;
public String billsec;
public String digits_dialed;
public String duration;
public String answered_agent;
public String answered_agent_name;
public String missed_agent;
public String broadcast_lead_fields;
public String recording_url;
public String outbound_sec;
public String agent_ring_time;
public String agent_transfer_ring_time;
public String call_connected;
public String aws_call_recording_identifier;
public String campaign_name;
public String campaign_id;
public String reason_key;
public String recordId;
}*/
    global class Answered_Agent{
        public String name;
        public String agent_number;
    }
    
    global class Missed_Agent{
        public String name;
        public String agent_number;
    }
    
}