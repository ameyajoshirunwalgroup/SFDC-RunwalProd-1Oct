public without sharing class CPBrokerageInvoiceDueUploadEmailCtrl {
    public String cpId{get;set;}
    public List<Broker__c> cpList {get;set;}
    public List<CP_Profile_Update__c> cpprofileupdate {get;set;}
    public String Recordurl{get;set;}
    public String ApprovalLink{get;set;}
    Public List<Brokerage_Invoice__c> CPInv {get;set;}
    Public List<Broker__c> ChannelPartner {get;set;}
    Public List<Booking__c> bklist {get;set;}
    Public List<Brokerage_Scheme__c> brokerageScheme{get;set;}
    Public List<Kicker_Incentive__c> KickerScheme{get;set;}
    public string errormsg {get;set;}
    public string errormsg2 {get;set;}
    public Integer isError1 {get;set;}
    public List<InvoiceWrapper> invoiceWrapper {get;set;}
    
    public CP_Brokerage__c cpBrokerage {get;set;}
    public List<AOP__c> aopDetails {get;set;}
    public List<Place_of_Supply__c> pos {get;set;}
    public Boolean istaxapplicable {get;set;}
    public Boolean showgst {get;set;}
    public Boolean showigst {get;set;}
    public Decimal totalCGST {get;set;}
    public Decimal totalSGST {get;set;}
    public Decimal totalIGST {get;set;}
    public Decimal grandTotal {get;set;}
    public Decimal totalBrokerageAmount {get;set;}
    public List<InvoiceWrapper> invoiceWrappers {get;set;}
    public String BrokerageAmtStr {get;set;}
    public String TotalwithTaxStr {get;set;}
    public String CgstStr {get;set;}
    public String SgstStr {get;set;}
    public String IgstStr {get;set;}
    public String NoToWord {get;set;}
    public Boolean GSTApplicable {get;set;}
    public Set<String> uniqueRERANumbers = new Set<String>();
    public String allRERANumbers { get; set; }
    public List<Tower__c> tlist {get;set;}
    public String AVValueStr {get;set;}
    public Boolean Base {get;set;}
    
    
    
    
    Public static list<Legal_Entity__c> legalentity{get;set;}
    Public static list<Project__c> ProjectList{get;set;}
    public CPBrokerageInvoiceDueUploadEmailCtrl(){
        brokerageScheme = new List<Brokerage_Scheme__c>();
        aopDetails = new List<AOP__c>();
        pos = new List<Place_of_Supply__c>();
        showgst = false;
        showigst = false;
        istaxapplicable = false;
        totalCGST = 0;
        totalSGST = 0;
        totalIGST = 0;
        grandTotal = 0;
        totalBrokerageAmount = 0;
        
        if(Test.isRunningTest()){
            //cpId = apexpages.currentpage().getparameters().get('cpId'); 
            //getcpupdate();
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
                     ORDER BY CreatedDate DESC
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
    
    
    public void dmlOperation() {
        try {
            // Null Check 1: Ensure lists exist
            if(CPInv == null || CPInv.isEmpty() || invoiceWrappers == null) {
                System.debug('dmlOperation - No data to process');
                return;
            }
            
            // Create map safely
            Map<Id, InvoiceWrapper> invoiceWrapperMap = new Map<Id, InvoiceWrapper>();
            for(InvoiceWrapper wrapper : invoiceWrappers) {
                if(wrapper != null && wrapper.invoice != null) {
                    invoiceWrapperMap.put(wrapper.invoice.Id, wrapper);
                }
            }
            
            for(Brokerage_Invoice__c inv : CPInv) {
                inv.Invoice_Status__c = 'Invoice Downloaded';
                InvoiceWrapper wrapper = invoiceWrapperMap.get(inv.Id);
                
                if(wrapper != null) {
                    inv.Invoice_Amount__c = wrapper.totalWithTax;
                    // Safely handle String conversion for CGST/SGST/IGST
                    inv.CGST__c = wrapper.cgstAmount != null ? String.valueOf(wrapper.cgstAmount) : '0';
                    inv.SGST__c = wrapper.sgstAmount != null ? String.valueOf(wrapper.sgstAmount) : '0';
                    inv.IGST__c = wrapper.igstAmount != null ? String.valueOf(wrapper.igstAmount) : '0';
                }
            }
            
            update CPInv;
            
            if(cpBrokerage != null) {
                // Safely set totals on parent
                cpBrokerage.CGST__c = String.valueOf(totalCGST != null ? totalCGST : 0);
                cpBrokerage.SGST__c = String.valueOf(totalSGST != null ? totalSGST : 0);
                cpBrokerage.IGST__c = String.valueOf(totalIGST != null ? totalIGST : 0);
                cpBrokerage.Total_Invoice_Amount__c = grandTotal != null ? grandTotal : 0;
                cpBrokerage.Invoice_Status__c = 'Invoice Downloaded';
                
                update cpBrokerage;
            }
        } catch (Exception e) {
            System.debug('dmlOperation Error: ' + e.getMessage() + ' at ' + e.getLineNumber());
            this.errormsg = 'Update failed: ' + e.getMessage();
        }
    }
    
    public void getbooking(){
        
        //Recordurl = 'https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/Brokerage_Invoice__c/'+cpId+'/view';
        Recordurl = 'https://'+ URL.getOrgDomainUrl().getHost() + '/lightning/r/CP_Brokerage__c/'+cpId+'/view';
        ApprovalLink = generateApprovalURL(cpId);
        //offerdetailmethod();
        
    }
    public static String generateApprovalURL(String recordID){
        String url='';
        List<ProcessInstanceWorkitem> workItemLst = [SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recordID];
        if(workItemLst.size() > 0){
            //url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/ProcessInstanceWorkitem/' + workItemLst[0].id+'/view';
            url='https://'+ Site.getDomain() + '/lightning/r/ProcessInstanceWorkitem/' + workItemLst[0].id+'/view';
        }
        return url;
    }
    /*public void getcpupdate(){
        system.debug('cpId::'+cpId);
        //Map<Id,CP_Brokerage__c> cpBrokerageInvoices = new Map<Id,CP_Brokerage__c>([SELECT Id,Name,Channel_Partner__c FROM CP_Brokerage__c WHERE Id = 'a0Q9I00000Gfb2QUAR']);
        //cpId = 'a0Q9I00000Gfb2QUAR';
        if(cpId != null) {
            fetchInvoices(cpId);
            
            if(isError1 == 0 && !CPInv.isEmpty()) {
                Base = true;
                System.debug('CP_InvoicePreview - Base set to true, CPInv size: ' + CPInv.size());
                
                this.invoiceWrappers = new List<InvoiceWrapper>(); 
                
                for(Brokerage_Invoice__c inv : CPInv){
                    // Use parameterized constructor to handle AOP logic
                    InvoiceWrapper invWrap = new InvoiceWrapper(inv, showgst, istaxapplicable, cpBrokerage, aopDetails);
                    
                    // Add extra flags needed for the repeat loop
                    if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Base Brokerage') invWrap.Base = true;
                    else if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Additional Brokerage') invWrap.Additional = true;
                    
                    this.invoiceWrappers.add(invWrap);
            }
                
                dmlOperation(); 
            } else {
                System.debug('CP_InvoicePreview - Base remains false, isError1: ' + isError1 + ', CPInv size: ' + CPInv.size());
            }
        } 
        else {
            errormsg = 'No CP Brokerage ID provided in URL parameter.';
            isError1 = 1;
            System.debug('CP_InvoicePreview - No ID parameter found');
        }
        
        CPInv = [Select id,Name,Approval_Status__c,Brokerage__c,Brokerage_In_Rs__c,Brokerage_Summary__c,Channel_Partner__c,If_GST_is_applicable__c,Invoice_Number__c,
                 Invoice_Status__c,Total_Agreement_Value__c,Booking__c,Opportunity__c,Booking__r.Project__r.Name,Booking__r.Unit_No__r.RW_Param4__c,Booking__r.Booking_Date__c,
                 Booking__r.Unit_No__r.RW_Param2__c,Channel_Partner__r.State__c,Place_of_Supply__c,Eligible_Slab__c,Brokerage_Summary__r.Brokerage_Scheme__c,Booking__r.Unit_Number__c,
                 Brokerage_Lookup__r.Brokerage_Type__c,Project__c,CGST__c,SGST__c,IGST__c,Invoice_Amount__c,Brokerage_Summary__r.Kicker_Incentive__c,Channel_Partner__r.Name,
                 Invoice_Date__c,RW_Eligible_Slab__c,CP_Name__c,Customer_Name__c from Brokerage_Invoice__c where CP_Brokerage__c =: cpId];
        System.debug('CPInv.size(): ' + CPInv.size());
        ChannelPartner = [Select id,Name,Broker_Pan_No__c,RW_RERA_Registration_Number__c,Address__c,RW_GST_Number__c,RW_Mobile_No__c,SAP_CP_Code__c,RW_Email__c,
                          Bank_Branch__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Cheque_DD_Favouring_Name__c from Broker__c where id=:CPInv[0].Channel_Partner__c];
        brokerageScheme = [Select Id,Name,Start_Date__c,End_Date__c from Brokerage_Scheme__c where Id=:CPInv[0].Brokerage_Summary__r.Brokerage_Scheme__c];
        KickerScheme = [Select Id,Name,Start_Date__c,End_Date__c,Type__c from Kicker_Incentive__c where Id=:CPInv[0].Brokerage_Summary__r.Kicker_Incentive__c];
        bklist = [Select Id,Name,Booking_Date__c,Agreement_Value_for_brokers__c,Wing__c,Unit_Number__c From Booking__c where Id=:CPInv[0].Booking__c];
        //BrokerageAmtStr = INFormat(CPInv[0].Brokerage_In_Rs__c);
        invoiceWrapper = new List<InvoiceWrapper>();
        for(Brokerage_Invoice__c inv : CPInv){
            InvoiceWrapper invWrap = new InvoiceWrapper();
            invWrap.invoice = inv;
            invWrap.BrokerageAmtStr = INFormat(inv.Brokerage_In_Rs__c);
            if(inv.Brokerage_Lookup__r.Brokerage_Type__c != 'Kicker Incentive'){
                if(inv.If_GST_is_applicable__c == 'Yes' ){
                    invWrap.Cgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Sgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Igst = (invWrap.Cgst + invWrap.Sgst).setscale(2,RoundingMode.HALF_UP);
                    invWrap.CgstStr = INFormat(invWrap.Cgst);
                    invWrap.SgstStr = INFormat(invWrap.Sgst);
                    invWrap.IgstStr = INFormat(invWrap.Igst);
                    invWrap.AVValueStr = INFormat(inv.Total_Agreement_Value__c);
                    invWrap.TotalwithTax = invWrap.Cgst + invWrap.Sgst + inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = true;
                }else{
                    invWrap.TotalwithTax = inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.AVValueStr = INFormat(inv.Total_Agreement_Value__c);
                    invWrap.GSTApplicable = false;
                }
            }else{
                if(inv.If_GST_is_applicable__c == 'Yes' ){
                    invWrap.Cgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Sgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Igst = (invWrap.Cgst + invWrap.Sgst).setscale(2,RoundingMode.HALF_UP);
                    invWrap.CgstStr = INFormat(invWrap.Cgst);
                    invWrap.SgstStr = INFormat(invWrap.Sgst);
                    invWrap.IgstStr = INFormat(invWrap.Igst);
                    invWrap.TotalwithTax = invWrap.Cgst + invWrap.Sgst +inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = true;
                }else{
                    invWrap.TotalwithTax = inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = false;
                }
            }
            if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Base Brokerage'){
                invWrap.Base = True;
            }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Additional Brokerage' || inv.Brokerage_Lookup__r.Brokerage_Type__c=='Retrofit Brokerage'){
                invWrap.Additional = True;
            }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Kicker Incentive'){
                invWrap.Kicker = True;
            }
            if(inv.If_GST_is_applicable__c == 'Yes'){
                invWrap.istaxapplicable = true;
            }else{
                invWrap.istaxapplicable = false;
            }
            if(inv.Place_of_Supply__c == 'Maharashtra'){
                invWrap.showgst = true;
                invWrap.showigst = false;
            }else{
                invWrap.showgst = false;
                invWrap.showigst = true;
            }
            
            invoiceWrapper.add(invWrap);
        }
        
    }*/
    
    
    public void getcpupdate() {
    System.debug('cpId::' + cpId);
    
    // 1. Initialize the plural list immediately to avoid NULL errors in VF
    this.invoiceWrappers = new List<InvoiceWrapper>(); 
    
    if(cpId != null) {
        fetchInvoices(cpId);
        
        if(isError1 == 0 && CPInv != null && !CPInv.isEmpty()) {
            Base = true;
            
            // 2. Loop through and populate the wrappers
            for(Brokerage_Invoice__c inv : CPInv) {
                // Parameterized constructor handles tax and AOP logic
                InvoiceWrapper invWrap = new InvoiceWrapper(inv, showgst, istaxapplicable, cpBrokerage, aopDetails);
                
                // Set flags for different brokerage types so they show in the main table
                String bType = inv.Brokerage_Lookup__r.Brokerage_Type__c;
                if(bType == 'Base Brokerage') {
                    invWrap.Base = true;
                } else if(bType == 'Additional Brokerage' || bType == 'Retrofit Brokerage') {
                    invWrap.Additional = true;
                } else if(bType == 'Kicker Incentive') {
                    invWrap.Kicker = true;
                }
                
                // Add to the plural list used by the Visualforce Component
                this.invoiceWrappers.add(invWrap);
            }
            
            // 3. Perform status update
            dmlOperation(); 
        }
    } else {
        errormsg = 'No CP Brokerage ID provided.';
        isError1 = 1;
    }
}
    
    
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(0,RoundingMode.HALF_UP).toPlainString();
        system.debug('M0::-'+m0);
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() ==2) {
                decimalPart = tempStr[1];
            }
        }
        
        //String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String m1 = tempStr[0].reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
            if(i==2) {
                mF += ',';
            }
            if(i==4 || i==6 || i==8 || i==10 || i==12) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        //  if(String.isNotBlank(decimalPart)) 
        //     mf = mf + '.'  + decimalPart;
        
        if(!negative)
            mf =  mf; //+ '/-';
        else
            mf =  mf; // + '/-'; // '- ' + Removed by Aniket as on 30-11-2021 because of double negative sign 
        return mf;
    }
    
    
    public class InvoiceWrapper{
        public String AVValueStr {get;set;}
        public String TotalStr {get;set;}
        public String NoToWord {get;set;}
        public Decimal Total {get;set;}
        public Boolean Base {get;set;}
        public Boolean Additional {get;set;}
        public Boolean Kicker {get;set;}
        public Boolean istaxapplicable {get;set;}
        public String dateStr {get;set;}
        public Decimal Cgst {get;set;}
        public Decimal Sgst {get;set;}
        public Decimal Igst {get;set;}
        public Decimal TotalwithTax {get;set;}
        public String BrokerageAmtStr {get;set;}
        public String TotalwithTaxStr {get;set;}
        public String CgstStr {get;set;}
        public String SgstStr {get;set;}
        public String IgstStr {get;set;}
        public Boolean GSTApplicable {get;set;}
        public Boolean showgst {get;set;}
        public Boolean showigst {get;set;}
        public Brokerage_Invoice__c invoice {get;set;}
        public Decimal brokerageAmount {get;set;}
        public Decimal cgstAmount {get;set;}
        public Decimal sgstAmount {get;set;}
        public Decimal igstAmount {get;set;}
        public Decimal brokeragePercentage {get;set;}
        
        public InvoiceWrapper() {
            this.Base = false;
            this.Additional = false;
            this.Kicker = false;
            this.cgstAmount = 0;
            this.sgstAmount = 0;
            this.igstAmount = 0;
        }
        
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
    
}