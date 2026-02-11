trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {

    Map<Id, Id> docToBookingMap = new Map<Id, Id>();

    // 1️⃣ Identify Booking records dynamically
    for (ContentDocumentLink cdl : Trigger.new) {
        if (cdl.LinkedEntityId != null &&
            cdl.LinkedEntityId.getSObjectType() == Booking__c.SObjectType
        ) {
            docToBookingMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }
    }

    if (docToBookingMap.isEmpty()) return;

    Set<Id> bookingIds = new Set<Id>(docToBookingMap.values());

    // 2️⃣ Query Booking data
    Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>([
        SELECT Id,
               Total_Waiver_Amount_to_be_Approved__c,
               RW_Total_Interest_Amount_Waived__c,
               Interest_Waiver_Approved_but_not_Waived__c
        FROM Booking__c
        WHERE Id IN :bookingIds
    ]);

    // 3️⃣ Calculate requested amount
    Map<Id, String> bookingAmountMap = new Map<Id, String>();

    for (Booking__c b : bookingMap.values()) {
        Decimal totalRequested =
            (b.Total_Waiver_Amount_to_be_Approved__c != null ? b.Total_Waiver_Amount_to_be_Approved__c : 0) +
            (b.RW_Total_Interest_Amount_Waived__c != null ? b.RW_Total_Interest_Amount_Waived__c : 0) +
            (b.Interest_Waiver_Approved_but_not_Waived__c != null ? b.Interest_Waiver_Approved_but_not_Waived__c : 0);

        bookingAmountMap.put(b.Id, String.valueOf(totalRequested.setScale(0)));
    }

    // 4️⃣ Query ContentVersion
    List<ContentVersion> versions = [
        SELECT Id, ContentDocumentId, Title
        FROM ContentVersion
        WHERE IsLatest = true
        AND ContentDocumentId IN :docToBookingMap.keySet()
    ];

    List<ContentVersion> versionsToUpdate = new List<ContentVersion>();
    Set<Id> iomBookingIds = new Set<Id>();

    for (ContentVersion cv : versions) {
        if (cv.Title != null && cv.Title.toLowerCase().contains('iom')) {

            Id bookingId = docToBookingMap.get(cv.ContentDocumentId);
            String amountStr = bookingAmountMap.get(bookingId);

            if (amountStr != null) {
                cv.Title = 'IOM_' + amountStr;
                versionsToUpdate.add(cv);
                iomBookingIds.add(bookingId);
            }
        }
    }

    // 5️⃣ Update file titles
    if (!versionsToUpdate.isEmpty()) {
        update versionsToUpdate;
    }

    // 6️⃣ Update Booking checkbox ONLY if IOM uploaded
    if (!iomBookingIds.isEmpty()) {
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        for (Id bid : iomBookingIds) {
            bookingsToUpdate.add(new Booking__c(
                Id = bid,
                is_IOM_Uploaded__c = true
            ));
        }
        update bookingsToUpdate;
    }
}