public class CPProfileUpdateApprovalEmailController {
	public String cpId{get;set;}
    public List<Broker__c> cpList {get;set;}
    public List<CP_Profile_Update__c> cpprofileupdate {get;set;}
    public String Recordurl{get;set;}
    public String recipientId{get;set;}
    public String approvername{get;set;}
    public String ApprovalLink{get;set;}
    public CPProfileUpdateApprovalEmailController(){
        //cpId = apexpages.currentpage().getparameters().get('cpId');
    }
    public void getbooking(){
        
        Recordurl = 'https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/Broker__c/'+cpId+'/view';
        ApprovalLink = generateApprovalURL(cpId);
        recipientId = generateApproverId(cpId);
        approvername = [Select Id,name from user where Id =: recipientId].Name;
        //offerdetailmethod();
        
    }
    public static String generateApprovalURL(String recordID){
        String url='';
        List<ProcessInstanceWorkitem> workItemLst = [SELECT id,ActorId,OriginalActorId FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recordID];
        if(workItemLst.size() > 0){
            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() + '/lightning/r/ProcessInstanceWorkitem/' + workItemLst[0].id+'/view';
            
        }
        return url;
    }
    public static String generateApproverId(String recordID){
        String recipientname='';
        List<ProcessInstanceWorkitem> workItemLst = [SELECT id,ActorId,OriginalActorId FROM ProcessInstanceWorkitem WHERE processInstance.TargetObjectId=:recordID];
        if(workItemLst.size() > 0){
            recipientname = workItemLst[0].ActorId;
        }
        return recipientname;
    }
    public void getcpupdate(){
        system.debug('cpId::'+cpId); 
        cpList = [Select Id,Name from Broker__c where Id=:cpId];
        cpprofileupdate = [Select Id,Name,Old_GST_No__c,New_GST_No__c,Old_CP_Name__c,New_CP_Name__c,Channel_Partner__c,Old_RERA_No__c,New_RERA_No__c from CP_Profile_Update__c
                          where Channel_Partner__c =:cpId ];
    }
}