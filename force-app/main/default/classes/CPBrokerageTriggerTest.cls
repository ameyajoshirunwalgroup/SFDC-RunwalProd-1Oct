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
            Account__c = testAccount.Id,
            RW_Email__c = 'test7489349@gmail.com'
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
        
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 10';
        insert bs;
        
        Brokerage__c bro = new Brokerage__c();
        bro.Name = 'Base Brokerage';
        bro.Brokerage__c = 2;
        bro.Brokerage_Amount__c = 272059;
        bro.Brokerage_Summary__c = bs.Id;
        bro.Opportunity_AV__c = 13602975;
        bro.Brokerage_Type__c = 'Base Brokerage';
        insert bro;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Invoice_Number__c = '';
        bi.If_GST_is_applicable__c = '';
        bi.Brokerage_Lookup__c = bro.id;
        bi.Total_Agreement_Value__c = null;
        bi.Invoice_Status__c = 'Not Submitted';
        bi.Invoice_Date__c = system.today();
        bi.Brokerage_In_Rs__c = 53633;
        bi.Invoice_Date__c = system.today();
        bi.IGST__c = '';
        bi.CGST__c = '';
        bi.SGST__c = '';
        bi.Invoice_Amount__c = null;
        bi.Approval_Status__c = 'Approved By L3 - Accounts';
        insert bi;
        
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
            Channel_Partner__c = channelPartner.Id,
            AOP__c = aop.id,
            Total_Brokerage__c = 3000,
            Invoice_Date__c = Date.today(),
            Legal_Entity__c = legalEntity.id,
            Invoice_Number__c = '8282'
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
        
        List<CP_Brokerage__c> cpBrok = [SELECT Id, Total_Brokerage__c, SAP_TDS__c,
               (SELECT Id, Brokerage_In_Rs__c FROM Brokerage_Invoices__r)
        FROM CP_Brokerage__c
        WHERE Invoice_Number__c = '8282'
        LIMIT 1];
        bi.CP_Brokerage__c = cpBrok[0].Id;
        update bi;
        
        String email = label.EmailForChannelPartner;
        
        Contact dummyContact = new Contact(
            LastName = 'Dummy Contact',
            Email = email
        );
        insert dummyContact;
        
        
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
        CP_Brokerage__c brokerage = [SELECT Id FROM CP_Brokerage__c where Invoice_Number__c = '8282' LIMIT 1];
        Test.startTest();
        CPBrokerageTriggerHandler.sendEmailmethod(new Set<Id>{brokerage.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testMethodForCPBrok2() {
        
        // 1️⃣ Get parent WITHOUT child (safe)
        CP_Brokerage__c cp = [
            SELECT Id, Total_Brokerage__c
            FROM CP_Brokerage__c
            WHERE Invoice_Number__c = '8282'
            LIMIT 1
        ];
        
        // 2️⃣ Update SAP TDS
        cp.SAP_TDS__c = 2777;
        update cp;
        
    }

}