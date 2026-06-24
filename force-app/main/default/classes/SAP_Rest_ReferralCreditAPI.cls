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
        /**Added for Referral Credit Changes starts */
        System.debug('referralCreditId**'+referralCreditId);
        Id recordId = referralCreditId[0];
        String sObjectType = recordId.getSObjectType().getDescribe().getName();

        System.debug('Object Name: ' + sObjectType);
        /**Added for Referral Credit Changes ends */

        // List<Referral_Credits__c> RcList1 = [Select Id,name,Referral_In_Rs__c,Name_of_New_Customer__c,Reference_Booking__r.Name,Reference_Booking__c,long_text1__c,Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c,
        //                                              Booking__r.Customer__r.SalesOrder_Number__c  From Referral_Credits__c Where Id IN: referralCreditId and Approval_Status__c = 'Approved']; //Added Approval_Status__c for Referral Credit Changes
        
        
        String query = 'SELECT Id, Name, Referral_In_Rs__c, Reference_Booking__c, long_text1__c, ' +
                       'Reference_Booking__r.Tower__r.Legal_Entity__r.RDS_Company_Code__c, ' +
                       'Booking__r.Customer__r.SalesOrder_Number__c, Booking__r.Customer__r.AccountId,'+
                       'CLR_Document_Number__c, Invoice_Document_Number__c,Booking__r.Referral_Amount__c,'+
                       'Booking__r.Customer__r.Opt_for_Referral__c ,Booking__r.Customer__r.SAP_Customer_Number__c' +
                       ' FROM ' + sObjectType + ' ' +
                       'WHERE Id IN :referralCreditId AND Approval_Status__c = \'Approved by L2\'';
        
        List<SObject> RcList1 = Database.query(query);
        if (RcList1.isEmpty()) return;

        SObject mainRec = RcList1[0];
        Id Refbookingids = (Id)mainRec.get('Reference_Booking__c');

        system.debug('RcList1::'+RcList1);         
        system.debug('RcList1 size::'+RcList1.size()); 
        //Id Refbookingids = RcList1[0].Reference_Booking__c;
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
            //Http http = new Http();
            Http http1 = new Http();
            
            String username = Label.SAP_Username;
            String password = Label.SAP_Password;
            //String endPointURL = Label.SAP_Referral_Credit_API_Endpoint;
            String endPointURL = Label.SAP_Referral_API_Endpoint;//Added for Refrral Credit Changes
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            
            String sapdocno = '';
            String sapdocdate = '';
            String VendorNo = '';
            String financialYear = '';
            String invDocNumber = '';
            String clrDocNumber = '';
            String finYear = '';
            
            /* Calling get method for Authentication */            
            JSONGenerator gen = JSON.createGenerator(true);

            /**Added for Referral Credit Changes starts */

            gen.writeStartObject(); 
            gen.writeFieldName('ADF_CRN');
            gen.writeStartArray(); 
            gen.writeStartObject();
            
            String apiName = '';
            String headerText = '';
            String customerNumber = '';
            if(sObjectType == 'Referral_Credits__c'){
                apiName = 'REFERRAL';
                headerText = 'Referral Credit';
                if(lstApplicant[0].Opportunity__r.SAP_Customer_Number__c!= Null && lstApplicant[0].Opportunity__r.SAP_Customer_Number__c !=''){
                    customerNumber = lstApplicant[0].Opportunity__r.SAP_Customer_Number__c;
                }
            }
            else if(sObjectType == 'Credit_Note__c'){
                apiName = 'VOUCHER';
                headerText = 'Credit Note';

                if(mainRec.getSObject('Booking__r') != null &&
                mainRec.getSObject('Booking__r').getSObject('Customer__r') != null) {

                    customerNumber = (String) mainRec
                        .getSObject('Booking__r')
                        .getSObject('Customer__r')
                        .get('SAP_Customer_Number__c');
                }
            }
            gen.writeStringField('Api_Name', apiName);

            gen.writeStringField('sCurrency', 'INR');
            gen.writeStringField('Ref_Doc_No', (String)mainRec.get('Name'));
            gen.writeStringField('Pstng_Date', '');//20260325
            gen.writeStringField('Item_Text', (String)mainRec.get('long_text1__c'));
            gen.writeStringField('Header_Txt', headerText);
            gen.writeStringField('Fisc_Year', '');
            gen.writeStringField('Doc_Date', '');//20260425
            gen.writeStringField('Customer', customerNumber != null ? customerNumber : '');
            // if(lstApplicant[0].Opportunity__r.SAP_Customer_Number__c!= Null && lstApplicant[0].Opportunity__r.SAP_Customer_Number__c !=''){
            //     gen.writeStringField('Customer',lstApplicant[0].Opportunity__r.SAP_Customer_Number__c!= null ? lstApplicant[0].Opportunity__r.SAP_Customer_Number__c : '');
            // }

            String companyCode = '';
            SObject refBooking = mainRec.getSObject('Reference_Booking__r');
            if(refBooking != null) {
                SObject tower = refBooking.getSObject('Tower__r');
                if(tower != null) {
                    SObject legalEntity = tower.getSObject('Legal_Entity__r');
                    if(legalEntity != null) companyCode = (String)legalEntity.get('RDS_Company_Code__c');
                }
            }
            gen.writeStringField('Comp_Code', companyCode != null ? companyCode : '');

            // Decimal amount;
            // if(mainRec.get('Referral_In_Rs__c')!= Null ){
            //      amount = (Decimal)mainRec.get('Referral_In_Rs__c');
                
            // }

            Decimal amount;

            // Boolean optForReferral = (Boolean) mainRec.getSObject('Booking__r.Customer__r')
            //                                         .get('Opt_for_Referral__c');


            SObject booking = mainRec.getSObject('Booking__r');
            SObject customer = booking != null ? booking.getSObject('Customer__r') : null;

            Boolean optForReferral = customer != null 
                ? (Boolean) customer.get('Opt_for_Referral__c') 
                : false;
                                                    
            if (optForReferral == true) {
                if (mainRec.get('Referral_In_Rs__c') != null) {
                    amount = (Decimal) mainRec.get('Referral_In_Rs__c');
                }
            } else {
                if (mainRec.getSObject('Booking__r') != null &&
                    mainRec.getSObject('Booking__r').get('Referral_Amount__c') != null) {
                    
                    amount = (Decimal) mainRec.getSObject('Booking__r')
                                            .get('Referral_Amount__c');
                }
            }


            gen.writeNumberField('Amount', amount != null ? amount : 0);

            gen.writeStringField('TDS_Amount', '');

            gen.writeEndObject();
            gen.writeEndArray(); 
            gen.writeEndObject(); 

            /**Added for Referral Credit Changes ends */

            // Get the JSON string.
            body += gen.getAsString();
            system.debug('body:: ' + body);
            
            /**Added for Referral Credit Changes starts */
            String csrf_token = 'fetch';
            HttpRequest csrfReq = new HttpRequest();
            csrfReq.setMethod('HEAD');
            csrfReq.setEndpoint(endPointURL);
            csrfReq.setHeader('Authorization', authorizationHeader);
            csrfReq.setHeader('Content-Type', 'application/json');
            csrfReq.setHeader('x-csrf-token', csrf_token);

            Http http = new Http();
            HttpResponse csrfRes = http.send(csrfReq);

            String csrfToken = csrfRes.getHeader('x-csrf-token');
            String cookie = csrfRes.getHeader('Set-Cookie');

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointURL);
            request.setMethod('POST');
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('content-type', 'application/json');
            request.setHeader('x-csrf-token', csrfToken);
            request.setHeader('Cookie', cookie);
            request.setHeader('Connection', 'keep-alive');
            request.setBody(body);
            /**Added for Referral Credit Changes ends */

            ResponseData responseBody = new ResponseData();
            String failureResponseData = '';
           // if(!Test.isRunningTest()){
                try{
                    HttpResponse response = http1.send(request); 
                    System.debug('Response Body: ' + (response.getBody()));                   
                    responseBody = (ResponseData)JSON.deserialize(response.getBody(), ResponseData.class);
                    
                    if(responseBody != null && responseBody.FRECORD != null && !responseBody.FRECORD.isEmpty()){

                        FRecord rec = responseBody.FRECORD[0];
                        System.debug('Record Status :: ' + rec.STATUS);

                        if(rec.STATUS == 'Failure'){
                            System.debug('Failure Response');
                            failureResponseData = response.getBody();
                        } 
                        else if(rec.STATUS == 'Success'){
                            System.debug('Success Response');
                        }

                        system.debug('jsonResponse Body :: ' + responseBody);
                        system.debug('jsonResponse Body Status :: ' + responseBody.FRecord[0].STATUS);
                        system.debug('StatusCode : '+ response.getStatusCode());                  
                        
                        if(rec.CRN_DOC != null){
                            sapdocno = rec.CRN_DOC;
                        }

                        if(rec.DOC_DATE != null && rec.DOC_DATE != '0000-00-00'){
                            sapdocdate = rec.DOC_DATE;
                        }

                        if(rec.CUSTOMER != null){
                           VendorNo = rec.CUSTOMER;
                        }

                        if(rec.INV_DOC != null){
                           invDocNumber = rec.INV_DOC;
                        }

                        if(rec.CLR_DOC != null){
                           clrDocNumber = rec.CLR_DOC;
                        }

                        //if(rec.CRN_DOC_MSG != null){
                        if(!String.isEmpty(rec.CRN_DOC_MSG)){
                            String msg = rec.CRN_DOC_MSG;
                            System.debug('msg**'+msg);
                            List<String> parts = msg.split('/');
                            System.debug('parts**'+parts);
                            String yearPart = parts[2].substring(0, 4);  

                            System.debug('Year: ' + yearPart);
                            finYear = yearPart;
                        }


                        if(response.getStatusCode() == 200 && responseBody.FRECORD != null && !responseBody.FRECORD.isEmpty()&& responseBody.FRECORD[0].STATUS == 'Success'){                         

                            Account acc = New Account();
                            acc.id = lstApplicant[0].Booking__r.Customer__r.AccountId;

                            if((acc.Vendor_Code__c == null || acc.Vendor_Code__c == '') && VendorNo != ''){
                                acc.Vendor_Code__c = VendorNo;
                            }
                            update acc;

                            /** Referral Credit Changes */
                            SObject recordToUpdate = Id.valueOf(mainRec.Id).getSObjectType().newSObject(mainRec.Id);
                            System.debug('recordToUpdate**'+recordToUpdate);

                            if(sObjectType == 'Referral_Credits__c'){
                                recordToUpdate.put('SAP_Document_No__c', sapdocno);
                            }
                        
                            if(sObjectType =='Credit_Note__c'){
                                recordToUpdate.put('SAP_Document_Number__c', sapdocno);
                            }

                            recordToUpdate.put('Vendor_Code__c', VendorNo);
                            recordToUpdate.put('Invoice_Document_Number__c', invDocNumber);
                            recordToUpdate.put('CLR_Document_Number__c', clrDocNumber);
                            recordToUpdate.put('Financial_Year__c', finYear);

                            if(String.isNotBlank(sapdocdate)) {
                                recordToUpdate.put('SAP_Document_Date__c', Date.valueOf(sapdocdate));
                            }

                            System.debug('recordToUpdate1**'+recordToUpdate);
                            update recordToUpdate;

                            api.API_Name__c = 'Referral Credit API';
                            api.Request__c = body;
                            api.Response__c = response.getBody(); // better than String.valueOf(responseBody)
                            System.debug('API Response : '+api.Response__c);
                            api.Status__c = 'Success';  

                            if(sObjectType == 'Referral_Credits__c') api.Referral_Credit__c = mainRec.Id;
                            if(sObjectType == 'Credit_Note__c') api.Credit_Note__c = mainRec.Id;
                        }
                    
                        else{
                            api.API_Name__c = 'Referral Credit API';
                            api.Request__c = body;
                            api.Response__c = response.getBody();
                            system.debug('API Response : '+api.Response__c);
                            api.Status__c = 'Failure';
                            if(sObjectType == 'Referral_Credits__c') api.Referral_Credit__c = mainRec.Id;
                            if(sObjectType == 'Credit_Note__c') api.Credit_Note__c = mainRec.Id;
                            // api.Referral_Credit__c = RcList1[0].id;                       
                        }  
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
                    if(sObjectType == 'Referral_Credits__c') api.Referral_Credit__c = mainRec.Id;
                    if(sObjectType == 'Credit_Note__c') api.Credit_Note__c = mainRec.Id;
                    // api.Referral_Credit__c = RcList1[0].id;
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

    /**Added for Referral Credit Changes starts */
    public class ResponseData {
        public String BUSINESSARE;
        public List<FRecord> FRECORD;
    }

    public class FRecord {
        public String CUSTOMER;
        public String COMP_CODE;
        public String DOC_DATE;
        public String PROJ_CODE;
        public String CRN_DOC;
        public String CRN_DOC_MSG;
        public String INV_DOC;
        public String INV_DOC_MSG;
        public String CLR_DOC;
        public String CLR_DOC_MSG;
        public String STATUS;
    }
    
    /**Added for Referral Credit Changes ends */
    
}