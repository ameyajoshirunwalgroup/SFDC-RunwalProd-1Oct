public class InvoiceTriggerHandler {
    @future(callout=true)
    public static void sendEmailmethod(Set<Id> bsIds){
        system.debug('bsIds:;'+bsIds);
        List<Brokerage_Invoice__c> InvoiceList = new List<Brokerage_Invoice__c>();
        InvoiceList = [Select Id,Name,Channel_Partner__c,Channel_Partner__r.RW_Email__c from Brokerage_Invoice__c where Id IN:bsIds];
        system.debug('InvoiceList:;'+InvoiceList);
        for(Brokerage_Invoice__c bi :InvoiceList){
            List<Broker__c> ChannelPartner = new List<Broker__c>();
            
            PageReference pageRef2 = new PageReference('/apex/CPInvoiceDueEmail');
            pageRef2.getParameters().put('id', bi.Id);
            
            Blob body;
            Blob htmlBody;
            try {
                // returns the output of the page as a PDF
                if(!test.isRunningTest()) {
                    htmlBody = pageRef2.getContent();
                }
                else {
                    htmlBody = Blob.valueof('Dummy COntent for Test Methods');
                    body = Blob.valueOf('Some Text');
                }    
            } catch (VisualforceException e) {
                system.debug('in the catch block'+e.getMessage());
                body = Blob.valueOf('Some Text');
            }
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            
            
            List<String> toAddresses = new List<String>();
            List<String> toCCAddresses = new List<String>();
            List<String> toBCCAddresses = new List<String>();
            
            String Subject = 'Intimation For Invoice Generation -  Runwal Group !!!';
            toAddresses.add(bi.Channel_Partner__r.RW_Email__c);
            //toAddresses.add('shobha.shetty@runwal.com');
            //toCCAddresses.add('aniket.kale@stetig.in');
            if(!toAddresses.isEmpty()){
                message.setToAddresses(toAddresses);
            }
            if(!toCCAddresses.isEmpty()){
                message.setCcAddresses(toCCAddresses);
            }
            message.setSubject(Subject);
            message.setHtmlBody(htmlBody.toString());
            allMails.add(message);
            Messaging.sendEmail(allMails); 
        }
        
        
    }
    
}