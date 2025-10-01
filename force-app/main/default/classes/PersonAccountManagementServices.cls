public with sharing class PersonAccountManagementServices {
   
    public static void AddCampaignToAccount(List<Account> accList) {
      //Based on EnquiryMode for CALLS
    Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
    
    //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
      for(account a:accList) {
        if(a.TollFree_Number__c != null)  {
          if(campaignDetails.containsKey('TOLLFREENUMBER')) {
            campaignDetails.get('TOLLFREENUMBER').add(a.TollFree_Number__C);
          } else {
            List<String> tollFreeList = new List<String>();
            tollFreeList.add(a.TollFree_Number__C);
            campaignDetails.put('TOLLFREENUMBER', tollFreeList);
          }
        }  
        if(a.Campaign_Code__C != null)  {
          if(campaignDetails.containsKey('CAMPAIGNCODE')) {
            campaignDetails.get('CAMPAIGNCODE').add(a.Campaign_Code__C);
          } else {
            List<String> codeList = new List<String>();
            codeList.add(a.Campaign_Code__C);
            campaignDetails.put('CAMPAIGNCODE', codeList);
          }
        }
      }
      Map<String,Campaign> searchResults = new Map<String,Campaign>();
      
      System.debug('CampaignDetails:' + CampaignDetails);
    if(campaignDetails != null && !campaignDetails.isEmpty())  
    searchResults = CampaignManagementServices.searchCampaign(CampaignDetails);
    
    // create a Map like below
    //  campaingnA, [List of accounts to add to that campaign]
    //    campaignB, [List of accounts to add to that campaign]
    Map<Campaign,Set<Account>> campaignMap = new Map<Campaign,Set<Account>>();
    
    for(Account a: accList) {
      if(searchResults.containsKey(a.TollFree_Number__c)) {
        Campaign c= searchResults.get(a.TollFree_Number__c);
        if(campaignMap.containsKey(c)){
          campaignMap.get(c).add(a);
        } else {
          Set<Account> al = new Set<Account>();
          al.add(a);
          campaignMap.put(c,al);
        }
      }  
      
      if(searchResults.containsKey(a.Campaign_Code__c)) {
        Campaign c= searchResults.get(a.Campaign_Code__c);
        if(campaignMap.containsKey(c)){
          campaignMap.get(c).add(a);
        } else {
          Set<Account> al = new Set<Account>();
          al.add(a);
          campaignMap.put(c,al);
        }
      }      
    }
    System.debug('In account campaign code:' + campaignMap);
    CampaignManagementServices.addCampaignToAccount(campaignMap);
    }

}