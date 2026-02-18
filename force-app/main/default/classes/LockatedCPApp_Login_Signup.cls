@RestResource(urlMapping='/cplogin/*')
global without sharing class LockatedCPApp_Login_Signup {
    
   /* @HttpGet
    global static LoginSignupGet doGet(){
        
        RestRequest req = RestContext.request;
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(String.isBlank(bkgId))
        	return null;    
        
        List<Loan__c> loansList = [SELECT Id, Loan_Amount__c,RW_Bank_Preference_1__c,RW_Bank_Preference_2__c,RW_Bank_Preference_3__c,RW_Loan_Record_Status__c,CreatedDate,Comments__c,Tenure__c FROM Loan__c WHERE RW_Booking__c =: bkgId];
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
            loans.add(loan);
        }
        details.loanRequests = loans;
        return details;
    }*/
    
    /*@HttpPost
    global static String doPost(){	        
        RestRequest req = RestContext.request;
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        LoginReqPost data = (LoginReqPost)JSON.deserialize(jsonBody, LoginReqPost.class); 
        
        return data.email;
    }*/
    
    @HttpPost
    global static ApiResponse doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        ApiResponse response = new ApiResponse();

        try {
            LoginReqPost data = (LoginReqPost) JSON.deserialize(req.requestBody.toString(), LoginReqPost.class);

            // Validation 1: Required fields
            if (String.isBlank(data.email)) {
                response.success = false;
                response.message = 'Email is required';
                return response;
            }
            if (String.isBlank(data.password)) {
                response.success = false;
                response.message = 'Password is required';
                return response;
            }

            // Validation 2: Check for existing record
            List<User> existingUsr = [
                SELECT Id, Email, Phone 
                FROM User 
                WHERE Email = :data.email OR Phone = :data.phone
                LIMIT 1
            ];

            if (!existingUsr.isEmpty()) {
                response.success = false;
                response.message = 'User already exists with given Email/Phone';
                return response;
            }

            // If validations pass → process further            
           /* Contact c = new Contact(
                LastName = 'API User',
                Email = data.email,
                Phone = data.phone
            );
            insert c;*/

            response.success = true;
            response.message = 'CP Logged in successfully';
            return response;

        } catch (Exception e) {
            response.success = false;
            response.message = 'Error: ' + e.getMessage();
            return response;
        }
    }

    global class LoginReqPost{
        public string email;
        public string phone;
        public string password;
    }
    
    global class ApiResponse {
        public Boolean success;
        public String message;
    }

}