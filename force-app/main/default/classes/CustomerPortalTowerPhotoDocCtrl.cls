public class CustomerPortalTowerPhotoDocCtrl {
    @AuraEnabled  
    public static List<ContentDocument> getFiles(String SanctionDocumentId){ 
        List<ContentDocument> cd = new List<ContentDocument>();
        List<ContentVersion> cv =[SELECT Id, ContentDocumentId FROM ContentVersion where Id = :SanctionDocumentId];
        //return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :SanctionDocumentId];  
        if(cv != null && cv.size() >0)
            return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :cv[0].ContentDocumentId];   
        else
            return cd;
    } 
    
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId){ 
		ContentVersion cv =[SELECT Id, ContentDocumentId FROM ContentVersion where ContentDocumentId = :sdocumentId];
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
       List<RW_Tower_Construction_Update__c> lstTower = [select id,RW_Tower_Construction_Photo_ID__c from RW_Tower_Construction_Update__c where  RW_Tower_Construction_Photo_ID__c = :cv.Id];
        
        if(lstTower!=null &  lstTower.size()>0){
            lstTower[0].RW_Tower_Construction_Photo_ID__c = null;
            update lstTower[0];
        }
        
    } 
    
    
    
    @AuraEnabled
    public static RW_Tower_Construction_Update__c getTCURecord(String TCUId){
        List<RW_Tower_Construction_Update__c> tcuRecord = [SELECT Id,Name,RW_Tower_Construction_Photo_ID__c FROM RW_Tower_Construction_Update__c WHERE Id= :TCUId ];
        if(tcuRecord != null && tcuRecord.size() >0)
            return tcuRecord[0];
        else
            return null;
    }
    
     @AuraEnabled  
    public static String updateSanctionData(Map<String,String> DocDetails){
        String TCUId= DocDetails.get('tcuId');
        ContentVersion cv =[SELECT Id,ContentDocumentId FROM ContentVersion where ContentDocumentId = :DocDetails.get('documentId') and Islatest=true];
        RW_Tower_Construction_Update__c sanctionTCURecord = new RW_Tower_Construction_Update__c(Id =TCUId);
        //sanctionTCURecord.RW_Tower_Construction_Photo_ID__c = DocDetails.get('documentId');
        //
        sanctionTCURecord.RW_Tower_Construction_Photo_ID__c = cv.Id;
   
        update sanctionTCURecord;
        return cv.Id;
    }
    
}