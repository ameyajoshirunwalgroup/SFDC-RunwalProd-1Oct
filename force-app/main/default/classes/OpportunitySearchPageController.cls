/* Requirement : Opportunity Search Functionality Issue I0141
 * Created by Sheetal on 14/4/2022
 */
public class OpportunitySearchPageController {
    public List < SelectOption > lstProjectList {
        get;
        set;
    }
    public Opportunity NewOpportunity {
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
    public list < Opportunity > lstOpty {
        get;
        set;
    }
    public Boolean isOptyExist {
        get;
        set;
    }
    
    public Boolean isNew {
        get;
        set;
    }
    
	public Boolean isNRI {
        get;
        set;
    }    
    public OpportunitySearchPageController () {				
        NewOpportunity = new Opportunity();
        lstProjectList = new List < SelectOption > ();
        strError = '';
        isOptyExist = false;
        isNew = true;
        isNRI = false;

        List < Project__c > lstProj = [select Id, name, RW_Status__c from Project__c where RW_Status__c =: 'Active']; 
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
    
    public void searchAllOpportunity() { 
        try{
            lstOpty = new list < Opportunity > ();
            strError = '';
            isOptyExist = false;
            
            if (strProjectId == null || strProjectId == '') {
                strError = 'Please select the Project to proceed.';
                return;
            }
            
            if (NewOpportunity.RW_Mobile_No__c == null || NewOpportunity.RW_Mobile_No__c == '') {
                strError = 'Please enter the Contact No to proceed.';
                return;
            }
            
            if (!isNRI && NewOpportunity.RW_Mobile_No__c.length() != 10) {
                strError = 'Please enter the mobile number of 10 digit.';
                return;
            }
            
            isNew = false;
            
            lstOpty = [select id, Name, RW_Project__r.Name, RW_Mobile_No__c, OwnerId, Walkin_Source__c,RW_Opportunity_Status__c, RW_Project__c,CreateDate__c
					   from Opportunity where RW_Mobile_No__c =: NewOpportunity.RW_Mobile_No__c  and  RW_Project__c =: strProjectId ];                      
            System.debug('lstOpty ::' + lstOpty);

            if (!lstOpty.isEmpty() && lstOpty.size() > 0) {
                isOptyExist = true;
                
            } else {
                isOptyExist = false;
            }
        }
        Catch(Exception ex){
            system.debug('Exception Occured..' +ex);
        }
    }
}