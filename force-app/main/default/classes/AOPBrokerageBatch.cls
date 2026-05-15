public with sharing class AOPBrokerageBatch implements Database.Batchable<SObject>, Database.Stateful {

    private String fy; 
    private Map<Id, Id> cpToAccountMap = new Map<Id, Id>();

    public AOPBrokerageBatch(String financialYear) {
        this.fy = financialYear;
    }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date fyStart = getFYStart(fy);
    Date fyEnd   = getFYEnd(fy);
    System.debug('➡️ FY Start: ' + fyStart + ', FY End: ' + fyEnd);

    // Step 1: Query all eligible AOPs for the FY
    Set<Id> cpIds = new Set<Id>();
    List<AOP__c> aops = [
        SELECT Channel_Partner__c
        FROM AOP__c
        WHERE Start_Date__c <= :fyEnd
          AND End_Date__c >= :fyStart
          AND Commitment_min__c != null
          AND Commitment_max__c != null
    ];
    System.debug('⚡ Eligible AOPs count: ' + aops.size());

    for (AOP__c a : aops) {
        cpIds.add(a.Channel_Partner__c);
    }
    System.debug('⚡ Eligible CP IDs count: ' + cpIds.size() + ' | ' + cpIds);
  Integer testCount = [
    SELECT COUNT()
    FROM Booking__c
    WHERE BrokerIId__c IN :cpIds  AND Booking_Date__c >= :DateTime.newInstance(fyStart, Time.newInstance(0,0,0,0)) AND  Booking_Date__c <= :DateTime.newInstance(fyEnd, Time.newInstance(23,59,59,999)) 
];
System.debug('⚡ Booking count with only BrokerIId filter = ' + testCount);
    // Step 2: Return inline query using Database.getQueryLocator
    Database.QueryLocator locator = Database.getQueryLocator([
        SELECT Id, Name, Opportunity__c, BrokerIId__c, BrokerIId__r.Account__c, Agreement_Value_for_brokers__c,
               Project__c, Booking_Date__c, Tower__c, X5_Received__c, RW_X9_99_Received__c,Status__c,
               RW_Registration_Done__c, Brokerage_Scheme__c, Is_Special_Brokerage_Scheme__c,
               Type_Of_Client_Formula__c, RW_Registration_Date__c, Type_of_Client__c,Source_of_Booking__c
        FROM Booking__c
        WHERE// Project__c != null
         // AND Status__c = 'Booking Confirmed'
         // AND RW_Registration_Done__c != 'Yes'
          //AND
        BrokerIId__c != null
         // AND Opportunity__c != null
          AND Booking_Date__c >= :DateTime.newInstance(fyStart, Time.newInstance(0,0,0,0))
         AND  Booking_Date__c <= :DateTime.newInstance(fyEnd, Time.newInstance(23,59,59,999))
          AND (RW_X9_99_Received__c = true OR X5_Received__c = true)
          //AND Source_of_Booking__c = 'Channel Partner'
          AND BrokerIId__c IN :cpIds
    ]);
    System.debug('⚡ QueryLocator created with Bookings');

    return locator;
}


    public void execute(Database.BatchableContext bc, List<Booking__c> scope) {
        System.debug('⚡ Processing scope size: ' + scope.size());

        Map<Id, List<Booking__c>> cpToBookings = new Map<Id, List<Booking__c>>();
        for (Booking__c b : scope) {
            if (!cpToBookings.containsKey(b.BrokerIId__c)) {
                cpToBookings.put(b.BrokerIId__c, new List<Booking__c>());
            }
            cpToBookings.get(b.BrokerIId__c).add(b);
            cpToAccountMap.put(b.BrokerIId__c, b.BrokerIId__r.Account__c);
        }

        // Query AOP agreements
        Map<Id, AOP__c> cpToAop = new Map<Id, AOP__c>([
            SELECT Id, Channel_Partner__c, Commitment_min__c, Commitment_max__c
            FROM AOP__c
            WHERE Start_Date__c <= :getFYEnd(fy)
              AND End_Date__c >= :getFYStart(fy)
              AND Channel_Partner__c IN :cpToBookings.keySet()
        ]);
        System.debug('⚡ Found AOP agreements: ' + cpToAop.keySet());

        // Query slabs
        Map<Id, List<AOP_Slab__c>> aopToSlabs = new Map<Id, List<AOP_Slab__c>>();
        for (AOP_Slab__c slab : [
            SELECT Id, AOP__c, Lower_Limit__c, Upper_Limit__c, Brokerage_Rate__c, Priority__c
            FROM AOP_Slab__c
            WHERE AOP__c IN :cpToAop.keySet()
            ORDER BY Priority__c ASC
        ]) {
            if (!aopToSlabs.containsKey(slab.AOP__c)) {
                aopToSlabs.put(slab.AOP__c, new List<AOP_Slab__c>());
            }
            aopToSlabs.get(slab.AOP__c).add(slab);
        }
        System.debug('⚡ Slabs grouped by AOP: ' + aopToSlabs);

        List<Brokerage_Summary__c> summariesToInsert = new List<Brokerage_Summary__c>();
        List<Brokerage__c> brokeragesToInsert = new List<Brokerage__c>();

        for (Id cpId : cpToBookings.keySet()) {
            Decimal totalAV = 0;
            for (Booking__c b : cpToBookings.get(cpId)) {
                totalAV += (b.Agreement_Value_for_brokers__c != null) ? b.Agreement_Value_for_brokers__c : 0;
            }
            System.debug('➡️ CP ' + cpId + ' total AV=' + totalAV);

            Decimal brokerageRate = 0;
            AOP__c cpAop = cpToAop.get(cpId);
            if (cpAop != null && aopToSlabs.containsKey(cpAop.Id)) {
                AOP_Slab__c matchedSlab;
                AOP_Slab__c downgradeSlab;

                for (AOP_Slab__c slab : aopToSlabs.get(cpAop.Id)) {
                    if (totalAV >= slab.Lower_Limit__c && totalAV <= slab.Upper_Limit__c) {
                        matchedSlab = slab;
                        break;
                    }
                    if (slab.Upper_Limit__c < cpAop.Commitment_min__c) {
                        downgradeSlab = slab;
                    }
                }

                if (matchedSlab != null) {
                    brokerageRate = matchedSlab.Brokerage_Rate__c;
                    System.debug('✅ Matched slab for CP ' + cpId + ': ' + matchedSlab.Id + ' | Rate=' + brokerageRate);
                } else if (downgradeSlab != null) {
                    brokerageRate = downgradeSlab.Brokerage_Rate__c;
                    System.debug('⚠️ Downgrade slab used for CP ' + cpId + ': ' + downgradeSlab.Id + ' | Rate=' + brokerageRate);
                } else {
                    System.debug('❌ No matching slab found for CP ' + cpId);
                }
            }

            // Create Summary
            Brokerage_Summary__c summary = new Brokerage_Summary__c(
                Channel_Partner__c = cpId,
                CP_Account__c = cpToAccountMap.get(cpId)
            );
            summariesToInsert.add(summary);

            // Create Line items
            for (Booking__c b : cpToBookings.get(cpId)) {
                Decimal av = (b.Agreement_Value_for_brokers__c != null ? b.Agreement_Value_for_brokers__c : 0);
                Decimal brokerageAmt = av * brokerageRate / 100;

                System.debug('   📌 Booking ' + b.Id + ' | AV=' + av + ' | Rate=' + brokerageRate + ' | Amount=' + brokerageAmt);

                Brokerage__c line = new Brokerage__c(
                    Brokerage_Type__c = 'AOP Brokerage',
                    Channel_Partner__c = cpId,
                    Brokerage_Amount__c = brokerageAmt,
                    Brokerage__c = brokerageRate
                );
                brokeragesToInsert.add(line);
            }
        }

        insert summariesToInsert;
        System.debug('✅ Inserted summaries: ' + summariesToInsert);

        for (Brokerage__c b : brokeragesToInsert) {
            for (Brokerage_Summary__c s : summariesToInsert) {
                if (b.Channel_Partner__c == s.Channel_Partner__c && b.Brokerage_Summary__c == null) {
                    b.Brokerage_Summary__c = s.Id;
                }
            }
        }

        insert brokeragesToInsert;
        System.debug('✅ Inserted line items: ' + brokeragesToInsert);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('🎯 AOP Brokerage Batch completed for FY ' + fy);
    }

 private Date getFYStart(String fy) {
        System.debug('➡️ Raw FY: ' + fy);
        if (String.isBlank(fy)) {
            throw new AuraHandledException('⚠️ Financial year string cannot be blank.');
        }
        String cleaned = fy.replace('FY', ''); 
        String[] parts = cleaned.split('-');
        Integer startYear = Integer.valueOf(parts[0]);
        return Date.newInstance(startYear, 4, 1); // FY starts April 1
    }

    private Date getFYEnd(String fy) {
        System.debug('➡️ Raw FY: ' + fy);
        if (String.isBlank(fy)) {
            throw new AuraHandledException('⚠️ Financial year string cannot be blank.');
        }
        String cleaned = fy.replace('FY', '');
        String[] parts = cleaned.split('-');

        Integer endYear;
        if (parts.size() > 1 && !String.isBlank(parts[1])) {
            endYear = Integer.valueOf(parts[1]) + 2000;
        } else {
            endYear = Integer.valueOf(parts[0]) + 1;
        }

        return Date.newInstance(endYear, 3, 31); // FY ends March 31
    }

}