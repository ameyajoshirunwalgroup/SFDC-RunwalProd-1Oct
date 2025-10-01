trigger trgUser on User (after insert, after update) {
	
    if(Trigger.isInsert && Trigger.isAfter){
        Set<Id> usrIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        List<Account> updateAcc = new List<Account>();
        for(User usr : Trigger.New){
            if(usr.ProfileId == System.Label.Runwal_Customer_Portal_Profile_Id){
                usrIds.add(usr.Id);
                accIds.add(usr.AccountId);
                Account acc = new Account();
                acc.Id = usr.AccountId;
                acc.Portal_User__c = usr.Id;
                updateAcc.add(acc);
            }
        }
        if(updateAcc.size() > 0){
            update updateAcc;
        }
        if(!Test.isRunningTest() && usrIds.size() > 0){
            CreateUserWhenUnitBooked.createuser(new List<Id>(accIds));
        }
        
        
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        Set<Id> accIds = new Set<Id>();
        for(User usr : Trigger.New){
            if(usr.ProfileId == System.Label.Runwal_Customer_Portal_Profile_Id && usr.IsActive == false && usr.IsActive != Trigger.oldMap.get(usr.Id).IsActive){
                System.debug('Acc Id: ' + Trigger.oldMap.get(usr.Id).AccountId);
                accIds.add(Trigger.oldMap.get(usr.Id).AccountId);
            } 
        }
        if(!Test.isRunningTest() && accIds.size() > 0){
            //CreateUserWhenUnitBooked.deleteuser(new List<Id>(accIds));
            System.enqueueJob(new DeleteUserInMobileAppQueueable(accIds));
        }
    }
}