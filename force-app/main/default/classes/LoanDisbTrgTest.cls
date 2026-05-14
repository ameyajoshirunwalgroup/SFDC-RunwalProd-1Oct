@isTest
public class LoanDisbTrgTest {
	@isTest
    public static void loanDisb1(){
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
                       
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
                               ProfileId = p1.id
                              );
        insert tuser1;
        
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
        insert objAcc;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        //objTower.RW_Terms_And_Conditions__c ='TC';
        objTower.Property_Type__c = 'Residential';
        insert objTower;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTower.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.Deck_Area__c = 687;
        objPUU.Utility_Area__c = 500;
        objPUU.RW_Param4__c = 'A-5504'; 
        
        insert objPUU;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=objAcc.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 05-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.RW_Project_Unit__c = objPUU.Id;
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_SDR_Status__c = 'SDR Pending';
        objBking.RW_Last_SDR_Received__c = system.today().addDays(-4);
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.Flat_No__c= 'A-5105';
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Allotment_Premium__c = 10000;
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        insert objBking;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser1.Id;
        ObjRm.Contact_Number__c='2154789622';
        insert ObjRm; 
        
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
        	hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm1.TL_Name__c = 'Apeksha Sathe';
        	hlrm1.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm1;
        	
        	Bank_with_RM__c bankRM = new Bank_with_RM__c();
        	bankRM.Name = 'Axis Bank Ltd-R Bliss';
        	bankRM.RM_Name__c = 'Kunal Kate';
        	bankRM.RM_Email__c = 'kunal@mail.com';
        	bankRM.TL_Name__c = 'Apeksha Sathe';
        	bankRM.TL_Email__c = 'apeksha@mail.com';
        	bankRM.Inactive__c = false;
        	insert bankRM;
        
        	Project_Shortforms__c proShort = new Project_Shortforms__c();
        	proShort.Name = 'Runwal Bliss';
            proShort.Short_Name__c = 'R Bliss';
        	insert proShort;
        
        	RM_Usernames__c rm = new RM_Usernames__c();
            rm.RW_Email__c = 'testrm@mail.com';
            rm.Name = 'Bliss RM';
            rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm;
        
        	RM_Usernames__c rm1 = new RM_Usernames__c();
            rm1.RW_Email__c = 'testrm@mail.com';
            rm1.Name = 'Apeksha Sathe';
            rm1.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm1.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm1;
        
        APF__c apf = new APF__c();
        apf.RW_Bank_Name__c = 'Axis Bank Ltd';
        apf.RW_Project__c = objpr.Id;
        apf.RW_Tower__c = objTower.Id;
        apf.Connector__c = 'Yes';
        apf.Connector_Fee__c = 0.40;
        apf.RW_Bank_Contact_Email_Id__c = 'test@mail.com';
        apf.RW_Relationship_Manager__c = ObjRm.Id;
        apf.Net_Gross__c = 'Gross';
        apf.Connector_Fee_for_Residential__c = 0.45;
        apf.Connector_Fee_for_Commercial__c = 1;
        apf.Ladder_Scheme__c = 'Yes';
        insert apf; 
        
        Home_Loan_Ladder__c lad = new Home_Loan_Ladder__c();
        lad.Name = 'Test Ladder';
        lad.Gross_Payout__c = 0.65;
        lad.Amount_Range_From__c = 0;
        lad.Amount_Range_To__c = 1000000000;
        lad.APF__c = apf.Id;
        insert lad;
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'Axis Bank Ltd';
        l1.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
        l1.RW_Booking__c = objBking.id;
        l1.RW_Opportunity__c = oppRec.id;
        l1.RW_Unit_No__c = objPUU.id;
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.RW_Project_Name__c = objpr.id;
        l1.HL_RM_Name__c = 'Kunal Kate';
        l1.HL_TL_Name__c = 'Apeksha Sathe';
        l1.RW_Sanction_Amount__c = 5000000;
        insert l1;
        
        Loan_Disbursement_Details__c ld = new Loan_Disbursement_Details__c();
        ld.Disbursement_Amount__c = 100000;
        ld.Disbursement_Date__c = Date.today();
        ld.Connector_Fee__c = 0.40;
        ld.Instrument_Number__c = '12458';
        ld.Loan__c = l1.Id;
        ld.Disbursement_Type__c = 'First Disbursement';
        insert ld;
        
        
        ld.Connector_Fee_Ladder__c = 0.5;
        ld.Ladder_Applied__c = false;
        update ld;
        
        HomeLoanLadder.ladder();
    }
    
    @isTest
    public static void loanDisb2(){
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
                       
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
                               ProfileId = p1.id
                              );
        insert tuser1;
        
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
        insert objAcc;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        //objTower.RW_Terms_And_Conditions__c ='TC';
        objTower.Property_Type__c = 'Commercial';
        insert objTower;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTower.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.Deck_Area__c = 687;
        objPUU.Utility_Area__c = 500;
        objPUU.RW_Param4__c = 'A-5504'; 
        
        insert objPUU;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=objAcc.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 05-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.RW_Project_Unit__c = objPUU.Id;
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_SDR_Status__c = 'SDR Pending';
        objBking.RW_Last_SDR_Received__c = system.today().addDays(-4);
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.Flat_No__c= 'A-5105';
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Allotment_Premium__c = 10000;
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        insert objBking;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser1.Id;
        ObjRm.Contact_Number__c='2154789622';
        insert ObjRm; 
        
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
        	hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm1.TL_Name__c = 'Apeksha Sathe';
        	hlrm1.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm1;
        	
        	Bank_with_RM__c bankRM = new Bank_with_RM__c();
        	bankRM.Name = 'Axis Bank Ltd-R Bliss';
        	bankRM.RM_Name__c = 'Kunal Kate';
        	bankRM.RM_Email__c = 'kunal@mail.com';
        	bankRM.TL_Name__c = 'Apeksha Sathe';
        	bankRM.TL_Email__c = 'apeksha@mail.com';
        bankRM.Inactive__c = false;
        	insert bankRM;
        
        	Project_Shortforms__c proShort = new Project_Shortforms__c();
        	proShort.Name = 'Runwal Bliss';
            proShort.Short_Name__c = 'R Bliss';
        	insert proShort;
        
        	RM_Usernames__c rm = new RM_Usernames__c();
            rm.RW_Email__c = 'testrm@mail.com';
            rm.Name = 'Bliss RM';
            rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm;
        
        	RM_Usernames__c rm1 = new RM_Usernames__c();
            rm1.RW_Email__c = 'testrm@mail.com';
            rm1.Name = 'Apeksha Sathe';
            rm1.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm1.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm1;
        
        APF__c apf = new APF__c();
        apf.RW_Bank_Name__c = 'Axis Bank Ltd';
        apf.RW_Project__c = objpr.Id;
        apf.RW_Tower__c = objTower.Id;
        apf.Connector__c = 'Yes';
        apf.Connector_Fee__c = 0.40;
        apf.RW_Bank_Contact_Email_Id__c = 'test@mail.com';
        apf.RW_Relationship_Manager__c = ObjRm.Id;
        apf.Net_Gross__c = 'Net';
        apf.Connector_Fee_for_Residential__c = 0.55;
        apf.Connector_Fee_for_Commercial__c = 1;
        insert apf; 
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'Axis Bank Ltd';
        l1.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
        l1.RW_Booking__c = objBking.id;
        l1.RW_Opportunity__c = oppRec.id;
        l1.RW_Unit_No__c = objPUU.id;
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.RW_Project_Name__c = objpr.id;
        l1.HL_RM_Name__c = 'Kunal Kate';
        l1.HL_TL_Name__c = 'Apeksha Sathe';
        l1.RW_Sanction_Amount__c = 5000000;
        insert l1;
        
        Loan_Disbursement_Details__c ld = new Loan_Disbursement_Details__c();
        ld.Disbursement_Amount__c = 100000;
        ld.Disbursement_Date__c = Date.today();
        ld.Connector_Fee__c = 0.40;
        ld.Instrument_Number__c = '12458';
        ld.Loan__c = l1.Id;
        ld.Disbursement_Type__c = 'First Disbursement';
        insert ld;
        
        delete ld;
    }
    
    @isTest
    public static void loanDisb3(){
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        
                       
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
                               ProfileId = p1.id
                              );
        insert tuser1;
        
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
        insert objAcc;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        //objTower.RW_Terms_And_Conditions__c ='TC';
        objTower.Property_Type__c = 'Residential';
        insert objTower;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTower.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.Deck_Area__c = 687;
        objPUU.Utility_Area__c = 500;
        objPUU.RW_Param4__c = 'A-5504'; 
        
        insert objPUU;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=objAcc.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.Sales_Manager_User__c= UserInfo.getUserId(); //Added by Vinay 05-12-2025
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.RW_Project_Unit__c = objPUU.Id;
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_SDR_Status__c = 'SDR Pending';
        objBking.RW_Last_SDR_Received__c = system.today().addDays(-4);
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.Flat_No__c= 'A-5105';
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Allotment_Premium__c = 10000;
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        insert objBking;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser1.Id;
        ObjRm.Contact_Number__c='2154789622';
        insert ObjRm; 
        
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
        	hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm1.TL_Name__c = 'Apeksha Sathe';
        	hlrm1.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm1;
        	
        	Bank_with_RM__c bankRM = new Bank_with_RM__c();
        	bankRM.Name = 'Axis Bank Ltd-R Bliss';
        	bankRM.RM_Name__c = 'Kunal Kate';
        	bankRM.RM_Email__c = 'kunal@mail.com';
        	bankRM.TL_Name__c = 'Apeksha Sathe';
        	bankRM.TL_Email__c = 'apeksha@mail.com';
        	bankRM.Inactive__c = false;
        	insert bankRM;
        
        	Project_Shortforms__c proShort = new Project_Shortforms__c();
        	proShort.Name = 'Runwal Bliss';
            proShort.Short_Name__c = 'R Bliss';
        	insert proShort;
        
        	RM_Usernames__c rm = new RM_Usernames__c();
            rm.RW_Email__c = 'testrm@mail.com';
            rm.Name = 'Bliss RM';
            rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm;
        
        	RM_Usernames__c rm1 = new RM_Usernames__c();
            rm1.RW_Email__c = 'testrm@mail.com';
            rm1.Name = 'Apeksha Sathe';
            rm1.RW_Reporting_1_Email__c = 'rep1@mail.com';
            rm1.RW_Reporting_2_Email__c = 'rep2@mail.com';
            insert rm1;
        
        APF__c apf = new APF__c();
        apf.RW_Bank_Name__c = 'Axis Bank Ltd';
        apf.RW_Project__c = objpr.Id;
        apf.RW_Tower__c = objTower.Id;
        apf.Connector__c = 'Yes';
        apf.Connector_Fee__c = 0.40;
        apf.RW_Bank_Contact_Email_Id__c = 'test@mail.com';
        apf.RW_Relationship_Manager__c = ObjRm.Id;
        apf.Net_Gross__c = 'Gross';
        apf.Connector_Fee_for_Residential__c = 0.45;
        apf.Connector_Fee_for_Commercial__c = 1;
        apf.Ladder_Scheme__c = 'Yes';
        insert apf; 
        
        Home_Loan_Ladder__c lad = new Home_Loan_Ladder__c();
        lad.Name = 'Test Ladder';
        lad.Gross_Payout__c = 0.65;
        lad.Amount_Range_From__c = 0;
        lad.Amount_Range_To__c = 1000000000;
        lad.APF__c = apf.Id;
        insert lad;
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'Axis Bank Ltd';
        l1.RW_Bank_Preference_1__c = 'Axis Bank Ltd';
        l1.RW_Booking__c = objBking.id;
        l1.RW_Opportunity__c = oppRec.id;
        l1.RW_Unit_No__c = objPUU.id;
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.RW_Project_Name__c = objpr.id;
        l1.HL_RM_Name__c = 'Kunal Kate';
        l1.HL_TL_Name__c = 'Apeksha Sathe';
        l1.RW_Sanction_Amount__c = 5000000;
        insert l1;
        
        Loan_Disbursement_Details__c ld = new Loan_Disbursement_Details__c();
        ld.Disbursement_Amount__c = 100000;
        ld.Disbursement_Date__c = Date.today();
        ld.Connector_Fee__c = 0.40;
        ld.Instrument_Number__c = '12458';
        ld.Loan__c = l1.Id;
        ld.Disbursement_Type__c = 'First Disbursement';
        insert ld;
        
        
        ld.Connector_Fee_Ladder__c = 0.5;
        ld.Ladder_Applied__c = true;
        update ld;
        
        //HomeLoanLadder.ladder();
    }
}