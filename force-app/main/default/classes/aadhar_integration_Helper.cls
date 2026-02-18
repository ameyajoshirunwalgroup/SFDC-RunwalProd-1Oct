public without sharing class aadhar_integration_Helper {
    
    
    @AuraEnabled(cacheable=true)
    public static List<Applicant_Details__c> getApplicants(Id srecordId) {
        System.debug('Record ID received in getApplicants: ' + srecordId);
        return [
            SELECT Id, First_Name__c, Last_Name__c, Email_Address__c, issigned__c,Applicant_Number__c,UUID__c
            FROM Applicant_Details__c
            WHERE Booking__r.Id = :srecordId Order by Applicant_Number__c
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static String getBookingRecordID(Id sRrecordId) {
        System.debug('Record ID received: ' + sRrecordId);
        if (sRrecordId == null) {
            return null;
        }
        String signingURL = '';
        
       try {
            PageReference pdfPage = Page.Generate_BookingApplication_PDF;
            pdfPage.getParameters().put('id', sRrecordId);
            Blob pdfBlob = pdfPage.getContentAsPDF();
            String encodedBlob = EncodingUtil.base64Encode(pdfBlob);
            
            List<Applicant_Details__c> applicants = [
                SELECT Id, First_Name__c, Last_Name__c, Email_Address__c, isSigned__c,UUID__c, Applicant_Number__c	
                FROM Applicant_Details__c
                WHERE Booking__r.Id = :sRrecordId And
                Applicant_Number__c = 'Primary Applicant'
            ];
            
            True_Signed__mdt objTrueSigned = [
                SELECT API_Key__c, Initiator__c, signpxy__c, Workflow_Id__c, uploadfileURL__c, data_type__c
                FROM True_Signed__mdt
                WHERE DeveloperName = 'Upload_File'
                LIMIT 1
            ];
            
            for (Applicant_Details__c objApp : applicants) {
                String uuid = objApp.UUID__c ;
                String cs = EncodingUtil.convertToHex(
                    Crypto.generateDigest('SHA-256', Blob.valueOf(objTrueSigned.API_Key__c + uuid))
                );
                
               	String receiverEmail = objApp.Email_Address__c;
                String initiator = objTrueSigned.Initiator__c;
                String workflowId = objTrueSigned.Workflow_Id__c;
                String signLoc = objTrueSigned.signpxy__c;
                String signerEmail = objApp.Email_Address__c;
                String signerName = objApp.First_Name__c + ' ' + objApp.Last_Name__c;
                
                String callbackUrl = 'https://runwal--fullcopy.sandbox.my.site.com/customer/s/sign-complete?bookingId=' + sRrecordId;
                system.debug('call back url ===>' + callbackUrl);
                String requestBody = 
                    '{' +
                    '"uuid":"' + uuid + '",' +
                    '"cs":"' + cs + '",' +
                    '"receiveremail":"' + receiverEmail + '",' +
                    '"initiator":"' + initiator + '",' +
                    '"signerlist":[{' +
                    '"signer":"' + signerEmail + '",' +
                    '"signer_name":"' + signerName + '",' +
                    '"seq_no":1,' +
                    '"parallel_index":1' +
                    '}],' +
                    '"workflow_id":"' + workflowId + '",' +
                    '"uploadfile":"' + encodedBlob + '",' +
                    '"callbackurl":"' + callbackUrl + '"' +
                    '}';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(objTrueSigned.uploadfileURL__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(requestBody);
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                
                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    signingURL = string.ValueOf(responseMap.get('url'));
                    System.debug('signingURL ===> ' + signingURL);
                    string message = string.ValueOf(responseMap.get('message'));
                    System.debug('message ===> ' + message);
                    string page = string.ValueOf(responseMap.get('page'));
                    System.debug('page ===> ' + page);
                    string widget = string.ValueOf(responseMap.get('widget'));
                    System.debug('widget ===> ' + widget);
                    string sUuid = string.ValueOf(responseMap.get('uuid'));
                    System.debug('sUuid ===> ' + sUuid);
                    
                } else {
                    System.debug('API call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
        
        return signingURL;
    }
    
    @AuraEnabled(cacheable=True)
    Public static string downloadsignedPdf(string UUID, string Cs, string bookingId){
        system.debug('i am in download method');
        String base64EncodedPDF = '';
        string signingUrl = '';
        String apiUrl = 'https://tsonestage.truecopy.in/services/corpservice/v2/fetchsignedfile/'+UUID+'/'+Cs;
        system.debug('Api call in download signed pdf'+ apiUrl);
        String requestBody = 
            '{' +
            '"uuid":"' + UUID + '",' +
            '"cs":"' + Cs + '"' +
            '}';
        system.debug('i am in requestBody method'+ requestBody);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('GET');
        //req.setHeader('Content-Type', 'application/octet-stream');
        //req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            Blob pdfBlob = res.getBodyAsBlob();
            base64EncodedPDF = EncodingUtil.base64Encode(pdfBlob);
            //getSigningURLforsecond(base64EncodedPDF);
            system.debug('base 64 file ===>'+ base64EncodedPDF);
        }
        
        if(base64EncodedPDF != null){
            system.debug('i am inside second APi');
          	List<Applicant_Details__c> applicants = [
                SELECT Id, First_Name__c, Last_Name__c, Email_Address__c, isSigned__c,UUID__c, Applicant_Number__c	
                FROM Applicant_Details__c
                WHERE Booking__r.Id = :bookingId And Applicant_Number__c = 'Second Applicant'
            ];
            
            True_Signed__mdt objTrueSigned = [
                SELECT API_Key__c, Initiator__c, signpxy__c, Workflow_Id__c, uploadfileURL__c, data_type__c
                FROM True_Signed__mdt
                WHERE DeveloperName = 'Upload_File'
                LIMIT 1
            ];
            
            for (Applicant_Details__c objApp : applicants) {
                system.debug('i am inside applicant details');
                String suuid = objApp.UUID__c;
                String scs = EncodingUtil.convertToHex(
                    Crypto.generateDigest('SHA-256', Blob.valueOf(objTrueSigned.API_Key__c + suuid))
                );
                System.debug('scs==>'+ scs);
               	String receiverEmail = objApp.Email_Address__c;
                String initiator = objTrueSigned.Initiator__c;
                String workflowId = objTrueSigned.Workflow_Id__c;
                String signLoc = objTrueSigned.signpxy__c;
                String signerEmail = objApp.Email_Address__c;
                String signerName = objApp.First_Name__c + ' ' + objApp.Last_Name__c;
                system.debug('i am before second callback url');
                String callbackUrl = 'https://runwal--fullcopy.sandbox.my.site.com/customer/s/sign-complete?bookingId=' + bookingId;
                
                String signingrequestBody = 
                    '{' +
                    '"uuid":"' + suuid + '",' +
                    '"cs":"' + scs + '",' +
                    '"receiveremail":"' + receiverEmail + '",' +
                    '"initiator":"' + initiator + '",' +
                    '"signerlist":[{' +
                    '"signer":"' + signerEmail + '",' +
                    '"signer_name":"' + signerName + '",' +
                    '"seq_no":2,' +
                    '"parallel_index":1' +
                    '}],' +
                    '"workflow_id":"' + workflowId + '",' +
                    '"uploadfile":"' + base64EncodedPDF + '",' +
                    '"callbackurl":"' + callbackUrl + '"' +
                    '}';
                system.debug('signingrequestBody ===>'+ signingrequestBody);
                HttpRequest reqsigning = new HttpRequest();
                reqsigning.setEndpoint(objTrueSigned.uploadfileURL__c);
                reqsigning.setMethod('POST');
                reqsigning.setHeader('Content-Type', 'application/json');
                reqsigning.setBody(signingrequestBody);
                
                Http shttp = new Http();
                HttpResponse resSigning = shttp.send(reqsigning);
                
                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resSigning.getBody());
                    signingURL = string.ValueOf(responseMap.get('url'));
                    System.debug('signingURL ===> ' + signingURL);
                    string message = string.ValueOf(responseMap.get('message'));
                    System.debug('message ===> ' + message);
                    string page = string.ValueOf(responseMap.get('page'));
                    System.debug('page ===> ' + page);
                    string widget = string.ValueOf(responseMap.get('widget'));
                    System.debug('widget ===> ' + widget);
                    string sUid = string.ValueOf(responseMap.get('uuid'));
                    System.debug('sUuid ===> ' + sUuid);
                    
                    
                } else {
                    System.debug('API call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
                }
            }  
            
        }
        
        return signingUrl;
    }
    
    
    @AuraEnabled(cacheable=true)
    Public static string downloadfinalPdf(string UUID, string Cs){
        String base64EncodedPDF = '';
        string signingUrl = '';
        String apiUrl = 'https://tsonestage.truecopy.in/services/corpservice/v2/fetchsignedfile/'+UUID+'/'+Cs;
        system.debug('api url ==>' + apiUrl);
        String requestBody = 
            '{' +
            '"uuid":"' + UUID + '",' +
            '"cs":"' + Cs + '"' +
            '}';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiUrl);
        req.setMethod('GET');
        //req.setHeader('Content-Type', 'application/octet-stream');
        //req.setBody(requestBody);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('response body ==>' + res);
        if (res.getStatusCode() == 200) {
            Blob pdfBlob = res.getBodyAsBlob();
            base64EncodedPDF = EncodingUtil.base64Encode(pdfBlob);
            system.debug('base 64 file ===>'+ base64EncodedPDF);
            
        }
    	return base64EncodedPDF;
    }
    
}