public class ProspectAccessController {
    public List < SelectOption > lstProjectList {
        get;
        set;
    }
    public Lead NewLead {
        get;
        set;
    }
    public Boolean show{
        get; 
        set;
    }
    public string strProjectId {
        get;
        set;
    }
    public string strError {
        get;
        set;
    }
    public list < Lead > lstDuplicateLeads {
        get;
        set;
    }
    public list <Prospect__c> lstDuplicateProspects {
        get;
        set;
    }
    public List<Prospect__c> sameProjectProspects{get;set;}
    Public List<Prospect__c> diffProjectProspects{get;set;}
   
    public Boolean isDuplicateLeadExist {
        get;
        set;
    }
    
    public Boolean isSameProspectExist {                            //for Same project Prospects
        get;
        set;
    }
    public Boolean isDiffProspectExist {                            //for Different project Prospects
        get;
        set;
    }
    
    public Boolean isNew {
        get;
        set;
    }
    public boolean dupflag {
        get;
        set;
    }
    public boolean checkbox{
        get;
        set;
    }
    List < opportunity > lstOpp;

    public ProspectAccessController() {
        show = true;
        NewLead = new Lead();
        lstProjectList = new List < SelectOption > (); 
        strError = '';
        isDuplicateLeadExist = false;
        isDiffProspectExist = false;
        isSameProspectExist =false;
        isNew = true;
        checkbox = false;
        dupflag = false;

        List < Project__c > lstProj = [select Id, name, RW_Status__c from Project__c where RW_Status__c =: 'Active']; //
        System.debug('lstProj ::' + lstProj);
        lstProjectList.add(new SelectOption('', '---Please Select Project---'));
        if (lstProj != null && lstProj.size() > 0) {
            for (Project__c EachProj: lstProj) {
                lstProjectList.add(new SelectOption(EachProj.id, EachProj.name));
            }
        }
    }

    //on cancel button
    public PageReference goBack() {
        Pagereference objReference = new Pagereference('/');
        objReference.setRedirect(true);
        return objReference;
    }

    //on share button
    public PageReference  saveMethod(){
                    List<Prospect__Share> listProspect =new List<Prospect__Share>();
        			List<id> RecordIds = new List<id>();
        			list<UserRecordAccess> userAccess = new list<UserRecordAccess>();
                    List <LeadShare> listlead = new List <LeadShare> (); 
                    if(sameProjectProspects.size() > 0)
                    {                    
                        Prospect__Share csShare = new Prospect__Share();
                        csShare.AccessLevel = 'edit';
                        csShare.RowCause= 'Manual';
                        csShare.parentId = sameProjectProspects[0].id;
                        csShare.UserOrGroupId = userinfo.getUserId();
                        RecordIds.add(sameProjectProspects[0].id);
                        listProspect.add(csShare);
                        
                    }else if(diffProjectProspects.size() > 0)
                    {
                        Prospect__Share csShare = new Prospect__Share();
                        csShare.AccessLevel = 'edit';
                        csShare.RowCause= 'Manual';
                        csShare.parentId = diffProjectProspects[0].id;
                        csShare.UserOrGroupId = userinfo.getUserId();
                        RecordIds.add(diffProjectProspects[0].id);
                        listProspect.add(csShare);
                    }else if(lstDuplicateLeads.size() > 0)
                    {                    
                        LeadShare csShare = new LeadShare();
                        csShare.LeadAccessLevel = 'edit';
                        csShare.RowCause= 'Manual';
                        csShare.LeadId = lstDuplicateLeads[0].id;
                        csShare.UserOrGroupId = userinfo.getUserId();
                        RecordIds.add(lstDuplicateLeads[0].id);
                        listlead.add(csShare);
                    }
        try{         
        if(RecordIds.size() > 0  && RecordIds != null)
        {
          userAccess=[SELECT RecordId FROM UserRecordAccess WHERE UserId=: UserInfo.getUserId() AND HasEditAccess = True AND RecordId IN: RecordIds ];
        }
        if(userAccess.size() > 0  && userAccess != null)
        {
            system.debug('Already has Access to Record');            
            strError = '"You have been granted access to records successfully!".';
            dupflag = true;          
        }else{
            
            if(listlead.size() > 0 && listlead != null){			
            system.debug(listlead);
            insert listlead;
            strError = '"You have been granted access to this lead successfully!".';
            dupflag = true;
        } 
            
        if(listProspect.size() > 0 && listProspect != null)
        {
            system.debug(listProspect);
            insert listProspect;
            strError = '"You have been granted access to this Prospect successfully!".';
            dupflag = true;                
        }
             
        }
        }
        catch (exception ex) {
              strError = '"There is a error while granting a access".'+ex.getMessage();            
      }
        return null;
    }
    
public Pagereference duplead(){
        Pagereference objReference = new Pagereference('/' + lstDuplicateLeads[0].id);
             objReference.setRedirect(true);
                return objReference;
        
}
public void searchAllLead() {
    sameProjectProspects = new List<Prospect__c>();
    diffProjectProspects = new List<Prospect__c>();
    lstDuplicateLeads = new list < Lead > ();
    lstDuplicateProspects = new list<Prospect__c>();
    strError = '';
    isDuplicateLeadExist = false;
    isDiffProspectExist = false;
    isSameProspectExist =false;

    
    if (NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '') {
        strError = 'Please enter the Contact No to proceed.';
        return;
    }

    isNew = false;

    string strMobileNumber = '%' + NewLead.RW_Mobile_No__c + '%';
    lstDuplicateProspects = [select id,name,Project__c,Project__r.name,User__r.name,Mobile_No__c,Secondary_Mobile_No__c from Prospect__c where (Mobile_No__c LIKE: strMobileNumber OR Secondary_Mobile_No__c LIKE: strMobileNumber)];       // AND Project__c =: strProjectId
    if(lstDuplicateProspects!= null && lstDuplicateProspects.size() > 0)
    {
        for(Prospect__c p : lstDuplicateProspects)
        {
            if(p.Project__c == strProjectId)
            {
                sameProjectProspects.add(p);                
            }
            else{
                diffProjectProspects.add(p);                
            }
        }
        if(sameProjectProspects.size() > 0)
        {
           isSameProspectExist = True; 
        }else if(diffProjectProspects.size() > 0){
           isDiffProspectExist = True; 
        } 
    }else{
    string strQry = 'select id, name, RW_project__r.Name, ';

    Map < String, Schema.SObjectType > GlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Lead');
    Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('RWLeadSearch');

    for (Schema.FieldSetMember fieldsSetMem: fieldSetObj.getFields()) {
        strQry += fieldsSetMem.getFieldPath().toLowercase() + ',';
    }
    strQry = strQry.removeEnd(',');
    strQry += ' from Lead where (RW_Mobile_No__c LIKE: strMobileNumber OR RW_Secondary_Mobile_No__c LIKE: strMobileNumber) and isConverted = false'; //and RW_Project__c =: strProjectId

    lstDuplicateLeads = database.query(strQry);

    if (lstDuplicateLeads != null && lstDuplicateLeads.size() > 0) {
        isDuplicateLeadExist = true;        
    } else {
        isDuplicateLeadExist = false;
        show = false;
    }
    }
}
            
}