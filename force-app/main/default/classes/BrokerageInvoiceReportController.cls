global class BrokerageInvoiceReportController {
    
     
    @AuraEnabled
    public static List<allData> aopCpReportData(String scheme, String cpId){
        System.debug('scheme: ' + scheme);
        System.debug('cpId: ' + cpId);
        List<allData> allDtList = new List<allData>();
        //repData rep = new repData();
        //rep.aopCpCount = 0;
        //rep.otherCpCount = 0;
        //rep.iomDate = Date.today();
        
        Map<Id,Brokerage_Scheme__c> schemes = new Map<Id,Brokerage_Scheme__c>();
        List<String> bkgStatus = new List<String>{'Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending','Booking Cancelled – Refund Ready','Booking Cancelled - Refunded'};
        
        //List<Brokerage_Summary__c> summaryList = [SELECT Id, Booking__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: schemes.keySet()];
        
        String qry = '';
        if(scheme != null &&  cpId != null){
            qry += 'SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus';
        }else if(cpId != null){
            qry += 'SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus';
        }else if(scheme != null){
            qry += 'SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Booking__r.Status__c NOT IN : bkgStatus';
        }
        //List<Brokerage_Summary__c> summaryList = [SELECT Id, Booking__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =:cpId];
        List<Brokerage_Summary__c> summaryList = Database.query(qry);
        
        List<String> bkgIds = new List<String>();
        
        for(Brokerage_Summary__c summ : summaryList){
            bkgIds.add(summ.Booking__c);
        }
        
        Map<Id,Booking__c> bkgMap;
        String lableValue = System.label.Show_all_bookings_on_Brokerage_Invoice_Report;
        if(lableValue == 'Yes'){
            bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus]);
        }else if(lableValue == 'No'){
            bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus AND RW_Registration_Status__c = 'Registration Completed']);
        }
        
        /*Map<Id,Booking__c> bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus]);*/
        
        
        
        List<Brokerage__c> allBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, AOP_CP__c, Channel_Partner__r.Name, (SELECT Id, Status__c, Brokerage_Lookup__c FROM Brokerage_Invoices__r) 
                                            FROM Brokerage__c WHERE Booking__c =: bkgIds AND Status__c = 'Due'];
        
        Set<String> aopCpList = new Set<String>();
        Map<String, String> invStatusMap = new Map<String, String>();
        for(Brokerage__c brk : allBrokerages){
            if(brk.Booking__r.Is_AOP_CP_Applicable__c){
                aopCpList.add(brk.Booking__c);
                for(Brokerage_Invoice__c inv : brk.Brokerage_Invoices__r){
            		invStatusMap.put(inv.Brokerage_Lookup__c, inv.Status__c);
        		}
            }
        }
        
        System.debug('aopCpList: ' + aopCpList);
        List<Brokerage__c> onePerBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Name = '1% Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = true];
        List<Brokerage__c> slabBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c != 'Base Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = true];
        List<Brokerage__c> baseBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c = 'Base Brokerage' AND Name = 'Base Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = true];
        Map<String, Decimal> slabBrokPerc = new Map<String, Decimal>();
        Map<String, Decimal> baseBrokPerc = new Map<String, Decimal>();
        Map<String, String> slabBrokStatus = new Map<String, String>();
        Map<String, String> baseBrokStatus = new Map<String, String>();
        Map<String, Decimal> onePerBrokPerc = new Map<String, Decimal>();
        Map<String, String> onePerBrokStatus = new Map<String, String>();
        for(Brokerage__c brk : slabBrokerages){
            slabBrokPerc.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, brk.Brokerage__c);
            slabBrokStatus.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, invStatusMap.get(brk.Id));
        }
        for(Brokerage__c bs : baseBrokerages){
            baseBrokPerc.put(bs.Booking__c, bs.Brokerage__c);
            baseBrokStatus.put(bs.Booking__c, invStatusMap.get(bs.Id));
        }
        for(Brokerage__c brk : onePerBrokerages){
            onePerBrokPerc.put(brk.Booking__c, brk.Brokerage__c);
            onePerBrokStatus.put(brk.Booking__c, invStatusMap.get(brk.Id));
        }
        List<brokerageDetails> aopCpdetailsList = new List<brokerageDetails>();
       
        Map<String, List<brokerageDetails>> aopCpDataMap = new Map<String, List<brokerageDetails>>();
        List<Decimal> totalPerList = new List<Decimal>();
        for(String bkg : aopCpList){
            System.debug('aopCpList--1');
            if(bkgMap.get(bkg) != null){
                brokerageDetails det = new brokerageDetails();
                det.companyCode = bkgMap.get(bkg).Project__r.RW_SAP_Company_Code__c;
                det.unitName = bkgMap.get(bkg).Unit_No__r.RW_Param4__c;
                det.customerName = bkgMap.get(bkg).Opportunity__r.Name;
                det.channelPartner = bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name;
                det.bookingName = bkgMap.get(bkg).Name;
                det.bookingDate = Date.valueOf(bkgMap.get(bkg).Booking_Date__c);
                det.receivedPercent = bkgMap.get(bkg).Payment_Received__c;
                if(bkgMap.get(bkg).RW_Registration_Status__c == 'Registration Completed'){
                    det.regStatus = 'Yes';
                }else{
                    det.regStatus = 'No';
                }
                //det.regStatus = bkgMap.get(bkg).RW_Registration_Done__c;
                det.agreVal = bkgMap.get(bkg).Allotment_Premium__c;
                det.agreValBrk = bkgMap.get(bkg).Agreement_Value_for_brokers__c;
                Decimal onePerBrokPercVal = 0;
                if(onePerBrokPerc.keySet().contains(bkg)){
                    onePerBrokPercVal = onePerBrokPerc.get(bkg);
                }
                Decimal onePerBrkerageVal = (onePerBrokPercVal != 0)? onePerBrokPercVal : 0;
                det.onePerInvoice = onePerBrkerageVal;
                det.onePerInvoiceStatus = onePerBrokStatus.get(bkg);
                det.onePerBrkAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * onePerBrkerageVal)/100).setscale(2,RoundingMode.HALF_UP);
                //det.baseBrkerage = bkgMap.get(bkg).Base_Brokerage__c;
                Decimal baseBrokPercVal = 0;
                if(baseBrokPerc.keySet().contains(bkg)){
                    baseBrokPercVal = baseBrokPerc.get(bkg);
                }
                //Decimal baseBrkerageVal = (baseBrokPercVal != 0)? (baseBrokPercVal - onePerBrkerageVal) : 0;
                Decimal baseBrkerageVal = baseBrokPercVal;
                det.baseBrkerage = baseBrkerageVal;
                det.baseBrkerageStatus = baseBrokStatus.get(bkg);
                det.baseBrkerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * baseBrkerageVal)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad1Brk = (slabBrokPerc.get(bkg+'_Slab 2')) != null ? slabBrokPerc.get(bkg+'_Slab 2') : 0;
                det.lad1Brokerage = lad1Brk;
                det.lad1BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 2');
                det.lad1BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad1Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad2Brk = (slabBrokPerc.get(bkg+'_Slab 3')) != null ? slabBrokPerc.get(bkg+'_Slab 3') : 0;
                det.lad2Brokerage = lad2Brk;
                det.lad2BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 3');
                det.lad2BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad2Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad3Brk = (slabBrokPerc.get(bkg+'_Slab 4')) != null ? slabBrokPerc.get(bkg+'_Slab 4') : 0;
                det.lad3Brokerage = lad3Brk;
                det.lad3BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 4');
                det.lad3BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad3Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad4Brk = (slabBrokPerc.get(bkg+'_Slab 5')) != null ? slabBrokPerc.get(bkg+'_Slab 5') : 0;
                det.lad4Brokerage = lad4Brk;
                det.lad4BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 5');
                det.lad4BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad4Brk)/100).setscale(2,RoundingMode.HALF_UP);
                det.totalBrokerage = onePerBrkerageVal + baseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                det.totalBrokerageAmt = (det.onePerBrkAmt + det.baseBrkerageAmt + det.lad1BrokerageAmt + det.lad2BrokerageAmt + det.lad3BrokerageAmt + det.lad4BrokerageAmt).setscale(2,RoundingMode.HALF_UP);
                det.aopCpTotalPercent = onePerBrkerageVal + baseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                totalPerList.add(onePerBrkerageVal + baseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk);
                if(aopCpDataMap.keySet().contains(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name)){
                    System.debug('aopCpDataMap if: ');
                    aopCpDataMap.get(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name).add(det);
                }else{
                    System.debug('aopCpDataMap else: ');
                    aopCpDataMap.put(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name, new List<brokerageDetails>{det});
                }
            }
            
        }
        System.debug('aopCpDataMap: ' + aopCpDataMap.keySet());
        totalPerList.sort();
        
        for(String cp : aopCpDataMap.keySet()){
            System.debug('aopCpDataMap 1: ');
            allData d = new allData();
            d.schemeName = summaryList[0].Brokerage_Scheme__r.Name;
            d.startDate = summaryList[0].Brokerage_Scheme__r.Start_Date__c;
            d.endDate = summaryList[0].Brokerage_Scheme__r.End_Date__c;
            d.aopcpName = cp;
            d.aopCpdetailist = aopCpDataMap.get(cp);
            d.aopCpCount = aopCpDataMap.get(cp).size();
            d.iomDate = Date.today();
            //d.aopCpTotalPercent = aopCpDataMap.get(cp)[0].aopCpTotalPercent;
            d.aopCpTotalPercent = totalPerList[totalPerList.size()-1];
            allDtList.add(d);
        }
        return allDtList;
    }
    
    @AuraEnabled
    public static List<allData> otherCpReportData(String scheme, String cpId){
        System.debug('scheme: ' + scheme);
        System.debug('cpId: ' + cpId);
        List<allData> allDtList = new List<allData>();
        //repData rep = new repData();
        //rep.aopCpCount = 0;
        //rep.otherCpCount = 0;
        //rep.iomDate = Date.today();
        
        Map<Id,Brokerage_Scheme__c> schemes = new Map<Id,Brokerage_Scheme__c>();
       List<String> bkgStatus = new List<String>{'Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending','Booking Cancelled – Refund Ready','Booking Cancelled - Refunded'};
        
        String qry = '';
        if(scheme != null &&  cpId != null){
            qry += 'SELECT Id, Booking__c, Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus';
        }else if(cpId != null){
            qry += 'SELECT Id, Booking__c, Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus';
        }else if(scheme != null){
            qry += 'SELECT Id, Booking__c, Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Booking__r.Status__c NOT IN : bkgStatus';
        }
        //List<Brokerage_Summary__c> summaryList = [SELECT Id, Booking__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =:cpId];
        List<Brokerage_Summary__c> summaryList = Database.query(qry);
        
        
        List<String> bkgIds = new List<String>();
        
        for(Brokerage_Summary__c summ : summaryList){
            bkgIds.add(summ.Booking__c);
        }
        
        Map<Id,Booking__c> bkgMap;
        String lableValue = System.label.Show_all_bookings_on_Brokerage_Invoice_Report;
        if(lableValue == 'Yes'){
            bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus]);
        }else if(lableValue == 'No'){
            bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus AND RW_Registration_Status__c = 'Registration Completed']);
        }
        
        /*Map<Id,Booking__c> bkgMap = new Map<Id,Booking__c>([SELECT Id, Name, Unit_No__r.RW_Param4__c, Opportunity__r.Name, Booking_Date__c, Project__r.RW_SAP_Company_Code__c,
                                                            Payment_Received__c,BrokerIId__r.Name, RW_Registration_Done__c, Allotment_Premium__c, RW_Registration_Status__c,
                                                            Agreement_Value_for_brokers__c, Base_Brokerage__c, Brokerage_Summary__r.Channel_Partner__r.Name
                                                            FROM Booking__c WHERE Id =: bkgIds AND Status__c NOT IN : bkgStatus]);*/
        
        
        
        List<Brokerage__c> allBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, AOP_CP__c, Channel_Partner__r.Name, Status__c, (SELECT Id, Status__c, Brokerage_Lookup__c FROM Brokerage_Invoices__r) 
                                            FROM Brokerage__c WHERE Booking__c =: bkgIds AND Status__c = 'Due'];
        
        Set<String> otherCpList = new Set<String>();
        Map<String, String> invStatusMap = new Map<String, String>();
        for(Brokerage__c brk : allBrokerages){
            if(!brk.Booking__r.Is_AOP_CP_Applicable__c){
                otherCpList.add(brk.Booking__c);
                //rep.aopCpChannelPartner = brk.Channel_Partner__r.Name;
                for(Brokerage_Invoice__c inv : brk.Brokerage_Invoices__r){
            		invStatusMap.put(inv.Brokerage_Lookup__c, inv.Status__c);
        		}
            }
        }
        List<Brokerage__c> slabBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c != 'Base Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = false];
        List<Brokerage__c> baseBrokerages = [SELECT Id, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c = 'Base Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = false];
        Map<String, Decimal> slabBrokPerc = new Map<String, Decimal>();
        Map<String, String> slabBrokStatus = new Map<String, String>();
        Map<String, Decimal> baseBrokPerc = new Map<String, Decimal>();
        Map<String, String> baseBrokStatus = new Map<String, String>();
        for(Brokerage__c brk : slabBrokerages){
            slabBrokPerc.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, brk.Brokerage__c);
            slabBrokStatus.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, invStatusMap.get(brk.Id));
        }
        for(Brokerage__c bs : baseBrokerages){
            baseBrokPerc.put(bs.Booking__c, bs.Brokerage__c);
            baseBrokStatus.put(bs.Booking__c, invStatusMap.get(bs.Id));
        }
        
        List<brokerageDetails> otherCpdetailsList = new List<brokerageDetails>();
       
        Map<String, List<brokerageDetails>> otherCpDataMap = new Map<String, List<brokerageDetails>>();
        
      	List<Decimal> totalPerList = new List<Decimal>();
        for(String bkg : otherCpList){
            //rep.otherCpCount += 1;
            if(bkgMap.get(bkg) != null){
                brokerageDetails det = new brokerageDetails();
                det.companyCode = bkgMap.get(bkg).Project__r.RW_SAP_Company_Code__c;
                det.unitName = bkgMap.get(bkg).Unit_No__r.RW_Param4__c;
                det.customerName = bkgMap.get(bkg).Opportunity__r.Name;
                det.channelPartner = bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name;
                det.bookingName = bkgMap.get(bkg).Name;
                det.bookingDate = Date.valueOf(bkgMap.get(bkg).Booking_Date__c);
                det.receivedPercent = bkgMap.get(bkg).Payment_Received__c;
                if(bkgMap.get(bkg).RW_Registration_Status__c == 'Registration Completed'){
                    det.regStatus = 'Yes';
                }else{
                    det.regStatus = 'No';
                }
                //det.regStatus = bkgMap.get(bkg).RW_Registration_Done__c;
                det.agreVal = bkgMap.get(bkg).Allotment_Premium__c;
                det.agreValBrk = bkgMap.get(bkg).Agreement_Value_for_brokers__c;
                //det.onePerInvoice = 1;
                //det.onePerBrkAmt = (bkgMap.get(bkg).Agreement_Value_for_brokers__c * 0.01).setscale(2,RoundingMode.HALF_UP);
                det.baseBrkerage = baseBrokPerc.get(bkg);
                det.baseBrkerageStatus = baseBrokStatus.get(bkg);
                det.baseBrkerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * baseBrokPerc.get(bkg))/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad1Brk = (slabBrokPerc.get(bkg+'_Slab 2')) != null ? slabBrokPerc.get(bkg+'_Slab 2') : 0;
                det.lad1Brokerage = lad1Brk;
                det.lad1BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 2');
                det.lad1BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad1Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad2Brk = (slabBrokPerc.get(bkg+'_Slab 3')) != null ? slabBrokPerc.get(bkg+'_Slab 3') : 0;
                det.lad2Brokerage = lad2Brk;
                det.lad2BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 3');
                det.lad2BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad2Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad3Brk = (slabBrokPerc.get(bkg+'_Slab 4')) != null ? slabBrokPerc.get(bkg+'_Slab 4') : 0;
                det.lad3Brokerage = lad3Brk;
                det.lad3BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 4');
                det.lad3BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad3Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad4Brk = (slabBrokPerc.get(bkg+'_Slab 5')) != null ? slabBrokPerc.get(bkg+'_Slab 5') : 0;
                det.lad4Brokerage = lad4Brk;
                det.lad4BrokerageStatus = slabBrokStatus.get(bkg+'_Slab 5');
                det.lad4BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad4Brk)/100).setscale(2,RoundingMode.HALF_UP);
                det.totalBrokerage = baseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                det.totalBrokerageAmt = (det.baseBrkerageAmt + det.lad1BrokerageAmt + det.lad2BrokerageAmt + det.lad3BrokerageAmt + det.lad4BrokerageAmt).setscale(2,RoundingMode.HALF_UP);
                det.otherCpTotalPercent = baseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                totalPerList.add(baseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk);
                otherCpdetailsList.add(det);
                
                if(otherCpDataMap.keySet().contains(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name)){
                    otherCpDataMap.get(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name).add(det);
                    System.debug('otherCpDataMap if: ' + otherCpDataMap);
                }else{
                    otherCpDataMap.put(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name, new List<brokerageDetails>{det});
                    System.debug('otherCpDataMap else: ' + otherCpDataMap);
                }
                System.debug('otherCpDataMap1: ' + otherCpDataMap);
            }
            
        }
        totalPerList.sort();
        for(String cp : otherCpDataMap.keySet()){
            allData d = new allData();
            d.schemeName = summaryList[0].Brokerage_Scheme__r.Name;
            d.startDate = summaryList[0].Brokerage_Scheme__r.Start_Date__c;
            d.endDate = summaryList[0].Brokerage_Scheme__r.End_Date__c;
            d.othercpName = cp;
            d.otherCpdetailist = otherCpDataMap.get(cp);
            d.otherCpCount = otherCpDataMap.get(cp).size();
            d.iomDate = Date.today();
            //d.otherCpTotalPercent = otherCpDataMap.get(cp)[0].otherCpTotalPercent;
            d.otherCpTotalPercent = totalPerList[totalPerList.size()-1];
            allDtList.add(d);
        }
        
        System.debug('otherCpDataMap: ' + otherCpDataMap);
        
        
        System.debug('otherCpdetailsList: '+ otherCpdetailsList);
        //rep.otherCpdetailsList = otherCpdetailsList;
        //System.debug('rep: ' + rep.otherCpdetailsList);
        System.debug('allDtList: ' + allDtList);
        return allDtList;
    }

    
    public class allData{
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public String schemeName;
        @AuraEnabled
        public String aopcpName;
        @AuraEnabled
        public String othercpName;
        @AuraEnabled
        public Integer aopCpCount;
        @AuraEnabled
        public Integer otherCpCount;
        @AuraEnabled
        public Date iomDate;
        @AuraEnabled
        public Decimal otherCpTotalPercent;
        @AuraEnabled
        public Decimal aopCpTotalPercent;
        @AuraEnabled
        public List<brokerageDetails> aopCpdetailist;
        @AuraEnabled
    	public List<brokerageDetails> otherCpdetailist;
    }
    
    public class brokerageDetails{
        @AuraEnabled
        public String companyCode;
        @AuraEnabled
        public String unitName;
        @AuraEnabled
        public String customerName;
        @AuraEnabled
        public String channelPartner;
        @AuraEnabled
        public String bookingName;
        @AuraEnabled
        public Date bookingDate;
        @AuraEnabled
        public Decimal receivedPercent;
        @AuraEnabled
        public String regStatus;
        @AuraEnabled
        public Decimal agreVal;
        @AuraEnabled
        public Decimal agreValBrk;
        @AuraEnabled
        public Decimal onePerInvoice;
        @AuraEnabled
        public Decimal onePerBrkAmt;
        @AuraEnabled
        public String onePerInvoiceStatus;
        @AuraEnabled
        public Decimal baseBrkerage;
        @AuraEnabled
        public Decimal baseBrkerageAmt;
        @AuraEnabled
        public String baseBrkerageStatus;
        @AuraEnabled
        public Decimal lad1Brokerage;
        @AuraEnabled
        public Decimal lad1BrokerageAmt;
        @AuraEnabled
        public String lad1BrokerageStatus;
        @AuraEnabled
        public Decimal lad2Brokerage;
        @AuraEnabled
        public Decimal lad2BrokerageAmt;
        @AuraEnabled
        public String lad2BrokerageStatus;
        @AuraEnabled
        public Decimal lad3Brokerage;
        @AuraEnabled
        public Decimal lad3BrokerageAmt;
        @AuraEnabled
        public String lad3BrokerageStatus;
        @AuraEnabled
        public Decimal lad4Brokerage;
        @AuraEnabled
        public Decimal lad4BrokerageAmt;
        @AuraEnabled
        public String lad4BrokerageStatus;
        @AuraEnabled
        public Decimal totalBrokerage;
        @AuraEnabled
        public Decimal totalBrokerageAmt;
        @AuraEnabled
        public Decimal otherCpTotalPercent;
        @AuraEnabled
        public Decimal aopCpTotalPercent;
      
    }
}