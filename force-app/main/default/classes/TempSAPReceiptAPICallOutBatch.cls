global class TempSAPReceiptAPICallOutBatch implements Database.Batchable<sObject>, Database.Stateful ,Database.AllowsCallouts {
    //Get the response for SAP Payment API 
    public  SAPPaymentInterface sapPaymentInterface = new SAPPaymentInterface();
    public    sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT payReceipt= new sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT();
    public    sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceipt= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
    public    sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceiptResponse= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
    public   Map<String,SAPPaymentInterface.ZsdSfdcPaymentReceipt> mapResponse = new Map<String,SAPPaymentInterface.ZsdSfdcPaymentReceipt>(); 
    public   Map<String,receiptWrapper> mapOfReceiptWrapperwithoutbooking = new Map<String,receiptWrapper>();
    public set<string> processed = new set<string>();
    public String timestamp;
    public String crn;
    public static boolean bypassErrorLog = false;
    public   List<String> chequeCode ;
    public    Map<String, RW_Demand__c> MapofDemandNumWithDemand = new Map<String, RW_Demand__c>();
    // Existing UniqueIds 
    public    List<String> ExistingUniqueIdsList = new List<String>();
    public set<string>uniqpaymentitemid= new set<string>();
    
    global  TempSAPReceiptAPICallOutBatch(String timestamp, String crn){
        this.timestamp = timestamp;
        chequeCode =system.label.SAP_Cheque_Codes.split(',');// new List<String>{'DF','DE','D1','DZ','DT','AB','DS','DB'};
        this.crn = crn;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        Set<String>  cutomerIds = new Set<String>(); 
        Set<String> uniqueIds = new Set<String>(); 
        Map<String,String> demandnumberMap = new Map<String,String>();
        
        
        
        try{
            // sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,System.now().format('yyyyMMddHHmmss'));
            
            if(test.isRunningTest()){
                String rec='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"], 	"item": [{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "0000006234-000005", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "50000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "001", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0010000180", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "3610725.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "R", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "R", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025445", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "389275.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "003", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, 	 { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "9033311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "123495678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "01400090145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, 	 { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "9033311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "0030000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "123495678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "032", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "01400090145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] } ';
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
                insert erp;
                
            }
        }  
        
        
        //System.debug('*after call*'+JSON.serialize( sfdcpayReceiptResponse));
        //   system.debug(sfdcpayReceiptResponse.item.size());
        //loop through the response 
        try{
            if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
            {
                for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
                {
                    if(chequeCode.contains(responseRec.HBlart) && responseRec.kunnr != null && responseRec.kunnr != '' && responseRec.kunnr == crn)
                    {
                        //build the customer id set to get the opportunity
                        cutomerIds.add(responseRec.kunnr);
                        //build the unique id set for checking duplicate
                        uniqueIds.add(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs);
                    }
                    //if demand number is not null then build the customer number to demand number map
                    system.debug(responseRec.Zdemand);
                    system.debug(responseRec.Zdemand != null && responseRec.Zdemand != '');
                    if(responseRec.Zdemand != null && responseRec.Zdemand != '' && responseRec.kunnr == crn)
                    {
                        demandnumberMap.put(responseRec.Zdemand,responseRec.kunnr);
                    }
                    //  add to the map demandnumberMap
                    //make map uniqqueid to response
                    mapResponse.put(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs,responseRec);
                }
            }
        }  catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Receipts API';
            erp.Status__c = 'Failure';
            erp.Request__c =timestamp;
            erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            insert erp;
        }
        
        
        system.debug('!!!!!!!!!!!!'+demandnumberMap.keyset());
        //Get all the demand in the system by querying it on demandNumberMap which we created above it will have demand which are present in the payments
        List<RW_Demand__c> ListOfDemands = [select id, name, RW_Customer_Number__c,RW_Billing_Document_Number__c, (select id,RW_Demand_Item_Number__c,Total_Demand_Item_Amount_Paid__c, name,RW_Legacy_Amount_Paid__c,RW_Legacy_Demand__c from Demand_Items__r) from RW_Demand__c where RW_Billing_Document_Number__c In: demandnumberMap.keyset()]; 
        for(RW_Demand__c demandList : ListOfDemands)
        {//build the customer number to demand number map
            MapofDemandNumWithDemand.put(demandList.RW_Billing_Document_Number__c, demandList);
        }
        
        List<RW_Payment_Details__c> ListToUpdatePayment = new List<RW_Payment_Details__c>();
        system.debug('uniqueIds_______.'+uniqueIds);
        //Query the Payment details object with the uniqueIds set and get the existing payments in the system  
        List<RW_Payment_Details__c> PaymentDetailsWithUniqueKey = [select id,RW_UniqueId__c,RW_Clearing_Document_Number__c, name, RW_Customer_ID__c,RW_Status_Code__c,RW_Status_Description__c from RW_Payment_Details__c where RW_UniqueId__c  In: uniqueIds];
        for(RW_Payment_Details__c PaymentUnique : PaymentDetailsWithUniqueKey)
        {
            if(mapResponse.ContainsKey(PaymentUnique.RW_UniqueId__c))
            {
                SAPPaymentInterface.ZsdSfdcPaymentReceipt responseV =   mapResponse.get(PaymentUnique.RW_UniqueId__c);              
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
                    
                }else if((PaymentUnique.RW_Clearing_Document_Number__c== null && responseV.Augbl != null)|| 
                         (PaymentUnique.RW_Clearing_Document_Number__c != responseV.Augbl))
                {
                    PaymentUnique.RW_Clearing_Document_Number__c = responseV.Augbl;
                    // the the payment record to the ListToUpdatePayment to update
                    ListToUpdatePayment.add(PaymentUnique);
                }
                //Add all the existing payment records unique ids to UniqueIdsList which will be excluded from the insert operation
                ExistingUniqueIdsList.add(PaymentUnique.RW_UniqueId__c);
            }
        }
        
        system.debug('qwerty'+ListToUpdatePayment.size());
        if(ListToUpdatePayment.size()>0)
            update ListToUpdatePayment;
        
        
        
        
        
        String soqlQuery = 'Select Id, Name,SAP_Customer_Number__c,Booking__c, (Select id,Name FROM EOI__r) from Opportunity where SAP_Customer_Number__c IN:cutomerIds and stagename in (\'Unit Booked\',\'EOI Received\') ';
        
        return Database.getQueryLocator(soqlQuery);
        
    }
    
    global void execute( Database.BatchableContext BC,     List<Opportunity> scope)
    {
        Map<String,receiptWrapper> mapOfReceiptWrapper = new Map<String,receiptWrapper>();
        Map<String,Opportunity> customerOppMap = new Map<String,Opportunity>();
        Map<String,Id> MapOfBookingCustomerId = new Map<String,Id>(); 
        
        for(Opportunity oppRecord : scope)
        {
            //If EOI is present we will tag the Payment Reciept to the Opportunity else it will be in tagged to booking record
            if(oppRecord.EOI__r.size() >0 && oppRecord.Booking__c ==null)
            {
                //   System.debug('*added in map**');
                customerOppMap.put(oppRecord.SAP_Customer_Number__c, oppRecord);
            }
            
            else{
                if(oppRecord.Booking__c != null){
                    MapOfBookingCustomerId.put(oppRecord.SAP_Customer_Number__c, oppRecord.Booking__c);
                    //     System.debug('*added in map of MapOfBookingCustomerId **' + MapOfBookingCustomerId);
                }
            }
        }
        system.debug('$$$$$$$$$$$$'+MapOfBookingCustomerId.size());
        
        try{
            system.debug(json.serialize(sfdcpayReceiptResponse));
            //below loop will be used to insert the new record in to the payment detail and detail item object along with the demand linkage
            if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
            {                system.debug('ExistingUniqueIdsList'+ExistingUniqueIdsList.size());
             
             for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
             {
                 String UniqueIdsPayment = responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs;
                 system.debug('$$$$$$$$$$$$'+UniqueIdsPayment); 
                 //if(responseRec.HBlart == 'DF' || responseRec.HBlart == 'DE' || responseRec.HBlart =='D1')
                 if(chequeCode.contains(responseRec.HBlart) && !ExistingUniqueIdsList.Contains(UniqueIdsPayment) )// MapOfDemandWithCustomerId.ContainsKey(responseRec.kunnr)
                 {system.debug('MK');
                  
                  //if the payments wrapper doesnt have uniqueid build the payment detail and detail item
                  if( customerOppMap.ContainsKey(responseRec.kunnr) || MapOfBookingCustomerId.containsKey(responseRec.kunnr) ){
                      if(!mapOfReceiptWrapper.ContainsKey(UniqueIdsPayment) || mapOfReceiptWrapper.get(UniqueIdsPayment).paymentDetails.RW_Customer_ID__c !=responseRec.kunnr)
                      {
                          system.debug('MK'+responseRec);
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
                          system.debug('$$$$$$$$$');
                          system.debug(receiptWrapper);
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
                          system.debug(MapofDemandNumWithDemand);
                          //check if the demand of payment record exists in MapOfDemandWithCustomerId and if existing loop through the demand items
                          //and check if demand item number matches the demand item number of the payment, if matches set the lookup field
                          if( MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)  ){
                              
                              
                              for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r)
                              {
                                  if( MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r.size()==1){
                                      PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].Id;
                                  }else {
                                      if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR))
                                          PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                  }
                              }
                          }
                          // PaymentItems.RW_Demand_Item__c = MapOfDemandItemWithCustomerId.get(responseRec.kunnr).Id;
                          
                          receiptWrapper.paymentDetailsItems.add(PaymentItems);
                          //build the payment detail and detail item wrapper
                          mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                          processed.add(UniqueIdsPayment);
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
                          system.debug(MapofDemandNumWithDemand);
                          //check if the demand of payment record exists in MapofDemandNumWithDemand and if existing loop through the demand items
                          //and check if demand item number matches the demand item number of the payment, if matches set the lookup field                        
                          if(MapofDemandNumWithDemand.containsKey(responseRec.Zdemand)){
                              for(RW_Demand_Item__c demandItemList : MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r)
                              {  
                                  if( MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r.size()==1){
                                      PaymentItems.RW_Demand_Item__c = MapofDemandNumWithDemand.get(responseRec.Zdemand).Demand_Items__r[0].Id;
                                  }else{
                                      if(demandItemList.RW_Demand_Item_Number__c == String.valueOf(responseRec.POSNR))
                                          PaymentItems.RW_Demand_Item__c = demandItemList.Id;
                                  }
                              }
                          }
                          receiptWrapper.paymentDetailsItems.add(PaymentItems);
                          //build the payment detail and detail item wrapper
                          mapOfReceiptWrapper.put(UniqueIdsPayment, receiptWrapper);
                          
                      }
                      
                  }
                  
                  
                 }//ending of else
                 
                 
             }//end of for
             
            } //end of if
            
            List<RW_Payment_Details__c> receiptToInsert = new List<RW_Payment_Details__c>();
            for(receiptWrapper dw : mapOfReceiptWrapper.values())
            {
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
            for(RW_Payment_Details__c pd : pac)
            {
                CnumPayIdMap.put(pd.RW_Customer_ID__c,pd.id);
                system.debug(pd.RW_UniqueId__c);
                if(mapOfReceiptWrapper.containsKey(pd.RW_UniqueId__c)){
                    List<RW_Payment_Detail_Item__c> paymentDetailsItems = mapOfReceiptWrapper.get(pd.RW_UniqueId__c).paymentDetailsItems;
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
                    
                    receiptItemToInsert.addAll(paymentDetailsItems);}
            }
            //inserting payment detail item
            system.debug('receiptItemToInsert------>'+receiptItemToInsert.size());
            if(receiptItemToInsert.size()>0)
                insert  receiptItemToInsert;
        }
        catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Receipts API';
            erp.Status__c = 'Failure';
            erp.Request__c =timestamp;
            //  erp.Response__c = ;
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            insert erp;
        }
        
    }
    
    
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug(mapOfReceiptWrapperwithoutbooking.size());
        
        
        
        
        List<RW_Payment_Details__c> receiptToInsertWB = new List<RW_Payment_Details__c>();
        for(receiptWrapper dw : mapOfReceiptWrapperwithoutbooking.values())
        {
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
        for(RW_Payment_Details__c pd : pacWB)
        {
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
        
        
        
        //BatchIrisAPIReceiptRestCallout recIRIS = new BatchIrisAPIReceiptRestCallout();
        //database.executeBatch(recIRIS, 1);
    }

	
    
    class receiptWrapper
    { 
        public RW_Payment_Details__c paymentDetails;
        public List<RW_Payment_Detail_Item__c> paymentDetailsItems;
    }
    
    
}