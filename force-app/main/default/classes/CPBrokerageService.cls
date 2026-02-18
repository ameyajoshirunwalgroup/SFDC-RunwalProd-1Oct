public with sharing class CPBrokerageService {
    
    // Wrapper for Flow input
    public class InvoiceInput {
        @InvocableVariable(required=true)
        public Id invoiceId;
    }

    @InvocableMethod(label='Create CP Brokerage from Invoices' description='Groups invoices and creates CP_Brokerage records')
    public static void createFromFlow(List<InvoiceInput> request) {
        Set<Id> invoiceIds = new Set<Id>();
        for (InvoiceInput input : request) {
            if (input.invoiceId != null) {
                invoiceIds.add(input.invoiceId);
            }
        }
        if (!invoiceIds.isEmpty()) {
            createCPBrokerageFromInvoices(invoiceIds);
        }
    }
    
    // 🔑 Utility method to generate consistent grouping key
    private static String makeKey(Id cpId, String legalEntityId, String type) {
        return String.valueOf(cpId) + '-' + String.valueOf(legalEntityId) + '-' + String.valueOf(type);
    }
    
    // Core logic
    public static void createCPBrokerageFromInvoices(Set<Id> invoiceIds) {
        // Step 1: Fetch invoices
        List<Brokerage_Invoice__c> invoices = [
            SELECT Id, Channel_Partner__c, Legal_Entity__c,
                   Brokerage_In_Rs__c, Brokerage_Amt_Post_TDS__c,
                   Brokerage_Lookup__r.Name, Brokerage_Lookup__r.Brokerage_Type__c,
                   Booking__r.Unit_No__r.Legal_Entity__c, Brokerage_Summary__c,Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c,
                   CP_Invoice_Approver_L1__c, CP_Invoice_Approver_L2__c,Booking__r.Tower__r.Legal_Entity__c,
                   CP_Invoice_Approver_L3__c, CP_Invoice_Approver_L4__c, CP_Invoice_Approver_L5__c,
                   CP_Invoice_Clearing_L1__c, CP_Invoice_Clearing_L2__c,
                   Approval_Status__c, Approval_Status_clearing__c,
                   Date_Approved_by_L1__c, Date_Approved_by_L2__c, Date_Approved_by_L3__c,
                   Date_Approved_by_L4__c, Date_Approved_By_Submitter__c,
                   Brokerage_Summary__r.AOP__c,Project__c,Customer_Name__c,Tower_Unit__c,Type_of_Client__c,Brokerage_Scheme_Name__c
            FROM Brokerage_Invoice__c
            WHERE Id IN :invoiceIds
        ];
        
        // Step 2: Group invoices
        Map<String, List<Brokerage_Invoice__c>> grouped = new Map<String, List<Brokerage_Invoice__c>>();
        for (Brokerage_Invoice__c inv : invoices) {
            String type = (inv.Brokerage_Lookup__r != null && inv.Brokerage_Lookup__r.Name == 'AOP Brokerage') 
                          ? 'AOP Brokerage'
                          : (inv.Brokerage_Lookup__r != null ? inv.Brokerage_Lookup__r.Brokerage_Type__c : 'Unknown');
            
            String key = makeKey(inv.Channel_Partner__c, inv.Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c, type);
            
            if (!grouped.containsKey(key)) grouped.put(key, new List<Brokerage_Invoice__c>());
            grouped.get(key).add(inv);
        }
        
        // Step 3: Create CP_Brokerage__c records
        List<CP_Brokerage__c> toInsert = new List<CP_Brokerage__c>();
        Map<String, List<Brokerage_Invoice__c>> groupToInvoices = new Map<String, List<Brokerage_Invoice__c>>();
        
        for (String key : grouped.keySet()) {
            List<Brokerage_Invoice__c> groupInvoices = grouped.get(key);
            Brokerage_Invoice__c first = groupInvoices[0];
            //Added by Prashant to Map required customer details.. //21-01-26.Start
            Set<String> projectNames = new Set<String>();
            Set<String> customerNames = new Set<String>();
            Set<String> towerUnits = new Set<String>();
            Set<String> schemeNames = new Set<String>();
            Decimal totalBrokerage = 0;
            for (Brokerage_Invoice__c inv : groupInvoices) {
                totalBrokerage += (inv.Brokerage_In_Rs__c != null ? inv.Brokerage_In_Rs__c : 0);
                
                if (inv.Project__c != null) {
                    projectNames.add(inv.Project__c);
                }
                if (inv.Customer_Name__c != null) {
                    customerNames.add(inv.Customer_Name__c);
                }
                if (inv.Tower_Unit__c != null) {
                    towerUnits.add(inv.Tower_Unit__c);
                }
                if (inv.Brokerage_Scheme_Name__c != null) {
                    schemeNames.add(inv.Brokerage_Scheme_Name__c);
                }
            }
            
            
            // Get type again to ensure consistent key
            String type = (first.Brokerage_Lookup__r != null && first.Brokerage_Lookup__r.Name == 'AOP Brokerage') 
                          ? 'AOP Brokerage'
                          : (first.Brokerage_Lookup__r != null ? first.Brokerage_Lookup__r.Brokerage_Type__c : 'Unknown');
            
            CP_Brokerage__c cpb = new CP_Brokerage__c();
            cpb.Channel_Partner__c = first.Channel_Partner__c;
            cpb.Legal_Entity__c = first.Booking__r.Tower__r.Legal_Entity__c;
            cpb.Company_Name__c = first.Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Name__c;
            cpb.Total_Brokerage__c = totalBrokerage;
            cpb.Invoice_Date__c = Date.today();
            cpb.Brokerage_Type__c = type;
            
            String projectName = String.join(new List<String>(projectNames), ', ');
            String customerName = String.join(new List<String>(customerNames), ', ');
            String towerName = String.join(new List<String>(towerUnits), ', ');
            String schemeName = String.join(new List<String>(schemeNames), ', ');

            cpb.Project__c = projectName;
            cpb.Customer_Name__c = customerName;
            cpb.Tower_Unit__c = towerName;
            cpb.Brokerage_Scheme_Name__c = schemeName;         
            
            // Approver fields
            cpb.CP_Invoice_Approver_L1__c = first.CP_Invoice_Approver_L2__c;
            cpb.CP_Invoice_Approver_L2__c = first.CP_Invoice_Approver_L3__c;
            cpb.CP_Invoice_Approver_L3__c = first.CP_Invoice_Approver_L4__c;
            cpb.CP_Invoice_Approver_L4__c = first.CP_Invoice_Approver_L5__c;
            cpb.CP_MIS__c = first.CP_Invoice_Approver_L1__c;
            
            cpb.CP_Invoice_Clearing_L1__c = first.CP_Invoice_Clearing_L1__c;
            cpb.CP_Invoice_Clearing_L2__c = first.CP_Invoice_Clearing_L2__c;
            cpb.AOP__c = first.Brokerage_Summary__r.AOP__c;
            
            toInsert.add(cpb);
            groupToInvoices.put(key, groupInvoices);
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
            
            // Step 4: Map inserted CP_Brokerage__c back to invoices
            Map<String, Id> keyToCPBId = new Map<String, Id>();
            for (CP_Brokerage__c cpb : toInsert) {
                String key = makeKey(cpb.Channel_Partner__c, cpb.Company_Name__c, cpb.Brokerage_Type__c);
                keyToCPBId.put(key, cpb.Id);
            }
            
            List<Brokerage_Invoice__c> toUpdate = new List<Brokerage_Invoice__c>();
            for (String key : groupToInvoices.keySet()) {
                Id cpbId = keyToCPBId.get(key);
                for (Brokerage_Invoice__c inv : groupToInvoices.get(key)) {
                    inv.CP_Brokerage__c = cpbId;
                    toUpdate.add(inv);
                }
            }
            
            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }
        }
    }
}