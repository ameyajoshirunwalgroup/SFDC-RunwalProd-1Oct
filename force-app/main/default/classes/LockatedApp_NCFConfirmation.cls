@RestResource(urlMapping='/ncf/*')
global class LockatedApp_NCFConfirmation {
    
    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, Object> errorResult = new Map<String, Object>();
        System.debug('bkgId: ' + bkgId);
        if(String.isBlank(bkgId) || bkgId == 'ncf'){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass the Booking Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            List<Name_Confirmation_Form__c> ncfRecords = [SELECT Id,Name,Address_Proof_Document__c,Address_Proof_Number__c,Booking__c,RW_Nominee_Name__c,RW_POA_Email__c,
                                                          NCF_Document_Id__c,PancardNo__c,RW_Active_NCF__c,RW_Allow_Customer_to_Update__c,RW_Nominee_PAN_Number__c,
                                                          RW_Primary_Aadhar_Number__c,RW_Primary_Country__c,RW_Primary_DOB__c,RW_Primary_Email__c,RW_POA_Phone_Number__c,
                                                          RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Primary_Mobile_Number__c,RW_POA_Name__c,RW_POA_PAN_Number__c,
                                                          RW_Primary_Permanent_Address_Line_1__c,NCF_Received_Date__c,Status__c,Applicant2_Name__c,RW_Primary_Permanent_Address_Line_3__c,
                                                          Applicant2_Email_Address__c,Applicant2_Mobile_No__c,Applicant2_Permanent_Address__c,RW_Primary_Permanent_Address_Line_2__c,
                                                          Applicant2_PAN__c,Applicant3_Name__c,Applicant4_Name__c,Applicant5_Name__c,Applicant3_Mobile_No__c,Subtype_Of_Applicant__c,
                                                          Applicant4_Mobile_No__c,Applicant5_Mobile_No__c,Applicant3_Permanent_Address__c,Applicant4_Permanent_Address__c,
                                                          Applicant5_Permanent_Address__c,Applicant3_Email_Address__c,Applicant4_Email_Address__c,Applicant5_Email_Address__c,
                                                          NCF_TAT__c FROM Name_Confirmation_Form__c WHERE Booking__c =: bkgId AND RW_Active_NCF__c = true]; 
            if(ncfRecords.size() > 0){
                Name_Confirmation_Form__c ncf = ncfRecords[0];
                NCFDetailsGet det = new NCFDetailsGet();
                det.applicant_1_name = ncf.RW_Primary_First_Name__c + ' ' + ncf.RW_Primary_Last_Name__c;
                det.applivant_1_pan = ncf.PancardNo__c;
                det.applicant_2_name = ncf.Applicant2_Name__c;
                det.applivant_2_pan = ncf.Applicant2_PAN__c;
                det.applicant_3_name = ncf.Applicant3_Name__c;
                det.applivant_3_pan = '';
                det.applicant_4_name = ncf.Applicant4_Name__c;
                det.applivant_4_pan = '';
                det.nominee_name = ncf.RW_Nominee_Name__c;
                det.nominee_pan = ncf.RW_Nominee_PAN_Number__c;
                det.poa_name = ncf.RW_POA_Name__c;
                det.poa_pan = ncf.RW_POA_PAN_Number__c;
                String addr = (ncf.RW_Primary_Permanent_Address_Line_1__c != null)? ncf.RW_Primary_Permanent_Address_Line_1__c : '';
                addr += (ncf.RW_Primary_Permanent_Address_Line_2__c != null)? ncf.RW_Primary_Permanent_Address_Line_2__c : '';
                addr += (ncf.RW_Primary_Permanent_Address_Line_3__c != null)? ncf.RW_Primary_Permanent_Address_Line_3__c : '';
                det.address = addr;
                det.poa_contact = ncf.RW_POA_Phone_Number__c;
        		det.poa_email = ncf.RW_POA_Email__c;
        		det.applicant_contact = ncf.RW_Primary_Mobile_Number__c;
        		det.applicant_email = ncf.RW_Primary_Email__c;
                det.residentialStatus = ncf.Subtype_Of_Applicant__c;
                
                res.responseBody = Blob.valueOf(JSON.serialize(det));
                res.statusCode = 200;
            }else{
                errorResult.put('status', 'error');
                errorResult.put('message', 'No NCF record found for this booking');
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
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            NCFDetailsPost resData = (NCFDetailsPost)JSON.deserialize(jsonBody, NCFDetailsPost.class);
            if(String.isNotBlank(resData.booking)){
                Booking__c bkg = new Booking__c();
                bkg.Id = resData.booking;
                bkg.NCF_Status__c = resData.ncf_status;
                update bkg;
                Name_Confirmation_Form__c ncf = [SELECT Id FROM Name_Confirmation_Form__c WHERE Booking__c =: resData.booking AND RW_Active_NCF__c = true];
                ncf.Status__c = 'Approved';
                update ncf;
                res.responseBody = Blob.valueOf('Details updated successfully');
                res.statusCode = 200;
            }else{
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
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
    
    global class NCFDetailsPost{
        public String booking;
        public String ncf_status;
    }
    
    global class NCFDetailsGet{
        public String applicant_1_name;
        public String applivant_1_pan;
        public String applicant_2_name;
        public String applivant_2_pan;
        public String applicant_3_name;
        public String applivant_3_pan;
        public String applicant_4_name;
        public String applivant_4_pan;
        public String nominee_name;
        public String nominee_pan;
        public String poa_name;
        public String poa_pan;
        public String address;
        public String poa_contact;
        public String poa_email;
        public String applicant_contact;
        public String applicant_email;
        public String residentialStatus;
    }
}