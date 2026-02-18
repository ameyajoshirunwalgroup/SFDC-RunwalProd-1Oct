public with sharing class QuotationManagementServices {
    
    public static Map<String,List<QuoteUIWrapper>> getQuotationUIFormat(Id unitId, Decimal allotmentCharges, Decimal discountLumpsum, Integer addCarParks, Id subPlanId) {
        System.debug('allotment charges in quotation m ===>'+allotmentCharges );
        Map<String,Decimal> allChargesMap = InventoryCostServices.getAllCharges(unitId, allotmentCharges, discountLumpsum, subPlanId);
        system.debug('allChargesMap=='+allChargesMap);
        Project_Unit__c u = InventoryCostServices.getUnitDetails(unitId);
        Map<String,List<QuoteUIWrapper>> UIMap = new Map<String,List<QuoteUIWrapper>>();
        Boolean printBreakup = false;
        //for printing service tax for each cost
        Map<String,List<tax_breakup__c>> taxSlabMap = InventoryCostServices.getChildTaxSlabs();
        //Data for left top table
        Map<String,List<QuoteUIWrapper>> leftTopMap = new Map<String,List<QuoteUIWrapper>>();
        List<QuoteUIWrapper> tempList = new List<QuoteUIWrapper>();
        tempList.add(new QuoteUIWrapper('Flat Details', u.Name,'header','header'));
        tempList.add(new QuoteUIWrapper('Tower', u.TowerName__r.Name));
        tempList.add(new QuoteUIWrapper('Floor', String.valueOf(u.New_Floor__c)));  // RW_Floor__c
        tempList.add(new QuoteUIWrapper('Unit No', u.Name));
        tempList.add(new QuoteUIWrapper('Type', u.Project_Unit_Type__r.Name));
        tempList.add(new QuoteUIWrapper('Carpet Area (Sq. Ft.)', String.valueOf(u.Carpet_Area__c)));
        tempList.add(new QuoteUIWrapper('Saleable Area (Sq. Ft.)', String.valueOf(u.Saleable_Area__c)));
        String views = '';
        if(String.isNotBlank(u.S_View1__c))
            views = u.S_View1__c +' ,';
        if(String.isNotBlank(u.S_View_2__c))
            views = views + u.S_View_2__c + ' ,';
        if(String.isNotBlank(u.S_View_3__c))
            views = views + u.S_View_3__c;
        // remove the last character only if its a comma.
        if(views.length() > 0 && views.substring(views.length() -1).equals(','))
            views = views.substring(0,views.length() -1);
        
        tempList.add(new QuoteUIWrapper('View',views ) );
        string carpark = '';
        Integer totalCarParks = addCarParks;
          if(u.single_car_park_earmarked__c != null) {
              carpark = string.valueOf(u.single_car_park_earmarked__c) + ' Single Covered,';
              Integer total = Integer.valueOf(u.single_car_park_earmarked__c);
              totalCarParks += total;
          }
          if(u.tandem_car_park_earmarked__c != null) {
              carpark += ' '+ string.valueOf(u.tandem_car_park_earmarked__c) + ' Tandem Covered, ';
              Integer total = Integer.valueOf(2*u.tandem_car_park_earmarked__c);
              totalCarParks += total;
          }
          if(u.single_open_earmarked__c != null) {
              carpark += ' '+ string.valueOf(u.single_open_earmarked__c) + ' Single Open,';
              Integer total = Integer.valueOf(u.single_open_earmarked__c);
              totalCarParks += total;
          }
        if(u.tandem_open_earmarked__c != null) {
            carpark += ' '+ string.valueOf(u.tandem_open_earmarked__c) + ' Tandem Open,';
            Integer total = Integer.valueOf(2*u.tandem_open_earmarked__c);
            totalCarParks += total;
        }
        if(u.Stack__c != null) {
            carpark += ' ' + string.valueOf(u.Stack__c) + ' Stilt';
            Integer total = Integer.valueOf(u.Stack__c);
            totalCarParks += total;
        }
         if(u.MLCP_Earmarked__c!= null) {
            carpark += ' ' + string.valueOf(u.MLCP_Earmarked__c) + ' MLCP';
            Integer total = Integer.valueOf(u.MLCP_Earmarked__c);
            totalCarParks += total;
        }
        
        // remove the last character only if its a comma.
        if(carpark.length() > 0 && carpark.substring(carpark.length() -1).equals(','))
            carpark = carpark.substring(0,carpark.length() -1);
        tempList.add(new QuoteUIWrapper('Car Park', carpark )); 
        tempList.add(new QuoteUIWrapper('Total Parks', string.valueOf(totalCarParks) )); 
        
        leftTopMap.put('LEFTTOP',tempList);
        
        //Data for right top table
        Map<String,List<QuoteUIWrapper>> rightTopMap = new Map<String,List<QuoteUIWrapper>>();
    List<QuoteUIWrapper> tempList0 = new List<QuoteUIWrapper>();
        List<QuoteUIWrapper> tempList1 = new List<QuoteUIWrapper>();
        
        Map<String,List<QuoteUIWrapper>> leftBottomMap = new Map<String,List<QuoteUIWrapper>>();
        List<QuoteUIWrapper> tempList2 = new List<QuoteUIWrapper>();
        List<QuoteUIWrapper> tempList3 = new List<QuoteUIWrapper>();
        List<QuoteUIWrapper> tempList4 = new List<QuoteUIWrapper>();
                
        if(discountLumpsum != 0) {
            tempList1.add(new QuoteUIWrapper('', 'Discounted Cost','header','header'));
            tempList1.add(new QuoteUIWrapper('Allotment Premium     ( A )', INFormat(allChargesMap.get('AGREEMENTVALUE')), 'bold','avalDisc'));
        } else {
            tempList1.add(new QuoteUIWrapper('Total Cost', 'Amount','header','header'));
            tempList1.add(new QuoteUIWrapper('Allotment Premium     ( A )', INFormat(allChargesMap.get('AGREEMENTVALUE')), 'bold','aval'));
        }
        
        system.debug('Allotment Premium( A ) -> ' + INFormat(allChargesMap.get('AGREEMENTVALUE')));
        List<Project_Charges__c> projCharges = InventoryCostServices.getProjectChargesDefined(u.RW_Project__r.Name);
        
        Decimal charge1Sum = 0;
        Decimal charge2Sum = 0;
        Decimal charge3Sum = 0;
        Decimal charge4Sum = 0;
        Integer maintenanceCount = 0;
        Integer stampCount = 0;
        Integer otherCount = 0;
        Integer serviceCount = 0;
        
        for(Project_Charges__c pc : projCharges) {
            
            if(pc.S_Charge_Bucket__c.equals('Stamp Duty and Registration') && pc.Active__c){
                if(stampCount == 0) {
                    // whenever there is a discount, put some characters, the reason being blank values make the size of the table column
                    // shrink and distorts the table size. The discount values column and the orginal values column should match up
                    if(discountLumpsum != 0) 
                        tempList1.add(new QuoteUIWrapper('Stamp Duty and Registration Charges' ,'---','bold',''));
                    else
                        tempList1.add(new QuoteUIWrapper('Stamp Duty and Registration Charges' ,'','bold',''));
                }    
                tempList1.add(new QuoteUIWrapper(pc.Charge_Code__r.Name, INFormat(allChargesMap.get(pc.Charge_Code__r.Name))));
                charge1Sum = charge1Sum + allChargesMap.get(pc.Charge_Code__r.Name);
                stampCount++;
            }
            if(pc.S_Charge_Bucket__c.equals('Maintenance Charges') && pc.Active__c){
                if(maintenanceCount == 0) {
                    tempList2.add(new QuoteUIWrapper('Maintenance Charges' ,'','bold',''));
                }
                    
                tempList2.add(new QuoteUIWrapper(pc.Remarks__c, INFormat(allChargesMap.get(pc.Charge_Code__r.Name))));
                charge2Sum = charge2Sum + allChargesMap.get(pc.Charge_Code__r.Name);
                maintenanceCount++;
            }
            if(pc.S_Charge_Bucket__c.equals('Other Charges') && pc.Active__c){
                if(otherCount == 0)
                    tempList3.add(new QuoteUIWrapper('Other Charges' ,'','bold',''));
                tempList3.add(new QuoteUIWrapper(pc.Remarks__c, INFormat(allChargesMap.get(pc.Charge_Code__r.Name))));
                charge3Sum = charge3Sum + allChargesMap.get(pc.Charge_Code__r.Name);
                otherCount++;
            }
            if(pc.Service_Tax_Applicable_on_this_charge__c && pc.Active__c  && pc.S_Charge_Bucket__c.equals('Agreement Value') && printBreakup) {
              System.debug('Agreement Value Taxes:' + pc.Charge_code__r.name);
                  if(serviceCount == 0) {
                      if(discountLumpsum != 0) 
                        tempList4.add(new QuoteUIWrapper('GST Breakup' ,'---','bold',''));
                      else
                        tempList4.add(new QuoteUIWrapper('GST Breakup' ,'','bold',''));
                      charge4Sum = charge4Sum + allChargesMap.get('AGREEMENTVALUE TAX AMT');
                }
                
                if(taxSlabMap.containsKey(pc.Service_Tax_Percentage__c)) {
                for(tax_breakup__c tb : taxSlabMap.get(pc.Service_Tax_Percentage__c)) {
                    tempList4.add(new QuoteUIWrapper(tb.tax_name__c + ' on ' + pc.Charge_Code__r.Name + ' @ ' + allChargesMap.get(pc.Charge_Code__r.Name + ' '+ tb.tax_name__c +  ' TAX RATE') +'% on ' +  Informat(allChargesMap.get(pc.charge_code__r.Name + ' '+ tb.tax_name__c +  ' TAXABLE AMOUNT')) , 
                                                                          INFormat(allChargesMap.get(pc.Charge_Code__r.Name + ' ' + tb.tax_name__c+ ' TAX AMT'))));
                  }
                 }
                
                serviceCount++;
            } else if(pc.Service_Tax_Applicable_on_this_charge__c && pc.Active__c  && pc.S_Charge_Bucket__c.equals('Agreement Value') && pc.charge_code__r.Name.equals('Basic')) {
              System.debug('Agreement Value Taxes:' + pc.Charge_code__r.name);
                if(serviceCount == 0) {
                    if(discountLumpsum != 0) 
                        tempList4.add(new QuoteUIWrapper('GST Breakup' ,'---','bold',''));
                    else
                        tempList4.add(new QuoteUIWrapper('GST Breakup' ,'','bold',''));
                    
                }
                charge4Sum = charge4Sum + allChargesMap.get('AGREEMENTVALUE TAX AMT');
                if(taxSlabMap.containsKey(pc.Service_Tax_Percentage__c)) {
                for(tax_breakup__c tb : taxSlabMap.get(pc.Service_Tax_Percentage__c)) {
                    tempList4.add(new QuoteUIWrapper(tb.tax_name__c + ' on ' + 'AGREEMENT VALUE' + ' @ ' + allChargesMap.get('AGREEMENTVALUE'+ ' '+ tb.tax_name__c +  ' TAX RATE') +'% on ' +  InFormat(allChargesMap.get('AGREEMENTVALUE' + ' '+ tb.tax_name__c +  ' TAXABLE AMOUNT')) , 
                                                                          INFormat(allChargesMap.get('AGREEMENTVALUE' + ' ' + tb.tax_name__c+ ' TAX AMT'))));
                  }
                 }
                serviceCount++;
            }
            if(pc.Service_Tax_Applicable_on_this_charge__c && pc.Active__c  && !pc.S_Charge_Bucket__c.equals('Agreement Value')) {
        System.debug('Charge Name:' + pc);
                if(taxSlabMap.containsKey(pc.Service_Tax_Percentage__c)) {
                  for(tax_breakup__c tb : taxSlabMap.get(pc.Service_Tax_Percentage__c)) {
                    tempList4.add(new QuoteUIWrapper(tb.tax_name__c + ' on '+  + pc.Charge_Code__r.Name + ' @ ' + allChargesMap.get(pc.Charge_Code__r.Name + ' '+ tb.tax_name__c +  ' TAX RATE') +'% on ' +  Informat(allChargesMap.get(pc.charge_code__r.Name + ' '+ tb.tax_name__c +  ' TAXABLE AMOUNT')) , 
                                                                        INFormat(allChargesMap.get(pc.Charge_Code__r.Name + ' ' + tb.tax_name__c+ ' TAX AMT'))));
                  }
                }
                
                charge4Sum = charge4Sum + allChargesMap.get(pc.Charge_Code__r.Name + ' TOTAL TAX AMT');
                  serviceCount++;
              }
          }
        
        tempList1.add(new QuoteUIWrapper('Total (Stamp Duty and Registration)       (B)', INFormat(charge1Sum),'bold','bold','STAMPDUTYREGISTRATIONTOTAL',charge1Sum));
        
        tempList2.add(new QuoteUIWrapper('Total (Maintenance Charges)', INFormat(charge2Sum),'bold','bold','SCT',charge2Sum));
        
        tempList3.add(new QuoteUIWrapper('Total (Other Charges)', INFormat(charge3Sum),'bold','bold','OCT',charge3Sum));
        
        tempList4.add(new QuoteUIWrapper('Total (GST)     (C)', INFormat(charge4Sum),'bold','bold','SERVICETAXESTOTAL',charge4Sum));
        
        tempList4.add(new QuoteUIWrapper('Total (Maintenance Charges)       (D)', INFormat(charge2Sum),'bold','bold','MAINTENANCECHARGESTOTAL',charge2Sum));

        tempList4.add(new QuoteUIWrapper('Total (Other Charges)     (E)', INFormat(charge3Sum),'bold','bold','OTHERCHARGESTOTAL',charge3Sum));
        
        Decimal grandTotal = allChargesMap.get('AGREEMENTVALUE') + charge1Sum + charge2Sum + charge3Sum + charge4Sum;
        
        tempList4.add(new QuoteUIWrapper('Grand Total       (A+B+C+D+E)', INFormat(grandTotal),'header','header','GRANDTOTAL',grandTotal));

        rightTopMap.put('RIGHTTOP',tempList0);
    rightTopMap.get('RIGHTTOP').addAll(tempList1);
        rightTopMap.get('RIGHTTOP').addAll(tempList4);
        leftBottomMap.put('LEFTBOTTOM', tempList2);
        leftBottomMap.get('LEFTBOTTOM').addAll(tempList3);
        
        UIMap.putAll(leftTopMap);
        UIMap.putAll(rightTopMap);
        UIMap.putAll(leftBottomMap);
        system.debug('UIMap=='+UIMap);
        system.debug('rightTopMap=='+rightTopMap);
        return UIMap;
        
        
    }
    
    public static Map<String,Id> getApprovers(Id projId) {
        List<Team_Members__c> tmList = [Select User__c,Approver_Type__c, IsActive__c from Team_Members__c where Team__r.name like 'Sales Approvers Team%' and Team__r.Project__c = : projId];
        Map<String,Id> quoteApproversMap = new Map<String,Id>();
        for(Team_Members__c tm : tmList) {
            quoteApproversMap.put(tm.Approver_Type__c, tm.User__c);
        }
        return quoteApproversMap;
    }

    public class QuoteUIWrapper {
        public String colText {get; set;}
        public String colValue {get; set;}
        public String formatText {get;set;}
        public String formatVal {get;set;}
        public String chargeName {get;set;}
        public Decimal Amount {get;set;}
        
        public QuoteUIWrapper(String colText, String colValue){
            this.colText = colText;
            this.colValue = colValue;
        }
        
        public QuoteUIWrapper(String colText, String colValue, String formatText){
            this.colText = colText;
            this.colValue = colValue;
            this.formatText = formatText;
        }
        
        public QuoteUIWrapper(String colText, String colValue, String formatText, String formatVal){
            this.colText = colText;
            this.colValue = colValue;
            this.formatText = formatText;
            this.formatVal = formatVal;
        }
        
        public QuoteUIWrapper(String colText, String colValue, String formatText, String formatVal, String chargeName, Decimal Amount){
            this.colText = colText;
            this.colValue = colValue;
            this.formatText = formatText;
            this.formatVal = formatVal;
            this.chargeName = chargeName;
            this.Amount = Amount.setscale(0,RoundingMode.HALF_UP);
        }
    } 
    // method for formatting the currency details to Indian Commas Format
    public static String INFormat(Decimal money) {
        Boolean negative = false;
        if(money < 0) {
            negative = true;
        }
        String m1 = String.valueOf(math.abs(money.setscale(0,RoundingMode.HALF_UP))).reverse();
        String mF = '';
        for(Integer i=0; i < m1.length() ; i++) {
            mF += m1.substring(i,i+1);
            if(i==2) {
                mF += ',';
            }
            if(i==4 || i==6 || i==8 || i==10 || i==12) {
                mF += ',';
            }
        }
        mf = mf.reverse();
        if(mf.substring(0,1).equals(',')) {
            mf = mf.substring(1);
        }
        if(!negative)
            mf = 'Rs ' + mf + '/-';
        else
            mf = '- Rs ' + mf + '/-';
        return mf;
    }
}