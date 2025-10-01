public class N_ScreenPopController{
    
    public string mobilePhone {get;set;}
    public string did {get;set;}
    
    public N_ScreenPopController(){
        
      //  Map<String,String> allPageParams = ApexPages.currentPage().getParameters();
      // for(string st : allPageParams.keySet()){ 
      // }
        
        if(ApexPages.currentPage().getParameters().containsKey('phone'))  {     
            mobilePhone = ApexPages.currentPage().getParameters().get('phone'); 
        }
        
        if(ApexPages.currentPage().getParameters().get('did') != null)  {     
            did = ApexPages.currentPage().getParameters().get('did'); 
            system.debug('did'+did);
        }        
    }
    
    public pageReference openScreen(){
        
        PageReference pageRef;
        List <Lead> leadList;
        List <Lead> Llist;
        List <Account> accList;
        List <Opportunity> optyList;
     //   List <Case> caseList;
        string countryCode;
        string country;
        string formattedphone;
        system.debug('mobilePhone'+mobilePhone);
        if(String.isNotBlank(mobilePhone) && mobilePhone != null) {
            formattedphone = mobilePhone;
            // for india, usa, uk the number of digits in phone # is 10. So if the length is greater than 10
            // then take the last 10 as mobile and whatever is remaining in the first digits after stripping off
            // the 10 digits are taken as countryCode. Then we compare them with potential country code formats that we know of
            // for US, UK,  India and then set the country accordingly.
            
            if(string.isNotBlank(formattedphone) && formattedPhone.length() > 11) {
                system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

                countryCode =  formattedPhone.subString(0, formattedPhone.length() -11);
                mobilePhone = formattedPhone.substring(countryCode.length());
                if(countryCode.equals('86') || countryCode.equals('0086') ||countryCode.equals('086')){ 
                    countryCode = '086';  
                    country = 'China';
                }else if(countryCode.equals('1') || countryCode.equals('001')){
                    country = 'USA';
                }else if(countryCode.equals('91') || countryCode.equals('091') || countryCode.equals('0091')){
                    countryCode = '+91';
                    country = 'India';
                }else if(countryCode.equals('44') || countryCode.equals('044') || countryCode.equals('0044')){
                    countryCode = '044';
                    country = 'London';
                }  
            }
             	system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

            if(string.isNotBlank(formattedphone) && formattedPhone.length() > 10 && string.isBlank(country)) {
                countryCode =  formattedPhone.substring(0, formattedPhone.length() - 10);
                mobilePhone = formattedPhone.substring(countryCode.length());
                if(countryCode.equals('1') || countryCode.equals('001')){ 
                    country = 'USA';
                }
                 else if(countryCode.equals('0') || countryCode.equals('00')){ 
                    countryCode = '+91';
                    country = 'India';
                }
                else if(countryCode.equals('91') || countryCode.equals('091') || countryCode.equals('0091')){
                    countryCode = '+91';
                    country = 'India';
                }else if(countryCode.equals('44') || countryCode.equals('044') || countryCode.equals('0044')){
                    countryCode = '044';
                    country = 'London';
                }else if(countryCode.equals('61') || countryCode.equals('0061') ||countryCode.equals('061')){ 
                    countryCode = '061';
                    country = 'Australia';
                }else if(countryCode.equals('60') || countryCode.equals('0060') ||countryCode.equals('060')){ 
                    countryCode = '060';
                    country = 'Malaysia';
                }else if(countryCode.equals('971') || countryCode.equals('00971') ||countryCode.equals('0971')){ 
                    countryCode = '0971';
                    country = 'Dubai';
                }else if(countryCode.equals('965') || countryCode.equals('00965') ||countryCode.equals('0965')){ 
                    countryCode = '0965';
                    country = 'Kuwait';
                }else if(countryCode.equals('966') || countryCode.equals('00966') ||countryCode.equals('0966')){ 
                    countryCode = '0966';
                    country = 'Saudi Arabia';
                }
            }
             	system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

            if(string.isNotBlank(formattedphone) && formattedPhone.length() > 9 && string.isBlank(country)) {
                countryCode =  formattedPhone.subString(0, formattedPhone.length() - 9);
                mobilePhone = formattedPhone.substring(countryCode.length());
                if(countryCode.equals('61') || countryCode.equals('0061') ||countryCode.equals('061')){ 
                    countryCode = '061';
                    country = 'Australia';
                }else if(countryCode.equals('60') || countryCode.equals('0060') ||countryCode.equals('060')){ 
                    countryCode = '060';
                    country = 'Malaysia';
                }else if(countryCode.equals('971') || countryCode.equals('00971') ||countryCode.equals('0971')){ 
                    countryCode = '0971'; 
                    country = 'Dubai';
                }else if(countryCode.equals('965') || countryCode.equals('00965') ||countryCode.equals('0965')){ 
                    countryCode = '0965';
                    country = 'Kuwait';
                }else if(countryCode.equals('966') || countryCode.equals('00966') ||countryCode.equals('0966')){ 
                    countryCode = '0966';
                    country = 'Saudi Arabia';
                }else if(countryCode.equals('974') || countryCode.equals('00974') ||countryCode.equals('0974')){ 
                    countryCode = '0974';
                    country = 'Qatar';
                }else if(countryCode.equals('968') || countryCode.equals('00968') ||countryCode.equals('0968')){ 
                    countryCode = '0968';
                    country = 'Oman';
                }else if(countryCode.equals('973') || countryCode.equals('00973') ||countryCode.equals('0973')){ 
                    countryCode = '0973';
                    country = 'Bahrain';
                }else if(countryCode.equals('65') || countryCode.equals('0065') ||countryCode.equals('065')){ 
                    countryCode = '065';
                    country = 'Singapore';
                }else if(countryCode.equals('852') || countryCode.equals('00852') ||countryCode.equals('0852')){ 
                    countryCode = '0852';
                    country = 'Hong Kong';
                }
            }
           	    system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

            if(string.isNotBlank(formattedphone) && formattedPhone.length() > 8 && string.isBlank(country)) {
                countryCode =  formattedPhone.subString(0, formattedPhone.length() -8);
                mobilePhone = formattedPhone.substring(countryCode.length());
                if(countryCode.equals('974') || countryCode.equals('00974') ||countryCode.equals('0974')){ 
                    countryCode = '0974';
                    country = 'Qatar';
                }else if(countryCode.equals('968') || countryCode.equals('00968') ||countryCode.equals('0968')){ 
                    countryCode = '0968';
                    country = 'Oman';
                }else if(countryCode.equals('973') || countryCode.equals('00973') ||countryCode.equals('0973')){ 
                    countryCode = '0973';
                    country = 'Bahrain';
                }else if(countryCode.equals('65') || countryCode.equals('0065') ||countryCode.equals('065')){ 
                    countryCode = '065';
                    country = 'Singapore';
                }else if(countryCode.equals('852') || countryCode.equals('00852') ||countryCode.equals('0852')){ 
                    countryCode = '0852';
                    country = 'Hong Kong';
                }else if(countryCode.equals('965') || countryCode.equals('00965') ||countryCode.equals('0965')){ 
                    countryCode = '0965';
                    country = 'Kuwait';
                }                                    
            }
             system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

            if(string.isNotBlank(formattedphone) && formattedPhone.length() >= 10 && string.isBlank(country)) {
                countryCode =  formattedPhone.substring(0, formattedPhone.length() - 10);
                mobilePhone = formattedPhone.substring(countryCode.length());
                //mobilePhone = formattedPhone;
                if(mobilePhone.length() == 10){
                    country = 'India';
                    countryCode = '+91';
                } else {
                    country = '';
                    countryCode = '';
                }
            }
             system.debug('Country Code : '+countryCode);
                system.debug('country   : '+country);
                system.debug('Mobile   : '+mobilePhone);

            if(mobilePhone.length() > 10) {
                mobilePhone = mobilePhone.substring(mobilePhone.length() - 10);
            }
            
            
            leadList = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :mobilePhone OR Phone = :mobilePhone) AND isConverted= false];
            
          
            /////////// For Opportunity 
             if(optyList != null && optyList.size() == 1 && !optyList.isEmpty()) {                  
                pageRef = new PageReference('/' + optyList[0].Id);                           
            }
            else if(leadList != null && leadList.size() == 1 && !leadList.isEmpty()) {                  
                pageRef = new PageReference('/' + leadList[0].Id);                           
            }
            else {
                string campaignId;
                String LeadSource, LeadSubSource, PrimaryCampaignCode, CampaignName, Project, LeadSubSubSource;
                List<Campaign> CampaignList = new List<Campaign>();
               // List<Project__c> project1List = new List<Project__c>();
                if(did != null){
                    CampaignList = [SELECT Id, Name, Type, Primary_Project__c, Digital_Maketing_Campaign_Code__c,RW_Sub_Type__c,Sub_Sub_Source__c from Campaign where Digital_Maketing_Campaign_Code__c = :did and IsActive = true];
                    system.debug('CampaignList'+CampaignList);
                }
                if (CampaignList.size() > 0){      
                    LeadSource = CampaignList[0].Type;       
                    LeadSubSource = CampaignList[0].RW_Sub_Type__c;
                    LeadSubSubSource = CampaignList[0].Sub_Sub_Source__c;
                    CampaignName = CampaignList[0].Id;
                    PrimaryCampaignCode = CampaignList[0].Digital_Maketing_Campaign_Code__c;
                    if(CampaignList[0].Primary_Project__c != null){
                        Project = CampaignList[0].Primary_Project__c;
                      ///  project1List = [SELECT Id, Name from Project__c Where id = :CampaignList[0].Project__c];
                    }
                }
                
                Lead l  = new Lead (
                    	LastName = 'Name',
                		RW_Mobile_No__c = mobilePhone,
                		RDS_Country_Code__c = countryCode,
                		RDS_Country__c = Country, 
                		Campaign_Code__c = did,
                		RW_Project__c = Project,
                		LeadSource = LeadSource,
                    	RW_Lead_Sub_Source__c = LeadSubSource,
                    	Lead_Sub_Sub_Source__c = LeadSubSubSource,
                		RW_Lead_through_CTI__c = true);
                try{
                    insert l;
                    Llist = [select id, Name From Lead where id=: l.id];
                    pageRef = new PageReference('/' + Llist[0].id);
                }
                catch(Exception ex){
                }
               
            }
        }      
        return pageRef;      
    }   
}