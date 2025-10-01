public with sharing class quotationcomcontroller {
    ApexPages.StandardController controller;
    Public Quotation__c q {
        get;
        set;
    }
    public List < Standard_Customer_Pay_Plan_Detail__c > scppdList {
        get;
        set;
    }
    public List < wrapperclass > wrapperList {
            get;
            set;
    }
    public string construction 
    {
            get;
            set;
    }
    Public List< Standard_Customer_Pay_Plan_Detail__c > newRecordList {
        get;
        set;
    }
    public Tax_Slab__c gstSlab {
            get;
            set;
        }
    public Decimal agreementValuewithDiscount {
            get;
            set;
        }
    public Decimal agreementValuewithoutDiscountTax {
            get;
            set;
        }
    public decimal totalTDS {
        get;
        set;
    }
    public decimal totalFinalCheque {
        get;
        set;
    }
    public decimal stampDuty {
        get;
        set;
    }
    public decimal othercharges{
        get;
        set;
    }
    public decimal otherchargesTax{
        get;
        set;
    }
    public decimal scGST{
        get;
        set;
    }
    public Legal_Entity__c le {
        get;
        set;
    }
    public Decimal grandTotal {
        get;
        set;
    }
    public Decimal gst1Percenatge {
        get;
        set;
    }
    public Decimal gst2Percenatge {
        get;
        set;
    }
    public Decimal gstamount{
    get;
    set;
    }
    public Decimal additionalgstdis{
    get;
    set;
    }
    public Decimal Expectedallprice{
    get;
    set;
    }
   public List <String> strq {
    get;
    set;
    }
   // ----- Wrapper Class -----
    public class wrapperclass {
        public Standard_Customer_Pay_Plan_Detail__c scppd {
            get;
            set;
        }
        public String isToBePaid1 {
            get;
            set;
        }
        public Decimal installment1 {
            get;
            set;
        }
        public Decimal gst{
            get;
            set;
        }
        public Decimal tds{
            get;
            set;
        }
        public Decimal finalcheque {
            get;
            set;
        }
        public Decimal percentageval {
            get;
            set;
        }
        public string constructionstage {
            get;
            set;
        }
        public String newvar {
            get;
            set;
        }
       
       
        public wrapperclass(Standard_Customer_Pay_Plan_Detail__c newRecord, String isToBePaid, Decimal installment, Decimal percentage, String constructionstageName, Decimal gstAmount,string ProjName,Decimal AggrVal,Decimal othercharges) {
            scppd = newRecord;

            if (constructionstageName != '') {
                isToBePaid1 = constructionstageName;
            } else {
                system.debug('isToBePaid' + isToBePaid);
                system.debug('constructionstageName' + constructionstageName);
                isToBePaid1 = isToBePaid;
            }

            installment1 = installment;
            gst = gstAmount.setScale(0);
            
            if( (AggrVal + othercharges) < 5000000)
            {  tds = 0; }
            else
            {  tds = (installment * 1 /100).setScale(0); }
            
            finalcheque = installment - tds;
            percentageval = percentage;
            
            //  system.debug('constructionstage'+ constructionstageName);
        }
    }
    public quotationcomcontroller(ApexPages.StandardController controller) {

     //   ApexPages.currentPage().getParameters().put('id', pp.id);

        this.controller = controller;
        q = (Quotation__c) controller.getRecord();
        agreementValuewithDiscount = 0;
        agreementValuewithoutDiscountTax = 0;
        grandTotal = 0;
        le = new legal_entity__c();
        totalFinalCheque = 0;
        totalTDS = 0;
        additionalgstdis = 0;
        stampDuty = 0;
        othercharges = 0;
        otherchargesTax = 0;
        scGST = 0;
        strq = new List <string>();
        Expectedallprice = 0;
        System.debug('quotation List::' + q);
        gstSlab = new Tax_Slab__c();
        gstSlab = [Select Id , name, Percentage__c from tax_Slab__c where Name = 'GST'];
        scppdList = new List < Standard_Customer_Pay_Plan_Detail__c > ();
        wrapperList = new List < wrapperclass > ();
        newRecordList =  new List< Standard_Customer_Pay_Plan_Detail__c >(); 
        scppdList = [SELECT Id, Project_Construction_Stages__c, Project_Construction_Stages__r.Name,
            Customer_Pay_Plan_Header__c, Is_to_be__c, Days_Months_Value__c, Installment__c,
            Amount_Value__c, Is_to_be_Paid__c, Due_Date__c, Original_Percentage__c,Service_Tax_Amount_Q__c
            FROM Standard_Customer_Pay_Plan_Detail__c
            WHERE Customer_Pay_Plan_Header__c != null
            and Customer_Pay_Plan_Header__r.Quotation__c = : q.id
            and Customer_Pay_Plan_Header__r.Global_Charge_Name__c = 'Basic'
        ];
        if(q.Agreement_Value_D__c != 0) {
            agreementValuewithDiscount = q.Agreement_Value_D__c;
        }
        else{
            agreementValuewithDiscount = q.Agreement_Value__c;
            }
            gstamount = q.Agreement_Value__c - agreementValuewithDiscount ; 
        if(q.Agreement_Value__c != null)
            agreementValuewithoutDiscountTax = (q.Agreement_Value__c * 5.5/100).setScale(0);
        totalTDS = (agreementValuewithDiscount *0.01).setScale(0);
      
        
        
        if(q.Stamp_Duty_D__c != 0)
            stampDuty = q.Stamp_Duty_D__c;
        else
            stampDuty = q.Stamp_Duty__c;
       if(q.Agreement_Value_ST_D__c != 0)
           scGST = q.Agreement_Value_ST_D__c;
       else
           scGST = q.Agreement_Value_ST__c;
       if(q.Grand_Total_D__c != 0)
           grandTotal = q.Grand_Total_D__c;
       else
           grandTotal = q.Grand_Total__c;
           
       othercharges = (q.Other_Charges_Amount_1__c + q.Other_Charges_Amount_2__c + q.Other_Charges_Amount_3__c + q.Other_Charges_Amount_4__c  
                       + q.Other_Charges_Amount_6__c + q.Other_Charges_Amount_7__c + q.Other_Charges_Amount_8__c 
                       + q.Other_Charges_Amount_9__c + q.Other_Charges_Amount_11__c + q.Other_Charges_Amount_14__c).setScale(0);
       if(q.project__r.Name != null) {
          if(!q.project__r.Name.equalsIgnoreCase('Runwal Pinnacle')) {
              otherchargesTax = ((othercharges + q.Project_Maintenance_Charges_Amount_1__c) * 18/100).setScale(0); 
          }
          else if(q.project__r.Name.equalsIgnoreCase('Runwal Pinnacle')) {
              otherchargesTax = ((othercharges + q.Project_Maintenance_Charges_Amount_1__c) * 5/100).setScale(0); 
          }
          if( (agreementValuewithDiscount + othercharges)< 5000000){
            totalTDS = 0;
          }
       }
       system.debug('agreement value::'+agreementValuewithDiscount +'::+tax calculated on it::'+scGST+'::TDS on it::'+totalTDS);
       totalFinalCheque = agreementValuewithDiscount - totalTDS;
       if(!q.OC_Approved__c) {
           if(q.project__r.Name != null) {
               if(!q.project__r.Name.equalsIgnoreCase('Runwal Pinnacle')) {
                   if(q.Project_Unit__r.Tax_Rate_Basic__c != null && q.Project_Unit__r.Tax_Rate_Basic__c == 'GST 8%') {
                       gst1Percenatge = 8;
                       additionalgstdis = agreementValuewithDiscount * 0.005;
                   }
                   else{
                       gst1Percenatge = 12;
                       additionalgstdis = agreementValuewithDiscount * 0.025; 
                   }
               }
               else if(q.project__r.Name.equalsIgnoreCase('Runwal Pinnacle')) {
                   gst1Percenatge = 5;
                   additionalgstdis = 0; 
               }
           }  
       }  
       else {
           //otherchargesTax = 0;
           gst1Percenatge = 0;
           //gst2Percenatge = 0;
       } 
       
       
        system.debug('additionalgstdis '+ additionalgstdis );
        system.debug('grandTotal '+ grandTotal );
        Expectedallprice = grandTotal - additionalgstdis ;
         
       le = InventoryCostServices.getLegalEntityDetails(q.Project_Unit__r.Id, q.Project__r.Id);
        if (!scppdList.isEmpty()) {
            for (Standard_Customer_Pay_Plan_Detail__c scp: scppdList) {
                Standard_Customer_Pay_Plan_Detail__c newSccp = new Standard_Customer_Pay_Plan_Detail__c();

                if (scp.Is_to_be__c != null) {
                    newSccp.Is_to_be__c = scp.Is_to_be__c;
                }

                if (scp.Installment__c != null) {
                    newSccp.Installment__c = scp.Installment__c;
                }
                if (scp.Service_Tax_Amount_Q__c != null) {
                    newSccp.Service_Tax_Amount_Q__c = scp.Service_Tax_Amount_Q__c;
                }


                if (scp.Amount_Value__c != null) {
                    newSccp.Amount_Value__c = scp.Amount_Value__c;
                }

                if (scp.Project_Construction_Stages__r.Name != null) {
                    construction = scp.Project_Construction_Stages__r.Name;
                    system.debug('if part');
                } else {
                    construction = '';
                }

                newRecordList.add(newSccp);
                
                    if(newSccp.Installment__c == null)
                    {
                        newSccp.Installment__c = 0;
                    }
                                     
                    wrapperList.add(new wrapperclass(newSccp,newSccp.Is_to_be__c, newSccp.Installment__c, newSccp.Amount_Value__c,construction,newSccp.Service_Tax_Amount_Q__c,q.project__r.Name,q.Agreement_Value__c,othercharges ));
                
            }
        }
        
       List <Quotation__c> lstq = new List <Quotation__c>();
       lstq =[select id,Single_car_park_Earmarked__c,Tandem_car_park_Earmarked__c,Single_Open_Earmarked__c,Tandem_Open_Earmarked__c,Stack_Earmarked__c,
              MLCP_Earmarked__c,MLCP_Additional__c,Stack_Additional__c,Tandem_Open_Additional__c,Single_Open_Additional__c,Tandem_car_park_Additional__c,
              Single_car_park_Additional__c from Quotation__c where id =: q.id];
              
              system.debug('lstq:' + lstq);
              
              if(lstq[0].MLCP_Additional__c!= 0){
                    strq.add('MLCP');
                    system.debug('STRQ1:'+ strq);
                    }
              if(lstq[0].Stack_Additional__c!= 0){
                    strq.add('Stilt');
                    system.debug('STRQ2:'+ strq);
                    }
              if(lstq[0].Tandem_Open_Additional__c!= 0){
                    strq.add('Tandem Open');
                    system.debug('STRQ3:'+ strq);
                    }
              if(lstq[0].Single_Open_Additional__c!= 0){
                    strq.add('Single Open');
                    system.debug('STRQ4:'+ strq);
                    }
              if(lstq[0].Tandem_car_park_Additional__c!= 0){
                    strq.add('Tandem Covered');
                    system.debug('STRQ5:'+ strq);
                    }
              if(lstq[0].Single_car_park_Additional__c!= 0){
                    strq.add('Single Covered ');
                    system.debug('STRQ6:'+ strq);
                    }                                                                  
         }
}