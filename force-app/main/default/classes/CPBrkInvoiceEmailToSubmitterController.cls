public class CPBrkInvoiceEmailToSubmitterController {
	//public String cpId{get;set;}
    public String cpId {
        get;
        set {
            cpId = value;
            if(String.isNotBlank(cpId)){
                getcpupdate(); 
                getbooking();
            }
        }
    }
    public List<Broker__c> cpList {get;set;}
    public List<CP_Profile_Update__c> cpprofileupdate {get;set;}
    public String Recordurl{get;set;}
    public String ApprovalLink{get;set;}
    Public List<CP_Brokerage__c> CPInv {get;set;}
    Public List<Broker__c> ChannelPartner {get;set;}
    Public List<Booking__c> bklist {get;set;}
    Public List<Brokerage_Scheme__c> brokerageScheme{get;set;}
    public String AVValueStr {get;set;}
    public String TotalStr {get;set;}
    public String NoToWord {get;set;}
    public Decimal Total {get;set;}
    public Boolean Base {get;set;}
    public Boolean Additional {get;set;}
    public Boolean Kicker {get;set;}
    public Boolean istaxapplicable {get;set;}
    Public List<Kicker_Incentive__c> KickerScheme{get;set;}
    public String dateStr {get;set;}
    public Decimal Cgst {get;set;}
    public Decimal Sgst {get;set;}
    public Decimal Igst {get;set;}
    public Decimal TotalwithTax {get;set;}
    public String BrokerageAmtStr {get;set;}
    public String TotalwithTaxStr {get;set;}
    public String CgstStr {get;set;}
    public String SgstStr {get;set;}
    public String IgstStr {get;set;}
    public Boolean GSTApplicable {get;set;}
    public string errormsg {get;set;}
    public string errormsg2 {get;set;}
    public Integer isError1 {get;set;}
    public Boolean showgst {get;set;}
    public Boolean showigst {get;set;}
    Public static list<Legal_Entity__c> legalentity{get;set;}
    Public static list<Project__c> ProjectList{get;set;}
    public CPBrkInvoiceEmailToSubmitterController(){
        //cpId = apexpages.currentpage().getparameters().get('cpId');
    }
    public void getbooking(){
        
        //Recordurl = 'https://runwal.lightning.force.com/lightning/r/CP_Brokerage__c/'+cpId+'/view';        
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();        
        Recordurl = baseUrl + '/lightning/r/CP_Brokerage__c/' + cpId + '/view';
        //Recordurl = 'Test';
        System.debug('Record URL: ' + Recordurl);
        //Recordurl = 'https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/CP_Brokerage__c/'+cpId+'/view';
        //ApprovalLink = generateApprovalURL(cpId);
        //offerdetailmethod();
        
    }
    public void getcpupdate(){
        system.debug('cpId::'+cpId); 
        CPInv = [Select id,Name,Approval_Status__c,Brokerage__c,Total_Brokerage__c,Brokerage_Summary__c,Channel_Partner__c,If_GST_is_applicable__c,Invoice_Number__c,
                 Invoice_Status__c,Total_Agreement_Value__c,Booking__c,Opportunity__c,Booking__r.Project__r.Name,Booking__r.Unit_No__r.RW_Param4__c,
                 Booking__r.Unit_No__r.RW_Param2__c,Channel_Partner__r.State__c,Place_of_Supply__c/*Eligible_Slab__c*/,Brokerage_Summary__r.Brokerage_Scheme__c,
                 Brokerage_Type__c,Project__c,CGST__c,SGST__c,IGST__c,Total_Invoice_Amount__c,Brokerage_Summary__r.Kicker_Incentive__c,
                 Invoice_Date__c,/*RW_Eligible_Slab__c*/CP_Name__c,Customer_Name__c,
                 (Select id,Eligible_Slab__c,RW_Eligible_Slab__c,Brokerage_Summary__c,Brokerage_Summary__r.Brokerage_Scheme__c,Brokerage_Summary__r.Kicker_Incentive__c,Booking__c,
                  CP_Brokerage__r.Invoice_Number__c,CP_Brokerage__r.Invoice_Date__c,Opportunity__r.Name,Brokerage__c,Total_Agreement_Value__c,Brokerage_In_Rs__c,Invoice_Amount__c,
                  CGST__c,SGST__c,IGST__c,
                  Booking__r.Id,Booking__r.Name,Booking__r.Booking_Date__c,Booking__r.Agreement_Value_for_brokers__c,Booking__r.Wing__c,Booking__r.Unit_Number__c from Brokerage_Invoices__r) 
                 from CP_Brokerage__c where id=: cpId];
        ChannelPartner = [Select id,Name,Broker_Pan_No__c,RW_RERA_Registration_Number__c,Address__c,RW_GST_Number__c,RW_Mobile_No__c,SAP_CP_Code__c,RW_Email__c,
                          Bank_Branch__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Cheque_DD_Favouring_Name__c from Broker__c where id=:CPInv[0].Channel_Partner__c];
        
        system.debug('CP INV - > '+CPInv);
        system.debug('CP INV - > '+CPInv[0].Brokerage_Invoices__r);
        system.debug('Invoice number -> '+ CPInv[0].Invoice_Number__c);
        if(!CPInv[0].Brokerage_Invoices__r.isEmpty()){
            Id schemeId = CPInv[0].Brokerage_Invoices__r[0].Brokerage_Summary__r.Brokerage_Scheme__c;
            if(schemeId != null) {
                brokerageScheme = [Select Id,Name,Start_Date__c,End_Date__c from Brokerage_Scheme__c where Id=:schemeId];
            }
            
            
            Id kickerId = CPInv[0].Brokerage_Invoices__r[0].Brokerage_Summary__r.Kicker_Incentive__c;
            if(kickerId != null) {
                KickerScheme = [Select Id,Name,Start_Date__c,End_Date__c,Type__c from Kicker_Incentive__c where Id=:kickerId];
            }
        }        
        
        
        Set<Id> bkIds = new Set<Id>();
        if(!CPInv.isEmpty()){
            for(CP_Brokerage__c cpb: CPInv){
                for(Brokerage_Invoice__c bi : cpb.Brokerage_Invoices__r){
                    if(bi.Booking__c != null){
                        bkIds.add(bi.Booking__c);
                    }                    
                }
            }
        }
        bklist = [Select Id,Name,Booking_Date__c,Agreement_Value_for_brokers__c,Wing__c,Unit_Number__c,Opportunity__r.Name From Booking__c where Id IN: bkIds];
        BrokerageAmtStr = INFormat(CPInv[0].Total_Brokerage__c);
        
        if(CPInv[0].Brokerage_Type__c != 'Kicker Incentive'){
            if(CPInv[0].If_GST_is_applicable__c == 'Yes' ){
                Cgst = String.isNotBlank(CPInv[0].CGST__c) && CPInv[0].CGST__c != '0' ? Decimal.valueOf(CPInv[0].CGST__c) : 0.00;
                Sgst = String.isNotBlank(CPInv[0].SGST__c) && CPInv[0].SGST__c != '0' ? Decimal.valueOf(CPInv[0].SGST__c) : 0.00;
                Igst = String.isNotBlank(CPInv[0].IGST__c) && CPInv[0].IGST__c != '0' ? Decimal.valueOf(CPInv[0].IGST__c) : 0.00;                
                CgstStr = INFormat(Cgst);
                SgstStr = INFormat(Sgst);
                IgstStr = INFormat(Igst);
                AVValueStr = INFormat(CPInv[0].Total_Agreement_Value__c);                
                TotalwithTax = CPInv[0].Total_Invoice_Amount__c != null ? CPInv[0].Total_Invoice_Amount__c : 0.00;
                TotalwithTax = TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                TotalwithTaxStr = INFormat(TotalwithTax);
                NoToWord = S_NumberToWord.convertNumbertoWords(TotalwithTax);
                GSTApplicable = true;
            }else{
                TotalwithTax = CPInv[0].Total_Brokerage__c;
                TotalwithTax = TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                TotalwithTaxStr = INFormat(TotalwithTax);
                NoToWord = S_NumberToWord.convertNumbertoWords(TotalwithTax);
                AVValueStr = INFormat(CPInv[0].Total_Agreement_Value__c);
                GSTApplicable = false;
            }
        }else{
            if(CPInv[0].If_GST_is_applicable__c == 'Yes' ){
                Cgst = String.isNotBlank(CPInv[0].CGST__c) && CPInv[0].CGST__c != '0' ? Decimal.valueOf(CPInv[0].CGST__c) : 0.00;
                Sgst = String.isNotBlank(CPInv[0].SGST__c) && CPInv[0].SGST__c != '0' ? Decimal.valueOf(CPInv[0].SGST__c) : 0.00;
                Igst = String.isNotBlank(CPInv[0].IGST__c) && CPInv[0].IGST__c != '0' ? Decimal.valueOf(CPInv[0].IGST__c) : 0.00;
                CgstStr = INFormat(Cgst);
                SgstStr = INFormat(Sgst);
                IgstStr = INFormat(Igst);
                TotalwithTax = CPInv[0].Total_Invoice_Amount__c != null ? CPInv[0].Total_Invoice_Amount__c : 0.00;
                TotalwithTax = TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                TotalwithTaxStr = INFormat(TotalwithTax);
                NoToWord = S_NumberToWord.convertNumbertoWords(TotalwithTax);
                GSTApplicable = true;
            }else{
                TotalwithTax = CPInv[0].Total_Brokerage__c;
                TotalwithTax = TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                TotalwithTaxStr = INFormat(TotalwithTax);
                NoToWord = S_NumberToWord.convertNumbertoWords(TotalwithTax);
                GSTApplicable = false;
            }
        }
        if(CPInv[0].Brokerage_Type__c=='Base Brokerage'){
            Base = True;
        }else if(CPInv[0].Brokerage_Type__c=='Additional Brokerage' || CPInv[0].Brokerage_Type__c=='Retrofit Brokerage'){
            Additional = True;
        }else if(CPInv[0].Brokerage_Type__c=='Kicker Incentive'){
            Kicker = True;
        }
        if(CPInv[0].If_GST_is_applicable__c == 'Yes'){
            istaxapplicable = true;
        }else{
            istaxapplicable = false;
        }
        if(CPInv[0].Place_of_Supply__c == 'Maharashtra'){
            showgst = true;
            showigst = false;
        }else{
            showgst = false;
            showigst = true;
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
      //  if(String.isNotBlank(decimalPart)) 
      //     mf = mf + '.'  + decimalPart;
        
        if(!negative)
            mf =  mf; //+ '/-';
        else
            mf =  mf; // + '/-'; // '- ' + Removed by Aniket as on 30-11-2021 because of double negative sign 
          return mf;
    }
    
    
    
    
}