public class BatchtoAssignAddBrkaccruedDashboards implements Database.Batchable<sObject>, Database.Stateful {
    
    /*Public static void callBatchtoAssignAddBrkaccruedDashboards(){
        BatchtoAssignAddBrkaccruedDashboards  bb = new BatchtoAssignAddBrkaccruedDashboards();
        Database.executeBatch(bb,50);
    }*/
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        return Database.getQueryLocator([Select id,Name,Opportunity__r.StageName,Status__c,Passback__c,Brokerage_Scheme__c,Custom_Base_Brokerage__c,Agreement_Value_for_brokers__c,
                                         Brokerage__c,Brokerage_Summary__c,Type_Of_Client_Formula__c,Brokerage_Scheme__r.Start_Date__c,Brokerage_Scheme__r.End_Date__c,BrokerIId__c,
                                         Brokerage_Scheme__r.Slab_Type__c
                                         from Booking__c where Source_of_Booking__c ='Channel Partner' and Opportunity__r.Stagename = 'Unit Booked' and BrokerIId__c != null
                                         and Status__c = 'Booking Confirmed' and Brokerage_Scheme__c != null and DAY_ONLY(CreatedDate)>= 2023-04-01 /*and Id = 'a0s5j000000BoH2AAK'*/]); 
    }
    
    public void execute(Database.BatchableContext bc, List<Booking__c> blist){
        if(!blist.isEmpty()){
            system.debug('blist-'+blist);
            list<Booking__c> blist1 = new list<Booking__c>();
            list<Brokerage_Slab__c> bsSlab = new list<Brokerage_Slab__c>();
            //Map<Id,Integer> bIdVsAddBookingCountMap = new Map<Id,Integer>();
            Decimal totalAV = 0.0;
            for(Booking__c b : blist){
                String scheme= b.Brokerage_Scheme__c;
                String client = b.Type_Of_Client_Formula__c;
                Date schemeStartDate = b.Brokerage_Scheme__r.Start_Date__c;
                Date schemeEndDate = b.Brokerage_Scheme__r.End_Date__c;
                String cpId = b.BrokerIId__c;
                String slabType = b.Brokerage_Scheme__r.Slab_Type__c;
                Decimal AVforBrokers = b.Agreement_Value_for_brokers__c;
                bsSlab = [Select Id,Name,From__c,To__c,Additional_Brokerage__c,Additional_Brokerage_for_Local_Bookings__c,Additional_Brokerage_for_OS_NRI__c,
                          Base_Brokerage_for_Local_Bookings__c,Base_Brokerage_for_OS_NRI__c from Brokerage_Slab__c where Brokerage_Scheme__c =: scheme order by Name];
                blist1 = [Select id,Name,Agreement_Value_for_brokers__c from Booking__c where Source_of_Booking__c ='Channel Partner'and Status__c = 'Booking Confirmed'AND 
                          Brokerage_Scheme__c =: scheme and Opportunity__r.StageName = 'Unit Booked' and BrokerIId__c =: cpId order by Name ASC];
                //system.debug('Booking count ->> '+blist1.size());
                if(slabType == 'Value'){
                    for(Booking__c b1 : blist1){
                        system.debug('Booking Name -> '+b1.Name);
                        totalAV += b1.Agreement_Value_for_brokers__c;
                    }
                }                
                //bIdVsAddBookingCountMap.put(b.Brokerage_Scheme__c,blist1.size());
                for(Brokerage_Slab__c bs: bsSlab){
                    if(slabType == 'Count'){
                        if(bs.From__c != null && (bs.From__c <= blist1.size()  && (bs.To__c >= blist1.size() || bs.To__c == null))){
                            system.debug('Booking Name - >> '+b.Name);
                            system.debug('Booking list size -->>'+blist1.size());
                            system.debug('Slab Name ->> '+bs.Name);
                            Decimal brokerage = 0.0;
                            if(client == 'Local' && bs.Additional_Brokerage_for_Local_Bookings__c != null){
                                system.debug('Additional Brokerage for Local Booking to be given ->>> '+bs.Additional_Brokerage_for_Local_Bookings__c);
                                brokerage = bs.Additional_Brokerage_for_Local_Bookings__c;
                            }else if(client == 'NRI' && bs.Additional_Brokerage_for_OS_NRI__c != null){
                                system.debug('Additional Brokerage for NRI Booking to be given ->>> '+bs.Additional_Brokerage_for_OS_NRI__c);
                                brokerage = bs.Additional_Brokerage_for_OS_NRI__c;
                            }
                            if(brokerage != 0 || brokerage != null){
                                b.Additional_Brokerage_Accrued_Dashboards__c = (brokerage * AVforBrokers)/100;
                            }
                        }
                    }
                    if(slabType == 'Value'){
                        if(bs.From__c != null && (bs.From__c <= totalAV && (bs.To__c >= totalAV || bs.To__c == null))){
                            system.debug('bSlab.From__c <= totalAV && bSlab.To__c >= totalAV::::'+ (bs.From__c <= totalAV && bs.To__c >= totalAV));
                            system.debug('Booking Name - >> '+b.Name);
                            system.debug('Booking list size -->>'+totalAV);
                            system.debug('Slab Name ->> '+bs.Name);
                            Decimal brokerage = 0.0;
                            if(client == 'Local' && bs.Additional_Brokerage_for_Local_Bookings__c != null){
                                system.debug('Additional Brokerage for Local Booking to be given ->>> '+bs.Additional_Brokerage_for_Local_Bookings__c);
                                brokerage = bs.Additional_Brokerage_for_Local_Bookings__c;
                            }else if(client == 'NRI' && bs.Additional_Brokerage_for_OS_NRI__c != null){
                                system.debug('Additional Brokerage for NRI Booking to be given ->>> '+bs.Additional_Brokerage_for_OS_NRI__c);
                                brokerage = bs.Additional_Brokerage_for_OS_NRI__c;
                            }
                            if(brokerage != 0 || brokerage != null){
                                b.Additional_Brokerage_Accrued_Dashboards__c = (brokerage * AVforBrokers)/100;
                            }
                        }
                    } 
                }	
            }
            
           /* for (Id keyId : bIdVsAddBookingCountMap.keySet()) {
                System.debug('Booking Id: ' + keyId + ' → Booking Count: ' + bIdVsAddBookingCountMap.get(keyId));                
            }*/

        }
        
        if(!blist.isEmpty()){
            Database.SaveResult[] wiList = Database.update(blist, false);
		
            for(Database.SaveResult sr : wiList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ':' + err.getMessage());
                    }
                }
            }
        }
    }	
    
    public void finish(Database.BatchableContext bc) {}
}