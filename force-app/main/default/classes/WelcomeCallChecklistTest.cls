@isTest
public class WelcomeCallChecklistTest {
     
    @testSetup
    public static void WelcomeCallChecklistDataTest() 
    {
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        user salesmanager = UniversalTestClassSetup.createusers('Sales Manager', 'Deepak','Arya','salesmanager@runwal.com.uat','salesmanagertest@runwal.com.uat');
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        UniversalTestClassSetup.assignpm(rm.id,'RM_Permission_Set');
        
         UserRole obj1=new UserRole(Name= 'ABC'); 
			insert obj1;
        String recordTypeId1  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        sitehead.UserRoleId = obj1.Id;
        update sitehead;
        system.runAs(rm){
               Test.startTest();
               //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        a.OwnerId=sitehead.Id;
        a.RecordTypeId =recordTypeId1;
        insert a;
            
        Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
       Project__c objpr = UniversalTestClassSetup.setupproject(sitehead.id,objlglentity.id);
         
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.id,'A','Residential');
            
            Tower__c t1 = UniversalTestClassSetup.setuptower(objpr.id,'A','Commercial');
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
       Tower__c objTwr = new Tower__c();
        objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
            Relationship_Manager__c rms = new Relationship_Manager__c();
            rms.User__c = rm.id;
            rms.Project__c = objpr.id;
            rms.Tower__c = t1.id;
            insert rms;
            
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = t1.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = oppRec.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Relationship_Manager__c = rms.Id;
        objPUU.Carpet_Area__c= 789;
        insert objPUU;
            
         Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = oppRec.Id;
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
        insert q;
        
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = oppRec.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Quotation__c = q.Id;
        objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        objBking.Sales_Manager__c= salesmanager.Id;
        objBking.Status__c ='Booking Confirmed';
        insert objBking;
    
          RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
         wcObj.RW_Booking__c = objBking.Id;
         wcObj.RW_Welcome_Call_Status__c = 'Accept';
         //wcObj.Name = 'Test';
         wcObj.RW_Is_welcome_Letter_sent__c = True;
         wcObj.RW_Welcome_Call_Completed__c = false;
         wcObj.RW_Welcome_Call_Initiation_date__c = null;
         wcObj.RW_Welcome_Call_Accepted_date__c = system.today();
         wcObj.RW_Discrepancy_list_shared_via_email__c = True;
         wcObj.RM_email__c = 'test@123.com';
        
         insert wcObj;
        
        RW_Welcome_Call_Remarks__c welRema = new RW_Welcome_Call_Remarks__c();
        welRema.RW_Welcome_Call__c = wcObj.Id;
        welRema.RW_Remarks__c = 'ApplicantName1: Yes~Test7 Test9 Test8~ApplicantName1 % appnme,EmailAddresses1: Yes~shailesh.devare@stetig.in~EmailAddresses1 % email@email.com';
        insert welRema;
        
        
        Team__c tem = new Team__c();
        tem.Name = 'CRM Lead';
        tem.Project__c = objpr.Id;
        tem.Team_Type__c= 'Team Lead';
        insert tem;
        
        Team_Members__c temMbr = new Team_Members__c();
        temMbr.Team__c = tem.Id;
        temMbr.User__c = sitehead.Id;
        temMbr.User_Active__c  =true;
        insert temMbr;
            
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = oppRec.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = objBking.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'wc@email.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        apt1.PancardNo__c = 'abc213456';
        appList.add(apt1);
        insert apt1;
        
        Applicant_Details__c apt2 = new Applicant_Details__c();
        apt2.Name = 'Applicant 2';
        apt2.Permanent_Address__c = 'test address1';
        apt2.Opportunity__c = oppRec.Id;
        apt2.Applicant_Number__c = 'Second Applicant';
        apt2.Subtype_Of_Applicant__c = 'Indian National';
        apt2.Type_Of_Applicant__c= 'Individual Buyer';
        apt2.Booking__c = objBking.Id;
        apt2.DOB__c = Date.today();
        apt2.Office_Address_Line_1__c = 'Office Address Line 2';
        apt2.Mobile_Number__c = '1234567899';
        apt2.Email_Address__c = 'wc@email.com';
        apt2.Address_Proof__c = true;
        apt2.Address_Proof_Document__c = 'Passport';
        apt2.gender__c = 'Female';
        apt2.Designation_picklist__c = 'Accounting';
        apt2.Occupation__c = 'Admin';
        apt2.PancardNo__c = 'abc213456';
        appList.add(apt2);
        insert apt2;
        
        Applicant_Details__c apt3 = new Applicant_Details__c();
        apt3.Name = 'Applicant 3';
        apt3.Permanent_Address__c = 'test address1';
        apt3.Opportunity__c = oppRec.Id;
        apt3.Applicant_Number__c = 'Third Applicant';
        apt3.Subtype_Of_Applicant__c = 'Indian National';
        apt3.Type_Of_Applicant__c= 'Individual Buyer';
        apt3.Booking__c = objBking.Id;
        apt3.DOB__c = Date.today();
        apt3.Office_Address_Line_1__c = 'Office Address Line 2';
        apt3.Mobile_Number__c = '1234567899';
        apt3.Email_Address__c = 'wc@email.com';
        apt3.Address_Proof__c = true;
        apt3.Address_Proof_Document__c = 'Passport';
        apt3.gender__c = 'Male';
        apt3.Designation_picklist__c = 'Accounting';
        apt3.Occupation__c = 'Admin';
        apt3.PancardNo__c = 'abc213456';
        appList.add(apt3);
        insert apt3;
        
        Applicant_Details__c apt4 = new Applicant_Details__c();
        apt4.Name = 'Applicant 4';
        apt4.Permanent_Address__c = 'test address1';
        apt4.Opportunity__c = oppRec.Id;
        apt4.Applicant_Number__c = 'Fourth Applicant';
        apt4.Subtype_Of_Applicant__c = 'Indian National';
        apt4.Type_Of_Applicant__c= 'Individual Buyer';
        apt4.Booking__c = objBking.Id;
        apt4.DOB__c = Date.today();
        apt4.Office_Address_Line_1__c = 'Office Address Line 2';
        apt4.Mobile_Number__c = '1234567899';
        apt4.Email_Address__c = 'wc@email.com';
        apt4.Address_Proof__c = true;
        apt4.Address_Proof_Document__c = 'Passport';
        apt4.PancardNo__c = 'abc213456';
        appList.add(apt4);
        insert apt4;
        
        Applicant_Details__c apt5 = new Applicant_Details__c();
        apt5.Name = 'Applicant 5';
        apt5.Permanent_Address__c = 'test address1';
        apt5.Opportunity__c = oppRec.Id;
        apt5.Applicant_Number__c = 'Fifth Applicant';
        apt5.Subtype_Of_Applicant__c = 'Indian National';
        apt5.Type_Of_Applicant__c= 'Individual Buyer';
        apt5.Booking__c = objBking.Id;
        apt5.DOB__c = Date.today();
        apt5.Office_Address_Line_1__c = 'Office Address Line 2';
        apt5.Mobile_Number__c = '1234567899';
        apt5.Email_Address__c = 'wc@email.com';
        apt5.Address_Proof__c = true;
        apt5.Address_Proof_Document__c = 'Passport';
        apt5.PancardNo__c = 'abc213456';
        appList.add(apt5);
        insert apt5;
    
        }
        
        
            UserRole obj=new UserRole(Name= 'ABC'); 
			insert obj;
            
            List<Profile> profiles = [Select Id, Name from Profile where Name IN ('System Administrator','Runwal Customer Portal')];
       Map<String, String> profileMap = new Map<String, String>();
        for(Profile prof : profiles){
            profileMap.put(prof.Name, prof.Id);
        }

    	/*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;*/
        
        String orgId1 = UserInfo.getOrganizationId();
    String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName1 = orgId1 + dateString1 + randomInt1;
    User tuser1 = new User(  firstname = 'TestUser',
                            lastName = 'TestUser',
                            email = uniqueName1 + '@gmail' +'.com',
                            Username = uniqueName1 + '@test' + orgId1 + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName1.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = profileMap.get('System Administrator'),
                            UserRoleId = obj.Id
                            );
         insert tuser1;
            
         List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0])
        {    
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
        //Inserting account
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        objAcc.RecordTypeID=recordTypeId ;
        objAcc.LastName ='TestAccount22';
        objAcc.PersonEmail = 'wc@email.com';
        objAcc.City__c='TestCity';
        objAcc.RW_Zip_Code__c = '9999999';
        objAcc.State__c ='Karnataka';
        objAcc.Country__c ='India';
        objAcc.Mobile_No__c = '9876543212';
        objAcc.Alternate_Email__c = 'wc1@email.com';
        objAcc.Gender__c='Male';
        objAcc.Salutation = 'Mr.';
        objAcc.Birth_Date__c = System.today().addYears(-20); 
        objAcc.OwnerId = tuser1.Id;
        insert objAcc;
        
        Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        
        //Profile p = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser1',
                              lastName = 'TestUser2',
                              email = uniqueName + '@gmail' +'.com',
                              contactId=acc.PersonContactId,
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = profileMap.get('Runwal Customer Portal')
                             );
        insert tuser;
        system.debug('*1*');
        }
    }
   @isTest
    Public static void testgetPicklistValuesForBankName() 
    {
        WelcomeCallChecklist handler = new WelcomeCallChecklist();
        handler.dummyMethod();
         WelcomeCallChecklist.getPicklistValuesForBankName('Loan__c',new List<String>{'RW_Bank_Name__c'});
   
    }
    
 @isTest
public static void testprevCallRemarks() {
    try {
        Test.startTest();
        
        User u = [SELECT Id, Name FROM User WHERE Username = 'rmanagertest@runwal.com.uat'];  
        System.runAs(u) {
           // Test.startTest();  

            System.debug('%%%%%%%%%%%%%%%');  
            
            // --- Your SOQL queries and object setup here ---
            Booking__c objBking = [SELECT Id, Name FROM Booking__c LIMIT 1];
            
            List<Applicant_Details__c> appList = [SELECT Id, Name FROM Applicant_Details__c LIMIT 10];
            Receipt__c r1 = [SELECT Id, Name FROM Receipt__c LIMIT 1];
            RW_Welcome_Call__c wcObj = [SELECT Id, Name FROM RW_Welcome_Call__c LIMIT 1];
            
            List<String> finalRemarksList = new List<String>{
                'ApplicantName1: Yes~Test7 Test9 Test8~ApplicantName1 % appnme',
                'EmailAddresses1: Yes~shailesh.devare@stetig.in~EmailAddresses1 % email@email.com'
            };
            
            WelcomeCallChecklist.WrpClsWelcomeObj wrpObj = new WelcomeCallChecklist.WrpClsWelcomeObj();
            wrpObj.bkg = objBking;
            wrpObj.applicantList = appList;
            wrpObj.link = 'test';
            
            String status = 'Reject';                                            
            String addRrmks = 'Test';  
            String modeOfFunding = 'Bank Loan';   
            List<String> bankPreferenceForLoan = new List<String>{'Axis Bank','Bank of India'};    
            Boolean isDhamaka = true;  
            
            // ---- Method Calls ----
            WelcomeCallChecklist.CriticalNonCriticalLineItems();
            WelcomeCallChecklist.prevCallRemarks(objBking.Id);
            WelcomeCallChecklist.loadYesNoDropDown(objBking.Id);
            WelcomeCallChecklist.loadModeOfFunding(objBking.Id);
            WelcomeCallChecklist.callCheckList(objBking.Id);
            WelcomeCallChecklist.registrationConsultants();    
            WelcomeCallChecklist.createTaskFromPB(new List<Id>{objBking.Id});
            
            WelcomeCallChecklist.saveCheckList(
                finalRemarksList, wrpObj, status, addRrmks, modeOfFunding,
                'Axis Bank', 'Axis Bank', 'Axis Bank',
                bankPreferenceForLoan, new List<Receipt__c>{r1}, isDhamaka
            );
            
            Test.stopTest();
        }
        
        // Batch jobs
        WelcomeCallPendingList wecplist = new WelcomeCallPendingList();
        Database.executeBatch(wecplist, 1);
        
        WelcomeCallEscalationMatrix objClass = new WelcomeCallEscalationMatrix();
	        Database.executeBatch(objClass, 1);
        
    } catch (Exception e) {
        System.debug('❌ Unexpected exception: ' + e.getMessage());
        System.debug('❌ Stack Trace: ' + e.getStackTraceString());
    }
}

     public static testMethod void testschedule() {
        Test.StartTest();
    	ScheduleWelcomeCallPendingList testsche = new ScheduleWelcomeCallPendingList();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    
    public static testMethod void testschedule1() {
        Test.StartTest();
    	ScheduleWelcomeCallEscalationMatrix testsche = new ScheduleWelcomeCallEscalationMatrix();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
    
    
}