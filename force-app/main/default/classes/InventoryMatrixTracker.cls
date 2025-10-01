@isTest
public class InventoryMatrixTracker
{
    static testMethod void myUnitTest() 
    {
        Project__c objProj = new Project__c();
        objProj.name = 'test';
        insert objProj;
        
        Project_Unit__c objPU = new Project_Unit__c();
        objPU.name = 'test';
        objPU.RW_Project__c = objProj.id;
        objPU.RW_Param1__c = 'P1';
        objPU.RW_Param2__c = 'T1';
        objPU.RW_Param3__c = 'F1';
        objPU.RW_Param4__c = 'U1';
        objPU.RW_Unit_Status__c = 'Hold';
        insert objPU;
        
        /*Opportunity objopp = new Opportunity();
        objopp.name = 'test';
        objopp.Account = 
        objopp.CloseDate = system.today();
        objopp.StageName = 'Qualification';
        insert objopp;*/
        
        InventoryMatrix objClass = new InventoryMatrix();
        objClass.SelectedProjId = objProj.id;
        objClass.SelectedTowerId = 'T1';
        List<SelectOption> lstSelect = objClass.getProjectNames();
        List<SelectOption> lstSelect1 = objClass.getTowerNames();
        objClass.SelectedTowerId = 'T1';
        objClass.SearchProjectUnit();
        objClass.TowersName();
    }
}