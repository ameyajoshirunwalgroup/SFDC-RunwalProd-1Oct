@IsTest
public class CaseCommentHistoryHandlerTest {
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
            locobuzz__Locobuzz_ID__c = null,
            Description = 'test-new'
        );
        insert closedCase;

    }
    
    @IsTest
    static void testCaseCommentHandler() {
        Case closedCase = [SELECT Id, Status, Last_Closed_Date__c,Subject,AccountId,ContactId,RW_Project__c,locobuzz__Locobuzz_ID__c,RW_Case_Type__c,Remarks_by_RM__c,
                           Customer_Lifecycle_Touchpoint__c, RW_Complaint_Type__c, RW_Complaint_SubType__c, Description, RW_Resolution_comments__c
                           FROM Case WHERE Subject = 'Closed Case' LIMIT 1];
        closedCase.RW_Resolution_comments__c = 'test Again';
        update closedCase;
        
        
    }
}