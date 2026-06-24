@isTest
public class TeamMemberServiceTest {

    // ---------- Helper Method Inside This Test Class ----------
    private static User createUser(String email) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = email,
            Username = email+ 'test',
            Alias = 'tst',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        return u;
    }

    // =======================================================================
    // TEST 1: Set<Id> method
    // =======================================================================
    @isTest
    public static void testGetProjectTeamMembers_IdSet() {

        // Create Users
        User u1 = createUser('user1@test.com');
        User u2 = createUser('user2@test.com');
        insert new List<User>{u1, u2};

        // Create Project
        Project__c proj = new Project__c(Name = 'Project A');
        insert proj;

        // Create Team
        Team__c team = new Team__c(
            Name = 'CP Approvers Team',
            Project__c = proj.Id
        );
        insert team;

        // Create Team Members
        Team_Members__c tm1 = new Team_Members__c(
            Team__c = team.Id,
            User__c = u1.Id,
            Approver_Type__c = 'CP MIS'
        );
        Team_Members__c tm2 = new Team_Members__c(
            Team__c = team.Id,
            User__c = u2.Id,
            Approver_Type__c = 'CP Invoice Approver L1'
        );
        insert new List<Team_Members__c>{tm1, tm2};

        // Call Method
        Set<Id> projIds = new Set<Id>{ proj.Id };
        List<String> levels = new List<String>{ 'CP MIS', 'CP Invoice Approver L1' };

        Map<Id, Map<String, Team_Members__c>> result =
            TeamMemberService.getProjectTeamMembers(projIds, 'CP Approvers Team', levels);

        // Assertions
        System.assertEquals(1, result.size(), 'Project count should be 1');
        Map<String, Team_Members__c> approverMap = result.get(proj.Id);
        System.assertEquals(2, approverMap.size(), 'Approver count should be 2');

        System.assertEquals(tm1.Id, approverMap.get('CP MIS').Id, 'Mismatch in CP MIS');
        System.assertEquals(tm2.Id, approverMap.get('CP Invoice Approver L1').Id, 'Mismatch in L1 Approver');
    }


    // =======================================================================
    // TEST 2: Set<String> method
    // =======================================================================
    @isTest
    public static void testGetProjectTeamMembers_StringSet() {

        // Create User
        User u = createUser('user3@test.com');
        insert u;

        // Create Project
        Project__c proj = new Project__c(Name = 'Project B');
        insert proj;

        // Create Team
        Team__c team = new Team__c(
            Name = 'CP Approvers Team',
            Project__c = proj.Id
        );
        insert team;

        // Create Team Member
        Team_Members__c tm = new Team_Members__c(
            Team__c = team.Id,
            User__c = u.Id,
            Approver_Type__c = 'CP MIS'
        );
        insert tm;

        // Call overloaded method
        Set<String> projIdsAsString = new Set<String>{ String.valueOf(proj.Id) };
        List<String> levels = new List<String>{ 'CP MIS' };

        Map<Id, Map<String, Team_Members__c>> result =
            TeamMemberService.getProjectTeamMembers(projIdsAsString, 'CP Approvers Team', levels);

        // Assertions
        System.assertEquals(1, result.size());
        System.assert(result.containsKey(proj.Id));
        System.assertEquals(tm.Id, result.get(proj.Id).get('CP MIS').Id);
    }
}