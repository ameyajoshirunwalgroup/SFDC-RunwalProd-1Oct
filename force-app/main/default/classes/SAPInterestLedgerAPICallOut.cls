public class SAPInterestLedgerAPICallOut 
{
public static boolean bypassErrorLog = false;
 public static boolean fortest = false;   
    //  @future(callOut = true)
    public static void getLedger(String timestamp) 
    {
       Map<String,Booking__c> mapOfBookings = new Map<String,Booking__c>();
        
       SAPInterestLedgerAPI  interestLedgerApi = new SAPInterestLedgerAPI();
       SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  sapinterestLedgerBND  = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
           SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT sfdcLedgerResponse = new  SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT ();

        try{system.debug('MK');
            
            if(test.isRunningTest()){
                String response ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
    sfdcLedgerResponse=(      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT )json.deserialize(response,       SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT.class);
                if(fortest){
CalloutException e = new CalloutException();
                e.setMessage('Validation Error(s) occurred during inventory Get.');
throw e;
                }
            }else{
                sfdcLedgerResponse = sapinterestLedgerBND.ZSD_SFDC_WS_INT_LDG_TDS(timestamp);}
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
      //  system.debug('response for the Ledger' +json.serialize(sfdcLedgerResponse)); 
        
        Set<String>  accountIds = new Set<String>();
         try{
        if(sfdcLedgerResponse!=null && sfdcLedgerResponse.item != null && sfdcLedgerResponse.item.size() >0)
        {
            for(SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST response :sfdcLedgerResponse.item)
            {
                
                if(response.ACCOUNT != null && response.ACCOUNT !='')
                {
                    accountIds.add(response.ACCOUNT); 
                }
            }
            
            system.debug('AccountIds---->' + accountIds);
                        system.debug('AccountIds---->' + accountIds.size());

        }
            
        List<Opportunity> opprec = [Select Id, Name, SAP_Customer_Number__c, Booking__c from Opportunity where SAP_Customer_Number__c IN:accountIds];
        Map<string, String> BookingIds = new Map<string,String>();
        for(Opportunity b: opprec)
        {	if(b.Booking__c!=null)
            BookingIds.put(b.SAP_Customer_Number__c, b.Booking__c);
        }
           
    
        system.debug('BookingIds' + BookingIds);        
        if(sfdcLedgerResponse!=null && sfdcLedgerResponse.item != null && sfdcLedgerResponse.item.size()>0 )
        {
            for(SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST response :sfdcLedgerResponse.item)
            {
                if(BookingIds.containsKey(response.ACCOUNT))
                {

                    Booking__c bookingWithLedger = new Booking__c();
                        //BookingIds.get(response.ACCOUNT);
                    bookingWithLedger.id = BookingIds.get(response.ACCOUNT);
                    
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
					
                    
                    mapOfBookings.put(response.ACCOUNT, bookingWithLedger);      
                 }

                

            }
   
        }
             system.debug('$$$$$$$$$$');
        system.debug(mapOfBookings.values());
       update  mapOfBookings.values();
        
          
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Interest Ledger';
            erp.Request__c = timestamp;
         //   erp.Response__c = JSON.serialize(sfdcLedgerResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            erp.Status__c='Failure';
            insert erp;
            
        }}
    
    
    

}