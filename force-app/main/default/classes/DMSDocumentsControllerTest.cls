@isTest
public class DMSDocumentsControllerTest {
    
    @isTest
    public static void testDmsSearch(){
        Account objAcc = new Account();
        objAcc.name = 'test';
        insert objAcc;
        
        Opportunity objopp = new Opportunity();
        objopp.Name = 'test';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        objopp.SAP_Customer_Number__c = '123456';
        objopp.SalesOrder_Number__c = '124345';
        objopp.Primary_Name__c = 'Test';
        insert objopp;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param2__c = 'TOWER A';
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.RW_Param4__c = 'A-5504'; 
        insert objPUU;
        
        
        Booking__c objBking = new Booking__c();
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = objopp.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.Flat_No__c= 'A-5105';
        insert objBking;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Doc',
          PathOnClient = 'Doc.pdf',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objBking.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;  
        
        DMS_Projects_Map__c proMap = new DMS_Projects_Map__c();
        proMap.Name = 'Runwal Bliss';
        proMap.Project_Keyword__c = 'BLISS';
        proMap.Project_Category__c = 'EVIE#CRM#BLISS';
        insert proMap;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DMSDocumentsControllerSearchMock());
		DMSDocumentsController.searchDocs(objBking.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testDmsUpload(){
        Account objAcc = new Account();
        objAcc.name = 'test';
        insert objAcc;
        
        Opportunity objopp = new Opportunity();
        objopp.Name = 'test';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        objopp.SAP_Customer_Number__c = '123456';
        objopp.SalesOrder_Number__c = '124345';
        objopp.Primary_Name__c = 'Test';
        insert objopp;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param2__c = 'TOWER A';
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.RW_Param4__c = 'A-5504'; 
        insert objPUU;
        
        
        Booking__c objBking = new Booking__c();
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = objopp.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.Flat_No__c= 'A-5105';
        insert objBking;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Doc',
          PathOnClient = 'Doc.pdf',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objBking.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;  
        
        DMS_Projects_Map__c proMap = new DMS_Projects_Map__c();
        proMap.Name = 'Runwal Bliss';
        proMap.Project_Keyword__c = 'BLISS';
        proMap.Project_Category__c = 'EVIE#CRM#BLISS';
        insert proMap;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DMSDocumentsControllerUploadMock());
        Map<String, String> docIdVsBkgId = new Map<String, String>();
        docIdVsBkgId.put('DocId', documents[0].Id);
        docIdVsBkgId.put('bookingId', objBking.Id);
        DMSDocumentsController.sendDocsToDms(docIdVsBkgId); 
        Test.stopTest();
    }

}