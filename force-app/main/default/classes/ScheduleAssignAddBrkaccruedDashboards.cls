global class ScheduleAssignAddBrkaccruedDashboards implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchtoAssignAddBrkaccruedDashboards  bb = new BatchtoAssignAddBrkaccruedDashboards();
        Database.executeBatch(bb,50);
    }
}