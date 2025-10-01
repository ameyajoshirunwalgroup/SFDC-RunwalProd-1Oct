global class SAPOutstandingAmountAPIBatch implements Database.Batchable<sObject>, Database.Stateful ,Database.AllowsCallouts, Schedulable{
    
    public Map<String, String> soVsAmt = new Map<String, String>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        OutstandingAmountSync.ZSD_SFDC_OS_AMT_SYNC amt = new OutstandingAmountSync.ZSD_SFDC_OS_AMT_SYNC();
        OutstandingAmountSync.ZsdSfdcOsAmtSyncResponse_element ele = new OutstandingAmountSync.ZsdSfdcOsAmtSyncResponse_element();
        OutstandingAmountSync.ZfiCustOs os = new OutstandingAmountSync.ZfiCustOs();
        OutstandingAmountSync.ZsdSfdcOsAmtTt res = new OutstandingAmountSync.ZsdSfdcOsAmtTt();
        List<String> soNums = new List<String>();
        try{
            res = amt.ZsdSfdcOsAmtSync('1');
            for(OutstandingAmountSync.ZfiCustOs r : res.item){
                soNums.add(r.VbelnN);
                soVsAmt.put(r.VbelnN,r.Dmshb);
            }
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Outstanding API';
            erp.Request__c = String.valueOf(system.now());
            erp.Status__c ='Failure';
            string resp = JSON.serialize(res).replaceAll('\n','<br/>');
            resp = resp.replaceAll('\t', '&nbsp;');
            resp = resp.replaceAll('&quot;','"');
            if(resp.length()>50000)
                resp = resp.substring(0,50000);
            erp.Response__c = resp;
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Timeout Error';
            insert erp;
        }
        String soqlQuery;
        if(!Test.isRunningTest()){
            soqlQuery = 'SELECT Id, FBL5N__c, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Opportunity__r.StageName FROM Booking__c WHERE Opportunity__r.StageName = \'Unit Booked\' AND Opportunity__r.SalesOrder_Number__c IN : soNums';
        	return Database.getQueryLocator(soqlQuery);
        }else{
            soVsAmt.put('3262627','10000');
            soqlQuery = 'SELECT Id, FBL5N__c, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.SalesOrder_Number__c, Opportunity__r.StageName FROM Booking__c WHERE Opportunity__r.SalesOrder_Number__c = \'3262627\' LIMIT 1';
        	return Database.getQueryLocator(soqlQuery);
        }
    }
    
    global void execute( Database.BatchableContext BC, List<Booking__c> scope){
        Map<String, Booking__c> crnVsBkg = new Map<String, Booking__c>();
        List<Booking__c> bkgsToUpdate = new List<Booking__c>();
        for(Booking__c bkg : scope){
            //crnVsBkg.put(bkg.Opportunity__r.SAP_Customer_Number__c, bkg);
            bkg.FBL5N__c = Decimal.valueOf(soVsAmt.get(bkg.Opportunity__r.SalesOrder_Number__c));
            bkgsToUpdate.add(bkg);
        }
        /*for(String crn : crnVsAmt.keySet()){
            if(crnVsBkg.get(crn) != null){
                crnVsBkg.get(crn).FBL5N__c = Decimal.valueOf(crnVsAmt.get(crn));
            	bkgsToUpdate.add(crnVsBkg.get(crn));
            }
        }*/
        system.debug('bkgsToUpdate: ' + bkgsToUpdate.size());
        //update bkgsToUpdate;
        BookingTriggerHandler.byPass = true;
        //update bkgsToUpdate;
        Database.update(bkgsToUpdate, false);
        BookingTriggerHandler.byPass = false;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    global void execute(SchedulableContext dc) {
        SAPOutstandingAmountAPIBatch b = new SAPOutstandingAmountAPIBatch();
		database.executeBatch(b,100);
    }
}