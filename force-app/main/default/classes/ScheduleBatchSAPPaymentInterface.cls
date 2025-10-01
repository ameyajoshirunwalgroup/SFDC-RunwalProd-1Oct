global class ScheduleBatchSAPPaymentInterface implements Schedulable
{
   global void execute(SchedulableContext sc) 
   {
        Database.executeBatch(new BatchSAPPaymentInterface());
   }
}