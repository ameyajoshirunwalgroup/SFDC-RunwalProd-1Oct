public class getCPBrkReceipts {
    @InvocableMethod
    public static void callgetreceipt() {
        System.enqueueJob(new SAPCPBrkReceiptAPICallOut(new List<Id>()));
    }
    
}