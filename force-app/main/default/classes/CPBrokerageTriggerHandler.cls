public class CPBrokerageTriggerHandler {
    @future // Use @future to run this asynchronously and avoid Mixed DML errors
    public static void sendEmailmethod(Set<Id> cpBrokerageIds) {

        // 1. Find the Email Template
        // IMPORTANT: Update 'Channel_Partner_Invoice_Generation_Request'
        // to be the *exact* Developer Name / API Name of your template.
        EmailTemplate template = [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName = 'Channel_Partner_Invoice_Generation_Request'
            LIMIT 1
        ];

        // 2. Get the records and the recipient email addresses
        List<CP_Brokerage__c> brokeragesToEmail = [
            SELECT Id, Channel_Partner__r.RW_Email__c, Channel_Partner__r.Name
            FROM CP_Brokerage__c
            WHERE Id IN :cpBrokerageIds
            AND Channel_Partner__r.RW_Email__c != null // Only get records with an email
        ];

        if (brokeragesToEmail.isEmpty()) {
            // No one to email, so we can stop.
            return;
        }
        // Get dummy contact email from custom label
        String dummyEmail = Label.EmailForChannelPartner;
        Contact dummyContacts = [SELECT Id,Email FROM Contact where Email =: dummyEmail  LIMIT 1];

        // 3. Create a list of emails to send
        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();

        for (CP_Brokerage__c brokerage : brokeragesToEmail) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(template.Id);
            mail.setWhatId(brokerage.Id);
            mail.setTargetObjectId(dummyContacts.Id);
            mail.setToAddresses(new List<String>{ brokerage.Channel_Partner__r.RW_Email__c });
            mail.setSaveAsActivity(false);
            allEmails.add(mail);
        }

        // 4. Send all emails at once (bulk-safe)
        if (!allEmails.isEmpty()) {
            try {
                Messaging.sendEmail(allEmails);
            } catch (Exception e) {
                System.debug('Error sending Channel Partner emails: ' + e.getMessage());
            }
        }
    }
    
    //Added by Prashant/....5-1-26 START
    public static void updateTDSonChildInvoices(Set<Id> bIds) {
        List<CP_Brokerage__c> cpblist = [ SELECT Id, Total_Brokerage__c, SAP_TDS__c, (SELECT Id, Brokerage_In_Rs__c FROM Brokerage_Invoices__r) FROM CP_Brokerage__c WHERE Id IN :bIds];
        List<Brokerage_Invoice__c> bilist = new List<Brokerage_Invoice__c>();
        for (CP_Brokerage__c c : cpblist) {            
            if (c.Brokerage_Invoices__r == null || c.Brokerage_Invoices__r.isEmpty()) {
                continue;
            }            
            Decimal totalBrokerageParent = c.Total_Brokerage__c != null ? c.Total_Brokerage__c : 0;
            Decimal tdsParent = c.SAP_TDS__c != null ? c.SAP_TDS__c : 0;
            
            if (totalBrokerageParent == 0) {
                continue;
            }
            Decimal tdsRatio = tdsParent / totalBrokerageParent;            
            for (Brokerage_Invoice__c bi : c.Brokerage_Invoices__r) {                
                if (bi.Brokerage_In_Rs__c == null) continue;                
                bi.SAP_TDS__c = (bi.Brokerage_In_Rs__c * tdsRatio).setScale(2, RoundingMode.HALF_UP);
                bilist.add(bi);
            }
        }
        
        if(!bilist.isEmpty()){
            try{
                update bilist; 
            }catch(Exception e){
                system.debug('Invoice Update Error: ' + e.getMessage()); 
            } 
        }
    }

    //Added by Prashant/....5-1-26 END
    
    //Added by Prashant to Create Brokerage Receipts when Clearing date is updated in the system... 19-02-26..START
    public static void createBrkReceiptonClearing(Set<Id> cpbIds){         
        system.debug('Inside createBrkReceiptonClearing');
        if(cpbIds == null || cpbIds.isEmpty()){
            return;
        }        
        Set<Id> existingCPB = new Set<Id>();        
        for(Brokerage_Receipt__c br : [SELECT CP_Brokerage__c FROM Brokerage_Receipt__c WHERE CP_Brokerage__c IN :cpbIds ]){
            existingCPB.add(br.CP_Brokerage__c);
        }
        
        List<Brokerage_Receipt__c> brlist = new List<Brokerage_Receipt__c>();
        
        List<CP_Brokerage__c> cpblist = [SELECT Id,Name, Invoice_Number__c, SAP_Document_No__c, Total_Brokerage__c,Invoice_Date__c, SAP_Clearing_Date__c, SAP_Broker_code__c,
            Legal_Entity__r.RDS_Company_Code__c, SAP_Clearing_No__c, SAP_Document_Date__c, SAP_Posting_Date__c,Total_Invoice_Amount__c,SAP_TDS__c,(Select Id from Brokerage_Invoices__r order by createddate desc limit 1) FROM CP_Brokerage__c WHERE Id IN :cpbIds];
        
        for(CP_Brokerage__c cpb : cpblist){
            
            if(existingCPB.contains(cpb.Id)){
                continue;
            }
            system.debug('Inside createBrkReceiptonClearing -> '+cpb.Name);
            Brokerage_Receipt__c r = new Brokerage_Receipt__c();
            r.CP_Brokerage__c = cpb.Id;
            r.SFDC_Invoice_reference__c = cpb.Invoice_Number__c;
            r.Document_No__c = cpb.SAP_Document_No__c;
            r.Document_Date__c = cpb.SAP_Document_Date__c;
            r.Brokerage_Invoice__c = !cpb.Brokerage_Invoices__r.isEmpty() ? cpb.Brokerage_Invoices__r[0].Id : null;
            r.Posting_Date__c = cpb.SAP_Posting_Date__c;
            r.SAP_Invoice_Number__c = cpb.SAP_Document_No__c;
            Decimal invoiceAmt = cpb.Total_Invoice_Amount__c != null ? cpb.Total_Invoice_Amount__c : 0  - cpb.SAP_TDS__c != null ? cpb.SAP_TDS__c : 0;
            r.Invoice_Amount__c = invoiceAmt;//Same as defined in earlier process.We use to get the Paid amount from SAP but now as we already have the data here. 
            r.Invoice_Date__c = cpb.Invoice_Date__c;
            r.Payment_Date__c = cpb.SAP_Clearing_Date__c;
            r.Clearing_Document_Number__c = cpb.SAP_Clearing_No__c;
            r.SAP_Broker_Code__c = cpb.SAP_Broker_code__c;
            r.SAP_Company_Code__c = cpb.Legal_Entity__r.RDS_Company_Code__c;
            r.Clearing_Date__c = cpb.SAP_Clearing_Date__c;
            r.Accounting_Document_No__c = cpb.SAP_Clearing_No__c;
            if(!cpb.Brokerage_Invoices__r.isEmpty())
            	brlist.add(r);
        }
        
        if(!brlist.isEmpty()){
            Database.SaveResult[] results = Database.insert(brlist, false);
            
            for(Database.SaveResult sr : results){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug('Receipt Insert Error: ' + err.getMessage());
                    }
                }
            }
        }
    }
    //Added by Prashant to Create Brokerage Receipts when Clearing date is updated in the system... 19-02-26..END
    
    //Added by Prashant to sync CP Brokerage entities with BI. /// 26-02-26..START
    public static void syncChildInvoices(List<CP_Brokerage__c> newList, Map<Id, CP_Brokerage__c> oldMap){
        
        Set<Id> parentIdsToProcess = new Set<Id>();
        
        for(CP_Brokerage__c n : newList){
            
            if(n.Invoice_Number__c != oldMap.get(n.Id).Invoice_Number__c ||
               n.Invoice_Date__c != oldMap.get(n.Id).Invoice_Date__c ||
               n.If_GST_is_applicable__c != oldMap.get(n.Id).If_GST_is_applicable__c ||
               n.SAP_Document_No__c != oldMap.get(n.Id).SAP_Document_No__c ||
               n.SAP_Document_Date__c != oldMap.get(n.Id).SAP_Document_Date__c ||
               n.SAP_Clearing_Date__c != oldMap.get(n.Id).SAP_Clearing_Date__c ||
               n.SAP_Posting_Date__c != oldMap.get(n.Id).SAP_Posting_Date__c ||
               n.SAP_TDS__c != oldMap.get(n.Id).SAP_TDS__c ||
               n.Total_Invoice_Amount__c != oldMap.get(n.Id).Total_Invoice_Amount__c ||
               n.IGST__c != oldMap.get(n.Id).IGST__c ||
               n.CGST__c != oldMap.get(n.Id).CGST__c ||
               n.SGST__c != oldMap.get(n.Id).SGST__c)
            {                
                parentIdsToProcess.add(n.Id);
            }
        }
        
        if(!parentIdsToProcess.isEmpty())
        {            
            List<Brokerage_Invoice__c> childrenToUpdate = [
                SELECT Id, CP_Brokerage__c, Brokerage_In_Rs__c,Invoice_Number__c, Invoice_Date__c, If_GST_is_applicable__c,SAP_Document_No__c, SAP_Document_Date__c,
                SAP_Clearing_Date__c, SAP_Posting_Date__c,SAP_TDS__c, Invoice_Amount__c, IGST__c, CGST__c, SGST__c FROM Brokerage_Invoice__c WHERE 
                CP_Brokerage__c IN :parentIdsToProcess
            ];
            
            Map<Id, CP_Brokerage__c> parentMap = new Map<Id, CP_Brokerage__c>(newList);
            
            List<Brokerage_Invoice__c> finalUpdateList = new List<Brokerage_Invoice__c>();
            
            for(Brokerage_Invoice__c child : childrenToUpdate){                
                CP_Brokerage__c parent = parentMap.get(child.CP_Brokerage__c);                
                if(parent == null) continue;  
                child.Invoice_Number__c = parent.Invoice_Number__c;
                child.Invoice_Date__c = parent.Invoice_Date__c;
                child.If_GST_is_applicable__c = parent.If_GST_is_applicable__c;
                child.SAP_Document_No__c = parent.SAP_Document_No__c;
                child.SAP_Document_Date__c = parent.SAP_Document_Date__c;
                child.SAP_Clearing_Date__c = parent.SAP_Clearing_Date__c;
                child.SAP_Posting_Date__c = parent.SAP_Posting_Date__c;                
                
                Decimal brokerageAmt = child.Brokerage_In_Rs__c != null ? child.Brokerage_In_Rs__c : 0;
                Decimal gstRate = 0.09; // 9%
                
                Decimal cgst = 0;
                Decimal sgst = 0;
                Decimal igst = 0;
                
                if(parent.If_GST_is_applicable__c == 'Yes'){                               
                    if(parent.Place_of_Supply__c != 'Maharashtra'){
                        igst = (brokerageAmt * 0.18).setScale(2, RoundingMode.HALF_UP);
                    }else{
                        cgst = (brokerageAmt * gstRate).setScale(2, RoundingMode.HALF_UP);
                        sgst = (brokerageAmt * gstRate).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                
                child.CGST__c = String.valueOf(cgst);
                child.SGST__c = String.valueOf(sgst);
                child.IGST__c = String.valueOf(igst);
                
                Decimal totalGST = cgst + sgst + igst;
                
                child.Invoice_Amount__c = (brokerageAmt + totalGST).setScale(2, RoundingMode.HALF_UP);
                
                Decimal totalBrokerageParent = parent.Total_Brokerage__c != null ? parent.Total_Brokerage__c : 0;
                Decimal parentTDS = parent.SAP_TDS__c != null ? parent.SAP_TDS__c : 0;
                
                if(totalBrokerageParent > 0){
                    Decimal tdsRatio = parentTDS / totalBrokerageParent;
                    child.SAP_TDS__c = (brokerageAmt * tdsRatio).setScale(2, RoundingMode.HALF_UP);
                }
                
                finalUpdateList.add(child);
            }
            
            if(!finalUpdateList.isEmpty()){
                Database.update(finalUpdateList, false);
            }
        }
    }
    //Added by Prashant to sync CP Brokerage entities with BI. /// 26-02-26..END
    
    
   
    
    
}