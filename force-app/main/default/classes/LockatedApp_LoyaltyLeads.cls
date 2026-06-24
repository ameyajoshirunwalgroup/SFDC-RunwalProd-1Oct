@RestResource(urlMapping='/loyalty/*')
global without sharing class LockatedApp_LoyaltyLeads {
    
    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(String.isBlank(bkgId) || bkgId == 'referrals'){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid Booking Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                List<Booking__c> bkg = [SELECT Id, Opportunity__r.Account.Mobile_No__c FROM Booking__c WHERE Id =: bkgId];
                if(bkg.size() > 0){
                    LoyaltyLeads det = new LoyaltyLeads();
                    List<Lead> loyaltyLeads = [SELECT Id, RW_Mobile_No__c,RW_Project__r.Name,RW_Location__c,CreatedDate,RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c FROM Lead WHERE IsConverted = false AND RW_Mobile_No__c =: bkg[0].Opportunity__r.Account.Mobile_No__c];
                    List<String> projImageIds = new List<String>();
                    for(Lead ld : loyaltyLeads){
                        if(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c != null)
                        	projImageIds.add(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c); 
                    }
                    System.debug('projImageIds: ' + projImageIds);
                    Map<String, String> projImageLink = new Map<String, String>();
                    if(projImageIds.size() > 0){
                        List<ContentDistribution> distrList = [SELECT Id,Name,DistributionPublicUrl,ContentDocumentId,ContentVersion.Title,ContentVersion.FileExtension FROM ContentDistribution 
                                                               WHERE ContentDocumentId =: projImageIds];
                        System.debug('distrList: ' + distrList);
                        for(ContentDistribution dist : distrList){
                            //projImageLink.put(dist.ContentDocumentId, dist.DistributionPublicUrl);
                            
							String furl = dist.DistributionPublicUrl.replace('sfc/p/', 'sfc/p/#');
                            furl += '/' + dist.ContentVersion.Title + '.' + ContentVersion.FileExtension;
                            projImageLink.put(dist.ContentDocumentId, furl);
                        }
                    }
                    System.debug('projImageLink: ' + projImageLink);
                    List<Loyalty> loyaltyList = new List<Loyalty>();
                    for(Lead ld : loyaltyLeads){
                        Loyalty loy = new Loyalty();
                        loy.projectName = ld.RW_Project__r.Name;
                        loy.location = ld.RW_Location__c;
                        loy.enquiredOn = String.valueOf(ld.CreatedDate);
                        //loy.imageUrl = projImageLink.get(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c);
                        if(projImageLink.get(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c) != null){
                            loy.imageUrl = projImageLink.get(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c);
                            System.debug('loy.imageUrl: ' + loy.imageUrl);
                        }else{
                            loy.imageUrl = imagePublicUrl(ld.RW_Project__r.WhatsApp_Bot_Project_Image_File_Id__c);
                            System.debug('loy.imageUrl: ' + loy.imageUrl);
                        }
                        System.debug('loy.imageUrl: ' + loy.imageUrl);
                        loyaltyList.add(loy);
                    }
                    det.myEnquiries = loyaltyList;
                    //return null;
                    res.responseBody = Blob.valueOf(JSON.serialize(det));
                    res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Booking record not found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
                
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
            
        }    
        
    }
    
    public static String imagePublicUrl(String docId){
        if(docId != null){
            System.debug('docId: ' + docId);
            List<ContentVersion> file = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: docId];
            System.debug('file: ' + file);
            String furl;
            List<ContentDistribution> dist = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension FROM ContentDistribution 
                                              WHERE ContentVersionId =: file[0].Id LIMIT 1];
            if(dist.size() > 0){
                /*furl = dist[0].DistributionPublicUrl.replace('sfc/p/', 'sfc/p/#');
                furl += '/' + dist[0].ContentVersion.Title + '.' + dist[0].ContentVersion.FileExtension;
                return furl;*/
                return dist[0].DistributionPublicUrl;
            }else{
                ContentDistribution newDist = new ContentDistribution(
                    Name = file[0].Title,
                    ContentVersionId = file[0].Id,
                    PreferencesAllowViewInBrowser= true,
                    PreferencesNotifyOnVisit = false);
                insert newDist;
                ContentDistribution distb = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl,ContentVersion.Title,ContentVersion.FileExtension FROM ContentDistribution WHERE Id =: newDist.Id];
                /*furl = distb.DistributionPublicUrl.replace('sfc/p/', 'sfc/p/#');
                furl += '/' + distb.ContentVersion.Title + '.' + distb.ContentVersion.FileExtension;
                return furl;*/
                return distb.DistributionPublicUrl;
            }
        }else{
            return null;
        }
    }
    
    global class LoyaltyLeads{
        public List<Loyalty> myEnquiries;
    }
    
    public class Loyalty{
        public string projectName;
        public string location;
        public string enquiredOn;
        public string imageUrl;
    }
}