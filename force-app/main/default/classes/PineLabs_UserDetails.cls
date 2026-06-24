@RestResource(urlMapping='/userDetails/*')
global class PineLabs_UserDetails {
	@HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            List<Opportunity> opps = [SELECT Id, AccountId, Account.FirstName, Account.LastName, Account.PersonEmail, Account.Mobile_No__c, Account.Birth_Date__c, RW_Mobile_No__c, RW_Email__c  FROM Opportunity WHERE StageName = 'Unit Booked'];
            List<UserDetails> users = new List<UserDetails>();
            for(Opportunity opp : opps){
                UserDetails user = new UserDetails();
                user.firstName = opp.Account.FirstName;
                user.lastName = opp.Account.LastName;
                user.mobile = (opp.RW_Mobile_No__c != null)? opp.RW_Mobile_No__c : opp.Account.Mobile_No__c;
                user.email = (opp.RW_Email__c != null)? opp.RW_Email__c : opp.Account.PersonEmail;
                user.customerId = opp.AccountId;
                user.birthDate = String.valueOf(opp.Account.Birth_Date__c);
                users.add(user);
            }
            res.responseBody = Blob.valueOf(JSON.serialize(users));
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
        
    }
    
    global class UserDetails{
        public String firstName;
        public String lastName;
        public String mobile;
        public String email;
        public String customerId;
        public String birthDate;
    }
}