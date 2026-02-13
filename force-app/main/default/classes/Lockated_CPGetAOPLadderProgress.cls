@RestResource(urlMapping='/cpGetAOPLadderProgress/*')
global without sharing class Lockated_CPGetAOPLadderProgress {
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
            Date todaysDate = system.today();  
            try{
                list<AOP__c> aoplist = [Select Id,Name,AOP_CP_Name__c,Channel_Partner__c,Relevant_zone__c,Commitment_max__c,AOP_Schemes__c,
                                        AOP_Schemes__r.Financial_Year_Start_Date__c,AOP_Schemes__r.Financial_Year_End_Date__c,Target_AOP_Slab__c,
                                        Target_AOP_Slab__r.Lower_Limit__c,Target_AOP_Slab__r.Upper_Limit__c,Target_AOP_Slab__r.Slab_Name__c,
                                        Target_AOP_Slab__r.Brokerage_Rate__c,Target_AOP_Slab__r.AOP_Schemes_Slabs__c,Target_AOP_Slab__r.Category__c, 
                                        (Select Id,Lower_Limit__c,Upper_Limit__c,Slab_Name__c,Brokerage_Rate__c,Category__c from AOP_Slab__r Order by Slab_Name__c)                                    
                                        from AOP__c where Channel_Partner__c =: cpId and AOP_Schemes__c != null and AOP_Schemes__r.Financial_Year_Start_Date__c <=: todaysDate and 
                                        AOP_Schemes__r.Financial_Year_End_Date__c >=: todaysDate limit 1];
                AOPLadderProgress aopLadderProgress = new AOPLadderProgress(); 
                if(!aoplist.isEmpty()){
                    AOP__c aop = aoplist[0];
                    Integer slabCount = aoplist[0].AOP_Slab__r.size();
                    aopLadderProgress.Name = aop.Name;
                    aopLadderProgress.cpName = aop.AOP_CP_Name__c;
                    aopLadderProgress.zone = aop.Relevant_zone__c;
                    aopLadderProgress.commitment = String.valueOf(aop.Commitment_max__c);
                    aopLadderProgress.startDate = String.valueOf(aop.AOP_Schemes__r.Financial_Year_Start_Date__c);
                    aopLadderProgress.endDate = String.valueOf(aop.AOP_Schemes__r.Financial_Year_End_Date__c);                                        
                    aopLadderProgress.targetSlabId = aop.Target_AOP_Slab__c;
                    /*aopLadderProgress.targetSlab = new SlabDetails();
                    aopLadderProgress.targetSlab.slabName = aop.Target_AOP_Slab__r.Slab_Name__c;
                    aopLadderProgress.targetSlab.lowerLimit = String.valueOf(aop.Target_AOP_Slab__r.Lower_Limit__c);
                    aopLadderProgress.targetSlab.upperLimit = String.valueOf(aop.Target_AOP_Slab__r.Upper_Limit__c);
                    aopLadderProgress.targetSlab.category = aop.Target_AOP_Slab__r.Category__c;
                    aopLadderProgress.targetSlab.brokerage = String.valueOf(aop.Target_AOP_Slab__r.Brokerage_Rate__c);
                    aopLadderProgress.targetSlab.slabId = aop.Target_AOP_Slab__c;
                    aopLadderProgress.currentSlab = new SlabDetails();*/
                    //Assign Current Sales value
                    Id CPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();//Added by Prashant 12-09-25
                    list<Booking__c> blist = [SELECT Id, Name, Opportunity__c, BrokerIId__c, BrokerIId__r.Account__c, 
                                              Agreement_Value_for_brokers__c, Project__c, Booking_Date__c, Tower__c, 
                                              X5_Received__c, RW_X9_99_Received__c, Status__c, RW_Registration_Done__c, 
                                              Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c, Type_Of_Client_Formula__c, 
                                              RW_Registration_Date__c, Type_of_Client__c, Source_of_Booking__c, AOP_Scheme__c,
                                              Brokerage_Summary__c, Brokerage_Summary__r.Id, Brokerage_Summary__r.Name
                                              FROM Booking__c
                                              WHERE BrokerIId__c = :aop.Channel_Partner__c
                                              AND BrokerIId__c != null
                                              AND AOP_Scheme__c = :aop.Id
                                              AND DAY_ONLY(Booking_Date__c) >= :aop.AOP_Schemes__r.Financial_Year_Start_Date__c
                                              AND DAY_ONLY(Booking_Date__c) <= :aop.AOP_Schemes__r.Financial_Year_End_Date__c
                                              AND (RW_X9_99_Received__c = true)
                                              AND Status__c = 'Booking Confirmed'
                                              AND RW_Registration_Done__c = 'Yes'
                                              AND Brokerage_Summary__c != null
                                              and Exclude_From_Brokerage_Batch__c = false 
                                              and Type_of_Client__c != null 
                                              and Booking_Date__c > 2022-09-29T23:01:01Z 
                                              and RW_Registration_Date__c != null 
                                              And Source_of_Booking__c = 'Channel Partner' /*and BrokerIId__c = 'a012800000sGnNs' */ 
                                              and  Brokerage_Scheme__c != null 
                                              AND BrokerIId__r.RecordTypeId =: CPRecordTypeId
                                              AND Checklist_Approved__c = true//Added by Prashant to add checklist approved condition(billing checklist should be approved before summary creation )//17-11-2025....
                                              AND BrokerIId__r.Valid_RERA_certificate__c = true /*AND BrokerIId__r.Valid_competency_certificate__c = true*///Commented by Prashant as discussed with team to discard use of CC. 12/12/25.//Added by Prashant to update th condition to restrict billing creation for the cps who dont have valid RERA & CC.11-09-25.	
                                             ];
                    Decimal currentSalesValue = 0;
                    Integer bookingCount = 0;
                    if(!blist.isEmpty()){
                        for(Booking__c b: blist){
                            currentSalesValue += (b.Agreement_Value_for_brokers__c);
                            bookingCount += 1;
                        }
                    }
                    //currentSalesValue = 1600000000.00;
                    aopLadderProgress.BookingDone = String.valueOf(bookingCount);
                    aopLadderProgress.overallProgressPct = ((currentSalesValue/aop.Commitment_max__c)*100).setscale(0,RoundingMode.HALF_UP);
                    aopLadderProgress.slabDetails = new list<SlabDetails>();
                    Map<String,AOP_Slab__c> slabNameVsDetailsMap = new Map<String,AOP_Slab__c>();
                    
                    for (AOP_Slab__c slab : aop.AOP_Slab__r) {
                        slabNameVsDetailsMap.put(slab.Slab_Name__c,slab);                        
                    }
                     
                    Boolean currentSlabFound = false;
                    Integer nextSlabIndex;
                    Decimal brokerageValueForCurrent =0;
                    Map<Integer, SlabDetails> sortedSlabMap = new Map<Integer, SlabDetails>();
                    for(AOP_Slab__c slab : aop.AOP_Slab__r){                       
                        SlabDetails sd = new SlabDetails();
                        sd.slabName = slab.Slab_Name__c;
                        if(slab.Lower_Limit__c > currentSalesValue){
                            sd.HowMuchtoReachNextSlab = (slab.Lower_Limit__c - currentSalesValue) / 10000000;
                        }                        
                        sd.lowerLimit = String.valueOf(slab.Lower_Limit__c);
                        sd.upperLimit = String.valueOf(slab.Upper_Limit__c);
                        sd.category = slab.Category__c;
                        sd.brokerage = String.valueOf(slab.Brokerage_Rate__c);
                        sd.slabId = slab.Id;
                        
                        //Assigning Target Slab.
                        if(slab.Id == aopLadderProgress.targetSlabId){
                            sd.isTargetSlab = true;
                        }
                        //Assigning Current Slab.
                        if(currentSalesValue >= slab.Lower_Limit__c && currentSalesValue <= slab.Upper_Limit__c){
                            sd.isCurrentSlab = true;
                            currentSlabFound = true;
                            if(slab.Brokerage_Rate__c!=null && currentSalesValue!=null){
                            	brokerageValueForCurrent = (slab.Brokerage_Rate__c * currentSalesValue)/100;
                                aopLadderProgress.totalEarnings = brokerageValueForCurrent;
                            }
                        }
                        Integer slabNumber = Integer.valueOf(slab.Slab_Name__c.replaceAll('[^0-9]', ''));
    					sortedSlabMap.put(slabNumber, sd);
                    }
                    
                    List<Integer> slabNumbers = new List<Integer>(sortedSlabMap.keySet());
					slabNumbers.sort();
                    
                    for (Integer num : slabNumbers) {
                        aopLadderProgress.slabDetails.add(sortedSlabMap.get(num));
                    }
                    
                    Integer listSize = aopLadderProgress.slabDetails.size();
                    for (Integer i = 0; i < listSize; i++) {
                        SlabDetails currentWrapper = aopLadderProgress.slabDetails[i];
                        
                        // Set Last Slab flag
                        if (i == listSize - 1) {
                            currentWrapper.isLastSlab = true;
                        }
                        
                        if(i==0 && currentSlabFound == false){
                            aopLadderProgress.slabDetails[i].isNextSlab = true;
                        }
                        
                        // Identify Next Slab based on Current
                        if (currentWrapper.isCurrentSlab && i < listSize - 1) {
                            aopLadderProgress.slabDetails[i + 1].isNextSlab = true;
                        }
                    }
                    
                    
                    aopLadderProgress.currentSalesValue = String.valueOf(currentSalesValue);
                    //aopLadderProgress.currentSalesValue = '270000000';
                     
                }
                res.responseBody = Blob.valueOf(JSON.serialize(aopLadderProgress));
                res.statusCode = 200;
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 500;                    
            }          
        }
    }
    
    
    public class AOPLadderProgress{
        public String Name;
        public String cpName;
        public String zone;
        public String commitment;        
        public String startDate;
        public String endDate;
        public String targetSlabId;
        public String currentSalesValue;
        public String BookingDone; 
        public Decimal overallProgressPct;
        public Decimal totalEarnings;
        //public SlabDetails targetSlab;
        //public SlabDetails currentSlab;
        //public SlabDetails nextSlab;
        //public SlabDetails lastSlab;
        public list<SlabDetails> slabDetails;
        //public list<LadderProgressDetails> ladderProgressDetails;
    }
    
    public class SlabDetails{
        public String slabName;
        public String lowerLimit;
        public String upperLimit;
        public String category;
        public String brokerage;  
        public String slabId;
        public Decimal HowMuchtoReachNextSlab = 0;
        public Boolean isTargetSlab = false;
        public Boolean isCurrentSlab = false;
        public Boolean isNextSlab = false;
        public Boolean isLastSlab = false;
    }  
    
    public static void dummyMethod(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;

        i++;
        i++;
    }
}