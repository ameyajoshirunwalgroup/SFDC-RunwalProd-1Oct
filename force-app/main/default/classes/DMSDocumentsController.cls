public class DMSDocumentsController {
    
    
   @AuraEnabled
   public static Map<String,List<String>> searchDocs(String bkgId){
       
       List<Booking__c> bkg = [SELECT Id, Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Opportunity__r.Name,
                          Project__r.RW_SAP_Company_Code__c, Unit_No__r.RW_Param4__c, Unit_No__r.RW_Param2__c,Project__r.Name,
                          Primary_Applicant_Name__c
                          FROM Booking__c WHERE Id =: bkgId LIMIT 1];
       Map<String, DMS_Projects_Map__c> proMap = DMS_Projects_Map__c.getall();
       
       HttpRequest request = new HttpRequest();
       HttpResponse response = new HttpResponse();
       Http http = new Http();
       
       JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('userCredentials');
        generator.writeStartObject();
        generator.writeStringField('access_key', System.Label.DMS_Access_Key);
        generator.writeEndObject();
        generator.writeFieldName('metaDeta');
        generator.writeStartObject();
        generator.writeStringField('deal_Room', 'RUNWAL RESIDENCY');
        generator.writeStringField('im_Name', 'CRM');
       if(proMap.get(bkg[0].Project__r.Name) != null){
           if(proMap.get(bkg[0].Project__r.Name).Project_Category__c != null){
               generator.writeStringField('category_Name', proMap.get(bkg[0].Project__r.Name).Project_Category__c);
               
           }
       }
        generator.writeFieldName('imfName');
        generator.writeStartArray();
        generator.writeString('SALES ORDER NUMBER');
        generator.writeEndArray();
        generator.writeEndObject();
        generator.writeFieldName('masterDetails');
        generator.writeStartArray();
        generator.writeStartObject();
        generator.writeStringField('SALES ORDER NUMBER', bkg[0].Opportunity__r.SalesOrder_Number__c);
        generator.writeEndObject();
        generator.writeEndArray();
        String jsonString = generator.getAsString();
        System.debug('jsonString: ' + jsonString);
       
       
       request.setEndpoint(System.Label.DMS_Search_End_Point);
       request.setHeader('Content-Type', 'application/json');
       request.setMethod('GET');
       request.setTimeout(120000);
       //request.setBody(JSON.Serialize(jsonString));
       request.setBody(jsonString);
       System.debug('request: ' + request);
       response = http.send(request);
       Map<String, List<String>> resMap = new Map<String, List<String>>();
       if(response.getStatusCode() == 200){
           List<SearchResponseData> resDetails = new List<SearchResponseData>();
           System.debug('Response success: ' + response);
           System.debug('Response body: ' + response.getBody());
           String resBody = response.getBody();
           resDetails = (List<SearchResponseData>)JSON.deserialize(resBody, List<SearchResponseData>.class);
           for(SearchDocumentDetails doc : resDetails[0].uploadedDocuments.document_details){
               if(resDetails[0].error == 'Y'){
                   resMap.put('Error', new List<String>{resDetails[0].error_msg, resDetails[0].error_msg});
               }else{
                   List<String> docNameSplit = doc.docSetName.split('=');
                   resMap.put(docNameSplit[1], new List<String>{doc.document_name, doc.doc_preview_uri, doc.doc_download_uri});
               }
               
           }
           return resMap;
       }else{
           System.debug('Response error: ' + response);
           throw new AuraHandledException(String.valueof(response));
       }
    }
    
    @AuraEnabled
    public static String sendDocsToDms(Map<String, String> docIdVsBkgId){
        
        
        Map<ContentVersion,Booking__c> fileVsBkg = new Map<ContentVersion,Booking__c>();
        List<Booking__c> bkg = [SELECT Id, Name, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Opportunity__r.Name,
                          Project__r.RW_SAP_Company_Code__c, Unit_No__r.RW_Param4__c, Unit_No__r.RW_Param2__c,Project__r.Name,
                          Primary_Applicant_Name__c
                          FROM Booking__c WHERE Id =: docIdVsBkgId.get('bookingId')];
        List<ContentVersion> files = [SELECT Id, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: docIdVsBkgId.get('DocId')];
        
        
        String fileData = EncodingUtil.base64Encode(files[0].VersionData);
        
        String customerNumber = String.valueOf(Integer.valueOf(bkg[0].Opportunity__r.SAP_Customer_Number__c));
        Map<String, DMS_Projects_Map__c> proMap = DMS_Projects_Map__c.getall();
        
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('userCredentials');
        generator.writeStartObject();
        generator.writeStringField('access_key', System.Label.DMS_Access_Key);
        generator.writeEndObject();
        generator.writeFieldName('metaDeta');
        generator.writeStartObject();
        generator.writeStringField('deal_Room', 'RUNWAL RESIDENCY');
        generator.writeStringField('category_Name', proMap.get(bkg[0].Project__r.Name).Project_Category__c);
        generator.writeStringField('im_Name', 'CRM');
        generator.writeStringField('imfName','SALES ORDER NUMBER');
        generator.writeEndObject();
        generator.writeFieldName('masterDetails');
        generator.writeStartArray();
        generator.writeStartObject();
        generator.writeStringField('SALES ORDER NUMBER', bkg[0].Opportunity__r.SalesOrder_Number__c);
        generator.writeStringField('CUSTOMER CODE', customerNumber);
        generator.writeStringField('UNIT NO', bkg[0].Unit_No__r.RW_Param4__c);
        generator.writeStringField('CUSTOMER NAME', bkg[0].Primary_Applicant_Name__c);
        generator.writeStringField('COMPANY CODE', bkg[0].Project__r.RW_SAP_Company_Code__c);
        generator.writeStringField('WING/TOWER', bkg[0].Unit_No__r.RW_Param2__c);
        generator.writeStringField('PROJECT NAME', proMap.get(bkg[0].Project__r.Name).Project_Keyword__c);
        generator.writeFieldName('uploadedDocuments');
        generator.writeStartArray();
        generator.writeStartObject();
        generator.writeStringField('docSetName', 'CRM Documents Type>'+docIdVsBkgId.get('documentType'));
        generator.writeStringField('third_party_file_content', fileData);
        generator.writeStringField('third_party_file_name', files[0].Title +'.pdf');
        generator.writeEndObject();
        generator.writeEndArray();
        generator.writeEndObject();
        String jsonString = generator.getAsString();
        System.debug('jsonString: ' + jsonString);
        request.setEndpoint(System.Label.DMS_Upload_End_Point);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setTimeout(120000);
        //request.setBody(JSON.Serialize(jsonString));
        request.setBody(jsonString);
        System.debug('request: ' + request);
        response = http.send(request);
        String docLink;
        String docType;
        if(response.getStatusCode() == 200){
            List<ResponseData> resDetails = new List<ResponseData>();
            System.debug('Response body: ' + response.getBody());
            String resBody = response.getBody();
            resDetails = (List<ResponseData>)JSON.deserialize(resBody, List<ResponseData>.class);
            docLink = resDetails[0].uploadedDocuments.document_details[0].doc_preview_uri;
            docType = resDetails[0].uploadedDocuments.document_details[0].docSetName;
        } 
        return docLink;
    }
    
    
    public class ResponseData{
        public string error;
        public string error_msg;
        public string status;
        public string dealRoom_id;
        public string im_id;
        public string imv_id;
        public string auto_inc_no;
        public string imfName;
        public string ivalue_status;
        public Map<String,String> master_value_details;
        public UploadedDocuments uploadedDocuments;
    }
    
    public class UploadedDocuments{
        public string error;
        public string error_msg;
        public string status;
        public string dealRoom_id;
        public string category_id;
        public List<DocumentDetails> document_details;
    }
    
    public class DocumentDetails{
        public string error;
        public string error_msg;
        public string primary_doc_id;
        public string doc_id;
        public string docSetName;
        public string doc_preview_uri;
        public string doc_download_uri;
    }
    
    public class SearchResponseData{
        public string error;
        public string error_msg;
        public string status;
        public string dealRoom_id;
        public string im_id;
        public string imv_id;
        public string auto_inc_no;
        public string third_party_id;
        public List<string> imfName;
        public string ivalue_status;
        public Map<String,String> master_value_details;
        public SearchUploadedDocuments uploadedDocuments;
    }
    
    public class SearchUploadedDocuments{
        public string error;
        public string error_msg;
        public string status;
        public string dealRoom_id;
        public List<SearchDocumentDetails> document_details;
    }
    
    public class SearchDocumentDetails{
        public string error;
        public string error_msg;
        public string primary_doc_id;
        public string doc_id;
        public string document_name;
        public string docSetName;
        public string doc_preview_uri;
        public string doc_download_uri;
    }
   
}