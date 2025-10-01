@isTest
public class TestChannelPartnerSearchPageController {
@isTest
         private static void  ChannelPartnerSearchPage () {            
             test.startTest();
                 pageReference pageRef = page.ChannelPartnerSearchPage;
                 Test.setCurrentPage(pageRef);
                 ChannelPartnerSearchPageController ChannelPartnerSearchPage = new ChannelPartnerSearchPageController();
                 ChannelPartnerSearchPage.NewCP.Broker_Pan_No__c = 'ABCDF34567';
                 ChannelPartnerSearchPage.NewCP.Name = 'Testcp';
                 ChannelPartnerSearchPage.NewCP.RW_Email__c = 'testcp@stetig.in';
                 
                 ChannelPartnerSearchPage.searchAllChannelPartner();
             	 ChannelPartnerSearchPage.goBack();
				 ChannelPartnerSearchPage.createNew();  
             
             
             	 ChannelPartnerSearchPageController ChannelPartnerSearchPage1 = new ChannelPartnerSearchPageController();
                 ChannelPartnerSearchPage1.NewCP.Broker_Pan_No__c = '';
                 ChannelPartnerSearchPage1.NewCP.Name = 'Testcp';
                 ChannelPartnerSearchPage1.NewCP.RW_Email__c = 'testcp@stetig.in';
                 
                 ChannelPartnerSearchPage1.searchAllChannelPartner();
             	 ChannelPartnerSearchPage1.goBack();
				 ChannelPartnerSearchPage1.createNew(); 
             
                 ChannelPartnerSearchPageController ChannelPartnerSearchPage2 = new ChannelPartnerSearchPageController();
                 ChannelPartnerSearchPage2.NewCP.Broker_Pan_No__c = 'ABCDF34567';
                 ChannelPartnerSearchPage2.NewCP.Name = '';
                 ChannelPartnerSearchPage2.NewCP.RW_Email__c = 'testcp@stetig.in';
                 
                 ChannelPartnerSearchPage2.searchAllChannelPartner();
             	 ChannelPartnerSearchPage2.goBack();
				 ChannelPartnerSearchPage2.createNew();  
             
                 ChannelPartnerSearchPageController ChannelPartnerSearchPage3 = new ChannelPartnerSearchPageController();
                 ChannelPartnerSearchPage3.NewCP.Broker_Pan_No__c = 'ABCDF34567';
                 ChannelPartnerSearchPage3.NewCP.Name = '';
                 ChannelPartnerSearchPage3.NewCP.RW_Email__c = 'testcp@stetig.in';
                 
                 ChannelPartnerSearchPage3.searchAllChannelPartner();
             	 ChannelPartnerSearchPage3.goBack();
                 ChannelPartnerSearchPage3.Save();
				 ChannelPartnerSearchPage3.createNew(); 
             
             	
                 test.stopTest();
         }
    @isTest
         private static void  ChannelPartnerCreatePage () {            
             test.startTest();
                 pageReference pageRef = page.CreateNewChannelPartner;
                 Test.setCurrentPage(pageRef);
                 CreateNewChannelPartnerController CreateNewChannelPartner = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner.NewCP.Broker_Pan_No__c = 'ABCDF34523';
                 CreateNewChannelPartner.NewCP.Name = 'Testcp1';
                 CreateNewChannelPartner.NewCP.RW_Email__c = 'testcp1@stetig.in';
                 CreateNewChannelPartner.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner.NewCP.RW_Mobile_No__c = '1245555555';
                 CreateNewChannelPartner.saveMethod();                
             	 CreateNewChannelPartner.goBack();
             
             	 CreateNewChannelPartnerController CreateNewChannelPartner11 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner11.NewCP.Broker_Pan_No__c = 'ABCDF34523';
                 CreateNewChannelPartner11.NewCP.Name = 'Testcp1';
                 CreateNewChannelPartner11.NewCP.RW_Email__c = 'testcp1@stetig.in';
                 CreateNewChannelPartner11.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner11.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner11.NewCP.RW_Mobile_No__c = '1245555555';
                 CreateNewChannelPartner11.saveMethod();                
             	 CreateNewChannelPartner11.goBack();
             
                 CreateNewChannelPartnerController CreateNewChannelPartner1 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner1.NewCP.Broker_Pan_No__c = 'ABCSS34523';
                 CreateNewChannelPartner1.NewCP.Name = '';
                 CreateNewChannelPartner1.NewCP.RW_Email__c = 'testcphh@stetig.in';
                 CreateNewChannelPartner1.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner1.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner1.NewCP.RW_Mobile_No__c = '1245555887';
                 CreateNewChannelPartner1.saveMethod();                
             	 CreateNewChannelPartner1.goBack();  
                  
                 CreateNewChannelPartnerController CreateNewChannelPartner2 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner2.NewCP.Broker_Pan_No__c = 'ABCSS34528';
                 CreateNewChannelPartner2.NewCP.Name = '';
                 CreateNewChannelPartner2.NewCP.RW_Email__c = '';
                 CreateNewChannelPartner2.NewCP.Dialing_Country1__c = '';
                 CreateNewChannelPartner2.NewCP.Dialing_Country_Code1__c = '';
                 CreateNewChannelPartner2.NewCP.RW_Mobile_No__c = '';
                 CreateNewChannelPartner2.saveMethod();                
             	 CreateNewChannelPartner2.goBack();
             
             
             	 CreateNewChannelPartnerController CreateNewChannelPartner3 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner3.NewCP.Broker_Pan_No__c = '';
                 CreateNewChannelPartner3.NewCP.Name = 'testcp';
                 CreateNewChannelPartner3.NewCP.RW_Email__c = 'testcphh@stetig.in';
                 CreateNewChannelPartner3.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner3.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner3.NewCP.RW_Mobile_No__c = '1245555887';
                 CreateNewChannelPartner3.saveMethod();                
             	 CreateNewChannelPartner3.goBack();
             
				 CreateNewChannelPartnerController CreateNewChannelPartner4 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner4.NewCP.Broker_Pan_No__c = 'test';
                 CreateNewChannelPartner4.NewCP.Name = 'Testcp1';
                 CreateNewChannelPartner4.NewCP.RW_Email__c = 'testcp1@stetig.in';
                 CreateNewChannelPartner4.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner4.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner4.NewCP.RW_Mobile_No__c = '1245555555';
                 CreateNewChannelPartner4.saveMethod();                
             	 CreateNewChannelPartner4.goBack();      
             
                 CreateNewChannelPartnerController CreateNewChannelPartner5 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner5.NewCP.Broker_Pan_No__c = 'ABCDF34526';
                 CreateNewChannelPartner5.NewCP.Name = 'Testcp1';
                 CreateNewChannelPartner5.NewCP.Dialing_Country1__c = '';
                 CreateNewChannelPartner5.NewCP.Dialing_Country_Code1__c = '+91';
                 CreateNewChannelPartner5.NewCP.RW_Email__c = 'testcp1@stetig.in';
                 CreateNewChannelPartner5.NewCP.RW_Mobile_No__c = '1245555555';
                 CreateNewChannelPartner5.saveMethod();                
             	 CreateNewChannelPartner5.goBack();
             
                 CreateNewChannelPartnerController CreateNewChannelPartner6 = new CreateNewChannelPartnerController();
                 CreateNewChannelPartner6.NewCP.Broker_Pan_No__c = 'ABCDF34526';
                 CreateNewChannelPartner6.NewCP.Name = 'Testcp1';
                 CreateNewChannelPartner6.NewCP.Dialing_Country1__c = 'India';
                 CreateNewChannelPartner6.NewCP.Dialing_Country_Code1__c = '';
                 CreateNewChannelPartner6.NewCP.RW_Email__c = 'testcp1@stetig.in';
                 CreateNewChannelPartner6.NewCP.RW_Mobile_No__c = '1245555555';
                 CreateNewChannelPartner6.saveMethod();                
             	 CreateNewChannelPartner6.goBack();
             
             
                test.stopTest();
         }
    
                   private static Broker__c createBroker() {
                      Broker__c objBroker = new Broker__c();
                      objBroker.Broker_Pan_No__c = 'ABCDF34526';
                      objBroker.Name = 'Testcp2';
                      objBroker.RW_Email__c = 'testcp4@stetig.in';
                      objBroker.Dialing_Country1__c = 'India';
                      objBroker.Dialing_Country_Code1__c = '+91';
                      objBroker.RW_Mobile_No__c = '1112288888';
                      objBroker.Unregistered_Channel_Partner__c = true;
                      insert objBroker;
                       return objBroker;
                      }
                private static Project__c createProject() {
                Project__c objProject = new Project__c();
                objProject.name = 'test';
                objProject.RW_Status__c = 'Active';
                objProject.RW_Address__c = 'star garden';
                objProject.Site_Address_Map_Link__c = 'www.google.com';
                
                insert objProject ;
            return objProject;
         } 
         
         private static Account createPAAccount () {
                List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                Account objAcc = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                    RecordType = personAccountRecordType[0],Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                    RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                             Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
                insert objAcc;
             return objAcc;
         }
         private static Opportunity createOpp (Id accId, Id projId) {
             //Account a = createPAAccount();
             //project__c p = createProject();
                      Broker__c objBroker = new Broker__c();
                      objBroker.Broker_Pan_No__c = 'ABCDF34527';
                      objBroker.Name = 'Testcp21';
                      objBroker.RW_Email__c = 'testcph4@stetig.in';
                      objBroker.Dialing_Country1__c = 'India';
                      objBroker.Dialing_Country_Code1__c = '+91';
                      objBroker.RW_Mobile_No__c = '1112288898';
                      objBroker.Unregistered_Channel_Partner__c = true;
                      insert objBroker;
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Qualification';//'Unit Booked';
                objopp.RW_Project__c = projId;
                objopp.Budget_In_Cr__C = 100;
                objopp.RW_Ethnicity__c = 'test';
                objopp.RW_Location__c = 'MANGLAUR';
                objopp.RW_Configuration__c = '1.5 BHK';
                objopp.RW_Time_line__c = 'Ready Possession';
                objopp.Walkin_Source__c = 'Channel Partner';
                objopp.RW_Broker__c = objBroker.id;
                //objopp.RW_Project_Unit__c = u.Id;
                insert objOpp;
                Opportunity objOppToreturn = [Select id,RW_Project__c,AccountId ,StageName ,RW_Opportunity_Status__c 
                                                      from Opportunity where id =:objOpp.id];
             return objOppToreturn ;
         }       
    
    
    
}