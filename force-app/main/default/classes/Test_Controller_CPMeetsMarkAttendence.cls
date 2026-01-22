@IsTest
private class Test_Controller_CPMeetsMarkAttendence {

    /** Utility: create a User with a Contact so that
     *  CampaignMember.Contact fields can be populated */
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
            Username  = 'testuser' + System.currentTimeMillis() + '@example.com',
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
    static void testController_CPMeetsMarkAttendence_AllMethods() {
        User u = createUserWithContact();

        // Create a future CP Meets Campaign (for positive scenarios)
        Campaign futureCampaign = new Campaign(
            Name = 'Future CP Meet',
            Type__c = System.Label.CPMeetsCampaign,
            StartDate = Date.today(),
            EndDate   = Date.today().addDays(1),
            Tollfree_Number__c  = '9389289290',
            Event_Date_Time__c = DateTime.now().addDays(1)
        );
        insert futureCampaign;

        // Create a CampaignMember with RSVP = true
        CampaignMember cm = new CampaignMember(
            CampaignId = futureCampaign.Id,
            ContactId  = u.ContactId,
            RSVP__c    = true,
            Status     = 'Sent',
            Additional_Attendees__c = 2,
            Total_Attendees__c = 3,
            Is_Attended__c = false
        );
        insert cm;

        System.runAs(u) {
            Test.startTest();

            // ---------- getCampaignNameSuggestions ----------
            List<Campaign> nameSuggestions =
                Controller_CPMeetsMarkAttendence.getCampaignNameSuggestions('Future');
            System.assertEquals(1, nameSuggestions.size(), 'Should find campaign by name');

            List<Campaign> emptyNameSuggestions =
                Controller_CPMeetsMarkAttendence.getCampaignNameSuggestions('');
            System.assertEquals(0, emptyNameSuggestions.size(),
                'Blank searchKey should return empty list');

            // ---------- getMembersByCampaignName ----------
            List<CampaignMember> membersByName =
                Controller_CPMeetsMarkAttendence.getMembersByCampaignName('Future');
            System.assertEquals(1, membersByName.size(), 'Should return one member');

            List<CampaignMember> membersByNameEmpty =
                Controller_CPMeetsMarkAttendence.getMembersByCampaignName('');
            System.assertEquals(0, membersByNameEmpty.size(),
                'Blank searchKey should return empty list');

            // ---------- getMembersByCampaignIdAndName ----------
            List<CampaignMember> membersByIdAndName =
                Controller_CPMeetsMarkAttendence.getMembersByCampaignIdAndName(
                    futureCampaign.Id, 'Test');
            System.assertEquals(1, membersByIdAndName.size(), 'Should return one member');

            List<CampaignMember> membersByIdAndNameEmpty =
                Controller_CPMeetsMarkAttendence.getMembersByCampaignIdAndName(null, 'Test');
            System.assertEquals(0, membersByIdAndNameEmpty.size(),
                'Blank campaignId should return empty list');

            // ---------- getMemberNameSuggestions ----------
            List<CampaignMember> memberNameSuggestions =
                Controller_CPMeetsMarkAttendence.getMemberNameSuggestions(
                    futureCampaign.Id, 'Test');
            System.assertEquals(1, memberNameSuggestions.size(), 'Should suggest member name');

            List<CampaignMember> memberNameSuggestionsEmpty =
                Controller_CPMeetsMarkAttendence.getMemberNameSuggestions(
                    futureCampaign.Id, '');
            System.assertEquals(0, memberNameSuggestionsEmpty.size(),
                'Blank searchKey should return empty list');

            // ---------- getMembersByMemberName ----------
            List<CampaignMember> membersByMemberName =
                Controller_CPMeetsMarkAttendence.getMembersByMemberName('Test');
            System.assertEquals(1, membersByMemberName.size(), 'Should return member by name');

            List<CampaignMember> membersByMemberNameEmpty =
                Controller_CPMeetsMarkAttendence.getMembersByMemberName('');
            System.assertEquals(0, membersByMemberNameEmpty.size(),
                'Blank searchKey should return empty list');

            // ---------- updateCampaignMemberStatus ----------
            // Flip attendance and total attendees to test update
            CampaignMember cmToUpdate = new CampaignMember(
                Id = cm.Id,
                Is_Attended__c = true,
                Total_Attendees__c = 4
            );
            Controller_CPMeetsMarkAttendence.updateCampaignMemberStatus(
                new List<CampaignMember>{cmToUpdate});

            // Verify update
            CampaignMember updated =
                [SELECT Is_Attended__c, Total_Attendees__c
                 FROM CampaignMember WHERE Id = :cm.Id];
            System.assertEquals(true, updated.Is_Attended__c,
                'Attendance should be updated to true');
            System.assertEquals(4, updated.Total_Attendees__c,
                'Total attendees should be updated');

            // Call updateCampaignMemberStatus with empty list for negative path
            Controller_CPMeetsMarkAttendence.updateCampaignMemberStatus(new List<CampaignMember>());

            Test.stopTest();
        }
    }
}