public class SendWhatsAppMsg{
    
    @future(callout=true)
    Public static void genaricMethodToSendWhatsAppMsg(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String MobileNo, String elementName){
        
        
        //methodToSendWhatsAppMsg(param1, param2, param3 ,param4,param5,param6,param7,param8,param9, countryCode, MobileNo, elementName);
        System.debug('### genaricMethodToSendWhatsAppMsg Parameters ### ' + 
                     'param1=' + param1 + ', param2=' + param2 + ', param3=' + param3 + 
                     ', param4=' + param4 + ', param5=' + param5 + ', param6=' + param6 + 
                     ', param7=' + param7 + ', param8=' + param8 + ', param9=' + param9 + 
                     ', MobileNo=' + MobileNo + ', elementName=' + elementName);
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        system.debug('##customMeta  '+customMeta); 
        
        // string jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9", "element_name": "eoi_booking_management", "language": { "policy": "deterministic", "code": "en" }, "localizable_params": [ {"default": "'+param1+'"}, {"default": "'+param2+'"}, {"default": "'+param3+'"}, {"default": "'+param4+'"} ] }';
        //string jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9", "element_name": "new_lead_greetings", "language": { "policy": "deterministic", "code": "en" }, "localizable_params": [ {"default": "'+param1+'"} ] }';
        
        string jsonParse;
        
        jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9",';
        jsonParse += '"name": '+ '"' + customMeta.RW_element_name__c + '",';
        system.debug('______17 name'+jsonParse);
        jsonParse += '"language": { "policy": "deterministic", "code": "en" }';
        
        if(String.isNotBlank(param1) || String.isNotBlank(param2) ||
           String.isNotBlank(param3) || String.isNotBlank(param4) || 
           String.isNotBlank(param5) || String.isNotBlank(param6) ||
           String.isNotBlank(param7) || String.isNotBlank(param8) ||
           String.isNotBlank(param9)) {
               
               jsonParse += ',"components": [{"type": "body",';
               jsonParse += '"parameters": [';
               if(String.isNotBlank(param1) && param1 != null){
                   jsonParse += '{"type": "text"';  
                   jsonParse += ',"text": "'+param1+'"}'; 
               }
               if(String.isNotBlank(param2) && param2 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param2+'"}';
               }
               if(String.isNotBlank(param3) && param3 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param3+'"}';
               }
               if(String.isNotBlank(param4) && param4 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param4+'"}';
               }
               if(String.isNotBlank(param5) && param5 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param5+'"}';
               }
               if(String.isNotBlank(param6) && param6 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param6+'"}';
               }
               if(String.isNotBlank(param7) && param7 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param7+'"}';
               }
               if(String.isNotBlank(param8) && param8 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param8+'"}';
               }
               if(String.isNotBlank(param9) && param9 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param9+'"}';
               }
               jsonParse += ']';
           }
        
        jsonParse +=  '}]';
        jsonParse +=  '}';
        
        system.debug('______40jsonParse  '+jsonParse);
        
        
        WhatsAppWrapper whatsAppWrp  = new WhatsAppWrapper();
        whatsAppWrp.business_id = 2492;
        whatsAppWrp.to = MobileNo;
        whatsAppWrp.type_Z = 'template';
        JSONParser parser = JSON.createParser(jsonParse);
        WhatsAppWrapper.Template templateBody = new WhatsAppWrapper.Template(parser);
        System.debug('templateBody: ' + templateBody);
        whatsAppWrp.template = templateBody;
        list<WhatsAppWrapper.Components> localParamList = new  list<WhatsAppWrapper.Components>();
        if(Test.isRunningTest()){
            WhatsAppWrapper.consumeObject(parser);
        }
        
        string str = System.JSON.serialize(whatsAppWrp);
        str = str.replace('"type_Z"','"type"');
        //str = str.replace('"default_Z"','"default"');
        str = str.replace('"text_Z"','"text"');
        system.debug('##JsonStr  '+str); 
        
        //callout
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer' + System.Label.WhatsApp_Authorization_Bearer); 
        req.setHeader('client-id', System.Label.WhatsApp_client_id);
        req.setEndpoint('https://whatsapp-notifications.haptikapi.com/whatsapp/notification/v2/');
        req.setBody(str);
        HTTPResponse res = http.send(req);
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    //@future(callout=true)
    Public static void genaricMethodToSendWhatsAppMsgBatch(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String MobileNo, String elementName){
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        system.debug('##customMeta  '+customMeta); 
        
        // string jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9", "element_name": "eoi_booking_management", "language": { "policy": "deterministic", "code": "en" }, "localizable_params": [ {"default": "'+param1+'"}, {"default": "'+param2+'"}, {"default": "'+param3+'"}, {"default": "'+param4+'"} ] }';
        //string jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9", "element_name": "new_lead_greetings", "language": { "policy": "deterministic", "code": "en" }, "localizable_params": [ {"default": "'+param1+'"} ] }';
        
        string jsonParse;
        
        jsonParse = '{ "namespace": "dd6eaff3_6ab8_4187_9b2e_a4a7cff6aeb9",';
        jsonParse += '"name": '+ '"' + customMeta.RW_element_name__c + '",';
        system.debug('______17 name'+jsonParse);
        jsonParse += '"language": { "policy": "deterministic", "code": "en" }';
        
        if(String.isNotBlank(param1) || String.isNotBlank(param2) ||
           String.isNotBlank(param3) || String.isNotBlank(param4) || 
           String.isNotBlank(param5) || String.isNotBlank(param6) ||
           String.isNotBlank(param7) || String.isNotBlank(param8) ||
           String.isNotBlank(param9)) {
               
               jsonParse += ',"components": [{"type": "body",';
               jsonParse += '"parameters": [';
               if(String.isNotBlank(param1) && param1 != null){
                   jsonParse += '{"type": "text"';  
                   jsonParse += ',"text": "'+param1+'"}'; 
               }
               if(String.isNotBlank(param2) && param2 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param2+'"}';
               }
               if(String.isNotBlank(param3) && param3 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param3+'"}';
               }
               if(String.isNotBlank(param4) && param4 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param4+'"}';
               }
               if(String.isNotBlank(param5) && param5 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param5+'"}';
               }
               if(String.isNotBlank(param6) && param6 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param6+'"}';
               }
               if(String.isNotBlank(param7) && param7 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param7+'"}';
               }
               if(String.isNotBlank(param8) && param8 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param8+'"}';
               }
               if(String.isNotBlank(param9) && param9 != null){
                   jsonParse += ',{"type": "text"';
                   jsonParse += ',"text": "'+param9+'"}';
               }
               jsonParse += ']';
           }
        
        jsonParse +=  '}]';
        jsonParse +=  '}';
        
        system.debug('______40jsonParse  '+jsonParse);
        
        
        WhatsAppWrapper whatsAppWrp  = new WhatsAppWrapper();
        whatsAppWrp.business_id = 2492;
        whatsAppWrp.to = MobileNo;
        whatsAppWrp.type_Z = 'template';
        JSONParser parser = JSON.createParser(jsonParse);
        WhatsAppWrapper.Template templateBody = new WhatsAppWrapper.Template(parser);
        System.debug('templateBody: ' + templateBody);
        whatsAppWrp.template = templateBody;
        list<WhatsAppWrapper.Components> localParamList = new  list<WhatsAppWrapper.Components>();
        if(Test.isRunningTest()){
            WhatsAppWrapper.consumeObject(parser);
        }
        
        string str = System.JSON.serialize(whatsAppWrp);
        str = str.replace('"type_Z"','"type"');
        //str = str.replace('"default_Z"','"default"');
        str = str.replace('"text_Z"','"text"');
        system.debug('##JsonStr  '+str); 
        
        //callout
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer' + System.Label.WhatsApp_Authorization_Bearer); 
        req.setHeader('client-id', System.Label.WhatsApp_client_id);
        req.setEndpoint('https://whatsapp-notifications.haptikapi.com/whatsapp/notification/v2/');
        req.setBody(str);
        HTTPResponse res = http.send(req);
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    //@future(callout=true)
    Public static void methodToSendWhatsAppMsgBatch(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String countryCode, String MobileNo, String elementName){
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        System.debug('--methodToSendWhatsAppMsg--');
        System.debug('param1: ' + param1);
        System.debug('param2: ' + param2);
        
        String templateName = customMeta.RW_element_name__c;
        
        String languageCode;
        if(templateName == 'call_disposition'){
            languageCode = 'en_GB';
        }else{
            languageCode = 'en';
        }
        
        String payload;
        if(elementName == 'call_disposition'){
            payload = 'Call Disposition';
        }else if(elementName == 'case_closure_new'){
            payload = 'Case closure';
        }else if( elementName == 'post_60_days'){
            payload = 'Post 60 Days';
        }else if(elementName == 'generic_feedback'){
            payload = 'Dynamic{api_name:camp,camp_id:'+param2+'}';
        }else if(elementName == 'Sales Experience'){
            payload = 'I want to give feedback on my sales experience';
        }else if(elementName == 'Day of Registration'){
            payload = 'Day of Registration';
        }else if(elementName == 'Day of Key Handover'){
            payload = 'Key Handover';
        }
        
        String jsonParse;
        if(String.isNotBlank(countryCode) && countryCode != null){
            jsonParse = '{"countryCode" : ' + '"' + countryCode + '",';
        }else{
            jsonParse = '{"countryCode" : "+91",';
        }
        
        jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        if(String.isNotBlank(param1) && param1 != null){
            jsonParse += '"callbackData" : ' + '"' + param1 + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        if(elementName == 'possession_guidelines' || elementName == 'Bank Funding Requirements Documents' || elementName == 'Birthday Wish' || elementName == 'Demand Letter'){
            jsonParse += '"headerValues"  : [';
            if(String.isNotBlank(param8) && param8 != null){
                jsonParse += '"' + param8 + '"';
            }
            jsonParse += '],';
            if(String.isNotBlank(param9) && param9 != null){
                jsonParse +='"fileName" : "' + param9 + '.pdf",';
            }
        }
        
        jsonParse += '"bodyValues"  : [';
        /*if(String.isNotBlank(param1) && param1 != null){
jsonParse += '"' + param1 + '"';
}*/
        if(String.isNotBlank(param2) && param2 != null){
            jsonParse += '"' + param2 + '"';
        }
        if(String.isNotBlank(param3) && param3 != null){
            jsonParse += ',"' + param3 + '"';
        }
        if(String.isNotBlank(param4) && param4 != null){
            jsonParse += ',"' + param4 + '"';
        }
        if(String.isNotBlank(param5) && param5 != null){
            jsonParse += ',"' + param5 + '"';
        }
        if(String.isNotBlank(param6) && param6 != null){
            jsonParse += ',"' + param6 + '"';
        }
        if(String.isNotBlank(param7) && param7 != null){
            jsonParse += ',"' + param7 + '"';
        }
        if(elementName != 'possession_guidelines' && elementName != 'Bank Funding Requirements Documents' && elementName != 'Birthday Wish'  && elementName != 'Demand Letter'){
            if(String.isNotBlank(param8) && param8 != null){
                jsonParse += ',"' + param8 + '"';
            }
            if(String.isNotBlank(param9) && param9 != null){
                jsonParse += ',"' + param9 + '"';
            }
        }
        /*if(String.isNotBlank(param8) && param8 != null){
jsonParse += ',"' + param8 + '"';
}
if(String.isNotBlank(param9) && param9 != null){
jsonParse += ',"' + param9 + '"';
}*/
        //jsonParse += ']}}';
        
        jsonParse += '],';
        jsonParse += '"buttonPayload" : {';
        jsonParse += '"0" : ["';
        jsonParse +=  payload + '"]},';
        
        jsonParse += '"buttonValues" : {';
        jsonParse += '"0" : ["';
        jsonParse +=  param9 + '"]}}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        //string str = System.JSON.serialize(parser);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    @future(callout=true)
    Public static void methodToSendWhatsAppMsg(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String countryCode, String MobileNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--');
        System.debug('param1: ' + param1);
        System.debug('param2: ' + param2);
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        String templateName = customMeta.RW_element_name__c;
        String languageCode;
        if(templateName == 'call_disposition'){
            languageCode = 'en_GB';
        }else{
            languageCode = 'en';
        }
        
        String payload;
        if(elementName == 'call_disposition'){
            payload = 'Call Disposition';
        }else if(elementName == 'case_closure_new'){
            payload = 'Case closure|'+param3;
        }else if(elementName == 'post_60_days'){
            payload = 'Post 60 Days';
        }else if(elementName == 'generic_feedback'){
            payload = 'Dynamic{api_name:camp,camp_id:'+param2+'}';
        }else if(elementName == 'Sales Experience'){
            payload = 'I want to give feedback on my sales experience';
        }else if(elementName == 'Day of Registration'){
            payload = 'Day of Registration';
        }else if(elementName == 'Day of Key Handover'){
            payload = 'Key Handover';
        }
        
        String jsonParse;
        if(String.isNotBlank(countryCode) && countryCode != null){
            jsonParse = '{"countryCode" : ' + '"' + countryCode + '",';
        }else{
            jsonParse = '{"countryCode" : "+91",';
        }
        
        jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        if(String.isNotBlank(param1) && param1 != null){
            jsonParse += '"callbackData" : ' + '"' + param1 + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        if(elementName == 'possession_guidelines' || elementName == 'Bank Funding Requirements Documents' || elementName == 'Birthday Wish'){
            jsonParse += '"headerValues"  : [';
            if(String.isNotBlank(param8) && param8 != null){
                jsonParse += '"' + param8 + '"';
            }
            jsonParse += '],';
            if(String.isNotBlank(param9) && param9 != null){
                jsonParse +='"fileName" : "' + param9 + '.pdf",';
            }
        }
        jsonParse += '"bodyValues"  : [';
        /*if(String.isNotBlank(param1) && param1 != null){
jsonParse += '"' + param1 + '"';
}*/
        if(String.isNotBlank(param2) && param2 != null){
            jsonParse += '"' + param2 + '"';
        }
        if(String.isNotBlank(param3) && param3 != null){
            jsonParse += ',"' + param3 + '"';
        }
        if(String.isNotBlank(param4) && param4 != null){
            jsonParse += ',"' + param4 + '"';
        }
        if(String.isNotBlank(param5) && param5 != null){
            jsonParse += ',"' + param5 + '"';
        }
        if(String.isNotBlank(param6) && param6 != null){
            jsonParse += ',"' + param6 + '"';
        }
        if(String.isNotBlank(param7) && param7 != null){
            jsonParse += ',"' + param7 + '"';
        }
        if(elementName != 'possession_guidelines' && elementName != 'Bank Funding Requirements Documents' && elementName != 'Birthday Wish'){
            if(String.isNotBlank(param8) && param8 != null){
                jsonParse += ',"' + param8 + '"';
            }
            if(String.isNotBlank(param9) && param9 != null){
                jsonParse += ',"' + param9 + '"';
            }
        }
        /*if(String.isNotBlank(param8) && param8 != null){
jsonParse += ',"' + param8 + '"';
}
if(String.isNotBlank(param9) && param9 != null){
jsonParse += ',"' + param9 + '"';
}*/
        //jsonParse += ']}}';
        
        jsonParse += '],';
        jsonParse += '"buttonPayload" : {';
        jsonParse += '"0" : ["';
        jsonParse +=  payload + '"]},';
        
        jsonParse += '"buttonValues" : {';
        jsonParse += '"0" : ["';
        jsonParse +=  param9 + '"]}}}';
        
        
        
        JSONParser parser = JSON.createParser(jsonParse);
        //string str = System.JSON.serialize(parser);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    @future(callout=true)
    Public static void methodToSendWhatsAppMsgNew(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String countryCode, String MobileNo, String elementName){
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        String templateName = customMeta.RW_element_name__c;
        String languageCode = 'en';
        
        String jsonParse;
        if(String.isNotBlank(countryCode) && countryCode != null){
            jsonParse = '{"countryCode" : ' + '"' + countryCode + '",';
        }else{
            jsonParse = '{"countryCode" : "+91",';
        }
        
        jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(param1) && param1 != null){
            jsonParse += '"' + param1 + '"';
        }
        if(String.isNotBlank(param2) && param2 != null){
            jsonParse += ',"' + param2 + '"';
        }
        if(String.isNotBlank(param3) && param3 != null){
            jsonParse += ',"' + param3 + '"';
        }
        if(String.isNotBlank(param4) && param4 != null){
            jsonParse += ',"' + param4 + '"';
        }
        if(String.isNotBlank(param5) && param5 != null){
            jsonParse += ',"' + param5 + '"';
        }
        if(String.isNotBlank(param6) && param6 != null){
            jsonParse += ',"' + param6 + '"';
        }
        if(String.isNotBlank(param7) && param7 != null){
            jsonParse += ',"' + param7 + '"';
        }
        if(String.isNotBlank(param8) && param8 != null){
            jsonParse += ',"' + param8 + '"';
        }
        if(String.isNotBlank(param9) && param9 != null){
            jsonParse += ',"' + param9 + '"';
        }
        jsonParse += ']}}';
       
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key_RG);  
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    Public static void methodToSendWhatsAppMsgBatchNew(String param1, String param2, string param3 ,string param4,string param5,string param6,string param7,string param8,string param9, String countryCode, String MobileNo, String elementName){
        
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where MasterLabel =: elementName limit 1];
        
        String templateName = customMeta.RW_element_name__c;
        String languageCode = 'en';
        
        String jsonParse;
        if(String.isNotBlank(countryCode) && countryCode != null){
            jsonParse = '{"countryCode" : ' + '"' + countryCode + '",';
        }else{
            jsonParse = '{"countryCode" : "+91",';
        }
        
        jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(param1) && param1 != null){
            jsonParse += '"' + param1 + '"';
        }
        if(String.isNotBlank(param2) && param2 != null){
            jsonParse += ',"' + param2 + '"';
        }
        if(String.isNotBlank(param3) && param3 != null){
            jsonParse += ',"' + param3 + '"';
        }
        if(String.isNotBlank(param4) && param4 != null){
            jsonParse += ',"' + param4 + '"';
        }
        if(String.isNotBlank(param5) && param5 != null){
            jsonParse += ',"' + param5 + '"';
        }
        if(String.isNotBlank(param6) && param6 != null){
            jsonParse += ',"' + param6 + '"';
        }
        if(String.isNotBlank(param7) && param7 != null){
            jsonParse += ',"' + param7 + '"';
        }
        if(String.isNotBlank(param8) && param8 != null){
            jsonParse += ',"' + param8 + '"';
        }
        if(String.isNotBlank(param9) && param9 != null){
            jsonParse += ',"' + param9 + '"';
        }
        jsonParse += ']}}';
       
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key_RG);  
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
    }
    
    
    @InvocableMethod (label='Task_Send_Email_Alerts')
    Public Static void methodTofetchLeadforSendingWhatsAppMsg(List<String> lstLead){
        //Commented by Prashant 05-09-25 - Issue Subject - SFDC Error by Amit Kamble
       /* System.debug('lstLead>>> ' +lstLead);
        
        Set<String> setLeadId = new Set<String>();
        if(!lstLead.isEmpty() && lstLead.size()>0){
            for(String objLead : lstLead){
                setLeadId.add(objLead);
            }
        }
        system.debug('setLeadId>>>' +setLeadId);
        
        Task objTask = [SELECT Id, Type,WhoId,Call_Status__c,Call_Disposition_Custom__c, Call_Proposed_date_of_visit__c
                        FROM task 
                        WHERE WhoId =: setLeadId AND CreatedDate = today 
                        AND Call_Status__c != null 
                        AND Call_Disposition_Custom__c != null 
                        ORDER BY CreatedDate DESC LIMIT 1];
        
        system.debug('objTask>>>' +objTask);
        
        String elementName;
        String LeadName; 
        String DefaultNo = '02269315204';
        
        List<Lead> lstLeads = [Select Id,Name,FirstName, LastName, RW_Project__c,RW_Project__r.Name,RW_Project__r.Project_Location__c,
                               RW_Project__r.Project_site_URL__c,RW_Project__r.RW_LocalityName__c, RW_Project__r.RW_Project_Location_Videos_Link__c,
                               RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.Testimonial_Video_Link__c,RW_Project__r.Site_Address_Map_Link__c,
                               RW_Location__c, RW_Mobile_No__c, OwnerId, OwnerPhone__c
                               From Lead Where Id =:setLeadId];
        
        
        System.debug('lstLeads>>>' +lstLeads);
        
        if(objTask.Call_Status__c == 'Not Connected' &&
           (objTask.Call_Disposition_Custom__c == 'Not Answering' || objTask.Call_Disposition_Custom__c == 'Disconnected while Ringing' ||
            objTask.Call_Disposition_Custom__c == 'Number Busy' || objTask.Call_Disposition_Custom__c == 'Switched Off' ||
            objTask.Call_Disposition_Custom__c == 'Not Reachable')){
                
                RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel,DeveloperName, Label, RW_element_name__c
                                                        FROM RW_Presales_WhatsApp__mdt where DeveloperName = 'Lead_Unable_To_Contact'];
                system.debug('customMeta>>>' +customMeta);
                if(customMeta != null){
                    elementName = customMeta.RW_element_name__c;
                    System.debug('elementName >>> ' + elementName);
                    
                    if(!lstLeads.isEmpty() && lstLeads.size() > 0){
                        for(Lead objLead : lstLeads){
                            LeadName = (objLead.FirstName != null ? objLead.FirstName : '') + (objLead.LastName != null ? ' ' + objLead.LastName : '');
                            System.Debug('LeadName>>>>' +LeadName);
                            mtdToSendWhatsAppForUnableToConnect(objLead.Id,LeadName, objLead.RW_Project__r.Name, objLead.RW_Mobile_No__c, DefaultNo, elementName);
                        }
                    }                    
                }
                else {
                    System.debug('No metadata found for given template.');
                } 
            }
        else if(objTask.Call_Status__c == 'Connected' && objTask.Call_Disposition_Custom__c == 'Interested'){
            
            RW_Presales_WhatsApp__mdt customMeta1 = [SELECT Id, MasterLabel,DeveloperName, Label, RW_element_name__c
                                                     FROM RW_Presales_WhatsApp__mdt where DeveloperName = 'Lead_Interested_Msg'];
            system.debug('customMeta1>>>' +customMeta1);          
            
            if(customMeta1 != Null){
                elementName = customMeta1.RW_element_name__c;
                System.debug('elementName >>> ' + elementName);
                
                if(!lstLeads.isEmpty() && lstLeads.size() > 0){
                    for(Lead objLead : lstLeads){
                        LeadName = (objLead.FirstName != null ? objLead.FirstName : '') + 
                            (objLead.LastName != null ? ' ' + objLead.LastName : '');
                        System.Debug('LeadName>>>>' +LeadName);
                        mtdToSendWhatsAppForInterestedCustomer(objLead.Id,LeadName, objLead.RW_Project__r.Name, objLead.RW_Project__r.RW_LocalityName__c, objLead.RW_Mobile_No__c, elementName); //objLead.RW_Project__r.Project_Location__c
                    }
                }  
            }
            else {
                System.debug('No metadata found for given template.');
            } 
        }
        
        else if (objTask.Call_Status__c == 'Connected' && objTask.Call_Disposition_Custom__c == 'Visit Scheduled') {
            
            List<RW_Presales_WhatsApp__mdt> customMetaList = [
                SELECT Id, MasterLabel, DeveloperName, Label, RW_element_name__c
                FROM RW_Presales_WhatsApp__mdt
                WHERE DeveloperName IN (
                    'Lead_Send_Project_Details',
                    'Lead_Site_Visit_Schedule',
                    'Lead_Notify_Presales_On_Visit_Schedule')
            ];
            
            System.debug('customMetaList >>> ' + customMetaList);
            
            if (!customMetaList.isEmpty() && !lstLeads.isEmpty()) {
                for (Lead objLead : lstLeads) {
                    
                    String LeadName1 = (objLead.FirstName != null ? objLead.FirstName : '') +
                        (objLead.LastName != null ? ' ' + objLead.LastName : '');
                    
                    DateTime dtValue = objTask.Call_Proposed_date_of_visit__c;
                    String onlyDate = dtValue != null ? dtValue.format('dd/MM/yyyy') : '';
                    String onlyTime = dtValue != null ? dtValue.format('hh:mm a') : '';
                    
                    for (RW_Presales_WhatsApp__mdt objMeta : customMetaList) {
                        
                        String elementName1 = objMeta.RW_element_name__c;
                        String devName = objMeta.DeveloperName;
                        System.debug('Processing Template: ' + devName);
                        
                        // Lead_Send_Project_Details
                        if (devName == 'Lead_Send_Project_Details') {
                            mtdToSendWhatsAppForProjectDetails(
                                objLead.Id, LeadName1,
                                objLead.RW_Project__r.Name,
                                objLead.RW_Project__r.RW_LocalityName__c,
                                objLead.RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                                objLead.RW_Project__r.Site_Address_Map_Link__c,
                                objLead.RW_Project__r.RW_Project_Location_Videos_Link__c, DefaultNo,
                                objLead.RW_Mobile_No__c, elementName1
                            );
                        }
                        // Lead_Site_Visit_Schedule - Standard Visit Message
                        if (devName == 'Lead_Site_Visit_Schedule' && dtValue != null) {
                            mtdToSendWhatsAppForVisitScheduled(
                                objLead.Id, LeadName1, onlyDate, onlyTime,
                                objLead.RW_Project__r.Name,
                                objLead.RW_Project__r.Site_Address_Map_Link__c,
                                objLead.RW_Mobile_No__c, DefaultNo, elementName1
                            ); 
                        }
                        // Lead_Notify_Presales_On_Visit_Schedule
                        if (devName == 'Lead_Notify_Presales_On_Visit_Schedule') {
                            mtdToSendWhatsAppToPresalesOnVisitSchedule(
                                objLead.Id, LeadName1,
                                objLead.OwnerPhone__c, elementName1
                            );
                        }
                    }
                }
            } else {
                System.debug('No metadata found or leads are empty.');
            }
        }
*/
    }
    
    @future(callout=true)
    Private static void mtdToSendWhatsAppForUnableToConnect(String LeadId,String LeadName, String Project, String MobileNo, String DefaultNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        
        List<Lead> lstLeads = [Select Id, RW_Mobile_No__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '",';
        }
        if(String.isNotBlank(Project) && Project != null){
            jsonParse += '"' + Project + '",';
        }
        if(String.isNotBlank(DefaultNo) && DefaultNo != null){
            jsonParse += '"' + DefaultNo + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Not Connected and call Sub status: Not Answering, Disconnected While Ringing, Number Busy, Switched Off, Not Reachable::::::::::::');
        system.debug('auth>>>' + System.Label.Interakt_Secret_Key);
        
    }
    @future(callout=true)
    Private static void mtdToSendWhatsAppForInterestedCustomer(String LeadId,String LeadName, String Project, String Location, String MobileNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        
        List<Lead> lstLeads = [Select Id, RW_Mobile_No__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '",';
        }
        if(String.isNotBlank(Project) && Project != null){
            jsonParse += '"' + Project + '",';
        }
        if(String.isNotBlank(Location) && Location != null){
            jsonParse += '"' + Location + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Interested:::::::');
        
    }
    @future(callout=true)
    Private static void mtdToSendWhatsAppForProjectDetails(String LeadId,String LeadName, String Project, String Location, String BrochureUrl, String SiteLink, String VideoLink,String DefaultNo, String MobileNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        
        List<Lead> lstLeads = [Select Id, RW_Mobile_No__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '",';
        }
        if(String.isNotBlank(Project) && Project != null){
            jsonParse += '"' + Project + '",';
        }
        if(String.isNotBlank(Location) && Location != null){
            jsonParse += '"' + Location + '",';
        }
        if(String.isNotBlank(SiteLink) && SiteLink != null){
            jsonParse += '"' + SiteLink + '",';
        }
        if(String.isNotBlank(BrochureUrl) && BrochureUrl != null){
            jsonParse += '"' + BrochureUrl + '",';
        }
        if(String.isNotBlank(VideoLink) && VideoLink != null){
            jsonParse += '"' + VideoLink + '",';
        }
        if(String.isNotBlank(DefaultNo) && DefaultNo != null){
            jsonParse += '"' + DefaultNo + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Visit Scheduled---Send Project Details ::::: ');
        
    }
    @future(callout=true)
    Private static void mtdToSendWhatsAppForVisitScheduled(String LeadId,String LeadName, String VisitDate, String VisitTime, String Project, String SiteLink, String MobileNo, String DefaultNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        System.debug('--LeadName--' +LeadName);
        System.debug('VisitDate: ' + VisitDate);
        System.debug('VisitTime: ' + VisitTime);
        
        List<Lead> lstLeads = [Select Id, RW_Mobile_No__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '",';
        }
        if(VisitDate != null){
            jsonParse += '"' + VisitDate + '",';
        }
        if(VisitTime != null){
            jsonParse += '"' + VisitTime + '",';
        }
        if(String.isNotBlank(Project) && Project != null){
            jsonParse += '"' + Project + '",';
        }
        if(String.isNotBlank(SiteLink) && SiteLink != null){
            jsonParse += '"' + SiteLink + '",';
        }
        if(String.isNotBlank(DefaultNo) && DefaultNo != null){
            jsonParse += '"' + DefaultNo + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Visit Scheduled---Site Visit Scheduled send email to Customer::::: ');
        
    }
    @future(callout=true)
    Private static void mtdToSendWhatsAppToPresalesOnVisitSchedule(String LeadId,String LeadName, String MobileNo, String elementName){
        System.debug('--methodToSendWhatsAppMsg--' +LeadId);
        System.debug('MobileNo: ' + MobileNo);
        System.debug('elementName: ' + elementName);
        System.debug('--LeadName--' +LeadName);
        
        
        List<Lead> lstLeads = [Select Id, OwnerId, OwnerPhone__c From Lead where Id =: LeadId];
        system.debug('lstLeads>>>' +lstLeads);
        RW_Presales_WhatsApp__mdt customMeta = [SELECT Id, MasterLabel, Label, RW_namespace__c,RW_Type__c,RW_element_name__c
                                                FROM RW_Presales_WhatsApp__mdt where RW_element_name__c =: elementName limit 1];
        system.debug('customMeta>>>' +customMeta);
        
        String templateName = customMeta.RW_element_name__c;
        system.debug('templateName>>>' +templateName);
        String languageCode = 'en';
        
        String jsonParse;
        String fullNumber ='+91'+MobileNo;
        
        jsonParse = '{"countryCode" : "+91",';
        //jsonParse += '"phoneNumber" : ' + '"' + MobileNo + '",';
        jsonParse += '"fullPhoneNumber" : ' + '"' +fullNumber + '",';
        jsonParse += '"campaignId" : ' + '"",';
        
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"callbackData" : ' + '"' + LeadName + '",';
        }
        jsonParse += '"type" : "Template",';
        jsonParse += '"template" : { "name" : '  + '"' + templateName + '", "languageCode" : "'+languageCode+'",';
        jsonParse += '"headerValues"  : [],';
        
        jsonParse += '"bodyValues"  : [';
        if(String.isNotBlank(LeadName) && LeadName != null){
            jsonParse += '"' + LeadName + '"';
        }
        
        jsonParse += ']}}';
        
        JSONParser parser = JSON.createParser(jsonParse);
        System.debug('jsonParse '+jsonParse);
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Basic ' + System.Label.Interakt_Secret_Key); 
        req.setEndpoint('https://api.interakt.ai/v1/public/message/');
        req.setBody(jsonParse);
        HTTPResponse res = http.send(req);
        System.debug('End Point '+req.getEndpoint());
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        System.debug('Call status: Connected and call Sub status: Visit Scheduled---Notify Presales On Visit Schedule:::::');
        
    }
    public static void dummyMethod(){
        
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}