public class TopSheetPdfController {
    public List<Brokerage_Invoice__c> InvoiceList{get;set;}
    public List<Booking__c> BookingList{get;set;}
    public List<Broker__c> CPList{get;set;}
    public List<ProcessInstanceStep> PInstanceList{get;set;}
    public string ReceiptAmount{get;set;}
    public string BrokerageAmount{get;set;}
    public string BrokerageTotalAmount{get;set;}
    public string AVAllotmentPremium{get;set;}
    public string AVforBrokers{get;set;}
    public Decimal IntCGST{get;set;}
    public Integer Int1CGST{get;set;}
    public String CurrencyCGST{get;set;}
    public Decimal IntSGST{get;set;}
    public Integer Int1SGST{get;set;}
    public String CurrencySGST{get;set;}
    public Decimal IntIGST{get;set;}
    public Integer Int1IGST{get;set;}
    public String CurrencyIGST{get;set;}
    public Integer Int1TDS{get;set;}
    public String CurrencyTDS{get;set;}
    public Decimal BroKerageAmtPostTDS{get;set;}
    public Decimal Int1BroKerageAmtPostTDS{get;set;}
    public String CurrencyBrAmtPostTDS{get;set;}
    
    /* public List<Brokerage_Receipt__c> ReceiptList{get;set;}
public List<ProcessInstanceWorkitem> workItemLst {get;set;}
public List<ProcessInstanceStep> workItemLst1 {get;set;}*/
    public TopSheetPdfController(){
        Id InvoiceId = ApexPages.currentPage().getParameters().get('id');
        InvoiceList = New List<Brokerage_Invoice__c>(); 
        BookingList = New List<Booking__c>();
        CPList = New List<Broker__c>();
        PInstanceList = New List<ProcessInstanceStep>();
        /*SELECT Id, StepStatus, comments,CreatedDate
                
                 FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=: InvoiceList[0].id
                 and stepStatus='Approved'*/
        
        
        //Int1TDS = 0;
        //ReceiptList = New List<Brokerage_Receipt__c>();
        //workItemLst = New List<ProcessInstanceWorkitem>();
        //workItemLst1 = New List<ProcessInstanceStep>();
        TopSheetPdfMethod(InvoiceId);
    }
    public void TopSheetPdfMethod(Id InvId){
           try{
        InvoiceList = [Select Id,name,Project__c,Invoice_Date__c,Customer_Name__c,Tower_Unit__c,CP_Name__c,Brokerage_Scheme_Name__c,Booking__c,Channel_Partner__c,CP_Invoice_Approver_L1__r.name,CP_Invoice_Approver_L2__r.name,CP_Invoice_Approver_L3__r.name,CP_Invoice_Approver_L4__r.name,CP_Invoice_Approver_L5__r.name,CGST__c,SGST__c,SAP_TDS__c,IGST__c, Brokerage__c,Brokerage_In_Rs__c,Invoice_Amount__c,
                       Brokerage_Lookup__r.name,Date_Approved_by_L1__c,Date_Approved_by_L2__c,Date_Approved_by_L3__c,Date_Approved_by_L4__c,Date_Approved_ByL1_formula__c,Date_Approved_ByL2_formula__c,Date_Approved_ByL3_formula__c,Date_Approved_ByL4_formula__c,Phase__c ,Brokerage_Summary__r.Kicker_Type__c,Date_Approved_By_Submitter_Formula__c,SAP_Document_No__c,Brokerage_Lookup__r.AOP_CP__c
                       From Brokerage_Invoice__c Where Id =:InvId ];        
        system.debug('InvoiceList ::'+InvoiceList);
        system.debug('InvoiceList Size ::'+InvoiceList.size());
        BookingList = [Select id,name,Booking_Date__c,RW_Registration_Done__c,RW_Registration_Status__c,Agreement_Value_for_brokers__c,Total_Brokerage_Amount__c,Base_Brokerage_2__c,Kicker_Incentive_lookup__r.name,RW_Total_Receipt_Amount_Received__c,Payment_Received__c,Allotment_Premium__c,F_B_CAM__c,Development_Charge__c,Stamp_duty_payable_by_Runwal__c,Stamp_duty_Paid2__c from Booking__c Where Id =: InvoiceList[0].Booking__c];
        system.debug('BookingList::'+BookingList);
        system.debug('BookingList Size :'+BookingList.size());
        
        CPList = [Select id,name,Company_Name_As_per_RERA__c,Representative_Name__c From Broker__c Where Id = : InvoiceList[0].Channel_Partner__c];
        system.debug('CPList ::'+CPList);
        system.debug('CPList Size :'+CPList.size());
        PInstanceList = [SELECT Id, StepStatus,CreatedDate
                    FROM ProcessInstanceStep where ProcessInstance.TargetObjectId=: InvId
                 and stepStatus='Approved'];
               
               system.debug('PInstanceList' +PInstanceList);
               
               
               
        ReceiptAmount = INFormat(BookingList[0].RW_Total_Receipt_Amount_Received__c);
        BrokerageAmount = INFormat(InvoiceList[0].Brokerage_In_Rs__c);
        BrokerageTotalAmount = INFormat(InvoiceList[0].Invoice_Amount__c);
        AVAllotmentPremium = INFormat(BookingList[0].Allotment_Premium__c);
        AVforBrokers = INFormat(BookingList[0].Agreement_Value_for_brokers__c);
        
        IntCGST  = (decimal.ValueOf(InvoiceList[0].CGST__c));
        Int1CGST = Integer.ValueOf(IntCGST.setscale(0,RoundingMode.HALF_UP));
        CurrencyCGST =  INFormat(Int1CGST);
        
        IntSGST  = (decimal.ValueOf(InvoiceList[0].SGST__c));
        Int1SGST = Integer.ValueOf(IntSGST.setscale(0,RoundingMode.HALF_UP));
        CurrencySGST =  INFormat(Int1SGST);
        
        
        IntIGST  = (decimal.ValueOf(InvoiceList[0].IGST__c));
        Int1IGST = Integer.ValueOf(IntIGST.setscale(0,RoundingMode.HALF_UP));
        CurrencyIGST = INFormat(Int1IGST);
       /* if(InvoiceList[0].SAP_TDS__c == NULL){
             InvoiceList[0].SAP_TDS__c = 0.00;
        }
        else{
              Int1TDS= Integer.ValueOf(InvoiceList[0].SAP_TDS__c.setscale(0,RoundingMode.HALF_UP)); 
        }*/
        Int1TDS= Integer.ValueOf(InvoiceList[0].SAP_TDS__c.setscale(0,RoundingMode.HALF_UP)); 
        system.debug('Int1TDS ::'+Int1TDS);
        CurrencyTDS = INFormat(Int1TDS);
        system.debug('CurrencyTDS ::'+CurrencyTDS);
        
        if(BrokerageAmount != null || BrokerageAmount != '' ){
            BroKerageAmtPostTDS = (InvoiceList[0].Brokerage_In_Rs__c + Int1IGST + Int1SGST + Int1CGST) - Int1TDS;
            Int1BroKerageAmtPostTDS = BroKerageAmtPostTDS.setscale(0,RoundingMode.HALF_UP);
            CurrencyBrAmtPostTDS = INFormat(Int1BroKerageAmtPostTDS);
        }
        // ReceiptList =[Select id,name,Brokerage_Invoice__c,Invoice_Amount__c from Brokerage_Receipt__c Where  Invoice_Amount__c != Null And Brokerage_Invoice__c =: InvId ];
        // system.debug('ReceiptList::'+ReceiptList);
        //system.debug('ReceiptList Size :'+ReceiptList.size());
        //workItemLst = [SELECT id, ActorId,CreatedDate,SystemModstamp,processInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId =: InvId];
        // workItemLst1 = [SELECT ProcessInstanceId, StepStatus, OriginalActorId, CreatedDate, CreatedById, Id FROM ProcessInstanceStep Where Id =: InvId];
        // system.debug('workItemLst::'+workItemLst);
        // system.debug('workItemLst size::'+workItemLst.size());
         }
         catch(exception ex){
			System.debug('Exception occured::'+ex);
}
    }
    public static String INFormat(Decimal money) {
        
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        Decimal tempMoney = money;
        String m0 = tempMoney.setscale(0,RoundingMode.HALF_UP).toPlainString();
        system.debug('M0::-'+m0);
        String decimalPart;
        List<String> tempStr = new List<String>();
        if(String.isNotBlank(m0)) {
            tempStr = m0.split('\\.');
            if(tempStr != null && tempStr.size() ==2) {
                decimalPart = tempStr[1];
            }
        }
        
        //String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String m1 = tempStr[0].reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
            if(i==2) {
                mF += ',';
            }
            if(i==4 || i==6 || i==8 || i==10 || i==12) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        
        if(!negative)
            mf =  mf;
        else
            mf =  mf; 
        return mf;
    }
    
}