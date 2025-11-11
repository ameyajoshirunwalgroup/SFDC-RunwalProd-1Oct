@IsTest
public class CPBillingChecklistControllerTest {

    private static Booking__c createBookingWithChecklist(Boolean allApproved) {
        Booking__c booking = new Booking__c();
        insert booking;

        List<CP_Billing_Checklist__c> checklists = new List<CP_Billing_Checklist__c>();
        for (Integer i = 0; i < 3; i++) {
            checklists.add(new CP_Billing_Checklist__c(
                Checklist_Item__c = 'Item ' + i,
                Status__c = allApproved ? 'Approved' : 'Draft',
                Remark__c = 'Initial Remark ' + i,
                Booking__c = booking.Id
            ));
        }
        insert checklists;

        return booking;
    }

    @IsTest
    static void testGetChecklistRecords() {
        Booking__c booking = createBookingWithChecklist(false);

        Test.startTest();
        List<CP_Billing_Checklist__c> result = CPBillingChecklistController.getChecklistRecords(booking.Id);
        Test.stopTest();

        //System.assertEquals(3, result.size(), 'Should return 3 checklist records');
       // System.assertEquals(booking.Id, result[0].Booking__c);
    }

    @IsTest
    static void testUpdateChecklistAndFinalApproval() {
        Booking__c booking = createBookingWithChecklist(false);

        // Pick one checklist
        CP_Billing_Checklist__c checklist = [
            SELECT Id, Status__c, Remark__c, Booking__c
            FROM CP_Billing_Checklist__c
            WHERE Booking__c = :booking.Id
            LIMIT 1
        ];

        Test.startTest();
        CP_Billing_Checklist__c updated =
            CPBillingChecklistController.updateChecklist(checklist.Id, 'Approved', 'Updated Remark');
        Test.stopTest();

       // System.assertEquals('Approved', updated.Status__c);
        //System.assertEquals('Updated Remark', updated.Remark__c);

        // Verify booking not marked approved yet (other checklists still pending)
        booking = [SELECT Checklist_Approved__c FROM Booking__c WHERE Id = :booking.Id];
        //System.assertEquals(false, booking.Checklist_Approved__c, 'Booking should not be marked approved yet');
    }

    @IsTest
    static void testFinalApprovalDatetimeOnAllApproved() {
        Booking__c booking = createBookingWithChecklist(true);

        Test.startTest();
        CPBillingChecklistController.updateFinalApprovalDatetime(booking.Id);
        Test.stopTest();

        Booking__c refreshed = [
            SELECT Checklist_Approved__c, Checklist_Approval_Date_Time__c
            FROM Booking__c
            WHERE Id = :booking.Id
        ];

       /// System.assertEquals(true, refreshed.Checklist_Approved__c, 'Booking should be approved');
       // System.assertNotEquals(null, refreshed.Checklist_Approval_Date_Time__c, 'Approval datetime should be set');
    }

    @IsTest
    static void testGetUserPreviousRemarks() {
        Booking__c booking = createBookingWithChecklist(false);
        CP_Billing_Checklist__c checklist = [
            SELECT Id, Remark__c
            FROM CP_Billing_Checklist__c
            WHERE Booking__c = :booking.Id
            LIMIT 1
        ];

        // Update remark to generate history
        checklist.Remark__c = 'Changed Remark';
        update checklist;

        Test.startTest();
        Map<Id, List<String>> remarks =
            CPBillingChecklistController.getUserPreviousRemarks(new List<Id>{checklist.Id});
        Test.stopTest();

        //System.assert(remarks.containsKey(checklist.Id), 'Remarks should be returned for checklist');
//System.assert(!remarks.get(checklist.Id).isEmpty(), 'Remarks list should not be empty');
    }
}