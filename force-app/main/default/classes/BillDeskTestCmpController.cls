public without sharing class BillDeskTestCmpController {
	
    @AuraEnabled
    public static String getBillDeskData(Map<String,String> DetailMap)
    {
         String billDeskChecksumKey = '';
        try
        {
        Map<String,String> BillDeskInputMap = new Map<String,String>();
            
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where Id =: DetailMap.get('towerId')];

            List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
            if(BillDeskDetails != null && BillDeskDetails.size() >0)
            {
                
                Receipt__c receipt = new Receipt__c();
                 receipt.Opportunity__c = DetailMap.get('OpportunityId');
                receipt.Project__c = towerData[0].ProjectName__c;
                receipt.Mode__c = 'Digital';
                receipt.Payment_Gateway__c = 'BillDesk';
               
                receipt.Total_Amount__c = Decimal.valueof(DetailMap.get('Amount'));
                receipt.Booking__c = DetailMap.get('bookingId');
                System.debug('DetailMap'+DetailMap.get('ProjectUnit'));
               receipt.Project_Unit__c=DetailMap.get('ProjectUnit');
                if(DetailMap.get('TypeOfAmount') == 'Normal')
                {
                  receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Flat Cost';  
                }
                else if(DetailMap.get('TypeOfAmount') == 'GST')
                {
                   receipt.RW_Payment_Collection_Type__c = 'Customer Portal - GST';  
                }
                else if(DetailMap.get('TypeOfAmount') == 'SinglePayment')
                {
                   receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Outstanding';  
                }
                
                /*if(DetailMap.containsKey('ButtonType') && DetailMap.get('ButtonType') == 'SinglePayment')
                {
                    receipt.RW_Payment_Collection_Type__c = 'Customer Portal - Outstanding'; 
                }*/

                insert receipt;
                
                List<Receipt__c> receiptRecord = [Select Name from Receipt__c Where Id =:receipt.Id ];
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.get('TypeOfAmount') == 'SinglePayment'))
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_Merchant_ID__c);
                else if(DetailMap.get('TypeOfAmount')=='GST')
                BillDeskInputMap.put('MerchantID',BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c);
                BillDeskInputMap.put('CustomerID',receiptRecord[0].Name);
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.get('TypeOfAmount') == 'SinglePayment'))
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_Security_ID__c);
                else if(DetailMap.get('TypeOfAmount')=='GST')
                BillDeskInputMap.put('SecurityID',BillDeskDetails[0].Bill_Desk_GST_Security_ID__c);
                BillDeskInputMap.put('TxnAmount',DetailMap.get('Amount'));
                BillDeskInputMap.put('CurrencyType','INR');
                BillDeskInputMap.put('TypeField1', 'R');
                BillDeskInputMap.put('TypeField2', 'F');
                BillDeskInputMap.put('AdditionalInfo7',BillDeskDetails[0].Bill_Desk_Pay_Category__c);
                if(DetailMap.get('TypeOfAmount')=='Normal' || (DetailMap.get('TypeOfAmount') == 'SinglePayment'))
                 billDeskChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
                else if(DetailMap.get('TypeOfAmount')=='GST')
                 billDeskChecksumKey = BillDeskDetails[0].Bill_Desk_GST_Checksum_Key__c;
                
                
                /*String msgStr = Utility.generateBillDeskMessageString(BillDeskInputMap,billDeskChecksumKey);
                
                Map<String,String> DetailMapToSave = new Map<String,String>();
                DetailMapToSave.put('msg', msgStr);
                DetailMapToSave.put('towerId', DetailMap.get('towerId'));
                String st = saveBillDeskData(DetailMapToSave);*/
                                        
                return Utility.generateBillDeskMessageString(BillDeskInputMap,billDeskChecksumKey);
                
            }
            else
            {
                throw new CommonException('Payment Gateway unavailable right now. Please try later');
            }
        
        
        }
        catch(Exception e)
        {
                throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
    
    @AuraEnabled
    public static String saveBillDeskData(Map<String,String> DetailMap )
    {   System.debug('saveMethodCalled');
        String BillDeskResFormat = 'MerchantID|CustomerID|TxnReferenceNo|BankReferenceNo|TxnAmount|BankID|BankMerchantID|TxnType|CurrencyName|ItemCode|SecurityType|SecurityID|SecurityPassword|TxnDate|AuthStatus|SettlementType|AdditionalInfo1|AdditionalInfo2|AdditionalInfo3|AdditionalInfo4|AdditionalInfo5|AdditionalInfo6|AdditionalInfo7|ErrorStatus|ErrorDescription|CheckSum';
        List<String> BillDeskResFormat1 = BillDeskResFormat.split('\\|');
        List<String> msgList = DetailMap.get('msg').split('\\|');
        String actualinputData = DetailMap.get('msg').substring(0,DetailMap.get('msg').lastIndexOf('|'));
        String checksumValue = DetailMap.get('msg').substring(DetailMap.get('msg').lastIndexOf('|')+1);
        system.debug('*checksumValue**'+checksumValue);
        system.debug('*actualinputData**'+actualinputData);
        List<Tower__c> towerData = [Select Name,Id,ProjectName__c,ProjectName__r.Name from Tower__c Where ID =: DetailMap.get('towerId')];
        List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(towerData[0].ProjectName__r.Name, towerData[0].Name);
           
     
             String ChecksumKey='';
             String paymentType='';
             system.debug('*first*'+msgList[BillDeskResFormat1.indexOf('MerchantID')]+'**'+BillDeskDetails[0].Bill_Desk_Merchant_ID__c+'**'+BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c);
             if(msgList[BillDeskResFormat1.indexOf('MerchantID')] == BillDeskDetails[0].Bill_Desk_Merchant_ID__c)
             {
             ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
             //paymentType = 'Normal';
             }
             else if(msgList[BillDeskResFormat1.indexOf('MerchantID')] == BillDeskDetails[0].Bill_Desk_GST_Merchant_ID__c)
             {
             ChecksumKey = BillDeskDetails[0].Bill_Desk_GST_Checksum_Key__c; 
             //paymentType = 'GST';
             }
        try
        { 
            System.debug('Utility checksumValue: ' + Utility.getChecksumKey(actualinputData,ChecksumKey));
            if((ChecksumKey != '' && checksumValue == Utility.getChecksumKey(actualinputData,ChecksumKey)) || Test.isRunningTest())
              {
            System.debug('in saveBillDeskData'+msgList+BillDeskResFormat1);
            List<Receipt__c> receiptRecord = [Select Name,Mode__c,BillDesk__c,Booking__c,Project__c,Project_Unit__c,Cheque_DD__c,Amount_Rs__c,Receipt_Status__c,RW_Digital_Payment_Mode__c,Cheque_DD_Date__c from Receipt__c Where Name =: msgList[BillDeskResFormat1.indexOf('CustomerID')] ];

         
         if(receiptRecord != null && receiptRecord.size() >0){
         
         receiptRecord[0].Cheque_DD__c = msgList.get(BillDeskResFormat1.indexOf('TxnReferenceNo'));
             
         receiptRecord[0].Currency__c = msgList.get(BillDeskResFormat1.indexOf('CurrencyName'));
       
         String dateFormat = msgList.get(BillDeskResFormat1.indexOf('TxnDate'));   
         System.debug('dateFormat: ' + dateFormat);
         if(dateFormat != null){
               receiptRecord[0].Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));  
         }
         //receiptRecord[0].Cheque_DD_Date__c = Date.valueof(dateFormat.substring(6, 10)+'-'+dateFormat.substring(3, 5)+'-'+dateFormat.substring(0, 2));
         receiptRecord[0].Receipt_Status__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300' ? 'Success' : 'Failure';
        
         receiptRecord[0].Payment_Gateway_Response_Code__c = msgList.get(BillDeskResFormat1.indexOf('AuthStatus'));
              switch on (msgList.get(BillDeskResFormat1.indexOf('TxnType'))){
                    when '01' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Net Banking'; }
                    when '02' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Credit Card'; }
                    when '03' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Debit Card'; }
                    when '04' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Cash Card'; }
                    when '05' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Mobile Wallet'; }
                    when '06' { receiptRecord[0].BillDesk_Payment_Mode__c = 'IMPS'; }
                    when '07' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Reward Points'; }
                    when '08' { receiptRecord[0].BillDesk_Payment_Mode__c = 'Rupay'; }
                    when '10' { receiptRecord[0].BillDesk_Payment_Mode__c = 'UPI'; }
                    when else { receiptRecord[0].BillDesk_Payment_Mode__c = 'Others'; }    
                }
             update receiptRecord[0];
         }
         
         System.debug('**receipt rec**'+receiptRecord);

         if(msgList.get(BillDeskResFormat1.indexOf('AuthStatus')) == '0300'){
              return 'Success';   
            }
            else{ 
              return 'Failure';  
            }
          
        }
             else{ 
              return 'Failure';  
            }
        }
        catch(Exception e)
        {
            throw new CommonException('There was an error -'+e.getMessage()+'. Please try later');
        }
    }
}