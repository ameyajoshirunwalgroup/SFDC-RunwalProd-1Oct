trigger ChannelPartnerUpdateTrigger on Broker__c (before update) {
    if(trigger.isbefore && trigger.isupdate){
        List<Broker__c> CpList = Trigger.New ;
        id cpid = CpList[0].id;
        List<Lead> LeadList = [Select id,name,RW_Broker__c from lead Where RW_Broker__c =: cpid  ] ;
        system.debug('LeadList = :' +LeadList.size());
        List<Opportunity> OpportunityList = [Select id,name,RW_Broker__c from Opportunity Where RW_Broker__c =: cpid OR RW_Walkin_Channel_Partner__c =: cpid] ;
        system.debug('OpportunityList = :' +OpportunityList.size());
        List<Prospect__c> ProspectList = [Select id,name,Channel_Partner__c from Prospect__c Where Channel_Partner__c =: cpid] ;
        system.debug('ProspectList = :' +ProspectList.size());
        
        for(Broker__c br : Trigger.New) {
            if(LeadList.size() > 0 || OpportunityList.size() > 0 || ProspectList.size() > 0 ){
                //br.addError('You Cannot edit this checkbox as Related Lead/Opportunity/Prospect is present..!!');
            }
        }  
    }
    /*if(trigger.isbefore && trigger.isupdate){
        List<Account> accList = New List<Account>();
        List<Contact> conlist = New List<Contact>();
        List<User> UserList= New List<User>();
        List<Broker__c> CPList1 = trigger.new;
        
        acclist = [SELECT id,Name,CP_Email__c,Mobile_No__c,Channel_Partner_Activated__c,Channel_Partner__r.Id From Account Where Id =: CPList1[0].Account__c];
        System.debug('AccountLst :: '+acclist);
        conlist = [Select Id, AccountId From Contact Where AccountId =: accList[0].Id];
        UserList = [Select Id ,ContactId From User where ContactId =: conlist[0].Id ];
        system.debug('UserList '+UserList);
        for(Broker__c br : CPList1 ){
            if(UserList.size()>0){
                br.addError('User already exists');
                
            }
        }
        
    }*/
}