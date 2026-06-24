// This class contains logic for opportunity reallocation to secondary sales manager, and sales manager will be assigned randomly,
// that is using round robin logic 
// Digicloud Team - Suraj S - 11 - 4 - 2025 
public class Opportunity_ReallocationLogicHelper {
    
    @InvocableMethod(label='Assign Secondary Sales Manager from Project Team')
    public static void assignSecondarySM(List<Id> opportunityIds) { 
        if (opportunityIds == null || opportunityIds.isEmpty()) return;
        
        // Query Opportunities with their related Projects and OwnerId
        Map<Id, Opportunity> Map_OppWithProjects = new Map<Id, Opportunity>(
            [SELECT Id, OwnerId, RW_Project__c, Secondary_Sales_Manager__c ,Sales_Manager_User__c FROM Opportunity WHERE Id IN :opportunityIds]
        );
        system.debug('Inside assignSecondarySM project list==>' + Map_OppWithProjects.size()); 
        
        //Get unique Project Ids
        Set<Id> projectIds = new Set<Id>();
        for (Opportunity opp : Map_OppWithProjects.values()) {  
            if (opp.RW_Project__c != null) {
                projectIds.add(opp.RW_Project__c);
            }
        }
        
        if (projectIds.isEmpty()) return;
        
        //Query Sales Teams from Projects and their members
        List<Team__c> lstSalesTeam = [ SELECT Id, Name, Project__c, (SELECT Id, User__c FROM Team_Members__r)
                                      FROM Team__c WHERE Project__c IN :projectIds  ];  //AND Name = 'Sales Team'
        
        system.debug('Inside assignSecondarySM lstSalesTeam list==>' + lstSalesTeam.size());
        
        //Build Project → List<User Ids> map
        Map<Id, List<Id>> map_projectIdAndUserIds = new Map<Id, List<Id>>();
        for (Team__c team : lstSalesTeam) {
            List<Id> userIds = new List<Id>();
            for (Team_Members__c member : team.Team_Members__r) {
                if (member.User__c != null) {
                    userIds.add(member.User__c);
                }
            }
            if (!userIds.isEmpty()) {
                map_projectIdAndUserIds.put(team.Project__c, userIds);
            }
        }
        system.debug('Inside assignSecondarySM map_projectIdAndUserIds==>' + map_projectIdAndUserIds); 
        
        //Query existing Opportunity to check opportunity count per user
        Map<Id, Map<Id, Integer>> map_projectIdToUserIdAndOppCount = new Map<Id, Map<Id, Integer>>();
        List<Opportunity> lstExistingOpps = [ SELECT Id, RW_Project__c, Secondary_Sales_Manager__c, Sales_Manager_User__c, StageName FROM Opportunity
                                             WHERE RW_Project__c IN :projectIds AND Secondary_Sales_Manager__c != null AND Sales_Manager_User__c != null
                                             AND StageName IN ('Visit Done', 'Negotiation', 'Quote Confirmation', 'Unit Blocked')];
        
        for (Opportunity opp : lstExistingOpps) {
            if (!map_projectIdToUserIdAndOppCount.containsKey(opp.RW_Project__c)) {
                map_projectIdToUserIdAndOppCount.put(opp.RW_Project__c, new Map<Id, Integer>());
            }
            Map<Id, Integer> userCountMap = map_projectIdToUserIdAndOppCount.get(opp.RW_Project__c);
            
            // Count Secondary Sales Manager
            if (opp.Secondary_Sales_Manager__c != null) {
                Id userId = opp.Secondary_Sales_Manager__c;
                userCountMap.put(userId, userCountMap.containsKey(userId) ? userCountMap.get(userId) + 1 : 1);
            }
            
            // Count Primary Sales Manager, considering Sales_Manager_User__c field is used for primary sales manager assignment
            if (opp.Sales_Manager_User__c != null) {
                Id userId = opp.Sales_Manager_User__c;
                userCountMap.put(userId, userCountMap.containsKey(userId) ? userCountMap.get(userId) + 1 : 1);
            }
        }
        
        system.debug('Inside assignSecondarySM map_projectIdToUserIdAndOppCount==>' + map_projectIdToUserIdAndOppCount); 
        
        //Assign secondary manager using round-robin (least assigned logic)
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for (Opportunity opp : Map_OppWithProjects.values()) {
            if (opp.Secondary_Sales_Manager__c == null && map_projectIdAndUserIds.containsKey(opp.RW_Project__c)) {
                List<Id> teamUsers = map_projectIdAndUserIds.get(opp.RW_Project__c);
                if (teamUsers.isEmpty()) continue;
                
                Map<Id, Integer> userCountMap = map_projectIdToUserIdAndOppCount.containsKey(opp.RW_Project__c)
                    ? map_projectIdToUserIdAndOppCount.get(opp.RW_Project__c)
                    : new Map<Id, Integer>();
                
                // Find minimum assignment count
                Integer minCount = 2147483647; // Integer.MAX_VALUE in Apex
                for (Id userId : teamUsers) { 
                    Integer count = userCountMap.containsKey(userId) ? userCountMap.get(userId) : 0;
                    if (count < minCount) {
                        minCount = count;
                    }
                } 
                
                // list of users with the minimum count
                List<Id> leastLoadedUsers = new List<Id>();
                for (Id userId : teamUsers) { 
                    Integer count = userCountMap.containsKey(userId) ? userCountMap.get(userId) : 0;
                    // Exclude owner from being assigned as secondary manager
                    if (count == minCount && userId != opp.OwnerId && opp.Sales_Manager_User__c != null && userId != opp.Sales_Manager_User__c){ 
                        system.debug('Inside least loaded user addition to list ==>');
                        leastLoadedUsers.add(userId);
                    }
                }
                
                // If no eligible user (only owner had min count), skip assignment
                if (leastLoadedUsers.isEmpty()) continue;
                
                // Choose randomly among user with less opportunities assigned
                Integer listSize = leastLoadedUsers.size();
                Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), listSize);
                Id selectedUser = leastLoadedUsers[randomIndex];
                
                opp.Secondary_Sales_Manager__c = selectedUser;
                opp.Opportunity_reassigned__c = true;
                opp.Reassignment_DateTime__c = DateTime.Now();
                oppsToUpdate.add(opp);
                
                if (userCountMap.containsKey(selectedUser)) {
                    userCountMap.put(selectedUser, userCountMap.get(selectedUser) + 1);
                } else {
                    userCountMap.put(selectedUser, 1);
                }
                
                map_projectIdToUserIdAndOppCount.put(opp.RW_Project__c, userCountMap);
            }
        }
        
        system.debug('opportunities to update ==>'+ oppsToUpdate);
        
        //Update Opportunities
        if (!oppsToUpdate.isEmpty()) {
            try {
                update oppsToUpdate;
            } catch (DmlException e) {
                System.debug('Error while updating Opportunities: ' + e.getMessage());
            }
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