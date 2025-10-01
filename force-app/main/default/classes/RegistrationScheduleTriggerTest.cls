@isTest
public class RegistrationScheduleTriggerTest {

    @isTest
    public static void regScheduleTest(){
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Project';
        proj.RW_Project_Code__c = '180';
        proj.RW_SAP_Company_Code__c = '1000';
        proj.SAPMaterial_Code__c = '1001';
        insert proj;
        
        Booking__c bkg = new Booking__c();
        bkg.Project__c = proj.Id;
        insert bkg;
        
        
        Registration_Schedule__c rs = new Registration_Schedule__c();
        rs.Booking__c = bkg.Id;
        rs.Registration_Schedule_Date__c = Date.today();
        rs.Registration_Schedule_Time__c = '10:30 AM';
        rs.Venue__c = 'Test';
        insert rs;
        
        Registration_Schedule__c rs1 = new Registration_Schedule__c();
        rs1.Booking__c = bkg.Id;
        rs1.Registration_Schedule_Date__c = Date.today();
        rs1.Registration_Schedule_Time__c = '10:30 AM';
        rs1.Venue__c = 'Test';
        insert rs1;
    }
}