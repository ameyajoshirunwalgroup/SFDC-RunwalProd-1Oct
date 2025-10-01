@isTest
public class CRMBotFlowTest {
    
    @isTest
    public static void test1(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.Haptik_Bot_Active__c = true;
        objpr.RW_Status__c = 'Active';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Mobile_No__c = '1236547896';
        acc.Country_Code__c = '+91';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.RW_Mobile_No__c = '1236547896';
        opp.RW_Email__c = 'test@mail.com';
        opp.SAP_Customer_Number__c = '12345';
        opp.RW_Project__c = objpr.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        opp.Booking__c = bkg.Id;
        update opp;
        
        Test.startTest();
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/CRMBotFlow'; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        req1.addParameter('number','911236547896');
        CRMBotFlow.doGet();
        
        CRMBotFlow.doPost('12345','Test','Booking Confirmation Letter','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Account Statement','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void test2(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.Haptik_Bot_Active__c = true;
        objpr.RW_Status__c = 'Active';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Mobile_No__c = '1236547896';
        acc.Country_Code__c = '+91';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.RW_Mobile_No__c = '1236547896';
        opp.RW_Email__c = 'test@mail.com';
        opp.SAP_Customer_Number__c = '12345';
        opp.RW_Project__c = objpr.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        opp.Booking__c = bkg.Id;
        update opp;
        
        Test.startTest();

        
        CRMBotFlow.doPost('12345','Test','Last 3 Demand Letters','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Latest Payment Receipt','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Last 3 Payment Receipts','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        
        Test.stopTest();
    }
    
    @isTest
    public static void test3(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.Haptik_Bot_Active__c = true;
        objpr.RW_Status__c = 'Active';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Mobile_No__c = '1236547896';
        acc.Country_Code__c = '+91';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.RW_Mobile_No__c = '1236547896';
        opp.RW_Email__c = 'test@mail.com';
        opp.SAP_Customer_Number__c = '12345';
        opp.RW_Project__c = objpr.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        opp.Booking__c = bkg.Id;
        update opp;
        
        Test.startTest();

        
        CRMBotFlow.doPost('12345','Test','Current Outstanding','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Possession Date','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Interest Statement','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        
        Test.stopTest();
    }
    
    
    @isTest
    public static void test4(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.Haptik_Bot_Active__c = true;
        objpr.RW_Status__c = 'Active';
        objpr.RW_SAP_Company_Code__c = '1000';
        insert objpr;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Mobile_No__c = '1236547896';
        acc.Country_Code__c = '+91';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.CloseDate = Date.today() + 10;
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.RW_Mobile_No__c = '1236547896';
        opp.RW_Email__c = 'test@mail.com';
        opp.SAP_Customer_Number__c = '12345';
        opp.RW_Project__c = objpr.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        insert bkg;
        
        opp.Booking__c = bkg.Id;
        update opp;
        
        Test.startTest();
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/CRMBotFlow'; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        req1.addParameter('number','911236547896');
        CRMBotFlow.doGet();
        
        CRMBotFlow.doPost('12345','Test','Payment Online','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        CRMBotFlow.doPost('12345','Test','Latest Demand Letter','1000',objpr.Id,bkg.Id,'','test@mail.com','');
        
        Test.stopTest();
    }

}