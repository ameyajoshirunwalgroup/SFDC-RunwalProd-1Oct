@isTest
public  Class SendNotificationtoSMforVisitFollowUpTest {
    @isTest  
    static void TaskTest() {
    Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
       // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        // List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
        Profile pr = [Select Id,Name from Profile where Name = 'NRI Sales Manager'];
        
        User u = new User();
        u.Username = 'test123@stetig.in';
        u.LastName = 'Test';
        u.Email = 'test@stetig.in';
        u.Alias = 'Test';
        u.EmailEncodingKey='UTF-8';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LanguageLocaleKey='en_US';
        if(pr.Id != null){
            u.ProfileId = pr.Id;
        }
        insert u;
        Opportunity o = new Opportunity(Name = 'Opp-1',RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Qualification', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
        insert o;
        list<Opportunity> oList = new list<Opportunity>{o};
        system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
        
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5)
        );
        insert task;
        
        
        Test.startTest(); 
        
        SendNotificationtoSMforVisitFollowUp.sendCustomNotification(oList);
        BatchForNotificationtoSMforVisitFollowUp bb = new BatchForNotificationtoSMforVisitFollowUp();
        Database.executeBatch(bb,1);

        Test.stopTest();
 
  }
    
    @isTest
    static void TaskTest2() {
        // Create mock users with different profiles
        //Profile salesProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Profile']; // Replace with the correct profile name
        Profile nriProfile = [SELECT Id FROM Profile WHERE Name = 'NRI Sales Manager']; // Replace with the correct profile name
        Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);

        User salesUser = new User(
            LastName = 'Test',
            Email = 'test.sales@example.com',
            Username = 'test.sales@example.com' + System.currentTimeMillis(),
            Alias = 'tsales',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = nriProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert salesUser;

        User nriSalesManager = new User(
            LastName = 'Test',
            Email = 'test.nri@example.com',
            Username = 'test.nri@example.com' + System.currentTimeMillis(),
            Alias = 'tnri',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = nriProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert nriSalesManager;


        Opportunity opp2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(10),
            RW_Sales_Associate__c = 'Test', // Replace with appropriate field if necessary
            Date_Of_Visit__c = Date.today().addDays(-1),
            AccountId =acc.Id,
            RW_CIF_form_number__c = '12222',
            RW_Project__c = P.Id
            
        );
        insert opp2;
        
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5)
        );
        insert task;
        
        
        List<Opportunity> oppList = new List<Opportunity>{opp2};

        // Call the method to test
        Test.startTest();
        SendNotificationtoSMforVisitFollowUp.sendCustomNotification(oppList);
        BatchForNotificationtoSMforVisitFollowUp bb = new BatchForNotificationtoSMforVisitFollowUp();
        Database.executeBatch(bb,1);
        Test.stopTest();
    }
}