public class TrgBrokerageReceiptHandler {
    public static void handleReceiptAmountonCPBrokerage(Map<Id,list<Decimal>> cpBrkVsBrkAmt){
        system.debug('In cpBrkVsBrkAmt -> '+cpBrkVsBrkAmt);
        list<CP_Brokerage__c> cpblisttoUpdate = new list<CP_Brokerage__c>();
        Map<Id,CP_Brokerage__c> cpbMap = new Map<Id,CP_Brokerage__c>();
        list<CP_Brokerage__c> cpblist = [Select Id,Total_Amount_Paid__c from CP_Brokerage__c where Id In: cpBrkVsBrkAmt.keyset()];
        if(!cpblist.isEmpty()){
            for(CP_Brokerage__c cpb : cpblist){
                cpbMap.put(cpb.Id,cpb);
            }
        }
        system.debug('In cpBrkVsBrkAmt.keyset() -> '+cpBrkVsBrkAmt.keyset());
        for(Id bId : cpBrkVsBrkAmt.keyset()){
            system.debug('In For cpBrkVsBrkAmt.keyset() -> ');
            CP_Brokerage__c cb = new CP_Brokerage__c();
            cb.Id = bId;
            Decimal totalAmtPaid = (cpbMap.get(bId).Total_Amount_Paid__c != null) ? cpbMap.get(bId).Total_Amount_Paid__c : 0;
            for(Decimal br : cpBrkVsBrkAmt.get(bId)){
                totalAmtPaid += br;
            }
            cb.Total_Amount_Paid__c = totalAmtPaid;
            cpblisttoUpdate.add(cb);
        }                                                                                                                                                                                                                                                                          
        try{
            update cpblisttoUpdate;
        }catch(Exception e){
            system.debug('Error -> '+e.getMessage());
        }
    } 
}