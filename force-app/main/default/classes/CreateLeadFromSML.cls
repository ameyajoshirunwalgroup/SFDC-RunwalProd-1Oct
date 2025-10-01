public with sharing class CreateLeadFromSML {
    @InvocableMethod(label='Create Lead From SML')
    public static void createLead(List<String> SMLIds) {
        
        // Iterate over the list of lead IDs
        String SMLId = SMLIds[0];
        system.debug('SMLId'+SMLId);
        
        list<Social_Media_Lead__c> sml = [Select Id,Processed__c,Lead_ID__c from Social_Media_Lead__c where Id =:SMLId and Processed__c = false Limit 1];
        system.debug('lead id'+sml[0].Lead_ID__c);
        
        System.debug('leadID: ' + sml[0].Lead_ID__c);
        try {
            socialMediaLeadservices.makeFBCallout(sml[0].Lead_ID__c);
            System.debug('Callout executed successfully.');
        } catch (Exception e) {
            System.debug('Error during callout: ' + e.getMessage());
        }
    }
}