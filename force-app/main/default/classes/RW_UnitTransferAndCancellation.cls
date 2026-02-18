public with sharing class RW_UnitTransferAndCancellation {
    
    public Booking__c info {
        get;
        private set;
    }
    
    public Booking__c newInfo {
        get;
        private set;
    }
    
    public Project_Unit__c unitInfo {
        get;
        private set;
    }
    
    public Decimal brokerageAmount {get; set;}
    public String oldAppNames {get;set;}
    public String newAppNames {get;set;}
    public Decimal lessDeductions {get; set;}
    public Decimal gst8Perc {get; set;}
    
    @AuraEnabled
    public static Booking__c getBookingInformation(string bookingId){
        Booking__c bookingInfo= [select Project__r.Name ,Allotment_Premium__c, GST_Tax_G__c ,RM_Name__c, Project__r.CRMHead__r.Name, Project__r.Overall_CRM_Head__r.Name, Unit_No__r.RW_Param4__c,Unit_No__r.TowerName__r.Name, Unit_No__r.Name, Opportunity__r.Primary_Name__c, Opportunity__r.Applicant_Name__c, Opportunity__r.Other_Applicants_Name__c, Status__c, Source_of_Booking__c, Opportunity__r.StageName, Basic_Booking_Amount__c, RW_GST_On_Interest__c, Credited_Amount__c, RW_Total_GST_Amount__c, RW_Total_TDS_Outstanding__c, Total_TDS_Amount_Paid_In_Rs__c, Reason_For_Cancellation__c, Date_of_Cancellation__c, Cancellation_Requested_Status__c, Cancellation_Reason__c,Cancellation_Sub_reason__c, Forfeiture_Amount__c, Brokerage_Amount__c, Interest_Value__c, Taxes_if_any__c, Forfeiture_Amount_Type__c,Other_Forfeiture_Amount__c, Forfeit_Percentage__c, Total_Forfeiture_Amount__c, CGST__c, SGST__c, Booking_Date__c, RW_Registration_Status__c, Primary_Applicant_Name__c,  MVAT__c, Total_Refund_Amount__c, Final_Refund_Amount__c, Quotation__r.Agreement_Value__c, Quotation__r.Agreement_Value_D__c,  RW_Total_Receipt_Amount_Received__c, Opportunity__r.SAP_Customer_Number__c, Cancellation_Subtype__c, Mode_of_Cancellation__c,Payment_Refund_Amount__c,Resale_Status__c,New_Rate__c,New_Flat_Agreement_Value__c,Received_Amtount__c,Scheme_of_Customer__r.Name, Referral_Amount_Cancellation_Checklist__c,Referral_Amount__c, Interest_with_GST__c,TAX__c, GST__c, Total_Amount_to_be_Transferred__c, Swipe_Charges__c, NOTE__c, New_Unit__c, RW_Total_Interest__c,RW_Total_Amount_Collected__c, Stamp_Duty_Cheque_Exchang_Amt_to_be_paid__c FROM Booking__c  Where id = : bookingId ];        
        
        List<Brokerage_Invoice__c> brokInvoices = [SELECT Id, Total_Amount_Paid__c FROM Brokerage_Invoice__c WHERE Booking__c =: bookingId];
        Decimal brokerageAmount = 0;
        for(Brokerage_Invoice__c bi : brokInvoices){
            if(bi.Total_Amount_Paid__c != null){ // Addeb by coServe 21-02-2024
                brokerageAmount += bi.Total_Amount_Paid__c;
            }
            //brokerageAmount += bi.Total_Amount_Paid__c; // Commented by coServe 21-02-2024
        }
        bookingInfo.Brokerage_Paid__c = brokerageAmount;
        if(bookingInfo.RW_Total_Interest__c != null && bookingInfo.RW_Total_Amount_Collected__c != null){
            bookingInfo.Interest_with_GST__c = bookingInfo.RW_Total_Interest__c - bookingInfo.RW_Total_Amount_Collected__c + (0.08* (bookingInfo.RW_Total_Interest__c - bookingInfo.RW_Total_Amount_Collected__c));
        }
        
        return bookingInfo;
    }
    
   // Unit Cancelled
    @AuraEnabled
    public static void bookingcancelled(string BookingId , string cancelReason ,string cancellationSubReason ,string ForfeitureAmount ,string BrokerageAmount , string InterestValue , string Taxesifany ,string ForfeitureAmounttype , string Otherforfeitureamount , string ForfeiPercentage ,string TotalForfeitureAmount, string TotalRefundAmount , string FinalRefundAmount, string MVAT , string TDS , string cancellationdescription , string CGST , string SGST, string TotalRecievedAmount, String cancSubType, String modeofCanc, String payRefAmt, String ResaleStatus, String newRate, String newFlatAgrVal, String recvAmt, String referralAmt, String swipeCharges, String brokeragePaid, String totalAmtToBeTransfrd, String note, String gst){
        BookingTriggerHandler.byPass =true;
        Booking__c boookingRecord = [Select Id , GST_Tax_G__c,Checklist_download_date__c ,Cancellation_initiation_date__c ,Forfeiture_Amount__c , Brokerage_Amount__c , Opportunity__r.StageName,Interest_Value__c , Taxes_if_any__c ,Forfeiture_Amount_Type__c ,Other_Forfeiture_Amount__c , Forfeit_Percentage__c , Total_Forfeiture_Amount__c ,Cancellation_Reason__c , Cancellation_Sub_reason__c ,Date_of_Cancellation__c , Opportunity__r.Status__c , Cancellation_Requested_Status__c , Status__c, Old_Opp_Status__c , Old_status__c , RW_Total_TDS_Outstanding__c , MVAT__c , Reason_For_Cancellation__c ,CGST__c , SGST__c , Total_Refund_Amount__c , Final_Refund_Amount__c, RW_Total_Receipt_Amount_Received__c  FROM Booking__c Where id = : BookingId];
        if(ForfeitureAmount != null){
            boookingRecord.Forfeiture_Amount__c    = Decimal.ValueOf(ForfeitureAmount);
        }
        if(BrokerageAmount != null){
            boookingRecord.Brokerage_Amount__c    = Decimal.ValueOf(BrokerageAmount);
        }
        if(InterestValue != null && cancelReason == 'Unit cancelled' && (cancellationSubReason == 'R3' || cancellationSubReason == 'Z8')){
            boookingRecord.Interest_with_GST__c    = Decimal.ValueOf(InterestValue);
        }else{
            boookingRecord.Interest_Value__c    = Decimal.ValueOf(InterestValue);
        }
        if(Taxesifany != null){
            boookingRecord.Taxes_if_any__c    = Decimal.ValueOf(Taxesifany);
        }
        if(Otherforfeitureamount != null){
            boookingRecord.GST_Tax_G__c    = Decimal.ValueOf(Otherforfeitureamount);
        }
        if(ForfeiPercentage != null){
            boookingRecord.Forfeit_Percentage__c    = Decimal.ValueOf(ForfeiPercentage);
        }
        if(TotalForfeitureAmount != null){
            boookingRecord.Total_Forfeiture_Amount__c    = Decimal.ValueOf(TotalForfeitureAmount);
        }
        boookingRecord.Cancellation_Reason__c = cancelReason;
        boookingRecord.Cancellation_Sub_reason__c =  cancellationSubReason;
        if(boookingRecord.Old_status__c == null){
            boookingRecord.Old_status__c = boookingRecord.Status__c;
            boookingRecord.Old_Opp_Status__c = boookingRecord.Opportunity__r.StageName; 
        } 
        boookingRecord.Status__c =  'Cancellation Initiated';
        //boookingRecord.Opportunity__r.Status__c = 'Cancellation Initiated'; 
        if(TDS != null){
            boookingRecord.Total_TDS_Amount_Paid_In_Rs__c = Decimal.ValueOf(TDS);
        }
        if(MVAT != null){
            boookingRecord.MVAT__c =     Decimal.ValueOf(MVAT);
        }
        if(TotalRefundAmount != null){
            boookingRecord.Total_Refund_Amount__c = Decimal.ValueOf(TotalRefundAmount);
        }
        if(FinalRefundAmount != null){
            boookingRecord.Final_Refund_Amount__c  = Decimal.ValueOf(FinalRefundAmount);
        }
        boookingRecord.Reason_For_Cancellation__c =  cancellationdescription;  
        if(CGST != null){
            boookingRecord.CGST__c = Decimal.ValueOf(CGST);
        }
        if(SGST != null){
            boookingRecord.SGST__c = Decimal.ValueOf(SGST);
        }
        boookingRecord.Cancellation_initiation_date__c = system.today();
        boookingRecord.Checklist_download_date__c = system.today();  
        boookingRecord.RW_Total_Receipt_Amount_Received__c = Decimal.ValueOf(TotalRecievedAmount);
        boookingRecord.Cancellation_Subtype__c = cancSubType;
        boookingRecord.Mode_of_Cancellation__c = modeofCanc;
        boookingRecord.Payment_Refund_Amount__c = payRefAmt;
        boookingRecord.Resale_Status__c = ResaleStatus;
        if(newRate != null){
            boookingRecord.New_Rate__c = Decimal.ValueOf(newRate);
        }
        if(newFlatAgrVal != null){
            boookingRecord.New_Flat_Agreement_Value__c = Decimal.ValueOf(newFlatAgrVal);
        }
        if(recvAmt != null){
            boookingRecord.Received_Amtount__c = Decimal.ValueOf(recvAmt);
        }
        if(referralAmt != null){
            boookingRecord.Referral_Amount_Cancellation_Checklist__c = Decimal.ValueOf(referralAmt);
        }
        if(swipeCharges != null){
            boookingRecord.Swipe_Charges__c = Decimal.ValueOf(swipeCharges);
        }
        if(brokeragePaid != null){
            boookingRecord.Brokerage_Paid__c = Decimal.ValueOf(brokeragePaid);
        }
        if(totalAmtToBeTransfrd != null){
            boookingRecord.Total_Amount_to_be_Transferred__c = Decimal.ValueOf(totalAmtToBeTransfrd);
        }
        if(gst != null){
            boookingRecord.GST__c = Decimal.ValueOf(gst);
        }
        /*if(cancelReason == 'Unit cancelled' && (cancellationSubReason == 'R3' || cancellationSubReason == 'Z8')){
            boookingRecord.TAX__c = Decimal.ValueOf(Taxesifany);
        }*/
        boookingRecord.NOTE__c = note;
        Update boookingRecord;
        BookingTriggerHandler.byPass =false;
        sendEmail(BookingId);
    }
    
    @AuraEnabled
    public static void bookingcancelledUpgrade(Map<String,String> cancDetails){
        BookingTriggerHandler.byPass =true;
        Booking__c boookingRecord = [Select Id , GST_Tax_G__c,Checklist_download_date__c ,Cancellation_initiation_date__c ,Forfeiture_Amount__c , Brokerage_Amount__c , Opportunity__r.StageName,Interest_Value__c , Taxes_if_any__c ,Forfeiture_Amount_Type__c ,Other_Forfeiture_Amount__c , Forfeit_Percentage__c , Total_Forfeiture_Amount__c ,Cancellation_Reason__c , Cancellation_Sub_reason__c ,Date_of_Cancellation__c , Opportunity__r.Status__c , Cancellation_Requested_Status__c , Status__c, Old_Opp_Status__c , Old_status__c , RW_Total_TDS_Outstanding__c , MVAT__c , Reason_For_Cancellation__c ,CGST__c , SGST__c , Total_Refund_Amount__c , Final_Refund_Amount__c, RW_Total_Receipt_Amount_Received__c  FROM Booking__c Where id = : cancDetails.get('BookingId')];
        
        if(cancDetails.get('BrokerageAmount') != null){
            boookingRecord.Brokerage_Amount__c    = Decimal.ValueOf(cancDetails.get('BrokerageAmount'));
        }
        if(cancDetails.get('InterestValue') != null){
            boookingRecord.Interest_with_GST__c    = Decimal.ValueOf(cancDetails.get('InterestValue'));
        }
        if(cancDetails.get('Taxesifany') != null){
            boookingRecord.Taxes_if_any__c    = Decimal.ValueOf(cancDetails.get('Taxesifany'));
        }
        if(cancDetails.get('Otherforfeitureamount') != null){
            boookingRecord.GST_Tax_G__c    = Decimal.ValueOf(cancDetails.get('Otherforfeitureamount'));
        }
        boookingRecord.Cancellation_Reason__c = cancDetails.get('cancelReason');
        boookingRecord.Cancellation_Sub_reason__c =  cancDetails.get('cancellationSubReason');
        if(boookingRecord.Old_status__c == null){
            boookingRecord.Old_status__c = boookingRecord.Status__c;
            boookingRecord.Old_Opp_Status__c = boookingRecord.Opportunity__r.StageName; 
        } 
        boookingRecord.Status__c =  'Cancellation Initiated';
        //boookingRecord.Opportunity__r.Status__c = 'Cancellation Initiated'; 
        if(cancDetails.get('TDS') != null){
            boookingRecord.Total_TDS_Amount_Paid_In_Rs__c = Decimal.ValueOf(cancDetails.get('TDS'));
        }
        if(cancDetails.get('MVAT') != null){
            boookingRecord.MVAT__c =     Decimal.ValueOf(cancDetails.get('MVAT'));
        }
        boookingRecord.Reason_For_Cancellation__c =  cancDetails.get('cancellationdescription'); 
        if(cancDetails.get('CGST') != null){
            boookingRecord.CGST__c = Decimal.ValueOf(cancDetails.get('CGST'));
        }
        if(cancDetails.get('SGST') != null){
            boookingRecord.SGST__c = Decimal.ValueOf(cancDetails.get('SGST'));
        }
        boookingRecord.Cancellation_initiation_date__c = system.today();
        boookingRecord.Checklist_download_date__c = system.today();  
        if(cancDetails.get('TotalRecievedAmount') != null){
        	boookingRecord.RW_Total_Receipt_Amount_Received__c = Decimal.ValueOf(cancDetails.get('TotalRecievedAmount'));
        }
        boookingRecord.Cancellation_Subtype__c = cancDetails.get('cancSubType');
        boookingRecord.Mode_of_Cancellation__c = cancDetails.get('modeofCanc');
        boookingRecord.Payment_Refund_Amount__c = cancDetails.get('payRefAmt');
        boookingRecord.Resale_Status__c = cancDetails.get('ResaleStatus');
        if(cancDetails.get('newRate') != null){
            boookingRecord.New_Rate__c = Decimal.ValueOf(cancDetails.get('newRate'));
        }
        if(cancDetails.get('newFlatAgrVal') != null){
            boookingRecord.New_Flat_Agreement_Value__c = Decimal.ValueOf(cancDetails.get('newFlatAgrVal'));
        }
        if(cancDetails.get('recvAmt') != null){
            boookingRecord.Received_Amtount__c = Decimal.ValueOf(cancDetails.get('recvAmt'));
        }
        if(cancDetails.get('referralAmt') != null){
            boookingRecord.Referral_Amount_Cancellation_Checklist__c = Decimal.ValueOf(cancDetails.get('referralAmt'));
        }
        if(cancDetails.get('swipeCharges') != null){
            boookingRecord.Swipe_Charges__c = Decimal.ValueOf(cancDetails.get('swipeCharges'));
        }
        if(cancDetails.get('brokeragePaid') != null){
            boookingRecord.Brokerage_Paid__c = Decimal.ValueOf(cancDetails.get('brokeragePaid'));
        }
        if(cancDetails.get('totalAmtToBeTransfrd') != null){
            boookingRecord.Total_Amount_to_be_Transferred__c = Decimal.ValueOf(cancDetails.get('totalAmtToBeTransfrd'));
        }
        if(cancDetails.get('gst') != null){
            boookingRecord.GST__c = Decimal.ValueOf(cancDetails.get('gst'));
        }
        /*if(cancelReason == 'Unit cancelled' && (cancellationSubReason == 'R3' || cancellationSubReason == 'Z8')){
            boookingRecord.TAX__c = Decimal.ValueOf(Taxesifany);
        }*/
        boookingRecord.NOTE__c = cancDetails.get('note');
        Update boookingRecord;
        BookingTriggerHandler.byPass =false;
        sendEmail(cancDetails.get('BookingId'));
    }
    
    // Unit Transfered
    @AuraEnabled
    public static void bookingUnitTransfer(string BookingId , string cancelReason , string cancelSubReason , string cancellationdescription){
        BookingTriggerHandler.byPass =true;
        Booking__c boookingRecord = [Select Id ,Reason_For_Cancellation__c, Cancellation_initiation_date__c,Status__c , Opportunity__r.StageName, Old_status__c , Old_Opp_Status__c,Cancellation_Reason__c , Cancellation_Sub_reason__c ,Date_of_Cancellation__c FROM Booking__c Where id = : BookingId];
        boookingRecord.Cancellation_Reason__c = cancelReason;
        boookingRecord.Cancellation_Sub_reason__c =  cancelSubReason;
        boookingRecord.Reason_For_Cancellation__c = cancellationdescription;
        if(boookingRecord.Old_status__c == null){
            boookingRecord.Old_status__c = boookingRecord.Status__c;
            boookingRecord.Old_Opp_Status__c = boookingRecord.Opportunity__r.StageName;  
        }  
        boookingRecord.Status__c =  'Cancellation Initiated';
        boookingRecord.Cancellation_initiation_date__c = system.today();
        system.debug(boookingRecord);
        Update boookingRecord;
        BookingTriggerHandler.byPass =false;
        sendEmail(BookingId);
    }
    
    //Generate Checklist for Unit Cancelled
    Public RW_UnitTransferAndCancellation() {
        string recordid = ApexPages.currentPage().getParameters().get('id');
        info = [Select Name,Allotment_Premium__c, Quotation__r.Agreement_Value_D__c,Total_Forfeiture_Amount__c ,Taxes_if_any__c  ,GST_Tax_G__c,
                Interest_Value__c ,RM_Name__c,Project__r.Name , Unit_No__r.Saleable_Area__c, Unit_No__r.RW_Param4__c, Unit_No__r.Name , 
                Opportunity__r.Primary_Name__c , Opportunity__r.Applicant_Name__c, Opportunity__r.Other_Applicants_Name__c, Status__c , 
                Source_of_Booking__c , Opportunity__r.StageName , Basic_Booking_Amount__c , RW_GST_On_Interest__c  , Credited_Amount__c , 
                RW_Total_GST_Amount__c, RW_Total_TDS_Outstanding__c, Reason_For_Cancellation__c, Area__c, Carpet_Area__c, 
                RW_Total_Interest_Amount_Waived__c, RW_Total_Amount_Balance__c , RW_Total_Amount_Collected__c, RW_Registration_Status__c, 
                Date_of_Cancellation__c, ST_Token_Amount__c, Total_TDS_Amount_Paid_In_Rs__c	, Brokerage_Amount__c, Booking_Date__c, 
                RW_Total_Demand_Raised__c, Cancellation_Requested_Status__c  , Cancellation_Reason__c, Cancellation_Sub_reason__c , 
                Cancellation_descrption__c , Forfeit_Percentage__c  ,Forfeiture_Amount_Type__c, Final_Refund_Amount__c , CGST__c , SGST__c ,  
                Quotation__r.Agreement_Value__c , Quotation__r.Total_Rate_Card_PSF__c, RW_Total_Receipt_Amount_Received__c,  MVAT__c, 
                Primary_Applicant_Name__c, Project__r.CRMHead__r.Name ,Project__r.Overall_CRM_Head__r.Name,Forfeiture_Amount__c,
                Payment_Refund_Amount__c,Resale_Status__c,New_Rate__c,New_Flat_Agreement_Value__c,Received_Amtount__c,
                Referral_Amount_Cancellation_Checklist__c, Referral_Amount__c, Scheme_of_Customer__r.Name, Opportunity__r.SAP_Customer_Number__c,
                Total_Demand_Raised_Principal__c,RW_Total_Interest__c,Total_Brokerage_Amount__c,RW_Registration_Date__c,Net_Rate__c, Unit_No__r.RW_Param1__c,
                Unit_No__r.RW_Param2__c,TAX__c,FBL5N__c,Swipe_Charges__c,RW_Total_Amount_Received_Without_GST__c,GST__c,Interest_with_GST__c,
                Total_Amount_to_be_Transferred__c,Project__r.Accounts_Head__c, Unit_No__r.Relationship_Manager__r.TL_Name__c,NOTE__c,Brokerage_Paid__c,
                Project__r.CRM_MIS_Head__r.Name, New_Unit__c, New_Unit__r.Booking__c, Stamp_Duty_Cheque_Exchang_Amt_to_be_paid__c
                From Booking__c Where Id=:recordId LIMIT 1];
        
        List<Booking__c> newBkg = [SELECT Id, Net_Rate__c, Allotment_Premium__c, Unit_No__r.Saleable_Area__c, Primary_Applicant_Name__c,Opportunity__r.SAP_Customer_Number__c, Booking_Date__c, Unit_No__r.RW_Param1__c,Unit_No__r.RW_Param2__c, Unit_No__r.RW_Param4__c FROM Booking__c WHERE Id =: info.New_Unit__r.Booking__c];
        if(newBkg.size() > 0){
            newInfo = newBkg[0];
        }
         
        /*List<Brokerage_Invoice__c> brokInvoices = [SELECT Id, Total_Amount_Paid__c FROM Brokerage_Invoice__c WHERE Booking__c =: recordId];
        brokerageAmount = 0;
        for(Brokerage_Invoice__c bi : brokInvoices){
            brokerageAmount += bi.Total_Amount_Paid__c;
        }*/
        List<Id> bkgIds = new List<Id>{info.Id};
        if(newInfo != null){
            bkgIds.add(newInfo.Id);
        }
        
        List<Applicant_Details__c> apps = [SELECT Id,Booking__c, Name FROM Applicant_Details__c WHERE Booking__c =: bkgIds AND Applicant_Number__c = 'Second Applicant'];
        
        Map<String, String> appMap = new Map<String, String>();
        for(Applicant_Details__c app : apps){
            appMap.put(app.Booking__c, app.Name);
        }
        if(appMap.get(info.Id) != null){
            oldAppNames = info.Primary_Applicant_Name__c + '/ ' + appMap.get(info.Id);
        }else{
            oldAppNames = info.Primary_Applicant_Name__c;
        }
        if(newInfo != null){
            if(appMap.get(newInfo.Id) != null){
            newAppNames = newInfo.Primary_Applicant_Name__c + '/ ' + appMap.get(newInfo.Id);
            }else{
                newAppNames = newInfo.Primary_Applicant_Name__c;
            }
        }
        
        //lessDeductions = info.GST__c + info.Swipe_Charges__c + info.Interest_with_GST__c + info.Brokerage_Paid__c + info.Total_TDS_Amount_Paid_In_Rs__c;
        lessDeductions = (info.GST__c != null ? info.GST__c : 0) + (info.Swipe_Charges__c != null ? info.Swipe_Charges__c : 0) + 
            (info.Interest_with_GST__c != null ? info.Interest_with_GST__c : 0) + (info.Brokerage_Paid__c != null ? info.Brokerage_Paid__c : 0) +
            (info.Total_TDS_Amount_Paid_In_Rs__c != null ? info.Total_TDS_Amount_Paid_In_Rs__c : 0);
        Decimal totalInterest = info.RW_Total_Interest__c != null ? info.RW_Total_Interest__c : 0;
        Decimal totalAmtCollected = info.RW_Total_Amount_Collected__c != null ? info.RW_Total_Amount_Collected__c : 0;
        info.Interest_with_GST__c = totalInterest - totalAmtCollected + (0.08*(totalInterest - totalAmtCollected));
        gst8Perc = 0.08*(totalInterest - totalAmtCollected);
 	}
    
    public static void sendEmail(string recordId)
    {   
     
     	Booking__c bookingRecord = [select id,Name,Status__c,Cancellation_Reason__c,toLabel(Cancellation_Sub_reason__c),Project__r.CRMHead__c, Project__r.CRMHead__r.Email ,Project__r.Project_CRM_Lead__c, Project__r.Project_CRM_Lead__r.Email,Sales_Manager__c, Sales_Manager__r.Email, Unit_No__r.Relationship_Manager__c, Unit_No__r.Relationship_Manager__r.RM_Email__c , Project__r.Sales_MIS__c, Project__r.Sales_MIS__r.Email from Booking__c where id =:recordId ];
        system.Debug(bookingRecord);
        List<String> emailsToSend = new List<String>();
        string RManager = null;
        string SManger = null;
        string CRMHead = null;
        string CRMLead = null;
        string MISTeam = null ;   
        if(bookingRecord.Unit_No__r.Relationship_Manager__r.RM_Email__c!=null && bookingRecord.Unit_No__r.Relationship_Manager__c != System.label.System_Administrator_User_Id){   
            Rmanager =bookingRecord.Unit_No__r.Relationship_Manager__r.RM_Email__c;
            emailsToSend.add(Rmanager);
        }
        if(bookingRecord.Sales_Manager__r.Email!=null && bookingRecord.Sales_Manager__c != System.label.System_Administrator_User_Id){
            SManger = bookingRecord.Sales_Manager__r.Email;
            emailsToSend.add(SManger);
        }
        if(bookingRecord.Project__r.CRMHead__r.Email!=null && bookingRecord.Project__r.CRMHead__c != System.label.System_Administrator_User_Id){
            CRMHead = bookingRecord.Project__r.CRMHead__r.Email;
            emailsToSend.add(CRMHead);  
        }
        if(bookingRecord.Project__r.Project_CRM_Lead__r.Email!=null && bookingRecord.Status__c  == 'Booking Cancelled - Refunded' && bookingRecord.Project__r.Project_CRM_Lead__c != System.label.System_Administrator_User_Id){
            CRMLead = bookingRecord.Project__r.Project_CRM_Lead__r.Email;
            emailsToSend.add(CRMLead);  
        }
        if(bookingRecord.Project__r.Sales_MIS__r.Email !=null && bookingRecord.Status__c  == 'Booking Cancelled - Refunded' && bookingRecord.Project__r.Sales_MIS__c != System.label.System_Administrator_User_Id){
            MISTeam = bookingRecord.Project__r.Sales_MIS__r.Email;
            emailsToSend.add(MISTeam);  
        }
     Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
	 List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
     //List<String> sendTo = new List<String>();
	 //sendTo.addAll((Label.RW_Email_Milestone).split(','));
	 emailMessage.setToAddresses(emailsToSend);
     emailMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress()); 
     String body = ''; String Sub = '';
     if(bookingRecord.Status__c  == 'Cancellation Initiated'){
   	 Sub = 'Cancellation of Booking Initiated';
     emailMessage.setSubject(Sub);        
     body = 'This is to be notify that cancellation of Booking Initiated for ' + bookingRecord.Name +'. Below is the information:<br /><br />';     
     body += '<b>Cancellation Reason :</b> ' + bookingRecord.Cancellation_Reason__c + '<br>';
     body += '<b>Cancellation Sub Reason :</b> ' + bookingRecord.Cancellation_Sub_reason__c + '<br><br><br>';  
     }
     else if(bookingRecord.Status__c  == 'Booking Cancelled - Refunded'){
     Sub = 'Refund Handover document uploaded';
     emailMessage.setSubject(Sub);        
     body = 'This is to be notify that refund for Booking  ' + bookingRecord.Name + ' is handed over to the customer.<br /><br />';
     }
     body += URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId + '<br><br>'; 
     body += 'Thanks,';  
     emailMessage.setHtmlBody(body);    
     mails.add(emailMessage);
     Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);   
        if (results[0].success){
            System.debug('The email was sent successfully.');
        }else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    }
    
    @InvocableMethod(label='CloningOpportunity' description='cloning the opportunity record when booking is unit transfer')
    public static void cloneOpportunityRecord(List<ID> ids){
        system.debug(ids);
        Opportunity opp = [Select Id ,Name , SAP_Customer_Number__c , RW_Project__c ,AccountId ,StageName ,Account_Mobile_Number__c , Customer_Reference__c , RW_Mobile_No__c , RW_Previous_Opportunity__c ,Walkin_Source__c,Walk_in_Sub_Source__c,RW_Walkin_Channel_Partner__c ,Sales_Manager__c, Booking__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name, Sourcing_Manager__c, RW_Sourcing_Manager__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name from Opportunity Where Id =: ids LIMIT 1]; // Added Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
        Opportunity clonedRecord = opp.clone();
        clonedRecord.Name = opp.Name;
        clonedRecord.StageName = 'Qualification';
        clonedRecord.RW_Previous_Opportunity__c = opp.Id;
        clonedRecord.RW_Mobile_No__c = opp.RW_Mobile_No__c;
        clonedRecord.Walkin_Source__c = opp.Walkin_Source__c;
        clonedRecord.RW_Walkin_Channel_Partner__c = opp.RW_Walkin_Channel_Partner__c;
        clonedRecord.Sales_Manager__c = opp.Sales_Manager__c;
        clonedRecord.SAP_Customer_Number__c = opp.SAP_Customer_Number__c;
        clonedRecord.RW_Project__c = opp.RW_Project__c;
        Map<String, Opp_Close_Date__c> oppClsDateMap = Opp_Close_Date__c.getall();
        if(oppClsDateMap.keySet().size() > 0){
            clonedRecord.CloseDate = System.today().addDays(Integer.valueOf(oppClsDateMap.get(clonedRecord.RW_project__c).No_of_Days__c)); 
        }

        /*clonedRecord.IsCloned__c = true; //Added by Vinay 20-01-2022
        clonedRecord.Previous_Booking_Id__c = opp.Booking__c; //Added by Vinay 20-01-2022
        clonedRecord.Booking__c = null; //Added by Vinay 20-01-2022
        clonedRecord.RW_Sales_Associate__c = opp.RW_Sales_Associate__c; //Added by Vinay 04-02-2022
        clonedRecord.Sourcing_Manager__c = opp.Sourcing_Manager__c; //Added by Vinay 04-02-2022
        clonedRecord.RW_Sourcing_Manager__c = opp.RW_Sourcing_Manager__c; //Added by Vinay 04-02-2022*/
        Insert clonedRecord;
        List<RW_EOI__c> eoi = [Select Id ,Opportunity__c from RW_EOI__c WHere  Opportunity__c =:opp.Id];
            for(RW_EOI__c eoiId : eoi){
            eoiId.Opportunity__c = clonedRecord.Id;
        }
        if(eoi.size() >0){
        	update eoi;
        }
        List<Applicable_Offer__c> applicableOffer = [Select Id ,Opportunity__c from Applicable_Offer__c WHere  Opportunity__c =:opp.Id];
            for(Applicable_Offer__c offerId : applicableOffer){
            offerId.Opportunity__c = clonedRecord.Id;
        }
        if(applicableOffer.size() >0){
        	update applicableOffer;
        }
    }
    
     @AuraEnabled
    public static void updateCancellationChecklistDate(string recordId) {
    BookingTriggerHandler.byPass =true;    
    Booking__c obj = [Select Id, Cancellation_checklist_Upload_Date__c from Booking__c  WHere id=:recordId];
    obj.Cancellation_checklist_Upload_Date__c = system.today();
    update obj;
     BookingTriggerHandler.byPass =false;   
    }
    
    @AuraEnabled
    public static void updateCancellationLetterDate(string recordId) {
    BookingTriggerHandler.byPass =true;    
    Booking__c obj = [Select Id, Cancellation_Letter_Upload_Date__c from Booking__c  WHere id=:recordId];
    obj.Cancellation_Letter_Upload_Date__c = system.today();
    update obj;
    BookingTriggerHandler.byPass =false;    
    }
    
    @AuraEnabled
    public static void updateDeedofCancellationDate(string recordId) {
    BookingTriggerHandler.byPass =true;    
    Booking__c obj = [Select Id, Deed_of_Cancellation_Upload_Date__c from Booking__c  WHere id=:recordId];
    obj.Deed_of_Cancellation_Upload_Date__c = system.today();
    update obj;
    BookingTriggerHandler.byPass =false;    
    }
    
    @AuraEnabled
    public static void transferRequestUpload(string recordId) {
    BookingTriggerHandler.byPass =true;    
    Booking__c obj = [Select Id, Unit_Transfer_Request_Upload_Date__c from Booking__c  WHere id=:recordId];
    obj.Unit_Transfer_Request_Upload_Date__c = system.today();
    update obj;
    BookingTriggerHandler.byPass =false;    
    }
        
    @AuraEnabled
    public static void updateRefundHandoverDocument(string recordId) {
    BookingTriggerHandler.byPass =true;    
    Booking__c obj = [Select Id, Update_Refund_Handover_Date__c , status__c from Booking__c  WHere id=:recordId];
   // obj.Update_Refund_Handover_Date__c = Date.valueof(handoverDocumentDate);
    obj.Status__c = 'Booking Cancelled - Refunded';    
    update obj;
    BookingTriggerHandler.byPass =false;    
    sendEmail(recordId);
    }
    
    @AuraEnabled
    public static Booking__c getBookingRecordData(string recordId) {    
    Booking__c obj = [Select Id, Cancellation_Checklist_Link__c, Cancellation_Deed_Document_Link__c ,Cancellation_Letter_Link__c ,Refund_Handover_Document_Link__c ,Approval_Status__c ,Cancellation_Request_Date__c ,Cancellation_Requested_Status__c,Cancellation_Reason__c ,RW_Registration_Type__c , RW_Registration_Status__c, Status__c from Booking__c  WHere id=:recordId  LIMIT 1];
    return obj;
    }
    
    @AuraEnabled
    public static void updateRetainBooking(string recordId) {        
        Booking__c boookingRecord = [Select Id , Cancellation_Reason__c, Cancellation_Sub_reason__c , Opportunity__c  , Status__c , Cancellation_Requested_Status__c,Opportunity__r.StageName , Old_Opp_Status__c , Old_status__c, Is_Retained__c , Retention_Date__c from Booking__c  WHere id=:recordId];
        string oldstatus = boookingRecord.Old_Opp_Status__c;
        boookingRecord.Reason_For_Cancellation__c = null;
        boookingRecord.Cancellation_Sub_reason__c =  null;
        boookingRecord.Cancellation_Reason__c = null;
        boookingRecord.Cancellation_Requested_Status__c = 'Retained';
        boookingRecord.Status__c =  boookingRecord.Old_status__c;
        boookingRecord.Is_Retained__c = true;
        boookingRecord.Retention_Date__c = system.today();    
        //boookingRecord.Opportunity__r.Status__c = boookingRecord.Old_Opp_Status__c;  
        boookingRecord.Old_status__c = null;
        Opportunity opp = new Opportunity();
        opp.Id = boookingRecord.Opportunity__c;
        opp.StageName = oldstatus;
        update opp;
        BookingTriggerHandler.byPass =true;
        update boookingRecord;
        BookingTriggerHandler.byPass =false;
    }
    
    @AuraEnabled
    public static Booking__c getRefundHandoverInfo(string bookingId) {
    Booking__c boookingRecord = [Select Id,Status__c,Opportunity__r.Status__c,Cancellation_Requested_Status__c from Booking__c  WHere id=:bookingId Limit 1];
    return boookingRecord;
    }
       
    @AuraEnabled
    public  static void sendApprovalRequest(String recordId){
        Booking__c obj = [select Project__r.CRMHead__c , Project__r.Overall_CRM_Head__c , Level_Two_Approver__c , Level_Three_Approver__c from Booking__c Where Id =:recordId];
        if(obj !=null && (obj.Project__r.CRMHead__c != obj.Level_Two_Approver__c || obj.Project__r.Overall_CRM_Head__c != obj.Level_Three_Approver__c)){
            BookingTriggerHandler.byPass =true;
            obj.Level_Two_Approver__c = obj.Project__r.CRMHead__c;
            obj.Level_Three_Approver__c =obj.Project__r.Overall_CRM_Head__c;
            update obj;
            BookingTriggerHandler.byPass =false;
        }
        try{
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Request for Booking Cancellation');
        req1.setObjectId(recordId);
        
        // Submit on behalf of a specific submitter
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Booking_Cancellation_4'); //Commented by Vinay 21-03-2025
        //req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        //System.assert(result.isSuccess());
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
}
    
    @AuraEnabled
    public  static void sendApprovalRequestforUnitTransfer(String recordId){
        Booking__c obj = [select Project__r.CRMHead__c , Project__r.Overall_CRM_Head__c , Level_Two_Approver__c , Level_Three_Approver__c from Booking__c Where Id =:recordId];
        if(obj !=null && (obj.Project__r.CRMHead__c != obj.Level_Two_Approver__c || obj.Project__r.Overall_CRM_Head__c != obj.Level_Three_Approver__c)){
            BookingTriggerHandler.byPass =true;
            obj.Level_Two_Approver__c = obj.Project__r.CRMHead__c;
            obj.Level_Three_Approver__c =obj.Project__r.Overall_CRM_Head__c;
            update obj;
            BookingTriggerHandler.byPass =false;
        }
        try{
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Request for Booking Cancellation');
        req1.setObjectId(recordId);
        
        // Submit on behalf of a specific submitter
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Booking_Unit_Transfer');
        //req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        //System.assert(result.isSuccess());
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
}
    
    @AuraEnabled
    public static Project_Unit__c getUnitInfo(string unitId, String bkgId){
        Project_Unit__c unitInfo = [SELECT Id, Booking__c, Booking__r.Name, Booking__r.Opportunity__r.SAP_Customer_Number__c,Booking__r.Primary_Applicant_Name__c, Booking__r.Allotment_Premium__c, Saleable_Area__c,Booking__r.Net_Rate__c, Booking__r.Booking_Date__c, RW_Param1__c, RW_Param2__c, RW_Param4__c FROM Project_Unit__c WHERE Id =: unitId]; 
        Booking__c bkg = new Booking__c();
        bkg.Id = bkgId;
        bkg.New_Unit__c = unitId;
        BookingTriggerHandler.byPass = true;
        update bkg;
        BookingTriggerHandler.byPass = false;
        return unitInfo;
    }

}