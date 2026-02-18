public class importDataFromCSVController {
    public Blob csvFileBody{get;set;}
    public string csvAsString{get;set;}
    public string csvFileName{get;set;}
    public string objectName{get;set;}
    public String[] csvFileLines{get;set;}
    public List<customWrapper> custlist{get;set;}
    public importDataFromCSVController(){
        csvFileLines = new String[]{};
            custlist = New List<customWrapper>(); 
    }
    
    public void importCSVFile(){
        try{
            objectName = csvFileName;
            csvAsString = csvFileBody.toString();
            //system.debug('csvAsString'+csvAsString);
            csvFileLines = csvAsString.split('\n'); 
            Map<Id,String> cpOldIdvsNewIdMap = new Map<Id,String>();
            for(Integer i=1;i<csvFileLines.size();i++){
                customWrapper cw = new customWrapper() ;
                string[] csvRecordData = csvFileLines[i].split(',');
                cw.OldId = csvRecordData[0].trim();             
                cw.NewId = csvRecordData[1].trim();                                                                         
                custlist.add(cw); 
                cpOldIdvsNewIdMap.put(cw.OldId,cw.NewId);
            }
            //insert acclist;
            
            List<Schema.ChildRelationship> childRelationships = Schema.getGlobalDescribe().get('Broker__c').getDescribe().getChildRelationships();
            system.debug('childRelationships'+childRelationships);
            Map<String, String> relationshipMappings = new Map<String, String>();
            String soql = 'Select Id, ';
            for (Schema.ChildRelationship cr : childRelationships) {  
                if(cr.getRelationshipName() == 'Leads__r'){
                    System.debug('Child Object: ' + cr.getChildSObject());
                    System.debug('Field on Child: ' + cr.getField());
                    System.debug('Relationship Name: ' + cr.getRelationshipName());
                    //AOP__c-Channel_partner__c => AOP__r.
                    relationshipMappings.put(String.valueOf(cr.getChildSObject()) + '-' + String.valueOf(cr.getField()),String.valueOf(cr.getRelationshipName()));
                    soql += '(Select Id,'+ cr.getField() +' from '+ cr.getRelationshipName() +'),';
                    //break;
                }
            }
            if (soql.endsWith(',')) {
                soql = soql.substring(0, soql.length() - 1);
            }
            Set<Id> OldIds = new Set<Id>(cpOldIdvsNewIdMap.keySet());
            soql += ' FROM Broker__c WHERE Id IN :OldIds';
            system.debug('soql query - '+soql);
            
            List<Broker__c> childRecords = Database.query(soql);
            system.debug('childRecords list = '+childRecords);
            
            /*List<SObject> recordsToUpdate = new List<SObject>();
            
            for(String objName : relationshipMappings.keySet()){
                for (SObject record : childRecords) {
                     Id oldId = (Id)record.get(relationshipMappings.get(objName));
                    if (cpOldIdvsNewIdMap.containsKey(oldId)) {
                        record.put(relationshipMappings.get(objName), cpOldIdvsNewIdMap.get(oldId));
                        recordsToUpdate.add(record);
                    }
                }
            }
            system.debug('recordsToUpdate'+recordsToUpdate);
            //update recordsToUpdate;*/
    
            
           /* list<Broker__c> brlist = [Select id,(Select id,Channel_Partner__c from Accounts__r),
                                      (select id from Opportunities__r),
                                      (select id from Opportunities1__r)  
                                      from Broker__c 
                                      where Id IN: cpOldIdvsNewIdMap.keySet()
                                     ];
            system.debug('Broker list = '+brlist);*/
            list<Account> acctoUpdate = new list<Account>();
            list<Booking__c> btoUpdate = new list<Booking__c>();
            //list<Brokerage_Invoice__c> bitoUpdate = new list<Brokerage_Invoice__c>();
            //list<Brokerage_Summary__c> sumtoUpdate = new list<Brokerage_Summary__c>();
            //list<Brokerage__c> brotoUpdate = new list<Brokerage__c>();
            //list<CIF__c> ciftoUpdate = new list<CIF__c>();
            //list<CP_Category__c> cpctoUpdate = new list<CP_Category__c>();
            //list<CP_Profile_Update__c> cputoUpdate = new list<CP_Profile_Update__c>();
            list<Lead> ltoUpdate = new list<Lead>();
            list<Lead> l1toUpdate = new list<Lead>();
            list<OTP__c> otptoUpdate = new list<OTP__c>();
            list<Prospect__c> prostoUpdate = new list<Prospect__c>();
            list<Task> tsktoUpdate = new list<Task>();
            list<Opportunity> otoUpdate = new list<Opportunity>();
            list<Opportunity> o1toUpdate = new list<Opportunity>();
            list<Opportunity> o2toUpdate = new list<Opportunity>();
            for(Broker__c br : childRecords)
            {
                //system.debug('Broker Id: '+ br.Id);
                /*
                if (br.Accounts__r != null && !br.Accounts__r.isEmpty()) 
                {
                    for (Account acc : br.Accounts__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.Channel_Partner__c);
                        String OldId = acc.Channel_Partner__c;
                        OldId = OldId.left(15);
                        acc.Channel_Partner__c = cpOldIdvsNewIdMap.get(OldId);
                        acctoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.Channel_Partner__c);                       
                    }
                }*/
                /*
                if (br.Booking20__r != null && !br.Booking20__r.isEmpty()) 
                {
                    for (Booking__c acc : br.Booking20__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.BrokerIId__c);
                        String OldId = acc.BrokerIId__c;
                        OldId = OldId.left(15);
                        acc.BrokerIId__c = cpOldIdvsNewIdMap.get(OldId);
                        btoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.BrokerIId__c);                       
                    }
                }*/
                if (br.Leads__r != null && !br.Leads__r.isEmpty()) 
                {
                    for (Lead acc : br.Leads__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.RW_Broker__c);
                        String OldId = acc.RW_Broker__c;
                        OldId = OldId.left(15);
                        acc.RW_Broker__c = cpOldIdvsNewIdMap.get(OldId);
                        ltoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.RW_Broker__c);                       
                    }
                }
                /*
                if (br.Leads1__r != null && !br.Leads1__r.isEmpty()) 
                {
                    for (Lead acc : br.Leads1__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.Walkin_Channel_Partner__c);
                        String OldId = acc.Walkin_Channel_Partner__c;
                        OldId = OldId.left(15);
                        acc.Walkin_Channel_Partner__c = cpOldIdvsNewIdMap.get(OldId);
                        ltoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.Walkin_Channel_Partner__c);                       
                    }
                }*/
                /*
                if (br.OTPs__r != null && !br.OTPs__r.isEmpty()) 
                {
                    for (OTP__c acc : br.OTPs__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.Channel_Partner_Lookup__c);
                        String OldId = acc.Channel_Partner_Lookup__c;
                        OldId = OldId.left(15);
                        acc.Channel_Partner_Lookup__c = cpOldIdvsNewIdMap.get(OldId);
                        otptoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.Channel_Partner_Lookup__c);                       
                    }
                }*/
                /*
                if (br.Prospects__r != null && !br.Prospects__r.isEmpty()) 
                {
                    for (Prospect__c acc : br.Prospects__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.Channel_Partner__c);
                        String OldId = acc.Channel_Partner__c;
                        OldId = OldId.left(15);
                        acc.Channel_Partner__c = cpOldIdvsNewIdMap.get(OldId);
                        prostoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.Channel_Partner__c);                       
                    }
                }*/
                /*
                if (br.Tasks != null && !br.Tasks.isEmpty()) 
                {
                    for (Task acc : br.Tasks) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.WhatId);
                        String OldId = acc.WhatId;
                        OldId = OldId.left(15);
                        acc.WhatId = cpOldIdvsNewIdMap.get(OldId);
                        tsktoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.WhatId);                       
                    }
                }*/
                /*
                if (br.Opportunities__r != null && !br.Opportunities__r.isEmpty()) 
                {
                    for (Opportunity acc : br.Opportunities__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.RW_Broker__c);
                        String OldId = acc.RW_Broker__c;
                        OldId = OldId.left(15);
                        acc.RW_Broker__c = cpOldIdvsNewIdMap.get(OldId);
                        otoUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.RW_Broker__c);                       
                    }
                }*/
                /*
                if (br.Opportunities1__r != null && !br.Opportunities1__r.isEmpty()) 
                {
                    for (Opportunity acc : br.Opportunities1__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.RW_Walkin_Channel_Partner__c);
                        String OldId = acc.RW_Walkin_Channel_Partner__c;
                        OldId = OldId.left(15);
                        acc.RW_Walkin_Channel_Partner__c = cpOldIdvsNewIdMap.get(OldId);
                        o1toUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.RW_Walkin_Channel_Partner__c);                       
                    }
                }*/
                /*
                if (br.Opportunities4__r != null && !br.Opportunities4__r.isEmpty()) 
                {
                    for (Opportunity acc : br.Opportunities4__r) 
                    {
                        System.debug('Account Id: ' + acc.Id);
                        System.debug('Account Broker Id Old : ' + acc.Walk_in_Channel_Partner__c);
                        String OldId = acc.Walk_in_Channel_Partner__c;
                        OldId = OldId.left(15);
                        acc.Walk_in_Channel_Partner__c = cpOldIdvsNewIdMap.get(OldId);
                        o2toUpdate.add(acc);
                        System.debug('Account Broker Id New : ' + acc.Walk_in_Channel_Partner__c);                       
                    }
                }*/
            }
            system.debug('ltoUpdate'+ltoUpdate);
            //update acctoUpdate;
             //update btoUpdate;
             //update ltoUpdate;
             //update l1toUpdate;
            // update otptoUpdate;
             //update prostoUpdate;
            // update tsktoUpdate;
            // update otoUpdate;
            // update o1toUpdate;
            // update o2toUpdate;
            list<ERP_Integration_Log__c> erpLogList = new list<ERP_Integration_Log__c>();
            if (!ltoUpdate.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(ltoUpdate,false);
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults[i].isSuccess()) {
                        for (Database.Error error : updateResults[i].getErrors()) {                        
                            ERP_Integration_Log__c api = new ERP_Integration_Log__c();
                            api.API_Name__c = 'Full Copy';
                            api.Request__c = ltoUpdate[i].Id;
                            api.Response__c = error.getStatusCode() + ' - ' + error.getMessage();
                            erpLogList.add(api);
                        }
                    }
                }
            }
            if(!erpLogList.isEmpty()){
                Database.insert(erpLogList,false);
            }
            
        }
        catch (Exception e)
        {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            ApexPages.addMessage(errorMessage);
            system.debug('Error - '+e.getMessage());
        }  
    }
    
    public class customWrapper{
        public string OldId {get;set;}
        public string NewId {get;set;}
    }
    
   	

}