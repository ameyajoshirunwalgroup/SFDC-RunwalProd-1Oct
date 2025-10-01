public class SAP_Rest_ReferralCreditAPI {
    Public String LIFNR{get;set;}
    Public String ref_to_cust{get;set;}
    Public String PARTN_CAT{get;set;}
    Public String KTOKK{get;set;}
    Public String TITLE{get;set;}
    Public String NAME_FIRST{get;set;}
    Public String NAME_LAST{get;set;}
    Public String NAME_MIDDLE{get;set;}
    Public String NAME_ORG1{get;set;}
    Public String STREET{get;set;}
    Public String STR_SUPPL1 {get;set;}
    Public String STR_SUPPL2{get;set;}
    Public String STR_SUPPL3 {get;set;}
    Public String CITY {get;set;}
    Public String POST_CODE{get;set;}
    Public String COUNTRY{get;set;}
    Public String REGION{get;set;}
    Public String SORT1{get;set;}
    Public String MOB_NUMBER{get;set;}
    Public String SMTP_ADDR{get;set;}
    Public String CONTACT_PERSON{get;set;}
    Public String PAN{get;set;}
    Public String ref_text{get;set;}
    @future(Callout = true)
    public static void sendReferrallist(list<Id> referralCreditId) {
        List<Referral_Credits__c> RcList1 = [Select Id,name,Referral_In_Rs__c,Name_of_New_Customer__c,Reference_Booking__r.Name,Reference_Booking__c,long_text1__c,Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c,
                                                     Booking__r.Customer__r.SalesOrder_Number__c  From Referral_Credits__c Where Id IN: referralCreditId]; 
        system.debug('RcList1::'+RcList1);         
        system.debug('RcList1 size::'+RcList1.size()); 
        Id Refbookingids = RcList1[0].Reference_Booking__c;
        String body = '';
        system.debug('Refbookingids'+Refbookingids);
        List<ERP_Integration_Log__c> APIlogsToInsertList = new List<ERP_Integration_Log__c>();
        List<Applicant_Details__c> lstApplicant = [SELECT Id,Booking__c,Booking__r.Customer__r.AccountId,                                                   
                                                   Type_Of_Applicant__c,Salutation__c,First_Name__c,Middle_Name__c,Last_Name__c,Name,Permanent_Address__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
                                                   Permanent_Address_Line_3__c,State__c,City__c,Pincode__c,Country__c,Mobile_Number__c,Email_Address__c,PancardNo__c,Address_Proof_Number__c,Opportunity__r.SAP_Customer_Number__c
                                                   FROM Applicant_Details__c WHERE  Booking__c =:Refbookingids ];
        
        system.debug('lstApplicant'+lstApplicant);
        system.debug('lstApplicant size'+lstApplicant.size());   
        if(!lstApplicant.isempty() && lstApplicant.size()>0){         
            
            ERP_Integration_Log__c api = new ERP_Integration_Log__c();
            
            ReferralCreditCreationParser jsonResponse = new ReferralCreditCreationParser();
            Http http = new Http();
            Http http1 = new Http();
            
            String username = Label.SAP_Username;
            String password = Label.SAP_Password;
            String endPointURL = Label.SAP_Referral_Credit_API_Endpoint;
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            
            String sapdocno = '';
            String sapdocdate = '';
            String VendorNo = '';
            
            /* Calling get method for Authentication */            
            JSONGenerator gen = JSON.createGenerator(true);
            // Write data to the JSON string.
            gen.writeStartObject();
            if(lstApplicant[0].Opportunity__r.SAP_Customer_Number__c!= Null && lstApplicant[0].Opportunity__r.SAP_Customer_Number__c !=''){
                gen.writeStringField('ref_to_cust',lstApplicant[0].Opportunity__r.SAP_Customer_Number__c);
            }else{
                gen.writeStringField('ref_to_cust','');
            }
            if(lstApplicant[0].Type_Of_Applicant__c!= Null && lstApplicant[0].Type_Of_Applicant__c =='Individual Buyer'){
                gen.writeStringField('PARTN_CAT','1');
            }else{
                gen.writeStringField('PARTN_CAT','');
            }
            gen.writeStringField('KTOKK','Z006');
            /*if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' ){
gen.writeStringField('TITLE',lstApplicant[0].Salutation__c);
}else{
gen.writeStringField('TITLE','');
}*/
            
            if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'Mr.'){
                gen.writeStringField('TITLE','0002');
            }
            else if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'Ms'){
                gen.writeStringField('TITLE','0001');
            }
            else if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'M/S'){
                gen.writeStringField('TITLE','0005');
            }
            else if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'Mrs'){
                gen.writeStringField('TITLE','0006');
            } 
            else if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'Dr.'){
                gen.writeStringField('TITLE','0007');
            } 
            else if(lstApplicant[0].Salutation__c!= Null && lstApplicant[0].Salutation__c !='' && lstApplicant[0].Salutation__c == 'CAPT.'){
                gen.writeStringField('TITLE','0008');
            } 
            else{
                gen.writeStringField('TITLE','');
            } 
            if(lstApplicant[0].First_Name__c!= Null && lstApplicant[0].First_Name__c !=''){
                gen.writeStringField('NAME_FIRST',lstApplicant[0].First_Name__c);
            }else{
                gen.writeStringField('NAME_FIRST','');
            }
            if(lstApplicant[0].Middle_Name__c!= Null && lstApplicant[0].Middle_Name__c !=''){
                gen.writeStringField('NAME_MIDDLE',lstApplicant[0].Middle_Name__c);
            }else{
                gen.writeStringField('NAME_MIDDLE','');
            }
            if(lstApplicant[0].Last_Name__c!= Null && lstApplicant[0].Last_Name__c !=''){
                gen.writeStringField('NAME_LAST',lstApplicant[0].Last_Name__c);
            }else{
                gen.writeStringField('NAME_LAST','');
            }
            if(lstApplicant[0].First_Name__c =='' && lstApplicant[0].Last_Name__c ==''){
                gen.writeStringField('NAME_ORG1',lstApplicant[0].Name);
            }else{
                gen.writeStringField('NAME_ORG1','');
            }
            if(lstApplicant[0].Permanent_Address__c!= Null && lstApplicant[0].Permanent_Address__c !=''){
                gen.writeStringField('STREET',lstApplicant[0].Permanent_Address__c);
            }else{
                gen.writeStringField('STREET','');
            }
            if(lstApplicant[0].Permanent_Address_Line_1__c!= Null && lstApplicant[0].Permanent_Address_Line_1__c !=''){
                gen.writeStringField('STR_SUPPL1',lstApplicant[0].Permanent_Address_Line_1__c);
            }else{
                gen.writeStringField('STR_SUPPL1','');
            }
            if(lstApplicant[0].Permanent_Address_Line_2__c!= Null && lstApplicant[0].Permanent_Address_Line_2__c !=''){
                gen.writeStringField('STR_SUPPL2',lstApplicant[0].Permanent_Address_Line_2__c);
            }else{
                gen.writeStringField('STR_SUPPL2','');
            }
            if(lstApplicant[0].Permanent_Address_Line_3__c!= Null && lstApplicant[0].Permanent_Address_Line_3__c !=''){
                gen.writeStringField('STR_SUPPL3',lstApplicant[0].Permanent_Address_Line_3__c);
            }else{
                gen.writeStringField('STR_SUPPL3','');
            }
            if(lstApplicant[0].City__c!= Null && lstApplicant[0].City__c !=''){
                gen.writeStringField('CITY',lstApplicant[0].City__c);
            }else{
                gen.writeStringField('CITY','');
            }
            if(lstApplicant[0].Pincode__c != Null ){
                gen.writeNumberField('POST_CODE',lstApplicant[0].Pincode__c);
            }else{
                gen.writeNumberField('POST_CODE',0);
            }
            if(lstApplicant[0].Country__c!= Null && lstApplicant[0].Country__c !=''){
                gen.writeStringField('COUNTRY',lstApplicant[0].Country__c);
            }else{
                gen.writeStringField('COUNTRY','');
            }
            if(lstApplicant[0].State__c!= Null && lstApplicant[0].State__c !=''){
                gen.writeStringField('REGION',lstApplicant[0].State__c);
            }else{
                gen.writeStringField('REGION','');
            }
            if(lstApplicant[0].Booking__r.Customer__r.AccountId!= Null){
                gen.writeStringField('SORT1',lstApplicant[0].Booking__r.Customer__r.AccountId);
                //gen.writeStringField('SORT1','76666');
            }else{
                gen.writeStringField('SORT1','');
            }
            if(lstApplicant[0].Mobile_Number__c!= Null && lstApplicant[0].Mobile_Number__c !=''){
                gen.writeStringField('MOB_NUMBER',lstApplicant[0].Mobile_Number__c);
            }else{
                gen.writeStringField('MOB_NUMBER','');
            }
            if(lstApplicant[0].Email_Address__c!= Null && lstApplicant[0].Email_Address__c !=''){
                gen.writeStringField('SMTP_ADDR',lstApplicant[0].Email_Address__c);
            }else{
                gen.writeStringField('SMTP_ADDR','');
            }
            if(lstApplicant[0].Name!= Null && lstApplicant[0].Name !=''){
                gen.writeStringField('CONTACT_PERSON',lstApplicant[0].Name);
            }else{
                gen.writeStringField('CONTACT_PERSON','');
            }
            if(lstApplicant[0].PancardNo__c!= Null && lstApplicant[0].PancardNo__c !=''){
                gen.writeStringField('PAN',lstApplicant[0].PancardNo__c);
            }else{
                gen.writeStringField('PAN','');
            }
                                   
            gen.writeStringField('lifnr','');
            gen.writeStringField('nature_work','');
            gen.writeStringField('legal_form','');
            gen.writeStringField('residential_status','');
            gen.writeStringField('gst_no','');
            gen.writeStringField('rera_no','');
            gen.writeStringField('aadhar_no','');
            gen.writeStringField('zterms','');
            //  gen.writeStringField('bukrs','1000');
            //gen.writeStringField('inv_amt','50000');
            if(RcList1[0].Referral_In_Rs__c!= Null ){
                gen.writeNumberField('inv_amt',RcList1[0].Referral_In_Rs__c);
            }else{
                gen.writeNumberField('inv_amt',0);
            }
            //   gen.writeStringField('inv_no','123456');
            if(RcList1[0].Booking__r.Customer__r.SalesOrder_Number__c != Null ){
                gen.writeStringField('inv_no',RcList1[0].Booking__r.Customer__r.SalesOrder_Number__c);
            }else{
                gen.writeStringField('inv_no','');
            }
            if(RcList1[0].Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c!= Null ){
                gen.writeStringField('bukrs',RcList1[0].Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c);
            }else{
                gen.writeStringField('bukrs','');
            }
            gen.writeStringField('ref_text',RcList1[0].long_text1__c);
            gen.writeEndObject();
            // Get the JSON string.
            body += gen.getAsString();
            system.debug('body:: ' + body);
            /* Calling Post method to push data */
            
            Httprequest request = new HttpRequest();                      
            request.setMethod('POST');
            request.setEndpoint(endPointURL); 
            request.setHeader('authorization', authorizationHeader);
            request.setHeader('content-type', 'text/plain'); /// application/json
            request.setBody(body);          
            ResponseData responseBody = new ResponseData();
            String failureResponseData = '';
           // if(!Test.isRunningTest()){
                try{
                    //Making call to external REST API
                    HttpResponse response = http1.send(request); 
                    System.debug('Response Body: ' + (response.getBody()));                   
                    //jsonResponse = ReferralCreditCreationParser.parse(responseBody);
                    responseBody = (ResponseData)JSON.deserialize(response.getBody(), ResponseData.class);
                    if(responseBody.STATUS == 'Failure'){
                        System.debug('Failure Response');
                        failureResponseData = response.getBody();
                    }else if(responseBody.STATUS == 'Success'){
                        System.debug('Success Response');
                    }
                    system.debug('jsonResponse Body :: ' + responseBody);
                    system.debug('jsonResponse Body Status :: ' + responseBody.STATUS);
                    system.debug('StatusCode : '+ response.getStatusCode());                  
                    
                    if(responseBody.DOCUMENT_NO != null)
                    	sapdocno = String.valueOf(responseBody.DOCUMENT_NO);
                    if(responseBody.DOCUMENT_DT != null)
                    	sapdocdate = String.valueOf(responseBody.DOCUMENT_DT);
                    if(responseBody.LIFNR != null)
                    	VendorNo = String.valueOf(responseBody.LIFNR);
                    
                    if(response.getStatusCode() == 200 && responseBody.STATUS == 'Success'){
                        Account acc = New Account();
                        acc.id =lstApplicant[0].Booking__r.Customer__r.AccountId;
                        if((acc.Vendor_Code__c == Null ||   acc.Vendor_Code__c == '') && VendorNo != ''){
                            acc.Vendor_Code__c =  VendorNo;
                        }
                        update acc;
                        Referral_Credits__c Rc = New Referral_Credits__c();
                        List<Referral_Credits__c> RcList = [Select Id,name,Vendor_Code__c,SAP_Document_No__c,SAP_Document_Date__c,Reference_Booking__c,Date_Error_Fixed__c From Referral_Credits__c Where Id =: referralCreditId];
                        Rc.Reference_Booking__c = Refbookingids;
                        if( Rc.SAP_Document_No__c== Null && sapdocno != ''){
                            Rc.SAP_Document_No__c = sapdocno;
                        }
                        if( Rc.Vendor_Code__c== Null && VendorNo != ''){
                            Rc.Vendor_Code__c = VendorNo;
                        }
                        if(sapdocdate != '')
                        	Rc.SAP_Document_Date__c =  Date.valueOf(sapdocdate);
                        Rc.Id =RcList[0].id;
                        update Rc;
                        api.API_Name__c = 'Referral Credit API';
                        api.Request__c = body;
                        api.Response__c = String.valueOf(responseBody);
                        system.debug('API Response : '+api.Response__c);
                        api.Status__c = 'Success';  
                        api.Referral_Credit__c = RcList1[0].id;
                        
                    }
                    else{
                        api.API_Name__c = 'Referral Credit API';
                        api.Request__c = body;
                        api.Response__c = failureResponseData;
                        system.debug('API Response : '+api.Response__c);
                        api.Status__c = 'Failure';
                        api.Referral_Credit__c = RcList1[0].id;                       
                    }  
                }
                catch(Exception e){
                    system.debug('api request in catch:: ' + e);
                    api.Request__c = body;
                    api.Status__c = 'Failure';
                    //api.Response__c = String.valueOf(jsonResponse);
                    if(failureResponseData != ''){}
                    	api.Response__c = failureResponseData;
                    system.debug('API Response : '+api.Response__c);
                    system.debug('Error at Line No:: ' + e.getLineNumber());
                    api.Referral_Credit__c = RcList1[0].id;
                }
                if(api != null){
                    APIlogsToInsertList.add(api);
                }
                if(APIlogsToInsertList.size()>0){
                    insert APIlogsToInsertList;
                }
          //  }
            
        }
        
        
    }
    
    public class ResponseData{
        public String LIFNR;
        public String DOCUMENT_NO;
        public String DOCUMENT_DT;
        public String ERR_TEXT;
        public String BROKER_CD;
        public String STATUS;        
    } 
    
}