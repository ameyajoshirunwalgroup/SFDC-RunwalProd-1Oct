public with sharing class OfferMasterConfiguratorController {

    @AuraEnabled(cacheable=true)
    public static List<Tower__c> getTowersByProject(Id projectId, String searchTerm) {
        String query = 'SELECT Id, Name FROM Tower__c WHERE ProjectName__c = :projectId';
        
        if (String.isNotBlank(searchTerm)) {
            String key = '%' + searchTerm + '%';
            query += ' AND Name LIKE :key';
        }
        
        return Database.query(query);
    }

     @AuraEnabled(cacheable=true)
    public static List<Offer_Master_Data__c> getOffers() {
        return [
            SELECT Id, Name, Start_Date__c, End_Date__c, Offer_Value__c, 
                   Discount_Category__c, Offer_type__c,Offer_calculation__c,Monetizable__c
            FROM Offer_Master_Data__c
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTypologyValues() {
        //List<String> values = new List<String>();
        List<Map<String,String>> values = new List<Map<String,String>>();

        Schema.DescribeFieldResult dfr =
            Project_Unit__c.New_Type__c.getDescribe();

        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            if (ple.isActive()) {
                values.add(new Map<String,String>{
                'label' => ple.getLabel(),   // For UI
                'value' => ple.getValue()    // API name
            });
                //values.add(ple.getLabel()); // or getValue()
                //values.add(ple.getValue()); // or getValue()
            }
        }
        System.debug('values**'+values);
        return values;
    }

    @AuraEnabled
    public static void createOffers(Id projectIds, List<Id> offerId, List<Id> towerIds,List<String> lstOfTypology) {
        System.debug('offers**'+offerId);
        System.debug('lstOfTypology**'+lstOfTypology);
        Set<String> duplicateKeys = new Set<String>();
        try{
            String projName;
            List<Offer_Master__c> offerMasterToInsert = new List<Offer_Master__c>();
            List<Offer_Master__c> lstOfofferMaster = new List<Offer_Master__c>();
            Set<Id> setOfProjId = new Set<Id>();
            Map<Id, String> towerIdToNameMap = new Map<Id, String>();
            //Map<Id, String> IdToOfferMaster = new Map<Id, String>();
            Set<String> existingUniqueKeys = new Set<String>();
            

            if(offerId == null){
                return;
            }
            if(projectIds == null){
                return;
            }

            List<Project__c> proj = [Select Id,Name from Project__c where Id =:projectIds];
            projName = proj[0].Name;

            List<Id> lstOftowers = (towerIds != null && !towerIds.isEmpty())? towerIds: new List<Id>{ null };

            if (towerIds != null && !towerIds.isEmpty()) {
                for (Tower__c tower : [
                    SELECT Id, Name
                    FROM Tower__c
                    WHERE Id IN :towerIds
                ]) {
                    towerIdToNameMap.put(tower.Id,tower.Name);
                }
            }
                
            List<String> lstOftypologies = (lstOfTypology != null && !lstOfTypology.isEmpty())? lstOfTypology: new List<String>{ null };
        
            lstOfofferMaster = [Select Id,Offer_Unique_Key__c from Offer_Master__c];
            for(Offer_Master__c offerMaster : lstOfofferMaster){
                existingUniqueKeys.add(offerMaster.Offer_Unique_Key__c);
            }
                
            List<Offer_Master_Data__c> lstOfmasterData = [Select Id,Name,Monetizable__c,Offer_calculation__c,Offer_Type__c,
                                                        Offer_Value__c,Start_Date__c,End_Date__c,Discount_Category__c,Image__c
                                                            from Offer_Master_Data__c where Id=:offerId];
            
                for(Offer_Master_Data__c offerData :lstOfmasterData){
                    for(Id towerId : lstOftowers){
                            for(String typology :lstOftypologies){
                                String towerName =(towerId != null && towerIdToNameMap.containsKey(towerId))? towerIdToNameMap.get(towerId): '';
                        //String uniqueKey = offerData.Name+'-'+projName+'-'+towerName+'-'+typology;
                        String uniqueKey = offerData.Name+'-'+projName;

                        if (towerName != null && towerName != '') {
                            uniqueKey +='-'+towerName;
                        }

                        if (typology != null && typology != '') {
                            uniqueKey +='-'+typology;
                        }

                        System.debug('uniqueKey1**'+uniqueKey);
                                Offer_Master__c offerMaster = new Offer_Master__c();
                                offerMaster.Name = offerData.Name+'-'+projName+'-'+towerName+'-'+typology;
                                offerMaster.Project__c = projectIds;  
                                offerMaster.Monetizable__c = offerData.Monetizable__c;
                                offerMaster.Offer_calculation__c = offerData.Offer_calculation__c;
                                offerMaster.Offer_type__c = offerData.Offer_Type__c;
                                offerMaster.Offer_Value__c = offerData.Offer_Value__c;
                                offerMaster.Start_Date__c = offerData.Start_Date__c;
                                offerMaster.End_Date__c = offerData.End_Date__c;
                                offerMaster.Discount_Category__c = offerData.Discount_Category__c;
                                offerMaster.Image__c = offerData.Image__c;
      
                                if(towerId!=null){
                                    offerMaster.Tower__c = towerId;
                                }
                                if(typology!=null){
                                    offerMaster.Typology__c = typology;
                                }
                        System.debug('uniqueKey**'+uniqueKey);
                        if (existingUniqueKeys.contains(uniqueKey)) {
                            duplicateKeys.add(uniqueKey);
                            continue; // skip creation
                        }

                        offerMaster.Offer_Unique_Key__c = uniqueKey;

                                offerMasterToInsert.add(offerMaster);
                            }
                    }
                }
            System.debug('offerMasterToInsert**'+offerMasterToInsert);
            if (!duplicateKeys.isEmpty()) {
                throw new AuraHandledException(
                    'Offer already exists for the following combination(s): \n' +
                    String.join(new List<String>(duplicateKeys), '\n')  
                );
            }
            if (!offerMasterToInsert.isEmpty() && offerMasterToInsert.size()>0) {
                upsert offerMasterToInsert Offer_Unique_Key__c;
            }
        }
        catch (AuraHandledException ahe) {
            throw ahe; 
        }
        catch(Exception ex){
            throw new AuraHandledException(
                'Unexpected error occurred: ' + ex.getMessage()
            );
        }
    }

    // @AuraEnabled
    // public static void createOffers(Id projectId,List<Id> offerIds,List<Id> towerIds,List<String> lstOfTypology) 
    //     {
    //     try {
    //         // ================== BASIC GUARDS ==================
    //         if (projectId == null || offerIds == null || offerIds.isEmpty()) {
    //             return;
    //         }

    //         List<Id> towers = (towerIds != null && !towerIds.isEmpty())
    //             ? towerIds
    //             : new List<Id>{ null };

    //         List<String> typologies = (lstOfTypology != null && !lstOfTypology.isEmpty())
    //             ? lstOfTypology
    //             : new List<String>{ null };

    //         // ================== MASTER DATA ==================
    //         List<Offer_Master_Data__c> masterDataList = [
    //             SELECT Id, Name, Monetizable__c, Offer_calculation__c,
    //                 Offer_Type__c, Offer_Value__c,
    //                 Start_Date__c, End_Date__c,
    //                 Discount_Category__c, Image__c
    //             FROM Offer_Master_Data__c
    //             WHERE Id IN :offerIds
    //         ];

    //         // ================== TOWER NAME MAP ==================
    //         Map<Id, String> towerNameMap = new Map<Id, String>();
    //         if (towerIds != null && !towerIds.isEmpty()) {
    //             for (Tower__c t : [
    //                 SELECT Id, Name FROM Tower__c WHERE Id IN :towerIds
    //             ]) {
    //                 towerNameMap.put(t.Id, t.Name);
    //             }
    //         }

    //         // ================== PREPARE DATA ==================
    //         List<Offer_Master__c> recordsToInsert = new List<Offer_Master__c>();
    //         Set<String> newKeys = new Set<String>();
    //         Map<String, String> readableMap = new Map<String, String>();

    //         for (Offer_Master_Data__c data : masterDataList) {
    //             for (Id towerId : towers) {
    //                 for (String typology : typologies) {

    //                     String towerKey = towerId != null ? towerId : 'NA';
    //                     String typoKey  = typology != null ? typology : 'NA';

    //                     String uniqueKey =
    //                         data.Name +'-'+
    //                         projectId +'-'+
    //                         towerKey +'-'+
    //                         typoKey;

    //                     // ---------- Human readable label ----------
    //                     String label = data.Name;

    //                     if (towerId != null) {
    //                         label +='-'+towerNameMap.get(towerId);
    //                     }
    //                     if (typology != null) {
    //                         label +='-'+typology;
    //                     }

    //                     newKeys.add(uniqueKey);
    //                     readableMap.put(uniqueKey, label);

    //                     Offer_Master__c om = new Offer_Master__c();
    //                     om.Name = data.Name;
    //                     om.Project__c = projectId;
    //                     om.Tower__c = towerId;
    //                     om.Typology__c = typology;
    //                     om.Monetizable__c = data.Monetizable__c;
    //                     om.Offer_calculation__c = data.Offer_calculation__c;
    //                     om.Offer_type__c = data.Offer_Type__c;
    //                     om.Offer_Value__c = data.Offer_Value__c;
    //                     om.Start_Date__c = data.Start_Date__c;
    //                     om.End_Date__c = data.End_Date__c;
    //                     om.Discount_Category__c = data.Discount_Category__c;
    //                     om.Image__c = data.Image__c;
    //                     om.Offer_Unique_Key__c = uniqueKey;

    //                     recordsToInsert.add(om);
    //                 }
    //             }
    //         }

    //         // ================== DUPLICATE CHECK ==================
    //         List<String> duplicates = new List<String>();

    //         for (Offer_Master__c ex : [
    //             SELECT Id, Offer_Unique_Key__c
    //             FROM Offer_Master__c
    //             WHERE Offer_Unique_Key__c IN :newKeys
    //         ]) {
    //             if (readableMap.containsKey(ex.Offer_Unique_Key__c)) {
    //                 duplicates.add(readableMap.get(ex.Offer_Unique_Key__c));
    //             }
    //         }

    //         if (!duplicates.isEmpty()) {
    //             throw new AuraHandledException(
    //                 'The following offers already exist:\n• ' +
    //                 String.join(duplicates, '\n• ')
    //             );
    //         }

    //         // ================== INSERT ==================
    //         if (!recordsToInsert.isEmpty()) {
    //             insert recordsToInsert;
    //         }

    //     } catch (Exception ex) {
    //         throw new AuraHandledException(ex.getMessage());
    //     }
    // }

}