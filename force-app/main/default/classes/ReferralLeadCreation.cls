public class ReferralLeadCreation implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> referralIds;
    
    @InvocableMethod
    public static void executeReferralLeadCreation(List<String> refIds) {
        //ReferralLeadCreation(refIds);
        Id jobId = Database.executeBatch(new ReferralLeadCreation(refIds));
    }
    
    public ReferralLeadCreation(List<String> refIds){
        this.referralIds = refIds;
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        //string query = 'Select Id, Name, Account__c, RW_Last_Name__c, RW_First_Name__c, RW_Email_Address__c, RW_Contact_Phone__c, RW_How_do_you_know_this_person__c, RW_Project__c, RW_Status__c, RW_Mode__c, RW_LeadCreated__c , RW_Referral_Id__c,RW_Duplicate_Lead__c,Project_Unit__c,Account__r.Name,Account__r.Id,Project_Unit__r.Name From RW_Referral__c where RW_Referral_Processed__c = false';
        //return Database.getQueryLocator(query);
        if(referralIds.size() > 0){
            return Database.getQueryLocator([Select Id, Name, Account__c, RW_Last_Name__c, RW_First_Name__c, RW_Email_Address__c, RW_Contact_Phone__c, RW_How_do_you_know_this_person__c, RW_Project__c, RW_Status__c, RW_Mode__c, RW_LeadCreated__c , RW_Referral_Id__c,RW_Duplicate_Lead__c,Project_Unit__c,Account__r.Name,Account__r.Id,Project_Unit__r.Name From RW_Referral__c where Id =: referralIds]);
        }else{
            string query = 'Select Id, Name, Account__c, RW_Last_Name__c, RW_First_Name__c, RW_Email_Address__c, RW_Contact_Phone__c, RW_How_do_you_know_this_person__c, RW_Project__c, RW_Status__c, RW_Mode__c, RW_LeadCreated__c , RW_Referral_Id__c,RW_Duplicate_Lead__c,Project_Unit__c,Account__r.Name,Account__r.Id,Project_Unit__r.Name From RW_Referral__c where RW_Referral_Processed__c = false';
        	return Database.getQueryLocator(query);
        }
        
    }
    
    public void execute(Database.BatchableContext bc, List<RW_Referral__c> refList){
        Set<String> refContactPhone = new Set<String>();
        
        for(RW_Referral__c ref : refList){
            String mobile = ref.RW_Contact_Phone__c;
            mobile = mobile.deleteWhitespace();
            if(mobile.startswith('+91')){
                mobile = mobile.subString(3, mobile.length());
            }
            refContactPhone.add(mobile);
        }
        Map<String, Opportunity> mobVsOppMap = new Map<String, Opportunity>();
        Map<String, Opportunity> mobProjVsOppMap = new Map<String, Opportunity>();
        List<Opportunity> opps = [SELECT Id, Name, RW_Mobile_No__c, RW_Project__r.Name, StageName, Status__c, RW_Opportunity_Status__c FROM Opportunity WHERE RW_Mobile_No__c =: refContactPhone];
        for(Opportunity opp : opps){
            mobVsOppMap.put(opp.RW_Mobile_No__c, opp);
            mobProjVsOppMap.put(opp.RW_Mobile_No__c+':'+opp.RW_Project__r.Name, opp);
        }
        
        Map<String, Lead> mobVsLeadMap = new Map<String, Lead>();
        List<Lead> leads = [SELECT Id, Name, RW_Mobile_No__c, RW_Project__r.Name FROM Lead WHERE RW_Mobile_No__c =: refContactPhone AND IsDeleted = false AND IsConverted = false];
        for(Lead ld : leads){
            mobVsLeadMap.put(ld.RW_Mobile_No__c, ld);
        }
        
        Map<String, Prospect__c> mobVsProspect = new Map<String, Prospect__c>();
        Map<String, Prospect__c> mobProjVsProspect = new Map<String, Prospect__c>();
        List<Prospect__c> prospects = [SELECT Id, Mobile_No__c, Project__r.Name, Lead__c, Opportunity__c FROM Prospect__c WHERE Mobile_No__c =: refContactPhone];
        for(Prospect__c pros : prospects){
            mobVsProspect.put(pros.Mobile_No__c, pros);
            mobProjVsProspect.put(pros.Mobile_No__c+':'+pros.Project__r.Name, pros);
        }
        
        List<Project__c> prjList = [SELECT Id, Name, CRMHead__c, CRMHead__r.Email, Loyalty_Head__c, Loyalty_Head__r.Username FROM Project__c];   
        Map<String, Project__c> projMap = new Map<String, Project__c>();
        for(Project__c prj : prjList){
            projMap.put(prj.Name, prj); 
        }
        List<Lead> leadsToInsert = new List<Lead>();
        List<Prospect__c> prospectsToInsert = new List<Prospect__c>();
        List<Task> tasksToInsert = new List<Task>();
        
        List<Lead> leadsToCreateTasks = new List<Lead>();
        List<Prospect__c> prospectsToCreateTasks = new List<Prospect__c>();
        List<Opportunity> oppsToCreateTasks = new List<Opportunity>();
        
        Id LoyaltyRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Referral and Loyalty').getRecordTypeId();
        
        for(RW_Referral__c ref : refList){
            //Added by coServe 27-06-2024 Start
            String mobile = ref.RW_Contact_Phone__c;
            mobile = mobile.deleteWhitespace();
            if(mobile.startswith('+91')){
                mobile = mobile.subString(3, mobile.length());
            }
            //ref.RW_Contact_Phone__c = mobile;
            System.debug('mobile: ' + mobile);
            //Added by coServe 27-06-2024 End
            if(!mobVsOppMap.keySet().contains(mobile)){
                if(!mobVsLeadMap.keySet().contains(mobile)){
                    //Create lead with Task for Loyalty TL 
                    
                    Lead lead = new Lead();
                    lead.RW_Referral_Lead__c = ref.Id;
                    lead.Email = ref.RW_Email_Address__c;
                    lead.RW_Mobile_No__c = mobile; 
                    lead.LastName = ref.RW_Last_Name__c;
                    lead.FirstName = ref.RW_First_Name__c;
                    lead.Customer_Reference__c = ref.Account__c;
                    if(ref.RW_Project__c!=null){
                        lead.RW_Project__c =  projMap.get(ref.RW_Project__c).Id;
                        If(projMap.get(ref.RW_Project__c).Loyalty_Head__c != null){
                            lead.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                        }
                    }
                    lead.LeadSource = 'Referral';
                    lead.RW_Lead_Sub_Source__c = 'Existing client reference'; 
                    lead.Referral_Batch_Lead__c = true;
                    leadsToInsert.add(lead);
                    if(!Test.isRunningTest()){
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,ref.RW_Project__c,null,null, null,null,null,null,null,'+91',mobile,'Loyalty Lead Creation');
                    }
                    
                }else if(mobVsLeadMap.keySet().contains(mobile)){
                    if(mobVsLeadMap.get(mobile).RW_Project__r.Name == ref.RW_Project__c){
                        //Task for Loyalty TL
                        leadsToCreateTasks.add(mobVsLeadMap.get(mobile));
                        Task tsk = new Task();
                        tsk.WhoId = mobVsLeadMap.get(mobile).Id;
                        //tsk.Description = 'New Referral Lead created';
                        tsk.Subject = 'New Referral Lead created';
                        tsk.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                        tsk.RecordTypeId = LoyaltyRecordTypeId;
                        tasksToInsert.add(tsk);
                        ref.RW_Duplicate_Lead__c = true;
                    }else{
                        if(mobVsProspect.keySet().contains(mobile) && mobVsProspect.get(mobile).Project__r.Name == ref.RW_Project__c){
                            //Task for Loyalty TL
                            prospectsToCreateTasks.add(mobVsProspect.get(mobile));
                            Task tsk = new Task();
                            //tsk.WhatId = mobVsProspect.get(ref.RW_Contact_Phone__c).Id;
                            tsk.WhoId = mobVsLeadMap.get(mobile).Id;
                            //tsk.Description = 'New Referral Lead created';
                            tsk.Subject = 'New Referral Lead created';
                            tsk.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                            tsk.RecordTypeId = LoyaltyRecordTypeId;
                            tasksToInsert.add(tsk); 
                            ref.RW_Duplicate_Lead__c = true;
                        }else if(mobVsProspect.keySet().contains(mobile) && mobVsProspect.get(mobile).Project__r.Name != ref.RW_Project__c){
                            //Create prospect with Task for Loyalty TL
                            Prospect__c pros = new Prospect__c();
                            //pros.Name = mobVsLeadMap.get(ref.RW_Contact_Phone__c).Name;
                            //pros.Project__c = mobVsLeadMap.get(ref.RW_Contact_Phone__c).RW_Project__c;
                            //pros.Lead__c = mobVsLeadMap.get(ref.RW_Contact_Phone__c).Id;
                            pros.Name = ref.Name;
                            pros.Project__c = projMap.get(ref.RW_Project__c).Id;
                            pros.Lead__c = mobVsLeadMap.get(mobile).Id;
                            pros.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                            prospectsToInsert.add(pros);
                            ref.RW_LeadCreated__c = true;
                        }else if(!mobVsProspect.keySet().contains(mobile)){
                            Prospect__c pros = new Prospect__c();
                            //pros.Name = mobVsLeadMap.get(ref.RW_Contact_Phone__c).Name;
                            //pros.Project__c = mobVsLeadMap.get(ref.RW_Contact_Phone__c).RW_Project__c;
                            //pros.Lead__c = mobVsLeadMap.get(ref.RW_Contact_Phone__c).Id;
                            pros.Name = ref.Name;
                            pros.Project__c = projMap.get(ref.RW_Project__c).Id;
                            pros.Lead__c = mobVsLeadMap.get(mobile).Id;
                            pros.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                            prospectsToInsert.add(pros);
                            ref.RW_LeadCreated__c = true;
                        }
                    }
                }
            }else{
                //if(mobVsOppMap.get(ref.RW_Contact_Phone__c).RW_Project__r.Name == ref.RW_Project__c){
                if(mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c) != null){
                    //if(mobVsOppMap.get(ref.RW_Contact_Phone__c).StageName == 'Unit Booked'){
                    if(mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).StageName == 'Unit Booked'){
                        //Task for Loyalty TL
                        //oppsToCreateTasks.add(mobVsOppMap.get(ref.RW_Contact_Phone__c));
                        Task tsk = new Task();
                        //tsk.WhatId = mobVsOppMap.get(ref.RW_Contact_Phone__c).Id;
                        tsk.WhatId = mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).Id;
                        //tsk.Description = 'New Referral Lead created';
                        tsk.Subject = 'New Referral Lead created';
                        tsk.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                        tsk.RecordTypeId = LoyaltyRecordTypeId;
                        tasksToInsert.add(tsk);
                        ref.RW_Duplicate_Lead__c = true;
                    }else{
                        //if(mobVsOppMap.get(ref.RW_Contact_Phone__c).Status__c == 'Active'){
                        if(mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).RW_Opportunity_Status__c == 'Active'){
                            //Task for Loyalty TL
                            //oppsToCreateTasks.add(mobVsOppMap.get(ref.RW_Contact_Phone__c));
                            Task tsk = new Task();
                            //tsk.WhatId = mobVsOppMap.get(ref.RW_Contact_Phone__c).Id;
                            tsk.WhatId = mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).Id;
                            //tsk.Description = 'New Referral Lead created';
                            tsk.Subject = 'New Referral Lead created';
                            tsk.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                            tsk.RecordTypeId = LoyaltyRecordTypeId;
                            tasksToInsert.add(tsk);
                            ref.RW_Duplicate_Lead__c = true;
                        }else{
                            //Create prospect with Task for Loyalty TL
                            Prospect__c pros = new Prospect__c();
                            //pros.Name = mobVsOppMap.get(ref.RW_Contact_Phone__c).Name;
                            //pros.Project__c = mobVsOppMap.get(ref.RW_Contact_Phone__c).RW_Project__c;
                            //pros.Opportunity__c = mobVsOppMap.get(ref.RW_Contact_Phone__c).Id;
                            pros.Name = mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).Name;
                            pros.Project__c = mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).RW_Project__c;
                            pros.Opportunity__c = mobProjVsOppMap.get(mobile+':'+ref.RW_Project__c).Id;
                            pros.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                            prospectsToInsert.add(pros);
                            ref.RW_LeadCreated__c = true;
                        }
                    }
                }else{
                    //if(mobVsProspect.keySet().contains(ref.RW_Contact_Phone__c) && mobVsProspect.get(ref.RW_Contact_Phone__c).Project__r.Name == ref.RW_Project__c){
                    if(mobProjVsProspect.get(mobile+':'+ref.RW_Project__c) != null){
                        //Task for Loyalty TL
                        //prospectsToCreateTasks.add(mobVsProspect.get(ref.RW_Contact_Phone__c));
                        Task tsk = new Task();
                        //tsk.WhatId = mobVsProspect.get(ref.RW_Contact_Phone__c).Id;
                        tsk.WhatId = mobProjVsProspect.get(mobile+':'+ref.RW_Project__c).Id;
                        //tsk.Description = 'New Referral Lead created';
                        tsk.Subject = 'New Referral Lead created';
                        tsk.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                        tsk.RecordTypeId = LoyaltyRecordTypeId;
                        tasksToInsert.add(tsk);
                        ref.RW_Duplicate_Lead__c = true;
                    //}else if(mobVsProspect.keySet().contains(ref.RW_Contact_Phone__c) && mobVsProspect.get(ref.RW_Contact_Phone__c).Project__r.Name != ref.RW_Project__c){
                    }else{
                        //Create prospect with Task for Loyalty TL
                        Prospect__c pros = new Prospect__c();
                        pros.Name = mobVsOppMap.get(mobile).Name;
                        //pros.Project__c = mobVsOppMap.get(ref.RW_Contact_Phone__c).RW_Project__c;
                        pros.Project__c = projMap.get(ref.RW_Project__c).Id;
                        pros.Opportunity__c = mobVsOppMap.get(mobile).Id;
                        pros.OwnerId = projMap.get(ref.RW_Project__c).Loyalty_Head__c;
                        //pros.Opportunity__c = mobProjVsOppMap.get(ref.RW_Contact_Phone__c+':'+ref.RW_Project__c).Id;
                        ref.RW_LeadCreated__c = true;
                        prospectsToInsert.add(pros);
                    }
                }
            }
            ref.RW_Status__c = 'Processed';
            ref.RW_Referral_Processed__c = true;
        }
        update refList;
        if(leadsToInsert.size() > 0){
            insert leadsToInsert;
            List<Lead> leadList = [SELECT Id, Name, RW_Project__r.Name FROM Lead WHERE Id =: leadsToInsert];
            for(Lead ld : leadList){
                //leadsToCreateTasks.add(ld);
                Task tsk = new Task();
                tsk.WhoId = ld.Id;
                //tsk.Description = 'New Referral Lead created';
                tsk.Subject = 'New Referral Lead created';
                tsk.OwnerId = projMap.get(ld.RW_Project__r.Name).Loyalty_Head__c;
                tsk.RecordTypeId = LoyaltyRecordTypeId;
                tasksToInsert.add(tsk);
            }
        }
        
        /*if(leadsToCreateTasks.size() > 0){
            createTask(leadsToCreateTasks, null);
        }*/
        
        if(prospectsToInsert.size() > 0 ){
            insert prospectsToInsert;
            List<Prospect__c> prospectList = [SELECT Id, Project__r.Name FROM Prospect__c WHERE Id =: prospectsToInsert];
            for(Prospect__c pros : prospectList){
                //prospectsToCreateTasks.add(pros);
                Task tsk = new Task();
                tsk.WhatId = pros.Id;
                //tsk.Description = 'New Referral Lead created';
                tsk.Subject = 'New Referral Lead created';
                if(Test.isRunningTest()){
                    tsk.OwnerId = UserInfo.getUserId();
                }else{
                    tsk.OwnerId = projMap.get(pros.Project__r.Name).Loyalty_Head__c;
                }
                tsk.RecordTypeId = LoyaltyRecordTypeId;
                tasksToInsert.add(tsk);
            }
        }
        if(tasksToInsert.size() > 0){
            insert tasksToInsert;
        }
        
        /*if(prospectsToCreateTasks.size() > 0){
            createTask(null, prospectsToCreateTasks);
        }*/
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    

}