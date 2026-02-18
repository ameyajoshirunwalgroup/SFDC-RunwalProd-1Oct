public class LocobuzzCaseAssignment {

    @InvocableMethod
    public static void updateCaseOwner(List<Id> caseIds){
        assignToProjectSpoc(caseIds);
    }
    
    public static void assignToProjectSpoc(List<Id> caseIds){
        List<Case> locoBuzzCasese = new List<Case>();
        Set<String> accountIds = new Set<String>();
        List<Case> caseList = [SELECT Id, locobuzz__Locobuzz_ID__c, RW_Project_Text__c, Department__c, AccountId, OwnerId, Locobuzz_Owner_Assigned__c, RW_Project__c FROM Case WHERE Id =: caseIds];
        for(Case cs : caseList){
            //if(cs.locobuzz__Locobuzz_ID__c != null && cs.locobuzz__Locobuzz_ID__c != '' && cs.RW_Project_Text__c != null && cs.Locobuzz_Owner_Assigned__c == false){
            if(cs.locobuzz__Locobuzz_ID__c != null && cs.locobuzz__Locobuzz_ID__c != '' && cs.RW_Project_Text__c != null && (cs.Locobuzz_Owner_Assigned__c == false || cs.OwnerId == System.label.System_Administrator_User_Id)){
                locoBuzzCasese.add(cs);
                accountIds.add(cs.AccountId);
            }
        }
        
        if(locoBuzzCasese.size() > 0){
            
            List<Project__c> projs = [SELECT Id, Name FROM Project__c WHERE RW_Status__c = 'Active'];
            Map<String, String> projMap = new Map<String, String>();
            for(Project__c proj : projs){
                projMap.put(proj.Name, proj.Id);
            }
            
            List<Opportunity> opps = [SELECT Id, AccountId, RW_Project_Unit__r.RW_Param2__c, RW_Project__r.Name FROM Opportunity WHERE AccountId =: accountIds AND RW_Project__r.Name = 'Runwal Gardens' AND StageName = 'Unit Booked' AND RW_Project_Unit__r.RW_Param2__c != null];
            Map<String, String> accIdVsTower = new Map<String, String>();
            for(Opportunity opp : opps){
                accIdVsTower.put(opp.AccountId, opp.RW_Project_Unit__r.RW_Param2__c);
            }
            
            list<group> lstQueue = [SELECT Id, Name FROM group WHERE Type ='Queue' AND Name = 'General-Queue'];
            
            Map<String, Locobuzz_Project_Spocs__c> spocs = Locobuzz_Project_Spocs__c.getall();
            Map<String, String> userMap = spocUsers(spocs);
            List<String> projTextValuesToExclude = new List<String>{'Not a customer/ Others', 'Not a customer', 'Others'};
            Boolean ownerAssigned = false; //Added by Vinay 10-04-2025
            Database.DMLOptions options = new Database.DMLOptions(); //Added by Vinay 16-04-2025
			options.assignmentRuleHeader.useDefaultRule = false; //Added by Vinay 16-04-2025
            for(Case cs : locoBuzzCasese){
                if(!projTextValuesToExclude.contains(cs.RW_Project_Text__c)){
                    cs.RW_Project__c = projMap.get(cs.RW_Project_Text__c);
                }
                for(Locobuzz_Project_Spocs__c spoc : spocs.values()){
                    if(spoc.Department__c == 'Projects' && spoc.Project_Name__c == 'Runwal Gardens'){
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c && spoc.Tower__c == accIdVsTower.get(cs.AccountId)){
                            cs.OwnerId = (userMap.get(spoc.L1_Spoc_Email__c) != null)? userMap.get(spoc.L1_Spoc_Email__c) : lstQueue[0].Id;
                            //cs.Escalation_Level__c = 'New';
                            cs.Tower__c = accIdVsTower.get(cs.AccountId);
                            cs.Locobuzz_Owner_Assigned__c = true;
                            ownerAssigned = true; //Added by Vinay 10-04-2025
                        }
                    }else{
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c){
                            cs.OwnerId = (userMap.get(spoc.L1_Spoc_Email__c) != null)? userMap.get(spoc.L1_Spoc_Email__c) : lstQueue[0].Id;
                            cs.Locobuzz_Owner_Assigned__c = true;
                            ownerAssigned = true; //Added by Vinay 10-04-2025
                            //cs.Escalation_Level__c = 'New';
                        }
                    }
                    if(ownerAssigned == false){
                       cs.OwnerId = System.label.General_Queue_Id;
                    }
                }
            }
            update locoBuzzCasese;
        }
    }
    
    /*public static void assignToProjectSpoc(List<Case> caseList){
        List<Case> locoBuzzCasese = new List<Case>();
        Set<String> accountIds = new Set<String>();
        List<Id> caseIds = new List<Id>(); //Added by Vinay 23-04-2025
        //List<Case> cases = [SELECT Id, locobuzz__Locobuzz_ID__c, RW_Project_Text__c, Department__c, AccountId, OwnerId FROM Case WHERE Id =: caseList];
        for(Case cs : caseList){
            if(cs.locobuzz__Locobuzz_ID__c != null && cs.locobuzz__Locobuzz_ID__c != '' && cs.RW_Project_Text__c != null && cs.Locobuzz_Owner_Assigned__c == false){
                locoBuzzCasese.add(cs);
                accountIds.add(cs.AccountId);
                caseIds.add(cs.Id); //Added by Vinay 23-04-2025
            }
        }
        updateCaseOwner(caseIds); //Added by Vinay 23-04-2025
        if(locoBuzzCasese.size() > 0){
            
            List<Project__c> projs = [SELECT Id, Name FROM Project__c WHERE RW_Status__c = 'Active'];
            Map<String, String> projMap = new Map<String, String>();
            for(Project__c proj : projs){
                projMap.put(proj.Name, proj.Id);
            }
            
            List<Opportunity> opps = [SELECT Id, AccountId, RW_Project_Unit__r.RW_Param2__c, RW_Project__r.Name FROM Opportunity WHERE AccountId =: accountIds AND RW_Project__r.Name = 'Runwal Gardens' AND StageName = 'Unit Booked' AND RW_Project_Unit__r.RW_Param2__c != null];
            Map<String, String> accIdVsTower = new Map<String, String>();
            for(Opportunity opp : opps){
                accIdVsTower.put(opp.AccountId, opp.RW_Project_Unit__r.RW_Param2__c);
            }
            
            list<group> lstQueue = [SELECT Id, Name FROM group WHERE Type ='Queue' AND Name = 'General-Queue'];
            
            Map<String, Locobuzz_Project_Spocs__c> spocs = Locobuzz_Project_Spocs__c.getall();
            Map<String, String> userMap = spocUsers(spocs);
            List<String> projTextValuesToExclude = new List<String>{'Not a customer/ Others', 'Not a customer', 'Others'};
            Boolean ownerAssigned = false; //Added by Vinay 10-04-2025
            Database.DMLOptions options = new Database.DMLOptions(); //Added by Vinay 16-04-2025
			options.assignmentRuleHeader.useDefaultRule = false; //Added by Vinay 16-04-2025
            for(Case cs : locoBuzzCasese){
                if(!projTextValuesToExclude.contains(cs.RW_Project_Text__c)){
                    cs.RW_Project__c = projMap.get(cs.RW_Project_Text__c);
                }
                for(Locobuzz_Project_Spocs__c spoc : spocs.values()){
                    if(spoc.Department__c == 'Projects' && spoc.Project_Name__c == 'Runwal Gardens'){
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c && spoc.Tower__c == accIdVsTower.get(cs.AccountId)){
                            cs.OwnerId = (userMap.get(spoc.L1_Spoc_Email__c) != null)? userMap.get(spoc.L1_Spoc_Email__c) : lstQueue[0].Id;
                            //cs.Escalation_Level__c = 'New';
                            cs.Tower__c = accIdVsTower.get(cs.AccountId);
                            cs.Locobuzz_Owner_Assigned__c = true;
                            ownerAssigned = true; //Added by Vinay 10-04-2025
                            System.debug('SPOC: ' + userMap.get(spoc.L1_Spoc_Name__c));
                        }
                    }else{
                        if(cs.Department__c == spoc.Department__c && cs.RW_Project_Text__c == spoc.Project_Name__c){
                            System.debug('SPOC Det: ' + spoc);
                            cs.OwnerId = (userMap.get(spoc.L1_Spoc_Email__c) != null)? userMap.get(spoc.L1_Spoc_Email__c) : lstQueue[0].Id;
                            cs.Locobuzz_Owner_Assigned__c = true;
                            ownerAssigned = true; //Added by Vinay 10-04-2025
                            //cs.Escalation_Level__c = 'New';
                            System.debug('SPOC Email: ' + spoc.L1_Spoc_Email__c);
                            System.debug('SPOC: ' + userMap.get(spoc.L1_Spoc_Email__c));
                        }
                    }
                    if(ownerAssigned == false){
                        cs.OwnerId = System.label.General_Queue_Id;
                     }
                }
                System.debug('Locobuzz Owner: ' + cs.OwnerId);
            }
            //update locoBuzzCasese;
        }
    }*/
    
    public static Map<String, String> spocUsers(Map<String, Locobuzz_Project_Spocs__c> spocs){
        Set<String> spocEmails = new Set<String>();
        for(Locobuzz_Project_Spocs__c spoc : spocs.values()){
            if(spoc.L1_Spoc_Email__c != null && spoc.L1_Spoc_Email__c != '') spocEmails.add(spoc.L1_Spoc_Email__c);
            if(spoc.L2_Spoc_Email__c != null && spoc.L2_Spoc_Email__c != '') spocEmails.add(spoc.L2_Spoc_Email__c);
            if(spoc.L3_Spoc_Email__c != null && spoc.L3_Spoc_Email__c != '') spocEmails.add(spoc.L3_Spoc_Email__c);
            if(spoc.L4_Spoc_Email__c != null && spoc.L4_Spoc_Email__c != '') spocEmails.add(spoc.L4_Spoc_Email__c);
        }
        
        List<User> users = [SELECT Id, Email FROM User WHERE Email =: spocEmails];
        Map<String, String> userMap = new Map<String, String>();
        for(User usr : users){
            userMap.put(usr.Email, usr.Id);
        }
        return userMap;
    }

}