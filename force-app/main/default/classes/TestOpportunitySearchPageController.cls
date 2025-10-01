@isTest
 public class TestOpportunitySearchPageController {
     @isTest
         private static void OpportunitysearchPagetest () {
             project__c p = createProject();
             Account a = createPAAccount();
             Opportunity o = createOpp(a.Id,p.Id);
             test.startTest();
                 pageReference pageRef = page.OpportunitySearchPage;
                 Test.setCurrentPage(pageRef);
                 OpportunitySearchPageController OpportunitySearch = new OpportunitySearchPageController();
                 OpportunitySearch.strProjectId = p.Id;
                 OpportunitySearch.NewOpportunity.RW_Mobile_No__c = '1212121213';
                 OpportunitySearch.searchAllOpportunity();
             	 OpportunitySearch.goBack();
                 OpportunitySearchPageController OpportunitySearch1 = new OpportunitySearchPageController();
                 
                 OpportunitySearch1.strProjectId = p.Id;
                 OpportunitySearch1.NewOpportunity.RW_Mobile_No__c = '1212121212';
                 OpportunitySearch1.searchAllOpportunity();
                 OpportunitySearch1.goBack();
                 OpportunitySearchPageController OpportunitySearch11 = new OpportunitySearchPageController();
                 OpportunitySearch11.strProjectId = p.Id;
             test.stopTest();
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
                objopp.Walkin_Source__c = 'Digital';
                objopp.Walkin_SubSource__c = 'Facebook';
                //objopp.RW_Project_Unit__c = u.Id;
                insert objOpp;
                Opportunity objOppToreturn = [Select id,RW_Project__c,AccountId ,StageName ,RW_Opportunity_Status__c 
                                                      from Opportunity where id =:objOpp.id];
             return objOppToreturn ;
         }       
 }