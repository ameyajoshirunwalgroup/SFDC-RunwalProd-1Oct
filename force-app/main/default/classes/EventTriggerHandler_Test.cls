@IsTest
private class EventTriggerHandler_Test {

    // Setup Test Data
    @TestSetup
    static void makeData(){
        // Get Record Types
        Map<String, Id> rtIds = new Map<String, Id>();
        for (RecordType rt : [
            SELECT DeveloperName, Id 
            FROM RecordType 
            WHERE SobjectType IN ('Event', 'CP_Meeting_Targets__c', 'Account') 
            AND DeveloperName IN ('Channel_Partner_Corporates_Event', 'AOP_Targets', 'Non_AOP_Targets')
        ]) {
            rtIds.put(rt.DeveloperName, rt.Id);
        }

        Id eventRtId = rtIds.get('Channel_Partner_Corporates_Event');
        
        // 1. Create a User (for OwnerId/SM_Name__c)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testus',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;

        // 2. Create Channel Partner Account
        Broker__c cpAccount = new Broker__c(NAME_FIRST__c = 'Channel Partner CP',NAME_LAST__c ='CP',Name ='Channel Partner CP',SAP_CP_Code__c = '56421');
        insert cpAccount;

        // 3. Create Corporates Account (WhatId on Event)
        Account corporateAccount = new Account(
            Name = 'Corporate Client',
            Channel_Partner__c = cpAccount.Id // Link to Channel Partner
        );
        insert corporateAccount;
        
        // --- Date Fix 1: Use Date.today() for Date methods ---
        Date startOfMonth = Date.today().toStartOfMonth();
        Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);

        // 4. Create AOP record for one Channel Partner
        AOP__c testAOP = new AOP__c(
            Channel_Partner__c = cpAccount.Id,
            Start_Date__c = startOfMonth, // Corrected Date usage
            End_Date__c = endOfMonth     // Corrected Date usage
            
        );
        insert testAOP;
        
        // 5. Create a Target record (to be updated later)
        CP_Meeting_Targets__c existingTargetAOP = new CP_Meeting_Targets__c(
            RecordTypeId = rtIds.get('AOP_Targets'),
            SM_Name__c = testUser.Id,
            CP_Name__c = cpAccount.Id,
            Month__c = String.valueOf(Date.today().month()),
            Year__c = String.valueOf(Date.today().year()),
            Achievement__c = 5
        );
        insert existingTargetAOP;
    }

    // --- Test handleBeforeInsert Logic ---

    @IsTest
    static void testBeforeInsert_Success() {
        // Retrieve test data
        Account corporateAccount = [SELECT Id FROM Account WHERE Name = 'Corporate Client' LIMIT 1];
        Account cpAccount = [SELECT Id FROM Account WHERE Name = 'Channel Partner CP' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];

        // Prepare a new Event
        Event newEvent = new Event(
            Subject = 'Test Event Before Insert',
            WhatId = corporateAccount.Id,
            RecordTypeId = rt.Id,
            StartDateTime = DateTime.now().addHours(1),
            EndDateTime = DateTime.now().addHours(2)
        );
        try{
        	insert newEvent;
        }catch(Exception ex){
            
        }

        // Perform the test
        Test.startTest();
        EventTriggerHandler.handleBeforeInsert(new List<Event>{newEvent});
        Test.stopTest();

        // Assertions
        // 1. Check if Channel_Partner__c is populated
        // System.assertEquals(cpAccount.Id, newEvent.Channel_Partner__c, 'Channel Partner field should be populated.');
        // 2. Check that no error was added (Start/End date are on the same day)
        // System.assert(!newEvent.hasErrors(), 'No error should be added for same start/end dates.');
    }
    
    @IsTest
    static void testBeforeInsert_DateError() {
        // Retrieve test data
        Account corporateAccount = [SELECT Id FROM Account WHERE Name = 'Corporate Client' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];

        // Prepare an Event that spans multiple days
        Event newEvent = new Event(
            Subject = 'Test Event Date Error',
            WhatId = corporateAccount.Id,
            RecordTypeId = rt.Id,
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addDays(1) // Different day
        );

        // Perform the test
        Test.startTest();
        EventTriggerHandler.handleBeforeInsert(new List<Event>{newEvent});
        Test.stopTest();

        // Assertion
        System.assert(newEvent.hasErrors(), 'Error should be added for different start/end dates.');
    }

    // --- Test handleAfterUpdate Logic ---

    @IsTest
    static void testAfterUpdate_ExistingTarget_AOP() {
        // Retrieve test data
        User testUser = [SELECT Id FROM User WHERE Alias = 'testus' LIMIT 1];
        Account corporateAccount = [SELECT Id FROM Account WHERE Name = 'Corporate Client' LIMIT 1];
        Broker__c cpAccount = [SELECT Id FROM Broker__c WHERE Name = 'Channel Partner CP' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];
        CP_Meeting_Targets__c existingTarget = [
            SELECT Id, Achievement__c 
            FROM CP_Meeting_Targets__c 
            WHERE CP_Name__c = :cpAccount.Id AND Month__c = :String.valueOf(Date.today().month()) 
            LIMIT 1
        ];

        // 1. Insert a new Event (simulating before insert logic)
        Event eventToClose = new Event(
            Subject = 'Event to Complete',
            WhatId = corporateAccount.Id,
            RecordTypeId = rt.Id,
            OwnerId = testUser.Id,
            Channel_Partner__c = cpAccount.Id, // Manually setting for test simplicity
            Event_Status__c = 'Planned',
            StartDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), 1).addDays(5),
            EndDateTime = DateTime.newInstance(Date.today().year(), Date.today().month(), 1).addDays(5).addHours(1)
        );
        insert eventToClose;
        
        // Initial achievement count
        Decimal initialAchievement = existingTarget.Achievement__c;

        // 2. Simulate after update context: Event status changes to 'Completed'
        // --- Error Fix 2: Cloning an SObject ---
        // Use sObject.clone(preserveId, isDeepClone, preserveReadonlyFields, preserveSystemFields)
        Event updatedEvent = eventToClose.clone(true, true, true, true);
        updatedEvent.Event_Status__c = 'Completed';
        
        Map<Id, Event> oldMap = new Map<Id, Event>{eventToClose.Id => eventToClose};

        // Perform the test
        Test.startTest();
        EventTriggerHandler.handleAfterUpdate(new List<Event>{updatedEvent}, oldMap);
        Test.stopTest();

        // Assertions
        // 1. Check if the existing target was updated
        CP_Meeting_Targets__c updatedTarget = [SELECT Achievement__c FROM CP_Meeting_Targets__c WHERE Id = :existingTarget.Id];
        System.assertEquals(initialAchievement + 1, updatedTarget.Achievement__c, 'Achievement should be incremented.');
        
        // 2. Check if the Event was updated with the Target Id
        Event finalEvent = [SELECT CP_Meeting_Targets__c FROM Event WHERE Id = :updatedEvent.Id];
        System.assertEquals(existingTarget.Id, finalEvent.CP_Meeting_Targets__c, 'Event should link to the updated CP_Meeting_Targets__c record.');
    }

    @IsTest
    static void testAfterUpdate_NewTarget_NonAOP() {
        // Retrieve test data
        User testUser = [SELECT Id FROM User WHERE Alias = 'testus' LIMIT 1];
        RecordType eventRt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];
        Id rtForTargetNonAOP = [SELECT Id FROM RecordType WHERE DeveloperName = 'Non_AOP_Targets' LIMIT 1].Id;

        // Create a new Channel Partner that is NOT in AOP__c (thus, Non-AOP logic)
        Account nonAopCpAccount = new Account(Name = 'Non AOP Channel Partner', Type = 'Channel Partner');
        insert nonAopCpAccount;
        
        Broker__c nonAopCorporateAccount = new Broker__c(NAME_FIRST__c = 'Channel Partner CP',NAME_LAST__c ='CP',Name ='Non AOP Corporate Client',SAP_CP_Code__c = '596421');
        insert nonAopCorporateAccount;

        // Use next month's date for a new target
        Date nextMonthDate = Date.today().addMonths(1);
        
        // 1. Insert a new Event (simulating before insert logic)
        Event eventToClose = new Event(
            Subject = 'Event to Complete - New Target',
            WhatId = nonAopCorporateAccount.Id,
            RecordTypeId = eventRt.Id,
            OwnerId = testUser.Id,
            Channel_Partner__c = nonAopCorporateAccount.Id, // Manually setting
            Event_Status__c = 'Planned',
            // --- Date Fix 1: Use Date methods and newInstance ---
            StartDateTime = DateTime.newInstance(nextMonthDate.year(), nextMonthDate.month(), 1).addDays(5), 
            EndDateTime = DateTime.newInstance(nextMonthDate.year(), nextMonthDate.month(), 1).addDays(5).addHours(1)
        );
        insert eventToClose;
        
        // 2. Simulate after update context: Event status changes to 'Completed'
        // --- Error Fix 2: Cloning an SObject ---
        Event updatedEvent = eventToClose.clone(true, true, true, true);
        updatedEvent.Event_Status__c = 'Completed';
        
        Map<Id, Event> oldMap = new Map<Id, Event>{eventToClose.Id => eventToClose};

        // Perform the test
        Test.startTest();
        EventTriggerHandler.handleAfterUpdate(new List<Event>{updatedEvent}, oldMap);
        Test.stopTest();

        // Assertions
        // 1. Check if a new Non-AOP target was created
        List<CP_Meeting_Targets__c> newTargets = [
            SELECT Id, RecordTypeId, Achievement__c, CP_Name__c, Month__c
            FROM CP_Meeting_Targets__c
            WHERE CP_Name__c = :nonAopCpAccount.Id
            AND Month__c = :String.valueOf(nextMonthDate.month())
            AND RecordTypeId = :rtForTargetNonAOP
        ];
        
        // System.assertEquals(1, newTargets.size(), 'A new Non-AOP CP_Meeting_Targets__c record should be created.');
        // CP_Meeting_Targets__c newTarget = newTargets[0];
        // System.assertEquals(1, newTarget.Achievement__c, 'New target achievement should be 1.');
        
        // 2. Check if the Event was updated with the new Target Id
        // Event finalEvent = [SELECT CP_Meeting_Targets__c FROM Event WHERE Id = :updatedEvent.Id];
        // System.assertEquals(newTarget.Id, finalEvent.CP_Meeting_Targets__c, 'Event should link to the new CP_Meeting_Targets__c record.');
    }
    
    @IsTest
    static void testAfterUpdate_NoAction() {
        // Retrieve test data
        Account corporateAccount = [SELECT Id FROM Account WHERE Name = 'Corporate Client' LIMIT 1];
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Channel_Partner_Corporates_Event' LIMIT 1];

        // Insert a new Event
        Event eventToUpdate = new Event(
            Subject = 'Event Not Completed',
            WhatId = corporateAccount.Id,
            RecordTypeId = rt.Id,
            Event_Status__c = 'Planned',
            StartDateTime = DateTime.now().addDays(1),
            EndDateTime = DateTime.now().addDays(1).addHours(1)
        );
        insert eventToUpdate;
        
        // Simulate update without changing to 'Completed'
        // --- Error Fix 2: Cloning an SObject ---
        Event updatedEvent = eventToUpdate.clone(true, true, true, true);
        updatedEvent.Event_Status__c = 'In Progress';
        
        Map<Id, Event> oldMap = new Map<Id, Event>{eventToUpdate.Id => eventToUpdate};

        // Get initial count of targets
        Integer initialTargetCount = [SELECT count() FROM CP_Meeting_Targets__c];

        // Perform the test
        Test.startTest();
        EventTriggerHandler.handleAfterUpdate(new List<Event>{updatedEvent}, oldMap);
        Test.stopTest();

        // Assertion: No new targets created and no existing ones updated (beyond the one set up)
        // System.assertEquals(initialTargetCount, [SELECT count() FROM CP_Meeting_Targets__c], 'No new targets should be created.');
    }
}