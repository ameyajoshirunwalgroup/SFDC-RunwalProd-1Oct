trigger ClonePaymentPlan on Payment_Plan__c (after insert) {
    
    List<Payment_Plan__c> clnRecords = (List<Payment_Plan__c>) Trigger.new;
     if(clnRecords.get(0).isClone()){

        
         Payment_Plan__c clnPln = clnRecords.get(0);
         Payment_Plan__c orgPlan = [SELECT Id, Name, Project__c FROM Payment_Plan__c WHERE Id =: clnRecords.get(0).getCloneSourceId()];
         
                  
         
       	 //List<Project_Charges__c> lstProjectCharges = [select Id, Name from Project_Charges__c where Project__c =: orgPlan.Project__c AND Payment_Plan_Applicable__c = true ORDER BY Name limit 999];  
       	 List<Project_Charges__c> lstProjectCharges = [select Id, Name from Project_Charges__c where Project__c =: clnPln.Project__c AND Payment_Plan_Applicable__c = true ORDER BY Name limit 999];            
         //List<Standard_Pay_Plan_Header__c> lstPayPlanHeader = [select Id, Name, Project__c, Plan_Code__c, Tower__c, Payment_Plan__c, Charge_Code__r.Name from Standard_Pay_Plan_Header__c where Payment_Plan__c =: orgPlan.Id AND Project__c =: orgPlan.Project__c ORDER BY Charge_Code__r.Name limit 999];
         List<Standard_Pay_Plan_Header__c> lstPayPlanHeader = [select Id, Name, Project__c, Plan_Code__c, Tower__c, Payment_Plan__c, Charge_Code__r.Name from Standard_Pay_Plan_Header__c where Payment_Plan__c =: orgPlan.Id AND Project__c =: orgPlan.Project__c ORDER BY Charge_Code__r.Name limit 999];
         System.debug('lstPayPlanHeader: ' + lstPayPlanHeader);
         
         List<Standard_Pay_Plan_Header__c> listHeaders = new List<Standard_Pay_Plan_Header__c>();
         for(Integer i=0; i < lstPayPlanHeader.size(); i++){
             Standard_Pay_Plan_Header__c headerClone  = lstPayPlanHeader[i].clone(false, true, false, false);
             headerClone.Charge_Code__c = lstPayPlanHeader[i].Charge_Code__c;
             //headerClone.Project__c = lstPayPlanHeader[i].Project__c;
             headerClone.Project__c = clnPln.Project__c;
             headerClone.Payment_Plan__c = clnPln.Id;
             headerClone.Name = lstPayPlanHeader[i].Name;
             headerClone.Tower__c = clnPln.Tower__c;
             headerClone.Plan_Code__c = clnPln.Plan_Code__c;
             listHeaders.add(headerClone);
         }
         insert listHeaders;
         
         Set<Id> setHeaderId = new Set<Id>();
         Map<Id, Id> mapOrgVsClndHeadrIds = new Map<Id, Id>();
         Map<Id, Standard_Pay_Plan_Header__c> mapOrgVsClndHeadr = new Map<Id, Standard_Pay_Plan_Header__c>();
                
         if(lstPayPlanHeader != Null && lstPayPlanHeader.size() > 0){
             
             for(Standard_Pay_Plan_Header__c objPayPlanHeader : lstPayPlanHeader){
                 for(Standard_Pay_Plan_Header__c clndPlanHeader : listHeaders){
                     if(clndPlanHeader.Charge_Code__c == objPayPlanHeader.Charge_Code__c && clndPlanHeader.Name == objPayPlanHeader.Name){
                         mapOrgVsClndHeadrIds.put(objPayPlanHeader.Id, clndPlanHeader.Id);
                         mapOrgVsClndHeadr.put(clndPlanHeader.Id, clndPlanHeader);
                     }
                 }
                 
             }
             
             if(mapOrgVsClndHeadrIds.keySet() != Null && mapOrgVsClndHeadrIds.size() > 0){
                 System.debug('mapOrgVsClndHeadrIds: ' + mapOrgVsClndHeadrIds.keySet());
                 
                 
                 List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForDays = [select Id, Registration_Linked__c, Tower__c, Amount_Value__c, Is_to_be_Paid__c, Project_Construction_Stages__c, Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                            where Standard_Pay_Plan_Header__c IN: mapOrgVsClndHeadrIds.keySet() AND 
                                                                            Is_to_be_Paid__c = 'From Dt. of Booking'
                                                                            AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                 
                 System.debug('lstPayPlanDetailsForDays: ' + lstPayPlanDetailsForDays);
                 List<Standard_Customer_Pay_Plan_Detail__c> dateOfBookingList = new List<Standard_Customer_Pay_Plan_Detail__c>();
                 for(Integer i=0; i < lstPayPlanDetailsForDays.size(); i++){
                     Standard_Customer_Pay_Plan_Detail__c daysDetailsClone  = lstPayPlanDetailsForDays[i].clone(false, true, false, false);
                     daysDetailsClone.Standard_Pay_Plan_Header__c = mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForDays[i].Standard_Pay_Plan_Header__c);
                     //daysDetailsClone.Is_to_be_Paid__c = lstPayPlanDetailsForDays[i].Is_to_be_Paid__c;
                     //daysDetailsClone.Project_Construction_Stages__c = lstPayPlanDetailsForDays[i].Project_Construction_Stages__c;
                     //daysDetailsClone.Tower__c = lstPayPlanDetailsForDays[i].Tower__c;
                     daysDetailsClone.Tower__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForDays[i].Standard_Pay_Plan_Header__c)).Tower__c;
                     daysDetailsClone.Project__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForDays[i].Standard_Pay_Plan_Header__c)).Project__c;
                     //daysDetailsClone.Amount_Value__c = lstPayPlanDetailsForDays[i].Amount_Value__c;
                     dateOfBookingList.add(daysDetailsClone);
                 }
                 insert dateOfBookingList;
                 
                 List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForRegisDt = [select Id, Registration_Linked__c, Tower__c, Amount_Value__c, Is_to_be_Paid__c, Project_Construction_Stages__c, Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                                           where Standard_Pay_Plan_Header__c IN: mapOrgVsClndHeadrIds.keySet() AND 
                                                                                           Is_to_be_Paid__c = 'From Dt. of Registration' 
                                                                                           AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                 
                 List<Standard_Customer_Pay_Plan_Detail__c> dateOfRegList = new List<Standard_Customer_Pay_Plan_Detail__c>();
                 for(Integer i=0; i < lstPayPlanDetailsForRegisDt.size(); i++){
                     Standard_Customer_Pay_Plan_Detail__c dtRegClone  = lstPayPlanDetailsForRegisDt[i].clone(false, true, false, false);
                     dtRegClone.Standard_Pay_Plan_Header__c = mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegisDt[i].Standard_Pay_Plan_Header__c);
                     dtRegClone.Tower__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegisDt[i].Standard_Pay_Plan_Header__c)).Tower__c;
                     dtRegClone.Project__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegisDt[i].Standard_Pay_Plan_Header__c)).Project__c;
                     dateOfRegList.add(dtRegClone);
                 }
                 insert dateOfRegList;
                 
                 List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForRegistration = [select Id, Registration_Linked__c , Tower__c, Amount_Value__c, Is_to_be_Paid__c, Project_Construction_Stages__c, Standard_Pay_Plan_Header__c, Days_Months_Value__c, Value__c, Is_to_be__c,OC_Milestone__c from Standard_Customer_Pay_Plan_Detail__c
                                                                                                where Standard_Pay_Plan_Header__c IN: mapOrgVsClndHeadrIds.keySet() AND 
                                                                                                Is_to_be_Paid__c = 'Registration' 
                                                                                                AND Customer_Pay_Plan_Header__c = Null ORDER BY Days_Months_Value__c limit 999];
                 
                 List<Standard_Customer_Pay_Plan_Detail__c> regPlanList = new List<Standard_Customer_Pay_Plan_Detail__c>();
                 for(Integer i=0; i < lstPayPlanDetailsForRegistration.size(); i++){
                     Standard_Customer_Pay_Plan_Detail__c regClone  = lstPayPlanDetailsForRegistration[i].clone(false, true, false, false);
                     regClone.Standard_Pay_Plan_Header__c = mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegistration[i].Standard_Pay_Plan_Header__c);
                     regClone.Tower__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegistration[i].Standard_Pay_Plan_Header__c)).Tower__c;
                     regClone.Project__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForRegistration[i].Standard_Pay_Plan_Header__c)).Project__c;
                     regPlanList.add(regClone);
                 }
                 insert regPlanList;
                 
                 System.debug('mapOrgVsClndHeadrIds: ' + mapOrgVsClndHeadrIds.keySet());
                 List<Standard_Customer_Pay_Plan_Detail__c> lstPayPlanDetailsForStages = [select Id, Registration_Linked__c , Tower__c, Amount_Value__c, Is_to_be_Paid__c, Project_Construction_Stages__c, Standard_Pay_Plan_Header__c, Project_Construction_Stages__r.Sequence_No__c, Value__c, Is_to_be__c,OC_Milestone__c, Project_Construction_Stages__r.Name from Standard_Customer_Pay_Plan_Detail__c 
                                                                                          where Standard_Pay_Plan_Header__c IN: mapOrgVsClndHeadrIds.keySet() AND 
                                                                                          Is_to_be_Paid__c = 'Construction Stage' AND 
                                                                                          Customer_Pay_Plan_Header__c = Null ORDER BY Project_Construction_Stages__r.Sequence_No__c limit 999];
				
				
                 
                 System.debug('lstPayPlanDetailsForStages.size(): ' + lstPayPlanDetailsForStages.size());
                 List<Standard_Customer_Pay_Plan_Detail__c> consrtStageList = new List<Standard_Customer_Pay_Plan_Detail__c>();
                 
                                
                 List<Id> pcsIds = new List<Id>();
                 for(Integer i=0; i < lstPayPlanDetailsForStages.size(); i++){
                     pcsIds.add(lstPayPlanDetailsForStages[i].Project_Construction_Stages__c);
                 }
                 List<Project_Construction_Stages__c> pcs = [SELECT Id, Name, Project__c, Tower__c, Sequence_No__c FROM Project_Construction_Stages__c WHERE Id IN: pcsIds];
                 
                 Map<Id, Id> pcsIdsMap = new Map<Id, Id>();
                 Map<String, Id> pcNameIdsMap = new Map<String, Id>();
                 List<String> pcsNames = new List<String>();
                 List<Decimal> sequenceNums = new List<Decimal>();
                 List<Project_Construction_Stages__c> pcsByTower = [SELECT Id, Name, Project__c, Tower__c, Sequence_No__c FROM Project_Construction_Stages__c WHERE Tower__c =: clnPln.Tower__c AND Sequence_No__c != null];
                 for(Project_Construction_Stages__c pc : pcsByTower){
                     pcsNames.add(pc.Name);
                     pcsIdsMap.put(pc.Id, pc.Id);
                     pcNameIdsMap.put(pc.Name, pc.Id);
                     sequenceNums.add(pc.Sequence_No__c);
                 }
                 
                 List<Project_Construction_Stages__c> pcsToInsert = new List<Project_Construction_Stages__c>();
                 
                 
                 for(Integer i=0; i < pcs.size(); i++){
                     if(!pcsNames.contains(pcs[i].Name)){
                         Decimal seqNum;
                         do {
                             seqNum = randomNum();
                         } while (sequenceNums.contains(seqNum));
                         Project_Construction_Stages__c pcsClone = pcs[i].clone(false, true, false, false);
                         pcsClone.Tower__c = clnPln.Tower__c;
                         pcsClone.Project__c = clnPln.Project__c;
                         pcsClone.Sequence_No__c = seqNum;
                         pcsToInsert.add(pcsClone);
                     }
                     
                 }
                 insert pcsToInsert;
                 for(Integer i=0; i < pcsToInsert.size(); i++){
                     pcsIdsMap.put(pcsToInsert[i].getCloneSourceId(), pcsToInsert[i].Id);
                     pcNameIdsMap.put(pcsToInsert[i].Name, pcsToInsert[i].Id);
                 }
                 
                 for(Integer i=0; i < lstPayPlanDetailsForStages.size(); i++){
                     
                     Standard_Customer_Pay_Plan_Detail__c constrStgClone  = lstPayPlanDetailsForStages[i].clone(false, true, false, false);
                     constrStgClone.Standard_Pay_Plan_Header__c = mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForStages[i].Standard_Pay_Plan_Header__c);
                     constrStgClone.Tower__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForStages[i].Standard_Pay_Plan_Header__c)).Tower__c;
                     constrStgClone.Project__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForStages[i].Standard_Pay_Plan_Header__c)).Project__c;
                     //constrStgClone.Project_Construction_Stages__c = pcsIdsMap.get(lstPayPlanDetailsForStages[i].Project_Construction_Stages__c);
                     constrStgClone.Project_Construction_Stages__c = pcNameIdsMap.get(lstPayPlanDetailsForStages[i].Project_Construction_Stages__r.Name);
                     //constrStgClone.Project_Construction_Stages__c = mapOrgVsClndHeadr.get(mapOrgVsClndHeadrIds.get(lstPayPlanDetailsForStages[i].Standard_Pay_Plan_Header__c)).Project_Construction_Stages__c;
                     consrtStageList.add(constrStgClone);
                 }
                 insert consrtStageList;
                 
             }
         }
                  
         ApexPages.StandardController sc = new  ApexPages.StandardController(clnPln);
         
         ShowPaymentPlanController ext = new ShowPaymentPlanController(sc);
    }
    
    public static Integer randomNum(){
        Integer IntrandomNumber = Integer.valueof((Math.random() * 100));
		return IntrandomNumber;
    }
}