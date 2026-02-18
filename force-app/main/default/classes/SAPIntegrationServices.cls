public with sharing class SAPIntegrationServices {
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    @future (callout=true)
    public static void createSO(Set<Id> oIdSet) {
        String customerNumber;
        String SONumber;
        // Added RW_Project_Unit__r.Booking__c in the query by Tejaswini
        List<Opportunity> oList  = [Select Id, SAP_Customer_Number__c,SalesOrder_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet];
      //Added by Vinay 19-11-2021
        List<ERP_Integration_Log__c> erpLogs = [SELECT Id, API_Name__c, Status__c, Opportunity__c FROM ERP_Integration_Log__c WHERE Opportunity__c =: oList[0].Id  and Status__c = 'Success' and API_Name__c = 'Customer Creation/Update'];
                
        // check if customer is present, if not call CC API and SO API.
      //  if(oList[0].SAP_Customer_Number__c == null) {
      
        if(oList[0].SAP_Customer_Number__c == null && erpLogs.size() == 0){//Added by Vinay 19-11-2021
            customerNumber = createCustomer(oIdSet);
            oList[0].SAP_Customer_Number__c = customerNumber;
            //if(oList != null)
            	//update oList;
        }
        if((customerNumber != null && customerNumber!= '') || (oList[0].SAP_Customer_Number__c != null && oList[0].SAP_Customer_Number__c != '')){
            //oList[0].SAP_Customer_Number__c = customerNumber;
            
            if(customerNumber != null && customerNumber!= ''){
                system.debug('customerNumber>>>' +customerNumber);
                SONumber = generateSalesOrder(oIdSet, customerNumber);
            }else if(oList[0].SAP_Customer_Number__c != null && oList[0].SAP_Customer_Number__c != ''){
                SONumber = generateSalesOrder(oIdSet, oList[0].SAP_Customer_Number__c);
            }
            
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
            system.debug(json.serialize(erpLogList.size()));
            system.debug(json.serialize(erpLogList[0].id));
            
            system.debug(oList[0]);
            system.debug(customerNumber+SONumber);
            if(SONumber != null){
                List<String> soNumWithGst = SONumber.split(','); //Added by Vinay 13-02-2026
                
                //oList[0].SalesOrder_Number__c = SONumber;
                oList[0].SalesOrder_Number__c = (soNumWithGst.size() > 0)? soNumWithGst[0] : ''; //Added by Vinay 13-02-2026
                
                //Added by Vinay 11-12-2025 Start
                Booking__c bkg = new Booking__c();
                bkg.Id = oList[0].Booking__c;
                bkg.SO_Release_Date_in_SAP__c = Date.today();
				bkg.X4_5_Received__c = true;
                if(soNumWithGst.size() > 1){ //Added by Vinay 13-02-2026
                    List<GST_Conversion__mdt> gstConversion = [SELECT Id, MasterLabel, Label, SAP_GST__c,GST_Value__c FROM GST_Conversion__mdt WHERE SAP_GST__c =: Decimal.valueOf(soNumWithGst[1]) LIMIT 1];
                    //bkg.GST_Percent__c =  Decimal.valueOf(soNumWithGst[1]); 
                    if(gstConversion != null && gstConversion.size() > 0){
                        bkg.GST_Percent__c = gstConversion[0].GST_Value__c;
                    }
                }
                update bkg;
                //Added by Vinay 11-12-2025 End
            }
                
            
            //if(oList != null)
                //update oList;
        }
        
         if(erpLogList.size() > 0)
                insert erpLogList;
        
        if(oList != null){
            try{
                update oList;
            }catch (DmlException e) {
				System.debug('The following exception has occurred: ' + e.getMessage());
			}   
        }
                
        
          
      //  }
        /*else {//commented else as we need to update the customer created during eoi
            // if Customer is present, dont call CC API. Log the info that the API is not called.
            System.debug('Customer is present:');
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.request__c = 'NA';
            log.API_name__c = 'Customer Creation';
            log.Booking__c = oList[0].Booking__c;
            log.Opportunity__c = oList[0].Id;
            log.response__c = 'NA';
            log.Status__c = 'Not processed';
            log.Error_Reason__c = 'Customer is already present on the opportunity, now calling the update customer API';
            erpLogList.add(log);
            // using the customer present in the OPP call the SO API, if SO # is not present. 
            customerNumber = oList[0].SAP_Customer_Number__c;
            system.debug(oList[0].SAP_Customer_Number__c+'oList[0].SAP_Customer_Number__c');
            //    customerNumber = createCustomer(oIdSet);
            if(oList[0].SalesOrder_Number__c == null) {
                SONumber = generateSalesOrder(oIdSet, customerNumber);
                if(SONumber != null)
                    oList[0].SalesOrder_Number__c = SONumber;
                if(erpLogList.size() > 0)
                    insert erpLogList;
                if(oList != null)
                    update oList;
            } else {
                // if SO # is also present then don't call the API as well.
                System.debug('Sales Order is present: Not calling the APIs');
                // ERP_Integration_Log__c log1 = new ERP_Integration_Log__c();
//log1.request__c = 'NA';
//log1.API_name__c = 'Sales Order';
//log1.Booking__c = oList[0].Booking__c;
//log1.Opportunity__c = oList[0].Id;
//log1.response__c = 'NA';
//log1.Status__c = 'Not processed';
//log1.Error_Reason__c = 'SO is already present on the opportunity, not calling the SO API';
//erpLogList.add(log1);
//if(erpLogList.size() > 0)
//insert erpLogList;
                generateSalesOrder(oIdSet, customerNumber);
            }
            
        }*/
    }
    
    public static String generateSalesOrder(Set<Id> oIdSet, String cNo){    
        system.debug('MK'+cNo);
        String SONumber;
        Boolean dataError = false;
        Id bookingId;
        Id oppId;
        Id unitId;
        Id quoteId;
        List<Booking__c>  bList  = new List<Booking__c>();
        List<Quotation__c>  qList  = new List<Quotation__c>();
        List<Project_Unit__c>   uList = new List<Project_Unit__c>();
        String errMsg ='';
        // Added RW_Project_Unit__r.Booking__c by Tejaswini in the query
        List<Opportunity> oList  = [Select Id,SalesOrder_Number__c, SAP_Customer_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Walkin_Channel_Partner__c, Walkin_Source__c,Walkin_SubSource__c,RW_Project_Unit__r.Booking__c,Referral_Sub_Source__c from Opportunity where Id in: oIdSet]; 
        //opportunity check
        if(oList == null || oList.size() == 0 || oList.size() > 1) {
            dataError = true;
            errMsg = 'Invalid Opportunity,';
        } else {
            oppId = oList[0].Id;
        }
        // customer # check
        if(cNo == null) {
            dataError = true;
            errMsg += 'Customer number not present,';
        } 
        // project data check
        List<Project__c> pRec = [Select Id, Name,Brokerage__c, Project_Property_Type__c,Sales_District__c, allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c,allotment_charges_8__c, Allotment_Charges_9__c,Stack_Car_Park_Charges__c from Project__c where Id = : oList[0].RW_Project__c];
        if(pRec == null || pRec.size() > 1) {
            errMsg += 'Project Data Issue,';
            dataError = true;
        }
        // tower or plant data check
        List<Tower__c> tRec = [Select Id, Name, Property_Type__c,SAP_Plant_Code__c  from Tower__c where Id = : oList[0].RW_Project_Unit__r.TowerName__c];
        if(tRec == null || tRec.size() > 1) {
            errMsg += 'Tower Data Issue,';
            dataError = true;
            
        } else {
            if(tRec[0].SAP_Plant_Code__c == null) {
                errMsg += 'SAP Tower Code not present,';
                dataError = true;
            }
        }
        // booking check
        if(oList[0].Booking__c == null) {
            dataError = true;
            errMsg = 'Booking not present,';
        }  else {
            bookingId = oList[0].Booking__c;
            bList = [Select Id,Brokerage__c	, Booking_Date__c, Source_Of_Booking__c, Name,RW_Last_SDR_Received__c,Funding_Status__c,
                     RW_Registration_Date__c,RW_BRL_Number__c,RW_Release_of_Charge_issue_status__c,RW_ROC_Date__c,RW_Signed_Agreement_to_Customer_Date__c,
                     RW_Actual_Possession_Date__c,RW_Agreement_Possession_Date__c	,Date_for_offer_of_Possession__c,Passback__c,Brokerage1_Amount__c,
                     RW_Nominee_Name__c	,Date_of_Occupation_Certificate__c	,Date_of_Cancellation__c,RW_Key_handover_date__c,Agreement_Value_for_brokers__c,
                     Referral__c, Customer_reference_SAP_Code__c, Referral_Amount__c, Referral_Passback__c,Loan_Bank__c, RW_Loan_Bank__c, RW_Loan_Amount__c, 
                     RW_Loan_Account_Number__c, RW_Loan_Sanction_Date__c, RW_Noc_Generated_Date__c, Interest_to_be_Applied__c, ADF_Opted__c //added by digicloud
                     from Booking__c where Id = : bookingId];
        }
        // quotation check
        if(oList[0].Booking__r.Quotation__c == null) {
            dataError = true;
            errMsg = 'Quotation not present,';
        } else {
            quoteId = oList[0].Booking__r.Quotation__c;
            qList = [Select Id, Name,PaymentPlan__r.name, Total_Discount_L__c, Customer_Total_Discount_L__c, Discount_1_Type__c, Discount_1_PSF__c, Discount_1_L__c, Premium_Charges_Description_1__c, Premium_Charges_ST_1__c, Premium_Charges_Amount_1__c,CAM_Charges__c,BCAM_Charges__c,Total_No_of_Parking__c,Discount_9_L__c,Total_Discount_lumpsum_Wo_CP_Passback__c,Discount_10_L__c,Discount_11_L__c,Valid_Till_Date__c from Quotation__c where Id = :quoteId];
        }
        
        if(oList[0].RW_Project_Unit__c == null) {
            dataError = true;
            errMsg = 'Unit not present,';
        } else {
            unitId = oList[0].RW_Project_Unit__c;
            uList = [Select Id, Name,Unit_SAP_Code__c,Saleable_Area__c, Carpet_area__c, Service_Room_Unit__c, Service_Room_Unit__r.Unit_SAP_Code__c, Service_Room_Unit__r.Saleable_Area__c from Project_Unit__c where Id = : oList[0].RW_Project_Unit__c];
            if(uList[0].Unit_SAP_Code__c == null) {
                dataError = true;
                errMsg += 'SAP Material Code not present in the unit,';
            }
        }
        List<Project_Charges__c> pList = new List<Project_Charges__c>();
        if(pRec != null) {
            pList = [Select Id, Name, Charge_Code__c, S_Charge_Bucket__c from Project_charges__c where Project__c = :pRec[0].Id];
        }
        Set<Id> GlobalChargesSet = new Set<Id>();
        if(pList == null) {
            dataError = true;
            errMsg += 'Invalid Project Charges,';
        } else {
            for(Project_Charges__c p : pList) {
                if(p.S_Charge_Bucket__c.equals('Other Charges') || p.Name.equalsIgnoreCase('Basic') ||  p.Name.equalsIgnoreCase('Allotment Charges'))
                    GlobalChargesSet.add(p.Charge_Code__c);
            }
        }
        // check if SAP codes are there for all global charges of this project.
        List<Global_Charges__c> glList = [Select Id, Name, SAP_Material_Code__C, SAP_Condition_Type__c, SAP_material_Type__c from Global_Charges__c where Id in :GlobalChargesSet];
        if(glList == null) {
            dataError = true;
            errMsg += 'Invalid Project Charges,';
        } else {
            for(Global_Charges__c g : glList) {
                if(g.SAP_Material_Code__C == null) {
                    system.debug(g+'&&&&&&&&&&&MK');
                    dataError = true;
                    errMsg += g.Name + ' doesnot have a  SAP Material Code,';
                }
                
                if(g.Name == 'Basic') {
                    if(g.SAP_material_Type__c == null) {
                        system.debug(g+'&&&&&&&&&&&MK');
                        errMsg += g.Name + ' doesnot have a  SAP Material Type,';
                        dataError = true;
                    }
                }
                
            }
        } 
        
        // if data error , dont call API, log the error and exit.
        if(dataError) {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'Sales Order';
            log.Booking__c = oList[0].RW_Project_Unit__r.Booking__c;
            log.Opportunity__c = oList[0].Id;
            log.Status__c = 'Not Processed';
            log.Error_Reason__c = errMsg;
                     log.Status__c = 'Failure';
            log.Error_Type__c = 'Data Error';
            erpLogList.add(log);
        }    
        else if(!dataError){
                        SalesOrderErrorLogger sLog = new SalesOrderErrorLogger();
            integer BasicPlanSequenceNo;
            String BasicCPPHId ;
            Map<String, Global_Charges__c> globalChargesMap = new Map<String, Global_Charges__c>();
            for(Global_Charges__c g : glList) {
                globalChargesMap.put(g.Name, g);
            }
            // Order Header
             SalesOrderSAPAPIMCS.ZsdstOrderHeader orderHeader = new SalesOrderSAPAPIMCS.ZsdstOrderHeader();
            // Changes made to take Property type from tower level instead of Project on 10-10-2020 By Shailesh
            if(String.isNotBlank(tRec[0].Property_Type__c) && tRec[0].Property_Type__c.equalsIgnoreCase('Residential') ){
                orderHeader.DOC_TYPE = 'ZRES';
                orderHeader.DISTR_CHAN= '10'; // for residential
            } else if (String.isNotBlank(tRec[0].Property_Type__c) && tRec[0].Property_Type__c.equalsIgnoreCase('Commercial') ) {
                orderHeader.DOC_TYPE = 'ZCOC'; 
                orderHeader.DISTR_CHAN= '20'; 
            }
            if(bList[0].Interest_to_be_Applied__c == 'Yes'){ // Added by coServe 18-10-2024
                orderHeader.INT_CALC_FLAG = 'X';
            }else{
                orderHeader.INT_CALC_FLAG = '';
            }
            orderHeader.PLANT = tRec[0].SAP_Plant_Code__c;
            orderHeader.DIVISION= '00';
            orderHeader.SALES_GRP = '';
            orderHeader.SALES_OFF= '';
            orderHeader.PURCH_NO_C= bList[0].Name;
            orderHeader.PO_DAT_S = '';
            orderHeader.DOC_DATE = '';
            orderHeader.SALES_ORD_NO=oList[0].SalesOrder_Number__c;
            // added by digicloud for ADF Option
            if(bList[0].ADF_Opted__c == true){
                orderHeader.ADF_OPTION = 'Y';
            }else{
                orderHeader.ADF_OPTION = 'N';
            }
 //orderHeader.AdfOption = 'Y';
            //orderHeader.ZzpossStrDt = String.ValueOf(bList[0].RW_Actual_Possession_Date__c);
            orderHeader.ZZSTM_REG_PD = String.ValueOf(bList[0].RW_Last_SDR_Received__c);
            orderHeader.ZZREG_DT = String.valueOf(bList[0].RW_Registration_Date__c);
            orderHeader.ZZBOOK_DT=String.ValueOf( bList[0].Booking_Date__c.date() );
            orderHeader.ZZREG_SR_NO=bList[0].RW_BRL_Number__c;
            orderHeader.ZZRROC_DT=String.ValueOf( bList[0].RW_ROC_Date__c );
            orderHeader.ZZAGRMT_DT=String.ValueOf( bList[0].RW_Signed_Agreement_to_Customer_Date__c );
            orderHeader.ZZAGR_POSS_DT=String.ValueOf( bList[0].RW_Agreement_Possession_Date__c );
            orderHeader.ZZPOSS_STR_DT=String.ValueOf( bList[0].RW_Actual_Possession_Date__c );
            orderHeader.ZZKEY_HDOVR_DT=String.ValueOf( bList[0].RW_Key_handover_date__c );
            orderHeader.ZZOCCP_CERT_DT=String.ValueOf( bList[0].Date_of_Occupation_Certificate__c );
            orderHeader.NOMINI1 = bList[0].RW_Nominee_Name__c;	
            //Added by coServe 10-01-2023 Start
            if(bList[0].Funding_Status__c == 'Self Funded'){
                orderHeader.ZZPAY_MODE = '1';
            }else if(bList[0].Funding_Status__c == 'Loan Bank'){
                orderHeader.ZZPAY_MODE = '2';
            }
            //Added by coServe 10-01-2023 End
            //Added by coServe 05-06-2023 Start
            //orderHeader.ZzloanBd = bList[0].Loan_Bank__c; //commented by coServe 13-09-2023
            orderHeader.ZZLOAN_BD = bList[0].RW_Loan_Bank__c; //Added by coServe 13-09-2023
            if(bList[0].RW_Loan_Amount__c != null)
                orderHeader.ZZLOAN_AMT = String.valueOf(bList[0].RW_Loan_Amount__c);
            if(bList[0].RW_Loan_Account_Number__c != null)
                orderHeader.ZZLOAN_FILE_NO = String.valueOf(bList[0].RW_Loan_Account_Number__c);
            if(bList[0].RW_Loan_Sanction_Date__c != null)
                orderHeader.ZZSANCTION_DT  =String.valueOf(bList[0].RW_Loan_Sanction_Date__c) ;
            if(bList[0].RW_Noc_Generated_Date__c != null)
            orderHeader.ZZNOC_ISS_DT=String.valueOf(bList[0].RW_Noc_Generated_Date__c) ;
            //Added by coServe 05-06-2023 End
        //    orderHeader.ZzcarparkAlt=Integer.valueOf(qList[0].No_of_parking__c);
          orderHeader.ZZCARPARK_ALT=Integer.valueOf(qList[0].Total_No_of_Parking__c);   	
           orderHeader.PAYMENT_PLAN_TYPE = qList[0].PaymentPlan__r.name;
            // Order Header for logging
           /* SalesOrderLogger.ZsdstOrderHeader orderHeaderLog = new SalesOrderLogger.ZsdstOrderHeader();
            orderHeaderLog.DocType = orderHeader.DocType;
            orderHeaderLog.Plant = orderHeader.Plant;
            orderHeaderLog.DistrChan= orderHeader.DistrChan;
            orderHeaderLog.Division= orderHeader.Division;
            orderHeaderLog.SalesGrp = orderHeader.SalesGrp;
            orderHeaderLog.SalesOff= orderHeader.SalesOff;
            orderHeaderLog.PurchNoC= orderHeader.PurchNoC;
            orderHeaderLog.PoDatS = orderHeader.PoDatS;
            orderHeaderLog.DocDate = orderHeader.DocDate;*/
            
            Integer seqNo = 10;
            Integer count = 1;
            // order line items table - its a list of order lines
            SalesOrderSAPAPIMCS.TableOfZsdstOrderItem orderItemsList = new SalesOrderSAPAPIMCS.TableOfZsdstOrderItem();
            orderItemsList.item = new List<SalesOrderSAPAPIMCS.ZsdstOrderItem>();
            
            // order conditions - its a list of order conditions
            SalesOrderSAPAPIMCS.TableOfZsdstCondition orderConditionsList = new SalesOrderSAPAPIMCS.TableOfZsdstCondition();
            orderConditionsList.item = new List<SalesOrderSAPAPIMCS.ZsdstCondition>();
            
            List<Customer_Pay_Plan_Header__C> cpphList = new List<Customer_Pay_Plan_Header__C>();
            cpphList = [Select Id, Name, Global_Charges__c, Global_Charges__R.Name, Global_Charges__r.SAP_Material_Code__c, Global_Charges__r.SAP_Condition_Type__c,Global_Charges__r.SAP_Material_Type__c, Standard_Pay_Plan_Header__c, Standard_Pay_Plan_Header__r.Charge_Code__c ,Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c, Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c, Amount__c from customer_pay_plan_header__c where Quotation__c = :quoteId  order by Global_Charges__r.Sequence_No__c];
            List<Rate_List__c> rList = new List<Rate_List__c>();
            rList = [Select Id, Name, Global_Charges__c, Global_Charges__r.Name,Rate__c, Amount__c, Charge_on_Area_Type__c, Charged_Based_On__c,Charge_Based_On_Master__c from Rate_List__c where Project_Unit__c = :unitId];
            Map<String, Rate_List__c> rateMap = new Map<String, Rate_List__c>();
            if(rList.size() > 0) {
                for(Rate_List__c r: rList) {
                    rateMap.put(r.Global_Charges__c, r);
                }
            }
            if(cpphList.size() == 0) {
                dataError = true;
                errMsg += 'Charges Not present: Missing CPPH';
            } else {
                for(Customer_Pay_Plan_Header__c cpph: cpphList) {
                    // Basic charges
                    // Basic represents the unit material and includes everything in the Agreement value bucket including Floor Rise, Basic
                    if(cpph.Standard_Pay_Plan_Header__r.Charge_Code__c != null && cpph.Global_Charges__R.Name.equalsIgnoreCase('Basic')) {
                        
                        SalesOrderSAPAPIMCS.ZsdstOrderItem  orderLine = new SalesOrderSAPAPIMCS.ZsdstOrderItem();
                        orderLine.ItmNumber = string.valueOf(SeqNo * count);
                        BasicPlanSequenceNo = SeqNo * count;
                        BasicCPPHId = cpph.id;
                        orderLine.Material = uList[0].Unit_SAP_Code__c;
                        orderLine.TargetQty= String.valueOf(uList[0].Saleable_Area__c);
                        orderLine.TargetQu='';
                        orderLine.Mtart = cpph.Global_Charges__r.SAP_Material_Type__c;
                        orderLine.Pltyp = '';
                        orderLine.Konda = '';
                        orderItemsList.item.add(orderLine);
                        count++;
                        // order conditions for Basic. If there are Additional Premium , then include that as a condition of Basic.
                        
                        if(uList[0].Service_Room_Unit__c != null){ // Added by Vinay 01-07-2025
                            SalesOrderSAPAPIMCS.ZsdstOrderItem  orderLine1 = new SalesOrderSAPAPIMCS.ZsdstOrderItem();
                            orderLine1.ItmNumber = string.valueOf(SeqNo * count);
                            orderLine1.Material = uList[0].Service_Room_Unit__r.Unit_SAP_Code__c;
                            orderLine1.TargetQty= String.valueOf(uList[0].Service_Room_Unit__r.Saleable_Area__c);
                            orderLine1.TargetQu='';
                            orderLine1.Mtart = '';
                            orderLine1.Pltyp = '';
                            orderLine1.Konda = '';
                            orderItemsList.item.add(orderLine1);
                            count++;
                        }
                    }
                    
                    if (cpph.Standard_Pay_Plan_Header__r.Charge_Code__c != null && 
                        cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c.equalsIgnoreCase('Other Charges')) {
                            
                            // Debugging Charge Code & Bucket
                            System.debug('Charge Code__c: ' + cpph.Standard_Pay_Plan_Header__r.Charge_Code__c);
                            System.debug('Charge Bucket__c: ' + cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c);
                            
                            // Debugging CPPH record details
                            System.debug('CPPH record:' + cpph.Name + ', Global Charges: ' + cpph.Global_Charges__c);
                            
                            // Check if the Charge_Calculated_As field exists and debug it
                            System.debug('Charge Calculated As: ' + cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c);
                            
                            // Check if Global_Charges__c exists
                            if (cpph.Global_Charges__c == null) {
                                System.debug('ERROR: cpph.Global_Charges__c is NULL.');
                            } else {
                                System.debug('cpph.Global_Charges__c: ' + cpph.Global_Charges__c);
                                
                                // Check if rateMap contains the key
                                if (!rateMap.containsKey(cpph.Global_Charges__c)) {
                                    System.debug('ERROR: rateMap does NOT contain key: ' + cpph.Global_Charges__c);
                                } else {
                                    System.debug('rateMap contains key: ' + cpph.Global_Charges__c);
                                    
                                    // Fetch the value from rateMap
                                    Rate_List__c rateObj = rateMap.get(cpph.Global_Charges__c);
                                    System.debug('Fetched rateObj: ' + rateObj);
                                    
                                    // Check if Charge_Based_On_Master__c exists before accessing
                                    if (rateObj != null) {
                                        System.debug('Charge_Based_On_Master__c: ' + rateObj.Charge_Based_On_Master__c);
                                        
                                        if (cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c.equalsIgnoreCase('Rate List at Unit Level') && 
                                            rateObj.Charge_Based_On_Master__c.equals('Rate')) {
                                                System.debug('Condition satisfied, proceeding further.');
                                            } else {
                                                System.debug('Condition NOT met.');
                                            }
                                    } else {
                                        System.debug('ERROR: rateObj is NULL.');
                                    }
                                }
                            }
                        }
                    
                    
                    // other charges bucket - each other charge is a separate order line item.
                    if(cpph.Standard_Pay_Plan_Header__r.Charge_Code__c != null && cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c.equalsIgnoreCase('Other Charges')) {
                        // is it rate list or lumpsum
                        System.debug('CPPH record:' + cpph.Name + ':' + cpph.Global_Charges__r.Name);
                        if(cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c.equalsIgnoreCase('Rate List at Unit Level') && 
                           rateMap.get(cpph.Global_Charges__c).Charge_Based_On_Master__c.equals('Rate') 
                           //&& rateMap.get(cpph.Global_Charges__c).Amount__c > 0  // Commented by coServe 11-05-2023
                           )
                            {
                               SalesOrderSAPAPIMCS.ZsdstOrderItem  orderLine = new SalesOrderSAPAPIMCS.ZsdstOrderItem();
                               orderLine.ItmNumber = string.valueOf(SeqNo * count);
                               orderLine.Material = cpph.Global_Charges__r.SAP_Material_Code__c;
                               if(rateMap.get(cpph.Global_Charges__c).Charge_on_Area_Type__c.equalsIgnoreCase('Saleable Area'))
                                   orderLine.TargetQty= String.valueOf(uList[0].Saleable_Area__c);
                               else
                                   orderLine.TargetQty= String.valueOf(uList[0].carpet_Area__c);
                               orderLine.TargetQu='';
                               orderLine.Mtart = '';
                               orderLine.Pltyp = '';
                               orderLine.Konda	 = '';
                               orderItemsList.item.add(orderLine);
                               // order condition for other charges
                               SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                               orderCondition.ItmNumber = orderLine.ItmNumber;
                               orderCondition.CondType = cpph.Global_Charges__r.SAP_Condition_Type__c;
                               orderCondition.CondValue = String.valueOf(rateMap.get(cpph.Global_Charges__c).Rate__c);
                               orderConditionsList.item.add(orderCondition);
                               
                           } else {
                               SalesOrderSAPAPIMCS.ZsdstOrderItem  orderLine = new SalesOrderSAPAPIMCS.ZsdstOrderItem();
                               orderLine.ItmNumber = string.valueOf(SeqNo * count);
                               orderLine.Material = cpph.Global_Charges__r.SAP_Material_Code__c;
                               orderLine.TargetQty= '1';
                               orderLine.TargetQu='';
                               orderLine.Mtart = '';
                               orderLine.Pltyp = '';
                               orderLine.Konda	 = '';
                               orderItemsList.item.add(orderLine);
                               
                               // order condition for other charges
                               SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                               orderCondition.ItmNumber = orderLine.ItmNumber;
                               orderCondition.CondType = cpph.Global_Charges__r.SAP_Condition_Type__c;
                               orderCondition.CondValue = String.valueOf(cpph.Amount__c);
                               orderConditionsList.item.add(orderCondition);
                           }
                        count++;
                    }
                }
            }
            // check for Discounts
            if(qList[0].Total_Discount_L__c != 0) {
                
                
                Decimal GSTDiscount = 0;
                // send all discounts in one line and GST discount in another.
                if(qList[0].Discount_1_Type__c != null && qList[0].Discount_1_Type__c.equalsIgnoreCase('GST Discount') ) {
                    // order condition for other charges
                    SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                    orderCondition.ItmNumber = '10';
                    orderCondition.CondValue = String.valueOf(qList[0].Discount_1_L__c.setscale(2,RoundingMode.HALF_UP));
                    orderCondition.CondType = 'ZGST';
                    orderConditionsList.item.add(orderCondition);
                    GSTDiscount = qList[0].Discount_1_L__c;
                }
                // this means there are other discounts as well, apart from the GST discount as well.
                //if(qList[0].Total_Discount_L__c - GSTDiscount > 0) { //Commented by coServe 21-10-2022
                if(qList[0].Total_Discount_lumpsum_Wo_CP_Passback__c - GSTDiscount > 0){
                    // order condition for other charges
                    SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                    orderCondition.ItmNumber = '10';
                    //Commented by vinay 22-12-2021
                    //orderCondition.CondValue = String.valueOf((qList[0].Total_Discount_L__c - GSTDiscount).setscale(2,RoundingMode.HALF_UP));
                    //orderCondition.CondValue = String.valueOf((qList[0].Customer_Total_Discount_L__c - GSTDiscount).setscale(2,RoundingMode.HALF_UP)); //Commented by coServe 21-10-2022
                    //orderCondition.CondValue = String.valueOf((qList[0].Total_Discount_lumpsum_Wo_CP_Passback__c - GSTDiscount).setscale(2,RoundingMode.HALF_UP)); //Sending the discount by excluding the CP Passback discount
                    Decimal discount10 = (qList[0].Discount_10_L__c != null)? qList[0].Discount_10_L__c : 0;
                    Decimal discount11 = (qList[0].Discount_11_L__c != null)? qList[0].Discount_11_L__c : 0;
                    orderCondition.CondValue = String.valueOf((qList[0].Total_Discount_lumpsum_Wo_CP_Passback__c - GSTDiscount - discount10 - discount11).setscale(2,RoundingMode.HALF_UP));
                    orderCondition.CondType = 'ZDS1';
                    orderConditionsList.item.add(orderCondition);
                }
                
            }
            // check for Additional Premium [ZPRM]
            if(qList[0].Premium_Charges_Amount_1__c != null && qList[0].Premium_Charges_Amount_1__c != 0) {
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf((qList[0].Premium_Charges_Amount_1__c * uList[0].Saleable_Area__c).setscale(2,RoundingMode.HALF_UP));
                orderCondition.CondType = 'ZPRM';
                orderConditionsList.item.add(orderCondition);
            }
            // Added by shailesh on 23rd of Oct 2019
            // check for CAM value [ZBEX]
            if(qList[0].CAM_Charges__c != null && qList[0].CAM_Charges__c != 0) {
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf((qList[0].CAM_Charges__c).setscale(2,RoundingMode.HALF_UP));
                orderCondition.CondType = 'ZBEX';
                orderConditionsList.item.add(orderCondition);
            }
            // check for BCAM value [ZMAN]
            if(qList[0].BCAM_Charges__c != null && qList[0].BCAM_Charges__c != 0) {
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf((qList[0].BCAM_Charges__c).setscale(2,RoundingMode.HALF_UP));
                orderCondition.CondType = 'ZMAN';
                orderConditionsList.item.add(orderCondition);
            }
            //Ends Here
            Decimal allotmentCharges = 0;
            // check for car parks
            List<Car_Parking_Charge__c> carParkingList = [Select Id, Name, Parking__c, SAP_Material_Code__c from Car_Parking_Charge__c where Booking__c = :bookingId];
            if(carParkingList != null && carParkingList.size() > 0) {
                for(Car_Parking_Charge__c cp: carParkingList) {
                    SalesOrderSAPAPIMCS.ZsdstOrderItem  orderLine = new SalesOrderSAPAPIMCS.ZsdstOrderItem();
                    orderLine.ItmNumber = string.valueOf(SeqNo * count);
                    orderLine.Material = cp.SAP_Material_Code__c;
                    orderLine.TargetQty= '1';
                    orderLine.TargetQu='';
                    orderLine.Mtart = '';
                    orderLine.Pltyp = '';
                    orderLine.Konda = '';
                    orderItemsList.item.add(orderLine);
                    // which one to take for the charge name? also what's the allotment charge and development charges? Dev charges are in agreement value bucket for us and other charges for SAP
                    if(cp.Parking__c.equalsIgnoreCase('Single Covered')) {
                        allotmentCharges += pRec[0].allotment_charges_1__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Tandem Covered')) {
                        allotmentCharges += pRec[0].allotment_charges_2__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Single Open')) {
                        allotmentCharges += pRec[0].allotment_charges_3__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Covered Stack')) {
                        allotmentCharges += pRec[0].allotment_charges_4__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Stilt')) {
                        allotmentCharges += pRec[0].allotment_charges_5__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('MLCP')) {
                        allotmentCharges += pRec[0].allotment_charges_6__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Podium')) {
                        allotmentCharges += pRec[0].allotment_charges_8__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Puzzle Car Park')) { //Added by Vinay 28-03-2025
                        allotmentCharges += pRec[0].allotment_charges_9__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Stack')) { //Added by Vinay 13-02-2026
                        allotmentCharges += pRec[0].Stack_Car_Park_Charges__c;
                    }
                    count++;
                }
                // order condition for parking charges
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf(allotmentCharges);
                orderCondition.CondType = globalChargesMap.get('Allotment Charges').SAP_Condition_Type__c;
                orderConditionsList.item.add(orderCondition);
            }
            // populate the logger
/*            SalesOrderLogger.TableOfZsdstOrderItem orderItemsLogList = new SalesOrderLogger.TableOfZsdstOrderItem();
            orderItemsLogList.item = new List<SalesOrderLogger.ZsdstOrderItem>();
            for( SalesOrderSAPAPIMCS.ZsdstOrderItem oLine :  orderItemsList.item) {
                SalesOrderLogger.ZsdstOrderItem  orderLogLine = new SalesOrderLogger.ZsdstOrderItem();
                orderLogLine.ItmNumber = oLine.ItmNumber;
                orderLogLine.Material = oLine.Material;
                orderLogLine.TargetQty= oLine.TargetQty;
                orderLogLine.TargetQu=oLine.TargetQu;
                orderLogLine.Mtart = oLine.Mtart;
                orderLogLine.Pltyp = oLine.Pltyp;
                orderLogLine.Konda = oLine.Konda;
                orderItemsLogList.item.add(orderLogLine);
            }
            
*/            
            SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction partnerFunctionList = new SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction();
            SalesOrderSAPAPIMCS.ZsdstPartnerFunction partnerFunction1 = new SalesOrderSAPAPIMCS.ZsdstPartnerFunction();
      //      SalesOrderLogger.TableOfZsdstPartnerFunction partnerFunctionLogList = new SalesOrderLogger.TableOfZsdstPartnerFunction();
       //     SalesOrderLogger.ZsdstPartnerFunction partnerFunctionLog1 = new SalesOrderLogger.ZsdstPartnerFunction();
            
            if(oList[0].Walkin_Source__c != null && oList[0].Walkin_Source__c.equalsIgnoreCase('Channel Partner')) {
                List<Broker__c> cpList = new List<Broker__c>();
                cpList = [Select Id, Name, SAP_CP_Code__c from Broker__c where Id = : oList[0].RW_Walkin_Channel_Partner__c ];
                if(!cpList.isEmpty() && cpList.size() ==1 && String.isNotBlank(cpList[0].SAP_CP_Code__c )) {
                    // partner function table - its a list of partner functions
                    
                    partnerFunction1.PartnRole = 'ZB';
                    partnerFunction1.PartnNumb = cpList[0].SAP_CP_Code__c;
                    
                    partnerFunctionList.item = new List<SalesOrderSAPAPIMCS.ZsdstPartnerFunction>();
                    partnerFunctionList.item.add(partnerFunction1);
                    
                    // partner function logging - its a list of partner functions
                /*    partnerFunctionLog1.PartnRole = 'ZB';
                    partnerFunctionLog1.PartnNumb = cpList[0].SAP_CP_Code__c;
                    
                    partnerFunctionLogList.item = new List<SalesOrderLogger.ZsdstPartnerFunction>();
                    partnerFunctionLogList.item.add(partnerFunctionLog1);*/
                    
                    // order condition for parking charges
                    SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                    orderCondition.ItmNumber = '10';
                    /*if(bList[0].Passback__c != null && bList[0].Passback__c != 0){ //Added by Prashant.. 18-07-2025.///
                        orderCondition.condValue = String.valueOf(bList[0].Brokerage1_Amount__c);
                    }else*/ if(bList[0].Brokerage__c != null && bList[0].Brokerage__c != 0){
                        orderCondition.CondValue = String.valueOf(bList[0].Brokerage__c);
                    }else{
                        orderCondition.CondValue = '0';
                    }
                    orderCondition.CondType = 'ZBRK';
                    orderConditionsList.item.add(orderCondition);
                    
                    if(bList[0].Agreement_Value_for_brokers__c != 0 || bList[0].Agreement_Value_for_brokers__c != Null) {
                        SalesOrderSAPAPIMCS.ZsdstCondition orderCondition2 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                        orderCondition2.ItmNumber = '10';
                        orderCondition2.CondValue = String.valueOf(bList[0].Agreement_Value_for_brokers__c);
                        orderCondition2.CondType = 'ZAVB';
                        orderConditionsList.item.add(orderCondition2);
                    }
                    
                    //Added by coServe 20-10-2022 Start
                    if(qList[0].Discount_9_L__c != null && qList[0].Discount_9_L__c != 0) {
                        SalesOrderSAPAPIMCS.ZsdstCondition orderCondition1 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                        orderCondition1.ItmNumber = '10';
                        orderCondition1.CondValue = String.valueOf(qList[0].Discount_9_L__c);
                        orderCondition1.CondType = 'ZCPD';
                        orderConditionsList.item.add(orderCondition1);
                    }
                    //Added by coServe 20-10-2022 End
                }
                
            }
            //Added by coServe 09-01-2023 Start
            if(oList[0].Walkin_Source__c != null && oList[0].Walkin_Source__c.equalsIgnoreCase('Referral') && oList[0].Referral_Sub_Source__c != null &&
               oList[0].Referral_Sub_Source__c.equalsIgnoreCase('Existing client reference')){
                if(qList[0].Discount_10_L__c != null && qList[0].Discount_10_L__c != 0) {
                    
                        SalesOrderSAPAPIMCS.ZsdstCondition orderCondition1 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                        orderCondition1.ItmNumber = '10';
                        orderCondition1.CondValue = String.valueOf((qList[0].Discount_10_L__c).setscale(2,RoundingMode.HALF_UP));
                        orderCondition1.CondType = 'ZRPB';
                        orderConditionsList.item.add(orderCondition1);
                }  
                if(qList[0].Discount_11_L__c != null && qList[0].Discount_11_L__c != 0) {
                        SalesOrderSAPAPIMCS.ZsdstCondition orderCondition2 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                        orderCondition2.ItmNumber = '10';
                        orderCondition2.CondValue = String.valueOf((qList[0].Discount_11_L__c).setscale(2,RoundingMode.HALF_UP));
                        orderCondition2.CondType = 'ZRED';
                        orderConditionsList.item.add(orderCondition2);
                }
            
                /*String referralDiscount;
                for(Referral_Discount__c rd : [SELECT Id, Referral__c, Referrer__c, Valid_From__c, Valid_To__c FROM Referral_Discount__c]){
                    if(qList[0].Valid_Till_Date__c >= rd.Valid_From__c && qList[0].Valid_Till_Date__c <= rd.Valid_To__c){
                        referralDiscount = String.valueOf(rd.Referral__c);
                    }else{
                        referralDiscount = '1';
                    }
                }*/
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition2 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition2.ItmNumber = '10';
                //orderCondition2.CondValue = referralDiscount;
                //orderCondition2.CondValue = String.valueOf(bList[0].Referral__c);
                   if(bList[0].Referral_Passback__c > 0){
                       //orderCondition2.CondValue = String.valueOf(bList[0].Referral__c);
                       orderCondition2.CondValue = String.valueOf(bList[0].Referral_Amount__c.setscale(2,RoundingMode.HALF_UP));
                   }else {
                       orderCondition2.CondValue = String.valueOf(bList[0].Referral__c);
                       //orderCondition2.CondValue = String.valueOf(bList[0].Referral_Amount__c.setscale(2,RoundingMode.HALF_UP));
                   }
                orderCondition2.CondType = 'ZREF';
                orderConditionsList.item.add(orderCondition2);
                   
                partnerFunction1.PartnRole = 'ZR';
                partnerFunction1.PartnNumb = String.valueOf(bList[0].Customer_reference_SAP_Code__c);
                   
                partnerFunctionList.item = new List<SalesOrderSAPAPIMCS.ZsdstPartnerFunction>();
                partnerFunctionList.item.add(partnerFunction1);
            
            	/*SalesOrderSAPAPIMCS.ZsdstCondition orderCondition3 = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition3.ItmNumber = '10';
                orderCondition3.CondValue = String.valueOf(bList[0].Customer_reference_SAP_Code__c);
                orderCondition3.CondType = 'ZR';
                orderConditionsList.item.add(orderCondition3);*/
           }
            //Added by coServe 09-01-2023 End
            // order line conditions for logging
          /*  SalesOrderLogger.TableOfZsdstCondition orderConditionsLogList = new SalesOrderLogger.TableOfZsdstCondition();
            orderConditionsLogList.item = new List<SalesOrderLogger.ZsdstCondition>();
            for( SalesOrderSAPAPIMCS.ZsdstCondition oLine :  orderConditionsList.item) {
                SalesOrderLogger.ZsdstCondition  orderLogCondition = new SalesOrderLogger.ZsdstCondition();
                orderLogCondition.ItmNumber = oLine.ItmNumber;
                orderLogCondition.CondType = oLine.CondType;
                orderLogCondition.CondValue = oLine.CondValue;
                orderConditionsLogList.item.add(orderLogCondition);
            }*/
            SalesOrderSAPAPIMCS.TableOfZsdstBillPlan billPlanList = new SalesOrderSAPAPIMCS.TableOfZsdstBillPlan();
            billPlanList.item = new List<   SalesOrderSAPAPIMCS.ZsdstBillPlan>();
            
            List<Standard_Customer_Pay_Plan_Detail__c> payPlanList = [Select id,RW_SAP_Milestone_Code__c,Payment_Milestone__c,Installment__c,Due_Date__c,Milestone_Percentage__c	 from Standard_Customer_Pay_Plan_Detail__c	 where Customer_Pay_Plan_Header__c=:BasicCPPHId];
            for(Standard_Customer_Pay_Plan_Detail__c sp :payPlanList){
                SalesOrderSAPAPIMCS.ZsdstBillPlan billPlan = new SalesOrderSAPAPIMCS.ZsdstBillPlan();
                billPlan.ItmNumber =string.valueOf(BasicPlanSequenceNo);
                billPlan.BillDate = String.valueOf(sp.Due_Date__c-15);
                billPlan.Usage=sp.RW_SAP_Milestone_Code__c;
                billPlan.InvPer =string.valueOf(sp.Milestone_Percentage__c.setscale(2));
                billPlan.BillValue =string.valueOf( sp.Installment__c);
                billPlanList.item.add(billPlan);
            }
            
            SalesOrderSAPAPIMCS.TableOfBapiret2 bapiRet2List = new SalesOrderSAPAPIMCS.TableOfBapiret2();
            bapiRet2List.item = new List<SalesOrderSAPAPIMCS.BAPIRET2>();
            SalesOrderSAPAPIMCS.Bapiret2 bapiItem = new SalesOrderSAPAPIMCS.Bapiret2();
            bapiItem.Type_x ='';
            bapiItem.Id  ='';
            bapiItem.Number_x ='';
            bapiItem.Message ='';
            bapiItem.LogNo ='';
            bapiItem.LogMsgNo ='';
            bapiItem.MessageV1 ='';
            bapiItem.MessageV2 ='';
            bapiItem.MessageV3 ='';
            bapiItem.MessageV4 ='';
            bapiItem.Parameter ='';
            bapiItem.Row =0;
            bapiItem.Field ='';
            bapiItem.System_x ='';
            
            bapiRet2List.item.add(bapiItem);
            
            // all put together forms the sales order
            SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER salesorder1 = new SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER();
            salesorder1.timeout_x = 120000;
            String CustomerNumber = cNo;
            
          /*  SalesOrderLogger.ZsdSdfcSalesOrderLogger_element SOLogger = new SalesOrderLogger.ZsdSdfcSalesOrderLogger_element();
            SOLogger.OrderHeader = OrderHeaderLog;
            SOLogger.OrderItems = OrderItemsLogList;
            SOLogger.OrderConditions = OrderConditionsLogList;
            SOLogger.PartnerFuntion = partnerFunctionLogList;
            SOLogger.Customerno = CustomerNumber;*/
            Boolean callOutError = false;
            String exceptionMsg = '';
            SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element salesOrderResponse;
            
            SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element responseLog = new SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element();
            responseLog.Return_x  = new SalesOrderLogger.TableOfBapiret2();
            responseLog.Return_x.item = new List<SalesOrderLogger.Bapiret2>();
                   sLog.orderHeader = orderHeader;
            sLog.orderItemsList = orderItemsList;
            sLog.orderConditionsList =orderConditionsList;
            sLog.billPlanList = billPlanList;
            sLog.partnerFunctionList =partnerFunctionList;
            sLog.CustomerNumber = CustomerNumber;
            Boolean exceptionError = false;
            try {
                system.debug(json.serialize(billPlanList));
                system.debug(json.serialize(CustomerNumber));
                
                system.debug(json.serialize(orderConditionsList));
                system.debug(json.serialize(orderHeader));
                
                system.debug(json.serialize(partnerFunctionList));
                salesOrderResponse = salesorder1.ZsdSdfcSalesOrder(billPlanList,CustomerNumber, orderConditionsList, orderHeader, orderItemsList, partnerFunctionList, bapiRet2List);
                system.debug(JSON.serialize(salesOrderResponse));
                system.debug(salesOrderResponse.Salesdocument+'salesOrderResponse.Salesdocument;');
                System.debug('salesOrderResponse.GstPerc: ' + salesOrderResponse.GstPerc);
                if(salesOrderResponse.Return_x.item != null) {
                    system.debug('MK'+salesOrderResponse.Return_x.item);
                    for(SalesOrderSAPAPIMCS.Bapiret2 returnMsg :  salesOrderResponse.Return_x.item) {
                        system.debug('M');
                        SalesOrderLogger.Bapiret2 msgLogLine = new SalesOrderLogger.Bapiret2();
                        msgLogLine.Type_x = returnMsg.Type_x;
                        msgLogLine.Id = returnMsg.Id;
                        msgLogLine.Number_x = returnMsg.Number_x;
                        msgLogLine.Message = returnMsg.Message;
                        msgLogLine.LogNo = returnMsg.LogNo;
                        msgLogLine.LogMsgNo = returnMsg.LogMsgNo;
                        msgLogLine.MessageV1 = returnMsg.MessageV1;
                        msgLogLine.MessageV2 = returnMsg.MessageV2;
                        msgLogLine.MessageV3 = returnMsg.MessageV3;
                        msgLogLine.MessageV4 = returnMsg.MessageV4;
                        msgLogLine.Parameter = returnMsg.Parameter;
                        msgLogLine.Row = returnMsg.Row;
                        msgLogLine.Field = returnMsg.Field;
                        msgLogLine.System_x= returnMsg.System_x;
                        
                        responseLog.Return_x.item.add(msgLogLine);
                    }
                }
                
                if(salesOrderResponse.Salesdocument != null && salesOrderResponse.Salesdocument != '') {
                    responseLog.Salesdocument = salesOrderResponse.Salesdocument;
                    SONumber = salesOrderResponse.Salesdocument;
                    if(salesOrderResponse.GstPerc != null && salesOrderResponse.GstPerc != ''){ //Added by Vinay 13-02-2026
                        SONumber = salesOrderResponse.Salesdocument + ',' + salesOrderResponse.GstPerc;
                    }
                    system.debug(sonumber);
                } else {
                    callOutError = true;
                    exceptionMsg = 'Sales Order # not received';
                    
                }
            } catch (Exception ex) {
                System.debug('Exception:' + ex.getMessage());
                callOutError = true;
                                exceptionError= true;
                exceptionMsg = ex.getMessage();
            } finally {
                System.debug('JSON Logger request:' + JSON.SerializePretty(sLog));
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                
                String requestF = JSON.SerializePretty(sLog);
               requestF =  requestF.replaceAll('&quot;','"');
              //  requestF  = requestF.replaceAll('\t', '&nbsp;');
                log.request__c = requestF;
                
                log.API_name__c = 'Sales Order';
                log.Booking__c = bookingId;
                log.Opportunity__c = oppId;
                String responseF = JSON.SerializePretty(responseLog);
                responseF =  responseF.replaceAll('\n','<br/>');
                responseF  = responseF.replaceAll('\t', '&nbsp;');
                log.response__c = responseF;
                if(!callOutError) {
                    log.Status__c = 'Success';
                    
                } else {
                     log.Status__c = 'Failure';
                      if(exceptionError){
                        log.Error_Type__c='Timeout Error';
                    }else{
                        log.Error_Type__c='Data Error';
                        
                    }
                   
                    log.Error_Reason__c = exceptionMsg;
                }
                erpLogList.add(log);
                // insert log;
            }
            
        }
        return SONumber;
    }
    
    public static String createCustomer(Set<Id> oIdSet){
        String customerNumber;
        Boolean dataError = false;
        Id bookingId;
        Id oppId;
        Id unitId;
        Id quoteId;
        List<Booking__c>  bList  = new List<Booking__c>();
        List<Quotation__c>  qList  = new List<Quotation__c>();
        List<Project_Unit__c>   uList = new List<Project_Unit__c>();
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Map<String, Applicant_Details__c> appMap = new Map<String, Applicant_Details__c>();
        String errMsg ='';
        // Added RW_Project_Unit__r.Booking__c by Tejaswini in the query
        List<Opportunity> oList  = [Select Id, SAP_Customer_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, Sales_Manager__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name, RW_Closing_Head__c, RW_Sourcing_Manager__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name, RW_Sourcing_Head__c,Walkin_Source__c,RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet];   //Added Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
        //opportunity check
        if(oList.isEmpty() || oList.size() == 0 || oList.size() > 1) {
            dataError = true;
            errMsg = 'Invalid Opportunity,';
        } else {
            oppId = oList[0].Id;
        }
        List<Project__c> pRec = new List<Project__c>();
        List<Tower__c> tRec = new List<Tower__c>();
        if(oppId != null) {
            // project data check
            pRec = [Select Id, Name,SAPMaterial_Code__c, Sales_District__c, Project_Property_Type__c,allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c from Project__c where Id = : oList[0].RW_Project__c];
            if(pRec == null || pRec.size() > 1) {
                errMsg += 'Project Data Issue,';
                dataError = true;
            } else {
                if(pRec[0].SAPMaterial_Code__c == null) {
                    errMsg += 'SAP Project Code not present,';
                    dataError = true;
                }
            }
            // tower or plant data check
            tRec = [Select Id, Name, Property_Type__c,SAP_Plant_Code__c  from Tower__c where Id = : oList[0].RW_Project_Unit__r.TowerName__c];
            if(tRec == null || tRec.size() > 1) {
                errMsg += 'Tower Data Issue,';
                dataError = true;
                
            } else {
                if(tRec[0].SAP_Plant_Code__c == null) {
                    errMsg += 'SAP Tower Code not present,';
                    dataError = true;
                }
            } 
            // booking check
            if(oList[0].Booking__c == null) {
                dataError = true;
                errMsg = 'Booking not present,';
            }  else {
                bookingId = oList[0].Booking__c;
                bList = [Select Id, Booking_Date__c,Source_of_Booking__c,Sourcing_Mananger__c,Sales_Managers__c,Name,Customer_Category_Type__c,Scheme_of_Customer__r.SAP_Code__c from Booking__c where Id = : bookingId];
            }
            // quotation check
            if(oList[0].Booking__r.Quotation__c == null) {
                dataError = true;
                errMsg = 'Quotation not present,';
            } else {
                quoteId = oList[0].Booking__r.Quotation__c;
                qList = [Select Id, Name, Total_Discount_L__c, Discount_1_Type__c, Discount_1_PSF__c, Discount_1_L__c, Premium_Charges_Description_1__c, Premium_Charges_ST_1__c, Premium_Charges_Amount_1__c,BCAM_Charges__c,CAM_Charges__c  from Quotation__c where Id = :quoteId];
            }
            
            if(oList[0].RW_Project_Unit__c == null) {
                dataError = true;
                errMsg = 'Unit not present,';
            } else {
                unitId = oList[0].RW_Project_Unit__c;
                uList = [Select Id, Name,Unit_SAP_Code__c,Saleable_Area__c, Carpet_area__c from Project_Unit__c where Id = : oList[0].RW_Project_Unit__c];
                if(uList[0].Unit_SAP_Code__c == null) {
                    dataError = true;
                    errMsg += 'SAP Material Code not present in the unit,';
                }
            } 
            system.debug(bookingId+'MK');
            system.debug(bookingId != null);
            if(bookingId != null) {
                appList = [Select Id, Mailing_Address_Line_1__c, 
                           Mailing_Address_Line_2__c, 
                           Mailing_Address_Line_3__c, 
                           Mailing_State__c,
                           Mailing_City__c,
                           Mailing_Pincode__c,
                           Mailing_Country__c, 
                           Permanent_Address_Line_1__c,
                           Permanent_Address_Line_2__c,
                           Permanent_Address_Line_3__c,
                           City__c,
                           State__c,
                           Pincode__c,
                           Country__c,
                           Email_Address__c,
                           Mobile_Number__c,
                           Office_Address_Line_1__c,
                           Office_Address_Line_2__c,
                           Office_Address_Line_3__c,
                           Organisation_Pincode__c,
                           Organisation_Country__c,
                           PancardNo__c,
                           Address_Proof_Number__c,
                           Address_Proof_Document__c,
                           Type_Of_Applicant__c,
                           Subtype_Of_Applicant__c,
                           Salutation__c,
                           Name,
                           Organization_Name__c,
                           DOB__c,
                           Nationality__c,
                           Landline_Number__c,
                           Applicant_Number__c,
                           gender__c,
                           Marital_Status__c,
                           Designation_picklist__c,
                           Nationality_picklist__c,
                           Contact_Person_Relationship__c,
                           First_Name__c,
                           Middle_Name__c,
                           Last_Name__c,
                           Occupation__c,
                           Designation__c,
                           PassportNoDetails__c
                           from
                           Applicant_Details__c
                           where Booking__C = :bookingId and Applicant_Status__c != 'Inactive'
                          ];
                system.debug(appList+'MK');
                if(appList == null || appList.size() == 0) {
                    dataError = true;
                    errMsg += 'Applicant Details not present';
                } else {
                    for(Applicant_Details__c a : appList) {
                        appMap.put(a.Applicant_Number__c, a);
                    }
                }
            }
            
        }
        // if data error , dont call API, log the error and exit.
        if(dataError) {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'Customer Creation';
            if(oppId != null) {
                log.Booking__c = oList[0].RW_Project_Unit__r.Booking__c;
                log.Opportunity__c = oList[0].Id;
            }
            log.Status__c = 'Not Processed';
            log.Error_Reason__c = errMsg;
            log.Status__c='Failure';
            log.Error_Type__c = 'Data Error';
            erpLogList.add(log);
        }    
        else if(!dataError){
            CustomerCreation.ZsdSfdcCustomerHd customerHeader = new CustomerCreation.ZsdSfdcCustomerHd();
            if(oList[0].SAP_Customer_Number__c != null)
            {
                System.debug('*already customer present*' + oList[0].SAP_Customer_Number__c);
                customerHeader.Kunnr =  oList[0].SAP_Customer_Number__c;
                System.debug('*already customer present after assign*' + customerHeader.Kunnr);
            }  
            customerHeader.Kdkg2 = bList[0].Scheme_of_Customer__r.SAP_Code__c;
            customerHeader.Vkorg = pRec[0].SAPMaterial_Code__c;
            customerHeader.Werks = tRec[0].SAP_Plant_Code__c;
            //customerHeader.Vtweg = pRec[0].Project_Property_Type__c;
            customerHeader.Vtweg = tRec[0].Property_Type__c;
            customerHeader.Spart = '00';
            //customerHeader.Ktokd = pRec[0].Project_Property_Type__c;
            customerHeader.Ktokd = tRec[0].Property_Type__c;
            customerHeader.Title = appMap.get('Primary Applicant').Salutation__c;
            customerHeader.NameFirst  = appMap.get('Primary Applicant').First_Name__c;
            customerHeader.NameMiddle = appMap.get('Primary Applicant').Middle_Name__c;
            customerHeader.NameLast = appMap.get('Primary Applicant').Last_Name__c;
            customerHeader.Langucorr = 'E';
            customerHeader.Sort1 = uList[0].Unit_SAP_Code__c;
            customerHeader.Sort2 = oppid;
            if(String.isNotBlank(appMap.get('Primary Applicant').gender__c) && appMap.get('Primary Applicant').gender__c.equalsIgnoreCase('Male'))
                customerHeader.Xsexf = 'M';
            else if( String.isNotBlank(appMap.get('Primary Applicant').gender__c) && appMap.get('Primary Applicant').gender__c.equalsIgnoreCase('Female') )
                customerHeader.Xsexf = 'F';
            else
                customerHeader.Xsexf = 'O';
            
            // to do get list from SAP and update the picklist in Salesforce
            customerHeader.Marst = appMap.get('Primary Applicant').Marital_Status__c;
            customerHeader.Natio = appMap.get('Primary Applicant').Nationality_Picklist__c;
            customerHeader.Jobgr = appMap.get('Primary Applicant').Occupation__c;
            customerHeader.StaffGrp = appMap.get('Primary Applicant').Designation__c;
            system.debug(appMap+'appMap');     
            customerHeader.bzirk= pRec[0].Sales_District__c; 
            if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('Indian National') )
                customerHeader.kukla = 'Resident Indian';
            else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('Foreign Nationals Of Indian Origin') )
                customerHeader.kukla = 'PIO';
            else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('For NRI') )
                customerHeader.kukla = 'NRI';
            else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('For Company') )
                customerHeader.kukla = 'Company';
            else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('For Company') )
                customerHeader.kukla = 'Company';
            else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('Partnership Firm') )
                customerHeader.kukla = 'Partnership Firm';
            
            // these need to mapped in SAP based on SFDC data
            if(String.isNotBlank(oList[0].Sourcing_Manager_User__c)) // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__c by Vinay 04-12-2025
                customerHeader.Kvgr1 = oList[0].Sourcing_Manager_User__r.Name; // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__r.Name by Vinay 04-12-2025
            if(String.isNotBlank(oList[0].RW_Sourcing_Head__c))
                customerHeader.Kvgr2 = oList[0].RW_Sourcing_Head__c;
            if(String.isNotBlank(oList[0].Sales_Manager_User__c)) 	//Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                customerHeader.Kvgr3 = oList[0].Sales_Manager_User__r.Name; 	//Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
            if(String.isNotBlank(oList[0].RW_Closing_Head__c))
                customerHeader.Kvgr4 = oList[0].RW_Closing_Head__c;
            if(String.isNotBlank(oList[0].Walkin_Source__c))
                customerHeader.Kvgr5 = oList[0].Walkin_Source__c;
            
            customerHeader.Addrcode = '01';
            
            // to ends here
            
            if(appMap.get('Primary Applicant').DOB__c != null )
            {
                Date DOB = appMap.get('Primary Applicant').DOB__c;
                String strMonth;
                String strDate;
                
                if(String.valueof(DOB.month()).length()  ==1)
                    strMonth = '0' + String.valueof(DOB.month());
                else 
                    strMonth = String.valueof(DOB.month());
                
                if(String.valueof(DOB.day()).length()  ==1)
                    strDate = '0' + String.valueof(DOB.day());
                else 
                    strDate = String.valueof(DOB.day());
                
                customerHeader.Birthdt = String.valueof(DOB.year()) + strMonth + strDate;
            }
            customerHeader.Katr1 = bList[0].Source_of_Booking__c;
            //Added by coServe 29-06-2022 Start
            if(bList[0].Customer_Category_Type__c == 'Management Bookings')
                customerHeader.Bran1 = '0002';
            if(bList[0].Customer_Category_Type__c == 'Barter Deal Customer')
                customerHeader.Bran1 = '0003';
            if(bList[0].Customer_Category_Type__c == 'Legal Case')
                customerHeader.Bran1 = '0004';
            if(bList[0].Customer_Category_Type__c == 'CIP-Canc. in Process')
                customerHeader.Bran1 = '0005';
            if(bList[0].Customer_Category_Type__c == 'Regular')
                customerHeader.Bran1 = '0006';
            //Added by coServe 29-06-2022 End
            if(String.isNotBlank(appMap.get('Primary Applicant').Organization_Name__c))
                customerHeader.Emplo = appMap.get('Primary Applicant').Organization_Name__c;
            customerHeader.Vkbur = pRec[0].SAPMaterial_Code__c;        
            
            // tax details
            /** IN3 India: GST Identification Number(GSTIN)
IN4 India: Passport Number
IN5 India: Aadhar Card Number
IN6 India: PAN Number
IN7 India: Driving Licen
IN8 India: Voters ID
IN9 India: Electricity Bill **/
            
            CustomerCreation.TableOfZsdSfdcCustomerTax customerTaxList = new CustomerCreation.TableOfZsdSfdcCustomerTax();
            customerTaxList.item = new List<CustomerCreation.ZsdSfdcCustomerTax>();
            // Mandatory for Indian National, NRI , Company and Partnership firm
            if(String.isNotBlank(appMap.get('Primary Applicant').PancardNo__c) ) {
                CustomerCreation.ZsdSfdcCustomerTax taxLineitem1 = new CustomerCreation.ZsdSfdcCustomerTax();
                taxLineitem1.Ind = 'M';
                taxLineitem1.Taxtype = 'IN6';
                taxLineitem1.Taxnumxl = appMap.get('Primary Applicant').PancardNo__c;
                customerTaxList.item.add(taxLineItem1);
            }
            // In case of Indian National we collect address proof documents in form or Aadhar, Passport, Driving License, Electricity Bill or Voters card.
            // In case of company we dont collect anything other than pan card, so that already addressed above.
            if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Aadhar Card')) {
                CustomerCreation.ZsdSfdcCustomerTax taxLineitem2 = new CustomerCreation.ZsdSfdcCustomerTax();
                taxLineitem2.Ind = 'M';
                taxLineitem2.Taxtype = 'IN5';
                taxLineitem2.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
                customerTaxList.item.add(taxLineItem2);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem3 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Driving License')) {
                taxLineitem3.Ind = 'M';
                taxLineitem3.Taxtype = 'IN7';
                taxLineitem3.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
                customerTaxList.item.add(taxLineitem3);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem4 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Passport')) {
                taxLineitem4.Ind = 'M';
                taxLineitem4.Taxtype = 'IN4';
                taxLineitem4.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
                customerTaxList.item.add(taxLineitem4);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem6 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Electricity Bill')) {
                taxLineitem6.Ind = 'M';
                taxLineitem6.Taxtype = 'IN9';
                taxLineitem6.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
                customerTaxList.item.add(taxLineitem6);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem7 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Voter\'s  ID Card')) {
                taxLineitem7.Ind = 'M';
                taxLineitem7.Taxtype = 'IN8';
                taxLineitem7.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
                customerTaxList.item.add(taxLineitem7);
            }
            
            // In case of NRI we collect passport #, but doesn't get categorised as address proof document
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem5 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(appMap.get('Primary Applicant').PassportNoDetails__c)) {
                taxLineitem5.Ind = 'M';
                taxLineitem5.Taxtype = 'IN4';
                taxLineitem5.Taxnumxl = appMap.get('Primary Applicant').PassportNoDetails__c;
                customerTaxList.item.add(taxLineitem5);
            }
            
            
            
            // Mailing, Permanent and Office address of primary applicant
            CustomerCreation.TableOfZsdSfdcCustomerAddress customerAddressList = new CustomerCreation.TableOfZsdSfdcCustomerAddress();
            customerAddressList.item = new List<CustomerCreation.ZsdSfdcCustomerAddress>();
            
            CustomerCreation.ZsdSfdcCustomerAddress mailingAddressItem = new CustomerCreation.ZsdSfdcCustomerAddress();
            mailingAddressItem.Addrcode = '01';
            mailingAddressItem.Street = appMap.get('Primary Applicant').Mailing_Address_Line_1__c;
            mailingAddressItem.StrSuppl1 =  appMap.get('Primary Applicant').Mailing_Address_Line_2__c;
            mailingAddressItem.StrSuppl2 =  appMap.get('Primary Applicant').Mailing_Address_Line_3__c;
            mailingAddressItem.PostCode = String.valueOf(appMap.get('Primary Applicant').Mailing_Pincode__c);
            mailingAddressItem.City = appMap.get('Primary Applicant').Mailing_City__c;
            mailingAddressItem.Country = appMap.get('Primary Applicant').Mailing_Country__c;
            // to do check with SAP
            mailingAddressItem.Region  = appMap.get('Primary Applicant').Mailing_State__c;
            customerAddressList.item.add(mailingAddressItem);
            
            // permanent address
            CustomerCreation.ZsdSfdcCustomerAddress permanentAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
            permanentAddress.Addrcode = '02';
            permanentAddress.Street = appMap.get('Primary Applicant').permanent_Address_Line_1__c;
            permanentAddress.StrSuppl1 =  appMap.get('Primary Applicant').permanent_Address_Line_2__c;
            permanentAddress.StrSuppl2 =  appMap.get('Primary Applicant').permanent_Address_Line_3__c;
            permanentAddress.PostCode = String.valueOf(appMap.get('Primary Applicant').Pincode__c);
            permanentAddress.City = appMap.get('Primary Applicant').City__c;
            permanentAddress.Country = appMap.get('Primary Applicant').Country__c;
            // to do check with SAP
            permanentAddress.Region  = appMap.get('Primary Applicant').State__c;
            customerAddressList.item.add(permanentAddress);
            
            // office address
            if(String.isNotBlank(appMap.get('Primary Applicant').Office_Address_Line_1__c) ) {
                CustomerCreation.ZsdSfdcCustomerAddress officeAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
                officeAddress.Addrcode = '03';
                officeAddress.Street = appMap.get('Primary Applicant').Office_Address_Line_1__c;
                officeAddress.StrSuppl1 =  appMap.get('Primary Applicant').Office_Address_Line_2__c;
                officeAddress.StrSuppl2 =  appMap.get('Primary Applicant').Office_Address_Line_3__c;
                officeAddress.PostCode = String.valueOf(appMap.get('Primary Applicant').Organisation_Pincode__c);
                officeAddress.Country = appMap.get('Primary Applicant').Organisation_Country__c;
                // to do check with SAP
                customerAddressList.item.add(officeAddress);
            }
            
            Integer SeqNo = 10;
            Integer count = 1;
            // Co Applicant Details
            CustomerCreation.TableOfZsdsBpContact  coAppList = new CustomerCreation.TableOfZsdsBpContact();
            coAppList.Item = new List<CustomerCreation.ZsdsBpContact>();
            for(String appNumber : appMap.keySet()) {
                if(!appNumber.equalsIgnoreCase('Primary Applicant')) {
                    CustomerCreation.ZsdsBpContact coApp1 = new CustomerCreation.ZsdsBpContact();
                    coApp1.Srno = String.ValueOf(SeqNo * count);
                    coApp1.Title = appMap.get(appNumber).Salutation__c;
                    coApp1.NameFirst = appMap.get(appNumber).First_Name__c;
                    coApp1.NameMiddle = appMap.get(appNumber).Middle_Name__c;
                    coApp1.NameLast = appMap.get(appNumber).Last_Name__c;
                    if(String.isNotBlank(appMap.get(appNumber).Designation_picklist__c))
                        coApp1.Pafkt = appMap.get(appNumber).Designation_picklist__c;
                    if(String.isNotBlank(appMap.get(appNumber).Occupation__c))
                        coApp1.Abtnr = appMap.get(appNumber).Occupation__c;
                    if(String.isNotBlank(appMap.get(appNumber).gender__c) && appMap.get(appNumber).gender__c.equalsIgnoreCase('Male'))
                        coApp1.Xsexf = 'M';
                    else if( String.isNotBlank(appMap.get(appNumber).gender__c) && appMap.get(appNumber).gender__c.equalsIgnoreCase('Female') )
                        coApp1.Xsexf = 'F';
                    else
                        coApp1.Xsexf = 'O';
                    // to check with SAP
                    coApp1.Marst = appMap.get(appNumber).Marital_Status__c;
                    
                    if(appMap.get(appNumber).DOB__c != null )
                    {
                        Date DOB = appMap.get(appNumber).DOB__c;
                        String strMonth;
                        String strDate;
                        if(String.valueof(DOB.month()).length()  ==1)
                            strMonth = '0' + String.valueof(DOB.month());
                        else 
                            strMonth = String.valueof(DOB.month());
                        
                        if(String.valueof(DOB.day()).length()  ==1)
                            strDate = '0' + String.valueof(DOB.day());
                        else 
                            strDate = String.valueof(DOB.day());
                        
                        coApp1.Birthdt = String.valueof(DOB.year()) + strMonth + strDate;
                    }
                    
                    coApp1.Street = appMap.get(appNumber).Mailing_Address_Line_1__c;
                    coApp1.StrSuppl1 = appMap.get(appNumber).Mailing_Address_Line_2__c;
                    coApp1.strSuppl2 = appMap.get(appNumber).Mailing_Address_Line_3__c;
                    coApp1.PostCode = String.valueOf(appMap.get(appNumber).Mailing_Pincode__c);
                    coApp1.City = appMap.get(appNumber).Mailing_City__c;
                    coApp1.Country = appMap.get(appNumber).Mailing_Country__c;
                    // to do check with SAP
                    coApp1.Region  = appMap.get(appNumber).Mailing_State__c;
                    coApp1.Mobile = appMap.get(appNumber).Mobile_Number__c;
                    coApp1.CpReln  = appMap.get(appNumber).Contact_Person_Relationship__c;
                    // map the co applicant number.
                    if(appNumber.equalsIgnoreCase('Second Applicant'))
                        coApp1.CpRole
                        = 'CO-APPLICANT 1';
                    else if(appNumber.equalsIgnoreCase('Third Applicant'))
                        coApp1.CpRole = 'CO-APPLICANT 2';
                    else if(appNumber.equalsIgnoreCase('Fourth Applicant'))
                        coApp1.CpRole = 'CO-APPLICANT 3';
                    else if(appNumber.equalsIgnoreCase('Fifth Applicant'))
                        coApp1.CpRole = 'CO-APPLICANT 4';
                    if(String.isNotBlank(appMap.get(appNumber).PancardNo__c))
                        coApp1.Pan = appMap.get(appNumber).PancardNo__c;
                    if(String.isNotBlank(appMap.get(appNumber).Email_Address__c))
                        coApp1.smtpAddr = appMap.get(appNumber).Email_Address__c;
                    
                    if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Aadhar Card'))
                        coApp1.Aadhar = appMap.get(appNumber).Address_Proof_Number__c;
                    if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Passport'))
                        coApp1.Passport = appMap.get(appNumber).Address_Proof_Number__c;
                    //   if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Driving License'))
                    // populate drivers license in the respective field
                    // coApp1.Aadhar = appMap.get(appNumber).Address_Proof_Number__c;
                    coAppList.Item.add(coApp1);
                    count ++;
                }
            }
            // phone and email of permanent applicant 
            CustomerCreation.TableOfZsdSfdcCustomerComm  commList = new CustomerCreation.TableOfZsdSfdcCustomerComm();
            commList.Item = new List<CustomerCreation.ZsdSfdcCustomerComm>();
            CustomerCreation.ZsdSfdcCustomerComm commItem1 = new CustomerCreation.ZsdSfdcCustomerComm();
            commItem1.Addrcode = '01';
            commItem1.MobileNo  = appMap.get('Primary Applicant').Mobile_Number__c;
            commItem1.SmtpAddr =  appMap.get('Primary Applicant').Email_Address__c;
            commList.item.add(commItem1);
            
            // logger data population
            // Manoj:03-01-2021:Moving to new loggger logic where will will log the request as is without cleanup
            CustomerCreationErrorLogger cLog = new CustomerCreationErrorLogger();
            cLog.customerHeader = customerHeader;
            cLog.customerTaxList = customerTaxList;
            cLog.customerAddressList =customerAddressList;
            cLog.coAppList = coAppList;
            cLog.commList = commList;
           /* CustomerCreationLogger.ZsdSfdcCustomerHd chl = new  CustomerCreationLogger.ZsdSfdcCustomerHd();
            chl.kunnr = customerHeader.kunnr;
            chl.Vkorg = customerHeader.Vkorg;
            chl.Werks = customerHeader.Werks;
            chl.Vtweg = customerHeader.Vtweg;
            chl.Spart= customerHeader.Spart;
            chl.Ktokd= customerHeader.Ktokd;
            chl.Title= customerHeader.Title;
            chl.NameFirst= customerHeader.NameFirst;
            chl.NameLast= customerHeader.NameLast;
            chl.NameMiddle= customerHeader.NameMiddle;
            chl.Langucorr= customerHeader.Langucorr;
            chl.Sort1= customerHeader.Sort1;
            chl.Sort2= customerHeader.Sort2;
            chl.Xsexf= customerHeader.Xsexf;
            chl.Marst= customerHeader.Marst;
            chl.Natio= customerHeader.Natio;
            chl.Jobgr= customerHeader.Jobgr;
            chl.Birthdt= customerHeader.Birthdt;
            chl.Birthpl= customerHeader.Birthpl;
            chl.StaffGrp= customerHeader.StaffGrp;
            chl.Bpext= customerHeader.Bpext;
            chl.Kukla= customerHeader.Kukla;
            chl.Niels= customerHeader.Niels;
            chl.Katr1= customerHeader.Katr1;
            chl.Emplo= customerHeader.Emplo;
            chl.Kvgr1= customerHeader.Kvgr1;
            chl.Kvgr2= customerHeader.Kvgr2;
            chl.Kvgr3= customerHeader.Kvgr3;
            chl.Kvgr4= customerHeader.Kvgr4;
            chl.Kvgr5= customerHeader.Kvgr5;
            chl.Bzirk= customerHeader.Bzirk;
            chl.Vkbur= customerHeader.Vkbur;
            chl.Vkgrp= customerHeader.Vkgrp;
            chl.Kdgrp= customerHeader.Kdgrp;
            chl.Klabc= customerHeader.Klabc;
            chl.Waers= customerHeader.Waers;
            chl.Addrcode= customerHeader.Addrcode;
            
            CustomerCreationLogger.TableOfZsdSfdcCustomerComm  commListLogger = new CustomerCreationLogger.TableOfZsdSfdcCustomerComm();
            commListLogger.Item = new List<CustomerCreationLogger.ZsdSfdcCustomerComm>();
            
            for(CustomerCreation.ZsdSfdcCustomerComm comm1 : commList.Item) {
                CustomerCreationLogger.ZsdSfdcCustomerComm commLogItem1 = new CustomerCreationLogger.ZsdSfdcCustomerComm();
                commLogItem1.Addrcode = comm1.Addrcode;
                commLogItem1.MobileNo  = comm1.MobileNo;
                commLogItem1.SmtpAddr =  comm1.SmtpAddr;
                commListLogger.item.add(commLogItem1);
            }
            
            CustomerCreationLogger.TableOfZsdSfdcCustomerTax customerTaxListlogger = new CustomerCreationLogger.TableOfZsdSfdcCustomerTax();
            customerTaxListlogger.item = new List<CustomerCreationLogger.ZsdSfdcCustomerTax>();
            for(CustomerCreation.ZsdSfdcCustomerTax tax1 : customerTaxList.item) {
                CustomerCreationLogger.ZsdSfdcCustomerTax taxLogLineitem1 = new CustomerCreationLogger.ZsdSfdcCustomerTax();
                taxLogLineitem1.Ind = tax1.Ind;
                taxLogLineitem1.Taxtype = tax1.Taxtype;
                taxLogLineitem1.Taxnumxl = tax1.Taxnumxl;
                customerTaxListlogger.item.add(taxLogLineitem1);
            }
            
            CustomerCreationLogger.TableOfZsdsBpContact  coAppLogList = new CustomerCreationLogger.TableOfZsdsBpContact();
            coAppLogList.Item = new List<CustomerCreationLogger.ZsdsBpContact>();
            for(CustomerCreation.ZsdsBpContact contact1 : coAppList.item) {
                CustomerCreationLogger.ZsdsBpContact contactLog1 = new CustomerCreationLogger.ZsdsBpContact();
                contactLog1.Partner = contact1.Partner;
                contactLog1.Srno = contact1.Srno;
                contactLog1.Title = contact1.Title;
                contactLog1.NameFirst = contact1.NameFirst;
                contactLog1.NameLast = contact1.NameLast;
                contactLog1.NameMiddle = contact1.NameMiddle;
                contactLog1.Xsexf = contact1.Xsexf;
                contactLog1.Marst = contact1.Marst;
                contactLog1.Birthdt = contact1.Birthdt;
                contactLog1.Street = contact1.Street;
                contactLog1.StrSuppl1 = contact1.StrSuppl1;
                contactLog1.StrSuppl2 = contact1.StrSuppl2;
                contactLog1.StrSuppl3 = contact1.StrSuppl3;
                contactLog1.Location = contact1.Location;
                contactLog1.PostCode = contact1.PostCode;
                contactLog1.City = contact1.City;
                contactLog1.Country = contact1.Country;
                contactLog1.Region = contact1.Region;
                contactLog1.Landline = contact1.Landline;
                contactLog1.Mobile = contact1.Mobile;
                contactLog1.FaxNumber = contact1.FaxNumber;
                contactLog1.CpRole = contact1.CpRole;
                contactLog1.CpReln = contact1.CpReln;
                contactLog1.Abtnr = contact1.Abtnr;
                contactLog1.Pafkt = contact1.Pafkt;
                contactLog1.SmtpAddr = contact1.SmtpAddr;
                contactLog1.Pan = contact1.Pan;
                contactLog1.Aadhar = contact1.Aadhar;
                contactLog1.Passport = contact1.Passport;
                coAppLogList.Item.add(contactLog1);
            }
            
            // Mailing, Permanent and Office address of primary applicant
            CustomerCreationLogger.TableOfZsdSfdcCustomerAddress customerAddressLogList = new CustomerCreationLogger.TableOfZsdSfdcCustomerAddress();
            customerAddressLogList.item = new List<CustomerCreationLogger.ZsdSfdcCustomerAddress>();
            for(CustomerCreation.ZsdSfdcCustomerAddress addr1 : customerAddressList.item) {
                CustomerCreationLogger.ZsdSfdcCustomerAddress addrLog1 = new CustomerCreationLogger.ZsdSfdcCustomerAddress();
                addrLog1.Addrcode = addr1.Addrcode;
                addrLog1.Seqno = addr1.Seqno;
                addrLog1.NameCo = addr1.NameCo;
                addrLog1.Street = addr1.Street;
                addrLog1.StrSuppl1 = addr1.StrSuppl1;
                addrLog1.StrSuppl2 = addr1.StrSuppl2;
                addrLog1.StrSuppl3 = addr1.StrSuppl3;
                addrLog1.Location = addr1.Location;
                addrLog1.PostCode = addr1.PostCode;
                addrLog1.City = addr1.City;
                addrLog1.Country = addr1.Country;
                addrLog1.Region = addr1.Region;
                customerAddressLogList.item.add(addrLog1);
            }
            CustomerCreationLogger.ZsdSfdcCustomer_element ccRequestLog = new CustomerCreationLogger.ZsdSfdcCustomer_element();
            ccRequestLog.CustomerAddress = customerAddressLogList;
            ccRequestLog.CustomerComm = commListLogger;
            ccRequestLog.CustomerContact = coAppLogList;
            ccRequestLog.CustomerHeader = chl;
            ccRequestLog.CustomerTax = customerTaxListlogger;
            // logger ends here.
*/
    
            CustomerCreation.TableOfBapiret2 bapiRet2List = new CustomerCreation.TableOfBapiret2();
            bapiRet2List.item = new List<CustomerCreation.Bapiret2>();
            CustomerCreation.Bapiret2 bapiItem = new CustomerCreation.Bapiret2();
            bapiItem.Type_x ='';
            bapiItem.Id  ='';
            bapiItem.Number_x ='';
            bapiItem.Message ='';
            bapiItem.LogNo ='';
            bapiItem.LogMsgNo ='';
            bapiItem.MessageV1 ='';
            bapiItem.MessageV2 ='';
            bapiItem.MessageV3 ='';
            bapiItem.MessageV4 ='';
            bapiItem.Parameter ='';
            bapiItem.Row =0;
            bapiItem.Field ='';
            bapiItem.System_x ='';
            
            bapiRet2List.item.add(bapiItem);
            CustomerCreationLogger.ZsdSfdcCustomerResponse_element responseLog = new CustomerCreationLogger.ZsdSfdcCustomerResponse_element();
            responseLog.Return_x  = new CustomerCreationLogger.TableOfBapiret2();
            responseLog.Return_x.item = new List<CustomerCreationLogger.Bapiret2>();
              Boolean callOutError = false;
            String exceptionMsg = '';
            Boolean ExceptionError = false;
            try {
                CustomerCreation.ZSD_SFDC_CUSTOMER customerCreation = new CustomerCreation.ZSD_SFDC_CUSTOMER();
                system.debug(JSON.serialize(customerAddressList));
                system.debug(JSON.serialize(commList));
                system.debug(JSON.serialize(coAppList));
                system.debug(JSON.serialize(customerAddressList));
                system.debug(JSON.serialize(customerHeader));
                system.debug(JSON.serialize(customerTaxList));
                CustomerCreation.ZsdSfdcCustomerResponse_element customerCreationResponse = customerCreation.ZsdSfdcCustomer(customerAddressList,commList, coAppList,customerHeader,customerTaxList, bapiRet2List);
                System.debug('Customer creation response:' + customerCreationResponse.Customerno);
                if(customerCreationResponse != null && customerCreationResponse.Return_x != null && customerCreationResponse.Return_x.item != null ) {
                    for(CustomerCreation.Bapiret2 returnMsg :  customerCreationResponse.Return_x.item) {
                        CustomerCreationLogger.Bapiret2 msgLogLine = new CustomerCreationLogger.Bapiret2();
                        msgLogLine.Type_x = returnMsg.Type_x;
                        msgLogLine.Id = returnMsg.Id;
                        msgLogLine.Number_x = returnMsg.Number_x;
                        msgLogLine.Message = returnMsg.Message;
                        msgLogLine.LogNo = returnMsg.LogNo;
                        msgLogLine.LogMsgNo = returnMsg.LogMsgNo;
                        msgLogLine.MessageV1 = returnMsg.MessageV1;
                        msgLogLine.MessageV2 = returnMsg.MessageV2;
                        msgLogLine.MessageV3 = returnMsg.MessageV3;
                        msgLogLine.MessageV4 = returnMsg.MessageV4;
                        msgLogLine.Parameter = returnMsg.Parameter;
                        msgLogLine.Row = returnMsg.Row;
                        msgLogLine.Field = returnMsg.Field;
                        msgLogLine.System_x= returnMsg.System_x;
                        
                        responseLog.Return_x.item.add(msgLogLine);
                    }
                }
                
                if(customerCreationResponse != null &&  customerCreationResponse.Customerno != null && customerCreationResponse.Customerno != '') {
                    responseLog.Customerno = customerCreationResponse.Customerno;
                    customerNumber = customerCreationResponse.Customerno;
                    
                } else {
                    callOutError = true;
                    exceptionMsg = 'Customer number # not received';
                    
                }
            } catch (Exception ex) {
                System.debug('Exception:' + ex.getMessage());
                callOutError = true;
                                ExceptionError = true;
                exceptionMsg = ex.getMessage();
            } finally {
                System.debug('JSON Logger request:' + JSON.SerializePretty(cLog));
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                String requestF = JSON.SerializePretty(cLog);
           //     requestF =  requestF.replaceAll('&quot;','"');
               // requestF  = requestF.replaceAll('\t', '&nbsp;');
                log.request__c = requestF;
                log.API_name__c = 'Customer Creation/Update';
                log.Booking__c = bookingId;
                log.Opportunity__c = oppId;
                String responseF = JSON.SerializePretty(responseLog);
                responseF =  responseF.replaceAll('\n','<br/>');
                responseF  = responseF.replaceAll('\t', '&nbsp;');
                log.response__c = responseF;
                if(!callOutError) {
                    log.Status__c = 'Success';
                    
                } else {
                     log.Status__c = 'Failure';
                    if(exceptionError){
                        log.Error_Type__c='Timeout Error';
                    }else{
                        log.Error_Type__c='Data Error';
                    }
                   
                    log.Error_Reason__c = exceptionMsg;
                }
                erpLogList.add(log);
            }
        }
        return customerNumber;
    }
    //manoj 17-0-2020 commenting as we have real time api
  /*  public static List<CanReqWrapper> pollForCancellationRequests(DateTime strTimeStamp){
        Boolean callOutError = false;
        String exceptionMsg = '';
        String timeStamp;
        String tempTimeStamp = '';
        system.debug('incoming timestamp::'+strTimeStamp);
        // Input will be time stamp (YYYYMMDDhhmmss)
        tempTimeStamp = strTimeStamp.format('yyyyMMddhhmmss');
        system.debug('formatted timestamp::'+tempTimeStamp);
        //timestamp = '20181011000000';
        timestamp = tempTimeStamp;
        CancellationTransfer1.ZSD_SFDC_SALES_ORDER_CAN_TRF cancelTransfer = new CancellationTransfer1.ZSD_SFDC_SALES_ORDER_CAN_TRF();
        CancellationTransfer1.ZsdtSfdcSoCf ELogReq = new CancellationTransfer1.ZsdtSfdcSoCf();
        ELogReq.item = new List<CancellationTransfer1.ZsdSfdcSoCf>();
        cancellationtransfer1.ZsdtSfdcSoCf canTraResponse = new cancellationtransfer1.ZsdtSfdcSoCf();
        List<CanReqWrapper> CanReqWrapperList;
        try {
            canTraResponse = cancelTransfer.ZsdSfdcSalesOrderCanTrf(ELogReq, timestamp);
            System.debug('cancellation transfer response:' + canTraResponse);
            CanReqWrapperList = new List<CanReqWrapper>();
            if(canTraResponse != null &&  canTraResponse.item != null && canTraResponse.item.size() > 0) {
                // this means we have received requests from SAP, go through each one of them and perform actions in salesforce.
                for(CancellationTransfer1.ZsdSfdcSoCf cRequest :canTraResponse.item) {
                    System.debug('Requests received:' + cRequest);
                    CanReqWrapper c = new CanReqWrapper();
                    c.Mandt= cRequest.Mandt;
                    c.SalesOrder = cRequest.SalesOrder;
                    c.Timestamp = cRequest.Timestamp;
                    c.CancelReason = cRequest.CancelReason;
                    c.CancelDate = cRequest.CancelDate;
                    c.UnitStatus = cRequest.UnitStatus;
                    c.Type_x = cRequest.Type_x;
                    CanReqWrapperList.add(c);
                }
                if(CanReqWrapperList != null && CanReqWrapperList.size() > 0) {
                    //processCancellation(CanReqWrapperList);
                    return CanReqWrapperList;
                }
                
            } else {
                exceptionMsg = 'No cancellations requests received in this batch:' + timeStamp;
            }
        } catch (Exception ex) {
            System.debug('Exception:' + ex.getMessage());
            callOutError = true;
            exceptionMsg = ex.getMessage();
        } finally {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            String requestF = timeStamp;
            log.request__c = requestF;
            log.API_name__c = 'Cancellation Request Poll';
            String responseF = JSON.SerializePretty(canTraResponse);
            responseF =  responseF.replaceAll('\n','<br/>');
            responseF  = responseF.replaceAll('\t', '&nbsp;');
            log.response__c = responseF;
            if(!callOutError) {
                log.Status__c = 'Success';
                
            } else {
                log.Status__c = 'Failure';
                log.Error_Reason__c = exceptionMsg;
            }
            erpLogList.add(log);
            insert erpLogList;
        }
        return CanReqWrapperList;
    }
    public static void processCancellation(List<CanReqWrapper> canList) {
        System.debug('Cancellation Request:' + canList);
        List<Opportunity> oppUpdatelist = new List<Opportunity>();
        List<Project_Unit__c> unitUpdateList = new List<Project_Unit__c>();
        List<Booking__c> bookingUpdateList = new List<Booking__c>();
        List<ERP_Integration_Log__c> logInsertList = new List<ERP_Integration_Log__c>();
        List<Opportunity> optyClonedList = new List<Opportunity>();
        for(CanReqWrapper cw : canList) {
            ERP_Integration_Log__c eil = new ERP_Integration_Log__c();
            result r = new result();
            
            String requestStr = 'SONumber: '+cw.SalesOrder + ' cancellationReason: ' + cw.CancelReason + ' cancellationDate: ' + cw.CancelDate 
                + ' unitStatus: '+cw.UnitStatus + ' Type:' + cw.Type_x + ' Timestamp:' +  cw.Timestamp;
            String jsonRespStr = '';
            eil.Request__c = requestStr;
            eil.API_Name__c = 'Salesorder Edit';
            
            List<Opportunity> oList = [Select Id, SalesOrder_Number__c, RW_Project_Unit__c, Booking__c from Opportunity where SalesOrder_Number__c =: cw.SalesOrder];
            List<Booking__c> bookingList = new List<Booking__c>();
            if(oList != null) {
                if(oList.size() == 1) {
                    if(oList[0].RW_Project_Unit__c != null) {
                        List<Project_Unit__c> uList = [Select Id , RW_Unit_Status__c from Project_Unit__c where Id =: oList[0].RW_Project_Unit__c];
                        if(oList[0].Booking__c != null)
                            bookingList = [Select Id , Customer_Name__c, Date_of_Cancellation__c, Reason_For_Cancellation__c,Status__c
                                           from Booking__c where Id =: oList[0].Booking__c];
                        if(uList != null && uList.size() == 1) {
                            try {
                                uList[0].RW_Unit_Status__c = cw.unitStatus; //changes made by Tejaswini
                                oList[0].StageName = 'Cancelled';
                                oList[0].RW_Reason_for_Cancellation__c = cw.CancelReason;  
                                if(bookingList != null && bookingList.size() == 1) {
                                    bookingList[0].Status__c = 'Cancelled';
                                    bookingList[0].Reason_For_Cancellation__c = cw.CancelReason;
                                    if(!String.isBlank(cw.CancelDate) && cw.CancelDate != null)
                                        bookingList[0].Date_of_Cancellation__c = Date.valueOf(cw.CancelDate);
                                    System.debug('Booking Id: '+bookingList[0].Id+' Booking Status__c:'+bookingList[0].Status__c+
                                                 ' bookingList[0].Reason_For_Cancellation__c: '+bookingList[0].Reason_For_Cancellation__c +
                                                 ' bookingList[0].Date_of_Cancellation__c: '+ bookingList[0].Date_of_Cancellation__c);
                                }
                                // Added by Shailesh to clone opportunity if Type is "Transfer"
                                if(cw.Type_x.equalsIgnoreCase('TRA')) {
                                    Opportunity optytobeCloned = [Select Id,Name,AccountId,RW_Project__c,RW_Email__c,RW_Mobile_No__c,LeadSource,SAP_Customer_Number__c, Walkin_Source__c,Walkin_sub_sub_source__c,RW_Walkin_Channel_Partner__c,Walk_in_Corporate__c,Name_of_Unregistered_Corporate__c,RW_Walkin_Reference_Source__c,RW_Walkin_Customer_Reference__c,Name_Of_Walkin_Referee__c from Opportunity
                                                                  where Id =: oList[0].Id];
                                    optyClonedList.add(optytobeCloned);
                                }
                                oppUpdatelist.add(oList[0]);
                                unitUpdateList.add(uList[0]);
                                if(bookingList != null && bookingList.size() == 1)
                                    bookingUpdateList.add(bookingList[0]);
                                
                                r.returnCode = 0;
                                r.message = 'Sales Order cancel request has been processed successfully';
                                
                                jsonRespStr = Json.serialize(r);
                                eil.Response__c = jsonRespStr;
                                eil.Opportunity__c = oList[0].Id;
                                if(oList[0].Booking__c != null)
                                    eil.Booking__c = oList[0].Booking__c;
                                eil.Status__c = 'Success';
                                logInsertList.add(eil);
                            } catch (Exception ex) {
                                r.returnCode = 1;
                                r.message = 'Error occurred while processing this request:' + ex.getMessage();
                                jsonRespStr = Json.serialize(r);
                                eil.Response__c = jsonRespStr;
                                eil.Opportunity__c = oList[0].Id;
                                if(oList[0].Booking__c != null)
                                    eil.Booking__c = oList[0].Booking__c;
                                eil.Status__c = 'Failure';
                                eil.Error_Reason__c = r.message;
                                logInsertList.add(eil);
                            }
                        } else {
                            r.returnCode = 1;
                            r.message = 'Invalid Unit on Opportunity -1, Please contact Administrator';
                            jsonRespStr = Json.serialize(r);
                            eil.Response__c = jsonRespStr;
                            eil.Opportunity__c = oList[0].Id;
                            if(oList[0].Booking__c != null)
                                eil.Booking__c = oList[0].Booking__c;
                            eil.Status__c = 'Failure';
                            eil.Error_Reason__c = r.message;
                            logInsertList.add(eil);
                        }
                    } else {
                        r.returnCode = 1;
                        r.message = 'Invalid Unit on Opportunity -2, Please contact Administrator';
                        jsonRespStr = Json.serialize(r);
                        eil.Response__c = jsonRespStr;
                        eil.Opportunity__c = oList[0].Id;
                        if(oList[0].Booking__c != null)
                            eil.Booking__c = oList[0].Booking__c;
                        eil.Status__c = 'Failure';
                        eil.Error_Reason__c = r.message;
                        logInsertList.add(eil);
                    }
                } else {
                    r.returnCode = 1;
                    r.message = 'Invalid Sales Order Number -1';
                    jsonRespStr = Json.serialize(r);
                    eil.Response__c = jsonRespStr;
                    eil.Status__c = 'Failure';
                    eil.Error_Reason__c = r.message;
                    logInsertList.add(eil);
                }
            } else {
                r.returnCode = 1;
                r.message = 'Invalid Sales Order Number -2';
                jsonRespStr = Json.serialize(r);
                eil.Response__c = jsonRespStr;
                eil.Status__c = 'Failure';
                eil.Error_Reason__c = r.message;
                logInsertList.add(eil);
            }
        }
        if(!oppUpdateList.isEmpty() && oppUpdateList.size() > 0)
            update oppUpdateList;
        
        if(!unitUpdateList.isEmpty() && unitUpdateList.size() > 0)
            update unitUpdateList;
        
        if(!bookingUpdateList.isEmpty() && bookingUpdateList.size() > 0)
            update bookingUpdateList;
        
        if(!optyClonedList.isEmpty() && optyClonedList.size() > 0) {
            List<Opportunity> oClonedListToInsert = new List<Opportunity>();
            for(Opportunity o : optyClonedList) {
                Opportunity oCloned = new Opportunity();
                oCloned = o.clone(false, false, false, false);
                oCloned.stageName = 'Qualification';
                oClonedListToInsert.add(oCloned);
            }
            if(!oClonedListToInsert.isEmpty() && oClonedListToInsert.size() > 0)
                insert oClonedListToInsert;
        }
        
        if(!logInsertList.isEmpty() && logInsertList.size() > 0)
            insert logInsertList;
    }
    
    public class CanReqWrapper {
        public String Mandt;
        public String SalesOrder;
        public String Timestamp;
        public String CancelReason;
        public String CancelDate;
        public String UnitStatus;
        public String Type_x;
        
    }
    public class result {
        public Integer returnCode;
        public String message;
    }  */
}