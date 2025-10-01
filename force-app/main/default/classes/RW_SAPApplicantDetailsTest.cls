@isTest
public class RW_SAPApplicantDetailsTest {
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
        system.debug('*2*');
        //Inserting Referral
        RW_Referral__c objRef = New RW_Referral__c();
        objRef.Account__c = objAcc.Id;
        objRef.RW_First_Name__c ='TestAccount11';
        objRef.RW_Last_Name__c ='TestAccount22';
        objRef.RW_Email_Address__c = 'wc@email.com';
        objRef.RW_Project__c = 'Runwal Bliss';
        objRef.RW_Contact_Phone__c= '9876543212';
        objRef.RW_Mode__c= 'Customer portal';
        insert objRef;
        system.debug('*3*');
        //Inserting Tower
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        system.debug('*4*');
        //Inserting Tower Construction Update
        
        system.debug('*5*');
        //Inserting Opportunity
        //
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=acc.PersonEmail;
        //oppRec.StageName='Qualification';
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = acc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
         oppRec.Booking_Feedback_Link__c='654864524';
         oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
         oppRec.RW_Sourcing_Manager__c='Rohit Sharma';
         
        insert oppRec;
        }
    }
    
    @isTest
    private static void TestRWSAPApplicantDetails()
    {
        List<Opportunity> oppRec = [Select id from Opportunity];
        List<Id> Ids = new List<Id>();
        for(Opportunity opp : oppRec)
        {
            Ids.add(opp.Id);
        }
     
        RW_SAPApplicantDetails.callSAPCustomerUpdate(Ids);
    }
}