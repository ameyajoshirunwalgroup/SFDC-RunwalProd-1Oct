@isTest
public class TestIrisAPICancellationClass {

    @testSetup
    private static void setupdata() 
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
        
         Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Customer__c =oppRec.Id;
       // objBking.Unit_No__c = objPUU.id;
        //objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Sales_Manager__c= tuser.Id;
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Token_Amount__c=2000;
        objBking.Allotment_Premium__c=3000;
         objBking.Source_of_Booking__c='Direct';
          objBking.Carpet_Area__c=23;
          objBking.RW_Registration_Date__c=System.today();
        insert objBking;
        

 		
        
    }
    
     @isTest
    private static void testIrisAPICancellation()
    {
       List<Booking__c> bookingRec = [Select id from Booking__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());
       IrisAPICancellationClass.sendtoiris(new List<Id>{bookingRec[0].Id});
         Test.stopTest();
        
        
       
    }
    
   /* @isTest
    private static void testIrisAPICancellationSecondScenario()
    {
        List<Booking__c> bookingRec = [Select id from Booking__c];
        Test.setMock(HttpCalloutMock.class,new UniversalHttpMockErrorResponseClass());
      IrisAPICancellationClass.sendtoiris(new List<Id>{bookingRec[0].Id});
    }*/
    
     @isTest
    private static void testIrisAPIBookingRegistration()
    {
       List<Booking__c> bookingRec = [Select id from Booking__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());
       
       IrisAPIBookingRegistrationComplete.sendtoiris(new List<Id>{bookingRec[0].Id});
        Test.stopTest();
        
       
    }
    
   /* @isTest
    private static void testIrisAPIBookingRegistrationSecondscenario()
    {
         List<Booking__c> bookingRec = [Select id from Booking__c];
      Test.setMock(HttpCalloutMock.class,new UniversalHttpMockErrorResponseClass());
      IrisAPIBookingRegistrationComplete.sendtoiris(new List<Id>{bookingRec[0].Id});
    }*/
}