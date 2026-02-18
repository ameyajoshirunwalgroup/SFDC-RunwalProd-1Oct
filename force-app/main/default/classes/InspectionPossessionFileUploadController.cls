public class InspectionPossessionFileUploadController {
 @AuraEnabled  
    public static List<ContentDocument> getFiles(String InspPossDocumentId){ 
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :InspPossDocumentId];        
    } 
    
        
    @AuraEnabled  
    public static void deleteFiles(String IPdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :IPdocumentId]; 
        
        List<InspectionAndPossession__c> InspPoss = [select Id, Name,RW_InspectionPossession_File_ID__c FROM InspectionAndPossession__c where  RW_InspectionPossession_File_ID__c = :IPdocumentId];
        if(InspPoss!=null & InspPoss.size()>0){
            InspPoss[0].RW_InspectionPossession_File_ID__c = null;
            update InspPoss[0];
        }
        
    } 
        
    
    @AuraEnabled
    public static InspectionAndPossession__c getInspPossRecord(String InspPossId){
        List<InspectionAndPossession__c> InspPossRecord = [SELECT Id, Name,RW_InspectionPossession_File_ID__c FROM InspectionAndPossession__c WHERE Id= :InspPossId ];
        if(InspPossRecord != null && InspPossRecord.size() >0)
            return InspPossRecord[0];
        else
            return null;
    }
    
    
    
     @AuraEnabled  
    public static void updateInspPossData(Map<String,String> DocDetails){
        String InspPossId= DocDetails.get('InspPossId');
        InspectionAndPossession__c InspPossRecord = new InspectionAndPossession__c(Id =InspPossId);
        InspPossRecord.RW_InspectionPossession_File_ID__c = DocDetails.get('documentId');
   
        update InspPossRecord;
  
    }
    
   
}