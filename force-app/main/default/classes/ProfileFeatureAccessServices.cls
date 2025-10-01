public with sharing class ProfileFeatureAccessServices {
  
  public static boolean hasAccess(Id userId, String featureName) {
    // when you want to check if a user access to a specific feature, first call getUserAccess, 
    // if that returns NO, then user doesnt have access
    // if it return YES, then user has access
    // if that returns CANTSAY, check profile access
    // if that return YES, user has access, if that returns NO user doesnt have access
    String response = getUserAccess(userId,featureName);
    system.debug('userId>>>>>'+userId);
    system.debug('featureName>>>>>'+featureName);
    system.debug('response>>>>>'+response);
    if(response.equals('YES')) {
      return true;
    } else if(response.equals('NO')) {
      return false;
    } else {
      List<User> u = [Select Id, profile.Name from user where Id = :userId];
    
      if(u.size() != 0) {
      system.debug('u.size()>>>>>>>'+u.size());
        response = getProfileAccess(u[0].profile.Name, featureName);
         system.debug('u[0].profile.Name>>>>>>>>>'+u[0].profile.Name);
        if(response.equals('YES'))
          return true;
        else
         system.debug('else part');
          return false;
      }
      else {
        return false;
      }
    }
  }
  
  public static String getUserAccess(Id userId, String featureName) {
    List<ProfileToFeatureAccess__c> uAccess = [Select Feature_Accessible__c from ProfileToFeatureAccess__c where Single_User_Access_Exception__c = :userId
                          and FeaturesList__c = :featureName LIMIT 1];
    String response = null;
    if(uAccess.size() == 0) {
      response = 'CANTSAY';
    } else if (uAccess[0].Feature_Accessible__c) {
      response = 'YES';
    } else {
      response = 'NO';
    }
    system.debug('response'+response);
    return response;
  }
  
  public static String getProfileAccess(String profileName, String featureName) {
    List<ProfileToFeatureAccess__c> pAccess = [Select Feature_Accessible__c from ProfileToFeatureAccess__c where ProfileList__c = :profileName
                          and FeaturesList__c = :featureName LIMIT 1];
    String response = null;
    if(pAccess.size() == 0) {
      response = 'NO';
    } else if (pAccess[0].Feature_Accessible__c) {
      response = 'YES';
    } else {
      response = 'NO';
    }
    system.debug('response+++++'+response);
    return response;
  }
  
  
  /////////////////////// Below method added by vikas for edit options //////////////////
  public static Integer getEditAccess(String profileName, String featureName) {
  system.debug('inside profile feature method profile name:: '+profileName +' featureName:: ' +featureName);
    List<ProfileToFeatureAccess__c> pAccess = [Select Feature_Accessible__c,Edit_Access__c from ProfileToFeatureAccess__c where ProfileList__c = :profileName
                          and FeaturesList__c = :featureName LIMIT 1];
    Integer response = 0;
    //system.debug('pAccess.size::: '+pAccess.size());
    //system.debug('pAccess::: '+pAccess);
    
    if(pAccess.size() == 1) {
        if(pAccess[0].Edit_Access__c)
            response = 1;
        else
            response = 0;
    }
    //system.debug('response+++++'+response);
    return response;
  }
  
}