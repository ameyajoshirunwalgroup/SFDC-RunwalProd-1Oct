public class RWCaseTriggerHandler_New {

    // ─────────────────────────────────────────────────────────────
    // Entry point
    // ─────────────────────────────────────────────────────────────
    public void runTrigger() {
        List<Case>    newList = (List<Case>)    Trigger.new;
        Map<Id, Case> oldMap  = (Map<Id, Case>) Trigger.oldMap;

        if (Trigger.isBefore && Trigger.isInsert) { onBeforeInsert(newList, oldMap); }
        if (Trigger.isBefore && Trigger.isUpdate) { onBeforeUpdate(newList, oldMap); }
        if (Trigger.isAfter  && Trigger.isInsert) { onAfterInsert (newList, oldMap); }
        if (Trigger.isAfter  && Trigger.isUpdate) { onAfterUpdate (newList, oldMap); }
    }

    // ─────────────────────────────────────────────────────────────
    // BEFORE INSERT
    // ─────────────────────────────────────────────────────────────
    public void onBeforeInsert(List<Case> newList, Map<Id, Case> oldMap) {

        Id CUSTOMER_RT_ID  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id CP_PORTAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();

        // ── updateProjectWeb ─────────────────────────────────────
        for (Case cs : newList) {
            if (cs.Origin == 'Website' && cs.RecordTypeId == CUSTOMER_RT_ID) {
                if (cs.RW_Project_Text__c      != null) { cs.RW_Project__c      = cs.RW_Project_Text__c;      }
                if (cs.RW_Project_Unit_Text__c != null) { cs.RW_Project_Unit__c = cs.RW_Project_Unit_Text__c; }
            }
        }

        // ── updateProjectField ───────────────────────────────────
        Map<String, Project_Keywords__c> keywordSettings = Project_Keywords__c.getAll();
        Map<String, Id> projectNameToId = new Map<String, Id>();
        for (Project__c proj : [SELECT Id, Name FROM Project__c]) {
            projectNameToId.put(proj.Name, proj.Id);
        }
        Map<String, String> keywordToProjectName = new Map<String, String>();
        for (String settingKey : keywordSettings.keySet()) {
            for (String kw : keywordSettings.get(settingKey).RW_Keyword__c.split(';')) {
                keywordToProjectName.put(kw.toLowerCase(), settingKey);
            }
        }
        for (Case cs : newList) {
            if (cs.Origin != 'Email' || cs.Subject == null || cs.RecordTypeId != CUSTOMER_RT_ID) { continue; }
            String subjectLower = cs.Subject.toLowerCase();
            for (String kw : keywordToProjectName.keySet()) {
                if (subjectLower.contains(kw) && projectNameToId.containsKey(keywordToProjectName.get(kw))) {
                    cs.RW_Project__c = projectNameToId.get(keywordToProjectName.get(kw));
                }
            }
        }

        // ── updateManagerEmail ───────────────────────────────────
        Map<String, RM_Usernames__c> rmSettings = RM_Usernames__c.getAll();
        for (Case cs : newList) {
            if (cs.RW_RM_Name__c != null && rmSettings.containsKey(cs.RW_RM_Name__c) && cs.RecordTypeId == CUSTOMER_RT_ID) {
                RM_Usernames__c rm = rmSettings.get(cs.RW_RM_Name__c);
                cs.RW_Immediate_Manager_Email__c = rm.RW_Reporting_1_Email__c;
                cs.RW_Reporting_2_Email__c       = rm.RW_Reporting_2_Email__c;
                cs.RW_Reporting_3_Email__c       = rm.RW_Reporting_3_Email__c;
                cs.RW_Reporting_4_Email__c       = rm.RW_Reporting_4_Email__c;
            }
        }

        // ── updateEntitlementOnCase ──────────────────────────────
        Map<String, Entitlement> entitlementByName = new Map<String, Entitlement>();
        for (Entitlement e : [
            SELECT Id, Name FROM Entitlement
            WHERE  Name = :Label.Entitlement_Name
               OR  Name = :Label.Reopen_Entitlement_Name
               OR  Name = :Label.Resolved_Entitlement_Name
        ]) {
            entitlementByName.put(e.Name, e);
        }
        if (!entitlementByName.isEmpty()) {
            for (Case cs : newList) {
                if (String.isNotBlank(cs.locobuzz__Locobuzz_ID__c) || cs.Post_Possession_Customer__c) { continue; }
                if (cs.OwnerId == null || cs.RecordTypeId != CUSTOMER_RT_ID) { continue; }
                if (String.valueOf(cs.OwnerId).startsWith('005')) {
                    if (cs.Status != 'Resolved' && cs.RW_Case_Reopened_Date__c == null) {
                        cs.RW_Escalated_Time__c = System.now();
                        cs.EntitlementId        = entitlementByName.get(Label.Entitlement_Name)?.Id;
                    }
                } else {
                    cs.RW_Escalated_Time__c = null;
                    cs.EntitlementId        = null;
                }
            }
        }

        // ── caseownerUpdateForsingleOppo ─────────────────────────
        List<Id> singleOppoAccIds = new List<Id>();
        for (Case cs : newList) {
            if (cs.AccountId != null && cs.RecordTypeId == CUSTOMER_RT_ID) {
                singleOppoAccIds.add(cs.AccountId);
            }
        }
        if (!singleOppoAccIds.isEmpty()) {
            Map<Id, List<Opportunity>> accToOpps = new Map<Id, List<Opportunity>>();
            for (Account acc : [
                SELECT Id,
                       (SELECT Id,
                               RW_Project_Unit__r.Relationship_Manager__r.user__c,
                               RW_Project_Unit__r.Relationship_Manager__c,
                               RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c,
                               StageName
                        FROM   Opportunities
                        WHERE  StageName = 'Unit Booked')
                FROM   Account
                WHERE  Id IN :singleOppoAccIds
            ]) {
                if (!acc.Opportunities.isEmpty()) {
                    accToOpps.put(acc.Id, acc.Opportunities);
                }
            }
            for (Case cs : newList) {
                if (!accToOpps.containsKey(cs.AccountId)
                    || cs.RecordTypeId != CUSTOMER_RT_ID
                    || cs.Origin == 'Walk-in'
                    || cs.Post_Possession_Customer__c
                    || String.isNotBlank(cs.locobuzz__Locobuzz_ID__c)) { continue; }
                List<Opportunity> opps = accToOpps.get(cs.AccountId);
                if (opps.size() == 1
                    && opps[0].RW_Project_Unit__r.Relationship_Manager__c != null
                    && !cs.FM_Team_Assigned__c) {
                    cs.OwnerId = opps[0].RW_Project_Unit__r.Relationship_Manager__r.user__c;
                }
            }
        }

        // ── updatecasestatus ─────────────────────────────────────
        for (Case cs : newList) {
            if (cs.RecordTypeId == CP_PORTAL_RT_ID) {
                cs.Status = 'Open';
            }
        }

        // ── updateAccountId ──────────────────────────────────────
        Map<String, Case> emailToCase = new Map<String, Case>();
        for (Case cs : newList) {
            if (cs.Origin == 'Email') { emailToCase.put(cs.SuppliedEmail, cs); }
        }
        if (!emailToCase.isEmpty()) {
            List<Account> accounts = [
                SELECT Id, PersonEmail, PersonContactId, Stop_Case_Emails__c,
                       (SELECT Id, AccountId, StageName,
                               Booking__r.Booking_Date__c, CreatedDate,
                               Booking__r.RW_Key_handover_date__c
                        FROM   Opportunities
                        WHERE  StageName = 'Unit Booked'
                        ORDER BY Booking__r.Booking_Date__c DESC)
                FROM   Account
                WHERE  PersonEmail IN :emailToCase.keySet()
                  AND  IsPersonAccount = true
            ];

            String firstOppId;
            if (!accounts.isEmpty() && !accounts[0].Opportunities.isEmpty()) {
                firstOppId = accounts[0].Opportunities[0].Id;
            }

            Map<String, String>        accIdToContactId  = new Map<String, String>();
            Map<String, Boolean>       accIdToStopEmails = new Map<String, Boolean>();
            Map<String, List<Account>> emailToAccounts   = new Map<String, List<Account>>();

            for (Account acc : accounts) {
                accIdToContactId.put(acc.Id, acc.PersonContactId);
                accIdToStopEmails.put(acc.Id, acc.Stop_Case_Emails__c);
                List<Account> bucket = emailToAccounts.get(acc.PersonEmail);
                if (bucket == null) {
                    emailToAccounts.put(acc.PersonEmail, new List<Account>{ acc });
                } else {
                    bucket.add(acc);
                }
            }

            for (String email : emailToAccounts.keySet()) {
                List<Account> bucket = emailToAccounts.get(email);
                String resolvedAccId;
                if (bucket.size() > 1) {
                    Map<Datetime, String> bookingDateToAccId = new Map<Datetime, String>();
                    Map<Datetime, String> oppDateToAccId     = new Map<Datetime, String>();
                    for (Account acc : bucket) {
                        for (Opportunity opp : acc.Opportunities) {
                            if (opp.Booking__r.Booking_Date__c != null) {
                                bookingDateToAccId.put(opp.Booking__r.Booking_Date__c, opp.AccountId);
                            } else {
                                oppDateToAccId.put(opp.CreatedDate, opp.AccountId);
                            }
                        }
                    }
                    if (!bookingDateToAccId.isEmpty()) {
                        List<Datetime> dates = new List<Datetime>(bookingDateToAccId.keySet());
                        dates.sort();
                        resolvedAccId = bookingDateToAccId.get(dates[dates.size() - 1]);
                    } else if (!oppDateToAccId.isEmpty()) {
                        List<Datetime> dates = new List<Datetime>(oppDateToAccId.keySet());
                        dates.sort();
                        resolvedAccId = oppDateToAccId.get(dates[dates.size() - 1]);
                    }
                } else {
                    resolvedAccId = bucket[0].Id;
                }
                if (resolvedAccId != null) {
                    Case cs = emailToCase.get(email);
                    cs.AccountId      = resolvedAccId;
                    cs.ContactId      = accIdToContactId.get(resolvedAccId);
                    cs.Opportunity__c = firstOppId;
                    cs.Stop_Emails__c = accIdToStopEmails.get(resolvedAccId);
                }
            }
        }

        // ── updateEscalationTAT ──────────────────────────────────
        List<Case_Escalation_Matrix_SLA__c> slaMatrix = [
            SELECT Id, Case_Sub_Type__c, Case_Type__c,
                   Customer_Lifecycle_Touchpoint__c, SLA__c
            FROM   Case_Escalation_Matrix_SLA__c
            WHERE  Active__c = true
        ];
        if (!slaMatrix.isEmpty()) {
            for (Case cs : newList) {
                if (cs.Status == 'Reopened') { cs.Escalation_Level__c = 'New'; }
                if (String.isNotBlank(cs.locobuzz__Locobuzz_ID__c)) { continue; }
                // Insert path: set TAT when all 3 fields are populated
                if (cs.Customer_Lifecycle_Touchpoint__c != null
                    && cs.RW_Complaint_Type__c != null
                    && cs.RW_Complaint_SubType__c != null) {
                    for (Case_Escalation_Matrix_SLA__c mat : slaMatrix) {
                        if (cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c
                            && cs.RW_Complaint_Type__c    == mat.Case_Type__c
                            && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c) {
                            cs.Case_Escalation_TAT__c = mat.SLA__c;
                            break;
                        }
                    }
                }
            }
        }

        // ── updateRMNameasOwnerforWalkinCases ────────────────────
        for (Case cs : newList) {
            if (cs.Origin == 'Walk-in' && cs.RecordTypeId == CUSTOMER_RT_ID) {
                cs.RW_RM_Name__c = cs.RW_Owner_Name__c;
            }
        }

        // ── checkForCancelledCustomer ────────────────────────────
        Map<Id, Id> caseToAccId   = new Map<Id, Id>();
        Set<Id>     cancelAccIds  = new Set<Id>();
        Set<Id>     cancelOppIds  = new Set<Id>();
        for (Case cs : newList) {
            if (String.isNotBlank(cs.AccountId)) {
                caseToAccId.put(cs.Id, cs.AccountId);
                cancelAccIds.add(cs.AccountId);
                if (String.isNotBlank(cs.Opportunity__c)) { cancelOppIds.add(cs.Opportunity__c); }
            }
        }
        if (!caseToAccId.isEmpty()) {
            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id, (SELECT Id, StageName FROM Opportunities)
                FROM   Account
                WHERE  Id IN :cancelAccIds
            ]);
            for (Case cs : newList) {
                if (cs.AccountId == null) { continue; }
                Account acc = accMap.get(cs.AccountId);
                if (acc == null || acc.Opportunities.isEmpty()) { continue; }
                Integer total = acc.Opportunities.size(), cancelled = 0;
                for (Opportunity opp : acc.Opportunities) {
                    if (opp.StageName == 'Cancelled') { cancelled++; }
                }
                if (total == cancelled) { cs.Stop_Emails__c = true; }
            }
        }
        if (!cancelOppIds.isEmpty()) {
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                SELECT Id, StageName FROM Opportunity WHERE Id IN :cancelOppIds
            ]);
            for (Case cs : newList) {
                if (cs.Opportunity__c != null && oppMap.get(cs.Opportunity__c)?.StageName == 'Cancelled') {
                    cs.Stop_Emails__c = true;
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // BEFORE UPDATE
    // ─────────────────────────────────────────────────────────────
    public void onBeforeUpdate(List<Case> newList, Map<Id, Case> oldMap) {

        Id CUSTOMER_RT_ID  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id CP_PORTAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();

        // ── checkForCancelledCustomer ────────────────────────────
        Map<Id, Id> caseToAccId   = new Map<Id, Id>();
        Set<Id>     cancelAccIds  = new Set<Id>();
        Set<Id>     cancelOppIds  = new Set<Id>();
        for (Case cs : newList) {
            if (String.isNotBlank(cs.AccountId)) {
                caseToAccId.put(cs.Id, cs.AccountId);
                cancelAccIds.add(cs.AccountId);
                if (String.isNotBlank(cs.Opportunity__c)) { cancelOppIds.add(cs.Opportunity__c); }
            }
        }
        if (!caseToAccId.isEmpty()) {
            Map<Id, Account> accMap = new Map<Id, Account>([
                SELECT Id, (SELECT Id, StageName FROM Opportunities)
                FROM   Account
                WHERE  Id IN :cancelAccIds
            ]);
            for (Case cs : newList) {
                if (cs.AccountId == null) { continue; }
                Account acc = accMap.get(cs.AccountId);
                if (acc == null || acc.Opportunities.isEmpty()) { continue; }
                Integer total = acc.Opportunities.size(), cancelled = 0;
                for (Opportunity opp : acc.Opportunities) {
                    if (opp.StageName == 'Cancelled') { cancelled++; }
                }
                if (total == cancelled) { cs.Stop_Emails__c = true; }
            }
        }
        if (!cancelOppIds.isEmpty()) {
            Map<Id, Opportunity> cancelOppMap = new Map<Id, Opportunity>([
                SELECT Id, StageName FROM Opportunity WHERE Id IN :cancelOppIds
            ]);
            for (Case cs : newList) {
                if (cs.Opportunity__c != null && cancelOppMap.get(cs.Opportunity__c)?.StageName == 'Cancelled') {
                    cs.Stop_Emails__c = true;
                }
            }
        }

        // ── updateOwnerAsRmOrQueue ───────────────────────────────
        Set<String> rmNames          = new Set<String>();
        List<Case>  casesForRmLookup = new List<Case>();
        for (Case cs : newList) {
            Boolean rmChanged       = (oldMap.get(cs.Id).RW_RM_Name__c != cs.RW_RM_Name__c);
            Boolean ownerFlagChange = (cs.RW_Is_Owner_changed__c
                                       && !oldMap.get(cs.Id).RW_Is_Owner_changed__c
                                       && (cs.Origin == 'Email' || cs.Origin == 'Website' || cs.Origin == 'Portal'));
            if (cs.locobuzz__Locobuzz_ID__c == null
                && cs.RW_RM_Name__c != null
                && cs.RecordTypeId == CUSTOMER_RT_ID
                && (rmChanged || ownerFlagChange)
                && !cs.FM_Team_Assigned__c) {
                rmNames.add(cs.RW_RM_Name__c);
                casesForRmLookup.add(cs);
            }
        }
        Map<String, User> nameToUser    = new Map<String, User>();
        Set<String>       assignedCaseIds = new Set<String>();
        if (!rmNames.isEmpty()) {
            List<String> profiles = System.label.Case_Owner_Assignment_Profiles.split(',');
            for (User u : [
                SELECT Id, Name FROM User
                WHERE  Name IN :rmNames
                  AND  Profile.Name IN :profiles
                  AND  IsActive = true
            ]) {
                nameToUser.put(u.Name, u);
            }
            for (Case cs : casesForRmLookup) {
                if (nameToUser.containsKey(cs.RW_RM_Name__c) && !cs.Post_Possession_Customer__c) {
                    cs.OwnerId = nameToUser.get(cs.RW_RM_Name__c).Id;
                    assignedCaseIds.add(cs.Id);
                }
            }
        }
        Set<String> queueProjectIds = new Set<String>();
        List<Case>  queueCases      = new List<Case>();
        for (Case cs : newList) {
            if (cs.locobuzz__Locobuzz_ID__c == null
                && cs.RW_Is_Owner_changed__c
                && !oldMap.get(cs.Id).RW_Is_Owner_changed__c
                && (cs.Origin == 'Email' || cs.Origin == 'Website')
                && cs.RW_RM_Name__c == null
                && cs.RecordTypeId == CUSTOMER_RT_ID
                && !cs.FM_Team_Assigned__c
                && !assignedCaseIds.contains(cs.Id)
                && !cs.Post_Possession_Customer__c) {
                queueProjectIds.add(cs.RW_Project__c);
                queueCases.add(cs);
            }
        }
        if (!queueProjectIds.isEmpty()) {
            Map<String, String> projIdToName = new Map<String, String>();
            for (Project__c p : [SELECT Id, Name FROM Project__c WHERE Id IN :queueProjectIds]) {
                projIdToName.put(p.Id, p.Name);
            }
            Map<String, String> queueNameToId = new Map<String, String>();
            for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Queue']) {
                queueNameToId.put(g.Name, g.Id);
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail        = false;
            dmo.EmailHeader.triggerAutoResponseEmail = false;
            dmo.assignmentRuleHeader.useDefaultRule  = false;
            for (Case cs : queueCases) {
                String projName    = projIdToName.get(cs.RW_Project__c);
                String targetQueue = (projName != null) ? projName + '-Queue' : null;
                cs.OwnerId = (targetQueue != null && queueNameToId.containsKey(targetQueue))
                    ? queueNameToId.get(targetQueue)
                    : queueNameToId.get(Label.Generic_Queue_Name);
                cs.setOptions(dmo);
            }
        }

        // ── updateManagerEmail ───────────────────────────────────
        Map<String, RM_Usernames__c> rmSettingsUpd = RM_Usernames__c.getAll();
        for (Case cs : newList) {
            if (cs.RW_RM_Name__c != null && rmSettingsUpd.containsKey(cs.RW_RM_Name__c) && cs.RecordTypeId == CUSTOMER_RT_ID) {
                RM_Usernames__c rm = rmSettingsUpd.get(cs.RW_RM_Name__c);
                cs.RW_Immediate_Manager_Email__c = rm.RW_Reporting_1_Email__c;
                cs.RW_Reporting_2_Email__c       = rm.RW_Reporting_2_Email__c;
                cs.RW_Reporting_3_Email__c       = rm.RW_Reporting_3_Email__c;
                cs.RW_Reporting_4_Email__c       = rm.RW_Reporting_4_Email__c;
            }
        }

        // ── updateEntitlementOnCase ──────────────────────────────
        Map<String, Entitlement> entitlementByName = new Map<String, Entitlement>();
        for (Entitlement e : [
            SELECT Id, Name FROM Entitlement
            WHERE  Name = :Label.Entitlement_Name
               OR  Name = :Label.Reopen_Entitlement_Name
               OR  Name = :Label.Resolved_Entitlement_Name
        ]) {
            entitlementByName.put(e.Name, e);
        }
        if (!entitlementByName.isEmpty()) {
            for (Case cs : newList) {
                if (String.isNotBlank(cs.locobuzz__Locobuzz_ID__c) || cs.Post_Possession_Customer__c) { continue; }
                if (cs.OwnerId == null || cs.RecordTypeId != CUSTOMER_RT_ID) { continue; }
                Boolean ownerChanged = (oldMap.get(cs.Id).OwnerId != cs.OwnerId);
                if (String.valueOf(cs.OwnerId).startsWith('005')) {
                    if (cs.Status != 'Resolved' && cs.RW_Case_Reopened_Date__c == null) {
                        if (ownerChanged) {
                            cs.RW_Escalated_Time__c = System.now();
                            cs.EntitlementId        = entitlementByName.get(Label.Entitlement_Name)?.Id;
                        }
                    } else if (cs.Status == 'Resolved' && oldMap.get(cs.Id).Status != cs.Status) {
                        cs.RW_Escalated_Time__c = System.now();
                        cs.EntitlementId        = entitlementByName.get(Label.Resolved_Entitlement_Name)?.Id;
                    } else if (cs.Status == 'Reopened' && oldMap.get(cs.Id).Status != cs.Status) {
                        cs.EntitlementId = entitlementByName.get(Label.Reopen_Entitlement_Name)?.Id;
                    }
                } else {
                    cs.RW_Escalated_Time__c = null;
                    cs.EntitlementId        = null;
                }
            }
        }

        // ── showErrorforcontactedCase ────────────────────────────
        Set<Id> contactedCaseIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.Status == 'Contacted'
                && oldMap.get(cs.Id).Status != 'Contacted'
                && cs.RecordTypeId == CUSTOMER_RT_ID) {
                contactedCaseIds.add(cs.Id);
            }
        }
        if (!contactedCaseIds.isEmpty()) {
            Map<Id, Task> caseIdToTask = new Map<Id, Task>();
            for (Task t : [
                SELECT Id, Status, WhatId FROM Task
                WHERE  WhatId IN :contactedCaseIds
                  AND  Subject = 'Call Customer'
            ]) {
                caseIdToTask.put(t.WhatId, t);
            }
            for (Case cs : newList) {
                if (!contactedCaseIds.contains(cs.Id)) { continue; }
                Task t = caseIdToTask.get(cs.Id);
                if (t == null || t.Status != 'Completed') {
                    cs.addError('For Contacted, the call customer task must be completed.');
                }
            }
        }

        // ── updateOwnersfieldonCase ──────────────────────────────
        for (Case cs : newList) {
            if (cs.RecordTypeId != CP_PORTAL_RT_ID || cs.RW_Owner_Name__c == null) { continue; }
            Boolean ownerChanged = (cs.OwnerId != oldMap.get(cs.Id).OwnerId);
            if (ownerChanged) {
                cs.Owners__c = (cs.Owners__c != null && cs.RW_Is_Escalated__c)
                    ? cs.Owners__c + ', ' + cs.RW_Owner_Name__c
                    : cs.RW_Owner_Name__c;
            } else if (cs.Status == 'Case Closed') {
                cs.Owners__c = (cs.Owners__c != null)
                    ? cs.Owners__c + ', ' + cs.RW_Owner_Name__c
                    : cs.RW_Owner_Name__c;
            }
        }

        // ── updateEscalationTAT ──────────────────────────────────
        List<Case_Escalation_Matrix_SLA__c> slaMatrixUpd = [
            SELECT Id, Case_Sub_Type__c, Case_Type__c,
                   Customer_Lifecycle_Touchpoint__c, SLA__c
            FROM   Case_Escalation_Matrix_SLA__c
            WHERE  Active__c = true
        ];
        if (!slaMatrixUpd.isEmpty()) {
            for (Case cs : newList) {
                if (cs.Status == 'Reopened') { cs.Escalation_Level__c = 'New'; }
                if (String.isNotBlank(cs.locobuzz__Locobuzz_ID__c)) { continue; }
                // Validation: require fields when closing a complaint
                if (cs.RW_Case_Type__c == 'Complaint'
                    && cs.Status == 'Case Closed'
                    && oldMap.get(cs.Id).Status != 'Case Closed'
                    && (cs.Customer_Lifecycle_Touchpoint__c == null
                        || cs.RW_Complaint_Type__c == null
                        || cs.RW_Complaint_SubType__c == null)
                    && cs.CreatedDate.date() >= Date.newInstance(2025, 3, 29)) {
                    cs.addError('Please fill Customer Lifecycle Touchpoint, Complaint Type & Complaint Subtype');
                }
                // Update TAT when type fields change
                if (cs.Customer_Lifecycle_Touchpoint__c != null
                    && cs.RW_Complaint_Type__c != null
                    && cs.RW_Complaint_SubType__c != null
                    && oldMap.get(cs.Id) != null
                    && cs.RW_Complaint_Type__c    != oldMap.get(cs.Id).RW_Complaint_Type__c
                    && cs.RW_Complaint_SubType__c != oldMap.get(cs.Id).RW_Complaint_SubType__c) {
                    for (Case_Escalation_Matrix_SLA__c mat : slaMatrixUpd) {
                        if (cs.Customer_Lifecycle_Touchpoint__c == mat.Customer_Lifecycle_Touchpoint__c
                            && cs.RW_Complaint_Type__c    == mat.Case_Type__c
                            && cs.RW_Complaint_SubType__c == mat.Case_Sub_Type__c) {
                            cs.Case_Escalation_TAT__c = mat.SLA__c;
                            break;
                        }
                    }
                }
            }
        }

        // ── updateUnitWhenProjectChanged ─────────────────────────
        Set<String> projChangedAccIds = new Set<String>();
        List<Case>  projChangedCases  = new List<Case>();
        for (Case cs : newList) {
            if (String.isNotBlank(cs.AccountId) && cs.RW_Project__c != oldMap.get(cs.Id).RW_Project__c) {
                projChangedAccIds.add(cs.AccountId);
                projChangedCases.add(cs);
            }
        }
        if (!projChangedAccIds.isEmpty()) {
            Map<String, List<Opportunity>> accToOppsForProj = new Map<String, List<Opportunity>>();
            for (Opportunity opp : [
                SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c
                FROM   Opportunity
                WHERE  AccountId IN :projChangedAccIds
                  AND  StageName = 'Unit Booked'
                  AND  RW_Project_Unit__c != null
                ORDER BY Booking__r.Booking_Date__c DESC
            ]) {
                List<Opportunity> bucket = accToOppsForProj.get(opp.AccountId);
                if (bucket == null) {
                    accToOppsForProj.put(opp.AccountId, new List<Opportunity>{ opp });
                } else {
                    bucket.add(opp);
                }
            }
            for (Case cs : projChangedCases) {
                List<Opportunity> opps = accToOppsForProj.get(cs.AccountId);
                if (opps == null) { continue; }
                for (Opportunity opp : opps) {
                    if (cs.RW_Project__c == opp.RW_Project__c) {
                        cs.RW_Project_Unit__c = opp.RW_Project_Unit__c;
                        cs.Opportunity__c     = opp.Id;
                        break;
                    }
                }
            }
        }

        // ── ownerAssignment (FM team post-possession) ────────────
        Set<Id> ownerAssignOppIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.Opportunity__c != null) { ownerAssignOppIds.add(cs.Opportunity__c); }
        }
        if (!ownerAssignOppIds.isEmpty()) {
            Map<Id, Opportunity> ownerOppMap = new Map<Id, Opportunity>([
                SELECT Id, Booking__c, Booking__r.RW_Key_handover_date__c
                FROM   Opportunity
                WHERE  Id IN :ownerAssignOppIds
            ]);
            for (Case cs : newList) {
                if (cs.Opportunity__c == null) { continue; }
                Opportunity opp = ownerOppMap.get(cs.Opportunity__c);
                if (opp?.Booking__c != null && opp.Booking__r.RW_Key_handover_date__c != null) {
                    if (cs.CreatedDate > (opp.Booking__r.RW_Key_handover_date__c + 60)) {
                        cs.OwnerId             = System.label.Default_Facility_Management_User;
                        cs.FM_Team_Assigned__c = true;
                    }
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────
    // AFTER INSERT
    // ─────────────────────────────────────────────────────────────
    public void onAfterInsert(List<Case> newList, Map<Id, Case> oldMap) {

        Id CUSTOMER_RT_ID  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id CP_PORTAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();

        // ── updateProjectUnit ────────────────────────────────────
        Set<String>  puAccIds  = new Set<String>();
        List<String> puCaseIds = new List<String>();
        for (Case c : newList) {
            if (String.isNotBlank(c.AccountId)) {
                puAccIds.add(c.AccountId);
                puCaseIds.add(c.Id);
            }
        }
        if (!puAccIds.isEmpty()) {
            Map<String, List<Opportunity>> puAccToOpps = new Map<String, List<Opportunity>>();
            for (Opportunity opp : [
                SELECT Id, AccountId, RW_Project_Unit__c, RW_Project__c, RW_RM_Name__c,
                       Booking__r.RW_Key_handover_date__c,
                       RW_Project_Unit__r.Relationship_Manager__r.user__c
                FROM   Opportunity
                WHERE  AccountId IN :puAccIds
                  AND  StageName = 'Unit Booked'
                  AND  RW_Project_Unit__c != null
                ORDER BY Booking__r.Booking_Date__c DESC
            ]) {
                List<Opportunity> bucket = puAccToOpps.get(opp.AccountId);
                if (bucket == null) {
                    puAccToOpps.put(opp.AccountId, new List<Opportunity>{ opp });
                } else {
                    bucket.add(opp);
                }
            }
            List<Case> puCasesToUpdate = new List<Case>();
            for (Case c : [
                SELECT Id, AccountId, RW_Project__c, locobuzz__Locobuzz_ID__c,
                       Post_Possession_Customer__c, RW_RM_Name__c, FM_Team_Assigned__c
                FROM   Case
                WHERE  Id IN :puCaseIds
            ]) {
                List<Opportunity> opps = puAccToOpps.get(c.AccountId);
                if (opps == null || opps.isEmpty()) { continue; }
                Opportunity firstOpp = opps[0];
                c.RW_Project_Unit__c = firstOpp.RW_Project_Unit__c;
                c.RW_Project__c      = firstOpp.RW_Project__c;
                c.Opportunity__c     = firstOpp.Id;
                if (String.isBlank(c.locobuzz__Locobuzz_ID__c)
                    && !c.Post_Possession_Customer__c
                    && c.RW_RM_Name__c == null) {
                    c.RW_RM_Name__c = firstOpp.RW_RM_Name__c;
                }
                if (firstOpp.Booking__r.RW_Key_handover_date__c == null && c.FM_Team_Assigned__c) {
                    c.Post_Possession_Customer__c = false;
                    c.OwnerId                     = firstOpp.RW_Project_Unit__r.Relationship_Manager__r.user__c;
                    c.FM_Team_Assigned__c         = false;
                }
                puCasesToUpdate.add(c);
            }
            if (!puCasesToUpdate.isEmpty()) { update puCasesToUpdate; }
        }

        // ── CreateTask ───────────────────────────────────────────
        List<RecordType> taskRecTypes = [
            SELECT Id FROM RecordType
            WHERE  Name = :Label.Case_task_record_type_Name
              AND  SobjectType = 'Task'
        ];
        Id taskRtId = taskRecTypes.isEmpty() ? null : taskRecTypes[0].Id;

        List<Task> tasksToInsert   = new List<Task>();
        List<Case> casesToFlagDone = new List<Case>();
        for (Case cs : newList) {
            if (cs.RW_Is_Task_Created__c
                || cs.RecordTypeId != CUSTOMER_RT_ID
                || String.isNotBlank(cs.locobuzz__Locobuzz_ID__c)
                || cs.Stop_Emails__c
                || cs.OwnerId == null
                || !String.valueOf(cs.OwnerId).startsWith('005')
                || cs.RW_Project__c == null) { continue; }
            Task t         = new Task();
            t.RecordTypeId = taskRtId;
            t.Subject      = 'Call Customer';
            t.Status       = 'Not Started';
            t.OwnerId      = cs.OwnerId;
            t.Project__c   = cs.RW_Project__c;
            t.WhatId       = cs.Id;
            t.ActivityDate = System.today().addDays(Integer.valueOf(System.label.Task_DueDate));
            t.Priority     = 'Normal';
            t.RW_RM_Name__c = cs.RW_RM_Name__c;
            tasksToInsert.add(t);
            casesToFlagDone.add(new Case(Id = cs.Id, RW_Is_Task_Created__c = true));
        }
        if (!tasksToInsert.isEmpty())   { insert tasksToInsert; }
        if (!casesToFlagDone.isEmpty()) { update casesToFlagDone; }

        // ── NotificationToRMOnCaseCrea ───────────────────────────
        Set<Id> notifAccIds = new Set<Id>();
        for (Case cs : newList) {
            if (cs.AccountId != null && cs.RecordTypeId == CUSTOMER_RT_ID) { notifAccIds.add(cs.AccountId); }
        }
        if (!notifAccIds.isEmpty()) {
            Map<Id, List<Opportunity>> notifAccToOpps = new Map<Id, List<Opportunity>>();
            for (Account acc : [
                SELECT Id, Stop_Case_Emails__c,
                       (SELECT Id,
                               RW_Project_Unit__r.Relationship_Manager__r.user__c,
                               RW_Project_Unit__r.Relationship_Manager__c,
                               RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c,
                               StageName, Account.Stop_Case_Emails__c
                        FROM   Opportunities
                        WHERE  StageName = 'Unit Booked')
                FROM   Account
                WHERE  Id IN :notifAccIds
            ]) {
                if (!acc.Opportunities.isEmpty()) { notifAccToOpps.put(acc.Id, acc.Opportunities); }
            }

            EmailTemplate singleRmTpl = [SELECT Id FROM EmailTemplate WHERE Name = 'Notification To RM'  LIMIT 1];
            EmailTemplate multiRmTpl  = [SELECT Id FROM EmailTemplate WHERE Name = 'Notification To RMs' LIMIT 1];
            String orgEmailId = Utility.getOrgWideEmailAddress();
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Case cs : newList) {
                if (cs.Post_Possession_Customer__c || cs.RecordTypeId != CUSTOMER_RT_ID) { continue; }
                List<Opportunity> opps = notifAccToOpps.get(cs.AccountId);
                if (opps == null || cs.ContactId == null) { continue; }
                if (opps.size() == 1) {
                    Opportunity opp = opps[0];
                    if (opp.RW_Project_Unit__r.Relationship_Manager__c != null
                        && opp.Account.Stop_Case_Emails__c == false
                        && !cs.Stop_Emails__c) {
                        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                        msg.setTargetObjectId(cs.ContactId);
                        msg.setTreatTargetObjectAsRecipient(false);
                        msg.setWhatId(cs.Id);
                        msg.setOrgWideEmailAddressId(orgEmailId);
                        msg.setTemplateId(singleRmTpl.Id);
                        msg.setUseSignature(false);
                        msg.setBccSender(false);
                        msg.setSaveAsActivity(false);
                        msg.toAddresses = new List<String>{ opp.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c };
                        emails.add(msg);
                    }
                } else {
                    for (Opportunity opp : opps) {
                        if (opp.RW_Project_Unit__r.Relationship_Manager__c != null
                            && opp.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c != null
                            && opp.Account.Stop_Case_Emails__c == false
                            && !cs.Stop_Emails__c) {
                            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                            msg.setTargetObjectId(cs.ContactId);
                            msg.setTreatTargetObjectAsRecipient(false);
                            msg.setWhatId(cs.Id);
                            msg.setOrgWideEmailAddressId(orgEmailId);
                            msg.setTemplateId(multiRmTpl.Id);
                            msg.setUseSignature(false);
                            msg.setBccSender(false);
                            msg.setSaveAsActivity(false);
                            msg.toAddresses = new List<String>{ opp.RW_Project_Unit__r.Relationship_Manager__r.RM_Email__c };
                            emails.add(msg);
                        }
                    }
                }
            }
            if (!emails.isEmpty()) { Messaging.sendEmail(emails); }
        }

        // ── CPPortalMethod ───────────────────────────────────────
        List<User> portalUser = [SELECT Id, ContactId FROM User WHERE Id = '0059I0000078nh3QAA'];
        List<Contact> portalContacts;
        if (!portalUser.isEmpty()) {
            portalContacts = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Id = :portalUser[0].ContactId];
        }

        Set<String>  cpOppIds  = new Set<String>();
        Set<String>  cpProjIds = new Set<String>();
        for (Case cs : newList) {
            if (cs.Opportunity__c != null) { cpOppIds.add(cs.Opportunity__c); }
        }

        Map<Id, String>     cpOppToProjId = new Map<Id, String>();
        Map<Id, Project__c> cpProjMap     = new Map<Id, Project__c>();

        if (!cpOppIds.isEmpty()) {
            for (Opportunity opp : [
                SELECT Id, RW_Project__c, Sourcing_Manager_User__c, Sourcing_Manager_User__r.Name
                FROM   Opportunity
                WHERE  Id IN :cpOppIds
            ]) {
                cpProjIds.add(opp.RW_Project__c);
                cpOppToProjId.put(opp.Id, opp.RW_Project__c);
            }
            if (!cpProjIds.isEmpty()) {
                cpProjMap = new Map<Id, Project__c>([
                    SELECT Id, Name, MIS_User__c, MIS_User__r.Email, MIS_User__r.Name
                    FROM   Project__c
                    WHERE  Id IN :cpProjIds
                ]);
            }
        }

        List<String> cpEscLevels = new List<String>{
            'CP Case L1 Escalation', 'CP Case L2 Escalation', 'CP Case L3 Escalation',
            'CP Case L4 Escalation', 'CP Case L5 Escalation', 'CP Case L6 Escalation'
        };
        Map<Id, Map<String, Team_Members__c>> cpProjToApprovers =
            TeamMemberService.getProjectTeamMembers(cpProjIds, 'CP Case Escalation Team', cpEscLevels);

        List<Case> cpCasesToUpdate = new List<Case>();
        for (Case cs : newList) {
            if (cs.Origin != 'Channel Partner Portal' || cs.RecordTypeId != CP_PORTAL_RT_ID) { continue; }
            Case upd = new Case(Id = cs.Id);
            if (portalContacts != null && !portalContacts.isEmpty()) {
                upd.ContactId                  = portalContacts[0].Id;
                upd.Account_Channel_Partner__c = portalContacts[0].AccountId;
            }
            if (cs.Opportunity__c != null) {
                String projId = cpOppToProjId.get(cs.Opportunity__c);
                if (projId != null && cpProjMap.containsKey(projId)) {
                    Project__c proj = cpProjMap.get(projId);
                    upd.RW_Project__c      = proj.Id;
                    upd.RW_Project_Text__c = proj.Name;
                    if (proj.MIS_User__c != null) { upd.OwnerId = proj.MIS_User__c; }
                    Map<String, Team_Members__c> approverMap = cpProjToApprovers.get(projId);
                    if (approverMap != null) {
                        upd.RW_Immediate_Manager_Email__c = approverMap.get('CP Case L1 Escalation')?.User__r.Email;
                        upd.RW_Reporting_2_Email__c       = approverMap.get('CP Case L2 Escalation')?.User__r.Email;
                        upd.RW_Reporting_3_Email__c       = approverMap.get('CP Case L3 Escalation')?.User__r.Email;
                        upd.RW_Reporting_4_Email__c       = approverMap.get('CP Case L4 Escalation')?.User__r.Email;
                        upd.RW_Reporting_5_Email__c       = approverMap.get('CP Case L5 Escalation')?.User__r.Email;
                        upd.RW_Reporting_6_Email__c       = approverMap.get('CP Case L6 Escalation')?.User__r.Email;
                    }
                }
            }
            cpCasesToUpdate.add(upd);
        }
        if (!cpCasesToUpdate.isEmpty()) { update cpCasesToUpdate; }
    }

    // ─────────────────────────────────────────────────────────────
    // AFTER UPDATE
    // ─────────────────────────────────────────────────────────────
    public void onAfterUpdate(List<Case> newList, Map<Id, Case> oldMap) {

        Id CUSTOMER_RT_ID  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id CP_PORTAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();

        // ── updateTaskOwner ──────────────────────────────────────
        Map<Id, Case> ownerChangedCases = new Map<Id, Case>();
        for (Case cs : newList) {
            if (cs.OwnerId != null
                && String.valueOf(cs.OwnerId).startsWith('005')
                && cs.RecordTypeId == CUSTOMER_RT_ID
                && oldMap.get(cs.Id).OwnerId != cs.OwnerId) {
                ownerChangedCases.put(cs.Id, cs);
            }
        }
        if (!ownerChangedCases.isEmpty()) {
            List<Task> tasksToUpdate = [
                SELECT Id, OwnerId, WhatId FROM Task WHERE WhatId IN :ownerChangedCases.keySet()
            ];
            for (Task t : tasksToUpdate) {
                t.OwnerId = ownerChangedCases.get(t.WhatId).OwnerId;
            }
            if (!tasksToUpdate.isEmpty()) { update tasksToUpdate; }
        }

        // ── CPPortalEmailToCaseMethod (once per trigger run) ─────
        if (checkRecursion.isFirstRun()) {
            Boolean hasOpenCase = false;
            for (Case cs : newList) {
                if (cs.Status != 'Case Closed') { hasOpenCase = true; break; }
            }
            if (hasOpenCase) {
                Set<String>  cpEmails     = new Set<String>();
                Set<String>  cpProjectIds = new Set<String>();
                for (Case cs : newList) {
                    cpEmails.add(cs.SuppliedEmail);
                    if (cs.RW_Project__c != null) { cpProjectIds.add(cs.RW_Project__c); }
                }

                Map<String, Contact> emailToContact = new Map<String, Contact>();
                for (Contact c : [
                    SELECT Id, Email, AccountId FROM Contact
                    WHERE  Email IN :cpEmails
                      AND  Channel_Partner_Portal_Activated__c = true
                ]) {
                    emailToContact.put(c.Email, c);
                }

                Map<Id, Project__c> cpUpdProjMap = new Map<Id, Project__c>();
                if (!cpProjectIds.isEmpty()) {
                    cpUpdProjMap = new Map<Id, Project__c>([
                        SELECT Id, Name, MIS_User__c, MIS_User__r.Email, MIS_User__r.Name
                        FROM   Project__c
                        WHERE  Id IN :cpProjectIds
                    ]);
                }

                List<String> cpEscLevels = new List<String>{
                    'CP Case L1 Escalation', 'CP Case L2 Escalation', 'CP Case L3 Escalation',
                    'CP Case L4 Escalation', 'CP Case L5 Escalation', 'CP Case L6 Escalation'
                };
                Map<Id, Map<String, Team_Members__c>> cpUpdApprovers =
                    TeamMemberService.getProjectTeamMembers(cpProjectIds, 'CP Case Escalation Team', cpEscLevels);

                List<Case> cpUpdCases = new List<Case>();
                for (Case cs : newList) {
                    if ((cs.Origin != 'Email - Channel Partner' && cs.Origin != 'Channel Partner Portal')
                        || cs.RecordTypeId != CP_PORTAL_RT_ID
                        || cs.Case_Category__c == null
                        || cs.Case_Sub_Category__c == null
                        || cs.RW_Project__c == null) { continue; }

                    Case upd = new Case(Id = cs.Id);
                    Contact con = emailToContact.get(cs.SuppliedEmail);
                    if (con != null) {
                        upd.ContactId                  = con.Id;
                        upd.Account_Channel_Partner__c = con.AccountId;
                    }
                    if (cpUpdProjMap.containsKey(cs.RW_Project__c)) {
                        upd.RW_Project_Text__c = cpUpdProjMap.get(cs.RW_Project__c).Name;
                        if (cpUpdProjMap.get(cs.RW_Project__c).MIS_User__c != null) {
                            upd.OwnerId = cpUpdProjMap.get(cs.RW_Project__c).MIS_User__c;
                        }
                    }
                    Map<String, Team_Members__c> approverMap = cpUpdApprovers.get(cs.RW_Project__c);
                    if (approverMap != null) {
                        upd.RW_Immediate_Manager_Email__c = approverMap.get('CP Case L1 Escalation')?.User__r.Email;
                        upd.RW_Reporting_2_Email__c       = approverMap.get('CP Case L2 Escalation')?.User__r.Email;
                        upd.RW_Reporting_3_Email__c       = approverMap.get('CP Case L3 Escalation')?.User__r.Email;
                        upd.RW_Reporting_4_Email__c       = approverMap.get('CP Case L4 Escalation')?.User__r.Email;
                        upd.RW_Reporting_5_Email__c       = approverMap.get('CP Case L5 Escalation')?.User__r.Email;
                        upd.RW_Reporting_6_Email__c       = approverMap.get('CP Case L6 Escalation')?.User__r.Email;
                    }
                    cpUpdCases.add(upd);
                }
                if (!cpUpdCases.isEmpty()) { update cpUpdCases; }
            }
        }
    }
}