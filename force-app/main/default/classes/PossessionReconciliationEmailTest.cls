@isTest
public class PossessionReconciliationEmailTest {
    @istest
    private static void reconciliationEmailTest(){
        Account a=new Account();
        a.FirstName='test';
        a.LastName='test2';
        a.PersonEmail='abc@xyz.com';
        a.Mobile_No__c='12345';
        insert a;
       
        Project__c pro=new Project__c();
        pro.Name='Runwal Bliss';
        pro.RW_Project_Code__c='3';
        pro.RW_Status__c='Active';
        insert pro;
        
        Opportunity opty=new Opportunity();
        opty.RW_Project__c=pro.id;
        opty.Name='test';
        opty.AccountId=a.id;
        opty.RW_Email__c='abc@xyz.com';
        opty.StageName='Unit Booked';
        opty.RW_Mobile_No__c='12345';
        opty.CloseDate=system.today();
        opty.RW_Rating__c='warm';
        opty.Remark__c='Test';
        opty.LeadSource='TV';
        insert opty;  
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = opty.Id;
        objBking.Project__c = pro.Id;
        objBking.Opportunity__c = opty.Id;
        objBking.Primary_Applicant_Email__c = 'test@mail.com';
        //objBking.Unit_No__c = objPUU.id;
        insert objBking;
        
        Applicant_Details__c ad = new Applicant_Details__c();
        ad.Name='Test';
        ad.Opportunity__c = opty.Id;
        ad.Booking__c = objBking.Id;
        ad.DOB__c=System.today();
        ad.Subtype_Of_Applicant__c='For NRI';
        ad.Permanent_Address__c ='abc';
        ad.Organisation_Pincode__c=123456;
        ad.Mailing_Pincode__c =234567;
        ad.Organisation_Country__c ='india';
        ad.Mailing_Country__c ='india';
        ad.Mobile_Number__c= '1234567899';
        ad.Email_Address__c='abc@xyz.com';
        ad.Nationality__c='India';
        insert ad;
        
        Possession_Reconciliation__c pr1 = new Possession_Reconciliation__c();
        pr1.Name = 'Test1';
        pr1.Booking_Status__c = 'Booking Confirmed';
        pr1.Email_Template__c = 'Runwal Gardens Payment Reconciliation';
        pr1.Project__c = 'Runwal Bliss';
        pr1.Towers__c = 'A';
        pr1.End_Date__c = Date.today() - 1;
        pr1.Scheduling_Time__c = '10:00';
        pr1.Scheduling_Days__c = 'MON';
        insert pr1;
        
        Possession_Reconciliation__c pr2 = new Possession_Reconciliation__c();
        pr2.Name = 'Test2';
        pr2.Booking_Status__c = 'Booking Confirmed';
        pr2.Email_Template__c = 'Runwal Gardens Payment Reconciliation';
        pr2.Project__c = 'Runwal Gardens';
        pr2.Towers__c = 'Tower 13';
        pr2.End_Date__c = Date.today() + 1;
        pr2.Scheduling_Time__c = '10:00';
        pr2.Scheduling_Days__c = 'MON';
        insert pr2;
        
        pr1.End_Date__c = Date.today() + 4;
        update pr1;
        
        Test.startTest();
        List<String> towers = pr1.Towers__c.split(',');
        //PossessionReconciliationEmail b = new PossessionReconciliationEmail(pr.Project__c, towers, pr.Start_Date1__c, pr.End_Date__c, pr.Booking_Status__c, pr.Email_Template__c);
		PossessionReconciliationEmail b = new PossessionReconciliationEmail(pr1);
        Database.executeBatch(b, 200);
        
        delete pr2;
        
        Test.stopTest();
    }

}