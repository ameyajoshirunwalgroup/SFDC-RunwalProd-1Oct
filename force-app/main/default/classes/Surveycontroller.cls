public without sharing class Surveycontroller
{
    public set<String> typeQ {get;set;}
    public Map<String,List<Survey_Questions__c>> mapQuestion{get;set;}
    public List<Survey_Questions__c> squestions{get;set;} 
    public List<Survey__c> surveys{get;set;}
    public List<Survey_Expiry_Days__c>explist{get;set;}
    public Survey__c survey{get;set;}
    //public string oppid{get;set;}
    public string surid{get;set;}
    public Boolean isTrue{get;set;}
    public Boolean isDone{get;set;}
    public Boolean isExpired{get;set;}
    public boolean isDisplay{get;set;}
    public boolean show {get;set;}
    //public List< Opportunity> lstopty{get;set;}
    //public Integer rating{get;set;}
    //public List<SelectOption> options {get;set;}

    public Surveycontroller()
    {        
        //oppid = ApexPages.currentPage().getParameters().get('oId');
        //system.debug('OBJID***'+oppid);
        surid = ApexPages.currentPage().getParameters().get('sid');
        system.debug('SURID***'+surid);
        //survey = [select id,Project__c from Survey__c where id =: surid]; //Commented by Vinay 28-01-2025
        List<Survey__c> survList = [select id,Project__c from Survey__c where id =: surid]; //Added by Vinay 28-01-2025
        if(survList.size() > 0){ //Added by Vinay 28-01-2025
            survey = survList[0];
        }
        mapQuestion = new Map<String,List<Survey_Questions__c>>();
        typeQ = new set<String>();
        isTrue = false;
        isExpired = false;
        isDone = false;
        isDisplay = false;
        show = true;
        squestions = new List<Survey_Questions__c>();
        if(surid == null)
        {
            isTrue = True;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Link is Malformed. Please Try clicking the link again!'));
        }
        
        explist = [select id,name,Expiry_Days__c from Survey_Expiry_Days__c];
        List<Survey__c> surveylist = ([select Name,Project__c,IsSubmitted__c,Opportunity__c,Survey_Template__c,Survey_Template__r.Name,Ageing__c,Survey_For_Activity__c,RecordType.Name 
                                      from Survey__c where (id =: surid AND Survey_Template__r.Name = 'Site Visit Survey Template')]);
                                      
        //lstopty=[Select id,Name,Latest_SV_Survey_Link__c from Opportunity where id =: surveylist[0].Opportunity__c];                              
        for(Survey_Expiry_Days__c s : explist)
        {
            system.debug('EXPDAYS::'+s.Expiry_Days__c);
            for(Survey__c c : surveylist)
            {
                system.debug('AGEING::'+c.Ageing__c);
                if(c.Ageing__c > s.Expiry_Days__c)
                {
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Link is Expired!'));
                    isExpired = True;
                }
            }
        }
        if(!surveylist.isEmpty())
        {
            for(Survey__c c : surveylist)
            {
                system.debug('AGEING::'+c.Ageing__c);
                if(c.IsSubmitted__c == True)
                {
                    if(isExpired == True)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Link is Expired!'));
                    }
                    else
                    {
                        isTrue = True;
                        if(c.Survey_For_Activity__c == 'Booking')
                        {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Looks like you have already submitted this survey.'));
                        }
                        else
                        {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Looks like you have already submitted this survey. For more information please visit www.runwalgroup.in'));                             
                        }  
                    }           
                }
                else if(isExpired == True)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Link is Expired!'));
                }
                else
                {
                    system.debug('Inside else');
                    isDisplay = true;
                        
                    squestions = [select id,Name,Question_Number__c,Question_Text__c,Answer_Picklist__c,Survey__c,AnswerText__c,RecordType.Name,Survey__r.Survey_For_Activity__c,     
                                  Question_Text_Number__c, Type_of_Question__c from Survey_Questions__c where Survey__c =: surid  order by Question_Number__c ASC];
                    //system.debug(+squestions.Question_Text_Number__c);
                    for(Survey_Questions__c sq : squestions)
                    {
                        system.debug(+sq.Question_Text_Number__c);
                        typeQ.add(sq.Type_of_Question__c);
                        if(mapQuestion.containsKey(sq.Type_of_Question__c)) mapQuestion.get(sq.Type_of_Question__c).add(sq);
                        else
                        {
                            List<Survey_Questions__c> newList = new List<Survey_Questions__c>();
                            newList.add(sq);
                            mapQuestion.put(sq.Type_of_Question__c,newList);
                        }   
                    }
                    
                    system.debug('Type Of Question::: '+typeQ);
                    system.debug('Mapping with Type of Question: '+mapQuestion);
                    system.debug('squestions:: '+squestions);                                      
                 }
            }    
        } else if(surveylist.isEmpty()){
                 show = false;
                 system.debug('inside error msg'); 
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Site Visit Survey Should Be Created!'));
        }  
    }
    
    public void save()
    {
        List<Survey__c> surveys = ([select Name,Project__c,IsSubmitted__c from Survey__c where id =: surid]);
        if(!surveys.isEmpty())
        {
            system.debug('surveys size:: '+surveys.size());
            for(Survey__c s : surveys)
            {
                s.IsSubmitted__c  = True;
                s.Active__c = false;
                s.Submitted_On__c = system.now();
                update surveys;
            }
        }
        if(!squestions.isEmpty())
        {
            try
            {
                update squestions;
                for(Survey_Questions__c c : squestions)
                {
                    isDisplay = false;
                    if(c.Survey__r.Survey_For_Activity__c == 'Booking')
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'We want to thank you for sharing your feedback with us.Your feedback is extremely valuable to us and once again extend our gratitude for your continued support and cooperation.'));
                    }
                    else
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Thank you for your feedback, for more information please visit www.runwalgroup.in'));
                    }
                }
            }  
            catch(Exception e)
            {
                isDisplay = false;
                system.debug(+e.getMessage());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error in Survey Submission'));
            }   
            isDone = True;
       } 
    } 
}