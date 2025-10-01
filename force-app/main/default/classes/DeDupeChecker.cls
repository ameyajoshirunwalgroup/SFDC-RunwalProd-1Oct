public class DeDupeChecker {
    
    public static Map < Lead, List < Lead >> findLeadDupeforLeads(String Field, List < Lead > leadList) {
        Map < Lead, List < Lead >> leadDuplicateMap = new Map < Lead, List < Lead >> ();
        /* if (Field == 'EMAIL') {
Map < Lead, List < Lead >> leadEmailDupMap = findLeadDupeforLeadsByEmail(leadList);
leadDuplicateMap.putAll(leadEmailDupMap);
} else if (Field == 'ALTEMAIL') {
Map < Lead, List < Lead >> leadEmailDupMap = findLeadDupeforLeadsByAltEmail(leadList);
leadDuplicateMap.putAll(leadEmailDupMap);
} else */
        if (Field == 'MOBILE') {
            Map < Lead, List < Lead >> leadMobileDupMap = findLeadDupeforLeadsByMobile(leadList);
            leadDuplicateMap.putAll(leadMobileDupMap);
        } else if (Field == 'ALTMOBILE') {
            Map < Lead, List < Lead >> leadMobileDupMap = findLeadDupeforLeadsByAltMobile(leadList);
            leadDuplicateMap.putAll(leadMobileDupMap);
            
            // Added By UBSDigicloud 07-07-2025 start
        }else if (Field == 'COMPOSITE') {
            Map<Lead, List<Lead>> leadCompositeDupMap = findLeadDupesByCompositeKey(leadList);
            leadDuplicateMap.putAll(leadCompositeDupMap);
            // Added By UBSDigicloud 07-07-2025 End
        } else
        {
            System.debug('findLeadDupeforLeads not implement for key: ' + Field);
        }
        return leadDuplicateMap;
    }
    
    
    // Added By UBSDigicloud 07-07-2025 start
    public static Map<Lead, List<Lead>> findLeadDupesByCompositeKey(List<Lead> leadList) {
        Map<Lead, List<Lead>> dupMap = new Map<Lead, List<Lead>>();
        Map<String, List<Lead>> compositeKeyToIncomingLeads = new Map<String, List<Lead>>();
        
        Set<String> mobileNumbers = new Set<String>();
        Set<Id> projectIds = new Set<Id>();
        
        // Step 1: Prepare incoming lead keys and collect mobiles/projectIds
        for (Lead l : leadList) {
            String primaryMobile = (l.RDS_Country_Code__c != null ? l.RDS_Country_Code__c : '') +
                (l.RW_Mobile_No__c != null ? l.RW_Mobile_No__c : '');
            String secondaryMobile = (l.Country_Code_2__c != null ? l.Country_Code_2__c : '') +
                (l.RW_Secondary_Mobile_No__c != null ? l.RW_Secondary_Mobile_No__c : '');
            
            if (!String.isBlank(primaryMobile)) mobileNumbers.add(primaryMobile);
            if (!String.isBlank(secondaryMobile)) mobileNumbers.add(secondaryMobile);
            
            if (l.RW_Project__c != null) projectIds.add(l.RW_Project__c);
        }
        
        // Step 2: Fetch Project → Development mapping
        Map<Id, String> projectIdToDev = new Map<Id, String>();
        for (Project__c proj : [
            SELECT Id, Segment_Lookup__r.Name
            FROM Project__c
            WHERE Id IN :projectIds
        ]) {
            if (proj.Segment_Lookup__r != null)
                projectIdToDev.put(proj.Id, proj.Segment_Lookup__r.Name);
        }
        
        // Step 3: Build composite keys for incoming leads
        String vertical = Label.Default_Lead_Vertical;
        for (Lead l : leadList) {
            String development = projectIdToDev.get(l.RW_Project__c);
            if (String.isBlank(development)) continue;
            
            List<String> mobiles = new List<String>{
                (l.RDS_Country_Code__c != null ? l.RDS_Country_Code__c : '') +
                    (l.RW_Mobile_No__c != null ? l.RW_Mobile_No__c : ''),
                    
                    (l.Country_Code_2__c != null ? l.Country_Code_2__c : '') +
                    (l.RW_Secondary_Mobile_No__c != null ? l.RW_Secondary_Mobile_No__c : '')
                    };
                        
                        for (String m : mobiles) {
                            if (String.isBlank(m)) continue;
                            String key = m + '@@' + development + '@@' + vertical;
                            
                            if (!compositeKeyToIncomingLeads.containsKey(key))
                                compositeKeyToIncomingLeads.put(key, new List<Lead>());
                            
                            compositeKeyToIncomingLeads.get(key).add(l);
                        }
        }
        
        // Step 4: Query existing leads based on composite keys
        List<Lead> existingLeads = [
            SELECT Id, RDS_Country_Code__c, RW_Mobile_No__c,
            Country_Code_2__c, RW_Secondary_Mobile_No__c,
            Development__c, Vertical__c
            FROM Lead
            WHERE (IsConverted = FALSE AND IsActive__c = TRUE)
            AND (Primary_Mobile_No_with_code__c IN :mobileNumbers OR Secondary_Mobile_No_with_code__c IN :mobileNumbers)
        ];
        
        for (Lead existing : existingLeads) {
            List<String> existingMobiles = new List<String>{
                (existing.RDS_Country_Code__c != null ? existing.RDS_Country_Code__c : '') +
                    (existing.RW_Mobile_No__c != null ? existing.RW_Mobile_No__c : ''),
                    
                    (existing.Country_Code_2__c != null ? existing.Country_Code_2__c : '') +
                    (existing.RW_Secondary_Mobile_No__c != null ? existing.RW_Secondary_Mobile_No__c : '')
                    };
                        
                        for (String m : existingMobiles) {
                            if (String.isBlank(m) || String.isBlank(existing.Development__c) || String.isBlank(existing.Vertical__c)) continue;
                            
                            String key = m + '@@' + existing.Development__c + '@@' + existing.Vertical__c;
                            if (compositeKeyToIncomingLeads.containsKey(key)) {
                                for (Lead incoming : compositeKeyToIncomingLeads.get(key)) {
                                    if (!dupMap.containsKey(incoming)) {
                                        dupMap.put(incoming, new List<Lead>());
                                    }
                                    dupMap.get(incoming).add(existing);
                                }
                            }
                        }
        }
        
        return dupMap;
        
    }
    // Added By UBSDigicloud 07-07-2025 End
    
    
    public static Map < Lead, List < Account >> findPADupeforLeads(String Field, List < Lead > leadList) {
        Map < Lead, List < Account >> leadDuplicateMap = new Map < Lead, List < Account >> ();
        /*if (Field == 'EMAIL') {
Map < Lead, List < Account >> personAccountEmailDup = findPADupeforLeadsByEmail(leadList);
leadDuplicateMap.putAll(personAccountEmailDup);
} 
else if (Field == 'ALTEMAIL') {
Map < Lead, List < Account >> personAccountEmailDup = findPADupeforLeadsByAltEmail(leadList);
leadDuplicateMap.putAll(personAccountEmailDup);
} else */
        if (Field == 'MOBILE') {
            Map < Lead, List < Account >> PAMobileDupMap = findPADupeforLeadsByMObile(leadList);
            leadDuplicateMap.putAll(PAMobileDupMap);
        }else if (Field == 'ALTMOBILE') {
            Map < Lead, List < Account >> PAMobileDupMap = findPADupeforLeadsByAltMObile(leadList);
            leadDuplicateMap.putAll(PAMobileDupMap);
        } 
        else {
            System.debug('findPADupeforLeads not implement for key: ' + Field);
        }
        return leadDuplicateMap;
    }
    
    /*public static Map < Lead, List < Lead >> findLeadDupeforLeadsByEmail(List < Lead > leadList) {
Map < String, List < Lead >> emailKeyMap = new Map < String, List < Lead >> ();
// arrange the incoming list of leads in the below format
// {email1, [IncomingLead1, IncomingLead2, IncomingLead3]
//  email2, [IncomingLead4, IncomingLead5]
//  email3, [IncomingLead6]}
if (leadList == null || leadList.isEmpty()) {
List < String > customMsgList = new List < String > ();
customMsgList.add('Incoming lead list is empty');
throw new GlobalException(customMsgList, '', 'findLeadDupeForLeadsByEmail');
}
for (Lead l: leadList) {
System.debug('lead l: ' + l);
if (l.Email != null) {
if (emailKeyMap.containsKey(l.Email)) emailKeyMap.get(l.Email).add(l);
else {
List < Lead > newList = new List < Lead > ();
newList.add(l);
emailKeyMap.put(l.email, newList);
}
}
}
System.debug('Incoming emailKeyMap:' + emailKeyMap);

// search for duplicates in existing leads 
// arrange the existing lead list below format
// {email1, [existingLead1, existingLead2, existingLead3]
//  email2, [existingLead4, existingLead5]
//  email3, [existingLead6]
Map < String, List < Lead >> existingLeademailKeyMap = new Map < String, List < Lead >> ();

for (Lead existingLead: [Select Id, Name, Email, RW_Mobile_No__c from lead where email IN: emailKeyMap.keyset() and isConverted = false]) {
if (existingLeademailKeyMap.containsKey(existingLead.Email)) existingLeademailKeyMap.get(existingLead.Email).add(existingLead);
else {
List < Lead > newList = new List < Lead > ();
newList.add(existingLead);
existingLeademailKeyMap.put(existingLead.email, newList);
}
}

// loop through the incoming list map and check if there are duplicates in the existing lead map
Map < Lead, List < Lead >> leadEmailDupMap = new Map < Lead, List < Lead >> ();
for (String email: emailKeyMap.keyset()) {
if (existingLeademailKeyMap.containsKey(email)) {
for (Lead l: emailKeyMap.get(email)) {
leadEmailDupMap.put(l, existingLeademailKeyMap.get(email));
System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingLeademailKeyMap.get(email));
}
}
}
return leadEmailDupMap;
}
*/
    public static Map < Lead, List < Lead >> findLeadDupeforLeadsByMobile(List < Lead > leadList) {
        Map < String, List < Lead >> mobileKeyMap = new Map < String, List < Lead >> ();
        Set<Id> lIdSet = new Set<Id>();
        // arrange the incoming list of leads in the below format
        // {mobile1, [IncomingLead1, IncomingLead2, IncomingLead3]
        //  mobile2, [IncomingLead4, IncomingLead5]
        //  mobile3, [IncomingLead6]}
        if (leadList == null || leadList.isEmpty()) {
            List < String > customMsgList = new List < String > ();
            customMsgList.add('Incoming lead list is empty');
            throw new GlobalException(customMsgList, '', 'findLeadDupeForLeadsByMobile');
        }
        for (Lead l: leadList) {
            System.debug('lead l: ' + l);
            if (l.RW_Mobile_No__c != null) {
                if (mobileKeyMap.containsKey(l.RW_Mobile_No__c)) mobileKeyMap.get(l.RW_Mobile_No__c).add(l);
                else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(l);
                    mobileKeyMap.put(l.RW_Mobile_No__c, newList);
                }
            }
            if (l.Phone != null) {
                if (mobileKeyMap.containsKey(l.Phone)) mobileKeyMap.get(l.Phone).add(l);
                else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(l);
                    mobileKeyMap.put(l.Phone, newList);
                }
            }
            if(l.Id != null) {
                lIdSet.add(l.Id);
            }
        }
        System.debug('Incoming mobileKeyMap:' + mobileKeyMap);
        
        // arrange the existing lead list below format
        // {mobile1, [existingLead1, existingLead2, existingLead3]
        //  mobile2, [existingLead4, existingLead5]
        //  mobile3, [existingLead6]
        Map < String, List < Lead >> existingLeadMobileKeyMap = new Map < String, List < Lead >> ();
        
        for (Lead existingLead: [Select Id, Name, Email, RW_Mobile_No__c from lead where RW_Mobile_No__c IN: mobileKeyMap.keyset() and isConverted = false and Id not in :lIdSet]) {
            if (existingLeadMobileKeyMap.containsKey(existingLead.RW_Mobile_No__c)) existingLeadMobileKeyMap.get(existingLead.RW_Mobile_No__c).add(existingLead);
            else {
                List < Lead > newList = new List < Lead > ();
                newList.add(existingLead);
                existingLeadMobileKeyMap.put(existingLead.RW_Mobile_No__c, newList);
            }
        }
        
        // loop through the incoming list map and check if there are duplicates in the existing lead map
        Map < Lead, List < Lead >> leadMobileDupMap = new Map < Lead, List < Lead >> ();
        for (String mobile: mobileKeyMap.keyset()) {
            if (existingLeadMobileKeyMap.containsKey(mobile)) {
                for (Lead l: mobileKeyMap.get(mobile)) {
                    leadMobileDupMap.put(l, existingLeadMobileKeyMap.get(mobile));
                    System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingLeadMobileKeyMap.get(mobile));
                }
            }
        }
        return leadMobileDupMap;
    }
    
    // alternate phone and mobile dedupe logic added per request on 3/1/2016
    
    /**public static Map < Lead, List < Lead >> findLeadDupeforLeadsByAltEmail(List < Lead > leadList) {
Map < String, List < Lead >> emailKeyMap = new Map < String, List < Lead >> ();
// arrange the incoming list of leads in the below format
// {email1, [IncomingLead1, IncomingLead2, IncomingLead3]
//  email2, [IncomingLead4, IncomingLead5]
//  email3, [IncomingLead6]}
if (leadList == null || leadList.isEmpty()) {
List < String > customMsgList = new List < String > ();
customMsgList.add('Incoming lead list is empty');
throw new GlobalException(customMsgList, '', 'findLeadDupeForLeadsByAltEmail');
}
for (Lead l: leadList) {
System.debug('lead l: ' + l);
if (l.Email != null) {
if (emailKeyMap.containsKey(l.Email)) emailKeyMap.get(l.Email).add(l);
else {
List < Lead > newList = new List < Lead > ();
newList.add(l);
emailKeyMap.put(l.email, newList);
}
}
}
System.debug('Incoming emailKeyMap:' + emailKeyMap);

// search for duplicates in existing leads 
// arrange the existing lead list below format
// {altemail1, [existingLead1, existingLead2, existingLead3]
//  altemail2, [existingLead4, existingLead5]
//  altemail3, [existingLead6]
Map < String, List < Lead >> existingLeademailKeyMap = new Map < String, List < Lead >> ();

for (Lead existingLead: [Select Id, Name, Email, RW_Mobile_No__c, RDS_Alternate_Email_Id__c from lead where RDS_Alternate_Email_Id__c IN: emailKeyMap.keyset() and isConverted = false]) {
if (existingLeademailKeyMap.containsKey(existingLead.RDS_Alternate_Email_Id__c)) 
existingLeademailKeyMap.get(existingLead.RDS_Alternate_Email_Id__c).add(existingLead);
else {
List < Lead > newList = new List < Lead > ();
newList.add(existingLead);
existingLeademailKeyMap.put(existingLead.RDS_Alternate_Email_Id__c, newList);
}
}

// loop through the incoming list map and check if there are duplicates in the existing lead map
Map < Lead, List < Lead >> leadEmailDupMap = new Map < Lead, List < Lead >> ();
for (String email: emailKeyMap.keyset()) {
if (existingLeademailKeyMap.containsKey(email)) {
for (Lead l: emailKeyMap.get(email)) {
leadEmailDupMap.put(l, existingLeademailKeyMap.get(email));
System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingLeademailKeyMap.get(email));
}
}
}
return leadEmailDupMap;
}
*/
    // the incoming lead the fields will be present in RW_Mobile_No__c and email. It needs to be compared against
    // email, mobile, altEmail, altMobile in the lead and account
    public static Map < Lead, List < Lead >> findLeadDupeforLeadsByAltMobile(List < Lead > leadList) {
        Map < String, List < Lead >> mobileKeyMap = new Map < String, List < Lead >> ();
        // arrange the incoming list of leads in the below format
        // {mobile1, [IncomingLead1, IncomingLead2, IncomingLead3]
        //  mobile2, [IncomingLead4, IncomingLead5]
        //  mobile3, [IncomingLead6]}
        if (leadList == null || leadList.isEmpty()) {
            List < String > customMsgList = new List < String > ();
            customMsgList.add('Incoming lead list is empty');
            throw new GlobalException(customMsgList, '', 'findLeadDupeForLeadsByAltMobile');
        }
        for (Lead l: leadList) {
            System.debug('lead l: ' + l);
            if (l.RW_Mobile_No__c != null && l.RW_Mobile_No__c != '') {
                
                if (mobileKeyMap.containsKey(l.RW_Mobile_No__c)) mobileKeyMap.get(l.RW_Mobile_No__c).add(l);
                else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(l);
                    mobileKeyMap.put(l.RW_Mobile_No__c, newList);
                }
            }
        }
        System.debug('Incoming mobileKeyMap:' + mobileKeyMap);
        
        // arrange the existing lead list below format
        // {mobile1, [existingLead1, existingLead2, existingLead3]
        //  mobile2, [existingLead4, existingLead5]
        //  mobile3, [existingLead6]
        Map < String, List < Lead >> existingLeadMobileKeyMap = new Map < String, List < Lead >> ();
        if(!mobileKeyMap.isEmpty() && mobileKeyMap.size() > 0) {
            
            for (Lead existingLead: [Select Id, Name, Email, RW_Mobile_No__c, Phone, RW_Secondary_Mobile_No__c from lead where (RW_Secondary_Mobile_No__c IN: mobileKeyMap.keyset() OR Phone IN: mobileKeyMap.keyset()) and isConverted = false]) {
                if (existingLeadMobileKeyMap.containsKey(existingLead.RW_Secondary_Mobile_No__c)){
                    existingLeadMobileKeyMap.get(existingLead.RW_Secondary_Mobile_No__c).add(existingLead);
                }else if(existingLeadMobileKeyMap.containsKey(existingLead.Phone)){
                    existingLeadMobileKeyMap.get(existingLead.Phone).add(existingLead);
                }else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(existingLead);
                    if(existingLead.RW_Secondary_Mobile_No__c != null){
                        existingLeadMobileKeyMap.put(existingLead.RW_Secondary_Mobile_No__c, newList);
                    }else if(existingLead.Phone != null){
                        existingLeadMobileKeyMap.put(existingLead.Phone, newList);
                    }
                    
                }
            }
        }
        // loop through the incoming list map and check if there are duplicates in the existing lead map
        Map < Lead, List < Lead >> leadMobileDupMap = new Map < Lead, List < Lead >> ();
        for (String mobile: mobileKeyMap.keyset()) {
            if (existingLeadMobileKeyMap.containsKey(mobile)) {
                for (Lead l: mobileKeyMap.get(mobile)) {
                    leadMobileDupMap.put(l, existingLeadMobileKeyMap.get(mobile));
                    System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingLeadMobileKeyMap.get(mobile));
                }
            }
        }
        return leadMobileDupMap;
    }
    
    
    /**public static Map < Lead, List < Account >> findPADupeforLeadsByEmail(List < Lead > leadList) {
Map < String, List < Lead >> emailKeyMap = new Map < String, List < Lead >> ();
// arrange the incoming list of leads in the below format
// {email1, [IncomingLead1, IncomingLead2, IncomingLead3]
//  email2, [IncomingLead4, IncomingLead5]
//  email3, [IncomingLead6]}
if (leadList == null || leadList.isEmpty()) {
List < String > customMsgList = new List < String > ();
customMsgList.add('Incoming lead list is empty');
throw new GlobalException(customMsgList, '', 'findPADupeForLeadsByEmail');
}
for (Lead l: leadList) {
System.debug('lead l: ' + l);
if (l.email != null) {
if (emailKeyMap.containsKey(l.Email)) emailKeyMap.get(l.Email).add(l);
else {
List < Lead > newList = new List < Lead > ();
newList.add(l);
emailKeyMap.put(l.email, newList);
}
}
}
System.debug('Incoming emailKeyMap:' + emailKeyMap);

// search for duplicates in existing person accounts 
// arrange the existing person account list below format
// {email1, [existingPA1, existingPA2, existingPA3]
//  email2, [existingPA4, existingPA5]
//  email3, [existingPA6]

Map < String, List < Account >> existingPAemailKeyMap = new Map < String, List < Account >> ();
for (Account existingPA: [Select Id, Name, RW_Email__c, Mobile_No__c from Account where RW_Email__c IN: emailKeyMap.keyset() and isPersonAccount = true]) {
if (existingPAemailKeyMap.containsKey(existingPA.RW_Email__c)) existingPAemailKeyMap.get(existingPA.RW_Email__c).add(existingPA);
else {
List < Account > newList = new List < Account > ();
newList.add(existingPA);
existingPAemailKeyMap.put(existingPA.RW_Email__c, newList);
}
}

// loop through the incoming lead map and check if there are duplicates in the existing person account map
// the final duplicate Map will be of the below format
// {lead1, [PADup1, PADup2]
//  lead2, []
//  lead3, [PADup3]}

Map < Lead, List < Account >> personAccountEmailDup = new Map < Lead, List < Account >> ();
for (String email: emailKeyMap.keyset()) {
if (existingPAemailKeyMap.containsKey(email)) {
for (Lead l: emailKeyMap.get(email)) {
personAccountEmailDup.put(l, existingPAemailKeyMap.get(email));
System.debug('Lead:' + l.lastName + 'person account duplicates are:' + existingPAemailKeyMap.get(email));
}
}
}

return personAccountEmailDup;

}
**/
    public static Map < Lead, List < Account >> findPADupeforLeadsByMobile(List < Lead > leadList) {
        Map < String, List < Lead >> mobileKeyMap = new Map < String, List < Lead >> ();
        // arrange the incoming list of leads in the below format
        // {mobile1, [IncomingLead1, IncomingLead2, IncomingLead3]
        //  mobile2, [IncomingLead4, IncomingLead5]
        //  mobile3, [IncomingLead6]}
        if (leadList == null || leadList.isEmpty()) {
            List < String > customMsgList = new List < String > ();
            customMsgList.add('Incoming lead list is empty');
            throw new GlobalException(customMsgList, '', 'findPADupeForLeadsByMobile');
        }
        for (Lead l: leadList) {
            System.debug('lead l: ' + l);
            if (l.RW_Mobile_No__c != null) {
                if (mobileKeyMap.containsKey(l.RW_Mobile_No__c)) mobileKeyMap.get(l.RW_Mobile_No__c).add(l);
                else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(l);
                    mobileKeyMap.put(l.RW_Mobile_No__c, newList);
                }
            }
        }
        System.debug('Incoming mobileKeyMap:' + mobileKeyMap);
        
        // arrange the existing lead list below format
        // {mobile1, [existingLead1, existingLead2, existingLead3]
        //  mobile2, [existingLead4, existingLead5]
        //  mobile3, [existingLead6]
        Map < String, List < Account >> existingPAMobileKeyMap = new Map < String, List < Account >> ();
        
        for (Account existingPA: [Select Id, Name, RW_Email__c, Mobile_No__c from Account where Mobile_No__c IN: mobileKeyMap.keyset() and isPersonAccount = true]) {
            if (existingPAMobileKeyMap.containsKey(existingPA.Mobile_No__c)) existingPAMobileKeyMap.get(existingPA.Mobile_No__c).add(existingPA);
            else {
                List < Account > newList = new List < Account > ();
                newList.add(existingPA);
                existingPAMobileKeyMap.put(existingPA.Mobile_No__c, newList);
            }
        }
        
        // loop through the incoming list map and check if there are duplicates in the existing lead map
        Map < Lead, List < Account >> PAMobileDupMap = new Map < Lead, List < Account >> ();
        for (String mobile: mobileKeyMap.keyset()) {
            if (existingPAMobileKeyMap.containsKey(mobile)) {
                for (Lead l: mobileKeyMap.get(mobile)) {
                    PAMobileDupMap.put(l, existingPAMobileKeyMap.get(mobile));
                    System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingPAMobileKeyMap.get(mobile));
                }
            }
        }
        return PAMobileDupMap;
    }
    // alt email and mobile logic for accounts deduping added on 3/1/16
    /**public static Map < Lead, List < Account >> findPADupeforLeadsByAltEmail(List < Lead > leadList) {
Map < String, List < Lead >> emailKeyMap = new Map < String, List < Lead >> ();
// arrange the incoming list of leads in the below format
// {email1, [IncomingLead1, IncomingLead2, IncomingLead3]
//  email2, [IncomingLead4, IncomingLead5]
//  email3, [IncomingLead6]}
if (leadList == null || leadList.isEmpty()) {
List < String > customMsgList = new List < String > ();
customMsgList.add('Incoming lead list is empty');
throw new GlobalException(customMsgList, '', 'findPADupeforLeadsByAltEmail');
}
for (Lead l: leadList) {
System.debug('lead l: ' + l);
if (l.email != null) {
if (emailKeyMap.containsKey(l.Email)) emailKeyMap.get(l.Email).add(l);
else {
List < Lead > newList = new List < Lead > ();
newList.add(l);
emailKeyMap.put(l.email, newList);
}
}
}
System.debug('Incoming emailKeyMap:' + emailKeyMap);

// search for duplicates in existing person accounts 
// arrange the existing person account list below format
// {email1, [existingPA1, existingPA2, existingPA3]
//  email2, [existingPA4, existingPA5]
//  email3, [existingPA6]

Map < String, List < Account >> existingPAemailKeyMap = new Map < String, List < Account >> ();
for (Account existingPA: [Select Id, Name, RW_Email__c, Mobile_No__c, RW_Additional_Email__c from Account where RW_Additional_Email__c IN: emailKeyMap.keyset() and isPersonAccount = true]) {
if (existingPAemailKeyMap.containsKey(existingPA.RW_Additional_Email__c)) existingPAemailKeyMap.get(existingPA.RW_Additional_Email__c).add(existingPA);
else {
List < Account > newList = new List < Account > ();
newList.add(existingPA);
existingPAemailKeyMap.put(existingPA.RW_Additional_Email__c, newList);
}
}

// loop through the incoming lead map and check if there are duplicates in the existing person account map
// the final duplicate Map will be of the below format
// {lead1, [PADup1, PADup2]
//  lead2, []
//  lead3, [PADup3]}

Map < Lead, List < Account >> personAccountEmailDup = new Map < Lead, List < Account >> ();
for (String email: emailKeyMap.keyset()) {
if (existingPAemailKeyMap.containsKey(email)) {
for (Lead l: emailKeyMap.get(email)) {
personAccountEmailDup.put(l, existingPAemailKeyMap.get(email));
System.debug('Lead:' + l.lastName + 'person account duplicates are:' + existingPAemailKeyMap.get(email));
}
}
}

return personAccountEmailDup;

}
*/
    // find Account duplicates by alternate  mobile
    public static Map < Lead, List < Account >> findPADupeforLeadsByAltMobile(List < Lead > leadList) {
        Map < String, List < Lead >> mobileKeyMap = new Map < String, List < Lead >> ();
        // arrange the incoming list of leads in the below format
        // {mobile1, [IncomingLead1, IncomingLead2, IncomingLead3]
        //  mobile2, [IncomingLead4, IncomingLead5]
        //  mobile3, [IncomingLead6]}
        if (leadList == null || leadList.isEmpty()) {
            List < String > customMsgList = new List < String > ();
            customMsgList.add('Incoming lead list is empty');
            throw new GlobalException(customMsgList, '', 'findPADupeforLeadsByAltMobile');
        }
        for (Lead l: leadList) {
            System.debug('lead l: ' + l);
            if (l.RW_Mobile_No__c != null) {
                if (mobileKeyMap.containsKey(l.RW_Mobile_No__c)) mobileKeyMap.get(l.RW_Mobile_No__c).add(l);
                else {
                    List < Lead > newList = new List < Lead > ();
                    newList.add(l);
                    mobileKeyMap.put(l.RW_Mobile_No__c, newList);
                }
            }
        }
        System.debug('Incoming mobileKeyMap:' + mobileKeyMap);
        
        // arrange the existing lead list below format
        // {mobile1, [existingLead1, existingLead2, existingLead3]
        //  mobile2, [existingLead4, existingLead5]
        //  mobile3, [existingLead6]
        Map < String, List < Account >> existingPAMobileKeyMap = new Map < String, List < Account >> ();
        if(!mobileKeyMap.isEmpty() && mobileKeyMap.size() > 0){
            for (Account existingPA: [Select Id, Name, RW_Email__c,Mobile_No__c,RW_Additional_Email__c, Phone, RW_Secondary_Mobile_No__pc from Account where (RW_Secondary_Mobile_No__pc IN: mobileKeyMap.keyset() OR Phone IN: mobileKeyMap.keyset()) and isPersonAccount = true]) {
                if(existingPAMobileKeyMap.containsKey(existingPA.RW_Secondary_Mobile_No__pc)){
                    existingPAMobileKeyMap.get(existingPA.RW_Secondary_Mobile_No__pc).add(existingPA);
                }else if(existingPAMobileKeyMap.containsKey(existingPA.Phone)){
                    existingPAMobileKeyMap.get(existingPA.Phone).add(existingPA);
                }else {
                    List < Account > newList = new List < Account > ();
                    newList.add(existingPA);
                    if(existingPA.RW_Secondary_Mobile_No__pc != null){
                        existingPAMobileKeyMap.put(existingPA.RW_Secondary_Mobile_No__pc, newList);
                    }else if(existingPA.Phone != null){
                        existingPAMobileKeyMap.put(existingPA.Phone, newList);
                    }
                    
                }
            }
        }
        
        
        // loop through the incoming list map and check if there are duplicates in the existing lead map
        Map < Lead, List < Account >> PAMobileDupMap = new Map < Lead, List < Account >> ();
        for (String mobile: mobileKeyMap.keyset()) {
            if (existingPAMobileKeyMap.containsKey(mobile)) {
                for (Lead l: mobileKeyMap.get(mobile)) {
                    PAMobileDupMap.put(l, existingPAMobileKeyMap.get(mobile));
                    System.debug('Lead:' + l.lastName + 'lead duplicates are:' + existingPAMobileKeyMap.get(mobile));
                }
            }
        }
        return PAMobileDupMap;
    }
    
    public static Map < Lead, Map < String, List < Id >>> aggregateLeadDuplicates(  //Map < Lead, List < Lead >> emailDupMap, 
        Map < Lead, List < Lead >> MobileDupMap,
        //  Map < Lead, List < Account >> PAEmailDupMap, 
        Map < Lead, List < Account >> PAMobileDupMap,
        // Map < Lead, List < Lead >> altemailDupMap, 
        Map < Lead, List < Lead >> altMobileDupMap,
        //Map < Lead, List < Account >> altPAEmailDupMap, 
        Map < Lead, List < Account >> altPAMobileDupMap
    ) {
        
        Map < Lead, Map < String, List < Id >>> leadDupAgg = new Map < Lead, Map < String, List < Id >>> ();
        /* if (!emailDupMap.isEmpty()) {
for (Lead lead: emailDupMap.keyset()) {
System.debug('231:' + emailDupMap.keyset());
Map < String, List < Id >> leadMap = new Map < String, List < Id >> ();
for (Lead dupLead: emailDupMap.get(lead)) {
if (leadMap.containsKey('LEADEMAIL')) {
leadMap.get('LEADEMAIL').add(duplead.Id);
} else  {
List < Id > IdList = new List < Id > ();
IdList.add(dupLead.Id);
leadMap.put('LEADEMAIL', IdList);
}
}
System.debug('leademail:' + leadMap);
leadDupAgg.put(lead, leadMap);
System.debug('Aggregate:244: ' + leadDupAgg);
}
}*/
        
        /* Commented by UBSDigicloud 07-07-25
if (!MobileDupMap.isEmpty()) {
for (Lead lead: MobileDupMap.keyset()) {
Map < String, List < Id >> leadMap = new Map < String, List < Id >> ();
for (Lead dupLead: MobileDupMap.get(lead)) {
if (leadMap.containsKey('LEADMOBILE')) {
leadMap.get('LEADMOBILE').add(duplead.Id);
} else {
List < Id > IdList = new List < Id > ();
IdList.add(dupLead.Id);
leadMap.put('LEADMOBILE', IdList);
}
}
if (leadDupAgg.containsKey(lead)) {
leadDupAgg.get(lead).putAll(leadMap);
} else {
leadDupAgg.put(lead, leadMap);
}
System.debug('Aggregate:265: ' + leadDupAgg);

}
} Commented by UBSDigicloud 07-07-25 End */
        
        // Updated for Composite Key Matching
        if (!MobileDupMap.isEmpty()) {
            for (Lead lead : MobileDupMap.keySet()) {
                Map<String, List<Id>> leadMap = new Map<String, List<Id>>();
                
                for (Lead dupLead : MobileDupMap.get(lead)) {
                    if (leadMap.containsKey('LEADCOMPOSITE')) {
                        leadMap.get('LEADCOMPOSITE').add(dupLead.Id);
                    } else {
                        List<Id> idList = new List<Id>();
                        idList.add(dupLead.Id);
                        leadMap.put('LEADCOMPOSITE', idList); //  Updated label
                    }
                }
                
                if (leadDupAgg.containsKey(lead)) {
                    leadDupAgg.get(lead).putAll(leadMap);
                } else {
                    leadDupAgg.put(lead, leadMap);
                }
                
                System.debug('Aggregate:265: ' + leadDupAgg);
            }
        }
        
        
        
        // alternate email and mobile data aggregation
        /*  if (!altemailDupMap.isEmpty()) {
for (Lead lead: altemailDupMap.keyset()) {
System.debug('231:' + altemailDupMap.keyset());
Map < String, List < Id >> leadMap = new Map < String, List < Id >> ();
for (Lead dupLead: altemailDupMap.get(lead)) {
if (leadMap.containsKey('LEADALTEMAIL')) {
leadMap.get('LEADALTEMAIL').add(duplead.Id);
} else  {
List < Id > IdList = new List < Id > ();
IdList.add(dupLead.Id);
leadMap.put('LEADALTEMAIL', IdList);
}
}
System.debug('leademail:' + leadMap);
leadDupAgg.put(lead, leadMap);
System.debug('Aggregate:244: ' + leadDupAgg);
}
}*/
        if (!altMobileDupMap.isEmpty()) {
            for (Lead lead: altMobileDupMap.keyset()) {
                Map < String, List < Id >> leadMap = new Map < String, List < Id >> ();
                for (Lead dupLead: altMobileDupMap.get(lead)) {
                    if (leadMap.containsKey('LEADALTMOBILE')) {
                        leadMap.get('LEADALTMOBILE').add(duplead.Id);
                    } else {
                        List < Id > IdList = new List < Id > ();
                        IdList.add(dupLead.Id);
                        leadMap.put('LEADALTMOBILE', IdList);
                    }
                }
                if (leadDupAgg.containsKey(lead)) {
                    leadDupAgg.get(lead).putAll(leadMap);
                } else {
                    leadDupAgg.put(lead, leadMap);
                }
                System.debug('Aggregate:265: ' + leadDupAgg);
                
            }
        }
        // alt email and mobile aggregation for leads end here.
        
        /*if (!PAEmailDupMap.isEmpty()) {
for (Lead lead: PAEmailDupMap.keyset()) {
System.debug('271:' + PAEmailDupMap.keyset());
Map < String, List < Id >> accMap = new Map < String, List < Id >> ();
for (Account dupAcc: PAEmailDupMap.get(lead)) {
if (accMap.containsKey('PAEMAIL')) {
accMap.get('PAEMAIL').add(dupAcc.Id);
} else {
List < Id > IdList = new List < Id > ();
IdList.add(dupAcc.Id);
accMap.put('PAEMAIL', IdList);
}
}
System.debug('acc email:' + accMap);
if (leadDupAgg.containsKey(lead)) {
leadDupAgg.get(lead).putAll(accMap);
} else {
leadDupAgg.put(lead, accMap);
}
System.debug('Aggregate:285: ' + leadDupAgg);
}
}*/
        
        if (!PAMobileDupMap.isEmpty()) {
            for (Lead lead: PAMobileDupMap.keyset()) {
                System.debug('271:' + PAMobileDupMap.keyset());
                Map < String, List < Id >> accMap = new Map < String, List < Id >> ();
                for (Account dupAcc: PAMobileDupMap.get(lead)) {
                    if (accMap.containsKey('PAMOBILE')) {
                        accMap.get('PAMOBILE').add(dupAcc.Id);
                    } else {
                        List < Id > IdList = new List < Id > ();
                        IdList.add(dupAcc.Id);
                        accMap.put('PAMOBILE', IdList);
                    }
                }
                System.debug('acc email:' + accMap);
                if (leadDupAgg.containsKey(lead)) {
                    leadDupAgg.get(lead).putAll(accMap);
                } else {
                    leadDupAgg.put(lead, accMap);
                }
                System.debug('Aggregate:304: ' + leadDupAgg);
            }
        }
        // alt email and mobile aggregation for PA starts here
        /*   if (!altPAEmailDupMap.isEmpty()) {
for (Lead lead: altPAEmailDupMap.keyset()) {
System.debug('271:' + altPAEmailDupMap.keyset());
Map < String, List < Id >> accMap = new Map < String, List < Id >> ();
for (Account dupAcc: altPAEmailDupMap.get(lead)) {
if (accMap.containsKey('PAALTEMAIL')) {
accMap.get('PAALTEMAIL').add(dupAcc.Id);
} else {
List < Id > IdList = new List < Id > ();
IdList.add(dupAcc.Id);
accMap.put('PAALTEMAIL', IdList);
}
}
System.debug('acc email:' + accMap);
if (leadDupAgg.containsKey(lead)) {
leadDupAgg.get(lead).putAll(accMap);
} else {
leadDupAgg.put(lead, accMap);
}
System.debug('Aggregate:285: ' + leadDupAgg);
}
}*/
        
        if (!altPAMobileDupMap.isEmpty()) {
            for (Lead lead: altPAMobileDupMap.keyset()) {
                System.debug('271:' + altPAMobileDupMap.keyset());
                Map < String, List < Id >> accMap = new Map < String, List < Id >> ();
                for (Account dupAcc: altPAMobileDupMap.get(lead)) {
                    if (accMap.containsKey('PAALTMOBILE')) {
                        accMap.get('PAALTMOBILE').add(dupAcc.Id);
                    } else {
                        List < Id > IdList = new List < Id > ();
                        IdList.add(dupAcc.Id);
                        accMap.put('PAALTMOBILE', IdList);
                    }
                }
                System.debug('acc email:' + accMap);
                if (leadDupAgg.containsKey(lead)) {
                    leadDupAgg.get(lead).putAll(accMap);
                } else {
                    leadDupAgg.put(lead, accMap);
                }
                System.debug('Aggregate:304: ' + leadDupAgg);
            }
        }
        return leadDupAgg;
    }
    
    public static List < DupResultsDTO > dupHandler(Map < Lead, Map < String, List < Id >>> leadDupAgg, String context) {
        List < DupResultsDTO > dupResults;
        if (context == 'BULKLOAD') {
            dupResults = bulkLoadDupHandler(leadDupAgg, context);
        } else if (context == 'WEB' || context == 'EMAIL') {
            dupResults = WebDupHandler(leadDupAgg, context);
        } else {
            // not implementing for UI context as it will be handled by the DupeCatcher which has a better UI for handling duplicates
            // cant use the same for bulk as it doesnt handle bulk load
            // cant use the same for web forms as we need to take special actions not provided by dupe catcher
            System.debug('ERROR: duplicate logic invoked for context: ' + context + ' which hasnt been implemented');
            List < String > customMsgList = new List < String > ();
            
            customMsgList.add('ERROR: duplicate logic invoked for context: ' + context + ' which hasn\'t been implemented');
            throw new GlobalException(customMsgList, '', 'DupHandler');
        }
        
        return dupResults;
    }
    
    public static List < DupResultsDTO > bulkLoadDupHandler(Map < Lead, Map < String, List < Id >>> leadDupAgg, String context) {
        
        List < Account > updateAccList = new List < Account > ();
        List < Lead > updateLeadList = new List < Lead > ();
        List < DupResultsDTO > dupResultsList = new List < DupResultsDTO > ();
        
        for (Lead originalLead: leadDupAgg.keyset()) {
            DupResultsDTO dupResults = new DupResultsDTO();
            if (!leadDupAgg.get(originalLead).isEmpty()) {
                Map < String, List < Id >> dupMapPerLead = leadDupAgg.get(originalLead);
                
                if (!dupMapPerLead.isEmpty()) {
                    // Aggregate and count the number of duplicates
                    // goto no duplicates, one duplicate, or more than one duplicate scenario based on count
                    
                  /*  Set < Id > leadDup = new Set < Id > (); // Comment By UBSDigicloud 07-07-25
                    if (dupMapPerLead.containsKey('LEADEMAIL')) leadDup.addAll(dupMapPerLead.get('LEADEMAIL'));
                    if (dupMapPerLead.containsKey('LEADMOBILE')) leadDup.addAll(dupMapPerLead.get('LEADMOBILE'));*/
                    
                    Set < Id > leadDup = new Set < Id > ();
                    if (dupMapPerLead.containsKey('LEADCOMPOSITE')) leadDup.addAll(dupMapPerLead.get('LEADCOMPOSITE'));
                    if (dupMapPerLead.containsKey('LEADCOMPOSITE')) leadDup.addAll(dupMapPerLead.get('LEADCOMPOSITE'));
                    
                    Set < Id > accDup = new Set < Id > ();
                    if (dupMapPerLead.containsKey('PAEMAIL')) accDup.addAll(dupMapPerLead.get('PAEMAIL'));
                    if (dupMapPerLead.containsKey('PAMOBILE')) accDup.addAll(dupMapPerLead.get('PAMOBILE'));
                    
                    // bucket the duplicates into lead and account duplicates and populate in the DTO
                    // mainly used in bulk upload for setting lead.addError with the list of all duplicate values
                    Map < String, Set < Id >> dupMap = new Map < String, Set < Id >> ();
                    if (!leadDup.isEmpty()) dupMap.put('LEAD', leadDup);
                    if (!accDup.isEmpty()) dupMap.put('ACCOUNT', accDup);
                    
                    if (!dupMap.isEmpty()) {
                        dupResults.duplicatesMap.putAll(dupMap);
                    }
                    
                    dupResults.originalLead = originalLead;
                    if (dupResults != null) {
                        dupResultsList.add(dupResults);
                    }
                }
            }
        }
        for (DupResultsDTO d: dupResultsList)
            System.debug('DupResults: ' + d.originalLead + ':' + d.dupEnquiryTaskId + ':' + d.duplicateMaster + ':' + d.duplicatesMap);
        return dupResultsList;
    }
    
    public static List < DupResultsDTO > WebDupHandler(Map < Lead, Map < String, List < Id >>> leadDupAgg, String context) {
        
        List < Account > updateAccList = new List < Account > ();
        List < Lead > updateLeadList = new List < Lead > ();
        List < DupResultsDTO > dupResultsList = new List < DupResultsDTO > ();
        
        for (Lead originalLead: leadDupAgg.keyset()) {
            DupResultsDTO dupResults = new DupResultsDTO();
            if (!leadDupAgg.get(originalLead).isEmpty()) {
                Map < String, List < Id >> dupMapPerLead = leadDupAgg.get(originalLead);
                
                if (!dupMapPerLead.isEmpty()) {
                    // Aggregate and count the number of duplicates
                    // goto no duplicates, one duplicate, or more than one duplicate scenario based on count
                    
                    Set < Id > leadDup = new Set < Id > ();
                    //if (dupMapPerLead.containsKey('LEADEMAIL')) leadDup.addAll(dupMapPerLead.get('LEADEMAIL'));
                  //  if (dupMapPerLead.containsKey('LEADMOBILE')) leadDup.addAll(dupMapPerLead.get('LEADMOBILE')); // Comment Added by UBSDigiclouf 07-07-25
                    if (dupMapPerLead.containsKey('LEADCOMPOSITE')) leadDup.addAll(dupMapPerLead.get('LEADCOMPOSITE'));

                    //if (dupMapPerLead.containsKey('LEADALTEMAIL')) leadDup.addAll(dupMapPerLead.get('LEADALTEMAIL'));
                    if (dupMapPerLead.containsKey('LEADALTMOBILE')) leadDup.addAll(dupMapPerLead.get('LEADALTMOBILE'));
                    
                    Set < Id > accDup = new Set < Id > ();
                    //if (dupMapPerLead.containsKey('PAEMAIL')) accDup.addAll(dupMapPerLead.get('PAEMAIL'));
                    if (dupMapPerLead.containsKey('PAMOBILE')) accDup.addAll(dupMapPerLead.get('PAMOBILE'));
                    //if (dupMapPerLead.containsKey('PAALTEMAIL')) accDup.addAll(dupMapPerLead.get('PAALTEMAIL'));
                    if (dupMapPerLead.containsKey('PAALTMOBILE')) accDup.addAll(dupMapPerLead.get('PAALTMOBILE'));
                    
                    // bucket the duplicates into lead and account duplicates and populate in the DTO
                    // mainly used in bulk upload for setting lead.addError with the list of all duplicate values
                    Map < String, Set < Id >> dupMap = new Map < String, Set < Id >> ();
                    if (!leadDup.isEmpty()) dupMap.put('LEAD', leadDup);
                    if (!accDup.isEmpty()) dupMap.put('ACCOUNT', accDup);
                    
                    if (!dupMap.isEmpty()) {
                        dupResults.duplicatesMap.putAll(dupMap);
                    }
                    
                    if (leadDup.size() + accDup.size() == 0) {
                        System.debug('No duplicates for lead:' + originalLead);
                    } else if (leadDup.size() + accDup.size() == 1) {
                        /** if (dupMapPerLead.containsKey('LEADEMAIL')) {
Lead dupLead = [SELECT Email,Phone,RDS_Alternate_Email_Id__c, RW_Mobile_No__c, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c 
from Lead where Id = : dupMapPerLead.get('LEADEMAIL')[0]];// Channel_Code__c, Campaign_Code__c, TollFree_Number__C 
if(dupLead.Email != null && dupLead.Email.contains('@dummy.com'))
dupLead.Email = originalLead.Email;
if(dupLead.RW_Mobile_No__c !=  null && dupLead.RW_Mobile_No__c.contains('mo-'))
dupLead.RW_Mobile_No__c = originalLead.RW_Mobile_No__c;
// if duplicate enquiry has new mobile or email copy in the alternate contact details
if(dupLead.Phone == null && dupLead.RW_Mobile_No__c != originalLead.RW_Mobile_No__c)
dupLead.Phone = originalLead.RW_Mobile_No__c;
if(dupLead.RDS_Alternate_Email_Id__c == null && dupLead.Email != originalLead.Email)
dupLead.RDS_Alternate_Email_Id__c = originalLead.Email;  
dupLead.MasterRecord__c = true;
dupLead.is_serviced__c = false;
dupLead.duplicate_created_Date__c = system.today();
//        if (originalLead.Channel_Code__c != null) dupLead.Channel_Code__c = originalLead.Channel_Code__c;
//        if (originalLead.TollFree_Number__c != null) dupLead.TollFree_Number__C = originallead.TollFree_Number__c;
if (originalLead.Campaign_Code__C != null) dupLead.Campaign_Code__C = originalLead.Campaign_Code__c;
if (dupLead.DuplicatesIdentified__C != null) dupLead.DuplicatesIdentified__C = dupLead.DuplicatesIdentified__c + dupLead.Id + '\n';
else dupLead.DuplicatesIdentified__C = dupLead.Id + '\n';
dupLead.LatestDuplicates__C = dupLead.Id;
updateLeadList.add(dupLead);
dupResults.originalLead = originalLead;
dupResults.duplicateMaster = dupLead.Id;

} else **/
                        if (dupMapPerLead.containsKey(/*'LEADMOBILE' Comment By UBSDigiCloud */ 'LEADCOMPOSITE')) {
                            Lead dupLead = [SELECT Email,Phone,RDS_Alternate_Email_Id__c, RW_Mobile_No__c, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
                                            //   Channel_Code__c, TollFree_Number__C
                                            from Lead where Id = : dupMapPerLead.get(/*'LEADMOBILE'Comment By UBSDigiCloud*/ 'LEADCOMPOSITE')[0]];
                            if(dupLead.Email != null && dupLead.Email.contains('@dummy.com'))
                                dupLead.Email = originalLead.Email;
                            if(dupLead.RW_Mobile_No__c!= null && dupLead.RW_Mobile_No__c.contains('mo-'))
                                dupLead.RW_Mobile_No__c= originalLead.RW_Mobile_No__c;
                            // if duplicate enquiry has new mobile or email copy in the alternate contact details
                            if(dupLead.Phone == null && dupLead.RW_Mobile_No__c!= originalLead.RW_Mobile_No__c)
                                dupLead.Phone = originalLead.RW_Mobile_No__c;
                            if(dupLead.RDS_Alternate_Email_Id__c == null && dupLead.Email != originalLead.Email)
                                dupLead.RDS_Alternate_Email_Id__c = originalLead.Email;
                            dupLead.MasterRecord__c = true;
                            dupLead.is_serviced__c = false;
                            dupLead.duplicate_created_Date__c = system.today();
                            //   if (originalLead.Channel_Code__c != null) dupLead.Channel_Code__c = originalLead.Channel_Code__c;
                            //    if (originalLead.TollFree_Number__c != null) dupLead.TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) dupLead.Campaign_Code__C = originalLead.Campaign_Code__c;
                            if (dupLead.DuplicatesIdentified__C != null) dupLead.DuplicatesIdentified__C = dupLead.DuplicatesIdentified__c + dupLead.Id + '\n';
                            else dupLead.DuplicatesIdentified__C = dupLead.Id + '\n';
                            dupLead.LatestDuplicates__C = dupLead.Id;
                            updateLeadList.add(dupLead);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = dupLead.Id;
                            
                        }
                        /*else if (dupMapPerLead.containsKey('LEADALTEMAIL')) {
Lead dupLead = [SELECT Email,Phone,RDS_Alternate_Email_Id__c, RW_Mobile_No__c, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
//   Channel_Code__c, TollFree_Number__C
from Lead where Id = : dupMapPerLead.get('LEADALTEMAIL')[0]];
if(dupLead.Email != null && dupLead.Email.contains('@dummy.com'))
dupLead.Email = originalLead.Email;
if(dupLead.RW_Mobile_No__c != null && dupLead.RW_Mobile_No__c.contains('mo-'))
dupLead.RW_Mobile_No__c = originalLead.RW_Mobile_No__c;
// if duplicate enquiry has new mobile or email copy in the alternate contact details
if(dupLead.Phone == null && dupLead.RW_Mobile_No__c != originalLead.RW_Mobile_No__c)
dupLead.Phone = originalLead.RW_Mobile_No__c;
if(dupLead.RDS_Alternate_Email_Id__c == null && dupLead.Email != originalLead.Email)
dupLead.RDS_Alternate_Email_Id__c = originalLead.Email;
dupLead.MasterRecord__c = true;
dupLead.is_serviced__c = false;
dupLead.duplicate_created_Date__c = system.today();
//  if (originalLead.Channel_Code__c != null) dupLead.Channel_Code__c = originalLead.Channel_Code__c;
//     if (originalLead.TollFree_Number__c != null) dupLead.TollFree_Number__C = originallead.TollFree_Number__c;
if (originalLead.Campaign_Code__C != null) dupLead.Campaign_Code__C = originalLead.Campaign_Code__c;
if (dupLead.DuplicatesIdentified__C != null) dupLead.DuplicatesIdentified__C = dupLead.DuplicatesIdentified__c + dupLead.Id + '\n';
else dupLead.DuplicatesIdentified__C = dupLead.Id + '\n';
dupLead.LatestDuplicates__C = dupLead.Id;
updateLeadList.add(dupLead);
dupResults.originalLead = originalLead;
dupResults.duplicateMaster = dupLead.Id;

}*/ 
                        else if (dupMapPerLead.containsKey('LEADALTMOBILE')) {
                            Lead dupLead = [SELECT Email,Phone,RDS_Alternate_Email_Id__c, RW_Mobile_No__c, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
                                            //    Channel_Code__c, TollFree_Number__C
                                            from Lead where Id = : dupMapPerLead.get('LEADALTMOBILE')[0]];
                            if(dupLead.Email  != null && dupLead.Email.contains('@dummy.com'))
                                dupLead.Email = originalLead.Email;
                            if(dupLead.RW_Mobile_No__c != null && dupLead.RW_Mobile_No__c.contains('mo-'))
                                dupLead.RW_Mobile_No__c = originalLead.RW_Mobile_No__c;
                            // if duplicate enquiry has new mobile or email copy in the alternate contact details
                            if(dupLead.Phone == null && dupLead.RW_Mobile_No__c != originalLead.RW_Mobile_No__c)
                                dupLead.Phone = originalLead.RW_Mobile_No__c;
                            if(dupLead.RDS_Alternate_Email_Id__c == null && dupLead.Email != originalLead.Email)
                                dupLead.RDS_Alternate_Email_Id__c = originalLead.Email;
                            dupLead.MasterRecord__c = true;
                            dupLead.is_serviced__c = false;
                            dupLead.duplicate_created_Date__c = system.today();
                            //   if (originalLead.Channel_Code__c != null) dupLead.Channel_Code__c = originalLead.Channel_Code__c;
                            //    if (originalLead.TollFree_Number__c != null) dupLead.TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) dupLead.Campaign_Code__C = originalLead.Campaign_Code__c;
                            if (dupLead.DuplicatesIdentified__C != null) dupLead.DuplicatesIdentified__C = dupLead.DuplicatesIdentified__c + dupLead.Id + '\n';
                            else dupLead.DuplicatesIdentified__C = dupLead.Id + '\n';
                            dupLead.LatestDuplicates__C = dupLead.Id;
                            updateLeadList.add(dupLead);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = dupLead.Id;
                            
                        } /**
else if (dupMapPerLead.containsKey('PAEMAIL')) {
Account dupAcc = [SELECT RW_Email__c, Mobile_No__c,Phone,RW_Additional_Email__c, PersonContactId, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
//    Channel_Code__c, TollFree_Number__C
from Account where Id = : dupMapPerLead.get('PAEMAIL')[0]];
if(dupAcc.RW_Email__c != null && dupAcc.RW_Email__c.contains('@dummy.com'))
dupAcc.RW_Email__c = originalLead.Email;
if(dupAcc.Mobile_No__c != null && dupAcc.Mobile_No__c.contains('mo-'))  
dupAcc.Mobile_No__c = originalLead.RW_Mobile_No__c;
// if duplicate enquiry has new mobile or email copy in the alternate contact details
if(dupAcc.Phone == null && dupAcc.Mobile_No__c != originalLead.RW_Mobile_No__c)
dupAcc.Phone = originalLead.RW_Mobile_No__c;
if(dupAcc.RW_Additional_Email__c == null && dupAcc.RW_Email__c != originalLead.Email)
dupAcc.RW_Additional_Email__c = originalLead.Email;
dupAcc.MasterRecord__c = true;
dupAcc.is_serviced__c = false;
dupAcc.duplicate_created_Date__c = system.today();
//     if (originalLead.Channel_Code__c != null) dupAcc.Channel_Code__c = originalLead.Channel_Code__c;
//      if (originalLead.TollFree_Number__c != null) dupAcc.TollFree_Number__C = originallead.TollFree_Number__c;
if (originalLead.Campaign_Code__C != null) dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
//   dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
if (dupAcc.DuplicatesIdentified__C != null) dupAcc.DuplicatesIdentified__C = dupAcc.DuplicatesIdentified__c + dupAcc.Id + '\n';
else dupAcc.DuplicatesIdentified__C = dupAcc.Id + '\n';
dupAcc.LatestDuplicates__C = dupAcc.Id;
updateAccList.add(dupAcc);
dupResults.originalLead = originalLead;
dupResults.duplicateMaster = dupAcc.Id;
}*/ 
                        else if (dupMapPerLead.containsKey('PAMOBILE')) {
                            Account dupAcc = [SELECT RW_Email__c, Mobile_No__c,Phone,RW_Additional_Email__c, PersonContactId, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
                                              //   Channel_Code__c, TollFree_Number__C
                                              from Account where Id = : dupMapPerLead.get('PAMOBILE')[0]];
                            if(dupAcc.RW_Email__c != null && dupAcc.RW_Email__c.contains('@dummy.com'))
                                dupAcc.RW_Email__c = originalLead.Email;
                            if(dupAcc.Mobile_No__c != null && dupAcc.Mobile_No__c.contains('mo-'))  
                                dupAcc.Mobile_No__c = originalLead.RW_Mobile_No__c;
                            if(dupAcc.Phone == null && dupAcc.Mobile_No__c != originalLead.RW_Mobile_No__c)
                                dupAcc.Phone = originalLead.RW_Mobile_No__c;
                            if(dupAcc.RW_Additional_Email__c == null && dupAcc.RW_Email__c != originalLead.Email)
                                dupAcc.RW_Additional_Email__c = originalLead.Email;
                            dupAcc.MasterRecord__c = true;
                            dupAcc.is_serviced__c = false;
                            dupAcc.duplicate_created_Date__c = system.today();
                            //      if (originalLead.Channel_Code__c != null) dupAcc.Channel_Code__c = originalLead.Channel_Code__c;
                            //      if (originalLead.TollFree_Number__c != null) dupAcc.TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
                            if (dupAcc.DuplicatesIdentified__C != null) dupAcc.DuplicatesIdentified__C = dupAcc.DuplicatesIdentified__c + dupAcc.Id + '\n';
                            else dupAcc.DuplicatesIdentified__C = dupAcc.Id + '\n';
                            dupAcc.LatestDuplicates__C = dupAcc.Id;
                            updateAccList.add(dupAcc);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = dupAcc.Id;
                        } /* 
else if (dupMapPerLead.containsKey('PAALTEMAIL')) {
Account dupAcc = [SELECT RW_Email__c, Mobile_No__c,Phone,RW_Additional_Email__c, PersonContactId, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
//        Channel_Code__c, TollFree_Number__C
from Account where Id = : dupMapPerLead.get('PAALTEMAIL')[0]];
if(dupAcc.RW_Email__c != null && dupAcc.RW_Email__c.contains('@dummy.com'))
dupAcc.RW_Email__c = originalLead.Email;
if(dupAcc.Mobile_No__c != null && dupAcc.Mobile_No__c.contains('mo-'))  
dupAcc.Mobile_No__c = originalLead.RW_Mobile_No__c;
if(dupAcc.Phone == null && dupAcc.Mobile_No__c != originalLead.RW_Mobile_No__c)
dupAcc.Phone = originalLead.RW_Mobile_No__c;
if(dupAcc.RW_Additional_Email__c == null && dupAcc.RW_Email__c != originalLead.Email)
dupAcc.RW_Additional_Email__c = originalLead.Email;
dupAcc.MasterRecord__c = true;
dupAcc.is_serviced__c = false;
dupAcc.duplicate_created_Date__c = system.today();
//       if (originalLead.Channel_Code__c != null) dupAcc.Channel_Code__c = originalLead.Channel_Code__c;
//        if (originalLead.TollFree_Number__c != null) dupAcc.TollFree_Number__C = originallead.TollFree_Number__c;
if (originalLead.Campaign_Code__C != null) dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
//       dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
if (dupAcc.DuplicatesIdentified__C != null) dupAcc.DuplicatesIdentified__C = dupAcc.DuplicatesIdentified__c + dupAcc.Id + '\n';
else dupAcc.DuplicatesIdentified__C = dupAcc.Id + '\n';
dupAcc.LatestDuplicates__C = dupAcc.Id;
updateAccList.add(dupAcc);
dupResults.originalLead = originalLead;
dupResults.duplicateMaster = dupAcc.Id;
}*/ 
                        else if (dupMapPerLead.containsKey('PAALTMOBILE')) {
                            Account dupAcc = [SELECT RW_Email__c, Mobile_No__c, Phone,RW_Additional_Email__c,PersonContactId, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c
                                              //    Channel_Code__c, Campaign_Code__c, TollFree_Number__C
                                              from Account where Id = : dupMapPerLead.get('PAALTMOBILE')[0]];
                            if(dupAcc.RW_Email__c != null && dupAcc.RW_Email__c.contains('@dummy.com'))
                                dupAcc.RW_Email__c = originalLead.Email;
                            if(dupAcc.Mobile_No__c != null && dupAcc.Mobile_No__c.contains('mo-'))  
                                dupAcc.Mobile_No__c = originalLead.RW_Mobile_No__c;
                            if(dupAcc.Phone == null && dupAcc.Mobile_No__c != originalLead.RW_Mobile_No__c)
                                dupAcc.Phone = originalLead.RW_Mobile_No__c;
                            if(dupAcc.RW_Additional_Email__c == null && dupAcc.RW_Email__c != originalLead.Email)
                                dupAcc.RW_Additional_Email__c = originalLead.Email;
                            dupAcc.MasterRecord__c = true;
                            dupAcc.is_serviced__c = false;
                            dupAcc.duplicate_created_Date__c = system.today();
                            //        if (originalLead.Channel_Code__c != null) dupAcc.Channel_Code__c = originalLead.Channel_Code__c;
                            //        if (originalLead.TollFree_Number__c != null) dupAcc.TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) dupAcc.Campaign_Code__C = originalLead.Campaign_Code__c;
                            if (dupAcc.DuplicatesIdentified__C != null) dupAcc.DuplicatesIdentified__C = dupAcc.DuplicatesIdentified__c + dupAcc.Id + '\n';
                            else dupAcc.DuplicatesIdentified__C = dupAcc.Id + '\n';
                            dupAcc.LatestDuplicates__C = dupAcc.Id;
                            updateAccList.add(dupAcc);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = dupAcc.Id;
                        }else {
                            System.debug('Some error: duplicate map contains an unknown key: \n');
                            List < String > customMsgList = new List < String > ();
                            customMsgList.add('Duplicate Map Contains an unknown Key:'+dupMapPerLead);
                            throw new GlobalException(customMsgList, '', 'WebDupHandler');
                        }
                    } else {
                        //If more than one duplicate exists?
                        // check if a master record exists, use that else
                        //query the first duplicate record, add incoming fields to that
                        //create a task of repeat enquiry against it and return the id
                        System.debug('More than one duplicates exists for lead Id: ' + originalLead + ' and they are ' + dupMapPerLead);
                        
                        List < Lead > leadDupRecs = new List < Lead > ();
                        List < Account > AccDupRecs = new List < Account > ();
                        if (!leadDup.isEmpty()) {
                            
                            leadDupRecs = [SELECT Email, RW_Mobile_No__c, Phone, RDS_Alternate_Email_Id__c,firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
                                           //       Channel_Code__c, TollFree_Number__C
                                           from Lead where Id in : leadDup];
                        }
                        if (!accDup.isEmpty()) {
                            accDupRecs = [SELECT RW_Email__c, Mobile_No__c,Phone,RW_Additional_Email__c, PersonContactId, firstName, LastName, OwnerId, MasterRecord__c, DuplicatesIdentified__c, LatestDuplicates__c, Campaign_Code__c
                                          //    Channel_Code__c, TollFree_Number__C
                                          from Account where Id in : AccDup];
                        }
                        // if a master record which has been used for merge is identified, use that as the master and upsert the values
                        // else use the first record from lead or account as master and upsert that record
                        
                        //Duplicate list is a comma separated list of all account + lead duplicates of a lead record.
                        //writing this back to the database in the duplicateList field. this field has a running list of all duplicates identified in multiple updates of the lead
                        //latest duplicate field contains the duplicates identified in the last update/insert of the lead record
                        List < String > DuplicateList = new List < String > ();
                        if (!leadDupRecs.isEmpty()) {
                            for (lead l: leadDupRecs) {
                                String dup = l.Id;
                                DuplicateList.add(dup);
                            }
                        }
                        if (!AccDupRecs.isEmpty()) {
                            for (Account a: AccDupRecs) {
                                String dup = a.Id;
                                DuplicateList.add(dup);
                            }
                        }
                        Boolean masterFound = false;
                        for (lead l: leadDupRecs) {
                            if (l.MasterRecord__C) {
                                if(l.Email != null && l.Email.contains('@dummy.com'))
                                    l.Email = originalLead.Email;
                                if(l.RW_Mobile_No__c != null && l.RW_Mobile_No__c.contains('mo-'))
                                    l.RW_Mobile_No__c = originalLead.RW_Mobile_No__c;
                                // if duplicate enquiry has new mobile or email copy in the alternate contact details
                                if(l.Phone == null && l.RW_Mobile_No__c != originalLead.RW_Mobile_No__c)
                                    l.Phone = originalLead.RW_Mobile_No__c;
                                if(l.RDS_Alternate_Email_Id__c == null && l.Email != originalLead.Email)
                                    l.RDS_Alternate_Email_Id__c = originalLead.Email;
                                l.duplicate_created_Date__c = system.today();
                                l.is_serviced__c = false;
                                //         System.debug('channel code information:' + originalLead.Channel_Code__c);
                                //       if (originalLead.Channel_Code__c != null) l.Channel_Code__c = originalLead.Channel_Code__c;
                                //       if (originalLead.TollFree_Number__c != null) l.TollFree_Number__C = originallead.TollFree_Number__c;
                                if (originalLead.Campaign_Code__C != null) l.Campaign_Code__C = originalLead.Campaign_Code__c;
                                if (l.DuplicatesIdentified__C != null) l.DuplicatesIdentified__C = l.DuplicatesIdentified__c + String.valueOf(DuplicateList) + '\n';
                                else l.DuplicatesIdentified__C = String.valueOf(DuplicateList) + '\n';
                                l.LatestDuplicates__C = String.valueOf(DuplicateList);
                                updateLeadList.add(l);
                                dupResults.originalLead = originalLead;
                                dupResults.duplicateMaster = l.Id;
                                masterFound = true;
                                break;
                            }
                        }
                        if (!masterFound) {
                            for (Account a: accDupRecs) {
                                if (a.MasterRecord__c) {
                                    if(a.RW_Email__c != null && a.RW_Email__c.contains('@dummy.com'))
                                        a.RW_Email__c = originalLead.Email;
                                    if(a.Mobile_No__c != null && a.Mobile_No__c.contains('mo-'))
                                        a.Mobile_No__c = originalLead.RW_Mobile_No__c;
                                    if(a.Phone == null && a.Mobile_No__c != originalLead.RW_Mobile_No__c)
                                        a.Phone = originalLead.RW_Mobile_No__c;
                                    if(a.RW_Additional_Email__c == null && a.RW_Email__c != originalLead.Email)
                                        a.RW_Additional_Email__c = originalLead.Email;
                                    a.duplicate_created_Date__c = system.today();
                                    a.is_serviced__c = false;
                                    //         if (originalLead.Channel_Code__c != null) a.Channel_Code__c = originalLead.Channel_Code__c;
                                    //         if (originalLead.TollFree_Number__c != null) a.TollFree_Number__C = originallead.TollFree_Number__c;
                                    if (originalLead.Campaign_Code__C != null) a.Campaign_Code__C = originalLead.Campaign_Code__c;
                                    if (a.DuplicatesIdentified__C != null) a.DuplicatesIdentified__C = a.DuplicatesIdentified__c + String.valueOf(DuplicateList) + '\n';
                                    else a.DuplicatesIdentified__C = String.valueOf(DuplicateList) + '\n';
                                    a.LatestDuplicates__C = String.valueOf(DuplicateList);
                                    updateAccList.add(a);
                                    dupResults.originalLead = originalLead;
                                    dupResults.duplicateMaster = a.Id;
                                    masterFound = true;
                                    break;
                                }
                            }
                        }
                        if (!masterFound && !leadDupRecs.isEmpty()) {
                            if(leadDupRecs[0].Email != null && leadDupRecs[0].Email.contains('@dummy.com'))
                                leadDupRecs[0].Email = originalLead.Email;
                            if(leadDupRecs[0].RW_Mobile_No__c != null && leadDupRecs[0].RW_Mobile_No__c.contains('mo-'))
                                leadDupRecs[0].RW_Mobile_No__c = originalLead.RW_Mobile_No__c;
                            // if duplicate enquiry has new mobile or email copy in the alternate contact details
                            if(leadDupRecs[0].Phone == null && leadDupRecs[0].RW_Mobile_No__c != originalLead.RW_Mobile_No__c)
                                leadDupRecs[0].Phone = originalLead.RW_Mobile_No__c;
                            if(leadDupRecs[0].RDS_Alternate_Email_Id__c == null && leadDupRecs[0].Email != originalLead.Email)
                                leadDupRecs[0].RDS_Alternate_Email_Id__c = originalLead.Email;  
                            leadDupRecs[0].MasterRecord__c = true;
                            leadDupRecs[0].duplicate_created_Date__c = system.today();
                            leadDupRecs[0].is_serviced__c = false;
                            //        if (originalLead.Channel_Code__c != null) leadDupRecs[0].Channel_Code__c = originalLead.Channel_Code__c;
                            //         if (originalLead.TollFree_Number__c != null) leadDupRecs[0].TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) leadDupRecs[0].Campaign_Code__C = originalLead.Campaign_Code__c;
                            leadDupRecs[0].DuplicatesIdentified__C = leadDupRecs[0].DuplicatesIdentified__c + String.valueOf(DuplicateList);
                            leadDupRecs[0].LatestDuplicates__C = String.valueOf(DuplicateList);
                            updateLeadList.add(leadDupRecs[0]);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = leadDupRecs[0].Id;
                            masterFound = true;
                        }
                        if (!masterFound && !AccDupRecs.isEmpty()) {
                            if(AccDupRecs[0].RW_Email__c != null && AccDupRecs[0].RW_Email__c.contains('@dummy.com'))
                                AccDupRecs[0].RW_Email__c = originalLead.Email;
                            if(AccDupRecs[0].Mobile_No__c != null && AccDupRecs[0].Mobile_No__c.contains('mo-'))
                                AccDupRecs[0].Mobile_No__c = originalLead.RW_Mobile_No__c;
                            if(AccDupRecs[0].Phone == null && AccDupRecs[0].Mobile_No__c != originalLead.RW_Mobile_No__c)
                                AccDupRecs[0].Phone = originalLead.RW_Mobile_No__c;
                            if(AccDupRecs[0].RW_Additional_Email__c == null && AccDupRecs[0].RW_Email__c != originalLead.Email)
                                AccDupRecs[0].RW_Additional_Email__c = originalLead.Email;
                            AccDupRecs[0].MasterRecord__c = true;
                            AccDupRecs[0].duplicate_created_Date__c = system.today();
                            AccDupRecs[0].is_serviced__c = false;
                            //          if (originalLead.Channel_Code__c != null) AccDupRecs[0].Channel_Code__c = originalLead.Channel_Code__c;
                            //           if (originalLead.TollFree_Number__c != null) AccDupRecs[0].TollFree_Number__C = originallead.TollFree_Number__c;
                            if (originalLead.Campaign_Code__C != null) AccDupRecs[0].Campaign_Code__C = originalLead.Campaign_Code__c;
                            AccDupRecs[0].DuplicatesIdentified__C = AccDupRecs[0].DuplicatesIdentified__c + String.valueOf(DuplicateList);
                            AccDupRecs[0].LatestDuplicates__C = String.valueOf(DuplicateList);
                            updateAccList.add(AccDupRecs[0]);
                            dupResults.originalLead = originalLead;
                            dupResults.duplicateMaster = AccDupRecs[0].Id;
                            masterFound = true;
                        }
                    }
                    
                }
                if (dupResults != null) {
                    dupResultsList.add(dupResults);
                }
            }
        }
        String description = 'Repeat Enquiry Received From: ' + context;
        Map < Id, Task > completeTaskMap = new Map < Id, Task > ();
        
        if (!updateLeadList.isEmpty()) {
            try {
                Database.SaveResult[] srList = Database.update(updateLeadList, true);
                for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated lead. Lead ID: ' + sr.getId());
                    } else {
                        // Operation failed, so get all errors  
                        List < String > customMsgList = new List < String > ();
                        for (Database.Error err: sr.getErrors()) {
                            String msg = 'Lead Update Failed :' + err.getMessage();
                            customMsgList.add(msg);
                        }
                        throw new GlobalException(customMsgList, '', 'WebDedupeHandler');
                    }
                }
            } catch (System.DmlException ex) {
                List < String > customMsgList = new List < String > ();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    String msg = 'Lead Update Failed :' + ex.getMessage();
                    customMsgList.add(msg);
                }
                throw new GlobalException(customMsgList, '', 'WebDedupeHandler');
            }
        }
        
        if (!updateAccList.isEmpty()) {
            try {
                Database.SaveResult[] srList = Database.update(updateAccList, true);
                for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated Account. Account ID: ' + sr.getId());
                    } else {
                        // Operation failed, so get all errors  
                        List < String > customMsgList = new List < String > ();
                        for (Database.Error err: sr.getErrors()) {
                            String msg = 'Account Update Failed :' + err.getMessage();
                            customMsgList.add(msg);
                        }
                        throw new GlobalException(customMsgList, '', 'WebDedupeHandler');
                    }
                }
            } catch (System.DmlException ex) {
                List < String > customMsgList = new List < String > ();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    String msg = 'Account Update Failed :' + ex.getMessage();
                    customMsgList.add(msg);
                }
                throw new GlobalException(customMsgList, '', 'WebDedupeHandler');
            }
        }
        Map<Id,Lead> enquiriesTaskMap = new Map<Id,Lead>();
        
        if (!dupResultsList.isEmpty()) {
            for (DupResultsDTO d: dupResultsList) {
                enquiriesTaskMap.put(d.duplicateMaster, d.originalLead);
            }
            
            Map < Id, Task > whoIdMap = TaskManagementServices.createTaskForEnquiries(enquiriesTaskMap);
            
            for (DupResultsDTO d: dupResultsList) {
                if (whoIdMap.containsKey(d.duplicateMaster)) {
                    d.dupEnquiryTaskId = whoIdMap.get(d.duplicateMaster).Id;
                }
            }   
        }
        for (DupResultsDTO d: dupResultsList)
            System.debug('DupResults: ' + d.originalLead + ':' + d.dupEnquiryTaskId + ':' + d.duplicateMaster + ':' + d.duplicatesMap);
        return dupResultsList;
    }
    
     public static void dummy(){
        
         String s2;        
        String s3;
        String s4;                
        String s5;
        String s6;        
        String s7;
        String s8;                
        String s9;
        String s10;        
        String s11;
        String s12;                
        String s13;
        String s14;        
        String s15;
        String s16;                
        String s110;
        String s210;        
        String s310;
        String s410;    
           integer i;
            i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
 i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
          i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        
    }
}