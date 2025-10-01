public class ReferedLeadCreation implements Database.Batchable<sObject>, Database.Stateful  {
    
    public List<Lead> leadsList;
    public Map<String,Project__c> mapOfPrj = new Map<String,Project__c>();
    public Map<id,Project__c> mapOfPrjId = new Map<id,Project__c>();
    public map<string,List<Lead>> existingLeadRefmap = new Map<string,List<Lead>>();
    public map<string,List<Lead>> existingLeadReferalmap = new Map<string,List<Lead>>();
    public Map<string, List<RW_Referral__c>> newLeadProject;
    public List<RW_Referral__c> refListForCompare =new List<RW_Referral__c>();
    public set<String> setOfProjectNames =new set<String>();
    public Map<String, RW_Referral__c> mobileProjectReferalsMap = new Map<String, RW_Referral__c>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        leadsList = new List<Lead>();
        newLeadProject = new Map<string, List<RW_Referral__c>>();
        string query = 'Select Id, Name, Account__c, RW_Last_Name__c, RW_First_Name__c, RW_Email_Address__c, RW_Contact_Phone__c, RW_How_do_you_know_this_person__c, RW_Project__c, RW_Status__c, RW_Mode__c, RW_LeadCreated__c , RW_Referral_Id__c,RW_Duplicate_Lead__c,Project_Unit__c,Account__r.Name,Account__r.Id,Project_Unit__r.Name From RW_Referral__c where RW_Referral_Processed__c = false';
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<RW_Referral__c> refList){
        list<id>  existingref =new list<id>();
        system.debug('#### refList '+refList.size());
        set<string> refContactPhone = new set<string>();
        set<string> refEmail = new set<string>();
        set<string>Project = new Set<string>();
        //Map<String, RW_Referral__c> mobileProjectReferalsMap = new Map<String, RW_Referral__c>();
        
        for(RW_Referral__c eachRef: refList){
            refContactPhone.add(eachRef.RW_Contact_Phone__c);
            refEmail.add(eachRef.RW_Email_Address__c);
            Project.add(eachRef.RW_Project__c);
            mobileProjectReferalsMap.put(eachRef.RW_Project__c+'-'+eachRef.RW_Contact_Phone__c,eachRef);
            eachref.RW_Referral_Processed__c = true;
            refListForCompare.add(eachRef);
        }
        
        update refList;
        
        List<Lead> existingLead = [Select id,Name,FirstName,LastName,RW_Mobile_No__c,project_name__c from lead where RW_Mobile_No__c in :refContactPhone and project_name__c In :Project];
        system.debug('___existingLead___'+existingLead.size());
        for(Lead led : existingLead){
            if(mobileProjectReferalsMap.containsKey(led.project_name__c+'-'+led.RW_Mobile_No__c)){
                existingref.add(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id);
                
                if( existingLeadRefmap.containsKey(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id)){
                    system.debug('___mobileProjectReferalsMap___'+mobileProjectReferalsMap);
                    
                    List<Lead> ledList = existingLeadRefmap.get(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id);
                    system.debug('___ledList___'+ledList);
                    if(!ledList.isEmpty() ){
                        system.debug('___led___'+led);
                        ledList.add(led);
                    }
                    system.debug('___If___ledList___'+ledList);
                    system.debug('existingLeadRefmap____'+existingLeadRefmap);
                    
                    setOfProjectNames.add(led.project_name__c);
                    if(!ledList.isEmpty())
                        existingLeadRefmap.put(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id,ledList);
                        existingLeadReferalmap.put(led.project_name__c, ledList);
                    
                }else{
                    system.debug('___in Duplicate else___'+led.Name);
                    setOfProjectNames.add(led.project_name__c);
                    existingLeadRefmap.put(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id,new list<Lead>{led});
                    existingLeadReferalmap.put(led.project_name__c, new list<Lead>{led});
                    
                }
            }
        }
        for(RW_Referral__c eachRef: refList){
            if(!existingref.contains(eachRef.id)){
                if( newLeadProject.containsKey(eachRef.RW_Project__c)){
                    List<RW_Referral__c> rf =  newLeadProject.get(eachRef.RW_Project__c);
                    rf.add(eachRef);
                    newLeadProject.put(eachRef.RW_Project__c,rf);
                    
                }else{
                    List<RW_Referral__c> rf =  new List<RW_Referral__c> ();
                    rf.add(eachRef);
                    newLeadProject.put(eachRef.RW_Project__c,rf);
                    
                }
            }
        }
        
        system.debug(newLeadProject);
        
        List<Project__c> prjList = [select Id,Name,CRMHead__c,CRMHead__r.Email,Presales_TL__c,Presales_TL__r.Username from Project__c where Name IN: Project ];        
        system.debug('#### prjList '+prjList);
        
        for(Project__c prj : prjList){
            mapOfPrj.put(prj.Name,prj); 
            mapOfPrjId.put(prj.id,prj);
            //system.debug('#### mapOfPrj '+mapOfPrj);
        }
        Set<string> setOfleads = new set<string>();
        for(string pjref: newLeadProject.keyset()){
            for(RW_Referral__c eachRef : newLeadProject.get(pjref)){
                system.debug('eachRef____ '+eachRef);
                Lead lead = new Lead();
                lead.RW_Referral_Lead__c = eachRef.Id;
                lead.Email = eachRef.RW_Email_Address__c;
                lead.RW_Mobile_No__c = eachRef.RW_Contact_Phone__c;
                lead.LastName = eachRef.RW_Last_Name__c;
                lead.FirstName = eachRef.RW_First_Name__c;
                lead.Customer_Reference__c = eachRef.Account__c;
                // lead.RW_Project__c = eachRef.Project_Unit__c;
                if(eachRef.RW_Project__c!=null){
                    lead.RW_Project__c =  mapOfPrj.get(eachRef.RW_Project__c).id;
                    If(mapOfPrj.get(eachRef.RW_Project__c).CRMHead__c != null){
                        lead.OwnerId = mapOfPrj.get(eachRef.RW_Project__c).CRMHead__c;
                    }
                }
                lead.LeadSource = 'Referral';
                lead.RW_Lead_Sub_Source__c = 'Existing client reference'; 
                setOfleads.add(eachRef.RW_Contact_Phone__c);
                leadsList.add(lead);
                //eachRef.RW_LeadCreated__c = true;
            }
        }
        System.debug('leadsList____' + leadsList.size()); 
        Set<String> uniqumobile = new Set<String>();
        List<Lead> uniqueLedListWithMbl = [select Id,Name,RW_Mobile_No__c from Lead where RW_Mobile_No__c IN: setOfleads];
        for(Lead lea: uniqueLedListWithMbl){
            uniqumobile.add(lea.RW_Mobile_No__c);
        }
        integer i = 0;
        while(i<leadsList.size()){
            if(uniqumobile.contains(leadsList[i].RW_Mobile_No__c)){
                leadsList.remove(i);
            }else{
                i++;
            }
        }
        System.debug('leadsList____after While____' + leadsList.size()); 
    }        
    
    public void finish(Database.BatchableContext bc){
        System.debug('mapOfPrj.keySet()____' +mapOfPrj.keySet());
        Set<RW_Referral__c> duplicateReferlList = new Set<RW_Referral__c>();
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage>(); 
        //Reffered lead duplicate foundss
        string url = System.Label.RW_Production_Url;
        If(existingLeadRefmap.size() > 0){
        system.debug('existingLeadReferalmap.keySet()____'+existingLeadReferalmap.keySet());
        for(string projectname : existingLeadReferalmap.keySet()){
            system.debug('projectname In Exisiting____'+projectname);
        string dupbody = 'Dear Team, <br/><br/>';
        dupbody += 'Exisiting lead has been referred by the user, please followup<br/><br/><br/>';        
        dupbody +='<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>Account Details</th><th>Refferal Details</th><th>Existing Lead Details</th></tr>';
        for(RW_Referral__c rf : mobileProjectReferalsMap.values() ){
            system.debug('rf______'+rf);
            if(existingLeadRefmap.containsKey(rf.Id)){
               system.debug('rf____In IF____'+rf); 
                rf.RW_Status__c = 'Processed';
                rf.RW_Duplicate_Lead__c = True;
                duplicateReferlList.add(rf);
                if(projectname == rf.RW_Project__c){
                    system.debug('rf____Lead___ProjectMatch____'+rf);
                    for(Lead led : existingLeadRefmap.get(rf.Id)){
                        system.debug('__existingLeadRefmap__'+ led.Name);
                        dupbody +=   '<tr><td> ' + rf.Account__r.Name + ' -  ' + rf.Project_Unit__r.Name + ' <a href="'+url+rf.Account__r.Id + ' ">View</a></td> <td> ' + rf.RW_First_Name__c +' '+ rf.RW_Last_Name__c +  '  -  ' + rf.RW_Project__c + ' <a href="'+url+rf.Id + '">View</a></td> <td>' + led.FirstName +' '+ led.LastName + '  -  ' + led.Project_Name__c + ' <a href="'+url+led.Id+'"> View </a></td></tr>';
                        
                    }
                }
            }
        }
        
        dupbody += '</table></body> <br/><br/></html>';
        dupbody += 'Thanks,<br/>';
        dupbody += ' Runwal Cares.';
        List<string> toAddrExisitingLeads = new List<string>();
        Messaging.SingleEmailMessage mailExisitingLeads = new Messaging.SingleEmailMessage(); 
      
            if(String.isNotBlank(mapOfPrj.get(projectName).CRMHead__r.Email)){
                system.debug('Exisiting mapOfPrj.get(projectName).CRMHead__r.Email____'+mapOfPrj.get(projectName).CRMHead__r.Email);
                toAddrExisitingLeads.add(mapOfPrj.get(projectName).CRMHead__r.Email);
                
            }
            if(String.isNotBlank(mapOfPrj.get(projectName).Presales_TL__r.Username)){
                toAddrExisitingLeads.add(mapOfPrj.get(projectName).Presales_TL__r.Username);
           }
      
        mailExisitingLeads.subject ='Existing Leads Reffered by Customer for Project '+ ' - ' + projectname ;
        system.debug('toAddrExisitingLeads____Existing Leads ' +toAddrExisitingLeads);
        mailExisitingLeads.setToAddresses(toAddrExisitingLeads);
        mailExisitingLeads.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        mailExisitingLeads.sethtmlbody(dupbody);
        messages.add(mailExisitingLeads);
        }
        
        
        //duplicateReferlList update duplicate check
        if(duplicateReferlList.size() > 0){
            system.debug('duplicateReferlList___'+duplicateReferlList.size() );
            update new List<RW_Referral__c>(duplicateReferlList);
        }
        }
        //Reffered lead success created 
        System.debug('leadsList in Finish_____ ' + leadsList.size());
        List<Id> leadList = new List<Id>();
        //insert   leadsList;
        Database.SaveResult[] srList = Database.insert(leadsList, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                
                System.debug('Successfully inserted. lead ID: ' + sr.getId());
                leadList.add(sr.getId());
            }
        }
        map<string,List<lead>> mapProjectLead= new map<string,List<lead>>();
        for(lead led : [Select Id,Name,FirstName,LastName,RW_Referral_Lead__r.Name,RW_Referral_Lead__c,Lead.RW_Project__r.Name,
                        RW_Referral_Lead__r.RW_First_Name__c,RW_Referral_Lead__r.RW_Last_Name__c,RW_Project__c,
                        RW_Referral_Lead__r.RW_Project__c,RW_Referral_Lead__r.Project_Unit__r.Name,RW_Referral_Lead__r.Account__r.Name
                        From Lead Where Id IN: leadList]){
                            system.debug('led____200__'+led);
                            system.debug('mapOfPrjId.get(led.RW_Project__c)_____ '+ mapOfPrjId.get(led.RW_Project__c).Name);
                            
                            if(mapProjectLead.containskey(mapOfPrjId.get(led.RW_Project__c).Name)){
                                system.debug('____'+mapProjectLead.containskey(mapOfPrjId.get(led.RW_Project__c).Name));
                                List<lead> leds = mapProjectLead.get(mapOfPrjId.get(led.RW_Project__c).Name);
                                leds.add(led);
                                mapProjectLead.put(mapOfPrjId.get(led.RW_Project__c).Name,leds);
                            }else{
                                mapProjectLead.put(mapOfPrjId.get(led.RW_Project__c).Name,new list<lead>{led});
                                
                            }
                        }
        system.debug('mapProjectLead.keySet()____'+mapProjectLead.keySet());
        for(string projectname : mapProjectLead.keySet()){
            system.debug('projectname____'+projectname);
            string newBody = 'Dear Team, <br/><br/>';
            
            newBody += 'New leads has been referred by the user, please followup<br/><br/><br/>';        
            newBody +='<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>Account Details</th><th>Refferal Details</th><th>New Lead Details</th></tr>';
            for(Lead led : mapProjectLead.get(projectname) ){
                system.debug('led____'+led);
                newBody +=   '<tr><td> ' + led.RW_Referral_Lead__r.Account__r.Name + '  -  ' + led.RW_Referral_Lead__r.Project_Unit__r.Name + ' <a href="'+url+led.RW_Referral_Lead__r.Account__r.Id + ' ">View</a></td> <td> ' + led.RW_Referral_Lead__r.RW_First_Name__c +' '+ led.RW_Referral_Lead__r.RW_Last_Name__c +  '  -  ' + led.RW_Referral_Lead__r.RW_Project__c + ' <a href="'+url+led.RW_Referral_Lead__c + ' ">View</a></td> <td> ' + led.FirstName + ' ' + led.LastName +  '  -  '  + led.RW_Project__r.Name + ' <a href="'+url+led.Id + ' "> View </a></td></tr>';
            }
            newBody += '</table></body> <br/><br/></html>';
            newBody += 'Thanks,<br/>';
            newBody += ' Runwal Cares.';
            
            List<string> toAddrNewLeads = new List<string>();
            Messaging.SingleEmailMessage mailNewLeads = new Messaging.SingleEmailMessage(); 
            
            if(String.isNotBlank(mapOfPrj.get(projectName).CRMHead__r.Email)){
                system.debug('New mapOfPrj.get(projectName).CRMHead__r.Email_______'+mapOfPrj.get(projectName).CRMHead__r.Email);
                 toAddrNewLeads.add(mapOfPrj.get(projectName).CRMHead__r.Email);
             }
            if(String.isNotBlank(mapOfPrj.get(projectName).Presales_TL__r.Username)){
                toAddrNewLeads.add(mapOfPrj.get(projectName).Presales_TL__r.Username);
                
            }
            mailNewLeads.subject ='New Leads Reffered by Customer for Project '+ ' - ' + projectname ;
            system.debug('toAddrNewLeads____New Leads ' +toAddrNewLeads);
            mailNewLeads.setToAddresses(toAddrNewLeads);
            mailNewLeads.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            mailNewLeads.sethtmlbody(newBody);
            messages.add(mailNewLeads);
            
        }
        
        //system.debug('messages @@@ ' + messages);
       if(messages.size()> 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('Messaging ' + results[0]);
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        
    }
}