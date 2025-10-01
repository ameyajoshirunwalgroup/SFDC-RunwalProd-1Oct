@isTest
public class RWCIFControllerTracker 
{
    static testMethod void unitTest()
    {
        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test@gmail.com';
        objLead.Rating = 'Hot';
        objLead.MobilePhone = '1212121212';
        objLead.RW_Mobile_No__c = '1212121212';
        objLead.LeadSource = 'Digital';
        objLead.Corporate_Company__c  = 'Other';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        objLead.RW_Date_of_Birth__c = System.today();
        objLead.RW_Customer_Type__c = 'NRI';
        objLead.RW_Occupation__c = 'test';
        objLead.RW_Ethnicity__c = 'test';
        objLead.RW_Budget_Rs_in_Cr__c = 10000;
        insert objLead;

        ApexPages.StandardController sc = new ApexPages.StandardController(objLead);
        ApexPages.currentPage().getParameters().put('id', objLead.Id);
        RWCIFController objCls = new RWCIFController(sc);
        
        objCls.strCurrentSource = 'Print Newspaper';

        objCls.validateLeadSource();

        PageReference obPage = objCls.GoBackToLead();

        PageReference obSave = objCls.redirectNext();
    }
}