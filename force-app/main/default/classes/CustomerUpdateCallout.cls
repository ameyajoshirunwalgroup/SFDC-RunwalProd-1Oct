public class CustomerUpdateCallout{
	public static List<ERP_Integration_Log__c> erpLogList = new List<ERP_Integration_Log__c>();
    @future (callout=true)
    public static void afterUpdateApplicant(Set<Id> oIdSet){
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
        
		List<Opportunity> oList  = [Select Id,SAP_Customer_Number__c,Booking__c,RW_Sourcing_Manager__c,RW_Sourcing_Head__c,RW_Sales_Associate__c,Sales_Manager_User__c,Sales_Manager_User__r.Name,RW_Closing_Head__c,Walkin_Source__c,SalesOrder_Number__c, RW_Project_Unit__c,  RW_Project_Unit__r.TowerName__c, RW_Project_Unit__r.TowerName__r.SAP_Plant_Code__c,RW_Project__r.SAPMaterial_Code__c, RW_Project_Unit__r.Unit_SAP_Code__c, RW_Project__c, RW_Project_Unit__r.Booking__c,Sourcing_Manager_User__c,Sourcing_Manager_User__r.Name  from Opportunity where Id IN: oIdSet]; //Added Sourcing_Manager_User__c, Sourcing_Manager_User__r.Name,Sales_Manager_User__c,Sales_Manager_User__r.Name by Vinay 04-12-2025      
        {
            for(Opportunity opp : oList){
                opportunityMap.put(opp.Id,opp);
                projectIds.add(opp.RW_Project__c);
                towerIds.add(opp.RW_Project_Unit__r.TowerName__c);
                projUnitIds.add(opp.RW_Project_Unit__c);
                 //System.debug('*inside opportunity for*'+opportunityMap +'**'+projectIds+'**'+'**'+towerIds+'**'+projUnitIds);
            }
        }
        
        for(Id oppId : opportunityMap.keyset()){
            if(opportunityMap.get(oppId).RW_Project__c == null){
                 dataErrorMap.put(oppId,'Project Data Issue,');
            }
            
            if(opportunityMap.get(oppId).RW_Project__c != null && opportunityMap.get(oppId).RW_Project__r.SAPMaterial_Code__c == null){
                 if(dataErrorMap.get(oppId) == null)
                 dataErrorMap.put(oppId,'SAP Project Code not present');
                 else
                 dataErrorMap.put(oppId,dataErrorMap.get(oppId)+',SAP Project Code not present');   
            }
            
            if(opportunityMap.get(oppId).RW_Project_Unit__c != null && opportunityMap.get(oppId).RW_Project_Unit__r.TowerName__c == null){
                 if(dataErrorMap.get(oppId) == null)
                 dataErrorMap.put(oppId,'Tower Data Issue');
                 else
                 dataErrorMap.put(oppId,dataErrorMap.get(oppId)+',Tower Data Issue');   
            }
            
            if(opportunityMap.get(oppId).RW_Project_Unit__c != null && opportunityMap.get(oppId).RW_Project_Unit__r.TowerName__c != null && opportunityMap.get(oppId).RW_Project_Unit__r.TowerName__r.SAP_Plant_Code__c == null){
                 if(dataErrorMap.get(oppId) == null)
                 dataErrorMap.put(oppId,'SAP Tower Code not present');
                 else
                 dataErrorMap.put(oppId,dataErrorMap.get(oppId)+',SAP Tower Code not present');   
            }

             if(opportunityMap.get(oppId). RW_Project_Unit__c == null){
                 if(dataErrorMap.get(oppId) == null)
                 dataErrorMap.put(oppId,'Unit not present');
                 else
                 dataErrorMap.put(oppId,dataErrorMap.get(oppId)+',Unit not present');   
            }
            
			 if(opportunityMap.get(oppId). RW_Project_Unit__c != null && opportunityMap.get(oppId). RW_Project_Unit__r.Unit_SAP_Code__c == null){
                 if(dataErrorMap.get(oppId) == null)
                 dataErrorMap.put(oppId,'SAP Material Code not present in the unit');
                 else
                 dataErrorMap.put(oppId,dataErrorMap.get(oppId)+',SAP Material Code not present in the unit');   
            }
            
        }
        
        List<Project__c> pRec = [Select Id,Name,SAPMaterial_Code__c,Sales_District__c,Project_Property_Type__c,allotment_charges_1__c,allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c from Project__c where Id = : projectIds];
        for(Opportunity opp : oList){
            for(Project__c projRec : pRec){
                if(opp.RW_Project__c == projRec.Id){  
                    opportunityProjectMap.put(opp.Id,projRec);
                }
            }
        }
         List<Tower__c> tRec = [Select Id,Name,Property_Type__c,SAP_Plant_Code__c from Tower__c where Id = : towerIds];

        for(Opportunity opp : oList){
            for(Tower__c tow : tRec){
                if(opp.RW_Project_Unit__r.TowerName__c == tow.Id){
                    opportunityTowerMap.put(opp.Id,tow);
                }
            }
        }
        
        List<Project_Unit__c> projUnit = [Select Id,Name,Unit_SAP_Code__c,Saleable_Area__c,Carpet_area__c from Project_Unit__c where Id = : projUnitIds];
        for(Opportunity opp : oList){
            for(Project_Unit__c projUt : projUnit){
                if(opp.RW_Project_Unit__c == projUt.Id){
                    opportunityProjectUnitMap.put(opp.Id,projUt);
                }
            }
        }
        /*List<Project__c> pRec = [Select Id, Name,SAPMaterial_Code__c, Sales_District__c, Project_Property_Type__c,allotment_charges_1__c, allotment_charges_2__c,allotment_charges_3__c,allotment_charges_4__c,allotment_charges_5__c,allotment_charges_6__c from Project__c where Id = : projectIds];
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


        
        
       List<Tower__c> tRec = [Select Id, Name,Property_Type__c, SAP_Plant_Code__c  from Tower__c where Id = : towerIds];

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
         
        } 
*/
        // List<RW_EOI__c> eoiRecForEmailNotifications = new List<RW_EOI__c>();
        List<Opportunity> oppRecs = new List<Opportunity>(); 
   
        for(Opportunity opp : oList){
            if(!dataErrorMap.containsKey(opp.id)){
               createCustomer(opp,opportunityProjectMap.get(opp.Id), opportunityTowerMap.get(opp.Id),opportunityProjectUnitMap.get(opp.Id));
                //createCustomer(opp);
            }else{
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                log.API_name__c = 'Customer Creation';
                if(opp.id != null){
                    log.Opportunity__c = opp.id;
                }
                log.Status__c = 'Not Processed';
                log.Error_Reason__c = dataErrorMap.get(opp.id);
                erpLogList.add(log);
            }
        }
        if(erpLogList.size() > 0){
            insert erpLogList;
        }
    }
    
    public static String createCustomer(Opportunity opp,Project__c pRec,Tower__c tRec, Project_Unit__c uList){
        //System.debug('*entered cc*'+opp+'**'+);
        String customerNumber;
        Boolean dataError = false;
        Id bookingId;
        Id oppId = opp.Id;
        Id unitId;
        Id quoteId;
        List<Booking__c>  bList  = new List<Booking__c>();
        List<Quotation__c>  qList  = new List<Quotation__c>();
        //List<Project_Unit__c>   uList = new List<Project_Unit__c>();
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Map<String, Applicant_Details__c> appMap = new Map<String, Applicant_Details__c>();
        String errMsg ='';
        // Added RW_Project_Unit__r.Booking__c by Tejaswini in the query
        bookingId = opp.Booking__c;
        bList = [Select Id,Brokerage__c	,Funding_Status__c, Booking_Date__c, Source_Of_Booking__c, Name,RW_Last_SDR_Received__c,
                 RW_Registration_Date__c,RW_BRL_Number__c,RW_Release_of_Charge_issue_status__c,RW_ROC_Date__c,RW_Signed_Agreement_to_Customer_Date__c,
                 RW_Actual_Possession_Date__c,RW_Agreement_Possession_Date__c	,Date_for_offer_of_Possession__c,
                 RW_Nominee_Name__c	,Date_of_Occupation_Certificate__c	,Date_of_Cancellation__c,RW_Key_handover_date__c,Customer_Category_Type__c
                 from Booking__c where Id = : bookingId];
        if(bookingId != null) {
            appList = [Select Id, Mailing_Address_Line_1__c,Mailing_Address_Line_2__c,Mailing_Address_Line_3__c,Mailing_State__c,Mailing_City__c,
                       Mailing_Pincode__c,Mailing_Country__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,City__c,
                       State__c,Pincode__c,Country__c,Email_Address__c,Mobile_Number__c,Office_Address_Line_1__c,Office_Address_Line_2__c,
                       Office_Address_Line_3__c,Organisation_Pincode__c,Organisation_Country__c,PancardNo__c,Address_Proof_Number__c,Address_Proof_Document__c,
                       Type_Of_Applicant__c,Subtype_Of_Applicant__c,Salutation__c,Name,Organization_Name__c,DOB__c,Nationality__c,
                       Landline_Number__c,Applicant_Number__c,gender__c,Marital_Status__c,Designation_picklist__c,Nationality_picklist__c,
                       Contact_Person_Relationship__c,First_Name__c,Middle_Name__c,Last_Name__c,Occupation__c,
                       Designation__c,PassportNoDetails__c,LastModifiedDate from Applicant_Details__c where Booking__c = :bookingId and Applicant_Status__c != 'Inactive'];
            Integer primaryCount = 0;
            Map<String, Applicant_Details__c> aMap = new Map<String, Applicant_Details__c>();
            for(Applicant_Details__c a : appList){
                aMap.put(a.Applicant_Number__c, a);
                //appMap.put(a.Applicant_Number__c, a);
                if(a.Applicant_Number__c == 'Primary Applicant'){ //Added by coServe 08-12-2023
                    primaryCount += 1;
                }   
            }
            //Added by coServe 08-12-2023
            if(primaryCount > 1){ 
                Applicant_Details__c app = [Select Id, Mailing_Address_Line_1__c, Mailing_Address_Line_2__c, Mailing_Address_Line_3__c, Mailing_State__c,Mailing_City__c,Mailing_Pincode__c,Mailing_Country__c, Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,City__c,State__c,Pincode__c,Country__c,Email_Address__c,Mobile_Number__c,Office_Address_Line_1__c,Office_Address_Line_2__c,Office_Address_Line_3__c,Organisation_Pincode__c,Organisation_Country__c,PancardNo__c,Address_Proof_Number__c,Address_Proof_Document__c,Type_Of_Applicant__c,Subtype_Of_Applicant__c,Salutation__c,Name,Organization_Name__c,DOB__c,Nationality__c,Landline_Number__c,Applicant_Number__c,gender__c,Marital_Status__c,Designation_picklist__c,Nationality_picklist__c,Contact_Person_Relationship__c,First_Name__c,Middle_Name__c,Last_Name__c,Occupation__c,Designation__c,PassportNoDetails__c from Applicant_Details__c where Booking__c = :bookingId and Applicant_Status__c != 'Inactive' and Applicant_Number__c = 'Primary Applicant' order by LastModifiedDate desc limit 1];
                appMap.put(app.Applicant_Number__c, app);
            }else{
                appMap = aMap;
            }
            
        }
            
        
        // if data error , dont call API, log the error and exit.
         
      
        CustomerCreation.ZsdSfdcCustomerHd customerHeader = new CustomerCreation.ZsdSfdcCustomerHd();
        if(opp.SAP_Customer_Number__c != null){
            customerHeader.Kunnr =  opp.SAP_Customer_Number__c;
        }  
        customerHeader.Vkorg = pRec.SAPMaterial_Code__c;
        customerHeader.Werks = tRec.SAP_Plant_Code__c;
        //customerHeader.Vtweg = pRec.Project_Property_Type__c;
        customerHeader.Vtweg = tRec.Property_Type__c;
        customerHeader.Spart = '00';
        //customerHeader.Ktokd = pRec.Project_Property_Type__c;
        customerHeader.Ktokd = tRec.Property_Type__c;
        customerHeader.Title = appMap.get('Primary Applicant').Salutation__c;
        customerHeader.NameFirst  = appMap.get('Primary Applicant').First_Name__c;
        customerHeader.NameMiddle = appMap.get('Primary Applicant').Middle_Name__c;
        customerHeader.NameLast = appMap.get('Primary Applicant').Last_Name__c;
        customerHeader.Langucorr = 'E';
        customerHeader.Sort1 = uList.Unit_SAP_Code__c;
        customerHeader.Sort2 = oppid;
        if(String.isNotBlank(appMap.get('Primary Applicant').gender__c) && appMap.get('Primary Applicant').gender__c.equalsIgnoreCase('Male'))
            customerHeader.Xsexf = 'M';
        else if( String.isNotBlank(appMap.get('Primary Applicant').gender__c) && appMap.get('Primary Applicant').gender__c.equalsIgnoreCase('Female') )
            customerHeader.Xsexf = 'F';
        else
            customerHeader.Xsexf = 'O';
        
        // to do get list from SAP and update the picklist in Salesforce
        customerHeader.Marst = appMap.get('Primary Applicant').Marital_Status__c;
        customerHeader.Natio = appMap.get('Primary Applicant').Nationality_Picklist__c;
        customerHeader.Jobgr = appMap.get('Primary Applicant').Occupation__c;
        customerHeader.StaffGrp = appMap.get('Primary Applicant').Designation__c;
        customerHeader.bzirk= pRec.Sales_District__c; 
        if(('Indian National').equalsIgnoreCase(appMap.get('Primary Applicant').Subtype_Of_Applicant__c))
            customerHeader.kukla = 'Resident Indian';
        else if(('Foreign Nationals Of Indian Origin').equalsIgnoreCase (appMap.get('Primary Applicant').Subtype_Of_Applicant__c ))
            customerHeader.kukla = 'PIO';
        else if(('For NRI').equalsIgnoreCase(appMap.get('Primary Applicant').Subtype_Of_Applicant__c))
            customerHeader.kukla = 'NRI';
        else if(('For Company').equalsIgnoreCase(appMap.get('Primary Applicant').Subtype_Of_Applicant__c ))
            customerHeader.kukla = 'Company';
        else if(('For Company').equalsIgnoreCase(appMap.get('Primary Applicant').Subtype_Of_Applicant__c))
            customerHeader.kukla = 'Company';
        else if(('Partnership Firm').equalsIgnoreCase(appMap.get('Primary Applicant').Subtype_Of_Applicant__c))
            customerHeader.kukla = 'Partnership Firm';
        
        // these need to mapped in SAP based on SFDC data
        if(String.isNotBlank(opp.Sourcing_Manager_User__c)) // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__c by Vinay 04-12-2025
            customerHeader.Kvgr1 = opp.Sourcing_Manager_User__r.Name;  // Replaced RW_Sourcing_Manager__c with Sourcing_Manager_User__r.Name by Vinay 04-12-2025
        if(String.isNotBlank(opp.RW_Sourcing_Head__c))
            customerHeader.Kvgr2 = opp.RW_Sourcing_Head__c;
        if(String.isNotBlank(opp.Sales_Manager_User__c)) // Replaced RW_Sales_Associate__c with Sales_Manager_User__c by Vinay 04-12-2025
            customerHeader.Kvgr3 = opp.Sales_Manager_User__r.Name; // Replaced RW_Sales_Associate__c with Sales_Manager_User__r.Name by Vinay 04-12-2025
        if(String.isNotBlank(opp.RW_Closing_Head__c))
            customerHeader.Kvgr4 = opp.RW_Closing_Head__c;
        if(String.isNotBlank(opp.Walkin_Source__c))
            customerHeader.Kvgr5 = opp.Walkin_Source__c;
        customerHeader.Addrcode = '01';
        
        // to ends here
        
        if(appMap.get('Primary Applicant').DOB__c != null){
            Date DOB = appMap.get('Primary Applicant').DOB__c;
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
        customerHeader.Katr1 = bList[0].Source_of_Booking__c;
        //Added by coServe 29-06-2022 Start
        if(bList[0].Customer_Category_Type__c == 'Management Bookings')
            customerHeader.Bran1 = '0002';
        if(bList[0].Customer_Category_Type__c == 'Barter Deal Customer')
            customerHeader.Bran1 = '0003';
        if(bList[0].Customer_Category_Type__c == 'Legal Case')
            customerHeader.Bran1 = '0004';
        if(bList[0].Customer_Category_Type__c == 'CIP-Canc. in Process')
            customerHeader.Bran1 = '0005';
        if(bList[0].Customer_Category_Type__c == 'Regular')
            customerHeader.Bran1 = '0006';
        //Added by coServe 29-06-2022 End
        if(String.isNotBlank(appMap.get('Primary Applicant').Organization_Name__c))
            customerHeader.Emplo = appMap.get('Primary Applicant').Organization_Name__c;
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
        // Mandatory for Indian National, NRI , Company and Partnership firm
        if(String.isNotBlank(appMap.get('Primary Applicant').PancardNo__c) ) {
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem1 = new CustomerCreation.ZsdSfdcCustomerTax();
            taxLineitem1.Ind = 'M';
            taxLineitem1.Taxtype = 'IN6';
            taxLineitem1.Taxnumxl = appMap.get('Primary Applicant').PancardNo__c;
            customerTaxList.item.add(taxLineItem1);
        }
        // In case of Indian National we collect address proof documents in form or Aadhar, Passport, Driving License, Electricity Bill or Voters card.
        // In case of company we dont collect anything other than pan card, so that already addressed above.
        if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Aadhar Card')) {
            CustomerCreation.ZsdSfdcCustomerTax taxLineitem2 = new CustomerCreation.ZsdSfdcCustomerTax();
            taxLineitem2.Ind = 'M';
            taxLineitem2.Taxtype = 'IN5';
            taxLineitem2.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
            customerTaxList.item.add(taxLineItem2);
        }
        CustomerCreation.ZsdSfdcCustomerTax taxLineitem3 = new CustomerCreation.ZsdSfdcCustomerTax();
        if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Driving License')) {
            taxLineitem3.Ind = 'M';
            taxLineitem3.Taxtype = 'IN7';
            taxLineitem3.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
            customerTaxList.item.add(taxLineitem3);
        }
        CustomerCreation.ZsdSfdcCustomerTax taxLineitem4 = new CustomerCreation.ZsdSfdcCustomerTax();
        if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Passport')) {
            taxLineitem4.Ind = 'M';
            taxLineitem4.Taxtype = 'IN4';
            taxLineitem4.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
            customerTaxList.item.add(taxLineitem4);
        }
        CustomerCreation.ZsdSfdcCustomerTax taxLineitem6 = new CustomerCreation.ZsdSfdcCustomerTax();
        if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Electricity Bill')) {
            taxLineitem6.Ind = 'M';
            taxLineitem6.Taxtype = 'IN9';
            taxLineitem6.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
            customerTaxList.item.add(taxLineitem6);
        }
        CustomerCreation.ZsdSfdcCustomerTax taxLineitem7 = new CustomerCreation.ZsdSfdcCustomerTax();
        if(String.isNotBlank(appMap.get('Primary Applicant').Address_Proof_Document__c) && appMap.get('Primary Applicant').Address_Proof_Document__c.equalsIgnoreCase('Voter\'s  ID Card')) {
            taxLineitem7.Ind = 'M';
            taxLineitem7.Taxtype = 'IN8';
            taxLineitem7.Taxnumxl = appMap.get('Primary Applicant').Address_Proof_Number__c;
            customerTaxList.item.add(taxLineitem7);
        }
        
        // In case of NRI we collect passport #, but doesn't get categorised as address proof document
        CustomerCreation.ZsdSfdcCustomerTax taxLineitem5 = new CustomerCreation.ZsdSfdcCustomerTax();
        if(String.isNotBlank(appMap.get('Primary Applicant').PassportNoDetails__c)) {
            taxLineitem5.Ind = 'M';
            taxLineitem5.Taxtype = 'IN4';
            taxLineitem5.Taxnumxl = appMap.get('Primary Applicant').PassportNoDetails__c;
            customerTaxList.item.add(taxLineitem5);
        }
        
        
        
        // Mailing, Permanent and Office address of primary applicant
        CustomerCreation.TableOfZsdSfdcCustomerAddress customerAddressList = new CustomerCreation.TableOfZsdSfdcCustomerAddress();
        customerAddressList.item = new List<CustomerCreation.ZsdSfdcCustomerAddress>();
        
        CustomerCreation.ZsdSfdcCustomerAddress mailingAddressItem = new CustomerCreation.ZsdSfdcCustomerAddress();
        mailingAddressItem.Addrcode = '01';
        mailingAddressItem.Street = appMap.get('Primary Applicant').Mailing_Address_Line_1__c;
        mailingAddressItem.StrSuppl1 =  appMap.get('Primary Applicant').Mailing_Address_Line_2__c;
        mailingAddressItem.StrSuppl2 =  appMap.get('Primary Applicant').Mailing_Address_Line_3__c;
        mailingAddressItem.PostCode = String.valueOf(appMap.get('Primary Applicant').Mailing_Pincode__c);
        mailingAddressItem.City = appMap.get('Primary Applicant').Mailing_City__c;
        mailingAddressItem.Country = appMap.get('Primary Applicant').Mailing_Country__c;
        // to do check with SAP
        mailingAddressItem.Region  = appMap.get('Primary Applicant').Mailing_State__c;
        customerAddressList.item.add(mailingAddressItem);
        
        // permanent address
        CustomerCreation.ZsdSfdcCustomerAddress permanentAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
        permanentAddress.Addrcode = '02';
        permanentAddress.Street = appMap.get('Primary Applicant').permanent_Address_Line_1__c;
        permanentAddress.StrSuppl1 =  appMap.get('Primary Applicant').permanent_Address_Line_2__c;
        permanentAddress.StrSuppl2 =  appMap.get('Primary Applicant').permanent_Address_Line_3__c;
        permanentAddress.PostCode = String.valueOf(appMap.get('Primary Applicant').Pincode__c);
        permanentAddress.City = appMap.get('Primary Applicant').City__c;
        permanentAddress.Country = appMap.get('Primary Applicant').Country__c;
        // to do check with SAP
        permanentAddress.Region  = appMap.get('Primary Applicant').State__c;
        customerAddressList.item.add(permanentAddress);
        
        // office address
        /*    if(String.isNotBlank(appMap.get('Primary Applicant').Office_Address_Line_1__c) ) {
CustomerCreation.ZsdSfdcCustomerAddress officeAddress = new CustomerCreation.ZsdSfdcCustomerAddress();
officeAddress.Addrcode = '03';
officeAddress.Street = appMap.get('Primary Applicant').Office_Address_Line_1__c;
officeAddress.StrSuppl1 =  appMap.get('Primary Applicant').Office_Address_Line_2__c;
officeAddress.StrSuppl2 =  appMap.get('Primary Applicant').Office_Address_Line_3__c;
officeAddress.PostCode = String.valueOf(appMap.get('Primary Applicant').Organisation_Pincode__c);
officeAddress.Country = appMap.get('Primary Applicant').Organisation_Country__c;
// to do check with SAP
customerAddressList.item.add(officeAddress);
}*/
        
        Integer SeqNo = 10;
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
                
                if(appMap.get(appNumber).DOB__c != null){
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
        // phone and email of permanent applicant 
        CustomerCreation.TableOfZsdSfdcCustomerComm  commList = new CustomerCreation.TableOfZsdSfdcCustomerComm();
        commList.Item = new List<CustomerCreation.ZsdSfdcCustomerComm>();
        CustomerCreation.ZsdSfdcCustomerComm commItem1 = new CustomerCreation.ZsdSfdcCustomerComm();
        commItem1.Addrcode = '01';
        commItem1.MobileNo  = appMap.get('Primary Applicant').Mobile_Number__c;
        commItem1.SmtpAddr =  appMap.get('Primary Applicant').Email_Address__c;
        commList.item.add(commItem1);
        
        // logger data population
        // Manoj:03-01-2021:Moving to new loggger logic where will will log the request as is without cleanup
        CustomerCreationErrorLogger cLog = new CustomerCreationErrorLogger();
        cLog.customerHeader = customerHeader;
        cLog.customerTaxList = customerTaxList;
        cLog.customerAddressList =customerAddressList;
        cLog.coAppList = coAppList;
        cLog.commList = commList;
        /*CustomerCreationLogger.ZsdSfdcCustomerHd chl = new  CustomerCreationLogger.ZsdSfdcCustomerHd();
chl.kunnr = customerHeader.kunnr;
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
*/
        /*      CustomerCreationLogger.TableOfZsdsBpContact  coAppLogList = new CustomerCreationLogger.TableOfZsdsBpContact();
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
        try{
            CustomerCreation.ZSD_SFDC_CUSTOMER customerCreation = new CustomerCreation.ZSD_SFDC_CUSTOMER();
            system.debug(JSON.serialize(customerAddressList));
            system.debug(JSON.serialize(commList));
            system.debug(JSON.serialize(coAppList));
            system.debug(JSON.serialize(customerHeader));
            system.debug(JSON.serialize(customerTaxList));
            CustomerCreation.ZsdSfdcCustomerResponse_element customerCreationResponse = customerCreation.ZsdSfdcCustomer(customerAddressList,commList, coAppList,customerHeader,customerTaxList, bapiRet2List);
            if(customerCreationResponse != null && customerCreationResponse.Return_x != null && customerCreationResponse.Return_x.item != null ){
                for(CustomerCreation.Bapiret2 returnMsg :  customerCreationResponse.Return_x.item){
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
            }else{
                callOutError = true;
                exceptionMsg = 'Customer number # not received';
            }
        }catch (Exception ex){
            callOutError = true;
            ExceptionError = true;
            exceptionMsg = ex.getMessage();
        }finally{
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            String requestF = JSON.SerializePretty(cLog);
            //    requestF =  requestF.replaceAll('\n','<br/>');
            //  requestF  = requestF.replaceAll('\t', '&nbsp;');
            log.request__c = requestF;
            log.API_name__c = 'Customer Creation/Update';
            log.Booking__c = bookingId;
            log.Opportunity__c = oppId;
            String responseF = JSON.SerializePretty(responseLog);
            responseF =  responseF.replaceAll('\n','<br/>');
            responseF  = responseF.replaceAll('\t', '&nbsp;');
            log.response__c = responseF;
            if(!callOutError){
                log.Status__c = 'Success';
            }else{
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
        return customerNumber;
    }
    
}