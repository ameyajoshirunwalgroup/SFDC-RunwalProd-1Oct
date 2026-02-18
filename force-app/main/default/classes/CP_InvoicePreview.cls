public class CP_InvoicePreview {
    public List<Brokerage_Invoice__c> CPInv {get;set;}
    public CP_Brokerage__c cpBrokerage {get;set;}
    public List<Broker__c> ChannelPartner {get;set;}
    public List<Booking__c> bklist {get;set;}
    public List<Brokerage_Scheme__c> brokerageScheme {get;set;}
    public List<Kicker_Incentive__c> KickerScheme {get;set;}
    public List<Place_of_Supply__c> pos {get;set;}
    public List<AOP__c> aopDetails {get;set;}
    public String dateStr {get;set;}
    public Decimal TotalBrokerage {get;set;}
    public Decimal Cgst {get;set;} 
    public Decimal Sgst {get;set;}
    public Decimal Igst {get;set;}
    public Decimal TotalwithTax {get;set;}
    public String BrokerageAmtStr {get;set;}
    public String TotalwithTaxStr {get;set;}
    public String CgstStr {get;set;}
    public String SgstStr {get;set;}
    public String IgstStr {get;set;}
    public String NoToWord {get;set;}
    public Boolean GSTApplicable {get;set;}
    public string errormsg {get;set;}
    public string errormsg2 {get;set;}
    public Integer isError1 {get;set;}
    public Boolean Base {get;set;}
    public Boolean Additional {get;set;}
    public Boolean Kicker {get;set;}
    public Boolean showgst {get;set;}
    public Boolean showigst {get;set;}
    public String AVValueStr {get;set;}
    public Boolean istaxapplicable {get;set;}
    public static List<Legal_Entity__c> legalentity {get;set;}
    Public static list<Project__c> ProjectList{get;set;}
    public List<Tower__c> tlist {get;set;}
    public Set<String> uniqueRERANumbers = new Set<String>();
    public String allRERANumbers { get; set; }
    // New properties for multiple invoices
    public List<InvoiceWrapper> invoiceWrappers {get;set;}
    public Decimal totalBrokerageAmount {get;set;}
    public Decimal totalCGST {get;set;}
    public Decimal totalSGST {get;set;}
    public Decimal totalIGST {get;set;}
    public Decimal grandTotal {get;set;}
    public String urlGstApp {get;set;}
    public String invoiceNumber {get;set;}
    public String invoiceDateString {get;set;}
    public Date invoiceDate {get;set;}
    
    public class InvoiceWrapper {
        public Brokerage_Invoice__c invoice {get;set;}
        public String brokerageAmtStr {get;set;}
        public String cgstStr {get;set;}
        public String sgstStr {get;set;}
        public String igstStr {get;set;}
        public String totalWithTaxStr {get;set;}
        public Decimal brokerageAmount {get;set;}
        public Decimal cgstAmount {get;set;}
        public Decimal sgstAmount {get;set;}
        public Decimal igstAmount {get;set;}
        public Decimal totalWithTax {get;set;}
        public Decimal brokeragePercentage {get;set;}
        
        /* public InvoiceWrapper(Brokerage_Invoice__c inv, Boolean showGST, Boolean isTaxApplicable, CP_Brokerage__c cpBrokerage, List<AOP__c> aopDetails) {
this.invoice = inv;
this.brokerageAmount = inv.Brokerage_In_Rs__c != null ? inv.Brokerage_In_Rs__c : 0;
this.brokerageAmtStr = INFormat(this.brokerageAmount);

if(isTaxApplicable) {
this.cgstAmount = showGST ? (this.brokerageAmount * 0.09).setScale(2, RoundingMode.HALF_UP) : 0;
this.sgstAmount = showGST ? (this.brokerageAmount * 0.09).setScale(2, RoundingMode.HALF_UP) : 0;
this.igstAmount = !showGST ? (this.brokerageAmount * 0.18).setScale(2, RoundingMode.HALF_UP) : 0;

this.totalWithTax = showGST ? 
(this.brokerageAmount + this.cgstAmount + this.sgstAmount).setScale(0, RoundingMode.HALF_UP) :
(this.brokerageAmount + this.igstAmount).setScale(0, RoundingMode.HALF_UP);
} else {
this.cgstAmount = 0;
this.sgstAmount = 0;
this.igstAmount = 0;
this.totalWithTax = this.brokerageAmount.setScale(0, RoundingMode.HALF_UP);
}

this.cgstStr = INFormat(this.cgstAmount);
this.sgstStr = INFormat(this.sgstAmount);
this.igstStr = INFormat(this.igstAmount);
this.totalWithTaxStr = INFormat(this.totalWithTax);
}*/
        public InvoiceWrapper(Brokerage_Invoice__c inv, Boolean showGST, Boolean isTaxApplicable, CP_Brokerage__c cpBrokerage, List<AOP__c> aopDetails) {
            this.invoice = inv;
            this.brokerageAmount = inv.Brokerage_In_Rs__c != null ? inv.Brokerage_In_Rs__c : 0;
            this.brokerageAmtStr = INFormat(this.brokerageAmount);
            
            if(isTaxApplicable) {
                // REPLICATED FROM ORIGINAL CODE - Same tax calculation logic
                this.cgstAmount = showGST ? (this.brokerageAmount * 0.09).setScale(2, RoundingMode.HALF_UP) : 0;
                this.sgstAmount = showGST ? (this.brokerageAmount * 0.09).setScale(2, RoundingMode.HALF_UP) : 0;
                this.igstAmount = !showGST ? (this.brokerageAmount * 0.18).setScale(2, RoundingMode.HALF_UP) : 0;
                
                this.totalWithTax = showGST ? 
                    (this.brokerageAmount + this.cgstAmount + this.sgstAmount).setScale(0, RoundingMode.HALF_UP) :
                    (this.brokerageAmount + this.igstAmount).setScale(0, RoundingMode.HALF_UP);
            } else {
                this.cgstAmount = 0;
                this.sgstAmount = 0;
                this.igstAmount = 0;
                this.totalWithTax = this.brokerageAmount.setScale(0, RoundingMode.HALF_UP);
            }
            
            this.cgstStr = INFormat(this.cgstAmount);
            this.sgstStr = INFormat(this.sgstAmount);
            this.igstStr = INFormat(this.igstAmount);
            this.totalWithTaxStr = INFormat(this.totalWithTax);
        }
    }
    
    public CP_InvoicePreview() {
        // Initialize all variables
        CPInv = new List<Brokerage_Invoice__c>();
        ChannelPartner = new List<Broker__c>();
        bklist = new List<Booking__c>();
        brokerageScheme = new List<Brokerage_Scheme__c>();
        KickerScheme = new List<Kicker_Incentive__c>();
        pos = new List<Place_of_Supply__c>();
        legalentity = new List<Legal_Entity__c>();
        tlist = new List<Tower__c>();
        invoiceWrappers = new List<InvoiceWrapper>();
        aopDetails = new List<AOP__c>();
        
        // Initialize boolean flags
        Base = false;
        Additional = false;
        Kicker = false;
        showgst = false;
        showigst = false;
        istaxapplicable = false;
        GSTApplicable = false;
        
        // Initialize strings and numbers
        errormsg = '';
        errormsg2 = '';
        isError1 = 0;
        dateStr = Date.today().format();
        totalBrokerageAmount = 0;
        totalCGST = 0;
        totalSGST = 0;
        totalIGST = 0;
        grandTotal = 0;
        
        // Get page parameter
        Id cpBrokerageId = ApexPages.currentPage().getParameters().get('id');
        urlGstApp = ApexPages.currentPage().getParameters().get('gstApp');
        invoiceNumber = ApexPages.currentPage().getParameters().get('invoiceNumber');
        invoiceDateString = ApexPages.currentPage().getParameters().get('invoiceDate');
        if(String.isNotBlank(invoiceDateString)){
            invoiceDate = Date.valueOf(invoiceDateString);
        }
        System.debug('CP_InvoicePreview Constructor - cpBrokerageId: ' + cpBrokerageId);
        
        if(String.isNotBlank(urlGstApp)) {
            this.istaxapplicable = (urlGstApp == 'Yes');
        }
        
        if(cpBrokerageId != null) {
            fetchInvoices(cpBrokerageId);
            invoiceNumber = String.isNotBlank(invoiceNumber) ? invoiceNumber : cpBrokerage.Invoice_Number__c;
        	invoiceDate = String.isNotBlank(invoiceDateString) ? invoiceDate : cpBrokerage.Invoice_Date__c;
            
            if(isError1 == 0 && !CPInv.isEmpty()) {
                Base = true;
                System.debug('CP_InvoicePreview - Base set to true, CPInv size: ' + CPInv.size());
            } else {
                System.debug('CP_InvoicePreview - Base remains false, isError1: ' + isError1 + ', CPInv size: ' + CPInv.size());
            }
        } else {
            errormsg = 'No CP Brokerage ID provided in URL parameter.';
            isError1 = 1;
            System.debug('CP_InvoicePreview - No ID parameter found');
        }
    }
    
    private void fetchInvoices(Id cpBrokerageId){
        try {
            System.debug('fetchInvoices - Starting with ID: ' + cpBrokerageId);
            
            cpBrokerage = [
                SELECT Id, If_GST_is_applicable__c, Invoice_Number__c, Channel_Partner__c,Invoice_Date__c,Place_of_Supply__c,AOP__c,Brokerage_Type__c,
                Channel_Partner__r.State__c,CGST__c, SGST__c, IGST__c
                
                FROM CP_Brokerage__c
                WHERE Id = :cpBrokerageId
                LIMIT 1
            ];
            
            Profile currentProfile = [
                SELECT Id, Name 
                FROM Profile 
                WHERE Id = :UserInfo.getProfileId()
            ];
            
            // Validate required fields on CP_Brokerage__c
            List<String> validationErrors = new List<String>();
            if((currentProfile.Name == 'Partner Community Login User' || currentProfile.Name == 'Partner Community User') && cpBrokerage.If_GST_is_applicable__c == null){
                validationErrors.add('Please Select If GST is Applicable (Y/N)');
            }
            if((currentProfile.Name == 'Partner Community Login User' || currentProfile.Name == 'Partner Community User') && String.isBlank(cpBrokerage.Invoice_Number__c)){
                validationErrors.add('Please Enter Invoice Number');
            }
            if((currentProfile.Name == 'Partner Community Login User' || currentProfile.Name == 'Partner Community User') && cpBrokerage.Channel_Partner__c == null){
                validationErrors.add('Channel Partner is required');
            }
            
            if(!validationErrors.isEmpty()) {
                errormsg = String.join(validationErrors, '; ');
                isError1 = 1;
                System.debug('fetchInvoices - Validation errors on CP_Brokerage__c: ' + errormsg);
                return;
            }
            if(cpBrokerage.Brokerage_Type__c == 'AOP Brokerage' && cpBrokerage.AOP__c != null) {
                try {
                    aopDetails = [
                        SELECT Id, Name, AOP_CP_Name__c, AOP_Non_AOP_Signed__c, Brokerage__c, 
                        Brokerage_for_NRI__c, Brokerage_for_Outstation__c, Projects__c, 
                        Relevant_zone__c, Start_Date__c,End_Date__c
                        FROM AOP__c
                        WHERE Id = :cpBrokerage.AOP__c
                        LIMIT 1
                    ];
                    System.debug('fetchInvoices - Found ' + aopDetails.size() + ' AOP records');
                } catch (Exception e) {
                    System.debug('fetchInvoices - Error fetching AOP details: ' + e.getMessage());
                }
            }
            // Fetch all invoices for the CP Brokerage
            CPInv = [SELECT Id, Name, Approval_Status__c, Brokerage__c, Brokerage_In_Rs__c, Brokerage_Summary__c,
                     Channel_Partner__c, If_GST_is_applicable__c, Invoice_Number__c, Invoice_Status__c,
                     Total_Agreement_Value__c, Booking__c, Opportunity__c,
                     Booking__r.Project__r.Name,
                     Booking__r.Unit_No__r.RW_Param4__c,
                     Booking__r.Unit_No__r.RW_Param2__c,
                     Channel_Partner__r.State__c,
                     Place_of_Supply__c,
                     Eligible_Slab__c,
                     Brokerage_Summary__r.Brokerage_Scheme__c,
                     Brokerage_Lookup__r.Brokerage_Type__c,
                     Project__c, CGST__c, SGST__c, IGST__c,
                     Invoice_Amount__c,
                     Brokerage_Summary__r.Kicker_Incentive__c,
                     Invoice_Date__c, RW_Eligible_Slab__c,
                     CP_Name__c, Customer_Name__c,
                     Booking__r.Customer_Name__c,
                     Booking__r.Booking_Date__c,
                     Booking__r.Unit_Number__c,
                     Booking__r.Agreement_Value_for_brokers__c,
                     AOP_Brokerage__c
                     FROM Brokerage_Invoice__c
                     WHERE CP_Brokerage__c = :cpBrokerageId
                     ORDER BY CreatedDate ASC
                     LIMIT 50
                    ];
            
            System.debug('fetchInvoices - Found ' + CPInv.size() + ' invoice records');
            
            if(CPInv.isEmpty()){
                errormsg = 'No Brokerage Invoice records found for this CP Brokerage ID: ' + cpBrokerageId;
                isError1 = 1;
                System.debug('fetchInvoices - No invoices found');
                return;
            }
            
            // Use first invoice to fetch common details
            Brokerage_Invoice__c firstInv = CPInv[0];
            System.debug('fetchInvoices - First invoice: ' + firstInv.Id + ', Invoice Number: ' + firstInv.Invoice_Number__c);
            
            // Fetch Channel Partner details
            try {
                ChannelPartner = [
                    SELECT Id, Name, Broker_Pan_No__c, RW_RERA_Registration_Number__c, Address__c, RW_GST_Number__c,
                    RW_Mobile_No__c, SAP_CP_Code__c, RW_Email__c, Company_Name_As_per_RERA__c,
                    Bank_Branch__c, Bank_Name__c, Account_Number__c, IFSC_Code__c,
                    Cheque_DD_Favouring_Name__c, Branch_Code__c, Place_of_Supply__c,
                    NAME_FIRST__c, NAME_MIDDLE__c, NAME_LAST__c
                    FROM Broker__c
                    WHERE Id = :cpBrokerage.Channel_Partner__c
                    LIMIT 1
                ];
                System.debug('fetchInvoices - Found ' + ChannelPartner.size() + ' Channel Partner records');
            } catch (Exception e) {
                System.debug('fetchInvoices - Error fetching Channel Partner: ' + e.getMessage());
                errormsg = 'Error fetching Channel Partner details: ' + e.getMessage();
                isError1 = 1;
                return;
            }
            
            // Determine tax settings from first invoice
            if(cpBrokerage.Place_of_Supply__c != null) {
                try {
                    pos = [
                        SELECT Id, Name, State_Code__c
                        FROM Place_of_Supply__c
                        WHERE Name = :cpBrokerage.Place_of_Supply__c
                        LIMIT 1
                    ];
                    System.debug('fetchInvoices - Found ' + pos.size() + ' Place of Supply records');
                } catch (Exception e) {
                    System.debug('fetchInvoices - Error fetching Place of Supply: ' + e.getMessage());
                }
            }
            
            // Set tax flags
            showgst = (pos.size() > 0 && pos[0].Name == 'Maharashtra');
            showigst = !showgst;
            istaxapplicable = (cpBrokerage.If_GST_is_applicable__c == 'Yes');
            if(String.isNotBlank(urlGstApp)) {
                this.istaxapplicable = (urlGstApp == 'Yes');
            }
            System.debug('fetchInvoices - Tax settings: showgst=' + showgst + ', showigst=' + showigst + ', istaxapplicable=' + istaxapplicable);
            
            // Create invoice wrappers and calculate totals
            totalBrokerageAmount = 0;
            totalCGST = 0;
            totalSGST = 0;
            totalIGST = 0;
            grandTotal = 0;
            
            for(Brokerage_Invoice__c inv : CPInv) {
                InvoiceWrapper wrapper = new InvoiceWrapper(inv, showgst, istaxapplicable,cpBrokerage,aopDetails);
                invoiceWrappers.add(wrapper);
                
                totalBrokerageAmount += wrapper.brokerageAmount;
                totalCGST += wrapper.cgstAmount;
                totalSGST += wrapper.sgstAmount;
                totalIGST += wrapper.igstAmount;
                grandTotal += wrapper.totalWithTax;
            }
            
            // Format totals as strings
            BrokerageAmtStr = INFormat(totalBrokerageAmount);
            CgstStr = INFormat(totalCGST);
            SgstStr = INFormat(totalSGST);
            IgstStr = INFormat(totalIGST);
            TotalwithTaxStr = INFormat(grandTotal);
            
            // Convert to words (you'll need to ensure S_NumberToWord class exists)
            try {
                NoToWord = S_NumberToWord.convertNumbertoWords(grandTotal);
            } catch (Exception e) {
                System.debug('fetchInvoices - Error converting to words: ' + e.getMessage());
                NoToWord = 'Error converting amount to words';
            }
            
            System.debug('fetchInvoices - Totals calculated: Brokerage=' + totalBrokerageAmount + ', Grand Total=' + grandTotal);
            
            // Fetch additional details using first invoice
            if(firstInv.Booking__c != null) {
                try {
                    // Process ALL invoices to collect RERA numbers
                    for(Brokerage_Invoice__c inv : CPInv) {
                        List<Booking__c> bklist = [
                            SELECT Id, Name, Booking_Date__c, Agreement_Value_for_brokers__c, Wing__c,
                            Unit_Number__c, Tower__c, Customer_Name__c
                            FROM Booking__c
                            WHERE Id = :inv.Booking__c
                            LIMIT 1
                        ];
                        
                        if(!bklist.isEmpty() && bklist[0].Tower__c != null) {
                            List<Tower__c> tlist = [
                                SELECT Id, Name, Legal_Entity__c
                                FROM Tower__c
                                WHERE Id = :bklist[0].Tower__c
                                LIMIT 1
                            ];
                            
                            if(!tlist.isEmpty() && tlist[0].Legal_Entity__c != null) {
                                List<Legal_Entity__c> legalEntityList = [
                                    SELECT Id, Name, RDS_Company_Code__c, RDS_Company_Name__c,
                                    RDS_Address1__c, RDS_Address2__c, RDS_PAN_No__c,
                                    GSTIN__c, RERA_Number__c
                                    FROM Legal_Entity__c
                                    WHERE Id = :tlist[0].Legal_Entity__c
                                    LIMIT 1
                                ];
                                
                                // Add RERA number to Set (automatically handles duplicates)
                                if(!legalEntityList.isEmpty() && 
                                   String.isNotBlank(legalEntityList[0].RERA_Number__c)) {
                                       uniqueRERANumbers.add(legalEntityList[0].RERA_Number__c);
                                   }
                            }
                        }
                    }
                    
                    // Convert Set to comma-separated String for display
                    if(!uniqueRERANumbers.isEmpty()) {
                        allRERANumbers = String.join(new List<String>(uniqueRERANumbers), ', ');
                    }
                    
                    
                    
                    bklist = [
                        SELECT Id, Name, Booking_Date__c, Agreement_Value_for_brokers__c, Wing__c,
                        Unit_Number__c, Tower__c, Customer_Name__c
                        FROM Booking__c
                        WHERE Id = :firstInv.Booking__c
                        LIMIT 1
                    ];
                    
                    if(!bklist.isEmpty() && bklist[0].Agreement_Value_for_brokers__c != null) {
                        AVValueStr = INFormat(bklist[0].Agreement_Value_for_brokers__c);
                    }
                    
                    if(!bklist.isEmpty() && bklist[0].Tower__c != null) {
                        tlist = [
                            SELECT Id, Name, Legal_Entity__c
                            FROM Tower__c
                            WHERE Id = :bklist[0].Tower__c
                            LIMIT 1
                        ];
                        
                        if(!tlist.isEmpty() && tlist[0].Legal_Entity__c != null) {
                            legalentity = [
                                SELECT Id, Name, RDS_Company_Code__c, RDS_Company_Name__c,
                                RDS_Address1__c, RDS_Address2__c, RDS_PAN_No__c,
                                GSTIN__c, RERA_Number__c
                                FROM Legal_Entity__c
                                WHERE Id = :tlist[0].Legal_Entity__c
                                LIMIT 1
                            ];
                        }
                    }
                    
                    System.debug('fetchInvoices - Additional details fetched: booking=' + bklist.size() + ', tower=' + tlist.size() + ', legal entity=' + legalentity.size());
                } catch (Exception e) {
                    System.debug('fetchInvoices - Error fetching additional details: ' + e.getMessage());
                }
            }
            
            // Fetch Brokerage Scheme if available
            if(firstInv.Brokerage_Summary__c != null) {
                try {
                    List<Brokerage_Summary__c> brokSummary = [
                        SELECT Id, Brokerage_Scheme__c
                        FROM Brokerage_Summary__c
                        WHERE Id = :firstInv.Brokerage_Summary__c
                        LIMIT 1
                    ];
                    
                    if(!brokSummary.isEmpty() && brokSummary[0].Brokerage_Scheme__c != null) {
                        brokerageScheme = [
                            SELECT Id, Name, Start_Date__c, End_Date__c
                            FROM Brokerage_Scheme__c
                            WHERE Id = :brokSummary[0].Brokerage_Scheme__c
                            LIMIT 1
                        ];
                    }
                    
                    System.debug('fetchInvoices - Brokerage scheme fetched: ' + brokerageScheme.size());
                } catch (Exception e) {
                    System.debug('fetchInvoices - Error fetching brokerage scheme: ' + e.getMessage());
                }
            }
            
            System.debug('fetchInvoices - Successfully completed data fetch');
            
        } catch (Exception e) {
            System.debug('fetchInvoices - Unexpected error: ' + e.getMessage() + '\n' + e.getStackTraceString());
            errormsg = 'Unexpected error occurred: ' + e.getMessage();
            isError1 = 1;
        }
    }
    
    /* public void dmlOperation() {
try {
System.debug('dmlOperation - Starting update for ' + CPInv.size() + ' invoices');

if(CPInv.isEmpty()) {
System.debug('dmlOperation - No invoices to update');
return;
}

for(Brokerage_Invoice__c inv : CPInv) {
inv.Invoice_Status__c = 'Invoice Downloaded';

if(showgst && istaxapplicable){
inv.CGST__c = String.valueOf(totalCGST);
inv.SGST__c = String.valueOf(totalSGST);
inv.IGST__c = '0';
} else if(showigst && istaxapplicable){
inv.IGST__c = String.valueOf(totalIGST);
inv.CGST__c = '0';
inv.SGST__c = '0';
} else {
inv.CGST__c = '0';
inv.SGST__c = '0';
inv.IGST__c = '0';
}
inv.Invoice_Amount__c = grandTotal;
}

update CPInv;
System.debug('dmlOperation - Successfully updated ' + CPInv.size() + ' invoices');

} catch (Exception e) {
System.debug('dmlOperation - Error updating invoices: ' + e.getMessage());
}
}
*/
    
    public void dmlOperation() {
        try {
            System.debug('dmlOperation - Starting update for ' + CPInv.size() + ' invoices');
            
            if(CPInv.isEmpty()) {
                System.debug('dmlOperation - No invoices to update');
                return;
            }
            
            // Create a map to easily find the wrapper for each invoice
            Map<Id, InvoiceWrapper> invoiceWrapperMap = new Map<Id, InvoiceWrapper>();
            for(InvoiceWrapper wrapper : invoiceWrappers) {
                invoiceWrapperMap.put(wrapper.invoice.Id, wrapper);
            }
            
            // Update individual invoices with THEIR OWN tax amounts and totals
            for(Brokerage_Invoice__c inv : CPInv) {
                inv.Invoice_Status__c = 'Invoice Downloaded';
                
                // Get the individual wrapper for this invoice
                InvoiceWrapper wrapper = invoiceWrapperMap.get(inv.Id);
                
                if(wrapper != null) {
                    // Set individual invoice amount
                    inv.Invoice_Amount__c = wrapper.totalWithTax;
                    
                    // SET INDIVIDUAL TAX AMOUNTS FOR EACH INVOICE
                    inv.CGST__c = String.valueOf(wrapper.cgstAmount);
                    inv.SGST__c = String.valueOf(wrapper.sgstAmount);
                   // inv.IGST__c = String.valueOf(wrapper.igstAmount);
                }
            }
            
            // Update all individual invoices with their correct amounts and tax values
            update CPInv;
            
            // Update CP Brokerage with TOTALS (sum of all child invoices)
            if(cpBrokerage != null) {
                // Set TOTALS on CP_Brokerage (sum of all child invoice amounts)
                cpBrokerage.CGST__c = String.valueOf(totalCGST);  // Total of all CGST
                cpBrokerage.SGST__c = String.valueOf(totalSGST);  // Total of all SGST  
              //  cpBrokerage.IGST__c = String.valueOf(totalIGST);  // Total of all IGST
                
                // Also update total amount on CP_Brokerage
                cpBrokerage.Total_Invoice_Amount__c = grandTotal; // Total of all invoice amounts
                cpBrokerage.Invoice_Status__c = 'Invoice Downloaded';
                
                update cpBrokerage;
            }
            
            System.debug('dmlOperation - Successfully updated individual invoice tax amounts and CP Brokerage totals');
            
        } catch (Exception e) {
            System.debug('dmlOperation - Error updating: ' + e.getMessage());
        }
    }
    
    public static String INFormat(Decimal money){
        if(money == null) money = 0;
        Boolean negative = (money < 0);
        Decimal tempMoney = Math.abs(money);
        String m0 = tempMoney.setScale(0, RoundingMode.HALF_UP).toPlainString();
        List<String> tempStr = m0.split('\\.');
        String m1 = tempStr[0].reverse();
        String mF = '';
        for(Integer i = 0; i < m1.length(); i++){
            mF += m1.substring(i, i + 1);
            if(i == 2 || i == 4 || i == 6 || i == 8 || i == 10 || i == 12) mF += ',';
        }
        mF = mF.reverse();
        if(mF.startsWith(',')) mF = mF.substring(1);
        if(negative) mF = '-' + mF;
        return mF;
    }
    
    public String getFormattedNumber(Decimal value) {
        return INFormat(value);
    }
}