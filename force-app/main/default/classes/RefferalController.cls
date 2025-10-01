public class RefferalController
{
    @AuraEnabled
    public static List<wrapLeadRecord> getLeadFromSFDC() 
    {
        id AccountId=[Select accountId from User where id =: Userinfo.getUserid()].accountId;
        //ID contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
        //ID AccID  = [Select AccountID from Contact where id =: contactId].AccountId;
        List<wrapLeadRecord> lstwrapLeadRecord=new List<wrapLeadRecord>();
        List<Lead> listLead =[select LeadSource,LastName, Status,
                                     firstName,Customer_Reference__c,Email,RW_Mobile_No__c,RW_Reference_Source__c 
                                     from Lead where 
                                     Customer_Reference__c=:AccountId and isConverted =: false
									 order by createdDate desc];
        system.debug('listLead======'+listLead);
        if(listLead != null && listLead.size() > 0)
          {
            for(Lead ObjeLead:listLead)
            {
                 wrapLeadRecord objwrapLeadRecord=new wrapLeadRecord();
                 objwrapLeadRecord.LastName=ObjeLead.LastName;
                 objwrapLeadRecord.FirstName=ObjeLead.FirstName;
                 objwrapLeadRecord.Email=ObjeLead.Email;
                 objwrapLeadRecord.Mobile=ObjeLead.RW_Mobile_No__c;
                 objwrapLeadRecord.LeadSource=ObjeLead.LeadSource;
                objwrapLeadRecord.strStatus = ObjeLead.Status;
                 objwrapLeadRecord.RefferalSource=ObjeLead.RW_Reference_Source__c;
                 lstwrapLeadRecord.add(objwrapLeadRecord);
            }
            return lstwrapLeadRecord;
          }
           
        else
           return lstwrapLeadRecord;
                
    }
    @AuraEnabled
    public static List<wrapOpportunityRecord> getOpp() 
    {
    
       id AccountId=[Select accountId from User where id =: Userinfo.getUserid()].accountId;
       List<wrapOpportunityRecord> lstwrapOpportunityRecord = new List<wrapOpportunityRecord>();
       List<Opportunity> listOpportunity =[select LeadSource, Name, Customer_Reference__c, StageName, CloseDate,
                                           Id, RW_Redeem__c, RW_Reference_Source__c, RW_Mobile_No__c, RW_Email__c,
                                           RW_19_99_Received__c, Account.PersonEmail, RW_Approval_Status__c from 
										   Opportunity where Customer_Reference__c =: AccountId
										   order by createdDate desc];
       
       system.debug('listOpportunity======'+listOpportunity);
       // system.debug('listLead======'+listLead);
       if(listOpportunity != null && listOpportunity .size() > 0)
       {
            for(Opportunity ObjOpportunity:listOpportunity )
            {
                 wrapOpportunityRecord objwrapOpportunityRecord = new wrapOpportunityRecord();
                 objwrapOpportunityRecord.Name = ObjOpportunity.Name;
                 //objwrapOpportunityRecord.Email = ObjOpportunity.Email;
                 objwrapOpportunityRecord.StageName = ObjOpportunity.StageName;
                 objwrapOpportunityRecord.LeadSource = ObjOpportunity.LeadSource;
                 objwrapOpportunityRecord.strRefSource = ObjOpportunity.RW_Reference_Source__c;
                 objwrapOpportunityRecord.strMobile = ObjOpportunity.RW_Mobile_No__c;
                 objwrapOpportunityRecord.strEmail = ObjOpportunity.Account.PersonEmail;
                 objwrapOpportunityRecord.Id = ObjOpportunity.Id;
                 if(ObjOpportunity.RW_Approval_Status__c != null && ObjOpportunity.RW_Approval_Status__c == 'Approved' && !ObjOpportunity.RW_Redeem__c)
                 	objwrapOpportunityRecord.isBoolean = false;
                 else
                    objwrapOpportunityRecord.isBoolean = true;
                 lstwrapOpportunityRecord.add(objwrapOpportunityRecord);
            }
            return lstwrapOpportunityRecord;
        }
           
        else
           return lstwrapOpportunityRecord;
                
   }
    @AuraEnabled
    public static List<Opportunity> updateOpportunity(String oppId)
    {
       system.debug('oppId:===='+oppId); 
       List<Opportunity> lstOpp=[select Id,RW_Redeem__c,Customer_Reference__c from Opportunity where Id=:oppId];
       List<Account> lstAccount=new List<Account>();
       if(lstOpp<>null && lstOpp.size()>0)
           {
               lstAccount=[select Id,RW_Redeem__c,RW_Email__c from Account where id=:lstOpp[0].Customer_Reference__c ];
               if(lstAccount<>null && lstAccount.size()>0)
               {
                   
                   lstAccount[0].RW_Redeem__c =true;
                   lstAccount[0].RW_Email__c =[Select Email from User where id =: Userinfo.getUserid()].Email;
                   update lstAccount;
               }
               lstOpp[0].RW_Redeem__c=true;
               lstOpp[0].RW_19_99_Received__c=true;
               update lstOpp;
            
           }
       return lstOpp;
    }
    @AuraEnabled
    public static string insertLeadToServer(String LastName, String FirstName, String Mobile, String Email, string SelectedProject)
    {
        System.debug('@LastName_______________'+LastName);
		if(LastName == null || LastName == '')
		{
			return 'Error : Please enter the Last Name';
		}

		if(Mobile == null || Mobile == '')
		{
			return 'Error : Please enter the Mobile No.';
		}

		if(Email == null || Email == '')
		{
			return 'Error : Please enter the Email';
		}

		if(SelectedProject == null || SelectedProject == '')
		{
			return 'Error : Please enter the Project Interested';
		}

		try
		{
			User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];

			Lead objLead=new Lead();
			objLead.LastName = FirstName;
			objLead.FirstName = LastName;
			objLead.RW_Mobile_No__c=Mobile;
			objLead.LeadSource='Reference Source';
			objLead.RW_Reference_Source__c='Existing Customer Reference';
			objLead.Email = Email;
			objLead.Customer_Reference__c = objLoggedInUser.accountId;

			List<Opportunity> lstOpp = [select id, RW_Given_Reference_Name__c, RW_RM_Name__c from Opportunity where AccountId =: objLoggedInUser.accountId];
			
			if(lstOpp != null && lstOpp.size() > 0)
			{
				map<String, RM_Usernames__c> mapOfRM = RM_Usernames__c.getAll();
				for(Opportunity EachOpp : lstOpp)
				{
					EachOpp.RW_Given_Reference_Name__c = LastName+' '+FirstName;
					if(EachOpp.RW_RM_Name__c != null && mapOfRM.containsKey(EachOpp.RW_RM_Name__c))
					{
						EachOpp.RW_RM_Email__c = mapOfRM.get(EachOpp.RW_RM_Name__c).RW_Email__c;
					}
				}

				update lstOpp;
			}
			
			if(SelectedProject != null && SelectedProject != '')
			{
				list<Project__c> lstProj = [select id, name from Project__c where name =: SelectedProject];
				if(lstProj != null && lstProj.size() > 0)
				{
					objLead.RW_Project__c = lstProj[0].id;
				}
			}
			
			
			insert objLead;
			system.debug('objLead======'+objLead);

			return 'The reference has been successfully added.';
		}
		catch(exception ex)
		{
			string strTempError = '';
            if(ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true)
            {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            
            if(ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true)
            {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() +' : '+ ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }

			if(ex.getMessage() != null && ex.getMessage().contains('RW_Unique_Lead__c') == true)
			{
                strTempError = 'The lead with the given information already exist on the system.';
            }

            if(strTempError != '')
				return 'Error : '+strTempError;
            else
            {
                System.debug('errrrrrrr::: ' + ex.getMessage());
                return 'Error : '+ex.getMessage();
            }
		}
		return null;
        
    }
	@AuraEnabled
    public static List<String> getProjName()
	{
        list<Project__c> lstProj = [select id, name from Project__c limit 999];
		if(lstProj != null && lstProj.size() > 0)
		{
			list<string> lstProjNames = new list<string>();
			for(Project__c EachProj : lstProj)
			{
				lstProjNames.add(EachProj.name);
			}
			return lstProjNames;
		}
		
		return null;
    }
}