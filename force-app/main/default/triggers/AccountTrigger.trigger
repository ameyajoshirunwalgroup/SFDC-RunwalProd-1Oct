trigger AccountTrigger on Account(before Insert, after Insert, before update, after update) {
  /*  if (Trigger.IsInsert) {
        if (Trigger.IsBefore) {
            List < Account > updateNRIList = new List < Account > ();
            List < Account > updateChannelList = new List < Account > ();

            // call the CampaignManagementServices.addchannel method
           for (Account a: trigger.new) {
                if (a.IsPersonAccount) 
                    updateChannelList.add(a);
            }
            updateNRIList = CampaignManagementServices.setNRIChannelOnAccount(updateChannelList);
        } else */ 
     if (Trigger.IsInsert) {   
        if (Trigger.isAfter) {
          List<Account> updateCMList = new List<Account>();
          for(Account a : trigger.new) {
    //        if(a.isPersonAccount && (a.Campaign_Code__c != null || a.TollFree_Number__C !=null)) {
              if(a.isPersonAccount && (a.Campaign_Code__c != null )) {  
              updateCMList.add(a);
            }
          }
          if (updateCMList != null && updateCMList.size() > 0) {
     /*   try {
         // PersonAccountManagementServices.AddCampaignToAccount(updateCMList);
        } catch (GlobalException ex) {
         // System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        }*/
      }
        }
   
        }
    
    
    If(Trigger.isUpdate) {
     /*   if (Trigger.isBefore) {
            List < Account > updateChannelList = new List < Account > ();
            List < Account > updateNRIList = new List < Account > ();

            for (Account a: trigger.new) {
                if (Trigger.newMap.get(a.Id).channel_Code__C != Trigger.oldMap.get(a.Id).Channel_Code__c && 
                                                                    Trigger.newMap.get(a.Id).IsPersonAccount) 
                    updateChannelList.add(a);
            }
            if (updateChannelList != null && updateChannelList.size() > 0) 
                updateNRIList = CampaignManagementServices.setNRIChannelOnAccount(updateChannelList);
        } else */
    
    
        if(Trigger.isAfter) {
          List < Account > updateCMList = new List < Account > ();
          List<Id> accIds = new List<Id>();
          //List<LockatedApp_UserDetailUpdate.AccountUpdateWrap> accUpdateWrapperList = new List<LockatedApp_UserDetailUpdate.AccountUpdateWrap>(); //Added by Vinay 30-12-2025
      for (account a: trigger.new) {
      //  if (Trigger.newMap.get(a.Id).Campaign_Code__C != Trigger.oldMap.get(a.Id).Campaign_Code__C || Trigger.newMap.get(a.Id).TollFree_Number__C != Trigger.oldMap.get(a.Id).TollFree_Number__C)
          if (Trigger.newMap.get(a.Id).Campaign_Code__C != Trigger.oldMap.get(a.Id).Campaign_Code__C )  
        updateCMList.add(a);
        //Added by coServe 07-12-2023
        if(a.Send_to_Lockated__c == true && (a.Send_to_Lockated__c != Trigger.oldMap.get(a.Id).Send_to_Lockated__c)){
            accIds.add(a.Id);
        }
        /*LockatedApp_UserDetailUpdate.AccountUpdateWrap accUpdateWrapper = new LockatedApp_UserDetailUpdate.AccountUpdateWrap();
        accUpdateWrapper.acc = a;
        if(a.Mobile_No__c != null && (a.Mobile_No__c != Trigger.oldMap.get(a.Id).Mobile_No__c)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.primaryMobileChanged = true;
            accUpdateWrapper.oldPrimaryMobile = Trigger.oldMap.get(a.Id).Mobile_No__c;
            accUpdateWrapper.newPrimaryMobile = a.Mobile_No__c;
        }
        if(a.PersonEmail != null && (a.PersonEmail != Trigger.oldMap.get(a.Id).PersonEmail)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.primaryEmailChanged = true;
            accUpdateWrapper.oldPrimaryEmail = Trigger.oldMap.get(a.Id).PersonEmail;
            accUpdateWrapper.newPrimaryEmail = a.PersonEmail;
        }
        if(a.Alternate_Mobile_No__c != null && (a.Alternate_Mobile_No__c != Trigger.oldMap.get(a.Id).Alternate_Mobile_No__c)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.secondaryMobileChanged = true;
            accUpdateWrapper.oldSecondaryMobile = Trigger.oldMap.get(a.Id).Alternate_Mobile_No__c;
            accUpdateWrapper.newSecondaryMobile = a.Alternate_Mobile_No__c;
        }
        if(a.Alternate_Email__c != null && (a.Alternate_Email__c != Trigger.oldMap.get(a.Id).Alternate_Email__c)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.secondaryEmailChanged = true;
            accUpdateWrapper.oldSecondaryEmail = Trigger.oldMap.get(a.Id).Alternate_Email__c;
            accUpdateWrapper.newSecondaryEmail = a.Alternate_Email__c;
        }
        if(a.RW_Secondary_Mobile_No__pc != null && (a.RW_Secondary_Mobile_No__pc != Trigger.oldMap.get(a.Id).RW_Secondary_Mobile_No__pc)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.secondaryMobileChanged = true;
            accUpdateWrapper.oldSecondaryMobile = Trigger.oldMap.get(a.Id).RW_Secondary_Mobile_No__pc;
            accUpdateWrapper.newSecondaryMobile = a.RW_Secondary_Mobile_No__pc;
        }
        if(a.RW_Secondary_Email__pc != null && (a.RW_Secondary_Email__pc != Trigger.oldMap.get(a.Id).RW_Secondary_Email__pc)){ // Added by Vinay 30-12-2025
            accUpdateWrapper.secondaryEmailChanged = true;
            accUpdateWrapper.oldSecondaryEmail = Trigger.oldMap.get(a.Id).RW_Secondary_Email__pc;
            accUpdateWrapper.newSecondaryEmail = a.RW_Secondary_Email__pc;
        }
        accUpdateWrapperList.add(accUpdateWrapper);*/
      }
      //Added by coServe 07-12-2023
      if(accIds.size() > 0){
          //CreateUserWhenUnitBooked.createuser(accIds); // Commented by Vinay 13-01-2026
          CreateUserWhenUnitBooked.createuserWithApplicants(accIds); // Added by Vinay 13-01-2026
      }
      /*if(accUpdateWrapperList.size() > 0){ //Added by Vinay 30-12-2025
          system.enqueuejob(new LockatedApp_UserDetailUpdate(accUpdateWrapperList));
      }*/
      if (updateCMList != null && updateCMList.size() > 0) {
      /*  try {
        //  PersonAccountManagementServices.AddCampaignToAccount(updateCMList);
        } catch (GlobalException ex) {
         // System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        }*/
      }
        }

    
   }
    if(trigger.isAfter && trigger.isInsert) {
        Set<Id> acID = new Set<Id>();
        Id ChannelPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        system.debug('ChannelPartnerId::' + ChannelPartnerId);
        for(Account acc:Trigger.New) {
            if(acc.RecordTypeId == ChannelPartnerId ){
                acID.add(acc.Id);
            }
        }
        if(!acID.isEmpty()){
            AccountTriggerHandler.createcontactCP(acID);
            AccountTriggerHandler.UpdateCPAccountOnCP(acID);
        }
    }
 }