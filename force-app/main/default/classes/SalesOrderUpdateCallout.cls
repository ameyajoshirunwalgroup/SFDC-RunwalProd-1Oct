public class SalesOrderUpdateCallout {
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    
    public static void UpdateSO(Set<Id> oIdSet) {
        String customerNumber;
        String SONumber;
        system.debug('MK');
        // Added RW_Project_Unit__r.Booking__c in the query by Tejaswini
        List<Opportunity> oList  = [Select Id,StageName, SAP_Customer_Number__c,SalesOrder_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet];
        system.debug(oList);
        // check if customer is present, if not call CC API and SO API.
        if(oList.size()>0 && oList[0].SAP_Customer_Number__c!=null && oList[0].SalesOrder_Number__c!=null){
          system.debug(oList[0].StageName );
            if(oList[0].StageName == 'Cancelled' || oList[0].StageName =='Booking Cancelled – Refund Pending'){
                cancelsalesorder(oIdSet);
            }else{
                updatesalesorder(oIdSet,oList[0].SAP_Customer_Number__c);
            }
        }else
        {
           	 SAPIntegrationServices.createSO(oIdSet);
        }
        
        
    }
    @future (callout=true)
    public Static void updatesalesorder(Set<Id> oIdSet, String cNo){
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
        List<Opportunity> oList  = [Select Id,SalesOrder_Number__c, SAP_Customer_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Walkin_Channel_Partner__c, Walkin_Source__c,RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet]; 
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
        List<Project__c> pRec = [Select Id, Name,Brokerage__c, Project_Property_Type__c,Sales_District__c, allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c,allotment_charges_8__c, Allotment_Charges_9__c from Project__c where Id = : oList[0].RW_Project__c];
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
            system.debug(tRec);
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
            bList = [Select Id,Status__c,RW_Cancellation_initiated_by__c,Cancellation_Sub_reason__c,Cancellation_Reason__c	, Booking_Date__c,Funding_Status__c, Source_Of_Booking__c, Name,RW_Last_SDR_Received__c, CreatedDate,
                  RW_Index_2__c,   RW_Registration_Date__c,RW_BRL_Number__c,RW_Release_of_Charge_issue_status__c,RW_ROC_Date__c,RW_Signed_Agreement_to_Customer_Date__c, ADF_Opted__c, //added by digicloud
                     RW_Actual_Possession_Date__c,RW_Agreement_Possession_Date__c	,Date_for_offer_of_Possession__c, Project__r.Name, Interest_to_be_Applied__c, 
                    RW_Noc_Generated_Date__c,RW_Loan_Sanction_Date__c, RW_Loan_Account_Number__c,RW_Loan_Amount__c,RW_Loan_Bank__c,Loan_Bank__c,RW_Nominee_Name__c	,Date_of_Occupation_Certificate__c	,Date_of_Cancellation__c,RW_Key_handover_date__c
                     
                     from Booking__c where Id = : bookingId];
        }
        // quotation check
        if(oList[0].Booking__r.Quotation__c == null) {
            if(bList[0].Project__r.Name == 'Runwal MyCity' && bList[0].CreatedDate < Date.valueOf('2023-04-01')){ // Added by coServe 06-11-2023  Changed RW_Registration_Date__c by CreatedDate by Vinay 10-07-2025
                
            }else{
                dataError = true;
                errMsg = 'Quotation not present,';
            }
            
        } else {
            quoteId = oList[0].Booking__r.Quotation__c;
            qList = [Select Id, Name, Total_Discount_L__c, Customer_Total_Discount_L__c, Discount_1_Type__c, Discount_1_PSF__c, Discount_1_L__c, Premium_Charges_Description_1__c, Premium_Charges_ST_1__c, Premium_Charges_Amount_1__c,CAM_Charges__c,BCAM_Charges__c,No_of_parking__c from Quotation__c where Id = :quoteId];
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
                    dataError = true;
                    errMsg += g.Name + ' doesnot have a  SAP Material Code,';
                }
                
                if(g.Name == 'Basic') {
                    if(g.SAP_material_Type__c == null) {
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
            log.Error_Type__c = 'Data Error';
            erpLogList.add(log);
        }    
        else if(!dataError){
            
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
            //orderHeader.ZzpossStrDt = String.ValueOf(bList[0].RW_Actual_Possession_Date__c);
             // added by digicloud for ADF Option
            if(bList[0].ADF_Opted__c == true){
                orderHeader.ADF_OPTION = 'Y';
            }else{
                orderHeader.ADF_OPTION = 'N';
            }
 //orderHeader.AdfOption = 'Y';
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
            if(bList[0].RW_Release_of_Charge_issue_status__c == 'Received'){
                orderHeader.ZZROC_ST = 'X';
            }
            if(bList[0].Funding_Status__c == 'Self Funded'){
                orderHeader.ZZPAY_MODE = '1';
            }else if(bList[0].Funding_Status__c == 'Loan Bank'){
                orderHeader.ZZPAY_MODE = '2';
            }else if(bList[0].Funding_Status__c == 'Not decided'){
                orderHeader.ZZPAY_MODE = '3';
            }
            orderHeader.ZZLOAN_BD = bList[0].RW_Loan_Bank__c; //Added by coServe 13-09-2023
            //orderHeader.ZzloanBd = bList[0].Loan_Bank__c; //commented by coServe 13-09-2023
                orderHeader.ZZLOAN_AMT = String.valueOf(bList[0].RW_Loan_Amount__c);
                orderHeader.ZZLOAN_FILE_NO = String.valueOf(bList[0].RW_Loan_Account_Number__c);//Added String.valueOf on 09-08-2022
            orderHeader.ZZSANCTION_DT  =String.valueOf(bList[0].RW_Loan_Sanction_Date__c) ;
            orderHeader.ZZNOC_ISS_DT=String.valueOf(bList[0].RW_Noc_Generated_Date__c) ;
          /*  if (bList[0].Status__c =='Booking Cancelled – Refund Pending'||  bList[0].Status__c =='Cancelled'){
                if (bList[0].Cancellation_Reason__c == 'Unit transfer'){
                    orderHeader.RejReason='Z8';
                }else{	
                    
                    orderHeader.RejReason = bList[0].Cancellation_Sub_reason__c;
                }
                            orderHeader.ZzcanlInitBy = bList[0].RW_Cancellation_initiated_by__c;
            orderHeader.ZzcanlDt = String.ValueOf(system.today());

            }*/
            orderHeader.ZZMKT_VAL = String.valueOf(bList[0].RW_Index_2__c);
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
            orderHeaderLog.DocDate = orderHeader.DocDate;
            */
            Integer seqNo = 10;
            Integer count = 1;
            // order line items table - its a list of order lines
            SalesOrderSAPAPIMCS.TableOfZsdstOrderItem orderItemsList = new SalesOrderSAPAPIMCS.TableOfZsdstOrderItem();
            orderItemsList.item = new List<SalesOrderSAPAPIMCS.ZsdstOrderItem>();
            
            // order conditions - its a list of order conditions
            SalesOrderSAPAPIMCS.TableOfZsdstCondition orderConditionsList = new SalesOrderSAPAPIMCS.TableOfZsdstCondition();
            orderConditionsList.item = new List<SalesOrderSAPAPIMCS.ZsdstCondition>();
            
       
            // populate the logger
        /*    SalesOrderLogger.TableOfZsdstOrderItem orderItemsLogList = new SalesOrderLogger.TableOfZsdstOrderItem();
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
        //    SalesOrderLogger.TableOfZsdstPartnerFunction partnerFunctionLogList = new SalesOrderLogger.TableOfZsdstPartnerFunction();
        //    SalesOrderLogger.ZsdstPartnerFunction partnerFunctionLog1 = new SalesOrderLogger.ZsdstPartnerFunction();
            
            /*   if(oList[0].Walkin_Source__c != null && oList[0].Walkin_Source__c.equalsIgnoreCase('Channel Partner')) {
List<Broker__c> cpList = new List<Broker__c>();
cpList = [Select Id, Name, SAP_CP_Code__c from Broker__c where Id = : oList[0].RW_Walkin_Channel_Partner__c ];
if(!cpList.isEmpty() && cpList.size() ==1 && String.isNotBlank(cpList[0].SAP_CP_Code__c )) {
// partner function table - its a list of partner functions

partnerFunction1.PartnRole = 'ZB';
partnerFunction1.PartnNumb = cpList[0].SAP_CP_Code__c;

partnerFunctionList.item = new List<SalesOrderSAPAPIMCS.ZsdstPartnerFunction>();
partnerFunctionList.item.add(partnerFunction1);

// partner function logging - its a list of partner functions
partnerFunctionLog1.PartnRole = 'ZB';
partnerFunctionLog1.PartnNumb = cpList[0].SAP_CP_Code__c;

partnerFunctionLogList.item = new List<SalesOrderLogger.ZsdstPartnerFunction>();
partnerFunctionLogList.item.add(partnerFunctionLog1);

// order condition for parking charges
SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
orderCondition.ItmNumber = '10';
if(pRec[0].Brokerage__c != null )
orderCondition.condValue = String.valueOf(pRec[0].Brokerage__c);
else
orderCondition.condValue = '0';
orderCondition.CondType = 'ZBRK';
orderConditionsList.item.add(orderCondition);
}

}*/
            // order line conditions for logging
            SalesOrderLogger.TableOfZsdstCondition orderConditionsLogList = new SalesOrderLogger.TableOfZsdstCondition();
            orderConditionsLogList.item = new List<SalesOrderLogger.ZsdstCondition>();
            /*  for( SalesOrderSAPAPIMCS.ZsdstCondition oLine :  orderConditionsList.item) {
SalesOrderLogger.ZsdstCondition  orderLogCondition = new SalesOrderLogger.ZsdstCondition();
orderLogCondition.ItmNumber = oLine.ItmNumber;
orderLogCondition.CondType = oLine.CondType;
orderLogCondition.CondValue = oLine.CondValue;
orderConditionsLogList.item.add(orderLogCondition);
}*/
            SalesOrderSAPAPIMCS.TableOfZsdstBillPlan billPlanList = new SalesOrderSAPAPIMCS.TableOfZsdstBillPlan();
            billPlanList.item = new List<   SalesOrderSAPAPIMCS.ZsdstBillPlan>();
            /*
List<Standard_Customer_Pay_Plan_Detail__c> payPlanList = [Select id,RW_SAP_Milestone_Code__c,Payment_Milestone__c,Installment__c,Due_Date__c,Milestone_Percentage__c	 from Standard_Customer_Pay_Plan_Detail__c	 where Customer_Pay_Plan_Header__c=:BasicCPPHId];
for(Standard_Customer_Pay_Plan_Detail__c sp :payPlanList){
SalesOrderSAPAPIMCS.ZsdstBillPlan billPlan = new SalesOrderSAPAPIMCS.ZsdstBillPlan();
billPlan.ItmNumber =string.valueOf(BasicPlanSequenceNo);
billPlan.BillDate = String.valueOf(sp.Due_Date__c);
billPlan.Usage=sp.RW_SAP_Milestone_Code__c;
billPlan.InvPer =string.valueOf(sp.Milestone_Percentage__c.setscale(2));
billPlan.BillValue =string.valueOf( sp.Installment__c);
billPlanList.item.add(billPlan);
}*/
            
            SalesOrderSAPAPIMCS.TableOfBapiret2 bapiRet2List = new SalesOrderSAPAPIMCS.TableOfBapiret2();
            bapiRet2List.item = new List<SalesOrderSAPAPIMCS.Bapiret2>();
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
            // SalesOrderLogger.ZsdSdfcSalesOrderLogger_element SOLogger = new SalesOrderLogger.ZsdSdfcSalesOrderLogger_element();
           SalesOrderErrorLogger SOLogger  = new SalesOrderErrorLogger();
            
            SOLogger.OrderHeader = OrderHeader;
            SOLogger.OrderItemsList = OrderItemsList;
            SOLogger.orderConditionsList = orderConditionsList;
            SOLogger.partnerFunctionList = partnerFunctionList;
            SOLogger.CustomerNumber = CustomerNumber;
            SOLogger.billPlanList=billPlanList;
            Boolean callOutError = false;
            String exceptionMsg = '';
            Boolean exceptionError = false;
            SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element salesOrderResponse;
            
            SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element responseLog = new SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element();
            responseLog.Return_x  = new SalesOrderLogger.TableOfBapiret2();
            responseLog.Return_x.item = new List<SalesOrderLogger.Bapiret2>();
            
            try {
                system.debug(json.serialize(billPlanList));
                system.debug(json.serialize(CustomerNumber));
                
                // system.debug(json.serialize(orderConditionsList));
                system.debug(json.serialize(orderHeader));
                
                system.debug(json.serialize(partnerFunctionList));

                salesOrderResponse = salesorder1.ZsdSdfcSalesOrder(billPlanList,CustomerNumber, orderConditionsList, orderHeader, orderItemsList, partnerFunctionList, bapiRet2List);
                system.debug(JSON.serialize(salesOrderResponse));
                system.debug(salesOrderResponse.Salesdocument+'salesOrderResponse.Salesdocument;');
                system.debug(salesOrderResponse.GstPerc+'salesOrderResponse.GstPerc;');
                //system.debug(salesOrderResponse.Status+'salesOrderResponse.Status;');
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
                System.debug('JSON Logger request:' + JSON.SerializePretty(SOLogger));
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                
                String requestF = JSON.SerializePretty(SOLogger);
                requestF =  requestF.replaceAll('&quot;','"');
           //     requestF  = requestF.replaceAll('\t', '&nbsp;');
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
               //  insert log;
            }
            
        }
        insert erpLogList;
    }
    
      @future (callout=true)
        public Static void cancelsalesorder(Set<Id> oIdSet){
        String cNo;
        String SONumber;
        Boolean dataError = false;
        Id oppId;
        List<Booking__c>  bList  = new List<Booking__c>();
        String errMsg ='';
        // Added RW_Project_Unit__r.Booking__c by Tejaswini in the query
        
        List<Opportunity> oList  = [Select Id,Name,SalesOrder_Number__c, SAP_Customer_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Walkin_Channel_Partner__c, Walkin_Source__c,RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet]; 
        
        system.debug(oList);
        system.debug(oList[0].SalesOrder_Number__c);
        //opportunity check
        //
        system.debug(oList);
        if(oList == null || oList.size() == 0 || oList.size() > 1) {
            dataError = true;
            errMsg = 'Invalid Opportunity,';
        } else {
            cNo = oList[0].SAP_Customer_Number__c;
            oppId = oList[0].Id;
        }
        // customer # check
        if(cNo == null) {
            dataError = true;
            errMsg += 'Customer number not present,';
        }  
              if(dataError) {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'Sales Order';
            log.Booking__c = oList[0].RW_Project_Unit__r.Booking__c;
            log.Opportunity__c = oList[0].Id;
            log.Status__c = 'Not Processed';
            log.Error_Reason__c = errMsg;
            log.Error_Type__c = 'Data Error';
            erpLogList.add(log);
        }  else{
            integer BasicPlanSequenceNo;
            String BasicCPPHId ;
            // Order Header
           SalesOrderSAPAPIMCS.ZsdstOrderHeader orderHeader = new SalesOrderSAPAPIMCS.ZsdstOrderHeader(); 


            // Changes made to take Property type from tower level instead of Project on 10-10-2020 By Shailesh
            String     bookingId = oList[0].Booking__c;
            bList = [Select Id,Cancellation_approved_date__c,RW_Index_2__c,RW_Cancellation_initiated_by__c,Status__c,Cancellation_Sub_reason__c,Cancellation_Reason__c	, Booking_Date__c,Funding_Status__c, Source_Of_Booking__c, Name,RW_Last_SDR_Received__c,
                     RW_Registration_Date__c,RW_BRL_Number__c,RW_Release_of_Charge_issue_status__c,RW_ROC_Date__c,RW_Signed_Agreement_to_Customer_Date__c,
                   Cancellation_initiation_date__c,  Project__c,  Unit_No__c,Quotation__c, RW_Actual_Possession_Date__c,RW_Agreement_Possession_Date__c	,Date_for_offer_of_Possession__c,
                     RW_Nominee_Name__c	,Date_of_Occupation_Certificate__c	,Date_of_Cancellation__c,RW_Key_handover_date__c, ADF_Opted__c                    
                     from Booking__c where Id = : bookingId];
            
            String quoteId = bList[0].Quotation__c;
            List<Quotation__c>      qList = [Select Id, Name,PaymentPlan__r.name, Total_Discount_L__c, Customer_Total_Discount_L__c, Discount_1_Type__c, Discount_1_PSF__c, Discount_1_L__c, Premium_Charges_Description_1__c, Premium_Charges_ST_1__c, Premium_Charges_Amount_1__c,CAM_Charges__c,BCAM_Charges__c,Total_No_of_Parking__c	 from Quotation__c where Id = :quoteId];
            
            String unitId = bList[0].Unit_No__c;
            List<Project_Unit__c>     uList = [Select Id, Name,Unit_SAP_Code__c,Saleable_Area__c, Carpet_area__c from Project_Unit__c where Id = :unitId];
            List<Project__c> pRec = [Select Id, Name,Brokerage__c, Project_Property_Type__c,Sales_District__c, allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c,allotment_charges_7__c,allotment_charges_8__c,Allotment_Charges_9__c,Stack_Car_Park_Charges__c from Project__c where Id = : bList[0].Project__c];
            List<Project_Charges__c> pList = new List<Project_Charges__c>();
            pList = [Select Id, Name, Charge_Code__c, S_Charge_Bucket__c from Project_charges__c where Project__c = :pRec[0].Id];
            
            
            
            
            Set<Id> GlobalChargesSet = new Set<Id>();
            
            for(Project_Charges__c p : pList) {
                if(p.S_Charge_Bucket__c.equals('Other Charges') || p.Name.equalsIgnoreCase('Basic') ||  p.Name.equalsIgnoreCase('Allotment Charges'))
                    GlobalChargesSet.add(p.Charge_Code__c);
            }              
            
            List<Global_Charges__c> glList = [Select Id, Name, SAP_Material_Code__C, SAP_Condition_Type__c, SAP_material_Type__c from Global_Charges__c where Id in :GlobalChargesSet];
            
            Map<String, Global_Charges__c> globalChargesMap = new Map<String, Global_Charges__c>();
            for(Global_Charges__c g : glList) {
                globalChargesMap.put(g.Name, g);
            }
            orderHeader.DIVISION= '00';
            orderHeader.SALES_GRP = '';
            orderHeader.SALES_OFF= '';
            orderHeader.PURCH_NO_C= bList[0].Name;
            orderHeader.PO_DAT_S = '';
            orderHeader.DOC_DATE = '';
            orderHeader.SALES_ORD_NO=oList[0].SalesOrder_Number__c;
            //orderHeader.ZzpossStrDt = String.ValueOf(bList[0].RW_Actual_Possession_Date__c);
             // added by digicloud for ADF Option
            if(bList[0].ADF_Opted__c == true){
                orderHeader.ADF_OPTION = 'Y';
            }else{
                orderHeader.ADF_OPTION = 'N';
            }
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
            if(bList[0].RW_Release_of_Charge_issue_status__c == 'Received'){
                orderHeader.ZZROC_ST = 'X';
            }
            if(bList[0].Funding_Status__c == 'Self Funded'){
                orderHeader.ZZPAY_MODE = '1';
            }else if(bList[0].Funding_Status__c == 'Loan Bank'){
                orderHeader.ZZPAY_MODE = '2';
            }else if(bList[0].Funding_Status__c == 'Not decided'){
                orderHeader.ZZPAY_MODE = '3';
            }
            system.debug( bList[0].Status__c);
            if (bList[0].Status__c =='Booking Cancelled – Refund Pending'||  bList[0].Status__c =='Cancelled' || bList[0].Status__c == 'Cancellation Initiated'){
                           orderHeader.ZZCANL_INIT_BY = bList[0].RW_Cancellation_initiated_by__c;
            orderHeader.ZZCANL_DT = String.ValueOf( bList[0].Cancellation_approved_date__c);

                if (bList[0].Cancellation_Reason__c == 'Unit transfer'){
                    orderHeader.REJ_REASON='Z8';
                }else{	
                    
                    orderHeader.REJ_REASON = bList[0].Cancellation_Sub_reason__c;
                }
            }
            orderHeader.ZZMKT_VAL = String.valueOf(bList[0].RW_Index_2__c);
          //  orderHeader.ZzcanlDt = String.valueOf(bList[0].Cancellation_initiation_date__c);
            system.debug(  orderHeader.REJ_REASON);
            // Order Header for logging
      
            Integer seqNo = 10;
            Integer count = 1;
            // order line items table - its a list of order lines
            SalesOrderSAPAPIMCS.TableOfZsdstOrderItem orderItemsList = new SalesOrderSAPAPIMCS.TableOfZsdstOrderItem();
            orderItemsList.item = new List<SalesOrderSAPAPIMCS.ZsdstOrderItem>();
            
            // order conditions - its a list of order conditions
            SalesOrderSAPAPIMCS.TableOfZsdstCondition orderConditionsList = new SalesOrderSAPAPIMCS.TableOfZsdstCondition();
            orderConditionsList.item = new List<SalesOrderSAPAPIMCS.ZsdstCondition>();
            
            List<Customer_Pay_Plan_Header__C> cpphList = new List<Customer_Pay_Plan_Header__C>();
            if(quoteId != null){
                cpphList = [Select Id, Name, Global_Charges__c, Global_Charges__R.Name, Global_Charges__r.SAP_Material_Code__c, Global_Charges__r.SAP_Condition_Type__c,Global_Charges__r.SAP_Material_Type__c, Standard_Pay_Plan_Header__c, Standard_Pay_Plan_Header__r.Charge_Code__c ,Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c, Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c, Amount__c from customer_pay_plan_header__c where Quotation__c = :quoteId  order by Global_Charges__r.Name];
            }
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
                    }
                    // other charges bucket - each other charge is a separate order line item.
                    if(cpph.Standard_Pay_Plan_Header__r.Charge_Code__c != null && cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Bucket__c.equalsIgnoreCase('Other Charges')) {
                        // is it rate list or lumpsum
                        System.debug('CPPH record:' + cpph.Name + ':' + cpph.Global_Charges__r.Name);
                        if(cpph.Standard_Pay_Plan_Header__r.Charge_Code__r.S_Charge_Calculated_As__c.equalsIgnoreCase('Rate List at Unit Level') && 
                           rateMap.get(cpph.Global_Charges__c).Charge_Based_On_Master__c.equals('Rate') 
                           //&& rateMap.get(cpph.Global_Charges__c).Amount__c > 0 // Commented by coServe 11-05-2023
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
                               orderLine.Konda = '';
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
                               orderLine.Konda = '';
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
            if(qList.size() > 0 && qList[0].Total_Discount_L__c != 0) { //Added qList.size() > 0 by Vinay 17-07-2025
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
                if(qList[0].Total_Discount_L__c - GSTDiscount > 0) { 
                    // order condition for other charges
                    SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                    orderCondition.ItmNumber = '10';
                    //Commented by vinay 22-12-2021
                    //orderCondition.CondValue = String.valueOf((qList[0].Total_Discount_L__c - GSTDiscount).setscale(2,RoundingMode.HALF_UP));
                    orderCondition.CondValue = String.valueOf((qList[0].Customer_Total_Discount_L__c - GSTDiscount).setscale(2,RoundingMode.HALF_UP));
                    orderCondition.CondType = 'ZDS1';
                    orderConditionsList.item.add(orderCondition);
                }
                
            }
            // check for Additional Premium [ZPRM]
            if(qList.size() > 0 && qList[0].Premium_Charges_Amount_1__c != null && qList[0].Premium_Charges_Amount_1__c != 0) { //Added qList.size() > 0 by Vinay 17-07-2025
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf((qList[0].Premium_Charges_Amount_1__c * uList[0].Saleable_Area__c).setscale(2,RoundingMode.HALF_UP));
                orderCondition.CondType = 'ZPRM';
                orderConditionsList.item.add(orderCondition);
            }
            // Added by shailesh on 23rd of Oct 2019
            // check for CAM value [ZBEX]
            if(qList.size() > 0 && qList[0].CAM_Charges__c != null && qList[0].CAM_Charges__c != 0) { //Added qList.size() > 0 by Vinay 17-07-2025
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.CondValue = String.valueOf((qList[0].CAM_Charges__c).setscale(2,RoundingMode.HALF_UP));
                orderCondition.CondType = 'ZBEX';
                orderConditionsList.item.add(orderCondition);
            }
            // check for BCAM value [ZMAN]
            if(qList.size() > 0 && qList[0].BCAM_Charges__c != null && qList[0].BCAM_Charges__c != 0) { //Added qList.size() > 0 by Vinay 17-07-2025
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
                    if(cp.Parking__c.equalsIgnoreCase('Tandem Open')) {
                        allotmentCharges += pRec[0].allotment_charges_4__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Stilt')) {
                        allotmentCharges += pRec[0].allotment_charges_5__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('MLCP')) {
                        allotmentCharges += pRec[0].allotment_charges_6__c;
                    }
                    //Added by coServe 22-09-2022 Start
                    if(cp.Parking__c.equalsIgnoreCase('Basement')) {
                        allotmentCharges += pRec[0].allotment_charges_7__c;
                    }
                    //Added by coServe 22-09-2022 End
                    if(cp.Parking__c.equalsIgnoreCase('Podium')) {
                        allotmentCharges += pRec[0].allotment_charges_8__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Puzzle Car Park')) { //Added by Vinay 28-03-2025
                        allotmentCharges += pRec[0].Allotment_Charges_9__c;
                    }
                    if(cp.Parking__c.equalsIgnoreCase('Stack')) { //Added by Vinay 13-02-2026
                        allotmentCharges += pRec[0].Stack_Car_Park_Charges__c;
                    }
                    count++;
                }
                // order condition for parking charges
                SalesOrderSAPAPIMCS.ZsdstCondition orderCondition = new SalesOrderSAPAPIMCS.ZsdstCondition();
                orderCondition.ItmNumber = '10';
                orderCondition.condValue = String.valueOf(allotmentCharges);
                orderCondition.CondType = globalChargesMap.get('Allotment Charges').SAP_Condition_Type__c;
                orderConditionsList.item.add(orderCondition);
            }
            
            
            
            
            
            
            
            // populate the logger
            SalesOrderLogger.TableOfZsdstOrderItem orderItemsLogList = new SalesOrderLogger.TableOfZsdstOrderItem();
            orderItemsLogList.item = new List<SalesOrderLogger.ZsdstOrderItem>();
            
            
            SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction partnerFunctionList = new SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction();
            SalesOrderSAPAPIMCS.ZsdstPartnerFunction partnerFunction1 = new SalesOrderSAPAPIMCS.ZsdstPartnerFunction();
          //  SalesOrderLogger.TableOfZsdstPartnerFunction partnerFunctionLogList = new SalesOrderLogger.TableOfZsdstPartnerFunction();
          //  SalesOrderLogger.ZsdstPartnerFunction partnerFunctionLog1 = new SalesOrderLogger.ZsdstPartnerFunction();
            
            // order line conditions for logging
           // SalesOrderLogger.TableOfZsdstCondition orderConditionsLogList = new SalesOrderLogger.TableOfZsdstCondition();
            //orderConditionsLogList.item = new List<SalesOrderLogger.ZsdstCondition>();
            SalesOrderSAPAPIMCS.TableOfZsdstBillPlan billPlanList = new SalesOrderSAPAPIMCS.TableOfZsdstBillPlan();
            billPlanList.item = new List<SalesOrderSAPAPIMCS.ZsdstBillPlan>();
            
            SalesOrderSAPAPIMCS.TableOfBapiret2 bapiRet2List = new SalesOrderSAPAPIMCS.TableOfBapiret2();
            bapiRet2List.item = new List<SalesOrderSAPAPIMCS.Bapiret2>();
            
            
            // all put together forms the sales order
            SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER salesorder1 = new SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER();
            salesorder1.timeout_x = 120000;
            String CustomerNumber = cNo;
            
           /* SalesOrderLogger.ZsdSdfcSalesOrderLogger_element SOLogger = new SalesOrderLogger.ZsdSdfcSalesOrderLogger_element();
            SOLogger.OrderHeader = OrderHeaderLog;
            SOLogger.OrderItems = OrderItemsLogList;
            SOLogger.OrderConditions = OrderConditionsLogList;
            SOLogger.PartnerFuntion = partnerFunctionLogList;
            SOLogger.Customerno = CustomerNumber;*/
             SalesOrderErrorLogger SOLogger  = new SalesOrderErrorLogger();
            
            SOLogger.OrderHeader = OrderHeader;
            SOLogger.OrderItemsList = OrderItemsList;
            SOLogger.orderConditionsList = orderConditionsList;
            SOLogger.partnerFunctionList = partnerFunctionList;
            SOLogger.CustomerNumber = CustomerNumber;
            Boolean callOutError = false;
                            Boolean exceptionError = false;
        String exceptionMsg = '';
            SalesOrderSAPAPIMCS.ZsdSdfcSalesOrderResponse_element salesOrderResponse;
            
            SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element responseLog = new SalesOrderLogger.ZsdSdfcSalesOrderLoggerResponse_element();
            responseLog.Return_x  = new SalesOrderLogger.TableOfBapiret2();
            responseLog.Return_x.item = new List<SalesOrderLogger.Bapiret2>();
            
            try {
                system.debug(json.serialize(billPlanList));
                system.debug(json.serialize(CustomerNumber));
                
                // system.debug(json.serialize(orderConditionsList));
                system.debug(json.serialize(orderHeader));
                
                system.debug(json.serialize(partnerFunctionList));
                salesOrderResponse = salesorder1.ZsdSdfcSalesOrder(billPlanList,CustomerNumber, orderConditionsList, orderHeader, orderItemsList, partnerFunctionList, bapiRet2List);
                system.debug(JSON.serialize(salesOrderResponse));
                system.debug(salesOrderResponse.Salesdocument+'salesOrderResponse.Salesdocument;');
                //Added by Vinay 21-03-2025 Start
                system.debug('salesOrderResponse.Status' + salesOrderResponse.Status);
                if(salesOrderResponse.Status != null){
                    bList[0].Cancellation_in_SAP__c = salesOrderResponse.Status;
                    if(salesOrderResponse.Status == 'Success'){
                        if(bList[0].Cancellation_Reason__c == 'Unit cancelled'){
                            bList[0].Status__c = 'Booking Cancelled – Refund Pending';
                        }else if(bList[0].Cancellation_Reason__c ==	'Unit transfer'){
                            bList[0].Status__c = 'Cancelled';
                        }
                    }
                    update bList[0];
                }else{
                    bList[0].Cancellation_in_SAP__c = 'Error';
                    update bList[0];
                }
                //Added by Vinay 21-03-2025 End
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
                  for(Car_Parking_Charge__c cp: carParkingList) {
                    cp.Booking__c = null;
                    cp.Status__c = 'Vacant';
                }
                update carParkingList;
                if(salesOrderResponse.Salesdocument != null && salesOrderResponse.Salesdocument != '') {
                    responseLog.Salesdocument = salesOrderResponse.Salesdocument;
                    SONumber = salesOrderResponse.Salesdocument;
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
                System.debug('JSON Logger request:' + JSON.SerializePretty(SOLogger));
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                
                String requestF = JSON.SerializePretty(SOLogger);
             //   requestF =  requestF.replaceAll('\n','<br/>');
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
                     if(exceptionError){
                        log.Error_Type__c='Timeout Error';
                    }else{
                        log.Error_Type__c='Data Error';
                        
                    }
                    log.Status__c = 'Failure';
                    log.Error_Reason__c = exceptionMsg;
                }
                //erpLogList.add(log);
                insert log;
            }
            
        }
        
    }
    
    @invocableMethod
    public static void cancelOpportunity(List<Opportunity> ops){
        
        cancelsalesorder(new Set<id>{ops[0].id});
    }
}