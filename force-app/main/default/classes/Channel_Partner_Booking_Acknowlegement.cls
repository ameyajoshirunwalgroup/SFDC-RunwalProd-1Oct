public class Channel_Partner_Booking_Acknowlegement {
      public String TokenInWords {
        get;
        set;
    }
   /* public String TokenInWords1 {
        get;
        set;
    }*/
 /*   public String TaxInWords {
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
   /*public List < Applicant_Details__c > ad1 {
        get;
        set;
    }*/
    public List < Receipt__c > re {
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
  /*  public string AllApplicantDetails {
        get;
        set;
    }*/
  /*  public Decimal T1 {
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
    public Channel_Partner_Booking_Acknowlegement() {
        b = new List < Booking__c > ();
        ad = new List < Applicant_Details__c > ();
        re = new List < Receipt__c > ();
        re2 = new List < Receipt__c > ();
        pu = new List < Project_Unit__c > ();
        
        //if (Apexpages.currentpage().getparameters().get('Id') != null && ApexPages.currentpage().getParameters().get('Id') != '')
        BookingId = ApexPages.currentpage().getParameters().get('id');
        
        b = [Select Id, Name, Project__c,Project__r.Front_Page_Image__c,Project__r.RDS_Company_Code__r.name, Project__r.RW_Project_Image__c, Project__r.RERA_Certificate_No__c, Flat_No__c, Referred_By__c, BrokerIId__r.RW_RERA_Registration_Number__c, Primary_Applicant_Email__c, Unit_No__c, Sub_Source__c,
             Source_of_Booking__c,opportunity__r.RW_Walkin_Channel_Partner__r.RW_Mobile_No__c,opportunity__r.RW_Walkin_Channel_Partner__r.RW_RERA_Registration_Number__c,opportunity__r.RW_Walkin_Channel_Partner__r.RW_Email__c,
             opportunity__r.RW_Walkin_Channel_Partner__c,opportunity__r.RW_Configuration__c, Booking_Date__c, Wing__c, Token_Amount__c, opportunity__r.RW_Walkin_Channel_Partner__r.Representative_Name__c,
             Contact_No_of_Referer_Customer_Custome__c, Allotment_Premium__c, No_of_Parking__c, Company__c, Sales_Managers__c,opportunity__r.RW_Walkin_Channel_Partner__r.name
             From Booking__c Where id =: BookingId
            ];
        system.debug(b);
        Token = b[0].Token_Amount__c;
        TokenInWords = S_NumberToWord.convertNumbertoWords(Token);
        
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
        
        re = [Select Id, Bank__c, DraweeBank__c, AmountToWords__c, Amount_Rs__c, Receipt_No__c, Name, Mode__c, Token_Amount_Receipt__c, Token_Amount_ST__c, Total_Amount__c, Cheque_DD__c, Cheque_DD_Date__c, Drawn_in_favour_of__c, TDS_Amount_In_Rs__c, Receipt_Date__c From Receipt__c Where Booking__c =: BookingId];
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
        pu = [Select Id, Name, S_View1__c, Project_Unit_Type__c,Legal_Entity__r.name,RW_Param4__c, Carpet_Area__c, View__c From Project_Unit__c Where id =: uId];
        System.debug(pu);
        
        
        
        
    }    
}