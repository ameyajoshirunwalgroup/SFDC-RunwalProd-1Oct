@isTest
public class CPBrokerageInvoiceControllerTest {
    @isTest
    public static void getCpBrokeragesTest(){
        try{
        List<CP_Brokerage__c> getCpBrokeragesObj = CPBrokerageInvoiceController.getCpBrokerages('test','Test','Test','Test');
        }catch(Exception ex){
            
        }
        try{
        Boolean checkBoolean = CPBrokerageInvoiceController.CheckForGSTNo('a0Q9I00000HChdYUAT');
        }catch(Exception ex){
            
        }
        // Get a valid User ID for all the approver lookup fields
        Id runningUserId = UserInfo.getUserId();

        // Create Channel Partner (assuming it's an Account)
        Account cp = new Account(Name='Test Channel Partner');
        insert cp;
        
        Broker__c channelPartner = new Broker__c(
            Name = 'Test Channel Partner',
            SAP_CP_Code__c='0006002521',
            Account__c = cp.Id
        );
        insert channelPartner;
        
        AOP__c aopObj = new AOP__c(
          //  Name = 'AOP FY 2024-25',
            Channel_Partner__c = channelPartner.Id,
            Start_Date__c = Date.newInstance(2024, 4, 1),
            End_Date__c = Date.newInstance(2025, 3, 31),
            Commitment_max__c = 50000000
        );

        // Create Legal Entity
        Legal_Entity__c le = new Legal_Entity__c(
            Name='Test Legal Entity', 
            RDS_Company_Name__c='Test LE Company'
        );
        insert le;
        
        Project__c newProj = new Project__c(
            Name = 'Runwal Bliss'
        );
        insert newProj;

        // Create Tower (linked to Legal Entity)
        Tower__c tower = new Tower__c(
            Name='Test Tower', 
            Legal_Entity__c = le.Id,
			ProjectName__c = newProj.Id
        );
        insert tower;

        // Create Booking (linked to Tower)
        Booking__c booking = new Booking__c(
            Tower__c = tower.Id
        );
        insert booking;

        // Create Brokerage Summary
        Brokerage_Summary__c summary = new Brokerage_Summary__c(
            AOP__c = aopObj.Id
        );
        insert summary;

        // Create Brokerage Lookups to test the two 'type' scenarios
        Brokerage__c bl_aop = new Brokerage__c(
            Name = 'AOP Brokerage', 
            Brokerage_Type__c = 'AOP Brokerage',
            Brokerage_Summary__c = summary.Id
        );
        Brokerage__c bl_other = new Brokerage__c(
            Name = 'Other Brokerage', 
            Brokerage_Type__c = 'AOP Brokerage',
            Brokerage_Summary__c = summary.Id
        );
        insert new List<Brokerage__c>{bl_aop, bl_other};
        
        // Create 3 Invoices
        List<Brokerage_Invoice__c> invoicesToCreate = new List<Brokerage_Invoice__c>();

        // Invoice 1 & 2: Should be grouped together (AOP)
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_aop.Id,
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 1000,
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));
        
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_aop.Id, // Same lookup
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 2000, // Different amount
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));

        // Invoice 3: Should be in its own group (Other)
        invoicesToCreate.add(new Brokerage_Invoice__c(
            Channel_Partner__c = channelPartner.Id,
            Booking__c = booking.Id,
            Brokerage_Lookup__c = bl_other.Id, // Different lookup
            Brokerage_Summary__c = summary.Id,
            Brokerage_In_Rs__c = 500,
            CP_Invoice_Approver_L1__c = runningUserId,
            CP_Invoice_Approver_L2__c = runningUserId,
            CP_Invoice_Approver_L3__c = runningUserId,
            CP_Invoice_Approver_L4__c = runningUserId,
            CP_Invoice_Approver_L5__c = runningUserId,
            CP_Invoice_Clearing_L1__c = runningUserId,
            CP_Invoice_Clearing_L2__c = runningUserId
        ));
        
        insert invoicesToCreate;
        try{
            Boolean checkBoolean = CPBrokerageInvoiceController.CheckForGSTNo(invoicesToCreate[0].id);
        }catch(Exception ex){
            
        }
        
        CP_Brokerage__c cpBrokerage = new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L1 - Site Heads',
            Brokerage_Type__c = 'AOP Brokerage',
            SAP_Document_No__c = 'SAP-123490',
            Total_Brokerage__c = 4000
        );
        insert cpBrokerage;
        try{
            Boolean checkBoolean = CPBrokerageInvoiceController.CheckForGSTNo(cpBrokerage.id);
        }catch(Exception ex){
            
        }
    }
}