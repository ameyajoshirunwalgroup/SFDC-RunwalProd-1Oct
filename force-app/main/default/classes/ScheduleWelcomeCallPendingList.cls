public class ScheduleWelcomeCallPendingList implements Schedulable {

   public void execute(SchedulableContext ctx) {
      WelcomeCallPendingList welCallPending = new WelcomeCallPendingList();
      database.executeBatch(welCallPending);
   }   

}