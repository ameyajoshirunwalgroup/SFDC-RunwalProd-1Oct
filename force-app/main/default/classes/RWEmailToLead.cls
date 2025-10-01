/*
    This Class is used for the email to creation of lead  
    --------------------------------------------------------------------------------------
    Name                                Date                                Version                     
    --------------------------------------------------------------------------------------
    Adarsh                            03/07/2017                              1.0   
    --------------------------------------------------------------------------------------
*/
global class RWEmailToLead implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
    	Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
    	
    	RW_Email_To_Lead_Activity__c objEmail = new RW_Email_To_Lead_Activity__c();
        objEmail.RW_Body__c = email.plainTextBody;
        objEmail.RW_From_Email__c = email.fromAddress;
        objEmail.RW_Subject__c = email.subject;

		List<User> lstUser = [select id from User where username =: Label.EmailToLeadUser];
        
        Lead objLead = new Lead();
        objLead.Email = email.fromAddress;
        objLead.LastName = email.fromAddress;
		objLead.LeadSource = 'Email';
        objLead.RW_Lead_through_Email__c = true;

		if(lstUser != null && lstUser.size() > 0)
		{
			objLead.OwnerId = lstUser[0].id;
		}
        
        try
        {
        	insert objLead;
        	
        	objEmail.RW_Lead__c = objLead.id;
        	insert objEmail;
        	
        	result.success = true;
        }
        catch(exception ex)
        {
        	system.debug('@Error______'+ex.getMessage());
        	result.success = false;
        }
        
        return result;
    }
}