@RestResource(urlMapping='/faqs/*')
global class LockatedApp_FAQs {

    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        try{
            List<RW_FAQ__c> faqs = [SELECT Id, CreatedDate,RW_Question__c,RW_Answer__c,RW_Active__c,RW_Order__c,Language__c FROM RW_FAQ__c WHERE RW_Active__c = true AND Language__c != null ORDER BY RW_Order__c ASC];
            Map<String, List<FAQ>> faqMap = new Map<String, List<FAQ>>();
            System.debug('--:' + faqs[0]);
            for(RW_FAQ__c faq : faqs){
                FAQ f = new FAQ();
                f.question = faq.RW_Question__c;
                f.answer = faq.RW_Answer__c;
                if(faqMap.get(faq.Language__c) != null){
                    faqMap.get(faq.Language__c).add(f);
                }else{
                    faqMap.put(faq.Language__c, new List<FAQ>{f});
                }
            }
            res.responseBody = Blob.valueOf(JSON.serialize(faqMap));
            res.statusCode = 200;
        }catch(exception e){
            errorResult.put('status', 'error');
            errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }
        
    }
    
    public class FAQS{
        public List<FAQ> englis_faqs;
        public List<FAQ> hindi_faqs;
        public List<FAQ> marathi_faqs;
    }
    public class FAQ{
        public String question;
        public String answer;
    }
}