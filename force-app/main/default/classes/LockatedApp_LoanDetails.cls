@RestResource(urlMapping='/loans/*')
global without sharing class LockatedApp_LoanDetails {
    
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
                List<Loan__c> loansList = [SELECT Id, Loan_Amount__c,RW_Bank_Preference_1__c,RW_Bank_Preference_2__c,RW_Bank_Preference_3__c,RW_Loan_Record_Status__c,CreatedDate,Comments__c,Tenure__c,RW_Sanction_Letter_ID__c,Lockated_App_Loan_Request_Id__c FROM Loan__c WHERE RW_Booking__c =: bkgId];
                if(loansList.size() > 0){
                    LoanDetailsGet details = new LoanDetailsGet();
                    List<LoanReqGet> loans = new List<LoanReqGet>();
                    for(Loan__c ln : loansList){
                        LoanReqGet loan = new LoanReqGet();
                        loan.loanAmount = String.valueOf(ln.Loan_Amount__c);
                        loan.status = ln.RW_Loan_Record_Status__c;
                        loan.submittedDate = String.valueOf(ln.CreatedDate);
                        List<String> banks = new List<String>();
                        if(ln.RW_Bank_Preference_1__c != null)
                            banks.add(ln.RW_Bank_Preference_1__c);
                        if(ln.RW_Bank_Preference_2__c != null)
                            banks.add(ln.RW_Bank_Preference_2__c);
                        if(ln.RW_Bank_Preference_3__c != null)
                            banks.add(ln.RW_Bank_Preference_3__c);
                        loan.preferredBanks = banks;
                        loan.sanction_letter = LockatedApp_DocumentDetails.distPublicUrl(ln.RW_Sanction_Letter_ID__c);
                        loan.requestId = ln.Lockated_App_Loan_Request_Id__c;
                        loans.add(loan);
                    }
                    details.loanRequests = loans;
                    //return details;
                    res.responseBody = Blob.valueOf(JSON.serialize(details));
                    res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Loan records not found for this booking');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
        } 
        
        
    }
    
    @HttpPost
    global static void doPost(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        LoanDetailsPost data = (LoanDetailsPost)JSON.deserialize(jsonBody, LoanDetailsPost.class);
        Map<String, String> projMap = new Map<String, String>();
        for(Project__c proj : [SELECT Id, Name FROM Project__c]){
            projMap.put(proj.Name, proj.Id);
        }
        try{
            List<Loan__c> loans = [SELECT Id FROM Loan__c WHERE RW_Booking__c =: data.loanRequest.booking];
            if(loans.size() > 0){
                res.responseBody = Blob.valueOf('Loan record already exist');
            	res.statusCode = 200;
            }else{
                Loan__c loan = new Loan__c();
                loan.RW_Booking__c = data.loanRequest.booking;
                loan.RW_Project_Name__c = projMap.get(data.loanRequest.projectName);
                loan.Loan_Amount__c = data.loanRequest.requiredLoanAmount;
                loan.Tenure__c = Decimal.valueOf(data.loanRequest.loanTenureYears);
                loan.RW_Bank_Preference_1__c = data.loanRequest.preferredBank;
                loan.Comments__c = data.loanRequest.comments;
                loan.Lockated_App_Loan_Request_Id__c = data.loanRequest.requestId;
                insert loan;
                //return 'Loan record cretaed successfully';
                res.responseBody = Blob.valueOf('Loan record cretaed successfully');
                res.statusCode = 200;
            }
            
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
    }
    
    global class LoanDetailsPost{
        public LoanReqPost loanRequest;
    }
    
    public class LoanReqPost{
        public string booking;
        public string projectName;
        public Decimal requiredLoanAmount;
        public string loanTenureYears;
        public string preferredBank;
        public string comments;
        public string requestId;
    }
    
    global class LoanDetailsGet{
        public List<LoanReqGet> loanRequests;
    }
    
    public class LoanReqGet{
        public string loanAmount;
        public List<string> preferredBanks;
        public string status;
        public string submittedDate;
        public string requestId;
        public string sanction_letter;
    }
}