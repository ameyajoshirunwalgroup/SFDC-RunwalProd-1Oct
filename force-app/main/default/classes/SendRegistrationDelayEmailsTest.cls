@isTest
public class SendRegistrationDelayEmailsTest {
    
    @testSetup
    static void setupTestData() {
       
        System.runAs(new User(Id = UserInfo.getUserId())) { // Run setup object DML in a separate transaction
            EmailTemplate template = new EmailTemplate();
            template.Name = 'Test Template';
            template.DeveloperName='TestTemplate';
            template.Subject = 'Test Subject {!Booking__c.Name}';
            template.HtmlValue = 'Dear {!Booking__c.Customer_Name__c}, Your booking on project {!Booking__c.RW_Project_Name__c} has been delayed. Booking Date: {!Booking__c.Booking_Date__c}, Registration Date: {!Booking__c.RW_Registration_Date__c}, Agreement Value: {!Booking__c.Agreement_Value_for_brokers__c}';
            template.TemplateType = 'custom';
            template.FolderId = UserInfo.getUserId(); // Use current user's folder
            insert template;
            
            
        }
        
        User u1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron456@radius.com', 'galvatron456@radius.com');
        Legal_Entity__c le=New Legal_Entity__c();
        le.Name='Testing';
        // le.SAP_ID__c='Test';
        //le.Project__c=objpr.id;
        insert le;
        Project__c objpr = new Project__c();
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.RDS_Company_Code__c=le.id;
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //  objpr.Project_Email_id__c = 'test@stetig.in';
        insert objpr;
        Cluster__c clusterObj=new Cluster__c();
        clusterObj.Name='Test';
        insert clusterObj;
        
        Tower__c towerObj = new Tower__c();
        towerObj.Name ='Test Tower';
        towerObj.ProjectName__c = objpr.Id;
        towerObj.Zone_Name__c = clusterObj.Id;
        insert towerObj;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.Name = 'TestUnit';
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit1';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='10';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        
        Account a = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
        insert a;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Unit Booked';
        opp.AccountId = a.Id;
        opp.Name = 'Test';
        opp.CloseDate = System.today()+10;
        insert opp;
        
        Booking__c b = new Booking__c();
        b.Opportunity__c = opp.Id;
        insert b;
        
    }
    
    @isTest
    static void testSendEmail() {
        // Fetch the test data created during @testSetup
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'Test Template' LIMIT 1];
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        
        // Prepare request
        SendRegistrationDelayEmails.EmailRequest req = new SendRegistrationDelayEmails.EmailRequest();
        req.toEmail = 'testuser@example.com'; // Replace with a valid email for the test
        req.TemplateId = template.Id;
        req.RecordId = booking.Id;
        
        // Create a list for the request
        List<SendRegistrationDelayEmails.EmailRequest> requests = new List<SendRegistrationDelayEmails.EmailRequest>{req};
        
        Test.startTest();
        // Call the method
        SendRegistrationDelayEmails.SendEmail(requests);
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testSendEmailWithoutSalesHead() {
        // Fetch the test data created during @testSetup
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'Test Template' LIMIT 1];
         
        User u2 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'luv@dius.com', 'luv@dius.com');
        Legal_Entity__c le1=New Legal_Entity__c();
        le1.Name='Testing2';
        // le.SAP_ID__c='Test';
        //le.Project__c=objpr.id;
        insert le1;
        Project__c objpr1 = new Project__c();
        objpr1.Name = 'TestProject2';
        objpr1.RDS_Short_Name__c = 'T';
        objpr1.RDS_Company_Code__c=le1.id;
        objpr1.Start_Date__c = System.today().addDays(-5);
        objpr1.RDS_Interest_Rate__c = 12;
        objpr1.Sales_Head__c  = u2.id;                                 
        insert objpr1;
        Cluster__c clusterObj1=new Cluster__c();
        clusterObj1.Name='Test2';
        insert clusterObj1;
        
        Tower__c towerObj1 = new Tower__c();
        towerObj1.Name ='Test Tower2';
        towerObj1.ProjectName__c = objpr1.id;
        towerObj1.Zone_Name__c = clusterObj1.id;
        insert towerObj1;
        
        Project_Unit_Type__c objPUT1 = new Project_Unit_Type__c();
        objPUT1.Name = 'TestUnit2';
        objPUT1.RDS_Code__c = '102';
        objPUT1.RDS_Project__c = objpr1.id;
        insert objPUT1;
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT1.id; 
        objPUU1.Name = 'TestUnit3';   
        objPUU1.RW_Project__c = objpr1.id;
        objPUU1.RW_Param1__c = '51';
        objPUU1.UnitNo__c ='101';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        
        Account a1 = new Account(lastName='portal account1', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
        insert a1;
        
        Opportunity opp1 = new Opportunity();
        opp1.StageName = 'Unit Booked';
        opp1.AccountId = a1.id;
        opp1.Name = 'Test2';
        opp1.CloseDate = System.today()+10;
        insert opp1;
        
        Booking__c b1 = new Booking__c();
        b1.Opportunity__c = opp1.id;
        b1.Project__c=objpr1.id;
        insert b1;
       
       
        SendRegistrationDelayEmails.EmailRequest req = new SendRegistrationDelayEmails.EmailRequest();
        req.toEmail = 'testuser2@example.com'; // Replace with a valid email for the test
        req.TemplateId = template.Id;
        req.RecordId = b1.id;
        
       
        List<SendRegistrationDelayEmails.EmailRequest> requests = new List<SendRegistrationDelayEmails.EmailRequest>{req};
        
        Test.startTest();
       
        SendRegistrationDelayEmails.SendEmail(requests);
        Test.stopTest();
        
       
    }
}