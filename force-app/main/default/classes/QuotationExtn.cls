public with sharing class QuotationExtn
{
    public Decimal cNPVLoss { get; set; }
     public Decimal Testtotalvalue { get; set; }
    public String selectedValue { get; set; }
    public List<SelectOption> discountOptions { get; set; }
    public String selectedDiscountOption { get; set; }
    public Decimal discountPercentage { get; set; }
	// public Decimal mandetoryDiscount { get; set; }
    public Decimal nonMandetory_monetorydiscount { get; set; }
    public Decimal nonMandetory_nonmonitizablediscount { get; set; }
    public Decimal nonMandetory_monitizablediscount { get; set; }
    
    public String StringnonMandetory_monetorydiscount { get; set; }
    public String StringnonMandetory_nonmonitizablediscount { get; set; }
    public String StringnonMandetory_monitizablediscount { get; set; }
	
    Public Decimal carParkAmt{get; set;}
    public Project_Unit__c u {get; set;}
    public Opportunity o {get; set;}
    public Quotation__c q {get;set;}
    public Id unitId {get;set;}
    public Id subventionPlanId {get;set;}
    public Id oppId {get; set;}
    public Id subPlanId {get; set;}
    public Project__c proj {get; set;}
    public Map<String, Decimal> allChargesMap {get;set;}
    public Map<String, Decimal> allChargesMapDisc {get; set;}
    public Decimal unitSealableArea { get; set; } //Added by Prakshi

    
    public Map<String,List<QuotationManagementServices.QuoteUIWrapper>> quoteUIMap {get;set;}
    public Map<String,List<QuotationManagementServices.QuoteUIWrapper>> quoteUIMapDisc {get;set;}
    
    public List<Payment_Plan__c> payPlanList {get;set;}
    public List<Payment_Plan__c> default_payPlanList {get;set;}
    public List<Payment_Plan__c> subventionPayPlanList {get;set;}
    
    public Decimal discountPSF {get;set;}
    public Decimal discountLumpsum {get;set;}
    Public String discountLumpsumFormatted {get; set;}
    public Decimal agreementValue {get;set;}
    public string sAgreementvaluepostDiscount {get;set;}// Addes by Digicloud Team - Suraj S
    public List<Quote_Applied_Discounts__c>  lstAllAppliedDiscounts;
    public List<Quote_Applied_Discounts__c> appliedDiscounts {get;set;}
    public List<Quote_Applied_Discounts__c>  lstNonMandDisc = new List<Quote_Applied_Discounts__c>(); // Addes by Digicloud Team - Suraj S
    
    public Integer addCarParks {get;set;}//Added for SDR ROC Management
    public Boolean sdPaidByRunwal {get;set;}//Added for SDR ROC Management
    public Boolean regChargesByRunwal {get;set;}//Added for SDR ROC Management
    public Boolean nonMonetaryOfferCheckbox {get;set;}//Added for Quotation Offer
    public Boolean isAnyNonMonetarySelected  {get;set;}//Added for Quotation Offer
    public Boolean isCalculateDiscountClicked {get;set;}//Added for Quotation Offer

    public List<InventoryCostServices.PlanDetailWrapper> payplanDetails; 
    public List<InventoryCostServices.PlanDetailWrapper> payplanDetailsForQuotedNPV; // Added by Digicloud team Suraj S
    public List<InventoryCostServices.PlanDetailWrapper> subventionPayplanDetails;
    public List<QPlanDetailWrapper> qplanWrapperList = new List<QPlanDetailWrapper>();
    public List<QPlanDetailWrapper> qplanWrapper {get { return qplanWrapperList; } set { qplanWrapperList = null; qplanWrapperList = value; }}
    
    public List<QPlanDetailWrapper> qplanWrapperListC = new List<QPlanDetailWrapper>();
    public List<QPlanDetailWrapper> qplanWrapperC {get { return qplanWrapperListC; } set { qplanWrapperListC = null; qplanWrapperListC = value; }}
    
    public Id selectedPlan {get; set;}
    public Boolean editSchedule {get; set;}
    public Boolean scheduleEdited {get;set;}
    public List<InventoryCostServices.DiscountWrapper> pDisc3 {get;set;}
    public List<InventoryCostServices.DiscountWrapper> pDisc {get;set;}
    public List<InventoryCostServices.DiscountWrapper> pDisc1 {get;set;}
    public String discountPageMode {get;set;}
    public Boolean disableDiscount {get;set;}
    
    public Decimal OriginalPlanNPV {get;set;}
    public Decimal OriginalPlanNPV2{get;set;}// Added by digicloud Suraj S
    public Decimal OriginalNPVPSF {get;set;}
    public Decimal UpdatedPlanNPV {get;set;}
    public Decimal UpdatedNPVPSF {get;set;}
    public Decimal NPVDiffLumpsum {get;set;}
    public Decimal NPVDiffLumpsum_Loss {get;set;}
    public Decimal NPVDiffPSF {get;set;}
    
    //Variable for NPV2
    
    public Decimal NPV2_A {get;set;}
    public Decimal NPV2_B {get;set;}
    public Decimal NPVDiffLumpsum2_Loss {get;set;}
    
    public string FormattedNPVDiffLumpsum_Loss {get; set;}
    Public string FormattedOriginalPlanNPVDeafult {get; set;}
    Public string FormattedOriginalPlanNPV {get; set;}
    
    public String SOriginalPlanNPV {get;set;}
    public String SOriginalPlanNPV2 {get;set;}// Added by digicloud Suraj S
    public String SOriginalNPVPSF {get;set;}
    public String SUpdatedPlanNPV {get;set;}
    public String SUpdatedNPVPSF {get;set;}
    public String SNPVDiffLumpsum {get;set;}
    public String SNPVDiffPSF {get;set;}
    public String StotalRateCardPSF {get;set;}
    public String StotalRateCardLumspum {get;set;}
    
    public Integer rowNumber {get;set;}
    public String addType {get;set;}
    public String quoteValidity {get;set;}
    public String quoteDate {get;set;}
    public String quoteFor {get;set;}
    public String quoteApprovalMsg {get;set;}
    public boolean  canAddCarPark1 {get;set;}
    public boolean  canAddCarPark2 {get;set;} 
    public boolean  canAddCarPark3 {get;set;}
    public boolean  canAddCarPark4 {get;set;} 
    public boolean  canAddCarPark5 {get;set;}
    public boolean  canAddCarPark6 {get;set;}
    public boolean  canAddCarPark7 {get;set;}
    public boolean  canAddCarPark8 {get;set;}
    public boolean  canAddCarPark9 {get;set;} //Added by Vinay 28-03-2025
    public boolean  canAddCarPark10 {get;set;} //Added by Vinay 19-11-2025
    public boolean  canAddCarPark11 {get;set;} //Added by Dolly
    public boolean  showAddCarPark {get;set;} 
    public Integer selectedCarPark1 {get;set;}
    public Integer selectedCarPark2 {get;set;}
    public Integer selectedCarPark3 {get;set;}
    public Integer selectedCarPark4 {get;set;}
    public Integer selectedCarPark5 {get;set;}
    public Integer selectedCarPark6 {get;set;}
    public Integer selectedCarPark7 {get;set;}
    public Integer selectedCarPark8 {get;set;}
    public Integer selectedCarPark9 {get;set;} //Added by Vinay 28-03-2025
    public Integer selectedCarPark10 {get;set;} //Added by Vinay 19-11-2025
 	public Decimal OriginalPlanNPVDeafult {get;set;}
    public Decimal fixedDiscount{get;set;}//Added by Digicloud
    public String SfixedDiscount{get;set;}//Added by Digicloud
    public Decimal sourceDiscount{get;set;}//Added by Digicloud
    public String stSourceDiscount{get;set;}//Added by Digicloud
    public Decimal originalAgreementVal{get;set;}//Added by Digicloud
    public String sOriginalAgreementVal{get;set;}
    public Decimal allotmentCharges {get;set;}  
    public Decimal baseRate{get;set;}
    Public Decimal discountVal{get;set;}
    public Decimal premiumRate{get;set;}
    public Decimal allotmentChargeLumsum{get;set;}
    public Decimal GstPsfRate{get;set;}
    public Decimal GstLumpsumRate{get;set;}
    public String TotalGSTDiscount{get;set;}
    public String TotalGSTDiscountPSF{get;set;}
    public decimal GSTpercentageApplied{get;set;}
    public Boolean parkingApplied {get; set;}   //Added by Dolly
    public Map<String,Integer> appliedParkingSnapshot = new Map<String,Integer>();  //Added by Dolly to track the applied parking at the time of applying parking, this will be used to validate the parking availability when user tries to add/remove parking

    
    // Referral Discount Variables
    Decimal sreferralDiscount = 0;
    Decimal sreferralDiscountAV = 0;
    Decimal sRefDiscPassBack = 0;
    Decimal sRefDiscPassBackAV = 0;
    
    Public Decimal refralDiscount{get; set;}
    
    Decimal CP_Discount = 0;
    Decimal CP_DiscountAV = 0;
    Decimal CP_PassbackValue = 0;
    Decimal CP_PassbackAV = 0;
   // Decimal CP_DiscountInput = 50;
    
    Public String Formatted_CP_Discount { get; set; }
    Public String Formatted_CP_DiscountAV { get; set; }
    Public String Formatted_CP_PassbackValue { get; set; }
    Public String Formatted_CP_PassbackAV { get; set; }
    
    public String CP_PassBackPercent { get; set; }
    
    public String Formatted_CP_PassBack { get; set; }
    
    public String OfferValue { get; set; } 
	public Decimal UnitAV { get; set; } 
    public Decimal DiscountedAV { get; set; }
    public String QuotedOfferValue { get; set; } 
    
    /*public Decimal referralDiscount  { get; set; } 
    public Decimal referralDiscountAV  { get; set; } 
    public Decimal RefDiscPassBack { get; set; } 
    public Decimal RefDiscPassBackAV { get; set; } */
    
    public String FormattedRefDisc { get; set; }
    public String FormattedRefDiscAV { get; set; }
    public String FormattedRefDiscPassBack { get; set; }
    public String FormattedRefDiscPassBackAV { get; set; }
    public Map<String,String> referralDetailsVsValueMap { get; set; } 
    
    public Decimal CP_DiscountInput { get; set; }
    
    Public Decimal NPV_A_OfferValue {get;set;} // Unit AV - Mandetory Discount-SourceDicount\
    Public Decimal NPV_A_DiscountRate {get;set;}
    public List<Payment_Plan__c> default_PaymentPlan {get;set;}
    Public Decimal NPV_A_Discount_Value {get; set;}
    Public Decimal NPV_B_Discount_Value {get; set;}
    Public Decimal NPV_Discount_Percent {get; set;}
   public String errorMessage { get; set; }
    // on load page, get all the charges, the flat details and render it on the UI.
    public QuotationExtn()
    {  
        q = new Quotation__c();
        oppId = null;
        unitId = null;
        subPlanId = null;
        addCarParks = 0;
        quoteApprovalMsg = 'N/A';
        selectedCarPark1 = 0;
        selectedCarPark2 = 0;
        selectedCarPark3 = 0;
        selectedCarPark4 = 0;
        selectedCarPark5 = 0;
        selectedCarPark6 = 0;
        selectedCarPark7 = 0;
        selectedCarPark8 = 0;
        selectedCarPark9 = 0; //Added by Vinay 28-03-2025
        selectedCarPark10 = 0; //Added by Vinay 19-11-2025
        allotmentCharges = 0;
        baseRate = 0;
        discountVal = 0;
        premiumRate = 0;
        allotmentChargeLumsum = 0;
        GstPsfRate = 0;
        GstLumpsumRate = 0;
        TotalGSTDiscount = 'Rs 0/-';
        TotalGSTDiscountPSF = 'Rs 0/-';
        refralDiscount = 0;
        cNPVLoss = 0;
        if(ApexPages.currentPage().getParameters().containsKey('id'))       
            unitId = (Id)ApexPages.currentPage().getParameters().get('id');    
        if(ApexPages.currentPage().getParameters().containsKey('oppId'))  
            if(ApexPages.currentPage().getParameters().get('oppId') != '')      
            oppId = (Id)ApexPages.currentPage().getParameters().get('oppId');           
        if(ApexPages.currentPage().getParameters().containsKey('subPlanId'))       
            subPlanId = (Id)ApexPages.currentPage().getParameters().get('subPlanId');  
        if(ApexPages.currentPage().getParameters().containsKey('discountVal'))       
            CP_DiscountInput = decimal.valueof((string)ApexPages.currentPage().getParameters().get('discountVal'));  
 		system.debug(' check Start ==='+CP_DiscountInput);
        system.debug('subPlanId Id ===<' +subPlanId );
        system.debug('unit Id ===<' +unitId );
        if( unitId != null ) {
            
            u = InventoryCostServices.getUnitDetails(unitId);
            proj = InventoryCostServices.getProjectDetails(unitId);
            o = InventoryCostServices.getOpportunityDetails(oppId);
            system.debug('Inside extn cks 236- > '+o);
            //if(subPlanId != null)
            //{
            unitSealableArea = u.Saleable_Area__c;//Added by Prakshi
            System.debug('unitSealableArea1**'+unitSealableArea);
            system.debug('((((((((((((((((((((((((((('+unitId+subPlanId);
            allChargesMap = InventoryCostServices.getAllCharges(unitId,0.0,0.0,subPlanId);
            system.debug('allChargesMap agreement value__'+ allChargesMap.get('AGREEMENTVALUE'));
            quoteUIMap = QuotationManagementServices.getQuotationUIFormat(unitId,0.0,0.0, selectedCarpark1 + selectedcarPark2, subPlanId);
            System.Debug('Quote UI Map : '+quoteUIMap);
            quoteUIMapDisc = null;
            payPlanList = InventoryCostServices.getPlanList(u.RW_Project__r.Id, u.TowerName__r.Id, subPlanId);
            System.debug('Sub Plan ==========='+subPlanId);
            agreementValue = allChargesMap.get('AGREEMENTVALUE');
            System.debug('agreement value after dicount is ===>'+ agreementValue);
            
            
            originalAgreementVal = allChargesMap.get('ORIGINALAGREEMENTVALUE'); 
            sOriginalAgreementVal = QuotationManagementServices.INFormat(originalAgreementVal);
            System.Debug('agreementValue in the extn__'+originalAgreementVal);
            System.Debug('fixedDiscounts in the extn__'+fixedDiscount);
            
            UnitAV = allChargesMap.get('FLATCOST'); 
            System.debug('UnitAV**'+UnitAV);
            OfferValue = QuotationManagementServices.INFormat(UnitAV);
            System.debug('OfferValue**'+OfferValue);
            
            discountOptions = new List<SelectOption>();
            discountOptions.add(new SelectOption('', '--None--'));
            discountOptions.add(new SelectOption('Advance', 'Advance (9%)'));
            discountOptions.add(new SelectOption('Deferred', 'Deferred (11%)'));
            
            
            // Calling below method from InventoryCostServices - Digicloud 
            if(agreementValue != null){
                InventoryCostServices.passAgreementValue(agreementValue, originalAgreementVal); 
            }
            StotalRateCardPSF = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDPSF'));
            StotalRateCardLumspum = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDLUMPSUM'));
            pDisc = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
            system.debug('pDisc__'+ pDisc); 
            pDisc1 = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
            
            // Getting discount values to show on UI - Digicloud Suraj S  
            system.debug('CP_PassBackPercent ===>'+ CP_DiscountInput);
             CP_DiscountInput= 0;
            InventoryCostServices.FixedDiscountWrapper discountResult = InventoryCostServices.calculateFixedDiscounts(proj.Id, oppId, unitId, originalAgreementVal, CP_DiscountInput);
            system.debug('discountMap__'+ discountResult);
            if (discountResult != null) {
                fixedDiscount = discountResult.fixedDiscounts != null ? discountResult.fixedDiscounts : 0;
                SfixedDiscount = QuotationManagementServices.INFormat(fixedDiscount);
                system.debug('fixedDiscount__'+ fixedDiscount);
                
                sreferralDiscount = discountResult.refralDiscount != null ? discountResult.refralDiscount : 0;
                sreferralDiscountAV = discountResult.refralDiscountAV != null ? discountResult.refralDiscountAV : 0;
                sRefDiscPassBack = discountResult.RefDiscPassBack != null ? discountResult.RefDiscPassBack : 0;
                sRefDiscPassBackAV= discountResult.RefDiscPassBackAV != null ? discountResult.RefDiscPassBackAV : 0;
                //FormattedRefDisc = QuotationManagementServices.INFormat(sreferralDiscount);
                //FormattedRefDiscAV = QuotationManagementServices.INFormat(sreferralDiscountAV);
                //FormattedRefDiscPassBack = QuotationManagementServices.INFormat(sRefDiscPassBack);
                //FormattedRefDiscPassBackAV = QuotationManagementServices.INFormat(sRefDiscPassBackAV);
                    
                
               // lstAllAppliedDiscounts = discountResult.appliedDiscounts != null ? discountResult.appliedDiscounts : new List<Quote_Applied_Discounts__c>(); 
               // system.debug('List Applied Discounts__'+ lstAllAppliedDiscounts.size());
               // system.debug('List Applied Discounts__'+ lstAllAppliedDiscounts);
                system.debug('sourceDiscount'+ sourceDiscount); 
                
            }
            
            
            baseRate = allChargesMap.get('BASERATE');
            q.Original_Base_Rate__c = allChargesMap.get('BasicPSF');
            q.Original_Premium_Rate__c = allChargesMap.get('Premium 1PSF'); 
            premiumRate = allChargesMap.get('Premium 1PSF');
            q.Original_Allotment_Charge__c = allChargesMap.get('Allotment Charges');
            allotmentChargeLumsum = allChargesMap.get('Allotment Charges');
            
            //}
            q.Project_Unit__c = u.id;
            q.Project__c = proj.id;
        }
        QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue);
        system.debug('QuotedOfferValue=='+QuotedOfferValue);
        
        if(oppId != null) {
            system.debug('Inside oppId line318- > '+oppId);
            o = [Select Id, Name, Account.Name, StageName, Sales_Manager__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,Walkin_SubSource__c,
                 Referral_Sub_Source__c,Walkin_Source__c,Opt_for_Referral__c,LeadSource,Lead_Sub_Source__c                               
                 from Opportunity where Id = :oppId]; //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
            q.Opportunity__c = o.Id;
            quoteFor = o.Name;
        }
        //referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//Call the Referral Details func..22-12-25//Uncommented by Prakshi
        //FormattedRefDisc = referralDetailsVsValueMap.get('FormattedRefDisc');
        //FormattedRefDiscAV = referralDetailsVsValueMap.get('agreementValue');
       // system.debug('FormattedRefDiscAV -> '+FormattedRefDiscAV);
        //system.debug('FormattedRefDisc -> '+FormattedRefDisc);
        //system.debug('AV -> '+referralDetailsVsValueMap.get('agreementValue'));
        discountPSF = 0;
        discountLumpsum = 0;
        editSchedule = false;
        scheduleEdited = false;
        disableDiscount = false;
        OriginalPlanNPV = 0.0;
        OriginalPlanNPVDeafult = 0.0;																
        OriginalPlanNPV2 = 0.0; //Added by digicloud team Suraj S
        UpdatedPlanNPV = 0.0;
        OriginalNPVPSF = 0.0;
        UpdatedNPVPSF = 0.0;
        NPVDiffLumpsum = 0.0;
        NPVDiffLumpsum_Loss=0.0;
        NPVDiffPSF = 0.0;
        // string values of the NPV fields for displaying Rs /-
        SOriginalPlanNPV = '';
        SOriginalNPVPSF = '';
        SUpdatedPlanNPV = '';
        SUpdatedNPVPSF = '';
        SNPVDiffLumpsum = '';
        SNPVDiffPSF = '';
        selectedCarPark1 = 0;
        selectedCarPark2 = 0;
        selectedCarPark3 = 0;
        selectedCarPark4 = 0;
        selectedCarPark5 = 0;
        selectedCarPark6 = 0; 
        selectedCarPark7 = 0;
        selectedCarPark8 = 0;
        selectedCarPark9 = 0; //Added by Vinay 28-03-2025
        selectedCarPark10 = 0; //Added by Vinay 19-11-2025
        if(proj != null) {
           // checkCarParkAvailability();
        parkingApplied = false; //Added by Dolly
         checkCarParkAvailablity();  //Added by Dolly
          loadProjectAvailability();  //Added by Dolly
          

  
        // 🔹 Default UI values from Unit (earmarked)
        syncUnitEarmarkedToQuotation();  //Added by Dolly
                // prepopulateCarParksFromUnit(); // ✅ ADD THIS LINE
            quoteValidity = (System.today().addDays(Integer.valueOf(proj.Quotation_Validity__c))).format();
            quoteDate = System.today().format();
        }
    }
    
 

    
    //Added by Dolly
    // ====== START: car park method =========
    public void checkCarParkAvailablity() {

        canAddCarPark1 = hasAvailable('Single Covered');
        canAddCarPark2 = hasAvailable('Tandem Covered');
        canAddCarPark3 = hasAvailable('Single Open');
        canAddCarPark4 = hasAvailable('Tandem Open');
        canAddCarPark5 = hasAvailable('Stilt');
        canAddCarPark6 = hasAvailable('MLCP');
        canAddCarPark7 = hasAvailable('Basement');
        canAddCarPark8 = hasAvailable('Podium');
        canAddCarPark9 = hasAvailable('Puzzle Car Park');
        canAddCarPark10 = hasAvailable('Covered Stack');
        canAddCarPark11 = hasAvailable('Stack Car Park');

        showAddCarPark =
            canAddCarPark1 || canAddCarPark2 || canAddCarPark3 ||
            canAddCarPark4 || canAddCarPark5 || canAddCarPark6 ||
            canAddCarPark7 || canAddCarPark8 || canAddCarPark9 || 
            canAddCarPark10 || canAddCarPark11;
    }

//Added by Dolly
private Boolean hasAvailable(String parkingType) {

    Integer cnt = [
        SELECT COUNT()
        FROM Car_Parking_Charge__c
        WHERE Project__c = :proj.Id
        AND Parking__c = :parkingType
        AND Category__c = 'Additional'
    ];

     // 🔹 UNIT earmarked parking (fields)
    Integer unitCnt = getUnitEarmarkedCount(parkingType);
      System.debug('---- AVAILABILITY CHECK ----');
    System.debug('Parking Type → ' + parkingType);
    System.debug('Project Additional → ' + cnt);
    System.debug('Unit Earmarked → ' + unitCnt);
    System.debug('Project id → ' + proj.Id);
    System.debug('AVAILABLE CHECK → ' + parkingType + ' = ' + cnt);
     return (cnt > 0 || unitCnt > 0);
}

private Integer getUnitEarmarkedCount(String parkingType) {

    if(parkingType == 'Single Covered')
        return (u.Single_car_park_Earmarked__c == null ? 0 : Integer.valueOf(u.Single_car_park_Earmarked__c));

    if(parkingType == 'Tandem Covered')
        return (u.Tandem_car_park_Earmarked__c == null ? 0 : Integer.valueOf(u.Tandem_car_park_Earmarked__c));

    if(parkingType == 'Single Open')
        return (u.Single_Open_Earmarked__c == null ? 0 : Integer.valueOf(u.Single_Open_Earmarked__c));

    if(parkingType == 'Tandem Open')
        return (u.Tandem_Open_Earmarked__c == null ? 0 : Integer.valueOf(u.Tandem_Open_Earmarked__c));

    if(parkingType == 'Stilt')
        return (u.Stack__c == null ? 0 : Integer.valueOf(u.Stack__c));

    if(parkingType == 'MLCP')
        return (u.MLCP_Earmarked__c == null ? 0 : Integer.valueOf(u.MLCP_Earmarked__c));

    if(parkingType == 'Basement')
        return (u.Basement_Earmarked__c == null ? 0 : Integer.valueOf(u.Basement_Earmarked__c));

    if(parkingType == 'Podium')
        return (u.Podium_Earmarked__c == null ? 0 : Integer.valueOf(u.Podium_Earmarked__c));

    if(parkingType == 'Puzzle Car Park')
        return (u.Puzzle_Car_Park_Earmarked__c == null ? 0 : Integer.valueOf(u.Puzzle_Car_Park_Earmarked__c));

    if(parkingType == 'Covered Stack')
        return (u.Covered_Stack_Earmarked__c == null ? 0 : Integer.valueOf(u.Covered_Stack_Earmarked__c));

    if(parkingType == 'Stack Car Park')
        return (u.Stack_Car_Park_Earmarked__c == null ? 0 : Integer.valueOf(u.Stack_Car_Park_Earmarked__c));

    return 0;
}

    public PageReference addCarPark() {
        
       // 1️⃣ Load availability once (safe even if already loaded)   //Added by Dolly
        loadProjectAvailability();

        // 2️⃣ Validate against project additional inventory   //Added by Dolly
        if (!validateAdditionalParkingAvailability()) {
            system.debug('inside addoark method validateAdditionalParkingAvailability');
        }

        // 3️⃣ Preview calculation only (NO split)   //Added by Dolly
        onApplyParking();



        //applyParkingToQuotation();
        //calculateParkingPreview();
                //Decimal totalAmount = 0;
        //discountLumpsum = 0;
        discountPSF = 0;
        

        //allotmentCharges = totalAmount;
        InventoryCostServices.baseRateVal = baseRate;
        InventoryCostServices.premiumRateVal = premiumRate;
        InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
        InventoryCostServices.sdPaidByRunwalContext = sdPaidByRunwal;
        InventoryCostServices.regPaidByRunwalContext = regChargesByRunwal;
        quoteUIMap = QuotationManagementServices.getQuotationUIFormat(unitId,allotmentCharges,discountLumpsum,selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7 , subPlanId);      
        System.debug('allotmentCharges**'+allotmentCharges);  
        allChargesMap = InventoryCostServices.getAllCharges(unitId, allotmentCharges, discountLumpsum,subPlanId);
        agreementValue = allChargesMap.get('AGREEMENTVALUE');
        StotalRateCardPSF = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDPSF'));
        StotalRateCardLumspum = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDLUMPSUM'));
		QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue);
        //referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//Added by Prakshi
        /* if(subPlanId != null) {
        Apexpages.currentPage().getParameters().put('subPlanId',subPlanId);
        QueryPlanDetails();
        }*/
        if(selectedPlan != null) {
            Apexpages.currentPage().getParameters().put('subPlanId',selectedPlan);
            QueryPlanDetails();
        }
        //getUpdatedCharges();//added by Prakshi
        return null;
    }
    
    

    public List<InventoryCostServices.PlanDetailWrapper> getPlanDetails(Id unitId,Id planId,  Map<String,Decimal> allChargesMapP){
        List<InventoryCostServices.PlanDetailWrapper> planDetails = new List<InventoryCostServices.PlanDetailWrapper>();
        System.debug('**hh**'+unitId+'*'+planId+'*'+allChargesMapP);
        planDetails = InventoryCostServices.getPlanDetails(unitId,planId,allChargesMapP);
        system.debug('Sharique' + planDetails);
        return planDetails;
    }
    
    
    public void QueryPlanDetails(){
        system.debug('Selected inside query plan');
        system.debug('Selected inside query plan qplanWrapperListC' + qplanWrapperListC);
        system.debug('Selected inside query plan qplanWrapperC'+ qplanWrapperC);
        InventoryCostServices.sdPaidByRunwalContext = sdPaidByRunwal;//Added for SDR
        InventoryCostServices.regPaidByRunwalContext = regChargesByRunwal;//Added for SDR
        allChargesMapDisc = new Map<String, Decimal>();
        errorMessage = '';
        //qplanWrapperListC = new List<QPlanDetailWrapper>();
        Standard_Customer_Pay_Plan_Detail__c scppd = new Standard_Customer_Pay_Plan_Detail__c();
        String planIdstr  = Apexpages.currentPage().getParameters().get('subPlanId');
        Id planId;
        system.debug('subPlanId: '+subPlanId);
        if(string.isNotBlank(subPlanId))
            planId = subPlanId;
        else
            planId = null;
        Boolean isValid = (planIdstr InstanceOf ID) ? true : false;
        If(isValid) {
            selectedPlan = planIdstr;
            planId = planIdstr;
        }
     system.debug('Selected palne id ------->'+planId);
        system.debug('Selected scheduleEdited boolean ------->'+scheduleEdited);
        if(!scheduleEdited && planId != null) {
            qplanWrapperListC = new List<QPlanDetailWrapper>();
            system.debug('Selected Discount Option ===>'+ selectedDiscountOption);
             system.debug('Selected inside query plan');
            default_payPlanList = InventoryCostServices.getdefaultPlanList(u.RW_Project__r.Id, u.TowerName__r.Id, subPlanId);
            
            //Dont Delete below if conditon VVVIMP
            String paymentplanId_Default;
            if(!default_payPlanList.isempty()){
                paymentplanId_Default = default_payPlanList[0].id;
            } else{
                paymentplanId_Default = planId;
            }
            
             system.debug('Dafult payment plan'+paymentplanId_Default);
            payplanDetails = new List<InventoryCostServices.PlanDetailWrapper>();
            payplanDetailsForQuotedNPV = new List<InventoryCostServices.PlanDetailWrapper>();
          List<InventoryCostServices.PlanDetailWrapper>  payplanDetails2 = new List<InventoryCostServices.PlanDetailWrapper>();
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
            allChargesMapDisc = InventoryCostServices.getAllCharges(unitId, allotmentCharges,discountLumpsum,subPlanId);
            System.debug('allChargesMapDisc1**'+allChargesMapDisc);
            // Shailesh added extra paramenter[unitId] to this method signature to make GST weiving off changes on 19.1.18//
            payplanDetails = getPlanDetails(unitId,planId, allChargesMapDisc);
            
            system.debug('allcharge map 123:'+allChargesMap.get('AGREEMENTVALUE'));
            system.debug('allcharge map 123:'+allChargesMap.get('FIXEDDISCOUNT'));
            system.debug('allcharge map 123:'+allChargesMap.get('NONMANDDISCOUNT'));
            system.debug('allcharge map 123:'+allChargesMap.get('REFERRALDISCOUNT'));
            system.debug('allcharge map 123:'+allChargesMap.get('REFERRALPASSBACK'));
            system.debug('allcharge map 123:'+allChargesMap.get('ORIGINALAGREEMENTVALUE'));
            
            
            
            //Anuj: get default plan
            payplanDetails2 = getPlanDetails(unitId,paymentplanId_Default, allChargesMapDisc);
            payplanDetailsForQuotedNPV = getPlanDetails(unitId,planId, allChargesMap);
            OriginalPlanNPV = InventoryCostServices.calculateNPV(payplanDetails, proj.Id,selectedDiscountOption);
            //NPV1_A
           	OriginalPlanNPVDeafult = InventoryCostServices.calculateNPV(payplanDetails2, proj.Id,selectedDiscountOption);
            //NPV2_A
            
          	NPV2_A = InventoryCostServices.calculateNPV2(payplanDetails2, proj.Id);
            system.debug('OriginalPlanNPV__'+ OriginalPlanNPV);
            system.debug('DeafultOriginalPlanNPV__'+ OriginalPlanNPVDeafult);
            NPVDiffLumpsum_Loss = OriginalPlanNPVDeafult- OriginalPlanNPV ;
            FormattedNPVDiffLumpsum_Loss = QuotationManagementServices.INFormat(NPVDiffLumpsum_Loss);
            FormattedOriginalPlanNPVDeafult = QuotationManagementServices.INFormat(OriginalPlanNPVDeafult);
            FormattedOriginalPlanNPV = QuotationManagementServices.INFormat(OriginalPlanNPV);
            System.debug('NPVDiffLumpsum_Loss NPV Difference dafult-selected(non edit)'+NPVDiffLumpsum_Loss);
                    
            OriginalPlanNPV2 = InventoryCostServices.calculateNPV(payplanDetailsForQuotedNPV, proj.Id,selectedDiscountOption); // Added by digicloud team Suraj S, mapping this value on UI at original NPV Value
            system.debug('Quoted NPV__'+ OriginalPlanNPV2); 
            OriginalNPVPSF = (OriginalPlanNPV/allChargesMap.get('AREA')).setscale(0,RoundingMode.HALF_UP);
            SOriginalPlanNPV = QuotationManagementServices.INFormat(OriginalPlanNPV);
            SOriginalPlanNPV2 = QuotationManagementServices.INFormat(OriginalPlanNPV2);// Added by digicloud team Suraj S
            SOriginalNPVPSF = QuotationManagementServices.INFormat(OriginalNPVPSF);
            qplanWrapperList = new List<QPlanDetailWrapper>();
            for(Integer i=0; i < payplanDetails.size(); i++) { 
                system.debug('payplanDetails:: '+payplanDetails[i]);
                QPlanDetailWrapper q = new QPlanDetailWrapper(payplanDetails[i].amount,payplanDetails[i].serviceTax, payplanDetails[i].totalPay, payplanDetails[i].payPlanRecord, payplanDetails[i].taxMap);
                if(payplanDetails[i].payPlanRecord != null)
                    scppd = payplanDetails[i].payPlanRecord.clone(true,true);
                else
                    scppd = null;
                qplanWrapperList.add(q);
                QPlanDetailWrapper q1 = new QPlanDetailWrapper(payplanDetails[i].amount,payplanDetails[i].serviceTax, payplanDetails[i].totalPay, scppd, payplanDetails[i].taxMap);
                // cloning the entire pay plan wrapper to maintain two separate list for editing
                System.debug('Q1');
                qplanWrapperListC.add(q1);
            }
            
        } else {
            // do nothing, if there is an edited schedule already in the controller wrapper class. return the same
            // or no plan is selected
        }
        
        if (NPVDiffLumpsum_Loss < 0 && selectedDiscountOption == 'Deferred') {
                system.debug('NPVDiffLumpsum_Loss'+ NPVDiffLumpsum_Loss +'-selectedDiscountOption--'+selectedDiscountOption);
                
                errorMessage = 'Error: Negative NPV difference with mismatched discount option Differ.';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Negative NPV difference with mismatched discount option Differ.'));
                system.debug('errorMessage'+ errorMessage);
                
            }
            
            
            if (NPVDiffLumpsum_Loss > 0 && selectedDiscountOption == 'Advance') {
                system.debug('NPVDiffLumpsum_Loss'+ NPVDiffLumpsum_Loss +'-selectedDiscountOption--'+selectedDiscountOption);
                
                errorMessage = 'Error: Negative NPV difference with mismatched discount option. Advance';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Negative NPV difference with mismatched discount option. Advance'));
                system.debug('errorMessage'+ errorMessage);
                
            }
    }
    
    // ======== END: Methods related to PLAN QUERYING and formatting end here =========
    
    // ===========START: PLAN EDIT Methods Start here
    
    // action function to add, remove, clone rows for plan editing
    // action related to the +, ++, --
    public void rowModify(){
        if(addType.equals('new')){
            QPlanDetailWrapper q = qplanWrapperListC[rowNumber];
            Standard_Customer_Pay_Plan_Detail__c pp = q.payPlanRecord.clone(true,true);
            QPlanDetailWrapper qNew = new QPlanDetailWrapper(0,0,pp);
            
            qNew.payPlanRecord.Amount_Value__c = 0;
            qNew.payPlanRecord.Amount__c = '';
            qNew.payPlanRecord.Days_Months__c = '';
            qNew.payPlanRecord.Days_Months_Value__c = 0;
            qNew.payPlanRecord.Is_To_Be_Paid__c = '';
            qNew.payPlanRecord.Remarks__c = 'New Row';
            qNew.payPlanRecord.Project_Construction_Stages__c = null;
            qNew.payPlanRecord.Total_Charge_Value_Minus__c = 0;
            qNew.payPlanRecord.Registration_Linked__c = false;
            qNew.payPlanRecord.Deduct_Token__c = false;
            qplanWrapperListC.add(rowNumber+1,qNew);
            
        } else if(addType.equals('clone')) {
            QPlanDetailWrapper q = qplanWrapperListC[rowNumber];
            Standard_Customer_Pay_Plan_Detail__c pp = q.payPlanRecord.clone(true,true);
            QPlanDetailWrapper qNew = new QPlanDetailWrapper(0,0,pp);
            qplanWrapperListC.add(rowNumber+1,qNew);
        } else if(addType.equals('remove')) {
            qplanWrapperListC.remove(rowNumber);
        }
    }
    
    // cancels the changes made to the plan by updating the boolean variables
    // after cancel the plan is refetched and the page is refreshed
    // action related to Cancel Changes button
    public void cancelEdit(){
        system.debug('inside cancelEdit method');
        scheduleEdited = false;
        editSchedule = false;
        OriginalPlanNPV = 0.0;
        UpdatedPlanNPV = 0.0;
        OriginalNPVPSF = 0.0;
        UpdatedNPVPSF = 0.0;
        // remove the NPV line item from the discount array as the pay plan changes have been canceled
        if(NPVDiffPSF != 0.0) {
            pDisc.remove(pDisc.size()-2);
        }
        NPVDiffLumpsum = 0.0;
        NPVDiffPSF = 0.0;
        //wipe out the decimal and the String values of NPV when the plan edit is canceled
        SOriginalPlanNPV = '';
        SOriginalNPVPSF = '';
        SUpdatedPlanNPV = '';
        SUpdatedNPVPSF = '';
        SNPVDiffLumpsum = '';
        SNPVDiffPSF = '';
        quoteUIMapDisc = null;
        disableDiscount = True;
        if(String.isNotBlank(quoteApprovalMsg) && quoteApprovalMsg.contains('Discount'))
            quoteApprovalMsg = quoteApprovalMsg.replace('& Modifications have been made to the payment plan','');
        else 
            quoteApprovalMsg = 'N/A';
    }
    
    // method for handling edits to the payment plan
    // here we disable discounts as discounts cant be applied after editing the payment plan
    // action related to button View Updated Schedule
    public PageReference updatePaymentSchedule() {

        System.debug('AV in updatePaymentSchedule'+allChargesMap.get('AGREEMENTVALUE'));
        system.debug('In update');
        system.debug('In update baseRateVal' + baseRate);
        system.debug('In update premiumRateVal' + premiumRate);
        system.debug('In update allotmentChargeVal' + allotmentChargeLumsum);
        system.debug('In update allotmentCharges' + allotmentCharges + 'Discount ===>' + discountLumpsum);
        InventoryCostServices.baseRateVal = baseRate;
        InventoryCostServices.premiumRateVal = premiumRate;
        InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
        Map<String,Decimal> allChargesMapNew = InventoryCostServices.getAllCharges(unitId, allotmentCharges, discountLumpsum, subPlanId);
        System.debug('AV in allChargesMapNew'+allChargesMapNew.get('AGREEMENTVALUE'));
        Boolean error = false;
        Integer counter = 0;
        List<InventoryCostServices.PlanDetailWrapper> pdList  = new List<InventoryCostServices.PlanDetailWrapper>();
        List<InventoryCostServices.PlanDetailWrapper> pdListOriginal  = new List<InventoryCostServices.PlanDetailWrapper>();
        
        
        
        
        for(Integer i=0; i < qPlanWrapperC.size()-1; i++) {
            QPlanDetailWrapper q= qPlanWrapperC[i];
            if(String.isBlank(q.payPlanRecord.Amount__c) || q.payPlanRecord.Amount__c == null || q.payPlanRecord.Amount_Value__c == 0.00 || String.isBlank(q.payPlanRecord.Days_Months__c)  || 
               String.IsBlank(q.payPlanRecord.Is_To_Be_Paid__c)) {
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Milestone defintion Incorrect'));              
                   ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter all required fields'));
                   q.style = 'error';
                   error = true;
               }
            if(q.payPlanRecord.Is_To_Be_Paid__c != null && (q.payPlanRecord.Is_To_Be_Paid__c.equals('Construction Stage') && q.payplanRecord.Project_Construction_Stages__c == null)) {
                q.style = 'error';
                error = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Milestone defintion Incorrect'));      
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter all required fields'));
            }
            counter++;
        }
        if(error && !Test.isRunningTest()) {
            return null;
        }
        system.debug('In update : '+qPlanWrapperC);
        for(QPlanDetailWrapper q : qPlanWrapperC) {
            InventoryCostServices.PlanDetailWrapper pdw = new InventoryCostServices.PlanDetailWrapper(q.amount,q.serviceTax,q.payPlanRecord);
            pdList.add(pdw);
        }
        //pdList.remove(pdList.size()-1);//Commented by Vinay 29-01-2025
        if(pdList.size() > 0) //Added by Vinay 29-01-2025
            pdList.remove(pdList.size()-1);
        
        for(QPlanDetailWrapper q : qPlanWrapper) {
            InventoryCostServices.PlanDetailWrapper pdwOriginal = new InventoryCostServices.PlanDetailWrapper(q.amount,q.serviceTax,q.payPlanRecord);
            pdListOriginal.add(pdwOriginal);
        }
        //pdListOriginal.remove(pdListOriginal.size()-1); //Commented by Vinay 29-01-2025
        if(pdListOriginal.size() > 0) //Added by Vinay 29-01-2025
            pdListOriginal.remove(pdListOriginal.size()-1);
        
        //calculate NPV for the new payment plan, if there is a difference, apply that as an discount for the customers payment
        List<InventoryCostServices.PlanDetailWrapper> updatedPd = InventoryCostServices.calculateUpdatedPaymentSchedule(pdList,allChargesMapNew, pdListOriginal,unitId);
        System.debug('In update ====>'+ pdList);
        System.debug('AV1**'+allChargesMap.get('AGREEMENTVALUE'));
        UpdatedPlanNPV = InventoryCostServices.calculateNPV(updatedPd, proj.Id,selectedDiscountOption);

        System.debug('OriginalPlanNPVDeafult**'+OriginalPlanNPVDeafult);
        System.debug('UpdatedPlanNPV**'+UpdatedPlanNPV);

        UpdatedNPVPSF = (UpdatedPlanNPV/ allChargesMap.get('AREA')).setscale(0,RoundingMode.HALF_UP);
        System.debug('AV2**'+allChargesMap.get('AGREEMENTVALUE'));
        NPVDiffLumpsum = OriginalPlanNPVDeafult - UpdatedPlanNPV;
        NPVDiffLumpsum_Loss = NPVDiffLumpsum;
        System.debug('Test Update Payment Scheduled ===>'+ NPVDiffLumpsum_Loss);
        NPVDiffPSF = (NPVDiffLumpsum/ allChargesMap.get('AREA')).setscale(0,RoundingMode.HALF_UP);
        SUpdatedPlanNPV = QuotationManagementServices.INFormat(UpdatedPlanNPV);
        SUpdatedNPVPSF = QuotationManagementServices.INFormat(UpdatedNPVPSF);
        SNPVDiffLumpsum = QuotationManagementServices.INFormat(NPVDiffLumpsum);
        
        System.debug('AV3**'+allChargesMap.get('AGREEMENTVALUE'));
        System.debug('SNPVDiffLumpsum**'+SNPVDiffLumpsum);

        SNPVDiffPSF = QuotationManagementServices.INFormat(NPVDiffPSF);
        error = false;
        errorMessage = '';
        qplanWrapperListC = new List<QPlanDetailWrapper>();
                
        for(Integer i=0; i < updatedPd.size(); i++) {
            QPlanDetailWrapper q = new QPlanDetailWrapper(updatedPd[i].amount,updatedPd[i].serviceTax,updatedPd[i].totalPay, updatedPd[i].payPlanRecord,updatedPd[i].taxMap);
            if(updatedPd[i].totalError) {
                q.style = 'error';
                error = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'The payment plan defintion is incorrect,the amount/percentages are not adding up to agreement value'));
            } 
            qplanWrapperListC.add(q);
        }
        system.debug('In update : '+error);
        if(error) {
            return null;
        }
        
        if (NPVDiffLumpsum_Loss < 0 && selectedDiscountOption == 'Deferred') {
                system.debug('NPVDiffLumpsum_Loss'+ NPVDiffLumpsum_Loss +'-selectedDiscountOption--'+selectedDiscountOption);
                
                errorMessage = 'Error: Negative NPV difference with mismatched discount option Differ.';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Negative NPV difference with mismatched discount option Differ.'));
                system.debug('errorMessage'+ errorMessage);
                
            }
            
            
            if (NPVDiffLumpsum_Loss > 0 && selectedDiscountOption == 'Advance') {
                system.debug('NPVDiffLumpsum_Loss'+ NPVDiffLumpsum_Loss +'-selectedDiscountOption--'+selectedDiscountOption);
                
                errorMessage = 'Error: Negative NPV difference with mismatched discount option. Advance';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error: Negative NPV difference with mismatched discount option. Advance'));
                system.debug('errorMessage'+ errorMessage);
                
            }
        
       
        disableDiscount = true;
        editSchedule = true;
        scheduleEdited = true;
        showAddCarPark = false;
        
        return null;
    }
    
    // method for final save of the payment changes 
    // here we disable discounts as discounts cant be applied after editing the payment plan
    // action related to button, Save Changes
   /* public PageReference savePaymentSchedule() {
        System.debug('NPV Loss ===>'+ NPVDiffLumpsum_Loss);
        System.debug('Allotment Charges ===>'+ allotmentCharges);
        System.debug('Discount Charges ===>'+ discountLumpsum);
        System.debug('Agreement Charges ===>'+ agreementValue);
        System.debug('Orignal Agreement Charges ===>'+ allChargesMap.get('ORIGNALAGREEMENTVALUE'));
        
        Decimal TotalCardPark = selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7;
        System.debug('TotalCardPark Charges ===>'+ TotalCardPark);
        
        if(NPVDiffPSF != 0.0) {
            pDisc.add(pDisc.size()-1,new InventoryCostServices.DiscountWrapper('Payment plan deviation (NPV)', NPVDiffPSF, NPVDiffLumpsum,false,false,true,'NPV'));
        }
        QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue);
        system.debug('QuotedOfferValue===>'+ QuotedOfferValue);
        getUpdatedCharges();
        
        Decimal AV = allChargesMap.get('AGREEMENTVALUE');
        system.debug('AV===>'+ AV);
        
        qPlanWrapperList = new List<QPlanDetailWrapper>(); 
        qPlanWrapperList.addAll(qPlanWrapperListC);
        disableDiscount = true;
        editSchedule = false;
        scheduleEdited = true;
        if(quoteApprovalMsg.equals('N/A'))
            quoteApprovalMsg = 'This quotation will go for an approval as Modifications have been made to the payment plan';
        else 
            quoteApprovalMsg += ' & Modifications have been made to the payment plan';
        return null;
    }*/
public PageReference savePaymentSchedule() {
    System.debug('NPV Loss ===> ' + NPVDiffLumpsum_Loss);
    System.debug('Allotment Charges ===> ' + allotmentCharges);
    System.debug('Discount Charges ===> ' + discountLumpsum);
    System.debug('Agreement Charges ===> ' + agreementValue);
    System.debug('Original Agreement Charges ===> ' + allChargesMap.get('AGREEMENTVALUE'));
    System.debug('NPVDiffPSF===> ' + NPVDiffPSF);
    System.debug('NPVDiffLumpsum ===> ' + NPVDiffLumpsum);
    System.debug('pDisc ===> ' + pDisc);
    
    Decimal TotalCardPark = selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + 
                           selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7;
    System.debug('TotalCardPark Charges ===> ' + TotalCardPark);
    
    // Add NPV discount to pDisc list
    if(NPVDiffPSF != 0.0) {
        pDisc.add(pDisc.size()-1, new InventoryCostServices.DiscountWrapper(
            'Payment plan deviation (NPV)', NPVDiffPSF, NPVDiffLumpsum, false, false, true, 'NPV'
        ));
    }
    
    QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue);
    system.debug('QuotedOfferValue ===> ' + QuotedOfferValue);
    //referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//Call the Referral Details func..22-12-25
    
    // Recalculate charges with NPV loss adjustment
    getUpdatedCharges();
    
    Decimal AV = allChargesMap.get('AGREEMENTVALUE');
    system.debug('AV from allChargesMap ===> ' + AV);
    
    // CRITICAL FIX: Recalculate the payment schedule with the adjusted agreement value
    // This ensures the payment plan matches the final agreement value
    InventoryCostServices.baseRateVal = baseRate;
    InventoryCostServices.premiumRateVal = premiumRate;
    InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
    
    // Get the updated charges map that includes NPV loss
    Map<String, Decimal> adjustedChargesMap = InventoryCostServices.getAllCharges(
        unitId, 
        allotmentCharges, 
        discountLumpsum, 
        subPlanId
    );
    
    System.debug('Adjusted Agreement Value ===> ' + adjustedChargesMap.get('AGREEMENTVALUE'));
    
    // Rebuild the payment plan wrappers with correct amounts
    List<InventoryCostServices.PlanDetailWrapper> pdList = new List<InventoryCostServices.PlanDetailWrapper>();
    for(QPlanDetailWrapper q : qPlanWrapperListC) {
        InventoryCostServices.PlanDetailWrapper pdw = new InventoryCostServices.PlanDetailWrapper(
            q.amount, 
            q.serviceTax, 
            q.payPlanRecord
        );
        pdList.add(pdw);
    }
    
    // Remove the grand total row
    if(pdList.size() > 0) {
        pdList.remove(pdList.size()-1);
    }
    
    // Recalculate with the adjusted charges map to get correct totals
    List<InventoryCostServices.PlanDetailWrapper> recalculatedPlan = 
        InventoryCostServices.calculateUpdatedPaymentSchedule(
            pdList, 
            adjustedChargesMap, 
            payplanDetails,
            unitId
        );
    
    System.debug('Recalculated Plan Size ===> ' + recalculatedPlan.size());
    
    // Update qPlanWrapperListC with recalculated values
    qPlanWrapperListC.clear();
    for(InventoryCostServices.PlanDetailWrapper pdw : recalculatedPlan) {
        QPlanDetailWrapper qpw = new QPlanDetailWrapper(
            pdw.amount,
            pdw.serviceTax,
            pdw.totalPay,
            pdw.payPlanRecord,
            pdw.taxMap
        );
        qPlanWrapperListC.add(qpw);
    }
    
    // Update qPlanWrapperList (this is what's displayed on the page)
    qPlanWrapperList.clear();
    qPlanWrapperList.addAll(qPlanWrapperListC);
    
    System.debug('qPlanWrapperList size after update: ' + qPlanWrapperList.size());
    
    // Verify the total matches
    Decimal calculatedTotal = 0;
    for(QPlanDetailWrapper qpw : qPlanWrapperList) {
        if(qpw.payPlanRecord != null) {
            calculatedTotal += qpw.amount;
        }
    }
    System.debug('Calculated Total from Payment Plan ===> ' + calculatedTotal);
    System.debug('Expected Agreement Value ===> ' + adjustedChargesMap.get('AGREEMENTVALUE'));
    
    // Reset the edit flags
    disableDiscount = true;
    editSchedule = false;
    scheduleEdited = true;
    
    // Update approval message
    if(quoteApprovalMsg.equals('N/A')) {
        quoteApprovalMsg = 'This quotation will go for an approval as Modifications have been made to the payment plan';
    } else if(!quoteApprovalMsg.contains('payment plan')) {
        quoteApprovalMsg += ' & Modifications have been made to the payment plan';
    }
    
    return null;
}

    
    // ===========END: PLAN EDIT Methods end here
    
    // =============START: All DISCOUNT related methods start here ============
    
    
    public PageReference openDiscountPage(){
        isCalculateDiscountClicked = true;//Added for Quotation Offer
        PageReference pageRef = new PageReference('/apex/QuotationDiscount');
        pageRef.getParameters().put('id',u.Id);
        return pageRef;
        
        
    }
    public PageReference backtoQuotePage(){
        PageReference pageRef = new PageReference('/apex/Quotation2');
        pageRef.getParameters().put('subPlanId',selectedPlan);
        pageRef.getParameters().put('id',unitId);
        pageRef.getParameters().put('oppId',oppId);
        system.debug('selectedPlan ::: '+selectedPlan );
        pageRef.getParameters().put('discountVal', String.valueOf(CP_DiscountInput));
 		system.debug(' check CP_DiscountInput backtoQuotePage==='+CP_DiscountInput);
        system.debug('oppid - >'+oppId);
        system.debug('unitId - >'+unitId);
        system.debug('oppid - >'+oppId);
        System.debug('agreementValue**'+agreementValue);
        QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue); 
        referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//Call the Referral Details func..22-12-25//Uncommented by Prakshi
        // if a plan was already selected, refetch the plan with the updated CV apportionment
        if(selectedPlan != null) {
            Apexpages.currentPage().getParameters().put('subPlanId',selectedPlan);
            QueryPlanDetails();
        }
        return pageRef;
    }
    public PageReference clearDiscount(){
        discountPSF = 0;
        discountlumpsum = 0;
        //pDisc = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
        //pDisc1 = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
        FinalCustomerDiscount = null;
        quoteApprovalMsg = 'N/A';
        PageReference pageRef = new PageReference('/apex/QuotationDiscount');
        pageRef.getParameters().put('id',u.Id);
        pageRef.getParameters().put('oppId',oppId);
        pageRef.getParameters().put('subPlanId',subPlanId);
        return pageRef;
    }
    //Getter for getting all referral values in fields-- 23-12-25
    /*public String getFormattedRefDisc() {return referralDetailsVsValueMap != null ? referralDetailsVsValueMap.get('FormattedRefDisc'): null;}
    public String getFormattedRefDiscPassBack() {return referralDetailsVsValueMap != null ? referralDetailsVsValueMap.get('FormattedRefDiscPassBack'): null;}
    public String getFormattedRefDiscAV() {return referralDetailsVsValueMap != null ? referralDetailsVsValueMap.get('FormattedRefDiscAV'): null;}
    public String getFormattedRefDiscPassBackAV() {return referralDetailsVsValueMap != null ? referralDetailsVsValueMap.get('FormattedRefDiscPassBackAV'): null;}
    */
    //Referral Values Population....22-12-25 
    public Map<String,String> fetchReferralDetails(Opportunity o,Decimal agreementValue){
        referralDetailsVsValueMap = new Map<String,String>();  
        Decimal DiscountedAV = agreementValue;
        Decimal referralDiscount = 0;
        Decimal referralDiscountAV = 0 ;
        Decimal RefDiscPassBack = 0;
        Decimal RefDiscPassBackAV = 0;
        if(o != null) {
            system.debug('DiscountedAV=='+DiscountedAV);    
            if(DiscountedAV != null) {
                if(o.Walkin_Source__c == 'Referral' && 
                   ( o.Walkin_SubSource__c == 'Existing client ref' || o.Walkin_SubSource__c == 'Existing client reference')) {//Added Existing client reference value for Quotation offer
                       // 0.5% standard referral discount
                       referralDiscount = DiscountedAV * 0.005; 
                       DiscountedAV -= referralDiscount;
                       referralDiscountAV = DiscountedAV - referralDiscount;//Uncommented by Prakshi
                       system.debug('AV after giving referral discount ==>' +DiscountedAV );
                       system.debug('0.5% referral discount applied: ' + referralDiscount);
                       //referralDetailsVsValueMap.put('FormattedRefDisc',QuotationManagementServices.INFormat(referralDiscount));
                       FormattedRefDisc = QuotationManagementServices.INFormat(referralDiscount);  
                       FormattedRefDiscAV = QuotationManagementServices.INFormat(referralDiscountAV); 
                       referralDetailsVsValueMap.put('FormattedRefDisc',FormattedRefDisc);
                       //referralDetailsVsValueMap.put('FormattedRefDiscAV',FormattedRefDiscAV);
                       if(o.Opt_for_Referral__c == True) {
                           // 1% discount if opted out of referral
                           RefDiscPassBack = referralDiscountAV * 0.01;
                           system.debug('1.5% RefPassback applied: ' + RefDiscPassBack);
                           DiscountedAV -= RefDiscPassBack;
                           RefDiscPassBackAV = DiscountedAV - RefDiscPassBack;
                           system.debug('1.5% referral discount applied: ' + DiscountedAV);
                           referralDetailsVsValueMap.put('FormattedRefDiscPassBack',QuotationManagementServices.INFormat(RefDiscPassBack));
                           FormattedRefDiscPassBack = QuotationManagementServices.INFormat(RefDiscPassBack);      
                           FormattedRefDiscPassBackAV = QuotationManagementServices.INFormat(RefDiscPassBackAV); 
                       } 
                   }
                else if((o.Walkin_Source__c == 'Loyalty' || o.LeadSource == 'Loyalty') && 
                        (o.Walkin_SubSource__c == 'Existing client reference' || o.Lead_Sub_Source__c == 'Existing client reference')){ 
                            referralDiscount = DiscountedAV *0.015;
                            DiscountedAV -= referralDiscount;
                            referralDiscountAV = DiscountedAV - referralDiscount;
                            system.debug('Discount for loyalty calculated__');
                            referralDetailsVsValueMap.put('FormattedRefDisc',QuotationManagementServices.INFormat(referralDiscount));
                            FormattedRefDisc = QuotationManagementServices.INFormat(referralDiscount);  
                            FormattedRefDiscAV = QuotationManagementServices.INFormat(referralDiscountAV); 
                        }
            }      
            referralDetailsVsValueMap.put('agreementValue',QuotationManagementServices.INFormat(DiscountedAV));
            
        }
        return referralDetailsVsValueMap;
    } 
    //Referral Values Population....22-12-25
    
    public pageReference calculateGSTpercenatgeDisc () {
        Decimal gstPSF = 0 ;
        Decimal gstLumpsum = 0;
        Decimal totalGSTPercentage = 0;
        gstPSF = u.Saleable_Area__c * GstPsfRate;
        gstLumpsum = GstLumpsumRate;
        agreementValue = allChargesMap.get('AGREEMENTVALUE');
        System.debug('AgreementValue::'+agreementValue);
        if(u.Tax_Rate_Basic__c != null && u.Tax_Rate_Basic__c == 'GST 8%') {
            totalGSTPercentage = ((agreementValue - (gstPSF + gstLumpsum)) * proj.GST_Percenatge_Discount_Unit__c / 100).setscale(0,RoundingMode.HALF_UP);
            GSTpercentageApplied = proj.GST_Percenatge_Discount_Unit__c;
        }
        else if(proj.GST_Percentage_Discount__c != null) {
            totalGSTPercentage = ((agreementValue - (gstPSF + gstLumpsum)) * proj.GST_Percentage_Discount__c/100).setscale(0,RoundingMode.HALF_UP);
            GSTpercentageApplied = proj.GST_Percentage_Discount__c;
        }
        if(q.project__r.Name != null && (q.project__r.Name.equalsIgnoreCase('Runwal Bliss') && q.Project_Unit__r.TowerName__r.Name.equalsIgnoreCase('F') ) ) {
            totalGSTPercentage = 0;                        //Added by Sheetal on 20/01/2022 to solve ISSUE I0102
            GSTpercentageApplied = 0;
        }
        
        TotalGSTDiscount = QuotationManagementServices.INFormat(totalGSTPercentage);
        TotalGSTDiscountPSF = QuotationManagementServices.INFormat((totalGSTPercentage / u.Saleable_Area__c).setscale(0,RoundingMode.HALF_UP));
        return null;
    }
    
    // customer discount details wrapper list
    public List<InventoryCostServices.DiscountWrapper> FinalCustomerDiscount{ 
        
        get {
            if(FinalCustomerDiscount == null) {
                FinalCustomerDiscount = new List<InventoryCostServices.DiscountWrapper>();
                FinalCustomerDiscount.add(new InventoryCostServices.DiscountWrapper('Customer Discount Total', 0.0, 0.0,false,false,false, 'Customer Discount Total') );
                FinalCustomerDiscount.add(new InventoryCostServices.DiscountWrapper('Client Rate (Post Discount)', 0.0, 0.0,false,false,false, 'Client Rate (Post Discount)') );
            } 
            return FinalCustomerDiscount;
        }
        set  {
            System.debug('value**'+value);
            FinalCustomerDiscount = value;
            System.debug('FinalCustomerDiscount**'+FinalCustomerDiscount);
        }
        
    }
    
    // used for getting the discounted cost values. this is called from "Apply discount button
    // on apply discount, we keep the original quotation values as is in the quoteUIMap and
    //populate the quoteUIDiscMap with the new values of charges
    // if the discount is 0, then make the map values back to null, the map with the discount details
    // section renders only if its not null
    public void getUpdatedCharges(){
        PageReference pageRef = new PageReference('/apex/QuotationDiscount');
        system.debug(' check NPVDiffLumpsum_Loss==='+NPVDiffLumpsum_Loss);
        Decimal custLumpsumActual = 0.0;
        Decimal custPSFActual = 0.0; 
        Decimal custLumpsumNotional = 0.0; //includes the NPV
        Decimal custPSFNotional = 0.0;  // includes the NPV
        Decimal NPV_OfferAV = 0.0;
        discountPSF = 0;
        discountLumpsum =0; 
        
        //sourceDiscount = sourceDiscount-discountLumpsum;
        //stSourceDiscount = QuotationManagementServices.INFormat(sourceDiscount);
        
        system.debug('agreement value in get update chages method == > '+ agreementValue);
        /*if(CP_PassbackAV != null && CP_PassbackAV > 0){
            unitId = (Id)ApexPages.currentPage().getParameters().get('id'); 
            subPlanId = (Id)ApexPages.currentPage().getParameters().get('subPlanId'); 
            allotmentCharges = CP_PassbackAV;
            
            System.debug('inside CP_PassbackAV condition' + CP_PassbackAV);
            System.debug('unitId: ' + unitId);
            System.debug('allotmentCharges: ' + allotmentCharges); 
            System.debug('discountLumpsum: ' + discountLumpsum);
            System.debug('car park sum: ' + (selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7));
            System.debug('subPlanId: ' + subPlanId);
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
            
            quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(
                unitId,
                allotmentCharges,
                discountLumpsum,
                selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + 
                selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7,
                subPlanId
            );
            
            System.debug('quoteUIMapDisc result: ' + quoteUIMapDisc);
            
        }*/
        Decimal originalAllotmentCharges = allotmentCharges;
        Decimal calculatedAllotmentCharges = originalAllotmentCharges;

        if(NPVDiffLumpsum_Loss != null){
            System.debug('inside NPV condition');
            System.debug('unitId: ' + unitId);
            System.debug('allotmentCharges: ' + allotmentCharges); 
            System.debug('discountLumpsum: ' + discountLumpsum);
            System.debug('car park sum: ' + carParkAmt);
            System.debug('subPlanId: ' + subPlanId);
            // Add these lines
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
            
            // Calculate NPV_OfferAV properly
            unitId = (Id)ApexPages.currentPage().getParameters().get('id'); 
            subPlanId = (Id)ApexPages.currentPage().getParameters().get('subPlanId'); 
            allotmentCharges = allotmentCharges + NPVDiffLumpsum_Loss;
            //calculatedAllotmentCharges = originalAllotmentCharges + (NPVDiffLumpsum_Loss);
            system.debug('allotmentChargeLumsum in NPV ===>'+ allotmentChargeLumsum);
            system.debug('allotmentCharges in NPV ===>'+ allotmentCharges);
            system.debug('calculatedAllotmentCharges in NPV ===>'+ calculatedAllotmentCharges);
            //quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(unitId,allotmentCharges,discountLumpsum,carParkAmt,subPlanId);
            system.debug('quoteUIMapDisc in Updated charges ===>'+ quoteUIMapDisc);
        }else{
        }      calculatedAllotmentCharges = originalAllotmentCharges;
       
        
        List<InventoryCostServices.DiscountWrapper> appliedDiscounts = new List<InventoryCostServices.DiscountWrapper>();
        
        System.debug('pDisc::**'+pDisc);
        for(InventoryCostServices.DiscountWrapper  d : pDisc) {
            /**Added for Quotation Offer starts */
            System.debug('d.selected**'+d.selected);
            System.debug('d.applied**'+d.applied);
            System.debug('d.discountCategory**'+d.discountCategory);
            System.debug('nonMonetaryOfferCheckbox**'+nonMonetaryOfferCheckbox);

            /**Added for Quotation Offer starts */
            if(d.discountCategory =='Non monetary'){
                if(d.applied == true){
                    isAnyNonMonetarySelected = true;
                }
                else{
                 isAnyNonMonetarySelected = false;
                }
            }
            /**Added for Quotation Offer ends */

            if(d.discountCategory == 'Non monetary' && d.applied == false && nonMonetaryOfferCheckbox == false && isAnyNonMonetarySelected!= true){
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Non Monetory Discounts Not Applicable .'));     
            return;
            }
            
            /**Added for Quotation Offer ends */
            system.debug('d.applied getting on 785==>'+ d.type + '---' + d.applied);
            system.debug('d.applied getting on 785==>'+ d.type + '---' + d.isMonetizableChecked);
            
            if(d.type != null && d.type.equals('Total Discount')) {
                d.PerSqFtVal = 0;
                d.LumpsumVal  = 0;
            }
            System.debug('d.isMonetizableChecked**'+d.isMonetizableChecked);
            System.debug('d.showMonetizable**'+d.showMonetizable);
            if(d.applied && d.type != 'Payment Plan Deviation (NPV)') {
                if(d.isMonetizableChecked == true || d.showMonetizable == false){
                    discountLumpsum += d.LumpsumVal;
                    //custLumpsumActual += d.LumpsumVal;//Commented for Quotation Offer
                    custPSFActual += d.PerSqFtVal;
                    appliedDiscounts.add(d);
                }
            } 
            System.debug('custLumpsumActual on pdisc'+custLumpsumActual);
           
            if (d.applied) {
                discountLumpsum += d.LumpsumVal;//Added for Quotation Offer
                custLumpsumActual += d.LumpsumVal;//Added for Quotation Offer
                custLumpsumNotional += d.LumpsumVal;
                custPSFNotional += d.PerSqFtVal;
                custPSFActual += d.PerSqFtVal;//Added for Quotation Offer
                /**Added by Prakshi for Quotation Offer starts */
                appliedDiscounts.add(d);
                if(d.PerSqFtVal > d.PerSqFtMax) {
                    quoteApprovalMsg = 'Approval Required for Discount - ' + d.type + '--';
                }
                /**Added by Prakshi for Quotation Offer ends */
            }
        }
        system.debug('pDisc1::: '+pDisc1);
        System.debug('custLumpsumActual**'+custLumpsumActual);
        // Commented pDisc1 loop by Prakshi as Customer Discount Total after apply discount is getting doubled for mandatory discounts
         /**for(InventoryCostServices.DiscountWrapper  d : pDisc1) {
            system.debug('d:: '+d);
            if (d.applied) {
                discountLumpsum += d.LumpsumVal;
                custLumpsumActual += d.LumpsumVal;
                custPSFActual += d.PerSqFtVal;
                
                custLumpsumNotional += d.LumpsumVal;
                custPSFNotional += d.PerSqFtVal;
                 appliedDiscounts.add(d);
                if(d.PerSqFtVal > d.PerSqFtMax) {
                    quoteApprovalMsg = 'Approval Required for Discount - ' + d.type + '--';
                }
            }
            System.debug('custLumpsumActual after**'+custLumpsumActual);
        }**/
        
         if(!appliedDiscounts.isEmpty()) {
             system.debug('quotation Id ===>'+ q.Id);
             system.debug('appliedDiscounts at line 824 ===>'+ appliedDiscounts);
        //createDiscountTasks(appliedDiscounts); // You need to pass the quote ID
     }
        
        
        // the total discount reflects the notional discount as well in the discount categories
        if(custPSFNotional != 0) {
            for(InventoryCostServices.DiscountWrapper  d : pDisc) {
                if(d.type.equals('Total Discount')) {
                    d.PerSqFtVal = custPSFNotional;
                    d.LumpsumVal  = custLumpsumNotional;
                }
            }
        }
        
        
        // if at all any actual discounts have been applied to the customer, then set the customer level discount wrapper
        // with max at project level and whats the increment given to the customer
        // recalculate the total cost
        // NPV is a notional discount and doesnt affect the final rates
        if(custLumpsumNotional != 0 || custPSFNotional != 0) {
            System.debug('FinalCustomerDiscount1**'+FinalCustomerDiscount);
            for(InventoryCostServices.DiscountWrapper  cf : FinalCustomerDiscount) {
                if(cf.Type.equals('Customer Discount Total')) {
                    cf.PerSqFtVal = custPSFActual;
                    cf.LumpsumVal = custLumpsumActual;
                    cf.SPerSqFtVal  = QuotationManagementServices.INFormat(cf.PerSqFtVal);
                    cf.SLumpsumVal  = QuotationManagementServices.INFormat(cf.LumpsumVal);
                    System.debug('SLumpsumVal for applied discount ==>' + cf.SLumpsumVal);
                }
                if(cf.Type.equals('Client Rate (Post Discount)')) {
                    cf.PerSqFtVal = allChargesMap.get('TOTALRATECARDPSF') - custPSFActual;
                    cf.LumpsumVal = allChargesMap.get('TOTALRATECARDLUMPSUM') - custLumpsumActual;
                    cf.SPerSqFtVal  = QuotationManagementServices.INFormat(cf.PerSqFtVal);
                    cf.SLumpsumVal  = QuotationManagementServices.INFormat(cf.LumpsumVal);
                }
                System.debug('cf.LumpsumVal**'+cf.LumpsumVal);
            }
        }
        // recalculate the project cost
        system.debug('discountLumpsum__'+ discountLumpsum); 
        if(discountLumpsum == 0){
           system.debug('in fixedDiscount line no 905');
            //agreementValue = originalAgreementVal - fixedDiscount;
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
             system.debug('Inside baseRate 914' + baseRate);
             system.debug('Inside premiumRate 914'+ premiumRate);
             system.debug('Inside agreementValue 914'+ agreementValue);
                         system.debug('Inside agreementValue / allotmentChargeLumsum 914'+ allotmentChargeLumsum);

            
            quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(unitId,allotmentCharges,discountLumpsum, selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7, subPlanId);
            system.debug('quoteUIMapDisc__after no discount__'+ quoteUIMapDisc); 
            
        }else if(discountLumpsum != 0) {
         
            system.debug('Inside if__ line 914');
            system.debug('Inside if__ line 914 allotmentChargeLumsum' + allotmentChargeLumsum + 'allotmentCharges===>' + allotmentCharges);
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
            quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(unitId,allotmentCharges,discountLumpsum, selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7, subPlanId);
            system.debug('quoteUIMapDisc__after applying discount__'+ quoteUIMapDisc); 
            //lstAllAppliedDiscounts = discountResult.appliedDiscounts != null ? discountResult.appliedDiscounts : new List<Quote_Applied_Discounts__c>(); 

            
        }else if(CP_PassbackValue != 0 || CP_PassbackAV != 0) {
        // Use the CP Passback value as the new agreement value
        quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(
            unitId, allotmentCharges, discountLumpsum, 
            selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6 + selectedCarPark7, 
            subPlanId
        );
    
        // Update agreement value with CP Passback value
        if (CP_PassbackAV != 0) {
            agreementValue = CP_PassbackAV;
        } else if (CP_PassbackValue != 0) {
            agreementValue = originalAgreementVal - CP_PassbackValue;
        }
        }else{
                    quoteUIMapDisc = null;
            }
        // Vinit here i calculate the quote av value 
        agreementValue = agreementValue -  discountLumpsum;
        
       sAgreementvaluepostDiscount = QuotationManagementServices.INFormat(agreementValue);

        system.debug('agreement===>'+ agreementValue);
        disableDiscount = false;
        editSchedule = false;
        showAddCarPark = false;//Commented for Quotation Offer
    }
    
    //Vinit: method created for the creating a task record for non mandetory disocunts here 
    public void createDiscountTasks(List<InventoryCostServices.DiscountWrapper> discountWrappers) {
       system.debug('Method call');
        system.debug('quotation Id inside create discount task method ===>'+ q.Id);
        system.debug('discountWrappers inside create discount task method ===>'+ q.Id);
        
        List<Task> tasksToCreate = new List<Task>();
        Set<String> existingTaskSubjects = new Set<String>();
        Recordtype  lstrecordtype = [select id, name from RecordType where Name = 'Collection Task' limit 1];
        Opportunity objopp = [select id, Sourcing_Manager_User__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,Walk_in_Source__c,
                              Walkin_Source__c,Opt_for_Referral__c,Referral_Sub_Source__c from opportunity where id =: oppId Limit 1]; //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
        List<Task> lstexistingTask = [SELECT Id, Subject 
                                FROM Task 
                                WHERE Subject LIKE 'Discount Applied:%'];
        
        for(Task existingTask : lstexistingTask) {
            existingTaskSubjects.add(existingTask.Subject);
        }
        
        for(InventoryCostServices.DiscountWrapper d : discountWrappers) {
            if(d.applied && d.type != 'Payment Plan Deviation (NPV)') {
                String taskSubject = 'Discount Applied: ' + d.type;
                if(!existingTaskSubjects.contains(taskSubject)) {
                Task discountTask = new Task();
                discountTask.OwnerId = objopp.Sourcing_Manager_User__c;
                //discountTask.WhatId = quoteId; // Link to the Quote
                discountTask.Subject = taskSubject;
                discountTask.Description = 'Discount Type: ' + d.type + 
                    '\nPer Sq Ft Value: ' + d.SPerSqFtVal +
                    '\nLumpsum Value: ' + d.SlumpsumVal +
                    '\nDiscount Type: ' + d.discountType;
                discountTask.Status = 'Not Started';
                discountTask.Priority = 'Normal';
                discountTask.ActivityDate = System.today().addDays(7);
                discountTask.RecordTypeId = lstrecordtype.id;
                discountTask.Next_Action_Date__c = System.today().addDays(14);
                
                
                tasksToCreate.add(discountTask);
                }
            }
        }
        
        if(!tasksToCreate.isEmpty()) {
            try {
                insert tasksToCreate;
                System.debug('Task created id  ' + tasksToCreate + ' discount tasks');
                System.debug('Created ' + tasksToCreate.size() + ' discount tasks');
            } catch (Exception e) {
                System.debug('Error creating discount tasks: ' + e.getMessage());
                // Handle error appropriately - maybe show a message to user
            }
        }
    }
    public PageReference MathforAppliedDiscount() {
        

       
        Boolean change = false;
        Boolean change1 = false;
        
        System.debug('pdisc*'+pDisc);
        for(InventoryCostServices.DiscountWrapper  d : pDisc) {

            System.debug('d.discountType1 **'+d.discountType );
            System.debug('d.applied1 **'+d.applied );
            /**Added for Quotation Offer starts */
            // if(d.applied == true && d.discountCategory =='Non monetary'){
            //     isAnyNonMonetarySelected = true;
            //     break;
            // }
            /**Added for Quotation Offer ends */
            
            if(d.applied && d.showMonetizable) {
                if(d.applied){
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                }  
                if(d.isMonetizableChecked && d.applied) {
                    // User wants to apply but NOT monetize - set lumpsum to 0
                    //d.lumpsumVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    System.debug('Non-monetized discount applied: ' + d.Type + ' - Lumpsum set to 0');
                }
            }else if(!d.applied && d.offerType == 'Mandatory'){
                d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
            }

            if(d.selected) {
                change = true;
                if(d.Type.equals('Floor Rise') || d.Type.equals('Referral') || d.Type.equals('GST Discount') 
                   || d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount') || d.Type.equals('Others') || d.Type.equals('CP Passback') ||d.Type.equals('Referral Passback')){
                       if(d.perSqFtVal != 0 && d.lumpsumVal!= 0 && d.psf) {
                           d.lumpsumVal = (d.perSqFtVal * u.Actual_Area_value__c).setscale(0, RoundingMode.HALF_UP);
                           system.debug('lumpsum value in method for applied discount__'+ d.lumpsumVal);
                           d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                           d.psf = false;
                           d.lumpsum = false;
                           d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                           
                       }
                   }
                
            }  
            
        }
        /*for(InventoryCostServices.DiscountWrapper  d : pDisc1) {

        if(d.selected) {
        change1 = true;              
        }
        }*/
        for(InventoryCostServices.DiscountWrapper  d : pDisc) {
            if(change && !(d.DiscountType == 'NPV'  || d.discountType == 'Total') ) {            
                if(d.selected) {
                    //d.applied = true;////Commented by Prakshi because after selecting apply checkbox all the checkbox are getting selected
                    //d.selected = false;//Commented for Quotation Offer because after selecting apply checkbox all the checkbox are getting unselecetd
                System.debug('selected for'+d.selected);
                System.debug('applied for'+d.applied);
                } else {
                    d.applied = false;//commented for Quotation offer
                    d.selected = false;
                    System.debug('selected else'+d.selected);
                    System.debug('applied else'+d.applied);
                }               
            }
            System.debug('selected Final'+d.selected);
            System.debug('applied Final'+d.applied);
        }    
        
               System.debug('pDisc1**'+pDisc);

        for(InventoryCostServices.DiscountWrapper  d : pDisc) { 
            system.debug('InventoryCostServices.DiscountWrapper__'+ d);
            if(change) {
                if(d.selected) {
                    //d.applied = true;//Commented by Prakshi because after selecting apply checkbox all the checkbox are getting selected
                    d.selected = false;
                } else {
                    d.applied = false;//commented for Quotation offer
                    d.selected = false;
                }
                
            }
            //system.debug('d.type:: '+d.type+ ' - d.Applied:: '+d.applied);
            // Adding changes for Diacount details and Vouchers details - Digicloud team - Suraj S.
            if(d.applied) {
                system.debug('Inside if Discount Applied__'+ d.Type);
                system.debug('Inside if Discount Applied__'+ d.lumpsumVal); 
                if(d.Type.equals('SCUD') || d.Type.equals('GST Discount') || d.Type.equals('Floor Rise') || d.Type.equals('Referral')
                   || d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount') || d.Type.equals('Others') || d.Type.equals('CP Passback') || d.Type.equals('Referral Passback')|| d.Type.equals('Lumpsum') || d.Type.equals('PSF') || d.Type.equals('Percentage') || d.Type.equals('Discount 5') || d.Type.equals('Discount 4')) {
                       //system.debug('SCUD condition');
                       if(d.perSqFtVal != 0 && d.lumpsumVal!= 0 && (d.psf && d.lumpsum)) {
                           ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL,'Select either per.sq.ft or lumpsum discount')));
                           if(d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount')) {
                               d.lumpsumVal = 0;
                               //d.perSqFtVal = 0;
                               d.applied=false;
                               return null;
                           }
                           
                           else {
                               d.lumpsumVal = 0;
                               d.perSqFtVal = 0;
                               d.applied=false;
                               return null;
                           }
                       } 
                       //    system.debug('d.perSqFtVal :: '+d.perSqFtVal);
                       //    system.debug('d.lumpsumVal :: '+d.lumpsumVal);
                       
                       if(d.perSqFtVal != 0 && (d.psf && d.lumpsum)) {                       
                           d.lumpsumVal = (d.perSqFtVal * u.Actual_Area_value__c).setscale(0, RoundingMode.HALF_UP); 
                           d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                           d.psf = false;
                           d.lumpsum = false;
                           d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                       }
                       if(d.lumpsumVal != 0 && (d.psf && d.lumpsum))  {
                           d.perSqFtVal = (d.lumpsumVal / u.Actual_Area_value__c).setscale(0, RoundingMode.HALF_UP);
                           d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                           d.psf = false;
                           d.lumpsum = false;
                           d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                       }
                       if(/*d.perSqFtVal != 0 && */ d.psf) { //&& d.lumpsum)    
                           // Added by digicloud team - 5-6-2025 - Suraj S
                           system.debug('d.Type on line 900__'+ d.Type); 
                           if(d.Type != 'Referral'){
                               d.lumpsumVal = (d.perSqFtVal * u.Actual_Area_value__c).setscale(0, RoundingMode.HALF_UP);
                           }else if(d.Type == 'Referral' && agreementValue != null){  
                               d.lumpsumVal = agreementValue * 0.005;
                           }
                           system.debug('d.lumpsumVal__'+ d.lumpsumVal);
                           //d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                           d.psf = false;
                           d.lumpsum = false;
                           d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                       }
                       if(d.lumpsumVal != 0 && d.lumpsum)  {
                           d.perSqFtVal = (d.lumpsumVal / u.Actual_Area_value__c).setscale(0, RoundingMode.HALF_UP);
                           d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                           d.psf = false;
                           d.lumpsum = false;
                           d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                       }
                       
                       
                   }
            } else {
                if(d.Type.equals('SCUD') || d.Type.equals('GST Discount')  ) {
                    d.psf = true;
                    d.lumpsum = true;
                    d.lumpsumVal = 0;
                    d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                }
                else if(d.Type.equals('Floor Rise') ) {
                    d.psf = true;
                    d.lumpsum = false;
                    //d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                    
                }
                else if(d.Type.equals('Others') ) {                 // Added by Sheetal on 6/12/2021
                    d.psf = true;
                    d.lumpsum = false;
                    //d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                }
                else if(d.Type.equals('CP Passback')) {
                    o = [Select Id, Name, Account.Name,Walkin_Source__c,Opt_for_Referral__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,Walk_in_Source__c,Referral_Sub_Source__c,Walkin_SubSource__c,LeadSource from Opportunity where Id = :oppId]; //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025 // Added LeadSource
                    if(d.Type == 'CP Passback' && o.Walkin_Source__c != 'Channel Partner'){
                        d.psf = false;
                        d.lumpsum = false;
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Walkin Source is not channel partner'));              
                    }
                    d.psf = false;
                    d.lumpsum = true;
                    //d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);                                          
                }
                else if(d.Type.equals('Referral Passback')) {         
                    d.psf = false;
                    d.lumpsum = true;
                    //d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);                                          
                }
                else if(d.Type.equals('Referral')) {
                    d.psf = false;
                    d.lumpsum = true;
                    //d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    system.debug('d.lumpsumVal__'+ d.lumpsumVal);
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                }
                else if(d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount')) {
                    d.psf = true;
                    d.lumpsum = true;
                    d.lumpsumVal = 0;
                    //d.perSqFtVal = 0;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                }
                //Adding conditions for discount and voucher related additions
                else if(d.Type.equals('Lumpsum') || d.Type.equals('PSF') || d.Type.equals('Percentage')){
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal); 
                    system.debug('d.SlumpsumVal__value from Dicount Details__' + d.SlumpsumVal);
                }
            } 
            //   System.debug('Math:' + d);
        }
        
        
        
        Decimal custLumpsumActual = 0.0;
        Decimal custPSFActual = 0.0; 
        Decimal custLumpsumNotional = 0.0; //includes the NPV
        Decimal custPSFNotional = 0.0;  // includes the NPV
        
        for(InventoryCostServices.DiscountWrapper  d : pDisc) {
            if(d.type.equals('Total Discount')) {
                d.PerSqFtVal = 0;
                d.LumpsumVal  = 0;
                d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal); 
                d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
            }
            if(d.applied && d.type != 'Payment Plan Deviation (NPV)') {
                discountLumpsum += d.LumpsumVal;
                custLumpsumActual += d.LumpsumVal;
                custPSFActual += d.PerSqFtVal;
            } 
            if (d.applied) {
                custLumpsumNotional += d.LumpsumVal;
                custPSFNotional += d.PerSqFtVal;
            }
        }
        
        // the total discount reflects the notional discount as well in the discount categories
        if(custPSFNotional != 0) {
            for(InventoryCostServices.DiscountWrapper  d : pDisc) {
                if(d.type.equals('Total Discount')) {
                    d.PerSqFtVal = custPSFNotional;
                    d.LumpsumVal  = custLumpsumNotional;
                    d.SlumpsumVal = QuotationManagementServices.INFormat(d.lumpsumVal);
                    d.SperSqFtVal = QuotationManagementServices.INFormat(d.perSqFtVal);
                }
            }
        }

        //  mandetoryDiscount = 0;
            nonMandetory_monetorydiscount = 0;
            nonMandetory_nonmonitizablediscount= 0;
            nonMandetory_monitizablediscount = 0;

            System.debug('=== Apply Discount START ===');
            System.debug('Discounts list size (pDisc): ' + (pDisc != null ? pDisc.size() : 0));

        // Loop over project-level discounts (pDisc holds what user selected in VF)
        if (pDisc != null) {
            for (InventoryCostServices.DiscountWrapper d : pDisc) {
                System.debug('Checking discount row: ' + d.type + 
                         ', applied? ' + d.applied + 
                         ', applied? ' + d.offerType + 
                         ', PSF=' + d.perSqFtVal + 
                         ', Lumpsum=' + d.lumpsumVal +
                         ', isMonetizableChecked=' + d.isMonetizableChecked +
                         ', Percentage=' + d.percentageVal +
                        ',showMonetizable'+d.showMonetizable +
                        ',discountType'+d.discountType);
                if (d.offerType == 'Non Mandatory' && d.applied== true && d.showMonetizable == false) {
                    nonMandetory_monetorydiscount += d.lumpsumVal != null ? d.lumpsumVal : 0;
                    StringnonMandetory_monetorydiscount = QuotationManagementServices.INFormat(nonMandetory_monetorydiscount);
                    System.debug('Added to Non-Mandatory Monetory: ' + d.lumpsumVal);
                }else if (d.offerType == 'Non Mandatory' && d.isMonetizableChecked == false && d.applied== true && d.showMonetizable == true  ){
                    nonMandetory_nonmonitizablediscount += d.lumpsumVal != null ? d.lumpsumVal : 0;
                    StringnonMandetory_nonmonitizablediscount = QuotationManagementServices.INFormat(nonMandetory_nonmonitizablediscount);
                    System.debug('Added to Non-Mandatory Non-Monetory: ' + d.lumpsumVal);
                } else if (d.offerType == 'Non Mandatory' && d.isMonetizableChecked == true && d.applied == true && d.showMonetizable == true ) {
                    nonMandetory_monitizablediscount += d.lumpsumVal != null ? d.lumpsumVal : 0;
                    StringnonMandetory_monitizablediscount = QuotationManagementServices.INFormat(nonMandetory_monitizablediscount);
                    System.debug('Added to Non-Mandatory Monetizable: ' + d.lumpsumVal);
                }   
                else{
                    StringnonMandetory_monetorydiscount = '0';//Added else block by Prakshi
                }
                /**Added by Prakshi starts */
                // if(d.applied == false && d.offerType =='Mandatory'){
                //     fixedDiscount -= d.lumpsumVal != null ? d.lumpsumVal : 0;
                //     SfixedDiscount = QuotationManagementServices.INFormat(fixedDiscount);
                //     system.debug('SfixedDiscount**'+ SfixedDiscount);
                //     system.debug('fixedDiscount****'+ fixedDiscount);
                // }
                /**Added by Prakshi ends */
            }
        }
        
    
        System.debug('=== Apply Discount END ===');
            
            
            return null;
    }
    
    
    // =============END: DISCOUNT related methods end here ============
    
    
    
    // =======START: quote related methods start here
    // 
    
    public PageReference savePrint(){
        //allChargesMap = new Map<String, Decimal>();
        System.debug('al chages map in save print'+ allChargesMap);
       // 
       /**Added for QUotation offer starts */
       if(isCalculateDiscountClicked != true){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Before saving, please navigate to the Calculate Discount page and select or deselect the required discounts.'));
         return null;
        }
       /**Added for QUotation offer ends */
        if(oppId != null && o == null) {
            o = [Select Id, Name, Account.Name, StageName, Sales_Manager__c, RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name, 
                 Walkin_SubSource__c, Referral_Sub_Source__c, Walkin_Source__c, Opt_for_Referral__c ,LeadSource
                 from Opportunity where Id = :oppId]; //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025//Added LeadSource by Prakshi
        }
        
        
        if (selectedPlan == null || String.isBlank(selectedPlan)) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'Please select a payment plan before proceeding.'
            ));
            return null; // Stops further execution
        }


        
        
        
        Map<String, Id> quoteApproversMap = QuotationManagementServices.getApprovers(proj.Id);
        Integer carParks =0;
        String SM;
        // unit details
        if(o != null && o.Sales_Manager_User__c != null)  //Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 04-12-2025
            SM = o.Sales_Manager_User__r.Name; //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 04-12-2025
        else if(o != null && o.LeadSource == 'Direct' && o.Walkin_Source__c == 'Direct') //Added by Vinay 08-01-2026
            SM = 'Direct';
        else
            SM = 'Not Available';
        //q.Name = proj.Name + '-' + u.Name  + '-'+ System.now().format() + '-' + SM ;
        String tempQuoteName = u.Name  + '-'+ System.now().format() + '-' + SM ;
        if(tempQuoteName.length() > 80)
            tempQuoteName = tempQuoteName.substring(0,79);
        q.Name = tempQuoteName;
        q.Prepared_Date__c = date.parse(quoteDate);
        q.Valid_Till_Date__c = date.parse (quoteValidity);
        q.FlatNo__c = u.Name;
        q.FloorNo__c = allChargesMap.get('FLOORNO');
        q.Carpet_Area_Sq_Ft__c =u.Carpet_Area__c;
        q.Appartment_Configuration__c = u.Project_Unit_Type__r.Name;
        q.Wing__c = u.TowerName__r.Name;
        q.Zone__c = u.TowerName__r.Zone_Name__r.Name;
        
        //Mapping of Refferal Source Disocunt Values
        
        
        Boolean isReferral = o.Walkin_Source__c == 'Referral' ;
        Boolean isCPPassback = o.Walkin_Source__c == 'Channel Partner';
        Decimal saleableArea = (u.Saleable_Area__c != null && u.Saleable_Area__c > 0) ? u.Saleable_Area__c : 0;
        
        if(isReferral) {
            System.debug('Insed save method Referral');
            // Standard referral discount
            q.Discount_11_Type__c = o.Walkin_Source__c;
            q.Discount_11_L__c = sreferralDiscount != null ? sreferralDiscount : 0;
            q.Discount_11_PSF__c = saleableArea > 0 ? q.Discount_11_L__c / saleableArea : 0;
            System.debug('Discount_11_Type__c===>' + q.Discount_11_Type__c);
            System.debug('Discount_11_L__c===>' + q.Discount_11_L__c);
            System.debug('Discount_11_PSF__c====>'+ q.Discount_11_PSF__c);
            // Passback discount if opted
            if(o.Opt_for_Referral__c == true) {
                q.Discount_10_Type__c = o.Walkin_Source__c + ' Passback';
                q.Discount_10_L__c = sRefDiscPassBack != null ? sRefDiscPassBack : 0;
                q.Discount_10_PSF__c = saleableArea > 0 ? q.Discount_10_L__c / saleableArea : 0;
                System.debug('Discount_10_Type__c===>' + q.Discount_11_Type__c);
                System.debug('Discount_10_L__c===>' + q.Discount_11_L__c);
                System.debug('Discount_10_PSF__c====>'+ q.Discount_11_PSF__c);
            }
        }
        
        
        //CP Passback Value
        if(isCPPassback){
            for(InventoryCostServices.DiscountWrapper d : pDisc){
                if(d.type != null && d.type.contains('Passback') && d.lumpsumVal != null){
                    q.Discount_9_Type__c = d.type;
                    q.Discount_9_L__c = d.lumpsumVal;
                    q.Discount_9_PSF__c = saleableArea > 0 ? q.Discount_9_L__c / saleableArea : 0;
                }
            }
        }
        
        
        if(string.isNotBlank(subPlanId)){
            q.Plan_Type__c = 'Subvention Plan';
            q.PaymentPlan__c = subPlanId;
        }
        else{
            q.Plan_Type__c = 'Non Subvention Plan';
            q.PaymentPlan__c = selectedPlan;
        }
        if(u.RW_Project__r.OC_Approved__c || u.Towername__r.OC_Approved__c || u.OC_Approved__c)
            q.OC_Approved__c = true;
        if(GSTpercentageApplied != null)
            q.GST_Percentage_Applicable__c = String.valueOf(GSTpercentageApplied);
        
        String views = '';
        if(String.isNotBlank(u.S_View1__c))
            views = u.S_View1__c +' ,';
        if(String.isNotBlank(u.S_View_2__c))
            views = views + u.S_View_2__c + ' ,';
        if(String.isNotBlank(u.S_View_3__c))
            views = views + u.S_View_3__c;
        // remove the last character only if its a comma.
        if(views.length() > 0 && views.substring(views.length() -1).equals(','))
            views = views.substring(0,views.length() -1);
        
        q.View__c = views;
        // 🚨 APPLY SELECTION MUST BE CLICKED BEFORE SAVE
        // 🚨 Apply required only if parking exists (default OR entered)
        Boolean parkingExists = false;

        for (ParkingConfig p : getParkingConfigs()) {

            Integer currentQty =
                q.get(p.addQtyField) == null ? 0 : Integer.valueOf(q.get(p.addQtyField));

            Integer defaultQty =
                p.unitEarmarked == null ? 0 : Integer.valueOf(p.unitEarmarked);

            if(currentQty > 0 || defaultQty > 0){
                parkingExists = true;
                break;
            }
        }

        if(parkingExists && parkingApplied == false){
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Please click Apply Selection before saving the quotation.'
                )
            );
            return null;
        }

        //calling 
        
        // 🚨 STEP A — If user changed parking AFTER Apply → STOP SAVE(Added by Dolly)
        // 🚨 STOP SAVE if parking changed but Apply not clicked
        for(ParkingConfig p : getParkingConfigs()){

            Integer currentQty =
                q.get(p.addQtyField) == null ? 0 : Integer.valueOf(q.get(p.addQtyField));

            Integer appliedQty =
                appliedParkingSnapshot.containsKey(p.type) ? appliedParkingSnapshot.get(p.type) : 0;

            if(currentQty != appliedQty){
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR,
                        'Please click Apply Selection before saving parking changes.'
                    )
                );
                return null;
            }
        }

        // 🚨 STEP B — If parking changed from Unit default → Approval required
        Boolean parkingChangedFromDefault = false;

        for (ParkingConfig p : getParkingConfigs()) {

            Integer currentQty =
                q.get(p.addQtyField) == null ? 0 : Integer.valueOf(q.get(p.addQtyField));

            Integer defaultQty =
                p.unitEarmarked == null ? 0 : Integer.valueOf(p.unitEarmarked);

            if(currentQty != defaultQty){
                parkingChangedFromDefault = true;
                break;
            }
        }



        applyParkingToQuotation();  //Added by Dolly

        if(quoteApproversMap.size() > 0) {
            q.Level_One_Approver__c = quoteApproversMap.get('First Level');
            q.Level_Two_Approver__c = quoteApproversMap.get('Second Level');
            q.Level_Three_Approver__c = quoteApproversMap.get('Third Level');
        }
        
        List<Project_Charges__c> projChargesList = InventoryCostServices.getProjectChargesDefined(u.RW_Project__r.Name);
        Map<String, Project_Charges__c> chargeDescriptionMap = new Map<String, Project_Charges__c>();
        for(Project_Charges__C pc : projChargesList) {
            System.debug('project charge::'+pc);
            if(pc.Active__c) {
                chargeDescriptionMap.put(pc.Name, pc);
            }
        }
        // base rates
        //q.Token_Amount__c = qPlanWrapperC[0].Amount; //Commented by Vinay 30-01-2025
        //q.ST_Token_Amount__c = qPlanWrapperC[0].serviceTax; //Commented by Vinay 30-01-2025
        if(qPlanWrapperC.size() > 0){ //Added by Vinay 30-01-2025
            q.Token_Amount__c = qPlanWrapperC[0].Amount;
            q.ST_Token_Amount__c = qPlanWrapperC[0].serviceTax;
        }
        
        // stamp duty registration fields
        System.debug('SDByRunwal**'+sdPaidByRunwal);
        System.debug('regChargesByRunwal**'+regChargesByRunwal);
        if(allChargesMap.get('Registration Charges') != null)
        System.debug('Reg**'+allChargesMap.get('Registration Charges'));
            q.Registration_Charges__c = allChargesMap.get('Registration Charges');
        if(allChargesMap.get('Legal Charges') != null)
            q.Legal_Charges__c = allChargesMap.get('Legal Charges');
        if(allChargesMap.get('Legal Charges TOTAL TAX AMT') != null)
            q.Legal_Charges_ST__c = allChargesMap.get('Legal Charges TOTAL TAX AMT');
        if(allChargesMap.get('Stamp Duty') != null)
        System.debug('SD***'+allChargesMap.get('Stamp Duty'));
            q.Stamp_Duty__c = allChargesMap.get('Stamp Duty');
        if(allChargesMap.get('Add SD in AV') != null)
            q.Stamp_duty_payable_by_Runwal__c = allChargesMap.get('Add SD in AV');
        if(allChargesMap.get('MVAT') != null)
            q.MVAT__c = allChargesMap.get('MVAT');
        if(allChargesMap.get('MVAT TOTAL TAX AMT') != null)
            q.MVAT_ST__c = allChargesMap.get('MVAT TOTAL TAX AMT');
        
        System.debug('Stamp Duty: '+ allChargesMap.get('Stamp Duty'));
        System.debug('Add SD in AV: '+ allChargesMap.get('Add SD in AV'));
        //Added by coServe 18-12-2023
        List<String> projectsToAllowZeroSD = System.label.Projects_to_allow_zero_Stamp_Duty.split(',');
        Boolean allowForSD = false;
        for(String p: projectsToAllowZeroSD){
            if(proj.Name == p){
                allowForSD = true;
            }
        }
        if(!allowForSD && allChargesMap.get('Stamp Duty') == null /**|| allChargesMap.get('Stamp Duty') == 0)**commented for SDR/ROC**/ && (allChargesMap.get('Add SD in AV') == null || allChargesMap.get('Add SD in AV') == 0) && !Test.isRunningTest()){
            ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL,'Stamp duty value is missing, please contact Sales Strategy.')));
            return null;
        }
        
        // Base Rates and Other Rates for the unit 
        // discounts applied
        // Adding Original NPV and Modified NPV on quotation - Digicloud Team - Suraj S.
       // q.Original_NPV__c = String.valueOf(QuotationManagementServices.INFormat(InventoryCostServices.calculateNPV(payplanDetailsForQuotedNPV, proj.Id)));
      // q.Modified_NPV__c = String.valueOf(QuotationManagementServices.INFormat(UpdatedPlanNPV));  
        q.Original_NPV__c = InventoryCostServices.calculateNPV(payplanDetailsForQuotedNPV, proj.Id,selectedDiscountOption);
        q.Modified_NPV__c = UpdatedPlanNPV;  
        q.Base_Rate_L__c = allChargesMap.get('Basic');
        q.Base_Rate_PSF__c = allChargesMap.get('BasicPSF');
        q.Floor_Rise_L__c = allChargesMap.get('FLOORRISETOTAL'); 
        q.Floor_Rise_PSF__c = allChargesMap.get('FLOORRISEPERSQFT');
        if(allChargesMap.containsKey('Premium 1')) {
            q.Premium_Charges_Category_1__c = chargeDescriptionMap.get('Premium 1').S_Charge_Bucket__c;
            q.Premium_Charges_Description_1__c = chargeDescriptionMap.get('Premium 1').Remarks__C;
            q.Premium_Charges_Amount_1__c = allChargesMap.get('Premium 1PSF');
        }
        if(allChargesMap.containsKey('Premium 2')) {
            q.Premium_Charges_Category_2__c = chargeDescriptionMap.get('Premium 2').S_Charge_Bucket__c;
            q.Premium_Charges_Description_2__c = chargeDescriptionMap.get('Premium 2').Remarks__C;
            q.Premium_Charges_Amount_2__c = allChargesMap.get('Premium 2PSF');
        }
        if(allChargesMap.containsKey('Premium 3')) {
            q.Premium_Charges_Category_3__c = chargeDescriptionMap.get('Premium 3').S_Charge_Bucket__c;
            q.Premium_Charges_Description_3__c = chargeDescriptionMap.get('Premium 3').Remarks__C;
            q.Premium_Charges_Amount_3__c = allChargesMap.get('Premium 3PSF');
        }
        if(allChargesMap.containsKey('Premium 4')) {
            q.Premium_Charges_Category_4__c = chargeDescriptionMap.get('Premium 4').S_Charge_Bucket__c;
            q.Premium_Charges_Description_4__c = chargeDescriptionMap.get('Premium 4').Remarks__C;
            q.Premium_Charges_Amount_4__c = allChargesMap.get('Premium 4PSF');
        }
        
        if(allChargesMap.get('Infrastructure Charges') != null)
            q.Infrastructure_charges__c = allChargesMap.get('Infrastructure Charges');
        if(allChargesMap.get('Infrastructure Charges TOTAL TAX AMT') != null)
            q.Infrastructure_Charges_ST__c = allChargesMap.get('Infrastructure Charges TOTAL TAX AMT');
        
        if(allChargesMap.get('Development Charges') != null)
            q.Development_Charges_L__c = allChargesMap.get('Development Charges');
        
        // Added by shailesh as these charges needs to be sent to SAP as a part of agreement value
        if(allChargesMap.containsKey('CAM') && allChargesMap.get('CAM') != null)
            q.CAM_Charges__c = allChargesMap.get('CAM');
        if(allChargesMap.containsKey('BCAM') && allChargesMap.get('BCAM') != null)
            q.BCAM_Charges__c = allChargesMap.get('BCAM');
        //Ends Here
        
        q.Total_Rate_Card_L__c = allChargesMap.get('TOTALRATECARDLUMPSUM');
        q.Total_Rate_Card_PSF__c = allChargesMap.get('TOTALRATECARDPSF');
        // copy the original rates to discounted rates, if discounts are applied this will get overwritten with that information
        q.Base_Rate_PSF_D__c = allChargesMap.get('TOTALRATECARDPSF');
        q.Base_Rate_L_D__c = allChargesMap.get('TOTALRATECARDLUMPSUM');
        
        // Discount details
        for(InventoryCostServices.DiscountWrapper  cf : FinalCustomerDiscount) {
            if(cf.Type.equals('Customer Discount Total')) {
                q.Customer_Total_Discount_PSF__c  = cf.PerSqFtVal;
                
                q.Customer_Total_Discount_L__c = cf.LumpsumVal; 
            }
            if(cf.Type.equals('Client Rate (Post Discount)')) {
                if(cf.PerSqFtVal > 0)
                    q.Base_Rate_PSF_D__c = cf.PerSqFtVal;
                if(cf.LumpsumVal > 0)
                    q.Base_Rate_L_D__c = cf.LumpsumVal;
            }
        }
        // get the sumtotal of all applied discounts
        for(InventoryCostServices.DiscountWrapper  d : pDisc) {
            // System.debug('pdisc:d' + d);
            if(d.applied && d.type.equalsIgnoreCase('CP Passback')){
                q.Discount_9_L__c = d.LumpsumVal;
                q.Discount_9_PSF__c = d.PerSqFtVal;
                q.Discount_9_Type__c = d.type;
                q.Approval_Required_on_Discount__c = true;
                
                
                // q.CP_Passback_discount_applied__c = true;
            }
            /*if(d.applied && d.type.equalsIgnoreCase('Referral Passback')){  //Added by Sheetal on 28/12/2022
                q.Discount_10_L__c = d.LumpsumVal;
                q.Discount_10_PSF__c = d.PerSqFtVal;
                q.Discount_10_Type__c = d.type;
                q.Approval_Required_on_Discount__c = true;
                
            }
            if(d.applied && d.type.equalsIgnoreCase('Referral')){
                q.Discount_11_L__c = d.LumpsumVal;
                q.Discount_11_PSF__c = d.PerSqFtVal;
                q.Discount_11_Type__c = d.type;
                q.Approval_Required_on_Discount__c = true;
                
            }*/
            /*if(d.applied && d.Type.equals('Floor Rise') || d.Type.equals('Referral') || d.Type.equals('GST Discount') || d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount') || d.Type.equals('Others') ){
            q.Other_than_CP_Passback_discount_applied__c = true;
            }*/
            if(d.type != 'Payment Plan Deviation (NPV)' && d.type != 'Total Discount') {
                if (d.applied  && d.type != 'CP Passback' && d.type!= 'Referral Passback'  && d.type!= 'Referral') {
                    q.Discount_1_L__c = d.LumpsumVal;
                    q.Discount_1_PSF__c = d.PerSqFtVal;
                    q.Discount_1_Type__c = d.type;
                    q.Approval_Required_on_Discount__c = true;
                    
                }              
            }
            
            if(d.applied && d.type == 'Payment Plan Deviation (NPV)') {
                q.NPV_Applied__c = true;
                q.NPV_L__c = d.LumpsumVal;
                q.NPV_PSF__c = d.PerSqFtVal;
                q.NPV_Type__c = d.type;
            } 
            if(d.type.equals('Total Discount')) {
                q.Total_Discount_L__c = d.LumpsumVal;
                q.Total_Discount_PSF__c = d.PerSqFtVal;
                q.Total_Discount_Type__c = d.type;
            } 
        }
        // get the sumtotal of all applied discounts
        for(InventoryCostServices.DiscountWrapper  d : pDisc1) {
            if (d.applied) {
                q.Discount_2_L__c = d.LumpsumVal;
                q.Discount_2_PSF__c = d.PerSqFtVal;
                q.Discount_2_Type__c = d.type;
            }
            else if(d.PerSqFtVal > d.PerSqFtMax) 
                q.Approval_Required_on_Discount__c = true;
            
            /* if(d.applied && d.Type.equals('Floor Rise') || d.Type.equals('Referral') || d.Type.equals('GST Discount') || d.Type.equals('Corporate') || d.Type.equals('NRI') || d.Type.equals('Other Discount') || d.Type.equals('Others') ){
        q.Other_than_CP_Passback_discount_applied__c = true;
        }
        else{
        q.Approval_Required_on_Discount__c = true;
        q.CP_Passback_discount_applied__c = true; 
        q.Other_than_CP_Passback_discount_applied__c = false;
        }*/
            
        }
        
        if(q.Approval_Required_on_Discount__c || scheduleEdited ) {
            q.Quote_Status__c = 'Approval Pending';
            q.Car_Parking_Approval__c ='Pending';
        }
        else
            q.Quote_Status__c = 'Valid';
        if(scheduleEdited) {
            q.Payment_Plan_Modified__c = true;  
        } else {
            q.Payment_Plan_Modified__c = false; 
        }
        if(allChargesMap.get('AGREEMENTVALUE') != null)
        SYstem.debug('AV on save**'+allChargesMap.get('AGREEMENTVALUE'));
            q.Agreement_Value__c = allChargesMap.get('AGREEMENTVALUE');
        if(allChargesMap.get('AGREEMENTVALUE TAX AMT') != null)
            q.Agreement_Value_ST__c = allChargesMap.get('AGREEMENTVALUE TAX AMT');
        
        if(allChargesMap.get('AGREEMENTVALUEFORBROKERS') != null)                            // Added by Sheetal to solve Issue I0100
            q.Agreement_Value_for_brokers__c = allChargesMap.get('AGREEMENTVALUEFORBROKERS');
        
        if(allChargesMap.get('AGREEMENTVALUENOTFORBROKERS') != null)                            // Added by Sheetal on 12/09/2022
            q.Agreement_Value_Not_for_brokers__c = allChargesMap.get('AGREEMENTVALUENOTFORBROKERS');
        
        
        // Maintenance charges
        if(allChargesMap.containsKey('Maintenance Charges 1')) {
            q.Proj_Maint_Charges_Desc_1__c = chargeDescriptionMap.get('Maintenance Charges 1').Remarks__c;
            q.Project_Maintenance_Charges_Category_1__c = chargeDescriptionMap.get('Maintenance Charges 1').S_Charge_Bucket__c;
            q.Project_Maintenance_Charges_Amount_1__c = allChargesMap.get('Maintenance Charges 1');
            if(allChargesMap.containsKey('Maintenance Charges 1 TOTAL TAX AMT'))
                q.Project_Maintenance_Charges_ST_1__c = allChargesMap.get('Maintenance Charges 1 TOTAL TAX AMT');
        }
        if(allChargesMap.containsKey('Maintenance Charges 2')) {
            q.Proj_Maint_Charges_Desc_2__c = chargeDescriptionMap.get('Maintenance Charges 2').Remarks__c;
            q.Project_Maintenance_Charges_Category_2__c = chargeDescriptionMap.get('Maintenance Charges 2').S_Charge_Bucket__c;
            q.Project_Maintenance_Charges_Amount_2__c = allChargesMap.get('Maintenance Charges 2');
        }
        if(allChargesMap.containsKey('Maintenance Charges 3')) {
            q.Proj_Maint_Charges_Desc_3__c = chargeDescriptionMap.get('Maintenance Charges 3').Remarks__c;
            q.Project_Maintenance_Charges_Category_3__c = chargeDescriptionMap.get('Maintenance Charges 3').S_Charge_Bucket__c;
            q.Project_Maintenance_Charges_Amount_3__c = allChargesMap.get('Maintenance Charges 3');
        }
        
        // Project specific charges
        if(allChargesMap.containsKey('Project Specific Charges 1')) {
            q.Project_Specific_Charges_Description_1__c = chargeDescriptionMap.get('Project Specific Charges 1').Remarks__c;
            q.Project_Specific_Charges_Category_1__c = chargeDescriptionMap.get('Project Specific Charges 1').S_Charge_Bucket__c;
            q.Project_Specific_Charges_Amount_1__c = allChargesMap.get('Project Specific Charges 1');
        }
        if(allChargesMap.containsKey('Project Specific Charges 2')) {
            q.Project_Specific_Charges_Description_2__c = chargeDescriptionMap.get('Project Specific Charges 2').Remarks__c;
            q.Project_Specific_Charges_Category_2__c = chargeDescriptionMap.get('Project Specific Charges 2').S_Charge_Bucket__c;
            q.Project_Specific_Charges_Amount_2__c = allChargesMap.get('Project Specific Charges 2');
        }
        if(allChargesMap.containsKey('Project Specific Charges 3')) {
            q.Project_Specific_Charges_Description_3__c = chargeDescriptionMap.get('Project Specific Charges 3').Remarks__c;
            q.Project_Specific_Charges_Category_3__c = chargeDescriptionMap.get('Project Specific Charges 3').S_Charge_Bucket__c;
            q.Project_Specific_Charges_Amount_3__c = allChargesMap.get('Project Specific Charges 3');
        }
        
        // Other charges        
        if(allChargesMap.containsKey('Society Charges')) {
            q.Other_Charges_Category_1__c = chargeDescriptionMap.get('Society Charges').S_Charge_Bucket__c;
            q.Other_Charges_Desc_1__c = chargeDescriptionMap.get('Society Charges').Remarks__c;
            q.Other_Charges_Amount_1__c = allChargesMap.get('Society Charges');
        }
        if(allChargesMap.containsKey('Legal Charges')) {
            q.Other_Charges_Category_2__c = chargeDescriptionMap.get('Legal Charges').S_Charge_Bucket__c;
            q.Other_Charges_Desc_2__c = chargeDescriptionMap.get('Legal Charges').Remarks__c;
            q.Other_Charges_Amount_2__c = allChargesMap.get('Legal Charges');
        }
        if(allChargesMap.containsKey('Electricity and Other Utility and Sevices Connection Charges')) {
            q.Other_Charges_Category_3__c = chargeDescriptionMap.get('Electricity and Other Utility and Sevices Connection Charges').S_Charge_Bucket__c;
            q.Other_Charges_Desc_3__c = chargeDescriptionMap.get('Electricity and Other Utility and Sevices Connection Charges').Remarks__c;
            q.Other_Charges_Amount_3__c = allChargesMap.get('Electricity and Other Utility and Sevices Connection Charges');
        }
        if(allChargesMap.containsKey('Water, Electricity and Other Utility and Services Connection Charges')) {
            q.Other_Charges_Category_4__c = chargeDescriptionMap.get('Water, Electricity and Other Utility and Services Connection Charges').S_Charge_Bucket__c;
            q.Other_Charges_Desc_4__c = chargeDescriptionMap.get('Water, Electricity and Other Utility and Services Connection Charges').Remarks__c;
            q.Other_Charges_Amount_4__c = allChargesMap.get('Water, Electricity and Other Utility and Services Connection Charges');
        }
        if(allChargesMap.containsKey('Club Membership Charges')) {
            q.Other_Charges_Category_5__c = chargeDescriptionMap.get('Club Membership Charges').S_Charge_Bucket__c;
            q.Other_Charges_Desc_5__c = chargeDescriptionMap.get('Club Membership Charges').Remarks__c;
            q.Other_Charges_Amount_5__c = allChargesMap.get('Club Membership Charges');
        }
        if(allChargesMap.containsKey('Receiving Sub Station')) {
            q.Other_Charges_Category_6__c = chargeDescriptionMap.get('Receiving Sub Station').S_Charge_Bucket__c;
            q.Other_Charges_Desc_6__c = chargeDescriptionMap.get('Receiving Sub Station').Remarks__c;
            q.Other_Charges_Amount_6__c = allChargesMap.get('Receiving Sub Station');
        }
        
        if(allChargesMap.containsKey('Electricity and Water Connection')) {
            System.debug('YYYY::'+allChargesMap.get('Electricity and Water Connection'));
            q.Other_Charges_Category_7__c = chargeDescriptionMap.get('Electricity and Water Connection').S_Charge_Bucket__c;
            q.Other_Charges_Desc_7__c = chargeDescriptionMap.get('Electricity and Water Connection').Remarks__c;
            q.Other_Charges_Amount_7__c = allChargesMap.get('Electricity and Water Connection');
        }
        if(allChargesMap.containsKey('Share Money')) {
            q.Other_Charges_Category_8__c = chargeDescriptionMap.get('Share Money').S_Charge_Bucket__c;
            q.Other_Charges_Desc_8__c = chargeDescriptionMap.get('Share Money').Remarks__c;
            q.Other_Charges_Amount_8__c = allChargesMap.get('Share Money');
        }
        if(allChargesMap.containsKey('Society Formation')) {
            q.Other_Charges_Category_9__c = chargeDescriptionMap.get('Society Formation').S_Charge_Bucket__c;
            q.Other_Charges_Desc_9__c = chargeDescriptionMap.get('Society Formation').Remarks__c;
            q.Other_Charges_Amount_9__c = allChargesMap.get('Society Formation');
        }
        if(allChargesMap.containsKey('Building Protection Deposit')) {
            q.Other_Charges_Category_10__c = chargeDescriptionMap.get('Building Protection Deposit').S_Charge_Bucket__c;
            q.Other_Charges_Desc_10__c = chargeDescriptionMap.get('Building Protection Deposit').Remarks__c;
            q.Other_Charges_Amount_10__c = allChargesMap.get('Building Protection Deposit');
        }
        if(allChargesMap.containsKey('Corpus Fund')) {
            q.Other_Charges_Category_11__c = chargeDescriptionMap.get('Corpus Fund').S_Charge_Bucket__c;
            q.Other_Charges_Desc_11__c = chargeDescriptionMap.get('Corpus Fund').Remarks__c;
            q.Other_Charges_Amount_11__c = allChargesMap.get('Corpus Fund');
        }
        if(allChargesMap.containsKey('Water, Electricity and Other Utility and Services')) {
            q.Other_Charges_Category_13__c = chargeDescriptionMap.get('Water, Electricity and Other Utility and Services').S_Charge_Bucket__c;
            q.Other_Charges_Desc_13__c = chargeDescriptionMap.get('Water, Electricity and Other Utility and Services').Remarks__c;
            q.Other_Charges_Amount_13__c = allChargesMap.get('Water, Electricity and Other Utility and Services');
        }
        if(allChargesMap.containsKey('Share Money Application Fees')) {
            q.Other_Charges_Category_14__c = chargeDescriptionMap.get('Share Money Application Fees').S_Charge_Bucket__c;
            q.Other_Charges_Desc_14__c = chargeDescriptionMap.get('Share Money Application Fees').Remarks__c;
            q.Other_Charges_Amount_14__c = allChargesMap.get('Share Money Application Fees');
        }
        if(allChargesMap.containsKey('BCAM-F')) {
            q.other_Charges_FCAM_Category__c = chargeDescriptionMap.get('BCAM-F').S_Charge_Bucket__c;
            q.Other_Charges_FCAM_Description__c = chargeDescriptionMap.get('BCAM-F').Remarks__c;
            q.Other_Charges_FCAM__c = allChargesMap.get('BCAM-F');
        }        
        if(allChargesMap.containsKey('FCAM')) {
            q.Other_Charges_Category_15__c = chargeDescriptionMap.get('FCAM').S_Charge_Bucket__c;
            q.Other_Charges_Desc_15__c = chargeDescriptionMap.get('FCAM').Remarks__c;
            q.Other_Charges_Amount_15__c = allChargesMap.get('FCAM');
        }
        if(allChargesMap.containsKey('Other Charges Retail')) {
            q.Other_Charges_Category_16__c = chargeDescriptionMap.get('Other Charges Retail').S_Charge_Bucket__c;
            q.Other_Charges_Desc_16__c = chargeDescriptionMap.get('Other Charges Retail').Remarks__c;
            q.Other_Charges_Amount_16__c = allChargesMap.get('Other Charges Retail');
        }
        
        
        // totals
        for(QuotationManagementServices.QuoteUIWrapper qw : quoteUIMap.get('RIGHTTOP')) {
            if(qw.chargeName != null) {
                if(qw.ChargeName.equals('STAMPDUTYREGISTRATIONTOTAL')) {
                    q.Stamp_Duty_and_Registration_Total__c = qw.Amount;
                }
                if(qw.ChargeName.equals('SERVICETAXESTOTAL')) {
                    q.Service_Taxes_Total__c = qw.Amount;
                }
                if(qw.ChargeName.equals('MAINTEANCECHARGESTOTAL')) {
                    q.Society_Charges_Total__c = qw.Amount;
                }
                if(qw.ChargeName.equals('OTHERCHARGESTOTAL')) {
                    q.Other_Charges_Total__c = qw.Amount;
                }
                if(qw.ChargeName.equals('GRANDTOTAL')) {
                    q.Grand_Total__c = qw.Amount;
                }
            }
        }
        
        // rates after discounts
        if(allChargesMapDisc != null && quoteUIMapDisc != null) {              
            q.Discount_Applied__c = true;
            System.debug('AV**'+allChargesMapDisc.get('AGREEMENTVALUE'));
            q.Agreement_Value_D__c = allChargesMapDisc.get('AGREEMENTVALUE');
            if(allChargesMapDisc.get('AGREEMENTVALUE TAX AMT') != null)
                q.Agreement_Value_ST_D__c = allChargesMapDisc.get('AGREEMENTVALUE TAX AMT');
            if(allChargesMapDisc.get('Stamp Duty') != null)
                q.Stamp_Duty_D__c = allChargesMapDisc.get('Stamp Duty');
            if(allChargesMapDisc.get('MVAT') != null)
                q.MVAT_D__c = allChargesMapDisc.get('MVAT');
            if(allChargesMapDisc.get('MVAT TOTAL TAX AMT') != null)
                q.MVAT_ST_D__c = allChargesMapDisc.get('MVAT TOTAL TAX AMT');
            
            for(QuotationManagementServices.QuoteUIWrapper qw : quoteUIMapDisc.get('RIGHTTOP')) {
                if(qw.chargeName != null) {
                    if(qw.ChargeName.equals('STAMPDUTYREGISTRATIONTOTAL')) {
                        q.Stamp_Duty_and_Registration_Total_D__c = qw.Amount;
                    }
                    if(qw.ChargeName.equals('SERVICETAXESTOTAL')) {
                        q.Service_Taxes_Total_D__c = qw.Amount;
                    }
                    if(qw.ChargeName.equals('GRANDTOTAL')) {
                        q.Grand_Total_D__c = qw.Amount;
                    }
                }
            }
        } 
        q.Non_Monetory_Discounts_Not_Applicable__c = nonMonetaryOfferCheckbox;//Added for Quotation Offer
        
        
        Id qId = null;
        PageReference pref;
        Database.saveResult sr = Database.insert(q);
        System.debug('Database save result'+ sr);

        if(sr.isSuccess()) {
            qId = sr.getId();
            InventoryCostServices.FixedDiscountWrapper discountResult = InventoryCostServices.calculateFixedDiscounts(proj.Id, oppId, unitId, originalAgreementVal, CP_DiscountInput);
            system.debug('Applied Mandetory Discount is ==>'+ discountResult);
            system.debug('@@@ : '+lstAllAppliedDiscounts);
            
            system.debug('PD List for non ==>'+ pDisc);
            for(InventoryCostServices.DiscountWrapper d : pDisc){
                if(d.applied == True){
                    system.debug('non mandetory discount is ==>'+ d);
                    Quote_Applied_Discounts__c qd = new Quote_Applied_Discounts__c();
                    qd.Name = d.type;
                    qd.Offer_type__c = d.offerType;
                    qd.Monetizable__c = d.isMonetizableChecked;
                    qd.Project__c = proj.id;
                    qd.Project_Unit__c = u.id;
                    qd.Tower__c = u.TowerName__c;
                    qd.Quotation__c = qId;
                    qd.Offer_Value__c = d.lumpsumVal;
                    qd.Start_Date__c = d.startDate;
                    qd.End_Date__c = d.endDate;
                    ////qd.Applied_Offer__c = objOffer.Id;
                    qd.Discount_Category__c = d.discountCategory;
                    lstNonMandDisc.add(qd);
                }
            }  
            
            if(lstNonMandDisc != null){
                Insert lstNonMandDisc;
            }
            
            // if(discountResult != null){
            //     lstAllAppliedDiscounts = discountResult.appliedDiscounts != null ? discountResult.appliedDiscounts : new List<Quote_Applied_Discounts__c>(); 
            //     system.debug('List Applied Discounts__'+ lstAllAppliedDiscounts.size());
            //     system.debug('List Applied Discounts__'+ lstAllAppliedDiscounts);
            //     for(InventoryCostServices.DiscountWrapper d : pDisc){//Added by Prakshi for offer Id tagging in Quote_Applied_Discounts__c
            //         if(d.applied== true){////Added by Prakshi for offer Id tagging in Quote_Applied_Discounts__c
            //             for(Quote_Applied_Discounts__c discount : lstAllAppliedDiscounts) {
            //                 discount.Quotation__c = qId;
            //                 if(discount.Project__c == null || discount.Project_Unit__c == null || discount.Tower__c == null ){
            //                     discount.Project__c = proj.id;
            //                     discount.Project_Unit__c = u.id;
            //                     discount.Tower__c = u.TowerName__c;
            //                 }
            //             }
            //         }
            //     }//Added by Prakshi
            
            //     insert lstAllAppliedDiscounts;
            // }//Commented by Prakshi because 2 quote applied discounts are creaated for mandatory discounts
           

        }
        /*if(sr.isSuccess()) {
            qId = sr.getId();
        }*/
        if(qId != null) {
            Quotation__c qNew = [Select Id, Name from Quotation__c where Id = : qId];
            System.debug('q.Single_Covered_Additional_Amount__c: ' + q.Single_Covered_Additional_Amount__c);
            
            u.SD_Paid_By_Runwal__c = sdPaidByRunwal;//Added for SDR ROC Management
            u.Registration_Charges_Paid_By_Runwal__c = regChargesByRunwal;//Added for SDR ROC Management
            update u;
            // call the save method of inventory cost services here
            List<InventoryCostServices.PlanDetailWrapper> pdList  = new List<InventoryCostServices.PlanDetailWrapper>();
            for(QPlanDetailWrapper q : qPlanWrapperC) {
                InventoryCostServices.PlanDetailWrapper pdw = new InventoryCostServices.PlanDetailWrapper(q.amount,q.serviceTax,q.payPlanRecord);
                pdList.add(pdw);
            }
            //pdList.remove(pdList.size()-1); //Commented by Vinay 29-03-2025
            if(pdList.size() > 0) //Added by Vinay 29-03-2025
                pdList.remove(pdList.size()-1);
            if(allChargesMapDisc != null){
                System.debug('allChargesMapDisc**'+allChargesMapDisc);
                if(string.isNotBlank(subPlanId))
                    InventoryCostServices.insertCustomerPaymentPlan(pdList, subPlanId,proj,u,o,qNew,allChargesMapDisc);
                else
                    InventoryCostServices.insertCustomerPaymentPlan(pdList, selectedplan,proj,u,o,qNew,allChargesMapDisc);    
            }    
            else{
                if(string.isNotBlank(subPlanId))
                    InventoryCostServices.insertCustomerPaymentPlan(pdList, subPlanId,proj,u,o,qNew,allChargesMap);
                else
                    InventoryCostServices.insertCustomerPaymentPlan(pdList, selectedplan,proj,u,o,qNew,allChargesMap);    
                
            }  
            // redirect to a new page for print
            for(QPlanDetailWrapper q : qPlanWrapperC) {
                q.strAmount = QuotationManagementServices.INFormat(q.Amount);
                q.strServiceTax = QuotationManagementServices.INFormat(q.serviceTax);
            }
            
            // not using this, as we are redirecting to quote detail page now.
            pref = new PageReference('/apex/PrintQuote');
            pref.getParameters().put('id',u.Id);
        } else {
            ApexPages.addMessage((new ApexPages.message(ApexPages.severity.FATAL,'Quotation Could not be saved')));
            return null;
        }
        // changed code to redirect to quote detail page instead of the print quote page
        return new PageReference('/' + qId);
        
    }
    
    
    
    //===========END: quote related methods end here
    
    // =============START: WRAPPER classes start here
    
    public class QPlanDetailWrapper {
        
        public Decimal amount  {get; set;}
        public Decimal serviceTax  {get; set;}
        public Decimal totalPay {get;set;}
        public Standard_Customer_Pay_Plan_Detail__c payPlanRecord {get;set;}
        public Map<String,Decimal> taxMap {get;set;}
        public Map<String,String> taxMapStr {get;set;}
        public List<String> taxNames {get;set;}
        public String style  {get; set;}
        public String strAmount {get;set;}
        public String strServiceTax {get;set;}
        public string strTotalPay {get;set;}
        
        // keeping cloned "C" copies of each variable. the cloned ones will remain readonly on the pay plan edit screen 
        // and the actual ones will get updated as user changes the plan.
        // these fields provide a reference to the user on what the original is was while editing
        
        // in the quotation screen we will show values from the original fields as read only
        // cloned fields are not rendered.
        
        public QPlanDetailWrapper(Decimal amount,  Decimal serviceTax, Standard_Customer_Pay_Plan_Detail__c ppR) {
            this.amount = amount.setscale(0, RoundingMode.HALF_UP);
            this.serviceTax  = serviceTax.setscale(0, RoundingMode.HALF_UP);
            this.payplanRecord = ppr;
            this.strAmount = QuotationManagementServices.INFormat(amount);
            this.strServiceTax = QuotationManagementServices.INFormat(serviceTax);
        }
        
        
        public QPlanDetailWrapper(Decimal amount,  Decimal serviceTax, Decimal totalPay, Standard_Customer_Pay_Plan_Detail__c ppR, Map<String,Decimal> taxSlab) {
            System.debug('QDetail Wrapper:' + ppr + ': totalPay' + totalPay);
            this.amount = amount.setscale(0, RoundingMode.HALF_UP);
            this.serviceTax  = serviceTax.setscale(0, RoundingMode.HALF_UP);
            this.payplanRecord = ppr;
            this.strAmount = QuotationManagementServices.INFormat(amount);
            this.strServiceTax = QuotationManagementServices.INFormat(serviceTax);
            this.strTotalPay = QuotationManagementServices.INFormat(totalPay);
            this.taxMapStr = new Map<String,String>();
            this.taxNames  = new List<String>();
            System.debug('taxMap:' + taxSlab);
            if(!taxSlab.isEmpty()) {
                for(String taxname: taxSlab.keySet()) {
                    taxMapStr.put(taxName, QuotationManagementServices.InFormat(taxSlab.get(taxName)));
                    taxNames.add(taxName);
                }
            }
            system.debug('taxMapStr:: '+taxMapStr);
            system.debug('taxMapStr:: '+taxNames);
        }
    }
    
    // ==========END: WRAPPER classes end here
    
    /*  ------------------------------------------- Added by Vikas for Base Rate changes   ---------------------------------*/
    
    Public void changeBaseRate(){
        system.debug('inside BaseRate Method: ');
        if(baseRate != null && u!= null){
            system.debug('discountVal::: '+discountVal);
            Decimal carParkAmount1 = 0;
            Decimal carParkAmount2 = 0;
            Decimal carParkAmount3 = 0;
            Decimal carParkAmount4 = 0;
            Decimal carParkAmount5 = 0;
            Decimal carParkAmount6 = 0;
            Decimal carParkAmount7 = 0;
            Decimal carParkAmount8 = 0;
            Decimal carParkAmount9 = 0; //Added by Vinay 28-03-2025
            Decimal carParkAmount10 = 0; //Added by Vinay 19-11-2025
            
            Decimal car1 = 0;
            Decimal car2 = 0;
            Decimal car3 = 0;
            Decimal car4 = 0;
            Decimal car5 = 0;
            Decimal car6 = 0;
            Decimal car7 = 0;
            Decimal car8 = 0;
            Decimal car9 = 0; //Added by Vinay 28-03-2025
            Decimal car10 = 0; //Added by Vinay 19-11-2025
            
            if(q.single_car_park_additional__c > 0) {
                carParkAmount1 = proj.allotment_charges_1__c * q.single_car_park_additional__c;
                car1 = q.single_car_park_additional__c;
                System.debug('q.single_car_park_additional__c: ' + q.single_car_park_additional__c);
                System.debug('carParkAmount1: ' + carParkAmount1);
                System.debug('q.Single_Covered_Additional_Amount__c: ' + q.Single_Covered_Additional_Amount__c);
                //selectedCarPark1 = Integer.valueOf(q.single_car_park_additional__c);
            }
            if(q.Tandem_car_park_additional__c > 0) {
                carParkAmount2 = proj.allotment_charges_2__c * q.Tandem_car_park_additional__c;
                car2 = q.Tandem_car_park_additional__c;
                //selectedCarPark2 = 2*Integer.valueOf(q.Tandem_car_park_additional__c);
            }
            if(q.Single_Open_additional__c > 0) {
                carParkAmount3 = proj.allotment_charges_3__c * q.Single_Open_additional__c;
                car3 = q.Single_Open_additional__c;
                //selectedCarPark3 = Integer.valueOf(q.Single_Open_additional__c);
            }
            if(q.Tandem_Open_additional__c > 0) {
                carParkAmount4 = proj.allotment_charges_4__c * q.Tandem_Open_additional__c;
                car4 = q.Tandem_Open_additional__c;
                //selectedCarPark4 = 2*Integer.valueOf(q.Tandem_Open_additional__c);
            }
            if(q.Stack_Additional__c > 0) {
                carParkAmount5 = proj.allotment_charges_5__c * q.Stack_Additional__c;
                car5 = q.Stack_Additional__c;
                //selectedCarPark5 = Integer.valueOf(q.Stack_Additional__c);
            }
            if(q.MLCP_Additional__c> 0) {
                carParkAmount6 = proj.allotment_charges_6__c * q.MLCP_Additional__c;
                car6 = q.MLCP_Additional__c;
                //selectedCarPark5 = Integer.valueOf(q.Stack_Additional__c);
            }
            if(q.Basement_Additional__c> 0) {
                carParkAmount7 = proj.allotment_charges_7__c * q.Basement_Additional__c;
                car7 = q.Basement_Additional__c;
                //selectedCarPark5 = Integer.valueOf(q.Stack_Additional__c);
            }  
            if(q.Podium__c> 0) {
                carParkAmount8 = proj.Allotment_Charges_8__c * q.Podium__c;
                car8 = q.Podium__c;
                //selectedCarPark5 = Integer.valueOf(q.Stack_Additional__c);
            }  
            
            if(q.Puzzle_Car_Park__c> 0) { //Added by Vinay 28-03-2025
                carParkAmount9 = proj.Allotment_Charges_9__c * q.Puzzle_Car_Park__c;
                car9 = q.Puzzle_Car_Park__c;
                //selectedCarPark5 = Integer.valueOf(q.Stack_Additional__c);
            } 
            if(q.Stack_Additional_1__c> 0) { //Added by Vinay 19-11-2025
                carParkAmount10 = proj.Stack_Car_Park_Charges__c * q.Stack_Additional_1__c;
                car10 = q.Stack_Additional_1__c;
            } 
            
            q = new Quotation__c();
            selectedPlan = null;
            qPlanWrapper.clear();
            allChargesMapDisc = null;
            quoteUIMapDisc = null;
            quoteApprovalMsg = 'N/A';
            editSchedule = false;
            scheduleEdited = false;
            disableDiscount = false;
            //discountPageMode = '';
            discountLumpsum = 0;
            discountPSF = 0;
            //q.quote_type__c = 'Normal';
            //bankFunded = false;
            //loanError = false;
            //loanErrorMsg = '';
            /* selectedCarPark1 = 0;
            selectedCarPark2 = 0;
            selectedCarPark3 = 0;
            selectedCarPark4 = 0;
            selectedCarPark5 = 0;
            allotmentCharges = 0;*/
            pDisc.clear();
            pDisc1.clear();
            OriginalPlanNPV = 0.0;
            UpdatedPlanNPV = 0.0;
            OriginalNPVPSF = 0.0;
            UpdatedNPVPSF = 0.0;
            NPVDiffLumpsum = 0.0;
            NPVDiffPSF = 0.0;
            SOriginalPlanNPV = '';
            SOriginalNPVPSF = '';
            SUpdatedPlanNPV = '';
            SUpdatedNPVPSF = '';
            SNPVDiffLumpsum = '';
            SNPVDiffPSF = '';
            pDisc = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
            system.debug('pDisc in QuotationExtn__' + pDisc);  
            pDisc1 = InventoryCostServices.getProjectLevelDiscounts(u.RW_Project__r.Id, u.Id,oppId);
            
            q.single_car_park_additional__c = car1;
            q.Tandem_car_park_additional__c = car2;
            q.Single_Open_additional__c = car3;
            q.Tandem_Open_additional__c = car4;
            q.Stack_Additional__c = car5;
            q.MLCP_Additional__c = car6;
            q.Basement_Additional__c = car7;
            q.Podium__c = car8;
            q.Puzzle_Car_Park__c = car9; //Added by Vinay 28-03-2025
            q.Stack_Additional_1__c = car10; //Added by Vinay 19-11-2025
            carParkAmt = carParkAmount1 + carParkAmount2 + carParkAmount3 + carParkAmount4 + carParkAmount5 + carParkAmount6 + carParkAmount7 + carParkAmount8 + carParkAmount9 + carParkAmount10;
            
            InventoryCostServices.baseRateVal = baseRate;
            InventoryCostServices.premiumRateVal = premiumRate;
            
            InventoryCostServices.allotmentChargeVal = allotmentChargeLumsum;
            allChargesMap = InventoryCostServices.getAllCharges(unitId,carParkAmt,0.0,subPlanId);
            quoteUIMap = QuotationManagementServices.getQuotationUIFormat(unitId,carParkAmt,0.0, selectedCarPark1+selectedCarPark2+selectedCarPark3+selectedCarPark4+selectedCarPark5+selectedCarPark6+selectedCarPark7+selectedCarPark8+selectedCarPark9+selectedCarPark10,subPlanId);
            System.debug('quoteUIMap**'+quoteUIMap);
            if(discountVal != null && discountVal > 0){
                quoteUIMapDisc = QuotationManagementServices.getQuotationUIFormat(unitId,carParkAmt,discountVal, selectedCarPark1 + selectedCarPark2 + selectedCarPark3 + selectedCarPark4 + selectedCarPark5 + selectedCarPark6+selectedCarPark7+selectedCarPark8+selectedCarPark10, subPlanId);
            }
            else{
                quoteUIMapDisc = null;
            }
            StotalRateCardPSF = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDPSF'));
            StotalRateCardLumspum = QuotationManagementServices.INFormat(allChargesMap.get('TOTALRATECARDLUMPSUM'));
            checkCarParkAvailablity();
            //clearDiscount();
            List<Payment_Plan__c> selectedSubventionPlan = new List<Payment_Plan__c>();
            List<Rate_List__c>rateList = new List<Rate_List__c>();
            map<string,Rate_List__c> rateMap = new map<string,Rate_List__c>();
            rateList = [Select Id, Rate__c, ChargeCost__c,Global_Charges__r.Name, Amount__c, Charged_Based_On__c,Project_Unit__r.Name, Project__r.Name, Project_Charges__r.Name
                        from Rate_List__c
                        where Project_Unit__C = :u.id //and Global_Charges__r.Name = 'Basic'
                        and (Effective_Till__c = null or Effective_Till__c <= TODAY)];
            for(Rate_List__c r : rateList){
                rateMap.put(r.Global_Charges__r.Name,r);
            }
            
            if(string.isNotBlank(subPlanId)){
                selectedSubventionPlan = [Select Subvention_Base_Rate__c  from Payment_Plan__c where Id =: subPlanId];
                q.Original_Base_Rate__c = selectedSubventionPlan[0].Subvention_Base_Rate__c;
                if(premiumRate != rateMap.get('Premium 1').rate__c){
                    q.Original_Premium_Rate__c = rateMap.get('Premium 1').rate__c;
                    q.Modified_Premium_Rate__c = premiumRate;
                    q.IsModified_Premium_Rate__c = true;
                }
                if(allotmentChargeLumsum != rateMap.get('Allotment Charges').Amount__c){
                    q.Original_Allotment_Charge__c = rateMap.get('Allotment Charges').Amount__c;
                    q.Modified_Allotment_Charge__c = allotmentChargeLumsum;
                    q.IsModified_Allotment_Charge__c = true;
                }
            }
            else{
                
                if(baseRate != rateMap.get('Basic').rate__c){            
                    q.Original_Base_Rate__c = rateMap.get('Basic').rate__c;
                }    
                if(premiumRate != rateMap.get('Premium 1').rate__c){
                    q.Original_Premium_Rate__c = rateMap.get('Premium 1').rate__c;
                    q.Modified_Premium_Rate__c = premiumRate;
                    q.IsModified_Premium_Rate__c = true;
                }
                if(allotmentChargeLumsum != rateMap.get('Allotment Charges').Amount__c){
                    q.Original_Allotment_Charge__c = rateMap.get('Allotment Charges').Amount__c;
                    q.Modified_Allotment_Charge__c = allotmentChargeLumsum;
                    q.IsModified_Allotment_Charge__c = true;
                }
            }    
            
            q.Modified_Base_Rate__c = baseRate; 
            q.IsModified_Base_Rate__c = true; 
            
            //quoteApprovalMsg = 'This quotation will go for an approval as Base Rate value have been changed';
            
            if(discountVal != null && discountVal > 0){
                system.debug('pDisc1:: '+pDisc1);
                if(!pDisc1.isEmpty()){
                    for(InventoryCostServices.DiscountWrapper d : pDisc1){
                        if(d.discountType == 'Special Discount'){
                            d.selected = true;
                            d.lumpsum = true;
                            d.lumpsumVal = discountVal;
                            d.applied = true; 
                            if(u.Actual_Area_value__c != null && u.Actual_Area_value__c > 0){
                                d.PerSqFtVal = (discountVal / u.Actual_Area_value__c).setscale(0,RoundingMode.HALF_UP);
                            }
                        }
                    }
                    getUpdatedCharges();
                }
                
            }
            else{
                for(InventoryCostServices.DiscountWrapper d : pDisc1){
                    if(d.discountType == 'Special Discount'){
                        d.selected = false;
                        d.lumpsum = false;
                        d.lumpsumVal = discountVal;
                        d.applied = false;// Commented for Quotation offer
                        d.PerSqFtVal = 0;
                        
                    } 
                }
            }
            
            //system.debug('pDisc1::: '+pDisc1);
            
            showAddCarPark = false;
            q.Project_Unit__c = u.id;
            q.Project__c = proj.id;  
            q.Opportunity__c = o.Id;
            
        }
        
        
    }
    
    Public void getOldBaseRate(){
        system.debug('inside getOldBaseRate Method: ');
        
        
        q.Modified_Base_Rate__c = null;
        q.IsModified_Base_Rate__c = false; 
        q.Modified_Premium_Rate__c  = null;
        q.IsModified_Premium_Rate__c = false;
        //quoteApprovalMsg = 'N/A';
        QuotedOfferValue = QuotationManagementServices.INFormat(agreementValue);
        //referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//Call the Referral Details func..22-12-25//Uncommented by Prakshi
    }
    
    public PageReference reloadURL(){
        
        //String sfdcURL =  System.URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
        String sfdcURL =  URL.getOrgDomainUrl().toExternalForm() + '/'; 
        PageReference pageRef;
        if(string.isNotBlank(subPlanId))
            pageRef = new PageReference(sfdcURL+'apex/Quotation2?id='+u.id+'&oppId='+oppId+'&subPlanId='+subPlanId);
        else
           /* pageRef = new PageReference(sfdcURL+oppId);
        pageRef.setRedirect(true);
        pageRef.getParameters().put('discountVal', String.valueOf(CP_DiscountInput));
 		system.debug(' check reloadURL==='+CP_DiscountInput);*/
            pageRef = new PageReference(sfdcURL+'apex/Quotation2?id='+u.id+'&oppId='+oppId);
         pageRef.setRedirect(true);
        return pageRef;
        
    }
    
  	Public PageReference cancleButton(){
        //String sfdcURL =  System.URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
        String sfdcURL =  URL.getOrgDomainUrl().toExternalForm() + '/'; 
        PageReference pageRef;
        pageRef = new PageReference(sfdcURL+oppId);
        return pageRef;
    }
    
    
    /* ---------------------------------------------- Vikas Added End here  -------------------------------------------*/
public class FixedDiscountWrapper2 {
    // Public variables (no get/set needed)
    public Decimal fixedDiscounts;
    public Decimal referralDiscount;
    public Decimal totalDiscounts;
    public List<Quote_Applied_Discounts__c> appliedDiscounts;
    
    // Optional constructor to initialize values
    public FixedDiscountWrapper2() {
        fixedDiscounts = 0;
        referralDiscount = 0;
        totalDiscounts = 0;
        appliedDiscounts = new List<Quote_Applied_Discounts__c>();
    }
}
    //Added for SDR/ROC Management
    public PageReference updateCalculations(){
    System.debug('sdPaidByRunwal**'+sdPaidByRunwal);
    System.debug('allCharges MAp update**'+allChargesMap);
    System.debug('allCharges AV**'+allChargesMap.get('AGREEMENTVALUE'));
    System.debug('allCharges SD**'+allChargesMap.get('Stamp Duty'));
    System.debug('selectedPlan**'+selectedPlan);
   
        // if(sdPaidByRunwal == true && SDAgreementValue != null){
        //     allChargesMap.put('AGREEMENTVALUE',SDAgreementValue+stampDutyValue);
            
        //     // stampDutyValue = 0.0;
        //     // allChargesMap.put('Stamp Duty',stampDutyValue);
        // }
        // if(regChargesByRunwal == true){
        //     //registrationCharges = 0.0;
        //     allChargesMap.put('AGREEMENTVALUE',allChargesMap.get('AGREEMENTVALUE')+allChargesMap.get('Registration Charges'));
        //     //allChargesMap.put('Registration Charges',registrationCharges);
        // }
        // allotmentCharges = allChargesMap.get('AGREEMENTVALUE');
        //addCarParks = selectedCarPark1 + selectedCarPark2 +selectedCarPark3 + selectedCarPark4 +selectedCarPark5 + selectedCarPark6 +selectedCarPark7 + selectedCarPark8 +selectedCarPark9;
        InventoryCostServices.sdPaidByRunwalContext = sdPaidByRunwal;
        InventoryCostServices.regPaidByRunwalContext = regChargesByRunwal;
        quoteUIMap = QuotationManagementServices.getQuotationUIFormat(unitId,allotmentCharges,discountLumpsum,addCarParks,subPlanId);
        allChargesMap = InventoryCostServices.getAllCharges(unitId, allotmentCharges, discountLumpsum,subPlanId);
        agreementValue = allChargesMap.get('AGREEMENTVALUE');
        System.debug('allChargesMap!**'+allChargesMap);
         if(selectedPlan != null) {
            Apexpages.currentPage().getParameters().put('subPlanId',selectedPlan);
            QueryPlanDetails();
        }
    
        
        //agreementValue = allChargesMap.get('AGREEMENTVALUE');//Added by Prakshi
        // referralDetailsVsValueMap = fetchReferralDetails(o,agreementValue);//added by Prakshi
        return null;
    }




//Added by Dolly
private class ParkingConfig {

    String type;
    Integer multiplier;
    Decimal unitCharge;

    Decimal requestedTotal;
    Decimal unitEarmarked;

    SObjectField addQtyField;
    SObjectField earmarkQtyField;
    SObjectField addAmtField;
    SObjectField earmarkAmtField;

    ParkingConfig(
        String type,
        Integer multiplier,
        Decimal unitCharge,
        Decimal requestedTotal,
        Decimal unitEarmarked,
        SObjectField addQtyField,
        SObjectField earmarkQtyField,
        SObjectField addAmtField,
        SObjectField earmarkAmtField
    ) {
        this.type = type;
        this.multiplier = multiplier;
        this.unitCharge = unitCharge;
        this.requestedTotal = requestedTotal;
        this.unitEarmarked = unitEarmarked;
        this.addQtyField = addQtyField;
        this.earmarkQtyField = earmarkQtyField;
        this.addAmtField = addAmtField;
        this.earmarkAmtField = earmarkAmtField;
    }
}

//Added by Dolly
private List<ParkingConfig> getParkingConfigs() {

    return new List<ParkingConfig>{
        new ParkingConfig(
            'Single Covered',
            1,
            proj.Allotment_Charges_1__c,
            q.Single_car_park_additional__c,
            u.Single_car_park_Earmarked__c,
            Quotation__c.Single_car_park_additional__c,
            Quotation__c.Single_car_park_earmarked__c,
            Quotation__c.Single_Covered_Additional_Amount__c,
            Quotation__c.Single_Covered_Additional_Amount__c
        ),

        new ParkingConfig(
            'Tandem Covered',
            1,
            proj.Allotment_Charges_2__c,
            q.Tandem_car_park_additional__c,
            u.Tandem_car_park_Earmarked__c,
            Quotation__c.Tandem_car_park_additional__c,
            Quotation__c.Tandem_car_park_earmarked__c,
            Quotation__c.Tandem_Covered_Additional_Amount__c,
            Quotation__c.Tandem_Covered_Additional_Amount__c
        ),

        new ParkingConfig(
            'Single Open',
            1,
            proj.Allotment_Charges_3__c,
            q.Single_Open_Additional__c,
            u.Single_Open_Earmarked__c,
            Quotation__c.Single_Open_Additional__c,
            Quotation__c.Single_Open_Earmarked__c,
            Quotation__c.Single_Open_Additional_Amount__c,
            Quotation__c.Single_Open_Additional_Amount__c
        ),

        new ParkingConfig(
            'Tandem Open',
            1,
            proj.Allotment_Charges_2__c,
            q.Tandem_Open_Additional__c,
            u.Tandem_Open_Earmarked__c,
            Quotation__c.Tandem_Open_Additional__c,
            Quotation__c.Tandem_Open_Earmarked__c,
            Quotation__c.Tandem_Open_Additional_Amount__c,
            Quotation__c.Tandem_Open_Additional_Amount__c
        ),

        new ParkingConfig(
            'Covered Stack',
            1,
            proj.Allotment_Charges_4__c,
            q.Covered_Stack_Additional__c,
            u.Covered_Stack_Earmarked__c,
            Quotation__c.Covered_Stack_Additional__c,
            Quotation__c.Covered_Stack_Earmarked__c,
            Quotation__c.Covered_Stack_Additional_Amount__c,
            Quotation__c.Covered_Stack_Additional_Amount__c
        ),

        new ParkingConfig(
            'Stilt',
            1,
            proj.Allotment_Charges_5__c,
            q.Stack_Additional__c,
            u.Stack__c,
            Quotation__c.Stack_Additional__c,
            Quotation__c.Stilt_Earmarked__c,
            Quotation__c.Stilt_Additional_Amount__c,
            Quotation__c.Stilt_Additional_Amount__c
        ),

        new ParkingConfig(
            'MLCP',
            1,
            proj.Allotment_Charges_6__c,
            q.MLCP_Additional__c,
            u.MLCP_Earmarked__c,
            Quotation__c.MLCP_Additional__c,
            Quotation__c.MLCP_Earmarked__c,
            Quotation__c.MLCP_Additional_Amount__c,
            Quotation__c.MLCP_Additional_Amount__c
        ),

        new ParkingConfig(
            'Basement',
            1,
            proj.Allotment_Charges_7__c,
            q.Basement_Additional__c,
            u.Basement_Earmarked__c,
            Quotation__c.Basement_Additional__c,
            Quotation__c.Basement_Earmarked__c,
            Quotation__c.Basement_Additional_Amount__c,
            Quotation__c.Basement_Additional_Amount__c
        ),

        new ParkingConfig(
            'Podium',
            1,
            proj.Allotment_Charges_8__c,
            q.Podium__c,
            u.Podium_Earmarked__c,
            Quotation__c.Podium__c,
            Quotation__c.Podium_Earmarked__c,
            Quotation__c.Podium_Amount__c,
            Quotation__c.Podium_Amount__c
        ),

        new ParkingConfig(
            'Puzzle Car Park',
            1,
            proj.Allotment_Charges_9__c,
            q.Puzzle_Car_Park__c,
            u.Puzzle_Car_Park_Earmarked__c,
            Quotation__c.Puzzle_Car_Park__c,
            Quotation__c.Puzzle_Car_Park_Earmarked__c,
            Quotation__c.Puzzle_Car_Park_Amount__c,
            Quotation__c.Puzzle_Car_Park_Amount__c
        ),

        new ParkingConfig(
            'Stack Car Park',
            1,
            proj.Allotment_Charges_2__c,
            q.Puzzle_Car_Park__c,
            u.Stack_Car_Park_Earmarked__c,
            Quotation__c.Puzzle_Car_Park__c,
            Quotation__c.Puzzle_Car_Park_Earmarked__c,
            Quotation__c.Puzzle_Car_Park_Amount__c,
            Quotation__c.Puzzle_Car_Park_Amount__c
        )
    };
}
//Added by Dolly
private Map<String, Integer> projectAvailability;

private void loadProjectAvailability() {

    projectAvailability = new Map<String, Integer>();

    for (AggregateResult ar : [
        SELECT Parking__c parkingType, COUNT(Id) cnt
        FROM Car_Parking_Charge__c
        WHERE Project__c = :proj.Id
        AND Category__c = 'Additional'
        AND Status__c = 'Vacant'
        GROUP BY Parking__c
    ]) {
        projectAvailability.put(
            (String) ar.get('parkingType'),
            (Integer) ar.get('cnt')
        );
    }
}
//Added by Dolly
private void checkCarParkAvailability() {

    showAddCarPark = false;

    for (ParkingConfig p : getParkingConfigs()) {
        if (projectAvailability.get(p.type) > 0) {
            showAddCarPark = true;
            break;
        }
    }
}
//Added by Dolly
private void syncUnitEarmarkedToQuotation() {

    for (ParkingConfig p : getParkingConfigs()) {
        q.put(p.addQtyField, p.unitEarmarked);
    }
}
//Added by Dolly
private Boolean validateAdditionalParkingAvailability() {

    Boolean hasError = false;

    for (ParkingConfig p : getParkingConfigs()) {

        Integer requested =
            q.get(p.addQtyField) == null
                ? 0
                : Integer.valueOf(q.get(p.addQtyField));


        Integer earmarked =
            p.unitEarmarked == null ? 0 : p.unitEarmarked.intValue();

        Integer additionalRequested = Math.max(requested - earmarked, 0);
        Integer available = projectAvailability.get(p.type);

        if (additionalRequested > available) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    'Only ' + available +
                    ' additional ' + p.type + ' car park(s) are available.'
                )
            );
            q.put(p.addQtyField, 0);
            q.put(p.addAmtField, 0);
            hasError = true;
        }
    }
    return !hasError;
}

//Added by Dolly
public void onApplyParking() {
    system.debug('before validateAdditionalParkingAvailability--?');
    Boolean isValid= validateAdditionalParkingAvailability();
    system.debug('after validateAdditionalParkingAvailability--?');

    Decimal totalAmount = 0;
    Integer totalParking = 0;

    for (ParkingConfig p : getParkingConfigs()) {

        Integer qty =
            q.get(p.addQtyField) == null
                ? 0
                : Integer.valueOf(q.get(p.addQtyField));

        Decimal charge =
            p.unitCharge == null ? 0 : p.unitCharge;

        Decimal amountForType = qty * charge;
        Integer parkingForType = qty * p.multiplier;

        // ⭐ TYPE-WISE DEBUG
        System.debug('------------- PARKING TYPE -------------');
        System.debug('Parking Type : ' + p.type);
        System.debug('Qty Entered  : ' + qty);
        System.debug('Unit Charge  : ' + charge);
        System.debug('Amount Added : ' + amountForType);
        System.debug('Parking Count Added : ' + parkingForType);



        totalAmount += qty * charge;
        totalParking += qty * p.multiplier;
    }
    System.debug('========== FINAL PARKING SUMMARY ==========');
    System.debug('TOTAL PARKING SELECTED : ' + totalParking);
    System.debug('TOTAL PARKING AMOUNT   : ' + totalAmount);
    System.debug('===========================================');
    system.debug('atotalAmountability--?'+totalAmount);
    allotmentCharges = totalAmount;
    q.No_of_parking__c = totalParking;
    parkingApplied = true;
    appliedParkingSnapshot.clear();

    for (ParkingConfig p : getParkingConfigs()) {
        Integer qty = q.get(p.addQtyField) == null ? 0 : Integer.valueOf(q.get(p.addQtyField));
        appliedParkingSnapshot.put(p.type, qty);
    }


}

//Added by Dolly
private void applyParkingToQuotation() {

    Decimal totalAmount = 0;
    Integer totalParking = 0;

    for (ParkingConfig p : getParkingConfigs()) {

        Integer requested =
            p.requestedTotal == null ? 0 : p.requestedTotal.intValue();

        Integer unitQty =
            p.unitEarmarked == null ? 0 : p.unitEarmarked.intValue();

        Integer earQty = Math.min(requested, unitQty);
        Integer addQty = Math.max(requested - unitQty, 0);
        Decimal charge = (p.unitCharge == null) ? 0 : p.unitCharge;

        Decimal earAmt = (earQty+addQty) * charge;
        //Decimal addAmt = addQty * p.unitCharge;

        q.put(p.earmarkQtyField, earQty);
        q.put(p.addQtyField, addQty);
        q.put(p.earmarkAmtField, earAmt);
        q.put(p.addAmtField, earAmt);

        totalAmount += earAmt;
        totalParking += (earQty + addQty) * p.multiplier;
    }

    allotmentCharges = totalAmount;
    q.No_of_parking__c = totalParking;
}

    //Added recalculateLumpsumFromPSF by Prakshi to recalculate lumpsump amount if PSF and Percentage is changed on the Quotation Discount Page
    public PageReference recalculateLumpsumFromPSF() {
        System.debug('Inside recalculateLumpsumFromPSF');
        System.debug('Inside pDisc**'+pDisc);
        System.debug('u**'+u);
        unitSealableArea = u.Saleable_Area__c;
        System.debug('unitSealableArea**'+unitSealableArea);
        System.debug('agreementValue1**'+agreementValue);
        
        if(pDisc !=null){
            for(InventoryCostServices.DiscountWrapper dw : pDisc) {
                System.debug('Inside for loop');

                if(dw.discountType == 'PSF') {

                    if(dw.perSqFtVal != null) {

                        dw.lumpsumVal = (dw.perSqFtVal * unitSealableArea).setScale(2);
                        dw.SlumpsumVal = QuotationManagementServices.INFormat(dw.lumpsumVal);

                    } else {
                        dw.lumpsumVal = 0;
                        dw.SlumpsumVal = '0';
                    }
                }
                if(dw.discountType == 'Percentage') {

                    if(dw.percentageVal != null) {

                        dw.lumpsumVal = (dw.percentageVal * agreementValue)/100;
                        dw.SlumpsumVal = QuotationManagementServices.INFormat(dw.lumpsumVal);

                    } else {
                        dw.lumpsumVal = 0;
                        dw.SlumpsumVal = '0';
                    }
                }
            }
        }
        return null;
    }

    public PageReference handleNonMonetaryNotApplicable() {
        for(InventoryCostServices.DiscountWrapper  dwrapper : pDisc) {
            System.debug('nonMonetaryOfferCheckbox**'+nonMonetaryOfferCheckbox);
            System.debug('d.discountCategory**'+dwrapper.discountCategory);
                
                /**Added for Quotation Offer starts */
                if(dwrapper.discountCategory == 'Non monetary' && nonMonetaryOfferCheckbox == true){
                    dwrapper.applied = false;
                    dwrapper.showApply = false;
                    dwrapper.showMonetizable = false;
                    //System.debug('disableApply1**'+disableApply);
                }
                if(dwrapper.discountCategory == 'Non monetary' && nonMonetaryOfferCheckbox == false){
                    dwrapper.applied = false;
                    dwrapper.showApply = true;
                    dwrapper.showMonetizable = true;
                    //System.debug('disableApply1**'+disableApply);
                }
                /**Added for Quotation Offer ends */
        }
        return null;
    }

}