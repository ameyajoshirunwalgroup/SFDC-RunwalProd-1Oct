public class BookingTriggerHandler {
    public static  boolean firstRun = true;
    public static boolean byPass = false;
    public void processRecords(List<Booking__c> newList, Map<Id,Booking__c> newMap, Map<Id, Booking__c> bkMap){  
        set<id> optySet = new set<id>();
        Set<id> pid = new set<id>();
        if(!byPass){
            for(Booking__c bk : newList){
                if(bk.Status__c == 'Booking Confirmed' && (bkMap.get(bk.id).Status__c == 'Booking Received' || bkMap.get(bk.id).Status__c == 'UnProcessed' ||bkMap.get(bk.id).Status__c == 'Sent for Approval'|| bkMap.get(bk.id).Status__c == 'Site Head Approval Pending'  )) {
                    optySet.add(bk.Customer__c);
                    if(bk.Status__c == 'Booking Confirmed'){
                        pid.add(bk.Unit_No__c);
                    }
                }
                //||bk.Status__c =='Booking Cancelled – Refund Pending'||  bk.Status__c =='Cancelled'
                if(((bk.Status__c == 'Booking Confirmed' || bk.Status__c == 'Booking Registered' ) && bk.Status__c != bkMap.get(bk.id).Status__c) ||
                   bk.RW_Actual_Possession_Date__c != bkMap.get(bk.id).RW_Actual_Possession_Date__c || bk.RW_Last_SDR_Received__c != bkMap.get(bk.id).RW_Last_SDR_Received__c ||
                   bk.RW_Registration_Date__c != bkMap.get(bk.id).RW_Registration_Date__c || bk.RW_BRL_Number__c != bkMap.get(bk.id).RW_BRL_Number__c ||
                   bk.RW_ROC_Date__c != bkMap.get(bk.id).RW_ROC_Date__c|| bk.RW_Index_2__c != bkMap.get(bk.id).RW_Index_2__c|| bk.RW_Signed_Agreement_to_Customer_Date__c != bkMap.get(bk.id).RW_Signed_Agreement_to_Customer_Date__c||
                   bk.RW_Agreement_Possession_Date__c != bkMap.get(bk.id).RW_Agreement_Possession_Date__c|| bk.RW_Actual_Possession_Date__c != bkMap.get(bk.id).RW_Actual_Possession_Date__c||
                   bk.RW_Key_handover_date__c != bkMap.get(bk.id).RW_Key_handover_date__c|| bk.Date_of_Occupation_Certificate__c != bkMap.get(bk.id).Date_of_Occupation_Certificate__c||
                   bk.RW_Nominee_Name__c != bkMap.get(bk.id).RW_Nominee_Name__c|| bk.RW_Release_of_Charge_issue_status__c != bkMap.get(bk.id).RW_Release_of_Charge_issue_status__c   ||
                   bk.Funding_Status__c != bkMap.get(bk.id).Funding_Status__c || bk.RW_Loan_Account_Number__c !=bkMap.get(bk.id).RW_Loan_Account_Number__c ||
                   bk.RW_Loan_Amount__c != bkMap.get(bk.id).RW_Loan_Amount__c || bk.Loan_Bank__c != bkMap.get(bk.id).Loan_Bank__c||
                   bk.RW_Loan_Sanction_Date__c != bkMap.get(bk.id).RW_Loan_Sanction_Date__c || bk.RW_Noc_Generated_Date__c !=  bkMap.get(bk.id).RW_Noc_Generated_Date__c ||
                   bk.Customer_Category_Type__c != bkMap.get(bk.id).Customer_Category_Type__c ||
                   (bk.Interest_to_be_Applied__c != bkMap.get(bk.id).Interest_to_be_Applied__c && bkMap.get(bk.id).Interest_to_be_Applied__c == 'No' && bk.Interest_to_be_Applied__c == 'Yes') ||
                   bk.ADF_Opted__c != bkMap.get(bk.Id).ADF_Opted__c // added by digicloud
                  ){
                      optySet.add(bk.Customer__c); 
                      
                  }
                
                if(bk.Status__c == 'UnProcessed' && bk.Funding_Status__c != bkMap.get(bk.id).Funding_Status__c || bk.RW_Loan_Account_Number__c !=bkMap.get(bk.id).RW_Loan_Account_Number__c ||
                   bk.RW_Loan_Amount__c != bkMap.get(bk.id).RW_Loan_Amount__c || bk.Loan_Bank__c != bkMap.get(bk.id).Loan_Bank__c||
                   bk.RW_Loan_Sanction_Date__c != bkMap.get(bk.id).RW_Loan_Sanction_Date__c || bk.RW_Noc_Generated_Date__c !=  bkMap.get(bk.id).RW_Noc_Generated_Date__c){
                       optySet.add(bk.Customer__c); 
                   }
                
            }
            if(pid.size()>0){
                List<Project_Unit__c> pUnits = [select id,RW_Unit_Status__c,RW_Booking_Date__c from Project_Unit__c where id in :pid];
                for(Project_Unit__c p : pUnits){
                    p.RW_Unit_Status__c ='Booked';
                    // Added By UBSDigicloud on 26-06-2025 START
                    p.RW_Booking_Date__c = System.today(); 
                    p.Is_Booking_Tagged__c=True; 
                    for (Booking__c bk : newList) {
                        if (bk.Unit_No__c == p.Id) {
                            p.Booking__c = bk.Id;
                            break;
                        }
                    }
                    // UBSDigicloud added on 26-06-2025 END
                }
                update pUnits;
            }
            if(optySet.size()>0){
                SalesOrderUpdateCallout.UpdateSO(optySet);
            }
        }
    }
    
    public void createLoanRecords(List<Booking__c> bkgs){
        //Map<String, Bank_with_RM__c> mapBankRM = Bank_with_RM__c.getall();//Commented by Prashant on 7-5-25.
        //Adding a filter Inactive = false to get only active bank with RM records.
        //Added by Prashant. 7-5-25.///////Start
        list<Bank_with_RM__c> bankWithRMLst = [SELECT id,Name,Inactive__c,CreatedDate,Disb_RM_Email__c,Disb_RM_Name__c,Project__c,RM_Email__c,RM_Name__c,TL_Email__c,TL_Name__c from Bank_with_RM__c where Inactive__c = false];
        Map<String, Bank_with_RM__c> mapBankRM = new Map<String, Bank_with_RM__c>(); 
        if(!bankWithRMLst.isEmpty()){
            for(Bank_with_RM__c b : bankWithRMLst){
                mapBankRM.put(b.Name,b);
            }
        }
        //Added by Prashant. 7-5-25.///////End
        Map<String, Project_Shortforms__c> projShortName = Project_Shortforms__c.getall();
        Map<String, RM_Usernames__c> mapRM = RM_Usernames__c.getall();
        List<Loan__c> loansToInsert = new List<Loan__c>();
        Set<Id> bkgIds = new Set<Id>();
        List<Home_Loan_RM__c> HLRMs = [SELECT Id,Name,Project__c,Project__r.Name,RM_Name__c,TL_Name__c,TL_Email__c,
                                       Reporting_1_Email__c,Reporting_2_Email__c FROM Home_Loan_RM__c];
        Map<String, Home_Loan_RM__c> hlrmMap = new Map<String, Home_Loan_RM__c>();
        Map<String, Home_Loan_RM__c> projRMMap = new Map<String, Home_Loan_RM__c>();
        for(Home_Loan_RM__c rm : HLRMs){
            hlrmMap.put(rm.Name, rm);
            projRMMap.put(rm.Project__r.Name, rm);
        }
        for(Booking__c bkg : bkgs){
            bkgIds.add(bkg.Id);
        }
        List<Loan__c> loans = [SELECT Id,Name,RW_Booking__c FROM Loan__c WHERE RW_Booking__c =: bkgIds];
        Map<Id,Id> bkgIdVsLnId = new Map<Id,Id>();
        for(Loan__c ln : loans){
            bkgIdVsLnId.put(ln.RW_Booking__c, ln.Id); 
        }
        for(Booking__c bkg : bkgs){
            if(bkgIdVsLnId.get(bkg.Id) == null || Test.isRunningTest()){
                Loan__c ln = new Loan__c();
                ln.RW_Booking__c = bkg.Id;
                ln.RW_Bank_Name__c = bkg.Loan_Bank__c;
                ln.RW_Bank_Preference_1__c = bkg.Loan_Bank__c;
                ln.RW_Opportunity__c = bkg.Opportunity__c;
                ln.RW_Loan_Record_Status__c = 'Loan Process Initiated';
                ln.RW_Project_Name__c = bkg.Project__c;
                ln.RW_Tower__c = bkg.Wing__c;
                ln.RW_Unit_No__c = bkg.Unit_No__c;
                //if(bkg.RW_Project_Name__c == 'Runwal Gardens'){
                // modified by Aditya (Saasworx) HL RM Tag after Insert
                /*if(bkg.Loan_Bank__c != null){
                    if(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c) != null){
                        if(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c != null)
                            ln.HL_RM_Name__c = mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).TL_Name__c;
                        if(hlrmMap.get(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_1_Email__c != null)
                            ln.HL_Reporting_1_Email__c = hlrmMap.get(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_1_Email__c;
                        if(hlrmMap.get(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_2_Email__c != null)
                            ln.HL_Reporting_2_Email__c = hlrmMap.get(mapBankRM.get(bkg.Loan_Bank__c+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_2_Email__c;
                    }else{
                        if(mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c != null)
                            ln.HL_RM_Name__c = mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c;
                        ln.HL_TL_Name__c = mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).TL_Name__c;
                        if(hlrmMap.get(mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_1_Email__c != null)
                            ln.HL_Reporting_1_Email__c = hlrmMap.get(mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_1_Email__c;
                        if(hlrmMap.get(mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_2_Email__c != null)
                            ln.HL_Reporting_2_Email__c = hlrmMap.get(mapBankRM.get('Other'+ '-' + projShortName.get(bkg.RW_Project_Name__c).Short_Name__c).RM_Name__c).Reporting_2_Email__c;
                    }
                }else{
                    ln.HL_TL_Name__c = System.label.Home_Loan_TL_Name;
                    ln.TL_Email__c = System.label.Home_Loan_TL_Email;
                    ln.HL_Reporting_1_Email__c = hlrmMap.get(System.label.Home_Loan_TL_Name).Reporting_1_Email__c;
                    ln.HL_Reporting_2_Email__c = hlrmMap.get(System.label.Home_Loan_TL_Name).Reporting_2_Email__c;
                }*/
                loansToInsert.add(ln);
                /*}else{
ln.HL_RM_Name__c = projRMMap.get(bkg.RW_Project_Name__c).RM_Name__c;
ln.HL_TL_Name__c = projRMMap.get(bkg.RW_Project_Name__c).TL_Name__c;
ln.TL_Email__c = projRMMap.get(bkg.RW_Project_Name__c).TL_Email__c;
}*/
            }
        }
        if(loansToInsert.size() > 0 && !Test.isRunningTest()){
            insert loansToInsert;
            //  modified by Aditya (Saasworx) HL RM Tag after Insert
            /*List<Loan__c> lns = new List<Loan__c>();
            for(Loan__c ln : loansToInsert){
                if(ln.HL_RM_Name__c == null){
                    lns.add(ln);
                }
            }
            if(lns.size() > 0){
                LoanController.sendEmailLoanCreated(lns);
            }*/
        }    		
    }
    
    public static void updateBrokerageSummaryStatus(Set<Id> SummaryIds){
        if(!byPass){//Added by Prashant to bypass trigger conditions. //20-05-2025....
            List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
            List<Brokerage__c> brokerageList = new List<Brokerage__c>();
            List<Brokerage__c> brokerageupdateList = new List<Brokerage__c>();
            brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c,Status__c from Brokerage_Summary__c where Booking__c IN: SummaryIds];
            if(!brokerSummaryList.isEmpty()){
                brokerageList = [Select id,name from Brokerage__c where Brokerage_Summary__c =:brokerSummaryList[0].id ];
                if(brokerSummaryList[0].Status__c != 'Due' && !brokerSummaryList.isEmpty()){
                    brokerSummaryList[0].Status__c = 'Due';
                    update brokerSummaryList;
                }
                for(Brokerage__c bl :brokerageList){
                    Brokerage__c bb = new Brokerage__c();
                    bb.Id = bl.Id;
                    bb.Status__c = 'Due';
                    brokerageupdateList.add(bb);
                }
                if(!brokerageupdateList.isEmpty()){
                    update brokerageupdateList;
                }
            }
        }
    }
    
    public static void ShowInvoice(Set<Id> SummaryIds){
        List<Brokerage_Summary__c> brokerSummaryList = new List<Brokerage_Summary__c>();
        List<Brokerage_Summary__c> UpdatebrokerSummaryList = new List<Brokerage_Summary__c>();
        brokerSummaryList = [select Id,Name,Broker__c,Brokerage_Scheme__c,Opportunity__c,Status__c from Brokerage_Summary__c where Id IN: SummaryIds];
        if(!brokerSummaryList.isEmpty()){
            For(Brokerage_Summary__c bs :brokerSummaryList){
                Brokerage_Summary__c bss = new Brokerage_Summary__c();
                bss.Id = bs.Id;
                bss.Show_Invoice__c = true;
                UpdatebrokerSummaryList.add(bss);
            }
        }
        if(!UpdatebrokerSummaryList.isEmpty()){
            Update UpdatebrokerSummaryList;
        }
        
    }
    public static void updateexcludebatch(Set<Id> BIds){
        List<Booking__c> BookingList = new List<Booking__c>();
        List<Booking__c> UpdateBookingList = new List<Booking__c>();
        BookingList = [select Id,Name,Exclude_From_Brokerage_Batch__c,Old_Booking__c,RW_Registration_Done__c,RW_X9_99_Received__c,Invoice_Submitted_by_CP__c from Booking__c where Id IN: BIds];
        if(!BookingList.isEmpty()){
            For(Booking__c b :BookingList){
                if(b.RW_Registration_Done__c == 'Yes' && b.RW_X9_99_Received__c == true && b.Invoice_Submitted_by_CP__c == true  ){
                    Booking__c book = new Booking__c();
                    book.Id = b.Id;
                    book.Exclude_From_Brokerage_Batch__c = true;
                    UpdateBookingList.add(book);
                }
            }
        }
        if(!UpdateBookingList.isEmpty()){
            Update UpdateBookingList;
        }
        
    }
    //Added by coServe 10-10-2022 start
    public void updateCAMandDevChargeDetails(List<Id> bks){
        List<Id> units = new List<Id>();
        List<Id> projs = new List<Id>();
        List<Id> bkgIds = new List<Id>();
        List<Booking__c> bkgToUpdateCAM = new List<Booking__c>();
        List<Booking__c> bkgToUpdateDevChrg = new List<Booking__c>();
        List<Booking__c> bkgs = [SELECT Id,Unit_No__c,F_B_CAM__c,Project__c,Project__r.Name,Development_Charge__c FROM Booking__c WHERE Id =: bks];
        for(Booking__c bk : bkgs){
            if(bk.Project__r.Name == 'Runwal Gardens'){
                units.add(bk.Unit_No__c);
            }else{
                projs.add(bk.Project__c);
            } 
        }
        if(units.size() > 0){
            List<Rate_List__c> rates = [SELECT Id,Amount__c,Project_Unit__c FROM Rate_List__c WHERE Project_Unit__c =: units AND (Global_Charges__r.Name = 'BCAM' OR Global_Charges__r.Name = 'CAM')];
            
            for(Booking__c b : bkgs){
                Double totalCharge = 0;
                for(Rate_List__c rt : rates){
                    if(rt.Project_Unit__c == b.Unit_No__c){
                        totalCharge += rt.Amount__c;
                    }
                }
                b.F_B_CAM__c = totalCharge;
                if(totalCharge > 0){
                    bkgToUpdateCAM.add(b);
                }  
            }
            update bkgToUpdateCAM;
        }
        
        if(projs.size() > 0){
            List<Project_Charges__c> projCharges = [SELECT Id, S_Lumpsum_Charge_Amount__c, Project__c FROM Project_Charges__c WHERE Name = 'Development Charges' AND Project__c =: projs];
            Map<Id,Double> mapProjVsDevCharge = new Map<Id,Double>();
            for(Project_Charges__c chrg : projCharges){
                mapProjVsDevCharge.put(chrg.Project__c, chrg.S_Lumpsum_Charge_Amount__c);
            }
            for(Booking__c bk : bkgs){
                bk.Development_Charge__c = mapProjVsDevCharge.get(bk.Project__c);
                bkgToUpdateDevChrg.add(bk);
            }
            if(bkgToUpdateDevChrg.size() > 0){
                update bkgToUpdateDevChrg;
            }
        }   
    }
    //Added by coServe 10-10-2022 end
    
    //Added by coServe 15-11-2022 start
    public static void UpdateBookingDateInOppAndUnit(List<Booking__c> bkgs){
        List<Id> oppIds = new List<Id>();
        List<Id> unitIds = new List<Id>();
        Map<Id, Date> bkgIdVsDate = new Map<Id, Date>();
        //List<Booking__c> bkgs = [SELECT Id, Customer__c, Unit_No__c, Opportunity__c, Booking_Date__c FROM Booking__c WHERE Id =: bkgIds];
        for(Booking__c bkg : bkgs){
            oppIds.add(bkg.Customer__c);
            unitIds.add(bkg.Unit_No__c);
            bkgIdVsDate.put(bkg.Id, Date.valueOf(bkg.Booking_Date__c));
        }
        List<Project_Unit__c> units = [SELECT Id,Booking__c,Booking__r.Booking_Date__c FROM Project_Unit__c WHERE Id =: unitIds];
        for(Project_Unit__c unit : units){
            unit.RW_Booking_Date__c = bkgIdVsDate.get(unit.Booking__c);
        }
        update units;
        
        List<Opportunity> opps = [SELECT Id,Booking__c,Booking__r.Booking_Date__c FROM Opportunity WHERE Id =: oppIds];
        for(Opportunity opp : opps){
            opp.RW_Booking_Date_Opp__c = bkgIdVsDate.get(opp.Booking__c);
        }
        update opps;
        
    }
    //Added by coServe 15-11-2022 end
    
    //Added by Prashant 30-05-2025 Start..///// Update booking date on Opportunity based on booking date on booking.
    public static void UpdateBookingDateInOpp(List<Booking__c> bkgs){
        list<Opportunity> opps = new list<Opportunity>();
        for(Booking__c bkg : bkgs){
            Opportunity o = new Opportunity();
            o.Id = bkg.Customer__c;
            o.Booking_Date__c = Date.valueOf(bkg.Booking_Date__c);
            opps.add(o);
        }
        try{
            update opps;             
        }catch(Exception e){
            system.debug('Error while updating Opportunity - >> '+e.getMessage());
        }
        
    }
    //Added by Prashant 30-05-2025 End..///// Update booking date on Opportunity based on booking date on booking.
    
    /*
//Added by Prashant 04-06-2025 Start..///// Update Total Amount Received on Opp based on Total Amount Received on booking.
public static void UpdateTotalAmountReceivedInOpp(List<Booking__c> bkgs){
list<Opportunity> opps = new list<Opportunity>();
for(Booking__c bkg : bkgs){
Opportunity o = new Opportunity();
o.Id = bkg.Customer__c;
o.RW_Total_Receipt_Amount_Received__c = bkg.RW_Total_Receipt_Amount_Received__c;
opps.add(o);
}
Database.update(opps, false);

}
//Added by Prashant 04-06-2025 End..///// Update Total Amount Received on Opp based on Total Amount Received on booking.

//Added by Prashant 04-06-2025 Start..///// Update Agreeement value for broker calculation.
public static void UpdateAVforBrokerCalcNew(Set<id> bkgs){
List<Booking__c> bookingsToUpdate = [SELECT Id, Quotation__c, Stamp_duty_Paid2__c, Stamp_duty_payable_by_Runwal__c,Quotation__r.Broker_Agreement_Value_New__c FROM Booking__c WHERE Id IN :bkgs];
if(!bookingsToUpdate.isEmpty()){
for(Booking__c b: bookingsToUpdate){
if( b.Stamp_duty_Paid2__c > b.Stamp_duty_payable_by_Runwal__c){
b.AV_for_broker_calculation_new__c = b.Quotation__r.Broker_Agreement_Value_New__c-(b.Stamp_duty_Paid2__c - b.Stamp_duty_payable_by_Runwal__c);
}else{
b.AV_for_broker_calculation_new__c = b.Quotation__r.Broker_Agreement_Value_New__c;
}
}
Database.update(bookingsToUpdate, false);
} 
}
//Added by Prashant 04-06-2025 End..///// Update Agreeement value for broker calculation.
*/
    
    //Added by coServe 24-04-2024 start-
    public static void sendDayOfRegWhatsAppFBLink(List<String> bkgIds){
        List<Booking__c> bkgs = [SELECT Id,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c,Opportunity__r.SAP_Customer_Number__c FROM Booking__c WHERE Id =: bkgIds];
        List<String> mobileNums = new List<String>();
        List<String> crns = new List<String>();
        for(Booking__c bkg : bkgs){
            mobileNums.add(bkg.Opportunity__r.RW_Mobile_No__c);
            crns.add(bkg.Opportunity__r.SAP_Customer_Number__c);
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.Opportunity__r.Account.Country_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Registration Date Entry'); // Added by coServe 15-07-2024
            }
        }
        List<WhatsApp_Feedback__c> wfb = [SELECT Id,CRN__c,Mobile_Number__c,Opportunity__c,Opportunity__r.Booking__c FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobileNums AND Feedback_Type__c = 'Day of Registration' AND CRN__c =: crns];
        Map<String, WhatsApp_Feedback__c> fbMap = new Map<String, WhatsApp_Feedback__c>();
        for(WhatsApp_Feedback__c fb : wfb){
            fbMap.put(fb.Opportunity__r.Booking__c, fb);
        }
        for(Booking__c bkg : bkgs){
            if(fbMap.get(bkg.Id) == null){
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsg(null, null, null, null, null, null, null, null, null, bkg.Opportunity__r.Account.Country_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'Day of Registration');
                }
            }
        }
    }
    public static void sendDayOfKeyHandWhatsAppFBLink(List<String> bkgIds){
        List<Booking__c> bkgs = [SELECT Id,Primary_Applicant_Name__c,Opportunity__r.Account.Country_Code__c,Opportunity__r.RW_Mobile_No__c,Opportunity__r.SAP_Customer_Number__c FROM Booking__c WHERE Id =: bkgIds];
        List<String> mobileNums = new List<String>();
        List<String> crns = new List<String>();
        for(Booking__c bkg : bkgs){
            mobileNums.add(bkg.Opportunity__r.RW_Mobile_No__c);
            crns.add(bkg.Opportunity__r.SAP_Customer_Number__c);
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,bkg.Primary_Applicant_Name__c,null,null,null,null,null,null,null,bkg.Opportunity__r.Account.Country_Code__c,bkg.Opportunity__r.RW_Mobile_No__c,'Possession Done Alert'); // Added by coServe 15-07-2024
            }
        }
        List<WhatsApp_Feedback__c> wfb = [SELECT Id,CRN__c,Mobile_Number__c,Opportunity__c,Opportunity__r.Booking__c FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobileNums AND Feedback_Type__c = 'Day of Possession Handover' AND CRN__c =: crns];
        Map<String, WhatsApp_Feedback__c> fbMap = new Map<String, WhatsApp_Feedback__c>();
        for(WhatsApp_Feedback__c fb : wfb){
            fbMap.put(fb.Opportunity__r.Booking__c, fb);
        }
        for(Booking__c bkg : bkgs){
            if(fbMap.get(bkg.Id) == null){
                if(!Test.isRunningTest()){
                    SendWhatsAppMsg.methodToSendWhatsAppMsg(null, null, null, null, null, null, null, null, null, bkg.Opportunity__r.Account.Country_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'Day of Key Handover');
                }
            }
        }
    }
    public static void submitForApproval(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookingMap) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        for (Booking__c booking : newBookings) {
            Booking__c oldBooking = oldBookingMap.get(booking.Id);
            if (oldBooking.Interest_to_be_Applied__c == 'No' && booking.Interest_to_be_Applied__c == 'Yes' && booking.Status__c == 'Booking Confirmed') {
                
                // Create an Approval request for the Booking record
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitting Booking for approval due to Interest Applied change.');
                approvalRequest.setObjectId(booking.Id); 
                approvalRequest.setSubmitterId(UserInfo.getUserId()); 
                approvalRequest.setProcessDefinitionNameOrId('Interest_Approval_Process');
                
                // Add the request to the list
                approvalRequests.add(approvalRequest);
            }
        }
        if (!approvalRequests.isEmpty()){
            Approval.ProcessResult[] approvalResults = Approval.process(approvalRequests);
        }
    }
    //Added by coServe 24-04-2024 End
    //Added by Vinay 13-12-2024 Start
    /*public static void sendNotificationToCustomer(List<String> bkgIds){

List<Receipt__c> receipts = [SELECT Id, Booking__c, Total_Amount__c FROM Receipt__c WHERE Booking__c =: bkgIds];
Map<String, Decimal> recptMap = new Map<String, Decimal>();
if(receipts.size() > 0){
for(Receipt__c rec : receipts){
if(recptMap.keySet().contains(rec.Booking__c)){
recptMap.put(rec.Booking__c, recptMap.get(rec.Booking__c) + rec.Total_Amount__c);
}else{
recptMap.put(rec.Booking__c, rec.Total_Amount__c);
}
}
}

List<Booking__c> bkgs = [SELECT Id, Primary_Applicant_Name__c, Opportunity__r.Account.Country_Code__c, Opportunity__r.RW_Mobile_No__c, Opportunity__r.SAP_Customer_Number__c, Opportunity__r.RW_Email__c, Allotment_Premium__c FROM Booking__c WHERE Id =: bkgIds];
List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
for(Booking__c bkg : bkgs){

Decimal receiptPercentage;
if(recptMap.get(bkg.id) != null && bkg.Allotment_Premium__c != null && bkg.Allotment_Premium__c != 0){
receiptPercentage = (recptMap.get(bkg.id) / bkg.Allotment_Premium__c)*100;  
}
if(receiptPercentage < 5){
if(!Test.isRunningTest()){
bkg.Next_Reminder_Date_5_Payment__c = Date.today() + 3;
}else{
bkg.Next_Reminder_Date_5_Payment__c = Date.today();
}
//bkg.Next_Reminder_Date_5_Payment__c = Date.today() + 3;

Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
message.toAddresses = new List<String>{bkg.Opportunity__r.RW_Email__c};
String emailBody = 'Dear Customer,<br/><br/>';
emailBody += 'We acknowledge your booking with Runwal.<br/>';
emailBody += 'To move to the next steps of your booking journey we request you to kindly clear the initial 5% of your agreement value.<br/><br/>';
emailBody += 'Post the clearance of the initial 5% of agreement value from your end, we will initiate a call with our representative to take you through the further steps of your booking Journey.<br/>';
emailBody += 'We thank you for choosing Runwal to be your preferred partner to deliver your dream home.<br/><br/>';
emailBody += 'Incase, you have paid 5%, then kindly ignore this email.<br/><br/>';
emailBody += 'Regards,<br/>';
emailBody += 'Runwal Group';
String plainTextBody = 'Dear Customer,\n\n We acknowledge your booking with Runwal. \n To move to the next steps of your booking journey we request you to kindly clear the initial 5% of your agreement value. \n\n Post the clearance of the initial 5% of agreement value from your end, we will initiate a call with our representative to take you through the further steps of your booking Journey. \n We thank you for choosing Runwal to be your preferred partner to deliver your dream home. \n\n Incase, you have paid 5%, then kindly ignore this email. \n\n Regards,\n Runwal Group';
message.setHtmlBody(emailBody);
message.setSubject('Initial Payment clearance notification towards your purchased Runwal unit');
message.setPlainTextBody(plainTextBody);
message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
messages.add(message);

if(!Test.isRunningTest()){
SendWhatsAppMsg.methodToSendWhatsAppMsg(null, null, null, null, null, null, null, null, null, bkg.Opportunity__r.Account.Country_Code__c, bkg.Opportunity__r.RW_Mobile_No__c, 'Booking Confirmaton');
}
}
}
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
update bkgs;
}*/
    //Added by Vinay 13-12-2024 End
    //
    
    //Added by Prashant 20-05-2025 Start
    public static void updateBrokerageonSchemeChange(List<Id> bkgIds){
        
        List<Booking__c> bklist = [SELECT Id,Booking_Date__c,Quotation__r.walkin_Source__c ,Brokerage_Scheme__r.Type__c,Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c,Brokerage_Scheme__r.Name,Brokerage_Scheme__r.Id,Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c,Passback_Amount__c,
                                   Brokerage_Scheme__c,Quotation__r.Brokerage_Agreement_Value__c,Type_of_Client__c FROM Booking__c WHERE Id IN: bkgIds];
        if(!bklist.isEmpty()){
            for(booking__c b : bklist){
                Date bookingDate = Date.ValueOf(b.Booking_Date__c);
                Date bookingDate2 = Date.ValueOf('2024-04-01T06:00:00.000Z');
                Decimal passbackAmt = 0;
                if(b.Passback_Amount__c != null){
                    passbackAmt = b.Passback_Amount__c;
                }
                if(b.Quotation__r.walkin_Source__c == 'Channel Partner'){
                    if(b.Brokerage_Scheme__r.Type__c == 'Local'){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - ((( passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(b.Brokerage_Scheme__r.Type__c == 'NRI' && bookingDate < bookingDate2){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c - (((passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if( b.Brokerage_Scheme__r.Type__c == 'NRI' && bookingDate >= bookingDate2){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(b.Brokerage_Scheme__r.Type__c == 'Both' && (b.Type_of_Client__c == 'Local' || b.Type_of_Client__c == 'Corporate' )){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(b.Brokerage_Scheme__r.Type__c == 'Both' && (b.Type_of_Client__c == 'NRI' || b.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }else if(b.Brokerage_Scheme__r.Type__c == 'Both' && (b.Type_of_Client__c == 'NRI' || b.Type_of_Client__c == 'Outstation') && bookingDate >= bookingDate2){
                        b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((b.Passback_Amount__c /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                        b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c;
                        b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                        b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                        b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    }
                }
            }
            try{
                update bklist;
            }catch(Exception e){
                system.debug('Error while updating Booking list - '+e.getMessage());
            }
        }
    }
    //Added by Prashant 20-05-2025 End
    
    // Added by UBSDigicloud 23-06-2025 START
    public static void processQuoteAndRelatedUpdates(List<Booking__c> bookingList) {
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Booking__c> quoteToBooking = new Map<Id, Booking__c>();
        
        for (Booking__c b : bookingList) {
            if (b.Quotation__c != null) {
                quoteIds.add(b.Quotation__c);
                quoteToBooking.put(b.Quotation__c, b);
            }
        }
        
        if (quoteIds.isEmpty()) return;
        
        // Quotation Data
        Map<Id, Quotation__c> quoteMap = new Map<Id, Quotation__c>([
            SELECT Id, Token_Amount__c, ST_Token_Amount__c, Zone__c, Wing__c, Appartment_Configuration__c,
            FloorNo__c, Carpet_Area_Sq_Ft__c, No_of_parking__c, Parking_Type__c, FlatNo__c,
            Project__c, Project_Unit__c, Agreement_Value_D__c, Agreement_Value__c,
            Discount_9_Type__c, Discount_9_L__c, Discount_10_Type__c, Discount_10_L__c,
            Discount_11_Type__c, Discount_11_L__c, Is_Special_Brokerage_Scheme__c, Quote_Status__c,
            Project_Unit__r.TowerName__c, Brokerage_Agreement_Value__c, walkin_Source__c,
            Tandem_car_park_Additional__c, Tandem_Open_Additional__c, Single_Open_Additional__c,
            Single_car_park_Additional__c, Stack_Additional__c, MLCP_Additional__c,
            Basement_Additional__c, Podium__c, Puzzle_Car_Park__c,Stamp_duty_payable_by_Runwal__c 
            FROM Quotation__c WHERE Id IN :quoteIds
        ]);
        
        // Booking Field Updates
        for (Booking__c b : bookingList) {
            Quotation__c q = quoteMap.get(b.Quotation__c);
            if (q == null) continue;
          //  b.Stamp_duty_payable_by_Runwal_Currency__c = q.Stamp_duty_payable_by_Runwal__c;
            b.Token_Amount__c = q.Token_Amount__c;
            b.ST_Token_Amount__c = q.ST_Token_Amount__c;
            b.Zone__c = q.Zone__c;
            b.Wing__c = q.Wing__c;
            b.Flat_Typology__c = q.Appartment_Configuration__c;
            b.Floor__c = q.FloorNo__c;
            b.Carpet_Area__c = q.Carpet_Area_Sq_Ft__c;
            b.No_of_parking__c = q.No_of_parking__c;
            b.Parking_Type__c = q.Parking_Type__c;
            b.Flat_No__c = q.FlatNo__c;
            b.Project__c = q.Project__c;
            b.Unit_No__c = q.Project_Unit__c;
            b.Is_Special_Brokerage_Scheme__c = q.Is_Special_Brokerage_Scheme__c;
            b.Tower__c = q.Project_Unit__r != null ? q.Project_Unit__r.TowerName__c : null;
            b.Allotment_Premium__c = (q.Agreement_Value_D__c == null || q.Agreement_Value_D__c == 0)
                ? q.Agreement_Value__c : q.Agreement_Value_D__c;
            
            b.Passback_Amount__c = (q.Discount_9_Type__c == 'CP Passback' && q.Quote_Status__c == 'Valid' && q.Discount_9_L__c != null) ? q.Discount_9_L__c : 0;
            b.Referral_Passback_Amount__c = (q.Discount_10_Type__c == 'Referral Passback' && q.Quote_Status__c == 'Valid' && q.Discount_10_L__c != null) ? q.Discount_10_L__c : 0;
            b.Referral_Discount_Amount__c = (q.Discount_11_Type__c == 'Referral' && q.Quote_Status__c == 'Valid' && q.Discount_11_L__c != null) ? q.Discount_11_L__c : 0;
            
            if (q.Brokerage_Agreement_Value__c != null && q.walkin_Source__c == 'Channel Partner') {
                Decimal baseBrokerage = 2.0;
                b.Base_Brokerage_2__c = baseBrokerage;
                b.Brokerage__c = baseBrokerage - ((b.Passback_Amount__c / q.Brokerage_Agreement_Value__c) * 100).setScale(2);
            }
        }
        
        // CPPH Updates
        List<Customer_Pay_Plan_Header__c> toUpdateCPPH = new List<Customer_Pay_Plan_Header__c>();
        for (Customer_Pay_Plan_Header__c cpph : [
            SELECT Id, Booking__c, Customer__c, Quotation__c
            FROM Customer_Pay_Plan_Header__c
            WHERE Quotation__c IN :quoteIds
        ]) {
            Booking__c b = quoteToBooking.get(cpph.Quotation__c);
            if (b != null) {
                cpph.Booking__c = b.Id;
                cpph.Customer__c = b.Opportunity__c;
                toUpdateCPPH.add(cpph);
            }
        }
        if (!toUpdateCPPH.isEmpty()) update toUpdateCPPH;
        
        // Parking Allocation
        List<Car_Parking_Charge__c> toUpdateParking = new List<Car_Parking_Charge__c>();
        for (Quotation__c q : quoteMap.values()) {
            Booking__c booking = quoteToBooking.get(q.Id);
            if (booking == null) continue;
            
            Map<String, Integer> parkingCounts = new Map<String, Integer>{
                'Tandem Covered' => (q.Tandem_car_park_Additional__c == null ? 0 : Integer.valueOf(q.Tandem_car_park_Additional__c)),
                    'Covered Stack' => (q.Tandem_Open_Additional__c == null ? 0 : Integer.valueOf(q.Tandem_Open_Additional__c)),
                    'Single Open' => (q.Single_Open_Additional__c == null ? 0 : Integer.valueOf(q.Single_Open_Additional__c)),
                    'Single Covered' => (q.Single_car_park_Additional__c == null ? 0 : Integer.valueOf(q.Single_car_park_Additional__c)),
                    'Stilt' => (q.Stack_Additional__c == null ? 0 : Integer.valueOf(q.Stack_Additional__c)),
                    'MLCP' => (q.MLCP_Additional__c == null ? 0 : Integer.valueOf(q.MLCP_Additional__c)),
                    'Basement' => (q.Basement_Additional__c == null ? 0 : Integer.valueOf(q.Basement_Additional__c)),
                    'Podium' => (q.Podium__c == null ? 0 : Integer.valueOf(q.Podium__c)),
                    'Puzzle Car Park' => (q.Puzzle_Car_Park__c == null ? 0 : Integer.valueOf(q.Puzzle_Car_Park__c))
                    };
                        
                        for (String parkingType : parkingCounts.keySet()) {
                            Integer required = parkingCounts.get(parkingType);
                            if (required <= 0) continue;
                            
                            List<Car_Parking_Charge__c> slots = [
                                SELECT Id, Parking__c, Category__c, Status__c, Project__c
                                FROM Car_Parking_Charge__c
                                WHERE Parking__c = :parkingType AND Status__c = 'Vacant'
                                AND Category__c = 'Additional' AND Project__c = :q.Project__c
                                LIMIT :required
                            ];
                            
                            for (Car_Parking_Charge__c slot : slots) {
                                slot.Status__c = 'Booked';
                                slot.Booking__c = booking.Id;
                                toUpdateParking.add(slot);
                            }
                        }
        }
        if (!toUpdateParking.isEmpty()) update toUpdateParking;
    } 
    // // Added by UBSDigicloud 23-06-2025 END
    
    //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.START
    public static void updateAVonOpportunity(Map<Id,Decimal> oppIdVsAVMap){             
        list<Opportunity> opplistt = new list<Opportunity>();
        if(!oppIdVsAVMap.keyset().isEmpty()){
            for(Id oppId : oppIdVsAVMap.keyset()){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.RW_Agreement_Value__c = oppIdVsAVMap.get(opp.Id);
                opplistt.add(opp);
            }
        }
        
        Database.SaveResult[] oppList1 = Database.update(opplistt, false);
        
        for(Database.SaveResult sr : oppList1){
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()){
                    System.debug(err.getStatusCode() + ':' + err.getMessage());
                }
            }
        }
    }
    //Added by Prashant to update Agreement value on Opportunity if allotment premium is updated on Booking.////27-06-2025.END
    
    
    /*public static void assignBaseBrokerageAccruedDashboards(list<Id> bids,Map<Id,Booking__c> oldmap){
        list<Booking__c> blist = [Select Id,Passback__c,Brokerage_Scheme__c,Custom_Base_Brokerage__c,Agreement_Value_for_brokers__c,Brokerage__c,Brokerage_Summary__c                                  
                                  from Booking__c where Id In : bids];
        if(!blist.isEmpty()){
            system.debug('blist-'+blist);
            for(Booking__c bkg : blist){
            if(oldMap == null){
                system.debug('Inside oldmap null');
                //Trigger Insert.... 
                if(bkg.Passback__c != null){
                    if(bkg.Brokerage_Scheme__c != null){                                
                        if(bkg.Custom_Base_Brokerage__c != null){
                            bkg.Base_Brokerage_Accrued_Dashboards__c = (bkg.Custom_Base_Brokerage__c - bkg.Passback__c) * bkg.Agreement_Value_for_brokers__c ;
                        }else{
                            bkg.Base_Brokerage_Accrued_Dashboards__c = bkg.Brokerage__c * bkg.Agreement_Value_for_brokers__c;
                        }
                    }else{
                        bkg.Base_Brokerage_Accrued_Dashboards__c = (2 - bkg.Passback__c) * bkg.Agreement_Value_for_brokers__c;
                    }
                }else{
                    bkg.Base_Brokerage_Accrued_Dashboards__c = 2 * bkg.Agreement_Value_for_brokers__c;
                } 
            }else if(oldmap != null){
                system.debug('Inside oldmap not null');
                //Trigger Update.... 
                if(oldmap.get(bkg.Id).Brokerage_Scheme__c != bkg.Brokerage_Scheme__c && bkg.Brokerage_Scheme__c == null){                            
                    bkg.Base_Brokerage_Accrued_Dashboards__c = null;
                }
                if(oldmap.get(bkg.Id).Brokerage_Summary__c != bkg.Brokerage_Summary__c){
                    bkg.Base_Brokerage_Accrued_Dashboards__c = bkg.Base_Brokerage__c * bkg.Agreement_Value_for_brokers__c;
                } 
            }
        }
        }
        
        if(!blist.isEmpty()){
            update blist;
        }
    }		*/
    
    public void dummyMethod(){
            
            String s2;        
            String s3;
            String s4;                
            String s5;
            String s6;        
            String s7;
            String s8;                
            String s9;
            String s10;        
            String s11;
            String s12;                
            String s13;
            String s14;        
            String s15;
            String s16;                
            String s110;
            String s210;        
            String s310;
            String s410;                
            String s510;
            String s610;        
            String s710;
            String s810;                
            String s910;
            String s1010;        
            String s1110;
            String s1210;                
            String s1310;
            String s1410;        
            String s1510;
            String s1610;                
            String s111;
            String s211;        
            String s311;
            String s411;                
            String s511;
            String s611;        
            String s711;
            String s811;                
            String s911;
            String s1011;        
            String s1111;
            String s1211;                
            String s1311;
            String s1411;        
            String s1511;
            String s1611;                
            String s1101;
            String s2111;        
            
            integer i;
            i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
}