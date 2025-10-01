trigger SubOfferTrigger on RW_Sub_Offer__c (before insert) 
{
    Map<Id,String> ProjectSalesDirectorMap = new Map <Id,String>();
    set<String> ProjectMap = new Set<String>();
    List<RW_Sub_Offer__c> subofferRecords = [Select Name,Project__c,Tower__c,RW_Offer_Type__c,Offer__c,RW_Approver__c from RW_Sub_Offer__c];
    System.debug('inside 1');
    if(subofferRecords!= null && subofferRecords.size() >0)
    {
        System.debug('inside 2');
        for(RW_Sub_Offer__c existingsuboffers : subofferRecords)
        {
            for(RW_Sub_Offer__c suboffer:Trigger.new)
            {
                
                if((suboffer.Project__c == existingsuboffers.Project__c) && (suboffer.Tower__c == existingsuboffers.Tower__c) && (suboffer.Name == existingsuboffers.Name) && (suboffer.RW_Offer_Type__c == existingsuboffers.RW_Offer_Type__c) && (suboffer.Offer__c == existingsuboffers.Offer__c ))
                {
                    
                    suboffer.addError('An suboffer with same name already exists for this project,Tower,Offer and Offer Type combination.');
                } 
            }
            
            
        }
    }
    
    for(RW_Sub_Offer__c suboffer:Trigger.new)
    {
        ProjectMap.add(suboffer.Project__c);
        
    }
    
    List<Project__c> projectRec = [SELECT Id, Site_Head_User__c FROM Project__c WHERE Id IN: ProjectMap ];
    for(Project__c proj : projectRec)
    {
        ProjectSalesDirectorMap.put(proj.Id, proj.Site_Head_User__c);
    }
    
    for(RW_Sub_Offer__c suboffer:Trigger.new)
    {
        for(Id projectId : ProjectSalesDirectorMap.keySet())
        {
            
            if(suboffer.Project__c == projectId)
            {
                
                suboffer.RW_Approver__c = ProjectSalesDirectorMap.get(projectId);
            }
        }
    }
    
    
}