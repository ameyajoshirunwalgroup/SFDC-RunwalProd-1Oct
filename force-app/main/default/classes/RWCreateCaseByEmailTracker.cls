@isTest
public with sharing class RWCreateCaseByEmailTracker 
{
    static testmethod void unittest1()
    {
        RM_Usernames__c objUsernames = new RM_Usernames__c();
        objUsernames.Name ='Adarsh';
        objUsernames.RW_Email__c ='relationmanager@runwal.com';
        objUsernames.User_Name__c ='test@gmail.com';
        insert objUsernames;
        
        list<string> lstaddress = new list<string>();
        lstaddress.add('customer.care@runwalgroup.in');
    	Messaging.InboundEmail email = new Messaging.InboundEmail();
    	email.plainTextBody ='bliss';
    	email.subject = 'bliss';
        if(lstaddress != null && lstaddress.size() > 0)
        {
    	email.toAddresses = lstaddress;
        }
        email.fromAddress = 'relationmanager@runwal.com';
    	
        Account objAccount = new Account();
        objAccount.Name = 'Acc';
        objAccount.PersonEmail ='relationmanager@runwal.com';
    	
    	Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        RWCreateCaseByEmail obj = new RWCreateCaseByEmail();
        obj.handleInboundEmail(email, envelope);

    	
    	
        
        system.debug('@@@@@@@@@objUsernames'+objUsernames);
        
         
    	
    }
}