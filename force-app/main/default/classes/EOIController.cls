public without sharing class EOIController 
{
    //public static final Blob CRYPTOKEY = EncodingUtil.base64Decode('aKUh/QDcqCZfRs6jBbmDEaQi3WCZ+OUEZagi6j3Ni74=');
    public static final Blob CRYPTOKEY = EncodingUtil.base64Decode(Label.URL_Encryption_Key);
    private static final String KEY = 'OTVO07DZOH'; 
    private static final String SALT = 'AGJCLF10D5'; 
    private static final String EASEBUZZ_URL = 'https://dashboard.easebuzz.in/easycollect/v1/create';


	@AuraEnabled
    public static Map<String,List<String>> getPreferredResidence(String projectName,String TowerName)
    {
        try
        {
        Map<String,List<String>> preferredResidenceMap = new  Map<String,List<String>>();
        List<String> UnitTypes = new List<String>();
        List<String> budgetTypes = new List<String>();
        List<String> floorTypes = new List<String>();
        List<String> sizes = new List<String>(); //Added by coServe 09-10-2024
        List<String> eoiAmounts = new List<String>(); //Added by coServe 09-10-2024
        Projects__mdt[] projMappings = [SELECT Id,Label FROM Projects__mdt Where Label =:projectName ];
        if(projMappings != null && projMappings.size() >0)
        {
            Project_Towers__mdt[] towerMappings = [SELECT Id,Label, Projects__c FROM Project_Towers__mdt Where Projects__c = :projMappings[0].Id and Label =:TowerName ];
            if(towerMappings != null && towerMappings.size() >0)
            {
                Preferred_Unit_Type__mdt[] unitTypeMappings = [SELECT Id,Label, Project__c ,Order__c FROM Preferred_Unit_Type__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                for(Preferred_Unit_Type__mdt unitTypeMapping : unitTypeMappings) 
                {
                    UnitTypes.add(unitTypeMapping.Label);
                }
                if(UnitTypes.size() >0)
                preferredResidenceMap.put('PreferredUnits',UnitTypes);
                else
                throw new CommonException('No unit types found for this Project/Tower');
                
                
                Preferred_Budget__mdt[] budgetMappings = [SELECT Id,Label, Project__c ,Order__c FROM Preferred_Budget__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                for(Preferred_Budget__mdt budgetMapping : budgetMappings) 
                {
                    budgetTypes.add(budgetMapping.Label);
                }
                
                if(budgetTypes.size() >0)
                preferredResidenceMap.put('PreferredBudget',budgetTypes);
                else
                throw new CommonException('No Budget types found for this Project/Tower');
                
                
                
                Preferred_Floors__mdt[] floorMappings = [SELECT Id,Label,Projects__c,Order__c FROM Preferred_Floors__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                for(Preferred_Floors__mdt floorMapping : floorMappings) 
                {
                    floorTypes.add(floorMapping.Label);
                }
                
                if(floorTypes.size() >0)
                preferredResidenceMap.put('PreferredFloors',floorTypes);
                
                
                //Added by coServe 09-10-2024 Start
                //if(projectName == 'Runwal Forests'){
                    
                    Preferred_Size__mdt[] sizeMappings = [SELECT Id,Label,Projects__c,Order__c FROM Preferred_Size__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                    for(Preferred_Size__mdt sizeMapping : sizeMappings){
                        sizes.add(sizeMapping.Label);
                    }
                    if(floorTypes.size() > 0){
                        preferredResidenceMap.put('PreferredSizes', sizes);
                    }
                    
                    EOI_Amount__mdt[] amountMappings = [SELECT Id,Label,Projects__c,Order__c FROM EOI_Amount__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                    for(EOI_Amount__mdt amountMapping : amountMappings){
                        eoiAmounts.add(amountMapping.Label);
                    }
                    if(floorTypes.size() > 0){
                        preferredResidenceMap.put('PreferredEoiAmounts', eoiAmounts);
                    }
                    
                    List<String> sources = System.Label.Application_Sources_for_Runwal_Mahalakshmi.split(',');
                    
                    if(sources.size() > 0){
                        preferredResidenceMap.put('ApplicationSources', sources);
                    }
                    
                //}
                //Added by coServe 09-10-2024 End

            }
        }
            return preferredResidenceMap;
 
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   /* @AuraEnabled
    public  static List<String> getUnitType(String projectName,String TowerName)
    {
        try
        {
        List<String> UnitTypes = new List<String>();
        Projects__mdt[] projMappings = [SELECT Id,Label FROM Projects__mdt Where Label =:projectName ];
        if(projMappings != null && projMappings.size() >0)
        {
            Project_Towers__mdt[] towerMappings = [SELECT Id,Label, Projects__c FROM Project_Towers__mdt Where Projects__c = :projMappings[0].Id and Label =:TowerName ];
            if(towerMappings != null && towerMappings.size() >0)
            {
                Preferred_Unit_Type__mdt[] unitTypeMappings = [SELECT Id,Label, Project__c , Object__c,Order__c FROM Preferred_Unit_Type__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                for(Preferred_Unit_Type__mdt unitTypeMapping : unitTypeMappings) 
                {
                    UnitTypes.add(unitTypeMapping.Label);
                }
                
                
            }
        }
        if(UnitTypes.size() >0)
        return UnitTypes;
        else
        throw new CommonException('No unit types found for this Project/Tower');   
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public  static List<String> getBudget(String projectName,String TowerName)
    {
        try
        {
        List<String> budgetTypes = new List<String>();
        Projects__mdt[] projMappings = [SELECT Id,Label FROM Projects__mdt Where Label =:projectName ];
        if(projMappings != null && projMappings.size() >0)
        {
           Project_Towers__mdt[] towerMappings = [SELECT Id,Label, Projects__c FROM Project_Towers__mdt Where Projects__c = :projMappings[0].Id and Label =:TowerName ];
            if(towerMappings != null && towerMappings.size() >0)
            {
                Preferred_Budget__mdt[] budgetMappings = [SELECT Id,Label, Project__c , Object__c,Order__c FROM Preferred_Budget__mdt Where Project_Towers__c = :towerMappings[0].Id Order by Order__c ASC];
                for(Preferred_Budget__mdt budgetMapping : budgetMappings) 
                {
                    budgetTypes.add(budgetMapping.Label);
                }
            }
        }
        if(budgetTypes.size() >0 )
        return budgetTypes;
        else
        throw new CommonException('No Budget types found for this Project/Tower');
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    */
    
   /* @AuraEnabled
    public static Payment_Gateway__mdt getPaymentGatewayDetails(String projectName)
    {
        try
        {
        List<String> paymentTypes = new List<String>();
       // Payment_Gateway__mdt[] paymentMappings = [SELECT Access_Code__c,Encryption_Key__c,Merchant_Number__c FROM Payment_Gateway__mdt Where Project_Name__c =:projectName ];
        Payment_Gateway__mdt paymentMappings = Utility.getPaymentGatewayDetails(projectName);
   
        if(paymentMappings != null )
        {
           return paymentMappings;
        }
        else
        {
            throw new CommonException('Please select a payment mode other than Digital.');
        }
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    */
    
    // Encrypt Data
   /* @AuraEnabled
    public static String getEncryptedData(String data){
       try
       {
        System.debug('**data**'+data);
        System.debug('**cryptokey**'+EncodingUtil.base64Encode(CRYPTOKEY));
        
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256',CRYPTOKEY,Blob.valueOf(data));
        System.debug('**blob data**'+encryptedData);
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedData),'UTF-8');
       }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }*/
    
    // Decrypt Data
    @AuraEnabled
    public static String getDecryptedData(String data){
        try
        {
            return Utility.getDecryptedData(data);
        /*System.debug('**data**'+data);
        System.debug('**cryptokey**'+EncodingUtil.base64Encode(CRYPTOKEY));
        //Blob KeyValue = Blob.valueOf(key);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256',CRYPTOKEY,EncodingUtil.base64Decode(data));
        System.debug('**blob data**'+decryptedData);
        return decryptedData.toString();*/
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*@AuraEnabled
    public static Blob generateKey()
    {
        Blob key = Crypto.generateAesKey(256);
        //String stringKey = EncodingUtil.base64Encode(key);
        return key;
        
    }*/
    
    @AuraEnabled
    public static void sendEOILink(String opprecordId,Decimal Amount,String towerId,Map<String,String> offerDetails, String paymentGateway)
    {
        System.debug('offerDeta*'+offerDetails);
        String customerEmail='';
        try
        {
        Opportunity opportunityRec = Utility.getOpportunityRecord(opprecordId);
        Id eoiRecordTypeId =Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
        for(RW_Digital_Link_Status__c eoiLink : opportunityRec.Digital_Link_Status__r)
              {
                  if(eoiLink.RW_Link_Status__c == 'Active' && eoiLink.RecordTypeId == eoiRecordTypeId )
                  {
                      throw new CommonException('There is already an active link sent to the customer. Please check with customer again or change the Link status to \'Expired\' from \'Active\' and then try again to send the link');
                  }
              }
            
        if(opportunityRec !=null)
        {
            customerEmail = opportunityRec.RW_Email__c;
        }
        
        if(!String.isEmpty(customerEmail))
        {
            String eoiRecordId='';
            List<RW_EOI__c> existingEoiRecords = new List<RW_EOI__c>();
            List<RW_EOI__c> existingSentEoiRecords = new List<RW_EOI__c>();
            RW_EOI__c eoiRec;
            if(opportunityRec.EOI__r.size() == 0)
            {
             eoiRec= CreateEOIRecord(opportunityRec,towerId);
             
            }
            else
            {
              for(RW_EOI__c eoiRecs : opportunityRec.EOI__r)
              {
                  if(eoiRecs.RW_Status__c != 'EOI Cancelled -Refunded' && eoiRecs.RW_Status__c != 'EOI Sent to Customer')
                  {
                      existingEoiRecords.add(eoiRecs);
                  }
                  
                  else if(eoiRecs.RW_Status__c == 'EOI Sent to Customer')
                  {
                      System.debug('inside add List*');
                      existingSentEoiRecords.add(eoiRecs);
                      System.debug('inside add List done*');
                      
                  }
                 
                
              }
                if(existingSentEoiRecords.size() >0)
                {
						System.debug('inside if check*'+existingSentEoiRecords.size()+'**'+existingSentEoiRecords);
                     eoiRec = existingSentEoiRecords[0];
                    System.debug('inside if check done*');
                }
                else if(existingEoiRecords.size() >0)
                {
                     throw new CommonException('There is/are already EOI records in this opportunity which are active and not cancelled. Please cancel the existing EOI\'s and then send the link');

                }
                else
                {
                  eoiRec= CreateEOIRecord(opportunityRec,towerId);
                }
              
            }
            system.debug('eoi**'+eoiRec);
            String eoiLinkRecordId = CreateEOILinkRecord(opprecordId);
            String applicableOfferId='';
            if(offerDetails.size() > 0)
            applicableOfferId = CreateApplicableOfferRecord(offerDetails,opportunityRec,eoiRec.Id);
            //String encryptedData = getEncryptedData(opprecordId+','+eoiRec.Id+','+eoiLinkRecordId+','+String.valueOf(Amount)+','+towerId);
            //String encryptedData = Utility.getEncryptedData(opprecordId+','+eoiRec.Id+','+eoiLinkRecordId+','+String.valueOf(Amount)+','+towerId+','+applicableOfferId);
            String encryptedData = Utility.getEncryptedData(opprecordId+','+eoiRec.Id+','+eoiLinkRecordId+','+String.valueOf(Amount)+','+towerId+','+applicableOfferId+','+'EaseBuzz'); /* bkk */
            System.debug('***paymentGateway***'+paymentGateway); /* bkk */
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Form_Link_Customer'];
            String htmlBody = template.HtmlValue; 
            if(eoiRec.RW_Primary_First_Name__c != null)
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
            else
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', '');
            if(eoiRec.RW_Primary_Last_Name__c != null)
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
            else
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', '');
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Project_Name__c}', opportunityRec.RW_Project__r.Name);
            htmlBody = htmlBody.replace('{!EOIFormLink}','<a href="'+Label.Community_URL+'eoi/?data='+encryptedData+'">Click Here'+'</a>' );
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c)!=null)
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c).RW_Phone__c));	
            else
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            
            
           /* if(opportunityRec.RW_Sales_Associate__c != null && opportunityRec.RW_Sales_Associate__c != '')
            htmlBody = htmlBody.replace('{!SMName}', opportunityRec.RW_Sales_Associate__c);
            else
            htmlBody = htmlBody.replace('{!SMName}', 'Runwal Group');  
            */
            
            String plainTextBody = template.Body; 
           	if(eoiRec.RW_Primary_First_Name__c != null)
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
            else
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', '');
            if(eoiRec.RW_Primary_Last_Name__c != null)
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
            else
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', '');   
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Project_Name__c}', opportunityRec.RW_Project__r.Name);
            plainTextBody = plainTextBody.replace('{!EOIFormLink}',  Label.Community_URL+'eoi/?data='+encryptedData);
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c)!=null)
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityRec.RW_Sales_Associate__c).RW_Phone__c));	
            else
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            
           /* if(opportunityRec.RW_Sales_Associate__c != null && opportunityRec.RW_Sales_Associate__c != '')
            plainTextBody = plainTextBody.replace('{!SMName}', opportunityRec.RW_Sales_Associate__c);
            else
            plainTextBody = plainTextBody.replace('{!SMName}', 'Runwal Group');   */
            //OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'Runwal Cares'];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { customerEmail };
            message.setTemplateId(template.Id);
            message.subject = template.Subject;
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            
            //String emailBody = '';
            //message.subject = 'EOI Form Submission Link';
            //emailBody +='Dear '+opportunityRec.Name +',<br/><br/> Please '+'<html><a href="'+Label.Community_URL+'eoi/?data='+encryptedData+'">Click Here'+'</a></html>'+' to fill the EOI form. <br/><br/> Regards,<br/> Runwal Team';
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            String URLMessage = Label.Community_URL+'eoi/?data='+encryptedData;
            List<String> SMSdata = new List<String>();
            System.debug('**before**');
            SMSdata.add(opprecordId);
            SMSdata.add(URLMessage);
            System.debug('**before !**'+opprecordId+'*'+URLMessage);
            EOIOutboundSMSFutureHandler.SendSMSOnEOIInterest(SMSdata);
            if (results[0].success) 
            {
                System.debug('The email is sent successfully');
                
            } 
            
            else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
                throw new CommonException('There was an error sending the EOI link in a mail. Please check with administrator.');
                
            }
            
        }
        
        else
        {
            throw new CommonException('There is no email present in Opportunity. Please add the email in opportunity first and then generate the EOI link');
        }
        }
        
        
     
        
        catch (Exception e)
        {
            //system.debug('*catch*'+e+'**message**'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    
    public static RW_EOI__c CreateEOIRecord(Opportunity oppRecord,String TowerId)
    { 
        try
        {
        Account accRecord = Utility.getAccountFromOpportunityRecord(oppRecord);
        System.debug('**'+accRecord);
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecord.id;
        eoiRecord.Tower__c=TowerId;
        eoiRecord.RW_Primary_First_Name__c = accRecord.FirstName;
        eoiRecord.RW_Primary_Last_Name__c = accRecord.LastName;
        eoiRecord.RW_Status__c='EOI Sent to Customer';
        if(accRecord !=null)
        {
             System.debug('***'+accRecord);
        eoiRecord.RW_City__c =accRecord.City__c;
        eoiRecord.RW_Pin__c =accRecord.RW_Zip_Code__c;
        eoiRecord.RW_State__c = accRecord.State__c;
        eoiRecord.RW_Countries__c = accRecord.Country__c;
        eoiRecord.RW_Primary_Contact_No__c=accRecord.Mobile_No__c;
        //eoiRecord.RW_Primary_Email__c=accRecord.PersonEmail;
        eoiRecord.RW_Primary_Alternate_Email__c = accRecord.Alternate_Email__c;
        eoiRecord.RW_Gender__c =accRecord.Gender__c;
            eoiRecord.RW_Salutation__c = accRecord.Salutation;
            eoiRecord.RW_Date_of_Birth__c = accRecord.Birth_Date__c;
        }
       // eoiRecord.RW_EOI_Link_Expiry__c= dateTime.parse(System.Now().format());
        
        eoiRecord.RW_Primary_Email__c=oppRecord.RW_Email__c;
        eoiRecord.RW_Primary_PAN_Details__c=oppRecord.RW_PAN_Card_Number__c;
        eoiRecord.RW_Secondary_Email__c=oppRecord.RW_Additional_Email__c;
        eoiRecord.RW_Primary_Aadhar_Details__c=oppRecord.RW_AADHAR_Card_Number__c;
        eoiRecord.RW_Primary_Passport_Details__c = oppRecord.RW_Passport_Number__c;
        eoiRecord.RW_Secondary_Email__c = oppRecord.RW_Secondary_Email__c;
        //eoiRecord.RW_Application_Source__c = oppRecord.Walkin_Source__c;
        //eoiRecord.RW_Source_Details__c = oppRecord.Walkin_SubSource__c;
         System.debug('*Before Insert*'+eoiRecord);
        insert eoiRecord;
         System.debug('*After Insert*'+eoiRecord);
        return eoiRecord;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    public static String CreateApplicableOfferRecord(Map<String,String> OfferDetails,Opportunity opportunityRec,String eoiRecordId )
    { 
        try
        {
            System.debug('before'+OfferDetails+'**'+opportunityRec+'**'+eoiRecordId);
           //List<Offer__c> offerRec = [Select Id,(Select Id,Name from Sub_Offers__r Where Name=: OfferDetails.get('subofferName')) from Offer__c where Name=:OfferDetails.get('offerName') and Project__c=:opportunityRec.RW_Project__c and Offer_Type__c='EOI' ];
            List<RW_Sub_Offer__c> subofferRecords = [Select Name,Offer__c,Offer__r.Name,Project__c from RW_Sub_Offer__c Where Project__c=: opportunityRec.RW_Project__c and RW_Offer_Type__c ='EOI' and Name=: OfferDetails.get('subofferName') and Offer__r.Name =:OfferDetails.get('offerName')];
         
            if(subofferRecords != null && subofferRecords.size()>0)
            {
               Applicable_Offer__c applicableOffer = new Applicable_Offer__c(); 
               applicableOffer.EOI__c = eoiRecordId;
               //applicableOffer.Opportunity__c = opportunityRec.Id;
               applicableOffer.Offer__c = subofferRecords[0].Offer__c;
               applicableOffer.Type_Of_Offer__c = 'EOI';
               applicableOffer.Sub_Offer__c = subofferRecords[0].Id;
               insert applicableOffer;
                return applicableOffer.Id;
           }
            else
                return '';
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String CreateEOILinkRecord(String oppRecordId)
    { 
        try
        {
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
               /* RW_EOI_Link_Status__c eoiLink = new RW_EOI_Link_Status__c();
                eoiLink.Opportunity__c = oppRecordId;
                eoiLink.RW_EOI_Link_Status__c = 'Active';
                eoiLink.RW_EOI_Link_Sent_Time__c = LinkSentTime;
                insert eoiLink; */
                //return eoiLink.Id;
                RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecordId;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        		return digitalLinkStatus.Id;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String CreateDigitalEOIPaymentLinkRecord(String oppRecordId)
    { 
        try
        {
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
               /* RW_EOI_Link_Status__c eoiLink = new RW_EOI_Link_Status__c();
                eoiLink.Opportunity__c = oppRecordId;
                eoiLink.RW_EOI_Link_Status__c = 'Active';
                eoiLink.RW_EOI_Link_Sent_Time__c = LinkSentTime;
                insert eoiLink; */
                //return eoiLink.Id;
                RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecordId;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('Digital EOI Payment').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        		return digitalLinkStatus.Id;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public  static void saveEOIrecord(String recordId,String eoiRecord)
    { 
        try{
            if(recordId != null && eoiRecord != null){
                EOIWrapper obj = (EOIWrapper)JSON.deserialize(eoiRecord, EOIWrapper.class);
                System.debug('**'+obj+'**Org**'+obj.RWOriginDetails);
                RW_EOI__c eoi = new RW_EOI__c();
                eoi.Id=recordId;
                if(eoi.RW_Status__c != 'EOI Confirmed')
                eoi.RW_Status__c = 'EOI Submitted - Payment pending';
                eoi.Tower__c = obj.RWTower;
                eoi.RW_Primary_First_Name__c = obj.RWPrimaryFirstName;
                eoi.RW_Primary_Middle_Name__c = obj.RWPrimaryMiddleName;
                eoi.RW_Primary_Last_Name__c = obj.RWPrimaryLastName;
                eoi.RW_Company_Name__c = obj.RWNameofCompany;
                eoi.RW_Residential_Company_Address__c = obj.RWResidentialCompanyAddress;
                eoi.RW_Date_of_Birth__c = obj.RWDateOfBirth;
                eoi.RW_Pin__c = obj.RWPin;
                eoi.RW_State__c=obj.RWState;
                eoi.RW_Countries__c = obj.RWCountry;
                eoi.RW_City__c = obj.RWCity;
                eoi.RW_Country_Phone_Code__c =obj.RWCountryPhoneCode;
                eoi.RW_Primary_Contact_No__c =obj.RWPrimaryContactNo;
                eoi.RW_Primary_Email__c = obj.RWPrimaryEmail;
                eoi.RW_Primary_PAN_Details__c = obj.RWPANDetails;
                eoi.RW_Primary_Alternate_Email__c = obj.RWPrimaryAlternateEmail;
                eoi.RW_Primary_Aadhar_Details__c = obj.RWPrimaryAadharDetails;
                eoi.RW_Primary_Passport_Details__c = obj.RWPrimaryPassportDetails;
                eoi.RW_Alternate_Contact_No__c = obj.RWPrimaryAlternateContactNo;
                
                eoi.RW_Secondary_First_Name__c = obj.RWSecondaryFirstName;
                eoi.RW_Secondary_Middle_Name__c = obj.RWSecondaryMiddleName;
                eoi.RW_Secondary_Last_Name__c = obj.RWSecondaryLastName;
				eoi.RW_Secondary_Contact_No__c =obj.RWSecondaryContactNo;
                eoi.RW_Secondary_Email__c = obj.RWSecondaryEmail;
                eoi.RW_Secondary_PAN_Details__c = obj.RWSecondaryPANDetails;
                eoi.RW_Secondary_Alternate_Email__c = obj.RWSecondaryAlternateEmail;
                eoi.RW_Secondary_Aadhar_Details__c = obj.RWSecondaryAadharDetails;
                eoi.RW_Secondary_Passport_Details__c = obj.RWSecondaryPassportDetails;
                
                eoi.RW_Preferred_Unit_Type__c =obj.RWPreferredUnitType;
                eoi.RW_Preferred_Budget__c=obj.RWPreferredBudget;
                eoi.RW_Preferred_Floors__c=obj.RWPreferredFloors;
                eoi.RW_Any_other_preference_please_specify__c=obj.RWAnyotherpreferencepleasespecify;
                eoi.RW_Preferred_Unit_No__c = obj.RWPreferredUnitNo;
                eoi.RW_Tentative_Agreement_Value__c =obj.RWTentativeAgreementValue;
                eoi.RW_Tentative_All_Inclusive_Price__c =obj.RWTentativeAllInclusivePrice;
                if(obj.RWOptin != null)
                eoi.RW_Opt_In__c = Boolean.valueOf(obj.RWOptin);
                if(obj.BillDeskTC != null)
                eoi.BillDesk_Terms_And_Conditions__c = Boolean.valueOf(obj.BillDeskTC); /* bkk */
                eoi.RW_Document_Number__c=obj.RWDocumentNumber;
                eoi.RW_Document_Proof__c = obj.RWDocumentProof;

                System.debug('**'+obj+'**Org1**'+obj.RWOriginDetails);
                eoi.RW_Type_Of_Origin__c = obj.RWTypeOfOrigin;
                eoi.RW_Origin_Details__c =obj.RWOriginDetails;
                System.debug('**Org2**'+eoi.RW_Origin_Details__c);
                eoi.RW_Pan_Card_Number_of_AuthoritySignatory__c = obj.RWPanCardNumberofAuthoritySignatory;
                eoi.RW_PassportNoDetails__c = obj.RWPassportNoDetails;
                eoi.RW_Channel_Partner_s_Company__c =obj.RWChannelPartnersCompany;
                
                eoi.RW_Permanent_Address_Line_1__c = obj.RWPermanentAddressLine1;
                eoi.RW_Permanent_Address_Line_2__c = obj.RWPermanentAddressLine2;
                eoi.RW_Permanent_Address_Line_3__c = obj.RWPermanentAddressLine3;
                if(obj.MailPermAddrSame != null)
                eoi.RW_Mailing_and_Permanent_Address_Same__c = obj.MailPermAddrSame;
                eoi.RW_Mailing_Address_Line_1__c = obj.RWMailingAddressLine1;
                eoi.RW_Mailing_Address_Line_2__c = obj.RWMailingAddressLine2;
                eoi.RW_Mailing_Address_Line_3__c = obj.RWMailingAddressLine3;
                
                eoi.RW_Mailing_Pin__c = obj.RWMailingPin;
                 if(obj.RWMailingState != null && obj.RWMailingState !='')
                eoi.RW_Mailing_State__c=obj.RWMailingState;
                if(obj.RWMailingCountry != null && obj.RWMailingCountry !='')
                eoi.RW_Mailing_Country__c = obj.RWMailingCountry;
                eoi.RW_Mailing_City__c = obj.RWMailingCity;
                
                eoi.RW_Gender__c = obj.RWGender;
                eoi.RW_Marital_Status__c = obj.RWMaritalStatus;
                eoi.RW_Designation__c = obj.RWDesignation;
                eoi.RW_Occupation__c = obj.RWOccupation;
                eoi.RW_Nationality__c = obj.RWNationality;
                eoi.RW_Digitally_Accepted_On__c = DateTime.parse(obj.RWDigitallyAcceptedOn);
                
                System.debug('before'+obj.RWTypeofapplicant);
                if(obj.RWTypeofapplicant == '' ||  obj.RWTypeofapplicant == null)
                {
                    System.debug('inside'+obj.RWTypeofapplicant);
                    eoi.RW_Type_Of_Applicant__c = null;
                }
                else
                eoi.RW_Type_Of_Applicant__c = obj.RWTypeofapplicant;
                
                if(obj.RWResidentialstatus == '' ||  obj.RWResidentialstatus == null)
                {
                    eoi.RW_Residential_Status__c = null;
                }
                else
                eoi.RW_Residential_Status__c = obj.RWResidentialstatus;
                
                System.debug('**Org2**'+eoi.RW_Origin_Details__c+'**'+eoi);
                
                //Added by coServe 09-10-2024 Start
                eoi.Landline_No__c = obj.LandlineNo;
                eoi.Customer_GST_No__c = obj.CustomerGST;
                eoi.Home_Loan__c = obj.HomeLoan;
                eoi.Secondary_Alternate_Contact_No__c = obj.SecondaryAlternateContactNo;
                eoi.Secondary_Landline_No__c = obj.SecondaryLandline;
                eoi.Secondary_Nationality__c = obj.SecondaryNationality;
                eoi.Secondary_Home_Loan__c = obj.SecondaryHomeloan;
                eoi.Draft_Cheque_No__c = obj.DraftChequeNo;
                eoi.Draft_Cheque_Date__c = obj.DraftChequeDate;
                eoi.Bank_Name__c = obj.BankName;
                eoi.Source_Details__c = obj.SourceDetails;
                eoi.Channel_Partner_Contact_No__c = obj.ChannelPartnerContactNo;
                eoi.Channel_Partner_Email__c = obj.ChannelPartnerEmail;	
                eoi.Preferred_Size__c = obj.PreferredSize;	
                eoi.EOI_Amount__c = obj.EOIAmount;
                //Added by coServe 09-10-2024 End
                
                upsert eoi;

               List<RW_EOI__c> eoiRec = [Select Id,Name,RW_City__c,RW_State__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Date_of_Birth__c,RW_Gender__c,RW_Salutation__c,RW_Primary_Alternate_Email__c,RW_Countries__c,RW_Pin__c,Opportunity__c, Opportunity__r.AccountId, (Select Id,Sub_Offer__r.RW_Status__c from Applicable_Offers__r Where Sub_Offer__r.RW_Status__c='Active') from RW_EOI__c where Id =:eoi.Id];
               List<Applicable_Offer__c> applicableOffers = new List<Applicable_Offer__c>();
                for(RW_EOI__c eoiRecValue : eoiRec )
               {
                   if(eoiRecValue.Applicable_Offers__r.size() >0)
                   {
                       for(Applicable_Offer__c appOffers : eoiRecValue.Applicable_Offers__r)
                       {
                           appOffers.Offer_Availed__c = true;
                           applicableOffers.add(appOffers);
                       }
                   }
               }
                if(applicableOffers.size() >0)
                {
                    update applicableOffers;
                }
                
                if(eoiRec !=null && eoiRec.size() >0 )
                {
                    System.debug('inside if1*'+eoiRec);
                Account accRecord = Utility.getAccountFromOpportunityRecord(eoiRec[0].Opportunity__r);
                accRecord.FirstName = eoiRec[0].RW_Primary_First_Name__c;
                accRecord.LastName = eoiRec[0].RW_Primary_Last_Name__c;
              
                accRecord.City__c = eoiRec[0].RW_City__c;
                accRecord.RW_Zip_Code__c =  eoiRec[0].RW_Pin__c ;
                accRecord.State__c =eoiRec[0].RW_State__c ;
                accRecord.Country__c=eoiRec[0].RW_Countries__c;
                //accRecord.Mobile_No__c=eoiRec[0].RW_Primary_Contact_No__c;
                accRecord.Alternate_Email__c = eoiRec[0].RW_Primary_Alternate_Email__c;
                accRecord.Gender__c= eoiRec[0].RW_Gender__c;
                accRecord.Birth_Date__c = eoiRec[0].RW_Date_of_Birth__c;
                     System.debug('inside if1 before update*'+eoiRec);
                    update accRecord;
                    System.debug('inside if1 after update*'+eoiRec);
                    
                    Opportunity opp = Utility.getOpportunityRecord(eoiRec[0].Opportunity__c);
                    String Name ='';
                    
                    if(eoiRec[0].RW_Primary_First_Name__c != '' && eoiRec[0].RW_Primary_First_Name__c != null)
                    {
                        Name = Name+eoiRec[0].RW_Primary_First_Name__c;
                    }
                    
                    if(eoiRec[0].RW_Primary_Last_Name__c != '' && eoiRec[0].RW_Primary_Last_Name__c != null)
                    {
                        if(Name !='')
                        Name = Name+' '+eoiRec[0].RW_Primary_Last_Name__c;
                        else
                        Name = eoiRec[0].RW_Primary_Last_Name__c;    
                    }
                    
                    if(opp.Name != Name)
                    {
                    opp.Name = Name;
                    update opp;
                    }
                }
                
            }
            
        } catch (Exception ex){
            System.debug('Exception:'+ex);
        }
        
    }
    
    
    @AuraEnabled
    public static EOIWrapper loadEOIdata(String eoiRecordId)
    { 
        try
        {
        	System.debug('**'+eoiRecordId);
            EOIWrapper eoiWrap = new EOIWrapper();
            if(eoiRecordId != null)
            {
                RW_EOI__c eoiRecord = Utility.getEOIRecord(eoiRecordId);
                System.debug('**'+eoiRecord);
                eoiWrap.Id=eoiRecord.Id;
                eoiWrap.RWName=eoiRecord.Name;
                eoiWrap.RWTowerName=eoiRecord.Tower__r.Name;
                eoiWrap.RWPrimaryFirstName=eoiRecord.RW_Primary_First_Name__c;
                eoiWrap.RWPrimaryMiddleName=eoiRecord.RW_Primary_Middle_Name__c;
                 eoiWrap.RWPrimaryLastName=eoiRecord.RW_Primary_Last_Name__c;
                 eoiWrap.RWNameofCompany=eoiRecord.RW_Company_Name__c;
                 eoiWrap.RWResidentialCompanyAddress=eoiRecord.RW_Residential_Company_Address__c;
                eoiWrap.RWCity=eoiRecord.RW_City__c;
                eoiWrap.RWDateOfBirth=eoiRecord.RW_Date_of_Birth__c;
                 eoiWrap.RWPin=eoiRecord.RW_Pin__c;
                eoiWrap.RWState=eoiRecord.RW_State__c;
                eoiWrap.RWCountry=eoiRecord.RW_Countries__c;
                 eoiWrap.RWCountryPhoneCode =eoiRecord.RW_Country_Phone_Code__c;
                eoiWrap.RWPrimaryContactNo= eoiRecord.RW_Primary_Contact_No__c;
                 eoiWrap.RWPrimaryAlternateContactNo= eoiRecord.RW_Alternate_Contact_No__c;
                eoiWrap.RWPrimaryEmail=eoiRecord.RW_Primary_Email__c ;
                eoiWrap.RWPANDetails=eoiRecord.RW_Primary_PAN_Details__c ;
                 eoiWrap.RWPrimaryAlternateEmail=eoiRecord.RW_Primary_Alternate_Email__c;
                 eoiWrap.RWPrimaryAadharDetails=eoiRecord.RW_Primary_Aadhar_Details__c;
                eoiWrap.RWPrimaryPassportDetails=eoiRecord.RW_Primary_Passport_Details__c ;
                
                 eoiWrap.RWSecondaryFirstName=eoiRecord.RW_Secondary_First_Name__c;
                 eoiWrap.RWSecondaryMiddleName=eoiRecord.RW_Secondary_Middle_Name__c;
                 eoiWrap.RWSecondaryLastName=eoiRecord.RW_Secondary_Last_Name__c;
				 eoiWrap.RWSecondaryContactNo=eoiRecord.RW_Secondary_Contact_No__c;
                eoiWrap.RWSecondaryEmail= eoiRecord.RW_Secondary_Email__c;
                eoiWrap.RWSecondaryPANDetails=eoiRecord.RW_Secondary_PAN_Details__c ;
                eoiWrap.RWSecondaryAlternateEmail=eoiRecord.RW_Secondary_Alternate_Email__c ;
                eoiWrap.RWSecondaryAadharDetails=eoiRecord.RW_Secondary_Aadhar_Details__c ;
               eoiWrap.RWSecondaryPassportDetails= eoiRecord.RW_Secondary_Passport_Details__c ;
                
                 eoiWrap.RWPreferredUnitType=eoiRecord.RW_Preferred_Unit_Type__c;
                eoiWrap.RWPreferredBudget=eoiRecord.RW_Preferred_Budget__c;
                eoiWrap.RWPreferredFloors=eoiRecord.RW_Preferred_Floors__c;
                eoiWrap.RWAnyotherpreferencepleasespecify=eoiRecord.RW_Any_other_preference_please_specify__c;
                 eoiWrap.RWPreferredUnitNo=eoiRecord.RW_Preferred_Unit_No__c;
                eoiWrap.RWTentativeAgreementValue=eoiRecord.RW_Tentative_Agreement_Value__c ;
                 eoiWrap.RWTentativeAllInclusivePrice=eoiRecord.RW_Tentative_All_Inclusive_Price__c;
                eoiWrap.RWApplicationSource =eoiRecord.RW_Application_Source__c;
                eoiWrap.RWSourceDetails= eoiRecord.RW_Sub_Source__c;
                 eoiWrap.RWClosingType=eoiRecord.RW_Closing_Type__c;
                 eoiWrap.RWChannelPartnersName=eoiRecord.RW_Channel_Partner_s_Name__c;
                eoiWrap.RWChannelPartnersCompany=eoiRecord.RW_Channel_Partner_s_Company__c;
                eoiWrap.RWSourceContactNo= eoiRecord.RW_Source_Contact_No__c;
                 eoiWrap.RWRERANo=eoiRecord.RW_Source_RERA_No__c;
                eoiWrap.RWSourceEmailId= eoiRecord.RW_Source_Email_Id__c;
                
                eoiWrap.RWDocumentNumber =eoiRecord.RW_Document_Number__c;
                eoiWrap.RWDocumentProof =eoiRecord.RW_Document_Proof__c;
                
                if(eoiRecord.RW_Type_Of_Origin__c != null && eoiRecord.RW_Type_Of_Origin__c != '')
                eoiWrap.RWTypeOfOrigin =eoiRecord.RW_Type_Of_Origin__c;
                eoiWrap.RWOriginDetails = eoiRecord.RW_Origin_Details__c ;
                eoiWrap.RWPanCardNumberofAuthoritySignatory =eoiRecord.RW_Pan_Card_Number_of_AuthoritySignatory__c;
                eoiWrap.RWPassportNoDetails =eoiRecord.RW_PassportNoDetails__c;
                
                
                eoiWrap.RWPermanentAddressLine1 = eoiRecord.RW_Permanent_Address_Line_1__c;
                 eoiWrap.RWPermanentAddressLine2 = eoiRecord.RW_Permanent_Address_Line_2__c;
                 eoiWrap.RWPermanentAddressLine3 = eoiRecord.RW_Permanent_Address_Line_3__c;
                
               
                
                 eoiWrap.RWMailingAddressLine1 = eoiRecord.RW_Mailing_Address_Line_1__c;
                 eoiWrap.RWMailingAddressLine2 = eoiRecord.RW_Mailing_Address_Line_2__c;
                 eoiWrap.RWMailingAddressLine3 = eoiRecord.RW_Mailing_Address_Line_3__c;
                
                 eoiWrap.RWMailingPin=eoiRecord.RW_Mailing_Pin__c;
                eoiWrap.RWMailingState=eoiRecord.RW_Mailing_State__c;
                eoiWrap.RWMailingCountry=eoiRecord.RW_Mailing_Country__c;
                
                 eoiWrap.RWMailingCity=eoiRecord.RW_Mailing_City__c;
                
                eoiWrap.RWGender = eoiRecord.RW_Gender__c;
                 eoiWrap.RWMaritalStatus = eoiRecord.RW_Marital_Status__c;
                eoiWrap.RWDesignation = eoiRecord.RW_Designation__c;
                eoiWrap.RWOccupation = eoiRecord.RW_Occupation__c;
                eoiWrap.RWNationality = eoiRecord.RW_Nationality__c;
                
                eoiWrap.RWTypeofapplicant = eoiRecord.RW_Type_Of_Applicant__c;
                eoiWrap.RWResidentialstatus = eoiRecord.RW_Residential_Status__c;
                
                eoiWrap.MailPermAddrSame = eoiRecord.RW_Mailing_and_Permanent_Address_Same__c;
                eoiWrap.RWOptin = eoiRecord.RW_Opt_In__c;
                eoiWrap.BillDeskTC = eoiRecord.BillDesk_Terms_And_Conditions__c; /* bkk */
                
                //Added by coServe 09-10-2024 Start
                eoiWrap.LandlineNo = eoiRecord.Landline_No__c;
                eoiWrap.CustomerGST = eoiRecord.Customer_GST_No__c;
                eoiWrap.HomeLoan = eoiRecord.Home_Loan__c;
                eoiWrap.SecondaryAlternateContactNo = eoiRecord.Secondary_Alternate_Contact_No__c;
                eoiWrap.SecondaryLandline = eoiRecord.Secondary_Landline_No__c;
                eoiWrap.SecondaryNationality = eoiRecord.Secondary_Nationality__c;
                eoiWrap.SecondaryHomeloan = eoiRecord.Secondary_Home_Loan__c;
                eoiWrap.DraftChequeNo = eoiRecord.Draft_Cheque_No__c;
                eoiWrap.DraftChequeDate = eoiRecord.Draft_Cheque_Date__c;
                eoiWrap.BankName = eoiRecord.Bank_Name__c;
                eoiWrap.SourceDetails = eoiRecord.Source_Details__c;
                eoiWrap.ChannelPartnerContactNo = eoiRecord.Channel_Partner_Contact_No__c;
                eoiWrap.ChannelPartnerEmail = eoiRecord.Channel_Partner_Email__c;
                eoiWrap.PreferredSize = eoiRecord.Preferred_Size__c;
                eoiWrap.EOIAmount = eoiRecord.EOI_Amount__c;
                //Added by coServe 09-10-2024 End
                
                List<Payment_Gateway__mdt > payments =  Utility.getPaymentGatewayDetails( eoiRecord.RW_Project_Name__c,eoiRecord.Tower__r.Name );

                 if(payments.size() > 0)
                 {
                 eoiWrap.gateway = payments[0];
                 eoiWrap.paymentGatewayAvailable = true;
                 }
                else
                {
                 eoiWrap.paymentGatewayAvailable = false;
                }
                
            }

            return eoiWrap;
            
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
       
        
    }
    
    
    @AuraEnabled
    public static OpportunityWrapper loadOpportunityData(String oppRecordId)
    { 
        try
        {
         OpportunityWrapper oppWrap = new OpportunityWrapper();
            if(oppRecordId != null)
            {
                Opportunity oppRecord = Utility.getOpportunityRecord(oppRecordId);
                oppWrap.OpportunityName = oppRecord.Name;
                oppWrap.Email = oppRecord.RW_Email__c;
                oppWrap.MobileNumber = oppRecord.RW_Mobile_No__c;
                oppWrap.ProjectName = oppRecord.RW_Project__r.Name;
                
            }
        return oppWrap;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   @AuraEnabled
    public static String checkLinkExpiry(String eoiLinkRecordId)
    { 
        try
        {
        if(eoiLinkRecordId != null)
        {
        RW_Digital_Link_Status__c eoiLinkRec = Utility.digitalLinkStatusRecord(eoiLinkRecordId);
        if(eoiLinkRec.RW_Link_Status__c == 'Expired')
        {
            return 'Expired';
        }
        
        else
        {
        return 'Active';
        }
        }
        else
            throw new CommonException('Error Fetching Digital Link Data.');
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> retreiveStatesList(String ObjectApiName , String FieldName)
    { 
        try
        {
        List<String> StatesList = Utility.getGlobalPicklists(ObjectApiName, fieldName);
        return StatesList;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<String> retreiveCountryList(String ObjectApiName , String FieldName)
    { 
        try
        {
        List<String> CountriesList = Utility.getGlobalPicklists(ObjectApiName, fieldName);
        return CountriesList;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
   /* @AuraEnabled
    public static List<String> retreiveCountryPhoneCode(String ObjectApiName , String FieldName)
    { 
        try
        {
        List<String> CountryPhoneCodeList = Utility.getGlobalPicklists(ObjectApiName, fieldName);
        return CountryPhoneCodeList;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    
    @AuraEnabled
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
    
    /* @AuraEnabled
    public static List<ApplicableOfferWrapper> getApplicableOfferRecords(String recordId,String offerType)
        {
            try
            {
            List<Applicable_Offer__c> offers =Utility.getApplicableOfferRecords(recordId,offerType);
            List<ApplicableOfferWrapper> appOffWrap = new List<ApplicableOfferWrapper>();
            if(offers!= null && offers.size() >0)
            {
                for(Applicable_Offer__c offerRec : offers)
                {
                    ApplicableOfferWrapper Wrap = new ApplicableOfferWrapper();
                    Wrap.RWOfferName = offerRec.Offer__r.Name;
                    Wrap.RWSubofferName = offerRec.RW_Sub_Offer_Name__c;
                    Wrap.RWValidTill = String.valueOf(offerRec.RW_End_Date__c);
                    appOffWrap.add(Wrap);
                	
                }
                
                return appOffWrap;
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
     /*@AuraEnabled
    public static List<Applicable_Offer__c> getOfferRecordforDigitalForm(String recordId,String offerType)
        {
            try
            {
            List<Applicable_Offer__c> offers =Utility.getApplicableOfferRecords(recordId,offerType);
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
    
    @AuraEnabled
    public static List<Applicable_Offer__c> getEOIApplicableOffers(String recordId,String applicableOfferId)
        {
            try
            {
            if(recordId != null && recordId !='' && applicableOfferId != null && applicableOfferId != '')
            {
            List<Applicable_Offer__c> applicableOfferRecord = [SELECT Id,Offer__c, Offer__r.Name ,RW_Offer_Name__c, RW_Sub_Offer_Name__c ,RW_End_Date__c,opportunity__c FROM Applicable_Offer__c WHERE EOI__c= :recordId and Id =:applicableOfferId];
            
                
            if(applicableOfferRecord!= null && applicableOfferRecord.size() >0)
            {  
                return applicableOfferRecord;
            }
            else
                return null;
            }
                else
            {
                return null;
            }
            }
            
            catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        }
    
    
    @AuraEnabled
    public static String getLoggedInProfileName()
        {
            try
            {
            String profileName =Utility.getLoggedInProfileName();
            return profileName;
            }
            catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        }
    
    @auraEnabled
    public static string getPaymentResponseDecryptedData(String inputdata,String decryptionKey){
        try
        {
            
       // Blob cryptoKey = Blob.valueOf('E9A2B6448EB867A7A9E622341452EECF');
        Blob cryptoKey = Blob.valueOf(decryptionKey);
        Blob hash = Crypto.generateDigest('MD5', cryptoKey);
        Blob data = EncodingUtil.convertFromHex(inputdata); //Received from ccAvenue response
        Blob decryptedText = Crypto.decryptWithManagedIV('AES128', hash, data);
        String PLAIN_TEXT = decryptedText.toString();
            //throw new AuraHandledException('test');
        return PLAIN_TEXT;
        }
        catch(Exception e)
        {
            System.debug('Exception is'+ e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static string encrypt(String inputdata,String encryptionKey){
        //Blob cryptoKey = Blob.valueOf('E9A2B6448EB867A7A9E622341452EECF');
        try
        {
        Blob cryptoKey = Blob.valueOf(encryptionKey);
        Blob hash = Crypto.generateDigest('MD5', cryptoKey );
        Blob data = Blob.valueOf(inputdata);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', hash , data);     
        String encRequest = EncodingUtil.convertToHex(encryptedData );
        system.debug(encRequest);
       // system.debug(decrypt(encRequest));
        return encRequest;
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     @AuraEnabled
    public static void insertPartialPaymentDetails(Map<String,String> details)
    {
        try
        {
            
        
        system.debug('**'+details);
         List<String> toAddress = new List<String>();
          Set<String> eoiSalesManagerSet = new Set<String>();
        Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
        Map<Id,List<String>> projectTeamEmailIds = new Map<Id,List<String>>();
        Set<Id> ProjetRecIds = new Set<Id>();
         Opportunity opp = [Select Id,RW_Project__c from Opportunity Where id =:details.get('oppRecId')];
         Receipt__c receipt = new Receipt__c();
         receipt.Mode__c = 'Digital';
         receipt.Cheque_DD__c = details.get('paymentTrackingId');
         receipt.RW_Digital_Payment_Mode__c = details.get('paymentMode');
         receipt.Cheque_DD_Date__c = Date.parse(details.get('paymentDate').split(' ')[0]);
         receipt.Total_Amount__c = decimal.valueOf(details.get('paymentAmount'));
          receipt.RW_Payment_Collection_Type__c='EOI';
          receipt.EOI__c=details.get('eoiRecId');
         //receipt.DraweeBank__c = obj.RWBankName;
         receipt.Opportunity__c = details.get('oppRecId');
          receipt.Project__c = opp.RW_Project__c;
            
         insert receipt;
            
        RW_EOI__c eoiRec =[Select Id,Name,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.SAP_Customer_Number__c, Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id =: details.get('eoiRecId')];
        
           if(eoiRec.Opportunity__r.RW_Sales_Associate__c != null)
           eoiSalesManagerSet.add(eoiRec.Opportunity__r.RW_Sales_Associate__c);
           ProjetRecIds.add(eoiRec.Opportunity__r.RW_Project__c);
        
            
            Set<Id> teamIds = new Set<Id>();
           List<Team__c> teamRecord = [Select id from Team__c where Team_Type__c ='MIS' and Project__c IN:ProjetRecIds] ;
           if(teamRecord != null && teamRecord.size() >0)
           {
               for(Team__c teamRec : teamRecord)
               {
                   teamIds.add(teamRec.Id);
               }
           }
             
           List<Team_Members__c> teamMembers = [Select Id,Email_Id__c,Team__r.Project__c from Team_Members__c where Team__c IN :teamIds];
           for(Team_Members__c teammem : teamMembers)
           {

               if(projectTeamEmailIds.containsKey(teammem.Team__r.Project__c))
               {
                  List<String> emailIdValues =  projectTeamEmailIds.get(teammem.Team__r.Project__c);
                  emailIdValues.add(teammem.Email_Id__c);
                  projectTeamEmailIds.put(teammem.Team__r.Project__c,emailIdValues);
               }
               else
               {
                   projectTeamEmailIds.put(teammem.Team__r.Project__c,new List<String>{teammem.Email_Id__c});
               }
           }
        
        
            List<User> userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet];
            if(userRec != null && userRec.size() >0)
            {
                for(User u : userRec)
                eoiSalesManagerEmailIds.put(u.Name,u.Email);
            }
            
             if(projectTeamEmailIds.containsKey(eoiRec.Opportunity__r.RW_Project__c))
            {
                if(projectTeamEmailIds.get(eoiRec.Opportunity__r.RW_Project__c) != null && projectTeamEmailIds.get(eoiRec.Opportunity__r.RW_Project__c).size() >0)
                toAddress.addAll(projectTeamEmailIds.get(eoiRec.Opportunity__r.RW_Project__c));
            }

            if(eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__c != null && eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null )
            toAddress.add(eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);

            if(eoiRec.Opportunity__r.RW_Sales_Associate__c != null && eoiSalesManagerEmailIds.containsKey(eoiRec.Opportunity__r.RW_Sales_Associate__c))
            {
                toAddress.add(eoiSalesManagerEmailIds.get(eoiRec.Opportunity__r.RW_Sales_Associate__c));
            }
            
            
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Partial_Payment'];
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            htmlBody = htmlBody.replace('{!Amount}', details.get('paymentAmount'));
            htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+details.get('eoiRecId'));
        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            plainTextBody = plainTextBody.replace('{!Amount}', details.get('paymentAmount'));
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+details.get('eoiRecId'));
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);   
            
             List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =: details.get('digitalLinkId')];
         if(digitalLinkRec != null && digitalLinkRec.size() >0)
         {
             digitalLinkRec[0].RW_Link_Status__c ='Expired';
             update digitalLinkRec[0];
         }
        }
        
       
        
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static void insertPaymentDetails(Map<String,String> details)
    {
        try
        {
            
        
        system.debug('**'+details);
         List<String> toAddress = new List<String>();
       /* RW_Payment_Details__c paydet = new RW_Payment_Details__c();
        paydet.Opportunity__c = details.get('oppRecId');
        paydet.RW_Bank_Reference_Number__c = details.get('bankReferenceNumber');
        paydet.RW_Transaction_Id__c = details.get('paymentTrackingId');
        paydet.RW_Payment_Amount__c = decimal.valueOf(details.get('paymentAmount'));
        paydet.RW_Payment_Mode__c = details.get('paymentMode');
         system.debug('*before*'+details);
        insert paydet;*/
        
         System.debug('before Insert');
         Opportunity opp = [Select Id,RW_Project__c from Opportunity Where id =:details.get('oppRecId')];
         Receipt__c receipt = new Receipt__c();
         receipt.Mode__c = 'Digital';
         receipt.Cheque_DD__c = details.get('paymentTrackingId');
         receipt.RW_Digital_Payment_Mode__c = details.get('paymentMode');
         receipt.Cheque_DD_Date__c = Date.parse(details.get('paymentDate').split(' ')[0]);
         receipt.Total_Amount__c = decimal.valueOf(details.get('paymentAmount'));
          receipt.RW_Payment_Collection_Type__c='EOI';
          receipt.EOI__c=details.get('eoiRecId');
         //receipt.DraweeBank__c = obj.RWBankName;
         receipt.Opportunity__c = details.get('oppRecId');
         receipt.Project__c = opp.RW_Project__c;
         
         insert receipt;
        RW_EOI__c eoiRecord = [Select id,Name,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,Opportunity__r.RW_Project__c,RW_Project_Name__c,Opportunity__c,Opportunity__r.RW_Sales_Associate__c,RW_EOI_Acknowledgment_Sent__c,RW_EOI_Acknowledgement_Sent_Date_Time__c from RW_EOI__c where id= : details.get('eoiRecId')];
        /*Team_Email_IDs__mdt[] teamEmails = [SELECT Id,Email_IDs__c FROM Team_Email_IDs__mdt Where DeveloperName ='Sales' or DeveloperName ='MIS' or DeveloperName='Accounts'];
            if(teamEmails != null && teamEmails.size() >0)
            {
                for(Team_Email_IDs__mdt emailData : teamEmails)
                {
                    toAddress.add(emailData.Email_IDs__c);
                }
            }
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_EOI_Payment'];
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRecord.Id);
        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRecord.Id);
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        */
        
            
         
         if(eoiRecord.RW_Status__c != 'EOI Confirmed')
         {
             eoiRecord.RW_Status__c = 'EOI Confirmed';
             eoiRecord.RW_EOI_Acknowledgment_Sent__c = 'Yes';
             eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c =  DateTime.now();
             update eoiRecord;
         }
         
         List<String> emailIds = Utility.getExternalTeamEmailIds(new List<String>{'CRM Team','Accounts','Sales Approvers Team'},eoiRecord.Opportunity__r.RW_Project__c);
             
             if(emailIds.size() >  0)
             {
                toAddress.addAll(emailIds);
             }   
          
            PageReference pdf = Page.CustomerEOIForm;
            pdf.getParameters().put('eoiId',eoiRecord.Id);
            Blob body;
            if(!Test.isRunningTest())
            body= pdf.getContent();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('EOIForm.pdf');
            attach.setInline(false);
            if(body != null)
            attach.Body = body;
            
         EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Confirmed_Customer'];
        	String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c)!=null)
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
            else
            htmlBody = htmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
              if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c)!=null)
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
            else
            plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { eoiRecord.RW_Primary_Email__c };
            message.subject = template.Subject;
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);  
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            if(toAddress.size() >0)
            message.setCcAddresses(toAddress); // Changed from BCC to CC by coServe 20-092024
            if(attach.body != null)
            message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);   
            
         List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =: details.get('digitalLinkId')];
         if(digitalLinkRec != null && digitalLinkRec.size() >0)
         {
             digitalLinkRec[0].RW_Link_Status__c ='Expired';
             update digitalLinkRec[0];
         }
         system.debug('*after*'+details);
            
            
           List<String> SMSdata = new List<String>();
            System.debug('**before**');
            SMSdata.add(eoiRecord.Opportunity__c);
            SMSdata.add(String.valueOf(System.now().format('dd MMM YYYY')));
            EOIOutboundSMSFutureHandler.SendSMSOnEOIConfirm(SMSdata);    
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static /*List<RW_Payment_Details__c>*/ List<Receipt__c>  getPaymentDetailsOfOpportunity(String oppRecordId,String TransactionId )
    {
      /*List<RW_Payment_Details__c> PaymentRecord =  [Select Id,RW_Transaction_Id__c,RW_Bank_Reference_Number__c from RW_Payment_Details__c Where Opportunity__c =:oppRecordId and RW_Transaction_Id__c =:TransactionId and RW_Bank_Reference_Number__c =:BankRefNumber];
      if(PaymentRecord != null && PaymentRecord.size() >0)
      {
          return PaymentRecord;
      }*/
        try
        { 
      List<Receipt__c> receipt =  [Select Id,Cheque_DD__c from Receipt__c Where Opportunity__c =:oppRecordId and Cheque_DD__c =:TransactionId];
         if(receipt != null && receipt.size() >0)
      {
          return receipt;
      }
       else
       {
           return null;
       }
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
      @AuraEnabled
     public static void savePaymentRecord(String opprecordId, String eoiRecId , String digitalLinkId ,String paymentRecord)
     {
         try
         {
          /* PaymentDetailsWrapper obj = (PaymentDetailsWrapper)JSON.deserialize(paymentRecord, PaymentDetailsWrapper.class);
         RW_Payment_Details__c paymentRec = new RW_Payment_Details__c();
         paymentRec.RW_Instrument_Number__c = obj.RWInstrumentNumber;
         paymentRec.RW_Payment_Date__c = Date.valueOf(obj.RWPaymentDate);
         paymentRec.RW_Payment_Amount__c = Decimal.valueOf(obj.RWPaymentAmount);
         paymentRec.Opportunity__c = oppRecId;
         
         insert paymentRec;*/
         System.debug('**'+opprecordId);
         Opportunity opp = [Select Id,RW_Project__c from Opportunity Where id =:opprecordId];
         PaymentDetailsWrapper obj = (PaymentDetailsWrapper)JSON.deserialize(paymentRecord, PaymentDetailsWrapper.class);
         Receipt__c receipt = new Receipt__c();
         receipt.Mode__c = obj.RWModeOfPayment;
         receipt.Cheque_DD__c = obj.RWInstrumentNumber;
         receipt.Cheque_DD_Date__c = Date.valueOf(obj.RWPaymentDate);
         receipt.Total_Amount__c = Decimal.valueOf(obj.RWPaymentAmount);
         receipt.DraweeBank__c = obj.RWBankName;
         receipt.Opportunity__c = opprecordId;
         receipt.Project__c = opp.RW_Project__c;
         receipt.RW_Payment_Collection_Type__c='EOI';
         receipt.EOI__c=eoiRecId;
         insert receipt;
         System.debug('*done*'+opprecordId);
           
         List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =: digitalLinkId];
         if(digitalLinkRec != null && digitalLinkRec.size() >0)
         {
             digitalLinkRec[0].RW_Link_Status__c ='Expired';
             update digitalLinkRec[0];
         }
           
            RW_EOI__c eoiRecord = [Select id,RW_EOI_Acknowledgment_Sent__c,Name,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.RW_Project__c,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email,RW_EOI_Acknowledgement_Sent_Date_Time__c,Opportunity__c,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c from RW_EOI__c where id= :eoiRecId];
           /*   Messaging.SingleEmailMessage customermessage = new Messaging.SingleEmailMessage();
            customermessage.toAddresses = new String[] { eoiRecord.RW_Primary_Email__c };
            String emailBody = '';
            customermessage.subject = 'EOI Submitted';
            emailBody +='Dear '+eoiRecord.RW_Primary_First_Name__c+' '+eoiRecord.RW_Primary_Last_Name__c +',<br/><br/> Thank you for submitting EOI for '+eoiRecord.RW_Project_Name__c+'. Your Reference number for EOI is '+ eoiRecord.Name +'. <br/><br/> Regards,<br/> Runwal Team';
            customermessage.setHtmlBody(emailBody);    
            Messaging.SingleEmailMessage[] customermessages =   new List<Messaging.SingleEmailMessage> {customermessage};
            Messaging.SendEmailResult[] customerresults = Messaging.sendEmail(customermessages);
         
*/
             
             
             eoiRecord.RW_EOI_Acknowledgment_Sent__c = 'Yes';
             eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c =  DateTime.now();
             update eoiRecord;
         
              List<String> AckToAddress = new List<String>();
              List<String> teamemailIds = Utility.getExternalTeamEmailIds(new List<String>{'CRM Team','Accounts','Sales Approvers Team'},eoiRecord.Opportunity__r.RW_Project__c);
             
             if(teamemailIds.size() >  0)
             {
                AckToAddress.addAll(teamemailIds);
             } 
             
             PageReference pdf = Page.CustomerEOIForm;
            pdf.getParameters().put('eoiId',eoiRecord.Id);
            Blob body;
            if(!Test.isRunningTest())
            body= pdf.getContent();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName('EOIForm.pdf');
            attach.setInline(false);
           	if(body != null)
            attach.Body = body;
             
             EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Confirmed_Customer'];
        	String custhtmlBody = custtemplate.HtmlValue; 
            custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
            custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
            custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.Opportunity__r.RW_Sales_Associate__c)!=null)
            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));
            else
            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');    
            String custplainTextBody = custtemplate.Body; 
            custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
            custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
            custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.Opportunity__r.RW_Sales_Associate__c)!=null)
            custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));
            else
            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');   
            
            Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
            custmessage.toAddresses = new String[] { eoiRecord.RW_Primary_Email__c };
            custmessage.subject = custtemplate.Subject;
            custmessage.setHtmlBody(custhtmlBody);   
            custmessage.setPlainTextBody(custplainTextBody); 
            custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            if(attach.body != null)
            custmessage.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
            if(AckToAddress.size() >0)
            custmessage.setCcAddresses(AckToAddress); // Changed from BCC to CC by coServe 20-092024
            Messaging.SingleEmailMessage[] custmessages =   new List<Messaging.SingleEmailMessage> {custmessage};
            Messaging.SendEmailResult[] custresults = Messaging.sendEmail(custmessages);   
             
             List<String> toAddress = new List<String>();
         //RW_EOI__c eoiRecord = [Select id,Name,RW_Status__c from RW_EOI__c where id= : eoiRecId];
       
             
             List<String> emailIds = Utility.getExternalTeamEmailIds(new List<String>{'MIS'},eoiRecord.Opportunity__r.RW_Project__c);
             
             if(emailIds.size() >  0)
             {
                toAddress.addAll(emailIds);
             }
             
             if(eoiRecord.Opportunity__r.RW_Sales_Associate__c != null)
             {
                 User SalesManager = Utility.getUserRecordByName(eoiRecord.Opportunity__r.RW_Sales_Associate__c);
                 if(SalesManager !=null)
                 toAddress.add(SalesManager.email);    
             }
             
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Offline_Payment'];
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRecord.Id);
            htmlBody = htmlBody.replace('{!PaymentMode}', receipt.Mode__c);        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRecord.Id);
        	plainTextBody = plainTextBody.replace('{!PaymentMode}', receipt.Mode__c); 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(eoiRecord.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null)
            toAddress.add(eoiRecord.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
             
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
           
            List<String> SMSdata = new List<String>();
            System.debug('**before**');
            SMSdata.add(eoiRecord.Opportunity__c);
            SMSdata.add(String.valueOf(System.now().format('dd MMM YYYY')));
            EOIOutboundSMSFutureHandler.SendSMSOnEOIConfirm(SMSdata);    
             
         }
         catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
     }
    
     @AuraEnabled
     public static Map<String,List<String>> getPicklistValuesForFields(String objectName,List<String> fieldNames)
     {
         try
         {
         system.debug('**'+objectName+'****'+fieldNames);
         Map<String,List<String>> picklistValues = new Map<String,List<String>>();
         for(String fieldName : fieldNames)
         {
             picklistValues.put(fieldName,Utility.getPicklistValues(objectName,fieldName));
         }
         system.debug('**'+picklistValues);
         Return picklistValues;
         }
         catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
     }
    
    @AuraEnabled
     public static Map<String,String> getTowersOfProject(String recordId)
     {
         try
         {
         List<String> towerNames = new List<String>();
         //Map<String,List<String>> towerData = new Map<String,List<String>>();
         Map<String,String> towerData = new Map<String,String>();
         Opportunity oppRec = Utility.getOpportunityRecord(recordId);
         
        Projects__mdt[] projMappings = [SELECT Id,Label FROM Projects__mdt Where Label =:oppRec.RW_Project__r.Name];
        if(projMappings != null && projMappings.size() >0)
        {    
             
         Project_Towers__mdt[] towerMappings = [SELECT Id,Label, Projects__c FROM Project_Towers__mdt Where Projects__c = :projMappings[0].Id ];
            if(towerMappings != null && towerMappings.size() >0)
            {
                for(Project_Towers__mdt towers :towerMappings)
                towerNames.add(towers.Label);
            }
             
         List<Tower__c> tRec = [Select Id, Name, ProjectName__c , ProjectName__r.Name from Tower__c where ProjectName__c = : oppRec.RW_Project__c order by Name];
         for(Tower__c towerRec : tRec)
         {
             for(String towers : towerNames)
             {
                 if(towers.equals(towerRec.Name))
                 {
                     towerData.put(towerRec.Id, towers);
                 }
             }
         }
        }
            return towerData;
         }
         catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
         /*towerNames.add(oppRec.RW_Project__r.Name);
         for(Tower__c tower : tRec)
         {
         towerNames.add(tower.Name);
         }
        // towerData.put(oppRec.RW_Project__r.Name , towerNames);
         return towerNames;*/
     }
    
    /*@AuraEnabled
    public static void sendPaymentLink(String opprecordId,Decimal Amount ,String paymentType)
    {
        String customerEmail='';
        try
        {
        Opportunity opportunityRec = Utility.getOpportunityRecord(opprecordId);
        Id eoiRecordTypeId =Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('Digital EOI Payment').getRecordTypeId();
        for(RW_Digital_Link_Status__c eoiLink : opportunityRec.Digital_Link_Status__r)
              {
                  if(eoiLink.RW_Link_Status__c == 'Active' && eoiLink.RecordTypeId == eoiRecordTypeId )
                  {
                      throw new CommonException('There is already an active link sent to the customer. Please check with customer again or change the Link status to \'Expired\' from \'Active\' and then try again to send the link');
                  }
              }
            
        if(opportunityRec !=null)
        {
            customerEmail = opportunityRec.RW_Email__c;
        }
        
        if(!String.isEmpty(customerEmail))
        {
            String eoiRecordId='';
            eoiRecordId =  opportunityRec.EOI__r[0].Id;
            RW_EOI__c eoiRec = [Select id,Name,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c from RW_EOI__c where id= : eoiRecordId];
            String paymentLinkRecordId = CreateDigitalEOIPaymentLinkRecord(opprecordId);
            //String encryptedData = getEncryptedData(opprecordId+','+eoiRecordId+','+paymentLinkRecordId+','+String.valueOf(Amount)+','+paymentType);
            String encryptedData = Utility.getEncryptedData(opprecordId+','+eoiRecordId+','+paymentLinkRecordId+','+String.valueOf(Amount)+','+paymentType);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { customerEmail };
            String emailBody = '';
            String CustomerName = '';
            if(eoiRec.RW_Primary_First_Name__c != null)
            {
                CustomerName = eoiRec.RW_Primary_First_Name__c ;
            }
            
            if(eoiRec.RW_Primary_Last_Name__c != null)
            {
                if(CustomerName != null && CustomerName !='')
                CustomerName = CustomerName + ' ' +eoiRec.RW_Primary_Last_Name__c ;
                else
                CustomerName = eoiRec.RW_Primary_Last_Name__c ;    
            }
            message.subject = 'Digital EOI Payment';
            emailBody +='Dear '+CustomerName+',<br/><br/> Please '+'<html><a href="'+Label.Community_URL+'digital-payment/?data='+encryptedData+'">Click Here'+'</a></html>'+' to make the remaining partial payment for '+paymentType+' amount. <br/><br/> Regards,<br/> Runwal Team';
            message.setHtmlBody(emailBody);    
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) 
            {
                System.debug('The email is sent successfully');
                
            } 
            
            else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
                throw new CommonException('There was an error sending the Payment link in a mail. Please check with administrator.');
                
            }
            
        }
        
        else
        {
            throw new CommonException('There is no email present in Opportunity. Please add the email in opportunity first and then generate the '+paymentType+' Payment link');
        }
        }
        
        
     
        
        catch (Exception e)
        {
            //system.debug('*catch*'+e+'**message**'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }  */
    
  public Static String generateUniqueTransactionId() {
        Blob randomBlob = Crypto.generateAesKey(128);  // Generate 128-bit random key
        String encodedString = EncodingUtil.convertToHex(randomBlob);
        String uniqueId = encodedString.substring(0, 28); // Take first 28 characters

        return uniqueId;
    }    
 @AuraEnabled
 public static String generateHashAndReturnPaymentLink(Id opportunityId, String amount) {
    Opportunity opp = [SELECT Id, Name, Hash__c, Account.Name, Account.PersonEmail, Account.Mobile_No__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

       if (opp == null || opp.Account.PersonEmail == null) {
        throw new AuraHandledException('Opportunity or Account email not found');
    }
    String key = 'OTVO07DZOH';
    String salt = 'AGJCLF10D5';   
    String merchant_txn = EOIController.generateUniqueTransactionId();
    String name = opp.Account.Name;
    String email = opp.Account.PersonEmail;
    String phone = opp.Account.Mobile_No__c;
    String message = 'Payment for Opportunity ' + opp.Name;
    String udf1 = '';
    String udf2 = '';
    String udf3 = '';
    String udf4 = '';
    String udf5 = '';

    
    String hashString = key + '|' + merchant_txn + '|' + name + '|' + email + '|' + phone + '|' + amount + '|' + udf1 + '|' + udf2 + '|' + udf3 + '|' + udf4 + '|' + udf5 + '|' + message + '|' + salt;
    String hash = generateSHA512(hashString);
    System.debug('hash'+hash);
    String paymentLink = callEasebuzzAPI(merchant_txn, amount, name, phone, email, hash, message);
     
    opp.Hash__c = hash;
    update opp;

    return paymentLink; 
}

public static String callEasebuzzAPI(String merchant_txn, String amount, String name, String phone, String email, String hash, String message) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://dashboard.easebuzz.in/easycollect/v1/create');
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');

    Map<String, Object> requestBody = new Map<String, Object>{
        'key' => 'OTVO07DZOH',
        'salt'=>'AGJCLF10D5',
        'merchant_txn' => merchant_txn,
        'amount' => amount,
        'name' => name,
        'phone' => phone,
        'email' => email,
        'hash' => hash,
        'udf1' => '',
        'udf2' => '',
        'udf3' => '',
        'udf4' => '',
        'udf5' => '',
        'message' => message
    };

    request.setBody(JSON.serialize(requestBody));
    System.debug('requestBody::'+requestBody);
    HttpResponse response = http.send(request);
    if (response.getStatusCode() != 200) {
        throw new AuraHandledException('Failed to call Easebuzz API: ' + response.getStatus());
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    if (response.getStatusCode()==200) {
        Map<String, Object> data = (Map<String, Object>) responseMap.get('data');
        return (String) data.get('payment_url'); 
    } else {
        throw new AuraHandledException('Failed to generate payment link: ' + (String) responseMap.get('message'));
    }
}

   
  @AuraEnabled
public static void generateHashAndSendRequest(Id opportunityId, String amount) {
    Opportunity opp = [SELECT Id, Name, Hash__c, Account.Name, Account.PersonEmail, Account.Mobile_No__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
    if (opp == null || opp.Account.PersonEmail == null) {
        throw new AuraHandledException('Opportunity or Account email not found');
    }

    String key = 'OTVO07DZOH';
    String salt = 'AGJCLF10D5';   
    String merchant_txn = EOIController.generateUniqueTransactionId();
    String name = opp.Account.Name;
    String email = opp.Account.PersonEmail;
    String phone = opp.Account.Mobile_No__c;
    String message = 'Payment for Opportunity ' + opp.Name;
    String udf1 = '';
    String udf2 = '';
    String udf3 = '';
    String udf4 = '';
    String udf5 = '';

  
    String hashString = key + '|' + merchant_txn + '|' + name + '|' + email + '|' + phone + '|' + amount + '|' + udf1 + '|' + udf2 + '|' + udf3 + '|' + udf4 + '|' + udf5 + '|' + message + '|' + salt;
    String hash = generateSHA512(hashString);

   
    opp.Hash__c = hash;
    update opp;

    System.enqueueJob(new PaymentLinkQueueable(opportunityId, amount, hash,merchant_txn));
}

    private static String generateTransactionId(Id opportunityId) {
        return opportunityId + String.valueOf(Datetime.now().getTime()); 
    }

 
    private static String generateSHA512(String input) {
        Blob inputBlob = Blob.valueOf(input);
        Blob hash = Crypto.generateDigest('SHA-512', inputBlob);
        return EncodingUtil.convertToHex(hash);
    }

   

   
  
    
    @AuraEnabled
    public static String getTowerTC(String towerId)
    {
        return Utility.retreiveTowerTC(towerId);
    }
    @AuraEnabled
    public static String getProjectTC(String projectId)
    {
        return Utility.retreiveProjectTC(Utility.getDecryptedDatawithdecode(projectId));
    }
    
   /* @AuraEnabled
    public static Map<String,List<String>> getOffersForProject(String OpprecId,String offerType)
    {
        Map<String,List<String>> OfferMap = new Map<String,List<String>>();
        Set<Id> OfferIds = new Set<Id>();
        List<Opportunity> oppRec = [Select id,RW_Project__c from Opportunity Where id=: OpprecId];
        if(oppRec != null && oppRec.size() >0)
        {
        	List<Offer__c> offerRec= [Select id,Name,RW_Sub_Offer__c from Offer__c Where Project__c=: oppRec[0].RW_Project__c and RW_Status__c='Active' and Offer_Type__c =:offerType and RW_Approval_Status__c='Approved'];
            for(Offer__c offerRecord : offerRec)
            {
                OfferIds.add(offerRecord.Id);
            }
            
            List<RW_Sub_Offer__c> subofferRecords = [Select Name,Offer__c,Offer__r.Name,Project__c from RW_Sub_Offer__c Where Project__c=: oppRec[0].RW_Project__c and RW_Status__c='Active' and RW_Offer_Type__c =:offerType and RW_Approval_Status__c='Approved'];
            for(RW_Sub_Offer__c subOffers : subofferRecords)
            {
                //for(Id offerid : OfferIds)
                //{
                   // if(subOffers.Offer__c == offerid)
                    //{
                        if(OfferMap.containsKey(subOffers.Offer__r.Name))
                        {
                         List<String> SubofferNames = OfferMap.get(subOffers.Offer__r.Name);
                         SubofferNames.add(subOffers.Name);
                         OfferMap.put(subOffers.Offer__r.Name , SubofferNames);
                        }
                        else
                        OfferMap.put(subOffers.Offer__r.Name ,new List<String>{subOffers.Name}); 
                    //}
                //}
            }
        }
        
        return OfferMap;
    }
    */
    
     @AuraEnabled
    public static Map<String,List<String>> getOffersForTower(String towerId,String offerType)
    {
        Map<String,List<String>> OfferMap = new Map<String,List<String>>();
         List<RW_Sub_Offer__c> subofferRecords = [Select Name,Offer__c,Offer__r.Name,Project__c,Tower__c from RW_Sub_Offer__c Where Tower__c=: towerId and RW_Status__c='Active' and RW_Offer_Type__c =:offerType and RW_Approval_Status__c='Approved'];
            for(RW_Sub_Offer__c subOffers : subofferRecords)
            {
  
                        if(OfferMap.containsKey(subOffers.Offer__r.Name))
                        {
                         List<String> SubofferNames = OfferMap.get(subOffers.Offer__r.Name);
                         SubofferNames.add(subOffers.Name);
                         OfferMap.put(subOffers.Offer__r.Name , SubofferNames);
                        }
                        else
                        OfferMap.put(subOffers.Offer__r.Name ,new List<String>{subOffers.Name}); 
            }
        
        
        return OfferMap;
    }
    
    @AuraEnabled
     public static Map<String,String> getProjectTowers(String recordId)
     {
         return Utility.getTowersOfProject(recordId);
     }
    
    @AuraEnabled
     public static List<RW_Sub_Offer__c> getSubOfferRecord(String recordId)
     {
         List<RW_Sub_Offer__c> subofferRecords = [Select Id,Name,Offer__c,Offer__r.Name,Project__c,Tower__c,Tower__r.Name from RW_Sub_Offer__c Where Id=: recordId];
         return subofferRecords;
     }
    
     @AuraEnabled
     public static String generateEOIOTP(String OTPType,String CustomerNo , String recordId)
     {
         String OTPNumber = Utility.generateOTP(OTPType,CustomerNo,recordId);
         RW_EOI__c eoiRec = [Select id,Name,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c from RW_EOI__c where id= : recordId];
         String CustomerName = '';
            if(eoiRec.RW_Primary_First_Name__c != null)
            {
                CustomerName = eoiRec.RW_Primary_First_Name__c ;
            }
            
            if(eoiRec.RW_Primary_Last_Name__c != null)
            {
                if(CustomerName != null && CustomerName !='')
                CustomerName = CustomerName + ' ' +eoiRec.RW_Primary_Last_Name__c ;
                else
                CustomerName = eoiRec.RW_Primary_Last_Name__c ;    
            }
         	Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { eoiRec.RW_Primary_Email__c };
            String emailBody = '';
            String plainTextBody ='';
            message.subject = 'Digital EOI Form OTP';
            emailBody +='Dear '+CustomerName+',<br/><br/> Your OTP for Digital form is '+OTPNumber+' . <br/><br/> Regards,<br/> Runwal Team<br/><br/>';
            plainTextBody +=  'Dear '+CustomerName+',\n Your OTP for Digital form is '+OTPNumber+' . \n Regards,\n Runwal Team<br/><br/>'; 
         	message.setHtmlBody(emailBody); 
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
         
         return OTPNumber;
     }
    
    @AuraEnabled
     public static String getCommunityDigitalEOIFormURL()
     {
         return Utility.getCommunityURL();
     }
    
    @AuraEnabled
     public static void notifyPaymentFailure(String eoiRecordId, String TrackingId, String failureReason)
     {
          RW_EOI__c eoiRecord = [Select id,RW_EOI_Acknowledgment_Sent__c,Name,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.RW_Project__c,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email,RW_EOI_Acknowledgement_Sent_Date_Time__c,Opportunity__c,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c from RW_EOI__c where id= :eoiRecordId];
          List<String> toAddress = new List<String>();
            if(eoiRecord.Opportunity__r.RW_Sales_Associate__c != null)
             {
                 User SalesManager = Utility.getUserRecordByName(eoiRecord.Opportunity__r.RW_Sales_Associate__c);
                 if(SalesManager !=null)
                 toAddress.add(SalesManager.email);    
             }
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_EOI_Payment_Failure'];
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            htmlBody = htmlBody.replace('{!paymentTrackingId}', TrackingId);
            htmlBody = htmlBody.replace('{!failureReason}', FailureReason);        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRecord.Name);
            plainTextBody = plainTextBody.replace('{!paymentTrackingId}', TrackingId);
            plainTextBody = plainTextBody.replace('{!failureReason}', FailureReason); 
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            if(eoiRecord.Opportunity__r.RW_Project__r.Sales_Site_Head__c != null && eoiRecord.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null)
            toAddress.add(eoiRecord.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
             
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
     }
    
    
     @AuraEnabled
     public static List<String> getDependentStatePicklists(String objectName , String CountryFieldName , String CountryFieldValue , String StateField )
     {
         List<String> stateValues = new List<String>();
         Sobject sobjectName = new RW_EOI__c();
         Map<String, List<String>> dependentmap = DependentPicklistUtility.getDependentMap(sobjectName, CountryFieldName, StateField);
         if(dependentmap.containsKey(CountryFieldValue))
         {
             stateValues.addAll(dependentmap.get(CountryFieldValue));
             return stateValues;
         }
         else
         {
             return stateValues;
         }
     }
    
    @AuraEnabled
     public static List<String> getDependentCityPicklists(String objectName , String StateFieldName , String StateFieldValue , String CityField )
     {
         List<String> cityValues = new List<String>();
         Sobject sobjectName = new RW_EOI__c();
         Map<String, List<String>> dependentmap = DependentPicklistUtility.getDependentMap(sobjectName, StateFieldName, CityField);
         if(dependentmap.containsKey(StateFieldValue))
         {
             cityValues.addAll(dependentmap.get(StateFieldValue));
             return cityValues;
         }
         else
         {
             return cityValues;
         }
     }
    
    @AuraEnabled
    public static String getBillDeskData(Map<String,String> DetailMap)
    {   
        String billDeskChecksumKey = '';
        try
        {
            Map<String,String> BillDeskInputMap = new Map<String,String>();
            List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];
            
            List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
            if(BillDeskDetails != null && BillDeskDetails.size() >0)
            {
                Receipt__c receipt = new Receipt__c();
                receipt.EOI__c = DetailMap.get('eoiRecId');
                receipt.Opportunity__c = DetailMap.get('oppRecId');
                receipt.Project__c = towerData[0].ProjectName__c;
                receipt.Mode__c = 'Digital';
                receipt.Payment_Gateway__c = 'BillDesk';
                receipt.RW_Payment_Collection_Type__c = 'EOI';
                receipt.Total_Amount__c = Decimal.valueof(DetailMap.get('Amount'));
                
                insert receipt;
                
                List<Receipt__c> receiptRecord = [Select Name, Opportunity__r.SalesOrder_Number__c, Opportunity__r.SAP_Customer_Number__c, 
                                                    Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, Project_Unit__r.RW_Param1__c, 
                                                    Project_Unit__r.RW_Param4__c from Receipt__c Where Id =:receipt.Id ];
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_Merchant_ID__c);
                BillDeskInputMap.put('CustomerID',receiptRecord[0].Name);
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_Security_ID__c);
                BillDeskInputMap.put('TxnAmount',DetailMap.get('Amount'));
                BillDeskInputMap.put('CurrencyType','INR');
                BillDeskInputMap.put('TypeField1', 'R');
                BillDeskInputMap.put('TypeField2', 'F');
                System.Debug('*****'+BillDeskDetails[0].Bill_Desk_Pay_Category__c);
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
                
            }
            else
            {
                throw new CommonException('Payment Gateway unavailable right now. Please try later');
            }        
        }
        catch(Exception e)
        {
            throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
    
    @AuraEnabled
    public static String saveBillDeskResp(String msg, String digitalLinkId, String eoiRecId, String towerId)
    {	
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        /*						    BDSKUATY  |R-6668    |U1230002028226|1              |00087666.00|123 |NA            |01     |INR         |DIRECT  |NA          |NA        |00.00           |16-07-2021 17:23:49|0300|NA      |NA             |NA             |NA             |NA             |NA             |NA             |NA             |NA         |NA              |1104D57AF9C00022172162983BF515FABE9C35BCEB0836098854F99105DA963C */
        system.debug('****'+BillDeskResFormat);
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
        List<String> msgList = msg.split('\\|');
        String actualinputData = msg.substring(0,msg.lastIndexOf('|'));
        String checksumValue = msg.substring(msg.lastIndexOf('|')+1);
        system.debug('*actualinputData**'+actualinputData+'*checksumValue**'+checksumValue);
        String ChecksumKey='';
        try
        {
            List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: towerId];
            List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);

            ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;

            if(ChecksumKey != '' && checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey))
            {
                List<Receipt__c> receiptRecord = [Select Name,Mode__c,Cheque_DD__c,Receipt_Status__c,Payment_Gateway_Response_Code__c,Cheque_DD_Date__c from Receipt__c Where Name =: msgList[BillDeskResFormat1.indexOf('CustomerID')]];
                
                if(receiptRecord != null && receiptRecord.size() >0){
                    receiptRecord[0].Cheque_DD__c = msgList.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
                    //receiptRecord[0].Total_Amount__c = Decimal.valueof(msgList.get(BillDeskResFormat1.indexOf('TxnAmount')));
                    String dateFormat = msgList.get(BillDeskResFormat1.indexOf('TxnDate'));    
                    receiptRecord[0].Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));
                    receiptRecord[0].Receipt_Status__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300' ? 'Success' : 'Failure';
                    receiptRecord[0].Payment_Gateway_Response_Code__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus'));
                    
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
                    
                    List<RW_Digital_Link_Status__c> digitalLinkRec =[Select id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =:digitalLinkId];
                    
                    if(digitalLinkRec != null && digitalLinkRec.size() >0)
                    {
                        digitalLinkRec[0].RW_Link_Status__c ='Expired';
                        update digitalLinkRec[0];
                    }
                    
                    RW_EOI__c eoiRecord = [Select id,RW_EOI_Acknowledgment_Sent__c,Name,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.RW_Project__c,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email,RW_EOI_Acknowledgement_Sent_Date_Time__c,Opportunity__c,RW_Status__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c from RW_EOI__c where id= :eoiRecId];
                    if(eoiRecord != null)
                    {   
                        eoiRecord.RW_Status__c = 'EOI Confirmed';
                        eoiRecord.RW_EOI_Acknowledgment_Sent__c = 'Yes';
                        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c =  DateTime.now();
                        update eoiRecord;
                    } 
                    List<String> toAddress = new List<String>();
                    List<String> emailIds = Utility.getExternalTeamEmailIds(new List<String>{'CRM Team','Accounts','Sales Approvers Team'},eoiRecord.Opportunity__r.RW_Project__c);
                    
                    if(emailIds.size() >  0)
                    {
                        toAddress.addAll(emailIds);
                    }  
                    PageReference pdf = Page.CustomerEOIForm;
                    pdf.getParameters().put('eoiId',eoiRecord.Id);
                    Blob body;
                    if(!Test.isRunningTest())
                        body= pdf.getContent();
                    
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType('application/pdf');
                    attach.setFileName('EOIForm.pdf');
                    attach.setInline(false);
                    if(body != null)
                        attach.Body = body;
                    
                    EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Confirmed_Customer'];
                    String htmlBody = template.HtmlValue; 
                    htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
                    htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
                    htmlBody = htmlBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
                    map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                    if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c)!=null)
                        htmlBody = htmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
                    else
                        htmlBody = htmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                    String plainTextBody = template.Body; 
                    plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecord.RW_Primary_First_Name__c);
                    plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecord.RW_Primary_Last_Name__c);
                    plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_EOI_Acknowledgement_Sent_Date_Time__c}', eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c.format('dd/MM/yyyy HH:mm:ss','IST')+' IST');
                    if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c)!=null)
                        plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecord.opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
                    else
                        plainTextBody = plainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = new String[] { eoiRecord.RW_Primary_Email__c };
                        message.subject = template.Subject;
                    message.setHtmlBody(htmlBody);   
                    message.setPlainTextBody(plainTextBody);  
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    if(toAddress.size() >0)
                        message.setCcAddresses(toAddress); // Changed from BCC to CC by coServe 20-092024
                    if(attach.body != null)
                        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    return 'Success';   
                }
                else{ 
                    return 'Failure';  
                }
            }
            else{ 
                return 'Failure';  
            }
        }
        catch(Exception e)
        {
            throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
    
    /*@AuraEnabled
     public static String getTCforRunwalMahalakshmiProj(){ //Added bu coServe 09-10-2024
         List<Project__c> projs = [SELECT Id, TermsAndConditions__c FROM Project__c WHERE Name = 'Runwal Forests'];
         if(projs.size() > 0){
             System.debug('--: ' + projs[0].TermsAndConditions__c);
             return projs[0].TermsAndConditions__c;
         }else{
             return null;
         }
     }*/
    
}