public class ReferralCreditAPIVFController {
    public list<Id> rcIds { get; set; }
    public Id rcId { get; set; }
    public List<Referral_Credits__c> rclist { get; set; }


    public ReferralCreditAPIVFController() {
        rcId = ApexPages.currentPage().getParameters().get('rcId');
        rclist = new List<Referral_Credits__c>();
        
        List<Referral_Credits__c> RcList1 = [Select Id,name,Referral_In_Rs__c,Name_of_New_Customer__c,Reference_Booking__r.Name,Reference_Booking__c,long_text1__c,Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c,
                                             Booking__r.Customer__r.SalesOrder_Number__c,Approval_Status__c  From Referral_Credits__c Where Id =: rcId]; 
        system.debug('RcList1::'+rclist);         
        system.debug('RcList1 size::'+rclist.size()); 
         if (!RcList1.isEmpty() && RcList1.size() > 0 ) {
            if(RcList1[0].Approval_Status__c != 'Uploaded'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'Please check if the IOM is uploaded! if not please upload IOM first before submitting the record for SAP Document Generation.'));
            }
           } 
        
    }

    public void ReferralCreditAPIVFController() {
        rcIds = new list<Id>();
        rclist = [Select Id,name,Referral_In_Rs__c,Name_of_New_Customer__c,Reference_Booking__r.Name,Reference_Booking__c,long_text1__c,Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c,
                                                     Booking__r.Customer__r.SalesOrder_Number__c,Approval_Status__c  From Referral_Credits__c Where Id =: rcId];        
        System.debug('rclist:' + rclist);
        System.debug('rclist Size:' + rclist.size());
        
        if (!rclist.isEmpty() && rclist.size() > 0 ) {
            if(rclist[0].Approval_Status__c != 'Uploaded'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                                           'Please check if the IOM is uploaded! if not please upload IOM first before submitting the record for SAP Document Generation.'));
            }
        }
        
        if (!rclist.isEmpty() && rclist.size() > 0) {           
            rcIds.add(rclist[0].Id);
            SAP_Rest_ReferralCreditAPI.sendReferrallist(rcIds);
            System.debug('Invoice API Triggered from button');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Document number generation in process, please click on Back to Credit Record button and refresh the page.'));
        }
        
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                'IOM Approval Status should be Uploaded before generating Document Number..'));
        }
        
        
        
    }

    public PageReference BackToReferralCredit() {
        PageReference P = new PageReference('/' + rcId);
        return P;
    }
}