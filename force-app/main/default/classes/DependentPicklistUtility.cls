public without sharing class DependentPicklistUtility{

    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName){
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if(objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if(!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for(Schema.PicklistEntry ple : contrEntries){
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for(PicklistEntryWrapper plew : depEntries){
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for(Integer i = 0; i < validForBits.length(); i++){
                String bit = validForBits.mid(i, 1);
                if (bit == '1'){
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val){
        String bits = '';
        while(val > 0){
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    @AuraEnabled  
    public static void insertDocumentData(Map<String,String> DocDetails){
        /*String eoiId= DocDetails.get('eoiRecId');
        RW_EOI__c eoiRecord = new RW_EOI__c(Id =eoiId);
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        eoiRecord.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        eoiRecord.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        eoiRecord.RW_Primary_PAN_Details__c =DocDetails.get('documentNumber');
        
        update eoiRecord;
        */
        
        Document_Details__c Details = new Document_Details__c();
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        Details.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        Details.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        Details.Opportunity__c = DocDetails.get('oppRecId');
        Details.EOI__c = DocDetails.get('eoiRecId');
        Details.RW_Document_Type__c=DocDetails.get('documentType');
        Details.RW_Document_ID__c = DocDetails.get('documentId');
        
        insert Details;
    }
    
    
     @AuraEnabled  
    public static void insertOtherDocumentData(Map<String,String> DocDetails){
       /* String eoiId= DocDetails.get('eoiRecId');
        RW_EOI__c eoiRecord = new RW_EOI__c(Id =eoiId);
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        eoiRecord.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        eoiRecord.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        eoiRecord.RW_Document_Proof__c=DocDetails.get('documentType');
        eoiRecord.RW_Document_Number__c = DocDetails.get('documentNumber');
        
        update eoiRecord; */
        
        
        Document_Details__c Details = new Document_Details__c();
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        Details.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        Details.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        Details.Opportunity__c = DocDetails.get('oppRecId');
        Details.EOI__c = DocDetails.get('eoiRecId');
        Details.RW_Document_Type__c=DocDetails.get('documentType');
        Details.RW_Document_ID__c = DocDetails.get('documentId');
        
        insert Details;
        
    }
    
   /* 
     @AuraEnabled  
    public static void insertDocumentDetails(Map<String,String> DocDetails)
    {
       List<ContentVersion> contver = [Select id,ContentLocation,Title,PathOnClient,Guest_Record_fileupload__c,ContentDocumentId from ContentVersion where Guest_Record_fileupload__c=: DocDetails.get('encrytedToken')];
       System.debug('**result'+contver);
           if(contver.size() >0)
       {
            System.debug('**inside');
            ContentVersion ContVerFile = new ContentVersion();
            //ContVerFile.VersionData = Blob.valueOf('string');
            ContVerFile.Title = contver[0].Title; 
            ContVerFile.ContentLocation= contver[0].ContentLocation;
            ContVerFile.PathOnClient=contver[0].PathOnClient;
            insert ContVerFile;
           System.debug('**success');
       }
           
		System.debug('**inside1');
      
        //Utility.associateFileToRecord(DocDetails.get('encrytedToken'));
        
        Document_Details__c Details = new Document_Details__c();
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        Details.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        Details.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        Details.Opportunity__c = DocDetails.get('oppRecId');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        Details.RW_Document_Type__c=DocDetails.get('documentType');
        Details.RW_Document_ID__c = DocDetails.get('documentId');
        
        insert Details;   
    }
    */
     @AuraEnabled  
    public static List<KYCWrapper> getKYCFiles(string recordId,String eoiId){ 
        // TO avoid following exception 
        // System.QueryException: Implementation restriction: ContentDocumentLink requires
        // a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or 
        // multiple Id's using the IN operator.
        // We have to add sigle record id into set or list to make SOQL query call
        List<KYCWrapper> kycWrap =new List<KYCWrapper>();
        Map<Id,Contentversion> ContentData = new Map<Id,Contentversion>();
        Map<Id,Document_Details__c> DocData = new Map<Id,Document_Details__c>();
        Map<Id,ContentDocument> ContentDocData = new Map<Id,ContentDocument>();
        Set<Id> recordIds=new Set<Id>{eoiId};
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds ];  
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        //List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
        List<Contentversion> contVer = [Select Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,IsLatest from ContentVersion where ContentDocumentId in :documentIds and IsLatest = true];
        for(Contentversion contVersion :contVer){
            ContentData.put(contVersion.Id, contVersion);
        }
        
        
        List<Document_Details__c> docDetails = [Select Id,RW_Type_Of_Applicant__c,RW_Document_Type__c,RW_Residential_Status__c,Opportunity__c,RW_Document_ID__c from Document_Details__c where RW_Document_ID__c in :documentIds and EOI__c =:eoiId];
        for(Document_Details__c details :docDetails){
            DocData.put(details.Id, details);
        }
        
       /* List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        for(ContentDocument contDocument :contDoc)
        {
        	ContentDocData.put(contDocument.Id,contDoc);
        } */ 
        
        for(Id contVersionId : ContentData.keySet()){
            for(Id docDataId : DocData.keySet()){
                if(DocData.get(docDataId).RW_Document_ID__c == ContentData.get(contVersionId).ContentDocumentId){
            KYCWrapper kycWrapData= new KYCWrapper();
            kycWrapData.documentType=DocData.get(docDataId).RW_Document_Type__c;
            kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileType = ContentData.get(contVersionId).ContentDocument.FileType;
            kycWrapData.Id = ContentData.get(contVersionId).ContentDocumentId;
            kycWrap.add(kycWrapData);
            
        }
            }
        }
       // system.assert(false);
        return kycWrap;
    } 
    
    
    public static String base64ToBits(String validFor){
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for(Integer i = 0; i < validFor.length(); i++){
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        return validForBits;
    }
    
    private static final String base64Chars = '' +'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +'abcdefghijklmnopqrstuvwxyz' +'0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs){
        return (List<PicklistEntryWrapper>) JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    /*
     @AuraEnabled  
    public static List<KYCWrapper> getFileData(string recordId){ 
        system.debug('**id'+recordId);
        // TO avoid following exception 
        // System.QueryException: Implementation restriction: ContentDocumentLink requires
        // a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or 
        // multiple Id's using the IN operator.
        // We have to add sigle record id into set or list to make SOQL query call
        List<KYCWrapper> kycWrap =new List<KYCWrapper>();
        Map<Id,Contentversion> ContentData = new Map<Id,Contentversion>();
        Map<Id,Document_Details__c> DocData = new Map<Id,Document_Details__c>();
        Map<Id,ContentDocument> ContentDocData = new Map<Id,ContentDocument>();
        Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds ];  
        System.debug('*size*'+cdl.size());
        for(ContentDocumentLink cdLink:cdl)
        {  
            System.debug('****'+cdLink);
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        //List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
        List<Contentversion> contVer = [Select Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,IsLatest from ContentVersion where ContentDocumentId in :documentIds and IsLatest = true];
        for(Contentversion contVersion :contVer)
        {
            System.debug('**inside contVersion**'+contVersion);
            ContentData.put(contVersion.Id, contVersion);
        }
        
        
        List<Document_Details__c> docDetails = [Select Id,RW_Type_Of_Applicant__c,RW_Document_Type__c,RW_Residential_Status__c,Opportunity__c,RW_Document_ID__c from Document_Details__c where RW_Document_ID__c in :documentIds];
        for(Document_Details__c details :docDetails)
        {
            DocData.put(details.Id, details);
        }
        
        List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        for(ContentDocument contDocument :contDoc)
        {
        	ContentDocData.put(contDocument.Id,contDoc);
        } 
        
        for(Id contVersionId : ContentData.keySet())
        {
            for(Id docDataId : DocData.keySet())
            {
                if(DocData.get(docDataId).RW_Document_ID__c == ContentData.get(contVersionId).ContentDocumentId)
                {
            KYCWrapper kycWrapData= new KYCWrapper();
            kycWrapData.applicantType = DocData.get(docDataId).RW_Type_Of_Applicant__c;
            kycWrapData.ResidentialStatus = DocData.get(docDataId).RW_Residential_Status__c;
            kycWrapData.documentType=DocData.get(docDataId).RW_Document_Type__c;
            kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileType = ContentData.get(contVersionId).ContentDocument.FileType;
            kycWrapData.Id = ContentData.get(contVersionId).ContentDocumentId;
            kycWrap.add(kycWrapData);
            
        }
            }
        }
       // system.assert(false);
        return kycWrap;
    } 
    
    
     @AuraEnabled  
    public static List<KYCWrapper> getFilesData(string recordId){ 
        system.debug('**id'+recordId);
         
        //List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
         List<KYCWrapper> kycWrap =new List<KYCWrapper>();
        Map<Id,Contentversion> ContentData = new Map<Id,Contentversion>();
        Map<Id,Document_Details__c> DocData = new Map<Id,Document_Details__c>();
        List<Contentversion> contVer = [Select Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,IsLatest from ContentVersion where IsLatest = true];
        for(Contentversion contVersion :contVer)
        {
            system.debug('inside'+contVersion);
            ContentData.put(contVersion.Id, contVersion);
        }
        
        
        List<Document_Details__c> docDetails = [Select Id,RW_Type_Of_Applicant__c,RW_Document_Type__c,RW_Residential_Status__c,Opportunity__c,RW_Document_ID__c from Document_Details__c ];
        for(Document_Details__c details :docDetails)
        {
            system.debug('inside 1'+details);
            DocData.put(details.Id, details);
        }
        
        List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        for(ContentDocument contDocument :contDoc)
        {
        	ContentDocData.put(contDocument.Id,contDoc);
        } 
        
        for(Id contVersionId : ContentData.keySet())
        {
            for(Id docDataId : DocData.keySet())
            {
                if(DocData.get(docDataId).RW_Document_ID__c == ContentData.get(contVersionId).ContentDocumentId)
                {
                    system.debug('inside 2'+DocData.get(docDataId));
            KYCWrapper kycWrapData= new KYCWrapper();
            kycWrapData.applicantType = DocData.get(docDataId).RW_Type_Of_Applicant__c;
            kycWrapData.ResidentialStatus = DocData.get(docDataId).RW_Residential_Status__c;
            kycWrapData.documentType=DocData.get(docDataId).RW_Document_Type__c;
            //kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
            kycWrapData.fileType = ContentData.get(contVersionId).ContentDocument.FileType;
            kycWrapData.Id = ContentData.get(contVersionId).ContentDocumentId;
            kycWrap.add(kycWrapData);
            
        }
            }
        }
        //system.assert(false);
        return kycWrap;
    } 
*/
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    }  
    
    public class PicklistEntryWrapper{
        public String label {get;set;}
        public String validFor {get;set;}
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getPicklistValuesForFields(String objectName,List<String> fieldNames){
        Map<String,List<String>> picklistValues = new Map<String,List<String>>();
        for(String fieldName : fieldNames){
            picklistValues.put(fieldName,Utility.getPicklistValues(objectName,fieldName));
        }
        Return picklistValues;
    }
}