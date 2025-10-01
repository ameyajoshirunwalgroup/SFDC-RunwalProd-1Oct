@isTest
public class BatchSAPPaymentInterfaceTest 
{
	
    
   /*  @testsetup
    private static void setupdata()
    {
        
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    	User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;
        
        String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.id
                            );
         insert tuser;
        
        opportunity objcustomer1= new Opportunity();
 		Project__c objpr;
        Tower__c objTwr;
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objCustomer1.Walk_in_Source__c = 'Channel Partner';
            //objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c ='87654323';
        insert objcustomer1;
        
        
        //Opportunity opp = [Select id from Opportunity][0];
        List<RW_Payment_Details__c> payList = new List<RW_Payment_Details__c>();
        for (Integer i=0;i<150;i++) 
        {
        RW_Payment_Details__c m = new RW_Payment_Details__c(RW_Accounting_Document_Number__c = 'test' + i,RW_Payment_Amount__c='1000',RW_Document_Type__c='DE',Opportunity__c =objcustomer1.Id);
        payList.add(m);
        }
        insert payList;
	}*/
    
    
        @isTest
    private static void testBatchSAPPaymentInterface() 
    {
        /*
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
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        insert objpr;
        
       // List<Opportunity> oppRecords = [Select id from Opportunity];
        Opportunity opp = new Opportunity();
        opp.AccountId = a.Id;
        opp.Name='Test';
        opp.SAP_Customer_Number__c ='87654323';
        opp.StageName='Qualification';
        opp.RW_Project__c = objpr.Id;
        insert opp;
        //List<Tower__c> towerRecords = [Select id from Tower__c];

       //List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=opp.id;
        //eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
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
        
        
        
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu3871@gmail.com';
        insert teamMembers;
        */
      /*  
        Account a = new Account();
        List<Account> accList = new List<Account>();
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
        accList.add(a);
        insert accList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountId = accList[0].Id;
        opp.Name='Test';
        opp.SAP_Customer_Number__c ='87654323';
        opp.StageName='Qualification';
       // opp.RW_Project__c = objpr.Id;
       oppList.add(opp);
        insert oppList;
        */
       
        List<RW_Payment_Details__c> payList = new List<RW_Payment_Details__c>();
        for (Integer i=0;i<150;i++) 
        {
        RW_Payment_Details__c m = new RW_Payment_Details__c(RW_Accounting_Document_Number__c = 'test' + i,RW_Payment_Amount__c=1000,RW_Document_Type__c='DE');
        payList.add(m);
        }
        insert payList;
       
     
            Test.startTest();
             Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
            //ScheduleBatchSAPPaymentInterface sc = new ScheduleBatchSAPPaymentInterface();
            //Define cron expression
            //String cronExp = '0 0,30 * * * *';
            //String jobID = System.schedule('Run Payment Interface', cronExp, sc);
 
           /* ScheduleBatchSAPPaymentInterface abs= new ScheduleBatchSAPPaymentInterface();
            String cronExpr = '0 0 * * * ?';
            String jobId = System.schedule('myJobTestJobName', cronExpr, abs);
            abs.execute(null);*/
            BatchSAPPaymentInterface c = new BatchSAPPaymentInterface();
            Database.executeBatch(c);
            
            Test.stopTest();
     
        
        
    }
    
   
}