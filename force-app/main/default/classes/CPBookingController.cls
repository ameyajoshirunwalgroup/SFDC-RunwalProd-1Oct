public without sharing class CPBookingController {
   /* @AuraEnabled(cacheable = true)
    public static list<Booking__c> getBookingList(){
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<Booking__c> bookinglist = new List<Booking__c>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        if(!user.isEmpty()){
            CPId = user[0].Id;
        }
        contact =[select id,Name,Email from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].id];
        
        bookinglist = [SELECT Id , Name From Booking__c ];
        
        System.debug('bookinglist::'+ bookinglist);
        return bookinglist; 
    }
    */
    
    
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
                            List<Lead> leadList = [SELECT Id FROM Lead WHERE RW_Broker__c =: sf.Id AND LeadSource = 'Temp Channel Partner']; 
                            System.debug('leadList: ' + leadList);
                            for(Lead ld : leadList){
                                ld.LeadSource = 'Channel Partner';
                            }
                            update leadList;
                            
                            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE RW_Broker__c =: sf.Id AND (LeadSource = 'Temp Channel Partner' OR Walkin_Source__c = 'Temp Channel Partner')];
                            for(Opportunity opp : opps){
                                opp.LeadSource = 'Channel Partner';
                                opp.Walkin_Source__c = 'Channel Partner';
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
    
    
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> returnFiles(List<String> lstFileIds, Id recId) {
        System.debug('lstFileIds:: ' + lstFileIds);
        System.debug('recId:: ' + recId);
        
        List<ContentVersion> result = new List<ContentVersion>();
        
        if (recId != null) {
            list<ContentDocumentLink> ContentDocumentLinklist = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recId];
            list<Id> ContentDocumentIds = new list<Id>();
            if(!ContentDocumentLinklist.isEmpty()){
                for(ContentDocumentLink cdl : ContentDocumentLinklist){
                    ContentDocumentIds.add(cdl.ContentDocumentId);
                }
            }
            if(!ContentDocumentIds.isEmpty()){
                result = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: ContentDocumentIds];
            }
            
        }
        else if (lstFileIds != null && !lstFileIds.isEmpty()) {
            result = [
                SELECT Id, Title, ContentDocumentId
                FROM ContentVersion
                WHERE Id IN :lstFileIds
            ];
        }
        system.debug('Result -> '+result);
        return result;
    }

    
    @AuraEnabled
    public static list<ContentVersion> returnAllFiles(list<Object> allfiles){
        System.debug('allfiles::'+ allfiles);
        //Fileupload2 fileData1 = (Fileupload2)JSON.deserialize(allfiles, Fileupload2.class);
        //System.debug('fileData1::'+ fileData1);
        list<String> lstCntVerIds = new list<String>();
        for(Object fid :allfiles){
            System.debug('serialize::'+ JSON.serialize(fid));
            List<String> splitList = new List<String>();
            List<String> splitList2 = new List<String>();
            system.debug('fid::'+String.valueOf(fid).split('\\('));
            splitList = String.valueOf(fid).split('\\(');
            system.debug('splitList::'+splitList[1]);
            splitList2 = splitList[1].split('\\)');
            system.debug('splitList::'+splitList2[0]);
            //Fileupload2 fileData1 = (Fileupload2)JSON.deserialize(JSON.serialize(fid), Fileupload2.class);
            lstCntVerIds.add(splitList2[0]); 
        }
        system.debug('lstCntVerIds::'+lstCntVerIds);
        return [SELECT Id, Title,ContentDocumentId FROM ContentVersion WHERE Id IN :lstCntVerIds];
    }
    
    @AuraEnabled
    public static list<Id> saveFiles(list<Object> filesToInsert,String recId){
        system.debug('filesToInsert::'+filesToInsert);
        list<Id> lstCntVerIds = new list<Id>();
        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        for (Object file : filesToInsert) {
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileData.Title;
            objCntVersion.Title = fileData.Title;
            objCntVersion.VersionData = fileData.VersionData;
            objCntVersion.Origin = 'C';
            system.debug('fileData.documentId::'+fileData.documentId);
            //createContentLink(fileData.documentId, recId);
            lstVersionsToInsert.add(objCntVersion);
        }
        
        list<Database.saveResult> res = Database.insert(lstVersionsToInsert);
        for (Database.SaveResult saveResult : res) {
            if(saveResult.isSuccess()) {
                lstCntVerIds.add(saveResult.getId());
            }
        }
        
        return lstCntVerIds;
    }
    
    
    public class FileInfo {
        public String Title;
        public String documentId;
        public Blob VersionData;
    }
    public class Fileupload {
        public String name;
        public String contentVersionId;
        public Blob contentBodyId;
    }
    public class Fileupload2 {
        public String cverId { get; set; }
    }
    
    @AuraEnabled
    public static list<Id> createContentLink(list<Object> uploadedfile, String recId, String docType) {
        System.debug('uploadedfile::'+ uploadedfile);
        System.debug('recordId::'+ recId);
        List<Id> cvId = new List<Id>();
        List<ContentDocumentLink >  cdlupdate = new List<ContentDocumentLink >();
        List<ContentVersion> cv = new List<ContentVersion>();
        for (Object file : uploadedfile) {
            Fileupload fileData = (Fileupload)JSON.deserialize(JSON.serialize(file), Fileupload.class);
            System.debug('contentVersionId::'+ fileData.contentVersionId);
            cvId.add(fileData.contentVersionId);
        }
        if(!cvId.isEmpty()){
            cv = [Select id,title,ContentDocumentId  from ContentVersion where id IN:cvId];
            if(!cv.isEmpty()){
                for (ContentVersion cc : cv) {
                    cc.Title = docType;
                    ContentDocumentLink  cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cc.ContentDocumentId ;
                    cdl.LinkedEntityId  = recId;
                    cdl.ShareType = 'V';
                    cdlupdate.add(cdl);
                }
                update cv;
            }
        }
        try {
            insert cdlupdate;
        } catch(DMLException e) {
            System.debug(e);
        }
        return cvId;      
    }
    
    //Added by Prashant -- 13-08-2025.
    @AuraEnabled
    public static list<Id> createContentLink2(list<Object> uploadedfile, String recId) {
        System.debug('uploadedfile::'+ uploadedfile);
        System.debug('recordId::'+ recId);
        
        list<Broker__c> brlist = [SELECT Id, Name FROM Broker__c WHERE Account__c IN (SELECT AccountId FROM User WHERE Id =: recId)];
        String brId;
        if(!brlist.isEmpty()){
            brId = brlist[0].Id;   
        }else{
            brId = UserInfo.getUserId();
        }
              
        List<Id> cvId = new List<Id>();
        List<ContentDocumentLink >  cdlupdate = new List<ContentDocumentLink >();
        List<ContentVersion> cv = new List<ContentVersion>();
        for (Object file : uploadedfile) {
            Fileupload fileData = (Fileupload)JSON.deserialize(JSON.serialize(file), Fileupload.class);
            System.debug('contentVersionId::'+ fileData.contentVersionId);
            cvId.add(fileData.contentVersionId);
        }
        if(!cvId.isEmpty()){
            cv = [Select id,title,ContentDocumentId  from ContentVersion where id IN:cvId];
            if(!cv.isEmpty()){
                for (ContentVersion cc : cv) {
                    ContentDocumentLink  cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = cc.ContentDocumentId ;
                    cdl.LinkedEntityId  = brId;
                    cdl.ShareType = 'V';
                    cdlupdate.add(cdl);
                }
            }
        }
        try {
            insert cdlupdate;
        } catch(DMLException e) {
            System.debug(e);
        }
        return cvId;      
    }
    //Added by Prashant -- 13-08-2025.
    //
    //
    
    
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

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        insert cv;
        return cv;
    }
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) return null;
        Id docId = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :contentVersionId
            LIMIT 1
        ].ContentDocumentId;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = docId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        insert cdl;
        return cdl;
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
    
    
    @AuraEnabled
    public static List<ContentVersion> getCollateralsA() {
        List<Collateral__c> clist = [Select id,name from Collateral__c];
        Set<Id> contentDocumentId = new Set<Id>();
        Set<Id> contentDocumentLinkIds = new Set<Id>();
        for (Integer i = 0; i < clist.size(); i++) {
            List<ContentDocumentLink> contentDocumentcollaterals = new List<ContentDocumentLink>();
            contentDocumentcollaterals = [SELECT ContentDocumentId, LinkedEntityId 
                                          FROM   ContentDocumentLink 
                                          WHERE  LinkedEntityId =: clist[i].id];
            for(ContentDocumentLink u : contentDocumentcollaterals){
                contentDocumentId.add(u.ContentDocumentId);
            }
        } 
        
        
        system.debug('ContentVersion::'+[SELECT Id, Title, FileExtension, ContentDocumentId From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId]);
        return [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate
                From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId];
    }
    @AuraEnabled
    public static List<ContentVersion> getCollateralsB() {
        List<Collateral__c> clist = [Select id,name from Collateral__c];
        Set<Id> contentDocumentId = new Set<Id>();
        Set<Id> contentDocumentLinkIds = new Set<Id>();
        for (Integer i = 0; i < clist.size(); i++) {
            List<ContentDocumentLink> contentDocumentcollaterals = new List<ContentDocumentLink>();
            contentDocumentcollaterals = [SELECT ContentDocumentId, LinkedEntityId 
                                          FROM   ContentDocumentLink 
                                          WHERE  LinkedEntityId =: clist[i].id];
            for(ContentDocumentLink u : contentDocumentcollaterals){
                contentDocumentId.add(u.ContentDocumentId);
            }
        } 
        
        
        system.debug('ContentVersion::'+[SELECT Id, Title, FileExtension, ContentDocumentId From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId]);
        return [SELECT Id, Title, FileExtension,ContentSize,Description, ContentDocumentId,CreatedDate
                From ContentVersion WHERE  ContentDocumentId IN : contentDocumentId];
    }
    
    //Added by Prashant 21-08-25. // Upload RERA n CC details and Submit record for approval.
    @AuraEnabled
    public static void updateDocDetailsnSubmitforAppr(Boolean isrera,/* Boolean iscc,*/ String brId, Date reraExpDate,Date ccExpDate) {
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
            /*if(iscc){
                b.CC_Valid_till__c = ccExpDate;
                b.Latest_CC_Upload_Status__c = 'Approval Pending';
                b.Latest_CC_Upload_Processed__c = false;
            }*///Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
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
    public static List<Brokerage_Invoice__c> getInvoice( String searchKey, String sortBy, String sortDirection, String searchKeystatus) {
        system.debug('searchKey::'+searchKey);
        system.debug('sortBy::'+sortBy);
        system.debug('sortDirection::'+sortDirection);
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].id;
        }
        System.debug('AccList '+ AccList);
        String a = 'Approved By L1';
        String b = 'Approved By L2';

        String query = 'SELECT Id, Name,Invoice_Number__c,RW_Eligible_Slab__c,Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Eligible_Slab__c,Brokerage_Lookup__c,Status__c,Project__c,Tower_Unit__c,Customer_Name__c,Brokerage_Scheme_Name__c FROM Brokerage_Invoice__c where ( Approval_Status_clearing__c =:a or Approval_Status_clearing__c =: b)  and Brokerage_Summary__r.CP_Account__c =' + '\''+ CPId +'\'';
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' and Invoice_Number__c LIKE :key';
        }
        if ( searchKeystatus != null && searchKeystatus != '' ) {
            String key2 = '%' + searchKeystatus + '%';
            query += ' and Invoice_Status__c LIKE :key2';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }

    //Added by coServe 31-05-2024 Start
    @AuraEnabled(cacheable=true)
    public static List<Brokerage_Invoice__c> getCpMandateInvoice( String searchKey, String sortBy, String sortDirection, String searchKeystatus) {

        Id loggeduserId = UserInfo.getUserId();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        List<Contact> contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        List<Account> AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        

        List<Broker__c> brokers = [SELECT Id FROM Broker__c WHERE Account__c =: AccList[0].Id];
        String brId;
        if(brokers.size() > 0){
            brId = brokers[0].Id;
        }
        
        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();


        String query = 'SELECT Id, Name,Invoice_Number__c,RW_Eligible_Slab__c,Invoice_Status__c,Invoice_Status_Brokerage_invoice__c,Eligible_Slab__c,Brokerage_Lookup__c,Status__c,Project__c,Tower_Unit__c,Customer_Name__c,Brokerage_Scheme_Name__c FROM Brokerage_Invoice__c where (Approval_Status_clearing__c = \'Approved By L1\' OR Approval_Status_clearing__c = \'Approved By L2\') AND AOP__r.RecordTypeId =: recordTypeId AND Channel_Partner__c =: brId';
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' and Invoice_Number__c LIKE :key';
        }
        if ( searchKeystatus != null && searchKeystatus != '' ) {
            String key2 = '%' + searchKeystatus + '%';
            query += ' and Invoice_Status__c LIKE :key2';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }
    //Added by coServe 31-05-2024 End

    @AuraEnabled(cacheable=true)
    public static List<Brokerage_Summary__c> getBrokerageSummary( String BssearchKey, String searchKeyBooking) {
        system.debug('BssearchKey::'+BssearchKey);
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].id;
        }
        System.debug('AccList '+ AccList);
        String query = 'SELECT Id, Name,Base_Brokerage__c,Additional_Brokerage__c,Brokerage__c,Applied_Slab_Name__c,Total_Agreement_Value__c,Total_Brokerage__c,Status__c,Brokerage_Scheme_Name__c,Booking_Name__c,Customer_Name__c,Tower_Unit__c,Project__c FROM Brokerage_Summary__c where CP_Account__c =' + '\''+ CPId +'\'';
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( BssearchKey != null && BssearchKey != '' ) {
            String key = BssearchKey + '%';
            query += ' and Status__c LIKE :key';
        }
        if ( searchKeyBooking != null && searchKeyBooking != '' ) {
            String key2 = '%' + searchKeyBooking + '%';
            query += ' and Booking_Name__c LIKE :key2';
        }
        
        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }
    //uncommented by vaishnavi 12/09/2025
    @AuraEnabled 
    public static String getPdfFileAsBase64String(String invId) {
        PageReference pageRef = new PageReference('/apex/ShowInvoicePreview');
        pageRef.getParameters().put('id',invId);
        Blob pdfBlob = pageRef.getContent();
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
    /********/
    @AuraEnabled(cacheable=true)
    public static List<OTP__c> getOTPs( String custname, String projectname) {
        system.debug('custname::'+custname);
        system.debug('projectname::'+projectname);
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].id;
        }
        System.debug('AccList '+ AccList);
        String query = 'SELECT Id, Name,Customer_Name__c,Customer_Site_Visit_On__c,Generated_OTP__c,OTP_Generated_on__c,Sourcing_Manager__c,Project_Name__c FROM OTP__c where OTP_Expired__c = false and Account__c =' + '\''+ CPId +'\'';
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( custname != null && custname != '' ) {
            String key = '%' + custname + '%';
            query += ' and Customer_Name__c LIKE :key';
        }
        if ( projectname != null && projectname != '' ) {
            String key2 = '%' + projectname + '%';
            query += ' and Project_Name__c LIKE :key2';
        }
        
        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> CPKickerBookings(String kickerId) {
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].id;
        }
        System.debug('AccList '+ AccList);
        String query = 'SELECT Id, Name,Unit_Number__c,RW_Project_Name__c,Agreement_Value_for_brokers__c FROM Booking__c where Account__c =' + '\''+ CPId +'\'and Kicker_Incentive_lookup__c =' + '\''+ kickerId +'\'';
        
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }
    @AuraEnabled(cacheable=true)
    public static List<Brokerage_Summary__c> getBrokerageSummaryCountValue( String SummaryId) {
        
        return [Select Id,Name,Count_of_Bookings__c,Aggregate_Agreement_Value__c from Brokerage_Summary__c where id=:SummaryId];
    }
    @AuraEnabled(cacheable=true)
    public static String ChannelPartnerId() {	
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,Channel_Partner__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].Channel_Partner__c;
        }
        return CPId;
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
    @AuraEnabled
    public static void UpdateRERANo(String CPId,String rerano) {
        Broker__c b = new Broker__c();
        b.Id = CPId;
        b.RW_RERA_Registration_Number__c = rerano;
        b.Unregistered_Channel_Partner__c = false;
        update b;
    }
    @AuraEnabled
    public static Boolean RERAPresent(String CPId) {
        Boolean isExist = false;
        list <Broker__c> CPList = new list <Broker__c> ();
        CPList = [Select Id,Name,RW_RERA_Registration_Number__c,SAP_CP_Code__c from Broker__c where Id =: CPId];
        if(CPList[0].RW_RERA_Registration_Number__c != null && CPList[0].SAP_CP_Code__c != null){
            isExist = true;
        }else if(CPList[0].RW_RERA_Registration_Number__c == null && CPList[0].SAP_CP_Code__c != null){
            isExist = true;
        }else if(CPList[0].RW_RERA_Registration_Number__c != null && CPList[0].SAP_CP_Code__c == null){
            isExist = true;
        }else if(CPList[0].RW_RERA_Registration_Number__c == null && CPList[0].SAP_CP_Code__c == null){
            isExist = false;
        }else{
            isExist = false;
        }
        system.debug('isExist::'+isExist);
        return isExist;
    }
    @AuraEnabled
    public static void UpdateGSTNo(String CPId,String gstno) {
        Broker__c b = new Broker__c();
        b.Id = CPId;
        b.RW_GST_Number__c = gstno;
        update b;
    }
    @AuraEnabled
    public static Boolean GSTPresent(String CPId) {
        Boolean isExist = false;
        list <Broker__c> CPList = new list <Broker__c> ();
        CPList = [Select Id,Name,RW_GST_Number__c,SAP_CP_Code__c from Broker__c where Id =: CPId];
        if(CPList[0].RW_GST_Number__c != null && CPList[0].SAP_CP_Code__c != null){
            isExist = true;
        }else if(CPList[0].RW_GST_Number__c == null && CPList[0].SAP_CP_Code__c != null){
            isExist = true;
        }else if(CPList[0].RW_GST_Number__c != null && CPList[0].SAP_CP_Code__c == null){
            isExist = true;
        }else if(CPList[0].RW_GST_Number__c == null && CPList[0].SAP_CP_Code__c == null){
            isExist = false;
        }else{
            isExist = false;
        }
        return isExist;
    }
    /*@AuraEnabled
    public static Boolean CheckForGSTNo(String InvId) {
        system.debug('InvId::'+InvId);
        Boolean isExist = false;
        list <Broker__c> CPList = new list <Broker__c> ();
        list <Brokerage_Invoice__c> IList = new list <Brokerage_Invoice__c> ();
        IList = [Select Id,Name,Channel_Partner__c from Brokerage_Invoice__c where Id =: InvId];
        if(!IList.isEmpty()){
            CPList = [Select Id,Name,RW_GST_Number__c from Broker__c where Id =: IList[0].Channel_Partner__c];
            if(CPList[0].RW_GST_Number__c != null){
                isExist = true;
            }else{
                isExist = false;
            }
        }
        return isExist;
    } */
    @AuraEnabled
public static Boolean CheckForGSTNo(String InvId) {
    system.debug('InvId::'+InvId);
    Boolean isExist = false;
    
    // First try to query as Brokerage_Invoice__c
    list<Brokerage_Invoice__c> IList = [Select Id, Name, Channel_Partner__c 
                                       from Brokerage_Invoice__c 
                                       where Id = :InvId LIMIT 1];
    
    if(!IList.isEmpty()){
        // This is a Brokerage_Invoice__c record
        list<Broker__c> CPList = [Select Id, Name, RW_GST_Number__c 
                                 from Broker__c 
                                 where Id = :IList[0].Channel_Partner__c LIMIT 1];
        if(!CPList.isEmpty() && CPList[0].RW_GST_Number__c != null){
            isExist = true;
        }
    } else {
        // If not found as Brokerage_Invoice__c, try as CP_Brokerage__c
        list<CP_Brokerage__c> cpBrokerageList = [Select Id, Name, Channel_Partner__c 
                                                from CP_Brokerage__c 
                                                where Id = :InvId LIMIT 1];
        
        if(!cpBrokerageList.isEmpty()){
            // This is a CP_Brokerage__c record
            list<Broker__c> CPList = [Select Id, Name, RW_GST_Number__c 
                                     from Broker__c 
                                     where Id = :cpBrokerageList[0].Channel_Partner__c LIMIT 1];
            if(!CPList.isEmpty() && CPList[0].RW_GST_Number__c != null){
                isExist = true;
            }
        }
    }
    
    return isExist;
}



    @AuraEnabled(cacheable=true)
    public static List<OTP__c> getbookings(String projectname, String custname, String Unitno, String paymentreceived, String Registrationdone) {
        system.debug('projectname::'+projectname);
        system.debug('custname::'+custname);
        system.debug('Unitno::'+Unitno);
        system.debug('paymentreceived::'+paymentreceived);
        system.debug('Registrationdone::'+Registrationdone);
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].id;
        }
        System.debug('AccList '+ AccList);
        String query = 'SELECT Id, Name,RW_Project_Name__c,Primary_Applicant_Name__c,Customer_Name_formula__c,Unit_Number__c,Booking_Date__c,Brokerage__c,Status__c,X9_90_Received__c,RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme_Name__c,Agreement_Value_for_brokers__c,Sourcing_Mananger__c,Customer_Payment_Received1__c FROM Booking__c where Account__c =' + '\''+ CPId +'\'';
        system.debug('query---'+query);
        //if(searchKey != '' && sortBy != '' && sortDirection != '' && searchKeystatus != ''){
        if ( projectname != null && projectname != '' ) {
            String key = '%' + projectname + '%';
            query += ' and RW_Project_Name__c LIKE :key';
        }
        if ( custname != null && custname != '' ) {
            String key2 = '%' + custname + '%';
            query += ' and Customer_Name_formula__c LIKE :key2';
        }
        if ( Unitno != null && Unitno != '' ) {
            String key3 = '%' + Unitno + '%';
            query += ' and Unit_Number__c LIKE :key3';
        }
        if ( Registrationdone != null && Registrationdone != '' ) {
            String key4 = '%' + Registrationdone + '%';
            query += ' and RW_Registration_Done__c LIKE :key4';
        }
        if ( paymentreceived != null && paymentreceived != '' && paymentreceived == 'Yes') {
            query += ' and RW_X9_99_Received__c = true';
        }else if(paymentreceived != null && paymentreceived != '' && paymentreceived == 'No'){
            query += ' and RW_X9_99_Received__c = false';
        }
        //query = query + ' LIMIT 10';
        //}
        system.debug('query::'+query);
        system.debug('query::'+Database.query( query ));
        return Database.query( query );
    }

    //Added by coServe 22-05-2024 Start
    @AuraEnabled(cacheable=true)
    public static List<Booking__c> getCpMandateBookings(String projectname, String custname, String Unitno, String paymentreceived, String Registrationdone) {
       System.debug('--getCpMandateBookings--');
       Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c,Channel_Partner__c from Account where id =:contact[0].AccountId];

        Id recordTypeId = Schema.SObjectType.AOP__c.getRecordTypeInfosByName().get('CP Mandate').getRecordTypeId();
        List<AOP__c> aops = [SELECT Id, Name, Start_Date__c, End_Date__c, Channel_Partner__c, Projects__c, RecordTypeId FROM AOP__c WHERE Channel_Partner__c =: AccList[0].Channel_Partner__c AND RecordTypeId =: recordTypeId];
        List<String> projectList = aops[0].Projects__c.split(';');
        //List<Booking__c> bkgs =[SELECT Id, Name,RW_Project_Name__c,Primary_Applicant_Name__c,Customer_Name_formula__c,Unit_Number__c,Booking_Date__c,Brokerage__c,Status__c,X9_90_Received__c,RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme_Name__c,Agreement_Value_for_brokers__c,Sourcing_Mananger__c,Customer_Payment_Received1__c FROM Booking__c WHERE AOP_Scheme__c =: aops[0].Id];
        List<Booking__c> bkgs = [SELECT Id, Name,RW_Project_Name__c,Primary_Applicant_Name__c,Customer_Name_formula__c,Unit_Number__c,Booking_Date__c,Brokerage__c,Status__c,X9_90_Received__c,RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme_Name__c,Agreement_Value_for_brokers__c,Sourcing_Mananger__c,Customer_Payment_Received1__c FROM Booking__c WHERE Booking_Date__c >=: aops[0].Start_Date__c AND Booking_Date__c <=: aops[0].End_Date__c AND Status__c = 'Booking Confirmed' AND RW_Registration_Status__c = 'Registration Completed' AND RW_X9_99_Received__c = true AND Project__r.Name IN: projectList];
        return bkgs;
    }
    //Added by coServe 22-05-2024 End

    @AuraEnabled
    public static List<Broker__c> getCPDetails(){
        List<Broker__c> cplist = new List<Broker__c>();
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c,Channel_Partner__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].Channel_Partner__c;
        }
        cplist = [SELECT RW_Email__c, RecordTypeId, Representative_Name__c, RW_Mobile_No__c, RW_Broker_Number__c, Address__c, Broker_Pan_No__c, Broker_Type__c, Service_Tax_No__c,
                  City__c, State__c, Pin_Code__c, Phone_2__c, Country__c, RW_GST_Number__c, RW_RERA_Registration_Number__c, RW_Is_GST_Applicable__c, RW_Is_RERA_Applicable__c,
                  RW_Proof_of_Income__c, Is_NRI_CP__c, SAP_CP_Code__c, Locality__c, Zone__c, Experience__c, CP_Speciality__c, Lead_Generation_Methodology__c, Aadhar_Card__c,
                  Individual_CP__c, Legal_Form__c, NAME_FIRST__c, NAME_LAST__c, NAME_MIDDLE__c, Payment_Terms__c, RW_CreateFromIRIS__c, RW_IRIS_Sync__c, RW_NATURE_WORK__c,
                  STREET__c, STR_SUPPL1__c, STR_SUPPL2__c, STR_SUPPL3__c, TITLE__c, Unregistered_Channel_Partner__c, Dialing_Country1__c, Dialing_Country_Code1__c,
                  Bank_Name__c, Bank_Branch__c, Account_Number__c, IFSC_Code__c, Cheque_DD_Favouring_Name__c, Account__c, Team_Size__c, Project__c, Approver_L1__c,
                  Are_you_NRI__c, IS_IGST_Applicable__c, State_Code__c, House_Flat_Company__c, Place_of_Supply__c, Company_Name__c, Channel_Partner_From_CP_Portal__c, 
                  Expertise__c, Company_Name_As_per_RERA__c, Phone_With_Country_Code__c, Is_T_C_Accepted__c, Branch_Code__c, Developers_Worked_For__c, Approver_L2__c,
                  Approval_Status__c, Approval_Status_Update__c, Country_2__c, State_2__c, Name, Id FROM Broker__c where Id=:CPId];
        System.debug('cplist:: '+ cplist);
        return cplist;
    }
    @AuraEnabled
    public static String updateChannelPartner(Broker__c sf) {	
        List<Broker__c> cplist = new List<Broker__c>();
        Id loggeduserId = UserInfo.getUserId();
        String CPId ;
        System.debug('Logged User is :: ' +UserInfo.getUserName());
        List<Contact> contact = new List<Contact>();
        List<Account> AccList = new List<Account>();
        List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
        System.debug('Contact Id:: '+user[0].ContactId);
        System.debug('User List:: '+ user);
        
        contact =[select id,Name,Email,AccountId from Contact where id =: user[0].ContactId];
        AccList = [Select id,name,CP_Email__c,Channel_Partner__c from Account where id =:contact[0].AccountId];
        if(!AccList.isEmpty()){
            CPId = AccList[0].Channel_Partner__c;
        }
        try{
            sf.Id = CPId;
            Update sf;
            return loggeduserId;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Broker__c> getBrokerDetails(Id CPUserId) {
        if (String.isBlank(CPUserId)) {
            return null;
        }else {
            return [SELECT Id, Name/*Valid_competency_certificate__c*//*Commented by Prashant as discussed with team to discard use of CC. 12/12/25.*/,Valid_RERA_certificate__c/*,Latest_CC_Upload_Status__c*/,Latest_RERA_Upload_Status__c FROM Broker__c WHERE Account__c IN (SELECT AccountId FROM User WHERE Id =: CPUserId) LIMIT 1];
        }
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

    //Added by Prashant.////
    @AuraEnabled(cacheable=true)
    public static list<Broker__c> getTempCPData(String tempcpid){
        Id tempRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
        if (String.isNotBlank(tempcpid)) {
            return [Select Id,Name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,Broker_Pan_No__c,RW_Broker_Number__c,RW_Email__c,RW_Mobile_No__c,Company_Name__c from Broker__c where RW_Broker_Number__c =: tempcpid and RecordTypeId=:tempRecordTypeId ];
        }
        return null;
    } 
    
    @AuraEnabled(cacheable=true)
    public static list<Broker__c> getExistingCPData(Id brId){
        Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
        if (String.isNotBlank(brId)) {
            return [Select id,name,NAME_FIRST__c,NAME_MIDDLE__c,NAME_LAST__c,TITLE__c,RW_RERA_Registration_Number__c,Account_Number__c,
                          IFSC_Code__c,RW_Mobile_No__c,RW_GST_Number__c,Is_NRI_CP__c,RW_Is_GST_Applicable__c,Bank_Name__c,Bank_Branch__c,
                          Cheque_DD_Favouring_Name__c,Team_Size__c,Are_you_NRI__c,IS_IGST_Applicable__c,House_Flat_Company__c,Place_of_Supply__c,
                          Company_Name__c,RW_Email__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,Individual_CP__c,Unregistered_Channel_Partner__c,
                          Company_Name_As_per_RERA__c,Project__c,Approver_L1__c,Approver_L2__c,Country__c,City__c,Pin_Code__c,Broker_Type__c,
                          Experience__c,Branch_Code__c,State__c,Dialing_Country_Code1__c,Expertise__c,Channel_Partner_From_CP_Portal__c,
                          Developers_Worked_For__c,Account__c,RW_Broker_Number__c,Broker_Pan_No__c,RERA_Valid_till__c/*,CC_Valid_till__c*/,STREET__c
                    		//RW_Is_CC_Applicable__c
                    from Broker__c where Id =: brId and RecordTypeId=:CPRecordTypeId ];
        }
        return null;
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
        }catch(Exception e){
            String cleanMessage;            
            if (e.getNumDml() > 0 && String.isNotBlank(e.getDmlMessage(0))) {
                cleanMessage = e.getDmlMessage(0); // Show only adderror from trigger....
            } else {
                cleanMessage = e.getMessage(); // Show complete error other than adderror....
            }            
            throw new AuraHandledException(cleanMessage);
        }
        return null;
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

/// Added by Anuj start
    @AuraEnabled(cacheable=true)
public static List<CP_Brokerage__c> getCpBrokerages(
    String searchKey,
    String sortBy,
    String sortDirection,
    String searchKeystatus
) {
    Id loggeduserId = UserInfo.getUserId();

    System.debug('User id'+loggeduserId);
    // Get current user → Contact → Account (Channel Partner Account)
    List<User> user = [SELECT Id, ContactId FROM User WHERE Id =:loggeduserId];
    System.debug('User'+user[0].ContactId);
    if(!user.isEmpty() && user[0].ContactId != null){
    List<Contact> contact = [SELECT Id, AccountId FROM Contact WHERE Id =: user[0].ContactId];
    List<Account> accList = [SELECT Id,Channel_Partner__c FROM Account WHERE Id =: contact[0].AccountId];
    if (accList.isEmpty()) return new List<CP_Brokerage__c>();
    Id cpAccountId = accList[0].Channel_Partner__c;
      System.debug('cpAccountId----'+cpAccountId);
    }
      String a = 'Approved By L1';
      String b = 'Approved By L2';

    String query =
        'SELECT Id, Name, Invoice_Number__c, Invoice_Date__c, If_GST_is_applicable__c,Total_Brokerage__c,' +
        ' Approval_Status__c, Approval_Status_clearing__c, Brokerage_Type__c,' +
        ' Channel_Partner__c,Legal_Entity__c,Legal_Entity__r.Name, CreatedDate, LastModifiedDate' +
        ' FROM CP_Brokerage__c' + ' WHERE  (Approval_Status_clearing__c = :a OR Approval_Status_clearing__c = :b)';
      System.debug('Cp Brokerag record'+query);//Channel_Partner__c = :cpAccountId' +
      // ' AND
    if (!String.isBlank(searchKey)) {
        String key = '%' + searchKey + '%';
        query += ' AND Invoice_Number__c LIKE :key';
    }
    if (!String.isBlank(searchKeystatus)) {
        String key2 = '%' + searchKeystatus + '%';
        query += ' AND Approval_Status__c LIKE :key2';
    }
    if (!String.isBlank(sortBy) && !String.isBlank(sortDirection)) {
        query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
    }
  List<CP_Brokerage__c> results = Database.query(query);
System.debug('📌 Query Result Size: ' + results.size());
System.debug('📌 Query Records: ' + results);
return results;

}
// Added By Anuj End
    
}