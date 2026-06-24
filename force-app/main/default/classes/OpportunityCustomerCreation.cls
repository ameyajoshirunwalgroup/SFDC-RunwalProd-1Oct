public with sharing class OpportunityCustomerCreation {
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    public static  List<Opportunity>  oList = new List<Opportunity>();
    @future (callout=true)
    public static void createOppCustomer(Set<Id> oIdSet) {
        String customerNumber;
        oList  = [Select Id, SAP_Customer_Number__c,AccountId, RW_Project_Unit__c,RW_Project_Unit__r.TowerName__c,
                  RW_Project__c, Sales_Manager__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,RW_Closing_Head__c, RW_Sourcing_Manager__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,
                  RW_Sourcing_Head__c,Walkin_Source__c,Account.Salutation,Account.FirstName,Account.LastName,
                  Account.Middle_Name__c,Account.Gender__c,Account.Marital_Status__c,Account.RW_Occupation__c,
                  Account.RW_Designation__c,Account.Organization_Name__c,Account.Mobile_No__c,Account.PersonEmail,
                  Account.RW_Additional_Email__c,Account.PersonTitle,Account.BillingCity,Account.BillingCountry,Account.Country__c,
                  Account.BillingPostalCode,Account.BillingState,Account.BillingStreet
                  from Opportunity where Id in: oIdSet]; //Added Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name,Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025
        List<ERP_Integration_Log__c> erpLogs = [SELECT Id, API_Name__c, Status__c, Opportunity__c FROM ERP_Integration_Log__c WHERE Opportunity__c =: oList[0].Id  and Status__c = 'Success' and API_Name__c = 'Opportunity Customer Creation/Update'];
       
        if(oList[0].SAP_Customer_Number__c == null && erpLogs.size() == 0){
            customerNumber = createCustomerFromOpportunity(oIdSet);
            oList[0].SAP_Customer_Number__c = customerNumber;
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
    }

    public static String createCustomerFromOpportunity(Set<Id> oIdSet){
        
       String customerNumber;
        Boolean dataError = false;
        Id oppId;
        Id unitId;
        List<Project_Unit__c>   uList = new List<Project_Unit__c>();
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Map<String, Applicant_Details__c> appMap = new Map<String, Applicant_Details__c>();
        //List<Account> accList = new List<Account>();
        List<Blocking_Unit_Information__c> blockUnitList = new List<Blocking_Unit_Information__c>();
        String errMsg ='';
        //List<Opportunity> oList  = [Select Id, SAP_Customer_Number__c,AccountId, RW_Project_Unit__c, Booking__c, Booking__r.Quotation__c,  RW_Project_Unit__r.TowerName__c,RW_PAN_Card_Number__c,  RW_Project__c, Sales_Manager__c,RW_Sales_Associate__c, RW_Closing_Head__c, RW_Sourcing_Manager__c, RW_Sourcing_Head__c,Walkin_Source__c,RW_Project_Unit__r.Booking__c from Opportunity where Id in: oIdSet];   
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
            if(pRec == null || pRec.size() == 0) {
                errMsg += 'Project Data Issue';
                dataError = true;
            } else {
                if(pRec[0].SAPMaterial_Code__c == null) {
                    errMsg += 'SAP Project Code not present';
                    dataError = true;
                }
            }
            // tower or plant data check
            tRec = [Select Id, Name, Property_Type__c,SAP_Plant_Code__c  from Tower__c where Id = : oList[0].RW_Project_Unit__r.TowerName__c];
            if(tRec == null || tRec.size() == 0) {
                errMsg += 'Tower Data Issue';
                dataError = true;
                
            } else {
                if(tRec[0].SAP_Plant_Code__c == null) {
                    errMsg += 'SAP Tower Code not present';
                    dataError = true;
                }
            }   
            
            if(oList[0].RW_Project_Unit__c == null) {
                dataError = true;
                errMsg = 'Unit not present';
            } else {
                unitId = oList[0].RW_Project_Unit__c;
                uList = [Select Id, Name,Unit_SAP_Code__c,Saleable_Area__c, Carpet_area__c from Project_Unit__c where Id = : oList[0].RW_Project_Unit__c];
                if(uList== null || uList.size()==0) {
                    dataError = true;
                    errMsg += 'Unit Data Isuue';
                }
                else{
                    if(uList[0].Unit_SAP_Code__c == null) {
                        dataError = true;
                        errMsg += 'SAP Material Code not present in the unit';
                    }
                }
            } 
            
            if(oList!=null && oList.size()>0){
              blockUnitList = [Select Id,Pan_Number__c,Aadhar_Number__c from Blocking_Unit_Information__c where Active__c = true AND Opportunity__c	=:oList[0].Id];
            }
            if(blockUnitList==null || blockUnitList.size()==0){
                dataError = true;
                errMsg += 'Block Unit Information not present';
            }
            if(oList.size()<0){
               dataError=true;
            }
            
            
        }
        // if data error , dont call API, log the error and exit.
        if(dataError) {
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.API_name__c = 'Opportunity Customer Creation/Update';
            if(oppId != null) {
               // log.Booking__c = oList[0].RW_Project_Unit__r.Booking__c;
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
            customerHeader.Kdkg2 = '00'; 
            customerHeader.Vkorg = pRec[0].SAPMaterial_Code__c;
            customerHeader.Werks = tRec[0].SAP_Plant_Code__c;
            customerHeader.Vtweg = tRec[0].Property_Type__c;
            customerHeader.Spart = '00';
            customerHeader.Ktokd = tRec[0].Property_Type__c;
            customerHeader.Title = oList[0].Account.Salutation;
            customerHeader.NameFirst  = oList[0].Account.FirstName;
            customerHeader.NameMiddle = oList[0].Account.Middle_Name__c;
            customerHeader.NameLast = oList[0].Account.LastName;
            customerHeader.Langucorr = 'E';
            customerHeader.Sort1 = uList[0].Unit_SAP_Code__c;
            customerHeader.Sort2 = oppid;
            if(!String.isEmpty(oList[0].Account.Gender__c)){
                
                if(oList[0].Account.Gender__c.equalsIgnoreCase('Male')){
                    customerHeader.Xsexf = 'M';
                }
                else if(oList[0].Account.Gender__c.equalsIgnoreCase('Female') ){
                    customerHeader.Xsexf = 'F';
                }
            }
            else{
                customerHeader.Xsexf = 'O';
            }
            
            customerHeader.Marst = oList[0].Account.Marital_Status__c;
            customerHeader.Jobgr = oList[0].Account.RW_Occupation__c;
            customerHeader.StaffGrp =oList[0].Account.RW_Designation__c;
            
            // these need to mapped in SAP based on SFDC data
            if(String.isNotBlank(oList[0].Sourcing_Manager_User__c))  // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__c by Vinay 04-12-2025
                customerHeader.Kvgr1 = oList[0].Sourcing_Manager_User__r.Name;  // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__r.Name by Vinay 04-12-2025
            if(String.isNotBlank(oList[0].RW_Sourcing_Head__c))
                customerHeader.Kvgr2 = oList[0].RW_Sourcing_Head__c;
            if(String.isNotBlank(oList[0].Sales_Manager_User__c))  	//Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                customerHeader.Kvgr3 = oList[0].Sales_Manager_User__r.Name; 	//Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
            if(String.isNotBlank(oList[0].RW_Closing_Head__c))
                customerHeader.Kvgr4 = oList[0].RW_Closing_Head__c;
            if(String.isNotBlank(oList[0].Walkin_Source__c))
                customerHeader.Kvgr5 = oList[0].Walkin_Source__c;
            
            customerHeader.Addrcode = '01';
            
            customerHeader.Katr1 = oList[0].Walkin_Source__c;
            if(String.isNotBlank(oList[0].Account.Organization_Name__c))
            {
                customerHeader.Emplo = oList[0].Account.Organization_Name__c;
            }
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
            //Mandatory for Indian National, NRI , Company and Partnership firm
            if(String.isNotBlank(blockUnitList[0].Pan_Number__c )) {
                CustomerCreation.ZsdSfdcCustomerTax taxLineitem1 = new CustomerCreation.ZsdSfdcCustomerTax();
                taxLineitem1.Ind = 'M';
                taxLineitem1.Taxtype = 'IN6';
                taxLineitem1.Taxnumxl = blockUnitList[0].Pan_Number__c;
                customerTaxList.item.add(taxLineItem1);
            }

                if(String.isNotBlank(blockUnitList[0].Aadhar_Number__c)) {
                CustomerCreation.ZsdSfdcCustomerTax taxLineitem2 = new CustomerCreation.ZsdSfdcCustomerTax();
                taxLineitem2.Ind = 'M';
                taxLineitem2.Taxtype = 'IN5';
                taxLineitem2.Taxnumxl = blockUnitList[0].Aadhar_Number__c;
                customerTaxList.item.add(taxLineItem2);
            }                       
            
            // Mailing, Permanent and Office address of primary applicant
            CustomerCreation.TableOfZsdSfdcCustomerAddress customerAddressList = new CustomerCreation.TableOfZsdSfdcCustomerAddress();
            customerAddressList.item = new List<CustomerCreation.ZsdSfdcCustomerAddress>();
            
            CustomerCreation.ZsdSfdcCustomerAddress AddressItem = new CustomerCreation.ZsdSfdcCustomerAddress();
            AddressItem.Addrcode = '01';
            AddressItem.Street = oList[0].Account.BillingStreet;
            AddressItem.PostCode = oList[0].Account.BillingPostalCode;
            AddressItem.City = oList[0].Account.BillingCity;
            AddressItem.Country = oList[0].Account.Country__c;

            AddressItem.Region  = oList[0].Account.BillingState;
            customerAddressList.item.add(AddressItem);

            Integer SeqNo = 10;
            Integer count = 1;
            // Co Applicant Details
            CustomerCreation.TableOfZsdsBpContact  coAppList = new CustomerCreation.TableOfZsdsBpContact();            
                    
            // phone and email of permanent applicant 
            CustomerCreation.TableOfZsdSfdcCustomerComm  commList = new CustomerCreation.TableOfZsdSfdcCustomerComm();
            commList.Item = new List<CustomerCreation.ZsdSfdcCustomerComm>();
            CustomerCreation.ZsdSfdcCustomerComm commItem1 = new CustomerCreation.ZsdSfdcCustomerComm();
            commItem1.Addrcode = '01';
            commItem1.MobileNo  =oList[0].Account.Mobile_No__c;
            //commItem1.SmtpAddr =  oList[0].Account.RW_Additional_Email__c;
            commItem1.SmtpAddr =  oList[0].Account.PersonEmail;
            commList.item.add(commItem1);
            
            CustomerCreationErrorLogger cLog = new CustomerCreationErrorLogger();
            cLog.customerHeader = customerHeader;
            cLog.customerTaxList = customerTaxList;
            cLog.customerAddressList =customerAddressList;
            cLog.coAppList = coAppList;
            cLog.commList = commList;

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
                System.debug('customerCreationResponse.Return_x:' + customerCreationResponse.Return_x);
                System.debug('customerCreationResponse.Return_x.item:' + customerCreationResponse.Return_x.item);
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
                    oList[0].SAP_Customer_Number__c = customerNumber;
                    update oList;
                    
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
                log.API_name__c = 'Opportunity Customer Creation/Update';
                //log.Booking__c = bookingId;
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
        //insert erpLogList;
        return customerNumber;
    }
}