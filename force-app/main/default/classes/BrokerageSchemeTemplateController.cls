public class BrokerageSchemeTemplateController {
    public string SchemeId {
        get; 
        set{
            SchemeId = value;
            if(SchemeId != null)
                getSchemeList();
        }
    }
    
    Public List<Brokerage_Scheme__c> SchemeList {get;set;}
    Public List<Scheme_Configuration__c> SchemeProjectList {get;set;}
    public List<Brokerage_Slab__c>SlabList {get;set;}
    public string ReletedSchemeLink {get;set;}
    
    public void getSchemeList(){
        system.debug('SchemeId :' +SchemeId);
        if(SchemeId != Null){
            ReletedSchemeLink = Url.getSalesforceBaseUrl().toExternalForm()+'/'+SchemeId;   
            SchemeList = [Select id,name,Slab_Type__c,Start_Date__c,End_Date__c,Project_Location__r.name from Brokerage_Scheme__c where id =: SchemeId];
            system.debug('SchemeList : '+SchemeList);
            SchemeProjectList = [Select id,name,Project__r.name,Brokerage_Scheme__c from Scheme_Configuration__c Where Brokerage_Scheme__c =: SchemeId ];
            system.debug('SchemeProjectList :'+SchemeProjectList);
            SlabList = [Select id,name,Brokerage_Scheme__c,From__c,To__c,Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c =: SchemeId]; 
            system.debug('SlabList : '+SlabList);
            
        }
        
    }
    
}