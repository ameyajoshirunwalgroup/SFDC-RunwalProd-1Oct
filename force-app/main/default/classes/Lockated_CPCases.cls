@RestResource(urlMapping='/cpCase/*')
global without sharing class Lockated_CPCases {

    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        res.addHeader('Content-Type', 'application/json');

        FinalResponse finalResponse = new FinalResponse();

        try {
            // Get brokerId parameter
            String brokerId = req.params.get('brokerId');
            
            // Validate input
            if (String.isBlank(brokerId)) {
                sendError(res, 400, 'Missing required parameter: brokerId');
                return;
            }
			
            // Fetch related Cases
            List<Case> brokerCases = [SELECT CaseNumber, Subject, Status, Opportunity__r.Name,Case_Category__c, Case_Sub_Category__c, CreatedDate, Description, RW_RM_Remarks__c
                                      FROM Case
                                      WHERE Opportunity__r.RW_Broker__c = :brokerId and RecordType.DeveloperName = 'Channel_Partner_Portal'
                                      ORDER BY CreatedDate DESC];

            if (brokerCases.isEmpty()) {
                sendError(res, 404, 'No cases found for the provided brokerId.');
                
                return;
            }
            
            // 1. Get all Case IDs (Added by Aditya)
            Set<Id> caseIds = new Map<Id, Case>(brokerCases).keySet();
            Map<Id, List<Documents>> caseIdToAttachmentsMap = new Map<Id, List<Documents>>();
    
            // 2. Query ContentDocumentLink to find files linked to these Cases
            // We filter by LinkedEntityId (The Case Id)
            List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId, LinkedEntityId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId IN :caseIds];
            
            Set<Id> contentDocIds = new Set<Id>();
            for(ContentDocumentLink link : docLinks) {
                contentDocIds.add(link.ContentDocumentId);
            }
    
            // 3. Fetch the actual File Data (ContentVersion)
            // Note: We check contentDocIds.isEmpty() to avoid query error if no files exist
            Map<Id, ContentVersion> docIdToVersionMap = new Map<Id, ContentVersion>();
            if(!contentDocIds.isEmpty()) {
                List<ContentVersion> fileVersions = [SELECT ContentDocumentId, Title, VersionData, FileExtension 
                                                     FROM ContentVersion 
                                                     WHERE ContentDocumentId IN :contentDocIds 
                                                     AND IsLatest = true];
                
                for(ContentVersion cv : fileVersions) {
                    docIdToVersionMap.put(cv.ContentDocumentId, cv);
                }
            }
    
            // 4. Map the Files back to the Case IDs
            for(ContentDocumentLink link : docLinks) {
                if(docIdToVersionMap.containsKey(link.ContentDocumentId)) {
                    ContentVersion cv = docIdToVersionMap.get(link.ContentDocumentId);
                    
                    Documents att = new Documents();
                    att.fileName = cv.Title + '.' + cv.FileExtension;
                    // Convert Blob to Base64 String
                    att.attachment = EncodingUtil.base64Encode(cv.VersionData);
    
                    if(!caseIdToAttachmentsMap.containsKey(link.LinkedEntityId)) {
                        caseIdToAttachmentsMap.put(link.LinkedEntityId, new List<Documents>());
                    }
                    caseIdToAttachmentsMap.get(link.LinkedEntityId).add(att);
                }
            }
            // --- END OF NEW LOGIC(Aditya) ---
			
            // Dynamic status mapping
            Map<String, List<CaseResponseDetails>> statusMap = new Map<String, List<CaseResponseDetails>>();
            List<CaseResponseDetails> allCases = new List<CaseResponseDetails>();

            for (Case c : brokerCases) {
                CaseResponseDetails caseRes = new CaseResponseDetails();
                caseRes.caseNumber = c.CaseNumber;
                caseRes.subject = c.Subject;
                caseRes.status = c.Status;
                caseRes.opportunityName = c.Opportunity__r != null ? c.Opportunity__r.Name : null;
                caseRes.caseCategory = c.Case_Category__c;
                caseRes.caseSubCategory = c.Case_Sub_Category__c;
                caseRes.closeRemarks = c.RW_RM_Remarks__c;
                // caseRes.createdDate = c.CreatedDate.date();
                if (c.CreatedDate != null) {
                    caseRes.createdDate = c.CreatedDate.format('dd-MM-yyyy');
                }
                caseRes.description = (c.Description != null && c.Description.length() > 1000)
                    ? c.Description.substring(0, 1000) + '...'
                    : c.Description;
                
                // Assign the attachments found earlier, or an empty list if none
                if (caseIdToAttachmentsMap.containsKey(c.Id)) {
                    caseRes.attachment = caseIdToAttachmentsMap.get(c.Id);
                } else {
                    caseRes.attachment = new List<Documents>();
                }

                allCases.add(caseRes);
                
                if (!statusMap.containsKey(c.Status)) {
                    statusMap.put(c.Status, new List<CaseResponseDetails>());
                }
                statusMap.get(c.Status).add(caseRes);
            }
			
            //statusMap.put('All', allCases);
            List<String> categoryList = new List<String>{'All'};
            for (String key : statusMap.keySet()) {
                if (key != 'All') categoryList.add(key);
            }

            finalResponse.category = categoryList;
            finalResponse.tickets = statusMap;
            
            finalResponse.getCaseType_Subtype = Lockated_CPGetPicklistValues.getDependentPicklist('Case', 'Case_Category__c','Case_Sub_Category__c');

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(finalResponse));
        } catch (Exception e) {
            sendError(res, 500, 'Unexpected error occurred: ' + e.getMessage());
        }
    }

    @HttpPost
    global static void doPost() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
		
        try {
            RestRequest req = RestContext.request;
            
            if (req == null || req.requestBody == null) {
                sendError(res, 400, 'Invalid request. Request body is empty.');
                return;
            }
            String brokerId = req.params.get('brokerId');
            
            // Validate input
            if (String.isBlank(brokerId)) {
                sendError(res, 400, 'Missing required parameter: brokerId');
                return;
            }

            CaseRequest input;
            try {
                System.debug('Case Request---->'+req.requestBody.toString());
                input = (CaseRequest) JSON.deserialize(req.requestBody.toString(), CaseRequest.class);
            } catch (Exception parseEx) {
                sendError(res, 400, 'Invalid JSON format: ' + parseEx.getMessage());
                return;
            }

            // Validate required fields dynamically
            List<String> missingFields = getMissingRequiredFields(input);
            
            if (!missingFields.isEmpty()) {
                sendError(res, 400, 'Missing required field(s): ' + String.join(missingFields, ', '));
                return;
            }

            Case newCase = createNewCaseRecord(input,brokerId);
            list<Opportunity> opplist = [Select Id from Opportunity where StageName = 'Unit Booked' and RW_Broker__c  =: brokerId Order by Createddate desc limit 1];
            if(!opplist.isEmpty()){
                newCase.Opportunity__c = opplist[0].Id;
            }
            try {
                insert newCase;
            } catch (DmlException dmlEx) {
                sendError(res, 500, 'Failed to create Case: ' + dmlEx.getDmlMessage(0));
                return;
            }
			
            //Take the most Recent Opportunity Id - As discussed with Internal Team.
            list<ContentVersion> cvlist = new list<ContentVersion>();
            For(Documents d : input.attachment){
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
                        LinkedEntityId = newCase.Id,  
                        ShareType = 'V',     
                        Visibility = 'AllUsers'
                    ));
                }            
                insert links;
            }

            sendSuccess(res, 201, 'Case created successfully: ' + newCase.Id);
        }
        catch (Exception ex) {
            sendError(res, 500, 'Unexpected error: ' + ex.getMessage());
        }
    }

    //create Case
    public static Case createNewCaseRecord(CaseRequest input,Id brokerId) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Channel_Partner_Portal').getRecordTypeId();

        Case newCase = new Case();
        newCase.Subject = 'Channel Partner Case';
        newCase.Description = input.description;
        newCase.Case_Category__c = input.category;
        newCase.Case_Sub_Category__c = input.sub_category;
        newCase.RecordTypeId = recordTypeId;
        newCase.Origin = 'Channel Partner Portal';
        newCase.Status = 'Open';

        if (String.isNotBlank(brokerId)) {
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
        }

        return newCase;
    }
	
    //get Related Opportunities
    public static Opportunity getOpportunityWithRelated(String oppId) {
        try {
            return [SELECT Id, AccountId, RW_Project__c FROM Opportunity WHERE Id = :oppId LIMIT 1];
        } catch (Exception e) {
            System.debug('Opportunity fetch failed: ' + e.getMessage());
            return null;
        }
    }

    // Upload Attachments
    public static void uploadAttachment(String base64File, Id caseId, String fileName) {
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
    
    //Validate required fields
    public static List<String> getMissingRequiredFields(CaseRequest input) {
        List<String> missing = new List<String>();
        //if (String.isBlank(input.brokerId))       missing.add('brokerId');
        if (String.isBlank(input.category))       missing.add('category');
        if (String.isBlank(input.sub_category))   missing.add('sub_category');
        //if (String.isBlank(input.opportunityId))  missing.add('opportunityId');
        if (String.isBlank(input.description))    missing.add('description');
        return missing;
    }

    // Success Response Helper
    public static void sendSuccess(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        CaseCreateResponse response = new CaseCreateResponse();
        response.isSuccess = true;
        response.success_message = message;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // Error Response Helper
    public static void sendError(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        CaseCreateResponse response = new CaseCreateResponse();
        response.isSuccess = false;
        response.error_message = message;
        response.getCaseType_Subtype = Lockated_CPGetPicklistValues.getDependentPicklist('Case', 'Case_Category__c','Case_Sub_Category__c');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // Wrapper Classes
    global class FinalResponse {
        public List<String> category;
        public Map<String, List<CaseResponseDetails>> tickets;
        public Lockated_CPGetPicklistValues.PicklistWrapper getCaseType_Subtype;
    }
    

    //Wrapper for case data
    global class CaseResponseDetails {
        public String caseNumber;
        public String subject;
        public String status;
        public String opportunityName;
        public String caseCategory;
        public String caseSubCategory;
        public String createdDate;
        public String description;
        public String closeRemarks;
        public list<Documents> attachment;
    }
	
    // Request Wrapper
    global class CaseRequest {
        //public String brokerId;
        //public String opportunityId;
        public String category;
        public String sub_category;
        public String description;
        public list<Documents> attachment;
    }
    
    public class Documents {
        public string fileName;
        public string fileType;
        public string attachment;
    } 

    // Response Wrapper
    global class CaseCreateResponse {
        public Boolean isSuccess;
        public String success_message;
        public String error_message;
        public Lockated_CPGetPicklistValues.PicklistWrapper getCaseType_Subtype;
    }
}