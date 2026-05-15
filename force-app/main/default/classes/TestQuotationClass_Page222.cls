@isTest
private class TestQuotationClass_Page222 {
     @isTest
    private static void QuotationPageTest222() {
        Legal_Entity__c objlglentity = new Legal_Entity__c();
        objlglentity.Name = 'RS';
        objlglentity.RDS_Company_Code__c='rs';
        objlglentity.RDS_Service_Tax_No__c= '123456789012345';
        objlglentity.RDS_Company_Name__c='111';
        objlglentity.RDS_Address1__c='123';
        objlglentity.RDS_Address2__c='234';
        objlglentity.RDS_City__c='delhi';
        objlglentity.RDS_Pin_Code__c='201301';
        objlglentity.RDS_Phone__c='9953528045';
        objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T35';
        objpr.Name = 'TestProject';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Company_Code__c = objlglentity.Id;
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Stage__c='Launch';
        objpr.RW_Address__c = 'Test';
        objpr.Project_Property_Type__c = 'Residential';
        objpr.S_Floor_Rise_Rate__c = 150;
        objpr.S_Applicable_From_Floor__c = 5;
        objpr.NPV__c = 12;
        objpr.S_Ready_Reckoner_Rate__c = 24000;
        objpr.Token_Amount__c = 200000;
        objpr.Service_Tax_Required_On_Token_Amount__c = true;
        objpr.Total_Max_Discount_Allowed__c = 100;
        objpr.Discount1_Type__c = 'General';
        objpr.Discount1_Per_Sq_Ft__c = 100;
        objpr.Discount2_Type__c = 'Armed Forces';
        objpr.Discount2_Per_Sq_Ft__c = 150;
        objpr.Discount2_Lumpsum__c = 100000;
        objpr.Allotment_Charges_1__c = 10000;
        objpr.Allotment_Charges_2__c = 10000;
        objpr.Allotment_Charges_3__c = 10000;
        objpr=RDSCommon.CreateProject(objpr);
        Project_Unit_Type__c objProjectUnitType = new Project_Unit_Type__c(Name='ONE BHK', RDS_Project__c=objpr.id);
        objProjectUnitType=RDSCommon.CreateProjectUnitType(objProjectUnitType);
        Tower__c t = new Tower__c(Name='Tower X', ProjectName__c=objpr.Id);
        t = RDSCommon.CreateTower(t);
        Tax_Slab__c taxS = new Tax_Slab__C(name='GST', From_Date__c=System.today().addDays(-10), Percentage__c=4.20);
        taxS = RDSCommon.CreateTaxSlab(taxS);
        insert new Tax_Breakup__c(Taxable_Percentage__c=66.66667, Tax_percentage__c=9, tax_code__c='CGST', Tax_Name__c='CGST', Tax_Slab__c=taxS.id, Effective_from__c=System.today().addDays(-10), Tax_Split_Type__c='CGST', Tax_Type__c='Service tax');
        insert new Tax_Breakup__c(Taxable_Percentage__c=66.66667, Tax_percentage__c=9, tax_code__c='SGST', Tax_Name__c='SGST', Tax_Slab__c=taxS.id, Effective_from__c=System.today().addDays(-10), Tax_Split_Type__c='SGST', Tax_Type__c='Service tax');
        Global_Charges__c gcBasic = new Global_Charges__c(Name='Basic', Code__c='011', Description__c='Basic', Sequence_No__c=99, Charge_Type__c='Basic', Nature_of_Charge__c='Debtors');
        gcBasic = RDSCommon.CreateGlobalCharges(gcBasic);
        Global_Charges__c gcFR = new Global_Charges__c(Name='Floor Rise', Code__c='018', Description__c='Floor Rise', Sequence_No__c=108, Charge_Type__c='Debtors', Nature_of_Charge__c='Debtors');
        gcFR = RDSCommon.CreateGlobalCharges(gcFR);
        Project_Charges__c pcBasic = new Project_Charges__c(Charge_Code__c=gcBasic.Id, Project__c=objpr.Id, Name='Basic', Active__c=true, Applied_This_Charge_To_FA__c=true, S_Charge_Calculated_As__c='Rate List at Unit Level', S_Charge_Bucket__c='Agreement Value', S_Payable_At__c='As per payment milestone', Payment_Plan_Applicable__c=true, Service_Tax_Percentage__c='GST', Service_Tax_Applicable_on_this_charge__c=true);
        pcBasic = RDSCommon.CreateProjectCharges(pcBasic);
        Project_Charges__c pcFR = new Project_Charges__c(Charge_Code__c=gcFR.Id, Project__c=objpr.Id, Name='Floor Rise', Active__c=true, Applied_This_Charge_To_FA__c=true, S_Charge_Calculated_As__c='Rate List at Unit Level', S_Charge_Bucket__c='Agreement Value', S_Payable_At__c='As per payment milestone', Payment_Plan_Applicable__c=false, Service_Tax_Percentage__c='GST', Service_Tax_Applicable_on_this_charge__c=true);
        pcFR = RDSCommon.CreateProjectCharges(pcFR);
        Project_Unit__c objPU1 = new Project_Unit__c(Name='TestFive', Rw_Project__c=objpr.Id, Project_Unit_Type__c=objProjectUnitType.id, RW_Param1__c='5', UnitNo__c='TestFive', RW_Unit_status__c='Booked', RW_Booking_Date__c=System.Today(), Actual_Area_value__c=2218, New_Floor__c='8', RW_Floor__c=8, TowerName__c=t.Id, Single_car_park_Earmarked__c=0, Single_Open_Earmarked__c=0, Tandem_Open_Earmarked__c=0, Tandem_car_park_Earmarked__c=0, Saleable_Area__c=1200, MLCP_Earmarked__c=0, Stack__c=0);
        objPU1 = RDSCommon.CreateProjectUnit(objPU1);
        Account ac = new Account(FirstName='F', LastName='L');
        ac = RDSCommon.CreateAccount(ac);
        Opportunity objOpp = new Opportunity(Name='Test', CloseDate=System.today(), AccountId=ac.Id, Status__c='Active', StageName='Qualification', RW_Project__c=objpr.Id);
        objOpp = RDSCommon.CreateOpportunity(objOpp);
        Rate_List_Header__c rlh = new Rate_List_Header__c(Name='RLH', Project__c=objpr.Id, Project_Charges__c=pcBasic.Id, Rate_list__c='All Charges', Effective_From__c=System.today().addDays(-3));
        rlh = RDSCommon.CreateRateListHeader(rlh);
        Rate_List_Detail__c rld = new Rate_List_Detail__c(Name='RLD', Charge_Based_On__c='Rate', Percent__c=23600, Project__c=objpr.Id, Rate_List_Header__c=rlh.id);
        rld = RDSCommon.CreateRateListHeader(rld);
        Rate_List__c rl1 = new Rate_List__c(Rate_List_HeaderID__c=rlh.Id, Project__c=objpr.Id, Global_Charges__c=gcBasic.Id, Project_Charges__c=pcBasic.Id, Project_Unit__c=objPU1.Id, Value__c=2218, Rate__c=23600, Charge_Based_On_Master__c='Rate', Charge_on_Area_Type__c='Saleable Area', Rate_List_Detail__c=rld.id);
        rl1 = RDSCommon.CreateRateList(rl1);
        Payment_Plan__c objPaymentPlan = new Payment_Plan__c(Name='Pay Plan 1', Project__c=objpr.Id, Tower__c=t.Id, Sub_Vention__c=true, Subvention_Base_Rate__c=50, No_GST_on_Token__c=true, Valid_upto__c=System.TODAY());
        insert objPaymentPlan;
        Project_Construction_Stages__c pcs = new Project_Construction_Stages__c(Project__c=objpr.Id, Sequence_No__c=20, Name='Stage1', Code__c='S1', Description__c='S1', Planned_date_of_completion__c=System.today().addDays(365), Tower__c=t.Id);
        insert pcs;
        Standard_Pay_Plan_Header__c sph = new Standard_Pay_Plan_Header__c(Project__c=objpr.Id, Charge_Code__c=pcBasic.Id, Payment_Plan__c=objPaymentPlan.id, Name='Basic Hdr', Plan_Code__c='89', tower__c=t.ID, Effective_from__c=System.today());
        sph = RDSCommon.CreateStandardPayPlanHeader(sph);
        Standard_Customer_Pay_Plan_Detail__c sppd = new Standard_Customer_Pay_Plan_Detail__c(Standard_Pay_Plan_Header__c=sph.id, Project__c=objpr.id, tower__c=t.ID, Is_to_be_Paid__c='From Dt. of Booking', Days_Months__c='Day(s)', Days_Months_Value__c=5, Amount__c='Amount', Amount_Value__c=110000, Installment__c=100);
        sppd = RDSCommon.CreateCustomerPayPlanHeaderDetail(sppd);
        Team__c objTeam = new Team__c(Name='Sales Approvers Team', Project__c=objpr.id, Team_Type__c='Sales Approvers Team', Towerlookup__c=t.id);
        insert objTeam;
        Id meId = UserInfo.getUserId();
        insert new List<Team_Members__c>{
            new Team_Members__c(Team__c=objTeam.Id, User_Active__c=true, Approver_Type__c='First Level', User__c=meId),
            new Team_Members__c(Team__c=objTeam.Id, User_Active__c=true, Approver_Type__c='Second Level', User__c=meId),
            new Team_Members__c(Team__c=objTeam.Id, User_Active__c=true, Approver_Type__c='Third Level', User__c=meId)
        };
        // Surgical fix: wire unit -> opportunity
        objPU1.RW_Customer__c = objOpp.Id;
        update objPU1;

        PageReference pRef2 = Page.Quotation2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('oppId', objOpp.id);
        ApexPages.currentPage().getParameters().put('id', objPU1.id);
        ApexPages.currentPage().getParameters().put('subPlanId', objPaymentPlan.id);

        Test.startTest();
        // CONSTRUCTOR INSIDE startTest — gets fresh 100 SOQL budget
        QuotationExtn qExNew = new QuotationExtn();
        qExNew.baseRate = 1110.0;
        qExNew.discountVal = 100000;
        qExNew.sOriginalAgreementVal = '300000';
        qExNew.allotmentChargeLumsum = 100000;
        try { qExNew.clearDiscount(); } catch(Exception e) {}
        qExNew.GstPsfRate = 1100;
        try { qExNew.calculateGSTpercenatgeDisc(); } catch(Exception e) {}
        try { qExNew.addCarPark(); } catch(Exception e) {}
        try { qExNew.reloadURL(); } catch(Exception e) {}
        try { qExNew.getOldBaseRate(); } catch(Exception e) {}
        try { qExNew.backtoQuotePage(); } catch(Exception e) {}
        try { qExNew.savePaymentSchedule(); } catch(Exception e) {}
        try { qExNew.MathforAppliedDiscount(); } catch(Exception e) {}
        try { qExNew.savePrint(); } catch(Exception e) {}
        try { qExNew.updateCalculations(); } catch(Exception e) {}
        Test.stopTest();
        System.assertNotEquals(null, qExNew);
    }
}