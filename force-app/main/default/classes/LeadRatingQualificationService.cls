/**
 * @Author: [ Uneecops team ]
 * @Version: 1.2
 * @Created Date: [11-03-2025]
 * @Description: [This class handles lead qualification and rating based on specified criteria]
 */
public without sharing class LeadRatingQualificationService {

    @InvocableMethod(label='Evaluate Lead Rating' description='Determines lead rating and returns Lead_Qualification__c field')
    public static List<LeadRatingResponse> evaluateLeadRating(List<LeadRatingRequest> requests) {
        List<LeadRatingResponse> responses = new List<LeadRatingResponse>();
        try {
            if (requests == null || requests.isEmpty()) return responses;

            Set<Integer> HOT_MATCH_COUNT = parseCustomLabel(System.Label.HOT_MATCH_COUNT);
            Set<Integer> WARM_MATCH_COUNT = parseCustomLabel(System.Label.WARM_MATCH_COUNT);
            Set<Integer> COLD_MATCH_COUNT = parseCustomLabel(System.Label.COLD_MATCH_COUNT);

            Set<Id> leadIds = new Set<Id>();
            for (LeadRatingRequest req : requests) {
                if (req.leadId != null) leadIds.add(req.leadId);
            }

            if (leadIds.isEmpty()) return responses;

            Map<Id, Id> leadToProjectMap = new Map<Id, Id>();
            try {
                for (Lead lead : [SELECT Id, RW_Project__c FROM Lead WHERE Id IN :leadIds]) {
                    if (lead.RW_Project__c != null) {
                        leadToProjectMap.put(lead.Id, lead.RW_Project__c);
                    }
                }
            } catch (Exception e) {
                System.debug('Error querying leads: ' + e.getMessage());
                return responses;
            }

            if (leadToProjectMap.isEmpty()) return responses;

            Set<Id> projectIds = new Set<Id>(leadToProjectMap.values());
            Map<Id, List<Qualification_Criteria__c>> projectToCriteriaMap = new Map<Id, List<Qualification_Criteria__c>>();

            try {
                for (Qualification_Criteria__c qc : [
                    SELECT Id, Project__c, Budget_QC__c, Location_QC__c, Configuration_QC__c,
                           Project_Type__c, Possession_QC__c, MIN_Budget_In_Lakh__c, MAX_Budget_In_Lakh__c
                    FROM Qualification_Criteria__c
                    WHERE Project__c IN :projectIds
                ]) {
                    if (!projectToCriteriaMap.containsKey(qc.Project__c)) {
                        projectToCriteriaMap.put(qc.Project__c, new List<Qualification_Criteria__c>());
                    }
                    projectToCriteriaMap.get(qc.Project__c).add(qc);
                }
            } catch (Exception e) {
                System.debug('Error querying Qualification_Criteria__c: ' + e.getMessage());
                return responses;
            }

            for (LeadRatingRequest req : requests) {
                try {
                    Id projectId = leadToProjectMap.get(req.leadId);
                    if (projectId == null || !projectToCriteriaMap.containsKey(projectId)) continue;

                    Integer maxMatchCount = 0;
                    for (Qualification_Criteria__c qc : projectToCriteriaMap.get(projectId)) {
                        Integer matchCount = calculateMatchingFields(req, qc);
                        maxMatchCount = Math.max(maxMatchCount, matchCount);
                    }

                    String rating;
                    String qualification;
                    if (HOT_MATCH_COUNT.contains(maxMatchCount)) {
                        rating = 'Hot';
                        qualification = 'Qualified';
                    } else if (WARM_MATCH_COUNT.contains(maxMatchCount)) {
                        rating = 'Warm';
                        qualification = 'Not Qualified';
                    } else {
                        rating = 'Cold';
                        qualification = 'Not Qualified';
                    }

                    responses.add(new LeadRatingResponse(req.leadId, rating, qualification));

                } catch (Exception e) {
                    System.debug('Error processing lead ' + req.leadId + ': ' + e.getMessage());
                    responses.add(new LeadRatingResponse(req.leadId, 'Error', 'Error'));
                }
            }
        } catch (Exception e) {
            System.debug('Unexpected error in evaluateLeadRating: ' + e.getMessage());
        }

        return responses; 
    }

    private static Integer calculateMatchingFields(LeadRatingRequest req, Qualification_Criteria__c qc) {
        Integer matchCount = 0;

       try {

            if (qc.Location_QC__c != null && req.location != null) {
                List<String> qcLocations = qc.Location_QC__c.split(';');
                if (qcLocations.contains(req.location)) matchCount++;
            }

            if (
                qc.MIN_Budget_In_Lakh__c != null &&
                qc.MAX_Budget_In_Lakh__c != null &&
                req.budget != null
            ) {
                if (req.budget >= qc.MIN_Budget_In_Lakh__c && req.budget <= qc.MAX_Budget_In_Lakh__c) {
                    matchCount++;
                }
            }

            if (qc.Possession_QC__c != null && req.possession != null) {
                List<String> qcPossessions = qc.Possession_QC__c.split(';');
                if (qcPossessions.contains(req.possession)) matchCount++;
            }

            if (qc.Configuration_QC__c != null && req.configuration != null) {
                if (qc.Configuration_QC__c == req.configuration) matchCount++;
            }
        } catch (Exception e) {
            System.debug('Error calculating match fields: ' + e.getMessage());
        }

        return matchCount;
    }

    private static Set<Integer> parseCustomLabel(String labelValue) {
        Set<Integer> values = new Set<Integer>();

        try {
            if (labelValue != null && labelValue != '') {
                for (String val : labelValue.split(',')) {
                    val = val.trim();
                    if (Pattern.matches('^\\d+$', val)) {
                        values.add(Integer.valueOf(val));
                    } else {
                        System.debug('Invalid number in Custom Label: ' + val);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing Custom Label: ' + e.getMessage());
        }

        return values;
    }

    public class LeadRatingRequest {
        @InvocableVariable(label='Lead Id' required=true)
        public Id leadId;

        @InvocableVariable(label='budget')
        public Decimal budget;

        @InvocableVariable(label='Location')
        public String location;

        @InvocableVariable(label='Possession')
        public String possession;

        @InvocableVariable(label='Configuration')
        public String configuration;

    }

    public class LeadRatingResponse {
        @InvocableVariable(label='Lead Id')
        public Id leadId;

        @InvocableVariable(label='Rating')
        public String rating;

        @InvocableVariable(label='Lead Qualification')
        public String leadQualification;

        public LeadRatingResponse(Id leadId, String rating, String leadQualification) {
            this.leadId = leadId;
            this.rating = rating;
            this.leadQualification = leadQualification;
        }
    }
}