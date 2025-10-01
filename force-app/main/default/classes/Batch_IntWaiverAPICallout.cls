global class Batch_IntWaiverAPICallout implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable, Database.Stateful {
    
    public List<WrapperIntWaiverAPI.items> lstWrapperIntWaiverAPI = new List<WrapperIntWaiverAPI.items>();
    public Boolean has_more = false;
    public String sapBatchId;
    public transient HTTPResponse response;
    public String jsonRespBody;
    public String sEndpoint;
    public String sUserName;
    public String sPassword;
    public Integer chunkSize; 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('inside start');
        String sQuery = 'select Id from user limit 1' ;
        system.debug('sQuery :' +sQuery);
        return Database.getQueryLocator(sQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        SAP_Integration__mdt Config = [
            SELECT Id, DeveloperName, End_Point_URL__c, Username__c, Password__c 
            FROM SAP_Integration__mdt 
            WHERE DeveloperName = 'GET_Interest_Waiver' 
            LIMIT 1
        ];
        system.debug('Config>>>>>>>>'+Config);
        chunkSize = Integer.valueOf(Label.SAP_Chunk_Size);
        system.debug('chunkSize>>>> ' + chunkSize);
        
        if (Config != null) {
            sEndpoint = Config.End_Point_URL__c + '&chunksize=' + chunkSize +'&batch_id=';
            sUserName = Config.Username__c;
            sPassword = Config.Password__c;
        }
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        Blob headerValue = Blob.valueOf(sUserName + ':' + sPassword);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setEndpoint(sEndpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('content-type','application/json');  
        try {
            response = http.send(req);
            
            system.debug('response.getBody()>>>>>>>' + response.getBody());     
            system.debug('response.getStatusCode()>>>>>>>' + response.getStatusCode());
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage());
            return; 
        }
        List<WrapperIntWaiverAPI.items> lstWrapperIntWaiverAPI = new List<WrapperIntWaiverAPI.items>();
        if(String.isNotBlank(response.getBody())){
            WrapperIntWaiverAPI wrapper = (WrapperIntWaiverAPI) JSON.deserialize(response.getBody(), WrapperIntWaiverAPI.class);
            
            if (response.getStatusCode() == 200) {
                system.debug('in if' + response.getStatusCode());
                if (wrapper != null) {
                    sapBatchId = wrapper.batch_id; 
                    SAP_IntegrationHelper.insertLogEntry('Demand Interest', response.getStatus(), null, null, '', '', '', sapBatchId);
                    system.debug('sapBatchId>>>>'+sapBatchId);
                    system.debug('after deserializatio' + wrapper);
                    if (wrapper.items != null){
                        system.debug(' wrapper.items>>>>>' +wrapper.items);
                        lstWrapperIntWaiverAPI = wrapper.items;
                        if(wrapper.has_more == 'Y'){
                            has_more = True;
                        }
                    }
                }
            }
            else{
                sapBatchId = wrapper.batch_id;
                
                sEndpoint = Config.End_Point_URL__c + '&chunksize=' + chunkSize +'&batch_id=' +sapBatchId;
                system.debug('sEndpoint>>>>' +sEndpoint);
                HTTP http1 = new HTTP();
                HttpRequest req1 = new HttpRequest();
                Blob headerValue1 = Blob.valueOf(sUserName + ':' + sPassword);
                String authorizationHeader1 = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setEndpoint(sEndpoint);
                req.setMethod('GET');
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('content-type','application/json');  
                try {
                    response = http1.send(req1);
                    
                    SAP_IntegrationHelper.insertLogEntry('Demand Interest', response.getStatus(), null, null, '', '', String.ValueOf(response.getStatusCode()), sapBatchId);
                    system.debug('sapBatchId>>>>'+sapBatchId);
                    
                    system.debug('response.getBody 1>>>>>>>' + response.getBody());     
                    system.debug('response.getStatusCode 1>>>>>>>' + response.getStatusCode());
                } catch (Exception e) {
                    System.debug('Error Message: ' + e.getMessage());
                    
                    SAP_IntegrationHelper.insertLogEntry('Demand Interest', response.getStatus(), null, null, '', '', String.ValueOf(response.getStatusCode()), sapBatchId);
                    system.debug('sapBatchId>>>>'+sapBatchId);
                    
                    return; 
                }
                
            } 
        }
        system.debug('Using lstWrapperIntWaiverAPI size: ' + lstWrapperIntWaiverAPI.size());
        
        List<RW_Demand__c> lstToUpdateDemand = new List<RW_Demand__c>();
        Map<String, WrapperIntWaiverAPI.items> mapWrappWithBillingNo = new Map<String, WrapperIntWaiverAPI.items>();
        
        if(!lstWrapperIntWaiverAPI.isEmpty() && lstWrapperIntWaiverAPI.size()>0){
            for (WrapperIntWaiverAPI.items objWrapp : lstWrapperIntWaiverAPI) {
                if (String.isNotBlank(objWrapp.belnr)) {
                    System.debug('objWrapp.belnr>>>' + objWrapp.belnr);
                    mapWrappWithBillingNo.put(objWrapp.belnr, objWrapp);
                }
            }
            system.debug('mapWrappWithBillingNo>>>>>' + mapWrappWithBillingNo);
            if (!mapWrappWithBillingNo.isEmpty()) {
                system.debug('in map is not empty>>>>>>>>');
                List<RW_Demand__c> lstDemand = [
                    SELECT Id, Booking__c, RW_Billing_Document_Number__c, Due_Date__c, SAP_Customer_Number__c, Project_Code__c,
                    SAP_Slab_Code__c, Demand_Amount__c, Interest_Days__c, Remaining_Amount__c,
                    Total_Interest_Amount__c, Net_Interest_Amount__c, Previously_Waived_Amount_SAP__c, Total_Demand_Paid__c,
                    SAP_Slab_Description__c, Unit_No__c
                    FROM RW_Demand__c
                    WHERE RW_Billing_Document_Number__c IN :mapWrappWithBillingNo.keySet()
                ];
                system.debug('lstDemand>>>>' +lstDemand);
                for (RW_Demand__c objDemand : lstDemand) {
                    WrapperIntWaiverAPI.items item = mapWrappWithBillingNo.get(objDemand.RW_Billing_Document_Number__c);
                    if (item != null) {
                        system.debug('Items are not null before mapping>>>>>>' +item);
                        if (item.int_amt != null){
                            objDemand.Total_Interest_Amount__c = item.int_amt;
                        }
                        if (item.waived_amt != null){
                            objDemand.Previously_Waived_Amount_SAP__c = item.waived_amt;
                        }
                        if (item.net_int_amt != null){
                            objDemand.Net_Interest_Amount__c = item.net_int_amt;
                        }
                        if (item.int_days != null){
                            objDemand.Interest_Days__c = item.int_days;
                        }
                        if (item.sgtxt != null){
                            objDemand.SAP_Slab_Description__c = item.sgtxt;
                        }
                        if (item.mlbez != null){
                            objDemand.SAP_Slab_Code__c = item.mlbez;
                        }
                        if (item.unit_no != null){
                            objDemand.Unit_No__c = item.unit_no;
                        }
                        lstToUpdateDemand.add(objDemand);
                    }
                }
            }
        }
        if (!lstToUpdateDemand.isEmpty()) {
            system.debug('Before Update>>>>>' +lstToUpdateDemand);
            // Database.update(lstToUpdateDemand);
            Database.SaveResult[] updateResults = Database.update(lstToUpdateDemand, true); 
            system.debug('updateResults>>>' +updateResults);
            if(updateResults != null && updateResults.size()>0){
                for (Database.SaveResult sr : updateResults) {
                    if (!sr.isSuccess()) {
                        // Record updated successfully
                        System.debug('Record with ID ' + sr.getId() + ' updated successfully.');
                        for (Database.Error error : sr.getErrors()) {
                            SAP_IntegrationHelper.insertLogEntry('Demand Interest', response.getStatus(), null, null, '', '', error.getMessage(), '');
                            
                            System.debug('Error updating record: ' + error.getMessage());
                            System.debug('Fields affected: ' + error.getFields());
                            System.debug('Error Status Code: ' + error.getStatusCode());
                        }
                    } 
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug('in Finish>>> has_more = ' + has_more);
        
        try {
            if (has_more) {
                system.debug(' in if has_more>>>.'+has_more);
                Database.executeBatch(new Batch_IntWaiverAPICallout());
            }  
            
        } catch(Exception e) {
            system.debug('e>>>.'+e.getMessage());
        }
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new Batch_IntWaiverAPICallout());
    }
}