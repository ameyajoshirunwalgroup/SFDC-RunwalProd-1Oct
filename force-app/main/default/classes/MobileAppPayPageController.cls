public class MobileAppPayPageController{
    
    public String bookingId {get;set;}
    public String OpportunityId {get;set;}
    public String towerId {get;set;}
    public String Amount {get;set;}
    public String ProjectUnit {get;set;}
    public String TypeOfAmount {get;set;}
    public String msg {get;set;}
    
    
    
    public void pay(){
        System.debug('msg: ' + apexpages.currentPage().getParameters().get('msg'));
        msg = apexpages.currentPage().getParameters().get('msg');
        bookingId = apexpages.currentPage().getParameters().get('bkgId');
        System.debug('bookingId: ' + bookingId);
        OpportunityId = System.currentPagereference().getParameters().get('oppId');
        towerId = System.currentPagereference().getParameters().get('twrId');
        Amount = System.currentPagereference().getParameters().get('amount');
        ProjectUnit = System.currentPagereference().getParameters().get('unit');
        System.debug('towerId: ' + towerId);
        System.debug('msg: ' + msg);
        
        
        /*pageReference pageRef = new Pagereference('/lightning/cmp/BillDeskTest');
        pageRef.setRedirect(true);
        return pageRef;*/
    }
    
}