@RestResource(urlMapping='/FB/API/Verify/*')   
global with sharing class fbLeads {    
    @HttpGet
    global static void fbVerifyEndPoint() {
        System.debug('Request:' + RestContext.request);
        RestContext.response.addHeader('Content-Type', 'text/plain');
        
        String challenge = RestContext.request.params.get('hub.challenge');
        String secret = RestContext.request.params.get('hub.verify_token');
        if(String.isNotBlank(secret) && secret.equals('secret007')) {
            RestContext.response.responseBody = Blob.valueOf(challenge);
        }
    }
    
    // When we subscribe to the lead gen event of page on which the lead gen form is present 
  // FB makes a call back to the remote site URL exposed by SFDC and posts a lead gen event message
  // from that get the lead gen id and insert into Social Media Lead object.
  
    @HttpPost
    global static void fbLeadCapture() {
        System.debug('Request:' + RestContext.request);
        Restrequest request = RestContext.request;
        fbParser1.fbEvent fbLeadEvent;
        List<fbParser1.Changes> changesList;
        fbParser1.Value leadEventValues;
        fbLeadEvent = fbParser1.parse(request.requestBody.toString());
        List<fbParser1.Entry> entryList = fbLeadEvent.entry;
        
        if(entryList != null && entryList.size() == 1)
          changesList = entryList[0].changes;
        else
          System.debug('Data issues with the incoming JSON');
        if(changesList != null && changesList.size() ==1) {
          leadEventValues = changesList[0].value;
          if(leadEventValues != null) {
            System.debug('Lead ID: ' + leadEventValues.leadgen_id + 'Form ID:' + leadEventValues.form_id + 'Page Id:' + leadEventValues.page_id + 'created time:' + leadEventValues.created_time);
            try {
              Social_Media_Lead__c sml = new Social_Media_Lead__c();
              sml.Lead_ID__c = leadEventValues.leadgen_id;
              sml.Form_ID__c = leadEventValues.form_id;
              sml.page_ID__c = leadEventValues.page_id;
              Integer unixTime = leadEventValues.created_time;
          DateTime dateInstance = datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0);
          Datetime dateTimeGMT = dateInstance.addSeconds(unixTime);
          Integer offset = UserInfo.getTimezone().getOffset(dateTimeGMT);
          Datetime dateTimeLocal = dateTimeGMT.addSeconds(offset).addSeconds(offset/1000);
              sml.lead_created_time__c = dateTimeLocal;
              sml.source__c = 'Facebook';
              insert sml;
              } catch (Exception ex) {
            }
          } else 
            System.debug('Data issues with the incoming JSON');
        }
        else
          System.debug('Data issues with the incoming JSON');
    }
   
    
}