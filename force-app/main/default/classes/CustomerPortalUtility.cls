public class CustomerPortalUtility 
{
    
    public static final Blob CRYPTOKEY = EncodingUtil.base64Decode(Label.URL_Encryption_Key);
	public static Account getopportunitiesfromAccount(Id AccountId)
    {
        List<Account> accountRecord = [SELECT Id,(Select Id,Name from Opportunities) FROM Account WHERE Id= :AccountId ];
        system.debug('AccountId**'+AccountId+'**'+accountRecord.size());
        if(accountRecord != null && accountRecord.size() >0)
            return accountRecord[0];
        else
            return null;
    }
    
    public static List<Opportunity> getOpportunities(Set<Id> oppIds)
    {
        
         List<Opportunity> opportunityRecord = [SELECT Id, Name ,Latest_SV_Survey_Link__c,RW_Sourcing_Manager__c,Sales_Manager__c, AccountId,RW_Sales_Associate__c,Walk_in_Sub_Source__c,Walk_in_Source__c, RW_Email__c ,Walkin_Source__c, RW_Mobile_No__c, RW_PAN_Card_Number__c , RW_Additional_Email__c,RW_AADHAR_Card_Number__c,RW_Passport_Number__c,RW_Secondary_Email__c,LeadSource,Lead_Sub_Source__c,RW_Project__c,RW_Project__r.Name,(SELECT id,RW_Status__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Project_Name__c,Opportunity__c FROM EOI__r),(SELECT id,Name,status__c, Project__r.RW_SAP_Company_Code__c,Total_Demand_Raised_Principal__c,Project__r.RW_Project_Brochure_PublicUrl__c,Project__r.RW_Project_Location_Videos_Link__c,Project__r.Name,Unit_No__r.RW_Param4__c,Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.Contact_Number__c,Unit_No__r.Relationship_Manager__r.RM_Email__c,Unit_No__r.TowerName__r.Name,Unit_No__r.TowerName__r.Enable_BillDesk__c,Floor__c,Unit_No__r.TowerName__r.RW_Floor_Plan__c, Source_of_Booking__c,Booking_Date__c,Carpet_Area__c,Primary_Applicant_Email__c,Customer__c, Customer__r.RW_Agreement_Value__c,Quotation__c,Quotation__r.Total_No_of_Parking__c,RW_Total_Interest__c,RW_Total_Interest_Amount_Waived__c,RW_Total_Collectable_Interest__c,RW_Total_Amount_Collected__c,RW_Total_Amount_Balance__c,Customer__r.SAP_Customer_Number__c,RW_Total_Demand_Raised__c,Customer__r.Latest_SV_Survey_Link__c,Customer__r.Portal_Possession_Survey_Link_Id__c,Customer__r.Booking_Feedback_Link__c,	RW_Total_TDS_Outstanding__c,Total_TDS_Amount_Paid_In_Rs__c , RW_Total_Demand_Paid__c, RW_Next_Demand_Date__c, RW_Expected_SDR_Date__c,RW_Registration_Date__c, RW_SDR_Status__c,Customer__r.SalesOrder_Number__c,RW_Agreement_Status__c,RW_Signed_Agreement_Document_Id__c,RW_Total_GST_Amount__c ,RW_Total_Receipt_Discount_Recieved__c , RW_Total_TDS_Due__c,RW_Registration_Status__c  , RW_Total_Demand_Outstanding__c , RW_Total_Receipt_Amount_Received__c,RW_Total_Demand_Paid_D__c,Project__r.Seperate_payment__c,Unit_No__r.Total_RERA_Carpet_Area__c,Project__r.Customer_Care_Email__c,No_of_Parking__c FROM Booking__r) FROM Opportunity WHERE StageName='Unit Booked' and Id IN :oppIds ];
        if(opportunityRecord != null && opportunityRecord.size() >0)
            return opportunityRecord;
        else
            return null;
    }
    
  /*   public static List<Applicant_Details__c> getApplicantDetails(String bookingId)
    {
        
        List<Applicant_Details__c> applicantDetailsRecord = [SELECT Id,First_Name__c,Type_Of_Origin__c,Origin_Details__c,PassportNoDetails__c,Pan_Card_Number_of_Authority_Signatory__c,Last_Name__c,PancardNo__c,Subtype_Of_Applicant__c,Address_Proof_Document__c,Address_Proof_Number__c,Applicant_Number__c,Email_Address__c,Type_Of_Applicant__c,Mobile_Number__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,Organization_Name__c,Booking__c,Opportunity__c FROM Applicant_Details__c WHERE Booking__c =:bookingId ];
        System.debug('**applicantRec*'+applicantDetailsRecord);
        if(applicantDetailsRecord != null && applicantDetailsRecord.size() >0)
            return applicantDetailsRecord;
        else
            return null;
    }*/
    
     public static List<Applicant_Details__c> getApplicantDetailsRecords(Set<Id> BookingIds)
    {
        
        List<Applicant_Details__c> applicantDetailsRecord = [SELECT Id,First_Name__c,Middle_Name__c,DOB__c,Country__c,State__c,City__c,Pincode__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,Type_Of_Origin__c,Origin_Details__c,PassportNoDetails__c,Pan_Card_Number_of_Authority_Signatory__c,Last_Name__c,PancardNo__c,Subtype_Of_Applicant__c,Address_Proof_Document__c,Address_Proof_Number__c,Applicant_Number__c,Email_Address__c,Type_Of_Applicant__c,Mobile_Number__c,Organization_Name__c,Booking__c,Opportunity__c,Booking__r.Name,Booking__r.Project__c,Booking__r.Unit_No__r.RW_Param4__c,Booking__r.RW_Registration_Status__c FROM Applicant_Details__c WHERE Booking__c IN:BookingIds and Applicant_Status__c!='Inactive'  ];
        System.debug('**applicantRec*'+applicantDetailsRecord);
        if(applicantDetailsRecord != null && applicantDetailsRecord.size() >0)
            return applicantDetailsRecord;
        else
            return null;
    }
    
  /* public static List<Loan__c> getloanDetails(String bookingId)	
    {	
        	
        List<Loan__c> loanDetailsRecord = [SELECT Id,RW_Loan_Record_Status__c,RW_Sanction_Letter_ID__c, RW_Pan_card_Id__c,RW_Aadhar_no__c,RW_Driving_License__c, RW_Passport_Photo__c FROM Loan__c WHERE RW_Booking__c =:bookingId ];	
        if(loanDetailsRecord != null && loanDetailsRecord.size() >0)	
            return loanDetailsRecord;	
        else	
            return null;	
    }*/
    
    
     public static List<Loan__c> getloanDetailRecords(Set<Id> bookingId)	
    {	
        	
        List<Loan__c> loanDetailsRecord = [SELECT Id,RW_Loan_Record_Status__c,RW_Booking__c,RW_Sanction_Letter_ID__c,RW_Pan_card_Id__c,RW_Aadhar_no__c,RW_Driving_License__c, RW_Passport_Photo__c FROM Loan__c WHERE RW_Booking__c IN :bookingId ];	
        System.debug('loanDetailsRecord size'+ loanDetailsRecord.size());	
        if(loanDetailsRecord != null && loanDetailsRecord.size() >0)	
            return loanDetailsRecord;	
        else	
            return null;	
    }
    
    public static List<TDS__c> getTDSDetailRecords(Set<Id> bookingId)
    {
        
        List<TDS__c> tdsDetailsRecord = [SELECT Id,RW_TDS_Certificate_Number__c,Booking__c,RW_Amount__c,RW_TDS_Document_ID__c FROM TDS__c WHERE Booking__c IN :bookingId ];
        System.debug('tdsDetailsRecord size'+ tdsDetailsRecord.size());
        if(tdsDetailsRecord != null && tdsDetailsRecord.size() >0)
            return tdsDetailsRecord;
        else
            return null;
    }
    
    	     public static List<RW_Bank_Details__c> getBankDetailsRecords(Set<Id> ProjectId)	
    {	
        	
        List<RW_Bank_Details__c> bankDetailsRecord = [SELECT Id,RW_Banks_Name__c,RW_Branch_Name__c, RW_Project_Name__c FROM RW_Bank_Details__c WHERE RW_Project_Name__c IN :ProjectId ];	
        System.debug('bankDetailsRecord size'+ bankDetailsRecord.size());	
        if(bankDetailsRecord != null && bankDetailsRecord.size() >0)	
            return bankDetailsRecord;	
        else	
            return null;	
    }	
    
    
    public static List<RW_Tower_Construction_Update__c> getconstructionDetailRecords(Set<Id> towerIds)
    {
        
        List<RW_Tower_Construction_Update__c> constructionDetailsRecord = [SELECT Id,RW_Description__c,RW_Tower__c,RW_Date__c,RW_Date_Month__c,RW_Date_Year__c,RW_Tower_Construction_Photo_ID__c FROM RW_Tower_Construction_Update__c WHERE RW_Tower__c IN :towerIds order by RW_Date__c desc ];
        System.debug('constructionDetailsRecord size'+ constructionDetailsRecord.size()+'*'+constructionDetailsRecord);
        if(constructionDetailsRecord != null && constructionDetailsRecord.size() >0)
            return constructionDetailsRecord;
        else
            return null;
    }
    
   
    public static List<Document_Details__c> getApplicantKYCDocumentDetails(Set<Id> applicantIds)
    {
        System.debug('before query*'+applicantIds);
        List<Document_Details__c> documentDetailsRecord = [SELECT Id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c FROM Document_Details__c WHERE RW_Applicant_Details__c IN :applicantIds ];
        System.debug('after query*'+documentDetailsRecord);
        if(documentDetailsRecord != null && documentDetailsRecord.size() >0)
            return documentDetailsRecord;
        else
            return null;
    }
    
     public static Map<String,Name_Confirmation_Form__c> getNCFRecordDetails(Set<Id> bookingId)
    {
        Map<String,Name_Confirmation_Form__c> ncfMap = new Map<String,Name_Confirmation_Form__c>();
        System.debug('before query ncf*'+bookingId);
        List<Name_Confirmation_Form__c> ncfDetailsRecord = [SELECT Id,Name,RW_Verified__c,RW_Allow_Customer_to_Update__c,Type_Of_Applicant__c,Subtype_Of_Applicant__c,PancardNo__c,Address_Proof_Document__c,Address_Proof_Number__c,Type_Of_Origin__c,Origin_Details__c,PassportNoDetails__c,Pan_Card_Number_of_Authority_Signatory__c,Booking__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Primary_Middle_Name__c,RW_Primary_Mobile_Number__c,RW_Primary_DOB__c,RW_Primary_Email__c,RW_Primary_Country__c,RW_Primary_City__c,RW_Primary_Permanent_Address_Line_1__c,RW_Primary_Permanent_Address_Line_2__c,RW_Primary_Permanent_Address_Line_3__c,RW_Primary_Pincode__c,RW_Primary_State__c,RW_POA_Email__c,RW_POA_Name__c,RW_Nominee_Name__c,RW_Nominee_PAN_Number__c,RW_POA_PAN_Number__c,RW_POA_Phone_Number__c FROM Name_Confirmation_Form__c WHERE Booking__c IN :bookingId and RW_Active_NCF__c = true ];
        System.debug('after query ncf1*'+ncfDetailsRecord);
        if(ncfDetailsRecord != null && ncfDetailsRecord.size() >0)
        {
            for(Name_Confirmation_Form__c ncfrec : ncfDetailsRecord)
        {
            ncfMap.put(ncfrec.Booking__c,ncfrec);
        }
            return ncfMap;
        }
        else
            return null;
    }
    
    public static List<Document_Details__c> getApplicantKYCDocumentDetailRecords(Set<Id> applicantIds)
    {
        System.debug('before query appliDet*'+applicantIds);
        List<Document_Details__c> documentDetailsRecord = [SELECT Id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c,RW_Residential_Status__c FROM Document_Details__c WHERE RW_Applicant_Details__c IN :applicantIds ];
        System.debug('after query appliDet*'+documentDetailsRecord);
        if(documentDetailsRecord != null && documentDetailsRecord.size() >0)
            return documentDetailsRecord;
        else
            return null;
    }
    
      public static List<RW_Demand__c> getDemandRecords(Set<Id> bookingIds)		
    {		
        System.debug('before query*'+bookingIds);		
        List<RW_Demand__c> demandListRecord = [select Id,Booking__c,Name,RW_Billing_Document_Number__c,RW_Customer_Number__c, RW_Demand_Amount__c, Demand_Date__c, RW_Demand_Status__c, Due_Date__c, RW_ODN_Number__c		
                                 ,RW_Total_Demand_Amount__c, RW_Total_GST_Amount__c,Demand_Amount__c,Total_Demand_Paid__c,Remaining_Amount__c, 		
                                 (select RW_Demand__c,Name,RW_Demand_Item_Amount__c,RW_Demand_Item_Number__c,RW_GST_Amount__c,RW_Milestone_Name__c,RW_Payment_Detail_Item__c,RW_Usage_Code__c from Demand_Items__r)		
                                 FROM RW_Demand__c where /*RW_Demand_Status__c != 'Paid' AND */ Booking__c In :bookingIds];		
        System.debug('after query*'+demandListRecord);		
        if(demandListRecord != null && demandListRecord.size() >0)		
            return demandListRecord;		
        else		
            return null;		
        		
    }
    
     public static List<InspectionAndPossession__c> getInsepectionPossesionRecords(Set<Id> bookingIds)
    {
        System.debug('before query inspection*'+bookingIds);
        List<InspectionAndPossession__c> insepctionListRecord = [select Id,Booking__c,RW_Inspection_Status__c,RW_Expected_Possession_dt__c,RW_Actual_possession_dt__c FROM InspectionAndPossession__c where Booking__c In :bookingIds];
        System.debug('after query inspection*'+insepctionListRecord);
        if(insepctionListRecord != null && insepctionListRecord.size() >0)
            return insepctionListRecord;
        else
            return null;
        
    }
    
     public static List<RW_Payment_Details__c> getPaymentReceipts(Set<Id> bookingIds)
    {
        System.debug('before query reccipets*'+bookingIds);
        List<RW_Payment_Details__c> receiptListRecord = [select Id,RW_Booking__c, RW_Accounting_Document_Number__c,RW_Bank_Reference_Number__c, RW_Branch_Name__c,RW_Clearing_Document_Number__c,RW_Company_Code__c,
                                                RW_Customer_ID__c,RW_Demand__c,RW_Demand_Number__c,RW_Document_Header_Text__c,RW_Document_Type__c,EOI__c,RW_Fiscal_Year__c,RW_Instrument_Number__c,RW_ODN_Number__c,
                                                RW_UniqueId__c,RW_Usage_Code__c, RW_Payment_Date__c, RW_Payment_Amount__c, Status__c, Total_Amount_Paid__c
                                 FROM RW_Payment_Details__c where RW_Booking__c In :bookingIds];
        System.debug('after query reciept record*'+receiptListRecord);
        if(receiptListRecord != null && receiptListRecord.size() >0)
            return receiptListRecord;
        else
            return null;
        
    }
    
    
    public static String getDomainURL()
    {
        return Url.getOrgDomainUrl().toExternalForm();
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
    
    
    
    
      
    
}