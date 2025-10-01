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
         //EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_EOI_Payment'];
         EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_Customer'];
         Set<Id> eoiIds = new Set<Id>();
         Map<Id,Receipt__c> receiptMap = new Map<Id,Receipt__c>();
         
         /* Set<Id> bkIds = new Set<Id>();
         Map<Id,Receipt__c> receiptbkMap = new Map<Id,Receipt__c>(); */
         
         for(Receipt__c receiptRec : Trigger.New)
         {	 
             if(receiptRec.Payment_Gateway__c != 'BillDesk'){  /* bkk */
                 if( receiptRec.Mode__c == 'Digital' && receiptRec.RW_Payment_Collection_Type__c == 'EOI')
                 {
                     
                     eoiIds.add(receiptRec.EOI__c);
                     receiptMap.put(receiptRec.EOI__c,receiptRec);
                 }
		 		 /*
                 if (receiptRec.Mode__c == 'Digital' && receiptRec.RW_Payment_Collection_Type__c == 'Booking'){
                     
                     bkIds.add(receiptRec.Booking__c);
                     receiptbkMap.put(receiptRec.Booking__c,receiptRec);
                     
                 } */
             }
         }
         
         List<RW_EOI__c> updateEOIRecs = new List<RW_EOI__c>();
         Map<Id ,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
         /* Map<Id ,Booking__c> bkRecMap = new Map<Id,Booking__c>([select id,Customer__r.RW_Sales_Associate__c, Primary_Applicant_Email__c,Primary_Applicant_Name__c from Booking__c where id in:bkIds]); */
         
         //Set<String> eoiSalesManagerSet = new Set<String>();
         //Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
         // Map<Id,List<String>> projectTeamEmailIds = new Map<Id,List<String>>();
         //Set<Id> ProjectIds = new Set<Id>();
         for(RW_EOI__c eoiRec :[Select Id,Name,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : eoiIds])
         {
             eoiRecMap.put(eoiRec.Id,eoiRec) ;
             //eoiSalesManagerSet.add(eoiRec.Opportunity__r.RW_Sales_Associate__c);
             //ProjectIds.add(eoiRec.Opportunity__r.RW_Project__c);
             if( eoiRec.Total_Amount_Received__c != null)
                 eoiRec.Total_Amount_Received__c = eoiRec.Total_Amount_Received__c + receiptMap.get(eoiRec.Id).Total_Amount__c;
             else
                 eoiRec.Total_Amount_Received__c = receiptMap.get(eoiRec.Id).Total_Amount__c; 
             updateEOIRecs.add(eoiRec);
         }
         
         if(updateEOIRecs.size() >0)
         {
             Update updateEOIRecs; 
         }
         
         //List<String> toAddress = new List<String>();
         /*Team_Email_IDs__mdt[] teamEmails = [SELECT Id,Email_IDs__c FROM Team_Email_IDs__mdt Where DeveloperName ='MIS' ];
if(teamEmails != null && teamEmails.size() >0)
{
for(Team_Email_IDs__mdt emailData : teamEmails)
{
toAddress.add(emailData.Email_IDs__c);
}
}*/
         
         /* Set<Id> teamIds = new Set<Id>();
List<Team__c> teamRecord = [Select id from Team__c where Team_Type__c ='MIS' and Project__c IN:ProjectIds] ;
if(teamRecord != null && teamRecord.size() >0)
{
for(Team__c teamRec : teamRecord)
{
teamIds.add(teamRec.Id);
}
}

List<Team_Members__c> teamMembers = [Select Id,Email_Id__c,Team__r.Project__c from Team_Members__c where Team__c IN :teamIds];
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


List<User> userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet];
if(userRec != null && userRec.size() >0)
{
for(User u : userRec)
eoiSalesManagerEmailIds.put(u.Name,u.Email);
}

*/
         
         //List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
         List<Messaging.SingleEmailMessage> custmessages = new List<Messaging.SingleEmailMessage>();
         for(Id eoiId :  eoiIds)
         {
             /* String htmlBody = template.HtmlValue; 
htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRecMap.get(eoiId).Name);
htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiId);
htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
htmlBody = htmlBody.replace('{!ProjectName}', eoiRecMap.get(eoiId).Opportunity__r.RW_Project__r.Name);
htmlBody = htmlBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
htmlBody = htmlBody.replace('{!DateOfPayment}', String.ValueOf(receiptMap.get(eoiId).Cheque_DD_Date__c));

String plainTextBody = template.Body; 
plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRecMap.get(eoiId).Name);
plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiId);
plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
plainTextBody = plainTextBody.replace('{!ProjectName}', eoiRecMap.get(eoiId).Opportunity__r.RW_Project__r.Name);
plainTextBody = plainTextBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
plainTextBody = plainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptMap.get(eoiId).Cheque_DD_Date__c));

Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
if(projectTeamEmailIds.containsKey(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__c))
{
if(projectTeamEmailIds.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__c) != null && projectTeamEmailIds.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__c).size() >0)
toAddress.addAll(projectTeamEmailIds.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__c));
}

if(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__r.Sales_Site_Head__c != null && eoiRecMap.get(eoiId).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null )
toAddress.add(eoiRecMap.get(eoiId).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);

if(eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c != null && eoiSalesManagerEmailIds.containsKey(eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c))
{
toAddress.add(eoiSalesManagerEmailIds.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c));
}
message.toAddresses = toAddress;
message.subject = template.Subject;
message.setTemplateId(template.Id);
message.setHtmlBody(htmlBody);   
message.setPlainTextBody(plainTextBody);
messages.add(message);
//Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
//Messaging.SendEmailResult[] results = 
*/
             String custhtmlBody = custtemplate.HtmlValue; 
             custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
             custhtmlBody = custhtmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
             custhtmlBody = custhtmlBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
             map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
             if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c)!=null)
                 custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
             else
                 custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
             
             
             String custplainTextBody = custtemplate.Body; 
             custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(eoiId).RW_Primary_First_Name__c);
             custplainTextBody = custplainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(eoiId).RW_Primary_Last_Name__c);
             custplainTextBody = custplainTextBody.replace('{!Amount}', String.ValueOf(receiptMap.get(eoiId).Total_Amount__c));
             if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c)!=null)
                 custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiId).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
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
	 	 /*
         EmailTemplate custBookingtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_Booking_Online_Customer'];
         
         for(id bkid : bkIds){           system.debug(bkRecMap+'MK');
                              system.debug(bkRecMap.get(bkId)+'MK');
                              String bkcusthtmlBody = custBookingtemplate.HtmlValue; 
                              bkcusthtmlBody = bkcusthtmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkRecMap.get(bkId).Primary_Applicant_Name__c);
                              bkcusthtmlBody = bkcusthtmlBody.replace('{!Amount}', String.ValueOf(receiptbkMap.get(bkId).Total_Amount__c));
                              map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                              if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c)!=null)
                                  bkcusthtmlBody = bkcusthtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c).RW_Phone__c));	
                              else
                                  bkcusthtmlBody = bkcusthtmlBody.replace('{!SMPhoneNumber}', System.label.RW_BookingSalesContact); 
                              
                              
                              String bkcustplainTextBody = custBookingtemplate.Body; 
                              
                              bkcustplainTextBody = bkcustplainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkRecMap.get(bkId).Primary_Applicant_Name__c);
                              bkcustplainTextBody = bkcustplainTextBody.replace('{!Amount}', String.ValueOf(receiptbkMap.get(bkId).Total_Amount__c));
                              if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(  bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c)!=null)
                                  bkcustplainTextBody = bkcustplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get( bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c).RW_Phone__c));	
                              else
                                  bkcustplainTextBody = bkcustplainTextBody.replace('{!SMPhoneNumber}', System.label.RW_BookingSalesContact); 
                              Messaging.SingleEmailMessage bkcustmessage = new Messaging.SingleEmailMessage();
                              bkcustmessage.toAddresses = new String[] {bkRecMap.get(bkId).Primary_Applicant_Email__c};
                                  bkcustmessage.subject = custBookingtemplate.Subject;
                              bkcustmessage.setTemplateId(custBookingtemplate.Id);
                              bkcustmessage.setHtmlBody(bkcusthtmlBody);   
                              bkcustmessage.setPlainTextBody(bkcustplainTextBody);
                              bkcustmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                              custmessages.add(bkcustmessage);
                             }
         */
         
         //Send emails to MIS Team
         /* 
         Map<String,List<String>> projectMISteam = new Map<String,List<String>>();
         set<string>bookinId = new set<String>();
         Map<string,Booking__c> bkmap = new Map<string,Booking__c>();
         
         for(Receipt__c receiptRec : Trigger.New)
         {
             if (receiptRec.Payment_Gateway__c != 'BillDesk' && receiptRec.RW_Payment_Collection_Type__c == 'Booking' && receiptRec.Booking__c!= null && receiptRec.Opportunity__c!=null){
                 bookinId.add(receiptRec.Booking__c);
             }
         }
         system.debug(bookinId);
         if(bookinId.size()>0){
             for(Booking__c bk :[select id, Name,Primary_Applicant_Name__c,Project__c from Booking__c where id in :bookinId]){
                 bkmap.put(bk.Id,bk);
                 system.debug(bkmap);
                 projectMISteam.put(bk.id, Utility.getExternalTeamEmailIds(new List<String>{'MIS'},bk.Project__c));
                 system.debug('projectMISteam1'+projectMISteam);
             }
         }
         EmailTemplate misEmailTeam = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Booking_MIS_Payment'];
         for(Receipt__c receiptRec : Trigger.New)
         {
             if (receiptRec.Payment_Gateway__c != 'BillDesk' && receiptRec.RW_Payment_Collection_Type__c == 'Booking' && receiptRec.Booking__c!= null && receiptRec.Opportunity__c!=null){
                 String misTeamHtmlMsg = misEmailTeam.HtmlValue; 
                 misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                 misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                 misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Name}', bkmap.get(receiptrec.Booking__c).Name);
                 misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Booking__c.Primary_Applicant_Name__c}', bkmap.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                 misTeamHtmlMsg = misTeamHtmlMsg.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                 
                 String misPlainTextBody = misEmailTeam.Body; 
                 misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Mode__c}', receiptRec.Mode__c);
                 misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Total_Amount__c}', String.ValueOf(receiptrec.Total_Amount__c));
                 misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Name}', bkmap.get(receiptrec.Booking__c).Name);
                 misPlainTextBody = misPlainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkmap.get(receiptrec.Booking__c).Primary_Applicant_Name__c);
                 misPlainTextBody = misPlainTextBody.replace('{!Receipt__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptrec.id);
                System.debug('misPlainTextBody'+misPlainTextBody);
                 Messaging.SingleEmailMessage misMessage = new Messaging.SingleEmailMessage();
                 System.debug('Project******'+projectMISteam.get(receiptrec.Booking__c));
                 misMessage.toAddresses = projectMISteam.get(receiptrec.Booking__c);
                
                 System.debug('receiptrec.Booking__c'+receiptrec.Booking__c);
                 system.debug('toAddress1 for projectMISteam'+misMessage.toAddresses);
                 misMessage.subject = misEmailTeam.Subject;
                 misMessage.setTemplateId(misEmailTeam.Id);
                 misMessage.setHtmlBody(misTeamHtmlMsg);   
                 misMessage.setPlainTextBody(misPlainTextBody);
                 misMessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                 System.debug('misMessage'+misMessage);
                 custmessages.add(misMessage);
                 system.debug('custmessages'+custmessages);
             }
         }    
		 */       
         Messaging.sendEmail(custmessages);
         
        }
        
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            System.debug('inside update');
            Set<Id> eoiIds = new Set<Id>();
            Set<Id> eoiSiteheadIds = new Set<Id>();
            Map<Id,Receipt__c> receiptMap = new Map<Id,Receipt__c>();
            List<RW_EOI__c> EOIRecList = new List<RW_EOI__c>();
            /*
            Set<id> bkIdSet = new Set<id>();
            List<Booking__c> booklist = new List<Booking__c>();
            Map<Id,Receipt__c> receiptBKMap = new Map<Id,Receipt__c>();
            */
            for(Receipt__c receiptRec : Trigger.New)
            {
                if((receiptRec.Physically_Cheque_Received__c && receiptRec.Physically_Cheque_Received__c != Trigger.OldMap.get(receiptRec.Id).Physically_Cheque_Received__c) && receiptRec.RW_Payment_Collection_Type__c == 'EOI' && receiptRec.EOI__c != null)
                {
                    System.debug('inside update if');
                    eoiIds.add(receiptRec.EOI__c);
                    receiptMap.put(receiptRec.EOI__c,receiptRec);
                    System.debug('inside update eoiIds'+eoiIds);
                }
                /*
                if((receiptRec.Physically_Cheque_Received__c && receiptRec.Physically_Cheque_Received__c != Trigger.OldMap.get(receiptRec.Id).Physically_Cheque_Received__c) && receiptRec.RW_Payment_Collection_Type__c == 'Booking' && receiptRec.Booking__c != null)
                {
                    System.debug('inside update if');
                    bkIdSet.add(receiptRec.Booking__c);
                    receiptBKMap.put(receiptRec.Booking__c,receiptRec);
                    System.debug('inside update booking'+eoiIds);
                }
				*/
                
                
                
            }
            List<RW_EOI__c> updateEOIRecs = new List<RW_EOI__c>();
            Map<Id,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
            for(RW_EOI__c eoiRec :[Select Id,Name,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : eoiIds])
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
            EmailTemplate custtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment_ChequeDD_Customer'];
            List<Messaging.SingleEmailMessage> custmessages = new List<Messaging.SingleEmailMessage>();
            if(eoiRecordList != null && eoiRecordList.size() >0)
            {
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
                        if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c)!=null)
                            custhtmlBody = custhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
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
                        if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c)!=null)
                            custplainTextBody = custplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
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
            //booking email
            /*
            Map<Id ,Booking__c> bkRecMap = new Map<Id,Booking__c>([select Name, id,Customer__r.RW_Sales_Associate__c, Primary_Applicant_Email__c,Primary_Applicant_Name__c from Booking__c where id in:bkIdSet]);
            EmailTemplate custBookingtemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Digital_Payment_Cheque_DD_Customer'];
            
            
            
            for(id bkid : bkIdSet){
                if(receiptBKMap.containsKey(bkid)&&receiptBKMap.get(bkid).Mode__c	 !='Digital'){
                    String bkcusthtmlBody = custBookingtemplate.HtmlValue; 
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkRecMap.get(bkId).Primary_Applicant_Name__c);
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!Booking__c.Name}', bkRecMap.get(bkId).Name);
                    
                    
                    String dateVal = DateTime.newInstance(receiptBKMap.get(bkid).Cheque_DD_Date__c.year(),receiptBKMap.get(bkid).Cheque_DD_Date__c.month(),receiptBKMap.get(bkid).Cheque_DD_Date__c.day()).format('dd-MM-YYYY');
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!paymentMode}', String.ValueOf(receiptBKMap.get(bkid).Mode__c));
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!Amount}', String.ValueOf(receiptBKMap.get(bkid).Total_Amount__c));
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!BankName}', String.ValueOf(receiptBKMap.get(bkid).DraweeBank__c));
                    
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!BankName}', '');
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!PaymentReferenceNumber}', String.ValueOf(receiptBKMap.get(bkid).Cheque_DD__c));
                    bkcusthtmlBody = bkcusthtmlBody.replace('{!Date}', dateVal);
                    
                    map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
                    if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c)!=null)
                        bkcusthtmlBody = bkcusthtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c).RW_Phone__c));	
                    else
                        bkcusthtmlBody = bkcusthtmlBody.replace('{!SMPhoneNumber}', System.label.RW_BookingSalesContact); 
                    
                    
                    String bkcustplainTextBody = custBookingtemplate.Body; 
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bkRecMap.get(bkId).Primary_Applicant_Name__c);
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!Booking__c.Name}', bkRecMap.get(bkId).Name);
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!paymentMode}', String.ValueOf(receiptBKMap.get(bkid).Mode__c));
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!Amount}', String.ValueOf(receiptBKMap.get(bkid).Total_Amount__c));
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!BankName}', String.ValueOf(receiptBKMap.get(bkid).DraweeBank__c));
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!PaymentReferenceNumber}', String.ValueOf(receiptBKMap.get(bkid).Cheque_DD__c));
                    bkcustplainTextBody = bkcustplainTextBody.replace('{!Date}', dateVal);
                    
                    if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(  bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c)!=null)
                        bkcustplainTextBody = bkcustplainTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get( bkRecMap.get(bkId).customer__r.RW_Sales_Associate__c).RW_Phone__c));	
                    else
                        bkcustplainTextBody = bkcustplainTextBody.replace('{!SMPhoneNumber}', System.label.RW_BookingSalesContact); 
                    Messaging.SingleEmailMessage bkcustmessage = new Messaging.SingleEmailMessage();
                    bkcustmessage.toAddresses = new String[] {bkRecMap.get(bkId).Primary_Applicant_Email__c};
                        bkcustmessage.subject = custBookingtemplate.Subject;
                    bkcustmessage.setTemplateId(custBookingtemplate.Id);
                    bkcustmessage.setHtmlBody(bkcusthtmlBody);   
                    bkcustmessage.setPlainTextBody(bkcustplainTextBody);
                    bkcustmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    custmessages.add(bkcustmessage);
                }
            }
			*/
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
            for(RW_EOI__c eoiRec :[Select Id,Name,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : refundEoiIds])
            {
                eoiRecMap.put(eoiRec.Id,eoiRec) ;
                eoiSalesManagerSet.add(eoiRec.Opportunity__r.RW_Sales_Associate__c);
                ProjectIds.add(eoiRec.Opportunity__r.RW_Project__c);
            }
            
            
            Set<Id> teamIds = new Set<Id>();
            List<Team__c> teamRecord = [Select id from Team__c where Team_Type__c ='MIS' and Project__c IN:ProjectIds] ;
            if(teamRecord != null && teamRecord.size() >0)
            {
                for(Team__c teamRec : teamRecord)
                {
                    teamIds.add(teamRec.Id);
                }
            }

            List<Team_Members__c> teamMembers = [Select Id,Email_Id__c,Team__r.Project__c from Team_Members__c where Team__c IN :teamIds];
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
            
            
            List<User> userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet];
            if(userRec != null && userRec.size() >0)
            {
                for(User u : userRec)
                    eoiSalesManagerEmailIds.put(u.Name,u.Email);
            }
            
            
            EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund_Customer'];
            EmailTemplate internaltemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Refund'];
            List<String> toAddress = new List<String>();
            /*Team_Email_IDs__mdt[] teamEmails = [SELECT Id,Email_IDs__c FROM Team_Email_IDs__mdt Where DeveloperName ='MIS' ];
if(teamEmails != null && teamEmails.size() >0)
{
for(Team_Email_IDs__mdt emailData : teamEmails)
{
toAddress.add(emailData.Email_IDs__c);
}
}
*/
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> internalmessages = new List<Messaging.SingleEmailMessage>();
            List<RW_EOI__c> eoiRefundRecordList = [Select Id,Name,Tower__r.Name,RW_Project_Name__c,RW_Primary_Email__c,RW_Primary_First_Name__c,RW_Primary_Last_Name__c,RW_Status__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : refundEoiIds];
            
            if(eoiRefundRecordList != null && eoiRefundRecordList.size() >0)
            {
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
                        /*    map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c)!=null)
customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
else
customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
*/    
                        String customerTextBody = customertemplate.Body; 
                        customerTextBody = customerTextBody.replace('{!Customer}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);  
                        customerTextBody = customerTextBody.replace('{!Amount}', String.valueOf(eoiReceiptMap.get(eoiRec.Id).Total_Amount__c));
                        customerTextBody = customerTextBody.replace('{!EOIName}',eoiRec.Name);
                        //customerTextBody = customerTextBody.replace('{!TowerName}',eoiRec.Tower__r.Name);
                        customerTextBody = customerTextBody.replace('{!ProjectName}',eoiRec.RW_Project_Name__c);
                        /*       if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get( eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c)!=null)
customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(eoiRecMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c).RW_Phone__c));	
else
customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); */
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
                        
                        if(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c != null && eoiSalesManagerEmailIds.containsKey(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c))
                        {
                            toAddress.add(eoiSalesManagerEmailIds.get(eoiReceiptMap.get(eoiRec.Id).Opportunity__r.RW_Sales_Associate__c));
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
                for(RW_EOI__c eoi :[select Id,Name,Owner.Email,RW_Project_Name__c,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where id IN :eoiIdBD]){
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
            
            EmailTemplate misTeamEOIBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_EOI_MIS_Payment'];
            EmailTemplate misTeamBookingBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_Booking_MIS_Payment'];
            EmailTemplate misTeamCustPortalBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_CustomerPortal_MIS_Payment'];
            EmailTemplate misTeamSAPDemBD = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='BillDesk_SAPDemands_MIS_Payment'];
            
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
    }
    
}