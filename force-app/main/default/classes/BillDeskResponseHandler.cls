@RestResource(urlMapping='/BillDeskResponseHandler')
global class BillDeskResponseHandler 
{
    @HttpPost
    global static void insertBillDeskDetails()
    {
        ERP_Integration_Log__c integrationLog = new ERP_Integration_Log__c();
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        //BillDeskResponse.test();
        system.debug('*firsttest1*'+BillDeskResFormat);
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
     	system.debug('*firsttest*'+BillDeskResFormat);
        Receipt__c receiptRecord = new Receipt__c();
        //System.debug('*inside*');
        RestRequest req = RestContext.request;
        system.debug('**'+req);
         //system.debug('**'+req.requestBody+'*****'+req.requestBody.toString()+'**'+req.params.get('msg'));
        //String inputMessage = req.requestBody.toString();
        String inputMessage=req.params.get('msg');
        system.debug('*input req*'+req.params.get('msg')+'**'+inputMessage);
        List<String> splitInput = inputMessage.split('\\|');
        system.debug('***'+splitInput);
        //String BillDeskInput='';
        String actualinputData = inputMessage.substring(0,inputMessage.lastIndexOf('|'));
        //List<String> actualinputDataArray = actualinputData.split('\\|');
        String pipe = '\\|';
        //system.debug('*test*'+actualinputData.replaceAll('&#124;', '|'));
        //actualinputData = actualinputData.replaceAll('&#124;', '|');
        
        system.debug('*actualinputData**'+actualinputData);
        String checksumValue = inputMessage.substring(inputMessage.lastIndexOf('|')+1);
        system.debug('*checksumValue**'+checksumValue);
        //String[] splitInput = inputMessage.split('|');
        
        List<Opportunity> oppRec = [Select Id , Name ,Booking__c, RW_Project__c,RW_Project__r.Name , RW_Project_Unit__c, RW_Project_Unit__r.TowerName__r.Name from Opportunity Where SalesOrder_Number__c=: splitInput[BillDeskResFormat1.indexOf('AdditionalInfo1')] and SAP_Customer_Number__c =:splitInput[BillDeskResFormat1.indexOf('AdditionalInfo2')]];
        if(oppRec.size() >0)
        {  
         System.debug('*11*'+oppRec[0].RW_Project__r.Name+'**'+oppRec[0].RW_Project_Unit__r.TowerName__r.Name);
         List<Payment_Gateway__mdt> paymentMappings =  Utility.getBIllDeskPaymentGatewayDetails(oppRec[0].RW_Project__r.Name , oppRec[0].RW_Project_Unit__r.TowerName__r.Name);  
         if(paymentMappings.size() >0)
         {
             String ChecksumKey='';
             String paymentType='';
             system.debug('*first*'+splitInput[BillDeskResFormat1.indexOf('MerchantID')]+'**'+paymentMappings[0].Bill_Desk_Merchant_ID__c+'**'+paymentMappings[0].Bill_Desk_GST_Merchant_ID__c);
             if(splitInput[BillDeskResFormat1.indexOf('MerchantID')] == paymentMappings[0].Bill_Desk_Merchant_ID__c)
             {
             ChecksumKey = paymentMappings[0].Bill_Desk_Checksum_Key__c;
             paymentType = 'Normal';
             }
             else if(splitInput[BillDeskResFormat1.indexOf('MerchantID')] == paymentMappings[0].Bill_Desk_GST_Merchant_ID__c)
             {
             ChecksumKey = paymentMappings[0].Bill_Desk_GST_Checksum_Key__c; 
             paymentType = 'GST';
             }
             
             system.debug('**ee**'+paymentMappings[0].Bill_Desk_Checksum_Key__c+'**'+ChecksumKey);
             //system.debug('inside first if'+checksumValue+'**'+Utility.getChecksumKey(actualinputData,ChecksumKey) + '**'+checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey));
             system.debug('inside first if'+checksumValue + '**'+ChecksumKey); 
             String checkValue = Utility.getChecksumKey(actualinputData,ChecksumKey);
             system.debug('*checkValue'+checkValue);
             if(ChecksumKey != '')
              {
                  system.debug('inside first if 1*'+checksumValue+'**'+checkValue);
                  system.debug('*comapare*'+checksumValue.equals(checkValue));
                  if(checksumValue.trim().equals(checkValue.trim()))
                  {
                 system.debug('inside first if 2');
                 receiptRecord.Mode__c = 'Digital';
                 receiptRecord.Cheque_DD__c = splitInput.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
                 receiptRecord.Total_Amount__c = Decimal.valueof(splitInput.get(BillDeskResFormat1.indexOf('TxnAmount')));
                 switch on (splitInput.get(BillDeskResFormat1.indexOf('TxnType'))){
                        when '01' { receiptRecord.BillDesk_Payment_Mode__c = 'Net Banking'; }
                        when '02' { receiptRecord.BillDesk_Payment_Mode__c = 'Credit Card'; }
                        when '03' { receiptRecord.BillDesk_Payment_Mode__c = 'Debit Card'; }
                        when '04' { receiptRecord.BillDesk_Payment_Mode__c = 'Cash Card'; }
                        when '05' { receiptRecord.BillDesk_Payment_Mode__c = 'Mobile Wallet'; }
                        when '06' { receiptRecord.BillDesk_Payment_Mode__c = 'IMPS'; }
                        when '07' { receiptRecord.BillDesk_Payment_Mode__c = 'Reward Points'; }
                        when '08' { receiptRecord.BillDesk_Payment_Mode__c = 'Rupay'; }
                        when '10' { receiptRecord.BillDesk_Payment_Mode__c = 'UPI'; }
                        when else { receiptRecord.BillDesk_Payment_Mode__c = 'Others'; }  
                    }
                 receiptRecord.Project__c = oppRec[0].RW_Project__c;
                 receiptRecord.Project_Unit__c = oppRec[0].RW_Project_Unit__c;
                 receiptRecord.Payment_Gateway__c = 'BillDesk';
                 if(paymentType == 'Normal')
				 receiptRecord.RW_Payment_Collection_Type__c = 'SAP Demands - Flat Cost';
                 else if(paymentType == 'GST')
                 receiptRecord.RW_Payment_Collection_Type__c = 'SAP Demands - GST';  
                 receiptRecord.Booking__c = oppRec[0].Booking__c;
                 receiptRecord.Opportunity__c =oppRec[0].Id;
                 String dateFormat = splitInput.get(BillDeskResFormat1.indexOf('TxnDate'));    
                 receiptRecord.Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));
                  
                 //receiptRecord[0].Cheque_DD_Date__c = Date.valueof(msgList.get(BillDeskResFormat1.indexOf('TxnDate')).split(' ')));
                 receiptRecord.Receipt_Status__c = splitInput.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300' ? 'Success' : 'Failure';
                      try{
                      insert receiptRecord;
                      }
                      catch(Exception e)
                      {
                         integrationLog.API_Name__c ='SAP BillDesk';
                        integrationLog.Request__c = req.params.get('msg');
                        integrationLog.Error_Type__c = 'Timeout Error';
                        integrationLog.Status__c ='Failure';
                        integrationLog.Error_Reason__c =e.getMessage();
                        insert integrationLog; 
                      }
                  }
                  else
                  {
                        integrationLog.API_Name__c ='SAP BillDesk';
                        integrationLog.Request__c = req.params.get('msg');
                        integrationLog.Error_Type__c = 'Data Error';
                        integrationLog.Status__c ='Failure';
                        integrationLog.Error_Reason__c ='Checksum Value Generated did not match with Checksum Value received from Bill Desk';
                        insert integrationLog;
                  }
              }
             else
             {
                 integrationLog.API_Name__c ='SAP BillDesk';
                integrationLog.Request__c = req.params.get('msg');
                integrationLog.Error_Type__c = 'Data Error';
                integrationLog.Status__c ='Failure';
                integrationLog.Error_Reason__c ='Merchant ID not found in Salesforce Custom Metadata for this Project and Tower';
                insert integrationLog;
             }
         }
            
            else
            {
            integrationLog.API_Name__c ='SAP BillDesk';
            integrationLog.Request__c = req.params.get('msg');
            integrationLog.Error_Type__c = 'Data Error';
            integrationLog.Status__c ='Failure';
            integrationLog.Error_Reason__c ='No Payment Gateway Details found in Custom metadata for this Project and Tower';
            insert integrationLog;
            }
        }
        
        else
        {
            integrationLog.API_Name__c ='SAP BillDesk';
            integrationLog.Request__c = req.params.get('msg');
            integrationLog.Error_Type__c = 'Data Error';
            integrationLog.Status__c ='Failure';
            integrationLog.Error_Reason__c ='No Opportunity found for the customer number and SalesOrder Number received in request';
            insert integrationLog;
        }
        

    }
    
     @HttpGet
    global static void insertBillDeskDetailsData()
    {
         ERP_Integration_Log__c integrationLog = new ERP_Integration_Log__c();
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        //BillDeskResponse.test();
        system.debug('*firsttest1*'+BillDeskResFormat);
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
     	system.debug('*firsttest*'+BillDeskResFormat);
        Receipt__c receiptRecord = new Receipt__c();
        //System.debug('*inside*');
        RestRequest req = RestContext.request;
        system.debug('**'+req);
         //system.debug('**'+req.requestBody+'*****'+req.requestBody.toString()+'**'+req.params.get('msg'));
        //String inputMessage = req.requestBody.toString();
        String inputMessage=req.params.get('msg');
        system.debug('*input req*'+req.params.get('msg')+'**'+inputMessage);
        List<String> splitInput = inputMessage.split('\\|');
        system.debug('***'+splitInput);
        //String BillDeskInput='';
        String actualinputData = inputMessage.substring(0,inputMessage.lastIndexOf('|'));
        //List<String> actualinputDataArray = actualinputData.split('\\|');
        String pipe = '\\|';
        //system.debug('*test*'+actualinputData.replaceAll('&#124;', '|'));
        //actualinputData = actualinputData.replaceAll('&#124;', '|');
        
        system.debug('*actualinputData**'+actualinputData);
        String checksumValue = inputMessage.substring(inputMessage.lastIndexOf('|')+1);
        system.debug('*checksumValue**'+checksumValue);
        //String[] splitInput = inputMessage.split('|');
        
        List<Opportunity> oppRec = [Select Id , Name ,Booking__c, RW_Project__c,RW_Project__r.Name , RW_Project_Unit__c, RW_Project_Unit__r.TowerName__r.Name from Opportunity Where SalesOrder_Number__c=: splitInput[BillDeskResFormat1.indexOf('AdditionalInfo1')] and SAP_Customer_Number__c =:splitInput[BillDeskResFormat1.indexOf('AdditionalInfo2')]];
        if(oppRec.size() >0)
        {  
         System.debug('*11*'+oppRec[0].RW_Project__r.Name+'**'+oppRec[0].RW_Project_Unit__r.TowerName__r.Name);
         List<Payment_Gateway__mdt> paymentMappings =  Utility.getBIllDeskPaymentGatewayDetails(oppRec[0].RW_Project__r.Name , oppRec[0].RW_Project_Unit__r.TowerName__r.Name);  
         if(paymentMappings.size() >0)
         {
             String ChecksumKey='';
             String paymentType='';
             system.debug('*first*'+splitInput[BillDeskResFormat1.indexOf('MerchantID')]+'**'+paymentMappings[0].Bill_Desk_Merchant_ID__c+'**'+paymentMappings[0].Bill_Desk_GST_Merchant_ID__c);
             if(splitInput[BillDeskResFormat1.indexOf('MerchantID')] == paymentMappings[0].Bill_Desk_Merchant_ID__c)
             {
             ChecksumKey = paymentMappings[0].Bill_Desk_Checksum_Key__c;
             paymentType = 'Normal';
             }
             else if(splitInput[BillDeskResFormat1.indexOf('MerchantID')] == paymentMappings[0].Bill_Desk_GST_Merchant_ID__c)
             {
             ChecksumKey = paymentMappings[0].Bill_Desk_GST_Checksum_Key__c; 
             paymentType = 'GST';
             }
             
             system.debug('**ee**'+paymentMappings[0].Bill_Desk_Checksum_Key__c+'**'+ChecksumKey);
             //system.debug('inside first if'+checksumValue+'**'+Utility.getChecksumKey(actualinputData,ChecksumKey) + '**'+checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey));
             system.debug('inside first if'+checksumValue + '**'+ChecksumKey); 
             String checkValue = Utility.getChecksumKey(actualinputData,ChecksumKey);
             system.debug('*checkValue'+checkValue);
             if(ChecksumKey != '')
              {
                  system.debug('inside first if 1*'+checksumValue+'**'+checkValue);
                  system.debug('*comapare*'+checksumValue.equals(checkValue));
                  if(checksumValue.trim().equals(checkValue.trim()))
                  {
                 system.debug('inside first if 2');
                 receiptRecord.Mode__c = 'Digital';
                 receiptRecord.Cheque_DD__c = splitInput.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
                 receiptRecord.Total_Amount__c = Decimal.valueof(splitInput.get(BillDeskResFormat1.indexOf('TxnAmount')));
                 switch on (splitInput.get(BillDeskResFormat1.indexOf('TxnType'))){
                        when '01' { receiptRecord.BillDesk_Payment_Mode__c = 'Net Banking'; }
                        when '02' { receiptRecord.BillDesk_Payment_Mode__c = 'Credit Card'; }
                        when '03' { receiptRecord.BillDesk_Payment_Mode__c = 'Debit Card'; }
                        when '04' { receiptRecord.BillDesk_Payment_Mode__c = 'Cash Card'; }
                        when '05' { receiptRecord.BillDesk_Payment_Mode__c = 'Mobile Wallet'; }
                        when '06' { receiptRecord.BillDesk_Payment_Mode__c = 'IMPS'; }
                        when '07' { receiptRecord.BillDesk_Payment_Mode__c = 'Reward Points'; }
                        when '08' { receiptRecord.BillDesk_Payment_Mode__c = 'Rupay'; }
                        when '10' { receiptRecord.BillDesk_Payment_Mode__c = 'UPI'; }
                        when else { receiptRecord.BillDesk_Payment_Mode__c = 'Others'; }  
                    }
                 receiptRecord.Project__c = oppRec[0].RW_Project__c;
                 receiptRecord.Project_Unit__c = oppRec[0].RW_Project_Unit__c;
                 receiptRecord.Payment_Gateway__c = 'BillDesk';
                 if(paymentType == 'Normal')
				 receiptRecord.RW_Payment_Collection_Type__c = 'SAP Demands - Flat Cost';
                 else if(paymentType == 'GST')
                 receiptRecord.RW_Payment_Collection_Type__c = 'SAP Demands - GST';  
                 receiptRecord.Booking__c = oppRec[0].Booking__c;
                 receiptRecord.Opportunity__c =oppRec[0].Id;
                 String dateFormat = splitInput.get(BillDeskResFormat1.indexOf('TxnDate'));    
                 receiptRecord.Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));
                  
                 //receiptRecord[0].Cheque_DD_Date__c = Date.valueof(msgList.get(BillDeskResFormat1.indexOf('TxnDate')).split(' ')));
                 receiptRecord.Receipt_Status__c = splitInput.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300' ? 'Success' : 'Failure';
                      try{
                      insert receiptRecord;
                      }
                      catch(Exception e)
                      {
                         integrationLog.API_Name__c ='SAP BillDesk';
                        integrationLog.Request__c = req.params.get('msg');
                        integrationLog.Error_Type__c = 'Timeout Error';
                        integrationLog.Status__c ='Failure';
                        integrationLog.Error_Reason__c =e.getMessage();
                        insert integrationLog; 
                      }
                  }
                  else
                  {
                        integrationLog.API_Name__c ='SAP BillDesk';
                        integrationLog.Request__c = req.params.get('msg');
                        integrationLog.Error_Type__c = 'Data Error';
                        integrationLog.Status__c ='Failure';
                        integrationLog.Error_Reason__c ='Checksum Value Generated did not match with Checksum Value received from Bill Desk';
                        insert integrationLog;
                  }
              }
             else
             {
                 integrationLog.API_Name__c ='SAP BillDesk';
                integrationLog.Request__c = req.params.get('msg');
                integrationLog.Error_Type__c = 'Data Error';
                integrationLog.Status__c ='Failure';
                integrationLog.Error_Reason__c ='Merchant ID not found in Salesforce Custom Metadata for this Project and Tower';
                insert integrationLog;
             }
         }
            
            else
            {
            integrationLog.API_Name__c ='SAP BillDesk';
            integrationLog.Request__c = req.params.get('msg');
            integrationLog.Error_Type__c = 'Data Error';
            integrationLog.Status__c ='Failure';
            integrationLog.Error_Reason__c ='No Payment Gateway Details found in Custom metadata for this Project and Tower';
            insert integrationLog;
            }
        }
        
        else
        {
            integrationLog.API_Name__c ='SAP BillDesk';
            integrationLog.Request__c = req.params.get('msg');
            integrationLog.Error_Type__c = 'Data Error';
            integrationLog.Status__c ='Failure';
            integrationLog.Error_Reason__c ='No Opportunity found for the customer number and SalesOrder Number received in request';
            insert integrationLog;
        }
        
        
    }
}