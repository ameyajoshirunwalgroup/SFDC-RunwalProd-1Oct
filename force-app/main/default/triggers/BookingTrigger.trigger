trigger BookingTrigger on Booking__c (after Insert, after update,before update) {
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Booking__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    if(!byPassTriggerExceution)
    {
        BookingTriggerHandler handler = new BookingTriggerHandler();
        
        Set<id> pid = new set<id>();
        List<RW_Welcome_Call__c> listOfWelcomcalls = new List<RW_Welcome_Call__c>();
        List<Booking__c> loansToCreate = new List<Booking__c>();
        List<Id> updateCAMandDevChrgDetails = new List<Id>();
        list<Booking__c> bids = new list<Booking__c>(); //Added by Prashant 30-05-2025 Start..///// Update booking date on Opportunity based on booking date on booking.
        list<Booking__c> blist = new list<Booking__c>(); //Added by Prashant 04-06-2025 Start..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
        Set<Id> bidsbrok = new Set<Id>(); //Added by Prashant 04-06-2025 Start..///// Update Agreeement value for broker calculation.
        Map<Id,Decimal> oppIdVsAVMap = new Map<Id,Decimal>();//Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking. ////27-06-2025.
        List<Booking__c> soReleasedBkgs = new List<Booking__c>();
       // List<Id> bkIds = new List<Id>();
        
        if(trigger.isAfter){
            System.debug('trigger.isAfter____');
            if(trigger.isInsert || trigger.isUpdate){
                System.debug('trigger Line 7___');
                for(Booking__c bkg: trigger.newMap.values()){
                    ////Added by Prashant 30-05-2025 Start..///// Update booking date on Opportunity based on booking date on booking.
                    if((trigger.oldMap != null && trigger.oldMap.get(bkg.id).Booking_Date__c != trigger.newMap.get(bkg.id).Booking_Date__c) || (trigger.oldMap == null && bkg.Booking_Date__c != null)){
                        bids.add(bkg);     
                    }
                    //Added by Prashant 30-05-2025 End..///// Update booking date on Opportunity based on booking date on booking.
                    /*
                    ////Added by Prashant 04-06-2025 Start..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
                    if((trigger.oldMap != null && trigger.oldMap.get(bkg.id).RW_Total_Receipt_Amount_Received__c != trigger.newMap.get(bkg.id).RW_Total_Receipt_Amount_Received__c) || (trigger.oldMap == null && bkg.RW_Total_Receipt_Amount_Received__c != null)){
                        blist.add(bkg);     
                    }
                    //Added by Prashant 04-06-2025 End..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
                    //
                    ////Added by Prashant 04-06-2025 Start..//// Update Agreeement value for broker calculation.
                    if((trigger.oldMap != null && 
                        (trigger.oldMap.get(bkg.id).Stamp_duty_Paid2__c != trigger.newMap.get(bkg.id).Stamp_duty_Paid2__c || 
                         trigger.oldMap.get(bkg.id).Stamp_duty_payable_by_Runwal__c != trigger.newMap.get(bkg.id).Stamp_duty_payable_by_Runwal__c)) || 
                       (trigger.oldMap == null && (bkg.Stamp_duty_Paid2__c != null || bkg.Stamp_duty_payable_by_Runwal__c != null)))
                    {
                        bidsbrok.add(bkg.Id);     
                    }
                    //Added by Prashant 04-06-2025 End..///// Update Agreeement value for broker calculation.
                    */
                    if(bkg.Status__c == 'Booking Confirmed' && trigger.isInsert){
                        System.debug('trigger Line 10 Booking Confirmed___');
                        //Mk commenting below line as booking cannot be inserted with confirmed status
                      /*  RW_Welcome_Call__c wc = new RW_Welcome_Call__c();
                        wc.Booking_Id__c = bkg.Id;
                        wc.RW_Booking__c = bkg.Id;
                        wc.RW_Welcome_Call_Status__c = 'Due';
                        listOfWelcomcalls.add(wc);*/
                    }
                    
                    //Added by coServe 10-10-2022 start
                    if(trigger.isInsert){
                        updateCAMandDevChrgDetails.add(bkg.Id);
                        //updateDvlpmentCharge.add(bkg.Id);  
                    }
                    //Added by coServe 10-10-2022 end
                    
                   
                    if(trigger.isupdate){
                        /*if((bkg.Status__c == 'Sent for Approval' && (trigger.oldMap.get(bkg.id).Status__c!= bkg.Status__c)) && (bkg.Booking_Form_Id__c == null || (bkg.Booking_Form_Id__c != null && bkg.Booking_Form_Uploaded__c == false))){
                            bkg.addError('Please upload Booking Form');
                        }*/
                        if(trigger.oldMap.get(bkg.Id).Status__c == 'Booking Confirmed' && (trigger.oldMap.get(bkg.id).Status__c!= bkg.Status__c)){
                            List<RW_Welcome_Call__c> welcomeCalls = [SELECT Id, RW_Booking__c FROM RW_Welcome_Call__c WHERE RW_Booking__c =: bkg.Id];
                            if(welcomeCalls.size() > 0){
                                if(bkg.Status__c != 'Cancelled' && bkg.Status__c != 'Cancellation Initiated'){
                                    bkg.addError('Can not change the status of Confirmed Booking');
                                }
                            }
                        }
                        
                        if(bkg.Status__c == 'Booking Confirmed' && (trigger.oldMap.get(bkg.id).Status__c!= bkg.Status__c )){
                            System.debug('trigger Line 10 Booking Confirmed___');
                            RW_Welcome_Call__c wc = new RW_Welcome_Call__c();
                            wc.Booking_Id__c = bkg.Id;
                            wc.RW_Booking__c = bkg.Id;
                            wc.RW_Welcome_Call_Status__c = 'Due';
                            listOfWelcomcalls.add(wc);
                        }
                        
                        //Added by vinay 16-02-2022 start
                        if(bkg.Funding_Status__c == 'Loan Bank' && trigger.oldMap.get(bkg.id).Funding_Status__c == 'Self Funded'){
                            loansToCreate.add(bkg);
                        }
                        //Added by vinay 16-02-2022 end
                        
                        //Added by coServe 20-09-2024 start
                        /*if(bkg.SO_Release_Date_in_SAP__c != null && trigger.oldMap.get(bkg.id).SO_Release_Date_in_SAP__c == null && bkg.X4_5_Received__c == true && bkg.Do_Not_Create_Welcome_Call__c == false){
                            soReleasedBkgs.add(bkg);
                        }*/ //Commented by Vinay 17-04-2025
                        if(bkg.SO_Release_Date_in_SAP__c != null && trigger.oldMap.get(bkg.id).SO_Release_Date_in_SAP__c == null && bkg.Do_Not_Create_Welcome_Call__c == false){ //Added by Vinay 17-04-2025
                            soReleasedBkgs.add(bkg);
                        }
                        //Added by coServe 20-09-2024 end
                        //
                        //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.START
                        if(bkg.Allotment_Premium__c != trigger.oldMap.get(bkg.Id).Allotment_Premium__c && bkg.Opportunity__c != null){
                            oppIdVsAVMap.put(bkg.Opportunity__c,bkg.Allotment_Premium__c);                   
                        }
                        //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.END\
                       
                        
                    }      
                    
                    
                 }
                /*if(!bkIds.isEmpty()){
                    BookingTriggerHandler.assignBaseBrokerageAccruedDashboards(bkIds,trigger.oldmap);
                }*/
                //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.START
                if(!oppIdVsAVMap.isEmpty()){
                    BookingTriggerHandler.updateAVonOpportunity(oppIdVsAVMap);
                }
                //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.END
                
                if(listOfWelcomcalls.size()>0){
                    system.debug(listOfWelcomcalls);
                    //upsert listOfWelcomcalls Booking_Id__c; //Commented by coServe 20-09-2024
                }
                //Added by vinay 16-02-2022 start
                if(loansToCreate.size()>0){
                    system.debug(loansToCreate);
                    handler.createLoanRecords(loansToCreate);
                }
                //Added by vinay 16-02-2022 end
                //Added by coServe 10-10-2022 start
                if(updateCAMandDevChrgDetails.size()>0){
                    system.debug(updateCAMandDevChrgDetails);
                    handler.updateCAMandDevChargeDetails(updateCAMandDevChrgDetails);
                }
                //Added by coServe 10-10-2022 end
                //Added by coServe 20-09-2024 start
                if(soReleasedBkgs.size()>0){
                    CreateWelcomeCallForSoReleasedBkgs.createWelcomeCall(soReleasedBkgs);
                }
                //Added by coServe 20-09-2024 end
                //
                //Added by Prashant 30-05-2025 Start..///// Update booking date on Opportunity based on booking date on booking.
                if(!bids.isEmpty()){
                    BookingTriggerHandler.UpdateBookingDateInOpp(bids);
                }
                //Added by Prashant 30-05-2025 End..///// Update booking date on Opportunity based on booking date on booking.
                /*
                //Added by Prashant 04-06-2025 Start..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
                if(!blist.isEmpty()){
                    BookingTriggerHandler.UpdateTotalAmountReceivedInOpp(blist);
                }
                //Added by Prashant 04-06-2025 End..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
                //Added by Prashant 04-06-2025 Start..///// Update Agreeement value for broker calculation.
                if(!bidsbrok.isEmpty()){
                    BookingTriggerHandler.UpdateAVforBrokerCalcNew(bidsbrok);
                }
                //Added by Prashant 04-06-2025 End..///// Update Agreeement value for broker calculation.
                */
                
                
            } 
            if( trigger.isUpdate&& BookingTriggerHandler.firstrun){
                system.debug('MK');
                BookingTriggerHandler.firstrun=false;
                handler.processRecords(trigger.new, trigger.newMap, trigger.oldMap);
                
            }
            
        }
        
        
        
        if(trigger.isbefore && (trigger.isupdate || Trigger.isinsert)){
            for(Booking__c b: trigger.new){
                if(b.Brokerage_Summary__c != NULL){
                    b.RW_Registration_Done__c = 'Yes';
                }
            }
        }
            
           
        }
        
        
    //Added by Prashant - Assigning 5% & 9% received date after payment completion.
    // Deployment date to be the difference factore before that date all the booking will be treated as legacy data.
    /*if(Trigger.isBefore && Trigger.isUpdate){
        for(Booking__c bk: trigger.new){
            if(bk.X5_Received__c == true && trigger.oldMap.get(bk.id).X5_Received__c != bk.X5_Received__c){
                bk.X5_Received_Date__c = system.today();
            }
            if(bk.RW_X9_99_Received__c == true && trigger.oldMap.get(bk.id).RW_X9_99_Received__c != bk.RW_X9_99_Received__c){
                bk.X9_90_Received_Date__c = system.today();
            }
        }
    }*/
    
    
    /*if(Trigger.isbefore && Trigger.isupdate){ //Added by coServe 01-03-2024
        for(Booking__c bk: trigger.new){
            if(bk.Received__c >= 95 && trigger.oldMap.get(bk.Id).Received__c < 95){
                System.debug('--- Received__c 95--');
                bk.Possession_Guidelines_Sent_Date__c = Date.today();
            }
        }
    }*/
    
    if(Trigger.isafter && Trigger.isupdate){
        Set<id> bid = new set<id>();
        Set<id> BookId = new set<id>();
        Set<id> Invoicebid = new set<id>();
        Set<id> BookingId = new set<id>();
        Set<id> SummaryId = new set<id>();
        Set<id> cancelledOppIds = new set<id>(); //Added by Vinay 29-03-2025
        List<Booking__c> cancelledBkgs = new List<Booking__c>(); // Added by coServe 29-03-2025
        List<Booking__c> bkgs = new List<Booking__c>(); // Added by coServe 15-11-2022
        List<String> dayOfRegBkgs = new List<String>(); // Added by coServe 24-04-2024
        List<String> dayOfKeyHandBkgs = new List<String>(); // Added by coServe 24-04-2024
        List<String> sendAccStatementBkgs = new List<String>(); // Added by coServe 19-09-2024
        List<String> confirmedBkgIds = new List<String>(); // Added by Vinay 13-12-2024
        List<Brokerage_Summary__c> BrokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage__c> BrokerageList = new List<Brokerage__c>();
        list<id> bidsonSchUpdate = new list<id>();//Added by Prashant .... 20-05-2025..
        for(Booking__c bk: trigger.new){
            if(( trigger.newMap.get(bk.id).RW_Registration_Done__c == 'Yes' 
               && bk.Brokerage_Scheme__c != null && bk.BrokerIId__c != null && bk.RW_X9_99_Received__c == true )){
                   SummaryId.add(bk.Id);
               }  
            
            if(trigger.oldMap.get(bk.id).CP_Invoice_Approval_Status__c != trigger.newMap.get(bk.id).CP_Invoice_Approval_Status__c && trigger.newMap.get(bk.id).CP_Invoice_Approval_Status__c != null
               && trigger.newMap.get(bk.id).CP_Invoice_Approval_Status__c == 'Approved By L2'){
                   Invoicebid.add(bk.Brokerage_Summary__c);
               }
            if(trigger.oldMap.get(bk.id).Source_of_Booking__c != trigger.newMap.get(bk.id).Source_of_Booking__c && trigger.newMap.get(bk.id).Source_of_Booking__c != null
               && trigger.oldMap.get(bk.id).Source_of_Booking__c == 'Channel Partner'){
                   bid.add(bk.Id);
               }
            if(trigger.oldMap.get(bk.id).Status__c != trigger.newMap.get(bk.id).Status__c && trigger.newMap.get(bk.id).Status__c != null
               && trigger.newMap.get(bk.id).Status__c == 'Cancelled' && trigger.newMap.get(bk.id).Cancellation_Reason__c == 'Unit transfer'){
                   BookId.add(bk.Id);
               }
            if(trigger.oldMap.get(bk.id).Calculate_Brokerage__c != trigger.newMap.get(bk.id).Calculate_Brokerage__c && trigger.newMap.get(bk.id).Calculate_Brokerage__c == true
               && trigger.oldMap.get(bk.id).Calculate_Brokerage__c == false){
                   System.debug('BrokerageCalculationForInactiveScheme');
                   BrokerageManagementServicesV2.BrokerageCalculationForInactiveScheme(bk.Id,bk.Brokerage_Scheme__c);
               }
            
            // Added by coServe 15-11-2022 Start
            if(trigger.oldMap.get(bk.id).Booking_Date__c != trigger.newMap.get(bk.id).Booking_Date__c){
                bkgs.add(bk);     
            }
            // Added by coServe 15-11-2022 End
            // Added by coServe 24-04-2024 Start
            if(trigger.oldMap.get(bk.Id).RW_Registration_Date__c == null && bk.RW_Registration_Date__c != null){
                dayOfRegBkgs.add(bk.Id);     
            }
            if(trigger.oldMap.get(bk.Id).RW_Key_handover_date__c == null && bk.RW_Key_handover_date__c != null){
                dayOfKeyHandBkgs.add(bk.Id);     
            }
            // Added by coServe 24-04-2024 End
            if(trigger.oldMap.get(bk.Id).Send_Account_Statement__c == false && bk.Send_Account_Statement__c == true){ // Added by coServe 19-09-2024
                sendAccStatementBkgs.add(bk.Id);     
            }
            if(trigger.oldMap.get(bk.Id).Interest_to_be_Applied__c=='No' && trigger.newMap.get(bk.id).Interest_to_be_Applied__c=='Yes' && bk.Interest_to_be_Applied__c!=null)
            {
                BookingTriggerHandler.submitForApproval(Trigger.new, Trigger.oldMap);
            }
            
            if(trigger.oldMap.get(bk.Id).Status__c != 'Booking Confirmed' && bk.Status__c == 'Booking Confirmed'){ // Added by Vinay 13-12-2024
                confirmedBkgIds.add(bk.Id);     
            }

            if(bk.Cancellation_in_SAP__c == 'Sent to SAP' && bk.Cancellation_in_SAP__c != trigger.oldMap.get(bk.Id).Cancellation_in_SAP__c){ //Added by Vinay 29-03-2025
                cancelledOppIds.add(bk.Opportunity__c);
                cancelledBkgs.add(bk);
            }
            //Added by Prashant to update brokerage % whenever scheme is updated ///Added by Prashant. 20-05-2025..//Start/////
            if( trigger.oldMap.get(bk.Id).Brokerage_Scheme__c != bk.Brokerage_Scheme__c && bk.Brokerage_Scheme__c != null && bk.BrokerIId__c != null && bk.Source_of_Booking__c == 'Channel Partner'){                
                bidsonSchUpdate.add(bk.Id);
            }
            //Added by Prashant to update brokerage % whenever scheme is updated ///Added by Prashant. 20-05-2025..//End/////
            //
        }
        if(!bidsonSchUpdate.isEmpty()){
            BookingTriggerHandler.updateBrokerageonSchemeChange(bidsonSchUpdate);//Added by Prashant to update brokerage % whenever scheme is updated ///Added by Prashant. 20-05-2025..///////
        }
        if(!bid.isEmpty()){
            BrokerageManagementService.BookingSourceChange(bid);
        }
        if(!Invoicebid.isEmpty()){
            BookingTriggerHandler.ShowInvoice(Invoicebid);
        }
        if(!SummaryId.isEmpty()){
            //Commented by Prashant because the query is already being used inside the called function in handler. 20-05-2025..
            //BrokerSummaryList = [Select id,name,Status__c,Raise_Performa_Invoice__c from Brokerage_Summary__c where Booking__c IN:SummaryId];
            //if(!BrokerSummaryList.isEmpty()){
            System.debug('inside if update brokerage summary');
            BookingTriggerHandler.updateBrokerageSummaryStatus(SummaryId);
            //}
        }
        if(!BookId.isEmpty()){
            BookingTriggerHandler.updateexcludebatch(BookId);
        }
        // Added by coServe 15-11-2022 Start
        if(bkgs.size() > 0){
            BookingTriggerHandler.UpdateBookingDateInOppAndUnit(bkgs);
        }
        // Added by coServe 15-11-2022 End
        // Added by coServe 24-04-2024 Start
        if(dayOfRegBkgs.size() > 0){
            BookingTriggerHandler.sendDayOfRegWhatsAppFBLink(dayOfRegBkgs);
        }
        if(dayOfKeyHandBkgs.size() > 0){
            BookingTriggerHandler.sendDayOfKeyHandWhatsAppFBLink(dayOfKeyHandBkgs);
        }
        // Added by coServe 24-04-2024 End
        if(sendAccStatementBkgs.size() > 0){ // Added by coServe 19-09-2024
            Id JobId = System.enqueueJob(new SendAccountStatementForCRMBot(sendAccStatementBkgs));
        }
        if(confirmedBkgIds.size() > 0){ // Added by coServe 13-12-2024
            //BookingTriggerHandler.sendNotificationToCustomer(confirmedBkgIds); // Commented by Vinay 10-02-2025
        }

        if(cancelledOppIds.size() > 0){ // Added by coServe 29-03-2025
            SalesorderUpdateCallout.cancelsalesorder(cancelledOppIds);
        }
        
    }
    
     

    /*if(Trigger.isbefore && Trigger.isupdate){
        Set<id> bid = new set<id>();
        system.debug('Inside for');
        for(Booking__c bk: trigger.new){
            List<Brokerage_Summary__c> BrokerSummaryList = new List<Brokerage_Summary__c>();
            BrokerSummaryList = [Select id,name,Status__c from Brokerage_Summary__c where Booking__c=:bk.id];
            if(!BrokerSummaryList.isEmpty()){
                if(BrokerSummaryList[0].Status__c == 'Due'){
                    if(trigger.oldMap.get(bk.id).Source_of_Booking__c != trigger.newMap.get(bk.id).Source_of_Booking__c){
                        bk.addError('Cannot change the source of booking as brokerage invoice has been raised');
                    }
                    if(trigger.oldMap.get(bk.id).Custom_Base_Brokerage__c != trigger.newMap.get(bk.id).Custom_Base_Brokerage__c){
                        bk.addError('Cannot change the Custom base brokerage as brokerage invoice has already been raised');
                    }
                }
            }
        }
    }*/
    
    
   // trigger BookingTrigger on Booking__c (before update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        List<Booking__c> changedBookings = new List<Booking__c>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            Booking__c newRec = Trigger.new[i];
            Booking__c oldRec = Trigger.old[i];

            if (newRec.Quotation__c != oldRec.Quotation__c && newRec.Quotation__c != null) {
                changedBookings.add(newRec);
            }
        }
        if (!changedBookings.isEmpty()) {
            BookingTriggerHandler.processQuoteAndRelatedUpdates(changedBookings);
        }
        
    }


}