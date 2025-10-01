public without sharing class Possessioncontroller 
{
    set<id> posstempset = new set<id>();   
    public List<Survey_Questions__c> pquestions{get;set;}
    public List<Survey__c> posssurlist{get;set;}
    public Survey__c survey{get;set;}
    public string surid{get;set;}
    public boolean isDisplay{get;set;}
    public boolean isExpired{get;set;}
    public boolean isDone{get;set;}
    public boolean isTrue{get;set;}
    public boolean isError{get;set;}
    public boolean show{get;set;}
    
    public Possessioncontroller()
    {
        isTrue = false;
        isExpired = false;
        isDone = false;
        isDisplay = false;
        isError = false;
        show = true;
        surid = ApexPages.currentPage().getParameters().get('sid');
        system.debug('SURID***'+surid);
        survey = [select id,Project__c from Survey__c where id =: surid];
        pquestions = new List<Survey_Questions__c>();
        if(surid == null)
        {
            isTrue = True;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Link is Malformed. Please Try clicking the link again!'));
        }
        
        List<Survey__c> surveylist = ([select Name,Project__c,IsSubmitted__c,Opportunity__c,Ageing__c,Survey_For_Activity__c,RecordType.Name,Survey_Template__c,Survey_Template__r.Name
                                      from Survey__c where( id =: surid AND Survey_Template__r.Name='Possession Template')]);
        
        if(!surveylist.isEmpty())
        {
            for(Survey__c c : surveylist)
            {
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
                    
                    pquestions =[select Id,Name,Question_Number__c,Question_Text__c,Answer_Yes_No__c,Survey__c,AnswerText__c,
                            RecordType.Name,Survey__r.Survey_For_Activity__c,Reason_For_Low_Rating__c,Financial_Capability__c,
                            Expected_Timeline__c,Buying_Behaviour__c,Liking_or_inclination_for_property__c,Competition_Considering__c,
                            Competition_Considering_If_Other__c,Our_standing_among_competition__c,How_much_time_spent_in_site__c,
                            With_whom_did_prospect_visit_the_site__c,Customer_Relatives_If_other__c,
                            whom_does_prospect_want_to_show_the_site__c,Decision_Maker__c,Work_Location__c,Office_Location__c,
                            Occupation__c,Visit_Individual__c,Visit_Spouse__c,Visit_Parents__c,Visit_Children__c,
                            Visit_Relative__c,Visit_Others__c,Show_Individual__c,Show_Spouse__c,Show_Parents__c,
                            Show_Children__c,Show_Relative__c,Show_Others__c,Customer_Relatives2_If_other__c,Decision_Maker_Individual__c,
                            Decision_Maker_Spouse__c,Decision_Maker_Parents__c,Decision_Maker_Children__c,Decision_Maker_Relative__c,
                            Decision_Maker_Others__c,Customer_Relatives3_If_other__c,Commercial_Negotiation__c,Inventory_Shortlisting__c,
                            Decision_Maker_Engagement__c,Total_A__c,Total_B__c,Total_Score__c 
                            from Survey_Questions__c where Survey__c =: surid  order by Question_Number__c ASC];
                            
                            system.debug(+pquestions);
                }
            }
        } else
            {
              show = false;
              system.debug('inside error msg');
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Possession Survey Should Be Created!'));              
          }
    }
    
    public void save()
    {
        posssurlist = [select Id,Name,Active__c,Submitted_On__c,Survey_Link__c,Survey_Template__c,RecordTypeId,IsSubmitted__c from Survey__c where Id =: surid];
        
        if(!posssurlist.isEmpty() && posssurlist.size() == 1)
        {
            posssurlist[0].IsSubmitted__c = true;
            posssurlist[0].Active__c = false;
            posssurlist[0].Submitted_On__c = system.now();
            update posssurlist[0];
        }
        
        if(!pquestions.isEmpty())
        {
            try
            {
                update pquestions;
               
                for(Survey_Questions__c c : pquestions)
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
            }catch(Exception e)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error in Survey Submission'));
            }   
            isDone = True;
       }        
    }
}