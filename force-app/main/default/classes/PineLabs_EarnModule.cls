@RestResource(urlMapping='/earnModule/*')
global class PineLabs_EarnModule {
    
    /*@HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        List<String> freshRefLeads = new List<String>();
        Date fromDate;
        Date toDate;
        if(req != null && req.requestBody != null){
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            
            if(String.isNotBlank(jsonBody)){
                DateRange resData = (DateRange)JSON.deserialize(jsonBody, DateRange.class);
                
                if(resData != null){
                    fromDate = (resData.fromDate != '')? Date.valueOf(resData.fromDate) : null;
                    toDate = (resData.toDate != '')? Date.valueOf(resData.toDate) : null;
                }
            }
        }
        try{
            
            Set<String> referredCustomers = new Set<String>();
            //Map<Id, Lead> referralLeadsToday = new Map<Id, Lead>([SELECT Id, Customer_Reference__c FROM Lead WHERE LeadSource = 'Referral' AND Customer_Reference__c != null AND CreatedDate = TODAY]);
            Map<Id, Lead> referralLeadsToday = new Map<Id, Lead>([SELECT Id, Customer_Reference__c FROM Lead WHERE LeadSource = 'Referral' AND Customer_Reference__c != null AND CreatedDate >=: fromDate AND CreatedDate <: toDate LIMIT 100]);
            System.debug('referralLeadsToday: ' + referralLeadsToday);
            Map<String, String> custIdVsLeadId = new Map<String, String>();
            for(Lead ld : referralLeadsToday.values()){
                referredCustomers.add(ld.Customer_Reference__c);
                custIdVsLeadId.put(ld.Customer_Reference__c, ld.Id);
            }
            System.debug('referredCustomers: ' + referredCustomers);
            List<RefDetails> siteVisits = new List<RefDetails>();
            //List<Opportunity> referralOppsToday = [SELECT Id, Customer_Reference__c, AccountId, Account.Mobile_No__c, Account.Name, Account.Booked_Opportunities__c,Customer_Reference__r.Name,Customer_Reference__r.Mobile_No__c,Customer_Reference__r.Booked_Opportunities__c FROM Opportunity WHERE CreatedDate = TODAY AND StageName = 'Site Visit' AND Customer_Reference__c != null AND LeadSource = 'Referral'];
            List<Opportunity> referralOppsToday = [SELECT Id, Customer_Reference__c, AccountId, Account.Mobile_No__c, Account.Name, Account.Booked_Opportunities__c,Customer_Reference__r.Name,Customer_Reference__r.Mobile_No__c,Customer_Reference__r.Booked_Opportunities__c FROM Opportunity WHERE StageName = 'Site Visit' AND Customer_Reference__c != null AND LeadSource = 'Referral' AND CreatedDate >=: fromDate AND CreatedDate <: toDate];
            System.debug('referralOppsToday: ' + referralOppsToday);
            Map<String, Integer> refSiteVisits = new Map<String, Integer>();
            Map<String, String> custIdVsOppId = new Map<String, String>();
            for(Opportunity opp : referralOppsToday){
                referredCustomers.add(opp.Customer_Reference__c);
                if(refSiteVisits.get(opp.Customer_Reference__c) == null){
                    refSiteVisits.put(opp.Customer_Reference__c, 1);
                }else{
                    refSiteVisits.put(opp.Customer_Reference__c, refSiteVisits.get(opp.Customer_Reference__c) + 1);
                }
                custIdVsOppId.put(opp.Customer_Reference__c, opp.AccountId);
                RefDetails ref = new RefDetails();
                ref.customerId = opp.Customer_Reference__r.Mobile_No__c;
                ref.referredPerson = opp.Customer_Reference__r.Name;
                ref.referralId = opp.Id;
                ref.status = (opp.Customer_Reference__r.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                ref.saleValue = 0;
                siteVisits.add(ref);
            }
            System.debug('referredCustomers: ' + referredCustomers);
            System.debug('refSiteVisits: ' + refSiteVisits);
            if(referredCustomers.size() > 0){
                List<Lead> refLeads = [SELECT Id, Customer_Reference__c FROM Lead WHERE Customer_Reference__c =: referredCustomers ORDER BY CreatedDate ASC];
                System.debug('refLeads: ' + refLeads);
                Map<String, List<Lead>> custVsLeads = new Map<String, List<Lead>>();
                for(Lead ld : refLeads){
                    if(custVsLeads.get(ld.Customer_Reference__c) != null){
                        custVsLeads.get(ld.Customer_Reference__c).add(ld);
                    }else{
                        custVsLeads.put(ld.Customer_Reference__c, new List<Lead>{ld});
                    }
                }
                System.debug('custVsLeads: ' + custVsLeads);
                List<Opportunity> refOpps = [SELECT Id, StageName, Customer_Reference__c FROM Opportunity WHERE Customer_Reference__c =: referredCustomers];
                System.debug('refOpps: ' + refOpps);
                Map<String, List<Opportunity>> custVsOpps = new Map<String, List<Opportunity>>();
                for(Opportunity opp : refOpps){
                    if(custVsOpps.get(opp.Customer_Reference__c) != null){
                        custVsOpps.get(opp.Customer_Reference__c).add(opp);
                    }else{
                        custVsOpps.put(opp.Customer_Reference__c, new List<Opportunity>{opp});
                    }
                }
                System.debug('custVsOpps: ' + custVsOpps);
                Map<String, String> refLeadPointsMap = new Map<String, String>();
                
                for(String cust : referredCustomers){
                    System.debug('custVsOpps.get(cust): ' + custVsOpps.get(cust));
                    if(custVsOpps.get(cust) == null || (custVsOpps.get(cust) != null && custVsOpps.get(cust).size() == 0)){
                        System.debug('custVsLeads.get(cust): ' + custVsLeads.get(cust));
                        if(custVsLeads.get(cust).size() == 1 && referralLeadsToday.containsKey(custVsLeads.get(cust)[0].Id)){
                            refLeadPointsMap.put(cust, 'First Lead');
                            freshRefLeads.add(cust);
                        }
                    }else if(custVsOpps.get(cust) != null && custVsOpps.get(cust).size() == 1){
                        if(custVsLeads.get(cust).size() == 1 && referralLeadsToday.containsKey(custVsLeads.get(cust)[0].Id)){
                            refLeadPointsMap.put(cust, 'First Lead');
                            freshRefLeads.add(cust);
                        }
                    }
                }
                
            }
            
            Map<String, List<Decimal>> ref20PaidBkgs = new Map<String, List<Decimal>>();
            List<RefDetails> closedRefs = new List<RefDetails>();
            Date dt = Date.today() - 3;
            //Map<Id, Booking__c> bkgs = new Map<Id, Booking__c>([SELECT Id, Allotment_Premium__c, Customer_Reference__c, Opportunity__r.Account.Mobile_No__c, Opportunity__r.Account.Name, Opportunity__r.AccountId, Opportunity__r.Account.Booked_Opportunities__c FROM Booking__c WHERE Customer_Reference__c != null AND X20_Received_Date__c = YESTERDAY]);
            Map<Id, Booking__c> bkgs = new Map<Id, Booking__c>([SELECT Id, Allotment_Premium__c, Customer_Reference__c, Opportunity__r.Account.Mobile_No__c, Opportunity__r.Account.Name, Opportunity__r.AccountId, Opportunity__r.Account.Booked_Opportunities__c FROM Booking__c WHERE Customer_Reference__c != null AND X20_Received_Date__c >=: (fromDate - 1) AND X20_Received_Date__c <: (toDate - 1)]);
            if(bkgs.size() > 0){
                for(Booking__c bkg : bkgs.values()){
                    if(ref20PaidBkgs.get(bkg.Customer_Reference__c) == null){
                        ref20PaidBkgs.put(bkg.Customer_Reference__c, new List<Decimal>{bkg.Allotment_Premium__c});
                    }else{
                        ref20PaidBkgs.get(bkg.Customer_Reference__c).add(bkg.Allotment_Premium__c);
                    }
                    RefDetails ref = new RefDetails();
                    ref.customerId = bkg.Opportunity__r.Account.Mobile_No__c;
                    ref.referredPerson = bkg.Opportunity__r.Account.Name;
                    ref.referralId = bkg.Id;
                    ref.status = (bkg.Opportunity__r.Account.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                    ref.saleValue = bkg.Allotment_Premium__c;
                    closedRefs.add(ref);
                }
            }
            System.debug('ref20PaidBkgs: ' + ref20PaidBkgs);
            System.debug('freshRefLeads: ' + freshRefLeads);
            Details det = new Details();
            det.freshLeads = freshRefLeads;
            det.siteVisits = refSiteVisits;
            det.closedReferrals = ref20PaidBkgs;
            
            Date dateAfert7Days = Date.today() + 7;
            List<RW_Demand__c> demands = [SELECT Id, Booking__r.Opportunity__r.AccountId,Booking__r.Opportunity__r.Account.Mobile_No__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Paid' AND Due_Date__c =: dateAfert7Days AND LastModifiedDate = YESTERDAY AND Booking__r.Customer_Reference__c != null];
            List<Payment> onTimePayments = new List<Payment>();
            for(RW_Demand__c dem : demands){
                Payment pay = new Payment();
                pay.customerId = dem.Booking__r.Opportunity__r.Account.Mobile_No__c;
                pay.status = 'Yes';
                onTimePayments.add(pay);
            }
            
            
            Details1 det1 = new Details1();
            List<RefDetails> freshLeads = new List<RefDetails>();
            for(Account acc : [SELECT Id, Name, Mobile_No__c, Booked_Opportunities__c FROM Account WHERE Id =: freshRefLeads]){
                RefDetails ref = new RefDetails();
                ref.customerId = acc.Mobile_No__c;
                ref.referredPerson = acc.Name;
                ref.referralId = custIdVsLeadId.get(acc.Id);
                ref.status = (acc.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                ref.saleValue = 0;
                freshLeads.add(ref);
            }
            det1.freshLeads = freshLeads;
            det1.siteVisits = siteVisits;
            System.debug('closedRefs: ' + closedRefs);
            det1.closedRefs = closedRefs;
            det1.onTimePayments = onTimePayments;
            //res.responseBody = Blob.valueOf(JSON.serialize(det));
            res.responseBody = Blob.valueOf(JSON.serialize(det1));
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }*/
    
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        List<String> freshRefLeads = new List<String>();
        Date fromDate;
        Date toDate;
        if(req != null && req.requestBody != null){
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            
            if(String.isNotBlank(jsonBody)){
                DateRange resData = (DateRange)JSON.deserialize(jsonBody, DateRange.class);
                
                if(resData != null){
                    fromDate = (resData.fromDate != '')? Date.valueOf(resData.fromDate) : null;
                    toDate = (resData.toDate != '')? Date.valueOf(resData.toDate) : null;
                }
            }
        }
        try{
            List<Referral_Points__c> refPoints = [SELECT Id,Type__c,Lead__c,Opportunity__c,Booking__c,Demand__c,Customer_Reference__c,
                                                  Customer_Reference__r.Name,Customer_Reference__r.Mobile_No__c,Customer_Reference__r.Booked_Opportunities__c,
                                                  Booking__r.Allotment_Premium__c, CreatedDate FROM Referral_Points__c WHERE CreatedDate >=: fromDate AND CreatedDate <: toDate];
            Details1 det = new Details1();
            List<RefDetails> freshLeads = new List<RefDetails>();
            List<RefDetails> siteVisits = new List<RefDetails>();
            List<RefDetails> closedRefs = new List<RefDetails>();
            List<Payment> onTimePayments = new List<Payment>();
            for(Referral_Points__c ref : refPoints){
                if(ref.Type__c == 'Fresh Lead'){
                    RefDetails rd = new RefDetails();
                    rd.customerId = ref.Customer_Reference__r.Mobile_No__c;
                    rd.referredPerson = ref.Customer_Reference__r.Name;
                    rd.referralId = ref.Lead__c;
                    rd.status = (ref.Customer_Reference__r.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                    rd.saleValue = 0;
                    rd.sfdcId = ref.Id;
                    rd.createdDate = String.valueOf(Date.valueOf(ref.CreatedDate));
                    freshLeads.add(rd);
                }else if(ref.Type__c == 'Site Visit'){
                    RefDetails rd = new RefDetails();
                    rd.customerId = ref.Customer_Reference__r.Mobile_No__c;
                    rd.referredPerson = ref.Customer_Reference__r.Name;
                    rd.referralId = ref.Opportunity__c;
                    rd.status = (ref.Customer_Reference__r.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                    rd.saleValue = 0;
                    rd.sfdcId = ref.Id;
                    rd.createdDate = String.valueOf(Date.valueOf(ref.CreatedDate));
                    siteVisits.add(rd);
                }else if(ref.Type__c == 'Closed Referral'){
                    RefDetails rd = new RefDetails();
                    rd.customerId = ref.Customer_Reference__r.Mobile_No__c;
                    rd.referredPerson = ref.Customer_Reference__r.Name;
                    rd.referralId = ref.Booking__c;
                    rd.status = (ref.Customer_Reference__r.Booked_Opportunities__c > 0)? 'Active' : 'Inactive';
                    rd.saleValue = ref.Booking__r.Allotment_Premium__c;
                    rd.sfdcId = ref.Id;
                    rd.createdDate = String.valueOf(Date.valueOf(ref.CreatedDate));
                    closedRefs.add(rd);
                }else if(ref.Type__c == 'On Time Payment'){
                    Payment pay = new Payment();
                    pay.customerId = ref.Customer_Reference__r.Mobile_No__c;
                    pay.status = 'Yes';
                    pay.sfdcId = ref.Id;
                    pay.createdDate = String.valueOf(Date.valueOf(ref.CreatedDate));
                    onTimePayments.add(pay);
                }
            }
            det.freshLeads = freshLeads;
            det.siteVisits = siteVisits;
            det.closedRefs = closedRefs;
            det.onTimePayments = onTimePayments;
            res.responseBody = Blob.valueOf(JSON.serialize(det));
            res.statusCode = 200;
            
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    /*@HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            List<Points> resData = (List<Points>)JSON.deserialize(jsonBody, List<Points>.class);
            system.debug('resData: ' + resData);
            List<String> mobileNums = new List<String>();
            for(Points point : resData){
                mobileNums.add(point.customerId);
            }
            List<Account> accs = [SELECT Id, Mobile_No__c, Referral_Points__c FROM Account WHERE Mobile_No__c =: mobileNums];
            Map<String, Account> accMap = new Map<String, Account>();
            for(Account acc : accs){
                accMap.put(acc.Mobile_No__c, acc);
            }
            List<Account> accToUpdate = new List<Account>();
            DateTime dt = System.now();
			String formattedDate = dt.format('dd-MM-yyyy', 'GMT');
            for(Points point : resData){
                system.debug('point: ' + point.customerId);
                system.debug('point: ' + point.points);
                if(String.isNotBlank(point.customerId)){
                    
                    Account acc = new Account();
                    acc.Id = accMap.get(point.customerId).Id;
                    if(accMap.get(point.customerId).Referral_Points__c != null){
                        acc.Referral_Points__c = accMap.get(point.customerId).Referral_Points__c + '; ' + formattedDate + ': ' + point.points;
                    }else{
                        acc.Referral_Points__c = formattedDate + ': ' + point.points;
                    }
                    
                    accToUpdate.add(acc);
                    res.responseBody = Blob.valueOf('Details updated successfully');
                    res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Please pass valid Customer Id');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
            }
            if(accToUpdate.size() > 0){
                update accToUpdate;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }*/
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            List<Points> resData = (List<Points>)JSON.deserialize(jsonBody, List<Points>.class);
            system.debug('resData: ' + resData);
            List<Referral_Points__c> refToUpdate = new List<Referral_Points__c>();
            Map<String,String> pointsMap = new Map<String, String>();
            Set<String> customers = new Set<String>();
            for(Points point : resData){
                pointsMap.put(point.customerId + '_' + point.pointsType, point.points);
                customers.add(point.customerId);
            }
            List<Referral_Points__c> refPoints = [SELECT Id,Customer_Reference__c,Type__c, Points__c,Customer_Reference__r.Mobile_No__c FROM Referral_Points__c WHERE Customer_Reference__r.Mobile_No__c =: customers AND Points__c = null];
            Map<String,List<Referral_Points__c>> refMap = new Map<String, List<Referral_Points__c>>();
            for(Referral_Points__c ref : refPoints){
                if(refMap.get(ref.Customer_Reference__r.Mobile_No__c + '_' + ref.Type__c) == null){
                    refMap.put(ref.Customer_Reference__r.Mobile_No__c + '_' + ref.Type__c, new List<Referral_Points__c>{ref});
                }else{
                    refMap.get(ref.Customer_Reference__r.Mobile_No__c + '_' + ref.Type__c).add(ref);
                }
            }
            for(Points point : resData){
                for(Referral_Points__c ref : refPoints){
                    if(point.customerId == ref.Customer_Reference__r.Mobile_No__c && point.pointsType == ref.Type__c && ref.Points__c == null){
                        ref.Points__c = Decimal.valueOf(point.points);
                        refToUpdate.add(ref);
                    }
                }
            }
            /*for(Points point : resData){
                if(refMap.get(point.customerId + '_' + point.pointsType).size() > 1){
                    
                    
                }
                Referral_Points__c ref = new Referral_Points__c();
                ref.Id = refMap.get(point.customerId + '_' + point.pointsType)[0].Id;
                ref.Points__c = point.points;
                refToUpdate.add(ref);
            }*/
            if(refToUpdate.size() > 0){
                update refToUpdate;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class Points{
        public String customerId;
        public String points;
        public String pointsType;
    }
    

    global class Details{
        public List<String> freshLeads;
        public Map<String, Integer> siteVisits;
        public Map<String, List<Decimal>> closedReferrals;
    }
    
    global class Details1{
        public List<RefDetails> freshLeads;
        public List<RefDetails> siteVisits;
        public List<RefDetails> closedRefs;
        public List<Payment> onTimePayments;
    }
    
    public class SiteVisit{
        public String customer;
        public Integer siteVisitsCount;
    }
    
    public class ClosedRef{
        public String customer;
        public Decimal saleValue;
    }
    
    public class RefDetails{
        public String customerId;
		public String referredPerson;
        public String referralId;
        public String status;
        public Decimal saleValue;
        public String sfdcId;
        public String createdDate;
    }
    
    public class Payment{
        public String customerId;
        public String status;
        public String sfdcId;
        public String createdDate;
    }
    
    global class DateRange{
        public String fromDate;
        public String toDate;
    }
    

}