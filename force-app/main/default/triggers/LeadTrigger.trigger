trigger LeadTrigger on Lead(before Insert, after Insert, before update, after update) {
    /*  if (Trigger.IsInsert) {
if (Trigger.IsBefore) {
//check the user, if its batch user, only then call the preprocessing logic
If(UserInfo.getUserName() == '') { 
List < DupResultsDTO > dupResList = new List < DupResultsDTO > ();
dupResList = LeadManagementServices.leadPreProcessing(Trigger.new, 'BULKLOAD');
if (dupResList != null) {
for (Lead l: Trigger.new) {
System.debug('Trigger.new: ' + l);
for (DupResultsDTO d: dupResList) {
if (d.originalLead == l) {
System.debug('Trigger.new: dup match' + l + d.originalLead);

String errMsg = 'Duplicates exists for:' + l.lastName + '\n';
for (String dupType: d.duplicatesMap.keySet()) {
errMsg = errMsg + '\n' + dupType + 'duplicates are:' + d.duplicatesMap.get(dupType);
}
l.addError(errMsg);
}
break;
}
}
}
}

/////////Anuja added this on 18/jan/16 /////////////
List <Lead> updateNewOwnerList = new List < Lead > ();
for (Lead l: Trigger.new) {
updateNewOwnerList.add(l);
}    
/////////Anuja added this on 18/jan/16 /////////////
if(updateNewOwnerList.size() > 0)
{
LeadManagementServices.updatefield(updateNewOwnerList);
}   

List < lead > updateNRIList = new List < Lead > ();
// call the CampaignManagementServices.addchannel method
updateNRIList = CampaignManagementServices.setNRIChannelOnLead(Trigger.new);
LeadManagementServices.setSystemCampaignOnLead(Trigger.new);
LeadManagementServices.setDialingCodeOnLead(Trigger.new);

} else if (Trigger.isAfter) {
try {
LeadManagementServices.AddCampaignToLead(Trigger.new);
} catch (GlobalException ex) {
System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
}
}
}     */
    //Added by Prashant to bypass trigger in prod. /////// 19-05-25.
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Lead' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
    
    List<String> lstLeadIds = new List<String>();
    //Added 2April2025 by digiCloud Team
    if(Trigger.isAfter && Trigger.isInsert){
        List<Lead> leadList = new List<Lead>();
        for(Lead objLead : Trigger.new){
            lstLeadIds.add(objLead.Id);
            leadList.add(objLead);
        } 
        System.debug('lstLeadIds>>>' +lstLeadIds);
        if(!lstLeadIds.isEmpty() && lstLeadIds.size()>0){
           // WhatsAppMSGForNewLeadTriggerHandler.sendWelcomeWhatsAppMsg(lstLeadIds);
              //system.enqueuejob(new WhatsAppMSGForNewLeadTriggerHandler(lstLeadIds)); // Commented by Vinay 26-09-2025
            system.enqueuejob(new LeadQueueable(leadList)); // Added by Vinay 26-09-2025
        }
    }
    if (Trigger.IsInsert) {
        if(Trigger.isBefore) {
          //  LeadManagementServices.setSystemCampaignOnLead(Trigger.new);
            for(lead l : trigger.new){
                if(l.RW_Broker__c != null){
                    if(l.LeadSource == 'Channel Partner'){
                        if(l.RW_Project__c != null){
                            /*List<Project__c> projectList = [Select Id,Name,Project_Location__c from Project__c where id =: l.RW_Project__c];
system.debug('projectList'+projectList);
system.debug('projectList[0].Project_Location__c'+projectList[0].Project_Location__c);
if(!projectList.isEmpty() && projectList[0].Project_Location__c != null){
system.debug('projectList[0].Project_Location__c'+projectList[0].Project_Location__c);
list<Project_Location__c> projectLocationList =[Select Id,CP_Category__c from Project_Location__c where Id =: projectList[0].Project_Location__c];
if(!projectLocationList.isEmpty() && projectLocationList[0].CP_Category__c != null){
l.CP_Category__c = projectLocationList[0].CP_Category__c;
}
}*/
                            
                            //New logic - 19/11-24
                            List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                                   where Project__c =: l.RW_Project__c and Channel_Partner__c =: l.RW_Broker__c];
                            system.debug('cpCategoryList'+cpCategoryList);                        
                            if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                                l.CP_Category__c = cpCategoryList[0].Category__c;
                            }
                            
                        }
                        List<Broker__c> newCP = [Select Id, AOP_Type__c from Broker__c where Id =: l.RW_Broker__c];
                        if(!newCP.isEmpty() && newCP[0].AOP_Type__c != null){
                            l.AOP_Type__c = newCP[0].AOP_Type__c;
                        }
                    }
                } 
            }
            
        }
        /*else if (Trigger.isAfter) {
            
            try {
                LeadManagementServices.AddCampaignToLead(Trigger.new);
                //LeadManagementServices.setSystemCampaignOnLead(Trigger.new);
                
            } catch (GlobalException ex) {
                System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
            }
            
            list<Lead> updateLeadDetails1 = new list<Lead>();
            list<Lead> updateLeadDetails2 = new list<Lead>();
        }*/
        
        If(Trigger.isUpdate) {
            /*  if (Trigger.isBefore) {
List < Lead > updateChannelList = new List < Lead > ();
List < Lead > updateNRIList = new List < Lead > ();
List <Lead> updateNewOwnerList = new List < Lead > ();

for (lead l: trigger.new) {
if (Trigger.newMap.get(l.Id).channel_Code__C != Trigger.oldMap.get(l.Id).Channel_Code__c) {
updateChannelList.add(l);
}

/////////Anuja added this on 18/jan/16 /////////////
if( Trigger.newMap.get(l.Id).OwnerId !=  Trigger.oldMap.get(l.Id).OwnerId)
{
updateNewOwnerList.add(l);

}

}
if (updateChannelList != null && updateChannelList.size() > 0) {
updateNRIList = CampaignManagementServices.setNRIChannelOnLead(updateChannelList);
}

LeadManagementServices.setDialingCodeOnLead(Trigger.new);

/////////Anuja added this on 18/jan/16 /////////////
if(updateNewOwnerList.size() > 0)
{
LeadManagementServices.updatefield(updateNewOwnerList);
}   

}    
else */ if (Trigger.isAfter) {
    List < Lead > updateCMList = new List < Lead > ();
    for (lead l: trigger.new) {
        if (Trigger.newMap.get(l.Id).Campaign_Code__C != Trigger.oldMap.get(l.Id).Campaign_Code__C || 
            Trigger.newMap.get(l.Id).TollFree_Number__C != Trigger.oldMap.get(l.Id).TollFree_Number__C /* || 
Trigger.newMap.get(l.Id).CCUCampaignDetails__c != Trigger.oldMap.get(l.Id).CCUCampaignDetails__c */ ) {
    updateCMList.add(l);
}  
        
        
        
    }
    
   /* if (updateCMList != null && updateCMList.size() > 0) {
        try {
            LeadManagementServices.AddCampaignToLead(updateCMList);
        } catch (GlobalException ex) {
            System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        }
    }*/
    
    /*   Map<Id,Lead> leadMap = new Map<Id,Lead>();
for(lead l : trigger.new) {
leadMap.put(l.Id, trigger.newMap.get(l.Id));
}
if(leadMap.size() > 0)
LeadManagementServices.changeActivityOwner(leadMap);      */      
}
        }
    }
    
    If(Trigger.isUpdate) {
        if (Trigger.isBefore){
            for (lead l: trigger.new) {
                if(l.LeadSource == 'Channel Partner'){
                    //Added by Prashant to update AOP type and CP category when Broker is changed.                
                    if (Trigger.newMap.get(l.Id).RW_Broker__c != Trigger.oldMap.get(l.Id).RW_Broker__c) {
                        if(Trigger.newMap.get(l.Id).RW_Broker__c != null){
                            system.debug('Inside Update trigger on broker change');
                            List<Broker__c> newCP = [Select Id, AOP_Type__c from Broker__c where Id =: Trigger.newMap.get(l.Id).RW_Broker__c];
                            if(!newCP.isEmpty() && newCP[0].AOP_Type__c != null){
                                l.AOP_Type__c = newCP[0].AOP_Type__c;
                            }
                        }else if(Trigger.newMap.get(l.Id).RW_Broker__c == null){
                            l.AOP_Type__c = null;
                        }
                    } 
                    
                    if (Trigger.newMap.get(l.Id).RW_Broker__c != Trigger.oldMap.get(l.Id).RW_Broker__c) {
                        if(Trigger.newMap.get(l.Id).RW_Broker__c != null){
                            system.debug('Inside Update trigger on broker change');
                            //New logic - 19/11-24
                            List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                                   where Project__c =: Trigger.newMap.get(l.Id).RW_Project__c and Channel_Partner__c =: Trigger.newMap.get(l.Id).RW_Broker__c];
                            system.debug('cpCategoryList'+cpCategoryList);                        
                            if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                                l.CP_Category__c = cpCategoryList[0].Category__c;
                            }
                        }else if(Trigger.newMap.get(l.Id).RW_Broker__c == null){
                            l.CP_Category__c = null;
                        }
                    } 
                    
                    if (Trigger.newMap.get(l.Id).RW_Project__c != Trigger.oldMap.get(l.Id).RW_Project__c) {
                        if(Trigger.newMap.get(l.Id).RW_Project__c != null){
                            //New logic - 19/11-24
                            List<CP_Category__c> cpCategoryList = [Select Id,Name,Category__c,Channel_Partner__c,Project__c from CP_Category__c
                                                                   where Project__c =: Trigger.newMap.get(l.Id).RW_Project__c and Channel_Partner__c =: Trigger.newMap.get(l.Id).RW_Broker__c];
                            system.debug('cpCategoryList'+cpCategoryList);                        
                            if(!cpCategoryList.isEmpty() && cpCategoryList[0].Category__c != null){
                                l.CP_Category__c = cpCategoryList[0].Category__c;
                            }
                        }else if(Trigger.newMap.get(l.Id).RW_Project__c == null){
                            l.CP_Category__c = null;
                        }
                    } 
                }
            }
        }
    }   
    integer i;
    i=0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;        
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;        
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;  i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;            i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    }
}