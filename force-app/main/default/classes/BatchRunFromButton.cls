public class BatchRunFromButton {
    public Id SchemeId {get;set;}
    public Date Startdatename {get;set;}
    public Date Enddatename {get;set;}
    List<Booking__c> bkList = new List<Booking__c>();
    set<ID> CPIds = new set<ID>();
    set<ID> SchemeIds = new set<ID>();
    public BatchRunFromButton() { 
        Integer Y = Date.Today().Year();
        Integer M = Date.Today().Month();
        Startdatename = Date.valueOf(''+Y+'-'+M+'-01 00:00:00');
        Enddatename = Date.valueOf(''+Y+'-'+M+'-31 00:00:00');
        SchemeId = ApexPages.currentPage().getParameters().get('id');
    }  
    public void BatchRun(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Batch run started'));
        BatchForBrokerageCalculation  bb = new BatchForBrokerageCalculation();
        Database.executeBatch(bb,1);
    } 
    public void BatchRunCancellation(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Batch run started'));
        BatchForCancelledBrokerage  cc = new BatchForCancelledBrokerage();
        Database.executeBatch(cc,1);
    }
    public void BatchRunLadderBrokerage(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Batch run started'));
        bkList = [select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                  RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                  and  RW_Registration_Done__c = 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false and
                  Type_of_Client__c != null and Brokerage_Summary__c != null and Booking_Date__c > 2022-09-29T23:01:01Z and RW_Registration_Date__c != null 
                  and Brokerage_Scheme__c != null and RW_X9_99_Received__c = true And Source_of_Booking__c = 'Channel Partner' ORDER BY Booking_Date__c ASC];
        for(Booking__c b:bkList){
            CPIds.add(b.BrokerIId__c);
        }
        /*for(Booking__c b:bkList){
            SchemeIds.add(b.Brokerage_Scheme__c);
        }*/
        SchemeIds.add(SchemeId);
        BatchBrokerageLadderCreation  cc = new BatchBrokerageLadderCreation(CPIds,SchemeIds);
        Database.executeBatch(cc,1);
    }
    public void BatchRunLadderBrokerageListView(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Batch run started'));
        bkList = [select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Booking_Date__c,Tower__c,
                  RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where Project__c != null and Status__c = 'Booking Confirmed'
                  and  RW_Registration_Done__c != 'Yes' and BrokerIId__c != null and Opportunity__c != null and Exclude_From_Brokerage_Batch__c = false and
                  Type_of_Client__c != null and Brokerage_Summary__c != null and Booking_Date__c > 2022-09-29T23:01:01Z and RW_Registration_Date__c != null 
                  and Brokerage_Scheme__c != null and RW_X9_99_Received__c = true And Source_of_Booking__c = 'Channel Partner' ORDER BY Booking_Date__c ASC];
        for(Booking__c b:bkList){
            CPIds.add(b.BrokerIId__c);
        }
        for(Booking__c b:bkList){
            SchemeIds.add(b.Brokerage_Scheme__c);
        }
        BatchBrokerageLadderCreation  cc = new BatchBrokerageLadderCreation(CPIds,SchemeIds);
        Database.executeBatch(cc,1);
    }
    public PageReference BatchRunInactiveScheme(){
        System.debug('Startdatename::'+Startdatename);
        System.debug('Enddatename::'+Enddatename);
        if(Startdatename != null && Enddatename != null){
            BatchForInactiveSchemeBrokerage  dd = new BatchForInactiveSchemeBrokerage(Startdatename,Enddatename);
            Database.executeBatch(dd,1);
           // return new PageReference('https://runwal--uat.sandbox.lightning.force.com/lightning/o/Brokerage_Scheme__c/list?filterName=00B1e000001zLNrEAM');
            return new PageReference('https://runwal.lightning.force.com/lightning/o/Brokerage_Scheme__c/list?filterName=00B5j00000CvPk5EAF');

            
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please Select Start and End Date'));
            return null;
        }
         
    }
    
    public PageReference Home() {  
//
         //   return new PageReference('https://runwal--uat.sandbox.lightning.force.com/lightning/o/Brokerage_Scheme__c/list?filterName=00B1e000001zLNrEAM');
         return new PageReference('https://runwal.lightning.force.com/lightning/o/Brokerage_Scheme__c/list?filterName=00B5j00000CvPk5EAF');         

    }
}