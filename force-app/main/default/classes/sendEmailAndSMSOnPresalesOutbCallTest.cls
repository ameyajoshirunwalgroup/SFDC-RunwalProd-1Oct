@isTest
public class sendEmailAndSMSOnPresalesOutbCallTest {
    
    @testSetup
    private static void sendEmailAndSMSOnPresalesOutbCallTest() 
    {   
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
  
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p.id
                            );
         insert tuser;
      
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        objpr.RW_Project_Brochure_ID__c = '0696D000000ZaCSQA0';
        objpr.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        objpr.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        objpr.Site_Address_Map_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account acc = new Account();
        acc.FirstName ='TestAccount1';
        acc.LastName ='TestAccount2';
        acc.PersonEmail = 'wc@email.com';
        acc.City__c='TestCity';
        acc.RW_Zip_Code__c = '999999';
        acc.State__c ='Karnataka';
        acc.Country__c ='India';
        acc.Mobile_No__c = '9876543212';
        acc.Alternate_Email__c = 'wc1@email.com';
        acc.Gender__c='Male';
        acc.Salutation = 'Mr.';
        acc.Birth_Date__c = System.today().addYears(-20);   
        insert acc;
        
       
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=acc.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = acc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.RW_Mobile_No__c = '1221122100';
        oppRec.LeadSource = 'Direct';
      
        insert oppRec;
        Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Reference';
        objLead.LeadSource = 'Direct';
        //objLead.RW_Reference_Source__c = 'Existing Customer Reference';
        objLead.RW_Lead_Sub_Source__c = 'Existing client reference';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = acc.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        insert objLead;
        
        Task taskCreate = new Task(whoId = objLead.Id,Status = 'Completed',Priority = 'Normal',
                                   Subject = 'Dummy subject' ,ActivityDate = system.today(),
                                  Communication_Type__c ='Outbound Call', Call_Status__c ='Ringing');
		insert taskCreate;
        
    }
    @isTest
    private static void testMethod1() 
    {   
        List<Opportunity>  oppList = [SELECT Id,RW_Email__c,Name,Project_Name__c,RW_Project__r.RW_Project_Brochure_ID__c,
                     RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,
                     RW_Project__r.Site_Address_Map_Link__c FROM Opportunity Limit 1];
        RW_Presales_Communication__c presaleComm = new RW_Presales_Communication__c();
        presaleComm.RW_Opportunity__c = oppList[0].Id;
        presaleComm.RW_Project_Details_Mode_of_Communication__c = 'Email';
        insert presaleComm;  
        List<Lead> objLead = [Select id,Email,RW_Mobile_No__c From Lead limit 1];
        sendEmailAndSMSOnPresalesOutboundCall sendEmail = new sendEmailAndSMSOnPresalesOutboundCall();
        SendSMSWhatsAppOnVisitConfirmed visiCon = new SendSMSWhatsAppOnVisitConfirmed();
        sendEmail.sendSMSToLead(objLead[0]);
        sendEmail.sendEmailToLead(objLead[0]);
    }
     @isTest
    private static void testMethod2() 
    {   
      
        List<Lead> objLead = [Select id,Email,RW_Mobile_No__c,LeadSource From Lead limit 1];
        List<Opportunity> objOpp = [Select id,RW_Mobile_No__c,LeadSource From Opportunity limit 1];
        Project__c prj = [Select id,name From Project__c limit 1];
        List<Task> listTask = new List<Task>();
        Task taskCreateLed = new Task(whoId = objLead[0].Id,Priority = 'Normal',Call_Proposed_date_of_visit__c = system.today(),
                                   Subject = 'Presales Call' ,ActivityDate = system.today(), Project__c = prj.id,RW_Call_Timing__c = System.Now(),
                                  Communication_Type__c ='Outbound Call', Call_Status__c ='Visit Confirmed',Next_Action_Date__c=system.today(),
                                  Task_Type__c = 'Presales Call');
	    listTask.add(taskCreateLed);
        Task taskCreateOpp = new Task(whatId = objOpp[0].Id,Priority = 'Normal',Call_Proposed_date_of_visit__c = system.today(),
                                   Subject = 'Presales Call' ,ActivityDate = system.today(), Project__c = prj.id,Next_Action_Date__c=system.today(),
                                  Communication_Type__c ='Outbound Call', Call_Status__c ='Visit Confirmed',RW_Call_Timing__c = System.Now(),
                                  Task_Type__c = 'Presales Call');

        listTask.add(taskCreateOpp);
        insert listTask;
       List<Task> tskLst = [select id,Communication_Type__c, Call_Status__c, Call_Proposed_date_of_visit__c, Call_Attempt_Status__c, 
                    Project__c,Project__r.Name,ActivityDate, whoId, Call_Time__c,Task_Type__c,ActivityDate__c,Next_Action_Date__c
                    from Task Limit 2];
        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SendSMSWhatsAppOnVisitConfirmed.SMSWhatsAppOnVisitConfirmed(new List<Id> {listTask[0].id});
        SendSMSWhatsAppOnVisitConfirmed.SMSWhatsAppOnVisitConfirmed(new List<Id> {listTask[1].id});
        Test.stopTest();
        
       
        
    }
}