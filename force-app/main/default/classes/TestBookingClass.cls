@isTest
private  Class TestBookingClass {
 
 
 @isTest
    private static void BookingTest() {
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
        objpr.Name = 'Runwal Bliss';
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
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'MLCP';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Project_Charges__c prc = new Project_Charges__c();
        prc.Name = 'Basic';
        prc.Project__c = objpr.Id;
        insert prc;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
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
        q.MLCP_Additional__c = null;
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
        q2.MLCP_Additional__c = null;
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
        r1.Currency__c = 'Indian Rupee';
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
        bookC1.boookingObj.Application_No__c = '1234';   
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';    
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
     
        // applicant1 to required fields validation simulation
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
        
        
        // applicant2 to required fields validation simulation
        bookC1.applicant2.Name = 'Second Man';
        bookC1.applicant2.Applicant_Number__c = 'Second Applicant';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Pincode__c = 444444;
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.City__c = 'Nagpur';
        bookC1.applicant2.Mailing_Country__c= null;
        bookC1.applicant2.Mailing_Pincode__c= null;
        bookC1.applicant2.Mobile_Number__c = '909090900';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.Pancard__c = true;
        bookC1.applicant2.Address_Proof__c = true;
        bookC1.applicant2.Address_Proof_Document__c = 'xyz';
        bookC1.applicant2.Address_Proof_Number__c = 'pqr';
        bookC1.applicant2.One_Passport_Size_Color_Photograph__c = true;
        bookC1.addressCheckApplicant2 = true;
        bookC1.save();
        /*bookC1.applicant3.Name ='Third Man';
        bookC1.save();
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();*/
        
        // applicant3 to required fields validation simulation
        bookC1.applicant3.Name = 'Third Man';
        bookC1.applicant3.Applicant_Number__c = 'Third Applicant';
        //bookC1.applicant3.DOB__c = system.today();
        //bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Pincode__c = 44444489;
        bookC1.applicant3.Country__c = 'India';
        //bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        //bookC1.applicant3.Mobile_Number__c = '909090900';
        //bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant3.Nationality__c = 'Indian';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.Pancard__c = false;
        bookC1.applicant3.PassportNumber__c = false;
        bookC1.applicant3.Funds_from_NRE_NRO__c = false;
        bookC1.applicant3.Address_Proof__c = true;
        bookC1.applicant3.Copy_of_Workpermit_Employment_contract__c = false;
        bookC1.applicant3.PancardNo__c = '123456789102';
        bookC1.applicant3.One_Passport_Size_Color_Photograph__c = false;
        bookC1.addressCheckApplicant3 = false;
        bookC1.save();
        
        
        bookC1.applicant4.Name ='Fourth Man';
        bookC1.applicant4.Applicant_Number__c = 'Fourth Applicant';
        //bookC1.applicant4.DOB__c = system.today();
        //bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Pincode__c = 44444478;
        bookC1.applicant4.Country__c = 'India';
        //bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        //bookC1.applicant4.Mobile_Number__c = '909090900';
        //bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant4.Nationality__c = 'Indian';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.Pancard__c = true;
        bookC1.applicant4.PassportNumber__c = true;
        bookC1.applicant4.Funds_from_NRE_FCNR__c= false;
        bookC1.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c = false;
        bookC1.applicant4.Address_Proof__c = true;
        bookC1.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant4.PancardNo__c = '1234567891';
        bookC1.applicant4.One_Passport_Size_Color_Photograph__c = false;
        bookC1.applicant4.Type_Of_Origin__c = '';
        bookC1.applicant4.Origin_Details__c = '';
        bookC1.addressCheckApplicant4 = false;
        bookC1.save();
        
        bookC1.applicant5.Name ='Fifth Man';
        bookC1.applicant5.Applicant_Number__c = 'Fifth Applicant';
        //bookC1.applicant5.DOB__c = system.today();
        //bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant5.Pincode__c = 44444454;
        bookC1.applicant5.Country__c = 'India';
        //bookC1.applicant5.City__c = 'Nagpur';
        //bookC1.applicant5.Mailing_Country__c= 'India';
        //bookC1.applicant5.Mobile_Number__c = '909090900';
        //bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Nationality__c = 'Indian';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.Pancard__c = false;
        bookC1.applicant5.PassportNumber__c = true;
        bookC1.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC1.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC1.applicant5.Address_Proof__c = false;
        bookC1.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC1.applicant5.PancardNo__c = '';
        bookC1.applicant5.One_Passport_Size_Color_Photograph__c = false;
        bookC1.applicant5.Address_Proof_Document__c = '';
        bookC1.applicant5.Address_Proof_Number__c  = '';
        bookC1.addressCheckApplicant5 = false;
        bookC1.save();
        
      
        Test.startTest();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
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
        bookC1.save();
        Test.stopTest();
        
        PageReference pRef2 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef2);
         BookingClass bookC2 = new BookingClass();
        List < SelectOption > sq2= bookC2.getQuote;
        bookC2.selectedQuote = q.Id;
        bookC2.receiptlist.add(r2);
      
        bookC2.getTokenAmount();
        bookC2.getReceiptDetails();
        
        bookC2.addReciept();
        bookC2.save();
        
        PageReference pRef3 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef3);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
         BookingClass bookC3 = new BookingClass();
        List < SelectOption > sq3= bookC3.getQuote;
        bookC3.selectedQuote = q.Id;
        bookC3.receiptlist.add(r2);
      
        bookC3.getTokenAmount();
        bookC3.getReceiptDetails();
        
        bookC3.addReciept();
        bookC3.save();
        
        PageReference pRef11 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef11);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC11 = new BookingClass();
        bookC11.i = 0;
        List < SelectOption > sq11= bookC11.getQuote;
        bookC11.selectedQuote = q.Id;
        bookC11.receiptlist.add(r1);
        bookC11.getTokenAmount();
        bookC11.getReceiptDetails();
        bookC11.addReciept();
        bookC11.boookingObj.Application_No__c = '123456';   
        bookC11.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';    
        bookC11.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC11.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
     
        // applicant1 to required fields validation simulation
        //bookC1.applicant.Salutation__c = 'Mr.';
        bookC11.applicant.Name = 'New Man';
        //bookC1.applicant.DOB__c = system.today();
        //bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant.Pincode__c = 444444;
        //bookC1.applicant.Country__c = 'India';
        //bookC1.applicant.City__c = 'Nagpur';
        //bookC1.applicant.Mailing_Country__c= 'India';
        //bookC1.applicant.Mobile_Number__c = '909090900';
        //bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant.Nationality__c = 'Indian';
        //bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC11.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC11.applicant.Pancard__c = false;
        bookC11.applicant.PanCard_of_Authority_Signatory__c = false;
        bookC11.applicant.Certified_copy_of_Partnership_Deed__c = false;
        bookC11.applicant.Copy_of_Authorization_Letter_POA__c  = false;
        bookC11.applicant.Certified_extract_of_Registration__c = false;
        bookC11.applicant.PancardNo__c = '12345678910';
        bookC11.applicant.Mailing_Country__c= 'India';
        bookC11.applicant.Mailing_Pincode__c = 123456789;
        bookC11.applicant.Mailing_State__c = null;
        bookC11.addressCheck = false;
        bookC11.save();
        
        // applicant2 to required fields validation simulation
        bookC11.applicant2.Name = 'Second Man';
        bookC11.applicant2.Applicant_Number__c = 'Second Applicant';
        //bookC1.applicant2.DOB__c = system.today();
        //bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant2.Pincode__c = 444444;
        //bookC1.applicant2.Country__c = 'India';
        //bookC1.applicant2.City__c = 'Nagpur';
        //bookC1.applicant2.Mailing_Country__c= 'India';
        //bookC1.applicant2.Mobile_Number__c = '909090900';
        //bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant2.Nationality__c = 'Indian';
        //bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC11.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC11.applicant2.Pancard__c = false;
        bookC11.applicant2.PanCard_of_Authority_Signatory__c = false;
        bookC11.applicant2.Certified_copy_of_Partnership_Deed__c = false;
        bookC11.applicant2.Certified_extract_of_Registration__c = false;
        bookC11.applicant2.Copy_of_Authorization_Letter_POA__c = false;
        bookC11.applicant2.Address_Proof__c = false;
        bookC11.applicant2.Address_Proof_Document__c = '';
        bookC11.applicant2.Address_Proof_Number__c = '';
        bookC11.applicant2.One_Passport_Size_Color_Photograph__c = false;
        bookC11.applicant2.Mailing_Country__c= 'India';
        bookC11.applicant2.Mailing_Pincode__c = 1559966;
        bookC11.applicant2.Mailing_State__c = null;
        bookC11.applicant2.PancardNo__c = '12345678922';
        bookC11.addressCheckApplicant2 = false;
        bookC11.save();
        /*bookC1.applicant3.Name ='Third Man';
        bookC1.save();
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();*/
        
        // applicant3 to required fields validation simulation
        bookC11.applicant3.Name = 'Third Man';
        bookC11.applicant3.Applicant_Number__c = 'Third Applicant';
        //bookC1.applicant3.DOB__c = system.today();
        //bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant3.Pincode__c = 444444;
        //bookC1.applicant3.Country__c = 'India';
        //bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        //bookC1.applicant3.Mobile_Number__c = '909090900';
        //bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant3.Nationality__c = 'Indian';
        //bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC11.applicant3.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC11.applicant3.Pancard__c = false;
        bookC11.applicant3.PassportNumber__c = true;
        bookC11.applicant3.Funds_from_NRE_NRO__c = true;
        bookC11.applicant3.Address_Proof__c = true;
        bookC11.applicant3.Copy_of_Workpermit_Employment_contract__c = true;
        bookC11.applicant3.PancardNo__c = '123456789123';
        bookC11.applicant3.One_Passport_Size_Color_Photograph__c = true;
        bookC11.applicant3.PanCard_of_Authority_Signatory__c = false;
        bookC11.applicant3.Certified_copy_of_Partnership_Deed__c = false;
        bookC11.applicant3.Certified_extract_of_Registration__c = false;
        bookC11.applicant3.Copy_of_Authorization_Letter_POA__c = false;
        bookC11.applicant3.Mailing_Country__c= 'India';
        bookC11.applicant3.Mailing_Pincode__c = null;
        bookC11.applicant3.Mailing_State__c = null;
        bookC11.addressCheckApplicant3 = false;
        bookC11.save();
        
        
        bookC11.applicant4.Name ='Fourth Man';
        bookC11.applicant4.Applicant_Number__c = 'Fourth Applicant';
        //bookC1.applicant4.DOB__c = system.today();
        //bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant4.Pincode__c = 44444478;
        //bookC1.applicant4.Country__c = 'India';
        //bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        //bookC1.applicant4.Mobile_Number__c = '909090900';
        //bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant4.Nationality__c = 'Indian';
        //bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC11.applicant4.Subtype_Of_Applicant__c = 'Indian National';
        bookC11.applicant4.Pancard__c = false;
        bookC11.applicant4.PassportNumber__c = true;
        bookC11.applicant4.Funds_from_NRE_FCNR__c= true;
        bookC11.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC11.applicant4.Address_Proof__c = false;
        bookC11.applicant4.Address_Proof_Document__c = '';
        bookC11.applicant4.Address_Proof_Number__c = '';
        bookC11.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC11.applicant4.PancardNo__c = '12345678910';
        bookC11.applicant4.One_Passport_Size_Color_Photograph__c = false;
        bookC11.applicant4.Mailing_Country__c= 'India';
        bookC11.applicant4.Mailing_Pincode__c = null;
        //bookC1.addressCheckApplicant3 = true;
        //bookC1.save();
        bookC11.addressCheckApplicant4 = false;
        bookC11.save();
        
        bookC11.applicant5.Name ='Fifth Man';
        bookC11.applicant5.Applicant_Number__c = 'Fifth Applicant';
        //bookC1.applicant5.DOB__c = system.today();
        //bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC11.applicant5.Pincode__c = 44444454;
        //bookC11.applicant5.Country__c = 'India';
        //bookC1.applicant5.City__c = 'Nagpur';
        //bookC1.applicant5.Mailing_Country__c= 'India';
        //bookC1.applicant5.Mobile_Number__c = '909090900';
        //bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        //bookC11.applicant5.Nationality__c = 'Indian';
        //bookC11.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC11.applicant5.Subtype_Of_Applicant__c = 'For Company';
        bookC11.applicant5.Pancard__c = false;
        bookC11.applicant5.PassportNumber__c = true;
        bookC11.applicant5.Funds_from_NRE_FCNR__c= true;
        bookC11.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c = true;
        bookC11.applicant5.Address_Proof__c = true;
        bookC11.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC11.applicant5.PancardNo__c = '';
        bookC11.applicant5.One_Passport_Size_Color_Photograph__c = true;
        bookC11.applicant4.Mailing_Country__c= 'India';
        bookC11.applicant4.Mailing_Pincode__c = null;
        bookC11.addressCheckApplicant5 = false;
        bookC11.save();
        
      
        //Test.startTest();
        /*bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();*/
        bookC11.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC11.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC11.save();
        bookC11.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC11.boookingObj.Future_Correspondence_Contact_Name__c = 'Fifth Man';
        bookC11.save();
        
        
        
        
        
       
        
        
                 
   }

   @isTest
    private static void BookingTest222() {
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
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
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
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        insert r2;
        
        PageReference pRef13 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef13);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC13 = new BookingClass();
        bookC13.i = 0;
        List < SelectOption > sq13= bookC13.getQuote;
        bookC13.selectedQuote = q.Id;
        bookC13.receiptlist.add(r1);
        bookC13.getTokenAmount();
        bookC13.getReceiptDetails();
        bookC13.addReciept();
        bookC13.boookingObj.Application_No__c = '123456';   
        bookC13.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';    
        bookC13.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC13.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        
        // applicant3 to required fields validation simulation
        bookC13.applicant3.Name = 'Third Man';
        bookC13.applicant3.Applicant_Number__c = 'Third Applicant';
        //bookC1.applicant3.DOB__c = system.today();
        //bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant3.Pincode__c = 444444;
        //bookC1.applicant3.Country__c = 'India';
        //bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        //bookC1.applicant3.Mobile_Number__c = '909090900';
        //bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant3.Nationality__c = 'Indian';
        //bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC13.applicant3.Subtype_Of_Applicant__c = 'For Company';
        bookC13.applicant3.Pancard__c = false;
        bookC13.applicant3.Copy_of_Memorandu_of_Association__c = false;
        bookC13.applicant3.Certified_copy_of_Article_of_Association__c = false;
        bookC13.applicant3.Certified_copy_of_Board_Resolution__c = false;
        bookC13.applicant3.Certified_copy_of_ROC_Incorporation__c = false;
        bookC13.applicant3.PancardNo__c = '123456789123';
        bookC13.applicant3.Self_attested_List_of_Shareholders__c = false;
        bookC13.applicant3.Self_attested_List_of_Directors__c = false;
        bookC13.applicant3.PanCard_of_Authority_Signatory__c = false;
        bookC13.applicant3.Certified_extract_of_Registration__c = false;
        bookC13.applicant3.Copy_of_Authorization_Letter_POA__c = false;
        bookC13.applicant3.Mailing_Country__c= 'India';
        bookC13.applicant3.Mailing_Pincode__c = 123456789;
        bookC13.applicant3.Mailing_State__c = null;
        bookC13.addressCheckApplicant3 = false;
        bookC13.save();
        
      
        Test.startTest();
        bookC13.boookingObj.Future_Correspondence_Contact__c = 'Third Applicant';
        bookC13.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC13.save();
        Test.stopTest();
        }
        
        @isTest
    private static void BookingTest111() {
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
        //objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Seventh_Day__c = false;
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
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
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
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        insert r2;
        
        
        PageReference pRef12 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef12);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
         ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC12 = new BookingClass();
        bookC12.i = 0;
        List < SelectOption > sq12= bookC12.getQuote;
        bookC12.selectedQuote = q.Id;
        bookC12.receiptlist.add(r1);
        bookC12.getTokenAmount();
        bookC12.getReceiptDetails();
        bookC12.addReciept();
        bookC12.boookingObj.Application_No__c = '123456';   
        bookC12.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';    
        bookC12.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC12.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
     
        // applicant1 to required fields validation simulation
       //bookC12.applicant.Salutation__c = 'Mr.';
        bookC12.applicant.Name = 'New Man';
        //bookC1.applicant.DOB__c = system.today();
        //bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant.Pincode__c = 444444;
        //bookC1.applicant.Country__c = 'India';
        //bookC1.applicant.City__c = 'Nagpur';
        //bookC1.applicant.Mailing_Country__c= 'India';
        //bookC1.applicant.Mobile_Number__c = '909090900';
        //bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant.Nationality__c = 'Indian';
        //bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC12.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC12.applicant.Pancard__c = false;
        bookC12.applicant.Address_Proof__c = false;
        bookC12.applicant.Address_Proof_Document__c = '';
        bookC12.applicant.Address_Proof_Number__c = '';
        bookC12.applicant.One_Passport_Size_Color_Photograph__c = false;
        bookC12.applicant.PancardNo__c = '12345678910';
        bookC12.applicant.Mailing_Country__c= 'India';
        bookC12.applicant.Mailing_Pincode__c = 123456789;
        bookC12.applicant.Mailing_State__c = null;
        bookC12.addressCheck = false;
        bookC12.save();
        
        // applicant2 to required fields validation simulation
        bookC12.applicant2.Name = 'Second Man';
        bookC12.applicant2.Applicant_Number__c = 'Second Applicant';
        //bookC1.applicant2.DOB__c = system.today();
        //bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant2.Pincode__c = 444444;
        //bookC1.applicant2.Country__c = 'India';
        //bookC1.applicant2.City__c = 'Nagpur';
        //bookC1.applicant2.Mailing_Country__c= 'India';
        //bookC1.applicant2.Mobile_Number__c = '909090900';
        //bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant2.Nationality__c = 'Indian';
        //bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC12.applicant2.Subtype_Of_Applicant__c = 'For Company';
        bookC12.applicant2.Pancard__c = false;
        bookC12.applicant2.PanCard_of_Authority_Signatory__c = false;
        bookC12.applicant2.Copy_of_Memorandu_of_Association__c = false;
        bookC12.applicant2.Certified_copy_of_Article_of_Association__c = false;
        bookC12.applicant2.Certified_copy_of_Board_Resolution__c = false;
        bookC12.applicant2.Certified_copy_of_ROC_Incorporation__c = false;
        bookC12.applicant2.Address_Proof_Document__c = '';
        bookC12.applicant2.Self_attested_List_of_Directors__c  = false;
        bookC12.applicant2.Self_attested_List_of_Shareholders__c = false;
        bookC12.applicant2.Mailing_Country__c= 'India';
        bookC12.applicant2.Mailing_Pincode__c = 1559966;
        bookC12.applicant2.Mailing_State__c = null;
        bookC12.applicant2.PancardNo__c = '12345678922';
        bookC12.addressCheckApplicant2 = false;
        bookC12.save();
        /*bookC1.applicant3.Name ='Third Man';
        bookC1.save();
        bookC1.addressCheckApplicant3 = true;
        bookC1.save();*/
        
        // applicant3 to required fields validation simulation
        bookC12.applicant3.Name = 'Third Man';
        bookC12.applicant3.Applicant_Number__c = 'Third Applicant';
        //bookC1.applicant3.DOB__c = system.today();
        //bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant3.Pincode__c = 444444;
        //bookC1.applicant3.Country__c = 'India';
        //bookC1.applicant3.City__c = 'Nagpur';
        //bookC1.applicant3.Mailing_Country__c= 'India';
        //bookC1.applicant3.Mobile_Number__c = '909090900';
        //bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant3.Nationality__c = 'Indian';
        //bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC12.applicant3.Subtype_Of_Applicant__c = 'For Company';
        bookC12.applicant3.Pancard__c = false;
        bookC12.applicant3.Copy_of_Memorandu_of_Association__c = false;
        bookC12.applicant3.Certified_copy_of_Article_of_Association__c = false;
        bookC12.applicant3.Certified_copy_of_Board_Resolution__c = false;
        bookC12.applicant3.Certified_copy_of_ROC_Incorporation__c = false;
        bookC12.applicant3.PancardNo__c = '123456789123';
        bookC12.applicant3.Self_attested_List_of_Shareholders__c = false;
        bookC12.applicant3.Self_attested_List_of_Directors__c = false;
        bookC12.applicant3.PanCard_of_Authority_Signatory__c = false;
        bookC12.applicant3.Certified_extract_of_Registration__c = false;
        bookC12.applicant3.Copy_of_Authorization_Letter_POA__c = false;
        bookC12.applicant3.Mailing_Country__c= 'India';
        bookC12.applicant3.Mailing_Pincode__c = 123456789;
        bookC12.applicant3.Mailing_State__c = null;
        bookC12.addressCheckApplicant3 = false;
        bookC12.save();
        
        
        bookC12.applicant4.Name ='Fourth Man';
        bookC12.applicant4.Applicant_Number__c = 'Fourth Applicant';
        //bookC1.applicant4.DOB__c = system.today();
        //bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC1.applicant4.Pincode__c = 44444478;
        //bookC1.applicant4.Country__c = 'India';
        //bookC1.applicant4.City__c = 'Nagpur';
        //bookC1.applicant4.Mailing_Country__c= 'India';
        //bookC1.applicant4.Mobile_Number__c = '909090900';
        //bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        //bookC1.applicant4.Nationality__c = 'Indian';
        //bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC12.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC12.applicant4.Pancard__c = false;
        bookC12.applicant4.PanCard_of_Authority_Signatory__c = false;
        bookC12.applicant4.Certified_extract_of_Registration__c = false;
        bookC12.applicant4.Certified_copy_of_Partnership_Deed__c = false;
        bookC12.applicant4.Copy_of_Authorization_Letter_POA__c = false;
        bookC12.applicant4.Address_Proof_Document__c = '';
        bookC12.applicant4.Address_Proof_Number__c = '';
        bookC12.applicant4.Copy_of_Workpermit_Employment_contract__c = true;
        bookC12.applicant4.PancardNo__c = '12345678910';
        bookC12.applicant4.One_Passport_Size_Color_Photograph__c = false;
        bookC12.applicant4.Mailing_Country__c= 'India';
        bookC12.applicant4.Mailing_Pincode__c = 12345677;
        //bookC1.addressCheckApplicant3 = true;
        //bookC1.save();
        bookC12.addressCheckApplicant4 = false;
        bookC12.save(); 
        
        bookC12.applicant5.Name ='Fifth Man';
        bookC12.applicant5.Applicant_Number__c = 'Fifth Applicant';
        //bookC1.applicant5.DOB__c = system.today();
        //bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        //bookC11.applicant5.Pincode__c = 44444454;
        //bookC11.applicant5.Country__c = 'India';
        //bookC1.applicant5.City__c = 'Nagpur';
        //bookC1.applicant5.Mailing_Country__c= 'India';
        //bookC1.applicant5.Mobile_Number__c = '909090900';
        //bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        //bookC11.applicant5.Nationality__c = 'Indian';
        //bookC11.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC12.applicant5.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC12.applicant5.Pancard__c = false;
        bookC12.applicant5.PanCard_of_Authority_Signatory__c = false;
        bookC12.applicant5.Certified_copy_of_Partnership_Deed__c = false;
        bookC12.applicant5.Certified_extract_of_Registration__c = false;
        bookC12.applicant5.Copy_of_Authorization_Letter_POA__c = false;
        bookC12.applicant5.Copy_of_Workpermit_Employment_contract__c = true;
        bookC12.applicant5.PancardNo__c = '1234567891155';
        bookC12.applicant5.One_Passport_Size_Color_Photograph__c = true;
        bookC12.applicant5.Mailing_Country__c= 'India';
        bookC12.applicant5.Mailing_Pincode__c = 123456789;
        bookC12.addressCheckApplicant5 = false;
        bookC12.save();
        
      
        //Test.startTest();
        /*bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'New Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'Second Man';
        bookC1.save();
        bookC11.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC11.boookingObj.Future_Correspondence_Contact_Name__c = 'Third Man';
        bookC11.save();*/
        bookC12.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC12.boookingObj.Future_Correspondence_Contact_Name__c = 'Fifth Man';
        bookC12.save();
     }   
              
}