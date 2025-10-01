public class generate_BookingApplication_Controller {
    
    public ApplicationDetils first_Applicant_Wrapper { get; set; }
    public ApplicationDetils second_Applicant_Wrapper { get; set; }
    public ApplicationDetils third_Applicant_Wrapper { get; set; }
    public BookingWrapper bookingWrap {get; set;}   
    Public date dDate {get; set;}
    public Id quotationId { get; set; }
    public Boolean showPriceSheet { get; set; }
    public List<BookingReceiptWrapper> receiptWrapList { get; set; }
    public Decimal grandTotalReceiptAmount { get; set; }
    public String parkingCountDisplay { get; set; }
    public Integer parkingCount { get; set; }
    public String bareShellDisplay { get; set; }
    public String totalAmountinWords { get; set; }
    
    //Image Variables
    public String ImageofQRcode { get; set; }
    public String FrontPageofProject { get; set; }
    public String LastPageofProject { get; set; }
    public String ImageofProjectLogo { get; set; }
    public String Terms1 { get; set; }
    public String Terms2 { get; set; }
    
    public generate_BookingApplication_Controller(ApexPages.StandardController controller){
        showPriceSheet = true;
        String recordId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Quotation ID to be passed: ' + quotationId);
        System.debug('ID prefix: ' + (quotationId != null ? String.valueOf(quotationId).left(3) : 'null'));
        dDate = System.Today();
        
        List<Booking__c> lstnBooking = [Select Id, Quotation__c From Booking__c Where Id = :recordId LIMIT 1];
        
        if(!lstnBooking.isEmpty()) {
            quotationId = lstnBooking[0].Quotation__c;
            System.debug('Quotation ID to be passed: ' + quotationId);
        }
        
        List<Applicant_Details__c> lstAD = [select id,Applicant_Number__c,First_Name__c,Last_Name__c,DOB__c,Nationality__c,Subtype_Of_Applicant__c,PancardNo__c,Address_Proof_Number__c,
                                            Permanent_Address__c,Mailing_Address__c, Mobile_Number__c,Email_Address__c,Landline_Number__c,Organization_Name__c,
                                            Designation__c,Organization_Address__c,UUID__C,Applicant_Email__c
                                            from Applicant_Details__c where Booking__r.Id =: recordId order by Applicant_Number__c];
        
        List<Booking__c> lstBooking = [Select Id, Unit_No__r.Name,Sales_Manager__r.Name,Sales_Managers__c,Carpet_Area__c,Unit_Type__c, Unit_No__r.Type_Label__c,
                                       Unit_No__r.TowerName__r.Name, No_of_Parking__c,Parking_Type__c,Allotment_Premium__c,Project__r.Quotation_Terms_Conditions__c,
                                       Quotation__r.Agreement_Value__c,Customer_reference_SAP_Code__c,Sale_Order__c,Type_of_Client__c ,
                                       Remarks__c,Customer_reference_Book_Unit__c,Funding_Status__c,BrokerIId__r.Name,BrokerIId__r.Company_Name_As_per_RERA__c,BrokerIId__r.RW_Email__c, 
                                       BrokerIId__r.RW_Mobile_No__c, BrokerIId__r.RW_RERA_Registration_Number__c,Unit_No__r.Legal_Entity__r.name,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Name__c,Unit_No__r.Legal_Entity__r.RDS_Company_Name__c,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address1__c, Unit_No__r.Legal_Entity__r.RDS_Address1__c,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address2__c, Unit_No__r.Legal_Entity__r.RDS_Address2__c,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.CIN__c, Unit_No__r.Legal_Entity__r.CIN__c,
                                       Project__r.Booking_Terms_Conditions__c,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.RERA_Number__c, Unit_No__r.Legal_Entity__r.RERA_Number__c,
                                       Unit_No__r.TowerName__r.Legal_Entity__r.Rera_QR_Code_URL__c,Unit_No__r.Legal_Entity__r.Rera_QR_Code_URL__c,
                                       Project__r.Project_site_URL__c,Project__r.Project_Last_Page_URL__c,Unit_No__r.TowerName__r.Project_Logo_URL__c,
                                       Unit_No__r.TowerName__r.ProjectName__r.Name,Unit_No__r.RW_Project__r.Name, Unit_No__r.TowerName__r.Zone_Name__r.Name,
                                       Unit_No__r.Cluster__c, Bare_Shell__c,Unit_No__r.RW_Param4__c,RW_Unit_Type__c,
                                       Project__r.Booking_Terms_Conditions_2__c,
                                       Source_of_Booking__c,Unit_No__r.TowerName__r.ProjectName__r.RDS_Company_Code__r.Name,
                                       Project__r.RW_Address__c,Project__r.RDS_City__c,
                                       (Select id,Parking__c, booking__r.No_of_Parking__c  from Car_Parking__r ),
                                       (SELECT Id, Mode__c, Cheque_DD__c, Cheque_DD_Date__c,Total_Amount__c FROM Receipts__r)
                                       From Booking__c Where Id =: recordId];
        
       
        
       
        
        
        //For Car Parking
        List<String> parkingList = new List<String>();
        if (!lstBooking.isEmpty()) {
            for (Car_Parking_Charge__c park : lstBooking[0].Car_Parking__r) {
                if (park.Parking__c != null) {
                    parkingList.add(park.Parking__c);
                }
            }
        }
        
        parkingCount = parkingList.size();
        System.debug('parking Count'+ parkingCount);
        parkingCountDisplay = parkingList.isEmpty() ? '' : String.join(parkingList, ',  ');
        //End of Car parking code
        
        
        
        first_Applicant_Wrapper = new ApplicationDetils();
        second_Applicant_Wrapper = new ApplicationDetils();
        third_Applicant_Wrapper = new ApplicationDetils();
        receiptWrapList = new List<BookingReceiptWrapper>();
        grandTotalReceiptAmount = 0;
        totalAmountinWords = '';
        if(!lstAD.isempty() && lstAD.size() > 0){
            for(Applicant_Details__c objAd : lstAD){
                if(objAd.Applicant_Number__c == 'Primary Applicant'){
                    first_Applicant_Wrapper.isfullName = objAd.First_Name__c + ' ' + objAd.Last_Name__c;
                    first_Applicant_Wrapper.isDob = objAD.DOB__c;
                    first_Applicant_Wrapper.isNationality = objAD.Nationality__c;
                    first_Applicant_Wrapper.isResedentialStatus = objAD.Subtype_Of_Applicant__c;
                    first_Applicant_Wrapper.isPanNo = objAD.PancardNo__c;
                    first_Applicant_Wrapper.isAadharNo = objAD.Address_Proof_Number__c;
                    first_Applicant_Wrapper.isPerAddress = objAD.Permanent_Address__c;
                    first_Applicant_Wrapper.isCommunAddress = objAD.Mailing_Address__c;
                    first_Applicant_Wrapper.isMoNo = objAD.Mobile_Number__c;
                    first_Applicant_Wrapper.isTelNo = objAD.Landline_Number__c;
                    first_Applicant_Wrapper.isemail = objAD.Applicant_Email__c;
                    first_Applicant_Wrapper.isCompanyName = objAD.Organization_Name__c;
                    first_Applicant_Wrapper.isDesignation = objAD.Designation__c;
                    first_Applicant_Wrapper.isOfficeAddress = objAD.Organization_Address__c;
                }
                else if(objAd.Applicant_Number__c == 'Second Applicant'){
                    second_Applicant_Wrapper.isfullName = objAd.First_Name__c + ' ' + objAd.Last_Name__c;
                    second_Applicant_Wrapper.isDob = objAD.DOB__c;
                    second_Applicant_Wrapper.isNationality = objAD.Nationality__c;
                    second_Applicant_Wrapper.isResedentialStatus = objAD.Subtype_Of_Applicant__c;
                    second_Applicant_Wrapper.isPanNo = objAD.PancardNo__c;
                    second_Applicant_Wrapper.isAadharNo = objAD.Address_Proof_Number__c;
                    second_Applicant_Wrapper.isPerAddress = objAD.Permanent_Address__c;
                    second_Applicant_Wrapper.isCommunAddress = objAD.Mailing_Address__c;
                    second_Applicant_Wrapper.isMoNo = objAD.Mobile_Number__c;
                    second_Applicant_Wrapper.isTelNo = objAD.Landline_Number__c;
                    second_Applicant_Wrapper.isemail = objAD.Email_Address__c;
                    second_Applicant_Wrapper.isCompanyName = objAD.Organization_Name__c;
                    second_Applicant_Wrapper.isDesignation = objAD.Designation__c;
                    second_Applicant_Wrapper.isOfficeAddress = objAD.Organization_Address__c;
                    
                } else if(objAd.Applicant_Number__c == 'Third Applicant'){
                    third_Applicant_Wrapper.isfullName = objAd.First_Name__c + ' ' + objAd.Last_Name__c;
                    third_Applicant_Wrapper.isDob = objAD.DOB__c;
                    third_Applicant_Wrapper.isNationality = objAD.Nationality__c;
                    third_Applicant_Wrapper.isResedentialStatus = objAD.Subtype_Of_Applicant__c;
                    third_Applicant_Wrapper.isPanNo = objAD.PancardNo__c;
                    third_Applicant_Wrapper.isAadharNo = objAD.Address_Proof_Number__c;
                    third_Applicant_Wrapper.isPerAddress = objAD.Permanent_Address__c;
                    third_Applicant_Wrapper.isCommunAddress = objAD.Mailing_Address__c;
                    third_Applicant_Wrapper.isMoNo = objAD.Mobile_Number__c;
                    third_Applicant_Wrapper.isTelNo = objAD.Landline_Number__c;
                    third_Applicant_Wrapper.isemail = objAD.Email_Address__c;
                    third_Applicant_Wrapper.isCompanyName = objAD.Organization_Name__c;
                    third_Applicant_Wrapper.isDesignation = objAD.Designation__c;
                    third_Applicant_Wrapper.isOfficeAddress = objAD.Organization_Address__c;
                }
            }
        }
        
        
        bookingWrap = new BookingWrapper();
        if(!lstBooking.isempty() && lstBooking.size() > 0){
            for(Booking__c objBook : lstBooking){
                bookingWrap.unitNo = objBook.Unit_No__r.RW_Param4__c;
                if(objBook.Sales_Manager__r.Name != null){
                    bookingWrap.salesManagerName = objBook.Sales_Manager__r.Name;
                }else {
                    bookingWrap.salesManagerName = objBook.Sales_Managers__c;
                }
                bookingWrap.Configuration = objBook.Unit_No__r.Type_Label__c;
                bookingWrap.carpetArea = objBook.Carpet_Area__c;
                bookingWrap.towerName = objBook.Unit_No__r.TowerName__r.Name;
                bookingWrap.agreementValue = objBook.Allotment_Premium__c;
                
                //Convert Amount in words
                //External class : NumberToWords is call
                if(objBook.Allotment_Premium__c != null){
                    NumberToWord converter = new NumberToWord();
                    converter.amount = objBook.Allotment_Premium__c;
                    converter.convertToWords();
                    bookingWrap.agreementValueinWords = converter.amountInWords;
                    System.debug('AMount In words ==>'+ bookingWrap.agreementValueinWords);
                }
                
                bookingWrap.sapCRNno = objBook.Customer_reference_SAP_Code__c;
                bookingWrap.salesOrdrNo = objBook.Sale_Order__c;
                bookingWrap.otherRemark = objBook.Remarks__c;
                bookingWrap.parkingType = objBook.Parking_Type__c;
                bookingWrap.nameOfCorporate = objBook.BrokerIId__r.Name;
                bookingWrap.nameofCompany = objBook.BrokerIId__r.Company_Name_As_per_RERA__c;
                bookingWrap.brokeremail = objBook.BrokerIId__r.RW_Email__c;
                bookingWrap.brokermobile = objBook.BrokerIId__r.RW_Mobile_No__c;
                bookingWrap.reraCertNo = objBook.BrokerIId__r.RW_RERA_Registration_Number__c;
                bookingWrap.bareShell =  objbook.Bare_Shell__c;
                bareShellDisplay = objbook.Bare_Shell__c ? 'Yes' : 'No';
                bookingWrap.UniteType = objbook.RW_Unit_Type__c;
                bookingWrap.TypeofClient = objbook.Type_of_Client__c ;
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.Rera_QR_Code_URL__c != null){
                    ImageofQRcode = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.Rera_QR_Code_URL__c;
                }else{
                    ImageofQRcode = objbook.Unit_No__r.Legal_Entity__r.Rera_QR_Code_URL__c;   
                }
                
                If(objbook.Project__r.Project_site_URL__c != null){
                    FrontPageofProject = objbook.Project__r.Project_site_URL__c;
                }
                
                
                If(objbook.Project__r.Project_Last_Page_URL__c != null){
                    LastPageofProject = objbook.Project__r.Project_Last_Page_URL__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Project_Logo_URL__c != null){
                    ImageofProjectLogo = objbook.Unit_No__r.TowerName__r.Project_Logo_URL__c;
                }
                
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Name__c != Null){
                    bookingWrap.projectName = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Name__c;
                }else{
                    bookingWrap.projectName = objbook.Unit_No__r.Legal_Entity__r.RDS_Company_Name__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address1__c != null){
                    bookingWrap.projectAddress1 = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address1__c; 
                }else{
                    bookingWrap.projectAddress1 = objbook.Unit_No__r.Legal_Entity__r.RDS_Address1__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address2__c != null){
                    bookingWrap.projectAddress2 = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Address2__c; 
                }else{
                    bookingWrap.projectAddress2 = objbook.Unit_No__r.Legal_Entity__r.RDS_Address2__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.CIN__c != null){
                    bookingWrap.projectCIN = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.CIN__c; 
                }else{
                    bookingWrap.projectCIN = objbook.Unit_No__r.Legal_Entity__r.CIN__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RERA_Number__c != null){
                    bookingWrap.mhahRera = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RERA_Number__c;
                }else{
                    bookingWrap.mhahRera = objbook.Unit_No__r.Legal_Entity__r.RERA_Number__c;
                }
                
                If(objbook.Unit_No__r.TowerName__r.ProjectName__r.Name != null && objbook.Unit_No__r.TowerName__r.Zone_Name__r.Name != null){
                    bookingWrap.mhahReraUnit = objbook.Unit_No__r.TowerName__r.ProjectName__r.Name + ' - ' + objbook.Unit_No__r.TowerName__r.Zone_Name__r.Name;
                }
                
                If(objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Name__c != Null){
                    bookingWrap.companyOrDeveloper = objbook.Unit_No__r.TowerName__r.Legal_Entity__r.RDS_Company_Name__c;
                }else{
                    bookingWrap.projectName = objbook.Unit_No__r.Legal_Entity__r.RDS_Company_Name__c; 
                }
                
                if(objbook.Project__r.Booking_Terms_Conditions__c != null){
                    Terms1 = objbook.Project__r.Booking_Terms_Conditions__c;
                }
                
                if(objbook.Project__r.Booking_Terms_Conditions_2__c != null){
                    Terms2 = objbook.Project__r.Booking_Terms_Conditions_2__c;
               }
                
                bookingWrap.sourceOfBooking = objbook.Source_of_Booking__c;
                
                
                //Below code is user to show max five receipt records agaisnt booking
                Integer count = 0;
                if (objBook.Receipts__r != null) {
                    for (Receipt__c rcpt : objBook.Receipts__r) {
                        if (rcpt.Total_Amount__c != null) {
                            grandTotalReceiptAmount += rcpt.Total_Amount__c;
                        }
                        
                        if (count >= 5) break;
                        BookingReceiptWrapper rw = new BookingReceiptWrapper();
                        rw.modeofInstrument = rcpt.Mode__c;
                        rw.chequeOrDdDate = rcpt.Cheque_DD_Date__c;
                        rw.chequeNo = rcpt.Cheque_DD__c;
                        rw.totalAmount = rcpt.Total_Amount__c;
                        if(rcpt.Total_Amount__c != null){
                            NumberToWord converter = new NumberToWord();
                            converter.amount = rcpt.Total_Amount__c;
                            converter.convertToWords();
                            totalAmountinWords = converter.amountInWords;
                            System.debug('AMount In words ==>'+ rw.totalAmountinWords);
                        }
                        
                        receiptWrapList.add(rw);
                        count++;
                    }
                }
            }
        }
    }
    
    // Email formatting method
    public String breakEmail(String email) {
        if(email == null || email.length() <= 20) {
            return email;
        }
        
        // Only add space after @ if the email is longer than 20 characters
        if(email.contains('@')) {
            Integer atPosition = email.indexOf('@');
            return email.substring(0, atPosition+1) + ' ' + email.substring(atPosition+1);
        }
        
        return email;
    }
    
    // Formatted email properties
    public String formattedFirstEmail {
        get {
            return breakEmail(first_Applicant_Wrapper.isemail);
        }
    }
    
    public String formattedSecondEmail {
        get {
            return breakEmail(second_Applicant_Wrapper.isemail);
        }
    }
    
    public String formattedThirdEmail {
        get {
            return breakEmail(third_Applicant_Wrapper.isemail);
        }
    }
    
    //Applicant Wrapper Variable
    Public Class ApplicationDetils{
        public string isfullName {get; set;}
        public date isDob {get; set;}
        public string isNationality {get; set;}
        public string isResedentialStatus {get; set;}
        public string isPanNo {get; set;}
        public string isAadharNo {get; set;}
        public string isGstNo {get; set;}
        public string isPerAddress {get; set;}
        public string isCommunAddress {get; set;}
        public string isMoNo {get; set;}
        public string isTelNo {get; set;}
        public string isemail {get; set;}
        public string isCompanyName {get; set;}
        public string isDesignation {get; set;}
        public string isOfficeAddress {get; set;}
        Public Integer ApplicanCount {get; set;} 
        
        public Boolean isSingleUnit { get; set; }
        public Boolean isSelfFunding {get; set;}
        public Boolean isBankFunding {get; set;}
        public String selfFundingPercent {get; set;}
        public String bankFundingPercent {get; set;}
        public String preferredBanks {get; set;}
        public String scheme {get; set;}
        
        public String applicantName {get; set;}
        public String coApplicantName {get; set;}
        public String coApplicantMobile {get; set;}
        public String coApplicantCompany {get; set;}
        public String coApplicantAge {get; set;}
        public String coApplicantSalary {get; set;}
        
        public Boolean isSalaried {get; set;}
        public Boolean isSelfEmployed {get; set;}
        public Boolean isProfessional {get; set;}
        public String mobileNo {get; set;}
        public String companyName {get; set;}
        public String age {get; set;}
        public String salary {get; set;}
        
        public Boolean is85to95 {get; set;}
        public Boolean is75to85 {get; set;}
        public Boolean isBelow75 {get; set;}
        
        public Boolean isEligibleYes {get; set;}
        public Boolean isEligibleNo {get; set;}
        
        public String loanEligibilityAmount {get; set;}
        public String remarks {get; set;}
        
    }
    
    Public Class BookingWrapper{
        public String unitNo {get; set;}
        public String salesManagerName {get; set;}
        public String Configuration {get; set;}
        public Decimal carpetArea {get; set;}
        public String towerName {get; set;}
        public Decimal noOfParking {get; set;}
        public Decimal agreementValue {get; set;}
        public String agreementValueinWords {get; set;}
        public String sapCRNno {get; set;}
        public String salesOrdrNo {get; set;}
        public String otherRemark {get; set;}
        public String parkingType {get; set;}
        public String nameOfCorporate {get; set;}
        public String nameofCompany {get; set;}
        public String brokeremail {get; set;}
        public String brokermobile {get; set;}
        public String reraCertNo {get; set;}
        public String refferUnitNo {get; set;}
        public String projectName { get; set; }
        public String projectAddress1 { get; set; }
        public String projectAddress2 { get; set; }
        public String projectCIN { get; set; }
        public String mhahRera { get; set; }
        public String mhahReraUnit { get; set; }
        public Boolean bareShell { get; set; }
        Public string companyOrDeveloper {get; set; }
        public string UniteType { get; set; }
        Public string sourceOfBooking {get; set; }
        Public string TypeofClient {get; set; }
        Public string existingCustomer {get; set; }
        Public string existingCustomerCRN {get; set; }
    }  
    
    public class BookingReceiptWrapper {
        public String modeofInstrument { get; set; }
        public Date chequeOrDdDate { get; set; }
        public String chequeNo { get; set; }
        public Decimal totalAmount { get; set; }
        public String totalAmountinWords { get; set; }
        
    }
    
    Public static void fakeMethod(){
        integer i = 1;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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
        i++;i++;
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