public class LockatedApp_LoyaltyEngine implements Schedulable{
    
    public void execute(SchedulableContext SC){
        birthdayPoints();
        dhamakaOffer1();
        registrationAnd20PercentPayement();
    }
    
    
    public static void birthdayPoints(){
        Date today = System.today();
        List<Opportunity> oppList = [SELECT Id, Customer_Reference__c FROM Opportunity WHERE StageName = 'Unit Booked' AND Customer_Reference__c != null];
        List<Lead> leadList = [SELECT Id, Customer_Reference__c FROM Lead WHERE Customer_Reference__c != null];
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : oppList){
            accIds.add(opp.Customer_Reference__c);
        }
        for(Lead ld : leadList){
            accIds.add(ld.Customer_Reference__c);
        }
        List<Applicant_Details__c> applicants = [SELECT Id,Booking__c,Booking__r.Opportunity__r.AccountId,Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c,Booking__r.Opportunity__r.Customer_Reference__c FROM Applicant_Details__c WHERE Booking__r.Opportunity__r.StageName = 'Unit Booked' AND Booking__r.Opportunity__r.AccountId =: accIds  
                                                 AND DAY_IN_MONTH(DOB__c) =: today.DAY() AND CALENDAR_MONTH(DOB__c) =: today.MONTH() AND Applicant_Number__c = 'Primary Applicant'];
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        for(Applicant_Details__c app : applicants){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Booking__c = app.Booking__c;
            ref.Account__c = app.Booking__r.Opportunity__r.AccountId;
            ref.Type__c = 'Birthday';
            /*if(app.Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c == 'Township'){
                ref.Points__c = '250';
                }else if(app.Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c == 'Premium'){
                ref.Points__c = '500';
                }else if(app.Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c == 'Luxury'){
                ref.Points__c = '1000';
             }*/
            
            switch on app.Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c {
                when 'Township' {
                    ref.Points__c = 250;
                }
                when 'Premium' {
                    ref.Points__c = 500;
                }
                when 'Luxury' {
                    ref.Points__c = 1000;
                }
                when else {
                    System.debug('No points');
                }
            }
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void dhamakaOffer(){
        Map<Id, Booking__c> bkgsMap = new Map<Id, Booking__c>([SELECT Id,CreatedDate,RW_Registration_Date__c,Project__r.Segment_Lookup__r.Segment_Type__c,Opportunity__r.AccountId,Opportunity__r.Customer_Reference__c,(SELECT Id,CreatedDate,RW_Booking__r.CreatedDate FROM Payment_Details__r) FROM Booking__c WHERE RW_Registration_Date__c != null AND RW_Total_Receipt_Amount_Received__c > 0]);
        List<Id> regCompletedBkgIds = new List<Id>();
        for(Booking__c bkg : bkgsMap.values()){
            if(bkg.RW_Registration_Date__c <= (Date.valueOf(bkg.CreatedDate) + 45)){
                regCompletedBkgIds.add(bkg.Id);
            }
        }
        if(regCompletedBkgIds.size() > 0){
            System.debug('regCompletedBkgIds: ' + regCompletedBkgIds.size());
            List<Referral_Points__c> existingRefPoints = [SELECT Id FROM Referral_Points__c WHERE Booking__c =: regCompletedBkgIds AND Type__c = 'Dhamaka Offer'];
            Map<String, List<Referral_Points__c>> bkgIdVsRefPoints = new Map<String, List<Referral_Points__c>>();
            for(Referral_Points__c ref : existingRefPoints){
                if(bkgIdVsRefPoints.get(ref.Booking__c) != null){
                    bkgIdVsRefPoints.get(ref.Booking__c).add(ref);
                }else{
                    bkgIdVsRefPoints.put(ref.Booking__c, new List<Referral_Points__c>{ref});
                }
            }
            List<String> bkgIds = new List<String>();
            List<Booking__c> bkgs = new List<Booking__c>();
            for(Id bkgId : regCompletedBkgIds){
                if(bkgIdVsRefPoints.get(bkgId) == null){
                    bkgIds.add(bkgId);
                    bkgs.add(bkgsMap.get(bkgId));
                }
            }
            /*List<RW_Payment_Details__c> receipts = [SELECT Id, RW_Booking__c,RW_Booking__r.CreatedDate FROM RW_Payment_Details__c WHERE RW_Booking__c =: bkgIds ORDER BY CreatedDate ASC];
            Map<String, List<RW_Payment_Details__c>> bkgIdVsReceiptsmap = new Map<String, List<RW_Payment_Details__c>>();
            for(RW_Payment_Details__c rec : receipts){
                if(bkgIdVsReceiptsmap.get(rec.RW_Booking__c) != null){
                    bkgIdVsReceiptsmap.get(rec.RW_Booking__c).add(rec);
                }else{
                    bkgIdVsReceiptsmap.put(rec.RW_Booking__c, new List<RW_Payment_Details__c>{rec});
                }
            }*/
            //if(bkgIdVsReceiptsmap.size() > 0){
            if(bkgs.size() > 0){
                for(Booking__c bkg : bkgs){
                    //RW_Payment_Details__c firstReceipt = bkgIdVsReceiptsmap.get(bkg.Id)[0];
                    RW_Payment_Details__c firstReceipt = bkg.Payment_Details__r[0];
                    if(Date.valueOf(firstReceipt.CreatedDate) <= Date.valueOf(firstReceipt.RW_Booking__r.CreatedDate) + 60){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Booking__c = bkg.Id;
                        ref.Account__c = bkg.Opportunity__r.Customer_Reference__c;
                        ref.Type__c = 'Dhamaka Offer';
                        switch on bkg.Project__r.Segment_Lookup__r.Segment_Type__c {
                            when 'Township' {
                                ref.Points__c = 15000;
                            }
                            when 'Premium' {
                                ref.Points__c = 20000;
                            }
                            when 'Luxury' {
                                ref.Points__c = 25000;
                            }
                            when else {
                                System.debug('No points');
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    public static void dhamakaOffer1(){
        
        List<RW_Payment_Details__c> receipts = [SELECT Id, RW_Booking__c,RW_Booking__r.CreatedDate,RW_Booking__r.RW_Booking_Confirmed_Date__c,RW_Booking__r.RW_Registration_Date__c FROM RW_Payment_Details__c WHERE CreatedDate = TODAY AND RW_Booking__r.RW_Registration_Date__c != null];
        List<Id> regCompletedBkgIds = new List<Id>();
        List<Id> recIds = new List<Id>();
        for(RW_Payment_Details__c rec : receipts){
            if(rec.RW_Booking__c != null && rec.RW_Booking__r.RW_Registration_Date__c <= (Date.valueOf(rec.RW_Booking__r.RW_Booking_Confirmed_Date__c) + 45)){
                regCompletedBkgIds.add(rec.RW_Booking__c);
                recIds.add(rec.id);
            }
        }
        if(regCompletedBkgIds.size() > 0){
            System.debug('regCompletedBkgIds: ' + regCompletedBkgIds.size());
            List<Referral_Points__c> existingRefPoints = [SELECT Id,Booking__c FROM Referral_Points__c WHERE Booking__c =: regCompletedBkgIds AND Type__c = 'Dhamaka Offer'];
            Map<String, List<Referral_Points__c>> bkgIdVsRefPoints = new Map<String, List<Referral_Points__c>>();
            for(Referral_Points__c ref : existingRefPoints){
                if(bkgIdVsRefPoints.get(ref.Booking__c) != null){
                    bkgIdVsRefPoints.get(ref.Booking__c).add(ref);
                }else{
                    bkgIdVsRefPoints.put(ref.Booking__c, new List<Referral_Points__c>{ref});
                }
            }
            List<String> bkgIds = new List<String>();
            for(Id bkgId : regCompletedBkgIds){
                if(bkgIdVsRefPoints.get(bkgId) == null){
                    bkgIds.add(bkgId);
                }
            }
			List<Booking__c> bkgs = [SELECT Id,CreatedDate,RW_Registration_Date__c,Project__r.Segment_Lookup__r.Segment_Type__c,Opportunity__r.AccountId,Opportunity__r.Customer_Reference__c,(SELECT Id,CreatedDate,RW_Booking__r.CreatedDate,RW_Booking__r.RW_Booking_Confirmed_Date__c FROM Payment_Details__r ORDER BY CreatedDate ASC) FROM Booking__c WHERE Id =: bkgIds];
            if(bkgs.size() > 0){
                List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
                for(Booking__c bkg : bkgs){
                    //RW_Payment_Details__c firstReceipt = bkg.Payment_Details__r[0];
                    RW_Payment_Details__c firstReceipt;
                    if(recIds.contains(bkg.Payment_Details__r[0].Id)){
                        firstReceipt = bkg.Payment_Details__r[0];
                    }
                    if(firstReceipt != null && Date.valueOf(firstReceipt.CreatedDate) <= Date.valueOf(firstReceipt.RW_Booking__r.RW_Booking_Confirmed_Date__c) + 60){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Booking__c = bkg.Id;
                        ref.Account__c = bkg.Opportunity__r.AccountId;
                        ref.Type__c = 'Dhamaka Offer';
                        switch on bkg.Project__r.Segment_Lookup__r.Segment_Type__c {
                            when 'Township' {
                                ref.Points__c = 15000;
                            }
                            when 'Premium' {
                                ref.Points__c = 20000;
                            }
                            when 'Luxury' {
                                ref.Points__c = 25000;
                            }
                            when else {
                                System.debug('No points');
                            }
                        }
                        refsToInsert.add(ref);
                    }
                }
                if(refsToInsert.size() > 0){
                    insert refsToInsert;
                }
            }
        }
    }
    
    public static void earlyPayment(List<RW_Demand__c> demands){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        for(RW_Demand__c dem : [SELECT Id,RW_Total_Demand_Amount__c,Booking__c,Booking__r.Customer_Reference__c,Booking__r.Opportunity__r.Customer_Reference__c,Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c,Booking__r.Opportunity__r.AccountId FROM RW_Demand__c WHERE Id IN: demands]){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Booking__c = dem.Booking__c;
            ref.Account__c = dem.Booking__r.Opportunity__r.Customer_Reference__c;
            ref.Demand__c = dem.Id;
            ref.Type__c = 'Early Payment 7 Days';
            switch on dem.Booking__r.Project__r.Segment_Lookup__r.Segment_Type__c {
                when 'Township' {
                    ref.Points__c = (0.001 * dem.RW_Total_Demand_Amount__c).setScale(2, RoundingMode.HALF_UP);
                }
                when 'Premium' {
                    ref.Points__c = (0.001 * dem.RW_Total_Demand_Amount__c).setScale(2, RoundingMode.HALF_UP);
                }
                when 'Luxury' {
                    ref.Points__c = (0.001 * dem.RW_Total_Demand_Amount__c).setScale(2, RoundingMode.HALF_UP);
                }
                when else {
                    System.debug('No points');
                }
            }
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void appEnrollment(List<Id> bookingIds){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        for(Booking__c bkg : [SELECT Id,Opportunity__r.AccountId,Project__r.Segment_Lookup__r.Segment_Type__c FROM Booking__c WHERE Id =: bookingIds]){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Booking__c = bkg.Id;
            ref.Account__c = bkg.Opportunity__r.AccountId;
            ref.Type__c = 'App Enrollment';
            switch on bkg.Project__r.Segment_Lookup__r.Segment_Type__c {
                when 'Township' {
                    ref.Points__c = 200;
                }
                when 'Premium' {
                    ref.Points__c = 200;
                }
                when 'Luxury' {
                    ref.Points__c = 200;
                }
                when else {
                    System.debug('No points');
                }
            }
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void referralFreshLeads(List<Id> leadIds){
        Map<String, String> custIdVsLeadId = new Map<String, String>();
        List<Lead> leads = [SELECT Id,Customer_Reference__c,RW_Project__r.Segment_Lookup__r.Segment_Type__c FROM Lead WHERE Id =: leadIds AND IsDeleted = false AND IsConverted = false];
        for(Lead ld : leads){
            custIdVsLeadId.put(ld.Customer_Reference__c, ld.Id);
        }
        if(custIdVsLeadId.size() > 0){
            List<Lead> refLeads = [SELECT Id, Customer_Reference__c,RW_Project__r.Segment_Lookup__r.Segment_Type__c FROM Lead WHERE Customer_Reference__c =: custIdVsLeadId.keySet() AND IsDeleted = false AND IsConverted = false ORDER BY CreatedDate ASC];
            System.debug('refLeads: ' + refLeads);
            Map<String, List<Lead>> custVsLeads = new Map<String, List<Lead>>();
            for(Lead ld : refLeads){
                if(custVsLeads.get(ld.Customer_Reference__c) != null){
                    custVsLeads.get(ld.Customer_Reference__c).add(ld);
                }else{
                    custVsLeads.put(ld.Customer_Reference__c, new List<Lead>{ld});
                }
            }
            System.debug('custVsLeads: ' + custVsLeads);
            List<Opportunity> refOpps = [SELECT Id, StageName, Customer_Reference__c FROM Opportunity WHERE Customer_Reference__c =: custIdVsLeadId.keySet()];
            System.debug('refOpps: ' + refOpps);
            Map<String, List<Opportunity>> custVsOpps = new Map<String, List<Opportunity>>();
            for(Opportunity opp : refOpps){
                if(custVsOpps.get(opp.Customer_Reference__c) != null){
                    custVsOpps.get(opp.Customer_Reference__c).add(opp);
                }else{
                    custVsOpps.put(opp.Customer_Reference__c, new List<Opportunity>{opp});
                }
            }
            System.debug('custVsOpps: ' + custVsOpps);
            List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
            for(Lead ld : leads){
                Decimal points = 0;
                switch on ld.RW_Project__r.Segment_Lookup__r.Segment_Type__c {
                    when 'Township' {
                        points = 250;
                    }
                    when 'Premium' {
                        points = 500;
                    }
                    when 'Luxury' {
                        points = 1000;
                    }
                    when else {
                        System.debug('No points');
                    }
                }
                if(custVsOpps.size() == 0){
                    System.debug('custVsLeads.get(ld.Customer_Reference__c): ' + custVsLeads.get(ld.Customer_Reference__c));
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Account__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
                        ref.Points__c = points;
                        refsToInsert.add(ref);
                    }
                }else if(custVsOpps != null && custVsOpps.get(ld.Customer_Reference__c) == null){
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Account__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
                        ref.Points__c = points;
                        refsToInsert.add(ref);
                    }
                }else if(custVsOpps != null && custVsOpps.get(ld.Customer_Reference__c) != null && custVsOpps.get(ld.Customer_Reference__c).size() == 0){
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Account__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
                        ref.Points__c = points;
                        refsToInsert.add(ref);
                    }
                }
                
            }
            if(refsToInsert.size() > 0){
                insert refsToInsert;
            }
        }
    }
    
    public static void referralSiteVisits(List<Opportunity> opportunities){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp : opportunities){
            oppIds.add(opp.Id);
        }
        for(Opportunity opp : [SELECT Id,AccountId,Customer_Reference__c,RW_Project__r.Segment_Lookup__r.Segment_Type__c FROM Opportunity WHERE Id =: oppIds]){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Customer_Reference__c = opp.Customer_Reference__c;
            ref.Opportunity__c = opp.Id;
            ref.Account__c = opp.Customer_Reference__c;
            ref.Type__c = 'Site Visit';
            Decimal points = 0;
            switch on opp.RW_Project__r.Segment_Lookup__r.Segment_Type__c {
                when 'Township' {
                    points = 750;
                }
                when 'Premium' {
                    points = 750;
                }
                when 'Luxury' {
                    points = 750;
                }
                when else {
                    System.debug('No points');
                }
            }
            ref.Points__c = points;
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void registrationAnd20PercentPayement(){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        List<Booking__c> bkgs = [SELECT Id,Opportunity__r.AccountId,Opportunity__r.Customer_Reference__c,Project__r.Segment_Lookup__r.Segment_Type__c,Allotment_Premium__c FROM Booking__c WHERE X20_Received__c = true AND RW_Registration_Status__c = 'Registration Completed' AND Opportunity__r.Customer_Reference__c != null];
        List<String> customerReferences = new List<String>();
        List<Id> bkgIds = new List<Id>();
        for(Booking__c bkg : bkgs){
            customerReferences.add(bkg.Opportunity__r.Customer_Reference__c);
            bkgIds.add(bkg.Id);
        }
        Map<String, List<Booking__c>> cusRefVsRefBookings = new Map<String, List<Booking__c>>();
        for(Booking__c bk : [SELECT Id,Opportunity__r.Customer_Reference__c FROM Booking__c WHERE Opportunity__r.AccountId =: customerReferences AND X20_Received__c = true AND RW_Registration_Status__c = 'Registration Completed']){
            if(cusRefVsRefBookings.get(bk.Opportunity__r.Customer_Reference__c) != null){
                cusRefVsRefBookings.get(bk.Opportunity__r.Customer_Reference__c).add(bk);
            }else{
                cusRefVsRefBookings.put(bk.Opportunity__r.Customer_Reference__c, new List<Booking__c>{bk});
            }
        }
        List<Referral_Points__c> existingRefPoints = [SELECT Id,Booking__c FROM Referral_Points__c WHERE Booking__c =: bkgIds AND Type__c = 'Registration and 20 percent payment'];
        Map<String, List<Referral_Points__c>> bkgIdVsRefPoints = new Map<String, List<Referral_Points__c>>();
        for(Referral_Points__c ref : existingRefPoints){
            if(bkgIdVsRefPoints.get(ref.Booking__c) != null){
                bkgIdVsRefPoints.get(ref.Booking__c).add(ref);
            }else{
                bkgIdVsRefPoints.put(ref.Booking__c, new List<Referral_Points__c>{ref});
            }
        }
        if(cusRefVsRefBookings.size() > 0){
            for(Booking__c bkg : bkgs){
                if(cusRefVsRefBookings.get(bkg.Opportunity__r.Customer_Reference__c) != null && bkgIdVsRefPoints.get(bkg.Id) == null){
                    Referral_Points__c ref = new Referral_Points__c();
                    ref.Booking__c = bkg.Id;
                    ref.Account__c = bkg.Opportunity__r.Customer_Reference__c;
                    ref.Type__c = 'Registration and 20 percent payment';
                    switch on bkg.Project__r.Segment_Lookup__r.Segment_Type__c {
                        when 'Township' {
                            ref.Points__c = (0.01 * bkg.Allotment_Premium__c).setScale(2, RoundingMode.HALF_UP);
                        }
                        when 'Premium' {
                            ref.Points__c = (0.01 * bkg.Allotment_Premium__c).setScale(2, RoundingMode.HALF_UP);
                        }
                        when 'Luxury' {
                            ref.Points__c = (0.01 * bkg.Allotment_Premium__c).setScale(2, RoundingMode.HALF_UP);
                        }
                        when else {
                            System.debug('No points');
                        }
                    }
                    refsToInsert.add(ref);
                }
            }
            if(refsToInsert.size() > 0){
                System.debug('refsToInsert: ' + refsToInsert.size());
                insert refsToInsert[0];
            }
        }
    }
    
}