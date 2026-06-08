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
}