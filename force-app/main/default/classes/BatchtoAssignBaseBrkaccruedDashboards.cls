public class BatchtoAssignBaseBrkaccruedDashboards implements Database.Batchable<sObject>, Database.Stateful {
    
    /*Public static void callBatchtoAssignBaseBrkaccruedDashboards(){
        BatchtoAssignBaseBrkaccruedDashboards  bb = new BatchtoAssignBaseBrkaccruedDashboards();
        Database.executeBatch(bb,50);
    }*/
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        system.debug('Inside start method----');
        return Database.getQueryLocator([Select id,Opportunity__r.StageName,Status__c,Passback__c,Brokerage_Scheme__c,Custom_Base_Brokerage__c,Agreement_Value_for_brokers__c,Brokerage__c,Brokerage_Summary__c,Base_Brokerage__c
                                         from Booking__c where Source_of_Booking__c ='Channel Partner' and Opportunity__r.Walkin_Source__c = 'Channel Partner' and Opportunity__r.Stagename = 'Unit Booked' and BrokerIId__c != null 
                                         and Status__c = 'Booking Confirmed' and DAY_ONLY(CreatedDate)>= 2023-04-01 and Brokerage_Scheme__c != null]); 
    }
    
    public void execute(Database.BatchableContext bc, List<Booking__c> blist){
        if(!blist.isEmpty()){
            system.debug('blist-'+blist);
            for(Booking__c bkg : blist){
                system.debug('Inside blist');
                if(bkg.Base_Brokerage__c != null && bkg.Base_Brokerage__c != 0){
                    bkg.Base_Brokerage_Accrued_Dashboards__c = (bkg.Base_Brokerage__c * bkg.Agreement_Value_for_brokers__c)/100;
                }else if(bkg.Brokerage__c != null && bkg.Brokerage__c != 0){
                    bkg.Base_Brokerage_Accrued_Dashboards__c = (bkg.Brokerage__c * bkg.Agreement_Value_for_brokers__c)/100;
                }
                /*}else{
                    system.debug('Inside scheme null');
                    if(bkg.Passback__c != null && bkg.Passback__c != 0){  
                        system.debug('Inside passback not null');
                        bkg.Base_Brokerage_Accrued_Dashboards__c = (bkg.Brokerage__c * bkg.Agreement_Value_for_brokers__c)/100;
                    }else if(bkg.Passback__c == null || bkg.Passback__c == 0){
                        system.debug('Inside passback null');
                        bkg.Base_Brokerage_Accrued_Dashboards__c = 0.02 * bkg.Agreement_Value_for_brokers__c;
                    }
                    
                } */
            }
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