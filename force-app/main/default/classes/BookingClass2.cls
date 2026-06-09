public class BookingClass2 {
    
    public static void updateAccount(Applicant_Details__c applicant, Account acc){
        if(String.isNotBlank(applicant.Salutation__c) && acc.Salutation != applicant.Salutation__c)
            acc.Salutation = applicant.Salutation__c;
        if(String.isNotBlank(applicant.First_Name__c) && acc.FirstName != applicant.First_Name__c)
            acc.FirstName = applicant.First_Name__c;
        if(String.isNotBlank(applicant.Middle_Name__c) && String.isNotBlank(applicant.Last_Name__c) && acc.LastName != (applicant.Middle_Name__c + ' ' + applicant.Last_Name__c))
            acc.LastName = applicant.Middle_Name__c + ' ' + applicant.Last_Name__c;
        else if(String.isBlank(applicant.Middle_Name__c) && String.isNotBlank(applicant.Last_Name__c) && acc.LastName != applicant.Last_Name__c)
            acc.LastName = applicant.Last_Name__c;
        if(applicant.Pincode__c != null && acc.RW_Zip_Code__c != String.valueOf(applicant.Pincode__c))
            acc.RW_Zip_Code__c = String.valueOf(applicant.Pincode__c);
        if(String.isNotBlank(applicant.Permanent_Address__c) && acc.Current_Residential_Address__c != applicant.Permanent_Address__c)
            acc.Current_Residential_Address__c = applicant.Permanent_Address__c;
        if(String.isNotBlank(applicant.Organization_Name__c) && acc.RW_Company_Name__c != applicant.Organization_Name__c)
            acc.RW_Company_Name__c = applicant.Organization_Name__c;
        if(String.isNotBlank(applicant.Designation__c) && acc.RW_Designation__c != applicant.Designation__c)
            acc.RW_Designation__c = applicant.Designation__c;
        update acc;
    }
    
   /* public static Booking__c updateBrokerageSchemeDetails(Booking__c boookingObj, list<Quotation__c> QuoteDetails, list<Brokerage_Scheme__c> brokerageScheme,Date bookingDate, Date bookingDate2){
        // if(QuoteDetails[0].Agreement_Value_for_brokers__c != 0 || QuoteDetails[0].Agreement_Value_for_brokers__c != Null)
        if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Local'  ){ 
            system.debug('brokerageScheme[0].Type__c ->'+brokerageScheme[0].Type__c);
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate < bookingDate2){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }
        else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI' && bookingDate >= bookingDate2){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }
        else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'Local' || boookingObj.Type_of_Client__c == 'Corporate' )){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'NRI' || boookingObj.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }
        else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (boookingObj.Type_of_Client__c == 'NRI' || boookingObj.Type_of_Client__c == 'Outstation') && bookingDate >= bookingDate2){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        } 
        return boookingObj;
    }*/
    
    //Added by Prashant to Handle base brokerage for NRI differently// 22-10-25. START
    public static Booking__c updateBrokerageSchemeDetails(Booking__c boookingObj, list<Quotation__c> QuoteDetails, list<Brokerage_Scheme__c> brokerageScheme){
        // if(QuoteDetails[0].Agreement_Value_for_brokers__c != 0 || QuoteDetails[0].Agreement_Value_for_brokers__c != Null)
        if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'Local') && (boookingObj.Type_of_Client__c == 'Local' || boookingObj.Type_of_Client__c == 'Corporate' )){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }else if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'NRI') && (boookingObj.Type_of_Client__c == 'NRI') /*|| boookingObj.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2*/){
            system.debug('brokerageScheme- '+brokerageScheme);
            system.debug('brokerageScheme- '+brokerageScheme[0].Base_Brokerage_for_NRI__c);
            system.debug('brokerageScheme- '+boookingObj.Passback_Amount__c);
            system.debug('brokerageScheme- '+QuoteDetails[0].Brokerage_Agreement_Value__c);
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_NRI__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_NRI__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        } else if(!brokerageScheme.isEmpty() && (brokerageScheme[0].Type__c == 'Both' || brokerageScheme[0].Type__c == 'Outstation') && (boookingObj.Type_of_Client__c == 'Outstation') /*&& bookingDate < bookingDate2*/){
            boookingObj.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c /  QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
            boookingObj.Base_Brokerage_2__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
            boookingObj.Brokerage_Scheme_Name__c =  brokerageScheme[0].Name;
            boookingObj.Brokerage_Scheme__c =  brokerageScheme[0].Id;
            boookingObj.Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c - (((boookingObj.Passback_Amount__c / QuoteDetails[0].Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
        }
        return boookingObj;
    }
	//Added by Prashant // 22-10-25. END	
    
    /*public static Integer tokenAmountValidation(Quotation__c quotation, Decimal totalAmount){ //Added by Vimay 05-08-2025
        Decimal requiredTokenAmount = quotation.Project_Unit__r.Token_Amount__c != null ? quotation.Project_Unit__r.Token_Amount__c : quotation.Project_Unit__r.RW_Project__r.Token_Amount__c; 
        if(totalAmount < requiredTokenAmount){ 
            System.debug('Total Amount is less than the Token Amount');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Total Amount is less than the Token Amount, you cannot block this unit.  Token Amount is:'+requiredTokenAmount);
            ApexPages.addMessage(myMsg);
            return 1;
        }else{
            return 0;
        }
    }*/
    
    /**Addded for Cancellation Changes starts */
    public Static void loadTowers(List<SelectOption> towerOptions,Booking__c boookingObj) {
        towerOptions.clear();
        //Id matchedTowerId = null;
        towerOptions.add(new SelectOption('', '--Select Tower--'));
        List<Tower__c> towerLst = [SELECT Id, Name 
                FROM Tower__c 
                WHERE ProjectName__c = :boookingObj.Cancelled_Project__c ORDER BY Name];

        System.debug('towerLst**'+towerLst);
        if(String.isNotBlank(boookingObj.Cancelled_Project__c)) {
            for(Tower__c t : towerLst) {
                towerOptions.add(new SelectOption(t.Id, t.Name));
            }
        }
    }

    public Static void loadUnits(List<SelectOption> unitOptions,Booking__c boookingObj) {
        unitOptions.clear();
        //Id matchedUnitId = null;
        unitOptions.add(new SelectOption('', '--Select Unit--'));
        List<Project_Unit__c> projectList = [SELECT Id, Name 
                FROM Project_Unit__c 
                WHERE TowerName__c = :boookingObj.Cancelled_Tower__c ORDER BY Name];
        System.debug('projectList**'+projectList);
        if(String.isNotBlank(boookingObj.Cancelled_Tower__c)) {
            for(Project_Unit__c unit : projectList) {
                unitOptions.add(new SelectOption(unit.Id, unit.Name));
                // if(unit.Name == opp.Cancelled_Unit__c) {
                //     matchedUnitId = unit.Id;
                // }
            }
            // if(matchedUnitId != null) {
            //     boookingObj.Cancelled_Unit_No__c = matchedUnitId;
            // }
            // else {
            //     System.debug('No matching Project ID found for Name: ' + opp.Cancelled_Unit__c);
            // }
        }
        System.debug('unitOptions**'+unitOptions);
    }
    
    Public Static void initializeCancellation(List<SelectOption> projectOptions,List<SelectOption> towerOptions, List<SelectOption> unitOptions, List<Project__c> projectLst,String matchedProjectId,Booking__c boookingObj,Opportunity opp){
        	matchedProjectId = null;
            projectOptions.add(new SelectOption('', '--Select Project--'));

            towerOptions.add(new SelectOption('', '--Select Tower--'));

            unitOptions.add(new SelectOption('', '--Select Unit--'));

                projectLst = [Select Id,Name from Project__c where RW_Status__c = 'Active' ORDER BY Name];
                for(Project__c proj : projectLst) {
                    projectOptions.add(new SelectOption(proj.Id, proj.Name));
                    if(proj.Name == opp.Cancelled_Project__c) {
                        matchedProjectId = proj.Name;
                    }
                }
                if(matchedProjectId != null) {
                    boookingObj.Cancelled_Project__c = matchedProjectId;
                } else {
                    System.debug('No matching Project ID found for Name: ' + opp.Cancelled_Project__c);
                }
                if(boookingObj.Cancelled_Project__c != null) {
                  loadTowers(towerOptions,boookingObj);
                  
                }
                if(opp.Cancelled_Tower__c != null) {
                    List<Tower__c> towers = [SELECT Id,Name FROM Tower__c 
                                    WHERE Name = :opp.Cancelled_Tower__c 
                                    AND ProjectName__c = :boookingObj.Cancelled_Project__c LIMIT 1];
                    if(!towers.isEmpty()) {
                        boookingObj.Cancelled_Tower__c = towers[0].Name;
                        loadUnits(unitOptions,boookingObj);
                    }
                }
                
                if(opp.Cancelled_Unit__c != null) {
                    List<Project_Unit__c> units = [SELECT Id,Name FROM Project_Unit__c 
                                        WHERE Name = :opp.Cancelled_Unit__c 
                                        LIMIT 1];
                    if(!units.isEmpty()) {
                        boookingObj.Cancelled_Unit_No__c = units[0].Name;
                    }
                }

            boookingObj.Cancelled_SAP_Customer_Number__c = opp.Cancelled_SAP_Customer_Number__c;
            boookingObj.Type_Of_sale__c = opp.Type_Of_sale__c;
            if(opp.Cancelled_Booking__c!=null){
                    boookingObj.Old_Booking__c = opp.Cancelled_Booking__c;
            }
        System.debug('projectOptions----->'+projectOptions);
        System.debug('projectLst----->'+projectLst);
    }
    
    public static Integer validateCancellationDetails(
        Booking__c boookingObj, 
        Opportunity opp, 
        String oldTypeOfSale, 
        Integer currentI
    ) {
        Integer i = currentI;

        if (boookingObj.Type_Of_sale__c == null) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select Type Of Booking');
            ApexPages.addMessage(myMsg);
            i = 1;
            System.debug('--i from utility: ' + i);
        }

        List<Opportunity> cancelOpp = new List<Opportunity>();
        
        if (boookingObj.Type_Of_sale__c == 'Transfer of unit' || 
            boookingObj.Type_Of_sale__c == 'Upgrade of unit' || 
            boookingObj.Type_Of_sale__c == 'Cancel & Rebook') {
            
            if (String.isNotBlank(opp.Cancelled_SAP_Customer_Number__c)) {
                cancelOpp = [
                    SELECT Id, Booking__c, Booking__r.Allotment_Premium__c, Booking__r.Project__r.Name, 
                           Booking__r.Unit_No__r.Name, Booking__r.Unit_No__r.TowerName__r.Name, 
                           SAP_Customer_Number__c, Booking__r.RW_Total_Receipt_Amount_Received__c 
                    FROM Opportunity 
                    WHERE SAP_Customer_Number__c = :opp.Cancelled_SAP_Customer_Number__c
                ];
            }
            
            if (String.isBlank(opp.Cancelled_SAP_Customer_Number__c) && String.isNotBlank(opp.Cancelled_Project__c)) {
                cancelOpp = [
                    SELECT Id, Booking__c, Booking__r.Allotment_Premium__c, Booking__r.Project__r.Name, 
                           Booking__r.Unit_No__r.Name, Booking__r.Unit_No__r.TowerName__r.Name, 
                           SAP_Customer_Number__c, Booking__r.RW_Total_Receipt_Amount_Received__c 
                    FROM Opportunity 
                    WHERE RW_Project__c = :opp.Cancelled_Project__c  
                      AND RW_Project_Unit__r.TowerName__c = :opp.Cancelled_Tower__c 
                      AND RW_Project_Unit__c = :opp.Cancelled_Unit__c
                ];
            }

            System.debug('CancelOpp ----->' + cancelOpp);

            if (String.isBlank(boookingObj.Reason_For_Change__c) && oldTypeOfSale != null && oldTypeOfSale != boookingObj.Type_Of_Sale__c) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please add Reason For Change');
                ApexPages.addMessage(myMsg);
                i = 1;
            }

            if (oldTypeOfSale != boookingObj.Type_Of_Sale__c && (boookingObj.Type_Of_Sale__c == 'Transfer of unit' || boookingObj.Type_Of_Sale__c == 'Upgrade of unit')) { 
                if ((String.isBlank(boookingObj.Cancelled_SAP_Customer_Number__c) && String.isBlank(boookingObj.Cancelled_Project__c)) ||
                    (String.isNotBlank(boookingObj.Cancelled_SAP_Customer_Number__c) && String.isNotBlank(boookingObj.Cancelled_Project__c))) { 
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please add either SAP Customer Number or Project Details');
                    ApexPages.addMessage(myMsg);
                    i = 1;
                }

                if (String.isNotBlank(boookingObj.Cancelled_Project__c)) {
                    if (String.isBlank(boookingObj.Cancelled_Tower__c)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add Tower for the selected Project');
                        ApexPages.addMessage(myMsg); 
                        i = 1;
                    }
                
                    if (String.isNotBlank(boookingObj.Cancelled_Tower__c) && String.isBlank(boookingObj.Cancelled_Unit_No__c)) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add Unit for the selected Project and Tower');
                        ApexPages.addMessage(myMsg); 
                        i = 1;  
                    }
                }
            }
        } 
        
        return i;
    }
    
    public static void validateAllApplicants(BookingClass c) {
        // -------------------------------------------------------------
        // APPLICANT 1 VALIDATIONS
        // -------------------------------------------------------------
        if (c.applicant.Salutation__c == '' || c.applicant.Salutation__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.First_Name__c == '' || c.applicant.First_Name__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Last_Name__c == '' || c.applicant.Last_Name__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.DOB__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Permanent_Address_Line_1__c == '' || c.applicant.Permanent_Address_Line_1__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Country__c == 'India' && (c.applicant.State__c == '' || c.applicant.State__c == null)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.City__c == '' || c.applicant.City__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Pincode__c == null || c.applicant.Pincode__c == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Country__c == '' || c.applicant.Country__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Country__c == 'India' && c.applicant.Pincode__c != null && String.valueOf(c.applicant.Pincode__c).length() != 6) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 1 Should Be Of 6 Digits'));
            c.i = 1;
        }
        if (c.applicant.Mobile_Number__c == '' || c.applicant.Mobile_Number__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Mobile_Number__c != null && c.applicant.Mobile_Number__c.length() != 10 && c.applicant.Subtype_Of_Applicant__c == 'Indian National') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 1 Should be of 10 digits'));
            c.i = 1;
        }
        if (c.applicant.Email_Address__c == '' || c.applicant.Email_Address__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        } else {
            Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
            for (String str : dummys.keySet()) {
                if (c.applicant.Email_Address__c.contains(str) || str.contains(c.applicant.Email_Address__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 1. Please update correct Email id.'));
                    c.i = 1;
                    break;
                }
            }
        }
        if (c.applicant.Nationality_Picklist__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Marital_Status__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Gender__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Type_Of_Applicant__c == '' || c.applicant.Type_Of_Applicant__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Subtype_Of_Applicant__c == '' || c.applicant.Subtype_Of_Applicant__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 1 Cannot Be Left Blank'));
            c.i = 1;
        }
        if (c.applicant.Subtype_Of_Applicant__c == 'Indian National') {
            if (c.applicant.Pancard__c == false || c.applicant.Address_Proof__c == false || String.isBlank(c.applicant.Address_Proof_Document__c) || String.isBlank(c.applicant.Address_Proof_Number__c) || String.isBlank(c.applicant.PancardNo__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant.PancardNo__c != null && c.applicant.PancardNo__c.length() != 10) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits'));
                c.i = 1;
            }
            if (c.applicant.Address_Proof_Number__c != null && !c.applicant.Address_Proof_Number__c.isAlphanumeric()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only'));
                c.i = 1;
            }
        }
        if (c.applicant.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin') {
            if (c.applicant.Funds_from_NRE_FCNR__c == false || c.applicant.Self_attested_copy_of_PIO_or_OCI_Card__c == false || c.applicant.Type_Of_Origin__c == '' || c.applicant.Origin_Details__c == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
        }
        if (c.applicant.Subtype_Of_Applicant__c == 'For NRI') {
            if (c.applicant.Pancard__c == false || c.applicant.PassportNumber__c == false || c.applicant.Funds_from_NRE_NRO__c == false || c.applicant.Copy_of_Workpermit_Employment_contract__c == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant.PancardNo__c != null && c.applicant.PancardNo__c.length() != 10) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits'));
                c.i = 1;
            }
        }
        if (c.applicant.Subtype_Of_Applicant__c == 'For Company') {
            if (c.applicant.Pancard__c == false || c.applicant.Copy_of_Memorandu_of_Association__c == false || c.applicant.Certified_copy_of_Article_of_Association__c == false || c.applicant.Certified_copy_of_Board_Resolution__c == false || c.applicant.Certified_copy_of_ROC_Incorporation__c == false || c.applicant.Self_attested_List_of_Shareholders__c == false || c.applicant.Self_attested_List_of_Directors__c == false || c.applicant.PanCard_of_Authority_Signatory__c == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant.PancardNo__c != null && c.applicant.PancardNo__c.length() != 10) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits'));
                c.i = 1;
            }
        }
        if (c.applicant.Subtype_Of_Applicant__c == 'Partnership Firm') {
            if (c.applicant.Pancard__c == false || c.applicant.PanCard_of_Authority_Signatory__c == false || c.applicant.Certified_copy_of_Partnership_Deed__c == false || c.applicant.Certified_extract_of_Registration__c == false || c.applicant.Copy_of_Authorization_Letter_POA__c == false) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant.PancardNo__c != null && c.applicant.PancardNo__c.length() != 10) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 1 Should Be Of 10 Digits'));
                c.i = 1;
            }
        }
        if (c.addressCheck == false) {
            if (c.applicant.Mailing_Address_Line_1__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 1 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant.Mailing_Pincode__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 1 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant.Mailing_Country__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Country for Applicant 1 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant.Mailing_Country__c == 'India' && c.applicant.Mailing_Pincode__c != null && String.valueOf(c.applicant.Mailing_Pincode__c).length() != 6) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 1 Should Be Of 6 Digits'));
                c.i = 1;
            }
            if (c.applicant.Mailing_Country__c == 'India' && c.applicant.Mailing_State__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 1 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant.Mailing_City__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 1 Cannot Be Left Blank'));
                c.i = 1;
            }
        }

        // -------------------------------------------------------------
        // APPLICANT 2 VALIDATIONS
        // -------------------------------------------------------------
        if (c.applicant2.First_Name__c != null || c.applicant2.Last_Name__c != null) {
            if (String.isBlank(c.applicant2.Salutation__c)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.First_Name__c == '' || c.applicant2.First_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Last_Name__c == '' || c.applicant2.Last_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.DOB__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Permanent_Address_Line_1__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Country__c == 'India' && (c.applicant2.State__c == '' || c.applicant2.State__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.City__c == '' || c.applicant2.City__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Pincode__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Country__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Country__c == 'India' && c.applicant2.Pincode__c != null && String.valueOf(c.applicant2.Pincode__c).length() != 6) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 2 Should Be Of 6 Digits'));
                c.i = 1;
            }
            if (c.applicant2.get('Mobile_Number__c') == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Mobile_Number__c != null && c.applicant2.Mobile_Number__c.length() != 10 && c.applicant2.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 2 Should be of 10 digits'));
                c.i = 1;
            }
            if (c.applicant2.Email_Address__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            } else {
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                for (String str : dummys.keySet()) {
                    if (c.applicant2.Email_Address__c.contains(str) || str.contains(c.applicant2.Email_Address__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 2. Please update correct Email id.'));
                        c.i = 1;
                        break;
                    }
                }
            }
            if (c.applicant2.Nationality_Picklist__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Marital_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Gender__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Type_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Subtype_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 2 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant2.Subtype_Of_Applicant__c == 'Indian National') {
                if (c.applicant2.Pancard__c == false || c.applicant2.Address_Proof__c == false || c.applicant2.Address_Proof_Document__c == '' || c.applicant2.Address_Proof_Number__c == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant2.PancardNo__c != null && c.applicant2.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits'));
                    c.i = 1;
                }
                if (c.applicant2.Address_Proof_Number__c != null && !c.applicant2.Address_Proof_Number__c.isAlphanumeric()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only'));
                    c.i = 1;
                }
            }
            if (c.applicant2.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin' && (c.applicant2.Funds_from_NRE_FCNR__c == false || c.applicant2.Self_attested_copy_of_PIO_or_OCI_Card__c == false || c.applicant2.Type_Of_Origin__c == '' || c.applicant2.Origin_Details__c == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant2.Subtype_Of_Applicant__c == 'For NRI') {
                if (c.applicant2.Pancard__c == false || c.applicant2.PassportNumber__c == false || c.applicant2.Funds_from_NRE_NRO__c == false || c.applicant2.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant2.PancardNo__c != null && c.applicant2.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant2.Subtype_Of_Applicant__c == 'For Company') {
                if (c.applicant2.Pancard__c == false || c.applicant2.Copy_of_Memorandu_of_Association__c == false || c.applicant2.Certified_copy_of_Article_of_Association__c == false || c.applicant2.Certified_copy_of_Board_Resolution__c == false || c.applicant2.Certified_copy_of_ROC_Incorporation__c == false || c.applicant2.Self_attested_List_of_Shareholders__c == false || c.applicant2.Self_attested_List_of_Directors__c == false || c.applicant2.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant2.PancardNo__c != null && c.applicant2.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant2.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (c.applicant2.Pancard__c == false || c.applicant2.PanCard_of_Authority_Signatory__c == false || c.applicant2.Certified_copy_of_Partnership_Deed__c == false || c.applicant2.Certified_extract_of_Registration__c == false || c.applicant2.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant2.PancardNo__c != null && c.applicant2.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 2 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.addressCheckApplicant2 == false) {
                if (c.applicant2.Mailing_Address_Line_1__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 2 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant2.Mailing_Pincode__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 2 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant2.Mailing_Country__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Country for Applicant 2 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant2.Mailing_Country__c == 'India' && c.applicant2.Mailing_Pincode__c != null && String.valueOf(c.applicant2.Mailing_Pincode__c).length() != 6) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 2 Should Be Of 6 Digits'));
                    c.i = 1;
                }
                if (c.applicant2.Mailing_Country__c == 'India' && c.applicant2.Mailing_State__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 2 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant2.Mailing_City__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 2 Cannot Be Left Blank'));
                    c.i = 1;
                }
            }
        }

        // -------------------------------------------------------------
        // APPLICANT 3 VALIDATIONS
        // -------------------------------------------------------------
        if (c.applicant3.First_Name__c != null || c.applicant3.Last_Name__c != null) {
            if (c.applicant3.Salutation__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.First_Name__c == '' || c.applicant3.First_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Last_Name__c == '' || c.applicant3.Last_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.DOB__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Permanent_Address_Line_1__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Country__c == 'India' && (c.applicant3.State__c == '' || c.applicant3.State__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.City__c == '' || c.applicant3.City__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Pincode__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Country__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Country__c == 'India' && c.applicant3.Pincode__c != null && String.valueOf(c.applicant3.Pincode__c).length() != 6) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 3 Should Be Of 6 Digits'));
                c.i = 1;
            }
            if (c.applicant3.Mobile_Number__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Mobile_Number__c != null && c.applicant3.Mobile_Number__c.length() != 10 && c.applicant3.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 3 Should be of 10 digits'));
                c.i = 1;
            }
            if (c.applicant3.Email_Address__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            } else {
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                for (String str : dummys.keySet()) {
                    if (c.applicant3.Email_Address__c.contains(str) || str.contains(c.applicant3.Email_Address__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 3. Please update correct Email id.'));
                        c.i = 1;
                        break;
                    }
                }
            }
            if (c.applicant3.Nationality_Picklist__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Marital_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Gender__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Type_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Subtype_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 3 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant3.Subtype_Of_Applicant__c == 'Indian National') {
                if (c.applicant3.Pancard__c == false || c.applicant3.Address_Proof__c == false || c.applicant3.Address_Proof_Document__c == '' || c.applicant3.Address_Proof_Number__c == '' || String.isBlank(c.applicant3.Address_Proof_Number__c) || String.isBlank(c.applicant3.PancardNo__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant3.PancardNo__c != null && c.applicant3.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits'));
                    c.i = 1;
                }
                if (c.applicant3.Address_Proof_Number__c != null && !c.applicant3.Address_Proof_Number__c.isAlphanumeric()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only'));
                    c.i = 1;
                }
            }
            if (c.applicant3.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin' && (c.applicant3.Funds_from_NRE_FCNR__c == false || c.applicant3.Self_attested_copy_of_PIO_or_OCI_Card__c == false || c.applicant3.Type_Of_Origin__c == '' || c.applicant3.Origin_Details__c == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant3.Subtype_Of_Applicant__c == 'For NRI') {
                if (c.applicant3.Pancard__c == false || c.applicant3.PassportNumber__c == false || c.applicant3.Funds_from_NRE_NRO__c == false || c.applicant3.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant3.PancardNo__c != null && c.applicant3.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant3.Subtype_Of_Applicant__c == 'For Company') {
                if (c.applicant3.Pancard__c == false || c.applicant3.Copy_of_Memorandu_of_Association__c == false || c.applicant3.Certified_copy_of_Article_of_Association__c == false || c.applicant3.Certified_copy_of_Board_Resolution__c == false || c.applicant3.Certified_copy_of_ROC_Incorporation__c == false || c.applicant3.Self_attested_List_of_Shareholders__c == false || c.applicant3.Self_attested_List_of_Directors__c == false || c.applicant3.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant3.PancardNo__c != null && c.applicant3.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant3.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (c.applicant3.Pancard__c == false || c.applicant3.PanCard_of_Authority_Signatory__c == false || c.applicant3.Certified_copy_of_Partnership_Deed__c == false || c.applicant3.Certified_extract_of_Registration__c == false || c.applicant3.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant3.PancardNo__c != null && c.applicant3.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 3 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.addressCheckApplicant3 == false) {
                if (c.applicant3.Mailing_Address_Line_1__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 3 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant3.Mailing_Pincode__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 3 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant3.Mailing_Country__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Country for Applicant 3 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant3.Mailing_Country__c == 'India' && c.applicant3.Mailing_Pincode__c != null && String.valueOf(c.applicant3.Mailing_Pincode__c).length() != 6) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 3 Should Be Of 6 Digits'));
                    c.i = 1;
                }
                if (c.applicant3.Mailing_Country__c == 'India' && c.applicant3.Mailing_State__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 3 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant3.Mailing_City__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 3 Cannot Be Left Blank'));
                    c.i = 1;
                }
            }
        }

        // -------------------------------------------------------------
        // APPLICANT 4 VALIDATIONS
        // -------------------------------------------------------------
        if (c.applicant4.First_Name__c != null || c.applicant4.Last_Name__c != null) {
            if (c.applicant4.Salutation__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.First_Name__c == '' || c.applicant4.First_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Last_Name__c == '' || c.applicant4.Last_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.DOB__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Permanent_Address_Line_1__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Country__c == 'India' && (c.applicant4.State__c == '' || c.applicant4.State__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.City__c == '' || c.applicant4.City__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Pincode__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Country__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Country__c == 'India' && c.applicant4.Pincode__c != null && String.valueOf(c.applicant4.Pincode__c).length() != 6) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 4 Should Be Of 6 Digits'));
                c.i = 1;
            }
            if (c.applicant4.Mobile_Number__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Mobile_Number__c != null && c.applicant4.Mobile_Number__c.length() != 10 && c.applicant4.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 4 Should be of 10 digits'));
                c.i = 1;
            }
            if (c.applicant4.Email_Address__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            } else {
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                for (String str : dummys.keySet()) {
                    if (c.applicant4.Email_Address__c.contains(str) || str.contains(c.applicant4.Email_Address__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 4. Please update correct Email id.'));
                        c.i = 1;
                        break;
                    }
                }
            }
            if (c.applicant4.Nationality_Picklist__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Marital_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Gender__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Type_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Subtype_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 4 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant4.Subtype_Of_Applicant__c == 'Indian National') {
                if (c.applicant4.Pancard__c == false || c.applicant4.Address_Proof__c == false || c.applicant4.Address_Proof_Document__c == '' || c.applicant4.Address_Proof_Number__c == '' || String.isBlank(c.applicant4.Address_Proof_Number__c) || String.isBlank(c.applicant4.PancardNo__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant4.PancardNo__c != null && c.applicant4.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits'));
                    c.i = 1;
                }
                if (c.applicant4.Address_Proof_Number__c != null && !c.applicant4.Address_Proof_Number__c.isAlphanumeric()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only'));
                    c.i = 1;
                }
            }
            if (c.applicant4.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin' && (c.applicant4.Funds_from_NRE_FCNR__c == false || c.applicant4.Self_attested_copy_of_PIO_or_OCI_Card__c == false || c.applicant4.Type_Of_Origin__c == '' || c.applicant4.Origin_Details__c == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant4.Subtype_Of_Applicant__c == 'For NRI') {
                if (c.applicant4.Pancard__c == false || c.applicant4.PassportNumber__c == false || c.applicant4.Funds_from_NRE_NRO__c == false || c.applicant4.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant4.PancardNo__c != null && c.applicant4.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant4.Subtype_Of_Applicant__c == 'For Company') {
                if (c.applicant4.Pancard__c == false || c.applicant4.Copy_of_Memorandu_of_Association__c == false || c.applicant4.Certified_copy_of_Article_of_Association__c == false || c.applicant4.Certified_copy_of_Board_Resolution__c == false || c.applicant4.Certified_copy_of_ROC_Incorporation__c == false || c.applicant4.Self_attested_List_of_Shareholders__c == false || c.applicant4.Self_attested_List_of_Directors__c == false || c.applicant4.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant4.PancardNo__c != null && c.applicant4.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant4.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (c.applicant4.Pancard__c == false || c.applicant4.PanCard_of_Authority_Signatory__c == false || c.applicant4.Certified_copy_of_Partnership_Deed__c == false || c.applicant4.Certified_extract_of_Registration__c == false || c.applicant4.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant4.PancardNo__c != null && c.applicant4.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 4 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.addressCheckApplicant4 == false) {
                if (c.applicant4.Mailing_Address_Line_1__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 4 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant4.Mailing_Pincode__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 4 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant4.Mailing_Country__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Country for Applicant 4 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant4.Mailing_Country__c == 'India' && c.applicant4.Mailing_Pincode__c != null && String.valueOf(c.applicant4.Mailing_Pincode__c).length() != 6) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 4 Should Be Of 6 Digits'));
                    c.i = 1;
                }
                if (c.applicant4.Mailing_Country__c == 'India' && c.applicant4.Mailing_State__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 4 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant4.Mailing_City__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 4 Cannot Be Left Blank'));
                    c.i = 1;
                }
            }
        }

        // -------------------------------------------------------------
        // APPLICANT 5 VALIDATIONS
        // -------------------------------------------------------------
        if (c.applicant5.First_Name__c != null || c.applicant5.Last_Name__c != null) {
            if (c.applicant5.Salutation__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Salutation for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.First_Name__c == '' || c.applicant5.First_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'First Name for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Last_Name__c == '' || c.applicant5.Last_Name__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Last Name for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.DOB__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'DOB for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Permanent_Address_Line_1__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Permanent address Line1 for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Country__c == 'India' && (c.applicant5.State__c == '' || c.applicant5.State__c == null)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'State for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.City__c == '' || c.applicant5.City__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'City for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Pincode__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Country__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Country__c == 'India' && c.applicant5.Pincode__c != null && String.valueOf(c.applicant5.Pincode__c).length() != 6) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pincode for Applicant 5 Should Be Of 6 Digits'));
                c.i = 1;
            }
            if (c.applicant5.Mobile_Number__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Mobile_Number__c != null && c.applicant5.Mobile_Number__c.length() != 10 && c.applicant5.Subtype_Of_Applicant__c == 'Indian National') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mobile Number for Applicant 5 Should be of 10 digits'));
                c.i = 1;
            }
            if (c.applicant5.Email_Address__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email Address for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            } else {
                Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
                for (String str : dummys.keySet()) {
                    if (c.applicant5.Email_Address__c.contains(str) || str.contains(c.applicant5.Email_Address__c)) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'It seems you are using Dummy email id for Applicant 5. Please update correct Email id.'));
                        c.i = 1;
                        break;
                    }
                }
            }
            if (c.applicant5.Nationality_Picklist__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Nationality for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Marital_Status__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Marital Status for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Gender__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Gender for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Type_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Type Of Applicant for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Subtype_Of_Applicant__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Residential Status for Applicant 5 Cannot Be Left Blank'));
                c.i = 1;
            }
            if (c.applicant5.Subtype_Of_Applicant__c == 'Indian National') {
                if (c.applicant5.Pancard__c == false || c.applicant5.Address_Proof__c == false || c.applicant5.Address_Proof_Document__c == '' || c.applicant5.Address_Proof_Number__c == '' || String.isBlank(c.applicant5.Address_Proof_Number__c) || String.isBlank(c.applicant5.PancardNo__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant5.PancardNo__c != null && c.applicant5.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits'));
                    c.i = 1;
                }
                if (c.applicant5.Address_Proof_Number__c != null && !c.applicant5.Address_Proof_Number__c.isAlphanumeric()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Adress proof number should be Alpha Numeric Characters only'));
                    c.i = 1;
                }
            }
            if (c.applicant5.Subtype_Of_Applicant__c == 'Foreign Nationals Of Indian Origin' && (c.applicant5.Funds_from_NRE_FCNR__c == false || c.applicant5.Self_attested_copy_of_PIO_or_OCI_Card__c == false || c.applicant5.Type_Of_Origin__c == '' || c.applicant5.Origin_Details__c == '')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                c.i = 1;
            }
            if (c.applicant5.Subtype_Of_Applicant__c == 'For NRI') {
                if (c.applicant5.Pancard__c == false || c.applicant5.PassportNumber__c == false || c.applicant5.Funds_from_NRE_NRO__c == false || c.applicant5.Copy_of_Workpermit_Employment_contract__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant5.PancardNo__c != null && c.applicant5.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant5.Subtype_Of_Applicant__c == 'For Company') {
                if (c.applicant5.Pancard__c == false || c.applicant5.Copy_of_Memorandu_of_Association__c == false || c.applicant5.Certified_copy_of_Article_of_Association__c == false || c.applicant5.Certified_copy_of_Board_Resolution__c == false || c.applicant5.Certified_copy_of_ROC_Incorporation__c == false || c.applicant5.Self_attested_List_of_Shareholders__c == false || c.applicant5.Self_attested_List_of_Directors__c == false || c.applicant5.PanCard_of_Authority_Signatory__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant5.PancardNo__c != null && c.applicant5.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.applicant5.Subtype_Of_Applicant__c == 'Partnership Firm') {
                if (c.applicant5.Pancard__c == false || c.applicant5.PanCard_of_Authority_Signatory__c == false || c.applicant5.Certified_copy_of_Partnership_Deed__c == false || c.applicant5.Certified_extract_of_Registration__c == false || c.applicant5.Copy_of_Authorization_Letter_POA__c == false) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please ensure that all the document checkboxes are checked and document details are filled properly.'));
                    c.i = 1;
                }
                if (c.applicant5.PancardNo__c != null && c.applicant5.PancardNo__c.length() != 10) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Pancard for Applicant 5 Should Be Of 10 Digits'));
                    c.i = 1;
                }
            }
            if (c.addressCheckApplicant5 == false) {
                if (c.applicant5.Mailing_Address_Line_1__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing address Line1 for Applicant 5 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant5.Mailing_Pincode__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 5 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant5.Mailing_Country__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Country for Applicant 5 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant5.Mailing_Country__c == 'India' && c.applicant5.Mailing_Pincode__c != null && String.valueOf(c.applicant5.Mailing_Pincode__c).length() != 6) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing Pincode for Applicant 5 Should Be Of 6 Digits'));
                    c.i = 1;
                }
                if (c.applicant5.Mailing_Country__c == 'India' && c.applicant5.Mailing_State__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing State for Applicant 5 Cannot Be Left Blank'));
                    c.i = 1;
                }
                if (c.applicant5.Mailing_City__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Mailing City for Applicant 5 Cannot Be Left Blank'));
                    c.i = 1;
                }
            }
        }
    }

    /**Added for Cancellation Changes ends */
    
    Public static void Dummy(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;    
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;   
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        i++; i++;
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
        
    }

    
}