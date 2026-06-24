public with sharing class RW_BookingStamp_Registration_Charges {
    public Registration_consultant__c consultant {
        get;
        private set;
    }
    
    public Booking__c info {
        get;
        private set;
    }
    
    public String scanningCharges {
        get;
        private set;
    }
    
    public String registrationCharges {
        get;
        private set;
    }
    
    public String stampDuty {
        get;
        private set;
    }
    
    public String totalStampDuty {
        get;
        private set;
    }
    
    public RW_BookingStamp_Registration_Charges(){
        string recordId = ApexPages.currentPage().getParameters().get('bookingid');
        //system.debug(recordId);
        //string recordId= 'a0s1e0000009QFQAA2';
        info = [select id,Quotation__r.Stamp_Duty__c,Name,Unit_No__r.Relationship_Manager__r.Contact_Number__c,RM_Name__c,Customer__r.Name,Registration_consultant__c ,Consultation_Scanning_charges__c, Quotation__r.Registration_Charges__c ,  Quotation__r.Stamp_Duty_and_Registration_Total__c,Unit_No__r.RW_Param4__c, Project__r.Name , Unit_No__r.TowerName__r.Name    from Booking__c Where Id =: recordId]; 
        if(info.Consultation_Scanning_charges__c !=null){
             integer consultationCharges = Integer.valueof(Math.ceil(info.Consultation_Scanning_charges__c));
        	 scanningCharges =  S_NumberToWord.convertNumbertoWords(consultationCharges);
        }
        if(info.Quotation__r.Registration_Charges__c !=null){
        registrationCharges =  S_NumberToWord.convertNumbertoWords(info.Quotation__r.Registration_Charges__c);
        }
        if(info.Quotation__r.Stamp_Duty__c !=null){
            integer stampCharges = Integer.valueof(Math.ceil(info.Quotation__r.Stamp_Duty__c));
        	stampDuty =  S_NumberToWord.convertNumbertoWords(stampCharges);
        }
        if(info.Quotation__r.Stamp_Duty_and_Registration_Total__c !=null){
        totalStampDuty =  S_NumberToWord.convertNumbertoWords(info.Quotation__r.Stamp_Duty_and_Registration_Total__c);
        }
        consultant = [select Account_Name__c , Account_No__c , Bank_Name__c ,Branch__c , IFSC_Code__c from Registration_consultant__c Where Id =:  info.Registration_consultant__c]; // 'a281e0000008rx2AAA'];  //
    }
    
    @AuraEnabled
    public static List <String> getConsultantList() {
        List <String> consultantList= new List <String>();
        try{
        list<Registration_consultant__c> masterDataList = [select id,Name from Registration_consultant__c];
        if(masterDataList.size() > 0){
        for(Registration_consultant__c md : masterDataList) {
            consultantList.add(md.Name);
        }
        return consultantList;
        }else{
            return null;
        }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static Registration_consultant__c getConsultantInfo(string consultantId ) {
       // List <String> consultantList= new List <String>();
        Registration_consultant__c info = [select Id,Name , Account_Name__c , Account_No__c , Bank_Name__c ,Branch__c , IFSC_Code__c from Registration_consultant__c Where Name =: consultantId Limit 1];                
       	return info;
    }
    
    @AuraEnabled
    public static List<RW_Welcome_Call__c> getWelcomeStatus(string recordId ) {  
        try{
       List<RW_Welcome_Call__c> welcomeCallStatus = [select RW_Welcome_Call_Status__c from RW_Welcome_Call__c Where RW_Booking__c =: recordId Limit 1];                
       if(welcomeCallStatus.size() > 0){
        return welcomeCallStatus;
       }else{
           return  null;
        }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveChargesInfo(string BookingId , string consultationcharges , string idInfo) {    
       // system.debug(bookingsToUpdate);  
        BookingTriggerHandler.byPass =true;
        Booking__c info = [select Id, RW_SDR_Letter_Sent_Date__c, RW_SDR_Letter_Sent__c ,Registration_consultant__c , Consultation_Scanning_charges__c from Booking__c Where Id =: BookingId];    
        if(info != null){
        info.Consultation_Scanning_charges__c = decimal.valueOf(consultationcharges);
        info.Registration_consultant__c = idInfo;
        info.RW_SDR_Letter_Sent_Date__c = system.today();
        info.RW_SDR_Letter_Sent__c = true;
        update info;
        }
        BookingTriggerHandler.byPass =false;
    }
    
    @AuraEnabled
    public static string getEmailContent(string recordId){
    String emailContent = '';
    PageReference ref = Page.SDRLetter; 
    ref.getParameters().put('bookingid',recordId);
    Blob content = ref.getContent();
    String file_contents = content.toString();
    emailContent = EncodingUtil.base64Encode(content);
    return file_contents;
    }
    
    @AuraEnabled
    public static void sendEmail(string emailContent , string recordId){  
     Booking__c bookingRecord = [select id, Primary_Applicant_Email__c from Booking__c where id =:recordId ];        
        List<String> emailsToSend = new List<String>();
        string CustomerEmail = null;
        if(bookingRecord.Primary_Applicant_Email__c!=null){   
            CustomerEmail =bookingRecord.Primary_Applicant_Email__c;
            emailsToSend.add(CustomerEmail);
        }   
     Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
	 List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
     List<String> sendTo = new List<String>();
     sendTo.addAll(emailsToSend);
	 //sendTo.add('sharique1.khan@in.ey.com');
     //sendTo.add('Manojkrishna.KS@in.ey.com');
     //system.debug(sendTo);   
	 emailMessage.setToAddresses(sendTo);
     emailMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress()); 
     String Sub = '';
     Sub = 'SDR Letter';
     emailMessage.setSubject(Sub);
     emailMessage.setHtmlBody(emailContent);    
     mails.add(emailMessage);
     Messaging.SendEmailResult[] results = Messaging.sendEmail(mails); 
     system.debug(results);   
        if (results[0].success){
            System.debug('The email was sent successfully.');
        }
        else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
   

}