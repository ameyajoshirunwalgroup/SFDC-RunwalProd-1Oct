public with sharing class UnitControllerD {
  public Id unitId {get;set;}
  public Map<String, Decimal> allChargesMap = new Map<String,Decimal>();
  public Project_Unit__c unit {get;set;}
  public UnitControllerD() {
    unitId = (Id) ApexPages.CurrentPage().getParameters().get('id');
    unit = [Select Id,Name, RW_Project__c,Floor_Rise__c, PLC1__c,View__c,Legal_Entity__c,Chargeable_Area__c,
                              /*Property_Type__c,*/RW_Floor__c,TowerName__c,RW_Unit_Status__c,Carpet_Area__c
                                   from Project_Unit__c where Id = :unitId LIMIT 1];  
  
    }
                                   
  public  void getAllCharges() {
    allChargesMap = InventoryCostServices.getAllCharges(unitId,0.0,0.0,null);
  }
  
  public Map<String, Double> getAllChargesMap() {
    return allChargesMap;
  }
}