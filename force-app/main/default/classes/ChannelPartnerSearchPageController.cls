public class ChannelPartnerSearchPageController {
    public Broker__c NewCP {
        get;
        set;
    }
    public string strError {
        get;
        set;
    }
    public list < Broker__c > lstCP {
        get;
        set;
    }
    public Boolean isCpExist {
        get;
        set;
    }
    
    public Boolean isNew {
        get;
        set;
    }
    public Boolean isUpdate{
        get;
        set;
    }
    
    public ChannelPartnerSearchPageController() {              
        NewCP = new Broker__c();        
        strError = '';
        isCpExist = false;
        isUpdate = false;
        isNew = true;
        lstCP = new list < Broker__c > ();
        //List < Broker__c > lstCP = [select Id,Name, RW_Mobile_No__c, Broker_Pan_No__c from Broker__c ];  //Where condition?
        // System.debug('lstCP ::' + lstCP);    
    }
    //on cancel button
    public PageReference goBack() {
        Pagereference objReference = new Pagereference('/');
        objReference.setRedirect(true);
        return objReference;
    }
    //on Create New Button
    public PageReference createNew() {
        PageReference objReference = new PageReference('/apex/CreateNewChannelPartner');
        return objReference;
    }  
    public void Save(){        
        try {
            List < Broker__c >lstCP = [select id, Name,OwnerId,Broker_Pan_No__c,Unregistered_Channel_Partner__c,RW_Email__c,RW_IRIS_Sync__c from Broker__c where Broker_Pan_No__c =: NewCP.Broker_Pan_No__c];      
            System.debug('lstCP1 ::' + lstCP);    
            if(!lstCP.isEmpty()){
                if (lstCP[0].Unregistered_Channel_Partner__c == false) {
                    lstCP[0].Unregistered_Channel_Partner__c = true;        
                }
            }
            System.debug('lstCP2 ::' + lstCP);    
            update lstCP;            
        } 
        
        catch (exception ex) {
            system.debug('Exception : ' +ex);
           // Apexpages.addMessage(new Apexpages.message(ApexPages.Severity.ERROR,'You Cannot edit this checkbox as Related Lead/Opportunity/Prospect is present..!!'));
        }        
    }
    public void searchAllChannelPartner() { 
        try{
            lstCP = new list < Broker__c > ();
            strError = '';
            isCpExist = false;           
            if (NewCP.Broker_Pan_No__c == null || NewCP.Broker_Pan_No__c == '' ) {
                strError = 'Please enter PAN number to proceed.';
                return;               
            }
            if(NewCP.Broker_Pan_No__c != null && (NewCP.Broker_Pan_No__c).length() != 10){
                strError = 'Please enter valid PAN number to proceed.';
                return;
            }
            isNew = false;
            lstCP = [select id, Name,OwnerId,Broker_Pan_No__c,Unregistered_Channel_Partner__c,RW_Email__c,RW_IRIS_Sync__c,SAP_CP_Code__c from Broker__c where Broker_Pan_No__c =: NewCP.Broker_Pan_No__c];      
            
            System.debug('lstCP ::' + lstCP);            
            if (!lstCP.isEmpty() && lstCP.size() > 0) {
                isCpExist = true;
                
            } else {
                isCpExist = false;
                strError = 'Channel partner not available with below PAN number Please click on new button to create the same.';
            }                        
        }
        Catch(Exception ex){
            system.debug('Exception Occured..' +ex);
        }        
    }           
}