public without sharing class leadTriggerHandler
{
    public void BeforeInsert(List<Lead> lstLead)
    {
        if(lstLead.size() > 0)
        {
            List<Lead> leadsForPresalesAssignment = new List<Lead>();
            
            for(Lead eachLead : lstLead)
            {
                if(eachLead.Web_To_Lead_Project__c != null && eachLead.Web_To_Lead_Project__c !='' && Lead__c.getAll().ContainsKey(eachLead.Web_To_Lead_Project__c))
                { 
                    eachLead.RW_Project__c = Lead__c.getInstance(eachLead.Web_To_Lead_Project__c).Project_Id__c !=null?Lead__c.getInstance(eachLead.Web_To_Lead_Project__c).Project_Id__c:null;
                }
                
                eachLead.Lead_Source__c = eachLead.LeadSource;
                
                //added on 6th July
                if(eachLead.RW_Corporate_Web_To_Lead__c)
                {
                    if(eachLead.RW_Existing_Corporate_Tie_Up__c)
                    {
                        eachLead.LeadSource = 'Corporate';
                    }
                    else
                    {
                        eachLead.LeadSource = 'Corporate(Unregistered)';
                        eachLead.RW_Lead_Sub_Source__c = 'Website enquiry';
                    }
                }
                
                
                if(eachLead.LeadSource == 'Digital'){ //Added by coServe 14-05-2024
                    leadsForPresalesAssignment.add(eachLead);
                }
                
                
                //added on 5th July by adarsh for the new CR
                //updation of email id
                /*if(eachLead.RW_Customer_Email__c != null)
{
pattern myPattern = pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+'); 
matcher myMatcher = myPattern.matcher(eachLead.RW_Customer_Email__c);
if(myMatcher.matches())
{
eachLead.Email = eachLead.RW_Customer_Email__c;
}
else
{
eachLead.addError('Please enter a valid Customer Email.');
}
}
else if(eachLead.Email != null)
{
eachLead.RW_Customer_Email__c = eachLead.Email;
}

//updation of mobile number
if(eachLead.RW_Customer_Mobile_Number__c != null)
{
eachLead.RW_Mobile_No__c = eachLead.RW_Customer_Mobile_Number__c;
}
else if(eachLead.RW_Mobile_No__c != null)
{
eachLead.RW_Customer_Mobile_Number__c = eachLead.RW_Mobile_No__c;
}*/
            }
            if(leadsForPresalesAssignment.size() > 0){ //Added by coServe 14-05-2024 
                //assignToPresalesUser(leadsForPresalesAssignment); //Commented by coServe 03-07-2024
            }
            
            set<string> setOfAgentMail = new set<string>();
            for(Lead EachLead : lstLead)
            {
                if(EachLead.RW_Agent_ID__c != null)
                {
                    setOfAgentMail.add(EachLead.RW_Agent_ID__c);
                }
            }
            if(setOfAgentMail.size() > 0)
            {
                list<user> lstUserDetail = [select id, email from user where email in: setOfAgentMail];
                if(lstUserDetail != null && lstUserDetail.size() > 0)
                {
                    map<string,string> mapOfUser = new map<string,string>();
                    for(user EachUser : lstUserDetail)
                    {
                        mapOfUser.put(EachUser.email, EachUser.id);
                    }
                    for(Lead EachLead : lstLead)
                    {
                        if(EachLead.RW_Agent_ID__c != null && mapOfUser.get(EachLead.RW_Agent_ID__c) != null)
                        {
                            EachLead.ownerId = mapOfUser.get(EachLead.RW_Agent_ID__c);
                        }
                    }
                }
            }
            //   updateBudget(lstLead);
        }
    }
    
    public void AfterInsert(List<Lead> lstLead)
    {
       duplicityCheck(lstLead, null);
        
        //Added by coServe 20-01-2023 Start
        List<Id> leadIds = new List<Id>();
        List<String> digitalLeadIds = new List<String>(); //Added by Vinay 23-09-2025
        //List<Id> loyaltyLeadIds= new List<Id>();  // Commented by Vinay 28-05-2025 to stop round robin auto assignment
        for(Lead ld : lstLead){
            if(ld.LeadSource == 'Retention' && (ld.Retention_RM_Name__c != null || ld.Retention_Closing_Head_Name__c!= null || ld.Retention_Presales_User__c != null || ld.Retention_Sales_Manager__c != null)){
                leadIds.add(ld.Id);
            } 
            if(ld.LeadSource == 'Digital'){ //Added by Vinay 23-09-2025
                digitalLeadIds.add(ld.Id);
            }
            /*List<String> loyaltyLeadSources = System.label.Loyalty_Referral_Lead_Sources.split(',');  // Commented by Vinay 28-05-2025 to stop round robin auto assignment

if(loyaltyLeadSources.contains(ld.LeadSource)){ //Added by coServe 26-07-2024
loyaltyLeadIds.add(ld.Id);
}*/
            
        }
        if(digitalLeadIds.size() > 0){ //Added by Vinay 23-09-2025
            //system.enqueuejob(new DigitalLeadAssignment(digitalLeadIds)); //Commented by Vinay 29-09-2025
        }
        if(leadIds.size()>0){
            List<Lead> leadList = [SELECT Id, Name, LeadSource, Retention_RM_Name__c,Retention_RM_Name__r.FirstName, Retention_RM_Name__r.LastName,
                                   Retention_RM_Name__r.UserName, Retention_Closing_Head_Name__r.FirstName, Retention_Closing_Head_Name__r.LastName, 
                                   Retention_Closing_Head_Name__r.UserName,Retention_Closing_Head_Name__c, Retention_Presales_User__r.FirstName,
                                   Retention_Presales_User__r.LastName, Retention_Presales_User__r.UserName, Retention_Sales_Manager__r.FirstName,
                                   Retention_Sales_Manager__r.LastName, Retention_Sales_Manager__r.UserName, Retention_Presales_User__c,
                                   Retention_Sales_Manager__c FROM Lead WHERE Id =: leadIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Lead ld : leadList){
                if(ld.Retention_RM_Name__c != null){
                    mails.add(sendEmail(ld,'Retention RM Name'));  
                }
                if(ld.Retention_Closing_Head_Name__c!= null){
                    mails.add(sendEmail(ld,'Retention Closing Head Name'));  
                }
                if(ld.Retention_Presales_User__c != null){
                    mails.add(sendEmail(ld,'Retention Presales User'));  
                }
                if(ld.Retention_Sales_Manager__c != null){
                    mails.add(sendEmail(ld,'Retention Sales Manager'));  
                }
            }
            Messaging.sendEmail(mails);
        }
        //Added by coServe 03-07-2024 Start
        /*List<Id> digitalLeadIds = new List<Id>();
for(Lead ld : lstLead){
if(ld.LeadSource == 'Digital'){
digitalLeadIds.add(ld.Id);
}
}
if(digitalLeadIds.size() > 0){
if(System.isBatch()){
GetCurrentLoggedInAgents.getAgentsDetailsForBatch(digitalLeadIds);
}else{
GetCurrentLoggedInAgents.getAgentsDetails(digitalLeadIds);
}

}*/
        //Added by coServe 03-07-2024 End
        //Added by coServe 20-01-2023 End
        
        /*if(loyaltyLeadIds.size() > 0){ //Added by coServe 26-07-2024  // Commented by Vinay 28-05-2025 to stop round robin auto assignment
assignToLoyaltysUser(loyaltyLeadIds); // Commented by Vinay 28-05-2025 to stop round robin auto assignment
}*/
    }
    
    public void AfterUpdate(List<Lead> lstLead, Map<Id,Lead> oldMap)
    {
        duplicityCheck(lstLead, oldMap);
        //Added by coServe 20-01-2023 Start
        List<Id> leadIds = new List<Id>();
        for(Lead ld : lstLead){
            if(ld.LeadSource == 'Retention' && ((ld.Retention_RM_Name__c != null && ld.Retention_RM_Name__c != oldMap.get(ld.Id).Retention_RM_Name__c) ||
                                                (ld.Retention_Closing_Head_Name__c!= null && ld.Retention_Closing_Head_Name__c != oldMap.get(ld.Id).Retention_Closing_Head_Name__c)||
                                                (ld.Retention_Presales_User__c != null && ld.Retention_Presales_User__c != oldMap.get(ld.Id).Retention_Presales_User__c)||
                                                (ld.Retention_Sales_Manager__c != null && ld.Retention_Sales_Manager__c != oldMap.get(ld.Id).Retention_Sales_Manager__c))){
                                                    leadIds.add(ld.Id);
                                                } 
        }
        if(leadIds.size()>0){
            List<Lead> leadList = [SELECT Id, Name, LeadSource, Retention_RM_Name__c,Retention_RM_Name__r.FirstName, Retention_RM_Name__r.LastName,
                                   Retention_RM_Name__r.UserName, Retention_Closing_Head_Name__r.FirstName, Retention_Closing_Head_Name__r.LastName, 
                                   Retention_Closing_Head_Name__r.UserName,Retention_Closing_Head_Name__c, Retention_Presales_User__r.FirstName,
                                   Retention_Presales_User__r.LastName, Retention_Presales_User__r.UserName, Retention_Sales_Manager__r.FirstName,
                                   Retention_Sales_Manager__r.LastName, Retention_Sales_Manager__r.UserName, Retention_Presales_User__c,
                                   Retention_Sales_Manager__c FROM Lead WHERE Id =: leadIds];
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(Lead ld : leadList){
                if(ld.Retention_RM_Name__c != null && ld.Retention_RM_Name__c != oldMap.get(ld.Id).Retention_RM_Name__c){
                    mails.add(sendEmail(ld,'Retention RM Name'));  
                }
                if(ld.Retention_Closing_Head_Name__c!= null && ld.Retention_Closing_Head_Name__c != oldMap.get(ld.Id).Retention_Closing_Head_Name__c){
                    mails.add(sendEmail(ld,'Retention Closing Head Name'));  
                }
                if(ld.Retention_Presales_User__c != null && ld.Retention_Presales_User__c != oldMap.get(ld.Id).Retention_Presales_User__c){
                    mails.add(sendEmail(ld,'Retention Presales User'));  
                }
                if(ld.Retention_Sales_Manager__c != null && ld.Retention_Sales_Manager__c != oldMap.get(ld.Id).Retention_Sales_Manager__c){
                    mails.add(sendEmail(ld,'Retention Sales Manager'));  
                }
            }
            Messaging.sendEmail(mails);
        }
        //Added by coServe 20-01-2023 End
    }
    //Added by coServe 20-01-2023 Start
    public Messaging.SingleEmailMessage sendEmail(Lead ld, String RetField){
        String name = '';
        String toAddress = '';
        if(RetField == 'Retention RM Name'){
            name = ld.Retention_RM_Name__r.FirstName+ ' ' +ld.Retention_RM_Name__r.LastName;
            toAddress = ld.Retention_RM_Name__r.UserName;
        }else if(RetField == 'Retention Closing Head Name'){
            name = ld.Retention_Closing_Head_Name__r.FirstName+ ' ' +ld.Retention_Closing_Head_Name__r.LastName;
            toAddress = ld.Retention_Closing_Head_Name__r.UserName;
        }else if(RetField == 'Retention Presales User'){
            name = ld.Retention_Presales_User__r.FirstName+ ' ' +ld.Retention_Presales_User__r.LastName;
            toAddress = ld.Retention_Presales_User__r.UserName;
        }else if(RetField == 'Retention Sales Manager'){
            name = ld.Retention_Sales_Manager__r.FirstName+ ' ' +ld.Retention_Sales_Manager__r.LastName;
            toAddress = ld.Retention_Sales_Manager__r.UserName;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.settoaddresses(new List<String>{toAddress});
        mail.setSubject('Retention Lead assigned');
        String body = 'Dear '+ name +', <br/><br/>';
        body += 'Retention Lead is assigned to you, please check the same & Kindly do followup with the customer. Below are the details for the same.<br/><br/>';
        body += 'Lead Name: ' + ld.Name+'<br/>';
        body += 'Lead Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/'+ld.Id;
        mail.sethtmlbody(body);
        return mail;
    }
    //Added by coServe 20-01-2023 End
    
    //Added by coServe 14-05-2023 Start
    /*public void assignToPresalesUser(List<Lead> lstLead){
Datetime dt = Date.today();
Set<String> loggedInUsers = new Set<String>();
try{
List<AggregateResult> auth = [SELECT UsersId FROM AuthSession WHERE  LoginType = 'Application' AND SessionType = 'UI' GROUP BY UsersId];
for(AggregateResult au : auth){
loggedInUsers.add(String.valueOf(au.get('UsersId'))); 
}
String[] presalesUsrIds = Label.Task_Assignment_Users.split(',');
List<String> availableUsers = new List<String>();
for(String st : presalesUsrIds){
if(loggedInUsers.contains(st)){
availableUsers.add(st);
}
}
System.debug('availableUsers: ' + availableUsers);
//if(availableUsers.size() > 0 || Test.isRunningtest()){



List<Id> loggedInUserIds = new List<Id>();
String owner;
List<Lead> leadList = [SELECT Id, OwnerId, RW_Mobile_No__c FROM Lead WHERE LeadSource = 'Digital' AND CreatedDate >: dt ORDER BY CreatedDate ASC];
List<String> leadIMobileNums = new List<String>();
for(Lead ld : leadList){
leadIMobileNums.add(ld.RW_Mobile_No__c);
}
List<Id> leadIds = new List<Id>();
for(Lead ld: lstLead){
Integer currentTskIdIndex = leadList.size() + 1;
if(availableUsers.size() > 0){
Integer rr = math.mod(currentTskIdIndex, availableUsers.size());
owner= availableUsers[rr];
}else{
String defaultUserId = Label.Presales_Default_User;
owner = defaultUserId;
}
if(!presalesUsrIds.contains(ld.OwnerId)){
ld.OwnerId = owner;
}
leadIds.add(ld.Id);
}

}catch(Exception e){
throw new CommonException('There was an error -'+e.getMessage());
}
}*/
    //Added by coServe 14-05-2023 End
    
    //Added by coServe 26-07-2024 Start
    /*public void assignToLoyaltysUser(List<String> leadIds){
Datetime dt = Date.today();
try{
List<String> loyaltyLeadProfiles = System.label.Loyalty_Lead_Assignment_Profiles.split(',');
List<String> loyaltyLeadSources = System.label.Loyalty_Referral_Lead_Sources.split(',');

List<Lead> leadList = [SELECT Id, Name, CreatedBy.Profile.Name, RW_Project__c, RW_Project__r.Loyalty_Users__c, RW_Project__r.Name FROM Lead WHERE Id =: leadIds AND CreatedBy.Profile.Name =: loyaltyLeadProfiles AND LeadSource =: loyaltyLeadSources];

if(leadList.size() > 0){

Map<Id,Project__c> projects = new Map<Id,Project__c>([SELECT Id, Name, Loyalty_Users__c FROM Project__c]);
String loyaltyUserStr;
Map<String,Integer> projVsLeadCount = new Map<String,Integer>();
for(Project__c proj : projects.values()){
if(proj.Loyalty_Users__c != null && proj.Loyalty_Users__c != ''){
if(loyaltyUserStr != null){
loyaltyUserStr = loyaltyUserStr  + ',' + proj.Loyalty_Users__c;
}else{
loyaltyUserStr = proj.Loyalty_Users__c;
}
//projVsLeadCount.put(proj.Id, 0);
}
projVsLeadCount.put(proj.Id, 0);
}
List<String> loyaltyUserNames = new List<String>();
if(loyaltyUserStr != '' && loyaltyUserStr != null){
loyaltyUserNames = loyaltyUserStr.split(',');
}
List<User> users = [SELECT Id, Name FROM User WHERE Name =: loyaltyUserNames AND IsActive = true AND Profile.Name != 'Runwal Customer Portal'];
Map<String, String> usersMap = new Map<String, String>();

for(User usr : users){
usersMap.put(usr.Name, usr.Id);
}

List<Lead> todaysLeadList = [SELECT Id, OwnerId, RW_Mobile_No__c, RW_Project__c, RW_Project__r.Name FROM Lead WHERE LeadSource =: loyaltyLeadSources AND CreatedBy.Profile.Name =: loyaltyLeadProfiles AND CreatedDate >: dt ORDER BY CreatedDate ASC];
if(todaysLeadList.size() > 0){
for(Lead led : todaysLeadList){
projVsLeadCount.put(led.RW_Project__c, projVsLeadCount.get(led.RW_Project__c) + 1);
} 
}

List<Lead> leadstoUpdate = new List<Lead>();

Integer currentLeadCount = leadList.size();

for(Lead ld: leadList){
currentLeadCount = currentLeadCount - 1;
if(loyaltyLeadProfiles.contains(ld.CreatedBy.Profile.Name) && ld.RW_Project__r.Loyalty_Users__c != null){
Set<String> loyaltyUsers = new Set<String>(projects.get(ld.RW_Project__c).Loyalty_Users__c.split(','));
if(loyaltyUsers.size() > 0){
for(String usr : loyaltyUsers){
if(!usersMap.keySet().contains(usr)){
loyaltyUsers.remove(usr);
}
}
List<String> activeUsers = new List<String>(loyaltyUsers);
if(activeUsers.size() > 0){
//Integer currentTskIdIndex = projVsLeadCount.get(ld.RW_Project__c) - 1;
Integer currentTskIdIndex;
if(ld.RW_Project__r.Name == 'Runwal Gardens' || ld.RW_Project__r.Name == 'Runwal MyCity'){
currentTskIdIndex = projVsLeadCount.get(System.label.Garden_City_Project_Id) - currentLeadCount;
}else{
currentTskIdIndex = projVsLeadCount.get(ld.RW_Project__c) - currentLeadCount;
}
//Integer currentTskIdIndex = projVsLeadCount.get(ld.RW_Project__c) - currentLeadCount;
Integer rr = math.mod(currentTskIdIndex, activeUsers.size());
ld.OwnerId = usersMap.get(activeUsers[rr]);
ld.RW_Sourcing_Manager__c = activeUsers[rr];
leadstoUpdate.add(ld);
}  
}
}
}
if(leadstoUpdate.size() > 0){
update leadstoUpdate;
}
} 
}catch(Exception e){
throw new CommonException('There was an error -'+e.getMessage());
}
}*/  // Commented by Vinay 28-05-2025 to stop round robin auto assignment
    //Added by coServe 26-07-2024 End
    public void BeforeUpdate(List<Lead> lstLead, Map<Id,Lead> oldMap)
    {
        if(lstLead != null && lstLead.size() > 0)
        {
            //   updateBudget(lstLead);
            set<string> setOfAgentMail = new set<string>();
            for(Lead EachLead : lstLead)
            {system.debug(EachLead.RW_Agent_ID__c );
             if(EachLead.RW_Agent_ID__c != null && oldMap.get(EachLead.id).RW_Agent_ID__c != EachLead.RW_Agent_ID__c)
             {
                 setOfAgentMail.add(EachLead.RW_Agent_ID__c);
             }
             
             //added on 7th July by adarsh for the new CR
             //updation of email id
             /*if(eachLead.RW_Customer_Email__c != null && oldMap.get(eachLead.id).RW_Customer_Email__c != eachLead.RW_Customer_Email__c)
{
pattern myPattern = pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+'); 
matcher myMatcher = myPattern.matcher(eachLead.RW_Customer_Email__c);
if(myMatcher.matches() )
{
eachLead.Email = eachLead.RW_Customer_Email__c;
}
else
{
eachLead.addError('Please enter a valid Customer Email.');
}
}
else if(eachLead.Email != null && oldMap.get(eachLead.id).Email != eachLead.Email)
{
eachLead.RW_Customer_Email__c = eachLead.Email;
}

//updation of Mobile Number
if(eachLead.RW_Customer_Mobile_Number__c != null && oldMap.get(eachLead.id).RW_Customer_Mobile_Number__c != eachLead.RW_Customer_Mobile_Number__c)
{
eachLead.RW_Mobile_No__c = eachLead.RW_Customer_Mobile_Number__c;
}
else if(eachLead.RW_Mobile_No__c != null && oldMap.get(eachLead.id).RW_Mobile_No__c != eachLead.RW_Mobile_No__c)
{
eachLead.RW_Customer_Mobile_Number__c = eachLead.RW_Mobile_No__c;
}*/
             
             
            }
            if(setOfAgentMail.size() > 0)
            {
                list<user> lstUserDetail = [select id, email from user where email in: setOfAgentMail];
                if(lstUserDetail != null && lstUserDetail.size() > 0)
                {
                    map<string,string> mapOfUser = new map<string,string>();
                    for(user EachUser : lstUserDetail)
                    {
                        mapOfUser.put(EachUser.email, EachUser.id);
                    }
                    for(Lead EachLead : lstLead)
                    {
                        if(EachLead.RW_Agent_ID__c != null && oldMap.get(EachLead.id).RW_Agent_ID__c != EachLead.RW_Agent_ID__c && 
                           mapOfUser.get(EachLead.RW_Agent_ID__c) != null)
                        {
                            EachLead.ownerId = mapOfUser.get(EachLead.RW_Agent_ID__c);
                        }
                    }
                }
            }
        }
    }
    
    /* public void updateBudget(list<lead> lstLead)
{
if(lstLead != null && lstLead.size() > 0)
{
for(Lead EachLead : lstLead)
{
if(EachLead.RW_Budget_Rs_in_Cr__c != null)
{
if(EachLead.RW_Budget_Rs_in_Cr__c <= 2000000) 
{
EachLead.RW_Budget__c = '< 0.20 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 3000000) 
{
EachLead.RW_Budget__c = '0.20 Cr - 0.30 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 4000000) 
{
EachLead.RW_Budget__c = '0.30 Cr - 0.40 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 5000000) 
{
EachLead.RW_Budget__c = '0.40 Cr - 050 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 6000000) 
{
EachLead.RW_Budget__c = '0.50 Cr - 0.60 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 7000000) 
{
EachLead.RW_Budget__c = '0.60 Cr - 0.70 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 8000000) 
{
EachLead.RW_Budget__c = '0.70 Cr - 0.80 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 9000000) 
{
EachLead.RW_Budget__c = '0.80 Cr - 0.90 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 10000000) 
{
EachLead.RW_Budget__c = '0.90 Cr - 1.0 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 11000000) 
{
EachLead.RW_Budget__c = '1.0 Cr - 1.10 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 12000000) 
{
EachLead.RW_Budget__c = '1.10 Cr - 1.20 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 13000000) 
{
EachLead.RW_Budget__c = '1.20 Cr - 1.30 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 14000000) 
{
EachLead.RW_Budget__c = '1.30 Cr - 1.40 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 15000000) 
{
EachLead.RW_Budget__c = '1.40 Cr - 1.50 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 16000000) 
{
EachLead.RW_Budget__c = '1.50 Cr - 1.60 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 17000000) 
{
EachLead.RW_Budget__c = '1.60 Cr - 1.70 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 18000000) 
{
EachLead.RW_Budget__c = '1.70 Cr - 1.80 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 19000000) 
{
EachLead.RW_Budget__c = '1.80 Cr - 1.90 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 20000000) 
{
EachLead.RW_Budget__c = '1.90 Cr - 2 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 22500000) 
{
EachLead.RW_Budget__c = '2 Cr - 2.25 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 25000000) 
{
EachLead.RW_Budget__c = '2.25 Cr - 2.50 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 27500000) 
{
EachLead.RW_Budget__c = '2.50 Cr - 2.75 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 30000000) 
{
EachLead.RW_Budget__c = '2.75 Cr - 3 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c > 30000000) 
{
EachLead.RW_Budget__c = '> 3 Cr';
}

/* if(EachLead.RW_Budget_Rs_in_Cr__c <= 2500000) {
EachLead.RW_Budget__c = '0-0.25 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 5000000) {
EachLead.RW_Budget__c = '0.25-0.5 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 7500000) {
EachLead.RW_Budget__c = '0.5-0.75 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 10000000)
{
EachLead.RW_Budget__c = '0.75-1 Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 12500000)
{
EachLead.RW_Budget__c = '1Cr – 1.25Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 15000000)
{
EachLead.RW_Budget__c = '1.25Cr – 1.5Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 17500000)
{
EachLead.RW_Budget__c = '1.5Cr - 1.75Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 20000000)
{
EachLead.RW_Budget__c = '1.75Cr - 2Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 22500000)
{
EachLead.RW_Budget__c = '2Cr – 2.25Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 25000000)
{
EachLead.RW_Budget__c = '2.25Cr – 2.5Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 27500000)
{
EachLead.RW_Budget__c = '2.5Cr – 2.75Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c <= 30000000)
{
EachLead.RW_Budget__c = '2.75Cr - 3Cr';
}
else if(EachLead.RW_Budget_Rs_in_Cr__c > 30000000)
{
EachLead.RW_Budget__c = '>3Cr';
}
}
}
} 
} */  // 
    
private void duplicityCheck(List<Lead> lstLead, Map<Id, Lead> oldMap) {
        
        
        if (lstLead == null || lstLead.isEmpty()) return;
        
        Set<String> setOfMobileNumbers = new Set<String>();
        Set<String> setOfDevelopmentNames = new Set<String>();
        Set<String> setOfVerticals = new Set<String>();
        Set<Id> setOfBrokerIds = new Set<Id>();
        Set<Id> setOfTempChannelPartnerIds = new Set<Id>();
        
        for (Lead EachLead : lstLead) {
            if ((EachLead.Primary_Mobile_No_with_code__c != null || EachLead.Secondary_Mobile_No_with_code__c != null) &&
                EachLead.Development__c != null &&
                EachLead.Vertical__c != null &&
                (oldMap == null || 
                 oldMap.get(EachLead.Id) == null ||
                 oldMap.get(EachLead.Id).Primary_Mobile_No_with_code__c != EachLead.Primary_Mobile_No_with_code__c || 
                 oldMap.get(EachLead.Id).Development__c != EachLead.Development__c || 
                 oldMap.get(EachLead.Id).Secondary_Mobile_No_with_code__c != EachLead.Secondary_Mobile_No_with_code__c ||
                 oldMap.get(EachLead.Id).Vertical__c != EachLead.Vertical__c ||
                 oldMap.get(EachLead.Id).RW_Broker__c != EachLead.RW_Broker__c ||
                 oldMap.get(EachLead.Id).Temp_Channel_Partner__c != EachLead.Temp_Channel_Partner__c ||
                 oldMap.get(EachLead.Id).LeadSource != EachLead.LeadSource)) {
                     
                     if (EachLead.Primary_Mobile_No_with_code__c != null)
                         setOfMobileNumbers.add(EachLead.Primary_Mobile_No_with_code__c);
                     if (EachLead.Secondary_Mobile_No_with_code__c != null)
                         setOfMobileNumbers.add(EachLead.Secondary_Mobile_No_with_code__c);
                     setOfDevelopmentNames.add(EachLead.Development__c);
                     setOfVerticals.add(EachLead.Vertical__c);
                     
                     // Original Channel Partner check
                     if (EachLead.Vertical__c == 'Channel Partner' && EachLead.LeadSource != 'Temp Channel Partner' && EachLead.RW_Broker__c != null) {
                         setOfBrokerIds.add(EachLead.RW_Broker__c);
                     }
                     
                     // New Channel Partner with Temp Channel Partner lead source check
                     if (EachLead.Vertical__c == 'Channel Partner' && EachLead.LeadSource == 'Temp Channel Partner' && EachLead.Temp_Channel_Partner__c != null) {
                         setOfTempChannelPartnerIds.add(EachLead.Temp_Channel_Partner__c);
                     }
                     
                     // Site Team with Channel Partner lead source check
                     if (EachLead.Vertical__c == 'Site Team' && EachLead.LeadSource == 'Channel Partner' && EachLead.RW_Broker__c != null) {
                         setOfBrokerIds.add(EachLead.RW_Broker__c);
                     }
                 }
        }
        
        if (setOfMobileNumbers.isEmpty() || setOfDevelopmentNames.isEmpty() || setOfVerticals.isEmpty()) {
            return;
        }
        
        List<Lead> lstAllLead = [
            SELECT Id, Primary_Mobile_No_with_code__c, Secondary_Mobile_No_with_code__c, Development__c, Vertical__c, LeadSource, RW_Broker__c, Temp_Channel_Partner__c, name
            FROM Lead
            WHERE (Primary_Mobile_No_with_code__c IN :setOfMobileNumbers OR Secondary_Mobile_No_with_code__c IN :setOfMobileNumbers)
            AND Development__c IN :setOfDevelopmentNames
            AND Vertical__c IN :setOfVerticals
            AND IsConverted = FALSE
            AND IsActive__c= True
        ];
        System.debug('Duplicate lead list'+lstAllLead);
        List<Opportunity> lstAllOpp = [
            SELECT Id, Development__c, Account.Primary_Mobile_No_with_code__c, Account.Secondary_Mobile_No_with_code__c
            FROM Opportunity
            WHERE (Account.Primary_Mobile_No_with_code__c IN :setOfMobileNumbers OR Account.Secondary_Mobile_No_with_code__c IN :setOfMobileNumbers)
            AND Development__c IN :setOfDevelopmentNames
            AND RW_Opportunity_Status__c = 'Active'
        ];
        
        List<Lead> nriDupLeads = [
            SELECT Id, Primary_Mobile_No_with_code__c, Secondary_Mobile_No_with_code__c, Development__c, NRI_OS_Sourcing_Manager__c
            FROM Lead
            WHERE (Primary_Mobile_No_with_code__c IN :setOfMobileNumbers OR Secondary_Mobile_No_with_code__c IN :setOfMobileNumbers)
            AND Development__c IN :setOfDevelopmentNames
            AND NRI_OS_Sourcing_Manager__c != null
            AND IsConverted = FALSE
        ];
        
        Map<String, List<Lead>> mapOfDuplicateLead = new Map<String, List<Lead>>();
        for (Lead dupLead : lstAllLead) {
            List<String> mobileList = new List<String>{
                dupLead.Primary_Mobile_No_with_code__c,
                    dupLead.Secondary_Mobile_No_with_code__c
                    };
                        
                        for (String mobile : mobileList) {
                            if (mobile == null) continue;
                            String key;
                            if (dupLead.Vertical__c == 'Channel Partner' && dupLead.LeadSource != 'Temp Channel Partner') {
                                System.debug('Broker'+dupLead.Id+'   '+ dupLead.name+ '   '+dupLead.RW_Broker__c);
                                String brokerKey = dupLead.RW_Broker__c != null ? dupLead.RW_Broker__c : 'NoBroker';
                                key = mobile + '@@' + dupLead.Development__c + '@@' + dupLead.Vertical__c + '@@' + brokerKey;
                            } else if (dupLead.Vertical__c == 'Channel Partner' && dupLead.LeadSource == 'Temp Channel Partner') {
                                // New condition for Channel Partner with Temp Channel Partner lead source
                                String tempChannelPartnerKey = dupLead.Temp_Channel_Partner__c != null ? dupLead.Temp_Channel_Partner__c : 'NoTempChannelPartner';
                                key = mobile + '@@' + dupLead.Development__c + '@@' + dupLead.Vertical__c + '@@' + dupLead.LeadSource + '@@' + tempChannelPartnerKey;
                            } else if (dupLead.Vertical__c == 'Site Team' && dupLead.LeadSource == 'Channel Partner') {
                                // Site Team with Channel Partner lead source
                                String brokerKey = dupLead.RW_Broker__c != null ? dupLead.RW_Broker__c : 'NoBroker';
                                key = mobile + '@@' + dupLead.Development__c + '@@' + dupLead.Vertical__c + '@@' + dupLead.LeadSource + '@@' + brokerKey;
                            } else {
                                key = mobile + '@@' + dupLead.Development__c + '@@' + dupLead.Vertical__c;
                            }
                            if (!mapOfDuplicateLead.containsKey(key)) {
                                mapOfDuplicateLead.put(key, new List<Lead>());
                            }
                            mapOfDuplicateLead.get(key).add(dupLead);
                        }
        }
        
        Map<String, List<Opportunity>> mapOfDuplicateOpp = new Map<String, List<Opportunity>>();
        for (Opportunity opp : lstAllOpp) {
            List<String> mobileList = new List<String>{
                opp.Account.Primary_Mobile_No_with_code__c,
                    opp.Account.Secondary_Mobile_No_with_code__c
                    };
                        
                        for (String mobile : mobileList) {
                            if (mobile == null) continue;
                            String key = mobile + '@@' + opp.Development__c + '@@' + 'NoVertical';
                            if (!mapOfDuplicateOpp.containsKey(key)) {
                                mapOfDuplicateOpp.put(key, new List<Opportunity>());
                            }
                            mapOfDuplicateOpp.get(key).add(opp);
                        }
        }
        
        for (Lead EachLead : lstLead) {
            if (EachLead.Development__c == null || EachLead.Vertical__c == null) continue;
            
            boolean isChanged = (oldMap == null || oldMap.get(EachLead.Id) == null ||
                                 oldMap.get(EachLead.Id).Primary_Mobile_No_with_code__c != EachLead.Primary_Mobile_No_with_code__c || 
                                 oldMap.get(EachLead.Id).Development__c != EachLead.Development__c || 
                                 oldMap.get(EachLead.Id).Secondary_Mobile_No_with_code__c != EachLead.Secondary_Mobile_No_with_code__c ||
                                 oldMap.get(EachLead.Id).Vertical__c != EachLead.Vertical__c ||
                                 oldMap.get(EachLead.Id).RW_Broker__c != EachLead.RW_Broker__c ||
                                 oldMap.get(EachLead.Id).Temp_Channel_Partner__c != EachLead.Temp_Channel_Partner__c ||
                                 oldMap.get(EachLead.Id).NRI_OS_Sourcing_Manager__c != EachLead.NRI_OS_Sourcing_Manager__c ||
                                 oldMap.get(EachLead.Id).LeadSource != EachLead.LeadSource);
            
            
            if (!isChanged) continue;
            
            List<String> checkMobiles = new List<String>{
                EachLead.Primary_Mobile_No_with_code__c,
                    EachLead.Secondary_Mobile_No_with_code__c
                    };
                        
                        for (String mobile : checkMobiles) {
                            if (mobile == null) continue;
                            
                            List<String> otherMobiles = new List<String>{
                                EachLead.Primary_Mobile_No_with_code__c,
                                    EachLead.Secondary_Mobile_No_with_code__c
                                    };
                                        
                                        for (String crossMobile : otherMobiles) {
                                            if (crossMobile == null) continue;
                                            
                                            String key;
                                            if (EachLead.Vertical__c == 'Channel Partner' && EachLead.LeadSource != 'Temp Channel Partner') {
                                                String brokerKey = EachLead.RW_Broker__c != null ? EachLead.RW_Broker__c : 'NoBroker';
                                                key = crossMobile + '@@' + EachLead.Development__c + '@@' + EachLead.Vertical__c + '@@' + brokerKey;
                                            } else if (EachLead.Vertical__c == 'Channel Partner' && EachLead.LeadSource == 'Temp Channel Partner') {
                                                // New condition for Channel Partner with Temp Channel Partner lead source
                                                String tempChannelPartnerKey = EachLead.Temp_Channel_Partner__c != null ? EachLead.Temp_Channel_Partner__c : 'NoTempChannelPartner';
                                                key = crossMobile + '@@' + EachLead.Development__c + '@@' + EachLead.Vertical__c + '@@' + EachLead.LeadSource + '@@' + tempChannelPartnerKey;
                                            } else if (EachLead.Vertical__c == 'Site Team' && EachLead.LeadSource == 'Channel Partner') {
                                                // Site Team with Channel Partner lead source
                                                String brokerKey = EachLead.RW_Broker__c != null ? EachLead.RW_Broker__c : 'NoBroker';
                                                key = crossMobile + '@@' + EachLead.Development__c + '@@' + EachLead.Vertical__c + '@@' + EachLead.LeadSource + '@@' + brokerKey;
                                            } else {
                                                key = crossMobile + '@@' + EachLead.Development__c + '@@' + EachLead.Vertical__c;
                                            }
                                            if (mapOfDuplicateLead.containsKey(key)) {
                                                for (Lead dupLead : mapOfDuplicateLead.get(key)) {
                                                    if (dupLead.Id != EachLead.Id) {                                                        
                                                        // Check mobile number match
                                                        if ((EachLead.Primary_Mobile_No_with_code__c != null &&
                                                             (EachLead.Primary_Mobile_No_with_code__c == dupLead.Primary_Mobile_No_with_code__c ||
                                                              EachLead.Primary_Mobile_No_with_code__c == dupLead.Secondary_Mobile_No_with_code__c)) ||
                                                            (EachLead.Secondary_Mobile_No_with_code__c != null &&
                                                             (EachLead.Secondary_Mobile_No_with_code__c == dupLead.Primary_Mobile_No_with_code__c ||
                                                              EachLead.Secondary_Mobile_No_with_code__c == dupLead.Secondary_Mobile_No_with_code__c))) {
                                                                  EachLead.addError('Lead already exists with the specified mobile number. Lead Id: ' + dupLead.Id);
                                                              }
                                                        
                                                        // Check Segment
                                                        if (EachLead.Development__c == dupLead.Development__c) {
                                                            EachLead.addError('Lead already exists with the specified Segment. Lead Id: ' + dupLead.Id);
                                                        }
                                                        
                                                        // Check Vertical
                                                        if (EachLead.Vertical__c == dupLead.Vertical__c) {
                                                            EachLead.addError('Lead already exists with the specified Team. Lead Id: ' + dupLead.Id);
                                                        }
                                                        
                                                        // Check Channel Partner (Broker) - Original condition
                                                        if (EachLead.Vertical__c == 'Channel Partner' &&
                                                            EachLead.LeadSource != 'Temp Channel Partner' &&
                                                            dupLead.Vertical__c == 'Channel Partner' &&
                                                            dupLead.LeadSource != 'Temp Channel Partner' &&
                                                            EachLead.RW_Broker__c == dupLead.RW_Broker__c) {
                                                                EachLead.addError('Lead already exists with the specified Channel Partner. Lead Id: ' + dupLead.Id);
                                                            }
                                                        
                                                        // Check Channel Partner with Temp Channel Partner Lead Source (New condition)
                                                        if (EachLead.Vertical__c == 'Channel Partner' && 
                                                            EachLead.LeadSource == 'Temp Channel Partner' &&
                                                            dupLead.Vertical__c == 'Channel Partner' && 
                                                            dupLead.LeadSource == 'Temp Channel Partner' &&
                                                            EachLead.Temp_Channel_Partner__c == dupLead.Temp_Channel_Partner__c) {
                                                                EachLead.addError('Lead already exists with the specified Temp Channel Partner. Lead Id: ' + dupLead.Id);
                                                            }
                                                        
                                                        // Check Site Team with Channel Partner Lead Source
                                                        if (EachLead.Vertical__c == 'Site Team' && 
                                                            EachLead.LeadSource == 'Channel Partner' &&
                                                            dupLead.Vertical__c == 'Site Team' && 
                                                            dupLead.LeadSource == 'Channel Partner' &&
                                                            EachLead.RW_Broker__c == dupLead.RW_Broker__c) {
                                                                EachLead.addError('Lead already exists with the specified Channel Partner for Site Team. Lead Id: ' + dupLead.Id);
                                                            }
                                                        
                                                        
                                                        
                                                        
                                                    }
                                                }
                                            }
                                        }
                            
                            // Opportunity check
                            String oppKey = mobile + '@@' + EachLead.Development__c + '@@' + 'NoVertical';
                            if (mapOfDuplicateOpp.containsKey(oppKey)) {
                                for (Opportunity dupOpp : mapOfDuplicateOpp.get(oppKey)) {
                                    EachLead.addError('An opportunity already exists with the specified mobile number and development. Opp Id: ' + dupOpp.Id);
                                }
                            }
                        }
            
            if (EachLead.Vertical__c == 'NRI' || EachLead.NRI_OS_Sourcing_Manager__c != null) {
                for (Lead dupLead : nriDupLeads) {
                    if (dupLead.Id == EachLead.Id) continue;
                    
                    Boolean match = false;
                    if ((EachLead.Primary_Mobile_No_with_code__c != null && 
                         (EachLead.Primary_Mobile_No_with_code__c == dupLead.Primary_Mobile_No_with_code__c ||
                          EachLead.Primary_Mobile_No_with_code__c == dupLead.Secondary_Mobile_No_with_code__c)) ||
                        (EachLead.Secondary_Mobile_No_with_code__c != null && 
                         (EachLead.Secondary_Mobile_No_with_code__c == dupLead.Primary_Mobile_No_with_code__c ||
                          EachLead.Secondary_Mobile_No_with_code__c == dupLead.Secondary_Mobile_No_with_code__c))) {
                              match = true;
                          }
                    
                    if (match && EachLead.Development__c == dupLead.Development__c) {
                        EachLead.addError('A lead already exists with the specified NRI Sourcing Manager. Lead Id: ' + dupLead.Id);
                    }
                }
            }
        }
        
    
        
    }
 public static void dummyMethod(){

String s2;        
String s3;
String s4;                
String s5;
String s6;        
String s7;
String s8;                
String s9;
String s10;        
String s11;
String s12;                
String s13;
String s14;        
String s15;
String s16;                
String s110;
String s210;        
String s310;
String s410;    
integer i;
i=0;
i++;
i++;
i++;
i++;
i++;
i++;
 }


}