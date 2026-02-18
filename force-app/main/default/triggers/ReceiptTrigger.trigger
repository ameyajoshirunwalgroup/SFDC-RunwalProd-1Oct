trigger ReceiptTrigger on Receipt__c (before insert,after insert,after update)
{
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Receipt__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    
    
    if(!byPassTriggerExceution)
    {
        if(Trigger.isAfter && Trigger.isInsert)
        {
            //EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_Customer']; //Commented by Vinay 10-12-2025
            EmailTemplate custtemplate; //Added by Vinay 10-12-2025
            Set<Id> eoiIds = new Set<Id>();
            Map<Id,Receipt__c> receiptMap = new Map<Id,Receipt__c>();
            
            for(Receipt__c receiptRec : Trigger.New)
            {
                if(receiptRec.Payment_Gateway__c != 'BillDesk'){  /* bkk */
                    if( receiptRec.Mode__c == 'Digital' && receiptRec.RW_Payment_Collection_Type__c == 'EOI')
                    {
                        
                        eoiIds.add(receiptRec.EOI__c);
                        receiptMap.put(receiptRec.EOI__c,receiptRec);
                    }
                    
                }
            }
            
            List<RW_EOI__c> updateEOIRecs = new List<RW_EOI__c>();
            Map<Id ,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
            
            
            //Added by Prashant to bulkify code - 3-11-25
            if (!eoiIds.isEmpty()) {
                List<RW_EOI__c> eoiList = [
                    SELECT Id, Name, Total_Amount_Received__c,
                    RW_Primary_First_Name__c, RW_Primary_Last_Name__c, RW_Primary_Email__c,
                    Opportunity__r.RW_Sales_Associate__c,Opportunity__r.Sales_Manager_User__c,Opportunity__r.Sales_Manager_User__r.Name,Opportunity__r.RW_Project__c,
                    Opportunity__r.RW_Project__r.Name, 
                    Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email
                    FROM RW_EOI__c
                    WHERE Id IN :eoiIds
                ];  //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
                
                custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_Customer']; //Added by Vinay 10-12-2025
                
                for(RW_EOI__c eoiRec :eoiList)
                {
                    eoiRecMap.put(eoiRec.Id,eoiRec) ;
                    
                    if( eoiRec.Total_Amount_Received__c != null)
                        eoiRec.Total_Amount_Received__c = eoiRec.Total_Amount_Received__c + receiptMap.get(eoiRec.Id).Total_Amount__c;
                    else
                        eoiRec.Total_Amount_Received__c = receiptMap.get(eoiRec.Id).Total_Amount__c;
                    updateEOIRecs.add(eoiRec);
                }
            }
            
            if(updateEOIRecs.size() >0)
            {
                Update updateEOIRecs;
            }
            
            
            
            //List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> custmessages = new List<Messaging.SingleEmailMessage>();
            for(Id eoiId :  eoiIds)
            {
                
                String custhtmlBody = custtemplate.HtmlValue;
                custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
                custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
                custhtmlBody = custhtmlBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
                map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiId).Opportunity__r.Sales_Manager_User__c)!=null)  	//Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                    custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiId).Opportunity__r.Sales_Manager_User__r.Name).RW_Phone__c)); //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                else
                    custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                
                
                String custplainTextBody = custtemplate.Body;
                custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
                custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
                custplainTextBody = custplainTextBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
                if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiId).Opportunity__r.Sales_Manager_User__c)!=null)  //Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                    custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiId).Opportunity__r.Sales_Manager_User__r.Name).RW_Phone__c));	  //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                else
                    custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
                custmessage.toAddresses = new String[] {eoiRecMap.get(eoiId).RW_Primary_Email__c};
                custmessage.subject = custtemplate.Subject;
                custmessage.setTemplateId(custtemplate.Id);
                custmessage.setHtmlBody(custhtmlBody);
                custmessage.setPlainTextBody(custplainTextBody);
                custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                custmessages.add(custmessage);
                
            }
            
            Messaging.sendEmail(custmessages);
            
        }
        
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            System.debug('inside update');
            Set<Id> eoiIds = new Set<Id>();
            Set<Id> eoiSiteheadIds = new Set<Id>();
            Map<Id,Receipt__c> receiptMap = new Map<Id,Receipt__c>();
            List<RW_EOI__c> EOIRecList = new List<RW_EOI__c>();
            
            for(Receipt__c receiptRec : Trigger.New)
            {
                if((receiptRec.Physically_Cheque_Received__c && receiptRec.Physically_Cheque_Received__c != Trigger.OldMap.get(receiptRec.Id).Physically_Cheque_Received__c) && receiptRec.RW_Payment_Collection_Type__c == 'EOI' && receiptRec.EOI__c != null)
                {
                    System.debug('inside update if');
                    eoiIds.add(receiptRec.EOI__c);
                    receiptMap.put(receiptRec.EOI__c,receiptRec);
                    System.debug('inside update eoiIds'+eoiIds);
                }
                
                
                
                
            }
            List<RW_EOI__c> updateEOIRecs = new List<RW_EOI__c>();
            Map<Id,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
            if(eoiIds.size() > 0){ //Added if condition by Vinay 10-12-2025

            }
            for(RW_EOI__c eoiRec :[Select Id,Name,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.Sales_Manager_User__c,Opportunity__r.Sales_Manager_User__r.Name,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : eoiIds]) 	//Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
            {
                eoiRecMap.put(eoiRec.Id,eoiRec) ;
                if( eoiRec.Total_Amount_Received__c != null)
                    eoiRec.Total_Amount_Received__c = eoiRec.Total_Amount_Received__c + receiptMap.get(eoiRec.Id).Total_Amount__c;
                else
                    eoiRec.Total_Amount_Received__c = receiptMap.get(eoiRec.Id).Total_Amount__c; updateEOIRecs.add(eoiRec);
            }
            
            if(updateEOIRecs.size() >0)
            {
                Update updateEOIRecs;
            }
            
            List<RW_EOI__c> eoiRecordList = [Select Id,Name,RW_Primary_First_Name__c,RW_Primary_Email__c,RW_Primary_Last_Name__c,RW_Status__c,Opportunity__c,Opportunity__r.RW_Project__r.Name from RW_EOI__c where Id IN : eoiIds];
            //EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_ChequeDD_Customer']; //Commented by Vinay 10-12-2025
            List<Messaging.SingleEmailMessage> custmessages = new List<Messaging.SingleEmailMessage>();
            if(eoiRecordList != null && eoiRecordList.size() >0)
            {
                EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_ChequeDD_Customer']; //Added by Vinay 10-12-2025
                System.debug('inside update eoiRecordList'+eoiRecordList);
                for(RW_EOI__c eoiRec : eoiRecordList)
                {
                    If(eoiRec.RW_Status__c != 'EOI Confirmed')
                    {
                        System.debug('inside update status');
                        eoiRec.RW_Status__c = 'EOI Confirmed';
                        EOIRecList.add(eoiRec);
                        
                        
                        String custhtmlBody = custtemplate.HtmlValue;
                        String dateVal = DateTime.newInstance(receiptMap.get(eoiRec.Id).Cheque_DD_Date__c.year(),receiptMap.get(eoiRec.Id).Cheque_DD_Date__c.month(),receiptMap.get(eoiRec.Id).Cheque_DD_Date__c.day()).format('dd-MM-YYYY');
                        custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
                        custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
                        custhtmlBody = custhtmlBody.replace('{!EOINumber}', eoiRec.Name);
                        custhtmlBody = custhtmlBody.replace('{!paymentMode}', String.ValueOf(receiptMap.get(eoiRec.Id).Mode__c));
                        custhtmlBody = custhtmlBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiRec.Id).Total_Amount__c));
                        custhtmlBody = custhtmlBody.replace('{!BankName}', String.ValueOf(receiptMap.get(eoiRec.Id).DraweeBank__c));
                        custhtmlBody = custhtmlBody.replace('{!PaymentReferenceNumber}', String.ValueOf(receiptMap.get(eoiRec.Id).Cheque_DD__c));
                        custhtmlBody = custhtmlBody.replace('{!Date}', dateVal);
                        map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                        if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__c)!=null) 	//Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__r.Name).RW_Phone__c));	 //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                        else
                            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                        String custplainTextBody = custtemplate.Body;
                        custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
                        custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
                        custplainTextBody = custplainTextBody.replace('{!EOINumber}', eoiRec.Name);
                        custplainTextBody = custplainTextBody.replace('{!paymentMode}', String.ValueOf(receiptMap.get(eoiRec.Id).Mode__c));
                        custplainTextBody = custplainTextBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiRec.Id).Total_Amount__c));
                        custplainTextBody = custplainTextBody.replace('{!BankName}', String.ValueOf(receiptMap.get(eoiRec.Id).DraweeBank__c));
                        custplainTextBody = custplainTextBody.replace('{!PaymentReferenceNumber}', String.ValueOf(receiptMap.get(eoiRec.Id).Cheque_DD__c));
                        custplainTextBody = custplainTextBody.replace('{!Date}', dateVal);
                        if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__c)!=null) //Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                            custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__r.Name).RW_Phone__c));	 //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                        else
                            custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');
                        Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
                        custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
                        custmessage.subject = custtemplate.Subject;
                        custmessage.setTemplateId(custtemplate.Id);
                        custmessage.setHtmlBody(custhtmlBody);
                        custmessage.setPlainTextBody(custplainTextBody);
                        custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        custmessages.add(custmessage);
                        
                    }
                }
            }
            
            if(EOIRecList.size() >0)
            {
                System.debug('inside update ');
                update EOIRecList;
            }
            
            if(custmessages.size() > 0)
                Messaging.sendEmail(custmessages);
        }
        
        if(Trigger.isAfter && Trigger.isInsert)
        {
            Set<String> eoiSalesManagerSet = new Set<String>();
            Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
            Map<Id,List<String>> projectTeamEmailIds = new Map<Id,List<String>>();
            Set<Id> ProjectIds = new Set<Id>();
            Set<Id> refundEoiIds = new Set<Id>();
            Map<Id,Receipt__c> eoiReceiptMap= new Map<Id,Receipt__c>();
            List<RW_EOI__c> EOIRefundRecList = new List<RW_EOI__c>();
            for(Receipt__c receiptRec : Trigger.New)
            {
                
                if(receiptRec.RW_Payment_Refunded__c && receiptRec.RW_Payment_Collection_Type__c == 'EOI' && receiptRec.EOI__c != null)
                {
                    System.debug('inside update if');
                    refundEoiIds.add(receiptRec.EOI__c);
                    eoiReceiptMap.put(receiptRec.EOI__c, receiptRec);
                    
                }
            }
            Map<Id ,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
            if (!refundEoiIds.isEmpty()) {
                List<RW_EOI__c> eoiList1 = [
                    Select Id,Name,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.Sales_Manager_User__c,Opportunity__r.Sales_Manager_User__r.Name,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,
                    Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : refundEoiIds
                ]; 	//Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
                
                for(RW_EOI__c eoiRec : eoilist1)
                {
                    eoiRecMap.put(eoiRec.Id,eoiRec) ;
                    eoiSalesManagerSet.add(eoiRec.Opportunity__r.Sales_Manager_User__r.Name); //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                    ProjectIds.add(eoiRec.Opportunity__r.RW_Project__c);
                }
            }
            
            Set<Id> teamIds = new Set<Id>();
            if (!ProjectIds.isEmpty()) {
                List<Team__c> teamRecord =
                    [Select id from Team__c where Team_Type__c ='MIS' and Project__c IN:ProjectIds];
                
                if(teamRecord != null && teamRecord.size() >0)
                {
                    for(Team__c teamRec : teamRecord)
                    {
                        teamIds.add(teamRec.Id);
                    }
                }
            }
            
            if(!teamIds.isEmpty()){
                List<Team_Members__c> teamMembers = [Select Id,Email_Id__c,Team__r.Project__c from Team_Members__c where Team__c IN :teamIds];
                if(teamMembers != null && teamMembers.size() >0)
                {
                    for(Team_Members__c teammem : teamMembers)
                    {
                        
                        if(projectTeamEmailIds.containsKey(teammem.Team__r.Project__c))
                        {
                            List<String> emailIdValues =  projectTeamEmailIds.get(teammem.Team__r.Project__c);
                            emailIdValues.add(teammem.Email_Id__c);
                            projectTeamEmailIds.put(teammem.Team__r.Project__c,emailIdValues);
                        }
                        else
                        {
                            projectTeamEmailIds.put(teammem.Team__r.Project__c,new List<String>{teammem.Email_Id__c});
                        }
                    }
                }
                
            }
            
            //List<User> userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet]; //Commented by Vinay 10-12-2025
            List<User> userRec = new List<User>(); //Added by Vinay 10-12-2025
            if(eoiSalesManagerSet.size() > 0){ //Added by Vinay 10-12-2025
                userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet];
            }
            if(userRec != null && userRec.size() >0)
            {
                for(User u : userRec)
                    eoiSalesManagerEmailIds.put(u.Name,u.Email);
            }
            
            
            //EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund_Customer']; //Commented by Vinay 10-12-2025
            //EmailTemplate internaltemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund']; //Commented by Vinay 10-12-2025
            List<String> toAddress = new List<String>();
            
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> internalmessages = new List<Messaging.SingleEmailMessage>();
            //List<RW_EOI__c> eoiRefundRecordList = [Select Id,Name,Tower__r.Name,RW_Project_Name__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Status__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : refundEoiIds]; //Commented by Vinay 10-12-2025
            List<RW_EOI__c> eoiRefundRecordList = new List<RW_EOI__c>(); //Added by Vinay 10-12-2025
            if(refundEoiIds.size() > 0){ //Added by Vinay 10-12-2025
                 eoiRefundRecordList = [Select Id,Name,Tower__r.Name,RW_Project_Name__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Status__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : refundEoiIds];
            }
            
            if(eoiRefundRecordList != null && eoiRefundRecordList.size() >0)
            {
                EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund_Customer']; //Added by Vinay 10-12-2025
                EmailTemplate internaltemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund']; //Added by Vinay 10-12-2025
                System.debug('inside update eoiRecordList'+eoiRefundRecordList);
                for(RW_EOI__c eoiRec : eoiRefundRecordList)
                {
                    If(eoiRec.RW_Status__c != 'EOI Cancelled -Refunded')
                    {
                        System.debug('inside update status');
                        eoiRec.RW_Status__c = 'EOI Cancelled -Refunded';
                        EOIRefundRecList.add(eoiRec);
                        
                        
                        
                        String customerhtmlBody = customertemplate.HtmlValue;
                        customerhtmlBody = customerhtmlBody.replace('{!Customer}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
                        customerhtmlBody = customerhtmlBody.replace('{!Amount}', String.valueOf(eoiReceiptMap.get(eoiRec.Id).Total_Amount__c));
                        customerhtmlBody = customerhtmlBody.replace('{!EOIName}',eoiRec.Name);
                        //customerhtmlBody = customerhtmlBody.replace('{!TowerName}',eoiRec.Tower__r.Name);
                        customerhtmlBody = customerhtmlBody.replace('{!ProjectName}',eoiRec.RW_Project_Name__c);
                        
                        String customerTextBody = customertemplate.Body;
                        customerTextBody = customerTextBody.replace('{!Customer}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
                        customerTextBody = customerTextBody.replace('{!Amount}', String.valueOf(eoiReceiptMap.get(eoiRec.Id).Total_Amount__c));
                        customerTextBody = customerTextBody.replace('{!EOIName}',eoiRec.Name);
                        //customerTextBody = customerTextBody.replace('{!TowerName}',eoiRec.Tower__r.Name);
                        customerTextBody = customerTextBody.replace('{!ProjectName}',eoiRec.RW_Project_Name__c);
                        
                        Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
                        
                        custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
                        custmessage.subject = customertemplate.Subject;
                        custmessage.setTemplateId(customertemplate.Id);
                        //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
                        custmessage.setHtmlBody(customerhtmlBody);
                        custmessage.setPlainTextBody(customerTextBody);
                        custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        customermessages.add(custmessage);
                        
                        
                        String internalhtmlBody = internaltemplate.HtmlValue;
                        internalhtmlBody = internalhtmlBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
                        internalhtmlBody = internalhtmlBody.replace('{!Amount}', String.valueOf(eoiReceiptMap.get(eoiRec.Id).Total_Amount__c));
                        String internalTextBody = internaltemplate.Body;
                        internalTextBody = internalTextBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
                        internalTextBody = internalTextBody.replace('{!Amount}', String.valueOf(eoiReceiptMap.get(eoiRec.Id).Total_Amount__c));
                        
                        Messaging.SingleEmailMessage intermessage = new Messaging.SingleEmailMessage();
                        System.debug('toAddress***'+toAddress);
                        toAddress.add(eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
                        System.debug('toAddress****'+toAddress);
                        
                        
                        if(projectTeamEmailIds.containsKey(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__c))
                        {
                            if(projectTeamEmailIds.get(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__c) != null && projectTeamEmailIds.get(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__c).size() >0)
                                toAddress.addAll(projectTeamEmailIds.get(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__c));
                        }
                        
                        if(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__r.Sales_Site_Head__c != null && eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null )
                            toAddress.add(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
                        
                        if(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__c != null && eoiSalesManagerEmailIds.containsKey(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__r.Name))  	//Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 05-12-2025
                        {
                            toAddress.add(eoiSalesManagerEmailIds.get(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.Sales_Manager_User__r.Name));  //Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 05-12-2025
                        }
                        
                        
                        intermessage.toAddresses = toAddress;
                        intermessage.subject = internaltemplate.Subject;
                        intermessage.setTemplateId(internaltemplate.Id);
                        //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
                        intermessage.setHtmlBody(internalhtmlBody);
                        intermessage.setPlainTextBody(internalTextBody);
                        intermessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        internalmessages.add(intermessage);
                        
                        
                        
                    }
                    
                    
                    
                }
                
            }
            
            if(EOIRefundRecList.size() >0)
            {
                System.debug('inside update ');
                update EOIRefundRecList;
            }
            
            if(customermessages.size() >0)
                Messaging.sendEmail(customermessages);
            
        }
        
        /* bkk */
        if((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)){
            //Send emails to MIS Team
            Map<String,List<String>> projectMISteam = new Map<String,List<String>>(); /* for 'Customer Portal' & 'SAP Demands Receipts' */
                Map<String,List<String>> booking_EOI_mailId = new Map<String,List<String>>(); /* for 'Booking' & 'EOI' Receipts */
                List<Messaging.SingleEmailMessage> custmessages = new List<Messaging.SingleEmailMessage>();
            set<string> bookinIdBD = new set<String>();
            Map<string,Booking__c> bkmapBD = new Map<string,Booking__c>();
            set<string> eoiIdBD = new set<String>();
            Map<string,RW_EOI__c> eoimapBD = new Map<string,RW_EOI__c>();
            set<string> custPotralId = new set<String>();
            Map<string,Booking__c> custPotralmapBD = new Map<string,Booking__c>();
            
            for(Receipt__c receiptRec : Trigger.New)
            {
                if (receiptRec.Payment_Gateway__c == 'BillDesk' && receiptRec.Receipt_Status__c == 'Success'){
                    System.debug('in trigger.new Receipt BillDesk 1'+receiptRec.EOI__c);
                    if(receiptRec.RW_Payment_Collection_Type__c == 'EOI' && receiptRec.EOI__c != null){
                        eoiIdBD.add(receiptRec.EOI__c);
                    }
                    else if(receiptRec.RW_Payment_Collection_Type__c == 'Booking' && receiptRec.Booking__c != null){
                        bookinIdBD.add(receiptRec.Booking__c);
                    }
                    else if ((receiptRec.RW_Payment_Collection_Type__c == 'Customer Portal'|| receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands' || receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands - Flat Cost' || receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands - GST') && receiptRec.Booking__c != null){
                        custPotralId.add(receiptRec.Booking__c);
                    }
                }
            }
            
            if(eoiIdBD.size()>0){
                for(RW_EOI__c eoi :[select Id,Name,Owner.Email,RW_Project_Name__c,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.Sales_Manager_User__c,Opportunity__r.Sales_Manager_User__r.Name,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where id IN :eoiIdBD]){  //Added Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 05-12-2025
                    eoimapBD.put(eoi.Id,eoi);
                    booking_EOI_mailId.put(eoi.Id, new String[] {eoi.Owner.Email});
                    //booking_EOI_mailId.put(eoi.Id, new String[] {'bharti.khokhar@in.ey.com'});
                    system.debug('***Trigger3 booking_EOI_mailId:'+booking_EOI_mailId);
                }
            }
            
            if(bookinIdBD.size()>0){
                for(Booking__c bk :[select id, Name,Owner.Email,RW_Project_Name__c,Primary_Applicant_Name__c,Project__c,Unit_No__r.Name from Booking__c where id IN :bookinIdBD]){
                    bkmapBD.put(bk.Id,bk);
                    system.debug('***Trigger4 bkmap:'+bkmapBD);
                    booking_EOI_mailId.put(bk.Id, new String[] {bk.Owner.Email});
                    //booking_EOI_mailId.put(bk.Id, new String[] {'priya.pangotra@in.ey.com'});
                }
            }
            if(custPotralId.size()>0){
                for(Booking__c bk :[select id,Name,Owner.Email,RW_Project_Name__c,Primary_Applicant_Name__c,Project__c,Unit_No__r.Name,Unit_No__r.Relationship_Manager__r.RM_Email__c,Opportunity__r.SAP_Customer_Number__c,Opportunity__r.SalesOrder_Number__c from Booking__c where id IN :custPotralId]){
                    custPotralmapBD.put(bk.Id,bk);
                    system.debug('***Trigger4 bkmap:'+custPotralmapBD);
                    List<String> emailIDs = Utility.getExternalTeamEmailIds(new List<String>{'MIS'},bk.Project__c);
                    
                    if(bk.Unit_No__r.Relationship_Manager__r.RM_Email__c != null)
                        emailIDs.add(bk.Unit_No__r.Relationship_Manager__r.RM_Email__c);
                    if(emailIDs.size() > 0)
                        projectMISteam.put(bk.id, emailIDs);
                    System.debug('projectMISteam2'+emailIDs);
                    /* projectMISteam.put(bk.Id, new String[] {'bharti.khokhar@in.ey.com','ishu.mittal@in.ey.com'}); */
                }
            }
            
            /*EmailTemplate misTeamEOIBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_EOI_MIS_Payment'];
            EmailTemplate misTeamBookingBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_Booking_MIS_Payment'];
            EmailTemplate misTeamCustPortalBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_CustomerPortal_MIS_Payment'];
            EmailTemplate misTeamSAPDemBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_SAPDemands_MIS_Payment'];
             *///Commented by Prashant to bulkify the soql // 02-11-25
            
            Map<String, EmailTemplate> emailTemplates = new Map<String, EmailTemplate>();
            for (EmailTemplate et : [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate WHERE DeveloperName IN (
                'BillDesk_EOI_MIS_Payment',
                'BillDesk_Booking_MIS_Payment',
                'BillDesk_CustomerPortal_MIS_Payment',
                'BillDesk_SAPDemands_MIS_Payment')])
            {
                emailTemplates.put(et.DeveloperName, et);
            }
            
            EmailTemplate misTeamEOIBD = emailTemplates.get('BillDesk_EOI_MIS_Payment');
            EmailTemplate misTeamBookingBD = emailTemplates.get('BillDesk_Booking_MIS_Payment');
            EmailTemplate misTeamCustPortalBD = emailTemplates.get('BillDesk_CustomerPortal_MIS_Payment');
            EmailTemplate misTeamSAPDemBD = emailTemplates.get('BillDesk_SAPDemands_MIS_Payment');
            
            for(Receipt__c receiptRec : Trigger.New)
            {
                if (receiptRec.Payment_Gateway__c == 'BillDesk' && (receiptRec.Receipt_Status__c == 'Success')){
                    if (receiptRec.RW_Payment_Collection_Type__c == 'EOI' && receiptRec.EOI__c != null){
                        system.debug('***Trigger.New BillDesk7:'+booking_EOI_mailId.get(receiptrec.EOI__c));
                        String misTeamHtmlMsg = misTeamEOIBD.HtmlValue;
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!RW_EOI__c.Name}', eoimapBD.get(receiptrec.EOI__c).Name);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!RW_EOI__c.RW_Primary_Applicant_Name__c}', eoimapBD.get(receiptrec.EOI__c).RW_Primary_First_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoimapBD.get(receiptrec.EOI__c).RW_Primary_Last_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!ProjectName}', eoimapBD.get(receiptrec.EOI__c).RW_Project_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        
                        String misPlainTextBody = misTeamEOIBD.Body;
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misPlainTextBody = misPlainTextBody.replace('{!RW_EOI__c.Name}', eoimapBD.get(receiptrec.EOI__c).Name);
                        misPlainTextBody = misPlainTextBody.replace('{!RW_EOI__c.RW_Primary_Applicant_Name__c}', eoimapBD.get(receiptrec.EOI__c).RW_Primary_First_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoimapBD.get(receiptrec.EOI__c).RW_Primary_Last_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misPlainTextBody = misPlainTextBody.replace('{!ProjectName}', eoimapBD.get(receiptrec.EOI__c).RW_Project_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        
                        Messaging.SingleEmailMessage misMessage = new Messaging.SingleEmailMessage();
                        misMessage.toAddresses = booking_EOI_mailId.get(receiptrec.EOI__c);
                        misMessage.subject = misTeamEOIBD.Subject;
                        misMessage.setTemplateId(misTeamEOIBD.Id);
                        misMessage.setHtmlBody(misTeamHtmlMsg);
                        misMessage.setPlainTextBody(misPlainTextBody);
                        misMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        custmessages.add(misMessage);
                    }
                    
                    if (receiptRec.RW_Payment_Collection_Type__c == 'Booking' && receiptRec.Booking__c != null){
                        system.debug('***Trigger.New BillDesk7:'+booking_EOI_mailId.get(receiptrec.Booking__c));
                        String misTeamHtmlMsg = misTeamBookingBD.HtmlValue;
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!ProjectUnit}', bkmapBD.get(receiptrec.Booking__c).Unit_No__r.Name);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Name}', bkmapBD.get(receiptrec.Booking__c).Name);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Primary_Applicant_Name__c}', bkmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!ProjectName}', bkmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        
                        
                        String misPlainTextBody = misTeamBookingBD.Body;
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misPlainTextBody = misPlainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misPlainTextBody = misPlainTextBody.replace('{!ProjectUnit}', bkmapBD.get(receiptrec.Booking__c).Unit_No__r.Name);
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Name}', bkmapBD.get(receiptrec.Booking__c).Name);
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misPlainTextBody = misPlainTextBody.replace('{!ProjectName}', bkmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        
                        Messaging.SingleEmailMessage misMessage = new Messaging.SingleEmailMessage();
                        misMessage.toAddresses = booking_EOI_mailId.get(receiptrec.Booking__c);
                        misMessage.subject = misTeamBookingBD.Subject;
                        misMessage.setTemplateId(misTeamBookingBD.Id);
                        misMessage.setHtmlBody(misTeamHtmlMsg);
                        misMessage.setPlainTextBody(misPlainTextBody);
                        misMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        custmessages.add(misMessage);
                    }
                    if (receiptRec.RW_Payment_Collection_Type__c == 'Customer Portal' && receiptRec.Booking__c != null){
                        system.debug('***Trigger.New BillDesk7:'+projectMISteam.get(receiptrec.Booking__c));
                        String misTeamHtmlMsg = misTeamCustPortalBD.HtmlValue;
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Name}', custPotralmapBD.get(receiptrec.Booking__c).Name);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Primary_Applicant_Name__c}', custPotralmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!ProjectName}', custPotralmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c != null )
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SAPCustomerNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c);
                        else
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SAPCustomerNumber}', '');
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c != null )
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SalesOrderNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SalesOrderNumber}', '');
                        
                        String misPlainTextBody = misTeamCustPortalBD.Body;
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misPlainTextBody = misPlainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Name}', custPotralmapBD.get(receiptrec.Booking__c).Name);
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', custPotralmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misPlainTextBody = misPlainTextBody.replace('{!ProjectName}', custPotralmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c != null)
                            misPlainTextBody = misPlainTextBody.replace('{!SAPCustomerNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misPlainTextBody = misPlainTextBody.replace('{!SAPCustomerNumber}', '');
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c != null)
                            misPlainTextBody = misPlainTextBody.replace('{!SalesOrderNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misPlainTextBody = misPlainTextBody.replace('{!SalesOrderNumber}', '');
                        
                        Messaging.SingleEmailMessage misMessage = new Messaging.SingleEmailMessage();
                        misMessage.toAddresses = projectMISteam.get(receiptrec.Booking__c);
                        misMessage.subject = misTeamCustPortalBD.Subject;
                        misMessage.setTemplateId(misTeamCustPortalBD.Id);
                        misMessage.setHtmlBody(misTeamHtmlMsg);
                        misMessage.setPlainTextBody(misPlainTextBody);
                        misMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        custmessages.add(misMessage);
                    }
                    if ((receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands' || receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands - Flat Cost' || receiptRec.RW_Payment_Collection_Type__c == 'SAP Demands - GST') && receiptRec.Booking__c != null){
                        system.debug('***Trigger.New BillDesk7:'+projectMISteam.get(receiptrec.Booking__c));
                        String misTeamHtmlMsg = misTeamSAPDemBD.HtmlValue;
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Name}', custPotralmapBD.get(receiptrec.Booking__c).Name);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Primary_Applicant_Name__c}', custPotralmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misTeamHtmlMsg = misTeamHtmlMsg.replace('{!ProjectName}', custPotralmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c != null)
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SAPCustomerNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c);
                        else
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SAPCustomerNumber}', '');
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c != null)
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SalesOrderNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misTeamHtmlMsg = misTeamHtmlMsg.replace('{!SalesOrderNumber}', '');
                        
                        String misPlainTextBody = misTeamSAPDemBD.Body;
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                        misPlainTextBody = misPlainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptrec.Cheque_DD_Date__c));
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Name}', custPotralmapBD.get(receiptrec.Booking__c).Name);
                        misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', custPotralmapBD.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Payment_Gateway__c}', receiptRec.Payment_Gateway__c);
                        misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                        misPlainTextBody = misPlainTextBody.replace('{!ProjectName}', custPotralmapBD.get(receiptrec.Booking__c).RW_Project_Name__c);
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SAP_Customer_Number__c != null)
                            misPlainTextBody = misPlainTextBody.replace('{!SAPCustomerNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misPlainTextBody = misPlainTextBody.replace('{!SAPCustomerNumber}', '');
                        if(custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c != null)
                            misPlainTextBody = misPlainTextBody.replace('{!SalesOrderNumber}', custPotralmapBD.get(receiptrec.Booking__c).Opportunity__r.SalesOrder_Number__c);
                        else
                            misPlainTextBody = misPlainTextBody.replace('{!SalesOrderNumber}', '');
                        
                        Messaging.SingleEmailMessage misMessage = new Messaging.SingleEmailMessage();
                        misMessage.toAddresses = projectMISteam.get(receiptrec.Booking__c);
                        misMessage.subject = misTeamSAPDemBD.Subject;
                        misMessage.setTemplateId(misTeamSAPDemBD.Id);
                        misMessage.setHtmlBody(misTeamHtmlMsg);
                        misMessage.setPlainTextBody(misPlainTextBody);
                        misMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                        custmessages.add(misMessage);
                        
                    }
                }
            }
            if(custmessages.size() >0){
                System.debug('custmessages****'+custmessages);
                Messaging.sendEmail(custmessages);
            }
        }
        
        if(Trigger.isBefore && Trigger.isInsert){ //Added by Vinay 20-08-2025
            Set<Id> oppIds = new Set<Id>();
            Map<String, Receipt__c> utrVsReceipt = new Map<String, Receipt__c>();
            for(Receipt__c rec : Trigger.New){
                if(!String.isBlank(rec.Cheque_DD__c) && !String.isBlank(rec.Opportunity__c) && !String.isBlank(rec.DraweeBank__c)){
                    oppIds.add(rec.Opportunity__c);
                    if(utrVsReceipt.get(rec.Opportunity__c + '_' + rec.Cheque_DD__c + '_' + rec.DraweeBank__c) == null){
                        utrVsReceipt.put(rec.Opportunity__c + '_' + rec.Cheque_DD__c + '_' + rec.DraweeBank__c, rec);
                    }else{
                        rec.addError('Duplicate UTR details found');
                    }
                }
                
            }
            
            if(oppIds.size() > 0){
                List<Receipt__c> recList = [SELECT Id, Opportunity__c, Cheque_DD__c, DraweeBank__c FROM Receipt__c WHERE Opportunity__c =: oppIds];
                Map<Id, List<Receipt__c>> oppVsReceipts = new Map<Id, List<Receipt__c>>();
                for(Receipt__c rec : recList){
                    if(oppVsReceipts.get(rec.Opportunity__c) != null){
                        oppVsReceipts.get(rec.Opportunity__c).add(rec);
                    }else{
                        oppVsReceipts.put(rec.Opportunity__c, new List<Receipt__c>{rec});
                    }
                }
                for(Receipt__c rec : Trigger.New){
                    if(oppVsReceipts.get(rec.Opportunity__c) != null){
                        for(Receipt__c recp : oppVsReceipts.get(rec.Opportunity__c)){
                            if(rec.Cheque_DD__c + '_' + rec.DraweeBank__c == recp.Cheque_DD__c + '_' + recp.DraweeBank__c){
                                rec.addError('Duplicate UTR details found');
                            }
                        }
                    }
                }
            }
        }
    }
    
}