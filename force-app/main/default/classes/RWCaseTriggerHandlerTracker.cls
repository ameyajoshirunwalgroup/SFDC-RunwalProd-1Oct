@isTest
public class RWCaseTriggerHandlerTracker 
{
    static testmethod void unittest1()
    {
        //RWTaskTriggerHandlerTracker.unitTest1();
        
        Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
        objProjectKeyword.name='Runwal Bliss';
        objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
        insert objProjectKeyword;
        
        
    }
    static testmethod void unittest2()
    {
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
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        insert oppRec;
        
        Case objCase = new Case();
        objCase.ContactId = con.Id;
        objCase.Status = 'Open';
        objCase.RW_RM_Name__c = 'Adarsh';
        objCase.Accountid = objAcc.id;
        objCase.Description = 'Description';
        objCase.RW_Project__c = objProject.id;
        objCase.Origin = 'Walk-in';
        objCase.RW_Is_Owner_changed__c = true;
        system.debug('Before@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
        insert objCase;
        objCase.RW_Is_Owner_changed__c = true; 
        objCase.RW_Project__c = null; //Added by Vinay 04-03-2025
        update objCase;
        system.debug('After@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
        
        
        Task objTask = new Task();
        objTask.subject ='Call Customer';
        objTask.whatid = objCase.id;
        objTask.status = 'open';
        objTask.Project__c = objCase.RW_Project__c;
        objTask.Priority='Normal';
        //objTask.ownerid = objCase.ownerid;
        
        insert objTask;
        
        RWCaseTriggerHandler objC = new RWCaseTriggerHandler();
        objC.createTask();
        
         ProjectUnitUpdateOnCaseBatch bw = new  ProjectUnitUpdateOnCaseBatch();
         Database.executeBatch(bw,1);
    }
    static testmethod void unittest3()
    {
        Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
        objProjectKeyword.name='Runwal Bliss';
        objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
        insert objProjectKeyword;
        
        RM_Usernames__c obj = new RM_Usernames__c();
        obj.Name ='Adarsh';
        obj.RW_Email__c ='relationmanager@runwal.com';
        obj.User_Name__c ='test@gmail.com';
        insert obj;
        
        Account objAccount = new Account();
        objAccount.Name = 'AccountName';
        
        insert objAccount;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        
        insert objProject;
        
        Case objCase = new Case();
        objCase.Status = 'Open';
        objCase.RW_RM_Name__c = 'Adarsh';
        objCase.Accountid = objAccount.id;
        objCase.Description = 'Description';
        objCase.RW_Project__c = objProject.id; 
        objCase.Origin = 'Website';
        objCase.Case_Category__c = 'Registration';
        objCase.Case_Sub_Category__c = 'Vendor Code';
        objCase.RW_Project__c = objProject.Id;
        //objCase.RW_Is_Owner_changed__c = true;
        objCase.RW_Project_Text__c = objProject.id;
        objCase.RW_Case_Comming_From_Portal__c = 'qwerty';
        system.debug('Before@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
        insert objCase;
        objCase.RW_Is_Owner_changed__c = true;
        objCase.OwnerId = userinfo.getUserId();
        
        update objCase;
        system.debug('After@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
        
        ProjectUnitUpdateOnCaseBatch bw = new  ProjectUnitUpdateOnCaseBatch();
         Database.executeBatch(bw,1);
        
        
    }
    static testmethod void unittest4()
    {
        Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
        objProjectKeyword.name='Runwal Bliss';
        objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
        insert objProjectKeyword;
        
        RM_Usernames__c obj = new RM_Usernames__c();
        obj.Name ='Adarsh';
        obj.RW_Email__c ='relationmanager@runwal.com';
        obj.User_Name__c ='test@gmail.com';
        insert obj;
        
        Account objAccount = new Account();
        objAccount.Name = 'AccountName';
        
        insert objAccount;
        
        Project__c objProject = new Project__c();
        objProject.Name = 'Project1';
        objProject.RW_Status__c = 'Active';
        
        insert objProject;
        
        Entitlement objEntitlement = new Entitlement();
        objEntitlement.Name ='Default Entitlement';
        objEntitlement.AccountId = objAccount.id;
        insert objEntitlement;

        Case_Escalation_Matrix_SLA__c sla = new Case_Escalation_Matrix_SLA__c();
        sla.Name = 'sla1';
        sla.SLA__c = 1;
        sla.Case_Type__c = 'Booking Experience';
        sla.Case_Sub_Type__c = 'Misinformed by Sales';
        sla.Customer_Lifecycle_Touchpoint__c = 'Pre-Booking Experience';
        sla.Active__c = true;
        insert sla;
        
        Case objCase = new Case();
        objCase.Status = 'Open';
        //objCase.RW_RM_Name__c = 'Adarsh';
        objCase.Accountid = objAccount.id;
        objCase.Description = 'Description';
        objCase.RW_Project__c = objProject.id; 
        objCase.Origin = 'Email';
        objCase.Subject = 'Bliss';
        //objCase.RW_Is_Owner_changed__c = false;
        objCase.RW_Project_Text__c = objProject.id;
        objCase.RW_Case_Comming_From_Portal__c = 'qwerty';
        //objCase.OwnerId =[select id from user][0].id;
        system.debug('Before@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
        system.debug('Before======objCase.OwnerId'+objCase.OwnerId);
        insert objCase;
        // objCase.RW_Is_Owner_changed__c = true;
        objCase.OwnerId = userinfo.getUserId();
        objCase.RW_RM_Name__c = 'Adarsh';
        system.debug('after======objCase.OwnerId'+objCase.OwnerId);
        update objCase;
        system.debug('After@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);

        objCase.RW_Case_Type__c = 'Complaint';
        objCase.RW_Complaint_Type__c = 'Booking Experience';
        objCase.RW_Complaint_SubType__c = 'Misinformed by Sales';
        objCase.Customer_Lifecycle_Touchpoint__c = 'Pre-Booking Experience';
        update objCase;
        
        
    }
    /*static testmethod void unittest5()
{
Project_Keywords__c objProjectKeyword = new Project_Keywords__c();
objProjectKeyword.name='Runwal Bliss';
objProjectKeyword.RW_Keyword__c ='Bliss;Runwal Bliss';
insert objProjectKeyword;

RM_Usernames__c obj = new RM_Usernames__c();
obj.Name ='Adarsh';
obj.RW_Email__c ='relationmanager@runwal.com';
obj.User_Name__c ='test@gmail.com';
insert obj;

Account objAccount = new Account();
objAccount.Name = 'AccountName';

insert objAccount;

Project__c objProject = new Project__c();
objProject.Name = 'Project1';
objProject.RW_Status__c = 'Active';

insert objProject;

Entitlement objEntitlement = new Entitlement();
objEntitlement.Name ='Default Entitlement';
objEntitlement.AccountId = objAccount.id;
insert objEntitlement;

Case objCase = new Case();
objCase.Status = 'Open';
//objCase.RW_RM_Name__c = 'Adarsh';
objCase.Accountid = objAccount.id;
objCase.Description = 'Description';
objCase.RW_Project__c = objProject.id; 
objCase.Origin = 'Email';
objCase.Subject = 'Bliss';
//objCase.RW_Is_Owner_changed__c = false;
objCase.RW_Project_Text__c = objProject.id;
objCase.RW_Case_Comming_From_Portal__c = 'qwerty';
//objCase.OwnerId =[select id from user][0].id;
system.debug('Before@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);
system.debug('Before======objCase.OwnerId'+objCase.OwnerId);
insert objCase;
// objCase.RW_Is_Owner_changed__c = true;
objCase.OwnerId = userinfo.getUserId();
objCase.RW_RM_Name__c = 'Adarsh';
objCase.Status ='Resolved';
system.debug('after======objCase.OwnerId'+objCase.OwnerId);
update objCase;
system.debug('After@@@@objCase.RW_Is_Owner_changed__c'+objCase.RW_Is_Owner_changed__c);


}*/
    
    static testmethod void CPProtal()
    {
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
       // Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        
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
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        //oppRec.Channel_Partner_Account__c = cpaccount.Id;
        insert oppRec;
        
        List<Id> acId = new List<Id>();
        //acId.add(cpaccount.id);
        //EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        //system.debug('cpAccount:::'+cpaccount);
        //User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        //system.runAs(u){
            Case objCase = new Case();
            objCase.Subject = 'Test Subject';
            objCase.Description = 'Test';
            //objCase.Opportunity__c = oppRec.Id;
            objCase.Origin = 'Channel Partner Portal';
            insert objCase; 
            
       // }
        
        List<CPDashboardController.RegisteredProjectCaseCount> result = CPDashboardController.getRegisteredCaseCountByProject('', '', '', '');
        List<CPDashboardController.UnRegisteredProjectCaseCount> result1 = CPDashboardController.getUnRegisteredCaseCountByProject('', '', '', '');
        
        
    }
    
    /*static testmethod void CPProtal2()
    {
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
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.Channel_Partner_Account__c = cpaccount.Id;
        insert oppRec;
        
        
        Case objCase = new Case();
        objCase.Subject = 'Test Subject';
        objCase.Description = 'Test';
        objCase.Opportunity__c = oppRec.Id;
        objCase.Origin = 'Email - Channel Partner';
        insert objCase; 
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        
        objCase.Case_Category__c = 'Registration';
        objCase.Case_Sub_Category__c = 'Vendor Code';
        update objCase; 
        
        
        
    }
    */
    
    @isTest
    static void locobuzzCaseTest1(){
        
        Locobuzz_Project_Spocs__c spoc = new Locobuzz_Project_Spocs__c();
        spoc.Name = 'Sales_Runwal Bliss';
        spoc.Department__c = 'Sales';
        spoc.Project_Name__c = 'Runwal Bliss';
        spoc.L1_Spoc_Name__c = 'Spoc1';
        spoc.L1_Spoc_Email__c = 'spoc1@mail.com';
        spoc.L2_Spoc_Email__c = 'spoc2@mail.com';
        spoc.L3_Spoc_Email__c = 'spoc3@mail.com';
        insert spoc;
        
        List<Case> cases = new List<Case>();
        Case cs = new Case();
        cs.Status = 'Open';
        cs.Description = 'Description';
        cs.Subject = 'Locobuzz Case';
        cs.RW_Project_Text__c = 'Runwal Bliss';
        cs.locobuzz__Locobuzz_ID__c = '12345';
        cs.Department__c = 'Sales';
        cases.add(cs);
        
        Case cs1 = new Case();
        cs1.Status = 'Open';
        cs1.Description = 'Description';
        cs1.Subject = 'Locobuzz Case';
        cs1.RW_Project_Text__c = 'Runwal Bliss';
        cs1.locobuzz__Locobuzz_ID__c = '123456';
        cs1.Department__c = 'Sales';
        cs1.Escalation_Level__c = 'Level 1';
        cases.add(cs1);
        insert cases;
        
        Test.startTest();
        LocobuzzCaseEscalation esc = new LocobuzzCaseEscalation();
        esc.execute(null);

        LocobuzzCaseAssignment.updateCaseOwner(new List<Id>{cs.Id}); // Added by Vinay 23-04-2025
        
        
         ProjectUnitUpdateOnCaseBatch bw = new  ProjectUnitUpdateOnCaseBatch();
         Database.executeBatch(bw,1);
        Test.stopTest();
    }
}