public class TemporaryBatchIrisAPIReceiptRestCallout implements Database.Batchable<sObject>,Database.AllowsCallouts {
     public  List<Id> oppIds = new List<Id>();
    
    
    public TemporaryBatchIrisAPIReceiptRestCallout(List<Id> opporIds)
    {
        oppIds.addAll(opporIds);
    }
    
    public DataBase.QueryLocator start(Database.BatchableContext bc)
    {
        String Query = 'select id,Name,RW_Payment_Mode__c,RW_Instrument_Number__c,RW_Status_Code__c,RW_Posting_Date__c,RW_Accounting_Document_Number__c,RW_Bank_Reference_Number__c,RW_Booking__c,RW_Branch_Name__c,RW_Clearing_Document_Number__c,RW_Company_Code__c,Total_Amount_Paid__c,RW_Payment_Date__c,RW_Iris_Synced__c from RW_Payment_Details__c where RW_Booking__r.Source_of_Booking__c = \'Channel Partner\' and RW_Document_Type__c != \'AB\' and RW_Booking__c IN:oppIds' ;
        system.debug('*entered BatchIrisAPIReceiptRestCallout start*'+Database.getQueryLocator(Query));
        return Database.getQueryLocator(Query);
        
    }
    
    public void execute(DataBase.BatchableContext bc , List<RW_Payment_Details__c> paydets)
    { set<id> reversalId=new set<id>();
        List< ERP_Integration_Log__c> loglist = new List<ERP_Integration_Log__c>();
        Map<string,list<RW_Payment_Details__c>> bookingtoPdmap = new map<string,list<RW_Payment_Details__c>>();
        for(RW_Payment_Details__c pd : paydets){
            if(bookingtoPdmap.containsKey(pd.RW_Booking__c)){
                list<RW_Payment_Details__c> pds = new list<RW_Payment_Details__c>();
                pds = bookingtoPDmap.get(pd.RW_Booking__c);
                pds.add(pd);
                system.debug('*added in if bookingtoPDMap*');
                bookingtoPDMap.put(pd.RW_Booking__c,pds);
            }else
            {
                system.debug('*added in else bookingtoPDMap*');
                bookingtoPDMap.put(pd.RW_Booking__c,new List<RW_Payment_Details__c>{pd});
            }
        }
        
      //  map<string,IrisAPIReceiptJson> updateReceipts = new        map<string,IrisAPIReceiptJson>();
        
        system.debug(bookingtoPDMap);
        List<Booking__c> bkList = [select id,Quotation__r.Agreement_Value__c,Quotation__r.Grand_Total__c,RW_Stop_IRIS_Sync__c,Customer__c,Unit_No__c
                                   , BrokerIId__r.RW_CreateFromIRIS__c ,Source_of_Booking__c,BrokerIId__c,Unit_No__r.Unit_SAP_Code__c,Unit_no__r.Bed_Rooms__c,Unit_No__r.New_Floor__c,RW_Synced_with_IRIS__c,RW_X9_99_Received__c
                                   from booking__c where id in : bookingtoPDMap.keyset()];
        list<RW_Payment_Details__c> updatesync = new list<RW_Payment_Details__c>();
        for(Booking__c bk : bkList){
            system.debug('*before for*');
            if(bk.Source_of_Booking__c == 'Channel Partner' && bk.BrokerIId__c != null && bk.BrokerIId__R.RW_CreateFromIRIS__c ){
                system.debug('*inside if for*');
                if(bk.RW_Synced_with_IRIS__c){
                    List<RW_Payment_Details__c> pdList =     bookingtoPDMap.get(bk.id);
                    
                    IrisAPIBookingDetailJson objJson  = new IrisAPIBookingDetailJson();
                    IrisAPIBookingDetailJson.cls_booking_detail clsBookingDetails = new IrisAPIBookingDetailJson.cls_booking_detail();
                    List<IrisAPIBookingDetailJson.cls_receipts_attributes> listOfreceiptAtt = new List<IrisAPIBookingDetailJson.cls_receipts_attributes>();
                    
                    
                    for(RW_Payment_Details__c pd: pdList){
                        if( ! bk.RW_X9_99_Received__c  && !bk.RW_Stop_IRIS_Sync__c)
                        {//if iris is synce there we need to use update API
                                if(!pd.RW_Iris_Synced__c && pd.RW_Status_Code__c == null){
                                //build the insert receipts list
                                IrisAPIBookingDetailJson.cls_receipts_attributes rec = new IrisAPIBookingDetailJson.cls_receipts_attributes();
                                system.debug(pd.RW_Payment_Date__c);
                                system.debug(pd.RW_Payment_Date__c.year());
                                system.debug( DateTime.newInstance( pd.RW_Payment_Date__c.year(), pd.RW_Payment_Date__c.month(), pd.RW_Payment_Date__c.day(),5,30,0).format('dd/MM/yyyy'));
                                rec.issued_date = DateTime.newInstance( pd.RW_Payment_Date__c.year(), pd.RW_Payment_Date__c.month(), pd.RW_Payment_Date__c.day()).format('dd/MM/yyyy');
                                rec.processed_on = DateTime.newInstance( pd.RW_Posting_Date__c.year(), pd.RW_Posting_Date__c.month(), pd.RW_Posting_Date__c.day()).format('dd/MM/yyyy');
                                rec.total_amount= pd.Total_Amount_Paid__c;
                                rec.payment_identifier = pd.RW_Instrument_Number__c;
                                
                                rec.reference_id = pd.Id;
                                if(pd.RW_Status_Code__c == null){
                                    rec.status = 'success';
                                }
                                
                                listOfreceiptAtt.add(rec);
                            }else{
                                system.debug('*cancellation reversal else*');
                                //build the update list
/*                                IrisAPIReceiptJson recjson = new IrisAPIReceiptJson();
                                IrisAPIReceiptJson.cls_receipt rec1 = new IrisAPIReceiptJson.cls_receipt();
                                
                                rec1.issued_date = DateTime.newInstance( pd.RW_Payment_Date__c.year(), pd.RW_Payment_Date__c.month(), pd.RW_Payment_Date__c.day()).format('d/MM/YYYY');
                                rec1.processed_on = DateTime.newInstance( pd.RW_Posting_Date__c.year(), pd.RW_Posting_Date__c.month(), pd.RW_Posting_Date__c.day()).format('d/MM/YYYY');
                                rec1.total_amount= pd.Total_Amount_Paid__c;
                                rec1.payment_identifier = pd.RW_Instrument_Number__c;
                                
                                rec1.reference_id = pd.Id;
                                if(pd.RW_Status_Code__c == null)
                                    rec1.status = 'success';
                                else
                                    rec1.status ='revoke';
                                recjson.receipt = rec1;
                                updateReceipts.put(pd.id,recjson);*/
                                if(pd.RW_Iris_Synced__c && pd.RW_Status_Code__c != null){
                                    // build the reversal set 
                                    // 
                                    reversalId.add(pd.id);
                                     system.debug('*cancellation reversal idss*'+pd.id);
                                }
                            }
                        }
                    } 
                    if(listOfreceiptAtt.size()>0){
                        clsBookingDetails.receipts_attributes =  listOfreceiptAtt;
                        
                        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                        log.API_name__c = 'IRIS Channel Partner';
                        log.Booking__c = bk.id;
                        
                        objJson.booking_detail = clsBookingDetails;
                        system.debug('_____objJson  '+objJson);
                        string str = System.JSON.serialize(objJson);
                        
                        system.debug('____JsonStr  '+str);
                        
                        log.Request__c=str;
                        //callout
                        try{
                            Http http = new Http();
                            HttpRequest req = new HttpRequest(); 
                            req.setMethod('PATCH');
                            req.setHeader('Content-Type',  'application/json');
                            req.setTimeout(60000);
                       //     req.setHeader('Client-key', 'f389fd4bf4e34a772a2a5946b5b159a0'); 
                         //   req.setHeader('Client-id', '5fa1990f62d4a723cee0e6a3'); 
                             req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
      
                            req.setEndpoint(System.label.RW_IRIS_Endpoint+'booking_details/'+bk.Id);
                            req.setBody(str);
                            HTTPResponse res = http.send(req);
                            System.debug('res!!! getBody '+res.getBody());
                            System.debug('res!!! getStatusCode '+res.getStatusCode());
                            log.Response__c =res.getBody();
                            
                            
                            if(res.getStatusCode() == 200 || res.getStatusCode()==201){
                                log.Status__c = 'Success';
                                for( IrisAPIBookingDetailJson.cls_receipts_attributes rec  :objJson.booking_detail.receipts_attributes){
                                    RW_Payment_Details__c pd = new RW_Payment_Details__c();
                                    pd.Id = rec.reference_id;
                                    pd.RW_Iris_Synced__c = true;
                                    updatesync.add(pd);
                                }
                                
                            }else{
                                log.Status__c = 'Failure';
                                log.Error_Type__c='Data Error';
                            }
                        }
                        catch(exception e){
                            
                            log.Status__c = 'Failure';
                            log.Error_Type__c = 'Timeout Error';
                            log.Error_Reason__c = e.getMessage();
                        }
                        finally{
                            loglist.add(log);
                            
                        }
                    }
                }else{
                    
                }
            }
            //if booking is iris synced and receipt is not iris synced then call iris payment created
            //call booking create
            //pass the cancellation set to below method
        
            if(reversalId != null && reversalId.size() >0)
            ReceiptRestCalloutPATCH(reversalId);//updateReceipts);
                if(loglist.size()>0)
                insert loglist;
            if(updatesync.size()>0)
                update updatesync;
        }
        
    }
    
    public static void ReceiptRestCalloutPATCH(set<id> receiptIds){ //Map<string,IrisAPIReceiptJson> recList){
        //modify this method to have the new json
        system.debug('*inside ReceiptRestCalloutPATCH*'+receiptIds);
        List< ERP_Integration_Log__c> loglist = new List<ERP_Integration_Log__c>();
        for(string rec : receiptIds){
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'IRIS Channel Partner';
            log.RW_Payment_Details__c = rec;
            log.Request__c='{"user_request":{"receipt_id": "'+rec+'","type": "cancellation"}}';                 
          //  system.debug('____JsonStr  '+str);
            try{
                Http http = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setMethod('POST');
                req.setHeader('Content-Type',  'application/json');
                req.setTimeout(60000);
           //     req.setHeader('Client-key', 'f389fd4bf4e34a772a2a5946b5b159a0'); 
             //   req.setHeader('Client-id', '5fa1990f62d4a723cee0e6a3'); 
                 req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
      
                req.setEndpoint(System.label.RW_IRIS_Endpoint+'user_requests/');
                //build receipt structure
               req.setBody('{"user_request":{"receipt_id": "'+rec+'","type": "cancellation"}}');
                HTTPResponse res = http.send(req);
                System.debug('res!!! getBody '+res.getBody());
                System.debug('res!!! getStatusCode '+res.getStatusCode());
                
                log.Response__c =res.getBody();
                
                
                if(res.getStatusCode() == 200 || res.getStatusCode()==201){
                    log.Status__c = 'Success';
                    
                }else{
                    log.Status__c = 'Failure';
                    log.Error_Type__c='Data Error';
                }
            }
            catch(exception e){
                
                log.Status__c = 'Failure';
                log.Error_Type__c = 'Timeout Error';
                log.Error_Reason__c = e.getMessage();
            }finally{
                loglist.add(log);
            }
        }
        
        
       /* for(string key : recList.keySet()){
            string str = System.JSON.serialize(recList.get(key));
            
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'IRIS Channel Partner';
            log.RW_Payment_Details__c = key;
            log.Request__c=str;                 
            system.debug('____JsonStr  '+str);
            //callout
            try{
                Http http = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setMethod('POST');
                req.setHeader('Content-Type',  'application/json');
           //     req.setHeader('Client-key', 'f389fd4bf4e34a772a2a5946b5b159a0'); 
             //   req.setHeader('Client-id', '5fa1990f62d4a723cee0e6a3'); 
                 req.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
            req.setHeader('Client-id', System.label.RW_Iris_clientid); 
      
                req.setEndpoint(System.label.RW_IRIS_Endpoint+'user_requests/');
                req.setBody(str);
                HTTPResponse res = http.send(req);
                System.debug('res!!! getBody '+res.getBody());
                System.debug('res!!! getStatusCode '+res.getStatusCode());
                
                log.Response__c =res.getBody();
                
                
                if(res.getStatusCode() == 200 || res.getStatusCode()==201){
                    log.Status__c = 'Success';
                    
                }else{
                    log.Status__c = 'Failure';
                    log.Error_Type__c='Data Error';
                }
            }
            catch(exception e){
                
                log.Status__c = 'Failure';
                log.Error_Type__c = 'Timeout Error';
                log.Error_Reason__c = e.getMessage();
            }finally{
                loglist.add(log);
            }
        }*/
        if(loglist.size()>0){
            insert loglist;
        }
    }
    
    public void finish(Database.BatchableContext bc)
    {
        
    }
}