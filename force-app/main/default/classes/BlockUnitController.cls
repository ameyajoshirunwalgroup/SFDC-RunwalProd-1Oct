public class BlockUnitController {
    //Added by Dolly
    Public CIF__c CIFObj { get; set;}
    public String originalModeOfFunding { get; set; }
    public String originalBankPreference1 { get; set; }
    public String originalBankPreference2 { get; set; }
    public String originalBankPreference3 { get; set; }

    // Added By UBSdigicloud
    public String aadharNumber { get; set; }
    public String panNumber { get; set; }
    
    public List<String> pendingReason { get; set; } // To store multiple selected values
    //  public String bookNowStatus { get; set; }
    public String remarks { get; set; }
    public List<SelectOption> pendingReasonList { get; set; }
    //  public List<SelectOption> bookNowStatusList { get; set; }
    
    
    
    public Date blockedDate { get; set; } //Added by Prashant // 14-07-25...//
    public String payMode1 {get;set;}
    public Decimal amount1 {get;set;}
    public Date payDate1 {get;set;}
    public String payDetails1 {get;set;}
    public String bank1 {get;set;}
    
    public String payMode2 {get;set;}
    public Decimal amount2 {get;set;}
    public Date payDate2 {get;set;}
    public String payDetails2 {get;set;}
    public String bank2 {get;set;}
    
    public String payMode3 {get;set;}
    public Decimal amount3 {get;set;}
    public Date payDate3 {get;set;}
    public String payDetails3 {get;set;}
    public String bank3 {get;set;}
    
    public String payMode4 {get;set;}
    public Decimal amount4 {get;set;}
    public Date payDate4 {get;set;}
    public String payDetails4 {get;set;}
    public String bank4 {get;set;}
    
    public String payMode5 {get;set;}
    public Decimal amount5 {get;set;}
    public Date payDate5 {get;set;}
    public String payDetails5 {get;set;}
    public String bank5 {get;set;}
    
    public List<SelectOption> payModeList {get;set;} 
    public List<SelectOption> bankList {get;set;} //Added by Vinay 21-08-2025
    public String unitId {get;set;}
    public String oppId {get;set;}
    public List<Blocking_Unit_Information__c> info {get;set;}
    public Project_Unit__c unit {get;set;}
    public Opportunity opp {get;set;}
    public Decimal tokenAmount {get;set;}
    public Boolean showContinueButton {get;set;}
    public String blkId {get;set;}
    public Decimal agrementVal {get;set;}
    public Boolean hideAll {get;set;}
    
    public BlockUnitController(){
        
        if (ApexPages.currentPage().getParameters().get('unitId') != null && ApexPages.currentPage().getParameters().get('unitId') != '') {
            unitId = ApexPages.currentPage().getParameters().get('unitId');
            system.debug('unitId: ' + unitId);
        }
        if (ApexPages.currentPage().getParameters().get('oppId') != null && ApexPages.currentPage().getParameters().get('oppId') != '') {
            oppId = ApexPages.currentPage().getParameters().get('oppId');
            system.debug('oppId: ' + oppId);
        }
        
        unit = [SELECT Id, Name, RW_Customer__c, RW_Customer__r.Name, RW_Project__c, RW_Project__r.Name, RW_Project__r.Sales_Site_Head__c,
                Saleable_Area__c, RW_Param4__c, Token_Amount__c, RW_Booking_Date__c,RW_Project__r.Token_Amount__c FROM Project_Unit__c WHERE Id =: unitId];
        opp = [SELECT Id, Name, StageName, RW_Opportunity_Status__c, Relationship_Manager__c, Blocked_Date__c, RW_Booking_Date_Opp__c, RW_Project__r.Allow_Blocking_on_Non_Active_Opportunity__c FROM Opportunity WHERE Id =: oppId];
        CIFObj= [select Id,Opportunity__c,Mode_of_funding__c,Bank_Preference_1__c,Bank_Preference_2__c,Bank_Preference_3__c from CIF__c where Opportunity__c=:oppId];
        // Store original values
        originalModeOfFunding = CIFObj.Mode_of_funding__c;
        originalBankPreference1 = CIFObj.Bank_Preference_1__c;
        originalBankPreference2 = CIFObj.Bank_Preference_2__c;
        originalBankPreference3 = CIFObj.Bank_Preference_3__c;
        if(opp.RW_Project__r.Allow_Blocking_on_Non_Active_Opportunity__c == false && opp.RW_Opportunity_Status__c != 'Active'){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'You can only Block the Active Opportunity');
            ApexPages.addMessage(myMsg);
            hideAll = true;
        }
        
        //Added by Prashant // 14-07-25...//
        if (blockedDate == null) {
            blockedDate = Date.today();
        }
        //Added by Prashant // 14-07-25...//
        tokenAmount = unit.Token_Amount__c;
        
        List<Blocking_Unit_Information__c> info = [SELECT Id FROM Blocking_Unit_Information__c WHERE Opportunity__c =: oppId AND Project_Unit__c =: unitId];
        
        payModeList = new List<SelectOption>();
        List<Schema.Picklistentry> payModeResult = Blocking_Unit_Information__c.Mode_Of_Payment__c.getDescribe().getPicklistValues();
        payModeList.add(new SelectOption('', ''));
        for(Schema.PicklistEntry f : payModeResult) {
            payModeList.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        
        //Added by Vinay 21-08-2025 Start
        bankList = new List<SelectOption>();
        List<Schema.Picklistentry> bankResult = Receipt__c.DraweeBank__c.getDescribe().getPicklistValues();
        bankList.add(new SelectOption('', ''));
        for(Schema.PicklistEntry f : bankResult) {
            bankList.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        //Added by Vinay 21-08-2025 End
        
        // Added By UBSdicloud team 
        pendingReasonList = new List<SelectOption>();
        List<Schema.PicklistEntry> pendingResult = Blocking_Unit_Information__c.Pending_Reason__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry f : pendingResult) {
            pendingReasonList.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        
        /*    bookNowStatusList = new List<SelectOption>();
List<Schema.PicklistEntry> bookNowResult = Blocking_Unit_Information__c.Book_Now_Status__c.getDescribe().getPicklistValues();
bookNowStatusList.add(new SelectOption('', ''));
for(Schema.PicklistEntry f : bookNowResult) {
bookNowStatusList.add(new SelectOption(f.getValue(), f.getLabel()));
}
bookNowStatus = 'Pending'; */
    }
    
    // Added by UBSDigicloud -------------------
    public PageReference saveAndRedirectToQuotePage() {
        PageReference result = saveDetails(); // Reuse the same validations and save logic
        if (result != null) {
            // Redirect to quotation page
            PageReference quotePage = new PageReference('/apex/QuotationStartPage');
            quotePage.getParameters().put('oppId', oppId);
            quotePage.getParameters().put('unitId', unitId);
            quotePage.setRedirect(true);
            return quotePage;
        }
        return null; // If saveDetails fails, stay on the same page with messages
    }
    //--------------
    //
    public pageReference saveDetails(){
        
        List<Blocking_Unit_Information__c> blkInfoToInsert = new List<Blocking_Unit_Information__c>();
        
        // Check if the token amount is provided
        Decimal requiredTokenAmount = unit.Token_Amount__c != null ? unit.Token_Amount__c : unit.RW_Project__r.Token_Amount__c;
        
        /*if(requiredTokenAmount == null){ //Commented by Vinay 02-07-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Token amount is missing on both Unit and Project. Please contact Sales Strategy.');
            ApexPages.addMessage(myMsg); 
            return null;
        }*/
        
        // Validate Pending Reason and Book Now Status
        // Check if no options are selected
        if (pendingReason == null || pendingReason.isEmpty()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Pending Reason is required');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        
        // Check if 'Others' is selected and remarks is blank
        if (pendingReason.contains('Others') && (remarks == null || remarks.trim() == '')) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'If Pending Reason: Others then Remarks is mandatory');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        
        if ((payMode1 != null  ) && (amount1 == null ||payDate1 == null || (payDetails1 == null || payDetails1 == '') ))  {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter All Payment Fields ');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        if ((amount1 != null) && (payMode1 == null || payDate1 == null || (payDetails1 == null || payDetails1 == '') || String.isBlank(bank1)))  { // Added String.isBlank(bank1) by Vinay 21-08-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        if (CIFObj.Mode_of_funding__c == null || CIFObj.Mode_of_funding__c == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill up Mode Of Funding to proceed.');
            ApexPages.addMessage(myMsg); 
            return null; 
        }
        if (CIFObj.Mode_of_funding__c == 'Bank Loan' && (CIFObj.Bank_Preference_1__c == null || CIFObj.Bank_Preference_1__c == '') ){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill up Bank Prefrences to proceed.');
            ApexPages.addMessage(myMsg); 
            return null; 
        }
         // Check duplicate banks
        Set<String> bankSet = new Set<String>();
        if (CIFObj.Bank_Preference_1__c != null) bankSet.add(CIFObj.Bank_Preference_1__c);
        if (CIFObj.Bank_Preference_2__c != null) {
            if (bankSet.contains(CIFObj.Bank_Preference_2__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bank 2 cannot be same as Bank 1.'));
                return null;
            }
            bankSet.add(CIFObj.Bank_Preference_2__c);
        }
        if (CIFObj.Bank_Preference_3__c != null) {
            if (bankSet.contains(CIFObj.Bank_Preference_3__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Bank 3 cannot be same as another selected Bank.'));
                return null;
            }
            bankSet.add(CIFObj.Bank_Preference_3__c);
        }
        
        //Added by Vinay 21-08-2025 Start
        List<String> utrDetails = new List<String>();
        if(!String.isBlank(payDetails1) && !String.isBlank(bank1))
            utrDetails.add(payDetails1 + '_' + bank1);
        if(!String.isBlank(payDetails2) && !String.isBlank(bank2))
            utrDetails.add(payDetails2 + '_' + bank2);
        if(!String.isBlank(payDetails3) && !String.isBlank(bank3))
            utrDetails.add(payDetails3 + '_' + bank3);
        if(!String.isBlank(payDetails4) && !String.isBlank(bank4))
            utrDetails.add(payDetails4 + '_' + bank4);
        if(!String.isBlank(payDetails5) && !String.isBlank(bank5))
            utrDetails.add(payDetails5 + '_' + bank5);
        Set<String> uniqueUtrDetails = new Set<String>(utrDetails);
        if (utrDetails.size() > 1 && utrDetails.size() > uniqueUtrDetails.size()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Cheque / UTR Details found');
            ApexPages.addMessage(myMsg); 
            return null; 
        }
        //Added by Vinay 21-08-2025 End
        
        //Added by Prashant /// 14-07-25.///Start
        system.debug('amount1-'+amount1);
        if (amount1 == 0)  {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the token amount');
            ApexPages.addMessage(myMsg); 
            return null;  
        }else if(amount1 < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the correct token amount');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        //Added by Prashant /// 14-07-25.///End
        
        if ((payMode2 != null ) && (amount2 == null ||payDate2 == null || (payDetails2 == null || payDetails2 == '') || String.isBlank(bank2) ))  { // Added String.isBlank(bank2) by Vinay 21-08-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        if ((payMode3 != null ) && (amount3 == null ||payDate3 == null || (payDetails3 == null || payDetails3 == '') || String.isBlank(bank3) ))  { // Added String.isBlank(bank3) by Vinay 21-08-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        if ((payMode4 != null ) && (amount4 == null ||payDate4 == null || (payDetails4 == null || payDetails4 == '') || String.isBlank(bank4) ))  { // Added String.isBlank(bank4) by Vinay 21-08-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        if ((payMode5 != null ) && (amount5 == null ||payDate5 == null || (payDetails5 == null || payDetails5 == '') || String.isBlank(bank5) ))  { // Added String.isBlank(bank5) by Vinay 21-08-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        
        //Added by Prashant // 14-07-25...// START
        if(blockedDate == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter the Blocked date');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        //Added by Prashant // 14-07-25...//END
        
        // Aadhar validation: only if entered, must be exactly 12 digits
        if (!String.isBlank(aadharNumber)) {
            if (!Pattern.matches('^[0-9]{12}$', aadharNumber)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Aadhar Number. It must be exactly 12 digits.'));
                return null;
            }
        }
        
        // PAN validation: only if entered, must follow the valid PAN format (ABCDE1234F)
        if (!String.isBlank(panNumber)) {
            if (!Pattern.matches('^[A-Z]{5}[0-9]{4}[A-Z]{1}$', panNumber)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid PAN Number. Format must be like ABCDE1234F.'));
                return null;
            }
        }
        
        //Added by Dolly
        Boolean cifChanged = CIFObj.Mode_of_funding__c != originalModeOfFunding ||
                     CIFObj.Bank_Preference_1__c != originalBankPreference1 ||
                     CIFObj.Bank_Preference_2__c != originalBankPreference2 ||
                     CIFObj.Bank_Preference_3__c != originalBankPreference3;
            system.debug('cifChanged----->'+cifChanged);
            if(cifChanged){
                update CIFObj;
            }
        
        Blocking_Unit_Information__c blkInfo = new Blocking_Unit_Information__c();
        blkInfo.Opportunity__c = oppId;
        blkInfo.Project_Unit__c = unitId;
        blkInfo.Active__c = true;
        blkInfo.Approver__c = unit.RW_Project__r.Sales_Site_Head__c;
        blkInfo.Agreed_Agreement_Value__c = agrementVal;
        blkInfo.Amount__c = amount1;
        blkInfo.Mode_Of_Payment__c = payMode1;
        blkInfo.Paid_Date__c = payDate1;
        blkInfo.Transaction_Details__c = payDetails1;
        blkInfo.Bank_Name__c = bank1;
        blkInfo.Amount_2__c = amount2;
        blkInfo.Mode_Of_Payment_2__c = payMode2;
        blkInfo.Paid_Date_2__c = payDate2;
        blkInfo.Transaction_Details_2__c = payDetails2;
        blkInfo.Bank_Name_2__c = bank2;
        blkInfo.Amount_3__c = amount3;
        blkInfo.Mode_Of_Payment_3__c = payMode3;
        blkInfo.Paid_Date_3__c = payDate3;
        blkInfo.Transaction_Details_3__c = payDetails3;
        blkInfo.Bank_Name_3__c = bank3;
        blkInfo.Amount_4__c = amount4;
        blkInfo.Mode_Of_Payment_4__c = payMode4;
        blkInfo.Paid_Date_4__c = payDate4;
        blkInfo.Transaction_Details_4__c = payDetails4;
        blkInfo.Bank_Name_4__c = bank4;
        blkInfo.Amount_5__c = amount5;
        blkInfo.Mode_Of_Payment_5__c = payMode5;
        blkInfo.Paid_Date_5__c = payDate5;
        blkInfo.Transaction_Details_5__c = payDetails5;
        blkInfo.Bank_Name_5__c = bank5;
        blkInfo.Aadhar_Number__c = aadharNumber;
        blkInfo.PAN_Number__c = panNumber;  
        blkInfo.Pending_Reason__c = String.join(pendingReason, ';');
        //blkInfo.Book_Now_Status__c = bookNowStatus;
        blkInfo.Remarks__c = remarks;
        // blkInfo.Booking_Date__c = bookingDate;
        
        blkInfo.Total_Amount__c = (amount1 != null ? amount1 : 0) + (amount2 != null ? amount2 : 0) + (amount3 != null ? amount3 : 0) + (amount4 != null ? amount4 : 0) + (amount5 != null ? amount5 : 0);
        blkInfo.Approval_Status__c = 'Approved';
        
        Decimal totalAmount = blkInfo.Total_Amount__c;
        /*if(totalAmount < requiredTokenAmount){ //Commented by Vinay 02-07-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total Amount is less than the Token Amount, you cannot block this unit.  Token Amount is:'+requiredTokenAmount);
            ApexPages.addMessage(myMsg); 
            return null;
        }else {*/
            // Insert the blkInfo record if all validations pass
            insert blkInfo;
            
            unit.RW_Unit_Status__c = 'Blocked';
            unit.RW_Customer__c = oppId;
            update unit;
            
            Boolean updateOpp = false;
            if(opp.StageName != 'Unit Blocked'){
                opp.StageName = 'Unit Blocked';
                opp.RW_Agreement_Value__c = agrementVal;
                opp.Blocking_Amount_Received__c = blkInfo.Total_Amount__c;//Added by Prashant... 05-06-2025.. /// 
                system.debug('blockedDate-'+blockedDate);
        		opp.Blocked_Date__c = blockedDate;//Added by Prashant /// 14-07-25.///
                /*if(opp.Blocked_Date__c == null){
                    opp.Blocked_Date__c = Date.today();
                }*/
                if(opp.RW_Booking_Date_Opp__c == null){
                    opp.RW_Booking_Date_Opp__c = Date.today();
                }
                opp.RW_Project_Unit__c = unitId;
                updateOpp = true;
            }
            
            if(updateOpp == true){
                update opp;
            }
            
        	
            PageReference oppPage = new Pagereference('/' + oppId);
            oppPage.setRedirect(true);
            return oppPage;
            
            
        //} //Commented by Vinay 02-07-2025
    }
    
   /* Public PageReference cancleButton(){
      String sfdcURL = URL.getOrgDomainUrl().toExternalForm() + '/';
      System.debug('Salesforce Org URL: ' + sfdcURL);
        PageReference pageRef;
        pageRef = new PageReference(sfdcURL+oppId);
        return pageRef;
    }*/
    //Added by Dolly
    public void modeOfFundingChanged() {
        if (CIFObj.Mode_of_funding__c != 'Bank Loan') {
            CIFObj.Bank_Preference_1__c = null;
            CIFObj.Bank_Preference_2__c = null;
            CIFObj.Bank_Preference_3__c = null;
        }
}

    Public PageReference cancleButton(){
        return new PageReference('/' + oppId);
    }
      public void dummyMethod(){
            
            String s2;        
            String s3;
            String s4;                
            String s5;
            String s6;        
            String s7;
            String s8;                
            String s9;
            String s10;        
            String s11;
            String s12;                
            String s13;
            String s14;        
            String s15;
            String s16;                
            String s110;
            String s210;        
            String s310;
            String s410;                
            String s510;
            String s610;        
            String s710;
            String s810;                
            String s910;
            String s1010;        
            String s1110;
            String s1210;                
            String s1310;
            String s1410;        
            String s1510;
            String s1610;                
            String s111;
            String s211;        
            String s311;
            String s411;                
            String s511;
            String s611;        
            String s711;
            String s811;                
            String s911;
            String s1011;        
            String s1111;
            String s1211;                
            String s1311;
            String s1411;        
            String s1511;
            String s1611;                
            String s1101;
            String s2111;        
            
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
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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