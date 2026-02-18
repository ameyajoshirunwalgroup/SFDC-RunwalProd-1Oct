global class SalesorderUpdateCalloutBatch implements Database.Batchable<sObject>, Database.Stateful ,Database.AllowsCallouts{
    
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    
    public Set<Id> oppIds = new Set<Id>();
    global SalesorderUpdateCalloutBatch(Set<Id> opIds){
        this.oppIds = opIds;
    }
	
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,SalesOrder_Number__c, SAP_Customer_Number__c, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Walkin_Channel_Partner__c, Walkin_Source__c,RW_Project_Unit__r.Booking__c from Opportunity where Id =: oppIds]);
    }
    
    global void execute( Database.BatchableContext BC, List<Opportunity> oList){
        
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
        
        if(oList == null || oList.size() == 0 || oList.size() > 1) {
            dataError = true;
            errMsg = 'Invalid Opportunity,';
        } else {
            oppId = oList[0].Id;
        }
        if(oList[0].SAP_Customer_Number__c == null) {
            dataError = true;
            errMsg += 'Customer number not present,';
        } 
        List<Project__c> pRec = [Select Id, Name,Brokerage__c, Project_Property_Type__c,Sales_District__c, allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c from Project__c where Id = : oList[0].RW_Project__c];
        if(pRec == null || pRec.size() > 1) {
            errMsg += 'Project Data Issue,';
            dataError = true;
        }
        List<Tower__c> tRec = [Select Id, Name, Property_Type__c,SAP_Plant_Code__c  from Tower__c where Id = : oList[0].RW_Project_Unit__r.TowerName__c];
        if(tRec == null || tRec.size() > 1 || tRec.size() == 0) {
            errMsg += 'Tower Data Issue,';
            dataError = true;
            
        } else {
            system.debug(tRec);
            if(tRec[0].SAP_Plant_Code__c == null) {
                errMsg += 'SAP Tower Code not present,';
                dataError = true;
            }
        }
        if(oList[0].Booking__c == null) {
            dataError = true;
            errMsg = 'Booking not present,';
        }  else {
            bookingId = oList[0].Booking__c;
            bList = [Select Id,Status__c,RW_Cancellation_initiated_by__c,Cancellation_Sub_reason__c,Cancellation_Reason__c	, Booking_Date__c,Funding_Status__c, Source_Of_Booking__c, Name,RW_Last_SDR_Received__c,
                  RW_Index_2__c,   RW_Registration_Date__c,RW_BRL_Number__c,RW_Release_of_Charge_issue_status__c,RW_ROC_Date__c,RW_Signed_Agreement_to_Customer_Date__c,
                     RW_Actual_Possession_Date__c,RW_Agreement_Possession_Date__c	,Date_for_offer_of_Possession__c,// ADF_Opted__c,
                    RW_Noc_Generated_Date__c,RW_Loan_Sanction_Date__c, RW_Loan_Account_Number__c,RW_Loan_Amount__c,RW_Loan_Bank__c,Loan_Bank__c,RW_Nominee_Name__c	,Date_of_Occupation_Certificate__c	,Date_of_Cancellation__c,RW_Key_handover_date__c
                     
                     from Booking__c where Id = : bookingId];
        }
        if(oList[0].Booking__r.Quotation__c == null) {
            dataError = true;
            errMsg = 'Quotation not present,';
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
        if(dataError) {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'Sales Order';
            log.Booking__c = oList[0].RW_Project_Unit__r.Booking__c;
            log.Opportunity__c = oList[0].Id;
            log.Status__c = 'Not Processed';
            log.Error_Reason__c = errMsg;
            log.Error_Type__c = 'Data Error';
            erpLogList.add(log);
        }else if(!dataError){
            integer BasicPlanSequenceNo;
            String BasicCPPHId ;
            Map<String, Global_Charges__c> globalChargesMap = new Map<String, Global_Charges__c>();
            for(Global_Charges__c g : glList) {
                globalChargesMap.put(g.Name, g);
            }
            SalesOrderSAPAPIMCS.ZsdstOrderHeader orderHeader = new SalesOrderSAPAPIMCS.ZsdstOrderHeader();
            if(String.isNotBlank(tRec[0].Property_Type__c) && tRec[0].Property_Type__c.equalsIgnoreCase('Residential') ){
                orderHeader.DocType = 'ZRES';
                orderHeader.DistrChan= '10'; // for residential
            } else if (String.isNotBlank(tRec[0].Property_Type__c) && tRec[0].Property_Type__c.equalsIgnoreCase('Commercial') ) {
                orderHeader.DocType = 'ZCOC'; 
                orderHeader.DistrChan= '20'; 
            }
            orderHeader.Plant = tRec[0].SAP_Plant_Code__c;
            orderHeader.Division= '00';
            orderHeader.SalesGrp = '';
            orderHeader.SalesOff= '';
            orderHeader.PurchNoC= bList[0].Name;
            orderHeader.PoDatS = '';
            orderHeader.DocDate = '';
            orderHeader.SalesOrdNo=oList[0].SalesOrder_Number__c;
             // added by digicloud for ADF Option
           /* if(bList[0].ADF_Opted__c == true){
                orderHeader.ADF_OPTION = 'Y';
            }else{
                orderHeader.ADF_OPTION = 'N';
            }*/
            orderHeader.ZZSTMREGPD = String.ValueOf(bList[0].RW_Last_SDR_Received__c);
            orderHeader.ZZREGDT = String.valueOf(bList[0].RW_Registration_Date__c);
            orderHeader.ZzbookDt=String.ValueOf( bList[0].Booking_Date__c.date() );
            orderHeader.ZZREGSRNO=bList[0].RW_BRL_Number__c;
            orderHeader.ZZRROCDT=String.ValueOf( bList[0].RW_ROC_Date__c );
            orderHeader.ZZAGRMTDT=String.ValueOf( bList[0].RW_Signed_Agreement_to_Customer_Date__c );
            orderHeader.ZZAGRPOSSDT=String.ValueOf( bList[0].RW_Agreement_Possession_Date__c );
            orderHeader.ZZPOSSSTRDT=String.ValueOf( bList[0].RW_Actual_Possession_Date__c );
            orderHeader.ZZKEYHDOVRDT=String.ValueOf( bList[0].RW_Key_handover_date__c );
            orderHeader.ZZOCCPCERTDT=String.ValueOf( bList[0].Date_of_Occupation_Certificate__c );
            orderHeader.Nomini1 = bList[0].RW_Nominee_Name__c;	
            if(bList[0].RW_Release_of_Charge_issue_status__c == 'Received'){
                orderHeader.ZZROCST = 'X';
            }
            if(bList[0].Funding_Status__c == 'Self Funded'){
                orderHeader.ZZPAYMODE = '1';
            }else if(bList[0].Funding_Status__c == 'Loan Bank'){
                orderHeader.ZZPAYMODE = '2';
            }else if(bList[0].Funding_Status__c == 'Not decided'){
                orderHeader.ZZPAYMODE = '3';
            }
            orderHeader.ZzloanBd = bList[0].Loan_Bank__c;
            orderHeader.ZzloanAmt = String.valueOf(bList[0].RW_Loan_Amount__c);
            orderHeader.ZzloanFileNo = String.valueOf(bList[0].RW_Loan_Account_Number__c);
            orderHeader.ZzsanctionDt  =String.valueOf(bList[0].RW_Loan_Sanction_Date__c) ;
            orderHeader.ZznocIssDt=String.valueOf(bList[0].RW_Noc_Generated_Date__c) ;
            orderHeader.ZzmktVal = String.valueOf(bList[0].RW_Index_2__c);
            Integer seqNo = 10;
            Integer count = 1;
            SalesOrderSAPAPIMCS.TableOfZsdstOrderItem orderItemsList = new SalesOrderSAPAPIMCS.TableOfZsdstOrderItem();
            orderItemsList.item = new List<SalesOrderSAPAPIMCS.ZsdstOrderItem>();
            SalesOrderSAPAPIMCS.TableOfZsdstCondition orderConditionsList = new SalesOrderSAPAPIMCS.TableOfZsdstCondition();
            orderConditionsList.item = new List<SalesOrderSAPAPIMCS.ZsdstCondition>();
            SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction partnerFunctionList = new SalesOrderSAPAPIMCS.TableOfZsdstPartnerFunction();
            SalesOrderSAPAPIMCS.ZsdstPartnerFunction partnerFunction1 = new SalesOrderSAPAPIMCS.ZsdstPartnerFunction();
            SalesOrderLogger.TableOfZsdstCondition orderConditionsLogList = new SalesOrderLogger.TableOfZsdstCondition();
            orderConditionsLogList.item = new List<SalesOrderLogger.ZsdstCondition>();
            SalesOrderSAPAPIMCS.TableOfZsdstBillPlan billPlanList = new SalesOrderSAPAPIMCS.TableOfZsdstBillPlan();
            billPlanList.item = new List<   SalesOrderSAPAPIMCS.ZsdstBillPlan>();
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
            SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER salesorder1 = new SalesOrderSAPAPIMCS.ZSD_SFDC_SALES_ORDER();
            salesorder1.timeout_x = 60000;
            String CustomerNumber = oList[0].SAP_Customer_Number__c;
            
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
            try{
                system.debug(json.serialize(billPlanList));
                system.debug(json.serialize(CustomerNumber));
                system.debug(json.serialize(orderHeader));
                system.debug(json.serialize(partnerFunctionList));
                salesOrderResponse = salesorder1.ZsdSdfcSalesOrder(billPlanList,CustomerNumber, orderConditionsList, orderHeader, orderItemsList, partnerFunctionList, bapiRet2List);
                system.debug(JSON.serialize(salesOrderResponse));
                system.debug(salesOrderResponse.Salesdocument+'salesOrderResponse.Salesdocument;');
                if(salesOrderResponse.Return_x.item != null){
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
                                system.debug('json.serialize(orderHeader)>>>>' +json.serialize(orderHeader)); // added digicloud
                 if(salesOrderResponse.Salesdocument != null && salesOrderResponse.Salesdocument != '') {
                    responseLog.Salesdocument = salesOrderResponse.Salesdocument;
                    SONumber = salesOrderResponse.Salesdocument;
                    system.debug(sonumber);
                } else {
                    callOutError = true;
                    exceptionMsg = 'Sales Order # not received';
                }
        }catch (Exception ex) {
            System.debug('Exception:' + ex.getMessage());
            callOutError = true;
            exceptionError= true;
            exceptionMsg = ex.getMessage();
        } finally {
            System.debug('JSON Logger request:' + JSON.SerializePretty(SOLogger));
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            
            String requestF = JSON.SerializePretty(SOLogger);
            requestF =  requestF.replaceAll('&quot;','"');
            log.request__c = requestF;
                
            log.API_name__c = 'Sales Order';
            log.Booking__c = bookingId;
            log.Opportunity__c = oppId;
            String responseF = JSON.SerializePretty(responseLog);
            responseF =  responseF.replaceAll('\n','<br/>');
            responseF  = responseF.replaceAll('\t', '&nbsp;');
            log.response__c = responseF;
            if(!callOutError){
                log.Status__c = 'Success';
            }else {
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
    insert erpLogList;
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}