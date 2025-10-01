global class FarvisionApiConfiguration
{
    @future(callout=true)
    public static void CreateApplicationInFarvision(set<Id> OpportunityIds)
    { 
        string ResponseString = '';
        string emptyContent = '';
        decimal defaultAnnualIncome = 0.00;  
        List<Opportunity> objOpportunities = new List<Opportunity>();
        List<Farvision_API_Settings__c> fvSettings = Farvision_API_Settings__c.getall().values();
        
        if(fvSettings.size() == 0)
            system.debug('Please create custom settings to consume farvision API');
        
        if(OpportunityIds.size() > 0)
        {
            objOpportunities = [Select Zip_Code__c, Walkin_SubSource__c, Walkin_Source__c, Type, SystemModstamp, SyncedQuoteId, 
                                        Street__c, State__c, StageName, Remark__c, RW_Walk_in_Source__c, RW_Unregistered_Broker_Name__c, 
                                        RW_Unregistered_Broker_Mobile__c, RW_Unregistered_Broker_Email__c, RW_Unit_Rate__c, 
                                        RW_Unit_Area__c, RW_Type_of_Parking__c, RW_Time_line__c, RW_Sourcing_Manager__c, 
                                        RW_Site_Visit_Completion__c, RW_Secondary_Mobile_No__c, RW_Secondary_Email__c, 
                                        RW_Sales_Manager_Comment__c, RW_Sales_Associate__c, RW_Referral_Details__c, 
                                        RW_Reference_Source__c, RW_Reason_for_Unqualified__c, RW_Reason_for_Closed_Lost__c, 
                                        RW_Rating__c, RW_Project__r.Name, RW_Project_Unit__c, RW_Pre_Sales_User__c, RW_Phone_No__c, 
                                        RW_Passport_Received__c, RW_Passport_Number__c, RW_PAN_Card_Received__c, RW_PAN_Card_Number__c, 
                                        RW_Others__c, RW_Number_of_Visits__c, RW_Number_of_Parking__c, RW_Mobile_No__c, 
                                        RW_Missed_Call__c, RW_Location__c, RW_Email__c, RW_Configuration__c, RW_Co_Owner_Name__c, 
                                        RW_Call_Completion__c, RW_Budget__c, RW_Broker__c, RW_Booking_Source__c, 
                                        RW_Apply_Unregistered_Broker__c, RW_Agreement_Value__c, RW_AADHAR_Card_Received__c, 
                                        RW_AADHAR_Card_Number__c, Probability, Pricebook2Id, OwnerId, NextStep, Name, 
                                        Lead_Sub_Source__c, Lead_Source_to_acc__c, LeadSource, LastViewedDate, LastReferencedDate, 
                                        LastModifiedDate, LastModifiedById, LastActivityDate, IsWon, IsDeleted, IsClosed, Id, 
                                        HasOpportunityLineItem, ForecastCategoryName, ForecastCategory, FiscalYear, FiscalQuarter, 
                                        Fiscal, First_Site_Visit_Date__c, Expected_Date_of_Closure1__c, Description, 
                                        Customer_Reference__c, CreatedDate, CreatedById, Country__c, Corporate_Company__c, CloseDate, 
                                        City__c, CampaignId, Amount, AccountId, Account.Name, Account.Salutation, Account.FirstName,
                                        Account.LastName, Account.Birth_Date__c, 
                                        Account.BillingStreet,Account.BillingCountry, Account.BillingState, Account.BillingCity, 
                                        Account.BillingPostalCode,
                                        Account.ShippingStreet, Account.ShippingCountry, Account.ShippingState, Account.ShippingCity, 
                                        Account.ShippingPostalCode, Account.Organization_Name__c 
                                From Opportunity 
                                where Id in: OpportunityIds];
        }
        
        system.debug('CreateApplicationInFarvision - objOpportunity======' + objOpportunities);
        
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
            HttpResponse res = h.send(req);
            ResponseString = res.getBody();
        
            System.debug('ResponseString========================'+ ResponseString);
        
            if(ResponseString != '' )  
            {
               objFarvisionAuthResponse = FarvisionAuthResponse.parse(ResponseString);
            }

            system.debug('objFarvisionAuthResponse==============' + objFarvisionAuthResponse);
            Datetime myDateTime = Datetime.newInstance(1753, 1, 1);
            map<Id,FarvisionAuthResponse> mapFarvisionApplicants = new map<Id,FarvisionAuthResponse>();
         
            if(objFarvisionAuthResponse != null)
            {
                if(objFarvisionAuthResponse.ErrorCode == Response.Success.ordinal())
                {
            
                    if(objFarvisionAuthResponse.UserInfo[0].UserToken !=null && objFarvisionAuthResponse.UserInfo[0].UserToken != '')
                    {
                        string userToken = objFarvisionAuthResponse.UserInfo[0].UserToken;
                        string insertLeadEndPoint = fvSettings[0].FV_Create_Application__c;    
                    
                        system.debug('UserToken==============' + userToken);
                   
                        for(Opportunity objOpportunity : objOpportunities)
                        {
                            FarvisionLead objFarvisionApplicant = new FarvisionLead();
                            objFarvisionAuthResponse = new FarvisionAuthResponse();
                        
                            ResponseString = '';
                            h = new Http();
                            req = new HTTPRequest();
                        
                            req.setHeader('Content-Type','application/json; charset=UTF-8');
                            req.setEndpoint(insertLeadEndPoint);
                            req.setMethod('POST');    
                            req.setTimeout(integer.valueof(fvSettings[0].Timeout__c));
                       
                            objFarvisionApplicant.SecurityKey = fvSettings[0].FV_SecurityKey__c;
                            objFarvisionApplicant.UserToken = userToken;
                            objFarvisionApplicant.LoginID = fvSettings[0].FV_UserID__c;
                            objFarvisionApplicant.AppDt =   Date.today(); //objOpportunity.CreatedDate;
                            objFarvisionApplicant.Project = CheckNull(objOpportunity.RW_Project__r.Name);
                            objFarvisionApplicant.Applicant  =  CheckNull(objOpportunity.Name);
                            objFarvisionApplicant.AppSalutation  =  CheckNull(objOpportunity.Account.Salutation);
                            objFarvisionApplicant.ApplicantFirstName  =  CheckNull(objOpportunity.Account.FirstName);
                            objFarvisionApplicant.ApplicantMiddleName  = emptyContent;
                            objFarvisionApplicant.ApplicantLastName   =  CheckNull(objOpportunity.Account.LastName);
                            objFarvisionApplicant.ApplicantGender   = emptyContent;
                            objFarvisionApplicant.RelationType = emptyContent;
                            objFarvisionApplicant.RelativeName  = emptyContent;
                            objFarvisionApplicant.DOB = objOpportunity.Account.Birth_Date__c == null ? myDateTime : objOpportunity.Account.Birth_Date__c;
                            objFarvisionApplicant.OpportunityCode  =  CheckNull(objOpportunity.Id);
                            objFarvisionApplicant.Nationality = emptyContent;
                            objFarvisionApplicant.ResidentStatus  = emptyContent;
                            objFarvisionApplicant.PanNo  =  CheckNull(objOpportunity.RW_PAN_Card_Number__c);
                            objFarvisionApplicant.PassportNo  =  CheckNull(objOpportunity.RW_Passport_Number__c);
                            objFarvisionApplicant.CorrSpondAddress1  =  CheckNull(objOpportunity.Account.ShippingStreet);
                            objFarvisionApplicant.CorrSpondAddress2  = emptyContent;
                            objFarvisionApplicant.CorrSpondAddress3  = emptyContent;
                            objFarvisionApplicant.CorrSpondCountry   =  CheckNull(objOpportunity.Account.ShippingCountry);
                            objFarvisionApplicant.CorrSpondState   =  CheckNull(objOpportunity.Account.ShippingState);
                            objFarvisionApplicant.CorrSpondCity   =  CheckNull(objOpportunity.Account.ShippingCity);
                            objFarvisionApplicant.CorrSpondPinCode   =  CheckNull(objOpportunity.Account.ShippingPostalCode);
                            objFarvisionApplicant.CorrSpondAddFull   = emptyContent;
                            objFarvisionApplicant.CorrSpondPh1   = CheckNull(objOpportunity.RW_Phone_No__c);
                            objFarvisionApplicant.CorrSpondPh2    = CheckNull(objOpportunity.RW_Secondary_Mobile_No__c);
                            objFarvisionApplicant.CorrSpondMob    = CheckNull(objOpportunity.RW_Mobile_No__c);
                            objFarvisionApplicant.CorrSpondFax    = emptyContent;
                            objFarvisionApplicant.CorrSpondEmail    = CheckNull(objOpportunity.RW_Email__c);
                            objFarvisionApplicant.PermanentAddress1   =  CheckNull(objOpportunity.Account.BillingStreet);
                            objFarvisionApplicant.PermanentAddress2   = emptyContent;
                            objFarvisionApplicant.PermanentAddress3   = emptyContent;
                            objFarvisionApplicant.PermanentCountry   =  CheckNull(objOpportunity.Account.BillingCountry);
                            objFarvisionApplicant.PermanentState   =  CheckNull(objOpportunity.Account.BillingState);
                            objFarvisionApplicant.PermanentCity   =  CheckNull(objOpportunity.Account.BillingCity);
                            objFarvisionApplicant.PermanentPinCode   =  CheckNull(objOpportunity.Account.BillingPostalCode);
                            objFarvisionApplicant.PermanentAddressFull   = emptyContent;
                            objFarvisionApplicant.PermanentPhone1   =  emptyContent;
                            objFarvisionApplicant.PermanentPhone2   =  emptyContent;
                            objFarvisionApplicant.PermanentMobNo     =  emptyContent;
                            objFarvisionApplicant.PermanentFaxNo    = emptyContent;
                            objFarvisionApplicant.Occupation    = emptyContent;
                            objFarvisionApplicant.AnnualIncome     = defaultAnnualIncome;
                            objFarvisionApplicant.Designation     = emptyContent;
                            objFarvisionApplicant.Company    =  CheckNull(objOpportunity.Account.Organization_Name__c);
                            objFarvisionApplicant.OfficeAddress1     = emptyContent;
                            objFarvisionApplicant.OfficeAddress2     = emptyContent;
                            objFarvisionApplicant.OfficeAddress3     = emptyContent;
                            objFarvisionApplicant.OfficeCountry     = emptyContent;
                            objFarvisionApplicant.OfficeState     = emptyContent;
                            objFarvisionApplicant.OfficeCity      = emptyContent;
                            objFarvisionApplicant.OfficePinCode      = emptyContent;
                            objFarvisionApplicant.OfficePh1      = emptyContent;
                            objFarvisionApplicant.OfficePh2      = emptyContent;
                            objFarvisionApplicant.OfficeFax      = emptyContent;
                            objFarvisionApplicant.OfficeEmail    =  emptyContent;
                            objFarvisionApplicant.CoAppName    =  CheckNull(objOpportunity.RW_Co_Owner_Name__c);
                            objFarvisionApplicant.SalesPersonName    =  CheckNull(objOpportunity.RW_Sales_Associate__c);
                        
                            string jsonRequest = System.JSON.serialize(objFarvisionApplicant);
                            system.debug('jsonRequest=====' + jsonRequest);
                        
                            req.setbody(jsonRequest);
                            res = h.send(req);
                        
                            ResponseString = res.getBody();
                        
                            system.debug('ResponseString====='  + ResponseString);
                            if(ResponseString != '')  
                            {
                               objFarvisionAuthResponse = FarvisionAuthResponse.parse(ResponseString);
                            }
                        
                            if(objFarvisionAuthResponse.ErrorCode == Response.Success.ordinal())
                            {
                                system.debug('ApplicantID==============' + objFarvisionAuthResponse.ApplicantID);
                                mapFarvisionApplicants.put(objOpportunity.Id,objFarvisionAuthResponse);
                            }
                            else
                            {
                                system.debug('StatusMessage==============' + objFarvisionAuthResponse.StatusMessage);
                            }
                        }
                    
                        system.debug('mapFarvisionApplicants=====' + mapFarvisionApplicants);
                        if(mapFarvisionApplicants.size() > 0)
                        {
                            list<Opportunity> objUpdateOpportunities = new List<Opportunity>();
                            for ( ID objOpprtunityId : mapFarvisionApplicants.keySet() ){
                            
                                Opportunity objUpdateOpportunity = new Opportunity();
                                objFarvisionAuthResponse = new FarvisionAuthResponse();
                            
                                objFarvisionAuthResponse = mapFarvisionApplicants.get(objOpprtunityId);
                            
                                objUpdateOpportunity.Id = objOpprtunityId;
                                objUpdateOpportunity.FV_Application_ID__c = objFarvisionAuthResponse.ApplicantID;
                            
                                objUpdateOpportunities.add(objUpdateOpportunity);
                            }
                        
                            if(objUpdateOpportunities.size() > 0)
                            {
                                system.debug('objUpdateOpportunities=====' + objUpdateOpportunities);
                                update objUpdateOpportunities;
                            }
                        }
                     
                    }
                }
            }
        }
    }
    
    private static string CheckNull(String value)
    {
        string retValue = '';
        if(String.isNotBlank(value)) {
            retValue = value;
        }
        
        return retValue;
    }
    
    public enum Response {
        Success,
        Error
    }
}