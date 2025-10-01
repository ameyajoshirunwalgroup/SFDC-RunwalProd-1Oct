public class ChannelPartnerTriggerHandler {
    public static boolean bypasstrigger=false;
    
    public static void sendBrokerlist(Id brokerid){
        if(!bypasstrigger)
            SAPChannelPartnerAPICallOut.sendBrokerlist(brokerId);
    }
    
    //Added by Prashant 11-06-2025. Start
    public static void createCPCategory(List<String> cpIds){
        list<CP_Category__c> cpclist = new list<CP_Category__c>();
        List<Broker__c> cpList = [SELECT Id FROM Broker__c WHERE Id In: cpIds];        
        list<String> segmentlist = getSegmentPicklistValues();
        Integer currentYear = Date.today().year();
        Date StartDate = Date.newInstance(currentYear-3, 4, 1);
        Date EndDate = Date.newInstance(currentYear-1, 3, 31);
        
        For(Broker__c b : cpList){
            if(!segmentlist.isEmpty()){
                for(String segment : segmentlist){
                    CP_Category__c cpc = new CP_Category__c();
                    cpc.Channel_Partner__c = b.id;
                    cpc.Category__c = 'P4';
                    cpc.Segment__c = segment;
                    cpc.Start_Date__c = StartDate;
                    cpc.End_Date__c = EndDate;
                    cpc.Relevant_FY__c = String.valueOf(currentYear);
                    cpclist.add(cpc);
                }
            }
        }
        if(!cpclist.isEmpty()){
            Database.insert(cpclist,false);
        }
    }
    private static List<String> getSegmentPicklistValues() {
        List<String> picklistValues = new List<String>();        
        Schema.DescribeFieldResult fieldResult = Project__c.Segment__c.getDescribe();        
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry val : values) {
            //picklistValues.add(val.getLabel()); // You can also use getValue()
            picklistValues.add(val.getValue());
        }        
        return picklistValues;
    }
    //Added by Prashant 11-06-2025. End
    //
    
    
    
    /*    public static void isafter(List<Broker__c> broker, Map<Id,Broker__c> newMap, Map<Id, Broker__c> oldMap){

if(!bypasstrigger){

list<id> trid = new list<id>();


for(Broker__c br : broker){
if((br.RW_RERA_Registration_Number__c != null || br.RW_RERA_Registration_Number__c != '')){
trid.add(br.id);
}
}            



if(!test.isRunningTest())
if(trid.size()>0)
SAPChannelPartnerAPICallOut.sendBrokerlist(trid[0]);

}
}

*/
    public static void CPProfileUpdate(List<Broker__c> lstNewCP,List<Broker__c> lstOldCP,Map<Id, Broker__c> mapIdToOldCP, Map<Id, Broker__c> mapIdToNewdCP){
        for(Broker__c cp:lstNewCP){
            Broker__c objNewcpupdate = mapIdToNewdCP.get(cp.Id);
            Broker__c objOldcpupdate = mapIdToOldCP.get(cp.id);
            System.debug('New Map:::'+objNewcpupdate);
            System.debug('Old Mapp:::'+objOldcpupdate);
            CP_Profile_Update__c p = new CP_Profile_Update__c();
            if(objOldcpupdate.Approval_Status_Update__c != 'Approval Pending'){
                if(checkRecursion.isFirstRun()){ 
                    List<CP_Profile_Update__c> ExistingCPProfile = new List<CP_Profile_Update__c>();
                    ExistingCPProfile = [Select id,name from CP_Profile_Update__c where Channel_Partner__c =:objNewcpupdate.Id];
                    system.debug('ExistingCPProfile::'+ExistingCPProfile);
                    if(ExistingCPProfile.isEmpty()){
                        p.Old_RERA_No__c = objOldcpupdate.RW_RERA_Registration_Number__c;
                        p.New_RERA_No__c = objNewcpupdate.RW_RERA_Registration_Number__c;
                        p.Old_GST_No__c = objOldcpupdate.RW_GST_Number__c;
                        p.New_GST_No__c = objNewcpupdate.RW_GST_Number__c;
                        p.Old_CP_Name__c = objOldcpupdate.Name;
                        p.New_CP_Name__c = objNewcpupdate.Name;
                        p.New_First_Name__c = objOldcpupdate.NAME_FIRST__c;
                        p.New_Last_Name__c = objNewcpupdate.NAME_LAST__c;
                        p.Old_First_Name__c = objOldcpupdate.NAME_FIRST__c;
                        p.Old_Last_Name__c = objNewcpupdate.NAME_LAST__c;
                        p.Channel_Partner__c = objNewcpupdate.Id;
                        insert p;
                        /*Broker__c bb = new Broker__c();
bb.Approval_Status_Update__c = 'Approval Pending';
bb.Id = objNewcpupdate.Id;
update bb;*/
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(objNewcpupdate.id);
                        req1.setProcessDefinitionNameOrId('Channel_Partner_Update_Approval_Process');
                        req1.setSkipEntryCriteria(true);
                        Approval.ProcessResult result = Approval.process(req1);
                    }else{
                        delete ExistingCPProfile;
                        p.Old_RERA_No__c = objOldcpupdate.RW_RERA_Registration_Number__c;
                        p.New_RERA_No__c = objNewcpupdate.RW_RERA_Registration_Number__c;
                        p.Old_GST_No__c = objOldcpupdate.RW_GST_Number__c;
                        p.New_GST_No__c = objNewcpupdate.RW_GST_Number__c;
                        p.Old_CP_Name__c = objOldcpupdate.Name;
                        p.New_CP_Name__c = objNewcpupdate.Name;
                        p.New_First_Name__c = objOldcpupdate.NAME_FIRST__c;
                        p.New_Last_Name__c = objNewcpupdate.NAME_LAST__c;
                        p.Old_First_Name__c = objOldcpupdate.NAME_FIRST__c;
                        p.Old_Last_Name__c = objNewcpupdate.NAME_LAST__c;
                        p.Channel_Partner__c = objNewcpupdate.Id;
                        insert p;
                        Broker__c bb = new Broker__c();
                        bb.Approval_Status_Update__c = 'Approval Pending';
                        bb.Id = objNewcpupdate.Id;
                        update bb;
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(objNewcpupdate.id);
                        req1.setProcessDefinitionNameOrId('Channel_Partner_Update_Approval_Process');
                        req1.setSkipEntryCriteria(true);
                        Approval.ProcessResult result = Approval.process(req1);
                    }
                }
            }else if(objNewcpupdate.Approval_Status_Update__c == 'Rejected By L1'){
                
                List<CP_Profile_Update__c> cpp = new List<CP_Profile_Update__c>();
                List<Broker__c> bro = new List<Broker__c>();
                bro = [Select Id,Name,RW_RERA_Registration_Number__c,RW_GST_Number__c,Approval_Status_Update__c,NAME_LAST__c,NAME_FIRST__c from Broker__c where Id =: objNewcpupdate.Id];
                cpp = [Select Id,Name,Old_RERA_No__c,Old_GST_No__c,Old_CP_Name__c,Old_Last_Name__c,Old_First_Name__c from CP_Profile_Update__c where Channel_Partner__c =: bro[0].Id ORDER BY Name DESC];
                bro[0].Name = cpp[0].Old_CP_Name__c;
                bro[0].NAME_FIRST__c = cpp[0].Old_First_Name__c;
                bro[0].NAME_LAST__c = cpp[0].Old_Last_Name__c;
                bro[0].RW_RERA_Registration_Number__c = cpp[0].Old_RERA_No__c;
                bro[0].RW_GST_Number__c = cpp[0].Old_GST_No__c;
                bro[0].Approval_Status_Update__c = 'Rejected By L1';
                update bro;
                delete cpp;
                
            }else if(objNewcpupdate.Approval_Status_Update__c == 'Rejected By L2'){
                List<CP_Profile_Update__c> cpp = new List<CP_Profile_Update__c>();
                List<Broker__c> bro = new List<Broker__c>();
                bro = [Select Id,Name,RW_RERA_Registration_Number__c,RW_GST_Number__c,Approval_Status_Update__c,NAME_LAST__c,NAME_FIRST__c from Broker__c where Id =: objNewcpupdate.Id];
                cpp = [Select Id,Name,Old_RERA_No__c,Old_GST_No__c,Old_CP_Name__c,Old_Last_Name__c,Old_First_Name__c from CP_Profile_Update__c where Channel_Partner__c =: bro[0].Id ORDER BY Name DESC];
                bro[0].Name = cpp[0].Old_CP_Name__c;
                bro[0].NAME_FIRST__c = cpp[0].Old_First_Name__c;
                bro[0].NAME_LAST__c = cpp[0].Old_Last_Name__c;
                bro[0].RW_RERA_Registration_Number__c = cpp[0].Old_RERA_No__c;
                bro[0].RW_GST_Number__c = cpp[0].Old_GST_No__c;
                bro[0].Approval_Status_Update__c = 'Rejected By L2';
                update bro;
                delete cpp;
            }
        }
    }
    
    //Added by coServe 14-02-2024 Start
    public static void checkTempCp(List<String> cpIds){
        
        List<Broker__c> cpList = [SELECT Id, RW_Mobile_No__c FROM Broker__c WHERE Id =: cpIds];
        
        Map<String, String> mobNumVsCp = new Map<String, String>();
        for(Broker__c br : cpList){
            mobNumVsCp.put(br.RW_Mobile_No__c, br.Id);
        }
        
        List<Temp_Channel_Partner__c> tempCpList = new List<Temp_Channel_Partner__c>();
        if(mobNumVsCp.keySet().size() > 0){
            tempCpList = [SELECT Id, Name, Mobile_No__c, PAN_No__c, First_Name__c, Middle_Name__c, Last_Name__c, Email__c, State__c, 
                          Converted__c FROM Temp_Channel_Partner__c WHERE Mobile_No__c =: mobNumVsCp.keySet() AND Converted__c = false];
        }
        if(tempCpList.size() > 0){
            Map<String, String> tempCpIdVsMobNumMap = new Map<String, String>();
            for(Temp_Channel_Partner__c tempCp : tempCpList){
                tempCp.Converted__c = true;
                tempCp.Original_Channel_Partner__c = mobNumVsCp.get(tempCp.Mobile_No__c);
                tempCpIdVsMobNumMap.put(tempCp.Id, tempCp.Mobile_No__c);
            }
            Database.update(tempCpList, false);
            
            List<Lead> leadList = [SELECT Id, Temp_Channel_Partner__c FROM Lead WHERE Temp_Channel_Partner__c =: tempCpIdVsMobNumMap.keySet() AND LeadSource = 'Temp Channel Partner']; 
            if(leadList.size() > 0){
                for(Lead ld : leadList){
                    ld.LeadSource = 'Channel Partner';
                    ld.RW_Broker__c = mobNumVsCp.get(tempCpIdVsMobNumMap.get(ld.Temp_Channel_Partner__c));
                    ld.Temp_Channel_Partner__c = null;
                }
                Database.update(leadList, false);
            }
            
            List<Opportunity> opps = [SELECT Id, Temp_Channel_Partner__c FROM Opportunity WHERE Temp_Channel_Partner__c =: tempCpIdVsMobNumMap.keySet() AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner')];
            if(opps.size() > 0){
                for(Opportunity opp : opps){
                    System.debug('opp.Temp_Channel_Partner__c: ' + opp.Temp_Channel_Partner__c);
                    System.debug('Mobile: ' + tempCpIdVsMobNumMap.get(opp.Temp_Channel_Partner__c));
                    System.debug('br Id: ' + mobNumVsCp.get(tempCpIdVsMobNumMap.get(opp.Temp_Channel_Partner__c)));
                    String cpId = mobNumVsCp.get(tempCpIdVsMobNumMap.get(opp.Temp_Channel_Partner__c));
                    opp.LeadSource = 'Channel Partner';
                    opp.RW_Broker__c = cpId;
                    opp.Temp_Channel_Partner__c = null;
                    opp.RW_Walkin_Channel_Partner__c = cpId;
                    opp.Walkin_Source__c = 'Channel Partner';
                }
                //update opps;
                Database.update(opps, false);
            }
            
            List<Prospect__c> prospects = [SELECT Id, Temp_Channel_Partner__c FROM Prospect__c WHERE Temp_Channel_Partner__c =: tempCpIdVsMobNumMap.keySet() AND Lead_Source__c  = 'Temp Channel Partner'];
            if(prospects.size() > 0){
                for(Prospect__c pros : prospects){
                    pros.Channel_Partner__c = mobNumVsCp.get(tempCpIdVsMobNumMap.get(pros.Temp_Channel_Partner__c));
                    pros.Lead_Source__c  = 'Channel Partner';
                    pros.Temp_Channel_Partner__c = null;
                }
                Database.update(prospects, false);
            }
        }
    }
    //Added by coServe 14-02-2024 End
    
    //Added by coServe 29-02-2024 Start
    public static void tagFromTempCpToOriginalCp(List<String> cpIds){
        List<Temp_Channel_Partner__c> tempCps = [SELECT Id, Name, Mobile_No__c, PAN_No__c, First_Name__c, Middle_Name__c, Last_Name__c, Email__c,
                                                 State__c, Converted__c, Original_Channel_Partner__c FROM Temp_Channel_Partner__c WHERE 
                                                 Original_Channel_Partner__c =: cpIds];
        
        Map<String, String> tempCpVsOriginalCp = new Map<String, String>();
        Map<String, String> tempCpNameVsOriginalCp = new Map<String, String>();
        for(Temp_Channel_Partner__c tempCp : tempCps){
            tempCpVsOriginalCp.put(tempcp.Id, tempCp.Original_Channel_Partner__c);
            tempCpNameVsOriginalCp.put(tempcp.Name, tempCp.Original_Channel_Partner__c);
        }
        
        List<Lead> leadList = [SELECT Id, Temp_Channel_Partner__c FROM Lead WHERE Temp_Channel_Partner__c =: tempCpVsOriginalCp.keySet() AND LeadSource = 'Temp Channel Partner']; 
        System.debug('leadList: ' + leadList);
        for(Lead ld : leadList){
            ld.LeadSource = 'Channel Partner';
            ld.RW_Broker__c = tempCpVsOriginalCp.get(ld.Temp_Channel_Partner__c);
            ld.Temp_Channel_Partner__c = null;
        }
        Database.update(leadList, false);
        
        List<Opportunity> opps = [SELECT Id, Temp_Channel_Partner__c FROM Opportunity WHERE Temp_Channel_Partner__c =: tempCpVsOriginalCp.keySet() AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner')];
        for(Opportunity opp : opps){
            opp.LeadSource = 'Channel Partner';
            opp.RW_Broker__c = tempCpVsOriginalCp.get(opp.Temp_Channel_Partner__c);
            opp.RW_Walkin_Channel_Partner__c = tempCpVsOriginalCp.get(opp.Temp_Channel_Partner__c);
            opp.Walkin_Source__c = 'Channel Partner';
            opp.Temp_Channel_Partner__c = null;
        }
        Database.update(opps, false);
        
        List<Prospect__c> prospects = [SELECT Id, Temp_Channel_Partner__c FROM Prospect__c WHERE Temp_Channel_Partner__c =: tempCpVsOriginalCp.keySet() AND Lead_Source__c  = 'Temp Channel Partner'];
        for(Prospect__c pros : prospects){
            pros.Channel_Partner__c = tempCpVsOriginalCp.get(pros.Temp_Channel_Partner__c);
            pros.Lead_Source__c  = 'Channel Partner';
            pros.Temp_Channel_Partner__c = null;
        }
        Database.update(prospects, false);
        
        List<Booking__c> bookings = [SELECT Id, Temp_Channel_Partner_Name__c FROM Booking__c WHERE Temp_Channel_Partner_Name__c =: tempCpNameVsOriginalCp.keySet() AND Source_of_Booking__c = 'Temp Channel Partner'];
        for(Booking__c bkg : bookings){
            bkg.BrokerIId__c = tempCpNameVsOriginalCp.get(bkg.Temp_Channel_Partner_Name__c);
            bkg.Source_of_Booking__c = 'Channel Partner';
        }
        Database.update(bookings, false);
    }
    //Added by coServe 29-02-2024 End 
    
    //Added by Prashant ../// 21-08-25 Start
    public static void closeReminderTasks(list<Id> brIds){
        list<Task> tasklist = [Select Id from Task where WhatId In: brIds and Status != 'Completed'];
        if(!tasklist.isEmpty()){
            for(Task t: tasklist){
                t.Status = 'Completed';
            }
            try{
                update tasklist;
            }catch(Exception e){
                System.debug('Error while updating Tasks -> '+e.getMessage());
            }
        }
    }
    //Added by Prashant ../// 21-08-25 End
    
    
}