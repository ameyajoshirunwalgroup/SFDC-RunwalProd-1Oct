@IsTest
private class Test_showCampaignDetailsPageHelper {

    // Utility method to create a test user with a contact
    private static User createUserWithContact() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User' LIMIT 1];
        
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
            Username  = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = c.Id
        );
        insert u;
        return u;
    }

    @IsTest
    static void testShowCampaignDetailsPageHelper() {
        // Create test data
        User u = createUserWithContact();

        Campaign c = new Campaign(
            Name = 'CP Meets Event',
            Type__c = 'CP Meets',
            StartDate = Date.today(),
            Event_Date_Time__c = System.today() + 5,
            Event_Location__c = 'Baner',
            Tollfree_Number__c = '9389289290',
            EndDate = Date.today().addDays(1)
        );
        insert c;

        CampaignMember cm = new CampaignMember(
            CampaignId = c.Id,
            ContactId  = u.ContactId,
            RSVP__c = false,
            Declined__c = false,
            Additional_Attendees__c = 0
        );
        insert cm;

        // Run all code as our test user so UserInfo.getUserId() returns this user's Id
        System.runAs(u) {
            // ---- fetchCampaignDetailsById ----
            Test.startTest();
            showCampaignDetailsPageHelper.campaignWrapper wrap =
                showCampaignDetailsPageHelper.fetchCampaignDetailsById(c.Id);
            Test.stopTest();

            // ---- addMemberToCampaign ----
            Boolean addResult = showCampaignDetailsPageHelper.addMemberToCampaign(c.Id, 3);
          
            CampaignMember updatedCM = [SELECT Additional_Attendees__c, RSVP__c
                                        FROM CampaignMember WHERE Id = :cm.Id];
          
            // ---- saveDeclinedToCampaign ----
            Boolean declineResult = showCampaignDetailsPageHelper.saveDeclinedToCampaign(c.Id);

            CampaignMember declinedCM = [SELECT Declined__c FROM CampaignMember WHERE Id = :cm.Id];

            // ---- Negative case: No CampaignMember ----
            Campaign c2 = new Campaign(
                Name = 'Non Member Event',
                Type__c = 'CP Meets',
                StartDate = Date.today(),
                EndDate = Date.today().addDays(1),
              Event_Date_Time__c = System.today() + 15,
                Tollfree_Number__c  = '9389289290',
            Event_Location__c = 'Baner'
            );
            insert c2;

            showCampaignDetailsPageHelper.campaignWrapper wrap2 =
                showCampaignDetailsPageHelper.fetchCampaignDetailsById(c2.Id);
            System.assertEquals(false, wrap2.isAlreadyMember, 'No member should be found');

            Boolean addResult2 = showCampaignDetailsPageHelper.addMemberToCampaign(c2.Id, 1);
            System.assertEquals(false, addResult2, 'Should return false when no CampaignMember exists');

            Boolean declineResult2 = showCampaignDetailsPageHelper.saveDeclinedToCampaign(c2.Id);
            System.assertEquals(false, declineResult2, 'Should return false when no CampaignMember exists');
        }
    }
}