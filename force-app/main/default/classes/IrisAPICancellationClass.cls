public class IrisAPICancellationClass {
	
    @invocablemethod(label='Sends the Cancellation to IRIS' description='Send the Cancellation to IRIS')
    public static void sendtoiris(List<id> bkIds){
        bookingUpdate(bkIds);
    }
    
    @future(callout=true)
    public static void bookingupdate(List<id>bkids){

     IrisAPICancellationJson canjson = new IrisAPICancellationJson();
     canjson.user_request = new IrisAPICancellationJson.user_request();
     canjson.user_request.type ='cancellation'; 
        
            
       /*IrisAPIBookingDetailJson bkjson = new IrisAPIBookingDetailJson();
        
        bkjson.booking_detail = new IrisAPIBookingDetailJson.cls_booking_detail();
          bkjson.booking_detail.tasks_attributes = new IrisAPIBookingDetailJson.cls_tasks_attributes();
           bkjson.booking_detail.tasks_attributes.registration_done = true;*/
        List<ERP_Integration_Log__c> ers = new List<ERP_Integration_Log__c>();
        for(id i : bkIds){
              Http http1 = new Http();
             HttpRequest req1 = new HttpRequest(); 
                req1.setMethod('POST');
                req1.setHeader('Content-Type',  'application/json');
                req1.setHeader('Client-key', system.label.RW_IRIS_ClientSecret); 
                req1.setHeader('Client-id', System.label.RW_Iris_clientid); 
                req1.setEndpoint(System.label.RW_IRIS_Endpoint+'user_requests');
                canjson.user_request.booking_detail_id = i;
                req1.setBody(json.serialize(canjson));
                HTTPResponse res1;
                if(!Test.isRunningTest())
               res1 = http1.send(req1);
                //System.debug('res!!! getBody '+res1.getBody());
                //System.debug('res!!! getStatusCode '+res1.getStatusCode());
             if(res1 != null && (res1.getStatusCode() == 200 || res1.getStatusCode() == 201)){
                 
             }else{
                 
                 ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
                 erp.Request__c = json.serialize(canjson);
                 if(res1 != null)
                 erp.Response__c = json.serialize(res1.getBody());
                 erp.Status__c = 'Failure';
                 erp.Error_Type__c = 'Data Error';
                 erp.Booking__c = i;
                 erp.API_Name__c ='IRIS Booking';
                 ers.add(erp);
             }
            
        }
        if(ers.size() >0 && !Test.isRunningTest())
        insert ers;

    }

}