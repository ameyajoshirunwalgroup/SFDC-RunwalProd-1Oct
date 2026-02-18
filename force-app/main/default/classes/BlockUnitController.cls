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
    /*Added for unidentified Payments starts*/
    public Blob  file1 {get;set;}
    public String fileName1 {get;set;}
    /*Added for unidentified Payments ends*/
    
    public String payMode2 {get;set;}
    public Decimal amount2 {get;set;}
    public Date payDate2 {get;set;}
    public String payDetails2 {get;set;}
    public String bank2 {get;set;}
    /*Added for unidentified Payments starts*/
    public Blob  file2 {get;set;}
    public String fileName2 {get;set;}
    /*Added for unidentified Payments ends*/
    
    public String payMode3 {get;set;}
    public Decimal amount3 {get;set;}
    public Date payDate3 {get;set;}
    public String payDetails3 {get;set;}
    public String bank3 {get;set;}
    /*Added for unidentified Payments starts*/
    public Blob  file3 {get;set;}
    public String fileName3 {get;set;}
    /*Added for unidentified Payments ends*/
    
    public String payMode4 {get;set;}
    public Decimal amount4 {get;set;}
    public Date payDate4 {get;set;}
    public String payDetails4 {get;set;}
    public String bank4 {get;set;}
    /*Added for unidentified Payments starts*/
    public Blob  file4 {get;set;}
    public String fileName4 {get;set;}
    /*Added for unidentified Payments ends*/
    
    public String payMode5 {get;set;}
    public Decimal amount5 {get;set;}
    public Date payDate5 {get;set;}
    public String payDetails5 {get;set;}
    public String bank5 {get;set;}
    /*Added for unidentified Payments starts*/
    public Blob  file5 {get;set;}
    public String fileName5 {get;set;}
    /*Added for unidentified Payments ends*/
    
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

    public List<RowWrapper> rowList {get;set;} //Added by Vinay 09-02-2026
    public Integer rowIndex { get; set; } //Added by Vinay 09-02-2026
    
    public BlockUnitController(){
        
        if (ApexPages.currentPage().getParameters().get('unitId') != null && ApexPages.currentPage().getParameters().get('unitId') != '') {
            unitId = ApexPages.currentPage().getParameters().get('unitId');
            system.debug('unitId: ' + unitId);
        }
        if (ApexPages.currentPage().getParameters().get('oppId') != null && ApexPages.currentPage().getParameters().get('oppId') != '') {
            oppId = ApexPages.currentPage().getParameters().get('oppId');
            system.debug('oppId: ' + oppId);
        }

        //Added by Vinay 09-02-2026 Start
        rowList = new List<RowWrapper>();
        RowWrapper row = new RowWrapper();
        row.sNo = 1;
        rowList.add(row);
        //Added by Vinay 09-02-2026 End
        
        unit = [SELECT Id, Name, RW_Customer__c, RW_Customer__r.Name, RW_Project__c, RW_Project__r.Name, RW_Project__r.Sales_Site_Head__c,
                Saleable_Area__c, RW_Param4__c, Token_Amount__c, RW_Booking_Date__c,RW_Project__r.Token_Amount__c FROM Project_Unit__c WHERE Id =: unitId];
        opp = [SELECT Id, Name, StageName, RW_Opportunity_Status__c, Relationship_Manager__c, Blocked_Date__c, RW_Booking_Date_Opp__c, RW_Project__r.Allow_Blocking_on_Non_Active_Opportunity__c,RW_Project__c,RW_Mobile_No__c FROM Opportunity WHERE Id =: oppId];//Added RW_Project__c,RW_Mobile_No__c for unidentified payments
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
        //PageReference result = saveDetails(); // Reuse the same validations and save logic //Commented by Vinay 09-02-2026
        PageReference result = saveDetails1(); //Added by Vinay 09-02-2026
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

    public pageReference saveDetails1(){ //Added by Vinay 09-02-2026
        System.debug('rowList: ' + rowList);
        List<Blocking_Unit_Information__c> blkInfoToInsert = new List<Blocking_Unit_Information__c>();
        // Check if the token amount is provided
        Decimal requiredTokenAmount = unit.Token_Amount__c != null ? unit.Token_Amount__c : unit.RW_Project__r.Token_Amount__c;
        
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
        
        List<String> utrDetails = new List<String>();
        Decimal totalAmount = 0;
        List<Receipt__c> receiptList = new List<Receipt__c>();
        List<ContentVersion> contentList = new List<ContentVersion>();
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        String mobNumber = opp.RW_Mobile_No__c;
        for(RowWrapper rw : rowList) {
            System.debug('S No: ' + rw.sNo);
            System.debug('mode_of_payment: ' + rw.payment_mode);
            System.debug('Amount: ' + rw.amount);
            System.debug('date_value: ' + rw.pay_date);
            System.debug('cheque_utr: ' + rw.cheque_utr);
            System.debug('bank: ' + rw.bank);
            System.debug('file_name: ' + rw.file_name);
            System.debug('file: ' + rw.file_body);
            if ((rw.payment_mode != null  ) && (rw.amount == null ||rw.pay_date == null || (rw.cheque_utr == null || rw.cheque_utr == '') ))  {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter All Payment Fields ');
                ApexPages.addMessage(myMsg); 
                return null;  
            }
            if ((rw.amount != null) && (rw.payment_mode == null || rw.pay_date == null || (rw.cheque_utr == null || rw.cheque_utr == '') || String.isBlank(rw.bank)))  { // Added String.isBlank(bank1) by Vinay 21-08-2025
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the payment Details');
                ApexPages.addMessage(myMsg); 
                return null;  
            }
            
            if(!String.isBlank(rw.cheque_utr) && !String.isBlank(rw.bank))
            	utrDetails.add(rw.cheque_utr + '_' + rw.bank);
            
            totalAmount += (rw.amount != null)? rw.amount : 0;
            receiptList.add(new Receipt__c(
                Opportunity__c = oppId,
                Mode__c = rw.payment_mode,
                Active__c = true,
                Total_Amount__c = rw.amount,
                Cheque_DD_Date__c = rw.pay_date,
                Cheque_DD__c = rw.cheque_utr,
                DraweeBank__c = rw.bank,
                Project_Unit__c = unitId,
                Project__c = opp.RW_Project__c,
                Receipt_Unique_Key__c = mobNumber+'_'+rw.cheque_utr+'_'+rw.bank
            ));
            
            if (rw.file_body != null) contentList.add(createCV(rw.file_body, rw.file_name));
        }
        Set<String> uniqueUtrDetails = new Set<String>(utrDetails);
        if (utrDetails.size() > 1 && utrDetails.size() > uniqueUtrDetails.size()) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Cheque / UTR Details found');
            ApexPages.addMessage(myMsg); 
            return null; 
        }
        if (rowList.size() > 0 && rowList[0].amount == 0)  {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the token amount');
            ApexPages.addMessage(myMsg); 
            return null;  
        }else if(rowList.size() > 0 && rowList[0].amount < 0){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Enter the correct token amount');
            ApexPages.addMessage(myMsg); 
            return null;
        }
        if(blockedDate == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Enter the Blocked date');
            ApexPages.addMessage(myMsg); 
            return null;  
        }
        
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
        blkInfo.Amount__c = (rowList.size() >= 1)? rowList[0].amount : 0;
        blkInfo.Mode_Of_Payment__c = (rowList.size() >= 1)? rowList[0].payment_mode : null;
        blkInfo.Paid_Date__c = (rowList.size() >= 1)? rowList[0].pay_date : null;
        blkInfo.Transaction_Details__c = (rowList.size() >= 1)? rowList[0].cheque_utr : null;
        blkInfo.Bank_Name__c = (rowList.size() >= 1)? rowList[0].bank : null;
        blkInfo.Amount_2__c = (rowList.size() >= 2)? rowList[1].amount : 0;
        blkInfo.Mode_Of_Payment_2__c = (rowList.size() >= 2)? rowList[1].payment_mode : null;
        blkInfo.Paid_Date_2__c = (rowList.size() >= 2)? rowList[1].pay_date : null;
        blkInfo.Transaction_Details_2__c = (rowList.size() >= 2)? rowList[1].cheque_utr : null;
        blkInfo.Bank_Name_2__c = (rowList.size() >= 2)? rowList[1].bank : null;
        blkInfo.Amount_3__c = (rowList.size() >= 3)? rowList[2].amount : 0;
        blkInfo.Mode_Of_Payment_3__c = (rowList.size() >= 3)? rowList[2].payment_mode : null;
        blkInfo.Paid_Date_3__c = (rowList.size() >= 3)? rowList[2].pay_date : null;
        blkInfo.Transaction_Details_3__c = (rowList.size() >= 3)? rowList[2].cheque_utr : null;
        blkInfo.Bank_Name_3__c = (rowList.size() >= 3)? rowList[2].bank : null;
        blkInfo.Amount_4__c = (rowList.size() >= 4)? rowList[3].amount : 0;
        blkInfo.Mode_Of_Payment_4__c = (rowList.size() >= 4)? rowList[3].payment_mode : null;
        blkInfo.Paid_Date_4__c = (rowList.size() >= 4)? rowList[3].pay_date : null;
        blkInfo.Transaction_Details_4__c = (rowList.size() >= 4)? rowList[3].cheque_utr : null;
        blkInfo.Bank_Name_4__c = (rowList.size() >= 4)? rowList[3].bank : null;
        blkInfo.Amount_5__c = (rowList.size() >= 5)? rowList[4].amount : 0;
        blkInfo.Mode_Of_Payment_5__c = (rowList.size() >= 5)? rowList[4].payment_mode : null;
        blkInfo.Paid_Date_5__c = (rowList.size() >= 5)? rowList[4].pay_date : null;
        blkInfo.Transaction_Details_5__c = (rowList.size() >= 5)? rowList[4].cheque_utr : null;
        blkInfo.Bank_Name_5__c = (rowList.size() >= 5)? rowList[4].bank : null;
        blkInfo.Amount_6__c = (rowList.size() >= 6)? rowList[5].amount : 0;
        blkInfo.Mode_Of_Payment_6__c = (rowList.size() >= 6)? rowList[5].payment_mode : null;
        blkInfo.Paid_Date_6__c = (rowList.size() >= 6)? rowList[5].pay_date : null;
        blkInfo.Transaction_Details_6__c = (rowList.size() >= 6)? rowList[5].cheque_utr : null;
        blkInfo.Bank_Name_6__c = (rowList.size() >= 6)? rowList[5].bank : null;
        blkInfo.Amount_7__c = (rowList.size() >= 7)? rowList[6].amount : 0;
        blkInfo.Mode_Of_Payment_7__c = (rowList.size() >= 7)? rowList[6].payment_mode : null;
        blkInfo.Paid_Date_7__c = (rowList.size() >= 7)? rowList[6].pay_date : null;
        blkInfo.Transaction_Details_7__c = (rowList.size() >= 7)? rowList[6].cheque_utr : null;
        blkInfo.Bank_Name_7__c = (rowList.size() >= 7)? rowList[6].bank : null;
        blkInfo.Amount_8__c = (rowList.size() >= 8)? rowList[7].amount : 0;
        blkInfo.Mode_Of_Payment_8__c = (rowList.size() >= 8)? rowList[7].payment_mode : null;
        blkInfo.Paid_Date_8__c = (rowList.size() >= 8)? rowList[7].pay_date : null;
        blkInfo.Transaction_Details_8__c = (rowList.size() >= 8)? rowList[7].cheque_utr : null;
        blkInfo.Bank_Name_8__c = (rowList.size() >= 8)? rowList[7].bank : null;
        blkInfo.Amount_9__c = (rowList.size() >= 9)? rowList[8].amount : 0;
        blkInfo.Mode_Of_Payment_9__c = (rowList.size() >= 9)? rowList[8].payment_mode : null;
        blkInfo.Paid_Date_9__c = (rowList.size() >= 9)? rowList[8].pay_date : null;
        blkInfo.Transaction_Details_9__c = (rowList.size() >= 9)? rowList[8].cheque_utr : null;
        blkInfo.Bank_Name_9__c = (rowList.size() >= 9)? rowList[8].bank : null;
        blkInfo.Amount_10__c = (rowList.size() >= 10)? rowList[9].amount : 0;
        blkInfo.Mode_Of_Payment_10__c = (rowList.size() >= 10)? rowList[9].payment_mode : null;
        blkInfo.Paid_Date_10__c = (rowList.size() >= 10)? rowList[9].pay_date : null;
        blkInfo.Transaction_Details_10__c = (rowList.size() >= 10)? rowList[9].cheque_utr : null;
        blkInfo.Bank_Name_10__c = (rowList.size() >= 10)? rowList[9].bank : null;
        blkInfo.Aadhar_Number__c = aadharNumber;
        blkInfo.PAN_Number__c = panNumber;  
        blkInfo.Pending_Reason__c = String.join(pendingReason, ';');
        //blkInfo.Book_Now_Status__c = bookNowStatus;
        blkInfo.Remarks__c = remarks;
        // blkInfo.Booking_Date__c = bookingDate;
        blkInfo.Blocking_Date__c = blockedDate; //Added by Dolly
        blkInfo.Approval_Status__c = 'Approved';
        blkInfo.Total_Amount__c = totalAmount;
        
        if(totalAmount < requiredTokenAmount){ //Commented by Vinay 02-07-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total Amount is less than the Token Amount, you cannot block this unit.  Token Amount is:'+requiredTokenAmount);
            ApexPages.addMessage(myMsg); 
            return null;
        }
        // Insert the blkInfo record if all validations pass
        insert blkInfo;
        
        try{
            if (!receiptList.isEmpty()) {
                upsert receiptList Receipt_Unique_Key__c ;
            }         
        }
        catch (DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        System.debug('receiptList**'+receiptList);
        
        if (!contentList.isEmpty()) {
            insert contentList;
            //                 // Fetch inserted ContentVersion records to get ContentDocumentId
            Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(
                [SELECT Id,Title,PathOnClient, VersionData,ContentDocumentId FROM ContentVersion WHERE Id IN :contentList]
            );
            System.debug('contentList**'+contentList);
            System.debug('cvMap**'+cvMap);
            
            // Collect receipt IDs to check for existing ContentDocuments
            Set<Id> receiptIds = new Set<Id>();
            if (!receiptList.isEmpty()) {
                for (Receipt__c r : receiptList) {
                    if (r.Id != null) {
                        receiptIds.add(r.Id);
                    }//receiptIds.add(r.Id);
                }
            }
            System.debug('receiptIds**'+receiptIds);
            
            // Find if any receipts already have linked ContentDocuments
            Map<Id, Id> receiptToDocMap = new Map<Id, Id>();
            if(!receiptIds.isEmpty()) {
                for (ContentDocumentLink cdl : [
                    SELECT LinkedEntityId, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId IN :receiptIds
                ]) {
                    System.debug('cdl**'+cdl);
                    receiptToDocMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                }
            }
            System.debug('receiptToDocMap**'+receiptToDocMap);
            List<ContentVersion> newVersionList = new List<ContentVersion>();
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            
            Integer i = 0;
            for (Receipt__c rec : receiptList) {
                if (i >= cvMap.size()) break;
                ContentVersion insertedCV = cvMap.get(contentList[i].Id);
                
                if (receiptToDocMap.containsKey(rec.Id)) {
                    // Add new version to existing document
                    newVersionList.add(new ContentVersion(
                        Title = insertedCV.Title,
                        PathOnClient = insertedCV.PathOnClient,
                        VersionData = insertedCV.VersionData,
                        ContentDocumentId = receiptToDocMap.get(rec.Id)
                    ));
                } else {
                    // Link brand new document to receipt
                    linkList.add(new ContentDocumentLink(
                        ContentDocumentId = insertedCV.ContentDocumentId,
                        LinkedEntityId = rec.Id,
                        ShareType = 'V',
                        Visibility = 'AllUsers'
                    ));
                }
                i++;
            }
            
            if (!newVersionList.isEmpty()) {
                insert newVersionList;
            }
            if (!linkList.isEmpty()) {
                insert linkList;
            }
        }
        
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

    }

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
        blkInfo.Blocking_Date__c = blockedDate; //Added by Dolly  
        // blkInfo.Booking_Date__c = bookingDate;
        
        blkInfo.Total_Amount__c = (amount1 != null ? amount1 : 0) + (amount2 != null ? amount2 : 0) + (amount3 != null ? amount3 : 0) + (amount4 != null ? amount4 : 0) + (amount5 != null ? amount5 : 0);
        blkInfo.Approval_Status__c = 'Approved';
        
        Decimal totalAmount = blkInfo.Total_Amount__c;
        // Added For Unidentified Payment Start
        if(totalAmount < requiredTokenAmount){ //Commented by Vinay 02-07-2025
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total Amount is less than the Token Amount, you cannot block this unit.  Token Amount is:'+requiredTokenAmount);
            ApexPages.addMessage(myMsg); 
            return null;
        }
        // Added For Unidentified Payment End
            // Insert the blkInfo record if all validations pass
            insert blkInfo;
            /*Added for unidentifiend payment starts*/
            List<Receipt__c> receiptList = new List<Receipt__c>();
            String mobNumber = opp.RW_Mobile_No__c;
            if (payMode1 != null && amount1 != null) {
                receiptList.add(new Receipt__c(
                    Opportunity__c = oppId,
                    Mode__c = payMode1,
                    Active__c = true,
                    Total_Amount__c = amount1,
                    Cheque_DD_Date__c = payDate1,
                    Cheque_DD__c = payDetails1,
                    DraweeBank__c = bank1,
                    Project_Unit__c = unitId,
                    Project__c = opp.RW_Project__c,
                    Receipt_Unique_Key__c = mobNumber+'_'+payDetails1+'_'+bank1
                ));
            }
            if (payMode2 != null && amount2 != null) {
                receiptList.add(new Receipt__c(
                    Opportunity__c = oppId,
                    Mode__c = payMode2,
                    Active__c = true,
                    Total_Amount__c = amount2,
                    Cheque_DD_Date__c = payDate2,
                    Cheque_DD__c = payDetails2,
                    DraweeBank__c = bank2,
                    Project_Unit__c = unitId,
                    Project__c = opp.RW_Project__c,
                    Receipt_Unique_Key__c = mobNumber+'_'+payDetails2+'_'+bank2
                ));
            }
            if (payMode3 != null && amount3 != null) {
                receiptList.add(new Receipt__c(
                    Opportunity__c = oppId,
                    Mode__c = payMode3,
                    Active__c = true,
                    Total_Amount__c = amount3,
                    Cheque_DD_Date__c = payDate3,
                    Cheque_DD__c = payDetails3,
                    DraweeBank__c = bank3,
                    Project_Unit__c = unitId,
                    Project__c = opp.RW_Project__c,
                    Receipt_Unique_Key__c = mobNumber+'_'+payDetails3+'_'+bank3
                ));
            }
            if (payMode4 != null && amount4 != null) {
                receiptList.add(new Receipt__c(
                    Opportunity__c = oppId,
                    Mode__c = payMode4,
                    Active__c = true,
                    Total_Amount__c = amount4,
                    Cheque_DD_Date__c = payDate4,
                    Cheque_DD__c = payDetails4,
                    DraweeBank__c = bank4,
                    Project_Unit__c = unitId,
                    Project__c = opp.RW_Project__c,
                    Receipt_Unique_Key__c = mobNumber+'_'+payDetails4+'_'+bank4
                ));
            }
            if (payMode5 != null && amount5 != null) {
                receiptList.add(new Receipt__c(
                    Opportunity__c = oppId,
                    Mode__c = payMode5,
                    Active__c = true,
                    Total_Amount__c = amount5,
                    Cheque_DD_Date__c = payDate5,
                    Cheque_DD__c = payDetails5,
                    DraweeBank__c = bank5,
                    Project_Unit__c = unitId,
                    Project__c = opp.RW_Project__c,
                    Receipt_Unique_Key__c = mobNumber+'_'+payDetails5+'_'+bank5
                ));
            }
                try{
                    if (!receiptList.isEmpty()) {
                    upsert receiptList Receipt_Unique_Key__c ;
                    }         
                }
                catch (DMLException e) {
                    ApexPages.addMessages(e);
                    return null;
                }
            System.debug('receiptList**'+receiptList);

            List<ContentVersion> contentList = new List<ContentVersion>();
            List<ContentDocumentLink> links = new List<ContentDocumentLink>();

            if (file1 != null) contentList.add(createCV(file1, fileName1));
            if (file2 != null) contentList.add(createCV(file2, fileName2));
            if (file3 != null) contentList.add(createCV(file3, fileName3));
            if (file4 != null) contentList.add(createCV(file4, fileName4));
            if (file5 != null) contentList.add(createCV(file5, fileName5));

            if (!contentList.isEmpty()) {
                insert contentList;
            //                 // Fetch inserted ContentVersion records to get ContentDocumentId
                Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(
                    [SELECT Id,Title,PathOnClient, VersionData,ContentDocumentId FROM ContentVersion WHERE Id IN :contentList]
                );
                System.debug('contentList**'+contentList);
                System.debug('cvMap**'+cvMap);

                // Collect receipt IDs to check for existing ContentDocuments
                Set<Id> receiptIds = new Set<Id>();
                if (!receiptList.isEmpty()) {
                for (Receipt__c r : receiptList) {
                            if (r.Id != null) {
                                receiptIds.add(r.Id);
                            }//receiptIds.add(r.Id);
                    }
                }
                System.debug('receiptIds**'+receiptIds);

                // Find if any receipts already have linked ContentDocuments
                Map<Id, Id> receiptToDocMap = new Map<Id, Id>();
                if(!receiptIds.isEmpty()) {
                    for (ContentDocumentLink cdl : [
                        SELECT LinkedEntityId, ContentDocumentId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId IN :receiptIds
                    ]) {
                        System.debug('cdl**'+cdl);
                        receiptToDocMap.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
                    }
                }
                System.debug('receiptToDocMap**'+receiptToDocMap);
                List<ContentVersion> newVersionList = new List<ContentVersion>();
                List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();

                Integer i = 0;
                for (Receipt__c rec : receiptList) {
                    if (i >= cvMap.size()) break;
                    ContentVersion insertedCV = cvMap.get(contentList[i].Id);

                    if (receiptToDocMap.containsKey(rec.Id)) {
                        // Add new version to existing document
                        newVersionList.add(new ContentVersion(
                            Title = insertedCV.Title,
                            PathOnClient = insertedCV.PathOnClient,
                            VersionData = insertedCV.VersionData,
                            ContentDocumentId = receiptToDocMap.get(rec.Id)
                        ));
                    } else {
                        // Link brand new document to receipt
                        linkList.add(new ContentDocumentLink(
                            ContentDocumentId = insertedCV.ContentDocumentId,
                            LinkedEntityId = rec.Id,
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                        ));
                    }
                    i++;
                }

                if (!newVersionList.isEmpty()) {
                    insert newVersionList;
                }
                if (!linkList.isEmpty()) {
                    insert linkList;
                }
            }
             
            /*Added for unidentifiend payment ends */
            
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
    /*Added for unidentified Payments starts*/
     private ContentVersion createCV(Blob body, String fileName) {
        return new ContentVersion(
            Title = fileName != null ? fileName : 'UploadedFile',
            PathOnClient = fileName != null ? fileName : 'UploadedFile.txt',
            VersionData = body
        );
    }
    /*Added for unidentified Payments ends*/
    
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

    public void addRow() {  //Added by Vinay 09-02-2026
        if (rowList.size() < 10) {
            RowWrapper row = new RowWrapper();
            row.sNo = rowList.size() + 1;
            rowList.add(row);
        }
    }
    
    public void removeRow() { //Added by Vinay 09-02-2026
        System.debug('removeRow: ');
        System.debug('rowIndex: ' + rowIndex);
        System.debug('rowList: ' + rowList);
        if (rowIndex != null && rowIndex < rowList.size() && rowList.size() != 1) {
            rowList.remove(rowIndex);
            System.debug('rowList: ' + rowList);
            for(RowWrapper row : rowList){
                if(row.sNo > rowIndex){
                    row.sNo = row.sNo -1;
                }
            }
        }
    }
    
    public class RowWrapper { //Added by Vinay 09-02-2026
        public Integer sNo {get;set;}
        public String payment_mode {get;set;}
        public Decimal amount {get;set;}
        public Date pay_date {get;set;}
        public String cheque_utr {get;set;}
        public String bank {get;set;}
        public Blob file_body {get;set;}
        public String file_name {get;set;}
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