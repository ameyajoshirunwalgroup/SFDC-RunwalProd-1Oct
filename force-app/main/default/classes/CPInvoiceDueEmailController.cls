public class CPInvoiceDueEmailController {
    Public List<Brokerage_Invoice__c> CPInv {get;set;}
    Public List<Broker__c> ChannelPartner {get;set;}
    Public List<Booking__c> bklist {get;set;}
    Public List<Brokerage_Scheme__c> brokerageScheme{get;set;}
    public Id cpId;
    public String AVValueStr {get;set;}
    public String TotalStr {get;set;}
    public String NoToWord {get;set;}
    public Decimal Total {get;set;}
    public CPInvoiceDueEmailController(){
        Id cpId = ApexPages.currentPage().getParameters().get('id');
        system.debug('cpId::'+cpId);
        CPInv = [Select id,Name,Approval_Status__c,Brokerage__c,Brokerage_In_Rs__c,Brokerage_Summary__c,Channel_Partner__c,If_GST_is_applicable__c,Invoice_Number__c,
                 Invoice_Status__c,Total_Agreement_Value__c,Booking__c,Opportunity__c,Booking__r.Project__r.Name,Booking__r.Unit_No__r.RW_Param4__c,
                 Booking__r.Unit_No__r.RW_Param2__c,Channel_Partner__r.State__c,Place_of_Supply__c,Eligible_Slab__c,Brokerage_Summary__r.Brokerage_Scheme__c from Brokerage_Invoice__c where id=: cpId];
        ChannelPartner = [Select id,Name,Broker_Pan_No__c,RW_RERA_Registration_Number__c,Address__c,RW_GST_Number__c,RW_Mobile_No__c,SAP_CP_Code__c,RW_Email__c,
                          Bank_Branch__c,Bank_Name__c,Account_Number__c,IFSC_Code__c,Cheque_DD_Favouring_Name__c from Broker__c where id=:CPInv[0].Channel_Partner__c];
        brokerageScheme = [Select Id,Name,Start_Date__c,End_Date__c from Brokerage_Scheme__c where Id=:CPInv[0].Brokerage_Summary__r.Brokerage_Scheme__c];
        bklist = [Select Id,Name,Booking_Date__c,Agreement_Value_for_brokers__c,Wing__c,Unit_Number__c,Primary_Applicant_Name__c From Booking__c where Id=:CPInv[0].Booking__c];
        if(!CPInv.isEmpty()){
            AVValueStr = INFormat(CPInv[0].Total_Agreement_Value__c);
            TotalStr = INFormat(CPInv[0].Brokerage_In_Rs__c);
            Total = (CPInv[0].Brokerage_In_Rs__c).setscale(0,RoundingMode.HALF_UP);
            system.debug('Total::'+Total);
            NoToWord = S_NumberToWord.convertNumbertoWords(Total);
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