public class ProspectCreationController {
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
   
    public Boolean isDuplicateLeadExist {
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

    public  ProspectCreationController() {
        show = true;
        NewLead = new Lead();
        lstProjectList = new List < SelectOption > ();
        strError = '';
        isDuplicateLeadExist = false;
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
                    List <LeadShare> listlead = new List <LeadShare> ();  
                    LeadShare csShare = new LeadShare();
                    csShare.LeadAccessLevel = 'edit';
                    csshare.RowCause= 'Manual';
                    csShare.LeadId = lstDuplicateLeads[0].id;
                    csShare.UserOrGroupId = userinfo.getUserId();
                    listlead.add(csShare);
        try{            
        if(listlead.size() > 0 && listlead != null){
            
            system.debug(listlead);
            insert listlead;
            strError = '"You have been granted access to this lead successfully!".';
            dupflag = true;
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
   
    lstDuplicateLeads = new list < Lead > ();
    strError = '';
    isDuplicateLeadExist = false;

    
    if (NewLead.RW_Mobile_No__c == null || NewLead.RW_Mobile_No__c == '') {
        strError = 'Please enter the Contact No to proceed.';
        return;
    }

    isNew = false;

    string strMobileNumber = '%' + NewLead.RW_Mobile_No__c + '%';

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