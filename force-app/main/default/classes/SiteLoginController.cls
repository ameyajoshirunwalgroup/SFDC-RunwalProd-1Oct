/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global list<Attachment> lstAttachment {get; set;}
    global string strContent {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        return Site.login(username, password, startUrl);
    }
    global list<string> lstContent{get;set;}
    global SiteLoginController ()
    {
        list<KL_Whats_New__c> lstWhatsNew = [select id, RW_Active__c, (select id from attachments), RW_Contents__c from KL_Whats_New__c where RW_Active__c =: true limit 1];
        
        lstAttachment = new list<Attachment>();
        if(lstWhatsNew != null && lstWhatsNew.size() > 0)
        {
            if(lstWhatsNew[0].attachments != null && lstWhatsNew[0].attachments.size() > 0)
                lstAttachment.addAll(lstWhatsNew[0].attachments);
            
            if(lstWhatsNew[0].RW_Contents__c != null)
            {
                strContent = lstWhatsNew[0].RW_Contents__c;
	             lstContent= new list<string>();
	              
	             String firstSubString = lstWhatsNew[0].RW_Contents__c.substringBetween('<ol>', '</ol>');   
	             for(string str:firstSubString.split('</li>'))
	             {
	             	 
	             	lstContent.add(str.removeStart('<li>'));
	             }
            }
        }
    }
}