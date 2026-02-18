@RestResource(urlMapping='/serviceRequests/*')
global class LockatedApp_ServiceRequests {
    
    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            if(String.isBlank(bkgId) || bkgId == 'serviceRequests'){
                errorResult.put('status', 'error');
                errorResult.put('message', 'Please pass valid Booking Id');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }else{
                List<Booking__c> bkgs = [SELECT Id, Opportunity__r.AccountId FROM Booking__c WHERE Id =: bkgId];
                if(bkgs.size() > 0){
                    String accId = bkgs[0].Opportunity__r.AccountId;
                    List<Case> cases = [SELECT Id,CaseNumber,Status,Subject,RW_Case_Type__c,Customer_Lifecycle_Touchpoint__c,RW_Complaint_Type__c,
                                        RW_Complaint_SubType__c,Description,CreatedDate FROM Case WHERE AccountId =: accId AND Status IN ('Open','Case Closed')]; 
                    List<String> caseIds = new List<String>();
                    for(Case cs : cases){
                        caseIds.add(cs.Id);
                    }
                    Map<String, List<Comment>> caseCommentsMap = getCaseComments(caseIds);
                    Map<String, Attachmnt> attMap = getCaseAttachments(caseIds);
                    ServiceRequests servReq = new ServiceRequests(); 
                    servReq.category = LockatedApp_PostSales.getPicklistValues('Case', 'Status');
                    List<Ticket> ticketList = new List<Ticket>();
                    for(Case cs : cases){
                        Ticket tkt = new Ticket();
                        tkt.CaseNumber = cs.CaseNumber;
                        tkt.Status = cs.Status;
                        tkt.Subject = cs.Subject;
                        tkt.caseType = cs.RW_Case_Type__c;
                        tkt.categoryType = cs.Customer_Lifecycle_Touchpoint__c;
                        tkt.categoryName = cs.RW_Complaint_Type__c;
                        tkt.sub_category = cs.RW_Complaint_SubType__c;
                        tkt.case_Description = cs.Description;
                        tkt.createdOn = String.valueOf(cs.CreatedDate);
                        tkt.feedback = '';
                        tkt.rating = '';
                        
                        tkt.attachment = attMap.get(cs.Id);
                        tkt.comments = caseCommentsMap.get(cs.Id);
                        ticketList.add(tkt);
                    }
                    servReq.tickets = ticketList;
                    //return servReq;
                    res.responseBody = Blob.valueOf(JSON.serialize(servReq));
                	res.statusCode = 200;
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Booking record not found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }
            }
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    @HttpPost
    global static void doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            String postType = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
            system.debug('req: ' + req.requestBody);
            String jsonBody = req.requestBody.toString();
            
            if(postType == 'case'){
                caseDetails det = (caseDetails) JSON.deserialize(jsonBody, caseDetails.class);
                if(det.booking_id != null){
                    List<Booking__c> bkg = [SELECT Opportunity__r.AccountId FROM Booking__c WHERE Id =: det.booking_id];
                    if(bkg.size() == 0){
                        errorResult.put('status', 'error');
                        errorResult.put('message', 'Booking record not found');
                        res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                        res.statusCode = 400;
                    }else{
                        Case cs = new Case();
                        cs.RW_Case_Type__c = det.caseType;
                        cs.Origin = 'Lockated App';
                        if(det.caseType == 'Complaint'){
                            cs.Customer_Lifecycle_Touchpoint__c = det.categorType;
                            cs.RW_Complaint_Type__c = det.categoryName;
                            cs.RW_Complaint_SubType__c = det.sub_category;
                        }
                        cs.Description = det.description;
                        //cs.AccountId = det.booking_id;
                        cs.AccountId = bkg[0].Opportunity__r.AccountId;
                        
                        
                        
                        insert cs;
                        //return 'Service Request submitted successfully ' + cs.Id;
                        if(det.attachment != null && det.attachment != ''){
                            Attachment attach = new Attachment();
                            attach.ParentId = cs.Id;
                            //attach.Name = postType + '.' + resData.fileType;
                            attach.Name = 'Service Request';
                            attach.Body = EncodingUtil.base64Decode(det.attachment);
                            attach.ContentType = 'application/pdf';
                            insert attach;
                            
                            Blob fileBody = EncodingUtil.base64Decode(det.attachment);
                            
                            ContentVersion contentVersion = new ContentVersion();
                            contentVersion.Title = 'Service Request';                     
                            contentVersion.PathOnClient = 'Service Request.pdf';     
                            contentVersion.VersionData = fileBody;                
                            insert contentVersion;
                            
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = [
                                SELECT ContentDocumentId 
                                FROM ContentVersion 
                                WHERE Id = :contentVersion.Id
                            ].ContentDocumentId;
                            
                            
                            cdl.LinkedEntityId = cs.Id; 
                            cdl.ShareType = 'V'; 
                            cdl.Visibility = 'AllUsers';
                            insert cdl;
                            
                        }
                       
                        res.responseBody = Blob.valueOf('Service Request submitted successfully');
                        res.statusCode = 200;
                    }
                }
            }else if(postType == 'caseComment'){
                CaseCommentPost det = (CaseCommentPost) JSON.deserialize(jsonBody, CaseCommentPost.class);
                String base64Data = det.attachment;  
                Blob fileBody = EncodingUtil.base64Decode(base64Data);
                
                FeedItem post = new FeedItem(
                    ParentId = det.case_id,
                    Body = det.description,
                    Type = 'ContentPost'
                );
                insert post;
                
                ContentVersion cv = new ContentVersion(
                    VersionData = fileBody,
                    PathOnClient = det.fileName + '.' + det.fileType,
                    Title = det.fileName
                );
                insert cv;
                
                //Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                
                
                
                FeedAttachment fa = new FeedAttachment(
                    FeedEntityId = post.Id,
                    RecordId = cv.Id,
                    Type = 'CONTENT'
                );
                insert fa;
                //return 'Service Request comment submitted successfully';
                res.responseBody = Blob.valueOf('Service Request comment submitted successfully');
                res.statusCode = 200;
            }
            
            //return null;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    /*public static Map<String, List<Comment>> getCaseComments(list<String> caseIds){

List<FeedComment> feedComments = [SELECT Id, FeedItemId, ParentId, CommentBody, CommentType, RelatedRecordId, Status, ThreadParentId, 
CreatedDate, CreatedBy.Name FROM FeedComment where ParentId =: caseIds AND CommentBody != null];
List<String> feedIds = new List<String>();
for(FeedComment feed : feedComments){
feedIds.add(feed.FeedItemId);
}
System.debug('feedIds: ' + feedIds);
Map<String, Attachmnt> attMap = getCaseAttachments(feedIds);
System.debug('attMap: ' + attMap);
Map<String, List<Comment>> caseCommentsMap = new Map<String, List<Comment>>();
for(FeedComment fc : feedComments){
Comment com = new Comment();
com.description = fc.CommentBody;
com.comment_by = fc.CreatedBy.Name;
com.comment_on = String.valueOf(fc.CreatedDate);
if(caseCommentsMap.get(fc.ParentId) != null){
caseCommentsMap.get(fc.ParentId).add(com);
}else{
caseCommentsMap.put(fc.ParentId, new List<Comment>{com});
}
com.attachment = attMap.get(fc.Id);
}
return caseCommentsMap;
}*/
    
    public static Map<String, List<Comment>> getCaseComments(list<String> caseIds){
        
        List<FeedItem> feedsList = [SELECT Id, Body, CreatedBy.Name, CreatedDate, ParentId FROM FeedItem WHERE ParentId =: caseIds];
        List<FeedItem> feeds = new List<FeedItem>();
        List<String> feedIds = new List<String>();
        for(FeedItem feed : feedsList){
            if(feed.Body != null){
                feedIds.add(feed.Id);
                feeds.add(feed);
            }
        }
        System.debug('feedIds: ' + feedIds);
        Map<String, Attachmnt> attMap = getCaseCommentAttachments(feedIds);
        System.debug('attMap: ' + attMap);
        Map<String, List<Comment>> caseCommentsMap = new Map<String, List<Comment>>();
        for(FeedItem item : feeds){
            Comment com = new Comment();
            com.description = item.Body;
            com.comment_by = item.CreatedBy.Name;
            com.comment_on = String.valueOf(item.CreatedDate);
            if(caseCommentsMap.get(item.ParentId) != null){
                caseCommentsMap.get(item.ParentId).add(com);
            }else{
                caseCommentsMap.put(item.ParentId, new List<Comment>{com});
            }
            com.attachment = attMap.get(item.Id);
        }
        return caseCommentsMap;
    }
    
    public static Map<String, Attachmnt> getCaseAttachments(list<String> caseIds){
        Map<String, Attachmnt> attMap = new Map<String, Attachmnt>();
        List<Attachment> atts = [SELECT Id, Name, ParentId, ContentType, Body FROM Attachment WHERE ParentId =: caseIds];
        Map<String, List<Attachment>> caseVsAttachments = new Map<String, List<Attachment>>();
        for(Attachment at : atts){
            if(caseVsAttachments.get(at.ParentId) != null){
                caseVsAttachments.get(at.ParentId).add(at);
            }else{
                caseVsAttachments.put(at.ParentId, new List<Attachment>{at});
            }
        }
        for(String csId : caseIds){
            if(caseVsAttachments.get(csId) != null){
                Attachmnt attch = new Attachmnt();
                attch.attchementType = atts[0].ContentType;
                attch.url = EncodingUtil.base64Encode(caseVsAttachments.get(csId)[0].Body);
                //attch.url = String.valueOf(atts[0].Body);
                attMap.put(csId, attch);
            }
        }
        
        /*List<ContentDocumentLink> cdlList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: caseIds];
        System.debug('cdlList: ' + cdlList);
        Set<Id> docIds = new Set<Id>();
        Map<String, String> docIdVsCaseId = new Map<String, String>();
        for (ContentDocumentLink cdl : cdlList) {
            docIds.add(cdl.ContentDocumentId);
            docIdVsCaseId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }
        List<ContentVersion> files = new List<ContentVersion>();
        Map<String, String> docIdVsDistribution = new Map<String, String>();
        Map<String, Attachmnt> attMap = new Map<String, Attachmnt>();
        if (!docIds.isEmpty()) {
            files = [SELECT Id, Title, FileExtension, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :docIds ];
            List<ContentDocument> docs = [SELECT Id, Title, FileType, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :docIds];
            List<ContentDistribution> dists = [SELECT Id, DistributionPublicUrl, Name, ContentDocumentId FROM ContentDistribution WHERE ContentDocumentId = : docIds];
            for(ContentDistribution dist : dists){
                docIdVsDistribution.put(dist.ContentDocumentId, dist.DistributionPublicUrl);
            }
            for(ContentDocument doc : docs){
                if(docIdVsDistribution.get(doc.Id) != null){
                    Attachmnt attch = new Attachmnt();
                    attch.attchementType = doc.FileType;
                    attch.url = docIdVsDistribution.get(doc.Id);
                    attMap.put(docIdVsCaseId.get(doc.Id), attch);
                }else{
                    ContentDistribution dist = new ContentDistribution();
                    dist.Name = doc.Title;
                    dist.ContentVersionId = doc.LatestPublishedVersionId;
                    dist.PreferencesAllowViewInBrowser = true;
                    dist.PreferencesAllowOriginalDownload = true;
                    insert dist;
                    ContentDistribution dt = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE Id =: dist.Id];
                    Attachmnt attch = new Attachmnt();
                    attch.attchementType = doc.FileType;
                    attch.url = dt.DistributionPublicUrl;
                    attMap.put(docIdVsCaseId.get(doc.Id), attch);
                }
            }
        }*/
        
        /*String baseUrl = URL.getOrgDomainURL().toExternalForm();
Map<String, List<String>> caseAttachmentsMap = new Map<String, List<String>>();

for (Attachment att : atts) {
Attachmnt attch = new Attachmnt();
attch.attchementType = att.ContentType;
attch.url = baseUrl + '/servlet/servlet.FileDownload?file=' + att.Id;
//attMap.put(att.ParentId, attch);
//caseAttachmentsMap.put(att.ParentId, new List<String>{att.ContentType, baseUrl + '/servlet/servlet.FileDownload?file=' + att.Id});
}
for (ContentVersion cv : files) {
Attachmnt attch = new Attachmnt();
attch.attchementType = cv.FileExtension;
attch.url = baseUrl + '/sfc/servlet.shepherd/version/download/' + cv.Id;
attMap.put(docIdVsCaseId.get(cv.ContentDocumentId), attch);
//caseAttachmentsMap.put(docIdVsCaseId.get(cv.ContentDocumentId), new List<String>{cv.FileExtension, baseUrl + '/sfc/servlet.shepherd/version/download/' + cv.Id});
}*/
        
        return attMap;
    }
    
    public static Map<String, Attachmnt> getCaseCommentAttachments(List<String> feedItemIds){
        
        /*List<FeedItem> feeds = [SELECT Id FROM FeedItem WHERE ParentId = '5009I00000Esw29QAB'];
Set<Id> feedItemIds = new Set<Id>();
for(FeedItem item : feeds){
feedItemIds.add(item.Id);
}*/
        List<FeedAttachment> feedAttchments = [SELECT Id,RecordId,Type,FeedEntityId  FROM FeedAttachment WHERE FeedEntityId =: feedItemIds];
        System.debug('feedAttchments: ' + feedAttchments);
        Set<Id> versionIds = new Set<Id>();
        Map<String, String> versionIdVsFeeItemId = new Map<String, String>();
        for(FeedAttachment att : feedAttchments){
            versionIds.add(att.RecordId); 
            versionIdVsFeeItemId.put(att.RecordId, att.FeedEntityId);
        }
        Map<String, Attachmnt> attMap = new Map<String, Attachmnt>();
        Map<Id,ContentVersion> versions = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId, FileType, Title FROM ContentVersion WHERE Id =: versionIds]);
        
        List<ContentDistribution> distList = [SELECT Id,DistributionPublicUrl,ContentVersionId FROM ContentDistribution WHERE ContentVersionId =: versionIds];
        Map<String, String> versionIdVsDistribution = new Map<String, String>();
        Map<String, ContentVersion> distributionIdVsVersion = new Map<String, ContentVersion>();
        for(ContentDistribution dis : distList){
            versionIdVsDistribution.put(dis.ContentVersionId, dis.DistributionPublicUrl);
        }
        List<ContentDistribution> distToInsert = new List<ContentDistribution>();
        for(ContentVersion ver : versions.values()){
            if(versionIdVsDistribution.get(ver.Id) != null){
                Attachmnt attch = new Attachmnt();
                attch.attchementType = ver.FileType;
                attch.url = versionIdVsDistribution.get(ver.Id);
                attMap.put(versionIdVsFeeItemId.get(ver.Id), attch);
            }else{
                ContentDistribution dist = new ContentDistribution();
                dist.Name = ver.Title;
                dist.ContentVersionId = ver.Id;
                dist.PreferencesAllowViewInBrowser = true;
                dist.PreferencesAllowOriginalDownload = true;
                distToInsert.add(dist);
            }
        }
        
        insert distToInsert;
        System.debug('distToInsert: ' + distToInsert);
        for(ContentDistribution dis : [SELECT Id, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE Id =: distToInsert]){
            System.debug('dis.DistributionPublicUrl: ' + dis.DistributionPublicUrl);
            System.debug('dis.Id: ' + dis.Id);
            Attachmnt attch = new Attachmnt();
            attch.attchementType = versions.get(dis.ContentVersionId).FileType;
            attch.url = dis.DistributionPublicUrl;
            attMap.put(versionIdVsFeeItemId.get(dis.ContentVersionId), attch);
        }
        return attMap;
    }
    
    
    global class ServiceRequests{
        public List<String> category;
        public List<Ticket> tickets;
    }
    
    public class Ticket{
        public String CaseNumber;
        public String Status;
        public String Subject;
        public String caseType;
        public String categoryType;
        public String categoryName;
        public String sub_category;
        public String case_Description;
        public String createdOn;
        public String feedback;
        public String rating;
        public Attachmnt attachment;
        public List<Comment> comments;
    }
    
    public class Comment{
        public String description;
        public String comment_by;
        public String comment_on;
        public Attachmnt attachment;
    }
    
    public class Attachmnt{
        public String attchementType;
        public String url;
        
    }
    
    public class caseDetails{
        public String caseType;
        public String categorType;
        public String categoryName;
        public String sub_category;
        public String description;
        public String attachment;
        public String booking_id;
    }
    
    public class CaseCommentPost{
        public String description;
        public string attachment;
        public string case_id;
        public string fileType;
        public string fileName;
    }
}