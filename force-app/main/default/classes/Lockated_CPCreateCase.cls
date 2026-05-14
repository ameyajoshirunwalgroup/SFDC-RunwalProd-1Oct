@RestResource(urlMapping='/cpCreateCase/*')
global without sharing class Lockated_CPCreateCase {

    @HttpPost
    global static void createCase() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        RestRequest req = RestContext.request;
        String brokerId = req.params.get('brokerId');
        
            try {
                if (req == null || req.requestBody == null) {
                    sendErrorResponse(400, 'Invalid request. Request body is empty.');
                    return;
                }
                
                CaseRequest input;
                try {
                    input = (CaseRequest) JSON.deserialize(req.requestBody.toString(), CaseRequest.class);
                } catch (Exception parseEx) {
                    sendErrorResponse(400, 'Invalid JSON format: ' + parseEx.getMessage());
                    return;
                }
                
                if (String.isBlank(input.category) || String.isBlank(input.description)) {
                    sendErrorResponse(400, 'Missing required fields: category or description.');
                    return;
                }
                
                if(String.isBlank(brokerId)){
                    sendErrorResponse(400, 'Please pass valid CP Id');
                    return;
                }
                
                Case newCase = createNewCaseRecord(brokerId,input);
                list<Opportunity> opplist = [Select Id from Opportunity where StageName = 'Unit Booked' and RW_Broker__c  =: brokerId Order by Createddate desc limit 1];
                newCase.Opportunity__c = opplist[0].Id;
                system.debug('newCase. - > '+newCase);
                try {
                    insert newCase;
                } catch (DmlException dmlEx) {
                    sendErrorResponse(500, 'Failed to create Case: ' + dmlEx.getDmlMessage(0));
                    return;
                }
                
                //Take the most Recent Opportunity Id - As discussed with Internal Team.
                
                list<ContentVersion> cvlist = new list<ContentVersion>();
                For(Documents d : input.documents){
                    system.debug('Attachment -> '+d.attachment);
                    system.debug('fileName -> '+d.fileName);
                    system.debug('fileType -> '+d.fileType);
                    String base64Data = d.attachment;  
                    Blob fileBody = EncodingUtil.base64Decode(base64Data);
                    
                    ContentVersion cv = new ContentVersion(
                        VersionData = fileBody,
                        PathOnClient = d.fileName + '.' + d.fileType,
                        Title = d.fileName
                    );
                    cvlist.add(cv);
                }
                system.debug('cvlist -> '+cvlist);
                if(!cvlist.isEmpty()){
                    insert cvlist;
                    
                    List<ContentDocumentLink> links = new List<ContentDocumentLink>();            
                    for (ContentVersion cv : [Select Id,ContentDocumentId from ContentVersion where Id =: cvlist]) {
                        links.add(new ContentDocumentLink(
                            ContentDocumentId = cv.ContentDocumentId, 
                            LinkedEntityId = brokerId,  
                            ShareType = 'V',     
                            Visibility = 'AllUsers'
                        ));
                    }            
                    insert links;
                }
                
                
                sendSuccessResponse(201, 'Case created successfully: ' + newCase.Id);
            }
            catch (Exception ex) {
                sendErrorResponse(500, 'Unexpected error: ' + ex.getMessage());
            }
        
    }

    private static Case createNewCaseRecord(String brokerId,CaseRequest input) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Channel_Partner_Portal').getRecordTypeId();

        Case newCase = new Case();
        newCase.Subject = 'Customer Portal Case';
        newCase.Description = input.description;
        newCase.Case_Category__c = input.category;
        newCase.Case_Sub_Category__c = input.sub_category;
        newCase.RecordTypeId = recordTypeId;
        newCase.Origin = 'Channel Partner Portal';
        
        try {
            Broker__c broker = [SELECT Id,
                                (SELECT Id,
                                 (SELECT Id FROM Contacts LIMIT 1)
                                 FROM Accounts__r LIMIT 1)
                                FROM Broker__c WHERE Id =: brokerId LIMIT 1];
            
            if (broker.Accounts__r != null && !broker.Accounts__r.isEmpty()) {
                Account acc = broker.Accounts__r[0];
                newCase.AccountId = acc.Id;
                
                if (acc.Contacts != null && !acc.Contacts.isEmpty()) {
                    newCase.ContactId = acc.Contacts[0].Id;
                }
            }
        } catch (Exception ex) {
            System.debug('Broker to Account/Contact tagging failed: ' + ex.getMessage());
        }

        return newCase;
    }

    private static Opportunity getOpportunityWithRelated(String oppId) {
        try {
            return [
                SELECT Id, AccountId, RW_Project__c FROM Opportunity WHERE Id = :oppId LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('Opportunity fetch failed: ' + e.getMessage());
            return null;
        }
    }

    private static void uploadAttachment(String base64File, Id caseId, String fileName) {
        if (String.isBlank(base64File) || caseId == null) return;

        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64File);
            insert cv;

            Id contentDocId = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id
            ].ContentDocumentId;

            insert new ContentDocumentLink(
                LinkedEntityId = caseId,
                ContentDocumentId = contentDocId,
                ShareType = 'V'
            );
        } catch (Exception ex) {
            throw new AuraHandledException('Attachment upload failed: ' + ex.getMessage());
        }
    }

    // Success Response Helper
    private static void sendSuccessResponse(Integer statusCode, String message) {
        RestResponse res = RestContext.response;
        res.statusCode = statusCode;
        CaseResponse response = new CaseResponse();
        response.isSuccess = true;
        response.success_message = message;
        response.error_message = null;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // Error Response Helper
    private static void sendErrorResponse(Integer statusCode, String message) {
        RestResponse res = RestContext.response;
        res.statusCode = statusCode;
        CaseResponse response = new CaseResponse();
        response.isSuccess = false;
        response.success_message = null;
        response.error_message = message;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // Request Wrapper
    global class CaseRequest {
        //public String opportunityId;
        public String category;
        public String sub_category;
        public String description;
        public list<Documents> documents;
    }
    
    public class Documents {
        public string fileName;
        public string fileType;
        public string attachment;
    } 

    // Response Wrapper
    global class CaseResponse {
        public Boolean isSuccess;
        public String success_message;
        public String error_message;
    }
}