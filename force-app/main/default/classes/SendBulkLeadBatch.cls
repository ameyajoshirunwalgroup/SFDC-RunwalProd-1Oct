global class SendBulkLeadBatch implements Database.Batchable <sObject>, Database.AllowsCallouts {
    global Set<Id> mailIds;
    //global String template;
    
    global SendBulkLeadBatch(Set<Id> sendMailIds) { //, string templateName
        mailIds = sendMailIds;
        //template = templateName;
    }
    global List < CampaignMember > start(Database.BatchableContext BC) {
        List < CampaignMember > cmList = new List < CampaignMember > ();
        cmList= [SELECT Id,Lead.id,Lead.Name,Contact.AccountId ,Contact.name, Email,FirstName ,LastName, Type FROM CampaignMember where Id in : mailIds];
        system.debug('cmList::'+CmList.size());
        return cmList;
    }

    global void execute(Database.BatchableContext BC, List < CampaignMember > scope) {
        set<Id> cmids = new Set<Id>();
        for(CampaignMember cm : scope) {
            System.debug('cm Id:' + cm);
            //MassSendEmailManagmentServices.sendMail(cm,template);
           cmids.add(cm.id);
        }
        //MassSendEmailManagmentServices.insertTask(cmids,template);
        //MassSendEmailManagmentServices.sendMail(cmids,template);
        ID jobID = System.enqueueJob(new SendBulkLeadFutureHandler(cmids));
    }

    global void finish(Database.BatchableContext BC) {}
}