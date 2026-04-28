public class trgToUpdateOppStageHandler
{
    public void afterUpdate(List<Project_Unit__c> lstProjUnit, Map<Id,Project_Unit__c> mapProjUnit)
    {
        system.debug('**'+lstProjUnit + '@@@@@@@' +mapProjUnit);
        if(lstProjUnit != null && lstProjUnit.size() > 0)
        {
            Set<Id> setIds = new Set<Id>();
            Set<Id> set7th = new Set<Id>();
            Set<Id> setRMUpdate = new Set<Id>();
            Set<Id> unitIds = new Set<Id>();
            Set<Id> setIdSMSForBookedUnit = new Set<Id>();
            for(Project_Unit__c objProjUnit : lstProjUnit)
            {
                if(objProjUnit.RW_Unit_Status__c != mapProjUnit.get(objProjUnit.Id).RW_Unit_Status__c && objProjUnit.RW_Customer__c !=null)
                {
                    setIds.add(objProjUnit.RW_Customer__c);    
                }
                if(objProjUnit.RW_Seventh_Day__c)
                    set7th.add(objProjUnit.RW_Customer__c);  
                //Added by coServe 11-01-2023 Start
                if(objProjUnit.Relationship_Manager__c != mapProjUnit.get(objProjUnit.Id).Relationship_Manager__c && objProjUnit.RW_Customer__c !=null){
                    setRMUpdate.add(objProjUnit.RW_Customer__c);
                    unitIds.add(objProjUnit.Id);
                }
                //Added by coServe 11-01-2023 End
            }
            //system.debug(setIds);
            List<Opportunity> lstUpdateOpp = new List<Opportunity>(); 
            List<RW_EOI__c> eoiRecords = new List<RW_EOI__c>();
            if(setIds != null && setIds.size() > 0)
            {
                List<Opportunity> lstOpp = [SELECT Id, StageName , (Select Id,RW_Status__c from EOI__r) FROM Opportunity WHERE Id IN : setIds];
                
                if(lstOpp != null && lstOpp.size() > 0)
                {
                    for(Project_Unit__c objProj : lstProjUnit)
                    {
                        for(Opportunity objOpp : lstOpp)
                        {system.debug(objOpp.Id);
                         system.debug(objProj.RW_Customer__c);
                            if(objOpp.Id == objProj.RW_Customer__c)
                            {
                                system.debug('@objProj.RW_Unit_Status__c-----'+objProj.RW_Unit_Status__c);
                                if(objProj.RW_Unit_Status__c == 'Booked')
                                {
                                    objOpp.StageName = 'Unit Booked';
                                    //objOpp.RW_Booking_Date_Opp__c = objProj.RW_Booking_Date__c ; // Commented by coServe 04-09-2024, To keep the Blocking Unit Created Date as Booking Date.
                                    lstUpdateOpp.add(objOpp);
                                    system.debug('Inside first list add'+lstUpdateOpp);
                                    setIdSMSForBookedUnit.add(objProj.id);
                                    for(RW_EOI__c eoiRecs : objOpp.EOI__r)
                                    {
                                        if(eoiRecs.RW_Status__c == 'EOI Blocked')
                                        {
                                            eoiRecs.RW_Status__c = 'EOI Booked';
                                            eoiRecords.add(eoiRecs);
                                        }
                                    }
                                } 
                                
                                else if(objProj.RW_Unit_Status__c == 'Hold' || objProj.RW_Unit_Status__c == 'Blocked')
                                {
                                    objOpp.StageName = 'Unit Blocked';
                                    lstUpdateOpp.add(objOpp);
                                    system.debug('Inside second list add'+lstUpdateOpp);
                                } 
                                else if(objProj.RW_Unit_Status__c == 'Documentation Complete')
                                {
                                    objOpp.StageName = 'Documentation Complete';
                                    lstUpdateOpp.add(objOpp);
                                    system.debug('Inside third list add'+lstUpdateOpp);
                                } 
                                else
                                {
                                    objOpp.StageName = 'Qualification';
                                    lstUpdateOpp.add(objOpp);
                                    system.debug('Inside fourth list add'+lstUpdateOpp);
                                }
                            } 
                        }
                    }
                }
            }
            if(set7th!=null && set7th.size()>0)
            {
                List<Opportunity> lstOpp1 = [SELECT Id, StageName FROM Opportunity WHERE Id IN : set7th];
                for(Project_Unit__c objProj1 : lstProjUnit)
                {
                    for(Opportunity objOpp1 : lstOpp1)
                    {
                        if(objOpp1.Id == objProj1.RW_Customer__c && objProj1.Booking__c == null)
                        {
                            objOpp1.RW_Project_Unit__c = null;
                            objOpp1.StageName = 'Qualification';
                            lstUpdateOpp.add(objOpp1);
                            system.debug('Inside fifth list add'+lstUpdateOpp);
                        }
                    }
                }
            }
            //Added by coServe 11-01-2023 Start
            if(setRMUpdate!=null && setRMUpdate.size()>0){
                List<Opportunity> lstOpp2 = [SELECT Id, StageName, RW_RM_Name__c, RW_Project_Unit__c FROM Opportunity WHERE Id IN : setRMUpdate];
                List<Project_Unit__c> lstProjUnits = [SELECT Id, RW_Customer__c, Relationship_Manager__r.Name FROM Project_Unit__c WHERE Id IN : unitIds];
                for(Project_Unit__c objProj2 : lstProjUnits){
                    for(Opportunity objOpp2 : lstOpp2){
                        if(objOpp2.Id == objProj2.RW_Customer__c){
                            objOpp2.RW_RM_Name__c = objProj2.Relationship_Manager__r.Name;
                        	lstUpdateOpp.add(objOpp2);
                            system.debug('Inside sixth list add'+lstUpdateOpp);
                        } 
                    }
                }
            }
            //Added by coServe 11-01-2023 End
            system.debug('@@@@@lstUpdateOpp'+ lstUpdateOpp);
            if(lstUpdateOpp != null && lstUpdateOpp.size() > 0)
            {
                if(!test.isRunningTest())
                    update lstUpdateOpp;
            }
            
            if(eoiRecords!= null && eoiRecords.size() >0)
            {
                update eoiRecords;
            }
            if(setIdSMSForBookedUnit!=null && setIdSMSForBookedUnit.size()>0)
                OutboundSMSFutureHandler.SendSMSOnOppBooking(setIdSMSForBookedUnit);
        }
    }
    
    public void updateTypeLabel(List<Id> unitIds){
        Map<String, String> picklistValues = getPicklistValues('Project_Unit__c', 'New_Type__c');
        list<Project_Unit__c> lstProjUnit = [Select Id,New_Type__c from Project_Unit__c where Id In: unitIds];
        for(Project_Unit__c pu : lstProjUnit){
            system.debug('picklistValues.get(pu.New_Type__c)'+picklistValues.get(pu.New_Type__c));
            if(picklistValues.get(pu.New_Type__c)!= null){
                pu.Type_Label__c = picklistValues.get(pu.New_Type__c);
            }else{
                pu.Type_Label__c = null;
            }
        }
        try{
            update lstProjUnit;
        }catch(Exception e){
            system.debug('Error while updating unit -'+e.getMessage());
        }
    }
    
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe()
            .fields.getMap()
            .get(fieldName)
            .getDescribe();
        
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistEntries) {
            values.put(entry.getValue(), entry.getLabel());
        }
        
        return values;
    }
    
}