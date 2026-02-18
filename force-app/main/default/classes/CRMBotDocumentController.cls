public class CRMBotDocumentController {
    
    public String pdfData {get;set;}
    public String docId {get;set;}
    public String docName {get;set;}
    
    public CRMBotDocumentController(){
        
        docId = ApexPages.currentPage().getParameters().get('id');
        docName = ApexPages.currentPage().getParameters().get('doc');
        System.debug('docId: ' + docId);
        System.debug('docName: ' + docName);
        //docName = 'Test';
        //Attachment att = [SELECT Id, Body FROM Attachment WHERE Id = '00P1e000005bDaxEAE'];
        //System.debug('body: ' + att.Body.toString());
        //pdfData = att.Body.toString();
        //pdfData = PDFController.getCustLedgerPdf('a0s1e0000026FS0AAM');
        if(docName == 'acs'){
            pdfData = PDFController.getCustLedgerPdf(docId);
        }else if(docName == 'dem'){
            pdfData = PDFController.getdemandPdf(docId);
        }else if(docName == 'recp'){
            pdfData = PDFController.getreceiptPdf(docId);
        }else if(docName == 'costsheet'){
            /*PageReference pdf = Page.quotationattachment;
            pdf.getParameters().put('id',docId);
            Blob body= pdf.getContent();
            pdfData = EncodingUtil.base64encode(body);*/
            
            Quotation__c q = [SELECT Id, Cost_Sheet_pdf_data__c FROM Quotation__c where Id  =: docId];
            pdfData = q.Cost_Sheet_pdf_data__c;
        }else if(docName == 'ncf'){  //Added by Vinay 16-10-2025
            pdfData = NameConfirmationController.generateAndSendForm(docId);
        }

		System.debug('pdfData: ' + pdfData);

    }

}