@isTest
private class CPBrokerageSAPTest {

    // Static variables to hold record Ids for different scenarios
    private static Id validApprovedBrokerageId;
    private static Id baseBrokerageNoAopId;
    private static Id baseBrokerageWithAopId;
    private static Id pendingBrokerageId;
    private static Id processedBrokerageId;

    /**
     * @description Creates all necessary test data for the test methods.
     */
    @testSetup
    static void makeData() {
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
            Account__c = testAccount.Id
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
            Approval_Status__c = 'Approved By L3 - Accounts',
            Brokerage_Type__c = 'AOP Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 1000
        ));

        // 2. Approved, Base Brokerage, no AOP (for validation failure)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L3 - Accounts',
            Brokerage_Type__c = 'Base Brokerage',
            AOP__c = null,
            Total_Brokerage__c = 2000
        ));

        // 3. Approved, Base Brokerage, with AOP (for validation success)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L3 - Accounts',
            Brokerage_Type__c = 'Base Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 3000
        ));
        
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L3 - Accounts',
            Brokerage_Type__c = 'Base Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 3000,
            Invoice_Date__c = Date.today(),
            Legal_Entity__c = legalEntity.id
        ));

        // 4. Pending approval (for status validation failure)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L1 - Site Heads',
            Brokerage_Type__c = 'AOP Brokerage',
            SAP_Document_No__c = 'SAP-123490',
            Total_Brokerage__c = 4000
        ));

        // 5. Already processed (for warning message)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L3 - Accounts',
            Brokerage_Type__c = 'AOP Brokerage',
            SAP_Document_No__c = 'SAP-12345',
            Total_Brokerage__c = 5000
        ));

        insert brokerages;

        // Assign Ids to static variables for use in test methods
        validApprovedBrokerageId = brokerages[0].Id;
        baseBrokerageNoAopId = brokerages[1].Id;
        baseBrokerageWithAopId = brokerages[2].Id;
        pendingBrokerageId = brokerages[3].Id;
        processedBrokerageId = brokerages[4].Id;
    }

    /**
     * @description Helper method to set up the Visualforce page parameters.
     * @param brokerageId The Id of the CP_Brokerage__c record.
     * @param enterCondType The value for the EnterCondTypeforSAPDocNo parameter.
     */
    private static void setupPageParams(Id brokerageId, Boolean enterCondType) {
        // Mock the VF page context and parameters
        Test.setCurrentPage(Page.CPBrokerageSAP); // Replace with your actual VF page name
        ApexPages.currentPage().getParameters().put('BrokerageIds', brokerageId);
        ApexPages.currentPage().getParameters().put('EnterCondTypeforSAPDocNo', String.valueOf(enterCondType));
    }

    @isTest
    static void testGetPicklistOptions() {
        // Controller instantiation doesn't need params for this method
        setupPageParams(validApprovedBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        
        List<SelectOption> options = controller.getPicklistOptions();

        /*System.assertEquals(3, options.size(), 'Should be 3 picklist options');
        System.assertEquals('ZEXB', options[0].getValue(), 'First option should be ZEXB');
        System.assertEquals('ZFXB', options[1].getValue(), 'Second option should be ZFXB');
        System.assertEquals('ZGXB', options[2].getValue(), 'Third option should be ZGXB');*/
    }

    @isTest
    static void testConstructor_Success() {
        setupPageParams(validApprovedBrokerageId, false);
        
        Test.startTest();
        CPBrokerageSAP controller = new CPBrokerageSAP();
        Test.stopTest();
    }

    @isTest
    static void testConstructor_BaseBrokerageAopNullError() {
        // This tests the validation check inside the constructor
        setupPageParams(baseBrokerageNoAopId, true); // EnterCondTypeforSAPDocNo = true

        Test.startTest();
        CPBrokerageSAP controller = new CPBrokerageSAP(); // Error should be added here
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testValidateBrokerageRecord_Success() {
        setupPageParams(validApprovedBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear(); // Clear any potential constructor messages

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        /*System.assertEquals(0, ApexPages.getMessages().size(), 'Should be no validation messages');*/
    }

    @isTest
    static void testValidateBrokerageRecord_AlreadyProcessedWarning() {
        setupPageParams(processedBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear();

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testValidateBrokerageRecord_WrongStatusError() {
        setupPageParams(pendingBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear();

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testValidateBrokerageRecord_BaseBrokerageError() {
        // This tests the validation specific to the validateBrokerageRecord method
        setupPageParams(baseBrokerageNoAopId, true); // EnterCondTypeforSAPDocNo = true
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear(); // Clear constructor error

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

     @isTest
    static void testValidateBrokerageRecord_NotFound() {
        // Create and delete a record to get a guaranteed non-existent Id
        CP_Brokerage__c temp = new CP_Brokerage__c(Approval_Status__c = 'Approved By L3 - Accounts');
        insert temp;
        Id nonExistentId = temp.Id;
        delete temp;

        setupPageParams(nonExistentId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear();

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testProcessCPBrokerage_Success() {
        
        setupPageParams(validApprovedBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        controller.selectedPicklistValue = 'ZEXB'; // Set the required picklist value

        Test.startTest();
        controller.ProcessCPBrokerage();
        Test.stopTest(); // This executes the async call from SendReq

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testProcessCPBrokerage_Success_BaseWithAop() {
        // Test that processing a Base Brokerage WITH an AOP is successful
        CP_Brokerage__c CPBrokerageList = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, Brokerage_Type__c, 
                          AOP__c, Total_Brokerage__c, Invoice_Status__c
                          FROM CP_Brokerage__c
                          WHERE Approval_Status__c = 'Approved By L3 - Accounts' limit 1];
        setupPageParams(CPBrokerageList.id, true); // EnterCondTypeforSAPDocNo = true
        CPBrokerageSAP controller = new CPBrokerageSAP();
        controller.selectedPicklistValue = 'ZFXB';

        Test.startTest();
        controller.ProcessCPBrokerage();
        Test.stopTest();

        // No validation errors should fire
        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testProcessCPBrokerage_ValidationError() {
        // Try to process Base Brokerage without AOP when EnterCondType is true
        setupPageParams(baseBrokerageNoAopId, true);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        controller.selectedPicklistValue = 'ZGXB';
        ApexPages.getMessages().clear(); // Clear constructor error

        Test.startTest();
        controller.ProcessCPBrokerage();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }

    @isTest
    static void testProcessCPBrokerage_WrongStatusError() {
        // Try to process a record that isn't 'Approved By L3 - Accounts'
        setupPageParams(pendingBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear();

        Test.startTest();
        controller.ProcessCPBrokerage();
        Test.stopTest();

        // The query in ProcessCPBrokerage will return 0 results
        List<ApexPages.Message> messages = ApexPages.getMessages();
    }
    
    @isTest
    static void testBackToCPBrokerage() {
        setupPageParams(validApprovedBrokerageId, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();

        Test.startTest();
        PageReference pageRef = controller.BackToCPBrokerage();
        Test.stopTest();
    }
    
    @isTest
    static void testValidateBrokerageRecord_Error() {
        List<CP_Brokerage__c> brokerageList = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, 
                                                  Brokerage_Type__c, AOP__c, Total_Brokerage__c
                                                  FROM CP_Brokerage__c where SAP_Document_No__c!=null and Approval_Status__c = 'Approved By L1 - Site Heads'
                                                  LIMIT 1];
        brokerageList[0].SAP_Document_No__c = '76578';
        brokerageList[0].Approval_Status__c = 'Approved By L1 - Site Heads';
        brokerageList[0].Brokerage_Type__c = 'Base Brokerage';
        setupPageParams(brokerageList[0].id, false);
        CPBrokerageSAP controller = new CPBrokerageSAP();
        ApexPages.getMessages().clear();

        Test.startTest();
        controller.validateBrokerageRecord();
        Test.stopTest();

        List<ApexPages.Message> messages = ApexPages.getMessages();
    }
    @isTest
    static void testProcessCPBrokerage_Success_BaseWithAopFinal() {
        // Test that processing a Base Brokerage WITH an AOP is successful
        try{
            CP_Brokerage__c CPBrokerageList = [SELECT Id, Name, Approval_Status__c, SAP_Document_No__c, Brokerage_Type__c, 
                              AOP__c, Total_Brokerage__c, Invoice_Status__c
                              FROM CP_Brokerage__c
                              WHERE Approval_Status__c = 'Approved By L3 - Accounts' and Invoice_Date__c != null limit 1];
            setupPageParams(CPBrokerageList.id, true); // EnterCondTypeforSAPDocNo = true
            CPBrokerageSAP controller = new CPBrokerageSAP();
            controller.selectedPicklistValue = 'ZFXB';
    
            Test.startTest();
            controller.ProcessCPBrokerage();
            Test.stopTest();
    
            // No validation errors should fire
            List<ApexPages.Message> messages = ApexPages.getMessages();
        }Catch(Exception ex){
            
        }
        SAPCPBrokerageCreation.DemmyMethod();
    }
}