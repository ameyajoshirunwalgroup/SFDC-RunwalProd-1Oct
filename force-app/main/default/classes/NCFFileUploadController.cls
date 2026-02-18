public class NCFFileUploadController {
	@AuraEnabled  
    public static List<ContentDocument> getFiles(String ncfdocumentId){ 
        List<ContentDocument> cd = new List<ContentDocument>();
      	List<ContentVersion> cv =[SELECT Id,ContentDocumentId FROM ContentVersion where Id = :ncfdocumentId];
        //return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :SanctionDocumentId];  
        if(cv != null && cv.size() >0)
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE Id = :cv[0].ContentDocumentId];   
        else
        return cd;
    } 
    
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId){ 
		ContentVersion cv =[SELECT Id,ContentDocumentId FROM ContentVersion where ContentDocumentId = :sdocumentId];
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
       List<Name_Confirmation_Form__c> lstTower = [select id,NCF_Document_Id__c from Name_Confirmation_Form__c where  NCF_Document_Id__c = :cv.Id];
        
        if(lstTower!=null &  lstTower.size()>0){
            lstTower[0].NCF_Document_Id__c = null;
            update lstTower[0];
        }
    } 
    
    
    
    @AuraEnabled
    public static Name_Confirmation_Form__c getNCFRecord(String ncfId){
        List<Name_Confirmation_Form__c> ncfRecord = [SELECT Id,Name,NCF_Document_Id__c FROM Name_Confirmation_Form__c WHERE Id= :ncfId ];
        if(ncfRecord != null && ncfRecord.size() >0)
            return ncfRecord[0];
        else
            return null;
    }
    
    @AuraEnabled  
    public static String updatencfData(Map<String,String> DocDetails){
        String ncfId= DocDetails.get('ncfId');
        ContentVersion cv =[SELECT Id,ContentDocumentId FROM ContentVersion where ContentDocumentId = :DocDetails.get('documentId') and Islatest=true];
        system.debug('*cv*'+cv);
        Name_Confirmation_Form__c ncfRecord = new Name_Confirmation_Form__c(Id =ncfId);
        //sanctionTCURecord.RW_Tower_Construction_Photo_ID__c = DocDetails.get('documentId');
        //
        ncfRecord.NCF_Document_Id__c = cv.Id;
        
        update ncfRecord;
        return cv.Id;
        
    }
    

}