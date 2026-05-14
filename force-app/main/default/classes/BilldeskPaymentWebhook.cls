@RestResource(urlMapping='/billdeskWebhook/*')
global class BilldeskPaymentWebhook {

    @HttpPost
    global static void billdeskWebhookResp(){
        RestRequest req = RestContext.request;
        system.debug('**'+req);
        String message = req.params.get('transaction_response');
        System.debug('transaction_response: ' + req.params.get('transaction_response'));
        Integer index1 = message.indexOf('.');
        message = message.subString(index1+1, message.length()-1);
        Integer index2 = message.indexOf('.');
        message = message.subString(0,index2);
        Blob bsignature = EncodingUtil.base64Decode(message);
        String decodeBase64String = bsignature.toString();
        System.debug('decodeBase64String: ' + decodeBase64String);
        
        system.debug('** body: '+req.requestBody);
        String jsonBody = req.requestBody.toString();
        system.debug('jsonBody: '+jsonBody);
        //BilldeskResponse resp = (BilldeskResponse) System.JSON.deserialize(req.requestBody.toString(), BilldeskResponse.class);
        BilldeskResponse resp = (BilldeskResponse) System.JSON.deserialize(decodeBase64String, BilldeskResponse.class);

        Receipt__c receipt = [SELECT Id, Opportunity__c FROM Receipt__c WHERE Billdesk_Order_Id__c =: resp.orderid];
        
        receipt.Total_Amount__c = Decimal.valueOf(resp.amount);
        receipt.BillDesk_Payment_Mode__c = resp.payment_method_type;
        receipt.Receipt_Status__c = (resp.auth_status == '0300')? 'Success' : 'Failure';
        if(resp.auth_status != '0300'){
            ERP_Integration_Log__c integrationLog = new ERP_Integration_Log__c();
            integrationLog.API_Name__c ='SAP BillDesk';
            integrationLog.Request__c = jsonBody;
            integrationLog.Opportunity__c = receipt.Opportunity__c;
            integrationLog.Error_Type__c = 'Timeout Error';
            integrationLog.Status__c ='Failure';
            integrationLog.Error_Reason__c = 'transaction_error_code: ' + resp.transaction_error_code + '; transaction_error_desc: ' + resp.transaction_error_desc + '; transaction_error_type: ' + resp.transaction_error_type;
            insert integrationLog; 
        }
        update receipt;
    }
    
    global class BilldeskResponse{
        public string objectid;
        public string transactionid;
        public string orderid;
        public string mercid;
        public string transaction_date;
        public string amount;
        public string surcharge;
        public string discount;
        public string charge_amount;
        public AdditionalInfo additional_info;
        public string ru;
        public string txn_process_type;
        public string bankid;
        public string itemcode;
        public string bank_ref_no;
        public string auth_status;
        public string transaction_error_code;
        public string transaction_error_desc;
        public string transaction_error_type;
        public string payment_method_type;
        public UPI upi;
        public string payment_category;
    }
    
    public class AdditionalInfo{
        public string additional_info1;
        public string additional_info2;
    }
    
    public class UPI{
        public string vpa;
        public string masked_vpa;
    }
}