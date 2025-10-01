@isTest
public class ConvertTempCpToOriginalCpControllerTest {
    
    @isTest
    public static void convertTempCpTest(){
        Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
        tempCp.Name = 'Test Temp CP';
        tempCp.Mobile_No__c = '1111111111';
        tempCp.Email__c = 'test@mail.com';
        tempCp.First_Name__c = 'Test FN';
        tempCp.Last_Name__c = 'Test LN';
        tempCp.PAN_No__c = 'AQRTG5445F';
        tempCp.State__c = 'Test State';
        insert tempCp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test';
        insert proj;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Temp_Channel_Partner__c = tempCp.Id;
        ld.LeadSource = 'Temp Channel Partner';
        ld.RW_Mobile_No__c = '2244556633';
        ld.Email = 'test1@mail.com';
        ld.RW_Project__c = proj.Id; //Added by Vinay 29-08-2025
        insert ld;
        
        Prospect__c prs = new Prospect__c();
        prs.Temp_Channel_Partner__c = tempCp.Id;
        prs.Lead_Source__c = 'Temp Channel Partner';
        insert prs;
        
        
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'Test';
        dt.Name = proj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test Opportunity';
        opp.LeadSource = 'Temp Channel Partner';
        opp.Temp_Channel_Partner__c = tempCp.Id;
        opp.RW_Project__c = proj.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Temp_Channel_Partner_Name__c = 'Test Temp CP';
        bkg.Source_of_Booking__c = 'Temp Channel Partner';
        insert bkg;
        
        ConvertTempCpToOriginalCpController.convertCp(tempCp.Id);
       
    }
    
    @isTest
    public static void convertTempCpTest1(){
        Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
        tempCp.Name = 'Test Temp CP';
        tempCp.Mobile_No__c = '2145896568';//Added by Vinay 29-08-2025
        insert tempCp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test';
        insert proj;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Temp_Channel_Partner__c = tempCp.Id;
        ld.LeadSource = 'Temp Channel Partner';
        ld.RW_Mobile_No__c = '2244556633';
        ld.Email = 'test1@mail.com';
        ld.RW_Project__c = proj.Id; //Added by Vinay 29-08-2025
        insert ld;
        
        Prospect__c prs = new Prospect__c();
        prs.Temp_Channel_Partner__c = tempCp.Id;
        prs.Lead_Source__c = 'Temp Channel Partner';
        insert prs;
        
        
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'Test';
        dt.Name = proj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test Opportunity';
        opp.LeadSource = 'Temp Channel Partner';
        opp.Temp_Channel_Partner__c = tempCp.Id;
        opp.RW_Project__c = proj.Id;
        insert opp;
        
        Booking__c bkg = new Booking__c();
        bkg.Temp_Channel_Partner_Name__c = 'Test Temp CP';
        bkg.Source_of_Booking__c = 'Temp Channel Partner';
        insert bkg;
        
        ConvertTempCpToOriginalCpController.convertCp(tempCp.Id);
        //ConvertTempCpToOriginalCpController.dummy();
       
    }
    
    @isTest
    public static void checkTempCpTest(){
        Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
        tempCp.Name = 'Test Temp CP';
        tempCp.Mobile_No__c = '2222222222';
        tempCp.Email__c = 'test@mail.com';
        tempCp.First_Name__c = 'Test FN';
        tempCp.Last_Name__c = 'Test LN';
        tempCp.PAN_No__c = 'AQRTG5445F';
        tempCp.State__c = 'Test State';
        insert tempCp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test';
        insert proj;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Temp_Channel_Partner__c = tempCp.Id;
        ld.LeadSource = 'Temp Channel Partner';
        ld.RW_Mobile_No__c = '2244556633';
        ld.Email = 'test1@mail.com';
        ld.RW_Project__c = proj.Id; //Added by Vinay 29-08-2025
        insert ld;
        
        Prospect__c prs = new Prospect__c();
        prs.Temp_Channel_Partner__c = tempCp.Id;
        prs.Lead_Source__c = 'Temp Channel Partner';
        insert prs;
        
        
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'Test';
        dt.Name = proj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test Opportunity';
        opp.LeadSource = 'Temp Channel Partner';
        opp.Temp_Channel_Partner__c = tempCp.Id;
        opp.RW_Project__c = proj.Id;
        insert opp;
        
        Broker__c br = new Broker__c();
        br.Name = 'Test CP';
        br.RW_Mobile_No__c = '2222222222';
        br.Broker_Pan_No__c = 'ASDRT5445F';
        insert br;
        
        ChannelPartnerTriggerHandler.checkTempCp(new List<String>{br.Id});
        //ChannelPartnerTriggerHandler.tagFromTempCpToOriginalCp(new List<String>{br.Id});
    }
    
    @isTest
    public static void tagFromTempCpToOriginalCpTest(){
        
        Broker__c br = new Broker__c();
        br.Name = 'Test CP';
        br.RW_Mobile_No__c = '1111111111';
        br.Broker_Pan_No__c = 'ASDRT5445F';
        br.Registration_Complete__c = true;
        insert br;
        
        
        Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
        tempCp.Name = 'Test Temp CP';
        tempCp.Mobile_No__c = '1111111111';
        tempCp.Email__c = 'test@mail.com';
        tempCp.First_Name__c = 'Test FN';
        tempCp.Last_Name__c = 'Test LN';
        tempCp.PAN_No__c = 'AQRTG5445F';
        tempCp.State__c = 'Test State';
        tempCp.Original_Channel_Partner__c = br.Id;
        insert tempCp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Test';
        insert proj;
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead';
        ld.Temp_Channel_Partner__c = tempCp.Id;
        ld.LeadSource = 'Temp Channel Partner';
        ld.RW_Mobile_No__c = '2244556633';
        ld.Email = 'test1@mail.com';
        ld.RW_Project__c = proj.Id; //Added by Vinay 29-08-2025
        insert ld;
        
        Prospect__c prs = new Prospect__c();
        prs.Temp_Channel_Partner__c = tempCp.Id;
        prs.Lead_Source__c = 'Temp Channel Partner';
        insert prs;
        
        
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'Test';
        dt.Name = proj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.Name = 'Test Opportunity';
        opp.LeadSource = 'Temp Channel Partner';
        opp.Temp_Channel_Partner__c = tempCp.Id;
        opp.RW_Project__c = proj.Id;
        insert opp;
        
        br.RW_CreateFromIRIS__c = true;
        br.RW_GST_Number__c = '123456789123456';
        
        update br;
        
        //ChannelPartnerTriggerHandler.tagFromTempCpToOriginalCp(new List<String>{br.Id});
    }
    
    @isTest
    public static void anarockLeadTest1(){
        RestRequest req= new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/anarockCp'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        String jsonRespose = '{"LeadData" : {"name" : "Test Lead","mobile" : "2222222225","projectId" : "","email" : ""},"CpData" : {"name" : "Test Cp","mobile" : "3333333334","email" : "","state" : "","pan" : ""}}';
        req.requestBody = Blob.valueof(jsonRespose);
        RestContext.request = req;
        RestContext.response = res;
        AnarockLeadCpCreation.doPost();
    }
    
    @isTest
    public static void anarockLeadTest2(){
        
        Broker__c br = new Broker__c();
        br.Name = 'Test Cp';
        br.RW_Mobile_No__c = '3333333334';
        br.Broker_Pan_No__c = 'ADERG5445F';
        insert br;
        
        RestRequest req= new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/anarockCp'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        String jsonRespose = '{"LeadData" : {"name" : "Test Lead","mobile" : "2222222225","projectId" : "","email" : ""},"CpData" : {"name" : "Test Cp","mobile" : "3333333334","email" : "","state" : "","pan" : ""}}';
        req.requestBody = Blob.valueof(jsonRespose);
        RestContext.request = req;
        RestContext.response = res;
        AnarockLeadCpCreation.doPost();
    }
    
    @isTest
    public static void anarockLeadTest3(){
        
        Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
        tempCp.Name = 'Test Cp';
        tempCp.Mobile_No__c = '3333333334';
        insert tempCp;
        
        RestRequest req= new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/anarockCp'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        String jsonRespose = '{"LeadData" : {"name" : "Test Lead","mobile" : "2222222225","projectId" : "","email" : ""},"CpData" : {"name" : "Test Cp","mobile" : "3333333334","email" : "","state" : "","pan" : ""}}';
        req.requestBody = Blob.valueof(jsonRespose);
        RestContext.request = req;
        RestContext.response = res;
        AnarockLeadCpCreation.doPost();
    }

}