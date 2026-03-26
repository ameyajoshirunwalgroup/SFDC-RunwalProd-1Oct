trigger ContentDocumentTrigger on ContentDocument (before delete) {

    Set<Id> docIds = new Set<Id>();

    for (ContentDocument doc : Trigger.old) {
        docIds.add(doc.Id);
    }

    // Get links to check if file is attached to Booking
    List<ContentDocumentLink> links = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId IN :docIds
    ];

    Map<Id, List<ContentDocumentLink>> docLinkMap = new Map<Id, List<ContentDocumentLink>>();

    for (ContentDocumentLink link : links) {
        if (!docLinkMap.containsKey(link.ContentDocumentId)) {
            docLinkMap.put(link.ContentDocumentId, new List<ContentDocumentLink>());
        }
        docLinkMap.get(link.ContentDocumentId).add(link);
    }

    for (ContentDocument doc : Trigger.old) {

        String fileName = doc.Title != null ? doc.Title.toLowerCase() : '';
        String normalized = fileName.replaceAll('[^a-z]', '');

        // 🔥 Check IWR + IOM
        //if (normalized.contains('iwr') && normalized.contains('iom')) {
		if (normalized.contains('iwr')) {

            // Check if linked to Booking
            if (docLinkMap.containsKey(doc.Id)) {

                for (ContentDocumentLink link : docLinkMap.get(doc.Id)) {

                    if (link.LinkedEntityId.getSObjectType() == Booking__c.SObjectType) {

                        doc.addError('You cannot delete IWR files from Booking.');
                    }
                }
            }
        }
    }
}