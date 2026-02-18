@RestResource(urlMapping='/cpCPInvoicesGeneration/*')
global without sharing class Lockated_CPPostInvoiceGeneration {
    // Generate Invoice
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> responseMap = new Map<String, Object>();
        
        String invId = req.params.get('invId');
        
        List<String> missingParams = new List<String>();
        if (String.isBlank(invId)) missingParams.add('invId');
        
        if (!missingParams.isEmpty()) {
            res.statusCode = 400;
            responseMap.put('status', 'error');
            responseMap.put('message', 'Missing required parameters: ' + String.join(missingParams, ', '));
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return; // Stop execution if validation fails
        }
        try {
            String jsonBody = req.requestBody != null ? req.requestBody.toString() : '';
            
            if (String.isBlank(jsonBody)) {
                res.statusCode = 400;
                responseMap.put('status', 'error');
                responseMap.put('message', 'Request body cannot be empty');
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }
            InvoiceRequestWrapper requestData = (InvoiceRequestWrapper) JSON.deserialize(jsonBody, InvoiceRequestWrapper.class);

            // 4. Validate for Missing Fields
            if (String.isBlank(requestData.invDate)) missingParams.add('invDate');
            if (String.isBlank(requestData.invNumber)) missingParams.add('invNumber');
            if (String.isBlank(requestData.invIsGSTApp)) missingParams.add('invIsGSTApp');

            if (!missingParams.isEmpty()) {
                res.statusCode = 400;
                responseMap.put('status', 'error');
                responseMap.put('message', 'Missing required fields: ' + String.join(missingParams, ', '));
                res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
                return;
            }
             
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. START...
            if (invId != null) {
                Id invIdNew = invId;
                Schema.SObjectType objType = invIdNew.getSObjectType();
                if (objType == CP_Brokerage__c.SObjectType) {
                    List<CP_Brokerage__c> cpBrokerageUpdate = new List<CP_Brokerage__c>();
                    // 3. Query the Record
                    List<CP_Brokerage__c> invlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c, Invoice_Date__c, Invoice_Status__c 
                        FROM CP_Brokerage__c 
                        WHERE Id = :invId 
                        LIMIT 1
                    ];
                    
                    if (!invlist.isEmpty()) {
                        for(CP_Brokerage__c invObj: invlist){
                            invObj.Invoice_Number__c = requestData.invNumber;
                            invObj.If_GST_is_applicable__c = requestData.invIsGSTApp;
                            invObj.Invoice_Status__c = 'Invoice Downloaded';
                            try {
                                invObj.Invoice_Date__c = Date.valueOf(requestData.invDate);
                            } catch (Exception e) {
                                throw new CalloutException('Invalid Date Format. Please use YYYY-MM-DD.');
                            }
                            cpBrokerageUpdate.add(invObj);
                        }
                        if(!cpBrokerageUpdate.isEmpty()){
                            update cpBrokerageUpdate;
                            PageReference pdfPage = Page.ShowCP_InvoicePreview;
                            pdfPage.getParameters().put('id', invId);
                            pdfPage.getParameters().put('gstApp', requestData.invIsGSTApp);
                            pdfPage.getParameters().put('invoiceNumber', requestData.invNumber);
                            pdfPage.getParameters().put('invoiceDate', requestData.invDate);
                            Blob pdfBlob;
                            if (Test.isRunningTest()) { 
                                pdfBlob = Blob.valueOf('Mock PDF Content');
                            } else {
                                pdfBlob = pdfPage.getContentAsPDF();
                            }
                            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                            responseMap.put('pdfContent', base64Pdf);
                            responseMap.put('fileName', 'Invoice_' + requestData.invNumber + '.pdf');
                            res.statusCode = 200;
                            responseMap.put('status', 'success');
                            responseMap.put('message', 'Invoice updated successfully');
                            responseMap.put('id', invId);
                        }
                    }
                    else {
                        // Record Not Found
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No CP_Brokerage__c record found with Id: ' + invId);
                    }
                }
                else if (objType == Brokerage_Invoice__c.SObjectType) {
                    List<Brokerage_Invoice__c> brokerageUpdate = new List<Brokerage_Invoice__c>();
                    // 3. Query the Record
                    List<Brokerage_Invoice__c> invlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c, Invoice_Date__c, Invoice_Status__c 
                        FROM Brokerage_Invoice__c 
                        WHERE Id = :invId 
                        LIMIT 1
                    ];
                    
                    if (!invlist.isEmpty()) {
                        for(Brokerage_Invoice__c invObj: invlist){
                            invObj.Invoice_Number__c = requestData.invNumber;
                            invObj.If_GST_is_applicable__c = requestData.invIsGSTApp;
                            invObj.Invoice_Status__c = 'Invoice Downloaded';
                            try {
                                invObj.Invoice_Date__c = Date.valueOf(requestData.invDate);
                            } catch (Exception e) {
                                throw new CalloutException('Invalid Date Format. Please use YYYY-MM-DD.');
                            }
                            brokerageUpdate.add(invObj);
                        }
                        if(!brokerageUpdate.isEmpty()){
                            update brokerageUpdate;
                            PageReference pdfPage = Page.ShowInvoicePreview;
                            pdfPage.getParameters().put('id', invId);
                            pdfPage.getParameters().put('gstApp', requestData.invIsGSTApp);
                            pdfPage.getParameters().put('invoiceNumber', requestData.invNumber);
                            pdfPage.getParameters().put('invoiceDate', requestData.invDate);
                            Blob pdfBlob;
                            if (Test.isRunningTest()) { 
                                pdfBlob = Blob.valueOf('Mock PDF Content');
                            } else {
                                pdfBlob = pdfPage.getContentAsPDF();
                            }
                            String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                            responseMap.put('pdfContent', base64Pdf);
                            responseMap.put('fileName', 'Invoice_' + requestData.invNumber + '.pdf');
                            res.statusCode = 200;
                            responseMap.put('status', 'success');
                            responseMap.put('message', 'Invoice updated successfully');
                            responseMap.put('id', invId);
                        }
                    }
                    else {
                        // Record Not Found
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No Brokerage_Invoice__c record found with Id: ' + invId);
                    }
                }
            }
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. END...
            
            
        }catch(Exception ex){
            res.statusCode = 500;
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        // Return the JSON response
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }
    
    
    //Download Invoice 
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> responseMap = new Map<String, Object>();
        
        String invId = req.params.get('invId');
        
        List<String> missingParams = new List<String>();
        if (String.isBlank(invId)) missingParams.add('invId');
        
        if (!missingParams.isEmpty()) {
            res.statusCode = 400;
            responseMap.put('status', 'error');
            responseMap.put('message', 'Missing required parameters: ' + String.join(missingParams, ', '));
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            return; // Stop execution if validation fails
        }
        try{
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. START...
            if (invId != null) {
                Id invIdNew = invId;
                Schema.SObjectType objType = invIdNew.getSObjectType();
                if (objType == CP_Brokerage__c.SObjectType) {
                    // 3. Query the Record
                    List<CP_Brokerage__c> invlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c, Invoice_Date__c 
                        FROM CP_Brokerage__c 
                        WHERE Id = :invId 
                        LIMIT 1
                    ];
                    
                    if (!invlist.isEmpty()) {
                        PageReference pdfPage = Page.ShowCP_InvoicePreview;
                        pdfPage.getParameters().put('id', invId);
                        Blob pdfBlob;
                        if (Test.isRunningTest()) { 
                            pdfBlob = Blob.valueOf('Mock PDF Content');
                        } else {
                            pdfBlob = pdfPage.getContentAsPDF();
                        }
                        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                        responseMap.put('pdfContent', base64Pdf);
                        responseMap.put('fileName', 'Invoice_PDF' + '.pdf');
                        res.statusCode = 200;
                        responseMap.put('status', 'success');
                        responseMap.put('id', invId);
                    }
                    else {
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No CP_Brokerage__c record found with Id: ' + invId);
                    }
                }
                else if (objType == Brokerage_Invoice__c.SObjectType) {
                    // 3. Query the Record
                    List<Brokerage_Invoice__c> invlist = [
                        SELECT Id, Invoice_Number__c, If_GST_is_applicable__c, Invoice_Date__c 
                        FROM Brokerage_Invoice__c 
                        WHERE Id = :invId 
                        LIMIT 1
                    ];
                    
                    if (!invlist.isEmpty()) {
                        PageReference pdfPage = Page.ShowCP_InvoicePreview;
                        pdfPage.getParameters().put('id', invId);
                        Blob pdfBlob;
                        if (Test.isRunningTest()) { 
                            pdfBlob = Blob.valueOf('Mock PDF Content');
                        } else {
                            pdfBlob = pdfPage.getContentAsPDF();
                        }
                        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
                        responseMap.put('pdfContent', base64Pdf);
                        responseMap.put('fileName', 'Invoice_PDF' + '.pdf');
                        res.statusCode = 200;
                        responseMap.put('status', 'success');
                        responseMap.put('id', invId);
                    }
                    else {
                        res.statusCode = 404;
                        responseMap.put('status', 'error');
                        responseMap.put('message', 'No Brokerage_Invoice__c record found with Id: ' + invId);
                    }
                }
            }
            //Changes made by Prashant to update BI and CPB depends on what Id is received in request.// 04-02-26. END...
        }catch(Exception ex){
            res.statusCode = 500;
            responseMap.put('status', 'error');
            responseMap.put('message', ex.getMessage());
        }
        res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }
    
    public class InvoiceRequestWrapper {
        public String invDate;       // Expected format: "2025-12-07"
        public String invNumber;
        public String invIsGSTApp;
    }
}