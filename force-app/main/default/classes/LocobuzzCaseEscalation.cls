global class LocobuzzCaseEscalation implements Database.Batchable <sObject>, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Department__c, RW_Project__c, Tower__c, RW_Project_Text__c, Escalation_Level__c, CaseNumber, CreatedDate, OwnerId FROM Case WHERE Status != 'Case Closed' AND Status != 'Closed' AND locobuzz__Locobuzz_ID__c != null AND Department__c != null AND RW_Project_Text__c != null AND Escalation_Level__c != 'Level 3']);
    }
    
    global void execute(Database.BatchableContext bc, list <Case> caseList){
        if(caseList.size() > 0){
            Map<String, Locobuzz_Project_Spocs__c> spocs = Locobuzz_Project_Spocs__c.getall();
            
            Map<String, String> userMap = LocobuzzCaseAssignment.spocUsers(spocs);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String baseUrl = URL.getOrgDomainURL().toExternalForm();
            String orgEmail = Utility.getOrgWideEmailAddress();
            for(Case cs : caseList){
                String escalationEmail;
                for(Locobuzz_Project_Spocs__c spoc : spocs.values()){
                    if(spoc.Department__c == 'Projects' && spoc.Project_Name__c == 'Runwal Gardens'){
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c && spoc.Tower__c == cs.Tower__c){
                            escalationEmail = updateEscalation(cs, userMap, spoc);
                        }
                    }else{
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c){
                            escalationEmail = updateEscalation(cs, userMap, spoc);
                        }
                    }
                }
                if(escalationEmail != null){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.settoaddresses(new List<String>{escalationEmail});
                    mail.setOrgWideEmailAddressId(orgEmail);
                    mail.setsubject('Case Escalation');
                    String body;
                    body = '<html><body>Dear ,<br/><br/>';
                    body += 'The Case ' + cs.CaseNumber + ' was escalated to you. <br/><br/>';
                    body += 'Case Link: ' + baseUrl + '/' + cs.Id;
                    mail.sethtmlbody(body);
                    mails.add(mail);
                }
            }
            update caseList;
            Database.update(caseList, false);
            if(mails.size() > 0){
                Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    global void execute(SchedulableContext dc) {
        LocobuzzCaseEscalation b = new LocobuzzCaseEscalation();
        Database.executeBatch(b, 100);
    }

    /*global void execute(SchedulableContext sc){
        List<Case> caseList = [SELECT Id, Department__c, RW_Project__c, Tower__c, RW_Project_Text__c, Escalation_Level__c, CaseNumber, CreatedDate, OwnerId FROM Case WHERE Status != 'Case Closed' AND locobuzz__Locobuzz_ID__c != null];
        
        if(caseList.size() > 0){
            Map<String, Locobuzz_Project_Spocs__c> spocs = Locobuzz_Project_Spocs__c.getall();
            
            Map<String, String> userMap = LocobuzzCaseAssignment.spocUsers(spocs);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String baseUrl = URL.getOrgDomainURL().toExternalForm();
            String orgEmail = Utility.getOrgWideEmailAddress();
            for(Case cs : caseList){
                String escalationEmail;
                for(Locobuzz_Project_Spocs__c spoc : spocs.values()){
                    if(spoc.Department__c == 'Projects' && spoc.Project_Name__c == 'Runwal Gardens'){
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c && spoc.Tower__c == cs.Tower__c){
                            escalationEmail = updateEscalation(cs, userMap, spoc);
                        }
                    }else{
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c){
                            escalationEmail = updateEscalation(cs, userMap, spoc);
                        }
                    }
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.settoaddresses(new List<String>{escalationEmail});
                mail.setOrgWideEmailAddressId(orgEmail);
                mail.setsubject('Case Escalation');
                String body;
                body = '<html><body>Dear ,<br/><br/>';
                body += 'The Case ' + cs.CaseNumber + ' was escalated to you. <br/><br/>';
                body += 'Case Link: ' + baseUrl + '/' + cs.Id;
                mail.sethtmlbody(body);
                mails.add(mail);
                
                System.debug('Owner: ' + cs.OwnerId);
            }
            update caseList;
            Database.update(caseList, false);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
        	System.debug('result: ' + result);
        }
    }*/
    
    public static String updateEscalation(Case cs, Map<String, String> userMap, Locobuzz_Project_Spocs__c spoc){
        String escalationEmail;
        Datetime dt;
        if(!Test.isRunningTest()){
             dt = system.now();
        }else{
            dt = system.now().addHours(80);
        }
        if(cs.Escalation_Level__c == 'New' && dt >= cs.CreatedDate.addHours(24)){
            if(userMap.get(spoc.L2_Spoc_Email__c) != null)
                cs.OwnerId = userMap.get(spoc.L2_Spoc_Email__c);
            if(spoc.L2_Spoc_Email__c != null)
                escalationEmail = spoc.L2_Spoc_Email__c;
            cs.Escalation_Level__c = 'Level 1';
        }else if(cs.Escalation_Level__c == 'Level 1' && dt >= cs.CreatedDate.addHours(48)){
            if(userMap.get(spoc.L3_Spoc_Email__c) != null)
                cs.OwnerId = userMap.get(spoc.L3_Spoc_Email__c);
            if(spoc.L3_Spoc_Email__c != null)
                escalationEmail = spoc.L3_Spoc_Email__c;
            cs.Escalation_Level__c = 'Level 2';
        }else if(cs.Escalation_Level__c == 'Level 2' && dt >= cs.CreatedDate.addHours(72)){
            if(userMap.get(spoc.L4_Spoc_Email__c) != null)
                cs.OwnerId = userMap.get(spoc.L4_Spoc_Email__c);
            if(spoc.L4_Spoc_Email__c != null)
                escalationEmail = spoc.L4_Spoc_Email__c;
            cs.Escalation_Level__c = 'Level 3';
        }
        return escalationEmail;
    }
}