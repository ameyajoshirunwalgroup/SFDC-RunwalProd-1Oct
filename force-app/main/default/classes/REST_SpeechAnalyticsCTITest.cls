@isTest
public class REST_SpeechAnalyticsCTITest {
    
    @isTest
    public static void ctiTest(){
        
        Task tsk = new Task();
        tsk.Subject = 'Test';
        tsk.CallObject = '123455';
        tsk.ActivityDate = Date.Today();
        insert tsk;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'https://runwal--ctisb.sandbox.my.salesforce-sites.com/Callback1/services/apexrest/Integration/SpeechAnalytics'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        String JSONMsg = '{"meta": {"ucid": "123455","call_date":"'+Date.Today()+'","call_time": "11:25:56","username": "runwal","user_id": "0","file_id": "DIAca4275a861e3958b2f35c4293bf71fdf","audio_url": "","call_duration": 288.9,"agent": "Kirti Chawla","skill": "-","disposition": "Wrap up time exceeded :120","language": "hi-IN","campaign": "Online_Offline_MyCity_CRM","call_type": "Manual"},"transcription": {"0": {"transcript": "Test Transcript 0"},"1": {"transcript": "Test Transcript 1"}},"summary_report": {"summary_info": {"summary": "Test Summary","sentiment": "neutral","topic": ["Registration","Receipt","GST","Unit Upgrade","Relationship Manager Response"]}}}';
        req.requestBody = Blob.valueof(JSONMsg);
        RestContext.request = req;
        RestContext.response = res;
        
        REST_SpeechAnalyticsCTI.updateCallSummary();
        
        PageReference pRef = Page.CallTranscript;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id', '123455');
        ApexPages.currentPage().getParameters().put('num', 'one');
        ApexPages.currentPage().getParameters().put('num', 'sum');
        CallTranscriptController c = new CallTranscriptController();
    }

}