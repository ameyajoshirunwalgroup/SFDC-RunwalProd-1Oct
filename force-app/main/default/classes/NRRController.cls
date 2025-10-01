public class NRRController {
    
    public NRR__c nrrDetails {get;set;}
    
    public String oppId {get;set;}
    public String recordId {get;set;}
    
    //Public Id recordId = System.currentPagereference().getParameters().get('id');
    
    public NRRController(){
        recordId = ApexPages.currentPage().getParameters().get('id');
        System.debug('recordId: ' + recordId);
        nrrDetails = [SELECT Id, Name, Project_Unit__c, Project_Name__c, Flat_No__c, Saleable_Area__c, Booking_Date__c, Base_Price__c,
                           PAGE_premium__c, Floor_Rise__c, Garden_Premium_NPV_any_other_premium__c, Premium_1__c, Premium_2__c, Discount_1__c, 
                           Discount_2__c, CP_passback_if_Applicable__c, Discount_3_CP_Pass_back__c, Total_Rate__c, Agreement_Value__c,
                           Development_Charges__c, SD_in_AV__c, Total_Agreement_Value__c, AV_as_per_cost_sheet__c, AV_After_2_GST_discount__c,
                           AV_for_Brokerage_after_deduction__c, Passback__c, Brokerage_to_be_paid__c, CP_Pay_out_Referral_payout__c, 
                           Interest_Cost_NPV_Subvention_Deffered__c, Other_Cost_if_any_Eg_SD_Waiver__c, SD_impact_if_applicable__c, Base_Brokerage__c,
                           GST_ITC_Benefit__c, Net_value__c, Net_Realisation__c, Approved_NRR__c, Source__c, Payment_Plan__c, Customer_Name__c,
                      	   Opportunity__c, SD_Impact_Applicable__c, Project__r.GST_Percentage_Discount__c, No_of_Parkings__c, GST__c,
                      	   Base_Price_with_Car_Parks__c
                           FROM NRR__c WHERE Project_Unit__c =: recordId];
        
        System.debug('recordid: ' + recordid);
        System.debug('nrrDetails: ' + nrrDetails);
    }
    
    @auraEnabled
    public static NRR__c nrrCheck(String recId, String oppId){
        NRR__c nrr = new NRR__c();
        List<NRR__c> nr = [SELECT Id, Name, Project_Unit__c, Project_Name__c, Flat_No__c, Saleable_Area__c, Booking_Date__c, Base_Price__c,
                           PAGE_premium__c, Floor_Rise__c, Garden_Premium_NPV_any_other_premium__c, Premium_1__c, Premium_2__c, Discount_1__c, 
                           Discount_2__c, CP_passback_if_Applicable__c, Discount_3_CP_Pass_back__c, Total_Rate__c, Agreement_Value__c,
                           Development_Charges__c, SD_in_AV__c, Total_Agreement_Value__c, AV_as_per_cost_sheet__c, AV_After_2_GST_discount__c,
                           AV_for_Brokerage_after_deduction__c, Passback__c, Brokerage_to_be_paid__c, CP_Pay_out_Referral_payout__c, 
                           Interest_Cost_NPV_Subvention_Deffered__c, Other_Cost_if_any_Eg_SD_Waiver__c, SD_impact_if_applicable__c, Base_Brokerage__c,
                           GST_ITC_Benefit__c, Net_value__c, Net_Realisation__c, Approved_NRR__c, Source__c, Payment_Plan__c, Customer_Name__c,
                           Opportunity__c, SD_Impact_Applicable__c, Project_Unit__r.RW_Project__r.GST_Percentage_Discount__c, No_of_Parkings__c,
                           Base_Price_with_Car_Parks__c, GST__c
                           FROM NRR__c WHERE Project_Unit__c =: recId];
        
        Project_Unit__c unit = [SELECT Id, RW_Project__c, RW_Project__r.Name, RW_Param4__c, Saleable_Area__c, RW_Booking_Date__c,
									RW_Customer__r.Name, RW_Project__r.GST_Percentage_Discount__c, TowerName__c                              
                                    FROM Project_Unit__c WHERE Id=: recId];
        
        //List<Brokerage_Scheme__c> brokSchemes = [SELECT Id, Base_Brokerage_for_Local_Bookings__c FROM Brokerage_Scheme__c WHERE End_Date__c >: Date.today()];
        Opportunity opp = new Opportunity();
        if(oppId != null){
            opp = [SELECT Id, Name, Walkin_Source__c, RW_Type_of_Client__c FROM Opportunity WHERE Id =: oppId];
        }
        if(nr.size() > 0){
            nrr = nr[0];
            if(oppId != null){
                
                
                
                List<Scheme_Configuration__c> sc = [Select Id,Name,Brokerage_Scheme__c,Type__c from Scheme_Configuration__c 
                                          where ((Project__c =:unit.RW_Project__c and Tower__c =:unit.TowerName__c) OR 
                                                 (Project__c =:unit.RW_Project__c and Tower__c =:null)) and 
                                          		 (Type__c =: opp.RW_Type_of_Client__c OR Type__c =: 'Both') and Active__c = true];
                Date bookingDate = system.today();
                if(!sc.isEmpty()){
                    if(opp.Walkin_Source__c == 'Channel Partner'){
                        List<Brokerage_Scheme__c> brokerageScheme = [select Id,Name,Base_Brokerage__c,Base_Brokerage_for_OS_NRI__c,Type__c,Base_Brokerage_for_Local_Bookings__c from Brokerage_Scheme__c where id =: sc[0].Brokerage_Scheme__c and
                                           Start_Date__c <=: bookingDate and (End_Date__c = null or End_Date__c >=: bookingDate) and Approval_Status__c = 'Approved by Level 2'];
                        if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Local'  ){
                            nrr.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'NRI'){
                            nrr.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (opp.RW_Type_of_Client__c == 'Local' || opp.RW_Type_of_Client__c == 'Corporate' )){
                            nrr.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_Local_Bookings__c;
                        }else if(!brokerageScheme.isEmpty() && brokerageScheme[0].Type__c == 'Both' && (opp.RW_Type_of_Client__c == 'NRI' || opp.RW_Type_of_Client__c == 'Outstation')){
                            nrr.Base_Brokerage__c = brokerageScheme[0].Base_Brokerage_for_OS_NRI__c;
                        }
                    }
           		}
                
                System.debug('--opp: ' + opp);
               	nrr.Opportunity__c = opp.Id;
                nrr.Customer_Name__c = opp.Name;
                nrr.Source__c = opp.Walkin_Source__c; 
                //update nrr;
                
                //nrrUpdate(nrr);
            }
            if(oppId != null || nrr.No_of_Parkings__c != null){
                nrrUpdate(nrr);
            }
            
        }else{
            /*Project_Unit__c unit = [SELECT Id, RW_Project__c, RW_Project__r.Name, RW_Param4__c, Saleable_Area__c, RW_Booking_Date__c,
									RW_Customer__r.Name, RW_Project__r.GST_Percentage_Discount__c                                  
                                    FROM Project_Unit__c WHERE Id=: recId];*/
            
            
            List<Rate_List__c> rateList = [SELECT Id, Rate__c, Global_Charges__r.Name FROM Rate_List__c WHERE Project_Unit__c =: recId];
            Map<String, Decimal> chargeVsRate = new Map<String, Decimal>();
            for(Rate_List__c rt : rateList){
                chargeVsRate.put(rt.Global_Charges__r.Name, rt.Rate__c);
            }
            
            Project_Charges__c devCharge = [SELECT Id, S_Lumpsum_Charge_Amount__c FROM Project_Charges__c WHERE 
                                                Project__c =: unit.RW_Project__c AND Name = 'Development Charges'];
            
            //nrr.Customer_Name__c = opp.Name;
            nrr.Project_Unit__c = recId;
            nrr.Project__c = unit.RW_Project__c;
            nrr.Project_Name__c = unit.RW_Project__r.Name;
            nrr.Flat_No__c = unit.RW_Param4__c;
            nrr.Saleable_Area__c = unit.Saleable_Area__c;
            //nrr.Booking_Date__c = Date.today();
            nrr.Base_Price__c = chargeVsRate.get('Basic');
            nrr.Base_Price_with_Car_Parks__c = chargeVsRate.get('Basic');
            nrr.PAGE_premium__c = 0;
            nrr.Floor_Rise__c = chargeVsRate.get('Floor Rise');
            nrr.Development_Charges__c = (chargeVsRate.get('Development Charges') > 0 ? chargeVsRate.get('Development Charges') : devCharge.S_Lumpsum_Charge_Amount__c);
            nrr.SD_in_AV__c = chargeVsRate.get('Add SD in AV');
            //nrr.Base_Brokerage__c = brokSchemes[0].Base_Brokerage_for_Local_Bookings__c;
            nrr.Payment_Plan__c = 'As per Plan';
            insert nrr;
        }
        return nrr;
    }
    
    @auraEnabled
    public static NRR__c nrrUpdate(NRR__c nrr){
        Decimal basePrice = (nrr.Base_Price_with_Car_Parks__c != null)? nrr.Base_Price_with_Car_Parks__c : 0;
        Decimal pagePremium = (nrr.PAGE_premium__c != null)? nrr.PAGE_premium__c : 0;
        Decimal gardenPremium = (nrr.Garden_Premium_NPV_any_other_premium__c != null)? nrr.Garden_Premium_NPV_any_other_premium__c : 0; 
        Decimal premium1 = (nrr.Premium_1__c != null)? nrr.Premium_1__c : 0;
        Decimal premium2 = (nrr.Premium_2__c != null)? nrr.Premium_2__c : 0;
        Decimal discount1 = (nrr.Discount_1__c != null)? nrr.Discount_1__c : 0;
        Decimal discount2 = (nrr.Discount_2__c != null)? nrr.Discount_2__c : 0;
        Decimal floorRise = (nrr.Floor_Rise__c != null)? nrr.Floor_Rise__c : 0;
        Decimal developmentCharge = (nrr.Development_Charges__c != null)? nrr.Development_Charges__c : 0;
        Decimal SDinAV = (nrr.SD_in_AV__c != null)? nrr.SD_in_AV__c : 0;
        Decimal baseBrokerage = (nrr.Base_Brokerage__c != null)? nrr.Base_Brokerage__c : 0;
        Decimal cpPassbackIfApplicable = (nrr.CP_passback_if_Applicable__c != null)? nrr.CP_passback_if_Applicable__c : 0;
        Decimal otherCost = (nrr.Other_Cost_if_any_Eg_SD_Waiver__c != null)? nrr.Other_Cost_if_any_Eg_SD_Waiver__c : 0;
        //Decimal sdImpact = (nrr.SD_impact_if_applicable__c != null)? nrr.SD_impact_if_applicable__c : 0;
        System.debug('cpPassbackIfApplicable: ' + cpPassbackIfApplicable);
        nrr.Discount_3_CP_Pass_back__c = (cpPassbackIfApplicable / nrr.Saleable_Area__c).setscale(0,RoundingMode.HALF_UP);
        
        Decimal totalRate = basePrice + pagePremium + floorRise + gardenPremium + premium1 + premium2 - (discount1 + discount2 + nrr.Discount_3_CP_Pass_back__c);
        nrr.Total_Rate__c = totalRate.setscale(0,RoundingMode.HALF_UP);
        nrr.Agreement_Value__c = (totalRate * nrr.Saleable_Area__c).setscale(0,RoundingMode.HALF_UP);
        nrr.Total_Agreement_Value__c = (nrr.Agreement_Value__c + developmentCharge + SDinAV).setscale(0,RoundingMode.HALF_UP);
        
        //nrr.AV_After_2_GST_discount__c = (nrr.Total_Agreement_Value__c * ((100 - nrr.Project_Unit__r.RW_Project__r.GST_Percentage_Discount__c)/100)).setscale(0,RoundingMode.HALF_UP);
        nrr.AV_for_Brokerage_after_deduction__c = (nrr.AV_After_2_GST_discount__c - developmentCharge - SDinAV).setscale(0,RoundingMode.HALF_UP);
        nrr.Passback__c = ((cpPassbackIfApplicable / nrr.AV_for_Brokerage_after_deduction__c)*100).setscale(2,RoundingMode.HALF_UP);
        nrr.Brokerage_to_be_paid__c = (baseBrokerage - nrr.Passback__c).setscale(2,RoundingMode.HALF_UP);
        nrr.CP_Pay_out_Referral_payout__c = ((nrr.AV_for_Brokerage_after_deduction__c * nrr.Brokerage_to_be_paid__c)/100).setscale(0,RoundingMode.HALF_UP);
        nrr.Interest_Cost_NPV_Subvention_Deffered__c = (gardenPremium * nrr.Saleable_Area__c).setscale(0,RoundingMode.HALF_UP);
        
        Decimal sdImpactVal = 0;
        if(nrr.SD_Impact_Applicable__c == 'Yes'){
            Decimal discVal = 0.06 * nrr.AV_After_2_GST_discount__c;
            String dString = String.valueOf(discVal);
            Integer index = dString.indexOf('.');
            String val = dString.substring(0,dString.indexOf('.'));
            String str = dString.substring(dString.indexOf('.')-3, dString.indexOf('.'));
            System.debug('str: ' + str);
            
            if(Integer.valueOf(str) <= 500){
                sdImpactVal = Integer.valueOf(val) + (500 - Integer.valueOf(str));
                System.debug('sdImpactVal: ' + sdImpactVal);
            }else if(Integer.valueOf(str) > 500){
                sdImpactVal = Integer.valueOf(val) + (1000 - Integer.valueOf(str));
                System.debug('sdImpactVal: ' + sdImpactVal);
            }
        }
        
        
        nrr.SD_impact_if_applicable__c = sdImpactVal;
        //nrr.GST_ITC_Benefit__c = (0.02 * nrr.Total_Agreement_Value__c).setscale(0,RoundingMode.HALF_UP);
        nrr.Net_value__c = (nrr.AV_After_2_GST_discount__c - nrr.CP_Pay_out_Referral_payout__c - nrr.Interest_Cost_NPV_Subvention_Deffered__c - otherCost + nrr.GST_ITC_Benefit__c - sdImpactVal).setscale(0,RoundingMode.HALF_UP);
        nrr.Net_Realisation__c = (nrr.Net_value__c / nrr.Saleable_Area__c).setscale(0,RoundingMode.HALF_UP);
        //nrr.Approved_NRR__c = basePrice + pagePremium + floorRise;
        update nrr;
        return nrr;
    }
    
    @auraEnabled
    public static NRR__c updateCarParks(NRR__c nrr){
        Decimal basePrice = (nrr.Base_Price__c != null)? nrr.Base_Price__c : 0; 
        Decimal parkings = (nrr.No_of_Parkings__c != null)? nrr.No_of_Parkings__c : 0;
        nrr.Base_Price_with_Car_Parks__c = basePrice + (parkings * (700000/nrr.Saleable_Area__c)).setscale(2,RoundingMode.HALF_UP);
        update nrr;
        return nrr;
    }
    
    @auraEnabled
    public static NRR__c updateGSTValues(NRR__c nrr){
        nrr.AV_After_2_GST_discount__c = (nrr.Total_Agreement_Value__c * ((100 - nrr.GST__c)/100)).setscale(0,RoundingMode.HALF_UP);
        nrr.GST_ITC_Benefit__c = ((nrr.GST__c / 100) * nrr.Total_Agreement_Value__c).setscale(0,RoundingMode.HALF_UP);
        update nrr;
        return nrr;
    }

}