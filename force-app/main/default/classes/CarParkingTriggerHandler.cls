public class CarParkingTriggerHandler {

    public static void recalculateCounts(List<Car_Parking_Charge__c> newList,Map<Id, Car_Parking_Charge__c> oldMap) {

        Set<Id> projectUnitIds = new Set<Id>();

        // From new records
        if (newList != null) {
            for (Car_Parking_Charge__c cp : newList) {
                if (cp.Project_Unit__c != null) {
                    projectUnitIds.add(cp.Project_Unit__c);
                }
            }
        }

        // From old records (important when Project Unit changes)
        if (oldMap != null) {
            for (Car_Parking_Charge__c oldCp : oldMap.values()) {
                if (oldCp.Project_Unit__c != null) {
                    projectUnitIds.add(oldCp.Project_Unit__c);
                }
            }
        }

        if (projectUnitIds.isEmpty()) {
            return;
        }

        updateParkingCounts(projectUnitIds);
    }

    /**
     * Recalculate parking counts per Project Unit
     */
    private static void updateParkingCounts(Set<Id> projectUnitIds) {

        // Aggregate parking records
        List<AggregateResult> parkingAgg = [
            SELECT
                Project_Unit__c projectUnitId,
                Parking__c parkingType,
                COUNT(Id) total
            FROM Car_Parking_Charge__c
            WHERE Project_Unit__c IN :projectUnitIds
			AND Category__c = 'Earmarked'
            AND Status__c = 'Vacant'
            GROUP BY Project_Unit__c, Parking__c
        ];

        // Map<ProjectUnitId, Map<ParkingType, Count>>
        Map<Id, Map<String, Integer>> unitParkingMap = new Map<Id, Map<String, Integer>>();

        for (AggregateResult ar : parkingAgg) {
            Id unitId = (Id) ar.get('projectUnitId');
            String type = (String) ar.get('parkingType');
            Integer countVal = (Integer) ar.get('total');

            if (!unitParkingMap.containsKey(unitId)) {
                unitParkingMap.put(unitId, new Map<String, Integer>());
            }
            unitParkingMap.get(unitId).put(type, countVal);
        }

        // Fetch Project Units
        List<Project_Unit__c> unitsToUpdate = [
            SELECT Id,
                   Single_car_park_Earmarked__c,Tandem_car_park_Earmarked__c,Single_Open_Earmarked__c,Tandem_Open_Earmarked__c,
                   Stack__c,MLCP_Earmarked__c,Basement_Earmarked__c,Podium_Earmarked__c,Puzzle_Car_Park_Earmarked__c,
                   Covered_Stack_Earmarked__c,Stack_Car_Park_Earmarked__c
            FROM Project_Unit__c
            WHERE Id IN :projectUnitIds
        ];

        for (Project_Unit__c unit : unitsToUpdate) {

            Map<String, Integer> counts = unitParkingMap.containsKey(unit.Id) ? unitParkingMap.get(unit.Id) : new Map<String, Integer>();

            unit.Single_car_park_Earmarked__c = counts.containsKey('Single Covered') ? counts.get('Single Covered') : 0;

            unit.Tandem_car_park_Earmarked__c = counts.containsKey('Tandem Covered') ? counts.get('Tandem Covered') : 0;

            unit.Single_Open_Earmarked__c = counts.containsKey('Single Open') ? counts.get('Single Open') : 0;

            unit.Tandem_Open_Earmarked__c = counts.containsKey('Tandem Open') ? counts.get('Tandem Open') : 0;

            unit.Stack__c = counts.containsKey('Stilt') ? counts.get('Stilt') : 0;

            unit.MLCP_Earmarked__c = counts.containsKey('MLCP') ? counts.get('MLCP') : 0;

            unit.Basement_Earmarked__c = counts.containsKey('Basement') ? counts.get('Basement') : 0;

            unit.Podium_Earmarked__c = counts.containsKey('Podium') ? counts.get('Podium') : 0;

            unit.Puzzle_Car_Park_Earmarked__c = counts.containsKey('Puzzle Car Park') ? counts.get('Puzzle Car Park') : 0;

            unit.Covered_Stack_Earmarked__c = counts.containsKey('Covered Stack') ? counts.get('Covered Stack') : 0;

            unit.Stack_Car_Park_Earmarked__c = counts.containsKey('Stack Car Park') ? counts.get('Stack Car Park') : 0;

        }

        if (!unitsToUpdate.isEmpty()) {
            update unitsToUpdate;
        }
    }
}