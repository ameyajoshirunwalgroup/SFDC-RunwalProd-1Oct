@isTest
public class TestContentManagerService {
    @isTest
    public static void TestMethod1(){
        String getContentDetailsObj = ContentManagerService.getContentDetails('a1mJ4000000LFoKIAW');
    }
    
    @isTest
    public static void TestMethod4(){
        try{
        ContentManagerService.invoicestatus('Invoice Uploaded','a1mJ4000000LFoKIAW');
        }catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void TestMethod5(){
        try{
        ContentManagerService.updateBrokerageInvoiceStatus('Invoice Uploaded','a1mJ4000000LFoKIAW');
        }catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void TestMethod6(){
        try{
        ContentManagerService.updateCPBrokerageStatus('Invoice Uploaded','a1mJ4000000LFoKIAW');
        }catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void TestMethod7(){
        try{
        String result = ContentManagerService.getExperienceURL();
        }catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void TestMethod2(){/////////////////////////////User for ContentType Method in ContentManagerService /////////////////////////
        
        List<String> fileType = new String[]{'docx','csv','wav','wmv','mp3','mp4','png','pdf','image/jpeg'}; 
            Test.startTest(); 
        for(String str :fileType)
        {
            
            ContentManagerService.ContentType(str); 
            
            
        }
        ContentManagerService.getLoginURL();
        //ContentManagerService.getExperienceURL();
        test.stopTest();
    } 
    
    
    
}