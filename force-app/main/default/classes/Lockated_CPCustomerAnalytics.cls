@RestResource(urlMapping='/cpCustomerAnalytics/*')
global without sharing class Lockated_CPCustomerAnalytics {
    @HttpGet
    global static void doGet()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String cpId = req.params.get('cpId');
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(cpId)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                ResponseWrapper resp = new ResponseWrapper();
                resp.zoneWiseDetails = new list<Details>();
                list<Broker__c> brs = [Select Id,RecordTypeId from Broker__c where Id =: cpId limit 1];  
                Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
                Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();
                
                if(!brs.isEmpty()){
                    //Inside Registered CP
                    if(brs[0].RecordTypeId == CPRecordTypeId){
                        list<Opportunity> olist = [Select id,Budget_In_Cr__c,Zone__c,Unit_No__r.Type__c,Unit_No__c,CreatedDate from Opportunity  where
                                                   (Walkin_Source__c = 'Channel Partner' or LeadSource = 'Channel Partner') and
                                                   (RW_Walkin_Channel_Partner__c =: cpId or RW_Broker__c =: cpId) and 
                                                   StageName != 'Cancelled' and Zone__c != null  and Booking__c =null ];
                        list<Booking__c> blist = [Select id,Opportunity__r.Account.Zone__c,Unit_No__r.Type__c,Unit_No__c,CreatedDate from Booking__c where Source_of_Booking__c = 'Channel Partner' and BrokerIId__c =: cpId and Status__c = 'Booking Confirmed' and Opportunity__r.Account.Zone__c != null];
                        // This handles different Fiscal Year start months automatically
            			Date startOfLastFY = getStartOfLastTwoFiscalYears();
                        Map<String, Boolean> zoneActiveStatusMap = new Map<String, Boolean>();
                        if(!olist.isEmpty() && !blist.isEmpty()){
                            Map<String,list<Opportunity>> zoneVsOppMap = new Map<String,list<Opportunity>>();
                            // Maps to calculate "All Zones" typology
						    Map<String, Integer> globalTypologyCountMap = new Map<String, Integer>();
                            Set<String> uniqueZones = new Set<String>();                           
                            for (Opportunity o : olist) {
                                uniqueZones.add(o.Zone__c);
                                if(!zoneVsOppMap.containsKey(o.Zone__c)){
                                    zoneVsOppMap.put(o.Zone__c,new list<Opportunity>());
                                }
                                system.debug('Zone__c - > '+o.Zone__c);
                                zoneVsOppMap.get(o.Zone__c).add(o);  
                                // GLOBAL AGGREGATION FOR "ALL ZONES"
                                String typo = o.Unit_No__c != null ? o.Unit_No__r.Type__c != null ? o.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                if(!globalTypologyCountMap.containsKey(typo)){
                                    globalTypologyCountMap.put(typo, 0);
                                }
                                globalTypologyCountMap.put(typo, globalTypologyCountMap.get(typo) + 1);
                                // Track "Yes" if CreatedDate is in current or previous FY
                                if(!zoneActiveStatusMap.containsKey(o.Zone__c)) zoneActiveStatusMap.put(o.Zone__c, false);
                                if(o.CreatedDate >= startOfLastFY) zoneActiveStatusMap.put(o.Zone__c, true);
                            }
                            Map<String,list<Booking__c>> zoneVsBkMap = new Map<String,list<Booking__c>>();  
                            for(Booking__c b : blist){
                                uniqueZones.add(b.Opportunity__r.Account.Zone__c);
                                if(!zoneVsBkMap.containsKey(b.Opportunity__r.Account.Zone__c)){
                                    zoneVsBkMap.put(b.Opportunity__r.Account.Zone__c,new list<Booking__c>());
                                }
                                zoneVsBkMap.get(b.Opportunity__r.Account.Zone__c).add(b);  
                                // GLOBAL AGGREGATION FOR "ALL ZONES"
                                String typo = b.Unit_No__c != null ? b.Unit_No__r.Type__c != null ? b.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                if(!globalTypologyCountMap.containsKey(typo)){
                                    globalTypologyCountMap.put(typo, 0);
                                }
                                globalTypologyCountMap.put(typo, globalTypologyCountMap.get(typo) + 1);
                                String zone = b.Opportunity__r.Account.Zone__c;
                                if(!zoneActiveStatusMap.containsKey(zone)) zoneActiveStatusMap.put(zone, false);
                				if(b.CreatedDate >= startOfLastFY) zoneActiveStatusMap.put(zone, true);
                            }
                            resp.zones = new list<String>();
                            resp.zones.add('All Zones');
                            Decimal ClientBudgetForAll = 0;
                            Details allZoneDetails = new Details();
                            allZoneDetails.zoneName = 'All Zones';
                            allZoneDetails.typlogydistribution = new List<Map<String, Integer>>();
                            Integer yesCount = 0;
                            for(String zone : uniqueZones){                                
                                resp.zones.add(zone);
                                Details d = new Details();
                                d.zoneName = zone;
                                Boolean isActive = zoneActiveStatusMap.get(zone);
                                d.activeZones = isActive ? 'Yes' : 'No';
                                if(isActive) yesCount++;
                                d.typlogydistribution = new List<Map<String, Integer>>();
                                Map<String, Integer> localTypologyMap = new Map<String, Integer>();
                                Decimal ClientBudget = 0;
                                if(zoneVsOppMap.get(zone) != null){
                                    for(Opportunity opp : zoneVsOppMap.get(zone)){
                                        d.totalWalkIns += 1;
                                        allZoneDetails.totalWalkIns +=1;
                                        if(opp.Budget_In_Cr__c!=null){
                                            ClientBudget += opp.Budget_In_Cr__c;
                                            ClientBudgetForAll += opp.Budget_In_Cr__c;
                                        }
                                        // Typology Count for THIS Zone
                                        String t = opp.Unit_No__c != null ? opp.Unit_No__r.Type__c != null ? opp.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                        if(!localTypologyMap.containsKey(t)){
                                            localTypologyMap.put(t, 0);
                                        }
                                        localTypologyMap.put(t, localTypologyMap.get(t) + 1);
                                    }
                                }
                                
                                if(d.totalWalkIns != 0){
                                    d.avgClientBudget = (ClientBudget / d.totalWalkIns).setScale(0, RoundingMode.HALF_UP);
                                }  
                                if(zoneVsBkMap.get(zone) != null){
                                    for(Booking__c bk : zoneVsBkMap.get(zone)){
                                        d.totalBookings += 1;
                                        allZoneDetails.totalBookings +=1;
                                        
                                        // Typology Count for THIS Zone
                                        String t = bk.Unit_No__c != null ? bk.Unit_No__r.Type__c != null ? bk.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                        if(!localTypologyMap.containsKey(t)){
                                            localTypologyMap.put(t, 0);
                                        }
                                        localTypologyMap.put(t, localTypologyMap.get(t) + 1);
                                    }
                                }
                                // Convert Map to List<Map<String, Integer>> format for JSON
                                d.totalUnit = 0;
                                for(String key : localTypologyMap.keySet()){
                                    Map<String, Integer> singleTypo = new Map<String, Integer>();
                                    singleTypo.put(key, localTypologyMap.get(key));
                                    d.typlogydistribution.add(singleTypo);
                                    d.totalUnit += localTypologyMap.get(key); // Sum up units
                                }
                                // Add to All Zones Total Unit
                                allZoneDetails.totalUnit += d.totalUnit;
                                //d.activeZones = true;
                                
                                resp.zoneWiseDetails.add(d);
                            }
                            allZoneDetails.activeZones = String.valueOf(yesCount);
                            if(allZoneDetails.totalWalkIns!= 0){
                                allZoneDetails.avgClientBudget = (ClientBudgetForAll / allZoneDetails.totalWalkIns).setScale(0, RoundingMode.HALF_UP);
                            }
                            
                            // Convert Global Typology Map to List format
                            for(String key : globalTypologyCountMap.keySet()){
                                Map<String, Integer> singleTypo = new Map<String, Integer>();
                                singleTypo.put(key, globalTypologyCountMap.get(key));
                                allZoneDetails.typlogydistribution.add(singleTypo);
                            }
                            
                            resp.zoneWiseDetails.add(allZoneDetails);
                            
                            res.responseBody = Blob.valueOf(JSON.serialize(resp));
                            res.statusCode = 200;
                        }else{
                            errorResult.put('status', 'error');
                            errorResult.put('message', 'No Records Found with this Registered CP');
                            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                            res.statusCode = 400;
                        }
                        
                    }
                    //Inside Temp CP
                    if(brs[0].RecordTypeId == TempCPRecordTypeId){
                         list<Opportunity> olist = [Select id,Budget_In_Cr__c,Zone__c,Unit_No__r.Type__c,Unit_No__c  from Opportunity  where
                                                   (Walkin_Source__c = 'Temp Channel Partner' or LeadSource = 'Temp Channel Partner') and
                                                   (RW_Walkin_Channel_Partner__c =: cpId or RW_Broker__c =: cpId) and 
                                                   StageName != 'Cancelled' and Zone__c != null  and Booking__c =null ];
                        list<Booking__c> blist = [Select id,Opportunity__r.Account.Zone__c,Unit_No__c, Unit_No__r.Type__c from Booking__c where Source_of_Booking__c = 'Temp Channel Partner' and BrokerIId__c =: cpId and Opportunity__r.Account.Zone__c != null];
                        if(!olist.isEmpty() && !blist.isEmpty()){
                            Map<String,list<Opportunity>> zoneVsOppMap = new Map<String,list<Opportunity>>();
                            // Maps to calculate "All Zones" typology
						    Map<String, Integer> globalTypologyCountMap = new Map<String, Integer>();
                            Set<String> uniqueZones = new Set<String>();                           
                            for (Opportunity o : olist) {
                                uniqueZones.add(o.Zone__c);
                                if(!zoneVsOppMap.containsKey(o.Zone__c)){
                                    zoneVsOppMap.put(o.Zone__c,new list<Opportunity>());
                                }
                                system.debug('Zone__c - > '+o.Zone__c);
                                zoneVsOppMap.get(o.Zone__c).add(o);    
                                // GLOBAL AGGREGATION FOR "ALL ZONES"
                                String typo = o.Unit_No__c != null ? o.Unit_No__r.Type__c != null ? o.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                if(!globalTypologyCountMap.containsKey(typo)){
                                    globalTypologyCountMap.put(typo, 0);
                                }
                                globalTypologyCountMap.put(typo, globalTypologyCountMap.get(typo) + 1);
                            }
                            Map<String,list<Booking__c>> zoneVsBkMap = new Map<String,list<Booking__c>>();  
                            for(Booking__c b : blist){
                                system.debug('blist'+blist);
                                system.debug('blist'+b);
                                //system.debug('Unit_No__r.Type__c'+b.Unit_No__r.Type__c);
                                uniqueZones.add(b.Opportunity__r.Account.Zone__c);
                                if(!zoneVsBkMap.containsKey(b.Opportunity__r.Account.Zone__c)){
                                    zoneVsBkMap.put(b.Opportunity__r.Account.Zone__c,new list<Booking__c>());
                                }
                                zoneVsBkMap.get(b.Opportunity__r.Account.Zone__c).add(b);
                                // GLOBAL AGGREGATION FOR "ALL ZONES"
                                //system.debug('Unit_No__r.Type__c'+b.Unit_No__r.Type__c);
                                String typo = b.Unit_No__c != null ? b.Unit_No__r.Type__c != null ? b.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                if(!globalTypologyCountMap.containsKey(typo)){
                                    globalTypologyCountMap.put(typo, 0);
                                }
                                globalTypologyCountMap.put(typo, globalTypologyCountMap.get(typo) + 1);
                            }
                            resp.zones = new list<String>();
                            resp.zones.add('All Zones');
                            Decimal ClientBudgetForAll = 0;
                            Details allZoneDetails = new Details();
                            allZoneDetails.zoneName = 'All Zones';
                            allZoneDetails.typlogydistribution = new List<Map<String, Integer>>();
                            for(String zone : uniqueZones){
                                resp.zones.add(zone);
                                Details d = new Details();
                                d.typlogydistribution = new List<Map<String, Integer>>();
                            	Map<String, Integer> localTypologyMap = new Map<String, Integer>();
                                d.zoneName = zone;
                                Decimal ClientBudget = 0;
                                for(Opportunity opp : zoneVsOppMap.get(zone)){
                                    d.totalWalkIns += 1;
                                    allZoneDetails.totalWalkIns +=1;
                                    if(opp.Budget_In_Cr__c!=null){
                                        ClientBudget += opp.Budget_In_Cr__c;
                                        ClientBudgetForAll += opp.Budget_In_Cr__c;
                                    }
                                    
                                    // Typology Count for THIS Zone
                                    String t = opp.Unit_No__c != null ? opp.Unit_No__r.Type__c != null ? opp.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                    if(!localTypologyMap.containsKey(t)){
                                        localTypologyMap.put(t, 0);
                                    }
                                    localTypologyMap.put(t, localTypologyMap.get(t) + 1);
                                }
                                d.avgClientBudget = (ClientBudget / d.totalWalkIns).setScale(0, RoundingMode.HALF_UP);
                                for(Booking__c bk : zoneVsBkMap.get(zone)){
                                    d.totalBookings += 1;
                                    allZoneDetails.totalBookings +=1;
                                    
                                    // Typology Count for THIS Zone
                                    String t = bk.Unit_No__c != null ? bk.Unit_No__r.Type__c != null ? bk.Unit_No__r.Type__c : 'Unknown' : 'Unknown';
                                    if(!localTypologyMap.containsKey(t)){
                                        localTypologyMap.put(t, 0);
                                    }
                                    localTypologyMap.put(t, localTypologyMap.get(t) + 1);
                                }
                                
                                // Convert Map to List<Map<String, Integer>> format for JSON
                                d.totalUnit = 0;
                                for(String key : localTypologyMap.keySet()){
                                    Map<String, Integer> singleTypo = new Map<String, Integer>();
                                    singleTypo.put(key, localTypologyMap.get(key));
                                    d.typlogydistribution.add(singleTypo);
                                    d.totalUnit += localTypologyMap.get(key); // Sum up units
                                }
                                // Add to All Zones Total Unit
                                allZoneDetails.totalUnit += d.totalUnit;
                                
                                resp.zoneWiseDetails.add(d);
                            }
                            
                            if(allZoneDetails.totalWalkIns!= 0){
                                allZoneDetails.avgClientBudget = (ClientBudgetForAll / allZoneDetails.totalWalkIns).setScale(0, RoundingMode.HALF_UP);
                            }
                            
                            
                            resp.zoneWiseDetails.add(allZoneDetails);
                            
                            res.responseBody = Blob.valueOf(JSON.serialize(resp));
                            res.statusCode = 200;
                        }else{
                            errorResult.put('status', 'error');
                            errorResult.put('message', 'No Records Found with this Registered CP');
                            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                            res.statusCode = 400;
                        }
                    }
                }                
                else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'No CP Record Found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400;
                }            
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
        }
    }   
    
    private static Date getStartOfLastTwoFiscalYears() {
        Organization org = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization LIMIT 1];
        Integer startMonth = org.FiscalYearStartMonth;
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        
        Integer currentFYStartYear;
        if (currentMonth >= startMonth) {
            currentFYStartYear = currentYear;
        } else {
            currentFYStartYear = currentYear - 1;
        }
        
        // Return the start of the PREVIOUS Financial Year (Total 2 FYs)
        return Date.newInstance(currentFYStartYear - 1, startMonth, 1);
    }
    
    global class ResponseWrapper {
        public list<String> zones;
        public list<Details> zoneWiseDetails;  
    }
    
    public class Details{
        public String zoneName;
        public Integer totalWalkIns = 0;
        public Integer totalBookings = 0;
        public Decimal avgClientBudget = 0;
        public String activeZones;//??
        
            // New Fields
        public Integer totalUnit = 0;
        public List<Map<String, Integer>> typlogydistribution;
    }
}