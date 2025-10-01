@istest
public class InteraktWebhookTest {
	@istest
    public static void test1(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal.my.salesforce-sites.com/interaktWebhook/services/apexrest/interaktWebhook'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        String body = '{"version": "1.0", "timestamp": "2023-07-07T06:39:19.576619", "type": "message_api_delivered", "data": {"customer": {"id": "b0e54348-47b1-4805-9862-2cd0d881329a", "channel_phone_number": "918977007794", "phone_number": "8977007794", "country_code": "+91", "traits": {"name": "", "whatsapp_opted_in": true, "source_id": null, "source_url": null}}, "message": {"id": "7d8eabf5-a5ee-49ea-918d-0a351047198b", "chat_message_type": "PublicApiMessage", "channel_failure_reason": null, "message_status": "Delivered", "received_at_utc": "2023-07-07T06:39:09.523000", "delivered_at_utc": "2023-07-07T06:39:19.235000", "seen_at_utc": null, "campaign_id": null, "is_template_message": true, "raw_template": "{Test}", "channel_error_code": null, "message_content_type": "Template", "media_url": null, "message": "", "meta_data": {"source": "PublicInterakt", "source_data": {"callback_data": "'+ acc.Id + '"}}}}}';
        req.requestBody =Blob.valueOf(body);
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
        InteraktWebhook.interaktWebhookResp();
        Test.stopTest();
    }
}