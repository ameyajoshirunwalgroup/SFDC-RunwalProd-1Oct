@isTest
public class UniversalTestClassForErrorHandler {
    @testsetup
    public static void setupdata(){
                     string res= '{	"Salesdocument_type_info": ["Salesdocument", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"Salesdocument": "23456777",	"Return_x_type_info": ["Return", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "1", "false"],	"Return_x": {		"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"],';

             res +='"item": [{"Type_x_type_info": ["Type", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Type_x": "S","System_x_type_info": ["System", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"System_x": "ECQCLNT210","Row_type_info": ["Row", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"Row": 0,"Parameter_type_info": ["Parameter", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Parameter": "","Number_x_type_info": ["Number", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Number_x": "219",	"MessageV4_type_info": ["MessageV4", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"MessageV4": "","MessageV3_type_info": ["MessageV3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"MessageV3": "","MessageV2_type_info": ["MessageV2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],	"MessageV2": "","MessageV1_type_info": ["MessageV1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"MessageV1": "","Message_type_info": ["Message", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Message": "Sales document  was not changed","LogNo_type_info": ["LogNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"LogNo": "","LogMsgNo_type_info": ["LogMsgNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],';
             res +='"LogMsgNo": "000000","Id_type_info": ["Id", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"Id": "V4","Field_type_info": ["Field", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"],"field_order_type_info": ["Type_x", "Id", "Number_x", "Message", "LogNo", "LogMsgNo", "MessageV1", "MessageV2", "MessageV3", "MessageV4", "Parameter", "Row", "Field", "System_x"],';
             res +='"Field": "","apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]}],"field_order_type_info": ["item"],"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"]}}';
 

      
         Legal_Entity__c objlglentity = new Legal_Entity__c();
        objlglentity.Name = 'RS';
        objlglentity.RDS_Company_Code__c='rs';
        objlglentity.RDS_Service_Tax_No__c= '123456789012345';
        objlglentity.RDS_Company_Name__c='111';
        objlglentity.RDS_Address1__c='123';
        objlglentity.RDS_Address2__c='234';
        objlglentity.RDS_City__c='delhi';
        objlglentity.RDS_Pin_Code__c='201301';
        objlglentity.RDS_Phone__c='9953528045';
        objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
        
           Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T35';
        objpr.Name = 'TestProject';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Company_Code__c = objlglentity.Id;
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Stage__c='Launch';
        objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
        objpr.Project_Property_Type__c = 'Residential';
        objpr.S_Floor_Rise_Rate__c = 150;
        objpr.S_Applicable_From_Floor__c = 5;
        objpr.S_View1_PLC__c = 10;
        objpr.S_View2_PLC__c = 20;
        objpr.S_View3_PLC__c = 30;
        objpr.NPV__c = 12;
        objpr.S_Ready_Reckoner_Rate__c = 24000;
        objpr.Token_Amount__c = 200000;
        objpr.Service_Tax_Required_On_Token_Amount__c = true;
        objpr.Total_Max_Discount_Allowed__c = 100;
        objpr.Discount1_Type__c = 'General';
        //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
        objpr.Discount1_Per_Sq_Ft__c = 100;
        objpr.Discount2_Type__c = 'Armed Forces';
        objpr.Discount2_Per_Sq_Ft__c = 150;
        objpr.Discount3_Type__c = 'Corporate';
        objpr.Discount3_Per_Sq_Ft__c = 200;
        objpr.Discount4_Type__c = 'Employee';
        objpr.Discount4_Per_Sq_Ft__c = 250;
        objpr.Discount5_Type__c = 'NRI';
        objpr.Discount5_Per_Sq_Ft__c = 300;
        objpr.Discount6_Type__c = 'Physically Challenged';
        objpr.Discount6_Per_Sq_Ft__c = 350;
        objpr.Discount8_Description__c = 'summer offer';
        objpr.Discount8_Type__c = 'Special Offer';
        objpr.Discount8_Per_Sq_Ft__c = 1000;
        objpr.Discount9_Description__c = 'DAM';
        objpr.Discount9_Type__c = 'DAM';
        objpr.Discount9_Per_Sq_Ft__c = 2000;
        //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
        objpr.Discount2_Lumpsum__c = 100000;
        objpr.Allotment_Charges_1__c = 10000;
        objpr.Allotment_Charges_2__c = 10000;
        objpr.Allotment_Charges_3__c = 10000;
        objpr.Allotment_Charges_4__c = 10000;
        objpr.Allotment_Charges_5__c = 10000;
        objpr.Allotment_Charges_6__c = 10000;
        objpr=RDSCommon.CreateProject(objpr);
        
                String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;

           Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Qualification'; 
               objOpportunity.SAP_Customer_Number__c ='12345678';

        objOpportunity.RW_Project__c = objpr.id; 
             objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Booking__c bk = new booking__c();
        bk.Customer__c = objOpportunity.id;
        bk.Opportunity__c = objOpportunity.id;
        insert bk;
           objOpportunity.Booking__c = bk.Id;
               update objOpportunity;
        
        ERP_Integration_Log__c err = new ERP_Integration_Log__c(
        API_Name__c	='Sales Order',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
        Request__c =res,
            Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err;
                       String respnse ='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"], 	"item": [{ 		"TOT_INT_type_info": ["TOT_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_INT": "19184.0", 		"TOT_COLL_INT_type_info": ["TOT_COLL_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TOT_COLL_INT": "19184.0", 		"TDS_PAID_type_info": ["TDS_PAID", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_PAID": "0.0", 		"TDS_OUTSTND_type_info": ["TDS_OUTSTND", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_OUTSTND": "0.0", 		"TDS_DUE_type_info": ["TDS_DUE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_DUE": "0.0", 		"TDS_CERT_RECV_type_info": ["TDS_CERT_RECV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"TDS_CERT_RECV": "0.0", 		"INT_AMT_WAIVED_type_info": ["INT_AMT_WAIVED", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_WAIVED": "0.0", 		"INT_AMT_COLL_type_info": ["INT_AMT_COLL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_COLL": "0.0", 		"INT_AMT_BAL_type_info": ["INT_AMT_BAL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"INT_AMT_BAL": "19184.0", 		"GST_CHRG_INT_type_info": ["GST_CHRG_INT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_CHRG_INT": "3453.12", 		"field_order_type_info": ["ACCOUNT", "TOT_INT", "INT_AMT_WAIVED", "TOT_COLL_INT", "INT_AMT_COLL", "INT_AMT_BAL", "GST_CHRG_INT", "TDS_DUE", "TDS_PAID", "TDS_OUTSTND", "TDS_CERT_RECV"], 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"], 		"ACCOUNT_type_info": ["ACCOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ACCOUNT": "12345678" 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';

         ERP_Integration_Log__c err1 = new ERP_Integration_Log__c(
        API_Name__c	='Interest Ledger',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
        Request__c =respnse,
            Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err1;
        
                        String dmd ='{"item_type_info":["item","urn:sap-com:document:sap:rfc:functions",null,"0","-1","false"],"item":[{"USAGE_CODE_type_info":["USAGE_CODE","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"USAGE_CODE":"Z0041","STATUS_type_info":["STATUS","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"STATUS":"C","POSNR_type_info":["POSNR","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"POSNR":"000010","ODN_NO_type_info":["ODN_NO","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"ODN_NO":"RV20/10/50000125","MIL_STN_NAME_type_info":["MIL_STN_NAME","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"MIL_STN_NAME":"DUE ON 31ST MARCH 2019","GST_AMOUNT_type_info":["GST_AMOUNT","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"GST_AMOUNT":"394536.0","field_order_type_info":["CUSTOMER","B_DOC_NO","ODN_NO","DEMAND_DT","DEMAND_DUE_DT","DEMAND_AMOUNT","GST_AMOUNT","USAGE_CODE","MIL_STN_NAME","STATUS"],"DEMAND_DUE_DT_type_info":["DEMAND_DUE_DT","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"DEMAND_DUE_DT":"2021-01-19","DEMAND_DT_type_info":["DEMAND_DT","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"DEMAND_DT":"2021-01-04","DEMAND_AMOUNT_type_info":["DEMAND_AMOUNT","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"DEMAND_AMOUNT":"3287630.0","CUSTOMER_type_info":["CUSTOMER","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"CUSTOMER":"12345678","B_DOC_NO_type_info":["B_DOC_NO","urn:sap-com:document:sap:rfc:functions",null,"1","1","false"],"B_DOC_NO":"9010025444","apex_schema_type_info":["urn:sap-com:document:sap:rfc:functions","false","true"]}],"field_order_type_info":["item"],"apex_schema_type_info":["urn:sap-com:document:sap:rfc:functions","false","true"]}';
   ERP_Integration_Log__c err2 = new ERP_Integration_Log__c(
        API_Name__c	='Demand API',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
        Request__c =dmd,
            Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err2;
        
                        String rec='{ 	"item_type_info": ["item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false"], 	"item": [{ 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "0000006234-000005", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "50000.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "001", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0010000180", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025444", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "3610725.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "123111", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "R", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "R", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "9010025445", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "Z0001", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000010", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "389275.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "003", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-04", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000144", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}, { 		"Zuonr_type_info": ["Zuonr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zuonr": "903311", 		"ZstatusDescp_type_info": ["ZstatusDescp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusDescp": "Reversal in current period", 		"ZstatusCode_type_info": ["ZstatusCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"ZstatusCode": "01", 		"Zodn_type_info": ["Zodn", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zodn": "", 		"Zdemand_type_info": ["Zdemand", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Zdemand": "", 		"Xref1_type_info": ["Xref1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Xref1": "", 		"Sgtxt_type_info": ["Sgtxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Sgtxt": "Cheque", 		"Posnr_type_info": ["Posnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Posnr": "000000", 		"Kunnr_type_info": ["Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Kunnr": "12345678", 		"HBudat_type_info": ["HBudat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBudat": "2021-01-05", 		"HBlart_type_info": ["HBlart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"HBlart": "DZ", 		"Gjahr_type_info": ["Gjahr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Gjahr": "2020", 		"field_order_type_info": ["HBudat", "Belnr", "Bukrs", "Gjahr", "HBlart", "Bktxt", "Dmbtr", "Zuonr", "Kunnr", "Zodn", "ZstatusCode", "ZstatusDescp", "Augbl", "Zdemand", "Xref1", "Sgtxt", "Bldat", "Buzei", "Posnr"], 		"Dmbtr_type_info": ["Dmbtr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Dmbtr": "318217.0", 		"Buzei_type_info": ["Buzei", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Buzei": "002", 		"Bukrs_type_info": ["Bukrs", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bukrs": "1000", 		"Bldat_type_info": ["Bldat", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bldat": "2021-01-05", 		"Bktxt_type_info": ["Bktxt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Bktxt": "ICICI BANK LTD", 		"Belnr_type_info": ["Belnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Belnr": "0140000145", 		"Augbl_type_info": ["Augbl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false"], 		"Augbl": "", 		"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] 	}], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:soap:functions:mc-style", "false", "true"] }';
   ERP_Integration_Log__c err3 = new ERP_Integration_Log__c(
        API_Name__c	='Receipts API',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
        Request__c =rec,
            Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err3;
         ERP_Integration_Log__c err4 = new ERP_Integration_Log__c(
        API_Name__c	='Customer Creation/Update',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
             Request__c = '{ "customerTaxList" : { "item_type_info" : [ "item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false" ], "item" : [ { "Taxtype_type_info" : [ "Taxtype", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Taxtype" : "IN6", "Taxnumxl_type_info" : [ "Taxnumxl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Taxnumxl" : "QWERT1234A", "Ind_type_info" : [ "Ind", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Ind" : "M", "field_order_type_info" : [ "Ind", "Taxtype", "Taxnumxl" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] }, { "Taxtype_type_info" : [ "Taxtype", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Taxtype" : "IN5", "Taxnumxl_type_info" : [ "Taxnumxl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Taxnumxl" : "234512345678", "Ind_type_info" : [ "Ind", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Ind" : "M", "field_order_type_info" : [ "Ind", "Taxtype", "Taxnumxl" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] } ], "field_order_type_info" : [ "item" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] }, "customerHeader" : { "Xsexf_type_info" : [ "Xsexf", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Xsexf" : "F", "Werks_type_info" : [ "Werks", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Werks" : "1001", "Waers_type_info" : [ "Waers", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Waers" : null, "Vtweg_type_info" : [ "Vtweg", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Vtweg" : "Residential", "Vkorg_type_info" : [ "Vkorg", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Vkorg" : "1001", "Vkgrp_type_info" : [ "Vkgrp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Vkgrp" : null, "Vkbur_type_info" : [ "Vkbur", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Vkbur" : "1001", "Title_type_info" : [ "Title", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Title" : "Ms", "StaffGrp_type_info" : [ "StaffGrp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StaffGrp" : null, "Spart_type_info" : [ "Spart", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Spart" : "00", "Sort2_type_info" : [ "Sort2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Sort2" : "0061e000002W0SzAAK", "Sort1_type_info" : [ "Sort1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Sort1" : "1001R006104", "Niels_type_info" : [ "Niels", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Niels" : null, "Natio_type_info" : [ "Natio", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Natio" : "India", "NameMiddle_type_info" : [ "NameMiddle", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "NameMiddle" : null, "NameLast_type_info" : [ "NameLast", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "NameLast" : "MISTeam", "NameFirst_type_info" : [ "NameFirst", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "NameFirst" : "Shreya", "Marst_type_info" : [ "Marst", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Marst" : "Single", "Langucorr_type_info" : [ "Langucorr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Langucorr" : "E", "Kvgr5_type_info" : [ "Kvgr5", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kvgr5" : "Channel Partner", "Kvgr4_type_info" : [ "Kvgr4", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kvgr4" : null, "Kvgr3_type_info" : [ "Kvgr3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kvgr3" : "Shailesh Kotian", "Kvgr2_type_info" : [ "Kvgr2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kvgr2" : "Dhiren Goswami", "Kvgr1_type_info" : [ "Kvgr1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kvgr1" : "Deepak Arya", "Kunnr_type_info" : [ "Kunnr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kunnr" : null, "Kukla_type_info" : [ "Kukla", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kukla" : "Resident Indian", "Ktokd_type_info" : [ "Ktokd", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Ktokd" : "Residential", "Klabc_type_info" : [ "Klabc", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Klabc" : null, "Kdgrp_type_info" : [ "Kdgrp", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Kdgrp" : null, "Katr1_type_info" : [ "Katr1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Katr1" : "Channel Partner", "Jobgr_type_info" : [ "Jobgr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Jobgr" : "Accounting", "field_order_type_info" : [ "Kunnr", "Vkorg", "Werks", "Vtweg", "Spart", "Ktokd", "Title", "NameFirst", "NameLast", "NameMiddle", "Langucorr", "Sort1", "Sort2", "Xsexf", "Marst", "Natio", "Jobgr", "Birthdt", "Birthpl", "StaffGrp", "Bpext", "Kukla", "Niels", "Katr1", "Emplo", "Kvgr1", "Kvgr2", "Kvgr3", "Kvgr4", "Kvgr5", "Bzirk", "Vkbur", "Vkgrp", "Kdgrp", "Klabc", "Waers", "Addrcode" ], "Emplo_type_info" : [ "Emplo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Emplo" : "Runwal", "Bzirk_type_info" : [ "Bzirk", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Bzirk" : null, "Bpext_type_info" : [ "Bpext", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Bpext" : null, "Birthpl_type_info" : [ "Birthpl", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Birthpl" : null, "Birthdt_type_info" : [ "Birthdt", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Birthdt" : "19950104", "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ], "Addrcode_type_info" : [ "Addrcode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Addrcode" : "01" }, "customerAddressList" : { "item_type_info" : [ "item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false" ], "item" : [ { "StrSuppl3_type_info" : [ "StrSuppl3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl3" : null, "StrSuppl2_type_info" : [ "StrSuppl2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl2" : null, "StrSuppl1_type_info" : [ "StrSuppl1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl1" : "City", "Street_type_info" : [ "Street", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Street" : "Gotham", "Seqno_type_info" : [ "Seqno", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Seqno" : null, "Region_type_info" : [ "Region", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Region" : "Maharashtra", "PostCode_type_info" : [ "PostCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "PostCode" : "300120", "NameCo_type_info" : [ "NameCo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "NameCo" : null, "Location_type_info" : [ "Location", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Location" : null, "field_order_type_info" : [ "Addrcode", "Seqno", "NameCo", "Street", "StrSuppl1", "StrSuppl2", "StrSuppl3", "Location", "PostCode", "City", "Country", "Region" ], "Country_type_info" : [ "Country", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Country" : "India", "City_type_info" : [ "City", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "City" : "Mumbai", "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ], "Addrcode_type_info" : [ "Addrcode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Addrcode" : "01" }, { "StrSuppl3_type_info" : [ "StrSuppl3", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl3" : null, "StrSuppl2_type_info" : [ "StrSuppl2", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl2" : null, "StrSuppl1_type_info" : [ "StrSuppl1", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "StrSuppl1" : "City", "Street_type_info" : [ "Street", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Street" : "Gotham", "Seqno_type_info" : [ "Seqno", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Seqno" : null, "Region_type_info" : [ "Region", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Region" : "Maharashtra", "PostCode_type_info" : [ "PostCode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "PostCode" : "300120", "NameCo_type_info" : [ "NameCo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "NameCo" : null, "Location_type_info" : [ "Location", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Location" : null, "field_order_type_info" : [ "Addrcode", "Seqno", "NameCo", "Street", "StrSuppl1", "StrSuppl2", "StrSuppl3", "Location", "PostCode", "City", "Country", "Region" ], "Country_type_info" : [ "Country", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Country" : "India", "City_type_info" : [ "City", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "City" : "Mumbai", "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ], "Addrcode_type_info" : [ "Addrcode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Addrcode" : "02" } ], "field_order_type_info" : [ "item" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] }, "commList" : { "item_type_info" : [ "item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false" ], "item" : [ { "TelNumber_type_info" : [ "TelNumber", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "TelNumber" : null, "SmtpAddr_type_info" : [ "SmtpAddr", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "SmtpAddr" : "sandeepshreyasaachi@gmail.com", "Seqno_type_info" : [ "Seqno", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Seqno" : null, "MobileNo_type_info" : [ "MobileNo", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "MobileNo" : "3451212345", "field_order_type_info" : [ "Addrcode", "Seqno", "MobileNo", "SmtpAddr", "TelNumber", "FaxNumber" ], "FaxNumber_type_info" : [ "FaxNumber", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "FaxNumber" : null, "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ], "Addrcode_type_info" : [ "Addrcode", "urn:sap-com:document:sap:soap:functions:mc-style", null, "1", "1", "false" ], "Addrcode" : "01" } ], "field_order_type_info" : [ "item" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] }, "coAppList" : { "item_type_info" : [ "item", "urn:sap-com:document:sap:soap:functions:mc-style", null, "0", "-1", "false" ], "item" : [ ], "field_order_type_info" : [ "item" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:soap:functions:mc-style", "false", "true" ] } }',
            Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err4;
        
        string unit='{ "WERKS_type_info" : [ "WERKS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "WERKS" : "1001", "VTWEG_type_info" : [ "VTWEG", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "VTWEG" : "10", "VKORG_type_info" : [ "VKORG", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "VKORG" : "1001", "UTIL_A_type_info" : [ "UTIL_A", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "UTIL_A" : "16.68", "TAXCLASS3_type_info" : [ "TAXCLASS3", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "TAXCLASS3" : "1", "NTGEW_type_info" : [ "NTGEW", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "NTGEW" : "706.00", "MVGR5_type_info" : [ "MVGR5", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MVGR5" : "Z00", "MVGR4_type_info" : [ "MVGR4", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MVGR4" : "19", "MVGR3_type_info" : [ "MVGR3", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MVGR3" : null, "MVGR2_type_info" : [ "MVGR2", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MVGR2" : "R44", "MVGR1_type_info" : [ "MVGR1", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MVGR1" : "60", "MTART_type_info" : [ "MTART", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MTART" : "ZFER", "MSTAV_type_info" : [ "MSTAV", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MSTAV" : "01", "MFRGR_type_info" : [ "MFRGR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MFRGR" : "2", "MEINS_type_info" : [ "MEINS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MEINS" : "FT2", "MATNR_type_info" : [ "MATNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MATNR" : "1001R006003", "MAKTX_type_info" : [ "MAKTX", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MAKTX" : "A-6003", "KTGRM_type_info" : [ "KTGRM", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "KTGRM" : "ZA", "KONDM_type_info" : [ "KONDM", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "KONDM" : "ZA", "field_order_type_info" : [ "MATNR", "MTART", "MFRGR", "BISMT", "BRGEW", "NTGEW", "MEINS", "MSTAV", "WERKS", "MAKTX", "VKORG", "MVGR1", "MVGR2", "MVGR3", "MVGR4", "MVGR5", "VTWEG", "KONDM", "KTGRM", "TAXCLASS3", "DECK_A", "UTIL_A" ], "DECK_A_type_info" : [ "DECK_A", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "DECK_A" : "0.00", "BRGEW_type_info" : [ "BRGEW", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "BRGEW" : "1190.00", "BISMT_type_info" : [ "BISMT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "BISMT" : "A-6003", "apex_schema_type_info" : [ "urn:sap-com:document:sap:rfc:functions", "false", "true" ] }';
   
       ERP_Integration_Log__c err5 = new ERP_Integration_Log__c(
        API_Name__c	='Unit Inventory',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
             Request__c = unit,
           Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err5;
        string rate = '{ "item_type_info" : [ "item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false" ], "item" : [ { "WERKS_type_info" : [ "WERKS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "WERKS" : "1001", "VTWEG_type_info" : [ "VTWEG", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "VTWEG" : "10", "VKORG_type_info" : [ "VKORG", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "VKORG" : "1001", "MATNR_type_info" : [ "MATNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "MATNR" : "null", "KSCHL_type_info" : [ "KSCHL", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "KSCHL" : "ZPRM", "KBETR_type_info" : [ "KBETR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false" ], "KBETR" : "3.00", "field_order_type_info" : [ "KSCHL", "VKORG", "VTWEG", "WERKS", "MATNR", "KBETR" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:rfc:functions", "false", "true" ] } ], "field_order_type_info" : [ "item" ], "apex_schema_type_info" : [ "urn:sap-com:document:sap:rfc:functions", "false", "true" ] }';
       ERP_Integration_Log__c err6 = new ERP_Integration_Log__c(
        API_Name__c	='Price Change',
            Error_Reason__c='XYZ',
              Opportunity__c =objOpportunity.id,
            Booking__c = bk.id,
             Request__c = rate,
           Response__c='error',
            Status__c= 'Failure',
            Error_Type__c ='Timeout Error'
        );
        insert err6;
    }
       @istest
    public static void testErrorHandlers(){
                                Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

       
     RW_ErrorHandlerSchedulable sx  = new RW_ErrorHandlerSchedulable('Sales Order',2,'Runwal Bliss');
    sx.execute(null);
        RW_ErrorHandlerSchedulable sx1  = new RW_ErrorHandlerSchedulable('Customer Creation/Update',2,'Runwal Bliss');
    sx1.execute(null);
        RW_ErrorHandlerSchedulable sx2  = new RW_ErrorHandlerSchedulable('Unit Inventory',2,'Runwal Bliss');
    sx2.execute(null);
        RW_ErrorHandlerSchedulable sx3  = new RW_ErrorHandlerSchedulable('Price Change',2,'Runwal Bliss');
    sx3.execute(null);
        RW_ErrorHandlerSchedulable sx4  = new RW_ErrorHandlerSchedulable('Demand API',2,'Runwal Bliss');
    sx4.execute(null);
        RW_ErrorHandlerSchedulable sx5  = new RW_ErrorHandlerSchedulable('Receipts API',2,'Runwal Bliss');
    sx5.execute(null);
        RW_ErrorHandlerSchedulable sx6  = new RW_ErrorHandlerSchedulable('Interest Ledger',2,'Runwal Bliss');
    sx6.execute(null);
}
}