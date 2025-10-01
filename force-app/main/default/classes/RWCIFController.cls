public without sharing class RWCIFController 
{
	public Lead objLead { get; set; }
	public string strLeadId;
	public String strEventDate { get; set; }
	public String strDOB { get; set; }
	public List<wrapLeadSource> lstLeadSource { get; set; }
	public string strCurrentSource { get; set; }
	public string strError { get; set; }
	public Boolean isSubmitted { get; set; }

	//constructor 
    public RWCIFController(ApexPages.StandardController controller)
	{
		initialize();
		//objLead = (Lead)controller.getRecord();

		if(Apexpages.Currentpage().getParameters().get('id') != null && Apexpages.Currentpage().getParameters().get('id') != '')
			strLeadId = Apexpages.Currentpage().getParameters().get('id');

		if(strLeadId != null && strLeadId != '')
		{
			objLead = [select Id, salutation, firstName, LastName, RW_Project__c, RW_Mobile_No__c, RW_Secondary_Mobile_No__c, Email, RW_Secondary_Email__c, 
						Phone, State__c, City__c, Zip_Code__c, Street__c, Country__c, RW_Occupation__c, RW_Company_Name__c, RW_Company_Location__c,
						RW_Designation__c, RW_Budget_Rs_in_Cr__c, RW_Configuration__c, LeadSource, RW_Project__r.Name, RW_Broker__c, RW_Reference_Source__c,
						RW_Apply_Unregistered_Broker__c, RW_Unregistered_Broker_Email__c, RW_Unregistered_Broker_Mobile__c, RW_Unregistered_Broker_Name__c,
						Customer_Reference__c, RW_Lead_Sub_Source__c, Corporate_Company__c, NameofUnregisteredCorporate_LeadSource__c, RW_Nature_of_Work__c,
						RW_Family_Structure__c, RW_Floor_Choices__c, RW_Facing__c, RW_Time_line__c, RW_Vastu_Entry_Towards__c, RW_Any_Other_Vastu__c,
						RW_Number_of_Cars__c, RW_With_Balcony__c, RW_With_Servant_Room__c, RW_Neighbourhood_Places__c, RW_Date_of_Birth__c, RW_Customer_Type__c,
						RW_Other_Company_Name__c, RW_Location__c, RW_Ethnicity__c, RW_Referral_Details__c
						from Lead where id =: strLeadId];
		
			Schema.DescribeFieldResult fieldResult = Lead.LeadSource.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for( Schema.PicklistEntry f : ple)
			{
				wrapLeadSource objWrap = new wrapLeadSource();
				if(f.getLabel() != 'Corporate(Unregistered)')
				{
					objWrap.strLabel = f.getLabel();
				
					objWrap.strLeadSource = f.getValue();

					if(objLead.LeadSource == 'Corporate(Unregistered)' && f.getLabel() == 'Corporate')
					{
						objWrap.isSelected = true;
						objLead.Corporate_Company__c = 'Other';
					}
					else if(objLead.LeadSource != null && objLead.LeadSource == f.getValue())
					{
						objWrap.isSelected = true;
					}

				lstLeadSource.add(objWrap);
				}
			}

			if(objLead.RW_Date_of_Birth__c != null)
			{
				strDOB = string.valueOf(datetime.newInstance(objLead.RW_Date_of_Birth__c.year(), 
                                                        objLead.RW_Date_of_Birth__c.month(), 
                                                        objLead.RW_Date_of_Birth__c.day()).format('dd/MM/yyyy'));
			}

			if(objLead.RW_Budget_Rs_in_Cr__c != null)
			{
				objLead.RW_Budget_Rs_in_Cr__c = objLead.RW_Budget_Rs_in_Cr__c / 10000000;
			}
			objLead.RW_CIF_Form_Submit_Date__c = System.now();
		}
	}   
	
	//initialize
	private void initialize()
	{
		objLead = new Lead();
		lstLeadSource = new List<wrapLeadSource>();
		strError = '';
		strEventDate = string.valueOf(system.now().format('dd/MM/yyyy HH:mm a'));
		isSubmitted = false;
	} 

	//wrapper for lead source
	public class wrapLeadSource
	{
		public string strLeadSource { get; set; }
		public string strLabel { get; set; }
		public Boolean isSelected { get; set; }

		public wrapLeadSource()
		{
			isSelected = false;
		}
	}

	//this method is used for validating the walkin source
    public void validateLeadSource()
    {
        Boolean isOneSelected = false;
		if (lstLeadSource != null && lstLeadSource.size() > 0)
        {
            for (wrapLeadSource EachSource : lstLeadSource)
            {
                if(EachSource.isSelected)
					isOneSelected = true;
				
				if (strCurrentSource != null && strCurrentSource != '')
                {
                    if (strCurrentSource != EachSource.strLeadSource)
                        EachSource.isSelected = false;
                }
                else
					EachSource.isSelected = false;
            }
        }
        objLead.LeadSource = strCurrentSource;

		if(!isOneSelected)
		{
			objLead.LeadSource = null;
			strCurrentSource = null;
		}
    }

	public PageReference GoBackToLead()
	{
		Pagereference objReference = new Pagereference('/' + objLead.Id);
        objReference.setRedirect(true);
        return objReference;
	}

	public PageReference redirectNext()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			strError = '';
			if(objLead != null)
			{
				if(objLead.RW_Customer_Type__c == null || objLead.RW_Customer_Type__c == '')
				{
					strError = 'Please fill up the Customer Type to proceed.';
					return null;
				}

				if(objLead.RW_Occupation__c == null || objLead.RW_Occupation__c == '')
				{
					strError = 'Please fill up the Occupation to proceed.';
					return null;
				}

				/*if(objLead.RW_Company_Name__c == null || objLead.RW_Company_Name__c == '')
				{
					strError = 'Please fill up the Company Name to proceed.';
					return null;
				}

				if(objLead.RW_Company_Location__c == null || objLead.RW_Company_Location__c == '')
				{
					strError = 'Please fill up the Company Location to proceed.';
					return null;
				}

				if(objLead.RW_Designation__c == null || objLead.RW_Designation__c == '')
				{
					strError = 'Please fill up the Designation to proceed.';
					return null;
				}*/

				if(objLead.RW_Ethnicity__c == null || objLead.RW_Ethnicity__c == '')
				{
					strError = 'Please fill up the Ethnicity to proceed.';
					return null;
				}

				if(strDOB != null && strDOB != '')
				{
					objLead.RW_Date_of_Birth__c = date.Parse(strDOB);
				}

				if(objLead.RW_Budget_Rs_in_Cr__c != null)
				{
					objLead.RW_Budget_Rs_in_Cr__c = objLead.RW_Budget_Rs_in_Cr__c * 10000000;
				}
				if(objLead.LeadSource != null)
				{
					if(objLead.LeadSource == 'Corporate' && objLead.Corporate_Company__c == 'Other')
					{
						objLead.LeadSource = 'Corporate(Unregistered)';
					}
					
					if(objLead.LeadSource != 'Channel Partner')
					{
						objLead.RW_Apply_Unregistered_Broker__c = false;
						objLead.RW_Broker__c = null;
						objLead.RW_Unregistered_Broker_Name__c = null;
						objLead.RW_Unregistered_Broker_Email__c = null;
						objLead.RW_Unregistered_Broker_Mobile__c = null;
					}

					if(objLead.RW_Reference_Source__c != null && objLead.RW_Reference_Source__c != 'Existing Customer Reference' && objLead.LeadSource != 'Loyalty')
					{
						objLead.Customer_Reference__c = null;
					}

					if(objLead.LeadSource != 'Reference')
					{
						objLead.RW_Reference_Source__c = null;
					}

					if(objLead.LeadSource == 'Channel Partner' || objLead.LeadSource == 'Reference' || objLead.LeadSource == 'Corporate' ||
						objLead.LeadSource == 'Loyalty')
					{
						objLead.RW_Lead_Sub_Source__c = null;
					}

					if(objLead.LeadSource != 'Corporate')
					{
						objLead.Corporate_Company__c = null;
					}

					if(objLead.LeadSource != 'Corporate(Unregistered)')
					{
						objLead.NameofUnregisteredCorporate_LeadSource__c = null;
					}
				}
				else
				{
					strError = 'Error : Please select the Lead Source to proceed.';
					return null;
				}

				
				update objLead;

				if(UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t')
				{
					isSubmitted = true;
					return null;
				}
				else
				{
					Pagereference objReference = new Pagereference('/' + objLead.Id);
					objReference.setRedirect(true);
					return objReference;
				}

				//Pagereference objReference = new Pagereference('/apex/RWCIFFormForSM?id=' + objLead.Id);
				
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
		return null;
	}

	/*public PageReference GoBackToCIF()
	{
		Pagereference objReference = new Pagereference('/apex/RWCIFForm?id=' + objLead.Id);
		objReference.setRedirect(true);
		return objReference;
	}

	public PageReference finalSave()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			update objLead;

			Pagereference objReference = new Pagereference('/' + objLead.Id);
			objReference.setRedirect(true);
			return objReference;

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
	}*/
}