public class ChannelPartnerTopSheetController {

    // This list will be used by the Visualforce page to iterate through each invoice.
    public List<InvoiceWrapper> invoiceDetails { get; set; }
    // This will hold the Channel Partner details, common for all invoices in the PDF.
    public CP_Brokerage__c channelPartner { get; set; }
    
    public SumBrokerageWrapper SumBrokerageWrapperObj {get;set;}

    // Wrapper class to hold all necessary data for a SINGLE invoice sheet.
    public class InvoiceWrapper {
        public Brokerage_Invoice__c invoice { get; set; }
        public Booking__c booking { get; set; }
        public String ReceiptAmount { get; set; }
        public String BrokerageTotalAmount { get; set; }
        public String AVAllotmentPremium { get; set; }
        public String AVforBrokers { get; set; }
        public String CurrencyCGST { get; set; }
        public String CurrencySGST { get; set; }
        public String CurrencyIGST { get; set; }
        public String CurrencyTDS { get; set; }
        public String CurrencyBrAmtPostTDS { get; set; }
        public List<BrokerageLineItemWrapper> brokerageLines { get; set; }
    }
    
    public class SumBrokerageWrapper{
        public Decimal BrokerageTotalAmount {get;set;}
        public Decimal CurrencyTDSTotal {get;set;}
        public Decimal CurrencyBrAmtPostTDS {get;set;}
        SumBrokerageWrapper(){
            BrokerageTotalAmount=0;
            CurrencyTDSTotal=0;
            CurrencyBrAmtPostTDS=0;
        }
    }

    // A small wrapper for the brokerage lines section within each invoice.
    public class BrokerageLineItemWrapper {
        public String invName { get; set; }
        public Decimal invBrokerage { get; set; }
        public Decimal invBrokerageAmt { get; set; }
    }

    // Constructor gets the Channel Partner ID from the URL
    public ChannelPartnerTopSheetController() {
        // IMPORTANT: The ID from the URL is now the Channel_Partner__c ID
        Id channelPartnerId = ApexPages.currentPage().getParameters().get('id');
        invoiceDetails = new List<InvoiceWrapper>();
        SumBrokerageWrapperObj = new SumBrokerageWrapper();
        if (channelPartnerId != null) {
            loadData(channelPartnerId);
        }
    }

    public void loadData(Id channelPartnerId) {
        try {
            // 1. Get the parent Channel Partner record
            channelPartner = [SELECT Id , Channel_Partner__r.Company_Name_As_per_RERA__c, Channel_Partner__r.Representative_Name__c,Company_Name__c,
                              Channel_Partner__r.Name, Legal_Entity__r.Name, Brokerage_Type__c, SAP_Document_No__c, Legal_Entity__r.RDS_Company_Name__c,Legal_Entity__r.Account_Name_Service_Tax__c,
                              CP_Invoice_Approver_L3__r.name, CP_Invoice_Approver_L4__r.name, CP_Invoice_Approver_L1__r.name, CP_Invoice_Approver_L2__r.name,
                              Date_Approved_By_Submitter_Formula__c, Date_Approved_ByL1_formula__c, Date_Approved_ByL2_formula__c, Date_Approved_ByL3_formula__c,
                              Date_Approved_ByL4_formula__c
                              FROM CP_Brokerage__c WHERE Id = :channelPartnerId];

            // 2. Get all related invoices for this Channel Partner
            List<Brokerage_Invoice__c> allInvoices = [
                SELECT Id, Name, Project__c, Invoice_Date__c, Customer_Name__c, Tower_Unit__c, CP_Name__c,
                       Brokerage_Scheme_Name__c, Booking__c, Channel_Partner__c, Brokerage_Summary__c,
                       CP_Invoice_Approver_L1__r.name, CP_Invoice_Approver_L2__r.name, CP_Invoice_Approver_L3__r.name,
                       CP_Invoice_Approver_L4__r.name, CP_Invoice_Approver_L5__r.name,
                       CGST__c, SGST__c, SAP_TDS__c, IGST__c, Brokerage__c, Brokerage_In_Rs__c, Invoice_Amount__c,
                       Brokerage_Lookup__r.name, Brokerage_Lookup__r.AOP_CP__c,
                       Date_Approved_By_Submitter_Formula__c, Date_Approved_ByL1_formula__c, Date_Approved_ByL2_formula__c,
                       Date_Approved_ByL3_formula__c, Date_Approved_ByL4_formula__c,
                       Phase__c, Brokerage_Summary__r.Kicker_Type__c, SAP_Document_No__c, CP_Brokerage__c,Brokerage_Lookup__r.Total_Brokerage__c
                FROM Brokerage_Invoice__c
                WHERE CP_Brokerage__c = :channelPartnerId
            ];

            if (allInvoices.isEmpty()) return;

            // 3. Collect related IDs to query related objects efficiently (Bulkification)
            Set<Id> bookingIds = new Set<Id>();
            Set<Id> summaryIds = new Set<Id>();
            for (Brokerage_Invoice__c inv : allInvoices) {
                if (inv.Booking__c != null) bookingIds.add(inv.Booking__c);
                if (inv.Brokerage_Summary__c != null) summaryIds.add(inv.Brokerage_Summary__c);
            }

            // 4. Query all related objects at once and store in Maps for easy access
            Map<Id, Booking__c> bookingMap = new Map<Id, Booking__c>([
                SELECT Id, Name, Booking_Date__c, RW_Registration_Status__c, Agreement_Value_for_brokers__c,
                       RW_Total_Receipt_Amount_Received__c, Payment_Received__c, Allotment_Premium__c,
                       F_B_CAM__c, Development_Charge__c, Stamp_duty_payable_by_Runwal__c, Stamp_duty_Paid2__c
                FROM Booking__c WHERE Id IN :bookingIds
            ]);

            // Query all brokerage lines for all relevant summaries
            Map<Id, List<Brokerage_Invoice__c>> summaryToInvoicesMap = new Map<Id, List<Brokerage_Invoice__c>>();
            for(Brokerage_Invoice__c lineItem : [SELECT Id, Brokerage_Lookup__r.Name,Brokerage_Lookup__r.Brokerage_Type__c, Brokerage__c, Brokerage_In_Rs__c, Brokerage_Summary__c,Brokerage_Lookup__r.Total_Brokerage__c 
                                                 FROM Brokerage_Invoice__c WHERE Brokerage_Summary__c IN :summaryIds ORDER BY CreatedDate ASC]) {
                if (!summaryToInvoicesMap.containsKey(lineItem.Brokerage_Summary__c)) {
                    summaryToInvoicesMap.put(lineItem.Brokerage_Summary__c, new List<Brokerage_Invoice__c>());
                }
                summaryToInvoicesMap.get(lineItem.Brokerage_Summary__c).add(lineItem);
            }


            // 5. Process each invoice and create a wrapper object
            for (Brokerage_Invoice__c inv : allInvoices) {
                InvoiceWrapper wrapper = new InvoiceWrapper();
                wrapper.invoice = inv;
                wrapper.booking = bookingMap.get(inv.Booking__c);
                wrapper.brokerageLines = new List<BrokerageLineItemWrapper>();

                if (wrapper.booking != null) {
                    wrapper.ReceiptAmount = INFormat(wrapper.booking.RW_Total_Receipt_Amount_Received__c);
                    wrapper.AVAllotmentPremium = INFormat(wrapper.booking.Allotment_Premium__c);
                    wrapper.AVforBrokers = INFormat(wrapper.booking.Agreement_Value_for_brokers__c);
                }

                wrapper.BrokerageTotalAmount = INFormat(inv.Invoice_Amount__c);
                
                Decimal cgst = inv.CGST__c != null ? decimal.ValueOf(inv.CGST__c) : 0;
                Decimal sgst = inv.SGST__c != null ? decimal.ValueOf(inv.SGST__c) : 0;
                Decimal igst = inv.IGST__c != null ? decimal.ValueOf(inv.IGST__c) : 0;
                Decimal tds = inv.SAP_TDS__c != null ? inv.SAP_TDS__c : 0;

                wrapper.CurrencyCGST = INFormat(cgst.setScale(0, RoundingMode.HALF_UP));
                wrapper.CurrencySGST = INFormat(sgst.setScale(0, RoundingMode.HALF_UP));
                wrapper.CurrencyIGST = INFormat(igst.setScale(0, RoundingMode.HALF_UP));
                wrapper.CurrencyTDS = INFormat(tds.setScale(0, RoundingMode.HALF_UP));

                Decimal brokerageInRs = inv.Brokerage_In_Rs__c != null ? inv.Brokerage_In_Rs__c : 0;
                Decimal postTDSAmount = (brokerageInRs + igst + sgst + cgst) - tds;
                wrapper.CurrencyBrAmtPostTDS = INFormat(postTDSAmount.setScale(0, RoundingMode.HALF_UP));
                BrokerageLineItemWrapper lineWrapper = new BrokerageLineItemWrapper();
                lineWrapper.invName = inv.Brokerage_Lookup__r.Name;
                lineWrapper.invBrokerage = inv.Brokerage_Lookup__r.Total_Brokerage__c;
                lineWrapper.invBrokerageAmt = inv.Brokerage_In_Rs__c;
                wrapper.brokerageLines.add(lineWrapper);
                
                SumBrokerageWrapperObj.BrokerageTotalAmount = inv.Invoice_Amount__c !=null?
                    SumBrokerageWrapperObj.BrokerageTotalAmount + inv.Invoice_Amount__c:SumBrokerageWrapperObj.BrokerageTotalAmount;
                SumBrokerageWrapperObj.CurrencyTDSTotal = inv.SAP_TDS__c != null?
                    SumBrokerageWrapperObj.CurrencyTDSTotal + inv.SAP_TDS__c:SumBrokerageWrapperObj.CurrencyTDSTotal;
                SumBrokerageWrapperObj.CurrencyBrAmtPostTDS = postTDSAmount !=null?
                    SumBrokerageWrapperObj.CurrencyBrAmtPostTDS + postTDSAmount:SumBrokerageWrapperObj.CurrencyBrAmtPostTDS;
                
                // Populate the brokerage lines
                /*if(summaryToInvoicesMap.containsKey(inv.Brokerage_Summary__c)){
                    for(Brokerage_Invoice__c lineItem : summaryToInvoicesMap.get(inv.Brokerage_Summary__c)){
                        if(lineItem.Brokerage_Lookup__r.Brokerage_Type__c == channelPartner.Brokerage_Type__c){
                            BrokerageLineItemWrapper lineWrapper = new BrokerageLineItemWrapper();
                            lineWrapper.invName = lineItem.Brokerage_Lookup__r.Name;
                            lineWrapper.invBrokerage = lineItem.Brokerage_Lookup__r.Total_Brokerage__c;
                            lineWrapper.invBrokerageAmt = lineItem.Brokerage_In_Rs__c;
                            wrapper.brokerageLines.add(lineWrapper);
                        }
                    }
                }*/
                
                invoiceDetails.add(wrapper);
            }
        } catch (Exception ex) {
            System.debug('Exception in TopSheetPdfController: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
    }
    
    // Utility method to format numbers into Indian currency format
    public static String INFormat(Decimal money) {
        if (money == null) return '0';
        
        string result = '';
        long number1 = money.round(RoundingMode.HALF_UP);
        string s = string.valueOf(number1);
        
        if (s.length() > 3) {
            result = s.substring(s.length() - 3, s.length());
            s = s.substring(0, s.length() - 3);
            while (s.length() > 0) {
                integer len = (s.length() > 2) ? 2 : s.length();
                result = s.substring(s.length() - len, s.length()) + ',' + result;
                s = s.substring(0, s.length() - len);
            }
        } else {
            result = s;
        }
        return result;
    }
}