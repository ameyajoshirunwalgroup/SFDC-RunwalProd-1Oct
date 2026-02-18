public class ProspectManagementServices {
    public static void updateSMonOpty(List<prospect__c> lstProspect) {
        List<Prospect__c> prospectList = new List<Prospect__c>();
        Map<Id,Prospect__c> prospectmap = new Map<Id,Prospect__c>();
        List<Opportunity> lstopty = new List<Opportunity>();
        List<opportunity> lstOptyToUodate = new List<opportunity>();
        prospectList = [Select id, Name, user__c,User__r.name,opportunity__c from Prospect__c where id IN :lstprospect];
        if(!prospectList.isEmpty()) {
            for(Prospect__c p : prospectList) {
                prospectmap.put(p.Opportunity__c,p);
            }
        }
        if(!prospectmap.isEmpty()) {
            lstopty = [Select id, name,RW_Sales_Associate__c,Sales_Manager_User__c from Opportunity where Id =:prospectmap.keySet()];  //Added Sales_Manager_User__c by Vinay 05-12-2025
        }
        if(!lstopty.isEmpty()) {
            for(Opportunity o : lstopty) {
                if(prospectmap.containsKey(o.Id)) {
                    if(prospectmap.get(o.Id).User__r.Name != null) {
                        //o.RW_Sales_Associate__c = prospectmap.get(o.Id).User__r.Name; //Commented by Vinay 05-112-2025
                        o.Sales_Manager_User__c = prospectmap.get(o.Id).User__c; //Added by Vinay 05-112-2025
                        lstOptyToUodate.add(o);
                    }
                }
            }
            if(!lstOptyToUodate.isEmpty())
                update lstOptyToUodate;
        }
    }
}