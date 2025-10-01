public class ReferedLeadCreationExtension implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    public List<Id> leadIds= new List<Id>();
    public ReferedLeadCreationExtension(List<Id> leadIds){
        this.leadIds = leadIds;
    }
	public Database.QueryLocator start(Database.BatchableContext bc) {
          
        
      string query = 'Select Id,Name,Project_Name__c,RW_Mobile_No__c,RW_Project__r.RW_LocalityName__c, RW_Project__r.Site_Address_Map_Link__c, RW_Project__r.RW_Project_Brochure_PublicUrl__c, RW_Project__r.RW_Project_Location_Videos_Link__c FROM Lead where ID IN:leadIds';
      return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<lead> leadList){
        for(Lead lead: leadList){
            SendWhatsAppMsg.genaricMethodToSendWhatsAppMsgForBatch(lead.Name,lead.Project_Name__c, lead.RW_Project__r.RW_LocalityName__c, lead.RW_Project__r.Site_Address_Map_Link__c, lead.RW_Project__r.RW_Project_Brochure_PublicUrl__c, lead.RW_Project__r.RW_Project_Location_Videos_Link__c,System.Label.RW_SalesContact, lead.RW_Mobile_No__c,System.Label.Lead_Project_Content_HSM);	
        }
    } 
    
    public void finish(Database.BatchableContext bc){
        
    }
}