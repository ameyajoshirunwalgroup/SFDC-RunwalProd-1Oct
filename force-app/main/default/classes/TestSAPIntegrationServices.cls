@isTest
private class TestSAPIntegrationServices {
    @isTest
    private static void testCreateSO(){
        Opportunity objcustomer;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Club Membership';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Club Membership';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Agreement Value';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Club Membership';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        insert parkings;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        
        objcustomer.CloseDate=system.today()+7;
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Rating__c = 'Hot';
        objcustomer.Remark__c = 'test remarks';
        objcustomer.LeadSource = 'Direct';
        objcustomer.Lead_Sub_Source__c = 'Digital';
        objcustomer.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer.RW_Sales_Associate__c = 'DIRECT';
        objcustomer.Walk_in_Source__c = 'Referral';
        objcustomer.Referral_Sub_Source__c = 'Existing client reference';
		//objcustomer.Walk_in_Source__c = 'Channel Partner';
        insert objcustomer;
        
        
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        Id cpRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();        
        chp1.RecordTypeId = cpRecordTypeId;
        insert chp1;
        
        
        
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTwr.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = objcustomer.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        insert objPUU;
        
        
        
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
        q.Discount_9_L__c = 100;
        q.Discount_10_L__c = 100;
        q.Discount_11_L__c = 100;
        insert q;
        
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
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = objcustomer.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = objcustomer.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Quotation__c = q.Id;
        objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        insert objBking;
        
        List<Applicant_Details__c> apps = new List<Applicant_Details__c>();
        Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = objcustomer.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = objBking.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        //apt1.PancardNo__c = 'abc213456';
        //insert apt1;
        apps.add(apt1);
        
        Applicant_Details__c apt2 = new Applicant_Details__c();
        apt2.Name = 'Applicant 2';
        apt2.Permanent_Address__c = 'test address1';
        apt2.Opportunity__c = objcustomer.Id;
        apt2.Applicant_Number__c = 'Second Applicant';
        apt2.Subtype_Of_Applicant__c = 'Indian National';
        apt2.Type_Of_Applicant__c= 'Individual Buyer';
        apt2.Booking__c = objBking.Id;
        apt2.DOB__c = Date.today();
        apt2.Office_Address_Line_1__c = 'Office Address Line 2';
        apt2.Mobile_Number__c = '1234567899';
        apt2.Email_Address__c = 'test1@test1.com';
        apt2.Address_Proof__c = true;
        apt2.Address_Proof_Document__c = 'Passport';
        apt2.gender__c = 'Female';
        apt2.Designation_picklist__c = 'Accounting';
        apt2.Occupation__c = 'Admin';
        apt2.PancardNo__c = 'ABC123456';
        //insert apt2;
        apps.add(apt2);
        
        Applicant_Details__c apt3 = new Applicant_Details__c();
        apt3.Name = 'Applicant 3';
        apt3.Permanent_Address__c = 'test address1';
        apt3.Opportunity__c = objcustomer.Id;
        apt3.Applicant_Number__c = 'Third Applicant';
        apt3.Subtype_Of_Applicant__c = 'Indian National';
        apt3.Type_Of_Applicant__c= 'Individual Buyer';
        apt3.Booking__c = objBking.Id;
        apt3.DOB__c = Date.today();
        apt3.Office_Address_Line_1__c = 'Office Address Line 2';
        apt3.Mobile_Number__c = '1234567899';
        apt3.Email_Address__c = 'test1@test1.com';
        apt3.Address_Proof__c = true;
        apt3.Address_Proof_Document__c = 'Passport';
        apt3.gender__c = 'Male';
        apt3.Designation_picklist__c = 'Accounting';
        apt3.Occupation__c = 'Admin';
        apt3.PancardNo__c = 'ABC123456';
        //insert apt3;
        apps.add(apt3);
        
        Applicant_Details__c apt4 = new Applicant_Details__c();
        apt4.Name = 'Applicant 4';
        apt4.Permanent_Address__c = 'test address1';
        apt4.Opportunity__c = objcustomer.Id;
        apt4.Applicant_Number__c = 'Fourth Applicant';
        apt4.Subtype_Of_Applicant__c = 'Indian National';
        apt4.Type_Of_Applicant__c= 'Individual Buyer';
        apt4.Booking__c = objBking.Id;
        apt4.DOB__c = Date.today();
        apt4.Office_Address_Line_1__c = 'Office Address Line 2';
        apt4.Mobile_Number__c = '1234567899';
        apt4.Email_Address__c = 'test1@test1.com';
        apt4.Address_Proof__c = true;
        apt4.Address_Proof_Document__c = 'Passport';
        apt4.PancardNo__c = 'ABC123456';
        //insert apt4;
        apps.add(apt4);
        
        Applicant_Details__c apt5 = new Applicant_Details__c();
        apt5.Name = 'Applicant 5';
        apt5.Permanent_Address__c = 'test address1';
        apt5.Opportunity__c = objcustomer.Id;
        apt5.Applicant_Number__c = 'Fifth Applicant';
        apt5.Subtype_Of_Applicant__c = 'Indian National';
        apt5.Type_Of_Applicant__c= 'Individual Buyer';
        apt5.Booking__c = objBking.Id;
        apt5.DOB__c = Date.today();
        apt5.Office_Address_Line_1__c = 'Office Address Line 2';
        apt5.Mobile_Number__c = '1234567899';
        apt5.Email_Address__c = 'test1@test1.com';
        apt5.Address_Proof__c = true;
        apt5.Address_Proof_Document__c = 'Passport';
        apt5.PancardNo__c = 'ABC123456';
        //insert apt5;
        apps.add(apt5);
        insert apps;
          
        objcustomer.RW_Project_Unit__c=objPUU.id;  
        objcustomer.Booking__c = objBking.Id;
        //objcustomer.RW_Walkin_Channel_Partner__c = chp1.Id;
        update objcustomer;
        
        objPUU.RW_Unit_Status__c ='Booked';
        objPUU.RW_Booking_Date__c = Date.today();
        objPUU.Booking__c = objBking.Id;
        update objPUU;
        
        
        OIds.add(objcustomer.Id);
        SAPIntegrationServices.createSO(OIds);
  
    }
    
    @isTest
    private static void testGenerateSO(){
       Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Agreement Value';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        
             /*OIds1.clear();
        OIds.add(objcustomer.Id);
        SAPIntegrationServices.createSO(OIds);
        
        objcustomer.RW_Project__c=objpr.id;
        update objcustomer;
        
        OIds1.clear();
        OIds.add(objcustomer.Id);
        SAPIntegrationServices.createSO(OIds);*/
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        Id cpRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();        
        chp1.RecordTypeId = cpRecordTypeId;
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        insert objcustomer1;
        
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        insert apt6;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.createSO(OIds1);
    }
    
     @isTest
    private static void testGenerateSOWithSONumber(){
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Agreement Value';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        objcustomer1.SalesOrder_Number__c = '213245467';
        insert objcustomer1;
        
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        insert apt6;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.createSO(OIds1);
    }
    
     /*@isTest
    private static void testGenerateSOWith2Opty(){
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit__c objPUU;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Agreement Value';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        
        objcustomer.CloseDate=system.today()+7;
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Rating__c = 'Hot';
        objcustomer.Remark__c = 'test remarks';
        objcustomer.LeadSource = 'Direct';
        objcustomer.Lead_Sub_Source__c = 'Digital';
        objcustomer.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer.RW_Sales_Associate__c = 'DIRECT';
        //objcustomer.Walk_in_Source__c = 'Channel Partner';
		//objcustomer.Walk_in_Source__c = 'Channel Partner';
        insert objcustomer;
        
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        objcustomer1.SalesOrder_Number__c = '213245467';
        insert objcustomer1;
        
     
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTwr.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = objcustomer.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
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
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = objcustomer.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = objcustomer.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Quotation__c = q.Id;
        objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        insert objBking;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        apt6.PancardNo__c = 'abc213456';
        insert apt6;
        
        objcustomer.RW_Project_Unit__c=objPUU.id;  
        objcustomer.Booking__c = objBking.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = chp1.Id;
        update objcustomer;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        objPUU.RW_Unit_Status__c ='Booked';
        objPUU.RW_Booking_Date__c = Date.today();
        objPUU.Booking__c = objBking.Id;
        update objPUU;
        
        OIds1.add(objcustomer.ID);
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.createSO(OIds1);
    }*/
    
        @isTest
    private static void testGenerateSOWithRateList(){
       Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Other Charges';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        objTwr.Property_Type__c = 'Residential';
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        objCP5.Parking__c = 'Covered Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Car_Parking_Charge__c objCP6 = new Car_Parking_Charge__c();
        objCP6.Status__c = 'Vacant';
        objCP6.Category__c = 'Additional';
        objCP6.Parking__c = 'Stilt';
        objCP6.Project__c = objpr.Id;
        insert objCP6;
            
        Car_Parking_Charge__c objCP7 = new Car_Parking_Charge__c();
        objCP7.Status__c = 'Vacant';
        objCP7.Category__c = 'Additional';
        objCP7.Parking__c = 'MLCP';
        objCP7.Project__c = objpr.Id;
        insert objCP7;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
            
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        insert objcustomer1;
        
        
        Project_Unit__c sr = new Project_Unit__c();
        sr.Name = 'Service Room';
        sr.RW_Project__c = objpr.Id;
        sr.TowerName__c = objTwr.Id;
        sr.New_Floor__c = '10';
        sr.Is_Service_Room_Unit__c = true;
        sr.RW_Param1__c = 'Param 1';
        sr.RW_Param2__c = 'Param 2';
        sr.RW_Param3__c = 'Param 3';
        sr.RW_Param4__c = 'Param 4';
        sr.Carpet_Area__c = 10;
        sr.Deck_Area__c = 10;
        sr.Utility_Area__c = 10;
        sr.Service_Room_Status__c = 'Available';
        sr.Avail_Service_Room__c = false;
        insert sr;
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        objPUU1.Service_Room_Unit__c = sr.Id;
        objPUU1.Avail_Service_Room__c = true;
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        q1.CAM_Charges__c = 1000;
        q1.BCAM_Charges__c = 100;
        q1.Discount_9_L__c = 100;
        q1.Discount_10_L__c = 100;
        q1.Discount_11_L__c = 100;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        objBking1.Brokerage__c = 10;
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        insert apt6;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        Rate_List_Header__c objRlh = new Rate_List_Header__c();
        objRlh.Name = 'Basic RL Header';
        objRlh.Project__c = objpr.Id;
        objRlh.Project_Charges__c = PCharge.Id;
        objRlh.Rate_list__c = 'All Charges';
        objRlh.Effective_From__c = system.today().addDays(-3);
        insert objRlh;
        
        Rate_List__c objRL = new Rate_List__c();
        objRL.Rate_List_HeaderID__c = objRlh.Id;
        objRL.Project__c = objpr.Id;
        objRL.Global_Charges__c = ObjGloChrg.Id;
        objRL.Project_Charges__c = PCharge.Id;
        objRL.Project_Unit__c = objPUU1.Id;
        objRL.Charge_Based_On_Master__c = 'Rate';
        objRL.Value__c = 2218;
        objRL.Rate__c = 23600;
        objRL.Amount__c = 100000;
        objRL.Charge_on_Area_Type__c = 'Saleable Area';
        insert objRL;
        
        
        
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
        objPaymentPlan.Name ='Pay Plan 1';
        objPaymentPlan.Project__c = objpr.Id;
        objPaymentPlan.Tower__c =  objTwr.Id;
        insert objPaymentPlan;
        
        Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
        objSPP.Project__c = objpr.Id;
        objSPP.Charge_Code__c= PCharge.Id;
        objSPP.Payment_Plan__c=objPaymentPlan.id;
        objSPP.Name='Basic Header';
        objSPP.Plan_Code__c= '89';
        objSPP.tower__c =  objTwr.Id;
        objSPP.Effective_from__c = System.today();
        insert objSPP;
        
        Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
        objCPPH.Amount__c=1000000.00;
        objCPPH.Customer__c=objcustomer1.id; 
        objCPPH.Effect_From_Date__c=system.today(); 
        objCPPH.Global_Charges__c=ObjGloChrg.id; 
        objCPPH.Project__c=objpr.id; 
        objCPPH.Project_Unit__c=objPUU1.id; 
        objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
        objCPPH.tower__c =  objTwr.Id;
        objCPPH.Quotation__c = q1.id;
        objCPPH.PlanDt__c=system.today();
        objCPPH.Booking__c = objBking1.id;
        insert objCPPH;
        
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Standard_Pay_Plan_Header__c = objSPP.Id;
        scppd1.Tower__c = objTwr.Id;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppd1.Project__c = objpr.Id;
        scppd1.Customer_Pay_Plan_Header__c = objCPPH.Id;
        scppd1.Due_Date__c = Date.today() + 30;
        scppd1.Milestone_Percentage__c = 10;
        scppd1.Installment__c = 100000;
        insert scppd1;
        
        
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.generateSalesOrder(OIds1, objcustomer1.SAP_Customer_Number__c);
    }
    
     @isTest
    private static void testGenerateCustmr(){
       Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Other Charges';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        objTwr.Property_Type__c = 'Residential';
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        objCP5.Parking__c = 'Covered Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Car_Parking_Charge__c objCP6 = new Car_Parking_Charge__c();
        objCP6.Status__c = 'Vacant';
        objCP6.Category__c = 'Additional';
        objCP6.Parking__c = 'Stilt';
        objCP6.Project__c = objpr.Id;
        insert objCP6;
            
        Car_Parking_Charge__c objCP7 = new Car_Parking_Charge__c();
        objCP7.Status__c = 'Vacant';
        objCP7.Category__c = 'Additional';
        objCP7.Parking__c = 'MLCP';
        objCP7.Project__c = objpr.Id;
        insert objCP7;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
            
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        insert objcustomer1;
        
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        q1.CAM_Charges__c = 1000;
        q1.BCAM_Charges__c = 100;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        objBking1.Brokerage__c = 10;
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'For Company';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        apt6.Gender__c = 'Male';
        apt6.Organization_Name__c = 'ABC';
        insert apt6;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        Rate_List_Header__c objRlh = new Rate_List_Header__c();
        objRlh.Name = 'Basic RL Header';
        objRlh.Project__c = objpr.Id;
        objRlh.Project_Charges__c = PCharge.Id;
        objRlh.Rate_list__c = 'All Charges';
        objRlh.Effective_From__c = system.today().addDays(-3);
        insert objRlh;
        
        Rate_List__c objRL = new Rate_List__c();
        objRL.Rate_List_HeaderID__c = objRlh.Id;
        objRL.Project__c = objpr.Id;
        objRL.Global_Charges__c = ObjGloChrg.Id;
        objRL.Project_Charges__c = PCharge.Id;
        objRL.Project_Unit__c = objPUU1.Id;
        objRL.Charge_Based_On_Master__c = 'Rate';
        objRL.Value__c = 2218;
        objRL.Rate__c = 23600;
        objRL.Amount__c = 100000;
        insert objRL;
        
        
        
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
        objPaymentPlan.Name ='Pay Plan 1';
        objPaymentPlan.Project__c = objpr.Id;
        objPaymentPlan.Tower__c =  objTwr.Id;
        insert objPaymentPlan;
        
        Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
        objSPP.Project__c = objpr.Id;
        objSPP.Charge_Code__c= PCharge.Id;
        objSPP.Payment_Plan__c=objPaymentPlan.id;
        objSPP.Name='Basic Header';
        objSPP.Plan_Code__c= '89';
        objSPP.tower__c =  objTwr.Id;
        objSPP.Effective_from__c = System.today();
        insert objSPP;
        
        Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
        objCPPH.Amount__c=1000000.00;
        objCPPH.Customer__c=objcustomer1.id; 
        objCPPH.Effect_From_Date__c=system.today(); 
        objCPPH.Global_Charges__c=ObjGloChrg.id; 
        objCPPH.Project__c=objpr.id; 
        objCPPH.Project_Unit__c=objPUU1.id; 
        objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
        objCPPH.tower__c =  objTwr.Id;
        objCPPH.Quotation__c = q1.id;
        objCPPH.PlanDt__c=system.today();
        objCPPH.Booking__c = objBking1.id;
        insert objCPPH;
        
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Standard_Pay_Plan_Header__c = objSPP.Id;
        scppd1.Tower__c = objTwr.Id;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppd1.Project__c = objpr.Id;
        scppd1.Customer_Pay_Plan_Header__c = objCPPH.Id;
        scppd1.Due_Date__c = Date.today() + 30;
        scppd1.Milestone_Percentage__c = 10;
        scppd1.Installment__c = 100000;
        insert scppd1;
        
        
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.createCustomer(OIds1);
        
        //Added by coServe 29-06-2022 Start
        
        objBking1.Customer_Category_Type__c = 'Management Bookings';
        update objBking1;
        
        apt6.Address_Proof_Document__c = 'Electricity Bill';
        apt6.PassportNoDetails__c = '12547865';
        update apt6;
        
        CustomerUpdateCallout.afterUpdateApplicant(OIds1);
        //Added by coServe 29-06-2022 End
    }
    
    //Added by coServe 29-06-2022 Start
     @isTest
    private static void testUpdateCustmr(){
       Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Other Charges';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        objTwr.Property_Type__c = 'Residential';
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        objCP5.Parking__c = 'Covered Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Car_Parking_Charge__c objCP6 = new Car_Parking_Charge__c();
        objCP6.Status__c = 'Vacant';
        objCP6.Category__c = 'Additional';
        objCP6.Parking__c = 'Stilt';
        objCP6.Project__c = objpr.Id;
        insert objCP6;
            
        Car_Parking_Charge__c objCP7 = new Car_Parking_Charge__c();
        objCP7.Status__c = 'Vacant';
        objCP7.Category__c = 'Additional';
        objCP7.Parking__c = 'MLCP';
        objCP7.Project__c = objpr.Id;
        insert objCP7;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
             
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        insert objcustomer1;
        
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        q1.CAM_Charges__c = 1000;
        q1.BCAM_Charges__c = 100;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        objBking1.Brokerage__c = 10;
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ADERG5885F';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        apt6.Gender__c = 'FeMale';
        apt6.Organization_Name__c = 'ABC';
        insert apt6;
        
        Applicant_Details__c apt7 = new Applicant_Details__c();
        apt7.Name = 'Applicant 1';
        apt7.Permanent_Address__c = 'test address';
        apt7.Opportunity__c = objcustomer1.Id;
        apt7.Applicant_Number__c = 'Second Applicant';
        apt7.Subtype_Of_Applicant__c = 'For Company';
        apt7.Type_Of_Applicant__c= 'Individual Buyer';
        apt7.Booking__c = objBking1.Id;
        apt7.DOB__c = Date.today();
        apt7.Office_Address_Line_1__c = 'Office Address Line 1';
        apt7.Mobile_Number__c = '1234567890';
        apt7.Email_Address__c = 'test@test.com';
        apt7.PancardNo__c = 'ABC123456';
        apt7.Address_Proof__c = true;
        apt7.Address_Proof_Document__c = 'Aadhar Card';
        //apt7.PancardNo__c = 'abc213456';
        apt7.Gender__c = 'Male';
        apt7.Organization_Name__c = 'ABC';
        apt7.Designation_picklist__c = 'Analyst';
        apt7.Occupation__c = 'Accounting';
        insert apt7;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        Rate_List_Header__c objRlh = new Rate_List_Header__c();
        objRlh.Name = 'Basic RL Header';
        objRlh.Project__c = objpr.Id;
        objRlh.Project_Charges__c = PCharge.Id;
        objRlh.Rate_list__c = 'All Charges';
        objRlh.Effective_From__c = system.today().addDays(-3);
        insert objRlh;
        
        Rate_List__c objRL = new Rate_List__c();
        objRL.Rate_List_HeaderID__c = objRlh.Id;
        objRL.Project__c = objpr.Id;
        objRL.Global_Charges__c = ObjGloChrg.Id;
        objRL.Project_Charges__c = PCharge.Id;
        objRL.Project_Unit__c = objPUU1.Id;
        objRL.Charge_Based_On_Master__c = 'Rate';
        objRL.Value__c = 2218;
        objRL.Rate__c = 23600;
        objRL.Amount__c = 100000;
        insert objRL;
        
        
        
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
        objPaymentPlan.Name ='Pay Plan 1';
        objPaymentPlan.Project__c = objpr.Id;
        objPaymentPlan.Tower__c =  objTwr.Id;
        insert objPaymentPlan;
        
        Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
        objSPP.Project__c = objpr.Id;
        objSPP.Charge_Code__c= PCharge.Id;
        objSPP.Payment_Plan__c=objPaymentPlan.id;
        objSPP.Name='Basic Header';
        objSPP.Plan_Code__c= '89';
        objSPP.tower__c =  objTwr.Id;
        objSPP.Effective_from__c = System.today();
        insert objSPP;
        
        Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
        objCPPH.Amount__c=1000000.00;
        objCPPH.Customer__c=objcustomer1.id; 
        objCPPH.Effect_From_Date__c=system.today(); 
        objCPPH.Global_Charges__c=ObjGloChrg.id; 
        objCPPH.Project__c=objpr.id; 
        objCPPH.Project_Unit__c=objPUU1.id; 
        objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
        objCPPH.tower__c =  objTwr.Id;
        objCPPH.Quotation__c = q1.id;
        objCPPH.PlanDt__c=system.today();
        objCPPH.Booking__c = objBking1.id;
        insert objCPPH;
        
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Standard_Pay_Plan_Header__c = objSPP.Id;
        scppd1.Tower__c = objTwr.Id;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppd1.Project__c = objpr.Id;
        scppd1.Customer_Pay_Plan_Header__c = objCPPH.Id;
        scppd1.Due_Date__c = Date.today() + 30;
        scppd1.Milestone_Percentage__c = 10;
        scppd1.Installment__c = 100000;
        insert scppd1;
        
        
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.createCustomer(OIds1);
        
        objBking1.Customer_Category_Type__c = 'Management Bookings';
        update objBking1;
        
        apt6.Address_Proof_Document__c = 'Driving License';
        //update apt6;
        
        CustomerUpdateCallout.afterUpdateApplicant(OIds1);
        
    }
    //Added by coServe 29-06-2022 End
    @isTest
    private static void testGenerateSOReferral(){
       Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Tower__c objTwr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        Set<Id> OIds = new Set<Id>();
        Set<Id> OIds1 = new Set<Id>();
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '2000';
        objpr.Allotment_Charges_1__c = 1000;
        objpr.Allotment_Charges_2__c = 1000;
        objpr.Allotment_Charges_3__c = 1000;
        objpr.Allotment_Charges_4__c = 1000;
        objpr.Allotment_Charges_5__c = 1000;
        insert objpr;
        
        Global_Charges__c ObjGloChrg = new Global_Charges__c();
        ObjGloChrg.Name = 'Basic';
        ObjGloChrg.Code__c = '011';
        ObjGloChrg.Description__c = 'Basic';
        ObjGloChrg.Sequence_No__c = 99;
        ObjGloChrg.Charge_Type__c = 'Basic';
        ObjGloChrg.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg.SAP_Material_Code__c = '3000';
        ObjGloChrg.SAP_Material_Type__c = 'TST001';
        ObjGloChrg.SAP_Condition_Type__c = 'ABC0';
        ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
        
        Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
        ObjGloChrg1.Name = 'Allotment Charges';
        ObjGloChrg1.Code__c = '012';
        ObjGloChrg1.Description__c = 'Allotment Charges';
        ObjGloChrg1.Sequence_No__c = 100;
        ObjGloChrg1.Charge_Type__c = 'Society Charges';
        ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg1.SAP_Material_Code__c = '3001';
        ObjGloChrg1.SAP_Material_Type__c = 'TST002';
        ObjGloChrg1.SAP_Condition_Type__c = 'ABC1';
        ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
        
        Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
        ObjGloChrg2.Name = 'Tax Charge';
        ObjGloChrg2.Code__c = '015';
        ObjGloChrg2.Description__c = 'SERVICE TAX';
        ObjGloChrg2.Sequence_No__c = 105;
        ObjGloChrg2.Charge_Type__c = 'Tax';
        ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
        ObjGloChrg2.SAP_Material_Code__c = '3002';
        ObjGloChrg2.SAP_Material_Type__c = 'TST003';
        ObjGloChrg2.SAP_Condition_Type__c = 'ABC2';
        ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
        
        Project_Charges__c PCharge = new Project_Charges__c();
        PCharge.Charge_Code__c = ObjGloChrg.Id;
        PCharge.Project__c = objpr.Id;
        PCharge.Name = 'Basic';
        PCharge.Active__c = true;
        PCharge.Applied_This_Charge_To_FA__c = true;
        PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
        PCharge.S_Charge_Bucket__c = 'Other Charges';
        PCharge.S_Payable_At__c = 'As per payment milestone';
        PCharge.Payment_Plan_Applicable__c = true;
        pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
        pCharge.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge=RDSCommon.CreateProjectCharges(PCharge);
        
        Project_Charges__c PCharge1 = new Project_Charges__c();
        PCharge1.Charge_Code__c = ObjGloChrg1.Id;
        PCharge1.Project__c = objpr.Id;
        PCharge1.Name = 'Allotment Charges';
        PCharge1.Active__c = true;
        PCharge1.Applied_This_Charge_To_FA__c = true;
        PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
        pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
        PCharge1.S_Charge_Bucket__c = 'Society Charges';
        PCharge1.S_Payable_At__c = 'At Possession';
        PCharge1.Payment_Plan_Applicable__c = true;
        PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
        PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
        PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
        
        objTwr = new Tower__c();
		objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        objTwr.Property_Type__c = 'Residential';
        insert objTwr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
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
        objCP5.Parking__c = 'Covered Stack';
        objCP5.Project__c = objpr.Id;
        insert objCP5;
        
        Car_Parking_Charge__c objCP6 = new Car_Parking_Charge__c();
        objCP6.Status__c = 'Vacant';
        objCP6.Category__c = 'Additional';
        objCP6.Parking__c = 'Stilt';
        objCP6.Project__c = objpr.Id;
        insert objCP6;
            
        Car_Parking_Charge__c objCP7 = new Car_Parking_Charge__c();
        objCP7.Status__c = 'Vacant';
        objCP7.Category__c = 'Additional';
        objCP7.Parking__c = 'MLCP';
        objCP7.Project__c = objpr.Id;
        insert objCP7;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
            
        
        Broker__c chp1 = new Broker__c();
        chp1.Name = 'Channel Partner 1';
        chp1.RW_RERA_Registration_Number__c = 'abc123456789';
        chp1.RW_Mobile_No__c = '1234567890';
        chp1.Representative_Name__c = 'Representative 1';
        chp1.Broker_Pan_No__c = 'ABC2345345';
        chp1.SAP_CP_Code__c = '1000';
        Id cpRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();        
        chp1.RecordTypeId = cpRecordTypeId;
        insert chp1;
        Test.setMock(WebServiceMock.class, new CustomerCreationWebServiceMockImpl());
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        objcustomer1.CloseDate=system.today()+7;
        objcustomer1.Status__c ='Active';
        objCustomer1.AccountId = a.Id;
        objcustomer1.Sales_Manager__c = 'SM2@g.com';
        objcustomer1.RW_Rating__c = 'Hot';
        objcustomer1.Remark__c = 'test remarks';
        objcustomer1.LeadSource = 'Direct';
        objcustomer1.Walkin_Source__c = 'Channel Partner';
        //objcustomer1.RW_Walkin_Channel_Partner__c = chp1.Id;
        objcustomer1.Lead_Sub_Source__c = 'Digital';
        objcustomer1.Sourcing_Manager__c = 'Aniket Sapre';
        objcustomer1.RW_Sales_Associate__c = 'DIRECT';
        objcustomer1.SAP_Customer_Number__c = '213456782134';
        objcustomer1.Walkin_Source__c = 'Referral';
        objcustomer1.Referral_Sub_Source__c = 'Existing client reference';
        insert objcustomer1;
        
     
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id; 
        objPUU1.TowerName__c = objTwr.Id;
        objPUU1.Name = 'TestUnit';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='91';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.RW_Customer__c = objcustomer1.Id;
        objPUU1.RW_Base_Rate__c = 3000;
        objPUU1.Saleable_Area__c = 10000;
        objPUU1.Floor_Rise__c = 0;
        objPUU1.RW_PLC__c = 200;
        objPUU1.Unit_SAP_Code__c = '1002';
        insert objPUU1;
        
             
        Quotation__c q1 = new Quotation__c();
        q1.Name = 'Q010101';
        q1.Total_Discount_L__c = 10000;
        q1.Discount_1_Type__c = 'GST Discount';
        q1.Premium_Charges_Amount_1__c = 30000;
        q1.Quote_Status__c = 'Valid';
        q1.Prepared_Date__c = System.today();
        q1.Project__c = objpr.Id;
        q1.Project_Unit__c = objPUU1.Id;
        q1.FloorNo__c = 11;
        q1.Opportunity__c = objcustomer1.Id;
        q1.Appartment_Configuration__c = '1 BHK';
        q1.Carpet_Area_Sq_Ft__c = 1200;
        q1.Token_Amount__c =110000;
        q1.ST_Token_Amount__c = 1000;
        q1.Allow_booking_without_full_token__c = TRUE;
        q1.Agreement_Value__c = 60422880;
        q1.Agreement_Value_ST__c = 2537761;
        q1.Tandem_car_park_Additional__c = 0;
        q1.Tandem_Open_Additional__c= 0;
        q1.Single_car_park_Additional__c= 0;
        q1.Single_Open_Additional__c = 0;
        q1.Stack_Additional__c = 0;
        q1.CAM_Charges__c = 1000;
        q1.BCAM_Charges__c = 100;
        q1.Discount_9_L__c = 100;
        q1.Discount_10_L__c = 100;
        q1.Discount_11_L__c = 100;
        insert q1;
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 200000;
        r2.Cheque_DD__c = '908888';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU1.Id;
        r2.Opportunity__c = objcustomer1.Id;
        r2.CheckReceipt__c = true;
        r2.Token_Amount_Receipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'Axis Bank';
        r2.Total_Amount__c = 200000;
        r2.Currency__c = 'Indian Rupee';
        insert r2;
        
        Booking__c objBking1 = new Booking__c();
        objBking1.Customer__c = objcustomer1.Id;
        objBking1.Project__c = objpr.Id;
        objBking1.Opportunity__c = objcustomer1.Id;
        objBking1.Unit_No__c = objPUU1.id;
        objBking1.Quotation__c = q1.Id;
        objBking1.Receipts__c = r2.Id;
        objBking1.Booking_Date__c = Date.today();
        objBking1.Brokerage__c = 10;
        insert objBking1;
        
        objCP1.Booking__c = objBking1.Id;
        update objCP1;
        objCP2.Booking__c = objBking1.Id;
        update objCP2;
		objCP3.Booking__c = objBking1.Id;
        update objCP3;
		objCP4.Booking__c = objBking1.Id;
        update objCP4;
		objCP5.Booking__c = objBking1.Id;
        update objCP5;     
        
        Applicant_Details__c apt6 = new Applicant_Details__c();
        apt6.Name = 'Applicant 1';
        apt6.Permanent_Address__c = 'test address';
        apt6.Opportunity__c = objcustomer1.Id;
        apt6.Applicant_Number__c = 'Primary Applicant';
        apt6.Subtype_Of_Applicant__c = 'Indian National';
        apt6.Type_Of_Applicant__c= 'Individual Buyer';
        apt6.Booking__c = objBking1.Id;
        apt6.DOB__c = Date.today();
        apt6.Office_Address_Line_1__c = 'Office Address Line 1';
        apt6.Mobile_Number__c = '1234567890';
        apt6.Email_Address__c = 'test@test.com';
        apt6.PancardNo__c = 'ABC123456';
        apt6.Address_Proof__c = true;
        apt6.Address_Proof_Document__c = 'Passport';
        //apt6.PancardNo__c = 'abc213456';
        insert apt6;
        
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.Booking__c = objBking1.Id;
        update objcustomer1;
        
        objPUU1.RW_Unit_Status__c ='Booked';
        objPUU1.RW_Booking_Date__c = Date.today();
        objPUU1.Booking__c = objBking1.Id;
        update objPUU1;
        
        Rate_List_Header__c objRlh = new Rate_List_Header__c();
        objRlh.Name = 'Basic RL Header';
        objRlh.Project__c = objpr.Id;
        objRlh.Project_Charges__c = PCharge.Id;
        objRlh.Rate_list__c = 'All Charges';
        objRlh.Effective_From__c = system.today().addDays(-3);
        insert objRlh;
        
        Rate_List__c objRL = new Rate_List__c();
        objRL.Rate_List_HeaderID__c = objRlh.Id;
        objRL.Project__c = objpr.Id;
        objRL.Global_Charges__c = ObjGloChrg.Id;
        objRL.Project_Charges__c = PCharge.Id;
        objRL.Project_Unit__c = objPUU1.Id;
        objRL.Charge_Based_On_Master__c = 'Rate';
        objRL.Value__c = 2218;
        objRL.Rate__c = 23600;
        objRL.Amount__c = 100000;
        objRL.Charge_on_Area_Type__c = 'Saleable Area';
        insert objRL;
        
        
        
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
        objPaymentPlan.Name ='Pay Plan 1';
        objPaymentPlan.Project__c = objpr.Id;
        objPaymentPlan.Tower__c =  objTwr.Id;
        insert objPaymentPlan;
        
        Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
        objSPP.Project__c = objpr.Id;
        objSPP.Charge_Code__c= PCharge.Id;
        objSPP.Payment_Plan__c=objPaymentPlan.id;
        objSPP.Name='Basic Header';
        objSPP.Plan_Code__c= '89';
        objSPP.tower__c =  objTwr.Id;
        objSPP.Effective_from__c = System.today();
        insert objSPP;
        
        Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
        objCPPH.Amount__c=1000000.00;
        objCPPH.Customer__c=objcustomer1.id; 
        objCPPH.Effect_From_Date__c=system.today(); 
        objCPPH.Global_Charges__c=ObjGloChrg.id; 
        objCPPH.Project__c=objpr.id; 
        objCPPH.Project_Unit__c=objPUU1.id; 
        objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
        objCPPH.tower__c =  objTwr.Id;
        objCPPH.Quotation__c = q1.id;
        objCPPH.PlanDt__c=system.today();
        objCPPH.Booking__c = objBking1.id;
        insert objCPPH;
        
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Standard_Pay_Plan_Header__c = objSPP.Id;
        scppd1.Tower__c = objTwr.Id;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppd1.Project__c = objpr.Id;
        scppd1.Customer_Pay_Plan_Header__c = objCPPH.Id;
        scppd1.Due_Date__c = Date.today() + 30;
        scppd1.Milestone_Percentage__c = 10;
        scppd1.Installment__c = 100000;
        insert scppd1;
        
        
        
        OIds1.add(objcustomer1.Id);
        SAPIntegrationServices.generateSalesOrder(OIds1, objcustomer1.SAP_Customer_Number__c);
    }
}