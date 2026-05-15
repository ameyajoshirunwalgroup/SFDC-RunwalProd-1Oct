global class Schedule20percentReporttoRM implements Schedulable {
    global void execute(SchedulableContext sc) {
        SendReferralCreditEmails.send20PercentReport();
    }
}