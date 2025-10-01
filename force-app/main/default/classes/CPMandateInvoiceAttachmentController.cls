public class CPMandateInvoiceAttachmentController {
    
    Public Brokerage_Invoice__c CpInv {get;set;}
    public List<Annexure> annexure {get;set;}
    
    public CPMandateInvoiceAttachmentController(){
        CpInv = new Brokerage_Invoice__c();
        annexure = new List<Annexure>();
        
        Id invId = ApexPages.currentPage().getParameters().get('id');
        String bkgListStr = ApexPages.currentPage().getParameters().get('bkgListStr');
        Decimal recoveryAmt = Decimal.valueOf(ApexPages.currentPage().getParameters().get('recovery'));
        List<String> bkgNameList = bkgListStr.split(',');
        Decimal brokerage = Decimal.valueOf(ApexPages.currentPage().getParameters().get('brokerage'));
        //System.debug('brokerage: ' + brokerage);
        
        /*Brokerage_Invoice__c inv = [SELECT Id, Invoice_Number__c, Invoice_Date__c, Place_of_Supply__c, AOP__c, Channel_Partner__c, Channel_Partner__r.SAP_CP_Code__c, 
                 Channel_Partner__r.Broker_Pan_No__c, Channel_Partner__r.RW_RERA_Registration_Number__c, Channel_Partner__r.RW_GST_Number__c,
                 Channel_Partner__r.Cheque_DD_Favouring_Name__c, Channel_Partner__r.Bank_Name__c, Channel_Partner__r.Account_Number__c,
                 Channel_Partner__r.IFSC_Code__c, Channel_Partner__r.Bank_Branch__c, AOP__r.Name, Channel_Partner__r.Company_Name_As_per_RERA__c, 
                 Channel_Partner__r.Address__c, AOP__r.Start_Date__c, AOP__r.End_Date__c, AOP__r.Brokerage__c, AOP__r.CP_Mandate_Scheme__c,
                 Channel_Partner__r.RW_Mobile_No__c, Channel_Partner__r.RW_Email__c, Channel_Partner__r.Name, CP_Mandate_Recovery_Amount__c,
                 Legal_Entity__r.RDS_Company_Name__c, Legal_Entity__r.RDS_Address1__c, Legal_Entity__r.RDS_PAN_No__c, Legal_Entity__r.GSTIN__c,
                 Legal_Entity__r.RERA_Number__c, Legal_Entity__c, Brokerage__c, Brokerage_In_Rs__c, If_GST_is_applicable__c
                 FROM Brokerage_Invoice__c WHERE Id =: invId LIMIT 1];*/
        //Brokerage_Invoice__c inv = [SELECT Id FROM Brokerage_Invoice__c WHERE Id =: invId];
        //System.debug('inv: ' + inv);
        List<Booking__c> bkgs = new List<Booking__c>();
        if(recoveryAmt > 0){
            bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c FROM Booking__c WHERE Name =: bkgNameList];
        }else{
            bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c FROM Booking__c WHERE Name =: bkgNameList AND Status__c = 'Booking Confirmed'];
        }
        /*List<Booking__c> bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c FROM Booking__c WHERE Name =: bkgNameList];*/
        System.debug('bkgs: ' + bkgs.size());
        
        for(Booking__c bkg : bkgs){
            //brokerageAmount += bkg.Agreement_Value_for_brokers__c;
            //if(bkg.Status__c == 'Booking Confirmed'){
                Decimal amountVal = 0;
                if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                    amountVal = bkg.Agreement_Value_for_brokers__c;
                }else{
                    amountVal = bkg.Allotment_Premium__c;
                }
                Annexure anex = new Annexure();
                anex.customerName = bkg.Opportunity__r.Name;
                anex.bookingDate = Date.valueOf(bkg.Booking_Date__c);
                anex.bookingStatus = bkg.Status__c;
                anex.unit = bkg.Unit_No__r.RW_Param2__c + ' - ' + bkg.Unit_No__r.RW_Param4__c;
                anex.finalAv = amountVal.setscale(2,RoundingMode.HALF_UP);
                anex.brokerage = brokerage;
                anex.brokerageAmount = ((brokerage * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                if(CPInv.If_GST_is_applicable__c == 'Yes'){
                    anex.cgst = (0.09 * anex.brokerageAmount).setscale(2,RoundingMode.HALF_UP);
                    anex.sgst = (0.09 * anex.brokerageAmount).setscale(2,RoundingMode.HALF_UP);
                    //anex.totalBrokerage = (anex.brokerageAmount + anex.cgst + anex.sgst).setscale(2,RoundingMode.HALF_UP);
                }else{
                    anex.cgst = 0;
                    anex.sgst = 0;
                }
                anex.totalBrokerage = (anex.brokerageAmount + anex.cgst + anex.sgst).setscale(2,RoundingMode.HALF_UP);
                anex.cpName = bkg.BrokerIId__r.Name;
                annexure.add(anex); 
            //}
        }
    }
    
    public class Annexure{
        public String customerName{get;set;}
        public Date bookingDate{get;set;}
        public String bookingStatus{get;set;}
        public String unit{get;set;}
        public Decimal finalAv{get;set;}
        public Decimal brokerage{get;set;}
        public Decimal brokerageAmount{get;set;}
        public Decimal cgst{get;set;}
        public Decimal sgst{get;set;}
        public Decimal totalBrokerage{get;set;}
        public String cpName{get;set;}
    }

}