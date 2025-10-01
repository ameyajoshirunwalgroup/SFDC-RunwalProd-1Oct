public class SAPReceiptAPICallOut 
{
    //@future(callOut = true)
    public static boolean bypassErrorLog = false;
    
    public static void getReceipts(String timestamp,String ProjectName) 
    {
        Map<String,Opportunity> customerOppMap = new Map<String,Opportunity>();
        Map<String,String> PaymentDetUniqueIdMap = new Map<String,String>();
        Map<String,RW_Payment_Details__c> sapResponseMap = new Map<String,RW_Payment_Details__c>();
        //List<RW_Payment_Details__c> payDetailsInsert = new List<RW_Payment_Details__c>();    
        //List<RW_Payment_Details__c> payDetailsUpdate = new List<RW_Payment_Details__c>();  
        Map<String,String> demandnumberMap = new Map<String,String>();
        List<RW_Payment_Details__c> payDetailsList = new List<RW_Payment_Details__c>();
        Set<String>  cutomerIds = new Set<String>(); 
        Set<String> uniqueIds = new Set<String>(); 
        List<String> chequeCode = new List<String>{'DF','DE','D1','DZ','DT','AB','DS','DB'};
            // List<String>     chequeCode =system.label.SAP_Cheque_Codes.split(',');
            
            //List<String> chequeCode = new List<String>{'DF','DE'};
            Map<String,List<SAPPaymentInterface.ZsdSfdcPaymentReceipt>> mapResponse = new Map<String,List<SAPPaymentInterface.ZsdSfdcPaymentReceipt>>(); 
        Map<String,Id> MapOfBookingCustomerId = new Map<String,Id>(); 
        Map<String, RW_Demand__c> MapofDemandNumWithDemand = new Map<String, RW_Demand__c>();
        Map<String, RW_Demand_Item__c> MapOfDemandItemWithCustomerId = new  Map<String, RW_Demand_Item__c>();
        Map<String,receiptWrapper> mapOfReceiptWrapper = new Map<String,receiptWrapper>();
        
        // Existing UniqueIds 
        List<String> ExistingUniqueIdsList = new List<String>();
        
        List<RW_Payment_Details__c> ListToUpdatePayment = new List<RW_Payment_Details__c>();
        
        
        //Get the response for SAP Payment API 
        SAPPaymentInterface sapPaymentInterface = new SAPPaymentInterface();
        sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT payReceipt= new sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT();
        sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceipt= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
        sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceiptResponse= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
        // System.debug('*before call*');
        try{
            // sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,System.now().format('yyyyMMddHHmmss'));
            
            if(test.isRunningTest()){
                String rec='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"], 	"item": [{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "0000006234-000005", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "50000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "001", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0010000180", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "3610725.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "R", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "R", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025445", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "389275.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "003", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, 	{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "890890", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "5000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "01400001490", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	},{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311sss", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "890890", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "5000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "01400001491", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] }';
                sfdcpayReceiptResponse =  (    sapPaymentInterface.ZsdtSfdcPaymentReceipt)JSON.deserialize(rec,     sapPaymentInterface.ZsdtSfdcPaymentReceipt.class);       
            }else{
                
                payReceipt.timeout_x = 60000;    
                sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,timestamp);
            }
            
        }catch(exception ex){
            if(!bypassErrorLog){
                ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
                erp.API_Name__c = 'Receipts API';
                erp.Request__c = timestamp;//JSON.serialize(System.now().format('yyyyMMddHHmmss'));
                erp.Status__c='Failure';
                erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
                erp.Error_Reason__c = ex.getMessage();
                erp.Error_Type__c = 'Timeout Error';
                insert erp;}
        }   //     System.debug('**'+System.now().format('yyyyMMddHHmmss'));
        // sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,'20210104101010');
        
        System.debug('*after call*'+ sfdcpayReceiptResponse.item.size());
        //   system.debug(sfdcpayReceiptResponse.item.size());
        //loop through the response 
        try{
            if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
            {
                for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
                {
                    if(chequeCode.contains(responseRec.HBlart) && responseRec.kunnr != null && responseRec.kunnr != '')
                    {
                        //build the customer id set to get the opportunity
                        cutomerIds.add(responseRec.kunnr);
                        //build the unique id set for checking duplicate
                        uniqueIds.add(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs);
                    }
                    //if demand number is not null then build the customer number to demand number map
                    if(responseRec.Zdemand != null && responseRec.Zdemand != '')
                    {
                        demandnumberMap.put(responseRec.kunnr,responseRec.Zdemand);
                    }
                    //  add to the map demandnumberMap
                    //make map uniqqueid to response
                    if(mapResponse.containsKey(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs)){
                        List<SAPPaymentInterface.ZsdSfdcPaymentReceipt> receipts = mapResponse.get(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs);
                        receipts.add(responseRec);
                        mapResponse.put(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs,receipts);
                    }else{
                        mapResponse.put(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs, new List<SAPPaymentInterface.ZsdSfdcPaymentReceipt>{responseRec});
                    }
                }
            }
            //  system.debug( 'demandnumberMap'+ demandnumberMap);
            // system.debug('Customer Ids' + cutomerIds);
            // system.debug('uniqueIds'+uniqueIds);
            // system.debug(mapResponse);
            //CustomerIds has all the customer ids present in the API, we will query opportunity with this id and get Booking id and eoi list
            List<Opportunity> opprec = [Select Id, Name,SAP_Customer_Number__c,Booking__c, (Select id,Name FROM EOI__r) from
                                        Opportunity where SAP_Customer_Number__c IN:cutomerIds and stagename in ('Unit Booked','EOI Received') and
                                        RW_Project__r.Name = :ProjectName];
            for(Opportunity oppRecord : opprec)
            {
                //If EOI is present we will tag the Payment Reciept to the Opportunity else it will be in tagged to booking record
                if(oppRecord.EOI__r.size() >0 && oppRecord.Booking__c ==null)
                {
                    //   System.debug('*added in map**');
                    customerOppMap.put(oppRecord.SAP_Customer_Number__c, oppRecord);
                }
                
                else{
                    MapOfBookingCustomerId.put(oppRecord.SAP_Customer_Number__c, oppRecord.Booking__c);
                    //     System.debug('*added in map of MapOfBookingCustomerId **' + MapOfBookingCustomerId);
                }
            }
            system.debug('!!!!!!!!!!!!'+demandnumberMap.values());
            //Get all the demand in the system by querying it on demandNumberMap which we created above it will have demand which are present in the payments
            List<RW_Demand__c> ListOfDemands = [select id, name, RW_Customer_Number__c,RW_Billing_Document_Number__c, (select id,RW_Demand_Item_Number__c,Total_Demand_Item_Amount_Paid__c, name,RW_Legacy_Amount_Paid__c,RW_Legacy_Demand__c from Demand_Items__r) from RW_Demand__c where RW_Billing_Document_Number__c In: demandnumberMap.values()]; 
            for(RW_Demand__c demandList : ListOfDemands)
            {//build the customer number to demand number map
                MapofDemandNumWithDemand.put(demandList.RW_Billing_Document_Number__c, demandList);
            }
            
            
            
            //Existing Reversal Id - this is done for legacy where data is not tagged fully mainly for DZ
            
            List<RW_Payment_Detail_Item__c> receiptItemtoUpdate = new List<RW_Payment_Detail_Item__c>();
            Map<String,RW_Demand_Item__c> DemandItemtoUpdate = new Map<String,RW_Demand_Item__c>();
            //Query the Payment details object with the uniqueIds set and get the existing payments in the system  
            List<RW_Payment_Details__c> PaymentDetailsWithUniqueKey = [select id,RW_UniqueId__c, name, RW_Customer_ID__c,
                                                                       RW_Status_Code__c,RW_Status_Description__c,
                                                                       (select id,RW_Amount__c ,RW_Demand_Item_Number__c,RW_Demand_Number__c,RW_Demand_Item__c from Payment_Detail_Items__r 
                                                                        where RW_Demand_Item__c = null)   
                                                                       from RW_Payment_Details__c where RW_UniqueId__c  In: uniqueIds];
            for(RW_Payment_Details__c PaymentUnique : PaymentDetailsWithUniqueKey)
            {
                if(mapResponse.ContainsKey(PaymentUnique.RW_UniqueId__c))
                {
                    SAPPaymentInterface.ZsdSfdcPaymentReceipt responseV =   mapResponse.get(PaymentUnique.RW_UniqueId__c)[0];              
                    //Check the payment update condition. Payment update will happen on if the payment is reversed, so we are checking if payment status is null in exisiting record and in the new response it is not null
                    if((PaymentUnique.RW_Status_Code__c == null || PaymentUnique.RW_Status_Description__c == null || PaymentUnique.RW_Status_Code__c == '' || PaymentUnique.RW_Status_Description__c == '') 
                       && (responseV.ZstatusCode !=null || responseV.ZstatusDescp !=null || responseV.ZstatusCode !='' || responseV.ZstatusDescp !='' )&&
                       (PaymentUnique.RW_Status_Code__c!= responseV.ZstatusCode || PaymentUnique.RW_Status_Description__c!= responseV.ZstatusDescp))
                    {
                        PaymentUnique.RW_Status_Code__c = responseV.ZstatusCode;
                        PaymentUnique.RW_Status_Description__c = responseV.ZstatusDescp;
                        PaymentUnique.RW_Document_Type__c = responseV.HBlart;
                        // the the payment record to the ListToUpdatePayment to update
                        ListToUpdatePayment.add(PaymentUnique);
                        
                        //below is nasty workaround done for legacy receipts where receipts are not tagged to demands and
                        //Receipt gets reversed, so we need to reduce the reversed amount from legacy amount field of the demand item
                        for(SAPPaymentInterface.ZsdSfdcPaymentReceipt payrece: mapResponse.get(PaymentUnique.RW_UniqueId__c))
                        {                    
                            for(RW_Payment_Detail_Item__c PDi :PaymentUnique.Payment_Detail_Items__r){
                                if(PDI.RW_Amount__c == Decimal.valueOf( payrece.Dmbtr)){
                                    
                                    if (MapofDemandNumWithDemand.containsKey(payrece.Zdemand)) { 
                                        RW_Demand__c dmd =  MapofDemandNumWithDemand.get(payrece.Zdemand);
                                        if(dmd !=null){
                                            if(dmd.Demand_Items__r.size()==1){
                                                if( dmd.Demand_Items__r[0].RW_Legacy_Amount_Paid__c!=null&&dmd.Demand_Items__r[0].RW_Legacy_Demand__c){
                                                    PDI.RW_Demand_Item__c = dmd.Demand_Items__r[0].id;
                                                    PDI.RW_Demand_Number__c = payrece.Zdemand;
                                                    receiptItemtoUpdate.add(PDI);
                                                    if(DemandItemtoUpdate.containskey( dmd.Demand_Items__r[0].id))
                                                    {
                                                        RW_Demand_Item__c d =       DemandItemtoUpdate.get(dmd.Demand_Items__r[0].id);
                                                        if( Decimal.valueOf( payrece.Dmbtr)<d.RW_Legacy_Amount_Paid__c){
                                                            d.RW_Legacy_Amount_Paid__c = d.RW_Legacy_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                        }else{
                                                            d.RW_Legacy_Amount_Paid__c=0; 
                                                        }
                                                        if(Decimal.valueOf( payrece.Dmbtr)< d.Total_Demand_Item_Amount_Paid__c)
                                                            d.Total_Demand_Item_Amount_Paid__c = d.Total_Demand_Item_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                        else 
                                                            d.Total_Demand_Item_Amount_Paid__c =0;
                                                        DemandItemtoUpdate.put(d.id,d);
                                                    }else{
                                                        if( dmd.Demand_Items__r[0].RW_Legacy_Amount_Paid__c>Decimal.valueOf( payrece.Dmbtr))
                                                            dmd.Demand_Items__r[0].RW_Legacy_Amount_Paid__c = dmd.Demand_Items__r[0].RW_Legacy_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                        else
                                                            dmd.Demand_Items__r[0].RW_Legacy_Amount_Paid__c=0;
                                                        if(   dmd.Demand_Items__r[0].Total_Demand_Item_Amount_Paid__c >Decimal.valueOf( payrece.Dmbtr))
                                                            dmd.Demand_Items__r[0].Total_Demand_Item_Amount_Paid__c = dmd.Demand_Items__r[0].Total_Demand_Item_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                        else 
                                                            dmd.Demand_Items__r[0].Total_Demand_Item_Amount_Paid__c =0;   
                                                        
                                                        DemandItemtoUpdate.put( dmd.Demand_Items__r[0].id, dmd.Demand_Items__r[0]);
                                                    }
                                                } 
                                            }else{
                                                for(RW_Demand_Item__c dmrd : dmd.Demand_Items__r){
                                                    if(dmrd.RW_Demand_Item_Number__c ==payrece.POSNR && dmrd.RW_Legacy_Amount_Paid__c !=null && dmrd.RW_Legacy_Demand__c){
                                                        PDI.RW_Demand_Item__c = dmrd.id;
                                                        PDI.RW_Demand_Number__c = payrece.Zdemand;
                                                        PDI.RW_Demand_Item_Number__c =payrece.Posnr;
                                                        receiptItemtoUpdate.add(PDI);
                                                        
                                                        if(DemandItemtoUpdate.containskey( dmrd.id))
                                                        {RW_Demand_Item__c dm = DemandItemtoUpdate.get( dmrd.id);
                                                         if(  dm.RW_Legacy_Amount_Paid__c>Decimal.valueOf( payrece.Dmbtr))
                                                             dm.RW_Legacy_Amount_Paid__c = dm.RW_Legacy_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                         else
                                                             dm.RW_Legacy_Amount_Paid__c=0;
                                                         if( dm.Total_Demand_Item_Amount_Paid__c>Decimal.valueOf( payrece.Dmbtr))
                                                             dm.Total_Demand_Item_Amount_Paid__c =    dm.Total_Demand_Item_Amount_Paid__c -Decimal.valueOf( payrece.Dmbtr);
                                                         else
                                                             dm.Total_Demand_Item_Amount_Paid__c=0;
                                                         DemandItemtoUpdate.put(dmrd.id, dmrd);
                                                        }else{
                                                            if(  dmrd.RW_Legacy_Amount_Paid__c>Decimal.valueOf( payrece.Dmbtr))
                                                                dmrd.RW_Legacy_Amount_Paid__c = dmrd.RW_Legacy_Amount_Paid__c - Decimal.valueOf( payrece.Dmbtr);
                                                            else
                                                                dmrd.RW_Legacy_Amount_Paid__c =0;
                                                            if(  dmrd.Total_Demand_Item_Amount_Paid__c >Decimal.valueOf( payrece.Dmbtr))
                                                                dmrd.Total_Demand_Item_Amount_Paid__c =    dmrd.Total_Demand_Item_Amount_Paid__c -Decimal.valueOf( payrece.Dmbtr);
                                                            else
                                                                dmrd.Total_Demand_Item_Amount_Paid__c =0;
                                                            DemandItemtoUpdate.put(dmrd.id, dmrd);
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                        // system.debug('qwerty'+ListToUpdatePayment);
                    }
                    //Add all the existing payment records unique ids to UniqueIdsList which will be excluded from the insert operation
                    ExistingUniqueIdsList.add(PaymentUnique.RW_UniqueId__c);
                }
            }
            
            
            
            
            //  system.debug(MapofDemandNumWithDemand);
            //below loop will be used to insert the new record in to the payment detail and detail item object along with the demand linkage
            if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
            {
                for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
                {
                    String UniqueIdsPayment = responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs;
                    //   system.debug('$$$$$$$$$$$$'+UniqueIdsPayment); 
                    //if(responseRec.HBlart == 'DF' || responseRec.HBlart == 'DE' || responseRec.HBlart =='D1')
                    if(chequeCode.contains(responseRec.HBlart) && !ExistingUniqueIdsList.Contains(UniqueIdsPayment) )// MapOfDemandWithCustomerId.ContainsKey(responseRec.kunnr)
                    {//system.debug('MK');
                        
                        //if the payments wrapper doesnt have uniqueid build the payment detail and detail item
                        if(!mapOfReceiptWrapper.ContainsKey(UniqueIdsPayment))
                        {
                            //  system.debug('MK'+responseRec);
                            receiptWrapper receiptWrapper = new receiptWrapper();
                            receiptWrapper.paymentDetails  = new RW_Payment_Details__c();
                            receiptWrapper.paymentDetailsItems = new List<RW_Payment_Detail_Item__c>();
                            receiptWrapper.paymentDetails.RW_Customer_ID__c = responseRec.kunnr;
                            receiptWrapper.paymentDetails.RW_Payment_Date__c = Date.valueOf(responseRec.Bldat);
                            receiptWrapper.paymentDetails.RW_Posting_Date__c = Date.valueOf(responseRec.HBudat);
                            receiptWrapper.paymentDetails.RW_Document_Type__c = responseRec.HBlart;
                            receiptWrapper.paymentDetails.RW_Instrument_Number__c = responseRec.Zuonr;
                            if(responseRec.Dmbtr != null && responseRec.Dmbtr !='')                   
                                receiptWrapper.paymentDetails.RW_Payment_Amount__c =  Decimal.valueOf(responseRec.Dmbtr);
                            receiptWrapper.paymentDetails.RW_Fiscal_Year__c = responseRec.Gjahr;
                            receiptWrapper.paymentDetails.RW_Accounting_Document_Number__c = responseRec.Belnr; 
                            receiptWrapper.paymentDetails.RW_Company_Code__c=responseRec.Bukrs;
                            receiptWrapper.paymentDetails.RW_Bank_Name__c=responseRec.Bktxt;
                            receiptWrapper.paymentDetails.RW_Status_Description__c = responseRec.ZstatusDescp;
                            receiptWrapper.paymentDetails.RW_Clearing_Document_Number__c = responseRec.Augbl;
                            receiptWrapper.paymentDetails.RW_Status_Code__c=responseRec.ZstatusCode;
                            receiptWrapper.paymentDetails.RW_ODN_Number__c = responseRec.Zodn;
                            receiptWrapper.paymentDetails.RW_Payment_Item_Number__c = responseRec.Buzei;
                            receiptWrapper.paymentDetails.RW_Demand_Number__c =responseRec.Zdemand;
                            receiptWrapper.paymentDetails.RW_Usage_Description__c = responseRec.Sgtxt;
                            receiptWrapper.paymentDetails.RW_Usage_Code__c = responseRec.Xref1;
                            // system.debug('$$$$$$$$$');
                            //  system.debug(receiptWrapper);
                            // receiptWrapper.paymentDetails.RW_Demand__c = MapOfDemandWithCustomerId.get(responseRec.kunnr).Id;
                            //Below if will tag Opportunity to the Payment details valid for EOI scenario
                            if(customerOppMap.containsKey(responseRec.kunnr) )
                            {
                                
                                receiptWrapper.paymentDetails.Opportunity__c =  customerOppMap.get(responseRec.kunnr).Id;
                                
                            } else{
                                //Tag booking record
                                receiptWrapper.paymentDetails.RW_Booking__c = MapOfBookingCustomerId.get(responseRec.kunnr);     
                                
                            }  
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
                            
                            //check if the demand of payment record exists in MapOfDemandWithCustomerId and if existing loop through the demand items
                            //and check if demand item number matches the demand item number of the payment, if matches set the lookup field
                            if( MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)  ){
                                
                                if(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r.size() ==1){
                                    PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].Id;
                                    if(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].RW_Legacy_Demand__c && Date.valueOf(responseRec.HBudat)<date.newInstance(integer.valueOf(timestamp.left(4)),integer.valueOf(timestamp.mid(4,2)),integer.valueOf(timestamp.mid(6,2))) - 1){
                                        {
                                            if(DemandItemtoUpdate.containskey(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].id)){
                                                RW_Demand_Item__c dm =DemandItemtoUpdate.get(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].id);
                                                if( dm.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                    dm.RW_Legacy_Amount_Paid__c =   dm.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                else
                                                    dm.RW_Legacy_Amount_Paid__c =0;
                                                DemandItemtoUpdate.put(dm.id,dm);
                                            }else{
                                                RW_Demand_Item__c dm =MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0];
                                                if(dm.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                    dm.RW_Legacy_Amount_Paid__c =   dm.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                else
                                                    dm.RW_Legacy_Amount_Paid__c =0;
                                                DemandItemtoUpdate.put(dm.id,dm);
                                            }
                                        }
                                    }
                                    
                                }
                                else{
                                    for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r)
                                    {
                                        if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR)){
                                            PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                            
                                            
                                            if(demandItemList.RW_Legacy_Demand__c && Date.valueOf(responseRec.HBudat)<date.newInstance(integer.valueOf(timestamp.left(4)),integer.valueOf(timestamp.mid(4,2)),integer.valueOf(timestamp.mid(6,2))) - 1){
                                                { 
                                                    if(DemandItemtoUpdate.containskey(demandItemList.id)){
                                                        RW_Demand_Item__c   dnd =DemandItemtoUpdate.get(demandItemList.id);
                                                        if( demandItemList.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                        demandItemList.RW_Legacy_Amount_Paid__c =   demandItemList.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                        else
                                                             demandItemList.RW_Legacy_Amount_Paid__c = 0;
                                                        DemandItemtoUpdate.put(dnd.id,dnd);
                                                    }else{
                                                        if(demandItemList.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                        demandItemList.RW_Legacy_Amount_Paid__c =   demandItemList.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                        else
                                                                demandItemList.RW_Legacy_Amount_Paid__c = 0;
                                                        DemandItemtoUpdate.put(demandItemList.id,demandItemList);   
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // PaymentItems.RW_Demand_Item__c = MapOfDemandItemWithCustomerId.get(responseRec.kunnr).Id;
                            
                            receiptWrapper.paymentDetailsItems.add(PaymentItems);
                            //build the payment detail and detail item wrapper
                            mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                            //  system.debug('$$$$$$$$$$$$$$$');
                            
                            // system.debug(mapOfReceiptWrapper);
                        }
                        else{
                            
                            //system.debug('*5**'+responseRec.Bldat);
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
                            
                            //check if the demand of payment record exists in MapofDemandNumWithDemand and if existing loop through the demand items
                            //and check if demand item number matches the demand item number of the payment, if matches set the lookup field                        
                          /*  if(MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)){
                                for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r)
                                {
                                    if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR))
                                        PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                }
                            }*/
                                                        if( MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)  ){
                                
                                if(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r.size() ==1){
                                    PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].Id;
                                    if(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].RW_Legacy_Demand__c && Date.valueOf(responseRec.HBudat)<date.newInstance(integer.valueOf(timestamp.left(4)),integer.valueOf(timestamp.mid(4,2)),integer.valueOf(timestamp.mid(6,2))) - 1){
                                        {
                                            if(DemandItemtoUpdate.containskey(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].id)){
                                                RW_Demand_Item__c dm =DemandItemtoUpdate.get(MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].id);
                                                if( dm.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                    dm.RW_Legacy_Amount_Paid__c =   dm.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                else
                                                    dm.RW_Legacy_Amount_Paid__c =0;
                                                DemandItemtoUpdate.put(dm.id,dm);
                                            }else{
                                                RW_Demand_Item__c dm =MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0];
                                                if(dm.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                    dm.RW_Legacy_Amount_Paid__c =   dm.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                else
                                                    dm.RW_Legacy_Amount_Paid__c =0;
                                                DemandItemtoUpdate.put(dm.id,dm);
                                            }
                                        }
                                    }
                                    
                                }
                                else{
                                    for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r)
                                    {
                                        if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR)){
                                            PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                            
                                            
                                            if(demandItemList.RW_Legacy_Demand__c && Date.valueOf(responseRec.HBudat)<date.newInstance(integer.valueOf(timestamp.left(4)),integer.valueOf(timestamp.mid(4,2)),integer.valueOf(timestamp.mid(6,2))) - 1){
                                                { 
                                                    if(DemandItemtoUpdate.containskey(demandItemList.id)){
                                                        RW_Demand_Item__c   dnd =DemandItemtoUpdate.get(demandItemList.id);
                                                        if( demandItemList.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                        demandItemList.RW_Legacy_Amount_Paid__c =   demandItemList.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                        else
                                                             demandItemList.RW_Legacy_Amount_Paid__c =0;
                                                        DemandItemtoUpdate.put(dnd.id,dnd);
                                                    }else{
                                                        if( demandItemList.RW_Legacy_Amount_Paid__c >  Decimal.valueOf(responseRec.Dmbtr))
                                                        demandItemList.RW_Legacy_Amount_Paid__c =   demandItemList.RW_Legacy_Amount_Paid__c -  Decimal.valueOf(responseRec.Dmbtr);
                                                       else
                                                            demandItemList.RW_Legacy_Amount_Paid__c =0;
                                                        DemandItemtoUpdate.put(demandItemList.id,demandItemList);   
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            receiptWrapper.paymentDetailsItems.add(PaymentItems);
                            //build the payment detail and detail item wrapper
                            mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                            //  system.debug('%%%%%%%%%%%%%');
                            // system.debug(mapOfReceiptWrapper);
                        }
                        
                        
                    }//ending of else
                    
                    
                }//end of for
                
            } //end of if
            List<RW_Payment_Details__c> receiptToInsert = new List<RW_Payment_Details__c>();
            // system.debug('receiptToInsert' + receiptToInsert);
            //loop through the payment wrapper and make payment detail list to insert
            for(receiptWrapper dw : mapOfReceiptWrapper.values())
            {
                receiptToInsert.add(dw.paymentDetails);
            }
            if(DemandItemtoUpdate.size()>0)
                update DemandItemtoUpdate.values(); 
            if(ListToUpdatePayment.size()>0)
                receiptToInsert.AddALL(ListToUpdatePayment);
            upsert receiptToInsert;
            //system.debug(receiptToInsert);
            set<id> payid = new set<id>();
            for(RW_Payment_Details__c rc : receiptToInsert){
                payid.add(rc.id);
            }
            List<RW_Payment_Details__c> pac=   [select id,RW_UniqueId__c,RW_Customer_ID__c from RW_Payment_Details__c where id in : payid];
            List<RW_Payment_Detail_Item__c> receiptItemToInsert = new List<RW_Payment_Detail_Item__c>();
            //    system.debug('receiptItemToInsert' + receiptItemToInsert);
            //loop through the inserted payment details and get the payment detail item from wrapper and set the payment detail id(m-d relationship)
            Map<String,String> CnumPayIdMap = new Map<String,String>();
            // system.debug(receiptToInsert);
            
            for(RW_Payment_Details__c pd : pac)
            {
                CnumPayIdMap.put(pd.RW_Customer_ID__c,pd.id);
                //  system.debug(pd.RW_UniqueId__c);
                if(mapOfReceiptWrapper.containsKey(pd.RW_UniqueId__c)){
                    List<RW_Payment_Detail_Item__c> paymentDetailsItems = mapOfReceiptWrapper.get(pd.RW_UniqueId__c).paymentDetailsItems;
                    //   system.debug(paymentDetailsItems);
                    for(RW_Payment_Detail_Item__c pdi : paymentDetailsItems)
                    {
                        pdi.RW_Payment_Details__c = pd.Id;
                    }
                    
                    receiptItemToInsert.addAll(paymentDetailsItems);}
            }
            //inserting payment detail item
            // system.debug(receiptItemToInsert);
            if(receiptItemtoUpdate.size()>0)
                receiptItemToInsert.addAll(receiptItemtoUpdate) ; 
            if(receiptItemToInsert.size()>0)
                upsert  receiptItemToInsert;
            system.debug('End');
            //linking Reciept to Demand via junction object
            //loop through the Map values of wrapper CnumPayIdMap,MapofDemandNumWithDemand
            set<String> demandReciept = new set<String>();
            List<RW_Demand_Reciept__c> demandRec = new List<RW_Demand_Reciept__c>();
            for(receiptWrapper rw : mapOfReceiptWrapper.values()){
                for(RW_Payment_Detail_Item__c pdi : rw.paymentDetailsItems){
                    
                    if(MapofDemandNumWithDemand.containsKey(pdi.RW_Demand_Number__c) && !demandReciept.contains(pdi.RW_Demand_Number__c +'|'+rw.paymentDetails.RW_Accounting_Document_Number__c+'|'+rw.paymentDetails.RW_Fiscal_Year__c+'|'+rw.paymentDetails.RW_Company_Code__c)){
                        RW_Demand_Reciept__c dc = new RW_Demand_Reciept__c();
                        dc.RW_Demand__c =      MapofDemandNumWithDemand.get(pdi.RW_Demand_Number__c).id;
                        dc.RW_Payment_Details__c = CnumPayIdMap.get( rw.paymentDetails.RW_Customer_ID__c);
                        demandReciept.add(pdi.RW_Demand_Number__c +'|'+rw.paymentDetails.RW_Accounting_Document_Number__c+'|'+rw.paymentDetails.RW_Fiscal_Year__c+'|'+rw.paymentDetails.RW_Company_Code__c);
                        demandRec.add(dc);
                    }
                    
                }
            }
            insert demandRec;
            
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Receipts API';
            erp.Status__c = 'Failure';
            erp.Request__c =timestamp;
            erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            insert erp;
        }
        
    }
    
    public static void paymentDetailRollUps(set<Id> PaymentDetailIds)
    {
        
        List<Booking__c> bookingsToUpdate = new List<Booking__c>();
        
        if(PaymentDetailIds.size() > 0)
        {
            bookingsToUpdate = [Select id,RW_Total_Receipt_Amount_Received__c,RW_Total_Receipt_Discount_Recieved__c, (Select id,Total_Amount_Paid__c,RW_Status_Code__c,RW_Document_Type__c from Payment_Details__r where RW_Status_Code__c = null ) from Booking__c where id IN : PaymentDetailIds];
        }
        //  system.debug('%%%%%%%%%%%%');
        //  system.debug(bookingsToUpdate);
        List<String> chequeCode =   System.Label.RW_DocumentType4AmountReceived.split(','); //new List<String>{'DF','DZ','D1'};
        List<String> discountchequeCode =System.Label.RW_DocumentType4DiscountsReceived.split(','); // new List<String>{'DS','DB'};
        
        for(Booking__c book : bookingsToUpdate)
        {
            Decimal val = 0.00;
            Decimal valdiscount = 0.00;
            
            for(RW_Payment_Details__c pd : book.Payment_Details__r){
                if(pd.RW_Status_Code__c == null && pd.RW_Document_Type__c !=null)
                {
                    if(chequeCode.contains(pd.RW_Document_Type__c))
                    {
                        // book.RW_Total_Receipt_Amount_Received__c = val;
                        val += pd.Total_Amount_Paid__c; 
                    }
                    
                    if(discountchequeCode.contains(pd.RW_Document_Type__c))
                    {
                        valdiscount += pd.Total_Amount_Paid__c; 
                    }  
                }
                
                //  system.debug('$$$$$$$$$$$$$$$'+val+'%%%%%%%%%%%%'+valdiscount);
            }
            book.RW_Total_Receipt_Amount_Received__c = val;
            book.RW_Total_Receipt_Discount_Recieved__c = valdiscount;
        }
        //   system.debug(bookingsToUpdate);   
        BookingTriggerHandler.byPass =true;
        update bookingsToUpdate;
        BookingTriggerHandler.byPass =false;
    }
    
    
    class receiptWrapper
    { 
        public RW_Payment_Details__c paymentDetails;
        public List<RW_Payment_Detail_Item__c> paymentDetailsItems;
    }
    
    
    
}