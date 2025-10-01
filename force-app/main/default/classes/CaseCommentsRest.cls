@RestResource(urlMapping='/caseComments/*')
global without sharing class CaseCommentsRest {
    
    @HttpGet
    global static feedItemWithComments doGet(){
        List<Comments> comms = new List<Comments>();
        feedItemWithComments fedWithComms = new feedItemWithComments();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String caseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<FeedItem> allFeeds = [SELECT Id, ParentId, Type, Title, Body, Visibility, Status, IsClosed, HasLink, RelatedRecordId, CreatedDate, 
                                CreatedBy.Name FROM FeedItem WHERE ParentId =: caseId];
        List<FeedItem> feeds = new List<FeedItem>();
        for(FeedItem fd : allFeeds){
            if(fd.Body != null){
                feeds.add(fd);
            }
        }
        List<FeedComment> feedComments = [SELECT Id, FeedItemId, ParentId, CommentBody, CommentType, RelatedRecordId, Status, ThreadParentId, 
                                          CreatedDate, CreatedBy.Name FROM FeedComment where ParentId =: caseId AND CommentBody != null];
        Map<String, List<FeedComment>> mapFeedVsComms = new Map<String, List<FeedComment>>();
        for(FeedItem fd : feeds){
            Comments com = new Comments();
            List<FeedComment> fcs = new List<FeedComment>();
            for(FeedComment fc : feedComments){
                if(fc.FeedItemId == fd.Id){
                    fcs.add(fc);
                }
            }
            com.feed = fd;
            com.feedRelatedComms = fcs;
            comms.add(com);
            mapFeedVsComms.put(fd.Id, fcs);
        }
        System.debug('mapFeedVsComms: ' + mapFeedVsComms);
        fedWithComms.feedWithComms = comms;
        return fedWithComms;
    }
    
    global class Comments{
        FeedItem feed;
        List<FeedComment> feedRelatedComms;
    }
    
    global class feedItemWithComments{
        List<Comments> feedWithComms;
    }
    
    @HttpPost
    global static void doPost(String caseId, String comment){
        FeedItem feed = new FeedItem();
        feed.ParentId = caseId;
        feed.Body = comment;
        insert feed;
    }

}