global class SchedulePaymentReminderReporttoRM implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendPaymentReminderReporttoRM.SendPaymentReminderReporttoRM();
    }
}