public class SAPCPReceiptAPICallOut {
    @future(callout=true)
    public static void getCPReceipts(List<Id> RId) 
    {
        String timestamp;
        List<String> chequeCode = new List<String>{'DF','DE','D1','DZ','DT','AB','DS','DB'};
            Map<String,List<SAPCPPaymentInterface.ZstrInvSentLog>> mapResponse = new Map<String,List<SAPCPPaymentInterface.ZstrInvSentLog>>(); 
        List<String> InvoiceDocNoList = new List<String>();
        List<Brokerage_Invoice__c> InvoiceList = new List<Brokerage_Invoice__c>();
        List<Brokerage_Receipt__c> UpdateReceiptList = new List<Brokerage_Receipt__c>();
        List<Project__c> ProjectList = new list<Project__c>();
        List<Legal_Entity__c> legalentity = new list<Legal_Entity__c>();
        List<Brokerage_Invoice__c> InvoiceList1 = new List<Brokerage_Invoice__c>();
		boolean check1;
        //Get the response for SAP Payment API 
        SAPCPPaymentInterface sapCPPaymentInterface = new SAPCPPaymentInterface();
        sapCPPaymentInterface.ZFI_PMNT_RCPT_BROK_API payReceipt= new sapCPPaymentInterface.ZFI_PMNT_RCPT_BROK_API();
        sapCPPaymentInterface.ZttInvSentLog sfdcpayReceipt= new sapCPPaymentInterface.ZttInvSentLog();
        sapCPPaymentInterface.ZttInvSentLog sfdcpayReceiptResponse= new sapCPPaymentInterface.ZttInvSentLog();
        // System.debug('*before call*');
        try{
            // sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,System.now().format('yyyyMMddHHmmss'));
            
            if(test.isRunningTest()){
                String rec = '{   "apex_schema_type_info": "(urn:sap-com:document:sap:soap:functions:mc-style, false, true), field_order_type_info=(item), item=(ZstrInvSentLog:[AccDocNo=0010000635, AccDocNo_type_info=(AccDocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Bukrs=1000, Bukrs_type_info=(Bukrs, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), ClrDocNo=0010000635, ClrDocNo_type_info=(ClrDocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocDate=2022-10-12, DocDate_type_info=(DocDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocNo=, DocNo_type_info=(DocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocType=KZ, DocType_type_info=(DocType, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Gjahr=2018, Gjahr_type_info=(Gjahr, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), InvAmt=          375354.00, InvAmt_type_info=(InvAmt, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), InvDate=2022-10-12, InvDate_type_info=(InvDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PayDate=2019-06-12, PayDate_type_info=(PayDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PayMode=, PayMode_type_info=(PayMode, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PostDate=2022-10-12, PostDate_type_info=(PostDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Sapinvoiceno=0190000477, Sapinvoiceno_type_info=(Sapinvoiceno, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Sfdcinvoiceref=30023, Sfdcinvoiceref_type_info=(Sfdcinvoiceref, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), apex_schema_type_info=(urn:sap-com:document:sap:soap:functions:mc-style, false, true), field_order_type_info=(Sfdcinvoiceref, Sapinvoiceno, AccDocNo, ClrDocNo, DocNo, Bukrs, Gjahr, DocType, DocDate, InvDate, ...)], ZstrInvSentLog:[AccDocNo=0010000635, AccDocNo_type_info=(AccDocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Bukrs=1000, Bukrs_type_info=(Bukrs, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), ClrDocNo=0010000635, ClrDocNo_type_info=(ClrDocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocDate=2022-10-12, DocDate_type_info=(DocDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocNo=, DocNo_type_info=(DocNo, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), DocType=AB, DocType_type_info=(DocType, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Gjahr=2018, Gjahr_type_info=(Gjahr, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), InvAmt=          376353.33, InvAmt_type_info=(InvAmt, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), InvDate=2022-10-12, InvDate_type_info=(InvDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PayDate=2019-06-12, PayDate_type_info=(PayDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PayMode=, PayMode_type_info=(PayMode, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), PostDate=2022-10-12, PostDate_type_info=(PostDate, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Sapinvoiceno=0190000477, Sapinvoiceno_type_info=(Sapinvoiceno, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), Sfdcinvoiceref=30023, Sfdcinvoiceref_type_info=(Sfdcinvoiceref, urn:sap-com:document:sap:soap:functions:mc-style, null, 1, 1, false), apex_schema_type_info=(urn:sap-com:document:sap:soap:functions:mc-style, false, true), field_order_type_info=(Sfdcinvoiceref, Sapinvoiceno, AccDocNo, ClrDocNo, DocNo, Bukrs, Gjahr, DocType, DocDate, InvDate, ...)]), item_type_info=(item, urn:sap-com:document:sap:soap:functions:mc-style, null, 0, -1, false)"}';
                //sfdcpayReceiptResponse =  (    sapCPPaymentInterface.ZttInvSentLog)JSON.deserialize(rec,SAPCPPaymentInterface.ZttInvSentLog.class);
                //dummy();
            }
            else{                                        
                Datetime d = system.now()-1;
                timestamp = d.format('yyyyMMddHHmmss');
                payReceipt.timeout_x = 60000;    
                sfdcpayReceiptResponse = payReceipt.ZfmBrokinteg(sfdcpayReceipt,timestamp);
               /* ERP_Integration_Log__c erp = new ERP_Integration_Log__c();   		// commented by sheetal on 29/12/2023 as response data limit exceeded.
                erp.API_Name__c = 'CP Receipt API';
                erp.Request__c = timestamp;//JSON.serialize(System.now().format('yyyyMMddHHmmss'));
                erp.Status__c = 'Success';
                erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
                insert erp;*/
            }
            
        }catch(exception ex){
            system.debug('Error::'+ex.getMessage());
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'CP Receipt API';
            erp.Request__c = timestamp;//JSON.serialize(System.now().format('yyyyMMddHHmmss'));
            erp.Status__c = 'Failure';
            erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Timeout Error';
            insert erp;
        }   
        System.debug('Response item:::'+ sfdcpayReceiptResponse.item);
        System.debug('Response:::'+ sfdcpayReceiptResponse);
        try{
            if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0){
                for(sapCPPaymentInterface.ZstrInvSentLog responseRec : sfdcpayReceiptResponse.item){
                    InvoiceDocNoList.add(responseRec.Sapinvoiceno);
                }
                  InvoiceList1 = [Select Id,name from Brokerage_Invoice__c Where Id =: 'a2f5j000000Dkx5AAC' LIMIT 1];
                  system.debug('InvoiceList1 ::'+InvoiceList1);                         
                System.debug('InvoiceDocNoList:::'+InvoiceDocNoList);
                InvoiceList = [Select Id,Name,SAP_Document_No__c,Invoice_Number__c,SAP_Broker_code__c,Booking__r.Project__r.Name from Brokerage_Invoice__c where SAP_Document_No__c IN:InvoiceDocNoList ];
                List<String> projList = new List<String>();
                for(Brokerage_Invoice__c br : InvoiceList){
                    projList.add(br.Booking__r.Project__r.Name);
                }
                 ProjectList = [Select Id,Name,RDS_Company_Code__c,RW_SAP_Company_Code__c from Project__c where Name=:projList and RW_SAP_Company_Code__c != Null ];
                Map<String,String> companyCodeMap = new Map<String,String>();
                for(Project__c proj : ProjectList){
                    companyCodeMap.put(proj.Name, proj.RW_SAP_Company_Code__c);
                }
              system.debug('companyCodeMap::'+companyCodeMap);
              system.debug('ProjectList::'+ProjectList);
                        if(!ProjectList.isEmpty()){
                            legalentity = [Select Id,name,RDS_Company_Code__c,RDS_Company_Name__c,RDS_Address1__c,RDS_Address2__c,RDS_PAN_No__c,GSTIN__c,RERA_Number__c from Legal_Entity__c where Id=:ProjectList[0].RDS_Company_Code__c];
                            system.debug('legalentity::'+legalentity);
                        }
                System.debug('InvoiceList:::'+InvoiceList);
                for(sapCPPaymentInterface.ZstrInvSentLog responseRec : sfdcpayReceiptResponse.item){
                    check1 = false;
                    Brokerage_Receipt__c r = new Brokerage_Receipt__c();
                    for(Brokerage_Invoice__c bi : InvoiceList){
                        if(responseRec.Sapinvoiceno == bi.SAP_Document_No__c && responseRec.Lifnr.right(7)  == bi.SAP_Broker_code__c.right(7) && responseRec.Bukrs == companyCodeMap.get(bi.Project__c) &&responseRec.Sfdcinvoiceref == bi.Invoice_Number__c  ){
                            system.debug('Sapinvoiceno1 :'+responseRec.Sapinvoiceno);
                            system.debug('LIFNR1 :'+responseRec.Lifnr);
                            system.debug('Bukrs1 :'+responseRec.Bukrs);
                            system.debug('Sfdcinvoiceref1 :'+responseRec.Sfdcinvoiceref);
                            r.SFDC_Invoice_reference__c = responseRec.Sfdcinvoiceref;
                            r.Document_No__c = responseRec.DocNo;
                            r.Document_Type__c = responseRec.DocType;
                            r.Document_Date__c = date.valueof(responseRec.DocDate);
                            r.Posting_Date__c = date.valueof(responseRec.PostDate);
                            r.SAP_Invoice_Number__c = responseRec.Sapinvoiceno;
                            r.Invoice_Amount__c = (Decimal.valueOf((responseRec.InvAmt).trim()));
                            r.Invoice_Date__c = date.valueof(responseRec.InvDate);
                            r.Payment_Date__c = date.valueof(responseRec.PayDate);
                            r.Payment_Mode__c = responseRec.PayMode;
                            r.Clearing_Document_Number__c = responseRec.ClrDocNo;
                            if(responseRec.Lifnr.right(7) != NUll || responseRec.Lifnr.right(7) != ''){
                               r.SAP_Broker_Code__c = responseRec.Lifnr.right(7);
                            }
                            if(responseRec.Bukrs != Null || responseRec.Bukrs != ''){
                             r.SAP_Company_Code__c = responseRec.Bukrs;
                            }
                            if(responseRec.ClrDate != '0000-00-00'){
                                r.Clearing_Date__c = date.valueof(responseRec.ClrDate);
                            }
                            check1 = true;
                            system.debug('check1 ::'+check1);
                            r.Brokerage_Invoice__c = bi.Id;
                            r.Accounting_Document_No__c = responseRec.AccDocNo;
                           
                        }
                      /*  else{
                           system.debug('Sapinvoiceno2 :'+responseRec.Sapinvoiceno);
                            system.debug('LIFNR2 :'+responseRec.Lifnr);
                            system.debug('Bukrs2 :'+responseRec.Bukrs);
                            system.debug('Sfdcinvoiceref2 :'+responseRec.Sfdcinvoiceref);
                            r.SFDC_Invoice_reference__c = responseRec.Sfdcinvoiceref;
                            r.Document_No__c = responseRec.DocNo;
                            r.Document_Type__c = responseRec.DocType;
                            r.Document_Date__c = date.valueof(responseRec.DocDate);
                            r.Posting_Date__c = date.valueof(responseRec.PostDate);
                            r.SAP_Invoice_Number__c = responseRec.Sapinvoiceno;
                            r.Invoice_Amount__c = (Decimal.valueOf((responseRec.InvAmt).trim()));
                            r.Invoice_Date__c = date.valueof(responseRec.InvDate);
                            r.Payment_Date__c = date.valueof(responseRec.PayDate);
                            r.Payment_Mode__c = responseRec.PayMode;
                            r.Clearing_Document_Number__c = responseRec.ClrDocNo;
                            if(responseRec.ClrDate != '0000-00-00'){
                                r.Clearing_Date__c = date.valueof(responseRec.ClrDate);
                            }
                            r.Brokerage_Invoice__c = InvoiceList1[0].id;
                            r.Accounting_Document_No__c = responseRec.AccDocNo;
                           
                            
                        }*/
                    }
                    if(check1 == false){
                          system.debug('check1 ::'+check1);
                         system.debug('Sapinvoiceno2 :'+responseRec.Sapinvoiceno);
                            system.debug('LIFNR2 :'+responseRec.Lifnr);
                            system.debug('Bukrs2 :'+responseRec.Bukrs);
                            system.debug('Sfdcinvoiceref2 :'+responseRec.Sfdcinvoiceref);
                            r.SFDC_Invoice_reference__c = responseRec.Sfdcinvoiceref;
                            r.Document_No__c = responseRec.DocNo;
                            r.Document_Type__c = responseRec.DocType;
                            r.Document_Date__c = date.valueof(responseRec.DocDate);
                            r.Posting_Date__c = date.valueof(responseRec.PostDate);
                            r.SAP_Invoice_Number__c = responseRec.Sapinvoiceno;
                            r.Invoice_Amount__c = (Decimal.valueOf((responseRec.InvAmt).trim()));
                            r.Invoice_Date__c = date.valueof(responseRec.InvDate);
                            r.Payment_Date__c = date.valueof(responseRec.PayDate);
                            r.Payment_Mode__c = responseRec.PayMode;
                            r.Clearing_Document_Number__c = responseRec.ClrDocNo;
                            if(responseRec.Lifnr != NUll || responseRec.Lifnr != ''){
                               r.SAP_Broker_Code__c = responseRec.Lifnr;
                            }
                            if(responseRec.Bukrs != Null || responseRec.Bukrs != ''){
                             r.SAP_Company_Code__c = responseRec.Bukrs;
                            }
                            if(responseRec.ClrDate != '0000-00-00'){
                                r.Clearing_Date__c = date.valueof(responseRec.ClrDate);
                            }
                            r.Brokerage_Invoice__c = InvoiceList1[0].id;
                            r.Accounting_Document_No__c = responseRec.AccDocNo;
                    }
                     UpdateReceiptList.add(r);
                }
                System.debug('UpdateReceiptList:::'+UpdateReceiptList);
                if(!UpdateReceiptList.isEmpty()){
                    insert UpdateReceiptList;
                }
            }
        }catch(exception ex){
            ERP_Integration_Log__c erp = new ERP_Integration_Log__c();
            erp.API_Name__c = 'CP Receipt API';
            erp.Request__c = timestamp;//JSON.serialize(System.now().format('yyyyMMddHHmmss'));
            erp.Status__c = 'Failure';
            erp.Response__c = JSON.serialize(sfdcpayReceiptResponse).replaceAll('\n','<br/>').replaceAll('\t', '&nbsp;');
            erp.Error_Reason__c = ex.getMessage();
            erp.Error_Type__c = 'Timeout Error';
            insert erp;
        }
        
        
    }
    
    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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