@isTest
public class CustomerPortalHomeControllerTest {
    
     // @isTest
    //private static void callCustomerPortalcontroller()
    //{
    @testSetup
    private static void setupdata(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAPInventoryCallMock());
        Test.stopTest();
        
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj;
        
        //Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];
        
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
                               ProfileId = System.label.System_Administrator_Profile_Id,
                               UserRoleId = obj.Id
                              );
        insert tuser1;
        
        //List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(tuser1)
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
            objpr.Customer_Care_Email__c = 'test@mail.com';
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
            objTower.Enable_BillDesk__c = true;
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
            oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 04-12-2025
            oppRec.RW_Closing_Head__c='Karthik Chettiar';
            oppRec.Walkin_Source__c='Direct';
            oppRec.SAP_CUstomer_Number__c='0020009875';
            oppRec.SalesOrder_Number__c ='3262627';
            oppRec.RW_Agreement_Value__c=13425663;
            oppRec.Booking_Feedback_Link__c='654864524';
            oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
            oppRec.RW_Sourcing_Manager__c='Rohit Sharma';
            oppRec.Sourcing_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 04-12-2025
            insert oppRec;
            
            
            /*Tower__c objTwr = new Tower__c();
            objTwr.SAP_Plant_Code__c = '100';
            objTwr.Name = 'Test Tower';
            objTwr.ProjectName__c = objpr.Id;
            objTwr.RW_Floor_Plan__c='test';
            insert objTwr;*/
            
            RW_Tower_Construction_Update__c objTowerCon = New RW_Tower_Construction_Update__c();
            objTowerCon.Name = 'TestAccount';
            objTowerCon.RW_Description__c = 'Test';
            objTowerCon.RW_Project__c =objpr.id;
            objTowerCon.RW_Tower__c = objTower.Id;
            insert objTowerCon;
            
            /*RW_Tower_Construction_Update__c objTowerCon1 = New RW_Tower_Construction_Update__c();
            objTowerCon1.Name = 'TestAccount';
            objTowerCon1.RW_Description__c = 'Test';
            objTowerCon1.RW_Project__c =objpr.id;
            objTowerCon1.RW_Tower__c = objTower.Id;
            insert objTowerCon1;*/
            
            
            
            Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
            objPUT.RDS_Code__c = '101';
            objPUT.RDS_Project__c = objpr.id;
            insert objPUT;
            
            Relationship_Manager__c ObjRm = new Relationship_Manager__c();
            ObjRm.Tower__c = objTower.Id;
            ObjRm.Project__c = objpr.Id;
            ObjRm.User__c = tuser1.Id;
            ObjRm.Contact_Number__c='9987654323';
            insert ObjRm; 
            
            Project_Unit__c objPUU = new Project_Unit__c();  
            objPUU.Project_Unit_Type__c = objPUT.id; 
            objPUU.TowerName__c = objTower.Id;
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
            objPUU.RW_Unit_Status__c = 'Booked';
            objPUU.RW_Booking_Date__c = Date.today();
            objPUU.RW_Param4__c = 'Test';
            objPUU.Total_RERA_Carpet_Area__c = 100;
            insert objPUU;
            
            
            RW_EOI__c eoiRecord = new RW_EOI__c();
            eoiRecord.Opportunity__c=oppRec.id;
            eoiRecord.Tower__c = objTower.id;
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
            objBking.RW_Key_handover_date__c = System.today();
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
            
            List<RW_Demand__c> demands = new List<RW_Demand__c>();
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
            //insert demandobj;
            demands.add(demandobj);
            
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
            //insert demandobj1;
            demands.add(demandobj1);
            insert demands;
            
            /*RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
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
            insert temMbr;*/
            
            //List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
            Applicant_Details__c apt1 = new Applicant_Details__c();
            apt1.Name = 'Applicant 1';
            apt1.First_Name__c='Test';
            apt1.Last_Name__c='Test2';
            apt1.Middle_Name__c='Test3';
            apt1.Permanent_Address__c = 'test address';
            apt1.Opportunity__c = oppRec.Id;
            apt1.Applicant_Number__c = 'Primary Applicant';
            apt1.Subtype_Of_Applicant__c = 'Indian National';
            apt1.Type_Of_Applicant__c= 'Individual Buyer';
            apt1.Booking__c = objBking.Id;
            apt1.DOB__c = Date.today();
            apt1.Office_Address_Line_1__c = 'Office Address Line 1';
            apt1.Mobile_Number__c = '1234567890';
            apt1.Email_Address__c = 'test@test.com';
            apt1.PancardNo__c = 'ABC123456';
            apt1.Address_Proof__c = true;
            apt1.Address_Proof_Document__c = 'Passport';
            apt1.Address_Proof_Number__c='BLYTU0987Y';
            apt1.Type_Of_Origin__c='PIO card';
            apt1.Origin_Details__c='210';
            apt1.PassportNoDetails__c='A9876543';
            apt1.Pan_Card_Number_of_Authority_Signatory__c='NJHYT5678U';
            apt1.Permanent_Address_Line_1__c='test';
            apt1.Permanent_Address_Line_2__c='test1';
            apt1.Permanent_Address_Line_3__c='test2';
            apt1.Country__c='India';
            apt1.State__c='Maharashtra';
            apt1.City__c='Mumbai';
            apt1.Pincode__c=456789;
            apt1.Organization_Name__c = 'Test';
            insert apt1;
            
            /*appList.add(apt1);
            //insert apt1;
            
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
            apt2.Email_Address__c = 'test1@test1.com';
            apt2.Address_Proof__c = true;
            apt2.Address_Proof_Document__c = 'Passport';
            apt2.gender__c = 'Female';
            apt2.Designation_picklist__c = 'Accounting';
            apt2.Occupation__c = 'Admin';
            apt2.PancardNo__c = 'ABC213456';
            appList.add(apt2);
            //insert apt2;
            
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
            apt3.Email_Address__c = 'test1@test1.com';
            apt3.Address_Proof__c = true;
            apt3.Address_Proof_Document__c = 'Passport';
            apt3.gender__c = 'Male';
            apt3.Designation_picklist__c = 'Accounting';
            apt3.Occupation__c = 'Admin';
            apt3.PancardNo__c = 'ABC213456';
            appList.add(apt3);
            //insert apt3;
            
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
            apt4.Email_Address__c = 'test1@test1.com';
            apt4.Address_Proof__c = true;
            apt4.Address_Proof_Document__c = 'Passport';
            apt4.PancardNo__c = 'ABC213456';
            appList.add(apt4);
            //insert apt4;
            
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
            apt5.Email_Address__c = 'test1@test1.com';
            apt5.Address_Proof__c = true;
            apt5.Address_Proof_Document__c = 'Passport';
            apt5.PancardNo__c = 'ABC213456';
            appList.add(apt5);
            //insert apt5;
            ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt WHERE Object_Name__c = 'Applicant_Details__c'];
            byPasstrigMappings[0].ByPassTrigger__c = true;
            insert appList;*/
            
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = objBking.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;  
            
            Document_Details__c details = new Document_Details__c();
            details.Applicant_Number__c='Primary Applicant';
            details.RW_Document_ID__c= documents[0].Id;   
            details.RW_Applicant_Details__c = apt1.Id;
            details.Booking__c=objBking.Id;
            details.RW_Document_Status__c = 'Active';
            details.RW_Type_Of_Applicant__c  ='Individual Buyer' ; 
            details.RW_Residential_Status__c ='Indian National';
            details.RW_Document_Type__c = 'PAN Card';
            insert details;
            
            /*Document_details__c details1 = new Document_details__c();
            details1.Applicant_Number__c='Primary Applicant';
            details1.RW_Document_ID__c= documents[0].Id;   
            details1.RW_Applicant_details__c = apt1.Id;
            details1.Booking__c=objBking.Id;
            details1.RW_Document_Status__c = 'Active';
            details1.RW_Type_Of_Applicant__c  ='Individual Buyer' ; 
            details1.RW_Residential_Status__c ='Indian National';
            details1.RW_Document_Type__c = 'PAN Card';
            insert details1; */   
            
            
            /*Loan__c l1 = new Loan__c();
            l1.RW_Bank_Name__c = 'ICICI Bank Ltd';
            l1.RW_Bank_Preference_1__c = 'ICICI Bank Ltd';
            l1.RW_Booking__c = objBking.id;
            l1.RW_Opportunity__c = oppRec.id;
            l1.RW_Unit_No__c = objPUU.id;
            l1.RW_Tower__c = 'A';
            l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
            l1.RW_Loan_Account_Number__c = '1234';
            l1.RW_Project_Name__c = objpr.id;
            l1.RW_Pari_Passu__c=true;
            l1.Home_Loan_Taken_From__c = 'Direct';
            insert l1;*/
            
            
            
            TDS__c tds = new TDS__c();
            tds.RW_TDS_Certificate_Number__c = '768768';
            tds.RW_TDS_Document_ID__c=documents[0].id;
            tds.Booking__c =objBking.Id;
            tds.Opportunity__c =oppRec.id;
            insert tds;
            
            /*TDS__c tds1 = new TDS__c();
            tds1.RW_TDS_Certificate_Number__c = '768768';
            tds1.RW_TDS_Document_ID__c=documents[0].id;
            tds1.Booking__c =objBking.Id;
            tds1.Opportunity__c =oppRec.id;
            insert tds1;*/
            
            RW_Payment_Details__c payDet = new RW_Payment_Details__c();
            payDet.RW_Document_Type__c = 'DE';
            payDet.RW_Payment_Amount__c = 1000;
            payDet.RW_Accounting_Document_Number__c='857565';
            payDet.RW_Bank_Reference_Number__c='77777';
            payDet.RW_Branch_Name__c='Andheri';
            payDet.RW_Clearing_Document_Number__c='8888';
            payDet.RW_Company_Code__c ='1001';
            payDet.RW_Customer_ID__c='002000056';
            payDet.RW_Payment_Date__c=System.today();
            payDet.RW_Document_Type__c='Cheque';
            payDet.Opportunity__c =oppRec.id;
            payDet.RW_Booking__c=objBking.Id;
            payDet.RW_Company_Code__c='2000';
            payDet.RW_Fiscal_Year__c='2020';
            insert payDet;
            
            
            /*RW_Payment_Details__c payDet1 = new RW_Payment_Details__c();
            payDet1.RW_Document_Type__c = 'DE';
            payDet1.RW_Payment_Amount__c = 1000;
            payDet1.RW_Accounting_Document_Number__c='857565';
            payDet1.RW_Bank_Reference_Number__c='77777';
            payDet1.RW_Branch_Name__c='Andheri';
            payDet1.RW_Clearing_Document_Number__c='8888';
            payDet1.RW_Company_Code__c ='1001';
            payDet1.RW_Customer_ID__c='002000056';
            payDet1.RW_Payment_Date__c=System.today();
            payDet1.RW_Document_Type__c='Cheque';
            payDet1.Opportunity__c =oppRec.id;
            payDet1.RW_Booking__c=objBking.Id;
            payDet1.RW_Company_Code__c='2000';
            payDet1.RW_Fiscal_Year__c='2020';
            insert payDet1;*/
            
        }        
        
        
        
    }
    
    
    
    
    @isTest
    private static void callCustomerPortalcontrollerClass(){
        Test.startTest();
        List<User> u = [Select id from User where firstname='TestUser1'];
        system.runAs(u[0]){
            System.debug('SOQL used: ' + Limits.getQueries());
            CustomerPortalHomeController.getPortalHomeData();
            System.debug('SOQL used: ' + Limits.getQueries());
            CustomerPortalHomeController.getLastLoginTime();
            System.debug('SOQL used: ' + Limits.getQueries());
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testinsertDocumentData(){
        Test.startTest();
        //List<Booking__c> bk = [Select id from Booking__c];
        //List<Opportunity> oppRec = [Select id from Opportunity];
        System.debug('SOQL used: ' + Limits.getQueries());
        List<Applicant_Details__c> appDet = [Select id, Booking__c, Opportunity__c from Applicant_Details__c where Applicant_Number__c='Primary Applicant'];
        System.debug('SOQL used: ' + Limits.getQueries());
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug('SOQL used: ' + Limits.getQueries());
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = appDet[0].Booking__c;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        //insert cdl;
        
        
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('applicantType','Individual Buyer');
        DocDetails.put('residentialStatus','Indian National');
        DocDetails.put('oppRecId',appDet[0].Opportunity__c);
        DocDetails.put('bookingId',appDet[0].Booking__c);
        DocDetails.put('applicantId',appDet[0].Id);
        DocDetails.put('uploadType','KYC');
        DocDetails.put('documentType','SAMPLE PAN CARD');
        DocDetails.put('documentId',documents[0].Id);
        System.debug('SOQL used: ' + Limits.getQueries());
        CustomerPortalHomeController.insertDocumentData(DocDetails);
        System.debug('SOQL used: ' + Limits.getQueries());
        CustomerPortalHomeController.insertDocumentLoanData(DocDetails);
        
        Map<String,String> TdsDocDetails = new Map<String,String>();
        TdsDocDetails.put('tdscertificateNumber','867675');
        TdsDocDetails.put('tdsamount','6547');
        TdsDocDetails.put('oppId',appDet[0].Opportunity__c);
        TdsDocDetails.put('bookingId',appDet[0].Booking__c);
        TdsDocDetails.put('tdsdocumentId',documents[0].Id);
        
        CustomerPortalHomeController.createTDSRecord(TdsDocDetails); 
        
        CustomerPortalHomeController.getKYCFiles(appDet[0].Booking__c,'Primary Applicant');
        Test.stopTest();
    }
    
    
    @isTest
    private static void testPDFController(){
        Test.startTest();
        List<Booking__c> bk = [Select id from Booking__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        Test.setMock(WebServiceMock.class, new SAPPdfCalloutMock());
        
        //List<RW_Demand__c> demand = [SELECT Id, Name,RW_Billing_Document_Number__c, RW_Demand_Milestone__c,RW_Customer_Number__c FROM RW_Demand__c];
        //PDFController.getdemandPdf(demand[0].Id);
        //PDFController.getdemandDetails(demand[0].Id);
        
        //List<RW_Payment_Details__c> receipt = [SELECT Id, Name,RW_Accounting_Document_Number__c, RW_Fiscal_Year__c, RW_Company_Code__c FROM RW_Payment_Details__c];
        //PDFController.getreceiptPdf(receipt[0].Id);
        
        //PDFController.getinterestLedgerPdf('134432455','2000');
        //PDFController.getinttLedgerPdf(bk[0].Id);
        //PDFController.getagreementPdf('35354');
        //PDFController.getCustomerLedgerPdf('134432455','2000');
        //PDFController.getCustLedgerPdf(bk[0].Id);
        //PDFController.sendDemandEmail(new List<Id>{demand[0].Id},'45qerrwre');
        CustomerPortalHomeController.getIntertestLedgerPDF('134432455', '2000');
        CustomerPortalHomeController.getCustomerLedgerPdf('134432455', '2000');
        CustomerPortalHomeController.getAgreementPDF('134432455');
        CustomerPortalHomeController.getEOIPdf(eoiRecord.Id);
        CustomerPortalHomeController.getBookingPdf(bk[0].Id);
        Test.stopTest();
    }
    
    
    @isTest
    private static void testinsertCase(){
        Test.startTest();
        List<Opportunity> oppRec = [Select id,RW_Project__c from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        List<Booking__c> bk = [Select id,Unit_No__r.RW_Param4__c from Booking__c];
        oppRec[0].StageName ='Unit Booked';
        update oppRec[0];
        Map<String,String> Details = new Map<String,String>();
        Details.put('bookingId',bk[0].Id);
        Details.put('projectId',oppRec[0].RW_Project__c);
        Details.put('unitnumber',bk[0].Unit_No__r.RW_Param4__c);
        String RMName = '';
        Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
        for(String rmnames : mapOfCustomSetting.keySet()){
            RMName = rmnames;
            break;
        }
        Case_Escalation_Matrix_SLA__c sla = new Case_Escalation_Matrix_SLA__c();
        sla.Name = 'Test';
        sla.Case_Type__c = 'QR Code / IVR';
        sla.Customer_Lifecycle_Touchpoint__c = 'Self-Service Options';
        insert sla;
        
        List<User> u = [Select id,AccountId,ContactId from User where firstname='TestUser1'];
        Case caseRec = new Case();
        caseRec.RW_Case_Type__c='Complaint';
        caseRec.Customer_Lifecycle_Touchpoint__c = 'Self-Service Options';
        caseRec.RW_Complaint_Type__c='QR Code / IVR';
        caseRec.RW_Complaint_SubType__c = 'Incorrect information on IVR';
        caseRec.AccountId =u[0].AccountId;
        caseRec.Opportunity__c = oppRec[0].Id;
        if(RMName != null && RMName !='')
            caseRec.RW_RM_Name__c=RMName;
        Case caseRec1 = new Case();
        caseRec1.RW_Case_Type__c='Complaint';
        caseRec1.Customer_Lifecycle_Touchpoint__c = 'Post-Possession';
        caseRec1.RW_Complaint_Type__c='Post-Possession Complaints';
        caseRec1.RW_Complaint_SubType__c = 'Possession Pending complaints';
        caseRec1.AccountId =u[0].AccountId;
        caseRec1.Origin ='Email';
        if(RMName != null && RMName !='')
            caseRec1.RW_RM_Name__c=RMName;
        insert caseRec1;
        
        
        system.runAs(u[0]){
            CustomerPortalHomeController.insertCase(caseRec, Details);
        }
        Test.stopTest();
    }
    
    
    @isTest
    private static void testinsertChangeRequestCase(){
        Test.startTest();
        List<Booking__c> bk = [Select id from Booking__c];
        Map<String,String> Details = new Map<String,String>();
        Details.put('bookingId',bk[0].Id);
        
        Case caseRec = new Case();
        caseRec.RW_Case_Type__c='Complaint';
        caseRec.RW_Complaint_Type__c='Post Possession Related';
        caseRec.RW_Complaint_SubType__c = 'Runwal App Related';
        caseRec.Origin ='Email';

        CustomerPortalHomeController.insertChangeRequestCase(caseRec, Details);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetBankPicklists(){
        Test.startTest();
        List<Project__c> proj = [Select id from Project__c];
        
        RW_Bank_Details__c bankDet = new RW_Bank_Details__c();
        bankDet.RW_Branch_Name__c='Andheri';
        bankDet.RW_Banks_Name__c='ICICI Bank Ltd';
        bankDet.RW_Project_Name__c=proj[0].Id;
        insert bankDet;
        
        
        RW_Bank_Details__c bankDet1 = new RW_Bank_Details__c();
        bankDet1.RW_Branch_Name__c='Mulund';
        //bankDet1.RW_Banks_Name__c='Yes Bank Ltd';
        bankDet1.RW_Project_Name__c=proj[0].Id;
        bankDet1.RW_Email_Id__c='c@gmail.com';
        insert bankDet1;
        
        RW_Bank_Details__c bankDet2 = new RW_Bank_Details__c();
        bankDet2.RW_Branch_Name__c='Mulund';
        bankDet2.RW_Banks_Name__c='ICICI Bank Ltd';
        bankDet2.RW_Project_Name__c=proj[0].Id;
        bankDet2.RW_Email_Id__c='c@gmail.com';
        insert bankDet2;
        
        CustomerPortalHomeController.getBankPicklists(proj[0].Id);
        CustomerPortalUtility.getBankDetailsRecords(new Set<Id>{proj[0].Id});
        CustomerPortalHomeController.videos(); 
        Test.stopTest();
    }
    
    @isTest
    private static void testcreateLoanRecord(){
        
        Test.startTest();
        List<Opportunity> oppRec = [Select id from Opportunity];
        List<Booking__c> bk = [Select id from Booking__c];
        List<Project__c> proj = [Select id from Project__c];
        
        RW_Bank_Details__c bankDet2 = new RW_Bank_Details__c();
        bankDet2.RW_Branch_Name__c='Mulund';
        bankDet2.RW_Banks_Name__c='ICICI Bank Ltd';
        bankDet2.RW_Project_Name__c=proj[0].Id;
        insert bankDet2;
        
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('pancardno','UYTRE4567T');
        DocDetails.put('aadharno','876543456789');
        DocDetails.put('uploadedSalarySlip','UYTRE4567T');
        DocDetails.put('uploadedITR','UYTRE4567T');
        DocDetails.put('uploadedBankStatement','UYTRE4567T');
        DocDetails.put('Bankname','ICICI Bank Ltd');
        DocDetails.put('bookingId',bk[0].Id);
        DocDetails.put('projectID',proj[0].Id);
        DocDetails.put('branchname','Mulund');
        DocDetails.put('oppId',oppRec[0].Id);
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'SalarySLip',
          PathOnClient = 'SalarySLip.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        DocDetails.put('uploadedSalarySlipId',documents[0].Id);
        
        ContentVersion contentVersion1 = new ContentVersion(
          Title = 'ITR',
          PathOnClient = 'ITR.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title='ITR'];
        
        DocDetails.put('uploadedITRId',documents1[0].Id);
        
        ContentVersion contentVersion2 = new ContentVersion(
          Title = 'BankStatement',
          PathOnClient = 'BankStatement.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title='BankStatement'];
        
        DocDetails.put('uploadedBankStatementId',documents2[0].Id);
        
        
        ContentVersion contentVersion3 = new ContentVersion(
          Title = 'PAN',
          PathOnClient = 'PAN.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion3;    
        List<ContentDocument> documents3 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title='PAN'];
        
        DocDetails.put('uploadedPANDocumentID',documents3[0].Id);
        
         ContentVersion contentVersion4 = new ContentVersion(
          Title = 'Aadhar',
          PathOnClient = 'Aadhar.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion4;    
        List<ContentDocument> documents4 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title='Aadhar'];
        
        DocDetails.put('uploadedAadharCardDocumentID',documents4[0].Id);
        CustomerPortalHomeController.createLoanRecord(DocDetails);
        Test.stoptest();
        
    }
    
    @isTest
    private static void testGetBillDeskData(){
        Test.startTest();
        Booking__c bk = [Select id, Opportunity__c, Unit_No__r.TowerName__c, Unit_No__c  from Booking__c LIMIT 1];
        //List<Opportunity> oppRec = [Select id from Opportunity];
        //List<Project_Unit__c> proj=[Select id from Project_Unit__c];
        //List<Tower__c> tower= [Select id from Tower__c];
        String amount='100000';
        
        
        Map<String,String> DetailMap=new Map<String,String>();         
        DetailMap.put('bookingId', bk.Id);
        DetailMap.put('OpportunityId', bk.Opportunity__c);
        DetailMap.put('towerId', bk.Unit_No__r.TowerName__c);
        DetailMap.put('Amount', amount);
        DetailMap.put('TypeOfAmount','Normal');
        DetailMap.put('ProjectUnit',bk.Unit_No__c);
        DetailMap.put('ButtonType','SinglePayment');
        
        CustomerPortalHomeController.getBillDeskData(DetailMap);
        Test.stopTest();
        
    }
    @isTest
    private static void testSaveBillDeskData(){
        Test.startTest();
        Receipt__c rec = [Select Id,Name From Receipt__c limit 1 ];
        Tower__c t=[Select id from tower__c limit 1];
        String name=rec.Name;
        Map<String,String>  SaveDetailMap=new Map<String,String>();
        SaveDetailMap.put('towerId',t.id);
        SaveDetailMap.put('msg','BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|8E2A7079253D64E1954BED58D6CB089BBD85CFA138FE7E83A08C1328C4706F28' );
        CustomerPortalHomeController.saveBillDeskData(SaveDetailMap);  
        Test.stopTest();
    }
    
    @isTest
    private static void testupdateLoanRecord()
    {
        Test.startTest();
        //List<Loan__c> loan = [Select id,RW_Bank_Name__c,RW_Booking__c,RW_Opportunity__c,RW_Unit_No__c,RW_Tower__c,RW_Loan_Record_Status__c,RW_Loan_Account_Number__c,RW_Project_Name__c from Loan__c];
        Booking__c bkg = [SELECT Id, Opportunity__c, Unit_No__c, Project__c FROM Booking__c LIMIT 1];
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'ICICI Bank Ltd';
        l1.RW_Bank_Preference_1__c = 'ICICI Bank Ltd';
        l1.RW_Booking__c = bkg.id;
        l1.RW_Opportunity__c = bkg.Opportunity__c;
        l1.RW_Unit_No__c = bkg.Unit_No__c;
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.RW_Project_Name__c = bkg.Project__c;
        l1.RW_Pari_Passu__c=true;
        l1.Home_Loan_Taken_From__c = 'Direct';
        insert l1;
        
         ContentVersion contentVersion = new ContentVersion(
          Title = 'SalarySLip',
          PathOnClient = 'SalarySLip.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('loanId',l1.Id);
        DocDetails.put('documentId',documents[0].id);
        
        CustomerPortalHomeController.updateLoanRecord(DocDetails);
        Test.stoptest();
    }
    
   
}