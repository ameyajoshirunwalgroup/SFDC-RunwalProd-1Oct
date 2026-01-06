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
    
    /**Added for SDR/ROC Management starts */
    public void calculateRRR(List<Id> unitIds){

        System.debug('unitIds**'+unitIds);

        Decimal carpetarea=0;
        Decimal deckArea=0;
        Decimal utilityArea=0;
        Decimal serviceArea=0;
        Decimal reraCarpetArea=0;
        Decimal totalAreaInMtr=0;
        Decimal sqrMtrBuiltUp=0;
        Decimal parkingCount = 0;
        Decimal parkingMtrs = 0;
        Decimal totalArea = 0;
        Decimal floorRiseValue =0;
        Decimal finalArea = 0;
        Decimal marketValue = 0;
        Decimal totalMV = 0;
        Decimal floorRisePercentage = 0;
        Decimal bigProjectPercentage = 0;
        Decimal bigProjectValue = 0;
        Decimal totalAreaMV = 0;
        Decimal parkingAreaMV = 0;
        Decimal SDForBrokerage = 0;

        Set<Id> oppIds = new Set<Id>();
        Set<Id> unitIdsSet = new Set<Id>();
        Set<String> projNames = new Set<String>();
        Set<Decimal> floorNumber = new Set<Decimal>();

        Decimal areaCalculation = Decimal.valueOf(System.label.Area_Calculation);
        Decimal sqrMtrBuiltUpValue = Decimal.valueOf(System.label.Square_Meter_Built_Up);
        Decimal parkingArea = Decimal.valueOf(System.label.Parking_Area);
        Decimal parkingMultiplication = Decimal.valueOf(System.label.Parking_Multiplication);
        Decimal additionalMultiplication = Decimal.valueOf(System.label.Additional_Mutiplication);

        System.debug('areaCalculation**'+areaCalculation);
        System.debug('sqrMtrBuiltUpValue**'+sqrMtrBuiltUpValue);
        System.debug('parkingArea**'+parkingArea);
        System.debug('parkingMultiplication**'+parkingMultiplication);
        System.debug('additionalMultiplication**'+additionalMultiplication);

        List<Quotation__c> quoteLst = new List<Quotation__c>();
        List<Quotation__c> quotelstToUpdate = new List<Quotation__c>();
        List<Floor_Rise__mdt> floorRiseLst = new List<Floor_Rise__mdt>();
        List<Big_Project__mdt> bigProjectLst = new List<Big_Project__mdt>();

        List<Project_Unit__c> projUnitLst =[Select Id,RW_Customer__c,RW_Project__c,RW_Project__r.Name,New_Floor__c from Project_Unit__c where Id=:unitIds AND SD_Paid_By_Runwal__c = true];
        if (projUnitLst.isEmpty()) return;

        System.debug('projUnitLst size = '+ projUnitLst.size());
        System.debug('projUnitLst = ' + projUnitLst);

        for(Project_Unit__c projUnit :projUnitLst){
            if(projUnit.RW_Customer__c!=null){
                oppIds.add(projUnit.RW_Customer__c);
                unitIdsSet.add(projUnit.Id);
                projNames.add(projUnit.RW_Project__r.Name);
                floorNumber.add(Decimal.valueOf(projUnit.New_Floor__c));
            }
        }
        System.debug('projNames**'+projNames);
        System.debug('floorNumber**'+floorNumber);
        System.debug('unitIdsSet**'+unitIdsSet);
        System.debug('oppIds**'+oppIds);

        floorRiseLst = [Select Id,Max_Value__c,Min_Value__c,Percentage_Value__c,Project__c from Floor_Rise__mdt where Project__c=:projNames];
        bigProjectLst = [Select Id,Applicable_Percentage__c,Project__c from Big_Project__mdt where Project__c=:projNames];
        
        System.debug('floorRiseLst**'+floorRiseLst);

        quoteLst = [Select Id,No_of_parking__c,Total_MV__c,Project_Unit__r.New_Floor__c,Project__r.Name,Project_Unit__r.Carpet_Area__c,Project_Unit__r.Total_RERA_Carpet_Area__c,Agreement_Value__c,Project_Unit__r.Deck_Area__c,Project_Unit__r.Service_Room_Carpet_Area__c,Project_Unit__r.Utility_Area__c,Project__r.S_Ready_Reckoner_Rate__c,Project_Unit__r.S_Charge_Percentage__c from Quotation__c where Project_Unit__c=:unitIdsSet AND Quote_Status__c='Valid' AND Opportunity__c =:oppIds];
         System.debug('quoteLst**'+quoteLst);

        for(Quotation__c quote : quoteLst){
            carpetarea = quote.Project_Unit__r.Carpet_Area__c !=null ? quote.Project_Unit__r.Carpet_Area__c/areaCalculation : 0;
            System.debug('carpetarea**'+carpetarea);

            deckArea = quote.Project_Unit__r.Deck_Area__c !=null ? quote.Project_Unit__r.Deck_Area__c/areaCalculation :0;
            System.debug('deckArea**'+deckArea);

            utilityArea = quote.Project_Unit__r.Utility_Area__c !=null ? quote.Project_Unit__r.Utility_Area__c/areaCalculation : 0;
            System.debug('utilityArea**'+utilityArea);

            reraCarpetArea = quote.Project_Unit__r.Total_RERA_Carpet_Area__c !=null ? quote.Project_Unit__r.Total_RERA_Carpet_Area__c/areaCalculation :0;
            System.debug('reraCarpetArea**'+reraCarpetArea);

            serviceArea = quote.Project_Unit__r.Service_Room_Carpet_Area__c !=null ? quote.Project_Unit__r.Service_Room_Carpet_Area__c/areaCalculation :0;
            System.debug('serviceArea**'+serviceArea);

            totalAreaInMtr = carpetarea + deckArea + utilityArea + serviceArea+reraCarpetArea;
            System.debug('totalAreaInMtr**'+totalAreaInMtr);
            
            sqrMtrBuiltUp = totalAreaInMtr*sqrMtrBuiltUpValue;
            System.debug('sqrMtrBuiltUp**'+sqrMtrBuiltUp);
            
            parkingCount = quote.No_of_parking__c;
            parkingMtrs = parkingCount*(parkingArea*parkingMultiplication);
            System.debug('parkingMtrs**'+parkingMtrs);
            
            //totalArea = sqrMtrBuiltUp + parkingMtrs;

            marketValue = quote.Project__r.S_Ready_Reckoner_Rate__c;
            System.debug('marketValue**'+marketValue);

           // finalArea = totalArea*additionalMultiplication;
            
            for(Big_Project__mdt bigProjectObj : bigProjectLst){
            if(bigProjectObj.Project__c!=null && bigProjectObj.Applicable_Percentage__c!=null){
                if(bigProjectObj.Project__c == quote.Project__r.Name){
                  bigProjectPercentage = Decimal.valueOf(bigProjectObj.Applicable_Percentage__c);
                }
            }
            }
            System.debug('bigProjectPercentage**'+bigProjectPercentage);

            for(Floor_Rise__mdt floorRiseObj:floorRiseLst){
                if(floorRiseObj.Min_Value__c!=null && floorRiseObj.Max_Value__c!=null && floorRiseObj.Percentage_Value__c!=null && 
                   quote.Project_Unit__r.New_Floor__c!= null &&
                   Decimal.valueOf(floorRiseObj.Min_Value__c) <= Decimal.valueOf(quote.Project_Unit__r.New_Floor__c) && 
                   Decimal.valueOf(floorRiseObj.Max_Value__c) >= Decimal.valueOf(quote.Project_Unit__r.New_Floor__c))
                {
                floorRisePercentage =  Decimal.valueOf(floorRiseObj.Percentage_Value__c);
                }

                System.debug('floorRisePercentage**'+floorRisePercentage);

                
                // if(totalArea!=null && floorRisePercentage!=null ){
                // floorRiseValue = (totalArea*floorRisePercentage)/100;
                //}
            }

            bigProjectValue = marketValue * bigProjectPercentage;
            System.debug('bigProjectValue**'+bigProjectValue);

            floorRiseValue = bigProjectValue * floorRisePercentage;
            System.debug('floorRiseValue**'+floorRiseValue);

            totalAreaMV = sqrMtrBuiltUp * floorRiseValue;
            System.debug('totalAreaMV**'+totalAreaMV);

            parkingAreaMV = parkingMtrs * bigProjectValue ;
            System.debug('parkingAreaMV**'+parkingAreaMV);
            
            if(totalAreaMV!=null && parkingAreaMV!=null){
              totalMV =  Math.ceil((totalAreaMV + parkingAreaMV)/1000*1000);
            }
            System.debug('totalMV**'+totalMV);
            System.debug('quote.Agreement_Value__c**'+quote.Agreement_Value__c);

            if(totalMV!=null){
            quote.Total_MV__c = totalMV;
                if(totalMV > quote.Agreement_Value__c){
                    SDForBrokerage = (quote.Project_Unit__r.S_Charge_Percentage__c*totalMV)/100;
                    quote.Agreement_Value_for_brokers__c = quote.Agreement_Value__c	- SDForBrokerage;
                }
            }
            System.debug('Total_MV__c**'+quote.Total_MV__c);
            quotelstToUpdate.add(quote);
        }

        if(!quotelstToUpdate.isEmpty()){
        update quotelstToUpdate;
    }
    }

    /**Added for SDR/ROC Management ends */
    
}