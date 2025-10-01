public class SendWhatsAppMsgForBatch {
    
   Public static void genaricMethodToSendWhatsAppMsgForBatch(Id LeadId,String elementName){
       
      //param1, String param2, string param3 ,string param4,string param5,string param6,string param7, String MobileNo, String elementName  
     Lead led = [SELECT Id,Email,Name,RW_Project__c,Project_Name__c,LeadSource,RW_Project__r.RW_Project_Brochure_ID__c,RW_Project__r.RW_LocalityName__c,	
                     RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,	
                     RW_Project__r.Site_Address_Map_Link__c,RW_Mobile_No__c FROM Lead Where ID =: LeadId];
    	
        String Signature;
        String ContactNumber;
        if(String.isNotBlank(led.LeadSource)){
            if(led.LeadSource == 'Channel Partner'){
                Signature = System.Label.RW_CPSignature;
                ContactNumber = System.Label.RW_CPContactNumber;
            }else if(led.LeadSource != 'Channel Partner'){
                Signature = System.Label.RW_NotCPSignature;
                ContactNumber = System.Label.RW_NotCPContactNumber;
            }
        }    

                 
        
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
        
        if(String.isNotBlank(led.Name) || String.isNotBlank(led.Project_Name__c) ||
           String.isNotBlank(led.RW_Project__r.RW_LocalityName__c) || String.isNotBlank(led.RW_Project__r.Site_Address_Map_Link__c) || 
           String.isNotBlank(led.RW_Project__r.RW_Project_Brochure_PublicUrl__c) || String.isNotBlank(led.RW_Project__r.RW_Project_Location_Videos_Link__c) ||
           String.isNotBlank(System.Label.Website_URL) || String.isNotBlank(ContactNumber) || String.isNotBlank(Signature)) {
               
            //jsonParse += ',"localizable_params": [';
            jsonParse += ',"components": [{"type": "body",';
            jsonParse += '"parameters": [';
               if(String.isNotBlank(led.Name)){
                   //jsonParse += '{"default": "'+led.Name+'"}'; 
                   jsonParse += '{"type": "text"';  
                   jsonParse += ',"text": "'+led.Name+'"}';
                }
               if(String.isNotBlank(led.Project_Name__c)){
                   //jsonParse += ',{"default": "'+led.Project_Name__c+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+led.Project_Name__c+'"}';
               }
               if(String.isNotBlank(led.RW_Project__r.RW_LocalityName__c)){
                   //jsonParse += ',{"default": "'+led.RW_Project__r.RW_LocalityName__c+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+led.RW_Project__r.RW_LocalityName__c+'"}';
               }
               if(String.isNotBlank(led.RW_Project__r.Site_Address_Map_Link__c)){
                   //jsonParse += ',{"default": "'+led.RW_Project__r.Site_Address_Map_Link__c+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+led.RW_Project__r.Site_Address_Map_Link__c+'"}';
               }
               if(String.isNotBlank(led.RW_Project__r.RW_Project_Brochure_PublicUrl__c)){
                   //jsonParse += ',{"default": "'+led.RW_Project__r.RW_Project_Brochure_PublicUrl__c+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+led.RW_Project__r.RW_Project_Brochure_PublicUrl__c+'"}';
               }
               if(String.isNotBlank(led.RW_Project__r.RW_Project_Location_Videos_Link__c)){
                   //jsonParse += ',{"default": "'+led.RW_Project__r.RW_Project_Location_Videos_Link__c+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+led.RW_Project__r.RW_Project_Location_Videos_Link__c+'"}';
               }
               if(String.isNotBlank(System.Label.Website_URL)){
                   //jsonParse += ',{"default": "'+System.Label.Website_URL+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+System.Label.Website_URL+'"}';
               }
               if(String.isNotBlank(ContactNumber)){
                   //jsonParse += ',{"default": "'+ContactNumber+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+ContactNumber+'"}';
               }
               if(String.isNotBlank(Signature)){
                   //jsonParse += ',{"default": "'+Signature+'"}';
                   jsonParse += ',{"type": "text"';  
                   jsonParse += ',"text": "'+Signature+'"}';
               }
               jsonParse += ']';
           }
        	jsonParse +=  '}]';
           jsonParse +=  '}';
        
        system.debug('______40jsonParse  '+jsonParse);
        
      	WhatsAppWrapper whatsAppWrp  = new WhatsAppWrapper();
        whatsAppWrp.business_id = 2492;
        whatsAppWrp.to = led.RW_Mobile_No__c;
        //whatsAppWrp.type_Z = 'hsm';
       	whatsAppWrp.type_Z = 'template';
        JSONParser parser = JSON.createParser(jsonParse);
        WhatsAppWrapper.Template templateBody = new WhatsAppWrapper.Template(parser);
        whatsAppWrp.template = templateBody;
        list<WhatsAppWrapper.Components> localParamList = new  list<WhatsAppWrapper.Components>();
       
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


}