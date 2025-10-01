@isTest
global class WebServiceMockImpl implements WebServiceMock {
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
       SAPPaymentInterface.ZsdSfdcPaymentReceiptResponse_element respElement = 
           new SAPPaymentInterface.ZsdSfdcPaymentReceiptResponse_element();
               
               //SAPPaymentInterface sapPayInterface = new SAPPaymentInterface();
               system.debug('before mock*');
               SAPPaymentInterface.ZsdSfdcPaymentReceipt itemRecs = new SAPPaymentInterface.ZsdSfdcPaymentReceipt();
                system.debug('after mock**');
               itemRecs.Belnr = 'test1';
               itemRecs.Gjahr = '';
               itemRecs.Bukrs='';
               itemRecs.Zdemand='';
               itemRecs.Kunnr ='87654323';
               itemRecs.HBlart = 'DF';
               itemRecs.Dmbtr ='1000';
               itemRecs.ZstatusCode ='06';
               itemRecs.Bldat = '2020-10-27';
               itemRecs.HBudat = '2020-10-27';
               
               SAPPaymentInterface.ZsdSfdcPaymentReceipt itemRecs1 = new SAPPaymentInterface.ZsdSfdcPaymentReceipt();
                system.debug('after mock**');
               itemRecs1.Belnr = 'test2';
               itemRecs1.Gjahr = '';
               itemRecs1.Bukrs='';
               itemRecs1.Zdemand='';
               itemRecs1.Kunnr ='87654323';
               itemRecs1.HBlart = 'DE';
               itemRecs.Dmbtr ='1000';
               itemRecs1.Bldat = '2020-10-27';
               itemRecs1.HBudat = '2020-10-27';
               SAPPaymentInterface.ZsdtSfdcPaymentReceipt PaymentReceipt = new SAPPaymentInterface.ZsdtSfdcPaymentReceipt();
               system.debug('after mock***');
               PaymentReceipt.item = new List<SAPPaymentInterface.ZsdSfdcPaymentReceipt>();
               PaymentReceipt.item.add(itemRecs);
               PaymentReceipt.item.add(itemRecs1);
               system.debug('after mock****');
       respElement.PaymentReceipt = PaymentReceipt;
       response.put('response_x', respElement); 
   }
}