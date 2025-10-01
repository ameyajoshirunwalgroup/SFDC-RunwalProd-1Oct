public class UpdateMobileNumberController {

    @AuraEnabled
    public static void updateMobileNumber(Id recId, String mobNum, String secMobNum, String countryCode, String dailingCountry){
    //public static void updateMobileNumber(Id recId, String secMobNum, String countryCode, String dailingCountry){
        
        try{
            String objName = recId.getSObjectType().getDescribe().getName();
            if(objName == 'Opportunity'){
                Opportunity opp = [SELECT Id, AccountId, Booking__c FROM Opportunity WHERE Id =: recId];
                Account acc = new Account();
                Booking__c bkg = new Booking__c();
                Applicant_Details__c app = new Applicant_Details__c();
                List<Applicant_Details__c> appDetails = [SELECT Id FROM Applicant_Details__c WHERE Booking__c =: opp.Booking__c AND 
                                                   Applicant_Number__c = 'Primary Applicant'];
                if(mobNum != null){
                    opp.RW_Mobile_No__c = mobNum;
                    acc.Mobile_No__c = mobNum;
                    if(appDetails.size() == 1){
                        appDetails[0].Mobile_Number__c = mobNum;
                        update appDetails[0];
                    }
                }
                if(secMobNum != null){
                    opp.RW_Secondary_Mobile_No__c = secMobNum;
                    acc.RW_Secondary_Mobile_No__pc = secMobNum;
                    acc.Country_Code_2__c = countryCode;
                    acc.Dialing_Country_2__c = dailingCountry;
                }
                
                update opp;
                
                acc.Id = opp.AccountId;
                update acc;
                
            }else if(objName == 'Lead'){
                Lead ld = new Lead();
                ld.Id = recId;
                if(mobNum != null){
                    ld.RW_Mobile_No__c = mobNum;
                }
                if(secMobNum != null){
                    ld.RW_Secondary_Mobile_No__c = secMobNum;
                }
                update ld;
            }
            
        }catch(Exception e){
            system.debug('Error line: ' + e.getLineNumber());
            throw new AurahandledException(e.getMessage()); 
        }
        
    }
    
    @AuraEnabled
    public static List<String> getCountryCodeList(){
       List<String> countryCodeValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Country_Code_2__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			countryCodeValuesList.add(pickListVal.getValue());
		}     
		return countryCodeValuesList;
    }
    
    @AuraEnabled
    public static List<String> getDialingCountryList(){
       List<String> dialingCountryValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Account.Dialing_Country_2__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			dialingCountryValuesList.add(pickListVal.getLabel());
		}     
		return dialingCountryValuesList;
    }
}