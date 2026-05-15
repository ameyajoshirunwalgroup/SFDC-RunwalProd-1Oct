@RestResource(urlMapping='/documents/*')
global class LockatedApp_DocumentDetails {
    
    @HttpGet
    global static void doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            if(String.isBlank(bkgId) || bkgId == 'documents'){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{ 
                List<Booking__c> bkgs = [SELECT Id, RW_Signed_Agreement_Document_Id__c, Possession_Guidelines_Sent_Date__c,Booking_Form_Id__c FROM Booking__c WHERE Id =: bkgId];
                if(bkgs.size() > 0){
                    DocumentDetails det = new DocumentDetails();
                    Documents doc = new Documents();
                    
                    DocDetails bkgForm = new DocDetails();
                    bkgForm.title = 'Booking Form';
                    bkgForm.doc_number = '';
                    bkgForm.doc_date = '';
                    //bkgForm.url = 'https://runwal--fullcopy.sandbox.my.salesforce-sites.com/PreviewBooking/?id='+bkgId;
                    bkgForm.url = distPublicUrl(bkgs[0].Booking_Form_Id__c);
                    doc.booking_form = bkgForm;
                    
                    DocDetails agr = new DocDetails();
                    agr.title = 'Agreement';
                    agr.doc_number = '';
                    agr.doc_date = '';
                    //agr.url = 'https://runwal--fullcopy.sandbox.my.salesforce-sites.com/AgreementDoc/'+bkgs[0].RW_Signed_Agreement_Document_Id__c;
                    RestRequest req10= new RestRequest(); 
                    RestResponse res10 = new RestResponse();
                    req10.requestURI = 'https://runwal--fullcopy.sandbox.my.salesforce.com/services/apexrest/AgreementDoc/'+bkgs[0].RW_Signed_Agreement_Document_Id__c; 
                    req10.httpMethod = 'Get';
                    req10.addHeader('Content-Type', 'application/json'); 
                    RestContext.request = req10;
                    RestContext.response = res10;
                    if(!Test.isRunningTest()){
                        agr.url = AgreementDocRest.doGet();
                    }
                    //agr.url = AgreementDocRest.doGet();
                    doc.agreement = agr;
                    
                    List<Applicant_Details__c> apps = [SELECT Id, Booking__c FROM Applicant_Details__c WHERE Booking__c =: bkgId AND Applicant_Number__c = 'Primary Applicant'];
                    List<Document_Details__c> documentDetailsRecord = [SELECT Id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,
                                                                       RW_Document_Type__c,RW_Residential_Status__c,CreatedDate 
                                                                       FROM Document_Details__c WHERE RW_Applicant_Details__c =: apps[0].Id];
                    Map<String, Document_Details__c> mapDocTypeVsdoc = new Map<String, Document_Details__c>();
                    List<DocDetails> kycDocs = new List<DocDetails>();
                    if(documentDetailsRecord.size() > 0){
                        for(Document_Details__c d : documentDetailsRecord){
                            mapDocTypeVsdoc.put(d.RW_Document_Type__c, d);
                            DocDetails kycDoc = new DocDetails();
                            kycDoc.title = d.RW_Document_Type__c;
                            kycDoc.doc_number = '';
                            kycDoc.doc_date = String.valueOf(d.CreatedDate);
                            kycDoc.url = distPublicUrl(d.RW_Document_ID__c);
                            kycDocs.add(kycDoc);
                            
                        }
                        
                        
                        /*DocDetails kyc_aadhar = new DocDetails();
kyc_aadhar.title = 'Aadhar Card';
kyc_aadhar.doc_number = '';
kyc_aadhar.doc_date = String.valueOf(mapDocTypeVsdoc.get('Aadhar Card').CreatedDate);
kyc_aadhar.url = distPublicUrl(mapDocTypeVsdoc.get('Aadhar Card').RW_Document_ID__c);
kycDocs.add(kyc_aadhar);

DocDetails kyc_pan = new DocDetails();
kyc_pan.title = 'Pan Card';
kyc_pan.doc_number = '';
kyc_pan.doc_date = String.valueOf(mapDocTypeVsdoc.get('PAN Card').CreatedDate);
kyc_pan.url = distPublicUrl(mapDocTypeVsdoc.get('PAN Card').RW_Document_ID__c);
kycDocs.add(kyc_pan);*/
                        
                        doc.kyc = kycDocs;
                        
                    }
                    
                    List<Loan__c> loans = [SELECT Id, RW_Sanction_Letter_ID__c, RW_Sanction_Date__c FROM Loan__c WHERE RW_Booking__c = : bkgId];
                    if(loans.size() > 0){
                        List<DocDetails> sanctionLetters = new List<DocDetails>();
                        DocDetails sanctionLetter = new DocDetails();
                        sanctionLetter.title = 'Sanction Letter';
                        sanctionLetter.doc_number = '';
                        sanctionLetter.doc_date = String.valueOf(loans[0].RW_Sanction_Date__c);
                        sanctionLetter.url = distPublicUrl(loans[0].RW_Sanction_Letter_ID__c);
                        sanctionLetters.add(sanctionLetter);
                        doc.sanction_letter = sanctionLetters;
                    }
                    
                    DocDetails possessionDoc = new DocDetails();
                    possessionDoc.title = 'Possession Guidelines';
                    possessionDoc.doc_number = '';
                    possessionDoc.doc_date = String.valueOf(bkgs[0].Possession_Guidelines_Sent_Date__c);
                    possessionDoc.url = distPublicUrl(System.label.Possession_Guidelines_Doc_Id);
                    doc.possession_guide = possessionDoc;
                    
                    /*List<RW_Demand__c> demands = [SELECT Id, Name, (SELECT Id, Name, RW_Usage_Code__c FROM Demand_Items__r) FROM RW_Demand__c WHERE Booking__c =: bkgId AND RW_Demand_Status__c != 'Revoke' AND Demand_Amount__c != 0 ORDER BY CreatedDate Desc LIMIT 3];
if(demands.size() > 0){
List<DocDetails> demandDocs = new List<DocDetails>();
for(RW_Demand__c dem : demands){
DocDetails demandDoc = new DocDetails();
demandDoc.title = 'Possession Guidelines';
demandDoc.doc_number = '';
demandDoc.doc_date = String.valueOf(bkgs[0].Possession_Guidelines_Sent_Date__c);
demandDoc.url = 'https://runwal--fullcopy.sandbox.my.salesforce-sites.com/crmbotdoc?id='+dem.Id+'&doc=dem';
demandDocs.add(demandDoc);
}
doc.demand_letters = demandDocs;
}

List<RW_Payment_Details__c> recps = [SELECT Id, Name FROM RW_Payment_Details__c WHERE RW_Booking__c =: bkgId AND RW_Document_Type__c IN ('DZ','DT','DF') AND Status__c != 'Reversed' ORDER BY CreatedDate Desc LIMIT 3];
if(recps.size() > 0){
List<DocDetails> receiptDocs = new List<DocDetails>();
for(RW_Payment_Details__c rec : recps){
DocDetails receiptDoc = new DocDetails();
receiptDoc.title = 'Possession Guidelines';
receiptDoc.doc_number = '';
receiptDoc.doc_date = String.valueOf(bkgs[0].Possession_Guidelines_Sent_Date__c);
receiptDoc.url = 'https://runwal--fullcopy.sandbox.my.salesforce-sites.com/crmbotdoc?id='+rec.Id+'&doc=recp';
receiptDocs.add(receiptDoc);
}
doc.payment_receipts = receiptDocs;
}*/
                    
                    det.documents = doc;
                    //return det;
                    
                    res.responseBody = Blob.valueOf(JSON.serialize(det));
                	res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Booking record not found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
            }            
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
        
    }
    
    public static String distPublicUrl(String docId){
        if(docId != null){
            System.debug('docId: ' + docId);
            List<ContentVersion> file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: docId];
            System.debug('file: ' + file);
            List<ContentDistribution> dist = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                              WHERE ContentVersionId =: file[0].Id LIMIT 1];
            if(dist.size() > 0){
                return dist[0].DistributionPublicUrl;
            }else{
                ContentDistribution newDist = new ContentDistribution(
                    Name = file[0].Title,
                    ContentVersionId = file[0].Id,
                    PreferencesAllowViewInBrowser= true,
                    PreferencesNotifyOnVisit = false);
                insert newDist;
                ContentDistribution distb = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id =: newDist.Id];
                return distb.DistributionPublicUrl;
            }
        }else{
            return 'Please upload the document';
        }
        
    }
    
    global class DocumentDetails{
        public Documents documents;
    }
    
    public class Documents{
        public DocDetails booking_form;
        public DocDetails agreement;
        public DocDetails possession_guide;
        public List<DocDetails> kyc;
        //public List<DocDetails> demand_letters;
        //public List<DocDetails> payment_receipts;
        public List<DocDetails> sanction_letter;
    }
    public class DocDetails{
        public string title;
        public string doc_number;
        public string doc_date;
        public string url;
    }
    
}