public class BrokerageInvoiceSAP {
    public Id InvoiceIds { get; set; }
    public Boolean EnterCondTypeforSAPDocNo { get; set; }
    public Set<Id> BI = new Set<Id>();
    public List<Brokerage_Invoice__c> BrokerageInvoicelist { get; set; }

    public String selectedPicklistValue { get; set; }

    public List<SelectOption> getPicklistOptions() {     
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ZEXB', 'ZEXB'));
        //options.add(new SelectOption('Z1BR', 'Z1BR'));
        //options.add(new SelectOption('ZBRK', 'ZBRK'));        
        options.add(new SelectOption('ZFXB', 'ZFXB'));
        options.add(new SelectOption('ZGXB', 'ZGXB'));
        return options;
    }

    public BrokerageInvoiceSAP() {
        InvoiceIds = ApexPages.currentPage().getParameters().get('InvoiceIds');
        EnterCondTypeforSAPDocNo = Boolean.valueOf(ApexPages.currentPage().getParameters().get('EnterCondTypeforSAPDocNo'));
        BrokerageInvoicelist = new List<Brokerage_Invoice__c>();
        
        list<Brokerage_Invoice__c> blist = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c,Eligible_Slab__c
            FROM Brokerage_Invoice__c
            WHERE Approval_Status__c = 'Approved By L3 - Accounts' AND Id = :InvoiceIds];
         if (!blist.isEmpty() && blist.size() > 0 && EnterCondTypeforSAPDocNo == true ) {
            if(blist[0].Eligible_Slab__c == 'Slab 1'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Condition type cannot be given when Eligible slab is Slab 1'));
            }
           } 
        
    }

    public void BrokerageInvoice() {
        BrokerageInvoicelist = [
            SELECT Id, Name, Approval_Status__c, SAP_Document_No__c,Eligible_Slab__c
            FROM Brokerage_Invoice__c
            WHERE Approval_Status__c = 'Approved By L3 - Accounts' AND Id = :InvoiceIds
        ];
        
        System.debug('BrokerageInvoicelist:' + BrokerageInvoicelist);
        System.debug('BrokerageInvoicelist Size:' + BrokerageInvoicelist.size());
        System.debug('Selected Picklist Value: ' + selectedPicklistValue);
        
        if (!BrokerageInvoicelist.isEmpty() && BrokerageInvoicelist.size() > 0 && EnterCondTypeforSAPDocNo == true ) {
            if(BrokerageInvoicelist[0].Eligible_Slab__c == 'Slab 1'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           'Condition type cannot be given when Eligible slab is Slab 1'));
            }
        }
       
        if (!BrokerageInvoicelist.isEmpty() && BrokerageInvoicelist.size() > 0) {
            BI.add(InvoiceIds);
            SAPCPInvoiceCreation.SendReq(BI, EnterCondTypeforSAPDocNo,selectedPicklistValue);
            System.debug('Invoice API Triggered from button');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Document number generation in process, please click on Back to Invoice button and refresh the Brokerage invoice page.'));
        }
        
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Approval Status is not Approved by -L3'));
        }
        
        
        
    }

    public PageReference BackToBrokerageInvoice() {
        PageReference P = new PageReference('/' + InvoiceIds);
        return P;
    }
}