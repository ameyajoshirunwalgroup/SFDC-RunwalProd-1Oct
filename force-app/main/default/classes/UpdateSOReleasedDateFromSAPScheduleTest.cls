@isTest
public class UpdateSOReleasedDateFromSAPScheduleTest 
{
    @isTest
    private static void testscheduledClass()
    {
        UpdateSOReleasedDateFromSAPSchedule sch = new UpdateSOReleasedDateFromSAPSchedule();
        Test.StartTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        String cronExp = '0 0 * * * ?';
        String jobID = System.schedule('Run Payment Interface', cronExp, sch);
        Test.stopTest(); 
    }
}