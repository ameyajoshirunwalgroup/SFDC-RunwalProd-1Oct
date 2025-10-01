public class SMAssignToProspect 
    {
    public list<Prospect__c> lstProspect;
    Public string pId{get;set;}
        Lead leadobj = new Lead();
    
    public SMAssignToProspect()
    {      
        if(ApexPages.currentPage().getParameters().containsKey('id') && string.isNotBlank(ApexPages.currentPage().getParameters().get('id'))){
            pId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if(string.isNotBlank(pId)){
            lstProspect = [select id,name,User__c,Opportunity__c,Project__c,Status__c,ownerId,
                                  SM_Assignment_DateTime__c ,SM_Assigned__c,Tower__c,Lead_Source__c from Prospect__c where id =: pId];
        }
        
    }
    
    public void assignSM(){
            
        if(!lstProspect.isEmpty()){
        
          if(!lstProspect[0].SM_Assigned__c){
              List <Team_Members__c> lstTeamMembers = new List <Team_Members__c>();
              if(lstProspect[0].Lead_Source__c == 'NRI'){
              if(lstProspect[0].Tower__c != null){
              
                lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'NRI Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Towerlookup__c    =: lstProspect[0].Tower__c];
                system.debug('lstTeamMembers::' + lstTeamMembers );
                }
                else {
                   lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'NRI Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Project__c =: lstProspect[0].Project__c];
                   system.debug('lstTeamMembersprj::' + lstTeamMembers );
                }
              }
              else if(lstProspect[0].Lead_Source__c == 'Referral'){
              if(lstProspect[0].Tower__c != null){
              
                lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Referral Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Towerlookup__c    =: lstProspect[0].Tower__c];
                system.debug('lstTeamMembers::' + lstTeamMembers );
                }
                else {
                   lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Referral Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Project__c =: lstProspect[0].Project__c];
                   system.debug('lstTeamMembersprj::' + lstTeamMembers );
                }
              }
              else if(lstProspect[0].Lead_Source__c == 'Loyalty'){
              if(lstProspect[0].Tower__c != null){
              
                lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Loyalty' AND User_Active__c = true AND IsActive__c = true AND Team__r.Towerlookup__c    =: lstProspect[0].Tower__c];
                system.debug('lstTeamMembers::' + lstTeamMembers );
                }
                else {
                   lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Loyalty' AND User_Active__c = true AND IsActive__c = true AND Team__r.Project__c =: lstProspect[0].Project__c];
                   system.debug('lstTeamMembersprj::' + lstTeamMembers );
                }
              }
              else{
               if(lstProspect[0].Tower__c != null){
              
                lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Prospect Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Towerlookup__c    =: lstProspect[0].Tower__c];
                system.debug('lstTeamMembers::' + lstTeamMembers );
                }
                else {
                   lstTeamMembers = [select id,User__c,User_Active__c,Counter__c,Team__c,Last_Assignment__c,name from Team_Members__c where Team__r.Team_Type__c= 'Prospect Team' AND User_Active__c = true AND IsActive__c = true AND Team__r.Project__c =: lstProspect[0].Project__c];
                   system.debug('lstTeamMembersprj::' + lstTeamMembers );
                }
              }
                list<Team_Members__c> lstTeamMembersToUpdate = new List<Team_Members__c >();
                system.debug('-------lstTeamMembers------'+lstTeamMembers); 
                
                if(lstTeamMembers != null && lstTeamMembers.size() >= 1)
                    {
                        datetime lsttime = system.now();
                        Id ownerId = lstProspect[0].ownerId;
                    for(Team_Members__c objTM : lstTeamMembers )
                    {
                        if(lsttime!= null && objTM.Last_Assignment__c == null) ////< lsttime
                        {
                            ownerId = objTM.user__c;
                            break;
                        }
                        else if(lsttime!= null && objTM.Last_Assignment__c < lsttime) ////
                        {
                                lsttime = objTM.Last_Assignment__c;
                                ownerId = objTM.user__c;
                        }
                        else{
                    
                            }
                    }    
                    
                for(Team_Members__c objTM : lstTeamMembers )
                {
                    if(objTM.user__c == ownerId)
                    {
                            objTM.Last_Assignment__c = system.now();
                            if(objTM.Counter__c != null)
                            objTM.Counter__c = objTM.Counter__c+1;
                            objTM.Ownerid = ownerId;
                            objTM.Last_Assignment__c = system.now();
                            lstTeamMembersToUpdate.add(objTM);
                    }
                }
                lstProspect[0].User__c = ownerId;
                lstProspect[0].SM_Assigned__c = true;
                lstProspect[0].SM_Assignment_DateTime__c = System.Now();
                if(lstTeamMembersToUpdate != null && lstTeamMembersToUpdate.size() > 0)
                update lstTeamMembersToUpdate;    
             
                update lstProspect;
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Confirm,'SM Assigned to prospect successfully.'));
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning,'There is no member in selecting Team.'));
            }
          }
           else{
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'There is already SM assgined to this prospect.'));
            }
        }
    }
    
    public PageReference BackToPage() 
    {       
        if(string.isNotBlank(pId))
        {
            pageReference P = new pageReference('/'+ pId);
            return P;
        }
        return null;
    }
    
    }