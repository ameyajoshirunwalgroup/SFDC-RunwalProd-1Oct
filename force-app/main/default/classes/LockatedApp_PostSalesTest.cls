@isTest
public class LockatedApp_PostSalesTest {
    
    @isTest
    public static void test1(){
        
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
        a.Mobile_No__c = '1236547896';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.WhatsApp_Bot_Project_Image_File_Id__c = System.label.Possession_Guidelines_Doc_Id;
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
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Mobile_No__c = '1234567890';
        oppRec.Sales_Manager_User__c = UserInfo.getUserId();
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
        q.Other_Charges_Category_1__c = 'Other Charges';
        q.Other_Charges_Amount_1__c = 1000;
        q.Other_Charges_Category_2__c = 'Other Charges';
        q.Other_Charges_Amount_2__c = 1000;
        q.Other_Charges_Category_3__c = 'Other Charges';
        q.Other_Charges_Amount_3__c = 1000;
        q.Other_Charges_Category_4__c = 'Other Charges';
        q.Other_Charges_Amount_4__c = 1000;
        q.Other_Charges_Category_5__c = 'Other Charges';
        q.Other_Charges_Amount_5__c = 1000;
        q.Other_Charges_Category_6__c = 'Other Charges';
        q.Other_Charges_Amount_6__c = 1000;
        q.Other_Charges_Category_7__c = 'Other Charges';
        q.Other_Charges_Amount_7__c = 1000;
        q.Other_Charges_Category_8__c = 'Other Charges';
        q.Other_Charges_Amount_8__c = 1000;
        q.Other_Charges_Category_9__c = 'Other Charges';
        q.Other_Charges_Amount_9__c = 1000;
        q.Other_Charges_Category_10__c = 'Other Charges';
        q.Other_Charges_Amount_10__c = 1000;
        q.Other_Charges_Category_11__c = 'Other Charges';
        q.Other_Charges_Amount_11__c = 1000;
        q.Other_Charges_Category_12__c = 'Other Charges';
        q.Other_Charges_Amount_12__c = 1000;
        q.Other_Charges_Category_13__c = 'Other Charges';
        q.Other_Charges_Amount_13__c = 1000;
        q.Other_Charges_Category_14__c = 'Other Charges';
        q.Other_Charges_Amount_14__c = 1000;
        q.Other_Charges_Category_15__c = 'Other Charges';
        q.Other_Charges_Amount_15__c = 1000;
        q.Other_Charges_Category_16__c = 'Other Charges';
        q.Other_Charges_Amount_16__c = 1000;
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
        objBking.RW_Signed_Agreement_Document_Id__c = System.label.Possession_Guidelines_Doc_Id;
        insert objBking;
        
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Applicant_Details__c app1 = new Applicant_Details__c();
        app1.Applicant_Number__c = 'Primary Applicant';
        app1.PancardNo__c = 'ASFER5665G';
        app1.Address_Proof_Number__c = '125365478589';
        app1.Booking__c = objBking.id;
        appList.add(app1);
        
        Applicant_Details__c app2 = new Applicant_Details__c();
        app2.Applicant_Number__c = 'Second Applicant';
        app2.Last_Name__c = 'Test';
        app2.PancardNo__c = 'ASFER5665G';
        app2.Address_Proof_Number__c = '125365478589';
        app2.Booking__c = objBking.Id;
        appList.add(app2);
        
        Applicant_Details__c app3 = new Applicant_Details__c();
        app3.Applicant_Number__c = 'Third Applicant';
        app3.Last_Name__c = 'Test';
        app3.PancardNo__c = 'ASFER5665G';
        app3.Address_Proof_Number__c = '125365478589';
        app3.Booking__c = objBking.Id;
        appList.add(app3);
        
        Applicant_Details__c app4 = new Applicant_Details__c();
        app4.Applicant_Number__c = 'Fourth Applicant';
        app4.Last_Name__c = 'Test';
        app4.PancardNo__c = 'ASFER5665G';
        app4.Address_Proof_Number__c = '125365478589';
        app4.Booking__c = objBking.Id;
        appList.add(app4);
        insert appList;
        
        RW_Demand__c dem = new RW_Demand__c();
        dem.RW_Demand_Status__c = 'Due';
        dem.Booking__c = objBking.Id;
        dem.RW_Demand_Milestone__c = 'Booking Amount';
        insert dem;
        
        RW_Payment_Details__c rec = new RW_Payment_Details__c();
        rec.RW_Booking__c = objBking.Id;
        rec.RW_Payment_Amount__c = 1000;
        insert rec;
                
        Lead ld = new Lead();
        ld.Customer_Reference__c = a.Id;
        ld.LastName = 'Test';
        ld.Email = 'test@mail.com';
        ld.RW_Mobile_No__c = '1236547896';
        ld.Status = 'VCVP';
        ld.RW_Project__c = objpr.id;
        insert ld;
        
        Opportunity refOpp = new Opportunity();
        refOpp.Name = 'Ref Opp';
        refOpp.CloseDate = Date.today() + 10;
        refOpp.StageName = 'Site Visit';
        refOpp.Customer_Reference__c = a.Id;
        insert refOpp;
        
        Booking__c refBkg = new Booking__c();
        refBkg.Customer_Reference__c = 'TestAccount1 TestAccount2';
        refBkg.Status__c = 'Booking Confirmed';
        insert refBkg;
        
        Document_Details__c doc = new Document_Details__c();
        doc.RW_Applicant_Details__c = appList[0].Id;
        insert doc;
        
        /*Loan__c ln = new Loan__c();
        ln.RW_Booking__c = objBking.Id;
        ln.RW_Bank_Preference_1__c = 'Axis Bank ltd';
        insert ln;*/
        
        ContentVersion version = new ContentVersion();
        version.ContentDocumentId = System.label.Possession_Guidelines_Doc_Id;
        version.PathOnClient = 'Possession GuideLines.pdf';
        version.VersionData = Blob.valueOf('Test Content');
        insert version;
        
        /*Registration_Schedule__c sch = new Registration_Schedule__c();
        sch.Booking__c = objBking.Id;
        sch.Active__c = true;
        insert sch;*/
        
        Test.startTest();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/customerDetails/'+objBking.Id; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        LockatedApp_PostSales.doGet();
        LockatedApp_MyReferrals.doGet();
        LockatedApp_LoanDetails.doGet();
        LockatedApp_LoyaltyLeads.doGet();
        LockatedApp_RegistrationAppointment.doGet();
        LockatedApp_ServiceRequests.doGet();
        
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/documents/'+objBking.Id; 
        req2.httpMethod = 'Get';
        req2.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        LockatedApp_DocumentDetails.doGet();
        
        /*String jsonStr = '{"loanRequest": {"booking" : "' + refBkg.Id + '","projectName": "Runwal Bliss","requiredLoanAmount": 1000,"loanTenureYears": "2","preferredBank": "Bank of India","comments": "Test"}}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/loans/'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        req3.requestBody = Blob.valueOf(jsonStr);
        LockatedApp_LoanDetails.doPost();*/
        
        String jsonStr4 = '{"booking" : "' + refBkg.Id + '","ncf_status": "Completed"}';
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/ncf/'; 
        req4.httpMethod = 'Post';
        req4.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req4;
        RestContext.response = res4;
        req4.requestBody = Blob.valueOf(jsonStr4);
        LockatedApp_NCFConfirmation.doPost();
        
        String jsonStr5 = '{"customerProfileDetails": {"booking": "' + objBking.Id + '","PrimaryApplicants": [{"fullName": "Vinay","birthDate": "","panCard": "","gstinNumber": "","companyName": "","designation": "","permanentAddress": "","correspondenceAddress": "Test","emailId": "","mobileNumber": ""}]}}';
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/primaryApplicant/'; 
        req5.httpMethod = 'Post';
        req5.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req5;
        RestContext.response = res5;
        req5.requestBody = Blob.valueOf(jsonStr5);
        LockatedApp_PrimaryApplicant.doPost();
        
        String jsonStr7 = '{"customerProfileDetails": {"booking": "' + refBkg.Id + '","PrimaryApplicants": [{"fullName": "Vinay","birthDate": "","panCard": "","gstinNumber": "","companyName": "","designation": "","permanentAddress": "Test","correspondenceAddress": "Test","emailId": "","mobileNumber": ""}]}}';
        RestRequest req7 = new RestRequest(); 
        RestResponse res7 = new RestResponse();
        req7.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/primaryApplicant/'; 
        req7.httpMethod = 'Post';
        req7.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req7;
        RestContext.response = res7;
        req7.requestBody = Blob.valueOf(jsonStr7);
        LockatedApp_PrimaryApplicant.doPost();
        
        PageReference ncfPdf = Page.CRMBotDocument;
        Test.setCurrentPage(ncfPdf);
        ApexPages.currentPage().getParameters().put('id',objBking.Id);
        NameConfirmationController ncf = new NameConfirmationController();
        
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        Test.startTest();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/customerDetails/'; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        LockatedApp_PostSales.doGet();
        LockatedApp_MyReferrals.doGet();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/documents/'; 
        req2.httpMethod = 'Get';
        req2.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        LockatedApp_DocumentDetails.doGet();
        
        LockatedApp_LoanDetails.doGet();
        
        Booking__c refBkg = new Booking__c();
        refBkg.Customer_Reference__c = 'TestAccount1 TestAccount2';
        refBkg.Status__c = 'Booking Confirmed';
        insert refBkg;
        
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/loans/'+refBkg.Id; 
        req3.httpMethod = 'Get';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        LockatedApp_LoanDetails.doGet();
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/loyalty/'; 
        req4.httpMethod = 'Get';
        req4.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req4;
        RestContext.response = res4;
        LockatedApp_LoyaltyLeads.doGet();
        
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/loyalty/1234'; 
        req5.httpMethod = 'Get';
        req5.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req5;
        RestContext.response = res5;
        LockatedApp_LoyaltyLeads.doGet();
        
        LockatedApp_LoyaltyLeads.doGet();
        
        String jsonStr6 = '{"booking" : "","ncf_status": "Completed"}';
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();
        req6.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/ncf/'; 
        req6.httpMethod = 'Post';
        req6.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req6;
        RestContext.response = res6;
        req6.requestBody = Blob.valueOf(jsonStr6);
        LockatedApp_NCFConfirmation.doPost();
        
        LockatedApp_RegistrationAppointment.doGet();
        
        String jsonStr7 = '{"customerProfileDetails": {"booking": "","PrimaryApplicants": [{"fullName": "Vinay","birthDate": "","panCard": "","gstinNumber": "","companyName": "","designation": "","permanentAddress": "Test","correspondenceAddress": "Test","emailId": "","mobileNumber": ""}]}}';
        RestRequest req7 = new RestRequest(); 
        RestResponse res7 = new RestResponse();
        req7.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/primaryApplicant/'; 
        req7.httpMethod = 'Post';
        req7.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req7;
        RestContext.response = res7;
        req7.requestBody = Blob.valueOf(jsonStr7);
        LockatedApp_PrimaryApplicant.doPost();
        
        LockatedApp_ServiceRequests.doGet();
        
        String jsonStr8 = '{"App_Version" : "","Source" : "","OS_Version" : "","Model" : "","Type_A_I" : "","Custom_Device_ID" : "","Customer" : "","FCM_ID_Action" : ""}';
        RestRequest req8 = new RestRequest(); 
        RestResponse res8 = new RestResponse();
        req8.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/userDeviceDetails'; 
        req8.httpMethod = 'Post';
        req8.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req8;
        RestContext.response = res8;
        req8.requestBody = Blob.valueOf(jsonStr8);
        LockatedApp_UserDeviceDetails.doPost();
        
        Test.stopTest();
    }
    
    @isTest
    public static void test3(){
        
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
        a.Mobile_No__c = '1236547896';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
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
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Mobile_No__c = '1234567890';
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPU1.id;
        objBking.Booking_Date__c = Date.today();
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_Total_Receipt_Amount_Received__c = 1000;
        objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
        objBking.Primary_Applicant_Email__c = 'test@mail.com';
        insert objBking;
        
        Case cs = new Case();
        cs.AccountId = a.Id;
        insert cs;
        
        FeedItem item = new FeedItem();
        item.ParentId = cs.Id;
        item.Body = 'Test';
        insert item;
        
        
        
		ContentVersion version = new ContentVersion();
        version.ContentDocumentId = System.label.Possession_Guidelines_Doc_Id;
        version.PathOnClient = 'Possession GuideLines.pdf';
        version.VersionData = Blob.valueOf('Test Content');
        insert version;
        
        FeedAttachment att = new FeedAttachment();
        att.FeedEntityId = item.Id;
        att.RecordId = version.Id;
        att.Type = 'Content';
        insert att;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.LinkedEntityId = cs.Id;
        link.ContentDocumentId = System.label.Possession_Guidelines_Doc_Id;
        //insert link;
        
        RW_FAQ__c faq = new RW_FAQ__c();
        faq.RW_Question__c = 'Question';
        faq.RW_Answer__c = 'Answer';
        faq.Language__c = 'English';
        faq.RW_Order__c = 1;
        faq.RW_Active__c = true;
        insert faq;
        
        Test.startTest();
        
        RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/'+objBking.Id; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        LockatedApp_ServiceRequests.doGet();
        
        String jsonStr2 = '{"caseType" : "Complaint","categorType" : "Cancellation Related","categoryName" : "Cancellation Related","sub_category" : "","description" : "Test","booking_id" :"' + objBking.Id + '","attachment" : ""}';
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/case'; 
        req2.httpMethod = 'Post';
        req2.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        req2.requestBody = Blob.valueOf(jsonStr2);
        LockatedApp_ServiceRequests.doPost();
        
        String jsonStr3 = '{"description" : "Test for file attchment","case_id" : "' + cs.Id + '","fileType" : "jpeg","fileName" : "Test Att","attachment" : ""}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/caseComment'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        req3.requestBody = Blob.valueOf(jsonStr3);
        LockatedApp_ServiceRequests.doPost();
        
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/1234'; 
        req4.httpMethod = 'Get';
        req4.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req4;
        RestContext.response = res4;
        LockatedApp_ServiceRequests.doGet();
        
        String jsonStr5 = '{"caseType" : "Complaint","categorType" : "Cancellation Related","categoryName" : "Cancellation Related","sub_category" : "","description" : "Test","booking_id" :"1234","attachment" : ""}';
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/case'; 
        req5.httpMethod = 'Post';
        req5.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req5;
        RestContext.response = res5;
        req5.requestBody = Blob.valueOf(jsonStr5);
        LockatedApp_ServiceRequests.doPost();
        
        String jsonStr6 = '{"App_Version" : "","Source" : "","OS_Version" : "","Model" : "","Type_A_I" : "","Custom_Device_ID" : "","Customer" : "0020006618","FCM_ID_Action" : ""}';
        RestRequest req6 = new RestRequest(); 
        RestResponse res6 = new RestResponse();
        req6.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/userDeviceDetails'; 
        req6.httpMethod = 'Post';
        req6.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req6;
        RestContext.response = res6;
        req6.requestBody = Blob.valueOf(jsonStr6);
        LockatedApp_UserDeviceDetails.doPost();
        
        String jsonStr7 = '{"App_Version" : "","Source" : "","OS_Version" : "","Model" : "","Type_A_I" : "","Custom_Device_ID" : "","Customer" : "134","FCM_ID_Action" : ""}';
        RestRequest req7 = new RestRequest(); 
        RestResponse res7 = new RestResponse();
        req7.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/serviceRequests/userDeviceDetails'; 
        req7.httpMethod = 'Post';
        req7.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req7;
        RestContext.response = res7;
        req7.requestBody = Blob.valueOf(jsonStr7);
        LockatedApp_UserDeviceDetails.doPost();
        
        String jsonStr8 = '{"booking" : "'+ objBking.Id +'","utrNumber" : "1234","fileType" : "pdf","fileContent" : ""}';
        RestRequest req8 = new RestRequest(); 
        RestResponse res8 = new RestResponse();
        req8.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/utrUpload/StampDuty'; 
        req8.httpMethod = 'Post';
        req8.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req8;
        RestContext.response = res8;
        req8.requestBody = Blob.valueOf(jsonStr8);
        LockatedApp_UploadUTRDetails.doPost();
        
        String jsonStr9 = '{"booking" : "","utrNumber" : "1234","fileType" : "pdf","fileContent" : ""}';
        RestRequest req9 = new RestRequest(); 
        RestResponse res9 = new RestResponse();
        req9.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/utrUpload/StampDuty'; 
        req9.httpMethod = 'Post';
        req9.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req9;
        RestContext.response = res9;
        req9.requestBody = Blob.valueOf(jsonStr9);
        LockatedApp_UploadUTRDetails.doPost();
        
        String jsonStr10 = '{"booking" : "'+ objBking.Id +'","utrNumber" : "","fileType" : "pdf","fileContent" : ""}';
        RestRequest req10 = new RestRequest(); 
        RestResponse res10 = new RestResponse();
        req10.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/utrUpload/StampDuty'; 
        req10.httpMethod = 'Post';
        req10.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req10;
        RestContext.response = res10;
        req10.requestBody = Blob.valueOf(jsonStr10);
        LockatedApp_UploadUTRDetails.doPost();
        
        RestRequest req11 = new RestRequest(); 
        RestResponse res11 = new RestResponse();
        req11.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/faqs'; 
        req11.httpMethod = 'Get';
        req11.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req11;
        RestContext.response = res11;
        LockatedApp_FAQs.doGet();
        
        String jsonStr12 = '{"reqType" : "Enquiry","booking" : "'+ objBking.Id +'","firstName" : "Vinay","lastName" : "V","phone" : "1246676356","email" : "test@mail.com","project" : "Runwal Bliss","description" : ""}';
        RestRequest req12 = new RestRequest(); 
        RestResponse res12 = new RestResponse();
        req12.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/referralEnquiry'; 
        req12.httpMethod = 'Post';
        req12.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req12;
        RestContext.response = res12;
        req12.requestBody = Blob.valueOf(jsonStr12);
        LockatedApp_SubmitReferralEnquiry.doPost();
        
        String jsonStr13 = '{"reqType" : "Referral","booking" : "'+ objBking.Id +'","firstName" : "Vinay","lastName" : "V","phone" : "1246676356","email" : "test@mail.com","project" : "Runwal Bliss","description" : ""}';
        RestRequest req13 = new RestRequest(); 
        RestResponse res13 = new RestResponse();
        req13.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/referralEnquiry'; 
        req13.httpMethod = 'Post';
        req13.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req13;
        RestContext.response = res13;
        req13.requestBody = Blob.valueOf(jsonStr13);
        LockatedApp_SubmitReferralEnquiry.doPost();
        
        String jsonStr14 = '{"booking" : "'+ objBking.Id +'","fileType" : "pdf","fileContent" : "12145265"}';
        RestRequest req14 = new RestRequest(); 
        RestResponse res14 = new RestResponse();
        req14.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/sanctionLetter'; 
        req14.httpMethod = 'Post';
        req14.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req14;
        RestContext.response = res14;
        req14.requestBody = Blob.valueOf(jsonStr14);
        LockatedApp_UploadSanctionLetter.doPost();
        
        Test.stopTest();
    }
    
    @isTest
    public static void test4(){
        
        Holiday h = new Holiday();
        h.RecurrenceType = 'RecursYearlyNth';
        h.Name = 'RecursYearlyNth';
        h.ActivityDate = Date.valueOf('2025-11-13');
        h.IsRecurrence = true;
        h.RecurrenceStartDate = Date.valueOf('2025-11-13');
        h.RecurrenceDayOfWeekMask = 1;
        h.RecurrenceMonthOfYear = 'January';
        h.RecurrenceInstance = 'First';
        insert h;
        
        Holiday h1 = new Holiday();
        h1.RecurrenceType = 'RecursMonthly';
        h1.Name = 'RecursMonthly';
        h1.ActivityDate = Date.valueOf('2025-11-13');
        h1.IsRecurrence = true;
        h1.RecurrenceStartDate = Date.valueOf('2025-11-13');
        h1.RecurrenceDayOfMonth = 1;
        h1.RecurrenceInterval = 1;
        insert h1;
        
        Holiday h2 = new Holiday();
        h2.RecurrenceType = 'RecursWeekly';
        h2.Name = 'RecursWeekly';
        h2.ActivityDate = Date.valueOf('2025-11-13');
        h2.IsRecurrence = true;
        h2.RecurrenceStartDate = Date.valueOf('2025-11-13');
        h2.RecurrenceInterval = 1;
        h2.RecurrenceDayOfWeekMask = 1;
        insert h2;
        
        Holiday h3 = new Holiday();
        h3.RecurrenceType = 'RecursDaily';
        h3.Name = 'RecursDaily';
        h3.ActivityDate = Date.valueOf('2025-11-13');
        h3.IsRecurrence = true;
        h3.RecurrenceStartDate = Date.valueOf('2025-11-13');
        h3.RecurrenceInterval = 1;
        insert h3;
        
        Test.startTest();
        
		RestRequest req1 = new RestRequest(); 
        RestResponse res1 = new RestResponse();
        req1.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/faqs'; 
        req1.httpMethod = 'Get';
        req1.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req1;
        RestContext.response = res1;
        LockatedApp_FAQs.doGet();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/holidays'; 
        req2.httpMethod = 'Get';
        req2.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req2;
        RestContext.response = res2;
        LockatedApp_Holidays.doGet();
        
        String jsonStr3 = '{"reqType" : "Referral","booking" : "","firstName" : "Vinay","lastName" : "V","phone" : "1246676356","email" : "test@mail.com","project" : "Runwal Bliss","description" : ""}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/referralEnquiry'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        req3.requestBody = Blob.valueOf(jsonStr3);
        LockatedApp_SubmitReferralEnquiry.doPost();
        
        String jsonStr4 = '{"reqType" : "Referral","booking" : "1234","firstName" : "Vinay","lastName" : "V","phone" : "1246676356","email" : "test@mail.com","project" : "Runwal Bliss","description" : ""}';
        RestRequest req4 = new RestRequest(); 
        RestResponse res4 = new RestResponse();
        req4.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/referralEnquiry'; 
        req4.httpMethod = 'Post';
        req4.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req4;
        RestContext.response = res4;
        req4.requestBody = Blob.valueOf(jsonStr4);
        LockatedApp_SubmitReferralEnquiry.doPost();
        
        String jsonStr5 = '{"booking" : "","fileType" : "pdf","fileContent" : ""}';
        RestRequest req5 = new RestRequest(); 
        RestResponse res5 = new RestResponse();
        req5.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/sanctionLetter'; 
        req5.httpMethod = 'Post';
        req5.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req5;
        RestContext.response = res5;
        req5.requestBody = Blob.valueOf(jsonStr5);
        LockatedApp_UploadSanctionLetter.doPost();
        
        Test.stopTest();
    }
    
    @isTest
    public static void test5(){
        
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
        a.Mobile_No__c = '1236547896';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        objpr.WhatsApp_Bot_Project_Image_File_Id__c = System.label.Possession_Guidelines_Doc_Id;
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
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 09-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Mobile_No__c = '1234567890';
        oppRec.Sales_Manager_User__c = UserInfo.getUserId();
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
        q.Other_Charges_Category_1__c = 'Other Charges';
        q.Other_Charges_Amount_1__c = 1000;
        q.Other_Charges_Category_2__c = 'Other Charges';
        q.Other_Charges_Amount_2__c = 1000;
        q.Other_Charges_Category_3__c = 'Other Charges';
        q.Other_Charges_Amount_3__c = 1000;
        q.Other_Charges_Category_4__c = 'Other Charges';
        q.Other_Charges_Amount_4__c = 1000;
        q.Other_Charges_Category_5__c = 'Other Charges';
        q.Other_Charges_Amount_5__c = 1000;
        q.Other_Charges_Category_6__c = 'Other Charges';
        q.Other_Charges_Amount_6__c = 1000;
        q.Other_Charges_Category_7__c = 'Other Charges';
        q.Other_Charges_Amount_7__c = 1000;
        q.Other_Charges_Category_8__c = 'Other Charges';
        q.Other_Charges_Amount_8__c = 1000;
        q.Other_Charges_Category_9__c = 'Other Charges';
        q.Other_Charges_Amount_9__c = 1000;
        q.Other_Charges_Category_10__c = 'Other Charges';
        q.Other_Charges_Amount_10__c = 1000;
        q.Other_Charges_Category_11__c = 'Other Charges';
        q.Other_Charges_Amount_11__c = 1000;
        q.Other_Charges_Category_12__c = 'Other Charges';
        q.Other_Charges_Amount_12__c = 1000;
        q.Other_Charges_Category_13__c = 'Other Charges';
        q.Other_Charges_Amount_13__c = 1000;
        q.Other_Charges_Category_14__c = 'Other Charges';
        q.Other_Charges_Amount_14__c = 1000;
        q.Other_Charges_Category_15__c = 'Other Charges';
        q.Other_Charges_Amount_15__c = 1000;
        q.Other_Charges_Category_16__c = 'Other Charges';
        q.Other_Charges_Amount_16__c = 1000;
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
        objBking.RW_Signed_Agreement_Document_Id__c = System.label.Possession_Guidelines_Doc_Id;
        insert objBking;
        
        
        Loan__c ln = new Loan__c();
        ln.RW_Booking__c = objBking.Id;
        ln.RW_Bank_Preference_1__c = 'Axis Bank ltd';
        insert ln;
        
        ContentVersion version = new ContentVersion();
        version.ContentDocumentId = System.label.Possession_Guidelines_Doc_Id;
        version.PathOnClient = 'Possession GuideLines.pdf';
        version.VersionData = Blob.valueOf('Test Content');
        insert version;
        
        Registration_Schedule__c sch = new Registration_Schedule__c();
        sch.Booking__c = objBking.Id;
        sch.Active__c = true;
        insert sch;
        
        Test.startTest();
        
        String jsonStr = '{"loanRequest": {"booking" : "' + objBking.Id + '","projectName": "Runwal Bliss","requiredLoanAmount": 1000,"loanTenureYears": "2","preferredBank": "Bank of India","comments": "Test"}}';
        RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
        req3.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/loans/'; 
        req3.httpMethod = 'Post';
        req3.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req3;
        RestContext.response = res3;
        req3.requestBody = Blob.valueOf(jsonStr);
        LockatedApp_LoanDetails.doPost();
        
        Test.stopTest();
    }
}