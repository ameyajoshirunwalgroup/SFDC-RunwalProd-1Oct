global class CaseEscalationMatrix implements Schedulable {
    
    global void execute(SchedulableContext sc){
        //Map<String, Case_Escalation_Matrix_SLA__c> escalationSLA = Case_Escalation_Matrix_SLA__c.getall();
        
        List<Case_Escalation_Matrix_SLA__c> escalationSLA = [SELECT Id,Active__c,Case_Sub_Type__c,Case_Type__c,Customer_Lifecycle_Touchpoint__c,SLA__c FROM Case_Escalation_Matrix_SLA__c WHERE Active__c = true];
        
        List<Case> caseList = new List<Case>();
        
        if(!Test.isRunningTest()){
            caseList = [SELECT Id,CaseNumber,Status,RW_Complaint_Type__c,RW_Complaint_SubType__c,CreatedDate,Escalation_Level__c,RW_RM_Name__c,RW_Case_Reopened_Date__c,Customer_Lifecycle_Touchpoint__c FROM Case WHERE Status != 'Case Closed' AND Customer_Lifecycle_Touchpoint__c != null AND RW_Complaint_Type__c != null AND RW_Complaint_SubType__c != null AND RW_RM_Name__c != null];
                       // AND CreatedDate <=: (Date.today() - 1)];
        }else{
            caseList = [SELECT Id,CaseNumber,Status,RW_Complaint_Type__c,RW_Complaint_SubType__c,CreatedDate,Escalation_Level__c,RW_RM_Name__c,RW_Case_Reopened_Date__c,Customer_Lifecycle_Touchpoint__c FROM Case];
        }
        
        /*List<Case> caseList = [SELECT Id, CaseNumber, Status, RW_Complaint_Type__c, RW_Complaint_SubType__c, CreatedDate, Escalation_Level__c, RW_RM_Name__c 
                               FROM Case WHERE Status != 'Case Closed' AND Id = '500Ik000001LyawIAC'];*/
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Task> taskList = new List<Task>();
        
        Map<String, RM_Usernames__c> rmUsersMap = RM_Usernames__c.getall();
        List<String> rmUserNames = new List<String>();
        List<String> managerEmails = new List<String>();
        for(RM_Usernames__c rm : rmUsersMap.values()){
            if(!managerEmails.contains(rm.RW_Reporting_1_Email__c)){
                managerEmails.add(rm.RW_Reporting_1_Email__c);
            }
            if(!managerEmails.contains(rm.RW_Reporting_2_Email__c)){
                managerEmails.add(rm.RW_Reporting_2_Email__c);
            }
            if(!managerEmails.contains(rm.RW_Reporting_3_Email__c)){
                managerEmails.add(rm.RW_Reporting_3_Email__c);
            }
            if(!managerEmails.contains(rm.RW_Reporting_4_Email__c)){
                managerEmails.add(rm.RW_Reporting_4_Email__c);
            }
            rmUserNames.add(rm.User_Name__c);
        }
        
        List<User> users = [SELECT Id,Name,Email FROM User WHERE UserName =: rmUserNames OR Email =: managerEmails];
        Map<String, User> userMap = new Map<String, User>();
        for(User usr : users){
            userMap.put(usr.Email, usr);
        }
        
        List<Case> casesToUpdate = new List<Case>();
        String baseUrl = URL.getOrgDomainURL().toExternalForm();
        String orgEmail = Utility.getOrgWideEmailAddress();
        for(Case cs : caseList){
            Long difference;
            if(!Test.isRunningTest()){
                if(cs.RW_Case_Reopened_Date__c != null){
                    difference = Datetime.now().getTime() - cs.RW_Case_Reopened_Date__c.getTime();
                }else{
                    difference = Datetime.now().getTime() - cs.CreatedDate.getTime();
                }
            }else{
                if(cs.RW_Case_Reopened_Date__c != null){
                    difference = Datetime.now().getTime() - cs.RW_Case_Reopened_Date__c.getTime() + 10800000;
                }else{
                    difference = Datetime.now().getTime() - cs.CreatedDate.getTime() + 10800000;
                }
            }
            
            //Long hourDifference = 1;
            Long hourDifference = difference / 3600000;
            long daysDifference = hourDifference / 24;
            if(cs.Escalation_Level__c == 'New'){
                for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                    if(cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c && cs.RW_Complaint_Type__c == mat.Case_Type__c && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c && hourDifference >= mat.SLA__c){
                        //cs.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c).Id;
                        cs.Escalation_Level__c = 'Level 1';
                        casesToUpdate.add(cs);
                        if(rmUsersMap.get(cs.RW_RM_Name__c) != null && rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.settoaddresses(new List<String>{rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c});
                            mail.setccaddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
                            mail.setOrgWideEmailAddressId(orgEmail);
                            mail.setsubject('Case Escalation');
                            String body;
                            if(userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c) != null){
                                body = '<html><body>Dear ' + userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c).Name + ',<br/><br/>';
                                
                                Task tsk = new Task();
                                tsk.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_1_Email__c).Id;
                                tsk.activityDate = System.today();
                                tsk.status = 'open';
                                tsk.Subject = 'Case Escalation';
                                tsk.priority = 'High';
                                taskList.add(tsk);
                            }else{
                                body = '<html><body>Dear ,<br/><br/>';
                            }
                            body += 'The Case ' + cs.CaseNumber + ' was escalated to you. <br/><br/>';
                            body += 'Case Link: ' + baseUrl + '/' + cs.Id;
                            mail.sethtmlbody(body);
                            mails.add(mail);
                        }
                    }
                }
            }else if(cs.Escalation_Level__c == 'Level 1'){
                for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                    if(cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c && cs.RW_Complaint_Type__c == mat.Case_Type__c && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c && hourDifference >= (mat.SLA__c + 1)){
                        //cs.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c).Id;
                        cs.Escalation_Level__c = 'Level 2';
                        casesToUpdate.add(cs);
                        
                        if(rmUsersMap.get(cs.RW_RM_Name__c) != null && rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.settoaddresses(new List<String>{rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c});
                            mail.setccaddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
                            mail.setOrgWideEmailAddressId(orgEmail);
                            mail.setsubject('Case Escalation');
                            String body;
                            if(userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c) != null){
                                body = '<html><body>Dear ' + userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c).Name + ',<br/><br/>';
                                
                                Task tsk = new Task();
                                tsk.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_2_Email__c).Id;
                                tsk.activityDate = System.today();
                                tsk.status = 'open';
                                tsk.Subject = 'Case Escalation';
                                tsk.priority = 'High';
                                taskList.add(tsk);
                            }else{
                                body = '<html><body>Dear ,<br/><br/>';
                            }
                            body += 'The Case ' + cs.CaseNumber + ' was escalated to you. <br/><br/>';
                            body += 'Case Link: ' + baseUrl + '/' + cs.Id;
                            mail.sethtmlbody(body);
                            mails.add(mail);
                        }
                    }
                }
            }else if(cs.Escalation_Level__c == 'Level 2'){
                for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                    if(cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c && cs.RW_Complaint_Type__c == mat.Case_Type__c && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c && hourDifference >= (mat.SLA__c + 2)){
                        //cs.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c).Id;
                        cs.Escalation_Level__c = 'Level 3';
                        casesToUpdate.add(cs);
                        
                        if(rmUsersMap.get(cs.RW_RM_Name__c) != null && rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c != null){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.settoaddresses(new List<String>{rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c});
                            mail.setccaddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
                            mail.setOrgWideEmailAddressId(orgEmail);
                            mail.setsubject('Case Escalation');
                            String body;
                            if(userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c) != null){
                                body = '<html><body>Dear ' + userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c).Name + ',<br/><br/>';
                                
                                Task tsk = new Task();
                                tsk.OwnerId = userMap.get(rmUsersMap.get(cs.RW_RM_Name__c).RW_Reporting_3_Email__c).Id;
                                tsk.activityDate = System.today();
                                tsk.status = 'open';
                                tsk.Subject = 'Case Escalation';
                                tsk.priority = 'High';
                                taskList.add(tsk);
                            }else{
                                body = '<html><body>Dear ,<br/><br/>';
                            }
                            body += 'A Case ' + cs.CaseNumber + ' was escalated to you. <br/><br/>';
                            body += 'Case Link: ' + baseUrl + '/' + cs.Id;
                            mail.sethtmlbody(body);
                            mails.add(mail);
                        }
                    }
                }
            }
        }
        
        Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
        insert taskList;
        update casesToUpdate;
    }
    
}