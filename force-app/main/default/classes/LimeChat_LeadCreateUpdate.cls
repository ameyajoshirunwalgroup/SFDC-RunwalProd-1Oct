@RestResource(urlMapping='/limeChatLead/*')
global class LimeChat_LeadCreateUpdate {

    /*@HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String leadType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, Object> errorResult = new Map<String, Object>();
        Map<String, Object> successResult = new Map<String, Object>();
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        LeadDetails data = (LeadDetails)JSON.deserialize(jsonBody, LeadDetails.class);
        try{
            if(leadType == 'new'){
                Lead ld = new Lead();
                ld.FirstName = data.firstName;
                ld.LastName = data.lastName;
                ld.RW_Mobile_No__c = data.mobile;
                insert ld;
                successResult.put('status', 'success');
                successResult.put('message', 'Lead record created successfully: ' + ld.Id);
                res.responseBody = Blob.valueOf(JSON.serialize(successResult));
                //res.responseBody = Blob.valueOf('Lead record created successfully: ' + ld.Id);
                res.statusCode = 200;
            }else if(leadType == 'update'){
                Lead lead = new Lead();
                List<Lead> leadList = [SELECT Id FROM Lead WHERE RW_Mobile_No__c =: data.mobile];
                if(leadList.size() > 0){
                    if(data.project != null && data.project.startsWith('a00') 
                    for(Lead ld : leadList){
                        if(data.project != null && data.project.startsWith('a00') && ld.RW_Project__c = data.project){
                            lead = ld;
                        }
                    }
                }
                
                
                if(data.salutation != null)
                    ld.Salutation = data.salutation;
                if(data.firstName != null)
                    ld.FirstName = data.firstName;
                if(data.lastName != null)
                    ld.LastName = data.lastName;
                if(data.project != null && data.project.startsWith('a00')){
                    ld.RW_Project__c = data.project;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Please pass valid project Id');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                    return;
                }
                if(data.countryCode != null)
                    ld.RDS_Country_Code__c = data.countryCode;
                if(data.mobile != null)
                    ld.RW_Mobile_No__c = data.mobile;
                if(data.typeOfClient != null)
                	ld.Client_Type__c = data.typeOfClient;
                if(data.state != null)
                	ld.State__c = data.state;
                if(data.city != null)
                	ld.City__c = data.city;
                if(data.zip != null)
                	ld.Zip_Code__c = data.zip;
                if(data.budget != null)
                    ld.RW_Budget__c = data.budget;
                if(data.configuration != null)
                    ld.RW_Configuration__c = data.configuration;
                if(data.location != null)
                    ld.RW_Location__c = data.location;
                update ld;
                
                successResult.put('status', 'success');
                successResult.put('message', 'Lead record updated successfully: ' + ld.Id);
                res.responseBody = Blob.valueOf(JSON.serialize(successResult));
                //res.responseBody = Blob.valueOf('Lead record updated successfully: ' + ld.Id);
                res.statusCode = 200;
            }
        }catch(exception e){
            String error;
            if (e.getMessage() != null && e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                error = ((e.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
                error = error.split('\\.')[0];
                errorResult.put('message', error);
            }else{
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            }
            errorResult.put('status', 'error');
            //errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }*/
                       
                       
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String leadType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, Object> errorResult = new Map<String, Object>();
        Map<String, Object> successResult = new Map<String, Object>();
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        try{
            if(leadType == 'new'){
                LeadCreateDetails data = (LeadCreateDetails)JSON.deserialize(jsonBody, LeadCreateDetails.class);
                List<Lead> leadList = [SELECT Id FROM Lead WHERE RW_Mobile_No__c =: data.phone_number];
                if(leadList.size() == 0){
                    Lead lead = new Lead();
                    lead.LastName = data.wa_display_name;
                    lead.RW_Mobile_No__c = data.phone_number;
                    lead.WhatsApp_Lead_Status__c = data.lead_status;
                    lead.WhatsApp_Lead_Stage__c = data.lead_stage;
                    lead.WhatsApp_Lead_LimeChat__c = true;
                    insert lead;
                    successResult.put('status', 'success');
                    successResult.put('message', 'Lead record created successfully: ' + lead.Id);
                    res.responseBody = Blob.valueOf(JSON.serialize(successResult));
                    //res.responseBody = Blob.valueOf('Lead record updated successfully: ' + ld.Id);
                    res.statusCode = 200;
                }else{
                    RW_Presales_Communication__c preSalesComm = new RW_Presales_Communication__c();
                    preSalesComm.RW_Lead__c = leadList[0].Id;
                    insert preSalesComm;
                    
                    Task t = new Task();
                    t.WhoId = leadList[0].Id;
                    t.status = 'Completed';
                    t.task_type__c = 'Enquiry Received';
                    t.Subject = 'New Enquiry Received From: WhatsApp';
                    t.FullName__c = leadList[0].LastName;
                    insert t;
                }
            }else if(leadType == 'update'){
                LeadUpdateDetails data = (LeadUpdateDetails)JSON.deserialize(jsonBody, LeadUpdateDetails.class);
                Lead lead = new Lead();
                List<Lead> leadList = [SELECT Id,RW_Project__c,WhatsApp_Lead_LimeChat__c,Salutation,LastName,RDS_Country_Code__c,Client_Type__c,
                                       State__c,City__c,Zip_Code__c,RW_Budget__c,RW_Configuration__c,RW_Location__c,WhatsApp_Lead_Status__c,
                                       WhatsApp_Qualification_Tag__c,WhatsApp_Unqualification_Reason__c,WhatsApp_Drop_Off_Stage__c,
                                       WhatsApp_Drop_Off_Timestamp__c,WhatsApp_Resume_Timestamp__c FROM Lead WHERE RW_Mobile_No__c =: data.phone_number];
                if(leadList.size() > 0){
                    for(Lead ld : leadList){
                        if(!String.isBlank(data.project) && ld.RW_Project__c == data.project && ld.WhatsApp_Lead_LimeChat__c){
                            lead = ld;
                            continue; 
                        }else if(!String.isBlank(data.project) && ld.RW_Project__c == data.project){
                            lead = ld;
                            continue; 
                        }
                    }
                    if(lead.Id == null){
                        lead = leadList[0];
                    }
                    mapLeadFields(data, lead);
                    update lead;
                    successResult.put('status', 'success');
                    successResult.put('message', 'Lead record updated successfully: ' + lead.Id);
                    res.responseBody = Blob.valueOf(JSON.serialize(successResult));
                    //res.responseBody = Blob.valueOf('Lead record updated successfully: ' + ld.Id);
                    res.statusCode = 200;
                }else{
                    Lead ld = new Lead();
                    mapLeadFields(data, ld);
                    insert ld;
                    successResult.put('status', 'success');
                    successResult.put('message', 'Lead record created successfully: ' + ld.Id);
                    res.responseBody = Blob.valueOf(JSON.serialize(successResult));
                    //res.responseBody = Blob.valueOf('Lead record updated successfully: ' + ld.Id);
                    res.statusCode = 200;
                }
            }
        }catch(exception e){
            String error;
            if (e.getMessage() != null && e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                error = ((e.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
                error = error.split('\\.')[0];
                errorResult.put('message', error);
            }else{
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            }
            errorResult.put('status', 'error');
            //errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    public static void mapLeadFields(LeadUpdateDetails data, Lead lead){
        lead.RW_Mobile_No__c = data.phone_number;
        lead.Salutation = (data.salutation != null)? data.salutation : lead.Salutation;
        lead.LastName = (data.wa_display_name != null)? data.wa_display_name : lead.LastName;
        lead.RW_Project__c = (data.project != null && data.project.startsWith('a00'))? data.project : lead.RW_Project__c;
        lead.RDS_Country_Code__c = (data.country_code != null)? data.country_code : lead.RDS_Country_Code__c;
        lead.Client_Type__c = (data.type_of_client != null)? data.type_of_client : lead.Client_Type__c;
        lead.State__c = (data.state != null)? data.state : lead.State__c;
        lead.City__c = (data.city != null)? data.city : lead.City__c;
        lead.Zip_Code__c = (data.zip != null)? data.zip : lead.Zip_Code__c;
        lead.RW_Budget__c = (data.budget != null)? data.budget : lead.RW_Budget__c;
        lead.RW_Configuration__c = (data.configuration != null)? data.configuration : lead.RW_Configuration__c;
        lead.RW_Location__c = (data.location != null)? data.location : lead.RW_Location__c;
        lead.WhatsApp_Lead_Status__c = (data.lead_status != null)? data.lead_status : lead.WhatsApp_Lead_Status__c;
        lead.WhatsApp_Qualification_Tag__c = (data.qualification_tag != null)? data.qualification_tag : lead.WhatsApp_Qualification_Tag__c;
        lead.WhatsApp_Unqualification_Reason__c = (data.unqualification_reason != null)? data.unqualification_reason : lead.WhatsApp_Unqualification_Reason__c;
        lead.WhatsApp_Drop_Off_Stage__c = (data.drop_off_stage != null)? data.drop_off_stage : lead.WhatsApp_Drop_Off_Stage__c;
        lead.WhatsApp_Drop_Off_Timestamp__c = (data.drop_off_timestamp != null)? data.drop_off_timestamp : lead.WhatsApp_Drop_Off_Timestamp__c;
        lead.WhatsApp_Resume_Timestamp__c = (data.resume_timestamp != null)? data.resume_timestamp : lead.WhatsApp_Resume_Timestamp__c;
    }
    
    global class LeadCreateDetails{
        public String phone_number;
        public String wa_display_name;
        public String lead_status ;
        public String lead_stage ;
        public String entry_timestamp;
    }
    
    global class LeadUpdateDetails{
        public String salutation;
        public String wa_display_name;
        public String project;
        public String email;
        public String country_code;
        public String phone_number;
        public String type_of_client;
        public String state;
        public String city;
        public String zip;
        public String budget;
        public String configuration;
        public String location;
        public String lead_status;
        public String qualification_tag;
        public String unqualification_reason;
        public String drop_off_stage;
        public String drop_off_timestamp;
        public String resume_timestamp;
    }
}