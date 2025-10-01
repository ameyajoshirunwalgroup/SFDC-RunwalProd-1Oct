global class RWUpdateLeadActivityCount implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator([Select Id, (select id from Tasks), (select id from events) from Lead where isConverted =: false]);
    
    }                                                          
                                
     global void execute(Database.BatchableContext bc, List<Lead> lstLead)
     {
        if(lstLead != null && lstLead.size() > 0)
		{
			for(Lead EachLead : lstLead)
			{
				if(EachLead.Events != null && EachLead.Events.size() > 0)
					EachLead.RW_Number_of_Events__c = EachLead.Events.size();
				else
					EachLead.RW_Number_of_Events__c = 0;

				if(EachLead.Tasks != null && EachLead.Tasks.size() > 0)
					EachLead.RW_Number_of_Tasks__c = EachLead.Tasks.size();
				else
					EachLead.RW_Number_of_Tasks__c = 0;
			}
			update lstLead;
		}
     }                
     global void finish(Database.BatchableContext bc)
     {
        
     }
}