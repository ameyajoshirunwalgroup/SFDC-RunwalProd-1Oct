public class wrapOpportunityRecord
     {
     @AuraEnabled
     public String Name{get;set;}
     @AuraEnabled
     public String StageName{get;set;}
     @AuraEnabled
     public String Email{get;set;}
     @AuraEnabled     
     public String LeadSource{get;set;}
     @AuraEnabled
     public String strMobile{get;set;}
     @AuraEnabled
     public String strEmail{get;set;}
	 @AuraEnabled
     public String strRefSource{get;set;}
     @AuraEnabled
     public String Id{get;set;}
     @AuraEnabled
     public Boolean isBoolean{get;set;}
     public    wrapOpportunityRecord()
         {
         Name='';
         //Email='';
         StageName='';
         LeadSource='';
         strMobile='';
         strEmail='';
         Id='';
         strRefSource = '';
         isBoolean=true;
         }
     }