public class CustomerPortalReferralWrapper{
    @AuraEnabled
    public List<projects> projectNames{get;set;}
    
    @AuraEnabled
    public List<referralWrapper> referralRecords{get;set;}
    
    
    public CustomerPortalReferralWrapper(){

        referralRecords = new List<referralWrapper>();
        projectNames = new List<projects>();
    }
    
    public class referralWrapper{
	@AuraEnabled
    public String firstName{get;set;}
    
    @AuraEnabled
    public String lastName{get;set;}
    
    @AuraEnabled
    public String project{get;set;}
    
    @AuraEnabled
    public String leadId{get;set;}
    
    @AuraEnabled
    public String leadStatus{get;set;}
    }
    
    public class projects{
    @AuraEnabled
    public String projId{get;set;}
    
    @AuraEnabled
    public String projName{get;set;}

    }
    
}