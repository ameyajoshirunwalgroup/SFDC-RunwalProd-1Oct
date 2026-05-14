@IsTest
public class EmailMessageTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        // Create test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create test Contact
        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@example.com', AccountId = acc.Id);
        insert con;
        
        Project__c proj = new Project__c(Name='Runwal Bliss');
        insert proj;

        // Create a closed Case (parent)
        Case closedCase = new Case(
            Subject = 'Closed Case',
            Status = 'Open',
            AccountId = acc.Id,
            ContactId = con.Id,
            RW_Project__c = proj.Id, // simulate closed 15 days ago
            locobuzz__Locobuzz_ID__c = null
        );
        insert closedCase;

    }

    @IsTest
    static void testEmailMessageTriggerHandler_FollowUpCreation() {
        // Fetch parent cases
        Case closedCase = [SELECT Id, Status, Last_Closed_Date__c,Subject,AccountId,ContactId,RW_Project__c,locobuzz__Locobuzz_ID__c,RW_Case_Type__c,Remarks_by_RM__c,
                           Customer_Lifecycle_Touchpoint__c, RW_Complaint_Type__c, RW_Complaint_SubType__c
                           FROM Case WHERE Subject = 'Closed Case' LIMIT 1];
        closedCase.Status = 'Case Closed';
        closedCase.RW_RM_Remarks__c = 'Closed Satisfactory';
        closedCase.Remarks_by_RM__c = 'Closed Satisfactory';
        closedCase.Last_Closed_Date__c = Date.today().addDays(-15);
        closedCase.RW_Case_Type__c = 'Complaint';
        closedCase.Customer_Lifecycle_Touchpoint__c = 'Cancellation Related';
        closedCase.RW_Complaint_Type__c = 'Cancellation Related';
        closedCase.RW_Complaint_SubType__c = 'Delay in processing refund';
        update closedCase;
        
        System.debug('Case Id From Test Class--->'+closedCase.Id);
        
        EmailMessage mockEmail = new EmailMessage(
            Id = '02s000000000001', // fake Id ok in tests
            Subject = 'Follow-up needed',
            FromAddress = 'customer@example.com',
            ToAddress = 'support@example.com',
            Incoming = true,
            ParentId = closedCase.Id,
            Status = '3',
            MessageDate = System.now(),
            TextBody = 'Reopening issue'
        );
        Test.startTest();
        EmailMessageTriggerHandler.handleAfterInsert(new List<EmailMessage>{ mockEmail });
        Test.stopTest();
        
        EmailMessageTriggerHandler.dummyMethod();
        
        // Create incoming email messages
        List<EmailMessage> emails = new List<EmailMessage>{
            new EmailMessage(
                Subject = 'Follow-up needed',
                FromAddress = 'customer@example.com',
                ToAddress = 'support@example.com',
                Incoming = true,
                ParentId = closedCase.Id,
                RelatedToId = closedCase.Id,
                Status = '3',
                MessageDate = System.now(),
                TextBody = 'Reopening issue'
            )
        };
        insert emails;
        
        

        
    }
}