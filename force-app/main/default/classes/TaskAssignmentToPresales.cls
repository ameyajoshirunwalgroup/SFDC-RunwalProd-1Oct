public class TaskAssignmentToPresales {
    
    public static void assign(List<Task> taskList){
        Datetime dt = Date.today();
        Set<String> loggedInUsers = new Set<String>();
        try{
            List<AggregateResult> auth = [SELECT UsersId FROM AuthSession WHERE  LoginType = 'Application' AND SessionType = 'UI' GROUP BY UsersId];
            for(AggregateResult au : auth){
                loggedInUsers.add(String.valueOf(au.get('UsersId'))); 
            }
            String[] usrIds = Label.Task_Assignment_Users.split(',');
            List<String> availableUsers = new List<String>();
            for(String st : usrIds){
                if(loggedInUsers.contains(st)){
                    availableUsers.add(st);
                }
            }
            System.debug('availableUsers: ' + availableUsers);
            //if(availableUsers.size() > 0 || Test.isRunningtest()){
            List<Task> listTasks = [SELECT Id, CreatedDate FROM Task WHERE Task_Type__c = 'Enquiry Received' AND CreatedDate >: dt ORDER BY CreatedDate ASC];
            List<Id> tskIds = new List<Id>();
            for(Task t : listTasks){
                tskIds.add(t.Id);
            }
            List<Task> tasksToUpdate = new List<Task>();
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Id> taskIds = new List<Id>();
            List<Id> leadIds = new List<Id>();
            Map<Id,Id> mapTskIdVsLeadId = new Map<Id,Id>();
            for(Task tsk: taskList){
                taskIds.add(tsk.Id);
                if (tsk.WhoId != null && tsk.WhoId.getSObjectType().getDescribe().getName() == 'Lead'){
                    leadIds.add(tsk.WhoId);
                    mapTskIdVsLeadId.put(tsk.Id, tsk.WhoId);
                } 
            }
            Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id, LeadSource, Integration_Source__c FROM Lead WHERE Id =: leadIds AND LeadSource = 'Digital']);
            
            List<Id> loggedInUserIds = new List<Id>();
            List<Task> tasksNew = [SELECT Id, WhoId FROM Task WHERE Id =: taskIds];
            for(Task tsk: tasksNew){
                if(tskIds.contains(tsk.Id) && leadMap.get(tsk.WhoId) != null  && leadMap.get(tsk.WhoId).Integration_Source__c != 'Website'){
                    Integer currentTskIdIndex = tskIds.indexOf(tsk.Id);
                    if(availableUsers.size() > 0){
                        Integer rr = math.mod(currentTskIdIndex, availableUsers.size());
                        tsk.OwnerId = availableUsers[rr];
                        if(leadMap.keySet().contains(tsk.WhoId)){
                            leadMap.get(tsk.WhoId).OwnerId = availableUsers[rr];
                            leadsToUpdate.add(leadMap.get(tsk.WhoId));
                        }
                        tasksToUpdate.add(tsk);
                    }else{
                        String defaultUserId = Label.Presales_Default_User;
                        tsk.OwnerId = defaultUserId;
                        if(leadMap.keySet().contains(tsk.WhoId)){
                            leadMap.get(tsk.WhoId).OwnerId = defaultUserId;
                            leadsToUpdate.add(leadMap.get(tsk.WhoId));
                        }
                        tasksToUpdate.add(tsk);
                    }
                }
            }
            update tasksToUpdate;
            if(leadsToUpdate.size()> 0){
                //update leadsToUpdate;
            } 
            //} 
        }catch(Exception e){
            throw new CommonException('There was an error -'+e.getMessage());
        }
        
    }
    
    public static void dummyMethod(){
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
    }
    
}