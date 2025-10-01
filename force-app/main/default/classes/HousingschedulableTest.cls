@isTest
    public class HousingschedulableTest {
        @isTest
            public static void test () {
                Test.startTest();
                 //Test.setMock(HttpCalloutMock.class, new HousingComSuccessCalloutMockImpl());
                    LeadsFromHousingComScheduled sch1 = new LeadsFromHousingComScheduled();
                    String sch = '0 0 23 * * ?'; 
                    system.schedule('housing lead test', sch, sch1); 
                    //sch1.execute(sch);
                Test.StopTest();
            }
    }