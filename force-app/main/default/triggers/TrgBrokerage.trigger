trigger TrgBrokerage on Brokerage__c (after insert, before insert,after update,after delete,before update) {
    /*if (trigger.isafter && trigger.isInsert){
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokerageupdateList = new List<Brokerage__c>();
        for (Brokerage__c b: trigger.new) {
            if(b.Brokerage_Summary__c != null){
                brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c,Status__c
                                     from Brokerage_Summary__c where Id =: b.Brokerage_Summary__c];
                if(brokerSummaryList[0].Status__c == 'Due' && !brokerSummaryList.isEmpty()){
                    Brokerage__c bb = new Brokerage__c();
                    bb.Id = b.Id;
                    bb.Status__c = 'Due';
                    brokerageupdateList.add(bb);
                }
            }
        }
        if(!brokerageupdateList.isEmpty()){
            update brokerageupdateList;
        }
    }*/
    
    if (trigger.isbefore && trigger.isInsert){
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        Set<Id> brokerSummaryIds = new Set<Id>();
        List<Brokerage__c> brokerageupdateList = new List<Brokerage__c>();
        for (Brokerage__c b: trigger.new) {
            system.debug('Inside loop');
            brokerSummaryIds.add(b.Brokerage_Summary__c);
            /*//Added by Prashant - Total Brokerage Amount Text for Dashboards. ///START 03-07-2025.////
            if(b.Brokerage_Amount__c != null || b.Cancelled_Brokerage_Amount__c != null){
                Decimal BrokerageAmt = b.Brokerage_Amount__c != null ? b.Brokerage_Amount__c : 0;
                Decimal CanclledBrokerageAmt = b.Cancelled_Brokerage_Amount__c != null ? b.Cancelled_Brokerage_Amount__c : 0;                
                Decimal TotalBrokerageAmt = BrokerageAmt - CanclledBrokerageAmt;
                system.debug('BrokerageAmt'+BrokerageAmt);
                system.debug('CanclledBrokerageAmt'+CanclledBrokerageAmt);
                system.debug('TotalBrokerageAmt'+TotalBrokerageAmt);
                b.Total_Brokerage_Amount_Text__c = TotalBrokerageAmt;
            }
            //Added by Prashant - Total Brokerage Amount Text for Dashboards. ///END 03-07-2025.////*/
        }
        brokerSummaryList = [Select Id,Name,Status__c from Brokerage_Summary__c where Id IN:brokerSummaryIds];
        for (Brokerage__c b: trigger.new) {
            for (Brokerage_Summary__c bs: brokerSummaryList) {
                if(b.Brokerage_Summary__c != null && bs.Status__c == 'Due' && b.Status__c != 'Due' && b.Brokerage_Summary__c == bs.Id){
                    system.debug('Inside if');
                    b.Status__c = 'Due';
                }
            }
        }
        
    }
    
    /*//Added by Prashant - Total Brokerage Amount Text for Dashboards. ///START 03-07-2025.////
    if(trigger.isBefore && trigger.isUpdate){
        for (Brokerage__c b: trigger.new) {
            system.debug('Outside If loop');
            if((trigger.oldmap.get(b.Id).Brokerage_Amount__c != b.Brokerage_Amount__c) || (trigger.oldmap.get(b.Id).Cancelled_Brokerage_Amount__c != b.Cancelled_Brokerage_Amount__c)){
                system.debug('Inside If loop');
                Decimal BrokerageAmt = b.Brokerage_Amount__c != null ? b.Brokerage_Amount__c : 0;
                Decimal CanclledBrokerageAmt = b.Cancelled_Brokerage_Amount__c != null ? b.Cancelled_Brokerage_Amount__c : 0;                
                Decimal TotalBrokerageAmt = BrokerageAmt - CanclledBrokerageAmt;
                system.debug('BrokerageAmt'+BrokerageAmt);
                system.debug('CanclledBrokerageAmt'+CanclledBrokerageAmt);
                system.debug('TotalBrokerageAmt'+TotalBrokerageAmt);
                b.Total_Brokerage_Amount_Text__c = TotalBrokerageAmt;
            }
        }
    }
    //Added by Prashant - Total Brokerage Amount Text for Dashboards. ///END 03-07-2025.////*/
    
    /*//Added by Prashant - Assigning Additional Brokerage Accrued (Dashboards). ///START 02-07-2025.////
    Map<Id,Decimal> bkIdVsBrgMap = new Map<Id,Decimal>();
    if(trigger.isAfter && trigger.isInsert){        
        for (Brokerage__c b: trigger.new) {
            if(b.Brokerage_Type__c == 'Additional Brokerage' && b.Booking__c != null && b.Total_Brokerage_Amount_Text__c != null){
                bkIdVsBrgMap.put(b.Booking__c,b.Total_Brokerage_Amount_Text__c);
            }         
        } 
    }
    if(trigger.isAfter && trigger.isDelete){
        system.debug('<<-- Inside isAfter && isDelete -->>');
        for (Brokerage__c b: trigger.old) {
            if(b.Brokerage_Type__c == 'Additional Brokerage' && b.Booking__c != null){                
                bkIdVsBrgMap.put(b.Booking__c,(b.Total_Brokerage_Amount_Text__c != null ? -b.Total_Brokerage_Amount_Text__c : 0));
            }
        } 
    }
    if(trigger.isAfter && trigger.isUpdate){
        for (Brokerage__c b: trigger.new) {
            if(b.Brokerage_Type__c == 'Additional Brokerage' && b.Booking__c != null && trigger.oldmap.get(b.Id).Total_Brokerage_Amount_Text__c != trigger.newmap.get(b.Id).Total_Brokerage_Amount_Text__c){    
                system.debug('New value -> '+trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0);
                system.debug('Old value -> '+trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0);
                system.debug('Difference -> '+((trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0)  - (trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0)));
                bkIdVsBrgMap.put(b.Booking__c,((trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.newMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0) - (trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c != null ? trigger.oldMap.get(b.Id).Total_Brokerage_Amount_Text__c : 0)));               
            }
        } 
    }
    system.debug('bkIdVsBrgMap'+bkIdVsBrgMap);
    if(!bkIdVsBrgMap.isEmpty()){	
        TrgBrokerageHandler.AssignAdditionalBrokerageAccruedDashboards(bkIdVsBrgMap);
    }
    //Added by Prashant - Assigning Additional Brokerage Accrued (Dashboards). ///END 02-07-2025.////*/
}