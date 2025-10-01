public class ExhibitionsComponentController 
{
    @AuraEnabled
    public static list<WrapExhibitionData> getExhibitonData()
    {
        list<RW_Exhibition_Master__c> lstExhMaster = [select id, name, RW_Active__c, RW_Content__c, 
                                                            (select id, RW_Project__c, RW_Param1__c, RW_Param2__c, RW_Param3__c, 
                                                            RW_Param4__c, RW_Param5__c from Exhibition_Access__r), 
                                                            (select id from attachments), 
                                                            (select id, RW_Accounts__c, RW_I_m_Coming__c, RW_How_Many__c, 
                                                             RW_Exhibition_Master__c from Exhibitions__r),
                                                        RW_From_Date__c, RW_To_Date__c 
                                                        from RW_Exhibition_Master__c where RW_Active__c =: true];
                                                        
        if(lstExhMaster != null && lstExhMaster.size() > 0)
        {
            //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
			User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
            
            if(objLoggedInUser != null && objLoggedInUser.accountId != null)
            {
                list<WrapExhibitionData> lstWrap = new list<WrapExhibitionData>();
                map<string, RW_Exhibition_Master__c> mapOfProjectUnit = new map<string, RW_Exhibition_Master__c>();
                for(RW_Exhibition_Master__c objExh : lstExhMaster)
                {
                    if(objExh.Exhibition_Access__r != null && objExh.Exhibition_Access__r.size() > 0)
                    {
                        for(RW_Exhibition_Access__c objAcc : objExh.Exhibition_Access__r)
                        {
                            string strParam = '';
                            if(objAcc.RW_Project__c != null)
                                strParam += objAcc.RW_Project__c;
                            
                            if(objAcc.RW_Param1__c != null)
                                strParam += '@@'+objAcc.RW_Param1__c;
                                
                            if(objAcc.RW_Param2__c != null)
                                strParam += '@@'+objAcc.RW_Param2__c;
                                
                            if(objAcc.RW_Param3__c != null)
                                strParam += '@@'+objAcc.RW_Param3__c;
                                
                            if(objAcc.RW_Param4__c != null)
                                strParam += '@@'+objAcc.RW_Param4__c;
                                
                            if(objAcc.RW_Param5__c != null)
                                strParam += '@@'+objAcc.RW_Param5__c;
                                
                            if(strParam != '')
                                mapOfProjectUnit.put(strParam, objExh);
                        }
                    }
                    else
                    {
                        WrapExhibitionData objWrap = new WrapExhibitionData();
                        objWrap.strMasterNam = objExh.name;
                        objWrap.strContent = objExh.RW_Content__c;
                        objWrap.strFrom = objExh.RW_From_Date__c;
                        objWrap.strTo = objExh.RW_To_Date__c;
                        objWrap.objMasterId = objExh.id;
                        objWrap.isSaved = false;
                        
                        if(objExh.Exhibitions__r != null && objExh.Exhibitions__r.size() > 0)
                        {
                            for(RW_Exhibition__c EachExhibitn : objExh.Exhibitions__r)
                            {
                                if(EachExhibitn.RW_Accounts__c == objLoggedInUser.accountId)
                                {
                                    //objWrap.objExh = EachExhibitn;
                                    objWrap.isSaved = true;
                                    if(EachExhibitn.RW_How_Many__c != null)
                                    	objWrap.strNumber = string.valueOf(EachExhibitn.RW_How_Many__c);
                                    
                                    objWrap.IMComming = EachExhibitn.RW_I_m_Coming__c;
                                }
                            }
                        }
                        
                        if(!objWrap.isSaved)
                        {
                            //objWrap.objExh = new RW_Exhibition__c();
                            //objWrap.objExh.RW_Exhibition_Master__c = objExh.id;
                            //objWrap.objExh.RW_Accounts__c = objLoggedInUser.accountId;
                        }
                        if(objExh.Attachments != null && objExh.Attachments.size() > 0)
                        {
                            objWrap.strImgId = '/servlet/servlet.FileDownload?file='+objExh.Attachments[0].id;
                        }
                        lstWrap.add(objWrap);
                    }
                }
                
                system.debug('@map of unit_______'+mapOfProjectUnit);
                if(mapOfProjectUnit != null && mapOfProjectUnit.size() > 0)
                {
                    list<Opportunity> lstOpportunity = [select id, name, RW_Project__c, AccountId, RW_Project_Unit__c, RW_Project_Unit__r.name,
                                                        RW_Project_Unit__r.RW_Param1__c, RW_Project_Unit__r.RW_Param2__c, RW_Project_Unit__r.RW_Param3__c,
                                                        RW_Project_Unit__r.RW_Param4__c, RW_Project_Unit__r.RW_Param5__c from Opportunity where 
                                                        AccountId =: objLoggedInUser.accountId];
                                                        
                    if(lstOpportunity != null && lstOpportunity.size() > 0)
                    {
                        set<string> setOfProject = new set<string>();
                        set<string> setOfUnit = new set<string>();
                        
                        for(Opportunity EachOpp : lstOpportunity)
                        {
                            string strParam = '';
                            if(EachOpp.RW_Project__c != null)
                                strParam = EachOpp.RW_Project__c;
                                
                            if(EachOpp.RW_Project_Unit__c != null)
                            {
                                if(EachOpp.RW_Project_Unit__r.RW_Param1__c != null)
                                    strParam += '@@'+EachOpp.RW_Project_Unit__r.RW_Param1__c;
                                    
                                if(EachOpp.RW_Project_Unit__r.RW_Param2__c != null)
                                    strParam += '@@'+EachOpp.RW_Project_Unit__r.RW_Param2__c;
                                    
                                if(EachOpp.RW_Project_Unit__r.RW_Param3__c != null)
                                    strParam += '@@'+EachOpp.RW_Project_Unit__r.RW_Param3__c;
                                    
                                if(EachOpp.RW_Project_Unit__r.RW_Param4__c != null)
                                    strParam += '@@'+EachOpp.RW_Project_Unit__r.RW_Param4__c;
                                    
                                if(EachOpp.RW_Project_Unit__r.RW_Param5__c != null)
                                    strParam += '@@'+EachOpp.RW_Project_Unit__r.RW_Param5__c;
                                    
                            }
                            
                            system.debug('@strParam_____________'+strParam);
                            if(strParam != '')
                            {
                                for(string EachStr : mapOfProjectUnit.keySet())
                                {
                                    if(strParam.startsWith(EachStr))
                                    {
                                        WrapExhibitionData objWrap = new WrapExhibitionData();
                                        objWrap.objMasterId = mapOfProjectUnit.get(EachStr).id;
                                        objWrap.strMasterNam = mapOfProjectUnit.get(EachStr).name;
                                        objWrap.strContent = mapOfProjectUnit.get(EachStr).RW_Content__c;
                                        objWrap.strFrom = mapOfProjectUnit.get(EachStr).RW_From_Date__c;
                                        objWrap.strTo = mapOfProjectUnit.get(EachStr).RW_To_Date__c;
                                        objWrap.isSaved = false;
                                        if(mapOfProjectUnit.get(EachStr).Exhibitions__r != null && mapOfProjectUnit.get(EachStr).Exhibitions__r.size() > 0)
                                        {
                                            for(RW_Exhibition__c EachExhibitn : mapOfProjectUnit.get(EachStr).Exhibitions__r)
                                            {
                                                if(EachExhibitn.RW_Accounts__c == objLoggedInUser.accountId)
                                                {
                                                    //objWrap.objExh = EachExhibitn;
                                                    objWrap.isSaved = true;
                                                    if(EachExhibitn.RW_How_Many__c != null)
                                                    	objWrap.strNumber = string.valueOf(EachExhibitn.RW_How_Many__c);
                                                    
                                                    objWrap.IMComming = EachExhibitn.RW_I_m_Coming__c;
                                                }
                                            }
                                        }
                                        
                                        if(!objWrap.isSaved)
                                        {
                                            //objWrap.objExh = new RW_Exhibition__c();
                                            //objWrap.objExh.RW_Exhibition_Master__c = mapOfProjectUnit.get(EachStr).id;
                                            //objWrap.objExh.RW_Accounts__c = objLoggedInUser.accountId;
                                        }
                                        if(mapOfProjectUnit.get(EachStr).Attachments != null && mapOfProjectUnit.get(EachStr).Attachments.size() > 0)
                                        {
                                            objWrap.strImgId = '/servlet/servlet.FileDownload?file='+mapOfProjectUnit.get(EachStr).Attachments[0].id;
                                        }
                                        lstWrap.add(objWrap);
                                    }
                                }
                            }
                        }
                    }
                }
                if(lstWrap != null && lstWrap.size() > 0)
                {
                    return lstWrap;
                }                                
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static string addExhibitionApex(string stringWrp)
    {
        //User objLoggedInUser = [Select id, accountId from User where id =: '005p0000001GNFO'];
		User objLoggedInUser = [Select id, accountId from User where id =: Userinfo.getUserid()];
        list<WrapExhibitionData> lstWrap = new list<WrapExhibitionData>();
        system.debug('@stringWrp______'+stringWrp);
        if(stringWrp != '')
        {
         	lstWrap = (list<WrapExhibitionData>)JSON.deserialize(stringWrp, List<WrapExhibitionData>.class);
        }
        try
        {
            if(lstWrap != null && lstWrap.size() > 0)
            {
                list<RW_Exhibition__c> lstExb2Insert = new list<RW_Exhibition__c>();
                boolean isSuccess = false;
                for(WrapExhibitionData Eachwrap : lstWrap)
                {
                    if(!Eachwrap.isSaved && Eachwrap.IMComming)
                    {
                        system.debug('@IMComming______'+Eachwrap.strNumber);
                        if(Eachwrap.strNumber != null)
                        {
                            if(Eachwrap.strNumber.isNumeric())
                            {
                            	RW_Exhibition__c objExhib = new RW_Exhibition__c();
                                objExhib.RW_How_Many__c = integer.valueOf(Eachwrap.strNumber);
                                objExhib.RW_Exhibition_Master__c = Eachwrap.objMasterId;
                                objExhib.RW_Accounts__c = objLoggedInUser.accountId;
                                objExhib.RW_I_m_Coming__c = true;
                                lstExb2Insert.add(objExhib);
                                isSuccess = true;
                            }
                        }
                    }
                }
                if(!isSuccess)
                {
                    return 'Please enter all valid record to proceed.';
                }
                else
                {
                    insert lstExb2Insert;
                    return 'Inserted Sucessfully';
                }
            }
            return '';
        }
        catch(exception ex)
        {
            return ex.getMessage();
        }
    }
}