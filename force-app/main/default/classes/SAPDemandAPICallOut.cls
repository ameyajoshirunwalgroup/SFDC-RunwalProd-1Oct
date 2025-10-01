public class SAPDemandAPICallOut 
{
    //  @future(callOut = true)
    public static boolean bypassErrorLog = false;
    
    public static boolean throwexception = false;
    public static void getDemands(String timestamp)
    {
        
        
        Map<String,demandWrapper> mapOfDemandWrapper = new Map<String,demandWrapper>();
        
        SAPDemandAPI  sapDemandApi  = new SAPDemandAPI();
        SAPDemandAPI.ZSD_SFDC_WSDL_DEMAND_BND  sapDemandBNDApi  = new SapDemandApi.ZSD_SFDC_WSDL_DEMAND_BND();
        SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT sfdcpayDemandResponse = new    SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT();
        Map<string,string> milestoneMap = new Map<string,string>();
        milestoneMap.put('BCAM','Building CAM');
        milestoneMap.put('CLUB_MAIN','CLUB_MAINTENANCE');
        milestoneMap.put('FCAM','COMMON AREA MAINTENANCE');
        milestoneMap.put('WAT_ELEC','WATER & ELECTRICITY CONN CHARGES');
        milestoneMap.put('DEV_CHGS','DEVELOPMENT CHARGES');
        milestoneMap.put('ELE_SUBST','Electricity & Sub Station');
        milestoneMap.put('LEGL_CHS','legal charges');
        milestoneMap.put('MSEB','MSEB');
        milestoneMap.put('SEC_DEPO','SECURITY DEPOSITE CHARGES');
        milestoneMap.put('SHARE_APP','SHARE APPLICATION MONEY');
        milestoneMap.put('SOC_FORM','SOCIETY FORMATION');
        
        
        try{if(test.isRunningTest()){
            
            String dmd = '{	"item_type_info": ["item", "urn:sap-com:document:sap:rfc:functions", null, "0", "-1", "false"],	"item": [{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000010", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025444", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	},{ 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025444", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}, 			 { 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "P", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025445", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	}, 			 { 		"USAGE_CODE_type_info": ["USAGE_CODE", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"USAGE_CODE": "Z0041", 		"STATUS_type_info": ["STATUS", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"STATUS": "C", 		"POSNR_type_info": ["POSNR", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"POSNR": "000011", 		"ODN_NO_type_info": ["ODN_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"ODN_NO": "RV20/10/50000125", 		"MIL_STN_NAME_type_info": ["MIL_STN_NAME", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"MIL_STN_NAME": "DUE ON 31ST MARCH 2019", 		"GST_AMOUNT_type_info": ["GST_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"GST_AMOUNT": "394536.0", 		"field_order_type_info": ["CUSTOMER", "B_DOC_NO", "ODN_NO", "DEMAND_DT", "DEMAND_DUE_DT", "DEMAND_AMOUNT", "GST_AMOUNT", "USAGE_CODE", "MIL_STN_NAME", "STATUS"], 		"DEMAND_DUE_DT_type_info": ["DEMAND_DUE_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DUE_DT": "2021-01-19", 		"DEMAND_DT_type_info": ["DEMAND_DT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_DT": "2021-01-04", 		"DEMAND_AMOUNT_type_info": ["DEMAND_AMOUNT", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"DEMAND_AMOUNT": "3287630.0", 		"CUSTOMER_type_info": ["CUSTOMER", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"CUSTOMER": "12345678", 		"B_DOC_NO_type_info": ["B_DOC_NO", "urn:sap-com:document:sap:rfc:functions", null, "1", "1", "false"], 		"B_DOC_NO": "9010025446", 		"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] 	} 			 			 			], 	"field_order_type_info": ["item"], 	"apex_schema_type_info": ["urn:sap-com:document:sap:rfc:functions", "false", "true"] }';
            sfdcpayDemandResponse =  (SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT) JSON.deserialize(dmd,  SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT.class);
            if(throwexception)   {
                CalloutException e = new CalloutException();
                e.setMessage('Validation Error(s) occurred during inventory Get.');
                throw e; 
            }
        }else{
                    sapDemandBNDApi.timeout_x = 60000;

            sfdcpayDemandResponse = sapDemandBNDApi.ZSD_SFDC_WS_DEMAND( timestamp); } 
            //  SAPDemandAPI.ZSD_SFDC_DEMAND_INFO_TT sfdcpayDemandResponse = sapDemandBNDApi.ZSD_SFDC_WS_DEMAND('20201230101010');  
           }   catch(exception ex){
               if(!bypassErrorLog){
                   ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
                   erp.API_Name__c = 'Demand API';
                   erp.Request__c = timestamp;
                   erp.Status__c ='Failure';
                   erp.Response__c = JSON.serialize(sfdcpayDemandResponse);
                   erp.Error_Reason__c = ex.getMessage();
                   erp.Error_Type__c = 'Timeout Error';
                   insert erp;}
               
           }   
        system.debug('response---> '+ JSON.serialize(sfdcpayDemandResponse));
        Set<String>  cutomerIds = new Set<String>();
        Set<String> demandNoIds = new Set<String>();
        try{
            //QUery through all the demands
            if(sfdcpayDemandResponse!=null && sfdcpayDemandResponse.item != null && sfdcpayDemandResponse.item.size() >0)
            {
                for(SAPDemandAPI.ZSD_SFDC_DEMAND_INFO response :sfdcpayDemandResponse.item)
                {
                    if(response.CUSTOMER != null && response.CUSTOMER !='' && response.B_DOC_NO !=null && response.B_DOC_NO!='')
                    {//customer id stores all the list of cutomer id present in the response, this is used to query opportunity to get the booking id
                        cutomerIds.add(response.CUSTOMER);
                        //demand id stores all the uniq demands present in the response, this is used to check the existing demands in the system
                        demandNoIds.add(response.B_DOC_NO);
                    }
                }
            }
            
            system.debug('response-- cutomerIds-> '+ cutomerIds);
            system.debug('response--- demandNoIds> '+ demandNoIds);
            
            //query opportunity withe the customer ids to get the booking record id,opty id etc
            List<Opportunity> opprec = [Select Id, Name, SAP_Customer_Number__c, Booking__c from Opportunity where SAP_Customer_Number__c IN:cutomerIds and stagename='Unit Booked'];
            
            //BookingIds is the map of sap customer number and booking record id for the existing demands
            Map<string, String> BookingMap = new Map<string,String>();
            for(Opportunity b: opprec)
            {
                BookingMap.put(b.SAP_Customer_Number__c, b.Booking__c);
            }
            system.debug('BookingMap'+BookingMap);
            //query all the all the existing demnds, demand status by passing demand number.
            
            List<RW_Demand__c> demandRecords = [select id, RW_Demand_Status__c, RW_Customer_Number__c, RW_Billing_Document_Number__c from RW_Demand__c where RW_Billing_Document_Number__c =: demandNoIds];
            
            // map<Billing document number, demand object> mapOfDemndnumber
            Map<String,RW_Demand__c> mapOfDemandNumber = new Map<string,RW_Demand__c>();
            for(RW_Demand__c dm :demandRecords ){
                mapOfDemandNumber.put(dm.RW_Billing_Document_Number__c,dm);
            }
            List<RW_Demand__c> listOfDemandUpdate = new List<RW_Demand__c>();
            set<id> demandIdstoNull = new set<id>();
            set<id> demandIdstoClear = new set<id>();
            set<id> demandtoreopen = new set<id>();
            system.debug('BookingMap' + BookingMap);        
            if(sfdcpayDemandResponse!=null && sfdcpayDemandResponse.item != null && sfdcpayDemandResponse.item.size()>0 )
            {
                //loop through the sap demand api response
                for(SAPDemandAPI.ZSD_SFDC_DEMAND_INFO response :sfdcpayDemandResponse.item)
                { // check if the BookingMap has customer id in response, i.e  booking is present in the system && the demand is not present in the system
                    if(BookingMap.containsKey(response.CUSTOMER) && !mapOfDemandNumber.ContainsKey(response.B_DOC_NO))
                    {
                        // if there are 1 demand items for the demand then there will be already entry in the mapOfDemandWrapper
                        if(mapOfDemandWrapper.containsKey(response.B_DOC_NO))
                        {
                            system.debug(response+'MK');
                            //get the demand wrapper and create new demand item
                            demandWrapper wrapper = mapOfDemandWrapper.get(response.B_DOC_NO);
                            RW_Demand_Item__c demandItems = new RW_Demand_Item__c();
                            
                            //fill in the line items details. 
                            demandItems.RW_Demand_Item_Amount__c = decimal.valueOf(response.DEMAND_AMOUNT);
                            demandItems.RW_GST_Amount__c = decimal.valueOf(response.GST_AMOUNT);
                            if(milestoneMap.containskey( response.MIL_STN_NAME))
                                demandItems.RW_Milestone_Name__c = milestoneMap.get( response.MIL_STN_NAME);
                            else
                                demandItems.RW_Milestone_Name__c = response.MIL_STN_NAME;
                            demandItems.RW_Usage_Code__c = response.USAGE_CODE;
                            demandItems.RW_Demand_Item_Number__c = response.POSNR;
                            if(response.STATUS == 'P'){
                                
                                demandItems.Total_Demand_Item_Amount_Paid__c	=  decimal.valueOf(response.GST_AMOUNT)+decimal.valueOf(response.DEMAND_AMOUNT);
                                demandItems.RW_Stop_Receipt_Rollup__c = true;
                                
                            }
                            wrapper.demandItems.add(demandItems);
                            mapOfDemandWrapper.put(response.B_DOC_NO, wrapper);      
                        }
                        else
                        {
                            //build the demand wrapper
                            demandWrapper wrapper = new demandWrapper();
                            
                            //initialize the demand under wrapper
                            wrapper.demand = new RW_Demand__c();
                            //build the demand with data
                            wrapper.demand.Booking__c  = BookingMap.get(response.CUSTOMER); 
                            wrapper.demand.RW_Billing_Document_Number__c = response.B_DOC_NO;
                            wrapper.demand.Name = response.B_DOC_NO;
                            wrapper.demand.RW_Customer_Number__c = response.CUSTOMER; 
                            
                            try {
                                wrapper.demand.Demand_Date__c = date.valueOf(response.DEMAND_DT);
                            }
                            catch(TypeException e) {
                                // Throw a custom exception and handle the message in your component
                            }
                            
                            try {
                                wrapper.demand.Due_Date__c = date.valueOf(response.DEMAND_DUE_DT);
                            }
                            catch(TypeException e) {
                                // Throw a custom exception and handle the message in your component
                            }
                            wrapper.demand.RW_ODN_Number__c = response.ODN_NO;
                            // wrapper.demand.RW_Demand_Milestone__c = response.MIL_STN_NAME;
                            if(milestoneMap.containskey( response.MIL_STN_NAME))
                                wrapper.demand.RW_Demand_Milestone__c = milestoneMap.get( response.MIL_STN_NAME);
                            else
                                wrapper.demand.RW_Demand_Milestone__c = response.MIL_STN_NAME;
                            
                            wrapper.demandItems = new List<RW_Demand_Item__c>();
                            //build the demand item
                            RW_Demand_Item__c demndItem = new RW_Demand_Item__c();
                            demndItem.RW_Demand_Item_Amount__c = decimal.valueOf(response.DEMAND_AMOUNT);
                            demndItem.RW_GST_Amount__c = decimal.valueOf(response.GST_AMOUNT);
                            //demndItem.RW_Milestone_Name__c = response.MIL_STN_NAME;
                            if(milestoneMap.containskey( response.MIL_STN_NAME))
                                demndItem.RW_Milestone_Name__c = milestoneMap.get( response.MIL_STN_NAME);
                            else
                                demndItem.RW_Milestone_Name__c = response.MIL_STN_NAME;
                            
                            demndItem.RW_Usage_Code__c = response.USAGE_CODE;   
                            demndItem.RW_Demand_Item_Number__c = response.POSNR;
                            if(response.STATUS == 'P'){
                                wrapper.demand.RW_Demand_Status__c = 'Paid' ;
                                demndItem.Total_Demand_Item_Amount_Paid__c	=  decimal.valueOf(response.GST_AMOUNT)+decimal.valueOf(response.DEMAND_AMOUNT);
                                demndItem.RW_Stop_Receipt_Rollup__c = true;
                                
                            }else  if(response.STATUS == 'C')
                            {
                                wrapper.demand.RW_Demand_Status__c = 'Revoke';
                            }
                            wrapper.demandItems.add(demndItem);
                            mapOfDemandWrapper.put(response.B_DOC_NO, wrapper);
                        } 
                    }
                    
                    else if(mapOfDemandNumber.ContainsKey(response.B_DOC_NO)){
                        
                        //if the demand is already present in the system
                        
                        RW_Demand__c demandupd =   mapOfDemandNumber.get(response.B_DOC_NO);
                        // check if the previous status is not revoke and new status is revoke 
                        if(demandupd.RW_Demand_Status__c != 'Revoke' && response.STATUS == 'C' )
                        { 
                            
                            demandupd.RW_Demand_Status__c = 'Revoke';
                            demandIdstoNull.add(demandupd.Id);
                            listOfDemandUpdate.add(demandupd);
                        }//If previous status is not Paid and new status is P
                        else if(demandupd.RW_Demand_Status__c != 'Paid' && response.STATUS == 'P' ){
                            demandupd.RW_Demand_Status__c = 'Paid';
                            demandIdstoClear.add(demandupd.Id);
                            listOfDemandUpdate.add(demandupd);
                        }else if(demandupd.RW_Demand_Status__c == 'Paid' &&( response.STATUS == '' ||  response.STATUS== null)){
                            
                            demandupd.RW_Demand_Status__c = 'Due';
                            listOfDemandUpdate.add(demandupd);
                            demandtoreopen.add(demandupd.id);
                            
                        }
                    }
                    
                }
                
                
            }
            system.debug('mapOfDemandWrapper' + mapOfDemandWrapper);
            
            List<RW_Demand__c> demandToInsert = new List<RW_Demand__c>();
            system.debug('demandToInsert' + demandToInsert);
            for(demandWrapper dw : mapOfDemandWrapper.values())
            {
                demandToInsert.add(dw.demand);
            }
            // insert the demands
            insert  demandToInsert;
            //update the demands
            update listOfDemandUpdate;
            List<RW_Demand_Item__c> demanditemtoclear = [select id,Total_Demand_Item_Amount_Paid__c,RW_GST_Amount__c,RW_Demand_Item_Amount__c from RW_Demand_Item__c where Rw_Demand__C in:demandIdstoNull];
            
            system.debug('demanditemtoclear ---->' +   demanditemtoclear.size());
            for(RW_Demand_Item__c di :demanditemtoclear){
                di.Total_Demand_Item_Amount_Paid__c = 0;
                di.RW_Demand_Item_Amount__c = 0;
                di.RW_GST_Amount__c=0;
                di.RW_Stop_Receipt_Rollup__c = true;
            }
            update demanditemtoclear;
            
            //update demand items of fully paid demand
            
            List<RW_Demand_Item__c> demanditemtopaid = [select id,Total_Demand_Item_Amount_Paid__c,RW_GST_Amount__c,RW_Demand_Item_Amount__c from RW_Demand_Item__c where Rw_Demand__C in:demandIdstoClear];
            
            system.debug('demanditemtoclear ---->' +   demanditemtopaid.size());
            for(RW_Demand_Item__c di :demanditemtopaid){
                di.Total_Demand_Item_Amount_Paid__c =  di.RW_Demand_Item_Amount__c+ di.RW_GST_Amount__c;
                
                di.RW_Stop_Receipt_Rollup__c = true;
            }
            update demanditemtopaid;    
            
            List<RW_Demand_Item__c> demanditemtoreopen = [select id,Total_Demand_Item_Amount_Paid__c,RW_GST_Amount__c,RW_Demand_Item_Amount__c from RW_Demand_Item__c where Rw_Demand__C in:demandtoreopen];
            set<id> dmids = new set<id>();
            system.debug('demanditemtoclear ---->' +   demanditemtoreopen.size());
            for(RW_Demand_Item__c di :demanditemtoreopen){
                di.Total_Demand_Item_Amount_Paid__c =  0;
                
                di.RW_Stop_Receipt_Rollup__c = false;
                dmIds.add(di.id);
            }
            update demanditemtoreopen;    
            
            PaymentItemHandler.recalculateDemanditem(dmIds);
            
            
            system.debug('demandToInsert ---->' +   demandToInsert.size());
            
            List<RW_Demand_Item__c> demdItemsToInsert = new List<RW_Demand_Item__c>();
            
            
            //update the demand item with demand id
            for(RW_Demand__c demd :  demandToInsert)
            {
                List<RW_Demand_Item__c> demdIdUpdate = mapOfDemandWrapper.get(demd.RW_Billing_Document_Number__c).demandItems;
                for(RW_Demand_Item__c dI : demdIdUpdate)
                {
                    dI.RW_Demand__c = demd.Id;
                }
                
                demdItemsToInsert.addAll(demdIdUpdate);
                
            }
            
            insert demdItemsToInsert;
            
            system.debug('demdItemsToInsert' + demdItemsToInsert.size());
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'Demand API';
            erp.Status__c='Failure';
            erp.Request__c = timestamp;//JSON.serialize(System.now().format('yyyyMMddHHmmss'));
            string res = JSON.serialize(sfdcpayDemandResponse).replaceAll('\n','<br/>');
            res = res.replaceAll('\t', '&nbsp;');
            res = res.replaceAll('&quot;','"');
            if(res.length()>50000)
                res = res.substring(0,50000);
            
            erp.Response__c = res;//.abbreviate(131072);//JSON.serialize(sfdcpayDemandResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;').replaceAll('&quot;','"');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Data Error';
            insert erp;
            
        }
    }
    
    
    public class demandWrapper
    { 
        public RW_Demand__c demand;
        public List<RW_Demand_Item__c> demandItems;
    }
}