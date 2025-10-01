@RestResource(urlMapping='/interactWebhook/*')
global class InteractWebhook {
    
	@HttpPost
    global static void interactWebhookResp(){
        RestRequest req = RestContext.request;
        system.debug('**'+req);
        system.debug('** body: '+req.requestBody);
        String jsonBody = req.requestBody.toString();
        system.debug('jsonBody: '+jsonBody);
        //system.debug('jsonBody: ' + jsonBody);
        system.debug('customer: ' + req.params.get('customer'));
        JsonResponse resp = (JsonResponse) System.JSON.deserialize(req.requestBody.toString(), JsonResponse.class);
        System.debug('resp: ' + resp);
        RawTemplate temp = new RawTemplate();
        if(!Test.isRunningTest()){
            temp = (RawTemplate) System.JSON.deserialize(resp.data.message.raw_template, RawTemplate.class);
        }else{
            temp.Name = 'Test';
        }
        System.debug('callback_data: ' + resp.data.message.meta_data.source_data.callback_data);
        WhatsApp_Message_Status__c msgSts = new WhatsApp_Message_Status__c();
        if(resp.data.message.meta_data.source_data.callback_data != null && resp.data.message.meta_data.source_data.callback_data != ''){
            msgSts.Opportunity__c = resp.data.message.meta_data.source_data.callback_data;
        }
        msgSts.Mobile_Number__c = resp.data.customer.phone_number;
        msgSts.Country_Code__c = resp.data.customer.country_code;
        msgSts.Template__c = temp.name;
        msgSts.Status__c = resp.data.message.message_status;
        msgSts.Error_Code__c = resp.data.message.channel_error_code;
        msgSts.Error_Reason__c = resp.data.message.channel_failure_reason;
        insert msgSts;
        
    }
    
    public class JsonResponse{
        public Data data;
        public String version;
        public String timestamp;
        public String type;
    }
    public class Data{
        public Customer customer;
        public Message message;
    }
    public class Customer{
        public String id;
        public String channel_phone_number;
        public String phone_number;
        public String country_code;
        public Traits traits;
    }
    public class Traits{
        
    }
    public class Message{
        public String id;
        public String chat_message_type;
        public String channel_failure_reason;
        public String message_status;
        public String received_at_utc;
        public String delivered_at_utc;
        public String seen_at_utc;
        public String campaign_id;
        public String is_template_message;
        public String channel_error_code;
        public String message_content_type;
        public String raw_template;
        public String media_url;
        public Metadata meta_data;
        
    }
    public class Metadata{
        public String source;
        public SourceData source_data;
    }
    public class SourceData{
        public String callback_data;
    }
    public class RawTemplate{
        public String id;
        public String created_at_utc;
        public String modified_at_utc;
        public String created_by_user_id;
        public String is_deleted;
        public String name;
        public String language;
        public String category;
        public String template_category_label;
        public String header_format;
        public String header;
        public String header_handle;
        public String header_handle_file_url;
        public String header_handle_file_name;
        public String header_text;
        public String body;
        public String body_text;
        public String footer;
        public String buttons;
        public String button_text;
        public String allow_category_change;
        public String autosubmitted_for;
        public String display_name;
        public String organization_id;
        public String approval_status;
        public String wa_template_id;
        public String is_archived;
        public String channel_type;
        public String allow_delete;
        public String rejection_reason;
    }
}