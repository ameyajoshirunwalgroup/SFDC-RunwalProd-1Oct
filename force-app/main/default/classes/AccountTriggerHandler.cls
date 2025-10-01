public class AccountTriggerHandler {
    public static void createcontactCP(set<Id> accId){
        List<Account> aclist = new List<Account>();
        List<Contact> conlist = new List<Contact>();
        
        aclist = [Select Id,Name,FirstName,LastName,CP_Email__c,Phone,Mobile_No__c 
                  From Account Where Id IN: accId AND RecordType.Name = 'Channel Partner'];
        system.debug('aclist :: '+aclist);
        
        Contact con;
        if(!aclist.isEmpty()){
            for(Account a: aclist){
                con = new Contact();
                //con.Name = a.Name;
                //con.FirstName = a.FirstName;
                con.LastName = a.Name;
                con.AccountId = a.Id;
                if(string.isNotBlank(a.CP_Email__c)){
                    con.Email = a.CP_Email__c;
                }
                if(string.isNotBlank(a.Mobile_No__c)){
                    con.MobilePhone = a.Mobile_No__c;
                }
                
                conlist.add(con);
            }
        }
        
        try{
            system.debug('Inside Try !!');
            insert conlist;
        }catch(Exception e){
            system.debug('Exception for contact :: '+e);
        }
    }
    
    public static void UpdateCPAccountOnCP(set<Id> accId){
        List<Account> aclist = new List<Account>();
        List<Broker__c> BrokerUpdate = new List<Broker__c>();
        aclist = [Select Id,Name,Channel_Partner__c 
                  From Account Where Id IN: accId AND RecordType.Name = 'Channel Partner'];
        system.debug('aclist :: '+aclist);
        if(!aclist.isEmpty()){
            for(Account a: aclist){
                Broker__c cp = new Broker__c();
                cp.Account__c = a.Id;
                cp.Id = a.Channel_Partner__c;
                BrokerUpdate.add(cp);
                
            }
        }
        
        try{
            system.debug('Inside Try !!');
            Update BrokerUpdate;
        }catch(Exception e){
            system.debug('Exception for contact :: '+e);
        }
    }
}