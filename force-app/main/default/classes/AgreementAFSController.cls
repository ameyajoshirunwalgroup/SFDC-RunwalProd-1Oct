public class AgreementAFSController{
    @AuraEnabled  
    public static List<ContentDocument> getAgreementFiles(String agreementdocumentId){ 
        
      /*  Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }    
        return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :documentIds]; */
        
        return [SELECT Id,Title,FileType FROM ContentDocument WHERE Id = :agreementdocumentId];        
    } 
  
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId){ 
        delete [SELECT Id from ContentDocument WHERE Id = :sdocumentId]; 
        
         List<Booking__c> lstbooking = [select id,RW_Signed_Agreement_Document_Id__c from Booking__c where  RW_Signed_Agreement_Document_Id__c = :sdocumentId];
        //system.debug('lstTDS[0]' + loan);
        if(lstbooking!=null & lstbooking.size()>0){
            lstbooking[0].RW_Signed_Agreement_Document_Id__c = null;
            //system.debug('lstTDS[0]' + loan);
            update lstbooking[0];
        }
    } 
    
    @AuraEnabled  
    public static void updateAgreementData(Map<String,String> DocDetails){
        String BookingId= DocDetails.get('bookingId');
        Booking__c booking = new Booking__c(Id =BookingId);
        booking.RW_Signed_Agreement_Document_Id__c =DocDetails.get('documentId');
        update booking;
    }
    
     @AuraEnabled
     public static Booking__c getBookingRecord(String bookingId){
         List<Booking__c> bookingRec = [SELECT Id,Name,RW_Signed_Agreement_Document_Id__c FROM Booking__c WHERE Id= :bookingId ];
         if(bookingRec != null && bookingRec.size() >0)
             return bookingRec[0];
         else
             return null;
     }
    
  /*  public static void sendEmails(List<APF__c> apf)
    {
        set<id> projectId = new set<id>();
        for(APF__c apfid :apf)
        {
            projectId.add(apfid.RW_Project__c);
        }
        
        List<RW_Project__c> projectList = [select id, name (select id, Sales_Manager__c, Sales_Site_Head__c from Booking__c) from RW_Project__c]
    }*/
    
}