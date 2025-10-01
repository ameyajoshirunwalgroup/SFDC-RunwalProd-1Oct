@isTest
public class EOITestClass 
{
	@testSetup
    private static void EOITest() 
    {
		
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    	/*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;*/
        
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
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);   
        insert a;
        
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;

        Receipt__c receipt = new Receipt__c();
        receipt.Cheque_DD_Amount_Rs__c = 200000;
        receipt.Cheque_DD__c = '908888';
        receipt.Cheque_DD_Date__c = system.today();
        receipt.Project__c = objpr.Id;
        receipt.Opportunity__c = oppRec.Id;
        receipt.CheckReceipt__c = true;
        receipt.Token_Amount_Receipt__c = true;
        receipt.Physically_Cheque_Received__c = true;
        receipt.Approval_Status__c = 'Approved';
        receipt.Receipt_Date__c = system.today();
        receipt.DraweeBank__c = 'Axis Bank';
        receipt.Total_Amount__c = 200000;
        receipt.Currency__c = 'Indian Rupee';
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c =9000;
        receipt.Mode__c ='Digital';
        receipt.RW_Payment_Collection_Type__c = 'EOI';
        insert receipt;       
        
       
    }
    
    @isTest
    private static void testsendEOILink() 
    {
        try
        {
        Map<String,String> offerMapValues = new Map<String,String>();
        offerMapValues.put('subofferName','TestSubOffer');
        offerMapValues.put('offerName','TestOffer');
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        Decimal Amount = 90000;
        String offerType ='EOI';
        String paymentGateway ='BillDesk';
            
        EOIController.sendEOILink(oppRecords[0].Id, Amount, towerRecords[0].id, offerMapValues, paymentGateway);
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        
        EOIController.sendEOILink(oppRecords[0].Id, Amount, towerRecords[0].id, offerMapValues, paymentGateway);
            
        }
        
        catch(Exception e)
        {
            System.debug('Exception'+e);
        }
 
    }
    
    
    @isTest
    private static void testgetDecryptedData() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        Decimal Amount = 90000;
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        insert eoiRecord;
        
                RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        
        String encryptedData = Utility.getEncryptedData(oppRecords[0].id+','+eoiRecord.Id+','+digitalLinkStatus.Id+','+String.valueOf(Amount)+','+towerRecords[0].id);
        String decryptedData= EOIController.getDecryptedData(EncodingUtil.urlDecode(encryptedData, 'UTF-8'));
    }
    
    
     @isTest
    private static void testsaveEOIRecord() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        insert eoiRecord;
        
        
        List<Offer__c> offerRecords = [Select id from Offer__c];
        List<RW_Sub_Offer__c> subofferRecords = [Select id,RW_Status__c from RW_Sub_Offer__c];
        
        Applicable_Offer__c appOffers = new Applicable_Offer__c();
        appOffers.Offer__c = offerRecords[0].Id;
        appOffers.Sub_Offer__c = subofferRecords[0].Id;
        system.debug('status**'+subofferRecords[0].RW_Status__c);
        appOffers.EOI__c = eoiRecord.Id;
        insert appOffers;
       
        EOIWrapper eoiWrap = new EOIWrapper();
        
        EOIController.saveEOIrecord(eoiRecord.id, JSON.serialize(eoiWrap));
    }
    
    @isTest
    private static void testloadEOIRecord() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        insert eoiRecord; 
        
        EOIController.loadEOIdata(eoiRecord.Id);
    }
    
    @isTest
    private static void testloadOpportunityData() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        EOIController.loadOpportunityData(oppRecords[0].Id);
    }
    
     @isTest
    private static void testcheckLinkExpiry() 
    {
        		List<Opportunity> oppRecords = [Select id from Opportunity];
         		RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
                
                EOIController.checkLinkExpiry(digitalLinkStatus.Id);
    }
    
    @isTest
    private static void testretreiveStatesList()
    {
        EOIController.retreiveStatesList('RW_EOI__c', 'RW_State__c');
    }
    
    @isTest
    private static void testretreiveCountryList()
    {
        EOIController.retreiveCountryList('RW_EOI__c', 'RW_Countries__c');
    }
    
    @isTest
    private static void testretreiveProjectName()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        EOIController.retreiveProjectName(oppRecords[0].Id);
    }
    
     @isTest
    private static void testgetEOIApplicableOffers() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        insert eoiRecord;
        
        
        List<Offer__c> offerRecords = [Select id from Offer__c];
        List<RW_Sub_Offer__c> subofferRecords = [Select id,RW_Status__c from RW_Sub_Offer__c];
        
        Applicable_Offer__c appOffers = new Applicable_Offer__c();
        appOffers.Offer__c = offerRecords[0].Id;
        appOffers.Sub_Offer__c = subofferRecords[0].Id;
        system.debug('status**'+subofferRecords[0].RW_Status__c);
        appOffers.EOI__c = eoiRecord.Id;
        insert appOffers;
        
        EOIController.getEOIApplicableOffers(eoiRecord.Id, 'EOI');
    }
    
    @isTest
    private static void testLoggedInProfileName() 
    {
        EOIController.getLoggedInProfileName();
        
    }
    
    @isTest
    private static void testgetPreferredResidence() 
    {
        List<Project__c> projRecords = [Select id,Name from Project__c];
        List<Tower__c> towerRecords = [Select id,Name from Tower__c];
        EOIController.getPreferredResidence(projRecords[0].Name, towerRecords[0].Name);
    }
    
    /*@isTest
    private static void testgetPaymentGatewayDetails() 
    {
        List<Project__c> projRecords = [Select id,Name from Project__c];
        EOIController.getPaymentGatewayDetails(projRecords[0].Name);
    }*/
    
    @isTest
    private static void testCreateDigitalEOIPaymentLinkRecord()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        EOIController.CreateDigitalEOIPaymentLinkRecord(oppRecords[0].Id);
    }
    
    @isTest
    private static void testEncrypt()
    {
        List<Project__c> projRecords = [Select id,Name from Project__c];
        //EOIController.getPaymentGatewayDetails(projRecords[0].Name);
        String encryptedData = EOIController.encrypt('test', 'E9A2B6448EB867A7A9E622341452EECF');
        EOIController.getPaymentResponseDecryptedData(encryptedData,'E9A2B6448EB867A7A9E622341452EECF');
    }
    
    @isTest
    private static void testinsertPaymentDetails()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].SAP_Customer_Number__c ='87654323';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        
        Map<String,String> details = new Map<String,String>();
        details.put('paymentTrackingId','111');
        details.put('paymentMode','Net Banking');
        details.put('paymentDate','04/10/2020 18:09:37');
        details.put('paymentAmount','9000');
        details.put('eoiRecId',eoiRecord.Id);
        details.put('oppRecId',oppRecords[0].Id);
        details.put('digitalLinkId',digitalLinkStatus.Id);
        
        EOIController.insertPaymentDetails(details);
        
        List<Project__c> projRecords = [Select id from Project__c];
        
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = projRecords[0].Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu387@gmail.com';
        insert teamMembers;
        
         Team_Members__c teamMembers1 = new Team_Members__c();
        teamMembers1.Team__c =teamRec.Id;
        teamMembers1.Email_Id__c ='chidu3876@gmail.com';
        insert teamMembers1;
        
        //EOIController.insertPartialPaymentDetails(details);
        EOIController.getPaymentDetailsOfOpportunity(oppRecords[0].id, details.get('paymentTrackingId'));
    }
    
    @isTest
    private static void testinsertPartialPaymentDetails()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].SAP_Customer_Number__c ='87654323';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        
        Map<String,String> details = new Map<String,String>();
        details.put('paymentTrackingId','111');
        details.put('paymentMode','Net Banking');
        details.put('paymentDate','04/10/2020 18:09:37');
        details.put('paymentAmount','9000');
        details.put('eoiRecId',eoiRecord.Id);
        details.put('oppRecId',oppRecords[0].Id);
        details.put('digitalLinkId',digitalLinkStatus.Id);
        
        //EOIController.insertPaymentDetails(details);
        
        List<Project__c> projRecords = [Select id from Project__c];
        
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = projRecords[0].Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu387@gmail.com';
        insert teamMembers;
        
         Team_Members__c teamMembers1 = new Team_Members__c();
        teamMembers1.Team__c =teamRec.Id;
        teamMembers1.Email_Id__c ='chidu3876@gmail.com';
        insert teamMembers1;
        
        EOIController.insertPartialPaymentDetails(details);
        //EOIController.getPaymentDetailsOfOpportunity(oppRecords[0].id, details.get('paymentTrackingId'));
    }

     @isTest
    private static void testnotifyPaymentFailure()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].SAP_Customer_Number__c ='87654323';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        EOIController.notifyPaymentFailure( eoiRecord.Id, '3456789', 'Test');
    }
    
    @isTest
    private static void testgetCommunityDigitalEOIFormURL()
    {
        EOIController.getCommunityDigitalEOIFormURL();
    }
    
    @isTest
    private static void testsavePaymentRecord()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].RW_Sales_Associate__c='A Heena Rawal';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
        
        PaymentDetailsWrapper payWrap = new PaymentDetailsWrapper();
        payWrap.RWModeOfPayment='Cheque';
        payWrap.RWInstrumentNumber='5555';
        payWrap.RWPaymentDate=String.valueOf(System.today());
        payWrap.RWPaymentAmount='90000';
        payWrap.RWBankName='Allahabad Bank';
        EOIController.savePaymentRecord(oppRecords[0].id,eoiRecord.id,digitalLinkStatus.Id, JSON.serialize(payWrap));
    }
    
    @isTest
    private static void testgetPicklistValuesForFields()
    {
            EOIController.getPicklistValuesForFields('RW_EOI__c',new List<String>{'RW_Gender__c'});
    }
    
    @isTest
    private static void testgetTowersOfProject()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        EOIController.getTowersOfProject(oppRecords[0].Id);
    }
  @IsTest
private static void testsendPaymentLink() {
    // Set the mock callout
    Test.setMock(HttpCalloutMock.class, new PaymentLinkMock());
    
    List<Opportunity> oppRecords = [Select id from Opportunity];
    List<Tower__c> towerRecords = [Select id from Tower__c];
    Decimal Amount = 90000;
    String offerType = 'EOI';
    
    RW_EOI__c eoiRecord = new RW_EOI__c();
    eoiRecord.Opportunity__c = oppRecords[0].id;
    eoiRecord.Tower__c = towerRecords[0].id;
    eoiRecord.RW_Primary_First_Name__c = 'Test1';
    eoiRecord.RW_Primary_Last_Name__c = 'Test2';
    eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
    insert eoiRecord;

    // Call the method to test
    Test.startTest();
    EOIController.generateHashAndSendRequest(oppRecords[0].Id, '9000');
    Test.stopTest();
    
    // Validate that the hash was generated and set on the Opportunity
    Opportunity opp = [SELECT Hash__c FROM Opportunity WHERE Id = :oppRecords[0].Id];
    System.assertNotEquals(null, opp.Hash__c, 'Hash should be generated');
}

    
    @isTest
    private static void testgetTowerTC() 
    {
         List<Tower__c> towerRecords = [Select id from Tower__c];
         EOIController.getTowerTC(towerRecords[0].Id);
    }
    
    @isTest
    private static void testgetOffersForTower() 
    {
         List<Tower__c> towerRecords = [Select id from Tower__c];
        EOIController.getOffersForTower(towerRecords[0].Id,'EOI');
    }
    
    @isTest
    private static void testgetProjectTowers() 
    {
         List<Project__c> projRecords = [Select id from Project__c];
        EOIController.getProjectTowers(projRecords[0].Id);
    }
    
    @isTest
    private static void testgetSubOfferRecord() 
    {
       List<RW_Sub_Offer__c> subOfferRec = [Select id from RW_Sub_Offer__c];
       EOIController.getSubOfferRecord(subOfferRec[0].Id);
    }
    
     @isTest
    private static void testgenerateEOIOTP() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        
        EOIController.generateEOIOTP('EOI', '8867543213', eoiRecord.Id);
    }
    
    @isTest
    private static void testEOICustomerCreation() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].SAP_Customer_Number__c = '9876543212';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        eoiRecord.RW_Status__c = 'EOI Confirmed';
        
        
        update eoiRecord;
        
        Project_Unit__c unit = new Project_Unit__c();
        unit.EOI__c = eoiRecord.Id;
        unit.Name = 'TestUnit';      
        unit.RW_Project__c = projectrecord[0].Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c ='9';
        unit.RW_Unit_Status__c ='Available';
        insert unit;
        
        eoiRecord.RW_Status__c = 'Cancellation Initiated';
        update eoiRecord;
        
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        update eoiRecord;
        
        eoiRecord.RW_Status__c = 'EOI Cancelled -Refunded';
        update eoiRecord;
        
        
    }
    
    @isTest
    private static void testEOIBlock()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
       Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = projectrecord[0].Id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =projectrecord[0].Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.EOI__c =eoiRecord.Id;
        objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        objPUU.Carpet_Area__c=2000;
        insert objPUU;
        
        eoiRecord.RW_Status__c = 'EOI Blocked';
        update eoiRecord;
    }
    
    /*@isTest
    private static void testupdateEOIBlockStatus()
    {
      List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = projectrecord[0].Id;
        insert objPUT;
        
        
        
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c =projectrecord[0].Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //objPUU.EOI__c =eoiRecord.Id;
        //objPUU.RW_EOI_Block_Status__c = 'EOI Blocked';
        insert objPUU;
        
        
        
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        S_InventoryMatrix sinv = new S_InventoryMatrix();
        sinv.oppId = oppRecords[0].id;
        sinv.projectUnitRecordId = objPUU.Id;
        sinv.updateEOIBlockStatus();
        
        sinv.checkEOIBeforeBooking();
        
        eoiRecord.RW_Status__c = 'EOI Confirmed';
        update eoiRecord;
        
        sinv.updateEOIBlockStatus();
		sinv.updateEOIBlockStatus();
        
        sinv.checkEOIBeforeBooking();
        sinv.updateEOIBlockStatus();
        sinv.updateEOIAvailableStatus();
        
        
        Project__c objpr1 = new Project__c();
        objpr1.RW_Project_Code__c = 'T32';
        objpr1.Name = 'Runwal Bliss1';
        objpr1.RDS_Short_Name__c = 'T';
        objpr1.Start_Date__c = System.today().addDays(-5);
        objpr1.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser.Id;
        objpr1.SAPMaterial_Code__c = '12111';
        insert objpr1;
        
        Account a1 = new Account();
        a1.FirstName ='TestAccount11';
        a1.LastName ='TestAccount22';
        a1.PersonEmail = 'wc@email.com';
        a1.City__c='TestCity';
        a1.RW_Zip_Code__c = '9999999';
        a1.State__c ='Karnataka';
        a1.Country__c ='India';
        a1.Mobile_No__c = '9876543212';
        a1.Alternate_Email__c = 'wc1@email.com';
        a1.Gender__c='Male';
        a1.Salutation = 'Mr.';
        a1.Birth_Date__c = System.today().addYears(-20);   
        insert a1;
        
        
        
        Opportunity oppRec1= new Opportunity();
        oppRec1.RW_Project__c=objpr1.id;
        oppRec1.name='Test 2';
        oppRec1.RW_Email__c=a1.PersonEmail;
        oppRec1.StageName='Qualification';
        oppRec1.CloseDate=system.today();
        oppRec1.Status__c ='Active';
        oppRec1.AccountId = a1.Id;
        oppRec1.Sales_Manager__c = 'SM21@g.com';
        oppRec1.Sourcing_Manager__c='Aniket Sapre';
        oppRec1.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec1.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec1.RW_Closing_Head__c='Karthik Chettiar';
        oppRec1.Walkin_Source__c='Direct';
        insert oppRec1;
        
        sinv.oppId =oppRec1.id;
        sinv.updateEOIBlockStatus();

        
        
        RW_EOI__c eoiRecord1 = new RW_EOI__c();
        eoiRecord1.RW_Status__c = 'EOI Blocked';
        eoiRecord1.Opportunity__c= oppRecords[0].id;
        insert eoiRecord1;
        
         RW_EOI__c eoiRecord2 = new RW_EOI__c();
        eoiRecord2.RW_Status__c = 'EOI Blocked';
        eoiRecord2.Opportunity__c= oppRec1.id;
        insert eoiRecord2;
        
        Project_Unit_Type__c objPUT1 = new Project_Unit_Type__c();
        objPUT1.RDS_Code__c = '102';
        objPUT1.RDS_Project__c = projectrecord[0].Id;
        insert objPUT1;
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT1.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c =projectrecord[0].Id;
        objPUU1.RW_Param1__c = '6';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.EOI__c=eoiRecord1.Id;
        
        insert objPUU1;

        sinv.projectUnitRecordId = objPUU1.Id;
        sinv.oppId =oppRec1.id;
        sinv.updateEOIAvailableStatus();

        eoiRecord2.Opportunity__c= null;
        update eoiRecord2;
        sinv.updateEOIAvailableStatus();
        
        
        objPUU1.RW_Unit_Status__c =null;
        objPUU1.EOI__c=null;
        update objPUU1;
        eoiRecord2.Opportunity__c= oppRec1.id;
        update eoiRecord2;
        sinv.checkEOIBeforeBooking();
        
        sinv.projectUnitRecordId =null;
        sinv.oppId =null;
        sinv.updateEOIBlockStatus();
        sinv.checkEOIBeforeBooking();
        sinv.updateEOIAvailableStatus();
    }*/
    
     @isTest
    private static void testEOICancellationController()
    {
        try{
         List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
       eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        EOICancellationController.getProjectSiteHead(eoiRecord.Id);
        EOICancellationController.sendApprovalRequest(eoiRecord.Id);
        }
        
        catch(Exception e)
        {
            SYstem.debug('Exception'+e);
        }
        
        
    }
    
      @isTest
    private static void testdigitalLinkTrigger()
    {
        try{
                List<Opportunity> oppRecords = [Select id from Opportunity];
                RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
                digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
                digitalLinkStatus.RW_Link_Status__c = 'Active';
                DateTime LinkSentTime = DateTime.parse(System.Now().format());
                digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
                digitalLinkStatus.RW_Link_Expiry_Time__c = DateTime.parse(System.Now().format());
                Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
                digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        
                insert digitalLinkStatus;
                  
        	     digitalLinkStatus.RW_Link_Status__c = 'Expired';
                 update digitalLinkStatus;
        
                 digitalLinkStatus.RW_Link_Status__c = 'Active';
                 update digitalLinkStatus;
        }
        
        catch(Exception e)
        {
            system.debug('Exception'+e);
        }
        
    }
    
     @isTest
    private static void testsubOfferTrigger()
    {
         Offer__c offers = new Offer__c();
        offers.Name='TestOffer1';
        insert offers;
        
            List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = projectrecord[0].Id;
        subOffers.Tower__c = towerRecords[0].Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
    }
    
    @isTest
    private static void testgetProjectSalesDirector() 
    {
        List<Project__c> projectrecord= [Select id from Project__c];
        Utility.getProjectSalesDirector(projectrecord[0].Id); 
    }
    
    /*  @isTest
    private static void testBatchSAPPaymentInterface() 
    {
      List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        List<RW_Payment_Details__c> payList = new List<RW_Payment_Details__c>();
        for (Integer i=0;i<150;i++) 
        {
        RW_Payment_Details__c m = new RW_Payment_Details__c(RW_Accounting_Document_Number__c = 'Payment' + i,RW_Payment_Amount__c='1000',RW_Document_Type__c='DE',Opportunity__c = oppRecords[0].Id);
        payList.add(m);
        }
        insert payList;
       
        System.debug('before Start');
        Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        
        Test.stopTest();
        
        BatchSAPPaymentInterface c = new BatchSAPPaymentInterface();
        Database.executeBatch(c);
        
    }*/
    
   /* @isTest
    private static void testScheduleSAPPaymentInterface() 
    {
         Test.startTest();
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        ScheduleSAPPaymentInterface sch = new ScheduleSAPPaymentInterface();
        sch.execute();
         Test.stopTest();
    }*/
    
    @isTest
    private static void testKYCFunctionality() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

       List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
          ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = eoiRecord.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        SObject EOI = new RW_EOI__c();
        String controllingFieldApiName = 'RW_Type_Of_Applicant__c';
        String depfieldApiName = 'RW_Residential_Status__c';
        DependentPicklistUtility.getDependentMap(EOI,controllingFieldApiName,depfieldApiName);
        
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('applicantType','Individual Buyer');
        DocDetails.put('residentialStatus','Indian National');
        DocDetails.put('oppRecId',oppRecords[0].Id);
        DocDetails.put('eoiRecId',eoiRecord.Id);
        DocDetails.put('documentType','SAMPLE PAN CARD');
        DocDetails.put('documentId',documents[0].Id);
        
        
        DependentPicklistUtility.insertDocumentData(DocDetails);
        DependentPicklistUtility.insertOtherDocumentData(DocDetails);
        DependentPicklistUtility.getKYCFiles(oppRecords[0].Id,eoiRecord.Id);
        DependentPicklistUtility.deleteFiles(documents[0].Id);
        DependentPicklistUtility.getPicklistValuesForFields('RW_EOI__c', new List<String>{'RW_Document_Proof__c'});
    }
    
    
    @isTest
    private static void testReceiptTrigger() 
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        oppRecords[0].SAP_Customer_Number__c = '8765432456';
        update oppRecords[0];
        List<Tower__c> towerRecords = [Select id from Tower__c];

        List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Sent to Customer';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = projectrecord[0].Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu387@gmail.com';
        insert teamMembers;
        
        Receipt__c receipt = new Receipt__c();
        receipt.RW_Payment_Refunded__c = true;
        receipt.Total_Amount__c =9000;
        receipt.Mode__c ='Cheque';
        receipt.RW_Payment_Collection_Type__c = 'EOI';
        receipt.EOI__c = eoiRecord.Id;
        receipt.Cheque_DD_Date__c = System.today();
        receipt.DraweeBank__c = 'Axis Bank';
        receipt.Cheque_DD__c ='9876543';
        insert receipt;
        
        receipt.Physically_Cheque_Received__c = true;
        update receipt;
        
        
        
    }
    
    
    @isTest
    private static void testPaymentDetailsTrigger()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

        List<Project__c> projectrecord= [Select id from Project__c];
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = projectrecord[0].Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu387@gmail.com';
        insert teamMembers;
        
        RW_Payment_Details__c payDet = new RW_Payment_Details__c();
        payDet.RW_Document_Type__c = 'DE';
        payDet.RW_Payment_Amount__c = 1000;
        payDet.Opportunity__c =oppRecords[0].id;
        insert payDet;
        
        RW_Payment_Details__c payDet1 = new RW_Payment_Details__c();
        payDet1.RW_Document_Type__c = 'CB';
        payDet1.RW_Payment_Amount__c = 1000;
        payDet1.Opportunity__c =oppRecords[0].id;
        insert payDet1;
    }
    
     @isTest
    private static void testPrintEOIData()
    {
         List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

        List<Project__c> projectrecord= [Select id from Project__c];
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Permanent_Address_Line_1__c='Addr1';
        eoiRecord.RW_Permanent_Address_Line_2__c='Addr2';
        eoiRecord.RW_Permanent_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.RW_Digitally_Accepted_On__c = System.now();
        insert eoiRecord;
        
        //PrintEOIData pd = new PrintEOIData();
        //pd.eoi = eoiRecord;
        
        Test.StartTest(); 
        PageReference pageRef = Page.PrintEOIForm; // Add your VF page Name here
  		//pageRef.getParameters().put('eoiId', eoiRecord.Id);
  		Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('eoiId', eoiRecord.Id);
        PrintEOIData pd = new PrintEOIData();
        Test.stopTest();
        
        
    }
    
    @isTest
    private static void testgetExternalTeamEmailIds()
    {
         List<Project__c> projectrecord= [Select id from Project__c];
         Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = projectrecord[0].Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='chidu387@gmail.com';
        insert teamMembers;
        
         Team_Members__c teamMembers1 = new Team_Members__c();
        teamMembers1.Team__c =teamRec.Id;
        teamMembers1.Email_Id__c ='chidu3876@gmail.com';
        insert teamMembers1;
        List<String> TeamType = new List<String>();
        TeamType.add('MIS');
        Utility.getExternalTeamEmailIds(TeamType,projectrecord[0].Id);
        
    }
    
    @isTest
    private static void testgetDependentStatePicklists()
    {
        
         EOIController.getDependentStatePicklists('RW_EOI__c', 'RW_Countries__c', 'India', 'RW_State__c');
         EOIController.getDependentCityPicklists('RW_EOI__c', 'RW_State__c', 'Maharashtra', 'RW_City__c');
    }
    
    @isTest
    private static void getEOIRecordData()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        List<Tower__c> towerRecords = [Select id from Tower__c];

        List<Project__c> projectrecord= [Select id from Project__c];
    	RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRecords[0].id;
        eoiRecord.Tower__c = towerRecords[0].id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Permanent_Address_Line_1__c='Addr1';
        eoiRecord.RW_Permanent_Address_Line_2__c='Addr2';
        eoiRecord.RW_Permanent_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        
        EOICancellationController.getEOIRecordData(eoiRecord.Id);
        
    }
    
    @isTest
    private static void testgetOrgWideEmailAddress()
    {
        Utility.getOrgWideEmailAddress();
    }
    
    @isTest
    private static void testcommonexception()
    {
        CommonException cm = new CommonException('test1','test2');
    }
    
    /* bkk */
    @isTest
    private static void testGetBillDeskData() 
    {
        List<Opportunity> oppRec = [Select id from Opportunity];
        List<Tower__c> tower = [Select id from Tower__c];
        RW_EOI__c eoi = new RW_EOI__c();
        eoi.Opportunity__c = oppRec[0].id;
        eoi.Tower__c = tower[0].id;
        insert eoi;
        String amount='100000';
        
        Map<String,String> DetailMap = new Map<String,String>();        
        DetailMap.put('eoiRecId', eoi.Id);
        DetailMap.put('oppRecId', oppRec[0].id);
        DetailMap.put('towerId', tower[0].id);
        DetailMap.put('Amount', amount);
        EOIController.getBillDeskData(DetailMap);   
        
    }
    /* bkk */
    @isTest
    private static void testSaveBillDeskData()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        Tower__c tower = [Select id,ProjectName__r.Name,Name from Tower__c limit 1];
        oppRecords[0].SAP_Customer_Number__c = '9876543212';
        update oppRecords[0];

        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c = oppRecords[0].id;
        eoiRecord.Tower__c = tower.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Confirmed'; 
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        Receipt__c receipt = [Select id,name from Receipt__c limit 1];
        receipt.Cheque_DD_Amount_Rs__c = 200000;
        receipt.Cheque_DD__c = '908888';
        receipt.Cheque_DD_Date__c = system.today();
        receipt.Opportunity__c = oppRecords[0].Id;
        receipt.CheckReceipt__c = true;
        receipt.Token_Amount_Receipt__c = true;
        receipt.Physically_Cheque_Received__c = true;
        receipt.Approval_Status__c = 'Approved';
        receipt.Receipt_Date__c = system.today();
        receipt.DraweeBank__c = 'Axis Bank';
        receipt.Total_Amount__c = 200000;
        receipt.Currency__c = 'Indian Rupee';
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c =9000;
        receipt.EOI__c = eoiRecord.Id;        
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c = 9000;
        receipt.Mode__c ='Digital';
        receipt.RW_Payment_Collection_Type__c = 'EOI';
      
        
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
        digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
        digitalLinkStatus.RW_Link_Status__c = 'Active';
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
        digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
        Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
        digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        insert digitalLinkStatus;
        
        String name = receipt.Name;
        String linkId = digitalLinkStatus.id;
        String eoiId = eoiRecord.id;
        String towerId = tower.id;
        String amount='100000';
		List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(tower.ProjectName__r.Name, tower.Name);
        String ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
        String actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
        String checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        String msg = actualinputData+ '|'+checksum;
        EOIController.saveBillDeskResp(actualinputData,linkId,eoiId,towerId);
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|02|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|03|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);

    }
    
    @isTest
    private static void testSaveBillDeskData1()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        Tower__c tower = [Select id,ProjectName__r.Name,Name from Tower__c limit 1];
        oppRecords[0].SAP_Customer_Number__c = '9876543212';
        update oppRecords[0];

        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c = oppRecords[0].id;
        eoiRecord.Tower__c = tower.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Confirmed'; 
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        Receipt__c receipt = [Select id,name from Receipt__c limit 1];
        receipt.Cheque_DD_Amount_Rs__c = 200000;
        receipt.Cheque_DD__c = '908888';
        receipt.Cheque_DD_Date__c = system.today();
        receipt.Opportunity__c = oppRecords[0].Id;
        receipt.CheckReceipt__c = true;
        receipt.Token_Amount_Receipt__c = true;
        receipt.Physically_Cheque_Received__c = true;
        receipt.Approval_Status__c = 'Approved';
        receipt.Receipt_Date__c = system.today();
        receipt.DraweeBank__c = 'Axis Bank';
        receipt.Total_Amount__c = 200000;
        receipt.Currency__c = 'Indian Rupee';
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c =9000;
        receipt.EOI__c = eoiRecord.Id;        
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c = 9000;
        receipt.Mode__c ='Digital';
        receipt.RW_Payment_Collection_Type__c = 'EOI';
        
        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
        digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
        digitalLinkStatus.RW_Link_Status__c = 'Active';
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
        digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
        Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
        digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        insert digitalLinkStatus;
        
        String name = receipt.Name;
        String linkId = digitalLinkStatus.id;
        String eoiId = eoiRecord.id;
        String towerId = tower.id;
        String amount='100000';
		List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(tower.ProjectName__r.Name, tower.Name);
        String ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
        String actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|04|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
        String checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        String msg = actualinputData+ '|'+checksum;
        EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|05|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|06|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);

    }
    
    @isTest
    private static void testSaveBillDeskData2()
    {
        List<Opportunity> oppRecords = [Select id from Opportunity];
        Tower__c tower = [Select id,ProjectName__r.Name,Name from Tower__c limit 1];
        update oppRecords[0];

        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c = oppRecords[0].id;
        eoiRecord.Tower__c = tower.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Confirmed'; 
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        insert eoiRecord;
        
        Receipt__c receipt = [Select id,name from Receipt__c limit 1];
        receipt.Cheque_DD_Amount_Rs__c = 200000;
        receipt.Cheque_DD__c = '908888';
        receipt.Cheque_DD_Date__c = system.today();
        receipt.Opportunity__c = oppRecords[0].Id;
        receipt.CheckReceipt__c = true;
        receipt.Token_Amount_Receipt__c = true;
        receipt.Physically_Cheque_Received__c = true;
        receipt.Approval_Status__c = 'Approved';
        receipt.Receipt_Date__c = system.today();
        receipt.DraweeBank__c = 'Axis Bank';
        receipt.Total_Amount__c = 200000;
        receipt.Currency__c = 'Indian Rupee';
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c =9000;
        receipt.EOI__c = eoiRecord.Id;        
        receipt.Payment_Gateway__c = 'BillDesk';
        receipt.Total_Amount__c = 9000;
        receipt.Mode__c ='Digital';
        receipt.RW_Payment_Collection_Type__c = 'EOI';

        RW_Digital_Link_Status__c digitalLinkStatus = new RW_Digital_Link_Status__c();
        digitalLinkStatus.RW_Opportunity__c = oppRecords[0].id;
        digitalLinkStatus.RW_Link_Status__c = 'Active';
        DateTime LinkSentTime = DateTime.parse(System.Now().format());
        digitalLinkStatus.RW_Link_Sent_Time__c = LinkSentTime;
        Id eoiRecordTypeId = Schema.SObjectType.RW_Digital_Link_Status__c.getRecordTypeInfosByName().get('EOI').getRecordTypeId();
        digitalLinkStatus.RecordTypeId = eoiRecordTypeId;
        insert digitalLinkStatus;
        
        String name = receipt.Name;
        String linkId = digitalLinkStatus.id;
        String eoiId = eoiRecord.id;
        String towerId = tower.id;
        String amount='100000';
		List<Payment_Gateway__mdt> BillDeskDetails = Utility.getBIllDeskPaymentGatewayDetails(tower.ProjectName__r.Name, tower.Name);
        String ChecksumKey = BillDeskDetails[0].Bill_Desk_Checksum_Key__c;
        String actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|07|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
        String checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        String msg = actualinputData+ '|'+checksum;
        EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|08|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);
        
        actualinputData = 'BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|10|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA';
		checksum = Utility.getChecksumKey(actualinputData,ChecksumKey);
        msg = actualinputData+ '|'+checksum;
        //EOIController.saveBillDeskResp(msg,linkId,eoiId,towerId);

    }
	/* bkk */
   
    

}