@RestResource(urlMapping='/cpOfferMasterDetails/*')
global without sharing class Lockated_CPOfferMasterDetails {

@HttpGet
global static void doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');

    Map<String, Object> errorResult = new Map<String, Object>();

    try {
        // Query Offer Master records
        List<Offer_Master__c> offerRecords = [
            SELECT Id,Name,
                       Discount_Category__c,End_Date__c,Monetizable__c,Image__c,
                       Offer_calculation__c,Offer_type__c,Offer_Value__c,Project__r.Name,
                       Project__c,Project_Unit__c,Start_Date__c,Tower__c,CreatedDate
                FROM Offer_Master__c
            ORDER BY CreatedDate DESC
        ];

        if (offerRecords.isEmpty()) {
            errorResult.put('status', 'success');
            errorResult.put('message', 'No offers found');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 200;
            return;
        }

        // Map to hold projects and their offers
        Map<Id, Map<String, Object>> projectsMap = new Map<Id, Map<String, Object>>();

        for (Offer_Master__c offer : offerRecords) {

            if (!projectsMap.containsKey(offer.Project__c)) {
                Map<String, Object> projectEntry = new Map<String, Object>();
                projectEntry.put('projectId', offer.Project__c);
                projectEntry.put('projectName', offer.Project__r.Name); 
                projectEntry.put('offers', new List<Map<String, Object>>());
                projectsMap.put(offer.Project__c, projectEntry);
            }

            List<Map<String, Object>> offersList = (List<Map<String, Object>>)projectsMap.get(offer.Project__c).get('offers');

            Map<String, Object> offerEntry = new Map<String, Object>();
            offerEntry.put('offerId', offer.Id);
            offerEntry.put('title', offer.Name);
            offerEntry.put('startDate', offer.Start_Date__c != null ? String.valueOf(offer.Start_Date__c) : '');
            offerEntry.put('endDate', offer.End_Date__c != null ? String.valueOf(offer.End_Date__c) : '');
            offerEntry.put('projectUnit', offer.Project_Unit__c);
            offerEntry.put('tower', offer.Tower__c);
            offerEntry.put('offerType', offer.Offer_type__c);
            offerEntry.put('offerCalculation', offer.Offer_calculation__c);
            offerEntry.put('offerValue', offer.Offer_Value__c);
            offerEntry.put('monetizable', offer.Monetizable__c);
            offerEntry.put('discountCategory', offer.Discount_Category__c);
            offerEntry.put('image', offer.Image__c);

            offersList.add(offerEntry);
        }

        // Prepare final JSON structure
        Map<String, Object> finalResponse = new Map<String, Object>();
        finalResponse.put('projects', projectsMap.values());

        res.responseBody = Blob.valueOf(JSON.serialize(finalResponse));
        res.statusCode = 200;

    } catch (Exception e) {
        errorResult.put('status', 'error');
        errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
        res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
        res.statusCode = 400;
    }
}

}