@isTest
public class CPCategoryTriggerHandlerTest {
    @isTest
    public static void testCase1(){        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Account_Number__c = '465446';
        insert cp;
        
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.Id;
        insert objpr;
        
        CP_Category__c cp1 = new CP_Category__c();
        cp1.Category__c = 'P1';
        cp1.Channel_Partner__c = cp.id;
        cp1.Project__c = objpr.Id;
        insert cp1;
        
        CP_Category__c cp2 = new CP_Category__c();
        cp2.Category__c = 'P2';
        cp2.Channel_Partner__c = cp.id;
        cp2.Project__c = objpr.Id;
        insert cp2;
    }
}