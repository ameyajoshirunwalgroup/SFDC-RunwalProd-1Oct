public class CpMandateInvoicePreview {
    
    Public Brokerage_Invoice__c CPInv {get;set;}
    Public List<Place_of_Supply__c> pos{get;set;}
    Public List<Booking__c> bkgs{get;set;}
    public boolean withRecovery {get;set;}
    public Decimal brokerageAmount {get;set;}
    public Decimal brokerage {get;set;}
    public Decimal cgst {get;set;}
    public Decimal sgst {get;set;}
    public Decimal totalBrokerage {get;set;}
    public Decimal recoveryAmount {get;set;}
    public Decimal recoveryBrokerage {get;set;}
    public Decimal recoveryCgst {get;set;}
    public Decimal recoverySgst {get;set;}
    public Decimal recoveryTotalBrokerage {get;set;}
    public Decimal netBrokerageAmount {get;set;}
    public Decimal netBrokerage {get;set;}
    public Decimal netCgst {get;set;}
    public Decimal netSgst {get;set;}
    public Decimal netTotalBrokerage {get;set;}
    public String NoToWord {get;set;}
    public List<Annexure> annexure {get;set;}
    public List<Annexure> annexureA {get;set;}
    public List<Annexure> annexureB {get;set;}
    public InvoiceDetails invDetails {get;set;}

    public CpMandateInvoicePreview(){
        
        CPInv = new Brokerage_Invoice__c();
        pos = new List<Place_of_Supply__c>();
        bkgs = new List<Booking__c>();
        annexure = new List<Annexure>();
        annexureA = new List<Annexure>();
        annexureB = new List<Annexure>();
        brokerage = 0;
        brokerageAmount = 0;
        recoveryAmount = 0;
        totalBrokerage = 0;
        cgst = 0;
        sgst = 0;
        recoveryTotalBrokerage = 0;
        recoveryCgst = 0;
        recoverySgst = 0;
        netBrokerageAmount = 0;
        netTotalBrokerage = 0;
        netCgst = 0;
        netSgst = 0;
        //withRecovery = true;
        
        Id invId = ApexPages.currentPage().getParameters().get('id');
        System.debug('invId: ' + invId);
  
        CPInv = [SELECT Id, Invoice_Number__c, Invoice_Date__c, Place_of_Supply__c, AOP__c, Channel_Partner__c, Channel_Partner__r.SAP_CP_Code__c, 
                 Channel_Partner__r.Broker_Pan_No__c, Channel_Partner__r.RW_RERA_Registration_Number__c, Channel_Partner__r.RW_GST_Number__c,
                 Channel_Partner__r.Cheque_DD_Favouring_Name__c, Channel_Partner__r.Bank_Name__c, Channel_Partner__r.Account_Number__c,
                 Channel_Partner__r.IFSC_Code__c, Channel_Partner__r.Bank_Branch__c, AOP__r.Name, Channel_Partner__r.Company_Name_As_per_RERA__c, 
                 Channel_Partner__r.Address__c, AOP__r.Start_Date__c, AOP__r.End_Date__c, AOP__r.Brokerage__c, AOP__r.CP_Mandate_Scheme__c,
                 Channel_Partner__r.RW_Mobile_No__c, Channel_Partner__r.RW_Email__c, Channel_Partner__r.Name, CP_Mandate_Recovery_Amount__c,
                 Legal_Entity__r.RDS_Company_Name__c, Legal_Entity__r.RDS_Address1__c, Legal_Entity__r.RDS_PAN_No__c, Legal_Entity__r.GSTIN__c,
                 Legal_Entity__r.RERA_Number__c, Legal_Entity__c, Brokerage__c, Brokerage_In_Rs__c, If_GST_is_applicable__c, AOP__r.Brokerage_for_NRI__c, 
                 AOP__r.Brokerage_for_Outstation__c, Booking_List__c
                 FROM Brokerage_Invoice__c WHERE Id =: invId LIMIT 1];
        
        if(!Test.isRunningTest()){
            List<String> bkgList = CPInv.Booking_List__c.split(',');
            bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c, Type_of_Client__c FROM Booking__c WHERE Name =: bkgList];
        }else{
            bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c, Type_of_Client__c FROM Booking__c];
        }
        
        /*bkgs = [SELECT Id, Name, Project__r.Name, Opportunity__r.Name, Unit_No__r.RW_Param4__c, Booking_Date__c, Unit_No__r.RW_Param2__c, 
                Date_of_Cancellation__c, Agreement_Value_for_brokers__c, Status__c, Brokerage__c, Brokerage_Amount__c, BrokerIId__r.Name,
                Allotment_Premium__c, Type_of_Client__c
                FROM Booking__c WHERE AOP_Mandate__c =: CPInv.AOP__r.Name AND Unit_No__r.Legal_Entity__c =: CPInv.Legal_Entity__c];*/
        
        System.debug('bkgs: ' + bkgs.size());
        List<String> canceslStatusValues = new List<String>{'Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending'};
            
        invDetails = new InvoiceDetails();
        invDetails.brokerageLocal = CPInv.AOP__r.Brokerage__c;
        invDetails.brokerageOS = CPInv.AOP__r.Brokerage_for_Outstation__c;
        invDetails.brokerageNRI = CPInv.AOP__r.Brokerage_for_NRI__c;
        invDetails.avLocal = 0;
        invDetails.avOS = 0;
        invDetails.avNRI = 0;
        invDetails.recoveryAvLocal = 0;
        invDetails.recoveryAvOS = 0;
        invDetails.recoveryAvNRI = 0;
        invDetails.brokerageAmountLocal = 0;
        invDetails.brokerageAmountOS = 0;
        invDetails.brokerageAmountNRI = 0;
        invDetails.recoveryAmountLocal = 0;
        invDetails.recoveryAmountOS = 0;
        invDetails.recoveryAmountNRI = 0;
        invDetails.cgstLocal = 0;
        invDetails.cgstOS = 0;
        invDetails.cgstNRI = 0;
        invDetails.sgstLocal = 0;
        invDetails.sgstOS = 0;
        invDetails.sgstNRI = 0;
        invDetails.recoveryCgstLocal = 0;
        invDetails.recoveryCgstOS = 0;
        invDetails.recoveryCgstNRI = 0;
        invDetails.recoverySgstLocal = 0;
        invDetails.recoverySgstOS = 0;
        invDetails.recoverySgstNRI = 0;
        
        for(Booking__c bkg : bkgs){
            if(bkg.Status__c == 'Booking Confirmed' && (bkg.Booking_Date__c >= CPInv.AOP__r.Start_Date__c && bkg.Booking_Date__c <= CPInv.AOP__r.End_Date__c)){
                Decimal amountVal = 0;
                if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                    amountVal = bkg.Agreement_Value_for_brokers__c;
                }else{
                    amountVal = bkg.Allotment_Premium__c;
                }
                if(bkg.Type_of_Client__c == 'Local'){
                    invDetails.avLocal += amountVal;
                }else if(bkg.Type_of_Client__c == 'Outstation'){
                    invDetails.avOS += amountVal;
                }else if(bkg.Type_of_Client__c == 'NRI'){
                    invDetails.avNRI += amountVal;
                }
                brokerageAmount += amountVal;
                Annexure anex = new Annexure();
                anex.clientType = bkg.Type_of_Client__c;
                anex.customerName = bkg.Opportunity__r.Name;
                anex.bookingDate = Date.valueOf(bkg.Booking_Date__c);
                anex.unit = bkg.Unit_No__r.RW_Param2__c + ' - ' + bkg.Unit_No__r.RW_Param4__c;
                anex.finalAv = amountVal.setscale(2,RoundingMode.HALF_UP);
                //anex.brokerage = CPInv.AOP__r.Brokerage__c;
                anex.brokerage = 0;
                anex.brokerageAmount = 0;
                if(bkg.Type_of_Client__c == 'Local'){
                    anex.brokerage = CPInv.AOP__r.Brokerage__c;
                    anex.brokerageAmount = ((CPInv.AOP__r.Brokerage__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }else if(bkg.Type_of_Client__c == 'Outstation'){
                    anex.brokerage = CPInv.AOP__r.Brokerage_for_Outstation__c;
                    anex.brokerageAmount = ((CPInv.AOP__r.Brokerage_for_Outstation__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }else if(bkg.Type_of_Client__c == 'NRI'){
                    anex.brokerage = CPInv.AOP__r.Brokerage_for_NRI__c;
                    anex.brokerageAmount = ((CPInv.AOP__r.Brokerage_for_NRI__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }
                //anex.brokerageAmount = ((CPInv.AOP__r.Brokerage__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
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
            }else if(canceslStatusValues.contains(bkg.Status__c) || (bkg.Status__c == 'Booking Confirmed' && (bkg.Booking_Date__c < CPInv.AOP__r.Start_Date__c || bkg.Booking_Date__c > CPInv.AOP__r.End_Date__c))){
                withRecovery = true;
                Decimal amountVal = 0;
                if(bkg.Agreement_Value_for_brokers__c != null && bkg.Agreement_Value_for_brokers__c != 0){
                    amountVal = bkg.Agreement_Value_for_brokers__c;
                }else{
                    amountVal = bkg.Allotment_Premium__c;
                }
                if(bkg.Type_of_Client__c == 'Local'){
                    invDetails.recoveryAvLocal += amountVal;
                }else if(bkg.Type_of_Client__c == 'Outstation'){
                    invDetails.recoveryAvOS += amountVal;
                }else if(bkg.Type_of_Client__c == 'NRI'){
                    invDetails.recoveryAvNRI += amountVal;
                }
                recoveryAmount += amountVal;
                Annexure anexb = new Annexure();
                anexb.clientType = bkg.Type_of_Client__c;
                anexb.customerName = bkg.Opportunity__r.Name;
                anexb.bookingDate = Date.valueOf(bkg.Date_of_Cancellation__c);
                anexb.unit = bkg.Unit_No__r.RW_Param2__c + ' - ' + bkg.Unit_No__r.RW_Param4__c;
                anexb.finalAv = amountVal.setscale(2,RoundingMode.HALF_UP);
                //anexb.brokerage = CPInv.AOP__r.Brokerage__c;
                //anexb.brokerageAmount = ((CPInv.AOP__r.Brokerage__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                anexb.brokerage = 0;
                anexb.brokerageAmount = 0;
                if(bkg.Type_of_Client__c == 'Local'){
                    anexb.brokerage = CPInv.AOP__r.Brokerage__c;
                    anexb.brokerageAmount = ((CPInv.AOP__r.Brokerage__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }else if(bkg.Type_of_Client__c == 'Outstation'){
                    anexb.brokerage = CPInv.AOP__r.Brokerage_for_Outstation__c;
                    anexb.brokerageAmount = ((CPInv.AOP__r.Brokerage_for_Outstation__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }else if(bkg.Type_of_Client__c == 'NRI'){
                    anexb.brokerage = CPInv.AOP__r.Brokerage_for_NRI__c;
                    anexb.brokerageAmount = ((CPInv.AOP__r.Brokerage_for_NRI__c * amountVal)/100).setscale(2,RoundingMode.HALF_UP);
                }
                if(CPInv.If_GST_is_applicable__c == 'Yes'){
                    anexb.cgst = (0.09 * anexb.brokerageAmount).setscale(2,RoundingMode.HALF_UP);
                    anexb.sgst = (0.09 * anexb.brokerageAmount).setscale(2,RoundingMode.HALF_UP);
                    //anexb.totalBrokerage = (anexb.brokerageAmount + anexb.cgst + anexb.sgst).setscale(2,RoundingMode.HALF_UP);
                }else{
                    anexb.cgst = 0;
                    anexb.sgst = 0;
                }
                anexb.totalBrokerage = (anexb.brokerageAmount + anexb.cgst + anexb.sgst).setscale(2,RoundingMode.HALF_UP);
                anexb.cpName = bkg.BrokerIId__r.Name;
                annexureB.add(anexb);
            }
        }
        
        invDetails.brokerageAmountLocal = ((invDetails.avLocal * invDetails.brokerageLocal)/100).setscale(2,RoundingMode.HALF_UP);
        invDetails.brokerageAmountOS = ((invDetails.avOS * invDetails.brokerageOS)/100).setscale(2,RoundingMode.HALF_UP);
        invDetails.brokerageAmountNRI = ((invDetails.avNRI * invDetails.brokerageNRI)/100).setscale(2,RoundingMode.HALF_UP);
        
        
        invDetails.recoveryAmountLocal = ((invDetails.recoveryAvLocal * invDetails.brokerageLocal)/100).setscale(2,RoundingMode.HALF_UP);
        invDetails.recoveryAmountOS = ((invDetails.recoveryAvOS * invDetails.brokerageOS)/100).setscale(2,RoundingMode.HALF_UP);
        invDetails.recoveryAmountNRI = ((invDetails.recoveryAvNRI * invDetails.brokerageNRI)/100).setscale(2,RoundingMode.HALF_UP);
        
        
        //brokerage = CPInv.AOP__r.Brokerage__c;
        //brokerage = CPInv.Brokerage__c;
        brokerage = CPInv.AOP__r.Brokerage__c;
        //brokerageAmount = ((brokerageAmount * brokerage)/100).setscale(2,RoundingMode.HALF_UP);
        brokerageAmount = CPInv.Brokerage_In_Rs__c.setscale(2,RoundingMode.HALF_UP);
        if(CPInv.If_GST_is_applicable__c == 'Yes'){
            cgst = (brokerageAmount * 0.09).setscale(2,RoundingMode.HALF_UP);
        	sgst = (brokerageAmount * 0.09).setscale(2,RoundingMode.HALF_UP);
            invDetails.cgstLocal = (0.09 * invDetails.brokerageAmountLocal).setscale(2,RoundingMode.HALF_UP);
            invDetails.cgstOS = (0.09 * invDetails.brokerageAmountOS).setscale(2,RoundingMode.HALF_UP);
            invDetails.cgstNRI = (0.09 * invDetails.brokerageAmountNRI).setscale(2,RoundingMode.HALF_UP);
            invDetails.sgstLocal = (0.09 * invDetails.brokerageAmountLocal).setscale(2,RoundingMode.HALF_UP);
            invDetails.sgstOS = (0.09 * invDetails.brokerageAmountOS).setscale(2,RoundingMode.HALF_UP);
            invDetails.sgstNRI = (0.09 * invDetails.brokerageAmountNRI).setscale(2,RoundingMode.HALF_UP);

           

        }
        invDetails.totalBrokerageLocal = (invDetails.brokerageAmountLocal + invDetails.cgstLocal + invDetails.sgstLocal).setscale(2,RoundingMode.HALF_UP);
        invDetails.totalBrokerageOS = (invDetails.brokerageAmountOS + invDetails.cgstOS + invDetails.sgstOS).setscale(2,RoundingMode.HALF_UP);
        invDetails.totalBrokerageNRI = (invDetails.brokerageAmountNRI + invDetails.cgstNRI + invDetails.sgstNRI).setscale(2,RoundingMode.HALF_UP);
        
        totalBrokerage = (brokerageAmount + cgst + sgst);
        if(recoveryAmount != 0){
            recoveryAmount = ((recoveryAmount * brokerage)/100).setscale(2,RoundingMode.HALF_UP);
            if(CPInv.If_GST_is_applicable__c == 'Yes'){
                recoveryCgst = (recoveryAmount * 0.09).setscale(2,RoundingMode.HALF_UP);
        		recoverySgst = (recoveryAmount * 0.09).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoveryCgstLocal = (0.09 * invDetails.recoveryAmountLocal).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoveryCgstOS = (0.09 * invDetails.recoveryAmountOS).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoveryCgstNRI = (0.09 * invDetails.recoveryAmountNRI).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoverySgstLocal = (0.09 * invDetails.recoveryAmountLocal).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoverySgstOS = (0.09 * invDetails.recoveryAmountOS).setscale(2,RoundingMode.HALF_UP);
                invDetails.recoverySgstNRI = (0.09 * invDetails.recoveryAmountNRI).setscale(2,RoundingMode.HALF_UP);
            }
            recoveryTotalBrokerage = (recoveryAmount + cgst + sgst).setscale(2,RoundingMode.HALF_UP);
            invDetails.recoveryTotalBrokerageLocal = (invDetails.recoveryAmountLocal + invDetails.recoveryCgstLocal + invDetails.recoverySgstLocal).setscale(2,RoundingMode.HALF_UP);
            invDetails.recoveryTotalBrokerageOS = (invDetails.recoveryAmountOS + invDetails.recoveryCgstOS + invDetails.recoverySgstOS).setscale(2,RoundingMode.HALF_UP);
            invDetails.recoveryTotalBrokerageNRI = (invDetails.recoveryAmountNRI + invDetails.recoveryCgstNRI + invDetails.recoverySgstNRI).setscale(2,RoundingMode.HALF_UP);
        
        }
        netBrokerageAmount = (brokerageAmount - recoveryAmount).setscale(2,RoundingMode.HALF_UP);
        invDetails.netAv = ((invDetails.avLocal + invDetails.avOS + invDetails.avNRI) - (invDetails.recoveryAvLocal + invDetails.recoveryAvOS + invDetails.recoveryAvNRI)).setscale(2,RoundingMode.HALF_UP);
        invDetails.netBrokerageAmount = ((invDetails.brokerageAmountLocal + invDetails.brokerageAmountOS + invDetails.brokerageAmountNRI) -
                                        (invDetails.recoveryAmountLocal + invDetails.recoveryAmountOS + invDetails.recoveryAmountNRI)).setscale(2,RoundingMode.HALF_UP);
        if(CPInv.If_GST_is_applicable__c == 'Yes'){
            //netCgst = (cgst - recoveryCgst).setscale(2,RoundingMode.HALF_UP);
        	//netSgst = (sgst - recoverySgst).setscale(2,RoundingMode.HALF_UP);
            invDetails.netCgst = ((invDetails.cgstLocal + invDetails.cgstOS + invDetails.cgstNRI) -
                                  (invDetails.recoveryCgstLocal + invDetails.recoveryCgstOS + invDetails.recoveryCgstNRI)).setscale(2,RoundingMode.HALF_UP);
            invDetails.netSgst = ((invDetails.sgstLocal + invDetails.sgstOS + invDetails.sgstNRI) -
                                  (invDetails.recoverySgstLocal + invDetails.recoverySgstOS + invDetails.recoverySgstNRI)).setscale(2,RoundingMode.HALF_UP);
            netCgst = invDetails.netCgst;
            netSgst = invDetails.netSgst;
        }else{
            invDetails.netCgst = 0;
            invDetails.netSgst = 0;
        }
        //netTotalBrokerage = (totalBrokerage - recoveryTotalBrokerage).setscale(0,RoundingMode.HALF_UP);
        netTotalBrokerage = invDetails.netBrokerageAmount + invDetails.netCgst + invDetails.netSgst;
        invDetails.netTotalBrokerage = (invDetails.netBrokerageAmount + invDetails.netCgst + invDetails.netSgst).setscale(0,RoundingMode.HALF_UP);
		invDetails.netBrokerage = invDetails.brokerageLocal + invDetails.brokerageOS + invDetails.brokerageNRI;
        System.debug('netTotalBrokerage: ' + netTotalBrokerage);
        NoToWord = S_NumberToWord.convertNumbertoWords(invDetails.netTotalBrokerage);
        
        pos = StateCodes(CPInv.Place_of_Supply__c);        
    }

    public void updateInv(){
        System.debug('netcgst: ' + netCgst);
        System.debug('netSgst: ' + netSgst);
        System.debug('netTotalBrokerage: ' + netTotalBrokerage);
        CPInv.CGST__c = String.valueOf(netCgst);
        CPInv.SGST__c = String.valueOf(netSgst);
        CPInv.Invoice_Amount__c = netTotalBrokerage;
        update CPInv;
    }


    public List<Place_of_Supply__c> StateCodes(String placeofsupply){
        List<Place_of_Supply__c> ps = new List<Place_of_Supply__c>();
        system.debug('placeofsupply::'+placeofsupply);
        ps = [Select id,name,State_Code__c,SGST__c,IGST__c,CGST__c from Place_of_Supply__c where Name =:placeofsupply];
        system.debug('ps::'+ps);
        return ps;
    }
    
    public class Annexure{
        public String customerName{get;set;}
        public Date bookingDate{get;set;}
        public String unit{get;set;}
        public Decimal finalAv{get;set;}
        public Decimal brokerage{get;set;}
        public Decimal brokerageAmount{get;set;}
        public Decimal cgst{get;set;}
        public Decimal sgst{get;set;}
        public Decimal totalBrokerage{get;set;}
        public String cpName{get;set;}
        public String clientType{get;set;}
    }
    
    public class InvoiceDetails{
        public Decimal brokerageLocal{get;set;}
        public Decimal brokerageOS{get;set;}
        public Decimal brokerageNRI{get;set;}
        public Decimal avLocal{get;set;}
        public Decimal avOS{get;set;}
        public Decimal avNRI{get;set;}
        public Decimal recoveryAvLocal{get;set;}
        public Decimal recoveryAvOS{get;set;}
        public Decimal recoveryAvNRI{get;set;}
        public Decimal brokerageAmountLocal{get;set;}
        public Decimal brokerageAmountOS{get;set;}
        public Decimal brokerageAmountNRI{get;set;}
        public Decimal recoveryAmountLocal{get;set;}
        public Decimal recoveryAmountOS{get;set;}
        public Decimal recoveryAmountNRI{get;set;}
        public Decimal cgstLocal{get;set;}
        public Decimal cgstOS{get;set;}
        public Decimal cgstNRI{get;set;}
        public Decimal recoveryCgstLocal{get;set;}
        public Decimal recoveryCgstOS{get;set;}
        public Decimal recoveryCgstNRI{get;set;}
        public Decimal sgstLocal{get;set;}
        public Decimal sgstOS{get;set;}
        public Decimal sgstNRI{get;set;}
        public Decimal recoverySgstLocal{get;set;}
        public Decimal recoverySgstOS{get;set;}
        public Decimal recoverySgstNRI{get;set;}
        public Decimal totalBrokerageLocal{get;set;}
        public Decimal totalBrokerageOS{get;set;}
        public Decimal totalBrokerageNRI{get;set;}
        public Decimal recoveryTotalBrokerageLocal{get;set;}
        public Decimal recoveryTotalBrokerageOS{get;set;}
        public Decimal recoveryTotalBrokerageNRI{get;set;}
        public Decimal netBrokerage{get;set;}
        public Decimal netAv{get;set;}
        public Decimal netBrokerageAmount{get;set;}
        public Decimal netCgst{get;set;}
        public Decimal netSgst{get;set;}
        public Decimal netTotalBrokerage{get;set;}
    }
}