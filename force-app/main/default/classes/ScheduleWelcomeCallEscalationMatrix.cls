public class ScheduleWelcomeCallEscalationMatrix implements Schedulable {

   public void execute(SchedulableContext ctx) {
      WelcomeCallEscalationMatrix welCallEscMartx = new WelcomeCallEscalationMatrix();
      database.executeBatch(welCallEscMartx);
   }   

}