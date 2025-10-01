global class ScheduleAssignBaseBrkaccruedDashboards implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchtoAssignBaseBrkaccruedDashboards  bb = new BatchtoAssignBaseBrkaccruedDashboards();
        Database.executeBatch(bb,50);
    }
}