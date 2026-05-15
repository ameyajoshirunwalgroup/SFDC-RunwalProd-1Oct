trigger trgupdateBrokerage on Booking__c (before update,before insert) {
    if(trigger.isbefore && trigger.isupdate){
        for(Booking__c bk: trigger.new){
            if(bk.Stamp_duty_Paid2__c != NULL){
                if(bk.Stamp_duty_Paid2__c > bk.Base_Brokerage_2__c ){
                    if(bk.Base_Brokerage_2__c != Null && bk.Passback__c!= Null ){
                        bk.Brokerage__c =   bk.Base_Brokerage_2__c - bk.Passback__c;
                        
                    }   
                }
            }
           if(bk.Base_Brokerage_2__c != Null &&  (trigger.oldMap.get(bk.id).Base_Brokerage_2__c != trigger.newMap.get(bk.id).Base_Brokerage_2__c )&& bk.Brokerage_Summary__c == Null){
                bk.Brokerage__c = bk.Base_Brokerage_2__c - bk.Passback__c;

                
            }
        }
    }   
   
    if(Trigger.isbefore && Trigger.isupdate) {
        for(Booking__c b : trigger.new){
            if(trigger.oldMap.get(b.id).RW_Registration_Done__c != null &&  trigger.newMap.get(b.id).RW_Registration_Done__c == 'Yes'){
                
                if( (trigger.oldMap.get(b.id).RW_Registration_Done__c != trigger.newMap.get(b.id).RW_Registration_Done__c && trigger.newMap.get(b.id).RW_Registration_Done__c == 'Yes') &&(b.Applied_Slab_Name__c != 'Slab 1' && (b.RW_Registration_Date__c == null || b.RW_BRL_Number__c == '' ||b.RW_BRL_Number__c == Null ||b.RW_Expected_Registration_Date__c ==Null || b.RW_Registration_Type__c == ''||b.RW_Registration_Type__c == Null))){
                  // b.addError('Error!...To make Registration Completed. BLR No, Registration Date, Expected Registration Date & Registration Type is Mandatory..');
                }
                
                
             
            }
        }
    }
  
    /*if(Trigger.isbefore && Trigger.isupdate){
        Set<Id> Bid = new Set<Id>();
        Set<id> Tid = new Set<Id>();
        for(Booking__c bk :trigger.new){
            if((trigger.oldMap.get(bk.id).RW_Registration_Done__c != trigger.newMap.get(bk.id).RW_Registration_Done__c && trigger.newMap.get(bk.id).RW_Registration_Done__c == 'Yes')){
                Bid.add(bk.BrokerIId__c);   
                Tid.add(bk.Tower__c);
                system.debug('Inside if ::');
                system.debug('trgBooking1 bk :: '+bk);
            }   
        }
        List<Booking__c> bkList = New List<Booking__c>();
        List<Broker__c> CpList = New  List<Broker__c>();
        List<Tower__c> TowerList = New List<Tower__c>();
        CpList = [Select Id,name,Place_of_Supply__c from Broker__c Where Place_of_Supply__c = NULL and Id IN : Bid ];
        TowerList = [Select Id,name,Legal_Entity__c from Tower__c Where Legal_Entity__c = NULL and Id IN : Tid];
        
        system.debug('Bid ::'+Bid);
        system.debug('CpList Size ::' +CpList.size());
        for(Booking__c bk :trigger.new){
            if(CpList.size() > 0 || !CpList.isEmpty()){
                bk.addError('Error..! Please update the Place of supply on Channel Partner.');
            }
            System.debug('TowerList ::'+TowerList);
            system.debug('Tid ::'+Tid);
            system.debug('TowerList Size ::' +TowerList.size());
            if(TowerList.size() > 0 || !TowerList.isEmpty()){
                bk.addError('Error..! Please update the Legal Entity on the Tower.');
                
            }
        }  
        
   
        
    }*/
}