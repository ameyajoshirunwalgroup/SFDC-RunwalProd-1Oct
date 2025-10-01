@isTest
public class testNewApplicationForBooking {
    @isTest
    public static void test1(){
        Booking__c objBooking;
       // Applicant_Details__c applidata;
       // TokenInWords tokw;
        Project_Unit__c objPUU1;
        Project__c objpr;
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Project_Unit__c objPUU;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        //project details
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Legal_Entity__r.name ='';
        insert objpr;
          
        //tower details
        Tower__c t = new Tower__c();
             t.Name = 'Tower X';
             t.ProjectName__c = objpr.Id;
             t = RDSCommon.CreateTower(t);
             
    

        //unit details  
        objPUU = new Project_Unit__c();  
        //objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        //no of car park details
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        //parking charges
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
       
        //parking charges
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        S_NumberToWord.convertNumbertoWords(100000);
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
        q.Project_Unit__c = objPUU.Id;
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
        objBooking.Token_Amount__c = 1000;
        objBooking.Unit_No__c = objPUU.Id;
        //objBooking.ownerId = a1.id;
        insert objBooking;
        
         Applicant_Details__c applidata = new  Applicant_Details__c();
         applidata.Name='test app1';
         applidata.DOB__c= system.today();
         applidata.PancardNo__c='AA121212';
         applidata.Permanent_Address__c='pune';
         applidata.Applicant_Number__c='123313';
         applidata.Mobile_Number__c='9988776655';
         applidata.Landline_Number__c='76676876887';
         applidata.Salutation__c='xyzzz';
         applidata.Mailing_Address__c='testaaa@gmail.com';
         applidata.Email_Address__c='ghghgh@gmail.com';
         applidata.Organization_Name__c='xyzzzz';
         applidata.Designation__c='developer';
         applidata.Organization_Address__c='xyzzz@gmail.com';
         //applidata.Booking__c = objBooking.Id;
         insert applidata;
        
         Applicant_Details__c applidataa = new  Applicant_Details__c();
         applidataa.Name='test app2';
         applidataa.DOB__c= system.today();
         applidataa.PancardNo__c='AA1212122';
         applidataa.Permanent_Address__c='punee';
         applidataa.Applicant_Number__c='1233132';
         applidataa.Mobile_Number__c='9988776635';
         applidataa.Landline_Number__c='76676876827';
         applidataa.Salutation__c='xyyzzz';
         applidataa.Mailing_Address__c='testaaya@gmail.com';
         applidataa.Email_Address__c='ghgyyhgh@gmail.com';
         applidataa.Organization_Name__c='xyyyzzzz';
         applidataa.Designation__c='developerrr';
         applidataa.Organization_Address__c='xyrrrzzz@gmail.com';
         //applidata.Booking__c = objBooking.Id;
         insert applidataa;
                
        
        //Name, DOB__c, PancardNo__c, Permanent_Address__c, Applicant_Number__c, Mobile_Number__c, Landline_Number__c, Salutation__c, Mailing_Address__c,
           //   Email_Address__c, Organization_Name__c, Designation__c, Organization_Address__c From Applicant_Details__c Where Booking__c =: BookingId order by createdDate asc
            // ];
        // applicant1 to required fields validation simulation
        BookingClass bookC1 = new BookingClass();
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 444444;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'India';
        bookC1.applicant.Mobile_Number__c = '909090900';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.Address_Proof__c = true;
        bookC1.applicant.Address_Proof_Document__c = 'abc';
        bookC1.applicant.Address_Proof_Number__c = 'pqr';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheck = true; 
        
        // applicant1 to required fields validation simulation
        BookingClass bookC2 = new BookingClass();
        bookC2.applicant.Salutation__c = 'Mr.';
        bookC2.applicant.Name = 'New Mann';
        bookC2.applicant.DOB__c = system.today();
        bookC2.applicant.Permanent_Address__c = 'Pike Street, New World, 45020';
        bookC2.applicant.Pincode__c = 444442;
        bookC2.applicant.Country__c = 'India';
        bookC2.applicant.City__c = 'Nagpur';
        bookC2.applicant.Mailing_Country__c= 'India';
        bookC2.applicant.Mobile_Number__c = '909090901';
        bookC2.applicant.Email_Address__c = 'newman1@justnow.com';
        bookC2.applicant.Nationality__c = 'Indian';
        bookC2.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC2.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC2.applicant.Pancard__c = true;
        bookC2.applicant.Address_Proof__c = true;
        bookC2.applicant.Address_Proof_Document__c = 'abcc';
        bookC2.applicant.Address_Proof_Number__c = 'pqrr';
        bookC2.applicant.One_Passport_Size_Color_Photograph__c = true;
        bookC2.addressCheck = true; 
       
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r2.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        r2.Booking__c = objBooking.Id;
       // insert r2;
        
        Receipt__c r = new Receipt__c();
       
        r.Cheque_DD_Amount_Rs__c = 8200;
        r.Cheque_DD__c = '90288851';
        r.Cheque_DD_Date__c = system.today();
        r.Project__c = objpr.Id;
        r.Project_Unit__c = objPUU.Id;
        r.Opportunity__c = objcustomer.Id;
        r.CheckReceipt__c = false;
        r.Physically_Cheque_Received__c = false;
        r.Approval_Status__c = 'Approved';
        r.Receipt_Date__c = system.today();
        r.DraweeBank__c = 'CITI';
        r.Total_Amount__c = 8490;
        r.Currency__c = 'Indian Rupee';
        r.Token_Amount_ST__c = false;
        r.Booking__c = objBooking.Id;
        //insert r;
        List<Receipt__c> lsrr = new List<Receipt__c>();
        lsrr.add(r2);lsrr.add(r); insert lsrr;
        
        ApexPages.currentPage().getParameters().put('id', objBooking.id);
         NewApplicationForBooking scp = new NewApplicationForBooking();
         scp.b.add(objBooking);
        
        // PageReference rPage = Page.New_ApplicationBookingFormVFP;
        //    Test.setCurrentPage(rPage);
           
        //ApexPages.currentPage().getParameters().put('id', objBooking.id);
        //   NewApplicationForBooking scp = new NewApplicationForBooking();
    }
}