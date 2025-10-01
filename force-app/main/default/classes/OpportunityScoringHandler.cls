// Developed by UBSdigicloud team 04-2025 to calculate the opportunity Score
public class OpportunityScoringHandler {
    public static void calculateOpportunityScores(List<Opportunity> oppList) {
        if (oppList == null || oppList.isEmpty()) {
            return; 
        }
        
        try {
            Set<Id> projectIds = new Set<Id>();
            for (Opportunity opp : oppList) {
                if (opp != null && opp.RW_Project__c != null) {
                    projectIds.add(opp.RW_Project__c);
                }
            }
            
            // Fetch Qualification_Criteria__c records by project
            Map<Id, List<Qualification_Criteria__c>> projectToCriteriaMap = new Map<Id, List<Qualification_Criteria__c>>();
            if (!projectIds.isEmpty()) {
                List<Qualification_Criteria__c> qcList = [
                    SELECT Id, Project__c, Budget_QC__c, Possession_QC__c, Configuration_QC__c, Location_QC__c ,MIN_Budget_In_Lakh__c, MAX_Budget_In_Lakh__c
                    FROM Qualification_Criteria__c 
                    WHERE Project__c IN :projectIds
                ];
                for (Qualification_Criteria__c qc : qcList) {
                    if (qc != null && qc.Project__c != null) {
                        if (!projectToCriteriaMap.containsKey(qc.Project__c)) {
                            projectToCriteriaMap.put(qc.Project__c, new List<Qualification_Criteria__c>());
                        }
                        projectToCriteriaMap.get(qc.Project__c).add(qc);
                    }
                }
            }
            
            // Fetch scoring rules from custom setting
            List<OpportunityCriteriaScores__c> criteriaSettings = [
                SELECT Sub_Criteria__c, Description__c, Score__c, Matching_Type__c, Opportunity_Field__c 
                FROM OpportunityCriteriaScores__c
            ];
            
            if (criteriaSettings == null || criteriaSettings.isEmpty()) {
                return; 
            }
            
            // Group by Matching Type
            Map<String, List<OpportunityCriteriaScores__c>> typeToSettingsMap = new Map<String, List<OpportunityCriteriaScores__c>>();
            for (OpportunityCriteriaScores__c setting : criteriaSettings) {
                if (setting != null && !String.isBlank(setting.Matching_Type__c)) {
                    if (!typeToSettingsMap.containsKey(setting.Matching_Type__c)) {
                        typeToSettingsMap.put(setting.Matching_Type__c, new List<OpportunityCriteriaScores__c>());
                    }
                    typeToSettingsMap.get(setting.Matching_Type__c).add(setting);
                }
            }
            
            // Iterate over Opportunities
            for (Opportunity opp : oppList) {
                if (opp == null) continue; 
                
                Integer totalScore = 0;
                
                // Handle Static scoring
                if (typeToSettingsMap.containsKey('Static')) {
                    totalScore += processStaticScoring(opp, typeToSettingsMap.get('Static'));
                }
                
                // Handle Dynamic scoring
                if (typeToSettingsMap.containsKey('Dynamic') && 
                    opp.RW_Project__c != null && 
                    projectToCriteriaMap.containsKey(opp.RW_Project__c)) {
                        
                        Qualification_Criteria__c bestMatch = findBestMatch(opp, projectToCriteriaMap.get(opp.RW_Project__c));
                        totalScore += processDynamicScoring(opp, bestMatch, typeToSettingsMap.get('Dynamic'));
                    }
                
                // Set Total Score
                opp.Opportunity_Total_Score__c = totalScore;
                
                // Rating Assignment
                if (totalScore >= 61) {
                    opp.Rating_system__c = 'Hot';
                } else if (totalScore >= 41) {
                    opp.Rating_system__c = 'Warm';
                } else {
                    opp.Rating_system__c = 'Cold';
                }
            }
        } catch (Exception e) {
            System.debug('Error calculating Opportunity Scores: ' + e.getMessage());
            
        }
    }
    
    // Static Scoring Logic
    private static Integer processStaticScoring(Opportunity opp, List<OpportunityCriteriaScores__c> settings) {
        Integer score = 0;
        if (settings == null || settings.isEmpty() || opp == null) {
            return score;
        }
        
        for (OpportunityCriteriaScores__c setting : settings) {
            if (setting == null) continue;
            
            String fieldAPI = setting.Opportunity_Field__c;
            if (String.isBlank(fieldAPI)) continue;
            
            Object valueObj = opp.get(fieldAPI);
            if (valueObj == null) continue;
            
            String oppValue = String.valueOf(valueObj);
            if (String.isBlank(oppValue)) continue;
            
            if (setting.Description__c == oppValue) {
                try {
                    score += Integer.valueOf(setting.Score__c);
                } catch (Exception ex) {
                    System.debug('Error parsing static score: ' + ex.getMessage());
                }
            }
        }
        return score;
    }
    
    // Dynamic Scoring Logic
    private static Integer processDynamicScoring(Opportunity opp, Qualification_Criteria__c bestMatch, List<OpportunityCriteriaScores__c> settings) {
        Integer score = 0;
        if (bestMatch == null || settings == null || settings.isEmpty() || opp == null) {
            return score;
        }
        
        for (OpportunityCriteriaScores__c setting : settings) {
            if (setting == null) continue;
            
            String fieldAPI = setting.Opportunity_Field__c;
            if (String.isBlank(fieldAPI)) continue;
            
            String matchStatus = 'Not Match';
            
            Object valueObj = opp.get(fieldAPI);
            String oppValue = (valueObj != null) ? String.valueOf(valueObj) : null;
            
            if (fieldAPI == 'Budget_In_Lakh__c' && bestMatch.MIN_Budget_In_Lakh__c != null && bestMatch.MAX_Budget_In_Lakh__c != null && valueObj != null) {
                Decimal oppBudget = (Decimal)valueObj;
                if (oppBudget >= bestMatch.MIN_Budget_In_Lakh__c && oppBudget <= bestMatch.MAX_Budget_In_Lakh__c) {
                    matchStatus = 'Match';
                }
            }
            
            else if (fieldAPI == 'RW_Time_line__c' && bestMatch.Possession_QC__c != null && oppValue != null && bestMatch.Possession_QC__c.contains(oppValue)) {
                matchStatus = 'Match';
            }
            else if (fieldAPI == 'RW_Configuration__c' && bestMatch.Configuration_QC__c != null && oppValue != null && bestMatch.Configuration_QC__c == oppValue) {
                matchStatus = 'Match';
            }
            else if (fieldAPI == 'RW_Location__c' && bestMatch.Location_QC__c != null && oppValue != null && bestMatch.Location_QC__c.contains(oppValue)) {
                matchStatus = 'Match';
            }
            
            if (setting.Description__c == matchStatus) {
                try {
                    score += Integer.valueOf(setting.Score__c);
                } catch (Exception ex) {
                    System.debug('Error parsing dynamic score: ' + ex.getMessage());
                }
            }
        }
        return score;
    }
    
    // Find best Qualification_Criteria__c match
    private static Qualification_Criteria__c findBestMatch(Opportunity opp, List<Qualification_Criteria__c> qcs) {
        if (opp == null || qcs == null || qcs.isEmpty()) {
            return null;
        }
        
        Qualification_Criteria__c bestMatch;
        Integer maxMatch = 0;
        
        for (Qualification_Criteria__c qc : qcs) {
            if (qc == null) continue;
            
            Integer count = 0;
            if (qc.MIN_Budget_In_Lakh__c != null && qc.MAX_Budget_In_Lakh__c != null && opp.Budget_In_Lakh__c != null) {
                if (opp.Budget_In_Lakh__c >= qc.MIN_Budget_In_Lakh__c && opp.Budget_In_Lakh__c <= qc.MAX_Budget_In_Lakh__c) {
                    count++;
                }
            }
            if (qc.Possession_QC__c != null && opp.RW_Time_line__c != null && qc.Possession_QC__c.contains(opp.RW_Time_line__c)) count++;
            if (qc.Configuration_QC__c != null && opp.RW_Configuration__c != null && qc.Configuration_QC__c == opp.RW_Configuration__c) count++;
            if (qc.Location_QC__c != null && opp.RW_Location__c != null && qc.Location_QC__c.contains(opp.RW_Location__c)) count++;
            
            if (count > maxMatch) {
                maxMatch = count;
                bestMatch = qc;
            }
        }
        return bestMatch;
    }
}