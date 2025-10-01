public without sharing class MyCaseController
{
	@AuraEnabled
    public static List<wrapCase> getCase()
	{
		//List<User> lstUser = [Select accountId from User where id =: Userinfo.getUserid()];
		List<wrapCase> lstWrap = new List<wrapCase>();
		List<Case> lstCase = [select Id, Subject, Description, RW_Resolution_comments__c, Status, 
								RW_Case_Comming_From_Portal__c, RW_Case_Type__c from Case Where 
								RW_Case_Comming_From_Portal__c =: Userinfo.getUserid()];

		if(lstCase != null && lstCase.size() > 0)
		{
			for(Case EachCase : lstCase)
			{
				wrapCase objWrap = new wrapCase();
				objWrap.strCaseStatus = EachCase.Status;
				objWrap.strCaseSubject = EachCase.Subject;
				objWrap.strCaseDescription = EachCase.Description;
				objWrap.strCaseRemark = EachCase.RW_Resolution_comments__c;
				if(EachCase.RW_Case_Type__c != null)
					objWrap.strCaseType = EachCase.RW_Case_Type__c;
				lstWrap.add(objWrap);
			}

			return lstWrap;
		}
		else
			return null;
	} 

	@AuraEnabled
    public static String insertNewCase(String Sub, String Descrp, String SelectedUnit, String CaseType)
	{
        System.debug('unit: '+ SelectedUnit);
		if(Sub != null && Sub != '' && Descrp != null && Descrp != '')
		{
			list<group> lstQueue = [select id, name from group where Type = 'Queue' and name =: label.Generic_Queue_Name];
			
			Case objCase = new Case();
			objCase.Subject = Sub;
			objCase.Description = Descrp;
			objCase.RW_Case_Comming_From_Portal__c = Userinfo.getUserid();
			objCase.Status = 'Open';
			objCase.RW_Case_Type__c = CaseType;
			objCase.Origin = 'Portal';

			User objLoggedInUser = [Select id, accountId, account.PersonContactId from User where id =: Userinfo.getUserid()];
			if(objLoggedInUser.accountId != null)
				objCase.AccountId = objLoggedInUser.accountId;

			if(objLoggedInUser.account.PersonContactId != null)
				objCase.ContactId = objLoggedInUser.account.PersonContactId;

			if(SelectedUnit != null && SelectedUnit != '')
			{
				List<Project_Unit__c> lstProjUnit = [select Id, name, RW_Project__c, RW_Customer__c, RW_Customer__r.RW_RM_Name__c from Project_Unit__c 
														where name =: SelectedUnit];
				if(lstProjUnit != null && lstProjUnit.size() > 0)
				{
					objCase.RW_Project_Unit__c = lstProjUnit[0].id;
					objCase.RW_Project__c = lstProjUnit[0].RW_Project__c;
					if(lstProjUnit[0].RW_Customer__c != null && lstProjUnit[0].RW_Customer__r.RW_RM_Name__c != null)
						objCase.RW_RM_Name__c = lstProjUnit[0].RW_Customer__r.RW_RM_Name__c;
				}
			}

			if(lstQueue != null && lstQueue.size() > 0)
				objCase.OwnerId = lstQueue[0].id;

			try{
				insert objCase;
				return 'Case has been successfully created.';
			}
			catch(exception ex)
			{
				return 'Error - '+ex.getMessage();
			}
		}
		else
			return 'Please enter Subject and Description.';
	}

	@AuraEnabled
    public static List<string> fetchUnits() 
    {
        User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

		List<Opportunity> lstOpp = [Select Id, RW_Project__c, RW_Project_Unit__c, RW_Project_Unit__r.name from Opportunity
									where AccountId =: objLoggedInUser.accountId];

		if(lstOpp != null && lstOpp.size() > 0)
		{
			List<String> lstOfUnit = new List<String>();
			for(Opportunity EachOpp : lstOpp)
			{
				if(EachOpp.RW_Project_Unit__c != null)
					lstOfUnit.add(EachOpp.RW_Project_Unit__r.name);
			}

			if(lstOfUnit.size() > 0)
				return lstOfUnit;
		}
		
		return null;
    }

	@AuraEnabled
	public static List<string> fetchCaseType()
	{
		List<String> lstPickVal = new List<String>();
		Schema.DescribeFieldResult fieldResult = Case.RW_Case_Type__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListVal = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry EachPickListVal : lstPickListVal)
		{
			lstPickVal.add(EachPickListVal.getValue());
		}

		return lstPickVal;
	}
}