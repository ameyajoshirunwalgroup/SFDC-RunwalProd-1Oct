@isTest
public class TestGenerateOtpforProspect {
    
    @isTest static void test1(){
        
       Lead le = new Lead();
       le.RW_Mobile_No__c = string.valueOf(1234567890);
       le.LastName = 'tset';
       le.IsConverted = false;
       insert le;
        
       Project__c proj = new Project__c();
       proj.Name = 'runwalBliss';
       insert proj;
        
       RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];

        Account objAcc = new Account();
        objAcc.lastname = 'test2';
        objAcc.PersonEmail = 'test2289stetigin@test.in';
        objAcc.RecordType = personAccountRecordType;
        objAcc.MasterRecord__c = true;
        insert objAcc;
        
        Opportunity opty = new Opportunity();
        opty.name = 'test2';
        opty.AccountId = objAcc.id;
        opty.CloseDate = system.today();
        opty.StageName = 'Qualification';
        opty.RW_Project__c = proj.id;
        //objopp.RW_Project_Unit__c = objPU.id;
        opty.RW_Sales_Associate__c = 'Test22';
        opty.RW_Mobile_No__c = '1233211222';
        opty.RW_Email__c = 'test@56test2.com';
        //objopp.RW_RM_Name__c = 'test RM';
        insert opty;
        //OptyID = opty.Id;
        
       /*Opportunity opty = new Opportunity();
       opty.Name = 'test';
       opty.Project_Name__c = 'RunwalGreens';
       opty.RW_Project__c = proj.Id;
       opty.StageName = 'Qualification';
       insert opty;*/
        
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
       Prospect__c pros = new Prospect__c();
       pros.Lead__c = le.Id;
       pros.Opportunity__c = opty.Id;
       pros.Last_Call_Attempt_Status__c= 'follow up';
       pros.call_proposed_date_of_visit__c = system.now();
       pros.Sales_Call_Attempt_Status__c = 'follow up';
       pros.Sales_Call_Proposed_Date_Of_Visit__c = system.now();
       pros.Opportunity__c = opty.id;
       pros.Account__c = objAcc.id;
      // pros.Channel_Partner__c = objBroker.id;
       insert pros;
         
       OTP__c otpobj = new OTP__c();
       otpobj.Generated_OTP__c = '12345';
       otpobj.OTP_Generate_For__c= 'corporate';
       otpobj.OTP_Generated_on__c= string.valueOf(system.now());
       otpobj.Lead__c = le.Id;
       otpobj.Prospect__c = pros.Id;
       otpobj.Account__c = objAcc.id;
       otpobj.Customer_Site_Visit_On__c = string.valueOf(system.now());
        
          
       OTP__c otpobj1 = new OTP__c();
       otpobj1.Generated_OTP__c = '1235';
       otpobj1.OTP_Generate_For__c= 'Channel Partner';
       otpobj1.OTP_Generated_on__c= string.valueOf(system.now());
       otpobj1.Lead__c = le.Id;
       otpobj1.Prospect__c = pros.Id;
       otpobj1.account__c = objAcc.Id;
       otpobj1.Channel_Partner_Lookup__c = objBroker.id;
       otpobj1.Customer_Site_Visit_On__c = string.valueOf(system.now());
       insert otpobj1;
        
       Prospect__c pros1 = new Prospect__c();
       pros1.Lead__c = le.Id;   
       pros1.Lead_Source__c = 'Referral';
       pros1.Lead_Sub_Source__c = 'Existing client reference';
       pros1.Customer_Reference__c =  objAcc.id;
       insert pros1;
        
       OTP__c otpobj2 = new OTP__c();
       otpobj2.Generated_OTP__c = '61894';
       otpobj2.OTP_Generate_For__c= 'Referral';
       otpobj2.Referral_Sub_Source__c= 'Existing client reference';

       otpobj2.OTP_Generated_on__c= string.valueOf(system.now());
       otpobj2.Customer_Reference_Lookup__c =  pros1.Customer_Reference__c;
       otpobj2.Customer_Site_Visit_On__c = string.valueOf(system.now());
       insert otpobj2;
        
       
       PageReference otppage = Page.generateOTPforProspect;
       Test.setCurrentPage(otppage);
        
       ApexPages.currentPage().getParameters().put('id',String.valueOf(pros.Id));
       GenerateOtpControllerforProspect generateotp = new  GenerateOtpControllerforProspect();
        generateotp.dummyMethod();
       generateotp.sendOTP();
       generateotp.Back();
       Pagereference pg = new Pagereference('/' + pros.Id);
       pg.setredirect(true);
        
        
            }

}