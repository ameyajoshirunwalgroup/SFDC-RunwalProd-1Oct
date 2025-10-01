@isTest
public class PostPossessionWhatsAppFBScheduleTest {
    
    @isTest
    private static void test1(){
        
        Booking__c bk = new Booking__c();
        bk.RW_Country_Phone_Code__c = '+91';
        bk.RW_Key_handover_date__c = System.today() - 60;
        insert bk;
        
        
        Test.startTest();
        PostPossessionWhatsAppFBSchedule b = new PostPossessionWhatsAppFBSchedule();
        //Database.executeBatch(b, 20);
        b.execute(null); 
        Test.stopTest();
    }

}