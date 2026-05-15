@isTest
public class SendWhatsAppOnSOCreationQueueableTest {
    
    @isTest
    public static void test1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduserrtt@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrr@testorg.com');
        insert u;
        
        User u2 = new User(Alias = 'standt', Email='testUser2@t1estorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@t1estorg.com'
                          );
        insert u2;
        List <Opportunity> ld = new List <Opportunity> ();
        OppTriggerHandler opp = new OppTriggerHandler();
        opp.BeforeInsert(ld);
        update ld;
        
        
        Project__c objProj = new Project__c();
        objProj.name = 'test2';
        insert objProj;
        
        Relationship_Manager__c rm1 = new Relationship_Manager__c();
        rm1.Name = 'test9';
        insert rm1;
        
        Project_Unit__c objPU = new Project_Unit__c();
        objPU.name = 'test2';
        objPU.RW_Project__c = objProj.id;
        objPU.RW_Param1__c = 'P1';
        objPU.RW_Param2__c = 'T1';
        objPU.RW_Param3__c = 'F1';
        objPU.RW_Param4__c = 'U1';
        objPU.RW_Unit_Status__c = 'Available';
        objPU.RW_Seventh_Day__c = false;
        objPU.Relationship_Manager__c = rm1.Id;
        insert objPU;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Project_Location__c = pl.id;
        insert objpr;
        
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        
        Account objAcc = new Account();
        objAcc.lastname = 'test2';
        objAcc.PersonEmail = 'teststetigin@test.in';
        objAcc.RecordType = personAccountRecordType;
        objAcc.MasterRecord__c = true;
        insert objAcc;
        
        Opp_Close_Date__c dt = new Opp_Close_Date__c();
        dt.Project_Name__c = 'test2';
        dt.Name = objProj.Id;
        dt.No_of_Days__c = 45;
        insert dt;
        
        Opportunity objopp = new Opportunity();
        objopp.name = 'test2';
        objopp.AccountId = objAcc.id;
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        objopp.RW_Project__c = objProj.id;
        objopp.RW_Project_Unit__c = objPU.id;
        objopp.RW_Sales_Associate__c = 'Test2';
        objopp.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        objopp.RW_Mobile_No__c = '1233211231';
        objopp.RW_Email__c = 'test1@test2.com';
        objopp.RW_RM_Name__c = 'Aliya Kirkire';
        objopp.LeadSource = 'Retention';
        objopp.Retention_RM_Name__c = u.Id;
        objopp.Retention_Closing_Head_Name__c = u.Id;
        objopp.Retention_Presales_User__c = u.Id;
        objopp.Retention_Sales_Manager__c = u.Id;
        objopp.SalesOrder_Number__c = null;
        insert objopp;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        //q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objopp.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.MLCP_Additional__c = null;
        q.Agreement_Value_for_brokers__c = 10000000;
        insert q;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = objopp.Id;
        bkg.Quotation__c = q.Id;
        insert bkg;
        
        objPU.RW_Unit_Status__c = 'Booked';
        objPU.RW_Booking_Date__c = system.today();
        update objPU;
        
        objopp.SalesOrder_Number__c = '123456';
        objopp.StageName = 'Unit Booked';
        update objopp;
        
        
        Test.startTest();
        SendWhatsAppOnSOCreationQueueable que = new SendWhatsAppOnSOCreationQueueable(new List<Id>{objopp.Id});
        system.enqueueJob(que);
        //SendWhatsAppOnSOCreationQueueable.dummy();
        Test.stopTest();
    }
    
}