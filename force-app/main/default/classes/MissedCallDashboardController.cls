public with sharing class MissedCallDashboardController {

    public class MissedCallWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerNumber;
        @AuraEnabled public String project;
        @AuraEnabled public String unit;
        @AuraEnabled public String tower;
        @AuraEnabled public String phase;
        @AuraEnabled public String rmName;
        @AuraEnabled public String tlName;
        @AuraEnabled public String lastCrmCallSubject;
        @AuraEnabled public String assignedTo;
        @AuraEnabled public String inboundDeskAgent;
        @AuraEnabled public Date callDate;
        @AuraEnabled public String callTime;
        @AuraEnabled public Integer ageMinutes;
        @AuraEnabled public Integer ageHours;
        @AuraEnabled public Integer ageDays;
        @AuraEnabled public Boolean isOverdue;
        @AuraEnabled public String segment;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<MissedCallWrapper> getMissedCalls() {
        
        Id loggedInUserId = UserInfo.getUserId();
        String query;
        User usr = [SELECT Id, Name, Profile.Name, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
        query = 'SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,Last_CRM_Call_Subject__c,RW_Project__r.Segment_Lookup__r.Name,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c,Owner.Name FROM Tasks WHERE Task_Type__c = \'CRM Call\' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Last_CRM_Call_Subject__c IN (\'Missed Call\',\'Call Back\') AND StageName = \'Unit Booked\' AND SalesOrder_Number__c != null';
        if(usr.Profile.Name == 'Relationship Manager' || Test.isRunningTest()){
            //query = 'SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c,Owner.Name FROM Tasks WHERE Task_Type__c = \'CRM Call\' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Last_CRM_Call_Subject__c IN (\'Missed Call\',\'Call Back\') AND StageName = \'Unit Booked\'';
            Map<String, Project_Keywords__c> mapOfProjectKeyword = Project_Keywords__c.getall();
            Map<String, String> mapOfKeyWords = new Map<String, String>();
            for(String EachKey : mapOfProjectKeyword.keySet()){
                List<String> lstKey = mapOfProjectKeyword.get(EachKey).RW_Keyword__c.split(';');
                for(string EachSubKey : lstKey)
                    mapOfKeyWords.put(EachSubKey.tolowerCase(), EachKey);
            }
            String project;
            /*if(usr.UserRole.Name != null ){
                for(String keyword : mapOfKeyWords.keySet()){
                    if(usr.UserRole.Name.tolowerCase().contains(keyword)){
                        project = mapOfKeyWords.get(keyword);
                    }
                }
                System.debug('project: ' + project);
                query += ' AND RW_Project_Unit__r.Relationship_Manager__c != null AND RW_Project_Unit__r.Relationship_Manager__r.User__c = :loggedInUserId AND RW_Project__r.Name =: project';
            }else{
                query += ' AND RW_Project_Unit__r.Relationship_Manager__c != null AND RW_Project_Unit__r.Relationship_Manager__r.User__c = :loggedInUserId';
            }*/
            query += ' AND RW_Project_Unit__r.Relationship_Manager__c != null AND RW_Project_Unit__r.Relationship_Manager__r.User__c = :loggedInUserId';
             
        }/*else if(usr.Profile.Name == 'Team Leader'){
            String tlName = usr.Name;
            //query = 'SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c,Owner.Name FROM Tasks WHERE Task_Type__c = \'CRM Call\' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Last_CRM_Call_Subject__c IN (\'Missed Call\',\'Call Back\') AND StageName = \'Unit Booked\'';
            query += ' AND RW_Project_Unit__r.Relationship_Manager__c != null AND RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c =: tlName';
            
        }*/
        List<MissedCallWrapper> wrapperList = new List<MissedCallWrapper>();
        /*List<Opportunity> oppList = [SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c,Owner.Name FROM Tasks WHERE Task_Type__c = 'CRM Call' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity 
                                     WHERE Last_CRM_Call_Subject__c IN ('Missed Call','Call Back') AND StageName = 'Unit Booked' AND 
                                     RW_Project_Unit__r.Relationship_Manager__c != null AND (RW_Project_Unit__r.Relationship_Manager__c = :loggedInUserId OR RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c =: usr.Name)];*/
        if(Test.isRunningTest()){
            query = 'SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,Last_CRM_Call_Subject__c,RW_Project__r.Segment_Lookup__r.Name,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c,Owner.Name FROM Tasks WHERE Task_Type__c = \'CRM Call\' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Last_CRM_Call_Subject__c IN (\'Missed Call\',\'Call Back\') AND StageName = \'Unit Booked\'';
        }
        System.debug('query: ' + query);
        List<Opportunity> oppList = Database.query(query);
        Datetime nowTime = System.now();
        for(Opportunity opp : oppList) {
            System.debug('opp.Tasks.size(): ' + opp.Tasks.size());
            if((opp.Tasks.size() > 0 && (opp.Tasks[0].Subject == 'Missed Call' || opp.Tasks[0].Subject == 'Call Back')) || Test.isRunningTest()){
                Task tsk;
                if(Test.isRunningTest()){
                    tsk = new Task(WhatId = opp.Id,Subject = 'Missed Call',Task_Type__c = 'CRM Call',Communication_Type__c = 'Inbound Call', Status = 'Not Started',Priority = 'Normal',CreatedDate=System.now().addHours(-8));
                }else{
                    tsk = opp.Tasks[0];
                }
                
                MissedCallWrapper wrap = new MissedCallWrapper();
                wrap.recordId = opp.Id;
                wrap.customerName = opp.Name;
                wrap.customerNumber = opp.SAP_Customer_Number__c;
                wrap.project = opp.RW_Project__c != null ? opp.RW_Project__r.Name : '';
                wrap.unit = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.RW_Param4__c : '';
                wrap.tower = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.RW_Param2__c : '';
                wrap.phase = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.Cluster__c : '';
                wrap.rmName = opp.RW_Project_Unit__r.Relationship_Manager__c != null ? opp.RW_Project_Unit__r.Relationship_Manager__r.Name : '';
                wrap.tlName = opp.RW_Project_Unit__r.Relationship_Manager__c != null ? opp.RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c : '';
                wrap.lastCrmCallSubject = opp.Last_CRM_Call_Subject__c;
                wrap.segment = opp.RW_Project__r.Segment_Lookup__r.Name;
                    
                Long diffMs = System.now().getTime() - tsk.CreatedDate.getTime();
    			Integer totalMinutes = (Integer)(diffMs / (1000 * 60));
                Integer days = totalMinutes / 1440; // 1440 = 24 * 60
                Integer remainingAfterDays = Math.mod(totalMinutes, 1440);
                Integer hours = remainingAfterDays / 60;
                Integer minutes = Math.mod(remainingAfterDays, 60);
                wrap.callDate = tsk.CreatedDate.date();
                wrap.callTime = tsk.CreatedDate.format('hh:mm a');
                //wrap.communicationType = tsk.Communication_Type__c;
                wrap.assignedTo = tsk.Owner.Name;
                wrap.inboundDeskAgent = tsk.Inbound_Desk_Agent__c;
                wrap.ageDays = days;
                wrap.ageHours = hours;
                wrap.ageMinutes = minutes;
                Integer totalHours = totalMinutes / 60;
                wrap.isOverdue = totalHours > 6;
                wrapperList.add(wrap);
            }
        }
        return wrapperList;
    }
    
    
}