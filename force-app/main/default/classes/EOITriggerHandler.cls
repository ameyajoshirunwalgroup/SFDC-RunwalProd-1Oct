public without sharing class EOITriggerHandler 
{
    public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    @future (callout=true)
    public static void afterUpdateEOI(Set<Id> oIdSet,Set<Id> eoiIds) 
    {
        System.debug('*inside afterUpdateEOI*'+eoiIds + '**'+oIdSet);
        Boolean dataError = false;
        String errMsg ='';
        String customerNumber;
        Set<String> projectIds = new Set<String>();
        Set<String> towerIds = new Set<String>();
        Set<String> projUnitIds = new Set<String>();
        Map<String,Opportunity> opportunityMap= new Map<String,Opportunity>();
        Map<String,Project__c> opportunityProjectMap= new Map<String,Project__c>();
        Map<String,Tower__c> opportunityTowerMap= new Map<String,Tower__c>();
        Map<String,Project_Unit__c> opportunityProjectUnitMap= new Map<String,Project_Unit__c>();
        Map<String,String> dataErrorMap= new Map<String,String>();
        
        
		List<Opportunity> oList  = [Select Id, SAP_Customer_Number__c, RW_Sourcing_Manager__c,RW_Sourcing_Head__c,RW_Sales_Associate__c,RW_Closing_Head__c,Walkin_Source__c,SalesOrder_Number__c, RW_Project_Unit__c,  RW_Project_Unit__r.TowerName__c,  RW_Project__c, RW_Project_Unit__r.Booking__c , (Select Id,Name from EOI__r Where RW_Status__c='EOI Confirmed') from Opportunity where Id IN: oIdSet];           
        {
            System.debug('*inside opportunity*'+oList);
            for(Opportunity opp : oList)
            {
                opportunityMap.put(opp.Id,opp);
                projectIds.add(opp.RW_Project__c);
                //towerIds.add(opp.RW_Project_Unit__r.TowerName__c);
                //projUnitIds.add(opp.RW_Project_Unit__c);
                 //System.debug('*inside opportunity for*'+opportunityMap +'**'+projectIds+'**'+'**'+towerIds+'**'+projUnitIds);
            }
        }
        
        List<Project__c> pRec = [Select Id, Name,SAPMaterial_Code__c, Sales_District__c, Project_Property_Type__c,allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c from Project__c where Id = : projectIds];
			 for(Opportunity opp : oList)
                {
                    for(Project__c projRec : pRec)
                    {
               
                    if(opp.RW_Project__c == projRec.Id)
                    {   
                        if(opportunityProjectMap.containsKey(opp.Id))
                        {
                                if(dataErrorMap.get(opp.Id) == null)
                                dataErrorMap.put(opp.Id,'Project Data Issue,');
                                else
                                dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'Project Data Issue,');  
                        }
                        else
                        {
                                opportunityProjectMap.put(opp.Id,projRec);
                        }
                    }
                }
                    if(opportunityProjectMap.get(opp.Id) == null)
                    {
                        if(dataErrorMap.get(opp.Id) == null)
                        {
                            dataErrorMap.put(opp.Id,'Project Data Issue,');
                        }
                        else if(dataErrorMap.get(opp.Id).contains('Project Data Issue,'))
                        {
                            
                        }
                        else
                        {
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'Project Data Issue,');
                        }
                        
                    }
                    else
                    {
                        if(opportunityProjectMap.get(opp.Id).SAPMaterial_Code__c == null)
                        {
                            if(dataErrorMap.get(opp.Id) == null)
                            dataErrorMap.put(opp.Id,'SAP Project Code not present,');
                            else
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'SAP Project Code not present,');    
                                
                        }
                    }
            }


        
        
      /* List<Tower__c> tRec = [Select Id, Name, SAP_Plant_Code__c  from Tower__c where Id = : towerIds];

            for(Opportunity opp : oList)
            {
                for(Tower__c tow : tRec)
                    {
                        if(opp.RW_Project_Unit__r.TowerName__c == tow.Id)
                        {
                            System.debug('*inside tower if*');
                                if(opportunityTowerMap.containsKey(opp.Id))
                            {
                                    if(dataErrorMap.get(opp.Id) == null)
                                    dataErrorMap.put(opp.Id,'Tower Data Issue,');
                                    else
                                    dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'Tower Data Issue,');   
                            }
                            else
                            {
                                    opportunityTowerMap.put(opp.Id,tow);
                            }
                        }
            }
                
                if(opportunityTowerMap.get(opp.Id) == null)
                    {
                        if(dataErrorMap.get(opp.Id) == null)
                        {
                            dataErrorMap.put(opp.Id,'Tower Data Issue,');
                        }
                         else if(dataErrorMap.get(opp.Id).contains('Tower Data Issue,'))
                        {
                            
                        }
                        else
                        {
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'Tower Data Issue,');
                        }
                        
                    }
                    else
                    {
                        if(opportunityTowerMap.get(opp.Id).SAP_Plant_Code__c == null)
                        {
                            if(dataErrorMap.get(opp.Id) == null)
                            dataErrorMap.put(opp.Id,'SAP Tower Code not present,');
                            else
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'SAP Tower Code not present,');    
                                
                        }
                    }
                
            }
            
         
        
 
      List<Project_Unit__c> projUnit = [Select Id, Name,Unit_SAP_Code__c,Saleable_Area__c, Carpet_area__c from Project_Unit__c where Id = : projUnitIds];
        for(Opportunity opp : oList)
            {
                for(Project_Unit__c projUt : projUnit)
                {
                    if(opp.RW_Project_Unit__c == projUt.Id)
                        {
                           
                                    opportunityProjectUnitMap.put(opp.Id,projUt);
                            
                        }
            }
                
                if(opportunityProjectUnitMap.get(opp.Id) == null)
                    {
                        if(dataErrorMap.get(opp.Id) == null)
                        {
                            dataErrorMap.put(opp.Id,'Unit not present,');
                        }
                         else if(dataErrorMap.get(opp.Id).contains('Unit not present,'))
                        {
                            
                        }
                        else
                        {
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'Unit not present,');
                        }
                        
                    }
                    else
                    {
                        if(opportunityProjectUnitMap.get(opp.Id).Unit_SAP_Code__c == null)
                        {
                            if(dataErrorMap.get(opp.Id) == null)
                            dataErrorMap.put(opp.Id,'SAP Material Code not present in the unit,');
                            else
                            dataErrorMap.put(opp.Id,dataErrorMap.get(opp.Id)+'SAP Material Code not present in the unit,');    
                                
                        }
            	}
         
        } */
         List<RW_EOI__c> eoiRecForEmailNotifications = new List<RW_EOI__c>();
         List<RW_EOI__c> eoiRecords = [SELECT Id, Name  , Tower__c, Tower__r.Property_Type__c,RW_Countries__c,RW_State__c,RW_City__c,RW_Mailing_State__c,RW_Mailing_Country__c,RW_Mailing_City__c,RW_Mailing_Pin__c,RW_Mailing_Address_Line_1__c,RW_Mailing_Address_Line_2__c,RW_Mailing_Address_Line_3__c,RW_Salutation__c,RW_Date_of_Birth__c, RW_Marital_Status__c, Opportunity__c,RW_Residential_Status__c,RW_Type_Of_Applicant__c, RW_Designation__c,RW_Occupation__c,RW_Nationality__c, RW_Type_Of_Origin__c,RW_Origin_Details__c,RW_Pan_Card_Number_of_AuthoritySignatory__c,RW_PassportNoDetails__c, RW_Country_Phone_Code__c ,RW_Gender__c,RW_Permanent_Address_Line_1__c,RW_Permanent_Address_Line_2__c,RW_Permanent_Address_Line_3__c,RW_Document_Number__c,RW_Document_Proof__c,RW_Primary_First_Name__c,RW_Source_RERA_No__c,RW_Primary_Middle_Name__c,RW_Primary_Last_Name__c,RW_Name_of_Company__c,RW_Channel_Partner_s_Name__c,RW_Channel_Partner_s_Company__c,RW_Residential_Company_Address__c,RW_Pin__c,RW_Primary_Contact_No__c,RW_Primary_Email__c ,RW_Primary_PAN_Details__c ,RW_Primary_Alternate_Email__c,RW_Primary_Aadhar_Details__c,RW_Primary_Passport_Details__c ,RW_Secondary_First_Name__c,RW_Secondary_Middle_Name__c,RW_Secondary_Last_Name__c,RW_Secondary_Contact_No__c,RW_Secondary_Email__c,RW_Secondary_PAN_Details__c ,RW_Secondary_Alternate_Email__c ,RW_Secondary_Aadhar_Details__c ,RW_Secondary_Passport_Details__c ,RW_Preferred_Unit_Type__c,RW_Preferred_Budget__c,RW_Preferred_Floors__c,RW_Any_other_preference_please_specify__c,RW_Preferred_Unit_No__c,RW_Tentative_Agreement_Value__c ,RW_Tentative_All_Inclusive_Price__c,RW_Application_Source__c,RW_Sub_Source__c,RW_Closing_Type__c,RW_Source_Contact_No__c,RW_Source_Email_Id__c FROM RW_EOI__c WHERE Id =:eoiIds ];
        List<Opportunity> oppRecs = new List<Opportunity>(); 
        for(RW_EOI__c eoiRec :eoiRecords)   
         { 
             for(Opportunity opp : oList)
             {
                 if(!dataErrorMap.containsKey(opp.id) && eoiRec.Opportunity__c == opp.Id )
                 {
                     if(opp.SAP_Customer_Number__c == null)
                     {
                         System.debug('*before Call*');
                     //customerNumber = createCustomer(opp,eoiRec,opportunityProjectMap.get(opp.Id), opportunityTowerMap.get(opp.Id),opportunityProjectUnitMap.get(opp.Id));
                         customerNumber = createCustomer(opp,eoiRec,opportunityProjectMap.get(opp.Id));
                         opp.SAP_Customer_Number__c = customerNumber;
                    // if(oList != null)
                        //update oList;
                         oppRecs.add(opp);
                         eoiRecForEmailNotifications.add(eoiRec);
                     }
                     
                     else
                     {
                         System.debug('*already customer present*' + opp.SAP_Customer_Number__c);
                     // createCustomer(opp,eoiRec,opportunityProjectMap.get(opp.Id), opportunityTowerMap.get(opp.Id),opportunityProjectUnitMap.get(opp.Id));
                     createCustomer(opp,eoiRec,opportunityProjectMap.get(opp.Id));
                     }
                 }
                 else
                 {
                     ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                    log.API_name__c = 'Customer Creation';
                    if(opp.id != null) 
                    {
                        log.Opportunity__c = opp.id;
                    }
                    log.Status__c = 'Not Processed';
                    log.Error_Reason__c = dataErrorMap.get(opp.id);
                    erpLogList.add(log);
                 }
             }
    
    }
        
        if(oppRecs.size() >0)
        {
            Update oppRecs;
        }
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        if(eoiRecForEmailNotifications.size() >0)
        {
        Set<Id> eoiRecIds = new Set<Id>();
        List<String> toAddress = new List<String>();
        Map<Id ,RW_EOI__c> eoiRecMap = new Map<Id,RW_EOI__c>();
        Set<String> eoiSalesManagerSet = new Set<String>();
        Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
        Map<Id,List<String>> projectTeamEmailIds = new Map<Id,List<String>>();
        Set<Id> ProjetRecIds = new Set<Id>();
        Map<Id,Receipt__c> receiptMap = new Map<Id,Receipt__c>();
        List<Receipt__c> receiptRecords =  [Select Id,Name,Mode__c,RW_Payment_Collection_Type__c, Total_Amount__c,EOI__c,Cheque_DD_Date__c from Receipt__c where EOI__c IN :eoiRecForEmailNotifications and Payment_Gateway__c !='BillDesk' ] ; 
        for(Receipt__c receiptRecord : receiptRecords)
        {
            
            if(receiptRecord.EOI__c != null)
            {
            eoiRecIds.add(receiptRecord.EOI__c);
            receiptMap.put(receiptRecord.Id , receiptRecord);
            }
        }
             for(RW_EOI__c eoiRec :[Select Id,Name,Total_Amount_Received__c,RW_Primary_First_Name__c,Opportunity__r.SAP_Customer_Number__c, Opportunity__r.RW_Sales_Associate__c,RW_Primary_Last_Name__c,RW_Primary_Email__c,Opportunity__r.RW_Project__c,Opportunity__c,Opportunity__r.RW_Project__r.Name,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c where Id IN : eoiRecIds])
        {
           eoiRecMap.put(eoiRec.Id,eoiRec) ;
           eoiSalesManagerSet.add(eoiRec.Opportunity__r.RW_Sales_Associate__c);
           ProjetRecIds.add(eoiRec.Opportunity__r.RW_Project__c);
        }
            
            Set<Id> teamIds = new Set<Id>();
           List<Team__c> teamRecord = [Select id from Team__c where Team_Type__c ='MIS' and Project__c IN:ProjetRecIds] ;
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
                  if(teammem.Email_Id__c != null)
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
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Payment'];
            
            for(Id receipts :  receiptMap.keyset())
        {
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).Name);
            htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptMap.get(receipts).EOI__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).RW_Primary_First_Name__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).RW_Primary_Last_Name__c);
            htmlBody = htmlBody.replace('{!ProjectName}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Name);
            htmlBody = htmlBody.replace('{!Amount}', String.ValueOf(receiptMap.get(receipts).Total_Amount__c));
            htmlBody = htmlBody.replace('{!DateOfPayment}', String.ValueOf(receiptMap.get(receipts).Cheque_DD_Date__c));
            htmlBody = htmlBody.replace('{!PaymentMode}',receiptMap.get(receipts).Mode__c);
            if(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.SAP_Customer_Number__c != null)
            htmlBody = htmlBody.replace('{!SAPCustomerNumber}',eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.SAP_Customer_Number__c);
            else
            htmlBody = htmlBody.replace('{!SAPCustomerNumber}','');
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).Name);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+receiptMap.get(receipts).EOI__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).RW_Primary_First_Name__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).RW_Primary_Last_Name__c);
            plainTextBody = plainTextBody.replace('{!ProjectName}', eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Name);
          
            plainTextBody = plainTextBody.replace('{!Amount}', String.ValueOf(receiptMap.get(receipts).Total_Amount__c));
            plainTextBody = plainTextBody.replace('{!DateOfPayment}', String.ValueOf(receiptMap.get(receipts).Cheque_DD_Date__c));
            plainTextBody = plainTextBody.replace('{!PaymentMode}',receiptMap.get(receipts).Mode__c);
			if(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.SAP_Customer_Number__c != null)
            plainTextBody = plainTextBody.replace('{!SAPCustomerNumber}',eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.SAP_Customer_Number__c);
            else
            plainTextBody = plainTextBody.replace('{!SAPCustomerNumber}','');    
            if(projectTeamEmailIds.containsKey(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c))
            {
                if(projectTeamEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c) != null && projectTeamEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c).size() >0)
                {
                    system.debug('*Email 1*'+projectTeamEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c));
                    if(projectTeamEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c) != null)
                toAddress.addAll(projectTeamEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__c));
                }
            }

            if(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Sales_Site_Head__c != null && eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null )
            
            {
                system.debug('*Email 2*'+eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
                if(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null)
                toAddress.add(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
            }

            if(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Sales_Associate__c != null && eoiSalesManagerEmailIds.containsKey(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Sales_Associate__c))
            {
                system.debug('*Email 3*'+eoiSalesManagerEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Sales_Associate__c));
                If(eoiSalesManagerEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Sales_Associate__c) != null)
                toAddress.add(eoiSalesManagerEmailIds.get(eoiRecMap.get(receiptMap.get(receipts).EOI__c).Opportunity__r.RW_Sales_Associate__c));
            }
            SYSTEM.debug('*EMAIL iDS*'+toAddress);
            if(toAddress != null && toAddress.size() > 0)
            {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            messages.add(message);
            }
            
        }
        
        }
        
        if(messages.size() >0)
        {
            Messaging.sendEmail(messages);
        }
        
        
        if(erpLogList.size() > 0)
        {
            //System.debug('erpLogList**'+erpLogList[0]);
                upsert erpLogList;
        }
    
}
    //public static String createCustomer(Opportunity oppRec,RW_EOI__c eoiRec ,Project__c pRec,Tower__c tRec,Project_Unit__c uList){
public static String createCustomer(Opportunity oppRec,RW_EOI__c eoiRec ,Project__c pRec){
    System.debug('*inside createCustomer method*');            
    String customerNumber;
                CustomerCreation.ZsdSfdcCustomerHd customerHeader = new CustomerCreation.ZsdSfdcCustomerHd();
                if(oppRec.SAP_Customer_Number__c != null)
                {
                    System.debug('*already customer present inside if*' + oppRec.SAP_Customer_Number__c);
                   customerHeader.Kunnr =  oppRec.SAP_Customer_Number__c;
                     System.debug('*already customer present after assign*' + customerHeader.Kunnr);
                }
                customerHeader.Vkorg = pRec.SAPMaterial_Code__c;
                //customerHeader.Werks = tRec.SAP_Plant_Code__c;
                //customerHeader.Vtweg = pRec.Project_Property_Type__c;
                customerHeader.Vtweg = eoiRec.Tower__r.Property_Type__c;
            customerHeader.Spart = '00';
            //customerHeader.Ktokd = pRec.Project_Property_Type__c;
            customerHeader.Ktokd = eoiRec.Tower__r.Property_Type__c;
            customerHeader.Title = eoiRec.RW_Salutation__c;
            customerHeader.NameFirst  = eoiRec.RW_Primary_First_Name__c;
            customerHeader.NameMiddle = eoiRec.RW_Primary_Middle_Name__c;
            customerHeader.NameLast = eoiRec.RW_Primary_Last_Name__c;
            customerHeader.Langucorr = 'E';
            customerHeader.Sort1 = 'EOI';
            customerHeader.Sort2 = oppRec.Id;
            if(String.isNotBlank(eoiRec.RW_Gender__c) && eoiRec.RW_Gender__c.equalsIgnoreCase('Male'))
                    customerHeader.Xsexf = 'M';
                else if( String.isNotBlank(eoiRec.RW_Gender__c) && eoiRec.RW_Gender__c.equalsIgnoreCase('Female') )
                    customerHeader.Xsexf = 'F';
                else
                    customerHeader.Xsexf = 'O';
            
                // to do get list from SAP and update the picklist in Salesforce
            customerHeader.Marst = eoiRec.RW_Marital_Status__c;
            customerHeader.Natio = eoiRec.RW_Nationality__c;
            customerHeader.Jobgr = eoiRec.RW_Occupation__c;
            customerHeader.StaffGrp = eoiRec.RW_Designation__c;
                       
            customerHeader.bzirk= pRec.Sales_District__c; 
            if(('Indian National').equalsIgnoreCase(eoiRec.RW_Residential_Status__c) )
            customerHeader.kukla = 'Resident Indian';
            else if(('Foreign Nationals Of Indian Origin').equalsIgnoreCase(eoiRec.RW_Residential_Status__c ))
            customerHeader.kukla = 'PIO';
            else if(('For NRI').equalsIgnoreCase(eoiRec.RW_Residential_Status__c ))
            customerHeader.kukla = 'NRI';
           // else if(appMap.get('Primary Applicant').Subtype_Of_Applicant__c.equalsIgnoreCase('For Company') )
            //customerHeader.kukla = 'Company';
            else if(('For Company').equalsIgnoreCase(eoiRec.RW_Residential_Status__c ))
            customerHeader.kukla = 'Company';
            else if(('Partnership Firm').equalsIgnoreCase(eoiRec.RW_Residential_Status__c ))
            customerHeader.kukla = 'Partnership Firm';
            
             // these need to mapped in SAP based on SFDC data
                if(String.isNotBlank(oppRec.RW_Sourcing_Manager__c))
                    customerHeader.Kvgr1 =oppRec.RW_Sourcing_Manager__c;
                if(String.isNotBlank(oppRec.RW_Sourcing_Head__c))
                    customerHeader.Kvgr2 =oppRec.RW_Sourcing_Head__c;
                if(String.isNotBlank(oppRec.RW_Sales_Associate__c))
                    customerHeader.Kvgr3 = oppRec.RW_Sales_Associate__c;
                if(String.isNotBlank(oppRec.RW_Closing_Head__c))
                    customerHeader.Kvgr4 = oppRec.RW_Closing_Head__c;
                if(String.isNotBlank(oppRec.Walkin_Source__c))
                    customerHeader.Kvgr5 = oppRec.Walkin_Source__c;
                
                customerHeader.Addrcode = '01';
                
            // to ends here
            
            if(eoiRec.RW_Date_of_Birth__c != null )
            {
                    Date DOB = eoiRec.RW_Date_of_Birth__c;
                    String strMonth;
                    String strDate;
                    
                    if(String.valueof(DOB.month()).length()  ==1)
                    strMonth = '0' + String.valueof(DOB.month());
                    else 
                    strMonth = String.valueof(DOB.month());
                    
                    if(String.valueof(DOB.day()).length()  ==1)
                    strDate = '0' + String.valueof(DOB.day());
                    else 
                    strDate = String.valueof(DOB.day());
                    
                    customerHeader.Birthdt = String.valueof(DOB.year()) + strMonth + strDate;
            }
            //customerHeader.Katr1 = bList[0].Source_of_Booking__c;
            //if(String.isNotBlank(appMap.get('Primary Applicant').Organization_Name__c))
                    //customerHeader.Emplo = appMap.get('Primary Applicant').Organization_Name__c;
             customerHeader.Vkbur = pRec.SAPMaterial_Code__c;        

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
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem1 = new CustomerCreation.ZsdSfdcCustomerTax();
            // Mandatory for Indian National, NRI , Company and Partnership firm
            if(String.isNotBlank(eoiRec.RW_Primary_PAN_Details__c) ) {
                taxLineitem1.Ind = 'M';
                taxLineitem1.Taxtype = 'IN6';
                taxLineitem1.Taxnumxl = eoiRec.RW_Primary_PAN_Details__c;
                customerTaxList.item.add(taxLineItem1);
            }
            // In case of Indian National we collect address proof documents in form or Aadhar, Passport, Driving License, Electricity Bill or Voters card.
           // In case of company we dont collect anything other than pan card, so that already addressed above.
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem2 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_Document_Proof__c) && eoiRec.RW_Document_Proof__c.equalsIgnoreCase('Aadhar Card')) {
                taxLineitem2.Ind = 'M';
                taxLineitem2.Taxtype = 'IN5';
                taxLineitem2.Taxnumxl = eoiRec.RW_Document_Number__c;
                customerTaxList.item.add(taxLineItem2);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem3 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_Document_Proof__c) && eoiRec.RW_Document_Proof__c.equalsIgnoreCase('Driving License')) {
                taxLineitem3.Ind = 'M';
                taxLineitem3.Taxtype = 'IN7';
                taxLineitem3.Taxnumxl = eoiRec.RW_Document_Number__c;
                customerTaxList.item.add(taxLineitem3);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem4 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_Document_Proof__c) && eoiRec.RW_Document_Proof__c.equalsIgnoreCase('Passport')) {
                taxLineitem4.Ind = 'M';
                taxLineitem4.Taxtype = 'IN4';
                taxLineitem4.Taxnumxl = eoiRec.RW_Document_Number__c;
                customerTaxList.item.add(taxLineitem4);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem6 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_Document_Proof__c) && eoiRec.RW_Document_Proof__c.equalsIgnoreCase('Electricity Bill')) {
                taxLineitem6.Ind = 'M';
                taxLineitem6.Taxtype = 'IN9';
                taxLineitem6.Taxnumxl = eoiRec.RW_Document_Number__c;
                customerTaxList.item.add(taxLineitem6);
            }
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem7 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_Document_Proof__c) && eoiRec.RW_Document_Proof__c.equalsIgnoreCase('Voter\'s  ID Card')) {
                taxLineitem7.Ind = 'M';
                taxLineitem7.Taxtype = 'IN8';
                taxLineitem7.Taxnumxl = eoiRec.RW_Document_Number__c;
                customerTaxList.item.add(taxLineitem7);
            }
            
             // In case of NRI we collect passport #, but doesn't get categorised as address proof document
             CustomerCreation.ZsdSfdcCustomerTax taxLineitem5 = new CustomerCreation.ZsdSfdcCustomerTax();
            if(String.isNotBlank(eoiRec.RW_PassportNoDetails__c)) {
                taxLineitem5.Ind = 'M';
                taxLineitem5.Taxtype = 'IN4';
                taxLineitem5.Taxnumxl = eoiRec.RW_PassportNoDetails__c;
                customerTaxList.item.add(taxLineitem5);
            }
            
             
            
            // Mailing, Permanent and Office address of primary applicant
            CustomerCreation.TableOfZsdSfdcCustomerAddress customerAddressList = new CustomerCreation.TableOfZsdSfdcCustomerAddress();
            customerAddressList.item = new List<CustomerCreation.ZsdSfdcCustomerAddress>();
            
            CustomerCreation.ZsdSfdcCustomerAddress mailingAddressItem = new CustomerCreation.ZsdSfdcCustomerAddress();
            mailingAddressItem.Addrcode = '01';
            mailingAddressItem.Street = eoiRec.RW_Mailing_Address_Line_1__c;
            mailingAddressItem.StrSuppl1 =  eoiRec.RW_Mailing_Address_Line_2__c;
            mailingAddressItem.StrSuppl2 =   eoiRec.RW_Mailing_Address_Line_3__c;
            mailingAddressItem.PostCode = String.valueOf(eoiRec.RW_Mailing_Pin__c);
            mailingAddressItem.City = eoiRec.RW_Mailing_City__c;
            if(eoiRec.RW_Mailing_Country__c == 'United Arab Emirates')
            mailingAddressItem.Country = 'Utd.Arab Emir.';
            else if(eoiRec.RW_Mailing_Country__c == 'United States')
            mailingAddressItem.Country = 'USA';
            else
            mailingAddressItem.Country = eoiRec.RW_Mailing_Country__c;
            // to do check with SAP
            mailingAddressItem.Region  = eoiRec.RW_Mailing_State__c; 
            customerAddressList.item.add(mailingAddressItem);
            
            // permanent address
            CustomerCreation.ZsdSfdcCustomerAddress permanentAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
            permanentAddress.Addrcode = '02';
            permanentAddress.Street = eoiRec.RW_Permanent_Address_Line_1__c;
            permanentAddress.StrSuppl1 =  eoiRec.RW_Permanent_Address_Line_2__c;
            permanentAddress.StrSuppl2 =  eoiRec.RW_Permanent_Address_Line_3__c;
            permanentAddress.PostCode = String.valueOf(eoiRec.RW_Pin__c);
            permanentAddress.City = eoiRec.RW_City__c;
            if(eoiRec.RW_Countries__c == 'United Arab Emirates')
            permanentAddress.Country = 'Utd.Arab Emir.';
            else if(eoiRec.RW_Countries__c == 'United States')
            permanentAddress.Country = 'USA';
            else
            permanentAddress.Country = eoiRec.RW_Countries__c;
            // to do check with SAP
            permanentAddress.Region  = eoiRec.RW_State__c;
            customerAddressList.item.add(permanentAddress);
            
            // office address
         /*   if(String.isNotBlank(appMap.get('Primary Applicant').Office_Address_Line_1__c) ) {
                CustomerCreation.ZsdSfdcCustomerAddress officeAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
                officeAddress.Addrcode = '03';
                officeAddress.Street = appMap.get('Primary Applicant').Office_Address_Line_1__c;
                officeAddress.StrSuppl1 =  appMap.get('Primary Applicant').Office_Address_Line_2__c;
                officeAddress.StrSuppl2 =  appMap.get('Primary Applicant').Office_Address_Line_3__c;
                officeAddress.PostCode = String.valueOf(appMap.get('Primary Applicant').Organisation_Pincode__c);
                officeAddress.Country = appMap.get('Primary Applicant').Organisation_Country__c;
                // to do check with SAP
                customerAddressList.item.add(officeAddress);
            }
            */
            //---------------------
            CustomerCreation.TableOfZsdsBpContact  coAppList = new CustomerCreation.TableOfZsdsBpContact();
            coAppList.Item = new List<CustomerCreation.ZsdsBpContact>();
            CustomerCreation.ZsdsBpContact coApp1 = new CustomerCreation.ZsdsBpContact();
                    coApp1.Srno = String.ValueOf(10);
                    if(oppRec.SAP_Customer_Number__c != null)
                {
                    //System.debug('*already customer present inside if*' + oppRec.SAP_Customer_Number__c);
                   coApp1.Partner = oppRec.SAP_Customer_Number__c;
                }  
                    coApp1.NameFirst = eoiRec.RW_Secondary_First_Name__c;
                    coApp1.NameMiddle = eoiRec.RW_Secondary_Middle_Name__c;
                    coApp1.NameLast = eoiRec.RW_Secondary_Last_Name__c;
                        if(String.isNotBlank(eoiRec.RW_Secondary_PAN_Details__c))
                            coApp1.Pan = eoiRec.RW_Secondary_PAN_Details__c;
						if(String.isNotBlank(eoiRec.RW_Secondary_Aadhar_Details__c))
                            coApp1.Aadhar = eoiRec.RW_Secondary_Aadhar_Details__c;
    					if(String.isNotBlank(eoiRec.RW_Secondary_Passport_Details__c))
                            coApp1.Aadhar = eoiRec.RW_Secondary_Passport_Details__c;
                        if(String.isNotBlank(eoiRec.RW_Secondary_Email__c))
                            coApp1.smtpAddr = eoiRec.RW_Secondary_Email__c;
						 coApp1.Mobile = eoiRec.RW_Secondary_Contact_No__c;
                        coAppList.Item.add(coApp1);
            
            
            //----------------------
           /* Integer SeqNo = 10;
            Integer count = 1;
            // Co Applicant Details
            CustomerCreation.TableOfZsdsBpContact  coAppList = new CustomerCreation.TableOfZsdsBpContact();
            coAppList.Item = new List<CustomerCreation.ZsdsBpContact>();
            for(String appNumber : appMap.keySet()) {
                    if(!appNumber.equalsIgnoreCase('Primary Applicant')) {
                    CustomerCreation.ZsdsBpContact coApp1 = new CustomerCreation.ZsdsBpContact();
                    coApp1.Srno = String.ValueOf(SeqNo * count);
                    coApp1.Title = appMap.get(appNumber).Salutation__c;
                    coApp1.NameFirst = appMap.get(appNumber).First_Name__c;
                    coApp1.NameMiddle = appMap.get(appNumber).Middle_Name__c;
                    coApp1.NameLast = appMap.get(appNumber).Last_Name__c;
                    if(String.isNotBlank(appMap.get(appNumber).Designation_picklist__c))
                            coApp1.Pafkt = appMap.get(appNumber).Designation_picklist__c;
                        if(String.isNotBlank(appMap.get(appNumber).Occupation__c))
                            coApp1.Abtnr = appMap.get(appNumber).Occupation__c;
                    if(String.isNotBlank(appMap.get(appNumber).gender__c) && appMap.get(appNumber).gender__c.equalsIgnoreCase('Male'))
                            coApp1.Xsexf = 'M';
                        else if( String.isNotBlank(appMap.get(appNumber).gender__c) && appMap.get(appNumber).gender__c.equalsIgnoreCase('Female') )
                            coApp1.Xsexf = 'F';
                        else
                            coApp1.Xsexf = 'O';
                        // to check with SAP
                    coApp1.Marst = appMap.get(appNumber).Marital_Status__c;
                    
                    if(appMap.get(appNumber).DOB__c != null )
                        {
                            Date DOB = appMap.get(appNumber).DOB__c;
                            String strMonth;
                            String strDate;
                            if(String.valueof(DOB.month()).length()  ==1)
                            strMonth = '0' + String.valueof(DOB.month());
                            else 
                            strMonth = String.valueof(DOB.month());
                            
                            if(String.valueof(DOB.day()).length()  ==1)
                            strDate = '0' + String.valueof(DOB.day());
                            else 
                            strDate = String.valueof(DOB.day());
                            
                            coApp1.Birthdt = String.valueof(DOB.year()) + strMonth + strDate;
                        }
                        
                    coApp1.Street = appMap.get(appNumber).Mailing_Address_Line_1__c;
                    coApp1.StrSuppl1 = appMap.get(appNumber).Mailing_Address_Line_2__c;
                    coApp1.strSuppl2 = appMap.get(appNumber).Mailing_Address_Line_3__c;
                    coApp1.PostCode = String.valueOf(appMap.get(appNumber).Mailing_Pincode__c);
                        coApp1.City = appMap.get(appNumber).Mailing_City__c;
                        coApp1.Country = appMap.get(appNumber).Mailing_Country__c;
                    // to do check with SAP
                    coApp1.Region  = appMap.get(appNumber).Mailing_State__c;
                    coApp1.Mobile = appMap.get(appNumber).Mobile_Number__c;
                    coApp1.CpReln  = appMap.get(appNumber).Contact_Person_Relationship__c;
                    // map the co applicant number.
                    if(appNumber.equalsIgnoreCase('Second Applicant'))
                            coApp1.CpRole = 'CO-APPLICANT 1';
                        else if(appNumber.equalsIgnoreCase('Third Applicant'))
                            coApp1.CpRole = 'CO-APPLICANT 2';
                        else if(appNumber.equalsIgnoreCase('Fourth Applicant'))
                            coApp1.CpRole = 'CO-APPLICANT 3';
                        else if(appNumber.equalsIgnoreCase('Fifth Applicant'))
                            coApp1.CpRole = 'CO-APPLICANT 4';
                        if(String.isNotBlank(appMap.get(appNumber).PancardNo__c))
                            coApp1.Pan = appMap.get(appNumber).PancardNo__c;
                        if(String.isNotBlank(appMap.get(appNumber).Email_Address__c))
                            coApp1.smtpAddr = appMap.get(appNumber).Email_Address__c;
                    
                        if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Aadhar Card'))
                            coApp1.Aadhar = appMap.get(appNumber).Address_Proof_Number__c;
                        if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Passport'))
                            coApp1.Passport = appMap.get(appNumber).Address_Proof_Number__c;
                   //   if(String.isNotBlank(appMap.get(appNumber).Address_Proof_Document__c) && appMap.get(appNumber).Address_Proof_Document__c.equalsIgnoreCase('Driving License'))
                            // populate drivers license in the respective field
                            // coApp1.Aadhar = appMap.get(appNumber).Address_Proof_Number__c;
                        coAppList.Item.add(coApp1);
                        count ++;
                    }
            }
*/
                // phone and email of permanent applicant 
                CustomerCreation.TableOfZsdSfdcCustomerComm  commList = new CustomerCreation.TableOfZsdSfdcCustomerComm();
                commList.Item = new List<CustomerCreation.ZsdSfdcCustomerComm>();
                CustomerCreation.ZsdSfdcCustomerComm commItem1 = new CustomerCreation.ZsdSfdcCustomerComm();
                commItem1.Addrcode = '01';
            commItem1.MobileNo  = eoiRec.RW_Primary_Contact_No__c;
            commItem1.SmtpAddr =  eoiRec.RW_Primary_Email__c;
            commList.item.add(commItem1);
           
            // logger data population
            //   // Manoj:03-01-2021:Moving to new loggger logic where will will log the request as is without cleanup
            CustomerCreationErrorLogger cLog = new CustomerCreationErrorLogger();
            cLog.customerHeader = customerHeader;
            cLog.customerTaxList = customerTaxList;
            cLog.customerAddressList =customerAddressList;
            cLog.coAppList = coAppList;
            cLog.commList = commList;
    /*
            CustomerCreationLogger.ZsdSfdcCustomerHd chl = new  CustomerCreationLogger.ZsdSfdcCustomerHd();
            chl.Kunnr=customerHeader.Kunnr;
            chl.Vkorg = customerHeader.Vkorg;
            chl.Werks = customerHeader.Werks;
            chl.Vtweg = customerHeader.Vtweg;
            chl.Spart= customerHeader.Spart;
            chl.Ktokd= customerHeader.Ktokd;
            chl.Title= customerHeader.Title;
            chl.NameFirst= customerHeader.NameFirst;
            chl.NameLast= customerHeader.NameLast;
            chl.NameMiddle= customerHeader.NameMiddle;
            chl.Langucorr= customerHeader.Langucorr;
            chl.Sort1= customerHeader.Sort1;
            chl.Sort2= customerHeader.Sort2;
            chl.Xsexf= customerHeader.Xsexf;
            chl.Marst= customerHeader.Marst;
            chl.Natio= customerHeader.Natio;
            chl.Jobgr= customerHeader.Jobgr;
            chl.Birthdt= customerHeader.Birthdt;
            chl.Birthpl= customerHeader.Birthpl;
            chl.StaffGrp= customerHeader.StaffGrp;
            chl.Bpext= customerHeader.Bpext;
            chl.Kukla= customerHeader.Kukla;
            chl.Niels= customerHeader.Niels;
            chl.Katr1= customerHeader.Katr1;
            chl.Emplo= customerHeader.Emplo;
            chl.Kvgr1= customerHeader.Kvgr1;
            chl.Kvgr2= customerHeader.Kvgr2;
            chl.Kvgr3= customerHeader.Kvgr3;
            chl.Kvgr4= customerHeader.Kvgr4;
            chl.Kvgr5= customerHeader.Kvgr5;
            chl.Bzirk= customerHeader.Bzirk;
            chl.Vkbur= customerHeader.Vkbur;
            chl.Vkgrp= customerHeader.Vkgrp;
            chl.Kdgrp= customerHeader.Kdgrp;
            chl.Klabc= customerHeader.Klabc;
            chl.Waers= customerHeader.Waers;
            chl.Addrcode= customerHeader.Addrcode;
            
                CustomerCreationLogger.TableOfZsdSfdcCustomerComm  commListLogger = new CustomerCreationLogger.TableOfZsdSfdcCustomerComm();
                commListLogger.Item = new List<CustomerCreationLogger.ZsdSfdcCustomerComm>();
                
                for(CustomerCreation.ZsdSfdcCustomerComm comm1 : commList.Item) {
                    CustomerCreationLogger.ZsdSfdcCustomerComm commLogItem1 = new CustomerCreationLogger.ZsdSfdcCustomerComm();
                    commLogItem1.Addrcode = comm1.Addrcode;
                commLogItem1.MobileNo  = comm1.MobileNo;
                commLogItem1.SmtpAddr =  comm1.SmtpAddr;
                commListLogger.item.add(commLogItem1);
                }
            
                CustomerCreationLogger.TableOfZsdSfdcCustomerTax customerTaxListlogger = new CustomerCreationLogger.TableOfZsdSfdcCustomerTax();
            customerTaxListlogger.item = new List<CustomerCreationLogger.ZsdSfdcCustomerTax>();
            for(CustomerCreation.ZsdSfdcCustomerTax tax1 : customerTaxList.item) {
                    CustomerCreationLogger.ZsdSfdcCustomerTax taxLogLineitem1 = new CustomerCreationLogger.ZsdSfdcCustomerTax();
                    taxLogLineitem1.Ind = tax1.Ind;
                    taxLogLineitem1.Taxtype = tax1.Taxtype;
                taxLogLineitem1.Taxnumxl = tax1.Taxnumxl;
                customerTaxListlogger.item.add(taxLogLineitem1);
            }
            
            CustomerCreationLogger.TableOfZsdsBpContact  coAppLogList = new CustomerCreationLogger.TableOfZsdsBpContact();
            coAppLogList.Item = new List<CustomerCreationLogger.ZsdsBpContact>();
            for(CustomerCreation.ZsdsBpContact contact1 : coAppList.item) {
                    CustomerCreationLogger.ZsdsBpContact contactLog1 = new CustomerCreationLogger.ZsdsBpContact();
                contactLog1.Partner = contact1.Partner;
                contactLog1.Srno = contact1.Srno;
                contactLog1.Title = contact1.Title;
                contactLog1.NameFirst = contact1.NameFirst;
                contactLog1.NameLast = contact1.NameLast;
                contactLog1.NameMiddle = contact1.NameMiddle;
                contactLog1.Xsexf = contact1.Xsexf;
                contactLog1.Marst = contact1.Marst;
                contactLog1.Birthdt = contact1.Birthdt;
                contactLog1.Street = contact1.Street;
                contactLog1.StrSuppl1 = contact1.StrSuppl1;
                contactLog1.StrSuppl2 = contact1.StrSuppl2;
                contactLog1.StrSuppl3 = contact1.StrSuppl3;
                contactLog1.Location = contact1.Location;
                contactLog1.PostCode = contact1.PostCode;
                contactLog1.City = contact1.City;
                contactLog1.Country = contact1.Country;
                contactLog1.Region = contact1.Region;
                contactLog1.Landline = contact1.Landline;
                contactLog1.Mobile = contact1.Mobile;
                contactLog1.FaxNumber = contact1.FaxNumber;
                contactLog1.CpRole = contact1.CpRole;
                contactLog1.CpReln = contact1.CpReln;
                contactLog1.Abtnr = contact1.Abtnr;
                contactLog1.Pafkt = contact1.Pafkt;
                contactLog1.SmtpAddr = contact1.SmtpAddr;
                contactLog1.Pan = contact1.Pan;
                contactLog1.Aadhar = contact1.Aadhar;
                contactLog1.Passport = contact1.Passport;
                coAppLogList.Item.add(contactLog1);
            }
            
            // Mailing, Permanent and Office address of primary applicant
            CustomerCreationLogger.TableOfZsdSfdcCustomerAddress customerAddressLogList = new CustomerCreationLogger.TableOfZsdSfdcCustomerAddress();
            customerAddressLogList.item = new List<CustomerCreationLogger.ZsdSfdcCustomerAddress>();
            for(CustomerCreation.ZsdSfdcCustomerAddress addr1 : customerAddressList.item) {
                    CustomerCreationLogger.ZsdSfdcCustomerAddress addrLog1 = new CustomerCreationLogger.ZsdSfdcCustomerAddress();
                    addrLog1.Addrcode = addr1.Addrcode;
                addrLog1.Seqno = addr1.Seqno;
                addrLog1.NameCo = addr1.NameCo;
                addrLog1.Street = addr1.Street;
                addrLog1.StrSuppl1 = addr1.StrSuppl1;
                addrLog1.StrSuppl2 = addr1.StrSuppl2;
                addrLog1.StrSuppl3 = addr1.StrSuppl3;
                addrLog1.Location = addr1.Location;
                addrLog1.PostCode = addr1.PostCode;
                addrLog1.City = addr1.City;
                addrLog1.Country = addr1.Country;
                addrLog1.Region = addr1.Region;
                customerAddressLogList.item.add(addrLog1);
            }
            CustomerCreationLogger.ZsdSfdcCustomer_element ccRequestLog = new CustomerCreationLogger.ZsdSfdcCustomer_element();
                ccRequestLog.CustomerAddress = customerAddressLogList;
            ccRequestLog.CustomerComm = commListLogger;
            ccRequestLog.CustomerContact = coAppLogList;
            ccRequestLog.CustomerHeader = chl;
            ccRequestLog.CustomerTax = customerTaxListlogger;
            // logger ends here.
            */
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
                  System.debug('*before SAP call*');   
            CustomerCreation.ZSD_SFDC_CUSTOMER customerCreation = new CustomerCreation.ZSD_SFDC_CUSTOMER();
            CustomerCreation.ZsdSfdcCustomerResponse_element customerCreationResponse = customerCreation.ZsdSfdcCustomer(customerAddressList,commList, coAppList,customerHeader,customerTaxList, bapiRet2List);
            System.debug('Customer creation response:' + customerCreationResponse);
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
                    
                } else {
                    callOutError = true;
                                       ExceptionError = true;             
                    exceptionMsg = 'Customer number # not received';
                    
                }
            } catch (Exception ex) {
                System.debug('Exception:' + ex.getMessage());
                callOutError = true;
                exceptionMsg = ex.getMessage();
            } finally {
                System.debug('JSON Logger request:' + JSON.SerializePretty(cLog));
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                String requestF = JSON.SerializePretty(cLog);
                requestF =  requestF.replaceAll('&quot;','"');
             //   requestF  = requestF.replaceAll('\t', '&nbsp;');
                log.request__c = requestF;
                log.API_name__c = 'Customer Creation/Update';
                //log.Booking__c = bookingId;
                log.Opportunity__c = oppRec.Id;
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
                erpLogList.add(log);
                
            }
        
        return customerNumber;
    }
    
    
    public static void afterUpdateCancellation(Map<Id,RW_EOI__c> eoiMap) 
    {
      Set<Id> eoiIDs = new Set<Id>();
      Set<Id> ProjectIds = new Set<Id>();
      Map<Id,List<String>> projectTeamEmailIds = new Map<Id,List<String>>();
      List<String> opportunityIds = new List<String>();
      List<String> toAddress = new List<String>();
      List<Opportunity> oppRecords = new List<Opportunity>();
        Set<String> eoiSalesManagerSet = new Set<String>();
        Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
        Map<String,String> eoiSourcingManagerEmailIds = new Map<String,String>();
        
        Set<String>  eoiSourcingManagerSet = new Set<String> ();
        
      Map<String,Opportunity> opportunityEoiMap = new Map<String,Opportunity>();
      List<Project_Unit__c> units = new List<Project_Unit__c>();
      List<Project_Unit__c> projUnits =  [Select Id,Name,EOI__c, RW_EOI_Block_Status__c from Project_Unit__c Where EOI__c IN : eoiMap.keySet() ];
      for(Project_Unit__c projUnit : projUnits)
      {
          projUnit.EOI__c = null;
          projUnit.RW_EOI_Block_Status__c = 'EOI Available';
          projUnit.RW_EOI_Blocked_By__c = null;
          projUnit.RW_EOI_Blocked_Date__c =null;
          units.add(projUnit);
      }
        
        if(units.size() > 0)
        {
            Update units;
        }
        
        for(RW_EOI__c eoiRec : eoiMap.values())
            {
                opportunityIds.add(eoiRec.Opportunity__c);
                eoiIDs.add(eoiRec.Id);
                
                
            }
        
        List<RW_EOI__c> eoiRecs =[Select Opportunity__r.RW_Project__c from RW_EOI__c where id IN:eoiIDs];
        for(RW_EOI__c eoiR : eoiRecs)
        {
            ProjectIds.add(eoiR.Opportunity__r.RW_Project__c);
        }
        System.debug('inside method');
        
        List<Opportunity> oppRecList = [Select Id,RW_Project__r.Name ,RW_Project__r.Sales_Site_Head__c,RW_Project__r.Sales_Site_Head__r.Email,RW_Sales_Associate__c,RW_Sourcing_Manager__c, SAP_Customer_Number__c from Opportunity where Id= :opportunityIds];
        for(Opportunity opp : oppRecList)
        {
            for(RW_EOI__c eoiRec : eoiMap.values())
                {
                    if(eoiRec.Opportunity__c == opp.Id)
                    {
                     opportunityEoiMap.put(eoiRec.Id, opp);
                     oppRecords.add(opp);
                     eoiSalesManagerSet.add(opp.RW_Sales_Associate__c);
                     eoiSourcingManagerSet.add(opp.RW_Sourcing_Manager__c);
                    }
                }
        }
        
        for(Opportunity oppRec : oppRecords)
        {
            oppRec.StageName = 'Qualification';
        }
        
            update oppRecords;
        
        
           Set<Id> teamIds = new Set<Id>();
           List<Team__c> teamRecord = [Select id from Team__c where (Team_Type__c ='Accounts' or Team_Type__c ='MIS') and Project__c IN:ProjectIds] ;
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
        
        List<User> userRecord = [Select id,Name,Email from User Where Name IN:eoiSourcingManagerSet];
            if(userRecord != null && userRecord.size() >0)
            {
                for(User u : userRecord)
                eoiSourcingManagerEmailIds.put(u.Name,u.Email);
            }
            
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation'];
            EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Customer'];
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();

            for(RW_EOI__c eoiRec : eoiMap.values())
            {
                if(projectTeamEmailIds.containsKey(opportunityEoiMap.get(eoiRec.Id).RW_Project__c))
            {
                if(projectTeamEmailIds.get(opportunityEoiMap.get(eoiRec.Id).RW_Project__c) != null && projectTeamEmailIds.get(opportunityEoiMap.get(eoiRec.Id).RW_Project__c).size() >0)
                toAddress.addAll(projectTeamEmailIds.get(opportunityEoiMap.get(eoiRec.Id).RW_Project__c));
            }
                
                
            if(opportunityEoiMap.get(eoiRec.Id).RW_Project__r.Sales_Site_Head__c != null && opportunityEoiMap.get(eoiRec.Id).RW_Project__r.Sales_Site_Head__r.Email != null )
            toAddress.add(opportunityEoiMap.get(eoiRec.Id).RW_Project__r.Sales_Site_Head__r.Email);

            if(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c != null && eoiSalesManagerEmailIds.containsKey(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c))
            {
                toAddress.add(eoiSalesManagerEmailIds.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c));
            }
                 if(opportunityEoiMap.get(eoiRec.Id).RW_Sourcing_Manager__c != null && eoiSourcingManagerEmailIds.containsKey(opportunityEoiMap.get(eoiRec.Id).RW_Sourcing_Manager__c))
            {
                toAddress.add(eoiSourcingManagerEmailIds.get(opportunityEoiMap.get(eoiRec.Id).RW_Sourcing_Manager__c));
            }
                
                
                if(toAddress.size() >0)
                {
              System.debug('inside for'+template);
            String htmlBody = template.HtmlValue; 
            htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            htmlBody = htmlBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRec.Id);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
            htmlBody = htmlBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
            htmlBody = htmlBody.replace('{!ProjectName}', opportunityEoiMap.get(eoiRec.Id).RW_Project__r.Name);
            if(opportunityEoiMap.get(eoiRec.Id).SAP_Customer_Number__c != null )
            htmlBody = htmlBody.replace('{!SAPCustomerNumber}', opportunityEoiMap.get(eoiRec.Id).SAP_Customer_Number__c);
            else
            htmlBody = htmlBody.replace('{!SAPCustomerNumber}', '');
            
              
                
            System.debug('htnl'+htmlBody);
            String plainTextBody = template.Body; 
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.Link}', Url.getOrgDomainUrl().toExternalForm()+'/'+eoiRec.Id);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_First_Name__c}', eoiRec.RW_Primary_First_Name__c);
            plainTextBody = plainTextBody.replace('{!RW_EOI__c.RW_Primary_Last_Name__c}', eoiRec.RW_Primary_Last_Name__c);
            plainTextBody = plainTextBody.replace('{!ProjectName}', opportunityEoiMap.get(eoiRec.Id).RW_Project__r.Name);
            if(opportunityEoiMap.get(eoiRec.Id).SAP_Customer_Number__c != null )
            plainTextBody = plainTextBody.replace('{!SAPCustomerNumber}', opportunityEoiMap.get(eoiRec.Id).SAP_Customer_Number__c);
            else
            plainTextBody = plainTextBody.replace('{!SAPCustomerNumber}', '');
             
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                System.debug('toAddress'+toAddress);
            
            message.toAddresses = toAddress;
            message.subject = template.Subject;
            message.setTemplateId(template.Id);
            //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
            message.setHtmlBody(htmlBody); 
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            messages.add(message);
            //Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            System.debug('inside for end');
                }   
                
            String customerhtmlBody = customertemplate.HtmlValue; 
            customerhtmlBody = customerhtmlBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');  
                
                String customerTextBody = customertemplate.Body; 
            customerTextBody = customerTextBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);  
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx');  
            
            Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
            custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
            custmessage.subject = customertemplate.Subject;
            custmessage.setTemplateId(customertemplate.Id);
            custmessage.setHtmlBody(customerhtmlBody); 
            custmessage.setPlainTextBody(customerTextBody);
            custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            customermessages.add(custmessage);    
            
            }
        if(messages.size() >0)
         Messaging.sendEmail(messages);
        
        if(customermessages.size() >0)
        Messaging.sendEmail(customermessages);
    }
    
    public static void afterCancellationInitiation(Map<Id,RW_EOI__c> eoiMap) 
    {
            EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Initiated_Customer'];
            Set<Id> opportunityIds = new Set<Id>();
            Map<Id,Opportunity> opportunityEoiMap = new Map<Id,Opportunity>();
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();
             for(RW_EOI__c eoiRec : eoiMap.values())
            {
                opportunityIds.add(eoiRec.Opportunity__c);
            }
        
            List<Opportunity> oppRecList = [Select Id,RW_Project__r.Name ,RW_Sales_Associate__c, SAP_Customer_Number__c from Opportunity where Id= :opportunityIds];
        for(Opportunity opp : oppRecList)
        {
            for(RW_EOI__c eoiRec : eoiMap.values())
                {
                    if(eoiRec.Opportunity__c == opp.Id)
                    {
                     opportunityEoiMap.put(eoiRec.Id, opp);

                    }
                }
        }
        
        
        for(RW_EOI__c eoiRec : eoiMap.values())
            {
            String customerhtmlBody = customertemplate.HtmlValue; 
            customerhtmlBody = customerhtmlBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
                String customerTextBody = customertemplate.Body; 
            customerTextBody = customerTextBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);  
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
            
            Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
            custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
            custmessage.subject = customertemplate.Subject;
            custmessage.setTemplateId(customertemplate.Id);
            //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
            custmessage.setHtmlBody(customerhtmlBody); 
            custmessage.setPlainTextBody(customerTextBody);
            custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            customermessages.add(custmessage); 
    }
        Messaging.sendEmail(customermessages);
}
    
    public static void afterCancellationComplete(Map<Id,RW_EOI__c> eoiMap) 
    {
            EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Cancellation_Complete_Customer'];
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();
        
        Set<Id> opportunityIds = new Set<Id>();
            Map<Id,Opportunity> opportunityEoiMap = new Map<Id,Opportunity>();
             for(RW_EOI__c eoiRec : eoiMap.values())
            {
                opportunityIds.add(eoiRec.Opportunity__c);
            }
        
            List<Opportunity> oppRecList = [Select Id,RW_Project__r.Name ,RW_Sales_Associate__c, SAP_Customer_Number__c from Opportunity where Id= :opportunityIds];
        for(Opportunity opp : oppRecList)
        {
            for(RW_EOI__c eoiRec : eoiMap.values())
                {
                    if(eoiRec.Opportunity__c == opp.Id)
                    {
                     opportunityEoiMap.put(eoiRec.Id, opp);

                    }
                }
        }
        
        for(RW_EOI__c eoiRec : eoiMap.values())
            {
            String customerhtmlBody = customertemplate.HtmlValue; 
            customerhtmlBody = customerhtmlBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
             map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
                String customerTextBody = customertemplate.Body; 
            customerTextBody = customerTextBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);  
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
            
            Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
            custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
            custmessage.subject = customertemplate.Subject;
            custmessage.setTemplateId(customertemplate.Id);
            //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
            custmessage.setHtmlBody(customerhtmlBody); 
            custmessage.setPlainTextBody(customerTextBody);
            custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            customermessages.add(custmessage); 
                
           //-------------
                
    }
        Messaging.sendEmail(customermessages);
}
    
    public static void afterEOIBlock(Map<Id,RW_EOI__c> eoiMap) 
    {
            set<Id> eoiIds = new Set<Id>();
            Map<Id,String> SiteHeadMap = new Map<Id,String>();
            List<Project_Unit__c> units = new List<Project_Unit__c>();
            Map<Id,Project_Unit__c> eoiUnitMap = new Map<Id,Project_Unit__c>();
           Set<String> eoiSalesManagerSet = new Set<String>();
          Map<Id,String> eoiSalesManagerMap = new Map<Id,String>();
           Map<String,String> eoiSalesManagerEmailIds = new Map<String,String>();
            List<Project_Unit__c> projUnits =  [Select Id,Name,EOI__c, RW_EOI_Block_Status__c from Project_Unit__c Where EOI__c IN : eoiMap.keySet() ];
              for(Project_Unit__c projUnit : projUnits)
              {
                  units.add(projUnit);
                  eoiUnitMap.put(projUnit.EOI__c, projUnit);
              }
              Set<Id> opportunityIds = new Set<Id>();
            Map<Id,Opportunity> opportunityEoiMap = new Map<Id,Opportunity>();
        for(RW_EOI__c eoiRec : eoiMap.values())
            {
                eoiIds.add(eoiRec.Id);
                opportunityIds.add(eoiRec.Opportunity__c);
            }
        
         List<Opportunity> oppRecList = [Select Id,RW_Project__r.Name ,RW_Sales_Associate__c, SAP_Customer_Number__c from Opportunity where Id= :opportunityIds];
        for(Opportunity opp : oppRecList)
        {
            for(RW_EOI__c eoiRec : eoiMap.values())
                {
                    if(eoiRec.Opportunity__c == opp.Id)
                    {
                     opportunityEoiMap.put(eoiRec.Id, opp);

                    }
                }
        }
        
            List<RW_EOI__c> eoiRecords = [Select Id,Name,Opportunity__r.RW_Sales_Associate__c,Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email from RW_EOI__c Where id IN:eoiIds];
            for(RW_EOI__c eoiRec : eoiRecords)
            {
                if(eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email != null)
                SiteHeadMap.put(eoiRec.Id, eoiRec.Opportunity__r.RW_Project__r.Sales_Site_Head__r.Email);
                if(eoiRec.Opportunity__r.RW_Sales_Associate__c != null)
                {
                 eoiSalesManagerSet.add(eoiRec.Opportunity__r.RW_Sales_Associate__c);
                eoiSalesManagerMap.put(eoiRec.Id,eoiRec.Opportunity__r.RW_Sales_Associate__c);
                }
            }
        
            List<User> userRec = [Select id,Name,Email from User Where Name IN:eoiSalesManagerSet];
            if(userRec != null && userRec.size() >0)
            {
                for(User u : userRec)
                eoiSalesManagerEmailIds.put(u.Name,u.Email);
            }
        
            EmailTemplate internaltemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Block'];
            EmailTemplate customertemplate = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='EOI_Block_Customer'];
            List<Messaging.SingleEmailMessage> customermessages = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> internalmessages = new List<Messaging.SingleEmailMessage>();
            for(RW_EOI__c eoiRec : eoiMap.values())
            {
            String customerhtmlBody = customertemplate.HtmlValue; 
            customerhtmlBody = customerhtmlBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);
            customerhtmlBody = customerhtmlBody.replace('{!UnitNumber}', eoiUnitMap.get(eoiRec.Id).Name);
            customerhtmlBody = customerhtmlBody.replace('{!EOIAckDate}', String.valueOf(eoiRec.RW_EOI_Acknowledgement_Sent_Date_Time__c));
            map<string, Sales_Manager_Cont__c> mapOfCustomSetting = Sales_Manager_Cont__c.getAll();
             System.debug('block number'+mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c));
            if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            {
                customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
                System.debug('inside phone check');
            }
                else
                {
            customerhtmlBody = customerhtmlBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
                    System.debug('inside phone check1');
                }
                String customerTextBody = customertemplate.Body; 
            customerTextBody = customerTextBody.replace('{!CustomerName}', eoiRec.RW_Primary_First_Name__c+' '+eoiRec.RW_Primary_Last_Name__c);  
            customerTextBody = customerTextBody.replace('{!UnitNumber}', eoiUnitMap.get(eoiRec.Id).Name);
            customerTextBody = customerTextBody.replace('{!EOIAckDate}', String.valueOf(eoiRec.RW_EOI_Acknowledgement_Sent_Date_Time__c));
             System.debug('block number'+mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c));
                if(mapOfCustomSetting!=null && mapOfCustomSetting.size()>0 && mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c)!=null)
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', string.valueOf(mapOfCustomSetting.get(opportunityEoiMap.get(eoiRec.Id).RW_Sales_Associate__c).RW_Phone__c));	
            else
            customerTextBody = customerTextBody.replace('{!SMPhoneNumber}', 'xxxxxxxxxx'); 
            
            Messaging.SingleEmailMessage custmessage = new Messaging.SingleEmailMessage();
            custmessage.toAddresses = new String[] {eoiRec.RW_Primary_Email__c};
            custmessage.subject = customertemplate.Subject;
            custmessage.setTemplateId(customertemplate.Id);
            //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
            custmessage.setHtmlBody(customerhtmlBody); 
            custmessage.setPlainTextBody(customerTextBody);
            custmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            customermessages.add(custmessage);
                
            
           //-------------------------
           
           String internalhtmlBody = internaltemplate.HtmlValue; 
            internalhtmlBody = internalhtmlBody.replace('{!EOIName}', eoiRec.Name);
            internalhtmlBody = internalhtmlBody.replace('{!UnitNumber}', eoiUnitMap.get(eoiRec.Id).Name);
            //internalhtmlBody = internalhtmlBody.replace('{!EOIAckDate}', String.valueOf(eoiRec.RW_EOI_Acknowledgement_Sent_Date_Time__c));
            String internalTextBody = internaltemplate.Body; 
            internalTextBody = internalTextBody.replace('{!EOIName}', eoiRec.Name);  
            internalTextBody = internalTextBody.replace('{!UnitNumber}', eoiUnitMap.get(eoiRec.Id).Name);
            //internalTextBody = internalTextBody.replace('{!EOIAckDate}', String.valueOf(eoiRec.RW_EOI_Acknowledgement_Sent_Date_Time__c));
            
            List<String> toAddress = new List<String>();
            if(SiteHeadMap.containsKey(eoiRec.Id) && SiteHeadMap.get(eoiRec.Id) != null)
            toAddress.add(SiteHeadMap.get(eoiRec.Id));
            if(eoiSalesManagerMap.containsKey(eoiRec.Id) && eoiSalesManagerEmailIds.containsKey(eoiSalesManagerMap.get(eoiRec.Id)))
            {
                toAddress.add(eoiSalesManagerEmailIds.get(eoiSalesManagerMap.get(eoiRec.Id)));
            }
                
            if(toAddress.size() >0)
            {
            Messaging.SingleEmailMessage intmessage = new Messaging.SingleEmailMessage();
            intmessage.toAddresses = toAddress;
            intmessage.subject = internaltemplate.Subject;
            intmessage.setTemplateId(internaltemplate.Id);
            //emailBody +='Dear Team,<br/><br/> '+emailBody + '<br/><br/>'+ 'Thanks,'+'<br/> </br> Runwal Team';
            intmessage.setHtmlBody(internalhtmlBody); 
            intmessage.setPlainTextBody(internalTextBody);
            intmessage.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            internalmessages.add(intmessage);
            }   
                
    }
        Messaging.sendEmail(customermessages);
        Messaging.sendEmail(internalmessages);
    }
}