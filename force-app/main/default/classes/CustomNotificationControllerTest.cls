@isTest
public class CustomNotificationControllerTest {
	@isTest
    static void testCustomNotificationController() {
        // Setup Test Data
        
        Account acc = new Account();
        acc.Mobile_No__c = '2222332211';
        acc.Name = 'Test Acc';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test opp';
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.CloseDate = Date.today() + 10;
        opp.RW_Mobile_No__c = '122112211';
        opp.RW_Email__c = 'test23111@gmail.com';
        insert opp;
        
        Project_Shortforms__c ps = new Project_Shortforms__c();
        ps.Name = 'Runwal Bliss';
        ps.Short_Name__c = 'R Bliss';
        insert ps;
        
        Booking__c bkg = new Booking__c();
        bkg.Opportunity__c = opp.Id;
        //bkg.Loan_Bank__c = 'HDFC Bank Ltd';
        
        insert bkg;
        
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
        
        bkg.RW_Key_handover_date__c = Date.today();
        //bkg.RW_Registration_Date__c = Date.today();
        bkg.Booking_Date__c = Date.today();
        bkg.Unit_No__c = objPUU1.Id;
        bkg.Interest_to_be_Applied__c = 'Yes';
        bkg.Status__c= 'Booking Confirmed';
        update bkg;
        
        Task task1 = new Task(
           // CI_Form__c = cif1.Id,
            Description = 'Feedback provided',
            Status = 'Not Started',Visit_Form_No__c='1233'
        );
        Task task2 = new Task(
            //CI_Form__c = cif2.Id,
            Status = 'Not Started',Subject = 'New Enquiry Received From:Digital', Description = 'Tet--- phone_number-----',OwnerId = userinfo.getUserId()
        );
        
        // Test method
        Test.startTest();
        CustomNotificationController.taskAssignmentNotification(new list<task>{task2});
        Test.stopTest();
    }
}