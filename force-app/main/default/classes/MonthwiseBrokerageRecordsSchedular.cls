global class MonthwiseBrokerageRecordsSchedular implements Schedulable {
    global void execute(SchedulableContext sc) {
        MonthwiseBrokerageRecords batch = new MonthwiseBrokerageRecords();
        Database.executebatch(batch,200);
    }
}