public class CallTranscriptController {
    
    public string transcript {get;set;}
    
    public CallTranscriptController(){
        string ucId = ApexPages.currentPage().getParameters().get('id');
        string transcriptNum = ApexPages.currentPage().getParameters().get('num');
        Call_Summary__c cs = [SELECT Id, Transcript_1__c, Transcript_2__c, Summary__c FROM Call_Summary__c WHERE UC_Id__c =: ucId LIMIT 1];
        if(transcriptNum == 'zero'){
            transcript = cs.Transcript_1__c;
        }else if(transcriptNum == 'one'){
            transcript = cs.Transcript_2__c;
        }else if(transcriptNum == 'sum'){
            transcript = cs.Summary__c;
        }
        
    }

}