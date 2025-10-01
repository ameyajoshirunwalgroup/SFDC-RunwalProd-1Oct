@RestResource(urlMapping='/ChannelPartnerServices/*') 
global class ChannelPartnerRestServices {
    
    @HttpPost
    global static void insertCP(){
        List<Broker__c> lstBroker = new List<Broker__c>(); 
        
        List < Response > lstResponse = new List < Response > ();
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString(); //the body of the request
        Set<id>insertIds = new Set<id>();
        lstBroker = (  List<Broker__c> )JSON.deserialize(jsonBody, List<Broker__c>.class);
        Map<String, String> labelToValue = new Map<String, String>();
        for (PickListEntry pe : Broker__c.TITLE__c.getDescribe().getPicklistValues()) {
                labelToValue.put(pe.getLabel(), pe.getValue());
        }
        
        for(Broker__c bc : lstBroker){
            
            string pan = bc.Broker_Pan_No__c.toLowerCase();
            if(pan.substring(3, 4) == 'p'){
                bc.Individual_CP__c = true;
                bc.name = bc.Name;
               //bc.name = bc.NAME_FIRST__c + ' '+bc.NAME_LAST__c;
            }else{
                bc.Representative_Name__c = bc.TITLE__c+' '+ bc.NAME_FIRST__c + ' '+bc.NAME_LAST__c;
            }
                bc.TITLE__c = labelToValue.get(bc.TITLE__c);
        }
        
        List<Broker__c> insertLIst = new LIst<Broker__c>();
        List<Broker__c> updateList = new List<Broker__c>();
        for(Broker__c bc : lstBroker){
            system.debug(  bc.id);
            if( String.isBlank(bc.id)){
                bc.id = null;
                system.debug('ml');
                insertLIst.add(bc);
            }else{
                                system.debug('mdl');

                updateList.add(bc);
            }
        }
        try{
            RestResponse res = RestContext.response;
            Database.SaveResult[] dbRes = Database.insert(insertLIst, false);
            for (Database.SaveResult sr:dbRes ) {
                if(sr.isSuccess()){
                    insertIds.add(sr.getId());
                }
            } 
            Database.SaveResult[] dbRes1 = Database.update(updateList, false);
            for (Database.SaveResult sr:dbRes1 ) {
                if(sr.isSuccess()){
                    insertIds.add(sr.getId());
                }
            } 
            
            
            Map<Id,Broker__c> successBroker =new Map<id,Broker__c>( [SELECT Address__c,Broker_Pan_No__c,Broker_Type__c,City__c,Country__c,CP_Speciality__c,Experience__c,Id,Is_NRI_CP__c,Lead_Generation_Methodology__c,Locality__c,Name,Phone_2__c,Pin_Code__c,Representative_Name__c,RW_Broker_Number__c,RW_Email__c,RW_GST_Number__c,RW_Is_GST_Applicable__c,RW_Is_RERA_Applicable__c,RW_Mobile_No__c,RW_Proof_of_Income__c,RW_RERA_Registration_Number__c,SAP_CP_Code__c,Service_Tax_No__c,State__c,Zone__c FROM Broker__c  where id IN :insertIds]);
            for (Database.SaveResult sr:dbRes ) {
                String errorMsg = '';
                if (sr.isSuccess()) {
                    res.statusCode = 200;
                    lstResponse.add(new Response('Successfully Inserted', successBroker.get(sr.getId())));
                }else{
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    }
                    res.statusCode = 400;
                    lstResponse.add(new Response(errorMsg, null));
                    
                } 
            }
             for (Database.SaveResult sr:dbRes1 ) {
                String errorMsg = '';
                if (sr.isSuccess()) {
                    res.statusCode = 200;
                    lstResponse.add(new Response('Successfully Updated', successBroker.get(sr.getId())));
                }else{
                    for (Database.Error err: sr.getErrors()) {
                        errorMsg = err.getStatusCode() + ': ' + err.getMessage();
                    }
                    res.statusCode = 400;
                    lstResponse.add(new Response(errorMsg, null));
                    
                } 
            }
                        res.responseBody = Blob.valueOf(JSON.serialize(lstResponse));

        } catch (Exception e) {
            RestResponse res = RestContext.response;
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(new Response(e.getMessage(), null)));
        }
        
    }
    global class Response {
        public String message;
        public Broker__c broker;
        public Response(String message,Broker__c eventRec) {
            this.message = message;
            this.broker = eventRec;
        }
    }
    
    
}