public class SendWhatsAppOnSOCreationQueueable implements Queueable, Database.AllowsCallouts {
    
    private List<Id> opportunityIds;
    
    public SendWhatsAppOnSOCreationQueueable(List<Id> oppIds) {
        this.opportunityIds = oppIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<Opportunity> opps = [SELECT Id, Primary_Name__c, RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c, Booking__r.Source_of_Booking__c, Booking__r.Quotation__c FROM Opportunity WHERE Id =: opportunityIds];
        String fileURL = System.label.Home_Loan_pdf_link;
        List<String> quoteIds = new List<String>();
        
        for(Opportunity eachOpp : opps){
            String costSheetLink = 'id='+ eachOpp.Booking__r.Quotation__c + '&doc=costsheet';
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,eachOpp.Primary_Name__c,eachOpp.Booking__r.Source_of_Booking__c,null,null,null,null,null,costSheetLink,eachOpp.Booking__r.RW_Country_Phone_Code__c,eachOpp.RW_Mobile_No__c,'Booking Details');
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,eachOpp.Primary_Name__c,null,null,null,null,null,fileURL,'Home Loan',eachOpp.Booking__r.RW_Country_Phone_Code__c,eachOpp.RW_Mobile_No__c,'Bank Funding Requirements Documents');
            }
            
            quoteIds.add(eachOpp.Booking__r.Quotation__c);
        }
        System.debug('quoteIds: ' + quoteIds);
        if(quoteIds.size() > 0){
            costSheetPdfDataUpdate(quoteIds);
        }
        
    }
    
    //@future(callout=true)
    public static void costSheetPdfDataUpdate(List<String> quoteIds){
        List<Quotation__c> quotes = [SELECT Id, Costsheet_format__c FROM Quotation__c WHERE Id =: quoteIds];
        for(Quotation__c q : quotes){
            //PageReference pdf = Page.quotationattachment;
            PageReference pdf = new PageReference('/apex/'+q.Costsheet_format__c);
            pdf.getParameters().put('id',q.Id);
            Blob body= pdf.getContentAsPdf();
            String pdfData = EncodingUtil.base64encode(body);
            q.Cost_Sheet_pdf_data__c = pdfData;
        }
        update quotes;
    }
    
    
    
}