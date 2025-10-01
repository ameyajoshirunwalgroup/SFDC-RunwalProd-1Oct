global class BatchSAPPaymentInterface implements 
    Database.Batchable<sObject>, Database.Stateful ,Database.AllowsCallouts 
{

    private List<RW_Payment_Details__c> lstPaymentDet = new List<RW_Payment_Details__c>();
    public List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    Map<String,RW_Payment_Details__c> sapResponseMap = new Map<String,RW_Payment_Details__c>();
    List<RW_Payment_Details__c> payDetailsInsert = new List<RW_Payment_Details__c>();    
    List<RW_Payment_Details__c> payDetailsUpdate = new List<RW_Payment_Details__c>();  
   /* public BatchSAPPaymentInterface(List<RW_Payment_Details__c> payDetailRecords) {
        lstPaymentDet = payDetailRecords;
    }*/
    
    
      global Database.QueryLocator start(Database.BatchableContext BC)
      {
           
      /* SAPPaymentInterface sapPaymentInterface = new SAPPaymentInterface();
       sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT payReceipt= new sapPaymentInterface.ZSD_SFDC_PAYMENT_RECEIPT();
       
       sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceipt= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
       sapPaymentInterface.ZsdtSfdcPaymentReceipt sfdcpayReceiptResponse= new sapPaymentInterface.ZsdtSfdcPaymentReceipt();
       System.debug('*before call*');
       sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,System.now().format('yyyyMMddHHmmss'));
       System.debug('**'+System.now().format('yyyyMMddHHmmss'));
       //sfdcpayReceiptResponse = payReceipt.ZsdSfdcPaymentReceipt(sfdcpayReceipt,'20201023184736');
       
       System.debug('*after call*'+ sfdcpayReceiptResponse);
       Map<String,Opportunity> customerOppMap = new Map<String,Opportunity>();
       Map<String,String> PaymentDetUniqueIdMap = new Map<String,String>();
       //List<RW_Payment_Details__c> payDetailsInsert = new List<RW_Payment_Details__c>();    
        //List<RW_Payment_Details__c> payDetailsUpdate = new List<RW_Payment_Details__c>();    
       
       List<RW_Payment_Details__c> payDetailsList = new List<RW_Payment_Details__c>();
  
       Set<String>  cutomerIds = new Set<String>(); 
       //List<String> chequeCode = new List<String>{'DF','DE','D1','DZ','DT'};
       List<String> chequeCode = new List<String>{'DF','DE'};
       if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
       {
       for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
       {
           if(chequeCode.contains(responseRec.HBlart) && responseRec.kunnr != null && responseRec.kunnr != '')
           {
               cutomerIds.add(responseRec.kunnr);
           }
       }
       }
           
	 List<Opportunity> opprec = [Select Id, Name,SAP_Customer_Number__c,(Select id,Name FROM EOI__r) from Opportunity where SAP_Customer_Number__c IN:cutomerIds ];
            for(Opportunity oppRecord : opprec)
            {
                if(oppRecord.EOI__r.size() >0)
                {
                System.debug('*added in map**');
                customerOppMap.put(oppRecord.SAP_Customer_Number__c, oppRecord);
                }
            }
          
         Set<String> uniqueIds = new Set<String>(); 
         
       if(sfdcpayReceiptResponse != null && sfdcpayReceiptResponse.item != null && sfdcpayReceiptResponse.item.size() >0)
       {
       for(SAPPaymentInterface.ZsdSfdcPaymentReceipt responseRec : sfdcpayReceiptResponse.item)
       {
           //if(responseRec.HBlart == 'DF' || responseRec.HBlart == 'DE' || responseRec.HBlart =='D1')
           if(chequeCode.contains(responseRec.HBlart))
           {
           RW_Payment_Details__c payDet = new RW_Payment_Details__c();
            payDet.RW_Customer_ID__c = responseRec.kunnr;
               //system.debug('*5**'+responseRec.Bldat);
            payDet.RW_Payment_Date__c = Date.valueOf(responseRec.Bldat);
            payDet.RW_Posting_Date__c = Date.valueOf(responseRec.HBudat);
            payDet.RW_Document_Type__c = responseRec.HBlart;
            payDet.RW_Instrument_Number__c = responseRec.Zuonr;
            if(responseRec.Dmbtr != null && responseRec.Dmbtr !='')
            payDet.RW_Payment_Amount__c =  Decimal.valueOf(responseRec.Dmbtr);
            payDet.RW_Fiscal_Year__c = responseRec.Gjahr;
            payDet.RW_Accounting_Document_Number__c = responseRec.Belnr; 
            payDet.RW_Company_Code__c=responseRec.Bukrs;
            payDet.RW_Document_Header_Text__c=responseRec.Bktxt;
            payDet.RW_Status_Description__c = responseRec.ZstatusDescp;
            payDet.RW_Clearing_Document_Number__c = responseRec.Augbl;
            payDet.RW_Status_Code__c=responseRec.ZstatusCode;
            payDet.RW_ODN_Number__c = responseRec.Zodn;
            payDet.RW_Usage_Code__c = responseRec.Xref1;
            payDet.RW_Usage_Description__c=responseRec.Sgtxt;
            payDet.RW_Demand_Number__c = responseRec.Zdemand;
            if(customerOppMap.containsKey(responseRec.kunnr) || Test.isRunningTest())
            {
            if(!Test.isRunningTest())
            {
			payDet.Opportunity__c =  customerOppMap.get(responseRec.kunnr).Id;
            }
            sapResponseMap.put(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs+'|'+responseRec.Zdemand,payDet) ;  
            
            }
            //uniqueIds.add(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs+'|'+responseRec.Zdemand);
            //sapResponseMap.put(responseRec.Belnr+'|'+responseRec.Gjahr+'|'+responseRec.Bukrs+'|'+responseRec.Zdemand,payDet) ;  
            //lstPaymentDet.add(payDet);
           }
       }
           
       }
          
           for(RW_Payment_Details__c paydet : sapResponseMap.Values())
           {
               system.debug('**inside insert all*'+paydet);
             payDetailsInsert.add(paydet);  
           }
      //return Database.getQueryLocator([Select Id,RW_UniqueId__c from RW_Payment_Details__c]);
          System.debug('**'+uniqueIds);
          Set<String> Keys = sapResponseMap.keyset();*/
           Set<String> Keys = new  Set<String>();
          //String soqlQuery = 'SELECT Id, RW_UniqueId__c From RW_Payment_Details__c Where RW_UniqueId__c IN :uniqueIds';
          String soqlQuery = 'SELECT Id, RW_UniqueId__c,RW_Status_Code__c,RW_Status_Description__c,RW_Clearing_Document_Number__c From RW_Payment_Details__c Where RW_UniqueId__c IN :Keys';
          return Database.getQueryLocator(soqlQuery);
          
         
      }

   global void execute(
                Database.BatchableContext BC, 
                List<RW_Payment_Details__c> scope)
   {
       
		
       for(RW_Payment_Details__c existingpaydet1 : scope)
           {
               System.debug('scope'+existingpaydet1+'**'+existingpaydet1.RW_Status_Code__c);
           }
      /* for(RW_Payment_Details__c paydet : lstPaymentDet)
       {
           
     	for(RW_Payment_Details__c existingpaydet : scope)
           {
               if(existingpaydet.RW_UniqueId__c == paydet.RW_Accounting_Document_Number__c +'|'+ paydet.RW_Fiscal_Year__c +'|'+ paydet.RW_Company_Code__c+'|'+paydet.RW_Demand_Number__c)
               {
                    paydet.Id = existingpaydet.Id;
                    
               }
           }
   } */
    /*   
       for(RW_Payment_Details__c paydet : sapResponseMap.Values())
       {
         //payDetailsInsert.add(paydet);  
     	for(RW_Payment_Details__c existingpaydet : scope)
           {
               if(existingpaydet.RW_UniqueId__c == paydet.RW_Accounting_Document_Number__c +'|'+ paydet.RW_Fiscal_Year__c +'|'+ paydet.RW_Company_Code__c+'|'+paydet.RW_Demand_Number__c) 
               {
                   for(Integer i=0; i<payDetailsInsert.size(); i++) 
                    {
                        if(paydet== payDetailsInsert.get(i))
                        {
                            system.debug('*removed*');
                            payDetailsInsert.remove(i);
                        }
                    }
                   
                   if(   (paydet.RW_Status_Code__c != '' && existingpaydet.RW_Status_Code__c !=paydet.RW_Status_Code__c)
                      || (paydet.RW_Status_Code__c == '' && existingpaydet.RW_Status_Code__c != null )
                      || (paydet.RW_Status_Description__c!='' && existingpaydet.RW_Status_Description__c != paydet.RW_Status_Description__c) 
                      || (paydet.RW_Status_Description__c=='' && existingpaydet.RW_Status_Description__c != null)
                      || (paydet.RW_Clearing_Document_Number__c!='' && existingpaydet.RW_Clearing_Document_Number__c != paydet.RW_Clearing_Document_Number__c)
                      || (paydet.RW_Clearing_Document_Number__c=='' && existingpaydet.RW_Clearing_Document_Number__c != null)
                     )
                   {
                    system.debug('**change**'+existingpaydet.RW_Status_Code__c+'^'+paydet.RW_Status_Code__c);
                    system.debug('**id**'+existingpaydet.Id+'before id'+paydet.Id);
                       
                    paydet.Id = existingpaydet.Id;
                    payDetailsUpdate.add(paydet);
                   
                       
                    /*if(payDetailsInsert.contains(paydet))
                    {
                        system.debug('**inside remove**'+paydet);
                    payDetailsInsert.remove(paydet);
                    }
                   }
                    
               }
           }
   }*/
       
       
   }

global void finish(Database.BatchableContext BC)
   {
        //List<RW_Payment_Details__c> payDetailsInsert = new List<RW_Payment_Details__c>();    
        //List<RW_Payment_Details__c> payDetailsUpdate = new List<RW_Payment_Details__c>();  
      /* for(RW_Payment_Details__c paydetail : lstPaymentDet)
       {
           if(paydetail.Id != null)
           {
               payDetailsUpdate.add(paydetail);
           }
           
           else
           {
               payDetailsInsert.add(paydetail);
           }
       }*/
       
       
      /* for(RW_Payment_Details__c paydetail : sapResponseMap.Values())
       {
           system.debug('**check1**'+paydetail);
           if(paydetail.Id == null && paydetail.Opportunity__c != null)
           {
                payDetailsInsert.add(paydetail);
               
           }
           
           else
           {
               if(paydetail.Id != null)
               payDetailsUpdate.add(paydetail);
           }
       }*/
       
       /*
       if(payDetailsInsert.size() >0)
        {
            system.debug('inside insert');
            Database.SaveResult[] srList = Database.insert(payDetailsInsert, false);
            
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                if (srList[i].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted payment details. Payment Details ID: ' + srList[i]);
                }
                else {
                    // Operation failed, so get all errors                
                   
                        System.debug('The following error has occurred during payment insert.');                    
                        //System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('Payment fields that affected this error: ' + err.getFields());
                        
                    ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                    log.API_name__c = 'Payment Interface';
                    log.Status__c = 'Failure';
                    if(srList[i].getErrors().size() >0)
                    log.Error_Reason__c = srList[i].getErrors()[0].getMessage()+'Fields-'+srList[i].getErrors()[0].getFields();
                    log.Opportunity__c = payDetailsInsert[i].Opportunity__c;
                    erpLogList.add(log);
                        
                    }
                
                
                
                
            }
        }
        
      if(payDetailsUpdate.size() >0)
        {
            Database.SaveResult[] srList = Database.update(payDetailsUpdate, false);
            
            // Iterate through each returned result
            for (Integer i=0;i<srList.size();i++) {
                if (srList[i].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully updated payment Record: ' + srList[i].getId());
                }
                else {
                    // Operation failed, so get all errors                
                   
                        System.debug('The following error has occurred during payment update.');                    
                       // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        //System.debug('Payment fields that affected this error: ' + err.getFields());
                    ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                    log.API_name__c = 'Payment Interface';
                    log.Status__c = 'Failure';
                    if(srList[i].getErrors().size() >0)
                    log.Error_Reason__c = srList[i].getErrors()[0].getMessage()+'Fields-'+srList[i].getErrors()[0].getFields();
                    log.Opportunity__c = payDetailsUpdate[i].Opportunity__c;
                    erpLogList.add(log);
                }
                
                
                
            }
        }
       
       if(erpLogList.size() >0)
       {
           insert erpLogList;
       }*/
   }
}