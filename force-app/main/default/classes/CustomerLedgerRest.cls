@RestResource(urlMapping='/CustomerLedger/*')
global without sharing class CustomerLedgerRest {
	@HttpGet
    global static Ledger doGet(){
        
        RestRequest req = RestContext.request;
        String bookingId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        Booking__c bkg = [SELECT Id, RW_Total_Demand_Raised__c, RW_Total_Receipt_Amount_Received__c, RW_Total_Receipt_Discount_Recieved__c,
                          RW_Total_TDS_Due__c, Total_Demand_Raised_Principal__c, RW_Total_GST_Amount__c, Total_TDS_Amount_Paid_In_Rs__c,
                          RW_Total_TDS_Outstanding__c, Project__r.Seperate_payment__c, Unit_No__c, Unit_No__r.TowerName__c, Customer__r.Id,
                          RW_Total_Demand_Outstanding__c
                          FROM Booking__c WHERE Id =: bookingId];
        
        Ledger ldg = new Ledger();
        ldg.totalDemandRaised = bkg.RW_Total_Demand_Raised__c;
        ldg.totalAmountReceived = bkg.RW_Total_Receipt_Amount_Received__c;
        ldg.totalDiscount = bkg.RW_Total_Receipt_Discount_Recieved__c;
        //Decimal demandOutstanding = bkg.RW_Total_Demand_Raised__c - bkg.RW_Total_Receipt_Amount_Received__c - bkg.RW_Total_Receipt_Discount_Recieved__c; //Commented by coServe 03-10-2023
        Decimal demandOutstanding = bkg.RW_Total_Demand_Outstanding__c;//Added by coServe 03-10-2023
        ldg.totalDemandOutstanding = demandOutstanding;
        ldg.overallTDSPayable = bkg.RW_Total_TDS_Due__c;
        ldg.overallTDSPaid = bkg.Total_TDS_Amount_Paid_In_Rs__c;
        ldg.netTDSOutstanding = bkg.RW_Total_TDS_Outstanding__c;
        ldg.showPayButton = true;//Added by coServe 03-10-2023
        /*if(demandOutstanding > bkg.RW_Total_TDS_Due__c){ //Commented by coServe 03-10-2023
            ldg.showPayButton = true;
        }else{
            ldg.showPayButton = false;
        }*/
        ldg.singlePayment = bkg.Project__r.Seperate_payment__c;
        if(bkg.Project__r.Seperate_payment__c){
            ldg.totalDemandAmount = demandOutstanding - bkg.RW_Total_TDS_Due__c;
        }else{
            ldg.totalDemandAmount = ((demandOutstanding - bkg.RW_Total_TDS_Due__c) * (bkg.Total_Demand_Raised_Principal__c/bkg.RW_Total_Demand_Raised__c)).setscale(0, RoundingMode.HALF_UP);
            ldg.totalGSTAmount = ((demandOutstanding - bkg.RW_Total_TDS_Due__c) * (bkg.RW_Total_GST_Amount__c/bkg.RW_Total_Demand_Raised__c)).setscale(0, RoundingMode.HALF_UP);
        }
        ldg.customerId = bkg.Customer__c;
        ldg.towerId = bkg.Unit_No__r.TowerName__c;
        ldg.unitId = bkg.Unit_No__c;
        
        return ldg;
    }
    
    
    global class Ledger{
        public Decimal totalDemandRaised;
        public Decimal totalAmountReceived;
        public Decimal totalDiscount;
        public Decimal totalDemandOutstanding;
        public Decimal totalDemandAmount;
        public Decimal totalGSTAmount;
        public Decimal overallTDSPayable;
        public Decimal overallTDSPaid;
        public Decimal netTDSOutstanding;
        public Boolean showPayButton;
        public Boolean singlePayment;
        public String customerId;
        public String towerId;
        public String unitId;
    }
}