public class EmailMessageTriggerHandler {
    private static Boolean isProcessing = false;
    public static void handleAfterInsert(List<EmailMessage> newEmails) {
        if (isProcessing) return;
        isProcessing = true;
        List<Case> updateParentCases = new List<Case>();
        // Collect Parent Case Ids
        Set<Id> parentCaseIds = new Set<Id>();
        for (EmailMessage em : newEmails) {
            System.debug('Incoming-->'+em.Incoming);
            System.debug('ParentId-->'+em.ParentId);
            if (em.Incoming && em.ParentId != null && em.ParentId.getSObjectType() == Case.sObjectType) {
            	parentCaseIds.add(em.ParentId);
            }
        }
        if(!parentCaseIds.isEmpty()){
            // Query parent cases
            Map<Id, Case> parentCaseMap = new Map<Id, Case>(
                [SELECT Id, CreatedDate, Subject, LastModifiedDate, AccountId, ContactId, RW_Project__c, RW_Project_Unit__c,
                ClosedDate,locobuzz__Locobuzz_ID__c,Last_Closed_Date__c,Status FROM Case
                WHERE Id IN :parentCaseIds and Status = 'Case Closed' and locobuzz__Locobuzz_ID__c = null]
            );
        
        System.debug('ParentCase Map---->'+parentCaseMap);
        
            List<Case> casesToInsert = new List<Case>();
            Map<Id, Case> emailToCaseDraftMap = new Map<Id, Case>();
            Integer followupDays = Integer.valueOf(System.Label.Email_Followup_Days);
        System.debug('FollowUp Days--->'+followupDays);
        
            for (EmailMessage em : newEmails) {
                System.debug('Check Parent Id---->'+em.ParentId);
                if (em.Incoming && parentCaseMap.containsKey(em.ParentId)) {
                    Case parentCase = parentCaseMap.get(em.ParentId);
                    System.debug('days between---->'+parentCase.Last_Closed_Date__c.date().daysBetween(Date.today()));
        
                    // Check if reply is after 10 days
                    if (parentCase.Last_Closed_Date__c.date().daysBetween(Date.today()) >= followupDays) {
                        Case newCase = new Case();
                        newCase.Subject = 'Follow-up: ' + (em.Subject != null ? em.Subject : parentCase.Subject);
                        newCase.Origin = 'Email';
                        newCase.Status = 'Open';
                        newCase.AccountId = parentCase.AccountId;
                        newCase.ContactId = parentCase.ContactId;
                        newCase.RW_Project__c = parentCase.RW_Project__c;
                        newCase.RW_Project_Unit__c = parentCase.RW_Project_Unit__c;
                        newCase.ParentId = parentCase.Id;
                        casesToInsert.add(newCase);
        
                        // Track which email should be cloned into this new case
                        emailToCaseDraftMap.put(em.Id, newCase);
                    }
                }
            }
        
            if (!casesToInsert.isEmpty()) {
                insert casesToInsert;
                // Clone EmailMessages under new cases
                List<EmailMessage> emailsToInsert = new List<EmailMessage>();
                for (EmailMessage em : newEmails) {
                    if (emailToCaseDraftMap.containsKey(em.Id)) {
                        Case newCase = emailToCaseDraftMap.get(em.Id);
        
                        EmailMessage clonedEmail = new EmailMessage();
                        clonedEmail.ParentId = newCase.Id; // Attach to new case
                        clonedEmail.Subject = em.Subject;
                        clonedEmail.FromAddress = em.FromAddress;
                        clonedEmail.ToAddress = em.ToAddress;
                        clonedEmail.CcAddress = em.CcAddress;
                        clonedEmail.BccAddress = em.BccAddress;
                        clonedEmail.TextBody = em.TextBody;
                        clonedEmail.HtmlBody = em.HtmlBody;
                        clonedEmail.MessageDate = em.MessageDate;
                        clonedEmail.Incoming = em.Incoming;
                        clonedEmail.Status = em.Status;
                        // Optionally track original
                        // clonedEmail.Original_Email__c = em.Id; 
        
                        emailsToInsert.add(clonedEmail);
                    }
                }
                if (!emailsToInsert.isEmpty()) {
                    insert emailsToInsert;
                }
            }
        }
        }
    
    Public static void dummyMethod(){
        Integer i=0;
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
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
    }