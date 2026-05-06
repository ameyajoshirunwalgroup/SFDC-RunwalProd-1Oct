public class CarParkingTriggerHandler {

    public static void recalculateCounts(List<Car_Parking_Charge__c> newList,Map<Id, Car_Parking_Charge__c> oldMap,Boolean isUnitChange,Boolean isStatusChange) {

        Set<Id> projectUnitIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();

        for (Car_Parking_Charge__c rec : newList) {
            if (rec.Project_Unit__c != null) {
                projectUnitIds.add(rec.Project_Unit__c);
            }
            if (rec.Project__c != null) {
                projectIds.add(rec.Project__c);
            }
        }

        // CASE 1 → UNIT LEVEL
        if (isUnitChange && !projectUnitIds.isEmpty()) {
            updateUnitCounts(projectUnitIds);
        }

        // CASE 2 → PROJECT LEVEL
        if (isStatusChange && !projectIds.isEmpty()) {
            updateProjectCounts(projectIds);
        }
    }

    /* ===============================
       UNIT LEVEL COUNT
    =============================== */
    private static void updateUnitCounts(Set<Id> projectUnitIds) {

        List<AggregateResult> parkingAgg = [
            SELECT Project_Unit__c unitId,
                   Parking__c type,
                   COUNT(Id) total
            FROM Car_Parking_Charge__c
            WHERE Project_Unit__c IN :projectUnitIds
            AND Category__c = 'Earmarked'
            AND Status__c = 'Vacant'
            GROUP BY Project_Unit__c, Parking__c
        ];

        Map<Id, Map<String, Integer>> unitMap = new Map<Id, Map<String, Integer>>();

        for (AggregateResult ar : parkingAgg) {
            Id unitId = (Id) ar.get('unitId');
            String type = (String) ar.get('type');
            Integer total = (Integer) ar.get('total');

            if (!unitMap.containsKey(unitId)) {
                unitMap.put(unitId, new Map<String, Integer>());
            }
            unitMap.get(unitId).put(type, total);
        }

        List<Project_Unit__c> units = [
            SELECT Id,Single_car_park_Earmarked__c,Tandem_car_park_Earmarked__c,Single_Open_Earmarked__c,Tandem_Open_Earmarked__c,Stack__c,
            MLCP_Earmarked__c,Basement_Earmarked__c,Podium_Earmarked__c,Puzzle_Car_Park_Earmarked__c,Covered_Stack_Earmarked__c,Stack_Car_Park_Earmarked__c
            FROM Project_Unit__c
            WHERE Id IN :projectUnitIds
        ];

        for (Project_Unit__c unit : units) {

            Map<String, Integer> counts = unitMap.containsKey(unit.Id) ? unitMap.get(unit.Id) : new Map<String, Integer>();

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

        if (!units.isEmpty()) {
            update units;
        }
    }

    /* ===============================
       PROJECT LEVEL COUNT
    =============================== */
    private static void updateProjectCounts(Set<Id> projectIds) {

        List<AggregateResult> projectAgg = [
            SELECT Project__c projectId,
                   Parking__c type,
                   COUNT(Id) total
            FROM Car_Parking_Charge__c
            WHERE Project__c IN :projectIds
            AND Category__c = 'Earmarked'
            AND Status__c = 'Vacant'
            AND Project_Unit__c!=null
            GROUP BY Project__c, Parking__c
        ];

        Map<Id, Map<String, Integer>> projectMap = new Map<Id, Map<String, Integer>>();

        for (AggregateResult ar : projectAgg) {
            Id projId = (Id) ar.get('projectId');
            String type = (String) ar.get('type');
            Integer total = (Integer) ar.get('total');

            if (!projectMap.containsKey(projId)) {
                projectMap.put(projId, new Map<String, Integer>());
            }
            projectMap.get(projId).put(type, total);
        }

        List<Project__c> projects = [
            SELECT Id,
                   Basement_Earmarked_Available__c,Podium_Earmarked_Available__c,Puzzle_Car_Park_Earmarked_Available__c,Tandem_Covered_Earmarked_Available__c,
                   Covered_Stack_Earmarked_Available__c,Single_Covered_Earmarked_Available__c,Single_Open_Earmarked_Available__c,Tandem_Open_Earmarked_Available__c,
                   MLCP_Earmarked_Available__c,Stack_Car_Park_Earmarked_Available__c,Stilt_Earmarked_Available__c
            FROM Project__c
            WHERE Id IN :projectIds
        ];

        for (Project__c proj : projects) {

            Map<String, Integer> counts = projectMap.containsKey(proj.Id) ? projectMap.get(proj.Id) : new Map<String, Integer>();

            proj.Single_Covered_Earmarked_Available__c = counts.containsKey('Single Covered') ? counts.get('Single Covered') : 0;

            proj.Tandem_Covered_Earmarked_Available__c = counts.containsKey('Tandem Covered') ? counts.get('Tandem Covered') : 0;

            proj.Single_Open_Earmarked_Available__c = counts.containsKey('Single Open') ? counts.get('Single Open') : 0;

            proj.Tandem_Open_Earmarked_Available__c = counts.containsKey('Tandem Open') ? counts.get('Tandem Open') : 0;

            proj.Stilt_Earmarked_Available__c = counts.containsKey('Stilt') ? counts.get('Stilt') : 0;

            proj.MLCP_Earmarked_Available__c = counts.containsKey('MLCP') ? counts.get('MLCP') : 0;

            proj.Basement_Earmarked_Available__c = counts.containsKey('Basement') ? counts.get('Basement') : 0;

            proj.Podium_Earmarked_Available__c = counts.containsKey('Podium') ? counts.get('Podium') : 0;

            proj.Puzzle_Car_Park_Earmarked_Available__c = counts.containsKey('Puzzle Car Park') ? counts.get('Puzzle Car Park') : 0;

            proj.Covered_Stack_Earmarked_Available__c = counts.containsKey('Covered Stack') ? counts.get('Covered Stack') : 0;

            proj.Stack_Car_Park_Earmarked_Available__c = counts.containsKey('Stack Car Park') ? counts.get('Stack Car Park') : 0;
        }

        if (!projects.isEmpty()) {
            update projects;
        }
    }
}