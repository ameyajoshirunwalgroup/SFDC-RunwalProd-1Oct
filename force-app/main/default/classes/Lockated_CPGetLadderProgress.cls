@RestResource(urlMapping='/cpGetLadderProgress/*')
global without sharing class Lockated_CPGetLadderProgress {
    @HttpGet
    global static void doGet() {
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
                Response response = new Response();
                response.responselist = new list<MyLadderProgress>();
                Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();//Added by Prashant 12-09-25
                
                list<Booking__c> blist = [select Id,Name,Opportunity__c,BrokerIId__c,Agreement_Value_for_brokers__c,Project__c,Tower__c,Status__c,Additional_Brokerage_Accrued_Dashboards__c,
                                          Base_Brokerage_Accrued_Dashboards__c,Project_Name__c,Unit_No__r.Name,Brokerage_Scheme__r.End_Date__c,Booking_Date__c,Payment_Received__c,Registration_date_status__c,
                                          RW_X9_99_Received__c,RW_Registration_Done__c,Brokerage_Scheme__c from Booking__c where 
                                          Project__c != null 
                                          and Status__c = 'Booking Confirmed'
                                          and  RW_Registration_Done__c = 'Yes' 
                                          and BrokerIId__c =: cpId 
                                          and Opportunity__c != null 
                                          and Exclude_From_Brokerage_Batch__c = false 
                                          and Type_of_Client__c != null 
                                          and Brokerage_Summary__c != null 
                                          and Booking_Date__c > 2022-09-29T23:01:01Z 
                                          and RW_Registration_Date__c != null 
                                          and RW_X9_99_Received__c = true 
                                          And Source_of_Booking__c = 'Channel Partner' /*and BrokerIId__c = 'a012800000sGnNs' */ 
                                          and  Brokerage_Scheme__c != null 
                                          AND BrokerIId__r.RecordTypeId =: CPRecordTypeId //Added by Prashant to Stop billing creation until cp is Registered. 12-09-25. 
                                          /*Commented this for testing.. *...*/ 
                                          AND Checklist_Approved__c = true//Added by Prashant to add checklist approved condition(billing checklist should be approved before summary creation )//17-11-2025....
                                          AND BrokerIId__r.Valid_RERA_certificate__c = true /*AND BrokerIId__r.Valid_competency_certificate__c = true*///Commented by Prashant as discussed with team to discard use of CC. 12/12/25.//Added by Prashant to update th condition to restrict billing creation for the cps who dont have valid RERA & CC.11-09-25.	
                                          ORDER BY Booking_Date__c DESC];
                Map<Id,list<Booking__c>> schemeVsBkMap = new Map<Id,list<Booking__c>>();
                if(!blist.isEmpty()){
                    for(Booking__c b : blist){
                        if (!schemeVsBkMap.containsKey(b.Brokerage_Scheme__c)) {
                            schemeVsBkMap.put(b.Brokerage_Scheme__c, new List<Booking__c>());
                        }
                        schemeVsBkMap.get(b.Brokerage_Scheme__c).add(b);
                    }
                }
                list<Brokerage_scheme__c> bschlist = [Select Id,Name,Start_Date__c,End_Date__c,Slab_Type__c,Type__c,(Select id,Name,Slab_No__c,To__c,From__c,
                                                      Total_Brokerage_for_Local_Bookings__c,Total_Brokerage_for_OS_NRI__c,Total_Brokerage_for_NRI__c,Additional_Brokerage_for_OS_NRI__c,Additional_Brokerage_for_NRI__c,Additional_Brokerage_for_Local_Bookings__c from Brokerage_Slabs__r Order by Slab_No__c) 
                                                      from Brokerage_Scheme__c where /*For Testing Id = 'a2a5j000000UcNjAAK'*/ Id In : schemeVsBkMap.keySet() ORDER BY Start_Date__c desc];
                if(!bschlist.isEmpty()){
                    for(Brokerage_scheme__c bs : bschlist){
                        Map<Id,list<Brokerage_Slab__c>> schemeVsSlabMap = new Map<Id,list<Brokerage_Slab__c>>();
                        Map<Decimal,Brokerage_Slab__c> slabNoVsDetailsMap = new Map<Decimal,Brokerage_Slab__c>();
                        MyLadderProgress mp = new MyLadderProgress();
                        // system.debug('Brokerage scheme ->>>> '+ bs.Name + ' Key -> ' +schemeVsBkMap.get(bs.Id).size());
                        //system.debug('Brokerage scheme ->>>> '+ bs.Name + ' Value -> ' +schemeVsBkMap.get(bs.Id));
                        mp.schemeName = bs.Name;
                        mp.schemeId = bs.Id;
                        mp.startDate = String.valueof(bs.Start_Date__c);
                        mp.endDate = String.valueof(bs.End_Date__c);
                        mp.slabType = bs.Slab_Type__c;
                        mp.bookingcnt = schemeVsBkMap.get(bs.Id).size();
                        mp.schemeClientType = bs.Type__c;
                        //mp.bookingcnt = 5; //For Testing...
                        Decimal totalAV = 0;
                        for(Booking__c b : schemeVsBkMap.get(bs.Id)){
                            totalAV += b.Agreement_Value_for_brokers__c;
                        }
                        mp.totalAV = totalAV;
                        mp.ladderDetails = new list<LadderDetails>();
                        for(Brokerage_Slab__c bss : bs.Brokerage_Slabs__r){
                            slabNoVsDetailsMap.put(bss.Slab_No__c,bss);
                        }
                        Integer nextSlabIndex;
                        for(Integer i = 0;i<slabNoVsDetailsMap.size();i++){
                            //Brokerage_Slab__c slab = schemeVsSlabMap.get(bss.Id);
                            Brokerage_Slab__c slab = slabNoVsDetailsMap.get(i+1);
                            LadderDetails ld = new LadderDetails();
                            ld.ladderName = slab.Name;
                            ld.ladderId = slab.Id;
                            ld.ladderFrom = String.valueof(slab.From__c);
                            ld.ladderTo = String.valueof(slab.To__c);
                            if(mp.schemeClientType == 'Local'){
                                ld.ladderBrokerage = slab.Total_Brokerage_for_Local_Bookings__c;
                            }else if(mp.schemeClientType == 'NRI'){
                                ld.ladderBrokerage = slab.Total_Brokerage_for_NRI__c;
                            }else if (mp.schemeClientType == 'Outstation'){
                                ld.ladderBrokerage = slab.Total_Brokerage_for_OS_NRI__c;
                            }else if (mp.schemeClientType == 'Both'){
                                ld.ladderBrokerage = slab.Total_Brokerage_for_Local_Bookings__c;
                            }
                            
                            if(mp.slabType == 'Count'){
                                ld.totalEarnings = (ld.ladderBrokerage * mp.totalAV)/100;
                                if(slab.From__c > mp.bookingcnt){
                                    ld.HowMuchtoReachNextSlab = (slab.From__c - mp.bookingcnt);
                                } 
                                //Assign Current Slab..
                                if(slab.From__c != null && (slab.From__c <= mp.bookingcnt && (slab.To__c >= mp.bookingcnt || slab.To__c == null))){
                                    ld.isCurrentSlab = true;
                                    //Assign Next Slab Index..
                                    if (i < slabNoVsDetailsMap.size() - 1) {
                                        nextSlabIndex = i + 1;
                                    }
                                }
                                //Assign Last Slab..
                                if (i == slabNoVsDetailsMap.size() - 1) {
                                    ld.isLastSlab = true;
                                }
                            }
                            if(mp.slabType == 'Value'){
                                ld.totalEarnings = (ld.ladderBrokerage * mp.totalAV)/100;
                                if(slab.To__c > ld.totalEarnings){
                                    ld.HowMuchtoReachNextSlab = (slab.To__c - ld.totalEarnings);
                                } 
                                //Assign Current Slab..
                                if(slab.From__c != null && (slab.From__c <= totalAV && (slab.To__c >= totalAV || slab.To__c == null))){
                                    ld.isCurrentSlab = true;
                                    //Assign Next Slab Index..
                                    if (i < slabNoVsDetailsMap.size() - 1) {
                                        nextSlabIndex = i + 1;
                                    }
                                }
                                //Assign Last Slab..
                                if (i == slabNoVsDetailsMap.size() - 1) {
                                    ld.isLastSlab = true;
                                }
                            }            
                            
                            if(ld.isCurrentSlab == true && ld.isLastSlab == true){
                                ld.isNextSlab = true;
                            }
                            
                            mp.ladderDetails.add(ld);
                        }
                        if (nextSlabIndex != null && nextSlabIndex < mp.ladderDetails.size()) {
                            mp.ladderDetails[nextSlabIndex].isNextSlab = true;
                        }
                        
                        response.responselist.add(mp);               
                    }
                }
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200;
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 500;
            }
            
        }
    }
    
    public class Response{
        public list<MyLadderProgress> responselist;
    }
    
    public class MyLadderProgress{
        public String schemeName;
        public String schemeId;
        public String schemeClientType;
        public String startDate;
        public String endDate;
        public String slabType;
        public Integer bookingcnt;
        public Decimal totalAV;
        public list<LadderDetails> ladderDetails;
        //public list<LadderProgressDetails> ladderProgressDetails;
    }
    
    public class LadderDetails{
        public String ladderName;
        public String ladderId;
        public String ladderFrom;
        public String ladderTo;
        public Decimal ladderBrokerage;  
        public Decimal totalEarnings;
        public Decimal HowMuchtoReachNextSlab = 0;
        public Boolean isCurrentSlab = false;
        public Boolean isNextSlab = false;
        public Boolean isLastSlab = false;
        public String toNextSlab;
        //public String ladderType;
    }
    
    public class LadderProgressDetails{
        public String ladderType;
        public Integer toNextSlab;
        public Decimal earnings;
        public String ladderName;
        public String ladderId;
    }    
        
}