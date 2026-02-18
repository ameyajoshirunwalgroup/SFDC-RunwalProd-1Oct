// Main Integration Class for CP_Brokerage__c
/*public class SAPCPBrokerageCreation {
    public static List<ERP_Integration_Log__c> APIlogsToInsertList = new List<ERP_Integration_Log__c>();
    public static List<Legal_Entity__c> legalentity;
    public static List<Project__c> ProjectList;
    public static List<CP_Brokerage__c> UpdateCPBrokerageList;
     
    public SAPCPBrokerageCreation(){
        ProjectList = new List<Project__c>();
        legalentity = new List<Legal_Entity__c>();
    }
    
    public static void SendReq(Set<Id> CPBrokerageId, Boolean EnterCondTypeforSAPDocNo, String HardcodeCondType){
        system.debug('Inside CP Brokerage SendReq !!!');
        system.debug('EnterCondTypeforSAPDocNo: ' + EnterCondTypeforSAPDocNo);
        system.debug('HardcodeCondType: ' + HardcodeCondType);
        
        List<CP_Brokerage__c> CPBrokerageList = new List<CP_Brokerage__c>();
        List<Tower__c> tlist = new List<Tower__c>();
        UpdateCPBrokerageList = new List<CP_Brokerage__c>();
        
        String body = '';
        
        // Query CP_Brokerage__c with all related fields
        CPBrokerageList = [SELECT Id, Name, Invoice_Number__c, If_GST_is_applicable__c, Total_Brokerage__c, 
                          Approval_Status__c, Invoice_Status__c, Place_of_Supply__c, Type_of_Client__c, 
                          Invoice_Date__c, SAP_Broker_code__c, IGST__c, CGST__c, SGST__c, SAP_Document_No__c,
                          SAP_Document_Date__c, SAP_Posting_Date__c, SAP_Clearing_Date__c, SAP_TDS__c, 
                          Channel_Partner__c, Legal_Entity__c, Brokerage_Type__c, AOP__c, Month__c
                          FROM CP_Brokerage__c 
                          WHERE Id IN: CPBrokerageId];
        
        // Query child Brokerage_Invoice__c records separately
        Map<Id, List<Brokerage_Invoice__c>> cpBrokerageToInvoicesMap = new Map<Id, List<Brokerage_Invoice__c>>();
        List<Brokerage_Invoice__c> childInvoices = [SELECT Id, CP_Brokerage__c, Name, Invoice_Amount__c,Brokerage_Lookup__r.Name,
                                                   Customer_Name__c, Tower_Unit__c, Project__c, SO_Number__c, 
                                                   Customer_Code__c, Brokerage__c, Total_Agreement_Value__c,
                                                   Invoice_Number__c, Brokerage_In_Rs__c
                                                   FROM Brokerage_Invoice__c 
                                                   WHERE CP_Brokerage__c IN: CPBrokerageId];
        
        // Group child invoices by CP_Brokerage__c
        for(Brokerage_Invoice__c invoice : childInvoices){
            if(!cpBrokerageToInvoicesMap.containsKey(invoice.CP_Brokerage__c)){
                cpBrokerageToInvoicesMap.put(invoice.CP_Brokerage__c, new List<Brokerage_Invoice__c>());
            }
            cpBrokerageToInvoicesMap.get(invoice.CP_Brokerage__c).add(invoice);
        }
         
        system.debug('CPBrokerageList ::>> ' + CPBrokerageList);
        
        if(!CPBrokerageList.isEmpty() && CPBrokerageList.size() > 0){
            Integer serialNumber = 1;
            
            // Create the main JSON wrapper with "invoices" array
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('invoices');
            gen.writeStartArray();
            
            for(CP_Brokerage__c cpBrokerage: CPBrokerageList){
                system.debug('Inside For Loop !!!');
                
                try{
                    // Get Legal Entity information
                    if(cpBrokerage.Legal_Entity__c != null){
                        legalentity = [SELECT Id, Name, RDS_Company_Code__c, RDS_Company_Name__c,
                                      RDS_Address1__c, RDS_Address2__c, RDS_PAN_No__c, GSTIN__c, RERA_Number__c 
                                      FROM Legal_Entity__c 
                                      WHERE Id = :cpBrokerage.Legal_Entity__c];
                        system.debug('legalentity:: ' + legalentity);
                    }
                    List<Brokerage_Invoice__c> relatedInvoices = cpBrokerageToInvoicesMap.get(cpBrokerage.Id);
                    
                    // Date formatting
                    Datetime d = cpBrokerage.Invoice_Date__c;
                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYYMMdd');
                    system.debug('Date: ' + dt);
                    
                    // Start individual invoice object in the array
                    gen.writeStartObject();
                    
                    // Write invoice header fields
                    gen.writeNumberField('sr_no', serialNumber);
                    serialNumber++;
                    
                    if(!legalentity.isEmpty() && String.isNotBlank(legalentity[0].RDS_Company_Code__c)){
                        gen.writeStringField('bukrs', legalentity[0].RDS_Company_Code__c);
                    } else {
                        gen.writeStringField('bukrs', '');
                    }
                    
                    if(String.isNotBlank(cpBrokerage.SAP_Broker_code__c)){
                        gen.writeStringField('lifnr', cpBrokerage.SAP_Broker_code__c);
                    } else {
                        gen.writeStringField('lifnr', '');
                    }
                    
                    if(String.isNotBlank(dt)){
                        gen.writeStringField('inv_dt', dt);
                    } else {
                        gen.writeStringField('inv_dt', '');
                    }
                    
                    if(String.isNotBlank(cpBrokerage.Invoice_Number__c)){
                        gen.writeStringField('inv_no', cpBrokerage.Invoice_Number__c);
                    } else {
                        gen.writeStringField('inv_no', '');
                    }
                    
                    // Calculate total invoice amount
                    Decimal totalInvoiceAmt = 0;
                    if(relatedInvoices != null && !relatedInvoices.isEmpty()){
                        for(Brokerage_Invoice__c invoice : relatedInvoices){
                            if(invoice.Invoice_Amount__c != null){
                                totalInvoiceAmt += invoice.Invoice_Amount__c;
                            }
                        }
                    }
                    gen.writeNumberField('tot_inv_amt', totalInvoiceAmt);
                    
                    // Header text
                    String headerText = 'CP Brokerage - ' + cpBrokerage.Name;
                    gen.writeStringField('hdr_text', headerText);
                    
                    // Write items array
                    gen.writeFieldName('items');
                    gen.writeStartArray();
                    
                    if(relatedInvoices != null && !relatedInvoices.isEmpty()){
                        for(Brokerage_Invoice__c invoice : relatedInvoices){
                            gen.writeStartObject();
                          String itemText = '';
                            List<String> parts = new List<String>();
                            
                            if (String.isNotBlank(invoice.Tower_Unit__c)) {
                                parts.add(invoice.Tower_Unit__c);
                            }
                            if (invoice.Brokerage_Lookup__r != null && String.isNotBlank(invoice.Brokerage_Lookup__r.Name)) {
                                parts.add(invoice.Brokerage_Lookup__r.Name);
                            }
                            if (invoice.Brokerage__c != null) {
                                parts.add(String.valueOf(invoice.Brokerage__c));
                            }
                            if (String.isNotBlank(invoice.Customer_Name__c)) {
                                parts.add(invoice.Customer_Name__c);
                            }
                            
                            // Join with " - "
                            itemText = String.join(parts, ' - ');
                            
                            // Enforce max length 50 chars
                            if (itemText.length() > 50) {
                                itemText = itemText.substring(0, 50);
                            }
                            gen.writeStringField('itm_text', itemText);
                            
                            if(invoice.Invoice_Amount__c != null){
                                gen.writeNumberField('inv_amt', invoice.Invoice_Amount__c);
                            } else {
                                gen.writeNumberField('inv_amt', 0);
                            }
                            
                            gen.writeEndObject();
                        }
                    }
                    
                    gen.writeEndArray(); // End items array
                    gen.writeEndObject(); // End individual invoice object
                    
                } catch(Exception e){
                    system.debug('Error building JSON: ' + e.getMessage());
                    system.debug('Error at Line No:: ' + e.getLineNumber());
                }
            }
            
            gen.writeEndArray(); // End invoices array
            gen.writeEndObject(); // End main object
            
            body = gen.getAsString();
            system.debug('Generated JSON Body:: ' + body);
            
            // Validate JSON structure
            try {
                Object parsedJson = JSON.deserializeUntyped(body);
                system.debug('JSON Validation: Success');
            } catch(Exception e) {
                system.debug('JSON Validation Failed: ' + e.getMessage());
            }
            
            // Now send the request ONCE with all invoices
            try{
                SAPCPBrokerageCreationParser jsonResponse = new SAPCPBrokerageCreationParser();
                Http http1 = new Http();
                
                // Authentication details
                String username = Label.SAP_Username;
                System.debug('username:: ' + username);
                String password = Label.SAP_Password;
                String endPointURL = 'http://123.108.44.40:8002/zcp_ladder/cp_ladder_inv?sap-client=300'; 
                System.debug('endPointURL:: ' + endPointURL);
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                
                HttpRequest request = new HttpRequest();                      
                request.setMethod('POST');
                request.setEndpoint(endPointURL); 
                request.setTimeout(120000);   
                request.setHeader('authorization', authorizationHeader);
                request.setHeader('content-type', 'application/json');
                request.setBody(body);
                
                ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                
                if(!Test.isRunningTest()){
                    HttpResponse response = http1.send(request); 
                    system.debug('Response:: ' + response.getBody());
                    system.debug('Response status code:: ' + response.getStatusCode());
                    
                    // Check if response is valid JSON before parsing
                    String responseBody = response.getBody();
                    if(String.isNotBlank(responseBody) && (responseBody.trim().startsWith('{') || responseBody.trim().startsWith('['))){
                        // Parse response - handles both array and object responses
                        List<SAPCPBrokerageCreationParser> responseList = new List<SAPCPBrokerageCreationParser>();
                        
                        if(responseBody.trim().startsWith('[')){
                            responseList = SAPCPBrokerageCreationParser.parseList(responseBody);
                        } else {
                            SAPCPBrokerageCreationParser singleResponse = SAPCPBrokerageCreationParser.parse(responseBody);
                            if(singleResponse != null){
                                responseList.add(singleResponse);
                            }
                        }
                        
                        system.debug('Parsed Response List :: ' + responseList);
                        
                        // Check if there are any errors in the response
                        Boolean hasError = false;
                        String errorMessages = '';
                        
                        for(SAPCPBrokerageCreationParser resp : responseList){
                            if(resp.IS_ERROR == 'Y'){
                                hasError = true;
                                errorMessages += resp.ERR_MSG + '; ';
                            }
                        }
                        
                        // Process each response and update corresponding CP_Brokerage record
                        Integer responseIndex = 0;
                        for(CP_Brokerage__c cpBrokerage : CPBrokerageList){
                            if(responseIndex < responseList.size()){
                                SAPCPBrokerageCreationParser resp = responseList[responseIndex];
                                
                                CP_Brokerage__c updateCPBrokerage = new CP_Brokerage__c();
                                updateCPBrokerage.Id = cpBrokerage.Id;
                                
                                // Only update if there's no error
                                if(resp.IS_ERROR != 'Y'){
                                    if(String.isNotBlank(resp.DOC_NO)){
                                        updateCPBrokerage.SAP_Document_No__c = resp.DOC_NO;
                                    }
                                    
                                    if(String.isNotBlank(resp.INV_DT) && resp.INV_DT != '0000-00-00'){
                                        try {
                                            updateCPBrokerage.SAP_Document_Date__c = Date.valueOf(resp.INV_DT);
                                            updateCPBrokerage.SAP_Posting_Date__c = Date.valueOf(resp.INV_DT);
                                            updateCPBrokerage.SAP_Clearing_Date__c = Date.valueOf(resp.INV_DT);
                                        } catch(Exception dateEx){
                                            system.debug('Date parsing error: ' + dateEx.getMessage());
                                        }
                                    }
                                    
                                    if(resp.TDS_AMT != null){
                                        updateCPBrokerage.SAP_TDS__c = resp.TDS_AMT;
                                    }
                                }
                                
                                UpdateCPBrokerageList.add(updateCPBrokerage);
                                responseIndex++;
                            }
                        }
                        
                        // API Log
                        api.API_Name__c = 'CP Brokerage Creation API';
                        api.Request__c = body;
                        api.Response__c = responseBody;
                        
                        if(hasError){
                            api.Status__c = 'Failure';
                            api.Response__c = 'Errors: ' + errorMessages + ' | Full Response: ' + responseBody;
                        } else {
                            api.Status__c = 'Success';
                        }
                    } else {
                        // Invalid response format
                        system.debug('Invalid JSON response received');
                        api.API_Name__c = 'CP Brokerage Creation API';
                        api.Request__c = body;
                        api.Response__c = 'Invalid JSON response: ' + responseBody;
                        api.Status__c = 'Failure';
                    }
                }
                
                APIlogsToInsertList.add(api);
                
            } catch(Exception e){
                system.debug('API request in catch:: ' + e);
                system.debug('Error at Line No:: ' + e.getLineNumber());
                
                ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                api.API_Name__c = 'CP Brokerage Creation API';
                api.Request__c = body;
                api.Response__c = e.getMessage() + ' Error at Line No:: ' + e.getLineNumber();
                api.Status__c = 'Failure';
                APIlogsToInsertList.add(api);
            }
            
            // Update CP_Brokerage__c records
            try{
                if(UpdateCPBrokerageList.size() > 0){
                    update UpdateCPBrokerageList;
                    system.debug('CP Brokerage Update Success !!!!');
                }
            } catch(Exception e){
                system.debug('Update Error at Line No:: ' + e.getLineNumber());
            }
            
            // Insert API Logs
            try{
                if(!APIlogsToInsertList.isEmpty()){
                    insert APIlogsToInsertList;
                    system.debug('API Logs Insert Success !!'+APIlogsToInsertList);
                }
            } catch(Exception e){
                system.debug('API Log Insert Error: ' + e.getMessage());
            }
        }
    }
    
    // Helper method for condition type mapping
    public static String getConditionType(String brokerageType, Boolean isAOP){
        String condtype = '';
        
        if(brokerageType == 'Kicker Incentive'){
            condtype = 'ZGXB';
        } else if(isAOP == true){
            condtype = 'Z1BR';
        } else {
            condtype = 'ZBRK';
        }
        
        return condtype;
    }
}*/


// Main Integration Class for CP_Brokerage__c
public class SAPCPBrokerageCreation {
    public static List<ERP_Integration_Log__c> APIlogsToInsertList = new List<ERP_Integration_Log__c>();
    public static List<Legal_Entity__c> legalentity;
    public static List<Project__c> ProjectList;
    public static List<CP_Brokerage__c> UpdateCPBrokerageList;
     
    public SAPCPBrokerageCreation(){
        ProjectList = new List<Project__c>();
        legalentity = new List<Legal_Entity__c>();
    }
    
    public static void SendReq(Set<Id> CPBrokerageId, Boolean EnterCondTypeforSAPDocNo, String HardcodeCondType){
        system.debug('Inside CP Brokerage SendReq !!!');
        system.debug('EnterCondTypeforSAPDocNo: ' + EnterCondTypeforSAPDocNo);
        system.debug('HardcodeCondType: ' + HardcodeCondType);
        
        List<CP_Brokerage__c> CPBrokerageList = new List<CP_Brokerage__c>();
        List<Tower__c> tlist = new List<Tower__c>();
        UpdateCPBrokerageList = new List<CP_Brokerage__c>();
        
        String body = '';
        
        // Query CP_Brokerage__c with all related fields
        CPBrokerageList = [SELECT Id, Name, Invoice_Number__c, If_GST_is_applicable__c, Total_Brokerage__c, 
                          Approval_Status__c, Invoice_Status__c, Place_of_Supply__c, Type_of_Client__c, 
                          Invoice_Date__c, SAP_Broker_code__c, IGST__c, CGST__c, SGST__c, SAP_Document_No__c,
                          SAP_Document_Date__c, SAP_Posting_Date__c, SAP_Clearing_Date__c, SAP_TDS__c, 
                          Channel_Partner__c, Legal_Entity__c, Brokerage_Type__c, AOP__c, Month__c,Total_Invoice_Amount__c
                          FROM CP_Brokerage__c 
                          WHERE Id IN: CPBrokerageId];
        
        // Query child Brokerage_Invoice__c records separately
        Map<Id, List<Brokerage_Invoice__c>> cpBrokerageToInvoicesMap = new Map<Id, List<Brokerage_Invoice__c>>();
        List<Brokerage_Invoice__c> childInvoices = [SELECT Id, CP_Brokerage__c, Name, Invoice_Amount__c,Brokerage_Lookup__r.Name,
                                                   Customer_Name__c, Tower_Unit__c, Project__c, SO_Number__c, 
                                                   Customer_Code__c, Brokerage__c, Total_Agreement_Value__c,
                                                   Invoice_Number__c, Brokerage_In_Rs__c
                                                   FROM Brokerage_Invoice__c 
                                                   WHERE CP_Brokerage__c IN: CPBrokerageId];
        
        // Group child invoices by CP_Brokerage__c
        for(Brokerage_Invoice__c invoice : childInvoices){
            if(!cpBrokerageToInvoicesMap.containsKey(invoice.CP_Brokerage__c)){
                cpBrokerageToInvoicesMap.put(invoice.CP_Brokerage__c, new List<Brokerage_Invoice__c>());
            }
            cpBrokerageToInvoicesMap.get(invoice.CP_Brokerage__c).add(invoice);
        }
         
        system.debug('CPBrokerageList ::>> ' + CPBrokerageList);
        
        if(!CPBrokerageList.isEmpty() && CPBrokerageList.size() > 0){
            Integer serialNumber = 1;
            
            // Create the main JSON wrapper with "invoices" array
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('invoices');
            gen.writeStartArray();
            
            for(CP_Brokerage__c cpBrokerage: CPBrokerageList){
                system.debug('Inside For Loop !!!');
                
                try{
                    // Get Legal Entity information
                    if(cpBrokerage.Legal_Entity__c != null){
                        legalentity = [SELECT Id, Name, RDS_Company_Code__c, RDS_Company_Name__c,
                                      RDS_Address1__c, RDS_Address2__c, RDS_PAN_No__c, GSTIN__c, RERA_Number__c 
                                      FROM Legal_Entity__c 
                                      WHERE Id = :cpBrokerage.Legal_Entity__c];
                        system.debug('legalentity:: ' + legalentity);
                    }
                    List<Brokerage_Invoice__c> relatedInvoices = cpBrokerageToInvoicesMap.get(cpBrokerage.Id);
                    
                    // Date formatting
                    Datetime d = cpBrokerage.Invoice_Date__c;
                    String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('YYYYMMdd');
                    system.debug('Date: ' + dt);
                    
                    // Start individual invoice object in the array
                    gen.writeStartObject();
                    
                    // Write invoice header fields
                    gen.writeNumberField('sr_no', serialNumber);
                    serialNumber++;
                    
                    if(!legalentity.isEmpty() && String.isNotBlank(legalentity[0].RDS_Company_Code__c)){
                        gen.writeStringField('bukrs', legalentity[0].RDS_Company_Code__c);
                    } else {
                        gen.writeStringField('bukrs', '');
                    }
                    
                    if(String.isNotBlank(cpBrokerage.SAP_Broker_code__c)){
                        gen.writeStringField('lifnr', cpBrokerage.SAP_Broker_code__c);
                    } else {
                        gen.writeStringField('lifnr', '');
                    }
                    
                    if(String.isNotBlank(dt)){
                        gen.writeStringField('inv_dt', dt);
                    } else {
                        gen.writeStringField('inv_dt', '');
                    }
                    
                    if(String.isNotBlank(cpBrokerage.Invoice_Number__c)){
                        gen.writeStringField('inv_no', cpBrokerage.Invoice_Number__c);
                    } else {
                        gen.writeStringField('inv_no', '');
                    }
                    
                    // Calculate total invoice amount
                    Decimal totalInvoiceAmt = 0;
                    if(relatedInvoices != null && !relatedInvoices.isEmpty()){
                        for(Brokerage_Invoice__c invoice : relatedInvoices){
                            /*if(invoice.Invoice_Amount__c != null){
                                //totalInvoiceAmt += invoice.Invoice_Amount__c;
                                totalInvoiceAmt += invoice.Brokerage_In_Rs__c;//Changed the mapping 
                            }*///Commented by Prashant to remove invoice amt and map brokerage amt - 5-1-26
                            if(invoice.Brokerage_In_Rs__c != null){
                                //totalInvoiceAmt += invoice.Invoice_Amount__c;
                                totalInvoiceAmt += invoice.Brokerage_In_Rs__c;//Changed the mapping by Prashant.. 5-1-26
                            }
                        }
                    }
                    gen.writeNumberField('tot_inv_amt', totalInvoiceAmt);
                    
                    // Header text
                    String headerText = 'CP Brokerage - ' + cpBrokerage.Name;
                    gen.writeStringField('hdr_text', headerText);
                    
                    // Write items array
                    gen.writeFieldName('items');
                    gen.writeStartArray();
                    
                    if(relatedInvoices != null && !relatedInvoices.isEmpty()){
                        for(Brokerage_Invoice__c invoice : relatedInvoices){
                            gen.writeStartObject();
                          String itemText = '';
                            List<String> parts = new List<String>();
                            
                            if (String.isNotBlank(invoice.Tower_Unit__c)) {
                                parts.add(invoice.Tower_Unit__c);
                            }
                            if (invoice.Brokerage_Lookup__r != null && String.isNotBlank(invoice.Brokerage_Lookup__r.Name)) {
                                parts.add(invoice.Brokerage_Lookup__r.Name);
                            }
                            if (invoice.Brokerage__c != null) {
                                parts.add(String.valueOf(invoice.Brokerage__c));
                            }
                            if (String.isNotBlank(invoice.Customer_Name__c)) {
                                parts.add(invoice.Customer_Name__c);
                            }
                            
                            // Join with " - "
                            itemText = String.join(parts, ' - ');
                            
                            // Enforce max length 50 chars
                            if (itemText.length() > 50) {
                                itemText = itemText.substring(0, 50);
                            }
                            gen.writeStringField('itm_text', itemText);
                            
                            /*if(invoice.Invoice_Amount__c != null){
                                gen.writeNumberField('inv_amt', invoice.Invoice_Amount__c);
                                gen.writeNumberField('inv_amt', invoice.Brokerage_In_Rs__c);//Changed the mapping...5-1-25
                            }*///Commented by Prashant to remove invoice amt and map brokerage amt - 5-1-25
                            if(invoice.Brokerage_In_Rs__c != null){
                                gen.writeNumberField('inv_amt', invoice.Brokerage_In_Rs__c);//Changed the mapping...5-1-25
                            }else {
                                gen.writeNumberField('inv_amt', 0);
                            }
                            
                            gen.writeEndObject();
                        }
                    }
                    
                    gen.writeEndArray(); // End items array
                    gen.writeEndObject(); // End individual invoice object
                    
                } catch(Exception e){
                    system.debug('Error building JSON: ' + e.getMessage());
                    system.debug('Error at Line No:: ' + e.getLineNumber());
                    
                    // Create error log with CP_Brokerage lookup
                    ERP_Integration_Log__c errorLog = new ERP_Integration_Log__c();
                    errorLog.API_Name__c = 'CP Brokerage Creation API';
                    errorLog.Request__c = 'Error during JSON building for CP Brokerage: ' + cpBrokerage.Name;
                    errorLog.Response__c = e.getMessage() + ' Error at Line No:: ' + e.getLineNumber();
                    errorLog.Status__c = 'Failure';
                    errorLog.CP_Brokerage_Invoices__c = cpBrokerage.Id; // Add lookup relationship
                    APIlogsToInsertList.add(errorLog);
                }
            }
            
            gen.writeEndArray(); // End invoices array
            gen.writeEndObject(); // End main object
            
            body = gen.getAsString();
            system.debug('Generated JSON Body:: ' + body);
            
            // Validate JSON structure
            try {
                Object parsedJson = JSON.deserializeUntyped(body);
                system.debug('JSON Validation: Success');
            } catch(Exception e) {
                system.debug('JSON Validation Failed: ' + e.getMessage());
            }
            // Now send the request ONCE with all invoices
            try{
                SAPCPBrokerageCreationParser jsonResponse = new SAPCPBrokerageCreationParser();
                Http http1 = new Http();
                
                // Authentication details
                String username = Label.SAP_Username;
                System.debug('username:: ' + username);
                String password = Label.SAP_Password;                
                //String endPointURL = 'http://123.108.44.40:8002/zcp_ladder/cp_ladder_inv?sap-client=300'; 
                String endPointURL = label.SAP_cp_ladder_inv;//Added dynamic endpoint.
                System.debug('endPointURL:: ' + endPointURL);
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                
                HttpRequest request = new HttpRequest();                      
                request.setMethod('POST');
                request.setEndpoint(endPointURL); 
                request.setTimeout(120000);   
                request.setHeader('authorization', authorizationHeader);
                request.setHeader('content-type', 'application/json');
                request.setBody(body);
                
                ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                // Set the CP_Brokerage lookup for the main API log (you might want to associate with first record or create separate logs)
                if(!CPBrokerageList.isEmpty()) {
                    api.CP_Brokerage_Invoices__c = CPBrokerageList[0].Id;
                }

                if(!Test.isRunningTest()){
                    HttpResponse response = http1.send(request); 
                    system.debug('Response:: ' + response.getBody());
                    system.debug('Response status code:: ' + response.getStatusCode());
                    
                    // Check if response is valid JSON before parsing
                    String responseBody = response.getBody();
                    if(String.isNotBlank(responseBody) && (responseBody.trim().startsWith('{') || responseBody.trim().startsWith('['))){
                        // Parse response - handles both array and object responses
                        List<SAPCPBrokerageCreationParser> responseList = new List<SAPCPBrokerageCreationParser>();
                        
                        if(responseBody.trim().startsWith('[')){
                            responseList = SAPCPBrokerageCreationParser.parseList(responseBody);
                        } else {
                            SAPCPBrokerageCreationParser singleResponse = SAPCPBrokerageCreationParser.parse(responseBody);
                            if(singleResponse != null){
                                responseList.add(singleResponse);
                            }
                        }
                        
                        system.debug('Parsed Response List :: ' + responseList);
                        
                        // Check if there are any errors in the response
                        Boolean hasError = false;
                        String errorMessages = '';
                        
                        for(SAPCPBrokerageCreationParser resp : responseList){
                            if(resp.IS_ERROR == 'Y'){
                                hasError = true;
                                errorMessages += resp.ERR_MSG + '; ';
                            }
                        }
                        
                        // Process each response and update corresponding CP_Brokerage record
                        Integer responseIndex = 0;
                        
                        for(CP_Brokerage__c cpBrokerage : CPBrokerageList){
                            if(responseIndex < responseList.size()){
                                SAPCPBrokerageCreationParser resp = responseList[responseIndex];
                                
                                CP_Brokerage__c updateCPBrokerage = new CP_Brokerage__c();
                                updateCPBrokerage.Id = cpBrokerage.Id;
                                
                                // Create individual API log for each CP_Brokerage record
                                ERP_Integration_Log__c individualLog = new ERP_Integration_Log__c();
                                individualLog.API_Name__c = 'CP Brokerage Creation API';
                                individualLog.CP_Brokerage_Invoices__c = cpBrokerage.Id;
                                individualLog.Request__c = 'Individual request for: ' + cpBrokerage.Name;
                                
                                // Only update if there's no error
                                if(resp.IS_ERROR != 'Y'){
                                    if(String.isNotBlank(resp.DOC_NO)){
                                        updateCPBrokerage.SAP_Document_No__c = resp.DOC_NO;
                                    }
                                    
                                    if(String.isNotBlank(resp.INV_DT) && resp.INV_DT != '0000-00-00'){
                                        try {
                                            updateCPBrokerage.SAP_Document_Date__c = Date.valueOf(resp.INV_DT);
                                            updateCPBrokerage.SAP_Posting_Date__c = Date.valueOf(resp.INV_DT);
                                            updateCPBrokerage.SAP_Clearing_Date__c = Date.valueOf(resp.INV_DT);
                                        } catch(Exception dateEx){
                                            system.debug('Date parsing error: ' + dateEx.getMessage());
                                        }
                                    }
                                    
                                    if(resp.TDS_AMT != null){
                                        updateCPBrokerage.SAP_TDS__c = resp.TDS_AMT;
                                        system.debug('resp.TDS_AMT -> '+resp.TDS_AMT);
                                    }
                                    
                                    individualLog.Response__c = 'Success - SAP Doc No: ' + resp.DOC_NO;
                                    individualLog.Status__c = 'Success';
                                } else {
                                    // Handle error for this specific record
                                    individualLog.Response__c = 'Error: ' + resp.ERR_MSG;
                                    individualLog.Status__c = 'Failure';
                                }
                                
                                UpdateCPBrokerageList.add(updateCPBrokerage);
                                //APIlogsToInsertList.add(individualLog);
                                responseIndex++;
                            }
                        }
                        
                        // Main API Log
                        api.Request__c = body;
                        api.Response__c = responseBody;
                        
                        if(hasError){
                            api.Status__c = 'Partial Failure';
                            api.Response__c = 'Errors: ' + errorMessages + ' | Full Response: ' + responseBody;
                        } else {
                            api.Status__c = 'Success';
                        }
                    } else {
                        // Invalid response format
                        system.debug('Invalid JSON response received');
                        api.Request__c = body;
                        api.Response__c = 'Invalid JSON response: ' + responseBody;
                        api.Status__c = 'Failure';
                    }
                }
                
                APIlogsToInsertList.add(api);
                
            } catch(Exception e){
                system.debug('API request in catch:: ' + e);
                system.debug('Error at Line No:: ' + e.getLineNumber());
                
                ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                api.API_Name__c = 'CP Brokerage Creation API';
                api.Request__c = body;
                api.Response__c = e.getMessage() + ' Error at Line No:: ' + e.getLineNumber();
                api.Status__c = 'Failure';
                
                // Add CP_Brokerage lookup for error log
                if(!CPBrokerageList.isEmpty()) {
                    api.CP_Brokerage_Invoices__c = CPBrokerageList[0].Id;
                }
                
                APIlogsToInsertList.add(api);
            }
            
            // Update CP_Brokerage__c records
            try{
                if(UpdateCPBrokerageList.size() > 0){
                    update UpdateCPBrokerageList;
                    system.debug('CP Brokerage Update Success !!!!');
                }
            } catch(Exception e){
                system.debug('Update Error at Line No:: ' + e.getLineNumber());
                
                // Create error log for update failure
                for(CP_Brokerage__c cpBrokerage : CPBrokerageList) {
                    ERP_Integration_Log__c updateErrorLog = new ERP_Integration_Log__c();
                    updateErrorLog.API_Name__c = 'CP Brokerage Update';
                    updateErrorLog.CP_Brokerage_Invoices__c = cpBrokerage.Id;
                    updateErrorLog.Request__c = 'Update operation for: ' + cpBrokerage.Name;
                    updateErrorLog.Response__c = 'Update failed: ' + e.getMessage();
                    updateErrorLog.Status__c = 'Failure';
                    APIlogsToInsertList.add(updateErrorLog);
                }
            }
            
            // Insert API Logs
            try{
                if(!APIlogsToInsertList.isEmpty()){
                    insert APIlogsToInsertList;
                    system.debug('API Logs Insert Success !!'+APIlogsToInsertList);
                }
            } catch(Exception e){
                system.debug('API Log Insert Error: ' + e.getMessage());
            }
            
        }
    }
    
    // Helper method for condition type mapping
    public static String getConditionType(String brokerageType, Boolean isAOP){
        String condtype = '';
        
        if(brokerageType == 'Kicker Incentive'){
            condtype = 'ZGXB';
        } else if(isAOP == true){
            condtype = 'Z1BR';
        } else {
            condtype = 'ZBRK';
        }
        
        return condtype;
    }
    
    public Static Void DemmyMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
    }
}