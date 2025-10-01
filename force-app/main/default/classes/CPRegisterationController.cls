public without sharing class CPRegisterationController {
    
     @AuraEnabled
    public static String selfregister(Broker__c sf) {
        System.debug('sf::'+ sf); 
        System.debug('Pan -> '+sf.Broker_Pan_No__c);
        if(sf != null){ 
            list<String> approvers = getApprovers(sf.Project__c);
            if(!approvers.isEmpty()){
                sf.Approver_L1__c = approvers[0];
                sf.Approver_L2__c = approvers[1];
            }
            
            if (sf.Company_Name_As_per_RERA__c != null) {
                sf.Name = sf.Company_Name_As_per_RERA__c;
            } else {
                sf.Name = sf.NAME_FIRST__c + ' ' + sf.NAME_LAST__c;
            }
            sf.STR_SUPPL1__c = sf.House_Flat_Company__c + ',' + sf.STREET__c;
            sf.Is_T_C_Accepted__c = true;
            sf.Channel_Partner_From_CP_Portal__c = true;
            system.debug('Inside istempcppresent');
            Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
            sf.RecordTypeId = CPRecordTypeId;
            
            
                /*
                //tempConverted = convertTempCP(tempcpno,sf);
                Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
                list<Broker__c> tempCP = [Select Id,Account__c from Broker__c where RW_Broker_Number__c =: sf.RW_Broker_Number__c and RecordTypeId =: TempCPRecordTypeId limit 1];
                system.debug('tempCP'+tempCP);
                if(!tempCP.isEmpty() && tempCP[0].Id != null){
                    system.debug('Inside istempcppresent Yes');
                    Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                    try{
                        tempCP[0].RecordTypeId = CPRecordTypeId;
                        tempCP[0] = copyFields(sf,tempCP[0]);
                        update tempCP[0]; 
                        if(tempCP[0].Account__c == null){
                            Set<Id> acID = new Set<Id>();
                            Account ac = new Account();                        
                            ac.Name = tempCP[0].Company_Name_As_per_RERA__c;
                            ac.CP_Email__c = tempCP[0].RW_Email__c;
                            ac.Mobile_No__c = tempCP[0].RW_Mobile_No__c;
                            ac.Channel_Partner__c = tempCP[0].id;
                            Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
                            ac.RecordTypeId = AccCPRecordTypeId;
                            insert ac;
                            acID.add(ac.Id);
                            if(!acID.isEmpty()){
                                //AccountTriggerHandler.createcontactCP(acID);
                                AccountTriggerHandler.UpdateCPAccountOnCP(acID);
                            }
                        }
                        return tempCP[0].Id;
                    }
                    catch(Exception e){
                        //if(!Test.isRunningTest()){
                        throw new AuraHandledException(e.getMessage());
                        //}
                    }  
                }*/
                /*else if(tempCP.isEmpty()){
system.debug('Inside istempcppresent empty');
try{
insert sf;
if(sf.Account__c == null){
Set<Id> acID = new Set<Id>();
Account ac = new Account();                        
ac.Name = sf.Company_Name_As_per_RERA__c;
ac.CP_Email__c = sf.RW_Email__c;
ac.Mobile_No__c = sf.RW_Mobile_No__c;
ac.Channel_Partner__c = sf.id;
Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
ac.RecordTypeId = AccCPRecordTypeId;
insert ac;
acID.add(ac.Id);
if(!acID.isEmpty()){
//AccountTriggerHandler.createcontactCP(acID);
AccountTriggerHandler.UpdateCPAccountOnCP(acID);
}
}
createCPCategory(new list<String>{sf.Id});
return sf.Id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}*/
                /*else{
                    system.debug('Inside Blank');
                    return 'No Temp CP Records Found';
                } */         
            
                
                system.debug('Inside last else');
                List<Broker__c> existingcp = new List<Broker__c>();
                /*if(isnri){
existingcp = [Select id,name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,TITLE__c,RW_RERA_Registration_Number__c,Account_Number__c,
IFSC_Code__c,RW_Mobile_No__c,RW_GST_Number__c,Is_NRI_CP__c,RW_Is_GST_Applicable__c,Bank_Name__c,Bank_Branch__c,
Cheque_DD_Favouring_Name__c,Team_Size__c,Are_you_NRI__c,IS_IGST_Applicable__c,House_Flat_Company__c,Place_of_Supply__c,
Company_Name__c,RW_Email__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,Individual_CP__c,Unregistered_Channel_Partner__c,
Company_Name_As_per_RERA__c,Project__c,Approver_L1__c,Approver_L2__c,Country__c,City__c,Pin_Code__c,Broker_Type__c,
Experience__c,Branch_Code__c,State__c,Dialing_Country_Code1__c,Expertise__c,Channel_Partner_From_CP_Portal__c,
Developers_Worked_For__c,Account__c from Broker__c where Broker_Pan_No__c=:sf.Broker_Pan_No__c];
if(!existingcp.isEmpty()){
existingcp[0].name = sf.name;
existingcp[0].NAME_FIRST__c = sf.NAME_FIRST__c;
existingcp[0].NAME_MIDDLE__c = sf.NAME_MIDDLE__c;
existingcp[0].NAME_LAST__c = sf.NAME_LAST__c;
existingcp[0].TITLE__c = sf.TITLE__c;
existingcp[0].RW_Email__c = sf.RW_Email__c;
existingcp[0].RW_RERA_Registration_Number__c = sf.RW_RERA_Registration_Number__c;
existingcp[0].Account_Number__c = sf.Account_Number__c;
existingcp[0].Cheque_DD_Favouring_Name__c = sf.Cheque_DD_Favouring_Name__c;
existingcp[0].IFSC_Code__c = sf.IFSC_Code__c;
existingcp[0].Branch_Code__c = sf.Branch_Code__c;
existingcp[0].Bank_Name__c = sf.Bank_Name__c;
existingcp[0].Bank_Branch__c = sf.Bank_Branch__c;
existingcp[0].RW_Mobile_No__c = sf.RW_Mobile_No__c;
existingcp[0].RW_GST_Number__c = sf.RW_GST_Number__c;
existingcp[0].House_Flat_Company__c = sf.House_Flat_Company__c;
existingcp[0].Company_Name_As_per_RERA__c = sf.Company_Name_As_per_RERA__c;
//existingcp[0].STREET__c = sf.STREET__c;
existingcp[0].STR_SUPPL1__c = sf.STR_SUPPL1__c;
existingcp[0].STR_SUPPL2__c = sf.STR_SUPPL2__c;
existingcp[0].STR_SUPPL3__c = sf.STR_SUPPL3__c;
existingcp[0].City__c = sf.City__c;
existingcp[0].State__c = sf.State__c;
existingcp[0].Country__c = sf.Country__c;
existingcp[0].Pin_Code__c = sf.Pin_Code__c;
existingcp[0].Broker_Type__c = sf.Broker_Type__c;
existingcp[0].Experience__c = sf.Experience__c;
existingcp[0].Dialing_Country_Code1__c = sf.Dialing_Country_Code1__c;
//existingcp[0].Expertise__c = sf.Expertise__c;
existingcp[0].Place_of_Supply__c = sf.Place_of_Supply__c;
existingcp[0].Team_Size__c = sf.Team_Size__c;
existingcp[0].Channel_Partner_From_CP_Portal__c = true;
//existingcp[0].Developers_Worked_For__c = sf.Developers_Worked_For__c;
existingcp[0].Project__c = sf.Project__c;
existingcp[0].Approver_L1__c = sf.Approver_L1__c;
existingcp[0].Approver_L2__c = sf.Approver_L2__c;
if (sf.Is_NRI_CP__c) {
existingcp[0].Is_NRI_CP__c = true;
} else {
existingcp[0].Is_NRI_CP__c = false;
}
if (sf.RW_Is_GST_Applicable__c) {
existingcp[0].RW_Is_GST_Applicable__c = true;
} else {
existingcp[0].RW_Is_GST_Applicable__c = false;
}
if (sf.Unregistered_Channel_Partner__c) {
existingcp[0].Unregistered_Channel_Partner__c = false;
} else {
existingcp[0].Unregistered_Channel_Partner__c = true;
}
if (sf.IS_IGST_Applicable__c == 'Yes') {
existingcp[0].IS_IGST_Applicable__c = 'Yes';
} else {
existingcp[0].IS_IGST_Applicable__c = 'No';
}
if (sf.Individual_CP__c) {
existingcp[0].Individual_CP__c = true;
} else {
existingcp[0].Individual_CP__c = false;
}
try{
update existingcp;

if(existingcp[0].Account__c == null){
Set<Id> acID = new Set<Id>();
Id ChannelPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
Account ac = new Account();
ac.Name = existingcp[0].Company_Name_As_per_RERA__c;
ac.CP_Email__c = existingcp[0].RW_Email__c;
ac.Mobile_No__c = existingcp[0].RW_Mobile_No__c;
ac.Channel_Partner__c = existingcp[0].id;
ac.RecordTypeId = ChannelPartnerId;
insert ac;
acID.add(ac.Id);
if(!acID.isEmpty()){
AccountTriggerHandler.createcontactCP(acID);
AccountTriggerHandler.UpdateCPAccountOnCP(acID);
}
}
return existingcp[0].id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}else{
try{
insert sf;
return sf.id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}


}
else{
existingcp = [Select id,name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,TITLE__c,RW_RERA_Registration_Number__c,Account_Number__c,
IFSC_Code__c,RW_Mobile_No__c,RW_GST_Number__c,Is_NRI_CP__c,RW_Is_GST_Applicable__c,Bank_Name__c,Bank_Branch__c,
Cheque_DD_Favouring_Name__c,Team_Size__c,Are_you_NRI__c,IS_IGST_Applicable__c,House_Flat_Company__c,Place_of_Supply__c,
Company_Name__c,RW_Email__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,Individual_CP__c,Unregistered_Channel_Partner__c,
Company_Name_As_per_RERA__c,Project__c,Approver_L1__c,Approver_L2__c,Country__c,City__c,Pin_Code__c,Broker_Type__c,
Experience__c,Branch_Code__c,State__c,Dialing_Country_Code1__c,Expertise__c,Channel_Partner_From_CP_Portal__c,
Developers_Worked_For__c,Account__c from Broker__c where Broker_Pan_No__c=:sf.Broker_Pan_No__c];
if(!existingcp.isEmpty()){
existingcp[0].name = sf.name;
existingcp[0].NAME_FIRST__c = sf.NAME_FIRST__c;
existingcp[0].NAME_MIDDLE__c = sf.NAME_MIDDLE__c;
existingcp[0].NAME_LAST__c = sf.NAME_LAST__c;
existingcp[0].TITLE__c = sf.TITLE__c;
existingcp[0].RW_Email__c = sf.RW_Email__c;
existingcp[0].RW_RERA_Registration_Number__c = sf.RW_RERA_Registration_Number__c;
existingcp[0].Account_Number__c = sf.Account_Number__c;
existingcp[0].Cheque_DD_Favouring_Name__c = sf.Cheque_DD_Favouring_Name__c;
existingcp[0].IFSC_Code__c = sf.IFSC_Code__c;
existingcp[0].Branch_Code__c = sf.Branch_Code__c;
existingcp[0].Bank_Name__c = sf.Bank_Name__c;
existingcp[0].Bank_Branch__c = sf.Bank_Branch__c;
existingcp[0].RW_Mobile_No__c = sf.RW_Mobile_No__c;
existingcp[0].RW_GST_Number__c = sf.RW_GST_Number__c;
existingcp[0].House_Flat_Company__c = sf.House_Flat_Company__c;
existingcp[0].Company_Name_As_per_RERA__c = sf.Company_Name_As_per_RERA__c;
//existingcp[0].STREET__c = sf.STREET__c;
existingcp[0].STR_SUPPL1__c = sf.STR_SUPPL1__c;
existingcp[0].STR_SUPPL2__c = sf.STR_SUPPL2__c;
existingcp[0].STR_SUPPL3__c = sf.STR_SUPPL3__c;
existingcp[0].City__c = sf.City__c;
existingcp[0].State__c = sf.State__c;
existingcp[0].Country__c = sf.Country__c;
existingcp[0].Pin_Code__c = sf.Pin_Code__c;
existingcp[0].Broker_Type__c = sf.Broker_Type__c;
existingcp[0].Experience__c = sf.Experience__c;
existingcp[0].Dialing_Country_Code1__c = sf.Dialing_Country_Code1__c;
//existingcp[0].Expertise__c = sf.Expertise__c;
existingcp[0].Place_of_Supply__c = sf.Place_of_Supply__c;
existingcp[0].Team_Size__c = sf.Team_Size__c;
existingcp[0].Channel_Partner_From_CP_Portal__c = true;
//existingcp[0].Developers_Worked_For__c = sf.Developers_Worked_For__c;
existingcp[0].Project__c = sf.Project__c;
existingcp[0].Approver_L1__c = sf.Approver_L1__c;
existingcp[0].Approver_L2__c = sf.Approver_L2__c;
if (sf.Is_NRI_CP__c) {
existingcp[0].Is_NRI_CP__c = true;
} else {
existingcp[0].Is_NRI_CP__c = false;
}
if (sf.RW_Is_GST_Applicable__c) {
existingcp[0].RW_Is_GST_Applicable__c = true;
} else {
existingcp[0].RW_Is_GST_Applicable__c = false;
}
if (sf.Unregistered_Channel_Partner__c) {
existingcp[0].Unregistered_Channel_Partner__c = false;
} else {
existingcp[0].Unregistered_Channel_Partner__c = true;
}
if (sf.IS_IGST_Applicable__c == 'Yes') {
existingcp[0].IS_IGST_Applicable__c = 'Yes';
} else {
existingcp[0].IS_IGST_Applicable__c = 'No';
}
if (sf.Individual_CP__c) {
existingcp[0].Individual_CP__c = true;
} else {
existingcp[0].Individual_CP__c = false;
}
try{
update existingcp;
if(existingcp[0].Account__c == null){
Set<Id> acID = new Set<Id>();
Id ChannelPartnerId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
Account ac = new Account();
ac.Name = existingcp[0].Company_Name_As_per_RERA__c;
ac.CP_Email__c = existingcp[0].RW_Email__c;
ac.Mobile_No__c = existingcp[0].RW_Mobile_No__c;
ac.Channel_Partner__c = existingcp[0].id;
ac.RecordTypeId = ChannelPartnerId;
insert ac;
acID.add(ac.Id);
if(!acID.isEmpty()){
AccountTriggerHandler.createcontactCP(acID);
AccountTriggerHandler.UpdateCPAccountOnCP(acID);
}
}
return existingcp[0].id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}else{
try{
insert sf;
return sf.id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}
}*/
                
                /*existingcp = [Select id,name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,TITLE__c,RW_RERA_Registration_Number__c,Account_Number__c,
IFSC_Code__c,RW_Mobile_No__c,RW_GST_Number__c,Is_NRI_CP__c,RW_Is_GST_Applicable__c,Bank_Name__c,Bank_Branch__c,
Cheque_DD_Favouring_Name__c,Team_Size__c,Are_you_NRI__c,IS_IGST_Applicable__c,House_Flat_Company__c,Place_of_Supply__c,
Company_Name__c,RW_Email__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,Individual_CP__c,Unregistered_Channel_Partner__c,
Company_Name_As_per_RERA__c,Project__c,Approver_L1__c,Approver_L2__c,Country__c,City__c,Pin_Code__c,Broker_Type__c,
Experience__c,Branch_Code__c,State__c,Dialing_Country_Code1__c,Expertise__c,Channel_Partner_From_CP_Portal__c,
Developers_Worked_For__c,Account__c from Broker__c where Broker_Pan_No__c=:sf.Broker_Pan_No__c];
if(!existingcp.isEmpty()){
system.debug('Inside else existingcp');
existingcp[0] = copyFields(sf, existingcp[0]);                
try{  
update existingcp;
if(existingcp[0].Account__c == null){
Set<Id> acID = new Set<Id>();
Account ac = new Account();                        
ac.Name = existingcp[0].Company_Name_As_per_RERA__c;
ac.CP_Email__c = existingcp[0].RW_Email__c;
ac.Mobile_No__c = existingcp[0].RW_Mobile_No__c;
ac.Channel_Partner__c = existingcp[0].id;
Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
ac.RecordTypeId = AccCPRecordTypeId;
insert ac;
acID.add(ac.Id);
if(!acID.isEmpty()){
//AccountTriggerHandler.createcontactCP(acID);
AccountTriggerHandler.UpdateCPAccountOnCP(acID);
}
}
createCPCategory(new list<String>{existingcp[0].Id});
return existingcp[0].id;
}catch(Exception e){
throw new AuraHandledException(e.getMessage());
}
}*/
                // else{
                system.debug('Inside else else');
                try{
                    
                    upsert sf;
                    if(sf.Id != null){
                        try{
                            List<Lead> leadList = [SELECT Id FROM Lead WHERE RW_Broker__c =: sf.Id AND LeadSource = 'Temp Channel Partner' AND IsConverted = false]; 
                            System.debug('leadList: ' + leadList);
                            for(Lead ld : leadList){
                                ld.LeadSource = 'Channel Partner';
                                ld.RW_Broker__c = sf.Id;                                
                            }
                            update leadList;
                            
                            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE RW_Broker__c =: sf.Id AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner')];
                            for(Opportunity opp : opps){
                                opp.LeadSource = 'Channel Partner';
                                opp.Walkin_Source__c = 'Channel Partner';
                                opp.RW_Broker__c = sf.Id;
                                opp.RW_Walkin_Channel_Partner__c = sf.Id;
                            }
                            update opps;
                            
                            List<Prospect__c> prospects = [SELECT Id FROM Prospect__c WHERE Channel_Partner__c =: sf.Id AND Lead_Source__c  = 'Temp Channel Partner'];
                            for(Prospect__c pros : prospects){
                                pros.Lead_Source__c  = 'Channel Partner';
                            }
                            update prospects;
                            
                            List<Booking__c> bookings = [SELECT Id FROM Booking__c WHERE BrokerIId__c =: sf.Id AND Source_of_Booking__c = 'Temp Channel Partner'];
                            for(Booking__c bkg : bookings){
                                bkg.Source_of_Booking__c = 'Channel Partner';
                            }
                            update bookings;
                            
                            List<OTP__c> otps = [SELECT Id FROM OTP__c WHERE Channel_Partner_Lookup__c =: sf.Id AND OTP_Generate_For__c = 'Temp Channel Partner'];
                            for(OTP__c otp : otps){
                                otp.OTP_Generate_For__c = 'Channel Partner';
                            }
                            update otps;
                            
                        }catch(Exception e){
                            if(!Test.isRunningTest()){
                                throw new AuraHandledException(e.getMessage());
                            }
                        }
                    }
                    if(sf.Account__c == null){
                        Set<Id> acID = new Set<Id>();
                        Account ac = new Account();                        
                        ac.Name = sf.Company_Name_As_per_RERA__c;
                        ac.CP_Email__c = sf.RW_Email__c;
                        ac.Mobile_No__c = sf.RW_Mobile_No__c;
                        ac.Channel_Partner__c = sf.id;
                        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
                        ac.RecordTypeId = AccCPRecordTypeId;
                        insert ac;
                        acID.add(ac.Id);
                        if(!acID.isEmpty()){
                            //AccountTriggerHandler.createcontactCP(acID);
                            AccountTriggerHandler.UpdateCPAccountOnCP(acID);
                        }
                    }
                    return sf.id;
                }catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }             
                //}
            
        } else{return null;}
    }
    
    
     @AuraEnabled
    public static String isDuplicateCPExist(Broker__c bk) {
        if (bk == null) {
            return null;
        }
        
        list<Broker__c> existing;
        if(bk.Id != null){
            existing = [
                SELECT Id, Name, RW_Mobile_No__c, Broker_Pan_No__c, RW_Email__c
                FROM Broker__c
                WHERE Id != :bk.Id
                AND (
                    RW_Mobile_No__c = :bk.RW_Mobile_No__c
                    OR Broker_Pan_No__c = :bk.Broker_Pan_No__c
                    OR RW_Email__c = :bk.RW_Email__c
                )
                LIMIT 1
            ];
        }else{
            existing = [
                SELECT Id, Name, RW_Mobile_No__c, Broker_Pan_No__c, RW_Email__c
                FROM Broker__c
                WHERE 
                RW_Mobile_No__c = :bk.RW_Mobile_No__c
                OR Broker_Pan_No__c = :bk.Broker_Pan_No__c
                OR RW_Email__c = :bk.RW_Email__c
                LIMIT 1
            ];
        }
        system.debug('Existing -> '+existing);
        if (existing.isEmpty()) {
            return null;
        }else{
            Boolean mobileMatch = existing[0].RW_Mobile_No__c == bk.RW_Mobile_No__c;
            Boolean panMatch = existing[0].Broker_Pan_No__c == bk.Broker_Pan_No__c;
            Boolean emailMatch = existing[0].RW_Email__c == bk.RW_Email__c;
            
            if (mobileMatch && panMatch && emailMatch) {
                return 'Duplicate exists with Mobile: ' + bk.RW_Mobile_No__c 
                    + ', PAN: ' + bk.Broker_Pan_No__c 
                    + ', and Email: ' + bk.RW_Email__c;
            } else if (mobileMatch && panMatch) {
                return 'Duplicate exists with Mobile: ' + bk.RW_Mobile_No__c 
                    + ' and PAN: ' + bk.Broker_Pan_No__c;
            } else if (mobileMatch && emailMatch) {
                return 'Duplicate exists with Mobile: ' + bk.RW_Mobile_No__c 
                    + ' and Email: ' + bk.RW_Email__c;
            } else if (panMatch && emailMatch) {
                return 'Duplicate exists with PAN: ' + bk.Broker_Pan_No__c 
                    + ' and Email: ' + bk.RW_Email__c;
            } else if (mobileMatch) {
                return 'Duplicate exists with Mobile: ' + bk.RW_Mobile_No__c;
            } else if (panMatch) {
                return 'Duplicate exists with PAN: ' + bk.Broker_Pan_No__c;
            } else if (emailMatch) {
                return 'Duplicate exists with Email: ' + bk.RW_Email__c;
            }
        }
        return null; 
    }
    
    //Added by Prashant.////
    @AuraEnabled(cacheable=true)
    public static list<Broker__c> getTempCPData(String brokerUniqueId){
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        if (String.isNotBlank(brokerUniqueId)) {
            return [Select Id,Name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,Broker_Pan_No__c,RW_Broker_Number__c,RW_Email__c,RW_Mobile_No__c,Company_Name__c from Broker__c where RW_Broker_Number__c =: brokerUniqueId and RecordTypeId=:tempRecordTypeId ];
        }
        return null;
    } 
    
    @AuraEnabled(cacheable=true)
    public static list<Broker__c> getExistingCPData(String brId){
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        if (String.isNotBlank(brId)) {
            return [Select id,name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,TITLE__c,RW_RERA_Registration_Number__c,Account_Number__c,
                          IFSC_Code__c,RW_Mobile_No__c,RW_GST_Number__c,Is_NRI_CP__c,RW_Is_GST_Applicable__c,Bank_Name__c,Bank_Branch__c,
                          Cheque_DD_Favouring_Name__c,Team_Size__c,Are_you_NRI__c,IS_IGST_Applicable__c,House_Flat_Company__c,Place_of_Supply__c,
                          Company_Name__c,RW_Email__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,Individual_CP__c,Unregistered_Channel_Partner__c,
                          Company_Name_As_per_RERA__c,Project__c,Approver_L1__c,Approver_L2__c,Country__c,City__c,Pin_Code__c,Broker_Type__c,
                          Experience__c,Branch_Code__c,State__c,Dialing_Country_Code1__c,Expertise__c,Channel_Partner_From_CP_Portal__c,
                          Developers_Worked_For__c,Account__c,RW_Broker_Number__c,Broker_Pan_No__c,RERA_Valid_till__c,CC_Valid_till__c,STREET__c,
                            RW_Is_CC_Applicable__c
                    from Broker__c where Id =: brId and RecordTypeId=:CPRecordTypeId ];
        }
        return null;
    } 

    //Added by Prashant 06-09-25. Upload Files New Logic
    @AuraEnabled
    public static String uploadFile(String base64, String filename, String recordId, String docType) {
        try {
            System.debug('uploadFile called with -> base64 length=' + (String.isNotBlank(base64) ? base64.length() : 0));
            System.debug('filename (actual file) = ' + filename);
            System.debug('docType (logical title) = ' + docType);
            System.debug('recordId = ' + recordId);
            
            if (String.isBlank(base64) || String.isBlank(filename) || String.isBlank(recordId) || String.isBlank(docType)) {
                throw new AuraHandledException('Invalid parameters for file upload.');
            }
            
            // Find existing docs linked to this record
            List<ContentDocumentLink> existingLinks = [
                SELECT ContentDocumentId, ContentDocument.Title
                FROM ContentDocumentLink  
                WHERE LinkedEntityId = :recordId 
                ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
            ];
            System.debug('existingLinks size = ' + existingLinks.size());
            
            for (ContentDocumentLink cdl : existingLinks) {
                System.debug('Checking existing doc -> Title=' + cdl.ContentDocument.Title + ', Id=' + cdl.ContentDocumentId);
                if (cdl.ContentDocument.Title == docType) {
                    ContentVersion newVersion = new ContentVersion(
                        ContentDocumentId = cdl.ContentDocumentId,
                        VersionData = EncodingUtil.base64Decode(base64),
                        Title = docType, 
                        PathOnClient = filename
                    );
                    insert newVersion;
                    System.debug('Added new version for docType=' + docType + ' -> ContentDocumentId=' + cdl.ContentDocumentId);
                    return cdl.ContentDocumentId;
                }
            }
            
            // Else create new ContentVersion + link
            ContentVersion cv = new ContentVersion(
                VersionData  = EncodingUtil.base64Decode(base64),
                Title = docType,
                PathOnClient = filename
            );
            insert cv;
            System.debug('Inserted new ContentVersion -> Id=' + cv.Id);
            
            // Fetch ContentDocumentId from inserted ContentVersion
            Id docId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :cv.Id
                LIMIT 1
            ].ContentDocumentId;
            System.debug('Derived ContentDocumentId=' + docId);
            
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = docId,
                LinkedEntityId = recordId,
                ShareType = 'V'
            );
            insert cdl;
            System.debug('Linked docId=' + docId + ' to record=' + recordId);
            
            return docId; 
        } catch (Exception e) {
            System.debug('ERROR in uploadFile: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Upload failed: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<ContentDocumentLink> fetchFiles(String recordId){
        return [SELECT LinkedEntityId, ContentDocument.CreatedDate,
                ContentDocument.Title, ContentDocumentId,
                ContentDocument.ContentSize, ContentDocument.FileType,ContentDocument.LastModifiedDate
                 FROM ContentDocumentLink  
                WHERE LinkedEntityId  =:recordId Order by ContentDocument.LastModifiedDate DESC];
    }
    
    //Added by Prashant 06-09-25. Upload Files New Logic
    

    //fetch picklist values from custom object in lwc
    
    @AuraEnabled(cacheable=true)
    public static List < customValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
        
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();
        
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();
        
        list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        
        for (Schema.PicklistEntry myCustPick: custPickValues) {
            
            customValueWrapper selectOptionValueWrapper = new customValueWrapper();
            
            selectOptionValueWrapper.custFldlabel = myCustPick.getLabel();
            
            selectOptionValueWrapper.custFldvalue = myCustPick.getValue();
            
            customObjWrapper.add(selectOptionValueWrapper);
            
        }
        
        return customObjWrapper;
        
    }
    
    // wrapper class
    
    public with sharing class customValueWrapper {
        
        @auraEnabled 
        public string custFldlabel {get;set;}
        
        @auraEnabled 
        public string custFldvalue {get;set;}
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List < customValueWrapper > getProjectList() {
        list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
        list <Project__c> plist = [Select Id,Name From Project__c where RW_Status__c = 'Active'];
        for(Project__c p:plist){
            customValueWrapper selectOptionValueWrapper = new customValueWrapper();
            selectOptionValueWrapper.custFldlabel = p.Name;
            selectOptionValueWrapper.custFldvalue = p.Name;
            customObjWrapper.add(selectOptionValueWrapper);
        }   
        system.debug('customObjWrapper::'+customObjWrapper);
        return customObjWrapper;
        
    }
    
    @AuraEnabled
    public static void registrationcomplete(String CPId) {
        Broker__c b = new Broker__c();
        b.Id = CPId;
        b.Registration_Complete__c = true;
        try{
            Update b;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List <String> getApprovers(String pname) {
        list <String> ApproversId = new list <String> ();
        // list <Project__c> plist = [Select Id,Name,Project_Location__r.CP_MIS__c,Project_Location__r.CP_Sourcing_Head__c From Project__c where Name =: pname];
        // if(!plist.isEmpty()){
        //     ApproversId.add(plist[0].Project_Location__r.CP_MIS__c);
        //     ApproversId.add(plist[0].Project_Location__r.CP_Sourcing_Head__c);
        // } 

        list<CP_Invoice_Approvers_list_CS__c> cpcustomSettingList = [select id,Name, CP_MIS__c, CP_Sourcing_Head__c from CP_Invoice_Approvers_list_CS__c where Name =: pname];
        if(!cpcustomSettingList.isEmpty()){
            ApproversId.add(cpcustomSettingList[0].CP_MIS__c);
            ApproversId.add(cpcustomSettingList[0].CP_Sourcing_Head__c);
           // ApproversId.add('0055j000007G2SJAA0');
            //ApproversId.add('0055j000007G2SJAA0');
        } 
        System.debug('ApproversId'+ApproversId);
        return ApproversId;
        
    }
    
    
    //Added by Prashant 21-08-25. // Upload RERA n CC details and Submit record for approval.
    @AuraEnabled
    public static void updateDocDetailsnSubmitforAppr(Boolean isrera, Boolean iscc, String brId, Date reraExpDate,Date ccExpDate) {
        system.debug('Broker Id - '+brId);
        if(String.isNotBlank(brId)){
            list<Broker__c> brlist = new list<Broker__c>();
            Broker__c b = new Broker__c();
            b.Id = brId;
            if(isrera){
                b.RERA_Valid_till__c = reraExpDate;
                b.Latest_RERA_Upload_Status__c = 'Approval Pending';
                b.Latest_RERA_Upload_Processed__c = false;
            }
            if(iscc){
                b.CC_Valid_till__c = ccExpDate;
                b.Latest_CC_Upload_Status__c = 'Approval Pending';
                b.Latest_CC_Upload_Processed__c = false;
            }
            brlist.add(b);
            try{
                update brlist;
            }catch(DMLException e) {
                System.debug(e);
            }
        }else{
            system.debug('No Broker Id found');
        }	
        
    }
    //Added by Prashant 21-08-25. // Upload RERA n CC details and Submit record for approval.

    @AuraEnabled(cacheable=false)
    public static List<Broker__c> getBrokerDetails(Id CPUserId) {
        if (String.isBlank(CPUserId)) {
            return null;
        }else {
            return [SELECT Id, Name,Valid_competency_certificate__c,Valid_RERA_certificate__c,Latest_CC_Upload_Status__c,Latest_RERA_Upload_Status__c FROM Broker__c WHERE Account__c IN (SELECT AccountId FROM User WHERE Id =: CPUserId) LIMIT 1];
        }
    }
    
     @AuraEnabled
    public static Id createTempCP(Broker__c bk) {
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        bk.RecordTypeId = tempRecordTypeId;     
        bk.Sourcing_Manager__c = UserInfo.getUserId();
        try{
            insert bk;
            if(bk.Id != null){                
                Id cpRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                Task t = new Task();
                t.WhatId = bk.id;
                t.OwnerId = UserInfo.getUserId();
                Date todayDate = System.today();
                DateTime createTime = DateTime.now();                
                t.ActivityDate = system.today().addDays(15);                    
                t.Status = 'In-progress';
                String subject = 'Temporary CP Registration Pending – '+ bk.Name;
                t.Subject = subject;
                //t.Task_Type__c = '';
                t.Type = 'Other';
                t.Task_Type__c = 'CP Call';
                t.RecordTypeId = cpRecordTypeId;
                t.Priority = 'Normal';                    
                String nbody1 = 'Kindly ensure that the registration is completed at the earliest to avoid delays in onboarding, payment, or portal access.\nRegards,';
                t.Description = nbody1; 
                t.ReminderDateTime = System.now();
                t.IsReminderSet = true; 
                try{
                    insert t;
                }catch(Exception e){
                    throw new AuraHandledException(e.getMessage());
                }
                
                return bk.id;                  
            }
        } catch (Exception e) {
            String cleanMessage;
            
            if (e instanceof DmlException) {
                DmlException de = (DmlException)e;
                if (de.getNumDml() > 0 && String.isNotBlank(de.getDmlMessage(0))) {
                    cleanMessage = de.getDmlMessage(0); // Show only adderror from trigger
                } else {
                    cleanMessage = de.getMessage();
                }
            } else {
                cleanMessage = e.getMessage(); // Handle non-DML exceptions
            }

    throw new AuraHandledException(cleanMessage);
}

        return null;
    }
    

    
}