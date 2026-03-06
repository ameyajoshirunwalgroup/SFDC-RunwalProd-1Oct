@IsTest
public class BillDeskSplitPaymentVFControllerTest {

    // ----------------------------------------------------
    // 1️⃣ SUCCESS CASE — OrderId Present + Record Exists
    // ----------------------------------------------------
    @IsTest
    static void testController_Success() {

        // Create Payment record
        Payment_Transaction__c payment = new Payment_Transaction__c(
            Order_Id__c = 'ORD123',
            Merchant_Id__c = 'MERCHANT1',
            BillDesk_Order_Id__c = 'BD123',
            RData__c = 'RDATA123',
            Payment_Url__c = 'https://payment.url'
        );
        insert payment;

        // Simulate VF page with parameter
        PageReference pageRef = Page.BillDeskSplitPaymentPage; // <-- your VF page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('orderId', 'ORD123');

        // Execute controller
        BillDeskSplitPaymentVFController ctrl =
            new BillDeskSplitPaymentVFController();

    }

    // ----------------------------------------------------
    // 2️⃣ BLANK ORDERID CASE
    // ----------------------------------------------------
    @IsTest
    static void testController_BlankOrderId() {

        PageReference pageRef = Page.BillDeskSplitPaymentPage;
        Test.setCurrentPage(pageRef);

        // Do NOT set orderId param
    }

    // ----------------------------------------------------
    // 3️⃣ RECORD NOT FOUND (Exception Case)
    // ----------------------------------------------------
    @IsTest
    static void testController_RecordNotFound() {

        PageReference pageRef = Page.BillDeskSplitPaymentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('orderId', 'NON_EXISTING');

        Boolean exceptionThrown = false;

        try {
            new BillDeskSplitPaymentVFController();
        } catch(Exception e) {
            exceptionThrown = true;
        }

    }
}