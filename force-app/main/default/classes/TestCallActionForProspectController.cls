@isTest

public class TestCallActionForProspectController {
   
        @istest
            public static void test() {
               Prospect__c pros = new Prospect__c();
                pros.Name = 'test prajakta';
                insert pros;
               Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
               User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                                    );
                insert objUser;
                test.starttest();
                    ApexPages.StandardController sc = new ApexPages.StandardController(pros);
                    CallActionForProspectController pc = new CallActionForProspectController(sc);
                    CallActionForProspectController.getPhoneFields(pros.Id);
                    CallActionForProspectController.click2Call(pros.Id,'9876544442');
                    CallActionForProspectController.click2CallKnowlarity(pros.Id,'9876544442');
                test.stoptest();
            }
}