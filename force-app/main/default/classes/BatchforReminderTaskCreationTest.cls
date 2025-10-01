@isTest
public  Class BatchforReminderTaskCreationTest {
    
    
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

        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
        insert objpr;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.Name = 'Test Legal Entity';
        le.RDS_Company_Code__c = '1234';
        insert le;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';   
        objPUU.Legal_Entity__c = le.id;
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Unit Booked';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Walkin_Source__c = 'Direct';        
        objcustomer.SAP_Customer_Number__c = '789123';
        objcustomer.SalesOrder_Number__c = '789123';
        insert objcustomer;
        
        Opportunity objcustomer2= new Opportunity();
        objcustomer2.RW_Project__c=objpr.id;
        objcustomer2.name='Test 1';
        objcustomer2.StageName='Unit Booked';
        //objcustomer2.RW_Project_Unit__c=objPUU1.id;  
        objcustomer2.CloseDate=system.today();
        objcustomer2.Status__c ='Active';
        objcustomer2.AccountId = a.Id;
        objcustomer2.RW_Type_of_Client__c = 'NRI';        
        objcustomer.SAP_Customer_Number__c = '789123';
        objcustomer.SalesOrder_Number__c = '789123';
        objcustomer2.Walkin_Source__c = 'Direct';
        //objcustomer2.Duplicate_Project_Unit_Request__c = false;
        //objcustomer2.Release_Unit__c = false;
        insert objcustomer2;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer.Id;
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
        q.MLCP_Additional__c = null;
        q.Agreement_Value_for_brokers__c = 10000000;
        insert q;
        //b.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Code__c
        Booking__c b = new Booking__c();
        b.Customer__c = objcustomer.Id;
        b.Project__c = objpr.Id;
        b.Opportunity__c = objcustomer.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = a.Id;
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Direct';
        b.Allotment_Premium__c = 10000000;
        b.RW_BRL_Number__c = '35363';
        b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Date__c = system.today();
        b.RW_Total_Receipt_Amount_Received__c = 2000000;
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        objcustomer.Booking__c = b.id;
        update objcustomer;
        
        objcustomer2.Booking__c = b.id;
        update objcustomer2;
        list<Task> tskklist = new list<Task>();
        Id ReminderLetterRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Reminder letter').getRecordTypeId();
        Task task = new Task(
            Subject = 'REMINDER1',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task);
        Task task1 = new Task(
            Subject = 'REMINDER2',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task1);
        Task task2 = new Task(
            Subject = 'REMINDER3',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task2);
        Task task3 = new Task(
            Subject = 'REMINDER4',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task3);
        Task task4 = new Task(
            Subject = 'REMINDER5',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task4);
        Task task5 = new Task(
            Subject = 'REMINDER6',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task5);
        Task task6 = new Task(
            Subject = 'Default Notice',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task6);
        Task task7 = new Task(
            Subject = 'Termination',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task7);
        Task task8 = new Task(
            Subject = 'Termination',
            Status = 'In-progress',
            Priority = 'Normal',
            ActivityDate = Date.today(),
            WhatId = objcustomer.Id,
            RecordTypeId = ReminderLetterRecordTypeId
        );
        tskklist.add(task8);
        
		insert tskklist;  
        for(Task t:tskklist ){
            Test.setCreatedDate(t.Id, System.today().addDays(-1));
        }
        
            // Call the method to test
            Test.startTest();        
       
        ScheduleBatchforReminderTaskCreation obj = new ScheduleBatchforReminderTaskCreation();
        obj.execute(null);
        ScheduleReminderTaskClosure obj1 = new ScheduleReminderTaskClosure();
        obj1.execute(null);
        BatchforReminderTaskCloseonCstPayment  bb = new BatchforReminderTaskCloseonCstPayment();
        Database.executeBatch(bb,50);
        // SendNotificationtoSMforVisitFollowUp.sendCustomNotification(oppList);
        // BatchForNotificationtoSMforVisitFollowUp bb = new BatchForNotificationtoSMforVisitFollowUp();
        // Database.executeBatch(bb,1);
        Test.stopTest();
    }
}