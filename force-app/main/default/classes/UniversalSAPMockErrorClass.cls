@istest
public class UniversalSAPMockErrorClass implements WebServiceMock  {
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
       /* else if(stub instanceof B)
            new BMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);*/
            else if(stub instanceof SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND)
            new demandMock().doInvoke(
                stub, request, response, 
                endpoint, soapAction, requestName, 
                responseNS, responseName, responseType);
        return;
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
              CalloutException e = new CalloutException();
        e.setMessage('Validation Error(s) occurred during inventory Get.');
        throw e;
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
           
              CalloutException e = new CalloutException();
        e.setMessage('Validation Error(s) occurred during inventory Get.');
        throw e; 
            
            
        
    }  
        
    }
}