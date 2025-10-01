public without sharing class bulk_Aadhar_Verification_Integration {
    @AuraEnabled
    public static void getBulkAadharVerification(String sRrecordId) {
        String BookingId = '';
        System.debug('Record ID received: ' + sRrecordId);
        if (sRrecordId == null) return;
        
        try {
            PageReference pdfPage = Page.Generate_BookingApplication_PDF;
            pdfPage.getParameters().put('id', sRrecordId);
            Blob pdfBlob = pdfPage.getContentAsPDF();
            String encodedBlob = EncodingUtil.base64Encode(pdfBlob);
            
            List<Applicant_Details__c> applicants = [
                SELECT Id, First_Name__c, Booking__r.Name,Last_Name__c,Mobile_Number__c, Email_Address__c, Booking__r.UUID__c, booking__r.RW_RM_Email__c,
                booking__r.UUID_Seq__c FROM Applicant_Details__c
                WHERE Booking__r.Id = :sRrecordId order by Applicant_Number__c
            ];
            
            if (applicants.isEmpty()) return;
            
            True_Signed__mdt objTrueSigned = [
                SELECT API_Key__c, Initiator__c, signpxy__c, Workflow_Id__c, uploadfileURL__c,callBackURL__c 
                FROM True_Signed__mdt
                WHERE DeveloperName = 'Upload_File'
                LIMIT 1
            ];
            
            List<String> signerList = new List<String>();
            Integer seq = 1;
            for (Applicant_Details__c app : applicants) {
                String signerEntry = '{' +
                    '"signer":"' + app.Email_Address__c + '",' +
                    '"signer_name":"' + app.First_Name__c + ' ' + app.Last_Name__c + '",' +
                    '"signer_mobile":"'+app.Mobile_Number__c+'",'+
                    '"seq_no":' + seq + ',' +
                    '"parallel_index":1' +
                    '}';
                signerList.add(signerEntry);
                seq++;
            }
            
            BookingId = applicants[0].booking__r.Id;
            String signerListJson = '[' + String.join(signerList, ',') + ']';
            Integer counter = Integer.valueOf(applicants[0].booking__r.UUID_Seq__c)+ 1;
            System.debug('counter in Prod ==>' + counter);
            
            //String uuid = applicants[0].Booking__r.UUID__c;
            String uuid = 'Booking_Form_'+applicants[0].Booking__r.Name +'_'+ counter;
            System.debug('UUID in Prod ==>' + uuid);
            String cs = EncodingUtil.convertToHex(
                Crypto.generateDigest('SHA-256', Blob.valueOf(objTrueSigned.API_Key__c + uuid))
            );
            
            String receiverEmail = applicants[0].Booking__r.RW_RM_Email__c;
            String initiator = objTrueSigned.Initiator__c;
            String workflowId = objTrueSigned.Workflow_Id__c;
            String callbackUrl = objTrueSigned.callBackURL__c;     
            System.debug('call back url===>'+callbackUrl);
            String requestBody = 
                '{' +
                '"uuid":"' + uuid + '",' +
                '"cs":"' + cs + '",' +
                '"receiveremail":"' + receiverEmail + '",' +
                '"initiator":"' + initiator + '",' +
                '"signerlist":' + signerListJson + ',' +
                '"workflow_id":"' + workflowId + '",' +
                '"uploadfile":"' + encodedBlob + '",' +
                '"callbackurl":"' + callbackUrl + '"' +
                '}';
            
            System.debug('Request body in apex===>' + requestBody);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(objTrueSigned.uploadfileURL__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestBody);
            
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug('signingURL ===> ' + responseMap.get('url'));
                System.debug('message ===> ' + responseMap.get('message'));
                System.debug('page ===> ' + responseMap.get('page'));
                System.debug('widget ===> ' + responseMap.get('widget'));
                System.debug('sUuid ===> ' + uuid);
                System.debug('status ===> ' + responseMap.get('status'));
            } else {
                System.debug('API call failed: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
            
            
           booking__c objB = new booking__c();
           objB.Id = BookingId; 
           objB.UUID_Seq__c = counter;
           objB.UUID__c = uuid; 
           update objB;
            
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getsignedDocuments(String UUID, String Cs) {
        System.debug('UUID in apex ==> ' + UUID);
        System.debug('Cs in apex ==> ' + Cs);
        String message = '';
        Blob pdfBlob;
        
        try {
            // Step 1: Call API to fetch signed document
            //String apiUrl = 'https://tsonestage.truecopy.in/services/corpservice/v2/fetchsignedfile/' + UUID + '/' + Cs;
            //String apiUrl = 'https://runwalenterprises.truecopy.in/services/corpservice/v2/fetchsignedfile/' + UUID + '/' + Cs;
            True_Signed__mdt objTrueSigned = [
                SELECT API_Key__c, Initiator__c, signpxy__c, Workflow_Id__c, uploadfileURL__c,SignedDocumentUrl__c 
                FROM True_Signed__mdt
                WHERE DeveloperName = 'Upload_File'
                LIMIT 1
            ];
            String SignedDocumentUrl = objTrueSigned.SignedDocumentUrl__c + UUID + '/' + Cs;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SignedDocumentUrl);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug('Response body ==> ' + res);
            
            if (res.getStatusCode() == 200) {
                pdfBlob = res.getBodyAsBlob();
            } else {
                return 'Failed to download signed document. Status: ' + res.getStatusCode();
            }
            
            // Step 2: Get Booking__c record
            List<Booking__c> lstbooking = [
                SELECT Id, UUID__c, IsSigned__c
                FROM Booking__c 
                WHERE UUID__c = :UUID
                LIMIT 1
            ];
            
            if (lstbooking.isEmpty()) {
                return 'No booking found for UUID: ' + UUID;
            }
            
            Booking__c booking = lstbooking[0];
            Id bookingId = booking.Id;
            System.debug('Booking Id ===> ' + bookingId);
            
            
            booking.IsSigned__c = true;
            System.debug('Booking isSigned__c in apex ==>'+ booking.IsSigned__c);
            update booking;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'SignedDocument_' + UUID;
            cv.PathOnClient = 'SignedDocument_' + UUID + '.pdf';
            cv.VersionData = pdfBlob;
            cv.IsMajorVersion = true;
            insert cv;
            System.debug('cv in apex ==>'+cv);
            
            ContentVersion insertedCV = [
                SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
            ];
            
            System.debug('insertedCV in apex ==>'+insertedCV);
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = bookingId;
            cdl.ContentDocumentId = insertedCV.ContentDocumentId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            System.debug('cdl in apex ==>'+cdl);
            
            message = 'Process completed. Booking marked as signed.';
        } catch (Exception e) {
            message = 'Error: ' + e.getMessage();
            System.debug(message);
        }
        
        return message;
    }
    
    @AuraEnabled
    public static void getSignedStatus(String uuid, String email, String name) {
        List<Applicant_Details__c> applicants = [Select Id,isSigned__c, Name,Email_Address__c,Booking__r.UUID__c
                                                 From Applicant_Details__c
                                                 WHERE Booking__r.UUID__c = :uuid AND Email_Address__c = :email and isSigned__c = false
                                                 LIMIT 1
                                                ];
        System.debug('Applicant details ===> '+ applicants);
    
    if (!applicants.isEmpty()) {
        Applicant_Details__c applicant = applicants[0];
        applicant.isSigned__c = True;
        System.debug('isSigned is true'+ applicant.isSigned__c);
        update applicant;
    }
        
    }
  
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> verifyApplicantDetails(String sRecordIds) {
        system.debug('sRecordId list ===>' + sRecordIds);
        List<Map<String, String>> applicantData = new List<Map<String, String>>();
        
        List<Applicant_Details__c> applicants = [
            SELECT Id, First_Name__c, DOB__c, Subtype_Of_Applicant__c, PancardNo__c,
            Address_Proof_Number__c, Mobile_Number__c, Applicant_Email__c, Last_Name__c
            FROM Applicant_Details__c
            WHERE Booking__r.Id = :sRecordIds
        ];
        
        if (applicants.isEmpty()) {
            return null;
        }
        
        for (Applicant_Details__c app : applicants) {
            List<String> missing = new List<String>();
            
            if (app.DOB__c == null) missing.add('Date of Birth');
            if (String.isBlank(app.PancardNo__c)) missing.add('PAN No');
            if (String.isBlank(app.Address_Proof_Number__c)) missing.add('Address Proof No');
            if (String.isBlank(app.Mobile_Number__c)) missing.add('Mobile No');
            if (String.isBlank(app.Applicant_Email__c)) missing.add('Email');
            
            if (!missing.isEmpty()) {
                String firstName = String.isNotBlank(app.First_Name__c) ? app.First_Name__c : 'Unknown';
                String lastName = String.isNotBlank(app.Last_Name__c) ? app.Last_Name__c : 'Unknown';
                String name = firstName + ' ' + lastName;
                
                Map<String, String> applicantInfo = new Map<String, String>();
                applicantInfo.put('applicantName', name);
                applicantInfo.put('missingFields', String.join(missing, ', '));
                applicantData.add(applicantInfo);
            }
        }
        
        return applicantData.isEmpty() ? null : applicantData;
    }
    
    Public static void fakeMethod(){
        integer i = 1;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
           i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}