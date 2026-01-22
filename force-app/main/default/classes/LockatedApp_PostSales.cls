@RestResource(urlMapping='/customerDetails/*')
global without sharing class LockatedApp_PostSales {
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResult = new Map<String, Object>();
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        if(String.isBlank(bkgId) || bkgId == 'customerDetails'){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid Booking Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                List<Booking__c> bk = [SELECT Id, Opportunity__r.AccountId FROM Booking__c WHERE Id =: bkgId];
                String accId = ((bk.size() > 0 && bk[0].Opportunity__c != null))? bk[0].Opportunity__r.AccountId : null;
                if(accId != null){
                    
                    
                    List<Booking__c> bkgs = [SELECT Id,Name,RW_Registration_Date__c,Booking_Date__c,RW_Key_handover_date__c,No_of_Parking__c,Parking_Type__c,NCF_Status__c,
                                             Unit_No__r.Type__c,Unit_No__r.Carpet_Area__c,Unit_No__r.Utility_Area__c,Project__r.Name,Project__r.RERA_Certificate_No__c,Project__r.RW_SAP_Company_Code__c,
                                             Unit_No__r.Name,Unit_No__r.RW_Param3__c,Unit_No__r.RW_Param2__c,Allotment_Premium__c,RW_Total_Demand_Raised__c,Unit_No__r.Deck_Area__c,
                                             RW_Total_Receipt_Amount_Received__c,FBL5N__c,RW_Registration_Status__c,RW_SDR_Status__c,Stamp_duty_Paid__c,Unit_No__r.TowerName__r.RERA_Certificate_No__c,
                                             Unit_No__r.Relationship_Manager__r.did_number_from_user__c,RW_X9_99_Received__c,Unit_No__r.RW_Param4__c,Unit_No__r.Total_RERA_Carpet_Area__c,
                                             RW_Total_SDR_Amount_Payable__c,RW_RM_Email__c,RM_Name__c,Unit_No__r.Relationship_Manager__r.Contact_Number__c,Unit_No__r.Relationship_Manager__r.User__r.MobilePhone,
                                             Sales_Managers__c,Owner.Name,Status__c,Date_of_Occupation_Certificate__c,Sales_Manager__r.Name,Unit_Type__c,Stamp_duty_payable_by_Runwal__c,
                                             Opportunity__r.Account.Country_Code__c,Opportunity__r.Account.Mobile_No__c,Opportunity__r.Account.PersonEmail,Opportunity__r.Account.RW_Email__c,Opportunity__r.Account.LastName,
                                             Opportunity__r.Account.FirstName,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.Account.Birth_Date__c,Unit_No__r.TowerName__c,
                                             Opportunity__r.Account.Gender__c,Project__r.WhatsApp_Bot_Project_Image_File_Id__c,RW_Total_TDS_Outstanding__c,Quotation__r.PaymentPlan__r.Name,
                                             (SELECT Id,DOB__c,Permanent_Address__c,Address_Proof_Number__c,PancardNo__c,Gender__c,Mobile_Number__c,GSTIN_Number__c,Occupation__c,
                                              Email_Address__c,Last_Name__c,First_Name__c,Applicant_Number__c,Correspondence_Address__c,Organization_Name__c FROM ApplicantDetails__r),
                                             (SELECT Id,Name,RW_Fiscal_Year__c,RW_Company_Code__c,RW_Accounting_Document_Number__c,RW_Payment_Amount__c,RW_Usage_Description__c,RW_Bank_Name__c,
                                              RW_Payment_Date__c,RW_Document_Type__c FROM Payment_Details__r WHERE Status__c != 'Reversed' ORDER By CreatedDate DESC),Quotation__r.Registration_Charges__c,Quotation__r.Plan_Type__c,
                                             Quotation__r.Other_Charges_Amount_1__c,Quotation__r.Other_Charges_Desc_1__c,Quotation__r.Other_Charges_Category_1__c,
                                             Quotation__r.Other_Charges_Amount_2__c,Quotation__r.Other_Charges_Desc_2__c,Quotation__r.Other_Charges_Category_2__c,
                                             Quotation__r.Other_Charges_Amount_3__c,Quotation__r.Other_Charges_Desc_3__c,Quotation__r.Other_Charges_Category_3__c,
                                             Quotation__r.Other_Charges_Amount_4__c,Quotation__r.Other_Charges_Desc_4__c,Quotation__r.Other_Charges_Category_4__c,
                                             Quotation__r.Other_Charges_Amount_5__c,Quotation__r.Other_Charges_Desc_5__c,Quotation__r.Other_Charges_Category_5__c,
                                             Quotation__r.Other_Charges_Amount_6__c,Quotation__r.Other_Charges_Desc_6__c,Quotation__r.Other_Charges_Category_6__c,
                                             Quotation__r.Other_Charges_Amount_7__c,Quotation__r.Other_Charges_Desc_7__c,Quotation__r.Other_Charges_Category_7__c,
                                             Quotation__r.Other_Charges_Amount_8__c,Quotation__r.Other_Charges_Desc_8__c,Quotation__r.Other_Charges_Category_8__c,
                                             Quotation__r.Other_Charges_Amount_9__c,Quotation__r.Other_Charges_Desc_9__c,Quotation__r.Other_Charges_Category_9__c,
                                             Quotation__r.Other_Charges_Amount_10__c,Quotation__r.Other_Charges_Desc_10__c,Quotation__r.Other_Charges_Category_10__c,
                                             Quotation__r.Other_Charges_Amount_11__c,Quotation__r.Other_Charges_Desc_11__c,Quotation__r.Other_Charges_Category_11__c,
                                             Quotation__r.Other_Charges_Amount_12__c,Quotation__r.Other_Charges_Desc_12__c,Quotation__r.Other_Charges_Category_12__c,
                                             Quotation__r.Other_Charges_Amount_13__c,Quotation__r.Other_Charges_Desc_13__c,Quotation__r.Other_Charges_Category_13__c,
                                             Quotation__r.Other_Charges_Amount_14__c,Quotation__r.Other_Charges_Desc_14__c,Quotation__r.Other_Charges_Category_14__c,
                                             Quotation__r.Other_Charges_Amount_15__c,Quotation__r.Other_Charges_Desc_15__c,Quotation__r.Other_Charges_Category_15__c,
                                             Quotation__r.Other_Charges_Amount_16__c,Quotation__r.Other_Charges_Desc_16__c,Quotation__r.Other_Charges_Category_16__c,
                                             (SELECT Id,Name,RW_Billing_Document_Number__c,Demand_Amount__c,Total_Demand_Paid__c,Remaining_Amount__c,CreatedDate,
                                              RW_Total_GST_Amount__c,RW_Total_Demand_Amount__c,RW_Demand_Status__c,Demand_Date__c,Due_Date__c,RW_Demand_Milestone__c FROM Demands__r WHERE RW_Demand_Status__c != 'Revoke' ORDER By Due_Date__c DESC)
                                             FROM Booking__c WHERE Opportunity__r.AccountId =: accId AND Status__c = 'Booking Confirmed'];//Id =: bkgId];
                    
                    LockatedApp_PostSalesWrapper det = new LockatedApp_PostSalesWrapper();
                    
                    if(bkgs.size() > 0){
                        Set<Id> bkIds = new Set<Id>();
                        Set<Id> towerIds = new Set<Id>();
                        for(Booking__c bkg : bkgs){
                            bkIds.add(bkg.Id);
                            towerIds.add(bkg.Unit_No__r.TowerName__c);
                        }
                        List<Loan__c> loans = [SELECT Id,HL_RM__c,HL_RM__r.User__r.Name,HL_RM__r.User__r.DID__c,RW_Booking__c,RW_Loan_Record_Status__c,RW_Sanction_Status__c FROM Loan__c WHERE RW_Booking__c =: bkIds];
                        Map<String,Loan__c> bkgIdVsLoanMap = new Map<String, Loan__c>();
                        for(Loan__c ln : loans){
                            bkgIdVsLoanMap.put(ln.RW_Booking__c, ln);
                        }
                        
                        List<Car_Parking_Charge__c> parkings = [SELECT Id,Parking__c,Booking__c FROM Car_Parking_Charge__c WHERE Booking__c =: bkIds];
                        Map<String,List<String>> bkgIdVsParkingsMap = new Map<String, List<String>>();
                        for(Car_Parking_Charge__c park : parkings){
                            if(bkgIdVsParkingsMap.get(park.Booking__c) != null){
                                bkgIdVsParkingsMap.get(park.Booking__c).add(park.Parking__c);
                            }else{
                                bkgIdVsParkingsMap.put(park.Booking__c, new List<String>{park.Parking__c}); 
                            }
                        }
                        
                        List<Tower__c> tower = [SELECT Id, Legal_Entity__c FROM Tower__c WHERE Id =: towerIds];
                        
                        
                        System.debug('acc.Country_Code__c: ' +bkgs[0].Opportunity__r.Account.Country_Code__c);
                        LockatedApp_PostSalesWrapper.customer cust = new LockatedApp_PostSalesWrapper.customer();
                        det.customer = cust;
                        cust.country_code = (bkgs[0].Opportunity__r.Account.Country_Code__c != null)? bkgs[0].Opportunity__r.Account.Country_Code__c : '';
                        //cust.mobile_number = bkgs[0].Opportunity__r.Account.Mobile_No__c;
                        //cust.email = (bkgs[0].Opportunity__r.Account.PersonEmail != null)? bkgs[0].Opportunity__r.Account.PersonEmail : bkgs[0].Opportunity__r.Account.RW_Email__c;
                        //cust.lastname = bkgs[0].Opportunity__r.Account.LastName;
                        //cust.firstname = bkgs[0].Opportunity__r.Account.FirstName;
                        cust.sap_cust_no = bkgs[0].Opportunity__r.SAP_Customer_Number__c;
                        cust.Customer_Sf_Id = bkgs[0].Opportunity__r.Account.Id;
                        //cust.birth_date = (bkgs[0].Opportunity__r.Account.Birth_Date__c != null)? String.valueOf(bkgs[0].Opportunity__r.Account.Birth_Date__c) : null;
                        //cust.gender = bkgs[0].Opportunity__r.Account.Gender__c;
                        for(Applicant_Details__c app : bkgs[0].ApplicantDetails__r){
                            if(app.Applicant_Number__c == 'Primary Applicant'){
                                cust.pan_card = app.PancardNo__c;
                                cust.aadhar = app.Address_Proof_Number__c;
                                cust.gst_number = app.GSTIN_Number__c;
                                cust.company_name = app.Organization_Name__c;
                                cust.occupation = app.Occupation__c;
                                cust.permanent_address = app.Permanent_Address__c;
                                cust.correspondence_address = app.Correspondence_Address__c;
                                cust.gender = app.Gender__c;
                                cust.birth_date = (app.DOB__c != null)? String.valueOf(app.DOB__c) : null;
                                cust.lastname = app.Last_Name__c;
                        		cust.firstname = app.First_Name__c;
                                cust.email = app.Email_Address__c;
                                cust.mobile_number = app.Mobile_Number__c;
                            }
                        }
                        
                        Set<Id> bkgIds = new Set<Id>();
                        //if(bkgs.size() > 0){
                        List<LockatedApp_PostSalesWrapper.booking_details> bkgDetails = new List<LockatedApp_PostSalesWrapper.booking_details>();
                        
                        for(Booking__c bkg : bkgs){
                            LockatedApp_PostSalesWrapper.booking_details bkgDet = new LockatedApp_PostSalesWrapper.booking_details();
                            bkgDet.bookingId = bkg.Id;
                            bkgDet.is_primary = '1';
                            bkgDet.registration_date = (bkg.RW_Registration_Date__c != null)? String.valueOf(bkg.RW_Registration_Date__c) : null;
                            bkgDet.booking_date = (bkg.Booking_Date__c != null)? String.valueOf(bkg.Booking_Date__c) : null;
                            bkgDet.handover_date = (bkg.RW_Key_handover_date__c != null)? String.valueOf(bkg.RW_Key_handover_date__c) : null;
                            //bkgDet.garden_facing = ''; // Need confirm this mapping - Not required
                            bkgDet.no_of_parkings = (bkg.No_of_Parking__c != null)? Integer.valueOf(bkg.No_of_Parking__c) : null;
                            bkgDet.type_of_parking = bkg.Parking_Type__c;
                            //bkgDet.type_of_parking = bkgIdVsParkingsMap.get(bkg.Id);
                            bkgDet.configuration_type = bkg.Unit_No__r.Type__c;
                            bkgDet.carpet_area = (bkg.Unit_No__r.Carpet_Area__c != null)? bkg.Unit_No__r.Carpet_Area__c : null;
                            bkgDet.utility_area = (bkg.Unit_No__r.Utility_Area__c != null)? bkg.Unit_No__r.Utility_Area__c : null;
                            bkgDet.balcony_area = bkg.Unit_No__r.Deck_Area__c; 
                            bkgDet.rera_carpet_area = (bkg.Unit_No__r.Total_RERA_Carpet_Area__c != null)? bkg.Unit_No__r.Total_RERA_Carpet_Area__c : null;
                            bkgDet.project_name = bkg.Project__r.Name;
                            bkgDet.rera_project_name = bkg.Project__r.Name; 
                            bkgDet.company_code = bkg.Project__r.RW_SAP_Company_Code__c;
                            //bkgDet.rera_id = bkg.Project__r.RERA_Certificate_No__c; 
                            bkgDet.rera_id = bkg.Unit_No__r.TowerName__r.RERA_Certificate_No__c;
                            if(!String.isBlank(bkg.Project__r.WhatsApp_Bot_Project_Image_File_Id__c)){
                                List<ContentDistribution> distrList = [SELECT Id, Name, DistributionPublicUrl, ContentDocumentId FROM ContentDistribution 
                                                                       WHERE ContentDocumentId =: bkg.Project__r.WhatsApp_Bot_Project_Image_File_Id__c];
                                bkgDet.project_logo = (distrList.size() > 0)? distrList[0].DistributionPublicUrl : null; 
                            }
                            
                            //bkgDet.unit = bkg.Unit_No__r.Name;
                            bkgDet.unit = bkg.Unit_No__r.RW_Param4__c;
                            Map<String, String> valueToLabelMap = new Map<String, String>();
                            for (Schema.PicklistEntry ple : Booking__c.Unit_Type__c.getDescribe().getPicklistValues()) {
                                valueToLabelMap.put(ple.getValue(), ple.getLabel());
                            }
                            bkgDet.unit_type = valueToLabelMap.get(bkg.Unit_Type__c);
                            bkgDet.floor = bkg.Unit_No__r.RW_Param3__c;
                            bkgDet.tower = bkg.Unit_No__r.RW_Param2__c;
                            bkgDet.agreement_value = (bkg.Allotment_Premium__c != null)? bkg.Allotment_Premium__c : null; 
                            bkgDet.total_demanded = (bkg.RW_Total_Demand_Raised__c != null)? bkg.RW_Total_Demand_Raised__c : null; 
                            bkgDet.total_received = (bkg.RW_Total_Receipt_Amount_Received__c != null)? bkg.RW_Total_Receipt_Amount_Received__c : null; 
                            bkgDet.amount_due = (bkg.FBL5N__c != null)? String.valueOf(bkg.FBL5N__c) : null; 
                            bkgDet.registration_status = bkg.RW_Registration_Status__c;
                            bkgDet.registration_amount = String.valueOf(bkg.Quotation__r.Registration_Charges__c); 
                            bkgDet.stamp_duty_status = bkg.RW_SDR_Status__c;
                            bkgDet.stamp_duty_amount_received = (bkg.Stamp_duty_Paid__c != null)? String.valueOf(bkg.Stamp_duty_Paid__c) : null;
                            bkgDet.stamp_duty_amount = (bkg.RW_Total_SDR_Amount_Payable__c != null)? bkg.RW_Total_SDR_Amount_Payable__c : null;
                            bkgDet.rm_email = bkg.RW_RM_Email__c;
                            bkgDet.rm_mobile = bkg.Unit_No__r.Relationship_Manager__r.User__r.MobilePhone;
                            bkgDet.ivr_number = bkg.Unit_No__r.Relationship_Manager__r.did_number_from_user__c;
                            bkgDet.rm_name = bkg.RM_Name__c;
                            bkgDet.sales_manager_name = bkg.Sales_Manager__r.Name; 
                            bkgDet.ownership = bkg.Owner.Name;
                            bkgDet.status = bkg.Status__c;
                            //bkgDet.booking_amount_paid = '';
                            //bkgDet.payment_plan_type = bkg.Quotation__r.Plan_Type__c;
                            bkgDet.payment_plan_type = bkg.Quotation__r.PaymentPlan__r.Name;
                            //bkgDet.payment_due_on_before = '';
                            //bkgDet.total_outstanding_a = (bkg.FBL5N__c != null)? String.valueOf(bkg.FBL5N__c) : null; //Commented by Vinay 05-01-2026
                            bkgDet.total_outstanding_a = (bkg.FBL5N__c != null)? ((bkg.RW_Total_TDS_Outstanding__c != null)? String.valueOf(bkg.FBL5N__c - bkg.RW_Total_TDS_Outstanding__c) : String.valueOf(bkg.FBL5N__c)) : ((bkg.RW_Total_TDS_Outstanding__c != null)? String.valueOf(0 - bkg.RW_Total_TDS_Outstanding__c) : null); //Added by Vinay 05-01-2026
                            bkgDet.total_outstanding_b = (bkg.RW_Total_TDS_Outstanding__c != null)? String.valueOf(bkg.RW_Total_TDS_Outstanding__c) : null;
                            //bkgDet.ncf_url = 'https://runwal--fullcopy.sandbox.my.salesforce-sites.com/crmbotdoc?id='+ bkg.Id + '&doc=ncf';
                            //bkgDet.ncf_url = System.label.Site_Url_New + '/crmbotdoc?id='+ bkg.Id + '&doc=ncf';
                            if(!Test.isRunningTest()){
                                bkgDet.ncf_url = NameConfirmationController.generateAndSendForm(bkg.Id);
                            }
                            
                            //bkgDet.grand_total = String.valueOf(((bkg.FBL5N__c != null)? bkg.FBL5N__c : 0) + ((bkg.RW_Total_TDS_Outstanding__c != null)? bkg.RW_Total_TDS_Outstanding__c : 0));
                            bkgDet.grand_total = (bkg.Allotment_Premium__c != null)? bkg.Allotment_Premium__c : null; 
                            bkgDet.booking_number = bkg.Name;
                            if(bkgIdVsLoanMap.get(bkg.Id) != null && bkgIdVsLoanMap.get(bkg.Id).HL_RM__c != null && bkgIdVsLoanMap.get(bkg.Id).HL_RM__r.User__c != null){
                                bkgDet.homeLoanRmName = bkgIdVsLoanMap.get(bkg.Id).HL_RM__r.User__r.Name;
                                bkgDet.homeLoanRmContact = bkgIdVsLoanMap.get(bkg.Id).HL_RM__r.User__r.DID__c;
                            }
                            bkgDet.homeloan_brochure = System.label.Home_Loan_Brochure_for_Post_Sales_App;
                            bkgDet.stamp_duty_paid_by = (bkg.Stamp_duty_payable_by_Runwal__c > 0)? 'Runwal' : 'Customer';
                            List<LockatedApp_PostSalesWrapper.other_applicants> otherApplicants = new List<LockatedApp_PostSalesWrapper.other_applicants>();
                            for(Applicant_Details__c app : bkg.ApplicantDetails__r){
                                if(app.Applicant_Number__c != 'Primary Applicant'){
                                    LockatedApp_PostSalesWrapper.other_applicants otherApplicant = new LockatedApp_PostSalesWrapper.other_applicants();
                                    otherApplicant.date_of_birth = (app.DOB__c != null)? String.valueOf(app.DOB__c) : null;
                                    otherApplicant.address = app.Permanent_Address__c;
                                    otherApplicant.aadhar = app.Address_Proof_Number__c;
                                    otherApplicant.pan = app.PancardNo__c;
                                    otherApplicant.gender = app.Gender__c;
                                    otherApplicant.mobile = app.Mobile_Number__c;
                                    otherApplicant.email = app.Email_Address__c;
                                    otherApplicant.applicant_type = app.Applicant_Number__c;	
                                    otherApplicant.lastname = app.Last_Name__c;
                                    otherApplicant.firstname = app.First_Name__c;
                                    otherApplicant.gst_number = app.GSTIN_Number__c;
                                    otherApplicant.company_name = app.Organization_Name__c;
                                    otherApplicant.occupation = app.Occupation__c;
                                    otherApplicant.permanent_address = app.Permanent_Address__c;
                                    otherApplicant.correspondence_address = app.Correspondence_Address__c;
                                    otherApplicants.add(otherApplicant);
                                }
                            }
                            bkgDet.other_applicants = otherApplicants;
                            LockatedApp_PostSalesWrapper.stages stages = new LockatedApp_PostSalesWrapper.stages();
                            stages.booking_details_status = (bkg.Status__c == 'Booking Confirmed')? 'Completed' : 'Pending';
                            stages.ncf_status = (bkg.NCF_Status__c == 'Completed')? 'Completed' : 'Pending';
                            stages.registration_status = (bkg.RW_Registration_Status__c == 'Registration Completed')? 'Completed' : 'Pending';
                            stages.sales_deed_status = (bkg.Status__c == 'Cancellation Initiated' && bkg.Deed_of_Cancellation_Upload_Date__c != null && bkg.Cancellation_Deed_Uploaded__c == true)? 'Completed' : 'Pending';
                            stages.stamp_duty_status = (bkg.RW_SDR_Status__c == 'Received')? 'Completed' : 'Pending';
                            stages.oc_status = (bkg.Date_of_Occupation_Certificate__c !=  null)? 'Completed' : 'Pending';
                            stages.possession_status = (bkg.RW_Key_handover_date__c != null)? 'Completed' : 'Pending';
                            stages.payment_9_9_status = (bkg.RW_X9_99_Received__c)? 'Completed' : 'Pending';
                            //stages.sanction_status = (bkgIdVsLoanMap.get(bkg.Id)!= null && bkgIdVsLoanMap.get(bkg.Id).RW_Loan_Record_Status__c == 'Loan Sanctioned')? 'Completed' : 'Pending';
                            stages.sanction_status = (bkgIdVsLoanMap.get(bkg.Id)!= null && bkgIdVsLoanMap.get(bkg.Id).RW_Sanction_Status__c == 'Loan Sanctioned')? 'Completed' : 'Pending';
                            bkgDet.stages = stages;
                            
                            List<LockatedApp_PostSalesWrapper.payment_receipt> receipts = new List<LockatedApp_PostSalesWrapper.payment_receipt>();
                            List<LockatedApp_PostSalesWrapper.credit_note> creditNotes = new List<LockatedApp_PostSalesWrapper.credit_note>();
                            for(RW_Payment_Details__c rec : bkg.Payment_Details__r){
                                if(rec.RW_Document_Type__c == 'DF' || rec.RW_Document_Type__c == 'DZ' || rec.RW_Document_Type__c == 'DT'){
                                    LockatedApp_PostSalesWrapper.payment_receipt receipt = new LockatedApp_PostSalesWrapper.payment_receipt();
                                    receipt.fiscal_year = rec.RW_Fiscal_Year__c;
                                    receipt.sap_document_number = rec.RW_Accounting_Document_Number__c;
                                    receipt.company_code = rec.RW_Company_Code__c;
                                    receipt.sap_payment_advice_no = rec.RW_Accounting_Document_Number__c; 
                                    receipt.pr_amount = rec.RW_Payment_Amount__c;
                                    receipt.pr_date = (rec.RW_Payment_Date__c != null)? String.valueOf(rec.RW_Payment_Date__c) : null;
                                    receipt.pr_no = rec.Name;
                                    receipt.milestone_name = rec.RW_Usage_Description__c;
                                    receipt.bank_name = rec.RW_Bank_Name__c;
                                    receipt.payment_date = String.valueOf(rec.RW_Payment_Date__c);
                                    receipts.add(receipt);
                                }else if(rec.RW_Document_Type__c == 'DS'){
                                    LockatedApp_PostSalesWrapper.credit_note cn = new LockatedApp_PostSalesWrapper.credit_note();
                                    cn.fiscal_year = rec.RW_Fiscal_Year__c;
                                    cn.sap_document_number = rec.RW_Accounting_Document_Number__c;
                                    cn.company_code = rec.RW_Company_Code__c;
                                    cn.sap_payment_advice_no = rec.RW_Accounting_Document_Number__c; 
                                    cn.pr_amount = rec.RW_Payment_Amount__c;
                                    cn.pr_date = (rec.RW_Payment_Date__c != null)? String.valueOf(rec.RW_Payment_Date__c) : null;
                                    cn.pr_no = rec.Name;
                                    cn.milestone_name = rec.RW_Usage_Description__c;
                                    cn.bank_name = rec.RW_Bank_Name__c;
                                    cn.payment_date = String.valueOf(rec.RW_Payment_Date__c);
                                    creditNotes.add(cn);
                                }
                                
                                
                            }
                            bkgDet.payment_receipt = receipts;
                            bkgDet.credit_note = creditNotes;
                            
                            List<LockatedApp_PostSalesWrapper.other_charges> otherCharges = new List<LockatedApp_PostSalesWrapper.other_charges>();
                            if(bkg.Quotation__r.Other_Charges_Category_1__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_1__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_1__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_2__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_2__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_2__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_3__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_3__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_3__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_4__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_4__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_4__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_5__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_5__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_5__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_6__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_6__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_6__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_7__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_7__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_7__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_8__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_8__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_8__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_9__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_9__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_9__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_10__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_10__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_10__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_11__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_11__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_11__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_12__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_12__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_12__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_13__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_13__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_13__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_14__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_14__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_14__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_15__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_15__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_15__c;
                                otherCharges.add(otherCharge);
                            }
                            if(bkg.Quotation__r.Other_Charges_Category_16__c == 'Other Charges'){
                                LockatedApp_PostSalesWrapper.other_charges otherCharge = new LockatedApp_PostSalesWrapper.other_charges();
                                otherCharge.total_amount = bkg.Quotation__r.Other_Charges_Amount_16__c;
                                otherCharge.name = bkg.Quotation__r.Other_Charges_Desc_16__c;
                                otherCharges.add(otherCharge);
                            }
                            bkgDet.other_charges = otherCharges;
                            
                            List<LockatedApp_PostSalesWrapper.milestones> milestones = new List<LockatedApp_PostSalesWrapper.milestones>();
                            List<LockatedApp_PostSalesWrapper.paymentsDue> paymentsDues = new List<LockatedApp_PostSalesWrapper.paymentsDue>();
                            List<Date> dueDate = new List<Date>();
                            List<String> bookingAmountDemandIds = new List<String>();
                            
                            for(RW_Demand__c dem : bkg.Demands__r){
                                //dueDate.add(dem.Due_Date__c);
                                LockatedApp_PostSalesWrapper.milestones milestone = new LockatedApp_PostSalesWrapper.milestones();
                                milestone.sap_demand_no = dem.RW_Billing_Document_Number__c;
                                milestone.total_amount = dem.Demand_Amount__c;
                                milestone.received_amount = dem.Total_Demand_Paid__c;
                                milestone.outstanding_amount = dem.Remaining_Amount__c;
                                milestone.taxable_amount = dem.RW_Total_GST_Amount__c;
                                milestone.base_amount = dem.RW_Total_Demand_Amount__c;
                                milestone.status = dem.RW_Demand_Status__c;
                                milestone.triggered_date = (dem.Demand_Date__c != null)? String.valueOf(dem.Demand_Date__c) : null;
                                milestone.expected_date = (dem.Due_Date__c != null)? String.valueOf(dem.Due_Date__c) : null;
                                milestone.name = dem.RW_Demand_Milestone__c;
                                milestones.add(milestone);
                                
                                if(dem.RW_Demand_Status__c == 'Due'){
                                    dueDate.add(dem.Due_Date__c);
                                    LockatedApp_PostSalesWrapper.paymentsDue payDue = new LockatedApp_PostSalesWrapper.paymentsDue();
                                    payDue.milestone = dem.RW_Demand_Milestone__c;
                                    //payDue.milestone_date = String.valueOf(dem.CreatedDate);
                                    payDue.milestone_date = String.valueOf(dem.Due_Date__c);
                                    payDue.base_amount = String.valueOf(dem.RW_Total_Demand_Amount__c);
                                    payDue.billed_tds = '';
                                    payDue.tds_received = '';
                                    payDue.payment_received = String.valueOf(dem.Total_Demand_Paid__c);
                                    payDue.total_amount_billed = String.valueOf(dem.Demand_Amount__c);
                                    payDue.total_amount_received = String.valueOf(dem.Total_Demand_Paid__c);
                                    payDue.total_amount_due = String.valueOf(dem.Remaining_Amount__c);
                                    payDue.status = dem.RW_Demand_Status__c;
                                    payDue.tax_amount = String.valueOf(dem.RW_Total_GST_Amount__c);
                                    paymentsDues.add(payDue);
                                    
                                }
                                
                                if(dem.RW_Demand_Milestone__c == 'BOOKING AMOUNT'){
                                    bookingAmountDemandIds.add(dem.Id);
                                }
                            }
                            Date latest;
                            for (Date d : dueDate) {
                                if (latest == null || d > latest) {
                                    latest = d;
                                }
                            }
                            bkgDet.payment_due_on_before = String.valueOf(latest);
                            if(bookingAmountDemandIds.size() > 0){
                                List<RW_Demand_Item__c> demItems = [SELECT Id FROM RW_Demand_Item__c WHERE RW_Demand__c =: bookingAmountDemandIds];
                                List<RW_Payment_Detail_Item__c> bookingReceipts = [SELECT Id, CreatedDate,RW_Amount__c,RW_Payment_Details__r.RW_Payment_Date__c FROM RW_Payment_Detail_Item__c WHERE RW_Demand_Item__c =: demItems ORDER BY CreatedDate ASC];
                                Decimal amount = 0;
                                if(bookingReceipts.size() > 0){
                                    for(RW_Payment_Detail_Item__c pay : bookingReceipts){
                                        amount += pay.RW_Amount__c;
                                    }
                                    bkgDet.booking_amount_paid = String.valueOf(amount);
                                    //bkgDet.booking_amount_paid_date = String.valueOf(bookingReceipts[0].CreatedDate); 
                                    bkgDet.booking_amount_paid_date = String.valueOf(bookingReceipts[0].RW_Payment_Details__r.RW_Payment_Date__c); 
                                }
                            }
                            bkgDet.milestones = milestones;
                            bkgDet.paymentsDue = paymentsDues;
                            bkgDetails.add(bkgDet);
                        }
                        cust.booking_details = bkgDetails;
                        System.debug('bkgDetails: ' + bkgDetails);
                        //}
                        //det.case_status = getPicklistValues('Case', 'Status');
                        det.case_status = new List<String>{'Open', 'Case Closed'};
                        LockatedApp_PostSalesWrapper.PicklistWrapper customerLifeCycle =  new LockatedApp_PostSalesWrapper.PicklistWrapper();
                        PicklistWrapper pw = getDependentPicklist('Case', 'Customer_Lifecycle_Touchpoint__c','RW_Complaint_Type__c');
                        //customerLifeCycle.pickListMap = pw.pickListMap;
                        //customerLifeCycle.parentFieldLabel = pw.parentFieldLabel;
                        //customerLifeCycle.childFieldLabel = pw.childFieldLabel;
                        //det.customer_lifecycle_touchpoint = customerLifeCycle;
                        
                        LockatedApp_PostSalesWrapper.PicklistWrapper complaintType =  new LockatedApp_PostSalesWrapper.PicklistWrapper();
                        PicklistWrapper pw1 = getDependentPicklist('Case', 'RW_Complaint_Type__c','RW_Complaint_SubType__c');
                        //complaintType.pickListMap = pw1.pickListMap;
                        //complaintType.parentFieldLabel = pw1.parentFieldLabel;
                        //complaintType.childFieldLabel = pw1.childFieldLabel;
                        //det.complaint_type = complaintType;
                        
                        
                        List<LockatedApp_PostSalesWrapper.Category> categoryList = new List<LockatedApp_PostSalesWrapper.Category>();
                        for(String clt : pw.pickListMap.keySet()){
                            /*for(String compType : pw1.pickListMap.keySet()){
                                if(pw.pickListMap.get(clt).contains(compType)){
                                    LockatedApp_PostSalesWrapper.Category c = new LockatedApp_PostSalesWrapper.Category();
                                    c.caseType = 'Complaint';
                                    c.categoryType = clt;
                                    c.categoryName = compType;
                                    c.subCategories = pw1.pickListMap.get(compType);
                                    categoryList.add(c);
                                }
                            }*/
                            if(clt != 'Post-Possession'){
                                for(String compType : pw1.pickListMap.keySet()){
                                    if(pw.pickListMap.get(clt).contains(compType)){
                                        LockatedApp_PostSalesWrapper.Category c = new LockatedApp_PostSalesWrapper.Category();
                                        c.caseType = 'Complaint';
                                        c.categoryType = clt;
                                        c.categoryName = compType;
                                        c.subCategories = pw1.pickListMap.get(compType);
                                        categoryList.add(c);
                                    }
                                }
                            }
                        }
                        LockatedApp_PostSalesWrapper.Category c = new LockatedApp_PostSalesWrapper.Category();
                        c.caseType = 'Enquiry';
                        c.categoryType = null;
                        c.categoryName = null;
                        c.subCategories = null;
                        categoryList.add(c);
                        det.case_category = categoryList;
                        System.debug('categoryList: ' + categoryList);
                        //return det;
                        res.responseBody = Blob.valueOf(JSON.serialize(det));
                        res.statusCode = 200;
                    }else{
                        errorResult.put('status', 'error');
                        errorResult.put('message', 'Booking record not found');
                        res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                        res.statusCode = 400;   
                    }
                }else{
                    errorResult.put('status', 'error');
                    errorResult.put('message', 'Booking record not found');
                    res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                    res.statusCode = 400; 
                }
            }catch(exception e){
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage() + ';  ' + e.getStackTraceString());
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;                
            }
        }
        
        
    }
    
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> results = new List<String>();
        
        // Get object describe
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get field describe
        Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldName).getDescribe();
        
        // Get picklist values
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            results.add(entry.getLabel());
        }
        
        return results;
    }
    
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue; 
        public String label;
        public String value;
        public String validFor;
        
    }
    
    public class PicklistWrapper{
        public Map<String, List<String>> pickListMap;
        public String parentFieldLabel;
        public String childFieldLabel;      
    }	
    
    
}