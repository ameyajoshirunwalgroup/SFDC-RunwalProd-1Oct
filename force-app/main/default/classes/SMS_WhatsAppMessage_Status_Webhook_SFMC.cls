@RestResource(urlMapping='/messageStatusWebhook/*')
global class SMS_WhatsAppMessage_Status_Webhook_SFMC {

    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        String sObjName;
        String resp;
        try{
            system.debug('req: ' + req.requestBody);
            String requestBody = req.requestBody.toString();
            system.debug('requestBody: ' + requestBody);
            
            Object parsed = JSON.deserializeUntyped(requestBody);
            List<Map<String, Object>> events = new List<Map<String, Object>>();
            List<WhatsApp_Message_Status__c> whatsappMessages = new List<WhatsApp_Message_Status__c>();
            List<SMS_Schedule_SMS_c__c> smsList = new List<SMS_Schedule_SMS_c__c>();
            if(parsed instanceof List<Object>){
                //JSON array
                for(Object obj : (List<Object>) parsed){
                    //events.add((Map<String, Object>) o);
                    Map<String, Object> payload = (Map<String, Object>) obj;
                    if(payload.containsKey('eventCategoryType')){
                        String eventCategory = (String) payload.get('eventCategoryType');
                        String eventType = eventCategory.substringAfter('.').subString(0,3);
                        String status = eventCategory.substringAfter('.').subString(3);
                        if(payload.containsKey('senderType') && payload.get('senderType') == 'WhatsApp'){
                            WhatsApp_Message_Status__c whatsapp = new WhatsApp_Message_Status__c();
                            whatsapp.Message_Sent_from_SFMC__c = true;
                            whatsapp.Status__c = status;
                            if(payload.containsKey('contactKey') && payload.get('contactKey') != null && payload.get('contactKey') != ''){
                                Id recId  = (Id) payload.get('contactKey');
                                String objectName = recId.getSObjectType().getDescribe().getName();
                                if(objectName == 'Lead'){
                                    whatsapp.Lead__c = recId;
                                }else if(objectName == 'Opportunity'){
                                    whatsapp.Opportunity__c = recId;
                                }else if(objectName == 'Account'){
                                    whatsapp.Account__c = recId;
                                }
                            }
                            
                            if(payload.get('eventCategoryType') == 'EngagementEvents.OttFailed'){
                                whatsapp.Error_Reason__c = (String) payload.get('reason');
                            }
                            if(payload.containsKey('mobileNumber')){
                                whatsapp.Mobile_Number__c = (String) payload.get('mobileNumber');
                            }
                            whatsappMessages.add(whatsapp);
                        }else if(eventType == 'Sms'){
                            SMS_Schedule_SMS_c__c sms = new SMS_Schedule_SMS_c__c();
                            sms.Name = 'SMS sent from SFMC';
                            sms.Message_Sent_from_SFMC__c = true;
                            sms.Status__c = status;
                            if(payload.containsKey('info')){
                                Map<String, Object> info = (Map<String, Object>) payload.get('info');
                                sms.Sender_Mobile__c = (String) info.get('to');
                                resp = eventType + ' : ' + status + '  :  ' + (String) info.get('to');
                            }
                            smsList.add(sms);
                        }
                    }
                    
                }
                if(smsList.size() > 0){
                    insert smsList;
                }
                if(whatsappMessages.size() > 0){
                    insert whatsappMessages;
                }
            }else if(parsed instanceof Map<String, Object>){
                //single JSON object
                events.add((Map<String, Object>) parsed);
            }
            
        	//Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            /*List<Object> payloadList = (List<Object>) JSON.deserializeUntyped(requestBody);
            system.debug('payloadList: ' + payloadList);
            
            for(Object obj : payloadList){
                Map<String, Object> payload = (Map<String, Object>) obj;
                
                
                if (payload.containsKey('eventCategoryType')){
                    String messageStatus = (String) payload.get('eventCategoryType');
                    String msgStatus = messageStatus.split('.')[1];
                    System.debug('messageStatus: ' + messageStatus);
                }
                if (payload.containsKey('mobileNumber')){
                    String mobile = (String) payload.get('mobileNumber');
                    System.debug('mobile: ' + mobile);
                }
                
            }*/
            
            
            /*RespDetails resData = (RespDetails)JSON.deserialize(jsonBody, RespDetails.class);
            if(resData.recordId != null){
                Id objId  = resData.recordId;
                sObjName = objId.getSObjectType().getDescribe().getName();
                
            }
            if(resData.messageType == 'SMS'){
                SMS_Schedule_SMS_c__c sms = new SMS_Schedule_SMS_c__c();
                sms.Name = 'SMS sent from SFMC';
                sms.Status__c = resData.status;
                sms.Sender_Mobile__c = resData.mobile;
                sms.SMS_Long_text__c = resData.message;
                sms.Message_Sent_from_SFMC__c = true;
                if(sObjName == 'Opportunity'){
                    sms.Opportunity_Lookup__c = resData.recordId;
                }else if(sObjName == 'Lead'){
                    sms.Lead_Lookup__c = resData.recordId;
                }
                insert sms;
            }else if(resData.messageType == 'Whatsapp'){
                WhatsApp_Message_Status__c whatsapp = new WhatsApp_Message_Status__c();
                whatsapp.Status__c = resData.status;
                whatsapp.Mobile_Number__c = resData.mobile;
                whatsapp.Message__c = resData.message;
                whatsapp.Message_Sent_from_SFMC__c = true;
                if(sObjName == 'Opportunity'){
                    whatsapp.Opportunity__c = resData.recordId;
                }else if(sObjName == 'Case'){
                    whatsapp.Case__c = resData.recordId;
                }else if(sObjName == 'Account'){
                    whatsapp.Account__c = resData.recordId;
                }else if(sObjName == 'Lead'){
                    whatsapp.Lead__c = resData.recordId;
                }
                insert whatsapp;
            }*/
            res.responseBody = Blob.valueOf('Message status submitted successfully; ' + resp);
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class RespDetails{
        public String mobile;
        public String status;
        public String recordId;
        public String messageType;
        public String message;
    }
}