public with sharing class BookingClass {
    public Applicant_Details__c applicant {
        get;
        set;
    }
    public Applicant_Details__c applicant2 {
        get;
        set;
    }
    public Applicant_Details__c applicant3 {
        get;
        set;
    }
    public Applicant_Details__c applicant4 {
        get;
        set;
    }
    public Applicant_Details__c applicant5 {
        get;
        set;
    }
    public Booking__c boookingObj {
        get;
        set;
    }
    public Receipt__c receiptObj {
        get;
        set;
    }
    public Receipt__c ChequeObj {
        get;
        set;
    }
    public Receipt__c DDObj {
        get;
        set;
    }
    public Receipt__c NEFTObj {
        get;
        set;
    }
    public Receipt__c RTGSObj {
        get;
        set;
    }
    public Receipt__c TDSObj {
        get;
        set;
    }
    public Receipt__c POObj {
        get;
        set;
    }
    public Receipt__c STreceiptObj {
        get;
        set;
    }
    public Receipt__c STChequeObj {
        get;
        set;
    }
    public Receipt__c STDDObj {
        get;
        set;
    }
    public Receipt__c STNEFTObj {
        get;
        set;
    }
    public Receipt__c STRTGSObj {
        get;
        set;
    }
    public Receipt__c STTDSObj {
        get;
        set;
    }
    public Receipt__c STPOObj {
        get;
        set;
    }
    public List < Opportunity > optyList {
        get;
        set;
    }
    public List < Customer_Pay_Plan_Header__c > CPPHListToAdd {
        get;
        set;
    }
    public List < Customer_Pay_Plan_Header__c > CPPHList {
        get;
        set;
    }
    public List < Quotation__c > queryResult {
        get;
        set;
    }
    public List < Quotation__c > QuoteDetails {
        get;
        set;
    }
    public List < Project_Unit__c > unitDetails {
        get;
        set;
    }
    
    public List < Receipt__c > ReceiptDetails {
        get;
        set;
    }
    public List < Receipt__c > STReceiptDetails {
        get;
        set;
    }
    public Quotation__c quotationObj { 
        get;
        set;
    }
    Public Integer i {
        get;
        set;
    }
    public String selectedVal { 
        get;
        set;
    }
    public String selectedQuote {
        get;
        set;
    }
    public Id quotationidparam { 
        get;
        set;
    }
    public Id optyidparam {
        get;
        set;
    }
    public Id unitId {
        get;
        set;
    }
    
    
    public RW_EOI__c eoRecord {
        get;
        set;
    }
    
    public List<Applicable_Offer__c> eoiOffers
    {
        get;
        set;
    }
    
    public Id ProjectId {
        get;
        set;
    }
    public Id optyId {
        get;
        set;
    }
    public Boolean addressCheck {
        get;
        set;
    }
    public Boolean addressCheckReverse {
        get;
        set;
    }
    public Boolean addressCheckApplicant2 {
        get;
        set;
    }
    public Boolean addressCheckApplicant3 {
        get;
        set;
    }
    public Boolean addressCheckApplicant4 {
        get;
        set;
    }
    public Boolean addressCheckApplicant5 {
        get;
        set;
    }
    public Legal_Entity__c le {
        get;
        set;
    }
    
    //added by shailesh
    public Receipt__c reciept {
        get;
        set;
    }
    
    public List < Receipt__c > receiptlist {
        get;
        set;
    }
    public List < Receipt__c > deletereceiptlist {
        get;
        set;
    }
    public Decimal TotalServiceandToken {
        get;
        set;
    }
    public Receipt__c del {
        get;
        set;
    }
    public Integer rowIndex {
        get;
        set;
    }
    public List < Receipt__c > ReceiptLstTobeUpdate {
        get;
        set;
    }
    //////////
    public Boolean ServiceTaxCheck { 
        get;
        set;
    }
    public Decimal TotalReceiptAmount {
        get;
        set;
    }
    public Decimal STTotalReceiptAmount {
        get;
        set;
    }
    public Decimal TotalToken {
        get;
        set;
    }
    public Decimal TotalQuoteToken {
        get;
        set;
    }
    //Added by Payal on 14/07/2021
    public boolean dupflag { 
        get;
        set;
    }
    public boolean dupflag1 {
        get;
        set;
    }
    public boolean isEmpManager {       //Added by Sheetal on 20/02/2022
        get;
        set;
    }
    public boolean isCustomerReference {       //Added by Sheetal on 20/02/2022
        get;
        set;
    }
    
    List < Car_Parking_Charge__c > ParkingListToUpdate = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > TandemOPENParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > SingleOPENParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > SingleCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > TandemCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > STILTParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > MLCPParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > BasementParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > PodiumParkingList = new List < Car_Parking_Charge__c > ();
    List < Car_Parking_Charge__c > PuzzleCarParkList = new List < Car_Parking_Charge__c > (); //Added by Vinay 28-03-2025
    List < Car_Parking_Charge__c > StackCarParkList = new List < Car_Parking_Charge__c > (); //Added by Vinay 21-11-2025
    
    List < Applicant_Details__c > listApplicant = new list < Applicant_Details__c > ();
    List < Receipt_Details__c > listReceiptDetails = new list < Receipt_Details__c > (); 
    Receipt_Details__c objReceiptDetails = new Receipt_Details__c();
    Receipt_Details__c objReceiptDetailsST = new Receipt_Details__c();
    List < Project_Charges__c > listglobalcharges = new List < Project_Charges__c > ();
    public List < Receipt__c > ListOldReceipt {
        get;
        set;
    }
    //Anuja added on  29/12/15
    public String tokenamt {
        get;
        set;
    }
    public String STamt {
        get;
        set;
    }
    public List<Scheme_Configuration__c> sc {
        get;
        set;
    }
    public List<AOP__c> AopList {
        get;
        set;
    }
    List<Brokerage_Scheme__c> brokerageScheme = new List<Brokerage_Scheme__c>();
    //Added by coServe 23-03-2023 Start
    /* public Document document {
get {
if (document == null)
document = new Document();
return document;
}
set;
}*/
    
    public String selectedvalue {set;get;} 
    public String docId;
    public String fileUrl {get;set;}
    public Boolean fileUploaded {get;set;}
    public Boolean disabelBookingDate {get;set;}
    //Added by coServe 23-03-2023 End
    public Account acc {get;set;} //Added by Vinay 03-06-2025    
    
    public BookingClass() {
        
        //added by shailesh
        reciept = new Receipt__c();
        deletereceiptlist = new List < Receipt__c > ();
        receiptlist = new List < Receipt__c > ();
        receiptlist.add(reciept);
        
        TotalServiceandToken = 0;
        rowIndex = 0;
        
        /////
        
        i = 0;
        TotalReceiptAmount = 0;
        STTotalReceiptAmount = 0;
        TotalToken = 0;
        TotalQuoteToken = 0;
        tokenamt = '';
        STamt = '';
        ParkingListToUpdate = new List < Car_Parking_Charge__c > ();
        TandemOPENParkingList = new List < Car_Parking_Charge__c > ();
        SingleOPENParkingList = new List < Car_Parking_Charge__c > ();
        SingleCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
        TandemCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
        STILTParkingList = new List < Car_Parking_Charge__c > ();
        MLCPParkingList = new List < Car_Parking_Charge__c > ();
        BasementParkingList = new List < Car_Parking_Charge__c > ();
        PodiumParkingList = new List < Car_Parking_Charge__c > ();
        PuzzleCarParkList = new List < Car_Parking_Charge__c > (); //Added by Vinay 28-03-2025
        StackCarParkList = new List < Car_Parking_Charge__c > (); //Added by Vinay 21-11-2025
        
        ReceiptLstTobeUpdate = new List < Receipt__c > ();
        
        ListOldReceipt = new List < Receipt__c > ();
        STReceiptDetails = new List < Receipt__c > ();
        ReceiptDetails = new List < Receipt__c > ();
        QuoteDetails = new List < Quotation__c > ();
        queryResult = new List < Quotation__c > ();
        CPPHList = new List < Customer_Pay_Plan_Header__c > ();
        CPPHListToAdd = new List < Customer_Pay_Plan_Header__c > ();
        optyList = new List < Opportunity > ();
        unitDetails = new List<Project_Unit__c>();
        
        le = new Legal_Entity__c();
        addressCheck = true;
        addressCheckApplicant2 = true;
        addressCheckApplicant3 = true;
        addressCheckApplicant4 = true;
        addressCheckApplicant5 = true;
        applicant = new Applicant_Details__c();
        applicant2 = new Applicant_Details__c();
        applicant3 = new Applicant_Details__c();
        applicant4 = new Applicant_Details__c();
        applicant5 = new Applicant_Details__c();
        boookingObj = new Booking__c();
        quotationObj = new Quotation__c(); 
        receiptObj = new Receipt__c();
        ChequeObj = new Receipt__c(); 
        DDObj = new Receipt__c();
        NEFTObj = new Receipt__c();
        RTGSObj = new Receipt__c();
        TDSObj = new Receipt__c();
        POObj = new Receipt__c();
        STreceiptObj = new Receipt__c();
        STChequeObj = new Receipt__c();
        STDDObj = new Receipt__c();
        STNEFTObj = new Receipt__c();
        STRTGSObj = new Receipt__c();
        STTDSObj = new Receipt__c();
        STPOObj = new Receipt__c();
        dupflag = false;
        dupflag1 = false;
        //   boookingObj.Brokerage__c =2.25;         //Added by Sheetal on 14/01/2022 .. Commented by Sheetal on 1/2/2023
        isEmpManager = false;                   //Added by Sheetal on 20/02/2022
        isCustomerReference = false;
        sc = new List<Scheme_Configuration__c>();
        AopList = New List<AOP__c>();
        disabelBookingDate = false;
        if (ApexPages.currentPage().getParameters().get('unitId') != null && ApexPages.currentPage().getParameters().get('unitId') != '') {
            
            unitId = ApexPages.currentPage().getParameters().get('unitId');
            //system.debug('inside contructor unit is ' + unitId);
        }
        
        
        
        if (ApexPages.currentPage().getParameters().get('optyid') != null && ApexPages.currentPage().getParameters().get('optyid') != '') {
            boookingObj.Opportunity__c = ApexPages.currentPage().getParameters().get('optyid');
            
            Opportunity opp = [SELECT Id, RW_Type_of_Client__c, AccountId FROM Opportunity WHERE Id =: ApexPages.currentPage().getParameters().get('optyid')]; //Commented by Vinay 04-06-2025
            
            acc = [SELECT Id, Salutation, FirstName, LastName, RW_Zip_Code__c, RW_Company_Name__c, RW_Other_Company_Name__c, RW_Designation__c, No_of_family_members__c, RW_Occupation__c, Distance_To_Office__c, Family_Income__c, Purpose__c, Vehicles_owned__c, Industry, Current_Residential_Address__c, Four_Wheeler__c FROM Account WHERE Id =: opp.AccountId]; //Added by Vinay 03-06-2025
            if(opp.RW_Type_of_Client__c == null && !Test.isRunningTest()){
                throw new CommonException('Type of Client should not be blank.');
            }
            
            try {
                ReceiptDetails = [SELECT id, Project_Unit__c, Project__c, Name, Cheque_DD_Date__c, DraweeBank__c, CreatedDate, LastModifiedDate, Token_Amount_Receipt__c, Due_Amount_Rs__c, Mode__c, Branch__c, Total_Amount__c,
                                  Receipt_Date__c FROM Receipt__c WHERE Opportunity__c =: boookingObj.Opportunity__c and Token_Amount_Receipt__c = true And(Project_Unit__c = null OR Project_Unit__c =: unitId)
                                 ]; //and Token_Amount_Receipt__c = true
                if (ReceiptDetails.size() > 0) {
                    system.debug('Inside ReceiptDetails');
                    boookingObj.Booking_Date__c = ReceiptDetails[0].CreatedDate;
                    boookingObj.Receipts__c = ReceiptDetails[0].id;
                    for (Receipt__c rds: ReceiptDetails) {
                        TotalReceiptAmount = TotalReceiptAmount + rds.Total_Amount__c;
                        if (rds.Project_Unit__c == null) {
                            rds.Project_Unit__c = unitId;
                        }
                    }
                    
                }
                STReceiptDetails = [SELECT id, Name, Cheque_DD_Date__c, DraweeBank__c, LastModifiedDate, Token_Amount_Receipt__c, Due_Amount_Rs__c, Mode__c, Branch__c, Total_Amount__c,
                                    Receipt_Date__c, Project_Unit__c FROM Receipt__c WHERE Opportunity__c =: boookingObj.Opportunity__c and Token_Amount_ST__c = true And(Project_Unit__c = null OR Project_Unit__c =: unitId)
                                   ];
                if (STReceiptDetails.size() > 0) {
                    system.debug('Inside STReceiptDetails');
                    boookingObj.ServiceReceipt__c = STReceiptDetails[0].id;
                    for (Receipt__c strds: STReceiptDetails) {
                        STTotalReceiptAmount = STTotalReceiptAmount + strds.Total_Amount__c;
                        if (strds.Project_Unit__c == null) {
                            strds.Project_Unit__c = unitId;
                        }
                    }
                }
                //Added by coServe 04-06-2024 Start
                if(boookingObj.Booking_Date__c >= Date.valueOf(System.label.Booking_Date_Editable)){
                    disabelBookingDate = true;
                }else if(boookingObj.Booking_Date__c < Date.valueOf(System.label.Booking_Date_Editable)){
                    disabelBookingDate = false;
                }
                
                //Added by coServe 04-06-2024 End
                
            } catch (DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                
            }
        }
        
        if (ApexPages.currentPage().getParameters().get('projectId') != null && ApexPages.currentPage().getParameters().get('projectId') != '') {
            
            ProjectId = ApexPages.currentPage().getParameters().get('projectId');
            system.debug('inside contructor ProjectId is ' + ProjectId);
        }
        getquotation();
        
        // Added by UBSDigicloud  Start------------------------------- Date 19-06-2025
        List<Blocking_Unit_Information__c> blkUnitInfoList = [
            SELECT Id, 
            Amount__c, Amount_2__c, Amount_3__c, Amount_4__c, Amount_5__c,
            Mode_Of_Payment__c, Mode_Of_Payment_2__c, Mode_Of_Payment_3__c, Mode_Of_Payment_4__c, Mode_Of_Payment_5__c,
            Paid_Date__c, Paid_Date_2__c, Paid_Date_3__c, Paid_Date_4__c, Paid_Date_5__c,
            Transaction_Details__c, Transaction_Details_2__c, Transaction_Details_3__c, Transaction_Details_4__c, Transaction_Details_5__c,Pan_Number__c,Aadhar_Number__c
            FROM Blocking_Unit_Information__c 
            WHERE Opportunity__c = :boookingObj.Opportunity__c AND Active__c = true
        ];
        
        if (!blkUnitInfoList.isEmpty()) {
            Blocking_Unit_Information__c blk = blkUnitInfoList[0];
            
            // Blocking_Unit_Information__c blk = blkUnitInfoList[0];
            
            // Pre-fill PAN card
            if (String.isNotBlank(blk.Pan_Number__c)) {
                applicant.Pancard__c = true;
                applicant.PancardNo__c = blk.Pan_Number__c;
            }
            
            // Pre-fill Address Proof with Aadhar
            if (String.isNotBlank(blk.Aadhar_Number__c)) {
                applicant.Address_Proof__c = true;
                applicant.Address_Proof_Document__c = 'Aadhar Card';
                applicant.Address_Proof_Number__c = blk.Aadhar_Number__c;
            }
            
            List<Receipt__c> tempList = new List<Receipt__c>();
            
            for (Integer i = 0; i < 5; i++) {
                Decimal amount;
                String mode;
                Date datePaid;
                String txn;
                
                if (i == 0) {
                    amount = blk.Amount__c;
                    mode = blk.Mode_Of_Payment__c;
                    datePaid = blk.Paid_Date__c;
                    txn = blk.Transaction_Details__c;
                } else if (i == 1) {
                    amount = blk.Amount_2__c;
                    mode = blk.Mode_Of_Payment_2__c;
                    datePaid = blk.Paid_Date_2__c;
                    txn = blk.Transaction_Details_2__c;
                } else if (i == 2) {
                    amount = blk.Amount_3__c;
                    mode = blk.Mode_Of_Payment_3__c;
                    datePaid = blk.Paid_Date_3__c;
                    txn = blk.Transaction_Details_3__c;
                } else if (i == 3) {
                    amount = blk.Amount_4__c;
                    mode = blk.Mode_Of_Payment_4__c;
                    datePaid = blk.Paid_Date_4__c;
                    txn = blk.Transaction_Details_4__c;
                } else if (i == 4) {
                    amount = blk.Amount_5__c;
                    mode = blk.Mode_Of_Payment_5__c;
                    datePaid = blk.Paid_Date_5__c;
                    txn = blk.Transaction_Details_5__c;
                }
                
                // Only add the row if at least one meaningful value exists
                if ((amount != null && amount != 0) || String.isNotBlank(mode) || String.isNotBlank(txn)) {
                    Receipt__c r = new Receipt__c();
                    r.Total_Amount__c = amount;
                    r.Mode__c = mode;
                    r.Cheque_DD_Date__c = datePaid;
                    r.Cheque_DD__c = txn;
                    
                    tempList.add(r);
                }
            }
            
            // Replace the default single row if data exists
            if (!tempList.isEmpty()) {
                receiptlist.clear();
                receiptlist.addAll(tempList);
            }
            // Added by UBSDigicloud   End   
            
            
        }
        
        
    }
    
    public PageReference getquotation() {
        Set<Id> eoiIds = new Set<Id>();
        if (boookingObj.Opportunity__c != null) {
            optyList = [SELECT id, RW_Booking_Date_Opp__c, Walk_in_Source__c, Walk_in_Sub_Source__c, Name, RW_Project__c, Account.Birth_Date__c,Account.RW_Country__c,Account.City__c,
                        Account.BillingStreet, Sourcing_Manager__c, Sales_Manager__c, Account.BillingCity, Account.BillingPostalCode,RW_Previous_Opportunity__r.Booking__r.Project__c,
                        Account.BillingCountry, Account.Name,  Account.Country__c, Account.RW_State__c, Account.RW_City__c, Account.Office_Street__c,Account.State__c,
                        Account.Mobile_No__c, Account.Alternate_Mobile_No__c, Walkin_Source__c, Walkin_SubSource__c, RW_Sourcing_Manager__c, RW_Sales_Associate__c,RW_Walkin_Channel_Partner__c,RW_Walkin_Channel_Partner__r.Name,
                        Employee_Reference__c,Employee_Reference__r.Name,RW_Type_of_Client__c, Lead_Sub_Source__c,RW_Project_Unit__r.name,RW_Project_Unit__r.TowerName__c,RW_Previous_Opportunity__c,RW_Previous_Opportunity__r.Booking__c, (Select Id,Name,RW_Status__c from EOI__r),RW_Walkin_Channel_Partner__r.Account__c,
                        RW_Project__r.CP_Invoice_Clearing_L1__c, RW_Project__r.CP_Invoice_Clearing_L2__c,RW_Walkin_Customer_Reference__c,RW_Walkin_Customer_Reference__r.name,Customer_reference_Booked_Unit__r.name,Referral_Sub_Source__c,
                        Account.Salutation, Account.FirstName, Account.LastName, Account.RW_Zip_Code__c, Account.RW_Company_Name__c, Account.RW_Other_Company_Name__c, Account.RW_Designation__c, Account.No_of_family_members__c,Blocked_Date__c
                        from Opportunity where id =: boookingObj.Opportunity__c
                       ]; //Account.BillingAddress,
            //system.debug('optyList Project__c ' +optyList[0].Project__c);
            if (optyList.size() > 0) 
            {
                
                
                //Added by coServe 29-05-2024 Start
                List<Blocking_Unit_Information__c> blkUnitInfoList = [SELECT Id FROM Blocking_Unit_Information__c WHERE Opportunity__c =: optyList[0].Id AND Active__c = true];
                if(blkUnitInfoList.size() == 0){
                    if(!Test.isRunningTest()){
                        throw new CommonException('Active Blocking Unit Information not found. Please go back to Opportunity and create Blocking Unit Information.');
                    }
                    //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Active Blocking Unit Information not found');
                    //ApexPages.addMessage(myMsg);
                    //i = 1;
                }
                //Added by coServe 25-05-2024 End
                
                if (optyList[0].Walkin_Source__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Walk in Source for opportunity  <a style="color:blue;" href="/' + optyList[0].id + '" target="_blank">' + optyList[0].Name + '</a> is empty');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                } else {
                    boookingObj.Source_of_Booking__c = optyList[0].Walkin_Source__c;
                    // boookingObj.Booking_Source_Details__c = optyList[0].Source_Details__c;   
                    
                }
                //Added by coServe 11-04-2024 Start
                /*if (optyList[0].Walkin_Source__c == 'Temp Channel Partner') {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Temp Channel Partner should be converted before creation of Booking');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }*///COmmented by Prashant to Allow temp cps to Book now. //15-9-25.
                //Added by coServe 11-04-2024 End
                if(optyList[0].RW_Type_of_Client__c != Null){
                    boookingObj.Type_of_Client__c = optyList[0].RW_Type_of_Client__c;
                }
                if(optyList[0].RW_Previous_Opportunity__c != Null){
                    boookingObj.Old_Booking__c = optyList[0].RW_Previous_Opportunity__r.Booking__c;
                }
                if(optyList[0].RW_Previous_Opportunity__c != Null && boookingObj.Old_Booking__r.RW_Registration_Done__c == 'Yes' && boookingObj.Old_Booking__r.RW_X9_99_Received__c == true && boookingObj.Old_Booking__r.Invoice_Submitted_by_CP__c == true  ){
                    boookingObj.Exclude_From_Brokerage_Batch__c = true;
                }
                if(optyList[0].RW_Previous_Opportunity__r.Booking__r.Project__c == boookingObj.Project__c && optyList[0].RW_Previous_Opportunity__c != Null){
                    boookingObj.Unit_Trasfer_to_Project__c = 'Same Project';
                }else if (optyList[0].RW_Previous_Opportunity__r.Booking__r.Project__c != boookingObj.Project__c && optyList[0].RW_Previous_Opportunity__c != Null){
                    boookingObj.Unit_Trasfer_to_Project__c = 'Different Project';
                }
                
                if(optyList[0].RW_Project__c != NULL){
                    boookingObj.CP_Invoice_Clearing_L1__c = optyList[0].RW_Project__r.CP_Invoice_Clearing_L1__c;
                    boookingObj.CP_Invoice_Clearing_L2__c = optyList[0].RW_Project__r.CP_Invoice_Clearing_L2__c;
                }
                /* if(optyList[0].RW_Project_Unit__r.name != Null){
boookingObj.Tower__c = optyList[0].RW_Project_Unit__r.TowerName__c;
}*/
                if(optyList[0].RW_Walkin_Channel_Partner__c !=  Null){
                    // boookingObj.Account__c =  optyList[0].RW_Walkin_Channel_Partner__r.Account__c;
                    List<Account> accList = [select id,name,Channel_Partner__c from Account where Channel_Partner__c =:optyList[0].RW_Walkin_Channel_Partner__c];
                    if(accList.size() > 0){
                        boookingObj.Account__c = accList[0].id ;   
                    }
                }
                
                if(optyList[0].Walkin_SubSource__c != null)     //updated  by Sheetal on 24/03/2022 to solve Issue I0118 
                {
                    boookingObj.Sub_Source__c = optyList[0].Walkin_SubSource__c;
                    /* ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Walk in Sub Source for opportunity  <a style="color:blue;" href="/'+optyList[0].id+'" target="_blank">'+optyList[0].Name+'</a> is empty');
ApexPages.addMessage(myMsg);
i=1;    */                    
                }
                if(optyList[0].Referral_Sub_Source__c != null)  {   //Added  by Sheetal on 5/12/2022                 {
                    boookingObj.Sub_Source__c = optyList[0].Referral_Sub_Source__c;
                }
                
                if(optyList[0].Walkin_Source__c != null && optyList[0].Walkin_Source__c == 'Referral' && optyList[0].Referral_Sub_Source__c == 'Existing client reference')  {   //Added  by Sheetal on 28/12/2022                  
                    boookingObj.Referral_Benefit__c = 1;
                }
                else{
                    boookingObj.Referral_Benefit__c = 0;
                }
                
                
                /* else{
boookingObj.Sub_Source__c = optyList[0].Walkin_SubSource__c;
//boookingObj.Booking_Source_Details__c = optyList[0].Source_Details__c;
}*/
                
                
                if (optyList[0].EOI__r.size() >0)
                {
                    for(RW_EOI__c eoiRecords : optyList[0].EOI__r)
                    {
                        if(eoiRecords.RW_Status__c == 'EOI Blocked' || eoiRecords.RW_Status__c == 'EOI Confirmed')
                            eoiIds.add(eoiRecords.Id);
                    }
                    
                    List<RW_EOI__c> eoiRec = [Select Id,Name,RW_Status__c,(Select Id,Name,Offer__c,Offer__r.Name,Sub_Offer__c,Sub_Offer__r.Name,Offer_Availed__c from Applicable_Offers__r where Offer_Availed__c =true) from RW_EOI__c Where Id IN : eoiIds  ];
                    if(eoiRec!= null && eoiRec.size() >0)
                    {
                        eoRecord = eoiRec[0];
                        eoiOffers = new List<Applicable_Offer__c>();
                        for(Applicable_Offer__c appOffers : eoRecord.Applicable_Offers__r)
                        {
                            if(appOffers.Offer_Availed__c)
                                eoiOffers.add(appOffers);
                        }
                        
                    }
                }
                
                if (optyList[0].RW_Sourcing_Manager__c == null && optyList[0].Walk_in_Source__c =='Channel Partner' ) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Sourcing Manager for opportunity  <a style="color:blue;" href="/' + optyList[0].id + '" target="_blank">' + optyList[0].Name + '</a> is empty');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                } else {
                    boookingObj.Sourcing_Mananger__c = optyList[0].RW_Sourcing_Manager__c;
                }
                if (optyList[0].RW_Sales_Associate__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Sales Manager for opportunity  <a style="color:blue;" href="/' + optyList[0].id + '" target="_blank">' + optyList[0].Name + '</a> is empty');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                } else {
                    boookingObj.Sales_Managers__c = optyList[0].RW_Sales_Associate__c;
                    boookingObj.Sales_Manager__c =  userinfo.getUserId();   //Added by Payal
                }
                //Added by Payal 14/07/2021
                if(optyList[0].Walkin_Source__c == 'Channel Partner' || optyList[0].Walkin_Source__c == 'Temp Channel Partner'){ 
                    boookingObj.BrokerIId__c = optyList[0].RW_Walkin_Channel_Partner__c;
                    dupflag = true;        
                }
                //Added by Sheetal on 29/11/2021
                if(optyList[0].Walkin_Source__c == 'Channel Partner' || optyList[0].Walkin_Source__c == 'Temp Channel Partner'){
                    boookingObj.BrokerIId__c = optyList[0].RW_Walkin_Channel_Partner__c;
                    boookingObj.Broker_Name__c = optyList[0].RW_Walkin_Channel_Partner__r.Name;  
                    dupflag1 = true;        
                }
                //Added by Sheetal on 28/02/2022 to solve Issue I0118
                if(optyList[0].Walkin_Source__c == 'Emp / Mgmt Reference'){           
                    boookingObj.Emp_Manager_Name__c = optyList[0].Employee_Reference__r.Name;  
                    isEmpManager = true;        
                }
                if(optyList[0].Walkin_Source__c == 'Referral' && optyList[0].Referral_Sub_Source__c == 'Existing client reference' && optyList[0].RW_Walkin_Customer_Reference__c != NULL){
                    boookingObj.Customer_reference_Book_Unit__c = optyList[0].Customer_reference_Booked_Unit__c;
                    boookingObj.Customer_Reference__c = optyList[0].RW_Walkin_Customer_Reference__r.Name; 
                    //boookingObj.boookingObj.Customer_Reference__c = optyList[0].Customer_Reference_Opportunity__c; 
                    isCustomerReference = true;
                }
                //System.debug('Todayyyyyy ' +boookingObj.Booking_Source_Details__c);
                //Assigning applicant1 details from account 
                //applicant.Salutation__c=optyList[0].Account.Salutation;
                applicant.Name = optyList[0].Account.Name;
                applicant.DOB__c = optyList[0].Account.Birth_Date__c;
                applicant.Country__c = optyList[0].Account.RW_Country__c;
                applicant.State__c = optyList[0].Account.State__c;
                applicant.City__c = optyList[0].Account.City__c;
                applicant.Permanent_Address__c = optyList[0].Account.Office_Street__c;
                applicant.Mobile_Number__c = optyList[0].Account.Mobile_No__c;
                applicant.Landline_Number__c = optyList[0].Account.Alternate_Mobile_No__c;
                //applicant.Email_Address__c = optyList[0].Account.PersonEmail;
                if (optyList[0].Account.BillingPostalCode != null) {
                    applicant.Pincode__c = Decimal.valueof(optyList[0].Account.BillingPostalCode);
                } else {
                    applicant.Pincode__c = 0;
                }
                applicant.Country__c = optyList[0].Account.BillingCountry;
                applicant.City__c = optyList[0].Account.BillingCity;
                //Added by Vinay 03-06-2025 Start
                applicant.Salutation__c = optyList[0].Account.Salutation;
                applicant.First_Name__c = optyList[0].Account.FirstName;
                applicant.Last_Name__c = optyList[0].Account.LastName;
                if(String.isNotBlank(optyList[0].Account.RW_Zip_Code__c) && optyList[0].Account.RW_Zip_Code__c.isNumeric())
                    applicant.Pincode__c = Integer.valueOf(optyList[0].Account.RW_Zip_Code__c);
                applicant.Organization_Name__c = (optyList[0].Account.RW_Company_Name__c != 'Others')? optyList[0].Account.RW_Company_Name__c : optyList[0].Account.RW_Other_Company_Name__c;
                applicant.Designation__c = optyList[0].Account.RW_Designation__c;
                //Added by Vinay 03-06-2025 End
            } else {
                
            }
        }
        if (boookingObj.Opportunity__c != null && unitId == null && ProjectId == null) {
            //system.debug('get quote if only opty');
            queryResult = [SELECT id, Tandem_car_park_Additional__c,Stack_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c,Podium__c, Name, Booking__c, Allow_booking_without_full_token__c, Project_Unit__r.RW_Project__c, Service_Tax_On_Token_Amount__c, Quote_Status__c,Puzzle_Car_Park__c,Stack_Additional_1__c
                           from Quotation__c where Quote_Status__c = 'Valid' and Opportunity__c =: boookingObj.Opportunity__c and Project_Unit__r.RW_Project__c =: optyList[0].RW_Project__c and Project_Unit__r.RW_Unit_Status__c = 'Vacant'
                           and Booking__c =: null
                          ];
            if (queryResult.size() > 0) {
                system.debug('Result only opty quotations' + queryResult);
                
            } else {
               // system.debug('Quotation Else if only opty');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Either this opportunity does not have a Valid Quotation or the unit associated with it is not vacant');
                ApexPages.addMessage(myMsg);
            }
            
        } else if (boookingObj.Opportunity__c != null && unitId != null && ProjectId == null) {
            queryResult = [SELECT id, Tandem_car_park_Additional__c,Podium__c,Stack_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c, Name, Booking__c, Allow_booking_without_full_token__c, Service_Tax_On_Token_Amount__c, Project_Unit__r.RW_Project__c, Project_Unit__c,Quote_Status__c, Puzzle_Car_Park__c,Stack_Additional_1__c from Quotation__c where Quote_Status__c = 'Valid' and Opportunity__c =: boookingObj.Opportunity__c and Project_Unit__c =: unitId and Project_Unit__r.RW_Project__c =: optyList[0].RW_Project__c and(Project_Unit__r.RW_Unit_Status__c = 'Available'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   OR Project_Unit__r.RW_Unit_Status__c = 'Blocked') and Booking__c =: null];
            system.debug('queryResult2' + queryResult);
            if (queryResult.size() > 0) {
                system.debug('Result only opty and unit quotations' + queryResult);
            } else {
                //system.debug('Quotation Else if opty  and unit is present but no quotation');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Either this opportunity does not have a Valid Quotation or the unit associated with the quotation is not vacant');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            
        } else if (boookingObj.Opportunity__c != null && ProjectId != null && unitId == null) {
            system.debug('get quote if ProjectId  is not null and ProjectId  :-' + ProjectId);
            queryResult = [SELECT id, Tandem_car_park_Additional__c,Stack_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c,Podium__c, Name, Booking__c, Allow_booking_without_full_token__c, Project_Unit__r.RW_Project__c, Service_Tax_On_Token_Amount__c, Project_Unit__c,Quote_Status__c, Puzzle_Car_Park__c,Stack_Additional_1__c from Quotation__c where Quote_Status__c = 'Valid' and Opportunity__c =: boookingObj.Opportunity__c and Project__c =: ProjectId and Project_Unit__r.RW_Unit_Status__c = 'Available'
                           and Booking__c =: null
                          ];
            //system.debug('queryResult' + queryResult);
            
            if (queryResult.size() > 0) {
                system.debug('Result only opty and ProjectId quotations' + queryResult);
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Either the opportunity does not have Valid Quotation or the unit associated with it is not vacant');
                ApexPages.addMessage(myMsg);
                i = 1;
            }                
        }/* else if (boookingObj.Opportunity__c != null && ProjectId != null && unitId != null) {
system.debug('get quote if opty and ProjectId and unitId ');
system.debug('get quote if ProjectId  is not null and ProjectId  :-' + ProjectId);
system.debug('get quote if opty and unitId ' + unitId);
queryResult = [SELECT id, Tandem_car_park_Additional__c,MLCP_Additional__c,Stack_Additional__c, Single_car_park_Additional__c,Podium__c, Name, Booking__c, Allow_booking_without_full_token__c, Project_Unit__r.RW_Project__c, Service_Tax_On_Token_Amount__c, Project_Unit__c,Quote_Status__c from Quotation__c where Quote_Status__c = 'Valid' and Opportunity__c =: boookingObj.Opportunity__c and Project__c =: ProjectId and(Project_Unit__r.RW_Unit_Status__c = 'Available'
OR Project_Unit__r.RW_Unit_Status__c = 'Hold' OR Project_Unit__r.RW_Unit_Status__c = 'Blocked') and Project_Unit__c =: unitId and Booking__c =: null];
system.debug('queryResult' + queryResult);

if (queryResult.size() > 0) {
system.debug('Result only opty and ProjectId quotations' + queryResult);
} else {
system.debug('Quotation Else if opty  and Project');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Either the opportunity does not have a Valid Quotation or the unit associated with it is not Available or hold');
ApexPages.addMessage(myMsg);
i = 1;
} 

} */
        else if (boookingObj.Opportunity__c != null && ProjectId != null && unitId != null) {
            system.debug('get quote if ProjectId  is not null and ProjectId  :-' + ProjectId + 'get quote if opty and unitId ' + unitId);
            queryResult = [SELECT id, Tandem_car_park_Additional__c,MLCP_Additional__c,Stack_Additional__c, Single_car_park_Additional__c,Stack_Additional_1__c,Podium__c, Name, Booking__c, Allow_booking_without_full_token__c, Project_Unit__r.RW_Project__c, Service_Tax_On_Token_Amount__c, Project_Unit__c,Quote_Status__c from Quotation__c where Quote_Status__c = 'Valid' and Opportunity__c =: boookingObj.Opportunity__c and Project__c =: ProjectId and(Project_Unit__r.RW_Unit_Status__c = 'Available'
                                                                                                                                                                                                                                                                                                                                                                                                                                              OR Project_Unit__r.RW_Unit_Status__c = 'Hold' OR Project_Unit__r.RW_Unit_Status__c = 'Blocked') and Project_Unit__c =: unitId and Booking__c =: null];
            system.debug('queryResult' + queryResult);
        }
        else {
            system.debug('Inside getQuote No Opportunity');
            
        } 
        return null;
    }
    
    //Create selectlist out of queryresult
    public List < SelectOption > getQuote {
        get {
            
            //system.debug('Inside getQuote queryResult' + queryResult);
            List < SelectOption > optns = new List < Selectoption > ();
            optns.add(new SelectOption('', 'Select a Quotation'));
            if (queryResult.size() > 0) {
                for (Quotation__c obj: queryResult) {
                    optns.add(new SelectOption(obj.Id, obj.Name));
                }
                
            } else {
                system.debug('No quotations');
                
            }
            return optns;
        }
        set;
    }
    
    //added by shailesh
    public void addReciept() {
        
        Receipt__c rec = new Receipt__c();
        receiptlist.add(rec);
        system.debug('receiptlist inside method::::' + receiptlist);
        
    }
    public void deleteReciept() {
        
        system.debug('receiptlist inside method size::::' + receiptlist.size());
        
        rowIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowIndex'));
        System.debug('row index be deleted ' + rowIndex + 'rows to be deleted ' + receiptlist[rowIndex]);
        del = receiptlist.remove(rowIndex);
        deletereceiptlist.add(del);
    }
    
    //Get Token from Quotation
    public PageReference getTokenAmount() {
        //system.debug('Selected Val' + selectedQuote);
        if (selectedQuote != null) {
            QuoteDetails = [SELECT id, Tandem_car_park_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c,Stack_Additional_1__c,Podium__c, Tandem_Open_Additional__c, Single_Open_Additional__c, Stack_Additional__c,Basement_Additional__c, Name, Booking__c, Allow_booking_without_full_token__c, Agreement_Value__c, Carpet_Area_Sq_Ft__c, Appartment_Configuration__c, Project__c, Service_Tax_On_Token_Amount__c,
                            Project_Unit__c, Token_Amount__c, ST_Token_Amount__c, Zone__c, Wing__c, Flat_Typology__c, FloorNo__c, Carpet_Area__c, No_of_parking__c, Parking_Type__c,Project__r.CEO__c, Puzzle_Car_Park__c,Stamp_duty_payable_by_Runwal__c,
                            Allotment_Premium_Agreement_Value__c, Agreement_Value_D__c, FlatNo__c, Level_One_Approver__c, Level_Two_Approver__c, Level_Three_Approver__c,Discount_9_Type__c,Discount_9_L__c, Quote_Status__c,Project_Unit__r.TowerName__c,Agreement_Value_for_brokers__c,Brokerage_Agreement_Value__c,Discount_10_Type__c,Discount_10_L__c,Discount_11_L__c,Discount_11_Type__c,Is_Special_Brokerage_Scheme__c,walkin_Source__c,Total_Car_Park_Amount__c,
                            Project_Unit__r.Token_Amount__c, Project_Unit__r.RW_Project__r.Token_Amount__c,/*Added by Prashant to add map development charges with booking.19-11-25...*/Development_Charges_L__c
                            FROM Quotation__c WHERE Id =: selectedQuote
                           ];
            
            //System.debug('Inside unitdetails'+unitDetails);
            if (QuoteDetails.size() > 0) {
                //System.Debug('Inside QuoteDetails' + QuoteDetails);
                boookingObj.Token_Amount__c = QuoteDetails[0].Token_Amount__c;
                //Anuja added on 29/12/15
                tokenamt = QuotationManagementServices1.INFormat(QuoteDetails[0].Token_Amount__c);
                boookingObj.Zone__c = QuoteDetails[0].Zone__c;
                boookingObj.Wing__c = QuoteDetails[0].Wing__c;
                boookingObj.Flat_Typology__c = QuoteDetails[0].Appartment_Configuration__c;
                boookingObj.Floor__c = QuoteDetails[0].FloorNo__c;
                boookingObj.Carpet_Area__c = QuoteDetails[0].Carpet_Area_Sq_Ft__c;
                boookingObj.No_of_parking__c = QuoteDetails[0].No_of_parking__c;
                boookingObj.Parking_Type__c = QuoteDetails[0].Parking_Type__c;
                boookingObj.Is_Special_Brokerage_Scheme__c =  QuoteDetails[0].Is_Special_Brokerage_Scheme__c;   //Added by Sheetal on 03/03/2023
                if(QuoteDetails[0].Development_Charges_L__c != null && QuoteDetails[0].Development_Charges_L__c != 0)
                	boookingObj.Development_Charge__c = QuoteDetails[0].Development_Charges_L__c; /*Added by Prashant to add map development charges with booking.19-11-25...*/
                
                
                if(QuoteDetails[0].Project_Unit__c  != Null){			//Added by Sheetal
                    boookingObj.Tower__c = QuoteDetails[0].Project_Unit__r.TowerName__c;
                }
                
                Date bookingDateAop = system.today();
                Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('AOP').getRecordTypeId();//Added by coServe 21-05-2024
                //AopList = [Select Id,name,Start_Date__c,End_Date__c,Category__c,Channel_Partner__c From AOP__c Where Channel_Partner__c =:optyList[0].RW_Walkin_Channel_Partner__c and  Start_Date__c <=: bookingDateAop and End_Date__c >=: bookingDateAop   ];//Commented by coServe 21-05-2024
                AopList = [Select Id,name,Start_Date__c,End_Date__c,Category__c,Channel_Partner__c,RecordTypeId From AOP__c Where Channel_Partner__c =:optyList[0].RW_Walkin_Channel_Partner__c and  Start_Date__c <=: bookingDateAop and End_Date__c >=: bookingDateAop and RecordTypeId =: recordTypeId  ];//Added by coServe 21-05-2024
                system.debug('AopList ::'+AopList);
                
                if(AopList.size() >0 && !AopList.isEmpty()){
                    system.debug('Inside if AopList ::::');
                    if(QuoteDetails[0].Quote_Status__c == 'Valid' && QuoteDetails[0].Discount_9_L__c == Null){
                        //system.debug('Inside if  ::::'); 
                        boookingObj.Is_AOP_CP_Applicable__c = true;
                        boookingObj.AOP_Scheme__c = AopList[0].id;
                        system.debug('Aop Applicable ::' +boookingObj.Is_AOP_CP_Applicable__c + 'Aop Scheme ::'+boookingObj.AOP_Scheme__c );
                        
                    }
                }
                /* if(optyList[0].RW_Walkin_Channel_Partner__r.AOP_CP__c && QuoteDetails[0].Quote_Status__c == 'Valid' && QuoteDetails[0].Discount_9_L__c == Null){
boookingObj.Is_AOP_CP_Applicable__c = true;
}*/
                
                if (QuoteDetails[0].Agreement_Value_D__c == 0) {
                    boookingObj.Allotment_Premium__c = QuoteDetails[0].Agreement_Value__c;
                } else {
                    boookingObj.Allotment_Premium__c = QuoteDetails[0].Agreement_Value_D__c;
                }
                if(QuoteDetails[0].Agreement_Value_for_brokers__c != 0 || QuoteDetails[0].Agreement_Value_for_brokers__c != Null){
                    //boookingObj.Agreement_Value_for_brokers__c = QuoteDetails[0].Agreement_Value_for_brokers__c;
                }
                
                boookingObj.Flat_No__c = QuoteDetails[0].FlatNo__c;
                boookingObj.Project__c = QuoteDetails[0].Project__c;
                boookingObj.Unit_No__c = QuoteDetails[0].Project_Unit__c;
                
                //Added by Prashant in order to flow Project Segment head to Booking Segment head(CEO)
                if(QuoteDetails[0].Project__r.CEO__c != null){
                    boookingObj.CEO__c = QuoteDetails[0].Project__r.CEO__c;
                }
                //System.Debug('Milestone1');
                boookingObj.Level_One_Approver__c = QuoteDetails[0].Level_One_Approver__c;
                boookingObj.Level_Two_Approver__c = QuoteDetails[0].Level_Two_Approver__c;
                boookingObj.Level_Three_Approver__c = QuoteDetails[0].Level_Three_Approver__c;
                // boookingObj.Sales_Manager_Approver__c = QuoteDetails[0].Owner;
                System.Debug('Milestone2');
                if (QuoteDetails[0].Service_Tax_On_Token_Amount__c == true) {
                    boookingObj.ST_Token_Amount__c = QuoteDetails[0].ST_Token_Amount__c;
                    //Anuja added on 29/12/15
                    STamt = QuotationManagementServices1.INFormat(QuoteDetails[0].ST_Token_Amount__c);
                } else {
                    
                    boookingObj.ST_Token_Amount__c = 0;
                }
                unitDetails = [SELECT id,Booking__c,Is_Booking_tagged__c FROM Project_Unit__c WHERE id =: QuoteDetails[0].Project_Unit__c];
                
                if (boookingObj.Opportunity__c != null && QuoteDetails[0].Project_Unit__c != null) {
                    le = QuotationManagementServices1.getLegalEntityDetails(boookingObj.Unit_No__c, boookingObj.Project__c);
                    //System.debug('leeeeeeee ' + le);
                    if (le != null) {
                        boookingObj.Stock__c = le.Account_Name_Flat_Cost__c;
                        boookingObj.Account_Number__c = String.valueOf(le.Account_Number_Flat_Cost__c);
                        boookingObj.Bank__c = le.Bank_Name_Flat_Cost__c;
                        boookingObj.IFSC_Code_Flat_Cost__c = le.IFSC_Code_Flat_Cost__c;
                        boookingObj.Account_Name_Service_Tax__c = le.Account_Name_Service_Tax__c;
                        boookingObj.Account_Number_Service_tax__c = String.ValueOf(le.Account_Number_Service_tax__c);
                        boookingObj.Bank_Name_Service_tax__c = le.Bank_Name_Service_tax__c;
                        boookingObj.IFSC_Code_Service_Tax__c = le.IFSC_Code_Service_Tax__c;
                    }
                }
                if(QuoteDetails[0].Discount_9_Type__c == 'CP Passback' && QuoteDetails[0].Quote_Status__c == 'Valid' && QuoteDetails[0].Discount_9_L__c != Null){  //Added by Sheetal
                    boookingObj.Passback_Amount__c = QuoteDetails[0].Discount_9_L__c;
                }
                else{
                    boookingObj.Passback_Amount__c = 0;
                }
                if(QuoteDetails[0].Discount_10_Type__c == 'Referral Passback' && QuoteDetails[0].Quote_Status__c == 'Valid' && QuoteDetails[0].Discount_10_L__c != Null){  //Added by Sheetal on 28/12/2022
                    boookingObj.Referral_Passback_Amount__c = QuoteDetails[0].Discount_10_L__c;
                }
                else{
                    boookingObj.Referral_Passback_Amount__c = 0;
                }
                if(QuoteDetails[0].Discount_11_Type__c == 'Referral' && QuoteDetails[0].Quote_Status__c == 'Valid' && QuoteDetails[0].Discount_11_L__c != Null){  //Added by Sheetal on 28/12/2022
                    boookingObj.Referral_Discount_Amount__c = QuoteDetails[0].Discount_11_L__c;
                }
                else{
                    boookingObj.Referral_Discount_Amount__c = 0;
                }
                
                if (QuoteDetails[0].Tandem_car_park_Additional__c != null) { ///tandem covered
                    
                    
                    TandemCOVEREDParkingList = [Select id, Parking__c, Status__c, Category__c, Booking__c, Name From Car_Parking_Charge__c where Parking__c =: 'Tandem Covered'
                                                and Status__c =: 'Vacant'
                                                and Category__c =: 'Additional'
                                                and Project__c =: boookingObj.Project__c
                                               ];
                    System.debug('TandemCOVEREDParkingList Size ..........)  ' + TandemCOVEREDParkingList.size());
                    
                }
                if (QuoteDetails[0].Tandem_Open_Additional__c != null) { ///tandem Open//Covered Stack
                    
                    TandemOPENParkingList = [Select id, Parking__c, Status__c, Category__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Covered Stack'
                                             and Status__c =: 'Vacant'
                                             and Category__c =: 'Additional'
                                             and Project__c =: boookingObj.Project__c
                                            ];
                    System.debug('TandemOPENParkingList Size ..........)  ' + TandemOPENParkingList.size());
                    
                }
                
                if (QuoteDetails[0].Single_car_park_Additional__c != null) { // single covered
                    SingleCOVEREDParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Single Covered'
                                                and Status__c =: 'Vacant'
                                                and Category__c =: 'Additional'
                                                and Project__c =: boookingObj.Project__c
                                               ];
                    System.debug('SingleCOVEREDParkingList Size ..........)  ' + SingleCOVEREDParkingList.size());
                    
                }
                
                if (QuoteDetails[0].Single_Open_Additional__c != null) { // single Open
                    SingleOPENParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Single Open'
                                             and Status__c =: 'Vacant'
                                             and Category__c =: 'Additional'
                                             and Project__c =: boookingObj.Project__c
                                            ];
                    System.debug('SingleOPENParkingList Size ..........)  ' + SingleOPENParkingList.size());
                    
                }
                if (QuoteDetails[0].Stack_Additional__c != null) { // Stack
                    STILTParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Stilt'
                                        and Status__c =: 'Vacant'
                                        and Category__c =: 'Additional'
                                        and Project__c =: boookingObj.Project__c
                                       ];
                    System.debug('STACKParkingList Size ..........)  ' + STILTParkingList.size());
                    
                }
                if (QuoteDetails[0].MLCP_Additional__c!= null) { // Stack
                    MLCPParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'MLCP'
                                       and Status__c =: 'Vacant'
                                       and Category__c =: 'Additional'
                                       and Project__c =: boookingObj.Project__c
                                      ];
                    System.debug('STACKParkingList Size ..........)  ' + MLCPParkingList.size());
                    
                }
                
                //Added by Payal 27/07/2021
                if (QuoteDetails[0].Basement_Additional__c!= null) { // Basement
                    BasementParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Basement'
                                           and Status__c =: 'Vacant'
                                           and Category__c =: 'Additional'
                                           and Project__c =: boookingObj.Project__c
                                          ];
                    System.debug('STACKParkingList Size ..........)  ' + BasementParkingList.size());
                    
                }
                //Added by Sheetal 10/11/2023
                if (QuoteDetails[0].Podium__c != null) { // Basement
                    PodiumParkingList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Podium'
                                         and Status__c =: 'Vacant'
                                         and Category__c =: 'Additional'
                                         and Project__c =: boookingObj.Project__c
                                        ];
                    System.debug('PodiumParkingList Size ..........)  ' + PodiumParkingList.size());
                    
                }
                
                //Added by Vinay 28-03-2025
                if (QuoteDetails[0].Puzzle_Car_Park__c != null) {
                    PuzzleCarParkList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Puzzle Car Park'
                                         and Status__c =: 'Vacant'
                                         and Category__c =: 'Additional'
                                         and Project__c =: boookingObj.Project__c
                                        ];
                    System.debug('PuzzleCarPark Size ..........)  ' + PuzzleCarParkList.size());
                    
                }
                if (QuoteDetails[0].Stack_Additional_1__c != null) { //Added by Vinay 21-11-2025
                    StackCarParkList = [Select id, Parking__c, Category__c, Status__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c =: 'Stack'
                                         and Status__c =: 'Vacant'
                                         and Category__c =: 'Additional'
                                         and Project__c =: boookingObj.Project__c
                                        ];
                    System.debug('StackCarPark Size ..........)  ' + StackCarParkList.size());
                    
                }
                
            }
            if (!Test.isRunningTest())
                getReceiptDetails();
        } else {
            boookingObj.Token_Amount__c = 0;
            boookingObj.ST_Token_Amount__c = 0;
        }
        return null;
    }
    //Get Receipt Using OptyId
    public PageReference getReceiptDetails() {
        TotalReceiptAmount = 0;
        STTotalReceiptAmount = 0;
        //system.debug('inside getReceiptDetails');
        try {
            ReceiptDetails = [SELECT id, Project_Unit__c, Project__c, Name, Cheque_DD_Date__c, DraweeBank__c, CreatedDate, LastModifiedDate, Token_Amount_Receipt__c, Due_Amount_Rs__c, Mode__c, Branch__c, Total_Amount__c,
                              Receipt_Date__c FROM Receipt__c WHERE Opportunity__c =: boookingObj.Opportunity__c and Token_Amount_Receipt__c = true And(Project_Unit__c = null OR Project_Unit__c =: unitId)
                             ]; //and Token_Amount_Receipt__c = true 
            if (ReceiptDetails.size() > 0) {
                //system.debug('Inside ReceiptDetails outside constructor');
                boookingObj.Booking_Date__c = ReceiptDetails[0].CreatedDate;
                boookingObj.Receipts__c = ReceiptDetails[0].id;
                for (Receipt__c rds: ReceiptDetails) {
                    TotalReceiptAmount = TotalReceiptAmount + rds.Total_Amount__c;
                    
                    if (rds.Project_Unit__c == null) {
                        rds.Project_Unit__c = QuoteDetails[0].Project_Unit__c;
                    }
                }
            } /*else {
boookingObj.Booking_Date__c = System.Now();
}*/
            
            // if Service tax is applicable for this project
            if (QuoteDetails.size() > 0 && QuoteDetails[0].Service_Tax_On_Token_Amount__c == true) {
                STReceiptDetails = [SELECT id, Project_Unit__c, Name, Cheque_DD_Date__c, DraweeBank__c, LastModifiedDate, Token_Amount_Receipt__c, Due_Amount_Rs__c, Mode__c, Branch__c, Total_Amount__c,
                                    Receipt_Date__c FROM Receipt__c WHERE Opportunity__c =: boookingObj.Opportunity__c and Token_Amount_ST__c = true And(Project_Unit__c = null OR Project_Unit__c =: unitId)
                                   ];
                if (STReceiptDetails.size() > 0) {
                    //system.debug('Inside STReceiptDetails outside constructor');
                    boookingObj.ServiceReceipt__c = STReceiptDetails[0].id;
                    for (Receipt__c strds: STReceiptDetails) {
                        STTotalReceiptAmount = STTotalReceiptAmount + strds.Total_Amount__c;
                        if (strds.Project_Unit__c == null) {
                            strds.Project_Unit__c = QuoteDetails[0].Project_Unit__c;
                        }
                    }
                }
            }
            
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            
        }
        
        return null;
    }
    
    public PageReference getaddressstatus() {
        
        //System.Debug('inside' + addressCheck);
        
        if (addressCheck == true) {
            addressCheckReverse = false;
        } else {
            addressCheckReverse = true;
        }
        return null;
        
    }
    
    public PageReference Save() {
        
        TotalServiceandToken = 0;
        i = 0;
        //Brokerage = 2.25;
        ////Anuja added on 7/1/16 ////////////////
        ///Tandem Covered////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && TandemCOVEREDParkingList.size() < QuoteDetails[0].Tandem_car_park_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of tandem covered parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        If(QuoteDetails != null && QuoteDetails.size() > 0 && QuoteDetails[0].No_of_parking__c > 0 && QuoteDetails[0].Total_Car_Park_Amount__c ==0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Car Parking amount is blank on quotation.');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i); 
        }
        
        ///tandem Open////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && TandemOPENParkingList.size() < QuoteDetails[0].Tandem_Open_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Covered Stack parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        ///Single Covered////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && SingleCOVEREDParkingList.size() < QuoteDetails[0].Single_car_park_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of single covered parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        ///Sigle Open////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && SingleOPENParkingList.size() < QuoteDetails[0].Single_Open_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of single open parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        ///Stack////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && STILTParkingList .size() < QuoteDetails[0].Stack_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Stilt parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        ///MLCP////
        if (QuoteDetails != null && QuoteDetails.size() > 0 && MLCPParkingList .size() < QuoteDetails[0].MLCP_Additional__c) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of MLCP parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        
        //Basement -- Added by Payal 27/07/2021 ///
        if (QuoteDetails != null && QuoteDetails.size() > 0 && BasementParkingList .size() < QuoteDetails[0].Basement_Additional__c) {
            //system.debug('BasementParkingList error');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Basement parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        //Podium -- Added by Sheetal 10/11/2023 ///
        if (QuoteDetails != null && QuoteDetails.size() > 0 && PodiumParkingList.size() < QuoteDetails[0].Podium__c) {
            system.debug('PodiumParkingList error');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Podium parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        
        //Puzzle Car Park -- Added by Vinay 28-03-2025
        if (QuoteDetails != null && QuoteDetails.size() > 0 && PuzzleCarParkList.size() < QuoteDetails[0].Puzzle_Car_Park__c) {
            system.debug('PuzzleCarParkList error');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Puzzle Car parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        //Stack Car Park -- Added by Vinay 21-11-2025
        if (QuoteDetails != null && QuoteDetails.size() > 0 && StackCarParkList.size() < QuoteDetails[0].Stack_Additional_1__c) {
            system.debug('StackCarParkList error');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Stack Car parking is unavailable');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
            
        }
        
        /////////////////////////////////////////////////////////////
        if (boookingObj.Opportunity__c == null) {
            system.debug('Inside null selected quote' + selectedQuote);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select an Opportunity');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        
        if(boookingObj.Booking_Date__c == null){//Added by Prashant.. //// 3-6-25.
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a valid Booking Date.');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (boookingObj.Booking_Date__c != null && boookingObj.Booking_Date__c > Datetime.now()) { // Added by coServe 16-05-2023
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Booking date should not be the future date');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        //Added by Prashant - 11-06-2025 Start
        //system.debug('optyList[0].Blocked_Date__c'+optyList[0].Blocked_Date__c);
        if (boookingObj.Booking_Date__c != null && optyList != null && optyList[0].Blocked_Date__c != null) { 
            Opportunity opp = [Select Id,Blocked_Date__c from Opportunity where Id =: optyList[0].Id];
            Date blockedDate = opp.Blocked_Date__c;
            String formattedDate = String.valueOf(blockedDate).substring(0, 10);
            if(boookingObj.Booking_Date__c < opp.Blocked_Date__c){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Booking date should not be less than Blocked date which is '+ formattedDate);
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        //Added by Prashant - 11-06-2025 End
        // Added by Vinay 17-01-2022 -- Start
        /*  if(dupflag == true && boookingObj.Brokerage__c == null){
if(boookingObj.RW_Project_Name__c == 'Runwal Gardens'){
//boookingObj.Brokerage__c = 2.25;
}else{
//boookingObj.Brokerage__c = 2;
}

//Project__c proj = [SELECT Id, Name, Brokerage__c FROM Project__c WHERE Id =: boookingObj.Project__c];
//boookingObj.Brokerage__c = proj.Brokerage__c;
update boookingObj;
}*/
        
        /* if(dupflag == true && boookingObj.Brokerage__c == null){     // Commented by Sheetal on 1/2/2023
System.debug('-- ' +i);
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Brokerage % Cannot Be Left Blank');
ApexPages.addMessage(myMsg);
i = 1; 
System.debug('--i: ' + i);
}*/
        // Added by Vinay 17-01-2022 -- End      
        
        // Commented by vinay 18-01-2022
        /*if(boookingObj.Brokerage__c == NULL || boookingObj.Brokerage__c != 2.25){   // Added by Sheetal on 14/01/2022
system.debug('Brokerage% error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Brokerage% should be 2.25');
ApexPages.addMessage(myMsg);
i = 1;
}*/
        /*  if (selectedQuote == '' || selectedQuote == null) {
system.debug('Inside null selected quote' + selectedQuote);
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select a quotation');
ApexPages.addMessage(myMsg);
i = 1;
System.debug('--i: ' + i);
}*/
        /*if(boookingObj.Application_No__c == '' || boookingObj.Application_No__c == null ){
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Application No. Cannot Be Left Blank');
ApexPages.addMessage(myMsg);
i=1;
}
*/
        if (boookingObj.Future_Correspondence_Contact__c == '' && boookingObj.Future_Correspondence_Contact__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Future Correspondence Contact Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (boookingObj.Future_Correspondence_Contact__c == 'Other') {
            if (boookingObj.Future_Correspondence_Contact_Name__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is Other Future Correspondence Name Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            
            if (boookingObj.Future_Correspondence_Contact_Phone__c == '' || boookingObj.Future_Correspondence_Contact_Phone__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is Other Future Correspondence Phone Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (boookingObj.Future_Correspondence_Contact_Email__c == '' || boookingObj.Future_Correspondence_Contact_Email__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is Other Future Correspondence Email Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (boookingObj.Future_Correspondence_Contact_Relation__c == '' || boookingObj.Future_Correspondence_Contact_Relation__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is Other Future Correspondence Relation Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        //////////////////Error Messages for Future Correspondence///////////////////////
        if (boookingObj.Future_Correspondence_Contact__c == '2nd Applicant') {
            
            if (applicant2.Name == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is (2nd Applicant) Applicant 2 Details Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (boookingObj.Future_Correspondence_Contact__c == '3rd Applicant') {
            
            if (applicant3.Name == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is (3rd Applicant) Applicant 3 Details Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (boookingObj.Future_Correspondence_Contact__c == '4th Applicant') {
            
            if (applicant4.Name == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is (4th Applicant) Applicant 4 Details Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (boookingObj.Future_Correspondence_Contact__c == '5th Applicant') {
            
            if (applicant5.Name == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Incase Future Correspondence Contact Is (5th Applicant) Applicant 5 Details Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        ////////////////////////// error messages for saales manager and sourcing manager  //////////////////////////
        if (boookingObj.Sales_Managers__c == '' || boookingObj.Sales_Managers__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Sales Mananger  Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (boookingObj.Sourcing_Mananger__c == '' || boookingObj.Sourcing_Mananger__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Sourcing Mananger Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        // if(dupflag == true && boookingObj.Brokerage__c == null){   
        /* ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Brokerage % Cannot Be Left Blank');
ApexPages.addMessage(myMsg);
i = 1; */
        //boookingObj.Brokerage__c = 2.25;      // Added by Sheetal on 13/01/2021
        //Brokerage =  boookingObj.Brokerage__c ;
        //update boookingObj;
        
        // }
        /*  if (boookingObj.Scheme_of_Customer1__c == '' || boookingObj.Scheme_of_Customer1__c == null) {
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Scheme of Customer Cannot Be Left Blank');
ApexPages.addMessage(myMsg);
i = 1;
System.debug('--i: ' + i);
}*/
        ////////////////////////// error messagess for applicant 1  //////////////////////////
        if (applicant.Salutation__c == '' || applicant.Salutation__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.First_Name__c == '' || applicant.First_Name__c == null) {
            system.debug('Inside null selected quote' + selectedQuote);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Last_Name__c == '' || applicant.Last_Name__c == null) {
            system.debug('Inside null selected quote' + selectedQuote);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.DOB__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        
        
        if (applicant.Permanent_Address_Line_1__c == '' || applicant.Permanent_Address_Line_1__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Country__c == 'India') {
            if (applicant.State__c == '' || applicant.State__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (applicant.City__c == '' || applicant.City__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Pincode__c == null || applicant.Pincode__c == 0) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Country__c == '' || applicant.Country__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Country__c == 'India' && applicant.Pincode__c != null) {
            if (String.valueOf(applicant.Pincode__c).length() != 6) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 1 Should Be Of 6 Digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (applicant.Mobile_Number__c == '' || applicant.Mobile_Number__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        
        
        system.debug('applicant.Mobile_Number__c'+ applicant.Mobile_Number__c);
        if(applicant.Mobile_Number__c!= null){
            system.debug('applicant.Mobile_Number__c.length'+ applicant.Mobile_Number__c.length());
        }
        
        //------ Validation updated by Priya for NRI customers -----//
        if (applicant.Mobile_Number__c != null && (applicant.Mobile_Number__c).length() != 10 && applicant.Subtype_Of_Applicant__c == 'Indian National') {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 1 Should be of 10 digits');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Email_Address__c == '' || applicant.Email_Address__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }else{ //Added by coServe 08-01-2024
            Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
            System.debug('dummyEmails: ' + dummys.keySet());
            for(String str : dummys.keySet()){
                if(applicant.Email_Address__c.contains(str) || str.contains(applicant.Email_Address__c)){
                    System.debug('Dummy Email1');
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 1. Please update correct Email id.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    break;
                }
            }
        }
        if (applicant.Nationality_Picklist__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Marital_Status__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Gender__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Type_Of_Applicant__c == '' || applicant.Type_Of_Applicant__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Subtype_Of_Applicant__c == '' || applicant.Subtype_Of_Applicant__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 1 Cannot Be Left Blank');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i: ' + i);
        }
        if (applicant.Subtype_Of_Applicant__c == 'Indian National') {
            if (applicant.Pancard__c == false 
                || applicant.Address_Proof__c == false 
                || String.isBlank(applicant.Address_Proof_Document__c)
                || String.isBlank(applicant.Address_Proof_Number__c)
                || String.isBlank(applicant.PancardNo__c)
                /* || applicant.One_Passport_Size_Color_Photograph__c == false */) {
                    
                    ApexPages.Message myMsg = new ApexPages.Message(
                        ApexPages.Severity.Error, 
                        'Please ensure that all the document checkboxes are checked and document details are filled properly.'
                    );
                    ApexPages.addMessage(myMsg);
                    
                    i = 1;
                    System.debug('--i: ' + i);
                }
            
            if (applicant.PancardNo__c != null && (applicant.PancardNo__c).length() != 10) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.Address_Proof_Number__c != null && !applicant.Address_Proof_Number__c.isAlphanumeric()) { // Added by coServe 15-05-2023
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            
        }
        if (applicant.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
            if (/*applicant.One_Passport_Size_Color_Photograph__c == false || */applicant.Funds_from_NRE_FCNR__c == false || applicant.Self_attested_copy_of_PIO_or_OCI_Card__c == false || applicant.Type_Of_Origin__c == '' || applicant.Origin_Details__c == '') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            
        }
        if (applicant.Subtype_Of_Applicant__c == 'For NRI') {
            if (applicant.Pancard__c == false /*|| applicant.One_Passport_Size_Color_Photograph__c == false*/ || applicant.PassportNumber__c == false || applicant.Funds_from_NRE_NRO__c == false || applicant.Copy_of_Workpermit_Employment_contract__c == false) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.PancardNo__c != null && (applicant.PancardNo__c).length() != 10) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        if (applicant.Subtype_Of_Applicant__c == 'For Company') {
            if (applicant.Pancard__c == false || applicant.Copy_of_Memorandu_of_Association__c == false || applicant.Certified_copy_of_Article_of_Association__c == false || applicant.Certified_copy_of_Board_Resolution__c == false || applicant.Certified_copy_of_ROC_Incorporation__c == false || applicant.Self_attested_List_of_Shareholders__c == false || applicant.Self_attested_List_of_Directors__c == false || applicant.PanCard_of_Authority_Signatory__c == false) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.PancardNo__c != null && (applicant.PancardNo__c).length() != 10) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            
        }
        if (applicant.Subtype_Of_Applicant__c == 'Partnership Firm') {
            if (applicant.Pancard__c == false || applicant.PanCard_of_Authority_Signatory__c == false || applicant.Certified_copy_of_Partnership_Deed__c == false || applicant.Certified_extract_of_Registration__c == false || applicant.Copy_of_Authorization_Letter_POA__c == false) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.PancardNo__c != null && (applicant.PancardNo__c).length() != 10) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        
        //anuja added on 16 dec 
        if (addressCheck == False) {
            
            if (applicant.Mailing_Address_Line_1__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.Mailing_Pincode__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Pincode for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.Mailing_Country__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Country for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant.Mailing_Country__c == 'India' && applicant.Mailing_Pincode__c != null) {
                if (String.valueOf(applicant.Mailing_Pincode__c).length() != 6) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 1 Should Be Of 6 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant.Mailing_Country__c == 'India') {
                if (applicant.Mailing_State__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 1 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant.Mailing_City__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 1 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
        }
        //////////////////////////////error messages for Applicant 2///////////////////////////
        if (applicant2.First_Name__c != null || applicant2.Last_Name__c != null) {
            if (string.isBlank(applicant2.Salutation__c)) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.First_Name__c == '' || applicant2.First_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Last_Name__c == '' || applicant2.Last_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.DOB__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Permanent_Address_Line_1__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Country__c == 'India') {
                if (applicant2.State__c == '' || applicant2.State__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 2 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant2.City__c == '' || applicant2.City__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Pincode__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Country__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Country__c == 'India' && applicant2.Pincode__c != null) {
                if (String.valueOf(applicant2.Pincode__c).length() != 6) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 2 Should Be Of 6 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant2.Mobile_Number__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            //------ Validation updated by Priya for NRI customers -----//
            if (applicant2.Mobile_Number__c != null && (applicant2.Mobile_Number__c).length() != 10 && applicant2.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 2 Should be of 10 digits');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Email_Address__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }else{ //Added by coServe 08-01-2024
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                System.debug('dummyEmails: ' + dummys.keySet());
                for(String str : dummys.keySet()){
                    if(applicant2.Email_Address__c.contains(str) || str.contains(applicant2.Email_Address__c)){
                        System.debug('Dummy Email1');
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 2. Please update correct Email id.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        break;
                    }
                }
            }
            if (applicant2.Nationality_Picklist__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Marital_Status__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Gender__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Type_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Subtype_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 2 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
                System.debug('--i: ' + i);
            }
            if (applicant2.Subtype_Of_Applicant__c == 'Indian National') {
                if (applicant2.Pancard__c == false || applicant2.Address_Proof__c == false || applicant2.Address_Proof_Document__c == '' || applicant2.Address_Proof_Number__c == '' /*|| applicant2.One_Passport_Size_Color_Photograph__c == false*/) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (applicant2.PancardNo__c != null && (applicant2.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (applicant2.Address_Proof_Number__c != null && !applicant2.Address_Proof_Number__c.isAlphanumeric()) { // Added by coServe 15-05-2023
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant2.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
                if (/*applicant2.One_Passport_Size_Color_Photograph__c == false || */applicant2.Funds_from_NRE_FCNR__c == false || applicant2.Self_attested_copy_of_PIO_or_OCI_Card__c == false || applicant2.Type_Of_Origin__c == '' || applicant2.Origin_Details__c == '') {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                
            }
            if (applicant2.Subtype_Of_Applicant__c == 'For NRI') {
                //if (applicant2.Pancard__c == false /*|| applicant2.One_Passport_Size_Color_Photograph__c == false*/ || applicant2.PassportNumber__c == false || applicant2.Funds_from_NRE_NRO__c == false || applicant2.Copy_of_Workpermit_Employment_contract__c == false   || String.isBlank(applicant2.Address_Proof_Number__c) || String.isBlank(applicant2.PancardNo__c)) { //Commented by Vinay 21-08-2025. There is deifference in the condition compared to applicant 1 & applicant 3 conditions.
                 if (applicant2.Pancard__c == false /*|| applicant2.One_Passport_Size_Color_Photograph__c == false*/ || applicant2.PassportNumber__c == false || applicant2.Funds_from_NRE_NRO__c == false || applicant2.Copy_of_Workpermit_Employment_contract__c == false) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        System.debug('--i: ' + i);
                    }
                if (applicant2.PancardNo__c != null && (applicant2.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant2.Subtype_Of_Applicant__c == 'For Company') {
                if (applicant2.Pancard__c == false || applicant2.Copy_of_Memorandu_of_Association__c == false || applicant2.Certified_copy_of_Article_of_Association__c == false || applicant2.Certified_copy_of_Board_Resolution__c == false || applicant2.Certified_copy_of_ROC_Incorporation__c == false || applicant2.Self_attested_List_of_Shareholders__c == false || applicant2.Self_attested_List_of_Directors__c == false || applicant2.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (applicant2.PancardNo__c != null && (applicant2.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant2.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (applicant2.Pancard__c == false || applicant2.PanCard_of_Authority_Signatory__c == false || applicant2.Certified_copy_of_Partnership_Deed__c == false || applicant2.Certified_extract_of_Registration__c == false || applicant2.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (applicant2.PancardNo__c != null && (applicant2.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            //anuja added on 16 dec  
            if (addressCheckApplicant2 == False) {
                
                if (applicant2.Mailing_Address_Line_1__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 2 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    //System.debug('--i: ' + i);
                }
                if (applicant2.Mailing_Pincode__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Pincode for Applicant 2 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    //System.debug('--i: ' + i);
                }
                if (applicant2.Mailing_Country__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Country for Applicant 2 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    //System.debug('--i: ' + i);
                }
                if (applicant2.Mailing_Country__c == 'India' && applicant2.Mailing_Pincode__c != null) {
                    if (String.valueOf(applicant2.Mailing_Pincode__c).length() != 6) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 2 Should Be Of 6 Digits');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        //System.debug('--i: ' + i);
                    }
                }
                if (applicant2.Mailing_Country__c == 'India') {
                    if (applicant2.Mailing_State__c == null) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 2 Cannot Be Left Blank');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        //System.debug('--i: ' + i);
                    }
                }
                if (applicant2.Mailing_City__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 2 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    //System.debug('--i: ' + i);
                }
            }
        }
        
        //////////////////////////////error messages for Applicant 3///////////////////////////
        if (applicant3.First_Name__c != null || applicant3.Last_Name__c != null) {
            
            if (applicant3.Salutation__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.First_Name__c == '' || applicant3.First_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Last_Name__c == '' || applicant3.Last_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.DOB__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Permanent_Address_Line_1__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Country__c == 'India') {
                if (applicant3.State__c == '' || applicant3.State__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 3 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant3.City__c == '' || applicant3.City__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Pincode__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Country__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Country__c == 'India' && applicant3.Pincode__c != null) {
                if (String.valueOf(applicant3.Pincode__c).length() != 6) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 3 Should Be Of 6 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant3.Mobile_Number__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            //------ Validation updated by Priya for NRI customers -----//
            if (applicant3.Mobile_Number__c != null && (applicant3.Mobile_Number__c).length() != 10 && applicant3.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 3 Should be of 10 digits');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Email_Address__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }else{ //Added by coServe 08-01-2024
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                System.debug('dummyEmails: ' + dummys.keySet());
                for(String str : dummys.keySet()){
                    if(applicant3.Email_Address__c.contains(str) || str.contains(applicant3.Email_Address__c)){
                        System.debug('Dummy Email1');
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 3. Please update correct Email id.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        break;
                    }
                }
            }
            if (applicant3.Nationality_Picklist__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Marital_Status__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Gender__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Type_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Subtype_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 3 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant3.Subtype_Of_Applicant__c == 'Indian National') {
                if (applicant3.Pancard__c == false || applicant3.Address_Proof__c == false || applicant3.Address_Proof_Document__c == '' || applicant3.Address_Proof_Number__c == '' /*|| applicant3.One_Passport_Size_Color_Photograph__c == false*/  || String.isBlank(applicant3.Address_Proof_Number__c)
                    || String.isBlank(applicant3.PancardNo__c)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                if (applicant3.PancardNo__c != null && (applicant3.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.Address_Proof_Number__c != null && !applicant3.Address_Proof_Number__c.isAlphanumeric()) { // Added by coServe 15-05-2023
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant3.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
                if (/*applicant3.One_Passport_Size_Color_Photograph__c == false || */applicant3.Funds_from_NRE_FCNR__c == false || applicant3.Self_attested_copy_of_PIO_or_OCI_Card__c == false || applicant3.Type_Of_Origin__c == '' || applicant3.Origin_Details__c == '') {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            if (applicant3.Subtype_Of_Applicant__c == 'For NRI') {
                if (applicant3.Pancard__c == false/* || applicant3.One_Passport_Size_Color_Photograph__c == false*/ || applicant3.PassportNumber__c == false || applicant3.Funds_from_NRE_NRO__c == false || applicant3.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.PancardNo__c != null && (applicant3.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant3.Subtype_Of_Applicant__c == 'For Company') {
                if (applicant3.Pancard__c == false || applicant3.Copy_of_Memorandu_of_Association__c == false || applicant3.Certified_copy_of_Article_of_Association__c == false || applicant3.Certified_copy_of_Board_Resolution__c == false || applicant3.Certified_copy_of_ROC_Incorporation__c == false || applicant3.Self_attested_List_of_Shareholders__c == false || applicant3.Self_attested_List_of_Directors__c == false || applicant3.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.PancardNo__c != null && (applicant3.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant3.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (applicant3.Pancard__c == false || applicant3.PanCard_of_Authority_Signatory__c == false || applicant3.Certified_copy_of_Partnership_Deed__c == false || applicant3.Certified_extract_of_Registration__c == false || applicant3.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.PancardNo__c != null && (applicant3.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            
            //anuja added on 16 dec  
            if (addressCheckApplicant3 == False) {
                
                if (applicant3.Mailing_Address_Line_1__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 3 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.Mailing_Pincode__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Pincode for Applicant 3 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.Mailing_Country__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Country for Applicant 3 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.Mailing_Country__c == 'India' && applicant3.Mailing_Pincode__c != null) {
                    if (String.valueOf(applicant3.Mailing_Pincode__c).length() != 6) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 3 Should Be Of 6 Digits');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant3.Mailing_Country__c == 'India') {
                    if (applicant3.Mailing_State__c == null) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 3 Cannot Be Left Blank');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant3.Mailing_City__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 3 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
        }
        //////////////////////////////error messages for Applicant 4///////////////////////////
        if (applicant4.First_Name__c != null || applicant4.Last_Name__c != null) {
            
            if (applicant4.Salutation__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.First_Name__c == '' || applicant4.First_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Last_Name__c == '' || applicant4.Last_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.DOB__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Permanent_Address_Line_1__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Country__c == 'India') {
                if (applicant4.State__c == '' || applicant4.State__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 4 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant4.City__c == '' || applicant4.City__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Pincode__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Country__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Country__c == 'India' && applicant4.Pincode__c != null) {
                if (String.valueOf(applicant4.Pincode__c).length() != 6) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 4 Should Be Of 6 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant4.Mobile_Number__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            //------ Validation updated by Priya for NRI customers -----//
            if (applicant4.Mobile_Number__c != null && (applicant4.Mobile_Number__c).length() != 10 && applicant4.Subtype_Of_Applicant__c == 'Indian National' ) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 4 Should be of 10 digits');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Email_Address__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }else{ //Added by coServe 08-01-2024
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                System.debug('dummyEmails: ' + dummys.keySet());
                for(String str : dummys.keySet()){
                    if(applicant4.Email_Address__c.contains(str) || str.contains(applicant4.Email_Address__c)){
                        System.debug('Dummy Email1');
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 4. Please update correct Email id.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        break;
                    }
                }
            }
            if (applicant4.Nationality_Picklist__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Marital_Status__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Gender__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Type_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Subtype_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 4 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant4.Subtype_Of_Applicant__c == 'Indian National') {
                if (applicant4.Pancard__c == false || applicant4.Address_Proof__c == false || applicant4.Address_Proof_Document__c == '' || applicant4.Address_Proof_Number__c == ''/* || applicant4.One_Passport_Size_Color_Photograph__c == false*/   || String.isBlank(applicant4.Address_Proof_Number__c)
                    || String.isBlank(applicant4.PancardNo__c)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                if (applicant4.PancardNo__c != null && (applicant4.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.Address_Proof_Number__c != null && !applicant4.Address_Proof_Number__c.isAlphanumeric()) { // Added by coServe 15-05-2023
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
            }
            if (applicant4.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
                if (/*applicant4.One_Passport_Size_Color_Photograph__c == false ||*/ applicant4.Funds_from_NRE_FCNR__c == false || applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c == false || applicant4.Type_Of_Origin__c == '' || applicant4.Origin_Details__c == '') {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            if (applicant4.Subtype_Of_Applicant__c == 'For NRI') {
                if (applicant4.Pancard__c == false /*|| applicant4.One_Passport_Size_Color_Photograph__c == false*/ || applicant4.PassportNumber__c == false || applicant4.Funds_from_NRE_NRO__c == false || applicant4.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.PancardNo__c != null && (applicant4.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant4.Subtype_Of_Applicant__c == 'For Company') {
                if (applicant4.Pancard__c == false || applicant4.Copy_of_Memorandu_of_Association__c == false || applicant4.Certified_copy_of_Article_of_Association__c == false || applicant4.Certified_copy_of_Board_Resolution__c == false || applicant4.Certified_copy_of_ROC_Incorporation__c == false || applicant4.Self_attested_List_of_Shareholders__c == false || applicant4.Self_attested_List_of_Directors__c == false || applicant4.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant3.PancardNo__c != null && (applicant4.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant4.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (applicant4.Pancard__c == false || applicant4.PanCard_of_Authority_Signatory__c == false || applicant4.Certified_copy_of_Partnership_Deed__c == false || applicant4.Certified_extract_of_Registration__c == false || applicant4.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.PancardNo__c != null && (applicant4.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            //anuja added on 16 dec  
            if (addressCheckApplicant4 == False) {
                
                if (applicant4.Mailing_Address_Line_1__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 4 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.Mailing_Pincode__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Pincode for Applicant 4 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.Mailing_Country__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Country for Applicant 4 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant4.Mailing_Country__c == 'India' && applicant4.Mailing_Pincode__c != null) {
                    if (String.valueOf(applicant4.Mailing_Pincode__c).length() != 6) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 4 Should Be Of 6 Digits');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant4.Mailing_Country__c == 'India') {
                    if (applicant4.Mailing_State__c == null) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 4 Cannot Be Left Blank');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant4.Mailing_City__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 4 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
        }
        //////////////////////////////error messages for Applicant 5///////////////////////////
        if (applicant5.First_Name__c != null || applicant5.Last_Name__c != null) {
            if (applicant5.Salutation__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.First_Name__c == '' || applicant5.First_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Last_Name__c == '' || applicant5.Last_Name__c == null) {
                system.debug('Inside null selected quote' + selectedQuote);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            
            if (applicant5.DOB__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Permanent_Address_Line_1__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Country__c == 'India') {
                if (applicant5.State__c == '' || applicant5.State__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 5 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant5.City__c == '' || applicant5.City__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Pincode__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Country__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Country__c == 'India' && applicant5.Pincode__c != null) {
                if (String.valueOf(applicant5.Pincode__c).length() != 6) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 5 Should Be Of 6 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            if (applicant5.Mobile_Number__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            //------ Validation updated by Priya for NRI customers -----//
            if (applicant5.Mobile_Number__c != null && (applicant5.Mobile_Number__c).length() != 10 && applicant5.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 5 Should be of 10 digits');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Email_Address__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }else{ //Added by coServe 08-01-2024
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                System.debug('dummyEmails: ' + dummys.keySet());
                for(String str : dummys.keySet()){
                    if(applicant5.Email_Address__c.contains(str) || str.contains(applicant5.Email_Address__c)){
                        System.debug('Dummy Email1');
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 5. Please update correct Email id.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                        break;
                    }
                }
            }
            if (applicant5.Nationality_Picklist__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Marital_Status__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Gender__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Type_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Subtype_Of_Applicant__c == null) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 5 Cannot Be Left Blank');
                ApexPages.addMessage(myMsg);
                i = 1;
            }
            if (applicant5.Subtype_Of_Applicant__c == 'Indian National') {
                if (applicant5.Pancard__c == false || applicant5.Address_Proof__c == false || applicant5.Address_Proof_Document__c == '' || applicant5.Address_Proof_Number__c == '' /*|| applicant5.One_Passport_Size_Color_Photograph__c == false*/  || String.isBlank(applicant5.Address_Proof_Number__c)
                    || String.isBlank(applicant5.PancardNo__c)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                if (applicant5.PancardNo__c != null && (applicant5.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.Address_Proof_Number__c != null && !applicant5.Address_Proof_Number__c.isAlphanumeric()) { // Added by coServe 15-05-2023
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                
            }
            if (applicant5.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
                if (/*applicant5.One_Passport_Size_Color_Photograph__c == false || */applicant5.Funds_from_NRE_FCNR__c == false || applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c == false || applicant5.Type_Of_Origin__c == '' || applicant5.Origin_Details__c == '') {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            if (applicant5.Subtype_Of_Applicant__c == 'For NRI') {
                if (applicant5.Pancard__c == false /* || applicant5.One_Passport_Size_Color_Photograph__c == false */ || applicant5.PassportNumber__c == false || applicant5.Funds_from_NRE_NRO__c == false || applicant5.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.PancardNo__c != null && (applicant5.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            if (applicant5.Subtype_Of_Applicant__c == 'For Company') {
                if (applicant5.Pancard__c == false || applicant5.Copy_of_Memorandu_of_Association__c == false || applicant5.Certified_copy_of_Article_of_Association__c == false || applicant5.Certified_copy_of_Board_Resolution__c == false || applicant5.Certified_copy_of_ROC_Incorporation__c == false || applicant5.Self_attested_List_of_Shareholders__c == false || applicant5.Self_attested_List_of_Directors__c == false || applicant5.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.PancardNo__c != null && (applicant5.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            if (applicant5.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (applicant5.Pancard__c == false || applicant5.PanCard_of_Authority_Signatory__c == false || applicant5.Certified_copy_of_Partnership_Deed__c == false || applicant5.Certified_extract_of_Registration__c == false || applicant5.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.PancardNo__c != null && (applicant5.PancardNo__c).length() != 10) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                
            }
            //anuja added on 16 dec  
            if (addressCheckApplicant5 == False) {
                
                if (applicant5.Mailing_Address_Line_1__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 5 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.Mailing_Pincode__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Pincode for Applicant 5 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.Mailing_Country__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing  Country for Applicant 5 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
                if (applicant5.Mailing_Country__c == 'India' && applicant5.Mailing_Pincode__c != null) {
                    if (String.valueOf(applicant5.Mailing_Pincode__c).length() != 6) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 5 Should Be Of 6 Digits');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant5.Mailing_Country__c == 'India') {
                    if (applicant5.Mailing_State__c == null) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 5 Cannot Be Left Blank');
                        ApexPages.addMessage(myMsg);
                        i = 1;
                    }
                }
                if (applicant5.Mailing_City__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 5 Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
        }
        
        //////////////////////////////////////Added BY Aniket Starts Here on 29-09-2022/////////////////////////////////////////
        //
        //
        //
        
        ////Added by Prashant to add the brokerage % on bookings in case the booking is created before the scheme creation - 12-2-25///Start// This logic is also added in DigitalBookingController cls on line 425,2173
        ////If there's any changes here please change the same there as well.
        //////////////////////////////////////Added BY Aniket Starts Here on 29-09-2022/////////////////////////////////////////
        Date bookingDate = Date.ValueOf(boookingObj.Booking_Date__c);
        Date bookingDate2 = Date.ValueOf('2024-04-01T06:00:00.000Z');
        
        //Added by Prashant to tag the scheme based on the booking date. START 9-4-25////
        system.debug('bookingDate::'+bookingDate);
        //Added by Prashant to prioritize the schemes that will be tagged on booking which has tower in it.//START - 13-01-25
        List<Scheme_Configuration__c> sctemp1 = new List<Scheme_Configuration__c>(); 
        system.debug('sc ----->>>> '+sc);
        List<Scheme_Configuration__c>sctemp = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c,Brokerage_Scheme__r.Start_Date__c from Scheme_Configuration__c where ((Project__c =:boookingObj.Project__c and Tower__c =:boookingObj.Tower__c) OR (Project__c =:boookingObj.Project__c and Tower__c =:null)) and (Type__c =: boookingObj.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true and Brokerage_Scheme__r.Start_Date__c <=: bookingDate];
        //sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c where ((Project__c =:boookingObj.Project__c and Tower__c =:boookingObj.Tower__c) OR (Project__c =:boookingObj.Project__c and Tower__c =:null)) and (Type__c =: boookingObj.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
        //list<Scheme_Configuration__c> sctemp1 = new List<Scheme_Configuration__c>();
        system.debug('scheme  ->> '+sctemp);
        if(!sctemp.isEmpty()){
            system.debug('Inside sctemp');
            system.debug('sc ----->>>> '+sc);
            for (Scheme_Configuration__c sci : sctemp) {   
                system.debug('scheme Id ->> '+sci.Brokerage_Scheme__c);
                system.debug('scheme start date ->> '+sci.Brokerage_Scheme__r.Start_Date__c);
                if (sci.Tower__c != null) {                        
                    sc.add(sci);                         
                    break;                         
                }                    
            }                
            if (sc.isEmpty()) {                    
                sc.add(sctemp[0]);                    
            }                
        }       
        //Added by Prashant to prioritize the schemes that will be tagged on booking which has tower in it.//END - 13-01-25
        if(!sc.isEmpty()){
            system.debug('sc ----->>>> '+sc);
            if(QuoteDetails[0].walkin_Source__c == 'Channel Partner' || QuoteDetails[0].walkin_Source__c == 'Temp Channel Partner'){
                system.debug('Inside Booking date >= scheme start date');
                brokerageScheme = [select Id,Name,Base_Brokerage__c,Base_Brokerage_for_OS_NRI__c,Type__c,Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_NRI__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                   Start_Date__c <=: bookingDate and (End_Date__c = null or End_Date__c >=: bookingDate) and Approval_Status__c = 'Approved by Level 2'];
                
                system.debug('brokerageScheme::'+brokerageScheme);
            }
            
        }
        
        if(sc.isEmpty()){
            system.debug('Inside sc empty ----->>>> ');
            sctemp1 = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c,Brokerage_Scheme__r.Start_Date__c from Scheme_Configuration__c where 
                       ((Project__c =:boookingObj.Project__c and Tower__c =:boookingObj.Tower__c) OR 
                        (Project__c =:boookingObj.Project__c and Tower__c =:null)) and 
                       (Type__c =: boookingObj.Type_of_Client__c OR Type__c =: 'Both') and 
                       Brokerage_Scheme__r.Approval_Status__c = 'Approved by Level 2' and 
                       Active__c = false and Brokerage_Scheme__r.Start_Date__c <=: bookingDate and (Brokerage_Scheme__r.End_Date__c = null or Brokerage_Scheme__r.End_Date__c >=: bookingDate) order by Brokerage_Scheme__r.End_Date__c];
            if(!sctemp1.isEmpty()){                
                for (Scheme_Configuration__c sci : sctemp1) {                    
                    if (sci.Tower__c != null) {                        
                        sc.add(sci);                         
                        break;                         
                    }                    
                }                
                if (sc.isEmpty() && !sctemp1.isEmpty()) {
                    sc.add(sctemp1[0]);
                }
                
            } 
            system.debug('sc ----->>>> '+sc);
            if(!sc.isEmpty()){
                if(QuoteDetails[0].walkin_Source__c == 'Channel Partner' || QuoteDetails[0].walkin_Source__c == 'Temp Channel Partner'){
                    system.debug('Inside Booking date <= scheme start date');
                    brokerageScheme = [select Id,Name,Base_Brokerage__c,Base_Brokerage_for_OS_NRI__c,Type__c,Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_NRI__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                       Approval_Status__c = 'Approved by Level 2'];
                    system.debug('brokerageScheme::'+brokerageScheme);
                }
            }
        }
        
        system.debug('Scheme configuration ----->>>> '+sc);
        system.debug('Brokerage scheme ----->>>> '+brokerageScheme);
        
     /*   if(QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].walkin_Source__c == 'Channel Partner'){

//Added by Prashant to compress code for this cls. // START 9-7-25

system.debug('Base Brokerage Before -->>'+boookingObj.Base_Brokerage__c);

boookingObj = BookingClass2.updateBrokerageSchemeDetails(boookingObj, QuoteDetails, brokerageScheme, bookingDate, bookingDate2);

system.debug('Base Brokerage After -->>'+boookingObj.Base_Brokerage__c);*/

//Added by Prashant to compress code for this cls. // END 9-7-25
        
        /* if(QuoteDetails != null && !QuoteDetails.isEmpty() &&  (QuoteDetails[0].walkin_Source__c == 'Channel Partner' || QuoteDetails[0].walkin_Source__c == 'Temp Channel Partner') ){
            
            // if(QuoteDetails[0].Agreement_Value_for_brokers__c != 0 || QuoteDetails[0].Agreement_Value_for_brokers__c != Null)
            
            if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Local'  ){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate < bookingDate2){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }
            
            else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate >= bookingDate2){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }
            
            else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'Local' || boookingObj.Type_of_Client__c == 'Corporate' )){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'NRI' || boookingObj.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }
            
            else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'NRI' || boookingObj.Type_of_Client__c == 'Outstation') && bookingDate >= bookingDate2){
                
                boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                
                boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                
                boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                
                boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                
            }
        } */
        //Added by Prashant to tag the scheme based on the booking date. END 9-4-25////
        //
        //

        //Added by Prashant to update logic to add scheme brokerage based on type of client - 22-10-25. START///////
        system.debug('Base Brokerage Before -->>'+boookingObj.Base_Brokerage__c);
        boookingObj = BookingClass2.updateBrokerageSchemeDetails(boookingObj, QuoteDetails, brokerageScheme);
        system.debug('Base Brokerage After -->>'+boookingObj.Base_Brokerage__c);
        //Added by Prashant to update logic to add scheme brokerage based on type of client - 22-10-25. END///////

        
        
        
        //////////////////////////////////////Added BY Aniket Ends Here on 29-09-2022////////////////////////////////////////
        //////////////////////////////////////Receipt Mandatory Checks//////////////////////////////////////////
        system.debug('ReceiptDetails.size():::: ' + ReceiptDetails.size());
        if (ReceiptDetails.size() == 0 && STReceiptDetails.size()==0) {
            System.Debug('insert receipt ' + ReceiptObj);
            System.Debug('receiptlist.size() ' + receiptlist.size());
            
            
            System.Debug('--receiptlist :' + receiptlist);
            for(Receipt__c rce : receiptlist)
            {
                system.debug('inside for loop');
                if (rce.Mode__c== null) //
                {
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Instrument Of Receipt Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (rce.Cheque_DD__c== null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Instrument number Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (rce.Cheque_DD_Date__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Date Of Receipt Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                if (rce.Total_Amount__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Amount Of Receipt Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                else{
                    //TotalReceiptAmount = receiptlist[0].Total_Amount__c;
                    TotalServiceandToken= TotalServiceandToken + rce.Total_Amount__c;
                }
                if (rce.DraweeBank__c == null) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Bank Of Receipt Cannot Be Left Blank');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                    System.debug('--i: ' + i);
                }
                
                
            }
            
            System.debug('Step oneeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee');
            //Checking token amount for all //
            Map < String, Decimal > taxSlabMap = QuotationManagementServices1.getTaxSlabs();
            Decimal TDSAmount = 0;
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && taxSlabMap.containsKey('TDS')) {
                
                TDSAMount = ((taxSlabMap.get('TDS') * boookingObj.Token_Amount__c) / 100).setscale(0, RoundingMode.HALF_UP);
            }
            System.debug('TDS Amount:' + TDSAmount + 'on token Amount:' + boookingObj.Token_Amount__c);
            if (boookingObj.Token_Amount__c != null && boookingObj.ST_Token_Amount__c != null) {
                TotalQuoteToken = boookingObj.ST_Token_Amount__c + (boookingObj.Token_Amount__c - TDSAmount);
                TotalToken = TotalServiceandToken;
                
                /*if (QuoteDetails != null && QuoteDetails.size() > 0 && QuoteDetails[0].Allow_booking_without_full_token__c == False && TotalToken < TotalQuoteToken ) {
System.debug('Step threeeeeeeeee');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total  Token Amount cannot be less than ' + QuotationManagementServices1.Informat(TotalQuoteToken));
ApexPages.addMessage(myMsg);
i=1;
}
*/
            }
            
        }
        
        ///////////////////Inserting Future correspondance contact////////////////////  
        if (boookingObj.Future_Correspondence_Contact__c == '1st Applicant') {
            if (applicant.Name != null) {
                boookingObj.Future_Correspondence_Contact_Name__c = applicant.Name;
            }
            if (applicant.Mobile_Number__c != null) {
                boookingObj.Future_Correspondence_Contact_Phone__c = applicant.Mobile_Number__c;
            }
            if (applicant.Email_Address__c != null) {
                boookingObj.Future_Correspondence_Contact_Email__c = applicant.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '1st Applicant';
            
        }
        if (boookingObj.Future_Correspondence_Contact__c == '2nd Applicant') {
            if (applicant2.Name != null) {
                boookingObj.Future_Correspondence_Contact_Name__c = applicant2.Name;
            }
            if (applicant2.Mobile_Number__c != null) {
                boookingObj.Future_Correspondence_Contact_Phone__c = applicant2.Mobile_Number__c;
            }
            if (applicant2.Email_Address__c != null) {
                boookingObj.Future_Correspondence_Contact_Email__c = applicant2.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '2nd Applicant';
        }
        if (boookingObj.Future_Correspondence_Contact__c == '3rd Applicant') {
            if (applicant3.Name != null) {
                boookingObj.Future_Correspondence_Contact_Name__c = applicant3.Name;
            }
            if (applicant3.Mobile_Number__c != null) {
                boookingObj.Future_Correspondence_Contact_Phone__c = applicant3.Mobile_Number__c;
            }
            if (applicant3.Email_Address__c != null) {
                boookingObj.Future_Correspondence_Contact_Email__c = applicant3.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '3rd Applicant';
        }
        if (boookingObj.Future_Correspondence_Contact__c == '4th Applicant') {
            if (applicant4.Name != null) {
                boookingObj.Future_Correspondence_Contact_Name__c = applicant4.Name;
            }
            if (applicant4.Mobile_Number__c != null) {
                boookingObj.Future_Correspondence_Contact_Phone__c = applicant4.Mobile_Number__c;
            }
            if (applicant4.Email_Address__c != null) {
                boookingObj.Future_Correspondence_Contact_Email__c = applicant4.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '4th Applicant';
        }
        if (boookingObj.Future_Correspondence_Contact__c == '5th Applicant') {
            if (applicant5.Name != null) {
                boookingObj.Future_Correspondence_Contact_Name__c = applicant5.Name;
            }
            if (applicant5.Mobile_Number__c != null) {
                boookingObj.Future_Correspondence_Contact_Phone__c = applicant5.Mobile_Number__c;
            }
            if (applicant5.Email_Address__c != null) {
                boookingObj.Future_Correspondence_Contact_Email__c = applicant5.Email_Address__c;
            }
            boookingObj.Future_Correspondence_Contact_Relation__c = '5th Applicant';
        }
        ///////////////////Inserting Future correspondance contact Endss here////////////////////     
        /*listglobalcharges = [SELECT Id, Name from Project_Charges__c where Name = 'Basic'
and Project__c =: boookingObj.Project__c LIMIT 1
];
System.Debug('listglobalcharges' + listglobalcharges);*/
        //inserting the receipt
        System.debug('iiiiiiiiiiiiiiiiiii TOKEN ' + i);
        boookingObj.Quotation__c = selectedQuote;
        
        //added by shailesh
        if (i == 0  || Test.isRunningTest()) {
            Decimal totalAmount = 0; //Added by Vinay 14-08-2025
            for (Receipt__c ListRct: receiptlist) {
                Receipt__c receiptOBJTobeUpdate = new Receipt__c();
                receiptOBJTobeUpdate.Mode__c = ListRct.Mode__c;
                receiptOBJTobeUpdate.Cheque_DD__c = ListRct.Cheque_DD__c;
                receiptOBJTobeUpdate.Token_Amount_ST__c = ListRct.Token_Amount_ST__c;
                receiptOBJTobeUpdate.Cheque_DD_Date__c = ListRct.Cheque_DD_Date__c;
                receiptOBJTobeUpdate.Total_Amount__c = ListRct.Total_Amount__c;
                receiptOBJTobeUpdate.Currency__c = 'Indian Rupee';
                receiptOBJTobeUpdate.DraweeBank__c = ListRct.DraweeBank__c;
                //receiptOBJTobeUpdate.Drawee_Bank_If_Others__c = ListRct.Drawee_Bank_If_Others__c;
                
                receiptOBJTobeUpdate.Opportunity__c = boookingObj.Opportunity__c;
                receiptOBJTobeUpdate.Project__c = boookingObj.Project__c;
                receiptOBJTobeUpdate.Project_Unit__c = boookingObj.Unit_No__c;
                receiptOBJTobeUpdate.Receipt_Date__c = system.today();
                receiptOBJTobeUpdate.Cheque_DD_Amount_Rs__c = ListRct.Total_Amount__c;
                receiptOBJTobeUpdate.On_Account_Money__c = ListRct.Total_Amount__c;
                receiptOBJTobeUpdate.Amount_Rs__c = ListRct.Total_Amount__c;
                receiptOBJTobeUpdate.Opportunity_Email_Id__c = applicant.Email_Address__c;
                
                totalAmount += (ListRct.Total_Amount__c != null)? ListRct.Total_Amount__c : 0; //Added by Vinay 14-08-2025

                if (ListRct.Token_Amount_ST__c == True) {
                    //system.debug('inside service tax true' + receiptlist[i].Id);
                    receiptOBJTobeUpdate.Token_Amount_Receipt__c = False;
                    receiptOBJTobeUpdate.Drawn_in_favour_of__c = boookingObj.Account_Name_Service_Tax__c + ' | ' + boookingObj.Account_Number_Service_tax__c;
                    
                } else {
                    receiptOBJTobeUpdate.Token_Amount_Receipt__c = True;
                    receiptOBJTobeUpdate.Drawn_in_favour_of__c = boookingObj.Stock__c + ' | ' + boookingObj.Account_Number__c;
                    
                }
                if (receiptOBJTobeUpdate.Total_Amount__c != null && receiptOBJTobeUpdate.Mode__c != null)
                    ReceiptLstTobeUpdate.add(receiptOBJTobeUpdate);
            }

            Decimal requiredTokenAmount = QuoteDetails[0].Project_Unit__r.Token_Amount__c != null ? QuoteDetails[0].Project_Unit__r.Token_Amount__c : QuoteDetails[0].Project_Unit__r.RW_Project__r.Token_Amount__c; //Added by Vinay 14-08-2025
            if(totalAmount < requiredTokenAmount){ //Added by Vinay 14-08-2025
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total Amount is less than the Token Amount, you cannot book this unit.  Token Amount is:'+requiredTokenAmount);
                ApexPages.addMessage(myMsg); 
                i = 1;
                return null;
            }
            
            try {
                if (!ReceiptLstTobeUpdate.isEmpty()) {
                    insert ReceiptLstTobeUpdate;
                }
            } catch (DmlException e) {
                System.debug('An error has occured. Please contact your administrator. : ' + e.getMessage());
                
            }
            
            for (Receipt__c rcd: ReceiptLstTobeUpdate) {
                if (rcd.Token_Amount_ST__c == True) {
                    boookingObj.ServiceReceipt__c = rcd.id;
                } else {
                    boookingObj.Receipts__c = rcd.id;
                }
            }
            
        }
        
        //Service Tax is applicable for this project
        
        system.debug('i' + i);
        if (i == 0 || Test.isRunningTest()) {
            
            Opportunity insObj = new Opportunity();
            insObj.Id = boookingObj.Opportunity__c;
            insObj.RW_Project__c = boookingObj.Project__c;
            insObj.RW_Project_Unit__c = boookingObj.Unit_No__c;
            insObj.RW_Agreement_Value__c = boookingObj.Allotment_Premium__c;
            insObj.Amount = boookingObj.Allotment_Premium__c;
            //insObj.Reason_for_Reblocking__c = 'Booking';
            //insObj.StageName= 'Token Amount Received - BIP';
            
            //insObj.Future_Correspondence_Contact_Name__c=boookingObj.Future_Correspondence_Contact_Name__c;
            
            //insObj.Future_Correspondence_Contact_Phone__c = boookingObj.Future_Correspondence_Contact_Phone__c;
            
            //insObj.Future_Correspondence_Contact_Email__c = boookingObj.Future_Correspondence_Contact_Email__c;
            //insObj.Future_Correspondence_Contact__c = boookingObj.Future_Correspondence_Contact__c;
            
            try {
                
                boookingObj.Customer__c = boookingObj.Opportunity__c;
                boookingObj.status__c = 'UnProcessed'; 
                boookingObj.Interest_to_be_Applied__c='No';
                // boookingObj.Booking_Application_Form_Hard_copy__c = fileUrl; //Added by coServe 23-03-2023
                //boookingObj.status__c = 'Booking Received';   //Modified by Sheetal on 12/1/2022 to solve Issue I0101
                insert boookingObj;
                update insObj;
                
            } catch (DmlException e) {
                System.debug('An error has occured. Please contact your administrator. : ' + e.getMessage());
                
            }
            
            //Updating Parkings/////
            
            ////Tandem Covered////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Tandem_car_park_Additional__c > 0) {
                for (integer j = 0; j < QuoteDetails[0].Tandem_car_park_Additional__c; j++) {
                    
                    TandemCOVEREDParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        TandemCOVEREDParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(TandemCOVEREDParkingList[j]);
                }
                
            }
            ////Tandem Open////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Tandem_Open_Additional__c > 0) {
                for (integer j = 0; j < QuoteDetails[0].Tandem_Open_Additional__c; j++) {
                    
                    TandemOPENParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        TandemOPENParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(TandemOPENParkingList[j]);
                }
                
            }
            ////Single Open////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Single_Open_Additional__c > 0) {
                for (integer j = 0; j < QuoteDetails[0].Single_Open_Additional__c; j++) {
                    
                    SingleOPENParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        SingleOPENParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(SingleOPENParkingList[j]);
                }
                
            }
            ////Single Covered////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Single_car_park_Additional__c > 0) {
                for (integer j = 0; j < QuoteDetails[0].Single_car_park_Additional__c; j++) {
                    SingleCOVEREDParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        SingleCOVEREDParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(SingleCOVEREDParkingList[j]);
                    
                }
                
            }
            ////Stack ////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Stack_Additional__c > 0) {
                for (integer j = 0; j < QuoteDetails[0].Stack_Additional__c; j++) {
                    STILTParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        STILTParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(STILTParkingList[j]);
                    
                }
                
            }
            ////MLCP////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].MLCP_Additional__c> 0) {
                for (integer j = 0; j < QuoteDetails[0].MLCP_Additional__c; j++) {
                    MLCPParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        MLCPParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(MLCPParkingList[j]);
                    
                }
                
            }
            ////Basement --- Added by Payal////
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Basement_Additional__c> 0) {
                for (integer j = 0; j < QuoteDetails[0].Basement_Additional__c; j++) {
                    BasementParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        BasementParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(BasementParkingList[j]);
                    
                }
                
            }
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Podium__c> 0) {
                system.debug('STACKParkingList Requires');
                for (integer j = 0; j < QuoteDetails[0].Podium__c; j++) {
                    PodiumParkingList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        PodiumParkingList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(PodiumParkingList[j]);
                    
                }
                
            }
            
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Puzzle_Car_Park__c> 0) { //Added by Vinay 28-03-2025
                system.debug('PuzzleCarParkList Requires');
                for (integer j = 0; j < QuoteDetails[0].Podium__c; j++) {
                    PuzzleCarParkList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        PuzzleCarParkList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(PuzzleCarParkList[j]);
                    
                }
                
            }
            if (QuoteDetails != null && !QuoteDetails.isEmpty() && QuoteDetails[0].Stack_Additional_1__c> 0) { //Added by Vinay 21-11-2025
                system.debug('StackCarParkList Requires');
                for (integer j = 0; j < QuoteDetails[0].Stack_Additional_1__c; j++) {
                    StackCarParkList[j].Status__c = 'Booked';
                    if (boookingObj.Id != null)
                        StackCarParkList[j].Booking__c = boookingObj.Id;
                    ParkingListToUpdate.add(StackCarParkList[j]);
                    
                }
                
            }
            
            if (ParkingListToUpdate.size() > 0 && !Test.isRunningTest()) {
                update ParkingListToUpdate;
            }
            //Updating  Customer Pay Plan Headers with new booking 
            if (boookingObj.id != null) {
                try {
                   
                    if (boookingObj.Quotation__c != null) {
                        CPPHList = [
                            SELECT Id, Name, Booking__c, Customer__c, Quotation__c 
                            FROM Customer_Pay_Plan_Header__c 
                            WHERE Quotation__c = :boookingObj.Quotation__c
                        ];
                        
                        if (!CPPHList.isEmpty()) {
                            for (Customer_Pay_Plan_Header__c cpph : CPPHList) {
                                System.debug('Inside cpph for');
                                cpph.Customer__c = boookingObj.Opportunity__c;
                                cpph.Booking__c = boookingObj.Id;
                                CPPHListToAdd.add(cpph);
                            }
                            update CPPHListToAdd;
                        }
                    }
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    
                }
                try {
                    //Updating Quotation with new booking
                    if (QuoteDetails.size() > 0) {
                        QuoteDetails[0].Booking__c = boookingObj.id;
                        update QuoteDetails;
                    }
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    
                }
                try {
                    //Updating ProjectUnit with new booking  =======>Added by Payal 15/07/2021
                    //Added by Prashant so that booking date gets updated to opp and unit.02-06-25.///Start
                    if(optyList.size() > 0){
                        optyList[0].RW_Booking_Date_Opp__c = Date.valueOf(boookingObj.Booking_Date__c);
                        update optyList;
                    }
                    //Added by Prashant so that booking date gets updated to opp and unit.02-06-25.///End
                    if (unitDetails.size() > 0) {
                        unitDetails[0].Booking__c = boookingObj.id;
                        unitDetails[0].Is_Booking_Tagged__c = true;
                        //unitDetails[0].RW_Booking_Date__c = System.today();  //Added by Sheetal on 17/01/2022 //Commented by coServe 05-09-2024
                        //unitDetails[0].RW_Booking_Date__c = optyList[0].RW_Booking_Date_Opp__c; //Added by coServe 05-09-2024
                        unitDetails[0].RW_Booking_Date__c = Date.valueOf(boookingObj.Booking_Date__c);//Added by Prashant so that booking date gets updated to opp and unit.02-06-25.
                        update unitDetails;
                        //update unitDetails;
                    }
                    
                    
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    
                }
                try {
                    
                    for (Receipt__c rct: ReceiptLstTobeUpdate) {
                        if (rct.id != null) {
                            rct.Booking__c = boookingObj.id;
                            rct.Project_Unit__c = boookingObj.Unit_No__c;
                            update rct;
                        }
                    }
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    
                }
                
                try {
                    system.debug('this use vikas receipt:::: ' + ReceiptDetails.size());
                    //Updating ReceiptDetails  with new booking
                    if (ReceiptDetails.size() > 0) {
                        
                        for (Receipt__c r: ReceiptDetails) {
                            r.Booking__c = boookingObj.id;
                            r.Opportunity_Email_Id__c = applicant.Email_Address__c;
                            if (r.Project_Unit__c == null) {
                                r.Project_Unit__c = boookingObj.Unit_No__c;
                            }
                            if (boookingObj.Project__c != null) {
                                
                                r.Project__c = boookingObj.Project__c;
                            }
                            if (!Test.isRunningTest())
                                ListOldReceipt.add(r);
                        }
                        
                    }
                    //Updating ReceiptDetails  with new booking
                    if (STReceiptDetails.size() > 0) {
                        for (Receipt__c st: STReceiptDetails) {
                            st.Booking__c = boookingObj.id;
                            st.Opportunity_Email_Id__c = applicant.Email_Address__c;
                            if (st.Project_Unit__c == null) {
                                st.Project_Unit__c = boookingObj.Unit_No__c;
                                
                            }
                            if (boookingObj.Project__c != null) {
                                
                                st.Project__c = boookingObj.Project__c;
                            }
                            if (!Test.isRunningTest())
                                ListOldReceipt.add(st);
                        }
                        
                    }
                    
                    update ListOldReceipt;
                } catch (DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                    
                }
                
                //inserting the Applicants
                if (applicant.First_Name__c != '' && applicant.First_Name__c != null && applicant.Last_Name__c != '' && applicant.Last_Name__c != null) {
                    if (applicant.Middle_Name__c != null) {
                        applicant.Name = applicant.First_Name__c + ' ' + applicant.Middle_Name__c + ' ' + applicant.Last_Name__c;
                    } else {
                        applicant.Name = applicant.First_Name__c + ' ' + applicant.Last_Name__c;
                    }
                    if (applicant.Permanent_Address_Line_1__c != null) {
                        applicant.Permanent_Address__c = applicant.Permanent_Address_Line_1__c;
                        if (applicant.Permanent_Address_Line_2__c != null) {
                            applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_2__c;
                            if (applicant.Permanent_Address_Line_3__c != null) {
                                applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_3__c;
                            }
                        }
                        
                        if (addressCheck == true) {
                            applicant.Mailing_Address_same_as_PermanentAddress__c = true;
                            applicant.Mailing_Address_Line_1__c = applicant.Permanent_Address_Line_1__c;
                            applicant.Mailing_Address_Line_2__c = applicant.Permanent_Address_Line_2__c;
                            applicant.Mailing_Address_Line_3__c = applicant.Permanent_Address_Line_3__c;
                            
                            applicant.Mailing_Address__c = applicant.Mailing_Address_Line_1__c;
                            if (applicant.Mailing_Address_Line_2__c != null) {
                                applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_2__c;
                                if (applicant.Mailing_Address_Line_3__c != null) {
                                    applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_3__c;
                                }
                            }
                            applicant.Mailing_Pincode__c = applicant.Pincode__c;
                            applicant.Mailing_Country__c = applicant.Country__c;
                            applicant.Mailing_State__c = applicant.State__c;
                            applicant.Mailing_City__c = applicant.City__c;
                            applicant.Nationality__c = applicant.Nationality_Picklist__c;
                            applicant.Designation__c = applicant.Designation_picklist__c;
                        } else {
                            applicant.Mailing_Address__c = applicant.Mailing_Address_Line_1__c;
                            if (applicant.Mailing_Address_Line_2__c != null) {
                                applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_2__c;
                                if (applicant.Mailing_Address_Line_3__c != null) {
                                    applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_3__c;
                                }
                            }
                        }
                    }
                    applicant.Applicant_Number__c = 'Primary Applicant';
                    applicant.Booking__c = boookingObj.id;
                    applicant.Opportunity__c = boookingObj.Opportunity__c;
                    listApplicant.add(applicant);
                    applicant.Organization_Address__c = applicant.Office_Address_Line_1__c;
                    if (applicant.Office_Address_Line_2__c != null) {
                        applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_2__c;
                        if (applicant.Office_Address_Line_3__c != null) {
                            applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_3__c;
                        }
                    }
                    
                    BookingClass2.updateAccount(applicant, acc); //Added by Vinay 04-06-2025 
                }
                if (applicant2.First_Name__c != '' && applicant2.First_Name__c != null && applicant2.Last_Name__c != '' && applicant2.Last_Name__c != null) {
                    if (applicant2.Middle_Name__c != null) {
                        applicant2.Name = applicant2.First_Name__c + ' ' + applicant2.Middle_Name__c + ' ' + applicant2.Last_Name__c;
                    } else {
                        applicant2.Name = applicant2.First_Name__c + ' ' + applicant2.Last_Name__c;
                    }
                    if (applicant2.Permanent_Address_Line_1__c != null) {
                        applicant2.Permanent_Address__c = applicant2.Permanent_Address_Line_1__c;
                        if (applicant2.Permanent_Address_Line_2__c != null) {
                            applicant2.Permanent_Address__c = applicant2.Permanent_Address__c + ', ' + applicant2.Permanent_Address_Line_2__c;
                            if (applicant2.Permanent_Address_Line_3__c != null) {
                                applicant2.Permanent_Address__c = applicant2.Permanent_Address__c + ', ' + applicant2.Permanent_Address_Line_3__c;
                            }
                        }
                        if (addressCheckApplicant2 == true) {
                            applicant2.Mailing_Address_same_as_PermanentAddress__c = true;
                            applicant2.Mailing_Address_Line_1__c = applicant2.Permanent_Address_Line_1__c;
                            applicant2.Mailing_Address_Line_2__c = applicant2.Permanent_Address_Line_2__c;
                            applicant2.Mailing_Address_Line_3__c = applicant2.Permanent_Address_Line_3__c;
                            
                            applicant2.Mailing_Address__c = applicant2.Mailing_Address_Line_1__c;
                            if (applicant2.Mailing_Address_Line_2__c != null) {
                                applicant2.Mailing_Address__c = applicant2.Mailing_Address__c + ', ' + applicant2.Mailing_Address_Line_2__c;
                                if (applicant2.Mailing_Address_Line_3__c != null) {
                                    applicant2.Mailing_Address__c = applicant2.Mailing_Address__c + ', ' + applicant2.Mailing_Address_Line_3__c;
                                }
                            }
                            applicant2.Mailing_Pincode__c = applicant2.Pincode__c;
                            applicant2.Mailing_Country__c = applicant2.Country__c;
                            applicant2.Mailing_State__c = applicant2.State__c;
                            applicant2.Mailing_City__c = applicant2.City__c;
                            applicant2.Nationality__c = applicant2.Nationality_Picklist__c;
                            applicant2.Designation__c = applicant2.Designation_picklist__c;
                            
                        } else {
                            applicant2.Mailing_Address__c = applicant2.Mailing_Address_Line_1__c;
                            if (applicant2.Mailing_Address_Line_2__c != null) {
                                applicant2.Mailing_Address__c = applicant2.Mailing_Address__c + ', ' + applicant2.Mailing_Address_Line_2__c;
                                if (applicant2.Mailing_Address_Line_3__c != null) {
                                    applicant2.Mailing_Address__c = applicant2.Mailing_Address__c + ', ' + applicant2.Mailing_Address_Line_3__c;
                                }
                            }
                        }
                    }
                    
                    applicant2.Applicant_Number__c = 'Second Applicant';
                    applicant2.Booking__c = boookingObj.id;
                    applicant2.Opportunity__c = boookingObj.Opportunity__c;
                    listApplicant.add(applicant2);
                    applicant2.Organization_Address__c = applicant2.Office_Address_Line_1__c;
                    if (applicant2.Office_Address_Line_2__c != null) {
                        applicant2.Organization_Address__c = applicant2.Organization_Address__c + ', ' + applicant2.Office_Address_Line_2__c;
                        if (applicant2.Office_Address_Line_3__c != null) {
                            applicant2.Organization_Address__c = applicant2.Organization_Address__c + ', ' + applicant2.Office_Address_Line_3__c;
                        }
                    }
                }
                if (applicant3.First_Name__c != '' && applicant3.First_Name__c != null && applicant3.Last_Name__c != '' && applicant3.Last_Name__c != null) {
                    if (applicant3.Middle_Name__c != null) {
                        applicant3.Name = applicant3.First_Name__c + ' ' + applicant3.Middle_Name__c + ' ' + applicant3.Last_Name__c;
                    } else {
                        applicant3.Name = applicant3.First_Name__c + ' ' + applicant3.Last_Name__c;
                    }
                    if (applicant3.Permanent_Address_Line_1__c != null) {
                        applicant3.Permanent_Address__c = applicant3.Permanent_Address_Line_1__c;
                        if (applicant3.Permanent_Address_Line_2__c != null) {
                            applicant3.Permanent_Address__c = applicant3.Permanent_Address__c + ', ' + applicant3.Permanent_Address_Line_2__c;
                            if (applicant3.Permanent_Address_Line_3__c != null) {
                                applicant3.Permanent_Address__c = applicant3.Permanent_Address__c + ', ' + applicant3.Permanent_Address_Line_3__c;
                            }
                        }
                        if (addressCheckApplicant3 == true) {
                            applicant3.Mailing_Address_same_as_PermanentAddress__c = true;
                            applicant3.Mailing_Address_Line_1__c = applicant3.Permanent_Address_Line_1__c;
                            applicant3.Mailing_Address_Line_2__c = applicant3.Permanent_Address_Line_2__c;
                            applicant3.Mailing_Address_Line_3__c = applicant3.Permanent_Address_Line_3__c;
                            
                            applicant3.Mailing_Address__c = applicant3.Mailing_Address_Line_1__c;
                            if (applicant3.Mailing_Address_Line_2__c != null) {
                                applicant3.Mailing_Address__c = applicant3.Mailing_Address__c + ', ' + applicant3.Mailing_Address_Line_2__c;
                                if (applicant3.Mailing_Address_Line_3__c != null) {
                                    applicant3.Mailing_Address__c = applicant3.Mailing_Address__c + ', ' + applicant3.Mailing_Address_Line_3__c;
                                }
                            }
                            applicant3.Mailing_Pincode__c = applicant3.Pincode__c;
                            applicant3.Mailing_Country__c = applicant3.Country__c;
                            applicant3.Mailing_State__c = applicant3.State__c;
                            applicant3.Mailing_City__c = applicant3.City__c;
                            applicant3.Nationality__c = applicant3.Nationality_Picklist__c;
                            applicant3.Designation__c = applicant3.Designation_picklist__c;
                            
                        } else {
                            applicant3.Mailing_Address__c = applicant3.Mailing_Address_Line_1__c;
                            if (applicant3.Mailing_Address_Line_2__c != null) {
                                applicant3.Mailing_Address__c = applicant3.Mailing_Address__c + ', ' + applicant3.Mailing_Address_Line_2__c;
                                if (applicant3.Mailing_Address_Line_3__c != null) {
                                    applicant3.Mailing_Address__c = applicant3.Mailing_Address__c + ', ' + applicant3.Mailing_Address_Line_3__c;
                                }
                            }
                        }
                    }
                    applicant3.Applicant_Number__c = 'Third Applicant';
                    applicant3.Booking__c = boookingObj.id;
                    applicant3.Opportunity__c = boookingObj.Opportunity__c;
                    listApplicant.add(applicant3);
                    applicant3.Organization_Address__c = applicant3.Office_Address_Line_1__c;
                    if (applicant3.Office_Address_Line_2__c != null) {
                        applicant3.Organization_Address__c = applicant3.Organization_Address__c + ', ' + applicant3.Office_Address_Line_2__c;
                        if (applicant3.Office_Address_Line_3__c != null) {
                            applicant3.Organization_Address__c = applicant3.Organization_Address__c + ', ' + applicant3.Office_Address_Line_3__c;
                        }
                    }
                }
                if (applicant4.First_Name__c != '' && applicant4.First_Name__c != null && applicant4.Last_Name__c != '' && applicant4.Last_Name__c != null) {
                    if (applicant4.Middle_Name__c != null) {
                        applicant4.Name = applicant4.First_Name__c + ' ' + applicant4.Middle_Name__c + ' ' + applicant4.Last_Name__c;
                    } else {
                        applicant4.Name = applicant4.First_Name__c + ' ' + applicant4.Last_Name__c;
                    }
                    if (applicant4.Permanent_Address_Line_1__c != null) {
                        applicant4.Permanent_Address__c = applicant4.Permanent_Address_Line_1__c;
                        if (applicant4.Permanent_Address_Line_2__c != null) {
                            applicant4.Permanent_Address__c = applicant4.Permanent_Address__c + ', ' + applicant4.Permanent_Address_Line_2__c;
                            if (applicant4.Permanent_Address_Line_3__c != null) {
                                applicant4.Permanent_Address__c = applicant4.Permanent_Address__c + ', ' + applicant4.Permanent_Address_Line_3__c;
                            }
                        }
                        if (addressCheckApplicant4 == true) {
                            applicant4.Mailing_Address_same_as_PermanentAddress__c = true;
                            applicant4.Mailing_Address_Line_1__c = applicant4.Permanent_Address_Line_1__c;
                            applicant4.Mailing_Address_Line_2__c = applicant4.Permanent_Address_Line_2__c;
                            applicant4.Mailing_Address_Line_3__c = applicant4.Permanent_Address_Line_3__c;
                            
                            applicant4.Mailing_Address__c = applicant4.Mailing_Address_Line_1__c;
                            if (applicant4.Mailing_Address_Line_2__c != null) {
                                applicant4.Mailing_Address__c = applicant4.Mailing_Address__c + ', ' + applicant4.Mailing_Address_Line_2__c;
                                if (applicant4.Mailing_Address_Line_3__c != null) {
                                    applicant4.Mailing_Address__c = applicant4.Mailing_Address__c + ', ' + applicant4.Mailing_Address_Line_3__c;
                                }
                            }
                            applicant4.Mailing_Pincode__c = applicant4.Pincode__c;
                            applicant4.Mailing_Country__c = applicant4.Country__c;
                            applicant4.Mailing_State__c = applicant4.State__c;
                            applicant4.Mailing_City__c = applicant4.City__c;
                            applicant4.Nationality__c = applicant4.Nationality_Picklist__c;
                            applicant4.Designation__c = applicant4.Designation_picklist__c;
                            
                        } else {
                            applicant4.Mailing_Address__c = applicant4.Mailing_Address_Line_1__c;
                            if (applicant4.Mailing_Address_Line_2__c != null) {
                                applicant4.Mailing_Address__c = applicant4.Mailing_Address__c + ', ' + applicant4.Mailing_Address_Line_2__c;
                                if (applicant4.Mailing_Address_Line_3__c != null) {
                                    applicant4.Mailing_Address__c = applicant4.Mailing_Address__c + ', ' + applicant4.Mailing_Address_Line_3__c;
                                }
                            }
                        }
                    }
                    applicant4.Applicant_Number__c = 'Fourth Applicant';
                    applicant4.Booking__c = boookingObj.id;
                    applicant4.Opportunity__c = boookingObj.Opportunity__c;
                    listApplicant.add(applicant4);
                    applicant4.Organization_Address__c = applicant4.Office_Address_Line_1__c;
                    if (applicant4.Office_Address_Line_2__c != null) {
                        applicant4.Organization_Address__c = applicant4.Organization_Address__c + ', ' + applicant4.Office_Address_Line_2__c;
                        if (applicant4.Office_Address_Line_3__c != null) {
                            applicant4.Organization_Address__c = applicant4.Organization_Address__c + ', ' + applicant4.Office_Address_Line_3__c;
                        }
                    }
                }
                if (applicant5.First_Name__c != '' && applicant5.First_Name__c != null && applicant5.Last_Name__c != '' && applicant5.Last_Name__c != null) {
                    if (applicant5.Middle_Name__c != null) {
                        applicant5.Name = applicant5.First_Name__c + ' ' + applicant5.Middle_Name__c + ' ' + applicant5.Last_Name__c;
                    } else {
                        applicant5.Name = applicant5.First_Name__c + ' ' + applicant5.Last_Name__c;
                    }
                    if (applicant5.Permanent_Address_Line_1__c != null) {
                        applicant5.Permanent_Address__c = applicant5.Permanent_Address_Line_1__c;
                        if (applicant5.Permanent_Address_Line_2__c != null) {
                            applicant5.Permanent_Address__c = applicant5.Permanent_Address__c + ', ' + applicant5.Permanent_Address_Line_2__c;
                            if (applicant5.Permanent_Address_Line_3__c != null) {
                                applicant5.Permanent_Address__c = applicant5.Permanent_Address__c + ', ' + applicant5.Permanent_Address_Line_3__c;
                            }
                        }
                        if (addressCheckApplicant5 == true) {
                            applicant5.Mailing_Address_same_as_PermanentAddress__c = true;
                            applicant5.Mailing_Address_Line_1__c = applicant5.Permanent_Address_Line_1__c;
                            applicant5.Mailing_Address_Line_2__c = applicant5.Permanent_Address_Line_2__c;
                            applicant5.Mailing_Address_Line_3__c = applicant5.Permanent_Address_Line_3__c;
                            
                            applicant5.Mailing_Address__c = applicant5.Mailing_Address_Line_1__c;
                            if (applicant5.Mailing_Address_Line_2__c != null) {
                                applicant5.Mailing_Address__c = applicant5.Mailing_Address__c + ', ' + applicant5.Mailing_Address_Line_2__c;
                                if (applicant5.Mailing_Address_Line_3__c != null) {
                                    applicant5.Mailing_Address__c = applicant5.Mailing_Address__c + ', ' + applicant5.Mailing_Address_Line_3__c;
                                }
                            }
                            applicant5.Mailing_Pincode__c = applicant5.Pincode__c;
                            applicant5.Mailing_Country__c = applicant5.Country__c;
                            applicant5.Mailing_State__c = applicant5.State__c;
                            applicant5.Mailing_City__c = applicant5.City__c;
                            applicant5.Nationality__c = applicant5.Nationality_Picklist__c;
                            applicant5.Designation__c = applicant5.Designation_picklist__c;
                            
                        } else {
                            applicant5.Mailing_Address__c = applicant5.Mailing_Address_Line_1__c;
                            if (applicant5.Mailing_Address_Line_2__c != null) {
                                applicant5.Mailing_Address__c = applicant5.Mailing_Address__c + ', ' + applicant5.Mailing_Address_Line_2__c;
                                if (applicant5.Mailing_Address_Line_3__c != null) {
                                    applicant5.Mailing_Address__c = applicant5.Mailing_Address__c + ', ' + applicant5.Mailing_Address_Line_3__c;
                                }
                            }
                        }
                    }
                    applicant5.Applicant_Number__c = 'Fifth Applicant';
                    applicant5.Booking__c = boookingObj.id;
                    applicant5.Opportunity__c = boookingObj.Opportunity__c;
                    listApplicant.add(applicant5);
                    applicant5.Organization_Address__c = applicant5.Office_Address_Line_1__c;
                    if (applicant5.Office_Address_Line_2__c != null) {
                        applicant5.Organization_Address__c = applicant5.Organization_Address__c + ', ' + applicant5.Office_Address_Line_2__c;
                        if (applicant5.Office_Address_Line_3__c != null) {
                            applicant5.Organization_Address__c = applicant5.Organization_Address__c + ', ' + applicant5.Office_Address_Line_3__c;
                        }
                    }
                }
                system.debug('listApplicant' + listApplicant);
                try {
                    if (listApplicant.size() > 0) {
                        if (!Test.isRunningTest())
                            insert listApplicant;
                    }
                    /*  if(listReceiptDetails.size() > 0){
insert listReceiptDetails; 
} */
                    
                    //system.debug('listReceiptDetails::::'+listReceiptDetails);
                } catch (DmlException e) {
                    System.debug('An error has occured. Please contact your administrator. : ' + e.getMessage());
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }
            }
            //System.Debug('ReceiptObj'+ReceiptObj);
            System.Debug('Booking Obj' + boookingObj);
            if (boookingObj.id != null) {
                PageReference newpage = new Pagereference('/' + boookingObj.id);
                newpage.setRedirect(true);
                
                return newpage;
            }
            
        }
        //boookingObj.Sales_Manager__c = boookingObj.OwnerId;
        return null;
    }
    public PageReference Cancel() {
        
        Id oppId;
        String sfdcURL = URL.getOrgDomainUrl().toExternalForm() + '/';
        
        if (optyList != null && !optyList.isEmpty()) {
            // Assign value to oppId
            oppId = optyList[0].Id;
        } else {
            
            return new PageReference('/home/home.jsp');
        }
        
        
        PageReference pageRef = new PageReference(sfdcURL + oppId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    //Added by coServe 23-03-2023 Start
    /* public PageReference upload() {
try {
document.AuthorId = UserInfo.getUserId();
document.FolderId = UserInfo.getUserId();
insert document;

} catch (DMLException e) {
this.fileUploaded = false;
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Kindly upload Booking Application Form'));
return null;
} 
System.debug('document: ' + document.Id);
this.docId = document.Id;
String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
String fileUrl = baseUrl + '/servlet/servlet.FileDownload?file=' + docId;
System.debug('fileUrl: ' + fileUrl);
this.fileUrl = fileUrl;
this.document = document;
this.selectedvalue = selectedvalue;
this.fileUploaded = true;
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Document uploaded successfully'));
return null;
}
//Added by coServe 23-03-2023 End*/
    
  
    
}