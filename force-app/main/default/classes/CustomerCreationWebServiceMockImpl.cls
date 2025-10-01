@isTest
global class CustomerCreationWebServiceMockImpl implements WebServiceMock {
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
               system.debug('*req*'+requestName);
       CustomerCreation.ZsdSfdcCustomerResponse_element respElement = 
           new CustomerCreation.ZsdSfdcCustomerResponse_element();
            //CustomerCreation.TableOfBapiret2 tb = new CustomerCreation.TableOfBapiret2();
               
               
           respElement.Customerno = '213456782134';
           response.put('response_x', respElement);
           }
}