public class CustomerPortalEnquiryWrapper {
    @AuraEnabled
    public List<projects> projectNames{get;set;}
    
    //@AuraEnabled
    //public List<referralWrapper> referralRecords{get;set;}
    
    
    public CustomerPortalEnquiryWrapper()
    {

        //referralRecords = new List<referralWrapper>();
        projectNames = new List<projects>();
    }
    
 
	@AuraEnabled
    public String firstName{get;set;}
    
    @AuraEnabled
    public String lastName{get;set;}
    
    @AuraEnabled
    public String project{get;set;}
    
    @AuraEnabled
    public String emailId{get;set;}
    
    @AuraEnabled
    public String phone{get;set;}
    
    
    public class projects
    {
    @AuraEnabled
    public String projId{get;set;}
    
    @AuraEnabled
    public String projName{get;set;}

    }


}