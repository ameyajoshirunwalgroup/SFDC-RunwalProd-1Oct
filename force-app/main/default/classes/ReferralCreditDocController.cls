public with sharing class ReferralCreditDocController {
    
    public string RDHId {
        get; 
        set{
            RDHId = value;
            if(RDHId != null)
                getCreateDocList();
        }
    }//{get;set;}
        public List<ContentDistribution> cd {get;set;}
        Public List<Referral_Credits__c> rdhList {get;set;}
        public string ReletedDocLink {get;set;}
        public void getCreateDocList(){
        
        ReletedDocLink = Url.getOrgDomainUrl().toExternalForm()+'/'+RDHId;
        List<ContentVersion> conversion = new List<ContentVersion>();
        cd = new List<ContentDistribution>();
        List<ContentDocumentLink> CDLink = new List<ContentDocumentLink>();
        Set<id> rdlid = New Set<id>();
        Set<id> conid = New Set<id>();
        
        rdhList = [select id,name,Name_of_Existing_Customer__c,Existing_Customer_Flat_no__c,SAP_Document_No__c,Vendor_Code__c  from Referral_Credits__c where id =: RDHId];
        CDLink = [SELECT ContentDocumentid, LinkedEntityid FROM contentDocumentLink WHERE LinkedEntityid =:RDHId];
        
        for(contentDocumentLink cdl : CDLink){
            rdlid.add(cdl.ContentDocumentid);
        }
        System.debug('ContentDocumentLink :: '+CDLink);
        if(!CDLink.isEmpty()){
            conversion = [SELECT Id,title, versiondata, ContentDocumentId, FileType  FROM ContentVersion WHERE ContentDocumentId IN : rdlid];
            System.debug('Contentconversion :: '+conversion);
            for(ContentVersion cvl : conversion){
                conid.add(cvl.id);
            }
        }    
        if(!conversion.isEmpty()){
            ContentTriggerHandler.createPublicLinkForFile(conid);            
            cd = [SELECT ContentVersionId,ContentVersion.title,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN : conid];
            System.debug('CD :: '+cd);
            System.debug('CD size :: '+cd.size());
        }        
    }
}