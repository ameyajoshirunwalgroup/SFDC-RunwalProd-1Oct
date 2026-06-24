public class OzonetelCallDisposition {
    
    @InvocableMethod
    public static void sendDisposition(List<Id> tskId){
        getTask(tskId);
    }
    
    @future (callout = true)
    public static void getTask(List<Id> tskId){
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        
        List<Task> tskList = new List<Task>();
        tskList = [Select Id, Visit_Form_No__c,Description ,CallObject, Ameyo_Agent_Id__c
                   From Task
                   Where Id IN : tskId];
        
        
        system.debug('TaskList::'+tskList);
        String Enquiry = EncodingUtil.urlEncode('General Enquiry', 'UTF-8');
        string customer='runwal';
        string api='KK37f7a89c616b3150169a5542ac1d97df';
        //string api='KK35dc4938827b9d489316754bd59eb2d4';		//updated for in-ccaass changes
        
        system.debug('Enquiry '+Enquiry);
        
        
        for(Task tk : tskList){
            
            /*String Discription = EncodingUtil.urlEncode(tk.Description,'UTF-8');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
          //  request.setEndpoint('https://api1.cloudagent.in/CAServices/Disposition/DispositionAPI.php?customer='+customer+'&agentID='+tk.Ameyo_Agent_Id__c+'&apiKey='+api+'&did='+tk.Visit_Form_No__c+'&comments='+Discription+'&ucid='+tk.CallObject+'&action=set&disposition='+Enquiry);
          // request.setEndpoint('https://in1-ccaas-api.ozonetel.com/CAServices/Disposition/DispositionAPI.php?customer='+customer+'&agentID='+tk.Ameyo_Agent_Id__c+'&apiKey='+api+'&did='+tk.Visit_Form_No__c+'&comments='+Discription+'&ucid='+tk.CallObject+'&action=set&disposition='+Enquiry);
           request.setEndpoint('https://in1-ccaas-api.ozonetel.com/CAServices/Disposition/DispositionAPIV2.php?customer='+customer+'&agentID='+tk.Ameyo_Agent_Id__c+'&apiKey='+api+'&did='+tk.Visit_Form_No__c+'&comments='+Discription+'&ucid='+tk.CallObject+'&action=set&disposition='+Enquiry);*/
			
            //Added by Vinay 15-04-2026 Start
	        String jsonData = '{"disposition" : "' + Enquiry + '", "agentID" : "' + tk.Ameyo_Agent_Id__c + '", "did" : "' + tk.Visit_Form_No__c + '", "ucid" : "' + tk.CallObject + '", "userName" : "runwal", "action" : "Set"}';
            request.setEndpoint('https://in1-ccaas-api.ozonetel.com/ca_apis/DispositionAPIV2');
            request.setMethod('POST');
            request.setHeader('content-Type', 'application/json');
            request.setHeader('apiKey', System.label.Ozonetel_API_Key);
            request.setBody(jsonData);
            //Added by Vinay 15-04-2026 End
            try{
                system.debug('request : '+ request);
                response=http.send(request);
                System.debug('Response Body : '+response.getBody());
                system.debug('Response : '+response);
                system.debug('Response : '+response.getStatus());
            }catch(System.Exception e){
                System.debug('Exception:- '+e.getMessage());
            }
        }
    }
}