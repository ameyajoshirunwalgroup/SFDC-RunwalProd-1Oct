public class ProjectBrochureUploadController {
 @AuraEnabled  
    public static List<ContentDocument> getFiles(String BrochureDocumentId){ 
       /* Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        } */   
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE Id = :BrochureDocumentId];        
    } 
    
    
    @AuraEnabled  
    public static void deleteFiles(String bdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :bdocumentId]; 
        
        List<Project__c> project = [select id,RW_Project_Brochure_ID__c from Project__c where  RW_Project_Brochure_ID__c = :bdocumentId];
        if(project!=null & project.size()>0){
            project[0].RW_Project_Brochure_ID__c = null;
            project[0].RW_Project_Brochure_PublicUrl__c = null;
            
            update project[0];
        }
        
    } 
    
  
    
    @AuraEnabled
    public static Project__c getProjectRecord(String projectId){
        List<Project__c> projectRecord = [SELECT Id,Name,RW_Project_Brochure_ID__c FROM Project__c WHERE Id= :projectId ];
        if(projectRecord != null && projectRecord.size() >0)
            return projectRecord[0];
        else
            return null;
    }
    
    
   
    @AuraEnabled  
    public static void updateBrochureData(Map<String,String> DocDetails){
        String projectId= DocDetails.get('projectId');
        Project__c brochureProjectRecord = new Project__c(Id =projectId);
        brochureProjectRecord.RW_Project_Brochure_ID__c = DocDetails.get('documentId');
        
        ContentDocumentLink contDoc = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where ContentDocumentId =: DocDetails.get('documentId') AND LinkedEntityId =: DocDetails.get('projectId')]; 
        ContentVersion contVer = [select Id,Title from contentversion where contentdocumentid = :contDoc.ContentDocumentId];
        ContentDistribution cd = new ContentDistribution();
        cd.Name = contVer.Title;
        cd.ContentVersionId = contVer.Id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        ContentDistribution contDis = [select Id, FirstViewDate,ContentVersionId, ContentDocumentId,LastViewDate,DistributionPublicUrl, ContentDownloadUrl,PdfDownloadUrl FROM ContentDistribution Where Id =: cd.Id];
        brochureProjectRecord.RW_Project_Brochure_PublicUrl__c =  contDis.DistributionPublicUrl;
        
        update brochureProjectRecord;
        
        
        
    }
    
    
}