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
                                                               SAP_Broker_code__c,Customer_Code__c from CP_Brokerage__c   where Channel_Partner__c =: cpId ];
                
                list<Brokerage_Invoice__c> brokerageinvlist = [Select id,Booking__c,Invoice_Amount__c,Total_Amount_Paid__c,Brokerage_Lookup__r.Brokerage_Type__c,SAP_Document_No__c,
                                                      Customer_Name__c,Project__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Date__c,Invoice_Number__c,Status__c,
                                                      Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Booking__r.Booking_Date__c,Booking__r.Name,Opportunity__r.Name,
                                                      Brokerage_Summary__r.Brokerage_Scheme__r.Start_Date__c,Brokerage_Summary__r.Brokerage_Scheme__r.End_Date__c, Booking__r.Allotment_Premium__c,
                                                      Opportunity__c, CP_Brokerage__c, Brokerage_Summary__r.Brokerage_Scheme__r.Name, Brokerage_Summary__r.Brokerage_Scheme__c, Brokerage_Summary__c,
                                                      Booking__r.Payment_Received__c,Booking__r.RW_Registration_Status__c
                                                              
                                                      
                                                               from Brokerage_Invoice__c  where Channel_Partner__c =: cpId ];
                
                
                Map<Id, List<Brokerage_Invoice__c>> parentToChildMap = new Map<Id, List<Brokerage_Invoice__c>>();

                for(CP_Brokerage__c parent : invlist) {
                    parentToChildMap.put(parent.Id, new List<Brokerage_Invoice__c>());
                }
                
                for(Brokerage_Invoice__c child : brokerageinvlist) {
                    if(child.CP_Brokerage__c != null && parentToChildMap.containsKey(child.CP_Brokerage__c)) {
                        parentToChildMap.get(child.CP_Brokerage__c).add(child);
                    }
                }
                
                Map<String, List<CP_Brokerage__c>> invoiceMap = new Map<String, List<CP_Brokerage__c>>();
                invoiceMap.put('paid', new List<CP_Brokerage__c>());
                invoiceMap.put('invoiceRaised', new List<CP_Brokerage__c>());
                invoiceMap.put('dueEligibleForInvoicing', new List<CP_Brokerage__c>());
                invoiceMap.put('notdue', new List<CP_Brokerage__c>());
                if(!invlist.isEmpty()){
                    Decimal totalBrokerageEarned = 0;
                    Decimal pendingPayout = 0;
                    for(CP_Brokerage__c inv : invlist){
                        if(inv.Status__c == 'Paid'){//Paid
                            invoiceMap.get('paid').add(inv);
                            if(inv.Total_Brokerage__c!=null){
                            	totalBrokerageEarned += inv.Total_Brokerage__c;
                            }
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c == 'Invoice Uploaded'){//Invoice Raised
                            invoiceMap.get('invoiceRaised').add(inv);
                            if(inv.Total_Brokerage__c!=null){
                            	pendingPayout += inv.Total_Brokerage__c;
                            }
                        }
                        else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c != 'Invoice Uploaded' && (inv.Approval_Status_clearing__c == 'Approved By L1' || inv.Approval_Status_clearing__c == 'Approved By L2')){//dueEligibleForInvoicing
                            invoiceMap.get('dueEligibleForInvoicing').add(inv);
                            if(inv.Total_Brokerage__c!=null){
                            	pendingPayout += inv.Total_Brokerage__c;
                            }
                        }
                        else{
                            invoiceMap.get('notdue').add(inv);
                            if(inv.Total_Brokerage__c!=null){
                            	pendingPayout += inv.Total_Brokerage__c;
                            }
                        }
                    }
                }
                else{
					errorResult.put('status', 'error');
                    errorResult.put('message', 'No CP Brokerage Record Found Against CPID');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 404; // Not Found
                    return; // Stop execution                    
                }
                if(!invoiceMap.isEmpty()){
                    list<TotalInvDetails> tlist = new list<TotalInvDetails>();
                    for(String sts : invoiceMap.keySet()){
                        Details details = new Details();
                        list<InvDetailsForBase> blist = new list<InvDetailsForBase>();
                        list<InvDetailsForLadder> llist = new list<InvDetailsForLadder>();
                        list<InvDetailsForAOP> alist = new list<InvDetailsForAOP>();
                        Decimal totalAmount = 0;
                        Decimal baseTotalAmount = 0;
                        Decimal ladderTotalAmount = 0;
                        Decimal aopTotalAmount = 0;
                        for(CP_Brokerage__c inv : invoiceMap.get(sts)){
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
                            if(inv.Total_Brokerage__c!=null){
                                totalAmount += inv.Total_Brokerage__c;
                            }
                            if(parentToChildMap.containsKey(inv.id)){
                                if(inv.Brokerage_Type__c == 'Base Brokerage'){
                                    assignBaseBrokerage(base,inv,parentToChildMap.get(inv.id));
                                    if(inv.Total_Brokerage__c!=null){
                                    	baseTotalAmount += inv.Total_Brokerage__c;
                                    }
                                    blist.add(base); 
                                }else if(inv.Brokerage_Type__c == 'Additional Brokerage'){
                                    assignLadderBrokerage(ladder,inv,parentToChildMap.get(inv.id));
                                    if(inv.Total_Brokerage__c!=null){
                                    	ladderTotalAmount += inv.Total_Brokerage__c;
                                    }
                                    llist.add(ladder);
                                }else if(inv.Brokerage_Type__c == 'AOP Brokerage'){
                                    assignAOPBrokerage(aop,inv,parentToChildMap.get(inv.id));
                                    if(inv.Total_Brokerage__c!=null){
                                    	aopTotalAmount += inv.Total_Brokerage__c;
                                    }
                                    alist.add(aop);
                                }
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
                    totalDetailsWrapper.details = tlist;
                    resp.totalDetails = totalDetailsWrapper;
                }
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
                res.statusCode = 200;
            }catch(Exception ex){
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
    global class Wrapper {
        public ResponseWrapper paid;
        public ResponseWrapper invoiceRaised;
        public ResponseWrapper dueEligibleForInvoicing;
        public ResponseWrapper notdue;  
        public ResponseWrapperTotal totalDetails;
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