public class CurrentPreviousMilestoneUpdateOnBooking {  
   
    
    @AuraEnabled
    public static MilestoneDetails updateMilestoneDetails(Id bookingId){
        List<RW_Demand__c> demands = [SELECT Id,Demand_Amount__c,RW_Total_Demand_Amount__c,RW_Total_GST_Amount__c,Remaining_Amount__c,Total_Demand_Paid__c,Booking__r.GST_Percent__c,Booking__r.GST_Current_Milestone__c,Booking__r.Principal_Current_Milestone__c,Booking__r.Principal_Previous_Milestone__c,Booking__r.GST_Previous_Milestone__c,Booking__r.RW_Total_TDS_Outstanding__c,Booking__r.Billed_Principal_Amount__c,Booking__r.Billed_GST_Amount__c,Booking__r.Total_Principal_with_GST__c FROM RW_Demand__c WHERE RW_Demand_Status__c = 'Due' AND Booking__c =: bookingId ORDER By CreatedDate DESC];
        MilestoneDetails details = new MilestoneDetails();
        System.debug('demands: ' + demands.size());
        if(demands.size() > 0){
            System.debug('demands[0]: ' + demands[0]);
            if(demands[0].Total_Demand_Paid__c == 0){
                details.current_principal = demands[0].RW_Total_Demand_Amount__c;
                details.current_gst = demands[0].RW_Total_GST_Amount__c;
            }else{
                details.current_gst = demands[0].Remaining_Amount__c * demands[0].Booking__r.GST_Percent__c / 100;
                details.current_principal = demands[0].Remaining_Amount__c - details.current_gst;
            }
            System.debug('details.current_principal: ' + details.current_principal);
            System.debug('details.current_gst: ' + details.current_gst);
            Decimal previousPrincipal = 0;
            Decimal previousGST = 0;
            for(Integer i=1;i<demands.size()-2;i++){
                if(demands[i].Total_Demand_Paid__c == 0){
                    previousPrincipal += demands[i].RW_Total_Demand_Amount__c;
                    previousGST += demands[i].RW_Total_GST_Amount__c;
                }else{
                    previousGST += demands[i].Remaining_Amount__c * demands[i].Booking__r.GST_Percent__c / 100;
                    previousPrincipal += demands[i].Remaining_Amount__c - previousGST;
                }
            }
            details.previous_principal = previousPrincipal;
            details.previous_gst = previousGST;
            details.tds_outstanding = demands[0].Booking__r.RW_Total_TDS_Outstanding__c;
            details.billed_principal = details.previous_principal + details.current_principal;
            details.billed_gst = details.previous_gst + details.current_gst;
            details.total_amount = details.billed_principal + details.billed_gst;
            
            
            Boolean updateBooking = false;
            Booking__c bkg = new Booking__c();
            bkg.Id = bookingId;
            if(demands[0].Booking__r.Principal_Current_Milestone__c != details.current_principal){
                bkg.Principal_Current_Milestone__c = details.current_principal;
                updateBooking = true;
            }
            if(demands[0].Booking__r.GST_Current_Milestone__c != details.current_gst){
                bkg.GST_Current_Milestone__c = details.current_gst;
                updateBooking = true;
            }
            if(demands[0].Booking__r.Principal_Previous_Milestone__c != details.previous_principal){
                bkg.Principal_Previous_Milestone__c = details.previous_principal;
                updateBooking = true;
            }
            if(demands[0].Booking__r.GST_Previous_Milestone__c != details.previous_gst){
                bkg.GST_Previous_Milestone__c = details.previous_gst;
                updateBooking = true;
            }
            if(demands[0].Booking__r.Billed_Principal_Amount__c != details.billed_principal){
                bkg.Billed_Principal_Amount__c = details.billed_principal;
                updateBooking = true;
            }
            if(demands[0].Booking__r.Billed_GST_Amount__c != details.billed_gst){
                bkg.Billed_GST_Amount__c = details.billed_gst;
                updateBooking = true;
            }
            if(demands[0].Booking__r.Total_Principal_with_GST__c != details.total_amount){
                bkg.Total_Principal_with_GST__c = details.total_amount;
                updateBooking = true;
            }
            
            if(updateBooking){
                BookingTriggerHandler.byPass =true;
                update bkg; 
                BookingTriggerHandler.byPass =false;
            }
        }
        System.debug('details: ' + details);
        
        
       return details;
    }
    
    
    public class MilestoneDetails{
        @AuraEnabled public Decimal current_principal;
        @AuraEnabled public Decimal current_gst;
        @AuraEnabled public Decimal previous_principal;
        @AuraEnabled public Decimal previous_gst;
        @AuraEnabled public Decimal tds_outstanding;
        @AuraEnabled public Decimal billed_principal;
        @AuraEnabled public Decimal billed_gst;
        @AuraEnabled public Decimal total_amount;
    }

}