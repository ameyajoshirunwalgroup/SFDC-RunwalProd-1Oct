@RestResource(urlMapping='/userDeviceDetails/*')
global class LockatedApp_UserDeviceDetails {
    
    /*@HttpPost
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
    }*/
    
    
    /*@HttpPost
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
            if(String.isBlank(dev.bookingNumber)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Booking Number should not be blank');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Booking__c> bkg = [SELECT Id, Opportunity__r.AccountId FROM Booking__c WHERE Id =: dev.bookingNumber];
                if(bkg.size() == 0){
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Customer not available in SFDC with this booking number');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }else{
                    Account acc = [SELECT Id, Lockated_User_Custom_Device_ID__c FROM Account WHERE Id =: bkg[0].Opportunity__r.AccountId];
                    if(dev.addOrDelete == 'Add'){
                        if(String.isBlank(acc.Lockated_User_Custom_Device_ID__c)){
                            acc.Lockated_User_Custom_Device_ID__c = dev.deviceToken;
                        }else{
                            acc.Lockated_User_Custom_Device_ID__c = acc.Lockated_User_Custom_Device_ID__c + ',' + dev.deviceToken;
                        }
                        update acc;
                        res.responseBody = Blob.valueOf('Device details updated successfully');
                		res.statusCode = 200;
                    }else if(dev.addOrDelete == 'Delete'){
                        if(String.isBlank(acc.Lockated_User_Custom_Device_ID__c) || !acc.Lockated_User_Custom_Device_ID__c.contains(dev.deviceToken)){
                            errorResult.put('status', 'error');
                            errorResult.put('message', 'Customer did not registered with this device token');
                            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                            res.statusCode = 400;
                            return;
                        }else{
                            if(acc.Lockated_User_Custom_Device_ID__c.contains(',')){
                                String result = acc.Lockated_User_Custom_Device_ID__c.replace(','+dev.deviceToken, '').replace(dev.deviceToken+',', '');
                            	acc.Lockated_User_Custom_Device_ID__c = result;
                            }else{
                                String result = acc.Lockated_User_Custom_Device_ID__c.replace(dev.deviceToken, '');
                            	acc.Lockated_User_Custom_Device_ID__c = result;
                            }
                            
                        }
                        update acc;
                        res.responseBody = Blob.valueOf('Device details deleted successfully');
                		res.statusCode = 200;
                    }
                }
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
            Device dev = (Device)JSON.deserialize(jsonBody, Device.class);
            List<Opportunity> opp = new List<Opportunity>();
            if(String.isBlank(dev.bookingNumber)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Booking Number should not be blank');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Booking__c> bkgs = [SELECT Id, Opportunity__r.AccountId,Lockated_User_Device_ID__c FROM Booking__c WHERE Id =: dev.bookingNumber];
                if(bkgs.size() == 0){
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Customer not available in SFDC with this booking number');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }else{
                    Booking__c bkg = bkgs[0];
                    if(dev.addOrDelete == 'Add'){
                        if(String.isBlank(bkg.Lockated_User_Device_ID__c)){
                            bkg.Lockated_User_Device_ID__c = dev.deviceToken;
                        }else{
                            bkg.Lockated_User_Device_ID__c = bkg.Lockated_User_Device_ID__c + ';' + dev.deviceToken;
                        }
                        update bkg;
                        res.responseBody = Blob.valueOf('Device details updated successfully');
                		res.statusCode = 200;
                    }else if(dev.addOrDelete == 'Delete'){
                        if(String.isBlank(bkg.Lockated_User_Device_ID__c) || !bkg.Lockated_User_Device_ID__c.contains(dev.deviceToken)){
                            errorResult.put('status', 'error');
                            errorResult.put('message', 'Customer did not registered with this device token');
                            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                            res.statusCode = 400;
                            return;
                        }else{
                            if(bkg.Lockated_User_Device_ID__c.contains(';')){
                                String result = bkg.Lockated_User_Device_ID__c.replace(';'+dev.deviceToken, '').replace(dev.deviceToken+';', '');
                            	bkg.Lockated_User_Device_ID__c = result;
                            }else{
                                String result = bkg.Lockated_User_Device_ID__c.replace(dev.deviceToken, '');
                            	bkg.Lockated_User_Device_ID__c = result;
                            }
                            
                        }
                        update bkg;
                        res.responseBody = Blob.valueOf('Device details deleted successfully');
                		res.statusCode = 200;
                    }
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
        public String deviceToken;
        public String bookingNumber;
        public String addOrDelete;
    }
}