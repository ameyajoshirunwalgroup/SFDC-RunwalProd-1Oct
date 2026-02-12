public class InterestWaiverApprovalTemplateController {
    public string BkId {
        get; 
        set{
            BkId = value;
            if(BkId != null)
                getCreateWaiverList();
        }
    }
    Public List<Booking__c> bklist {get;set;}
    Public List<Interest_Waiver__c> iwlist {get;set;}
    public String currentApproverName { get; set; }
    public String approverComments {get; set;}
    public Boolean showPendingApprSec {get; set;}
    public Boolean showApprovedSec {get; set;}
    public Boolean showRejectedSec {get; set;}
    
    
    public void getCreateWaiverList(){
        list<ProcessInstanceStep> approvalStep = [SELECT Actor.Name,Comments,StepStatus
                                                  FROM ProcessInstanceStep 
                                                  WHERE ProcessInstance.TargetObjectId =: BkId  order by CreatedDate desc limit 1];
        list<ProcessInstanceWorkitem> currentApprovalStep = [SELECT Actor.Name
                                                             FROM ProcessInstanceWorkitem
                                                             WHERE ProcessInstance.TargetObjectId = :BkId limit 1];
        if(!approvalStep.isEmpty()){
            currentApproverName = currentApprovalStep[0].Actor.Name;
        }
        if(!approvalStep.isEmpty()){
            approverComments = approvalStep[0].Comments;
        }                                                                                                                                                                                                                                                                                                                 
        showPendingApprSec = true;
        bklist = [select id,name,Interest_Waiver_Approval_Status__c,(Select id,Name,Sent_for_Approval__c,Approval_Status__c,Sub_Reason__c,Waiver_Reason__c,Waiver_Amount__c,Remarks__c,Demand__c,Demand__r.Name from Interest_Waivers__r where Sent_for_Approval__c = true )  from Booking__c where id =: BkId];
        if(!bklist.isEmpty()){
            iwlist = bklist[0].Interest_Waivers__r;
            if(bklist[0].Interest_Waiver_Approval_Status__c == 'Approved' ){                                                                                                                                                                                                                                                         
                   showApprovedSec = true;
                   showRejectedSec = false;
                   showPendingApprSec = false;
               } else if(bklist[0].Interest_Waiver_Approval_Status__c == 'Rejected' ){
                             showApprovedSec = false;
                             showRejectedSec = true;
                             showPendingApprSec = false;
                         }else{
                             showPendingApprSec = true;
                             showApprovedSec = false;
                             showRejectedSec = false;
                         }
        }
        
    }
    
    //Added by Dolly
    public String getBookingLink() {
        if(BkId == null) return '';
		String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        return baseUrl + '/' + BkId;
    }
    
    //Map to store Sub Reason Picklist (API → Label)
    private Map<String,String> subReasonPicklistMap;
    
    //Getter used by Visualforce
    public Map<String,String> getSubReasonPicklistMap() {
    
        if(subReasonPicklistMap == null){
    
            subReasonPicklistMap = new Map<String,String>();
    
            Schema.DescribeFieldResult fieldDesc =
                Interest_Waiver__c.Sub_Reason__c.getDescribe();
    
            for(Schema.PicklistEntry entry : fieldDesc.getPicklistValues()){
                subReasonPicklistMap.put(entry.getValue(), entry.getLabel());
            }
        }
    
        return subReasonPicklistMap;
    }


}