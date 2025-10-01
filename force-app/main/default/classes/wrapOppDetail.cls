public class wrapOppDetail
{
    @AuraEnabled
    public string strOppName{get;set;}
    @AuraEnabled
    public string strProjName{get;set;}
    @AuraEnabled
    public string strUnitName{get;set;}
    @AuraEnabled
    public string strConstName{get;set;}
    @AuraEnabled
    public string strProjectId{get;set;}
    @AuraEnabled
    public list<WrapAttachments> lstAttachment{get;set;}
}