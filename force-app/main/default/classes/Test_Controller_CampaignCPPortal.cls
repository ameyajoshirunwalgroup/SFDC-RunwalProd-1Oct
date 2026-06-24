@IsTest
private class Test_Controller_CampaignCPPortal {

    // Helper to create a user with a contact
    private static User createUserWithContact() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        
        Account objAcc = new Account();
        objAcc.Name = 'Test';
        insert objAcc;
        
        Contact c = new Contact(
            AccountId = objAcc.Id,
            LastName = 'Test Contact'
        );
        insert c;
        User u = new User(
            FirstName = 'Test',
            LastName  = 'User',
            Alias     = 'tuser',
            Email     = 'testuser@example.com',
            Username  = 'testuser' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US' ,
            ContactId = c.Id
        );
        insert u;
        return u;
    }

    @IsTest
    static void testControllerCampaignCPPortal() {
        // Create test data
        User u = createUserWithContact();

        // Future-dated CP Meets campaign
        Campaign futureCampaign = new Campaign(
            Name = 'Future CP Meet',
            Type__c = System.Label.CPMeetsCampaign,
            StartDate = Date.today(),
            EndDate = Date.today().addDays(1),
            Tollfree_Number__c  = '9389289290',
            Event_Date_Time__c = DateTime.now().addDays(1)
        );
        insert futureCampaign;

        // Past-dated CP Meets campaign
        Campaign pastCampaign = new Campaign(
            Name = 'Past CP Meet',
            Type__c = System.Label.CPMeetsCampaign,
            StartDate = Date.today().addDays(-5),
            EndDate = Date.today().addDays(-4),
            Tollfree_Number__c  = '9389289290',
            Event_Date_Time__c = DateTime.now().addDays(-1)
        );
        insert pastCampaign;

        // Link user to future campaign
        CampaignMember cm = new CampaignMember(
            CampaignId = futureCampaign.Id,
            ContactId  = u.ContactId
        );
        insert cm;

        System.runAs(u) {
            Test.startTest();

            // ----------------- getCampaignsForCurrentUser -----------------
            List<Campaign> userCampaigns =
                Controller_CampaignCPPortal.getCampaignsForCurrentUser();
            System.assertEquals(1, userCampaigns.size(),
                'User should see one future CP Meet campaign');

            // ----------------- getAllCampaigns -----------------
            List<Campaign> allFuture =
                Controller_CampaignCPPortal.getAllCampaigns();
            System.assertEquals(1, allFuture.size(),
                'Should return future CP Meet campaigns');

            // ----------------- getAllPastCampaigns -----------------
            List<Campaign> allPast =
                Controller_CampaignCPPortal.getAllPastCampaigns();
            System.assertEquals(1, allPast.size(),
                'Should return past CP Meet campaigns');

            Test.stopTest();
        }

        // -------- Negative case: user without Contact -----------
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User userNoContact = new User(
            FirstName = 'NoContact',
            LastName  = 'User',
            Alias     = 'nocont',
            Email     = 'nocontact@example.com',
            Username  = 'nocontact' + System.currentTimeMillis() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert userNoContact;

        System.runAs(userNoContact) {
            List<Campaign> emptyList =
                Controller_CampaignCPPortal.getCampaignsForCurrentUser();
            System.assertEquals(0, emptyList.size(),
                'Should return empty list when user has no Contact');
        }
    }
}