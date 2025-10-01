@isTest
public class CustomerPortalBannersControllerTest {

    @isTest
    public static void bannersTest(){
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'SalarySLip',
            PathOnClient = 'SalarySLip.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        List<cloudx_cms__SS_Carousel__c> cars = new List<cloudx_cms__SS_Carousel__c>();
        cloudx_cms__SS_Carousel__c car = new cloudx_cms__SS_Carousel__c();
        car.cloudx_cms__Name__c = 'CommunityHeaders';
        cars.add(car);
        
        cloudx_cms__SS_Carousel__c car2 = new cloudx_cms__SS_Carousel__c();
        car2.cloudx_cms__Name__c = 'PartnerPortalHeader';
        cars.add(car2);
        
        cloudx_cms__SS_Carousel__c carOld = new cloudx_cms__SS_Carousel__c();
        carOld.cloudx_cms__Name__c = 'OlderBanners';
        cars.add(carOld);
        insert cars;
        
        cloudx_cms__SS_Carousel_Slide__c slide1 = new cloudx_cms__SS_Carousel_Slide__c();
        slide1.cloudx_cms__Carousel__c = car.Id;
        insert slide1;
        
        cloudx_cms__SS_Carousel_Slide__c slide2 = new cloudx_cms__SS_Carousel_Slide__c();
        slide2.cloudx_cms__Carousel__c = car2.Id;
        insert slide2;
        
        CustomerPortalBannersController.banners(new List<String>{documents[0].Id}, 'CommunityHeaders');
        CustomerPortalBannersController.syncCustPortalToCpPortal();
    }
}