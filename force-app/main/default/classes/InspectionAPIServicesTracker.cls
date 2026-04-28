@isTest
public class InspectionAPIServicesTracker {
   
     @testSetup
    private static void InspectionAndPossessionDataTest() 
    {
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        user salesmanager = UniversalTestClassSetup.createusers('Sales Manager', 'Deepak','Arya','salesmanager@runwal.com.uat','salesmanagertest@runwal.com.uat');
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        UniversalTestClassSetup.assignpm(rm.id,'RM_Permission_Set');
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
        objPUU.Relationship_Manager__c = rms.Id;
        objPUU.Carpet_Area__c= 789;
        insert objPUU;
        
        
        
        //create teams
            Team__c objTeam = new Team__c();
            objTeam.Name = 'Facility Team';
            objTeam.Project__c = objpr.id;
            objTeam.Team_Type__c = 'Facility Team';
            objTeam.Towerlookup__c= t.id;
            insert objTeam;
     // Create Team Member
        Team_Members__c objTeamMbr = new Team_Members__c();
         objTeamMbr.Team__c = objTeam.Id;
         objTeamMbr.User_Active__c = True;
         objTeamMbr.Email_Id__c = 'test123@gmail.com';
        insert objTeamMbr;
             
             
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
    
        InspectionAndPossession__c insPoss = new InspectionAndPossession__c();
        insPoss.Booking__c = objBking.id;
        insPoss.Opportunity__c = oppRec.Id;
        insPoss.RW_Inspection_Status__c ='Inspection Scheduled';
        insPoss.RW_SAP_Code__c = '1001R001009';
    
        insert insPoss;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
            
        InspectionAndPossession__c insPoss1 = new InspectionAndPossession__c();
        insPoss1.Booking__c = objBking.id;
        insPoss1.Opportunity__c = oppRec.Id;
        insPoss1.RW_Inspection_Status__c ='Home Score Initiated';
        insPoss1.RW_SAP_Code__c = '1001R001008';
    
        insert insPoss1;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});    
        
            
       InspectionAndPossession__c insPoss2 = new InspectionAndPossession__c();
        insPoss2.Booking__c = objBking.id;
        insPoss2.Opportunity__c = oppRec.Id;
        insPoss2.RW_Inspection_Status__c ='Home Score Completed';
        insPoss2.RW_SAP_Code__c = '1001R001007';
    
        insert insPoss2;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
            
            
        InspectionAndPossession__c insPoss3 = new InspectionAndPossession__c();
        insPoss3.Booking__c = objBking.id;
        insPoss3.Opportunity__c = oppRec.Id;
        insPoss3.RW_Inspection_Status__c ='Snagging Initiated';
        insPoss3.RW_SAP_Code__c = '1001R001006';
    
        insert insPoss3;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
            
        InspectionAndPossession__c insPoss4 = new InspectionAndPossession__c();
        insPoss4.Booking__c = objBking.id;
        insPoss4.Opportunity__c = oppRec.Id;
        insPoss4.RW_Inspection_Status__c ='Snagging Completed';
        insPoss4.RW_SAP_Code__c = '1001R001005';
    
        insert insPoss4;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
        
        
        InspectionAndPossession__c insPoss5 = new InspectionAndPossession__c();
        insPoss5.Booking__c = objBking.id;
        insPoss5.Opportunity__c = oppRec.Id;
        insPoss5.RW_Inspection_Status__c ='Readiness Initiated';
        insPoss5.RW_SAP_Code__c = '1001R001004';
    
        insert insPoss5;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
            
         
        InspectionAndPossession__c insPoss6 = new InspectionAndPossession__c();
        insPoss6.Booking__c = objBking.id;
        insPoss6.Opportunity__c = oppRec.Id;
        insPoss6.RW_Inspection_Status__c ='Readiness Completed';
        insPoss6.RW_SAP_Code__c = '1001R001003';
    
        insert insPoss6;
        
        InspectionAndPossessionNotificationSetup.getInspPossDetails(new List<Id>{objBking.Id});
            
        InspectionPossessionFileUploadController.deleteFiles(String.valueOf(insPoss6.Id));
        InspectionPossessionFileUploadController.getInspPossRecord(String.valueOf(insPoss6.Id));
            
            
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
        cdl.LinkedEntityId =objBking.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Map<String,String> DocDetails = new Map<String,String>();
            DocDetails.put('applicantType','Individual Buyer');
            DocDetails.put('residentialStatus','Indian National');
            DocDetails.put('bookingId',objBking.id);
            DocDetails.put('oppId',oppRec.id);
            DocDetails.put('documentType','PAN Card');
            DocDetails.put('documentId',   documents[0].id);
            DocDetails.put('InspPossId',   insPoss6.Id);
            DocDetails.put('ApplicantNumber','Primary Applicant');
      		InspectionPossessionFileUploadController.getFiles(documents[0].Id);
            InspectionPossessionFileUploadController.updateInspPossData(DocDetails);
            
        }
    }
    
      static testMethod void InspecPossTest() {
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string allstring = '[{"RW_SAP_Code__c": "1001R001009","RW_Inspection_Status__c": "Home Score Initiated","RW_PT_Int_dt__c": "2020-09-23T00:00:00"}]';
       //'[{"RW_Expected_Possession_dt__c": "2020-09-26T00:00:00.000Z","RW_SAP_Code__c": "1001R001009"}]';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring);
        RestContext.request = req;
        RestContext.response = res; 
        InspectionAPIServices.insertInspecPossession();
          
    }
    
    
  

}