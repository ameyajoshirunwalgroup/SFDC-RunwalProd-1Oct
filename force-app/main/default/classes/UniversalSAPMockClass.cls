@istest
public class UniversalSAPMockClass implements WebServiceMock  {
    public void doInvoke(
        Object stub, Object request, Map<String, Object> response,
        String endpoint, String soapAction, String requestName,
        String responseNS, String responseName, String responseType) 
    {
        system.debug(stub);
        if(stub instanceof SAPInventoryCallout.ZSD_SFDC_WSDL_MCR_MCH_BND)
            new inventoryMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        else if(stub instanceof SAPPricelistAPI.ZSD_SFDC_WSDL_PRC_UPDT_BND)
            new rateListMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        else if(stub instanceof SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER)
            new salesordermock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        
        else if(stub instanceof CustomerCreation.ZSD_SFDC_CUSTOMER)
            new CustomerCreationmock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        else if(stub instanceof SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND)
            new demandMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        else if(stub instanceof SAPPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT)
            new receiptMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
            else if(stub instanceof SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND)
            new ledgerMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
          else if(stub instanceof SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS)
            new pdfMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
           else if(stub instanceof SAPChannelPartnerAPI.ZSD_SFDC_VENDOR)
            new vendorMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        return;
    }
    
      public class vendorMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
            if(request instanceof   SAPChannelPartnerAPI.ZSD_SFDC_VENDOR_element){
      string responsejson = '{"VENDOR_NUM_type_info":["VENDOR_NUM","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"VENDOR_NUM":"0006000511","RETURN_x_type_info":["RETURN","urn:sap-com:document:sap:rfc:functions",null,"0","1","false"],"RETURN_x":{"item_type_info":["item","urn:sap-com:document:sap:rfc:functions",null,"0","-1","false"],"item":null,"field_order_type_info":["item"],"apex_schema_type_info":["urn:sap-com:document:sap:rfc:functions","false","true"]},"field_order_type_info":["RETURN_x","VENDOR_NUM"],"apex_schema_type_info":["urn:sap-com:document:sap:rfc:functions","false","true"]}';
            SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element resp = (SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element) json.deserialize(responsejson, SAPChannelPartnerAPI.ZSD_SFDC_VENDORResponse_element.class);
                
                response.put('response_x', resp);
            }
        }
    }

      public class pdfMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
        string   ZpdfBase64 = 'd2R0Zmd5aHNqa2FkZml1YWhkc2l1ZmhhaXVkc2hmamlibmFka2puZGZhc2Rhcw==';
          SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element rsp = new SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element();
           rsp.ZpdfBase64 = ZpdfBase64;
              response.put('response_x', rsp);
            
        }
    }
           
   public class ledgerMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
            if(request instanceof SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_element){    
                String respnse ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
     SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT  sfdcLedgerResponse=(      SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT )json.deserialize(respnse,       SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT.class);
            system.debug(sfdcLedgerResponse);
             SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDSResponse_element resp = new  SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDSResponse_element();
       resp.RESPONSE = sfdcLedgerResponse;
                
              response.put('response_x', resp);
            }
        }
    }
    public class demandMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
            if(request instanceof SAPDemandAPI.ZSD_SFDC_WS_DEMAND_element){
                SAPDemandAPI.ZSD_SFDC_WS_DEMANDResponse_element respElement = 
                    new SAPDemandAPI.ZSD_SFDC_WS_DEMANDResponse_element();
                
                //SAPPaymentInterface sapPayInterface = new SAPPaymentInterface();
                system.debug('before mock*');
                
                String dmd ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000010", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025444", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}, 	{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "C", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000010", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "12345679", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	} 	, 	{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000010", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "10000.0", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "123456799", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	} 	,{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "P", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000010", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "12345678", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	} 	, 	{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025444", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}, { 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "P", 		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025445", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}, { 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "C", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 	  		"NET_PAID_type_info": ["NET_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"NET_PAID": "0.0", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS", "NET_PAID"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025446", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
                     SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT detailstt =  (SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT) JSON.deserialize(dmd,  SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT.class);
                
                
                system.debug(detailstt);
                
                respElement.DEMAND_INFO = detailstt;
                response.put('response_x', respElement);    system.debug( response.get('response_x'));
            }
            
        }
    }    
    
    
    public class receiptMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
            if(request instanceof SAPPaymentInterface.ZsdSfdcPaymentReceipt_element){
                
                
                String rec='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"], 	"item": [{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "0000006234-000005", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "50000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "001", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0010000180", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "3610725.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "R", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "R", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025445", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "389275.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "003", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] }';
                    
                    sapPaymentInterface.ZsdtSfdcPaymentReceipt            sfdcpayReceiptResponse =  (    sapPaymentInterface.ZsdtSfdcPaymentReceipt)JSON.deserialize(rec,     sapPaymentInterface.ZsdtSfdcPaymentReceipt.class);       
                
                SAPPaymentInterface.ZsdSfdcPaymentReceiptResponse_element rs = new SAPPaymentInterface.ZsdSfdcPaymentReceiptResponse_element();
           rs.PaymentReceipt = sfdcpayReceiptResponse;
                system.debug(rs);
                       response.put('response_x', rs);      
            }
        }
    }
    
    
    public class inventoryMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            system.debug(request);
            if(request instanceof SAPInventoryCallout.ZSD_SFDC_WS_MAT_CRT_CHNG_element){
                SAPInventoryCallout.ZSD_SFDC_WS_MAT_CRT_CHNGResponse_element respElement = 
                    new SAPInventoryCallout.ZSD_SFDC_WS_MAT_CRT_CHNGResponse_element();
                
                //SAPPaymentInterface sapPayInterface = new SAPPaymentInterface();
                system.debug('before mock*');
                SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT detailstt = new SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS_TT();
                detailstt.item = new List<SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS>();
                
                SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS returndetails = new SAPInventoryCallout.ZSD_SFDC_RETURN_DETAILS();
                system.debug('after mock***');
                returndetails.MATERIALNO = 'abc';
                returndetails.STATUS='SUCCESS';
                returndetails.ERRORMESSAGE='';
                system.debug('after mock****');
                
                detailstt.item.add(returndetails);
                
                respElement.RESPONSE = detailstt;
                response.put('response_x', respElement); 
            }
            
        }
    }    
    
    
    
    public class salesordermock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {system.debug(request);
         if(request instanceof             SalesOrderSAPAPIMCS.ZsdSdfcSalesOrder_element){
             string res= '{	"Salesdocument_type_info": ["Salesdocument", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"Salesdocument": "23456777",	"Return_x_type_info": ["Return", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "1", "false"],	"Return_x": {		"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"],';
             res +='"item": [{"Type_x_type_info": ["Type", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Type_x": "S","System_x_type_info": ["System", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"System_x": "ECQCLNT210","Row_type_info": ["Row", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"Row": 0,"Parameter_type_info": ["Parameter", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Parameter": "","Number_x_type_info": ["Number", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Number_x": "219",	"MessageV4_type_info": ["MessageV4", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"MessageV4": "","MessageV3_type_info": ["MessageV3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"MessageV3": "","MessageV2_type_info": ["MessageV2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"MessageV2": "","MessageV1_type_info": ["MessageV1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"MessageV1": "","Message_type_info": ["Message", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Message": "Sales document  was not changed","LogNo_type_info": ["LogNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"LogNo": "","LogMsgNo_type_info": ["LogMsgNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"LogMsgNo": "000000","Id_type_info": ["Id", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Id": "V4","Field_type_info": ["Field", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"field_order_type_info": ["Type_x", "Id", "Number_x", "Message", "LogNo", "LogMsgNo", "MessageV1", "MessageV2", "MessageV3", "MessageV4", "Parameter", "Row", "Field", "System_x"],';
             res +='"Field": "","apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]}],"field_order_type_info": ["item"],"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]}}';
             SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element respons= ( SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element)JSON.deserialize(res,  SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element.class);
             response.put('response_x',respons );
             
         }
        }
    }
    
    public class CustomerCreationmock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {system.debug(request);
         if(request instanceof  CustomerCreation.ZsdSfdcCustomer_element){
             
             string res='{	"Customerno": "0020006463",	"Return_x_type_info": ["Return", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "1", "false"],	"Return_x": {"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"],"item": [{';
             res +='"Type_x_type_info": ["Type", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Type_x": "","System_x_type_info": ["System", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"System_x": "","Row_type_info": ["Row", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"Row": 0,"Parameter_type_info": ["Parameter", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"Parameter": "","Number_x_type_info": ["Number", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Number_x": "000","MessageV4_type_info": ["MessageV4", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"MessageV4": "",';
             res +='"MessageV3_type_info": ["MessageV3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"MessageV3": "","MessageV2_type_info": ["MessageV2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"MessageV2": "","MessageV1_type_info": ["MessageV1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"MessageV1": "","Message_type_info": ["Message", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"Message": "","LogNo_type_info": ["LogNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"LogNo": "","LogMsgNo_type_info": ["LogMsgNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"LogMsgNo": "000000","Id_type_info": ["Id", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Id": "","Field_type_info": ["Field", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"field_order_type_info": ["Type_x", "Id", "Number_x", "Message", "LogNo", "LogMsgNo", "MessageV1", "MessageV2", "MessageV3", "MessageV4", "Parameter", "Row", "Field", "System_x"],	"Field": "","apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]';
             res +='}],"field_order_type_info": ["item"],"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]}}';
             CustomerCreation.ZsdSfdcCustomerResponse_element respons= (CustomerCreation.ZsdSfdcCustomerResponse_element)JSON.deserialize(res, CustomerCreation.ZsdSfdcCustomerResponse_element.class);
             
             response.put('response_x',respons );
         }
        }
    }
    
    public class rateListMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {system.debug(request);
         if(request instanceof SAPPricelistAPI.ZSD_SFDC_WS_PRI_CRT_element){
             string res = '{	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"],	"item": [{"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"],"STATUS": "Success","MATNR_type_info": ["MATNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"],"MATNR": "1R000333","KSCHL_type_info": ["KSCHL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"],	"KSCHL": "ZPR0","field_order_type_info": ["MATNR", "KSCHL", "STATUS", "ERRORMESSAGE"],"ERRORMESSAGE_type_info": ["ERRORMESSAGE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"],"ERRORMESSAGE": "","apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"]	}],	"field_order_type_info": ["item"],"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"]}';
             system.debug(res);
             SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT priceResponse =  ( SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT)JSON.deserialize(res, SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT.class);
             
             // system.debug(priceResponse+'priceResponse');
             
             SAPPricelistAPI.ZSD_SFDC_WS_PRI_CRTResponse_element priceResponses = new SAPPricelistAPI.ZSD_SFDC_WS_PRI_CRTResponse_element();
             priceResponses.GT_RESPONSE = priceResponse;//new SAPPricelistAPI.ZSD_SFDC_PRICING_RTN_DTLS_TT();
             
             response.put('response_x',priceResponses );
         }
        }
    }
}