@isTest
public class TestScheduleBatchSAPPaymentInterface 
{
    @isTest
    private static void testscheduledClass()
    {
        ScheduleBatchSAPPaymentInterface sch = new ScheduleBatchSAPPaymentInterface();
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        String cronExp = '0 0 * * * ?';
        String jobID = System.schedule('Run Payment Interface', cronExp, sch);
        Test.stopTest(); 
    }
}