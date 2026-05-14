public class CreateWelcomeCallForSoReleasedBkgs {
    
    //Creates Welcome Call record, Welcome Call Task and Send Email alert
    public static void createWelcomeCall(List<Booking__c> bkgs){
        
        List<RW_Welcome_Call__c> listOfWelcomcalls = new List<RW_Welcome_Call__c>();
        List<String> bkgsToCreateTask = new List<String>();
        Set<String> bkgIds = new Set<String>();
        for(Booking__c bkg : bkgs){
            bkgIds.add(bkg.Id);
        }
        
        Map<String, RW_Welcome_Call__c> bookingWelcomeCallMap = new Map<String, RW_Welcome_Call__c>();
        for(RW_Welcome_Call__c wc : [SELECT Id, Booking_Id__c FROM RW_Welcome_Call__c WHERE Booking_Id__c =: bkgIds]){
            bookingWelcomeCallMap.put(wc.Booking_Id__c, wc);
        }
        
        for(Booking__c bkg : bkgs){
            if(bookingWelcomeCallMap.get(bkg.Id) == null){
                RW_Welcome_Call__c wc = new RW_Welcome_Call__c();
                wc.Booking_Id__c = bkg.Id;
                wc.RW_Booking__c = bkg.Id;
                wc.RW_Welcome_Call_Status__c = 'Due';
                listOfWelcomcalls.add(wc);
                bkgsToCreateTask.add(bkg.Id);
            }
        }
        
        
        if(listOfWelcomcalls.size()>0){
            system.debug(listOfWelcomcalls);
            upsert listOfWelcomcalls Booking_Id__c; 
        }
        
        if(bkgsToCreateTask.size() > 0){
            createWelcomeCallTask(bkgsToCreateTask);
        }
    }
    // public static void createWelcomeCall(List<Booking__c> bkgs){
    
    //     List<String> bkgsToCreateTask = new List<String>();
    //     Set<Id> oppIds = new Set<Id>();

    //     for(Booking__c bkg : bkgs){
    //         if(bkg.Opportunity__c != null){
    //             oppIds.add(bkg.Opportunity__c);
    //         }
    //     }

    //     if(oppIds.isEmpty()) return;

    //     /* GET RECORD TYPE : Greeting Call */
    //     Id greetingRTId = Schema.SObjectType.RW_Welcome_Call__c.getRecordTypeInfosByDeveloperName().get('Greeting_Call').getRecordTypeId();
    //     Id welcomeRTId = Schema.SObjectType.RW_Welcome_Call__c.getRecordTypeInfosByDeveloperName().get('Welcome_Call').getRecordTypeId();


    //     /* FETCH EXISTING GREETING CALL RECORDS FROM OPPORTUNITY */
    //     Map<Id, RW_Welcome_Call__c> oppWelcomeCallMap = new Map<Id, RW_Welcome_Call__c>();

    //     for(RW_Welcome_Call__c wc : [
    //         SELECT Id, Opportunity__c
    //         FROM RW_Welcome_Call__c
    //         WHERE Opportunity__c IN :oppIds
    //         AND RecordTypeId = :greetingRTId
    //     ]){
    //         oppWelcomeCallMap.put(wc.Opportunity__c, wc);
    //     }

    //     /* UPDATE EXISTING RECORDS */
    //     List<RW_Welcome_Call__c> listOfWelcomcalls = new List<RW_Welcome_Call__c>();

    //     for(Booking__c bkg : bkgs){
            
    //         RW_Welcome_Call__c wc = oppWelcomeCallMap.get(bkg.Opportunity__c);
            
    //         if(wc != null){
    //             wc.Booking_Id__c = bkg.Id;
    //             wc.RW_Booking__c = bkg.Id;
    //             wc.RW_Welcome_Call_Status__c = 'Due';
    //             wc.RecordTypeId = welcomeRTId; 

    //             listOfWelcomcalls.add(wc);
    //             bkgsToCreateTask.add(bkg.Id);
    //         }
    //     }

    //     /* UPDATE INSTEAD OF UPSERT */
    //     if(listOfWelcomcalls.size() > 0){
    //         update listOfWelcomcalls;
    //     }

    //     /* KEEP TASK + EMAIL SAME */
    //     if(bkgsToCreateTask.size() > 0){
    //         createWelcomeCallTask(bkgsToCreateTask);
    //     }
    // }

    
    //Creates Welcome Call Task and Send Email alert
    public static void createWelcomeCallTask (List<String> bkgIds) {
        
        Messaging.SingleEmailMessage[] lstMail =   new List<Messaging.SingleEmailMessage>();
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND Name = 'Welcome Call' LIMIT 1];
        
        List<Booking__c> bkgs = [SELECT Id, Name, Unit_No__r.Relationship_Manager__r.User__r.id, Unit_No__r.Relationship_Manager__r.User__c, 
                                 Unit_No__r.Relationship_Manager__r.User__r.Name, Wing__c, Flat_No__c, Primary_Applicant_Name__c, 
                                 Unit_No__r.Relationship_Manager__r.RM_Email__c, Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c, 
                                 Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c, Opportunity__r.SAP_Customer_Number__c, Project__c,
                                 Opportunity__r.SalesOrder_Number__c, Project__r.Sales_Order_Release_Intimation__c, Unit_No__r.Relationship_Manager__r.User__r.IsActive
                                 FROM Booking__c WHERE Id =: bkgIds];
        List<Task> taskList = new List<Task>();
        for(Booking__c bk : bkgs){
            
            Task tsk = new Task(); 
            
            tsk.Call_Status__c = 'Welcome Call';
            tsk.Communication_Type__c = 'Outbound Call';
            tsk.IsReminderSet = True;
            System.debug('tsk.OwnerId: ' + bk.Unit_No__r.Relationship_Manager__c);
            System.debug('tsk.OwnerId: ' + bk.Unit_No__r.Relationship_Manager__r.User__c);
            System.debug('tsk.OwnerId: ' + bk.Unit_No__r.Relationship_Manager__r.User__r.id);
            /*if(bk.Unit_No__r.Relationship_Manager__r.User__r.id != null){
                tsk.OwnerId = bk.Unit_No__r.Relationship_Manager__r.User__c;
            }*/
            if(bk.Unit_No__r.Relationship_Manager__r.User__c != null && bk.Unit_No__r.Relationship_Manager__r.User__r.IsActive){
                tsk.OwnerId = bk.Unit_No__r.Relationship_Manager__r.User__c;
            }else{
                tsk.OwnerId = System.label.System_Administrator_User_Id;
            }
            System.debug('tsk.OwnerId: ' + tsk.OwnerId);
            tsk.RecordTypeId = rt.Id;
            tsk.Status = 'Not Started';
            tsk.Subject = 'Welcome Call';
            tsk.Type = 'Call'; 
            tsk.Priority = 'High';
            tsk.Description = 'Booking Confirmed Please Initiate Welcome Call - '+ bk.Wing__c + '-' + bk.Flat_No__c + '-' + bk.Primary_Applicant_Name__c;
            tsk.WhatId = bk.Id;
            tsk.ActivityDate=Date.today().addDays(5);
            tsk.Task_Type__c = 'CRM Call';
            tsk.FullName__c = bk.Unit_No__r.Relationship_Manager__r.User__r.Name;
            tsk.Project__c = bk.Project__c;
            if(tsk.OwnerId != null){
                //Insert tsk;
                system.debug('tsk in Initiate==>'+tsk);
                
                //CustomNotificationController.taskAssignmentNotification(new List<Task>{tsk});
                taskList.add(tsk);
                
                string body = 'Dear RM, <br/><br/>';
                body += ' The following Booking has been Confirmed, Click the below booking to Initiate Welcome Call. <br/>';
                body += ' Booking Name: <a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Booking__c/' + bk.id+ '/view">' + bk.Name+ '</a>';
                body += '<br/><br/><br/>';
                body += 'Regards,<br/>';
                
                if(bk.Unit_No__c != null && bk.Unit_No__r.Relationship_Manager__c != null && bk.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                    Messaging.SingleEmailMessage rmMail = new Messaging.SingleEmailMessage();
                    rmMail.toaddresses = new string[]{bk.Unit_No__r.Relationship_Manager__r.RM_Email__c};
                    rmMail.subject = 'Booking Confirmed Please Initiate Welcome Call';
                    List<String> bccAddrs = new List<String>();
                    if(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c != null){
                        bccAddrs.add(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_1__c);
                    }
                    if(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c != null){
                        bccAddrs.add(bk.Unit_No__r.TowerName__r.Welcome_Call_CC_Email_2__c);
                    }
                    if(bccAddrs.size() > 0)
                    	rmMail.setCcAddresses(bccAddrs);
                    rmMail.sethtmlbody(body);
                    lstMail.add(rmMail);
                }
                
                //Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
                
                
                if(bk.Project__r.Sales_Order_Release_Intimation__c != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    string body1 = 'Dear Team, <br/><br/>';
                    body1 += 'The below mentioned Salesorder has been auto released in SAP. Request you to take further actions.<br/><br/>';
                    body1 += 'CRN - ' + bk.Opportunity__r.SAP_Customer_Number__c + '<br/><br/>';
                    body1 += 'Sales Order - ' + bk.Opportunity__r.SalesOrder_Number__c + '<br/><br/>';
                    List<String> toAddr;
                    toAddr = bk.Project__r.Sales_Order_Release_Intimation__c.split(',');
                    mail.toaddresses = toAddr;
                    mail.subject = 'Sales Order Released from SAP';
                    mail.sethtmlbody(body1);
                    //lstMail.add(mail);
                }
            }  
        }
        
        if(taskList.size() > 0){
            //insert taskList;
            Database.saveResult[] srList = Database.insert(taskList, false);
            CustomNotificationController.taskAssignmentNotification(taskList);
        }
        
        if(lstMail.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
            system.debug('Messaging ' + results[0]);
            if(results[0].success) {
                System.debug('The email was sent successfully.');
            }else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
    
}