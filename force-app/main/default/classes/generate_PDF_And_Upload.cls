public class generate_PDF_And_Upload {
    public static void generateAndUpload(Id recordId) {
        
        PageReference pdfPage = Page.Generate_BookingApplication_PDF;
        pdfPage.getParameters().put('id', recordId);
        Blob pdfBlob = pdfPage.getContentAsPDF();
		system.debug('pdfBlob : '+pdfBlob);
        
        
        
        string encodedBlob2 = EncodingUtil.base64Encode(pdfBlob);
        
        
        Blob concatenatedBlob = EncodingUtil.base64Decode(encodedBlob2);
        System.debug('concatinate blob is here ===> '+ concatenatedBlob);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Runwal Booking Application PDF';
        cv.PathOnClient = 'Generate_BookingApplication_PDF.pdf';
        cv.VersionData = concatenatedBlob;
        cv.IsMajorVersion = true;
        insert cv;

        
        Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }

}