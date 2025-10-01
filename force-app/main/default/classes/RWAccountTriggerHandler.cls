public without sharing class RWAccountTriggerHandler 
{
    public void runTrigger()
    {
        if (Trigger.isBefore && Trigger.isInsert)
        {
            onBeforeInsert((list<Account>) trigger.new, null);
        }

        // Method will be called to handle Before Update Accounts
        if (Trigger.isBefore && Trigger.isUpdate)
        {
            onBeforeUpdate((list<Account>) trigger.new, (map<id, Account>) trigger.OldMap);
        }

        // Method will be called to handle After Insert Accounts
        if (Trigger.isAfter && Trigger.isInsert)
        {
            onAfterInsert((list<Account>) trigger.new, (map<id, Account>) trigger.NewMap);
        }

        // Method will be called to handle After Update Accountssss

        if (Trigger.isAfter && Trigger.isUpdate)
        {
            onAfterUpdate((list<Account>) trigger.new, 
                            (map<id, Account>) trigger.NewMap, (map<id, Account>) trigger.OldMap);
        }
    }

    // Method calls all the methods required to be executed after insert
    private void onAfterInsert(list<Account> lstTriggerNew, map<id, Account> mapTriggerNew)
    {

    }

    // Method calls all the methods required to be executed after update
    private void onAfterUpdate(list<Account> lstTriggerNew, map<id, Account> mapTriggerNew, map<id, Account> mapTriggerOld)
    {

    }


    // Method calls all the methods required to be executed before insert
    public void onBeforeInsert(list<Account> lstTriggerNew, map<id, Account> mapTriggerOld)
    {
        updateContactDetails(lstTriggerNew, null);
    }

    // Method calls all the methods required to be executed before update
    public void onBeforeUpdate(list<Account> lstTriggerNew, map<id, Account> mapTriggerOld)
    {
        updateContactDetails(lstTriggerNew, mapTriggerOld);
    }
    
    /*
        This method is for updating the contact detail of the customer
        --------------------------------------------------------------------------------------
        Name                                Date                                Version                     
        --------------------------------------------------------------------------------------
        Adarsh                            07/04/2017                              1.0    
        --------------------------------------------------------------------------------------
    */
    private void updateContactDetails(list<Account> lstTriggerNew, map<id, Account> mapTriggerOld)
    {
        /*if(lstTriggerNew != null && lstTriggerNew.size() > 0)
        {
            for(Account EachAcc : lstTriggerNew)
            {
                if(EachAcc.RW_Customer_Email__c != null && (mapTriggerOld == null || 
                    (mapTriggerOld != null && mapTriggerOld.get(EachAcc.id).RW_Customer_Email__c != EachAcc.RW_Customer_Email__c)))
                {
                    pattern myPattern = pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+'); 
                    matcher myMatcher = myPattern.matcher(EachAcc.RW_Customer_Email__c);
                    if(myMatcher.matches() )
                    {
                        EachAcc.RW_Email__c = EachAcc.RW_Customer_Email__c;
                    }
                    else
                    {
                        EachAcc.addError('Please enter a valid Customer Email.');
                    }
                }
                else if(EachAcc.RW_Email__c != null && (mapTriggerOld == null || 
                    (mapTriggerOld != null && mapTriggerOld.get(EachAcc.id).RW_Email__c != EachAcc.RW_Email__c)))
                {
                    EachAcc.RW_Customer_Email__c = EachAcc.RW_Email__c;
                }
                
                if(EachAcc.RW_Customer_Mobile_Number__c != null && (mapTriggerOld == null || 
                    (mapTriggerOld != null && mapTriggerOld.get(EachAcc.id).RW_Customer_Mobile_Number__c != EachAcc.RW_Customer_Mobile_Number__c)))
                {
                    EachAcc.RW_Mobile_No__c = EachAcc.RW_Customer_Mobile_Number__c;
                }
                else if(EachAcc.RW_Mobile_No__c != null && (mapTriggerOld == null || 
                    (mapTriggerOld != null && mapTriggerOld.get(EachAcc.id).RW_Mobile_No__c != EachAcc.RW_Mobile_No__c)))
                {
                    EachAcc.RW_Customer_Mobile_Number__c = EachAcc.RW_Mobile_No__c;
                }
            }
        }*/
    }
}