@RestResource(urlMapping='/GetUnitDetails/*')
global without sharing class GetUnitDetailsRest {
    @HttpGet
    global static List<Project_Unit__c> doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String custNum = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(!String.isBlank(custNum)){
            List<Opportunity> opp = [SELECT Id, Name, AccountId FROM Opportunity WHERE SAP_Customer_Number__c =: custNum ORDER BY CreatedDate DESC];
            Map<Id, Opportunity> oppsMap = new Map<Id,Opportunity>([SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId =: opp[0].AccountId]);
            List<Booking__c> bookings = [SELECT Id, Name, Project__c, Unit_No__c, Unit_Number__c, Opportunity__c, Wing__c, Zone__c,
                                         Floor__c, Flat_No__c, Status__c, Booking_Date__c 
                                         FROM Booking__c WHERE Customer__c =: oppsMap.keySet()];
            Set<Id> unitIds = new Set<Id>();
            for(Booking__c bk : bookings){
                unitIds.add(bk.Unit_No__c);
            }
            List<Project_Unit__c> units = [SELECT Id, Name, RW_Param4__c, Relationship_Manager__c, Relationship_Manager__r.RM_Name__c,
                                           Relationship_Manager__r.RM_Email__c, Relationship_Manager__r.Contact_Number__c, Booking__c,
                                           Booking__r.Name, Booking__r.Project__c, Relationship_Manager__r.User__c
                                           FROM Project_Unit__c WHERE Id =: unitIds];
            
            return units;
        }else{
            return null;
        }
        
    }
}