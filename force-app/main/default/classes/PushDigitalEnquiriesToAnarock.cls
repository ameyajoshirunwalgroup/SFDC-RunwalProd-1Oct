public class PushDigitalEnquiriesToAnarock implements Queueable, database.allowscallouts {
        public List < Task > enquiryList;
        public PushDigitalEnquiriesToAnarock(List < Task > tskList) {
                this.enquiryList = tskList;
        }
        public void execute(QueueableContext qc) {
                system.debug('inside execute Method enquiry List::' + enquiryList);
                List < Anarock_Integration_Log__c > logList = new List < Anarock_Integration_Log__c > ();
                // Query metadata for endpoint and API key.
                Anarock_Credential__mdt anarockSetting = new Anarock_Credential__mdt();
                anarockSetting = [Select MasterLabel, API_Key__c, Channel_Name__c, Endpoint__c from Anarock_Credential__mdt where QualifiedApiName = 'Credentials'];
                // Fetch all custom setting data for diallingCode-CountryCode Mapping
                Map<String,AnarockdialingandCountryCodes__c> dailingCountryMap = AnarockdialingandCountryCodes__c.getAll();
                System.debug('dailingCountryMap::'+dailingCountryMap);
                for (Task t: enquiryList) {
                        String exceptionMsg = '';
                        Boolean callOutError = false;

                        if (t.FullName__c == null) t.FullName__c = '';
                        if (t.Mobile_Number_Webform__c == null) t.Mobile_Number_Webform__c = '';
                        if (t.dialingCode__c == null) t.dialingCode__c = '';
                        if (t.emailAddress__c == null) t.emailAddress__c = '';
                        if (t.description == null) t.description = '';
                        if (t.Source_of_enquiry__c == null) t.Source_of_enquiry__c = '';
                        if (t.Sub_source_of_enquiry__c == null) t.Sub_source_of_enquiry__c = '';
                        if (t.Budget_WebForm__c == null) t.Budget_WebForm__c = '';
                        if (t.Configuration__c == null) t.Configuration__c = '';

                        Datetime gmt = Datetime.Now();
                        Long currentTime = gmt.getTime() / 1000;
                        string privateKey = anarockSetting.API_Key__c;
                        system.debug('current time:' + currentTime);
                        Blob secret = crypto.generateMac('HmacSHA256', Blob.valueOf(String.valueOf(currentTime)), blob.valueOf(privateKey));
                        String tempHash = EncodingUtil.convertToHex(secret);
                        System.debug('hash key::' + tempHash);

                        DateTime contactDate = t.CreatedDate;
                        Long CDate = contactDate.getTime() / 1000;
                        system.debug('contact Date in epoch::' + cdate);
                        String countryCode = '';
                        if(t.dialingCode__c != '' && dailingCountryMap.containsKey(t.dialingCode__c)) {
                            countryCode = dailingCountryMap.get(t.dialingCode__c).country_Code__c;
                        }
                        else 
                            countryCode = t.dialingCode__c;
                            
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        gen.writeStringField('name', t.FullName__c);
                        gen.writeStringField('phone', t.Mobile_Number_Webform__c);
                        gen.writeStringField('country_code', countryCode);
                        gen.writeStringField('email', t.emailAddress__c);
                        gen.writeStringField('purpose', 'buy');
                        gen.writeNumberField('current_time', currentTime);
                        gen.writeStringField('hash', tempHash);
                        gen.writeStringField('max_budget', t.Budget_WebForm__c);
                        gen.writeStringField('campaign_id', t.Project__r.Anarock_Campaign_Id__c);
                        gen.writeStringField('listing_name', t.Project__r.Name);
                        gen.writeNumberField('contact_date', CDate);
                        gen.writeStringField('remarks', t.description);
                        gen.writeStringField('source', t.Source_of_enquiry__c);
                        gen.writeStringField('sub_source', t.Sub_source_of_enquiry__c);
                        gen.writeStringField('apartment_types', t.Configuration__c);
                        gen.writeEndObject();

                        String pretty = gen.getAsString();
                        System.debug('Formatted json Request::' + pretty);
                        Http httpProtocol = new Http();
                        HttpRequest request = new HttpRequest();
                        request.setMethod('POST');
                        request.setHeader('content-type', 'application/json; charset=utf-8');
                        request.setEndPoint(anarockSetting.Endpoint__c);
                        request.setBody(pretty);
                        ResponseLog resLog = new ResponseLog();

                        try {
                                if (!Test.isRunningTest()) {
                                        HttpResponse response = httpProtocol.send(request);
                                        System.debug('Response:' + response.getBody());
                                        System.debug('Response:' + response);
                                        resLog = resLog.parse(response.getBody());
                                }
                                if (resLog != null && resLog.status != null && !resLog.status.equalsIgnorecase('OK')) {
                                        callOutError = true;
                                        exceptionMsg = resLog.message;
                                }

                        } catch (Exception ex) {
                                System.debug('Exception:' + ex.getMessage());
                                callOutError = true;
                                exceptionMsg = ex.getMessage();
                        }
                        Finally {
                                Anarock_Integration_Log__c log = new Anarock_Integration_Log__c();
                                pretty = pretty.replaceAll('\n', '<br/>');
                                pretty = pretty.replaceAll('\t', '&nbsp;');
                                log.request__c = pretty;
                                String responseF = JSON.SerializePretty(resLog);
                                responseF = responseF.replaceAll('\n', '<br/>');
                                responseF = responseF.replaceAll('\t', '&nbsp;');
                                System.debug('Formatted Response::' + responseF);
                                log.response__c = responseF;
                                if (t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead')
                                        log.Lead__c = t.whoId;
                                else if (t.whatId != null && t.whatId.getSObjectType().getDescribe().getName() == 'Account')
                                        log.Account__c = t.WhatId;
                                if (!callOutError)
                                        log.Status__c = 'Success';
                                else {
                                        log.Status__c = 'Failure';
                                        log.Error_Reason__c = exceptionMsg;
                                }
                                if(t.Project__c != null)
                                    log.Project__c = t.Project__c;
                                if(t.Source_of_enquiry__c != null)
                                    log.Source__c = t.Source_of_enquiry__c;
                                if(t.Sub_source_of_enquiry__c != null)
                                    log.Sub_Source__c = t.Sub_source_of_enquiry__c;
                                logList.add(log);
                        }

                }
                if (!logList.isEmpty())
                        insert logList;

        }
        public static void checkPrerequisiteforCallout(Set < Id > enqIds) {
                system.debug('inside check prerequisite Method::' + enqIds);
                List < Task > anarockQualifiedLeads = new List < Task > ();
                if (!enqIds.isEmpty()) {
                        anarockQualifiedLeads = [Select Id, whoId, WhatId, task_type__c, Status, FullName__c, emailAddress__c, country__c, dialingCode__c,
                                Mobile_Number_Webform__c, Source_of_enquiry__c, Sub_source_of_enquiry__c, Budget_WebForm__c, Configuration__c,
                                Project__c, Project__r.Send_Digital_data_to_Anarock__c, Project__r.Anarock_Campaign_Id__c, CreatedDate,
                                UTM_Campaign__c, UTM_Display__c, UTM_Medium__c, description, UTM_Source__c, UTM_Term__c, Project__r.Name
                                from Task where Id IN: enqIds
                                and Project__c != null
                                and Project__r.Send_Digital_data_to_Anarock__c = true
                        ];

                        system.debug('all anarock QualifiedLeadList::' + anarockQualifiedLeads);

                        if (!anarockQualifiedLeads.isEmpty() && anarockQualifiedLeads.size() > 0) {
                                system.debug('All anarock QualifiedLeadList size::' + anarockQualifiedLeads.size());
                                // Calling out Anarock API for all qualified leads.
                                System.enqueueJob(new PushDigitalEnquiriesToAnarock(anarockQualifiedLeads));
                        } else {
                                system.debug('No enquiries qualified for Anarock Callout');
                        }
                }

        }

        public class ResponseLog {
                public String status;
                public String message;
                public Response response;
                public List < Errors > errors;

                public ResponseLog parse(String json) {
                        return (ResponseLog) System.JSON.deserialize(json, ResponseLog.class);
                }
        }
        public class Response {
                public Integer lead_id;
                public Integer inquiries_count;
                public Integer last_inquiry_id;
        }
        public class Errors {
                public String message;
        }

}