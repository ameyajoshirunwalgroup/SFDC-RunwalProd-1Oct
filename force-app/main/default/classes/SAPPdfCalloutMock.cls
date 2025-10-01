@isTest
global class SAPPdfCalloutMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element respElement = 
           new SapSoapFunctionsMcS.ZsdSfdcPdfResponse_element();
       
       SapSoapFunctionsMcS.Bapiret2 bap = new SapSoapFunctionsMcS.Bapiret2();
       bap.Type_x='';
       bap.Id='';
       bap.Number_x='';
       bap.Message='';
        bap.LogNo='';
        bap.LogMsgNo='';
        bap.MessageV1='';
        bap.MessageV2='';
        bap.MessageV3='';
        bap.MessageV4='';
        bap.Parameter='';
        bap.Row=2;
        bap.Field='';
        bap.System_x='';   
               
       respElement.ZpdfBase64 = '564874';
       respElement.Zmessages = bap;
       response.put('response_x', respElement); 
   }
}