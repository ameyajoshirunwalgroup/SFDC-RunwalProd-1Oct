public without sharing class Utility 
{
    public static final Blob CRYPTOKEY = EncodingUtil.base64Decode('aKUh/QDcqCZfRs6jBbmDEaQi3WCZ+OUEZagi6j3Ni74=');
   /* public static List<Opportunity> getAllOpportunityRecords(List<String> recordId)
    {
        List<Opportunity> opportunityList = [SELECT Id, Name FROM Opportunity WHERE Id IN: recordId ];
        return opportunityList;
    }
    */
    public static Opportunity getOpportunityRecord(String recordId)
    {
        List<Opportunity> opportunityRecord = [SELECT Id,Project_Name__c, Name ,RW_Sourcing_Manager__c,Sales_Manager__c, AccountId,RW_Sales_Associate__c,Walk_in_Sub_Source__c,Walk_in_Source__c, RW_Email__c ,Walkin_Source__c, RW_Mobile_No__c, RW_PAN_Card_Number__c , RW_Additional_Email__c,RW_AADHAR_Card_Number__c,RW_Passport_Number__c,RW_Secondary_Email__c,LeadSource,Lead_Sub_Source__c,RW_Project__c,RW_Project__r.Name,RW_Walkin_Channel_Partner__c,RW_Walkin_Channel_Partner__r.Name,RW_Walkin_Channel_Partner__r.SAP_CP_Code__c,(SELECT id,RW_Status__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c FROM EOI__r),(SELECT id,status__c FROM Booking__r),(Select Id,RecordtypeId,RW_Link_Status__c,RW_Link_Sent_Time__c from Digital_Link_Status__r) FROM Opportunity WHERE Id= :recordId ];
        if(opportunityRecord != null && opportunityRecord.size() >0)
            return opportunityRecord[0];
        else
            return null;
    }
    
    public static Account getAccountFromOpportunityRecord(Opportunity oppRec)
    {
        List<Account> accountRecord = [SELECT Id,Marital_Status__c,Gender__c,City__c,Salutation,Birth_Date__c,FirstName,LastName,RW_Company_Name__c,Locality__c,PersonEmail,State__c,Country__c,Mobile_No__c,BillingAddress,RW_Zip_Code__c,RW_State__c,RW_Country__c,RW_Mobile_No__c,RW_Email__c,Alternate_Email__c FROM Account WHERE Id= :oppRec.AccountId ];
        if(accountRecord != null && accountRecord.size() >0)
            return accountRecord[0];
        else
            return null;
    }
    
    public static RW_EOI__c getEOIRecord(String recordId)
    {
        System.debug(Schema.sObjectType.RW_EOI__c.isAccessible());
        List<RW_EOI__c> eoiRecord = [SELECT Id,BillDesk_Terms_And_Conditions__c,RW_Countries__c,RW_Project_Name__c,RW_State__c,RW_City__c,RW_Mailing_State__c,RW_Mailing_Country__c,RW_Mailing_City__c,RW_Approval_Status__c,Name,RW_Company_Name__c,RW_Opt_In__c,RW_Mailing_and_Permanent_Address_Same__c,RW_Alternate_Contact_No__c,RW_Mailing_Pin__c, RW_Mailing_Address_Line_1__c,RW_Mailing_Address_Line_2__c,RW_Mailing_Address_Line_3__c,Opportunity__c , Opportunity__r.RW_Project__c , Tower__c ,RW_Date_of_Birth__c,RW_Marital_Status__c, Tower__r.Name, Tower__r.RW_Payment_Gateway__c, RW_Residential_Status__c,RW_Type_Of_Applicant__c, RW_Designation__c,RW_Occupation__c,RW_Nationality__c, RW_Type_Of_Origin__c,RW_Origin_Details__c,RW_Pan_Card_Number_of_AuthoritySignatory__c,RW_PassportNoDetails__c, RW_Country_Phone_Code__c ,RW_Gender__c,RW_Permanent_Address_Line_1__c,RW_Permanent_Address_Line_2__c,RW_Permanent_Address_Line_3__c,RW_Document_Number__c,RW_Document_Proof__c,RW_Primary_First_Name__c,RW_Source_RERA_No__c,RW_Primary_Middle_Name__c,RW_Primary_Last_Name__c,RW_Name_of_Company__c,RW_Channel_Partner_s_Name__c,RW_Channel_Partner_s_Company__c,RW_Residential_Company_Address__c,RW_Pin__c,RW_Primary_Contact_No__c,RW_Primary_Email__c ,RW_Primary_PAN_Details__c ,RW_Primary_Alternate_Email__c,RW_Primary_Aadhar_Details__c,RW_Primary_Passport_Details__c ,RW_Secondary_First_Name__c,RW_Secondary_Middle_Name__c,RW_Secondary_Last_Name__c,RW_Secondary_Contact_No__c,RW_Secondary_Email__c,RW_Secondary_PAN_Details__c ,RW_Secondary_Alternate_Email__c ,RW_Secondary_Aadhar_Details__c ,RW_Secondary_Passport_Details__c ,RW_Preferred_Unit_Type__c,RW_Preferred_Budget__c,RW_Preferred_Floors__c,RW_Any_other_preference_please_specify__c,RW_Preferred_Unit_No__c,RW_Tentative_Agreement_Value__c ,RW_Tentative_All_Inclusive_Price__c,RW_Application_Source__c,RW_Sub_Source__c,RW_Closing_Type__c,RW_Source_Contact_No__c,RW_Source_Email_Id__c,
                                     Landline_No__c,Customer_GST_No__c,Home_Loan__c, Secondary_Alternate_Contact_No__c, Secondary_Landline_No__c,Secondary_Nationality__c,Secondary_Home_Loan__c,Draft_Cheque_No__c,Draft_Cheque_Date__c,Bank_Name__c,Source_Details__c,Channel_Partner_Contact_No__c,Channel_Partner_Email__c,Preferred_Size__c,EOI_Amount__c
                                     FROM RW_EOI__c WHERE Id =:recordId ];
        if(eoiRecord != null && eoiRecord.size() >0)
        {
            return eoiRecord[0];
            
        }
        
        else
        {
            return null;
            
        }
    }
    
    
   public static Applicant_Details__c getApplicantDetailsRecord(String recordId)
    {
        System.debug(Schema.sObjectType.Applicant_Details__c.isAccessible());
        List<Applicant_Details__c> AppcDetRecord = [SELECT Id, Name,Booking__c, Mailing_Country__c,Organisation_Country__c FROM Applicant_Details__c WHERE Id =:recordId ];
        if(AppcDetRecord!= null && AppcDetRecord.size() >0)
        {
            return AppcDetRecord[0];
            
        }
        
        else
        {
            return null;
            
        }
    }
    
    
   /* public static RW_EOI_Link_Status__c getEOILinkStatusRecord(String recordId)
    {
        List<RW_EOI_Link_Status__c> eoiLinkStatus = [SELECT Id,RecordtypeId, Name,RW_EOI_Link_Status__c,RW_EOI_Link_Sent_Time__c FROM RW_EOI_Link_Status__c WHERE Id =:recordId ];
        if(eoiLinkStatus != null && eoiLinkStatus.size() >0)
            return eoiLinkStatus[0];
        else
            return null;
    }
    */
    public static RW_Digital_Link_Status__c digitalLinkStatusRecord(String recordId)
    {
        List<RW_Digital_Link_Status__c> LinkStatus = [SELECT Id, RecordTypeId, Name,RW_Link_Status__c,RW_Link_Sent_Time__c FROM RW_Digital_Link_Status__c WHERE Id =:recordId ];
        if(LinkStatus != null && LinkStatus.size() >0)
            return LinkStatus[0];
        else
            return null;
    }
    
    public static List<String> getGlobalPicklists(String objectName , String fieldName)
    {
        List<String> picklistOptions = new List<String>();
        Schema.SObjectType obj_describe = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe() ;
        Map<String,Schema.SObjectField> fields = obj_describe_result.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) 
        {
            picklistOptions.add(pickListVal.getValue());
        }
        
        return picklistOptions;
        
    }
    
 public static List<Applicable_Offer__c> getApplicableOfferRecords(String recordId,String offerType)
    {
        List<Applicable_Offer__c> applicableOfferRecord = [SELECT Id, Offer__c, Offer__r.Name , RW_Sub_Offer_Name__c ,RW_End_Date__c,opportunity__c FROM Applicable_Offer__c WHERE opportunity__c= :recordId ];
        if(applicableOfferRecord != null && applicableOfferRecord.size() >0)
            return applicableOfferRecord;
        else
            return null;
    }
    
   /* public static List<Applicable_Offer__c> getOfferRecordforDigitalForm(String recordId,String offerType)
    {
        List<Applicable_Offer__c> applicableOfferRecord = [SELECT RW_Offer_Name__c , RW_Sub_Offer_Name__c ,RW_End_Date__c,opportunity__c FROM Applicable_Offer__c WHERE opportunity__c= :recordId ];
        if(applicableOfferRecord != null && applicableOfferRecord.size() >0)
            return applicableOfferRecord;
        else
            return null;
    }
    */
    public static String getLoggedInProfileName()
    {
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        return profileName;
    }
    
   /* public static void associateFileToRecord(String recordId)
    {
        Map<Id,ContentVersion> contentVersionRec=new Map<Id,ContentVersion>(); 
        String contentDocumentId='';
        String AssociatedRecordId=recordId.split('\\|')[0];
        system.debug('**AssociatedRecordId***'+AssociatedRecordId);
        List<contentVersion> contVer =[Select id, Guest_Record_fileupload__c,ContentDocumentId from contentVersion where Guest_Record_fileupload__c=: recordId];
        system.debug('**Before1***'+contVer);
        if(contVer.size() >0)
        {
            system.debug('**Before12***');
            //AssociatedRecordId = recordId.split('|')[0];
            contentDocumentId =contVer[0].ContentDocumentId;
            
            system.debug('**Before13***'+AssociatedRecordId+'**'+contentDocumentId);
        }
        
        if(contentDocumentId!= null && contentDocumentId !='')
        {
            system.debug('**Before14***');
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId=AssociatedRecordId;
            cdl.Visibility ='AllUsers';
            
            insert cdl;
            
            system.debug('**Before15***');
        }
    }
    */
    public static List<String> getPicklistValues(String objectName,String fieldName)
    {
        List<String> pickListValues = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple)
        {
            pickListValues.add(pickListVal.getValue());
            
        }   
        
        return pickListValues;
    }
    
    public static String retreiveTowerTC(String towerId)
    {
        List<Tower__c> towerRec = [Select Id,RW_Terms_And_Conditions__c from Tower__c Where Id =:towerId];
        if(towerRec!= null && towerRec.size() >0)
        {
            return towerRec[0].RW_Terms_And_Conditions__c;
        }
        else
            return '';
    }
    public static String retreiveProjectTC(String projectId)
    {
        List<project__c> projectRec = [Select Id,TermsAndConditions__c  from project__c Where Id =:projectId];
        if(projectRec!= null && projectRec.size() >0)
        {
            return projectRec[0].TermsAndConditions__c ;
        }
        else
            return '';
    }
    
    public static String getProjectSiteHead(String projectId)
    {
        List<Project__c> projectRec = [SELECT Id, Sales_Site_Head__c FROM Project__c WHERE Id =: projectId ];
        if(projectRec != null && projectRec.size() >0)
        {
            return projectRec[0].Sales_Site_Head__c;
        }
        else
        {
            return '';
        }
    }
    
    public static String getProjectSalesDirector(String projectId)
    {
        List<Project__c> projectRec = [SELECT Id, Site_Head_User__c FROM Project__c WHERE Id =: projectId ];
        if(projectRec != null && projectRec.size() >0)
        {
            return projectRec[0].Site_Head_User__c;
        }
        else
        {
            return '';
        }
    }
    
    public static Map<String,String> getTowersOfProject(String projectId)
    {
        List<Tower__c> tRec = [Select Id, Name, ProjectName__c , ProjectName__r.Name from Tower__c where ProjectName__c = : projectId order by Name];
        Map<String,String> towerData = new Map<String,String>();     
        for(Tower__c towerRec : tRec)
        {
            
            towerData.put(towerRec.Id, towerRec.Name);
            
            
        }
        return towerData;
    }
    public  static List<Payment_Gateway__mdt> getPaymentGatewayDetails(String projectName,String tower)
    {
        try
        {
            List<Payment_Gateway__mdt> paymentMappings = [SELECT Access_Code__c,Encryption_Key__c,Sub_Account_Id__c,Merchant_Commission__c,Split_TDR_Charge__c,Merchant_Number__c FROM Payment_Gateway__mdt Where Project_Name__c =:projectName and Project_Tower__c =:tower ];
            return paymentMappings;
           /* if(paymentMappings != null && paymentMappings.size() >0)
            {
                return paymentTypes.apaymentMappings[0];
            }
            else
            {
                //throw new CommonException('No data found for payment gateway details for this Project.');
                return new Payment_Gateway__mdt();
            }*/
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
     public static String getEncryptedData(String data){
        System.debug('**data**'+data);
        System.debug('**cryptokey**'+EncodingUtil.base64Encode(CRYPTOKEY));
        
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256',CRYPTOKEY,Blob.valueOf(data));
        System.debug('**blob data**'+encryptedData);
        return EncodingUtil.urlEncode(EncodingUtil.base64Encode(encryptedData),'UTF-8');
        
        
    }
     public static String getDecryptedData(String data){
        System.debug('**data**'+data);
        System.debug('**cryptokey**'+EncodingUtil.base64Encode(CRYPTOKEY));
        //Blob KeyValue = Blob.valueOf(key);
        
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256',CRYPTOKEY,EncodingUtil.base64Decode(data));
        System.debug('**blob data**'+decryptedData);
        return decryptedData.toString();
    }
     public static String getDecryptedDatawithdecode(String data){
        System.debug('**data**'+data);
        System.debug('**cryptokey**'+EncodingUtil.base64Encode(CRYPTOKEY));
        //Blob KeyValue = Blob.valueOf(key);
        
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256',CRYPTOKEY,EncodingUtil.base64Decode(EncodingUtil.urlDecode(data,'UTF-8')));
        System.debug('**blob data**'+decryptedData);
        return decryptedData.toString();
    }
    public static String generateOTP(String OTPType,String customerNumber , String recordId)
    {
        String OTPNumber=''; 
        Integer xx;
        do
        {
           Double x = Math.random(); 
           long y = Math.round(x*100000);
           xx = String.valueOf(y).length();
           OTPNumber = String.valueOf(y);
       } while( xx < 5 );
                        
         try
         
         {   system.debug('otp'+OTPNumber);
             OTP__c otpobj = new OTP__c();
             otpobj.Generated_Digital_Form_OTP__c = OTPNumber;
             otpobj.OTP_Generated_on__c = string.valueOf(system.now());
             otpobj.User_Info__c = userinfo.getFirstName() +' '+userinfo.getLastName();
             otpobj.Digital_Form_Customer_Number__c = customerNumber;
             if(OTPType == 'EOI')
             otpobj.EOI__c = recordId;
             else if(OTPType == 'Booking')
             otpobj.Booking__c = recordId;    
             //otpobj.Prospect__c = prosId;
             //otpobj.Project__c = lstpros[0].Project__c;
             otpobj.User__c = UserInfo.getUserId();
          system.debug(otpobj+'otpobj');
             //if(lstpros[0].Channel_Partner__c != null)
                // otpObj.CP_Name__c = 'Channel Partner Name: '+lstpros[0].Channel_Partner__r.Name;
             insert otpobj;
             return OTPNumber;
         }
        
        catch(Exception e)
        {
            System.debug('Exception'+e.getMessage());
            return '';
        }
    }
    
     public static List<String> getExternalTeamEmailIds(List<String> TeamType,String ProjectId)
    {
           List<String> emailIds = new List<String>();
           Set<Id> teamIds = new Set<Id>();
           List<Team__c> teamRecord = [Select id from Team__c where Team_Type__c IN :TeamType and Project__c=:ProjectId] ;
        system.debug('MK'+teamRecord); 
        if(teamRecord != null && teamRecord.size() >0)
           {
               for(Team__c teamRec : teamRecord)
               {
                   teamIds.add(teamRec.Id);
               }
           }
             
           List<Team_Members__c> teamMembers = [Select Id,Email_Id__c,User__r.Email,IsActive__c from Team_Members__c where Team__c IN :teamIds];
           for(Team_Members__c teammem : teamMembers)
           {
               if(teammem.Email_Id__c != null)
               emailIds.add(teammem.Email_Id__c);
               if(teammem.User__r.Email != null && teammem.IsActive__c)
               {
                 emailIds.add(teammem.User__r.Email);
               }
           }
        return emailIds;
    }
    
    public static User getUserRecordByName(String UserName)
    {
       List<User> userRec = [Select id,Email from User Where Name =:UserName];
        if(userRec != null && userRec.size() >0)
        {
            return userRec[0];
        }
        else
            return null;
        
    }
    
    public static String getCommunityURL()
    {
        return Label.Community_URL;
    }
    
 
      public static List<Applicable_Offer__c> getApplicableOffers(String optyId,String offerType)
        {
            try
            {
            List<Applicable_Offer__c> applicableOfferRecord = [SELECT Id,Offer__c, Offer_Availed__c,Offer__r.Name ,RW_Offer_Name__c, RW_Sub_Offer_Name__c ,RW_End_Date__c,opportunity__c FROM Applicable_Offer__c WHERE Opportunity__c= :optyId and Type_Of_Offer__c= :offerType];
            
                
            if(applicableOfferRecord!= null && applicableOfferRecord.size() >0)
            {  
                return applicableOfferRecord;
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
   
      public static List<Applicable_Offer__c> getAppliedOffers(String optyId,String offerType)
        {
            try
            {
                List<RW_EOI__c> eoiList = [select id from RW_EOI__c where Opportunity__c =:optyId];
                List<id> eoiId = new List<id>();
                for(RW_EOI__c eoi :eoiList ){
                    eoiId.add(eoi.id);
                }
            List<Applicable_Offer__c> applicableOfferRecord = [SELECT Id,Offer__c, Offer_Availed__c,Offer__r.Name ,RW_Offer_Name__c, RW_Sub_Offer_Name__c ,RW_End_Date__c,opportunity__c FROM Applicable_Offer__c WHERE EOI__c IN :eoiId and Offer_Availed__c=true and Type_Of_Offer__c= :offerType];            
                
            if(applicableOfferRecord!= null && applicableOfferRecord.size() >0)
            {  
                return applicableOfferRecord;
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
    
     	public static String getOrgWideEmailAddress()
        {
    		OrgWideEmailAddress[] owea = [select Id,DisplayName from OrgWideEmailAddress where DisplayName = 'Runwal Cares'];
            if(owea!= null &&owea.size() >0)
                return owea.get(0).Id;
            else
                return '';
        }
        public static id getUserIdbyName(String Name){
        List<user> users = [select id from user where name = :Name];
        if(users.size()>0)
            return users[0].id;
        else
            return null;
    }
        //Salesmanager email id is used as username and his manager id is used as email
       public static List<string> getUserNameEmailbyName(String Name){
        List<user> users = [select id,UserName,Email from user where name = :Name];
           if(users.size()>0){
            List<String> emails = new List<string>{users[0].UserName,users[0].Email};
                return emails;}
        else
            return null;
    }
    
    
    public static String getChecksumKey(String inputData, String billDeskChecksumKey){
       // String salt = String.valueOf('BDSKUATY|123456|NA|100.00|XYZ|NA|NA|INR|DIRECT|R|bdskuaty|NA|NA|F|john@doe1.com|9820198201|NA|NA|NA|NA|NA|NA');
        String salt = String.valueOf(inputData);
        //String key = 'G3eAmyVkAzKp8jFq0fqPEqxF4agynvtJ';
        Blob data = crypto.generateMac('HmacSHA256',Blob.valueOf(salt),  Blob.valueOf(billDeskChecksumKey));
        return EncodingUtil.convertToHex(data).toUppercase();
        //system.debug('**'+EncodingUtil.convertToHex(data).toUppercase());
    }
    
   public static List<Payment_Gateway__mdt> getBIllDeskPaymentGatewayDetails(String projectName,String tower)
    {
        try
        {
            List<Payment_Gateway__mdt> paymentMappings = [SELECT Bill_Desk_Checksum_Key__c,Bill_Desk_Merchant_ID__c,Bill_Desk_Security_ID__c,Bill_Desk_Pay_Category__c,Bill_Desk_GST_Merchant_ID__c,Bill_Desk_GST_Checksum_Key__c,Bill_Desk_GST_Security_ID__c FROM Payment_Gateway__mdt Where Project_Name__c =:projectName and Project_Tower__c =:tower ];
            return paymentMappings;
           
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static String generateBillDeskMessageString(Map<String,String> messageInput, String billDeskChecksumKey)
    {
        String BillDeskFormat = 'MerchantID|CustomerID|Filler1|TxnAmount|BankID|Filler2|Filler3|CurrencyType|ItemCode|TypeField1|SecurityID|Filler4|Filler5|TypeField2|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|TypeField3';
        
        BillDeskFormat = BillDeskFormat.replace('MerchantID', messageInput.get('MerchantID') != null ? messageInput.get('MerchantID') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('CustomerID', messageInput.get('CustomerID') != null ? messageInput.get('CustomerID') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('Filler1', messageInput.get('Filler1') != null ? messageInput.get('Filler1') : 'NA');
		BillDeskFormat = BillDeskFormat.replace('TxnAmount', messageInput.get('TxnAmount') != null ? messageInput.get('TxnAmount') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('BankID', messageInput.get('BankID') != null ? messageInput.get('BankID') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('Filler2', messageInput.get('Filler2') != null ? messageInput.get('Filler2') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('Filler3', messageInput.get('Filler3') != null ? messageInput.get('Filler3') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('CurrencyType', messageInput.get('CurrencyType') != null ? messageInput.get('CurrencyType') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('ItemCode', messageInput.get('ItemCode') != null ? messageInput.get('ItemCode') : 'NA');
		BillDeskFormat = BillDeskFormat.replace('TypeField1', messageInput.get('TypeField1') != null ? messageInput.get('TypeField1') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('SecurityID', messageInput.get('SecurityID') != null ? messageInput.get('SecurityID') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('Filler4', messageInput.get('Filler4') != null ? messageInput.get('Filler4') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('Filler5', messageInput.get('Filler5') != null ? messageInput.get('Filler5') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('TypeField2', messageInput.get('TypeField2') != null ? messageInput.get('TypeField2') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo1', messageInput.get('AdditionalInfo1') != null ? messageInput.get('AdditionalInfo1') : 'NA');
		BillDeskFormat = BillDeskFormat.replace('AdditionalInfo2', messageInput.get('AdditionalInfo2') != null ? messageInput.get('AdditionalInfo2') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo3', messageInput.get('AdditionalInfo3') != null ? messageInput.get('AdditionalInfo3') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo4', messageInput.get('AdditionalInfo4') != null ? messageInput.get('AdditionalInfo4') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo5', messageInput.get('AdditionalInfo5') != null ? messageInput.get('AdditionalInfo5') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo6', messageInput.get('AdditionalInfo6') != null ? messageInput.get('AdditionalInfo6') : 'NA');
        BillDeskFormat = BillDeskFormat.replace('AdditionalInfo7', messageInput.get('AdditionalInfo7') != null ? messageInput.get('AdditionalInfo7') : 'NA');
		BillDeskFormat = BillDeskFormat.replace('TypeField3', messageInput.get('TypeField3') != null ? messageInput.get('TypeField3') : 'NA');
        
        String checksumKey = getChecksumKey(BillDeskFormat, billDeskChecksumKey);
        return BillDeskFormat+'|'+checksumKey;
    }
}