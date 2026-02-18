public class CPBrokerageInvClearingApprovalEmailCtrl {
    public String cpId{get;set;}
	Public List<Brokerage_Invoice__c> CPInv {get;set;}
    Public List<Broker__c> ChannelPartner {get;set;}
    Public List<Booking__c> bklist {get;set;}
    Public List<Brokerage_Scheme__c> brokerageScheme{get;set;}
    Public List<Kicker_Incentive__c> KickerScheme{get;set;}
    Public List<Place_of_Supply__c> pos{get;set;}
    public String dateStr {get;set;}
    public Decimal Cgst {get;set;}
    public Decimal Sgst {get;set;}
    public Decimal Igst {get;set;}
    public Decimal TotalwithTax {get;set;}
    public String BrokerageAmtStr {get;set;}
    public String TotalwithTaxStr {get;set;}
    public String AVValueStr {get;set;}
    public String CgstStr {get;set;}
    public String SgstStr {get;set;}
    public String IgstStr {get;set;}
    public String NoToWord {get;set;}
    public Boolean GSTApplicable {get;set;}
    public string errormsg {get;set;}
    public string errormsg2 {get;set;}
    public Integer isError1 {get;set;}
    public Boolean Base {get;set;}
    public Boolean Additional {get;set;}
    public Boolean Kicker {get;set;}
    public Boolean showgst {get;set;}
    public Boolean showigst {get;set;}
    public Boolean istaxapplicable {get;set;}   
    Public static list<Legal_Entity__c> legalentity{get;set;}
    Public static list<Project__c> ProjectList{get;set;}
    public String Recordurl{get;set;}
    public String ApprovalLink{get;set;}
    Public List<Tower__c> tlist {get;set;}
    public List<InvoiceWrapper> invoiceWrapper {get;set;}
    public CPBrokerageInvClearingApprovalEmailCtrl(){
        //Id cpId = ApexPages.currentPage().getParameters().get('id');
        CPInv = new List<Brokerage_Invoice__c>();
        ChannelPartner = new List<Broker__c>();
        bklist = new List<Booking__c>();
        brokerageScheme = new List<Brokerage_Scheme__c>();
        KickerScheme = new List<Kicker_Incentive__c>();
        pos = new List<Place_of_Supply__c>();
        ProjectList = new list<Project__c>();
        legalentity = new list<Legal_Entity__c>();
        errormsg = '';
        errormsg2 = '';
        isError1 = 0;
        
        
    }
    public void getbooking(){
        
        Recordurl = 'https://'+ System.URL.getCurrentRequestUrl().getHost() + '/lightning/r/CP_Brokerage__c/'+cpId+'/view';
        //Recordurl = 'https://'+ URL.getOrgDomainUrl().getHost() + '/lightning/r/CP_Brokerage__c/'+cpId+'/view';
        ApprovalLink = generateApprovalURL(cpId);
        //offerdetailmethod();
        
    }
    public static String generateApprovalURL(String recordID){
        String url='';
        List<ProcessInstanceWorkitem> workItemLst = [SELECT id FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recordID];
        if(workItemLst.size() > 0){
            url='https://'+ System.URL.getCurrentRequestUrl().getHost() + '/lightning/r/ProcessInstanceWorkitem/' + workItemLst[0].id+'/view';
            //url='https://'+ Site.getDomain() + '/lightning/r/ProcessInstanceWorkitem/' + workItemLst[0].id+'/view';
        }
        return url;
    }
    
    public void getinvoiceMethod(){
        //cpId = 'a0Q9I00000Gfb2QUAR';
        cpBrokerage = [Select id,Brokerage_Type__c,Project__c,(Select id from Brokerage_Invoices__r) from CP_Brokerage__c where Id =: cpId limit 1];
        System.debug('cpBrokerage size => ' + cpBrokerage.size());
        CPInv = [Select id,Name,Approval_Status__c,Brokerage__c,Brokerage_In_Rs__c,Brokerage_Summary__c,Channel_Partner__c,If_GST_is_applicable__c,Invoice_Number__c,
                 Invoice_Status__c,Total_Agreement_Value__c,Booking__c,Opportunity__c,Booking__r.Project__r.Name,Booking__r.Unit_No__r.RW_Param4__c,Booking__r.Booking_Date__c,
                 Booking__r.Unit_No__r.RW_Param2__c,Channel_Partner__r.State__c,Place_of_Supply__c,Eligible_Slab__c,Brokerage_Summary__r.Brokerage_Scheme__c,Booking__r.Unit_Number__c,
                 Brokerage_Lookup__r.Brokerage_Type__c,Project__c,CGST__c,SGST__c,IGST__c,Invoice_Amount__c,Brokerage_Summary__r.Kicker_Incentive__c,
                 Invoice_Date__c,RW_Eligible_Slab__c,CP_Name__c,Customer_Name__c,booking__r.Kicker_Incentive_lookup__c from Brokerage_Invoice__c where CP_Brokerage__c =: cpId order by createddate desc];
        dateStr = Date.today().format();
        invoiceWrapper = new List<InvoiceWrapper>();
        for(Brokerage_Invoice__c inv : CPInv){
            InvoiceWrapper invWrap = new InvoiceWrapper();
            invWrap.invoice = inv;
            invWrap.BrokerageAmtStr = INFormat(inv.Brokerage_In_Rs__c);
            
            if(inv.If_GST_is_applicable__c == null){
                errormsg += 'Please Select If GST is Applicable(Y/N)'; 
                isError1 = 1; 
            }
            if(inv.Invoice_Number__c == null){
                errormsg2 += 'Please Enter Invoice Number'; 
                isError1 = 1;
            }
            if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Base Brokerage'){
                invWrap.Base = True;
            }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Additional Brokerage' || inv.Brokerage_Lookup__r.Brokerage_Type__c=='Retrofit Brokerage'){
                invWrap.Additional = True;
                
            }else if(inv.Brokerage_Lookup__r.Brokerage_Type__c=='Kicker Incentive'){
                invWrap.Kicker = True;
            }
            if(inv.Place_of_Supply__c == 'Maharashtra'){
                invWrap.showgst = true;
                invWrap.showigst = false;
            }else{
                invWrap.showgst = false;
                invWrap.showigst = true;
            }
            if(inv.If_GST_is_applicable__c == 'Yes'){
                invWrap.istaxapplicable = true;
            }else{
                invWrap.istaxapplicable = false;
            }
            ChannelPartner = [Select id,Name,Broker_Pan_No__c,RW_RERA_Registration_Number__c,Address__c,RW_GST_Number__c,RW_Mobile_No__c,SAP_CP_Code__c,RW_Email__c,Company_Name_As_per_RERA__c,
                              Bank_Branch__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Cheque_DD_Favouring_Name__c,Branch_Code__c,Place_of_Supply__c,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c from Broker__c where id=:CPInv[0].Channel_Partner__c];
            brokerageScheme = [Select Id,Name,Start_Date__c,End_Date__c from Brokerage_Scheme__c where Id=:CPInv[0].Brokerage_Summary__r.Brokerage_Scheme__c];
            KickerScheme = [Select Id,Name,Start_Date__c,End_Date__c,Type__c from Kicker_Incentive__c where Id=:CPInv[0].booking__r.Kicker_Incentive_lookup__c];
            bklist = [Select Id,Name,Booking_Date__c,Agreement_Value_for_brokers__c,Wing__c,Unit_Number__c,Tower__c From Booking__c where Id=:CPInv[0].Booking__c];
            if(inv.Brokerage_Lookup__r.Brokerage_Type__c != 'Kicker Incentive'){
                tlist = [Select id,name,Legal_Entity__c from Tower__c where Id =:bklist[0].Tower__c];
                system.debug('tlist::'+tlist);
                if(!tlist.isEmpty()){
                    legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:tlist[0].Legal_Entity__c];
                    system.debug('legalentity::'+legalentity);
                }
            }else{
                ProjectList = [Select Id,Name,RDS_Company_Code__c from Project__c where Name=:CPInv[0].Project__c];
                system.debug('ProjectList::'+ProjectList);
                if(!ProjectList.isEmpty()){
                    legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:ProjectList[0].RDS_Company_Code__c];
                    system.debug('legalentity::'+legalentity);
                }
            }
            BrokerageAmtStr = INFormat(CPInv[0].Brokerage_In_Rs__c);
            pos = StateCodes(CPInv[0].Place_of_Supply__c);
            if(inv.Brokerage_Lookup__r.Brokerage_Type__c != 'Kicker Incentive'){
                if(inv.If_GST_is_applicable__c == 'Yes' ){
                    invWrap.Cgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Sgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    Cgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    Sgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    Igst = (Cgst + Sgst).setscale(2,RoundingMode.HALF_UP);
                    system.debug('inv.Brokerage_In_Rs__c - > '+inv.Brokerage_In_Rs__c);
                    system.debug('invWrap.Cgst - > '+invWrap.Cgst);
                    system.debug('invWrap.Cgst - > '+invWrap.Sgst);
                    if(invWrap.Cgst != null && invWrap.Sgst != null)
                   		invWrap.Igst = (invWrap.Cgst + invWrap.Sgst).setscale(2,RoundingMode.HALF_UP);
                    invWrap.CgstStr = INFormat(invWrap.Cgst);
                    invWrap.SgstStr = INFormat(invWrap.Sgst);
                    invWrap.IgstStr = INFormat(invWrap.Igst);
                    invWrap.AVValueStr = INFormat(inv.Total_Agreement_Value__c);
                    invWrap.TotalwithTax = invWrap.Cgst + invWrap.Sgst + inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = true;
                }else{
                    invWrap.TotalwithTax = inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.AVValueStr = INFormat(inv.Total_Agreement_Value__c);
                    invWrap.GSTApplicable = false;
                }
            }else{
                if(inv.If_GST_is_applicable__c == 'Yes' ){
                    invWrap.Cgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Sgst = (inv.Brokerage_In_Rs__c * 0.09).setscale(2,RoundingMode.HALF_UP);
                    invWrap.Igst = (invWrap.Cgst + invWrap.Sgst).setscale(2,RoundingMode.HALF_UP);
                    invWrap.CgstStr = INFormat(invWrap.Cgst);
                    invWrap.SgstStr = INFormat(invWrap.Sgst);
                    invWrap.IgstStr = INFormat(invWrap.Igst);
                    invWrap.TotalwithTax = invWrap.Cgst + invWrap.Sgst + inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = true;
                }else{
                    invWrap.TotalwithTax = inv.Brokerage_In_Rs__c;
                    invWrap.TotalwithTax = invWrap.TotalwithTax.setscale(0,RoundingMode.HALF_UP);
                    invWrap.TotalwithTaxStr = INFormat(invWrap.TotalwithTax);
                    invWrap.NoToWord = S_NumberToWord.convertNumbertoWords(invWrap.TotalwithTax);
                    invWrap.GSTApplicable = false;
                }
            }
            System.debug('invWrap.Base: ' + invWrap.Base);
            System.debug('invWrap.showigst: ' + invWrap.showigst);
            System.debug('invWrap.istaxapplicable: ' + invWrap.istaxapplicable);
            System.debug('invWrap.Additional: ' + invWrap.Additional);
            System.debug('invWrap.Kicker: ' + invWrap.Kicker);
            invoiceWrapper.add(invWrap);
        }
    }
    public List<CP_Brokerage__c> cpBrokerage {
        get {
            if (cpBrokerage == null) {
                cpBrokerage = [
                    SELECT Id, Brokerage_Type__c, Project__c,
                    (SELECT Id FROM Brokerage_Invoices__r)
                    FROM CP_Brokerage__c
                    WHERE Id = :cpId
                    LIMIT 1
                ];
                System.debug('cpBrokerage size => ' + cpBrokerage.size());
            }
            return cpBrokerage;
        }
        set;
    }

    public void dmlOperation() {
        //CPInv[0].Invoice_Status__c = 'Invoice Downloaded';
        if(showgst){
            if(istaxapplicable){
                CPInv[0].CGST__c = String.valueOf(Cgst);
                CPInv[0].SGST__c = String.valueOf(Sgst);
                //CPInv[0].IGST__c = String.valueOf(Igst);
                CPInv[0].Invoice_Amount__c = TotalwithTax;
            }else{
                CPInv[0].CGST__c = '0';
                CPInv[0].SGST__c = '0';
                //CPInv[0].IGST__c = String.valueOf(Igst);
                CPInv[0].Invoice_Amount__c = TotalwithTax;
            }
            CPInv[0].IGST__c = '0';
        }else if(showigst){
            if(istaxapplicable){
                CPInv[0].IGST__c = String.valueOf(Igst);
                CPInv[0].Invoice_Amount__c = TotalwithTax;
            }else{
                CPInv[0].IGST__c = '0';
                CPInv[0].Invoice_Amount__c = TotalwithTax;
            }
            CPInv[0].CGST__c = '0';
            CPInv[0].SGST__c = '0';
        }
        
        
        update CPInv;
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
    
    public List<Place_of_Supply__c> StateCodes(String placeofsupply){
        List<Place_of_Supply__c> ps = new List<Place_of_Supply__c>();
        system.debug('placeofsupply::'+placeofsupply);
        ps = [Select id,name,State_Code__c,SGST__c,IGST__c,CGST__c from Place_of_Supply__c where Name =:placeofsupply];
        system.debug('ps::'+ps);
        return ps;
    }
    
    
    public class InvoiceWrapper{
        public String AVValueStr {get;set;}
        public String TotalStr {get;set;}
        public String NoToWord {get;set;}
        public Decimal Total {get;set;}
        public Boolean Base {get;set;}
        public Boolean Additional {get;set;}
        public Boolean Kicker {get;set;}
    	public Boolean istaxapplicable {get;set;}
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
        public Boolean showgst {get;set;}
    	public Boolean showigst {get;set;}
        public Brokerage_Invoice__c invoice {get;set;}
    }
}