public class WelcomeCallReceipts {
   @AuraEnabled
    public static List<Receipt__c> fetchReceiptData(string strWcId) {
       
        List<RW_welcome_call__c> listOfWelcomcalls = [Select Id,RW_Booking__c From RW_welcome_call__c where Id=:strWcId];
       //List<Booking__c> bkngList =[SELECT Id,Name,(Select Id From Welcome_Calls__r where id=:strWcId Limit 1) FROM Booking__c limit 1];  
        
       List<Receipt__c> receiptList =[SELECT Name,Mode__c,Total_Amount__c,Cheque_DD_Date__c,DraweeBank__c,Cheque_DD__c FROM Receipt__c 
                                               WHERE Booking__c =: listOfWelcomcalls[0].RW_Booking__c];                        
           system.debug('receiptList!!!! '+receiptList.size()); 
      
        return receiptList;
        
    }
}