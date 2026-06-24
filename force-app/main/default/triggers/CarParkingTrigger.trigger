trigger CarParkingTrigger on Car_Parking_Charge__c (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        // ✅ INSERT → update both
        if (Trigger.isInsert) {
            CarParkingTriggerHandler.recalculateCounts(
                Trigger.new, null, true, true
            );
        }

        // ✅ UPDATE → separate logic
        if (Trigger.isUpdate) {

            List<Car_Parking_Charge__c> unitChanged = new List<Car_Parking_Charge__c>();
            List<Car_Parking_Charge__c> statusChanged = new List<Car_Parking_Charge__c>();

            for (Car_Parking_Charge__c newRec : Trigger.new) {
                Car_Parking_Charge__c oldRec = Trigger.oldMap.get(newRec.Id);

                // Unit change
                if (newRec.Project_Unit__c != oldRec.Project_Unit__c) {
                    unitChanged.add(newRec);
                }

                // Status change
                if (newRec.Status__c != oldRec.Status__c) {
                    statusChanged.add(newRec);
                }
            }

            if (!unitChanged.isEmpty()) {
                CarParkingTriggerHandler.recalculateCounts(
                    unitChanged, Trigger.oldMap, true, false
                );
            }

            if (!statusChanged.isEmpty()) {
                CarParkingTriggerHandler.recalculateCounts(
                    statusChanged, Trigger.oldMap, true, true
                );
            }
        }

        // ✅ DELETE → update both
        if (Trigger.isDelete) {
            CarParkingTriggerHandler.recalculateCounts(
                Trigger.old, null, true, true
            );
        }

        // ✅ UNDELETE → update both
        if (Trigger.isUndelete) {
            CarParkingTriggerHandler.recalculateCounts(
                Trigger.new, null, true, true
            );
        }
    }
}