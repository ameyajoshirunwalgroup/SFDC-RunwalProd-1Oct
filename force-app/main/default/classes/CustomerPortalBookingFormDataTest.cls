@isTest
public class CustomerPortalBookingFormDataTest 
{
	 @testSetup
    
    private static void setupdata() 
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAPInventoryCallMock());
        Test.stopTest();
            
        
            UserRole obj=new UserRole(Name= 'ABC'); 
			insert obj;
            
            Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

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
                            ProfileId = p1.id,
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
        
        Profile p = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
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
                              ProfileId = p.id
                             );
        insert tuser;
        system.debug('*1*');
        //Inserting Project
          Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
        insert objpr;
        system.debug('*2*');
        //Inserting Referral
        RW_Referral__c objRef = New RW_Referral__c();
        objRef.Account__c = objAcc.Id;
        objRef.RW_First_Name__c ='TestAccount11';
        objRef.RW_Last_Name__c ='TestAccount22';
        objRef.RW_Email_Address__c = 'wc@email.com';
        objRef.RW_Project__c = 'Runwal Bliss';
        objRef.RW_Contact_Phone__c= '9876543212';
        objRef.RW_Mode__c= 'Customer portal';
        insert objRef;
        system.debug('*3*');
        //Inserting Tower
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        system.debug('*4*');
        //Inserting Tower Construction Update
        
        system.debug('*5*');
        //Inserting Opportunity
        //
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=acc.PersonEmail;
        //oppRec.StageName='Qualification';
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = acc.Id;
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
         oppRec.RW_Sourcing_Manager__c='Rohit Sharma';
         
        insert oppRec;
        
        
        Tower__c objTwr = new Tower__c();
        objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        objTwr.RW_Floor_Plan__c='test';
        insert objTwr;
        
        RW_Tower_Construction_Update__c objTowerCon = New RW_Tower_Construction_Update__c();
        objTowerCon.Name = 'TestAccount';
        objTowerCon.RW_Description__c = 'Test';
        objTowerCon.RW_Project__c =objpr.id;
        objTowerCon.RW_Tower__c = objTwr.Id;
        insert objTowerCon;
            
        RW_Tower_Construction_Update__c objTowerCon1 = New RW_Tower_Construction_Update__c();
        objTowerCon1.Name = 'TestAccount';
        objTowerCon1.RW_Description__c = 'Test';
        objTowerCon1.RW_Project__c =objpr.id;
        objTowerCon1.RW_Tower__c = objTwr.Id;
        insert objTowerCon1;
          
            
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTwr.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser.Id;
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTwr.Id;
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
        objPUU.Relationship_Manager__c = ObjRm.Id;
        objPUU.Carpet_Area__c = 786;
        insert objPUU;
        
		            
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRec.id;
        eoiRecord.Tower__c = objTwr.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Confirmed'; 
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;    
            
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
        
        
        
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Customer__c =oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Sales_Manager__c= tuser.Id;
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Token_Amount__c=2000;
        objBking.Allotment_Premium__c=3000;
         objBking.Source_of_Booking__c='Direct';
          objBking.Carpet_Area__c=23;
          objBking.RW_Registration_Date__c=System.today();
        insert objBking;
        
            InspectionAndPossession__c insp = new InspectionAndPossession__c();
        insp.Booking__c= objBking.Id;
        insp.Opportunity__c=oppRec.Id;
        insp.RW_SAP_Code__c='68767889';
            
        insert insp;
            
            
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
        r1.Booking__c=objBking.Id;
        insert r1;
            
        RW_Demand__c demandobj = new RW_Demand__c();
        demandobj.Due_Date__c = system.today();
        demandobj.Booking__c = objBking.Id;
        
        demandobj.RW_Billing_Document_Number__c='097654567';
        demandobj.RW_Customer_Number__c='002000056';
        demandobj.RW_Demand_Amount__c=2000;
        demandobj.Demand_Date__c= system.today();
        demandobj.RW_Demand_Status__c='Paid';
        demandobj.RW_ODN_Number__c='6666';
        demandobj.RW_Demand_Milestone__c='6437';
        
            
        insert demandobj;
            
        RW_Demand__c demandobj1 = new RW_Demand__c();
        demandobj1.Due_Date__c = system.today();
        demandobj1.Booking__c = objBking.Id;
        
        demandobj1.RW_Billing_Document_Number__c='097654567';
        demandobj1.RW_Customer_Number__c='002000056';
        demandobj1.RW_Demand_Amount__c=2000;
        demandobj1.Demand_Date__c= system.today();
        demandobj1.RW_Demand_Status__c='Paid';
        demandobj1.RW_ODN_Number__c='6666';
        demandobj1.RW_Demand_Milestone__c='6437';
        
            
        insert demandobj1;
            
            
        RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
        wcObj.RW_Booking__c = objBking.Id;
        wcObj.RW_Welcome_Call_Status__c = 'Accept';
        //wcObj.Name = 'Test';
        wcObj.RW_Is_welcome_Letter_sent__c = True;
        wcObj.RW_Welcome_Call_Completed__c = false;
        wcObj.RW_Welcome_Call_Initiation_date__c = null;
        wcObj.RW_Welcome_Call_Accepted_date__c = system.today();
        wcObj.RW_Discrepancy_list_shared_via_email__c = True;
        wcObj.RM_email__c = 'mounika.ramagoni@in.ey.com';
        
        insert wcObj;
        
        RW_Welcome_Call_Remarks__c welRema = new RW_Welcome_Call_Remarks__c();
        welRema.RW_Welcome_Call__c = wcObj.Id;
        welRema.RW_Remarks__c = 'Remarks: remarks- remarks';
        insert welRema;
        
        
        Team__c tem = new Team__c();
        tem.Name = 'CRM Lead';
        tem.Project__c = objpr.Id;
        tem.Team_Type__c= 'Team Lead';
        insert tem;
        
        Team_Members__c temMbr = new Team_Members__c();
        temMbr.Team__c = tem.Id;
        temMbr.User__c = tuser.Id;
        temMbr.User_Active__c  =true;
        insert temMbr;
       
    
    }
    }
    
    
    
      @isTest
    private static void testpdfDataClass()
    {
		List<Booking__c> bk = [Select id from Booking__c];
        Test.StartTest(); 
        PageReference pageRef = Page.CustomerPortalBookingForm; // Add your VF page Name here
  		//pageRef.getParameters().put('eoiId', eoiRecord.Id);
  		Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', bk[0].Id);
        CustomerPortalBookingFormData pd = new CustomerPortalBookingFormData();
        Test.stopTest();
    }
}