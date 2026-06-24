public class InterestWaiverEmailHelper {

    @InvocableMethod(label='Send Interest Waiver Approval Email'
                     description='Sends approval email with IOM file attached. Call from Flow when Interest_Waiver_Approval_Status__c changes.')
    public static void sendApprovalEmail(List<Id> bookingIds) {
        for (Id bkId : bookingIds) {
            try {
                sendEmail(bkId);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'InterestWaiverEmailHelper error for Booking ' + bkId + ': ' + e.getMessage());
            }
        }
    }

    private static void sendEmail(Id bookingId) {
        // 1. Get the VF email template
        List<EmailTemplate> templates = [
            SELECT Id FROM EmailTemplate
            WHERE Name = 'Interest Waiver Approval'
            LIMIT 1
        ];
        if (templates.isEmpty()) return;

        // 2. Determine recipient
        Id recipientId = getRecipientId(bookingId);
        if (recipientId == null) return;

        // 3. Get IOM file ContentVersion Id
        String cvId = getIomContentVersionId(bookingId);

        // 4. Build and send email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templates[0].Id);
        email.setTargetObjectId(recipientId);
        email.setWhatId(bookingId);
        email.setSaveAsActivity(false);

        if (cvId != null) {
            email.setEntityAttachments(new List<String>{ cvId });
        }

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    }

    private static Id getRecipientId(Id bookingId) {
        // Pending approval: send to the approver
        List<ProcessInstanceWorkitem> workItems = [
            SELECT ActorId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :bookingId
            LIMIT 1
        ];
        if (!workItems.isEmpty()) {
            return workItems[0].ActorId;
        }

        // Approved or Rejected: send to the person who submitted for approval
        List<ProcessInstance> instances = [
            SELECT SubmittedById
            FROM ProcessInstance
            WHERE TargetObjectId = :bookingId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        if (!instances.isEmpty()) {
            return instances[0].SubmittedById;
        }

        // Fallback: Booking owner
        List<Booking__c> bookings = [
            SELECT OwnerId FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];
        return bookings.isEmpty() ? null : bookings[0].OwnerId;
    }

    private static String getIomContentVersionId(Id bookingId) {
        List<ContentDocumentLink> fileLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :bookingId
        ];

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : fileLinks) {
            docIds.add(link.ContentDocumentId);
        }
        if (docIds.isEmpty()) return null;

        List<ContentVersion> iomFiles = [
            SELECT Id
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds
            AND Title LIKE '%IOM%'
            AND IsLatest = true
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        return iomFiles.isEmpty() ? null : iomFiles[0].Id;
    }
}