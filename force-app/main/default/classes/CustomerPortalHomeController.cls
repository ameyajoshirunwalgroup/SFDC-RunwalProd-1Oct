public class CustomerPortalHomeController 
{
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    //changes made by ishu
    public static String getPrincipalPayableAmount(Decimal totalPrincipal,Decimal totalGST,Decimal totalDemand,Decimal totalOutStanding,Decimal TDSDue)
    {
       
        Decimal principalAmount=0;
     Integer BalanceDues;
         //BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);// Commented by coServe 12-12-2022
         //principalAmount=BalanceDues*(totalPrincipal/totalDemand);// Commented by coServe 12-12-2022
         principalAmount=totalOutStanding*(totalPrincipal/totalDemand);// Added by coServe 12-12-2022
        principalAmount = principalAmount - TDSDue;// Added by coServe 12-12-2022
        System.debug('****principalAmount****'+principalAmount);
     principalAmount=   principalAmount.round();
        System.debug('****principalAmount****'+principalAmount);
        
        return String.valueOf(principalAmount);
    }
    
    //changes made by Srinivas on 15/07/21
     public static String getGstPayableAmount(Decimal totalGST,Decimal totalDemand,Decimal totalOutStanding,Decimal TDSDue)
    {
        Decimal gstAmount=0;
        Decimal principalAmount=0;
     Integer BalanceDues;
         //BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);// Commented by coServe 12-12-2022
         //gstAmount=BalanceDues*(totalGST/totalDemand);// Commented by coServe 12-12-2022
         principalAmount=totalOutStanding*((totalDemand - totalOutStanding)/totalDemand);// Added by coServe 12-12-2022
        gstAmount = Integer.valueOf(totalOutStanding)-Integer.valueOf(principalAmount);// Added by coServe 12-12-2022
       gstAmount= gstAmount.round();
        return String.valueOf(gstAmount);
    }
    public static String getCheckProjectTotalAmount(Decimal totalOutStanding,Decimal TDSDue)
    {
        Integer BalanceDues;
         BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);
        return String.valueOf(BalanceDues);
    }
   

    @AuraEnabled(cacheable=true)
    public static List<User> getLastLoginTime() {        
        system.debug('current user'+UserInfo.getUserId());
        String userId = UserInfo.getUserId();
        System.debug('userId :: ' + userId);
        System.debug('data'+[SELECT AccountId,LastLoginDate FROM User WHERE Id = :userId LIMIT 1]);
        return [SELECT AccountId,LastLoginDate FROM User WHERE Id = :userId LIMIT 1];
    }
    
    @AuraEnabled
    public static List<HomeRunwalWrapper> getPortalHomeData()
    {
        system.debug('current user'+UserInfo.getUserId());
        List<String> status = new List<String>{'Booking Confirmed','Booking Registered','Unit Booked','Cancellation Initiated'};
        List<HomeRunwalWrapper> homeRunwalWrapList = new List<HomeRunwalWrapper>();
        HomeRunwalWrapper homeRunwalWrap = new HomeRunwalWrapper();
        List<Booking__c> bookingRecords = new List<Booking__c>(); 
        Map<Id,Booking__c> BookingMap = new Map<Id,Booking__c>();
        Set<Id> towerIds = new Set<Id>();
        Map<Id,RW_EOI__c> eoiMap = new Map<Id,RW_EOI__c>();
        Map<Id,Name_Confirmation_Form__c> ncfDetailsMap = new Map<Id,Name_Confirmation_Form__c>();
        List<String> excludePicklistValues = new List<String>{'Hardware','Software','Network','General'};
        List<String> excludeCaseTypePicklistValues = new List<String>{'General Feedback'};
        Map<Id,List<RW_Demand__c>> DemandMap = new Map<Id,List<RW_Demand__c>>();
        Map<Id,InspectionAndPossession__c> InspectionMap = new Map<Id,InspectionAndPossession__c>();
        Map<Id,List<Applicant_Details__c>> ApplicantDetailsMap = new Map<Id,List<Applicant_Details__c>>();
        Map<Id,List<Document_Details__c>> DocumentDetailsMap = new Map<Id,List<Document_Details__c>>();
        Map<Id,List<Loan__c>> loanDetailsMap = new Map<Id,List<Loan__c>>();
        Map<Id,List<TDS__c>> tdsDetailsMap = new Map<Id,List<TDS__c>>();
        Map<Id,List<RW_Tower_Construction_Update__c>> constDetailsMap = new Map<Id,List<RW_Tower_Construction_Update__c>>();
        Map<Id,List<RW_Payment_Details__c>> receiptsMap = new Map<Id,List<RW_Payment_Details__c>>();
        Set<Id> oppIds = new Set<Id> ();
        Set<Id> bookingIds = new Set<Id> ();
        List<String> CountryNames = getPicklists('Applicant_Details__c', 'Country__c');
        List<String> stateNames = getPicklists('Applicant_Details__c', 'State__c');
        List<String> cityNames = getPicklists('Applicant_Details__c', 'City__c');
         List<String> applicantTypeValues = getPicklists('Applicant_Details__c', 'Type_Of_Applicant__c');
        List<String> ResidentialStatusValues = getPicklists('Applicant_Details__c', 'Subtype_Of_Applicant__c');
        List<String> typeofOriginValues = getPicklists('Applicant_Details__c', 'Type_Of_Origin__c');
         List<String> addressProofDocValues = getPicklists('Applicant_Details__c', 'Address_Proof_Document__c');
        
        Map<String,String> fieldMap = new Map<String,String>();
        fieldMap.put('Subtype_Of_Applicant__c','Type_Of_Applicant__c');
        Map<string,PicklistWrapper> DependentPickListMap = getDependentPicklists('Applicant_Details__c',fieldMap);
        Map<String,String> complaintfieldMap = new Map<String,String>();
        complaintfieldMap.put('RW_Complaint_SubType__c','RW_Complaint_Type__c');
        Map<String,String> custLifefieldMap = new Map<String,String>(); //Added by Vinay 28-03-2025
        custLifefieldMap.put('RW_Complaint_Type__c','Customer_Lifecycle_Touchpoint__c'); //Added by Vinay 28-03-2025
        Map<String,String> caseTypefieldMap = new Map<String,String>(); 
        //caseTypefieldMap.put('RW_Complaint_Type__c','RW_Case_Type__c');  //Commented by Vinay 28-03-2025
        caseTypefieldMap.put('Customer_Lifecycle_Touchpoint__c','RW_Case_Type__c'); //Added by Vinay 28-03-2025
        
        
        Map<string,PicklistWrapper> ComplaintDependentPickListMap = getDependentPicklists('Case',complaintfieldMap);
     
            for(String key : ComplaintDependentPickListMap.keyset() )
            {
                for(String picklistkey : ComplaintDependentPickListMap.get(key).pickListMap.keyset())
                {
                    if(excludePicklistValues.contains(picklistkey))
                    {
                        ComplaintDependentPickListMap.get(key).pickListMap.remove(picklistkey);
                    }
                }
            }

            //Added by Vinay 28-03-2025 Start
            Map<string,PicklistWrapper> CustLifeDependentPickListMap = getDependentPicklists('Case',custLifefieldMap);
     
            for(String key : CustLifeDependentPickListMap.keyset() )
            {
                for(String picklistkey : CustLifeDependentPickListMap.get(key).pickListMap.keyset())
                {
                    if(excludeCaseTypePicklistValues.contains(picklistkey))
                    {
                        CustLifeDependentPickListMap.get(key).pickListMap.remove(picklistkey);
                    }
                    else
                    {
                        for(Integer i=0 ; i<CustLifeDependentPickListMap.get(key).pickListMap.get(picklistkey).size(); i++)
                        {
                     
                           if(excludePicklistValues.contains(CustLifeDependentPickListMap.get(key).pickListMap.get(picklistkey)[i]))
                            {
                                CustLifeDependentPickListMap.get(key).pickListMap.get(picklistkey).remove(i);
                            }
                                
                        }
                    }
                }
            }
            //Added by Vinay 28-03-2025 End
        Map<string,PicklistWrapper> CaseTypeDependentPickListMap = getDependentPicklists('Case',caseTypefieldMap);
     
            for(String key : CaseTypeDependentPickListMap.keyset() )
            {
                for(String picklistkey : CaseTypeDependentPickListMap.get(key).pickListMap.keyset())
                {
                    if(excludeCaseTypePicklistValues.contains(picklistkey))
                    {
                        CaseTypeDependentPickListMap.get(key).pickListMap.remove(picklistkey);
                    }
                    else
                    {
                        for(Integer i=0 ; i<CaseTypeDependentPickListMap.get(key).pickListMap.get(picklistkey).size(); i++)
                        {
                     
                           if(excludePicklistValues.contains(CaseTypeDependentPickListMap.get(key).pickListMap.get(picklistkey)[i]))
                            {
                                CaseTypeDependentPickListMap.get(key).pickListMap.get(picklistkey).remove(i);
                            }
                                
                        }
                    }
                }
            }
        
        system.debug('*countryNames*'+CountryNames);
        try
        {
            List<User> u = [SELECT Name, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
            System.debug('accId = ' + u[0].AccountId);
            if(!u.isEmpty()) 
            {
                Id accountId = u[0].AccountId; 
                Account accRecord = CustomerPortalUtility.getopportunitiesfromAccount(accountId);
                if(accRecord != null)
                {
                    system.debug('opp childs'+accRecord.Opportunities.size());
                    for(Opportunity opp : accRecord.Opportunities)
                    {
                        System.debug('**opp**'+opp);
                        oppIds.add(opp.Id);
                    }
                   if(oppIds.size() > 0) 
                   {
                       List<Opportunity> oppRecords = CustomerPortalUtility.getOpportunities(oppIds);
                       if(oppRecords != null && oppRecords.size() >0)
                       {
                           System.debug('**opps**'+oppRecords);
                           
                           for(Opportunity opps : oppRecords)
                           {
                               
                               for(Booking__c bookrecs : opps.Booking__r)
                               {
                                   System.debug('**Pro Name**'+bookrecs.Project__r.Name);
                                   //if(status.contains(bookrecs.Status__c))
                                   //{
                                   System.debug('**bookrecs**'+bookrecs);
                                   //bookingRecords.add(bookrecs);
                                   //bookingIds.add(bookrecs.Id);
                                   /*HomeRunwalWrapper wrapper = new HomeRunwalWrapper();
                                   wrapper.BookingId = bookrecs.Id;
                                   wrapper.BookingStatus = bookrecs.Status__c;*/
                                   BookingMap.put(bookrecs.Id,bookrecs);
                                   towerIds.add(bookrecs.Unit_No__r.TowerName__c);
                                   //}
                                   
                               }
                               
                               for(RW_EOI__c eoiRecs : opps.EOI__r)
                               {
                                   if(eoiRecs.RW_Status__c == 'EOI Confirmed' || eoiRecs.RW_Status__c =='EOI Blocked' ||eoiRecs.RW_Status__c =='EOI Booked')
                                   eoiMap.put(eoiRecs.Opportunity__c,eoiRecs);
                               }
                           }
                           
                           if(BookingMap.size() >0)
                           {
                               System.debug('**inside if first*');
                               List<RW_Demand__c> demands = CustomerPortalUtility.getDemandRecords(BookingMap.Keyset());
                               if(demands != null)
                               {
                               for(RW_Demand__c eachdemandRec : demands)
                               {
                                   System.debug('**inside demand for 1*');
                                   if(DemandMap.containsKey(eachdemandRec.Booking__c))
                                   {
                                       List<RW_Demand__c> existingDemand = DemandMap.get(eachdemandRec.Booking__c);
                                       existingDemand.add(eachdemandRec);
                                       DemandMap.put(eachdemandRec.Booking__c,existingDemand);
                                   }
                                   else
                                   {
                                       System.debug('**inside demand for else*');
                                       DemandMap.put(eachdemandRec.Booking__c,new List<RW_Demand__c>{eachdemandRec});
                                   }
                               }
                               }
                               
                                System.debug('**inside if of possesion*');
                               List<InspectionAndPossession__c> inspections = CustomerPortalUtility.getInsepectionPossesionRecords(BookingMap.Keyset());
                               system.debug('inspection-------> ' +  inspections);
                               if(inspections != null)
                               {
                               for(InspectionAndPossession__c eachinspectionRec : inspections)
                               {
                                   System.debug('**inside inspection for 1*');
                                  /* if(InspectionMap.containsKey(eachinspectionRec.Booking__c))
                                   {
                                       List<InspectionAndPossession__c> existingInspection = InspectionMap.get(eachinspectionRec.Booking__c);
                                       existingInspection.add(eachinspectionRec);
                                       InspectionMap.put(eachinspectionRec.Booking__c,existingInspection);
                                   }
                                   else
                                   {*/
                                       System.debug('**inside inspection for else*');
                                       InspectionMap.put(eachinspectionRec.Booking__c,eachinspectionRec);
                                  // }
                                       system.debug('iInspectionMap values -------> '+ InspectionMap);
                               }
                               }
                               
                               
                               List<RW_Payment_Details__c> receipts = CustomerPortalUtility.getPaymentReceipts(BookingMap.Keyset());
                               system.debug('receipt for the booking' + receipts);
                                  if(receipts !=null)
                               {
                                   for(RW_Payment_Details__c eachreceiptrec : receipts)
                                   {
                                    System.debug('**inside receipt for 1*');
                                   if(receiptsMap.containsKey(eachreceiptrec.RW_Booking__c))
                                   {
                                       List<RW_Payment_Details__c> existingReceipts = receiptsMap.get(eachreceiptrec.RW_Booking__c);
                                       existingReceipts.add(eachreceiptrec);
                                       receiptsMap.put(eachreceiptrec.RW_Booking__c,existingReceipts);
                                       System.debug('**inside receipt Map*' + receiptsMap);
                                   }
                                   else
                                   {
                                       System.debug('**inside receipt for else*');
                                       receiptsMap.put(eachreceiptrec.RW_Booking__c,new List<RW_Payment_Details__c>{eachreceiptrec});
                                   }
                               }  
                                       
                               }
                              Set<Id> appDetailSet = new Set<Id>();
                              List<Applicant_Details__c> appDetailsRecs = CustomerPortalUtility.getApplicantDetailsRecords(BookingMap.Keyset());
                              if(appDetailsRecs != null)
                              {
                               for(Applicant_Details__c appDetail : appDetailsRecs)
                               {
                                   appDetailSet.add(appDetail.Id);
                                   System.debug('**inside demand for 1*');
                                   if(ApplicantDetailsMap.containsKey(appDetail.Booking__c))
                                   {
                                       List<Applicant_Details__c> existingappDetails = ApplicantDetailsMap.get(appDetail.Booking__c);
                                       existingappDetails.add(appDetail);
                                       ApplicantDetailsMap.put(appDetail.Booking__c,existingappDetails);
                                   }
                                   else
                                   {
                                       System.debug('**inside demand for else*');
                                       ApplicantDetailsMap.put(appDetail.Booking__c,new List<Applicant_Details__c>{appDetail});
                                   }
                               }
                              }
                               
                               List<Document_Details__c> docDetailsRecs = CustomerPortalUtility.getApplicantKYCDocumentDetailRecords(appDetailSet);
                               if(docDetailsRecs != null) 
                               {
                               for(Document_Details__c docuDetail : docDetailsRecs)
                               {

                                   System.debug('**inside doc for 1*');
                                   if(DocumentDetailsMap.containsKey(docuDetail.RW_Applicant_Details__c))
                                   {
                                       List<Document_Details__c> existingdocDetails = DocumentDetailsMap.get(docuDetail.RW_Applicant_Details__c);
                                       existingdocDetails.add(docuDetail);
                                       DocumentDetailsMap.put(docuDetail.RW_Applicant_Details__c,existingdocDetails);
                                   }
                                   else
                                   {
                                       System.debug('**inside demand for else*');
                                       DocumentDetailsMap.put(docuDetail.RW_Applicant_Details__c,new List<Document_Details__c>{docuDetail});
                                   }
                               }
                               }
                               
                                List<Loan__c> loanDetailsRecs = CustomerPortalUtility.getloanDetailRecords(BookingMap.Keyset());
                                if(loanDetailsRecs !=null)
                                {
                               for(Loan__c loanDetail : loanDetailsRecs)
                               {
                                   System.debug('**inside loan for 1*');
                                   if(loanDetailsMap.containsKey(loanDetail.RW_Booking__c))
                                   {
                                       List<Loan__c> existingloanDetails = loanDetailsMap.get(loanDetail.RW_Booking__c);
                                       existingloanDetails.add(loanDetail);
                                       loanDetailsMap.put(loanDetail.RW_Booking__c,existingloanDetails);
                                   }
                                   else
                                   {
                                       System.debug('**inside loan for else*');
                                       loanDetailsMap.put(loanDetail.RW_Booking__c,new List<Loan__c>{loanDetail});
                                   }
                               }
                                }
                                List<TDS__c> tdsDetailsRecs = CustomerPortalUtility.getTDSDetailRecords(BookingMap.Keyset());
                              if(tdsDetailsRecs != null)
                              {
                               for(TDS__c tdsDetail : tdsDetailsRecs)
                               {
                                   System.debug('**inside loan for 1*');
                                   if(tdsDetailsMap.containsKey(tdsDetail.Booking__c))
                                   {
                                       List<TDS__c> existingtdsDetails = tdsDetailsMap.get(tdsDetail.Booking__c);
                                       existingtdsDetails.add(tdsDetail);
                                       tdsDetailsMap.put(tdsDetail.Booking__c,existingtdsDetails);
                                   }
                                   else
                                   {
                                       System.debug('**inside loan for else*');
                                       tdsDetailsMap.put(tdsDetail.Booking__c,new List<TDS__c>{tdsDetail});
                                   }
                               }
                              }
                               
                               
                                Map<String,Name_Confirmation_Form__c> ncfDetailsRecs = CustomerPortalUtility.getNCFRecordDetails(BookingMap.Keyset());
                              if(ncfDetailsRecs != null)
                              {
                               for(String ncfDetail : ncfDetailsRecs.keyset())
                               {
                                   ncfDetailsMap.put(ncfDetail,ncfDetailsRecs.get(ncfDetail));
                                   System.debug('**inside loan for 1*');
                               }
                              
                              }
                               
                               List<RW_Tower_Construction_Update__c> constructiondetails = CustomerPortalUtility.getconstructionDetailRecords(towerIds);
                               system.debug('constructiondetails*'+constructiondetails);
                               if(constructiondetails != null && constructiondetails.size() >0)
                               {
                                   for(RW_Tower_Construction_Update__c constructionupdates : constructiondetails)
                                   {
                                       if(constDetailsMap.containsKey(constructionupdates.RW_Tower__c))
                                   {
                                       List<RW_Tower_Construction_Update__c> existingconstDetails = constDetailsMap.get(constructionupdates.RW_Tower__c);
                                       existingconstDetails.add(constructionupdates);
                                       constDetailsMap.put(constructionupdates.RW_Tower__c,existingconstDetails);
                                   }
                                   else
                                   {
                                       System.debug('**inside loan for else*');
                                       constDetailsMap.put(constructionupdates.RW_Tower__c,new List<RW_Tower_Construction_Update__c>{constructionupdates});
                                   }

                                   }
                               }
                               
                           }
                       }
                       
                       
                   }
                }
            }
            
            for(Id bookingId :BookingMap.keyset())
            {
                HomeRunwalWrapper homeRunwalWrapper = new HomeRunwalWrapper();
                homeRunwalWrapper.BookingId = BookingMap.get(bookingId).Id;
                homeRunwalWrapper.currentUserId = UserInfo.getUserId();
                homeRunwalWrapper.sitelink = Label.SiteURL;
                homeRunwalWrapper.opportunityId =BookingMap.get(bookingId).Customer__c;
                homeRunwalWrapper.BookingName =BookingMap.get(bookingId).Name;
                homeRunwalWrapper.BookingStatus = BookingMap.get(bookingId).Status__c;
                homeRunwalWrapper.countryNames = CountryNames;
                homeRunwalWrapper.stateNames = stateNames;
                homeRunwalWrapper.cityNames = cityNames;
                homeRunwalWrapper.communityName = Label.Community_Name;
                if(BookingMap.get(bookingId).RW_Registration_Status__c != null)
                homeRunwalWrapper.registrationstatus = BookingMap.get(bookingId).RW_Registration_Status__c;
                if(BookingMap.get(bookingId).RW_Agreement_Status__c != null)
                homeRunwalWrapper.agreementStatus = BookingMap.get(bookingId).RW_Agreement_Status__c;
                if(BookingMap.get(bookingId).RW_Signed_Agreement_Document_Id__c != null)
                homeRunwalWrapper.agreementDocumentId=BookingMap.get(bookingId).RW_Signed_Agreement_Document_Id__c;
                homeRunwalWrapper.TotalDemandRaised = BookingMap.get(bookingId).RW_Total_Demand_Raised__c ;
                //changes made by ishu--------------
             if(BookingMap.get(bookingId).RW_Total_GST_Amount__c!=null)
             homeRunwalWrapper.TotalGST = BookingMap.get(bookingId).RW_Total_GST_Amount__c;
                if(BookingMap.get(bookingId).Total_Demand_Raised_Principal__c!=null)
                homeRunwalWrapper.TotalPrincipalDemand=BookingMap.get(bookingId).Total_Demand_Raised_Principal__c;
                //--------------------------------------------------------------------------------
                if(BookingMap.get(bookingId).RW_Total_Demand_Paid_D__c != null)
                homeRunwalWrapper.TotalDemandPaid = String.valueOf(BookingMap.get(bookingId).RW_Total_Demand_Paid_D__c) ;
                if(BookingMap.get(bookingId).RW_Total_Receipt_Amount_Received__c != null)
                homeRunwalWrapper.TotalAmountRecieved = string.valueof(BookingMap.get(bookingId).RW_Total_Receipt_Amount_Received__c);
                if(BookingMap.get(bookingId).RW_Total_Receipt_Discount_Recieved__c != null)
                homeRunwalWrapper.TotalDiscount = string.valueof(BookingMap.get(bookingId).RW_Total_Receipt_Discount_Recieved__c);
                if(BookingMap.get(bookingId).RW_Total_Demand_Outstanding__c != null)
              //  homeRunwalWrapper.TotalDemandOutstanding = string.valueof(BookingMap.get(bookingId).RW_Total_Demand_Outstanding__c);
                homeRunwalWrapper.TotalDemandOutstanding=BookingMap.get(bookingId).RW_Total_Demand_Raised__c - BookingMap.get(bookingId).RW_Total_Receipt_Amount_Received__c - BookingMap.get(bookingId).RW_Total_Receipt_Discount_Recieved__c ;
                homeRunwalWrapper.NextDemandDate = BookingMap.get(bookingId).RW_Next_Demand_Date__c;
                homeRunwalWrapper.ExpectedSDRDate = BookingMap.get(bookingId).RW_Expected_SDR_Date__c;
                if(BookingMap.get(bookingId).RW_Registration_Date__c !=null)
                homeRunwalWrapper.ExpectedRegistrationDate = BookingMap.get(bookingId).RW_Registration_Date__c.format();
                homeRunwalWrapper.SDRStatus = BookingMap.get(bookingId).RW_SDR_Status__c;
                homeRunwalWrapper.ProjectId = BookingMap.get(bookingId).Project__c; 
                homeRunwalWrapper.companyCode = BookingMap.get(bookingId).Project__r.RW_SAP_Company_Code__c; 
                if(InspectionMap.containsKey(bookingId))
                {
                homeRunwalWrapper.inspectionId = InspectionMap.get(bookingId).id;
                homeRunwalWrapper.inspectionStatus = InspectionMap.get(bookingId).RW_Inspection_Status__c;
                if(InspectionMap.get(bookingId).RW_Expected_Possession_dt__c !=null)
                homeRunwalWrapper.expectedPossesionDate = date.newinstance(InspectionMap.get(bookingId).RW_Expected_Possession_dt__c.year(), InspectionMap.get(bookingId).RW_Expected_Possession_dt__c.month(), InspectionMap.get(bookingId).RW_Expected_Possession_dt__c.day()).format();
                }     
                
                system.debug('Total Demand Raised & Total Demand Paid & SDR Status'+ homeRunwalWrapper.TotalDemandRaised + homeRunwalWrapper.TotalDemandPaid + homeRunwalWrapper.SDRStatus);
                system.debug('Expected SDR Date & Expected Registration Date'+ homeRunwalWrapper.ExpectedSDRDate + homeRunwalWrapper.ExpectedRegistrationDate);
                system.debug('Next Demand date & SDR Status & inspection status & possesion date'+ homeRunwalWrapper.NextDemandDate + homeRunwalWrapper.SDRStatus + homeRunwalWrapper.inspectionStatus + homeRunwalWrapper.expectedPossesionDate);
                
                
                homeRunwalWrapper.OverallTDSPaid = String.valueOf(BookingMap.get(bookingId).Total_TDS_Amount_Paid_In_Rs__c);
                homeRunwalWrapper.NetTDSOutstanding = String.valueOf(BookingMap.get(bookingId).RW_Total_TDS_Outstanding__c);
                homeRunwalWrapper.TotalTDSDue= BookingMap.get(bookingId).RW_Total_TDS_Due__c;
                homeRunwalWrapper.applicantTypePicklistValues = applicantTypeValues;
                homeRunwalWrapper.residentailstatusPicklistValues = ResidentialStatusValues;
                homeRunwalWrapper.typeofOriginPicklistValues = typeofOriginValues;
                homeRunwalWrapper.addressproofPicklistValues = addressProofDocValues;
              
                
                //-----------------changes made by ishu-------------
                if(BookingMap.get(bookingId).Unit_No__r.TowerName__r.Enable_BillDesk__c==true){
                if(homeRunwalWrapper.TotalDemandOutstanding>homeRunwalWrapper.TotalTDSDue){
                    homeRunwalWrapper.Flag=true;
                  String TotalPrincipalPayable=getPrincipalPayableAmount(homeRunwalWrapper.TotalPrincipalDemand,homeRunwalWrapper.TotalGST,homeRunwalWrapper.TotalDemandRaised,homeRunwalWrapper.TotalDemandOutstanding,homeRunwalWrapper.TotalTDSDue);
                homeRunwalWrapper.TotalAmountPaid = String.valueof(TotalPrincipalPayable);
                    System.debug('TotalPrincipalPayable'+TotalPrincipalPayable);
                    System.debug('homeRunwalWrapper.TotalAmountPaid'+homeRunwalWrapper.TotalAmountPaid);
                //---------------------------------------
                               //homeRunwalWrapper.dependentPicklistMap = new Map<string,PicklistWrapper>();
                // changes made by Srinivas on 15/07/21
                String TotalGstPayable=getGstPayableAmount(homeRunwalWrapper.TotalGST,homeRunwalWrapper.TotalDemandRaised,homeRunwalWrapper.TotalDemandOutstanding,homeRunwalWrapper.TotalTDSDue);
                homeRunwalWrapper.TotalGSTPaid =  String.valueOf(Decimal.valueOf(TotalGstPayable).setScale(0));
                 if(BookingMap.get(bookingId).Project__r.Seperate_payment__c==true){
                    
                    homeRunwalWrapper.SeperatePay=true;
                     
                        
                    String ProjectSpecificTotalAmount=getCheckProjectTotalAmount(homeRunwalWrapper.TotalDemandOutstanding,homeRunwalWrapper.TotalTDSDue);
                    if(ProjectSpecificTotalAmount!=null)
                        homeRunwalWrapper.ProjectSpecificAmount=ProjectSpecificTotalAmount;
                }
                else
                homeRunwalWrapper.SeperatePay=false;
                }
               
                }                
               // Boolean checkTotalOutstanding=checkTotalOutstatnding(homeRunwalWrapper.TotalDemandOutstanding,homeRunwalWrapper.TotalTDSDue);
              
            
               
                
                
                //ends 
                homeRunwalWrapper.dependentPicklistMap = new Map<string,homeRunwalWrapper.PicklistWrapper>();
                homeRunwalWrapper.PicklistWrapper pickWrap = new homeRunwalWrapper.PicklistWrapper();
                for(String key : DependentPickListMap.keySet())
                {
                    pickWrap.pickListMap = DependentPickListMap.get(key).pickListMap;
                    pickWrap.childFieldLabel = DependentPickListMap.get(key).childFieldLabel;
                    pickWrap.parentFieldLabel = DependentPickListMap.get(key).parentFieldLabel;
                    homeRunwalWrapper.dependentPicklistMap.put(key,pickWrap);
                }
                
                
                homeRunwalWrapper.complaintdependentPicklistMap = new Map<string,homeRunwalWrapper.PicklistWrapper>();
                homeRunwalWrapper.PicklistWrapper complaintpickWrap = new homeRunwalWrapper.PicklistWrapper();
                
                
                for(String key : ComplaintDependentPickListMap.keySet())
                {
                    system.debug('ComplaintDependentPickListMap.keySet()*'+ComplaintDependentPickListMap.keySet());
                    
                    complaintpickWrap.pickListMap = ComplaintDependentPickListMap.get(key).pickListMap;
                    complaintpickWrap.childFieldLabel = ComplaintDependentPickListMap.get(key).childFieldLabel;
                    complaintpickWrap.parentFieldLabel = ComplaintDependentPickListMap.get(key).parentFieldLabel;
                    homeRunwalWrapper.complaintdependentPicklistMap.put(key,complaintpickWrap);
                    system.debug('ComplaintDependentPickListMap.keySet() done*'+ComplaintDependentPickListMap.keySet());
                    
                }
                
                homeRunwalWrapper.caseTypedependentPicklistMap = new Map<string,homeRunwalWrapper.PicklistWrapper>();
                homeRunwalWrapper.PicklistWrapper caseTypepickWrap = new homeRunwalWrapper.PicklistWrapper();
                
                
                for(String key : CaseTypeDependentPickListMap.keySet())
                {
                    system.debug('ComplaintDependentPickListMap.keySet()*'+CaseTypeDependentPickListMap.keySet());
                    
                    caseTypepickWrap.pickListMap = CaseTypeDependentPickListMap.get(key).pickListMap;
                    caseTypepickWrap.childFieldLabel = CaseTypeDependentPickListMap.get(key).childFieldLabel;
                    caseTypepickWrap.parentFieldLabel = CaseTypeDependentPickListMap.get(key).parentFieldLabel;
                    homeRunwalWrapper.caseTypedependentPicklistMap.put(key,caseTypepickWrap);
                    system.debug('ComplaintDependentPickListMap.keySet() done*'+CaseTypeDependentPickListMap.keySet());
                    
                }
                
                //Added by Vinay 28-03-2025 Start
                homeRunwalWrapper.custLifedependentPicklistMap = new Map<string,homeRunwalWrapper.PicklistWrapper>();
                homeRunwalWrapper.PicklistWrapper custLifepickWrap = new homeRunwalWrapper.PicklistWrapper();
                
                for(String key : CustLifeDependentPickListMap.keySet())
                {
                    system.debug('CustLifeDependentPickListMap.keySet()*'+CustLifeDependentPickListMap.keySet());
                    
                    custLifepickWrap.pickListMap = CustLifeDependentPickListMap.get(key).pickListMap;
                    custLifepickWrap.childFieldLabel = CustLifeDependentPickListMap.get(key).childFieldLabel;
                    custLifepickWrap.parentFieldLabel = CustLifeDependentPickListMap.get(key).parentFieldLabel;
                    homeRunwalWrapper.custLifedependentPicklistMap.put(key,custLifepickWrap);
                    system.debug('CustLifeDependentPickListMap.keySet() done*'+CustLifeDependentPickListMap.keySet());
                    
                }
                //Added by Vinay 28-03-2025 End
                
                
                //homeRunwalWrapper.dependentPicklistMap =DependentPickListMap;
                if(BookingMap.get(bookingId).Customer__c!= null && BookingMap.get(bookingId).Customer__r.SAP_CUstomer_Number__c != null)
                homeRunwalWrapper.customerNumber = BookingMap.get(bookingId).Customer__r.SAP_CUstomer_Number__c;
                if(BookingMap.get(bookingId).Customer__c!= null && BookingMap.get(bookingId).Customer__r.SalesOrder_Number__c != null)
                homeRunwalWrapper.salesorderNumber = BookingMap.get(bookingId).Customer__r.SalesOrder_Number__c;
                if(BookingMap.get(bookingId).Customer__c!= null && BookingMap.get(bookingId).Customer__r.Portal_Possession_Survey_Link_Id__c != null)
                homeRunwalWrapper.possessionlinkId = BookingMap.get(bookingId).Customer__r.Portal_Possession_Survey_Link_Id__c;
                if(BookingMap.get(bookingId).Customer__c!= null && BookingMap.get(bookingId).Customer__r.Booking_Feedback_Link__c != null)
                homeRunwalWrapper.bookinglinkId = BookingMap.get(bookingId).Customer__r.Booking_Feedback_Link__c;
                if(BookingMap.get(bookingId).Project__c != null)
                homeRunwalWrapper.ProjectName=BookingMap.get(bookingId).Project__r.Name;
                if(BookingMap.get(bookingId).Project__c != null && BookingMap.get(bookingId).Project__r.RW_Project_Brochure_PublicUrl__c != null)
                homeRunwalWrapper.ProjectBrochureLink = BookingMap.get(bookingId).Project__r.RW_Project_Brochure_PublicUrl__c;
                if(BookingMap.get(bookingId).Project__c != null && BookingMap.get(bookingId).Project__r.RW_Project_Location_Videos_Link__c != null)
                homeRunwalWrapper.ProjectVideoLink = BookingMap.get(bookingId).Project__r.RW_Project_Location_Videos_Link__c;
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.TowerName__c !=null && BookingMap.get(bookingId).Unit_No__r.TowerName__r.RW_Floor_Plan__c != null)
                homeRunwalWrapper.TowerFloorPlanLink = BookingMap.get(bookingId).Unit_No__r.TowerName__r.RW_Floor_Plan__c;
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.TowerName__c !=null)
                {
                homeRunwalWrapper.TowerId = BookingMap.get(bookingId).Unit_No__r.TowerName__c;
                homeRunwalWrapper.TowerName=BookingMap.get(bookingId).Unit_No__r.TowerName__r.Name;
                }
                system.debug('*RM*'+BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__c+'RM Name'+BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Name__c);
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__c !=null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Name__c != null)
                homeRunwalWrapper.RMName =BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Name__c;
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__c !=null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.Contact_Number__c != null)
                homeRunwalWrapper.RMNumber =BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.Contact_Number__c;
                /*if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__c !=null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Email__c != null)
                homeRunwalWrapper.RMEmail =BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Email__c;*/
                if(BookingMap.get(bookingId).Project__c != null && BookingMap.get(bookingId).Project__r.Customer_Care_Email__c != null){
                    homeRunwalWrapper.RMEmail =BookingMap.get(bookingId).Project__r.Customer_Care_Email__c;
                }
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.RW_Param4__c !=null)
                homeRunwalWrapper.unitNumber=BookingMap.get(bookingId).Unit_No__r.RW_Param4__c;
                homeRunwalWrapper.unitNo=BookingMap.get(bookingId).Unit_No__c;
                if(BookingMap.get(bookingId).Customer__c != null && BookingMap.get(bookingId).Customer__r.RW_Agreement_Value__c !=null)
                homeRunwalWrapper.agreementValue=String.valueOf(BookingMap.get(bookingId).Customer__r.RW_Agreement_Value__c);
                System.debug('*Quot*'+BookingMap.get(bookingId).Quotation__c+'**'+BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c);
                if(BookingMap.get(bookingId).Quotation__c != null && BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c !=null){
                    homeRunwalWrapper.numberofCarParking=String.valueOf(BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c);
                }else if(BookingMap.get(bookingId).Quotation__c == null && BookingMap.get(bookingId).No_of_Parking__c != null){ // Added by Vinay 18-07-2025
                    homeRunwalWrapper.numberofCarParking=String.valueOf(BookingMap.get(bookingId).No_of_Parking__c);
                }
                
                if(BookingMap.get(bookingId).Floor__c !=null)
                homeRunwalWrapper.Floor=String.valueOf(BookingMap.get(bookingId).Floor__c);
                if(BookingMap.get(bookingId).Source_of_Booking__c != null)
                homeRunwalWrapper.SourceOfBooking= BookingMap.get(bookingId).Source_of_Booking__c;
                if(!String.isBlank(String.valueOf(BookingMap.get(bookingId).Booking_Date__c)))
                homeRunwalWrapper.BookingDate=BookingMap.get(bookingId).Booking_Date__c.format('dd/MM/yyyy');
                /*if(BookingMap.get(bookingId).Carpet_Area__c != null)
                homeRunwalWrapper.CarpetArea=String.valueOf(BookingMap.get(bookingId).Carpet_Area__c);*/
                //System.debug('--Unit--: ' + BookingMap.get(bookingId).Unit_No__c);
                //System.debug('--Carpet Area--: ' + BookingMap.get(bookingId).Unit_No__r.Total_RERA_Carpet_Area__c);
                if(BookingMap.get(bookingId).Unit_No__r.Total_RERA_Carpet_Area__c != null)
                    homeRunwalWrapper.CarpetArea=String.valueOf(BookingMap.get(bookingId).Unit_No__r.Total_RERA_Carpet_Area__c);
                if(BookingMap.get(bookingId).Customer__c != null && eoiMap.containsKey(BookingMap.get(bookingId).Customer__c))
                {
                 homeRunwalWrapper.encryptedeoiRecordId =CustomerPortalUtility.getEncryptedData(eoiMap.get(BookingMap.get(bookingId).Customer__c).Id);
                homeRunwalWrapper.eoiId = eoiMap.get(BookingMap.get(bookingId).Customer__c).Id;  
                }
                homeRunwalWrapper.encryptedBookingId =CustomerPortalUtility.getEncryptedData(bookingId);
                
                homeRunwalWrapper.domainURL = CustomerPortalUtility.getDomainURL();
                homeRunwalWrapper.documentdomainURL = CustomerPortalUtility.getDomainURL().substringBefore('.') + '--c.documentforce.com';
                SYstem.debug('*total interest*'+BookingMap.get(bookingId).RW_Total_Interest__c);
                if(BookingMap.get(bookingId).RW_Total_Interest__c != null)
                homeRunwalWrapper.totalInterest = String.valueOf(BookingMap.get(bookingId).RW_Total_Interest__c);
                if(BookingMap.get(bookingId).RW_Total_Interest_Amount_Waived__c != null)
                homeRunwalWrapper.totalInterestWaived = String.valueOf(BookingMap.get(bookingId).RW_Total_Interest_Amount_Waived__c);
                if(BookingMap.get(bookingId).RW_Total_Collectable_Interest__c != null)
                homeRunwalWrapper.totalcollectibleInterest = String.valueOf(BookingMap.get(bookingId).RW_Total_Collectable_Interest__c);
                if(BookingMap.get(bookingId).RW_Total_Amount_Collected__c != null)
                homeRunwalWrapper.totalamountcollected = String.valueOf(BookingMap.get(bookingId).RW_Total_Amount_Collected__c);
                if(BookingMap.get(bookingId).RW_Total_Amount_Balance__c != null)
                homeRunwalWrapper.totalamountbalance = String.valueOf(BookingMap.get(bookingId).RW_Total_Amount_Balance__c);
                if(BookingMap.get(bookingId).RW_Total_TDS_Due__c != null)
                homeRunwalWrapper.OverallTDSPayable = String.valueOf(BookingMap.get(bookingId).RW_Total_TDS_Due__c);
                
                System.debug('*email*'+BookingMap.get(bookingId).Primary_Applicant_Email__c+'**'+BookingMap.get(bookingId));
                if(BookingMap.get(bookingId).Primary_Applicant_Email__c != null)
                {
                    System.debug('inside email if');
                homeRunwalWrapper.PrimaryApplicantEmail = String.valueOf(BookingMap.get(bookingId).Primary_Applicant_Email__c);
                    System.debug('inside email if'+homeRunwalWrap.PrimaryApplicantEmail);
                }
                
                if(constDetailsMap.containskey(BookingMap.get(bookingId).Unit_No__r.TowerName__c))
                {
                    SYstem.debug('inside cons if*****');
                    for(RW_Tower_Construction_Update__c contructionupdate : constDetailsMap.get(BookingMap.get(bookingId).Unit_No__r.TowerName__c))
                    {
                    
                    
                    
                    
                    
                    if(homeRunwalWrapper.towerConstructionDetails.containskey(contructionupdate.RW_Date_Month__c+','+contructionupdate.RW_Date_Year__c))
                    {
                        SYstem.debug('inside cons if1*****');
                        Map<String,String> existingphotodetailsMap = homeRunwalWrapper.towerConstructionDetails.get(contructionupdate.RW_Date_Month__c+','+contructionupdate.RW_Date_Year__c);
                        existingphotodetailsMap.put(contructionupdate.RW_Tower_Construction_Photo_ID__c, contructionupdate.RW_Description__c);
                        homeRunwalWrapper.towerConstructionDetails.put(contructionupdate.RW_Date_Month__c+','+contructionupdate.RW_Date_Year__c,existingphotodetailsMap);
                        SYstem.debug('inside cons if1 end*****'+homeRunwalWrapper.towerConstructionDetails);
                    }
                    else
                    {
                        if(homeRunwalWrapper.towerConstructionDetails.size() <= 20)
                        {
                        SYstem.debug('inside cons else if1*****');
                        Map<String,String> photodetailsMap = new Map<String,String>();
                        photodetailsMap.put(contructionupdate.RW_Tower_Construction_Photo_ID__c, contructionupdate.RW_Description__c);
                        homeRunwalWrapper.towerConstructionDetails.put(contructionupdate.RW_Date_Month__c+','+contructionupdate.RW_Date_Year__c,photodetailsMap);
                        SYstem.debug('inside cons else if1 end*****'+homeRunwalWrapper.towerConstructionDetails);
                        }
                    }   
                    
                        
                   /* homeRunwalWrapper.towerConstructionWrapper towerconwrap = new homeRunwalWrapper.towerConstructionWrapper();
                    towerconwrap.description = contructionupdate.RW_Description__c;
                    towerconwrap.photodate = contructionupdate.RW_Date__c;
                    towerconwrap.photodatemonth = contructionupdate.RW_Date_Month__c;
                    towerconwrap.photodateyear = contructionupdate.RW_Date_Year__c;
                    towerconwrap.photodocumentID= contructionupdate.RW_Tower_Construction_Photo_ID__c;
                        //Url.getOrgDomainUrl().toExternalForm()
                    towerconwrap.imageURL = contructionupdate.RW_Tower_Construction_Photo__c;
                    homeRunwalWrapper.towerConstructionWrapperList.add(towerconwrap);*/
                    }
                    
                    
                    //homeRunwalWrapper.towerConstructionDetails = constDetailsMap.get(BookingMap.get(bookingId).Unit_No__r.TowerName__c);
                }
                
                SYstem.debug('inside out*****'+homeRunwalWrapper.towerConstructionDetails);
               /* 
                Set<Id> appDetailIds = new Set<Id>();
                List<Applicant_Details__c> appDetailsRecords = CustomerPortalUtility.getApplicantDetails(bookingId);
                for(Applicant_Details__c appDetailRecs : appDetailsRecords)
                {
                    appDetailIds.add(appDetailRecs.Id);
                }
                Map<Id,List<Document_Details__c>> applicantDocumentMap = new Map<Id,List<Document_Details__c>>();
                List<Document_Details__c> documentDetailsRecords = CustomerPortalUtility.getApplicantKYCDocumentDetails(appDetailIds);
                if(documentDetailsRecords != null)
                {
                System.debug('inside documentDetailsRecords*'+documentDetailsRecords);
                for(Document_Details__c appDocuments : documentDetailsRecords)
                {
                    System.debug('inside appDocuments*'+appDocuments);
                    if(!applicantDocumentMap.containsKey(appDocuments.RW_Applicant_Details__c))
                    {
                        System.debug('inside contains appDocuments*'+appDocuments);
                    applicantDocumentMap.put(appDocuments.RW_Applicant_Details__c , new List<Document_Details__c>{appDocuments} );
                    
                    }
                        else
                    {
                        List<Document_Details__c> existingdocumentdetails = applicantDocumentMap.get(appDocuments.RW_Applicant_Details__c);
                        existingdocumentdetails.add(appDocuments);
                        applicantDocumentMap.put(appDocuments.RW_Applicant_Details__c , existingdocumentdetails );
                    }
                }
                }
                System.debug('*value*'+appDetailsRecords);
                for(Applicant_Details__c appDetails : appDetailsRecords)
                {
                    String addressVal = '';
                    homeRunwalWrapper.appDetailsWrapper appdetwrap = new homeRunwalWrapper.appDetailsWrapper();
                    appdetwrap.applicantId = appDetails.Id;
                    appdetwrap.firstName = appDetails.First_Name__c;
                    appdetwrap.lastName=appDetails.Last_Name__c;
                    appdetwrap.bookingId = appDetails.Booking__c;
                    appdetwrap.opportunityId = appDetails.Opportunity__c;
                    appdetwrap.email = appDetails.Email_Address__c;
                    appdetwrap.mobile=appDetails.Mobile_Number__c;
                    appdetwrap.companyname = appDetails.Organization_Name__c;
                    appdetwrap.appNumber = appDetails.Applicant_Number__c;
                    appdetwrap.applicantType=appDetails.Type_Of_Applicant__c;
                    appdetwrap.residentialStatus = appDetails.Subtype_Of_Applicant__c;
                    appdetwrap.panCard = appDetails.PancardNo__c;
                    appdetwrap.addressproofDocument = appDetails.Address_Proof_Document__c;
                    appdetwrap.addressproofDocumentNumber = appDetails.Address_Proof_Number__c;
                    appdetwrap.typeOfOrigin= appDetails.Type_Of_Origin__c;
                    appdetwrap.origindetails = appDetails.Origin_Details__c;
                    appdetwrap.passportnodetails = appDetails.PassportNoDetails__c;
                    appdetwrap.panCardNumberofAuthoritySignatory =appDetails.Pan_Card_Number_of_Authority_Signatory__c;
                    if(appDetails.Permanent_Address_Line_1__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_1__c))
                    {
                        addressVal = appDetails.Permanent_Address_Line_1__c;
                    }
                    if(appDetails.Permanent_Address_Line_2__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_2__c))
                    {
                        addressVal = addressVal + appDetails.Permanent_Address_Line_2__c;
                    }
                    
                    if(appDetails.Permanent_Address_Line_3__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_3__c))
                    {
                        addressVal = addressVal + appDetails.Permanent_Address_Line_3__c;
                    }
                    
                    appdetwrap.address=addressVal;
                    
                    if(applicantDocumentMap.containsKey(appDetails.Id))
                    {
                        System.debug('inside contains applicantDocumentMap*'+applicantDocumentMap);
                        for(Document_Details__c documentdetailRec : applicantDocumentMap.get(appDetails.Id))
                        {
                            System.debug('inside contains true*'+documentdetailRec.Applicant_Number__c+'**'+appdetwrap.applicantType);
                            //if(documentdetailRec.Applicant_Number__c == appdetwrap.appNumber)
                            //{
                                System.debug('inside files*'+documentdetailRec.RW_Document_Type__c+'**'+documentdetailRec.RW_Document_ID__c);
                                if(documentdetailRec.RW_Document_Type__c == 'PAN Card' && documentdetailRec.RW_Document_ID__c != null)
                                 appdetwrap.panCardDocumentId =  documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Aadhar Card' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.aadharDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Driving License' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.drivingLicenseDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Electricity Bill' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.electricitybillDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Voter’s ID Card' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.voterIdDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Passport' && documentdetailRec.RW_Document_ID__c != null && documentdetailRec.RW_Residential_Status__c=='Indian National')
                                    appdetwrap.passportDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Passport' && documentdetailRec.RW_Document_ID__c != null && (documentdetailRec.RW_Residential_Status__c=='Foreign Nationals Of Indian Origin' ||documentdetailRec.RW_Residential_Status__c=='For NRI' ))
                                    appdetwrap.passportnodetails = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Self-attested copy of Pan Card of Authority Signatory' )
                                    appdetwrap.panCardNumberofAuthoritySignatoryDocumentId = documentdetailRec.RW_Document_ID__c;
                            //}
                        }
                    }
                    
                    homeRunwalWrapper.appDetailsWrapperList.add(appdetwrap);
                }
*/                    
                
               /* List<Loan__c> loanRecords = CustomerPortalUtility.getloanDetails(bookingId);
                if(loanRecords != null)
                {
                    for(Loan__c loanRecs : loanRecords)
                    {
                        homeRunwalWrapper.loanWrapper loanWrap = new homeRunwalWrapper.loanWrapper();
                        loanWrap.loanId =loanRecs.Id;
                        loanWrap.loanstatus = loanRecs.RW_Loan_Record_Status__c;
                        loanWrap.sanctionletterDocumentId = loanRecs.RW_Sanction_Letter_ID__c;
                        homeRunwalWrapper.loanWrapperList.add(loanWrap);
                    }
                }*/
                
                
                
                if(loanDetailsMap.containsKey(bookingId))
                {
                    for(Loan__c loanRecs : loanDetailsMap.get(bookingId))
                    {
                        System.debug('inside loan forloop');
                        homeRunwalWrapper.loanWrapper loanWrap = new homeRunwalWrapper.loanWrapper();
                        loanWrap.loanId =loanRecs.Id;
                        loanWrap.loanstatus = loanRecs.RW_Loan_Record_Status__c;
                        loanWrap.sanctionletterDocumentId = loanRecs.RW_Sanction_Letter_ID__c;
                            
                        loanWrap.pancard = loanRecs.RW_Pan_card_Id__c;  
                        loanWrap.aadharcard = loanRecs.RW_Aadhar_no__c; 
                        loanWrap.drvinglicense = loanRecs.RW_Driving_License__c;    
                        loanWrap.passportsize = loanRecs.RW_Passport_Photo__c;
                        homeRunwalWrapper.loanWrapperList.add(loanWrap);
                    }
                }
                
                if(tdsDetailsMap.containsKey(bookingId))
                {
                    for(TDS__c tdsRecs : tdsDetailsMap.get(bookingId))
                    {
                        System.debug('inside loan forloop');
                        homeRunwalWrapper.tdsWrapper tdsWrap = new homeRunwalWrapper.tdsWrapper();
                        tdsWrap.tdsId =tdsRecs.Id;
                        tdsWrap.tdscertificateNumber = tdsRecs.RW_TDS_Certificate_Number__c;
                        tdsWrap.tdsDocumentId = tdsRecs.RW_TDS_Document_ID__c;
                        homeRunwalWrapper.tdsWrapperList.add(tdsWrap);
                    }
                }
                
                
                if(ApplicantDetailsMap.containsKey(bookingId))
                {
                   for(Applicant_Details__c appDetails : ApplicantDetailsMap.get(bookingId))
                    {
                        String addressVal = '';
                    homeRunwalWrapper.appDetailsWrapper appdetwrap = new homeRunwalWrapper.appDetailsWrapper();
                    SYstem.debug('inside appdet*');
                    if(appDetails.Id != null)
                    appdetwrap.applicantId = appDetails.Id;
                    if(appDetails.First_Name__c != null)
                    appdetwrap.firstName = appDetails.First_Name__c;
                    if(appDetails.Middle_Name__c != null)
                    appdetwrap.middleName = appDetails.Middle_Name__c;
                    if(appDetails.Last_Name__c != null)
                    appdetwrap.lastName=appDetails.Last_Name__c;
                    if(appDetails.Booking__c != null)
                    appdetwrap.bookingId = appDetails.Booking__c;
                    if(appDetails.Opportunity__c != null)
                    appdetwrap.opportunityId = appDetails.Opportunity__c;
                    if(appDetails.Email_Address__c != null)
                    appdetwrap.email = appDetails.Email_Address__c;
                     if(appDetails.Mobile_Number__c != null)
                    appdetwrap.mobile=appDetails.Mobile_Number__c;
                    if(appDetails.Organization_Name__c != null)
                    appdetwrap.companyname = appDetails.Organization_Name__c;
                    if(appDetails.Applicant_Number__c != null)
                    appdetwrap.appNumber = appDetails.Applicant_Number__c;
                    if(appDetails.Type_Of_Applicant__c != null)
                    appdetwrap.applicantType=appDetails.Type_Of_Applicant__c;
                    if(appDetails.Subtype_Of_Applicant__c != null)
                    appdetwrap.residentialStatus = appDetails.Subtype_Of_Applicant__c;
                    if(appDetails.PancardNo__c != null)
                    appdetwrap.panCard = appDetails.PancardNo__c;
                    if(appDetails.Address_Proof_Document__c != null)
                    appdetwrap.addressproofDocument = appDetails.Address_Proof_Document__c;
                    if(appDetails.Address_Proof_Number__c != null)
                    appdetwrap.addressproofDocumentNumber = appDetails.Address_Proof_Number__c;
                     if(appDetails.Type_Of_Origin__c != null)
                    appdetwrap.typeOfOrigin= appDetails.Type_Of_Origin__c;
                    if(appDetails.Origin_Details__c != null)
                    appdetwrap.origindetails = appDetails.Origin_Details__c;
                    if(appDetails.PassportNoDetails__c != null)
                    appdetwrap.passportnodetails = appDetails.PassportNoDetails__c;
                    if(appDetails.Pan_Card_Number_of_Authority_Signatory__c != null)
                    appdetwrap.panCardNumberofAuthoritySignatory =appDetails.Pan_Card_Number_of_Authority_Signatory__c;
                    if(appDetails.Permanent_Address_Line_1__c != null)
                    appdetwrap.permanentaddr1 = appDetails.Permanent_Address_Line_1__c ;
                    if(appDetails.Permanent_Address_Line_2__c != null)
                    appdetwrap.permanentaddr2 = appDetails.Permanent_Address_Line_2__c ;
                    if(appDetails.Permanent_Address_Line_3__c != null)
                    appdetwrap.permanentaddr3 = appDetails.Permanent_Address_Line_3__c ;
                    if(appDetails.Country__c != null)
                    appdetwrap.country =appDetails.Country__c;
                    if(appDetails.State__c != null)
                    appdetwrap.state =appDetails.State__c;
                    if(appDetails.City__c != null)
                    appdetwrap.city =appDetails.City__c;
                    if(appDetails.Pincode__c != null)
                    appdetwrap.pin = String.valueOf(appDetails.Pincode__c);
                    if(appDetails.DOB__c != null)
                    appdetwrap.dateOfBirth =appDetails.DOB__c;
                    if(appDetails.Booking__c != null && appDetails.Booking__r.Name != null)
                     appdetwrap.bookingName =appDetails.Booking__r.Name;
                        if(appDetails.Booking__r.Project__c != null)   
                     appdetwrap.ProjectId =appDetails.Booking__r.Project__c;
                     if(appDetails.Booking__r.Unit_No__r.RW_Param4__c != null)   
                     appdetwrap.unitNumber =appDetails.Booking__r.Unit_No__r.RW_Param4__c;
                     if(appDetails.Booking__r.RW_Registration_Status__c != null)   
                     appdetwrap.registrationStatus =appDetails.Booking__r.RW_Registration_Status__c;
                     SYstem.debug('inside appdet end*'+appDetails+'*'+appdetwrap.dateOfBirth);
                    if(appDetails.Permanent_Address_Line_1__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_1__c))
                    {
                        addressVal = appDetails.Permanent_Address_Line_1__c;
                    }
                    if(appDetails.Permanent_Address_Line_2__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_2__c))
                    {
                        addressVal = addressVal + appDetails.Permanent_Address_Line_2__c;
                    }
                    
                    if(appDetails.Permanent_Address_Line_3__c != null && !String.isEmpty(appDetails.Permanent_Address_Line_3__c))
                    {
                        addressVal = addressVal + appDetails.Permanent_Address_Line_3__c;
                    }
                    
                    appdetwrap.address=addressVal;
                        system.debug('applicant Id**'+appDetails.Id);
                        system.debug('doc Map**'+DocumentDetailsMap);
                     if(DocumentDetailsMap.containsKey(appDetails.Id))
                    {
                        System.debug('inside contains applicantDocumentMap*'+DocumentDetailsMap);
                        for(Document_Details__c documentdetailRec : DocumentDetailsMap.get(appDetails.Id))
                        {
                            System.debug('inside contains true*'+documentdetailRec.Applicant_Number__c+'**'+appdetwrap.applicantType);
                            //if(documentdetailRec.Applicant_Number__c == appdetwrap.appNumber)
                            //{
                                System.debug('inside files*'+documentdetailRec.RW_Document_Type__c+'**'+documentdetailRec.RW_Document_ID__c);
                                if(documentdetailRec.RW_Document_Type__c == 'PAN Card' && documentdetailRec.RW_Document_ID__c != null)
                                 appdetwrap.panCardDocumentId =  documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Aadhar Card' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.aadharDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Driving License' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.drivingLicenseDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Electricity Bill' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.electricitybillDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Voter’s ID Card' && documentdetailRec.RW_Document_ID__c != null)
                                    appdetwrap.voterIdDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Passport' && documentdetailRec.RW_Document_ID__c != null && documentdetailRec.RW_Residential_Status__c=='Indian National')
                                    appdetwrap.passportDocumentId = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Passport' && documentdetailRec.RW_Document_ID__c != null && (documentdetailRec.RW_Residential_Status__c=='Foreign Nationals Of Indian Origin' ||documentdetailRec.RW_Residential_Status__c=='For NRI' ))
                                    appdetwrap.passportnodetails = documentdetailRec.RW_Document_ID__c;
                                else if(documentdetailRec.RW_Document_Type__c == 'Self-attested copy of Pan Card of Authority Signatory' )
                                    appdetwrap.panCardNumberofAuthoritySignatoryDocumentId = documentdetailRec.RW_Document_ID__c;
                            //}
                        }
                    }
                    
                    homeRunwalWrapper.appDetailsWrapperList.add(appdetwrap);   
                        
                        
                    } 
                }
                
                
                
                if(ncfDetailsMap.containsKey(bookingId))
                {
                    system.debug('inside ncfDetailsMap* ');
                    homeRunwalWrapper.ncfdata = ncfDetailsMap.get(bookingId);
                }
                
                else
                {
                    system.debug('inside else ncfDetailsMap* ');
                    Name_Confirmation_Form__c newNCF = new Name_Confirmation_Form__c();
                    system.debug('*appdet*'+ApplicantDetailsMap);
                    system.debug('**'+bookingId);
                    if(ApplicantDetailsMap.containsKey(bookingId))
                    {
                    for(Applicant_Details__c appDetails : ApplicantDetailsMap.get(bookingId))
                    {
                         system.debug('*booking for*'+bookingId);
                        if(appDetails.Applicant_Number__c == 'Primary Applicant')
                        {
                        String addressVal = '';
                    
                    SYstem.debug('inside appdet*');
                    if(appDetails.First_Name__c != null)
                    newNCF.RW_Primary_First_Name__c = appDetails.First_Name__c;
                    if(appDetails.Middle_Name__c != null)
                    newNCF.RW_Primary_Middle_Name__c = appDetails.Middle_Name__c;
                    if(appDetails.Last_Name__c != null)
                    newNCF.RW_Primary_Last_Name__c = appDetails.Last_Name__c;
                    if(appDetails.Booking__c != null)
                    newNCF.Booking__c = appDetails.Booking__c;
                    /*if(appDetails.Opportunity__c != null)
                    newNCF.O = appDetails.Opportunity__c;*/
                    if(appDetails.Email_Address__c != null)
                    newNCF.RW_Primary_Email__c = appDetails.Email_Address__c;
                            
                            
                     if(appDetails.Mobile_Number__c != null)
                    newNCF.RW_Primary_Mobile_Number__c =appDetails.Mobile_Number__c;
                    
                    //if(appDetails.Applicant_Number__c != null)
                    //appdetwrap.appNumber = appDetails.Applicant_Number__c;
                    if(appDetails.Type_Of_Applicant__c != null)
                    newNCF.Type_Of_Applicant__c=appDetails.Type_Of_Applicant__c;
                    if(appDetails.Subtype_Of_Applicant__c != null)
                    newNCF.Subtype_Of_Applicant__c = appDetails.Subtype_Of_Applicant__c;
                    if(appDetails.PancardNo__c != null)
                    newNCF.PancardNo__c = appDetails.PancardNo__c;
                    if(appDetails.Address_Proof_Document__c != null)
                    newNCF.Address_Proof_Document__c = appDetails.Address_Proof_Document__c;
                    if(appDetails.Address_Proof_Number__c != null)
                    newNCF.Address_Proof_Number__c = appDetails.Address_Proof_Number__c;
                     if(appDetails.Type_Of_Origin__c != null)
                    newNCF.Type_Of_Origin__c= appDetails.Type_Of_Origin__c;
                    if(appDetails.Origin_Details__c != null)
                    newNCF.Origin_Details__c = appDetails.Origin_Details__c;
                    if(appDetails.PassportNoDetails__c != null)
                    newNCF.PassportNoDetails__c = appDetails.PassportNoDetails__c;
                    if(appDetails.Pan_Card_Number_of_Authority_Signatory__c != null)
                    newNCF.Pan_Card_Number_of_Authority_Signatory__c =appDetails.Pan_Card_Number_of_Authority_Signatory__c;
                    if(appDetails.Permanent_Address_Line_1__c != null)
                    newNCF.RW_Primary_Permanent_Address_Line_1__c = appDetails.Permanent_Address_Line_1__c ;
                    if(appDetails.Permanent_Address_Line_2__c != null)
                    newNCF.RW_Primary_Permanent_Address_Line_2__c = appDetails.Permanent_Address_Line_2__c ;
                    if(appDetails.Permanent_Address_Line_3__c != null)
                    newNCF.RW_Primary_Permanent_Address_Line_3__c = appDetails.Permanent_Address_Line_3__c ;
                    if(appDetails.Country__c != null)
                    newNCF.RW_Primary_Country__c =appDetails.Country__c;
                    if(appDetails.State__c != null)
                    newNCF.RW_Primary_State__c =appDetails.State__c;
                    if(appDetails.City__c != null)
                    newNCF.RW_Primary_City__c =appDetails.City__c;
                    if(appDetails.Pincode__c != null)
                    newNCF.RW_Primary_Pincode__c = appDetails.Pincode__c;
                    if(appDetails.DOB__c != null)
                    newNCF.RW_Primary_DOB__c =appDetails.DOB__c;
                       
                            newNCF.RW_Allow_Customer_to_Update__c=true;
                            homeRunwalWrapper.ncfdata = newNCF;
                            system.debug('*booking for end*'+bookingId);
                        }
                }
                }
                }
                if(DemandMap.containsKey(bookingId))
                {
                    System.debug('**inside demand if*');
                    for(RW_Demand__c demandrec : DemandMap.get(bookingId))
                    {
                       
                        System.debug('**inside demand for*');
                        homeRunwalWrapper.DemandWrapper demandwrap = new homeRunwalWrapper.DemandWrapper();
                        
                        demandwrap.demandId = demandrec.id;
                        demandwrap.demandName = demandrec.Name; 
                        if(demandrec.Due_Date__c !=null)
                        demandwrap.demandDueDate = demandrec.Due_Date__c.format();
                        demandwrap.BillingDocumentNumber = demandrec.RW_Billing_Document_Number__c;
                        demandwrap.CustomerNumber = demandrec.RW_Customer_Number__c;
                        if(demandrec.RW_Demand_Amount__c !=null)
                        demandwrap.DemandAmount = String.valueOf(demandrec.RW_Demand_Amount__c);
                        if(demandrec.Demand_Date__c !=null)
                        {
                        Date myDate = date.newinstance(demandrec.Demand_Date__c.year(), demandrec.Demand_Date__c.month(), demandrec.Demand_Date__c.day()); 
                        demandwrap.DemandDate = myDate.format();  
                        Date checkdate = Date.newInstance(2018, 8, 1);
                        if(myDate < checkdate)
                        {
                          demandwrap.disableDemandDownload =true;  
                        }
                            else
                            {
                                demandwrap.disableDemandDownload =false; 
                            }
                        }                       
                        demandwrap.demandStatus = demandrec.RW_Demand_Status__c;
                        demandwrap.ODNNumber = demandrec.RW_ODN_Number__c;
                        if(demandrec.Remaining_Amount__c !=null)
                        demandwrap.TotalDemandAmount = String.valueOf(demandrec.Remaining_Amount__c);
                        if(demandrec.RW_Total_GST_Amount__c !=null)
                        demandwrap.TotalGSTAmount = String.valueOf(demandrec.RW_Total_GST_Amount__c);
                        if(demandrec.Remaining_Amount__c !=null)
                        demandwrap.remainingAmount = String.valueOf(demandrec.Remaining_Amount__c);
                        if(demandrec.Total_Demand_Paid__c !=null)
                        demandwrap.recieved = String.valueOf(demandrec.Total_Demand_Paid__c);
                        if(demandrec.RW_Total_Demand_Amount__c !=null)
                        demandwrap.TotalDemandAmountCL = String.valueOf(demandrec.RW_Total_Demand_Amount__c);
                        
                        system.debug('demands in wrapper --> '+ demandwrap);
                       
                        demandwrap.demandItems  = new List<RW_Demand_Item__c>();
                        homeRunwalWrapper.demandWrapperList.add(demandwrap); 
                        System.debug('**inside demand for end*');
                        
                        for(RW_Demand_Item__c demandDetails: demandrec.Demand_Items__r)
                        {
                           demandwrap.demandItems.add(demandDetails);   
                          
                        }
                    }
                    
                }
                
                
                if(receiptsMap.containsKey(bookingId))
                {
                    for(RW_Payment_Details__c receiptRecs : receiptsMap.get(bookingId))
                    {
                        System.debug('inside forloop of receipt');
                        homeRunwalWrapper.receiptWrapper receiptWrap = new homeRunwalWrapper.receiptWrapper();
                       
                        receiptWrap.ReceiptId = receiptRecs.Id;
                        receiptWrap.AccountDocumentNumber = receiptRecs.RW_Accounting_Document_Number__c;
                        receiptWrap.BankReferenceNumber = receiptRecs.RW_Bank_Reference_Number__c;
                        receiptWrap.BranchName = receiptRecs.RW_Branch_Name__c;
                        receiptWrap.ClearingDocumentNumber = receiptRecs.RW_Clearing_Document_Number__c;
                        receiptWrap.CompanyCode = receiptRecs.RW_Company_Code__c;
                        receiptWrap.CustomerId = receiptRecs.RW_Customer_ID__c;
                        if(receiptRecs.Total_Amount_Paid__c !=null)
                        receiptWrap.ReceiptAmount = string.valueOf(receiptRecs.Total_Amount_Paid__c);
                        if(receiptRecs.RW_Payment_Date__c !=null)
                        {
                        receiptWrap.ReceiptDate = receiptRecs.RW_Payment_Date__c.format();
                        Date checkdate = Date.newInstance(2018, 8, 1);
                        if(receiptRecs.RW_Payment_Date__c < checkdate)
                        {
                          receiptWrap.disableReceiptDownload =true;  
                        }
                            else
                            {
                                receiptWrap.disableReceiptDownload =false; 
                            }
                        } 
                        
                        if(receiptRecs.Status__c !=null)
                        receiptWrap.ReceiptStatus = receiptRecs.Status__c;
                        if(receiptRecs.RW_Document_Type__c !=null)
                        receiptWrap.DocumentType = receiptRecs.RW_Document_Type__c;
                        
                        homeRunwalWrapper.receiptWrapperList.add(receiptWrap);
                        
                        system.debug('Wrapper Receipt List' + homeRunwalWrapper.receiptWrapperList);
                    }
                }
                
                
               /* if(InspectionMap.containsKey(bookingId))
                {
                    for(InspectionAndPossession__c inspectionRecs : InspectionMap.get(bookingId))
                    {
                        System.debug('inside forloop of inspection');
                        homeRunwalWrapper.inspectionWrapper inspectionWrap = new homeRunwalWrapper.inspectionWrapper();
                       
                        inspectionWrap.inspectionId = string.valueOf(inspectionRecs.Id);
                        inspectionWrap.inspectionStatus = inspectionRecs.RW_Inspection_Status__c;
                        inspectionWrap.expectedPossesionDate = inspectionRecs.RW_Expected_Possession_dt__c;
                        
                        
                        homeRunwalWrapper.inspectionWrapperList.add(inspectionWrap);
                        
                        system.debug('Wrapper inspection List' + homeRunwalWrapper.receiptWrapperList);
                    }
                }*/
                
                
                
                  
                SYstem.debug('WrapperData1'+homeRunwalWrapper);
                SYstem.debug('Current user'+homeRunwalWrapper.currentUserId);
                homeRunwalWrapList.add(homeRunwalWrapper);
            }
            
           /* if(bookingRecords.size() >0)
            {
                homeRunwalWrap.Bookings = new List<Booking__c>(); 
                homeRunwalWrap.Bookings.addAll(bookingRecords);
            }
            return homeRunwalWrap;*/
            SYstem.debug('WrapperData'+homeRunwalWrapList);
            return homeRunwalWrapList;
            
        }
        
        catch(Exception e)
        {
            //-----------------changes made by CoServe-------------
            //throw new AurahandledException('An Error Occured. Please contact Administartor.');
            throw new AurahandledException(e.getMessage()); 
            //---------------------------------------------------
        }
    }
    
    @AuraEnabled
    public static void insertDocumentData(Map<String,String> DocDetails)
    {
        Document_Details__c Details = new Document_Details__c();
        if(!'--- None ---'.equals(DocDetails.get('applicantType')))
        Details.RW_Type_Of_Applicant__c = DocDetails.get('applicantType');
        if(!'--- None ---'.equals(DocDetails.get('residentialStatus')))
        Details.RW_Residential_Status__c = DocDetails.get('residentialStatus');
        if(DocDetails.get('oppRecId') != null)
        Details.Opportunity__c = DocDetails.get('oppRecId');
        Details.RW_Document_Type__c=DocDetails.get('documentType');
        Details.RW_Document_ID__c = DocDetails.get('documentId');
        Details.Booking__c = DocDetails.get('bookingId');
        Details.Applicant_Number__c = DocDetails.get('ApplicantNumber');
        if(DocDetails.get('applicantId') != null)
        Details.RW_Applicant_Details__c = DocDetails.get('applicantId');
        Details.RW_Document_Status__c = 'Active';
        insert Details;
        
         if(DocDetails.get('uploadType') == 'KYC')
        {
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = DocDetails.get('documentId');
            cdl.LinkedEntityId = DocDetails.get('applicantId');
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
             List<String> toAddress = new List<String>();
            List<Booking__c> bookingRec =[Select id,Name, Unit_No__r.Relationship_Manager__r.RM_Email__c from Booking__c where id =:DocDetails.get('bookingId')];
        if(bookingRec != null && bookingRec.size() >0 && bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Email__c != null)
        {
            toAddress.add(bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Email__c);
        }
        
        if(toAddress.size() >0)
        {
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='KYC_Notification_Template'];
            String htmlBody = template.HtmlValue; 
            system.debug('');
            htmlBody = htmlBody.replace('{!bookingNumber}', bookingRec[0].Name);
            if(DocDetails.get('ApplicantNumber') != null)
            htmlBody=htmlBody.replace('{!applicantNumber}', DocDetails.get('ApplicantNumber'));
            htmlBody = htmlBody.replace('{!kyclink}', Url.getOrgDomainUrl().toExternalForm()+'/'+DocDetails.get('documentId'));

        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!bookingNumber}', bookingRec[0].Name);
            if(DocDetails.get('ApplicantNumber') != null)
            plainTextBody=plainTextBody.replace('{!applicantNumber}', DocDetails.get('ApplicantNumber'));
            plainTextBody = plainTextBody.replace('{!kyclink}', Url.getOrgDomainUrl().toExternalForm()+'/'+DocDetails.get('documentId'));

        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
        }
        }
    }
    
            @AuraEnabled    
    public static void insertDocumentLoanData(Map<String,String> DocDetails)    
    {   
            
        system.debug('LOan data ----->'+DocDetails);    
        Document_Details__c DetailsLoan = new Document_Details__c();    
        system.debug('LOan data1 ----->'+DetailsLoan+'**'+DocDetails.get('oppRecId'));  
        DetailsLoan.Opportunity__c = DocDetails.get('oppRecId');    
        system.debug('LOan data2 ----->'+DetailsLoan);  
        DetailsLoan.RW_Document_Type__c=DocDetails.get('documentType'); 
        system.debug('LOan data3 ----->'+DetailsLoan);  
        DetailsLoan.RW_Document_ID__c = DocDetails.get('documentId');   
        system.debug('LOan data4 ----->'+DetailsLoan);  
        DetailsLoan.Booking__c = DocDetails.get('bookingId');   
        system.debug('LOan data5 ----->'+DetailsLoan);  
        DetailsLoan.RW_Loan_Name__c = 'For Home Loan';  
        system.debug('LOan data --before insert--->' + DetailsLoan);    
        insert DetailsLoan; 
        system.debug('LOan data --after insert--->' + DetailsLoan); 
    }
    
    @AuraEnabled
    public static String getIntertestLedgerPDF(String customerNumber,String companycode)
    {
        return PDFController.getinterestLedgerPdf(customerNumber,companycode);
    }
    
    @AuraEnabled
    public static String getCustomerLedgerPdf(String customerNumber,String companycode)
    {
        return PDFController.getCustomerLedgerPdf(customerNumber,companycode);
    }
    
    @AuraEnabled
    public static String getAgreementPDF(String salesorderNumber)
    {
        return PDFController.getagreementPdf(salesorderNumber);
    }
    
    
    @AuraEnabled
    public static void updateLoanRecord(Map<String,String> DocDetails)
    {
        Loan__c loanRec = new Loan__c(id=DocDetails.get('loanId'));
        loanRec.RW_Sanction_Letter_ID__c = DocDetails.get('documentId');
        update loanRec;
    }
    
    @AuraEnabled
    public static void createTDSRecord(Map<String,String> DocDetails)
    {
        TDS__c tdsRec = new TDS__c();
        tdsRec.RW_TDS_Document_ID__c = DocDetails.get('tdsdocumentId');
        tdsRec.RW_TDS_Certificate_Number__c = DocDetails.get('tdscertificateNumber');
        tdsRec.RW_Amount__c = Decimal.valueOf(DocDetails.get('tdsamount'));
        tdsRec.Opportunity__c= DocDetails.get('oppId');
        tdsRec.Booking__c = DocDetails.get('bookingId');
        insert tdsRec;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = DocDetails.get('tdsdocumentId');
        cdl.LinkedEntityId = tdsRec.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    
    //public static void createNCFRecord(Name_Confirmation_Form__c NCFDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFDetails,Map<String,String> NCFOtherDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFOtherApplicantDetails,List<String> RemovedAppIds,String BookingRecordId)
    //{
    @AuraEnabled
    public static void createNCFRecord(Name_Confirmation_Form__c NCFDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFOtherApplicantDetails,List<String> RemovedAppIds,String BookingRecordId)
    {
        System.debug('*inside*');
        List<Name_Confirmation_Form__c> ncfObj = new List<Name_Confirmation_Form__c>();
        List<Applicant_Details__c> appDetailObjList = new List<Applicant_Details__c>();
        //system.debug('*NCF*'+NCFDetails+'**');
       /* for(String BookingId : NCFDetails.keyset())
        {
        Name_Confirmation_Form__c ncf = new Name_Confirmation_Form__c();
        ncf.RW_Primary_First_Name__c = NCFDetails.get(BookingId).firstName;
        ncf.RW_Primary_Last_Name__c = NCFDetails.get(BookingId).lastName;
        ncf.RW_Primary_Middle_Name__c = NCFDetails.get(BookingId).middleName;
        ncf.RW_Primary_Email__c = NCFDetails.get(BookingId).email;
        ncf.RW_Primary_Permanent_Address_Line_1__c = NCFDetails.get(BookingId).permanentaddr1;
        ncf.RW_Primary_Permanent_Address_Line_2__c = NCFDetails.get(BookingId).permanentaddr2;
        ncf.RW_Primary_Permanent_Address_Line_3__c = NCFDetails.get(BookingId).permanentaddr3;
        ncf.RW_Primary_DOB__c = NCFDetails.get(BookingId).dateOfBirth;
        //ncf.RW_Primary_PAN_Number__c = NCFDetails.get(BookingId).panCard;
        ncf.RW_Primary_Aadhar_Number__c = NCFDetails.get(BookingId).addressproofDocumentNumber;
        ncf.RW_Primary_Country__c = NCFDetails.get(BookingId).country;
        ncf.RW_Primary_State__c = NCFDetails.get(BookingId).state;
        ncf.RW_Primary_City__c = NCFDetails.get(BookingId).city;
        ncf.RW_Primary_Pincode__c = Decimal.valueOf(NCFDetails.get(BookingId).pin);
        ncf.RW_Primary_Mobile_Number__c = NCFDetails.get(BookingId).mobile;
        ncf.RW_Nominee_PAN_Number__c =  NCFOtherDetails.get('nomineepan');
        //ncf.RW_Nominee_First_Name__c =  NCFOtherDetails.get('nomineename');
        ncf.RW_POA_Name__c = NCFOtherDetails.get('poaname');
        ncf.RW_POA_PAN_Number__c  =  NCFOtherDetails.get('poapan');
        ncf.RW_POA_Phone_Number__c =  NCFOtherDetails.get('poamobile');
        ncf.RW_POA_Email__c = NCFOtherDetails.get('poaemail');
            
        ncf.Booking__c = BookingId;
        ncfObj.add(ncf);  
        }*/
        
        NCFDetails.RW_Active_NCF__c = true;
        NCFDetails.RW_Allow_Customer_to_Update__c = false;
        upsert NCFDetails;
        List<String> toAddress = new List<String>();
         List<Booking__c> bookingRec =[Select id,Name, Unit_No__r.Relationship_Manager__r.RM_Email__c from Booking__c where id =:NCFDetails.Booking__c];
        if(bookingRec != null && bookingRec.size() >0 && bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Email__c != null)
        {
            toAddress.add(bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Email__c);
        }
        
        if(toAddress.size() >0)
        {
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='NCF_Template'];
            String htmlBody = template.HtmlValue; 
            system.debug('');
            htmlBody = htmlBody.replace('{!bookingNumber}', bookingRec[0].Name);
            htmlBody = htmlBody.replace('{!ncflink}', Url.getOrgDomainUrl().toExternalForm()+'/'+NCFDetails.Id);

        
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!bookingNumber}', bookingRec[0].Name);
            plainTextBody = plainTextBody.replace('{!ncflink}', Url.getOrgDomainUrl().toExternalForm()+'/'+NCFDetails.Id);

        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
        }
        
        Set<String> newApplicantIds = new Set<String>(); 
        for(String appNumber : NCFOtherApplicantDetails.keyset())
        {
            Applicant_Details__c appdet = new Applicant_Details__c();
            if(NCFOtherApplicantDetails.get(appNumber).applicantId != null)
            {
                appdet.Id = NCFOtherApplicantDetails.get(appNumber).applicantId;
            }
            
            else
            {
                system.debug('*inside new applicant*');
                newApplicantIds.add(appNumber);
            }
            
            if (NCFOtherApplicantDetails.get(appNumber).firstName != '' && NCFOtherApplicantDetails.get(appNumber).firstName != null && NCFOtherApplicantDetails.get(appNumber).lastName != '' && NCFOtherApplicantDetails.get(appNumber).lastName != null) {
                    if (NCFOtherApplicantDetails.get(appNumber).middleName != null) {
                        appdet.Name = NCFOtherApplicantDetails.get(appNumber).firstName + ' ' + NCFOtherApplicantDetails.get(appNumber).middleName + ' ' + NCFOtherApplicantDetails.get(appNumber).lastName;
                    } else {
                        appdet.Name = NCFOtherApplicantDetails.get(appNumber).firstName + ' ' + NCFOtherApplicantDetails.get(appNumber).lastName;
                    }
            }
            appdet.First_Name__c = NCFOtherApplicantDetails.get(appNumber).firstName;
            appdet.Last_Name__c = NCFOtherApplicantDetails.get(appNumber).lastName;
            appdet.Middle_Name__c = NCFOtherApplicantDetails.get(appNumber).middleName;
            appdet.Permanent_Address_Line_1__c = NCFOtherApplicantDetails.get(appNumber).permanentaddr1;
            if(NCFOtherApplicantDetails.get(appNumber).permanentaddr2 != null)
            appdet.Permanent_Address_Line_2__c = NCFOtherApplicantDetails.get(appNumber).permanentaddr2;
            if(NCFOtherApplicantDetails.get(appNumber).permanentaddr3 != null)
            appdet.Permanent_Address_Line_3__c = NCFOtherApplicantDetails.get(appNumber).permanentaddr3;
            appdet.DOB__c = NCFOtherApplicantDetails.get(appNumber).dateOfBirth;
            appdet.Email_Address__c = NCFOtherApplicantDetails.get(appNumber).email;
            appdet.Mobile_Number__c = NCFOtherApplicantDetails.get(appNumber).mobile;
            appdet.Country__c = NCFOtherApplicantDetails.get(appNumber).country;
            appdet.State__c = NCFOtherApplicantDetails.get(appNumber).state;
            appdet.City__c = NCFOtherApplicantDetails.get(appNumber).city;
            appdet.Pincode__c = Decimal.valueOf(NCFOtherApplicantDetails.get(appNumber).pin);
            appdet.PancardNo__c =NCFOtherApplicantDetails.get(appNumber).panCard;
            if(NCFOtherApplicantDetails.get(appNumber).addressproofDocument !=null)
            appdet.Address_Proof_Document__c = NCFOtherApplicantDetails.get(appNumber).addressproofDocument;
            if(NCFOtherApplicantDetails.get(appNumber).addressproofDocumentNumber != null)
            appdet.Address_Proof_Number__c = NCFOtherApplicantDetails.get(appNumber).addressproofDocumentNumber;
            if(NCFOtherApplicantDetails.get(appNumber).typeOfOrigin != null)
            appdet.Type_Of_Origin__c = NCFOtherApplicantDetails.get(appNumber).typeOfOrigin;
            if(NCFOtherApplicantDetails.get(appNumber).origindetails != null)
            appdet.Type_Of_Origin__c = NCFOtherApplicantDetails.get(appNumber).origindetails;
            if(NCFOtherApplicantDetails.get(appNumber).panCardNumberofAuthoritySignatory != null)
            appdet.Pan_Card_Number_of_Authority_Signatory__c =  NCFOtherApplicantDetails.get(appNumber).panCardNumberofAuthoritySignatory;
            if(NCFOtherApplicantDetails.get(appNumber).passportnodetails != null)
            appdet.PassportNoDetails__c = NCFOtherApplicantDetails.get(appNumber).passportnodetails;
            if(NCFOtherApplicantDetails.get(appNumber).applicantType != null)
            appdet.Type_Of_Applicant__c = NCFOtherApplicantDetails.get(appNumber).applicantType;
            if(NCFOtherApplicantDetails.get(appNumber).residentialStatus != null)
            appdet.Subtype_Of_Applicant__c = NCFOtherApplicantDetails.get(appNumber).residentialStatus;
            appdet.Applicant_Number__c =appNumber;
            appdet.Booking__c =NCFOtherApplicantDetails.get(appNumber).bookingId;
            appdet.Opportunity__c = NCFOtherApplicantDetails.get(appNumber).opportunityId;
            appDetailObjList.add(appdet);
            system.debug('*added to list*');
        }
        
       List<Applicant_Details__c> appDetailsRec =  [Select Id,Applicant_Status__c from Applicant_Details__c Where Id IN :RemovedAppIds];
       for(Applicant_Details__c appDetails : appDetailsRec )
       {
           appDetails.Applicant_Status__c= 'Inactive';
       }
        
        List<Document_Details__c> existingdocuments = [Select id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c,RW_Type_Of_Applicant__c from Document_Details__c where RW_Applicant_Details__c =:RemovedAppIds];
        for(Document_Details__c existingdocs : existingdocuments )
       {
           existingdocs.RW_Document_Status__c= 'Inactive';
       }
        
        if(appDetailsRec.size() >0)
        Update appDetailsRec;
        
        if(existingdocuments.size() >0)
        Update existingdocuments;
           
           
        if(appDetailObjList.size() >0)
        {
        system.debug('*before upsert appDetailObjList*');
        upsert appDetailObjList;
        system.debug('*after upsert*');
        }
        
        Map<String,Applicant_Details__c> newlyaddedapplicantDetails = new Map<String,Applicant_Details__c>();
        if(appDetailObjList.size() >0)
        {
            system.debug('**inside if^****'+appDetailObjList);
        for(Applicant_Details__c appdet : appDetailObjList)
        {
            system.debug('**inside for****');
            if(newApplicantIds.contains(appdet.Applicant_Number__c))
            {
                system.debug('**inside for 1****'+appdet.Applicant_Number__c);
                newlyaddedapplicantDetails.put(appdet.Applicant_Number__c,appdet);
            }
        }
        }
        
        List<ContentDocumentLink> insertList = new List<ContentDocumentLink>();
        List<Document_Details__c> updateDcs = new List<Document_Details__c>();
        List<Document_Details__c> documents = [Select id,RW_Applicant_Details__c,Applicant_Number__c,Booking__c,RW_Document_ID__c,RW_Document_Type__c,RW_Type_Of_Applicant__c from Document_Details__c where Booking__c =:BookingRecordId and RW_Document_Status__c != 'Inactive'];
        if(newlyaddedapplicantDetails != null && newlyaddedapplicantDetails.size() >0)
        {
             system.debug('**inside if doc****'+documents.size());
            system.debug('*newlyaddedapplicantDetails*'+newlyaddedapplicantDetails);
        for(Document_Details__c dc : documents){
            if(dc.RW_Applicant_Details__c == null && newlyaddedapplicantDetails.containsKey(dc.Applicant_Number__c)){
                string appId = newlyaddedapplicantDetails.get(dc.Applicant_Number__c).Id;
                system.debug(appId);
                dc.RW_Applicant_Details__c = appId;
                ContentDocumentLink  cdl = new ContentDocumentLink ();
                cdl.linkedEntityId = appId;
                cdl.ContentDocumentId = dc.RW_Document_ID__c;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                updateDcs.add(dc);
                insertList.add(cdl);}
        }
        }
        if(insertList.size() > 0){
            insert insertList;}
        
         if(updateDcs.size() > 0){
            update updateDcs;}
        
        
        if(ncfObj.size() >0)
        insert ncfObj;
        
    }
    
     @AuraEnabled  
    public static List<KYCWrapper> getKYCFiles(String bookingId,String applicantNumber){ 
        system.debug('**id'+bookingId);
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
        System.debug('*size*'+cdl.size());
        for(ContentDocumentLink cdLink:cdl)
        {  
            System.debug('****'+cdLink);
            documentIds.add(cdLink.ContentDocumentId);  
        }      
        //List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];  
        List<Contentversion> contVer = [Select Id,ContentDocumentId,ContentDocument.Title,ContentDocument.FileType,IsLatest from ContentVersion where ContentDocumentId in :documentIds and IsLatest = true];
        for(Contentversion contVersion :contVer)
        {
            System.debug('**inside contVersion**'+contVersion);
            ContentData.put(contVersion.Id, contVersion);
        }
        
        
        List<Document_Details__c> docDetails = [Select Id,RW_Type_Of_Applicant__c,RW_Document_Type__c,RW_Residential_Status__c,Opportunity__c,RW_Document_ID__c from Document_Details__c where RW_Document_ID__c in :documentIds and Booking__c =:bookingId and Applicant_Number__c =:applicantNumber];
        for(Document_Details__c details :docDetails)
        {
            System.debug('**inside DocData**'+details);
            DocData.put(details.Id, details);
        }
        
        /* List<ContentDocument> contDoc = [SELECT Id,Title,FileType FROM ContentDocument WHERE id IN: documentIds];
for(ContentDocument contDocument :contDoc)
{
ContentDocData.put(contDocument.Id,contDoc);
} */ 
        
        for(Id contVersionId : ContentData.keySet())
        {
            for(Id docDataId : DocData.keySet())
            {
                if(DocData.get(docDataId).RW_Document_ID__c == ContentData.get(contVersionId).ContentDocumentId)
                {
                    System.debug('**inside KYCWrapper**');
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
    public static List<String> getPicklists(String ObjectName, String FieldName)
    {
        //return Utility.getPicklistValues('Applicant_Details__c', 'Country__c');
        return Utility.getPicklistValues(ObjectName, FieldName);
        
    }
    
    @AuraEnabled
    public static String getEOIPdf(String encryptedEoiRecordId)
    {
            PageReference pdf = Page.CustomerPortalEOIForm;
            pdf.getParameters().put('eoiId',encryptedEoiRecordId);
            if(!Test.isRunningTest())
            {
             Blob body= pdf.getContent();
             return EncodingUtil.base64Encode(body);
            }
            else
            {
               return '';
            }
    }
    
    @AuraEnabled
    public static String getBookingPdf(String encryptedBookingRecordId)
    {
            PageReference pdf = Page.CustomerPortalBookingForm;
            pdf.getParameters().put('id',encryptedBookingRecordId);
            if(!Test.isRunningTest())
            {
             Blob body= pdf.getContent();
             return EncodingUtil.base64Encode(body);
            }
            else
            {
               return '';
            }
            
    }
    
    
    @AuraEnabled  
    public static void deleteFiles(string sdocumentId){ 
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:sdocumentId];       
    }  
    
    @AuraEnabled  
    public static String insertCase(Case newCase,Map<String,String> Details){ 
        try{
        List<Booking__c> bookingRec =[Select Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.User__c, RW_Key_handover_date__c, Project__r.FM_Team__c, Opportunity__c from Booking__c Where Id =:Details.get('bookingId')];
        Id customerRecordId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        List<User> u = [Select Id,ContactId,AccountId, IsActive, IsPortalEnabled, Email from User  where Id = :UserInfo.getUserId()];
        
        newCase.RecordTypeId = customerRecordId;
        //newCase.RW_Case_Type__c='Complaint';
        newCase.Origin ='Portal';
        newCase.Subject ='Service Request - '+Details.get('bookingName');
        if(Details.get('projectId') != null)
        newCase.RW_Project__c =Details.get('projectId');
        if(Details.get('unitnumber') != null)
        newCase.RW_Flat_No__c =Details.get('unitnumber');
        if(u.size() >0){
            //newCase.AccountId = u[0].AccountId;  
            //newCase.ContactId = u[0].ContactId;
        }
        
        // Added by Vinay 28-03-2025 Start
        List<Case_Escalation_Matrix_SLA__c> escalationSLA = [SELECT Id,Active__c,Case_Sub_Type__c,Case_Type__c,Customer_Lifecycle_Touchpoint__c,SLA__c FROM Case_Escalation_Matrix_SLA__c WHERE Active__c = true];
        if(escalationSLA.size() > 0){
            map<String, String> l2l1Map = new Map<String, String>();
            for(Case_Escalation_Matrix_SLA__c mat : escalationSLA){
                if(!l2l1Map.containsKey(mat.Case_Type__c)){
                    l2l1Map.put(mat.Case_Type__c, mat.Customer_Lifecycle_Touchpoint__c);
                }
            }
            newCase.Customer_Lifecycle_Touchpoint__c = l2l1Map.get(newCase.RW_Complaint_Type__c);
        }
        // Added by Vinay 28-03-2025 End
        
         if(bookingRec.size() >0 && bookingRec[0].Unit_No__r.Relationship_Manager__c != null ){
            newCase.RW_RM_Name__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Name__c;
            //newCase.RW_RM_Name__c ='Adrian Dsouza';
            newCase.User_Id__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
            //newCase.RM_User__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
           // newCase.OwnerId = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
            //Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
            if(bookingRec[0].RW_Key_handover_date__c != null){ //Added by Vinay 03-04-2025
                newCase.Post_Possession_Customer__c = true;
            }
            
        }else{
         // system.debug('*entered*'+bookingRec[0]);
           
          List<Group>  QueueObj =[Select Id From Group where Type = 'Queue' and Name =: Label.Generic_Queue_Name];
          if(QueueObj.size() >0){
            newCase.OwnerId =QueueObj[0].Id;
          }
        }
        //Added by Vinay 07-07-2025 Start
        Date date4MonthsBack = Date.today().addMonths(-4);
        List<String> complaintValues = new List<String>{'Carpentry','Clubhouse & Amenities','Electrical','HVAC','Plumbing'};
        if(bookingRec[0].RW_Key_handover_date__c != null && bookingRec[0].RW_Key_handover_date__c <= date4MonthsBack && complaintValues.contains(newCase.RW_Complaint_Type__c)){
            //return 'You don\'t have the access to raise the service request.';
            String fmTeam = (bookingRec[0].Project__r.FM_Team__c != null)? bookingRec[0].Project__r.FM_Team__c : '';
            String message = 'We hope you\'re settling in well. Please note that as more than 4 months have passed since possession, the portal is now limited to common area-related complaints only.\n';
            message += 'For any concerns regarding your flat, we\'re still here to help.\n ';
            message += 'You can reach our Helpdesk at:\n 📧 Email: ' + fmTeam;
            //message += '📞 Phone: 86557 02566 / 93219 66137 \n';
            return message;
        }else{
            Insert newCase;
            
            //Added by Vinay 28-03-2025
            if(bookingRec[0].RW_Key_handover_date__c != null){
                String fmTeam = (bookingRec[0].Project__r.FM_Team__c != null)? bookingRec[0].Project__r.FM_Team__c : '';
                return 'Case is created successfully, the FM team will acknowledge you. Going forward request you to please write an email to FM team: ' + fmTeam;
            }else{
                return 'Case is created successfully. Relationship Manager will check and revert';
            }
        }
        }catch(exception e){
            return String.valueOf(e);
        }
        //Added by Vinay 07-07-2025 End
       /* Insert newCase;
        
        //Added by Vinay 28-03-2025 Start
        if(bookingRec[0].RW_Key_handover_date__c != null){
            String fmTeam = (bookingRec[0].Project__r.FM_Team__c != null)? bookingRec[0].Project__r.FM_Team__c : '';
            return 'Case is created successfully, the FM team will acknowledge you. Going forward request you to please write an email to FM team: ' + fmTeam;
        }else{
            return 'Case is created successfully. Relationship Manager will check and revert';
        }*/
        //Added by Vinay 28-03-2025 End
    }
    
     @AuraEnabled  
    public static void insertChangeRequestCase(Case newCase,Map<String,String> Details)
    { 
        List<Booking__c> bookingRec =[Select Unit_No__r.Relationship_Manager__r.RM_Name__c,Unit_No__r.Relationship_Manager__r.User__c from Booking__c Where Id =:Details.get('bookingId')];
        List<User> u = [Select Id,ContactId,AccountId, IsActive, IsPortalEnabled, Email from User  where Id = :UserInfo.getUserId()];
        Id customerRecordId =Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        newCase.RecordTypeId = customerRecordId;
        newCase.RW_Case_Type__c='Complaint';
        newCase.RW_Complaint_Type__c = '';
        newCase.RW_Complaint_SubType__c = '';//added by prashant for deployment.
        newCase.Origin ='Portal';
        newCase.Subject ='Request For Change in Applicant Details';
        if(u.size() >0)
        {
            System.debug('inside***');
          //newCase.AccountId = u[0].AccountId;  
          //newCase.ContactId = u[0].ContactId;
        }
        //newCase.OwnerId = '0051e000000jx5VAAQ';
        if(bookingRec.size() >0 && bookingRec[0].Unit_No__r.Relationship_Manager__c != null )
        {
            system.debug('**'+bookingRec[0]);
            system.debug('*2*'+bookingRec[0].Unit_No__c);
            system.debug('*3*'+bookingRec[0].Unit_No__r.Relationship_Manager__c);
            system.debug('*4*'+bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c);
            system.debug('*5*'+bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Name__c);
            newCase.RW_RM_Name__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.RM_Name__c;
            //newCase.RW_RM_Name__c ='Adrian Dsouza';
            newCase.User_Id__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
            //newCase.RM_User__c = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
           // newCase.OwnerId = bookingRec[0].Unit_No__r.Relationship_Manager__r.User__c;
            //Map<String, RM_Usernames__c> mapOfCustomSetting = RM_Usernames__c.getall();
            
        }
        else
        {
         // system.debug('*entered*'+bookingRec[0]);
           
          List<Group>  QueueObj =[Select Id From Group where Type = 'Queue' and Name =: Label.Generic_Queue_Name];
          if(QueueObj.size() >0)
          {
            newCase.OwnerId =QueueObj[0].Id;
          }
        }
        if(Details.get('projectId') != null)
        newCase.RW_Project__c =Details.get('projectId');
        if(Details.get('unitnumber') != null)
        newCase.RW_Flat_No__c =Details.get('unitnumber');
        //newCase.Description = 'Request for Change for '+Details.get('applicantNumber') + ' in Booking '+Details.get('bookingName') +'.Description - '+ newCase.Description;
        newCase.Description = Details.get('description');
        Insert newCase;
    }
    
     @AuraEnabled  
    public static Map<String,List<String>> getBankPicklists(string ProjectName)
    { 
        Map<String,List<String>> bankMap = new Map<String,List<String>>();
        
        
        List<RW_Bank_Details__c> bankList = [select id, name, RW_Banker_Name__c, RW_Banks_Name__c, RW_Branch_Name__c, RW_Email_Id__c , RW_Project_Name__c from RW_Bank_Details__c where RW_Project_Name__c =: ProjectName];
        system.debug('BanklIst -----> ' + bankList);
        for(RW_Bank_Details__c bank  : bankList)
        {
            
            if(!bankMap.containsKey(bank.RW_Banks_Name__c))
            {
                List<String> branchName = new List<String>();
                branchName.add(bank.RW_Branch_Name__c);
                bankMap.put(bank.RW_Banks_Name__c, branchName);
                system.debug('Values in the Map----> '+ bankMap);
            }
            
            else
            {
             List<String> branchName = bankMap.get(bank.RW_Banks_Name__c);
                if(!branchName.contains(bank.RW_Branch_Name__c))
                {
                    branchName.add(bank.RW_Branch_Name__c);
                    bankMap.put(bank.RW_Banks_Name__c, branchName);
                }             
            }
        }
        return bankMap;
    }
    
    
     @AuraEnabled   
    public static void createLoanRecord(Map<String,String> DocDetails)  
    {   
         Loan__c loanRec = new Loan__c();   
         if(DocDetails.get('pancardno')!=null)  
         {  
           loanRec.RW_Pan_card_Id__c = DocDetails.get('pancardno'); 
         }  
         if(DocDetails.get('aadharno')!=null)   
         {  
           loanRec.RW_Aadhar_no__c = DocDetails.get('aadharno');    
         }  
         if(DocDetails.get('uploadedSalarySlip')!=null) 
         {  
           loanRec.RW_Salary_Slip__c = DocDetails.get('uploadedSalarySlip');    
         }  
         if(DocDetails.get('uploadedITR')!=null)    
         {  
           loanRec.RW_ITR__c = DocDetails.get('uploadedITR');   
         }
         
         if(DocDetails.get('uploadedBankStatement')!=null)  
         {  
           loanRec.RW_Bank_Statement__c = DocDetails.get('uploadedBankStatement');  
         }
        
         
         if(DocDetails.get('oppId')!=null)  
         {  
           loanRec.RW_Opportunity__c= DocDetails.get('oppId');  
         }  
         if(DocDetails.get('bookingId')!=null)  
         {  
           loanRec.RW_Booking__c = DocDetails.get('bookingId'); 
         }  
         if(DocDetails.get('Bankname')!=null)   
         {  
           loanRec.RW_Bank_Name__c = DocDetails.get('Bankname');    
           loanRec.RW_Bank_Preference_1__c = DocDetails.get('Bankname');
         }  
         if(DocDetails.get('branchname')!=null) 
         {  
           loanRec.RW_Bank_Branch__c = DocDetails.get('branchname');    
         }  
         if(DocDetails.get('projectID')!=null)  
         {  
           loanRec.RW_Project_Name__c = DocDetails.get('projectID');    
         }  
            
         loanRec.RW_Loan_Record_Status__c = 'Loan Process Initiated';   
        insert loanRec;
        /*if(!Test.isRunningTest()){
            insert loanRec;
        }*/
         
        
         
            
         system.debug('loanRec --> ' + loanRec);    
         if(loanRec != null){
        List<Id> contentDocumentIds = new List<Id>();
        if(DocDetails.get('uploadedPANDocumentID') !=null)  
        {   
        ContentDocumentLink cdl = new ContentDocumentLink();    
        cdl.ContentDocumentId = DocDetails.get('uploadedPANDocumentID');    
        cdl.LinkedEntityId = loanRec.Id;    
        cdl.ShareType = 'V';    
        cdl.Visibility = 'AllUsers';    
        insert cdl;
            contentDocumentIds.add(DocDetails.get('uploadedPANDocumentID'));
         system.debug('after loanRec cdl--> ' + cdl);   
        }   
            
            
         if(DocDetails.get('uploadedAadharCardDocumentID') !=null)  
        {   
        ContentDocumentLink cd2 = new ContentDocumentLink();    
        cd2.ContentDocumentId = DocDetails.get('uploadedAadharCardDocumentID'); 
        cd2.LinkedEntityId = loanRec.Id;    
        cd2.ShareType = 'V';    
        cd2.Visibility = 'AllUsers';    
        insert cd2; 
            contentDocumentIds.add(DocDetails.get('uploadedAadharCardDocumentID'));
        system.debug('after loanRec cd2--> ' + cd2);    
        }   
            
            
        if(DocDetails.get('uploadedSalarySlipId')!=null)    
        {   
        ContentDocumentLink cd3 = new ContentDocumentLink();    
        cd3.ContentDocumentId = DocDetails.get('uploadedSalarySlipId'); 
        cd3.LinkedEntityId = loanRec.Id;    
        cd3.ShareType = 'V';    
        cd3.Visibility = 'AllUsers';    
        insert cd3; 
            
           contentDocumentIds.add(DocDetails.get('uploadedSalarySlipId'));            
           system.debug('after loanRec cd3--> ' + cd3); 
        }   
            
            
         if(DocDetails.get('uploadedITRId')!=null)  
        {   
        ContentDocumentLink cd4 = new ContentDocumentLink();    
        cd4.ContentDocumentId = DocDetails.get('uploadedITRId');    
        cd4.LinkedEntityId = loanRec.Id;    
        cd4.ShareType = 'V';    
        cd4.Visibility = 'AllUsers';    
        insert cd4; 
            
            contentDocumentIds.add(DocDetails.get('uploadedITRId'));
            system.debug('after loanRec cd4--> ' + cd4);    
        }
        
         if(DocDetails.get('uploadedBankStatementId')!=null)    
        {   
        ContentDocumentLink cd5 = new ContentDocumentLink();    
        cd5.ContentDocumentId = DocDetails.get('uploadedBankStatementId');  
        cd5.LinkedEntityId = loanRec.Id;    
        cd5.ShareType = 'V';    
        cd5.Visibility = 'AllUsers';    
        insert cd5; 
            contentDocumentIds.add(DocDetails.get('uploadedBankStatementId'));
            system.debug('after loanRec cd5--> ' + cd5);    
        }   
         sendEmailToBankSPOC(loanRec,contentDocumentIds);  
    } 
    }   
    

       @AuraEnabled
        public static void sendEmailToBankSPOC(Loan__c loanRec, List<id> contentDocumentIds)
        {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<Id> contenversionIds = new List<Id>();
        
         List<Loan__c> loan = [select id, name,RW_Booking__r.Primary_Applicant_Name__c from Loan__c where id =: loanRec.Id];
            system.debug('Loan record for Email --> **** '+ loan);
          
         List<RW_Bank_Details__c> bankD = [SELECT Id, RW_Branch_Name__c, RW_Banks_Name__c, RW_Banker_Name__c, CreatedDate, RW_Email_Id__c, RW_Project_Name__c FROM RW_Bank_Details__c where RW_Banks_Name__c = :loanRec.RW_Bank_Name__c AND RW_Branch_Name__c = :loanRec.RW_Bank_Branch__c ];
          if(bankD.size()>0 &&  bankD[0].RW_Email_Id__c !=null )
          {
            List<ContentVersion> ListcontentVersion = [SELECT ContentDocumentId, Id FROM ContentVersion where ContentDocumentId IN :contentDocumentIds];
              system.debug('ListcontentVersion for loan -->' + ListcontentVersion);
              for(ContentVersion cv  :ListcontentVersion)
              {
                  contenversionIds.add(cv.Id);
              }
              system.debug('ContentVersionids for Loan --> '+ contenversionIds);
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Loan_Apply'];
                
                String htmlBody = template.HtmlValue; 
                String plainTextBody = template.Body;
                system.debug('Email Template -->' + template);
                system.debug('before replace -->');
              
                system.debug('after replace -->' + htmlBody);
                    system.debug('Applicant Name for the Bank *****' + loan[0].RW_Booking__r.Primary_Applicant_Name__c);
                    if(loan.size()> 0 && loan[0].RW_Booking__r.Primary_Applicant_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', loan[0].RW_Booking__r.Primary_Applicant_Name__c);
                    plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', loan[0].RW_Booking__r.Primary_Applicant_Name__c ); 
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', ' ');
                     plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', ' ');
                        
                    }               
                    system.debug('Bank Name in loan --->' + bankD[0].RW_Banks_Name__c);
                    if(bankD.size()>0 && bankD[0].RW_Banks_Name__c !=null)
                    {
                    htmlBody = htmlBody.replace('{!Loan__c.RW_Bank_Name__c}', bankD[0].RW_Banks_Name__c) ;
                    plainTextBody= plainTextBody.replace('{!Loan__c.RW_Bank_Name__c}', bankD[0].RW_Banks_Name__c);
                    }
                    else
                    {
                     htmlBody = htmlBody.replace('{!Loan__c.RW_Bank_Name__c}', ' ');
                     plainTextBody = plainTextBody.replace('{!Loan__c.RW_Bank_Name__c}', ' ');
                    }
      
                                   
                system.debug('after replace   -->' + htmlBody);

                       
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new list<String>{string.valueOf(bankD[0].RW_Email_Id__c)};
                message.subject = template.Subject;
                message.setTemplateId(template.Id);
                message.setHtmlBody(htmlBody);   
                message.setPlainTextBody(plainTextBody);
                if(contenversionIds.size()>0)
                message.setEntityAttachments(contenversionIds);
                message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
          }
        }
          
    @AuraEnabled 
    public static Map<string,PicklistWrapper> getDependentPicklists(String ObjectName, Map<String,String> fieldsMap) {
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
    
    
    
    
     public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
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
    public static String getBillDeskData(Map<String,String> DetailMap)
    {
         String billDeskChecksumKey = '';
        try
        {
        Map<String,String> BillDeskInputMap = new Map<String,String>();
        System.debug('towerId :' + DetailMap.get('towerId'));
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];

            List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
            if(BillDeskDetails != null && BillDeskDetails.size() >0)
            {
                
                Receipt__c receipt = new Receipt__c();
                 receipt.Opportunity__c = DetailMap.get('OpportunityId');
                receipt.Project__c = towerData[0].ProjectName__c;
                receipt.Mode__c = 'Digital';
                receipt.Payment_Gateway__c = 'BillDesk';
               
                receipt.Total_Amount__c = Decimal.valueof(DetailMap.get('Amount'));
                receipt.Booking__c = DetailMap.get('bookingId');
                System.debug('DetailMap'+DetailMap.get('ProjectUnit'));
               receipt.Project_Unit__c=DetailMap.get('ProjectUnit');
                if(DetailMap.get('TypeOfAmount') == 'Normal')
                {
                  receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Flat Cost';  
                }
                else if(DetailMap.get('TypeOfAmount') == 'GST')
                {
                   receipt.RW_Payment_Collection_Type__c = 'Customer Portal - GST';  
                }
                
                if(DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment')
                {
                    receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Outstanding'; 
                }

                insert receipt;
                
                List<Receipt__c> receiptRecord = [Select Name, Opportunity__r.SalesOrder_Number__c, Opportunity__r.SAP_Customer_Number__c, 
                                                  Opportunity__r.RW_Mobile_No__c, Opportunity__r.RW_Email__c, Project_Unit__r.RW_Param1__c, 
                                                  Project_Unit__r.RW_Param4__c from Receipt__c Where Id =:receipt.Id ];
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment'))
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_Merchant_ID__c);
                else if(DetailMap.get('TypeOfAmount')=='GST')
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c);
                BillDeskInputMap.put('CustomerID',receiptRecord[0].Name);
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment'))
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_Security_ID__c);
                else if(DetailMap.get('TypeOfAmount')=='GST')
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_GST_Security_ID__c);
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
                BillDeskInputMap.put('AdditionalInfo7',BillDeskDetails[0].Bill_Desk_Pay_Category__c);
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment'))
                 billDeskChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
                else if(DetailMap.get('TypeOfAmount')=='GST')
                 billDeskChecksumKey = BillDeskDetails[0].Bill_Desk_GST_Checksum_Key__c;
                return Utility.generateBillDeskMessageString(BillDeskInputMap,billDeskChecksumKey);
                
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
    public static String saveBillDeskData(Map<String,String> DetailMap )
    {   System.debug('saveMethodCalled');
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
        List<String> msgList = DetailMap.get('msg').split('\\|');
        String actualinputData = DetailMap.get('msg').substring(0,DetailMap.get('msg').lastIndexOf('|'));
        String checksumValue = DetailMap.get('msg').substring(DetailMap.get('msg').lastIndexOf('|')+1);
        system.debug('*checksumValue**'+checksumValue);
        system.debug('*actualinputData**'+actualinputData);
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];
        List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
           
     
             String ChecksumKey='';
             String paymentType='';
             system.debug('*first*'+msgList[BillDeskResFormat1.indexOf('MerchantID')]+'**'+BillDeskDetails[0].Bill_Desk_Merchant_ID__c+'**'+BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c);
             if(msgList[BillDeskResFormat1.indexOf('MerchantID')] == BillDeskDetails[0].Bill_Desk_Merchant_ID__c)
             {
             ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
             //paymentType = 'Normal';
             }
             else if(msgList[BillDeskResFormat1.indexOf('MerchantID')] == BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c)
             {
             ChecksumKey = BillDeskDetails[0].Bill_Desk_GST_Checksum_Key__c; 
             //paymentType = 'GST';
             }
        try
        { 
            if(ChecksumKey != '' && checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey))
              {
            System.debug('in saveBillDeskData'+msgList+BillDeskResFormat1);
            List<Receipt__c> receiptRecord = [Select Name,Mode__c,BillDesk__c,Booking__c,Project__c,Project_Unit__c,Cheque_DD__c,Amount_Rs__c,Receipt_Status__c,RW_Digital_Payment_Mode__c,Cheque_DD_Date__c from Receipt__c Where Name =: msgList[BillDeskResFormat1.indexOf('CustomerID')] ];

         
         if(receiptRecord != null && receiptRecord.size() >0){
         
         receiptRecord[0].Cheque_DD__c = msgList.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
             
         receiptRecord[0].Currency__c = msgList.get(BillDeskResFormat1.indexOf('CurrencyName'));
       
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
         
         System.debug('**receipt rec**'+receiptRecord);

         if(msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300'){
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
    //Added by coServe 11-04-2023 Start
    @AuraEnabled
    public static List<Customer_Portal_Videos__c> videos(){
        List<Customer_Portal_Videos__c> vids = [SELECT Id, Name, File_Id__c, Order__c, Video_Link__c FROM Customer_Portal_Videos__c ORDER By Order__c];
        System.debug('vids: ' + vids);
        return vids;
    }
    //Added by coServe 11-04-2023 End
}