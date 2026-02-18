@isTest 
public class CPDashboardControllerTest {
    
    @isTest 
    static void testGetFilteredCases_NewUser() {
        // Mock the JSON data
        String jsonData = '{"unProcessedCases":"","totalOpenStage1":"","projectName": "Test Project","Registered":"","registeredCases":"","openregisteredCases":"","closedregisteredCases":"","totalopenregistered":"","totalclosedregistered":"","stage1":"","stage2":"","stage3":"","stage4":"","stage5":"","stage6":"","stage7":"","totalstage1rcases":"","totalstage2rcases":"","totalstage3rcases":"","totalstage4rcases":"","totalstage5rcases":"","totalstage6rcases":"","totalstage7rcases":"","unstage1":"","unstage2":"","unstage3":"","unstage4":"","unstage5":"","unstage6":"","unstage7":"","totalstage1uncases":"","totalstage2uncases":"","totalstage3uncases":"","totalstage4uncases":"","totalstage5uncases":"","totalstage6uncases":"","totalstage7uncases":"","UnRegistered":"","unregisteredCases":"","openunregisteredCases":"","closedunregisteredCases":"","Total_Un":"","totalopenunregistered":"","totalclosedunregistered":"","totalopencases":"","totalclosedcases":"","totalstage1cases":"","totalstage2cases":"","totalstage3cases":"","totalstage4cases":"","totalstage5cases":"","totalstage6cases":"","totalstage7cases":"","period":"Custom", "new_user": ""}'; // Replace with actual User Id
        
        // Create test data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Now create the User with the ContactId set
        User u = new User(
            Alias = 'standtq',
            Email = 'standarduserq@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingNew',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standardusernew@testorg.com'
        );
        insert u;
        
        // Create a test Project__c record
        Project__c project = new Project__c(
            Name = 'Test Project'
        );
        insert project;
        
        Test.startTest();
        // Call the method with mocked data
        List<Case> filteredCases = CPDashboardController.getFilteredCasesNew(jsonData, 'custom', null, null, u.Id);
        CPDashboardController.getFilteredCasesNew(jsonData, 'custom', '2024', '7', u.Id);
        CPDashboardController.getFilteredCasesNew(jsonData, 'custom', '', '7', u.Id);
        CPDashboardController.getFilteredCasesNew(jsonData, 'custom', '2024', '', u.Id);
        CPDashboardController.getFilteredCasesNew(jsonData, '', '', '7', u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('', '', '', '');
        CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        CPDashboardController.getTotalCaseCount('', '', '', '');
        CPDashboardController.getUnprocessedCases('', '', '', '');
        CPDashboardController.getCaseDataBasedonCustomLabel('', '', '', '');
        CPDashboardController.getCaseData();         
        //CPDashboardController.dummy();
        Test.stopTest();
        
        
    }
    
    @isTest 
    static void testGetFilteredCases_NewUser2() {
        // Mock the JSON data
        String jsonData = '{"projectName": "Test Project","Registered":"","registeredCases":"","openregisteredCases":"","closedregisteredCases":"","totalopenregistered":"","totalclosedregistered":"","stage1":"","stage2":"","stage3":"","stage4":"","stage5":"","stage6":"","stage7":"","stage8":"","openstage1":"","openstage2":"","openstage3":"","openstage4":"","openstage5":"","openstage6":"","openstage7":"","openstage8":"","totalstage1rcases":"","totalstage2rcases":"","totalstage3rcases":"","totalstage4rcases":"","totalstage5rcases":"","totalstage6rcases":"","totalstage7rcases":"","unstage1":"","unstage2":"","unstage3":"","unstage4":"","unstage5":"","unstage6":"","unstage7":"","totalstage1uncases":"","totalstage2uncases":"","totalstage3uncases":"","totalstage4uncases":"","totalstage5uncases":"","totalstage6uncases":"","totalstage7uncases":"","UnRegistered":"","unregisteredCases":"","openunregisteredCases":"","closedunregisteredCases":"","Total_Un":"","totalopenunregistered":"","totalclosedunregistered":"","totalopencases":"","totalclosedcases":"","totalstage1cases":"","totalstage2cases":"","totalstage3cases":"","totalstage4cases":"","totalstage5cases":"","totalstage6cases":"","totalstage7cases":"","period":"", "new_user": ""}'; // Replace with actual User Id
        
        // Create test data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Now create the User with the ContactId set
        User u = new User(
            Alias = 'standtq',
            Email = 'standarduserq@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingNew',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standardusernew@testorg.com'
        );
        insert u;
        
        // Create a test Project__c record
        Project__c project = new Project__c(
            Name = 'Test Project'
        );
        insert project;
        
        Test.startTest();
        // Call the method with mocked data
        List<Case> filteredCases = CPDashboardController.getFilteredCasesNew(jsonData, 'custom', null, null, u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '2024', '7', u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '', '', u.Id);
        CPDashboardController.getRegisteredCaseCountByProject('Custom', '2024', '', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '2024', '7', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '', '', u.Id);
        CPDashboardController.getUnRegisteredCaseCountByProject('Custom', '2024', '', u.Id);
        CPDashboardController.getTotalCaseCount('Custom', '2024', '7', u.Id);
        CPDashboardController.getTotalCaseCount('', '', '', null);
        //CPDashboardController.getTotalCaseCount('Custom', '', '7', u.Id);
        CPDashboardController.getTotalCaseCount('Custom', '2024', '', u.Id);
        CPDashboardController.getCaseData();
        CPDashboardController.getUnprocessedCases('Custom', '2024', '7', u.Id);
        CPDashboardController.getUnprocessedCases('Custom', '', '', u.Id);
        CPDashboardController.getUnprocessedCases('Custom', '2024', '', u.Id);
        Test.stopTest();
        
        
    }
    
    
    
    @isTest
    static void testGetRegisteredCaseCountByProject() {
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
        insert cp;
        
        
        
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        Account cpaccount = [Select Id,Name,Channel_Partner__c,PersonContactId from Account where Channel_Partner__c =: cp.Id];
        system.debug('account'+cpaccount);
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName= 'New';
        c.AccountId = cpaccount.id;
        insert c;
        
       	Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User'];
        
        User usr = new User();
        usr.ProfileId = p.id;
        usr.Email = 'teststetig43646@stetig.in';
        usr.ContactId = c.id;
        usr.Username = 'Test@stetig.in.out';
        usr.Alias = 'Test';
        usr.TimeZoneSidKey = 'Asia/Kolkata';
        usr.LocaleSidKey = 'en_IN';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        usr.LastName = 'TTest';
        
        insert usr;
        
        Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
        objProjectKeyword.name='Runwal Bliss';
        objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
        insert objProjectKeyword;
        
        RM_Usernames__c obj = new RM_Usernames__c();
        obj.Name ='Adarsh';
        obj.RW_Email__c ='relationmanager@runwal.com';
        obj.User_Name__c ='test@gmail.com';
        insert obj;
        
        Contact con = new Contact();
        con.lastName = 'LastName';
        
        insert con;
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        //objAcc.RecordTypeID=recordTypeId ;
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
       
        //objAcc.OwnerId = tuser1.Id;
        insert objAcc;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        objProject.CP_Case_L1_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L2_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L3_Escalation__c = userinfo.getUserId();
        objProject.MIS_User__c = userinfo.getUserId();
        insert objProject;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objProject.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=objAcc.PersonEmail;
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.Channel_Partner_Account__c = cpaccount.Id;
        insert oppRec;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in' limit 1];
        // Create test data
        // 
        //Profile p = [SELECT Id FROM Profile WHERE Name=''];
        //User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        
        
        
        
        //User u = [SELECT Id,name FROM user where Profile.Name ='Partner Community User' and IsActive = true limit 1];
         //User u = [Select Id,name from User where Accountid limit 1];
        
        //system.runAs(u){
            Case objCase = new Case();
            objCase.Subject = 'Test Subject';
            objCase.Description = 'Test';
            objCase.Opportunity__c = oppRec.Id;
            objCase.Origin = 'Channel Partner Portal';
            objCase.Case_Category__c = 'Profile Update';
            objCase.Case_Sub_Category__c = 'Email Change';
             objCase.Status = 'Open';
            insert objCase;
            
       // }
        
        
       // system.runAs(u){
            Case objCase1 = new Case();
            objCase1.Subject = 'Test Subject';
            objCase1.Description = 'Test56';
            objCase1.Opportunity__c = oppRec.Id;
            objCase1.Origin = 'Channel Partner Portal';
            objCase1.Case_Category__c = 'Profile Update';
            objCase1.Case_Sub_Category__c = 'Email Change';
            objCase1.Current_Stage__c = 'CP-L2';
        objCase1.Status = 'Open';
            insert objCase1; 
            
       // }
        
        
            
        //Case c1 = new Case();
        //c1.Status = 'Case Closed';
        //c1.Remarks_by_RM__c = 'Closed Satisfactory';
        //c1.Id = c.id;
        //update c1;
        
        List<CPDashboardController.RegisteredProjectCaseCount> result = CPDashboardController.getRegisteredCaseCountByProject('', '', '', '');
        //List<CPDashboardController.CaseWrapper> result1 = CPDashboardController.getCaseData();
        //List<CPDashboardController.UnRegisteredProjectCaseCount> result2 = CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        //List<CPDashboardController.totalCaseCount> result3 = CPDashboardController.getTotalCaseCount('', '', '', '');
       // CPDashboardController.getUnprocessedCases('', '', '', '');
    }    @isTest
    static void testGetRegisteredCaseCountByProject1() {
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
        insert cp;
        
        Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        
        Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
        objProjectKeyword.name='Runwal Bliss';
        objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
        insert objProjectKeyword;
        
        RM_Usernames__c obj = new RM_Usernames__c();
        obj.Name ='Adarsh';
        obj.RW_Email__c ='relationmanager@runwal.com';
        obj.User_Name__c ='test@gmail.com';
        insert obj;
        
        Contact con = new Contact();
        con.lastName = 'LastName';
        
        insert con;
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        //objAcc.RecordTypeID=recordTypeId ;
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
       
        //objAcc.OwnerId = tuser1.Id;
        insert objAcc;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        objProject.CP_Case_L1_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L2_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L3_Escalation__c = userinfo.getUserId();
        objProject.MIS_User__c = userinfo.getUserId();
        insert objProject;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objProject.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=objAcc.PersonEmail;
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.Channel_Partner_Account__c = cpaccount.Id;
        insert oppRec;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in' limit 1];
        
        
        
        //system.runAs(u){
            Case objCase1 = new Case();
            objCase1.Subject = 'Test Subject';
            objCase1.Description = 'Test56';
            objCase1.Opportunity__c = null;
            objCase1.Origin = 'Channel Partner Portal';
            objCase1.Case_Category__c = 'Profile Update';
            objCase1.Case_Sub_Category__c = 'Email Change';
            objCase1.Current_Stage__c = 'CP-L2';
            objCase1.Status = 'Open';
            objCase1.ContactId = null;
            insert objCase1; 
            
        //}
        
        
            
        //Case c1 = new Case();
        //c1.Status = 'Case Closed';
        //c1.Remarks_by_RM__c = 'Closed Satisfactory';
        //c1.Id = c.id;
        //update c1;
        
        List<CPDashboardController.UnRegisteredProjectCaseCount> result = CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        //List<CPDashboardController.CaseWrapper> result1 = CPDashboardController.getCaseData();
        //List<CPDashboardController.UnRegisteredProjectCaseCount> result2 = CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        //List<CPDashboardController.totalCaseCount> result3 = CPDashboardController.getTotalCaseCount('', '', '', '');
       // CPDashboardController.getUnprocessedCases('', '', '', '');
    }
    
    
    
    
        
     @isTest
    public static void testGetUnRegisteredCaseCountByProject() {
        // Create test data
       Id ChannelPartnerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a User
        //User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in' limit 1];
        //
        // Create test data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        // Now create the User with the ContactId set
        User u = new User(
            Alias = 'standtq',
            Email = 'standarduserq11@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestingNew',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduserne122w@testorg.com'
        );
        insert u;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        objProject.CP_Case_L1_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L2_Escalation__c = userinfo.getUserId();
        objProject.CP_Case_L3_Escalation__c = userinfo.getUserId();
        objProject.MIS_User__c = userinfo.getUserId();
        insert objProject;

        	// Create test Cases
        Case case1 = new Case();
        case1.AccountId = testAccount.Id;
        case1.RecordTypeId = ChannelPartnerId;
        case1.Origin = 'Email - Channel Partner';
        case1.Subject = 'Test Case 1';
        case1.RW_Project__c = objProject.id;
        case1.Status = 'Case Closed';
        case1.SuppliedEmail = 'qww@gmail.com';
        case1.Case_Category__c = 'Profile Update';
        case1.Case_Sub_Category__c = 'Email Change';
        case1.Current_Stage__c = 'CP-L1';
            
          
        Case case2 = new Case(
            AccountId = testAccount.Id,
            RecordTypeId = ChannelPartnerId,
            Origin = 'Email - Channel Partner',
            Subject = 'Test Case 2',
            RW_Project__c = objProject.Id,
            Status = 'Open',
            SuppliedEmail = 'test@stetig.in',
            Case_Category__c = 'Profile Update',
            Case_Sub_Category__c = 'Email Change',
            Current_Stage__c = 'CP-L1'
        );
        
        

        insert new List<Case> { case1, case2 };

        // Test with different parameters
        Test.startTest();
        List<CPDashboardController.UnRegisteredProjectCaseCount> result = CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        Test.stopTest();

    }
    
    
    
}