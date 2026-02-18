trigger CarParkingTrigger on Car_Parking_Charge__c(after insert, after update) {
	// Your trigger logic here
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
            CarParkingTriggerHandler.recalculateCounts(Trigger.new, null);
        }
		if (Trigger.isUpdate) {

            List<Car_Parking_Charge__c> filteredList = new List<Car_Parking_Charge__c>();

            for (Car_Parking_Charge__c newRec : Trigger.new) {
                Car_Parking_Charge__c oldRec = Trigger.oldMap.get(newRec.Id);

                // Run ONLY when relevant fields change
                if (
                    newRec.Project_Unit__c != oldRec.Project_Unit__c ||
                    newRec.Status__c != oldRec.Status__c
                ) {
                    filteredList.add(newRec);
                }
            }

            if (!filteredList.isEmpty()) {
                CarParkingTriggerHandler.recalculateCounts(filteredList, Trigger.oldMap);
            }
        }
	}
}