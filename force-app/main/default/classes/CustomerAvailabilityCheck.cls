@RestResource(urlMapping='/checkCustomer/*')
global class CustomerAvailabilityCheck {
	
    @HttpGet
    global static Details checkCustomerAvailability(){
        
        RestRequest req = RestContext.request;
        
        String mobile = req.params.get('mobile');
        String email = req.params.get('email');
        //String project =req.params.get('project');
        System.debug('mobile: ' + mobile);
        System.debug('email: ' + email);
        
        List<Opportunity> opps = [SELECT Id, AccountId, Booking__c, Account.Mobile_No__c, Account.FirstName, Account.LastName, Account.Country_Code__c,
                                  Account.PersonEmail, RW_Project_Unit__r.RW_Param4__c, RW_Project_Unit__r.RW_Param2__c, Account.RW_Country__c, RW_Email__c,
                                  SAP_Customer_Number__c, RW_Project__r.Name FROM Opportunity WHERE StageName = 'Unit Booked' AND RW_Mobile_No__c =: mobile AND RW_Email__c =: email /*AND RW_Project__r.Name =: project*/];
        
        System.debug('opps: ' + opps);
        Details det = new Details();
        List<Society_Id__mdt> socityIds = [SELECT Id, Label, Value__c FROM Society_Id__mdt];
        Map<String, Country_Codes__c> countryNameCodes = Country_Codes__c.getall();
        Map<String, String> projNameVsSocityId = new Map<String, String>();
        for(Society_Id__mdt rec : socityIds){
            projNameVsSocityId.put(rec.Label, rec.Value__c);
        }
        
        Map<String, String> otpMap = new Map<String, String>();
        if(opps.size() > 0){
            
            String OTPNumber=''; 
            Integer xx;
            do{
                Double x = Math.random(); 
                long y = Math.round(x*100000);
                xx = String.valueOf(y).length();
                OTPNumber = String.valueOf(y);
            } while( xx < 5 );
            
            //String otp = OTPNumber;
            det.otp = OTPNumber;
            det.account_id = opps[0].AccountId;
            det.firstname = opps[0].Account.FirstName;
            det.lastname = opps[0].Account.LastName;
            det.email = opps[0].Account.PersonEmail;
            det.mobile = opps[0].Account.Mobile_No__c;
            if(opps[0].Account.Country_Code__c != null){
                det.country_code = opps[0].Account.Country_Code__c;
            }else{
                det.country_code = '+91';
            }
            if(opps[0].Account.RW_Country__c != null && countryNameCodes.get(opps[0].Account.RW_Country__c) != null){
                det.country_code_name = countryNameCodes.get(opps[0].Account.RW_Country__c).Code__c.toLowerCase();
            }else{
                det.country_code_name = 'in';
            }
            try{
                system.debug('otp'+OTPNumber);
                OTP__c otpobj = new OTP__c();
                otpobj.Generated_Digital_Form_OTP__c = OTPNumber;
                otpobj.OTP_Generated_on__c = string.valueOf(system.now());
                otpobj.User_Info__c = userinfo.getFirstName() +' '+userinfo.getLastName();
                otpobj.Digital_Form_Customer_Number__c = opps[0].Account.Mobile_No__c;   
                otpobj.User__c = UserInfo.getUserId();
                otpobj.Account__c  = opps[0].AccountId;
                otpobj.OTP_Generate_For__c = 'Lockated Customer Creation';
                insert otpobj;
                
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsg(null, OTPNumber, null, null, null, null, null, null, null, opps[0].Account.Country_Code__c, opps[0].Account.Mobile_No__c, 'lockated_otp');
                }
                
                OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'customercare@runwalgroup.in'];
                Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
                String htmlBody = 'Dear Customer,<br/><br/>'; 
                htmlBody += 'Please use code ' + OTPNumber + ' to login in Runwal Connect app. <br/><br/>';
                htmlBody += 'Runwal Group<br/><br/>';
                message.toaddresses = new string[]{opps[0].RW_Email__c};
                message.subject = 'Runwal Connect app OTP'; 
                message.setHtmlBody(htmlBody);
                message.setOrgWideEmailAddressId(owea[0].Id);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
                
            }catch(Exception e){
                System.debug('Exception'+e.getMessage());
            }
            
            List<OppDetails> oppDetList = new List<OppDetails>();
            for(Opportunity opp : opps){
                OppDetails oppDet = new OppDetails();
                oppDet.flat = opp.RW_Project_Unit__r.RW_Param4__c;
                oppDet.tower = opp.RW_Project_Unit__r.RW_Param2__c;
                oppDet.customer_code = opp.SAP_Customer_Number__c;
                oppDet.booking_number = opp.Booking__c;
                oppDet.society_id = projNameVsSocityId.get(opp.RW_Project__r.Name);
                oppDetList.add(oppDet);
            }
            
            det.opportunityDetails = oppDetList;
            //createuser(new List<Id>{opps[0].AccountId}, otp);
            //return 'Customer found in SFDC and the details were triggered';
            return det;
        }else{
            //return 'Customer not found';
            det.message = 'Customer not found. Please contact your Sales Manager';
            return det;
        }
    }
    
    global class Details{
        String otp;
        String account_id;
        String firstname;
        String lastname;
        String email;
        String mobile;
        String country_code;
        String country_code_name;
        String message;
        List<OppDetails> opportunityDetails; 
    }
    
    
    global class OppDetails{
        String flat;
        String tower;
        String customer_code;
        String booking_number;
        String society_id;
    }
    
    
}