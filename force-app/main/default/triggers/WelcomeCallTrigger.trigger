trigger WelcomeCallTrigger on RW_Welcome_Call__c (before update,after update) {
   // ReinitiateWelcomeCall
    if(trigger.isbefore && trigger.isupdate){
            for(RW_Welcome_Call__c welcall: trigger.new){
                if(welcall.RW_Reinitiate_Welcome_Call__c){
                    welcall.RW_Welcome_Call_Status__c = 'Reinitiate';
                    welcall.RW_Welcome_Call_Reinitiate_date__c = System.today();
                }
            }
    }
    
    if(trigger.isAfter && trigger.isupdate){
        Messaging.SingleEmailMessage[] lstMail =   new List<Messaging.SingleEmailMessage>(); 
       
      List<Task> taskListToInsert = new List<Task>();
        
       //Getting task recordId
	 RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND Name = 'Welcome Call' LIMIT 1];
	 Map<Id, RW_Welcome_Call__c> welcomMap = new Map<Id, RW_Welcome_Call__c>();
     Map<Id, Id> bkgidMap = new Map<Id, Id>();
        List<RW_Welcome_Call__c> calls = new List<RW_Welcome_Call__c>();
        for( RW_Welcome_Call__c WC: [select id,RW_Booking__r.Id,RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c,RW_Welcome_Call_Status__c,
                                     RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c,RW_Booking__r.Name,
                                     RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.id,RW_Booking__r.Sales_Manager__c,
                                     RW_Booking__r.Wing__c,RW_Booking__r.Flat_No__c,RW_Booking__r.Primary_Applicant_Name__c,
                                     RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.Name,RW_Booking__r.Project__c,
                                     RW_Booking__r.RW_Country_Phone_Code__c, RW_Applicant1_Mobile_No__c, RW_Booking__r.Opportunity__c, RW_Booking__r.Opportunity__r.RW_Mobile_No__c
                                     from RW_Welcome_Call__c where Id In:Trigger.new]){
            welcomMap.put(WC.Id, WC);
            system.debug('newMapWelcall.RW_Booking__r.Name==>'+WC.RW_Booking__c);
             if(WC.RW_Welcome_Call_Status__c == 'Accept'){
                 bkgidMap.put(WC.Id, WC.RW_Booking__c);
             }
             if(WC.RW_Welcome_Call_Status__c == 'Accept' && Trigger.OldMap.get(WC.Id).RW_Welcome_Call_Status__c != 'Accept'){
                 calls.add(WC);                            
             }
                                         
            if(WC.RW_Welcome_Call_Status__c == 'Reinitiate'){
                
                //Creating new record
                Task tsk = new Task(); 

                tsk.Call_Status__c = 'Welcome Call';
                tsk.Communication_Type__c = 'Outbound Call';
                tsk.IsReminderSet = True;
                tsk.OwnerId = WC.RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.id;
                tsk.RecordTypeId = rt.Id;
                tsk.Status = 'Not Started';
                tsk.Subject = 'Welcome Call';
                tsk.Type = 'Call'; 
                tsk.Priority = 'High'; 
                //'Welcome Call DiscrepancyList is resloved, Please Reinitiate the Welcome Call - '+ WC.RW_Booking__r.Name;
                tsk.Description = 'Welcome Call DiscrepancyList is resloved, Please Reinitiate the Welcome Call - '+ '-' + WC.RW_Booking__r.Flat_No__c +''+WC.RW_Booking__r.Primary_Applicant_Name__c;
                tsk.WhatId = WC.RW_Booking__r.Id;
                tsk.ActivityDate = Date.today().addDays(3);
                tsk.Task_Type__c = 'CRM Call';
                tsk.FullName__c = WC.RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__r.Name;
                tsk.Project__c = WC.RW_Booking__r.Project__c;
                taskListToInsert.add(tsk);
                
           //Mail Body     
          string body = 'Dear RM, <br/><br/>';

          body += ' Welcome Call DiscrepancyList is resloved, Click the below booking to Reinitiate the Welcome Call. <br/>';
          
          body += ' Booking Name: <a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Booking__c/' + WC.RW_Booking__r.Id+ '/view">' + WC.RW_Booking__r.Name+ '</a>';
          //body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '<br><br>';
          body += '<br/><br/><br/>';
          
          body += 'Thanks,<br/>';
         
          body += ' Runwal Homes.';
         
            Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
            objMail.toaddresses = new string[]{WC.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c};
            objMail.subject = 'Welcome Call DiscrepancyList is resloved, Please Reinitiate the Welcome Call';
            objMail.sethtmlbody(body);
            lstMail.add(objMail);
           
            }
          
        }
         if(lstMail.size()> 0){            
         Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
            system.debug('Messaging ' + results[0]);
               
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
         }
        //Updating the task status as 'Completed' for SM
            
            List<Task> taskUpdate = new List<Task>();
        
        if(taskListToInsert.size()> 0){
            Insert taskListToInsert;
            system.debug('taskListToInsert RM with DisList ==>'+taskListToInsert);
            List<Task> updateTaskListToCompleted = [Select Id,WhatId,Call_Status__c,Subject,OwnerId,status,RecordTypeId from Task
                                          where WhatId IN:Trigger.new];
            System.debug('#### updateTaskListToCompleted '+updateTaskListToCompleted);
            
            
            for(Task tsk: updateTaskListToCompleted){
                 system.debug('tsk SM Reinitiate==>'+tsk);
            
                 RW_Welcome_Call__c welcall = welcomMap.get(tsk.WhatId);
                
               if(welcall.RW_Welcome_Call_Status__c == 'Reinitiate'){
                    system.debug('welcall.RW_Welcome_Call_Status__c SM==>'+welcall.RW_Welcome_Call_Status__c);
                   
                 if(tsk.Call_Status__c == 'Welcome Call' && tsk.Subject == 'Welcome Call' && tsk.WhatId == welcall.id 
                   && tsk.OwnerId == welcall.RW_Booking__r.Sales_Manager__c && tsk.RecordTypeId == rt.Id){
                       tsk.status = 'Completed';
                       taskUpdate.add(tsk);
                   }
                }
                
            }
            
        }
        
        List<Task> updateTaskListToCompletedbkg = [Select Id,WhatId,Call_Status__c,Subject,OwnerId,status,RecordTypeId from Task
                                          where WhatId IN:bkgidMap.values()];
        
        List<Booking__c> bookingsList = [Select Id,Unit_No__r.Relationship_Manager__r.User__c,(select Id,RW_Welcome_Call_Status__c from Welcome_Calls__r) 
                                          from Booking__c where Id IN:bkgidMap.values()];
        Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>();
        for(Booking__c bk: bookingsList){
            bookingMap.put(bk.Id, bk);
        }
        for(Task tsk: updateTaskListToCompletedbkg){
             system.debug('tsk Accept==>'+tsk);
            
                 Booking__c bkng = bookingMap.get(tsk.WhatId);
                if(bkng.Welcome_Calls__r[0].RW_Welcome_Call_Status__c == 'Accept'){
                     system.debug('welcall.RW_Welcome_Call_Status__c RM==>'+bkng.Welcome_Calls__r[0].RW_Welcome_Call_Status__c);
                    system.debug('tsk.WhatId '+tsk.WhatId);
                    system.debug('welcall.RW_Booking__r.Id '+bkng.Id);
                    system.debug('tsk.OwnerId '+tsk.OwnerId);
                    system.debug('welcall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.User__c '+bkng.Unit_No__r.Relationship_Manager__r.User__c);
                    system.debug('tsk.RecordTypeId '+tsk.RecordTypeId);
                    system.debug('tsk.Call_Status__c '+tsk.Call_Status__c);
                    system.debug('tsk.Subject '+tsk.Subject);
                
                    if(tsk.Call_Status__c == 'Welcome Call' && tsk.Subject == 'Welcome Call' && tsk.WhatId == bkng.Id 
                     && tsk.OwnerId == bkng.Unit_No__r.Relationship_Manager__r.User__c && tsk.RecordTypeId == rt.Id){
                       tsk.status = 'Completed';
                        system.debug('tsk.status '+tsk.status);
                       taskUpdate.add(tsk);
                   }
                }
            }
        
        
        if(taskUpdate.size()> 0){
                update taskUpdate;
            }
        
        /*for(RW_Welcome_Call__c call : [SELECT Id, RW_Welcome_Call_Status__c, RW_Booking__r.Primary_Applicant_Name__c, RW_Booking__r.RW_Country_Phone_Code__c, RW_Applicant1_Mobile_No__c from RW_Welcome_Call__c WHERE Id IN : Trigger.new]){
            System.debug('call.RW_Booking__r.Primary_Applicant_Name__c: ' + call.RW_Booking__r.Primary_Applicant_Name__c);
            if(call.RW_Welcome_Call_Status__c == 'Accept' && Trigger.OldMap.get(call.Id).RW_Welcome_Call_Status__c != 'Accept'){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(call.RW_Booking__r.Primary_Applicant_Name__c, null, null, null, null, null, null, null, null, call.RW_Booking__r.RW_Country_Phone_Code__c, call.RW_Applicant1_Mobile_No__c, 'welcome_call');
            }
        }*/
        for(RW_Welcome_Call__c call : calls){
            if(!Test.isRunningTest()){
                //SendWhatsAppMsg.methodToSendWhatsAppMsg(call.RW_Booking__r.Opportunity__c,call.RW_Booking__r.Primary_Applicant_Name__c, null, null, null, null, null, null, null, call.RW_Booking__r.RW_Country_Phone_Code__c, call.RW_Applicant1_Mobile_No__c, System.label.Welcome_call_WhatsApp);
                SendWhatsAppMsg.methodToSendWhatsAppMsg(call.RW_Booking__r.Opportunity__c,call.RW_Booking__r.Primary_Applicant_Name__c, null, null, null, null, null, null, null, call.RW_Booking__r.RW_Country_Phone_Code__c, call.RW_Applicant1_Mobile_No__c, 'welcome_call_ov');
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,call.RW_Booking__r.Primary_Applicant_Name__c,System.label.Booking_to_Registration_Link,System.label.Home_loan_brochure_Link,System.label.TDS_Tutorial_Link,null,null,null,null,call.RW_Booking__r.RW_Country_Phone_Code__c, call.RW_Booking__r.Opportunity__r.RW_Mobile_No__c,'Welcome Call Accepted'); // Added by coServe 09-07-2024
            }
            
        }
     
    }
    
  }