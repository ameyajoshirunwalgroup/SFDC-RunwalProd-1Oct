public class ReferralPointsModule {
    
    public static void referralFreshLeads(List<Lead> leads){
        Map<String, String> custIdVsLeadId = new Map<String, String>();
        for(Lead ld : leads){
            custIdVsLeadId.put(ld.Customer_Reference__c, ld.Id);
        }
        if(custIdVsLeadId.size() > 0){
            List<Lead> refLeads = [SELECT Id, Customer_Reference__c FROM Lead WHERE Customer_Reference__c =: custIdVsLeadId.keySet() ORDER BY CreatedDate ASC];
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
            
            List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
            for(Lead ld : leads){
                if(custVsOpps == null){
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
                        refsToInsert.add(ref);
                    }
                }else if(custVsOpps != null && custVsOpps.get(ld.Customer_Reference__c) == null){
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
                        refsToInsert.add(ref);
                    }
                }else if(custVsOpps != null && custVsOpps.get(ld.Customer_Reference__c) != null && custVsOpps.get(ld.Customer_Reference__c).size() == 0){
                    if(custVsLeads.get(ld.Customer_Reference__c).size() == 1){
                        Referral_Points__c ref = new Referral_Points__c();
                        ref.Customer_Reference__c = ld.Customer_Reference__c;
                        ref.Lead__c = ld.Id;
                        ref.Type__c = 'Fresh Lead';
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
        for(Opportunity opp : opportunities){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Customer_Reference__c = opp.Customer_Reference__c;
            ref.Opportunity__c = opp.Id;
            ref.Type__c = 'Site Visit';
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void closedReferrals(List<Booking__c> bookings){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        for(Booking__c bkg : [SELECT Id,Opportunity__r.Customer_Reference__c FROM Booking__c WHERE Id IN: bookings]){
            Referral_Points__c ref = new Referral_Points__c();
            ref.Customer_Reference__c = bkg.Opportunity__r.Customer_Reference__c;
            ref.Booking__c = bkg.Id;
            ref.Type__c = '	Closed Referral';
            refsToInsert.add(ref);
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    public static void referralOnTimePayments(List<RW_Demand__c> demands){
        List<Referral_Points__c> refsToInsert = new List<Referral_Points__c>();
        for(RW_Demand__c dem : [SELECT Id, Booking__c, Booking__r.Customer_Reference__c, Booking__r.Opportunity__r.Customer_Reference__c  FROM RW_Demand__c WHERE Id IN: demands]){
            if(dem.Booking__r.Customer_Reference__c != null){
                Referral_Points__c ref = new Referral_Points__c();
                ref.Customer_Reference__c = dem.Booking__r.Opportunity__r.Customer_Reference__c;
                ref.Booking__c = dem.Booking__c;
                ref.Demand__c = dem.Id;
                ref.Type__c = 'On Time Payment';
                refsToInsert.add(ref);
            }
        }
        if(refsToInsert.size() > 0){
            insert refsToInsert;
        }
    }
    
    

}