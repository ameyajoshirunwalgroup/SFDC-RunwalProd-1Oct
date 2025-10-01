trigger TrgSchemeConfig on Scheme_Configuration__c (before insert) {
    for(Scheme_Configuration__c sc : trigger.new)
    {
        if(sc.Project__c != null && sc.Tower__c == null){
            List<Scheme_Configuration__c> sconfig = new List<Scheme_Configuration__c>();
            System.debug('Project::'+sc.Project__c);
            System.debug('sc::'+sc);
            sconfig = [Select id,name,Project__c,Tower__c,Project__r.Name from Scheme_Configuration__c where Project__c=:sc.Project__c And Tower__c = null and Active__c = true and 
                       Type__c =: sc.Type__c];
            System.debug('sconfig::'+sconfig);
            
            if(!sconfig.isEmpty()){
                sc.addError('Scheme Already Exist for this Project '+sconfig[0].Project__r.Name+'');
            }
        }
        if(sc.Project__c != null && sc.Tower__c != null){
            List<Scheme_Configuration__c> sconfig = new List<Scheme_Configuration__c>();
            sconfig = [Select id,name,Project__c,Tower__c,Tower__r.Name,Project__r.Name from Scheme_Configuration__c where Project__c=:sc.Project__c And Tower__c=:sc.Tower__c and 
                       Active__c = true and Type__c =: sc.Type__c];
            System.debug('sconfig::'+sconfig);
            if(!sconfig.isEmpty()){
                sc.addError('Scheme Already Exist for Tower '+sconfig[0].Tower__r.Name+' and Project '+sconfig[0].Project__r.Name	+'');
            }
        }
        
    }
}