@isTest
public class TestREST_CallbackCTI {
    
    @isTest
    private static void TestCreateEnquiry(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
            FirstName='Test1 User',
            Alias = 'tstU1',
            Email = 'testUsr1@stetig.in',
            Username = 'testUsr1@stetig.in',
            ProfileId = profileId.id,
            CTI_Agent_ID__c = 'test.test1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
            lstUser.add(new User(LastName = 'Test2',
            FirstName='Test User2',
            Alias = 'tstU2',
            Email = 'testUsr2@stetig.in',
            Username = 'testUsr2@stetig.in',
            ProfileId = profileId.id,
            department='presales',
            CTI_Agent_ID__c = 'test.test2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
            
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Mobile_No__c = '9879976656';
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
       
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = p.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09879976656\", \"PhoneName\": \"Pranay\", \"Skill\": \"runwal\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
     
        REST_CallbackCTI.CreateEnquiry();         
    }

    @isTest
    private static void TestCreateEnquiry1(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Phone = '4567569354'));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Mobile_No__c = '9879976656';
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = p.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09879976656\", \"PhoneName\": \"Pranay\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"Answered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();         
    }    
    
    @isTest
    private static void TestCreateEnquiry2(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                             Phone = '4567569354'));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Mobile_No__c = '9879976656';
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = p.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09879976656\", \"PhoneName\": \"Pranay\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"ONLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
          
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();         
    }
    
    @isTest(SeeAllData = false)
    private static void TestCreateEnquiry3(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Phone = '4567569354',
                             Offline_Agent_Name__c = 'Pranay'
                            ));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Mobile_No__c = '9879976656';
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = p.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"'+objOpportunity.id+'\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09879976656\", \"PhoneName\": \"Pranay -> Test\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"OFFLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();         
    }
    
    @isTest(SeeAllData=false)
    private static void TestCreateEnquiry4(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Phone = '4567569354',
                             Offline_Agent_Name__c = 'Pranay'
                            ));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
       Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = objProject.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"'+objLead.id+'\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"09879976656\", \"PhoneName\": \"Pranay -> Test\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"OFFLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
          
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();         
    }
    
    @isTest(SeeAllData = false)
    private static void TestCreateEnquiry5(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Phone = '4567569354',
                             Offline_Agent_Name__c = 'Pranay'
                            ));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Account Accnt = new Account(              
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678',
            Mobile_No__c = '1324235431',
            RM_Name__c = 'Testing1'
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Mobile_No__c = '9879976656';
        objOpportunity.StageName = 'Unit Booked'; 
        objOpportunity.RW_Sales_Associate__c = 'Test1 User Test';
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = p.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"009879976656\", \"PhoneName\": \"Pranay -> Test\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"OFFLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();         
    }
    
    @isTest(SeeAllData=false)
    private static void TestCreateEnquiry6(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Sales Manager' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                            Phone = '4567569354',
                             Offline_Agent_Name__c = 'Pranay'
                            ));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
       Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = objProject.Id);
        insert campaign;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"009243562121\", \"PhoneName\": \"Pranay -> Test\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"OFFLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
          
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();  
         REST_CallbackCTI.dummyMethod();
    }
      
	@isTest(SeeAllData=false)
    private static void TestCreateEnquiry7(){
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        String json = '{\"national\": \"08983115723\",\"monitorUCID\": \"1929157114451262\", \"UUI\": \"\", \"Did\": \"918068442375\", \"CampaignName\": \"Inbound_918068442375\", \"Location\": \"Mumbai\", \"CallerID\": \"009243562121\", \"PhoneName\": \"Pranay -> Test\", \"Skill\": \"runwal,4567569354\", \"StartTime\": \"2018-04-24 12:36:19\", \"EndTime\": \"2018-04-24 12:37:44\", \"TimeToAnswer\": \"\", \"CallDuration\": \"00:01:25\", \"Duration\": \"00:00:00\", \"FallBackRule\": \"AgentDial\", \"DialedNumber\": \"9021134576\", \"Type\": \"inbound\", \"AgentID\": \"Agent1\", \"AgentPhoneNumber\": \"3457468574\", \"AgentUniqueID\": \"93890\", \"AgentName\": \"Agent1\", \"Disposition\": \"\", \"HangupBy\": \"UserHangup\", \"Status\": \"NotAnswered\", \"AudioFile\": \"\", \"TransferType\": \"No Transfers\", \"TransferredTo\": \"\", \"Comments\": \"\", \"DialStatus\": \"user_disconnected\", \"Apikey\": \"KKdcdd1b0768911fc065fc0432268d034b\", \"AgentStatus\": \"\", \"CustomerStatus\": \"\", \"UserName\": \"\", \"CallerConfAudioFile\": \"\", \"ConfDuration\": \"00:00:00\", \"CampaignStatus\": \"OFFLINE\",\"countryCode\":\"+91\"}}';
        res.responseBody = Blob.valueOf(json);
        req.requestURI =  System.label.Site_Url_New + '/Callback1/services/apexrest/Integration/Callback1/' ; //Updated the link by Vinay 23-06-2025
          
        req.httpMethod = 'POST';
        req.addParameter('data', json);    
        RestContext.request = req;
        RestContext.response = res;
        
        REST_CallbackCTI.CreateEnquiry();  
         REST_CallbackCTI.dummyMethod();
        REST_CallbackCTI.createERPlog(json,'','','Test');
    }
}