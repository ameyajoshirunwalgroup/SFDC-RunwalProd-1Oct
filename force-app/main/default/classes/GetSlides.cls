@RestResource(urlMapping='/GetSlides/*')
global without sharing class GetSlides {
	
    @HttpGet
    global static List<String> slidesList(){
        List<cloudx_cms__SS_Carousel_Slide__c> slides;
        List<ContentDistribution> distList = new List<ContentDistribution>();
        
        if(!Test.isRunningTest()){
            slides = [SELECT Id, Name, cloudx_cms__Carousel__c, cloudx_cms__Image_URL__c, File_Id__c
                                                        FROM cloudx_cms__SS_Carousel_Slide__c WHERE cloudx_cms__Carousel__c =: System.Label.Carousel];
            //List<String> slideIds = System.label.Slides_on_Lockated_App.split(',');
            List<String> slideIds = new List<String>();
            for(cloudx_cms__SS_Carousel_Slide__c slide : slides){
                slideIds.add(slide.File_Id__c);
            }
            distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                                    FROM ContentDistribution WHERE ContentDocumentId IN: slideIds];
        }else{
            slides = [SELECT Id, Name, cloudx_cms__Carousel__c, cloudx_cms__Image_URL__c 
                                                        FROM cloudx_cms__SS_Carousel_Slide__c LIMIT 1];
            distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                                    FROM ContentDistribution Order by CreatedDate desc limit 1000];
        }
        
       /*List<cloudx_cms__SS_Carousel_Slide__c> slides = [SELECT Id, Name, cloudx_cms__Carousel__c, cloudx_cms__Image_URL__c 
                                                        FROM cloudx_cms__SS_Carousel_Slide__c WHERE cloudx_cms__Carousel__c ='a1x1e000000ErRKAA0'];*/
        System.debug('slides: ' + slides);
        /*List<ContentDistribution> distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                              FROM ContentDistribution Order by CreatedDate desc limit 1000];
        List<String> slideIds = System.label.Slides_on_Lockated_App.split(',');
        List<ContentDistribution> distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                                FROM ContentDistribution WHERE ContentDocumentId IN: slideIds];*/
        System.debug('distList: ' + distList);
        Map<String, String> mapUrls = new Map<String, String>();
        Map<String, ContentDistribution> mapurlVsContDist = new Map<String, ContentDistribution>();
        for(ContentDistribution dist : distList){
            mapUrls.put(dist.ContentDownloadUrl, dist.DistributionPublicUrl);
            mapurlVsContDist.put(dist.ContentDownloadUrl, dist);
            System.debug('dist.ContentDownloadUrl: ' + dist.ContentDownloadUrl);
            System.debug('dist.DistributionPublicUrl: ' + dist.DistributionPublicUrl);
            System.debug('dist.ContentVersionId: ' + dist.ContentVersionId);
        }
        System.debug('mapUrls: ' + mapUrls);
        /*List<String> slidUrls = new List<String>();
        for(cloudx_cms__SS_Carousel_Slide__c slid : slides){
            slidUrls.add(mapUrls.get(slid.cloudx_cms__Image_URL__c));
        }*/
        ///////////////////////////////
        List<String> slidUrlsPng = new List<String>();
        for(cloudx_cms__SS_Carousel_Slide__c slid : slides){
            ContentDistribution disb = mapurlVsContDist.get(slid.cloudx_cms__Image_URL__c);
            System.debug('disb: ' + disb);
            String finalUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/sfc/dist/version/renditionDownload?rendition=THUMB720BY480&versionId=';
            finalUrl += disb.ContentVersionId + '&operationContext=DELIVERY&contentID=';
            finalUrl += disb.ContentDocumentId;
            String publicUrl = disb.DistributionPublicUrl;
            publicUrl = !String.isEmpty(publicUrl) ? publicUrl.split('/a') [publicUrl.split('/a').size() - 1] : '';
			finalUrl += '&page=0&d=/a' + publicUrl + '&oid=' + UserInfo.getOrganizationId();
            finalUrl += '&filename.png';
            slidUrlsPng.add(finalUrl);
        }
        
        //////////////////////////////
		return slidUrlsPng;
    }
}