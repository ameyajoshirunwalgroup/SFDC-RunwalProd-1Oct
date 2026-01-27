@IsTest
private class Lockated_CPEvents_Test {
    
    /**
     * @Method: setupTestData
     * @Description: Creates Channel Partner, Account, Contact, Campaign, and CampaignMember records for testing.
     */
    private static Id setupTestData(Boolean withCampaigns) {
        // Create Record Type for Campaign (mock if not present)
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Campaign' AND DeveloperName = 'CP_Meets' LIMIT 1];

        // Create a Channel Partner Account
        Broker__c channelPartner = new Broker__c(Name = 'Channel Partner A');
        insert channelPartner;


        // Create Broker Account linked to Channel Partner
        Account brokerAccount = new Account(
            Name = 'Broker Account',
            Channel_Partner__c = channelPartner.Id
        );
        insert brokerAccount;

        // Create Contact linked to Broker Account
        Contact brokerContact = new Contact(
            FirstName = 'Test',
            LastName = 'Broker',
            AccountId = brokerAccount.Id
        );
        insert brokerContact;

        if (withCampaigns) {
            // Create CP_Meets Record Type ID dynamically
            Id cpMeetRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName()
                .get('CP_Meets').getRecordTypeId();

            // Create a Campaign
            Campaign campaignUpcoming = new Campaign(
                Name = 'CP Meet - Upcoming',
                RecordTypeId = cpMeetRecordTypeId,
                Type__c = 'CP Meets',
                Event_Date_Time__c = System.now().addDays(2),
                Event_Location__c = 'Mumbai',
                Description = 'Upcoming event',
                Status = 'Planned'
            );

            Campaign campaignPast = new Campaign(
                Name = 'CP Meet - Past',
                RecordTypeId = cpMeetRecordTypeId,
                Type__c = 'CP Meets',
                Event_Date_Time__c = System.now().addDays(-5),
                Event_Location__c = 'Pune',
                Description = 'Past event',
                Status = 'Completed'
            );

            insert new List<Campaign>{ campaignUpcoming, campaignPast };

            // Create Campaign Members (RSVP true for one, false for another)
            CampaignMember cmUpcoming = new CampaignMember(
                CampaignId = campaignUpcoming.Id,
                ContactId = brokerContact.Id,
                RSVP__c = true
            );
            CampaignMember cmPast = new CampaignMember(
                CampaignId = campaignPast.Id,
                ContactId = brokerContact.Id,
                RSVP__c = false
            );
            insert new List<CampaignMember>{ cmUpcoming, cmPast };
        }

        return channelPartner.Id;
    }

    /**
     * @Test: Missing brokerId parameter
     */
    @IsTest
    static void testMissingBrokerId() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpEvents/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Lockated_CPEvents.doGet();

    }

    /**
     * @Test: No Campaigns found for broker
     */
    @IsTest
    static void testNoCampaignsFound() {
        Id brokerId = setupTestData(false);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpEvents/';
        req.httpMethod = 'GET';
        req.addParameter('brokerId', brokerId);
        RestContext.request = req;
        RestContext.response = res;

        Lockated_CPEvents.doGet();

    }

    /**
     * @Test: Successful API call with upcoming and past events
     */
    @IsTest
    static void testSuccessfulBrokerEvents() {
        Id brokerId = setupTestData(true);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpEvents/';
        req.httpMethod = 'GET';
        req.addParameter('brokerId', brokerId);
        RestContext.request = req;
        RestContext.response = res;

        Lockated_CPEvents.doGet();


    }

    /**
     * @Test: Exception handling scenario (simulate error)
     */
    @IsTest
    static void testExceptionHandling() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpEvents/';
        req.httpMethod = 'GET';
        req.addParameter('brokerId', 'InvalidId'); // Invalid Id format
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPEvents.doGet();
        Test.stopTest();

    }
    


    @IsTest
    static void testDoPost_Going() {

        // ---------- Test Data ----------
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Broker__c broker = new Broker__c(
            Name = 'Test Broker',
            Account__c = acc.Id,
            Registration_Complete__c = true,
            RW_Mobile_No__c = '9999999999'
        );
        insert broker;

        Campaign camp = new Campaign(
            Name = 'Test Event',
            IsActive = true
        );
        insert camp;

        Lead l = new Lead(
            LastName = 'Test Lead',
            Company = 'Test',
            Status = 'Open',
            RW_Mobile_No__c = '1221232333'
        );
        insert l;

        CampaignMember cm = new CampaignMember(
            CampaignId = camp.Id,
            LeadId = l.Id
        );
        insert cm;

        // ---------- REST REQUEST ----------
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpEvent/rsvp';
        req.addParameter('cpId', broker.Id);
        req.addParameter('eventId', cm.Id);
        req.addParameter('status', 'Going');
        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = res;

        // ---------- Execute ----------
        Test.startTest();
        Lockated_CPEvents.doPost(); // 🔁 replace with actual class name
        Test.stopTest();

        // ---------- Assertions ----------
        System.assertEquals(200, res.statusCode);

        CampaignMember updatedCM = [
            SELECT RSVP__c, Additional_Attendees__c
            FROM CampaignMember
            WHERE Id = :cm.Id
        ];

        System.assertEquals(true, updatedCM.RSVP__c);
        System.assertEquals(1, updatedCM.Additional_Attendees__c);
    }

    @IsTest
    static void testDoPost_NotGoing() {

        // ---------- Test Data ----------
        Account acc = new Account(Name = 'Test Account 2');
        insert acc;

        Broker__c broker = new Broker__c(
            Name = 'Test Broker 2',
            Account__c = acc.Id,
            Registration_Complete__c = true,
            RW_Mobile_No__c = '8888888888'
        );
        insert broker;

        Campaign camp = new Campaign(
            Name = 'Test Event 2',
            IsActive = true
        );
        insert camp;

        Contact c = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id
        );
        insert c;

        CampaignMember cm = new CampaignMember(
            CampaignId = camp.Id,
            ContactId = c.Id
        );
        insert cm;

        // ---------- REST REQUEST ----------
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpEvent/rsvp';
        req.addParameter('cpId', broker.Id);
        req.addParameter('eventId', cm.Id);
        req.addParameter('status', 'Not Going');
        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = res;

        // ---------- Execute ----------
        Test.startTest();
        Lockated_CPEvents.doPost(); // 🔁 replace with actual class name
        Test.stopTest();

        // ---------- Assertions ----------
        System.assertEquals(200, res.statusCode);

        CampaignMember updatedCM = [
            SELECT Declined__c, Additional_Attendees__c
            FROM CampaignMember
            WHERE Id = :cm.Id
        ];

        System.assertEquals(true, updatedCM.Declined__c);
        System.assertEquals(1, updatedCM.Additional_Attendees__c);
    }

    @IsTest
    static void testMissingParams() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/cpEvent/rsvp';
        req.requestBody = Blob.valueOf('{}');

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPEvents.doPost(); // 🔁 replace with actual class name
        Test.stopTest();

        System.assertEquals(400, res.statusCode);
    }
    
    
}