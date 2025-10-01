@RestResource(urlMapping='/AgreementDoc/*')
global without sharing class AgreementDocRest {
	
    @HttpGet
    global static String doGet(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String docId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        List<ContentDistribution> dist = new List<ContentDistribution>();
        ContentVersion file = new ContentVersion();
        if(String.isNotBlank(docId)){
            file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: docId];
        	dist = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                    WHERE ContentVersionId =: file.Id LIMIT 1];
        }
        if(dist.size() > 0){
            return dist[0].DistributionPublicUrl;
        }else{
            ContentDistribution newDist = new ContentDistribution(
                                   Name = file.Title,
                                   ContentVersionId = file.Id,
                                   PreferencesAllowViewInBrowser= true);
        	insert newDist;
            ContentDistribution distb = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id =: newDist.Id];
            return distb.DistributionPublicUrl;
        }
        
        
        //ContentDistribution dist = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution WHERE Id =: newDist.Id];
        
        //return dist.DistributionPublicUrl;
        
    }
}