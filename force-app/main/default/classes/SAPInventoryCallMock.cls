@isTest
global class SAPInventoryCallMock implements WebServiceMock {
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