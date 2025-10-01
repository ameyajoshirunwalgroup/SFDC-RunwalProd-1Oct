@IsTest
public class SanctionLetterControllerTest {
    
    @testSetup   
    private static void setupdata() 
    {
        
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj;
        
        Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];
        
        
        
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
        
        List<User> u1 = [Select id, Name from User where firstname='TestUser'];
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
            
            //inserting legal Entity
            Legal_Entity__c legalEnt = new Legal_Entity__c();
            legalEnt.Name = 'Test Company Code';
            legalEnt.Account_Name_Flat_Cost__c = 'tate Private Limited Wing A Rera Escrow Account 1';
            legalEnt.Account_Name_Service_Tax__c = 'Evie Real Estate Private Limited';
            legalEnt.Account_Number_Service_tax__c =  '1630350000363';
            legalEnt.Account_Number_Flat_Cost__c = '57500000020226';
            legalEnt.Bank_Name_Flat_Cost__c = 'Bank- HDFC Bank Limited, Sion East Branch, Mumbai-400022,IFSC Code-HDFC0000163';
            legalEnt.Bank_Name_Service_tax__c = 'Bank- HDFC Bank Limited, Sion East Branch, Mumbai-400022,IFSC Code-HDFC0000163';
            legalEnt.IFSC_Code_Flat_Cost__c = 'HDFC0000163';
            legalEnt.IFSC_Code_Service_Tax__c = 'HDFC0000163';
          
            
            insert legalEnt;
            
            
            //Inserting Project
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Gardens';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Sales_Site_Head__c = tuser.Id;
            objpr.SAPMaterial_Code__c = '1211';
            objpr.Project_CRM_Lead__c = tuser.Id;
            objpr.RDS_Company_Code__c = legalEnt.Id;
            
            objpr.RW_Project_Location_Videos_Link__c='test';
            objpr.RW_Project_Brochure_PublicUrl__c='test1';
            insert objpr;
            system.debug('*2*');
            
            //Inserting Tower
            Tower__c objTower = new Tower__c();
            objTower.ProjectName__c = objpr.id;
            objTower.Name = 'A';
            objTower.SAP_Plant_Code__c = '111';
            objTower.RW_Terms_And_Conditions__c ='TC';
            insert objTower;
            system.debug('*4*');
            
            //Inserting Opportunity
            
            Opportunity oppRec= new Opportunity();
            oppRec.RW_Project__c=objpr.id;
            oppRec.name='Test 1';
            oppRec.RW_Email__c=acc.PersonEmail;
            oppRec.StageName='Qualification';
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
            insert oppRec;
            
            
            Tower__c objTwr = new Tower__c();
            objTwr.SAP_Plant_Code__c = '100';
            objTwr.Name = 'Test Tower';
            objTwr.ProjectName__c = objpr.Id;
            objTwr.RW_Floor_Plan__c='test';
            insert objTwr;
            
            Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
            objPUT.RDS_Code__c = '101';
            objPUT.RDS_Project__c = objpr.id;
            insert objPUT;
            
            Relationship_Manager__c ObjRm = new Relationship_Manager__c();
            ObjRm.Tower__c = objTwr.Id;
            ObjRm.Project__c = objpr.Id;
            ObjRm.User__c = tuser.Id;
            ObjRm.Contact_Number__c='9987654323';
            //ObjRm.Name = 'Bliss RM';
            ObjRm.Name = 'Sudhakar Nair';
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
            objPUU.Deck_Area__c = 687;
            objPUU.Utility_Area__c = 500;
            objPUU.RW_Param4__c = 'A-5504'; 
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
            q.Grand_Total__c = 70789090;
            q.Stamp_Duty_and_Registration_Total__c = 789090;
            
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
            objBking.Booking_Date__c = Date.today().addDays(-1);
            objBking.Sales_Manager__c= tuser.Id;
            objBking.Status__c ='Booking Confirmed';
            objBking.RW_SDR_Status__c = 'SDR Pending';
            objBking.RW_Last_SDR_Received__c = system.today().addDays(-4);
            objBking.RW_Total_Interest_Amount_Waived__c=6736;
            objBking.RW_Total_Collectable_Interest__c=6757;
            objBking.RW_Total_Amount_Collected__c=75757;
            objBking.RW_Total_Amount_Balance__c=75757;
            objBking.RW_Total_TDS_Due__c=56565;
            objBking.Floor__c=3;
            objBking.RW_Agreement_Status__c='Approved';
            objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
           // objBking.RW_Registration_Status__c = 'Registration Completed'
            
            objBking.Loan_Bank__c = 'Bank Of Baroda';
            objBking.Flat_No__c = '2891';
            objBking.Allotment_Premium__c = 100000;
            //objBking.Token_Amount__c = 10000;
            
            objBking.Source_of_Booking__c='Direct';
            objBking.Carpet_Area__c=23;
            insert objBking;
            
            //Added by Vinay 16-03-2022 start
            
            Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        	hlrm.Name = 'Kunal Kate';
        	hlrm.Project__c = objpr.Id;
        	//hlrm.User__c = '0051e000002B3lvAAC';
            hlrm.User__c = '0055j000003mmhYAAQ';
            hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm.TL_Name__c = 'Apeksha Sathe';
        	hlrm.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm;
        	
        	Home_Loan_RM__c hlrm1 = new Home_Loan_RM__c();
        	hlrm1.Name = 'Apeksha Sathe';
        	hlrm1.Project__c = objpr.Id;
        	insert hlrm1;
            
            Bank_with_RM__c bankRM = new Bank_with_RM__c();
            bankRM.Name = 'Bank of Baroda-R Gardens';
            bankRM.RM_Name__c = 'Kunal Kate';
            bankRM.RM_Email__c = 'kunal@mail.com';
            bankRM.TL_Name__c = 'Apeksha Sathe';
            bankRM.TL_Email__c = 'apksha@mail.com';
            insert bankRM;
            
            Project_Shortforms__c proShort = new Project_Shortforms__c();
        	proShort.Name = 'Runwal Gardens';
            proShort.Short_Name__c = 'R Gardens';
        	insert proShort;
            
            RM_Usernames__c rm = new RM_Usernames__c();
            rm.RW_Email__c = 'testrm@mail.com';
            //rm.Name = u1[0].Name;
            rm.Name = 'TestUser1 TestUser2';
            rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm;
            
            //Added by Vinay 16-03-2022 end
            
            
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
              
             APF__c apf = new APF__c();
             apf.RW_Bank_Name__c = 'ICICI Bank';
             apf.RW_Project__c = objpr.Id;
             apf.RW_Tower__c = objTwr.Id;
             apf.RW_Relationship_Manager__c = ObjRm.Id;

             insert apf; 
            system.debug('insert apf ****' + apf);
        }
        
    } 
    
	@IsTest
    private static void testSanctionLtrCtrlr(){
        
        Test.startTest();
        List<Project__c> proj = [Select id, CRMHead__r.Email,Sales_Site_Head__r.Email from Project__c];
        List<Booking__c> book = [Select id, Sales_Manager__r.Email from Booking__c];
        List<Opportunity> opp = [Select id from Opportunity];
        List<Project_Unit__c> Unit = [Select id,Relationship_Manager__r.RM_Email__c from Project_Unit__c];
        List<Tower__c> tower = [Select id from Tower__c];
        
        List<Loan__c> testloan = new List<Loan__c>();
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'Bank Of Baroda';
        l1.RW_Bank_Preference_1__c = 'Bank Of Baroda';
        l1.RW_Booking__c = book[0].id;
        l1.RW_Opportunity__c = opp[0].id;
        l1.RW_Unit_No__c = Unit[0].id;
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.RW_Project_Name__c = proj[0].id;
        l1.HL_RM_Name__c = 'Kunal Kate';
        l1.HL_TL_Name__c = 'Apeksha Sathe';
        l1.Home_Loan_Taken_From__c = 'Runwal';
        insert l1;
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'SalarySLip',
          PathOnClient = 'SalarySLip.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        


        SanctionLetterController.getLoanRecord(l1.Id);
        
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('loanId',l1.Id);
        DocDetails.put('documentId',documents[0].id);
        SanctionLetterController.updateTPAData(DocDetails);
        SanctionLetterController.getFiles(documents[0].id);
        SanctionLetterController.deleteTPAFiles(documents[0].id);
        
         ContentVersion contentVersion1 = new ContentVersion(
          Title = 'SalarySLip',
          PathOnClient = 'SalarySLip.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion1;    
        List<ContentDocument> documents1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        SanctionLetterController.updateSanctionData(DocDetails);
        SanctionLetterController.deleteFiles(documents1[0].id);
        
        CustomerPortalHomeController.updateLoanRecord(DocDetails);
        Test.stoptest();
    }
}