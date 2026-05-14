public class CustomerPortalTDSCtrl {
    @AuraEnabled  
    public static List<ContentDocument> getFiles(String SanctionDocumentId){ 
      
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE Id = :SanctionDocumentId];        
    } 
    
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
       List<TDS__c> lstTDS = [select id,RW_TDS_Certificate_Number__c,RW_TDS_Document_ID__c from TDS__c where  RW_TDS_Document_ID__c = :sdocumentId];
        //system.debug('lstTDS[0]' + loan);
        if(lstTDS!=null & lstTDS.size()>0){
            lstTDS[0].RW_TDS_Document_ID__c = null;
            //system.debug('lstTDS[0]' + loan);
            update lstTDS[0];
        }
        
    } 
    
    
    
    @AuraEnabled
    public static TDS__c getTDSRecord(String TDSId){
        List<TDS__c> tdsRecord = [SELECT Id,Name,RW_Amount__c,RW_TDS_Certificate_Number__c,RW_TDS_Document_ID__c FROM TDS__c WHERE Id= :TDSId ];
        if(tdsRecord != null && tdsRecord.size() >0)
            return tdsRecord[0];
        else
            return null;
    }
    
    @AuraEnabled  
    public static void updateSanctionData(Map<String,String> DocDetails){
        String TDSId= DocDetails.get('tdsId');
        TDS__c sanctionTDSRecord = new TDS__c(Id =TDSId);
        sanctionTDSRecord.RW_TDS_Document_ID__c = DocDetails.get('documentId');
        update sanctionTDSRecord;
    }
}