@isTest
public class TrgBrokerageReceiptHandlerTest {

    @isTest
    public static void testInsertUpdateDelete() {
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 10';
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        insert bro;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Invoice_Number__c = '';
        bi.If_GST_is_applicable__c = '';
        bi.Brokerage_Lookup__c = bro.id;
        bi.Total_Agreement_Value__c = null;
        bi.Invoice_Status__c = 'Not Submitted';
        bi.Invoice_Date__c = system.today();
        bi.Brokerage_In_Rs__c = 53633;
        bi.Invoice_Date__c = system.today();
        bi.IGST__c = '';
        bi.CGST__c = '';
        bi.SGST__c = '';
        bi.Invoice_Amount__c = null;
        bi.Approval_Status__c = 'Approved By L3 - Accounts';
        insert bi;

        // 1️⃣ Create CP Brokerage Master
        CP_Brokerage__c cp = new CP_Brokerage__c(
            Total_Amount_Paid__c = 0
        );
        insert cp;

        // ---------------------------
        // 2️⃣ INSERT → Should add amount
        // ---------------------------
        Brokerage_Receipt__c br1 = new Brokerage_Receipt__c(
            CP_Brokerage__c = cp.Id,
            Invoice_Amount__c = 5000,
            Brokerage_Invoice__c = bi.Id
        );
        insert br1;  // after insert trigger fires
        br1.Invoice_Amount__c = 7000;
		update br1;
        delete br1;

    }
}