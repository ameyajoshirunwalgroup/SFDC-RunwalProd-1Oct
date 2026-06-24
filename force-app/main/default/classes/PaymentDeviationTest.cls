@isTest
public class PaymentDeviationTest {
    
    @isTest
    public static void testPaymentDeviation(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity',AccountId = acc.Id, StageName = 'Qualification',CloseDate = Date.today().addDays(30));
        insert opp;
        
        Quotation__c quote = new Quotation__c(Opportunity__c = opp.Id);
        insert quote;
        
        Global_Charges__c gc = new Global_Charges__c(Name = 'Basic', Code__c = '100');
        insert gc;
        
        Customer_Pay_Plan_Header__c cpph = new Customer_Pay_Plan_Header__c(Quotation__c = quote.Id, Global_Charges__c = gc.Id);
        insert cpph;
        
        Standard_Customer_Pay_Plan_Detail__c scppd = new Standard_Customer_Pay_Plan_Detail__c(Customer_Pay_Plan_Header__c = cpph.Id, Is_to_be_Paid__c = 'From Dt. of Booking',Amount_Value__c = 10, Days_Months_Value__c = 30);
        insert scppd;
        
        Booking__c bkg = new Booking__c(Opportunity__c = opp.Id, Quotation__c = quote.Id, Booking_Date__c = Date.today());
        insert bkg;
        
        quote.Booking__c = bkg.Id;
        update quote;
        
        PaymentDeviation.calculateMilestoneDatesOnQuoteUpdate(new List<Id>{quote.Id});
    }

}