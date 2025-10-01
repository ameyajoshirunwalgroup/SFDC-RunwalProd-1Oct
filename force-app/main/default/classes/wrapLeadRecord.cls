public class wrapLeadRecord
     {
     @AuraEnabled
     public String LastName{get;set;}
     @AuraEnabled
     public String FirstName{get;set;}
     @AuraEnabled
     public String Email{get;set;}
     @AuraEnabled
     public String Mobile{get;set;}
     @AuraEnabled
     public String LeadSource{get;set;}
     @AuraEnabled
     public String RefferalSource{get;set;}
     @AuraEnabled
     public String strStatus{get;set;}
     
     public   wrapLeadRecord()
         {
         LastName='';
         FirstName='';
         Email='';
         Mobile='';
         LeadSource='';
         RefferalSource='';
         strStatus = '';
         }
     }