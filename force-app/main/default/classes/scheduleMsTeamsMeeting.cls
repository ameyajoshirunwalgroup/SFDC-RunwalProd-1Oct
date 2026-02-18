public with sharing class scheduleMsTeamsMeeting {

    @AuraEnabled
    public static RW_MS_Teams__c msIntegration(string strLeadOROppId, string sObjectType,
                                                Datetime startTime, Datetime endTime, string subject, 
                                                string content, string btnLable, string taskType){
       system.debug('_______taskType'+taskType);
        Lead objLead;
        Opportunity objOpp;

        //Formatting dateTime
        String startTimeFormatted = startTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
        system.debug('==>startTimeFormatted'+startTimeFormatted);
        
        String endTimeFormatted = endTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
        system.debug('==>endTimeFormatted  '+endTimeFormatted);
         
        //getting selected lead
        If(sObjectType == 'Lead'){
          objLead = [SELECT Id,Email,Name,RW_Mobile_No__c,RW_Project__c,Project_Name__c,RDS_Country_Code__c FROM Lead WHERE Id =: strLeadOROppId Limit 1];
        
        }
       
         //getting selected Opportunity
         If(sObjectType == 'Opportunity'){
          objOpp = [SELECT Id,RW_Email__c,Name,RW_Mobile_No__c,RW_Project__c,Project_Name__c,Account.Country_Code__c FROM Opportunity WHERE Id =: strLeadOROppId Limit 1];
         }

        // Json from
        JsonClsSchedule objJson  = new JsonClsSchedule();
        objJson.subject = subject;
        JsonClsSchedule.cls_body clsBdy = new JsonClsSchedule.cls_body();
        clsBdy.contentType = 'HTML';
        clsBdy.content = content;
        objJson.body = clsBdy;
        JsonClsSchedule.cls_start clsStart = new JsonClsSchedule.cls_start();
        clsStart.dateTime_start = startTimeFormatted;
        clsStart.timeZone = 'India Standard Time';
        objJson.start = clsStart;
        JsonClsSchedule.cls_end clsEnd = new JsonClsSchedule.cls_end();
        clsEnd.dateTime_End = endTimeFormatted;
        clsEnd.timeZone = 'India Standard Time';
        objJson.end_end = clsEnd;
        JsonClsSchedule.cls_location clsLoc = new JsonClsSchedule.cls_location();
        clsLoc.displayName = 'online';
        objJson.location = clsLoc;
        list<JsonClsSchedule.cls_attendees> listAtten = new list<JsonClsSchedule.cls_attendees>();
        JsonClsSchedule.cls_attendees clsAtt = new JsonClsSchedule.cls_attendees();
        JsonClsSchedule.cls_emailAddress emailAdd = new JsonClsSchedule.cls_emailAddress();
        If(sObjectType == 'Lead'){
         emailAdd.address = objLead.Email;
         emailAdd.name = objLead.Name; 
        }else if(sObjectType == 'Opportunity'){
         emailAdd.address = objOpp.RW_Email__c;
         emailAdd.name = objOpp.Name; 
        }
        clsAtt.emailAddress = emailAdd;
        clsAtt.type = 'required';
        listAtten.add(clsAtt);
        objJson.attendees = listAtten;
        objJson.allowNewTimeProposals = true;
        objJson.isOnlineMeeting = true;
        objJson.onlineMeetingProvider = 'teamsForBusiness';
        system.debug('##objJson  '+objJson);
        
        string str = System.JSON.serialize(objJson);
        String targetDateTimeStart = 'dateTime_start';
        String targetDateTimeEnd = 'dateTime_End';
        String targetEnd = 'end_end';
        String replaceDateTime = 'dateTime';
        String replaceEnd = 'end';
        str = str.replace(targetDateTimeStart, replaceDateTime);
        str = str.replace(targetDateTimeEnd, replaceDateTime);
        str = str.replace(targetEnd, replaceEnd);
        system.debug('##JsonStr  '+str);
        

       //callout
       Http http = new Http();
       HttpRequest req = new HttpRequest(); 
       req.setMethod('POST');
       req.setHeader('Content-Type',  'application/json');
       req.setHeader('Accept', 'application/json'); 
       req.setEndpoint('callout:MS_Teams/v1.0/me/events');//callout:MS_Teams/events
       req.setBody(str);
       HTTPResponse res = http.send(req);
       System.debug('res!!! getBody '+res.getBody());
       System.debug('res!!! getStatusCode '+res.getStatusCode());
       JsonClsSchedule respJsonSchedule= (JsonClsSchedule) JSON.deserialize(res.getBody(), JsonClsSchedule.class);
       System.debug('respJsonSchedule-------- '+respJsonSchedule);
       System.debug('respJsonSchedule MeetingID-------- '+respJsonSchedule.id);                                             
       System.debug('respJsonSchedule onlineMeeting -------- '+respJsonSchedule.onlineMeeting); 
       System.debug('respJsonSchedule onlineMeeting joinUrl-------- '+respJsonSchedule.onlineMeeting.joinUrl);                                         
      
                                             
      
       //JsonClsReSchedule respJson= (JsonClsReSchedule) JSON.deserialize(res.getBody(), JsonClsReSchedule.class);
       RW_MS_Teams__c msTem = new RW_MS_Teams__c(); 
       msTem.RW_Title__c = subject;
       msTem.RW_Start_Time__c = startTime;
       msTem.RW_End_Time__c = endTime;
       msTem.RW_Status__c = btnLable;
       msTem.RW_Meeting_Content__c = content;
       msTem.RW_MeetingID__c = respJsonSchedule.id;
       msTem.RW_OnlineMeeting_JoinUrl__c = respJsonSchedule.onlineMeeting.joinUrl;
       msTem.RW_Call_Type__c = taskType;
       If(sObjectType == 'Lead'){
       msTem.RW_Lead__c = strLeadOROppId;
       msTem.RW_Object_Type__c = 'Lead';
       }else if(sObjectType == 'Opportunity'){
       msTem.RW_Opportunity__c = strLeadOROppId;
       msTem.RW_Object_Type__c = 'Opportunity';
       }
       
       //Getting task recordId
      
       RecordType rt;
       If(taskType == 'Presales Call'){ 
         rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'Presales_Task' LIMIT 1];  
       }else If(taskType ==  'Sales Call'){
         rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'RW_Sales_Task' LIMIT 1];
       }
       
                                                    
       //Creating new record
       Task tsk = new Task(); 
       tsk.OwnerId = UserInfo.getUserId();
       tsk.Subject = 'MS Teams Meeting';
       tsk.Priority = 'Normal';
       tsk.Status = 'Open';
       tsk.Description = 'Schedule MsTeams Meeting';
       If(sObjectType == 'Lead'){
       tsk.WhoId = objLead.id; //record id
       }else if(sObjectType == 'Opportunity'){
       tsk.WhatId = objOpp.id; //record id
       }
       tsk.ActivityDate= Date.today();
       tsk.RecordTypeId = rt.Id;
       tsk.Type = 'Call';
       tsk.Communication_Type__c = 'Outbound Call';
       tsk.Call_Status__c = 'Meeting Scheduled';
       tsk.Next_Action_Date__c = system.now();
       If(taskType == 'Presales Call'){                                              
       tsk.Task_Type__c = 'Presales Call';
       system.debug('139_______taskType'+tsk.Task_Type__c);
       }else If(taskType ==  'Sales Call'){
       tsk.Task_Type__c =  'Sales Call';  
       system.debug('142_______taskType'+tsk.Task_Type__c);
       }
     
        try{  
            
            if(res.getStatusCode() == 201){
            Insert msTem;         
            Insert tsk;
            
            system.debug('msTem____'+msTem); 
            system.debug('task_____'+tsk); 
          
            }
            
           }catch(DMLException e){
            system.debug('Task not inserted !!!!'+e);
            system.debug('msTem not inserted !!!!'+e);
          }
         system.debug(' msTem.RW_Start_Time__c____'+ msTem.RW_Start_Time__c);
         system.debug(' RW_OnlineMeeting_JoinUrl__c____' +msTem.RW_OnlineMeeting_JoinUrl__c); 
         
        DateTime dT =msTem.RW_Start_Time__c;
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        system.debug(' myDate____'+myDate); 
        String strtDate = string.valueOf(myDate);
        system.debug(' strtDate____'+strtDate); 
        String strtTime = msTem.RW_Start_Time__c.format('hh:mm:ss a'); 
        system.debug(' strtTime____'+strtTime); 
                                                    
         RW_Presales_Communication__c preComm = New RW_Presales_Communication__c();
         preComm.RW_Meeting_Mode_of_Communication__c  = 'Email';
                                                    
         If(sObjectType == 'Lead'){
             system.debug(' ____whatsApp line Lead');
             if(!test.isRunningTest())   {
                If(String.isNotBlank(System.Label.StopWhatsAppScheduleMSMeeting) && System.Label.StopWhatsAppScheduleMSMeeting == 'No'){
                    //Added by Vinay 29-10-2021
                    if(objLead.LeadSource != 'Channel Partner'){
                        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objLead.Name,objLead.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objLead.RW_Mobile_No__c,System.Label.Lead_Ms_Team_Confirm_HSM);
                        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objLead.Name,objLead.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objLead.RW_Mobile_No__c,'Lead Ms Team Confirm');  // Commented by Vinay 29-08-2025
                        if(System.label.Haptik_API_Version == 'New'){
                            SendWhatsAppMsg.methodToSendWhatsAppMsgNew(objLead.Name,objLead.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objLead.RDS_Country_Code__c,objLead.RW_Mobile_No__c,'Lead Ms Team Confirm');  // Added by Vinay 29-08-2025
                        }else{
                            SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objLead.Name,objLead.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objLead.RW_Mobile_No__c,'Lead Ms Team Confirm');
                        }
                        
         	    		preComm.RW_Meeting_Mode_of_Communication__c += ',WhatsApp';
                    }
                 //Commented by Vinay 29-10-2021
          		//SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objLead.Name,objLead.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objLead.RW_Mobile_No__c,System.Label.Lead_Ms_Team_Confirm_HSM);
         	    //preComm.RW_Meeting_Mode_of_Communication__c += ',WhatsApp';
                }
             }
         }
      
         If(sObjectType == 'Opportunity'){
          system.debug(' ____whatsApp line Opportunity');
             if(!test.isRunningTest())   {
                If(String.isNotBlank(System.Label.StopWhatsAppScheduleMSMeeting) && System.Label.StopWhatsAppScheduleMSMeeting == 'No'){
                    //Added by Vinay 29-10-2021
                    if(objOpp.LeadSource != 'Channel Partner'){
                        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objOpp.Name,objOpp.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objOpp.RW_Mobile_No__c,System.Label.Lead_Ms_Team_Confirm_HSM);
                        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objOpp.Name,objOpp.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objOpp.RW_Mobile_No__c,'Lead Ms Team Confirm'); // Commented by Vinay 29-08-2025
                        if(System.label.Haptik_API_Version == 'New'){ //Added by Vinay 10-10-2025
                            SendWhatsAppMsg.methodToSendWhatsAppMsgNew(null,objOpp.Name,objOpp.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,objOpp.Account.Country_Code__c,objOpp.RW_Mobile_No__c,'Lead Ms Team Confirm');
                        }else{
                            SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objOpp.Name,objOpp.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objOpp.RW_Mobile_No__c,'Lead Ms Team Confirm');
                        }
                		preComm.RW_Meeting_Mode_of_Communication__c += ',WhatsApp';
                    }
                 //Commented by Vinay 29-10-2021
          		//SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(objOpp.Name,objOpp.Project_Name__c,strtTime,strtDate,msTem.RW_OnlineMeeting_JoinUrl__c,null,null,null,null,objOpp.RW_Mobile_No__c,System.Label.Lead_Ms_Team_Confirm_HSM);
                //preComm.RW_Meeting_Mode_of_Communication__c += ',WhatsApp';
                }
             }
         }
                                                    
        preComm.RW_Meeting_Email_WhatsApp_Sent_Date__c = system.now();
                                                    
        If(sObjectType == 'Lead'){
        preComm.RW_Lead__c = objLead.Id;
        }
        If(sObjectType == 'Opportunity'){
        preComm.RW_Opportunity__c = objOpp.Id;
        }
        
        preComm.RW_MS_Teams__c = msTem.Id;                                             
                                                 
         
        insert preComm;
        System.debug('RW_Presales_Communication__c Record inserted______ ' +preComm);
                                                    
       return msTem;
  }
 
}