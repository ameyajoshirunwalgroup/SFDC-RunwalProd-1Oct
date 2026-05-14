@RestResource(urlMapping='/bankDetails/*')
global class BankDetailsSyncFromSAP {

    @HttpPost
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        system.debug('req: ' + req.requestBody);
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            Details resData = (Details)JSON.deserialize(jsonBody, Details.class);
            system.debug('resData: ' + resData);
            system.debug('booking: ' + resData.plank_code);
            if(String.isBlank(resData.plank_code)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass plant code');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Tower__c> tower = [SELECT Id, Legal_Entity__c FROM Tower__c WHERE SAP_Plant_Code__c =: resData.plank_code];
                Legal_Entity__c le = new Legal_Entity__c();
                le.Id = tower[0].Legal_Entity__c;
                le.Account_Name_Flat_Cost__c = resData.bank_details.acc_name;
                le.Account_Number_Flat_Cost__c = resData.bank_details.acc_number;
                le.IFSC_Code_Flat_Cost__c = resData.bank_details.ifsc;
                le.Bank_Name_Flat_Cost__c = resData.bank_details.bank_name;
                le.Branch_Flat_Cost__c = resData.bank_details.branch;
                if(resData.bank_details.address.length() <= 255){
                   le.RDS_Address1__c = resData.bank_details.address;
                }else{
                    le.RDS_Address1__c = resData.bank_details.address.substring(0,255);
                    le.RDS_Address2__c = resData.bank_details.address.substring(255, resData.bank_details.address.length() - 1);
                }
                le.Account_Number_GST_Deposit__c = resData.gst_details.gst_acc_number;
                le.Account_Number_GST_Deposit__c = resData.gst_details.gst_acc_name;
                le.Account_Number_Interest__c = resData.int_details.int_bank_acc_number;
                le.Favouring_Interest__c = resData.int_details.int_payable_fav;
                update le;
                res.responseBody = Blob.valueOf('Bank details updated successfully');
        		res.statusCode = 200;
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
        
    }
    
    public class Details{
        public string plank_code;
        public string material_code;
        public string plant_name;
        public Bank_Details bank_details;
        public GST_Details gst_details;
        public INT_Details int_details;
    }
    
    public class Bank_Details{
        public string acc_number;
        public string acc_name;
        public string ifsc;
        public string bank_name;
        public string branch;
        public string address;
    }
    
    public class GST_Details{
        public string gst_acc_number;
        public string gst_acc_name;
    }
    public class INT_Details{
        public string int_payable_fav;
        public string int_bank_acc_number;
        public string int_bank_address;
    }
}