public class LeadManagementServices{
    
    public static List<DupResultsDTO> leadPreProcessing(List<Lead> LeadList, String context){
        
        /*Map<Lead,List<Lead>> leadEmailDupMap = DedupeChecker.findLeadDupeforLeads('EMAIL', leadList);
System.debug('lead email dup: ' + leadEmailDupMap);

Map<Lead,List<Account>> personAccountEmailDup = DedupeChecker.findPADupeforLeads('EMAIL',leadList);
System.debug('PA Email Dup: ' + personAccountEmailDup);

Map<Lead,List<Lead>> leadAltEmailDupMap = DedupeChecker.findLeadDupeforLeads('ALTEMAIL', leadList);
System.debug('lead email dup: ' + leadAltEmailDupMap);

Map<Lead,List<Account>> personAccountAltEmailDup = DedupeChecker.findPADupeforLeads('ALTEMAIL',leadList);
System.debug('PA Email Dup: ' + personAccountAltEmailDup);
*/
        
        // Added by Ubsdigicloud 07-07-25
        Map<Lead, List<Lead>> leadMobileDupMap = DeDupeChecker.findLeadDupeforLeads('COMPOSITE', leadList);

      //  Map<Lead, List<Lead>> leadMobileDupMap  = DedupeChecker.findLeadDupeforLeads('MOBILE', leadList);
        System.debug('Lead Mobile Dup: ' + leadMobileDupMap);
        
        Map<Lead,List<Account>>  PAMobileDupMap = DedupeChecker.findPADupeforLeads('MOBILE',leadList);
        System.debug('PA Mobile Duplicates: ' + PAMobileDupMap);
        
        Map<Lead, List<Lead>> leadAltMobileDupMap  = DedupeChecker.findLeadDupeforLeads('ALTMOBILE', leadList);
        System.debug('Lead Mobile Dup: ' + leadAltMobileDupMap);
        
        Map<Lead,List<Account>>  PAAltMobileDupMap = DedupeChecker.findPADupeforLeads('ALTMOBILE',leadList);
        System.debug('PA Mobile Duplicates: ' + PAAltMobileDupMap);
        
        Map<Lead, Map<String, List<Id>>> leadDupAgg = DedupeChecker.aggregateLeadDuplicates(leadMobileDupMap, PAMobileDupMap,leadAltMobileDupMap,PAAltMobileDupMap );
        System.debug('AggregatedDuplicates: ' + leadDupAgg);
        List<DupResultsDTO> dupResults = new List<DupResultsDTO>();
        if(leadDupAgg!=null & !leadDupAgg.isEmpty()) {
            // duplicates exists, based on the context of the method call, like batch loading, webservice call 
            // take context specific remedial action for duplicates
            dupResults = DedupeChecker.dupHandler(leadDupAgg, context);
        }
        
        return dupResults;
    }  
    // campaings are added to lead by inserting records in campaign Member table
    // since this would show up as a related and it is difficult to figure out 
    // which is first campaign through which the lead was created
    // adding a new field call System_Campaign__C in Lead which will be displayed as a
    // readonly field on lead layout
    // For leads coming in through calls, the toll free number will provide the campaigndetails
    // for web2lead the it will be the campaign code in the webform
    public static void SetSystemCampaignOnLead(List<Lead> leadList) {
        //Based on EnquiryMode for CALLS
        Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
        
        //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
        for(lead l:leadList) {
            if(l.TollFree_Number__c != null)  {
                if(campaignDetails.containsKey('TOLLFREENUMBER')) {
                    campaignDetails.get('TOLLFREENUMBER').add(l.TollFree_Number__C);
                } else {
                    List<String> tollFreeList = new List<String>();
                    tollFreeList.add(l.TollFree_Number__C);
                    campaignDetails.put('TOLLFREENUMBER', tollFreeList);
                }
            }
            if(l.Campaign_Code__C != null)  {
                if(campaignDetails.containsKey('CAMPAIGNCODE')) {
                    campaignDetails.get('CAMPAIGNCODE').add(l.Campaign_Code__C);
                } else {
                    List<String> codeList = new List<String>();
                    codeList.add(l.Campaign_Code__C);
                    campaignDetails.put('CAMPAIGNCODE', codeList);
                }
            }
        }
        Map<String,Campaign> searchResults = new Map<String,Campaign>();
        List < CampaignMember > cmList = new List < campaignMember > ();
        System.debug('CampaignDetails:' + CampaignDetails);
        if(campaignDetails != null && !campaignDetails.isEmpty())   
            searchResults = CampaignManagementServices.searchCampaign(CampaignDetails);
        for (lead l: leadList) {
            if (searchResults.containsKey(l.TollFree_Number__c)) {
                if(searchResults.get(l.TollFree_Number__c).Is_Virtual_Number_Campaign__c) {
                    //CampaignMember cm = new CampaignMember(CampaignId = searchResults.get(l.TollFree_Number__c).Id, LeadId = l.Id, Status = 'Responded');
                    //cmList.add(cm);
                    l.RW_Lead_Sub_Source__c = searchResults.get(l.TollFree_Number__c).RW_Sub_Type__c; //added line to default the CCU source to system source on 20.7.15 UAT - comments
                    l.leadSource = searchResults.get(l.TollFree_Number__c).Type; //added line to map the leadsource to campaign type on 20.7.15 UAT - comments
                    l.RW_Project__c = searchResults.get(l.TollFree_Number__c).Primary_Project__c; //added 3/1/16. The DM campaigns will just send the campaign code. the project has to be identified from the campaign record
                }
            }
            /**if (searchResults.containsKey(l.Campaign_Code__C)) {
CampaignMember cm = new CampaignMember(CampaignId = searchResults.get(l.Campaign_Code__C).Id, LeadId = l.Id, Status = 'Responded');
cmList.add(cm);
l.RW_Lead_Sub_Source__c = searchResults.get(l.Campaign_Code__C).RW_Sub_Type__c; //added line to default the CCU source to system source on 20.7.15 UAT - comments
l.leadSource = searchResults.get(l.Campaign_Code__C).Type; //added line to map the leadsource to campaign type on 20.7.15 UAT - comments
l.RW_Project__c = searchResults.get(l.Campaign_Code__C).Primary_Project__c;
}
**/
        }
        System.debug('Lead Source Details:' + LeadList);
        
    }
    public static void AddCampaignToLead(List<Lead> leadList) {
        //Based on EnquiryMode for CALLS
        Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
        
        //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
        for(lead l:leadList) {
            if(l.TollFree_Number__c != null)  {
                if(campaignDetails.containsKey('TOLLFREENUMBER')) {
                    campaignDetails.get('TOLLFREENUMBER').add(l.TollFree_Number__C);
                } else {
                    List<String> tollFreeList = new List<String>();
                    tollFreeList.add(l.TollFree_Number__C);
                    campaignDetails.put('TOLLFREENUMBER', tollFreeList);
                }
            }
            if(l.Campaign_Code__C != null)  {
                if(campaignDetails.containsKey('CAMPAIGNCODE')) {
                    campaignDetails.get('CAMPAIGNCODE').add(l.Campaign_Code__C);
                } else {
                    List<String> codeList = new List<String>();
                    codeList.add(l.Campaign_Code__C);
                    campaignDetails.put('CAMPAIGNCODE', codeList);
                }
            }
            // change made on 11-7-15, to fix the gap in code where, the lead is added as member of
            // CCU campaigns and site visit campaigns 
            
        }
        Map<String,Campaign> searchResults = new Map<String,Campaign>();
        
        System.debug('CampaignDetails:' + CampaignDetails);
        if(campaignDetails != null && !campaignDetails.isEmpty())   
            searchResults = CampaignManagementServices.searchCampaign(CampaignDetails);
        
        // create a Map like below
        // [campaingnA, [List of Lead to add to that campaign]
        //   campaignB, [List of leads to add to that campaign]]
        Map<Campaign,Set<lead>> campaignMap = new Map<Campaign,Set<Lead>>();
        
        for(lead l: leadList) {
            if(searchResults.containsKey(l.TollFree_Number__c)) {
                Campaign c= searchResults.get(l.TollFree_Number__c);
                if(campaignMap.containsKey(c)){
                    campaignMap.get(c).add(l);
                } else {
                    Set<lead> ll = new Set<Lead>();
                    ll.add(l);
                    campaignMap.put(c,ll);
                }
            }
            
            if(searchResults.containsKey(l.Campaign_Code__c)) {
                Campaign c= searchResults.get(l.Campaign_Code__c);
                if(campaignMap.containsKey(c)){
                    campaignMap.get(c).add(l);
                } else {
                    Set<lead> ll = new Set<Lead>();
                    ll.add(l);
                    campaignMap.put(c,ll);
                }
            }            
            
        }
        CampaignManagementServices.addCampaignToLead(campaignMap);
    } 
    
    
    
    
}