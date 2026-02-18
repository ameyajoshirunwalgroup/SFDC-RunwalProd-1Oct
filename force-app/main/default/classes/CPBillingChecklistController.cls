/**
* @File Name : CPBillingChecklistController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 2, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 2, 2025 |   | Initial Version
**/

public with sharing class CPBillingChecklistController {
    @AuraEnabled(cacheable=true)
    public static List<CP_Billing_Checklist__c> getChecklistRecords(Id bookingId) {
        return [
            SELECT Id, Checklist_Item__c, Status__c, Remark__c, Final_Approval_Date_Time__c, Booking__c,
            Booking__r.Original_Agreement_Value__c,
               Booking__r.Booking_Date__c,
               Booking__r.BrokerIId__r.Name,
               //Booking__r.BrokerIId__r.Valid_competency_certificate__c,//Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
               Booking__r.BrokerIId__r.Valid_RERA_certificate__c,
               Booking__r.Brokerage_Scheme__r.Name,
               Booking__r.Quotation__r.Discount_9_L__c,
               Booking__r.Stamp_duty_payable_by_Runwal__c,
               Booking__r.Development_Charge__c
            FROM CP_Billing_Checklist__c
            WHERE Booking__c = :bookingId
            ORDER BY CreatedDate ASC
        ];
    }

    @AuraEnabled
    public static CP_Billing_Checklist__c updateChecklist(Id recordId, String status, String remark) {
        CP_Billing_Checklist__c rec = [
            SELECT Id, Status__c, Remark__c, Booking__c, Final_Approval_Date_Time__c
            
            FROM CP_Billing_Checklist__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        rec.Status__c = status;
        rec.Remark__c = remark;
        update rec;

        // After updating this single record, check and update Final_Approval_Date_Time__c for all items
        if (rec.Booking__c != null) {
            updateFinalApprovalDatetimeInternal(rec.Booking__c);
        }

        return rec;
    }


    @AuraEnabled
    public static void updateFinalApprovalDatetime(Id bookingId) {
        updateFinalApprovalDatetimeInternal(bookingId);
    }

    private static void updateFinalApprovalDatetimeInternal(Id bookingId) {
    if (bookingId == null) return;

    // Fetch related checklist records
    List<CP_Billing_Checklist__c> records = [
        SELECT Id, Status__c, Final_Approval_Date_Time__c
        FROM CP_Billing_Checklist__c
        WHERE Booking__c = :bookingId
    ];

    if (records.isEmpty()) return;

    Boolean allApproved = true;
    List<CP_Billing_Checklist__c> toUpdateChecklists = new List<CP_Billing_Checklist__c>();

    // Loop through records
    for (CP_Billing_Checklist__c r : records) {
        if (r.Status__c != 'Approved') {
            allApproved = false;
        } else if (r.Final_Approval_Date_Time__c == null) {
            // Set approval time only once
            r.Final_Approval_Date_Time__c = System.now();
            toUpdateChecklists.add(r);
        }
    }

    // Update checklists if needed
    if (!toUpdateChecklists.isEmpty()) {
        update toUpdateChecklists;
    }

    // If ALL are approved, update Booking
    if (allApproved) {
        Booking__c booking = [
            SELECT Id, Checklist_Approved__c, Checklist_Approval_Date_Time__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
        ];

        if (booking.Checklist_Approved__c == false || booking.Checklist_Approval_Date_Time__c == null) {
            booking.Checklist_Approved__c = true;
            booking.Checklist_Approval_Date_Time__c = System.now();
            update booking;
        }
    }
}


    @AuraEnabled(cacheable=true)
public static Map<Id, List<String>> getUserPreviousRemarks(List<Id> recordIds) {
    Map<Id, List<String>> results = new Map<Id, List<String>>();
    if (recordIds == null || recordIds.isEmpty()) return results;

    Id userId = UserInfo.getUserId();

    List<CP_Billing_Checklist__History> histories = [
        SELECT ParentId, NewValue, CreatedDate, CreatedById
        FROM CP_Billing_Checklist__History
        WHERE Field = 'Remark__c'
          AND ParentId IN :recordIds
          AND CreatedById = :userId
        ORDER BY CreatedDate DESC LIMIT 1
    ];

    for (CP_Billing_Checklist__History h : histories) {
        if (!results.containsKey(h.ParentId)) {
            results.put(h.ParentId, new List<String>());
        }
        if (h.NewValue != null) {
            results.get(h.ParentId).add(
                h.NewValue + ' (' + String.valueOf(h.CreatedDate) + ')'
            );
        }
    }
    return results;
}

}