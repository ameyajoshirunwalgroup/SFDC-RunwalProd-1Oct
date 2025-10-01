@isTest
public class ReferralIOMControllerTest {

    // helper to create minimal booking with required fields
    private static Booking__c createBooking(Boolean referralCreated, String regDueStatus, String source) {
      
         Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        list<Tower__c> t = TestDataFactory.createTowers(1,p.Id);
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
        // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        // List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
        Profile pr = [Select Id,Name from Profile where Name = 'NRI Sales Manager'];
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User u1 = new User(LastName = 'Test',
                           FirstName='Test1 User',
                           Alias = 'tstU1',
                           Email = 'testUsr1@stetig.in',
                           Username = 'testUsr1@stetig.in',
                           ProfileId = profileId.id,
                           CTI_Agent_ID__c = 'test.test1',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           EmailEncodingKey = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US');
        insert u1;
        
        User u = new User();
        u.Username = 'test123@stetig.in';
        u.LastName = 'Test';
        u.ManagerId = u1.Id;
        u.Email = 'test@stetig.in';
        u.Alias = 'Test';
        u.IsActive =true;
        u.EmailEncodingKey='UTF-8';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LanguageLocaleKey='en_US';
        if(pr.Id != null){
            u.ProfileId = pr.Id;
        }
        insert u;
        Opportunity o = new Opportunity(Name = 'Opp-1',RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Unit Booked', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
        insert o;
        list<Opportunity> oList = new list<Opportunity>{o};
            system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
        
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5)
        );
        insert task;
        
        Project__c p1 = new Project__c();
        p1.Id = p.Id;
        p1.CRM_MIS_Head__c = userinfo.getUserId();
        p1.CRMHead__c = userinfo.getUserId();
        p1.Home_Loan_Email__c = UserInfo.getUserEmail();
        update p1;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = p.id;
        insert objPUT;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = t[0].Id;
        ObjRm.Project__c = p.Id;
        // ObjRm.User__c = u.Id;
        ObjRm.User__c = UserInfo.getUserId();
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;
        objPUU.TowerName__c = t[0].Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = p.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.Relationship_Manager__c=   ObjRm.id;
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = p.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = o.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 10000000;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.MLCP_Additional__c = null;
        q.Agreement_Value_for_brokers__c = 10000000;
        insert q;   
        
        Booking__c b1 = new Booking__c();
        b1.Customer__c = o.Id;
        b1.Project__c = p.Id;
        b1.Opportunity__c = o.Id;
        b1.Unit_No__c = objPUU.id;
        b1.Quotation__c = q.Id;
        b1.Booking_Date__c = Date.today();
        b1.Account__c = acc.Id;
        b1.Type_of_Client__c = 'Local';
        b1.Status__c = 'Booking Confirmed';
        b1.Source_of_Booking__c = 'Referral';
        b1.Sub_Source__c = 'Existing client reference';
        //b1.Registration_Status__c = 'Due';
        b1.Referral_Passback_Amount__c= 100000;
        //b1.Original_Agreement_Value__c = 1000000;
        b1.Referral_Discount_Amount__c = 100000;
        //b1.Referral_Passback__c = 1;
        b1.X20_Received_Date__c = system.today();
        b1.Customer_Reference_Opportunity__c = o.id;
        b1.RW_Registration_Done__c = 'Yes';
        b1.RW_Registration_Date__c = system.today()-10;
        b1.Exclude_From_Brokerage_Batch__c = false;
        //b.X5_Received__c = true;
        b1.RW_Total_Receipt_Amount_Received__c = 3000000;
        b1.Allotment_Premium__c = 10000000;
        //b1.RW_Registration_Status__c = 'Registration Completed';
        b1.RW_Registration_Type__c = 'Offline Registration';
        b1.RW_Expected_Registration_Date__c = system.today();
        b1.RW_Registration_Done__c = 'No';
        b1.Registration_Due_Status__c = regDueStatus;
        b1.Referral_IOM_Created_checkbox__c = true;
        insert b1;
        return b1;
    }

    @isTest
    static void testConstructorReferralDue() {
        Booking__c b = createBooking(false, 'Due', 'Referral');

        Test.startTest();
        PageReference pageRef = Page.ReferralIOMPage; // create a dummy VF page named ReferralIOMPage and assign controller
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', b.Id);

        ReferralIOMController ctrl = new ReferralIOMController();
        Test.stopTest();
    }

    @isTest
    static void testConstructorAlreadyCreated() {
        Booking__c b = createBooking(true, 'Due', 'Referral');

        Test.setCurrentPage(Page.ReferralIOMPage);
        ApexPages.currentPage().getParameters().put('id', b.Id);

        ReferralIOMController ctrl = new ReferralIOMController();
    }

    @isTest
    static void testSaveAndNavigation() {
        Booking__c b = createBooking(false, 'Due', 'Referral');

        Test.setCurrentPage(Page.ReferralIOMPage);
        ApexPages.currentPage().getParameters().put('id', b.Id);

        ReferralIOMController ctrl = new ReferralIOMController();
         PageReference saveRef = ctrl.save();
         PageReference pdfRef = ctrl.Generatepdf();
        PageReference backRef = ctrl.goBack();
    }

    @isTest
    static void testINFormatUtility() {
        Decimal money = 1234567.89;
        String result = ReferralIOMController.INFormat(money);
    }
}