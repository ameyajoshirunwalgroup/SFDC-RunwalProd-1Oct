@isTest
public class MobileAppControllerTest {
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
            
            Project__c objpr1 = new Project__c();
            objpr1.RW_Project_Code__c = 'T32';
            objpr1.Name = 'Runwal Gardens';
            objpr1.RDS_Short_Name__c = 'T';
            objpr1.Start_Date__c = System.today().addDays(-5);
            objpr1.RDS_Interest_Rate__c = 12;
            objpr1.Sales_Site_Head__c = tuser1.Id;
            objpr1.SAPMaterial_Code__c = '1211';
            objpr1.Project_CRM_Lead__c = tuser1.Id;
            objpr1.RW_Project_Location_Videos_Link__c='test';
            objpr1.RW_Project_Brochure_PublicUrl__c='test1';
            objpr1.RW_SAP_Company_Code__c='5245';
            insert objpr1;
            
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.Id,'A','Residential');
            
            Tower__c t1 = new tower__C();
            t1.Name = 'Tower 9';
            t1.Property_Type__c= 'Residential';
            t1.SAP_Plant_Code__c = '10001';
            t1.ProjectName__c = objpr1.Id;
            t1.Enable_BillDesk__c = true;
            insert t1;
            
            Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            //objPU1.Relationship_Manager__c = rms.id;
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
            oppRec.SAP_Customer_Number__c='0020006618';
            oppRec.SalesOrder_Number__c='3010005457';
            insert oppRec;
            
            Opportunity oppRec1= new Opportunity();
            oppRec1.RW_Project__c=objpr.id;
            oppRec1.name='Test 1';
            oppRec1.RW_Email__c=a.PersonEmail;
            oppRec1.StageName='Unit Booked';
            oppRec1.CloseDate=system.today();
            oppRec1.Status__c ='Active';
            oppRec1.AccountId = a.Id;
            oppRec1.Sales_Manager__c = 'SM2@g.com';
            oppRec1.Sourcing_Manager__c='Aniket Sapre';
            oppRec1.RW_Sourcing_Head__c='Adrian Dsouza';
            oppRec1.RW_Sales_Associate__c='Karthik Chettiar';
            oppRec1.RW_Closing_Head__c='Karthik Chettiar';
            oppRec1.Walkin_Source__c='Direct';
            oppRec1.SAP_Customer_Number__c='0020006619';
            oppRec1.SalesOrder_Number__c='3010005458';
            insert oppRec1;
            
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
            q.Tandem_car_park_Additional__c = 1;
            q.Tandem_Open_Additional__c= 1;
            q.Single_car_park_Additional__c= 1;
            q.Single_Open_Additional__c = 1;
            q.Stack_Additional__c = 1;
            q.MLCP_Additional__c = null;
            insert q;
            
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPU1.id;
            objBking.Quotation__c = q.Id;
            //objBking.Receipts__c = r1.Id;
            objBking.Booking_Date__c = Date.today();
            //objBking.Sales_Manager__c= salesmanager.Id;
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_Total_Receipt_Amount_Received__c = 1000;
            objBking.RW_Total_Receipt_Discount_Recieved__c = 0;
            insert objBking;
            
            RW_Demand__c demandobj = new RW_Demand__c();
            demandobj.Due_Date__c = system.today();
            demandobj.Booking__c = objBking.Id;
            demandobj.RW_Billing_Document_Number__c='097654567';
            demandobj.RW_Customer_Number__c='0020006618';
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
            apt1.PancardNo__c = 'abc213456';
            apt1.Address_Proof_Number__c='BLYTU0987Y';
            apt1.Type_Of_Origin__c='PIO card';
            apt1.Origin_Details__c='210';
            apt1.PassportNoDetails__c='A9876543';
            apt1.Pan_Card_Number_of_Authority_Signatory__c='NJHYT5678U';
            apt1.Permanent_Address_Line_1__c='test';
            apt1.Permanent_Address_Line_1__c='test1';
            apt1.Permanent_Address_Line_1__c='test2';
            apt1.Country__c='India';
            apt1.State__c='Maharashtra';
            apt1.City__c='Mumbai';
            apt1.Pincode__c=456789;
            insert apt1;
            
            RW_Referral__c ref = new RW_Referral__c();
            ref.RW_First_Name__c = 'Test';
            ref.RW_Last_Name__c = 'Test';
            ref.Account__c = a.Id;
            ref.RW_Project__c = objpr.Id;
            ref.RW_Contact_Phone__c = '2547896547';
            ref.RW_Email_Address__c = 'test@mail.com';
            insert ref;
            
            Blob blbdata = EncodingUtil.base64Decode('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');
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = 'Test.jpeg';
            cv.VersionData = blbdata;
            cv.IsMajorVersion = true;
            Insert cv;
            
            ContentVersion cv2 = new ContentVersion();
            cv2.ContentLocation = 'S';
            cv2.PathOnClient = 'Test2.jpeg';
            cv2.VersionData = blbdata;
            cv2.IsMajorVersion = true;
            Insert cv2;
            
            ContentVersion cv3 = new ContentVersion();
            cv3.ContentLocation = 'S';
            cv3.PathOnClient = 'Test2.jpeg';
            cv3.VersionData = blbdata;
            cv3.IsMajorVersion = true;
            Insert cv3;
            
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
            Id conDocId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv3.Id].ContentDocumentId;
            
            Document_Details__c Details = new Document_Details__c();
            Details.RW_Type_Of_Applicant__c = apt1.Type_Of_Applicant__c;
            Details.RW_Residential_Status__c = apt1.Subtype_Of_Applicant__c;
            Details.Opportunity__c = apt1.Opportunity__c;
            Details.RW_Document_Type__c= 'Aadhar Card';
            Details.RW_Document_ID__c = conDocId2;
            Details.Booking__c = apt1.Booking__c;
            Details.Applicant_Number__c = apt1.Applicant_Number__c;
            Details.RW_Applicant_Details__c = apt1.Id;
            Details.RW_Document_Status__c = 'Active';
            insert Details;
            
            RW_Tower_Construction_Update__c constUpdate = new RW_Tower_Construction_Update__c();
            constUpdate.RW_Description__c = 'update 1';
            constUpdate.RW_Date__c = Date.today();
            constUpdate.RW_Tower_Construction_Photo_ID__c = cv.Id;
            constUpdate.RW_Tower__c = t.Id;
            constUpdate.RW_Project__c = objpr.Id;
            insert constUpdate;
            
            Case objCase = new Case();
            objCase.AccountId = a.Id;
            objCase.Subject = 'testSubject';
            objCase.Description = 'testDescription';
            insert objCase;
            
            FeedItem feed =new FeedItem();
            feed.ParentId = objCase.Id;
            feed.Body = 'Test Body';
            insert feed;
            
            FeedComment fdComm = new FeedComment();
            fdComm.FeedItemId = feed.Id;
            fdComm.CommentBody = 'Test Comment';
            insert fdComm;
            
            Receipt__c r1 = new Receipt__c();
            r1.Cheque_DD_Amount_Rs__c = 200000;
            r1.Cheque_DD__c = '908888';
            r1.Cheque_DD_Date__c = system.today();
            r1.Project__c = objpr.Id;
            r1.Project_Unit__c = objPU1.Id;
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
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Test';
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            insert cd;
            
            ContentDistribution distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                              FROM ContentDistribution where ContentVersionId =: cv.Id limit 1];
            
            cloudx_cms__SS_Carousel__c cars = new cloudx_cms__SS_Carousel__c();
            insert cars; 
            
            cloudx_cms__SS_Carousel_Slide__c slid = new cloudx_cms__SS_Carousel_Slide__c();
            slid.cloudx_cms__Image_URL__c = distList.ContentDownloadUrl;
            slid.cloudx_cms__Carousel__c = cars.Id;
            insert slid;
            
            Test.startTest();
            
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            req1.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/CustomerCases/'+oppRec.SAP_Customer_Number__c; 
            req1.httpMethod = 'Get';
            req1.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req1;
            RestContext.response = res1; 
            CustomerCasesRestService.doGet();
            
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            req2.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/ReferralStatus/'+a.Id; 
            req2.httpMethod = 'Get';
            req2.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req2;
            RestContext.response = res2;
            ReferralStatusRestService.doGet();
            
            RestRequest req3 = new RestRequest(); 
            RestResponse res3 = new RestResponse();
            req3.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/ReferralStatus'; 
            req3.httpMethod = 'Get';
            req3.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req3;
            RestContext.response = res3;
            ReferralStatusRestService.doPost('Test','Test','5478965478','test@mail.com',objpr.Id,a.Id,'');
            
            RestRequest req4 = new RestRequest(); 
            RestResponse res4 = new RestResponse();
            req4.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/KYCDetails'; 
            req4.httpMethod = 'Get';
            req4.addHeader('Content-Type', 'application/json'); 
            req4.params.put('type', 'aadhar');
            req4.params.put('id', apt1.Id);
            RestContext.request = req4;
            RestContext.response = res4;
            KYCDetailsRestService.doGet();
            
            RestRequest req5 = new RestRequest(); 
            RestResponse res5 = new RestResponse();
            req5.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/KYCDetails'; 
            req5.httpMethod = 'Post';
            req5.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req5;
            RestContext.response = res5;
            KYCDetailsRestService.doPost('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',apt1.Id,'Aadhar Card',apt1.Type_Of_Applicant__c,apt1.Subtype_Of_Applicant__c,apt1.Opportunity__c,
                                        apt1.Booking__c,apt1.Applicant_Number__c,'jpeg');
            
            RestRequest req6 = new RestRequest(); 
            RestResponse res6 = new RestResponse();
            req6.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/TDSDetails/'+conDocId; 
            req6.httpMethod = 'Get';
            req6.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req6;
            RestContext.response = res6;
            TDSCertificatesRestService.doGet();
            
            RestRequest req7 = new RestRequest(); 
            RestResponse res7 = new RestResponse();
            req7.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/TDSDetails'; 
            req7.httpMethod = 'Post';
            req7.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req7;
            RestContext.response = res7;
            String resp = TDSCertificatesRestService.doPost('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',
                                         'jpeg',objBking.Id,'123654',100000,oppRec.Id);
            
            RestRequest req8= new RestRequest(); 
            RestResponse res8 = new RestResponse();
            req8.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/GetUnitDetails/'+oppRec.SAP_Customer_Number__c; 
            req8.httpMethod = 'Get';
            req8.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req8;
            RestContext.response = res8;
            GetUnitDetailsRest.doGet();
            
            RestRequest req9= new RestRequest(); 
            RestResponse res9 = new RestResponse();
            req9.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/GetSlides'; 
            req9.httpMethod = 'Get';
            req9.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req9;
            RestContext.response = res9;
            GetSlides.slidesList();
            
            RestRequest req13= new RestRequest(); 
            RestResponse res13 = new RestResponse();
            req13.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/GetConstructionUpdates/'+objBking.Id; 
            req13.httpMethod = 'Get';
            req13.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req13;
            RestContext.response = res13;
            GetConstructionUpdates.constructionUpdates();
            
            RestRequest req10= new RestRequest(); 
            RestResponse res10 = new RestResponse();
            req10.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/AgreementDoc/'+conDocId3; 
            req10.httpMethod = 'Get';
            req10.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req10;
            RestContext.response = res10;
            AgreementDocRest.doGet();
            
            RestRequest req11= new RestRequest(); 
            RestResponse res11 = new RestResponse();
            req11.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/caseComments/'+objCase.Id; 
            req11.httpMethod = 'Get';
            req11.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req11;
            RestContext.response = res11;
            CaseCommentsRest.doGet();
            
            RestRequest req12= new RestRequest(); 
            RestResponse res12 = new RestResponse();
            req12.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/caseComments/'+objCase.Id; 
            req12.httpMethod = 'Get';
            req12.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req12;
            RestContext.response = res12;
            CaseCommentsRest.doPost(objCase.Id, 'Test Comment');
            
            Map<String,String> DetailMap=new Map<String,String>();         
            DetailMap.put('bookingId', objBking.Id);
            DetailMap.put('OpportunityId', oppRec.Id);
            //DetailMap.put('towerId', t.Id);
            DetailMap.put('towerId', t1.Id);
            DetailMap.put('Amount', '100000');
            DetailMap.put('TypeOfAmount','Normal');
            DetailMap.put('ProjectUnit',objPU1.id);
            DetailMap.put('ButtonType','SinglePayment');
            
            BillDeskTestCmpController.getBillDeskData(DetailMap);
            
            Map<String,String> DetailMap2=new Map<String,String>();         
            DetailMap2.put('bookingId', objBking.Id);
            DetailMap2.put('OpportunityId', oppRec.Id);
            //DetailMap2.put('towerId', t.Id);
            DetailMap2.put('towerId', t1.Id);
            DetailMap2.put('Amount', '100000');
            DetailMap2.put('TypeOfAmount','GST');
            DetailMap2.put('ProjectUnit',objPU1.id);
            
            BillDeskTestCmpController.getBillDeskData(DetailMap2);
            
            
            Map<String,String> DetailMap1=new Map<String,String>();         
            DetailMap1.put('bookingId', objBking.Id);
            DetailMap1.put('OpportunityId', oppRec.Id);
            //DetailMap1.put('towerId', t.Id);
            DetailMap1.put('towerId', t1.Id);
            DetailMap1.put('Amount', '100000');
            DetailMap1.put('TypeOfAmount','SinglePayment');
            DetailMap1.put('ProjectUnit',objPU1.id);
            
            BillDeskTestCmpController.getBillDeskData(DetailMap1);
            
                        
            Map<String,String>  SaveDetailMap=new Map<String,String>();
            Receipt__c rec = [Select Id,Name From Receipt__c limit 1 ];
            String name = rec.Name;
            //SaveDetailMap.put('towerId',t.id);
            SaveDetailMap.put('towerId',t1.id);
            //SaveDetailMap.put('msg','RNWLEMPUAT|'+name +'|U1230002035462|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|8E2A7079253D64E1954BED58D6CB089BBD85CFA138FE7E83A08C1328C4706F28' );
            SaveDetailMap.put('msg','RNWLGDP1|'+name +'|U1230002035462|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|8E2A7079253D64E1954BED58D6CB089BBD85CFA138FE7E83A08C1328C4706F28' );
     		BillDeskTestCmpController.saveBillDeskData(SaveDetailMap);
            
            
            PageReference pageRef1 = Page.MobileAppPayPage; 
            pageRef1.getParameters().put('bookingId', String.valueOf(objBking.Id));
            pageRef1.getParameters().put('OpportunityId', String.valueOf(oppRec.Id));
            pageRef1.getParameters().put('towerId', String.valueOf(t.Id));
            pageRef1.getParameters().put('Amount', '100000');
            pageRef1.getParameters().put('ProjectUnit', String.valueOf(objPU1.id));
            pageRef1.getParameters().put('TypeOfAmount', 'GST');
            pageRef1.getParameters().put('msg', 'Test');
            Test.setCurrentPage(pageRef1);
            
            MobileAppPayPageController testPayPage = new MobileAppPayPageController();
            testPayPage.pay();
            
            
            PageReference pageRef2 = Page.MobileAppPayPage; 
            pageRef2.getParameters().put('accountId', String.valueOf(a.Id));
            Test.setCurrentPage(pageRef2);
            
            MobileAppNCFPageController testNCFPage = new MobileAppNCFPageController();
            testNCFPage.ncf();
            
            
            Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock());  
        	CreateUserWhenUnitBooked.createuser(new List<Id>{tuser1.Id});
            
            RestRequest req14= new RestRequest(); 
            RestResponse res14 = new RestResponse();
            req14.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/GetServiceReqDependentValues/RW_Complaint_Type__c:Complaint'; 
            req14.httpMethod = 'Get';
            req14.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req14;
            RestContext.response = res14;
            GetServiceReqDependentValues.getServiceReqDependentValues();

            
            RestRequest req15= new RestRequest(); 
            RestResponse res15 = new RestResponse();
            req15.requestURI = 'https://runwal--uat.sandbox.lightning.force.com/services/apexrest/CustomerLedger/'+objBking.Id; 
            req15.httpMethod = 'Get';
            req15.addHeader('Content-Type', 'application/json'); 
            RestContext.request = req15;
            RestContext.response = res15;
            CustomerLedgerRest.doGet();
            
            
            
            Test.stopTest();
        }
          
    }
    
}