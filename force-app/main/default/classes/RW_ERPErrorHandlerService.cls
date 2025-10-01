public class RW_ERPErrorHandlerService implements Database.Batchable<sObject>,Database.Stateful ,   Database.AllowsCallouts{
    public String apiType;
    public integer batchsize;
    public string query;
    public integer retryCount;
    public string projectname;
    /* public void execute(SchedulableContext sc){
Database.executeBatch(new RW_ERPErrorHandlerService(),batchsize);
}*/
    /* public static void fetchtheerrorLog(){
Decimal retryCount = Decimal.valueOf( system.Label.RW_Max_Retry);
List<String>EmailAddress = system.Label.RW_Error_Admin_Mail.split(',');
List<ERP_Integration_Log__c> errList = [];
Map<String,	List<ERP_Integration_Log__c>> errMap = new    Map<String,	List<ERP_Integration_Log__c>>();
}
*/
    public RW_ERPErrorHandlerService(String apitype,string project){
        this.projectname =project;
        this.apiType=apitype; //this.batchsize=batchsize; 
        this.retryCount = Integer.valueOf( SYstem.Label.RW_Max_Retry	);
        this.query = 'SELECT API_Name__c,Booking__c,Car_Parking__c,Channel_Partner__c,CreatedById,CreatedDate,Error_Reason__c,Error_Type__c,Id,IsDeleted,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,Opportunity__c,OwnerId,Project_Unit__c,Project__c,Rate_List__c,Request__c,Response__c,Retry_Count__c,Status__c FROM ERP_Integration_Log__c where status__C = \'Failure\' and Retry_Count__c < :retryCount and Error_Type__c = \'Timeout Error\' and API_name__c=:apiType' ;
        system.debug(query);  
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, 
                        List<ERP_Integration_Log__c> scope){
                            
                            switch on apiType{ 
                                when 'Sales Order'{
                                    List<Opportunity> optyList = new List<Opportunity>();
                                    for(ERP_Integration_Log__c erp :scope){
                                        system.debug('%%%%%%%%%%%%%%%'+scope); 
                                        SalesOrderErrorLogger sLog= (SalesOrderErrorLogger)JSON.deserialize(erp.Request__c.replaceAll('&quot;','"'), SalesOrderErrorLogger.class);
                                        system.debug(sLog);
                                        SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER salesorder1 = new SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER();
                                        salesorder1.timeout_x = 60000;
                                        SalesOrderSAPAPIMCS.TableOfBapiret2 bapiRet2List = new SalesOrderSAPAPIMCS.TableOfBapiret2();
                                        bapiRet2List.item = new List<SalesOrderSAPAPIMCS.Bapiret2>();
                                        erp.Retry_Count__c =  erp.Retry_Count__c +1;
                                        try{
                                            SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element salesOrderResponse = 
                                                salesorder1.ZsdSdfcSalesOrder(sLog.billPlanList,sLog.CustomerNumber, sLog.orderConditionsList, sLog.orderHeader, sLog.orderItemsList, sLog.partnerFunctionList, bapiRet2List);
                                            system.debug(salesOrderResponse);
                                            if(salesOrderResponse.Salesdocument != null && salesOrderResponse.Salesdocument != '') {
                                                opportunity op = new Opportunity();
                                                op.SalesOrder_Number__c = salesOrderResponse.Salesdocument;
                                                op.id = erp.Opportunity__c;
                                                optyList.add(op);
                                                
                                            }
                                            erp.Status__c = 'Reprocessed';
                                            String responseF = JSON.SerializePretty(salesOrderResponse);
                                            responseF =  responseF.replaceAll('\n','<br/>');
                                            responseF  = responseF.replaceAll('\t', '&nbsp;');
                                            erp.Response__c =  responseF;
                                        }catch(exception e){
                                            
                                            
                                        }
                                        
                                    }
                                    if(optyList.size()>0){
                                        update optyList;
                                    }
                                    update scope;
                                }
                                when 'Customer Creation/Update' {
                                    set<id> oppIds = new set<id>();
                                    List<Opportunity> optyList = new List<Opportunity>();
                                    
                                    for(ERP_Integration_Log__c erp :scope){
                                        oppIds.add(erp.Opportunity__c);
                                        
                                        //  CustomerCreationErrorLogger cLog= (CustomerCreationErrorLogger)JSON.deserialize(erp.Request__c, CustomerCreationErrorLogger.class);
                                        
                                    }
                                    
                                    Map<id,Opportunity> opMap = New Map<id,Opportunity>([select id, SAP_Customer_Number__c	,SalesOrder_Number__c,Booking__r.Status__c from opportunity where id in : oppIds]);
                                    list<ERP_Integration_Log__c> newlogs = new List<ERP_Integration_Log__c>();
                                    for(ERP_Integration_Log__c erp :scope){
                                        erp.Retry_Count__c =  erp.Retry_Count__c +1;
                                        CustomerCreation.TableOfBapiret2 bapiRet2List = new CustomerCreation.TableOfBapiret2();
                                        bapiRet2List.item = new List<CustomerCreation.Bapiret2>();
                                        system.debug('^^^^^^^^^^^^^^^^^^^^'+erp.Request__c);
                                        CustomerCreationErrorLogger cLog= (CustomerCreationErrorLogger)JSON.deserialize(erp.Request__c.replaceAll('&quot;','"'), CustomerCreationErrorLogger.class);
                                        //if customer number is null
                                        Opportunity op = opMap.get(erp.Opportunity__c);
                                        if(cLog.customerHeader.Kunnr == null && op.SAP_Customer_Number__c != null){
                                            cLog.customerHeader.Kunnr = op.SAP_Customer_Number__c;
                                        }
                                        
                                        CustomerCreation.ZSD_SFDC_CUSTOMER customerCreation = new CustomerCreation.ZSD_SFDC_CUSTOMER();
                                        try{
                                            CustomerCreation.ZsdSfdcCustomerResponse_element customerCreationResponse = customerCreation.ZsdSfdcCustomer(cLog.customerAddressList,cLog.commList, cLog.coAppList,cLog.customerHeader,cLog.customerTaxList, bapiRet2List);
                                            System.debug('Customer creation response:' + customerCreationResponse);
                                            
                                            if(customerCreationResponse != null &&  customerCreationResponse.Customerno != null && customerCreationResponse.Customerno != '') {
                                                opportunity opt = new Opportunity();
                                                opt.SAP_Customer_Number__c = customerCreationResponse.Customerno ;
                                                opt.id = erp.Opportunity__c;
                                                String responseF = JSON.SerializePretty(customerCreationResponse);
                                                responseF =  responseF.replaceAll('\n','<br/>');
                                                responseF  = responseF.replaceAll('\t', '&nbsp;');
                                                erp.Response__c = responseF;
                                                erp.Status__c = 'Reprocessed';
                                                if(erp.Booking__c != null && op.SalesOrder_Number__c == null && op.Booking__r.status__c=='Booking Confirmed'){
                                                    String so=     SAPIntegrationServices.generateSalesOrder(new Set<id>{op.id},op.SAP_Customer_Number__c );
                                                    if(SO!= null)
                                                        opt.SalesOrder_Number__c = so;
                                                    newLogs.addALl(SAPIntegrationServices.erpLogList);
                                                }
                                                optyList.add(opt);
                                            }
                                        }   catch(exception e){
                                            
                                        }finally{
                                        }
                                        
                                    }
                                    update scope;
                                    if(optyList.size()>0){
                                        update optyList;
                                    }
                                    if(newLogs.size()>0)
                                        insert newLogs;
                                }
                                
                               /* when 'Channel Partner'{
                                    List<Broker__c> lstBroker = new list<Broker__c>();
                                    for(ERP_Integration_Log__c erp :scope){
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_HD  req = (    SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_HD  )json.deserialize(erp.Request__c,    SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_HD.class);
                                        SAPChannelPartnerAPI.TABLE_OF_BAPIRET2 RETURN_x= new  SAPChannelPartnerAPI.TABLE_OF_BAPIRET2();
                                        SAPChannelPartnerAPI.ZSD_SFDC_VENDOR brokerData = New SAPChannelPartnerAPI.ZSD_SFDC_VENDOR();
                                        
                                        SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element resp = new           SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element();
                                        
                                        try{
                                            resp=   brokerData.ZSD_SFDC_VENDOR( RETURN_x,req);
                                                                                        erp.Status__c = 'Reprocessed';
                                            erp.Response__c = json.serializePretty(resp);
                                        }catch(exception e){
                                            
                                        }
                                        if(  resp.VENDOR_NUM != null &&  resp.VENDOR_NUM!= '')
                                        {

                                            Broker__c brl = new Broker__c();
                                            brl.SAP_CP_Code__c = resp.VENDOR_NUM;
                                            brl.id= erp.Channel_Partner__c;
                                            try{
                                                boolean sc =     IrisAPIChannelPartnerRestCallout.ChannelPartnerRestCallOutPatch(brl);
                                                brl.RW_IRIS_Sync__c = sc;
                                            }catch(exception e){
                                                
                                            }
                                            lstBroker.add(brl);
                                            
                                        }
                                    }
                                    
                                    update scope  ;
                                    if(lstBroker.size()>0){
                                        update lstBroker;
                                    }
                                }
                                */
                                when 'Unit Inventory','Car Parking Inventory'{
                                    SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT materialDetailsList = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT();
                                    materialDetailsList.item = new List<SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
                                    map<String,ERP_Integration_Log__c>erpcodemap = new map<String,ERP_Integration_Log__c>();
                                    for(ERP_Integration_Log__c erp :scope){
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS mat = (   SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS) JSON.deserialize(erp.Request__c.replaceAll('&quot;','"'),   SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS.class);
                                        materialDetailsList.item.add(mat);
                                        erpcodemap.put(mat.MATNR,erp);
                                    }
                                    
                                    Boolean callOutError = false;
                                    String exceptionMsg = '';
                                    SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT inventoryCreationResponse = new SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT();
                                    try{
                                        system.debug(json.serialize(materialDetailsList));
                                        SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND createInventory = new SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND();
                                        createInventory.timeout_x = 60000;
                                        inventoryCreationResponse = createInventory.ZSD_SFDC_WS_MAT_CRT_CHNG(materialDetailsList);
                                        System.debug('New Inventory response:' +json.serialize(inventoryCreationResponse));
                                        list<ERP_Integration_Log__c> repolog = new list<ERP_Integration_Log__c>();
                                        for(SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS res : inventoryCreationResponse.item)
                                        {
                                            ERP_Integration_Log__c erp = erpcodemap.get(res.MATERIALNO);
                                            if(res.Status == 'SUCCESS')
                                                erp.Status__c ='Reprocessed';
                                            repolog.add(erp);
                                        }
                                        update  repolog;
                                    }  
                                    catch (Exception ex) {
                                        System.debug('Exception:' + ex.getMessage());
                                        callOutError = true;
                                        exceptionMsg = ex.getMessage();
                                    }finally{
                                                                                update scope;

                                    }
                                }
                                when 'Price Change'{
                                    Map<String,String> inputMap = new Map<String,String>();
                                    Map<String,List<ERP_Integration_Log__c>> reprocedMap = new Map<String,List<ERP_Integration_Log__c>>();
                                    
                                    SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT pricingDataList = new          SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT();
                                    for(ERP_Integration_Log__c erp :scope){
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        pricingDataList =( SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT) JSON.deserialize(erp.Request__c.replaceAll('&quot;','"'),    SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT.class);
                                        for(SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS pt : pricingDataList.item){
                                            String MapKey = pt.KSCHL +'-'+
                                                pt.VKORG + '-' + 
                                                pt.WERKS + '-' +
                                                pt.MATNR + '-' +
                                                pt.VTWEG;
                                            String MapValue = pt.KBETR;
                                            inputMap.put(MapKey,MapValue); 
                                            
                                        }
                                    }
                                    
                                    SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT pricingDataListRepro = new          SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS_TT();
                                    pricingDataListRepro.item = new List<SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS>();
                                    for (String key : inputMap.keySet()){
                                        List<String> Keys  = Key.split('-');
                                        SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS priceItem = new SAPPricelistAPI.ZSD_SFDC_PRICING_DETAILS();
                                        
                                        priceItem.KSCHL = Keys[0];
                                        priceItem.VKORG = Keys[1];
                                        priceItem.WERKS = Keys[2];
                                        priceItem.MATNR = Keys[3];                     
                                        priceItem.KBETR = inputMap.get(Key);
                                        priceItem.VTWEG = Keys[4]; 
                                        
                                        pricingDataListRepro.item.add(priceItem);
                                        system.debug(priceItem);
                                    }   
                                    SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT priceResponse = new SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT();
                                    try{
                                        SAPPricelistAPI.ZSD_SFDC_WSDL_PRC_UPDT_BND createPrice = new SAPPricelistAPI.ZSD_SFDC_WSDL_PRC_UPDT_BND();
                                        createPrice.timeout_x = 60000;
                                        priceResponse = createPrice.ZSD_SFDC_WS_PRI_CRT(pricingDataList);
                                        System.debug('New Pricing response:' +json.serialize(priceResponse));
                                        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                                        String requestF = JSON.SerializePretty(pricingDataList);
                                        log.request__c = requestF;
                                        log.API_name__c = 'Price Change';                
                                        //log.Project_Unit__c = ProjectUnitRecordId;
                                        String responseF = JSON.SerializePretty(priceResponse);
                                        responseF =  responseF.replaceAll('\n','<br/>');
                                        responseF  = responseF.replaceAll('\t', '&nbsp;');
                                        log.response__c = responseF;
                                        log.Status__c = 'Success';
                                        insert log;
                                        for(ERP_Integration_Log__c erp :scope){
                                            erp.Status__c = 'Reprocessed';
                                        }
                                    }
                                    catch(Exception ex){
                                        
                                    }finally{
                                        update scope;
                                    }
                                    
                                }
                                /*  when 'Car Parking Inventory'{    
SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT materialDetailsList = new SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS_TT();
materialDetailsList.item = new List<SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS>();
map<String,ERP_Integration_Log__c>erpcodemap = new map<String,ERP_Integration_Log__c>();
for(ERP_Integration_Log__c erp :scope){
erp.Retry_Count__c = erp.Retry_Count__c +1;
SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS mat = (   SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS) JSON.deserialize(erp.Request__c,   SAPInventoryCallout.ZSD_SFDC_MATERIAL_DETAILS.class);
materialDetailsList.item.add(mat);
erpcodemap.put(mat.MATNR,erp);
}
}*/
                                when 'Demand API'{
                                    
                                    SAPDemandAPICallOut.bypassErrorLog = true;
                                    for(ERP_Integration_Log__c erp :scope){
                                        system.debug(erp);
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        try{
                                            SAPDemandAPICallOut.getDemands(erp.Request__c.replaceAll('&quot;','"'));
                                            erp.Status__c = 'Reprocessed';
                                        }catch(exception e){
                                            
                                        }
                                    }
                                    update scope;
                                }
                                when 'Receipts API'{
                                    SAPReceiptAPICallOut.bypassErrorLog = true;
                                    
                                    for(ERP_Integration_Log__c erp :scope){
                                        system.debug(erp);
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        try{
                                            SAPReceiptAPICallOut.getReceipts(erp.Request__c.replaceAll('&quot;','"'),projectname);
                                            erp.Status__c = 'Reprocessed';
                                        }catch(exception ex){}
                                    }
                                    update scope;
                                }
                                when 'Interest Ledger'{
                                    SAPInterestLedgerAPICallOut.bypassErrorLog = true;
                                    
                                    for(ERP_Integration_Log__c erp :scope){
                                        erp.Retry_Count__c = erp.Retry_Count__c +1;
                                        try{
                                            SAPInterestLedgerAPICallOut.getLedger(erp.Request__c.replaceAll('&quot;','"'));
                                            erp.Status__c = 'Reprocessed';
                                        }catch(exception ex){}
                                    }
                                    update scope;
                                }
                            }
                        }
    
    public void finish(Database.BatchableContext BC){
        
    }
}