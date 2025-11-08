public class Controller_CampaignCPPortal {
    public Static String CPMeetsCampaign=System.label.CPMeetsCampaign;
    
    /* @AuraEnabled(cacheable=true)
public static List<Campaign> getCampaigns(){
try {
LIst<Campaign> lstCampaigns = [Select id,StartDate,Description,Name,Type__c, Event_Date_Time__c,Event_Location__c  
from Campaign where Event_Date_Time__c >= TODAY 
and Type__c=:CPMeetsCampaign 
order by Event_Date_Time__c limit 5]; 
return lstCampaigns;   
} catch (Exception e) {  throw new AuraHandledException(e.getMessage());
}
}*/
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getCampaignsForCurrentUser(){
        try {
            // Get current user's contact
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(currentUser.ContactId == null){
                return new List<Campaign>();
            }
            
            List<CampaignMember> members = [SELECT CampaignId 
                                            FROM CampaignMember 
                                            WHERE ContactId = :currentUser.ContactId];
            
            Set<Id> campaignIds = new Set<Id>();
            for(CampaignMember cm : members){
                campaignIds.add(cm.CampaignId);
            }
            
            if(campaignIds.isEmpty()){
                return new List<Campaign>();
            }
            
            List<Campaign> lstCampaigns = [SELECT Id, StartDate, Description, Name, Type__c, Event_Date_Time__c, Event_Location__c
                                           FROM Campaign 
                                           WHERE Id IN :campaignIds
                                           AND Event_Date_Time__c >= TODAY
                                           AND Type__c = :CPMeetsCampaign
                                           ORDER BY Event_Date_Time__c
                                          ];
            return lstCampaigns;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static LIst<Campaign> getAllCampaigns(){
        try {
            LIst<Campaign> lstCampaigns = [Select id,StartDate,Description,Name,Type__c, Event_Date_Time__c, Event_Location__c
                                           from Campaign where Event_Date_Time__c >= TODAY 
                                           and Type__c=:CPMeetsCampaign 
                                           order by Event_Date_Time__c]; 
            return lstCampaigns;   
        } catch (Exception e) { throw new AuraHandledException(e.getMessage());
                              }
    }
    @AuraEnabled(cacheable=true)
    public static LIst<Campaign> getAllPastCampaigns(){
        try {
            LIst<Campaign> lstCampaigns = [Select id,StartDate,Description,Name,Type__c,Event_Date_Time__c 
                                           from Campaign 
                                           where Event_Date_Time__c < TODAY 
                                           and Type__c=:CPMeetsCampaign
                                           order by Event_Date_Time__c desc]; 
            return lstCampaigns;   
        } catch (Exception e) {  throw new AuraHandledException(e.getMessage());
                              }
    }
}