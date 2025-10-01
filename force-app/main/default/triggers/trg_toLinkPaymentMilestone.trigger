trigger trg_toLinkPaymentMilestone on Standard_Customer_Pay_Plan_Detail__c (before insert,before update) {
    set<Id> Ids = new set<Id>();
    
    set<String> paymentMilestoneSet = new set<String>();
    	for(Standard_Customer_Pay_Plan_Detail__c obj : Trigger.new)
        {
            Ids.add(obj.Standard_Pay_Plan_Header__c);
        }
    List<Standard_Pay_Plan_Header__c> payList = [Select id,Charge_Code__r.Name from Standard_Pay_Plan_Header__c where id in : Ids ];
    system.debug('payList'+payList);
    map<String,String> PayidToChargeMap = new Map<string,String>();
    for(Standard_Pay_Plan_Header__c sd : payList){
        PayidToChargeMap.put(sd.id,sd.Charge_Code__r.Name);
    }
	for(Standard_Customer_Pay_Plan_Detail__c obj : Trigger.new)
	{
   	//	Ids.add(obj.id);
   	system.debug(PayidToChargeMap);
        system.debug('MK');
        if(PayidToChargeMap.containsKey(obj.Standard_Pay_Plan_Header__c)){
   	if(PayidToChargeMap.get(obj.Standard_Pay_Plan_Header__c) == 'Basic')
   	paymentMilestoneSet.add(obj.Is_to_be__c	);
        }
    }
	//	List<Standard_Customer_Pay_Plan_Detail__c> custPayPlan = new List<Standard_Customer_Pay_Plan_Detail__c>([SELECT ID, Is_to_be__c 
                                              //              , Is_to_be_Paid__c , Days_Months__c , Days_Months_Value__c From Standard_Customer_Pay_Plan_Detail__c WHERE Id in  :Ids] );
    
        List<Payment_Milestone__c> recordPaymentMilestone = [Select id, Project_Stage__c,Usage__c ,  Is_to_be_Paid__c from Payment_Milestone__c where Project_Stage__c in :paymentMilestoneSet ];
    map<string,Payment_Milestone__c> milestoneMap = new map<string,Payment_Milestone__c>();

    for(Payment_Milestone__c pm:recordPaymentMilestone ){
        milestoneMap.put(pm.Project_Stage__c,pm);
    }
    Map<string,Payment_Milestone__c> pmtoInsert = new Map<String,Payment_Milestone__c>();
    for(Standard_Customer_Pay_Plan_Detail__c obj : Trigger.new)
    { 	system.debug('obj.Standard_Pay_Plan_Header__r.Charge_Code__r.Name'+obj.Standard_Pay_Plan_Header__r.Charge_Code__r.Name);
        if(PayidToChargeMap.get(obj.Standard_Pay_Plan_Header__c) == 'Basic')
        if(!milestoneMap.containsKey(obj.Is_to_be__c)){
            if(!pmtoInsert.containsKey(obj.Is_to_be__c)){
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.Project_Stage__c = obj.Is_to_be__c;
                pmtoInsert.put(obj.Is_to_be__c,pm);
                //MilestonePaymentEmailNotification.sendEmail(obj.Is_to_be__c , pm.Id);
            }
        }
    }
    
    insert pmtoInsert.values();
    milestoneMap.putAll(pmtoInsert);
    system.debug(milestoneMap);
    
    
    for(Standard_Customer_Pay_Plan_Detail__c obj : Trigger.new)
    {
        if(milestoneMap.containsKey(obj.Is_to_be__c)){
            obj.Payment_Milestone__c = milestoneMap.get(obj.Is_to_be__c).id;
        }
    }
    
    
     
    

}