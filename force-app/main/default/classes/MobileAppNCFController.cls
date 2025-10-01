public without sharing class MobileAppNCFController {
	
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    //changes made by ishu
    public static String getPrincipalPayableAmount(Decimal totalPrincipal,Decimal totalGST,Decimal totalDemand,Decimal totalOutStanding,Decimal TDSDue)
    {
       
        Decimal principalAmount=0;
     Integer BalanceDues;
         BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);
         principalAmount=BalanceDues*(totalPrincipal/totalDemand);
        System.debug('****principalAmount****'+principalAmount);
     principalAmount=   principalAmount.round();
        System.debug('****principalAmount****'+principalAmount);
        
        return String.valueOf(principalAmount);
    }
    
    //changes made by Srinivas on 15/07/21
     public static String getGstPayableAmount(Decimal totalGST,Decimal totalDemand,Decimal totalOutStanding,Decimal TDSDue)
    {
        Decimal gstAmount=0;
     Integer BalanceDues;
         BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);
         gstAmount=BalanceDues*(totalGST/totalDemand);
       gstAmount= gstAmount.round();
        return String.valueOf(gstAmount);
    }
    public static String getCheckProjectTotalAmount(Decimal totalOutStanding,Decimal TDSDue)
    {
        Integer BalanceDues;
         BalanceDues=Integer.valueOf(totalOutStanding)-Integer.valueOf(TDSDue);
        return String.valueOf(BalanceDues);
    }
   

    
    @AuraEnabled
    public static List<HomeRunwalWrapper> getPortalHomeData(String accId)
    {
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
        Map<String,String> custLifefieldMap = new Map<String,String>(); //Added by Vinay 23-04-2025
        custLifefieldMap.put('RW_Complaint_Type__c','Customer_Lifecycle_Touchpoint__c'); //Added by Vinay 23-04-2025
        Map<String,String> caseTypefieldMap = new Map<String,String>();
        //caseTypefieldMap.put('RW_Complaint_Type__c','RW_Case_Type__c');
        caseTypefieldMap.put('Customer_Lifecycle_Touchpoint__c','RW_Case_Type__c'); //Added by Vinay 23-04-2025
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
        
            //Added by Vinay 23-04-2025 Start
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
        //Added by Vinay 23-04-2025 End
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
                System.debug('accountId: ' + accountId);
                if(accountId == null){
                    accountId = accId;
                }
                System.debug('accId: ' + accId);
                System.debug('accountId: ' + accountId);
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
                homeRunwalWrapper.TotalDemandOutstanding = BookingMap.get(bookingId).RW_Total_Demand_Outstanding__c;
                //homeRunwalWrapper.TotalDemandOutstanding=BookingMap.get(bookingId).RW_Total_Demand_Raised__c - BookingMap.get(bookingId).RW_Total_Receipt_Amount_Received__c - BookingMap.get(bookingId).RW_Total_Receipt_Discount_Recieved__c ;
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

                //Added by Vinay 23-04-2025 Start
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
                //Added by Vinay 23-04-2025 End
                
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
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__c !=null && BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Email__c != null)
                homeRunwalWrapper.RMEmail =BookingMap.get(bookingId).Unit_No__r.Relationship_Manager__r.RM_Email__c;
                if(BookingMap.get(bookingId).Unit_No__c != null && BookingMap.get(bookingId).Unit_No__r.RW_Param4__c !=null)
                homeRunwalWrapper.unitNumber=BookingMap.get(bookingId).Unit_No__r.RW_Param4__c;
                homeRunwalWrapper.unitNo=BookingMap.get(bookingId).Unit_No__c;
                if(BookingMap.get(bookingId).Customer__c != null && BookingMap.get(bookingId).Customer__r.RW_Agreement_Value__c !=null)
                homeRunwalWrapper.agreementValue=String.valueOf(BookingMap.get(bookingId).Customer__r.RW_Agreement_Value__c);
                System.debug('*Quot*'+BookingMap.get(bookingId).Quotation__c+'**'+BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c);
                if(BookingMap.get(bookingId).Quotation__c != null && BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c !=null)
                homeRunwalWrapper.numberofCarParking=String.valueOf(BookingMap.get(bookingId).Quotation__r.Total_No_of_Parking__c);
                if(BookingMap.get(bookingId).Floor__c !=null)
                homeRunwalWrapper.Floor=String.valueOf(BookingMap.get(bookingId).Floor__c);
                if(BookingMap.get(bookingId).Source_of_Booking__c != null)
                homeRunwalWrapper.SourceOfBooking= BookingMap.get(bookingId).Source_of_Booking__c;
                if(!String.isBlank(String.valueOf(BookingMap.get(bookingId).Booking_Date__c)))
                homeRunwalWrapper.BookingDate=BookingMap.get(bookingId).Booking_Date__c.format('dd/MM/yyyy');
                /*if(BookingMap.get(bookingId).Carpet_Area__c != null)
                homeRunwalWrapper.CarpetArea=String.valueOf(BookingMap.get(bookingId).Carpet_Area__c);*/ //Commented by Vinay 23-04-2025
                if(BookingMap.get(bookingId).Unit_No__r.Total_RERA_Carpet_Area__c != null)  //Added by Vinay 23-04-2025
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
                        if(homeRunwalWrapper.towerConstructionDetails.size() <= 3)
                        {
                        SYstem.debug('inside cons else if1*****');
                        Map<String,String> photodetailsMap = new Map<String,String>();
                        photodetailsMap.put(contructionupdate.RW_Tower_Construction_Photo_ID__c, contructionupdate.RW_Description__c);
                        homeRunwalWrapper.towerConstructionDetails.put(contructionupdate.RW_Date_Month__c+','+contructionupdate.RW_Date_Year__c,photodetailsMap);
                        SYstem.debug('inside cons else if1 end*****'+homeRunwalWrapper.towerConstructionDetails);
                        }
                    }   
                    
                        
                   
                    }
                    
                    
                    //homeRunwalWrapper.towerConstructionDetails = constDetailsMap.get(BookingMap.get(bookingId).Unit_No__r.TowerName__c);
                }
                
                SYstem.debug('inside out*****'+homeRunwalWrapper.towerConstructionDetails);
                                
                
                
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
                
                
                SYstem.debug('WrapperData1'+homeRunwalWrapper);
                homeRunwalWrapList.add(homeRunwalWrapper);
            }
            
         
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
    
    
    //public static void createNCFRecord(Name_Confirmation_Form__c NCFDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFDetails,Map<String,String> NCFOtherDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFOtherApplicantDetails,List<String> RemovedAppIds,String BookingRecordId)
    //{
    @AuraEnabled
    public static void createNCFRecord(Name_Confirmation_Form__c NCFDetails,Map<String,HomeRunwalWrapper.appDetailsWrapper> NCFOtherApplicantDetails,List<String> RemovedAppIds,String BookingRecordId)
    {
        System.debug('*inside*');
        List<Name_Confirmation_Form__c> ncfObj = new List<Name_Confirmation_Form__c>();
        List<Applicant_Details__c> appDetailObjList = new List<Applicant_Details__c>();
        //system.debug('*NCF*'+NCFDetails+'**');
      
        
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
           
           
        if(appDetailObjList.size() >0  && !Test.isRunningTest())
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
    public static List<String> getPicklists(String ObjectName, String FieldName)
    {
        //return Utility.getPicklistValues('Applicant_Details__c', 'Country__c');
        return Utility.getPicklistValues(ObjectName, FieldName);
        
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
 
}