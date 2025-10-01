public class MyDetailComponentController 
{
    @AuraEnabled
    public static list<wrapOppDetail> getOpportunityData() 
    {
        list<wrapOppDetail> lstWrapper = new list<wrapOppDetail>();
        
        User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
        if(objLoggedInUser != null && objLoggedInUser.accountId != null)
        {
            list<Opportunity> lstOpportunity = [select id, name, RW_Project__c, RW_Project__r.name, RW_Project_Unit__c, RW_Project_Unit__r.name from Opportunity where 
                                                AccountId =: objLoggedInUser.accountId];
            
            if(lstOpportunity != null && lstOpportunity.size() > 0)
            {
                set<string> setOfProjectId = new set<string>();
                for(Opportunity EachOpp : lstOpportunity)
                {
                    if(EachOpp.RW_Project__c != null)
                        setOfProjectId.add(EachOpp.RW_Project__c);
                }
                
                map<string, RW_Construction_Stage__c> mapOfCons = new map<string, RW_Construction_Stage__c>();
                
                if(setOfProjectId.size() > 0)
                {
                    list<RW_Construction_Stage__c> lstProjConStage = [select id, name, RW_Sequence_No__c, RW_Project__c, (select id from attachments) from 
                                                                        RW_Construction_Stage__c where RW_Project__c in: setOfProjectId and RW_Sequence_No__c != null];
                                                                        
                    if(lstProjConStage != null && lstProjConStage.size() > 0)
                    {
                        for(RW_Construction_Stage__c EachStage : lstProjConStage)
                        {
                            if(mapOfCons.containsKey(EachStage.RW_Project__c))
                            {
                                if(EachStage.RW_Sequence_No__c > mapOfCons.get(EachStage.RW_Project__c).RW_Sequence_No__c)
                                {
                                    mapOfCons.put(EachStage.RW_Project__c, EachStage);
                                }
                            }
                            else
                            {
                                mapOfCons.put(EachStage.RW_Project__c, EachStage);
                            }
                        }
                    }
                }
                
                for(Opportunity EachOpp : lstOpportunity)
                {
                    wrapOppDetail objWrap = new wrapOppDetail();
                    objWrap.strOppName = EachOpp.name;
                    if(EachOpp.RW_Project__c != null)
                    {
                        objWrap.strProjName = EachOpp.RW_Project__r.name;
                        objWrap.strProjectId = EachOpp.RW_Project__c;
                        if(mapOfCons != null && mapOfCons.size() > 0 && mapOfCons.containsKey(EachOpp.RW_Project__c))
                        {
                            objWrap.strConstName = mapOfCons.get(EachOpp.RW_Project__c).name;
                            if(mapOfCons.get(EachOpp.RW_Project__c).Attachments != null && mapOfCons.get(EachOpp.RW_Project__c).Attachments.size() > 0)
                            {
                                objWrap.lstAttachment = new list<WrapAttachments>();
                                integer intcount = 0;
                                for(Attachment EachAtt : mapOfCons.get(EachOpp.RW_Project__c).Attachments)
                                {
                                	WrapAttachments objWr = new WrapAttachments();
                                	objWr.intNumber = intcount;
                                	objWr.strAttId = '/servlet/servlet.FileDownload?file='+EachAtt.id;
                                	objWrap.lstAttachment.add(objWr);
                                	 
                                	intcount = intcount + 1;
                                }
                            }
                        }
                    }
                        
                    if(EachOpp.RW_Project_Unit__c != null)
                        objWrap.strUnitName = EachOpp.RW_Project_Unit__r.name;
                        
                    lstWrapper.add(objWrap);
                } 
            }
        }
        system.debug('@lstWrapper______'+lstWrapper);
        return lstWrapper;
    }
    
    @AuraEnabled
    public static list<WrapAttachments> getstageData(string strProjId)
    {
    	list<RW_Construction_Stage__c> lstProjConStage = [select id, name, RW_Sequence_No__c, RW_Project__c, (select id from attachments) from 
                                                            RW_Construction_Stage__c where RW_Project__c =: strProjId and RW_Sequence_No__c != null 
                                                            order by RW_Sequence_No__c desc];
		list<WrapAttachments> lstAllAttId = new list<WrapAttachments>();
		integer intcount = 0;
		if(lstProjConStage != null && lstProjConStage.size() > 0 && lstProjConStage[0].attachments != null && lstProjConStage[0].attachments.size() > 0)
        {
        	for(Attachment EachAtt : lstProjConStage[0].attachments)
        	{
        		WrapAttachments objWrappr = new WrapAttachments();
        		objWrappr.intNumber = intcount;
            	objWrappr.strAttId = '/servlet/servlet.FileDownload?file='+EachAtt.id;
        		lstAllAttId.add(objWrappr);
        		
        		intcount = intcount + 1;
        	}
        }
        system.debug('@lstAllAttId______'+lstAllAttId);
        return lstAllAttId;
    }
}