@RestResource(urlMapping='/primaryApplicant/*')
global class LockatedApp_PrimaryApplicant {
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        
        try{
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            system.debug('jsonBody: ' + jsonBody);
            Applicant resData = (Applicant)JSON.deserialize(jsonBody, Applicant.class);
            system.debug('resData: ' + resData);
            system.debug('booking: ' + resData.customerProfileDetails.booking);
            if(String.isBlank(resData.customerProfileDetails.booking)){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Booking__c> bkg = [SELECT Id FROM Booking__c WHERE Id =: resData.customerProfileDetails.booking];
                if(bkg.size() == 0){
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Booking record not found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }else{
                    system.debug('fullName: ' + resData.customerProfileDetails.PrimaryApplicants[0].fullName);
                    List<Applicant_Details__c> apps = [SELECT Id,Name,DOB__c,PancardNo__c,GSTIN_Number__c,Organization_Name__c,Designation__c,Permanent_Address__c,Email_Address__c,Mobile_Number__c,Correspondence_Address__c FROM Applicant_Details__c WHERE Booking__c =: resData.customerProfileDetails.booking AND Applicant_Number__c = 'Primary Applicant'];
                    if(apps.size() > 0){
                        Boolean updateApplicant = false;
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].fullName) && apps[0].Name != resData.customerProfileDetails.PrimaryApplicants[0].fullName){
                            apps[0].Name = resData.customerProfileDetails.PrimaryApplicants[0].fullName;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].birthDate) && apps[0].DOB__c != Date.valueOf(resData.customerProfileDetails.PrimaryApplicants[0].birthDate)){
                            apps[0].DOB__c = Date.valueOf(resData.customerProfileDetails.PrimaryApplicants[0].birthDate);
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].panCard) && apps[0].PancardNo__c != resData.customerProfileDetails.PrimaryApplicants[0].panCard){
                            apps[0].PancardNo__c = resData.customerProfileDetails.PrimaryApplicants[0].panCard;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].gstinNumber) && apps[0].GSTIN_Number__c != resData.customerProfileDetails.PrimaryApplicants[0].gstinNumber){
                            apps[0].GSTIN_Number__c = resData.customerProfileDetails.PrimaryApplicants[0].gstinNumber;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].companyName) && apps[0].Organization_Name__c != resData.customerProfileDetails.PrimaryApplicants[0].companyName){
                            apps[0].Organization_Name__c = resData.customerProfileDetails.PrimaryApplicants[0].companyName;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].designation) && apps[0].Designation__c != resData.customerProfileDetails.PrimaryApplicants[0].designation){
                            apps[0].Designation__c = resData.customerProfileDetails.PrimaryApplicants[0].designation;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].permanentAddress) && apps[0].Permanent_Address__c != resData.customerProfileDetails.PrimaryApplicants[0].permanentAddress){
                            apps[0].Permanent_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].permanentAddress;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].emailId) && apps[0].Email_Address__c != resData.customerProfileDetails.PrimaryApplicants[0].emailId){
                            apps[0].Email_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].emailId;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].mobileNumber) && apps[0].Mobile_Number__c != resData.customerProfileDetails.PrimaryApplicants[0].mobileNumber){
                            apps[0].Mobile_Number__c = resData.customerProfileDetails.PrimaryApplicants[0].mobileNumber;
                            updateApplicant = true;
                        }
                        if(!String.isBlank(resData.customerProfileDetails.PrimaryApplicants[0].correspondenceAddress) && apps[0].Correspondence_Address__c != resData.customerProfileDetails.PrimaryApplicants[0].correspondenceAddress){
                            apps[0].Correspondence_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].correspondenceAddress;
                            updateApplicant = true;
                        }
                        if(updateApplicant == true){
                            update apps[0];
                            res.responseBody = Blob.valueOf('Details updated successfully');
                            res.statusCode = 200;
                        }
                    }else if(apps.size() == 0){
                        Applicant_Details__c app = new Applicant_Details__c();
                        app.Name = resData.customerProfileDetails.PrimaryApplicants[0].fullName;
                        app.DOB__c = (resData.customerProfileDetails.PrimaryApplicants[0].birthDate != '')? Date.valueOf(resData.customerProfileDetails.PrimaryApplicants[0].birthDate) : null;
                        app.PancardNo__c = resData.customerProfileDetails.PrimaryApplicants[0].panCard;
                        app.GSTIN_Number__c = resData.customerProfileDetails.PrimaryApplicants[0].gstinNumber;
                        app.Organization_Name__c = resData.customerProfileDetails.PrimaryApplicants[0].companyName;
                        app.Designation__c = resData.customerProfileDetails.PrimaryApplicants[0].designation;
                        app.Permanent_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].permanentAddress;
                        app.Email_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].emailId;
                        app.Mobile_Number__c = resData.customerProfileDetails.PrimaryApplicants[0].mobileNumber;
                        app.Booking__c = resData.customerProfileDetails.booking;
                        app.Correspondence_Address__c = resData.customerProfileDetails.PrimaryApplicants[0].correspondenceAddress;
                        res.responseBody = Blob.valueOf('Details updated successfully');
                		res.statusCode = 200;
                        insert app;
                    }
                    if(resData.customerProfileDetails.coApplicants != null && resData.customerProfileDetails.coApplicants.size() > 0){
                        List<Applicant_Details__c> coApps = [SELECT Id,Name,DOB__c,PancardNo__c,GSTIN_Number__c,Organization_Name__c,Designation__c,Permanent_Address__c,Email_Address__c,Mobile_Number__c,Correspondence_Address__c FROM Applicant_Details__c WHERE Booking__c =: resData.customerProfileDetails.booking AND Applicant_Number__c != 'Primary Applicant'];
                        if(coApps.size() > 0){
                            List<Applicant_Details__c> coAppsToUpdate = new List<Applicant_Details__c>();
                            for(CoApplicant resp : resData.customerProfileDetails.coApplicants){
                                for(Applicant_Details__c coApp : coApps){
                                    if((resp.panCard != null && resp.panCard == coApp.PancardNo__c) || (resp.birthDate != null && resp.birthDate == String.valueOf(coApp.DOB__c))){
                                        coApp.Name = (!String.isBlank(resp.fullName) && coApp.Name != resp.fullName)? resp.fullName : coApp.Name;
                                        coApp.DOB__c = (resp.birthDate != null && resp.birthDate != '' && String.valueOf(coApp.DOB__c) != resp.birthDate)? Date.valueOf(resp.birthDate) : coApp.DOB__c;
                                        coApp.PancardNo__c = (!String.isBlank(resp.panCard) && coApp.PancardNo__c != resp.panCard)? resp.panCard : coApp.PancardNo__c;
                                        coApp.GSTIN_Number__c = (!String.isBlank(resp.gstinNumber) && coApp.GSTIN_Number__c != resp.gstinNumber)? resp.gstinNumber : coApp.GSTIN_Number__c;
                                        coApp.Organization_Name__c = (!String.isBlank(resp.companyName) && coApp.Organization_Name__c != resp.companyName)? resp.companyName : coApp.Organization_Name__c;
                                        coApp.Designation__c = (!String.isBlank(resp.designation) && coApp.Designation__c != resp.designation)? resp.designation : coApp.Designation__c;
                                        coApp.Permanent_Address__c = (!String.isBlank(resp.permanentAddress) && coApp.Permanent_Address__c != resp.permanentAddress)? resp.permanentAddress : coApp.Permanent_Address__c;
                                        coApp.Correspondence_Address__c = (!String.isBlank(resp.correspondenceAddress) && coApp.Correspondence_Address__c != resp.correspondenceAddress)? resp.correspondenceAddress : coApp.Correspondence_Address__c;
                                        coApp.Email_Address__c = (!String.isBlank(resp.emailId) && coApp.Email_Address__c != resp.emailId)? resp.emailId : coApp.Email_Address__c;
                                        coApp.Mobile_Number__c = (!String.isBlank(resp.mobileNumber) && coApp.Mobile_Number__c != resp.mobileNumber)? resp.mobileNumber : coApp.Mobile_Number__c;
                                        coAppsToUpdate.add(coApp);
                                    }
                                }
                            }
                            if(coAppsToUpdate.size() > 0){
                                update coAppsToUpdate;
                                res.responseBody = Blob.valueOf('Details updated successfully');
                				res.statusCode = 200;
                            }
                        }
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
    
    public class Applicant{
        public CustomerProfileDetails customerProfileDetails;
    }
    
    public class CustomerProfileDetails{
        public String booking;
        public List<PrimaryApplicant> PrimaryApplicants;
        public List<CoApplicant> coApplicants;
    }
    
    public class PrimaryApplicant{
        public String fullName;
        public String birthDate;
        public String panCard;
        public String gstinNumber;
        public String companyName;
        public String designation;
        public String permanentAddress;
        public String correspondenceAddress;
        public String emailId;
        public String mobileNumber;
    }
    
    public class CoApplicant{
        public String fullName;
        public String birthDate;
        public String panCard;
        public String gstinNumber;
        public String companyName;
        public String designation;
        public String permanentAddress;
        public String correspondenceAddress;
        public String emailId;
        public String mobileNumber;
    }
}