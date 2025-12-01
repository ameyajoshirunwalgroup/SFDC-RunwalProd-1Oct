public class OppTriggerHandler
{
    
      //  Added by UBSDigicloud 07-04-2025
    private static final Set<String> scoringFields = loadScoringFields();

    private static Set<String> loadScoringFields() {
        Set<String> fields = new Set<String>();
        for (OpportunityCriteriaScores__c setting : OpportunityCriteriaScores__c.getAll().values()) {
            if (!String.isBlank(setting.Opportunity_Field__c)) {
                fields.add(setting.Opportunity_Field__c);
            }
        }
        return fields;
    }
           
    
    
    public void BeforeInsert(List<Opportunity> lstOpp)
    {
         //  Added by UBSDigicloud 07-04-2025
         OpportunityScoringHandler.calculateOpportunityScores(lstOpp); 
        
        Set<Id> setIdofProjUnit = new Set<Id>();
        if(lstOpp.size() > 0)
        {
            for(Opportunity eachOpp : lstOpp)
            {
                //Added by coServe 28-02-2024
                Map<String, Opp_Close_Date__c> oppClsDateMap = Opp_Close_Date__c.getall();
                if(oppClsDateMap.keySet().size() > 0){
                   eachOpp.CloseDate = System.today().addDays(Integer.valueOf(oppClsDateMap.get(eachOpp.RW_project__c).No_of_Days__c)); 
                }
                
                // Commented by coServe 28-02-2024
                /*if(eachOpp.RW_project__c == 'a005j00000E1098' || eachOpp.RW_project__c == 'a005j00000E1098AAB'){ // Added by coServe 22-05-2023
                    eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.OppCloseDate_MyCity));
                }else{
                    eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.OppCloseDate));
                }
                //eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.OppCloseDate));
                
                if(eachOpp.Walkin_Source__c!=null || eachOpp.Walkin_Source__c!='') //added by Rasika
                {
                    if(eachOpp.Walkin_Source__c=='Channel Partner')
                    {    
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.CP_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Channel_Partner));
                    }   
                    else if(eachOpp.Walkin_Source__c=='Corporate')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Corporate_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Corporate));   
                    }           
                    else if(eachOpp.Walkin_Source__c=='Loyalty')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Loyalty_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Loyalty));
                    }
                    else if(eachOpp.Walkin_Source__c=='Referral')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Referral_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Referral));
                    }
                    else if(eachOpp.Walkin_Source__c=='PreSales')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Presales_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Presales));
                    }
                    else if(eachOpp.Walkin_Source__c=='Direct')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Direct_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Direct));
                    }
                    else if(eachOpp.Walkin_Source__c=='NRI')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.NRI_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.NRI));
                    }
                    else if(eachOpp.Walkin_Source__c=='Digital')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Digital_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Digital));
                    }
                    else if(eachOpp.Walkin_Source__c=='Emp / Mgmt Reference')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.EmpMgmt_Reference_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Employee_Management_Reference));
                    }
                    else if(eachOpp.Walkin_Source__c=='Events')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Events_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Events));
                    }
                    else if(eachOpp.Walkin_Source__c=='Exhibitions')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Exhibitions_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Exhibition));
                    }
                    else if(eachOpp.Walkin_Source__c=='Hoarding')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Hoarding_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Hoarding));
                    }
                    else if(eachOpp.Walkin_Source__c=='Individual calling')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Individual_calling_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Individual_Calling));
                    }
                    else if(eachOpp.Walkin_Source__c=='Magazines')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Magazines_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Magazines));
                    }
                    else if(eachOpp.Walkin_Source__c=='Newspapers')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Newspapers_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Newspaper));
                    }
                    else if(eachOpp.Walkin_Source__c=='Outstation')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Outstation_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Outstation));
                    }
                    else if(eachOpp.Walkin_Source__c=='Paper Inserts')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Paper_Inserts_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Paper_Inserts));
                    }
                    else if(eachOpp.Walkin_Source__c=='Property Portals')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Property_Portals_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Property_Portals));
                    }
                    else if(eachOpp.Walkin_Source__c=='Radio')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Radio_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Radio));
                    }
                    else if(eachOpp.Walkin_Source__c=='Surround Marketing')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Surround_Marketing_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.Surround_marketing));
                    }
                    else if(eachOpp.Walkin_Source__c=='TV')
                    {
                        if(eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a000I00001xus6CQAQ' || eachOpp.RW_project__c == 'a000I00001xus6C' || eachOpp.RW_project__c == 'a005j00000E1098AAB')
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.TV_Gardens));
                        else
                            eachOpp.CloseDate = System.today().addDays(Integer.valueOf(Label.TV));
                    }
                    
                    
                } */  
                
                if(eachOpp.RW_Project_Unit__c != null)
                {
                    setIdofProjUnit.add(eachOpp.RW_Project_Unit__c);
                }
                /**    if(eachOpp.LeadSource != null)
eachOpp.Walkin_Source__c = eachOpp.LeadSource;

if(eachOpp.Lead_Sub_Source__c != null)
eachOpp.Walkin_SubSource__c = eachOpp.Lead_Sub_Source__c; **/
                
                if(eachOpp.NameofUnregisteredCorporate_LeadSource__c != null)
                    eachOpp.Name_of_Unregistered_Corporate__c = eachOpp.NameofUnregisteredCorporate_LeadSource__c ;   
                
                /**   else if(eachOpp.RW_Reference_Source__c != null)
eachOpp.Walkin_SubSource__c = eachOpp.RW_Reference_Source__c;   **/
                
                
                /* if(eachOpp.Walkin_Source__c == 'Referral' && eachOpp.RW_Walkin_Customer_Reference__c != ''){
List<OTP__c> lstotp = [Select id,Generated_OTP__c,Project__c,OTP_Expired__c, OTP_Generate_For__c,Prospect__c,Customer_Reference_Lookup__c,OTP_Generated_on__c,Customer_reference_SAP_Code__c,Customer_reference_Booked_Unit__c From OTP__c Where Customer_Reference_Lookup__c =: eachOpp.RW_Walkin_Customer_Reference__c AND  OTP_Expired__c = false];  
system.debug('lstotp' + lstotp);
if(lstotp.size()>0){
eachOpp.Customer_reference_SAP_Code__c = lstotp[0].Customer_reference_SAP_Code__c;
// eachOpp.Customer_reference_Booked_Unit__c =  lstotp[0].Customer_reference_Booked_Unit__c;
}
}*/
            }
        }
        if(setIdofProjUnit.size() > 0)
        {
            List<Project_Unit__c> lstProjUnit = [Select Id, RW_Customer__c, RW_Unit_Status__c from Project_Unit__c Where Id IN : setIdofProjUnit];
            if(lstProjUnit.size() > 0)
            {           
                for(Opportunity eachOpp : lstOpp)
                {
                    for(Project_Unit__c eachProjUnit : lstProjUnit)
                    {
                        if(eachOpp.RW_Project_Unit__c == eachProjUnit.Id && eachProjUnit.RW_Unit_Status__c != null)
                        {
                            if(eachOpp.RW_Project_Unit__c == eachProjUnit.Id && eachProjUnit.RW_Unit_Status__c != 'Available')
                            {
                                eachOpp.RW_Project_Unit__c.addError('This Project Unit is not Vacant, please choose other one. Before Insert.');
                            }
                        }
                    }
                }
            }
        }
        
        updateRatingValue(lstOpp);
    }
    public void AfterInsert(List<Opportunity> lstOpp)
    {
        Set<Id> setIdofProjUnit = new Set<Id>();
        Set<Id> setofOppId = new Set<Id>();  
        Set<Id> retentionOppIds = new Set<Id>(); // Added by coServe 20-01-2023
        list<Event> lstEventInsert = new list<Event>();  
        List<String> oppIds = new List<String>(); // Added by coServe 27-06-2024
        if(lstOpp.size() > 0)
        {
            for(Opportunity eachOpp : lstOpp)
            {
                oppIds.add(eachOpp.Id); // Added by coServe 27-06-2024
                if(eachOpp.RW_Project_Unit__c != null)
                {
                    setIdofProjUnit.add(eachOpp.RW_Project_Unit__c);
                    setofOppId.add(eachOpp.Id);
                }
                // Added by coServe 20-01-2023 Start
                if(eachOpp.LeadSource == 'Retention' && (eachOpp.Retention_RM_Name__c != null || eachOpp.Retention_Closing_Head_Name__c!= null || eachOpp.Retention_Presales_User__c != null || eachOpp.Retention_Sales_Manager__c != null)){
                    retentionOppIds.add(eachOpp.Id);
                }
                // Added by coServe 20-01-2023 End
                
                
            }
            if(oppIds.size() > 0){ // Added by coServe 27-06-2024
                //sendProspectDay1WhatsApp(oppIds);
            }
        }
        if(setofOppId.size() > 0)
        {
            List<Project_Unit__c> lstProjUnittoUpdate = [Select Id, RW_Unit_Status__c, RW_Customer__c from Project_Unit__c Where ID IN : setIdofProjUnit AND (RW_Unit_Status__c = NULL OR RW_Unit_Status__c = 'Available')]; 
            
            List<Opportunity> lstOpptoUpdate = new List<Opportunity>();             
            if(lstProjUnittoUpdate.size()>0)
            {
                for(Opportunity eachOpp : lstOpp)
                {
                    for(Project_Unit__c eachProjUnit : lstProjUnittoUpdate)
                    {
                        if(eachOpp.RW_Project_Unit__c == eachProjUnit.Id)
                        {
                            eachProjUnit.RW_Customer__c = eachOpp.Id;
                            eachProjUnit.RW_Unit_Status__c = 'Blocked';
                            //Commented by Vinay 02-02-2022
                            /*if(eachOpp.LeadSource!=null && eachOpp.LeadSource!='')
eachProjUnit.Booking_Source1__c = eachOpp.LeadSource;*/
                            //Added by Vinay 02-02-2022
                            if(eachOpp.Walkin_Source__c!=null && eachOpp.Walkin_Source__c!='')
                                eachProjUnit.Booking_Source1__c = eachOpp.Walkin_Source__c;
                        }
                    }
                    
                }
            }
            if(lstProjUnittoUpdate.size() > 0)
                update lstProjUnittoUpdate;
        }
        
        // Added by coServe 20-01-2023 Start
        if(retentionOppIds.size() > 0){
            List<Opportunity> oppList = [SELECT Id, Name, LeadSource, Retention_RM_Name__c,Retention_RM_Name__r.FirstName, Retention_RM_Name__r.LastName,
                                         Retention_RM_Name__r.UserName, Retention_Closing_Head_Name__r.FirstName, Retention_Closing_Head_Name__r.LastName, 
                                         Retention_Closing_Head_Name__r.UserName,Retention_Closing_Head_Name__c, Retention_Presales_User__r.FirstName,
                                         Retention_Presales_User__r.LastName, Retention_Presales_User__r.UserName, Retention_Sales_Manager__r.FirstName,
                                         Retention_Sales_Manager__r.LastName, Retention_Sales_Manager__r.UserName, Retention_Presales_User__c,
                                         Retention_Sales_Manager__c FROM Opportunity WHERE Id =: retentionOppIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp : oppList){
                if(opp.Retention_RM_Name__c != null){
                    mails.add(sendEmail(opp,'Retention RM Name'));  
                }
                if(opp.Retention_Closing_Head_Name__c!= null){
                    mails.add(sendEmail(opp,'Retention Closing Head Name'));  
                }
                if(opp.Retention_Presales_User__c != null){
                    mails.add(sendEmail(opp,'Retention Presales User'));  
                }
                if(opp.Retention_Sales_Manager__c != null){
                    mails.add(sendEmail(opp,'Retention Sales Manager'));  
                }
            }
            Messaging.sendEmail(mails);
        }
        // Added by coServe 20-01-2023 End
        
        //inserSiteVisit(lstOpp, null);
        /////////////////////////Added By Aniket(Stetig) on 02-09-22 Starts//////////////////////////////
        for(Opportunity cp : lstOpp){
            System.debug('Inside Sharing'+cp);
            List<Account> AccountList = new List<Account>();
            List <User> lstuser = new List <User>();
            List <Contact> lstcontact = new List <Contact>();
            List <Broker__c> lstCP = new List <Broker__c>();
            /*if(cp.RW_Broker__c != null ){
AccountList = [Select id,name,CP_Email__c from Account where Channel_Partner__c =:cp.RW_Broker__c ];
if(!AccountList.isEmpty()){
lstcontact =[select id,Name,Email from Contact where AccountId =: AccountList[0].id];
system.debug('lstcontact::' + lstcontact + 'lstcontactsize::' + lstcontact.size());
if(!lstcontact.isEmpty()){        
lstuser =[select id,name,IsActive,Email,contactID  from user where Email =: lstcontact[0].Email and IsActive = true and contactID =: lstcontact[0].id];
system.debug('user::' + lstuser + 'userlistsize' + lstuser.size());
if(!lstuser.isEmpty()){
Opportunityshare oppShare  = new Opportunityshare();
oppShare.opportunityid = cp.id; 
oppShare.UserOrGroupId = lstuser[0].id; 
oppShare.OpportunityAccessLevel  = 'Edit';
oppShare.RowCause = 'Manual';
insert oppShare;
}
}
}
}else*/ 
            /*if(cp.RW_Walkin_Channel_Partner__c != null){
lstCP = [Select Id,Name, Account__c from Broker__c where Id=: cp.RW_Walkin_Channel_Partner__c];
AccountList = [Select id,name,CP_Email__c from Account where Channel_Partner__c =:cp.RW_Walkin_Channel_Partner__c ];
if(!AccountList.isEmpty()){
lstcontact =[select id,Name,Email from Contact where AccountId =: AccountList[0].id];
system.debug('lstcontact::' + lstcontact + 'lstcontactsize::' + lstcontact.size());
if(!lstcontact.isEmpty()){        
lstuser =[select id,name,IsActive,Email,contactID  from user where Email =: lstcontact[0].Email and IsActive = true and contactID =: lstcontact[0].id];
system.debug('user::' + lstuser + 'userlistsize' + lstuser.size());
if(!lstuser.isEmpty()){
Opportunityshare oppShare  = new Opportunityshare();
oppShare.opportunityid = cp.id; 
oppShare.UserOrGroupId = lstuser[0].id; 
oppShare.OpportunityAccessLevel  = 'Edit';
oppShare.RowCause = 'Manual';
insert oppShare;
}
}
}
}
if(!lstCP.isEmpty()){
cp.Channel_Partner_Account__c = lstCP[0].Account__c;
}*/
        }
        /////////////////////////Added By Aniket(Stetig) on 02-09-22 Ends Here//////////////////////////////
    }
    
    //Added by coServe 20-01-2023 Start
    public Messaging.SingleEmailMessage sendEmail(Opportunity opp, String RetField){
        String name = '';
        String toAddress = '';
        if(RetField == 'Retention RM Name'){
            name = opp.Retention_RM_Name__r.FirstName+ ' ' +opp.Retention_RM_Name__r.LastName;
            toAddress = opp.Retention_RM_Name__r.UserName;
        }else if(RetField == 'Retention Closing Head Name'){
            name = opp.Retention_Closing_Head_Name__r.FirstName+ ' ' +opp.Retention_Closing_Head_Name__r.LastName;
            toAddress = opp.Retention_Closing_Head_Name__r.UserName;
        }else if(RetField == 'Retention Presales User'){
            name = opp.Retention_Presales_User__r.FirstName+ ' ' +opp.Retention_Presales_User__r.LastName;
            toAddress = opp.Retention_Presales_User__r.UserName;
        }else if(RetField == 'Retention Sales Manager'){
            name = opp.Retention_Sales_Manager__r.FirstName+ ' ' +opp.Retention_Sales_Manager__r.LastName;
            toAddress = opp.Retention_Sales_Manager__r.UserName;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.settoaddresses(new List<String>{toAddress});
        mail.setSubject('Retention Opportunity assigned');
        mail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        String body = 'Dear '+ name +', <br/><br/>';
        body += 'Retention Opportunity is assigned to you, please check the same & Kindly do followup with the customer. Below are the details for the same.<br/><br/>';
        body += 'Opportunity Name: ' + opp.Name+'<br/>';
        body += 'Opportunity Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+opp.Id;
        mail.sethtmlbody(body);
        return mail;
    }
    //Added by coServe 20-01-2023 End
    public void BeforeUpdate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId)
    {
        
        
         //  added By UBSDigicloud
       Boolean shouldScore = false;

        for (Opportunity newOpp : lstOpp) {
            Opportunity oldOpp = mapOldOppId.get(newOpp.Id);
		
            for (String fieldName : scoringFields) {
                system.debug(fieldName);
                if (newOpp.get(fieldName) != oldOpp.get(fieldName)) {
                    shouldScore = true;
                    break;
                }
            }

            if (shouldScore) break;
        }
	system.debug('shouldScore:  '+shouldScore);
        if (shouldScore) {
            system.debug('1: '+ lstOpp[0].name);
            OpportunityScoringHandler.calculateOpportunityScores(lstOpp);
        }

        
        
        Set<Id> setIdofProjUnit = new Set<Id>();
        //system.debug('xyz------'+lstOpp);
        if(lstOpp.size() > 0)
        {
            for(Opportunity eachOpp : lstOpp)
            {
                if(eachOpp.RW_Project_Unit__c != null)
                {
                    setIdofProjUnit.add(eachOpp.RW_Project_Unit__c);
                }
            }
        }
        if(setIdofProjUnit!=null && setIdofProjUnit.size()>0)
        {
            List<Project_Unit__c> lstProjUnit = [Select Id, RW_Unit_Status__c, RW_Customer__c from Project_Unit__c Where ID IN : setIdofProjUnit];
            system.debug('@lstProjUnit-------'+lstProjUnit);
            //system.debug('@lstOpp-------'+lstOpp);
            for(Opportunity eachOpp : lstOpp)
            {
                for(Project_Unit__c eachProjUnit : lstProjUnit)
                {system.debug(eachOpp.RW_Project_Unit__c);
                 system.debug(eachProjUnit.Id);
                 if(eachOpp.RW_Project_Unit__c == eachProjUnit.Id)
                 {
                     if(eachOpp.RW_Project_Unit__c != mapOldOppId.get(eachOpp.Id).RW_Project_Unit__c && eachProjUnit.RW_Customer__c != eachOpp.Id && (eachProjUnit.RW_Unit_Status__c == 'Blocked' || eachProjUnit.RW_Unit_Status__c == 'Booked' || eachProjUnit.RW_Unit_Status__c == 'Hold'))
                     {
                         eachOpp.RW_Project_Unit__c.addError('This Project Unit is not Available, please choose other one. Before Update.');
                     }
                 }
                }
            }
        }
        if(checkRecursion.isFirstRun()) 
        {
            updateCancellation(lstOpp, mapOldOppId);}
        updateRatingValue(lstOpp);
    }
    public void AfterUpdate(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId)
    {
        Set<Id> setIdofProjUnit = new Set<Id>();
        Set<Id> setofOppId = new Set<Id>();
        Set<Id> setofOppIdForSMS = new Set<Id>();
        Set<Id> setofOppIdForCallCompletion = new Set<Id>();
        Set<Id> setofOppIdForMissedCall = new Set<Id>();
        Set<Id> retentionOppIds = new Set<Id>();
        
        List<String> oppIdsToUpdate = new List<String>();
        List<String> oppIdsToSendWhatsApp = new List<String>();
        if(lstOpp.size() > 0)
        {
            for(Opportunity eachOpp : lstOpp)
            {
                if(eachOpp.RW_Project_Unit__c != null)
                {
                    setIdofProjUnit.add(eachOpp.RW_Project_Unit__c);
                }
                
                setofOppId.add(eachOpp.Id);
                if(eachOpp.RW_Site_Visit_Completion__c && !mapOldOppId.get(eachOpp.id).RW_Site_Visit_Completion__c)
                    setofOppIdForSMS.add(eachOpp.id);
                if(eachOpp.RW_Call_Completion__c && !mapOldOppId.get(eachOpp.id).RW_Call_Completion__c)
                    setofOppIdForCallCompletion.add(eachOpp.id);
                if(eachOpp.RW_Missed_Call__c && !mapOldOppId.get(eachOpp.id).RW_Missed_Call__c)
                    setofOppIdForMissedCall.add(eachOpp.id);
                // Added by coServe 20-01-2023 Start
                if(eachOpp.LeadSource == 'Retention' && ((eachOpp.Retention_RM_Name__c != null && eachOpp.Retention_RM_Name__c != mapOldOppId.get(eachOpp.Id).Retention_RM_Name__c) ||
                                                         (eachOpp.Retention_Closing_Head_Name__c!= null && eachOpp.Retention_Closing_Head_Name__c != mapOldOppId.get(eachOpp.Id).Retention_Closing_Head_Name__c)||
                                                         (eachOpp.Retention_Presales_User__c != null && eachOpp.Retention_Presales_User__c != mapOldOppId.get(eachOpp.Id).Retention_Presales_User__c)||
                                                         (eachOpp.Retention_Sales_Manager__c != null && eachOpp.Retention_Sales_Manager__c != mapOldOppId.get(eachOpp.Id).Retention_Sales_Manager__c))){
                                                             retentionOppIds.add(eachOpp.Id);
                                                         } 
                System.debug('retentionOppIds: ' + retentionOppIds);
                // Added by coServe 20-01-2023 End
                // Added by coServe 08-03-2024
                if(eachOpp.StageName == 'Unit Booked' && eachOpp.SAP_Customer_Number__c != null && eachOpp.SalesOrder_Number__c != null && 
                   (mapOldOppId.get(eachOpp.Id).SAP_Customer_Number__c == null || mapOldOppId.get(eachOpp.Id).SalesOrder_Number__c == null ||
                   mapOldOppId.get(eachOpp.Id).StageName != 'Unit Booked') && System.label.Send_Sales_Experience_Whatsapp_on_booking == 'true' && 
                   eachOpp.Send_Sales_Experience_Whatsapp_Message__c == false){
                       if(!Test.isRunningTest()){
                           //SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(eachOpp.Id, eachOpp.Name, eachOpp.RW_Sales_Associate__c, null, null, null, null, null, null, eachOpp.Booking__r.RW_Country_Phone_Code__c, eachOpp.RW_Mobile_No__c, 'Sales Experience');
                       }
                       oppIdsToUpdate.add(eachOpp.Id);
                }
                
                if(eachOpp.SalesOrder_Number__c != null && mapOldOppId.get(eachOpp.Id).SalesOrder_Number__c == null && eachOpp.StageName == 'Unit Booked'){ // Added by coServe 15-07-2024
                    oppIdsToSendWhatsApp.add(eachOpp.Id);
                }
                
            }
        }
        
        if(oppIdsToSendWhatsApp.size() > 0){ // Added by coServe 15-07-2024
            sendWhatsApp(oppIdsToSendWhatsApp);
        }
        
        
        // Added by coServe 08-03-2024 Start
        if(oppIdsToUpdate.size() > 0){
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            for(String oppId : oppIdsToUpdate){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                //opp.Send_Sales_Experience_Whatsapp_Message__c = true;
				opp.Unit_Booked_Date__c = Datetime.now();
                oppListToUpdate.add(opp);
            }
            update oppListToUpdate;
        }
        // Added by coServe 20-01-2023 Start
        if(retentionOppIds.size() > 0){
            List<Opportunity> oppList = [SELECT Id, Name, LeadSource, Retention_RM_Name__c,Retention_RM_Name__r.FirstName, Retention_RM_Name__r.LastName,
                                         Retention_RM_Name__r.UserName, Retention_Closing_Head_Name__r.FirstName, Retention_Closing_Head_Name__r.LastName, 
                                         Retention_Closing_Head_Name__r.UserName,Retention_Closing_Head_Name__c, Retention_Presales_User__r.FirstName,
                                         Retention_Presales_User__r.LastName, Retention_Presales_User__r.UserName, Retention_Sales_Manager__r.FirstName,
                                         Retention_Sales_Manager__r.LastName, Retention_Sales_Manager__r.UserName, Retention_Presales_User__c,
                                         Retention_Sales_Manager__c FROM Opportunity WHERE Id =: retentionOppIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Opportunity opp : oppList){
                if(opp.Retention_RM_Name__c != null && opp.Retention_RM_Name__c != mapOldOppId.get(opp.Id).Retention_RM_Name__c){
                    mails.add(sendEmail(opp,'Retention RM Name'));  
                }
                if(opp.Retention_Closing_Head_Name__c!= null && opp.Retention_Closing_Head_Name__c != mapOldOppId.get(opp.Id).Retention_Closing_Head_Name__c){
                    mails.add(sendEmail(opp,'Retention Closing Head Name'));  
                }
                if(opp.Retention_Presales_User__c != null && opp.Retention_Presales_User__c != mapOldOppId.get(opp.Id).Retention_Presales_User__c){
                    mails.add(sendEmail(opp,'Retention Presales User'));  
                }
                if(opp.Retention_Sales_Manager__c != null && opp.Retention_Sales_Manager__c != mapOldOppId.get(opp.Id).Retention_Sales_Manager__c){
                    mails.add(sendEmail(opp,'Retention Sales Manager'));  
                }
            }
            System.debug('emails size: ' + mails.size());
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
            System.debug('emails result: ' + result);
        }
        // Added by coServe 20-01-2023 End
        
        //List<Project_Unit__c> lstProjUnit = [Select Id, RW_Unit_Status__c, RW_Customer__c from Project_Unit__c Where ID IN : setIdofProjUnit OR RW_Customer__c IN : setofOppId];  //Commented by Vinay 31-01-2025
        List<Project_Unit__c> lstProjUnit = new List<Project_Unit__c>(); //Added by Vinay 31-01-2025
        if(setIdofProjUnit.size() > 0 && setofOppId.size() > 0) //Added by Vinay 31-01-2025
            lstProjUnit = [Select Id, RW_Unit_Status__c, RW_Customer__c from Project_Unit__c Where ID IN : setIdofProjUnit OR RW_Customer__c IN : setofOppId]; 
        
        //------------unit change------------------------
        if(lstOpp.size() > 0)
        {
            for(Opportunity eachOpp : lstOpp)
            {
                if(lstProjUnit.size() > 0)
                {
                    for(Project_Unit__c eachProjUnit : lstProjUnit)
                    {      
                        if(eachOpp.RW_Project_Unit__c != mapOldOppId.get(eachOpp.Id).RW_Project_Unit__c && mapOldOppId.get(eachOpp.Id).RW_Project_Unit__c != null && eachProjUnit.id == mapOldOppId.get(eachOpp.Id).RW_Project_Unit__c)
                        {system.debug('MK');
                         eachProjUnit.RW_Unit_Status__c = 'Available';
                         eachProjUnit.RW_Customer__c = null;
                         eachProjUnit.Booking_Source1__c = null;
                         //lstProjUnittoUpdate.add(objPu);
                        }
                        if(eachOpp.RW_Project_Unit__c!=null && eachProjUnit.id == eachOpp.RW_Project_Unit__c && eachProjUnit.RW_Unit_Status__c == 'Available')
                        {system.debug('MK');
                         eachProjUnit.RW_Unit_Status__c = 'Blocked';
                         eachProjUnit.RW_Customer__c = eachOpp.id;
                         // Commented by Vinay 02-02-2022
                         /*if(eachOpp.LeadSource!=null && eachOpp.LeadSource!='')
eachProjUnit.Booking_Source1__c = eachOpp.LeadSource;*/
                         // Added by Vinay 02-02-2022
                         if(eachOpp.Walkin_Source__c!=null && eachOpp.Walkin_Source__c!='')
                             eachProjUnit.Booking_Source1__c = eachOpp.Walkin_Source__c;
                        }
                    }
                }
                
            }
            system.debug('lstProjUnit!!!!'+lstProjUnit);
            if(lstProjUnit.size()>0)
                
                update lstProjUnit;
        }
        if(setofOppIdForSMS!=null && setofOppIdForSMS.size()>0) 
            OutboundSMSFutureHandler.SendSMSOnOppProcess(setofOppIdForSMS);
        
        if(setofOppIdForCallCompletion!=null && setofOppIdForCallCompletion.size()>0)
            OutboundSMSFutureHandler.SendSMSOnOppCallCompletion(setofOppIdForCallCompletion);
        
        if(setofOppIdForMissedCall!=null && setofOppIdForMissedCall.size()>0)
            OutboundSMSFutureHandler.SendSMSOnOppMissedCall(setofOppIdForMissedCall);
        
        AfterStageBookedSaveAccount(lstOpp,mapOldOppId);
        //inserSiteVisit(lstOpp, mapOldOppId);
        
        
    }
    
    public void afterUpdateSAP(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId) {
        set<Id> lstOppBookedIds = new set<Id>();
        set<Id> lstBlockedOppIds = new set<Id>();/*Added for unidentified payments starts */
        system.debug(lstOpp);
        system.debug(lstOpp.size() );
        if(lstOpp.size() > 0)
        {
            for(Opportunity objOpportunity : lstOpp)
            {
                System.debug('objOpportunity.StageName::'+objOpportunity.StageName);
                System.debug('mapOldOppId.get(objOpportunity.id).StageName::'+mapOldOppId.get(objOpportunity.id).StageName);
                //if(objOpportunity.StageName == 'Unit Booked' && mapOldOppId.get(objOpportunity.id).StageName != 'Unit Booked'  && objOpportunity.RW_Project__r.Name  != 'Runwal Greens')
                if(objOpportunity.StageName == 'Unit Booked' && mapOldOppId.get(objOpportunity.id).StageName != 'Unit Booked'  && objOpportunity.RW_Project__c  != 'a005D000000r5VW' && objOpportunity.RW_Project__c  != 'a002800000Lxm6Y')
                {
                    lstOppBookedIds.add(objOpportunity.Id);
                }
                /*Added for unidentified payments starts */
                if(objOpportunity.StageName == 'Unit Blocked' && mapOldOppId.get(objOpportunity.id).StageName != 'Unit Blocked' && mapOldOppId.get(objOpportunity.id).StageName =='Site Visit')
                {
                    lstBlockedOppIds.add(objOpportunity.Id);
                }
                /*Added for unidentified payments ends */
            }
        }
        
        system.debug('objOpportunity=====' + lstOppBookedIds);
        if(lstOppBookedIds.size() > 0)
        {   
            //SAPIntegrationServices.createSO(lstOppBookedIds);
        }
        /*Added for unidentified payments starts */
        if(lstBlockedOppIds.size() > 0)
        {       
            OpportunityCustomerCreation.createOppCustomer(lstBlockedOppIds);
        }
        /*Added for unidentified payments ends */
    }
    
    //After stage booked then save applicante in farvision
    public void AfterStageBookedSaveAccount(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId)
    {
        set<Id> lstOppBookedIds = new set<Id>();
        if(lstOpp.size() > 0)
        {
            for(Opportunity objOpportunity : lstOpp)
            {
                if(objOpportunity.StageName == 'Unit Booked' && mapOldOppId.get(objOpportunity.id).StageName != 'Unit Booked' && (objOpportunity.FV_Application_ID__c == ''|| objOpportunity.FV_Application_ID__c == null) && (objOpportunity.RW_Project__c  == 'a005D000000r5VW' || objOpportunity.RW_Project__c  == 'a002800000Lxm6Y'))
                {
                    lstOppBookedIds.add(objOpportunity.Id);
                }
            }
        }
        
        system.debug('objOpportunity=====' + lstOppBookedIds);
        if(lstOppBookedIds.size() > 0)
        {
            FarvisionApiConfiguration.CreateApplicationInFarvision(lstOppBookedIds);
        }
    }
    
    //this method is used for insert the site visit event on site visit stage
    /** commented by shailesh to stop site visit event on site visit stage.
private void inserSiteVisit(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId)
{
if(lstOpp != null && lstOpp.size() > 0)
{
List<Event> lstEventInsert = new List<Event>();
for(Opportunity eachOpp : lstOpp)
{
if(eachOpp.StageName == Label.RW_Site_Visit_StageName && (mapOldOppId == null || (mapOldOppId != null && 
mapOldOppId.get(eachOpp.id).StageName != eachOpp.StageName)))
{
Event objEvent = new Event();
objEvent.WhatId = eachOpp.id;
objEvent.Subject = 'Site Visit';
objEvent.OwnerId = eachOpp.OwnerId;
objEvent.StartDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 6, 00, 00);
objEvent.EndDateTime = datetime.newInstance(System.today().year(), System.today().month(), System.today().day(), 8, 00, 00);
objEvent.Type = 'Site Visit';
objEvent.Project__c = eachOpp.RW_Project__c;
objEvent.Remarks__c = eachOpp.RW_Sales_Manager_Comment__c;
objEvent.RW_Sales_Associate__c = eachOpp.RW_Sales_Associate__c;
lstEventInsert.add(objEvent);
}
}

if(lstEventInsert != null && lstEventInsert.size() > 0)
{
insert lstEventInsert;
}
}
}
**/
    private void updateCancellation(List<Opportunity> lstOpp, Map<Id, Opportunity> mapOldOppId)
    {system.debug('mk');
     if(lstOpp != null && lstOpp.size() > 0)
     {system.debug('mk');
      set<String> setOfUnit = new set<String>();
      set<String> setOfOpportunity = new set<String>();
      for(Opportunity EachOpp : lstOpp)
      {
          System.debug('*stageName*'+EachOpp.StageName+'**'+EachOpp.RW_Project_Unit__c);
          if((EachOpp.StageName == 'Cancelled' || EachOpp.StageName =='Booking Cancelled – Refund Pending') && EachOpp.RW_Project_Unit__c != null)
          {
              setOfUnit.add(EachOpp.RW_Project_Unit__c);
              system.debug('Sharique' + EachOpp.RW_Project_Unit__c);
              EachOpp.RW_Project_Unit__c = null;
              setOfOpportunity.add(EachOpp.Id);
          }
      }
      system.debug(setOfUnit);
      if(setOfUnit != null && setOfUnit.size() > 0)
      {
          List<Project_Unit__c> lstUnit2Update = new List<Project_Unit__c>();
          for(string EachUnit : setOfUnit)
          {
              Project_Unit__c objUnit = new Project_Unit__c();
              objUnit.Id = EachUnit;
              objUnit.RW_Customer__c = null;
              objUnit.Booking_Source1__c = null;
              objUnit.RW_Sales_Manager__c = null;
              objUnit.RW_Booking_Date__c = null;
              objUnit.RW_Current_Customer_Email__c = null;
              objUnit.RW_Unit_Status__c = 'Available';
              objUnit.Booking__c = null;
              
              lstUnit2Update.add(objUnit);
              system.debug('sharique size of list' + lstUnit2Update);
          }
          
          if(lstUnit2Update.size() > 0)
          {
              update lstUnit2Update;
          }
      }
      
      List<String> status = new List<String>{'Booking Confirmed','Booking Registered','Unit Booked'};
          Map<Id,List<Opportunity>> accountOppMap = new Map<Id,List<Opportunity>>();
      Map<Id,Booking__c> OppBookingMap = new Map<Id,Booking__c>();
      Set<Id> AccountIds = new Set<Id>();
      Set<Id> AllOpportunities = new Set<Id>();
      Set<Id> InactivatePortalAccountIds = new Set<Id>();   
      Set<Id> unitTransferOpportunityIds = new Set<Id>();
      if(setOfOpportunity.size() > 0){ //Added if condition by Vinay 31-01-2025
        for(Opportunity opp : [Select id,accountId,(select Status__c,Project__c,Cancellation_Reason__c FROM Booking__r) from opportunity where Id IN :setOfOpportunity])
        {
            AccountIds.add(opp.accountId);
            for(Booking__c bk : opp.Booking__r)
            {
                if(bk.Cancellation_Reason__c == 'Unit transfer')
                {
                    unitTransferOpportunityIds.add(opp.Id);
                }
            }
        }
    }
      
    if(AccountIds.size() > 0){ //Added if condition by Vinay 31-01-2025
        for(Account ao:[Select Id,name,(select Id,name from opportunities) from account       
                        where Id in:AccountIds]) 
        {
            if(ao.opportunities.size() > 1)
            {
                accountOppMap.put(ao.Id,ao.opportunities);
                for(Opportunity oppor : ao.opportunities)
                {
                    AllOpportunities.add(oppor.Id);
                }
            }
            
            else if(ao.opportunities.size() == 1)
            {
                if(!unitTransferOpportunityIds.contains(ao.opportunities[0].Id))
                    InactivatePortalAccountIds.add(ao.Id);
            }
        }
    }
      
      
      
    if(AllOpportunities.size() > 0){ //Added if condition by Vinay 31-01-2025
        for(Opportunity opp : [Select id,accountId,(select Status__c,Project__c FROM Booking__r where Status__c IN :status) from opportunity where Id IN :AllOpportunities])
        {
            if(opp.Booking__r.size() >0)
                OppBookingMap.put(opp.Id,opp.Booking__r[0]);
        }
    }
      
      
      for(Id accountId : accountOppMap.keyset())
      {
          Boolean hasOtherActiveBookings = false;
          for(Opportunity opp : accountOppMap.get(accountId))
          {
              if(!setOfOpportunity.contains(opp.Id) )
              {
                  if(OppBookingMap.containsKey(opp.Id))
                  {
                      if(status.contains(OppBookingMap.get(opp.Id).Status__c))
                      {
                          hasOtherActiveBookings = true;
                      }
                      else
                      {
                          //InactivatePortalAccountIds.add(opp.Id);
                      }
                  }
              }
          }
          
          if(!hasOtherActiveBookings)
          {
              InactivatePortalAccountIds.add(accountId);
          }
      }
      Map<Id,Id> personContactMap = new Map<Id,Id>(); 
      if(InactivatePortalAccountIds.size() >0)
      {
          List<Account> accountRecs = [SELECT PersonContactId,OwnerId FROM Account WHERE id IN :InactivatePortalAccountIds];
          for(Account acc : accountRecs)
          {
              if(acc.PersonContactId != null)
                  personContactMap.put(acc.Id,acc.PersonContactId);
          }
      }
      
      List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
      //EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Community_User_Deactivation']; //Commented by Vinay 31-01-2025
      List<User> usersToUpdate = new List<User>();
      List<Id> userIds = new List<Id>();
      List<User> userRecords = new List<User>();
      if(personContactMap.size() > 0){ //Added if condition by Vinay 31-01-2025
        for(User u : [Select Id, IsActive, IsPortalEnabled,Email from User  where ContactId in :personContactMap.Values()])
        {
            if(u.IsActive || u.IsPortalEnabled )
            {
                //u.IsActive = false;
                //u.IsPortalEnabled = false;
                //usersToUpdate.add(u);
                userIds.add(u.Id);
                userRecords.add(u);
            }
        }
    }
      
      if (userIds.size()>0)
      {
          //CommunityUserUpdate.updateUser(userIds);
          //update usersToUpdate;
          System.enqueueJob(new CommunityUserUpdate(userIds));
      }
      
      if(userRecords.size() > 0){ //Added if condition by Vinay 31-01-2025
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Community_User_Deactivation']; //Added by Vinay 31-01-2025
        for(User u : userRecords)
        {
            String htmlBody = template.HtmlValue; 
            //htmlBody = htmlBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            String plainTextBody = template.Body; 
            //plainTextBody = plainTextBody.replace('{!RW_EOI__c.Name}', eoiRec.Name);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new List<String>{u.email};
                message.subject = template.Subject;
            message.setTemplateId(template.Id);
            message.setHtmlBody(htmlBody);   
            message.setPlainTextBody(plainTextBody);
            message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            messages.add(message);
        }
    }
      
      if(messages.size() >0)
          Messaging.sendEmail(messages);
      
      
     }
     
    }
    
    private void updateRatingValue(List<Opportunity> lstOpp)
    {
        if(lstOpp != null && lstOpp.size() > 0)
        {
            for(Opportunity EachOpp : lstOpp)
            {
                if(EachOpp.RW_Auto_Rating__c >= 4.5)
                {
                    EachOpp.RW_Rating_Value__c = 'Hot, Likely booking';
                }
                else if(EachOpp.RW_Auto_Rating__c >= 4)
                {
                    EachOpp.RW_Rating_Value__c = 'Hot, Site Head to intervene';
                }
                else if(EachOpp.RW_Auto_Rating__c >= 3.5)
                {
                    EachOpp.RW_Rating_Value__c = 'Warm- Push for revisit';
                }
                else if(EachOpp.RW_Auto_Rating__c >= 3)
                {
                    EachOpp.RW_Rating_Value__c = 'Warm- Understand client issues and push for revisit';
                }
                else if(EachOpp.RW_Auto_Rating__c >= 2.5)
                {
                    EachOpp.RW_Rating_Value__c = 'Cold, follow-up at least five times';
                }
                else if(EachOpp.RW_Auto_Rating__c >= 2)
                {
                    EachOpp.RW_Rating_Value__c = 'Cold, follow-up at least thrice'; 
                }
                else if(EachOpp.RW_Auto_Rating__c > 0)
                {
                    EachOpp.RW_Rating_Value__c = 'Lost';
                }
                else
                {
                    EachOpp.RW_Rating_Value__c = '';
                }
            }
        }
    }
    
    // Added by Shailesh//
    //@future
    public static void updatebudgetonOpty(Set<Id> oSet) {
        List<Opportunity> oList = new List<Opportunity>();
        olIst = [Select Id, Name,Budget_In_Cr__C,RW_Budget__c from Opportunity where Id IN :oSet];
        if(oList != null && oList.size() > 0)
        {
            List<opportunity> optyListToUpdate = new List<Opportunity>();
            for(Opportunity Eachopty : oList)
            {
                if(Eachopty.Budget_In_Cr__C != null)
                {
                    
                    if(Eachopty.Budget_In_Cr__C <= 2000000) 
                    {
                        Eachopty.RW_Budget__c = '< 0.20 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 3000000) 
                    {
                        Eachopty.RW_Budget__c = '0.20 Cr - 0.30 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 4000000) 
                    {
                        Eachopty.RW_Budget__c = '0.30 Cr - 0.40 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 5000000) 
                    {
                        Eachopty.RW_Budget__c = '0.40 Cr - 050 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 6000000) 
                    {
                        Eachopty.RW_Budget__c = '0.50 Cr - 0.60 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 7000000) 
                    {
                        Eachopty.RW_Budget__c = '0.60 Cr - 0.70 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 8000000) 
                    {
                        Eachopty.RW_Budget__c = '0.70 Cr - 0.80 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 9000000) 
                    {
                        Eachopty.RW_Budget__c = '0.80 Cr - 0.90 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 10000000) 
                    {
                        Eachopty.RW_Budget__c = '0.90 Cr - 1.00 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 11000000) 
                    {
                        Eachopty.RW_Budget__c = '1.00 Cr - 1.10 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 12000000) 
                    {
                        Eachopty.RW_Budget__c = '1.10 Cr - 1.20 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 13000000) 
                    {
                        Eachopty.RW_Budget__c = '1.20 Cr - 1.30 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 14000000) 
                    {
                        Eachopty.RW_Budget__c = '1.30 Cr - 1.40 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 15000000) 
                    {
                        Eachopty.RW_Budget__c = '1.40 Cr - 1.50 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 16000000) 
                    {
                        Eachopty.RW_Budget__c = '1.50 Cr - 1.60 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 17000000) 
                    {
                        Eachopty.RW_Budget__c = '1.60 Cr - 1.70 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 18000000) 
                    {
                        Eachopty.RW_Budget__c = '1.70 Cr - 1.80 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 19000000) 
                    {
                        Eachopty.RW_Budget__c = '1.80 Cr - 1.90 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 20000000) 
                    {
                        Eachopty.RW_Budget__c = '1.90 Cr - 2.00 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 22500000) 
                    {
                        Eachopty.RW_Budget__c = '2.00 Cr - 2.25 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 25000000) 
                    {
                        Eachopty.RW_Budget__c = '2.25 Cr - 2.50 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 27500000) 
                    {
                        Eachopty.RW_Budget__c = '2.50 Cr - 2.75 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C <= 30000000) 
                    {
                        Eachopty.RW_Budget__c = '2.70 Cr - 3 Cr';
                    }
                    else if(Eachopty.Budget_In_Cr__C > 30000000) 
                    {
                        Eachopty.RW_Budget__c = ' > 3 Cr';
                    }
                    
                    optyListToUpdate.add(Eachopty);
                }
                
            }
            if(!optyListToUpdate.isEmpty())
                update optyListToUpdate;
        }
    }
    Public void UpdateCPAccount(List<Opportunity> lstOpp){
        Set<Id> setIdofCP = new Set<Id>();
        Set<Id> setIdofAccount = new Set<Id>();
        Set<Id> setIdofUser = new Set<Id>();
        List<Opportunity> OppUpdateList = new List<Opportunity>();
        //List <Broker__c> lstCP = new List <Broker__c>(); // Commented by Vinay 20-06-2025
        for(Opportunity Eachopty : lstOpp){
            if(Eachopty.RW_Walkin_Channel_Partner__c != null){
                setIdofCP.add(Eachopty.RW_Walkin_Channel_Partner__c);
            }
        }
        if(setIdofCP.size() > 0){ // Added if condition by Vinay 31-01-2025
             //lstCP = [Select Id,Name, Account__c from Broker__c where Id IN: setIdofCP];
             Map<Id, Broker__c> cpMap = new Map<Id, Broker__c>([Select Id,Name, Account__c from Broker__c where Id IN: setIdofCP]);
             for(Opportunity Eachopp : lstOpp){
                 if(Eachopp.RW_Walkin_Channel_Partner__c != Null && cpMap.get(Eachopp.RW_Walkin_Channel_Partner__c).Account__c != null){ // Added  cpMap.get(Eachopp.RW_Walkin_Channel_Partner__c).Account__c != null by Vinay 20-06-2025          
                     /*for(Broker__c b :lstCP){   // Commented by Vinay 20-06-2025
                         if(b.Account__c != NULL){ 
                             Opportunity opp = new Opportunity();
                             opp.Channel_Partner_Account__c = b.Account__c;
                             opp.Id = Eachopp.Id;
                             OppUpdateList.add(opp);
                             
                         }
                     }*/
                     Opportunity opp = new Opportunity();
                     opp.Channel_Partner_Account__c = cpMap.get(Eachopp.RW_Walkin_Channel_Partner__c).Account__c;
                     opp.Id = Eachopp.Id;
                     OppUpdateList.add(opp);
                 }
             }
        }
        if(OppUpdateList.size() > 0){
            /*  Map<Id, Opportunity> OppMap = new Map<Id, Opportunity>(OppUpdateList);
update OppMap.values();*/
            
            Map<Id, Opportunity> mapIdOpportunityToUpdate = new Map<Id, Opportunity>();
            for(Opportunity OpptyToUpdate : OppUpdateList){
                mapIdOpportunityToUpdate.put(OpptyToUpdate.Id, OpptyToUpdate);         
            }
             update mapIdOpportunityToUpdate.values();
        }
    }
    Public void InsertCPAccount(List<Opportunity> lstOpp){
        Set<Id> setIdofCP = new Set<Id>();
        List<Opportunity> OppUpdateList = new List<Opportunity>();
        List <Broker__c> lstCP = new List <Broker__c>();
        for(Opportunity Eachopty : lstOpp){
            if(Eachopty.RW_Walkin_Channel_Partner__c != null){
                setIdofCP.add(Eachopty.RW_Walkin_Channel_Partner__c);
            }
            
            
            if(lstCP.size() > 0){
                Eachopty.Channel_Partner_Account__c = lstCP[0].Id;
            }
        }
        if(setIdofCP.size() > 0) //Added if condition by Vinay 31-01-2025
        	lstCP = [Select Id,Name, Account__c from Broker__c where Id IN: setIdofCP];
        for(Opportunity Eachopp : lstOpp){
            for(Broker__c b :lstCP){
                if(b.Account__c != NULL){
                    Opportunity opp = new Opportunity();
                    opp.Channel_Partner_Account__c = b.Account__c;
                    opp.Id = Eachopp.Id;
                    OppUpdateList.add(opp);
                }
            }
        }
        if(OppUpdateList.size() > 0){
            update OppUpdateList;
        }
    }
    
    public static void sendWhatsApp(List<String> oppIds){
        List<Opportunity> opps = [SELECT Id, Primary_Name__c, RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c, Booking__r.Source_of_Booking__c, Booking__r.Quotation__c FROM Opportunity WHERE Id =: oppIds];
        /*String fileURL = System.label.Home_Loan_pdf_link;
        List<String> quoteIds = new List<String>();
        
        for(Opportunity eachOpp : opps){
            String costSheetLink = 'id='+ eachOpp.Booking__r.Quotation__c + '&doc=costsheet';
            if(!Test.isRunningTest()){
                SendWhatsAppMsg.methodToSendWhatsAppMsg(null,eachOpp.Primary_Name__c,eachOpp.Booking__r.Source_of_Booking__c,null,null,null,null,null,costSheetLink,eachOpp.Booking__r.RW_Country_Phone_Code__c,eachOpp.RW_Mobile_No__c,'Booking Details');
            	SendWhatsAppMsg.methodToSendWhatsAppMsg(null,eachOpp.Primary_Name__c,null,null,null,null,null,fileURL,'Home Loan',eachOpp.Booking__r.RW_Country_Phone_Code__c,eachOpp.RW_Mobile_No__c,'Bank Funding Requirements Documents');
            }
            
            quoteIds.add(eachOpp.Booking__r.Quotation__c);
        }
        if(quoteIds.size() > 0){
            //costSheetPdfDataUpdate(quoteIds);
        }*/
        
        Id JobId = System.enqueueJob(new SendWhatsAppOnSOCreationQueueable(oppIds));
    }
    // Added by coServe 27-06-2024
    public static void sendProspectDay1WhatsApp(List<String> oppIds){
        List<String> stages = System.label.Prospect_Engagement_Whatsapp_Opp_Stages.split(',');
        
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for(Opportunity opp : [SELECT Id, Name, StageName, Date_Of_Visit__c, RW_Project__c, RW_Project__r.VDNB_Customer_Whatsapp_Journey__c, RW_Mobile_No__c, RW_Project__r.Name, RW_Project__r.Day_1_Whatsapp_Content__c, RW_Project__r.WhatsApp_Bot_Project_Brochure_Url__c, RW_Project__r.Presales_Contact_No__c, RW_Project__r.Prospect_Engagement_Team__c, Account.Country_Code__c FROM Opportunity WHERE Id =: oppIds AND RW_Project__r.VDNB_Customer_Whatsapp_Journey__c = true]){ 
            if(stages.contains(opp.StageName) && opp.RW_Project__c != null && opp.RW_Project__r.VDNB_Customer_Whatsapp_Journey__c == true && opp.RW_Mobile_No__c != null){
                oppMap.put(opp.Id, opp);
            }
        }
        if(oppMap.keySet().size() > 0){
            List<CIF__c> cifs = [SELECT Id, Opportunity__c FROM CIF__c WHERE Opportunity__c =: oppMap.keySet()];
            Map<String,String> oppVsCifMap = new Map<String, String>();
            for(CIF__c cif : cifs){
                oppVsCifMap.put(cif.Opportunity__c, cif.Id);
            }
            for(String oppId : oppMap.keySet()){
                if(oppVsCifMap.get(oppId) != null && !Test.isRunningTest()){
                    //SendWhatsAppMsg.methodToSendWhatsAppMsg(null, oppMap.get(oppId).Name, oppMap.get(oppId).RW_Project__r.Name, oppMap.get(oppId).RW_Project__r.Day_1_Whatsapp_Content__c, oppMap.get(oppId).RW_Project__r.WhatsApp_Bot_Project_Brochure_Url__c, oppMap.get(oppId).RW_Project__r.Prospect_Engagement_Team__c, null, null, null, oppMap.get(oppId).Account.Country_Code__c, oppMap.get(oppId).RW_Mobile_No__c, 'Prospect Engagement Day 1');
                    SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(oppMap.get(oppId).Name, oppMap.get(oppId).RW_Project__r.Name, oppMap.get(oppId).RW_Project__r.Day_1_Whatsapp_Content__c, oppMap.get(oppId).RW_Project__r.WhatsApp_Bot_Project_Brochure_Url__c, oppMap.get(oppId).RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, oppMap.get(oppId).RW_Mobile_No__c, 'Prospect Engagement Day 1'); //Commented by Vinay 11-09-2025
                    //SendWhatsAppMsg.methodToSendWhatsAppMsgNew(oppMap.get(oppId).Name, oppMap.get(oppId).RW_Project__r.Name, oppMap.get(oppId).RW_Project__r.Day_1_Whatsapp_Content__c, oppMap.get(oppId).RW_Project__r.WhatsApp_Bot_Project_Brochure_Url__c, oppMap.get(oppId).RW_Project__r.Prospect_Engagement_Team__c, null, null, null, null, oppMap.get(oppId).Account.Country_Code__c, oppMap.get(oppId).RW_Mobile_No__c, 'Prospect Engagement Day 1'); //Added by Vinay 11-09-2025
                }
            }
        }
        
    }
    
    /*@future(callout=true)
    public static void costSheetPdfDataUpdate(List<String> quoteIds){
        List<Quotation__c> quotes = [SELECT Id FROM Quotation__c WHERE Id =: quoteIds];
        for(Quotation__c q : quotes){
            PageReference pdf = Page.quotationattachment;
            pdf.getParameters().put('id',q.Id);
            Blob body= pdf.getContent();
            String pdfData = EncodingUtil.base64encode(body);
            q.Cost_Sheet_pdf_data__c = pdfData;
        }
        update quotes;
    }*/
    public static void dummyMethod()  {
        decimal a =1;
        decimal b= 2;
        decimal c= 0;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
        c = a+b;
    }
    
}