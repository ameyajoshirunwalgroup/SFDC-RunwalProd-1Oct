@RestResource(urlMapping='/userDeviceDetails/*')
global class LockatedApp_UserDeviceDetails {
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            Device dev = (Device)JSON.deserialize(jsonBody, Device.class);
            List<Opportunity> opp = new List<Opportunity>();
            if(String.isBlank(dev.Customer)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Customer Number should not be blank');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                opp = [SELECT Id, AccountId FROM Opportunity WHERE SAP_Customer_Number__c =: dev.Customer];
                if(opp.size() == 0){
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Customer not available in SFDC with this customer number');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }else{
                    //Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE SAP_Customer_Number__c =: dev.Customer];
                    Account acc = new Account();
                    acc.Id = opp[0].AccountId;
                    acc.Lockated_User_App_Version__c = dev.App_Version;
                    acc.Lockated_User_Source__c = dev.Source;
                    acc.Lockated_User_OS_Version__c = dev.OS_Version;
                    acc.Lockated_User_Model__c = dev.Model;
                    acc.Lockated_User_Type_A_I__c = dev.Type_A_I;
                    acc.Lockated_User_Custom_Device_ID__c = dev.Custom_Device_ID;
                    acc.Lockated_User_Customer__c = dev.Customer;
                    acc.Lockated_User_FCM_ID_Action__c = dev.FCM_ID_Action;
                    update acc;
                    res.responseBody = Blob.valueOf('Device details updated successfully');
                	res.statusCode = 200;
                }
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    global class Device{
        public String App_Version;
        public String Source;
        public String OS_Version;
        public String Model;
        public String Type_A_I;
        public String Custom_Device_ID;
        public String Customer;
        public String Opportunity;
        public String FCM_ID_Action;
    }
}