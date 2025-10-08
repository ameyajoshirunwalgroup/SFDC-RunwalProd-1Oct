@isTest
public class testSaleConfirmationSheet
{
    @isTest
    public static void test1()
    {
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
          
		//Primary_Applicant_Email__c = new
        Tower__c t = new Tower__c();
             t.Name = 'Tower X';
             t.ProjectName__c = objpr.Id;
             t = RDSCommon.CreateTower(t);
             
    

          
        objPUU = new Project_Unit__c();  
        //objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.Saleable_Area__c =1000 ;
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  

        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.Saleable_Area__c = 3000;
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
            objBooking.Unit_No__c=objPUU1.Id;
            objBooking.Advance_Registration_Reference_No__c='R-01';
            objBooking.Sharing_Per_Amt__c='1000.00';
            objBooking.MG_Per_Amt__c='2000.00';
            objBooking.Sharing_Per_Amt_Val__c=1400.00;
            objBooking.Quotation__c = q.Id;
            objBooking.Future_Correspondence_Contact__c = 'First Applicant';
            objBooking.Status__c = 'Booking In Process';
            objBooking.Opportunity__c = objcustomer.id;
        	objBooking.Source_of_Booking__c='Channel Partner';
            //objBooking.ownerId = a1.id;
            insert objBooking;
        
        Applicant_Details__c ad1 = new Applicant_Details__c();
            ad1.Name = 'A One';
            ad1.Type_Of_Applicant__c = 'Individual Buyer';
            ad1.Subtype_Of_Applicant__c = 'Indian National';
            ad1.One_Passport_Size_Color_Photograph__c = true;
            ad1.Permanent_Address__c = 'Perma Addressia';
            ad1.Mailing_Address__c = 'Perma Addressia';
            ad1.Organization_Address__c = 'Perma Addressia';
            ad1.Organisation_Pincode__c = 123456;
            ad1.Organisation_Country__c = 'India';
            ad1.Email_Address__c = 'a1.one@gmail.com';
            ad1.Mobile_Number__c = '989898989';
            ad1.DOB__c = system.today().addMonths(-12);
            ad1.Booking__c = objBooking.Id;
            ad1.Applicant_Number__c = 'Primary Applicant';
            
            insert ad1;
        // construction stage creation
             // two stages are being created
             Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
             objPCS.Project__c = objpr.Id;
             objPCS.Name = 'Commencement of Raft/Foundation';
             objPCS.Code__c ='Test';
             objPCS.Description__c='Commencement of Raft/Foundation';
             objPCS.Planned_date_of_completion__c = System.today().addDays(365);
             objPCS.Tower__c = t.Id;
             objPCS.Sequence_No__c = 1;
             insert objPCS;
             
            // payment plan creation associated to the construction stages
             Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
             objPaymentPlan.Name ='Pay Plan 1';
             objPaymentPlan.Project__c = objpr .Id;
             objPaymentPlan.Tower__c = t.Id;
             insert objPaymentPlan;
             
           // global charges creation
             Global_Charges__c ObjGloChrg = new Global_Charges__c();
             ObjGloChrg.Name = 'Basic';
             ObjGloChrg.Code__c = '011';
             ObjGloChrg.Description__c = 'Basic';
             ObjGloChrg.Sequence_No__c = 99;
             ObjGloChrg.Charge_Type__c = 'Basic';
             ObjGloChrg.Nature_of_Charge__c = 'Debtors';
             ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
             
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
             
              Rate_List_Header__c objRlh = new Rate_List_Header__c();
             objRlh.Name = 'Basic RL Header';
             objRlh.Project__c = objpr.Id;
             objRlh.Project_Charges__c = PCharge.Id;
             objRlh.Rate_list__c = 'All Charges';
             objRlh.Effective_From__c = system.today().addDays(-3);
             objRlh=RDSCommon.CreateRateListHeader(objRlh);
             
              Rate_List__c objRL = new Rate_List__c();
             objRL.Rate_List_HeaderID__c = objRlh.Id;
             objRL.Project__c = objpr.Id;
             objRL.Global_Charges__c = ObjGloChrg.Id;
             objRL.Project_Charges__c = PCharge.Id;
             objRL.Project_Unit__c = objPUU1.Id;
             objRL.Value__c = 2218;
             objRL.Rate__c = 23600;
             objRL.Charge_Based_On_Master__c = 'Rate';
             //objRL.Rate_List_Detail__c = objRLd.id;
             objRL=RDSCommon.CreateRateList(objRL);
        
             Rate_List__c objRL1 = new Rate_List__c();
             objRL1.Rate_List_HeaderID__c = objRlh.Id;
             objRL1.Project__c = objpr.Id;
             objRL1.Global_Charges__c = ObjGloChrg.Id;
             objRL1.Project_Charges__c = PCharge.Id;
             objRL1.Project_Unit__c = objPUU1.Id;
             objRL1.Value__c = 2218;
             objRL1.Rate__c = 23600;
        	 objRL1.Amount__c = 23600;
         	 objRL1.ChargeCost__c= 2333600;
             objRL1.Charge_Based_On_Master__c = 'Lumpsum';
             //objRL.Rate_List_Detail__c = objRLd.id;
             objRL1=RDSCommon.CreateRateList(objRL1);
             
              // standard payment plan header creation
             Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
             objSPP.Project__c = objpr.Id;
             objSPP.Charge_Code__c= PCharge.Id;
             objSPP.Payment_Plan__c=objPaymentPlan.id;
             objSPP.Name='Basic Header';
             objSPP.Plan_Code__c= '89';
             objSPP.tower__c = t.ID;
             objSPP.Effective_from__c = System.today();
             objSPP=RDSCommon.CreateStandardPayPlanHeader(objSPP);
             
              Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
              objCPPH.Amount__c=1000000.00;
              objCPPH.Customer__c=objcustomer.id; 
              objCPPH.Effect_From_Date__c=system.today(); 
              objCPPH.Global_Charges__c=ObjGloChrg.id; 
              objCPPH.Project__c=objpr.id; 
              objCPPH.Project_Unit__c=objPUU1.id; 
              objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
              objCPPH.tower__c = t.ID;
              objCPPH.Quotation__c = q.id;
              objCPPH.PlanDt__c=system.today();
              objCPPH.Booking__c = objBooking.id;
              insert objCPPH;
              
              Standard_Customer_Pay_Plan_Detail__c    objSPPD4 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD4.Standard_Pay_Plan_Header__c = objSPP.id;
             objSPPD4.Project__c=objpr.id;
             objSPPD4.tower__c = t.ID;
             objSPPD4.Is_to_be_Paid__c='From Dt. of Booking';
             objSPPD4.Days_Months__c='Day(s)';
             objSPPD4.Days_Months_Value__c=0;
             objSPPD4.Amount__c='Amount';
             objSPPD4.Calculate_Installment_Amount_as__c=10;
             objSPPD4.Total_Charge_Value_Minus__c = 110000;
             objSPPD4.Customer_Pay_Plan_Header__c = objCPPH.Id;
             objSPPD4= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD4);
         PageReference rPage = Page.SaleConfirmationSheet_VFP;
            Test.setCurrentPage(rPage);
            
            ApexPages.currentPage().getParameters().put('id', objBooking.id);
           SaleConfirmationSheet scp = new SaleConfirmationSheet();
        
        
                
    }
}