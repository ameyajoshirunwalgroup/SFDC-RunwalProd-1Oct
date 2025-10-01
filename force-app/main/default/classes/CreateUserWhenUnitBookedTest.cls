@isTest
public class CreateUserWhenUnitBookedTest {
    @testSetup
    private static void setupdata() {
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeID=recordTypeId ;
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
        a.RW_Country__c = 'India';
        insert a;
        
        Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :a.Id];
        
        Profile p = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];

    	String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(  firstname = 'TestUser1',
                               lastName = 'TestUser2',
                               email = uniqueName + '@gmail' +'.com',
                               contactId=acc.PersonContactId,
                               Username = uniqueName + '@test1' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = p.id
                              );
        insert u;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //objpr.Sales_Site_Head__c = tuser1.Id;
        objpr.SAPMaterial_Code__c = '1211';
        //objpr.Project_CRM_Lead__c = tuser1.Id;
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        insert objpr;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        insert oppRec;
        
        Opportunity oppRec1= new Opportunity();
        oppRec1.RW_Project__c=objpr.id;
        oppRec1.name='Test 1';
        oppRec1.RW_Email__c=a.PersonEmail;
        oppRec1.StageName='Cancelled';
        oppRec1.CloseDate=system.today();
        oppRec1.Status__c ='Active';
        oppRec1.AccountId = a.Id;
        oppRec1.Sales_Manager__c = 'SM2@g.com';
        oppRec1.Sourcing_Manager__c='Aniket Sapre';
        oppRec1.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec1.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec1.RW_Closing_Head__c='Karthik Chettiar';
        oppRec1.Walkin_Source__c='Direct';
        oppRec1.SAP_Customer_Number__c='0020006618';
        oppRec1.SalesOrder_Number__c='3010005457';
        insert oppRec1;
        
        Booking__c booking=new Booking__c();
        booking.Status__c='Cancellation Initiated';
        booking.Opportunity__c=oppRec1.id;
        insert booking;
        
        oppRec1.Booking__c = booking.Id;
        update oppRec1;
        
        Country_Codes__c code = new Country_Codes__c();
        code.Name = 'India';
        code.Code__c = 'IN';
        insert code;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock());  
        CreateUserWhenUnitBooked.createuser(new List<Id>{acc.Id});
       	
        CreateUserWhenUnitBooked.deleteuser(new List<Id>{acc.Id});
        Test.stopTest();
    }
    
    @isTest
    private static void testCommunityUserUpdate(){
        List<User> u1 = [Select id from User where firstname='TestUser1'];
        Account acc = [Select Id,PersonEmail,PersonContactId From Account Where FirstName ='TestAccount1'];
        CommunityUserUpdate.updateUser(new List<Id>{u1[0].Id});
       	u1[0].isActive = false;
        update u1;
        Test.startTest();
        System.enqueueJob(new CommunityUserUpdate(new List<Id>{u1[0].Id}));
        Test.setMock(HttpCalloutMock.class, new CreateUserWhenUnitBookedMock());  
        DeleteUserInMobileAppQueueable del = new DeleteUserInMobileAppQueueable(new Set<Id>{acc.Id});
        System.enqueueJob(del);
        Test.stopTest();
    }
}