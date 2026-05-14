@isTest
private class TestQuotationClass_Calc {

   @isTest
static void test_updateCalculations_successPath() {
    // 1. Setup Data using your existing RDSCommon logic
    Account objac = new Account();
    objac.FirstName = 'Shock';
    objac.LastName = 'Wave';
    objac = RDSCommon.CreateAccount(objac);
    
    Legal_Entity__c objlglentity = new Legal_Entity__c();
    objlglentity.Name = 'RS';
    objlglentity.RDS_Company_Code__c = 'rs';
    objlglentity.RDS_Service_Tax_No__c = '123456789012345';
    objlglentity.RDS_Company_Name__c = '111';
    objlglentity.RDS_Address1__c = '123';
    objlglentity.RDS_Address2__c = '234';
    objlglentity.RDS_City__c = 'delhi';
    objlglentity.RDS_Pin_Code__c = '201301';
    objlglentity.RDS_Phone__c = '9953528045';
    objlglentity = RDSCommon.CreateLegalEntity(objlglentity);
    
    Project__c objpr = new Project__c();
    objpr.RW_Project_Code__c = 'T35';
    objpr.Name = 'TestProject';
    objpr.RDS_Company_Code__c = objlglentity.Id;
    objpr.Project_Stage__c = 'Launch';
    objpr = RDSCommon.CreateProject(objpr);
    
    Tower__c t = new Tower__c();
    t.Name = 'Tower X';
    t.ProjectName__c = objpr.Id;
    t = RDSCommon.CreateTower(t);
    
    Project_Unit_Type__c objProjectUnitType = new Project_Unit_Type__c();
    objProjectUnitType.name = 'ONE BHK';
    objProjectUnitType.RDS_Project__c = objpr.id;
    objProjectUnitType = RDSCommon.CreateProjectUnitType(objProjectUnitType);
    
    Opportunity objOpportunity = new Opportunity();
    objOpportunity.Name = 'Test';
    objOpportunity.CloseDate = System.today();
    objOpportunity.AccountId = objac.Id; 
    objOpportunity.Status__c = 'Active'; 
    objOpportunity.StageName = 'Unit Blocked'; 
    objOpportunity.RW_Project__c = objpr.Id; 
    objOpportunity = RDSCommon.CreateOpportunity(objOpportunity);
    
    Project_Unit__c objPU1 = new Project_Unit__c();
    objPU1.Name = 'TestCalc';
    objPU1.RW_Project__c = objpr.Id;
    objPU1.Project_Unit_Type__c = objProjectUnitType.id;
    objPU1.RW_Unit_status__c = 'Booked';
    objPU1.TowerName__c = t.Id;
    objPU1.Actual_Area_value__c = 2218;
    objPU1.RW_Param1__c = '5';
    objPU1.UnitNo__c = 'TestCalc';
    objPU1.RW_Booking_Date__c = system.Today();
    objPU1.New_Floor__c = '8';
    objPU1.RW_Floor__c = 8;
    objPU1.Single_car_park_Earmarked__c = 0;
    objPU1.Single_Open_Earmarked__c = 0;
    objPU1.Tandem_Open_Earmarked__c = 0;
    objPU1.Tandem_car_park_Earmarked__c = 0;
    objPU1.MLCP_Earmarked__c = 0;
    objPU1.Stack__c = 0;
    objPU1.Saleable_Area__c = 1200;
    objPU1 = RDSCommon.CreateProjectUnit(objPU1);
    
    Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
    objPaymentPlan.Name = 'Pay Plan 1';
    objPaymentPlan.Project__c = objpr.Id;
    objPaymentPlan.Tower__c = t.Id;
    insert objPaymentPlan;

    // 2. Set VF Page Context
    PageReference pRef4 = Page.Quotation2;
    Test.setCurrentPage(pRef4);
    ApexPages.currentPage().getParameters().put('oppId', objOpportunity.id);
    ApexPages.currentPage().getParameters().put('id', objPU1.id);

    // 3. Initialize Controller
    QuotationExtn ctrl = new QuotationExtn();

    // 4. Set variables to reach the successful part of updateCalculations
    ctrl.isCalculateDiscountClicked = true;
    ctrl.sdPaidByRunwal = true;
    ctrl.regChargesByRunwal = false;

    ctrl.unitId = objPU1.Id; 
    ctrl.subPlanId = objPaymentPlan.Id;
    ctrl.selectedPlan = objPaymentPlan.Id;
    
    ctrl.discountLumpsum = 10000;
    ctrl.carParkAmt = 5000;
    ctrl.allotmentCharges = 2000;
    ctrl.addCarParks = 0;
    ctrl.premiumRate = 100;
    ctrl.agreementValue = 5000000;

    Test.startTest();
    ctrl.updateCalculations();
    Test.stopTest();
}

}