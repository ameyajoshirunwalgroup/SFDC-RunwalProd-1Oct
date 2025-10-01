@RestResource(urlMapping='/CustomerCases/*')
global with sharing class CustomerCasesRestService {
	
    @HttpGet
    global static List<Case> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String custNum = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(!String.isBlank(custNum)){
            List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE SAP_Customer_Number__c =: custNum];
            if(opps.size() > 0){
                List<Case> lstCases = [SELECT Id, AccountId, Case_Description__c, CaseNumber, ClosedDate, Comments, Description,
                                       IsClosed, Manager_Name__c, Priority, Reason, Remarks_by_RM__c, RecordTypeId, 
                                       RW_Approval_Status__c, RW_Case_Comming_From_Portal__c, RW_Case_Escalation__c, RW_Case_Reopened_Date__c,
                                       RW_Case_Type__c, RW_Communication_Type__c, RW_Complaint_Sub_Subtype__c, RW_Complaint_SubType__c,
                                       RW_Complaint_Type__c, RW_Employee__c, RW_Escalated_Time__c, RW_Flat_No__c, 
                                       RW_Mobile_No__c, RW_Owner_Name__c, RW_Project__c, RW_Project_Unit__c, RW_Query_Type__c, RW_RM_Name__c,
                                       RW_RM_Remarks__c, Status, Subject, Type FROM Case WHERE AccountId =: opps[0].AccountId];
                return lstCases;
            }else{
                return null;
            }
        }else{
            return null;
        }
        
    }
}