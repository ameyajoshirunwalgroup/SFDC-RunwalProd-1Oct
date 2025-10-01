@isTest
public class ServiceRoomUnitHandlerTest {
    
    @testSetup static void setup() {
        Project__c proj = new Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Tower__c tower = new Tower__c();
        tower.Name = 'Test Tower';
        tower.ProjectName__c =proj.Id;
        insert tower;
        
        Project_Unit__c unit = new Project_Unit__c();
        unit.Name = 'Test Unit';
        unit.RW_Project__c = proj.Id;
        unit.TowerName__c = tower.Id;
        unit.New_Floor__c = '10';
        unit.RW_Param1__c = 'Param 1';
        unit.RW_Param2__c = 'Param 2';
        unit.RW_Param3__c = 'Param 3';
        unit.RW_Param4__c = 'Param 4';
        unit.Carpet_Area__c = 10;
        unit.Deck_Area__c = 10;
        unit.Utility_Area__c = 10;
        unit.Saleable_Area__c = 1000;
        unit.Total_RERA_Carpet_Area__c = 30;
        unit.Loading__c = 1.5;
        unit.Avail_Service_Room__c = false;
        unit.Is_Service_Room_Unit__c = false;
        unit.Total_RERA_Carpet_Area__c = 1000;
        insert unit;
        
        Project_Unit__c sr = new Project_Unit__c();
        sr.Name = 'Service Room';
        sr.RW_Project__c = proj.Id;
        sr.TowerName__c = tower.Id;
        sr.New_Floor__c = '10';
        sr.Is_Service_Room_Unit__c = true;
        sr.RW_Param1__c = 'Param 1';
        sr.RW_Param2__c = 'Param 2';
        sr.RW_Param3__c = 'Param 3';
        sr.RW_Param4__c = 'Param 4';
        sr.Carpet_Area__c = 10;
        sr.Deck_Area__c = 10;
        sr.Utility_Area__c = 10;
        sr.Service_Room_Status__c = 'Available';
        sr.Avail_Service_Room__c = false;
        insert sr;
            
    }
    
    @isTest
    public static void serviceRoomTest(){
        Project_Unit__c unit = [SELECT Id, Total_RERA_Carpet_Area__c, Loading__c FROM Project_Unit__c WHERE Is_Service_Room_Unit__c = false];
        unit.Avail_Service_Room__c = true;
        update unit;
        
        unit.Avail_Service_Room__c = false;
        update unit;
        
        ServiceRoomUnitHandler.updateSaleableAreaOnUnits(new List<Project_Unit__c>{unit});
        ServiceRoomUnitHandler.updateRateList(new List<Id>{unit.id});
    }

}