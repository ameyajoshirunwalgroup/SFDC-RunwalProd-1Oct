trigger ChannelPartnerTrigger on Broker__c (Before Insert,Before Update, After Insert, After Update) {
    
    if(trigger.isbefore && trigger.isInsert){        
        //Added by Prashant to Assign Temp CP Unique No based on previous record created....///START.. 07-08-2025/////
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        
        for(Broker__c br : Trigger.New){
            if(br.STREET__c != '' && br.STREET__c != null)
                br.Address__c = br.STREET__c;
            if(br.STR_SUPPL1__c != '' && br.STR_SUPPL1__c != null){
                if(br.Address__c != ''  &&  br.Address__c != null ){
                    br.Address__c = br.Address__c +' , '+br.STR_SUPPL1__c;
                }else{
                    br.Address__c = br.STR_SUPPL1__c;
                }
            }  
            if(br.STR_SUPPL2__c != '' && br.STR_SUPPL2__c != null){
                if(br.Address__c != ''  &&  br.Address__c != null ){
                    br.Address__c = br.Address__c +' , '+br.STR_SUPPL2__c;
                }else{
                    br.Address__c = br.STR_SUPPL2__c;
                }
            }   
            if(br.STR_SUPPL3__c != '' && br.STR_SUPPL3__c != null){
                if(br.Address__c != '' &&  br.Address__c != null ){
                    br.Address__c = br.Address__c +' , '+br.STR_SUPPL3__c;
                }else{
                    br.Address__c = br.STR_SUPPL3__c;
                }
            }   
            
            
            //Added by Prashant to Assign Temp CP Unique No based on previous record created....///START.. 07-08-2025/////            
            /* if(br.RecordTypeId == tempRecordTypeId){
if (!tempCpList.isEmpty()) {                    
String prefix = 'TEMP-';
Integer nextNumber = Integer.valueOf(recentTempCPNo.substring(5)) + 1;

String numberStr;
if (nextNumber < 1000) {
numberStr = String.valueOf(nextNumber).leftPad(4, '0');
} else {
numberStr = String.valueOf(nextNumber);
}
String currentTempCPNo = prefix + numberStr;
System.debug('Next Temp CP No: ' + currentTempCPNo);
br.Temp_CP_Unique_Id__c = currentTempCPNo;
} else {
// First record scenario
br.Temp_CP_Unique_Id__c = 'TEMP-0001';
}  */
            
            /*if(br.NAME_FIRST__c != null && br.NAME_LAST__c != null){
if(br.NAME_MIDDLE__c != null){
br.Name = br.NAME_FIRST__c + ' ' + br.NAME_MIDDLE__c + ' ' + br.NAME_LAST__c;
}else{
br.Name = br.NAME_FIRST__c + ' ' + br.NAME_LAST__c;
}
}*/
            // }   
            //Added by Prashant to Assign Temp CP Unique No based on previous record created....///END.. 07-08-2025/////        
            
        }
        
    }
    
    list<id> trid = new list<id>();
    if(Trigger.isAfter  ){
        system.debug('MK');
        //ChannelPartnerTriggerHandler.isafter(Trigger.new,Trigger.newmap,Trigger.oldmap);
        if(Trigger.isUpdate){
            for(Broker__c br : Trigger.New){
                system.debug('MK'+((br.RW_RERA_Registration_Number__c != null)));
                system.debug('MK'+br.RW_RERA_Registration_Number__c != '');
                system.debug('MK'+br.SAP_CP_Code__c != null);
                system.debug('MK'+br.SAP_CP_Code__c != '');
                if((trigger.oldMap.get(br.id).RW_RERA_Registration_Number__c != trigger.newMap.get(br.id).RW_RERA_Registration_Number__c && trigger.newMap.get(br.id).RW_RERA_Registration_Number__c != null && trigger.newMap.get(br.id).RW_RERA_Registration_Number__c != '' && trigger.newMap.get(br.id).Approval_Status__c == 'Approved By L2') ||
                   (trigger.oldMap.get(br.id).Approval_Status__c != trigger.newMap.get(br.id).Approval_Status__c && trigger.newMap.get(br.id).RW_RERA_Registration_Number__c != null && trigger.newMap.get(br.id).RW_RERA_Registration_Number__c != '' && trigger.newMap.get(br.id).Approval_Status__c == 'Approved By L2'))
                {
                    system.debug('MK');
                    trid.add(br.id);
                }
                
                if(trigger.oldMap.get(br.id).Data_Error_Fixed__c != trigger.newMap.get(br.id).Data_Error_Fixed__c && trigger.oldMap.get(br.id).Data_Error_Fixed__c == false && trigger.newMap.get(br.id).Data_Error_Fixed__c == true){
                    trid.add(br.id);
                }
                
            }            
        }
        
    }
    if(!test.isRunningTest()){
        if(trid.size()>0)
        {  
            if(checkRecursion.isFirstRunA()){ 
                ChannelPartnerTriggerHandler.sendBrokerlist(trid[0]);
            }
            
        }
        
    }
    
    if(trigger.isAfter && trigger.isInsert){
        List<Account> AccountUpdate = new List<Account>();
        Id AccChannelPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        Id ChannelPartnerId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();            
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();//Added by Prashant //25-08-25...
        Map<Id,String> tempCPIdVsEmailMap = new Map<Id,String>();//Added by Prashant 25-08-25...///    
        List<String> cpIds = new List<String>(); //Added by coServe 14-02-2024
        List<String> cpIdsCPC = new List<String>();
        for(Broker__c br : Trigger.New){
            if(br.RecordTypeId == ChannelPartnerId && br.Channel_Partner_From_CP_Portal__c == false && trigger.isInsert){//Added by Prashant to create account for only CP record type. //// 05-08-2025.
                Account ac = new Account();
                ac.Name = br.Name;
                ac.CP_Email__c = br.RW_Email__c;
                ac.Mobile_No__c = br.RW_Mobile_No__c;
                ac.Channel_Partner__c = br.id;
                ac.RecordTypeId = AccChannelPartnerId;
                AccountUpdate.add(ac);                
            }    
            if(br.RecordTypeId == ChannelPartnerId){
                cpIds.add(br.Id); //Added by coServe 14-02-2024
                cpIdsCPC.add(br.Id);//Added by Prashant to Create Category...
            }
            //Added by Prashant to send temp cp creation mail... 25-08-25///START
            if(br.RecordTypeId == tempRecordTypeId){
                system.debug('Inside Temp CP');
                tempCPIdVsEmailMap.put(br.Id,br.RW_Email__c);
            }
            //Added by Prashant to send temp cp creation mail... 25-08-25///END
        }
        if(AccountUpdate.size() > 0)
            insert AccountUpdate;
        if(cpIds.size() > 0){ //Added by coServe 14-02-2024
            ChannelPartnerTriggerHandler.checkTempCp(cpIds);
        }        
        //Added by Prashant 11-06-2025. Start
        if(cpIdsCPC.size() > 0){ 
            ChannelPartnerTriggerHandler.createCPCategory(cpIdsCPC);
        }
        //Added by Prashant 11-06-2025. End*
        //Added by Prashant 25-08-2025. Start
        if(tempCPIdVsEmailMap.size() > 0){
            system.debug('Inside tempCPIdVsEmailMap'+tempCPIdVsEmailMap);
            //SendCPEmails.SendTempCPCreationEmail(tempCPIdVsEmailMap);
            System.enqueueJob(new SendCPEmails(tempCPIdVsEmailMap, 'Temp_CP_creation_Email'));
        }
        //Added by Prashant 25-08-2025. End      
        //        
    }
    if(trigger.isAfter && trigger.isUpdate){
        List<String> cpIds = new List<String>();//Added by coServe 29-02-2024
        list<Id> brIds = new list<Id>();
        system.debug('Inside CP After update trigger');
        
        for(Broker__c br : Trigger.New){
            Id ChannelPartnerId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
            if(br.RecordTypeId == ChannelPartnerId){
                if(trigger.oldMap.get(br.id).RW_GST_Number__c != trigger.newMap.get(br.id).RW_GST_Number__c && trigger.oldMap.get(br.id).Registration_Complete__c){
                    ChannelPartnerTriggerHandler.CPProfileUpdate(Trigger.new,Trigger.old,trigger.oldMap,trigger.newMap);
                }
                if(trigger.oldMap.get(br.id).RW_RERA_Registration_Number__c != trigger.newMap.get(br.id).RW_RERA_Registration_Number__c && trigger.oldMap.get(br.id).Registration_Complete__c){
                    ChannelPartnerTriggerHandler.CPProfileUpdate(Trigger.new,Trigger.old,trigger.oldMap,trigger.newMap);
                }
                if(trigger.oldMap.get(br.id).Name != trigger.newMap.get(br.id).Name && trigger.oldMap.get(br.id).Name != null && trigger.oldMap.get(br.id).RW_RERA_Registration_Number__c == null && trigger.oldMap.get(br.id).Registration_Complete__c){
                    ChannelPartnerTriggerHandler.CPProfileUpdate(Trigger.new,Trigger.old,trigger.oldMap,trigger.newMap);
                }
                if(trigger.oldMap.get(br.id).Name != trigger.newMap.get(br.id).Name && trigger.oldMap.get(br.id).RW_RERA_Registration_Number__c != null && trigger.oldMap.get(br.id).Registration_Complete__c){
                    //br.addError('Field is Not Editable');
                }
                if(trigger.oldMap.get(br.id).Approval_Status_Update__c != trigger.newMap.get(br.id).Approval_Status_Update__c
                   && (trigger.newMap.get(br.id).Approval_Status_Update__c == 'Rejected By L1' || trigger.newMap.get(br.id).Approval_Status_Update__c == 'Rejected By L2') && trigger.oldMap.get(br.id).Registration_Complete__c){
                       if(checkRecursion.isFirstRun()){ 
                           system.debug('inside approved trigger');
                           ChannelPartnerTriggerHandler.CPProfileUpdate(Trigger.new,Trigger.old,trigger.oldMap,trigger.newMap);
                       }
                   }
                
                //Added by coServe 29-02-2024
                if(br.RW_CreateFromIRIS__c == true && br.RW_CreateFromIRIS__c != trigger.oldMap.get(br.id).RW_CreateFromIRIS__c){
                    cpIds.add(br.Id);
                }
                
            }
            //Added by Prashant to Close Reminder Temp CP Registration Tasks.21-08-25.///Start...
            Id tempChannelPartnerId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
            if(trigger.oldMap.get(br.id).RecordTypeId != trigger.newMap.get(br.id).RecordTypeId && trigger.oldMap.get(br.id).RecordTypeId == tempChannelPartnerId  && trigger.newMap.get(br.id).RecordTypeId == ChannelPartnerId ){
                brIds.add(br.Id);
            }
            //Added by Prashant to Close Reminder Temp CP Registration Tasks.21-08-25.///End...
            
        }
        //Added by coServe 29-02-2024
        if(cpIds.size() > 0){
            ChannelPartnerTriggerHandler.tagFromTempCpToOriginalCp(cpIds);
        }
        
        //Added by Prashant to Close Reminder Temp CP Registration Tasks.21-08-25.///Start...
        if(brIds.size() > 0){
            ChannelPartnerTriggerHandler.closeReminderTasks(brIds);
        }
        //Added by Prashant to Close Reminder Temp CP Registration Tasks.21-08-25.///End...
        
        
        
        
    }
    
}