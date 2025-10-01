@isTest
public class UpdateSOReleasedDateFromSAPTest {

    @isTest
    static void testUpdateSOReleased() {
        // Setup test data
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Unit Booked',
            CloseDate = Date.today(),
            SAP_Customer_Number__c = '789123',
            SalesOrder_Number__c = '123456',
        	RW_Mobile_No__c = '122112211',
        	RW_Email__c = 'test23111@gmail.com'
        );
        insert opp;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        insert objpr;


        list<User> usr = [Select Id from User where Id =: userinfo.getUserId()];
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        //ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = usr[0].Id;
        ObjRm.Contact_Number__c='1287654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        //objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit173'; 
        objPUU1.Relationship_Manager__c = ObjRm.Id;
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        Booking__c booking = new Booking__c(
            Opportunity__c = opp.Id,
            Unit_No__c = objPUU1.Id
        );
        insert booking;

        // Mocking HTTP response for the callout
        Test.setMock(HttpCalloutMock.class, new UpdateSOReleasedDateFromSAPMock());

        // Start test context
        Test.startTest();
        //UpdateSOReleasedDateFromSAP b = new UpdateSOReleasedDateFromSAP();
        UpdateSOReleasedDateFromSAP.updateSOReleased();
        Test.stopTest();

    }

    // Mock class for HTTP response
    private class UpdateSOReleasedDateFromSAPMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"MANDT": "", "VBELN": "123456", "KUNNR": "789123", "REL_DATE": "01.09.2024"}]');
            return res;
        }
    }
}