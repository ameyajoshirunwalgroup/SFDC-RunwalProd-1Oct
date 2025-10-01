public without sharing class DocumentComponentController 
{
	@AuraEnabled
    public static List<string> fetchDocuments() 
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
    public static string fetchLedgerDate(string strSelectedUnit) 
    {
        User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

		List<Opportunity> lstOpp = [Select Id, RW_Ledger_Valid_To__c from Opportunity
										where RW_Project_Unit__r.name =: strSelectedUnit
										and AccountId =: objLoggedInUser.accountId];

		if(lstOpp != null && lstOpp.size() > 0)
		{
			return lstOpp[0].RW_Ledger_Valid_To__c.format('YYYY-MM-DD hh:mm:ss');
		}
		
		return null;
    }
    
    @AuraEnabled
    public static string GoToDocuments()
    {
		User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
        
        list<attachment> lstAtt = [select id from attachment where parentId =: objLoggedInUser.accountId and name =: 'test.pdf'];

        string attid = '/servlet/servlet.FileDownload?file='+lstAtt[0].id;
        return attid;
    } 

	@AuraEnabled
    public static list<WrapPortalDocument> FetchAllPortalDocuments()
    {
		User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
		if(objLoggedInUser.accountId != null)
		{
			list<Attachment> lstAllAttachment = [select id, name, Description, CreatedDate from Attachment where 
													parentId =: objLoggedInUser.accountId];
													
			System.debug('@lstAllAttachment______'+lstAllAttachment);
			if(lstAllAttachment != null && lstAllAttachment.size() > 0)
			{
				list<WrapPortalDocument> lstWrapAtt = new list<WrapPortalDocument>();
				for(Attachment EachAtt : lstAllAttachment)
				{
					if(EachAtt.Description != null && EachAtt.Description.contains('Portal Upload : '))
					{
						WrapPortalDocument objWrap = new WrapPortalDocument();
						objWrap.strAttName = EachAtt.name;
						objWrap.strAttId = '/servlet/servlet.FileDownload?file='+EachAtt.id;
						objWrap.strCreatedDate = String.valueOf(EachAtt.CreatedDate);
						objWrap.strAttDescr = EachAtt.Description.replace('Portal Upload : ', '');
						lstWrapAtt.add(objWrap);
					}
				}
				if(lstWrapAtt.size() > 0)
					return lstWrapAtt;
			}
		}
		return null;
	}
    
    @AuraEnabled
    public static string UploadAttachments(String fileName, String base64Data, String contentType, String strSelectedUnit, string DocumentName)
    {
		try
		{
			//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
			User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
			if(objLoggedInUser.accountId != null)
			{
				base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
				Attachment a = new Attachment();
				a.parentId = objLoggedInUser.accountId;

				a.Body = EncodingUtil.base64Decode(base64Data);
				a.Name = fileName;
				a.ContentType = contentType;
				a.Description = 'Portal Upload : '+DocumentName+' uploaded for '+strSelectedUnit+' Unit';
        
				insert a;

				list<Opportunity> lstOpp = [select Id, RW_Form_16B_TDS_Certificate_Submitted__c, RW_Other_Document_Submitted__c, 
											RW_Payment_Details_Submitted__c, RW_Bank_Loan_Sanction_Letter_Submitted__c, RW_RM_Name__c,
											RW_RM_Email__c from Opportunity where RW_Project_Unit__r.name =: strSelectedUnit
											and accountId =: objLoggedInUser.accountId];

				if(lstOpp != null && lstOpp.size() > 0)
				{
					if(DocumentName == 'Form 16B(TDS Certificate)')
						lstOpp[0].RW_Form_16B_TDS_Certificate_Submitted__c = System.now();
					if(DocumentName == 'Payment Details')
						lstOpp[0].RW_Payment_Details_Submitted__c = System.now();
					if(DocumentName == 'Bank Loan Sanction Letter')
						lstOpp[0].RW_Bank_Loan_Sanction_Letter_Submitted__c = System.now();
					if(DocumentName == 'Other')
						lstOpp[0].RW_Other_Document_Submitted__c = System.now();

					map<String, RM_Usernames__c> mapOfRM = RM_Usernames__c.getAll();
					if(lstOpp[0].RW_RM_Name__c != null && mapOfRM.containsKey(lstOpp[0].RW_RM_Name__c))
						lstOpp[0].RW_RM_Email__c = mapOfRM.get(lstOpp[0].RW_RM_Name__c).RW_Email__c;
					
					update lstOpp[0];
				}
				return 'Document is successfully added.';
			}
			else
			{
				return 'Error : No Account found, Please contact your representative.';
			}
		}
		catch(exception ex)
		{
			return 'Error : '+ex.getMessage();
		}
    }
    
	//this method is used for the demand letter pdf generate.
    @AuraEnabled
    public static list<string> ViewDemandLetterDocs(String strSelectedUnit)
    {
        try
		{
			System.debug('@strSelectedUnit______'+strSelectedUnit);
			List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
		
       
			
			string strUserToken = fetchTokenNumber();
			if(strUserToken != null)
			{
				map<String, RW_Portal_Endpoint_URL__c> mapOfURL = RW_Portal_Endpoint_URL__c.getall();
				User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
	
				//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

				List<Opportunity> lstOpp = [select id, RW_Project_Unit__c from Opportunity where 
												RW_Project_Unit__r.name =: strSelectedUnit
												and AccountId =: objLoggedInUser.accountId];
					
				if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].RW_Project_Unit__c != null)
				{
					String strSecKey = fvSettings[0].FV_SecurityKey__c;
					String strLoginId = fvSettings[0].FV_UserID__c;
					String strOppCode = lstOpp[0].id;
					//String strOppCode = '0062800000AJQP2AAP';
					String strEndPoint = mapOfURL.get('DemandLetter').RW_URL__c;

					String strBody = '{ SecurityKey:"'+strSecKey+'", UserToken:"'+strUserToken+'", LoginID:"'+strLoginId+'", OPPORTUNITYCODE:"'+strOppCode+'"}';
					
					System.debug('strBody=================='+ strBody);

					Http htp = new Http();
					HTTPRequest  req1 = new HTTPRequest();
					req1.setHeader('Content-Type','application/json; charset=UTF-8');
					req1.setEndpoint(strEndPoint);
					req1.setMethod('POST');    
					req1.setbody(strBody);
					req1.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
					
					string ResponseString = '';
					WrapPortalData objResp = new WrapPortalData();
					if(!Test.isRunningTest())
					{
						HttpResponse res1 = htp.send(req1);
						ResponseString = res1.getBody();
						System.debug('ResponseString======2=================='+ ResponseString);
						objResp = WrapPortalData.parse(ResponseString);
					}
					
					else
					{
						ResponseString = 'Test';
						list<WrapPortalData.wrapPDFData> lstWrapData = new list<WrapPortalData.wrapPDFData>();
						WrapPortalData.wrapPDFData objWrapData = new WrapPortalData.wrapPDFData();
						objWrapData.DEMAND_PDF_STRING = 'Test';
						lstWrapData.add(objWrapData);
						objResp.CustDemandPDF = lstWrapData;
					}

					
					System.debug('objResp=================='+ objResp);

					if(objResp.CustDemandPDF != null && objResp.CustDemandPDF.size() > 0)
					{
						List<string> lstDemandPdf = new List<string>();
						for(WrapPortalData.wrapPDFData EachString : objResp.CustDemandPDF)
						{
							//strDemandPdf = strDemandPdf.concat(EachString.DEMAND_PDF_STRING);
							System.debug('EachString________'+EachString.DEMAND_PDF_STRING);
							lstDemandPdf.add(EachString.DEMAND_PDF_STRING);
						}
						System.debug('@lstDemandPdf________'+lstDemandPdf);
						return lstDemandPdf;
						//return objResp.CustDemandPDF[0].DEMAND_PDF_STRING;
					}
					else
						return null;

				}
				else
					return null;
			}
			
		}
		catch(exception ex)
		{
			//return 'Error - '+ex.getMessage();
			return null;
		}
        return null;
    }

	//this method is used for the Money Receipt pdf generate.
    @AuraEnabled
    public static list<string> ViewGenMoneyReceipt(String strSelectedUnit)
    {
        try
		{
			System.debug('@strSelectedUnit______'+strSelectedUnit);
			List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
		
       
			string strUserToken = fetchTokenNumber();
			if(strUserToken != null)
			{
				map<String, RW_Portal_Endpoint_URL__c> mapOfURL = RW_Portal_Endpoint_URL__c.getall();
				User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
	
				//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

				List<Opportunity> lstOpp = [select id, RW_Project_Unit__c from Opportunity where 
												RW_Project_Unit__r.name =: strSelectedUnit
												and AccountId =: objLoggedInUser.accountId];
					
				if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].RW_Project_Unit__c != null)
				{
					String strSecKey = fvSettings[0].FV_SecurityKey__c;
					String strLoginId = fvSettings[0].FV_UserID__c;
					String strOppCode = lstOpp[0].id;
					//String strOppCode = '00628000008bRpVAAU';
					String strEndPoint = mapOfURL.get('MoneyReceipt').RW_URL__c;

					String strBody = '{ SecurityKey:"'+strSecKey+'", UserToken:"'+strUserToken+'", LoginID:"'+strLoginId+'", OPPORTUNITYCODE:"'+strOppCode+'"}';
					
					Http htp = new Http();
					HTTPRequest  req1 = new HTTPRequest();
					req1.setHeader('Content-Type','application/json; charset=UTF-8');
					req1.setEndpoint(strEndPoint);
					req1.setMethod('POST');    
					req1.setbody(strBody);
					req1.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
					
					string ResponseString = '';
					
					WrapPortalData objResp = new WrapPortalData();
					if(!Test.isRunningTest())
					{
					
						HttpResponse res1 = htp.send(req1);
						ResponseString = res1.getBody();
						objResp = WrapPortalData.parse(ResponseString);
						System.debug('ResponseString======2=================='+ ResponseString);
					}

					else
					{
						ResponseString = 'Test';
						list<WrapPortalData.wrapPDFData> lstWrapData = new list<WrapPortalData.wrapPDFData>();
						WrapPortalData.wrapPDFData objWrapData = new WrapPortalData.wrapPDFData();
						objWrapData.MR_PDF_STRING = 'Test';
						lstWrapData.add(objWrapData);
						objResp.CustMoneyReceiptPDF = lstWrapData;
					}
					
					//objResp = WrapPortalData.parse(ResponseString);
					System.debug('objResp=================='+ objResp);

					if(objResp.CustMoneyReceiptPDF != null && objResp.CustMoneyReceiptPDF.size() > 0)
					{
						List<string> lstDemandPdf = new List<string>();
						for(WrapPortalData.wrapPDFData EachString : objResp.CustMoneyReceiptPDF)
						{
							lstDemandPdf.add(EachString.MR_PDF_STRING);
						}
						return lstDemandPdf;
					}
					else
						return null;

				}
				else
					return null;
			}
		}
		catch(exception ex)
		{
			return null;
		}
        return null;
    }

	//this method is used for the Allotment letter pdf generate.
    @AuraEnabled
    public static list<string> ViewAllotmentLetterDocs(String strSelectedUnit)
    {
        try
		{
			System.debug('@strSelectedUnit______'+strSelectedUnit);
			List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
		
       
			string strUserToken = fetchTokenNumber();
			if(strUserToken != null)
			{
				map<String, RW_Portal_Endpoint_URL__c> mapOfURL = RW_Portal_Endpoint_URL__c.getall();
				User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
	
				//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

				List<Opportunity> lstOpp = [select id, RW_Project_Unit__c from Opportunity where 
												RW_Project_Unit__r.name =: strSelectedUnit
												and AccountId =: objLoggedInUser.accountId];
					
				if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].RW_Project_Unit__c != null)
				{
					String strSecKey = fvSettings[0].FV_SecurityKey__c;
					String strLoginId = fvSettings[0].FV_UserID__c;
					String strOppCode = lstOpp[0].id;
					//String strOppCode = '00628000008bRpVAAU';
					String strEndPoint = mapOfURL.get('AllotmentLetter').RW_URL__c;

					String strBody = '{ SecurityKey:"'+strSecKey+'", UserToken:"'+strUserToken+'", LoginID:"'+strLoginId+'", OPPORTUNITYCODE:"'+strOppCode+'"}';
					
					System.debug('strBody=================='+ strBody);

					Http htp = new Http();
					HTTPRequest  req1 = new HTTPRequest();
					req1.setHeader('Content-Type','application/json; charset=UTF-8');
					req1.setEndpoint(strEndPoint);
					req1.setMethod('POST');    
					req1.setbody(strBody);
					req1.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
					
					string ResponseString = '';
					WrapPortalData objResp = new WrapPortalData();
					
                    if(!Test.isRunningTest())
					{
						HttpResponse res1 = htp.send(req1);
						ResponseString = res1.getBody();
						objResp = WrapPortalData.parse(ResponseString);
						System.debug('ResponseString======2=================='+ ResponseString);
					}
					
					else
					{
						ResponseString = 'Test';
						list<WrapPortalData.wrapPDFData> lstWrapData = new list<WrapPortalData.wrapPDFData>();
						WrapPortalData.wrapPDFData objWrapData = new WrapPortalData.wrapPDFData();
						objWrapData.Allot_PDF_STRING = 'Test';
						lstWrapData.add(objWrapData);
						objResp.CustAllotPDF = lstWrapData;
					}
					
					//objResp = WrapPortalData.parse(ResponseString);
					System.debug('objResp=================='+ objResp);

					if(objResp.CustAllotPDF != null && objResp.CustAllotPDF.size() > 0)
					{
						List<string> lstAllotPdf = new List<string>();
						for(WrapPortalData.wrapPDFData EachString : objResp.CustAllotPDF)
						{
							lstAllotPdf.add(EachString.Allot_PDF_STRING);
						}
						return lstAllotPdf;
					}
					else
						return null;

				}
				else
					return null;
			}
		}
		catch(exception ex)
		{
			return null;
		}
        return null;
    }

	//this method is used for the Reminder letter pdf generate.
    @AuraEnabled
    public static list<string> ViewReminderLetterDocs(String strSelectedUnit)
    {
        try
		{
			System.debug('@strSelectedUnit______'+strSelectedUnit);
			List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
		
			string strUserToken = fetchTokenNumber();
			if(strUserToken != null)
			{
				map<String, RW_Portal_Endpoint_URL__c> mapOfURL = RW_Portal_Endpoint_URL__c.getall();
				User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
	
				//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];

				List<Opportunity> lstOpp = [select id, RW_Project_Unit__c from Opportunity where 
												RW_Project_Unit__r.name =: strSelectedUnit
												and AccountId =: objLoggedInUser.accountId];
					
				if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].RW_Project_Unit__c != null)
				{
					String strSecKey = fvSettings[0].FV_SecurityKey__c;
					String strLoginId = fvSettings[0].FV_UserID__c;
					String strOppCode = lstOpp[0].id;
					//String strOppCode = '00628000008bRpVAAU';
					String strEndPoint = mapOfURL.get('ReminderLetter').RW_URL__c;

					String strBody = '{ SecurityKey:"'+strSecKey+'", UserToken:"'+strUserToken+'", LoginID:"'+strLoginId+'", OPPORTUNITYCODE:"'+strOppCode+'"}';
					
					System.debug('strBody=================='+ strBody);

					Http htp = new Http();
					HTTPRequest  req1 = new HTTPRequest();
					req1.setHeader('Content-Type','application/json; charset=UTF-8');
					req1.setEndpoint(strEndPoint);
					req1.setMethod('POST');    
					req1.setbody(strBody);
					req1.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
					
					string ResponseString = '';
					WrapPortalData objResp = new WrapPortalData();
					
                    if(!Test.isRunningTest())
					{	
						HttpResponse res1 = htp.send(req1);
						ResponseString = res1.getBody();
						objResp = WrapPortalData.parse(ResponseString);
						System.debug('ResponseString======2=================='+ ResponseString);
					}
					
					else
					{
						ResponseString = 'Test';
						list<WrapPortalData.wrapPDFData> lstWrapData = new list<WrapPortalData.wrapPDFData>();
						WrapPortalData.wrapPDFData objWrapData = new WrapPortalData.wrapPDFData();
						objWrapData.Reminder_PDF_STRING = 'Test';
						lstWrapData.add(objWrapData);
						objResp.CustReminderPDF = lstWrapData;
					}
					
					//objResp = WrapPortalData.parse(ResponseString);
					System.debug('objResp=================='+ objResp);

					if(objResp.CustReminderPDF != null && objResp.CustReminderPDF.size() > 0)
					{
						List<string> lstRemnPdf = new List<string>();
						for(WrapPortalData.wrapPDFData EachString : objResp.CustReminderPDF)
						{
							lstRemnPdf.add(EachString.Reminder_PDF_STRING);
						}
						return lstRemnPdf;
					}
					else
						return null;

				}
				else
					return null;
			}
		}
		catch(exception ex)
		{
			return null;
		}
        return null;
    }

	//this method is used for the aplicant ledger detail.
    @AuraEnabled
    public static List<string> ApplicantLedgerGenerate(String strSelectedUnit)
    {
		List<String> lstReturn = new List<String>();
	    try
		{
			System.debug('@strSelectedUnit______'+strSelectedUnit);

			//User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
			User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];

			List<Opportunity> lstOpp = [select id, RW_Project_Unit__c, RW_Customer_Applied_for_Applicant_Ledger__c,
											RW_Applicant_Ledger_Generated__c, RW_Ledger_Valid_To__c from Opportunity where 
											RW_Project_Unit__r.name =: strSelectedUnit
											and AccountId =: objLoggedInUser.accountId];

			if(lstOpp != null && lstOpp.size() > 0)
			{
				if(lstOpp[0].RW_Customer_Applied_for_Applicant_Ledger__c && !lstOpp[0].RW_Applicant_Ledger_Generated__c)
				{
					lstReturn.add('Alert : You have already applied for the Ledger. We will notify you after the Ledger generated.');
					return lstReturn;
				}

				if((lstOpp[0].RW_Customer_Applied_for_Applicant_Ledger__c && lstOpp[0].RW_Applicant_Ledger_Generated__c &&
							lstOpp[0].RW_Ledger_Valid_To__c < System.now()) || //if the ledger is expired
							!lstOpp[0].RW_Customer_Applied_for_Applicant_Ledger__c) // OR the customer hasn't applied
				{
					lstOpp[0].RW_Customer_Applied_for_Applicant_Ledger__c = true; // Notification to RM and Customer
					lstOpp[0].RW_Ledger_Valid_To__c = null; //valid to date null
					lstOpp[0].RW_Applicant_Ledger_Generated__c = false; //Applicant ledger to unchecked, SM manual check on this
					update lstOpp[0];

					lstReturn.add('Alert : You have successfully applied for the Ledger. It will take 7 days to generate.');
					return lstReturn;
				}

				if(lstOpp[0].RW_Customer_Applied_for_Applicant_Ledger__c && lstOpp[0].RW_Applicant_Ledger_Generated__c
					&& lstOpp[0].RW_Ledger_Valid_To__c >= System.now())
				{
					List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
					
					string strUserToken = fetchTokenNumber();
					if(strUserToken != null)
					{
						map<String, RW_Portal_Endpoint_URL__c> mapOfURL = RW_Portal_Endpoint_URL__c.getall();
						//User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
					
						if(lstOpp != null && lstOpp.size() > 0 && lstOpp[0].RW_Project_Unit__c != null)
						{
							String strSecKey = fvSettings[0].FV_SecurityKey__c;
							String strLoginId = fvSettings[0].FV_UserID__c;
							String strOppCode = lstOpp[0].id;
							//String strOppCode = '00628000008bRpVAAU';
							String strEndPoint = mapOfURL.get('ApplicantLedger').RW_URL__c;

							String strBody = '{ SecurityKey:"'+strSecKey+'", UserToken:"'+strUserToken+'", LoginID:"'+strLoginId+'", OPPORTUNITYCODE:"'+strOppCode+'"}';
					
							System.debug('strBody=================='+ strBody);

							Http htp = new Http();
							HTTPRequest  req1 = new HTTPRequest();
							req1.setHeader('Content-Type','application/json; charset=UTF-8');
							req1.setEndpoint(strEndPoint);
							req1.setMethod('POST');    
							req1.setbody(strBody);
							req1.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
					
							string ResponseString = '';
							WrapPortalData objResp = new WrapPortalData();
							
                            if(!Test.isRunningTest())
							{
								HttpResponse res1 = htp.send(req1);
								ResponseString = res1.getBody();
								objResp = WrapPortalData.parse(ResponseString);
								System.debug('ResponseString======2=================='+ ResponseString);
							}
							
							else
							{
								ResponseString = 'Test';
								list<WrapPortalData.wrapPDFData> lstWrapData = new list<WrapPortalData.wrapPDFData>();
								WrapPortalData.wrapPDFData objWrapData = new WrapPortalData.wrapPDFData();
								objWrapData.APPLICANTLEDGER_PDF_STRING = 'Test';
								lstWrapData.add(objWrapData);
								objResp.CustApplicantLedgerPDF = lstWrapData;
							}

							//objResp = WrapPortalData.parse(ResponseString);
							System.debug('objResp=================='+ objResp);

							if(objResp.CustApplicantLedgerPDF != null && objResp.CustApplicantLedgerPDF.size() > 0)
							{
								List<string> lstRemnPdf = new List<string>();
								for(WrapPortalData.wrapPDFData EachString : objResp.CustApplicantLedgerPDF)
								{
									lstRemnPdf.add(EachString.APPLICANTLEDGER_PDF_STRING);
								}
								return lstRemnPdf;
							}
							else
							{
								lstReturn.add('Alert : Applicant leadger not available, Please cotntact your Admin');
								return lstReturn;
							}

						}
						else
						{
							lstReturn.add('Alert : No Booked Id Found.');
							return lstReturn;
						}
					}
				}
			}
			
		}
		catch(exception ex)
		{
			lstReturn.add('Alert : '+ex.getMessage());
			return lstReturn;
		}
        return null;
    }

	//this method is to get the token number after user auth api
	public static string fetchTokenNumber()
	{
		List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
		FarvisionAuthResponse objFarvisionAuthResponse = new FarvisionAuthResponse();        
        string endPointURL = fvSettings[0].FV_Authenticate_User__c;
        string requestMessage = '{ SecurityKey:"'+fvSettings[0].FV_SecurityKey__c+'", UserID:"'+fvSettings[0].FV_UserID__c+'", Password:"'+fvSettings[0].FV_Password__c+'"}';
        
        system.debug('requestMessage-----' + requestMessage);
        Http h = new Http();
        HTTPRequest  req = new HTTPRequest();
        req.setHeader('Content-Type','application/json; charset=UTF-8');
        req.setEndpoint(endPointURL);
        req.setMethod('POST');    
        req.setbody(requestMessage);
        req.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
		
		if(!Test.isRunningTest())
        {
			String ResponseString = '';
			HttpResponse res = h.send(req);
            ResponseString = res.getBody();
        
            System.debug('ResponseString=====1==================='+ ResponseString);
			if(ResponseString != '' )  
            {
               objFarvisionAuthResponse = FarvisionAuthResponse.parse(ResponseString);
            }

			if(objFarvisionAuthResponse != null)
            {
                if(objFarvisionAuthResponse.ErrorCode == Response.Success.ordinal())
                {
                    if(objFarvisionAuthResponse.UserInfo[0].UserToken !=null && objFarvisionAuthResponse.UserInfo[0].UserToken != '')
                    {
						return objFarvisionAuthResponse.UserInfo[0].UserToken;
					}
				}
			}
		}
		else
		{
			return 'test';
		}

		return null;
	}

	//this method is used to get the latest constuction stage
    @AuraEnabled
	public static string viewLatestConstructionStage(string strSelectedUnit)
	{
		try
		{
			if(strSelectedUnit != null && strSelectedUnit != '')
			{
				List<Project_Unit__c> lsProj = [select id, name, RW_Project__c from Project_Unit__c where name =: strSelectedUnit];
				if(lsProj != null && lsProj.size() > 0)
				{
					list<RW_Construction_Stage__c> lstProjConStage = [select id, name, RW_Sequence_No__c, RW_Project__c, (select id from attachments) from 
                                                                        RW_Construction_Stage__c where RW_Project__c =: lsProj[0].RW_Project__c and 
																		RW_Sequence_No__c != null order by RW_Sequence_No__c desc limit 1];

					if(lstProjConStage != null && lstProjConStage.size() > 0)
					{
						if(lstProjConStage[0].attachments != null && lstProjConStage[0].attachments.size() > 0)
						{
							return '/servlet/servlet.FileDownload?file='+lstProjConStage[0].attachments[0].id;
						}
						else
							return 'Error : No construction stage document found.';
					}
					else
						return 'Error : No construction stage found.';
				}
				else
				{
					return 'Error : No Project tagged. Please connect your representative';
				}
			}
			else
			{
				return 'Error : Please select an unit to proceed.';
			}
		}
		catch(exception ex)
		{
			return 'Error - '+ex.getMessage();
		}
        return null;
	}

	
	public enum Response {
        Success,
        Error
    }
}