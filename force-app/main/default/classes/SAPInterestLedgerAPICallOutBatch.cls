global class SAPInterestLedgerAPICallOutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful
{
    public static boolean bypassErrorLog = false;
    public static boolean fortest = false;  
    public String timestamp;
    public String companyCode; //Added by Vinay 10-01-2025
    public     SAPInterestLedgerAPI  interestLedgerApi = new SAPInterestLedgerAPI();
    //public      SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  sapinterestLedgerBND  = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
    //public      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse = new  SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT ();
    //public Map<String, SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST> responseMap = new Map<String, SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST>(); //Added by Vinay 11-02-2025
    public Map<String,ResponseData> respMap = new Map<String,ResponseData>();

    global SAPInterestLedgerAPICallOutBatch(string times, String companyCode){//Added companyCode by Vinay 10-01-2025
        this.timestamp = times;
        this.companyCode = companyCode;//Added by Vinay 10-01-2025
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
//Map<String,Booking__c> mapOfBookings = new Map<String,Booking__c>();
        //SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse1 = new  SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT ();
        //SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  sapinterestLedgerBND  = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
        SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  sapinterestLedgerBND  = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
          SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse = new  SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT ();
        try{system.debug('MK');
            system.debug('timestamp: ' + timestamp);
            
            if(test.isRunningTest()){
                String response ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
                sfdcLedgerResponse=(      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT )json.deserialize(response,       SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT.class);
                if(fortest){
                    CalloutException e = new CalloutException();
                    e.setMessage('Validation Error(s) occurred during inventory Get.');
                    throw e;
                }
            }else{
                sapinterestLedgerBND.timeout_x = 120000;
                sfdcLedgerResponse = sapinterestLedgerBND.ZSD_SFDC_WS_INT_LDG_TDS(timestamp,companyCode);} //Added companyCode by Vinay 10-01-2025
           }catch(exception ex){
               if(!bypassErrorLog){
                   ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
                   erp.API_Name__c = 'Interest Ledger';
                   erp.Request__c = timestamp;
                   erp.Status__c='Failure';
                   erp.Response__c = JSON.serialize(sfdcLedgerResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
                   erp.Error_Reason__c = ex.getMessage();
                   erp.Error_Type__c = 'Timeout Error';
                   insert erp;
               }	
           }
         //system.debug('response for the Ledger' +json.serialize(sfdcLedgerResponse1)); 
        
        Set<String>  accountIds = new Set<String>();
        
        if(sfdcLedgerResponse!=null && sfdcLedgerResponse.item != null && sfdcLedgerResponse.item.size() >0)
        {
            for(SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST response :sfdcLedgerResponse.item)
            {
                
                if(response.ACCOUNT != null && response.ACCOUNT !='')
                {
                    accountIds.add(response.ACCOUNT); 
                    //responseMap.put(response.ACCOUNT, response); //Added by Vinay 11-02-2025

                    ResponseData respWrp = new ResponseData();
                    respWrp.ACCOUNT = response.ACCOUNT;
                    respWrp.GST_CHRG_INT = response.GST_CHRG_INT;
                    respWrp.INT_AMT_BAL = response.INT_AMT_BAL;
                    respWrp.INT_AMT_COLL = response.INT_AMT_COLL;
                    respWrp.INT_AMT_WAIVED = response.INT_AMT_WAIVED;
                    respWrp.TDS_CERT_RECV = response.TDS_CERT_RECV;
                    respWrp.TDS_DUE = response.TDS_DUE;
                    respWrp.TDS_OUTSTND = response.TDS_OUTSTND;
                    respWrp.TDS_PAID = response.TDS_PAID;
                    respWrp.TOT_COLL_INT = response.TOT_COLL_INT;
                    respWrp.TOT_INT = response.TOT_INT;
                    respMap.put(response.ACCOUNT, respWrp);
                }
            }
            
            system.debug('AccountIds---->' + json.serialize(accountIds));
            system.debug('AccountIds---->' + accountIds.size());
            //   List<Opportunity> opprec = [Select Id, Name, SAP_Customer_Number__c, Booking__c from Opportunity where SAP_Customer_Number__c IN:accountIds];
            
        }
        
        return Database.getQueryLocator('Select Id, Name, SAP_Customer_Number__c, Booking__c from Opportunity where SAP_Customer_Number__c IN:accountIds and stagename=\'Unit Booked\' and Booking__c != null');        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {  
     //Added by coServe 23-05-2022 start
     /*SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse2 = new  SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT ();
     SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  sapinterestLedgerBND  = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
     system.debug('timestamp: ' + timestamp);
     if(test.isRunningTest()){
         String response ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
         sfdcLedgerResponse2=(      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT )json.deserialize(response,       SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT.class);
     }else{
         sfdcLedgerResponse2 = sapinterestLedgerBND.ZSD_SFDC_WS_INT_LDG_TDS(timestamp);
     }*/
     //Added by coServe 23-05-2022 end
     if(test.isRunningTest()){
         String response ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
         SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse=(      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT )json.deserialize(response,       SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT.class);
     }
     //system.debug('sfdcLedgerResponse: ' + sfdcLedgerResponse);
     //system.debug('sfdcLedgerResponse: ' + sfdcLedgerResponse.item);
      Map<String,Booking__c> mapOfBookings = new Map<String,Booking__c>();
     Map<string, String> BookingIds = new Map<string,String>();
     for(Opportunity b: scope)
     {	if(b.Booking__c!=null)
         BookingIds.put(b.SAP_Customer_Number__c, b.Booking__c);
     }
     Set<id> bkids = new Set<id>();
     Map<id,  Booking__c> bookingMap =new map<id,Booking__c>([select id,RW_Total_Interest__c,RW_Total_Interest_Amount_Waived__c,RW_Total_Collectable_Interest__c
                                                              ,RW_Total_Amount_Collected__c,RW_Total_Amount_Balance__c,Total_TDS_Amount_Paid_In_Rs__c,
                                                              RW_Total_TDS_Due__c,RW_Total_TDS_Outstanding__c,RW_GST_On_Interest__c  from booking__c where id in :BookingIds.values()]);
     system.debug('BookingIds' + BookingIds);   
     if(respMap != null && respMap.size() > 0 ){ //Added by Vinay 11-02-2025
        for(String crn : BookingIds.keySet()){
            if(respMap.get(crn) != null){
                Booking__c bookingWithLedger = bookingMap.get(BookingIds.get(crn));
                if(bookingWithLedger.RW_Total_Interest__c != decimal.valueOf(respMap.get(crn).TOT_INT) ||
                   bookingWithLedger.RW_Total_Interest_Amount_Waived__c != decimal.valueOf(respMap.get(crn).INT_AMT_WAIVED)||
                   bookingWithLedger.RW_Total_Collectable_Interest__c != decimal.valueOf(respMap.get(crn).TOT_COLL_INT)  ||
                   bookingWithLedger.RW_Total_Amount_Collected__c !=  decimal.valueOf(respMap.get(crn).INT_AMT_COLL)||
                   bookingWithLedger.RW_Total_Amount_Balance__c !=  decimal.valueOf(respMap.get(crn).INT_AMT_BAL)||
                   bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c !=decimal.valueOf( respMap.get(crn).TDS_PAID)||
                   bookingWithLedger.RW_Total_TDS_Due__c !=  decimal.valueOf(respMap.get(crn).TDS_DUE)||
                   bookingWithLedger.RW_Total_TDS_Outstanding__c !=  decimal.valueOf(respMap.get(crn).TDS_OUTSTND)||
                   bookingWithLedger.RW_GST_On_Interest__c !=  decimal.valueOf(respMap.get(crn).GST_CHRG_INT)){
                       
                       bookingWithLedger.RW_Total_Interest__c = decimal.valueOf(respMap.get(crn).TOT_INT);
                       bookingWithLedger.RW_Total_Interest_Amount_Waived__c = decimal.valueOf(respMap.get(crn).INT_AMT_WAIVED);
                       bookingWithLedger.RW_Total_Collectable_Interest__c = decimal.valueOf(respMap.get(crn).TOT_COLL_INT);
                       bookingWithLedger.RW_Total_Amount_Collected__c =  decimal.valueOf(respMap.get(crn).INT_AMT_COLL);
                       bookingWithLedger.RW_Total_Amount_Balance__c =  decimal.valueOf(respMap.get(crn).INT_AMT_BAL);
                       
                       bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c =decimal.valueOf( respMap.get(crn).TDS_PAID);
                       bookingWithLedger.RW_Total_TDS_Due__c =  decimal.valueOf(respMap.get(crn).TDS_DUE);
                       //	bookingWithLedger.RW_TDS_Certificate_Received__c =  response.TDS_CERT_RECV;
                       bookingWithLedger.RW_Total_TDS_Outstanding__c =  decimal.valueOf(respMap.get(crn).TDS_OUTSTND);
                       bookingWithLedger.RW_GST_On_Interest__c =  decimal.valueOf(respMap.get(crn).GST_CHRG_INT);
                       bkids.add(bookingWithLedger.id);
                       
                       mapOfBookings.put(respMap.get(crn).ACCOUNT, bookingWithLedger);         
                   }
            }
        }
    }  
     /*if(sfdcLedgerResponse!=null && sfdcLedgerResponse.item != null && sfdcLedgerResponse.item.size()>0 ) //Commented by Vinay 11-02-2025
     {
         for(SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST response :sfdcLedgerResponse.item)
         {
             //   system.debug('Bokking ids cpntains' + BookingIds.containsKey(response.ACCOUNT));
             // system.debug('Bokking ids map contains' + BookingIds.containsKey(response.ACCOUNT));
             if(BookingIds.containsKey(response.ACCOUNT))
             { 
                 if(bookingMap.containsKey(BookingIds.get(response.ACCOUNT))){
                     Booking__c bookingWithLedger = bookingMap.get(BookingIds.get(response.ACCOUNT));
                     if(bookingWithLedger.RW_Total_Interest__c != decimal.valueOf(response.TOT_INT) ||
                        bookingWithLedger.RW_Total_Interest_Amount_Waived__c != decimal.valueOf(response.INT_AMT_WAIVED)||
                        bookingWithLedger.RW_Total_Collectable_Interest__c != decimal.valueOf(response.TOT_COLL_INT)  ||
                        bookingWithLedger.RW_Total_Amount_Collected__c !=  decimal.valueOf(response.INT_AMT_COLL)||
                        bookingWithLedger.RW_Total_Amount_Balance__c !=  decimal.valueOf(response.INT_AMT_BAL)||
                        bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c !=decimal.valueOf( response.TDS_PAID)||
                        bookingWithLedger.RW_Total_TDS_Due__c !=  decimal.valueOf(response.TDS_DUE)||
                        bookingWithLedger.RW_Total_TDS_Outstanding__c !=  decimal.valueOf(response.TDS_OUTSTND)||
                        bookingWithLedger.RW_GST_On_Interest__c !=  decimal.valueOf(response.GST_CHRG_INT))
                     {
                         
                         bookingWithLedger.RW_Total_Interest__c = decimal.valueOf(response.TOT_INT);
                         bookingWithLedger.RW_Total_Interest_Amount_Waived__c = decimal.valueOf(response.INT_AMT_WAIVED);
                         bookingWithLedger.RW_Total_Collectable_Interest__c = decimal.valueOf(response.TOT_COLL_INT);
                         bookingWithLedger.RW_Total_Amount_Collected__c =  decimal.valueOf(response.INT_AMT_COLL);
                         bookingWithLedger.RW_Total_Amount_Balance__c =  decimal.valueOf(response.INT_AMT_BAL);
                         
                         bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c =decimal.valueOf( response.TDS_PAID);
                         bookingWithLedger.RW_Total_TDS_Due__c =  decimal.valueOf(response.TDS_DUE);
                         //	bookingWithLedger.RW_TDS_Certificate_Received__c =  response.TDS_CERT_RECV;
                         bookingWithLedger.RW_Total_TDS_Outstanding__c =  decimal.valueOf(response.TDS_OUTSTND);
                         bookingWithLedger.RW_GST_On_Interest__c =  decimal.valueOf(response.GST_CHRG_INT);
                         bkids.add(bookingWithLedger.id);
                         
                         mapOfBookings.put(response.ACCOUNT, bookingWithLedger);         
                     }
                     
                     
                 }
                 
             }
             
              
             
         }
         
     }*/

     /*if(respWrpList != null && respWrpList.size()>0 ) //Commented by Vinay 11-02-2025
     {
         for(ResponseWrapper response : respWrpList)
         {
             //   system.debug('Bokking ids cpntains' + BookingIds.containsKey(response.ACCOUNT));
             // system.debug('Bokking ids map contains' + BookingIds.containsKey(response.ACCOUNT));
             if(BookingIds.containsKey(response.ACCOUNT))
             { 
                 if(bookingMap.containsKey(BookingIds.get(response.ACCOUNT))){
                     Booking__c bookingWithLedger = bookingMap.get(BookingIds.get(response.ACCOUNT));
                     if(bookingWithLedger.RW_Total_Interest__c != decimal.valueOf(response.TOT_INT) ||
                        bookingWithLedger.RW_Total_Interest_Amount_Waived__c != decimal.valueOf(response.INT_AMT_WAIVED)||
                        bookingWithLedger.RW_Total_Collectable_Interest__c != decimal.valueOf(response.TOT_COLL_INT)  ||
                        bookingWithLedger.RW_Total_Amount_Collected__c !=  decimal.valueOf(response.INT_AMT_COLL)||
                        bookingWithLedger.RW_Total_Amount_Balance__c !=  decimal.valueOf(response.INT_AMT_BAL)||
                        bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c !=decimal.valueOf( response.TDS_PAID)||
                        bookingWithLedger.RW_Total_TDS_Due__c !=  decimal.valueOf(response.TDS_DUE)||
                        bookingWithLedger.RW_Total_TDS_Outstanding__c !=  decimal.valueOf(response.TDS_OUTSTND)||
                        bookingWithLedger.RW_GST_On_Interest__c !=  decimal.valueOf(response.GST_CHRG_INT))
                     {
                         
                         bookingWithLedger.RW_Total_Interest__c = decimal.valueOf(response.TOT_INT);
                         bookingWithLedger.RW_Total_Interest_Amount_Waived__c = decimal.valueOf(response.INT_AMT_WAIVED);
                         bookingWithLedger.RW_Total_Collectable_Interest__c = decimal.valueOf(response.TOT_COLL_INT);
                         bookingWithLedger.RW_Total_Amount_Collected__c =  decimal.valueOf(response.INT_AMT_COLL);
                         bookingWithLedger.RW_Total_Amount_Balance__c =  decimal.valueOf(response.INT_AMT_BAL);
                         
                         bookingWithLedger.Total_TDS_Amount_Paid_In_Rs__c =decimal.valueOf( response.TDS_PAID);
                         bookingWithLedger.RW_Total_TDS_Due__c =  decimal.valueOf(response.TDS_DUE);
                         //	bookingWithLedger.RW_TDS_Certificate_Received__c =  response.TDS_CERT_RECV;
                         bookingWithLedger.RW_Total_TDS_Outstanding__c =  decimal.valueOf(response.TDS_OUTSTND);
                         bookingWithLedger.RW_GST_On_Interest__c =  decimal.valueOf(response.GST_CHRG_INT);
                         bkids.add(bookingWithLedger.id);
                         
                         mapOfBookings.put(response.ACCOUNT, bookingWithLedger);         
                     }
                     
                     
                 }
                 
             }
             
              
             
         }
         
     }*/
       system.debug('$$$$$$$$$$');
     system.debug(mapOfBookings.size());
     BookingTriggerHandler.bypass = true;
     //List<Booking__c> updateLock = [select id from booking__c where id in :bkids for update] ;
        //update  mapOfBookings.values();
     //try catch added by coServe on 13-07-2022
     try{
         update  mapOfBookings.values();
     }catch(exception e){
         ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
         erp.API_Name__c = 'Interest Ledger';
         erp.Request__c = timestamp;
         erp.Error_Reason__c = e.getMessage();
         erp.Response__c = 'Unprocessed Records: ' + mapOfBookings.keyset();
         erp.Error_Type__c = 'Data Error';
         erp.Status__c='Failure';
         insert erp;
     }
     
     BookingTriggerHandler.bypass = false;
    }

    public class ResponseWrapper{
        public Map<String,ResponseData> respDetails;
    }

    public class ResponseData{
        public String ACCOUNT;
        public String GST_CHRG_INT;
        public String INT_AMT_BAL;
        public String INT_AMT_COLL;
        public String INT_AMT_WAIVED;
        public String TDS_CERT_RECV;
        public String TDS_DUE;
        public String TDS_OUTSTND;
        public String TDS_PAID;
        public String TOT_COLL_INT;
        public String TOT_INT;
    }
    
    global void finish(Database.BatchableContext BC)
    {
       
    
    }
    
}