@isTest
public class SendRMdetailstoSAPTest {

    @isTest
    static void testSendRMdetailstoSAP() {
        // Setup test data
        Date yesterdayDate = System.today().addDays(-1);
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Unit Booked',
            CloseDate = Date.today(),
            SAP_Customer_Number__c = '7189123',
            SalesOrder_Number__c = '1123456',
        	RW_Mobile_No__c = '186112211',
        	RW_Email__c = 'test3723111@gmail.com',
            RW_Sourcing_Manager__c='Rohit Sharma',
            RW_Closing_Head__c = 'Rohit Gupta',
            RW_Sales_Associate__c = UserInfo.getUserId()
            //Last_Sourcing_Closing_Mgr_Change__c = yesterdayDate
        );
        insert opp;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Contact_No__c = '66554433';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;
        
        Legal_Entity__c le = new Legal_Entity__c();
        le.RDS_Company_Code__c = '1000';
        le.Name = 'Test Company 67';
        insert le;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        towerRec.SAP_Plant_Code__c = '4738535';
        insert towerRec;
        
        Profile p1 = [Select Id, Name from Profile where Name = 'Relationship Manager'];
        
        User tuser1 = new User(  firstname = 'TestUs83er',
                               lastName = 'TestUse3353r',
                               email = 'tetxtv7427842@gmail.com',
                               Username = 'tetxtv7687427842@gmail.com',
                               EmailEncodingKey = 'ISO-8859-1',
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p1.id,
                               Tata_CTI_Agent_Number__c = '33443322',
                               Alias = '4657687'
                              );
        insert tuser1;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = towerRec.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser1.Id;
        ObjRm.Contact_Number__c='2154789622';
        insert ObjRm; 

        //Date yesterdayDate = System.today().addDays(-1);
/*select id,RM_Updation_Date__c,Legal_Entity__c,TowerName__r.SAP_Plant_Code__c,RW_Customer__r.SAP_Customer_Number__c,
                                                Unit_SAP_Code__c,Relationship_Manager__r.User__r.Name,Relationship_Manager__r.User__r.Tata_CTI_Agent_Number__c,
                                                Relationship_Manager__r.User__r.Email,Legal_Entity__r.RDS_Company_Code__c  from Project_Unit__*/        
        Project_Unit__c pu1 = new Project_Unit__c();
        //pu1.RM_Updation_Date__c = yesterdayDate;
        pu1.Legal_Entity__c = le.id;
        pu1.TowerName__c = towerRec.id;
        pu1.RW_Customer__c = opp.id;
        pu1.Unit_SAP_Code__c = '365345';
        pu1.RW_Project__c = objpr.Id;
        pu1.Legal_Entity__c = le.Id;
        pu1.RW_Param1__c = '4';
        pu1.UnitNo__c ='11';
        pu1.Relationship_Manager__c = ObjRm.id;
        pu1.RM_Updation_Date__c = yesterdayDate;
        insert pu1;
       /* system.debug('date'+pu.RM_Updation_Date__c);
        system.debug('StageName'+pu.RW_Customer__r.StageName);
        system.debug('SAP_Customer_Number__c'+pu.RW_Customer__r.SAP_Customer_Number__c);*/
         Project_Unit__c pu = new Project_Unit__c();
        pu.RM_Updation_Date__c = yesterdayDate;
        pu.Legal_Entity__c = le.id;
        pu.TowerName__c = towerRec.id;
        pu.RW_Customer__c = opp.id;
        pu.Unit_SAP_Code__c = '365355';
        pu.RW_Project__c = objpr.Id;
        pu.Legal_Entity__c = le.Id;
        pu.RW_Param1__c = '5';
        pu.UnitNo__c ='10';
        pu.Relationship_Manager__c = ObjRm.id;
        insert pu;
        Set<Id> puIds = new Set<Id>();
        puIds.add(pu.Id);
        
        Booking__c booking = new Booking__c(
            Opportunity__c = opp.Id,
            Unit_No__c = pu.Id
        );
        insert booking;

        
        /*opp.Booking__c = booking.id;
        opp.RW_Project_Unit__c = pu.id;
        update opp;*/
        

        // Mocking HTTP response for the callout
        

        // Start test context
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new SendRMdetailstoSAPMock());
        //SendRMdetailstoSAP.getRMdetails();
        
        SendRMDetailsBatch batchJob = new SendRMDetailsBatch();
        Database.executeBatch(batchJob, 1000);
        
        SendRMdetailstoSAP.updateSourcingM_ClosingM_Updation_Date(new Set<id>{opp.id});
        SendRMdetailstoSAP.updateRMUpdationDate(new Set<id>{pu.id});
        Test.stopTest();
    }

    // Mock class for HTTP response
    private class SendRMdetailstoSAPMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            //res.setBody('[{"MANDT": "", "VBELN": "123456", "KUNNR": "789123", "REL_DATE": "01.09.2024"}]');
            return res;
        }
    }
    
    @isTest
    private static void testscheduledClass()
    {
        SendRMDetailsBatchSchedule sch = new SendRMDetailsBatchSchedule();
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        String cronExp = '0 0 * * * ?';
        String jobID = System.schedule('Run Batch Cls Schedule', cronExp, sch);
        Test.stopTest(); 
    }
}