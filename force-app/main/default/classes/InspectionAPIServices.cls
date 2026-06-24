@RestResource(urlMapping='/CustomerService/InspectionAndPossession/*') 
global class InspectionAPIServices {
    
    
    @HttpPost
    global static String insertInspecPossession(){
        List<InspectionAndPossession__c> inspPossList = new List<InspectionAndPossession__c>(); 
        Map<String,InspectionAndPossession__c> inspectionMap = new map<String,InspectionAndPossession__c>();
        RestRequest req = RestContext.request; //the RestRequest for the Apex REST method
        String jsonBody = req.requestBody.toString(); //the body of the request
        if (!String.isBlank(jsonBody)) {
            inspPossList = (  List<InspectionAndPossession__c> )JSON.deserialize(jsonBody, List<InspectionAndPossession__c>.class );
            for(InspectionAndPossession__c insp : inspPossList)  {
                inspectionMap.put(insp.RW_SAP_Code__c,insp);              
                
            }
            
            List<Booking__C> bookings = [select id,Customer__c,Unit_No__r.Unit_SAP_Code__c from booking__C where Unit_No__r.Unit_SAP_Code__c in :inspectionMap.keyset() ];
            Map<String,Booking__c> bookMap = new Map<String,Booking__c>();
            for(Booking__c bk : bookings){
                bookMap.put(bk.Unit_No__r.Unit_SAP_Code__c, bk);                
            }
            for(String s : bookMap.keyset()){
                InspectionAndPossession__c is = inspectionMap.get(s);
                if(is.RW_Inspection_Status__c =='Readiness Completed'){
                    is.RW_No_due_certificate__c ='Received';
                }
                is.Booking__c = bookMap.get(s).id;
                 is.Opportunity__c = bookMap.get(s).Customer__c;
                inspectionMap.put(s,is);
            }
            
        }
 List<Database.upsertResult> uResults= Database.upsert(inspectionMap.values(),InspectionAndPossession__c.RW_SAP_Code__c,false) ;
        
        List<Id> listOfbkgs = new List<Id>();
        for(Integer index = 0, size = uResults.size(); index < size; index++) {
            if(uResults[index].isSuccess()) {
                if(uResults[index].isCreated()){
                    listOfbkgs.add(inspectionMap.values()[index].Booking__c);
                }else{
                    listOfbkgs.add(inspectionMap.values()[index].Booking__c);
                }
            }
        }
        if(listOfbkgs.size()>0){
          InspectionAndPossessionNotificationSetup.getInspPossDetails(listOfbkgs);
        }
        
        return JSON.serialize(uResults);
    }
    
   }