public class SanctionLetterController 
{
  @AuraEnabled  
    public static List<ContentDocument> getFiles(String SanctionDocumentId){ 
       /* Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        } */   
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :SanctionDocumentId];        
    } 
    
     @AuraEnabled  
     public static List<ContentDocument> getTPAFiles(String TPADocumentId){ 
       /* Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        } */   
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id =:TPADocumentId];        
    } 
    
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
       List<Loan__c> loan = [select id, RW_Sanction_Letter_ID__c,RW_TPA_Letter_Id__c,RW_Sanction_Status__c from Loan__c where  RW_Sanction_Letter_ID__c = :sdocumentId];
        system.debug('Loan[0]' + loan);
        if(loan!=null & loan.size()>0)
        {
            loan[0].RW_Sanction_Letter_ID__c = null;
          //  loan[0].RW_Sanction_Status__c = 'Sanction Pending';
            system.debug('Loan[0]' + loan);
            update loan[0];
        }
        
    } 
    
     @AuraEnabled  
    public static void deleteTPAFiles(String sdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
       List<Loan__c> loan = [select id, RW_Sanction_Letter_ID__c,RW_TPA_Letter_Id__c from Loan__c where  RW_TPA_Letter_Id__c = :sdocumentId];
        if(loan!=null & loan.size()>0)
        {
            loan[0].RW_TPA_Letter_Id__c = null;
            
            update loan[0];
        }
        
    }  
    
    @AuraEnabled
     public static Loan__c getLoanRecord(String loanId)
        {
            List<Loan__c> loanRecord = [SELECT Id, Name,RW_Pari_Passu__c,RW_Sanction_Letter_ID__c,RW_TPA_Letter_Id__c, RW_TPA_Noc_Uploaded__c,RW_NOC_Generated__c, RW_TPA_Case__c,RW_Sanction_Status__c, Home_Loan_Taken_From__c FROM Loan__c WHERE Id= :loanId ];
            if(loanRecord != null && loanRecord.size() >0)
            return loanRecord[0];
            else
            return null;
        }
    
     /* @AuraEnabled
     public static Loan__c getTPAUploadedFile(String loanId)
        {
            List<Loan__c> loanRecord = [SELECT Id, Name, RW_TPA_Letter_Id__c,RW_TPA_Noc_Uploaded__c, RW_TPA_Case__c FROM Loan__c WHERE Id= :loanId ];
            if(loanRecord != null && loanRecord.size() >0)
            return loanRecord[0];
            else
            return null;
        }*/
   
     @AuraEnabled  
    public static void updateSanctionData(Map<String,String> DocDetails)
    {
        String LoanId= DocDetails.get('loanId');
        Loan__c sanctionloanRecord = new Loan__c(Id =LoanId);
        sanctionloanRecord.RW_Sanction_Letter_ID__c = DocDetails.get('documentId');
        try{
            update sanctionloanRecord;
        }catch(Exception e){
			
			throw new AuraHandledException('Error Exception happend'+e.getMessage());    
		}    
  
    }
    
     @AuraEnabled  
    public static void updateTPAData(Map<String,String> DocDetails)
    {
        String LoanId= DocDetails.get('loanId');
        Loan__c tpaloanRecord = new Loan__c(Id =LoanId);
        tpaloanRecord.RW_TPA_Letter_Id__c = DocDetails.get('documentId');
   
        update tpaloanRecord;
  
    }
     
}