@isTest
public class SAPCPBrokerageCreationQueueableTest {
    @isTest
    public static void testQueueClass(){
        try{
        Id testId = '01I9I000002HnFp';
        Set<Id> setId = new Set<Id>();
        setId.add(testId);
        SAPCPBrokerageCreationQueueable queueableJob = new SAPCPBrokerageCreationQueueable(setId);
        
        System.enqueueJob(queueableJob);  
        }catch(Exception ex){
            
        }
    }
}