public class GetSAPReceiptsForCustomer {
    
    @AuraEnabled
    public static void customerReceipts(String bkgId){
        
        Booking__c bkg = [SELECT Id, Opportunity__c, Opportunity__r.SAP_Customer_Number__c FROM Booking__c WHERE Id =: bkgId];
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        
        
        
        String crn = bkg.Opportunity__r.SAP_Customer_Number__c;
        Datetime d = system.now();
        String timeStamp = String.valueOf(d.format('yyyyMMddHHmmss'));
        
        String username = Label.SAP_Username;
        String password = Label.SAP_Password;
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        
        String endPoint = System.label.SAP_Receipts_for_Customer;
        endPoint += '&CUSTOMER_CODE='+crn+'&TIMESTAMP='+timeStamp;
        String jsonBody;
        request.setEndpoint(endPoint);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        request.setHeader('Authorization', authorizationHeader);
        request.setTimeout(120000);
        if(!Test.isRunningTest()){
            response = http.send(request);
            if(response.getStatusCode() == 200){
                jsonBody = response.getBody();
            }else{
                System.debug('Fail');
                System.debug('Response: ' + response);
                ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
                erp.API_Name__c = 'Receipts API';
                erp.Status__c = 'Failure';
                erp.Request__c =timestamp;
                //  erp.Response__c = ;
                erp.Error_Reason__c = response.getBody();
                erp.Error_Type__c = 'Data Error';
                insert erp;
            }
        }else{
            jsonBody = '[{"BELNR":"0010000418","BUKRS":"1000","GJAHR":2020,"H_BLART":"AB","BLDAT":"2019-05-31","BKTXT":"","H_BUDAT":"2019-05-31","DMBTR":30595.58,"ZUONR":"0000000194-000012","KUNNR":"12345678","ZODN":"","ZSTATUS_CODE":"","ZSTATUS_DESCP":"","AUGBL":"0140002906","ZDEMAND":"12345678","XREF1":"Z0012","SGTXT":"ON COMPLETION OF 35th FLOOR","BUZEI":1,"POSNR":10}]';
        }
        
        
        List<respData> respList = (List<respData>)JSON.deserialize(jsonBody, List<respData>.class);
        List<String> chequeCode = system.label.SAP_Cheque_Codes.split(',');
        List<String> uniqueIdsList = new List<String>();
        Map<String, respData> respMap = new Map<String, respData>();
        Map<String,String> demandnumberMap = new Map<String,String>();
        set<string> processed = new set<string>();
        Map<String,receiptWrapper> mapOfReceiptWrapperwithoutbooking = new Map<String,receiptWrapper>();
        set<string>uniqpaymentitemid= new set<string>();
        try{
            System.debug('Success');
            System.debug('Response: ' + response.getBody());
            
            
            
            
            for(respData resp : respList){
                String uniqueId = resp.BELNR+'|'+resp.GJAHR+'|'+resp.BUKRS;
                uniqueIdsList.add(uniqueId);
                respMap.put(uniqueId, resp);
                if(resp.ZDEMAND != null && resp.ZDEMAND != ''){
                    demandnumberMap.put(resp.ZDEMAND,resp.KUNNR);
                }
            }
            System.debug('demandnumberMap: ' + demandnumberMap);
            Map<String, RW_Demand__c> MapofDemandNumWithDemand = new Map<String, RW_Demand__c>();
            List<RW_Demand__c> ListOfDemands = [select id, name, RW_Customer_Number__c,RW_Billing_Document_Number__c, (select id,RW_Demand_Item_Number__c,Total_Demand_Item_Amount_Paid__c, name,RW_Legacy_Amount_Paid__c,RW_Legacy_Demand__c from Demand_Items__r) from RW_Demand__c where RW_Billing_Document_Number__c In: demandnumberMap.keyset()]; 
            for(RW_Demand__c demandList : ListOfDemands){
                MapofDemandNumWithDemand.put(demandList.RW_Billing_Document_Number__c, demandList);
            }
            
            List<String> ExistingUniqueIdsList = new List<String>();
            List<RW_Payment_Details__c> ListToUpdatePayment = new List<RW_Payment_Details__c>();
            List<RW_Payment_Details__c> PaymentDetailsWithUniqueKey = [select id,RW_UniqueId__c,RW_Clearing_Document_Number__c, name, RW_Customer_ID__c,RW_Status_Code__c,RW_Status_Description__c from RW_Payment_Details__c where RW_UniqueId__c  In: uniqueIdsList];
            for(RW_Payment_Details__c PaymentUnique : PaymentDetailsWithUniqueKey){
                if(respMap.ContainsKey(PaymentUnique.RW_UniqueId__c)){
                    if((PaymentUnique.RW_Status_Code__c == null || PaymentUnique.RW_Status_Description__c == null || PaymentUnique.RW_Status_Code__c == '' || PaymentUnique.RW_Status_Description__c == '') 
                       && (respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_CODE !=null || respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_DESCP !=null || respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_CODE !='' || respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_DESCP !='' )&&
                       (PaymentUnique.RW_Status_Code__c!= respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_CODE || PaymentUnique.RW_Status_Description__c!= respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_DESCP)){
                           PaymentUnique.RW_Status_Code__c = respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_CODE;
                           PaymentUnique.RW_Status_Description__c = respMap.get(PaymentUnique.RW_UniqueId__c).ZSTATUS_DESCP;
                           PaymentUnique.RW_Document_Type__c = respMap.get(PaymentUnique.RW_UniqueId__c).H_BLART;
                           PaymentUnique.RW_Booking__c = bkgId;
                           ListToUpdatePayment.add(PaymentUnique);
                       }else if((PaymentUnique.RW_Clearing_Document_Number__c== null && respMap.get(PaymentUnique.RW_UniqueId__c).AUGBL != null)|| 
                                (PaymentUnique.RW_Clearing_Document_Number__c != respMap.get(PaymentUnique.RW_UniqueId__c).AUGBL)){
                                    PaymentUnique.RW_Clearing_Document_Number__c = respMap.get(PaymentUnique.RW_UniqueId__c).AUGBL;
                                    PaymentUnique.RW_Booking__c = bkgId;
                                    ListToUpdatePayment.add(PaymentUnique);
                                }
                    ExistingUniqueIdsList.add(PaymentUnique.RW_UniqueId__c);
                    
                }
            }
            
            if(ListToUpdatePayment.size()>0){
                update ListToUpdatePayment;
            }
            System.debug('ListToUpdatePayment: ' + ListToUpdatePayment);
            List<Opportunity> oppList = [Select Id, Name,SAP_Customer_Number__c,Booking__c, (Select id,Name FROM EOI__r) from Opportunity where SAP_Customer_Number__c =: crn and StageName IN ('Unit Booked','EOI Received')];
            
            
            Map<String,receiptWrapper> mapOfReceiptWrapper = new Map<String,receiptWrapper>();
            for(respData responseRec : respList){
                String UniqueIdsPayment = responseRec.BELNR+'|'+responseRec.GJAHR+'|'+responseRec.BUKRS;
                if(chequeCode.contains(responseRec.H_BLART) && !ExistingUniqueIdsList.Contains(UniqueIdsPayment) ){
                    System.debug('--98--');
                    if(oppList[0].SAP_Customer_Number__c == responseRec.KUNNR){
                        System.debug('--100--');
                        if(!mapOfReceiptWrapper.ContainsKey(UniqueIdsPayment) || mapOfReceiptWrapper.get(UniqueIdsPayment).paymentDetails.RW_Customer_ID__c !=responseRec.kunnr){
                            System.debug('--102--');
                            receiptWrapper receiptWrapper = new receiptWrapper();
                            receiptWrapper.paymentDetails  = new RW_Payment_Details__c();
                            receiptWrapper.paymentDetailsItems = new List<RW_Payment_Detail_Item__c>();
                            receiptWrapper.paymentDetails.RW_Customer_ID__c = responseRec.KUNNR;
                            receiptWrapper.paymentDetails.RW_Payment_Date__c = Date.valueOf(responseRec.BLDAT);
                            receiptWrapper.paymentDetails.RW_Posting_Date__c = Date.valueOf(responseRec.H_BUDAT);
                            receiptWrapper.paymentDetails.RW_Document_Type__c = responseRec.H_BLART;
                            receiptWrapper.paymentDetails.RW_Instrument_Number__c = responseRec.ZUONR;
                            if(responseRec.DMBTR != null && responseRec.DMBTR !='')                   
                                receiptWrapper.paymentDetails.RW_Payment_Amount__c =  Decimal.valueOf(responseRec.DMBTR);
                            receiptWrapper.paymentDetails.RW_Fiscal_Year__c = responseRec.GJAHR;
                            receiptWrapper.paymentDetails.RW_Accounting_Document_Number__c = responseRec.BELNR; 
                            receiptWrapper.paymentDetails.RW_Company_Code__c=responseRec.BUKRS;
                            receiptWrapper.paymentDetails.RW_Bank_Name__c=responseRec.BKTXT;
                            receiptWrapper.paymentDetails.RW_Status_Description__c = responseRec.ZSTATUS_DESCP;
                            receiptWrapper.paymentDetails.RW_Clearing_Document_Number__c = responseRec.AUGBL;
                            receiptWrapper.paymentDetails.RW_Status_Code__c=responseRec.ZSTATUS_CODE;
                            receiptWrapper.paymentDetails.RW_ODN_Number__c = responseRec.ZODN;
                            receiptWrapper.paymentDetails.RW_Payment_Item_Number__c = responseRec.BUZEI;
                            receiptWrapper.paymentDetails.RW_Demand_Number__c =responseRec.ZDEMAND;
                            receiptWrapper.paymentDetails.RW_Usage_Description__c = responseRec.SGTXT;
                            receiptWrapper.paymentDetails.RW_Usage_Code__c = responseRec.XREF1;
                            system.debug('$$$$$$$$$');
                            system.debug(receiptWrapper);
                            receiptWrapper.paymentDetails.Opportunity__c =  oppList[0].Id;
                            receiptWrapper.paymentDetails.RW_Booking__c = oppList[0].Booking__c;
                            
                            RW_Payment_Detail_Item__c PaymentItems = new RW_Payment_Detail_Item__c();
                            PaymentItems.RW_Accounting_Document_Number__c = responseRec.BELNR;
                            PaymentItems.RW_Customer_Number__c = Decimal.valueOf(responseRec.KUNNR);
                            PaymentItems.RW_Demand_Number__c = responseRec.ZDEMAND;
                            PaymentItems.RW_Amount__c = Decimal.valueOf(responseRec.DMBTR);
                            PaymentItems.RW_Usage_Code__c = responseRec.XREF1;
                            PaymentItems.RW_Usage_Description__c = responseRec.SGTXT;
                            PaymentItems.RW_Payment_Item_Number__c = responseRec.BUZEI;
                            PaymentItems.RW_Instrument_Number__c = responseRec.ZUONR;
                            PaymentItems.RW_Demand_Item_Number__c = responseRec.POSNR;
                            system.debug(MapofDemandNumWithDemand);
                            
                            if( MapofDemandNumWithDemand.containsKey(responseRec.ZDEMAND)){
                                System.debug('--142--');
                                for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.ZDEMAND).Demand_Items__r){
                                    if( MapofDemandNumWithDemand.get(responseRec.ZDEMAND).Demand_Items__r.size()==1){
                                        PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.ZDEMAND).Demand_Items__r[0].Id;
                                    }else {
                                        if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR))
                                            PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                    }
                                }
                            }
                            
                            receiptWrapper.paymentDetailsItems.add(PaymentItems);
                            mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                            processed.add(UniqueIdsPayment);
                            
                        }else{
                            System.debug('--159--');
                            receiptWrapper receiptWrapper =mapOfReceiptWrapper.get(UniqueIdsPayment);
                            RW_Payment_Detail_Item__c PaymentItems = new RW_Payment_Detail_Item__c();
                            
                            PaymentItems.RW_Accounting_Document_Number__c = responseRec.Belnr;
                            PaymentItems.RW_Customer_Number__c = Decimal.valueOf(responseRec.kunnr);
                            PaymentItems.RW_Demand_Number__c = responseRec.Zdemand;
                            PaymentItems.RW_Amount__c = Decimal.valueOf(responseRec.Dmbtr);
                            PaymentItems.RW_Usage_Code__c = responseRec.Xref1;
                            PaymentItems.RW_Usage_Description__c = responseRec.Sgtxt;
                            PaymentItems.RW_Payment_Item_Number__c = responseRec.Buzei;
                            PaymentItems.RW_Instrument_Number__c = responseRec.Zuonr;
                            PaymentItems.RW_Demand_Item_Number__c = responseRec.POSNR;
                            system.debug(MapofDemandNumWithDemand);
                            
                            if(MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)){
                                for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r){  
                                    if( MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r.size()==1){
                                        PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].Id;
                                    }else{
                                        if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR))
                                            PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                    }
                                }
                            }
                            receiptWrapper.paymentDetailsItems.add(PaymentItems);
                            mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                        }
                    }else{
                        System.debug('--188--');
                        system.debug(processed);
                        if(! processed.contains(UniqueIdsPayment)){
                            System.debug('--191--');
                            if(!mapOfReceiptWrapperwithoutbooking.ContainsKey(UniqueIdsPayment) ||  mapOfReceiptWrapperwithoutbooking.get(UniqueIdsPayment).paymentDetails.RW_Customer_ID__c != responseRec.kunnr){
                                system.debug('MKmapOfReceiptWrapperwithoutbooking'+responseRec);
                                System.debug('--194--');
                                receiptWrapper receiptWrapperw = new receiptWrapper();
                                receiptWrapperw.paymentDetails  = new RW_Payment_Details__c();
                                receiptWrapperw.paymentDetailsItems = new List<RW_Payment_Detail_Item__c>();
                                receiptWrapperw.paymentDetails.RW_Customer_ID__c = responseRec.kunnr;
                                receiptWrapperw.paymentDetails.RW_Payment_Date__c = Date.valueOf(responseRec.Bldat);
                                receiptWrapperw.paymentDetails.RW_Posting_Date__c = Date.valueOf(responseRec.H_BUDAT);
                                receiptWrapperw.paymentDetails.RW_Document_Type__c = responseRec.H_BLART;
                                receiptWrapperw.paymentDetails.RW_Instrument_Number__c = responseRec.Zuonr;
                                if(responseRec.Dmbtr != null && responseRec.Dmbtr !='')                   
                                    receiptWrapperw.paymentDetails.RW_Payment_Amount__c =  Decimal.valueOf(responseRec.Dmbtr);
                                receiptWrapperw.paymentDetails.RW_Fiscal_Year__c = responseRec.Gjahr;
                                receiptWrapperw.paymentDetails.RW_Accounting_Document_Number__c = responseRec.Belnr; 
                                receiptWrapperw.paymentDetails.RW_Company_Code__c=responseRec.Bukrs;
                                receiptWrapperw.paymentDetails.RW_Bank_Name__c=responseRec.Bktxt;
                                receiptWrapperw.paymentDetails.RW_Status_Description__c = responseRec.ZSTATUS_DESCP;
                                receiptWrapperw.paymentDetails.RW_Clearing_Document_Number__c = responseRec.Augbl;
                                receiptWrapperw.paymentDetails.RW_Status_Code__c=responseRec.ZSTATUS_CODE;
                                receiptWrapperw.paymentDetails.RW_ODN_Number__c = responseRec.Zodn;
                                receiptWrapperw.paymentDetails.RW_Payment_Item_Number__c = responseRec.Buzei;
                                receiptWrapperw.paymentDetails.RW_Demand_Number__c =responseRec.Zdemand;
                                receiptWrapperw.paymentDetails.RW_Usage_Description__c = responseRec.Sgtxt;
                                receiptWrapperw.paymentDetails.RW_Usage_Code__c = responseRec.Xref1;
                                system.debug('$$$$$$$$$');
                                system.debug(receiptWrapperw);
                                // receiptWrapperw.paymentDetails.RW_Demand__c = MapOfDemandWithCustomerId.get(responseRec.kunnr).Id;
                                //below section builds payment detail items
                                RW_Payment_Detail_Item__c PaymentItems = new RW_Payment_Detail_Item__c();
                                PaymentItems.RW_Accounting_Document_Number__c = responseRec.Belnr;
                                PaymentItems.RW_Customer_Number__c = Decimal.valueOf(responseRec.kunnr);
                                PaymentItems.RW_Demand_Number__c = responseRec.Zdemand;
                                PaymentItems.RW_Amount__c = Decimal.valueOf(responseRec.Dmbtr);
                                PaymentItems.RW_Usage_Code__c = responseRec.Xref1;
                                PaymentItems.RW_Usage_Description__c = responseRec.Sgtxt;
                                PaymentItems.RW_Payment_Item_Number__c = responseRec.Buzei;
                                PaymentItems.RW_Instrument_Number__c = responseRec.Zuonr;
                                PaymentItems.RW_Demand_Item_Number__c = responseRec.POSNR;
                                uniqpaymentitemid.add(UniqueIdsPayment+'|'+responseRec.Buzei);
                                
                                receiptWrapperw.paymentDetailsItems.add(PaymentItems);
                                //build the payment detail and detail item wrapper
                                mapOfReceiptWrapperwithoutbooking.put(UniqueIdsPayment, receiptWrapperw);
                                
                            }else{
                                System.debug('--238--');
                                if(!uniqpaymentitemid.contains(UniqueIdsPayment+'|'+responseRec.Buzei)){
                                    System.debug('--240--');
                                    receiptWrapper receiptWrapperw =mapOfReceiptWrapperwithoutbooking.get(UniqueIdsPayment);
                                    RW_Payment_Detail_Item__c PaymentItems = new RW_Payment_Detail_Item__c();
                                    
                                    PaymentItems.RW_Accounting_Document_Number__c = responseRec.Belnr;
                                    PaymentItems.RW_Customer_Number__c = Decimal.valueOf(responseRec.kunnr);
                                    PaymentItems.RW_Demand_Number__c = responseRec.Zdemand;
                                    PaymentItems.RW_Amount__c = Decimal.valueOf(responseRec.Dmbtr);
                                    PaymentItems.RW_Usage_Code__c = responseRec.Xref1;
                                    PaymentItems.RW_Usage_Description__c = responseRec.Sgtxt;
                                    PaymentItems.RW_Payment_Item_Number__c = responseRec.Buzei;
                                    PaymentItems.RW_Instrument_Number__c = responseRec.Zuonr;
                                    PaymentItems.RW_Demand_Item_Number__c = responseRec.POSNR;
                                    uniqpaymentitemid.add(UniqueIdsPayment+'|'+responseRec.Buzei);
                                    
                                    receiptWrapperw.paymentDetailsItems.add(PaymentItems);
                                    mapOfReceiptWrapperwithoutbooking.put(UniqueIdsPayment, receiptWrapperw);
                                }
                            }
                        }
                    }
                }
            }
            
            List<RW_Payment_Details__c> receiptToInsert = new List<RW_Payment_Details__c>();
            for(receiptWrapper dw : mapOfReceiptWrapper.values()){
                receiptToInsert.add(dw.paymentDetails);
            }
            system.debug('receiptToInsert------->' + receiptToInsert.size());
            
            insert  receiptToInsert;
            set<id> payid = new set<id>();
            for(RW_Payment_Details__c rc : receiptToInsert){
                payid.add(rc.id);
            }
            
            List<RW_Payment_Details__c> pac=   [select id,RW_UniqueId__c,RW_Customer_ID__c, RW_Document_Type__c from RW_Payment_Details__c where id in : payid];
            List<RW_Payment_Detail_Item__c> receiptItemToInsert = new List<RW_Payment_Detail_Item__c>();
            
            Map<String,String> CnumPayIdMap = new Map<String,String>();
            for(RW_Payment_Details__c pd : pac){
                CnumPayIdMap.put(pd.RW_Customer_ID__c,pd.id);
                system.debug(pd.RW_UniqueId__c);
                if(mapOfReceiptWrapper.containsKey(pd.RW_UniqueId__c)){
                    List<RW_Payment_Detail_Item__c> paymentDetailsItems = mapOfReceiptWrapper.get(pd.RW_UniqueId__c).paymentDetailsItems;
                    system.debug(paymentDetailsItems.size());
                    for(RW_Payment_Detail_Item__c pdi : paymentDetailsItems){
                        pdi.RW_Payment_Details__c = pd.Id;
                        //Added by coServe 20-07-2022 Start
                        if(pd.RW_Document_Type__c == 'DE' || pd.RW_Document_Type__c == 'D1'){
                            pdi.RW_Amount__c = - pdi.RW_Amount__c;
                        }
                        //Added by coServe 20-07-2022 End
                    }
                    
                    receiptItemToInsert.addAll(paymentDetailsItems);
                }
            }
            system.debug('receiptItemToInsert------>'+receiptItemToInsert.size());
            if(receiptItemToInsert.size()>0)
                insert  receiptItemToInsert;
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Receipts API';
            erp.Status__c = 'Failure';
            erp.Request__c =timestamp;
            //  erp.Response__c = ;
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            insert erp;
        }
        
        List<RW_Payment_Details__c> receiptToInsertWB = new List<RW_Payment_Details__c>();
        
        for(receiptWrapper dw : mapOfReceiptWrapperwithoutbooking.values()){
            if(!processed.contains(dw.paymentDetails.RW_Accounting_Document_Number__c+'|'+dw.paymentDetails.RW_Fiscal_Year__c+'|'+dw.paymentDetails.RW_Company_Code__c))
                receiptToInsertWB.add(dw.paymentDetails);
        }
        system.debug('receiptToInsert------->' + receiptToInsertWB.size());
        
        insert  receiptToInsertWB;
        set<id> payidWB = new set<id>();
        for(RW_Payment_Details__c rc : receiptToInsertWB){
            payidWB.add(rc.id);
        }
        
        List<RW_Payment_Details__c> pacWB=   [select id,RW_UniqueId__c,RW_Customer_ID__c,RW_Document_Type__c from RW_Payment_Details__c where id in : payidWB];
        List<RW_Payment_Detail_Item__c> receiptItemToInsertWB = new List<RW_Payment_Detail_Item__c>();
        
        Map<String,String> CnumPayIdMapWB = new Map<String,String>();
        for(RW_Payment_Details__c pd : pacWB){
            CnumPayIdMapWB.put(pd.RW_Customer_ID__c,pd.id);
            system.debug(pd.RW_UniqueId__c);
            if(mapOfReceiptWrapperwithoutbooking.containsKey(pd.RW_UniqueId__c)){
                List<RW_Payment_Detail_Item__c> paymentDetailsItems = mapOfReceiptWrapperwithoutbooking.get(pd.RW_UniqueId__c).paymentDetailsItems;
                system.debug(paymentDetailsItems.size());
                for(RW_Payment_Detail_Item__c pdi : paymentDetailsItems)
                {
                    pdi.RW_Payment_Details__c = pd.Id;
                    //Added by coServe 20-07-2022 Start
                    if(pd.RW_Document_Type__c == 'DE' || pd.RW_Document_Type__c == 'D1'){
                        pdi.RW_Amount__c = - pdi.RW_Amount__c;
                    }
                    //Added by coServe 20-07-2022 End
                }
                
                receiptItemToInsertWB.addAll(paymentDetailsItems);}
        }
        //inserting payment detail item
        system.debug('receiptItemToInsert------>'+receiptItemToInsertWB.size());
        if(receiptItemToInsertWB.size()>0)
            insert  receiptItemToInsertWB;
        
        
    }
    
    public class respData{
        Public String BELNR;
        Public String BUKRS;
        Public String GJAHR;
        Public String H_BLART;
        Public String BLDAT;
        Public String BKTXT;
        Public String H_BUDAT;
        Public String DMBTR;
        Public String ZUONR;
        Public String KUNNR;
        Public String ZODN;
        Public String ZSTATUS_CODE;
        Public String ZSTATUS_DESCP;
        Public String AUGBL;
        Public String ZDEMAND;
        Public String XREF1;
        Public String SGTXT;
        Public String BUZEI;
        Public String POSNR;
        
    }
    
    class receiptWrapper{ 
        public RW_Payment_Details__c paymentDetails;
        public List<RW_Payment_Detail_Item__c> paymentDetailsItems;
    }
}