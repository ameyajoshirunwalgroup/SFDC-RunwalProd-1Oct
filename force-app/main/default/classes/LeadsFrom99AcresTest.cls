@isTest
public with sharing class LeadsFrom99AcresTest {
    
    @isTest
    private static void test1() {
        LeadsFrom99AcresBatch lb = new LeadsFrom99AcresBatch();
        database.executeBatch(lb, 1);
    }
    
    @isTest
    private static void test2() {
        
        Group_Name__c gp = new Group_Name__c();
        gp.Name = 'Runwal Bliss';
        gp.Project_Name__c = 'Runwal Bliss';
        insert gp;
        
        Project__c proj = new Project__c();
        proj.Name = 'Runwal Bliss';
        insert proj;
        
        LeadsFrom99AcresBatch lb = new LeadsFrom99AcresBatch();
        database.executeBatch(lb, 1);
    }
    
}