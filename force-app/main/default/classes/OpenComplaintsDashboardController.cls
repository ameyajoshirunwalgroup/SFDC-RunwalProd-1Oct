public with sharing class OpenComplaintsDashboardController {

    public class OpenComplaintsWrapper {
        @AuraEnabled public Id recordId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String customerName;
        @AuraEnabled public String customerNumber;
        @AuraEnabled public String project;
        @AuraEnabled public String unit;
        @AuraEnabled public String tower;
        @AuraEnabled public String phase;
        @AuraEnabled public String rmName;
        @AuraEnabled public String tlName;
        @AuraEnabled public String caseType;
        @AuraEnabled public Date caseOpenDate;
        @AuraEnabled public String caseOpenTime;
        @AuraEnabled public Integer ageMinutesCaseOpen;
        @AuraEnabled public Integer ageHoursCaseOpen;
        @AuraEnabled public Integer ageDaysCaseOpen;
        @AuraEnabled public Boolean isOverdueCaseOpen;
        @AuraEnabled public Date caseReopenDate;
        @AuraEnabled public String caseReopenTime;
        @AuraEnabled public Integer ageMinutesCaseReopen;
        @AuraEnabled public Integer ageHoursCaseReopen;
        @AuraEnabled public Integer ageDaysCaseReopen;
        @AuraEnabled public Boolean isOverdueCaseReopen;
        @AuraEnabled public Boolean isOverdue;
        @AuraEnabled public String segment;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenComplaintsWrapper> getOpenComplaints(Integer selectedYear, Integer selectedMonth, Date startDate, Date endDate) {
        
        Id loggedInUserId = UserInfo.getUserId();
        User usr = [SELECT Id,Name,ManagerId,Manager.Name,Profile.Name,UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
        List<OpenComplaintsWrapper> wrapperList = new List<OpenComplaintsWrapper>();
        String dateFilter = '';
        if(startDate != null && endDate != null){
            DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0,0,0,0));
    		DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23,59,59,999));
            dateFilter = ' AND (CreatedDate >= :startDateTime AND CreatedDate <= :endDateTime)';
        }
        else if(selectedYear != null && selectedMonth != null){
            dateFilter = ' AND (CALENDAR_YEAR(CreatedDate) = :selectedYear AND CALENDAR_MONTH(CreatedDate) = :selectedMonth)';
        }
        else if(selectedYear != null){
            dateFilter = ' AND (CALENDAR_YEAR(CreatedDate) = :selectedYear)';
        }
        String query = 'SELECT Id,CaseNumber,Status,CreatedDate,RW_RM_Name__c,RW_Case_Reopened_Date__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.RW_Project__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project_Unit__c,Opportunity__r.RW_Project_Unit__r.Name,Opportunity__r.RW_Project_Unit__r.RW_Param2__c,Opportunity__r.RW_Project_Unit__r.RW_Param4__c,Opportunity__r.RW_Project_Unit__r.Cluster__c,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.Name,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c,Opportunity__r.Booking__r.RW_Key_handover_date__c,Opportunity__r.RW_Project__r.Segment_Lookup__r.Name FROM Case WHERE Status IN (\'Open\',\'Reopened\') AND Opportunity__c != null AND Opportunity__r.Booking__c != null AND Opportunity__r.Booking__r.RW_Key_handover_date__c != null AND RecordType.Name NOT IN (\'Channel Partner Portal\',\'IT\',\'Visit Feedback\')';
        query += dateFilter;
        /*if(usr.Profile.Name == 'Relationship Manager'){
            String rmName = usr.Name;
            Map<String, Project_Keywords__c> mapOfProjectKeyword = Project_Keywords__c.getall();
            Map<String, String> mapOfKeyWords = new Map<String, String>();
            for(String EachKey : mapOfProjectKeyword.keySet()){
                List<String> lstKey = mapOfProjectKeyword.get(EachKey).RW_Keyword__c.split(';');
                for(string EachSubKey : lstKey)
                    mapOfKeyWords.put(EachSubKey.tolowerCase(), EachKey);
            }
            String project;
            if(usr.UserRole.Name != null ){
                for(String keyword : mapOfKeyWords.keySet()){
                    if(usr.UserRole.Name.tolowerCase().contains(keyword)){
                        project = mapOfKeyWords.get(keyword);
                    }
                }
                System.debug('project: ' + project);
                query += ' AND RW_RM_Name__c =: rmName AND RW_Project__r.Name =: project';
            }else{
                query += ' AND RW_RM_Name__c =: rmName';
            }
        }*/
        System.debug('query: ' + query);
        
        List<case> openComplaints = Database.query(query);
        System.debug('openComplaints: ' + openComplaints.size());
        //List<Case> openComplaints = [SELECT Id,CaseNumber,Status,CreatedDate,RW_Case_Reopened_Date__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.RW_Project__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project_Unit__c,Opportunity__r.RW_Project_Unit__r.Name,Opportunity__r.RW_Project_Unit__r.RW_Param2__c,Opportunity__r.RW_Project_Unit__r.RW_Param4__c,Opportunity__r.RW_Project_Unit__r.Cluster__c,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.Name,Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c FROM Case WHERE Status IN ('Open','Reopened') AND Opportunity__c != null ORDER By CreatedDate ASC];
        Datetime nowTime = System.now();
        Set<String> rmNames = new Set<String>();
        for(Case cs : openComplaints){
            if(cs.RW_RM_Name__c != null)
            	rmNames.add(cs.RW_RM_Name__c);
        }
        Map<String, String> rmNameVsTlName = new Map<String, String>();
        for(User u : [SELECT Id,Name,Manager.Name FROM User WHERE Name =: rmNames]){
            rmNameVsTlName.put(u.Name, u.Manager.Name);
        }
        for(Case cs : openComplaints) {
            if(cs.CreatedDate  <= (cs.Opportunity__r.Booking__r.RW_Key_handover_date__c + 90)){
                
                OpenComplaintsWrapper wrap = new OpenComplaintsWrapper();
                wrap.recordId = cs.Id;
                wrap.caseNumber = cs.CaseNumber;
                wrap.customerName = (cs.Opportunity__c != null)? cs.Opportunity__r.Name : '';
                wrap.customerNumber = (cs.Opportunity__c != null)? cs.Opportunity__r.SAP_Customer_Number__c : '';
                wrap.project = (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null) ? cs.Opportunity__r.RW_Project__r.Name : '';
                wrap.unit = (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null) ? cs.Opportunity__r.RW_Project_Unit__r.RW_Param4__c : '';
                wrap.tower =  (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null) ? cs.Opportunity__r.RW_Project_Unit__r.RW_Param2__c : '';
                wrap.phase = (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null) ? cs.Opportunity__r.RW_Project_Unit__r.Cluster__c : '';
                //wrap.rmName = (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null && cs.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__c != null) ? cs.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.Name : '';
                //wrap.tlName = (cs.Opportunity__c != null && cs.Opportunity__r.RW_Project__c != null && cs.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__c != null) ? cs.Opportunity__r.RW_Project_Unit__r.Relationship_Manager__r.TL_Name__c : '';
                wrap.rmName = (cs.RW_RM_Name__c != null) ? cs.RW_RM_Name__c : '';
                wrap.tlName = (cs.RW_RM_Name__c != null && rmNameVsTlName.containsKey(cs.RW_RM_Name__c)) ? rmNameVsTlName.get(cs.RW_RM_Name__c) : '';
                wrap.caseType = cs.Status;
                wrap.segment = cs.Opportunity__r.RW_Project__r.Segment_Lookup__r.Name;
                
                /*Datetime caseDate = cs.CreatedDate;
                if(cs.Status == 'Reopened' && cs.RW_Case_Reopened_Date__c != null){
                caseDate = cs.RW_Case_Reopened_Date__c;
                }
                
                Long diffMs = System.now().getTime() - caseDate.getTime();
                Integer totalMinutes = (Integer)(diffMs / (1000 * 60));
                Integer days = totalMinutes / 1440; // 1440 = 24 * 60
                Integer remainingAfterDays = Math.mod(totalMinutes, 1440);
                Integer hours = remainingAfterDays / 60;
                Integer minutes = Math.mod(remainingAfterDays, 60);
                wrap.caseOpenDate = caseDate.date();
                wrap.caseOpenTime = caseDate.format('hh:mm a');
                wrap.ageDays = days;
                wrap.ageHours = hours;
                wrap.ageMinutes = minutes;
                Integer totalHours = totalMinutes / 60;
                wrap.isOverdue = days > 1;*/
                
                if(cs.Status == 'Open'){
                    Long diffMs = System.now().getTime() - cs.CreatedDate.getTime();
                    Integer totalMinutes = (Integer)(diffMs / (1000 * 60));
                    Integer days = totalMinutes / 1440; // 1440 = 24 * 60
                    Integer remainingAfterDays = Math.mod(totalMinutes, 1440);
                    Integer hours = remainingAfterDays / 60;
                    Integer minutes = Math.mod(remainingAfterDays, 60);
                    wrap.caseOpenDate = cs.CreatedDate.date();
                    wrap.caseOpenTime = cs.CreatedDate.format('hh:mm a');
                    wrap.ageDaysCaseOpen = days;
                    wrap.ageHoursCaseOpen = hours;
                    wrap.ageMinutesCaseOpen = minutes;
                    Integer totalHours = totalMinutes / 60;
                    wrap.isOverdueCaseOpen = days > 1;
                    wrap.isOverdue = days > 1;
                }else if(cs.Status == 'Reopened' && cs.RW_Case_Reopened_Date__c != null){
                    Long diffMs = System.now().getTime() - cs.RW_Case_Reopened_Date__c.getTime();
                    Integer totalMinutes = (Integer)(diffMs / (1000 * 60));
                    Integer days = totalMinutes / 1440; // 1440 = 24 * 60
                    Integer remainingAfterDays = Math.mod(totalMinutes, 1440);
                    Integer hours = remainingAfterDays / 60;
                    Integer minutes = Math.mod(remainingAfterDays, 60);
                    wrap.caseReopenDate = cs.RW_Case_Reopened_Date__c.date();
                    wrap.caseReopenTime = cs.RW_Case_Reopened_Date__c.format('hh:mm a');
                    wrap.ageDaysCaseReopen = days;
                    wrap.ageHoursCaseReopen = hours;
                    wrap.ageMinutesCaseReopen = minutes;
                    Integer totalHours = totalMinutes / 60;
                    wrap.isOverdueCaseReopen = days > 1;
                    wrap.isOverdue = days > 1;
                }
                System.debug('wrap.rmName: ' + wrap.rmName);
                System.debug('usr.Name: ' + usr.Name);
                if(usr.Profile.Name == 'Relationship Manager'){
                    System.debug('wrap.rmName1: ' + wrap.rmName);
                    System.debug('usr.Name1: ' + usr.Name);
                    if(wrap.rmName == usr.Name)
                        wrapperList.add(wrap);
                    }/*else if(usr.Profile.Name == 'Team Leader'){
                    if(wrap.tlName == usr.Name)
                    wrapperList.add(wrap);
                    }*/else{
                    wrapperList.add(wrap);
                }
                //wrapperList.add(wrap);
            }
        }
        System.debug('wrapperList: ' + wrapperList);
        return wrapperList;
    }
}