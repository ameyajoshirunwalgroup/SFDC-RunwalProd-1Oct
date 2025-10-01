@isTest
public class IVRFlowTest {
	@isTest
    public static void test1(){
        UserRole objRole=new UserRole(Name= 'ABC'); 
		insert objRole;
        
		Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser',
                                lastName = 'TestUser',
                                email = uniqueName + '@gmail' +'.com',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = p.id,
                              	UserRoleId = objRole.Id
                                );
        insert tuser;
        
        List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0]){
            String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeID=recordTypeId ;
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
            a.OwnerId = tuser.Id;
            insert a;
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :a.Id];
            
            Profile p1 = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
            String orgId1 = UserInfo.getOrganizationId();
            String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName1 = orgId + dateString + randomInt;
            User tuser1 = new User(  firstname = 'TestUser1',
                                  lastName = 'TestUser2',
                                  email = uniqueName1 + '@gmail' +'.com',
                                  contactId=acc.PersonContactId,
                                  Username = uniqueName1 + '@test1' + orgId1 + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = uniqueName1.substring(18, 23),
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  ProfileId = p1.id
                                 );
            insert tuser1;
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Sales_Site_Head__c = tuser1.Id;
            objpr.SAPMaterial_Code__c = '1211';
            objpr.Project_CRM_Lead__c = tuser1.Id;
            objpr.RW_Project_Location_Videos_Link__c='test';
            objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
            insert objpr;
            
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
            
             Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            objPU1.UnitNo__c ='TestFive';
            objPU1.RW_Unit_status__c='Available';
            objPU1.RW_Booking_Date__c = system.Today();
            objPU1.Actual_Area_value__c = 2218;
            objPU1.New_Floor__c = '8';
            objPU1.RW_Param4__c ='A-4546';
            objPU1.TowerName__c = t.Id;
            objPU1.Carpet_Area__c = 10;
            objPU1.Saleable_Area__c=2218;
            objPU1.Single_car_park_Earmarked__c = 0;
            objPU1.Single_Open_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.Tandem_car_park_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.MLCP_Earmarked__c = 0;
            objPU1.Stack__c = 0;
            insert objPU1;
            
            Opportunity oppRec= new Opportunity();
            oppRec.RW_Project__c=objpr.id;
            oppRec.Name='Test 1';
            oppRec.RW_Email__c=a.PersonEmail;
            oppRec.StageName='Unit Booked';
            oppRec.CloseDate=system.today();
            oppRec.Status__c ='Active';
            oppRec.AccountId = a.Id;
            oppRec.Sales_Manager__c = 'SM2@g.com';
            oppRec.Sourcing_Manager__c='Aniket Sapre';
            oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
            oppRec.RW_Sales_Associate__c='Karthik Chettiar';
            oppRec.RW_Closing_Head__c='Karthik Chettiar';
            oppRec.Walkin_Source__c='Direct';
            oppRec.SAP_Customer_Number__c='0020006618';
            oppRec.SalesOrder_Number__c='3010005457';
            oppRec.RW_Mobile_No__c = '1234567890';
            insert oppRec;
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPU1.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = oppRec.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            //q.Tandem_car_park_Additional__c = 1;
            //q.Tandem_Open_Additional__c= 1;
            //q.Single_car_park_Additional__c= 1;
            //q.Single_Open_Additional__c = 1;
            //q.Stack_Additional__c = 1;
            //q.MLCP_Additional__c = null;
            insert q;
            
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPU1.id;
            objBking.Quotation__c = q.Id;
            objBking.Booking_Date__c = Date.today();
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_Total_Receipt_Amount_Received__c = 1000;
            objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
            objBking.Primary_Applicant_Email__c = 'test@mail.com';
            insert objBking;
            
            Test.startTest();
            
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            req1.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/ivr'; 
            req1.httpMethod = 'Get';
            req1.params.put('type', 'mobile');
            req1.params.put('number', oppRec.RW_Mobile_No__c);
            req1.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req1;
            RestContext.response = res1;
            IVRFlow.doGet();
            
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/ivr'; 
            req2.httpMethod = 'Get';
            req2.params.put('type', 'crn');
            req2.params.put('number', oppRec.SAP_Customer_Number__c);
            req2.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req2;
            RestContext.response = res2;
            IVRFlow.doGet();
            
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Booking Confirmation Letter', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Account Statement', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Payment Online', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            //IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Loan Process', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            

            Test.stopTest();
    }
}
    
    @isTest
    public static void test2(){
        UserRole objRole=new UserRole(Name= 'ABC'); 
		insert objRole;
        
		Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser',
                                lastName = 'TestUser',
                                email = uniqueName + '@gmail' +'.com',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = p.id,
                              	UserRoleId = objRole.Id
                                );
        insert tuser;
        
        List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0]){
            String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeID=recordTypeId ;
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
            a.OwnerId = tuser.Id;
            insert a;
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :a.Id];
            
            Profile p1 = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
            String orgId1 = UserInfo.getOrganizationId();
            String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName1 = orgId + dateString + randomInt;
            User tuser1 = new User(  firstname = 'TestUser1',
                                  lastName = 'TestUser2',
                                  email = uniqueName1 + '@gmail' +'.com',
                                  contactId=acc.PersonContactId,
                                  Username = uniqueName1 + '@test1' + orgId1 + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = uniqueName1.substring(18, 23),
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  ProfileId = p1.id
                                 );
            insert tuser1;
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Sales_Site_Head__c = tuser1.Id;
            objpr.SAPMaterial_Code__c = '1211';
            objpr.Project_CRM_Lead__c = tuser1.Id;
            objpr.RW_Project_Location_Videos_Link__c='test';
            objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
            insert objpr;
            
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
            
             Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            objPU1.UnitNo__c ='TestFive';
            objPU1.RW_Unit_status__c='Available';
            objPU1.RW_Booking_Date__c = system.Today();
            objPU1.Actual_Area_value__c = 2218;
            objPU1.New_Floor__c = '8';
            objPU1.RW_Param4__c ='A-4546';
            objPU1.TowerName__c = t.Id;
            objPU1.Carpet_Area__c = 10;
            objPU1.Saleable_Area__c=2218;
            objPU1.Single_car_park_Earmarked__c = 0;
            objPU1.Single_Open_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.Tandem_car_park_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.MLCP_Earmarked__c = 0;
            objPU1.Stack__c = 0;
            insert objPU1;
            
            Opportunity oppRec= new Opportunity();
            oppRec.RW_Project__c=objpr.id;
            oppRec.Name='Test 1';
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
            oppRec.SAP_Customer_Number__c='0020006618';
            oppRec.SalesOrder_Number__c='3010005457';
            oppRec.RW_Mobile_No__c = '1234567890';
            insert oppRec;
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPU1.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = oppRec.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            //q.Tandem_car_park_Additional__c = 1;
            //q.Tandem_Open_Additional__c= 1;
            //q.Single_car_park_Additional__c= 1;
            //q.Single_Open_Additional__c = 1;
            //q.Stack_Additional__c = 1;
            //q.MLCP_Additional__c = null;
            insert q;
            
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPU1.id;
            objBking.Quotation__c = q.Id;
            objBking.Booking_Date__c = Date.today();
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_Total_Receipt_Amount_Received__c = 1000;
            objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
            objBking.RW_Total_TDS_Outstanding__c = 0;
            objBking.Primary_Applicant_Email__c = 'test@mail.com';
            insert objBking;
            
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
            
            RW_Demand_Item__c dmid= new RW_Demand_Item__c();
            dmid.RW_Demand_Item_Amount__c =10000;
            dmid.RW_Demand__c = demandobj.id;
            dmid.RW_GST_Amount__c = 1000;
            dmid.RW_Legacy_Amount_Paid__c = 6000;
            dmid.RW_Legacy_Demand__c = true;
            dmid.Total_Demand_Item_Amount_Paid__c = 6000;
            insert dmid;
            
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
            
            Test.startTest();
            
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Latest Demand Letter', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Last 3 Demand Letters', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Latest Payment Receipt', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            //IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Last 3 Payment Receipts', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            
            
            IVROnlinePay pay = new IVROnlinePay();
            pay.crn = oppRec.SAP_Customer_Number__c;
            pay.successPage();
            pay.pay();
            pay.gstPay();
            pay.demandPay();
            
            Test.stopTest();
    }
}
    
    @isTest
    public static void test3(){
        UserRole objRole=new UserRole(Name= 'ABC'); 
		insert objRole;
        
		Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser',
                                lastName = 'TestUser',
                                email = uniqueName + '@gmail' +'.com',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = p.id,
                              	UserRoleId = objRole.Id
                                );
        insert tuser;
        
        List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0]){
            String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeID=recordTypeId ;
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
            a.OwnerId = tuser.Id;
            insert a;
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :a.Id];
            
            Profile p1 = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
            String orgId1 = UserInfo.getOrganizationId();
            String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName1 = orgId + dateString + randomInt;
            User tuser1 = new User(  firstname = 'TestUser1',
                                  lastName = 'TestUser2',
                                  email = uniqueName1 + '@gmail' +'.com',
                                  contactId=acc.PersonContactId,
                                  Username = uniqueName1 + '@test1' + orgId1 + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = uniqueName1.substring(18, 23),
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  ProfileId = p1.id
                                 );
            insert tuser1;
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Sales_Site_Head__c = tuser1.Id;
            objpr.SAPMaterial_Code__c = '1211';
            objpr.Project_CRM_Lead__c = tuser1.Id;
            objpr.RW_Project_Location_Videos_Link__c='test';
            objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
            insert objpr;
            
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
            
             Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            objPU1.UnitNo__c ='TestFive';
            objPU1.RW_Unit_status__c='Available';
            objPU1.RW_Booking_Date__c = system.Today();
            objPU1.Actual_Area_value__c = 2218;
            objPU1.New_Floor__c = '8';
            objPU1.RW_Param4__c ='A-4546';
            objPU1.TowerName__c = t.Id;
            objPU1.Carpet_Area__c = 10;
            objPU1.Saleable_Area__c=2218;
            objPU1.Single_car_park_Earmarked__c = 0;
            objPU1.Single_Open_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.Tandem_car_park_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.MLCP_Earmarked__c = 0;
            objPU1.Stack__c = 0;
            insert objPU1;
            
            Opportunity oppRec= new Opportunity();
            oppRec.RW_Project__c=objpr.id;
            oppRec.Name='Test 1';
            oppRec.RW_Email__c=a.PersonEmail;
            oppRec.StageName='Unit Booked';
            oppRec.CloseDate=system.today();
            oppRec.Status__c ='Active';
            oppRec.AccountId = a.Id;
            oppRec.Sales_Manager__c = 'SM2@g.com';
            oppRec.Sourcing_Manager__c='Aniket Sapre';
            oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
            oppRec.RW_Sales_Associate__c='Karthik Chettiar';
            oppRec.RW_Closing_Head__c='Karthik Chettiar';
            oppRec.Walkin_Source__c='Direct';
            oppRec.SAP_Customer_Number__c='0020006618';
            oppRec.SalesOrder_Number__c='3010005457';
            oppRec.RW_Mobile_No__c = '1234567890';
            insert oppRec;
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPU1.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = oppRec.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            //q.Tandem_car_park_Additional__c = 1;
            //q.Tandem_Open_Additional__c= 1;
            //q.Single_car_park_Additional__c= 1;
            //q.Single_Open_Additional__c = 1;
            //q.Stack_Additional__c = 1;
            //q.MLCP_Additional__c = null;
            insert q;
            
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPU1.id;
            objBking.Quotation__c = q.Id;
            objBking.Booking_Date__c = Date.today();
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_Total_Receipt_Amount_Received__c = 1000;
            objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
            objBking.Primary_Applicant_Email__c = 'test@mail.com';
            insert objBking;
            
            Test.startTest();
            
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            req1.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/ivr'; 
            req1.httpMethod = 'Get';
            req1.params.put('type', 'mobile');
            req1.params.put('number', oppRec.RW_Mobile_No__c);
            req1.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req1;
            RestContext.response = res1;
            IVRFlow.doGet();
            
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = 'https://runwal--uat.sandbox.my.salesforce.com/services/apexrest/ivr'; 
            req2.httpMethod = 'Get';
            req2.params.put('type', 'crn');
            req2.params.put('number', oppRec.SAP_Customer_Number__c);
            req2.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req2;
            RestContext.response = res2;
            IVRFlow.doGet();
            
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Call Back', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Last 3 Payment Receipts', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Loan Process', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
			//IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Interest Statement', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            Test.stopTest();
    }
}
    
    @isTest
    public static void test4(){
        UserRole objRole=new UserRole(Name= 'ABC'); 
		insert objRole;
        
		Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser',
                                lastName = 'TestUser',
                                email = uniqueName + '@gmail' +'.com',
                                Username = uniqueName + '@test' + orgId + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = p.id,
                              	UserRoleId = objRole.Id
                                );
        insert tuser;
        
        List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0]){
            String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account a = new Account();
            a.RecordTypeID=recordTypeId ;
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
            a.OwnerId = tuser.Id;
            insert a;
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :a.Id];
            
            Profile p1 = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
            String orgId1 = UserInfo.getOrganizationId();
            String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName1 = orgId + dateString + randomInt;
            User tuser1 = new User(  firstname = 'TestUser1',
                                  lastName = 'TestUser2',
                                  email = uniqueName1 + '@gmail' +'.com',
                                  contactId=acc.PersonContactId,
                                  Username = uniqueName1 + '@test1' + orgId1 + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = uniqueName1.substring(18, 23),
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  ProfileId = p1.id
                                 );
            insert tuser1;
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Sales_Site_Head__c = tuser1.Id;
            objpr.SAPMaterial_Code__c = '1211';
            objpr.Project_CRM_Lead__c = tuser1.Id;
            objpr.RW_Project_Location_Videos_Link__c='test';
            objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
            insert objpr;
            
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
            
             Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            objPU1.UnitNo__c ='TestFive';
            objPU1.RW_Unit_status__c='Available';
            objPU1.RW_Booking_Date__c = system.Today();
            objPU1.Actual_Area_value__c = 2218;
            objPU1.New_Floor__c = '8';
            objPU1.RW_Param4__c ='A-4546';
            objPU1.TowerName__c = t.Id;
            objPU1.Carpet_Area__c = 10;
            objPU1.Saleable_Area__c=2218;
            objPU1.Single_car_park_Earmarked__c = 0;
            objPU1.Single_Open_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.Tandem_car_park_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.MLCP_Earmarked__c = 0;
            objPU1.Stack__c = 0;
            insert objPU1;
            
            Opportunity oppRec= new Opportunity();
            oppRec.RW_Project__c=objpr.id;
            oppRec.Name='Test 1';
            oppRec.RW_Email__c=a.PersonEmail;
            oppRec.StageName='Unit Booked';
            oppRec.CloseDate=system.today();
            oppRec.Status__c ='Active';
            oppRec.AccountId = a.Id;
            oppRec.Sales_Manager__c = 'SM2@g.com';
            oppRec.Sourcing_Manager__c='Aniket Sapre';
            oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
            oppRec.RW_Sales_Associate__c='Karthik Chettiar';
            oppRec.RW_Closing_Head__c='Karthik Chettiar';
            oppRec.Walkin_Source__c='Direct';
            oppRec.SAP_Customer_Number__c='0020006618';
            oppRec.SalesOrder_Number__c='3010005457';
            oppRec.RW_Mobile_No__c = '1234567890';
            insert oppRec;
            
            Quotation__c q = new Quotation__c();
            q.Name = 'Q010101';
            q.Quote_Status__c = 'Valid';
            q.Prepared_Date__c = System.today();
            q.Project__c = objpr.Id;
            q.Project_Unit__c = objPU1.Id;
            q.FloorNo__c = 11;
            q.Opportunity__c = oppRec.Id;
            q.Appartment_Configuration__c = '1 BHK';
            q.Carpet_Area_Sq_Ft__c = 1200;
            q.Token_Amount__c =110000;
            q.ST_Token_Amount__c = 1000;
            q.Allow_booking_without_full_token__c = TRUE;
            q.Agreement_Value__c = 60422880;
            q.Agreement_Value_ST__c = 2537761;
            insert q;
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPU1.id;
            objBking.Quotation__c = q.Id;
            objBking.Booking_Date__c = Date.today();
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_Total_Receipt_Amount_Received__c = 1000;
            objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
            objBking.Primary_Applicant_Email__c = 'test@mail.com';
            insert objBking;
            
            Test.startTest();
			IVRFlow.doPost(oppRec.SAP_Customer_Number__c, oppRec.Name, 'Interest Statement', objpr.RW_SAP_Company_Code__c, objpr.Id, objBking.Id, tuser.Id, oppRec.RW_Email__c);
            Test.stopTest();
    }
}
    @isTest
    public static void test5(){
        Test.startTest();
        IVRFlow.doPost('123', 'Test', 'Interest Statement', '1000', '', '', '', '');
        Test.stopTest();
    }
}