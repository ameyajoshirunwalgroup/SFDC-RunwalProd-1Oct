trigger ReferralPointsTrg on Referral_Points__c (after insert) {
    
    
    if(Trigger.isInsert && Trigger.isAfter){
        
        Map<Id, Decimal> accIdVsPointsMap = new Map<Id, Decimal>();
        List<Id> loyaltyMemberIds = new List<Id>();
        List<Id> refPointIds = new List<Id>();
        for(Referral_Points__c refPoint: trigger.new){
            if(refPoint.Type__c == 'Fresh Lead'){
                loyaltyMemberIds.add(refPoint.Account__c);
            }
            refPointIds.add(refPoint.Id);
            if(accIdVsPointsMap.get(refPoint.Account__c) == null){
                accIdVsPointsMap.put(refPoint.Account__c, refPoint.Points__c);
            }else{
                accIdVsPointsMap.put(refPoint.Account__c, (accIdVsPointsMap.get(refPoint.Account__c) + refPoint.Points__c));
            }
        }
        
        List<Account> accList = new List<Account>();
        for(Account acc : [SELECT Id,Referral_Points__c FROM Account WHERE Id =: accIdVsPointsMap.keySet()]){
            acc.Referral_Points__c = (acc.Referral_Points__c != null)? (acc.Referral_Points__c + accIdVsPointsMap.get(acc.Id)) : accIdVsPointsMap.get(acc.Id);
            accList.add(acc);
        }
        if(accList.size() > 0){
            update accList;
        }
        
        if(refPointIds.size() > 0){
            LockatedApp_LoyaltyMemberCreation.creditWallet(refPointIds);
        }
        if(loyaltyMemberIds.size() > 0){
            LockatedApp_LoyaltyMemberCreation.createLoyaltyMember(loyaltyMemberIds);
        }
    }
}