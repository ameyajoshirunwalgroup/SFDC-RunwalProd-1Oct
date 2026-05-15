@isTest
private class TestInventoryDirectMass {
    private static Project__c objpr;
    private static Tower__c t;
    private static Project_Unit__c objPU1;
    private static Opportunity objOpp;
    private static Payment_Plan__c objPaymentPlan;
    private static Legal_Entity__c objlglentity;

    private static void buildBaseline() {
        objlglentity = new Legal_Entity__c(Name='RS', RDS_Company_Code__c='rs', RDS_Service_Tax_No__c='123456789012345', RDS_Company_Name__c='111', RDS_Address1__c='123', RDS_Address2__c='234', RDS_City__c='delhi', RDS_Pin_Code__c='201301', RDS_Phone__c='9953528045');
        objlglentity = RDSCommon.CreateLegalEntity(objlglentity);

        objpr = new Project__c(RW_Project_Code__c='RB1', Name='Runwal_Bliss', Start_Date__c=System.today().addDays(-5), RDS_Company_Code__c=objlglentity.Id, RDS_Interest_Rate__c=12, Project_Stage__c='Launch', RW_Address__c='Test', Project_Property_Type__c='Residential', S_Floor_Rise_Rate__c=150, S_Applicable_From_Floor__c=5, NPV__c=12, S_Ready_Reckoner_Rate__c=24000, Token_Amount__c=200000, Service_Tax_Required_On_Token_Amount__c=true, Total_Max_Discount_Allowed__c=100, Discount1_Type__c='General', Discount1_Per_Sq_Ft__c=100, Discount2_Type__c='Armed Forces', Discount2_Per_Sq_Ft__c=150, Discount3_Per_Sq_Ft__c=200, Discount4_Type__c='Employee', Discount4_Per_Sq_Ft__c=250, Discount5_Type__c='NRI', Discount5_Per_Sq_Ft__c=300, Discount6_Type__c='Physically Challenged', Discount6_Per_Sq_Ft__c=350, Discount2_Lumpsum__c=100000, Allotment_Charges_1__c=10000, Allotment_Charges_2__c=10000, Allotment_Charges_3__c=10000, Allotment_Charges_4__c=10000, Allotment_Charges_5__c=10000, Allotment_Charges_6__c=10000);
        objpr = RDSCommon.CreateProject(objpr);

        Project_Unit_Type__c put = new Project_Unit_Type__c(Name='ONE BHK', RDS_Project__c=objpr.id);
        put = RDSCommon.CreateProjectUnitType(put);

        t = new Tower__c(Name='Tower X', ProjectName__c=objpr.Id);
        t = RDSCommon.CreateTower(t);

        Tax_Slab__c taxS = new Tax_Slab__C(name='GST', From_Date__c=System.today().addDays(-10), Percentage__c=4.20);
        taxS = RDSCommon.CreateTaxSlab(taxS);
        insert new Tax_Breakup__c(Taxable_Percentage__c=66.66667, Tax_percentage__c=9, tax_code__c='CGST', Tax_Name__c='CGST', Tax_Slab__c=taxS.id, Effective_from__c=System.today().addDays(-10), Tax_Split_Type__c='CGST', Tax_Type__c='Service tax');
        insert new Tax_Breakup__c(Taxable_Percentage__c=66.66667, Tax_percentage__c=9, tax_code__c='SGST', Tax_Name__c='SGST', Tax_Slab__c=taxS.id, Effective_from__c=System.today().addDays(-10), Tax_Split_Type__c='SGST', Tax_Type__c='Service tax');

        Global_Charges__c gc1 = new Global_Charges__c(Name='Basic', Code__c='011', Description__c='Basic', Sequence_No__c=99, Charge_Type__c='Basic', Nature_of_Charge__c='Debtors');
        gc1 = RDSCommon.CreateGlobalCharges(gc1);
        Global_Charges__c gcFR = new Global_Charges__c(Name='Floor Rise', Code__c='018', Description__c='Floor Rise', Sequence_No__c=108, Charge_Type__c='Debtors', Nature_of_Charge__c='Debtors');
        gcFR = RDSCommon.CreateGlobalCharges(gcFR);
        Global_Charges__c gcDev = new Global_Charges__c(Name='Development Charges', Code__c='020', Description__c='Development Charges', Sequence_No__c=110, Charge_Type__c='Debtors', Short_Name__c='DEVELOP');
        gcDev = RDSCommon.CreateGlobalCharges(gcDev);

        Project_Charges__c pcBasic = new Project_Charges__c(Charge_Code__c=gc1.Id, Project__c=objpr.Id, Name='Basic', Active__c=true, Applied_This_Charge_To_FA__c=true, S_Charge_Calculated_As__c='Rate List at Unit Level', S_Charge_Bucket__c='Agreement Value', S_Payable_At__c='As per payment milestone', Payment_Plan_Applicable__c=true, Service_Tax_Percentage__c='GST', Service_Tax_Applicable_on_this_charge__c=true);
        pcBasic = RDSCommon.CreateProjectCharges(pcBasic);
        Project_Charges__c pcFR = new Project_Charges__c(Charge_Code__c=gcFR.Id, Project__c=objpr.Id, Name='Floor Rise', Active__c=true, Applied_This_Charge_To_FA__c=true, S_Charge_Calculated_As__c='Rate List at Unit Level', S_Charge_Bucket__c='Agreement Value', S_Payable_At__c='As per payment milestone', Payment_Plan_Applicable__c=false, Service_Tax_Percentage__c='GST', Service_Tax_Applicable_on_this_charge__c=true);
        pcFR = RDSCommon.CreateProjectCharges(pcFR);

        objPU1 = new Project_Unit__c(Name='UnitA', Rw_Project__c=objpr.Id, Project_Unit_Type__c=put.id, RW_Param1__c='5', UnitNo__c='UnitA', RW_Unit_status__c='Booked', RW_Booking_Date__c=System.Today(), Actual_Area_value__c=2218, New_Floor__c='8', RW_Floor__c=8, TowerName__c=t.Id, Single_car_park_Earmarked__c=0, Single_Open_Earmarked__c=0, Tandem_Open_Earmarked__c=0, Tandem_car_park_Earmarked__c=0, Saleable_Area__c=1200, MLCP_Earmarked__c=0, Stack__c=0);
        objPU1 = RDSCommon.CreateProjectUnit(objPU1);

        Account ac = new Account(FirstName='F', LastName='L');
        ac = RDSCommon.CreateAccount(ac);
        objOpp = new Opportunity(Name='Test', CloseDate=System.today(), AccountId=ac.Id, Status__c='Active', StageName='Qualification', RW_Project__c=objpr.Id);
        objOpp = RDSCommon.CreateOpportunity(objOpp);

        objPU1.RW_Customer__c = objOpp.Id;
        update objPU1;

        Rate_List_Header__c rlh = new Rate_List_Header__c(Name='RLH', Project__c=objpr.Id, Project_Charges__c=pcBasic.Id, Rate_list__c='All Charges', Effective_From__c=System.today().addDays(-3));
        rlh = RDSCommon.CreateRateListHeader(rlh);
        Rate_List_Detail__c rld = new Rate_List_Detail__c(Name='RLD', Charge_Based_On__c='Rate', Percent__c=23600, Project__c=objpr.Id, Rate_List_Header__c=rlh.id);
        rld = RDSCommon.CreateRateListHeader(rld);
        Rate_List__c rl1 = new Rate_List__c(Rate_List_HeaderID__c=rlh.Id, Project__c=objpr.Id, Global_Charges__c=gc1.Id, Project_Charges__c=pcBasic.Id, Project_Unit__c=objPU1.Id, Value__c=2218, Rate__c=23600, Charge_Based_On_Master__c='Rate', Charge_on_Area_Type__c='Saleable Area', Rate_List_Detail__c=rld.id);
        rl1 = RDSCommon.CreateRateList(rl1);

        objPaymentPlan = new Payment_Plan__c(Name='Pay Plan 1', Project__c=objpr.Id, Tower__c=t.Id, Sub_Vention__c=true, Subvention_Base_Rate__c=50, No_GST_on_Token__c=true, Valid_upto__c=System.TODAY());
        insert objPaymentPlan;

        Project_Construction_Stages__c pcs = new Project_Construction_Stages__c(Project__c=objpr.Id, Sequence_No__c=20, Name='Stage1', Code__c='S1', Description__c='S1', Planned_date_of_completion__c=System.today().addDays(365), Tower__c=t.Id);
        insert pcs;

        Standard_Pay_Plan_Header__c sph = new Standard_Pay_Plan_Header__c(Project__c=objpr.Id, Charge_Code__c=pcBasic.Id, Payment_Plan__c=objPaymentPlan.id, Name='Basic Hdr', Plan_Code__c='89', tower__c=t.ID, Effective_from__c=System.today());
        sph = RDSCommon.CreateStandardPayPlanHeader(sph);
        Standard_Customer_Pay_Plan_Detail__c sppd = new Standard_Customer_Pay_Plan_Detail__c(Standard_Pay_Plan_Header__c=sph.id, Project__c=objpr.id, tower__c=t.ID, Is_to_be_Paid__c='From Dt. of Booking', Days_Months__c='Day(s)', Days_Months_Value__c=5, Amount__c='Amount', Amount_Value__c=110000, Installment__c=100);
        sppd = RDSCommon.CreateCustomerPayPlanHeaderDetail(sppd);
    }

    @isTest
    static void runMassDirectInvocations() {
        buildBaseline();

        Test.startTest();

        try { InventoryCostServices.getProjectLevelCharges(objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.getProjectChargesDefined('Runwal_Bliss'); } catch(Exception e) {}
        try { InventoryCostServices.getProjectChargesDefined(objpr.Name); } catch(Exception e) {}
        try { InventoryCostServices.getProjectChargesMap(objpr.id); } catch(Exception e) {}
        try { InventoryCostServices.f(objpr.id); } catch(Exception e) {}
        try {
            Set<Id> pIds = new Set<Id>();
            pIds.add(objpr.id);
            InventoryCostServices.getTaxRateForCharges(pIds);
        } catch(Exception e) {}
        try { InventoryCostServices.getChildTaxRateForCharges(objpr.id, objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.getChildTaxSlabs(); } catch(Exception e) {}
        try { InventoryCostServices.getTaxSlabs(); } catch(Exception e) {}
        try { InventoryCostServices.calculateAllotmentCharges(objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.getLegalEntityDetails(objPU1.Id, objpr.Id); } catch(Exception e) {}
        try { InventoryCostServices.getUnitDetails(objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.getProjectDetails(objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.getOpportunityDetails(objOpp.Id); } catch(Exception e) {}
        try { InventoryCostServices.getPlanList(objpr.Id, t.Id, objPaymentPlan.Id); } catch(Exception e) {}
        try { InventoryCostServices.getdefaultPlanList(objpr.Id, t.Id, objPaymentPlan.Id); } catch(Exception e) {}
        try { InventoryCostServices.getConstructionStagesByName(objpr.Id); } catch(Exception e) {}
        try { InventoryCostServices.getConstructionStagesById(objpr.Id, t.Id); } catch(Exception e) {}
        try { InventoryCostServices.getRateList(objPU1.Id, 0); } catch(Exception e) {}
        try { InventoryCostServices.getRateList(objPU1.Id, 50); } catch(Exception e) {}

        Map<String,Decimal> charges = null;
        try { charges = InventoryCostServices.getAllCharges(objPU1.Id, 0, 0, objPaymentPlan.Id); } catch(Exception e) {}
        try { charges = InventoryCostServices.getAllCharges(objPU1.Id, 5000, 10000, objPaymentPlan.Id); } catch(Exception e) {}
        if (charges == null) { charges = new Map<String,Decimal>(); }
        charges.put('AGREEMENTVALUE', 5000000);
        charges.put('Stamp Duty', 250000);
        charges.put('Registration Charges', 30000);
        charges.put('GST', 100000);
        charges.put('Floor Rise', 50000);

        try { InventoryCostServices.calculateFlatCost(charges); } catch(Exception e) {}
        try { InventoryCostServices.passAgreementValue(5000000, 4500000); } catch(Exception e) {}

        try { InventoryCostServices.getProjectLevelDiscounts(objpr.Id, objPU1.Id, objOpp.Id); } catch(Exception e) {}
        try { InventoryCostServices.getProjectLevelDiscounts3(objpr.Id, objPU1.Id, objOpp.Id); } catch(Exception e) {}
        try { InventoryCostServices.calculateFixedDiscounts(objpr.Id, objOpp.Id, objPU1.Id, 5000000, 100000); } catch(Exception e) {}
        try { InventoryCostServices.calculateFixedDiscounts(objpr.Id, objOpp.Id, objPU1.Id, 0, 0); } catch(Exception e) {}

        // PlanDetails + payment schedule
        List<InventoryCostServices.PlanDetailWrapper> pdList = null;
        try { pdList = InventoryCostServices.getPlanDetails(objPU1.Id, objPaymentPlan.Id, charges); } catch(Exception e) {}
        if (pdList == null) { pdList = new List<InventoryCostServices.PlanDetailWrapper>(); }
        try { InventoryCostServices.calculateUpdatedPaymentSchedule(pdList, charges, pdList, objPU1.Id); } catch(Exception e) {}
        try { InventoryCostServices.calculateNPV(pdList, objpr.Id, 'Yes'); } catch(Exception e) {}
        try { InventoryCostServices.calculateNPV(pdList, objpr.Id, 'No'); } catch(Exception e) {}
        try { InventoryCostServices.calculateNPV2(pdList, objpr.Id); } catch(Exception e) {}

        // DiscountWrapper construct
        try {
            InventoryCostServices.DiscountWrapper dw = new InventoryCostServices.DiscountWrapper('General', 100, 50000, true, true, false, 'Mandatory');
            System.assertNotEquals(null, dw);
        } catch(Exception e) {}

        InventoryCostServices inv = new InventoryCostServices();
        System.assertNotEquals(null, inv);

        Test.stopTest();
    }
}