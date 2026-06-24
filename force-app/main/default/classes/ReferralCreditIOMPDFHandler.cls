// public class ReferralCreditIOMPDFHandler {

//     @future(callout=true)
//     public static void generateIOM(Set<Id> referralIds){
//         List<Referral_Credits__c> refList = [
//             SELECT Id, Booking__c
//             FROM Referral_Credits__c
//             WHERE Id IN :referralIds
//         ];

//         List<ContentVersion> cvList = new List<ContentVersion>();
//         Map<Id, Id> refToContentDoc = new Map<Id, Id>();

//         for(Referral_Credits__c rc : refList){

//             PageReference pdfPage = Page.ReferralIomPage;
//             pdfPage.getParameters().put('id', rc.Booking__c);

//             Blob pdfBlob = pdfPage.getContentAsPDF();

//             // String base64 = EncodingUtil.base64Encode(pdfPage.getContentAsPDF());
//             // String pdfBase64Content = EncodingUtil.urlEncode(base64, 'UTF-8');

//             ContentVersion cv = new ContentVersion();
//             cv.Title = 'Referral IOM';
//             cv.PathOnClient = 'ReferralIOM.pdf';
//             cv.VersionData = pdfBlob;
//             //cv.VersionData = pdfBase64Content;

//             cvList.add(cv);
//         }

//         insert cvList;

//         cvList = [
//             SELECT Id, ContentDocumentId
//             FROM ContentVersion
//             WHERE Id IN :cvList
//         ];

//         List<ContentDocumentLink> links = new List<ContentDocumentLink>();

//         Integer i = 0;

//         for(Referral_Credits__c rc : refList){

//             ContentDocumentLink cdl = new ContentDocumentLink();
//             cdl.ContentDocumentId = cvList[i].ContentDocumentId;
//             cdl.LinkedEntityId = rc.Id; // Attach to Referral Credit
//             cdl.ShareType = 'V';
//             cdl.Visibility = 'AllUsers';

//             links.add(cdl);
//             i++;
//         }

//         insert links;
//      }

// }

public class ReferralCreditIOMPDFHandler implements Queueable, Database.AllowsCallouts {

    private Set<Id> referralIds;

    public ReferralCreditIOMPDFHandler(Set<Id> referralIds){
        this.referralIds = referralIds;
    }

    public void execute(QueueableContext context){

        List<Referral_Credits__c> refList = [
            SELECT Id, Booking__c, Name
            FROM Referral_Credits__c
            WHERE Id IN :referralIds
        ];

        List<ContentVersion> cvList = new List<ContentVersion>();

        for(Referral_Credits__c rc : refList){

            try{
                PageReference pdfPage = Page.ReferralIomPage;
                pdfPage.getParameters().put('id', rc.Booking__c);

                Blob pdfBlob = pdfPage.getContentAsPDF();

                ContentVersion cv = new ContentVersion();
                cv.Title = 'Referral IOM - ' + rc.Name;
                cv.PathOnClient = 'Referral_IOM_' + rc.Name + '.pdf';
                cv.VersionData = pdfBlob;

                cvList.add(cv);

            }catch(Exception e){
                System.debug('PDF generation failed for: ' + rc.Id + ' Error: ' + e.getMessage());
            }
        }

        if(!cvList.isEmpty()){
            insert cvList;
        }

        // Link files to Referral Credit
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();

        List<ContentVersion> insertedCV = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :cvList
        ];

        Integer i = 0;

        for(Referral_Credits__c rc : refList){

            if(i < insertedCV.size()){

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = insertedCV[i].ContentDocumentId;
                cdl.LinkedEntityId = rc.Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';

                links.add(cdl);
            }
            i++;
        }

        if(!links.isEmpty()){
            insert links;
        }
    }
}