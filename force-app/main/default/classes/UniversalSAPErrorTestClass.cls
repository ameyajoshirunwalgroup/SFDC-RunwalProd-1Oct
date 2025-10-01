@istest
    public class UniversalSAPErrorTestClass {
/*
    @isTest
    public static void testdemandError(){
         try{
                        Test.setMock(WebServiceMock.class, new UniversalSAPMockErrorClass());
   SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND  sapDemandBNDApi  = new SapDemandApi.ZSD_SFDC_WSDL_DEMAND_BND();
       SAPDemandAPI.ZSD_SFDC_DEMAND_INFO dd= new SAPDemandAPI.ZSD_SFDC_DEMAND_INFO();
     sapDemandBNDApi.ZSD_SFDC_WS_DEMAND( '20210110101010'); 
         } 
     catch(calloutexception e){
            
     }}*/
   @isTest
    public static void testdemandSuccess(){
                        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        try{
  SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND  sapDemandBNDApi  = new SapDemandApi.ZSD_SFDC_WSDL_DEMAND_BND();
            sapDemandBNDApi.ZSD_SFDC_WS_DEMAND( '20210110101010',null); 
        SAPDemandsSchedulable sx = new SAPDemandsSchedulable(200);
         SAPDemandAPI.ZSD_SFDC_DEMAND_INFO dd = new SAPDemandAPI.ZSD_SFDC_DEMAND_INFO();
    sx.execute(null);
        }
        catch(calloutexception e){
            
        }
    
    }
        
          @isTest
    public static void testdemandSuccess1(){
                        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        try{
  SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND  sapDemandBNDApi  = new SapDemandApi.ZSD_SFDC_WSDL_DEMAND_BND();
            sapDemandBNDApi.ZSD_SFDC_WS_DEMAND( '20210110101010',null); 
        SAPDemandsSchedulable sx = new SAPDemandsSchedulable(200);
         SAPDemandAPI.ZSD_SFDC_DEMAND_INFO dd = new SAPDemandAPI.ZSD_SFDC_DEMAND_INFO();
    sx.execute(null);
                   sapDemandBNDApi.ZSD_SFDC_WS_DEMAND( '20210110101010',null); 
 }
        catch(calloutexception e){
            
        }
    
    }
@isTest
    public static void testreceiptSuccess(){
                        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        try{
  SAPPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT rec= new SAPPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT();
            SAPPaymentInterface.ZsdtSfdcPaymentReceipt PaymentReceipt = new SAPPaymentInterface.ZsdtSfdcPaymentReceipt();
            rec.ZsdSfdcPaymentReceipt(PaymentReceipt, '20210110101010'); 
        SAPReceiptsSchedulable sx = new SAPReceiptsSchedulable(200);
    sx.execute(null);
        }
        catch(calloutexception e){
            
        }
    
    }

    @istest
    public static void testinterest(){
                                Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

        SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND  bnd = new SAPInterestLedgerAPI.ZSD_SFDC_WS_INT_LDG_TDS_BND();
        SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_TT res= bnd.ZSD_SFDC_WS_INT_LDG_TDS('20210110101010',null);
        ScheduleLedgerAPI sx = new ScheduleLedgerAPI();
        
        SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST s  = new SAPInterestLedgerAPI.ZSD_SFDC_INT_LDG_TDS_ST();
    sx.execute(null);
}
    @istest
    public static void testpdf(){
                                        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());

        SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS mm = new SapSoapFunctionsMcS.ZSD_SFDC_PDF_WS();
        SapSoapFunctionsMcS.Bapiret2 bap = new SapSoapFunctionsMcS.Bapiret2();
    String base64=    mm.ZsdSfdcPdf('sfdsd', 'ZbdocNum', 'ZcompCode', 'ZcustNum', 'ZdocType', 'ZfiYear', 'ZsaleOrderNum').ZpdfBase64;
        system.assertEquals('d2R0Zmd5aHNqa2FkZml1YWhkc2l1ZmhhaXVkc2hmamlibmFka2puZGZhc2Rhcw==', base64);
    }
    
    
}