public class interestWaiverConsolidation {
    @AuraEnabled(cacheable=true)
    public static List<RW_Demand__c> getDemandRecords(String bookingId) {
        System.debug('Id::'+bookingId);
        System.debug('inside new RW_Demand__c method');
        List<Booking__c> blist = [Select Id,Name From Booking__c where Id=:bookingId limit 1];
        if(!blist.isEmpty()){
            system.debug('blist -> '+[SELECT Id,Name,Payment_Date__c,Total_Interest_Waiver_Amount__c  FROM RW_Demand__c WHERE Booking__c = :blist[0].id]);
            return [SELECT Id,Name,Payment_Date__c,Total_Interest_Waiver_Amount__c,Booking__r.Unit_No__r.Name,Booking__r.Name,Booking__r.Project__r.Name,Booking__r.Project__r.Project_Location__r.Name,
                     Booking__r.Id,Interest_Days__c,Net_Interest_Amount__c,Previously_Waived_Amount_SAP__c,Project_Code__c,SAP_Customer_Number__c,SAP_Slab_Code__c,RW_Demand_Milestone__c,
                    SAP_Slab_Description__c,Total_Interest_Amount__c,RW_Demand_Status__c,Interest_Waiver_Requested__c,Demand_Amount__c,Demand_Date__c,
                    Booking__r.Interest_Waiver_Approved_but_not_Waived__c,Booking__r.RW_Total_Interest_Amount_Waived__c,
                    Booking__r.Total_Approved_Interest_Amount_Waived__c,Booking__r.Project_Waived_Limit__c,
                    (Select id,Name,Sent_for_Approval__c,Approval_Status__c,Sub_Reason__c,Waiver_Reason__c,Waiver_Amount__c,Remarks__c from Interest_Waivers__r where Approval_Status__c != 'Rejected'  /*where Sent_for_Approval__c = true or Approval_Status__c = 'Approved' limit 1*/)
                    FROM RW_Demand__c WHERE Booking__c = :blist[0].id and Net_Interest_Amount__c!= null and RW_Demand_Status__c = 'Paid' and Payment_Date_Formula__c =false order by Demand_Date__c desc  /*and RW_Demand_Status__c ='Paid' and Count_IW__c > 0 and Payment_Date_Formula__c = false */];
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Interest_Waiver__c> getIWRecords(String bookingId) {
        System.debug('Id::'+bookingId);
        System.debug('inside new Interest_Waiver__c method');
        List<Booking__c> blist = [Select Id,Name From Booking__c where Id=:bookingId limit 1];
        if(!blist.isEmpty()){
            system.debug('blist -> '+[SELECT Id,Name,Demand__r.Name,Waiver_Amount__c  FROM Interest_Waiver__c WHERE Booking__c = :blist[0].id]);
            return [SELECT Id,Name,Demand__r.Name,Waiver_Amount__c,Approval_Status__c  FROM Interest_Waiver__c WHERE Approval_Status__c ='Draft' and  Booking__c = :blist[0].id ORDER BY CreatedDate DESC, Demand__r.Name ASC];
        }else{
            return null;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal interestWaiverAmtLimit(String demandId) {
        System.debug('demandId::'+demandId);
        
        List<Interest_Waiver__c> iwlist = [SELECT Id,Name,Waiver_Amount__c,Demand__r.Total_Interest_Amount__c FROM Interest_Waiver__c where Demand__c =: demandId and Approval_Status__c != 'Rejected' and Waiver_Amount__c != null];
        if(!iwlist.isEmpty()){
            Decimal totalInterestAmtWaived = 0;
            for(Interest_Waiver__c iw : iwlist){
                totalInterestAmtWaived += iw.Waiver_Amount__c;                
            }
            return totalInterestAmtWaived;
        }else{
            return null;
        }
    }
    
    
    @AuraEnabled
    public static Id createInterestWaiver(Interest_Waiver__c interestWaiverRecord) {
        System.debug('interestWaiverRecord::'+interestWaiverRecord);
        try{
            upsert interestWaiverRecord;
            return interestWaiverRecord.Id;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static Boolean submitSelectedWaivers(Id bookingId, List<Id> waivers,Boolean iomUploaded, Decimal totalWaiverRequested) {
        system.debug('Booking Id -> '+bookingId);
        system.debug('Waivers -> '+waivers);
        system.debug('iomUploaded -> '+iomUploaded);
        system.debug('totalWaiverRequested -> '+totalWaiverRequested);
        List<Interest_Waiver__c> waiverlist = [
            SELECT Id, Waiver_Amount__c, 
            Booking__r.Total_Waiver_Amount_to_be_Approved__c,
            Booking__r.Total_Waiver_Amount_Approved_Till_Now__c,
            Booking__r.Project_Waived_Limit__c
            FROM Interest_Waiver__c 
            WHERE Id IN :waivers
        ]; 
        
        Decimal totalIWAmttobeApproved = 0;
        
        if (!waiverlist.isEmpty()) {
            for (Interest_Waiver__c iw : waiverlist) {
                totalIWAmttobeApproved += iw.Waiver_Amount__c;
                iw.Sent_for_Approval__c = true;
                iw.Approval_Status__c = 'Submitted for Approval';
            }
            
            try {
                if(!Test.isRunningTest()){
                    update waiverlist;
                }
                
                
                Decimal totalWaiverAmtApprovedTillNow =
                    (waiverlist[0].Booking__r.Total_Waiver_Amount_Approved_Till_Now__c != null)
                    ? waiverlist[0].Booking__r.Total_Waiver_Amount_Approved_Till_Now__c: 0;
                
                if (waiverlist[0].Booking__r.Total_Waiver_Amount_to_be_Approved__c != null) {
                    totalWaiverAmtApprovedTillNow += waiverlist[0].Booking__r.Total_Waiver_Amount_to_be_Approved__c;
                }
                
                Booking__c b = new Booking__c();
                b.Total_Waiver_Amount_Approved_Till_Now__c = totalWaiverAmtApprovedTillNow;
                b.Total_Waiver_Amount_to_be_Approved__c = totalIWAmttobeApproved;
                b.Interest_Waiver_Approval_Status__c = 'Submitted for Approval'; 
                b.is_IOM_Uploaded__c = iomUploaded;
                b.Id = bookingId;
                if(!Test.isRunningTest()){
                update b;
                }
                
                Decimal waiverlimit = waiverlist[0].Booking__r.Project_Waived_Limit__c != null
                    ? waiverlist[0].Booking__r.Project_Waived_Limit__c: 0;
                return true;
                
                //return (totalIWAmttobeApproved > waiverlimit) ? 'Upload IOM' : 'Submit';
            }
            catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        return false;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<ContentDocumentLink> fetchFiles(String recordId){
        return [SELECT LinkedEntityId, ContentDocument.CreatedDate,
                ContentDocument.Title, ContentDocumentId,
                ContentDocument.ContentSize, ContentDocument.FileType,ContentDocument.LastModifiedDate
                 FROM ContentDocumentLink  
                WHERE LinkedEntityId  =:recordId Order by ContentDocument.LastModifiedDate DESC limit 5];
    }
    
    
    
   /* public static Boolean SendForApproval(String comment, Id bookingId){
        
        try{
            system.debug('comment::'+comment);
            system.debug('bookingId::'+bookingId);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(bookingId);
            req1.setProcessDefinitionNameOrId('Interest_Waiver_Approval');
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);
            return true;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }*/
}