public without sharing class showCampaignDetailsPageHelper {
    
    public class campaignWrapper {
        @AuraEnabled public Campaign oneCampaign { get; set; }
        @AuraEnabled public Boolean isConferance { get; set; }
        @AuraEnabled public Boolean isAlreadyMember { get; set; }
        @AuraEnabled public Decimal totalAttendees { get; set; }
        @AuraEnabled public Boolean hasRSVPed { get; set; }
        @AuraEnabled public Boolean hasDeclined { get; set; } 
    }
    
    @AuraEnabled(cacheable = true)
    public static campaignWrapper fetchCampaignDetailsById(String campaignID){
        campaignWrapper wrapperObjectToReturn = new campaignWrapper();
        wrapperObjectToReturn.hasRSVPed = false; // default
wrapperObjectToReturn.hasDeclined = false;
        try {
            // Fetch campaign
            Campaign oneCampaign = [SELECT Id, StartDate, Event_Date_Time__c, Event_Location__c, Description, Name, Type__c, EndDate, Registration_Count1__c
                                    FROM Campaign 
                                    WHERE Id = :campaignID
                                    LIMIT 1];
            wrapperObjectToReturn.oneCampaign = oneCampaign;
            wrapperObjectToReturn.totalAttendees = oneCampaign.Registration_Count1__c;

            if(oneCampaign.Type__c.contains('CP Meets')){
                wrapperObjectToReturn.isConferance = true;

                // Check if user is already a member
                User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

                if(currentUser.ContactId != null){
                    List<CampaignMember> cmList = [SELECT Id, RSVP__c ,Declined__c
                                                   FROM CampaignMember 
                                                   WHERE CampaignId = :campaignID AND ContactId = :currentUser.ContactId
                                                   LIMIT 1];
                    if(!cmList.isEmpty()){
                        wrapperObjectToReturn.isAlreadyMember = true;
                        wrapperObjectToReturn.hasRSVPed = cmList[0].RSVP__c; // set RSVP status
                        wrapperObjectToReturn.hasDeclined = cmList[0].Declined__c;
                    } else {
                        wrapperObjectToReturn.isAlreadyMember = false;
                    }
                } else {
                    wrapperObjectToReturn.isAlreadyMember = false;
                }
            } else {
                wrapperObjectToReturn.isConferance = false;
                wrapperObjectToReturn.isAlreadyMember = false;
            }
        } catch(Exception e) {
            System.debug('Error in fetchCampaignDetailsById: ' + e.getMessage());
        }
        return wrapperObjectToReturn;
    }

    @AuraEnabled
    public static Boolean addMemberToCampaign(String campaignID, Integer guestCount){
        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(currentUser.ContactId == null) return false;

            List<CampaignMember> campaignMembers = [SELECT Id, Additional_Attendees__c, RSVP__c
                                                    FROM CampaignMember 
                                                    WHERE CampaignId = :campaignID AND ContactId = :currentUser.ContactId];

            if(!campaignMembers.isEmpty()){
                for(CampaignMember cm : campaignMembers){
                    cm.Additional_Attendees__c = guestCount;
                    cm.RSVP__c = true; // mark RSVP yes
                }
                update campaignMembers;
            } else {
                System.debug('No CampaignMember found for this user in campaign.');
                return false;
            }
        } catch(Exception e) {
            System.debug('Error in addMemberToCampaign: ' + e.getMessage());
            return false;
        }
        return true;
    }
   @AuraEnabled
    public static Boolean saveDeclinedToCampaign(String campaignID){
        try {
            User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if(currentUser.ContactId == null) return false;

            List<CampaignMember> campaignMembers = [
                SELECT Id, Declined__c
                FROM CampaignMember
                WHERE CampaignId = :campaignID
                AND ContactId   = :currentUser.ContactId
            ];

            if(!campaignMembers.isEmpty()){
                for(CampaignMember cm : campaignMembers){
                    cm.Declined__c = true;
                }
                update campaignMembers;
            } else {
                return false;
            }
        } catch(Exception e) {
            System.debug('Error in saveDeclinedToCampaign: ' + e.getMessage());
            return false;
        }
        return true;
    }
}