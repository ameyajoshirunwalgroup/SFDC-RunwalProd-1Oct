public class CPProfileUpdate {
    @AuraEnabled
    public static String updateChannelPartner(Broker__c sf) {	
        List<Broker__c> cplist = new List<Broker__c>();
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c,Channel_Partner__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].Channel_Partner__c;
        }
        
        try{
            sf.Id = CPId;
            if(!Test.isRunningTest()){
                Update sf;
            }
            return loggeduserId;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getopps( String custname, String projectname,String orderBy, String direction) {
        system.debug('custname::'+custname);
        system.debug('projectname::'+projectname);
        /*Id loggeduserId = UserInfo.getUserId();
String CPId ;
System.debug('Logged User is :: ' +UserInfo.getUserName());
List<Contact> contact = new List<Contact>();
List<Account> AccList = new List<Account>();
List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
System.debug('Contact Id:: '+user[0].ContactId);
System.debug('User List:: '+ user);

contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
if(!AccList.isEmpty()){
CPId = AccList[0].id;
}
System.debug('AccList '+ AccList);*/
        String a = 'Active';
        String b = 'Booked';
        //     String query = 'SELECT Id, Name,Project_Name_formula__c,RW_Type_of_Client__c,Booking1__c,Unit1__c,RW_CIF_form_number__c,RW_Project_Unit__c,StageName,RW_Sourcing_Manager__c,RW_Number_of_Visits__c,Booking__c,RW_Booking_Date_Opp__c,RW_Budget__c,CloseDate,RW_Sales_Associate__c,RW_Sales_Manager_Comment__c,Number_of_Total_Visits__c FROM Opportunity where (RW_Opportunity_Status__c =:a OR RW_Opportunity_Status__c =:b)' +'order by CloseDate desc' ;    
        String query = 'SELECT Id, Name,Project_Name_formula__c,RW_Type_of_Client__c,Booking1__c,Unit1__c,RW_CIF_form_number__c,RW_Project_Unit__c,StageName,RW_Sourcing_Manager__c,RW_Number_of_Visits__c,Booking__c,RW_Booking_Date_Opp__c,RW_Budget__c,CloseDate,RW_Sales_Associate__c,RW_Sales_Manager_Comment__c,Number_of_Total_Visits__c FROM Opportunity where (RW_Opportunity_Status__c =:a OR RW_Opportunity_Status__c =:b)';
        
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( custname != null && custname != '' ) {
            String key = '%' + custname + '%';
            query += ' and Name LIKE :key';
        }
        if ( projectname != null && projectname != '' ) {
            String key2 = '%' + projectname + '%';
            query += ' and Project_Name_formula__c LIKE :key2';
        }
                   query += ' ORDER BY '+orderBy+' '+direction;

        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }
    /*@AuraEnabled(Cacheable=true)
    public static List <Opportunity> getoppsort(String field, String sortOrder) {
        String a = 'Active';
        String b = 'Booked';
        String query = 'SELECT Id, Name,Project_Name_formula__c,RW_Type_of_Client__c,Booking1__c,Unit1__c,RW_CIF_form_number__c,RW_Project_Unit__c,StageName,RW_Sourcing_Manager__c,RW_Number_of_Visits__c,Booking__c,RW_Booking_Date_Opp__c,RW_Budget__c,CloseDate,RW_Sales_Associate__c,RW_Sales_Manager_Comment__c,Number_of_Total_Visits__c FROM Opportunity where (RW_Opportunity_Status__c =:a OR RW_Opportunity_Status__c =:b)';
        system.debug('query==='+query);
        
        if(custname != null && sortOrder !=null){
            query += ' ORDER BY '+field+' '+sortOrder;
        }
        return Database.query(query);
    }*/
    
}