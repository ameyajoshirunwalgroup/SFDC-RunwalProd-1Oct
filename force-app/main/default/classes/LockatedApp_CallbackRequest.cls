@RestResource(urlMapping='/callbackReq/*')
global class LockatedApp_CallbackRequest {
	
    @HttpPost
    global static CallbackResp doPost(){
        RestRequest req = RestContext.request;
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Booking__c> bkg = [SELECT Id, Project__c, Unit_No__r.Relationship_Manager__r.User__c FROM Booking__c WHERE Id =: bkgId];
        if(bkg.size() > 0){
            Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
            Task tsk = new Task();
            tsk.RecordTypeId = recordTypeId;
            tsk.Subject = 'Call Back';
            tsk.Priority = 'Normal';
            tsk.Project__c = bkg[0].Project__c;
            tsk.WhatId = 'bkg[0].Id';
            tsk.OwnerId = bkg[0].Unit_No__r.Relationship_Manager__r.User__c;
            try{
                insert tsk;
                CallbackResp resp = new CallbackResp();
                resp.status = '200';
                resp.message = 'Callback requested';
                return resp;
            }catch(exception e){
                System.debug('--error--: ' + e);
            }
        }
        return null;
    }
    
    global class CallbackResp{
        public String status;
        public string message;
    }
}