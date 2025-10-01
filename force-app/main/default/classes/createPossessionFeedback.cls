public class createPossessionFeedback
{
    set<id> posstempset = new set<id>();
    List<Opportunity> opplist = new List<Opportunity>();
    Survey__c surobj1 = new Survey__c();
    public List<Survey__c> posssurlist{get;set;}
    public string possname{get;set;}
    public boolean isError{get;set;}
    
    public createPossessionFeedback()
    {
        isError = false;
    }
    
    public void create(Id oppid)
    {
        if(oppid != null)
        {
            system.debug('Inside Opportunity');
            opplist = [select id,name,RW_Project__c,RW_Project__r.Site_Visit_Survey_Template__c,RW_Project__r.Send_SV_Survey__c,Possession_Feedback_Link__c,
                       RW_Project__r.Possession_Template__r.Active__c,RW_Project__r.Possession_Template__r.id,RW_Possession_Done__c,StageName,  
                       AccountId,Account.Name,Account.PersonEmail,Account.PersonMobilePhone  from Opportunity where Id =: oppid];
            system.debug('Opportunity List in Survey Trigger:: '+opplist);
        }
        
        if(!oppList.isEmpty())
        {
            String PageLink = System.label.Site_Url_New + '/PossessionPage?sid=';                    ///Link for Production
            possname = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Possession Survey').getRecordTypeId();
            system.debug(+possname);
            posssurlist = [select Id,Name,Active__c,Submitted_On__c,Survey_Link__c,Survey_Template__c,RecordTypeId,IsSubmitted__c from Survey__c where Opportunity__c =: oppid AND RecordTypeId =: possname];
            system.debug(+posssurlist);
            
            if(oppList[0].RW_Project__c== null)
            {
                system.debug('First IF');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is No Project Present on This Opportunity.'));
                isError = true;
            }
            if(oppList[0].RW_Project__r.Possession_Template__c == null)
            {
                system.debug('Second IF');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Survey Template is Defined for This Project.'));    
                isError = true;
            }    
                    
            if(isError == false)
            {
                if(oppList[0].RW_Project__r.Possession_Template__c != null )
                {
                    if(posssurlist.isEmpty())
                    {
                        posstempset = new set<id>();
                        posstempset.add(oppList[0].RW_Project__r.Possession_Template__r.id);
                        system.debug('Possession TEMPLATE ID FOR QUESTIONS'+posstempset);
                        system.debug('After IF');
                            
                        surobj1 = new Survey__c();
                        surobj1.Active__c = oppList[0].RW_Project__r.Possession_Template__r.Active__c;
                        surobj1.Opportunity__c = oppList[0].id;
                        surobj1.Survey_Template__c = oppList[0].RW_Project__r.Possession_Template__r.id;
                        surobj1.Survey_Type__c = 'Possession';
                        surobj1.Survey_For_Activity__c = 'Possession';
                        surobj1.Account_Email_for_Opportunity__c = oppList[0].Account.PersonEmail;
                        surobj1.Account_Phone_for_Opportunity__c = oppList[0].Account.PersonMobilePhone;
                        surobj1.Account_Name_for_Opportunity__c = oppList[0].Account.Name;
                        surobj1.Mode__c = 'Both';
                        surobj1.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Possession Survey').getRecordTypeId();
                        insert surobj1;
                        surobj1.Survey_Link__c = PageLink + surobj1.id;
                        update surobj1;
                        oppList[0].Possession_Feedback_Link__c = surobj1.Survey_Link__c;
                        oppList[0].Portal_Possession_Survey_Link_Id__c = surobj1.id;
                        update oppList[0];
                    }
                }
            }
        }
        if(isError == false && surobj1 != null && !posstempset.isEmpty())
        {
            List<Survey_Questions_Template__c> questtemplist1 = ([select id,Name,Answer__c,Survey_Template__c,Question_Number__c,Question_Text__c,Answer_Yes_No__c,RecordTypeId,RecordType.Name from Survey_Questions_Template__c where Survey_Template__c =: posstempset order by Question_Number__c ASC]);
            system.debug('Questions in Template::'+questtemplist1);
            if(!questtemplist1.isEmpty())
            {
                for(Survey_Questions_Template__c q : questtemplist1)
                {
                    Survey_Questions__c quesobj1 = new Survey_Questions__c();
                    quesobj1.Survey__c = surobj1.id;
                    system.debug(+quesobj1.Survey__c);
                    quesobj1.Question_Number__c = q.Question_Number__c;
                    quesobj1.Question_Text__c = q.Question_Text__c;
                    quesobj1.Answer_Yes_No__c = q.Answer_Yes_No__c;
                    quesobj1.AnswerText__c = q.Answer__c;
                    
                    if(q.RecordType.Name == 'Free Text Questions')
                    {
                        system.debug('inside free text IF');
                        Id devRecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
                        quesobj1.RecordTypeId = devRecordTypeId;
                    }
                    else
                    {
                        system.debug('inside picklist');
                        Id devRecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Yes or No Questions').getRecordTypeId();
                        quesobj1.RecordTypeId = devRecordTypeId;
                    }
                    insert quesobj1;
                }
            }
        }
    }
}