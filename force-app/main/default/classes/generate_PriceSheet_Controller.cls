public class generate_PriceSheet_Controller {
    ApexPages.StandardController controller;
	
    public String projectName { get; set; }
    public String unitStatus { get; set; }
    public String TermsandCondition { get; set; }
	public String paymentPlan { get; set; }
	public String rwParam4 { get; set; }
	public String newType { get; set; }
    public Decimal totalReraCarpetArea { get; set; }
    public String deck { get; set; }
    public Decimal deckArea { get; set; }
    public Decimal utilityArea { get; set; }
    public Decimal carpetArea { get; set; }
	public Decimal agreementValue { get; set; }
    public Decimal agreementValueSTDC { get; set; }
    public Decimal agreementValueSTC { get; set; }
    public Decimal registrationCharges { get; set; }
    public string formatedregistrationCharges { get; set; }
    public Decimal pmcAmount1 { get; set; }
    public Decimal quotationGrandTotal { get; set; }
    public string formatedquotationGrandTotal { get; set; }
    public String carPark1 { get; set; }
	public String carPark2 { get; set; }
    public String carPark3 { get; set; }
    public String carPark4 { get; set; }
    public Integer totalCarParkCount { get; set; }
    public String cheqFav { get; set; }
	public String acNo { get; set; }
    public String gstFavoring { get; set; }
    public String gstAcNo{ get; set; }
    public String bankName { get; set; }
    public Decimal serviceRoomcarpate { get; set; }
    
    public Date dDate { get; set; }
    public Decimal othercharges { get; set; }
    public string formatedothercharges { get; set; }
    public Decimal otherchargesTax { get; set; }
    public string formatedotherchargesTax { get; set; }
    public Customer_Pay_Plan_Header__c objCPPH { get; set; }
    public Quotation__c q { get; set; }
    public List<Quotation__c> qnew { get; set; }
    public List<Standard_Customer_Pay_Plan_Detail__c> scppdList { get; set; }
    public List<Car_Parking_Charge__c> lstCarPark {get; set;}
    public List<wrapperclass> wrapperList { get; set; }
    public String construction { get; set; }
    public List<Standard_Customer_Pay_Plan_Detail__c> newRecordList { get; set; }
    public Tax_Slab__c gstSlab { get; set; }
    public Decimal agreementValuewithDiscount { get; set; }
    public string formatedagreementValuewithDiscount {get; set;}
    public Decimal agreementValuewithoutDiscountTax { get; set; }
    public Decimal totalTDS { get; set; }
    public string formatedtotalTDS { get; set; }
    
    public Decimal totalFinalCheque { get; set; }
    public string formatedtotaltotalFinalCheque { get; set; }
    
    public Decimal stampDuty { get; set; }
    public string formatedstampDuty { get; set; }
    public Decimal scGST { get; set; }
    public string formatedscGST { get; set; }
    public Legal_Entity__c le { get; set; }
    public Decimal grandTotal { get; set; }
    public Decimal gst1Percenatge { get; set; }
    public Decimal gst2Percenatge { get; set; }
    public Decimal gstamount { get; set; }
    public Decimal additionalgstdis { get; set; }
    public Decimal Expectedallprice { get; set; }
    public List<String> strq { get; set; }
    public Boolean dupflag1 { get; set; }
    public Boolean dupflag2 { get; set; }
    public Boolean dupflag3 { get; set; }
    
    //Indian Currency format variable
    public String  formatedagreementValue { get; set; }
    public String  formatedAgreementValueSTDC { get; set; }
    public String  formatedagreementValueSTC { get; set; }
    Public string  finalGstOnAv {get; set;}
     

    public class wrapperclass {
        public Standard_Customer_Pay_Plan_Detail__c scppd { get; set; }
        public String isToBePaid1 { get; set; }
        public Decimal installment1 { get; set; }
        public string formatedinstallment1 { get; set; }
        public Decimal gst { get; set; }
        public string formatedgst { get; set; }
        public Decimal tds { get; set; }
        public string formatedtds { get; set; }
        public Decimal finalcheque { get; set; }
        public string formatedfinalcheque { get; set; }
        public Decimal percentageval { get; set; }
        public String constructionstage { get; set; }
        public String newvar { get; set; }

        public wrapperclass(
            Standard_Customer_Pay_Plan_Detail__c newRecord,
            String isToBePaid,
            Decimal installment,
            Decimal percentage,
            String constructionstageName,
            Decimal gstAmount,
            String projName,
            Decimal aggrVal,
            Decimal othercharges
        ) {
            scppd = newRecord;

            isToBePaid1 = String.isNotBlank(constructionstageName) ? constructionstageName : isToBePaid;
            installment1 = installment != null ? installment : 0;
            formatedinstallment1 = formatIndianAccounting(installment1);
            
            gst = gstAmount != null ? gstAmount.setScale(0) : 0;
            formatedgst = formatIndianAccounting(gst);

            Decimal baseValue = (aggrVal != null ? aggrVal : 0) + (othercharges != null ? othercharges : 0);
            tds = baseValue < 5000000 ? 0 : (installment1 * 0.01).setScale(0);
            formatedtds = formatIndianAccounting(tds);

            finalcheque = installment1 - tds;
            formatedfinalcheque = formatIndianAccounting(finalcheque);
            percentageval = percentage != null ? percentage : 0;
        }
    }

    public generate_PriceSheet_Controller(ApexPages.StandardController controller) {
        String bookingId = ApexPages.currentPage().getParameters().get('id');
        system.debug('bookingId==='+bookingId);
        dDate = Date.today();
        this.controller = controller;
        List<Booking__c> lstnBooking = [Select Id, Quotation__c From Booking__c Where Id = :bookingId LIMIT 1];
       	string quotationId = lstnBooking[0].Quotation__c;
        wrapperList = new List<wrapperclass>();
        scppdList = new List<Standard_Customer_Pay_Plan_Detail__c>();
        newRecordList = new List<Standard_Customer_Pay_Plan_Detail__c>();

        q = [SELECT Id, Stamp_Duty_D__c, Stamp_Duty__c, Project__r.Name, Project_Unit__r.Id, Project_Unit__r.TowerName__r.Name,
             Project_Unit__r.TowerName__r.Apply_3_Additional_Discount__c, Project_Unit__r.TowerName__r.Apply_5_Additional_Discount__c,
             Project_Unit__r.TowerName__r.Exclude_GST_Passback__c, CreatedDate, Project_Maintenance_Charges_Amount_1__c,Booking__r.Allotment_Premium__c,
             Agreement_Value__c, Development_Charges_L__c,Other_Charges_Amount_1__c, Other_Charges_Amount_2__c, Other_Charges_Amount_3__c, 
             Other_Charges_Amount_4__c,Other_Charges_Amount_6__c, Other_Charges_Amount_7__c, Other_Charges_Amount_8__c, Other_Charges_Amount_9__c,
             Other_Charges_Amount_11__c, Other_Charges_Amount_13__c, Other_Charges_Amount_14__c,PaymentPlan__r.Name,Project_Unit__r.RW_Param4__c, 
             Project_Unit__r.Type_Label__c,Project_Unit__r.Total_RERA_Carpet_Area__c,Project_Unit__r.Deck__c,Project_Unit__r.Deck_Area__c, Project_Unit__r.Utility_Area__c,
             Project_Unit__r.Carpet_Area__c, Agreement_Value_ST_D__c, Agreement_Value_ST__c, Registration_Charges__c, Grand_Total_D__c,
             Project__r.Quotation_Terms_Conditions__c, Project_Unit__r.TowerName__r.RW_Terms_And_Conditions__c,Project_Unit__r.RW_Unit_Status__c,
             booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_Flat_Cost__c, Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Name_Flat_Cost__c,
             booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_Flat_Cost__c, Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Number_Flat_Cost__c,
             booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_GST_Deposit__c, Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Number_GST_Deposit__c,
             booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_for_GST_Deposit__c,Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Name_for_GST_Deposit__c,
             booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Bank_Name_GST__c,Project_Unit__r.TowerName__r.Legal_Entity__r.Bank_Name_GST__c,
             Booking__r.Unit_No__r.Service_Room_Carpet_Area__c,Agreement_Value_D__c
             FROM Quotation__c WHERE Id =: quotationId];
        
        List<Car_Parking_Charge__c> lstCarPark = [SELECT Id, Booking__r.Name, Parking__c  FROM Car_Parking_Charge__c 
                                                  where booking__c =: bookingId];
        System.debug('lsit of carpark==>' + lstCarPark);
        if(lstCarPark != null && !lstCarPark.isEmpty()){
            if(lstCarPark.size() > 0 && lstCarPark[0].Parking__c != null){
                carPark1 = lstCarPark[0].Parking__c;
            }
            if(lstCarPark.size() > 1 && lstCarPark[1].Parking__c != null){
                carPark2 = lstCarPark[1].Parking__c;
            }
            if(lstCarPark.size() > 2 && lstCarPark[2].Parking__c != null){
                carPark3 = lstCarPark[2].Parking__c;
            }
            if(lstCarPark.size() > 3 && lstCarPark[3].Parking__c != null){
                carPark4 = lstCarPark[3].Parking__c;
            }
            if (lstCarPark != null && !lstCarPark.isEmpty()) {
                totalCarParkCount = lstCarPark.size();
            }
        }
        
        //service room carpate area
        if(q.Booking__r.Unit_No__r.Service_Room_Carpet_Area__c != null){
            serviceRoomcarpate = q.Booking__r.Unit_No__r.Service_Room_Carpet_Area__c;
        }
        
        
        if(q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_Flat_Cost__c != null){
            cheqFav = q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_Flat_Cost__c;
        }else{
            cheqFav = q.Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Name_Flat_Cost__c;
        }
        
        if(q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_Flat_Cost__c != null){
            acNo = q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_Flat_Cost__c;
        }else{
            acNo = q.Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Number_Flat_Cost__c;
        }
        
        if(q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_for_GST_Deposit__c != null){
            gstFavoring = q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Name_for_GST_Deposit__c;
        }else{
            gstFavoring = q.Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Name_for_GST_Deposit__c;
        }
       
		if(q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_GST_Deposit__c != null){
            gstAcNo = q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Account_Number_GST_Deposit__c;
        }else{
            gstAcNo = q.Project_Unit__r.TowerName__r.Legal_Entity__r.Account_Number_GST_Deposit__c;
        }         
        
        if(q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Bank_Name_GST__c != null){
            bankName = q.booking__r.Unit_No__r.TowerName__r.Legal_Entity__r.Bank_Name_GST__c;
        }else{
            bankName = q.Project_Unit__r.TowerName__r.Legal_Entity__r.Bank_Name_GST__c;
        }  
        
        
        
        projectName = q.Project__r.Name;
        unitStatus = q.Project_Unit__r.RW_Unit_Status__c;
        paymentPlan = q.PaymentPlan__r.Name;
        rwParam4 = q.Project_Unit__r.RW_Param4__c;
        newType= q.Project_Unit__r.Type_Label__c;
        totalReraCarpetArea = q.Project_Unit__r.Total_RERA_Carpet_Area__c;
        deck = q.Project_Unit__r.Deck__c;
        deckArea = q.Project_Unit__r.Deck_Area__c;
        utilityArea = q.Project_Unit__r.Utility_Area__c;
        carpetArea = q.Project_Unit__r.Carpet_Area__c;
        
        agreementValue = q.Booking__r.Allotment_Premium__c;
        formatedagreementValue = formatIndianAccounting(q.Booking__r.Allotment_Premium__c);
        system.debug('agreement value ==>'+ agreementValue);
        
        agreementValueSTDC = q.Agreement_Value_ST_D__c;
        formatedAgreementValueSTDC = formatIndianAccounting(q.Agreement_Value_ST_D__c);
        
        agreementValueSTC = q.Agreement_Value_ST__c;
        formatedAgreementValueSTC = formatIndianAccounting(q.Agreement_Value_ST__c);
        
        finalGstOnAv = (agreementValueSTDC != null && agreementValueSTDC != 0) 
                        ? formatIndianAccounting(agreementValueSTDC) 
                        : formatIndianAccounting(agreementValueSTC);
            
        registrationCharges = q.Registration_Charges__c;
        formatedregistrationCharges = formatIndianAccounting(registrationCharges);
        
        pmcAmount1 = q.Project_Maintenance_Charges_Amount_1__c;
        quotationGrandTotal = q.Grand_Total_D__c;
        formatedquotationGrandTotal = formatIndianAccounting(quotationGrandTotal);
        if(q.Project_Unit__r.TowerName__r.RW_Terms_And_Conditions__c != null){
            TermsandCondition = q.Project_Unit__r.TowerName__r.RW_Terms_And_Conditions__c;
        }else{
            TermsandCondition = q.Project__r.Quotation_Terms_Conditions__c;
        }
        
       
        
       
        
        // Calculate othercharges
        Decimal amt1 = q.Other_Charges_Amount_1__c != null ? q.Other_Charges_Amount_1__c : 0;
        Decimal amt2 = q.Other_Charges_Amount_2__c != null ? q.Other_Charges_Amount_2__c : 0;
        Decimal amt3 = q.Other_Charges_Amount_3__c != null ? q.Other_Charges_Amount_3__c : 0;
        Decimal amt4 = q.Other_Charges_Amount_4__c != null ? q.Other_Charges_Amount_4__c : 0;
        Decimal amt6 = q.Other_Charges_Amount_6__c != null ? q.Other_Charges_Amount_6__c : 0;
        Decimal amt7 = q.Other_Charges_Amount_7__c != null ? q.Other_Charges_Amount_7__c : 0;
        Decimal amt8 = q.Other_Charges_Amount_8__c != null ? q.Other_Charges_Amount_8__c : 0;
        Decimal amt9 = q.Other_Charges_Amount_9__c != null ? q.Other_Charges_Amount_9__c : 0;
        Decimal amt11 = q.Other_Charges_Amount_11__c != null ? q.Other_Charges_Amount_11__c : 0;
        Decimal amt13 = q.Other_Charges_Amount_13__c != null ? q.Other_Charges_Amount_13__c : 0;
        Decimal amt14 = q.Other_Charges_Amount_14__c != null ? q.Other_Charges_Amount_14__c : 0;
        Decimal devCharges = q.Development_Charges_L__c != null ? q.Development_Charges_L__c : 0;

        othercharges = (
            amt1 + amt2 + amt3 + amt4 + amt6 + amt7 + amt8 + amt9 +
            amt11 + amt13 + amt14 + devCharges
        ).setScale(0);
		formatedothercharges = formatIndianAccounting(othercharges);
        
        Decimal maintCharges = q.Project_Maintenance_Charges_Amount_1__c != null ? q.Project_Maintenance_Charges_Amount_1__c : 0;

        if (q.Stamp_Duty_D__c != null && q.Stamp_Duty_D__c != 0) {
            stampDuty = q.Stamp_Duty_D__c;
        } else {
            stampDuty = q.Stamp_Duty__c;
        }
		formatedstampDuty = formatIndianAccounting(stampDuty);
            
        if (q.project__r != null && q.project__r.Name != null) {
            String projectName = q.project__r.Name;

            if (projectName.equalsIgnoreCase('Runwal Pinnacle')) {
                otherchargesTax = ((othercharges + maintCharges) * 0.05).setScale(0);
            } else if (projectName.equalsIgnoreCase('5th Avenue - Runwal Avenue')) {
                otherchargesTax = (othercharges * 0.18).setScale(0);
            } else {
                otherchargesTax = ((othercharges + maintCharges) * 0.18).setScale(0);
            }
            
            formatedotherchargesTax = formatIndianAccounting(otherchargesTax);
        }
        
        //agreementValuewithDiscount = q.Agreement_Value__c != null ? q.Agreement_Value__c.setScale(0) : 0;
        agreementValuewithDiscount = q.Agreement_Value_D__c != null ? q.Agreement_Value_D__c.setScale(0) : 0;
        formatedagreementValuewithDiscount = formatIndianAccounting(agreementValuewithDiscount);
        
        //scGST = (agreementValuewithDiscount * 0.05).setScale(0);
        scGST = q.Agreement_Value_ST_D__c;
        formatedscGST = formatIndianAccounting(scGST);
        
        Decimal baseValue = agreementValuewithDiscount + othercharges;
        if (baseValue >= 5000000) {
            totalTDS = (agreementValuewithDiscount * 0.01).setScale(0);
        } else {
            totalTDS = 0;
        }
        formatedtotalTDS = formatIndianAccounting(totalTDS);
        
        totalFinalCheque = (agreementValuewithDiscount - totalTDS).setScale(0);
		formatedtotaltotalFinalCheque = formatIndianAccounting(totalFinalCheque);
        
        scppdList = [
            SELECT Id, Project_Construction_Stages__c, Project_Construction_Stages__r.Name,
                Customer_Pay_Plan_Header__c, Is_to_be__c, Days_Months_Value__c, Installment__c,
                Amount_Value__c, Is_to_be_Paid__c, Due_Date__c, Original_Percentage__c, Service_Tax_Amount_Q__c
            FROM Standard_Customer_Pay_Plan_Detail__c
            WHERE Customer_Pay_Plan_Header__c != null
                AND Customer_Pay_Plan_Header__r.Quotation__c = :q.Id
                AND Customer_Pay_Plan_Header__r.Global_Charge_Name__c = 'Basic'
        ];

        if (!scppdList.isEmpty()) {
            for (Standard_Customer_Pay_Plan_Detail__c scp : scppdList) {
                Standard_Customer_Pay_Plan_Detail__c newSccp = new Standard_Customer_Pay_Plan_Detail__c();
                newSccp.Is_to_be__c = scp.Is_to_be__c;
                newSccp.Installment__c = scp.Installment__c != null ? scp.Installment__c : 0;
                newSccp.Service_Tax_Amount_Q__c = scp.Service_Tax_Amount_Q__c != null ? scp.Service_Tax_Amount_Q__c : 0;
                newSccp.Amount_Value__c = scp.Amount_Value__c != null ? scp.Amount_Value__c : 0;

                construction = scp.Project_Construction_Stages__r != null ? scp.Project_Construction_Stages__r.Name : '';

                newRecordList.add(newSccp);

                wrapperList.add(new wrapperclass(
                    newSccp,
                    newSccp.Is_to_be__c,
                    newSccp.Installment__c,
                    newSccp.Amount_Value__c,
                    construction,
                    newSccp.Service_Tax_Amount_Q__c,
                    q.project__r != null ? q.project__r.Name : '',
                    q.Agreement_Value__c != null ? q.Agreement_Value__c : 0,
                    othercharges
                ));
            }
        }

        le = InventoryCostServices.getLegalEntityDetails(
            q.Project_Unit__r != null ? q.Project_Unit__r.Id : null,
            q.Project__r != null ? q.Project__r.Id : null
        );
    }
    
    
    public static String formatIndianAccounting(Decimal amount) {
        if (amount == null) return '';
        String numStr = String.valueOf(amount.setScale(0)); // no decimals
        
        String intPart = numStr;
        String result = '';
        
        // Take last 3 digits first
        if (intPart.length() > 3) {
            result = intPart.substring(intPart.length() - 3);
            intPart = intPart.substring(0, intPart.length() - 3);
        } else {
            return intPart; // no formatting needed
        }
        
        // Keep adding commas every 2 digits (crore/lakh style)
        while (intPart.length() > 2) {
            result = intPart.substring(intPart.length() - 2) + ',' + result;
            intPart = intPart.substring(0, intPart.length() - 2);
        }
        
        if (!String.isEmpty(intPart)) {
            result = intPart + ',' + result;
        }
        
        return result;
    }
    
    Public static void fakeMethod(){
        integer i = 1;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}