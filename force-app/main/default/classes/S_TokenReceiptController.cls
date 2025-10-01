public with sharing class S_TokenReceiptController {

    public Id oppId {
        get;
        set;
    }
    public boolean error {
        get;
        set;
    }
    public Receipt__c r {
        get;
        set;
    }
    public String instrumentType {
        get;
        set;
    }
    public List < SelectOption > entityOptions {
        get;
        set;
    }
    public String entitySelected {
        get;
        set;
    }
    public List < Opportunity > oppList {
        get;
        set;
    }
    public boolean onlyToken {
        get;
        set;
    }
    public boolean foreignCurrency {
        get;
        set;
    }
    public boolean receiptSaved {
        get;
        set;
    }
    public boolean debug {
        get;
        set;
    }
    public String unitHeld {
        get;
        set;
    }
    public Boolean unitPresent {
        get;
        set;
    }
    public String address {
        get;
        set;
    }
    public S_TokenReceiptController() {
        r = new Receipt__c();
        error = false;
        oppId = null;
        receiptSaved = false;
        unitHeld = '';
        unitPresent = false;
        foreignCurrency = false;
        debug = false;
        if (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') {
            oppId = ApexPages.currentPage().getParameters().get('id');
        }

    }
    public Pagereference validate() {
        if (oppId == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please navigate from the Opportunity page to create a token amount receipt'));
            error = true;
            return null;
        }
        getCustomerDetails();
        return null;
    }
    public void selectInstrument() {
        error = false;
        if (r.mode__c.equalsIgnoreCase('Cheque') ||
            r.mode__c.equalsIgnoreCase('DD/Pay Order') ||
            r.mode__c.equalsIgnoreCase('EFT')
        ) {
            instrumentType = 'ins1';
            error = false;
        } else if (r.mode__c.equalsIgnoreCase('TDS')) {
            instrumentType = 'ins2';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Instrument type selection not valid for token amount receipt'));
            r.mode__c = '';
            error = true;
        } else {}
        r.Receipt_Date__c = system.today();
        getEntityDetails();
    }
    public list < SelectOption > holdOptions {
        get {
            list < SelectOption > optionList = new list < SelectOption > ();
            optionList.add(new SelectOption('YES', 'YES'));
            optionList.add(new SelectOption('NO', 'NO'));
            return optionList;
        }
        set;
    }
    public void unitHoldAction() {
        error = false;
        if (unitHeld == 'YES') {
            List < Project_Unit__c > uList = [Select Id, RW_Unit_Status__c from Project_Unit__c
                where Id = : r.Project_Unit__c
                and RW_Project__c = : oppList[0].RW_Project__c
            ];
            if (uList != null && uList.size() > 0 && !uList[0].RW_Unit_Status__c.equalsIgnoreCase('Available')) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Unit Selection, select an Available unit to generate token amount receipt'));
                r.Project_Unit__c = null;
                unitHeld = '';
                error = true;
            } else if (uList == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Unit Selection, this unit is not a valid selection for ' + oppList[0].RW_Project__r.Name));
                r.Project_Unit__c = null;
                unitHeld = '';
                error = true;
            } else {

            }
        } else {

        }
    }
    public void getEntityDetails() {
        entityOptions = new List < SelectOption > ();
        Legal_Entity__c le;
        if (r.Project_Unit__c != null)
            le = InventoryCostServices.getLegalEntityDetails(r.Project_Unit__c, r.Project__c);
        else
            le = InventoryCostServices.getLegalEntityDetails(null, r.Project__c);
        entityOptions.add(new SelectOption('', '--None--'));
        if (le != null && le.Account_Name_Flat_Cost__c != null) {
           entityOptions.add(new SelectOption('Flat Cost |' + le.Account_Name_Flat_Cost__c + '|' + le.Bank_Name_Flat_Cost__c + '|' + le.Account_Number_Flat_Cost__c, 'Flat Cost |' + le.Account_Name_Flat_Cost__c + '|' + le.Bank_Name_Flat_Cost__c + '|' + le.Account_Number_Flat_Cost__c));
        }
        if (le != null && le.Account_Name_Service_Tax__c != null) {
           entityOptions.add(new SelectOption('Service Tax |' + le.Account_Name_Service_Tax__c + '|' + le.Bank_Name_Service_tax__c + '|' + le.Account_Number_Service_tax__c, 'Service Tax |' + le.Account_Name_Service_Tax__c + '|' + le.Bank_Name_Service_tax__c + '|' + le.Account_Number_Service_tax__c));
        }
    }

    public void getCustomerDetails() {
        error = false;
        oppList = [Select Name, Id, StageName, Account.Salutation, Account.Name, Account.PersonEmail, Account.PersonMobilePhone,
            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
            /*Total_Interest__c,*/ Primary_Name__c, Other_Applicants_Name__c,
            /*Future_Correspondence_Contact__c, Future_Correspondence_Contact_Name__c,*/ RW_Email__c,
            /*Future_Correspondence_Contact_Email__c,*/ Account.RW_Email__c, Other_Applicants_Email__c,
            /*Total_Interest_Settled__c,Total_Waiver__c, Total_Interest_Waiver__c,*/ RW_Project__c, RW_Project_Unit__c,
             RW_Project__r.Cheque_Dishonour__c, RW_Project__r.Name,Account.Mobile_No__c,
            Primary_pancard__c, Other_Applicants_Pancard__c
            from Opportunity where Id = : oppId and RW_Opportunity_Status__c = 'Active'
        ]; // Account.BillingAddress,
        
        if (oppList.size() == 1 && (String.isBlank(oppList[0].Account.PersonEmail) || String.isBlank(oppList[0].Account.Mobile_No__c) )) { //|| String.isBlank(string.valueOf(oppList[0].Account.BillingAddress))
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please ensure the email address, mobile phone and address information is populated at the account level'));
        } else if (oppList.size() == 1 && !oppList[0].stageName.equalsIgnoreCase('Booking Confirmed')) {
            onlyToken = true;
            r.Project__c = oppList[0].RW_Project__c;
            r.Opportunity__c = oppList[0].Id;
            if ((oppList[0].Account.BillingStreet != null) && (oppList[0].Account.BillingStreet).length() > 0)
                address = oppList[0].Account.BillingStreet + ', ';
            if ((oppList[0].Account.BillingCity != null) && (oppList[0].Account.BillingCity).length() > 0)
                address += oppList[0].Account.BillingCity + ', ';
            if ((oppList[0].Account.BillingState != null) && (oppList[0].Account.BillingState).length() > 0)
                address += oppList[0].Account.BillingState + ', ';
            if ((oppList[0].Account.BillingCountry != null) && (oppList[0].Account.BillingCountry).length() > 0)
                address += oppList[0].Account.BillingCountry + ', ';
            if ((oppList[0].Account.BillingPostalCode != null) && (oppList[0].Account.BillingPostalCode).length() > 0)
                address += oppList[0].Account.BillingPostalCode;

            if (oppList[0].RW_Project_Unit__c != null) {
                r.Project_Unit__c = oppList[0].RW_Project_Unit__c;
                unitPresent = true;
            }

        } else {
            error = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Token Receipt cannot be created against this opportunity'));
        }

    }

    public PageReference saveReceipt() {
        System.debug('Save receipt:');
        error = false;
        if (r.mode__c.equalsIgnoreCase('Cheque') ||
            r.mode__c.equalsIgnoreCase('DD/Pay Order')) {
            if (r.Cheque_DD_Date__c < system.today().addDays(-90) || r.Cheque_DD_Date__c > system.today().addDays(1)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Instrument date has to be between 90 days ago from today to 1 day ahead of today'));
                error = true;
                return null;
            }
        }
        if (r.mode__c.equalsIgnoreCase('EFT')) {
            if (r.Cheque_DD_Date__c > system.today()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Instrument date cannot be a future date'));
                error = true;
                return null;
            }
        }


        Id rId;
        Receipt__c rt = new Receipt__c();
        rt = r;
        rt.Receipt_Status__c = 'UnProcessed';
        rt.On_Account_Money__c = r.Amount_Rs__c;
        rt.Total_Amount__c = r.Amount_Rs__c;
        rt.Cheque_DD_Amount_Rs__c = r.Amount_Rs__c;
        rt.Drawn_In_Favour_Of__c = entitySelected;
        if (foreignCurrency) {
            rt.Amount_in_Foreign_Currency__c = rt.Total_Amount__c;
            rt.Foreign_Currency_Type__c = rt.Currency__c;
        }
        if (oppList[0].Account.RW_Email__c != null) {
            //oppList[0].Primary_Email__c = oppList[0].Account.RW_Email__c;
            if (String.isBlank(rt.Opportunity_Email_Id__c))
                rt.Opportunity_Email_Id__c = oppList[0].Account.PersonEmail;
        }
        if (oppList[0].Account.PersonMobilePhone != null)
            oppList[0].Primary_Phone__c = oppList[0].Account.PersonMobilePhone;
        if (address != null) {
            oppList[0].Mailing_Address__c = address;
            oppList[0].Permanent_Address__c = address;
        }
        if (oppList[0].Account.Name != null) {
            oppList[0].Primary_Name__c = oppList[0].Account.Salutation + oppList[0].Account.Name;
        }

        List < String > sList = rt.Drawn_in_favour_of__c.split('\\|');
        System.debug(sList);
        System.debug(sList[0]);
        if (sList[0].equals('Service Tax '))
            rt.Token_Amount_ST__c = true;

        if (sList[0].equals('Flat Cost '))
            rt.Token_Amount_Receipt__c = true;

        if (r.Project_Unit__c != null)
            oppList[0].RW_Project_Unit__c = r.Project_Unit__c;
        try {
            Database.SaveResult r = Database.insert(rt);
            if (r.isSuccess())
                rId = r.getId();
            Database.upsertResult o = Database.upsert(oppList[0]);
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        receiptSaved = true;
        return null;
    }

}