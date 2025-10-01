@isTest
public class CustomerDetailsFormControllerTest {
    
    @isTest	
    public static void customerFormTest(){
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportuniy';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today() + 10;
        opp.No_of_Family_Members__c = 2;
        opp.No_of_Vehicles__c = '2';
        opp.Reason_To_Purchase__c = '';
        opp.Family_Income__c = '';
        opp.Distance_To_Office__c = '';
        opp.Four_Wheeler__c = 'Yes';
        insert opp;
        
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        CustomerDetailsFormController cdf = new CustomerDetailsFormController();
        cdf.getSalutationOptions();
        cdf.getDistanceToOfficeOptions();
        cdf.getFamilyIncomeOptions();
        cdf.getPurchaseReasonOptions();
        cdf.getFourWheelerOptions();
        cdf.getOccupationOptions();
        cdf.getNoOfVehiclesOptions();
        cdf.saveDetails();
        //cdf.getFirstNameChars();
        //cdf.getMiddleNameChars();
        //cdf.getLastNameChars();
        //cdf.getUnitNum();
        //cdf.getFamilyMembers();
        //cdf.getPinCode();
        //cdf.getAddress();
        //cdf.getCompanyName();
        //cdf.getIndustry();
        //cdf.getDesignation();
        //cdf.getNoOfVehicles();
    }

}