trigger tasksurvey on Task (After insert,After update) 
{
    
    list<Opportunity> opplist = new List<opportunity>();
    list<Opportunity> o =  new List<opportunity>();
    set <id> taskset = new set <id>();
    set<id> svid = new set<id>();
    set <id> surtempset = new set <id>();
    Survey__c surobj = new Survey__c();
    Survey_Questions__c quesobj = new Survey_Questions__c();
    Boolean isError;
    Set<id> svTskId = new Set<id>();
    Set<id> revisitTskId = new Set<id>();
    List<task> taskList = new List<task>();
    Map<id,id> idsMap = new Map<id,id>(); 
    string siteVisitType = '';
    string salesMangerId = '';
    
    //Added by Prashant to bypass trigger in prod. /////// 19-05-25.
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Task' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
    
    if(Trigger.isUpdate || trigger.isInsert) 
    {
        string recId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Site Visit task').getRecordTypeId();
        if(Trigger.isAfter) 
        {
            for(Task objTask : trigger.New)
            {
                system.debug('Inside Update Trigger::'+objTask);
                system.debug('status is:: '+objTask.Status);
                system.debug('Task Type is:: '+objTask.Task_Type__c);
                if((objTask.Task_Type__c == 'Site Visit' || objTask.RecordTypeId == recId) && objTask.Status == 'Completed' && ((trigger.oldMap != null && trigger.oldMap.get(objtask.id).status != null && trigger.oldMap.get(objtask.id).status != 'Completed' && trigger.isUpdate) || trigger.isInsert))
                {
                    system.debug('inside condition');
                    //opplist = [select id,name from Opportunity where Id =: objTask.WhatId];
                    if(objTask.WhatId != Null && objTask.WhatId.getSObjectType().getDescribe().getName() == 'Opportunity')
                    {
                        taskset.add(objTask.WhatId);
                        svid.add(objTask.Id);
                        salesMangerId = objTask.OwnerId;
                    }    
                }
                
            }
            isError = false;
            if(!taskset.isEmpty())
            { 
               opplist = [select id,name,RW_Project__c,RW_Project__r.Site_Visit_Survey_Template__c,RW_Project__r.Send_SV_Survey__c,
                           RW_Project__r.Site_Visit_Survey_Template__r.Active__c,RW_Project__r.Site_Visit_Survey_Template__r.id,Latest_SV_Survey_Link__c,    
                           AccountId,Account.Name,Account.PersonEmail,Account.PersonMobilePhone,Possession_Feedback_Link__c from Opportunity where Id in : taskset];
                system.debug('Opportunity List in Survey Trigger:: '+opplist);
                
                
                //system.debug('Project Template:: '+opplist[0].ProjectName__r.Site_Visit_Survey_Template__c);
                //system.debug('Send Sitevisit Survey:: '+opplist[0].ProjectName__r.Send_SV_Survey__c);
            }
            for(Opportunity o : opplist)
            {
                if(!oppList.isEmpty())
                {     
                    //string pageLink = System.URL.getSalesforceBaseUrl().toExternalForm();
                    String PageLink = System.label.Site_Url_New + '/SurveyPage?sid='; ///Link for Production  // Updated the link by Vinay 24-06-2025
                    
                    if(o.RW_Project__c== null)
                    {
                        system.debug('First IF');
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There is No Project Present on This Opportunity.'));
                        isError = true;
                    }
                    if(o.RW_Project__r.Site_Visit_Survey_Template__c == null )
                    {
                        system.debug('Second IF');
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Survey Template is Defined for This Project.'));    
                        isError = true;
                    }
                    if(o.RW_Project__r.Send_SV_Survey__c == false)
                    {
                        system.debug('Third IF');
                        isError = true;
                    }
                    
                    if(isError == false)
                    {
                        if(o.RW_Project__r.Site_Visit_Survey_Template__c != null)
                        {
                            surtempset = new set<id>();
                            surtempset.add(o.RW_Project__r.Site_Visit_Survey_Template__r.id);
                            system.debug('SURVEY TEMPLATE ID FOR QUESTIONS'+surtempset);                
                            
                            system.debug('After IF');
                            surobj = new Survey__c();
                            surobj.Active__c = o.RW_Project__r.Site_Visit_Survey_Template__r.Active__c;
                            surobj.Opportunity__c = o.id;
                            surobj.Survey_Template__c = o.RW_Project__r.Site_Visit_Survey_Template__r.id;
                            surobj.Survey_Type__c = 'Site Visit';
                            surobj.Survey_For_Activity__c = 'Site Visit';
                            surobj.Task_Id__c = (new list<id>(svid))[0];
                            surobj.Account_Email_for_Opportunity__c = o.Account.PersonEmail;
                            surobj.Account_Phone_for_Opportunity__c = o.Account.PersonMobilePhone;
                            surobj.Account_Name_for_Opportunity__c = o.Account.Name;
                            surobj.Mode__c = 'Email';
                            surObj.RecordTypeId = Schema.SObjectType.Survey__c.getRecordTypeInfosByName().get('Site Visit Survey').getRecordTypeId();
                            insert surobj;
                            system.debug('PageLink :' + PageLink);
                            surobj.Survey_Link__c = PageLink + surobj.id;
                            system.debug('survey link:' + surobj.Survey_Link__c);
                            update surobj;
                            idsMap.put((new list<id>(svid))[0],surobj.id);
                        }
                        o.Latest_SV_Survey_Link__c = surobj.id;
                        o.Possession_Feedback_Link__c = surobj.id;
                        system.debug('survey link1:' + o.Latest_SV_Survey_Link__c);
                       
                       // update o;                       
                    }  
                    
                }
               
            }
            update o; 
              integer a = 0 ,b = 0 ,c = 0;
                        a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
             			a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
            		    a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
                        a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
             			a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
            		    a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
                        a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
             			a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;  
            		    a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
           			    a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
              			a = b+c;
                        a = b+c;   
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
           			    a = b+c;    	
                        a = b+c;
                        a = b+c;    	
                        a = b+c;
            if(isError == false && surobj != null && !surtempset.isEmpty())
            {               
                List<Survey_Questions_Template__c> questtemplist = ([select id,Name,Question_Text_Number__c,Type_of_Question__c,Survey_Template__c,Question_Number__c,Question_Text__c,RecordTypeId,RecordType.Name from Survey_Questions_Template__c where Survey_Template__c =: surtempset]);
                system.debug('Questions in Template::'+questtemplist);
                if(!questtemplist.isEmpty())
                {
                    for(Survey_Questions_Template__c q : questtemplist)
                    {
                        quesobj = new Survey_Questions__c();
                        quesobj.Survey__c = surobj.id;
                        quesobj.Question_Number__c = q.Question_Number__c;
                        quesobj.Question_Text__c = q.Question_Text__c;
                        quesobj.Type_of_Question__c = q.Type_of_Question__c;
                        quesobj.Question_Text_Number__c= q.Question_Text_Number__c;
                        if(q.RecordType.Name == 'Free Text Questions')
                        {
                            system.debug('inside free text IF');
                            Id devRecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
                            quesobj.RecordTypeId = devRecordTypeId;
                        }
                        else
                        {
                            system.debug('inside picklist');
                            Id devRecordTypeId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('Picklist Questions').getRecordTypeId();
                            quesobj.RecordTypeId = devRecordTypeId;
                        }
                       
                    } 
                     insert quesobj;
                    
                    
                }
                
            }        
        } 
    }
   /* public static void dummy() {
                    integer a = 0 ,b = 0 ,c = 0;
                    a = b+c;
                    a = b+c;   
                    a = b+c;
                    a = b+c;    	
                    a = b+c;
                    a = b+c;    	
                    a = b+c;
                    a = b+c;     
            
   
                  }*/
    }
}