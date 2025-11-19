@isTest
public class RW_ERPErrorHandlerTest {
    
    @isTest
    public static void test1(){
        
        Project__c Pro = new Project__c();
        pro.Name = 'Runwal Test 1';
        pro.RW_Project_Code__c = '180';
        pro.RW_SAP_Company_Code__c = '1000';
        pro.SAPMaterial_Code__c = '1001';
        insert pro;
        
        Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        acc.FirstName = 'Chetan';
        acc.LastName = 'Bhuimbar';
        acc.Mobile_No__c = '9879879870';
        acc.PersonEmail = 'sarj@gmail.com';
        insert acc;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = pro.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test 123';
        opp.AccountId = acc.Id;
        opp.RW_Project__c = pro.Id;
        opp.StageName = 'Qualification';
        opp.CloseDate = system.today();
        opp.RW_Rating__c = 'Hot';
        opp.Remark__c = 'Test 123';
        opp.LeadSource = 'Digital';
        opp.SalesOrder_Number__c = '123456';
        insert opp;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = pro.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = opp.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.RW_Unit_Status__c = 'Booked';
        objPUU.RW_Booking_Date__c = Date.today();
        objPUU.TowerName__c = objTower.Id;
        insert objPUU;
        
        opp.RW_Project_Unit__c = objPUU.Id;
        update opp;
        
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_Name__c = 'Sales Order';
        log.Opportunity__c = opp.Id;
        log.Error_Reason__c = 'Web service callout failed';
        log.Response__c='error';
        log.Status__c= 'Failure';
        log.Error_Type__c ='Timeout Error';
        insert log;
        
        log.Error_Reason__c = '';
        log.Retry_Count__c = 4;
        update log;
        
        //RW_ERPErrorHandler.reTriggerSalesOrder(new List<Id>{opp.Id});
    }

}