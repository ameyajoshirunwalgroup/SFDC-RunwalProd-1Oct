public class SavePdfController {
    
    @AuraEnabled
    public static LightningResponse savePDF(String recordId, String vfPageName, String objName,String documentType) {
        LightningResponse response = new LightningResponse();
        if(vfPageName == 'SaleConfirmationSheet_VFP'){
            response=saveBookingFormPdf(recordId,vfPageName,objName,documentType);
        }
        return response;
    }
    
    @AuraEnabled
    public static LightningResponse saveBookingFormPdf(String recordId, String vfPageName, String objName,String documentType) {
        LightningResponse response = new LightningResponse();
        try {
            response.isSuccess = true;
            if (String.isNotBlank(recordId)) {
                Blob pdfContent = getPDFBlob(recordId, vfPageName);
                if(pdfContent != null ){
                    LightningResponse wrap = insertAttachment(recordId, pdfContent, 'SCS PDF', objName,documentType);
                    response.body = wrap.body;
                    response.isSuccess = wrap.isSuccess;
                    
            
                } else {
                    response.isSuccess = false;
                    response.body = 'Error: Unable to generate PDF';
                } 
            } else {
                    response.isSuccess = false;
                    response.body = 'Error: Invalid recordId';
                
            }
        }
        catch (Exception ex) {
            response.isSuccess = false;
            response.body = ex.getMessage();
        }
        return response;
    }
    
    @AuraEnabled
    public static LightningResponse insertAttachment(String recordId, Blob pdfBody, String pdfName, String objName,String documentType) {
        LightningResponse wrap = new LightningResponse();
        String returnMsg = '';
        try {
            wrap.isSuccess = true;
            sObject objRecord = Database.query('SELECT Id, Name FROM ' + objName + ' WHERE Id = :recordId'); 
            if (objRecord != null) {
                String recordName = objRecord.get('Name') != null ? String.valueOf(objRecord.get('Name')) : '';
                Datetime now = Datetime.now();
                String formattedDateTime = now.format('dd/MM/yyyy HH:mm:ss:SSSS');
                ContentVersion objContentVersion = new ContentVersion(Title = recordName+'_'+documentType+ '_Dated(' + formattedDateTime+')', PathOnClient = recordName+'_'+documentType+ + '_Dated(' + formattedDateTime+')'+'.pdf');
                objContentVersion.VersionData = pdfBody;
                insert objContentVersion;
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id].ContentDocumentId;
                wrap.contentDocumentId = conDocId;
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                insert cdl;
                returnMsg = objRecord.get('Name') + '_' + recordName +'_'+documentType+ '_Dated(' + formattedDateTime+')';
            } else {
                returnMsg = 'Error: Record not found';
                wrap.isSuccess = false;
            }
        } catch (Exception ex) {
            wrap.isSuccess = false;
            returnMsg = 'Error: ' + ex.getMessage();
        }
        wrap.body = returnMsg;
        return wrap;
    }

    @AuraEnabled
    public static Blob getPDFBlob(String recordId, String vfPageName) {
        Blob pdfContent = Blob.valueOf('');
        try {
            String vfPageNames = '/apex/' + vfPageName;
            PageReference pdfPage = new PageReference(vfPageNames);
            pdfPage.getParameters().put('id', recordId);
            if (!Test.isRunningTest()) {
                pdfContent = pdfPage.getContent();
            }else{
                pdfContent = Blob.valueOf('Mock PDF content');
            }
        } catch (Exception ex) {
            System.debug('getPDFBlob error body-------------->'+ ex.getMessage());
            System.debug('getPDFBlob error line number-------------->'+ ex.getLineNumber());
        }
        return pdfContent;
    }

    public class LightningResponse{
        @AuraEnabled
        public String body { get; set; }
        @AuraEnabled
        public Boolean isSuccess { get; set; }
        @AuraEnabled
        public String contentDocumentId { get; set; }
    }
}