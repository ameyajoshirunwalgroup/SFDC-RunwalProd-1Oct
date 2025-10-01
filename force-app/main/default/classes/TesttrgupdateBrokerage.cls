@isTest
public class TesttrgupdateBrokerage {
    private static testmethod void updateBrokerageonBookingTriggerTest(){
        
              
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        //q.Project__c = objpr.Id;
        q.Stamp_duty_payable_by_Runwal__c =1000;        
        insert q;
                
        Booking__c b = new Booking__c();
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Source_of_Booking__c = 'Channel Partner';
        // b.Stamp_duty_Paid__c = 100000;
        
        b.Base_Brokerage_2__c = 4;
        b.Base_Brokerage__c = 2;
        insert b;
        
        RW_Registration_Challan__c sdr = New RW_Registration_Challan__c();
        sdr.RW_SDR_Instrument_Amount__c = 40000;
        sdr.RW_SDR_Instrument_Date__c = system.today();
        sdr.Booking__c = b.Id;
        
        insert sdr;
       
        b.Brokerage__c = 2;
        update b;
        
        
         Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        //q.Project__c = objpr.Id;
        q1.Stamp_duty_payable_by_Runwal__c =1000;  
        
        insert q1;
                
        Booking__c b1 = new Booking__c();
        b1.Quotation__c = q1.Id;
        b1.Booking_Date__c = Date.today();
        b1.Type_of_Client__c = 'NRI';
        b1.Is_Special_Brokerage_Scheme__c = true;
        b1.RW_Registration_Done__c = 'Yes';
        b1.Source_of_Booking__c = 'Channel Partner';
        b1.RW_Registration_Date__c = system.today();
        b1.RW_BRL_Number__c = 'dfgffg466666';
        b1.RW_Expected_Registration_Date__c = system.today();
        b1.RW_Registration_Type__c = 'Offline Registration';
        // b.Stamp_duty_Paid__c = 100000;
        
        b1.Base_Brokerage_2__c = 4;
        b1.Base_Brokerage__c = 2;
        insert b1;
        

             
        b1.RW_Registration_Done__c = 'Yes';
        update b1;
        
    }   
    
}