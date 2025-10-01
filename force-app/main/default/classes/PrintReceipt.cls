public class PrintReceipt
{
    public List<Receipt__c> lstReceipt {get; set;}
    public Opportunity Customer {get;set;}   
    public String strReceiptId {get; set;} 
    public string letterhead{get;set;} 
    public id bookingId {get; set;}  
    //public list<Legal_Entity__c> le {get;set;}
    public String ownerName{get;set;}
    public String ownerPhone{get;set;}
    public String ownerEmail{get;set;}
    public String ownerSalutation{get;set;}
    public String amountRs{get;set;}
    public string legalAddress{get;set;}
    public string legalCity{get;set;}
    public string legalPinCode{get;set;} 
    public List<Receipt_Details__c> lstReceiptDetails {get; set;}       
    public Legal_Entity__c le {get; set;}
    public String PanNo{get;set;}
    public String ServiceTaxNo{get;set;}
    public String Address{get;set;}
    public String City{get;set;}
    public String PinCode{get;set;}    
    public String legalEntityName{get;set;}    
    public wrapperclass wrapperobj { get; set; }
    public List < wrapperclass> wrapperList{get; set;}
    public decimal totalAmt{get;set;}
    public string tamt{get;set;}
    public string accMoney{get;set;}
    public String CustomerOtherApplicantName {get; set;}
    public String CustomerPrimaryName  {get; set;} 
    public String CustomerMailingAddress {get; set;} 
    public String CustomerMobilePhone  {get; set;}
    public String CustomerPANNo {get; set;}   
    public String UnitName  {get; set;}
    public String receiverState{get; set;}
    public String receiverStateCode{get; set;}
    public String receiverGSTIN{get; set;}
    public String HSNCode {get; set;}
    public String clusterName  {get; set;}   
    public String TowerName  {get; set;}   
    
    public class wrapperclass
    {
        public String basicChargeswrap{ get; set;}
        public Decimal waccMoney{get;set;}
        public Receipt_Details__c lstReceiptDetails{get;set;}
        public string amt{get;set;}
        
        public wrapperclass(Receipt_Details__c rd, String charges, Boolean serviceTax)
        {
                   lstReceiptDetails = rd;
                   if(rd.Amount__c != null)
                   {
                       amt = QuotationManagementServices1.INFormat(rd.Amount__c);
                   }
                   else
                   {
                       rd.Amount__c = 0.00;
                       amt = QuotationManagementServices1.INFormat(rd.Amount__c);
                   }    
                   if(charges == 'Basic' && serviceTax == false)
                    {                
                        basicChargeswrap = 'Installment against Flat Cost';
                        system.debug('Charges : ' + charges);
                    }    
                    else if(charges == 'Basic' && serviceTax == true)
                    {
                        basicChargeswrap = 'Tax on Flat Cost';
                        system.debug('For Tax : ' + serviceTax);
                    }
                    else if(charges != 'Basic' && charges != null && serviceTax == true)
                    {
                        basicChargeswrap = 'Tax on ' + charges;
                    }
                    else if(charges == null && rd.Is_Cheque_Dishonour__c ==  true)
                    {
                        basicChargeswrap = 'Cheque Bounce';
                    }
                    else if(charges == null && rd.Is_Interest_Settlement__c ==  true)
                    {
                        basicChargeswrap = 'Interest applied on late payments';
                    }
                    else
                    {
                        basicChargeswrap = 'Installment against  ' + charges;
                    }
                    if(rd.Demand_Invoice__r.Invoice_Date__c != null)
                    {
                        System.Debug('Receipt Wrapper  - Invoice Date :'+rd.Demand_Invoice__r.Invoice_Date__c);                    
             }      }  
    }
    
   public PrintReceipt()
    {
         le = new Legal_Entity__c();
         PanNo = '';
         ServiceTaxNo = '';
         Address = '';
         City = '';
         PinCode = '';
         accMoney = '';
         amountRs='';
         receiverState = '';
         receiverStateCode = '';
         receiverGSTIN  = '';
         HSNCode = '';
        if(string.isBlank(strReceiptId)) {
            if(ApexPages.currentPage().getParameters().get('id') != null)
            {    
                strReceiptId = ApexPages.currentPage().getParameters().get('id');
                        
            }
            if(ApexPages.currentPage().getParameters().get('letterhead') != null)
            {    
                letterhead = ApexPages.currentPage().getParameters().get('letterhead');   
                system.debug('letterhead: ' + letterhead);
            }
            getReceiptDetails(); 
         }
         
    }
    
    public void getReceiptDetails() {
        // if we are coming form the receipt component, the strreceipt is already set
        if(strReceiptId != null)
        {
                  lstReceipt = [Select Id,name, Unit_No__c,Receipt_Date__c, Receipt_No__c, Mode__c, Cheque_DD__c, Cheque_DD_Date__c,Receipt_Status__c, 
                  Cheque_DD_Amount_Rs__c, Bank__c, Bank__r.Name, DraweeBank__c,Amount_in_Foreign_Currency__c, Foreign_Currency_Type__c,
                  Project__r.Name, Project__r.RDS_Company_Code__c, Project__r.RDS_Company_Code__r.Name, Project__r.RDS_Company_Code__r.RDS_Address1__c, 
                  Project__r.RDS_Company_Code__r.RDS_Address2__c, Project_Unit__c, Project_Unit__r.Legal_Entity__c, Project_Unit__r.Legal_Entity__r.Name, Project_Unit__r.Legal_Entity__r.RDS_Address1__c, Project_Unit__r.Name, /*Project_Unit__r.Param2__c,*/ Opportunity__c, 
                  Project_Unit__r.Legal_Entity__r.RDS_PAN_No__c,Project_Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,
                  Project_Unit__r.Legal_Entity__r.RDS_City__c,Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c,
                  Opportunity__r.Name, Opportunity__r.Applicant_Name__c, Total_Amount__c, /*Opportunity__r.Co_Owner1__r.Name, Opportunity__r.Co_Owner2__r.Name, Opportunity__r.Co_Owner3__r.Name, 
                  Opportunity__r.Co_Owner4__r.Name, */Opportunity__r.AccountId, Opportunity__r.Account.Name, /*Opportunity__r.Account.Code__c, Opportunity__r.Account.Family__r.Family_Name__c, */
                  /*Opportunity__r.Account.Correspondence_Address__c, */Opportunity__r.RW_Project_Unit__r.Booking__r.Application_No__c,Booking__r.Zone__c,Booking__r.Wing__c,Booking__r.Unit_No__r.Name,
                  Project_Unit__r.Booking__r.Application_No__c, Booking__r.Application_No__c,Drawee_Bank_If_Others__c,
                  (Select Amount__c, Id, Charges__r.Name from Receipt_Details__r),
                  Opportunity__r.Account.BillingStreet, Opportunity__r.Account.BillingCity,Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingPostalcode,
                  Opportunity__r.Account.BillingCountry,Project__r.Place_of_Supply__c,Project__r.State_Code_Where_Supplied__c,Project__r.HSN_Code__c,
                  // New Added Fields 
                  Opportunity__r.Primary_Name__c,Opportunity__r.Other_Applicants_Name__c,Opportunity__r.Mailing_Address__c,
                  Opportunity__r.Account.PersonMobilePhone,Project__r.Footer_Image__c,Project__r.RW_Project_Image__c,
                  Opportunity__r.RW_Project_Unit__r.Name,Receipt_Number__c,Amount_Rs__c,
                  Booking__r.Owner.Name,Booking__r.Owner.Email,Booking__r.Owner.Phone,
                  Opportunity__r.RW_Project_Unit__r.Legal_Entity__r.RDS_PAN_No__c,
                  Opportunity__r.RW_Project_Unit__r.Legal_Entity__r.RDS_Service_Tax_No__c,
                  Opportunity__r.RW_Project_Unit__r.Legal_Entity__r.RDS_Address1__c,
                  Opportunity__r.RW_Project_Unit__r.Legal_Entity__r.RDS_City__c,
                  Opportunity__r.RW_Project_Unit__r.Legal_Entity__r.RDS_Pin_Code__c,
                  Challan_No__c,NEFT__c, Currency__c,
                 /* Opportunity__r.Primary_Phone__c,*/
                  Opportunity__r.Primary_pancard__c,
                  /*Project_Unit__r.Owner.Name,Project_Unit__r.Owner.Email,Project_Unit__r.Owner.Phone,*/
                  On_Account_Money__c
                  from Receipt__c where id =: strReceiptId];
       }  
               system.debug('lstReceipt : ' + lstReceipt );
               if(lstReceipt != null && lstReceipt.size() == 1) {
                   //ApplicantNames = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c; 
                   CustomerPrimaryName  = lstReceipt[0].Opportunity__r.Primary_Name__c;
                   CustomerOtherApplicantName = lstReceipt[0].Opportunity__r.Other_Applicants_Name__c;
                   CustomerMailingAddress = lstReceipt[0].Opportunity__r.Mailing_Address__c;
                   //CustomerMobilePhone  =  lstReceipt[0].Opportunity__r.Primary_Phone__c;
                   CustomerPANNo = lstReceipt[0].Opportunity__r.Primary_pancard__c;
                   receiverState = lstReceipt[0].Project__r.Place_of_Supply__c;
                   receiverStateCode = lstReceipt[0].Project__r.State_Code_Where_Supplied__c;
                   HSNCode = lstReceipt[0].Project__r.HSN_Code__c;
           UnitName = lstReceipt[0].Opportunity__r.RW_Project_Unit__r.Name;
                   clusterName = lstReceipt[0].Booking__r.Zone__c;
                   towerName = lstReceipt[0].Booking__r.Wing__c;
                    if(lstReceipt[0].On_Account_Money__c != null)
                    {
                        system.debug('On Account Money : ' + lstReceipt[0].On_Account_Money__c);
                        
                        if(lstReceipt[0].Currency__c.equalsIgnoreCase('Indian Rupee'))
                        accMoney = QuotationManagementServices1.INFormat(lstReceipt[0].On_Account_Money__c);
                        else
                        accMoney = string.valueOf(lstReceipt[0].On_Account_Money__c) + ' ' + lstReceipt[0].Currency__c + 's';
                    }
                    //system.debug('On Account Money : ' + accMoney);
                    
                    lstReceiptDetails = [SELECT Id,Name,Demand_Invoice__c, For_Service_Tax__c,Amount__c,Receipts__c,Charges__r.Name, Receipts__r.Name,Receipts__r.On_Account_Money__c,
                    Demand_Invoice__r.Name,Demand_Invoice__r.Invoice_Date__c, /*Demand_Invoice__r.Demand_Number__c,*/ Is_Cheque_Dishonour__c,Is_Interest_Settlement__c FROM Receipt_Details__c WHERE Receipts__c = :strReceiptId] ;
                    
                    wrapperList = new List<wrapperclass>();
                    totalAmt=0;
                    for (integer i = 0; i < lstReceiptDetails.size() ; i++)
                    {
                           wrapperList.add(new wrapperclass(lstReceiptDetails[i], lstReceiptDetails[i].Charges__r.Name,lstReceiptDetails[i].For_Service_Tax__c));
                           totalAmt = totalAmt + lstReceiptDetails[i].Amount__c; 
                    } 
            
                     system.debug('lstReceiptDetails : ' + lstReceiptDetails);
                     if(lstReceipt[0].On_Account_Money__c != null)
                     {
                         totalAmt += lstReceipt[0].On_Account_Money__c; 
                         tamt = QuotationManagementServices1.INFormat(totalAmt);
                     }
                     if(lstReceipt[0].Currency__c.equalsIgnoreCase('Indian Rupee'))
                     {
                        tamt = QuotationManagementServices1.INFormat(totalAmt);
                     }    
                    else
                        tamt = string.valueOf(totalAmt) + ' ' + lstReceipt[0].Currency__c + 's';
                    if(String.isNotBlank(lstReceipt[0].Foreign_Currency_Type__c) && lstReceipt[0].Foreign_Currency_Type__c !=  lstReceipt[0].Currency__c) {
                        tamt += '( ' +  lstReceipt[0].Amount_in_Foreign_Currency__c  + ' '  + lstReceipt[0].Foreign_Currency_Type__c + 's )';
                    }
                      
                      
                  /*   if(lstReceipt[0].Currency__c.equalsIgnoreCase('Indian Rupee'))
                     
                        amountRs = QuotationManagementServices1.INFormat(lstReceipt[0].Amount_Rs__c);
                    else
                 
                        amountRs = string.valueOf(lstReceipt[0].Amount_Rs__c) + ' ' + lstReceipt[0].Currency__c + 's';
                    */
                    ///newly added
                    if(lstReceipt[0].Currency__c.equalsIgnoreCase('Indian Rupee'))
                     
                        amountRs = QuotationManagementServices1.INFormat(lstReceipt[0].Total_Amount__c);
                    else
                 
                        amountRs = string.valueOf(lstReceipt[0].Total_Amount__c) + ' ' + lstReceipt[0].Currency__c + 's';
                    
                   
                   if(lstReceipt[0].Booking__r.Owner.Name != null)
                    {
                            User u = [Select  title, Name, Phone, MobilePhone, Email from User where Id = :lstReceipt[0].Booking__r.OwnerId];
                            ownerSalutation = u.title;
                            ownerName = u.Name;
                            ownerPhone = u.MobilePhone;
                            ownerEmail = u.Email;
                    }
                
                    // legal Entity
                   if(lstReceipt[0].Opportunity__c != null && lstReceipt[0].Project_Unit__c != null )
                    {
                         le = InventoryCostServices.getLegalEntityDetails(lstReceipt[0].Project_Unit__c, lstReceipt[0].Project__c);
                         System.debug('leeeeeeee '+le);
                         if(le != null)
                         {
                            legalEntityName = le.Name;
                             PanNo = le.RDS_PAN_No__c;
                             ServiceTaxNo = le.RDS_Service_Tax_No__c;
                             Address = le.RDS_Address1__c;
                             City = le.RDS_City__c;
                             PinCode = le.RDS_Pin_Code__c;
                             receiverGSTIN  = le.GSTIN__c;
                         }
                    }
                    
                    
               }       
                
       } // Close PrintReceipt
          
}