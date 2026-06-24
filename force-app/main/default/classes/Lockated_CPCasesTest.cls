@IsTest
public class Lockated_CPCasesTest {

    // Helper to create Opportunity with Broker relationship
    public static Opportunity createTestOpportunity(String brokerId) {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

       Opportunity opp = new Opportunity(
        Name = 'Test Opp',
        StageName = 'Prospecting',
        CloseDate = System.today().addDays(30),
        LeadSource = 'Channel Partner', // bypass first rule
        RW_Broker__c = brokerId         // bypass this new rule
    );
        insert opp;

        // Simulate broker relationship via custom field
        opp.put('RW_Broker__c', brokerId);
        update opp;
        return opp;
    }

    // Helper to create Broker
    public static Broker__c createTestBroker() {
        Broker__c broker = new Broker__c(Name = 'Test Broker');
        insert broker;

        Account acc = new Account(Name = 'Broker Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;

        // Simulate Account relationship for Broker
        // Assuming Broker has child relationship Accounts__r
        // Insert relationship if needed in real org, else mock with Account only.
        return broker;
    }

    @IsTest
    static void testDoGet_NoCasesFound() {
        Broker__c broker = createTestBroker();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase?brokerId=' + broker.Id;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doGet();
        Test.stopTest();

    }

    @IsTest
    static void testDoGet_WithCases() {
        Broker__c broker = createTestBroker();
        Opportunity opp = createTestOpportunity(broker.Id);
        // Query for the Record Type ID using the DeveloperName
        Id portalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                          .get('Channel_Partner_Portal').getRecordTypeId();

        Case c = new Case(
            Subject = 'Test Case',
            Status = 'Open',
            Origin = 'Channel Partner Portal',
            Opportunity__c = opp.Id,
            RecordTypeId = portalRecordTypeId
        );
        insert c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
           req.requestUri = '/services/apexrest/cpCase';
            req.httpMethod = 'GET';
            req.params.put('brokerId', broker.Id);

        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doGet();
        Test.stopTest();

    }
    
    @IsTest
    static void testDoGet_WithCasesAndFiles() {
        // 1. Setup Data
        Broker__c broker = createTestBroker();
        // Assuming createTestOpportunity sets RW_Broker__c = broker.Id
        Opportunity opp = createTestOpportunity(broker.Id);
    
        Id portalRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                                  .get('Channel_Partner_Portal').getRecordTypeId();
    
        Case c = new Case(
            Subject = 'Test Case with File',
            Status = 'Open',
            Origin = 'Channel Partner Portal',
            Opportunity__c = opp.Id,
            RecordTypeId = portalRecordTypeId
        );
        insert c;
    
        // 2. Create a File (ContentVersion)
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
    
        // Get the ContentDocumentId that was automatically created
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
    
        // 3. Link the File to the Case (ContentDocumentLink)
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = c.Id,
            ContentDocumentId = conDocId,
            ShareType = 'V' // V = Viewer permission
        );
        insert cdl;
    
        // 4. Setup RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'GET';
        req.params.put('brokerId', broker.Id);
    
        RestContext.request = req;
        RestContext.response = res;
    
        // 5. Execute
        Test.startTest();
        Lockated_CPCases.doGet();
        Test.stopTest();
    
        // 6. Assertions
        Assert.areEqual(200, res.statusCode, 'Status code should be 200');
        String responseBody = res.responseBody.toString();
        Assert.isTrue(responseBody.contains('Test Document.pdf'), 'Response should contain the file name');
    }

    @IsTest
    static void testDoPost_CreateCase_Success() {
        Broker__c broker = createTestBroker();
        Opportunity opp = createTestOpportunity(broker.Id);

        Lockated_CPCases.CaseRequest caseReq = new Lockated_CPCases.CaseRequest();
        //caseReq.brokerId = broker.Id;
        //caseReq.opportunityId = opp.Id;
        caseReq.category = 'Category A';
        caseReq.sub_category = 'Sub Cat A';
        caseReq.description = 'Test description';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doPost();
        Test.stopTest();

    }
    
    @IsTest
    static void testDoPost_CreateCase_Success1() {
        Broker__c broker = createTestBroker();
        Opportunity opp = createTestOpportunity(broker.Id);

        Lockated_CPCases.CaseRequest caseReq = new Lockated_CPCases.CaseRequest();
        //caseReq.brokerId = broker.Id;
        //caseReq.opportunityId = opp.Id;
        caseReq.category = 'Category A';
        caseReq.sub_category = 'Sub Cat A';
        caseReq.description = 'Test description';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'POST';
        req.params.put('brokerId', broker.Id);
        req.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doPost();
        Test.stopTest();

    }
    
    @IsTest
    static void testDoPost_CreateCase_Success2() {
        Broker__c broker = createTestBroker();
        Opportunity opp = createTestOpportunity(broker.Id);

        Lockated_CPCases.CaseRequest caseReq = new Lockated_CPCases.CaseRequest();
        //caseReq.brokerId = broker.Id;
        //caseReq.opportunityId = opp.Id;
        caseReq.category = 'Category A';
        caseReq.sub_category = 'Sub Cat A';
        caseReq.description = 'Test description';
        String caseReq2 = '{"category": "Registration","sub_category": "Vendor Code","description": "Need clarification on loan interest","attachment": [{"fileName": "Doc 1","fileType": "pdf",    "attachment": "JVBERi0xLjQKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nCi9QYWdlcyAyIDAgUgo+PgplbmRvYmoK MiAwIG9iago8PC9UeXBlIC9QYWdlcwovS2lkcyBbMyAwIFJdCi9Db3VudCAxCj4+CmVuZG9iagoz IDAgb2JqCjw8L1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovTWVkaWFCb3ggWzAgMCA1OTUgODQy XQovQ29udGVudHMgNSAwIFIKL1Jlc291cmNlcyA8PC9Qcm9jU2V0IFsvUERGIC9UZXh0XQovRm9u dCA8PC9GMSA0IDAgUj4+Cj4+Cj4+CmVuZG9iago0IDAgb2JqCjw8L1R5cGUgL0ZvbnQKL1N1YnR5 cGUgL1R5cGUxCi9OYW1lIC9GMQovQmFzZUZvbnQgL0hlbHZldGljYQovRW5jb2RpbmcgL01hY1Jv bWFuRW5jb2RpbmcKPj4KZW5kb2JqCjUgMCBvYmoKPDwvTGVuZ3RoIDUzCj4+CnN0cmVhbQpCVAov RjEgMjAgVGYKMjIwIDQwMCBUZAooRHVtbXkgUERGKSBUagpFVAplbmRzdHJlYW0KZW5kb2JqCnhy ZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZgowMDAwMDAwMDA5IDAwMDAwIG4KMDAwMDAwMDA2MyAw MDAwMCBuCjAwMDAwMDAxMjQgMDAwMDAgbgowMDAwMDAwMjc3IDAwMDAwIG4KMDAwMDAwMDM5MiAw MDAwMCBuCnRyYWlsZXIKPDwvU2l6ZSA2Ci9Sb290IDEgMCBSCj4+CnN0YXJ0eHJlZgo0OTUKJSVF T0YK"},{"fileName": "Doc 2","fileType": "pdf",    "attachment": "JVBERi0xLjQKMSAwIG9iago8PC9UeXBlIC9DYXRhbG9nCi9QYWdlcyAyIDAgUgo+PgplbmRvYmoK MiAwIG9iago8PC9UeXBlIC9QYWdlcwovS2lkcyBbMyAwIFJdCi9Db3VudCAxCj4+CmVuZG9iagoz IDAgb2JqCjw8L1R5cGUgL1BhZ2UKL1BhcmVudCAyIDAgUgovTWVkaWFCb3ggWzAgMCA1OTUgODQy XQovQ29udGVudHMgNSAwIFIKL1Jlc291cmNlcyA8PC9Qcm9jU2V0IFsvUERGIC9UZXh0XQovRm9u dCA8PC9GMSA0IDAgUj4+Cj4+Cj4+CmVuZG9iago0IDAgb2JqCjw8L1R5cGUgL0ZvbnQKL1N1YnR5 cGUgL1R5cGUxCi9OYW1lIC9GMQovQmFzZUZvbnQgL0hlbHZldGljYQovRW5jb2RpbmcgL01hY1Jv bWFuRW5jb2RpbmcKPj4KZW5kb2JqCjUgMCBvYmoKPDwvTGVuZ3RoIDUzCj4+CnN0cmVhbQpCVAov RjEgMjAgVGYKMjIwIDQwMCBUZAooRHVtbXkgUERGKSBUagpFVAplbmRzdHJlYW0KZW5kb2JqCnhy ZWYKMCA2CjAwMDAwMDAwMDAgNjU1MzUgZgowMDAwMDAwMDA5IDAwMDAwIG4KMDAwMDAwMDA2MyAw MDAwMCBuCjAwMDAwMDAxMjQgMDAwMDAgbgowMDAwMDAwMjc3IDAwMDAwIG4KMDAwMDAwMDM5MiAw MDAwMCBuCnRyYWlsZXIKPDwvU2l6ZSA2Ci9Sb290IDEgMCBSCj4+CnN0YXJ0eHJlZgo0OTUKJSVF T0YK" }]}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'POST';
        req.params.put('brokerId', broker.Id);
        req.requestBody = Blob.valueOf(caseReq2);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testDoPost_MissingRequiredFields() {
        Lockated_CPCases.CaseRequest caseReq = new Lockated_CPCases.CaseRequest();
        // All fields blank

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doPost();
        Test.stopTest();

    }

    @IsTest
    static void testDoPost_InvalidOpportunity() {
        Broker__c broker = createTestBroker();

        Lockated_CPCases.CaseRequest caseReq = new Lockated_CPCases.CaseRequest();
        //caseReq.brokerId = broker.Id;
        //caseReq.opportunityId = '006000000000000AAA'; // Non-existing Opp Id
        caseReq.category = 'Category A';
        caseReq.sub_category = 'Sub Cat A';
        caseReq.description = 'Invalid Opp ID test';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/cpCase';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        Lockated_CPCases.doPost();
        Test.stopTest();

    }
    @IsTest
    static void testUploadAttachment() {
        // Create Case
        Case testCase = new Case(
            Subject = 'Test Case for Attachment',
            Status = 'Open',
            Origin = 'Channel Partner Portal'
        );
        insert testCase;
    
        // Small base64 file
        String fileContent = 'Hello World';
        String base64File = EncodingUtil.base64Encode(Blob.valueOf(fileContent));
    
        Test.startTest();
        Lockated_CPCases.uploadAttachment(base64File, testCase.Id, 'TestFile.txt');
        Test.stopTest();
    }


}