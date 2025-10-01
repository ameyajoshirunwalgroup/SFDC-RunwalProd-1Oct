public class ReferralIOMController {
    public List<Booking__c> BookingList{get;set;}
    public Id BookingId{get;set;}
    public string AVAllotmentPremium{get;set;}
    public string TotalAmountReceived{get;set;}
    public string ActualReferralAmount{get;set;}
    public Integer Int1ReferralAmt{get;set;}
    public String CurrencyReferralAmt{get;set;}  
    public Integer Int1TDS{get;set;}
    public String CurrencyTDS{get;set;}
    public Integer Int1AdjustedAmt{get;set;}
    public String AdjustedAmt{get;set;}
    public string ReferenceTotalAmtReceived{get;set;}
    public String strEventDate {get;set;}
    public boolean isReferral {get;set;}     
    public boolean isDue{get;set;}  
    public boolean isShowBtn{get;set;} 
    public string unitTypeLabel{get;set;}

    public ReferralIOMController(){
        try{
        isReferral = false;
        isDue = false;
        isShowBtn = true;
        BookingList = New List<Booking__c>(); 
        BookingId = ApexPages.currentPage().getParameters().get('id');
        
        BookingList = [Select Id,name,RW_Project_Name__c,Customer_Reference_Opportunity__r.SAP_Customer_Number__c, Customer_Reference_Opportunity__r.Booking__r.RW_Registration_Done__c,
                       Customer_Reference_Opportunity__r.name,Reference_Booking_Registration_Date__c,Customer_Reference_Opportunity__r.Booking__r.RW_Total_Receipt_Amount_Received__c,
                       Primary_Applicant_Name__c,Unit_Type__c,Customer__r.SAP_Customer_Number__c,Flat_No__c,RW_Registration_Done__c,RW_Registration_Date__c,RW_Total_Receipt_Amount_Received__c,
                       Unit_No__r.New_Type__c,Saleable_Area_Sq_Ft__c,Original_Agreement_Value__c,Referral_Amount__c,Registration_Due_Status__c,Registration_Status__c,
                       Referral_IOM_Created_checkbox__c,Actual_Referral_Amount__c,Allotment_Premium__c,Referral_IOM_Comments__c,Customer_Reference_Flat_No__c,
                       Unit_Number__c,X1_of_Agreement_Value__c,TDS_5_to_be_deducted__c,Customer_Reference_Amount_Received__c,Customer_Reference_Primary_Applicant_Nam__c,Source_of_Booking__c,
                       Sub_Source__c,Customer_Reference__c,Project__r.CRM_MIS_Head__r.Name,Project__r.CRMHead__r.Name from Booking__c Where Id =:BookingId]; 
                     
        system.debug('BookingList ::::'+BookingList);
        system.debug('BookingList Size ::::'+BookingList.size());
            if(BookingList[0].Source_of_Booking__c =='Referral' && BookingList[0].Registration_Due_Status__c == 'Due' ){
                isReferral = true;
            }
            if(BookingList[0].Registration_Due_Status__c == 'Due' && BookingList[0].Referral_IOM_Created_checkbox__c == false ){
                isDue = true;
            }
            if(BookingList[0].Referral_IOM_Created_checkbox__c == true){
                isShowBtn = false ;
            }
        AVAllotmentPremium = INFormat(BookingList[0].Allotment_Premium__c);
        if(BookingList[0].RW_Total_Receipt_Amount_Received__c != NULL){
            TotalAmountReceived = INFormat(BookingList[0].RW_Total_Receipt_Amount_Received__c);
        }
        
        if(BookingList[0].Actual_Referral_Amount__c != NULL){
            Int1ReferralAmt = Integer.ValueOf(BookingList[0].Actual_Referral_Amount__c.setscale(0,RoundingMode.HALF_UP));
            CurrencyReferralAmt =  INFormat(Int1ReferralAmt);
        }
        else{
            Int1ReferralAmt = Integer.ValueOf(BookingList[0].X1_of_Agreement_Value__c.setscale(0,RoundingMode.HALF_UP));
            CurrencyReferralAmt =  INFormat(Int1ReferralAmt);
        }
            Int1TDS = Integer.ValueOf(BookingList[0].TDS_5_to_be_deducted__c.setscale(0,RoundingMode.HALF_UP));
            CurrencyTDS =  INFormat(Int1TDS);
        
        if(CurrencyReferralAmt != '' &&CurrencyTDS!= '' ){
            Int1AdjustedAmt = Int1ReferralAmt - Int1TDS;
            AdjustedAmt =  INFormat(Int1AdjustedAmt);

        }
        if(BookingList[0].Customer_Reference_Amount_Received__c != NULL){
            ReferenceTotalAmtReceived = INFormat(BookingList[0].Customer_Reference_Amount_Received__c);

        }
            
            String unitTypeApiValue = BookingList[0].Unit_Type__c;
            unitTypeLabel = '';
            
            Schema.DescribeFieldResult fieldResult = Booking__c.Unit_Type__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistValues) {
                if (entry.getValue() == unitTypeApiValue) {
                    unitTypeLabel = entry.getLabel();
                    break;
                }
            }

            
            
                strEventDate = string.valueOf(system.now().format('dd/MM/yyyy'));
        }
         catch(exception ex){
			System.debug('Exception occured::'+ex);
}
    }
    
    
    
    public PageReference save(){
        //BookingList[0].Referral_IOM_Created__c = 'Yes';
        BookingList[0].Referral_IOM_Created_checkbox__c = true;
        system.debug('comments--------'+BookingList[0].Referral_IOM_Comments__c);
        update BookingList[0];
        //  ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'IOM Created Successfully.Thank you!'));
        
        Pagereference objReference = new Pagereference('/apex/ReferralIOMPdf?id=' +BookingId); 
        objReference.setRedirect(true);
        return objReference;
    }
     //on cancel button
    public PageReference goBack() {
        /*Pagereference objReference = new Pagereference('/Home');
        objReference.setRedirect(true);
        return objReference;*/
        Pagereference objReference = new Pagereference('/' +BookingId); 
                    objReference.setRedirect(true);
                    return objReference;
    }
    public PageReference Generatepdf() {
        Pagereference objReference = new Pagereference('/apex/ReferralIOMPdf?id=' +BookingId); 
        objReference.setRedirect(true);
        return objReference;
        
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