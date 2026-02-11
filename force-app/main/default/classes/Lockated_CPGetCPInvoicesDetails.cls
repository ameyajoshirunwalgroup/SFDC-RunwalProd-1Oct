@RestResource(urlMapping='/cpGetCPInvoicesDetails/*')
global without sharing class Lockated_CPGetCPInvoicesDetails {
    @HttpGet
    global static void doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String cpId = req.params.get('cpId');
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(cpId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                Wrapper resp = new Wrapper();
                ResponseWrapperTotal totalDetailsWrapper = new ResponseWrapperTotal();
                
                list<CP_Brokerage__c> invlist = [Select id,Total_Invoice_Amount__c,Total_Amount_Paid__c,SAP_Document_No__c,Total_Brokerage__c, SAP_Posting_Date__c, If_GST_is_applicable__c, Approval_Status__c,
                                                      Invoice_Date__c,Invoice_Number__c,Status__c,Brokerage_Type__c, AOP__r.Name, AOP__r.AOP_Schemes__r.Name,AOP__r.Commitment_max__c,Company_Name__c, Approval_Status_clearing__c,
                                                      Invoice_Status__c, Tower_Unit__c,Brokerage_Scheme_Name__c,Brokerage__c,Invoice_Status_CP_Portal__c,SO_Number__c,
                                                               SAP_Broker_code__c,Customer_Code__c,(Select id,Booking__c,Invoice_Amount__c,Total_Amount_Paid__c,Brokerage_Lookup__r.Brokerage_Type__c,SAP_Document_No__c,
                                                      Customer_Name__c,Project__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Date__c,Invoice_Number__c,Status__c,CreatedDate,
                                                      Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Booking__r.Booking_Date__c,Booking__r.Name,Opportunity__r.Name,
                                                      Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c,Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c, Booking__r.Allotment_Premium__c,
                                                      Opportunity__c, CP_Brokerage__c, Brokerage_Summary__r.Brokerage_Scheme__r.Name, Brokerage_Summary__r.Brokerage_Scheme__c, Brokerage_Summary__c,
                                                      Booking__r.Payment_Received__c,Booking__r.RW_Registration_Status__c from Brokerage_Invoices__r) from CP_Brokerage__c   where Channel_Partner__c =: cpId ];
                
                Date baseBrkCutoffDate = Date.valueOf(label.Base_Brokerage_Cut_off_Date);
                Date ladderBrkCutoffDate = Date.valueOf(label.Ladder_Brokerage_Cut_off_Date);
                
                list<Brokerage_Invoice__c> brokerageinvlist = [Select id,Booking__c,Invoice_Amount__c,Total_Amount_Paid__c,Brokerage_Lookup__r.Brokerage_Type__c,SAP_Document_No__c,
                                                      Customer_Name__c,Project__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Date__c,Invoice_Number__c,Status__c,CreatedDate,
                                                      Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Booking__r.Booking_Date__c,Booking__r.Name,Opportunity__r.Name,SAP_Posting_Date__c,
                                                      If_GST_is_applicable__c,Approval_Status__c,Tower_Unit__c,Brokerage_Scheme_Name__c,Brokerage__c,SO_Number__c,SAP_Broker_code__c,
                                                      Customer_Code__c,Approval_Status_clearing__c,
                                                      Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c,Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c, Booking__r.Allotment_Premium__c,
                                                      Opportunity__c, CP_Brokerage__c, Brokerage_Summary__r.Brokerage_Scheme__r.Name, Brokerage_Summary__r.Brokerage_Scheme__c, Brokerage_Summary__c,
                                                      Booking__r.Payment_Received__c,Booking__r.RW_Registration_Status__c from Brokerage_Invoice__c  where 
                                                      Channel_Partner__c =: cpId and CP_Brokerage__c = null and Brokerage_Lookup__r.Brokerage_Type__c != null 
                                                      AND (
                                                            (Brokerage_Lookup__r.Brokerage_Type__c = 'Base Brokerage' AND CreatedDate <= :baseBrkCutoffDate)
                                                            OR 
                                                            (Brokerage_Lookup__r.Brokerage_Type__c = 'Additional Brokerage' AND CreatedDate <= :ladderBrkCutoffDate)
                                                        )];
                
                
                Map<String, wrapperBrokerage> invoiceMapNew = new Map<String, wrapperBrokerage>();
                invoiceMapNew.put('paid', new wrapperBrokerage());
                invoiceMapNew.put('invoiceRaised', new wrapperBrokerage());
                invoiceMapNew.put('dueEligibleForInvoicing', new wrapperBrokerage());
                invoiceMapNew.put('notdue', new wrapperBrokerage());
                //New Invoices (CP Brokerage) Start Here..
                if(!invlist.isEmpty()){
                    for(CP_Brokerage__c inv : invlist){
                        if(inv.Status__c == 'Paid' && inv.SAP_Document_No__c != null){//Paid
                            invoiceMapNew.get('paid').cpBrokerageList.add(inv);
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c == 'Invoice Uploaded'){//Invoice Raised
                            invoiceMapNew.get('invoiceRaised').cpBrokerageList.add(inv);
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c != 'Invoice Uploaded' && (inv.Approval_Status_clearing__c == 'Approved By L1' || inv.Approval_Status_clearing__c == 'Approved By L2')){//dueEligibleForInvoicing
                            invoiceMapNew.get('dueEligibleForInvoicing').cpBrokerageList.add(inv);
                        }
                        else{
                            invoiceMapNew.get('notdue').cpBrokerageList.add(inv);
                        }
                    }
                }        
                //New Invoices(CP Brokerage) Logic Ends Here..
                //Old Invoices(Brokerage Invoice) Logic Starts Here..
                if(!brokerageinvlist.isEmpty()){
                    for(Brokerage_invoice__c inv : brokerageinvlist){                        
                        //Old Invoices
                        if(inv.Status__c == 'Paid' && inv.SAP_Document_No__c != null){//Paid
                            invoiceMapNew.get('paid').brokerageInvList.add(inv);
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c == 'Invoice Uploaded'){//Invoice Raised
                            invoiceMapNew.get('invoiceRaised').brokerageInvList.add(inv);
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c != 'Invoice Uploaded' && (inv.Approval_Status_clearing__c == 'Approved By L1' || inv.Approval_Status_clearing__c == 'Approved By L2')){//Due
                            invoiceMapNew.get('dueEligibleForInvoicing').brokerageInvList.add(inv);
                        }
                        else{
                            invoiceMapNew.get('notdue').brokerageInvList.add(inv);
                        }                        
                    }
                }
                //Old Invoices(Brokerage Invoice) Logic Ends Here..
                if(invlist.isEmpty() && brokerageinvlist.isEmpty()){
					errorResult.put('status', 'error');
                    errorResult.put('message', 'No CP Brokerage Record Found Against CPID');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 404; // Not Found
                    return; // Stop execution                    
                }
                
                //
                list<TotalInvDetails> tlist = new list<TotalInvDetails>();
                //New Invoices(CP Brokerage) Logic
                 if(!invoiceMapNew.isEmpty()){                    
                    for(String sts : invoiceMapNew.keySet()){
                        Details details = new Details();
                        list<InvDetailsForBase> blist = new list<InvDetailsForBase>();
                        list<InvDetailsForLadder> llist = new list<InvDetailsForLadder>();
                        list<InvDetailsForAOP> alist = new list<InvDetailsForAOP>();
                        Decimal totalAmount = 0;
                        Decimal baseTotalAmount = 0;
                        Decimal ladderTotalAmount = 0;
                        Decimal aopTotalAmount = 0;
                        if(invoiceMapNew.containsKey(sts) && !invoiceMapNew.get(sts).cpBrokerageList.isEmpty()){
                            for(CP_Brokerage__c inv : invoiceMapNew.get(sts).cpBrokerageList){
                                InvDetailsForBase base = new InvDetailsForBase();
                                InvDetailsForLadder ladder = new InvDetailsForLadder();
                                InvDetailsForAOP aop = new InvDetailsForAOP();
                                // For TotalDetails In wrapper
                                TotalInvDetails totalDetails = new TotalInvDetails();
                                // totalDetails.invdate = inv.Invoice_Date__c;
                                // *** DATE FIX FOR Invoice ***
                                if(inv.Invoice_Date__c != null) {
                                    Date d = Date.valueOf(inv.Invoice_Date__c);
                                    DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                    totalDetails.invdate = dt.format('dd-MM-yyyy');
                                } else {
                                    totalDetails.invdate = null;
                                }
                                // totalDetails.invoiceNo = inv.Invoice_Number__c;
                                totalDetails.transactionName = null;
                                totalDetails.brokerageAmount = inv.Total_Brokerage__c;
                                // totalDetails.statementUrl = null;
                                totalDetails.status = sts;
                                if(sts == 'paid'){
                                    totalDetails.status = 'Paid';
                                }else if(sts == 'invoiceRaised'){
                                    totalDetails.status = 'Invoice Raised';
                                }
                                else if(sts == 'dueEligibleForInvoicing'){
                                    totalDetails.status = 'Due Eligible For Invoicing';
                                }
                                else if(sts == 'notdue'){
                                    totalDetails.status = 'Not Due';
                                }
                                tlist.add(totalDetails);
                                // End For TotatlDetails In Wrapper
                                if(!inv.brokerage_invoices__r.isEmpty()){
                                    if(inv.Total_Brokerage__c!=null){
                                        totalAmount += inv.Total_Brokerage__c;
                                    }
                                    if(inv.Brokerage_Type__c == 'Base Brokerage'){
                                        assignBaseBrokerage(base,inv,inv.brokerage_invoices__r);
                                        if(inv.Total_Brokerage__c!=null){
                                            baseTotalAmount += inv.Total_Brokerage__c;
                                        }
                                        blist.add(base); 
                                    }else if(inv.Brokerage_Type__c == 'Additional Brokerage'){
                                        assignLadderBrokerage(ladder,inv,inv.brokerage_invoices__r);
                                        if(inv.Total_Brokerage__c!=null){
                                            ladderTotalAmount += inv.Total_Brokerage__c;
                                        }
                                        llist.add(ladder);
                                    }else if(inv.Brokerage_Type__c == 'AOP Brokerage'){
                                        assignAOPBrokerage(aop,inv,inv.brokerage_invoices__r);
                                        if(inv.Total_Brokerage__c!=null){
                                            aopTotalAmount += inv.Total_Brokerage__c;
                                        }
                                        alist.add(aop);
                                    }
                                }
                            }
                    	}
                        if(invoiceMapNew.containsKey(sts) && !invoiceMapNew.get(sts).brokerageInvList.isEmpty()){
                            for(Brokerage_invoice__c inv : invoiceMapNew.get(sts).brokerageInvList){
                                InvDetailsForBase base = new InvDetailsForBase();
                                InvDetailsForLadder ladder = new InvDetailsForLadder();
                                InvDetailsForAOP aop = new InvDetailsForAOP();
                                // For TotalDetails In wrapper
                                TotalInvDetails totalDetails = new TotalInvDetails();
                                // totalDetails.invdate = inv.Invoice_Date__c;
                                // *** DATE FIX FOR Invoice ***
                                if(inv.Invoice_Date__c != null) {
                                    Date d = Date.valueOf(inv.Invoice_Date__c);
                                    DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                                    totalDetails.invdate = dt.format('dd-MM-yyyy');
                                } else {
                                    totalDetails.invdate = null;
                                }
                                // totalDetails.invoiceNo = inv.Invoice_Number__c;
                                totalDetails.transactionName = null;
                                totalDetails.brokerageAmount = inv.Brokerage_In_Rs__c;
                                // totalDetails.statementUrl = null;
                                totalDetails.status = sts;
                                if(sts == 'paid'){
                                    totalDetails.status = 'Paid';
                                }else if(sts == 'invoiceRaised'){
                                    totalDetails.status = 'Invoice Raised';
                                }
                                else if(sts == 'dueEligibleForInvoicing'){
                                    totalDetails.status = 'Due Eligible For Invoicing';
                                }
                                else if(sts == 'notdue'){
                                    totalDetails.status = 'Not Due';
                                }
                                tlist.add(totalDetails);
                                // End For TotatlDetails In Wrapper
                                if(inv.Brokerage_In_Rs__c!=null){
                                    totalAmount += inv.Brokerage_In_Rs__c;
                                }
                                //if(parentToChildMap.containsKey(inv.id)){
                                    if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Base Brokerage'){
                                        assignBaseBrokerageBI(base,inv);
                                        if(inv.Brokerage_In_Rs__c !=null){
                                            baseTotalAmount += inv.Brokerage_In_Rs__c;
                                        }
                                        blist.add(base); 
                                    }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Additional Brokerage'){
                                        assignLadderBrokerageBI(ladder,inv);
                                        if(inv.Brokerage_In_Rs__c !=null){
                                            ladderTotalAmount += inv.Brokerage_In_Rs__c;
                                        }
                                        llist.add(ladder);
                                    }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'AOP Brokerage'){
                                        assignAOPBrokerageBI(aop,inv);
                                        if(inv.Brokerage_In_Rs__c !=null){
                                            aopTotalAmount += inv.Brokerage_In_Rs__c;
                                        }
                                        alist.add(aop);
                                    }
                               // }
                            }
                        }
                        ResponseWrapper responsewrapper = new ResponseWrapper();
                        details.BaseDetails = blist;
                        details.LadderDetails = llist;
                        details.AOPDetails = alist;
                        responsewrapper.details = details;
                        responsewrapper.totalPaid = totalAmount;
                        responsewrapper.base = baseTotalAmount;
                        responsewrapper.ladder = ladderTotalAmount;
                        responsewrapper.aop = aopTotalAmount;
                        if(sts == 'paid'){
                        	resp.paid = responsewrapper;
                            totalDetailsWrapper.paid = responsewrapper.totalpaid;
                        }
                        if(sts == 'invoiceRaised'){
                        	resp.invoiceRaised = responsewrapper;
                            totalDetailsWrapper.invRaised = responsewrapper.totalpaid;
                        }
                        if(sts == 'dueEligibleForInvoicing'){
                        	resp.dueEligibleForInvoicing = responsewrapper;
                            totalDetailsWrapper.due = responsewrapper.totalpaid;
                        }
                        if(sts == 'notdue'){
                        	resp.notdue = responsewrapper;
                            totalDetailsWrapper.notdue = responsewrapper.totalpaid;
                        }
                    }
                    //totalDetailsWrapper.details = tlist;
                    //resp.totalDetails = totalDetailsWrapper;
                }
                
                totalDetailsWrapper.details = tlist;
                resp.totalDetails = totalDetailsWrapper;
                
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
                res.statusCode = 200;
            }
            catch(Exception ex){
                errorResult.put('status', 'error');
                errorResult.put('message', ex.getMessage() + ';  ' + ex.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 500;
            }
        }
    }
    
    private static void assignBaseBrokerage(InvDetailsForBase base,CP_Brokerage__c cpBrokerage, List<Brokerage_Invoice__c> brokerageInvoice){
        base.brokerageAmount = cpBrokerage.Total_Brokerage__c;
        // base.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(cpBrokerage.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            base.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            base.invoiceProcessDate = null;
        }
        base.invoiceNo = cpBrokerage.Invoice_Number__c;
        base.invId = cpBrokerage.id;
        base.isGstAppilcable = cpBrokerage.If_GST_is_applicable__c;
        // base.invDate = cpBrokerage.Invoice_Date__c;
        if(cpBrokerage.Invoice_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            base.invDate = dt.format('dd-MM-yyyy');
        } else {
            base.invDate = null;
        }
        base.approvalStatus = cpBrokerage.Approval_Status__c;
        base.invoiceStatus = cpBrokerage.Status__c;
        base.towerUnit = cpBrokerage.Tower_Unit__c;
        base.schemeName = cpBrokerage.Brokerage_Scheme_Name__c;
        base.brokerage = cpBrokerage.Brokerage__c;
        base.totalInvAmount = cpBrokerage.Total_Invoice_Amount__c;
        base.salesOrderNumber = cpBrokerage.SO_Number__c;
        base.invoiceStatusPortal = cpBrokerage.Invoice_Status_CP_Portal__c;
        base.cpBrokerCode = cpBrokerage.SAP_Broker_code__c;
        base.customerNumber = cpBrokerage.Customer_Code__c;
        if(!brokerageInvoice.isEmpty()){
            base.avValueForBrokerage = 0;
            for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                base.customerName = brokerageInvoiceObj.Customer_Name__c;
                base.projectName = brokerageInvoiceObj.Project__c;
                if(brokerageInvoiceObj.Booking__r.Payment_Received__c!=null){
                    base.percentagePaidByCustomer = brokerageInvoiceObj.Booking__r.Payment_Received__c;
                }
                if(brokerageInvoiceObj.Booking__r.RW_Registration_Status__c!=null){
                    base.registrationStatus = brokerageInvoiceObj.Booking__r.RW_Registration_Status__c;
                }
                if(brokerageInvoiceObj.Booking__r.Booking_Date__c !=null){
                    Date d = brokerageInvoiceObj.Booking__r.Booking_Date__c.date();
                    base.bookingDate = DateTime.newInstance(d.year(), d.month(), d.day()).format('dd/MM/yyyy');
                }
                if(brokerageInvoiceObj.Total_Agreement_Value__c!=null){
                	base.avValueForBrokerage += brokerageInvoiceObj.Total_Agreement_Value__c;
                }
                return;//As Base Brokerage Always One on One Relationship
            }
        } 
    }
    
    public static void assignAOPBrokerage(InvDetailsForAOP aop,CP_Brokerage__c cpBrokerage, List<Brokerage_Invoice__c> brokerageInvoice){
        if(cpBrokerage.AOP__c!=null && cpBrokerage.AOP__r.AOP_Schemes__c!=null){
            aop.fyOfAOPScheme = cpBrokerage.AOP__r.AOP_Schemes__r.Name;
        }
        if(cpBrokerage.AOP__c!=null && cpBrokerage.AOP__r.Commitment_max__c != null){
            aop.aopAmout = cpBrokerage.AOP__r.Commitment_max__c;
        }
        aop.runwalEntity = cpBrokerage.Company_Name__c;
        aop.brokerageAmount = cpBrokerage.Total_Brokerage__c;
        // aop.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(cpBrokerage.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            aop.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            aop.invoiceProcessDate = null;
        }
        aop.invId = cpBrokerage.id;
        aop.isGstAppilcable = cpBrokerage.If_GST_is_applicable__c;
        // aop.invDate = cpBrokerage.Invoice_Date__c;
        if(cpBrokerage.Invoice_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            aop.invDate = dt.format('dd-MM-yyyy');
        } else {
            aop.invDate = null;
        }
        aop.approvalStatus = cpBrokerage.Approval_Status__c;
        aop.invoiceStatus = cpBrokerage.Status__c;
        if(!brokerageInvoice.isEmpty()){
            aop.avValueForBrokerage = 0;
            aop.achievedRevenue = 0; 
            for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                if(brokerageInvoiceObj.Total_Agreement_Value__c!=null){
                	aop.avValueForBrokerage += brokerageInvoiceObj.Total_Agreement_Value__c;
                }
                if(brokerageInvoiceObj.Booking__c!=null && brokerageInvoiceObj.Booking__r.Allotment_Premium__c!=null){
                    aop.achievedRevenue += brokerageInvoiceObj.Booking__r.Allotment_Premium__c;
                }
            }
        }
    }
    
    public static void assignLadderBrokerage(InvDetailsForLadder ladder,CP_Brokerage__c cpBrokerage, List<Brokerage_Invoice__c> brokerageInvoice){
        ladder.brokerageAmount = cpBrokerage.Total_Brokerage__c;
        // ladder.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(cpBrokerage.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            ladder.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            ladder.invoiceProcessDate = null;
        }
        ladder.invId = cpBrokerage.id;
        ladder.isGstAppilcable = cpBrokerage.If_GST_is_applicable__c;
        // ladder.invDate = cpBrokerage.Invoice_Date__c;
        if(cpBrokerage.Invoice_Date__c != null) {
            Date d = Date.valueOf(cpBrokerage.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            ladder.invDate = dt.format('dd-MM-yyyy');
        } else {
            ladder.invDate = null;
        }
        ladder.approvalStatus = cpBrokerage.Approval_Status__c;
        ladder.invoiceStatus = cpBrokerage.Status__c;
        if(!brokerageInvoice.isEmpty()){
            for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                if(brokerageInvoiceObj.Brokerage_Summary__c!=null && brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__c!=null){
                    ladder.schemeName = brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.Name; // Condiering the Brokerage Scheme is Same for ALL Invoices Against Same CP Invoice
                }
                if(brokerageInvoiceObj.Brokerage_Summary__c!=null && brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__c!=null){
                    // ladder.startDate = brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c; // Condiering the Brokerage Scheme is Same for ALL Invoices Against Same CP Invoice
                    // ladder.endDate = brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c;
                    if(brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c != null) {
                        Date d = Date.valueOf(brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c);
                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                        ladder.startDate = dt.format('dd-MM-yyyy');
                    } else {
                        ladder.startDate = null;
                    }
                    if(brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c != null) {
                        Date d = Date.valueOf(brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c);
                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                        ladder.endDate = dt.format('dd-MM-yyyy');
                    } else {
                        ladder.endDate = null;
                    }
                }
                if(brokerageInvoiceObj.Project__c!=null){
                    ladder.projectName.add(brokerageInvoiceObj.Project__c);
                }
                if(brokerageInvoiceObj.Booking__c != null && brokerageInvoiceObj.Booking__r.Name!=null){
                    ladder.bookingEligble.add(brokerageInvoiceObj.Booking__r.Name);
                }
            }
        }
    }
    
    
    public static void assignBaseBrokerageBI(InvDetailsForBase base,Brokerage_Invoice__c brokerageInvoice){
        base.brokerageAmount = brokerageInvoice.Brokerage_In_Rs__c;
        // base.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(brokerageInvoice.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            base.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            base.invoiceProcessDate = null;
        }
        base.invoiceNo = brokerageInvoice.Invoice_Number__c;
        base.invId = brokerageInvoice.id;
        base.isGstAppilcable = brokerageInvoice.If_GST_is_applicable__c;
        // base.invDate = cpBrokerage.Invoice_Date__c;
        if(brokerageInvoice.Invoice_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            base.invDate = dt.format('dd-MM-yyyy');
        } else {
            base.invDate = null;
        }
        base.approvalStatus = brokerageInvoice.Approval_Status__c;
        base.invoiceStatus = brokerageInvoice.Status__c;
        base.towerUnit = brokerageInvoice.Tower_Unit__c;
        base.schemeName = brokerageInvoice.Brokerage_Scheme_Name__c;
        base.brokerage = brokerageInvoice.Brokerage__c;
        base.totalInvAmount = brokerageInvoice.Invoice_Amount__c;
        base.salesOrderNumber = brokerageInvoice.SO_Number__c;
        base.invoiceStatusPortal = brokerageInvoice.Invoice_Status_Brokerage_invoice__c;
        base.cpBrokerCode = brokerageInvoice.SAP_Broker_code__c;
        base.customerNumber = brokerageInvoice.Customer_Code__c;
        //if(!brokerageInvoice.isEmpty()){
            base.avValueForBrokerage = 0;
            //for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                base.customerName = brokerageInvoice.Customer_Name__c;
                base.projectName = brokerageInvoice.Project__c;
                if(brokerageInvoice.Booking__r.Payment_Received__c!=null){
                    base.percentagePaidByCustomer = brokerageInvoice.Booking__r.Payment_Received__c;
                }
                if(brokerageInvoice.Booking__r.RW_Registration_Status__c!=null){
                    base.registrationStatus = brokerageInvoice.Booking__r.RW_Registration_Status__c;
                }
                if(brokerageInvoice.Booking__r.Booking_Date__c !=null){
                    Date d = brokerageInvoice.Booking__r.Booking_Date__c.date();
                    base.bookingDate = DateTime.newInstance(d.year(), d.month(), d.day()).format('dd/MM/yyyy');
                }
                if(brokerageInvoice.Total_Agreement_Value__c!=null){
                	base.avValueForBrokerage += brokerageInvoice.Total_Agreement_Value__c;
                }
                //return;//As Base Brokerage Always One on One Relationship
            //}
        //} 
    }
    
    public static void assignLadderBrokerageBI(InvDetailsForLadder ladder, Brokerage_Invoice__c brokerageInvoice){
        ladder.brokerageAmount = brokerageInvoice.Brokerage_In_Rs__c;
        // ladder.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(brokerageInvoice.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            ladder.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            ladder.invoiceProcessDate = null;
        }
        ladder.invId = brokerageInvoice.id;
        ladder.isGstAppilcable = brokerageInvoice.If_GST_is_applicable__c;
        // ladder.invDate = cpBrokerage.Invoice_Date__c;
        if(brokerageInvoice.Invoice_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            ladder.invDate = dt.format('dd-MM-yyyy');
        } else {
            ladder.invDate = null;
        }
        ladder.approvalStatus = brokerageInvoice.Approval_Status__c;
        ladder.invoiceStatus = brokerageInvoice.Status__c;
        //if(!brokerageInvoice.isEmpty()){
            //for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                if(brokerageInvoice.Brokerage_Summary__c!=null && brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__c!=null){
                    ladder.schemeName = brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__r.Name; // Condiering the Brokerage Scheme is Same for ALL Invoices Against Same CP Invoice
                }
                if(brokerageInvoice.Brokerage_Summary__c!=null && brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__c!=null){
                    // ladder.startDate = brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c; // Condiering the Brokerage Scheme is Same for ALL Invoices Against Same CP Invoice
                    // ladder.endDate = brokerageInvoiceObj.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c;
                    if(brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c != null) {
                        Date d = Date.valueOf(brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c);
                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                        ladder.startDate = dt.format('dd-MM-yyyy');
                    } else {
                        ladder.startDate = null;
                    }
                    if(brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c != null) {
                        Date d = Date.valueOf(brokerageInvoice.Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c);
                        DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
                        ladder.endDate = dt.format('dd-MM-yyyy');
                    } else {
                        ladder.endDate = null;
                    }
                }
                if(brokerageInvoice.Project__c!=null){
                    ladder.projectName.add(brokerageInvoice.Project__c);
                }
                if(brokerageInvoice.Booking__c != null && brokerageInvoice.Booking__r.Name!=null){
                    ladder.bookingEligble.add(brokerageInvoice.Booking__r.Name);
                }
            //}
        //}
    }
    
    public static void assignAOPBrokerageBI(InvDetailsForAOP aop, Brokerage_Invoice__c brokerageInvoice){
        if(brokerageInvoice.AOP__c!=null && brokerageInvoice.AOP__r.AOP_Schemes__c!=null){
            aop.fyOfAOPScheme = brokerageInvoice.AOP__r.AOP_Schemes__r.Name;
        }
        if(brokerageInvoice.AOP__c!=null && brokerageInvoice.AOP__r.Commitment_max__c != null){
            aop.aopAmout = brokerageInvoice.AOP__r.Commitment_max__c;
        }
        //aop.runwalEntity = brokerageInvoice.Company_Name__c;
        aop.brokerageAmount = brokerageInvoice.Brokerage_In_Rs__c;
        // aop.invoiceProcessDate = cpBrokerage.SAP_Posting_Date__c;
        if(brokerageInvoice.SAP_Posting_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.SAP_Posting_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            aop.invoiceProcessDate = dt.format('dd-MM-yyyy');
        } else {
            aop.invoiceProcessDate = null;
        }
        aop.invId = brokerageInvoice.id;
        aop.isGstAppilcable = brokerageInvoice.If_GST_is_applicable__c;
        // aop.invDate = cpBrokerage.Invoice_Date__c;
        if(brokerageInvoice.Invoice_Date__c != null) {
            Date d = Date.valueOf(brokerageInvoice.Invoice_Date__c);
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            aop.invDate = dt.format('dd-MM-yyyy');
        } else {
            aop.invDate = null;
        }
        aop.approvalStatus = brokerageInvoice.Approval_Status__c;
        aop.invoiceStatus = brokerageInvoice.Status__c;
        //if(!brokerageInvoice.isEmpty()){
            aop.avValueForBrokerage = 0;
            aop.achievedRevenue = 0; 
            //for(Brokerage_Invoice__c brokerageInvoiceObj: brokerageInvoice){
                if(brokerageInvoice.Total_Agreement_Value__c!=null){
                	aop.avValueForBrokerage += brokerageInvoice.Total_Agreement_Value__c;
                }
                if(brokerageInvoice.Booking__c!=null && brokerageInvoice.Booking__r.Allotment_Premium__c!=null){
                    aop.achievedRevenue += brokerageInvoice.Booking__r.Allotment_Premium__c;
                }
            //}
        //}
    }
    
    
    
    
    
    
    
    global class Wrapper {
        public ResponseWrapper paid;
        public ResponseWrapper invoiceRaised;
        public ResponseWrapper dueEligibleForInvoicing;
        public ResponseWrapper notdue;  
        public ResponseWrapperTotal totalDetails;
    }
    
    global class wrapperBrokerage{
        public List<CP_Brokerage__c> cpBrokerageList = new List<CP_Brokerage__c>();
        public List<Brokerage_Invoice__c> brokerageInvList = new List<Brokerage_Invoice__c>();
        
    }
    
    global class ResponseWrapper {
        public decimal totalPaid;
        public decimal base;
        public decimal ladder;
        public decimal aop;
        public Details details;        
    }
    
    public class Details{
        public list<InvDetailsForBase> BaseDetails;
        public list<InvDetailsForLadder> LadderDetails;
        public list<InvDetailsForAOP> AOPDetails;
    }
    
    public class InvDetailsForBase{
        public String customerName;
        public String projectName;
        public String towerUnit;
        public String schemeName;
        public Decimal brokerage;
        public Decimal avValueForBrokerage;
        public Decimal brokerageAmount;
        public Decimal totalInvAmount;
        public String invoiceProcessDate;
        public String invoiceNo;
        public String invId;
        public String isGstAppilcable;
        public String invDate;
        public String approvalStatus;
        public String invoiceStatus;
         public String invoiceStatusPortal;
        public String salesOrderNumber;
        public String cpBrokerCode;
        public String customerNumber;
        public Decimal percentagePaidByCustomer;
        public String registrationStatus;
        public String bookingDate;
    }
    
    public class InvDetailsForLadder{
        public String schemeName;
        public Set<String> projectName = new Set<String>();
        public String startDate;
        public String endDate;
        public Set<String> bookingEligble = new Set<String>();
        public Decimal brokerageAmount;
        public String invoiceProcessDate;
        public String invId;
        public String isGstAppilcable;
        public String invDate;
        public String approvalStatus;
        public String invoiceStatus;
    }
    
    public class InvDetailsForAOP{
        public String fyOfAOPScheme;
        public Decimal aopAmout;
        public Decimal achievedRevenue;
        public String runwalEntity;
        public Decimal avValueForBrokerage;
        public Decimal brokerageAmount;
        public String invoiceProcessDate;
        public String invId;
        public String isGstAppilcable;
        public String invDate;
        public String approvalStatus;
        public String invoiceStatus;
    }
    
    global class ResponseWrapperTotal {
        public decimal paid;
        public decimal invRaised;
        public decimal due;
        public decimal notdue;
        public list<TotalInvDetails> details;        
    }
    
    public class TotalInvDetails{
        public String invdate;
        public String transactionName;//????
        // public Decimal avValueForBrokerage;
        public Decimal brokerageAmount;
        public String status;
        // public String invoiceNo;
        // public String statementUrl;
    }
}