public class RWShortPageController
{
	public List<SelectOption> lstProjectList { get; set; }
	public Lead NewLead { get; set; }
	public string strProjectId { get; set; }
	public string strError { get; set; }
	public list<Lead> lstDuplicateLeads { get; set; }
	public Boolean isDuplicateLeadExist { get; set; }
	public Boolean isNew { get; set; }
	public Boolean isNRI { get; set; }
	public RWShortPageController()
	{
		NewLead = new Lead();
		lstProjectList = new List<SelectOption>();
		strError = '';
		isDuplicateLeadExist = false;
		isNew = true;
		isNRI = false;

		List<Project__c> lstProj = [select Id, name from Project__c where RW_Status__c =: 'Active'];
		if(lstProj != null && lstProj.size() > 0)
		{
			for(Project__c EachProj : lstProj)
			{
				lstProjectList.add(new SelectOption(EachProj.id, EachProj.name));
			}
		}
	}

	//on cancel button
    public PageReference goBack()
    {
        Pagereference objReference = new Pagereference('/');
        objReference.setRedirect(true);
        return objReference;
    }

	//on countinue button
    public PageReference saveMethod()
    {
        strError = '';
		Savepoint sp = Database.setSavepoint();
		try
		{
			if(strProjectId == null || strProjectId == '')
			{
				strError = 'Please select the Project to proceed.';
				return null;
			}

			if(NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '')
			{
				strError = 'Please enter the Contact No to proceed.';
				return null;
			}

			list<Lead> lstLead = [select Id from Lead where RW_Mobile_No__c =: NewLead.RW_Mobile_No__c and RW_Project__c =: strProjectId and 
										isConverted =: false];

			list<Opportunity> lstOpp = [select id, OwnerId, RW_Project__c, AccountId from Opportunity where Account.Mobile_No__c =: NewLead.RW_Mobile_No__c and 
												RW_Project__c =: strProjectId and RW_Opportunity_Status__c =: 'Active'];
			if(lstLead != null && lstLead.size() > 0)
			{
				Pagereference objReference = new Pagereference('/apex/RWCIFForm?id='+lstLead[0].id);
				objReference.setRedirect(true);
				return objReference;
			}
			else if(lstOpp != null && lstOpp.size() > 0)
			{
				Event objEvent = new Event();
				objEvent.WhatId = lstOpp[0].id;
				objEvent.Subject = 'Re-Visit';
				objEvent.OwnerId = lstOpp[0].OwnerId;
				objEvent.StartDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 6, 00, 00);
				objEvent.EndDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 8, 00, 00);
				objEvent.Type = 'Re-visit';
				objEvent.Project__c = strProjectId;
				insert objEvent;

				Pagereference objReference = new Pagereference('/'+lstOpp[0].id);
				objReference.setRedirect(true);
				return objReference;
			}
			else
			{
				if(NewLead.LastName == null || NewLead.LastName == '')
				{
					strError = 'Please enter the Last Name to proceed.';
					return null;
				}

				if(NewLead.Email == null || NewLead.Email == '')
				{
					strError = 'Please enter the Email to proceed.';
					return null;
				}

				NewLead.RW_Project__c = strProjectId;
				NewLead.RW_Lead_through_Email__c = true;

				if(isNRI)
				{
					NewLead.RW_Customer_Type__c = 'NRI';
				}

				insert NewLead;

				Pagereference objReference = new Pagereference('/apex/RWCIFForm?id='+NewLead.id);
				objReference.setRedirect(true);
				return objReference;
			}
		}
		catch(exception ex)
		{
			Database.rollback(sp);
            string strTempError = '';
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true)
            {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,') [1]).split(':') [0]).trim();
            }

            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true)
            {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,') [1]).split(':') [0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,') [1]).split(':') [1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();

            return null;
		}
    }

	public void searchAllLead()
	{
		lstDuplicateLeads = new list<Lead>();
		strError = '';
		if(strProjectId == null || strProjectId == '')
		{
			strError = 'Please select the Project to proceed.';
			return;
		}

		if(NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '')
		{
			strError = 'Please enter the Contact No to proceed.';
			return;
		}

		if(!isNRI &&  NewLead.RW_Mobile_No__c.length() != 10)
		{
			strError = 'Please enter the mobile number of 10 digit.';
			return;
		}

		isNew = false;

		string strMobileNumber = '%'+NewLead.RW_Mobile_No__c+'%';

		string strQry = 'select id, name, RW_project__r.Name, ';

		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Lead');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('RWLeadSearch');

		for(Schema.FieldSetMember fieldsSetMem : fieldSetObj.getFields()) 
		{
			strQry += fieldsSetMem.getFieldPath().toLowercase()+','; 
		}
		strQry = strQry.removeEnd(',');
		strQry += ' from Lead where RW_Mobile_No__c LIKE: strMobileNumber and RW_Project__c =: strProjectId and isConverted = false';

		lstDuplicateLeads = database.query(strQry);

		if(lstDuplicateLeads != null && lstDuplicateLeads.size() > 0)
		{
			isDuplicateLeadExist = true;
		}
		else
		{
			isDuplicateLeadExist = false;
		}
	}
}