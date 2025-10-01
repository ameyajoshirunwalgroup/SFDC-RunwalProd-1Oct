public class PaymentDetailsWrapper 
{
        @AuraEnabled
        public String RWInstrumentNumber{get;set;}
    
        @AuraEnabled
        public String RWPaymentDate{get;set;}
    
        @AuraEnabled
        public String RWPaymentAmount{get;set;}
    
        @AuraEnabled
        public String RWBankName{get;set;}
    
        @AuraEnabled
        public String RWModeOfPayment{get;set;}

}