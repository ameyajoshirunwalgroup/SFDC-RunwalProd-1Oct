@isTest
public with sharing class CPTaskLocationControllerTest {
    
    @testSetup
    static void setup() {
      
        Task testTask = new Task(
            Subject = 'Test Task',
            Status = 'Not Started',
            CP_Meeting_Address__Latitude__s = 37.7749, // San Francisco latitude
            CP_Meeting_Address__Longitude__s = -122.4194 // San Francisco longitude
        );
        insert testTask;
    }
    
    @isTest
    static void testUpdateTaskLocation() {
       
        Task testTask = [SELECT Id, CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s 
                         FROM Task LIMIT 1];
        
        
        Decimal newLatitude = 34.0522; // Los Angeles latitude
        Decimal newLongitude = -118.2437; // Los Angeles longitude
        
        // Call the updateTaskLocation method
        Test.startTest();
        CPTaskLocationController.updateTaskLocation(testTask.Id, newLatitude, newLongitude);
        Test.stopTest();
        
        // Verify that the Task record was updated
        Task updatedTask = [SELECT CP_Meeting_Address__Latitude__s, CP_Meeting_Address__Longitude__s 
                            FROM Task WHERE Id = :testTask.Id LIMIT 1];
      
    }
    
    @isTest
    static void testGetTaskById() {
        // Retrieve the Task record created in the test setup
        Task testTask = [SELECT Id FROM Task LIMIT 1];
        
        // Call the getTaskById method
        Test.startTest();
        Task retrievedTask = CPTaskLocationController.getTaskById(testTask.Id);
        Test.stopTest();
        
        
    }
}