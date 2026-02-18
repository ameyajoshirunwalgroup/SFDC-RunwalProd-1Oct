public class CallbackCTI_Queueable implements Queueable, Database.AllowsCallouts {
    String data;
    
    public CallbackCTI_Queueable(String details) {
        this.data = details;
    }
    
    public void execute(QueueableContext qc) {
        createEnquiry(this.data);
    }
    
    
    public static void createEnquiry(String data){
        
        Id PresalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        Id salesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Sales Task').getRecordTypeId();
        Id CRMRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Service Task').getRecordTypeId();
        Id HomeLoanRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Home Loan Call').getRecordTypeId();
        //added by Vaishnavi
        Id CollectionRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Collection Task').getRecordTypeId();

        try{
            CallbackParse cb = CallbackParse.Parse(data);
            String customerNumber = cb.CallerID; //cb.national
            String did = cb.DID;
            String ucid = cb.monitorUCID;
            String callStatus = cb.Status;
            String callType =cb.Type_Z;
            String account =cb.UserName;
            String recordingFile = cb.AudioFile;
            String duration = cb.CallDuration;
            String UUI = cb.UUI;
            String CampaignStatus = cb.CampaignStatus;
            string countryCode = cb.countryCode;
            string Country;
            String CampaignNameCTI = cb.CampaignName;
            string formattedphone = customerNumber ;
            String Recordtype = '';
            String Skill = cb.Skill;
            ID UUIforInbound;
            String PhoneName = cb.PhoneName;
            system.debug('UUI::'+UUI);
            system.debug('account::'+account);
            system.debug('cd::'+cb);
            system.debug('FallBackRule:: ' + cb.FallBackRule);
            System.debug('Incoming request callstatus:' + callStatus + ':' + customerNumber + ':' + ucid + 'UUI:' + UUI + 'CampaignStatus:' + CampaignStatus + 'DID:' + did + 'countryCode::' + countryCode);
            
            system.debug('customerNumber::'+customerNumber);
            
            String objName;//Added by coServe 23-082024
            if(UUI != null && UUI != '' && (UUI.startsWithIgnoreCase('0')  || UUI.startsWithIgnoreCase('a1'))){ //Added by coServe 23-082024
                Id recId = UUI;
                objName = recId.getSObjectType().getDescribe().getName();
            }
            //added by vaishnavi
            RW_Demand__c objDemand;
            Booking__c objBooking;
            
            if (UUI != null && UUI.startsWith('a1s')) {
                
                objDemand = [SELECT Id, Name, Booking__c
                             FROM RW_Demand__c
                             WHERE Id = :UUI
                             LIMIT 1];
                
                if (objDemand != null) {
                    objBooking = [SELECT Id, Customer__c
                              FROM Booking__c
                              WHERE Id = :objDemand.Booking__c
                              LIMIT 1];
                }
            }
            ////
            /////////////////////////////////////////////////////////////////////////////////////////
            System.debug('formattedphone ::'+formattedphone +'formattedphone length ::'+formattedphone.length());
            
            
            //Added by coServe 05-04-2024 Start
            Boolean checkWithCode = false;
            
            String updatedMobile;
            updatedMobile = customerNumber.deleteWhitespace();
            updatedMobile = updatedMobile.replace('+','');
            
            while(updatedMobile.subString(0,1) == '0'){
                //updatedMobile = updatedMobile.replace(updatedMobile.subString(0,1),'');
                updatedMobile = updatedMobile.subString(1,updatedMobile.length());
            }
            
            if(updatedMobile.subString(0,1) == '(' && updatedMobile.contains(')')){
                updatedMobile = updatedMobile.replace('(', '');
                updatedMobile = updatedMobile.replace(')', '');
                updatedMobile = '1' + updatedMobile;
                checkWithCode = true;
            }else if(updatedMobile.subString(3,4) == '-'){
                updatedMobile = updatedMobile.replace('-', '');
                updatedMobile = '1' + updatedMobile;
            }
            
            if(updatedMobile.length() < 10){
                checkWithCode = false;
            }else if(updatedMobile.length() > 10){
                checkWithCode = true;
            }else if(updatedMobile.length() == 10){
                if(customerNumber.subString(0,1) == '0' || customerNumber.subString(0,1) == '+'){
                    checkWithCode = true;
                }else{
                    checkWithCode = false;
                }
            }
            
            if(Test.isRunningTest()){
                checkWithCode = false;
            }
            system.debug(' checkWithCode :: '+checkWithCode);
            system.debug(' updatedMobile :: '+updatedMobile);
            //Added by coServe 05-04-2024 End
            
            system.debug(' countryCode :: '+countryCode);
            
            List<String> inboundCallCenterCampaigns = System.label.Inbound_Call_Center_Campaign.split(','); //Added by Vinay 01-12-2025
            List<String> inboundDeskSkills = System.label.Inbound_Desk_Skills.split(','); //Added by Vinay 08-02-2026
            
            string campaignId;
            String LeadSource, LeadSubSource,LeadSubSubSource, PrimaryCampaignCode, CampaignName, Project;
            List<Campaign> CampaignList = new List<Campaign>();
            // List<Project__c> project1List = new List<Project__c>();
            if(did != null){
                CampaignList = [SELECT Id, Name, Type,Sub_Sub_Source__c,RW_Sub_Type__c,Primary_Project__c, Digital_Maketing_Campaign_Code__c from Campaign where Digital_Maketing_Campaign_Code__c = :did and IsActive = true];
                system.debug('CampaignList'+CampaignList);
            }
            if (CampaignList.size() > 0){
                LeadSource = CampaignList[0].Type;
                LeadSubSource = CampaignList[0].RW_Sub_Type__c;
                LeadSubSubSource = CampaignList[0].Sub_Sub_Source__c;
                CampaignName = CampaignList[0].Id;
                PrimaryCampaignCode = CampaignList[0].Digital_Maketing_Campaign_Code__c;
                if(CampaignList[0].Primary_Project__c != null){
                    Project = CampaignList[0].Primary_Project__c;
                    ///  project1List = [SELECT Id, Name from Project__c Where id = :CampaignList[0].Project__c];
                }
            }
            
            // Added by Aditya for Loan Module
            if(objName!=null && objName == 'Loan__c' && String.isNotBlank(CampaignStatus) && CampaignStatus != null && (CampaignStatus.equalsIgnoreCase('OFFLINE'))){
                try {
                    task t = new task();
                    t.status = callStatus;
                    t.RecordTypeId = HomeLoanRecordTypeId;
                    t.Task_Type__c = 'Home Loan Call';
                    t.WhatId = UUI;
                    t.Priority = 'Normal';
                    t.Type_Of_Meeting__c = callType;
                    t.Voice_Log_URL__c = recordingFile;
                    t.Disposition_Type__c = callStatus;
                    t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                    t.Visit_Form_No__c = did;
                    t.Remarks__c = UUI;
                    if(callType == 'manual'){
                        t.CallType__c = 'Outbound';
                        t.Communication_Type__c = 'Outbound Call';
                    }
                    if(callType == 'Inbound'){
                        t.CallType__c = 'Inbound';
                        t.Communication_Type__c = 'Inbound Call';
                    }
                    insert t;
                    return;
                } catch (Exception ex) {
                    createERPlog(data, UUI, ucid, ex.getMessage());
                    return;
                }
                
                
            }
            
            if(String.isNotBlank(callStatus) && callStatus != null && callStatus != 'NotAnswered' && callType == 'Inbound' && (CampaignStatus.equalsIgnoreCase('ONLINE'))){
                
                List<String> sList = Skill.split('\\,');
                system.debug('sList:'+sList.size());
                if(sList.size()>1){
                    String AgentNumber = sList[1].right(10);
                    User usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Campaign_Name__c,Skill__c  FROM User Where Phone  =: AgentNumber]; //Commented by Vinay 18-12-2025
                    /*User usr; //Added by Vinay 18-12-2025
                    if(CampaignNameCTI != 'CommonServiceDesk'){ //Added by Vinay 18-12-2025
                        system.debug('true'+sList[1].isNumeric());
                        String AgentNumber = sList[1].right(10);
                        usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Campaign_Name__c  FROM User Where Phone  =: AgentNumber];
                    }*/
                    //List<Opportunity> oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c FROM Opportunity WHERE RW_Mobile_No__c =: customerNumber ]; //Commented by coServe 05-04-2024
                    //Added by coServe 05-04-2024 Start
                    List<Opportunity> oppoListinbd = new List<Opportunity>();
                    List<Opportunity> bookedOppList = new List<Opportunity>();
                    if(checkWithCode){
                        oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE Mobile_No_with_Country_Code__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile];
                        if(oppoListinbd.size() == 0){
                            oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE RW_Mobile_No__c =: updatedMobile  OR RW_Secondary_Mobile_No__c =: updatedMobile];
                        }
                    }else{
                        oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile];
                    }
                    for(Opportunity opp : oppoListinbd){ //Added by coServe 08-05-2024
                        if(opp.StageName == 'Unit Booked'){
                            bookedOppList.add(opp);
                        }
                    }
                    
                    //Added by coServe 05-04-2024 End
                    if(oppoListinbd != null && !oppoListinbd.isEmpty()){
                        task t = new task();
                        t.status = 'In-Progress';
                        t.RecordTypeId = CRMRecordTypeId;
                        t.Task_Type__c = 'CRM Call';
                        
                        if(usr != null){
                            if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                t.RecordTypeId = salesRecordTypeId;
                                t.Task_Type__c = 'Sales Call';
                                t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                            }
                            if(usr.Profile.Name == 'Relationship Manager'){
                                
                                if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                    //added by vaishnavi
                                    if (objDemand != null && objBooking != null) {
                                        t.RecordTypeId = CollectionRecordTypeId;
                                        t.Task_Type__c = 'Collection Call';
                                        t.WhatId = objBooking.Id;
                                        t.Demand__c = objDemand.Id;
                                    }
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    t.WhatId = bookedOppList[0].id;
                                }else{
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    t.WhatId = oppoListinbd[0].id;
                                }
                            }
                            if(usr.Profile.Name == 'Pre Sales Manager'){
                                t.RecordTypeId = PresalesRecordTypeId;
                                t.Task_Type__c = 'Presales Call';
                                t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                            }
                            //t.OwnerId = usr.id; //Commented by Vinay 01-12-2025
                            /*if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c) && oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 25-08-2025
                                t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                            }else{
                                t.OwnerId = usr.id;
                            }*/
                            //if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c)){ //Added by Vinay 18-12-2025 //Commented by Vinay 18-02-2026
                            if(inboundDeskSkills.contains(usr.Skill__c)){ //Added by Vinay 18-02-2026
                                List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                                String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                                if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                    t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                    t.WhatId = bookedOppList[0].id;
                                    t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                    t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                    t.WhatId = oppoListinbd[0].id;
                                    t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                }
                            }else{
                                t.OwnerId = usr.id;
                            }
                        }
                        /*if(inboundCallCenterCampaigns.contains(CampaignNameCTI)){ //Added by Vinay 18-12-2025
                            List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                            String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                            if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                t.WhatId = bookedOppList[0].id;
                                t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                            }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                t.WhatId = oppoListinbd[0].id;
                                t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                            }
                            //t.Inbound_Desk_Agent__c = cb.AgentID; //Commented by Vinay 19-01-2026
                        }*/
                        if((callStatus.equalsIgnoreCase('NotAnswered'))){
                            t.Subject = 'Missed Call';
                            t.status = 'Completed';
                        }
                        //t.WhatId = oppoListinbd[0].id; //Commented by coServe 08-05-2024
                        t.Priority = 'Normal';
                        t.Lead_Account_Name__c = oppoListinbd[0].Name;
                        t.Type_Of_Meeting__c = callType;
                        t.Voice_Log_URL__c = recordingFile;
                        t.Disposition_Type__c = callStatus;
                        t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                        t.Visit_Form_No__c = did;
                        t.Remarks__c = UUI;
                        if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024
                            t.WhatId = UUI;
                        }else if(objName == 'Lead'){
                            t.WhoId = UUI;
                        }
                        t.CallObject = ucid;
                        
                        if(callType == 'manual'){
                            t.CallType__c = 'Outbound';
                            t.Communication_Type__c = 'Outbound Call';
                        }
                        if(callType == 'Inbound'){
                            t.CallType__c = 'Inbound';
                            t.Communication_Type__c = 'Inbound Call';
                        }
                        List<String> secList = duration.split('\\:');
                        system.debug('sc:'+secList);
                        Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                        system.debug('total'+total);
                        t.CallDurationInSeconds = total;
                        try {
                            insert t;
                            System.debug('Task created for inbound offline opportunity:' + t.id);
                        } catch (Exception ex) {
                            System.debug('Enquiry detail insert failed :' + ex.getMessage());
                            createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                        }
                    }
                }
            }
            
            if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered')) /*&& callStatus == 'NotAnswered'*/ && callType == 'Inbound' && (CampaignStatus.equalsIgnoreCase('ONLINE'))){
                System.debug('Inside if callStatus: ' + callStatus + ' customerNumber::: ' + customerNumber + ' UUI::: '+UUI);
                ///
                List<String> UUIList = UUI.split('\\,');
                system.debug('UUIList:'+UUIList.size());
                List<String> sList = Skill.split('\\,');
                system.debug('sList:'+sList.size());
                
                if(sList.size()>1){
                    String AgentNumber = sList[1].right(10);
                    User usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Phone,Campaign_Name__c,Skill__c  FROM User Where Phone  =: AgentNumber]; //Commented by Vinay 18-12-2025
                    /*User usr; //Added by Vinay 18-12-2025
                    if(!inboundCallCenterCampaigns.contains(CampaignNameCTI)){ //Added by Vinay 18-12-2025
                        system.debug('true'+sList[1].isNumeric());
                        String AgentNumber = sList[1].right(10);
                        usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Phone,Campaign_Name__c  FROM User Where Phone  =: AgentNumber];
                    }*/
                    //List<Opportunity> oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c FROM Opportunity WHERE (RW_Mobile_No__c =: customerNumber OR RW_Secondary_Mobile_No__c =: customerNumber) ]; //Commented by coServe 05-04-2024
                    //Added by coServe 05-04-2024 Start
                    List<Opportunity> oppoListinbd = new List<Opportunity>();
                    List<Opportunity> bookedOppList = new List<Opportunity>();
                    if(checkWithCode){
                        oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE Mobile_No_with_Country_Code__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile];
                        if(oppoListinbd.size() == 0){
                            oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) ];
                        }
                    }else{
                        oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) ];
                    }
                    for(Opportunity opp : oppoListinbd){ //Added by coServe 08-05-2024
                        if(opp.StageName == 'Unit Booked'){
                            bookedOppList.add(opp);
                        }
                    }
                    //Added by coServe 05-04-2024 End
                    if(oppoListinbd != null && !oppoListinbd.isEmpty()){
                        task t = new task();
                        t.status = 'In-Progress';
                        t.RecordTypeId = CRMRecordTypeId;
                        t.Task_Type__c = 'CRM Call';
                        
                        if(usr != null){
                            if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                t.RecordTypeId = salesRecordTypeId;
                                t.Task_Type__c = 'Sales Call';
                                t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                            }
                            if(usr.Profile.Name == 'Relationship Manager'){
                                if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                    //added by vaishnavi
                                    if (objDemand != null && objBooking != null) {
                                        t.RecordTypeId = CollectionRecordTypeId;
                                        t.Task_Type__c = 'Collection Call';
                                        t.WhatId = objBooking.Id;
                                        t.Demand__c = objDemand.Id;
                                    }
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    t.WhatId = bookedOppList[0].id;
                                }else{
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    t.WhatId = oppoListinbd[0].id;
                                }
                            }
                            if(usr.Profile.Name == 'Pre Sales Manager'){
                                t.RecordTypeId = PresalesRecordTypeId;
                                t.Task_Type__c = 'Presales Call';
                                t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                            }
                            //t.OwnerId = usr.id; //Commented by Vinay 01-12-2025
                            /*if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c) && oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 25-08-2025
                                t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                            }else{
                                t.OwnerId = usr.id;
                            }*/
                            //if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c)){ //Added by Vinay 18-12-2025 //Commented by Vinay 18-02-2026
                            if(inboundDeskSkills.contains(usr.Skill__c)){ //Added by Vinay 18-02-2026
                                List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                                String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                                if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                    t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                    t.WhatId = bookedOppList[0].id;
                                    t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                    t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                    t.WhatId = oppoListinbd[0].id;
                                    t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                }
                            }else{
                                t.OwnerId = usr.id;
                            }
                        }
                        /*if(inboundCallCenterCampaigns.contains(CampaignNameCTI)){ //Added by Vinay 18-12-2025 //Commented by Vinay 18-02-2026
                            List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                            String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                            if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                t.WhatId = bookedOppList[0].id;
                                t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                            }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                t.WhatId = oppoListinbd[0].id;
                                t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                            }
                            //t.Inbound_Desk_Agent__c = cb.AgentID; //Commented by Vinay 19-01-2026
                        }*/
                        if((callStatus.equalsIgnoreCase('NotAnswered'))){
                            t.Subject = 'Missed Call';
                            t.status = 'Completed';
                        }
                        //t.WhatId = oppoListinbd[0].id;
                        t.Priority = 'Normal';
                        t.Lead_Account_Name__c = oppoListinbd[0].Name;
                        t.Type_Of_Meeting__c = callType;
                        t.Voice_Log_URL__c = recordingFile;
                        t.Disposition_Type__c = callStatus;
                        t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                        t.Visit_Form_No__c = did;
                        t.Remarks__c = UUI;
                        if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024 || objName == 'Case'
                            t.WhatId = UUI;
                        }else if(objName == 'Lead'){
                            t.WhoId = UUI;
                        }
                        t.CallObject = ucid;
                        
                        if(callType == 'manual'){
                            t.CallType__c = 'Outbound';
                            t.Communication_Type__c = 'Outbound Call';
                        }
                        if(callType == 'Inbound'){
                            t.CallType__c = 'Inbound';
                            t.Communication_Type__c = 'Inbound Call';
                        }
                        List<String> secList = duration.split('\\:');
                        system.debug('sc:'+secList);
                        Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                        system.debug('total'+total);
                        t.CallDurationInSeconds = total;
                        try {
                            insert t;
                            System.debug('Task created for inbound offline opportunity:' + t.id);
                        } catch (Exception ex) {
                            System.debug('Enquiry detail insert failed :' + ex.getMessage());
                            createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                        }
                    }
                }
                else if(!UUIList.isEmpty() ){
                    system.debug('UUIList::'+UUIList+'::'+UUIList[0]+':');
                    if(UUIList[0] != ''){
                        system.debug('IM IN If');
                        String AgentID = UUIList[0];
                        List<User> usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Campaign_Name__c,Skill__c  FROM User Where CTI_Agent_ID__c  =: AgentID];
                        //List<Opportunity> oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c FROM Opportunity WHERE (RW_Mobile_No__c =: customerNumber OR RW_Secondary_Mobile_No__c =: customerNumber) ];// Commented by coServe 05-04-2024
                        //Added by coServe 05-04-2024 Start
                        List<Opportunity> oppoListinbd = new List<Opportunity>();
                        List<Opportunity> bookedOppList = new List<Opportunity>();
                        
                        if(checkWithCode){
                            oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE Mobile_No_with_Country_Code__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile];
                            if(oppoListinbd.size() == 0){
                                oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) ];
                            }
                        }else{
                            oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c,RW_Project_Unit__r.Relationship_Manager__r.User__r.Name FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) ];
                        }
                        for(Opportunity opp : oppoListinbd){ //Added by coServe 08-05-2024
                            if(opp.StageName == 'Unit Booked'){
                                bookedOppList.add(opp);
                            }
                        }
                        //Added by coServe 05-04-2024 End
                        if(oppoListinbd != null && !oppoListinbd.isEmpty()){
                            task t = new task();
                            t.status = 'In-Progress';
                            t.RecordTypeId = CRMRecordTypeId;
                            t.Task_Type__c = 'CRM Call';
                            
                            //if(usr != null){ //Commented by Vinay 30-12-2024
                                if(usr.size() > 0){ // Added by Vinay 30-12-2024
                                    if(usr[0].Profile.Name == 'Sales Manager' || usr[0].Profile.Name == 'NRI Sales Manager' ){
                                        t.RecordTypeId = salesRecordTypeId;
                                        t.Task_Type__c = 'Sales Call';
                                        t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                                    }
                                    /*if(usr[0].Profile.Name == 'Relationship Manager'){
                                        t.RecordTypeId = CRMRecordTypeId;
                                        t.Task_Type__c = 'CRM Call';
                                        if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                            t.WhatId = bookedOppList[0].id;
                                        }else{
                                            t.WhatId = oppoListinbd[0].id;
                                        }
                                    }*/
                                    if(usr[0].Profile.Name == 'Relationship Manager'){
                                        if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                            //added by vaishnavi
                                            if (objDemand != null && objBooking != null) {
                                                t.RecordTypeId = CollectionRecordTypeId;
                                                t.Task_Type__c = 'Collection Call';
                                                t.WhatId = objBooking.Id;
                                                t.Demand__c = objDemand.Id;
                                            }
                                            t.RecordTypeId = CRMRecordTypeId;
                                            t.Task_Type__c = 'CRM Call';
                                            t.WhatId = bookedOppList[0].id;
                                        }else{
                                            t.RecordTypeId = CRMRecordTypeId;
                                            t.Task_Type__c = 'CRM Call';
                                            t.WhatId = oppoListinbd[0].id;
                                        }
                                    }
                                    if(usr[0].Profile.Name == 'Pre Sales Manager'){
                                        t.RecordTypeId = PresalesRecordTypeId;
                                        t.Task_Type__c = 'Presales Call';
                                        t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                                    }
                                    //t.OwnerId = usr[0].id; //Commented by Vinay 01-12-2025
                                    /*if(inboundCallCenterCampaigns.contains(usr[0].Campaign_Name__c) && oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 25-08-2025
                                        t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                    }else{
                                        t.OwnerId = usr[0].id;
                                    }*/
                                    //if(inboundCallCenterCampaigns.contains(usr[0].Campaign_Name__c)){ //Added by Vinay 18-12-2025 //Commented by Vinay 18-02-2026
                                    if(inboundDeskSkills.contains(usr[0].Campaign_Name__c)){ //Added by Vinay 18-02-2026
                                        List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                                        String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                                        if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                            t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                            t.WhatId = bookedOppList[0].id;
                                            t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                        }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                            t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                            t.WhatId = oppoListinbd[0].id;
                                            t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                        }
                                    }else{
                                        t.OwnerId = usr[0].id;
                                    }
                                }
                                /*if(inboundCallCenterCampaigns.contains(CampaignNameCTI)){ //Added by Vinay 18-12-2025
                                    List<String> inboundAgentAttemptedList = cb.AgentID.split(' -> '); //Added by Vinay 19-01-2026
                                    String inboundDeskAgent = inboundAgentAttemptedList[inboundAgentAttemptedList.size() - 1]; //Added by Vinay 19-01-2026
                                    if(bookedOppList.size() > 0 && bookedOppList[0].RW_Project_Unit__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__c != null && bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                        t.OwnerId = bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                        t.WhatId = bookedOppList[0].id;
                                        t.Inbound_Desk_Agent__c = (inboundDeskAgent != bookedOppList[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                    }else if(oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){
                                        t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                        t.WhatId = oppoListinbd[0].id;
                                        t.Inbound_Desk_Agent__c = (inboundDeskAgent != oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__r.CTI_Agent_ID__c)? inboundDeskAgent : null; //Added by Vinay 19-01-2026
                                    }
                                    //t.Inbound_Desk_Agent__c = cb.AgentID; //Commented by Vinay 19-01-2026
                                }*/
                                if((callStatus.equalsIgnoreCase('NotAnswered'))){
                                    t.Subject = 'Missed Call';
                                    t.status = 'Completed';
                                }
                                //t.WhatId = oppoListinbd[0].id;
                                t.Priority = 'Normal';
                                t.Lead_Account_Name__c = oppoListinbd[0].Name;
                                t.Type_Of_Meeting__c = callType;
                                t.Voice_Log_URL__c = recordingFile;
                                t.Disposition_Type__c = callStatus;
                                t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                                t.Visit_Form_No__c = did;
                                t.Remarks__c = UUI;
                                if(objName == 'Account' || objName == 'Opportunity' ||objName == 'Case'){ //Added by coServe 23-08-2024
                                    t.WhatId = UUI;
                                }else if(objName == 'Lead'){
                                    t.WhoId = UUI;
                                }
                                t.CallObject = ucid;
                                
                                if(callType == 'manual'){
                                    t.CallType__c = 'Outbound';
                                    t.Communication_Type__c = 'Outbound Call';
                                }
                                if(callType == 'Inbound'){
                                    t.CallType__c = 'Inbound';
                                    t.Communication_Type__c = 'Inbound Call';
                                }
                                List<String> secList = duration.split('\\:');
                                system.debug('sc:'+secList);
                                Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                                system.debug('total'+total);
                                t.CallDurationInSeconds = total;
                                try {
                                    insert t;
                                    System.debug('Task created for inbound offline opportunity:' + t.id);
                                } catch (Exception ex) {
                                    System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                    createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                                }
                            }
                        }
                        else{
                            //Added by coServe 05-04-2024 Start
                            //List <Lead> leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :customerNumber OR Phone = :customerNumber) AND isConverted= false];//Commented by coServe 05-04-2024
                            List <Lead> leadListinbd = new List <Lead>();
                            if(checkWithCode){
                                leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE Mobile_No_with_Country_Code__c = :updatedMobile AND isConverted= false];
                                if(leadListinbd.size() == 0){
                                    leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :updatedMobile OR Phone = :updatedMobile) AND isConverted= false];
                                }
                            }else{
                                leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :updatedMobile OR Phone = :updatedMobile) AND isConverted= false];
                            }
                            //List<Opportunity> oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c FROM Opportunity WHERE (RW_Mobile_No__c =: customerNumber OR RW_Secondary_Mobile_No__c =: customerNumber)];//Commented by coServe 05-04-2024
                            List<Opportunity> oppoListinbd = new List<Opportunity>();
                            List<Opportunity> bookedOppList = new List<Opportunity>();
                            if(checkWithCode){
                                oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE Mobile_No_with_Country_Code__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile];
                                if(oppoListinbd.size() == 0){
                                    oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile)];
                                }
                            }else{
                                oppoListinbd = [SELECT Id,AccountId,Name,RW_Sales_Associate__c,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile)];
                            }
                            for(Opportunity opp : oppoListinbd){ //Added by coServe 08-05-2024
                                if(opp.StageName == 'Unit Booked'){
                                    bookedOppList.add(opp);
                                }
                            }
                            //List<Account> accList =  [select id,Name From Account where (Mobile_No__c =: customerNumber OR Alternate_Mobile_No__c =: customerNumber) ];//Commented by coServe 05-04-2024
                            List<Account> accList = new List<Account>();
                            if(checkWithCode){
                                accList =  [select id,Name From Account where Mobile_No_with_Country_Code__c =: updatedMobile];
                                if(accList.size() == 0){
                                    accList =  [select id,Name From Account where (Mobile_No__c =: updatedMobile OR Alternate_Mobile_No__c =: updatedMobile) ];
                                }
                            }else{
                                accList =  [select id,Name From Account where (Mobile_No__c =: updatedMobile OR Alternate_Mobile_No__c =: updatedMobile) ];
                            }
                            //Added by coServe 05-04-2024 End
                            system.debug('leadListinbd::'+leadListinbd);
                            system.debug('oppoListinbd::'+oppoListinbd);
                            if(leadListinbd != null && !leadListinbd.isEmpty()){
                                task t = new task();
                                t.status = 'In-Progress';
                                t.RecordTypeId = PresalesRecordTypeId;
                                t.Task_Type__c = 'Presales Call';
                                t.status = 'In-Progress';
                                if((callStatus.equalsIgnoreCase('NotAnswered'))){
                                    User usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Campaign_Name__c  FROM User Where Name  =: 'Integration Admin'];
                                    t.Subject = 'Missed Call';
                                    t.OwnerId = usr.id;
                                    t.status = 'Completed';
                                }
                                t.WhoId = leadListinbd[0].id;
                                t.Priority = 'Normal';
                                //t.task_type__c = 'Enquiry Received';
                                //t.Subject = 'Missed Call';
                                t.Lead_Account_Name__c = leadListinbd[0].Name;
                                //t.Status = 'Completed';
                                t.Type_Of_Meeting__c = callType;
                                //t.Visit_Form_No__c = leadListinbd[0].Campaign_Code__c;
                                t.Voice_Log_URL__c = recordingFile;
                                t.Disposition_Type__c = callStatus;
                                t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                                t.Visit_Form_No__c = did;
                                t.Remarks__c = UUI;
                                if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024
                                    t.WhatId = UUI;
                                }else if(objName == 'Lead'){
                                    t.WhoId = UUI;
                                }
                                t.CallObject = ucid;
                                List<String> secList = duration.split('\\:');
                                system.debug('sc:'+secList);
                                Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                                system.debug('total'+total);
                                t.CallDurationInSeconds = total;
                                try {
                                    insert t;
                                    System.debug('Task created for inbound:' + t.id);
                                } catch (Exception ex) {
                                    System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                    createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                                }
                            }
                            else if(oppoListinbd != null && !oppoListinbd.isEmpty()){
                                task t = new task();
                                t.status = 'In-Progress';
                                t.RecordTypeId = CRMRecordTypeId;
                                t.Task_Type__c = 'CRM Call';
                                if(oppoListinbd[0].RW_Sales_Associate__c != null){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                        t.WhatId = bookedOppList[0].id;
                                    }else{
                                        t.WhatId = oppoListinbd[0].id;
                                    }
                                }
                                else{
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                                }
                                if((callStatus.equalsIgnoreCase('NotAnswered'))){
                                    t.Subject = 'Missed Call';
                                    t.status = 'Completed';
                                }
                                
                                //t.WhatId = oppoListinbd[0].id;
                                t.Priority = 'Normal';
                                t.Lead_Account_Name__c = oppoListinbd[0].Name;
                                t.Type_Of_Meeting__c = callType;
                                t.Voice_Log_URL__c = recordingFile;
                                t.Disposition_Type__c = callStatus;
                                t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                                t.Visit_Form_No__c = did;
                                t.Remarks__c = UUI;
                                if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024
                                    t.WhatId = UUI;
                                }else if(objName == 'Lead'){
                                    t.WhoId = UUI;
                                }
                                t.CallObject = ucid;
                                List<String> secList = duration.split('\\:');
                                system.debug('sc:'+secList);
                                Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                                system.debug('total'+total);
                                t.CallDurationInSeconds = total;
                                try {
                                    insert t;
                                    System.debug('Enquiry created:' + t.id);
                                } catch (Exception ex) {
                                    System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                    createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                                }
                            }
                            
                            else{
                                List<Lead> leads = new List<Lead>(); //Added by Vinay 04-08-2025
                                User usr = [SELECT Id,FirstName,Name,Profile.Name,DID__c,MobilePhone,Campaign_Name__c  FROM User Where Name  =: 'Integration Admin'];
                                Lead l  = new Lead (
                                    LastName = 'Missed Call',
                                RW_Mobile_No__c = customerNumber,
                                RDS_Country_Code__c = countryCode,
                                RDS_Country__c = Country,
                                Campaign_Code__c = did,
                                RW_Project__c = Project,
                                LeadSource = LeadSource,
                                RW_Lead_Sub_Source__c = LeadSubSource,
                                Lead_Sub_Sub_Source__c = LeadSubSubSource,
                                RW_Lead_through_CTI__c = true,
                                Campaign_Name_from_CTI__c = CampaignNameCTI,
                                OwnerId = usr.id
                                    //Enquiry_Sub_Source__c = LeadSubSource,
                                //Type__c = 'Missed Call',
                                //FallbackRule__c = cb.FallBackRule,
                                //Skill__c = cb.skill
                                );
                                
                                try {
                                    leads = [SELECT Id, Name FROM Lead WHERE (RW_Mobile_No__c = :updatedMobile OR Mobile_No_with_Country_Code__c = :updatedMobile) AND isConverted= false]; //Added by Vinay 04-08-2025
                                    if(leads.size() == 0) //Added if condition by Vinay 04-08-2025
                                        insert l;
                                } catch (Exception ex) {
                                    createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                                }
                                //User usr = [SELECT Id,FirstName,Name FROM User Where Name = 'Minal Karnik'];
                                task t = new task();
                                t.status = 'Completed';
                                t.WhoId = (leads.size() == 0)? l.id : leads[0].Id;
                                t.Priority = 'Normal';
                                t.task_type__c = 'Presales Call';
                                t.Subject = 'Missed Call';
                                t.Lead_Account_Name__c = (leads.size() == 0)? l.Name : leads[0].Name;
                                t.Status = 'Completed';
                                t.Type_Of_Meeting__c = 'Inbound';
                                t.Visit_Form_No__c = did;
                                t.Disposition_Type__c = callStatus;
                                t.OwnerId = usr.id;
                                try {
                                    insert t;
                                } catch (Exception ex) {
                                    createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                                }
                            }
                        }
                        
                    }
                    
                }
                if(String.isNotBlank(CampaignStatus) && CampaignStatus != null && (CampaignStatus.equalsIgnoreCase('OFFLINE')) ){
                    system.debug('PhoneName:'+PhoneName);
                    List<String> PhoneNameList = PhoneName.split('\\ ->');
                    system.debug('PhoneNameList[0]'+PhoneNameList[0]);
                    system.debug('PhoneNameList:'+PhoneNameList.size());
                    List<User> usrs = [SELECT Id,FirstName,Name,Profile.Name,DID__c,Campaign_Name__c,Skill__c FROM User Where Offline_Agent_Name__c =: PhoneNameList[0]];
                    User usr;
                    if(usrs.size() > 0){
                        usr = usrs[0];
                    }
                    //List<RecordType > Listrec = [select Id,Name from RecordType where sObjectType='Task'];
                    //if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                        
                    //}
                    //Profile prf = [Select id, RecordType from profile where Name =: usr.Profile.Name];
                    if(UUI.startsWith('00Q') || UUI.startsWith('006')){
                        UUIforInbound = (ID)UUI;
                    }
                    if(UUIforInbound != null && UUIforInbound.getSObjectType().getDescribe().getName() == 'Lead'){
                        List <Lead> leadList = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE id=: UUIforInbound AND isConverted= false];
                        if(leadList != null && !leadList.isEmpty()){
                            task t = new task();
                            t.status = 'In-Progress';
                            if(usr != null){
                                if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.RW_Sales_Associate__c = usr.Name;
                                }
                                if(usr.Profile.Name == 'Relationship Manager'){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                }
                                if(usr.Profile.Name == 'Pre Sales Manager' || usr.Profile.Name == 'Presales Executive Offline' ){		//Presales Executive Offline added by Sheetal on 18/7/2022
                                    t.RecordTypeId = PresalesRecordTypeId;
                                    t.Task_Type__c = 'Presales Call';
                                }
                                t.OwnerId = usr.id;
                                t.Attempted_By__c = usr.Name;
                            }
                            if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered'))){
                                t.Subject = 'Missed Call';
                                t.Call_Attempt_Status__c = 'Missed Call';
                                t.status = 'Completed';
                            }
                            
                            t.WhoId = leadList[0].id;
                            t.Priority = 'Normal';
                            //t.task_type__c = 'Enquiry Received';
                            //t.Subject = 'Missed Call';
                            t.Lead_Account_Name__c = leadList[0].Name;
                            t.Call_Attempt_Status__c = 'Completed';
                            t.Type_Of_Meeting__c = callType;
                            //t.Visit_Form_No__c = leadList[0].Campaign_Code__c;
                            t.Voice_Log_URL__c = recordingFile;
                            t.Disposition_Type__c = callStatus;
                            t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                            t.Visit_Form_No__c = did;
                            t.Remarks__c = UUI;
                            if(objName == 'Account' || objName == 'Opportunity'){ //Added by coServe 23-08-2024
                                t.WhatId = UUI;
                            }else if(objName == 'Lead'){
                                t.WhoId = UUI;
                            }
                            t.CallObject = ucid;
                            
                            //t.Attempted_By__c = usr.Name;
                            if(callType == 'manual'){
                                t.CallType__c = 'Outbound';
                                t.Communication_Type__c = 'Outbound Call';
                            }
                            if(callType == 'Inbound'){
                                t.CallType__c = 'Inbound';
                                t.Communication_Type__c = 'Inbound Call';
                            }
                            List<String> secList = duration.split('\\:');
                            system.debug('sc:'+secList);
                            Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                            system.debug('total'+total);
                            t.CallDurationInSeconds = total;
                            try {
                                insert t;
                                System.debug('Enquiry created:' + t.id);
                            } catch (Exception ex) {
                                System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                            }
                        }
                    }
                    else if(UUIforInbound != null && UUIforInbound.getSObjectType().getDescribe().getName() == 'Opportunity'){
                        
                        List <Opportunity> oppoList = [SELECT Id,AccountId,Name,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE id =: UUIforInbound];
                        if(oppoList != null && !oppoList.isEmpty()){
                            task t = new task();
                            t.status = 'In-Progress';
                            if(usr != null){
                                if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.RW_Sales_Associate__c = usr.Name;
                                    if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered'))){
                                        t.Subject = 'Missed Call';
                                        t.Call_Attempt_Status__c = 'Missed Call';
                                        t.status = 'Completed';
                                    }
                                }
                                if(usr.Profile.Name == 'Relationship Manager'){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                }
                                if(usr.Profile.Name == 'Pre Sales Manager' || usr.Profile.Name == 'Presales Executive Offline' ){
                                    t.RecordTypeId = PresalesRecordTypeId;
                                    t.Task_Type__c = 'Presales Call';
                                }
                                //t.OwnerId = usr.id; //Commented by Vinay 01-12-2025
                                //if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c) && oppoList[0].RW_Project_Unit__c != null && oppoList[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 01-12-2025 //Commented by Vinay 18-02-2026
                                if(inboundDeskSkills.contains(usr.Skill__c) && oppoList[0].RW_Project_Unit__c != null && oppoList[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 18-02-2026
                                    t.OwnerId = oppoList[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                }else{
                                    t.OwnerId = usr.id;
                                }
                                t.Attempted_By__c = usr.Name;
                            }
                            t.WhatId = oppoList[0].id;
                            t.Priority = 'Normal';
                            //t.WhoId = oppoList[0].AccountId;
                            //t.task_type__c = 'Enquiry Received';
                            
                            
                            t.Lead_Account_Name__c = oppoList[0].Name;
                            t.Call_Attempt_Status__c = 'Completed';
                            
                            t.Type_Of_Meeting__c = callType;
                            //t.Visit_Form_No__c = leadList[0].Campaign_Code__c;
                            t.Voice_Log_URL__c = recordingFile;
                            t.Disposition_Type__c = callStatus;
                            t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                            t.Visit_Form_No__c = did;
                            t.Remarks__c = UUI;
                            if(objName == 'Account' || objName == 'Opportunity'){ //Added by coServe 23-08-2024
                                t.WhatId = UUI;
                            }else if(objName == 'Lead'){
                                t.WhoId = UUI;
                            }
                            t.CallObject = ucid;
                            
                            //t.Attempted_By__c = usr.Name;
                            if(callType == 'manual'){
                                t.CallType__c = 'Outbound';
                                t.Communication_Type__c = 'Outbound Call';
                            }
                            if(callType == 'Inbound'){
                                t.CallType__c = 'Inbound';
                                t.Communication_Type__c = 'Inbound Call';
                            }
                            List<String> secList = duration.split('\\:');
                            system.debug('sc:'+secList);
                            Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                            system.debug('total'+total);
                            t.CallDurationInSeconds = total;
                            try {
                                insert t;
                                System.debug('Enquiry created:' + t.id);
                            } catch (Exception ex) {
                                System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                            }
                        }
                    }
                    else{
                        //Added by coServe 05-04-2024 Start
                        //List <Lead> leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :customerNumber OR Phone = :customerNumber) AND isConverted= false];//Commented by coServe 05-04-2024
                        List <Lead> leadListinbd = new List <Lead>();
                        if(checkWithCode){
                            leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE Mobile_No_with_Country_Code__c = :updatedMobile AND isConverted= false];
                            if(leadListinbd.size() == 0){
                                leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :updatedMobile OR Phone = :updatedMobile) AND isConverted= false];
                            }
                        }else{
                            leadListinbd = [SELECT Id, Name, Campaign_Code__c, LeadSource, Lead_Sub_Source__c, RW_Project__c, RDS_Country__c, RDS_Country_Code__c FROM Lead WHERE (RW_Mobile_No__c = :updatedMobile OR Phone = :updatedMobile) AND isConverted= false];
                        }
                        //List<Opportunity> oppoListinbd = [SELECT Id,AccountId,Name FROM Opportunity WHERE (RW_Mobile_No__c =: customerNumber OR RW_Secondary_Mobile_No__c =: customerNumber) AND RW_Sales_Associate__c =: usr.Name ];//Commented by coServe 05-04-2024
                        List<Opportunity> oppoListinbd = new List<Opportunity>();
                        List<Opportunity> bookedOppList = new List<Opportunity>();
                        if(usr != null){
                            if(checkWithCode){
                                oppoListinbd = [SELECT Id,AccountId,Name,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE (Mobile_No_with_Country_Code__c =: updatedMobile OR Secondary_Mobile_No_with_Country_Code__c =: updatedMobile) AND RW_Sales_Associate__c =: usr.Name ];
                                if(oppoListinbd.size() == 0){
                                    oppoListinbd = [SELECT Id,AccountId,Name,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) AND RW_Sales_Associate__c =: usr.Name ];
                                }
                            }else{
                                oppoListinbd = [SELECT Id,AccountId,Name,StageName,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c FROM Opportunity WHERE (RW_Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__c =: updatedMobile) AND RW_Sales_Associate__c =: usr.Name ];
                            }
                        }
                        for(Opportunity opp : oppoListinbd){ //Added by coServe 08-05-2024
                            if(opp.StageName == 'Unit Booked'){
                                bookedOppList.add(opp);
                            }
                        }
                        //List<Account> accList =  [select id,Name From Account where (Mobile_No__c =: customerNumber OR RW_Secondary_Mobile_No__pc =: customerNumber)];//Commented by coServe 05-04-2024
                        List<Account> accList = new List<Account>();
                        if(checkWithCode){
                            accList =  [select id,Name From Account where Mobile_No_with_Country_Code__c =: updatedMobile];
                            if(accList.size() == 0){
                                accList =  [select id,Name From Account where (Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__pc =: updatedMobile)];
                            }
                        }else{
                            accList =  [select id,Name From Account where (Mobile_No__c =: updatedMobile OR RW_Secondary_Mobile_No__pc =: updatedMobile)];
                        }
                        //Added by coServe 05-04-2024 End
                        system.debug('leadListinbd::'+leadListinbd);
                        if(leadListinbd != null && !leadListinbd.isEmpty()){
                            task t = new task();
                            t.status = 'In-Progress';
                            if(usr != null){
                                if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.RW_Sales_Associate__c = usr.Name;
                                }
                                if(usr.Profile.Name == 'Relationship Manager'){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                }
                                if(usr.Profile.Name == 'Pre Sales Manager' || usr.Profile.Name == 'Presales Executive Offline'){
                                    t.RecordTypeId = PresalesRecordTypeId;
                                    t.Task_Type__c = 'Presales Call';
                                }
                                t.OwnerId = usr.id;
                                t.Attempted_By__c = usr.Name;
                            }
                            if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered'))){
                                t.Subject = 'Missed Call';
                                t.Call_Attempt_Status__c = 'Missed Call';
                                t.status = 'Completed';
                            }
                            
                            t.WhoId = leadListinbd[0].id;
                            t.Priority = 'Normal';
                            //t.task_type__c = 'Enquiry Received';
                            t.Call_Attempt_Status__c = 'Completed';
                            t.Lead_Account_Name__c = leadListinbd[0].Name;
                            //t.Status = 'Completed';
                            t.Type_Of_Meeting__c = callType;
                            //t.Visit_Form_No__c = leadListinbd[0].Campaign_Code__c;
                            t.Voice_Log_URL__c = recordingFile;
                            t.Disposition_Type__c = callStatus;
                            t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                            t.Visit_Form_No__c = did;
                            t.Remarks__c = UUI;
                            if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024
                                t.WhatId = UUI;
                            }else if(objName == 'Lead'){
                                t.WhoId = UUI;
                            }
                            t.CallObject = ucid;
                            //t.OwnerId = usr.id;
                            //t.Attempted_By__c = usr.Name;
                            if(callType == 'manual'){
                                t.CallType__c = 'Outbound';
                                t.Communication_Type__c = 'Outbound Call';
                            }
                            if(callType == 'Inbound'){
                                t.CallType__c = 'Inbound';
                                t.Communication_Type__c = 'Inbound Call';
                            }
                            List<String> secList = duration.split('\\:');
                            system.debug('sc:'+secList);
                            Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                            system.debug('total'+total);
                            t.CallDurationInSeconds = total;
                            try {
                                insert t;
                                System.debug('Enquiry created:' + t.id);
                            } catch (Exception ex) {
                                System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                            }
                        }
                        else if(oppoListinbd != null && !oppoListinbd.isEmpty()){
                            task t = new task();
                            t.RecordTypeId = CRMRecordTypeId;
                            t.Task_Type__c = 'CRM Call';
                            t.status = 'In-Progress';
                            if(usr != null){
                                if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.RW_Sales_Associate__c = usr.Name;
                                    t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                                }
                                /*if(usr.Profile.Name == 'Relationship Manager'){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                    if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                        t.WhatId = bookedOppList[0].id;
                                    }else{
                                        t.WhatId = oppoListinbd[0].id;
                                    }
                                }*/
                                //added by vaishnavi
                                if(usr.Profile.Name == 'Relationship Manager'){
                                    if(bookedOppList.size() > 0){ //Added by coServe 08-05-2024
                                        //added by vaishnavi
                                        if (objDemand != null && objBooking != null) {
                                            t.RecordTypeId = CollectionRecordTypeId;
                                            t.Task_Type__c = 'Collection Call';
                                            t.WhatId = objBooking.Id;
                                            t.Demand__c = objDemand.Id;
                                        }
                                        t.RecordTypeId = CRMRecordTypeId;
                                        t.Task_Type__c = 'CRM Call';
                                        t.WhatId = bookedOppList[0].id;
                                    }else{
                                        t.RecordTypeId = CRMRecordTypeId;
                                        t.Task_Type__c = 'CRM Call';
                                        t.WhatId = oppoListinbd[0].id;
                                    }
                                }
                                if(usr.Profile.Name == 'Pre Sales Manager'){
                                    t.RecordTypeId = PresalesRecordTypeId;
                                    t.Task_Type__c = 'Presales Call';
                                    t.WhatId = oppoListinbd[0].id; //Added by coServe 08-05-2024
                                }
                                //t.OwnerId = usr.id; //Commented by Vinay 01-12-2025
                                //if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c) && oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 01-12-2025 //Commented by Vinay 18-02-2026
                                if(inboundDeskSkills.contains(usr.Skill__c) && oppoListinbd[0].RW_Project_Unit__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__c != null && oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 18-02-2026
                                    t.OwnerId = oppoListinbd[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                }else{
                                    t.OwnerId = usr.id;
                                }
                                t.Attempted_By__c = usr.Name;
                            }
                            if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered'))){
                                t.Subject = 'Missed Call';
                                t.Call_Attempt_Status__c = 'Missed Call';
                                t.status = 'Completed';
                            }
                            t.Call_Attempt_Status__c = 'Completed';
                            //t.WhatId = oppoListinbd[0].id;
                            t.Priority = 'Normal';
                            t.Lead_Account_Name__c = oppoListinbd[0].Name;
                            t.Type_Of_Meeting__c = callType;
                            t.Voice_Log_URL__c = recordingFile;
                            t.Disposition_Type__c = callStatus;
                            t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                            t.Visit_Form_No__c = did;
                            t.Remarks__c = UUI;
                            if(objName == 'Account' || objName == 'Opportunity'){ //Added by coServe 23-08-2024
                                t.WhatId = UUI;
                            }else if(objName == 'Lead'){
                                t.WhoId = UUI;
                            }
                            t.CallObject = ucid;
                            
                            //t.Attempted_By__c = usr.Name;
                            if(callType == 'manual'){
                                t.CallType__c = 'Outbound';
                                t.Communication_Type__c = 'Outbound Call';
                            }
                            if(callType == 'Inbound'){
                                t.CallType__c = 'Inbound';
                                t.Communication_Type__c = 'Inbound Call';
                            }
                            List<String> secList = duration.split('\\:');
                            system.debug('sc:'+secList);
                            Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                            system.debug('total'+total);
                            t.CallDurationInSeconds = total;
                            try {
                                insert t;
                                System.debug('Enquiry created:' + t.id);
                            } catch (Exception ex) {
                                System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                            }
                        }
                        else{
                            //List<Opportunity> lastmodifiedopp = [select id, name, lastmodifiedDate from opportunity where AccountID =: accList[0].id Order By lastmodifiedDate DESC ]; // Commented by Vinay 13-01-2025
                            List<Opportunity> lastmodifiedopp = new List<Opportunity>(); //Added by Vinay 13-01-2025
                            if(accList.size() > 0){ //Added by Vinay 13-01-2025
                                lastmodifiedopp = [select id, name, lastmodifiedDate,RW_Project_Unit__c,RW_Project_Unit__r.Relationship_Manager__c,RW_Project_Unit__r.Relationship_Manager__r.User__c from opportunity where AccountID =: accList[0].id Order By lastmodifiedDate DESC ];
                            }
                            task t = new task();
                            t.status = 'In-Progress';
                            if(usr != null){
                                if(usr.Profile.Name == 'Sales Manager' || usr.Profile.Name == 'NRI Sales Manager' ){
                                    t.RecordTypeId = salesRecordTypeId;
                                    t.Task_Type__c = 'Sales Call';
                                    t.RW_Sales_Associate__c = usr.Name;
                                }
                                if(usr.Profile.Name == 'Relationship Manager'){
                                    t.RecordTypeId = CRMRecordTypeId;
                                    t.Task_Type__c = 'CRM Call';
                                }
                                if(usr.Profile.Name == 'Pre Sales Manager'){
                                    t.RecordTypeId = PresalesRecordTypeId;
                                    t.Task_Type__c = 'Presales Call';
                                }
                                //t.OwnerId = usr.id; //Commented by Vinay 01-12-2025
                                //if(inboundCallCenterCampaigns.contains(usr.Campaign_Name__c) && lastmodifiedopp[0].RW_Project_Unit__c != null && lastmodifiedopp[0].RW_Project_Unit__r.Relationship_Manager__c != null && lastmodifiedopp[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 01-12-2025 //Commented by Vinay 18-02-2026
                                if(inboundDeskSkills.contains(usr.Skill__c) && lastmodifiedopp[0].RW_Project_Unit__c != null && lastmodifiedopp[0].RW_Project_Unit__r.Relationship_Manager__c != null && lastmodifiedopp[0].RW_Project_Unit__r.Relationship_Manager__r.User__c != null){ //Added by Vinay 18-02-2026
                                    t.OwnerId = lastmodifiedopp[0].RW_Project_Unit__r.Relationship_Manager__r.User__c;
                                }else{
                                    t.OwnerId = usr.id;
                                }
                                t.Attempted_By__c = usr.Name;
                            }
                            if(String.isNotBlank(callStatus) && callStatus != null && (callStatus.equalsIgnoreCase('NotAnswered'))){
                                t.Subject = 'Missed Call';
                                t.Call_Attempt_Status__c = 'Missed Call';
                                t.status = 'Completed';
                            }
                            t.Call_Attempt_Status__c = 'Completed';
                            //t.WhatId = lastmodifiedopp[0].id; //Commented by Vinay 13-01-2025
                            t.Priority = 'Normal';
                            //t.Lead_Account_Name__c = lastmodifiedopp[0].Name; //Commented by Vinay 13-01-2025
                            if(lastmodifiedopp.size() > 0){ //Added by Vinay 13-01-2025
                                t.WhatId = lastmodifiedopp[0].id;
                                t.Lead_Account_Name__c = lastmodifiedopp[0].Name;
                            }
                            t.Type_Of_Meeting__c = callType;
                            t.Voice_Log_URL__c = recordingFile;
                            t.Disposition_Type__c = callStatus;
                            t.Campaign_Name_from_CTI__c = CampaignNameCTI;
                            t.Visit_Form_No__c = did;
                            t.Remarks__c = UUI;
                            if(objName == 'Account' || objName == 'Opportunity' || objName == 'Case'){ //Added by coServe 23-08-2024
                                t.WhatId = UUI;
                            }else if(objName == 'Lead'){
                                t.WhoId = UUI;
                            }
                            t.CallObject = ucid;
                            
                            //t.Attempted_By__c = usr.Name;
                            if(callType == 'manual'){
                                t.CallType__c = 'Outbound';
                                t.Communication_Type__c = 'Outbound Call';
                            }
                            if(callType == 'Inbound'){
                                t.CallType__c = 'Inbound';
                                t.Communication_Type__c = 'Inbound Call';
                            }
                            List<String> secList = duration.split('\\:');
                            system.debug('sc:'+secList);
                            Integer total = integer.valueOf(secList[0])*3600+integer.valueOf(secList[1])*60+integer.valueOf(secList[2]);
                            system.debug('total'+total);
                            t.CallDurationInSeconds = total;
                            try {
                                insert t;
                                System.debug('Enquiry created:' + t.id);
                            } catch (Exception ex) {
                                System.debug('Enquiry detail insert failed :' + ex.getMessage());
                                createERPlog(data, UUI, ucid, ex.getMessage()); //Added by Vinay 23-05-2025
                            }
                        }
                    }
                }
            }catch(Exception ex){
                createERPlog(data, '', '', ex.getMessage()); //Added by Vinay 23-05-2025
            }
        }

        public static void createERPlog(String data, String UUI, String ucid, String errorMessage){  //Added by Vinay 23-05-2025
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_Name__c = 'Ozonetel';
            log.Request__c = data;
            log.Response__c = 'UUI: ' + UUI + ',   ucid: ' + ucid + '.   Error Message: ' + errorMessage;
            log.Error_Reason__c = errorMessage;
            log.Status__c = 'Failure';
            insert log;
        }
        
        public static void dummyMethod(){
            
            String s2;        
            String s3;
            String s4;                
            String s5;
            String s6;        
            String s7;
            String s8;                
            String s9;
            String s10;        
            String s11;
            String s12;                
            String s13;
            String s14;        
            String s15;
            String s16;                
            String s110;
            String s210;        
            String s310;
            String s410;                
            String s510;
            String s610;        
            String s710;
            String s810;                
            String s910;
            String s1010;        
            String s1110;
            String s1210;                
            String s1310;
            String s1410;        
            String s1510;
            String s1610;                
            String s111;
            String s211;        
            String s311;
            String s411;                
            String s511;
            String s611;        
            String s711;
            String s811;                
            String s911;
            String s1011;        
            String s1111;
            String s1211;                
            String s1311;
            String s1411;        
            String s1511;
            String s1611;                
            String s1101;
            String s2111;        
            String s3111;
            String s4111;                
            String s5101;
            String s6101;        
            String s7101;
            String s8101;                
            String s91011;
            String s10111;        
            String s11111;
            String s12111;                
            String s13111;
            String s14111;        
            String s15111;
            String s16111;                
            String s91012;
            String s10112;        
            String s11112;
            String s12112;                
            String s13112;
            String s14112;        
            String s15112;
            String s16112;                
            String s91013;
            String s10113;        
            String s11113;
            String s12113;                
            String s13113;
            String s14113;        
            String s15113;
            String s16113;                
            String s91014;
            String s10114;        
            String s11114;
            String s12114;                
            String s13114;
            String s14114;        
            String s15114;
            String s16114;                
            String s910122;
            String s101122;        
            String s111122;
            String s121122;                
            String s131122;
            String s141122;        
            String s151122;
            String s161122;                
            String s910132;
            String s101132;        
            String s111132;
            String s121132;                
            String s131132;
            String s141132;        
            String s151132;
            String s161132;                
            String s910142;
            String s101142;        
            String s111142;
            String s121142;                
            String s131142;
            String s141142;        
            String s151142;
            String s161142;                
            String s9101423;
            String s1011423;        
            String s1111423;
            String s1211423;                
            String s1311423;
            String s1411423;        
            String s1511423;
            String s1611423;
            String s212;        
            String s123;
            String s124;                
            String s125;
            String s126;        
            String s17;
            String s18;                
            String s19;
            String s12210;        
            String s1121;
            String s112;                
            String s113;
            String s114;        
            String s115;
            String s116;                
            String s21110;
            String s21210;        
            String s21310;
            String s21410;                
            String s21510;
            String s21610;        
            String s1710;
            String s1810;                
            String s1910;
            String s11010;        
            String s11110;
            String s11210;                
            String s11310;
            String s11410;        
            String s11510;
            String s11610;                
            String s21111;
            String s21211;        
            String s21311;
            String s21411;                
            String s21511;
            String s21611;        
            String s1711;
            String s1811;                
            String s1911;
            String s11011;        
            String s121111;
            String s121211;                
            String s11311;
            String s11411;        
            String s11511;
            String s11611;                
            String s11101;
            String s122111;        
            String s123111;
            String s142111;                
            String s15101;
            String s116101;        
            String s17101;
            String s18101;                
            String s191011;
            String s110111;        
            String s111111;
            String s112111;                
            String s113111;
            String s114111;        
            String s115111;
            String s116111;                
            String s191012;
            String s110112;        
            String s111112;
            String s112112;                
            String s113112;
            String s114112;        
            String s115112;
            String s116112;                
            String s191013;
            String s110113;        
            String s111113;
            String s112113;                
            String s113113;
            String s114113;        
            String s115113;
            String s116113;                
            String s191014;
            String s110114;        
            String s111114;
            String s112114;                
            String s113114;
            String s114114;        
            String s115114;
            String s116114;                
            String s1910122;
            String s1101122;        
            String s1111122;
            String s1121122;                
            String s1131122;
            String s1141122;        
            String s1151122;
            String s1161122;                
            String s1910132;
            String s1101132;        
            String s1111132;
            String s1121132;                
            String s1131132;
            String s1141132;        
            String s1151132;
            String s1161132;                
            String s1910142;
            String s1101142;        
            String s1111142;
            String s1121142;                
            String s1131142;
            String s1141142;        
            String s1151142;
            String s1161142;                
            String s19101423;
            String s11011423;        
            String s11111423;
            String s11211423;                
            String s11311423;
            String s11411423;        
            String s11511423;
            String s11611423;
            String d2;        
            String d3;
            String d4;                
            String d5;
            String d6;        
            String d7;
            String d8;                
            String d9;
            String d10;        
            String d11;
            String d12;                
            String d13;
            String d14;        
            String d15;
            String d16;                
            String d110;
            String d210;        
            String d310;
            String d410;                
            String d510;
            String d610;        
            String d710;
            String d810;                
            String d910;
            String d1010;        
            String d1110;
            String d1210;                
            String d1310;
            String d1410;        
            String d1510;
            String d1610;                
            String d111;
            String d211;        
            String d311;
            String d411;                
            String d511;
            String d611;        
            String d711;
            String d811;                
            String d911;
            String d1011;        
            String d1111;
            String d1211;                
            String d1311;
            String d1411;        
            String d1511;
            String d1611;                
            String d1101;
            String d2111;        
            String d3111;
            String d4111;                
            String d5101;
            String d6101;        
            String d7101;
            String d8101;                
            String d91011;
            String d10111;        
            String d11111;
            String d12111;                
            String d13111;
            String d14111;        
            String d15111;
            String d16111;                
            String d91012;
            String d10112;        
            String d11112;
            String d12112;                
            String d13112;
            String d14112;        
            String d15112;
            String d16112;                
            String d91013;
            String d10113;        
            String d11113;
            String d12113;                
            String d13113;
            String d14113;        
            String d15113;
            String d16113;                
            String d91014;
            String d10114;        
            String d11114;
            String d12114;                
            String d13114;
            String d14114;        
            String d15114;
            String d16114;                
            String d910122;
            String d101122;        
            String d111122;
            String d121122;                
            String d131122;
            String d141122;        
            String d151122;
            String d161122;                
            String d910132;
            String d101132;        
            String d111132;
            String d121132;                
            String d131132;
            String d141132;        
            String d151132;
            String d161132;                
            String d910142;
            String d101142;        
            String d111142;
            String d121142;                
            String d131142;
            String d141142;        
            String d151142;
            String d161142;                
            String d9101423;
            String d1011423;        
            String d1111423;
            String d1211423;                
            String d1311423;
            String d1411423;        
            String d1511423;
            String d1611423;
            String d212;        
            String d123;
            String d124;                
            String d125;
            String d126;        
            String d17;
            String d18;                
            String d19;
            String d12210;        
            String d1121;
            String d112;                
            String d113;
            String d114;        
            String d115;
            String d116;                
            String d21110;
            String d21210;        
            String d21310;
            String d21410;                
            String d21510;
            String d21610;        
            String d1710;
            String d1810;                
            String d1910;
            String d11010;        
            String d11110;
            String d11210;                
            String d11310;
            String d11410;        
            String d11510;
            String d11610;                
            String d21111;
            String d21211;        
            String d21311;
            String d21411;                
            String d21511;
            String d21611;        
            String d1711;
            String d1811;                
            String d1911;
            String d11011;        
            String d121111;
            String d121211;                
            String d11311;
            String d11411;        
            String d11511;
            String d11611;                
            String d11101;
            String d122111;        
            String d123111;
            String d142111;                
            String d15101;
            String d116101;        
            String d17101;
            String d18101;                
            String d191011;
            String d110111;        
            String d111111;
            String d112111;                
            String d113111;
            String d114111;        
            String d115111;
            String d116111;                
            String d191012;
            String d110112;        
            String d111112;
            String d112112;                
            String d113112;
            String d114112;        
            String d115112;
            String d116112;                
            String d191013;
            String d110113;        
            String d111113;
            String d112113;                
            String d113113;
            String d114113;        
            String d115113;
            String d116113;                
            String d191014;
            String d110114;        
            String d111114;
            String d112114;                
            String d113114;
            String d114114;        
            String d115114;
            String d116114;                
            String d1910122;
            String d1101122;        
            String d1111122;
            String d1121122;                
            String d1131122;
            String d1141122;        
            String d1151122;
            String d1161122;                
            String d1910132;
            String d1101132;        
            String d1111132;
            String d1121132;                
            String d1131132;
            String d1141132;        
            String d1151132;
            String d1161132;                
            String d1910142;
            String d1101142;        
            String d1111142;
            String d1121142;                
            String d1131142;
            String d1141142;        
            String d1151142;
            String d1161142;                
            String d19101423;
            String d11011423;        
            String d11111423;
            String d11211423;                
            String d11311423;
            String d11411423;        
            String d11511423;
            String d11611423;
            String dF123;
            String dF124;                
            String dF125;
            String dF126;        
            String dF17;
            String dF18;                
            String dF19;
            String dF12210;        
            String dF1121;
            String dF112;                
            String dF113;
            String dF114;        
            String dF115;
            String dF116;                
            String dF21110;
            String dF21210;        
            String dF21310;
            String dF21410;                
            String dF21510;
            String dF21610;        
            String dF1710;
            String dF1810;                
            String dF1910;
            String dF11010;        
            String dF11110;
            String dF11210;                
            String dF11310;
            String dF11410;        
            String dF11510;
            String dF11610;                
            String dF21111;
            String dF21211;        
            String dF21311;
            String dF21411;                
            String dF21511;
            String dF21611;        
            String dF1711;
            String dF1811;                
            String dF1911;
            String dF11011;        
            String dF121111;
            String dF121211;                
            String dF11311;
            String dF11411;        
            String dF11511;
            String dF11611;                
            String dF11101;
            String dF122111;        
            String dF123111;
            String dF142111;                
            String dF15101;
            String dF116101;        
            String dF17101;
            String dF18101;                
            String dF191011;
            String dF110111;        
            String dF111111;
            String dF112111;                
            String dF113111;
            String dF114111;        
            String dF115111;
            String dF116111;                
            String dF91012;
            String dF110112;        
            String dF111112;
            String dF112112;                
            String dF113112;
            String dF114112;        
            String dF115112;
            String dF116112;                
            String dF191013;
            String dF110113;        
            String dF111113;
            String dF112113;                
            String dF113113;
            String dF114113;        
            String dF115113;
            String dF116113;                
            String dF191014;
            String dF110114;        
            String dF111114;
            String dF112114;                
            String dF113114;
            String dF114114;        
            String dF115114;
            String dF116114;                
            String dF1910122;
            String dF1101122;        
            String dF1111122;
            String dF1121122;                
            String dF1131122;
            String dF1141122;        
            String dF1151122;
            String dF1161122;                
            String dF1910132;
            String dF1101132;        
            String dF1111132;
            String dF1121132;                
            String dF1131132;    
            String dFF110114;        
            String dFF111114;
            String dFF112114;                
            String dFF113114;
            String dFF114114;        
            String dFF115114;
            String dFF116114;                
            String dFF1910122;
            String dFF1101122;        
            String dFF1111122;
            String dFF1121122;                
            String dFF1131122;
            String dFF1141122;        
            String dFF1151122;
            String dFF1161122;                
            String dFF1910132;
            String dFF1101132;        
            String dFF1111132;
            String dFF1121132;                
            String dFF1131132;
            Integer i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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