@isTest
public class SelectAPFControllerTest {
    
    @isTest
    public static void apfTest(){
        
        Project__c prj = new Project__c();
        prj.RW_Project_Code__c = 'T31';
        prj.Name = 'Runwal Gardens';
        prj.RDS_Short_Name__c = 'T';
        prj.Start_Date__c = System.today().addDays(-5);
        prj.RDS_Interest_Rate__c = 12;
        prj.SAPMaterial_Code__c = '1211';
        prj.CRMHead__c = UserInfo.getUserId();
        prj.RW_Project_Location_Videos_Link__c='test';
        prj.RW_Project_Brochure_PublicUrl__c='test1';
        insert prj;
        
        Booking__c bkg = new Booking__c();
        bkg.Project__c = prj.Id;
        bkg.Floor__c=3;
        bkg.Flat_No__c= 'A-5105';
        bkg.RW_Agreement_Status__c='Approved';
        bkg.RW_Signed_Agreement_Document_Id__c ='00690000454';
        bkg.Allotment_Premium__c = 10000;
        insert bkg;
        
        Home_Loan_RM__c hlrm = new Home_Loan_RM__c();
        hlrm.Name = 'Kunal Kate';
        hlrm.Project__c = prj.Id;
        //hlrm.User__c = '0051e000002B3lvAAC';
        hlrm.User__c = '0055j000003mmhYAAQ';
        hlrm.Reporting_1_Email__c = 'rep1@mail.com';
        hlrm.Reporting_2_Email__c = 'rep2@mail.com';
        hlrm.TL_Name__c = 'Apeksha Sathe';
        hlrm.TL_Email__c = 'apeksha@mail.com';
        insert hlrm;
        
        Home_Loan_RM__c hlrm1 = new Home_Loan_RM__c();
        hlrm1.Name = 'Apeksha Sathe';
        hlrm1.Project__c = prj.Id;
        hlrm.Reporting_1_Email__c = 'rep1@mail.com';
        hlrm.Reporting_2_Email__c = 'rep2@mail.com';
        hlrm1.TL_Name__c = 'Apeksha Sathe';
        hlrm1.TL_Email__c = 'apeksha@mail.com';
        insert hlrm1;
        
        Bank_with_RM__c bankRM = new Bank_with_RM__c();
        bankRM.Name = 'Axis Bank Ltd-R Bliss';
        bankRM.RM_Name__c = 'Kunal Kate';
        bankRM.RM_Email__c = 'kunal@mail.com';
        bankRM.TL_Name__c = 'Apeksha Sathe';
        bankRM.TL_Email__c = 'apeksha@mail.com';
        insert bankRM;
        
        Project_Shortforms__c proShort = new Project_Shortforms__c();
        proShort.Name = 'Runwal Bliss';
        proShort.Short_Name__c = 'R Bliss';
        insert proShort;
        
        RM_Usernames__c rm = new RM_Usernames__c();
        rm.RW_Email__c = 'testrm@mail.com';
        rm.Name = 'Bliss RM';
        rm.RW_Reporting_1_Email__c = 'rep1@mail.com';
        rm.RW_Reporting_2_Email__c = 'rep2@mail.com';
        insert rm;
        
        RM_Usernames__c rm1 = new RM_Usernames__c();
        rm1.RW_Email__c = 'testrm@mail.com';
        rm1.Name = 'Apeksha Sathe';
        rm1.RW_Reporting_1_Email__c = 'rep1@mail.com';
        rm1.RW_Reporting_2_Email__c = 'rep2@mail.com';
        insert rm1;
        
        APF__c apf = new APF__c();
        apf.Connector_Code__c = '12345';
        apf.Company__c = 'WACL';
        apf.RW_Bank_Name__c = 'HDFC Bank Ltd';
        apf.RW_Project__c = prj.Id;
        insert apf;
        
        Loan__c l1 = new Loan__c();
        l1.RW_Bank_Name__c = 'Bank Of Baroda';
        l1.RW_Bank_Preference_1__c = 'Bank Of Baroda';
        l1.RW_Tower__c = 'A';
        l1.RW_Loan_Record_Status__c = 'Loan Process Initiated';
        l1.RW_Loan_Account_Number__c = '1234';
        l1.HL_RM_Name__c = 'Kunal Kate';
        l1.HL_TL_Name__c = 'Apeksha Sathe';
        l1.RW_APF__c = apf.Id;
        l1.RW_Booking__c = bkg.Id;
        insert l1;
        
        SelectAPFController.fetchApfRecords('12345');
        SelectAPFController.updateApfOnLoan(apf.Id, l1.Id, '12345');
    }

}