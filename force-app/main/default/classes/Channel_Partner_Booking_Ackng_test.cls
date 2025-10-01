@isTest
public class Channel_Partner_Booking_Ackng_test {
    @isTest
    public static void test2(){
        Project_Unit__c objPUU;
        Booking__c objBooking;
        Project__c objpr;
        Opportunity objcustomer;
        Opportunity objcustomer1;
        
        //project details
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Legal_Entity__r.name ='';
        insert objpr;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        //opportunity details
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
        
        //quotation details
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        //q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
      //  q.Allotment_Premium__c= 100000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        //q.Stack_Additional__c = 0; 
        insert q;  
        //booking details
        objBooking = new Booking__c();
        objBooking.Code__c='1234';
        objBooking.Reg_No__c='150224';
        objBooking.Project__c=objpr.id;
        objBooking.Direct__c=true;
        objBooking.Token_Amount__c = 12345667;
        objBooking.Broker_Code__c='A-022';
        objBooking.Broker_Name__c=' Broker 1';
        objBooking.Customer_Name__c='Client';
        objBooking.Effective_From__c=system.today();
        objBooking.Application_No__c='Ap-01';
        objBooking.Status__c='Approved';
        objBooking.MG_Effect_Date__c=system.today();
        objBooking.MG_Per_Amt_Val__c=222;
        objBooking.Customer__c=objcustomer.id;
        objBooking.UnitChange__c=true;
        objBooking.Area__c='Noida';
        objBooking.Remarks__c='Remarks';
        objBooking.Cretaed_On__c=system.today();
        objBooking.MG_Months_Year__c='jan-15';
        objBooking.MG_Mon_Year_Val__c=50;
        //objBooking.Unit_No__c=objPUU1.Id;
        //objBooking.Advance_Registration_Reference_No__c='R-01';
        objBooking.Sharing_Per_Amt__c='1000.00';
        objBooking.MG_Per_Amt__c='2000.00';
        objBooking.Sharing_Per_Amt_Val__c=1400.00;
        objBooking.Quotation__c = q.Id;
        objBooking.Future_Correspondence_Contact__c = 'First Applicant';
        objBooking.Status__c = 'Booking In Process';
        objBooking.Opportunity__c = objcustomer.id;
        objBooking.Source_of_Booking__c='Channel Partner';
        objBooking.Allotment_Premium__c= 110000;
        //objBooking.ownerId = a1.id;
        insert objBooking;   
        
       // PageReference rPage = Page.Channel_Partner_Booking_Acknowledgement;
        //    Test.setCurrentPage(rPage);
           
        ApexPages.currentPage().getParameters().put('id', objBooking.id);
        Channel_Partner_Booking_Acknowlegement scp = new Channel_Partner_Booking_Acknowlegement();
        scp.b.add(objBooking);
}
}