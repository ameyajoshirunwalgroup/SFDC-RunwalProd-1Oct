public class CustomerPortalBannersController {
    
    @AuraEnabled
    public static string banners(List<String> documentIds, String bannerType){
        try {
            //List<cloudx_cms__SS_Carousel__c> carousels = [SELECT Id, cloudx_cms__Name__c, cloudx_cms__No_of_Slides__c FROM cloudx_cms__SS_Carousel__c WHERE cloudx_cms__Name__c =: bannerType];
            List<cloudx_cms__SS_Carousel__c> carousels = [SELECT Id, cloudx_cms__Name__c, cloudx_cms__No_of_Slides__c FROM cloudx_cms__SS_Carousel__c];
            Map<String, cloudx_cms__SS_Carousel__c> carousalMap = new Map<String, cloudx_cms__SS_Carousel__c>();
            for(cloudx_cms__SS_Carousel__c car : carousels){
                carousalMap.put(car.cloudx_cms__Name__c, car);
            }
            List<ContentVersion> cvs = [SELECT Id, Title FROM contentversion WHERE contentdocumentid =: documentIds];
            List<ContentDistribution> cds = new List<ContentDistribution>();
            for(ContentVersion cv : cvs){
                ContentDistribution cd = new ContentDistribution();
                cd.Name = cv.Title;
                cd.ContentVersionId = cv.Id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                cds.add(cd);
            }
            insert cds;

            List<cloudx_cms__SS_Carousel_Slide__c> existingSlides = [SELECT Id, cloudx_cms__Carousel__c FROM cloudx_cms__SS_Carousel_Slide__c WHERE cloudx_cms__Carousel__c =: carousalMap.get(bannerType).Id];
            for(cloudx_cms__SS_Carousel_Slide__c slid : existingSlides){
                slid.cloudx_cms__Carousel__c = carousalMap.get('OlderBanners').Id;
                slid.Actual_Carousel__c = carousalMap.get(bannerType).Id;
            }
            update existingSlides;
            //delete existingSlides;

            List<ContentDistribution> distributionList = [SELECT ContentDocumentId, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE ContentDocumentId =: documentIds];
            List<cloudx_cms__SS_Carousel_Slide__c> slides = new List<cloudx_cms__SS_Carousel_Slide__c>();


            for(ContentDistribution dist : distributionList){
                cloudx_cms__SS_Carousel_Slide__c slide = new cloudx_cms__SS_Carousel_Slide__c();
                slide.cloudx_cms__Carousel__c = carousalMap.get(bannerType).Id;
                slide.cloudx_cms__Image_URL__c = dist.ContentDownloadUrl;
                slide.cloudx_cms__Slide_Order__c = distributionList.indexOf(dist) + 1;
                slide.File_Id__c = dist.ContentDocumentId;
                slides.add(slide);
            }
            insert slides;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static void syncCustPortalToCpPortal(){

        List<cloudx_cms__SS_Carousel__c> carousels = [SELECT Id, cloudx_cms__Name__c, cloudx_cms__No_of_Slides__c FROM cloudx_cms__SS_Carousel__c];
        Map<String, cloudx_cms__SS_Carousel__c> carousalMap = new Map<String, cloudx_cms__SS_Carousel__c>();
        for(cloudx_cms__SS_Carousel__c car : carousels){
            carousalMap.put(car.cloudx_cms__Name__c, car);
        }

        List<cloudx_cms__SS_Carousel_Slide__c> existingSlides = [SELECT Id, cloudx_cms__Carousel__c FROM cloudx_cms__SS_Carousel_Slide__c WHERE cloudx_cms__Carousel__c =: carousalMap.get('PartnerPortalHeader').Id];
        for(cloudx_cms__SS_Carousel_Slide__c slid : existingSlides){
            slid.cloudx_cms__Carousel__c = carousalMap.get('OlderBanners').Id;
            slid.Actual_Carousel__c = carousalMap.get('PartnerPortalHeader').Id;
        }
        update existingSlides;

        List<cloudx_cms__SS_Carousel_Slide__c> custPortalSlides = [SELECT Id, cloudx_cms__Carousel__c, cloudx_cms__Image_URL__c, cloudx_cms__Slide_Order__c, File_Id__c FROM cloudx_cms__SS_Carousel_Slide__c WHERE cloudx_cms__Carousel__c =: carousalMap.get('CommunityHeaders').Id];
        List<cloudx_cms__SS_Carousel_Slide__c> slides = new List<cloudx_cms__SS_Carousel_Slide__c>();
        for(cloudx_cms__SS_Carousel_Slide__c s : custPortalSlides){
            cloudx_cms__SS_Carousel_Slide__c slide = new cloudx_cms__SS_Carousel_Slide__c();
            slide.cloudx_cms__Carousel__c = carousalMap.get('PartnerPortalHeader').Id;
            slide.cloudx_cms__Image_URL__c = s.cloudx_cms__Image_URL__c;
            slide.cloudx_cms__Slide_Order__c = s.cloudx_cms__Slide_Order__c;
            slide.File_Id__c = s.File_Id__c;
            slides.add(slide);
        }
        insert slides;
    }
    
}