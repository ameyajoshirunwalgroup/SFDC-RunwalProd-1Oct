@IsTest
public class SMS_WhatsAppMsg_Status_Webhook_SFMC_Test {

    @IsTest
    static void testWhatsAppAndSmsEvents() {
        
        // Create test Lead (for contactKey)
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            RW_Mobile_No__c='848484848',
            Status = 'New'
        );
        insert testLead;

        // Prepare JSON request body (Array format as expected by class)
        List<Map<String, Object>> payloadList = new List<Map<String, Object>>();

        // WhatsApp Failed Event
        Map<String, Object> whatsappPayload = new Map<String, Object>();
        whatsappPayload.put('eventCategoryType', 'EngagementEvents.OttFailed');
        whatsappPayload.put('senderType', 'WhatsApp');
        whatsappPayload.put('contactKey', testLead.Id);
        whatsappPayload.put('mobileNumber', '9876543210');
        whatsappPayload.put('reason', 'Invalid Number');

        payloadList.add(whatsappPayload);

        // SMS Delivered Event
        Map<String, Object> smsPayload = new Map<String, Object>();
        smsPayload.put('eventCategoryType', 'EngagementEvents.SmsDelivered');
        
        Map<String, Object> infoMap = new Map<String, Object>();
        infoMap.put('to', '9123456789');
        smsPayload.put('info', infoMap);

        payloadList.add(smsPayload);

        String requestBody = JSON.serialize(payloadList);

        // Set REST Context
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/messageStatusWebhook/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SMS_WhatsAppMessage_Status_Webhook_SFMC.doPost();
        Test.stopTest();

        // Assertions

        // Validate WhatsApp record
        List<WhatsApp_Message_Status__c> waList = [
            SELECT Id, Status__c, Lead__c, Error_Reason__c, Mobile_Number__c
            FROM WhatsApp_Message_Status__c
        ];
        System.assertEquals(1, waList.size());
        System.assertEquals(testLead.Id, waList[0].Lead__c);
        System.assertEquals('Failed', waList[0].Status__c);
        System.assertEquals('Invalid Number', waList[0].Error_Reason__c);
        System.assertEquals('9876543210', waList[0].Mobile_Number__c);

        // Validate SMS record
        List<SMS_Schedule_SMS_c__c> smsList = [
            SELECT Id, Status__c, Sender_Mobile__c
            FROM SMS_Schedule_SMS_c__c
        ];
        System.assertEquals(1, smsList.size());
        System.assertEquals('Delivered', smsList[0].Status__c);
        System.assertEquals('9123456789', smsList[0].Sender_Mobile__c);

        // Validate response
        System.assertEquals(200, RestContext.response.statusCode);
        System.assert(
            RestContext.response.responseBody.toString().contains('Message status submitted successfully')
        );
    }
}