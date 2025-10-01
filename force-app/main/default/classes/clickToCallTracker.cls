@isTest
    public class clickToCallTracker {
        @istest
            public static void test() {
               Account acc = createPATemplate('TestPA1' , 'testleada@radiustest.com', '9876544441', false);
               Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
               User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                                    );
                insert objUser;
                test.starttest();
                    ApexPages.StandardController sc = new ApexPages.StandardController(acc);
                    callActionController ue = new callActionController(sc);
                    callActionController.getPhoneFields(acc.id);
                    callActionController.getAllPhoneFields(acc.id);
                    callActionController.click2Call(acc.id,'9876544441');
                    callActionController.click2CallKnowlarity(acc.id,'9876544441');
                test.stoptest();
            }
            
            @istest
            public static void testLead() {
               Lead le = createLeadTemplate('TestLead1' , 'testleada@test.com', '9876544442', false);
               Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
               User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                                    );
                insert objUser;
                test.starttest();
                    ApexPages.StandardController sc = new ApexPages.StandardController(le);
                    CallActionControllerForLead ue = new CallActionControllerForLead(sc);
                    CallActionControllerForLead.getPhoneFields(le.id);
                    CallActionControllerForLead.getAllPhoneFields(le.id);
                    CallActionControllerForLead.click2Call(le.id,'9876544442');
                    CallActionControllerForLead.click2CallKnowlarity(le.id,'9876544442');
                test.stoptest();
            }
            
            @istest
            public static void testOpportunity() {
               Account acc = createPATemplate('TestPA1' , 'testleada@radiustest.com', '9876544442', false);
               Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
               User objUser = new User(Alias = 'standt', Email='standardTest@testing.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US',Ameyo_Agent_Id__c = 12364790, ProfileId = p.Id, 
                                    TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@t1estorg.com'
                                    );
                insert objUser;
                Project__c pr = createProject('ONE BKC','111');
                List<Opportunity>  oList = createOpptyForAccount(acc.Id, pr.Id, 1);
                //oList[0].RW_Mobile_No__c = '9876544442';
                //update oList;
                test.starttest();
                    ApexPages.StandardController sc = new ApexPages.StandardController(oList[0]);
                    CallActionControllerForOpportunity ue = new CallActionControllerForOpportunity(sc);
                    CallActionControllerForOpportunity.getPhoneFields(oList[0].id);
                    CallActionControllerForOpportunity.getAllPhoneFields(oList[0].id);
                    CallActionControllerForOpportunity.click2Call(oList[0].id,'9876544442');
                    CallActionControllerForOpportunity.click2CallKnowlarity(oList[0].id,'9876544442');
                test.stoptest();
            }
            
            
             // creates  a person account with the basic parameters
          public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
            RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
            Account a = new Account(lastName=accName, personEmail = email, Mobile_No__c = Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster);
            insert a;
            return a;
          }  
          public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
            Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , RW_Mobile_No__c = mobile, MasterRecord__c = isMaster);
            insert l;
            return l;  
          }   
          public static Project__c createProject(String ProjName, String ProjectCode)
          {
                Project__c objProject = new Project__c(Name = ProjName);
                insert objProject;
                return objProject;
          }
           public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
            List<Opportunity> oList = new List<Opportunity>();
            Date closeDate; 
            for(Integer i =0;i<numOfOpp; i++){
              closeDate = Date.newInstance(2015, 8,29);
              Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', RW_Project__c = ProjId,closeDate=System.today(),RW_Mobile_No__c = '9876544442'); //S_Budget_In_lacs__c = 5000000,
              oList.add(o);            
            }
            insert oList;
            return oList;
          }
  
}