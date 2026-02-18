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
        string query = 'Select Id, Name, Account__c, RW_Last_Name__c, RW_First_Name__c, RW_Email_Address__c, RW_Contact_Phone__c, RW_How_do_you_know_this_person__c, RW_Project__c, RW_Status__c, RW_Mode__c, RW_LeadCreated__c , RW_Referral_Id__c,RW_Duplicate_Lead__c,Project_Unit__c,Account__r.Name,Account__r.Id,Project_Unit__r.Name, Opt_for_Referral__c From RW_Referral__c where RW_Referral_Processed__c = false';
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<RW_Referral__c> refList){
        list<id>  existingref =new list<id>();
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
        for(Lead led : existingLead){
            if(mobileProjectReferalsMap.containsKey(led.project_name__c+'-'+led.RW_Mobile_No__c)){
                existingref.add(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id);
                
                if( existingLeadRefmap.containsKey(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id)){
                    
                    List<Lead> ledList = existingLeadRefmap.get(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id);
                    if(!ledList.isEmpty() ){
                        ledList.add(led);
                    }
                    
                    setOfProjectNames.add(led.project_name__c);
                    if(!ledList.isEmpty())
                        existingLeadRefmap.put(mobileProjectReferalsMap.get(led.project_name__c+'-'+led.RW_Mobile_No__c).id,ledList);
                        existingLeadReferalmap.put(led.project_name__c, ledList);
                    
                }else{
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
        
        
        List<Project__c> prjList = [select Id,Name,CRMHead__c,CRMHead__r.Email,Presales_TL__c,Presales_TL__r.Username from Project__c where Name IN: Project ];        
        
        for(Project__c prj : prjList){
            mapOfPrj.put(prj.Name,prj); 
            mapOfPrjId.put(prj.id,prj);
            //system.debug('#### mapOfPrj '+mapOfPrj);
        }
        Set<string> setOfleads = new set<string>();
        for(string pjref: newLeadProject.keyset()){
            for(RW_Referral__c eachRef : newLeadProject.get(pjref)){
                Lead lead = new Lead();
                lead.RW_Referral_Lead__c = eachRef.Id;
                lead.Email = eachRef.RW_Email_Address__c;
                lead.RW_Mobile_No__c = eachRef.RW_Contact_Phone__c;
                lead.LastName = eachRef.RW_Last_Name__c;
                lead.FirstName = eachRef.RW_First_Name__c;
                lead.Customer_Reference__c = eachRef.Account__c;
                // lead.RW_Project__c = eachRef.Project_Unit__c;
                // Mapping opt for referral field from referral lead to lead - Digicloud
                system.debug('in LeadCreation Batch eachRef.Opt_for_Referral__c__'+ eachRef.Opt_for_Referral__c);
                lead.Opt_for_Referral__c = eachRef.Opt_for_Referral__c; 
                system.debug('in LeadCreation Batch eachRef.Opt_for_Referral__c__2'+ lead.Opt_for_Referral__c); 
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
    }        
    
    public void finish(Database.BatchableContext bc){
        Set<RW_Referral__c> duplicateReferlList = new Set<RW_Referral__c>();
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage>(); 
        //Reffered lead duplicate foundss
        string url = System.Label.RW_Production_Url;
        If(existingLeadRefmap.size() > 0){
        for(string projectname : existingLeadReferalmap.keySet()){
        string dupbody = 'Dear Team, <br/><br/>';
        dupbody += 'Exisiting lead has been referred by the user, please followup<br/><br/><br/>';        
        dupbody +='<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>Account Details</th><th>Refferal Details</th><th>Existing Lead Details</th></tr>';
        for(RW_Referral__c rf : mobileProjectReferalsMap.values() ){
            if(existingLeadRefmap.containsKey(rf.Id)){
                rf.RW_Status__c = 'Processed';
                rf.RW_Duplicate_Lead__c = True;
                duplicateReferlList.add(rf);
                if(projectname == rf.RW_Project__c){
                    for(Lead led : existingLeadRefmap.get(rf.Id)){
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
                toAddrExisitingLeads.add(mapOfPrj.get(projectName).CRMHead__r.Email);
                
            }
            if(String.isNotBlank(mapOfPrj.get(projectName).Presales_TL__r.Username)){
                toAddrExisitingLeads.add(mapOfPrj.get(projectName).Presales_TL__r.Username);
           }
      
        mailExisitingLeads.subject ='Existing Leads Reffered by Customer for Project '+ ' - ' + projectname ;
        mailExisitingLeads.setToAddresses(toAddrExisitingLeads);
        mailExisitingLeads.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        mailExisitingLeads.sethtmlbody(dupbody);
        messages.add(mailExisitingLeads);
        }
        
        
        //duplicateReferlList update duplicate check
        if(duplicateReferlList.size() > 0){
            update new List<RW_Referral__c>(duplicateReferlList);
        }
        }
        //Reffered lead success created 
        List<Id> leadList = new List<Id>();
        //insert   leadsList;
        Database.SaveResult[] srList = Database.insert(leadsList, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                
                leadList.add(sr.getId());
            }
        }
        map<string,List<lead>> mapProjectLead= new map<string,List<lead>>();
        for(lead led : [Select Id,Name,FirstName,LastName,RW_Referral_Lead__r.Name,RW_Referral_Lead__c,Lead.RW_Project__r.Name,
                        RW_Referral_Lead__r.RW_First_Name__c,RW_Referral_Lead__r.RW_Last_Name__c,RW_Project__c,
                        RW_Referral_Lead__r.RW_Project__c,RW_Referral_Lead__r.Project_Unit__r.Name,RW_Referral_Lead__r.Account__r.Name
                        From Lead Where Id IN: leadList]){
                            
                            if(mapProjectLead.containskey(mapOfPrjId.get(led.RW_Project__c).Name)){
                                List<lead> leds = mapProjectLead.get(mapOfPrjId.get(led.RW_Project__c).Name);
                                leds.add(led);
                                mapProjectLead.put(mapOfPrjId.get(led.RW_Project__c).Name,leds);
                            }else{
                                mapProjectLead.put(mapOfPrjId.get(led.RW_Project__c).Name,new list<lead>{led});
                                
                            }
                        }
        for(string projectname : mapProjectLead.keySet()){
            string newBody = 'Dear Team, <br/><br/>';
            
            newBody += 'New leads has been referred by the user, please followup<br/><br/><br/>';        
            newBody +='<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>Account Details</th><th>Refferal Details</th><th>New Lead Details</th></tr>';
            for(Lead led : mapProjectLead.get(projectname) ){
                newBody +=   '<tr><td> ' + led.RW_Referral_Lead__r.Account__r.Name + '  -  ' + led.RW_Referral_Lead__r.Project_Unit__r.Name + ' <a href="'+url+led.RW_Referral_Lead__r.Account__r.Id + ' ">View</a></td> <td> ' + led.RW_Referral_Lead__r.RW_First_Name__c +' '+ led.RW_Referral_Lead__r.RW_Last_Name__c +  '  -  ' + led.RW_Referral_Lead__r.RW_Project__c + ' <a href="'+url+led.RW_Referral_Lead__c + ' ">View</a></td> <td> ' + led.FirstName + ' ' + led.LastName +  '  -  '  + led.RW_Project__r.Name + ' <a href="'+url+led.Id + ' "> View </a></td></tr>';
            }
            newBody += '</table></body> <br/><br/></html>';
            newBody += 'Thanks,<br/>';
            newBody += ' Runwal Cares.';
            
            List<string> toAddrNewLeads = new List<string>();
            Messaging.SingleEmailMessage mailNewLeads = new Messaging.SingleEmailMessage(); 
            
            if(String.isNotBlank(mapOfPrj.get(projectName).CRMHead__r.Email)){
                 toAddrNewLeads.add(mapOfPrj.get(projectName).CRMHead__r.Email);
             }
            if(String.isNotBlank(mapOfPrj.get(projectName).Presales_TL__r.Username)){
                toAddrNewLeads.add(mapOfPrj.get(projectName).Presales_TL__r.Username);
                
            }
            mailNewLeads.subject ='New Leads Reffered by Customer for Project '+ ' - ' + projectname ;
            mailNewLeads.setToAddresses(toAddrNewLeads);
            mailNewLeads.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            mailNewLeads.sethtmlbody(newBody);
            messages.add(mailNewLeads);
            
        }
        
        //system.debug('messages @@@ ' + messages);
       if(messages.size()> 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success){
                System.debug('The email was sent successfully.');
            } else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
        
    }
}