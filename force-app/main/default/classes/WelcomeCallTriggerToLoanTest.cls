@IsTest
public class WelcomeCallTriggerToLoanTest {

    @IsTest
    private static void testLoanCreation(){
        BookingTriggerHandler.bypass=true;
        
        Profile p = [Select Id, Name from Profile where Name = 'Home Loan'];

    	String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(  firstname = 'TestUser1',
                               lastName = 'TestUser2',
                               email = uniqueName + '@gmail' +'.com',
                               Username = uniqueName + '@test1' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p.id
                              );
        insert u;
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
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
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        	
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
            objTower.RW_Terms_And_Conditions__c ='TC';
            insert objTower;
        
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
            ObjRm.Tower__c = objTower.Id;
            ObjRm.Project__c = objpr.Id;
            //ObjRm.User__c = tuser.Id;
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
            //objPUU.RW_Customer__c = oppRec.Id;
            objPUU.RW_Base_Rate__c = 3000;
            objPUU.Floor_Rise__c = 0;
            objPUU.RW_PLC__c = 200;
            objPUU.Unit_SAP_Code__c = '1000';
          //  objPUU.Relationship_Manager__c = ObjRm.Id;
            objPUU.Carpet_Area__c = 786;
            objPUU.Deck_Area__c = 687;
            objPUU.Utility_Area__c = 500;
            objPUU.RW_Param4__c = 'A-5504'; 
            insert objPUU;
            
        
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
        	oppRec.RW_Project_Unit__c = objPUU.Id;
            insert oppRec;
            
        	
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
            //objBking.Sales_Manager__c= tuser.Id;
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
           // objBking.RW_Registration_Status__c = 'Registration Completed'
            
            
            objBking.Source_of_Booking__c='Direct';
            objBking.Carpet_Area__c=23;
            insert objBking;
        
        	
            
        	Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        	hlrm.Name = 'Kunal Kate';
        	hlrm.Project__c = objpr.Id;
        	hlrm.User__c = u.Id;
        	//hlrm.User__c = '0051e000002B3lvAAC';
            //hlrm.User__c = '0055j000003mmhYAAQ';
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
        	
        	Loan__c ln =  new Loan__c();
        	ln.RW_Booking__c = objBking.Id;
            ln.RW_Opportunity__c = oppRec.Id;
            ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
            ln.RW_Project_Name__c = objpr.Id;
            ln.RW_Unit_No__c = objPUU.id;
        	//insert ln;
            System.debug('ln.RW_Booking__c: ' + ln.RW_Booking__c);
        
            RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
            wcObj.RW_Booking__c = objBking.Id;
        	wcObj.Booking_Id__c = objBking.Id;
            wcObj.RW_Welcome_Call_Status__c = 'Accept';
        	wcObj.RW_Mode_of_funding__c = 'Bank Loan';
        	wcObj.RW_Banking_Preference_for_Loan__c = 'Axis Bank Ltd,Andhra Pradesh State Co-operative Bank,Bajaj Housing Finance Ltd';
        	wcObj.RW_Applicant1_Email_Address__c = 'testapp1@gmail.com';
        	wcObj.RM_email__c = 'testrm@gmail.com';
        	wcObj.RW_Project__c = 'Runwal Bliss';
            insert wcObj;
        
        	
        	
        	//wcObj.RW_Welcome_Call_Status__c = 'Due';
        	//update wcObj;
            
            
    }
    
    @IsTest
    private static void testLoanCreationOnWelCallUpdate(){
        BookingTriggerHandler.bypass=true;
        
        Profile p = [Select Id, Name from Profile where Name = 'Home Loan'];

    	String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(  firstname = 'TestUser1',
                               lastName = 'TestUser2',
                               email = uniqueName + '@gmail' +'.com',
                               Username = uniqueName + '@test1' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p.id
                              );
        insert u;
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
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
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        	
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
            objTower.RW_Terms_And_Conditions__c ='TC';
            insert objTower;
        
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
            ObjRm.Tower__c = objTower.Id;
            ObjRm.Project__c = objpr.Id;
            //ObjRm.User__c = tuser.Id;
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
            //objPUU.RW_Customer__c = oppRec.Id;
            objPUU.RW_Base_Rate__c = 3000;
            objPUU.Floor_Rise__c = 0;
            objPUU.RW_PLC__c = 200;
            objPUU.Unit_SAP_Code__c = '1000';
          //  objPUU.Relationship_Manager__c = ObjRm.Id;
            objPUU.Carpet_Area__c = 786;
            objPUU.Deck_Area__c = 687;
            objPUU.Utility_Area__c = 500;
            objPUU.RW_Param4__c = 'A-5504'; 
            insert objPUU;
            
        
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
        	oppRec.RW_Project_Unit__c = objPUU.Id;
            insert oppRec;
            
        	
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
            //objBking.Sales_Manager__c= tuser.Id;
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
           // objBking.RW_Registration_Status__c = 'Registration Completed'
            
            
            objBking.Source_of_Booking__c='Direct';
        	objBking.Loan_Bank__c = 'Axis Bank Ltd';
            objBking.Carpet_Area__c=23;
            insert objBking;
        
        	
            
        	Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        	hlrm.Name = 'Kunal Kate';
        	hlrm.Project__c = objpr.Id;
        	hlrm.User__c = u.Id;
        	//hlrm.User__c = '0051e000002B3lvAAC';
        	//hlrm.User__c = '0055j000003mmhYAAQ';
        	hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm.TL_Name__c = 'Apeksha Sathe';
        	hlrm.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm;
        	
        	Home_Loan_RM__c hlrm1 = new Home_Loan_RM__c();
        	hlrm1.Name = 'Apeksha Sathe';
        	hlrm1.Project__c = objpr.Id;
        	hlrm1.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm1.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm1.TL_Name__c = 'Apeksha Sathe';
        	hlrm1.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm1;
        	
        	Bank_with_RM__c bankRM = new Bank_with_RM__c();
        	bankRM.Name = 'Axis Bank Ltd-R Bliss';
        	bankRM.RM_Name__c = 'Kunal Kate';
        	bankRM.RM_Email__c = 'kunal@mail.com';
        	bankRM.TL_Name__c = 'Apeksha Sathe';
        	bankRM.TL_Email__c = 'apeksha@mail.com';
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
        	
        	        
            RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
            wcObj.RW_Booking__c = objBking.Id;
        	wcObj.Booking_Id__c = objBking.Id;
            wcObj.RW_Welcome_Call_Status__c = 'Due';
        	wcObj.RW_Mode_of_funding__c = 'Bank Loan';
        	wcObj.RW_Banking_Preference_for_Loan__c = 'Axis Bank Ltd,Andhra Pradesh State Co-operative Bank,Bajaj Housing Finance Ltd';
        	wcObj.RW_Applicant1_Email_Address__c = 'testapp1@gmail.com';
        	wcObj.RM_email__c = 'testrm@gmail.com';
        	wcObj.RW_Project__c = 'Runwal Bliss';
            insert wcObj;
        try{
        	wcObj.RW_Welcome_Call_Status__c = 'Accept';
        	update wcObj;		
        }catch(Exception ex){
            
        }
    }
    
    @IsTest
    private static void testBookingTrgHandler(){
        BookingTriggerHandler.bypass=true;
        Profile p = [Select Id, Name from Profile where Name = 'Home Loan'];

    	String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(  firstname = 'TestUser1',
                               lastName = 'TestUser2',
                               email = uniqueName + '@gmail' +'.com',
                               Username = uniqueName + '@test1' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p.id
                              );
        insert u;
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
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
            
            Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        	
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
            objTower.RW_Terms_And_Conditions__c ='TC';
            insert objTower;
        
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
            ObjRm.Tower__c = objTower.Id;
            ObjRm.Project__c = objpr.Id;
            //ObjRm.User__c = tuser.Id;
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
            //objPUU.RW_Customer__c = oppRec.Id;
            objPUU.RW_Base_Rate__c = 3000;
            objPUU.Floor_Rise__c = 0;
            objPUU.RW_PLC__c = 200;
            objPUU.Unit_SAP_Code__c = '1000';
          //  objPUU.Relationship_Manager__c = ObjRm.Id;
            objPUU.Carpet_Area__c = 786;
            objPUU.Deck_Area__c = 687;
            objPUU.Utility_Area__c = 500;
            objPUU.RW_Param4__c = 'A-5504'; 
        	objPUU.RW_Booking_Date__c = Date.today().addDays(-1);
            insert objPUU;
            
        
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
        	oppRec.RW_Project_Unit__c = objPUU.Id;
            insert oppRec;
            
        	
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
            //objBking.Sales_Manager__c= tuser.Id;
            objBking.Status__c ='Booking Received';
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
           // objBking.RW_Registration_Status__c = 'Registration Completed'
            
            
            objBking.Source_of_Booking__c='Direct';
        	objBking.Loan_Bank__c = 'Axis Bank Ltd';
            objBking.Carpet_Area__c=23;
            insert objBking;
        
        	Booking__c objBkingUpdate = new Booking__c();
        	objBkingUpdate.Id = objBking.Id;
        	objBkingUpdate.Customer__c = oppRec.Id;
        	objBkingUpdate.Project__c = objpr.Id;
            objBkingUpdate.Opportunity__c = oppRec.Id;
            objBkingUpdate.Unit_No__c = objPUU.id;
            objBkingUpdate.Quotation__c = q.Id;
            objBkingUpdate.Receipts__c = r1.Id;
        	objBkingUpdate.Status__c ='Booking Confirmed';
        	objBkingUpdate.Booking_Date__c = Date.today().addDays(-1);
            objBkingUpdate.RW_SDR_Status__c = 'SDR Pending';
            objBkingUpdate.RW_Last_SDR_Received__c = system.today().addDays(-4);
            objBkingUpdate.RW_Total_Interest_Amount_Waived__c=6736;
            objBkingUpdate.RW_Total_Collectable_Interest__c=6757;
            objBkingUpdate.RW_Total_Amount_Collected__c=75757;
            objBkingUpdate.RW_Total_Amount_Balance__c=75757;
            objBkingUpdate.RW_Total_TDS_Due__c=56565;
            objBkingUpdate.Floor__c=3;
        	objBkingUpdate.Flat_No__c= 'A-5105';
            objBkingUpdate.RW_Agreement_Status__c='Approved';
            objBkingUpdate.RW_Signed_Agreement_Document_Id__c ='00690000454';
        	objBkingUpdate.Allotment_Premium__c = 10000;
            objBkingUpdate.Source_of_Booking__c='Direct';
        	objBkingUpdate.Loan_Bank__c = 'Axis Bank Ltd';
            objBkingUpdate.Carpet_Area__c=23;
        	update objBkingUpdate;
			
        	oppRec.Booking__c = objBkingUpdate.Id;
        	update oppRec;
            
        	Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        	hlrm.Name = 'Kunal Kate';
        	hlrm.Project__c = objpr.Id;
        	hlrm.User__c = u.Id;
        	//hlrm.User__c = '0051e000002B3lvAAC';
            //hlrm.User__c = '0055j000003mmhYAAQ';
            hlrm.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm.TL_Name__c = 'Apeksha Sathe';
        	hlrm.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm;
        	
        	Home_Loan_RM__c hlrm1 = new Home_Loan_RM__c();
        	hlrm1.Name = 'Apeksha Sathe';
        	hlrm1.Project__c = objpr.Id;
        	hlrm1.Reporting_1_Email__c = 'rep1@mail.com';
            hlrm1.Reporting_2_Email__c = 'rep2@mail.com';
            hlrm1.TL_Name__c = 'Apeksha Sathe';
        	hlrm1.TL_Email__c = 'apeksha@mail.com';
        	insert hlrm1;
        	
        	Bank_with_RM__c bankRM = new Bank_with_RM__c();
        	bankRM.Name = 'Axis Bank Ltd-R Bliss';
        	bankRM.RM_Name__c = 'Kunal Kate';
        	bankRM.RM_Email__c = 'kunal@mail.com';
        	bankRM.TL_Name__c = 'Apeksha Sathe';
        	bankRM.TL_Email__c = 'apeksha@mail.com';
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
        	
        
        	BookingTriggerHandler bk =  new BookingTriggerHandler();
        	BookingTriggerHandler.byPass = false;
        	bk.processRecords(new List<Booking__c>{objBking}, new Map<Id,Booking__c>{objBking.Id => objBking}, new Map<Id, Booking__c>{objBking.Id => objBking});
        
        	bk.processRecords(new List<Booking__c>{objBkingUpdate}, new Map<Id,Booking__c>{objBkingUpdate.Id => objBkingUpdate}, new Map<Id, Booking__c>{objBking.Id => objBking});
        	
        	          
    }
    
     
}