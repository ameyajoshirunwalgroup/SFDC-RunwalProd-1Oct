@isTest
public class CustomerPortalReferralTest {

    @testSetup 
    private static void setupdata() 
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new SAPInventoryCallMock());
        Test.stopTest();
            
        
            UserRole obj=new UserRole(Name= 'ABC'); 
			insert obj;
            
            Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

    	/*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;*/
        
        String orgId1 = UserInfo.getOrganizationId();
    String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName1 = orgId1 + dateString1 + randomInt1;
    User tuser1 = new User(  firstname = 'TestUser',
                            lastName = 'TestUser',
                            email = uniqueName1 + '@gmail' +'.com',
                            Username = uniqueName1 + '@test' + orgId1 + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName1.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p1.id,
                            UserRoleId = obj.Id
                            );
         insert tuser1;
            
         List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0])
        {    
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
        //Inserting account
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        objAcc.RecordTypeID=recordTypeId ;
        objAcc.LastName ='TestAccount22';
        objAcc.PersonEmail = 'wc@email.com';
        objAcc.City__c='TestCity';
        objAcc.RW_Zip_Code__c = '9999999';
        objAcc.State__c ='Karnataka';
        objAcc.Country__c ='India';
        objAcc.Mobile_No__c = '9876543212';
        objAcc.Alternate_Email__c = 'wc1@email.com';
        objAcc.Gender__c='Male';
        objAcc.Salutation = 'Mr.';
        objAcc.Birth_Date__c = System.today().addYears(-20); 
        objAcc.OwnerId = tuser1.Id;
        insert objAcc;
        
        Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        
        Profile p = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser1',
                              lastName = 'TestUser2',
                              email = uniqueName + '@gmail' +'.com',
                              contactId=acc.PersonContactId,
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = p.id
                             );
        insert tuser;
        system.debug('*1*');
        //Inserting Project
          Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
            objpr.RW_SAP_Company_Code__c='5245';
        insert objpr;
            
        }
    }
        
        
    @isTest
    private static void testCustomerPortalEnquiryController()
    {
        List<Project__c> proj = [Select id,Name from Project__c];
        RW_Referral__c ref = new RW_Referral__c();
        //ref.RW_Project__c = objpr.Id;
        ref.RW_Status__c = 'Duplicate';
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= proj[0].Name;
        ref.RW_Contact_Phone__c = '1221122100';
        
        RW_Referral__c ref1 = new RW_Referral__c();
        //ref.RW_Project__c = objpr.Id;
        ref1.RW_Status__c = 'Duplicate';
        ref1.RW_First_Name__c ='Test';
        ref1.RW_Last_Name__c='Lead';
        ref1.RW_Email_Address__c='Test@test.com';
        ref1.RW_Project__c= proj[0].Name;
        ref1.RW_Contact_Phone__c = '12211221004';
        
         List<User> u = [Select id from User where firstname='TestUser1'];
        system.runAs(u[0])
        {
       // CustomerPortalEnquiryController.getEnquiryRecords();
        CustomerPortalEnquiryController.insertReferral(ref);
        CustomerPortalReferralController.getReferralRecords();
        CustomerPortalReferralController.insertReferral(ref1);
        }
    }
}