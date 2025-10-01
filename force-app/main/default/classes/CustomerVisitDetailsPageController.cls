public class CustomerVisitDetailsPageController {
    
    public String name {get;set;}
    public String project {get;set;}
    public String tower {get;set;}
    public String unit {get;set;}
    public String mobile {get;set;}
    public String email {get;set;}
    public String interestedIn {get;set;}
    public Boolean showSuccessMsg {get;set;}
    public List<SelectOption> projList {get;set;} 
    public List<SelectOption> interestedList {get;set;}
    
    public CustomerVisitDetailsPageController(){
        projList = new List<SelectOption>();
        List<Schema.Picklistentry> projResult = Customer_Visit_Details__c.Project__c.getDescribe().getPicklistValues();
        projList.add(new SelectOption('', '-- select -- '));
        for(Schema.PicklistEntry f : projResult) {
            projList.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        
        interestedList = new List<SelectOption>();
        List<Schema.Picklistentry> interestedResult = Customer_Visit_Details__c.Interested_In__c.getDescribe().getPicklistValues();
        interestedList.add(new SelectOption('', '-- select -- '));
        for(Schema.PicklistEntry f : interestedResult) {
            interestedList.add(new SelectOption(f.getValue(), f.getLabel()));
        }
        
        System.debug('projList: ' + projList);
    }
    
    public pageReference saveDetails(){
        System.debug('project: ' + project);
        Boolean hasError = false;
        if(mobile.length() != 10){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Mobile number should be 10 digits.');
            ApexPages.addMessage(myMsg);
            hasError = true;
        }
        
        if(email != null){
            Map<String, Dummy_Emails__c> dummys = Dummy_Emails__c.getAll();
            System.debug('dummyEmails: ' + dummys.keySet());
            for(String str : dummys.keySet()){
                if(email.contains(str) || str.contains(email)){
                    System.debug('Dummy Email1');
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'It seems you are using Dummy email. Please update correct Email id.');
                    ApexPages.addMessage(myMsg);
                    hasError = true;
                }
            }
        }
        if(hasError == false){
            Customer_Visit_Details__c cvd = new Customer_Visit_Details__c();
            cvd.Name__c = name;
            cvd.Project__c = project;
            cvd.Tower_Name__c = tower;
            cvd.Unit_Number__c = unit;
            cvd.Mobile__c = mobile;
            cvd.Email__c = email;
            cvd.Interested_In__c = interestedIn;
            insert cvd;
            showSuccessMsg = true;
        }
        
        //PageReference cvdPage = new Pagereference('/' + cvd.id);
        //cvdPage.setRedirect(true);
        return null;
    }
    
}