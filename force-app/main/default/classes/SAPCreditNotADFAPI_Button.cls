public class SAPCreditNotADFAPI_Button {


    @InvocableMethod(label='SAPCreditNotADFAPICallout Batch')
    public static void runBatch(List<Id> recordId){

        System.debug('recordId: ' + recordId);
        SAPCreditNotADFAPICallout bt = new SAPCreditNotADFAPICallout(recordId);
        bt.execute(null);
    }
}