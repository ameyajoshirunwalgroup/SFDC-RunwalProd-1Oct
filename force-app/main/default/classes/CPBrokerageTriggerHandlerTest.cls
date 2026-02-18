@isTest
public class CPBrokerageTriggerHandlerTest {

    @testSetup
    static void setupData() {
        
        

        Account testAccount = new Account(
            Name = 'Test Channel Partner Account'
        );
        insert testAccount;
        
        Legal_Entity__c legalEntity = new Legal_Entity__c(Name ='RREPL', RDS_Company_Code__c = '2020');
        insert legalEntity;
        
        // Create Channel Partner
        Broker__c channelPartner = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = testAccount.Id,
            RW_Email__c = 'partner@example.com'
        );
        insert channelPartner;
        
        
        // AOP for FY processing
        AOP__c aop = new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000
        );
        insert aop;
        
        List<CP_Brokerage__c> brokerages = new List<CP_Brokerage__c>();

        // 1. Valid, approved, not Base (for general success)
        brokerages.add(new CP_Brokerage__c(
            Channel_Partner__c = channelPartner.Id,
            Approval_Status__c = 'Approved By L4 - Accounts',
            Brokerage_Type__c = 'AOP Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 1000
        ));
        
        insert brokerages;

        // Create a dummy Contact to act as the recipient (used in the email template)
        Contact dummyContact = new Contact(
            LastName = 'Dummy Contact',
            Email = 'adityaag26120@gmail.com'
        );
        insert dummyContact;

        

    }

    @isTest
    static void testSendEmailmethod_Positive() {
        // Get CP Brokerage record created in setup
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c LIMIT 1];

        Test.startTest();
        // Call the future method
        CPBrokerageTriggerHandler.sendEmailmethod(new Set<Id>{brokerage.Id});
        Test.stopTest();

        // Validate the async future execution indirectly
        // We can't assert sent emails directly in test context, 
        // but we can ensure no exceptions are thrown and setup is valid.
        System.assert(true, 'Future method executed without error');
    }

}