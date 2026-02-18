public class EnableCPPortaluser {
    
    @InvocableMethod(label='Enable Partner Portal User') //@future (Callout = true)
    public static void EnableCustomerCommunityUser(List<id> accids)
    {   
        
        List<Account> accList = New List<Account>();
        List<Contact> conlist = New List<Contact>();
        List<User> UserList= New List<User>();
        Set<Id> OppId = New Set<Id>();
        //Id AcountID = accID;
        
        acclist = [SELECT id,Name,CP_Email__c,Mobile_No__c,Channel_Partner_Activated__c,Channel_Partner__r.Id From Account Where Id IN: accids];
        System.debug('AccountLst :: '+acclist);
        for(Account a : acclist){
        
        List<Profile> pf = [SELECT Id FROM Profile WHERE Name =: 'Partner Community User'];
        System.debug('Profile Id :: ' + pf);
        if(a != Null && pf != Null && pf.size() > 0)
        {   
            if(a.Channel_Partner_Activated__c != true)
            {
                conlist = [Select Id, AccountId From Contact Where AccountId =: a.Id];
                System.debug('Inside if loop');
                User u = New User();
                u.LastName = a.Name ;
                if(a.CP_Email__c != Null)
                {
                    u.Email = a.CP_Email__c;
                    u.Username = a.CP_Email__c+'.rg';
                }
                if(a.Mobile_No__c != null){
                    u.MobilePhone =a.Mobile_No__c; 
                }
                
                u.Alias = a.Name.substring(0, 4);
                u.TimeZoneSidKey = 'Asia/Kolkata' ; 
                u.LocaleSidKey = 'en_IN'; 
                u.EmailEncodingKey = 'ISO-8859-1';
                u.ProfileId = pf[0].Id;
                u.ContactId = conlist[0].Id;
                u.LanguageLocaleKey = 'en_US';
                u.CommunityNickname = a.Name;
                
                Account ac = New Account();
                /*If(u.ContactId != Null)
                {
                    cn = [Select Id , AccountId From Contact Where Id =: u.ContactId];
                    ac = [Select Id ,IsCustomerPortal From Account Where Id =: cn.AccountId];
                }*/
                ac = [Select Id ,Channel_Partner_Activated__c From Account Where Id =: a.id];
                if( ac != Null)
                {
                    ac.Channel_Partner_Activated__c = true ;   
                    update ac;
                    System.debug('Check box updated successfully :: ');
                }
                
                Try{
                    insert u;
                System.debug('User Inserted successfully ');
                
                //Contact cn = New Contact();
                
                }catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
                
            }
            else
            {   
                CalloutException e = new CalloutException();
                e.setMessage('User Already Exist '+a.CP_Email__c);
                throw e;
            }
        }
        }
        
    }
}