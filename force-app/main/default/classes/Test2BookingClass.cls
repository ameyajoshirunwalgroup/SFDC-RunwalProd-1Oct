@isTest
private  Class Test2BookingClass {
  @testSetup
    
    private static void setupdata() 
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAPInventoryCallMock());
        Test.stopTest();
            
        
            
    }
    
 
 @isTest
    private static void BookingTest1() {
        Test.startTest();
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Opportunity objcustomer2;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777332',false);
        
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
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        //q.Service_Tax_On_Token_Amount__c = true;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
        
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
        insert r2;
      
        
       
       
        

            
   
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        //bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Sales_Managers__c = 'TestUser';
        bookC1.boookingObj.Sourcing_Mananger__c = 'RamuKaka';
        //bookC1.Save();
        bookC1.dummyMethod();

       
        /*bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';*/
     
        // applicant1 to required fields validation simulation
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.First_Name__c = 'New';
        bookC1.applicant.Middle_Name__c = 'Young';
        bookC1.applicant.Last_Name__c = 'Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 444444;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.state__c = 'Maharashtra';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'India';
        bookC1.applicant.Mobile_Number__c = '9090909000';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Nationality_Picklist__c = 'Indian';
        bookC1.applicant.Marital_Status__c = 'Married';
        bookC1.applicant.Gender__c= 'Male';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.Address_Proof__c = true;
        bookC1.applicant.Address_Proof_Document__c = 'abc';
        bookC1.applicant.Address_Proof_Number__c = 'pqr';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheck = true; 
        
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Salutation__c = 'Mr.';
        bookC1.applicant2.First_Name__c = 'Second';
        bookC1.applicant2.Middle_Name__c = 'Old';
        bookC1.applicant2.Last_Name__c = 'Man';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant2.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant2.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Pincode__c = 444444;
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.State__c= 'Maharashtra';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mailing_Pincode__c= null;
        bookC1.applicant2.Mobile_Number__c = '9090909000';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Nationality_Picklist__c = 'Indian';
        bookC1.applicant2.Marital_Status__c = 'Married';
        bookC1.applicant2.Gender__c= 'Male';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.Address_Proof__c = true;
        bookC1.applicant2.Address_Proof_Document__c = 'xyz';
        bookC1.applicant2.Address_Proof_Number__c = 'pqr';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant2 = true;
        //bookC1.save();
        //bookC1.dummyMethod();

        /*bookC1.applicant3.Name ='Third Man';
        bookC1.save();
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();*/
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Salutation__c = 'Mr.';
        bookC1.applicant3.First_Name__c = 'Third';
        bookC1.applicant3.Middle_Name__c = 'Young';
        bookC1.applicant3.Last_Name__c = 'Man';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant3.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant3.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Pincode__c = 444444;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c = 'Maharashtra';
        bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        bookC1.applicant3.Mobile_Number__c = '9090909000';
        bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant3.Nationality_Picklist__c = 'Indian';
        bookC1.applicant3.Marital_Status__c = 'Married';
        bookC1.applicant3.Gender__c= 'Male';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PassportNumber__c = true;
        bookC1.applicant3.Funds_from_NRE_NRO__c = true;
        bookC1.applicant3.Address_Proof__c = true;
        bookC1.applicant3.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant3.PancardNo__c = '1234567890';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant3 = true;
        //bookC1.save();
        
        bookC1.applicant4.Salutation__c = 'Mr.';
        bookC1.applicant4.First_Name__c = 'Fourth';
        bookC1.applicant4.Middle_Name__c = 'Young';
        bookC1.applicant4.Last_Name__c = 'Man';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.DOB__c = system.today();
        bookC1.applicant4.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant4.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant4.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Pincode__c = 444444;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= 'Maharashtra';
        bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        bookC1.applicant4.Mobile_Number__c = '9090909000';
        bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant4.Nationality_Picklist__c = 'Indian';
        bookC1.applicant4.Marital_Status__c = 'Married';
        bookC1.applicant4.Gender__c= 'Male';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PassportNumber__c = true;
        bookC1.applicant4.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant4.Address_Proof__c = true;
        bookC1.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant4.PancardNo__c = '1234567891';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant4.Type_Of_Origin__c = 'abc';
        bookC1.applicant4.Origin_Details__c = 'India';
        bookC1.addressCheckApplicant4 = true;
        bookC1.applicant4.Mailing_City__c= 'Pune';
        bookC1.boookingObj.Opportunity__c = objcustomer.id;
        //bookC1.save();
        
        bookC1.applicant5.Salutation__c = 'Mr.';
        bookC1.applicant5.First_Name__c = 'Fifth';
        bookC1.applicant5.Middle_Name__c = 'Young';
        bookC1.applicant5.Last_Name__c = 'Man';        
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';
        bookC1.applicant5.DOB__c = system.today();
        bookC1.applicant5.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant5.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant5.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant5.Pincode__c = 444444;
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.State__c= 'Maharashtra';
        bookC1.applicant5.City__c = 'Nagpur';
        bookC1.applicant5.Mailing_Country__c= 'India';
        bookC1.applicant5.Mobile_Number__c = '9090909000';
        bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Nationality_Picklist__c = 'Indian';
        bookC1.applicant5.Marital_Status__c = 'Married';
        bookC1.applicant5.Gender__c= 'Male';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PassportNumber__c = true;
        bookC1.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant5.Address_Proof__c = true;
        bookC1.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant5.PancardNo__c = '1234567890';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant5.Address_Proof_Document__c = 'Aadhar Card';
        bookC1.applicant5.Address_Proof_Number__c  = '121212457812';
        bookC1.addressCheckApplicant5 = true;
        //bookC1.save();
        
      
        //Test.startTest();
     //   bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
       // bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        //bookC1.save();
       /* bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fourth Man';
        bookC1.save();*/
        Test.stopTest();       
   }

   @isTest
    private static void BookingTest2() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
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
        
        /*objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;*/
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
    
        
        
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
        insert r2;
           
    
        
        
         
        
        
       
        
        
   
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Sales_Managers__c = '';
        bookC1.boookingObj.Sourcing_Mananger__c= '';
        bookC1.boookingObj.Sourcing_Mananger__c= null;
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';    
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';    
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';    
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';    
        bookC1.save(); 
        // applicant1 to required fields validation simulation
        
     
        
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c= '123456789';
        bookC1.addressCheck = false; 
        bookC1.applicant.Mailing_Address_Line_1__c = null;
        bookC1.applicant.Mailing_Pincode__c = null;
        bookC1.applicant.Mailing_Country__c = null;
        bookC1.save();
        bookC1.applicant.Country__c ='India';
        bookC1.applicant.Pincode__c = 7894563;
        bookC1.save();
        bookC1.applicant.Mobile_Number__c = null;
        bookC1.save();
        bookC1.applicant.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c= false;
        //bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant.Mailing_Country__c = 'India';
        bookC1.applicant.Mailing_Pincode__c= 7894563;
        bookC1.applicant.Mailing_State__c = null;
        //bookC1.save();
        

        
        bookC1.applicant2.First_Name__c = 'Second';
        bookC1.applicant2.Salutation__c = null;
        bookC1.applicant2.Last_Name__c = null;
        bookC1.applicant2.Pincode__c = null;
        //bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c= '123456789';
        //bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        //bookC1.save();
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.State__c= null;
        bookC1.applicant2.Pincode__c = 4578963;
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c= false;
        //bookC1.save();
   /* bookC1.applicant2.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant2.Country__c = null;
        bookC1.save();
        bookC1.applicant2.Pincode__c = 4578963;
        bookC1.save();
        bookC1.addressCheckApplicant2 = false;
        bookC1.applicant2.Mailing_Address_Line_1__c = null;
        bookC1.applicant2.Mailing_Pincode__c = null;
        bookC1.applicant2.Mailing_Country__c = null;
        bookC1.save();		*/
       bookC1.applicant2.Mailing_Country__c = 'India';
        bookC1.applicant2.Mailing_Pincode__c= 7894563;
        bookC1.applicant2.Mailing_State__c = null;
        bookC1.applicant2.Mailing_City__c= null;
        //bookC1.save();
        
        
        bookC1.applicant3.First_Name__c = 'Third';
        bookC1.applicant3.Salutation__c = null;
        bookC1.applicant3.Last_Name__c = null;
        bookC1.applicant3.Country__c = null;
        //bookC1.save();
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c= false;
        //bookC1.save();
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PancardNo__c = '12345678'; 
        /*bookC1.save();
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PancardNo__c= '123456789';
        bookC1.save();
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c= null;
        bookC1.applicant3.Pincode__c = 4578963;
        bookC1.save();
        bookC1.applicant3.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant3.DOB__c = null;
        bookC1.applicant3.Permanent_Address_Line_1__c = null;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c = null;
        bookC1.applicant3.Pincode__c = null;
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PancardNo__c = '12345678'; 
        bookC1.addressCheckApplicant3 = false; 
        bookC1.applicant3.Mailing_Address_Line_1__c = null;
        bookC1.applicant3.Mailing_Pincode__c = null;
        bookC1.applicant3.Mailing_Country__c = null;
        bookC1.save();*/
        bookC1.applicant3.Mailing_Country__c = 'India';
        bookC1.applicant3.Mailing_Pincode__c= 7894563;
        bookC1.applicant3.Mailing_State__c = null;
        bookC1.applicant3.Mailing_City__c= null;
        //bookC1.save();
        

        bookC1.applicant4.First_Name__c = 'Fourth';
        bookC1.applicant4.Salutation__c = null;
        bookC1.applicant4.Last_Name__c = null;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.Pincode__c = 45896312;
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c= '123456789';
        bookC1.addressCheckApplicant4 = false; 
        bookC1.applicant4.Mailing_Address_Line_1__c = null;
        bookC1.applicant4.Mailing_Pincode__c = null;
        bookC1.applicant4.Mailing_Country__c = null;
        //bookC1.save();
      /*bookC1.applicant4.Mailing_Country__c = 'India';
        bookC1.applicant4.Mailing_Pincode__c= 7894563;
        bookC1.applicant4.Mailing_State__c = null;
        bookC1.applicant4.Mailing_City__c= null;
        bookC1.save();*/
        /*bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= null;
        bookC1.applicant4.Pincode__c = 4578963;
        bookC1.save();
        bookC1.applicant4.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant4.Pincode__c = null;
        bookC1.applicant4.Country__c = null;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = null;
        bookC1.save();*/
        
        
        
       /* bookC1.applicant5.Last_Name__c = 'Young';
        bookC1.applicant5.First_Name__c = 'Fifth';
        bookC1.applicant5.Salutation__c = null;
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.Pincode__c = 45896312;
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PancardNo__c= '123456789';
        bookC1.addressCheckApplicant5 = false; 
        bookC1.applicant5.Mailing_Address_Line_1__c = null;
        bookC1.applicant5.Mailing_Pincode__c = null;
        bookC1.applicant5.Mailing_Country__c = null;
        bookC1.save();
        bookC1.applicant5.Mailing_Country__c = 'India';
        bookC1.applicant5.Mailing_Pincode__c= 7894563;
        bookC1.applicant5.Mailing_State__c = null;
        bookC1.applicant5.Mailing_City__c= null;
        bookC1.save();
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        bookC1.applicant5.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant5.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.State__c= null;
        bookC1.applicant5.Pincode__c = 4578963;
        bookC1.save();
        bookC1.applicant5.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant5.Pincode__c = null;
        bookC1.applicant5.Country__c = null;
        bookC1.save();
        bookC1.applicant5.Subtype_Of_Applicant__c = null;
        bookC1.save();*/
        
      
        /*bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.First_Name__c = 'New';
        bookC1.applicant.Middle_Name__c = 'Young';
        bookC1.applicant.Last_Name__c = 'Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 444444;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'India';
        bookC1.applicant.Mobile_Number__c = '9090909000';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Nationality_Picklist__c = 'Indian';
        bookC1.applicant.Marital_Status__c = 'Married';
        bookC1.applicant.Gender__c= 'Male';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.Address_Proof__c = true;
        bookC1.applicant.Address_Proof_Document__c = 'abc';
        bookC1.applicant.Address_Proof_Number__c = 'pqr';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheck = true; 
        
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.First_Name__c = 'Second';
        bookC1.applicant2.Middle_Name__c = 'Old';
        bookC1.applicant2.Last_Name__c = 'Man';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant2.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant2.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Pincode__c = 444444;
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mailing_Pincode__c= null;
        bookC1.applicant2.Mobile_Number__c = '9090909000';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Nationality_Picklist__c = 'Indian';
        bookC1.applicant2.Marital_Status__c = 'Married';
        bookC1.applicant2.Gender__c= 'Male';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.Address_Proof__c = true;
        bookC1.applicant2.Address_Proof_Document__c = 'xyz';
        bookC1.applicant2.Address_Proof_Number__c = 'pqr';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant2 = true;
        bookC1.save();
        
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Salutation__c = 'Mr.';
        bookC1.applicant3.First_Name__c = 'Third';
        bookC1.applicant3.Middle_Name__c = 'Young';
        bookC1.applicant3.Last_Name__c = 'Man';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant3.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant3.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Pincode__c = 444444;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c = 'Maharashtra';
        bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        bookC1.applicant3.Mobile_Number__c = '9090909000';
        bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant3.Nationality_Picklist__c = 'Indian';
        bookC1.applicant3.Marital_Status__c = 'Married';
        bookC1.applicant3.Gender__c= 'Male';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PassportNumber__c = true;
        bookC1.applicant3.Funds_from_NRE_NRO__c = true;
        bookC1.applicant3.Address_Proof__c = true;
        bookC1.applicant3.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant3.PancardNo__c = '1234567890';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();
        
        bookC1.applicant4.Salutation__c = 'Mr.';
        bookC1.applicant4.First_Name__c = 'Fourth';
        bookC1.applicant4.Middle_Name__c = 'Young';
        bookC1.applicant4.Last_Name__c = 'Man';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.DOB__c = system.today();
        bookC1.applicant4.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant4.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant4.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Pincode__c = 444444;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= 'Maharashtra';
        bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        bookC1.applicant4.Mobile_Number__c = '9090909000';
        bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant4.Nationality_Picklist__c = 'Indian';
        bookC1.applicant4.Marital_Status__c = 'Married';
        bookC1.applicant4.Gender__c= 'Male';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PassportNumber__c = true;
        bookC1.applicant4.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant4.Address_Proof__c = true;
        bookC1.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant4.PancardNo__c = '1234567891';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant4.Type_Of_Origin__c = 'abc';
        bookC1.applicant4.Origin_Details__c = 'India';
        bookC1.addressCheckApplicant4 = true;
        bookC1.applicant4.Mailing_City__c= 'Pune';
        bookC1.boookingObj.Opportunity__c = objcustomer.id;
        bookC1.save();
        
        bookC1.applicant5.Salutation__c = 'Mr.';
        bookC1.applicant5.First_Name__c = 'Fifth';
        bookC1.applicant5.Middle_Name__c = 'Young';
        bookC1.applicant5.Last_Name__c = 'Man';        
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';
        bookC1.applicant5.DOB__c = system.today();
        bookC1.applicant5.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant5.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant5.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant5.Pincode__c = 444444;
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.State__c= 'Maharashtra';
        bookC1.applicant5.City__c = 'Nagpur';
        bookC1.applicant5.Mailing_Country__c= 'India';
        bookC1.applicant5.Mobile_Number__c = '9090909000';
        bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Nationality_Picklist__c = 'Indian';
        bookC1.applicant5.Marital_Status__c = 'Married';
        bookC1.applicant5.Gender__c= 'Male';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PassportNumber__c = true;
        bookC1.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant5.Address_Proof__c = true;
        bookC1.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant5.PancardNo__c = '1234567890';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant5.Address_Proof_Document__c = 'Aadhar Card';
        bookC1.applicant5.Address_Proof_Number__c  = '121212457812';
        bookC1.addressCheckApplicant5 = true;
        bookC1.save(); */
        
      
       // Test.startTest();
     //   bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
       // bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        //bookC1.save();
       /* bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Fourth Man';
        bookC1.save();*/
          
   }
    
    @isTest
    private static void BookingTest33() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objCustomer.RW_Type_of_Client__c = 'Local';
        objCustomer.Walkin_Source__c = 'Direct';
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Agreement_Value_for_brokers__c = 100000;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        q2.Agreement_Value_for_brokers__c = 1000000;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
    
        
        
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
        insert r2;
           
    
        
        
         
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'NRI';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
        
       
        
        
   Test.startTest();
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Type_of_Client__c = 'Local';
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save();
        bookC1.boookingObj.Type_of_Client__c = 'NRI'; 
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save(); 
        //bookC1.dummyMethod();
        bookC1.Cancel();        
        
        bookC1.applicant4.Mailing_Country__c = 'India';
        bookC1.applicant4.Mailing_Pincode__c= 7894563;
        bookC1.applicant4.Mailing_State__c = null;
        bookC1.applicant4.Mailing_City__c= null;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= null;
        bookC1.applicant4.Pincode__c = 4578963;
        bookC1.save();
        bookC1.applicant4.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant4.Pincode__c = null;
        bookC1.applicant4.Country__c = null;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = null;
        bookC1.save();
        
         PageReference pRef2 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('optyId','');
        ApexPages.currentPage().getParameters().put('unitId','');
        ApexPages.currentPage().getParameters().put('projectId','');
        BookingClass bookC2 = new BookingClass();
        bookC2.i = 0;
        List < SelectOption > sq2= bookC2.getQuote;
        bookC2.selectedQuote = q.Id;
        bookC2.receiptlist.add(r1);
        //bookC2.getTokenAmount();
        bookC2.getReceiptDetails();
        bookC2.addReciept();
        //bookC2.deleteReciept();
        bookC2.getaddressstatus();
        bookC2.boookingObj.Application_No__c = '1234';   
        bookC2.boookingObj.Sales_Managers__c = '';
        bookC2.boookingObj.Sourcing_Mananger__c= '';
        bookC2.boookingObj.Sourcing_Mananger__c= null;
        
        bookC2.applicant.First_Name__c = null;
        bookC2.applicant.Salutation__c = null;
        bookC2.applicant.Last_Name__c = null;
        bookC2.applicant.Pincode__c = 123446;
     //   bookC2.save();     
        //bookC2.dummyMethod();
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.First_Name__c = 'New';
        bookC1.applicant.Middle_Name__c = 'Young';
        bookC1.applicant.Last_Name__c = 'Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 444444;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.state__c = 'Maharashtra';
        bookC1.applicant.City__c = 'Nagpur';
        bookC1.applicant.Mailing_Country__c= 'India';
        bookC1.applicant.Mobile_Number__c = '9090909000';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Nationality_Picklist__c = 'Indian';
        bookC1.applicant.Marital_Status__c = 'Married';
        bookC1.applicant.Gender__c= 'Male';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.Address_Proof__c = true;
        bookC1.applicant.Address_Proof_Document__c = 'abc';
        bookC1.applicant.Address_Proof_Number__c = 'pqr';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheck = true; 
        
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Salutation__c = 'Mr.';
        bookC1.applicant2.First_Name__c = 'Second';
        bookC1.applicant2.Middle_Name__c = 'Old';
        bookC1.applicant2.Last_Name__c = 'Man';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant2.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant2.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Pincode__c = 444444;
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.State__c= 'Maharashtra';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mailing_Pincode__c= null;
        bookC1.applicant2.Mobile_Number__c = '9090909000';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Nationality_Picklist__c = 'Indian';
        bookC1.applicant2.Marital_Status__c = 'Married';
        bookC1.applicant2.Gender__c= 'Male';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.Address_Proof__c = true;
        bookC1.applicant2.Address_Proof_Document__c = 'xyz';
        bookC1.applicant2.Address_Proof_Number__c = 'pqr';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant2 = true;
        //bookC1.save();
        //bookC1.dummyMethod();

        /*bookC1.applicant3.Name ='Third Man';
        bookC1.save();
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();*/
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Salutation__c = 'Mr.';
        bookC1.applicant3.First_Name__c = 'Third';
        bookC1.applicant3.Middle_Name__c = 'Young';
        bookC1.applicant3.Last_Name__c = 'Man';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant3.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant3.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Pincode__c = 444444;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.State__c = 'Maharashtra';
        bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        bookC1.applicant3.Mobile_Number__c = '9090909000';
        bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant3.Nationality_Picklist__c = 'Indian';
        bookC1.applicant3.Marital_Status__c = 'Married';
        bookC1.applicant3.Gender__c= 'Male';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.Pancard__c = true;
        bookC1.applicant3.PassportNumber__c = true;
        bookC1.applicant3.Funds_from_NRE_NRO__c = true;
        bookC1.applicant3.Address_Proof__c = true;
        bookC1.applicant3.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant3.PancardNo__c = '1234567890';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant3 = true;
        //bookC1.save();
        
        bookC1.applicant4.Salutation__c = 'Mr.';
        bookC1.applicant4.First_Name__c = 'Fourth';
        bookC1.applicant4.Middle_Name__c = 'Young';
        bookC1.applicant4.Last_Name__c = 'Man';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        bookC1.applicant4.DOB__c = system.today();
        bookC1.applicant4.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant4.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant4.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Pincode__c = 444444;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= 'Maharashtra';
        bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        bookC1.applicant4.Mobile_Number__c = '9090909000';
        bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant4.Nationality_Picklist__c = 'Indian';
        bookC1.applicant4.Marital_Status__c = 'Married';
        bookC1.applicant4.Gender__c= 'Male';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PassportNumber__c = true;
        bookC1.applicant4.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant4.Address_Proof__c = true;
        bookC1.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant4.PancardNo__c = '1234567891';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant4.Type_Of_Origin__c = 'abc';
        bookC1.applicant4.Origin_Details__c = 'India';
        bookC1.addressCheckApplicant4 = true;
        bookC1.applicant4.Mailing_City__c= 'Pune';
        bookC1.boookingObj.Opportunity__c = objcustomer.id;
        //bookC1.save();
        
        bookC1.applicant5.Salutation__c = 'Mr.';
        bookC1.applicant5.First_Name__c = 'Fifth';
        bookC1.applicant5.Middle_Name__c = 'Young';
        bookC1.applicant5.Last_Name__c = 'Man';        
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';
        bookC1.applicant5.DOB__c = system.today();
        bookC1.applicant5.Permanent_Address_Line_1__c = 'Pike Street';
        bookC1.applicant5.Permanent_Address_Line_2__c = 'New World';
        bookC1.applicant5.Permanent_Address_Line_3__c = '45000';
        bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant5.Pincode__c = 444444;
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.State__c= 'Maharashtra';
        bookC1.applicant5.City__c = 'Nagpur';
        bookC1.applicant5.Mailing_Country__c= 'India';
        bookC1.applicant5.Mobile_Number__c = '9090909000';
        bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Nationality_Picklist__c = 'Indian';
        bookC1.applicant5.Marital_Status__c = 'Married';
        bookC1.applicant5.Gender__c= 'Male';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.Pancard__c = true;
        bookC1.applicant5.PassportNumber__c = true;
        bookC1.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant5.Address_Proof__c = true;
        bookC1.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant5.PancardNo__c = '1234567890';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c = true;
        bookC1.applicant5.Address_Proof_Document__c = 'Aadhar Card';
        bookC1.applicant5.Address_Proof_Number__c  = '121212457812';
        bookC1.addressCheckApplicant5 = true;
        //bookC1.save();

         bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant.Pancard__c = true;
        bookC1.applicant.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant.Mailing_Country__c = 'India';
        bookC1.applicant.Mailing_Pincode__c= 7894563;
        bookC1.applicant.Mailing_State__c = null;
        bookC1.save();      
        bookC1.applicant2.First_Name__c = 'Second';
        bookC1.applicant2.Salutation__c = null;
        bookC1.applicant2.Last_Name__c = null;
        bookC1.applicant2.Pincode__c = null;
        bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c= '123456789';
        bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.State__c= null;
        bookC1.applicant2.Pincode__c = 4578963;
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        test.stopTest();
    }
    
    
    
    @isTest
    private static void BookingTest3() {
        UserRole obj=new UserRole(Name= 'ABC'); 
                                           insert obj;
            
            Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

              /*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
              insert u;*/
        
        String orgId1 = UserInfo.getOrganizationId();
    String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName1 = orgId1 + dateString1 + randomInt1;
    User tuser1 = new User(  firstname = 'TestUser',
                            lastName = 'TestUser',
                            email = 'ishumittal5' + '@gmail' +'.com',
                            Username = uniqueName1 + '@test' + orgId1 + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName1.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p1.id,
                            UserRoleId = obj.Id,
                           isActive=true
                            );
        insert tuser1;
        
    System.debug('objBooking1.OwnerId***'+tuser1.id);
    System.runAs(tuser1){  Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
    Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
         Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
         Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
         opp.Applicant_Name__c='XYZ';
                         opp.RW_Sales_Associate__c='A Aastha Tripathi';
        insert opp;
       Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
   

         Receipt__c receipt1 = new Receipt__c();
       /*  Booking__c bk = [Select id,Name from Booking__c Limit 1];
          Opportunity oppRec = [Select id,Primary_Name__c,Name from Opportunity Limit 1];*/
        
            Booking__c  objBooking1=new Booking__c();
   // objBooking.Primary_Applicant_Name__c='ABC';
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
                        objBooking1.Future_Correspondence_Contact__c = 'Other';
        System.debug('tuser1'+tuser1);
        objBooking1.OwnerId=tuser1.id;
                            
        
        System.debug('objBooking1.OwnerId' +objBooking1.OwnerId  + objBooking1.Owner.Email);
            insert objBooking1;
       Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        insert teamMembers;
        
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=opp.id;
        eoiRecord.Tower__c = towerRecords[0].id;
        
eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.OwnerId=tuser1.id;
        insert eoiRecord;
       Booking__c bk= [Select id from Booking__c where id=:objBooking1.id];
        receipt1.Opportunity__c=opp.id;
        receipt1.Booking__c=bk.Id;
         receipt1.Payment_Gateway__c = 'BillDesk';
         receipt1.Receipt_Status__c = 'Success';
         receipt1.RW_Payment_Collection_Type__c = 'Customer Portal - Flat Cost';
         receipt1.Amount_Rs__c=500000.00;
        receipt1.Total_Amount__c=999999;
         receipt1.Cheque_DD__c='U1237062533345';
         receipt1.Mode__c='Digital';
         receipt1.Receipt_Date__c = system.today();
          insert receipt1;
        //testing ending for customer Portal
        //
       
       Receipt__c receipt2 = new Receipt__c();
         receipt2.Opportunity__c=opp.id;
        receipt2.Booking__c=bk.Id;
        receipt2.EOI__c=eoiRecord.id;
		receipt2.RW_Payment_Refunded__c=true;
         receipt2.Payment_Gateway__c = 'BillDesk';
         receipt2.Receipt_Status__c = 'Success';
         receipt2.RW_Payment_Collection_Type__c = 'EOI';
         receipt2.Amount_Rs__c=500000.00;
        receipt2.Total_Amount__c=999999;
         receipt2.Cheque_DD__c='U1237062533345';
         receipt2.Mode__c='Digital';
         receipt2.Receipt_Date__c = system.today();
                    
                         receipt2.Cheque_DD_Date__c=system.today();
                         //insert receipt2;
      Receipt__c receipt3 = new Receipt__c();
         receipt3.Opportunity__c=opp.id;
        receipt3.Booking__c=bk.Id;
        receipt3.EOI__c=eoiRecord.id;
                         receipt3.RW_Payment_Refunded__c=true;
         receipt3.Payment_Gateway__c = 'BillDesk';
         receipt3.Receipt_Status__c = 'Success';
         receipt3.RW_Payment_Collection_Type__c = 'Booking';
         receipt3.Cheque_DD_Date__c=system.today();
         receipt3.Amount_Rs__c=500000.00;
        receipt3.Total_Amount__c=999999;
         receipt3.Cheque_DD__c='U1237062533345';
         receipt3.Mode__c='Digital';
         receipt3.Receipt_Date__c = system.today();
          insert receipt3;
                        
         Receipt__c receipt4 = new Receipt__c();
         receipt4.Opportunity__c=opp.id;
        receipt4.Booking__c=bk.Id;
        receipt4.EOI__c=eoiRecord.id;
         receipt4.Payment_Gateway__c = 'BillDesk';
         receipt4.Receipt_Status__c = 'Success';
         receipt4.RW_Payment_Collection_Type__c = 'SAP Demands';
         receipt4.Cheque_DD_Date__c=system.today();
         receipt4.Amount_Rs__c=500000.00;
        receipt4.Total_Amount__c=999999;
         receipt4.Cheque_DD__c='U1237062533345';
         receipt4.Mode__c='Digital';
         receipt4.Receipt_Date__c = system.today();
                         insert receipt4;}
      
    }
    @isTest
    private static void BookingTest4() {
         
      Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
    Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
         Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
         Broker__c objBroker = new Broker__c();
            objBroker.Broker_Pan_No__c = 'ABCDF34526';
            objBroker.Name = 'Testcp2';
            objBroker.RW_Email__c = 'testcp4@stetig.in';
            objBroker.Dialing_Country1__c = 'India';
            objBroker.Dialing_Country_Code1__c = '+91';
            objBroker.RW_Mobile_No__c = '1112288888';
            objBroker.Unregistered_Channel_Partner__c = true;
        objBroker.SAP_CP_Code__c = 'Test';
        Insert objBroker;      
         Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
        opp.Applicant_Name__c='XYZ';
        opp.Walkin_Source__c = 'Channel Partner';
        opp.RW_Walkin_Channel_Partner__c = objBroker.id;
        insert opp;
        
        Id AopRecordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('AOP').getRecordTypeId();
        
        AOP__c aop = new AOP__c();
        aop.Start_Date__c = system.today();
        aop.End_Date__c = system.today();
        aop.Category__c = 'Diamond';
        aop.Channel_Partner__c = objBroker.Id;
        aop.RecordTypeId = AopRecordTypeId;
        insert aop;  
        Tower__c t2 = new Tower__c();
        t2.ProjectName__c = objpr.id;
        t2.Name = 'A';
        t2.RW_Terms_And_Conditions__c ='TC';
        insert t2;
        
       Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.TowerName__c = t2.id;
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
   

         Receipt__c receipt1 = new Receipt__c();
 
    Booking__c  objBooking1=new Booking__c();
      
   // objBooking.Primary_Applicant_Name__c='ABC';
        
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
       insert objBooking1;
        
        
            
         Test.startTest();
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;

        
        Test.stopTest();          
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
            
        
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        
    
        insert teamMembers;
        
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
  
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.Total_Amount_Received__c=40000;
      
        
        insert eoiRecord;
       Booking__c bk= [Select id from Booking__c where id=:objBooking1.id];
     /*     Receipt__c receipt5 = new Receipt__c();
         receipt5.Opportunity__c=opp.id;
        receipt5.Booking__c=bk.Id;
       // receipt5.EOI__c=eoiRecord.id;
        receipt5.Payment_Gateway__c='xyz';
         receipt5.Receipt_Status__c = 'Success';
         receipt5.RW_Payment_Collection_Type__c = 'Booking';
         receipt5.Amount_Rs__c=500000.00;
        receipt5.Total_Amount__c=999999;
         receipt5.Cheque_DD__c='U1237062533345';
         receipt5.Mode__c='Digital';
         receipt5.Receipt_Date__c = system.today();
          insert receipt5;*/
          Receipt__c receipt6 = new Receipt__c();
         receipt6.Opportunity__c=opp.id;
        receipt6.Booking__c=bk.Id;
        receipt6.EOI__c=eoiRecord.id;
        receipt6.Payment_Gateway__c='xyz';
         receipt6.Receipt_Status__c = 'Success';
         receipt6.RW_Payment_Collection_Type__c = 'EOI';
         receipt6.Amount_Rs__c=500000.00;
        receipt6.Total_Amount__c=999999;
        
         receipt6.Cheque_DD__c='U1237062533345';
         receipt6.Mode__c='Digital';
         receipt6.Receipt_Date__c = system.today();
          insert receipt6;
       
     }
    /*    @isTest
    private static void BookingTest5() {
         
      Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
    Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
         Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
         Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
         opp.Applicant_Name__c='XYZ';
        insert opp;
       Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
   

         Receipt__c receipt1 = new Receipt__c();
 
    Booking__c  objBooking1=new Booking__c();
      
   // objBooking.Primary_Applicant_Name__c='ABC';
        
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
       
        
        
            insert objBooking1;
       Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
            
        
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        
    
        insert teamMembers;
        
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
  
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
      
        
        insert eoiRecord;
       Booking__c bk= [Select id from Booking__c where id=:objBooking1.id];
     
          Receipt__c receipt6 = new Receipt__c();
         receipt6.Opportunity__c=opp.id;
        receipt6.Booking__c=bk.Id;
        receipt6.EOI__c=eoiRecord.id;
        receipt6.Payment_Gateway__c='xyz';
        
         receipt6.RW_Payment_Collection_Type__c = 'Booking';
         receipt6.Amount_Rs__c=500000.00;
        receipt6.Total_Amount__c=999999;
         receipt6.Cheque_DD__c='U1237062533345';
         receipt6.Mode__c='Digital';
         receipt6.Receipt_Date__c = system.today();
          insert receipt6;
       
     }*/
    @isTest
    private static void BookingTest6() {
        UserRole obj=new UserRole(Name= 'ABC'); 
                                           insert obj;
            
            Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

              /*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
              insert u;*/
        
        String orgId1 = UserInfo.getOrganizationId();
    String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName1 = orgId1 + dateString1 + randomInt1;
    User tuser1 = new User(  firstname = 'TestUser',
                            lastName = 'TestUser',
                            email = 'ishumittal5' + '@gmail' +'.com',
                            Username = uniqueName1 + '@test' + orgId1 + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName1.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p1.id,
                            UserRoleId = obj.Id,
                           isActive=true
                            );
        insert tuser1;
        
    System.debug('objBooking1.OwnerId***'+tuser1.id);
    System.runAs(tuser1){  Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
    Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
         Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
         Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
         opp.Applicant_Name__c='XYZ';
                         opp.RW_Sales_Associate__c='A Aastha Tripathi';
        insert opp;
       Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
   

         Receipt__c receipt1 = new Receipt__c();
       /*  Booking__c bk = [Select id,Name from Booking__c Limit 1];
          Opportunity oppRec = [Select id,Primary_Name__c,Name from Opportunity Limit 1];*/
        
            Booking__c  objBooking1=new Booking__c();
   // objBooking.Primary_Applicant_Name__c='ABC';
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
        System.debug('tuser1'+tuser1);
        objBooking1.OwnerId=tuser1.id;
                            
        
        System.debug('objBooking1.OwnerId' +objBooking1.OwnerId  + objBooking1.Owner.Email);
            insert objBooking1;
       Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        insert teamMembers;
        
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=opp.id;
        eoiRecord.Tower__c = towerRecords[0].id;
        
eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.OwnerId=tuser1.id;
        insert eoiRecord;
       Booking__c bk= [Select id from Booking__c where id=:objBooking1.id];
       
       Receipt__c receipt2 = new Receipt__c();
         receipt2.Opportunity__c=opp.id;
        receipt2.Booking__c=bk.Id;
        receipt2.EOI__c=eoiRecord.id;
                         receipt2.RW_Payment_Refunded__c=true;
     
         receipt2.Receipt_Status__c = 'Success';
         receipt2.RW_Payment_Collection_Type__c = 'EOI';
         receipt2.Amount_Rs__c=500000.00;
        receipt2.Total_Amount__c=999999;
         receipt2.Cheque_DD__c='U1237062533345';
         receipt2.Mode__c='Digital';
         receipt2.Receipt_Date__c = system.today();
                        receipt2.DraweeBank__c='Axis Bank';
                         receipt2.Cheque_DD_Date__c=system.today();
                         insert receipt2;
                         receipt2.Physically_Cheque_Received__c=True;
                         update receipt2;

    }
      
    }
    
    @isTest
    private static void CPPortal() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
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
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Agreement_Value_for_brokers__c = 100000;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        q2.Agreement_Value_for_brokers__c = 1000000;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
    
        
        
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
        insert r2;
           
    
        
        
         
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
        
       
        
        
   
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
       /* BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Type_of_Client__c = 'Local';
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save();
        bookC1.boookingObj.Type_of_Client__c = 'NRI'; 
        bookC1.boookingObj.Passback_Amount__c = 45245;        
        bookC1.Save();        
        bookC1.dummyMethod();*/

          
   }
    @isTest
    private static void CPPortal2() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
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
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Agreement_Value_for_brokers__c = 100000;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        q2.Agreement_Value_for_brokers__c = 1000000;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
    
        
        
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
        insert r2;
           
    
        
        
         
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Local';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
        
       
        
        
   
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        /*BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Type_of_Client__c = 'Local';
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save();
        bookC1.boookingObj.Type_of_Client__c = 'NRI'; 
        bookC1.boookingObj.Passback_Amount__c = 45245;
       bookC1.dummyMethod();

        bookC1.Save();    */    
          
   }
    @isTest
    private static void CPPortal3() {
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        insert objCP3;
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        insert objCP4;
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objCustomer.RW_Type_of_Client__c = 'Local';
        objCustomer.Walkin_Source__c = 'Direct';
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
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
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Agreement_Value_for_brokers__c = 100000;
        insert q;
        
        Quotation__c q2 = new Quotation__c();
        q2.Name = 'Q020202';
        q2.Quote_Status__c = 'Approval Pending';
        q2.Prepared_Date__c = System.today();
        q2.Project__c = objpr.Id;
        q2.Project_Unit__c = objPUU1.Id;
        q2.FloorNo__c = 11;
        q2.Opportunity__c = objcustomer1.Id;
        q2.Appartment_Configuration__c = '1 BHK';
        q2.Carpet_Area_Sq_Ft__c = 1200;
        q2.Token_Amount__c =110000;
        q2.ST_Token_Amount__c = 1000;
        q2.Allow_booking_without_full_token__c = TRUE;
        q2.Agreement_Value__c = 60422880;
        q2.Agreement_Value_ST__c = 2537761;
        q2.Tandem_car_park_Additional__c = 0;
        q2.Tandem_Open_Additional__c= 0;
        q2.Single_car_park_Additional__c= 0;
        q2.Single_Open_Additional__c = 0;
        q2.Stack_Additional__c = 0;
        q2.Agreement_Value_for_brokers__c = 1000000;
        //q2.Service_Tax_On_Token_Amount__c = true;
        insert q2;
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        insert r1;
    
        
        
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
        insert r2;
           
    
        
        
         
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'NRI';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        insert bscheme;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
        
       
        
        
   Test.startTest();
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.boookingObj.Type_of_Client__c = 'Local';
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save();
        bookC1.boookingObj.Type_of_Client__c = 'NRI'; 
        bookC1.boookingObj.Passback_Amount__c = 45245;
        bookC1.Save(); 
        //bookC1.dummyMethod();
        bookC1.Cancel();        
        
        bookC1.applicant4.Mailing_Country__c = 'India';
        bookC1.applicant4.Mailing_Pincode__c= 7894563;
        bookC1.applicant4.Mailing_State__c = null;
        bookC1.applicant4.Mailing_City__c= null;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c= false;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PancardNo__c = '12345678'; 
        bookC1.save();
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.State__c= null;
        bookC1.applicant4.Pincode__c = 4578963;
        bookC1.save();
        bookC1.applicant4.Mobile_Number__c = '123456';
        bookC1.save();
        bookC1.applicant4.Pincode__c = null;
        bookC1.applicant4.Country__c = null;
        bookC1.save();
        bookC1.applicant4.Subtype_Of_Applicant__c = null;
        bookC1.save();
        
         PageReference pRef2 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('optyId','');
        ApexPages.currentPage().getParameters().put('unitId','');
        ApexPages.currentPage().getParameters().put('projectId','');
        BookingClass bookC2 = new BookingClass();
        bookC2.i = 0;
        List < SelectOption > sq2= bookC2.getQuote;
        bookC2.selectedQuote = q.Id;
        bookC2.receiptlist.add(r1);
        //bookC2.getTokenAmount();
        bookC2.getReceiptDetails();
        bookC2.addReciept();
        //bookC2.deleteReciept();
        bookC2.getaddressstatus();
        bookC2.boookingObj.Application_No__c = '1234';   
        bookC2.boookingObj.Sales_Managers__c = '';
        bookC2.boookingObj.Sourcing_Mananger__c= '';
        bookC2.boookingObj.Sourcing_Mananger__c= null;
        
        bookC2.applicant.First_Name__c = null;
        bookC2.applicant.Salutation__c = null;
        bookC2.applicant.Last_Name__c = null;
        bookC2.applicant.Pincode__c = 123446;
     //   bookC2.save();     
        //bookC2.dummyMethod();
		Test.stopTest();
   }
 
}