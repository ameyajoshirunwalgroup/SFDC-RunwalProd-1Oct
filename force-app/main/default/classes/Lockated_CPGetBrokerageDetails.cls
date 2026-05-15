@RestResource(urlMapping='/cpGetBrokerageDetails/*')
global without sharing class Lockated_CPGetBrokerageDetails {
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

            res.statusCode = 400;
        }else{
            try{
                Wrapper resp = new Wrapper();
                
                ResponseWrapper paid = new ResponseWrapper();
                ResponseWrapper due = new ResponseWrapper();
                ResponseWrapper notdue = new ResponseWrapper();
                ResponseWrapper invraised = new ResponseWrapper();
                ResponseWrapperTotal totalDetails = new ResponseWrapperTotal();
                ResponseWrapperSummary sum = new ResponseWrapperSummary();
                
                //Details details = new Details();                
                list<Brokerage_Invoice__c> invlist = [Select id,Booking__c,Invoice_Amount__c,Total_Amount_Paid__c,Brokerage_Lookup__r.Brokerage_Type__c,SAP_Document_No__c,
                                                      Customer_Name__c,Project__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Date__c,Invoice_Number__c,Status__c,
                                                      Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Booking__r.Booking_Date__c,Booking__r.Name,Opportunity__r.Name,
                                                      Opportunity__c                                       
                                                      from Brokerage_Invoice__c  where Channel_Partner__c =: cpId ];
                
                Map<String, List<Brokerage_Invoice__c>> invoiceMap = new Map<String, List<Brokerage_Invoice__c>>();
                invoiceMap.put('paid', new List<Brokerage_Invoice__c>());
                invoiceMap.put('invoiceRaised', new List<Brokerage_Invoice__c>());
                invoiceMap.put('dueEligibleForInvoicing', new List<Brokerage_Invoice__c>());
                invoiceMap.put('notdue', new List<Brokerage_Invoice__c>());
                if(!invlist.isEmpty()){
                    list<SummaryWrapper> slist = new list<SummaryWrapper>();
                    Decimal pendingPayout = 0;
                    Decimal totalBrokerageEarned = 0;
                    Integer invCount = 0;
                    for(Brokerage_Invoice__c inv : invlist){
                        invCount ++;
                        SummaryWrapper s = new SummaryWrapper();                        
                        s.bookingId = inv.Booking__r.Name;
                        s.customerName = (inv.Opportunity__c != null) ? inv.Opportunity__r.Name : null;
                        s.projectName = (inv.Project__c != null) ? inv.Project__c : null;
                        s.bookingDate = Date.valueof(inv.Booking__r.Booking_Date__c);
                        s.brokerageAmount = inv.Invoice_Amount__c;
                        if(inv.Status__c == 'Paid' && inv.SAP_Document_No__c != null){//Paid
                            invoiceMap.get('paid').add(inv);
                            s.payoutStatus = 'Paid';
                            totalBrokerageEarned += inv.Invoice_Amount__c;
                        }else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status__c == 'Invoice Uploaded' && (inv.Invoice_Status_Brokerage_invoice__c == 'Payment in Process' || inv.Invoice_Status_Brokerage_invoice__c == 'Pending for Accounts Approval' ||inv.Invoice_Status_Brokerage_invoice__c == 'Bill Uploaded')){//Invoice Raised
							invoiceMap.get('invoiceRaised').add(inv);
                            s.payoutStatus = 'Pending';
                            pendingPayout += inv.Invoice_Amount__c;
                        }else if(inv.Status__c == 'Unpaid' && inv.Invoice_Status_Brokerage_invoice__c == 'Bill Due'){//Due
                            invoiceMap.get('dueEligibleForInvoicing').add(inv);
                            s.payoutStatus = 'Pending';
                            pendingPayout += inv.Invoice_Amount__c;
                        }else{//Not Due
                            invoiceMap.get('notdue').add(inv);
                            s.payoutStatus = 'Pending';
                            pendingPayout += inv.Invoice_Amount__c;
                        }
                        slist.add(s);
                    }
                    sum.totalBrokerageEarned = totalBrokerageEarned;
                    sum.noOfInvoices = invCount;
                    sum.pendingPayout = pendingPayout;
                    sum.brokerageDetails = slist;
                } else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'No Data Found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
                list<TotalInvDetails> tlist = new list<TotalInvDetails>();
                for(String sts : invoiceMap.keySet()){
                    list<InvDetails> blist = new list<InvDetails>();
                	list<InvDetails> llist = new list<InvDetails>();
                    list<InvDetails> alist = new list<InvDetails>();
                    
                    Details details = new Details();
                    Decimal totalPaid = 0;
                    Decimal Base = 0;
                    Decimal Ladder = 0;
                    Decimal AOP = 0;
                    for(Brokerage_Invoice__c inv : invoiceMap.get(sts)){
                        InvDetails b = new InvDetails();
                        InvDetails l = new InvDetails();
                        InvDetails a = new InvDetails();
                        TotalInvDetails t = new TotalInvDetails();
                        t.invdate = inv.Invoice_Date__c;
                        t.transactionName = null;
                        t.avValueForBrokerage = inv.Total_Agreement_Value__c;
                        t.brokerageAmount = inv.Invoice_Amount__c;
                        t.invoiceNo = inv.Invoice_Number__c;
                        t.statementUrl = null;
                        t.status = sts;
                        tlist.add(t);
                        totalPaid += inv.Total_Amount_Paid__c;
                        //Base Brokerage
                        if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Base Brokerage'){                             
                            assignInvDetails(b,inv);
                            blist.add(b);          
                            
                            Base += inv.Total_Amount_Paid__c;                        
                        } 
                        //Additional Brokerage
                        else if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'Additional Brokerage'){
                            assignInvDetails(l,inv);
                            llist.add(l);  
                            
                            Ladder += inv.Total_Amount_Paid__c;
                        } 
                        //AOP Brokerage
                        else if(inv.Brokerage_Lookup__r.Brokerage_Type__c == 'AOP Brokerage'){
                            assignInvDetails(l,inv);
                            alist.add(l);  
                            
                            AOP += inv.Total_Amount_Paid__c;
                        } 
                    }
                    system.debug('blist - '+blist);
                    system.debug('llist - '+llist);
                    system.debug('alist - '+alist);
                    ResponseWrapper det = new ResponseWrapper();
                    details.BaseDetails = blist;
                    details.LadderDetails = llist;
                    details.AOPDetails = alist;
                    det.totalPaid = totalPaid;
                    det.Base = Base;
                    det.Ladder = Ladder;
                    det.AOP = AOP;
                    det.details = details;
                    
                    if(sts == 'paid'){
                        resp.paid = det;
                        totalDetails.paid = det.totalPaid;
                    }else if(sts == 'invoiceRaised'){
                        resp.invoiceRaised = det;
                        totalDetails.invRaised = det.totalPaid;
                    }else if(sts == 'dueEligibleForInvoicing'){
                        resp.dueEligibleForInvoicing = det;
                        totalDetails.due = det.totalPaid;
                    }else if(sts == 'notdue'){
                        resp.notdue = det;
                        totalDetails.notdue = det.totalPaid;
                    }
                    //res.responseBody = Blob.valueOf(JSON.serialize(resp));
                    //res.statusCode = 200;
                }
                totalDetails.details = tlist;
                resp.totalDetails = totalDetails;
                resp.summaryDetails = sum;
                
                res.responseBody = Blob.valueOf(JSON.serialize(resp));
                res.statusCode = 200;
                
              
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
            
        }
    }
    
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String invId = req.params.get('invId');
        Response response = new Response();
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(invId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid Invoice Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            /*
            try {
                // Deserialize the incoming JSON body
                Input input = (Input)JSON.deserialize(req.requestBody.toString(), Input.class);
                
                // Validate mandatory fields
                if(String.isBlank(input.customerName) || String.isBlank(input.mobileNumber)) {
                    response.status = 'error';
                    response.message = 'Customer Name and Mobile Number are required';
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(response));
                    return;
                }
                
                
                List<Broker__c> brlist = [Select Id,RecordTypeId,RecordType.DeveloperName,Sourcing_Manager__c,Account__c from Broker__c where Id =: cpId];
                List <Project__c> projList = [Select Id,Name from Project__c where Name =: input.projectInterested];
                
                if(brlist ==null || brlist.size()==0){
                    response.status = 'error';
                    response.message = 'Broker not found';
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(response));
                    return;
                }
                
                if(projList ==null || projList.size()==0){
                    response.status = 'error';
                    response.message = 'Project not found';
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(response));
                    return;
                }
                
                User communityUser;
                List<User> userList = [
                    SELECT Id, Name, ContactId, Profile.Name
                    FROM User
                    WHERE Contact.AccountId = :brlist[0].Account__c
                    AND IsActive = true
                    LIMIT 1
                ];
                
                if (!userList.isEmpty()) {
                    communityUser = userList[0];
                }
                if(brlist[0].Sourcing_Manager__c == null){
                    response.status = 'error';
                    response.message = 'Sourcing Manager not found against the Channel Partner';
                    res.statusCode = 400;
                    res.responseBody = Blob.valueOf(JSON.serialize(response));
                    return;
                }
                // Create Lead
                Lead newLead = new Lead();
                newLead.LastName = input.customerName;
                newLead.RW_Mobile_No__c = input.mobileNumber;
                newLead.Email = input.email;
                newLead.RW_Project__c = projList[0].Id;
                //newLead.RW_Project__c = input.projectInterested;
                //newLead.OwnerId = (communityUser != null ? communityUser.Id : UserInfo.getUserId());
                newLead.OwnerId =brlist[0].Sourcing_Manager__c ;
                newLead.RW_Broker__c = brlist[0].Id;
                newLead.Project_Type__c = input.propertyType;
                
                if(brlist[0].RecordType.DeveloperName =='Channel_Partner'){
                    newLead.LeadSource = 'Channel partner';
                }
                if(brlist[0].RecordType.DeveloperName =='Temp_Channel_Partner'){
                    newLead.LeadSource = 'Temp Channel Partner';
                }
                
                insert newLead;
                
                response.status = 'success';
                response.message = 'Lead added successfully';
                response.leadId = newLead.Id;
                res.statusCode = 200; // Created
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                
            } catch(Exception e) {
                response.status = 'error';
                response.message = e.getMessage();
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            }*/
    }
    }
    
    global class Response{
        public list<Documents> documents;
    }
    public class Documents {
        public string fileName;
        public string fileType;
        public string attachment;
    } 
    
    
    private static void assignInvDetails(InvDetails i, Brokerage_Invoice__c b){
        i.customerName = b.Customer_Name__c;
        i.projectName = b.Project__c;
        i.avValueForBrokerage = b.Total_Agreement_Value__c;
        i.brokerageAmount = b.Invoice_Amount__c;
        i.paidDate = b.Invoice_Date__c;
        i.invoiceNo = b.Invoice_Number__c;
        i.statementUrl = null;
    }
    
    global class Wrapper {
        public ResponseWrapper paid;
        public ResponseWrapper invoiceRaised;
        public ResponseWrapper dueEligibleForInvoicing;
        public ResponseWrapper notdue;  
        public ResponseWrapperTotal totalDetails;
        public ResponseWrapperSummary summaryDetails;
    }
    
    global class ResponseWrapper {
        public decimal totalPaid;
        public decimal base;
        public decimal ladder;
        public decimal aop;
        public Details details;        
    }
    
    global class ResponseWrapperTotal {
        public decimal paid;
        public decimal invRaised;
        public decimal due;
        public decimal notdue;
        public list<TotalInvDetails> details;        
    }
    
    global class ResponseWrapperSummary {
        public decimal totalBrokerageEarned;
        public integer noOfInvoices;
        public decimal pendingPayout;
        public list<SummaryWrapper> brokerageDetails;        
    }
    
    public class SummaryWrapper{
        public String bookingId;
        public String customerName;
        public String projectName;
        public Date bookingDate;
        public Decimal brokerageAmount;
        public String payoutStatus;
    }
    
    public class Details{
        public list<InvDetails> BaseDetails;
        public list<InvDetails> LadderDetails;
        public list<InvDetails> AOPDetails;
    }
    
    public class InvDetails{
        public String customerName;
        public String projectName;
        public Decimal avValueForBrokerage;
        public Decimal brokerageAmount;
        public Date paidDate;
        public String invoiceNo;
        public String statementUrl;
    }
    
    public class TotalInvDetails{
        public Date invdate;
        public String transactionName;//????
        public Decimal avValueForBrokerage;
        public Decimal brokerageAmount;
        public String status;
        public String invoiceNo;
        public String statementUrl;
    }
    
    
    public class Ladder{
        public String ladderSchemeName;
        public String projectName;
        public String startDate;
        public String endDate;
        public String bookingsEligible;
        public Decimal brokerageAmount;
        public Date paidDate;
        public String statementUrl;
    }
    
    public class AOP{
        public String fyOfAopScheme;
        public String aopAmount;
        public String achievedRevenue;
        public String runwalEntity;
        public String avForBrokerageInEntity;
        public String brokerageAmount;
        public Date paidDate;
        public String statementUrl;
    }
    
}