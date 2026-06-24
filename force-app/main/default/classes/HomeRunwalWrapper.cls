public class HomeRunwalWrapper{
    @AuraEnabled
    public List<Booking__c> Bookings{get;set;}
    
    @AuraEnabled
    public List<String> countryNames{get;set;}
    
    @AuraEnabled
    public List<String> stateNames{get;set;}
    
    @AuraEnabled
    public List<String> cityNames{get;set;}
    
    @AuraEnabled
    public String currentUserId{get;set;}
    
    @AuraEnabled
    public List<String> applicantTypePicklistValues{get;set;}
    
    @AuraEnabled
    public List<String> residentailstatusPicklistValues{get;set;}
    
    @AuraEnabled
    public List<String> addressproofPicklistValues{get;set;}
    
    @AuraEnabled
    public List<String> typeofOriginPicklistValues{get;set;}
    
    @AuraEnabled
    public Map<string,PicklistWrapper> dependentPicklistMap{get;set;}
    
    @AuraEnabled
    public Map<string,PicklistWrapper> complaintdependentPicklistMap{get;set;}
    
    @AuraEnabled
    public Map<string,PicklistWrapper> caseTypedependentPicklistMap{get;set;}
    
    @AuraEnabled
    public Map<string,PicklistWrapper> custLifedependentPicklistMap{get;set;}
    
    @AuraEnabled
    public List<DemandWrapper> demandWrapperList{get;set;}
    
    @AuraEnabled
    public List<receiptWrapper> receiptWrapperList{get;set;}
    
    @AuraEnabled
    public List<inspectionWrapper> inspectionWrapperList{get;set;} 
    
    @AuraEnabled
    public List<appDetailsWrapper> appDetailsWrapperList{get;set;}
    
   // @AuraEnabled
   // public List<towerConstructionWrapper> towerConstructionWrapperList{get;set;}
    
    @AuraEnabled
    public Map<String,Map<String,String>> towerConstructionDetails{get;set;}
    
    @AuraEnabled
    public List<loanWrapper> loanWrapperList{get;set;}
    
    @AuraEnabled
    public List<tdsWrapper> tdsWrapperList{get;set;}
    
    @AuraEnabled
    public String BookingStatus{get;set;}
    
    @AuraEnabled
    public Name_Confirmation_Form__c ncfdata{get;set;}
    
    @AuraEnabled
    public String customerNumber{get;set;}
    
    @AuraEnabled
    public String salesorderNumber{get;set;}
    
    @AuraEnabled
    public String agreementStatus{get;set;}
    
    @AuraEnabled
    public String agreementDocumentId{get;set;}
    
    @AuraEnabled
    public String BookingId{get;set;}
    
     @AuraEnabled
    public String communityName{get;set;}
    
    @AuraEnabled
    public String sitelink{get;set;}
    
    @AuraEnabled
    public String projectcompanycode{get;set;}
    
    @AuraEnabled
    public String bookinglinkId{get;set;}
    
    @AuraEnabled
    public String possessionlinkId{get;set;}
    
    @AuraEnabled
    public String opportunityId{get;set;}
    
    @AuraEnabled
    public String encryptedBookingId{get;set;}
    
    @AuraEnabled
    public String BookingName{get;set;}
    
    @AuraEnabled
    public String ProjectName{get;set;}
        	
    @AuraEnabled	
    public String ProjectId{get;set;}
    
    @AuraEnabled
    public String TowerName{get;set;}
    
    @AuraEnabled
    public String TowerId{get;set;}
    
    @AuraEnabled
    public String TowerFloorPlanLink{get;set;}
    
    @AuraEnabled
    public String ProjectBrochureLink{get;set;}
    
    @AuraEnabled
    public String ProjectVideoLink{get;set;}
    
    @AuraEnabled
    public String Floor{get;set;}
    
    @AuraEnabled
    public String RMName{get;set;}
    
    @AuraEnabled
    public String RMNumber{get;set;}
    
    @AuraEnabled
    public String RMEmail{get;set;}
    
    @AuraEnabled
    public String SourceOfBooking{get;set;}
    
    @AuraEnabled
    public String BookingDate{get;set;}
    
    @AuraEnabled
    public String CarpetArea{get;set;}
    
    @AuraEnabled
    public String PrimaryApplicantEmail{get;set;}
    
    @AuraEnabled
    public String encryptedeoiRecordId{get;set;}
    
    @AuraEnabled
    public String unitNumber{get;set;}
    
    @AuraEnabled
    public String unitNo{get;set;}
    
    @AuraEnabled
    public String agreementValue{get;set;}
    
    @AuraEnabled
    public String domainURL{get;set;}
    
    @AuraEnabled
    public String documentdomainURL{get;set;}
    
    @AuraEnabled
    public String numberofCarParking{get;set;}
    
    @AuraEnabled
    public String totalInterest{get;set;}
    
    @AuraEnabled
    public String totalInterestWaived{get;set;}
    
    @AuraEnabled
    public String totalcollectibleInterest{get;set;}
    
    @AuraEnabled
    public String totalamountcollected{get;set;}
    
    @AuraEnabled
    public String totalamountbalance{get;set;}
   /* 
    @AuraEnabled
    public String nomineename{get;set;}
    
    @AuraEnabled
    public String nomineepan{get;set;}
    
    @AuraEnabled
    public String poaname{get;set;}
    
    @AuraEnabled
    public String poapan{get;set;}
    
    @AuraEnabled
    public String poamobile{get;set;}
    
    @AuraEnabled
    public String poaemail{get;set;}
   */ 
    @AuraEnabled
    public Decimal TotalDemandRaised{get;set;}
    
    @AuraEnabled
    public Decimal TotalDemandOutstanding{get;set;}
    
    @AuraEnabled
    public String TotalDiscount{get;set;}
    
    @AuraEnabled
    public String OverallTDSPayable{get;set;}
    
    @AuraEnabled
    public String OverallTDSPaid{get;set;}
    
    @AuraEnabled
    public String NetTDSOutstanding{get;set;}
    
    @AuraEnabled
    public String TotalDemandPaid{get;set;}
    
    @AuraEnabled
    public Date NextDemandDate{get;set;}
    
    @AuraEnabled
    public Date ExpectedSDRDate{get;set;}
    
    @AuraEnabled
    public String ExpectedRegistrationDate{get;set;}
    
    @AuraEnabled
    public string SDRStatus{get;set;}
    
    @AuraEnabled
    public String inspectionStatus{get;set;}
    
    @AuraEnabled
    public String expectedPossesionDate{get;set;}
    
    @AuraEnabled
    public String inspectionId{get;set;}
    
    @AuraEnabled
    public String eoiId{get;set;}
     
    @AuraEnabled
    public String companyCode{get;set;}
    
    @AuraEnabled
    public String registrationstatus{get;set;}
    
    @AuraEnabled
    public String TotalAmountRecieved{get;set;}
    
    @AuraEnabled
    public String TotalAmountPaid{get;set;}
    @AuraEnabled
    public String TotalGSTPaid{get;set;}
    @AuraEnabled
    public Decimal TotalGST{get;set;}
    @AuraEnabled
    public Decimal TotalTDSDue{get;set;}
    @AuraEnabled
    public Decimal TotalPrincipalDemand{get;set;}
    @AuraEnabled
    public Boolean Flag{get;set;}
    @AuraEnabled
	public Boolean SeperatePay{get;set;}
    @AuraEnabled
	public String ProjectSpecificAmount{get;set;}
    
  
                       
                       
                       
    
               
    
    public HomeRunwalWrapper(){
        demandWrapperList = new List<DemandWrapper>();
        inspectionWrapperList = new List<inspectionWrapper>();
        appDetailsWrapperList = new List<appDetailsWrapper>();
        loanWrapperList = new List<loanWrapper>();
        tdsWrapperList = new List<tdsWrapper>();
        receiptWrapperList = new List<receiptWrapper>();
        //towerConstructionWrapperList = new List<towerConstructionWrapper>();
        towerConstructionDetails = new Map<String,Map<String,String>>();
    }
    
  /*  public class towerConstructionWrapper
    {
        @AuraEnabled
        public String description{get;set;}
        
        @AuraEnabled
        public String imageURL{get;set;}
        
        @AuraEnabled
        public String towerId{get;set;}
        
        @AuraEnabled
        public Date photodate{get;set;}
        
        @AuraEnabled
        public String photodatemonth{get;set;}
        
        @AuraEnabled
        public String photodateyear{get;set;}
        
        @AuraEnabled
        public String photodocumentID{get;set;}
        
        
    }*/
    
    public class DemandWrapper{
        @AuraEnabled
        public String demandId{get;set;}
        
        @AuraEnabled
        public String demandName{get;set;}
        
        @AuraEnabled
        public String demandStatus{get;set;}
        
        @AuraEnabled
        public String demandDueDate{get;set;}
        
        @AuraEnabled
        public String BillingDocumentNumber{get;set;}
        
        @AuraEnabled
        public String CustomerNumber{get;set;}
        
        @AuraEnabled
        public String DemandAmount{get;set;}
        
        @AuraEnabled
        public String DemandDate{get;set;}
        
        @AuraEnabled
        public String ODNNumber{get;set;}
        
        @AuraEnabled
        public String TotalGSTAmount{get;set;}
        
        @AuraEnabled
        public String TotalDemandAmount{get;set;}
        
        @AuraEnabled
        public String TotalDemandAmountCL{get;set;}
        
        @AuraEnabled
        public List<RW_Demand_Item__c> demandItems{get;set;}
        
        @AuraEnabled
        public String DemandItemAmount{get;set;}
        
        @AuraEnabled
        public String DemandItemNumber{get;set;}
        
        @AuraEnabled
        public String GSTAmount{get;set;}
        
        @AuraEnabled
        public String MilestoneName{get;set;}
        
        @AuraEnabled
        public String UsageCode{get;set;}
        
        @AuraEnabled
        public String remainingAmount{get;set;}
        
        @AuraEnabled
        public String recieved{get;set;}
        
        @AuraEnabled
        public Boolean disableDemandDownload{get;set;}
        
    }
    
    public class receiptWrapper{
        @AuraEnabled
        public String AccountDocumentNumber{get;set;}
        
        @AuraEnabled
        public String BankReferenceNumber{get;set;}
        
        @AuraEnabled
        public String BranchName{get;set;}
        
        @AuraEnabled
        public String ClearingDocumentNumber{get;set;}
        
        @AuraEnabled
        public String CompanyCode{get;set;}
        
        @AuraEnabled
        public String CustomerId{get;set;}
        
        @AuraEnabled
        public String DemandNumber{get;set;}
        
        @AuraEnabled
        public String ReceiptId{get;set;}
        
        @AuraEnabled
        public String ReceiptAmount{get;set;}
        
        @AuraEnabled
        public String ReceiptDate{get;set;}
        
        @AuraEnabled
        public String ReceiptStatus{get;set;}
        
        @AuraEnabled
        public String DocumentType{get;set;}
        
        @AuraEnabled
        public Boolean disableReceiptDownload{get;set;}
        
    }
    
    public class inspectionWrapper{
    }
    
    public class loanWrapper{
        @AuraEnabled
        public String loanId{get;set;}
        
        @AuraEnabled
        public String sanctionletterDocumentId{get;set;}
        
        @AuraEnabled
        public String loanstatus{get;set;}
        
        @AuraEnabled	
        public String pancard{get;set;}	
        	
        @AuraEnabled	
        public String aadharcard{get;set;}	
        	
        @AuraEnabled	
        public String drvinglicense{get;set;}	
        	
        @AuraEnabled	
        public String passportsize{get;set;}
        
    }
    
    public class tdsWrapper{
        @AuraEnabled
        public String tdsId{get;set;}
        
        @AuraEnabled
        public String tdsDocumentId{get;set;}
        
        @AuraEnabled
        public String tdscertificateNumber{get;set;}
        
        @AuraEnabled
        public String tdsamount{get;set;}
        
    }
    
    public class appDetailsWrapper{
        @AuraEnabled
        public String applicantId{get;set;}
        
        @AuraEnabled
        public String registrationStatus{get;set;}
        
        @AuraEnabled
        public String firstName{get;set;}
        
        @AuraEnabled
        public String lastName{get;set;}
        
        @AuraEnabled
        public String middleName{get;set;}
        
        @AuraEnabled
        public Date dateOfBirth{get;set;}
        
        @AuraEnabled
        public String permanentaddr1{get;set;}
        
        @AuraEnabled
        public String permanentaddr2{get;set;}
        
        @AuraEnabled
        public String permanentaddr3{get;set;}
        
        
        
        @AuraEnabled
        public String country{get;set;}
        
        @AuraEnabled
        public String state{get;set;}
        
        @AuraEnabled
        public String city{get;set;}
        
        @AuraEnabled
        public String pin{get;set;}
        
        @AuraEnabled
        public String email{get;set;}
        
        @AuraEnabled
        public String mobile{get;set;}
        
        @AuraEnabled
        public String address{get;set;}
        
        @AuraEnabled
        public String bookingId{get;set;}
        
        @AuraEnabled
        public String opportunityId{get;set;}
        
        @AuraEnabled
        public String companyname{get;set;}
        
        @AuraEnabled
        public String appNumber{get;set;}
        
        @AuraEnabled
        public String applicantType{get;set;}
        
        @AuraEnabled
        public String residentialStatus{get;set;}
        
        @AuraEnabled
        public String panCard{get;set;}
        
        @AuraEnabled
        public String panCardDocumentId{get;set;}
        
        @AuraEnabled
        public String addressproofDocument{get;set;}
        
        @AuraEnabled
        public String aadharDocumentId{get;set;}
        
        @AuraEnabled
        public String drivingLicenseDocumentId{get;set;}
        
        @AuraEnabled
        public String electricitybillDocumentId{get;set;}
        
        @AuraEnabled
        public String voterIdDocumentId{get;set;}
        
        @AuraEnabled
        public String passportDocumentId{get;set;}
        
        @AuraEnabled
        public String addressproofDocumentNumber{get;set;}
        
        @AuraEnabled
        public String typeOfOrigin{get;set;}
        
        @AuraEnabled
        public String origindetails{get;set;}
        
        @AuraEnabled
        public String piocardDocumentId{get;set;}
        
        @AuraEnabled
        public String ocicardDocumentId{get;set;}
        
        @AuraEnabled
        public String passportnodetails{get;set;}
        
        @AuraEnabled
        public String passportnodetailsDocumentId{get;set;}
        
        @AuraEnabled
        public String panCardNumberofAuthoritySignatory{get;set;}
        
        @AuraEnabled
        public String panCardNumberofAuthoritySignatoryDocumentId{get;set;}
        
        @AuraEnabled
        public String bookingName{get;set;}
        
        @AuraEnabled
        public String unitNumber{get;set;}
        
        @AuraEnabled
        public String ProjectId{get;set;}
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
    
    
}