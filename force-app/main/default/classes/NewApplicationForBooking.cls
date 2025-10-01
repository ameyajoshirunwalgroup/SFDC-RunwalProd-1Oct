public class NewApplicationForBooking {
    
    public String TokenInWords {
        get;
        set;
    }
    
    /*public String TaxInWords {
get;
set;
}*/
    public String AgreementValueInWords {
        get;
        set;
    }
    public Id BookingId {
        get;
        set;
    }
    public Id legalid {
        get;
        set;
    }
    public List < Booking__c > b {
        get;
        set;
    }
    public List < Project_Unit__c > pu {
        get;
        set;
    }
    public List < Applicant_Details__c > ad {
        get;
        set;
    }
    public  Legal_Entity__c  le {
        get;
        set;
    }
    
    /* public List < Applicant_Details__c > ad1 {
get;
set;
}*/
    public List < Receipt__c > re {
        get;
        set;
    }
    public List < Receipt__c > rectax {
        get;
        set;
    }
    public List < Receipt__c > re2 {
        get;
        set;
    }
    public Decimal AgreementValue {
        get;
        set;
    }
    public Decimal Token {
        get;
        set;
    }
    public Decimal Tax {
        get;
        set;
    }
    public Applicant_Details__c PA {
        get;
        set;
    }
    /*public string AllApplicantDetails {
get;
set;
}*/
    /*public Decimal T1 {
get;
set;
}
public Decimal T2 {
get;
set;
}
public Decimal T3 {
get;
set;
}
public Decimal T4 {
get;
set;
}*/
    public String receiptammount{get;set;}
    public Decimal receiptammount1{get;set;}
    public string developername{set;get;}
    public Boolean ShowpageBlockFlag{set;get;}
    public Boolean ShowpageBlockFlag1{set;get;}
    public decimal dvar{set;get;}
    public decimal dvar1{set;get;}
    public List<Date> datevarList {get;set;}
    public string datevar1 {get;set;}
    public string checkvar{get;set;}  
    public string bankname{get;set;} 
    public string favourvar{get;set;} 
    public string wordsamt{get;set;}
    public string modevar {get;set;}
    public string chequetaxdd {get;set;}
    public string chequetaxdate {get;set;}
    public string chequetaxbank {get;set;}
    public string datevar {get;set;}
    public String receiptammount1words {get;set;} 
    public String  receiptammountwords {get;set;}
    //  public string chequetaxdatestr{get;set;}
    public String  dvarformat{get;set;}
    public String receiptammount1format{get;set;}
    
    public NewApplicationForBooking() {
        b = new List < Booking__c > ();
        ad = new List < Applicant_Details__c > ();
        re = new List < Receipt__c > ();
        re2 = new List < Receipt__c > ();
        pu = new List < Project_Unit__c > ();
        le = new  Legal_Entity__c  (); 
        receiptammount = '';
        dvar =0;
        datevarList= new List<Date>();
        checkvar =''; 
        bankname ='';
        favourvar= '';
        receiptammount1=0;
        modevar = '';
        chequetaxdd ='';
        chequetaxdate ='';
        datevar = '';
        chequetaxbank ='';
        
       
        //if (Apexpages.currentpage().getparameters().get('Id') != null && ApexPages.currentpage().getParameters().get('Id') != '')
        BookingId = ApexPages.currentpage().getParameters().get('id');
        
        b = [Select Id, Name, Project__c,Project__r.Front_Page_Image__c,Project__r.RDS_Company_Code__r.name,Project__r.RDS_Company_Code__r.RDS_Company_Name__c,
             Project__r.RW_Project_Image__c, Project__r.RERA_Certificate_No__c, Flat_No__c, Referred_By__c, 
             BrokerIId__r.RW_RERA_Registration_Number__c,Quotation__r.Remarks__c,
             Primary_Applicant_Email__c, Unit_No__c, Sub_Source__c,Project__r.Project_Property_Type__c,
             Source_of_Booking__c,Source_Details__c,opportunity__r.RW_Walkin_Channel_Partner__r.RW_Mobile_No__c,
             opportunity__r.RW_Walkin_Channel_Partner__r.RW_RERA_Registration_Number__c,
             opportunity__r.RW_Walkin_Channel_Partner__r.RW_Email__c,project__r.TermsAndConditions__c,Unit_No__r.Legal_Entity__c,
             opportunity__r.RW_Walkin_Channel_Partner__c,opportunity__r.RW_Configuration__c, 
             Booking_Date__c, Wing__c, Token_Amount__c, opportunity__r.RW_Walkin_Channel_Partner__r.Representative_Name__c,
             Contact_No_of_Referer_Customer_Custome__c, Allotment_Premium__c, No_of_Parking__c,Quotation__r.Total_No_of_Parking__c, Company__c, Sales_Managers__c ,
             Unit_No__r.TowerName__r.Front_Page_Image__c,Emp_Manager_Name__c,opportunity__r.Walk_in_Corporate__c,opportunity__r.Employee_Reference__r.Employee_ID__c,
             opportunity__r.RW_Referral_Details__c, opportunity__r.Customer_Reference__c
             From Booking__c Where id =: BookingId
            ];
        system.debug(b);
        Token = b[0].Token_Amount__c;
        TokenInWords = S_NumberToWord.convertNumbertoWords(Token);
        
        if(b[0].Unit_No__r.Legal_Entity__c != null) {
            legalid = b[0].Unit_No__r.Legal_Entity__c;
            system.debug('test');
        }
        else  {
            legalid = b[0].Project__r.RDS_Company_Code__c;
        }
        system.debug('Legal Id = '+legalid);
        if(legalid != null){
         le = [Select Id ,RDS_Company_Name__c,Name,RDS_Address1__c,RDS_Address2__c,CIN__c,RDS_Phone__c,Legal_Entity_Email__c From Legal_Entity__c where id =: legalid];
        }
        system.debug(le);
        
        	
        // AgreementValueInNumber = INFormat(AgreementValue);
        
        AgreementValue = b[0].Allotment_Premium__c;
        AgreementValueInWords = S_NumberToWord.convertNumbertoWords(AgreementValue);
        
        ad = [Select Id, Name, DOB__c, PancardNo__c, Permanent_Address__c, Applicant_Number__c, Mobile_Number__c, Landline_Number__c, Salutation__c, Mailing_Address__c,
              Email_Address__c, Organization_Name__c, Designation__c, Organization_Address__c From Applicant_Details__c Where Booking__c =: BookingId order by createdDate asc
             ];
        system.debug(ad);
        
        if (!ad.isEmpty() && ad.size() == 1) {
            PA = ad[0];
            //AllApplica ntDetails = PA.Salutation__c +' '+ PA.Name;
        }
        
        re = [Select Id, Bank__c, DraweeBank__c, AmountToWords__c, Amount_Rs__c, Receipt_No__c, Name, Mode__c, 
              Token_Amount_Receipt__c, Token_Amount_ST__c,
              Total_Amount__c, Cheque_DD__c, Cheque_DD_Date__c, Drawn_in_favour_of__c,
              TDS_Amount_In_Rs__c, Receipt_Date__c From Receipt__c Where Booking__c =:BookingId];
        
        /*rectax = [Select Id, Bank__c, DraweeBank__c, AmountToWords__c, Amount_Rs__c, Receipt_No__c, Name, Mode__c, 
Token_Amount_Receipt__c, Token_Amount_ST__c,
Total_Amount__c, Cheque_DD__c, Cheque_DD_Date__c, Drawn_in_favour_of__c,
TDS_Amount_In_Rs__c, Receipt_Date__c From Receipt__c Where Booking__c =:BookingId];*/
        
        system.debug(re);
        if (re.size() != Null) {
            for (Receipt__c r: re)
            {
                Tax = r.Total_Amount__c;
                r.AmountToWords__c = S_NumberToWord.convertNumbertoWords(Tax);
                
            }
            System.debug(+TokenInWords);
        }
        
        id uId = b[0].Unit_No__c;
        pu = [Select Id, Name, S_View1__c,New_View__c, Project_Unit_Type__c,Legal_Entity__r.name,Legal_Entity__r.RDS_Company_Name__c,RW_Param4__c,RW_Param2__c, Carpet_Area__c, View__c,New_Type__c,Total_RERA_Carpet_Area__c From Project_Unit__c Where id =: uId];
        System.debug(pu);
        
        if(pu[0].Legal_Entity__r.RDS_Company_Name__c != null ) 
        {
            system.debug('IN IF  Block');
            developername = pu[0].Legal_Entity__r.RDS_Company_Name__c;
        } 
        else if(b[0].Project__r.RDS_Company_Code__r.RDS_Company_Name__c != null  ) 
        {
            system.debug('IN ELSE IF  Block');
            developername = b[0].Project__r.RDS_Company_Code__r.RDS_Company_Name__c;
        }
        else
        {
            system.debug('IN ELSE IF  Block');
            developername = '';
        }
        
        //for tax receipt or normal receipt
        for(Receipt__c r : re)
        {
            if(r.Token_Amount_ST__c == false) {
                //ShowpageBlockFlag = true;
                dvar += r.Total_Amount__c ;
                datevar += r.Cheque_DD_Date__c.format()  +' / ' ;
                checkvar +=  + r.Cheque_DD__c + ' / '; 
                bankname +=  r.DraweeBank__c + ' / '  ;
                favourvar +=  r.Drawn_in_favour_of__c + ' / ' ;
            }
           
            
        } 
         dvarformat  = QuotationManagementServices.INFormat(dvar);
         receiptammountwords = S_NumberToWord.convertNumbertoWords(dvar);   
         checkvar = checkvar.removeEnd(' / ');
         bankname = bankname.removeEnd(' / ');
         favourvar = favourvar.removeEnd(' / ');
          datevar = datevar.removeEnd(' / ');
        
        for(Receipt__c rt : re){
            
            if(rt.Token_Amount_ST__c == true) {
                receiptammount1 +=  rt.Total_Amount__c;
                modevar += rt.Mode__c + ' / ' ;
                chequetaxdd +=  rt.Cheque_DD__c + ' / ' ;
                chequetaxdate += rt.Cheque_DD_Date__c.format() +' / ' ;
                chequetaxbank +=   rt.DraweeBank__c +  ' / '  ;
                ShowpageBlockFlag = false;
                if(receiptammount1 != null)
                    ShowpageBlockFlag1 = true;
            }
          
            
        }
        receiptammount1format =  QuotationManagementServices.INFormat(receiptammount1);
        receiptammount1words = S_NumberToWord.convertNumbertoWords(receiptammount1);   
        modevar = modevar.removeEnd(' / ' );
        chequetaxdd = chequetaxdd.removeEnd(' / ');
        chequetaxbank = chequetaxbank.removeEnd(' / ');
        chequetaxdate = chequetaxdate.removeEnd(' / ');
    }
         
}