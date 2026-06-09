public with sharing class TaskTriggerHandler {

    /**
     * Main method called by the trigger to handle appending Remarks to Description
     */
    public static void handleRemarksAppend(List<Task> newTasks, Map<Id, Task> oldTasksMap, Boolean isUpdate) {
        if(checkRecursion.isFirstRun()) {
            // 1. Get the Record Type ID for 'Retention_Task' dynamically
            Id retentionRecordTypeId;
            try {
                retentionRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                                              .get('Retention_Task')
                                              .getRecordTypeId();
            } catch (Exception e) {
                // Fallback/Safety check: If the record type doesn't exist in this env, stop execution
                System.debug('Error: Record Type Retention_Task not found. ' + e.getMessage());
                return;
            }
    
            List<Task> tasksToUpdate = new List<Task>();
            
            for (Task newObj : newTasks) {
                
                // 2. CRITICAL CHECK: Filter by the 'Retention_Task' Record Type ID
                if (newObj.RecordTypeId != retentionRecordTypeId) {
                    continue; // Skip any task that is not a Retention Task
                }
    
                // Only execute if Remarks__c contains data
                if (String.isNotBlank(newObj.Remarks__c)) {
                    
                    // If updating, verify that Remarks__c actually changed to prevent recursive loops
                    if (isUpdate && oldTasksMap != null) {
                        Task oldObj = oldTasksMap.get(newObj.Id);
                        if (newObj.Remarks__c == oldObj.Remarks__c) {
                            continue; // Skip processing for this record
                        }
                    }
                    
                    System.debug('newObj.Remarks__c---->'+newObj.Remarks__c);
                    
                    // Construct an explicit update instance using the Task ID
                    Task updatedTask = new Task(Id = newObj.Id);
                    
                    // Generate the Timestamp and format the snippet
                    String timestamp = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
                    String newSnippet = '[' + timestamp + '] ' + newObj.Remarks__c;
                    
                    System.debug('newObj.Description---->'+newObj.Description);
                    // Append logic
                    if (String.isNotBlank(newObj.Description)) {
                        newObj.Description = newSnippet + '\n' + newObj.Description;
                    } else {
                        newObj.Description = newSnippet;
                    }
                    
                    // Clear out the entry field so it is clean for the next remark
                    // updatedTask.Remarks__c = ''; 
                    
                    // tasksToUpdate.add(updatedTask);
                }
            }
            
            // Commit the changes in the after context
            /*if (!tasksToUpdate.isEmpty()) {
                update tasksToUpdate;
            }*/
        }
    }
}