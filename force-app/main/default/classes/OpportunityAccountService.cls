public class OpportunityAccountService {
    
    
    @invocablemethod(label='emailchange')
    public static void updateemail(list<id> accIds){
        list<account> upAccount = new List<account>();
        List<Account> pAccounts = [select id,personemail,FirstName,LastName,RW_Email__c,(select id,RW_Email__c from Opportunities) from account where id in : accIds];
        Map<id,Account> userMap = new Map<id,Account>();
        for(account a : pAccounts){
            if(a.Opportunities.size() == 1){
                a.RW_Email__c = a.Opportunities[0].RW_Email__c;
                a.personemail = a.Opportunities[0].RW_Email__c;
                
                upAccount.add(a);
                userMap.put(a.id,a);
            }
        }
        update upAccount;
        //get the user id
        try{
            List<user> usrList =[select id,Firstname,LastName,Email,username,RW_Accountid__c from user where RW_Accountid__c in : userMap.keySet()];
            for(user u : usrList){
                u.Firstname = userMap.get(u.RW_Accountid__c).FirstName    ;   
                u.LastName = userMap.get(u.RW_Accountid__c).LastName;
                u.Email = userMap.get(u.RW_Accountid__c).personemail;
                u.Username = userMap.get(u.RW_Accountid__c).PersonEmail+'.runwalcustomer';
                
            }
            database.update(usrList);
        }catch(exception ex){
            
        }
    }
}