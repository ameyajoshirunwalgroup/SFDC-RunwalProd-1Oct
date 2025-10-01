public class CountryCode{
    public static String checkCode1(String di){ 
    CountryCodeMap__c cm = new CountryCodeMap__c();
        
        String temp = '';
         List<CountryCodeMap__c> lst = new List<CountryCodeMap__c>();  
        if(di != null && di != ''){
            
        
            lst =  [SELECT  Id, Name_Country__c ,Country_Code__c FROM CountryCodeMap__c where Country_Code__c =: di  ]; 
       		//Integer i;
        	if(lst.size() > 0) {
              temp = lst[0].Name_Country__c;
             	
   			}
             System.debug(temp);
        }
       
        return temp;
        
	}
}