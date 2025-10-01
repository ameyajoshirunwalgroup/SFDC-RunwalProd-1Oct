public with sharing class SAPReferralCreditAPICallOut {
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    @future (callout=true)
    
    public static void sendReferrallist(Id Refbookingids) {
        List<Applicant_Details__c> lstApplicant = [SELECT Id,Booking__c,Booking__r.Customer_Reference_Opportunity__r.AccountId,                                                   
                                                   Type_Of_Applicant__c,Salutation__c,First_Name__c,Middle_Name__c,Last_Name__c,Name,Permanent_Address__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
                                                   Permanent_Address_Line_3__c,State__c,City__c,Pincode__c,Country__c,Mobile_Number__c,Email_Address__c,PancardNo__c,Address_Proof_Number__c,Opportunity__r.SalesOrder_Number__c
                                                   FROM Applicant_Details__c WHERE  Booking__c =:Refbookingids  LIMIT 1];
        
        system.debug('____lstApplicant'+lstApplicant[0]);
        SAPReferralCreditAPI.ZSD_SFDC_VENDOR referralCreditData = New SAPReferralCreditAPI.ZSD_SFDC_VENDOR();
        SAPReferralCreditAPI.TABLE_OF_BAPIRET2 RETURN_x= new  SAPReferralCreditAPI.TABLE_OF_BAPIRET2();
        SAPReferralCreditAPI.ZSD_SFDC_VENDOR_HD VENDOR_HEADER = new SAPReferralCreditAPI.ZSD_SFDC_VENDOR_HD();
        VENDOR_HEADER.LIFNR = lstApplicant[0].Opportunity__r.SalesOrder_Number__c;
        VENDOR_HEADER.KTOKK = 'Z006'; 
        // VENDOR_HEADER.TITLE = String.valueOf(lstBroker[0].TITLE__c);
        String partnershipName = lstApplicant[0].First_Name__c +' '+lstApplicant[0].Last_Name__c;
        
        If(lstApplicant[0].Type_Of_Applicant__c  == 'Individual Buyer'){
            if(partnershipName != lstApplicant[0].Name){
                VENDOR_HEADER.NAME_ORG1 = lstApplicant[0].Name;
                //VENDOR_HEADER.NAME_LAST = lstBroker[0].NAME_LAST__c;
                VENDOR_HEADER.PARTN_CAT = '2'; // Added by Vinay 05-05-2022
                
            }else{
                VENDOR_HEADER.NAME_FIRST = lstApplicant[0].First_Name__c;
                VENDOR_HEADER.NAME_LAST = lstApplicant[0].Last_Name__c;
                VENDOR_HEADER.NAME_MIDDLE = lstApplicant[0].Middle_Name__c;   
                VENDOR_HEADER.TITLE = String.valueOf(lstApplicant[0].Salutation__c);
                VENDOR_HEADER.PARTN_CAT = '1'; // Added by Vinay 05-05-2022
            }
            //VENDOR_HEADER.PARTN_CAT = '1'; // Commented by Vinay 05-05-2022
            
        }
        /* else{
if(partnershipName != lstApplicant[0].Name){
VENDOR_HEADER.NAME_ORG1 = lstApplicant[0].Name;
}
VENDOR_HEADER.CONTACT_PERSON = lstBroker[0].Representative_Name__c; 
// VENDOR_HEADER.LEGAL_FORM = String.valueOf(lstBroker[0].Legal_Form__c);
// VENDOR_HEADER.NATURE_WORK = String.valueOf(lstBroker[0].RW_NATURE_WORK__c);
VENDOR_HEADER.PARTN_CAT = '2';
}*/
        VENDOR_HEADER.STREET = lstApplicant[0].Permanent_Address__c;
        VENDOR_HEADER.STR_SUPPL1 = lstApplicant[0].Permanent_Address_Line_1__c;
        VENDOR_HEADER.STR_SUPPL2 = lstApplicant[0].Permanent_Address_Line_2__c;
        VENDOR_HEADER.STR_SUPPL3 = lstApplicant[0].Permanent_Address_Line_3__c;
        VENDOR_HEADER.CITY = lstApplicant[0].City__c;
        // VENDOR_HEADER.POST_CODE = lstApplicant[0].Pincode__c;//
        VENDOR_HEADER.REGION = lstApplicant[0].State__c;
        VENDOR_HEADER.COUNTRY = lstApplicant[0].Country__c;
        VENDOR_HEADER.SORT1 = lstApplicant[0].Booking__r.Customer_Reference_Opportunity__r.AccountId;
        VENDOR_HEADER.MOB_NUMBER = String.valueOf(lstApplicant[0].Mobile_Number__c);
        VENDOR_HEADER.SMTP_ADDR = String.valueOf(lstApplicant[0].Email_Address__c);
        
        
        
        if(lstApplicant[0].PancardNo__c != null)
            VENDOR_HEADER.PAN = lstApplicant[0].PancardNo__c.toUpperCase(); 
      //  VENDOR_HEADER.AADHAR_NO =lstApplicant[0].PancardNo__c;
        String jsonstring = Json.serialize(VENDOR_HEADER);
        system.debug('____jsonstring'+jsonstring);
        boolean callOutError=false;
        String exceptionMsg;
        ERP_Integration_Log__c log = new ERP_Integration_Log__c();
        log.API_name__c = 'Referral Credit API';
        //log.Channel_Partner__c = lstBroker[0].id;//
        
        
        try{
            boolean status = false;
            log.Request__c = JSON.serialize(VENDOR_HEADER);
            SAPReferralCreditAPI.ZSD_SFDC_VENDORResponse_element resp = referralCreditData.ZSD_SFDC_VENDOR( RETURN_x,VENDOR_HEADER);
            log.Response__c = json.serialize(resp);
            system.debug('resp___ '+  json.serialize(resp));
            system.debug('resp.VENDOR_HEADER.LIFNR '+ resp.VENDOR_NUM);
            if(  resp.VENDOR_NUM != null &&  resp.VENDOR_NUM!= '')
                
            {
                
                // lstBroker[0].SAP_CP_Code__c =  resp.VENDOR_NUM;//Account - sap code
                log.Status__c='Success';
                Account acc = New Account();
                acc.id =lstApplicant[0].Booking__r.Customer_Reference_Opportunity__r.AccountId;
                acc.Vendor_Code__c =  resp.VENDOR_NUM;
                update acc;
                Referral_Credits__c Rc = New Referral_Credits__c();
                Rc.Reference_Booking__c = Refbookingids;
                //Rc.SAP_Document_No__c = resp.SAP_DOC_NO;
                //Rc.SAP_Document_Date__c =  Date.valueOf(resp.SAP_DOC_DT);
                update Rc;
            }else{
                log.Status__c='Failure';
                log.Error_Type__c='Data Error';
            }
        }catch(Exception ex){
            System.debug('Exception:' + ex.getMessage());
            callOutError = true;
            exceptionMsg = ex.getMessage();
        }finally{
            if(!callOutError) {
                // log.Status__c = 'Success';
                erpLogList.add(log);
                
            } else {
                log.Status__c = 'Failure';
                log.Error_Type__c='Timeout Error';
                log.Error_Reason__c = exceptionMsg;
                erpLogList.add(log);
                
            }
            if(erpLogList.size()>0)
         upsert erpLogList;
            /*ChannelPartnerTriggerHandler.bypasstrigger =true;
update lstBroker;
ChannelPartnerTriggerHandler.bypasstrigger =false;

if(erpLogList.size()>0)
upsert erpLogList;*/
        }
        
    }
     
    
}