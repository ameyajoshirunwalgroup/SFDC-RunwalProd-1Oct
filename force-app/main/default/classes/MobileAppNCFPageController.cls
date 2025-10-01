public class MobileAppNCFPageController {
    
	public String accountId {get;set;}
    
    
    public void ncf(){
        accountId = apexpages.currentPage().getParameters().get('accId');
        
        
        /*pageReference pageRef = new Pagereference('/lightning/cmp/BillDeskTest');
        pageRef.setRedirect(true);
        return pageRef;*/
    }
}