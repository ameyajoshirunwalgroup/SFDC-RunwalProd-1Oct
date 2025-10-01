global class SendRMDetailsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id,LastModifiedDate, Legal_Entity__c, TowerName__r.SAP_Plant_Code__c, RW_Customer__r.SAP_Customer_Number__c,
            Unit_SAP_Code__c, Relationship_Manager__r.User__r.Name, Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c,
            Relationship_Manager__r.User__r.Email, Legal_Entity__r.RDS_Company_Code__c, RW_Customer__r.RW_Sourcing_Manager__c,RW_Customer__r.RW_Sales_Associate__c,
            RW_Customer__r.RW_Closing_Head__c, RW_Customer__r.StageName,RW_Project__r.Contact_No__c,RW_Project__r.Name
            FROM Project_Unit__c where 
            (RM_Updation_Date__c = YESTERDAY or RW_Customer__r.Last_Sourcing_Closing_Mgr_Change__c = YESTERDAY) and 
            Legal_Entity__r.RDS_Company_Code__c != null and TowerName__r.SAP_Plant_Code__c != null and RW_Customer__r.SAP_Customer_Number__c != null and Unit_SAP_Code__c != null
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Project_Unit__c> puList) {
        List<SendRMdetailstoSAP.ResponseData> responseDataList = new List<SendRMdetailstoSAP.ResponseData>();
        
        for (Project_Unit__c opp : puList) {
            SendRMdetailstoSAP.ResponseData resp = new SendRMdetailstoSAP.ResponseData();
            if (opp.Legal_Entity__r.RDS_Company_Code__c != null){
                resp.BUKRS = opp.Legal_Entity__r.RDS_Company_Code__c;
            } 
            if (opp.TowerName__r.SAP_Plant_Code__c != null){
                resp.WERKS = opp.TowerName__r.SAP_Plant_Code__c;
            } 
            if (opp.RW_Customer__r.SAP_Customer_Number__c != null){
                resp.KUNNR = opp.RW_Customer__r.SAP_Customer_Number__c;
            } 
            if (opp.Unit_SAP_Code__c != null){
                resp.MATNR = opp.Unit_SAP_Code__c;
            } 
            if (opp.RW_Customer__r.RW_Sourcing_Manager__c != null){
                resp.SOURCING_MNGR = opp.RW_Customer__r.RW_Sourcing_Manager__c;
            } 
            if (opp.RW_Customer__r.RW_Sales_Associate__c != null){
                resp.CLOSING_MNGR = opp.RW_Customer__r.RW_Sales_Associate__c;
            } 
            if (opp.Relationship_Manager__r.User__r.Name != null){
                resp.RM_NAME = opp.Relationship_Manager__r.User__r.Name;
            } 
            if(opp.RW_Project__r.Name == '7 Mahalaxmi'){
                if (opp.Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c != null){
                    resp.RM_NUMBER = opp.Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c;
                } 
            }else if(opp.RW_Project__r.Name != '7 Mahalaxmi'){
                if (opp.RW_Project__r.Contact_No__c != null){
                    resp.RM_NUMBER = opp.RW_Project__r.Contact_No__c;
                } 
            }
            
            if (opp.Relationship_Manager__r.User__r.Email != null){
                resp.RM_EMAIL = opp.Relationship_Manager__r.User__r.Email;
            } 
            responseDataList.add(resp);
        }
        
        String jsonBody = JSON.serialize(responseDataList);
        System.debug('JSON Body: ' + jsonBody);
        
        SendRMdetailstoSAP.calloutToSAP(jsonBody);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch completed successfully.');
    }
}