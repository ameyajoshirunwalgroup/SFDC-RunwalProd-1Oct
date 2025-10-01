public class FeedbackComponentController 
{
    @AuraEnabled
    public static list<RW_Feedback__c> getFeedBackData()
    {
    	User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
        
        if(objLoggedInUser != null && objLoggedInUser.accountId != null)
        {
        	string strQuery = 'select id, name, RW_Project__c, RW_Project__r.name, RW_Project_Unit__c, RW_Project_Unit__r.name, (select ';
			Schema.FieldSet FBFieldSet = Schema.SObjectType.RW_Feedback__c.fieldSets.FBPortal;
			for(Schema.FieldSetMember fieldsSetMem : FBFieldSet.getFields())
			{
				strQuery += fieldsSetMem.getFieldPath().toLowercase() + ',';
			}
			
			string stAccId = objLoggedInUser.accountId;
			boolean isCompleted = false;
			strQuery += ' id, RW_Unit_Name__c from Feedback__r where RW_Is_Completed__c =: isCompleted) from opportunity where AccountId =: stAccId';
			
			system.debug('@strQuery__________'+strQuery);
			
			list<Opportunity> lstOppDetails = Database.query(strQuery);
			list<RW_Feedback__c> lstFeedBack = new list<RW_Feedback__c>();
			
			if(lstOppDetails != null && lstOppDetails.size() > 0)
			{
				for(Opportunity EachOpp : lstOppDetails)
				{
					//system.debug('@EachOpp.Feedback__r_________'+EachOpp.Feedback__r);
					if(EachOpp.Feedback__r != null && EachOpp.Feedback__r.size() > 0)
					{
						lstFeedBack.addAll(EachOpp.Feedback__r);
					}
				}
			}
			
			//if(lstFeedBack != null && lstFeedBack.size() > 0)
				return lstFeedBack;
			
				
        }
    	
    	return null;
    }
    
    @AuraEnabled
    public static string SaveFeedBackData(list<RW_Feedback__c> lstFeedBack)
    {
    	if(lstFeedBack != null && lstFeedBack.size() > 0)
    	{
    		/*boolean isError = false;
            for(RW_Feedback__c EachFB : lstFeedBack)
            {
                if(EachFB.RW_Hospitality_by_the_executive__c == null || EachFB.RW_Tell_us_about_our_service__c == null)
                {
                    isError = true;
                }
            }
            
            if(isError)
            {
                return 'Please fill up all the answers.';
            }
            else
            {
                update lstFeedBack;
                return 'You have Successfully submitted the feedback!';
            }*/
			try
			{
				update lstFeedBack;
                return 'You have Successfully submitted the feedback!';
			}
			catch(exception ex)
			{
				string strTempError = '';
				if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true)
				{
					strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,') [1]).split(':') [0]).trim();
				}

				if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true)
				{
					strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,') [1]).split(':') [0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,') [1]).split(':') [1]).trim();
				}

				if(strTempError != '')
					return 'Error - '+strTempError;
				else
					return 'Error - '+ex.getMessage();
			}
    	}
    	return null;
    }
}