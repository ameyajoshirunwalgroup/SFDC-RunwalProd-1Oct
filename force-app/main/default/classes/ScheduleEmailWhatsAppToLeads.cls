public class ScheduleEmailWhatsAppToLeads implements Schedulable{
    
   public void execute(SchedulableContext ctx) {
      SendEmailWhatsAppToLeads sendEmailWhatsApp = new SendEmailWhatsAppToLeads();
      database.executeBatch(sendEmailWhatsApp,1);
   }   
}