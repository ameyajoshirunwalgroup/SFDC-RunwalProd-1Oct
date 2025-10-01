public class sendEmailOnEsclatationHandler
{
    public void sendEsclation(List<Task> triggerNew, Map<Id, Task> mapOldTaskId)
    {
        //set<id> taskId = new Set<id>();
        
        set<id> setOfTaskidForSMS = new Set<id>();
        list<Event> lstEventToInsert = new list<Event>();
        set<id> setOftaskId = new set<id>();
        
        for(Task newTask : triggerNew)
        {
            /*if(newTask.RW_Escalation_Days__c!=null && newTask.RW_Escalation_Days__c > 0 && newTask.RW_Escalation_Days__c != triggerOldmap.get(newTask.id).RW_Escalation_Days__c)
            {
                taskId.add(newTask.id);
            }*/
            //if(newTask.WhatId!=null && newTask.getSObjectType()==Opportunity.sObjectType) Oppid.add(newTask.WhatId);
        /*    if(newTask.Call_Status__c == 'Visit Confirmed' && ((mapOldTaskId != null && mapOldTaskId.get(newTask.Id).Call_Status__c != 'Visit Confirmed') 
                || mapOldTaskId == null) && newTask.RW_Call_Timing__c!=null)
            {
                //Oppid.add(newTask.WhatId);
                event objEvent = new event();
                objEvent.Subject = 'Site Visit';
                objEvent.StartDateTime = newTask.RW_Call_Timing__c;
                objEvent.EndDateTime = newTask.RW_Call_Timing__c.addDays(1);
                objEvent.WhatId= newTask.WhatId;
                objEvent.OwnerId = newTask.OwnerId;
                objEvent.Type = 'Site Visit';
                if(newTask.RW_Sales_Associate__c!=null)
                objEvent.RW_Sales_Associate__c = newTask.RW_Sales_Associate__c;
               // insert objEvent;
               lstEventToInsert.add(objEvent);   // Added on 27-Dec-2015
            }
            */
            
            //update on the 5/3 for change in requirement by Adarsh
            if(newTask.RW_Call_Completion__c && ((mapOldTaskId != null && !mapOldTaskId.get(newTask.Id).RW_Call_Completion__c) || mapOldTaskId == null))
                setOftaskId.add(newTask.id);
        }
        
        if(setOftaskId.size() > 0)
                OutboundSMSFutureHandler.SendSMSOnOppCallCompletionTask(setOftaskId);
        
        // Added on 27-Dec-2015
        if(lstEventToInsert<> null && lstEventToInsert.size()>0)
        {
            Insert lstEventToInsert;
            for(Event ObjEvent: lstEventToInsert)
                setOfTaskidForSMS.add(ObjEvent.id);
            OutboundSMSFutureHandler.SendSMSOnOppSiteVisitConfrm(setOfTaskidForSMS);
        }
    }
        
    public void  countNumberOfVisitsOnOpportunity(List<Event> triggernew, Map<Id, Event> oldMap)
    {
        Set<id> setOppId = new Set<id>();
        for(Event eachEvent : triggernew)
        {
            if(eachEvent.WhatId != null && eachEvent.WhatId.getSObjectType() == Opportunity.SObjectType)
            {
                setOppId.add(eachEvent.WhatId);
            }
        }
        
        if(setOppId != null && setOppId.size() > 0)
        {
            List<Event> lstEvent = [select Id, WhatId, Type from Event  where WhatId =: setOppId and (Type =: 'Site Visit' or Type =: 'Re-visit' )];

            if(lstEvent != null && lstEvent.size() > 0)
            {
                Map<String, Integer> mapOfVisit = new Map<String, Integer>();
                Map<String, Integer> mapOfReVisit = new Map<String, Integer>();
                list<Opportunity> lstOpp2Update = new list<Opportunity>();
                for(Event EachEvent : lstEvent)
                {
                    if(EachEvent.Type == 'Site Visit')
                    {
                        if(!mapOfVisit.containsKey(EachEvent.WhatId))
                        {
                            mapOfVisit.put(EachEvent.WhatId, 0);
                        }
                        mapOfVisit.put(EachEvent.WhatId, mapOfVisit.get(EachEvent.WhatId) + 1);
                    }

                    if(EachEvent.Type == 'Re-visit')
                    {
                        if(!mapOfReVisit.containsKey(EachEvent.WhatId))
                        {
                            mapOfReVisit.put(EachEvent.WhatId, 0);
                        }
                        mapOfReVisit.put(EachEvent.WhatId, mapOfReVisit.get(EachEvent.WhatId) + 1);
                    }
                }

                for(Id EachId : setOppId)
                {
                    Opportunity objOpp = new Opportunity();
                    objOpp.Id = EachId;
                    if(mapOfVisit != null && mapOfVisit.size() > 0 && mapOfVisit.containsKey(EachId))
                    {
                        objOpp.RW_Number_of_Visits__c = mapOfVisit.get(EachId);
                    }
                    else
                    {
                        objOpp.RW_Number_of_Visits__c = 0;
                    }

                    if(mapOfReVisit != null && mapOfReVisit.size() > 0 && mapOfReVisit.containsKey(EachId))
                    {
                        objOpp.RW_Number_of_Re_Visit__c = mapOfReVisit.get(EachId);
                    }
                    else
                    {
                        objOpp.RW_Number_of_Re_Visit__c = 0;
                    }

                    lstOpp2Update.add(objOpp);
                }

                if(lstOpp2Update!=null && lstOpp2Update.size()>0)
                    update lstOpp2Update;
            }
        }
        
        /*AggregateResult[] groupedResults = [SELECT WhatId, COUNT(id)cntId FROM event where WhatId =:Oppid and Type =: 'Site Visit' GROUP BY WhatId];
        AggregateResult[] groupedResultsRevisit = [SELECT WhatId, COUNT(id)cntId FROM event where WhatId =:Oppid and Type =: 'Re-visit' GROUP BY WhatId];
        //list<task> LstTaskWithOpp = [SELECT WhatId, id FROM Task where WhatId =:Oppid and Status =:'Completed'];
        list<Opportunity> lstOpp = [SELECT id, RW_Number_of_Visits__c, RW_Number_of_Re_Visit__c from Opportunity where id in:Oppid];
        list<Opportunity> lstOpp2Update = new list<Opportunity>();
            
        for(Opportunity eachOpp : lstOpp)
        {
            for(AggregateResult ar : groupedResults)
            {
                if(ar.get('WhatId')==eachOpp.id)
                {
                    eachOpp.RW_Number_of_Visits__c = (Decimal) ar.get('cntId');
                }
            }
                
            for(AggregateResult ar : groupedResultsRevisit)
            {
                if(ar.get('WhatId')==eachOpp.id)
                {
                    eachOpp.RW_Number_of_Re_Visit__c = (Decimal) ar.get('cntId');
                }
                    
            }
                
            //eachOpp.RW_Number_of_Visits__c = eachOpp.RW_Number_of_Visits__c != null ? eachOpp.RW_Number_of_Visits__c : 0;
                
            //eachOpp.RW_Number_of_Visits__c += eachOpp.RW_Number_of_Re_Visit__c != null ? eachOpp.RW_Number_of_Re_Visit__c : 0;
                
            lstOpp2Update.add(eachOpp);
        }
        
        if(lstOpp2Update!=null && lstOpp2Update.size()>0)
            update lstOpp2Update;*/
    }
    //update on the 5/3 for change in requirement by Adarsh
    public void afterInsert(list<task> lstTask)
    {
        if(lstTask != null && lstTask.size() > 0)
        {
            set<id> setOftaskId = new set<id>();
            for(Task EachTask : lstTask)
            {
                if(EachTask.RW_Call_Completion__c)
                    setOftaskId.add(EachTask.id);
            }
            if(setOftaskId.size() > 0)
                OutboundSMSFutureHandler.SendSMSOnOppCallCompletionTask(setOftaskId);
            
              //copySalesManager(lstTask);
        }
        sendEsclation(lstTask, null);
        
           
    }
    
    //update on the 16/8/2016 for populating the sales manager field in opportunity by Rupalika
   /* commented by shailesh on 22.1.18 as sales manager selection process changed
    public void copySalesManager(list<task> lstTask)
    {
        set<Id> setOfOppId = new set<Id>();
        List<Opportunity> listOfOpp2Update = new List<Opportunity>();
        
        for(Task objTask : lstTask)
        {
            if(objTask.Whatid != null && objTask.Whatid.getSObjectType()==Opportunity.sObjectType)
                setOfOppId.add(objTask.Whatid);
        }
        if(setOfOppId.size()>0)
        {
            Map<id,Opportunity> mapOfOpp = new Map<id,Opportunity>([SELECT id, First_Time_Task_Assigned__c, RW_Sales_Associate__c from 
                                                                    Opportunity where id in:setOfOppId]);
        
            system.debug('@cr_____'+mapOfOpp);
            for(Task objTask : lstTask)
            {
                if(objTask.Whatid != null && objTask.Whatid.getSObjectType() == Opportunity.sObjectType && mapOfOpp.containsKey(objTask.Whatid))
                {
                    if(objTask.RW_Sales_Associate__c != null && !mapOfOpp.get(objTask.Whatid).First_Time_Task_Assigned__c)
                    {
                        mapOfOpp.get(objTask.Whatid).RW_Sales_Associate__c = objTask.RW_Sales_Associate__c;
                        mapOfOpp.get(objTask.Whatid).RW_Call_Completion__c= objTask.RW_Call_Completion__c;
                        mapOfOpp.get(objTask.Whatid).First_Time_Task_Assigned__c= true;
                        listOfOpp2Update.add(mapOfOpp.get(objTask.Whatid));
                    }
                    
                }
            }
            
            if(listOfOpp2Update.size() > 0)
                update listOfOpp2Update;
        }
    }
    **/
    public void updateLastSiteVisit(List<Event> triggernew, Map<Id, Event> oldMap)
    {
        Set<Id> setOppId = new Set<id>();
        List<Opportunity> listOfOpp = new List<Opportunity>();
        List<Opportunity> lst2updateOpp = new List<Opportunity>();
        map<id,Event> mapOfOppIDvsEndDate= new map<id,Event>();
        for(Event eachEvent : triggernew)
        {
            if(oldmap != null && oldMap.get(eachEvent.id).Type != eachEvent.Type && (eachEvent.Type == 'Site Visit' || eachEvent.Type == 'Re-visit')&& eachEvent.WhatId != null)
               { setOppId.add(eachEvent.Whatid); 
               mapOfOppIDvsEndDate.put(eachEvent.Whatid,eachEvent);
               }
                else if(oldmap == null && (eachEvent.Type== 'Site Visit' || eachEvent.Type== 'Re-visit')&& eachEvent.WhatId != null)
                   {
                   setOppId.add(eachEvent.Whatid);  
                    mapOfOppIDvsEndDate.put(eachEvent.Whatid,eachEvent);
                    }                  
                   system.debug('%%%%%%%setOppId%%%%%'+setOppId);        
        }
        if(setOppId.size()>0)
        {
            listOfOpp= [SELECT id, Last_Site_Visit_Date__c , name from Opportunity where id in:setOppId] ;
            system.debug('%%%%%%%listOfOpp%%%%%'+listOfOpp);
        }
        for(Opportunity ObjOpp :listOfOpp)
        {
            ObjOpp.Last_Site_Visit_Date__c = Date.ValueOf(mapOfOppIDvsEndDate.get(ObjOpp.id).EndDateTime);
            lst2updateOpp.add(ObjOpp);
            system.debug('%%%%%%%ObjOpp.Last_Site_Visit_Date__c%%%%%'+ObjOpp.Last_Site_Visit_Date__c);
            system.debug('%%%%%%%lst2updateOpp%%%%%'+lst2updateOpp);
        }
        if(lst2updateOpp.size()>0)
        update lst2updateOpp;
    }

    public void validateDelte(List<Event> triggernew, Map<Id, Event> oldMap)
    {
        User loggedinUser = [select Id, Profile.Name from User where Id = :UserInfo.getUserId()];
        for(Event EachEvent : oldMap.values()) // triggernew
        {
            if(loggedinUser.Profile.Name != 'System Administrator')
            {
                EachEvent.addError('You cannot delete the task, please contact your system admin.');
            }
        }
    }
    
}