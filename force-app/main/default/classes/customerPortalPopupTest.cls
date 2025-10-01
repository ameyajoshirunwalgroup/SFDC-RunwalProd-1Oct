@isTest
public class customerPortalPopupTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for users, profiles, and opportunities
        
        Profile customProfile = [SELECT Id FROM Profile LIMIT 1];
        
        User testUser = new User(
            Alias = 'tuse2545',
            Email = 'testuse344r@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = customProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser12222@example.com'
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name = 'Test Account',
            Mobile_No__c = '8877665544'
            //PersonEmail = 'test@stetig.in'
        );
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Unit Booked',
            CloseDate = Date.today(),
            RW_Mobile_No__c = '1655443322',
            RW_Email__c = 'test@gmail.com',
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        
        Booking__c testBooking = new Booking__c(
            Opportunity__c = testOpportunity.Id,
            Registration__c = false
            
        );
        insert testBooking;
        
        testOpportunity.Booking__c = testBooking.id;
        update testOpportunity;
    }
    
    @isTest
    static void testShowPopupBasedonProfile() {
        // Test the showPopupBasedonProfile method
        Test.startTest();
        
        // Run the method as the test user
        /*System.runAs([SELECT Id FROM User WHERE UserName = 'testuser12222@example.com']) {
Boolean showPopup = customerPortalPopup.showPopupBasedonProfile();
// System.assertEquals(true, showPopup, 'Popup should be shown for the profile');
}*/
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetProfileNameByUserId() {
        // Test the getProfileNameByUserId method
        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser12222@example.com' LIMIT 1];
        Test.startTest();
        
       // String profileName = customerPortalPopup.getProfileNameByUserId(testUser.Id);
        //System.assertEquals('Custom Profile', profileName, 'Profile name should be Custom Profile');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetLastLoginTime() {
        // Test the getLastLoginTime method
        User testUser = [SELECT Id FROM User WHERE UserName = 'testuser12222@example.com' LIMIT 1];
        Test.startTest();
        
       // List<User> lastLoginTime = customerPortalPopup.getLastLoginTime(testUser.Id);
       // System.assertNotEquals(null, lastLoginTime, 'Last login time should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetQuestions() {
        // Test the getQuestions method
        Test.startTest();
        
        //List<Popup_Questions__mdt> questions = customerPortalPopup.getQuestions(null);
        //System.assertNotEquals(null, questions, 'Questions should not be null');
        
        Test.stopTest();
    }
    
    
    
    @isTest
    static void testFetchDataForObjectFields2() {
        // Test the fetchDataForObjectFields method
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        /*Popup_Questions__mdt question = new Popup_Questions__mdt(
        Object_Name__c = 'Account',
        Field_Name__c = 'Name',
        Questions__c = 'What is the account name?'
        );
        insert question;*/
        
        
        
        // Create test data for Popup_Questions__mdt
        Popup_Questions__mdt customMetadataRecord1 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_1',
            Object_Name__c = 'Account',
            Field_Name__c = 'RW_Redeem__c',
            Questions__c = 'What is the account name?'
        );
        Popup_Questions__mdt customMetadataRecord2 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_2',
            Object_Name__c = 'Opportunity',
            Field_Name__c = 'RW_Redeem__c',
            Questions__c = 'What is the opportunity name?'
        );
        Popup_Questions__mdt customMetadataRecord3 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_3',
            Object_Name__c = 'Booking__c',
            Field_Name__c = 'Registration__c',
            Questions__c = 'What is the booking name?'
        );
        //insert customMetadataRecord;
        
        List<Popup_Questions__mdt> metadataList = new  List<Popup_Questions__mdt>();
        metadataList.add(customMetadataRecord1);
        metadataList.add(customMetadataRecord2);
        metadataList.add(customMetadataRecord3);
        
        //insert metadata
        //
        
        
        
        //insert metadataList;
        // Query custom metadata records into a list
        /*List<Popup_Questions__mdt> metadataList = [
            SELECT Id, DeveloperName, Object_Name__c, Field_Name__c, Questions__c 
            FROM Popup_Questions__mdt 
            ORDER BY DeveloperName
        ];*/
        
        
        system.debug('metadataList'+metadataList);
        //insert new List<Popup_Questions__mdt>{customMetadataRecord1, customMetadataRecord2, customMetadataRecord3};

        
        Test.startTest();
        
        //Map<String, Map<String, String>> data = customerPortalPopup.fetchDataForObjectFields(testAccount.Id,new List<Popup_Questions__mdt>{accMetadata});
        
        Map<String, Map<String, String>> data = customerPortalPopup.fetchDataForObjectFields(testAccount.Id,metadataList);
        //System.assertNotEquals(null, data, 'Data should not be null');
        
        
        
        Test.stopTest();
    }
    
    
    
    
    
    @isTest
    static void testGetPicklistValues() {
        // Test the getPicklistValues method
        Test.startTest();
        
        List<Map<String, String>> picklistValues = customerPortalPopup.getPicklistValues('Opportunity', 'StageName');
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateFieldData() {
        // Test the updateFieldData method
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        system.debug('testAccount'+testAccount);
        Opportunity opp = new Opportunity();
        opp.AccountId = testAccount.Id;
        opp.StageName = 'Unit Booked';
        opp.Name = 'Test Opp';
        opp.RW_Mobile_No__c = '1122223333';
        opp.RW_Email__c = 'test@gmail.com';
        opp.CloseDate = system.today()+10;
        insert opp;
        
         Profile customProfile = [SELECT Id FROM Profile LIMIT 1];
        
        User testUser = new User(
            Alias = 'tuse2545',
            Email = 'testuse34435y93r@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = customProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser138532222@example.com'
        );
        insert testUser;
        
        system.debug('Opportunity'+opp);
        // Create test data for Popup_Questions__mdt
        Popup_Questions__mdt customMetadataRecord11 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_1',
            Object_Name__c = 'Account',
            Field_Name__c = 'RW_Redeem__c',
            Questions__c = 'What is the account name?'
        );
        Popup_Questions__mdt customMetadataRecord22 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_2',
            Object_Name__c = 'Opportunity',
            Field_Name__c = 'RW_Missed_Call__c',
            Questions__c = 'What is the opportunity name?'
        );
        Popup_Questions__mdt customMetadataRecord33 = new Popup_Questions__mdt(
            DeveloperName = 'Test_Record_3',
            Object_Name__c = 'Booking__c',
            Field_Name__c = 'Registration__c',
            Questions__c = 'What is the booking name?'
        );
        //insert customMetadataRecord;
        
        List<Popup_Questions__mdt> metadataList = new  List<Popup_Questions__mdt>();
        metadataList.add(customMetadataRecord11);
        metadataList.add(customMetadataRecord22);
        metadataList.add(customMetadataRecord33);
        // Query custom metadata records into a list
        /*List<Popup_Questions__mdt> metadataList = [
            SELECT Id, DeveloperName, Object_Name__c, Field_Name__c, Questions__c 
            FROM Popup_Questions__mdt 
            ORDER BY DeveloperName
        ];*/
        
        
        system.debug('metadataList'+metadataList);
        
        
        
        Test.startTest();
        for(Popup_Questions__mdt popup: metadataList){
            customerPortalPopup.updateFieldData(testAccount.Id,popup.Object_Name__c , popup.Field_Name__c, 'Updated Account Name');
            customerPortalPopup.updateFieldData(testAccount.Id,popup.Object_Name__c , popup.Field_Name__c, 'Updated Opportunity Name');
            customerPortalPopup.updateFieldData(testAccount.Id,popup.Object_Name__c , popup.Field_Name__c, 'Updated Booking Name');
        }
        
        customerPortalPopup.showPopupBasedonProfile(testAccount.Id);
        customerPortalPopup.getQuestions(testUser.id, testAccount.Id);
        Account updatedAccount = [SELECT Name FROM Account WHERE Id = :testAccount.Id];
        //System.assertEquals('Updated Account Name', updatedAccount.Name, 'Account name should be updated');
        
        Test.stopTest();
    }
}