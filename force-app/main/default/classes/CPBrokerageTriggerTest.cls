@isTest
public class CPBrokerageTriggerTest {
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
            Approval_Status__c = 'Approved By L4 - Accounts',
            Brokerage_Type__c = 'AOP Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 1000
        ));

        // 2. Approved, Base Brokerage, no AOP (for validation failure)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L4 - Accounts',
            Brokerage_Type__c = 'Base Brokerage',
            AOP__c = null,
            Total_Brokerage__c = 2000
        ));

        // 3. Approved, Base Brokerage, with AOP (for validation success)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L4 - Accounts',
            Brokerage_Type__c = 'Base Brokerage',
            AOP__c = aop.id,
            Total_Brokerage__c = 3000
        ));
        
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L4 - Accounts',
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
            Total_Brokerage__c = 4000,
            Invoice_Number__c = '8893'
        ));

        // 5. Already processed (for warning message)
        brokerages.add(new CP_Brokerage__c(
            Approval_Status__c = 'Approved By L4 - Accounts',
            Brokerage_Type__c = 'AOP Brokerage',
            SAP_Document_No__c = 'SAP-12345',
            Total_Brokerage__c = 5000,
            Invoice_Number__c = '8642'
        ));

        insert brokerages;
        
    }
    @isTest
    public Static void testMethodForCPBrok(){
        List<CP_Brokerage__c> cpBrok = [Select id,Invoice_Number__c from CP_Brokerage__c where Invoice_Number__c = null];
        cpBrok[0].Invoice_Number__c ='65768';
        update cpBrok[0];
        List<CP_Brokerage__c> cpBrokInvoice = [Select id,Invoice_Number__c from CP_Brokerage__c where Invoice_Number__c != null];
        cpBrokInvoice[0].Invoice_Number__c ='65768';
        update cpBrokInvoice[0];
        try{
        List<CP_Brokerage__c> cpBrokInvoicedup = [Select id,Invoice_Number__c from CP_Brokerage__c where Invoice_Number__c = '8893'];
        cpBrokInvoicedup[0].Invoice_Number__c ='8642';
        update cpBrokInvoicedup[0];
        }catch(Exception ex){
            
        }
        
    }
}