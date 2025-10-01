public class EOIWrapper 
{
		 @AuraEnabled
        public String RWName{get;set;}
    
         @AuraEnabled
        public String Id{get;set;}
    
    
        @AuraEnabled
        public String RWPrimaryFirstName{get;set;}

        @AuraEnabled
        public String RWPrimaryMiddleName{get;set;}
    
    	@AuraEnabled
        public String RWPrimaryLastName{get;set;}

        @AuraEnabled
        public String RWNameofCompany{get;set;}
    
         @AuraEnabled
        public String RWResidentialCompanyAddress{get;set;}

        @AuraEnabled
        public String RWPin{get;set;}
    
        @AuraEnabled
        public String RWCity{get;set;}
    
    	@AuraEnabled
        public String RWPrimaryContactNo{get;set;}

        @AuraEnabled
        public String RWPrimaryEmail{get;set;}
    
    	@AuraEnabled
        public String RWPANDetails{get;set;}
    
    	@AuraEnabled
        public String RWPrimaryAlternateEmail{get;set;}

        @AuraEnabled
        public String RWPrimaryAadharDetails{get;set;}
    
        @AuraEnabled
        public String RWPrimaryPassportDetails{get;set;}
    
    	@AuraEnabled
        public String RWSecondaryFirstName{get;set;}

        @AuraEnabled
        public String RWSecondaryMiddleName{get;set;}
    
        @AuraEnabled
        public String RWSecondaryLastName{get;set;}
    
    	@AuraEnabled
        public String RWSecondaryContactNo{get;set;}

        @AuraEnabled
        public String RWSecondaryEmail{get;set;}
    
        @AuraEnabled
        public String RWSecondaryPANDetails{get;set;}
    
    	@AuraEnabled
        public String RWSecondaryAlternateEmail{get;set;}

        @AuraEnabled
        public String RWSecondaryAadharDetails{get;set;}
    
    	 @AuraEnabled
        public String RWSecondaryPassportDetails{get;set;}
    
    	@AuraEnabled
        public String RWPreferredUnitType{get;set;}

        @AuraEnabled
        public String RWPreferredBudget{get;set;}
    
         @AuraEnabled
        public String RWPreferredFloors{get;set;}
    
    	@AuraEnabled
        public String RWAnyotherpreferencepleasespecify{get;set;}

        @AuraEnabled
        public String RWPreferredUnitNo{get;set;}
    
        @AuraEnabled
        public String RWTentativeAgreementValue{get;set;}
    
    	@AuraEnabled
        public String RWTentativeAllInclusivePrice{get;set;}

        @AuraEnabled
        public String RWApplicationSource{get;set;}
    
        @AuraEnabled
        public String RWSourceDetails{get;set;}
    
    	@AuraEnabled
        public String RWClosingType{get;set;}

        @AuraEnabled
        public String RWChannelPartnersCompany{get;set;}
    
    	@AuraEnabled
        public String RWChannelPartnersName{get;set;}
    
         @AuraEnabled
        public String RWSourceContactNo{get;set;}
    
         @AuraEnabled
        public String RWSourceEmailId{get;set;}
    
         @AuraEnabled
        public String RWRERANo{get;set;}
    
    	@AuraEnabled
        public String RWState{get;set;}
    
        @AuraEnabled
        public String RWCountry{get;set;}
	
    	@AuraEnabled
        public String RWCountryPhoneCode {get;set;}
    
        @AuraEnabled
        public String RWDocumentNumber {get;set;}
    
        @AuraEnabled
        public String RWDocumentProof {get;set;}
    
         @AuraEnabled
        public String RWPermanentAddressLine1 {get;set;}
    
        @AuraEnabled
        public String RWPermanentAddressLine2 {get;set;}
    
        @AuraEnabled
        public String RWPermanentAddressLine3 {get;set;}
    
        @AuraEnabled
        public String RWGender {get;set;} 
    
         @AuraEnabled
        public String RWTypeOfOrigin {get;set;} 
    
         @AuraEnabled
        public String RWOriginDetails {get;set;} 
    
        @AuraEnabled
        public String RWPanCardNumberofAuthoritySignatory {get;set;} 
    
        @AuraEnabled
        public String RWPassportNoDetails{get;set;} 
    
         @AuraEnabled
        public String RWNationality{get;set;} 
    
        @AuraEnabled
        public String RWOccupation{get;set;} 
    
        @AuraEnabled
        public String RWDesignation{get;set;}
     
        @AuraEnabled
        public String RWTypeofapplicant{get;set;}
    
        @AuraEnabled
        public String RWResidentialstatus{get;set;}
       
         @AuraEnabled
        public String RWTower{get;set;}
    
          @AuraEnabled
        public String RWTowerName{get;set;}
    
         @AuraEnabled
        public Date RWDateOfBirth{get;set;}
    
        @AuraEnabled
        public String RWMaritalStatus{get;set;}
    
       @AuraEnabled
        public Boolean RWOptin{get;set;}
    
       @AuraEnabled
        public String RWMailingAddressLine1 {get;set;}
    
        @AuraEnabled
        public String RWMailingAddressLine2 {get;set;}
    
        @AuraEnabled
        public String RWMailingAddressLine3 {get;set;}
    
        @AuraEnabled
        public String RWMailingState{get;set;}
    
        @AuraEnabled
        public String RWMailingCountry{get;set;}
    
        @AuraEnabled
        public String RWMailingPin{get;set;}
    
        @AuraEnabled
        public String RWMailingCity{get;set;}
    
        @AuraEnabled
        public String RWPrimaryAlternateContactNo{get;set;}
    
        @AuraEnabled
        public Boolean MailPermAddrSame{get;set;}
    
        @AuraEnabled
        public String RWDigitallyAcceptedOn{get;set;}
    
        @AuraEnabled
        Public Payment_Gateway__mdt gateway;
    
        @AuraEnabled
        Public Boolean paymentGatewayAvailable;
        
   		/* bkk */
        @AuraEnabled
        Public Boolean BillDeskTC{get;set;}

        //Added by coServe 15-10-2024 Start
        @AuraEnabled
        Public String LandlineNo{get;set;}
    	@AuraEnabled
        Public String CustomerGST{get;set;}
    	@AuraEnabled
        Public String HomeLoan{get;set;}
    	@AuraEnabled
        Public String SecondaryAlternateContactNo{get;set;}
    	@AuraEnabled
        Public String SecondaryLandline{get;set;}
    	@AuraEnabled
        Public String SecondaryNationality{get;set;}
    	@AuraEnabled
        Public String SecondaryHomeloan{get;set;}
    	@AuraEnabled
        Public String DraftChequeNo{get;set;}
    	@AuraEnabled
        Public Date DraftChequeDate{get;set;}
    	@AuraEnabled
        Public String BankName{get;set;}
    	@AuraEnabled
        Public String SourceDetails{get;set;}
    	@AuraEnabled
        Public String ChannelPartnerContactNo{get;set;}
    	@AuraEnabled
        Public String ChannelPartnerEmail{get;set;}
    	@AuraEnabled
        Public String PreferredSize{get;set;}
    	@AuraEnabled
        Public String EOIAmount{get;set;}
    	@AuraEnabled
        Public String ApplicationSource{get;set;}
    	
    	//Added by coServe 15-10-2024 End
    
}