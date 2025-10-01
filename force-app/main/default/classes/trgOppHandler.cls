public class trgOppHandler {

    public static void addAopTypeAndCpCategory(List<Opportunity> cpOppList){
        
        Set<String> projects = new Set<String>();
        Set<String> cps = new Set<String>();
        for(Opportunity opp : cpOppList){
            projects.add(opp.RW_Project__c);
            cps.add(opp.RW_Walkin_Channel_Partner__c);
        }
        
        //List<CP_Category__c> cpCategoryList = [SELECT Id,Name,Category__c,Channel_Partner__c,Project__c FROM CP_Category__c WHERE Project__c =: projects AND Channel_Partner__c =: cps AND Category__c != null];
        Map<String,String> categoryMap = new Map<String, String>();
        Map<Id, Broker__c> brokers;
        if(cps.size() > 0){
            for(CP_Category__c cat : [SELECT Id,Name,Category__c,Channel_Partner__c,Project__c FROM CP_Category__c WHERE Project__c =: projects AND Channel_Partner__c =: cps AND Category__c != null]){
                categoryMap.put(cat.Project__c + '_' + cat.Channel_Partner__c, cat.Category__c);
            }
            brokers = new Map<Id, Broker__c>([SELECT Id,AOP_Type__c FROM Broker__c WHERE Id =: cps]);
        }
        
        system.debug('categoryMap: '+categoryMap);   
        
        
               
        for(Opportunity opp : cpOppList){
            if(!categoryMap.isEmpty()){
                opp.CP_Category__c = categoryMap.get(opp.RW_Project__c + '_' + opp.RW_Walkin_Channel_Partner__c);
            }
            if(!brokers.isEmpty() && brokers.get(opp.RW_Walkin_Channel_Partner__c) != null){
                opp.AOP_Type__c = brokers.get(opp.RW_Walkin_Channel_Partner__c).AOP_Type__c;
            }
        }
    }
    
    public static void updateReferralCustDetails(List<Opportunity> refOppList){
        Set<String> custRefs = new Set<String>();
        for(Opportunity opp : refOppList){
            custRefs.add(opp.RW_Walkin_Customer_Reference__c);
        }
        
        //List<Opportunity> lstOpp = [Select Id,StageName,RW_Booking_Date_Opp__c, Name,SAP_Customer_Number__c,AccountId,RW_Project_Unit__c /*Customer_Reference_Opportunity__c*/ From Opportunity Where AccountId=: custRefs AND StageName =:'Unit Booked'  ORDER BY RW_Booking_Date_Opp__c DESC ];
        Map<String, Opportunity> refOppMap = new Map<String, Opportunity>();
        if(custRefs.size() > 0){
            for(Opportunity opp : [Select Id,StageName,RW_Booking_Date_Opp__c, Name,SAP_Customer_Number__c,AccountId,RW_Project_Unit__c /*Customer_Reference_Opportunity__c*/ From Opportunity Where AccountId=: custRefs AND StageName =:'Unit Booked'  ORDER BY RW_Booking_Date_Opp__c DESC ]){
                refOppMap.put(opp.AccountId, opp);
            }
        }
        
        for(Opportunity opp : refOppList){
            if(refOppMap.get(opp.RW_Walkin_Customer_Reference__c) != null){
                /*opp.Customer_reference_SAP_Code__c = refOppMap.get(opp.RW_Walkin_Customer_Reference__c).SAP_Customer_Number__c;
                opp.Customer_reference_Booked_Unit__c = refOppMap.get(opp.RW_Walkin_Customer_Reference__c).RW_Project_Unit__c;
                //opp.Customer_Reference_Opportunity__c = refOppMap.get(opp.RW_Walkin_Customer_Reference__c).Id;*/
            }
        }
    }
}