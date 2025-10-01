@isTest(SeeAllData=True)
public class ToolingApiControllerTest {
    
   @isTest public static void Test1()
    {
        	  Test.setMock(HttpCalloutMock.class, new HTTPCalloutMockTestCommon());
              ToolingApiPageController  objToolingApiPage = new ToolingApiPageController();
			  objToolingApiPage.StartDate = system.today().addDays(-1);
        	  objToolingApiPage.EndDate = system.today();
        	  objToolingApiPage.callPage();
        	  Test.startTest();
        	  objToolingApiPage.downloadExcel();
        	  Test.stopTest();
    }
    @isTest public static void AuraTest()
    {
        	  Test.setMock(HttpCalloutMock.class, new HTTPCalloutMockTestAuraCommon());
              ToolingApiPageController  objToolingApiPage = new ToolingApiPageController();
			  objToolingApiPage.StartDate = system.today().addDays(-1);
        	  objToolingApiPage.EndDate = system.today();
        	  objToolingApiPage.callPage();
        	  Test.startTest();
        	  objToolingApiPage.downloadExcel();
        	  Test.stopTest();
    }
}