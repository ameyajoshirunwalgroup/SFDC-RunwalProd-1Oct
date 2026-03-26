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
    public ContentVersion latestIOMFile {get;set;}
    public Boolean iomUploaded {get;set;}
    
    
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
        bklist = [select id,name,Interest_Waiver_Approval_Status__c,(Select id,Name,Sent_for_Approval__c,Approval_Status__c,Sub_Reason__c,Waiver_Reason__c,Waiver_Amount__c,Remarks__c,Demand__c,Demand__r.Name,IOM_Uploaded__c from Interest_Waivers__r where Sent_for_Approval__c = true )  from Booking__c where id =: BkId];
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
        system.debug('bklist---->'+bklist);
        iomUploaded = false;

        for(Interest_Waiver__c iw : iwlist){
            system.debug('iwid---->'+iw.id  +  iw.IOM_Uploaded__c);
            if(iw.IOM_Uploaded__c){
                iomUploaded = true;
                break;
            }
        }

        if(iomUploaded){
            // Step 1: Get all files linked to Booking
            List<ContentDocumentLink> fileLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :BkId
            ];

            // Step 2: Store document ids
            Set<Id> docIds = new Set<Id>();

            for(ContentDocumentLink link : fileLinks){
                docIds.add(link.ContentDocumentId);
            }

            // Step 3: Fetch latest IOM file
            if(!docIds.isEmpty()){

                List<ContentVersion> iomFiles = [
                    SELECT Id, Title, FileExtension, ContentDocumentId
                    FROM ContentVersion
                    WHERE ContentDocumentId IN :docIds
                    ORDER BY CreatedDate DESC
                    
                ];

                for(ContentVersion cv : iomFiles){

                    String fileName = cv.Title != null ? cv.Title.toLowerCase() : '';
                    String normalized = fileName.replaceAll('[^a-z]', '');

                    // ✅ FIX: Check BOTH IWR + IOM
                    if(normalized.contains('iwr')){
                        latestIOMFile = cv;
                        break; // latest valid file
                    }
                }
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

    public String getIomFileUrl(){

        if(latestIOMFile == null){
            return '';
        }

        String baseUrl = URL.getOrgDomainUrl().toExternalForm();

        return baseUrl + '/lightning/r/ContentDocument/' +
           latestIOMFile.ContentDocumentId + '/view';
    }
}