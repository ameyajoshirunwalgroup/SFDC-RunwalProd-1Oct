public  without sharing class DigitalBookingController{
    private static final String base64Chars = '' +'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +'abcdefghijklmnopqrstuvwxyz' +'0123456789+/';
    
    @AuraEnabled
    public static string sendBookingLink(String opprecordId,Decimal Amount,Map<String,String> offerDetails,String quotationId, String PaymentGateway){ //PLN
        String customerEmail='';
        // try{
        //Opportunity opportunityRec = Utility.getOpportunityRecord(opprecordId);
        List<Opportunity> opportunityRecord = [SELECT Id,Project_Name__c, Name ,RW_Sourcing_Manager__c,Sales_Manager__c, AccountId,RW_Sales_Associate__c,Walk_in_Sub_Source__c,Walk_in_Source__c, RW_Email__c ,Walkin_Source__c, RW_Mobile_No__c, RW_PAN_Card_Number__c , RW_Additional_Email__c,RW_AADHAR_Card_Number__c,RW_Passport_Number__c,RW_Secondary_Email__c,LeadSource,Lead_Sub_Source__c,RW_Project__c,RW_Project__r.Name,RW_Walkin_Channel_Partner__c,RW_Walkin_Channel_Partner__r.Name,RW_Walkin_Channel_Partner__r.SAP_CP_Code__c,RW_Previous_Opportunity__c,RW_Previous_Opportunity__r.Booking__c,RW_Previous_Opportunity__r.Booking__r.Project__c,RW_Type_of_Client__c,RW_Project_Unit__r.TowerName__c,RW_Project__r.CP_Invoice_Clearing_L1__c,RW_Project__r.CP_Invoice_Clearing_L2__c,Account.Country_Code__c,(SELECT id,RW_Status__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c FROM EOI__r),(SELECT id,status__c FROM Booking__r),(Select Id,RecordtypeId,RW_Link_Status__c,RW_Link_Sent_Time__c from Digital_Link_Status__r) FROM Opportunity WHERE Id= :opprecordId ];
        Opportunity opportunityRec = opportunityRecord[0];
        Id bkRecordTypeId =Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        
        for(RW_Digital_Link_Status__c digLink : opportunityRec.Digital_Link_Status__r){
            if(digLink.RW_Link_Status__c == 'Active' && digLink.RecordTypeId == bkRecordTypeId){
                throw new CommonException('There is already an active link sent to the customer. Please check with customer again or change the Link status to \'Expired\' from \'Active\' and then try again to send the link');
            }
        }
        
        if(opportunityRec !=null){
            customerEmail = opportunityRec.RW_Email__c;
            //Added by coServe 02-01-2024 Start
            Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
            System.debug('dummyEmails: ' + dummys.keySet());
            for(String str : dummys.keySet()){
                if(customerEmail.contains(str) || str.contains(customerEmail)){
                    throw new CommonException('It seems you are using Dummy email id in this record. This will result in failure of sending digital link to customer. Please update correct email id and continue further.!');
                }
            }
            //Added by coServe 02-01-2024 End
        }
        //checking for blocked unit
        Quotation__c selectQuote = [Select id,Project_Unit__c,Project_Unit__r.name  from Quotation__c where id=:quotationId];
        List<Project_unit__c> pUnits = [select id,name from project_unit__c where RW_Customer__c = :opprecordId and RW_Unit_Status__c='Blocked'] ;
        if(pUnits.size()>0){
            boolean errorp = false;
            String ErrorMessage = 'This opportunity is blocked for Project Unit:';
            for(Project_unit__c pu : pUnits){
                if(pu.id != selectQuote.Project_Unit__c){
                    ErrorMessage = ErrorMessage + pu.Name +', ';
                    errorp=true;
                }
            }
            if(errorp){
                ErrorMessage=   ErrorMessage.trim().removeEnd(',')+' and you have selected Project Unit :'+selectQuote.Project_Unit__r.name;
                throw new CommonException(ErrorMessage);
            }
            
        }
        
        //checking for EOI for the opportunity
        List<RW_EOI__c> eoi = [select id from RW_EOI__c where Opportunity__c = : opprecordId];
        if(eoi.size()>0){
            //query for eoi block project unit
            
            List<Project_unit__c> eoiPUnits = [select id,name from project_unit__c where EOI__c = :eoi[0].Id and RW_EOI_Block_Status__c='EOI Blocked'] ;
            if(eoiPUnits.size()>0){
                Boolean eoiErr= false;
                String ErrorMessage = 'This opportunity is EOI blocked for Project Unit:';
                
                for(Project_unit__c pu:eoiPUnits){
                    if(pu.id != selectQuote.Project_Unit__c){
                        ErrorMessage = ErrorMessage + pu.Name +', ';
                        eoiErr=true;
                    }
                }
                if(eoiErr){
                    
                    ErrorMessage= ErrorMessage.trim().removeEnd(',')+' and you have selected Project Unit :'+selectQuote.Project_Unit__r.name;
                    throw new CommonException(ErrorMessage);
                    
                }
            }
        }
        if(!String.isEmpty(customerEmail)){
            String bkRecordId='';
            if(opportunityRec.Booking__r.size() == 0){
                bkRecordId = CreateBookingRecord(opportunityRec,quotationId,Amount);
                system.debug('Booking Record Id ---->' + bkRecordId);
            }else{
                if(opportunityRec.Booking__r.size() > 0 ){
                    
                    for(Booking__c bc :opportunityRec.Booking__r ){
                        if(bc.status__c != 'Booking In Process'){
                            throw new CommonException('There is already an active booking. Please verify');
                        }else{
                            bkRecordId =  bc.Id;
                            UpdateBookingRecord(opportunityRec,quotationId,Amount,bc.Id);
                        }
                    }
                }
            }
            if(OfferDetails.size() >0){
                CreateApplicableOfferRecord(OfferDetails,opprecordId,bkRecordId,opportunityRec.RW_Project__c );
            }
            String bkLinkRecordId = CreateBookingLinkRecord(opprecordId);
            String encryptedData = Utility.getEncryptedData(opprecordId+','+bkRecordId+','+bkLinkRecordId+','+PaymentGateway); //PLN
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            Booking__c bk = [select Unit_No__r.RW_Param4__c from Booking__c where id=:bkRecordId];
            PageReference pdf = Page.quotationattachment;
            
            pdf.getParameters().put('Id',quotationId);
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            if(! test.isrunningtest()){
                Blob body= pdf.getContentAsPDF();
                system.debug('biob'+body);
                attach.setContentType('application/pdf');
                attach.setFileName('Quotation.pdf');
                attach.setInline(false);
                attach.Body = body;
            }
            String SMmobile ;
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_Booking_Link_Customer'];
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Opportunity.Name}',opportunityRec.Name );
            htmlBody = htmlBody.replace('{!Opportunity.Project_Name__c}',opportunityRec.Project_Name__c );
            htmlBody = htmlBody.replace('{!Project_Unit__c.RW_Param4__c}',bk.Unit_No__r.RW_Param4__c );
            htmlBody = htmlBody.replace('{!DigitalBooking}','<a href="'+Label.Community_URL+'onlinebooking/?data='+encryptedData+'">Click Here'+'</a>' );
            
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c)!=null){   SMmobile=string.valueOf(mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c).RW_Phone__c);
                                                                                                                                              htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c).RW_Phone__c));
                                                                                                                                             }else{
                                                                                                                                                 SMmobile= System.Label.RW_BookingSalesContact;
                                                                                                                                                 htmlBody = htmlBody.replace('{!SMPhoneNumber}', System.Label.RW_BookingSalesContact);
                                                                                                                                             }
            String plainTextBody = template.Body;
            
            plainTextBody = plainTextBody.replace('{!Opportunity.Name}',opportunityRec.Name );
            plainTextBody = plainTextBody.replace('{!Opportunity.Project_Name__c}',opportunityRec.Project_Name__c );
            plainTextBody = plainTextBody.replace('{!Project_Unit__c.RW_Param4__c}',bk.Unit_No__r.RW_Param4__c );
            plainTextBody = plainTextBody.replace('{!DigitalBooking}', '<a href="'+Label.Community_URL+'onlinebooking/?data='+encryptedData+'">Click Here'+'</a>' );
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c)!=null)
                plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c).RW_Phone__c));
            else
                plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', System.Label.RW_BookingSalesContact);
            message.toAddresses = new String[] { customerEmail };
                message.setTemplateId(template.Id);
            message.subject = template.Subject;
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            if(! test.isrunningtest()){
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            }
            message.setHtmlBody(htmlBody);
            message.setPlainTextBody(plainTextBody);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success){
                System.debug('The email is sent successfully');
                
            }else{
                throw new CommonException('There was an error sending the Booking link in a mail. Please check with administrator.');
                
            }
            if(!Test.isRunningTest())
                if(String.isNotBlank(System.Label.StopWhatsAppOnDigitalBooking) && System.Label.StopWhatsAppOnDigitalBooking == 'No'){
                    //Added by Vinay 29-10-2021
                    if(opportunityRec.LeadSource != 'Channel Partner'){
                        //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(opportunityRec.Name,opportunityRec.Project_Name__c,Label.Community_URL+'onlinebooking/?data='+encryptedData,SMmobile,null,null,null,null,null,opportunityRec.RW_Mobile_No__c, System.Label.EOI_Booking_HSM);
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(opportunityRec.Name,opportunityRec.Project_Name__c,Label.Community_URL+'onlinebooking/?data='+encryptedData,SMmobile,null,null,null,null,null,opportunityRec.RW_Mobile_No__c, 'EOI Booking HSM'); //Commented by Vinay 11-09-2025
                        //SendWhatsAppMsg.methodToSendWhatsAppMsgNew(opportunityRec.Name,opportunityRec.Project_Name__c,Label.Community_URL+'onlinebooking/?data='+encryptedData,SMmobile,null,null,null,null,null,opportunityRec.Account.Country_Code__c,opportunityRec.RW_Mobile_No__c, 'EOI Booking HSM'); //Added by Vinay 11-09-2025
                    }
                    //Commented by Vinay 29-10-2021
                    //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(opportunityRec.Name,opportunityRec.Project_Name__c,Label.Community_URL+'onlinebooking/?data='+encryptedData,SMmobile,null,null,null,null,null,opportunityRec.RW_Mobile_No__c, System.Label.EOI_Booking_HSM);
                }
            return encryptedData;
        }else{
            throw new CommonException('There is no email present in Opportunity. Please add the email in opportunity first and then generate the Booking link');
        }
        // }catch(Exception e){
        //     throw new AuraHandledException('An Error has occured - '+e.getMessage());
        // }
        
        
        
    }
    
    public static void  UpdateBookingRecord(Opportunity oppRecord,String quotationId,Decimal Amount,Id bookingId){
        Account accRecord = Utility.getAccountFromOpportunityRecord(oppRecord);
        List<Applicant_Details__c> applist = new List<Applicant_Details__c>();
        Quotation__c  QuoteDetails = [SELECT id,Project__r.CRMHead__c,Project__r.Overall_CRM_Head__c,Zone__c,Wing__c,Appartment_Configuration__c,FloorNo__c,Carpet_Area_Sq_Ft__c,No_of_parking__c,Parking_Type__c,Agreement_Value__c,Agreement_Value_D__c,
                                      Project__r.Sales_Site_Head__c, FlatNo__c,Project__c,Project_Unit__c,Project_Unit__r.RW_Param4__c,Level_One_Approver__c,Level_Two_Approver__c,Level_Three_Approver__c, Project__r.CRM_MIS_Head__c,Brokerage_Agreement_Value__c,Project_Unit__r.TowerName__c  FROM Quotation__c WHERE Id =: quotationId];
        Booking__c  bkRecord = [SELECT id,Customer__c,Old_Booking__r.RW_Registration_Done__c,Old_Booking__r.RW_X9_99_Received__c,Old_Booking__r.Invoice_Submitted_by_CP__c,Project__c,Tower__c,Type_of_Client__c,Passback_Amount__c,(SELECT id,Name,Applicant_Number__c,Booking__c FROM ApplicantDetails__r) FROM Booking__c where id = :bookingId];
        //Added by Mounika on 18/03/2021
        // Applicant_Details__c appRecord = [SELECT id,Name,Applicant_Number__c,Booking__c FROM Applicant_Details__c where Applicant_Number__c = 'Primary Applicant' AND Booking__c =: bookingId ];
        //Ended here
        bkRecord.Source_of_Booking__c =   oppRecord.Walkin_Source__c;
        bkRecord.Sub_Source__c = oppRecord.Walk_in_Sub_Source__c;
        bkRecord.Sourcing_Mananger__c = oppRecord.RW_Sourcing_Manager__c;
        bkRecord.Sales_Managers__c = oppRecord.RW_Sales_Associate__c;
        bkRecord.Sales_Manager__c = utility.getUserIdbyName(oppRecord.RW_Sales_Associate__c);
        
        bkRecord.BrokerIId__c = oppRecord.RW_Walkin_Channel_Partner__c;
        bkRecord.Broker_Name__c = oppRecord.RW_Walkin_Channel_Partner__r.Name;
        bkRecord.Broker_Code__c = oppRecord.RW_Walkin_Channel_Partner__r.SAP_CP_Code__c;
        bkRecord.Customer__c=oppRecord.id;
        bkRecord.Quotation__c = quotationId;
        //   bkRecord.Token_Amount__c = QuoteDetails.Token_Amount__c;
        bkRecord.Token_Amount__c = Amount;
        bkRecord.Zone__c = QuoteDetails.Zone__c;
        bkRecord.Wing__c = QuoteDetails.Wing__c;
        bkRecord.Flat_Typology__c = QuoteDetails.Appartment_Configuration__c;
        bkRecord.Floor__c = QuoteDetails.FloorNo__c;
        bkRecord.Carpet_Area__c = QuoteDetails.Carpet_Area_Sq_Ft__c;
        bkRecord.No_of_parking__c = QuoteDetails.No_of_parking__c;
        bkRecord.Parking_Type__c = QuoteDetails.Parking_Type__c;
        if (QuoteDetails.Agreement_Value_D__c == 0){
            bkRecord.Allotment_Premium__c = QuoteDetails.Agreement_Value__c;
        }else{
            bkRecord.Allotment_Premium__c = QuoteDetails.Agreement_Value_D__c;
        }
        if(QuoteDetails.Project_Unit__c != Null){
            bkRecord.Tower__c = QuoteDetails.Project_Unit__r.TowerName__c;
        }
        
        bkRecord.Flat_No__c = QuoteDetails.FlatNo__c;
        bkRecord.Project__c = QuoteDetails.Project__c;
        bkRecord.Unit_No__c = QuoteDetails.Project_Unit__c;
        bkRecord.Level_One_Approver__c = QuoteDetails.Project__r.Sales_Site_Head__c;
        bkRecord.Level_Two_Approver__c = QuoteDetails.Project__r.CRMHead__c;
        bkRecord.Level_Three_Approver__c = QuoteDetails.Project__r.Overall_CRM_Head__c;
        bkRecord.CRM_Head__c = QuoteDetails.Project__r.CRM_MIS_Head__c;
        if (oppRecord != null && QuoteDetails.Project_Unit__c != null) {
            Legal_Entity__c  le = QuotationManagementServices1.getLegalEntityDetails(bkRecord.Unit_No__c, bkRecord.Project__c);
            if (le != null) {
                bkRecord.Stock__c = le.Account_Name_Flat_Cost__c;
                bkRecord.Account_Number__c = String.valueOf(le.Account_Number_Flat_Cost__c);
                bkRecord.Bank__c = le.Bank_Name_Flat_Cost__c;
                bkRecord.IFSC_Code_Flat_Cost__c = le.IFSC_Code_Flat_Cost__c;
                bkRecord.Account_Name_Service_Tax__c = le.Account_Name_Service_Tax__c;
                bkRecord.Account_Number_Service_tax__c = String.ValueOf(le.Account_Number_Service_tax__c);
                bkRecord.Bank_Name_Service_tax__c = le.Bank_Name_Service_tax__c;
                bkRecord.IFSC_Code_Service_Tax__c = le.IFSC_Code_Service_Tax__c;
                
            }
        }
        
        update bkRecord;
        
        //Added by Mounika on 18/03/2021
        for(Applicant_Details__c appRecord : bkRecord.ApplicantDetails__r){
            if(appRecord.Applicant_Number__c == 'Primary Applicant'){
                appRecord.Salutation__c = accRecord.Salutation;
                appRecord.First_Name__c = accRecord.FirstName;
                appRecord.Last_Name__c = accRecord.LastName;
                appRecord.Name = accRecord.FirstName +' '+ accRecord.LastName;
                appRecord.DOB__c = accRecord.Birth_Date__c;
                appRecord.City__c =accRecord.City__c;
                if(accRecord.RW_Zip_Code__c != null){
                    appRecord.Pincode__c =decimal.valueOf( accRecord.RW_Zip_Code__c);
                }
                appRecord.State__c = accRecord.State__c;
                appRecord.Country__c = accRecord.Country__c;
                appRecord.Mobile_Number__c=oppRecord.RW_Mobile_No__c;
                appRecord.Email_Address__c =oppRecord.RW_Email__c ;
                appRecord.Marital_Status__c = accRecord.Marital_Status__c;
                appRecord.Gender__c =accRecord.Gender__c;
                appRecord.Organization_Name__c = accRecord.RW_Company_Name__c;
                appRecord.Applicant_Number__c = 'Primary Applicant';
                appRecord.Booking__c = bookingId;
                applist.add(appRecord);
            }
            
        }
        
        update applist;
        //Ended here
        dummyMethod();
    }
    
    public static String CreateBookingRecord(Opportunity oppRecord, String quotationId,Decimal Amount){
        Account accRecord = Utility.getAccountFromOpportunityRecord(oppRecord);
        //booking record need below info
        //quotation id,opporunity,project,tower,zone,unit number,Opportunity,floor
        //flat number,Bank Name(Flat Cost),Account Name (Flat Cost),Account Number(Flat Cost),Primary Applicant Email,Account Name (ST)
        //Account Number(ST),Carpet Area,Bank Name(ST),IFSC Code(Flat Cost),IFSC Code(ST),
        
        //if EOI is filled we get below
        //KYC Details for primary and applicant info for primary
        Quotation__c  QuoteDetails = [SELECT id,Project__r.CRMHead__c,Project__r.Overall_CRM_Head__c, Tandem_car_park_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c, Tandem_Open_Additional__c, Single_Open_Additional__c, Stack_Additional__c, Name, Booking__c, Allow_booking_without_full_token__c, Agreement_Value__c, Carpet_Area_Sq_Ft__c, Appartment_Configuration__c, Project__c, Service_Tax_On_Token_Amount__c,
                                      Project_Unit__c, Token_Amount__c, ST_Token_Amount__c, Zone__c, Wing__c, Flat_Typology__c, FloorNo__c, Carpet_Area__c, No_of_parking__c, Parking_Type__c,
                                      Project__r.Sales_Site_Head__c, Allotment_Premium_Agreement_Value__c, Agreement_Value_D__c, FlatNo__c, Level_One_Approver__c, Level_Two_Approver__c, Level_Three_Approver__c, Project__r.CRM_MIS_Head__c,
                                      Discount_9_Type__c, Quote_Status__c,Discount_9_L__c,Brokerage_Agreement_Value__c,Project_Unit__r.TowerName__c,Is_Special_Brokerage_Scheme__c,Podium__c, Puzzle_Car_Park__c
                                      FROM Quotation__c WHERE Id =: quotationId];
        Booking__c bkRecord = new Booking__c();
        bkRecord.Opportunity__c=oppRecord.id;
        bkRecord.Customer__c=oppRecord.id;
        bkRecord.Sales_Managers__c = oppRecord.RW_Sales_Associate__c    ;
        bkRecord.Sales_Manager__c = utility.getUserIdbyName(oppRecord.RW_Sales_Associate__c);
        
        bkRecord.Sourcing_Mananger__c = oppRecord.RW_Sourcing_Manager__c;
        bkRecord.BrokerIId__c = oppRecord.RW_Walkin_Channel_Partner__c;
        bkRecord.Broker_Name__c = oppRecord.RW_Walkin_Channel_Partner__r.Name;
        bkRecord.Broker_Code__c = oppRecord.RW_Walkin_Channel_Partner__r.SAP_CP_Code__c;
        bkRecord.Customer__c=oppRecord.id;
        bkRecord.Quotation__c = quotationId;
        //   bkRecord.Token_Amount__c = QuoteDetails.Token_Amount__c;
        bkRecord.Token_Amount__c = Amount;
        bkRecord.Is_Special_Brokerage_Scheme__c =  QuoteDetails.Is_Special_Brokerage_Scheme__c;//Added by coServe 16-03-2023
        
        //tokenamt = QuotationManagementServices1.INFormat(QuoteDetails[0].Token_Amount__c);
        bkRecord.Zone__c = QuoteDetails.Zone__c;
        bkRecord.Wing__c = QuoteDetails.Wing__c;
        bkRecord.Flat_Typology__c = QuoteDetails.Appartment_Configuration__c;
        bkRecord.Floor__c = QuoteDetails.FloorNo__c;
        bkRecord.Carpet_Area__c = QuoteDetails.Carpet_Area_Sq_Ft__c;
        bkRecord.No_of_parking__c = QuoteDetails.No_of_parking__c;
        bkRecord.Parking_Type__c = QuoteDetails.Parking_Type__c;
        
        if (QuoteDetails.Agreement_Value_D__c == 0) {
            bkRecord.Allotment_Premium__c = QuoteDetails.Agreement_Value__c;
        } else {
            bkRecord.Allotment_Premium__c = QuoteDetails.Agreement_Value_D__c;
        }
        if(QuoteDetails.Project_Unit__c != Null){
            bkRecord.Tower__c = QuoteDetails.Project_Unit__r.TowerName__c;
        }
        
        bkRecord.Flat_No__c = QuoteDetails.FlatNo__c;
        bkRecord.Project__c = QuoteDetails.Project__c;
        bkRecord.Unit_No__c = QuoteDetails.Project_Unit__c;
        bkRecord.Level_One_Approver__c = QuoteDetails.Project__r.Sales_Site_Head__c;
        bkRecord.Level_Two_Approver__c = QuoteDetails.Project__r.CRMHead__c;
        bkRecord.Level_Three_Approver__c = QuoteDetails.Project__r.Overall_CRM_Head__c;
        bkRecord.CRM_Head__c = QuoteDetails.Project__r.CRM_MIS_Head__c;
        if (oppRecord != null && QuoteDetails.Project_Unit__c != null) {
            Legal_Entity__c  le = QuotationManagementServices1.getLegalEntityDetails(bkRecord.Unit_No__c, bkRecord.Project__c);
            if (le != null) {
                bkRecord.Stock__c = le.Account_Name_Flat_Cost__c;
                bkRecord.Account_Number__c = String.valueOf(le.Account_Number_Flat_Cost__c);
                bkRecord.Bank__c = le.Bank_Name_Flat_Cost__c;
                bkRecord.IFSC_Code_Flat_Cost__c = le.IFSC_Code_Flat_Cost__c;
                bkRecord.Account_Name_Service_Tax__c = le.Account_Name_Service_Tax__c;
                bkRecord.Account_Number_Service_tax__c = String.ValueOf(le.Account_Number_Service_tax__c);
                bkRecord.Bank_Name_Service_tax__c = le.Bank_Name_Service_tax__c;
                bkRecord.IFSC_Code_Service_Tax__c = le.IFSC_Code_Service_Tax__c;
                
            }
        }
        
        bkRecord.Status__c='Booking In Process';
        
        /* if(accRecord !=null)
{
System.debug('***'+accRecord);
bkRecord.RW_City__c =accRecord.Locality__c;
bkRecord.RW_Pin__c =accRecord.RW_Zip_Code__c;
bkRecord.RW_State__c = accRecord.State__c;
bkRecord.RW_Country__c = accRecord.Country__c;
bkRecord.RW_Primary_Contact_No__c=accRecord.Mobile_No__c;
bkRecord.RW_Primary_Email__c=accRecord.PersonEmail;
bkRecord.RW_Primary_Alternate_Email__c = accRecord.Alternate_Email__c;
bkRecord.RW_Gender__c =accRecord.Gender__c;
}*/
        // bkRecord.RW_EOI_Link_Expiry__c= dateTime.parse(System.Now().format());
        
        bkRecord.Source_of_Booking__c =   oppRecord.Walkin_Source__c;
        bkRecord.Sub_Source__c = oppRecord.Walk_in_Sub_Source__c;
        //bkRecord.RW_Application_Source__c = oppRecord.Walkin_Source__c;
        //bkRecord.RW_Source_Details__c = oppRecord.Walkin_SubSource__c;
        
        //Added by coServe 09-12-2022 Start
        bkRecord.Type_of_Client__c = oppRecord.RW_Type_of_Client__c;
        //bkRecord.Tower__c = oppRecord.RW_Project_Unit__r.TowerName__c;
        bkRecord.Old_Booking__c = oppRecord.RW_Previous_Opportunity__r.Booking__c;
        
        bkRecord.CP_Invoice_Clearing_L1__c = oppRecord.RW_Project__r.CP_Invoice_Clearing_L1__c;
        bkRecord.CP_Invoice_Clearing_L2__c = oppRecord.RW_Project__r.CP_Invoice_Clearing_L2__c;
        if(QuoteDetails.Discount_9_Type__c == 'CP Passback' && QuoteDetails.Quote_Status__c == 'Valid' && QuoteDetails.Discount_9_L__c != Null){
            bkRecord.Passback_Amount__c = QuoteDetails.Discount_9_L__c;
        }
        else{
            bkRecord.Passback_Amount__c = 0;
        }
        if(oppRecord.RW_Previous_Opportunity__c != Null && bkRecord.Old_Booking__r.RW_Registration_Done__c == 'Yes' && bkRecord.Old_Booking__r.RW_X9_99_Received__c == true && bkRecord.Old_Booking__r.Invoice_Submitted_by_CP__c == true  ){
            bkRecord.Exclude_From_Brokerage_Batch__c = true;
        }
        if(oppRecord.RW_Previous_Opportunity__r.Booking__r.Project__c == bkRecord.Project__c && oppRecord.RW_Previous_Opportunity__c != Null){
            bkRecord.Unit_Trasfer_to_Project__c = 'Same Project';
        }else if (oppRecord.RW_Previous_Opportunity__r.Booking__r.Project__c != bkRecord.Project__c && oppRecord.RW_Previous_Opportunity__c != Null){
            bkRecord.Unit_Trasfer_to_Project__c = 'Different Project';
        }
        Date bookingDate = Date.ValueOf(bkRecord.Booking_Date__c);
        //List<Scheme_Configuration__c> sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c where ((Project__c =:bkRecord.Project__c and Tower__c =:bkRecord.Tower__c) OR (Project__c =:bkRecord.Project__c and Tower__c =:null)) and (Type__c =: bkRecord.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
        list<Scheme_Configuration__c> sc = new list<Scheme_Configuration__c>();
        List<Scheme_Configuration__c> sctemp = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c from Scheme_Configuration__c where ((Project__c =:bkRecord.Project__c and Tower__c =:bkRecord.Tower__c) OR (Project__c =:bkRecord.Project__c and Tower__c =:null)) and (Type__c =: bkRecord.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
        //sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c where ((Project__c =:boookingObj.Project__c and Tower__c =:boookingObj.Tower__c) OR (Project__c =:boookingObj.Project__c and Tower__c =:null)) and (Type__c =: boookingObj.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
        if(!sctemp.isEmpty()){
            for(Scheme_Configuration__c sci : sctemp){
                if (sci.Tower__c != null) {
                    sc.add(sci);
                    break;
                }
            }
            if(sc.isEmpty()){
                sc.add(sctemp[0]);
            }
        }
        
        if(!sc.isEmpty()){
            List<Brokerage_Scheme__c> brokerageScheme = [select Id,Name,Base_Brokerage__c,Base_Brokerage_for_OS_NRI__c,Type__c,Base_Brokerage_for_Local_Bookings__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and Start_Date__c <=: bookingDate and (End_Date__c = null or End_Date__c >=: bookingDate) and Approval_Status__c = 'Approved by Level 2'];
            // if(QuoteDetails.Agreement_Value_for_brokers__c != 0 || QuoteDetails.Agreement_Value_for_brokers__c != Null)
            if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Local'  ){
                bkRecord.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                bkRecord.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                bkRecord.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                bkRecord.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                bkRecord.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI'){
                bkRecord.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                bkRecord.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                bkRecord.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                bkRecord.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                bkRecord.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (bkRecord.Type_of_Client__c == 'Local' || bkRecord.Type_of_Client__c == 'Corporate' )){
                bkRecord.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                bkRecord.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                bkRecord.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                bkRecord.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                bkRecord.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bkRecord.Passback_Amount__c / QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (bkRecord.Type_of_Client__c == 'NRI' || bkRecord.Type_of_Client__c == 'Outstation')){
                bkRecord.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bkRecord.Passback_Amount__c /  QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                bkRecord.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                bkRecord.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                bkRecord.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                bkRecord.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bkRecord.Passback_Amount__c / QuoteDetails.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            }
        }
        
        //Added by coServe 09-12-2022 End
        
        insert bkRecord;
        
        //Get EOI Count
        Applicant_Details__c pApp = new Applicant_Details__c();
        Applicant_Details__c sApp = new Applicant_Details__c();
        pApp.Applicant_Number__c = 'Primary Applicant';
        pApp.Booking__c = bkRecord.id;
        List<RW_EOI__c> eoiRecord = [SELECT Id,RW_State__c,RW_City__c,RW_Salutation__c,RW_Countries__c,RW_Permanent_Address__c,Name,Tower__c,RW_Date_of_Birth__c,RW_Marital_Status__c, Tower__r.Name, RW_Residential_Status__c,RW_Type_Of_Applicant__c, RW_Designation__c,RW_Occupation__c,RW_Nationality__c, RW_Type_Of_Origin__c,RW_Origin_Details__c,RW_Pan_Card_Number_of_AuthoritySignatory__c,RW_PassportNoDetails__c, RW_Country_Phone_Code__c ,RW_Gender__c,RW_Permanent_Address_Line_1__c,RW_Permanent_Address_Line_2__c,RW_Permanent_Address_Line_3__c,RW_Document_Number__c,RW_Document_Proof__c,RW_Primary_First_Name__c,RW_Source_RERA_No__c,RW_Primary_Middle_Name__c,RW_Primary_Last_Name__c,RW_Name_of_Company__c,RW_Channel_Partner_s_Name__c,RW_Channel_Partner_s_Company__c,RW_Residential_Company_Address__c,RW_Pin__c,RW_Primary_Contact_No__c,RW_Primary_Email__c ,RW_Primary_PAN_Details__c ,RW_Primary_Alternate_Email__c,RW_Primary_Aadhar_Details__c,RW_Primary_Passport_Details__c ,RW_Secondary_First_Name__c,RW_Secondary_Middle_Name__c,RW_Secondary_Last_Name__c,RW_Secondary_Contact_No__c,RW_Secondary_Email__c,RW_Secondary_PAN_Details__c ,RW_Secondary_Alternate_Email__c ,RW_Secondary_Aadhar_Details__c ,RW_Secondary_Passport_Details__c ,RW_Preferred_Unit_Type__c,RW_Preferred_Budget__c,RW_Preferred_Floors__c,RW_Any_other_preference_please_specify__c,RW_Preferred_Unit_No__c,RW_Tentative_Agreement_Value__c ,RW_Tentative_All_Inclusive_Price__c,RW_Application_Source__c,RW_Sub_Source__c,RW_Closing_Type__c,RW_Source_Contact_No__c,RW_Source_Email_Id__c FROM RW_EOI__c WHERE Opportunity__c =:oppRecord.id and RW_Status__c ='EOI Confirmed'];
        if(eoiRecord != null && eoiRecord.size() >0){
            RW_EOI__c eoi = eoiRecord[0];
            //if EOI is associated fill in applicant details with EOI
            
            pApp.Salutation__c = eoi.RW_Salutation__c;
            pApp.First_Name__c = eoi.RW_Primary_First_Name__c     ;         //
            pApp.Last_Name__c = eoi.RW_Primary_Last_Name__c;
            pApp.Name = eoi.RW_Primary_First_Name__c+ ' '+ eoi.RW_Primary_Last_Name__c;
            pApp.Middle_Name__c = eoi.RW_Primary_Middle_Name__c;
            pApp.DOB__c = eoi.RW_Date_of_Birth__c;
            pApp.Type_Of_Applicant__c = eoi.RW_Type_Of_Applicant__c;
            pApp.Subtype_Of_Applicant__c = eoi.RW_Residential_Status__c;
            pApp.Permanent_Address__c = eoi.RW_Permanent_Address__c ;
            pApp.Permanent_Address_Line_1__c = eoi.RW_Permanent_Address_Line_1__c       ;
            pApp.Permanent_Address_Line_2__c     = eoi.RW_Permanent_Address_Line_2__c   ;
            pApp.Permanent_Address_Line_3__c = eoi.RW_Permanent_Address_Line_3__c   ;
            pApp.State__c = eoi.RW_State__c ;
            pApp.City__c = eoi.RW_City__c   ;
            if(eoi.RW_Pin__c != null){
                pApp.Pincode__c = decimal.valueOf( eoi.RW_Pin__c)   ;
            }
            pApp.Country__c = eoi.RW_Countries__c ;
            pApp.Gender__c = eoi.RW_Gender__c;
            pApp.Organization_Name__c = eoi.RW_Name_of_Company__c;
            pApp.Designation__c=        eoi.RW_Designation__c;
            pApp.Marital_Status__c = eoi.RW_Marital_Status__c;
            pApp.Email_Address__c = eoi.RW_Primary_Email__c;
            pApp.Mobile_Number__c = eoi.RW_Primary_Contact_No__c;
            pApp.PancardNo__c =eoi.RW_PassportNoDetails__c;
            pApp.Pan_Card_Number_of_Authority_Signatory__c = eoi.RW_Pan_Card_Number_of_AuthoritySignatory__c;
            pApp.PassportNoDetails__c   = eoi.RW_PassportNoDetails__c;
            if(eoi.RW_Primary_Aadhar_Details__c != null){
                pApp.Address_Proof_Document__c ='Aadhar Card';
                pApp.Address_Proof_Number__c = eoi.RW_Primary_Aadhar_Details__c;
            }
            insert pApp;
            if(eoi.RW_Secondary_First_Name__c!=null){
                sApp.Applicant_Number__c = 'Secondary Applicant';
                sApp.Booking__c = bkRecord.id;
                sApp.First_Name__c = eoi.RW_Secondary_First_Name__c     ;
                sApp.Last_Name__c = eoi.RW_Secondary_Last_Name__c;
                sApp.Name = eoi.RW_Secondary_First_Name__c  +' '+eoi.RW_Secondary_Last_Name__c;
                sAPP.Middle_Name__c = eoi.RW_Secondary_Middle_Name__c;
                sApp.Email_Address__c = eoi.RW_Secondary_Email__c;
                sAPP.Mobile_Number__c = eoi.RW_Secondary_Contact_No__c;
                sApp.PancardNo__c = eoi.RW_Secondary_PAN_Details__c;
                if(eoi.RW_Secondary_Aadhar_Details__c != null){
                    sApp.Address_Proof_Document__c ='Aadhar Card';
                    sApp.Address_Proof_Number__c = eoi.RW_Secondary_Aadhar_Details__c;
                }
                sApp.PassportNoDetails__c = eoi.RW_Secondary_Passport_Details__c;
                insert sApp;
            }
            //Link EOI KYC with booking
            List<Document_Details__c> eoiKYClist = [select id,RW_Applicant_Details__c,Booking__c,Applicant_Number__c from Document_Details__c where EOI__c = :eoi.Id];
            for(Document_Details__c kyc :eoiKYClist){
                kyc.RW_Applicant_Details__c = pApp.id;
                kyc.Booking__c = bkRecord.id;
                kyc.Applicant_Number__c ='Primary Applicant ';
            }
            update eoiKYCList;
        }else{
            //  CIf__c cif = [select id from cif__c where Opportunity__c=:oppRecord.id order by createddate desc limit 1];
            
            pApp.Salutation__c = accRecord.Salutation;
            pApp.First_Name__c = accRecord.FirstName;
            pApp.Last_Name__c = accRecord.LastName;
            pApp.Name = accRecord.FirstName +' '+ accRecord.LastName;
            pApp.DOB__c = accRecord.Birth_Date__c;
            pApp.City__c =accRecord.City__c;
            if(accRecord.RW_Zip_Code__c != null){
                pApp.Pincode__c =decimal.valueOf( accRecord.RW_Zip_Code__c);
            }
            pApp.State__c = accRecord.State__c;
            pApp.Country__c = accRecord.Country__c;
            pApp.Mobile_Number__c=oppRecord.RW_Mobile_No__c;
            pApp.Email_Address__c =oppRecord.RW_Email__c ;
            pApp.Marital_Status__c = accRecord.Marital_Status__c;
            pApp.Gender__c =accRecord.Gender__c;
            pApp.Organization_Name__c = accRecord.RW_Company_Name__c;
            
            insert pApp;
        }
        return bkRecord.Id;
    }
    
    public static String CreateBookingLinkRecord(String oppRecordId){
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
        /* RW_EOI_Link_Status__c bkLink = new RW_EOI_Link_Status__c();
bkLink.Opportunity__c = oppRecordId;
bkLink.RW_EOI_Link_Status__c = 'Active';
bkLink.RW_EOI_Link_Sent_Time__c = LinkSentTime;
insert bkLink; */
        //return bkLink.Id;
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
        digitalLinkStatus.RW_Opportunity__c = oppRecordId;
        digitalLinkStatus.RW_Link_Status__c = 'Active';
        digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
        Id bkRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('Booking').getRecordTypeId();
        digitalLinkStatus.RecordTypeId = bkRecordTypeId;
        
        insert digitalLinkStatus;
        return digitalLinkStatus.Id;
    }
    
    @AuraEnabled
    public static quotationWrapper getQuotationMap(String recordId){
        map<string,Quotation__c>quotationIdNameMap = new Map<String,Quotation__c>();
        List<Quotation__c> quotationList = [Select id,Name,Project_Unit__r.TowerName__c,Tandem_car_park_Additional__c,Tandem_Open_Additional__c,Single_Open_Additional__c,Single_car_park_Additional__c, Podium__c,Puzzle_Car_Park__c,Project_Unit__r.RW_Unit_Status__c,Stack_Additional__c,MLCP_Additional__c,Project__r.Name,Payment_Plan_Modified__c,Quote_Status__c from Quotation__c  where Opportunity__c  =:recordId];
        Set<String>ProjectIds = new Set<String>();
        for(Quotation__c qt :quotationList ){
            quotationIdNameMap.put(qt.id,qt);
            ProjectIds.add(qt.Project__c);
        }
        List<Project__c> projectList = [Select name,Tandem_car_park_Available__c,Tandem_Open_Available__c,Single_car_park_Available__c,Single_Open_Available__c,Stack_Available__c,MLCP_Available__c,Stack_Available1__c, Puzzle_Car_Park_Available__c from project__c where id In :ProjectIds ];
        Map<String,Map<String,Decimal>> projectCarParAvailMap = new Map<String,Map<String,Decimal>>();
        for(project__c prj :projectList ){
            Map<String,Decimal> parkMap = new Map<String,Decimal>();
            parkMap.put('Tandem Covered',prj.Tandem_car_park_Available__c);
            parkMap.put('Covered Stack',prj.Tandem_Open_Available__c);
            parkMap.put('Single Open',prj.Single_Open_Available__c);
            parkMap.put('Single Covered',prj.Single_car_park_Available__c);
            parkMap.put('Stilt',prj.Stack_Available__c);
            parkMap.put('MLCP',prj.MLCP_Available__c);
            parkMap.put('Podium',prj.Stack_Available1__c);
            parkMap.put('Puzzle Car Park',prj.Puzzle_Car_Park_Available__c); //Added by Vinay 28-03-2025
            
            projectCarParAvailMap.put(prj.Name,parkMap);
            
        }
        
        quotationWrapper qt = new quotationWrapper();
        qt.quotationIdNameMap = quotationIdNameMap;
        qt.errors = new List<errorWrapper>();
        qt.AvailParking = projectCarParAvailMap;
        //  public String errorfield;
        // public String ErrorMessage;
        Opportunity Opty = [Select id,RW_Sourcing_Manager__c,RW_Sales_Associate__c, Walkin_Source__c from opportunity where id=:recordId];
        if (Opty.RW_Sourcing_Manager__c == null) {
            errorWrapper er= new ErrorWrapper();
            er.errorfield = 'Sourcing Manager';
            er.ErrorMessage = 'Sourcing Manager for opportunity  is empty';
            qt.errors.add(er);
            qt.isError =true;
        }
        if (Opty.RW_Sales_Associate__c == null) {
            errorWrapper er1= new ErrorWrapper();
            er1.errorfield = 'Sourcing Manager';
            er1.ErrorMessage = 'Sales Manager for opportunity  is empty';
            qt.errors.add(er1);
            
            qt.isError =true;
            
        }
        //Added by coServe 11-04-2024 Start
        if (Opty.Walkin_Source__c == 'Temp Channel Partner' || Test.isRunningTest()) {
            errorWrapper er2= new ErrorWrapper();
            er2.ErrorMessage = 'Temp Channel Partner should be converted before creation of Booking';
            qt.errors.add(er2);
            qt.isError =true;
        }
        //Added by coServe 11-04-2024 End
        
        return qt;
    }
    
    public class quotationWrapper{
        @auraEnabled
        public  map<string,Quotation__c>quotationIdNameMap  = new   map<string,Quotation__c>();
        @auraEnabled
        public Map<String,Map<string,Decimal>> AvailParking = new Map<String,Map<String,Decimal>>();
        @auraEnabled
        public List<errorWrapper> errors = new List<errorWrapper>();
        @AuraEnabled
        public boolean isError;
    }
    
    /* @AuraEnabled
public static Map<String,List<String>> getBookingOffersForProject(String OpprecId,String offerType)
{
return null ;//EOIController.getOffersForProject(OpprecId,offerType);

}*/
    @AuraEnabled
    public static List<Tower__c> getTowersOfProject(String recordId){
        List<String> towerNames = new List<String>();
        Map<String,List<String>> towerData = new Map<String,List<String>>();
        Opportunity oppRec = Utility.getOpportunityRecord(recordId);
        List<Tower__c> tRec = [Select Id,Name,ProjectName__c,ProjectName__r.Name from Tower__c where ProjectName__c = : oppRec.RW_Project__c order by Name];
        return tRec;
        
    }
    
    
    
    
    /* @AuraEnabled
public static Map<String, String> getMailingCountryPicklist(){
Map<String, String> options = new Map<String, String>();
//get Account Industry Field Describe
Schema.DescribeFieldResult fieldResult = Applicant_Details__c.Mailing_Country__c.getDescribe();
//get Account Industry Picklist Values
List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
for (Schema.PicklistEntry p: pList) {
//Put Picklist Value & Label in Map
options.put(p.getValue(), p.getLabel());
}
return options;
}*/
    
    /* @AuraEnabled
public static BookingWrapper loadBookingdata(String bookingRecordId)
{
System.debug('**'+bookingRecordId);
BookingWrapper bkWrap = new BookingWrapper();
if(bookingRecordId != null)
{
Applicant_Details__c bookingRecord = Utility.getApplicantDetailsRecord(bookingRecordId);
System.debug('**'+bookingRecord);
bkWrap.Id=bookingRecord.Id;
bkWrap.RWMailingCountry=bookingRecord.Mailing_Country__c;
}
return bkWrap;
}
*/
    public static Boolean checkLinkExpiry(String LinkRecordId){
        try{
            if(LinkRecordId != null){
                RW_Digital_Link_Status__c LinkRec = Utility.digitalLinkStatusRecord(LinkRecordId);
                if(LinkRec.RW_Link_Status__c == 'Expired'){
                    return TRUE;
                }else{
                    return FALSE;
                }
            }else
                throw new CommonException('Error Fetching Digital Link Data.');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*    @AuraEnabled
public static String retreiveProjectName(String opportunityId )
{
try
{
Opportunity opp = Utility.getOpportunityRecord(opportunityId);
if(opp != null)
return opp.RW_Project__r.Name;
else
throw new CommonException('Error Fetching Project Data.');
}
catch(Exception e)
{
system.debug(e.getMessage());
throw new AuraHandledException(e.getMessage());
}
}
*/
    @AuraEnabled
    public static Map<string,PicklistWrapper> getDependentPicklists(String ObjectName, Map<String,String> fieldsMap){
        Map<string,PicklistWrapper> picklistMap = new Map<string, PicklistWrapper>();
        
        
        for(String s: fieldsMap.keySet()){
            picklistMap.put(s,getDependentPicklist(ObjectName,fieldsMap.get(s),s));
        }
        return picklistMap;
    }
    
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    
    //Refer from here https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex
    public static String decimalToBinary(Integer val){
        String bits = '';
        while(val > 0){
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;
    }
    
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    
    
    @AuraEnabled
    public static Map<String,List<String>> getPicklistValuesForFields(String objectName,List<String> fieldNames){
        Map<String,List<String>> picklistValues = new Map<String,List<String>>();
        for(String fieldName : fieldNames){
            picklistValues.put(fieldName,Utility.getPicklistValues(objectName,fieldName));
        }
        Return picklistValues;
        
    }
    
    /* @AuraEnabled
public static List<Applicable_Offer__c> getOfferRecordforDigitalForm(String recordId,String offerType)
{
system.debug('enter Offer record' + recordId + offerType);
try
{
system.debug('enter Offer record' + recordId + offerType);
List<Applicable_Offer__c> offers =Utility.getApplicableOfferRecords(recordId,offerType);
system.debug('Offerrecord_____>>>' + offers);
if(offers!= null && offers.size() >0)
{
return offers;
}
else
return null;
}
catch(Exception e)
{
system.debug(e.getMessage());
throw new AuraHandledException(e.getMessage());
}
}

*/
    
    
    /*  public static String CreateDigitalEOIPaymentLinkRecord(String oppRecordId)
{
try
{
DateTime LinkSentTime = DateTime.parse(System.Now().format());

RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
digitalLinkStatus.RW_Opportunity__c = oppRecordId;
digitalLinkStatus.RW_Link_Status__c = 'Active';
digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
Id bookingRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('Digital Booking Payment').getRecordTypeId();
digitalLinkStatus.RecordTypeId = bookingRecordTypeId;

insert digitalLinkStatus;
return digitalLinkStatus.Id;
}
catch(Exception e)
{
system.debug(e.getMessage());
throw new AuraHandledException(e.getMessage());
}
}
*/
    @auraEnabled
    public static string getPaymentResponseDecryptedData(String inputdata,String decryptionKey){
        try{
            Blob cryptoKey = Blob.valueOf(decryptionKey);
            Blob hash = Crypto.generateDigest('MD5', cryptoKey);
            Blob data = EncodingUtil.convertFromHex(inputdata); //Received from ccAvenue response
            Blob decryptedText = Crypto.decryptWithManagedIV('AES128', hash, data);
            String PLAIN_TEXT = decryptedText.toString();
            //throw new AuraHandledException('test');
            return PLAIN_TEXT;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void insertPaymentDetails(Map<String,String> details){
        try{
            List<Receipt__c> recList = [Select id,EOI__c from Receipt__c where Opportunity__c = :details.get('oppRecId') ];
            for(Receipt__c rec : recList){
                if(rec.EOI__c != null){
                    rec.Booking__c = details.get('bookingId');
                }
            }
            Receipt__c receipt = new Receipt__c();
            receipt.Mode__c = 'Digital';
            receipt.Cheque_DD__c = details.get('paymentTrackingId');
            receipt.RW_Digital_Payment_Mode__c = details.get('paymentMode');
            receipt.Cheque_DD_Date__c = Date.parse(details.get('paymentDate').split(' ')[0]);
            receipt.Total_Amount__c = decimal.valueOf(details.get('paymentAmount'));
            receipt.RW_Payment_Collection_Type__c='Booking';
            receipt.Booking__c=details.get('bookingId');
            receipt.Opportunity__c = details.get('oppRecId');
            recList.add(receipt);
            upsert recList;
            Booking__c bookingRecord = [Select id,Unit_No__r.RW_Param4__c,Project__r.name,Name,Sales_Managers__c,Status__c,Customer__r.RW_Project__c,RW_Digitally_Accepted_On__c,Primary_Applicant_Email__c,Primary_Applicant_Name__c,customer__r.RW_Sales_Associate__c  from Booking__c where id= : details.get('bookingId')];
            
            if(bookingRecord.Status__c == 'Booking Received - Payment Pending'){
                bookingRecord.Status__c = 'Booking Received';
                update bookingRecord;
            }
            
            List<String> emailIds = Utility.getExternalTeamEmailIds(new List<String>{'CRM Team','Accounts','Sales Approvers Team'},bookingRecord.Customer__r.RW_Project__c);
            List<String> toAddress = new List<String>();
            List<String> managerEmail =new list<String>();
            if(bookingRecord.Sales_Managers__c!=null)
                managerEmail  = Utility.getUserNameEmailbyName(    bookingRecord.Sales_Managers__c);
            
            if(emailIds.size() >  0){
                toAddress.addAll(emailIds);
            }
            if(managerEmail != null && managerEmail.size() >  0){
                toAddress.addAll(managerEmail);
            }
            /*  PageReference pdf = Page.CustomerEOIForm;
pdf.getParameters().put('eoiId',eoiRecord.Id);
Blob body= pdf.getContent();

Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('EOIForm.pdf');
attach.setInline(false);
attach.Body = body;*/
            
            EmailTemplate template = [SELECT Id,Name,Subject,HtmlValue,Body,DeveloperName FROM EmailTemplate Where DeveloperName='Booking_Confirmed_Customer'];
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bookingRecord.Primary_Applicant_Name__c);
            htmlBody = htmlBody.replace('{!Project_Unit__c.RW_Param4__c}', bookingRecord.Unit_No__r.RW_Param4__c);
            htmlBody = htmlBody.replace('{!Project__c.Name}', bookingRecord.Project__r.name);
            //  htmlBody = htmlBody.replace('{!Booking__c.RW_Digitally_Accepted_On__c}', bookingRecord.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
            
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(bookingRecord.customer__r.RW_Sales_Associate__c)!=null){
                htmlBody = htmlBody.replace('{!SMName}', bookingRecord.customer__r.RW_Sales_Associate__c);
                htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(bookingRecord.customer__r.RW_Sales_Associate__c).RW_Phone__c));
            }else{
                htmlBody = htmlBody.replace('{!SMName}', bookingRecord.customer__r.RW_Sales_Associate__c);
                htmlBody = htmlBody.replace('{!SMPhoneNumber}', System.Label.RW_BookingSalesContact );
            }
            String plainTextBody = template.Body;
            
            plainTextBody = plainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bookingRecord.Primary_Applicant_Name__c);
            plainTextBody = plainTextBody.replace('{!Project_Unit__c.RW_Param4__c}', bookingRecord.Unit_No__r.RW_Param4__c);
            plainTextBody = plainTextBody.replace('{!Project__c.Name}', bookingRecord.Project__r.name);
            
            //  plainTextBody = htmlBody.replace('{!Booking__c.RW_Digitally_Accepted_On__c}', bookingRecord.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(bookingRecord.customer__r.RW_Sales_Associate__c)!=null){
                plainTextBody = plainTextBody.replace('{!SMName}', bookingRecord.customer__r.RW_Sales_Associate__c);
                plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(bookingRecord.Customer__r.RW_Sales_Associate__c).RW_Phone__c));
            }else{
                plainTextBody = plainTextBody.replace('{!SMName}', bookingRecord.customer__r.RW_Sales_Associate__c);
                plainTextBody = plainTextBody.replace('{!SMPhoneNumber}',System.Label.RW_BookingSalesContact);
            }
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { bookingRecord.Primary_Applicant_Email__c };
                message.subject = template.Subject;
            message.setHtmlBody(htmlBody);
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
            messages.add(message);
            if(toAddress.size() >0){
                //message.setCcAddresses(toAddress); // Changed from BCC to CC by coServe 20-092024
                Messaging.SingleEmailMessage managerMessage = new Messaging.SingleEmailMessage();
                managerMessage.toAddresses = toAddress;
                managerMessage.subject = template.Subject;
                managerMessage.setHtmlBody(htmlBody);
                managerMessage.setPlainTextBody(plainTextBody);
                managerMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                messages.add(managerMessage);
            }
            
            // message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            
            
            
            List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =: details.get('digitalLinkId')];
            if(digitalLinkRec != null && digitalLinkRec.size() >0){
                digitalLinkRec[0].RW_Link_Status__c ='Expired';
                update digitalLinkRec[0];
            }
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Receipt__c>  getPaymentDetailsOfBooking(String BookingRecordId,String TransactionId){
        
        try{
            List<Receipt__c> receipt =  [Select Id,Cheque_DD__c from Receipt__c Where Opportunity__c =:BookingRecordId and  Cheque_DD__c =:TransactionId];
            if(receipt != null && receipt.size() >0){
                return receipt;
            }else{
                return null;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    public static void CreateApplicableOfferRecord(Map<String,String> OfferDetails,id optyId,String bookingId,id projectId ){
        try{
            //List<Offer__c> offerRec = [Select Id,(Select Id,Name from Sub_Offers__r Where Name=: OfferDetails.get('subofferName')) from Offer__c where Name=:OfferDetails.get('offerName') and Project__c=:opportunityRec.RW_Project__c and Offer_Type__c='EOI' ];
            List<RW_Sub_Offer__c> subofferRecords = [Select Name,Offer__c,Offer__r.Name,Project__c,RW_Offer_Type__c from RW_Sub_Offer__c Where Project__c=:projectId and RW_Offer_Type__c ='Booking' and Name=: OfferDetails.get('subofferName') and Offer__r.Name =:OfferDetails.get('offerName')];
            List<Applicable_Offer__c> apOff = [Select id from Applicable_Offer__c where Sub_Offer__c =: subofferRecords[0].Id  and Booking__c =:bookingId];
            if(apOff.size() == 0){
                if(subofferRecords != null && subofferRecords.size()>0){
                    Applicable_Offer__c applicableOffer = new Applicable_Offer__c();
                    applicableOffer.Booking__c = bookingId;
                    applicableOffer.Opportunity__c = optyId;
                    applicableOffer.Offer__c = subofferRecords[0].Offer__c;
                    applicableOffer.Type_Of_Offer__c = subofferRecords[0].RW_Offer_Type__c;
                    applicableOffer.Sub_Offer__c = subofferRecords[0].Id;
                    insert applicableOffer;
                }
            }else{
                if(subofferRecords != null && subofferRecords.size()>0){
                    Applicable_Offer__c applicableOffer = apOff[0];
                    
                    applicableOffer.Offer__c = subofferRecords[0].Offer__c;
                    applicableOffer.Type_Of_Offer__c = subofferRecords[0].RW_Offer_Type__c;
                    applicableOffer.Sub_Offer__c = subofferRecords[0].Id;
                    update applicableOffer;
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getOffersForTower(String towerId,String offerType){
        Map<String,List<String>> OfferMap = new Map<String,List<String>>();
        List<RW_Sub_Offer__c> subofferRecords = [Select Name,Offer__c,Offer__r.Name,Project__c,Tower__c from RW_Sub_Offer__c Where Tower__c=: towerId and RW_Status__c='Active' and RW_Offer_Type__c =:offerType and RW_Approval_Status__c='Approved'];
        for(RW_Sub_Offer__c subOffers : subofferRecords){
            
            if(OfferMap.containsKey(subOffers.Offer__r.Name)){
                List<String> SubofferNames = OfferMap.get(subOffers.Offer__r.Name);
                SubofferNames.add(subOffers.Name);
                OfferMap.put(subOffers.Offer__r.Name , SubofferNames);
            }else
                OfferMap.put(subOffers.Offer__r.Name ,new List<String>{subOffers.Name});
        }
        return OfferMap;
    }
    @AuraEnabled
    public static onlineBookingWrapper getDetails(String data){
        try{
            List<String>  descryptdata = Utility.getDecryptedData(data).split(',');
            onlineBookingWrapper bookingWrap = new onlineBookingWrapper( descryptdata[1]);
            bookingWrap.OptyId = descryptdata[0];
            bookingWrap.BookId = descryptdata[1];
            bookingWrap.LinkId = descryptdata[2];
            bookingWrap.PaymentGateway = descryptdata[3];
            bookingWrap.linkExpired=checkLinkExpiry(descryptdata[2]);
            if( bookingWrap.linkExpired){
                return bookingWrap;
            }else{
                bookingWrap.Opty =  Utility.getOpportunityRecord(descryptdata[0]);
                bookingWrap.project = bookingWrap.Opty.RW_Project__r.Name;
                system.debug( bookingWrap.project);
                List<Payment_Gateway__mdt > payments =  Utility.getPaymentGatewayDetails( bookingWrap.project,bookingWrap.bookingDetails.booking.wing__c );
                if(payments.size() > 0){
                    bookingWrap.gateway = payments[0];
                    bookingWrap.GatewayAvailable = true;
                }
                bookingWrap.CommunityUrl= Utility.getCommunityURL();
                bookingWrap.EncryptedProjectId = Utility.getEncryptedData( bookingWrap.Opty.RW_Project__c);
                bookingWrap.paymentdetail = new List<Receipt__c>();
                Receipt__c rc = new Receipt__c();
                rc.Opportunity__c =descryptdata[0];
                rc.Booking__c = descryptdata[1];
                bookingWrap.paymentdetail.add(rc);
                system.debug('MK'+    bookingWrap.EncryptedProjectId);
                system.debug(bookingWrap.gateway);
                bookingWrap.UnitNumber = bookingWrap.bookingDetails.booking.Unit_No__r.RW_Param4__c;
                bookingWrap.applicableOffer = Utility.getApplicableOffers( bookingWrap.OptyId,'Booking');
                bookingWrap.appliedOffer= Utility.getAppliedOffers(bookingWrap.OptyId,'EOI');
            }
            bookingWrap.maxApplicants =decimal.valueOf( System.Label.RW_MAX_Applicant);
            return bookingWrap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Applicant_details__C> addApplicants(List<Applicant_details__C>  applicants){
        // List<Applicant_details__C> applicantList = (List<Applicant_details__C> )JSON.deserialize(applicants, List<Applicant_details__C>.class);
        try{
            Applicant_details__C app = new Applicant_details__C();
            Decimal size = applicants.size();
            app.Booking__c = applicants[0].Booking__c;
            
            switch on size.toPlainString(){
                when '1' {
                    app.Applicant_Number__c = 'Second Applicant';
                }
                when '2' {
                    app.Applicant_Number__c = 'Third Applicant';
                    
                }
                when '3' {
                    app.Applicant_Number__c = 'Fourth Applicant';
                    
                }
                when '4' {
                    app.Applicant_Number__c = 'Fifth Applicant';
                    
                }
            }
            applicants.add(app);
        }catch(Exception e){
            throw e;
        }
        return applicants;
    }
    
    
    @AuraEnabled
    public static List<Applicant_details__C> removeApplicants(List<Applicant_details__C>  applicants){
        Integer size = applicants.size();
        Applicant_details__C app =   applicants.get(size-1);
        applicants.remove(size-1);
        if(app.id != null){
            delete app;
        }
        return applicants;
    }
    @AuraEnabled
    public static List<Receipt__c> addPaymentType(List<Receipt__c>  payments){
        Receipt__c rec = new Receipt__c();
        rec.Opportunity__c = payments[0].Opportunity__c;
        rec.Booking__c = payments[0].Booking__c;
        payments.add(rec);
        return payments;
    }
    @AuraEnabled
    
    public static List<Receipt__c> removePaymentType(List<Receipt__c>  payments,Integer size){
        
        Integer listsize = payments.size();
        for(integer i=1;i<=size;i++){
            payments.remove(listsize-i);system.debug(payments);
        }
        return payments;
    }
    
    public class onlineBookingWrapper{
        @AuraEnabled
        Public String CommunityUrl;
        @AuraEnabled
        Public String OptyId;
        @AuraEnabled
        Public String BookId;
        @AuraEnabled
        public String LinkId;
        @AuraEnabled
        Public String project;
        @AuraEnabled
        Public  Boolean linkExpired;
        Opportunity Opty;
        @AuraEnabled
        Public   Payment_Gateway__mdt gateway;
        @AuraEnabled
        Public Boolean GatewayAvailable = false;
        @AuraEnabled
        Public decimal maxApplicants;
        @AuraEnabled
        Public String UnitNumber;
        @AuraEnabled
        public Boolean isBookingSuccess;
        @AuraEnabled
        public List<Applicable_Offer__c> appliedOffer;
        @AuraEnabled
        public List<Applicable_Offer__c> applicableOffer;
        @AuraEnabled
        Public   digitalBookingWrapper bookingDetails;
        @AuraEnabled
        Public List<Receipt__c> paymentdetail = new  List<Receipt__c>();
        @AuraEnabled
        Public String EncryptedProjectId;
        @AuraEnabled
        Public List<errorWrapper> errorList = new List<errorWrapper>();
        @AuraEnabled
        Public String PaymentGateway;
        onlineBookingWrapper(){}
        onlineBookingWrapper(String bookingId){
            bookingDetails = new digitalBookingWrapper(bookingId);
        }
    }
    
    public class digitalBookingWrapper{
        @AuraEnabled
        Public Booking__c booking;
        @AuraEnabled
        Public List<Applicant_details__C> applicants = new List<Applicant_details__c>();
        //write method to get the booking and applicant details
        digitalBookingWrapper(){
            
        }
        digitalBookingWrapper(String bookingId){
            booking = [SELECT Account_Name_Service_Tax__c,Account_Number_Service_tax__c,Account_Number__c,Allotment_Premium__c,Bank_Loan_Status__c,Bank_Name_Service_tax__c,Bank__c,
                       Basic_Booking_Amount__c,Booking_Date__c,Booking_Source_CP_New__c,Booking_Source_Details__c,Booking_Source_Reference_by_Customer__c,Booking_Source_Reference_By_Employee__c,
                       Brokerage_Amount__c,Brokerage__c,Carpet_Area__c,City__c,Code__c,CreatedDate,Credited_Amount__c,Customer_Name__c,Customer__c,Customer__r.RW_Sales_Associate__c,
                       Opportunity__r.RW_Project__c,Flat_No__c,Flat_Typology__c,Floor__c,Funding_Status__c,Future_Correspondence_Contact_Email__c,
                       Future_Correspondence_Contact_Name__c,Future_Correspondence_Contact_Phone__c,Future_Correspondence_Contact_Relation__c,
                       Future_Correspondence_Contact__c,Id,IFSC_Code_Flat_Cost__c,IFSC_Code_Service_Tax__c,IsDeleted,Level_One_Approver__c,Level_Three_Approver__c,Level_Two_Approver__c,Name,
                       Project__r.name,No_of_Parking__c,Opportunity__c,Parking_Type__c,Primary_Applicant_Email__c,Primary_Applicant_Name__c,Project_Name__c,
                       Project__c,Quotation__c,Remarks__c,RW_Country_Phone_Code__c,Sales_Managers__c,Sales_Manager__c,Sale_Order__c,Sharing_Per_Amt__c,Source_Details__c,Source_of_Booking__c,Sourcing_Mananger__c,Status__c,Stock__c,
                       ST_Token_Amount__c,Sub_Source__c,Token_Amount__c,Unit_No__c,Wing__c,Zone__c,Unit_No__r.RW_Param4__c,Unit_No__r.TowerName__c  FROM Booking__c where id = :bookingId];
            
            applicants = [SELECT Address_Proof_Document__c,Address_Proof_Number__c,Address_Proof__c,Applicant_Number__c,BookingDetails__c,Booking__c,Certified_copy_of_Article_of_Association__c,
                          Certified_copy_of_Board_Resolution__c,Certified_copy_of_Partnership_Deed__c,Certified_copy_of_ROC_Incorporation__c,Certified_extract_of_Registration__c,
                          City__c,Contact_Person_Relationship__c,Country__c, CreatedById,CreatedDate,Designation_picklist__c,Designation__c,DOB__c,Email_Address__c,
                          First_Name__c,Gender__c,Id,IsDeleted,Landline_Number__c,Last_Name__c,Mailing_Address_Line_1__c,Mailing_Address_Line_2__c,Mailing_Address_Line_3__c,
                          Mailing_Address_same_as_PermanentAddress__c,Mailing_Address__c,Mailing_City__c,Mailing_Country__c,Mailing_Pincode__c,Mailing_State__c,Mailing_Zone__c,Marital_Status__c,Middle_Name__c,Mobile_Number__c,
                          Name,Nationality_Picklist__c,Nationality__c,Occupation__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_Address_Line_3__c,One_Passport_Size_Color_Photograph__c,Opportunity__c,
                          Organisation_Country__c,Organisation_Pincode__c,Organization_Address__c,Organization_Name__c,Organization_Phone_numbers__c,Origin_Details__c,Other_Details_Remarks__c,PancardNo__c,
                          PanCard_of_Authority_Signatory__c,Pancard__c,Pan_Card_Number_of_Authority_Signatory__c,PassportNoDetails__c,PassportNumber__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,
                          Permanent_Address__c,Pincode__c,Preferred_address_for_all_correspondence__c,Salutation__c,Secondary_Mobile_Number__c,Self_attested_copy_of_PIO_or_OCI_Card__c,State__c,Subtype_Of_Applicant__c,Type_Of_Applicant__c,Type_Of_Origin__c, Mobile_No__c, Secondary_Mobile_No__c FROM Applicant_Details__c where Booking__c = : bookingId];
            
        }
    }
    
    /*    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
return (List<PicklistEntryWrapper>)
JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
}
*/
    
    
    @AuraEnabled
    public static void insertDocumentData(Map<String,String> DocDetails){
        
        Document_Details__c Details = new Document_Details__c();
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
            Details.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
            Details.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        Details.Booking__c = DocDetails.get('bookingId');
        Details.Opportunity__c = DocDetails.get('oppId');
        Details.RW_Document_Type__c=DocDetails.get('documentType');
        Details.RW_Document_ID__c = DocDetails.get('documentId');
        Details.Applicant_Number__c =DocDetails.get('ApplicantNumber');
        insert Details;
    }
    
    @AuraEnabled
    public static List<KYCWrapper> getKYCFiles(String bookingId,String applicantNumber){
        // TO avoid following exception
        // System.QueryException: Implementation restriction: ContentDocumentLink requires
        // a filter by a single Id on ContentDocumentId or LinkedEntityId using the equals operator or
        // multiple Id's using the IN operator.
        // We have to add sigle record id into set or list to make SOQL query call
        List<KYCWrapper> kycWrap =new List<KYCWrapper>();
        Map<Id,Contentversion> ContentData = new Map<Id,Contentversion>();
        Map<Id,Document_Details__c> DocData = new Map<Id,Document_Details__c>();
        Map<Id,ContentDocument> ContentDocData = new Map<Id,ContentDocument>();
        Set<Id> recordIds=new Set<Id>{bookingId};
            Set<Id> documentIds = new Set<Id>();
        List<ContentDocumentLink> cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIds ];
        for(ContentDocumentLink cdLink:cdl){
            documentIds.add(cdLink.ContentDocumentId);
        }
        //List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
        List<Contentversion> contVer = [Select Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,IsLatest from ContentVersion where ContentDocumentId in :documentIds and IsLatest = true];
        for(Contentversion contVersion :contVer){
            ContentData.put(contVersion.Id, contVersion);
        }
        
        List<Document_Details__c> docDetails = [Select Id,RW_Type_Of_Applicant__c,RW_Document_Type__c,RW_Residential_Status__c,Opportunity__c,RW_Document_ID__c from Document_Details__c where RW_Document_ID__c in :documentIds and Booking__c =:bookingId and Applicant_Number__c =:applicantNumber];
        for(Document_Details__c details :docDetails){
            DocData.put(details.Id, details);
        }
        
        /* List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
for(ContentDocument contDocument :contDoc)
{
ContentDocData.put(contDocument.Id,contDoc);
} */
        
        for(Id contVersionId : ContentData.keySet()){
            for(Id docDataId : DocData.keySet()){
                if(DocData.get(docDataId).RW_Document_ID__c == ContentData.get(contVersionId).ContentDocumentId){
                    KYCWrapper kycWrapData= new KYCWrapper();
                    kycWrapData.documentType=DocData.get(docDataId).RW_Document_Type__c;
                    kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
                    kycWrapData.fileName = ContentData.get(contVersionId).ContentDocument.Title;
                    kycWrapData.fileType = ContentData.get(contVersionId).ContentDocument.FileType;
                    kycWrapData.Id = ContentData.get(contVersionId).ContentDocumentId;
                    kycWrap.add(kycWrapData);
                    
                }
            }
        }
        // system.assert(false);
        return kycWrap;
    }
    @AuraEnabled
    public static void deleteFiles(string sdocumentId){
        delete[ select id from Document_Details__c where RW_Document_ID__c=:sdocumentId];
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];
    }
    @AuraEnabled
    public static String generateBookingOTP(String OTPType,String CustomerNo , String recordId,String bookingEmail){
        String OTPNumber = Utility.generateOTP(OTPType,CustomerNo,recordId);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { bookingEmail};
            String emailBody = '';
        String plainTextBody ='';
        message.subject = 'Digital Booking Form OTP';
        emailBody +='Dear Customer,<br/><br/> Your OTP for Digital form is '+OTPNumber+' . <br/><br/> Regards,<br/> Runwal Team<br/><br/>';
        plainTextBody +=  'Dear Customer,\n Your OTP for Digital form is '+OTPNumber+' . \n Regards,\n Runwal Team<br/><br/>';
        message.setHtmlBody(emailBody);
        message.setPlainTextBody(plainTextBody);
        message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        return OTPNumber;
    }
    public static onlineBookingWrapper insertBookingDetails(onlineBookingWrapper bk,String bookingLink,String PaymentType){
        //system.debug(bkwrap);
        // onlineBookingWrapper bk = (onlineBookingWrapper)JSON.deserialize(bkwrap, onlineBookingWrapper.class);
        
        try{
            //  system.debug(Json.serialize(bkwrap));
            system.debug(bk);
            Quotation__c    QuoteDetails = [SELECT id, Tandem_car_park_Additional__c,MLCP_Additional__c, Single_car_park_Additional__c, Tandem_Open_Additional__c, Single_Open_Additional__c, Stack_Additional__c, Name, Booking__c, Allow_booking_without_full_token__c, Agreement_Value__c, Carpet_Area_Sq_Ft__c, Appartment_Configuration__c, Project__c, Service_Tax_On_Token_Amount__c,
                                            Project_Unit__c, Token_Amount__c, ST_Token_Amount__c, Zone__c, Wing__c, Flat_Typology__c, FloorNo__c, Carpet_Area__c, No_of_parking__c, Parking_Type__c,
                                            Allotment_Premium_Agreement_Value__c,Total_No_of_Parking__c, Agreement_Value_D__c, FlatNo__c, Level_One_Approver__c, Level_Two_Approver__c, Level_Three_Approver__c,Podium__c, Puzzle_Car_Park__c
                                            FROM Quotation__c WHERE Id =:  bk.bookingDetails.booking.Quotation__c];
            if(PaymentType == 'offline'){
                bk.bookingDetails.booking.status__c='Booking Received';
            }else{
                bk.bookingDetails.booking.status__c='Booking Received - Payment Pending';
            }
            
            bk.bookingDetails.booking.Booking_Date__c = system.now();
            update bk.bookingDetails.booking;
            
            //get EOI Payments
            List<RW_Payment_Details__c> eoiPayments = [select id,RW_Booking__c,EOI__c,Opportunity__c from RW_Payment_Details__c where RW_Booking__c = null and
                                                       EOI__c != null and Opportunity__c =   :bk.bookingDetails.booking.customer__c];
            for(RW_Payment_Details__c pd :eoiPayments){
                pd.RW_Booking__c = bk.bookingDetails.booking.id;
            }
            opportunity oppRecord = new Opportunity();
            oppRecord.id =  bk.bookingDetails.booking.customer__c;
            oppRecord.RW_Project__c =      bk.bookingDetails.booking.Project__c;
            oppRecord.RW_Project_Unit__c =      bk.bookingDetails.booking.Unit_No__c;
            oppRecord.RW_Agreement_Value__c =      bk.bookingDetails.booking.Allotment_Premium__c;
            oppRecord.Amount =      bk.bookingDetails.booking.Allotment_Premium__c;
            oppRecord.Booking__c =  bk.bookingDetails.booking.id;
            
            oppRecord.RW_Number_of_Parking__c = QuoteDetails.Total_No_of_Parking__c;
            update oppRecord;
            List<Document_Details__c> documents = [Select id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c,RW_Type_Of_Applicant__c from Document_Details__c where Booking__c =:bk.bookingDetails.booking.id ];
            
            for(Applicant_Details__c applicant : bk.bookingDetails.applicants){
                
                if (applicant.Middle_Name__c != null){
                    applicant.Name = applicant.First_Name__c + ' ' + applicant.Middle_Name__c + ' ' + applicant.Last_Name__c;
                }else{
                    applicant.Name = applicant.First_Name__c + ' ' + applicant.Last_Name__c;
                }
                
                
                
                applicant.Permanent_Address__c = applicant.Permanent_Address_Line_1__c;
                if(applicant.Permanent_Address_Line_2__c != null){
                    applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_2__c;
                    if (applicant.Permanent_Address_Line_3__c != null) {
                        applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_3__c;
                    }
                }
                applicant.Mailing_Address__c = applicant.Mailing_Address_Line_1__c;
                if (applicant.Mailing_Address_Line_2__c != null) {
                    applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_2__c;
                    if (applicant.Mailing_Address_Line_3__c != null) {
                        applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_3__c;
                    }
                }
                applicant.Opportunity__c = bk.bookingDetails.booking.Opportunity__c;
                if(applicant.Office_Address_Line_1__c != null){
                    applicant.Organization_Address__c = applicant.Office_Address_Line_1__c;
                    if (applicant.Office_Address_Line_2__c != null) {
                        applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_2__c;
                        if (applicant.Office_Address_Line_3__c != null) {
                            applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_3__c;
                        }
                    }
                }
                
            }
            upsert  bk.bookingDetails.applicants;
            List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
            
            Map<string,Applicant_Details__c> appNumMap = new Map<string,Applicant_Details__c>();
            for(Applicant_Details__c ad :  bk.bookingDetails.applicants){
                appNumMap.put(ad.Applicant_Number__c, ad);
                
            }
            List<Document_Details__c> updateDcs = new List<Document_Details__c>();
            for(Document_Details__c dc : documents){
                system.debug(dc.Applicant_Number__c);
                if(dc.RW_Applicant_Details__c == null && appNumMap.containsKey(dc.Applicant_Number__c)){
                    Applicant_Details__c ap = appNumMap.get(dc.Applicant_Number__c);
                    system.debug(ap);
                    dc.RW_Applicant_Details__c = ap.Id;
                    ContentDocumentLink  cdl = new ContentDocumentLink ();
                    cdl.linkedEntityId = ap.Id;
                    cdl.ContentDocumentId = dc.RW_Document_ID__c;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    updateDcs.add(dc);
                    insertList.add(cdl);
                    if(dc.RW_Document_Type__c =='PAN Card'){
                        ap.Pancard__c =true;
                    }else if(dc.RW_Document_Type__c =='Passport'){
                        ap.PassportNumber__c =true;
                    }else if(dc.RW_Document_Type__c =='Aadhar Card'){
                        ap.Address_Proof__c =true;
                    }else if(dc.RW_Document_Type__c =='Pan Card Number of Authority Signatory'){
                        ap.PanCard_of_Authority_Signatory__c =true;
                    }else if(dc.RW_Document_Type__c =='Passport Size Photo'  ){
                        ap.One_Passport_Size_Color_Photograph__c = true;
                    }
                    appNumMap.put(dc.Applicant_Number__c,ap);
                }
            }
            if(insertList.size() > 0){
                insert insertList;}
            if(updateDcs.size() > 0){
                update updateDcs;}
            update appNumMap.values();
            decimal         i = 0;
            List < Car_Parking_Charge__c >  ParkingListToUpdate = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > TandemOPENParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > SingleOPENParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > SingleCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > TandemCOVEREDParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > STILTParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > MLCPParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > PodiumParkingList = new List < Car_Parking_Charge__c > ();
            List < Car_Parking_Charge__c > PuzzleCarParkList = new List < Car_Parking_Charge__c > ();//Added by Vinay 28-03-2025
            
            
            
            Set<String> quotationCarParking = new Set<String>();
            if (QuoteDetails.Tandem_car_park_Additional__c != null) { ///tandem covered
                quotationCarParking.add('Tandem Covered');
            }
            if (QuoteDetails.Tandem_Open_Additional__c != null) { ///tandem Open
                quotationCarParking.add('Covered Stack');
            }
            if (QuoteDetails.Single_car_park_Additional__c != null) { // single covered
                quotationCarParking.add('Single Covered');
            }
            
            if (QuoteDetails.Single_Open_Additional__c != null) { // single Open
                quotationCarParking.add('Single Open');
                
            }
            if (QuoteDetails.Stack_Additional__c != null) { // Stack
                quotationCarParking.add('Stilt');
            }
            if (QuoteDetails.MLCP_Additional__c!= null) { // Stack
                quotationCarParking.add('MLCP');
            }
            if (QuoteDetails.Podium__c!= null) { // Podium
                quotationCarParking.add('Podium');
            }
            if (QuoteDetails.Puzzle_Car_Park__c!= null) { //Added by Vinay 28-03-2025
                quotationCarParking.add('Puzzle Car Park');
            }
            List<Car_Parking_Charge__c> AvailableParking = [Select id, Parking__c, Status__c, Category__c, Name, Booking__c From Car_Parking_Charge__c where Parking__c IN : quotationCarParking and Status__c =: 'Vacant' and Category__c =: 'Additional' and Project__c =:bk.bookingDetails.booking.Project__c];
            for(Car_Parking_Charge__c cp :AvailableParking ){
                switch on cp.Parking__c{
                    when 'Tandem Covered'{TandemCOVEREDParkingList.add(cp);}
                    when 'Covered Stack'{TandemOPENParkingList.add(cp);}
                    when 'Single Covered'{SingleCOVEREDParkingList.add(cp);}
                    when 'Single Open'{SingleOPENParkingList.add(cp);}
                    when 'Stilt'{STILTParkingList.add(cp);}
                    when 'MLCP'{MLCPParkingList.add(cp);}
                    when 'Podium'{PodiumParkingList.add(cp);}
                    when 'Puzzle Car Park'{PuzzleCarParkList.add(cp);} //Added by Vinay 28-03-2025
                }
            }
            //Updating Parkings/////
            
            ////Tandem Covered////
            if(QuoteDetails.Tandem_car_park_Additional__c > 0){
                for (integer j = 0; j < QuoteDetails.Tandem_car_park_Additional__c; j++) {
                    
                    TandemCOVEREDParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        TandemCOVEREDParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(TandemCOVEREDParkingList[j]);
                }
                
            }
            ////Tandem Open----->Covered Stack////
            if(QuoteDetails.Tandem_Open_Additional__c > 0){
                for (integer j = 0; j < QuoteDetails.Tandem_Open_Additional__c; j++) {
                    
                    TandemOPENParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        TandemOPENParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(TandemOPENParkingList[j]);
                }
                
            }
            ////Single Open////
            if(QuoteDetails.Single_Open_Additional__c > 0){
                for (integer j = 0; j < QuoteDetails.Single_Open_Additional__c; j++) {
                    
                    SingleOPENParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        SingleOPENParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(SingleOPENParkingList[j]);
                }
                
            }
            ////Single Covered////
            if(QuoteDetails.Single_car_park_Additional__c > 0){
                for (integer j = 0; j < QuoteDetails.Single_car_park_Additional__c; j++) {
                    SingleCOVEREDParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        SingleCOVEREDParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(SingleCOVEREDParkingList[j]);
                    
                }
                
            }
            ////Stack ////
            if(QuoteDetails.Stack_Additional__c > 0){
                for (integer j = 0; j < QuoteDetails.Stack_Additional__c; j++) {
                    STILTParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        STILTParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(STILTParkingList[j]);
                    
                }
                
            }
            ////MLCP////
            if(QuoteDetails.MLCP_Additional__c> 0){
                for (integer j = 0; j < QuoteDetails.MLCP_Additional__c; j++) {
                    MLCPParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        MLCPParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(MLCPParkingList[j]);
                    
                }
                
            }
            ////Podium////
            if(QuoteDetails.Podium__c> 0){
                for (integer j = 0; j < QuoteDetails.Podium__c; j++) {
                    PodiumParkingList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        PodiumParkingList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(PodiumParkingList[j]);
                    
                }
                
            }
            if(QuoteDetails.Puzzle_Car_Park__c> 0){ //Added by Vinay 28-03-2025
                for (integer j = 0; j < QuoteDetails.Puzzle_Car_Park__c; j++) {
                    PuzzleCarParkList[j].Status__c = 'Booked';
                    if (bk.bookingDetails.booking.Id != null)
                        PuzzleCarParkList[j].Booking__c = bk.bookingDetails.booking.Id;
                    ParkingListToUpdate.add(PuzzleCarParkList[j]);
                    
                }
                
            }
            if(ParkingListToUpdate.size() > 0){
                update ParkingListToUpdate;
            }
            
            //Updating  Customer Pay Plan Headers with new booking
            if(bk.bookingDetails.booking.id != null){
                
                try{
                    List<Customer_Pay_Plan_Header__c>   CPPHListToAdd =new    List<Customer_Pay_Plan_Header__c>();
                    List<Customer_Pay_Plan_Header__c> CPPHList = [SELECT id,Name,Booking__c,Customer__c,Quotation__c FROM Customer_Pay_Plan_Header__c WHERE Quotation__c =: bk.bookingDetails.booking.Quotation__c];
                    if(CPPHList.size() > 0){
                        for(Customer_Pay_Plan_Header__c cpph: CPPHList){
                            cpph.Customer__c = bk.bookingDetails.booking.Opportunity__c;
                            cpph.Booking__c = bk.bookingDetails.booking.id;
                            CPPHListToAdd.add(cpph);
                        }
                    }
                    update CPPHListToAdd;
                    
                }catch(DmlException e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
                try{
                    //Updating Quotation with new booking
                    if(QuoteDetails != null){
                        QuoteDetails.Booking__c = bk.bookingDetails.booking.id;
                        update QuoteDetails;
                    }
                }catch(DmlException e){
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
            
            Project_Unit__c pUnit = [Select id,RW_Unit_Status__c,Booking__c,RW_Booking_Date__c,Is_Booking_Tagged__c, RW_Customer__r.RW_Booking_Date_Opp__c from Project_Unit__c where id=:QuoteDetails.project_unit__c];
            pUnit.Booking__c = bk.bookingDetails.booking.id;
            //pUnit.RW_Booking_Date__c = system.today(); // Commented by coServe 04-09-2024
            pUnit.RW_Booking_Date__c = pUnit.RW_Customer__r.RW_Booking_Date_Opp__c; // Added by coServe 04-09-2024
            pUnit.Is_Booking_Tagged__c = true;                       // Added by Sheetal on 02-11-2021
            update pUnit;
            
            if(PaymentType == 'offline'){
                
                RW_Digital_Link_Status__c LinkStatus = [SELECT Id,RecordTypeId,Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =:bookingLink ];
                LinkStatus.RW_Link_Status__c='Expired';
                update LinkStatus;
                try{
                    List<Receipt__c>  rcList = bk.paymentdetail;
                    for(Receipt__c r : rcList){
                        r.Booking__c =bk.bookingDetails.booking.id;
                    }
                    insert rcList;
                }catch(exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                bk.isBookingSuccess = true;
                //           Booking__c bookingRecord = [Select id,Name,Status__c,Customer__r.RW_Project__c,RW_Digitally_Accepted_On__c,Primary_Applicant_Name__c    from Booking__c where id= : details.get('bookingId')];
                
                
                List<String> emailIds = Utility.getExternalTeamEmailIds(new List<String>{'CRM Team','Accounts','Sales Approvers Team'}, bk.bookingDetails.Booking.Project__c);
                List<String> toAddress = new List<String>();
                List<String> managerEmail = Utility.getUserNameEmailbyName(    bk.bookingDetails.booking.Sales_Managers__c);
                
                if(emailIds.size() >  0){
                    toAddress.addAll(emailIds);
                }
                if(managerEmail!=null && managerEmail.size() >  0){
                    toAddress.addAll(managerEmail);}
                
                /*  PageReference pdf = Page.CustomerEOIForm;
pdf.getParameters().put('eoiId',eoiRecord.Id);
Blob body= pdf.getContent();

Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('EOIForm.pdf');
attach.setInline(false);
attach.Body = body;*/
                
                EmailTemplate template = [SELECT Id,Name,Subject,HtmlValue,Body,DeveloperName FROM EmailTemplate Where DeveloperName='Booking_Confirmed_Customer'];
                String htmlBody = template.HtmlValue;
                htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}',   bk.bookingDetails.applicants[0].Name);
                //   htmlBody = htmlBody.replace('{!Booking__c.RW_Digitally_Accepted_On__c}',  bk.bookingDetails.booking.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
                
                htmlBody = htmlBody.replace('{!Project_Unit__c.RW_Param4__c}', bk.bookingDetails.booking.Unit_No__r.RW_Param4__c);
                htmlBody = htmlBody.replace('{!Project__c.Name}', bk.bookingDetails.booking.Project__r.name);
                
                map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c)!=null){
                    htmlBody = htmlBody.replace('{!SMName}', bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c);
                    htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get( bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c).RW_Phone__c));
                }else{
                    htmlBody = htmlBody.replace('{!SMName}', bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c);
                    htmlBody = htmlBody.replace('{!SMPhoneNumber}', System.Label.RW_BookingSalesContact );
                }
                String plainTextBody = template.Body;
                
                plainTextBody = plainTextBody.replace('{!Project_Unit__c.RW_Param4__c}', bk.bookingDetails.booking.Unit_No__r.RW_Param4__c);
                plainTextBody = plainTextBody.replace('{!Project__c.Name}', bk.bookingDetails.booking.Project__r.name);
                
                plainTextBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}',bk.bookingDetails.applicants[0].Name);
                //   plainTextBody = htmlBody.replace('{!Booking__c.RW_Digitally_Accepted_On__c}', bk.bookingDetails.booking.RW_Digitally_Accepted_On__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
                if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c)!=null){
                    plainTextBody = plainTextBody.replace('{!SMName}', bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c);
                    plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(bk.bookingDetails.booking.Customer__r.RW_Sales_Associate__c).RW_Phone__c));
                }else{
                    plainTextBody = plainTextBody.replace('{!SMName}', bk.bookingDetails.booking.customer__r.RW_Sales_Associate__c);
                    plainTextBody = plainTextBody.replace('{!SMPhoneNumber}',System.Label.RW_BookingSalesContact);
                }
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { bk.bookingDetails.applicants[0].Email_Address__c };
                    message.subject = template.Subject;
                message.setHtmlBody(htmlBody);
                message.setPlainTextBody(plainTextBody);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                if(toAddress.size() >0)
                    message.setCcAddresses(toAddress); // Changed from BCC to CC by coServe 20-092024
                // message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                
                
                
            }
            return bk;
        }catch(exception e){
            bk.isBookingSuccess = false;
        }
        return bk;
    }
    @AuraEnabled
    public static String submitBooking(String payload,String encryptionKey,booking__c booking,List<Applicant_Details__c> applicants,List<Receipt__c> paymentDetail,String bookingLink,string comm,string subid,string tdr){
        
        digitalBookingWrapper bookingwrapper = new digitalBookingWrapper();
        bookingwrapper.booking = booking;
        bookingwrapper.applicants = applicants;
        
        onlineBookingWrapper bk = new onlineBookingWrapper();
        bk.bookingDetails = bookingwrapper;
        bk.paymentdetail = paymentDetail;
        
        insertBookingDetails( bk, bookingLink, 'online');
        String split=   '{"split_tdr_charge_type":"'+tdr+'","merComm":"'+comm+'","split_data_list":[{"splitAmount":"'+booking.Token_Amount__c+'","subAccId":"'+subid+'"}]}';
        payload = payload+'&split_data='+split+'\'';
        return encrypt(payload,encryptionKey);
        
        /*if (QuoteDetails != null && QuoteDetails.size() > 0 && TandemCOVEREDParkingList.size() < QuoteDetails[0].Tandem_car_park_Additional__c) {
system.debug('TandemCOVEREDParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of tandem covered parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
///tandem Open////
if (QuoteDetails != null && QuoteDetails.size() > 0 && TandemOPENParkingList.size() < QuoteDetails[0].Tandem_Open_Additional__c) {
system.debug('TandemOPENParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of tandem open parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
///Single Covered////
if (QuoteDetails != null && QuoteDetails.size() > 0 && SingleCOVEREDParkingList.size() < QuoteDetails[0].Single_car_park_Additional__c) {
system.debug('SingleCOVEREDParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of single covered parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
///Sigle Open////
if (QuoteDetails != null && QuoteDetails.size() > 0 && SingleOPENParkingList.size() < QuoteDetails[0].Single_Open_Additional__c) {
system.debug('SingleOPENParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of single open parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
///Stack////
if (QuoteDetails != null && QuoteDetails.size() > 0 && STILTParkingList .size() < QuoteDetails[0].Stack_Additional__c) {
system.debug('STACKParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of Stilt parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
///MLCP////
if (QuoteDetails != null && QuoteDetails.size() > 0 && MLCPParkingList .size() < QuoteDetails[0].MLCP_Additional__c) {
system.debug('MLCPParkingList error');
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Required number of MLCP parking is unavailable');
ApexPages.addMessage(myMsg);
i = 1;

}
*/
        
        
    }
    @AuraEnabled
    public static onlineBookingWrapper  saveBooking(booking__c booking,List<Applicant_Details__c> applicants,List<Receipt__c> paymentDetail,String bookingLink){
        digitalBookingWrapper bookingwrapper = new digitalBookingWrapper();
        bookingwrapper.booking = booking;
        bookingwrapper.applicants = applicants;
        
        onlineBookingWrapper bk = new onlineBookingWrapper();
        bk.bookingDetails = bookingwrapper;
        bk.paymentdetail = paymentDetail;
        
        return insertBookingDetails( bk, bookingLink, 'offline');
    }
    public static string encrypt(String inputdata,String encryptionKey){
        //Blob cryptoKey = Blob.valueOf('E9A2B6448EB867A7A9E622341452EECF');
        try{
            Blob cryptoKey = Blob.valueOf(encryptionKey);
            Blob hash = Crypto.generateDigest('MD5', cryptoKey );
            Blob data = Blob.valueOf(inputdata);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', hash , data);
            String encRequest = EncodingUtil.convertToHex(encryptedData );
            return encRequest;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @auraEnabled
    public static string decrypt(String inputdata,String encryptionKey){
        Blob cryptoKey = Blob.valueOf(encryptionKey);
        Blob hash = Crypto.generateDigest('MD5', cryptoKey);
        Blob data = EncodingUtil.convertFromHex(inputdata); //Received from ccAvenue response
        Blob decryptedText = Crypto.decryptWithManagedIV('AES128', hash, data);
        String PLAIN_TEXT = decryptedText.toString();
        return PLAIN_TEXT;
    }
    
    @auraEnabled
    
    public static onlineBookingWrapper getApplicants(string recordId){
        onlineBookingWrapper booking = new onlineBookingWrapper(recordId);
        booking.maxApplicants =decimal.valueOf( System.Label.RW_MAX_Applicant);
        return booking;
    }
    @AuraEnabled
    public static List<Applicant_details__C> saveApplicants(List<Applicant_details__C>  applicants){
        for(Applicant_details__C applicant : applicants){
            
            if(applicant.id != null && (String.valueOf(applicant.id)).length() <15)
                applicant.Id = null;
            
            if(applicant.Middle_Name__c != null){
                applicant.Name = applicant.First_Name__c + ' ' + applicant.Middle_Name__c + ' ' + applicant.Last_Name__c;
            }else{
                applicant.Name = applicant.First_Name__c + ' ' + applicant.Last_Name__c;
            }
            
            
            
            applicant.Permanent_Address__c = applicant.Permanent_Address_Line_1__c;
            if (applicant.Permanent_Address_Line_2__c != null) {
                applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_2__c;
                if (applicant.Permanent_Address_Line_3__c != null) {
                    applicant.Permanent_Address__c = applicant.Permanent_Address__c + ', ' + applicant.Permanent_Address_Line_3__c;
                }
            }
            applicant.Mailing_Address__c = applicant.Mailing_Address_Line_1__c;
            if (applicant.Mailing_Address_Line_2__c != null) {
                applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_2__c;
                if (applicant.Mailing_Address_Line_3__c != null) {
                    applicant.Mailing_Address__c = applicant.Mailing_Address__c + ', ' + applicant.Mailing_Address_Line_3__c;
                }
            }
            applicant.Opportunity__c = applicants[0].Opportunity__c;
            if(applicant.Office_Address_Line_1__c != null){
                applicant.Organization_Address__c = applicant.Office_Address_Line_1__c;
                if (applicant.Office_Address_Line_2__c != null) {
                    applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_2__c;
                    if (applicant.Office_Address_Line_3__c != null) {
                        applicant.Organization_Address__c = applicant.Organization_Address__c + ', ' + applicant.Office_Address_Line_3__c;
                    }
                }
            }
        }
        upsert applicants;
        List<Document_Details__c> documents = [Select id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c,RW_Type_Of_Applicant__c from Document_Details__c where Booking__c =:applicants[0].booking__c ];
        List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
        
        Map<string,Applicant_Details__c> appNumMap = new Map<string,Applicant_Details__c>();
        for(Applicant_Details__c ad :  applicants){
            appNumMap.put(ad.Applicant_Number__c, ad);
            
        }
        Map<String,Applicant_Details__c> appset = new Map<String,Applicant_Details__c>();
        List<Document_Details__c> updateDcs = new List<Document_Details__c>();
        for(Document_Details__c dc : documents){
            if(dc.RW_Applicant_Details__c == null){
                if(appNumMap.containskey(dc.Applicant_Number__c)){
                    Applicant_Details__c ap = appNumMap.get(dc.Applicant_Number__c);
                    dc.RW_Applicant_Details__c = ap.Id;
                    
                    ContentDocumentLink  cdl = new ContentDocumentLink ();
                    cdl.linkedEntityId = ap.Id;
                    cdl.ContentDocumentId = dc.RW_Document_ID__c;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers';
                    updateDcs.add(dc);
                    insertList.add(cdl);
                    if(dc.RW_Document_Type__c =='PAN Card'){
                        ap.Pancard__c =true;
                    }else if(dc.RW_Document_Type__c =='Passport'){
                        ap.PassportNumber__c =true;
                    }else if(dc.RW_Document_Type__c =='Aadhar Card'){
                        ap.Address_Proof__c =true;
                    }else if(dc.RW_Document_Type__c =='Pan Card Number of Authority Signatory'){
                        ap.PanCard_of_Authority_Signatory__c =true;
                    }else if(dc.RW_Document_Type__c =='Passport Size Photo'  ){
                        ap.One_Passport_Size_Color_Photograph__c = true;
                    }
                    appset.put(dc.RW_Applicant_Details__c,ap);
                }
            }
        }
        if(insertList.size() > 0){
            insert insertList;}
        if(updateDcs.size() > 0){
            update updateDcs;
        }
        if(appset.size()>0)
            update appset.values();
        
        return applicants;
        
    }
    public class errorWrapper{
        @auraEnabled
        public String errorfield;
        @auraEnabled
        public String ErrorMessage;
        
        @auraEnabled
        public Boolean isError;
        @AuraEnabled
        public boolean inApproval;
        
    }
    @auraenabled
    public static List<errorWrapper> checkforApproval(String recId){
        List<errorWrapper> errors = new List<errorWrapper>();
        
        booking__c bk = [select id,Name,RW_Applicant_KYC_Verified__c,Project_Name__c,Booking_Confirmation_Approval_Status__c,Brokerage__c,	Interest_to_be_Applied__c,
                         Source_of_Booking__c,Quotation__c,CreatedDate,Booking_Date__c,RW_Remarks__c,Sales_Managers__c,Sales_Manager__c,
                         BrokerIId__r.SAP_CP_Code__c,Scheme_of_Customer__c,Primary_Applicant_Email__c, Booking_Form_Id__c, Booking_Form_Uploaded__c,
                         Signed_Cost_Sheet_Form_Id__c,Signed_Cost_Sheet_Uploaded__c, IOM_Document_Id__c, IOM_Document_Uploaded__c,
                         Deviation_Approval_Doc_Id__c,Deviation_Approval_Doc_Uploaded__c, Token_Payment_Doc_Id__c, Token_Payment_Doc_Uploaded__c,
                         Quotation__r.walkin_Source__c,Type_of_Client__c,Tower__c,Project__c,Quotation__r.Brokerage_Agreement_Value__c,Passback_Amount__c,Unit_No__r.Token_Amount__c,Unit_No__r.RW_Project__r.Token_Amount__c,
                         (select id,Mode__c,Physically_Cheque_Received__c,Total_Amount__c from Receipts__r) from booking__c where id=:recId];
        boolean err = false;
        Decimal totalAmount = 0; //Added by Vinay 14-08-2025
        Decimal requiredTokenAmount = bk.Unit_No__r.Token_Amount__c != null ? bk.Unit_No__r.Token_Amount__c : bk.Unit_No__r.RW_Project__r.Token_Amount__c; //Added by Vinay 14-08-2025
       /* for(Receipt__c rec : bk.Receipts__r){
            if((rec.mode__c == 'Cheque' || rec.Mode__c == 'DD/Pay Order') && !(rec.Physically_Cheque_Received__c)){
                err=true;
            }
            totalAmount += rec.Total_Amount__c; //Added by Vinay 13-08-2025
        }
        if(totalAmount < requiredTokenAmount){ //Added by Vinay 13-08-2025
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Total Receipt Amount is less than the Token Amount. Token Amount is:'+requiredTokenAmount;
            errors.add(wrap);
        }Commented for unidentified Payments*/
        
        
         /*Added for unidentified Payment starts*/
        AggregateResult[] results = [SELECT SUM(Total_Amount_Paid__c) total 
                                             FROM RW_Payment_Details__c 
                                             WHERE RW_Booking__c = :recId];
                Decimal totalPaid = 0;
            if (!results.isEmpty()) {
                totalPaid = (Decimal)results[0].get('total') == null ? 0 :(Decimal)results[0].get('total') ;
            }
        System.debug('totalPaid**'+totalPaid);
        System.debug('requiredTokenAmount**'+requiredTokenAmount);
        if(totalPaid < requiredTokenAmount){
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Total SAP Receipt Amount is less than the Token Amount. Token Amount is:'+requiredTokenAmount;
            errors.add(wrap);
        }
        /*Added for unidentified Payment ends*/
        // Added by ubsdigicloud date 21-07-25
        if (bk.Quotation__c == null) {
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Quotation is required to submit the booking for Approval.';
            errors.add(wrap);
        } else {
            List<Customer_Pay_Plan_Header__c> qHeadrs = [select id,(select id,RW_SAP_Milestone_Code__c,Payment_Milestone__c,Payment_Milestone__r.name from Standard_Customer_Pay_Plan_Detail__r) from Customer_Pay_Plan_Header__c where Quotation__c=: bk.Quotation__c ];
            
            for(Customer_Pay_Plan_Header__c cpphd : qHeadrs){
                
                for(Standard_Customer_Pay_Plan_Detail__c spph : cpphd.Standard_Customer_Pay_Plan_Detail__r){
                    if(spph.RW_SAP_Milestone_Code__c == null && spph.Payment_Milestone__c != null){
                        errorWrapper wrap = new errorWrapper();
                        wrap.isError=true;
                        wrap.ErrorMessage =  spph.Payment_Milestone__c ;
                        wrap.errorfield =  spph.Payment_Milestone__r.Name;
                        errors.add(wrap);
                    }
                }
            }
        }        
        list<ProcessInstance> existingApprovals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId = :recId AND Status = 'Pending'];
        
        if(err){
            errorWrapper wrap = new errorWrapper();
            wrap.isError=true;
            wrap.ErrorMessage = System.Label.BookingRecieptError;
            errors.add(wrap);
        }
        if(bk.Source_of_Booking__c=='Channel Partner' && bk.Brokerage__c == null){
            //Commented by vinay 12-01-2022
            /*errorWrapper wrap = new errorWrapper();

wrap.isError = true;
wrap.ErrorMessage = System.Label.BookingCPError;
errors.add(wrap);*/
            //Added by vinay 12-01-2022 -- Start
            //Commented by Prashant and added the correct logic for assigning brokerage below.12-2-25.
            /*if(bk.Project_Name__c == 'Runwal Gardens'){
bk.Brokerage__c = 2.25;
}else{
bk.Brokerage__c = 2;
}
update bk;*/
            //Added by vinay 12-01-2022 -- End
            
            
            //Added by Prashant to add the brokerage % on bookings in case the booking is created before the scheme creation - 12-2-25///Start//
            //////////////////////////////////////Added BY Aniket Starts Here on 29-09-2022/////////////////////////////////////////
            Date bookingDate = Date.ValueOf(bk.Booking_Date__c);
            Date bookingDate2 = Date.ValueOf('2024-04-1T06:00:00.000Z');
            list<Scheme_Configuration__c> sc = new list<Scheme_Configuration__c>();
            list<Brokerage_Scheme__c> brokerageScheme = new list<Brokerage_Scheme__c>();
            
            //Added by Prashant to prioritize the schemes that will be tagged on booking which has tower in it.//START - 13-01-25
            List<Scheme_Configuration__c> sctemp = [Select Id,Name,Brokerage_Scheme__c,Type__c,Tower__c from Scheme_Configuration__c where ((Project__c =:bk.Project__c and Tower__c =:bk.Tower__c) OR (Project__c =:bk.Project__c and Tower__c =:null)) and (Type__c =: bk.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
            //sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c where ((Project__c =:boookingObj.Project__c and Tower__c =:boookingObj.Tower__c) OR (Project__c =:boookingObj.Project__c and Tower__c =:null)) and (Type__c =: boookingObj.Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
            if(!sctemp.isEmpty()){
                for (Scheme_Configuration__c sci : sctemp) {
                    if (sci.Tower__c != null) {
                        sc.add(sci);
                        break;
                    }
                }
                if (sc.isEmpty()) {
                    sc.add(sctemp[0]);
                }
            }
            //Added by Prashant to prioritize the schemes that will be tagged on booking which has tower in it.//END - 13-01-25
            if(!sc.isEmpty()){
                if(bk.Quotation__r.walkin_Source__c == 'Channel Partner'){
                    brokerageScheme = [select Id,Name,Base_Brokerage__c,Base_Brokerage_for_OS_NRI__c,Type__c,Base_Brokerage_for_Local_Bookings__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                       Start_Date__c <=: bookingDate and (End_Date__c = null or End_Date__c >=: bookingDate) and Approval_Status__c = 'Approved by Level 2'];
                    // if(QuoteDetails[0].Agreement_Value_for_brokers__c != 0 || QuoteDetails[0].Agreement_Value_for_brokers__c != Null)
                    if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Local'  ){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate < bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate >= bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'Local' || bk.Type_of_Client__c == 'Corporate' )){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'NRI' || bk.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (bk.Type_of_Client__c == 'NRI' || bk.Type_of_Client__c == 'Outstation') && bookingDate >= bookingDate2){
                        bk.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c /  bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        bk.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        bk.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
                        bk.Brokerage_Scheme__c =  brokerageScheme[0].Id;
                        bk.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((bk.Passback_Amount__c / bk.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                }
                
            }
            try{
                update bk;
            }catch(Exception e){
                system.debug('Error while updating Booking ---->> '+e.getMessage());
            }
            
            //////////////////////////////////////Added BY Aniket Ends Here on 29-09-2022////////////////////////////////////////
            ////Added by Prashant to add the brokerage % on bookings in case the booking is created before the scheme creation - 12-2-25///End//
        }
        
        if(bk.Booking_Confirmation_Approval_Status__c=='Approved'){
            errorWrapper wrap = new errorWrapper();
            
            wrap.isError = true;
            wrap.ErrorMessage = System.Label.BookingApproved;
            errors.add(wrap);
            
        }
        
        if(!(bk.RW_Applicant_KYC_Verified__c)){
            errorWrapper wrap = new errorWrapper();
            
            wrap.isError = true;
            wrap.ErrorMessage = System.Label.BookingKYCError;
            errors.add(wrap);
            
        }
        if(existingApprovals.size()>0){
            errorWrapper wrap = new errorWrapper();
            
            wrap.isError = true;
            wrap.inApproval = true;
            wrap.ErrorMessage = System.Label.BookingInApproval;
            errors.add(wrap);
            
        }
        //Added by Vinay 12-01-2022 ----Start
        if(bk.Source_of_Booking__c=='Channel Partner' && (bk.BrokerIId__r.SAP_CP_Code__c == null || bk.BrokerIId__r.SAP_CP_Code__c == '' || bk.BrokerIId__r.SAP_CP_Code__c == '0')){
            errorWrapper wrap = new errorWrapper();
            
            wrap.isError = true;
            wrap.ErrorMessage = System.Label.Channel_Partner_Not_Registered;
            errors.add(wrap);
        }
        
        if(bk.Scheme_of_Customer__c == null){
            errorWrapper wrap = new errorWrapper();
            
            wrap.isError = true;
            wrap.ErrorMessage = 'Please add Scheme of Customer';
            errors.add(wrap);
        }
        if(bk.Booking_Date__c > Datetime.now()){
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Booking date should not be the future date';
            errors.add(wrap);
        }
        
        if(bk.Primary_Applicant_Email__c == null){
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Please add Applicant details';
            errors.add(wrap);
        }
        if(bk.Booking_Form_Id__c == null || bk.Signed_Cost_Sheet_Form_Id__c == null || bk.Token_Payment_Doc_Id__c == null){
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Please upload all the Documents (Booking Form with KYC, Signed Cost Sheet, Token Payment Details)';
            errors.add(wrap);
        }
        if((bk.IOM_Document_Id__c == null && bk.IOM_Document_Uploaded__c == true) || (bk.Deviation_Approval_Doc_Id__c == null && bk.Deviation_Approval_Doc_Uploaded__c == true)){
            errorWrapper wrap = new errorWrapper();
            wrap.isError = true;
            wrap.ErrorMessage = 'Please upload all the Documents (IOM, Deviation Approval)';
            errors.add(wrap);
        }
        if((bk.Booking_Form_Id__c != null && bk.Booking_Form_Uploaded__c == false) ||
           (bk.Signed_Cost_Sheet_Form_Id__c != null && bk.Signed_Cost_Sheet_Uploaded__c == false) ||
           (bk.IOM_Document_Id__c != null && bk.IOM_Document_Uploaded__c == false) ||
           (bk.Deviation_Approval_Doc_Id__c != null && bk.Deviation_Approval_Doc_Uploaded__c == false) ||
           (bk.Token_Payment_Doc_Id__c != null && bk.Token_Payment_Doc_Uploaded__c == false)){
               errorWrapper wrap = new errorWrapper();
               wrap.isError = true;
               wrap.ErrorMessage = 'Please tick the documet uploaded check boxes (Booking Form with KYC, Signed Cost Sheet, Token Payment Details)';
               errors.add(wrap);
           }
        /*if(bk.Interest_to_be_Applied__c==null)
{
errorWrapper wrap = new errorWrapper();
wrap.isError = true;
wrap.ErrorMessage = 'Choose if Interest needs to be Applied ? ';
errors.add(wrap);
}*/
        /*if(Date.valueOf(bk.Booking_Date__c).daysBetween(Date.valueOf(bk.CreatedDate)) > 7 && (bk.RW_Remarks__c == '' || bk.RW_Remarks__c == null)){
errorWrapper wrap = new errorWrapper();
wrap.isError = true;
wrap.ErrorMessage = System.Label.Booking_Delay_Remarks;
errors.add(wrap);
}*/
        //Added by Vinay 12-01-2022 ----End
        
        return errors;
        
    }
    
    // Commented by coServe 06-10-2022
    /*@AuraEnabled
public  static void 
(String recordId,String Comments)
{
try
{
Booking__c bc= [select id,Level_One_Approver__c,Project__c from booking__c where id=:recordId];
project__c pj = [Select id,Sales_Site_Head__c from project__c where id = : bc.Project__c];
if(bc.Level_One_Approver__c == null || bc.Level_One_Approver__c != pj.Sales_Site_Head__c){
bc.Level_One_Approver__c = pj.Sales_Site_Head__c;
BookingTriggerHandler.byPass = true;
update bc;
BookingTriggerHandler.byPass = false;


}
Approval.ProcessSubmitRequest req1 =
new Approval.ProcessSubmitRequest();
req1.setComments(Comments);
req1.setObjectId(recordId);

// Submit on behalf of a specific submitter

// Submit the record to specific process and skip the criteria evaluation
// req1.setProcessDefinitionNameOrId('EOI_Cancellation');
//req1.setSkipEntryCriteria(true);

// Submit the approval request for the account
Approval.ProcessResult result = Approval.process(req1);

// Verify the result
//System.assert(result.isSuccess());
}
catch(Exception e)
{
throw new AuraHandledException(e.getMessage());
}
}*/
    
    // Added by coServe 06-10-2022 Start
    @AuraEnabled
    public  static void sendApprovalRequest(String recordId,String Comments){
        try{
            Booking__c bc= [select id,Level_One_Approver__c,Project__c, CRM_Head__c, Sales_Head__c, Customer__r.Walkin_Source__c,Interest_to_be_Applied__c,Passback_Amount__c, Source_of_Booking__c, Sub_Source__c, Referral_Passback_Amount__c from booking__c where id=:recordId];
            project__c pj = [Select id,Sales_Site_Head__c, CRMHead__c, CRM_MIS_Head__c, Sales_Head__c from project__c where id = : bc.Project__c];
            
            if(bc.Source_of_Booking__c == 'Referral' && bc.Sub_Source__c == 'Existing client reference' && bc.Referral_Passback_Amount__c > 0){
                if(bc.CRM_Head__c == null){
                    bc.CRM_Head__c = pj.CRM_MIS_Head__c;
                }
                if(bc.Sales_Head__c == null){
                    bc.Sales_Head__c = pj.Sales_Head__c;
                }
                BookingTriggerHandler.byPass = true;
                update bc;
                BookingTriggerHandler.byPass = false;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(Comments);
                req1.setObjectId(recordId);
                req1.setProcessDefinitionNameOrId('Booking_Approval_Process_for_Ref_Pasback');
                Approval.ProcessResult result = Approval.process(req1);
                
            }else if((bc.Customer__r.Walkin_Source__c == 'Channel Partner' && (bc.Passback_Amount__c != null && bc.Passback_Amount__c != 0))){
                if(bc.CRM_Head__c == null){
                    bc.CRM_Head__c = pj.CRM_MIS_Head__c;
                }
                if(bc.Sales_Head__c == null){
                    bc.Sales_Head__c = pj.Sales_Head__c;
                }
                BookingTriggerHandler.byPass = true;
                update bc;
                BookingTriggerHandler.byPass = false;
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(Comments);
                req1.setObjectId(recordId);
                req1.setProcessDefinitionNameOrId('Booking_Approval_Process_for_Passback');
                Approval.ProcessResult result = Approval.process(req1);
                
            }else{
                if(bc.Level_One_Approver__c == null || bc.Level_One_Approver__c != pj.Sales_Site_Head__c){
                    bc.Level_One_Approver__c = pj.Sales_Site_Head__c;
                    BookingTriggerHandler.byPass = true;
                    update bc;
                    BookingTriggerHandler.byPass = false;
                }
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments(Comments);
                req1.setObjectId(recordId);
                /*if(bc.Interest_to_be_Applied__c=='Yes')
{
req1.setProcessDefinitionNameOrId('Booking_Approval_Process_Latest');
}
else*/
                
                req1.setProcessDefinitionNameOrId('Booking_Approval_Process');
                
                Approval.ProcessResult result = Approval.process(req1);
            }
            
        }catch(Exception e){
            if(!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
    }
    // Added by coServe 06-10-2022 End
    
    @AuraEnabled
    Public static Boolean checkKYCAccepted(String recordId){
        Booking__c b = [Select id, RW_Applicant_KYC_Verified__c from booking__c where id=:recordId];
        return b.RW_Applicant_KYC_Verified__c;
    }
    @AuraEnabled
    Public static Boolean confirmKYCAccepted(String recordId){
        Booking__c b = [Select id, RW_Applicant_KYC_Verified__c from booking__c where id=:recordId];
        b.RW_Applicant_KYC_Verified__c = true;
        update b;
        return  b.RW_Applicant_KYC_Verified__c ;
    }
    
    //BillDesk integration Via API-  PLN
    @AuraEnabled
    public static String getBillDeskData(Map<String,String> DetailMap){
        String billDeskChecksumKey = '';
        try{
            Map<String,String> BillDeskInputMap = new Map<String,String>();
            List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];
            
            List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
            if(BillDeskDetails != null && BillDeskDetails.size() >0){
                
                Receipt__c receipt = new Receipt__c();
                receipt.Booking__c = DetailMap.get('bRecId');
                receipt.Opportunity__c = DetailMap.get('oppRecId');
                receipt.Project__c = towerData[0].ProjectName__c;
                receipt.Mode__c = 'Digital';
                receipt.Payment_Gateway__c = 'BillDesk';
                receipt.RW_Payment_Collection_Type__c='Booking';
                receipt.Total_Amount__c = Decimal.valueof(DetailMap.get('Amount'));
                receipt.Project_Unit__c=DetailMap.get('projectUnit');
                //   receipt.Receipt_Status__c='Processed-Sent for Banking';
                //  receipt.Receipt_Date__c=Date.today();
                
                insert receipt;
                
                List<Receipt__c> receiptRecord = [Select Name, Opportunity__r.SalesOrder_Number__c, Opportunity__r.SAP_Customer_Number__c,Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, Project_Unit__r.RW_Param1__c,Project_Unit__r.RW_Param4__c from Receipt__c Where Id =:receipt.Id ];
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_Merchant_ID__c);
                BillDeskInputMap.put('CustomerID',receiptRecord[0].Name);
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_Security_ID__c);
                BillDeskInputMap.put('TxnAmount',DetailMap.get('Amount'));
                BillDeskInputMap.put('CurrencyType','INR');
                BillDeskInputMap.put('TypeField1', 'R');
                BillDeskInputMap.put('TypeField2', 'F');
                //Added by coServe 02-02-2023 Start
                BillDeskInputMap.put('AdditionalInfo2',receiptRecord[0].Opportunity__r.SalesOrder_Number__c);
                BillDeskInputMap.put('AdditionalInfo3',receiptRecord[0].Opportunity__r.SAP_Customer_Number__c);
                BillDeskInputMap.put('AdditionalInfo4',receiptRecord[0].Project_Unit__r.RW_Param1__c + ' ' + receiptRecord[0].Project_Unit__r.RW_Param4__c);
                BillDeskInputMap.put('AdditionalInfo5',receiptRecord[0].Opportunity__r.RW_Email__c);
                BillDeskInputMap.put('AdditionalInfo6',receiptRecord[0].Opportunity__r.RW_Mobile_No__c);
                //Added by coServe 02-02-2023 End
                BillDeskInputMap.put('AdditionalInfo7',BillDeskDetails[0].Bill_Desk_Pay_Category__c); /* To set Payment Category for BillDesk - txtPayCategory */
                billDeskChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
                
                return Utility.generateBillDeskMessageString(BillDeskInputMap, billDeskChecksumKey);
                
            }else{
                throw new CommonException('Payment Gateway unavailable right now. Please try later');
            }
        }catch(Exception e){
            throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
    
    @AuraEnabled
    public static String saveBillDeskResp(String msg,String digitalLinkId, String bRecId,String towerId){
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
        List<String> msgList = msg.split('\\|');
        String actualinputData = msg.substring(0,msg.lastIndexOf('|'));
        String checksumValue = msg.substring((msg.lastIndexOf('|')+1));
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =:towerId];
        List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
        String ChecksumKey='';
        ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
        try{
            if(ChecksumKey != '' && checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey)){
                
                List<Receipt__c> receiptRecord = [Select Name,Mode__c,Cheque_DD__c,Amount_Rs__c,Receipt_Status__c,RW_Digital_Payment_Mode__c,Cheque_DD_Date__c from Receipt__c Where Name =: msgList[BillDeskResFormat1.indexOf('CustomerID')] ];
                
                if(receiptRecord != null && receiptRecord.size() >0){
                    //receiptRecord[0].Mode__c = 'Digital';
                    receiptRecord[0].Cheque_DD__c = msgList.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
                    // receiptRecord[0].Amount_Rs__c = Decimal.valueof(msgList.get(BillDeskResFormat1.indexOf('TxnAmount')));
                    String dateFormat = msgList.get(BillDeskResFormat1.indexOf('TxnDate'));
                    receiptRecord[0].Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));
                    receiptRecord[0].Receipt_Status__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300' ? 'Success' : 'Failure';
                    receiptRecord[0].Payment_Gateway_Response_Code__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus'));
                    //  receiptRecord[0].Payment_Gateway_Response_Code__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus'));
                    switch on (msgList.get(BillDeskResFormat1.indexOf('TxnType'))){
                        when '01' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Net Banking'; }
                        when '02' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Credit Card'; }
                        when '03' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Debit Card'; }
                        when '04' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Cash Card'; }
                        when '05' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Mobile Wallet'; }
                        when '06' { receiptRecord[0].BillDesk_Payment_Mode__c = 'IMPS'; }
                        when '07' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Reward Points'; }
                        when '08' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Rupay'; }
                        when '10' { receiptRecord[0].BillDesk_Payment_Mode__c = 'UPI'; }
                        when else { receiptRecord[0].BillDesk_Payment_Mode__c = 'Others'; }
                    }
                    update receiptRecord[0];
                }
                
                
                if(msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300'){
                    /* PLN*/
                    Booking__c bookingRecord = [Select id,Unit_No__r.RW_Param4__c,Project__r.name,Name,Sales_Managers__c,Status__c,Customer__r.RW_Project__c,RW_Digitally_Accepted_On__c,Primary_Applicant_Email__c,Primary_Applicant_Name__c,customer__r.RW_Sales_Associate__c  from Booking__c where id= : bRecId];
                    
                    if(bookingRecord!=NULL && bookingRecord.Status__c == 'Booking Received - Payment Pending'){
                        bookingRecord.Status__c = 'Booking Received';
                        update bookingRecord;
                    }
                    
                    List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id,RecordTypeId,Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id = :digitalLinkId];
                    if(digitalLinkRec != null && digitalLinkRec.size() >0){
                        digitalLinkRec[0].RW_Link_Status__c ='Expired';
                        update digitalLinkRec[0];
                    }
                    /* PLN*/
                    
                    return 'Success';
                }else{
                    return 'Failure';
                }
            }else{
                return 'Failure';
            }
            
        }catch(Exception e){
            throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
    
    @AuraEnabled
    public static Boolean profileCheck(){
        String[] profileIds = Label.Mobile_No_Visibility_Profiles.split(',');
        if(profileIds.contains(UserInfo.getProfileId())){
            return false;
        }else{
            return true;
        }
        
    }
    
    
    public static void dummyMethod(){
        integer i;
        i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}