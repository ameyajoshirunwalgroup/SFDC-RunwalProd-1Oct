public with sharing class JuvlonIntegration {
    
    @future (callout=true)
    public static void reportMethod( List<ID> ids){
        system.debug('ids___'+ids);
        
        RW_Juvlon_Campaign__c juvCampRec = [SELECT  Id, Name,RW_Approved_By__c, RW_Campaign_Status__c, RW_ListId__c,
                                            RW_Report_Id__c,RW_from_date__c, RW_to_date__c, RW_Juvlon_Object__c FROM 
                                            RW_Juvlon_Campaign__c  WHERE Id in :ids LIMIT 1 ];// Id='a1n6D000000KgKvQAK'
        system.debug('juvCampRec___'+juvCampRec);
        
        
        //List<Report> reportList = [SELECT Id,DeveloperName FROM Report where  DeveloperName = 'Juvlon_Campaign_Report'];
        // String reportId =  (String)reportList.get(0).get('Id');
        
        String reportId;
        if(!String.isBlank(juvCampRec.RW_Report_Id__c)){
            reportId  = juvCampRec.RW_Report_Id__c;
        }                
        system.debug('jreportId___'+reportId);
        
        
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        // Run a report
        Reports.ReportResults runResults = Reports.ReportManager.runReport(reportId);
        
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        system.debug('reportMd.getstandardDateFilter:::'+reportMd.getstandardDateFilter());
        system.debug('reportMd.getDetailColumns():::'+reportMd.getDetailColumns());
        system.debug('---col ReportType---'+reportMd.getReportType());
        Reports.standardDateFilter rprtDateFltr = reportMd.getstandardDateFilter();
        system.debug('---standardColumn---'+rprtDateFltr.getColumn());
        
        system.debug('---getDurationValue()---'+rprtDateFltr.getDurationValue());
        system.debug('---standardStartDate---'+rprtDateFltr.getStartDate());
        system.debug('---standardEndDate---'+rprtDateFltr.getEndDate());
        
        Map<String,String> mapFieldMtd = new Map<String,String>();
        
        List<RW_Report_Field_Mapping__mdt> repMapingField = [SELECT  RW_Field_Name__c, MasterLabel,RW_Report_Object__c FROM RW_Report_Field_Mapping__mdt];
        for(RW_Report_Field_Mapping__mdt repMtd:repMapingField){
            mapFieldMtd.put(repMtd.MasterLabel,repMtd.RW_Field_Name__c);
        } 
        
        system.debug('---mapFieldMtd values---'+mapFieldMtd.values());
        
        String allFields='';
        if(!reportMd.getDetailColumns().isEmpty() ){ 
            for(String str: reportMd.getDetailColumns()){
                system.debug('###str '+str);
                system.debug('###mapFieldMtd '+mapFieldMtd);

                system.debug(mapFieldMtd.get(str));
                if(mapFieldMtd.containsKey(str)){
                  allFields += mapFieldMtd.get(str)+','; 
                    system.debug('allFields____ '+allFields);
                }
                
            }
        }
        system.debug('allFields____ 62 '+allFields);
        // Get the report metadata
        String projFilter='';
        Map<String,String> operatorMap = New Map<String,String>();
        operatorMap.put('equals','=');
        operatorMap.put('notEqual','!=');
        
        Reports.ReportMetadata rm = runResults.getReportMetadata();
        system.debug('### rm '+rm);
        for(Reports.ReportFilter rf : rm.getreportFilters()){
            system.debug('---col name---'+rf.getcolumn());
            system.debug('---col value---'+rf.getValue());
            system.debug('---col FilterType()---'+rf.getFilterType()); 
            system.debug('---col Operator---'+rf.getOperator());
            
            if(!String.isBlank(rf.getcolumn()) ){
                if(rf.getcolumn().contains(juvCampRec.RW_Juvlon_Object__c) ){
                 
                    string cloumfilter = rf.getcolumn().remove(juvCampRec.RW_Juvlon_Object__c+'.');
                    system.debug('---cloumfilter---'+cloumfilter);
                   // if(juvCampRec.RW_Juvlon_Object__c == 'Lead'){
                       projFilter = mapFieldMtd.get(cloumfilter)+operatorMap.get(rf.getOperator())+ '\'' +rf.getValue()+'\'';
                   // }
                   /* if(juvCampRec.RW_Juvlon_Object__c == 'Opportunity'){
                        projFilter = cloumfilter+operatorMap.get(rf.getOperator())+ '\'' +rf.getValue()+'\'';
                    }*/
                   
                    system.debug('projFilter___'+projFilter);
                }
                
            }   
        }
        system.debug('---projFilter---'+projFilter);
        string whereclause ='';
        String query = 'Select '+allFields.removeEndIgnoreCase(',') +' From '+juvCampRec.RW_Juvlon_Object__c;
        system.debug('---query---'+query);
        if(!String.isBlank(projFilter) ){
           // query += ' where '+projFilter;
           whereclause= projFilter;
        }
        
        if(!String.isBlank(whereclause)){
            whereclause += ' AND';
        }
        if(!String.isBlank(rprtDateFltr.getStartDate())){
            
            date strDate = Date.valueOf(rprtDateFltr.getStartDate());//+;
            //System.debug('### strDate '+strDate); 
            DateTime dtAndTime = DateTime.newInstance(strDate.year(),strDate.month(),strDate.day(),0,0,0);
            //system.debug('StartDT (local time): ' + dtAndTime.format('yyyy-MM-dd\'T\'HH:mm:ss'+'.000+0000'));
            //query += ' AND CreatedDate ' + '>= ' +dtAndTime.format('yyyy-MM-dd\'T\'HH:mm:ss'+'.000+0000');
                        whereclause += ' CreatedDate ' + '>= ' +dtAndTime.format('yyyy-MM-dd\'T\'HH:mm:ss'+'.000+0000');

        }
          if(!String.isBlank(whereclause)){
            whereclause += ' AND';
        }
        if(!String.isBlank(rprtDateFltr.getEndDate())){
            
            date endDate = Date.valueOf(rprtDateFltr.getEndDate());
            //System.debug('### endDate '+endDate); 
            DateTime dtAndTime = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day(),23,59,59);
           // query += ' AND CreatedDate ' + '<= ' +dtAndTime.format('yyyy-MM-dd\'T\'HH:mm:ss'+'.000+0000');
               whereclause += ' CreatedDate ' + '<= ' +dtAndTime.format('yyyy-MM-dd\'T\'HH:mm:ss'+'.000+0000');
        }
        if(!String.isBlank(whereclause)){
            query += ' where '+ whereclause;
        }
        List<sObject> sobjList = new List<sObject>();
        if(!test.isRunningTest())    {    System.debug('### query '+query);
         sobjList = Database.query(query);
        System.debug('### sobjList '+sobjList.size());
    }
        if(sobjList != null && sobjList.size()> 0){
            subscribersSetUp(sobjList, juvCampRec.RW_Juvlon_Object__c, juvCampRec.RW_ListId__c, juvCampRec.Id);
        }
        // SELECT CreatedDate, LastName, FirstName,  RW_Project__c FROM Lead where RW_Project__r.Name = 'Runwal Bliss' And CreatedDate >= 2020-09-01T10:32:16.000+0000  and CreatedDate <=   2020-11-30T10:32:16.000+0000 
        
    }
    
    public static void subscribersSetUp(List<Sobject> listOfRecs, String objectType, String listId, String juvCampRecId){
        
        string str='';
        JuvlonJson subScrbList = new JuvlonJson();
        subScrbList.ApiKey = System.Label.RW_Juvlon_APIKey;
        subScrbList.listName = listId;
        List<JuvlonJson.Subscribers> sublist = new List<JuvlonJson.Subscribers>();
        if(objectType == 'Lead'){
         for(Sobject sobj: (List<lead>)listOfRecs){
            
            Lead lead = (Lead)sobj;
            JuvlonJson objJson  = new JuvlonJson();
            
            JuvlonJson.Subscribers subobj = new JuvlonJson.Subscribers();
            if(emailValidation( lead.Email))
            	subobj.email = lead.Email; 
            else 
                 subobj.email='';
            subobj.mobile = mobielValidation(lead.RW_Mobile_No__c);
            //subobj.firstName = lead.FirstName;
            //subobj.lastName = lead.lastName;
            sublist.add(subobj);
            subScrbList.subscribers = sublist;
            
          }   
        }
         if(objectType == 'Opportunity'){
         for(Sobject sobj: (List<Opportunity>)listOfRecs){
            
            Opportunity opp = (Opportunity)sobj;
            JuvlonJson objJson  = new JuvlonJson();
            
            JuvlonJson.Subscribers subobj = new JuvlonJson.Subscribers();
            if(emailValidation(opp.RW_Email__c))
            	subobj.email = opp.RW_Email__c; 
            else
                 subobj.email='';
             
            subobj.mobile = mobielValidation(opp.RW_Mobile_No__c);
             
            sublist.add(subobj);
            subScrbList.subscribers = sublist;
            
        }   
        }
subScrbList.isUnique = '0';        
       system.debug('___subScrbList  '+subScrbList);
        str = System.JSON.serialize(subScrbList);
        system.debug('__JsonStr  '+str);
        if(test.isRunningTest()){
        	JuvlonJson.parse(str);
        }    
        
        //callout
        Http http = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setHeader('Content-Type',  'application/json');
        req.setEndpoint('https://api2.juvlon.com/v4/addSubscribers');
        req.setBody(str);
        HTTPResponse res = http.send(req);
        System.debug('res!!! getBody '+res.getBody());
        System.debug('res!!! getStatusCode '+res.getStatusCode());
        
        RW_Juvlon_Campaign__c juvlonObj =  [select Id,Name,RW_Juvlon_Status__c,RW_Report_Id__c,RW_Juvlon_Object__c 
                                            from RW_Juvlon_Campaign__c WHERE Id =:juvCampRecId LIMIT 1];
            system.debug('juvlonObj:::'+juvlonObj); 
        if(res.getStatusCode() == 200){
            juvlonObj.RW_Juvlon_Status__c = 'Success';
        }
        else{
            juvlonObj.RW_Juvlon_Status__c = 'Failed';
        } 
        update juvlonObj; 
        
        
    }
    
  static  boolean emailValidation(string email){
        boolean valid = true;
        List<String>ignoreEmails = SYstem.label.RW_Juvlon_Ignore_Email.split(',');
        if(email !=null && ignoreEmails.contains(email.toLowerCase())){
            valid = false;
        }
        return valid ;
        
    }
  static  string mobielValidation(string mobilenumber){
      if(mobilenumber == null){
          return '';
      }else if(mobilenumber.startsWith('0')){
            if(mobilenumber.removeStart('0').length() == 10){
                return mobilenumber.removeStart('0');
            }
        }else if(mobilenumber.startsWith('91')){
               if(mobilenumber.removeStart('91').length() == 10){
                return mobilenumber.removeStart('91');
            }
        }else if(mobilenumber.startsWith('+91')){
               if(mobilenumber.removeStart('+91').length() == 10){
                return mobilenumber.removeStart('+91');
            }
        }else if(mobilenumber.length() ==10){
                    return mobilenumber;
        }else
            return '';
 //       return valid ;
        return mobilenumber;
    }

}