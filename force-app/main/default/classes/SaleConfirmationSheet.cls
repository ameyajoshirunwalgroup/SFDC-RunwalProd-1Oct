public class SaleConfirmationSheet {
        
        public List<Booking__c> b {get;set;} 
        public String  Discount {get;set;}
        public Id BookingId {get;set;}
        public List<Applicant_Details__c> ad {get;set;} 
        public List<Project_Unit__c> pu {get;set;}      
        public List<String> strapp{ get;set;} 
        public Map<String,Applicant_Details__c>  map1{get;  set;}
        public string primaryappname{get;set;}
        public string primaryappname1{get;set;}
        public string primaryappname2{get;set;}
        public string panno1 {get;set;}
        public string panno2 {get;set;}
        public string panno3 {get;set;}
        public String allotment{get;set;}
        public String baserate{get;set;}
        public String argv{get;set;}
        // public String refCreditDue{get;set;}//Added for Referral redit Changes
        public String totl{get;set;}
        public Decimal dupargv{get;set;}
        public String societyChr{get;set;}
        public string panNos{get;set;}
        public String maintnce{get;set;}
        public Decimal totalrate{get;set;}
        public String  wcpartner {get;set;}
        public Map<String, String> m {get;set;} // added for rate list
        public String totalDiscount{get;set;}
        public String totalpremium{get;set;}
        Integer i;
        public String BCAMCharges {get;set;}
        public String CAMCharges{get;set;}
        public string payouuts {get;set;}
        public string SocietyCharge{get;set;}
        public decimal lumpsumintoRate{get; set;}
    	
    	//Added by Dolly
        public List<Quote_Applied_Discounts__c> quoteDiscounts {get; set;}
        public List<OtherChargeWrapper> otherChargesList {get; set;}
        public List<Quote_Applied_Discounts__c> monetaryDiscounts {get; set;}
        public List<Quote_Applied_Discounts__c> nonMonetaryDiscounts {get; set;}
        public Decimal totalMonetaryDiscount {get; set;}
        public Decimal totalNonMonetaryDiscount {get; set;}
        public Decimal carpetAreaWithService {get; set;}
    	public String referralDiscountDisplay {get;set;}
        public String referralPassbackDisplay {get;set;}
        public String referralCreditDisplay {get;set;}
        public String referralDiscountLabel {get;set;}
        public String referralPassbackLabel {get;set;}
        public String referralCreditLabel {get;set;}
        public String typeOfAllotment {get; set;}
        public class OtherChargeWrapper {
            public String description {get; set;}
            public Decimal amount {get; set;}
        }
        public ApexPages.StandardController stdController;

        //constructor start
        public SaleConfirmationSheet(ApexPages.StandardController controller)
        {
            this.stdController = controller;
            Booking__c obj = (Booking__c)controller.getRecord();
            BookingId = obj.Id;
            Discount = '';
            payouuts='';
            totalrate = 0;
            m = new Map<String, String>() ;
            totl = '';
            allotment ='';
            argv='';
            // refCreditDue='';//Added for Referral Credit Changes
            dupargv=0;
            primaryappname= '';
            primaryappname1= '';
            primaryappname2  = '';  
            BCAMCharges = '';
            CAMCharges = '';  
            wcpartner= '';
            b   = new List<Booking__c>();
            ad  = new List<Applicant_Details__c>(); 
            pu  = new List<Project_Unit__c>(); 
            quoteDiscounts = new List<Quote_Applied_Discounts__c>();
            monetaryDiscounts = new List<Quote_Applied_Discounts__c>();
            nonMonetaryDiscounts = new List<Quote_Applied_Discounts__c>();
            otherChargesList = new List<OtherChargeWrapper>();
            totalDiscount ='';
            totalpremium= '';
            primaryappname='';
            
            //select booking details
            
            b = [Select Id, Name,Project__c, Project__r.RW_Project_Image__c,Project__r.RERA_Certificate_No__c,
                 Flat_No__c,Referred_By__c,BrokerIId__r.RW_RERA_Registration_Number__c,Project__r.Name,
                 Primary_Applicant_Email__c,Unit_No__c,Sub_Source__c,Source_of_Booking__c,Broker_Name__c,Booking_Date__c,
                 Wing__c,Token_Amount__c,Contact_No_of_Referer_Customer_Custome__c, Allotment_Premium__c,No_of_Parking__c,
                 Company__c,Sales_Managers__c,Quotation__r.Project_Maintenance_Charges_Amount_1__c,BrokerIId__c,BrokerIId__r.name,
                 Quotation__r.Total_No_of_Parking__c,Quotation__r.Other_Charges_Amount_1__c,Quotation__r.Modified_Allotment_Charge__c,Quotation__r.BCAM_Charges__c,
                 Customer_Reference_Opportunity__c,Customer_Reference_Opportunity__r.RW_Project__c,Customer_Reference_Opportunity__r.RW_Project_Unit__c,
                 Quotation__r.CAM_Charges__c,Unit_No__r.Name,Unit_No__r.SD_Paid_By_Runwal__c,Customer_Reference_Opportunity__r.RW_Project__r.Name,Customer_Reference_Opportunity__r.RW_Project_Unit__r.name,
                 Quotation__r.Base_Rate_PSF_D__c,Quotation__r.Base_Rate_PSF__c,Quotation__r.Original_Allotment_Charge__c,Quotation__r.Agreement_Value_D__c,
                 Quotation__r.Agreement_Value__c,Quotation__r.Total_Discount_PSF__c,Quotation__r.Other_Charges_Total__c ,
                 Project__r.allotment_charges_1__c ,Quotation__r.single_car_park_additional__c,Quotation__r.Single_car_park_Earmarked__c,
                 Project__r.allotment_charges_2__c ,Quotation__r.Tandem_car_park_additional__c,Quotation__r.Tandem_car_park_Earmarked__c,
                 Project__r.allotment_charges_3__c ,Quotation__r.Single_Open_additional__c,Quotation__r.Single_Open_Earmarked__c,
                 Project__r.Allotment_Charges_10__c ,Quotation__r.Tandem_Open_additional__c,Quotation__r.Tandem_Open_Earmarked__c,
                 Project__r.Allotment_Charges_7__c ,Quotation__r.Basement_Additional__c,Quotation__r.Basement_Earmarked__c,
                 Project__r.Allotment_Charges_8__c ,Quotation__r.Podium__c,Quotation__r.Podium_Earmarked__c,
                 Project__r.Allotment_Charges_5__c ,Quotation__r.Stilt_Earmarked__c,Quotation__r.Stack_Additional__c,
                 Project__r.Allotment_Charges_4__c ,Quotation__r.Covered_Stack_Earmarked__c,Quotation__r.Covered_Stack_Additional__c,
                 Project__r.Stack_Car_Park_Charges__c ,Quotation__r.Stack_Earmarked__c,Quotation__r.Stack_Additional_1__c,
                 Project__r.Allotment_Charges_9__c ,Quotation__r.Puzzle_Car_Park_Earmarked__c,Quotation__r.Puzzle_Car_Park__c,
                 opportunity__r.RW_Walkin_Channel_Partner__c,opportunity__r.RW_Walkin_Channel_Partner__r.Name,
                 Project__r.allotment_charges_6__c ,Quotation__r.MLCP_Additional__c,Quotation__r.MLCP_Earmarked__c,
                 Quotation__r.Premium_Charges_Amount_1__c ,Quotation__r.Premium_Charges_Amount_2__c,Quotation__r.Premium_Charges_Amount_3__c,
                 Quotation__r.Premium_Charges_Amount_4__c/*,Quotation__r.Referral_Credit_Due__c*/,
                 Quotation__r.Other_Charges_Desc_1__c,  Quotation__r.Other_Charges_Desc_2__c, Quotation__r.Other_Charges_Amount_2__c,
                 Quotation__r.Other_Charges_Desc_3__c, Quotation__r.Other_Charges_Amount_3__c, Quotation__r.Other_Charges_Desc_4__c,
                 Quotation__r.Other_Charges_Amount_4__c, Quotation__r.Other_Charges_Desc_5__c, Quotation__r.Other_Charges_Amount_5__c,
                 Quotation__r.Other_Charges_Desc_6__c, Quotation__r.Other_Charges_Amount_6__c, Quotation__r.Other_Charges_Desc_7__c, Quotation__r.Other_Charges_Amount_7__c,
                 Quotation__r.Other_Charges_Desc_8__c, Quotation__r.Other_Charges_Amount_8__c, Quotation__r.Other_Charges_Desc_9__c, Quotation__r.Other_Charges_Amount_9__c,
                 Quotation__r.Other_Charges_Desc_10__c, Quotation__r.Other_Charges_Amount_10__c, Quotation__r.Other_Charges_Desc_11__c, Quotation__r.Other_Charges_Amount_11__c,
                 Quotation__r.Other_Charges_Desc_12__c, Quotation__r.Other_Charges_Amount_12__c, Quotation__r.Other_Charges_Desc_13__c, Quotation__r.Other_Charges_Amount_13__c,
                 Quotation__r.Other_Charges_Desc_14__c, Quotation__r.Other_Charges_Amount_14__c, Quotation__r.Other_Charges_Desc_15__c, Quotation__r.Other_Charges_Amount_15__c,
                 Quotation__r.Other_Charges_Desc_16__c, Quotation__r.Other_Charges_Amount_16__c, Quotation__r.Other_Charges_FCAM_Description__c, Quotation__r.Other_Charges_FCAM__c,
                 Quotation__r.Stamp_Duty_and_Registration_Total_D__c,Quotation__r.PaymentPlan__r.Name,Quotation__r.Referral_Discounted_Value__c,Quotation__r.Referral_Passback_Value__c,
                 Quotation__r.Referral_Credit_Due__c,Customer_reference_SAP_Code__c,Customer_Reference_Opportunity__r.Name,Referral__c,Referral_Passback__c,Referral_Discount__c,
                 Quotation__c, Quotation__r.Agreement_Value_D_R__c,Quotation__r.SD_By_Runwal__c,Quotation__r.Stamp_Duty__c
                 From Booking__c Where id =: BookingId]; // Removed the Company__c field from soql by Vinay 01-10-2025//Added Referral_Credit_Due__c for Referral Changes
            

            //select unit details for perticuler unit no
            id uId = b[0].Unit_No__c;
            pu = [Select Id, Name, Project_Unit_Type__c,Carpet_Area__c,Saleable_Area__c,View__c,RW_Param4__c,Service_Room_Carpet_Area__c From Project_Unit__c Where id =: uId]; 
            System.debug(pu);
            
            if(b[0].opportunity__r.RW_Walkin_Channel_Partner__c != null) {
                wcpartner = '('+b[0].opportunity__r.RW_Walkin_Channel_Partner__r.Name+')';
            }
            carpetAreaWithService = pu[0].Carpet_Area__c;

            Decimal saleableArea = pu[0].Saleable_Area__c;
            
            //Added by Dolly
            List<Quote_Applied_Discounts__c> allDiscounts = new List<Quote_Applied_Discounts__c>();
            // ================= FETCH QUOTE DISCOUNTS =================
            if(b != null && !b.isEmpty() && b[0].Quotation__c != null) {
                
                Id quoteId = b[0].Quotation__c;
    
                allDiscounts = [
                    SELECT Id, Name, Offer_Value__c, Discount_Category__c, Offer_type__c, Monetizable__c
                    FROM Quote_Applied_Discounts__c
                    WHERE Quotation__c = :quoteId
                ];
    
                for(Quote_Applied_Discounts__c qd : allDiscounts){
                    if(qd.Discount_Category__c == 'Monetary'){
                        monetaryDiscounts.add(qd);
                    } else {
                        nonMonetaryDiscounts.add(qd);
                    }

                    //LOGIC FOR NPV & CP PASSBACK
                    if(qd.Name != null && qd.Offer_Value__c != null && saleableArea > 0){
                        if(qd.Discount_Category__c == 'Monetary'){
                            //if(qd.Name.containsIgnoreCase('NPV') || qd.Name.containsIgnoreCase('CP Passback')){

                                Decimal rate = (qd.Offer_Value__c / saleableArea).setScale(0, RoundingMode.HALF_UP);
                                if(rate>0 && rate!=null){
                                    String rateStr = 'Rs ' + rate + ' PER SQ.FT. (' + 
                                                INFormat(qd.Offer_Value__c) + ' - ' + qd.Name + ')';

                                    // add in rate details map
                                    m.put(qd.Name, rateStr);

                                    // since these are discounts → subtract
                                    totalrate -= rate;
                                }

                                System.debug('Added discount rate for ' + qd.Name + ' : ' + rate);
                            //}
                        }
                    }
                }

                // ===== CALCULATE TOTALS =====
                totalMonetaryDiscount = 0;
                for(Quote_Applied_Discounts__c qd : monetaryDiscounts){
                    if(qd.Offer_Value__c != null){
                        totalMonetaryDiscount += qd.Offer_Value__c;
                    }
                }
                
                totalNonMonetaryDiscount = 0;
                for(Quote_Applied_Discounts__c qd : nonMonetaryDiscounts){
                    if(qd.Offer_Value__c != null){
                        totalNonMonetaryDiscount += qd.Offer_Value__c;
                    }
                }
    
                for(Integer i = 1; i <= 16; i++) {
                    String descField = 'Other_Charges_Desc_' + i + '__c';
                    String amtField  = 'Other_Charges_Amount_' + i + '__c';

                    String descp = (String)b[0].Quotation__r.get(descField);
                    Decimal amt = (Decimal)b[0].Quotation__r.get(amtField);

                    addOtherCharge(descp, amt);
                }

                // extra fields
                addOtherCharge(
                    b[0].Quotation__r.Other_Charges_FCAM_Description__c,
                    b[0].Quotation__r.Other_Charges_FCAM__c
                );

                addOtherCharge('BCAM Charges', b[0].Quotation__r.BCAM_Charges__c);
    
            }
            // ========================================================
             
            

            // ================= LABELS =================
            if(b[0].Referral_Discount__c != null){
                referralDiscountLabel = 'REFERRAL/LOYALTY DISCOUNTED VALUE (' + b[0].Referral_Discount__c + '%)';
            }else{
                referralDiscountLabel = 'REFERRAL/LOYALTY DISCOUNTED VALUE';
            }
            
            if(b[0].Referral_Passback__c != null){
                referralPassbackLabel = 'REFERRAL/LOYALTY PASSBACK VALUE (' + b[0].Referral_Passback__c + '%)';
            }else{
                referralPassbackLabel = 'REFERRAL/LOYALTY PASSBACK VALUE';
            }
            
            if(b[0].Referral__c != null){
                referralCreditLabel = 'REFERRAL/LOYALTY CREDIT DUE (' + b[0].Referral__c + '%)';
            }else{
                referralCreditLabel = 'REFERRAL/LOYALTY CREDIT DUE';
            }
            
            
            // ================= VALUES =================
            Decimal totalValue = 0;
            Decimal rate = 0;
            // REFERRAL DISCOUNT
            if(b[0].Quotation__r.Referral_Discounted_Value__c != null && saleableArea > 0){
                
                totalValue = b[0].Quotation__r.Referral_Discounted_Value__c !=null ? b[0].Quotation__r.Referral_Discounted_Value__c : 0;
                if(saleableArea > 0 && totalValue > 0 ){
                    rate = (totalValue / saleableArea).setScale(0, RoundingMode.HALF_UP);
            		referralDiscountDisplay = INFormat(totalValue) + ' (' + rate + ' PER SQ.FT.)';
                     

                    string referralRateStr='Rs '+  rate + ' PER SQ.FT. (' + INFormat(totalValue) + ' - REFERRAL DISCOUNT)';
                    m.put('Referral Discount', referralRateStr);

                    totalrate -= rate; // since it's discount
                }
                
            }
            else{
                    referralDiscountDisplay = 'Rs 0/-';
                }
            
            // REFERRAL PASSBACK
            if(b[0].Quotation__r.Referral_Passback_Value__c != null && saleableArea > 0){
                
                totalValue = b[0].Quotation__r.Referral_Passback_Value__c !=null ? b[0].Quotation__r.Referral_Passback_Value__c : 0;
                if(saleableArea > 0 && totalValue > 0 ) {
                    rate = (totalValue / saleableArea).setScale(0, RoundingMode.HALF_UP);
            
                    referralPassbackDisplay = INFormat(totalValue) + ' (' + rate + ' PER SQ.FT.)';

                    string referralPassbackValueRateStr='Rs '+  rate + ' PER SQ.FT. (' + INFormat(totalValue) + ' - REFERRAL/LOYALTY PASSBACK)';
                    m.put('Referral Passback', referralPassbackValueRateStr);

                    totalrate -= rate; // since it's discount
                }
                
            }
            else{
                     referralPassbackDisplay = 'Rs 0/-';
                }
            
        
            Boolean isReferral = b[0].Source_of_Booking__c == 'Referral';
            Boolean isCP = b[0].Source_of_Booking__c == 'CHANNEL PARTNER';
            if(saleableArea > 0){

                // ================= REFERRAL =================
                if(isReferral && b[0].Quotation__r.Referral_Credit_Due__c != null){

                    totalValue = b[0].Quotation__r.Referral_Credit_Due__c;

                }

                // ================= CHANNEL PARTNER =================
                else if(isCP){

                    for(Quote_Applied_Discounts__c qd : allDiscounts){

                        // 🔥 IMPORTANT: adjust Name / field condition as per your org
                        if(qd.Name != null && qd.Name.containsIgnoreCase('CP Passback')){

                            totalValue += (qd.Offer_Value__c != null ? qd.Offer_Value__c : 0);
                        }
                    }
                }

                // ================= COMMON DISPLAY =================
                if(totalValue > 0){

                    rate = (totalValue / saleableArea).setScale(0, RoundingMode.HALF_UP);

                    referralCreditDisplay = INFormat(totalValue) + 
                                            ' (' + rate + ' PER SQ.FT.)';

                } else {
                    referralCreditDisplay = 'Rs 0/-';
                }

            } else {
                referralCreditDisplay = 'Rs 0/-';
            }
            
            //Added by Dolly till here
            
            if(pu[0].Service_Room_Carpet_Area__c != null && pu[0].Service_Room_Carpet_Area__c != 0) {
                carpetAreaWithService += pu[0].Service_Room_Carpet_Area__c;
            }
            if(!b[0].Source_of_Booking__c.equalsIgnoreCase('CHANNEL PARTNER'))
                payouuts = 'NA';
            //added today for rate list 
            List<Rate_List__c> results = [SELECT Id,Amount__c,Rate__c,ChargeCost__c,Charged_Based_On__c,Project_Unit__R.Actual_Area_value__c,Global_Charges__r.name,Project_Charges__c,Project_Charges__r.name FROM Rate_List__c  WHERE Project_Unit__c =:uId AND Project_Charges__r.S_Charge_Bucket__c='Agreement Value'];
            system.debug('Rate List : ' + results);
            Decimal basicandBCAM = 0;
            for( Rate_List__c r: results )
            {
                if(r.Charged_Based_On__c != null && r.Charged_Based_On__c.equalsIgnoreCase('Rate')) {
                    system.debug('All Rate list values' + r.Rate__c );
                    if(r.Rate__c > 0) {
                        String s = '';
                        
                        s = INFormat(r.Rate__c) +' PER SQ.FT. ' + '(' + r.Project_Charges__r.name + ')' ;
                        ///} 
                        if(!r.Project_Charges__r.name.containsIgnoreCase('Premium') &&
                           !r.Project_Charges__r.name.containsIgnoreCase('Basic') &&
                           !r.Project_Charges__r.name.containsIgnoreCase('BCAM') &&
                           !r.Project_Charges__r.name.containsIgnoreCase('CAM')) {
                            m.put(r.Project_Charges__r.name, s);
                            totalrate += r.Rate__c;
                          system.debug('Total rate for basic :' + totalrate );     
                         
                        }
                        if(r.Project_Charges__r.name.containsIgnoreCase('Basic') 
                           || r.Project_Charges__r.name.containsIgnoreCase('BCAM')
                           || r.Project_Charges__r.name.containsIgnoreCase('CAM')) {
                            basicandBCAM += r.Rate__c; 
                           
                          system.debug('Added value for basic :' + basicandBCAM );
                        }
                     }
                }
                else if(r.Charged_Based_On__c != null && r.Charged_Based_On__c.equalsIgnoreCase('Lumpsum')){
                    system.debug('In lumpsum');
                    system.debug('r.Amount__c :' + r.Amount__c);
                     if(r.Amount__c  > 0) {
                         lumpsumintoRate =((r.Amount__c / pu[0].Saleable_Area__c).setscale(0,RoundingMode.HALF_UP));// convert into rate from lumpsum
                         system.debug('r.Amount__c :' + r.Amount__c);
                         String s = '';
                         s = INFormat(lumpsumintoRate) +' PER SQ.FT. ' + '(' + r.Project_Charges__r.name + ')' ; 
                         
                         system.debug('Formated lumpsum value:' + s);
                         
                         if(!r.Project_Charges__r.name.containsIgnoreCase('Premium') &&
                            !r.Project_Charges__r.name.containsIgnoreCase('Basic') &&
                            !r.Project_Charges__r.name.containsIgnoreCase('BCAM') &&
                            !r.Project_Charges__r.name.containsIgnoreCase('CAM')) {
                             m.put(r.Project_Charges__r.name, s); 
                             totalrate += lumpsumintoRate;
                         }
                      
                         system.debug('Added lumpsum bcam and cam into total:' + totalrate );
                         
                         if(r.Project_Charges__r.name.containsIgnoreCase('Basic') 
                           || r.Project_Charges__r.name.containsIgnoreCase('BCAM')
                           || r.Project_Charges__r.name.containsIgnoreCase('CAM')) {
                            basicandBCAM += lumpsumintoRate; 
                               
                         system.debug('Added lumpsum bcam and cam into basic:' + basicandBCAM );
                         }
                                        
                     }
                    
                }
                
                
                // totalrate += r.Rate__c;
            }
            String BasicBCAM = '';
            if(basicandBCAM != 0) 
              system.debug('Check BCAM and basic value:' + basicandBCAM );
              system.debug('total rate:' + totalrate );
            {
                BasicBCAM = INFormat(basicandBCAM) +' PER SQ.FT.(Basic)'; 
                m.put('Basic', BasicBCAM) ;
                totalrate += basicandBCAM;
                
                system.debug('bcam cam and basic added into totalrate:' + totalrate );
            }
            
           /* if(b[0].Quotation__r.BCAM_Charges__c > 0) {
                BCAMCharges = INFormat(b[0].Quotation__r.BCAM_Charges__c);
            }
            if(b[0].Quotation__r.CAM_Charges__c > 0) {
                CAMCharges = INFormat(b[0].Quotation__r.CAM_Charges__c);
            } */
            
            if(b[0].Quotation__r.Total_Discount_PSF__c != null && b[0].Quotation__r.Total_Discount_PSF__c > 0){
                totalDiscount =INFormat(b[0].Quotation__r.Total_Discount_PSF__c) +' PER SQ.FT.(Discount) ' ;
                //m.put('Discount', s);
                system.debug('totalDiscount :'  + totalDiscount );
                totalrate =  totalrate - b[0].Quotation__r.Total_Discount_PSF__c;
                system.debug('discount minus totalrate :'  + totalrate );
            }
            /*if(b[0].Quotation__r.Premium_Charges_Amount_1__c != null && b[0].Quotation__r.Premium_Charges_Amount_1__c > 0
               || b[0].Quotation__r.Premium_Charges_Amount_2__c != null && b[0].Quotation__r.Premium_Charges_Amount_2__c > 0 
               || b[0].Quotation__r.Premium_Charges_Amount_3__c != null && b[0].Quotation__r.Premium_Charges_Amount_3__c > 0
               || b[0].Quotation__r.Premium_Charges_Amount_4__c != null && b[0].Quotation__r.Premium_Charges_Amount_4__c > 0 ) {*/
                //m.put('Discount', s);
            
                totalpremium =INFormat( b[0].Quotation__r.Premium_Charges_Amount_1__c + b[0].Quotation__r.Premium_Charges_Amount_2__c + b[0].Quotation__r.Premium_Charges_Amount_3__c + b[0].Quotation__r.Premium_Charges_Amount_4__c) + ' PER SQ.FT.(Premium) ' ;
                //m.put('Discount', s);
                system.debug('totalpremium :'  + totalpremium );
                totalrate =  totalrate + (b[0].Quotation__r.Premium_Charges_Amount_1__c + b[0].Quotation__r.Premium_Charges_Amount_2__c + b[0].Quotation__r.Premium_Charges_Amount_3__c + b[0].Quotation__r.Premium_Charges_Amount_4__c) ;
                                                                                                                                                                                                 
            // m.put('TOTAL RATE',  INFormat(totalrate));
            
            totalrate = totalrate.setScale(0, RoundingMode.HALF_UP);
            ///////   
            
            //select booking details
            ad = [Select Id, Name,DOB__c,PancardNo__c,Permanent_Address__c,Applicant_Number__c,
                  Mobile_Number__c,Landline_Number__c,Salutation__c,Mailing_Address__c ,
                  Email_Address__c,Organization_Name__c,Designation__c,Organization_Address__c 
                  From Applicant_Details__c Where Booking__c =: BookingId order by createdDate asc];
            
            panNos = '';
            
            for(Applicant_Details__c a : ad)
            {
                if(a.Pancardno__c != null && panNos != '')
                {
                    panNos += ' / ' + a.Pancardno__c;
                }
                else if(a.Pancardno__c != null && panNos == '')
                {
                    panNos += a.Pancardno__c;
                }
            }
            
            
            system.debug(ad);
            
            //for selecting number of applicant
            strapp = new List <String>{'1','2','3'};
                map1 = new Map<String,Applicant_Details__c>(); 
            
            for(Applicant_Details__c a: ad)
            {   
                
                if(a.Applicant_Number__c=='Primary Applicant')
                {primaryappname = a.name; panno1 = a.PancardNo__c;}
                else if(a.Applicant_Number__c=='second Applicant')
                {primaryappname1 = a.Name;panno2 =a.PancardNo__c;}
                else if(a.Applicant_Number__c=='third Applicant')
                {primaryappname2 =a.Name; panno3 =a.PancardNo__c;}             
            }
            //  allotment charge
            /*if(b[0].Quotation__r.Modified_Allotment_Charge__c != null && b[0].Quotation__r.Modified_Allotment_Charge__c> 0 ) 
    allotment = QuotationManagementServices.INFormat(b[0].Quotation__r.Modified_Allotment_Charge__c);
    else{
    allotment =QuotationManagementServices.INFormat(b[0].Quotation__r.Original_Allotment_Charge__c);
    }
    */
            //base rate check
            if(b[0].Quotation__r.Base_Rate_PSF_D__c !=null && b[0].Quotation__r.Base_Rate_PSF_D__c > 0)
                baserate = QuotationManagementServices.INFormat(b[0].Quotation__r.Base_Rate_PSF_D__c);
            else{
                baserate = QuotationManagementServices.INFormat(b[0].Quotation__r.Base_Rate_PSF__c);
            }
            //agreement value check
            if(b[0].Source_of_Booking__c =='Referral'){
                if(b[0].Quotation__r.Agreement_Value_D_R__c !=null && b[0].Quotation__r.Agreement_Value_D_R__c > 0){  
                    argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value_D_R__c);
                    dupargv =  b[0].Quotation__r.Agreement_Value_D_R__c;
                }
                else{
                    argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value__c);
                    dupargv =  b[0].Quotation__r.Agreement_Value__c;
                }
            }else{
                if(b[0].Quotation__r.Agreement_Value_D__c !=null && b[0].Quotation__r.Agreement_Value_D__c > 0){  
                    argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value_D__c);
                    dupargv =  b[0].Quotation__r.Agreement_Value_D__c;
                }else{
                    argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value__c);
                    dupargv =  b[0].Quotation__r.Agreement_Value__c;
                }
            }


            // if(b[0].Quotation__r.Agreement_Value_D__c !=null && b[0].Quotation__r.Agreement_Value_D__c > 0)
            // {  argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value_D__c);
            //  dupargv =  b[0].Quotation__r.Agreement_Value_D__c;
            // }
            // else{
            //     argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value__c);
            //     dupargv =  b[0].Quotation__r.Agreement_Value__c;
            // }
            /**Added for Referral Changes starts */
            // if(b[0].Quotation__r.Referral_Credit_Due__c!=null ){
            //   refCreditDue = QuotationManagementServices.INFormat(b[0].Quotation__r.Referral_Credit_Due__c);
            // }
            /**Added for Referral Changes ends */
    
            decimal dSocietyC = 0;
            if(b[0].Quotation__r.Other_Charges_Amount_9__c > 0) {
                societyChr= QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Amount_9__c);
                dSocietyC = b[0].Quotation__r.Other_Charges_Amount_9__c;
            }
            if(b[0].Quotation__r.Other_Charges_Amount_1__c > 0) {
                societyChr= QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Amount_1__c);
                dSocietyC = b[0].Quotation__r.Other_Charges_Amount_1__c;
            }
            //maintnce=QuotationManagementServices.INFormat(b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c);
            Decimal fcam = b[0].Quotation__r.Other_Charges_FCAM__c != null 
                ? b[0].Quotation__r.Other_Charges_FCAM__c : 0;

            Decimal bcam = b[0].Quotation__r.BCAM_Charges__c != null 
                ? b[0].Quotation__r.BCAM_Charges__c : 0;

            Decimal otherCharges = b[0].Quotation__r.Other_Charges_Total__c != null 
                ? b[0].Quotation__r.Other_Charges_Total__c : 0;
            maintnce=QuotationManagementServices.INFormat(fcam + bcam);
            // SocietyCharge = QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Total__c - b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c);
            // totl =  QuotationManagementServices.INFormat(dupargv + b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c + (b[0].Quotation__r.Other_Charges_Total__c - b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c));

            SocietyCharge = QuotationManagementServices.INFormat(otherCharges - (fcam + bcam));
            totl =  QuotationManagementServices.INFormat(dupargv + otherCharges);
            
            //Modified by Dolly
            Decimal carParkAmount1 = 0;

            // 🔥 ADD THIS
            List<String> allotmentTypes = new List<String>();

            // 1. Single Car Park
            Decimal single = getValue(b[0].Quotation__r.Single_car_park_Earmarked__c) + 
                            getValue(b[0].Quotation__r.single_car_park_additional__c);

            if(single > 0) {

                carParkAmount1 += getValue(b[0].project__r.allotment_charges_1__c) * single;

                // 🔥 ADD THIS
                allotmentTypes.add('Single Covered (' + Integer.valueOf(single) + ')');
            }

            // 2. Tandem Car Park
            Decimal tandem = getValue(b[0].Quotation__r.Tandem_car_park_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Tandem_car_park_additional__c);

            if(tandem > 0) {

                carParkAmount1 += getValue(b[0].project__r.allotment_charges_2__c) * tandem;

                allotmentTypes.add('Tandem Covered (' + Integer.valueOf(tandem) + ')');
            }

            // 3. Single Open
            Decimal singleOpen = getValue(b[0].Quotation__r.Single_Open_Earmarked__c) + 
                                getValue(b[0].Quotation__r.Single_Open_additional__c);

            if(singleOpen > 0) {

                carParkAmount1 += getValue(b[0].project__r.allotment_charges_3__c) * singleOpen;

                allotmentTypes.add('Single Open (' + Integer.valueOf(singleOpen) + ')');
            }

            // 4. Tandem Open
            Decimal tandemOpen = getValue(b[0].Quotation__r.Tandem_Open_Earmarked__c) + 
                                getValue(b[0].Quotation__r.Tandem_Open_additional__c);

            if(tandemOpen > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_10__c) * tandemOpen;

                allotmentTypes.add('Tandem Open (' + Integer.valueOf(tandemOpen) + ')');
            }

            // 5. Stilt / Stack
            Decimal stilt = getValue(b[0].Quotation__r.Stilt_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Stack_Additional__c);

            if(stilt > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_5__c) * stilt;

                allotmentTypes.add('Stilt (' + Integer.valueOf(stilt) + ')');
            }

            // 6. MLCP
            Decimal mlcp = getValue(b[0].Quotation__r.MLCP_Earmarked__c) + 
                        getValue(b[0].Quotation__r.MLCP_Additional__c);

            if(mlcp > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_6__c) * mlcp;

                allotmentTypes.add('MLCP (' + Integer.valueOf(mlcp) + ')');
            }

            // 7. Basement
            Decimal basement = getValue(b[0].Quotation__r.Basement_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Basement_Additional__c);

            if(basement > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_7__c) * basement;

                allotmentTypes.add('Basement (' + Integer.valueOf(basement) + ')');
            }

            // 8. Podium
            Decimal podium = getValue(b[0].Quotation__r.Podium_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Podium__c);

            if(podium > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_8__c) * podium;

                allotmentTypes.add('Podium (' + Integer.valueOf(podium) + ')');
            }

            // 9. Covered Stack
            Decimal covered = getValue(b[0].Quotation__r.Covered_Stack_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Covered_Stack_Additional__c);

            if(covered > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_4__c) * covered;

                allotmentTypes.add('Covered Stack (' + Integer.valueOf(covered) + ')');
            }

            // 10. Stack
            Decimal stack = getValue(b[0].Quotation__r.Stack_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Stack_Additional_1__c);

            if(stack > 0) {

                carParkAmount1 += getValue(b[0].project__r.Stack_Car_Park_Charges__c) * stack;

                allotmentTypes.add('Stack Car Park (' + Integer.valueOf(stack) + ')');
            }

            // 11. Puzzle
            Decimal puzzle = getValue(b[0].Quotation__r.Puzzle_Car_Park_Earmarked__c) + 
                            getValue(b[0].Quotation__r.Puzzle_Car_Park__c);

            if(puzzle > 0) {

                carParkAmount1 += getValue(b[0].project__r.Allotment_Charges_9__c) * puzzle;

                allotmentTypes.add('Puzzle Car Park (' + Integer.valueOf(puzzle) + ')');
            }

            // FINAL AMOUNT
            allotment = INFormat(carParkAmount1);

            // 🔥 FINAL TYPE STRING
            if(!allotmentTypes.isEmpty()){
                typeOfAllotment = String.join(allotmentTypes, ', ');
            }else{
                typeOfAllotment = 'NA';
            }
            
        }
        
        Decimal getValue(Decimal val) {
            return val == null ? 0 : val;
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
    
        public void addOtherCharge(String description, Decimal amt) {
        if(description != null && amt != null && amt > 0) {
            OtherChargeWrapper oc = new OtherChargeWrapper();
            oc.description = description;
            oc.amount = amt;
            otherChargesList.add(oc);
        }
    }
        public Decimal otherChargesTotal {
        get {
            Decimal total = 0;
            
            if(otherChargesList != null){
                for(OtherChargeWrapper oc : otherChargesList){
                    if(oc.amount != null){
                        total += oc.amount;
                    }
                }
            }
            
            return total;
        }
    }
        
       
    }