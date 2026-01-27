@RestResource(urlMapping='/cpAddLead/*')
global without sharing class Lockated_CPAddLead {

    // Input Wrapper
    global class LeadInput {
        public String customerName;
        public String mobileNumber;
        public String email;
        public String propertyType;
        public String projectInterested;
    }

    // Response Wrapper
    global class LeadResponse {
        public String status;
        public String message;
        public String leadId;
    }

    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String cpId = req.params.get('cpId');
        LeadResponse response = new LeadResponse();
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(cpId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try {
                // Deserialize the incoming JSON body
                LeadInput input = (LeadInput)JSON.deserialize(req.requestBody.toString(), LeadInput.class);
                
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
            }
    }
    }
}