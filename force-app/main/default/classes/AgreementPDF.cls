public class AgreementPDF {
    
    @AuraEnabled
    public static String agreement(String recordId){
        
        Booking__c bkg = [SELECT Id, Name, Opportunity__r.SalesOrder_Number__c, Project__r.RW_SAP_Company_Code__c, Project__r.Name,
                          Project__r.RW_Project_Code__c, Unit_No__r.TowerName__r.Name, Unit_No__r.TowerName__r.SAP_Plant_Code__c,
                          Unit_No__r.Unit_SAP_Code__c, Project__r.SAPMaterial_Code__c, Date_of_Occupation_Certificate__c
                          FROM Booking__c WHERE Id =: recordId];
        
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type',  'application/json');
        req.setTimeout(120000);
        //req.setEndpoint('https://dev.bluealgo.com/fmp/api/sfdc/add_data');
        //req.setEndpoint('https://afs.bluealgo.com:8082/fmp_new/api/sfdc/add_data');
        //req.setHeader('Authorization', 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJrcmlzaGFudUBwc2dyb3VwLmluIiwiaWF0IjoxNjkzODA4NjM0LCJleHAiOjE2OTM4OTUwMzR9.x5fJA0K4fpe5TlCxmIjaTTOlxJytvHFW165DJzXbvRS9qdVR9NWtXjwaMd4qb-x56BPJpj3z9Q_gHpTBHd4l5A');
        req.setEndpoint(System.Label.Bluealgo_End_Point);
        req.setHeader('Authorization',System.Label.Bluealgo_Auth_Token);
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        //generator.writeStringField('companycode', bkg.Project__r.RW_SAP_Company_Code__c);
        generator.writeStringField('salesordernum', bkg.Opportunity__r.SalesOrder_Number__c);
        //generator.writeStringField('project_name', bkg.Project__r.Name);
        //generator.writeStringField('project_code', bkg.Project__r.RW_Project_Code__c);
        //generator.writeStringField('tower_name', bkg.Unit_No__r.TowerName__r.Name);
        //generator.writeStringField('tower_code', bkg.Unit_No__r.TowerName__r.SAP_Plant_Code__c);
        //generator.writeStringField('booking_Id', bkg.Id);
        //generator.writeStringField('isRTMI', (bkg.Date_of_Occupation_Certificate__c == null ) ? 'No' : 'Yes');
        //generator.writeStringField('plant', bkg.Unit_No__r.Unit_SAP_Code__c);
        //generator.writeStringField('salesorg', bkg.Project__r.SAPMaterial_Code__c);
        generator.writeEndObject();
        String jsonString = generator.getAsString();
        System.debug('jsonString: ' + jsonString);
        req.setBody(jsonString);
        
        if(!Test.isRunningTest()){
            HTTPResponse res = http.send(req);
            System.debug('res '+res);
            System.debug('res!!! getBody '+res.getBody());
            ResponseBody resBody = new ResponseBody();
            resBody = (ResponseBody)JSON.deserialize(res.getBody(), ResponseBody.class);
            System.debug('docurl: ' + resBody.mailjson.body);
            
    
            return resBody.docurl;  
        }
        

        return null;    
    }
    
    public class ResponseBody{
        public Mailjson mailjson;
        public Smsjson smsjson;
        public String serviceErrorMessage;
        public String docurl;
        public Whatsappjson whatsappjson;
    }
    public class Mailjson{
        public List<String> attachment;
        public String subject;
        public String emailto;
        public String body;
    }
    public Class Smsjson{
        public String smsto;
        public String smsbody;
    }
    public Class Whatsappjson{
        public String whatsappto;
        public String whatsappbody;
    }
}