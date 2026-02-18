public class TeamMemberService {

    // Added by Dolly (Optimized)
    public static Map<Id, Map<String, Team_Members__c>> getProjectTeamMembers(Set<Id> projectIds, String teamName, List<String> memberLevels){
        Map<Id, Map<String, Team_Members__c>> projToApproverMap = new Map<Id, Map<String, Team_Members__c>>();

        if (projectIds.isEmpty() || String.isBlank(teamName)) {
            return projToApproverMap;
        }

        List<Team_Members__c> teamMembers = [
            SELECT Id, Approver_Type__c, User__r.Id, User__r.Name, User__r.Email,Team__r.Project__c
            FROM Team_Members__c
            WHERE User__c != null
            AND Approver_Type__c IN :memberLevels
            AND Team__r.Name = :teamName
            AND Team__r.Project__c IN :projectIds
            AND IsActive__c = TRUE
        ];

        // Group by Project + ApproverType
        for (Team_Members__c tm : teamMembers) {
            Id projId = tm.Team__r.Project__c;
            if (projId == null || tm.User__r == null) continue;

            if (!projToApproverMap.containsKey(projId)) {
                projToApproverMap.put(projId, new Map<String, Team_Members__c>());
            }

            projToApproverMap.get(projId).put(tm.Approver_Type__c, tm);
        }

        return projToApproverMap;
    }

	public static Map<Id, Map<String, Team_Members__c>> getProjectTeamMembers(Set<String> projectIds, String teamName, List<String> memberLevels){
        // convert Set<String> → Set<Id>
        Set<Id> projIdSet = new Set<Id>();
        for (String s : projectIds) {
            if (String.isNotBlank(s)) {
                projIdSet.add((Id)s);
            }
        }

        // call the original method
        return getProjectTeamMembers(projIdSet, teamName, memberLevels);
    }
}