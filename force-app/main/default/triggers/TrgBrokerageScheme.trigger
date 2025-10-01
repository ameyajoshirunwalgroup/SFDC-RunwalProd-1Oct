trigger TrgBrokerageScheme on Brokerage_Scheme__c (before insert,after insert,before update, after update) {
    /*if (trigger.isBefore && trigger.isInsert) {
        for (Brokerage_Scheme__c bs: trigger.new) {
            if(bs.Project__c != null && bs.Tower__c == null){
                List<Brokerage_Scheme__c> bros = new List<Brokerage_Scheme__c>();
                System.debug('Project::'+bs.Project__c);
                System.debug('bs::'+bs);
                bros = [Select id,name,Project__c,Tower__c,Active__c from Brokerage_Scheme__c where Project__c=:bs.Project__c And Tower__c = null And Active__c = true And Approval_Status__c = 'Approved by Level 2'];
                System.debug('bros::'+bros);
                if(!bros.isEmpty() && bs.Active__c == true){
                    bs.addError('Only one scheme should be Active in this Project');
                }
            }
            if(bs.Project__c != null && bs.Tower__c != null){
                List<Brokerage_Scheme__c> bros = new List<Brokerage_Scheme__c>();
                bros = [Select id,name,Project__c,Tower__c,Active__c from Brokerage_Scheme__c where Project__c=:bs.Project__c And Tower__c=:bs.Tower__c
                                            And Active__c = true And Approval_Status__c = 'Approved by Level 2'];
                System.debug('bros::'+bros);
                if(!bros.isEmpty() && bs.Active__c == true){
                    bs.addError('Only one scheme should be Active in this Tower');
                }
            }
        }
    }*/
    if(trigger.isAfter && trigger.isInsert){
        for (Brokerage_Scheme__c bs: trigger.new) {
            if(bs.Project_Location__c != null){
                List<Brokerage_Scheme__c> bros = new List<Brokerage_Scheme__c>();
                system.debug('new Project::'+trigger.newMap.get(bs.id).Project__c);
                bros = [Select id,name,Project_Location__r.Approver_L1__c,Project_Location__r.Approver_L2__c from Brokerage_Scheme__c where Id=:bs.id];
                system.debug('bros::'+bros);
                if(!bros.isEmpty()){
                    Brokerage_Scheme__c bks = new Brokerage_Scheme__c();
                    bks.Scheme_Approver_1__c = bros[0].Project_Location__r.Approver_L1__c;
                    bks.Scheme_Approver_2__c = bros[0].Project_Location__r.Approver_L2__c;
                    bks.Id = bs.Id;
                    update bks;
                }
            }
        }
    }
    // Added by Prashant to tag scheme with bookings in cases where the scheme is created after the booking or due to delayed scheme approval – 20-02-2025.
    if(Trigger.isAfter && Trigger.isUpdate){
        list<Id> schIdstoTagonBookings = new list<Id>();
        for (Brokerage_Scheme__c bs: trigger.new) {
            system.debug('Inisde trigge new');
            system.debug('Approval_Status__c'+ bs.Approval_Status__c);
            if((trigger.oldMap.get(bs.id).Approval_Status__c != trigger.newMap.get(bs.id).Approval_Status__c && trigger.newMap.get(bs.id).Approval_Status__c == 'Approved by Level 2') || (trigger.oldMap.get(bs.id).Legacy_booking_treated__c != trigger.newMap.get(bs.id).Legacy_booking_treated__c && trigger.newMap.get(bs.id).Legacy_booking_treated__c == true && trigger.oldMap.get(bs.id).Legacy_booking_treated__c == false)){
                system.debug('Inside if::');
                schIdstoTagonBookings.add(bs.Id);
            }
        }
        if(!schIdstoTagonBookings.isEmpty()){
            BrokerageSchemeTriggerHandler.BrokerageSchemeTagging(schIdstoTagonBookings);
        }
    }
    
    
    /*if (trigger.isBefore && trigger.isupdate) {
        for (Brokerage_Scheme__c bs: trigger.new) {
            if(bs.Project_Location__c != null){
                List<Brokerage_Scheme__c> bros = new List<Brokerage_Scheme__c>();
                system.debug('new Project::'+trigger.newMap.get(bs.id).Project__c);
                bros = [Select id,name,Project_Location__r.Approver_L1__c,Project_Location__r.Approver_L2__c from Brokerage_Scheme__c where Id=:bs.id];
                system.debug('bros::'+bros);
                if(!bros.isEmpty()){
                    Brokerage_Scheme__c bks = new Brokerage_Scheme__c();
                    bks.Scheme_Approver_1__c = bros[0].Project_Location__r.Approver_L1__c;
                    bks.Scheme_Approver_2__c = bros[0].Project_Location__r.Approver_L2__c;
                    update bks;
                }
            }
        }
    }*/
}