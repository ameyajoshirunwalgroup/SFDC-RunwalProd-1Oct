trigger SurveyQuestionTrigger on Survey_Questions__c (after update) {

set<id> ids = new set<id>();
List<Survey_Questions__c> svQuesList = new list<Survey_Questions__c>(); 
set<id> optyids = new set<id>();
List<opportunity> optyListForUpdate = new List<Opportunity>();
//string rId = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('SalesManger Site Visit').getRecordTypeId();
//string rIdNew = Schema.SObjectType.Survey_Questions__c.getRecordTypeInfosByName().get('SalesManger ReVisit').getRecordTypeId();

    for(Survey_Questions__c s : trigger.new){
        if(s.Survey__c != null ){ //&& (s.recordtypeId == rId || s.recordtypeId == rIdNew)
            ids.add(s.Survey__c);
        }
    }
    if(!ids.isEmpty()){
        svQuesList = [select id,name,survey__c,survey__r.opportunity__c,RecordType.name,Total_Score__c,survey__r.IsSubmitted__c from Survey_Questions__c where (survey__c IN:ids) and survey__r.opportunity__c != null and survey__r.IsSubmitted__c = true];
    }
    
    if(!svQuesList.isEmpty()){
        for(Survey_Questions__c sv : svQuesList){
            optyids.add(sv.survey__r.opportunity__c);
        }
    }
    system.debug('optyIds:: '+optyids);
    
    if(!optyids.isEmpty()){
        Map<id,opportunity> optyMap = new Map<id,opportunity>([select id,name,Site_Visit_Score__c,Repeat_Site_Visit_Score__c from opportunity where id IN: optyids]);
    
        if(optyMap != null){
            for(id key : optymap.keyset()){
                decimal totalOFSV = 0;
                decimal totalOFRSV = 0;
                for(Survey_Questions__c svNew : svQuesList){
                    if(svNew.survey__r.opportunity__c == key){
                        if(svNew.Total_Score__c != null){
                            if(svNew.RecordType.name =='SalesManger Site Visit')
                                totalOFSV += svNew.Total_Score__c;
                            if(svNew.RecordType.name =='SalesManger ReVisit')   
                                totalOFRSV += svNew.Total_Score__c; 
                        }
                    }
                }
                if(totalOFSV > 0)
                    optymap.get(key).Site_Visit_Score__c = totalOFSV; 
                if(totalOFRSV > 0)    
                    optymap.get(key).Repeat_Site_Visit_Score__c = totalOFRSV;  
                optyListForUpdate.add(optymap.get(key));   
            }
            
        }
    
    }
    if(!optyListForUpdate.isEmpty()){
        update optyListForUpdate;
    }
    
    
}