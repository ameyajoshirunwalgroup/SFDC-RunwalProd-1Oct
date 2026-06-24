trigger TrgBrokerageReceipt on Brokerage_Receipt__c (before update, after insert, after update, before insert, after delete) {
     Map<Id,list<Decimal>> cpBrkVsBrkAmt = new Map<Id,list<Decimal>>();
    if(trigger.isInsert && trigger.isAfter){
        //Added by Prashant to sum up amount to CP Brokerage. 
        for(Brokerage_Receipt__c br : Trigger.new){
            system.debug('In Insert');
            if(br.Invoice_Amount__c != null && br.CP_Brokerage__c != null){              
                if (!cpBrkVsBrkAmt.containsKey(br.CP_Brokerage__c)) {
                    cpBrkVsBrkAmt.put(br.CP_Brokerage__c, new List<Decimal>());
                }
                cpBrkVsBrkAmt.get(br.CP_Brokerage__c).add(br.Invoice_Amount__c);
            }   
        }	
    }
    
    if(trigger.isUpdate && trigger.isAfter){
        //Added by Prashant to sum up amount to CP Brokerage.
        for(Brokerage_Receipt__c br : Trigger.new){
            if(br.CP_Brokerage__c != null && trigger.oldMap.get(br.Id).Invoice_Amount__c != trigger.newMap.get(br.Id).Invoice_Amount__c){
				Decimal brkAmt = ((trigger.newMap.get(br.Id).Invoice_Amount__c != null)?trigger.newMap.get(br.Id).Invoice_Amount__c:0) - ((trigger.oldMap.get(br.Id).Invoice_Amount__c != null)?trigger.oldMap.get(br.Id).Invoice_Amount__c:0);               
                if (!cpBrkVsBrkAmt.containsKey(br.CP_Brokerage__c)) {
                    cpBrkVsBrkAmt.put(br.CP_Brokerage__c, new List<Decimal>());
                }
                cpBrkVsBrkAmt.get(br.CP_Brokerage__c).add(brkAmt);
            }   
        }
    }
    
    if (Trigger.isDelete && Trigger.isAfter) {
        for (Brokerage_Receipt__c br : Trigger.old) {
            if (br.CP_Brokerage__c != null && br.Invoice_Amount__c != null) {                
                Decimal brkAmt = (trigger.oldMap.get(br.Id).Invoice_Amount__c != null)?trigger.oldMap.get(br.Id).Invoice_Amount__c:0;
                if (!cpBrkVsBrkAmt.containsKey(br.CP_Brokerage__c)) {
                    cpBrkVsBrkAmt.put(br.CP_Brokerage__c, new List<Decimal>());
                }
                cpBrkVsBrkAmt.get(br.CP_Brokerage__c).add(-brkAmt);
            }
        }
    }
    if(!cpBrkVsBrkAmt.isEmpty()){
        system.debug('In cpBrkVsBrkAmt -> '+cpBrkVsBrkAmt);
        TrgBrokerageReceiptHandler.handleReceiptAmountonCPBrokerage(cpBrkVsBrkAmt);
    }
}