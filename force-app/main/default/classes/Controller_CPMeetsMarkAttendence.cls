public with sharing class Controller_CPMeetsMarkAttendence {
    public static String CPMeetsCampaign = System.label.CPMeetsCampaign;
    
    // ------------------ Campaign Name Suggestions ------------------
    @AuraEnabled(cacheable=true)
    public static List<Campaign> getCampaignNameSuggestions(String searchKey) {
        if (String.isBlank(searchKey)) return new List<Campaign>();
        
        String likePattern = '%' + searchKey + '%';
        return [
            SELECT Id, Name
            FROM Campaign
            WHERE Type__c = :CPMeetsCampaign
            AND Name LIKE :likePattern AND Event_Date_Time__c >= Today
            ORDER BY Name
        ];
    }
    
    // ------------------ CampaignMember Status Picklist ------------------
    /* @AuraEnabled(cacheable=true)
public static List<String> getStatusPicklistValues() {
List<String> values = new List<String>();
Schema.DescribeFieldResult fieldResult = CampaignMember.Status.getDescribe();
for (Schema.PicklistEntry p : fieldResult.getPicklistValues()) {
values.add(p.getLabel());
}
return values;
}
*/
    // ------------------ Get Members By Campaign Name (for LWC table) ------------------
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getMembersByCampaignName(String searchKey) {
        if (String.isBlank(searchKey)) return new List<CampaignMember>();
        
        String likePattern = '%' + searchKey + '%';
        
        // Find campaigns matching the name
        List<Campaign> lstCampaign = [
            SELECT Id
            FROM Campaign
            WHERE Type__c = :CPMeetsCampaign
            AND Name LIKE :likePattern AND Event_Date_Time__c >= Today
        ];
        
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign c : lstCampaign) {
            campaignIds.add(c.Id);
        }
        
        if (campaignIds.isEmpty()) return new List<CampaignMember>();
        
        return [
            SELECT Id, CampaignId, Campaign.Name, Status, Additional_Attendees__c, RSVP__c,
            Contact.Name, Contact.Email, MobilePhone, Total_Attendees__c, Is_Attended__c
            FROM CampaignMember
            WHERE CampaignId IN :campaignIds //AND RSVP__c = TRUE
        ];
    }
    
    // ------------------ Get Members By Selected Campaign & Member Name ------------------
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getMembersByCampaignIdAndName(Id campaignId, String searchKey) {
        if (String.isBlank(campaignId)) return new List<CampaignMember>();
        
        String likePattern = '%' + (searchKey == null ? '' : searchKey) + '%';
        
        return [
            SELECT Id, CampaignId, Campaign.Name, Status, Additional_Attendees__c,RSVP__c,
            Contact.Name, Contact.Email, MobilePhone, Total_Attendees__c, Is_Attended__c
            FROM CampaignMember
            WHERE CampaignId = :campaignId
            AND Contact.Name LIKE :likePattern// AND RSVP__c = TRUE
        ];
    }
    
    // ------------------ Member Name Suggestions for Selected Campaign ------------------
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getMemberNameSuggestions(Id campaignId, String searchKey) {
        if (String.isBlank(campaignId) || String.isBlank(searchKey)) return new List<CampaignMember>();
        
        String likePattern = '%' + searchKey + '%';
        return [
            SELECT Id, Contact.Name, RSVP__c
            FROM CampaignMember
            WHERE CampaignId = :campaignId
            AND Contact.Name LIKE :likePattern /*AND RSVP__c = TRUE*/
            ORDER BY Contact.Name
        ];
    }
    
    // ------------------ Get Members By Member Name Across All Campaigns ------------------
    @AuraEnabled(cacheable=true)
    public static List<CampaignMember> getMembersByMemberName(String searchKey) {
        if (String.isBlank(searchKey)) return new List<CampaignMember>();
        
        String likePattern = '%' + searchKey + '%';
        return [
            SELECT Id, CampaignId, Campaign.Name, Status, Additional_Attendees__c,
            RSVP__c, Contact.Name, Contact.Email, MobilePhone, Total_Attendees__c, Is_Attended__c
            FROM CampaignMember
            WHERE Campaign.Type__c = :CPMeetsCampaign
            AND Contact.Name LIKE :likePattern //AND RSVP__c = TRUE
        ];
    }
    
    // ------------------ Update CampaignMember Attendance ------------------
    @AuraEnabled
    public static void updateCampaignMemberStatus(List<CampaignMember> lstMember) {
        if (lstMember == null || lstMember.isEmpty()) return;
        
        List<CampaignMember> lstToUpdate = new List<CampaignMember>();
        
        for (CampaignMember objMember : lstMember) {
            if (objMember.Id != null) {
                CampaignMember cm = new CampaignMember();
                cm.Id = objMember.Id;
                if (objMember.Is_Attended__c != null) {
                    cm.Is_Attended__c = objMember.Is_Attended__c;
                }
                if (objMember.Total_Attendees__c != null) {
                    cm.Total_Attendees__c = objMember.Total_Attendees__c;
                }
                lstToUpdate.add(cm);
            }
        }
        system.debug('lstToUpdate>>' +lstToUpdate);
        if (!lstToUpdate.isEmpty()) {
            update lstToUpdate;
        }
    }
}