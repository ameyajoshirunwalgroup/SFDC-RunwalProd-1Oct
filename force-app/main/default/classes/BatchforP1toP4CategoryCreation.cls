//Written by Prashant/Vinay to Automatically create cp category yearly. 16-06-25
global class BatchforP1toP4CategoryCreation implements Database.Batchable<sObject>, Database.Stateful 
{
    
    public Integer currentYear;
    
    global BatchforP1toP4CategoryCreation(Integer currentYear){
        this.currentYear = currentYear;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
            String query = 'SELECT Id FROM Broker__c Order by createdDate desc';
            System.debug('Final Query: ' + query); 
            return Database.getQueryLocator(query);        
    }
    
    global void execute(Database.BatchableContext BC, List<Broker__c> brlist)
    {  

        list<CP_Category__c> cpCategoryList = new list<CP_Category__c>();
        Date StartDate = Date.newInstance(currentYear-3, 4, 1);
        Date EndDate = Date.newInstance(currentYear-1, 3, 31);
        list<String> segmentlist = getSegmentPicklistValues();
        if (!brlist.isEmpty() && !segmentlist.isEmpty()) {
            for (Broker__c b : brlist) {
                for(String segment : segmentlist){
                    CP_Category__c cpc = new CP_Category__c();
                    cpc.Channel_Partner__c = b.id;
                    cpc.Category__c = 'P4';
                    cpc.Segment__c = segment;
                    cpc.Start_Date__c = StartDate;
                    cpc.End_Date__c = EndDate;
                    cpc.Relevant_FY__c = String.valueOf(currentYear);
                    cpCategoryList.add(cpc);
                }
            }
        }
		
        if(!cpCategoryList.isEmpty()){
            Database.SaveResult[] wiList = Database.insert(cpCategoryList, false);

            for(Database.SaveResult sr : wiList){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getStatusCode() + ':' + err.getMessage());
                    }
                }
            }
        }
        
         /*if (!cpCategoryList.isEmpty()) {
            Database.SaveResult[] results = Database.insert(cpCategoryList, false);
            
            Integer i = 0;
            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {
                    String errorMsg = '';
                    for (Database.Error err : sr.getErrors()) {
                        errorMsg += err.getMessage() + ' ';
                    }

                    CP_Category_Error__c errorLog = new CP_Category_Error__c();
                    errorLog.Channel_Partner__c = cpCategoryList[i].Channel_Partner__c;
                    errorLog.Segment__c = cpCategoryList[i].Segment__c;
                    errorLog.Category__c = cpCategoryList[i].Category__c;
                    errorLog.Start_Date__c = cpCategoryList[i].Start_Date__c;
                    errorLog.End_Date__c = cpCategoryList[i].End_Date__c;
                    errorLog.Error_Message__c = errorMsg.trim();
                    errorLogList.add(errorLog);
                }
                i++;
            }
        }

        if (!errorLogList.isEmpty()) {
            insert errorLogList;
        }
		*/
        
    }
    
    global static List<String> getSegmentPicklistValues() {
        List<String> picklistValues = new List<String>();        
        Schema.DescribeFieldResult fieldResult = Project__c.Segment__c.getDescribe();        
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry val : values) {
            //picklistValues.add(val.getLabel()); // You can also use getValue()
            picklistValues.add(val.getValue());
        }        
        return picklistValues;
    }
    
    global void finish(Database.BatchableContext BC)
    {
       
    }
    
    
}