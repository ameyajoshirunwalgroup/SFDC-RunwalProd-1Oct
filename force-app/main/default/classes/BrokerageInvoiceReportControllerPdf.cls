global class BrokerageInvoiceReportControllerPdf {
    
    public String scheme {get;set;}
    public String cpId {get;set;}
    public List<allData> aopCpData {get;set;}
    public List<allData> otherCpData {get;set;}
    public Boolean showAopCpdata {get;set;}
    public Boolean showOtherCpdata {get;set;}

    public BrokerageInvoiceReportControllerPdf(){
        
        string scheme = ApexPages.currentPage().getParameters().get('scheme');
        string cpId = ApexPages.currentPage().getParameters().get('cpId');
        System.debug('scheme: ' + scheme);
        System.debug('cpId: ' + cpId);
        List<allData> aopCpAllDtList = new List<allData>();
        List<allData> otherCpAllDtList = new List<allData>();
        Map<Id,Brokerage_Scheme__c> schemes = new Map<Id,Brokerage_Scheme__c>();
            
        System.debug('--: ' + (cpId == null));
        System.debug('--: ' + (cpId == ''));
        System.debug('--: ' + (cpId == 'null'));
        List<String> bkgStatus = new List<String>{'Cancelled','Cancellation Initiated','Booking Cancelled – Refund Pending','Booking Cancelled – Refund Ready','Booking Cancelled - Refunded'};
            
        List<Brokerage_Summary__c> summaryList = new List<Brokerage_Summary__c>();
        if(scheme != 'null' && scheme != '' && (cpId == 'null' || cpId == '')){
            System.debug('--1--');
            summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Booking__r.Status__c NOT IN : bkgStatus];
        }else if(cpId != 'null' &&  cpId != '' && (scheme == 'null' || scheme == '')){
            System.debug('--2--');
            summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus];
        }else if(cpId != 'null' && scheme != 'null'){
            System.debug('--3--');
           summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =: cpId AND Booking__r.Status__c NOT IN : bkgStatus];
        }
        
        /*if(cpId != null && scheme != null){
            System.debug('--1--');
           summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme AND Channel_Partner__c =: cpId];
        }else if(cpId == null && scheme != null){
            System.debug('--2--');
            summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Brokerage_Scheme__c =: scheme];
        }else if(cpId != null && scheme == null){
            System.debug('--3--');
            summaryList = [SELECT Id, Booking__c,  Brokerage_Scheme__r.Name, Brokerage_Scheme__r.Start_Date__c, Brokerage_Scheme__r.End_Date__c FROM Brokerage_Summary__c WHERE Channel_Partner__c =: cpId];
        }*/
        System.debug('summaryList: ' + summaryList);
        List<String> bkgIds = new List<String>();
        
        for(Brokerage_Summary__c summ : summaryList){
            bkgIds.add(summ.Booking__c);
        }
         System.debug('bkgIds: ' + bkgIds);
        
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
        
        
       
        List<Brokerage__c> allBrokerages = [SELECT Id, Name, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, AOP_CP__c, Channel_Partner__r.Name, Status__c, (SELECT Id, Status__c, Brokerage_Lookup__c FROM Brokerage_Invoices__r)
                                            FROM Brokerage__c WHERE Booking__c =: bkgIds AND Status__c = 'Due'];
        List<Brokerage__c> onePerBrokerages = [SELECT Id, Name, Booking__c, Booking__r.Is_AOP_CP_Applicable__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Name = '1% Brokerage' AND Status__c = 'Due' AND Booking__r.Is_AOP_CP_Applicable__c = true];
        System.debug('allBrokerages: ' + allBrokerages);
        
        Set<String> aopCpList = new Set<String>();
        Set<String> otherCpList = new Set<String>();
        List<Brokerage__c> aopCpSlabBrokerages = new List<Brokerage__c>();
        List<Brokerage__c> aopCpBaseBrokerages = new List<Brokerage__c>();
        List<Brokerage__c> otherCpSlabBrokerages = new List<Brokerage__c>();
        List<Brokerage__c> otherCpBaseBrokerages = new List<Brokerage__c>();
        Map<String, String> invStatusMap = new Map<String, String>();
        for(Brokerage__c brk : allBrokerages){
            if(brk.Booking__r.Is_AOP_CP_Applicable__c){
                aopCpList.add(brk.Booking__c);
                if(brk.Brokerage_Type__c != 'Base Brokerage'){
                    aopCpSlabBrokerages.add(brk);
                }else if(brk.Brokerage_Type__c == 'Base Brokerage' && brk.Name == 'Base Brokerage'){
                    aopCpBaseBrokerages.add(brk);
                }
            }else{
                otherCpList.add(brk.Booking__c);
                if(brk.Brokerage_Type__c != 'Base Brokerage'){
                    otherCpSlabBrokerages.add(brk);
                }else if(brk.Brokerage_Type__c == 'Base Brokerage' && brk.Name == 'Base Brokerage'){
                    otherCpBaseBrokerages.add(brk);
                }
            }
            for(Brokerage_Invoice__c inv : brk.Brokerage_Invoices__r){
                invStatusMap.put(inv.Brokerage_Lookup__c, inv.Status__c);
            }
        }
        System.debug('aopCpList: ' + aopCpList);
        if(aopCpList.size() > 0){
            showAopCpdata = true;
        }else{
            showAopCpdata = false;
        }
        if(otherCpList.size() > 0){
            showOtherCpdata = true;
        }else{
            showOtherCpdata = false;
        }
        /*List<Brokerage__c> slabBrokerages = [SELECT Id, Booking__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c != 'Base Brokerage' AND Status__c = 'Due'];
        List<Brokerage__c> baseBrokerages = [SELECT Id, Booking__c, Brokerage__c, Eligible_Slab__c, Brokerage_Type__c, Status__c FROM Brokerage__c WHERE Booking__c =: bkgIds 
                                         AND Brokerage_Type__c = 'Base Brokerage' AND Status__c = 'Due'];*/
        Map<String, Decimal> aopCpSlabBrokPerc = new Map<String, Decimal>();
        Map<String, Decimal> aopCpBaseBrokPerc = new Map<String, Decimal>();
        Map<String, String> aopCpBaseBrokStatus = new Map<String, String>();
        Map<String, String> aopCpSlabBrokStatus = new Map<String, String>();
        
        Map<String, Decimal> otherCpSlabBrokPerc = new Map<String, Decimal>();
        Map<String, Decimal> otherCpBaseBrokPerc = new Map<String, Decimal>();
        Map<String, String> otherCpBaseBrokStatus = new Map<String, String>();
        Map<String, String> otherCpSlabBrokStatus = new Map<String, String>();
        
        Map<String, Decimal> onePerBrokPerc = new Map<String, Decimal>();
        Map<String, String> onePerBrokStatus = new Map<String, String>();
        
        for(Brokerage__c brk : aopCpSlabBrokerages){
            aopCpSlabBrokPerc.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, brk.Brokerage__c);
            aopCpSlabBrokStatus.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, invStatusMap.get(brk.Id));
        }
        
        for(Brokerage__c bs : aopCpBaseBrokerages){
            aopCpBaseBrokPerc.put(bs.Booking__c, bs.Brokerage__c);
            aopCpBaseBrokStatus.put(bs.Booking__c, invStatusMap.get(bs.Id));
        }
        for(Brokerage__c brk : otherCpSlabBrokerages){
            otherCpSlabBrokPerc.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, brk.Brokerage__c);
            otherCpSlabBrokStatus.put(brk.Booking__c+'_'+brk.Eligible_Slab__c, invStatusMap.get(brk.Id));
        }
        for(Brokerage__c bs : otherCpBaseBrokerages){
            otherCpBaseBrokPerc.put(bs.Booking__c, bs.Brokerage__c);
            otherCpBaseBrokStatus.put(bs.Booking__c, invStatusMap.get(bs.Id));
        }
        for(Brokerage__c brk : onePerBrokerages){
            onePerBrokPerc.put(brk.Booking__c, brk.Brokerage__c);
            onePerBrokStatus.put(brk.Booking__c, invStatusMap.get(brk.Id));
        }
        
        List<brokerageDetails> aopCpdetailsList = new List<brokerageDetails>();
        List<brokerageDetails> otherCpdetailsList = new List<brokerageDetails>();
       
        Map<String, List<brokerageDetails>> aopCpDataMap = new Map<String, List<brokerageDetails>>();
        Map<String, List<brokerageDetails>> otherCpDataMap = new Map<String, List<brokerageDetails>>();
        List<Decimal> aopTotalPerList = new List<Decimal>();
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
                det.onePerBrkAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * onePerBrkerageVal)/100).setscale(2,RoundingMode.HALF_UP);
                det.onePerInvoiceStatus = onePerBrokStatus.get(bkg);
                //det.baseBrkerage = bkgMap.get(bkg).Base_Brokerage__c;
                Decimal aopCpBaseBrokPercVal = 0;
                if(aopCpBaseBrokPerc.keySet().contains(bkg)){
                    aopCpBaseBrokPercVal = aopCpBaseBrokPerc.get(bkg);
                }
                //Decimal aopCpBaseBrkerageVal = (aopCpBaseBrokPercVal != 0)? (aopCpBaseBrokPercVal - onePerBrkerageVal) : 0;
                Decimal aopCpBaseBrkerageVal = aopCpBaseBrokPercVal;
                det.baseBrkerage = aopCpBaseBrkerageVal;
                det.baseBrkerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * (aopCpBaseBrkerageVal))/100).setscale(2,RoundingMode.HALF_UP);
                det.baseBrkerageStatus = aopCpBaseBrokStatus.get(bkg);
                Decimal lad1Brk = (aopCpSlabBrokPerc.get(bkg+'_Slab 2')) != null ? aopCpSlabBrokPerc.get(bkg+'_Slab 2') : 0;
                det.lad1Brokerage = lad1Brk;
                det.lad1BrokerageStatus = aopCpSlabBrokStatus.get(bkg+'_Slab 2');
                det.lad1BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad1Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad2Brk = (aopCpSlabBrokPerc.get(bkg+'_Slab 3')) != null ? aopCpSlabBrokPerc.get(bkg+'_Slab 3') : 0;
                det.lad2Brokerage = lad2Brk;
                det.lad2BrokerageStatus = aopCpSlabBrokStatus.get(bkg+'_Slab 3');
                det.lad2BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad2Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad3Brk = (aopCpSlabBrokPerc.get(bkg+'_Slab 4')) != null ? aopCpSlabBrokPerc.get(bkg+'_Slab 4') : 0;
                det.lad3Brokerage = lad3Brk;
                det.lad3BrokerageStatus = aopCpSlabBrokStatus.get(bkg+'_Slab 4');
                det.lad3BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad3Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad4Brk = (aopCpSlabBrokPerc.get(bkg+'_Slab 5')) != null ? aopCpSlabBrokPerc.get(bkg+'_Slab 5') : 0;
                det.lad4Brokerage = lad4Brk;
                det.lad4BrokerageStatus = aopCpSlabBrokStatus.get(bkg+'_Slab 5');
                det.lad4BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad4Brk)/100).setscale(2,RoundingMode.HALF_UP);
                det.totalBrokerage = onePerBrkerageVal + aopCpBaseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                det.totalBrokerageAmt = (det.onePerBrkAmt + det.baseBrkerageAmt + det.lad1BrokerageAmt + det.lad2BrokerageAmt + det.lad3BrokerageAmt + det.lad4BrokerageAmt).setscale(2,RoundingMode.HALF_UP);
                det.aopCpTotalPercent = onePerBrkerageVal + aopCpBaseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                aopTotalPerList.add(onePerBrkerageVal + aopCpBaseBrkerageVal + lad1Brk + lad2Brk + lad3Brk + lad4Brk);
                if(aopCpDataMap.keySet().contains(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name)){
                    System.debug('aopCpDataMap if: ');
                    aopCpDataMap.get(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name).add(det);
                }else{
                    System.debug('aopCpDataMap else: ');
                    aopCpDataMap.put(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name, new List<brokerageDetails>{det});
                }
            }
            
        }
        aopTotalPerList.sort();
        System.debug('aopCpDataMap: ' + aopCpDataMap.keySet());
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
            d.aopCpTotalPercent = aopTotalPerList[aopTotalPerList.size()-1];
            aopCpAllDtList.add(d);
        }
        aopCpData = aopCpAllDtList;
        List<Decimal> otherTotalPerList = new List<Decimal>();
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
                det.onePerInvoice = 1;
                det.onePerBrkAmt = (bkgMap.get(bkg).Agreement_Value_for_brokers__c * 0.01).setscale(2,RoundingMode.HALF_UP);
                det.baseBrkerage = otherCpBaseBrokPerc.get(bkg);
                det.baseBrkerageStatus = otherCpBaseBrokStatus.get(bkg);
                det.baseBrkerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * otherCpBaseBrokPerc.get(bkg))/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad1Brk = (otherCpSlabBrokPerc.get(bkg+'_Slab 2')) != null ? otherCpSlabBrokPerc.get(bkg+'_Slab 2') : 0;
                det.lad1Brokerage = lad1Brk;
                det.lad1BrokerageStatus = otherCpSlabBrokStatus.get(bkg+'_Slab 2');
                det.lad1BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad1Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad2Brk = (otherCpSlabBrokPerc.get(bkg+'_Slab 3')) != null ? otherCpSlabBrokPerc.get(bkg+'_Slab 3') : 0;
                det.lad2Brokerage = lad2Brk;
                det.lad2BrokerageStatus = otherCpSlabBrokStatus.get(bkg+'_Slab 3');
                det.lad2BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad2Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad3Brk = (otherCpSlabBrokPerc.get(bkg+'_Slab 4')) != null ? otherCpSlabBrokPerc.get(bkg+'_Slab 4') : 0;
                det.lad3Brokerage = lad3Brk;
                det.lad3BrokerageStatus = otherCpSlabBrokStatus.get(bkg+'_Slab 4');
                det.lad3BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad3Brk)/100).setscale(2,RoundingMode.HALF_UP);
                Decimal lad4Brk = (otherCpSlabBrokPerc.get(bkg+'_Slab 5')) != null ? otherCpSlabBrokPerc.get(bkg+'_Slab 5') : 0;
                det.lad4Brokerage = lad4Brk;
                det.lad4BrokerageStatus = otherCpSlabBrokStatus.get(bkg+'_Slab 5');
                det.lad4BrokerageAmt = ((bkgMap.get(bkg).Agreement_Value_for_brokers__c * lad4Brk)/100).setscale(2,RoundingMode.HALF_UP);
                det.totalBrokerage = otherCpBaseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                det.totalBrokerageAmt = (det.baseBrkerageAmt + det.lad1BrokerageAmt + det.lad2BrokerageAmt + det.lad3BrokerageAmt + det.lad4BrokerageAmt).setscale(2,RoundingMode.HALF_UP);
                det.otherCpTotalPercent = otherCpBaseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk;
                otherTotalPerList.add(otherCpBaseBrokPerc.get(bkg) + lad1Brk + lad2Brk + lad3Brk + lad4Brk);
                otherCpdetailsList.add(det);
                
                if(otherCpDataMap.keySet().contains(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name)){
                    otherCpDataMap.get(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name).add(det);
                }else{
                    otherCpDataMap.put(bkgMap.get(bkg).Brokerage_Summary__r.Channel_Partner__r.Name, new List<brokerageDetails>{det});
                }
            }
            
        }
        otherTotalPerList.sort();
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
            d.otherCpTotalPercent = otherTotalPerList[otherTotalPerList.size()-1];
            otherCpAllDtList.add(d);
        }
        otherCpData = otherCpAllDtList;
    }
    
    public class allData{
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String schemeName {get;set;}
        public String aopcpName {get;set;}
        public String othercpName {get;set;}
        public Integer aopCpCount {get;set;}
        public Integer otherCpCount {get;set;}
        public Date iomDate {get;set;}
        public Decimal otherCpTotalPercent {get;set;}
        public Decimal aopCpTotalPercent {get;set;}
        public List<brokerageDetails> aopCpdetailist {get;set;}
    	public List<brokerageDetails> otherCpdetailist {get;set;}
    }
    
    public class brokerageDetails{
        public String companyCode {get;set;}
        public String unitName {get;set;}
        public String customerName {get;set;}
        public String channelPartner {get;set;}
        public String bookingName {get;set;}
        public Date bookingDate {get;set;}
        public Decimal receivedPercent {get;set;}
        public String regStatus {get;set;}
        public Decimal agreVal {get;set;}
        public Decimal agreValBrk {get;set;}
        public Decimal onePerInvoice {get;set;}
        public Decimal onePerBrkAmt {get;set;}
        public String onePerInvoiceStatus {get;set;}
        public Decimal baseBrkerage {get;set;}
        public String baseBrkerageStatus {get;set;}
        public Decimal baseBrkerageAmt {get;set;}
        public Decimal lad1Brokerage {get;set;}
        public Decimal lad1BrokerageAmt {get;set;}
        public String lad1BrokerageStatus {get;set;}
        public Decimal lad2Brokerage {get;set;}
        public Decimal lad2BrokerageAmt {get;set;}
        public String lad2BrokerageStatus {get;set;}
        public Decimal lad3Brokerage {get;set;}
        public Decimal lad3BrokerageAmt {get;set;}
        public String lad3BrokerageStatus {get;set;}
        public Decimal lad4Brokerage {get;set;}
        public Decimal lad4BrokerageAmt {get;set;}
        public String lad4BrokerageStatus {get;set;}
        public Decimal totalBrokerage {get;set;}
        public Decimal totalBrokerageAmt {get;set;}
        public Decimal otherCpTotalPercent {get;set;}
        public Decimal aopCpTotalPercent {get;set;}
      
    }
    
}