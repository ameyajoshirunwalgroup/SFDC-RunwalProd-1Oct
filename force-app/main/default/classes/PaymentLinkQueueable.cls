public class PaymentLinkQueueable implements Queueable, Database.AllowsCallouts {
    private Id opportunityId;
    private String amount;
    private String hash;
    private Opportunity opp;
    private String merchant_txn;

    public PaymentLinkQueueable(Id opportunityId, String amount, String hash,String merchant_txn) {
        this.opportunityId = opportunityId;
        this.amount = amount;
        this.hash = hash;
        this.merchant_txn=merchant_txn;
    }

    public void execute(QueueableContext context) {
        opp = [SELECT Id, Name, Account.Name, Account.PersonEmail, Account.Mobile_No__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        
        String name = opp.Account.Name;
        String email = opp.Account.PersonEmail;
        String phone = opp.Account.Mobile_No__c;
        String message = 'Payment for Opportunity ' + opp.Name;
        String udf1 = '';
        String udf2 = '';
        String udf3 = '';
        String udf4 = '';
        String udf5 = '';

        Map<String, Object> requestBody = new Map<String, Object>{
            'key' => 'OTVO07DZOH', 
            'merchant_txn' => merchant_txn,
            'amount' => amount,
            'name' => name,
            'phone' => phone,
            'email' => email,
            'hash' => hash, 
            'udf1' => udf1,
            'udf2' => udf2,
            'udf3' => udf3,
            'udf4' => udf4,
            'udf5' => udf5,
            'message' => message
        };

        // Debug log for request body
        System.debug('Request Body: ' + JSON.serialize(requestBody));

        String responseBody = callEasebuzzAPI(requestBody);
        String paymentLink = parsePaymentLink(responseBody);

        sendPaymentLinkEmail(opp, paymentLink);
    }

    private String callEasebuzzAPI(Map<String, Object> requestBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://dashboard.easebuzz.in/easycollect/v1/create');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setBody(JSON.serialize(requestBody));
        HttpResponse response = http.send(request);
        System.debug('Response Status: ' + response.getStatus());
        System.debug('Response Body: ' + response.getBody());

        if (response.getStatusCode() != 200) {
            throw new AuraHandledException('Failed to call Easebuzz API: ' + response.getStatus());
        }

        return response.getBody();
    }

    private String parsePaymentLink(String responseBody) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (responseMap.containsKey('status')) {
            Object statusValue = responseMap.get('status');
            Boolean isSuccess = false;
            if (statusValue instanceof Boolean) {
                isSuccess = (Boolean) statusValue;
            } else if (statusValue instanceof String) {
                isSuccess = statusValue == 'true';
            }

            if (isSuccess && responseMap.containsKey('data')) {
                Map<String, Object> data = (Map<String, Object>)responseMap.get('data');
                if (data.containsKey('payment_url')) {
                    return (String)data.get('payment_url');
                } else {
                    throw new AuraHandledException('Failed to generate payment link: payment_url not found in data');
                }
            } else {
                throw new AuraHandledException('Failed to generate payment link: ' + (String)responseMap.get('message'));
            }
        } else {
            throw new AuraHandledException('Failed to generate payment link: status not found');
        }
    }

    private void sendPaymentLinkEmail(Opportunity opp, String paymentLink) {
        String emailBody = 'Dear ' + opp.Account.Name + ',\n\n' +
            'Please use the following link to complete the payment for Opportunity ' + opp.Name + ':\n' +
            paymentLink + '\n\n' +
            'Thank you,\n' +
            'Your Company';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[]{opp.Account.PersonEmail});
        email.setSubject('Payment Link for Opportunity ' + opp.Name);
        email.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }
}