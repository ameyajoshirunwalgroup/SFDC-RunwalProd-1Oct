@isTest
public class NOCTemplateControllerTest {
  
    @isTest   
    private static void nocTest() {
        
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
            
            Booking__c objBking = new Booking__c();
            objBking.Customer__c = oppRec.Id;
            objBking.Project__c = objpr.Id;
            objBking.Opportunity__c = oppRec.Id;
            objBking.Unit_No__c = objPUU.id;
            objBking.Quotation__c = q.Id;
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
            objBking.RW_Loan_Bank__c = 'Bank Of Baroda';
            objBking.Loan_Bank__c = 'Bank Of Baroda';
            objBking.Flat_No__c = '2891';
            objBking.Allotment_Premium__c = 100000;
            objBking.Source_of_Booking__c='Direct';
            objBking.Carpet_Area__c=23;
            objBking.RW_Registration_Status__c = 'Registration Completed';
            objBking.RW_Signed_Agreement_to_Customer_Date__c = Date.today();
            insert objBking;
            
            Booking__c objBking1 = new Booking__c();
            objBking1.Customer__c = oppRec.Id;
            objBking1.Project__c = objpr.Id;
            objBking1.Opportunity__c = oppRec.Id;
            objBking1.Unit_No__c = objPUU.id;
            objBking1.Quotation__c = q.Id;
            objBking1.Booking_Date__c = Date.today().addDays(-1);
            objBking1.Sales_Manager__c= tuser.Id;
            objBking1.Status__c ='Booking Confirmed';
            objBking1.RW_SDR_Status__c = 'SDR Pending';
            objBking1.RW_Last_SDR_Received__c = system.today().addDays(-4);
            objBking1.RW_Total_Interest_Amount_Waived__c=6736;
            objBking1.RW_Total_Collectable_Interest__c=6757;
            objBking1.RW_Total_Amount_Collected__c=75757;
            objBking1.RW_Total_Amount_Balance__c=75757;
            objBking1.RW_Total_TDS_Due__c=56565;
            objBking1.Floor__c=3;
            objBking1.RW_Agreement_Status__c='Approved';
            objBking1.RW_Signed_Agreement_Document_Id__c ='00690000454';
            objBking1.RW_Loan_Bank__c = 'Bank Of Baroda';
            objBking1.Loan_Bank__c = 'Bank Of Baroda';
            objBking1.Flat_No__c = '2891';
            objBking1.Allotment_Premium__c = 100000;
            objBking1.Source_of_Booking__c='Direct';
            objBking1.Carpet_Area__c=23;
            objBking1.RW_Registration_Status__c = 'Registration Completed';
            objBking1.RW_Signed_Agreement_to_Customer_Date__c = Date.today();
            insert objBking1;
        	
              
             APF__c apf = new APF__c();
             apf.RW_Bank_Name__c = 'ICICI Bank';
             apf.RW_Project__c = objpr.Id;
             apf.RW_Tower__c = objTwr.Id;
             apf.RW_Relationship_Manager__c = ObjRm.Id;

             insert apf; 
            system.debug('insert apf ****' + apf);
            
            Loan__c ln = new Loan__c();
            ln.RW_Booking__c = objBking.Id;
            ln.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
            ln.RW_Bank_Name__c = 'Axis Bank Ltd';
            ln.RW_Project_Name__c = objpr.Id;
            ln.RW_Loan_Record_Status__c = 'Loan Sanctioned';
            ln.RW_Sanction_Letter_ID__c = '1234567';
            ln.Home_Loan_Taken_From__c = 'Runwal';
            insert ln;
            
            Loan__c ln1 = new Loan__c();
            ln1.RW_Booking__c = objBking1.Id;
            ln1.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
            ln1.RW_Bank_Name__c = 'Axis Bank Ltd';
            ln1.RW_Project_Name__c = objpr.Id;
            ln1.RW_Loan_Record_Status__c = 'Loan Sanctioned';
            ln1.RW_Sanction_Letter_ID__c = '1234567';
            ln1.Home_Loan_Taken_From__c = 'Runwal';
            insert ln1;
            
            RW_NOC_Template__c nocTemp = new RW_NOC_Template__c();
            nocTemp.RW_Bank_Name__c = 'Axis Bank Ltd';
            nocTemp.RW_Project__c = objpr.Id;
            nocTemp.RW_Keyword__c = '[AgreementAmount],[AgreementDate],[BankName],[FlatNo],[Today],[ApplicantNames],[CarpetArea]';
            nocTemp.RW_Template__c = '[AgreementAmount] [AgreementDate] [BankName] [FlatNo] [Today] [ApplicantNames] [CarpetArea]';
            insert nocTemp;
            
            NOC_Variable_Mapping__c nocMap1 = new NOC_Variable_Mapping__c();
            nocMap1.Name = '[AgreementAmount]';
            nocMap1.Field__c = 'RW_Booking__r.Quotation__r.Agreement_Value__c';
            nocMap1.Decimal_Places__c = 2;
            insert nocMap1;
            
            NOC_Variable_Mapping__c nocMap2 = new NOC_Variable_Mapping__c();
            nocMap2.Name = '[AgreementDate]';
            nocMap2.Field__c = 'RW_Booking__r.RW_Signed_Agreement_to_Customer_Date__c';
            nocMap2.Is_Date__c = true;
            insert nocMap2;
            
            NOC_Variable_Mapping__c nocMap3 = new NOC_Variable_Mapping__c();
            nocMap3.Name = '[BankName]';
            nocMap3.Field__c = 'RW_Bank_Name__c';
            insert nocMap3;
            
            NOC_Variable_Mapping__c nocMap4 = new NOC_Variable_Mapping__c();
            nocMap4.Name = '[FlatNo]';
            nocMap4.Field__c = 'RW_Booking__r.Unit_No__r.RW_Param4__c';
            insert nocMap4;
            
            NOC_Variable_Mapping__c nocMap5 = new NOC_Variable_Mapping__c();
            nocMap5.Name = '[Today]_Fixed';
            nocMap5.Field__c = '';
            insert nocMap5;
            
            NOC_Variable_Mapping__c nocMap6 = new NOC_Variable_Mapping__c();
            nocMap6.Name = '[ApplicantNames]_Fixed';
            nocMap6.Field__c = '';
            insert nocMap6;
            
            NOC_Variable_Mapping__c nocMap10 = new NOC_Variable_Mapping__c();
            nocMap10.Name = '[CarpetArea]';
            nocMap10.Field__c = 'RW_Booking__r.Unit_No__r.Carpet_Area__c';
            nocMap10.Multiplier__c = 0.1;
            insert nocMap10;
            
            /*NOC_Variable_Mapping__c nocMap7 = new NOC_Variable_Mapping__c();
            nocMap7.Name = '[BranchName]';
            nocMap7.Field__c = 'RW_Bank_Branch__c';
            insert nocMap7;
            
            NOC_Variable_Mapping__c nocMap8 = new NOC_Variable_Mapping__c();
            nocMap8.Name = '[TowerName]';
            nocMap8.Field__c = 'RW_Booking__r.Unit_No__r.TowerName__r.name';
            insert nocMap8;
            
            NOC_Variable_Mapping__c nocMap9 = new NOC_Variable_Mapping__c();
            nocMap9.Name = '[ProjectName]';
            nocMap9.Field__c = 'RW_Project_Name__r.name';
            insert nocMap9;
            
            NOC_Variable_Mapping__c nocMap10 = new NOC_Variable_Mapping__c();
            nocMap10.Name = '[CarpetArea]';
            nocMap10.Field__c = 'RW_Booking__r.Unit_No__r.Carpet_Area__c';
            insert nocMap10;
            
            NOC_Variable_Mapping__c nocMap11 = new NOC_Variable_Mapping__c();
            nocMap11.Name = '[DeckArea]';
            nocMap11.Field__c = 'RW_Booking__r.Unit_No__r.Deck_Area__c';
            insert nocMap11;
            
            NOC_Variable_Mapping__c nocMap12 = new NOC_Variable_Mapping__c();
            nocMap12.Name = '[UtilityArea]';
            nocMap12.Field__c = 'RW_Booking__r.Unit_No__r.Utility_Area__c';
            insert nocMap12;
            
            NOC_Variable_Mapping__c nocMap13 = new NOC_Variable_Mapping__c();
            nocMap13.Name = '[FloorNo]';
            nocMap13.Field__c = 'RW_Booking__r.Unit_No__r.New_Floor__c';
            insert nocMap13;
            
            NOC_Variable_Mapping__c nocMap14 = new NOC_Variable_Mapping__c();
            nocMap14.Name = '[CheqAccount]';
            nocMap14.Field__c = 'RW_Project_Name__r.RDS_Company_Code__r.Account_Name_Flat_Cost__c';
            insert nocMap14;
            
            NOC_Variable_Mapping__c nocMap15 = new NOC_Variable_Mapping__c();
            nocMap15.Name = '[BranchAddress]';
            nocMap15.Field__c = 'Bank_Address_for_NOC__c';
            insert nocMap15;*/
            
            
            pageReference pageRef = page.NocTemplate;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id',ln.Id);
            NOCTemplateController noc = new NOCTemplateController();
            //noc.NOCTable();
            noc.downloadPdf();
            
            pageReference pageRef1 = page.NocTemplate;
            Test.setCurrentPage(pageRef1);
            ApexPages.currentPage().getParameters().put('id',ln1.Id);
            NOCTemplateControllerNew noc1 = new NOCTemplateControllerNew();
        }
        
    }  
}