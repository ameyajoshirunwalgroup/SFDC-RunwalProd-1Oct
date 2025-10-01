@isTest
public class CustomerVisitDetailsPageControllerTest {
    
    @isTest
    private static void cvdTest(){
        
        
        
        test.startTest();
        pageReference pagRef = page.CustomerVisitDetailsPage;
        test.setCurrentPage(pagRef);
        CustomerVisitDetailsPageController cvd = new CustomerVisitDetailsPageController();
        cvd.name = 'Test';
        cvd.project = '	Runwal Gardens';
        cvd.tower = 'A';
        cvd.unit = '1245';
        cvd.mobile = '4578965458';
        cvd.email = 'test@mail.com';
        cvd.interestedIn = 'Interiors';
            
        cvd.saveDetails();
        test.stopTest();
    }

}