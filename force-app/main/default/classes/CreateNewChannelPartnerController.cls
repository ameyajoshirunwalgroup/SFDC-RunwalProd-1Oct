public class CreateNewChannelPartnerController {
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
    public CreateNewChannelPartnerController() {    
        NewCP = new Broker__c();   
    }
    //on cancel button
    public PageReference goBack() {
        PageReference objReference = new PageReference('/apex/ChannelPartnerSearchPage');
        return objReference;
    }
    public PageReference saveMethod() {
        strError = '';
        Savepoint sp = Database.setSavepoint();
        try {
            if (NewCP.Broker_Pan_No__c == null || NewCP.Broker_Pan_No__c == '') {
                strError = 'Please enter channel partner PAN number to Proceed.';
                return null;
            }
            if(NewCP.Broker_Pan_No__c != null && (NewCP.Broker_Pan_No__c).length() != 10){
                strError = 'Please enter valid PAN to proceed.';
                return null;
            }

            lstCP = [select id, Name,OwnerId,Broker_Pan_No__c,Unregistered_Channel_Partner__c,RW_Email__c,RW_IRIS_Sync__c from Broker__c where Broker_Pan_No__c =: NewCP.Broker_Pan_No__c];      
            System.debug('lstCP ::' + lstCP); 
            if (!lstCP.isEmpty() && lstCP.size() > 0) {
                strError = 'Channel partner with this PAN is already available in the system.';
                return null;             
            }
            if (NewCP.Name == null || NewCP.Name == '') {
                strError = 'Please enter channel partner name to proceed.';
                return null;
            }         
            if (NewCP.Dialing_Country1__c == null || NewCP.Dialing_Country1__c == '') {
                strError = 'Please select country to proceed.';
                return null;
            }
            if (NewCP.Dialing_Country_Code1__c == null || NewCP.Dialing_Country_Code1__c == '') {
                strError = 'Please select country code to proceed.';
                return null;
            }
            if (NewCP.RW_Mobile_No__c == null || NewCP.RW_Mobile_No__c == '') {
                strError = 'Please enter mobile number to proceed.';
                return null;
            }
            if (NewCP.RW_Mobile_No__c != Null && (NewCP.RW_Mobile_No__c).length() != 10) {
                strError = 'Please enter valid mobile number to proceed.';
                return null;
            }
            if (NewCP.RW_Email__c == null || NewCP.RW_Email__c == '') {
                strError = 'Please enter email to proceed.';
                return null;
            }
            NewCP.Unregistered_Channel_Partner__c = true;  
            
            Insert NewCP;
            PageReference objReference = new PageReference('/'+NewCP.Id);
            objReference.setRedirect(true);
            return objReference;
            
        } 
        
        catch (exception ex) {
            Database.rollback(sp);
            string strTempError = '';            
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();
            return null;
                        
        }
    } 
    
}