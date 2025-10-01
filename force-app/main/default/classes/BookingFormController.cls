public class BookingFormController {
	
    @AuraEnabled
    public static Booking__c getBookingRecord(String bkgId){
        List<Booking__c> bkgRecord = [SELECT Id, Name, Booking_Form_Id__c, Booking_Form_Uploaded__c, Signed_Cost_Sheet_Form_Id__c,
                                      Signed_Cost_Sheet_Uploaded__c, IOM_Document_Id__c, IOM_Document_Uploaded__c, Deviation_Approval_Doc_Id__c,
                                      Deviation_Approval_Doc_Uploaded__c, Token_Payment_Doc_Id__c, Token_Payment_Doc_Uploaded__c
                                      FROM Booking__c WHERE Id= :bkgId ];
        if(bkgRecord != null && bkgRecord.size() >0)
            return bkgRecord[0];
        else
            return null;
    }
    
    @AuraEnabled  
    public static void updateBookingFormData(Map<String,String> DocDetails){
        System.debug('DocDetails: ' + DocDetails);
        System.debug('DocDetails.get(documentId): ' + DocDetails.get('documentId'));
        String bkgId= DocDetails.get('bookingId');
        Booking__c bkgRecord = new Booking__c(Id =bkgId);
        if(DocDetails.get('fileType') == 'Booking Form'){
            bkgRecord.Booking_Form_Id__c = DocDetails.get('documentId');
        }else if(DocDetails.get('fileType') == 'Signed Cost Sheet'){
            bkgRecord.Signed_Cost_Sheet_Form_Id__c = DocDetails.get('documentId');  
        }else if(DocDetails.get('fileType') == 'IOM'){
            bkgRecord.IOM_Document_Id__c = DocDetails.get('documentId');  
        }else if(DocDetails.get('fileType') == 'Deviation Approvals'){
            bkgRecord.Deviation_Approval_Doc_Id__c = DocDetails.get('documentId');  
        }else if(DocDetails.get('fileType') == 'Token Payment Details'){
            bkgRecord.Token_Payment_Doc_Id__c = DocDetails.get('documentId');  
        }
        try{
            BookingTriggerHandler.byPass = true;
            update bkgRecord;
            BookingTriggerHandler.byPass = false;
        }catch(Exception e){
			throw new AuraHandledException('Error Exception happend'+e.getMessage());    
		}    
    }
    
    @AuraEnabled  
    public static Map<Id,ContentDocument> getFiles(List<String> docIds){ 
        System.debug('docIds: ' + docIds);
        Map<Id,ContentDocument> docMap = new Map<Id,ContentDocument>([SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :docIds]);
        //return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :docIds];  
        return docMap;
    }
    
    @AuraEnabled  
    public static void deleteFiles(String sdocumentId, String documentName, String BookingId){ 
             
        List<Booking__c> bkgRecord = [SELECT Id, Name, Status__c, Booking_Form_Id__c, Booking_Form_Uploaded__c FROM Booking__c WHERE Id= :BookingId ];
       
        System.debug('Profile Id: ' + UserInfo.getProfileId());
        System.debug('Profile Id: ' + UserInfo.getName());
        if(bkgRecord[0].Status__c == 'Booking Confirmed' && (UserInfo.getName() == 'Lucy Roychoudhury' || UserInfo.getProfileId() == System.label.System_Administrator_Profile_Id)){
            delFile(bkgRecord[0], sdocumentId, documentName);
        }else if(bkgRecord[0].Status__c != 'Booking Confirmed'){
            delFile(bkgRecord[0], sdocumentId, documentName);
        }else{
            throw new AuraHandledException('You do not have the delete permission');
        }
    } 
           
    public static void delFile(Booking__c bkgRecord, String docId, String documentName){
        delete [SELECT Id from ContentDocument WHERE Id = :docId];
        system.debug('bkgRecord' + bkgRecord);
        if(bkgRecord!=null){
            if(documentName == 'BookingForm'){
                bkgRecord.Booking_Form_Id__c = null;
                bkgRecord.Booking_Form_Uploaded__c = false;
            }else if(documentName == 'SignedCostSheet'){
                bkgRecord.Signed_Cost_Sheet_Form_Id__c = null;
                bkgRecord.Signed_Cost_Sheet_Uploaded__c = false;
            }else if(documentName == 'iom'){
                bkgRecord.IOM_Document_Id__c = null;
                bkgRecord.IOM_Document_Uploaded__c = false;
            }else if(documentName == 'DeviationApprovals'){
                bkgRecord.Deviation_Approval_Doc_Id__c = null;
                bkgRecord.Deviation_Approval_Doc_Uploaded__c = false;
            }else if(documentName == 'TokenPaymentDetails'){
                bkgRecord.Token_Payment_Doc_Id__c = null;
                bkgRecord.Token_Payment_Doc_Uploaded__c = false;
            }
            system.debug('bkgRecord' + bkgRecord);
            update bkgRecord;
        }
    }
    
    /*@AuraEnabled  
    public static void updateBkgFrmBox(String bkgId, String checkBoxValue){
        Booking__c bkgRecord = new Booking__c(Id =bkgId);
        bkgRecord.Booking_Form_Uploaded__c = Boolean.valueOf(checkBoxValue);
        update bkgRecord;
    }*/
    
    @AuraEnabled  
    public static void updateCheckBox(String bkgId, String checkBoxValue, String fileType){
        Booking__c bkgRecord = new Booking__c(Id =bkgId);
        if(fileType == 'Booking Form'){
            bkgRecord.Booking_Form_Uploaded__c = Boolean.valueOf(checkBoxValue);
        }else if(fileType == 'Signed Cost Sheet'){
            bkgRecord.Signed_Cost_Sheet_Uploaded__c = Boolean.valueOf(checkBoxValue);
        }else if(fileType == 'IOM'){
            bkgRecord.IOM_Document_Uploaded__c = Boolean.valueOf(checkBoxValue);
        }else if(fileType == 'Deviation Approval'){
            bkgRecord.Deviation_Approval_Doc_Uploaded__c = Boolean.valueOf(checkBoxValue);
        }else if(fileType == 'Token Payment'){
            bkgRecord.Token_Payment_Doc_Uploaded__c = Boolean.valueOf(checkBoxValue);
        }
        
        update bkgRecord;
    }
    
}