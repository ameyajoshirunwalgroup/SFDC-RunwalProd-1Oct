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
    //constructor start
    public SaleConfirmationSheet()
    {
        Discount = '';
        payouuts='';
        totalrate = 0;
        m = new Map<String, String>() ;
        totl = '';
        allotment ='';
        argv='';
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
        totalDiscount ='';
        totalpremium= '';
        primaryappname='';
        
        //select booking details
        BookingId = ApexPages.currentpage().getParameters().get('id');
        
        b = [Select Id, Name,Project__c, Project__r.RW_Project_Image__c,Project__r.RERA_Certificate_No__c,
             Flat_No__c,Referred_By__c,BrokerIId__r.RW_RERA_Registration_Number__c,Project__r.Name,
             Primary_Applicant_Email__c,Unit_No__c,Sub_Source__c,Source_of_Booking__c,Broker_Name__c,Booking_Date__c,
             Wing__c,Token_Amount__c,Contact_No_of_Referer_Customer_Custome__c, Allotment_Premium__c,No_of_Parking__c,
             Company__c,Sales_Managers__c,Quotation__r.Project_Maintenance_Charges_Amount_1__c,Quotation__r.Other_Charges_Amount_9__c,
             Quotation__r.Total_No_of_Parking__c,Quotation__r.Other_Charges_Amount_1__c,Quotation__r.Modified_Allotment_Charge__c,Quotation__r.BCAM_Charges__c,Quotation__r.CAM_Charges__c,
             Quotation__r.Base_Rate_PSF_D__c,Quotation__r.Base_Rate_PSF__c,Quotation__r.Original_Allotment_Charge__c,Quotation__r.Agreement_Value_D__c,
             Quotation__r.Agreement_Value__c,Quotation__r.Total_Discount_PSF__c,Quotation__r.Other_Charges_Total__c ,
             Project__r.allotment_charges_1__c ,Quotation__r.single_car_park_additional__c,
             Project__r.allotment_charges_2__c ,Quotation__r.Tandem_car_park_additional__c,
             Project__r.allotment_charges_3__c ,Quotation__r.Single_Open_additional__c,
             Project__r.allotment_charges_4__c ,Quotation__r.Tandem_Open_additional__c,
             Project__r.allotment_charges_5__c ,Quotation__r.Stack_Additional__c,opportunity__r.RW_Walkin_Channel_Partner__c,opportunity__r.RW_Walkin_Channel_Partner__r.Name,
             Project__r.allotment_charges_6__c ,Quotation__r.MLCP_Additional__c,
             Quotation__r.Premium_Charges_Amount_1__c ,Quotation__r.Premium_Charges_Amount_2__c,Quotation__r.Premium_Charges_Amount_3__c,
             Quotation__r.Premium_Charges_Amount_4__c
             From Booking__c Where id =: BookingId];
        
         
        //select unit details for perticuler unit no
        id uId = b[0].Unit_No__c;
        pu = [Select Id, Name, Project_Unit_Type__c,Carpet_Area__c,Saleable_Area__c,View__c,RW_Param4__c From Project_Unit__c Where id =: uId]; 
        System.debug(pu);
        
        if(b[0].opportunity__r.RW_Walkin_Channel_Partner__c != null) {
            wcpartner = '('+b[0].opportunity__r.RW_Walkin_Channel_Partner__r.Name+')';
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
        
        totalrate = totalrate.setScale(0);
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
        if(b[0].Quotation__r.Agreement_Value_D__c !=null && b[0].Quotation__r.Agreement_Value_D__c > 0)
        {  argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value_D__c);
         dupargv =  b[0].Quotation__r.Agreement_Value_D__c;
        }
        else{
            argv = QuotationManagementServices.INFormat(b[0].Quotation__r.Agreement_Value__c);
            dupargv =  b[0].Quotation__r.Agreement_Value__c;
        }
        decimal dSocietyC = 0;
        if(b[0].Quotation__r.Other_Charges_Amount_9__c > 0) {
            societyChr= QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Amount_9__c);
            dSocietyC = b[0].Quotation__r.Other_Charges_Amount_9__c;
        }
        if(b[0].Quotation__r.Other_Charges_Amount_1__c > 0) {
            societyChr= QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Amount_1__c);
            dSocietyC = b[0].Quotation__r.Other_Charges_Amount_1__c;
        }
        maintnce=QuotationManagementServices.INFormat(b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c);
        SocietyCharge = QuotationManagementServices.INFormat(b[0].Quotation__r.Other_Charges_Total__c - b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c);
        totl =  QuotationManagementServices.INFormat(dupargv + b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c + (b[0].Quotation__r.Other_Charges_Total__c - b[0].Quotation__r.Project_Maintenance_Charges_Amount_1__c));
        
        Decimal carParkAmount1 = 0;
        if(b[0].Quotation__r.single_car_park_additional__c > 0) {
            carParkAmount1 += b[0].project__r.allotment_charges_1__c * b[0].Quotation__r.single_car_park_additional__c;
            
        }
        if(b[0].Quotation__r.Tandem_car_park_additional__c > 0) {
            carParkAmount1 += b[0].project__r.allotment_charges_2__c * b[0].Quotation__r.Tandem_car_park_additional__c;
            
        }
        if(b[0].Quotation__r.Single_Open_additional__c > 0) {
            carParkAmount1 += b[0].project__r.allotment_charges_3__c * b[0].Quotation__r.Single_Open_additional__c;
            
        }
        if(b[0].Quotation__r.Tandem_Open_additional__c > 0) {
            carParkAmount1 += b[0].project__r.allotment_charges_4__c * b[0].Quotation__r.Tandem_Open_additional__c;
            
        }        
        if(b[0].Quotation__r.Stack_Additional__c> 0) {
            carParkAmount1 += b[0].project__r.Allotment_Charges_5__c* b[0].Quotation__r.Stack_Additional__c;
            
        }
        
        if(b[0].Quotation__r.MLCP_Additional__c> 0) {
            carParkAmount1 += b[0].project__r.Allotment_Charges_6__c* b[0].Quotation__r.MLCP_Additional__c;
            
        }
        allotment = INFormat(carParkAmount1);
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