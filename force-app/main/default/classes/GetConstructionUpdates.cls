@RestResource(urlMapping='/GetConstructionUpdates/*')
global without sharing class GetConstructionUpdates {
    
	@HttpGet
    global static ProjectUpdates constructionUpdates(){
        
        RestRequest req = RestContext.request;
        String bookingId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
			
        Booking__c bkg = [SELECT Id, Unit_No__c, Unit_No__r.TowerName__c, Project__c, Project__r.RW_Project_Location_Videos_Link__c, 
                          Project__r.RW_Project_Brochure_PublicUrl__c FROM Booking__c WHERE Id =: bookingId];
        
        ProjectUpdates projUpdate = new ProjectUpdates();
        projUpdate.brochureLink = bkg.Project__r.RW_Project_Brochure_PublicUrl__c;
        projUpdate.videoLink = bkg.Project__r.RW_Project_Location_Videos_Link__c;
        
        
        /*List<RW_Tower_Construction_Update__c> constUpdts = [SELECT Id, RW_Description__c, RW_Date__c, RW_Tower_Construction_Photo_ID__c 
                                                        FROM RW_Tower_Construction_Update__c 
                                                        WHERE RW_Tower__c =: bkg.Unit_No__r.TowerName__c 
                                                            //AND RW_Project__c =: bkg.Project__c 
                                                            ORDER BY RW_Date__c DESC LIMIT 16];*/
        List<RW_Tower_Construction_Update__c> constUpdts = [SELECT Id, RW_Description__c, RW_Date__c, RW_Tower_Construction_Photo_ID__c 
                                                            FROM RW_Tower_Construction_Update__c WHERE RW_Tower__c =: bkg.Unit_No__r.TowerName__c AND
                                                            RW_Tower_Construction_Photo_ID__c != null ORDER BY RW_Date__c DESC LIMIT 16];
        List<RW_Tower_Construction_Update__c> constUpdates = new List<RW_Tower_Construction_Update__c>();
        List<String> versionIds = new List<String>();
        for(RW_Tower_Construction_Update__c upd : constUpdts){
            if(upd.RW_Description__c != null){
                constUpdates.add(upd);
                versionIds.add(upd.RW_Tower_Construction_Photo_ID__c);
            }
        }
        
        List<ContentDistribution> conDistList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                              FROM ContentDistribution WHERE ContentVersionId =: versionIds];
        Map<String,ContentDistribution> mapVersionIdVsDist = new Map<String,ContentDistribution>();
        for(ContentDistribution cont : conDistList){
            mapVersionIdVsDist.put(cont.ContentVersionId, cont);
        }
                
        List<ConstDetails> listUpdates = new List<ConstDetails>();
        List<ContentDistribution> listDist = new List<ContentDistribution>();
        Map<Id,Id> mapConstIdVsImageId = new Map<Id,Id>();
        List<Id> verIdsToCreate = new List<Id>();
        List<Id> allVerIds = new List<Id>();
        for(RW_Tower_Construction_Update__c constr : constUpdates){
            if(mapVersionIdVsDist.get(constr.RW_Tower_Construction_Photo_ID__c) == null){
                verIdsToCreate.add(constr.RW_Tower_Construction_Photo_ID__c);
            }else{
                allVerIds.add(constr.RW_Tower_Construction_Photo_ID__c);
            }
           	
        }
        List<ContentVersion> files = [SELECT Id, Title FROM ContentVersion WHERE Id =: verIdsToCreate];
        for(ContentVersion file : files){
            String nm = file.Title;
            if(nm.length() > 100 ){
                nm = nm.substring(0, 100);
            }
            ContentDistribution newDist = new ContentDistribution(
                                   Name = nm,
                                   ContentVersionId = file.Id,
                                   PreferencesAllowViewInBrowser= true,
            					   PreferencesNotifyOnVisit = false);
            listDist.add(newDist);
        }
        
        insert listDist;
        for(ContentDistribution cont : listDist){
            allVerIds.add(cont.ContentVersionId);
        }
        
        List<ContentDistribution> distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                              FROM ContentDistribution WHERE ContentVersionId =: allVerIds];
        Map<Id,ContentDistribution> mapVerIdVsContDisb = new Map<Id,ContentDistribution>();
        for(ContentDistribution distb : distList){
            mapVerIdVsContDisb.put(distb.ContentVersionId, distb);
        }
            
        
        for(RW_Tower_Construction_Update__c constr : constUpdates){
            if(constr.RW_Tower_Construction_Photo_ID__c != null && mapVerIdVsContDisb.get(constr.RW_Tower_Construction_Photo_ID__c) != null){  // Added if condition to fix the null pointer error by Vinay 10-06-2025
                String finalUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/sfc/dist/version/renditionDownload?rendition=THUMB720BY480&versionId=';
                finalUrl += mapVerIdVsContDisb.get(constr.RW_Tower_Construction_Photo_ID__c).ContentVersionId + '&operationContext=DELIVERY&contentID=';
                finalUrl += mapVerIdVsContDisb.get(constr.RW_Tower_Construction_Photo_ID__c).ContentDocumentId;
                String publicUrl = mapVerIdVsContDisb.get(constr.RW_Tower_Construction_Photo_ID__c).DistributionPublicUrl;
                publicUrl = !String.isEmpty(publicUrl) ? publicUrl.split('/a/') [publicUrl.split('/a/').size() - 1] : '';
                finalUrl += '&page=0&d=/a/' + publicUrl + '&oid=' + UserInfo.getOrganizationId();
                finalUrl += '&filename.png';
                
                ConstDetails details = new ConstDetails();
                details.description = constr.RW_Description__c;
                details.constDate = constr.RW_Date__c;
                details.image = finalUrl;
                listUpdates.add(details);
            }
            
            
        }
        projUpdate.constructionDetails = listUpdates;
        return projUpdate;
    }
    
    global class ConstDetails{
        public String description;
        public String image;
        public Date constDate;
        
    }
    global class ProjectUpdates{
        public List<ConstDetails> constructionDetails;
        public String brochureLink;
        public String videoLink;
    }
}