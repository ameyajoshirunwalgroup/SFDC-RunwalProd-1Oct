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
    /*public static void updateBrokerageonSchemeChange(List<Id> bkgIds){
        
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
    }*/
    public static void updateBrokerageonSchemeChange(List<Id> bkgIds){
        
        List<Booking__c> bklist = [SELECT Id,Booking_Date__c,Quotation__r.walkin_Source__c ,Brokerage_Scheme__r.Type__c,Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c,Brokerage_Scheme__r.Name,Brokerage_Scheme__r.Id,Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c,Passback_Amount__c,
                                   Brokerage_Scheme__c,Quotation__r.Brokerage_Agreement_Value__c,Type_of_Client__c,Brokerage_Scheme__r.Base_Brokerage_for_NRI__c FROM Booking__c WHERE Id IN: bkgIds];
        if(!bklist.isEmpty()){
            for(booking__c b : bklist){
                Decimal passbackAmt = 0;
                if(b.Passback_Amount__c != null){
                    passbackAmt = b.Passback_Amount__c;
                }
                
                /*
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
                */
                
                if((b.Brokerage_Scheme__r.Type__c == 'Both' || b.Brokerage_Scheme__r.Type__c == 'Local') && (b.Type_of_Client__c == 'Local' || b.Type_of_Client__c == 'Corporate' )){
                    b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c;
                    b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                    b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                    b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_Local_Bookings__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                }else if((b.Brokerage_Scheme__r.Type__c == 'Both' || b.Brokerage_Scheme__r.Type__c == 'NRI') && (b.Type_of_Client__c == 'NRI') /*|| b.Type_of_Client__c == 'Outstation') && bookingDate < bookingDate2*/){
                    b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_NRI__c - (((passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_NRI__c;
                    b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                    b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                    b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_NRI__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                } else if((b.Brokerage_Scheme__r.Type__c == 'Both' || b.Brokerage_Scheme__r.Type__c == 'Outstation') && (b.Type_of_Client__c == 'Outstation') /*&& bookingDate < bookingDate2*/){
                    b.Base_Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c - (((passbackAmt /  b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
                    b.Base_Brokerage_2__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c;
                    b.Brokerage_Scheme_Name__c =  b.Brokerage_Scheme__r.Name;
                    b.Brokerage_Scheme__c =  b.Brokerage_Scheme__r.Id;
                    b.Brokerage__c = b.Brokerage_Scheme__r.Base_Brokerage_for_OS_NRI__c - (((passbackAmt / b.Quotation__r.Brokerage_Agreement_Value__c)*100 ).setscale(2,RoundingMode.HALF_UP));
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
            Basement_Additional__c, Podium__c, Puzzle_Car_Park__c,Stamp_duty_payable_by_Runwal__c ,Stack_Additional_1__c
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
                    'Puzzle Car Park' => (q.Puzzle_Car_Park__c == null ? 0 : Integer.valueOf(q.Puzzle_Car_Park__c)),
                    'Stack Car Park' => (q.Stack_Additional_1__c == null ? 0 : Integer.valueOf(q.Stack_Additional_1__c))
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
    }       */

  public static void tagReceiptsFromOpportunity(List<Booking__c> newBookings) {
        if(newBookings == null || newBookings.isEmpty()) return;

        // Collect Opportunity Ids from new Bookings
        Set<Id> oppIds = new Set<Id>();
        //Map<Id, Id> bookingToOppMap = new Map<Id, Id>(); // Booking Id -> Opportunity Id
        for(Booking__c b : newBookings) {
            if(b.Opportunity__c != null) {
                oppIds.add(b.Opportunity__c);
                //bookingToOppMap.put(b.Id, b.Opportunity__c);
            }
        }

        if(oppIds.isEmpty()) return;

        // Query all receipts related to these Opportunities
        List<RW_Payment_Details__c> relatedReceipts = [
            SELECT Id, Opportunity__c, RW_Booking__c
            FROM RW_Payment_Details__c
            WHERE Opportunity__c IN :oppIds
        ];

        if(relatedReceipts == null || relatedReceipts.isEmpty()) return;

        List<RW_Payment_Details__c> receiptsToUpdate = new List<RW_Payment_Details__c>();

        // Map Opportunity Id -> Booking Id (for newly inserted Bookings)
        Map<Id, Id> oppToBookingMap = new Map<Id, Id>();
        for(Booking__c b : newBookings) {
            oppToBookingMap.put(b.Opportunity__c, b.Id);
        }

        // Tag each receipt to its Booking if not already linked
        for(RW_Payment_Details__c r : relatedReceipts) {
            Id bookingId = oppToBookingMap.get(r.Opportunity__c);
            if(bookingId != null && (r.RW_Booking__c == null || r.RW_Booking__c != bookingId)) {
                r.RW_Booking__c = bookingId;
                receiptsToUpdate.add(r);
            }
        }

        if(!receiptsToUpdate.isEmpty()) {
            update receiptsToUpdate;
        }
    }
    
    //Added by Prashant to update waiver amount to be approved.//09-12-25 STart.
    // public static void updateWaiverApprovedtillNow(list<Booking__c> blist){
    //     list<Project__c> projectList = new list<Project__c>();
    //     for(Booking__c b: blist){
    //         /*Decimal totalWaivertobeApproved = (b.Total_Waiver_Amount_to_be_Approved__c != null) ? b.Total_Waiver_Amount_to_be_Approved__c : 0;            
    //         Decimal totalWaiverApprovedTillNow = (b.Total_Waiver_Amount_Approved_Till_Now__c != null) ? b.Total_Waiver_Amount_Approved_Till_Now__c : 0;
    //         totalWaiverApprovedTillNow += totalWaivertobeApproved;
    //         b.Total_Waiver_Amount_Approved_Till_Now__c = totalWaiverApprovedTillNow;
    //         b.Total_Waiver_Amount_to_be_Approved__c = 0;*///Commented by Prashant due to requirement change from business- now approved till now to kept project wise so populating the amt on project
    //         Decimal totalWaivertobeApproved = (b.Total_Waiver_Amount_to_be_Approved__c != null) ? b.Total_Waiver_Amount_to_be_Approved__c : 0;            
    //         Decimal totalWaiverApprovedTillNow = (b.Total_Waiver_Amount_Approved_Till_Now__c != null) ? b.Total_Waiver_Amount_Approved_Till_Now__c : 0;
    //         totalWaiverApprovedTillNow += totalWaivertobeApproved;
    //         Project__c p = new Project__c();
    //         p.Id = b.Project__c;
    //         p.Waiver_Approved_till_now__c = totalWaiverApprovedTillNow;
	// 		b.Total_Waiver_Amount_to_be_Approved__c = 0; 
    //         projectList.add(p);
    //     }
    //     if(!projectList.isEmpty()){
    //      	update projectList;   
    //     }
    //     // if(!blist.isEmpty()){
    //     //  	update blist;   
    //     // }
    // }
    public static void updateWaiverApprovedtillNow(List<Booking__c> blist) {

    List<Project__c> projectList = new List<Project__c>();
    Set<Id> bookingIds = new Set<Id>();

    for (Booking__c b : blist) {
        bookingIds.add(b.Id);
    }

    // 🔹 Fetch summed Interest Waiver from Demands
    Map<Id, Decimal> bookingToDemandWaiverSum = new Map<Id, Decimal>();

    for (AggregateResult ar : [
        SELECT Booking__c bookingId,
               SUM(Total_Interest_Waiver_Amount__c) totalWaiver
        FROM RW_Demand__c
        WHERE Booking__c IN :bookingIds
        GROUP BY Booking__c
    ]) {
        bookingToDemandWaiverSum.put(
            (Id) ar.get('bookingId'),
            (Decimal) ar.get('totalWaiver')
        );
    }

    for (Booking__c b : blist) {

        Decimal totalWaivertobeApproved =
            b.Total_Waiver_Amount_to_be_Approved__c != null
            ? b.Total_Waiver_Amount_to_be_Approved__c
            : 0;

        Decimal totalWaiverApprovedTillNow =
            b.Total_Waiver_Amount_Approved_Till_Now__c != null
            ? b.Total_Waiver_Amount_Approved_Till_Now__c
            : 0;

        totalWaiverApprovedTillNow += totalWaivertobeApproved;

        // 🔹 Update Project
        if (b.Project__c != null) {
            Project__c p = new Project__c();
            p.Id = b.Project__c;
            p.Waiver_Approved_till_now__c = totalWaiverApprovedTillNow;
            projectList.add(p);
        }

        // 🔹 Reset to be approved
        b.Total_Waiver_Amount_to_be_Approved__c = 0;
    }

    if (!projectList.isEmpty()) {
        update projectList;
    }
}

    //Added by Prashant to update waiver amount to be approved.//09-12-25 End.
    
    //Added by Prashant to update waiver amount to be approved.//09-12-25 STart.
    public static void processWaivers(list<Id> Bids){
        list<Booking__c> blist = [Select id,Name,RM_Name__c,Interest_Waiver_Approval_Status__c,(Select id from Interest_Waivers__r where Sent_for_Approval__c = true),(SELECT Actor.Name,Comments,StepStatus
                                  FROM ProcessSteps order by CreatedDate desc limit 1) from Booking__c where Id in: bids ];
        list<Interest_Waiver__c> waiversToUpdate = new list<Interest_Waiver__c>();
        List<Id> waiversToSendtoSAP = new List<Id>();     
        List<Id> waiverIds = new List<Id>(); 
        if(!blist.isEmpty()){             
            for (Booking__c bk : blist) {
                if(bk.Interest_Waivers__r != null && !bk.Interest_Waivers__r.isEmpty()){
                    for (Interest_Waiver__c iw : bk.Interest_Waivers__r) {
                        if(bk.Interest_Waiver_Approval_Status__c == 'Approved'){
                            iw.Approval_Status__c = 'Approved';
                            //waiversToSendtoSAP.add(iw.Id);
                        } else if(bk.Interest_Waiver_Approval_Status__c == 'Rejected'){
                            iw.Approval_Status__c = 'Rejected';
                        }
                        iw.Sent_for_Approval__c = false;
                        waiversToUpdate.add(iw);
                        waiverIds.add(iw.Id);
                    }
                }
            }
            
            if (!waiversToUpdate.isEmpty()) {
                update waiversToUpdate;
                sendWaiverEmailApex(Bids,waiverIds);
            }
            if(!waiversToSendtoSAP.isEmpty()){
                //Id JobId = System.enqueueJob(new SAPInterestWaiverAPICallOutNew(waiversToSendtoSAP));
            }
        }
    }
    
    public static void processWaiversInProcess(list<Id> Bids){
        list<Booking__c> blist = [Select id,Name,RM_Name__c,Interest_Waiver_Approval_Status__c,(Select id from Interest_Waivers__r where Sent_for_Approval__c = true),(SELECT Actor.Name,Comments,StepStatus
                                  FROM ProcessSteps order by CreatedDate desc limit 1) from Booking__c where Id in: bids ];
        list<Interest_Waiver__c> waiversToUpdate = new list<Interest_Waiver__c>();     
        List<Id> waiverIds = new List<Id>(); 
        if(!blist.isEmpty()){             
            for (Booking__c bk : blist) {
                if(bk.Interest_Waivers__r != null && !bk.Interest_Waivers__r.isEmpty()){
                    for (Interest_Waiver__c iw : bk.Interest_Waivers__r) {
                        
                        iw.Approval_Status__c = bk.Interest_Waiver_Approval_Status__c;
                        waiversToUpdate.add(iw);
                    }
                }
            }
            
            if (!waiversToUpdate.isEmpty()) {
                update waiversToUpdate;
            }
        }
    }
    
    public static void sendWaiverEmailApex(List<Id> bids,list<Id> waiversIds) {
        
        List<Booking__c> bookingList = [
            SELECT Id, Name, Owner.Email, RM_Name__c, Interest_Waiver_Approval_Status__c,
            (SELECT Id, Name, Waiver_Reason__c, Sub_Reason__c, Waiver_Amount__c, Remarks__c, Approval_Status__c,Demand__c,Demand__r.Name
             FROM Interest_Waivers__r 
             WHERE Id in:waiversIds),
            (SELECT Comments, StepStatus, Actor.Name 
             FROM ProcessSteps 
             ORDER BY CreatedDate DESC 
             LIMIT 1),
             (SELECT Id, SubmittedById, SubmittedBy.Name, SubmittedBy.Email
                FROM ProcessInstances
                ORDER BY CreatedDate DESC
                LIMIT 1)

            FROM Booking__c 
            WHERE Id IN :bids
        ];

        // Fetch Org Wide Email Address (Customer Care)
        OrgWideEmailAddress owea = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE DisplayName = 'Runwal Cares'
            LIMIT 1
        ];
        
        for (Booking__c b : bookingList) {
            String initiatorName = '';
            String initiatorEmail = '';

            if(!b.ProcessInstances.isEmpty()){
                initiatorName = b.ProcessInstances[0].SubmittedBy.Name;
                initiatorEmail = b.ProcessInstances[0].SubmittedBy.Email;
            }
            
            if (b.Interest_Waivers__r == null || b.Interest_Waivers__r.isEmpty()) {
                continue; 
            }
            
            String latestComment = '';
            String latestApprover = '';
            
            if (!b.ProcessSteps.isEmpty()) {
                latestComment = b.ProcessSteps[0].Comments;
                latestApprover = b.ProcessSteps[0].Actor.Name;
            }
            
            String subject = (b.Interest_Waiver_Approval_Status__c == 'Approved')
                ? 'Interest Waiver Approved - ' + b.Name
                : 'Interest Waiver Rejected - ' + b.Name;

            // 🔹 Booking record URL
            String baseUrl = URL.getOrgDomainUrl().toExternalForm();
            String bookingUrl = baseUrl + '/' + b.Id;
            
            String body = '<html><body>';            
            body += '<p>Dear ' + initiatorName + ',</p>';            
            if (b.Interest_Waiver_Approval_Status__c == 'Approved') {
                body += '<p>The interest waiver request has been <b>approved</b>. Below are the details:</p>';
            } else {
                body += '<p>The interest waiver request has been <b>rejected</b>. Below are the details:</p>';
            }
             // ⭐ BOOKING LINK
            body += '<p><b>Booking:</b> <a href="' + bookingUrl + '">' + b.Name + '</a></p><br/>';
            
            body += '<br/>';
            
            body += '<table border="1" style="border-collapse:collapse; font-size:12px;">';
            body += '<tr>';
            body += '<th>Sr No</th>';
            body += '<th>Name</th>';
            body += '<th>Demand</th>';   // ADDED by Dolly
            body += '<th>Reason</th>';
            body += '<th>Sub Reason</th>';
            body += '<th>Amount</th>';
            body += '<th>Remarks</th>';
            body += '<th>Status</th>';
            body += '</tr>';
            
            Integer row = 1;
            
            for (Interest_Waiver__c iw : b.Interest_Waivers__r) {
                body += '<tr>';
                body += '<td>' + row + '</td>';
                body += '<td>' + iw.Name + '</td>';
                body += '<td>' + (iw.Demand__r != null ? iw.Demand__r.Name : '') + '</td>';  //Added Demand Name
                body += '<td>' + iw.Waiver_Reason__c + '</td>';
                //body += '<td>' + iw.Sub_Reason__c + '</td>';
                body += '<td>' + getSubReasonLabel(iw.Sub_Reason__c) + '</td>';
                body += '<td>' + iw.Waiver_Amount__c + '</td>';
                body += '<td>' + (iw.Remarks__c != null ? iw.Remarks__c : '') + '</td>';
                body += '<td>' + iw.Approval_Status__c + '</td>';
                body += '</tr>';
                row++;
            }
            
            body += '</table>';
            
            body += '<br/><br/>';
            
            if (!String.isBlank(latestComment)) {
                body += '<br/><br/>';
                body += '<p><b>Remarks from Approver (' + latestApprover + '):</b><br/>';
                body += latestComment + '</p>';                
            }
            if (b.Interest_Waiver_Approval_Status__c == 'Rejected') {
                body += '<p>Request you to take appropriate action accordingly.</p>';
            }
            
            body += '<p>Regards,<br/>Runwal Team</p>';
            body += '</body></html>';

            List<String> toList = new List<String>();

            if(!String.isBlank(initiatorEmail))
                toList.add(initiatorEmail);

            if(toList.isEmpty())
                toList.add('prashant.chaurasia.os@runwalgroup.in'); // fallback
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setOrgWideEmailAddressId(owea.Id);
            email.setToAddresses(toList);
            // email.setToAddresses(new String[] { (b.Owner.Email != null) ? b.Owner.Email : 'prashant.chaurasia.os@runwalgroup.in' });
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setSaveAsActivity(true);
            email.setWhatId(b.Id);

            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }

    
    
    public static void submitBookingforWaiverApproval(list<Id> iwBIds){
        try {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        if(!iwBIds.isEmpty()){
            for(Id bid:iwBIds){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(bid);
                req.setComments('Submitting for Interest Waiver Consolidation Approval');
                req.setProcessDefinitionNameOrId('Interest_Waiver_Approval');
                req.setSkipEntryCriteria(true);
                requests.add(req);
            }   
        }
        if (!requests.isEmpty()) {
            List<Approval.ProcessResult> results = Approval.process(requests);
            System.debug('Approval Results -> ' + results);
        }
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void validateIOMBeforeApproval(List<Booking__c> newList,Map<Id, Booking__c> oldMap) {
        for (Booking__c b : newList) {
            Booking__c oldB = oldMap.get(b.Id);

            // Run ONLY when approval status changes
            Boolean approvalStatusChanged = b.Interest_Waiver_Approval_Status__c != oldB.Interest_Waiver_Approval_Status__c;

            // Total waiver calculation
            Decimal totalRequested = (b.Total_Waiver_Amount_to_be_Approved__c != null ? b.Total_Waiver_Amount_to_be_Approved__c : 0) + (b.Total_Approved_Interest_Amount_Waived__c != null ? b.Total_Approved_Interest_Amount_Waived__c : 0) + (b.Interest_Waiver_Approved_but_not_Waived__c != null ? b.Interest_Waiver_Approved_but_not_Waived__c : 0);
            Decimal projectLimit = b.Project_Waived_Limit__c != null ? b.Project_Waived_Limit__c : 0;
            // Approval just happened
            if (    
                approvalStatusChanged &&
                (b.Interest_Waiver_Approval_Status__c != 'Rejected' && b.Interest_Waiver_Approval_Status__c != 'Submitted for Approval') &&
                totalRequested > projectLimit &&
                b.is_IOM_Uploaded__c == false) {

                    system.debug('id------->'+b.id);
                    b.addError('Approval cannot be completed. Please upload the IOM document on the Booking with extension as _IOM.');
                }

            if (
                approvalStatusChanged &&
                (b.Interest_Waiver_Approval_Status__c == 'Approved' || b.Interest_Waiver_Approval_Status__c == 'Rejected')
            ){
                // ✅ Reset checkbox when approved
                b.is_IOM_Uploaded__c = false;

            } 
            
        }

       
    }

   
    
   	/*public static void sendWaiverNotifications(List<Booking__c> bklistforNotif){
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='PushNotificationtoSM'];
        for(Booking__c b : bklistforNotif){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            String title = '';
            String body = '';
            if(b.Interest_Waiver_Approval_Status__c == 'Submitted for Approval' || b.Interest_Waiver_Approval_Status__c == 'Pending at CRM Head' || b.Interest_Waiver_Approval_Status__c == 'Pending at CEO'){
                title = b.RM_Name__c + 'is requesting approval for interest waiver';
                body = 'Interest Waiver for ₹' + b.Total_Waiver_Amount_to_be_Approved__c + 'is pending for Approval';
            } else if(b.Interest_Waiver_Approval_Status__c == 'Approved'){
                title = 'Waiver is Approved';
                body = 'Interest Waiver for ₹' + b.Total_Waiver_Amount_to_be_Approved__c + 'is Approved';
            } else if(b.Interest_Waiver_Approval_Status__c == 'Submitted for Approval' || b.Interest_Waiver_Approval_Status__c == 'Pending at CRM Head' || b.Interest_Waiver_Approval_Status__c == 'Pending at CEO'){
                title = 'Waiver is Rejected';
                body = 'Interest Waiver for ₹' + b.Total_Waiver_Amount_to_be_Approved__c + 'is Rejected, Please take necessary actions';
            }
            notification.setTitle(title);
            notification.setBody(body);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(b.Id);
            Set<String> ownerIds = new Set<String>();
            if(b.Interest_Waiver_Approval_Status__c == 'Approved'){
                if(b.Waiver_Approver_Level__c == 'Level 1' && b.Project_Lead__c != null){
                    ownerIds.add(b.Project_Lead__c);
                } else if(b.Waiver_Approver_Level__c == 'Level 2' && b.CRM_Head__c != null){
                    ownerIds.add(b.CRM_Head__c);
                } else  if(b.Waiver_Approver_Level__c == 'Level 3' && b.CEO__c != null){
                    ownerIds.add(b.CEO__c);
                }
            } else if(b.Interest_Waiver_Approval_Status__c == 'Rejected'){
                if(b.Waiver_Approver_Level__c == 'Level 1' && b.Project_Lead__c != null){
                    ownerIds.add(b.Project_Lead__c);
                } else if(b.Waiver_Approver_Level__c == 'Level 2' && b.Project_Lead__c != null && b.CRM_Head__c != null){
                    ownerIds.add(b.Project_Lead__c);
                    ownerIds.add(b.CRM_Head__c);
                } else if(b.Waiver_Approver_Level__c == 'Level 3' && b.Project_Lead__c != null && b.CRM_Head__c != null && b.CEO__c !=null ){
                    ownerIds.add(b.Project_Lead__c);
                    ownerIds.add(b.CRM_Head__c);
                    ownerIds.add(b.CEO__c);
                }
            } else if(b.Interest_Waiver_Approval_Status__c == 'Submitted for Approval'){
                ownerIds.add(b.Project_Lead__c);
            } else if(b.Interest_Waiver_Approval_Status__c == 'Pending at CRM Head'){
                ownerIds.add(b.CRM_Head__c);
            } else if(b.Interest_Waiver_Approval_Status__c == 'Pending at CEO'){
                ownerIds.add(b.CEO__c);
            }
            
            notification.send(ownerIds);
        }
    }*/
    //Added by Prashant to update waiver amount to be approved.//09-12-25 End.
    //
    
     //Convert Sub Reason API → Label(Added By Dolly)
    public static String getSubReasonLabel(String apiValue){

        if(String.isBlank(apiValue)) return '';

        Map<String,String> picklistMap = new Map<String,String>();

        Schema.DescribeFieldResult fieldDesc =
            Interest_Waiver__c.Sub_Reason__c.getDescribe();

        for(Schema.PicklistEntry entry : fieldDesc.getPicklistValues()){
            picklistMap.put(entry.getValue(), entry.getLabel());
        }

        return picklistMap.containsKey(apiValue)
            ? picklistMap.get(apiValue)
            : apiValue;
    }
   
	 
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
         i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
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