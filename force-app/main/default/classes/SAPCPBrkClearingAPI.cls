global class SAPCPBrkClearingAPI implements Queueable, Database.AllowsCallouts {
        
    // Get Clearing Doc Number & Date and update the same in the invoice.
    global void execute(QueueableContext qc) {

        String sapResponse = '';
        String errorMessage = ''; 
        List<String> successRecordIds = new List<String>(); 
        
        List<ERP_Integration_Log__c> apiloglist = new List<ERP_Integration_Log__c>();
        
        try {
            String username = System.label.SAP_Username;
            String password = System.label.SAP_Password;
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            String endpoint = System.label.SAP_CP_ladder_Inv_Payment;

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');

             Http http = new Http();
             HttpResponse response = http.send(req);

            //HttpResponse response = new HttpResponse();
            //response.setStatusCode(200);
            
            //response.setBody('[{"DOC_NO": "0190000032", "CLEARING_DOC_NO": "1622722", "CLEARING_DATE": "2026-03-23"},{"DOC_NO": "0190000003", "CLEARING_DOC_NO": "367838", "CLEARING_DATE": "2026-03-24"}]');

            sapResponse = response.getBody();
            
            if (response.getStatusCode() != 200) {
                errorMessage = 'SAP Callout Failed. Status Code: ' + response.getStatusCode();
                
                ERP_Integration_Log__c apiLog = new ERP_Integration_Log__c();
                apiLog.API_Name__c = 'CP Brokerage Clearing API';
                apiLog.Status__c = 'Failure';
                apiLog.Response__c = sapResponse.left(131072); // Keeps full response for full crashes
                apiLog.Error_Reason__c = errorMessage.left(255);
                apiLog.Error_Type__c = 'Timeout Error';
                apiloglist.add(apiLog);
                
                insert apiloglist;
                sendErrorEmail(errorMessage, sapResponse, successRecordIds, 'Timeout Error');
                return;
            }

            if (String.isBlank(sapResponse) || sapResponse.contains('No data found')) {
                System.debug('No data received from SAP.');
                return;
            }
            
            if (response.getStatusCode() == 200 && response.getBody() != '[{"ERROR_LOG":"No data found!"}]') {
                 List<RespData> resp = (List<RespData>) JSON.deserialize(sapResponse, List<RespData>.class);
                
                if (resp == null || resp.isEmpty()) {
                    System.debug('Empty response list received from SAP.');
                    return;
                }
                list<String> sapDocList = new list<String>();
                Map<String, RespData> sapDocNoVsResp = new Map<String, RespData>();
                for (RespData r : resp) {
                    if (String.isNotBlank(r.DOC_NO) && 
                        String.isNotBlank(r.BUKRS) && 
                        String.isNotBlank(r.INV_DT) && 
                        String.isNotBlank(r.INV_NO)) {
                            //Added a key with a combination of document number,company code,inv date, inv number..../// Changed on 24-03-26..
                                sapDocList.add(r.DOC_NO);
                                sapDocNoVsResp.put(r.DOC_NO + '-' + r.BUKRS + '-' + r.INV_DT + '-' + r.INV_NO, r);
                        }
                }
                
                if (!sapDocList.isEmpty()) {                
                    List<CP_Brokerage__c> cpbList = [SELECT Id, SAP_Document_No__c, SAP_Document_Date__c,SAP_Clearing_No__c,SAP_Clearing_Date__c,Invoice_Number__c,Invoice_Date__c,Legal_Entity__r.RDS_Company_Code__c FROM CP_Brokerage__c WHERE SAP_Document_No__c IN :sapDocList];
                    
                    if (!cpbList.isEmpty() && !sapDocNoVsResp.isEmpty()) {            
                        
                        List<CP_Brokerage__c> recordsToUpdate = new List<CP_Brokerage__c>();

                        for (CP_Brokerage__c cpb : cpbList) {
                            String invDateStr = '';
                            if (cpb.Invoice_Date__c != null) {
                                Datetime dt = Datetime.newInstance(cpb.Invoice_Date__c.year(), cpb.Invoice_Date__c.month(), cpb.Invoice_Date__c.day());
                                invDateStr = dt.format('yyyy-MM-dd');
                            }
                            
                            RespData sapData = sapDocNoVsResp.get(cpb.SAP_Document_No__c + '-' + cpb.Legal_Entity__r.RDS_Company_Code__c + '-' + invDateStr + '-' + cpb.Invoice_Number__c);
                            system.debug('sapData -> '+sapData);
                            system.debug('cpb -> '+cpb);
                            
                            if (sapData != null && String.isNotBlank(sapData.CLEARING_DATE) && String.isNotBlank(sapData.CLEARING_DOC_NO)) {
                                try {
                                    if(cpb.SAP_Clearing_No__c == null) {
                                        cpb.SAP_Clearing_Date__c = Date.valueOf(sapData.CLEARING_DATE);
                                        cpb.SAP_Clearing_No__c = sapData.CLEARING_DOC_NO;
                                        
                                        recordsToUpdate.add(cpb);
                                    }
                                } catch (Exception e) {
                                    ERP_Integration_Log__c apiLog = new ERP_Integration_Log__c();
                                    apiLog.API_Name__c = 'CP Brokerage Clearing API';
                                    apiLog.Status__c = 'Failure';
                                    apiLog.Response__c = JSON.serialize(sapData); 
                                    apiLog.Error_Reason__c = ('Date Format Error: ' + e.getMessage()).left(255);
                                    apiLog.Error_Type__c = 'Data Error';
                                    apiLog.CP_Brokerage_Invoices__c = cpb.Id;
                                    apiloglist.add(apiLog);
                                    
                                    errorMessage += 'Record ' + cpb.Id + ' Failed: ' + e.getMessage() + '<br/>';
                                }
                            } else {
                                ERP_Integration_Log__c apiLog = new ERP_Integration_Log__c();
                                apiLog.API_Name__c = 'CP Brokerage Clearing API';
                                apiLog.Status__c = 'Error';
                                apiLog.Response__c = (sapData != null) ? JSON.serialize(sapData) : 'Missing Data';
                                apiLog.Error_Reason__c = 'Missing Clearing Date or Doc No';
                                apiLog.CP_Brokerage_Invoices__c = cpb.Id;
                                apiloglist.add(apiLog);
                                
                                errorMessage += 'Record ' + cpb.Id + ' Failed: Missing Clearing Date or Doc No in SAP Response<br/>';
                            }
                        }

                        if (!recordsToUpdate.isEmpty()) {
                            Database.SaveResult[] results = Database.update(recordsToUpdate, false);
                            
                            for (Integer i = 0; i < results.size(); i++) {
                                
                                CP_Brokerage__c updatedRecord = recordsToUpdate[i];
                                RespData sapData = sapDocNoVsResp.get(updatedRecord.SAP_Document_No__c);
                                
                                ERP_Integration_Log__c apiLog = new ERP_Integration_Log__c();
                                apiLog.API_Name__c = 'CP Brokerage Clearing API';
                                apiLog.Response__c = JSON.serialize(sapData);
                                apiLog.CP_Brokerage_Invoices__c = updatedRecord.Id;
                                
                                if (results[i].isSuccess()) {
                                    successRecordIds.add(updatedRecord.Id);                        
                                    apiLog.Status__c = 'Success';
                                } else {
                                    String rowError = '';
                                    for (Database.Error err : results[i].getErrors()) {
                                        rowError += err.getMessage() + ' ';
                                        errorMessage += 'Update Failed (Id: ' + updatedRecord.Id + ') - ' + err.getMessage() + '<br/>';
                                    }
                                    
                                    apiLog.Status__c = 'Failure';
                                    apiLog.Error_Reason__c = rowError.left(255);
                                    apiLog.Error_Type__c = 'Data Error';
                                }
                                apiloglist.add(apiLog);
                            }
                        }
                    }
                }
            }
            
            if (!apiloglist.isEmpty()) {
                insert apiloglist;
            }

            if (String.isNotBlank(errorMessage)) {
                sendErrorEmail(errorMessage, sapResponse, successRecordIds, 'Data Processing Errors');
            }

        } catch (Exception ex) {
            errorMessage += 'Unexpected Exception: ' + ex.getMessage() + '<br/>';
            
            ERP_Integration_Log__c apiLog = new ERP_Integration_Log__c();
            apiLog.API_Name__c = 'CP Brokerage Clearing API';
            apiLog.Status__c = 'Failure';
            apiLog.Response__c = String.isNotBlank(sapResponse) ? sapResponse.left(131072) : 'No Response';
            apiLog.Error_Reason__c = errorMessage.left(255);
            apiLog.Error_Type__c = 'Unexpected Error';
            apiloglist.add(apiLog);
            insert apiloglist;
            
            sendErrorEmail(errorMessage, sapResponse, successRecordIds, 'Unexpected Error');
        } 
    }
    
    private static void sendErrorEmail(String errorMessage, String sapResponse, List<String> successRecordIds, String errorType) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{
            'prashant.chaurasia.os@runwalgroup.in',
            'shraddha.shahari@runwalgroup.in'
        });
        mail.setSubject('CP Brokerage Clearing API - Failure');
        
        String body = '<b>SAP Response:</b><br/>' + sapResponse + '<br/><br/>';
        body += '<b>Success Record Ids:</b><br/>' + successRecordIds + '<br/><br/>';
        body += '<b>Error Type:</b><br/>' + errorType + '<br/><br/>';
        body += '<b>Error Details:</b><br/>' + errorMessage; 
        
        mail.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    global class RespData {
        public String CLEARING_DOC_NO;
        public String CLEARING_DATE;
        public String DOC_NO;
        public String BUKRS;
        public String INV_DT;
        public String INV_NO;        
    }
}