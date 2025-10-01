@isTest
public class BookingClassTest {
    
    
    @testsetup
    private static void setupdata() {
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
        objpr.Service_Tax_Required_On_Token_Amount_c__c = true;
        insert objpr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        List<Project_Unit__c> units = new List<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //insert objPUU;
        units.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        //insert objPUU1;
        units.add(objPUU1);
        insert units;
        
        List<Car_Parking_Charge__c> parkings = new List<Car_Parking_Charge__c>();
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        //insert objCP1;
        parkings.add(objCP1);
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        //insert objCP2;
        parkings.add(objCP2);
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        //insert objCP3;
        parkings.add(objCP3);
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        //insert objCP4;
        parkings.add(objCP4);
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP5);
        
        Car_Parking_Charge__c objCP6 = new Car_Parking_Charge__c();
        objCP6.Status__c = 'Vacant';
        objCP6.Category__c = 'Additional';
        objCP6.Parking__c = 'Covered Stack';
        objCP6.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP6);
        
        Car_Parking_Charge__c objCP7 = new Car_Parking_Charge__c();
        objCP7.Status__c = 'Vacant';
        objCP7.Category__c = 'Additional';
        objCP7.Parking__c = 'Stilt';
        objCP7.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP7);
        
        Car_Parking_Charge__c objCP8 = new Car_Parking_Charge__c();
        objCP8.Status__c = 'Vacant';
        objCP8.Category__c = 'Additional';
        objCP8.Parking__c = 'MLCP';
        objCP8.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP8);
        
        Car_Parking_Charge__c objCP9 = new Car_Parking_Charge__c();
        objCP9.Status__c = 'Vacant';
        objCP9.Category__c = 'Additional';
        objCP9.Parking__c = 'Basement';
        objCP9.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP9);
        
        Car_Parking_Charge__c objCP10 = new Car_Parking_Charge__c();
        objCP10.Status__c = 'Vacant';
        objCP10.Category__c = 'Additional';
        objCP10.Parking__c = 'Podium';
        objCP10.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP10);
        
        Car_Parking_Charge__c objCP11 = new Car_Parking_Charge__c();
        objCP11.Status__c = 'Vacant';
        objCP11.Category__c = 'Additional';
        objCP11.Parking__c = 'Puzzle Car Park';
        objCP11.Project__c = objpr.Id;
        parkings.add(objCP11);
        
        insert parkings;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777332',false);
        Account a1 = TestDataFactory.createPATemplate('WC Account1', 'wc1@email.com','9098777331',false);
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        //objcustomer.Walkin_Source__c = 'Channel Partner';
        //objcustomer.RW_Apply_Unregistered_Broker__c = true;
        //objcustomer.RW_Unregistered_Broker_Name__c = 'Test Broker';
        //objcustomer.RW_Unregistered_Broker_Mobile__c = '2145789658';
        //objcustomer.Walkin_Apply_Unregistered_ChannelPartner__c = true;
        //objcustomer.Walkin_Unregistered_ChannelPartner_Name__c = 'Test Broker';
        //objcustomer.Walkin_UnregisteredChannelPartner_Mobile__c = '2145789658';
        //insert objcustomer;
        oppList.add(objcustomer);
        
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
        //insert objcustomer1;
        oppList.add(objcustomer1);
        insert oppList;
        
        RW_EOI__c eoi = new RW_EOI__c();
        eoi.Opportunity__c = objcustomer.Id;
        eoi.RW_Status__c = 'EOI Blocked';
        insert eoi;
        
        Applicable_Offer__c offer = new Applicable_Offer__c();
        offer.Offer_Availed__c = true;
        offer.EOI__c = eoi.Id;
        insert offer;
        
        AOP__c aop = new AOP__c();
        
        
        List<Quotation__c> quotationList = new List<Quotation__c>();
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
        q.Tandem_car_park_Additional__c = 1;
        q.Tandem_Open_Additional__c= 1;
        //q.Service_Tax_On_Token_Amount__c = true;
        q.Single_car_park_Additional__c= 1;
        q.Single_Open_Additional__c = 1;
        q.Stack_Additional__c = 1;
        q.MLCP_Additional__c = 1;
        q.Basement_Additional__c = 1;
        q.Podium__c = 1;
        q.Puzzle_Car_Park__c = 1;
        q.Agreement_Value_for_brokers__c  = 100000;
        
        //insert q;
        quotationList.add(q);
        
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
         q2.Agreement_Value_for_brokers__c  = 100000;
        //q2.Service_Tax_On_Token_Amount__c = true;
        //insert q2;
        quotationList.add(q2);
        insert quotationList;
        
        List<Receipt__c> receiptList = new List<Receipt__c>();
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
        //insert r1;
        receiptList.add(r1);
        
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
        //insert r2;
        receiptList.add(r2);
        insert receiptList;
        
        
        Dummy_Emails__c dummyEmail = new Dummy_Emails__c();
        dummyEmail.Name = 'abc@email.com';
        insert dummyEmail;
        
        List<Brokerage_Scheme__c> schemes = new List<Brokerage_Scheme__c>();
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Local';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        //bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        //bscheme.Project_Location__c = pl.Id;
        bscheme.Base_Brokerage_for_Local_Bookings__c = 1;
        schemes.add(bscheme);
        
        Brokerage_Scheme__c bscheme2 = new Brokerage_Scheme__c();
        bscheme2.Type__c = 'NRI';
        bscheme2.Approval_Status__c = 'Approved by Level 2';
        bscheme2.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme2.Slab_Type__c = 'Count';
        bscheme2.Start_Date__c = Date.newInstance(2023, 4, 1);
        bscheme2.End_Date__c = system.today()+2;
        schemes.add(bscheme2);
        
         Brokerage_Scheme__c bscheme3 = new Brokerage_Scheme__c();
        bscheme3.Type__c = 'Both';
        bscheme3.Approval_Status__c = 'Approved by Level 2';
        bscheme3.Base_Brokerage_for_OS_NRI__c = 2;
        bscheme3.Base_Brokerage_for_Local_Bookings__c = 2;
        bscheme3.Slab_Type__c = 'Count';
        bscheme3.Start_Date__c = Date.newInstance(2023, 4, 1);
        bscheme3.End_Date__c = system.today()+2;
        schemes.add(bscheme3);
        insert schemes;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = objpr.id;
        insert sc;
        
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
        
    }
    
    
    @isTest
    private static void BookingTest1() {
        
        Test.StartTest();
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
        
          
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
        bookC1.Save();
        
        Test.stopTest();       
    }
    
    @isTest
    private static void BookingTest2(){
        Test.StartTest();
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
          
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        //ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.applicant.Last_Name__c = '';
        bookC1.applicant.Country__c = null;
        bookC1.applicant.Mobile_Number__c = '';
        bookC1.applicant.Email_Address__c = 'abc@email.com';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.PancardNo__c = 'ABC1234';
        bookC1.applicant.Address_Proof_Number__c = 'ABC1234*';
        bookC1.addressCheck = false;
        bookC1.applicant2.Last_Name__c = 'Applicant 2';
        bookC1.applicant2.Country__c = null;
        bookC1.applicant2.Mobile_Number__c = '';
        bookC1.applicant2.Email_Address__c = 'abc@email.com';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.PancardNo__c = 'ABC1234';
        bookC1.applicant2.Address_Proof_Number__c = 'ABC1234*';
        bookC1.addressCheckApplicant2 = false;
        bookC1.applicant3.Last_Name__c = 'Applicant 3';
        bookC1.applicant3.Country__c = null;
        bookC1.applicant3.Mobile_Number__c = '';
        bookC1.applicant3.Email_Address__c = 'abc@email.com';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant3.PancardNo__c = 'ABC1234';
        bookC1.applicant3.Address_Proof_Number__c = 'ABC1234*';
        bookC1.addressCheckApplicant3 = false;
        bookC1.applicant4.Last_Name__c = 'Applicant 4';
        bookC1.applicant4.Country__c = null;
        bookC1.applicant4.Mobile_Number__c = '';
        bookC1.applicant4.Email_Address__c = 'abc@email.com';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant4.PancardNo__c = 'ABC1234';
        bookC1.applicant4.Address_Proof_Number__c = 'ABC1234*';
        bookC1.addressCheckApplicant4 = false;
        bookC1.applicant5.Last_Name__c = 'Applicant 5';
        bookC1.applicant5.Country__c = null;
        bookC1.applicant5.Mobile_Number__c = '';
        bookC1.applicant5.Email_Address__c = 'abc@email.com';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.PancardNo__c = 'ABC1234';
        bookC1.applicant5.Address_Proof_Number__c = 'ABC1234*';
        bookC1.addressCheckApplicant5 = false;
        bookC1.Save();
        
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest3(){
        Test.StartTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Opportunity> objcustomers = [SELECT Id FROM Opportunity LIMIT 2];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
        Broker__c brk = [SELECT Id FROM Broker__c LIMIT 1];
        
        acc.BillingPostalCode = '521366';
        acc.RW_Zip_Code__c = '521366';
        update acc;
        
        objcustomers[0].Walkin_Source__c = 'Channel Partner';
        objcustomers[0].RW_Sales_Associate__c = 'Test';
        objcustomers[0].RW_Sourcing_Manager__c = 'Test';
        objcustomers[0].RW_Previous_Opportunity__c = objcustomers[1].Id;
        objcustomers[0].RW_Walkin_Channel_Partner__c = brk.Id;
        objcustomers[0].Walkin_SubSource__c = 'Test';
        update objcustomers[0];
          
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomers[0].id);
        //ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        //ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.i = 0;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.addReciept();
        bookC1.getaddressstatus();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.Pincode__c = 52136;
        bookC1.applicant2.Last_Name__c = '';
        bookC1.applicant2.Pincode__c = 52136;
        bookC1.applicant2.Mobile_Number__c = null;
        bookC1.applicant2.Email_Address__c = null;
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant3.Last_Name__c = '';
        bookC1.applicant3.Pincode__c = 52136;
        bookC1.applicant3.Mobile_Number__c = null;
        bookC1.applicant3.Email_Address__c = null;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant4.Last_Name__c = '';
        bookC1.applicant4.Pincode__c = 52136;
        bookC1.applicant4.Mobile_Number__c = null;
        bookC1.applicant4.Email_Address__c = null;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant5.Last_Name__c = '';
        bookC1.applicant5.Pincode__c = 52136;
        bookC1.applicant5.Mobile_Number__c = null;
        bookC1.applicant5.Email_Address__c = null;
        bookC1.applicant5.Country__c = 'India';
        bookC1.Save();
        
        bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant.PancardNo__c = 'ABC1234';
        bookC1.applicant.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant2.PancardNo__c = 'ABC1234';
        bookC1.applicant2.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant3.PancardNo__c = 'ABC1234';
        bookC1.applicant3.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant4.PancardNo__c = 'ABC1234';
        bookC1.applicant4.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant5.PancardNo__c = 'ABC1234';
        bookC1.applicant5.Address_Proof_Number__c = 'ABC1234*';
        bookC1.Save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant.PancardNo__c = 'ABC1234';
        bookC1.applicant.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant2.PancardNo__c = 'ABC1234';
        bookC1.applicant.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant3.PancardNo__c = 'ABC1234';
        bookC1.applicant3.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant4.PancardNo__c = 'ABC1234';
        bookC1.applicant4.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant5.PancardNo__c = 'ABC1234';
        bookC1.applicant5.Address_Proof_Number__c = 'ABC1234*';
        bookC1.Save();
        bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant.PancardNo__c = 'ABC1234';
        bookC1.applicant.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant2.PancardNo__c = 'ABC1234';
        bookC1.applicant2.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant3.PancardNo__c = 'ABC1234';
        bookC1.applicant3.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant4.PancardNo__c = 'ABC1234';
        bookC1.applicant4.Address_Proof_Number__c = 'ABC1234*';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Partnership Firm';
        bookC1.applicant5.PancardNo__c = 'ABC1234';
        bookC1.applicant5.Address_Proof_Number__c = 'ABC1234*';
        
        bookC1.boookingObj.Future_Correspondence_Contact__c = '';
        bookC1.boookingObj.Booking_Date__c = DateTime.newInstance(2023, 12, 31, 23, 59, 0);
        bookC1.Save();
        
        Booking__c booking = new Booking__c();
        booking.Type_of_Client__c = 'Local';
        booking.Passback_Amount__c = 1000;
        
        Quotation__c quote = [SELECT Id, Brokerage_Agreement_Value__c FROM Quotation__c WHERE Brokerage_Agreement_Value__c != null LIMIT 1];
        List<Quotation__c> quoteList = new List<Quotation__c>{quote};
            
            // Date before 2024 for testing bookingDate < bookingDate2
            Date bookingDate = Date.newInstance(2023, 12, 31);
        Date compareDate = Date.newInstance(2024, 1, 1);
        
        List<Brokerage_Scheme__c> schemeList = [SELECT Id, Name, Type__c, Base_Brokerage_for_OS_NRI__c, Base_Brokerage_for_Local_Bookings__c FROM Brokerage_Scheme__c WHERE Type__c = 'NRI' LIMIT 1];
        
      //  Booking__c updatedBooking = BookingClass2.updateBrokerageSchemeDetails(booking, quoteList, schemeList, bookingDate, compareDate);
        
        Booking__c booking1 = new Booking__c();
        booking1.Type_of_Client__c = 'NRI';
        booking1.Passback_Amount__c = 1000;
        
        Quotation__c quote1 = [SELECT Id, Brokerage_Agreement_Value__c FROM Quotation__c WHERE Brokerage_Agreement_Value__c != null LIMIT 1];
        List<Quotation__c> quoteList1 = new List<Quotation__c>{quote1};
        
            Date bookingDate1 = Date.newInstance(2023, 12, 31);
        Date compareDate1 = Date.newInstance(2024, 1, 1);
        List<Brokerage_Scheme__c> schemeList1 = [SELECT Id, Name, Type__c, Base_Brokerage_for_OS_NRI__c, Base_Brokerage_for_Local_Bookings__c FROM Brokerage_Scheme__c WHERE Type__c = 'Both' LIMIT 1];
        
       // Booking__c updatedBooking1 = BookingClass2.updateBrokerageSchemeDetails(booking1, quoteList1, schemeList1, bookingDate1, compareDate1);
       // Booking__c updatedBooking2 = BookingClass2.updateBrokerageSchemeDetails(booking, quoteList1, schemeList1, bookingDate1, compareDate1);
        
        
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest4(){
        Test.StartTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
                  
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        //ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
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
        
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest5(){
        Test.StartTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
        
        objcustomer.Walkin_Source__c = 'Emp / Mgmt Reference';
        update objcustomer;
                  
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        //ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
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
        bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c = '';
        bookC1.boookingObj.Future_Correspondence_Contact_Relation__c = '';
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
        bookC1.applicant.Email_Address__c = '111@mail.com';
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.applicant2.Name = 'Applicant 2';
        bookC1.applicant2.Mobile_Number__c = '2222222222';
        bookC1.applicant2.Email_Address__c = '222@mail.com';
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.applicant3.Name = 'Applicant 3';
        bookC1.applicant3.Mobile_Number__c = '3333333333';
        bookC1.applicant3.Email_Address__c = '333@mail.com';
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.applicant4.Name = 'Applicant 4';
        bookC1.applicant4.Mobile_Number__c = '4444444444';
        bookC1.applicant4.Email_Address__c = '444@mail.com';
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.applicant5.Name = 'Applicant 5';
        bookC1.applicant5.Mobile_Number__c = '5555555555';
        bookC1.applicant5.Email_Address__c = '555@mail.com';
        bookC1.Save();
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest6(){
        Test.StartTest();
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
        
        //q.Project_Unit__c = null;
        //q.Quote_Status__c = 'Expired';
        //update q;
        
        objcustomer.Walkin_Source__c = 'Referral';
        objcustomer.Referral_Sub_Source__c = 'Existing client reference';
        objcustomer.RW_Walkin_Customer_Reference__c = accList[1].Id;
        update objcustomer;
                  
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        //ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        ApexPages.currentPage().getParameters().put('rowIndex','0');
        bookC1.deleteReciept();
        bookC1.boookingObj.Opportunity__c = null;
        bookC1.boookingObj.Booking_Date__c = Date.today() + 1;
        bookC1.boookingObj.Future_Correspondence_Contact__c = null;
        
        
        bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
        bookC1.applicant2.Name = null;
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
        bookC1.applicant3.Name = null;
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
        bookC1.applicant4.Name = null;
        bookC1.Save();
        bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
        bookC1.applicant5.Name = null;
        bookC1.Save();
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest7(){
        Test.StartTest();
        List<Account> accList = [SELECT Id FROM Account LIMIT 2];
        Opportunity objcustomer = [SELECT Id FROM Opportunity LIMIT 1];
        Project_Unit__c objPUU = [SELECT Id FROM Project_Unit__c LIMIT 1];
        Project__c objpr = [SELECT Id FROM Project__c LIMIT 1];
        Quotation__c q = [SELECT Id FROM Quotation__c LIMIT 1];
        Receipt__c r1 = [SELECT Id,Mode__c,Cheque_DD__c,Cheque_DD_Date__c,Total_Amount__c,DraweeBank__c,Token_Amount_ST__c FROM Receipt__c LIMIT 1];
        
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        //ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        bookC1.receiptlist.add(r1);
        bookC1.getTokenAmount();
        //bookC1.getReceiptDetails();
        bookC1.i = 0;
        bookC1.applicant.First_Name__c = 'First';
        bookC1.applicant.Last_Name__c = 'Last';
        bookC1.applicant.Middle_Name__c = 'Middle';
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Permanent_Address__c = 'Address 1';
        bookC1.applicant.Organization_Name__c = 'Test';
        bookC1.Save();
        //bookC1.dummyMethod();
        Test.stopTest();    
    }
    
    @isTest
    private static void BookingTest8(){
        Test.StartTest();
        Account acc = new Account();
        acc.LastName = 'Account 1';
        acc.RW_Zip_Code__c = '521355';
        acc.Current_Residential_Address__c = 'Test Acc Address';
        acc.RW_Company_Name__c = 'Test';
        acc.RW_Designation__c = 'Test';
        insert acc;
        
        Applicant_Details__c app = new Applicant_Details__c();
        app.Salutation__c = 'Mr';
        app.First_Name__c = 'First';
        app.Middle_Name__c = 'Middle';
        app.Last_Name__c = 'Last';
        app.Pincode__c = 521366;
        app.Permanent_Address__c = 'Test Addr';
        app.Organization_Name__c = 'Test org';
        app.Designation__c = 'Desig';
        insert app;
        
        BookingClass2.updateAccount(app, acc);
        Test.stopTest();    
    }
   

    
}