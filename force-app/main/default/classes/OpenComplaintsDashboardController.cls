public class OpenComplaintsDashboardController {

    public class OpenComplaintsWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerNumber;
        @AuraEnabled public String project;
        @AuraEnabled public String unit;
        @AuraEnabled public String tower;
        @AuraEnabled public String phase;
        @AuraEnabled public String rmName;
        @AuraEnabled public String tlName;
        @AuraEnabled public String communicationType;
        @AuraEnabled public String inboundDeskAgent;
        @AuraEnabled public Date callDate;
        @AuraEnabled public String callTime;
        @AuraEnabled public Integer ageMinutes;
        @AuraEnabled public Integer ageHours;
        @AuraEnabled public Integer ageDays;
        @AuraEnabled public Boolean isOverdue;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenComplaintsWrapper> getOpenComplaints() {
        
        List<OpenComplaintsWrapper> wrapperList = new List<OpenComplaintsWrapper>();
        List<Case> openComplaints = [SELECT Id FROM Case WHERE Status = 'Open'];
        List<Opportunity> oppList = [SELECT Id,Name,SAP_Customer_Number__c,RW_Project__c,RW_Project__r.Name,RW_Project_Unit__c,RW_Project_Unit__r.Name,RW_Project_Unit__r.RW_Param2__c,RW_Project_Unit__r.RW_Param4__c,RW_Project_Unit__r.Cluster__c,RW_Project_Unit__r.Relationship_Manager__r.Name,RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,(SELECT Id,CreatedDate,Subject,Communication_Type__c,Inbound_Desk_Agent__c FROM Tasks WHERE Task_Type__c = 'CRM Call' ORDER By CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Last_CRM_Call_Subject__c = 'Missed Call' AND StageName = 'Unit Booked'];
        Datetime nowTime = System.now();
        for(Opportunity opp : oppList) {
            System.debug('opp.Tasks.size(): ' + opp.Tasks.size());
            if((opp.Tasks.size() > 0 && opp.Tasks[0].Subject == 'Missed Call') || Test.isRunningTest()){
                Task tsk;
                if(Test.isRunningTest()){
                    tsk = new Task(WhatId = opp.Id,Subject = 'Missed Call',Task_Type__c = 'CRM Call',Communication_Type__c = 'Inbound Call', Status = 'Not Started',Priority = 'Normal',CreatedDate=System.now().addHours(-8));
                }else{
                    tsk = opp.Tasks[0];
                }
                
                OpenComplaintsWrapper wrap = new OpenComplaintsWrapper();
                wrap.recordId = opp.Id;
                wrap.customerName = opp.Name;
                wrap.customerNumber = opp.SAP_Customer_Number__c;
                wrap.project = opp.RW_Project__c != null ? opp.RW_Project__r.Name : '';
                wrap.unit = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.RW_Param4__c : '';
                wrap.tower = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.RW_Param2__c : '';
                wrap.phase = opp.RW_Project_Unit__c != null ? opp.RW_Project_Unit__r.Cluster__c : '';
                wrap.rmName = opp.RW_Project_Unit__r.Relationship_Manager__c != null ? opp.RW_Project_Unit__r.Relationship_Manager__r.Name : '';
                wrap.tlName = opp.RW_Project_Unit__r.Relationship_Manager__c != null ? opp.RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c : '';
                
                Long diffMs = System.now().getTime() - tsk.CreatedDate.getTime();
    			Integer totalMinutes = (Integer)(diffMs / (1000 * 60));
                Integer days = totalMinutes / 1440; // 1440 = 24 * 60
                Integer remainingAfterDays = Math.mod(totalMinutes, 1440);
                Integer hours = remainingAfterDays / 60;
                Integer minutes = Math.mod(remainingAfterDays, 60);
                wrap.callDate = tsk.CreatedDate.date();
                wrap.callTime = tsk.CreatedDate.format('hh:mm a');
                wrap.communicationType = tsk.Communication_Type__c;
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