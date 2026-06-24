@isTest
public class AttachGeneratedDocumentToNotesTest {
    
    @isTest
    public static void attchGenerateTest(){
        
        Booking__c bkg = new Booking__c();
        bkg.Status__c = 'UnProcessed';
        insert bkg;
        
        AttachGeneratedDocumentToNotes.Request req = new AttachGeneratedDocumentToNotes.Request();
        req.fileName = 'Test';
        req.fileUrl = 'Test';
        req.recordId = bkg.Id;
        
        AttachGeneratedDocumentToNotes.downloadAndAttach(new List<AttachGeneratedDocumentToNotes.Request>{req});
    }

}