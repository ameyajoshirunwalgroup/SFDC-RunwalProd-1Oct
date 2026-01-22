@RestResource(urlMapping='/referrals/*')
global without sharing class LockatedApp_MyReferrals{
    
    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(bkgId) || bkgId == 'referrals'){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid Booking Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                ReferralDetails details = new ReferralDetails();
                Booking__c bkg = [SELECT Id, Opportunity__r.AccountId, Opportunity__r.Account.Name FROM Booking__c WHERE Id =: bkgId AND Status__c = 'Booking Confirmed'];
                String accId = bkg.Opportunity__r.AccountId;
                String accName = bkg.Opportunity__r.Account.Name;
                System.debug('accName: ' + accName);
                List<Lead> referralLeads = [SELECT Id,Name,RW_Project__r.Name,CreatedDate,Status FROM Lead WHERE Customer_Reference__c =: accId];
                Integer vcvpLeads = 0;
                Integer lostLeads = 0;
                for(Lead ld : referralLeads){
                    if(ld.Status == 'VCVP'){
                        vcvpLeads += 1;
                    }
                    if(ld.Status == 'Lost'){
                        lostLeads += 1;
                    }
                }
                List<Opportunity> referralOpps = [SELECT Id,Name,RW_Project__r.Name,CreatedDate,StageName FROM Opportunity WHERE Customer_Reference__c =: accId];
                Integer siteVisitOpps = 0;
                Integer lostOpps = 0;
                for(Opportunity opp : referralOpps){
                    if(opp.StageName == 'Site Visit'){
                        siteVisitOpps += 1;
                    }
                    if(opp.StageName == 'Cancelled' || opp.StageName == 'Lost'){
                        lostOpps += 1;
                    }
                }
                List<Booking__c> bkgs = [SELECT Id,Opportunity__r.RW_Project__r.Name,Opportunity__r.Name,Opportunity__r.CreatedDate,Opportunity__r.StageName FROM Booking__c WHERE Customer_Reference__c =: accName AND Status__c = 'Booking Confirmed'];
                
                MyReferrals myReferral = new MyReferrals();
                details.myReferrals = myReferral;
                Stats sts = new Stats();
                sts.totalLeads = referralLeads.size();
                sts.siteVisits = siteVisitOpps + vcvpLeads;
                sts.bookings = bkgs.size();
                sts.lost = lostLeads + lostOpps;
                myReferral.stats = sts;
                
                List<Referrals> referralList = new List<Referrals>();
                for(Lead ld : referralLeads){
                    Referrals ref = new Referrals();
                    ref.projectName = ld.RW_Project__r.Name;
                    ref.customerName = ld.Name;
                    //ref.referralCode = '';
                    ref.referredOn = String.valueOf(ld.CreatedDate);
                    ref.status = ld.Status;
                    referralList.add(ref);
                }
                for(Opportunity opp : referralOpps){
                    Referrals ref = new Referrals();
                    ref.projectName = opp.RW_Project__r.Name;
                    ref.customerName = opp.Name;
                    //ref.referralCode = '';
                    //ref.referredOn = String.valueOf(opp.CreatedDate);
                    ref.status = opp.StageName;
                    referralList.add(ref);
                }
                for(Booking__c bk : bkgs){
                    Referrals ref = new Referrals();
                    ref.projectName = bk.Opportunity__r.RW_Project__r.Name;
                    ref.customerName = bk.Opportunity__r.Name;
                    //ref.referralCode = '';
                    //ref.referredOn = String.valueOf(bk.Opportunity__r.CreatedDate);
                    ref.status = bk.Opportunity__r.StageName;
                    referralList.add(ref);
                }
                myReferral.referrals = referralList;
                //return details;
                res.responseBody = Blob.valueOf(JSON.serialize(details));
                res.statusCode = 200;
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
            
        }
        
        
    }
    
    global class ReferralDetails{
        public MyReferrals myReferrals;
    }
    
    public class MyReferrals{
        public Stats stats;
        public List<Referrals> referrals;
    }
    
    public class Stats{
        public Integer totalLeads;
        public Integer siteVisits;
        public Integer bookings;
        public Integer lost;
    }
    
    public class Referrals{
        public String projectName;
        public String customerName;
        //public String referralCode;
        public String referredOn;
        public String status;
    }
}