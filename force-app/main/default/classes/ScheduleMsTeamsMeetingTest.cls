@IsTest
public class ScheduleMsTeamsMeetingTest {
    
    @testSetup  
    static void scheduleMsTeamsTest1() {
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
        
        
        Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Reference';
        //objLead.RW_Reference_Source__c = 'Existing Customer Reference';
        objLead.RW_Lead_Sub_Source__c = 'Existing client reference';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = a.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        insert objLead;
        
        
        RW_MS_Teams__c msTeam = new RW_MS_Teams__c();
        msTeam.RW_Start_Time__c = system.now();
        msTeam.RW_End_Time__c = system.now();
        msTeam.RW_Opportunity__c = oppRec.id;
        msTeam.RW_Lead__c = objLead.id;
        msTeam.RW_URL_Recording__c = 'test';
        msTeam.RW_Status__c = 'Schedule';
        msTeam.RW_Title__c = 'subject';
        msTeam.RW_MeetingID__c = 'AAMkADlmODkxYzg3LWFhMzktNDZmZi1iY2E3LWRiN2E2MTE5ZmVjMABGAAAAAABxn6aDwG4RRaGUtlFVbeOLBwCCOSe5g2onTJYny3_yhXymAAAAAAENAACCOSe5g2onTJYny3_yhXymAAAz5teAAAA';
        msTeam.RW_Meeting_Content__c = 'test clas';
        insert msTeam;
        
        string MsRecordID = msTeam.RW_MeetingID__c;
        string sobjecttype = 'Opportunity';
        Datetime startTime = msTeam.RW_Start_Time__c;
        Datetime endTime = msTeam.RW_End_Time__c;
        string content = msTeam.RW_Meeting_Content__c;
        string btnLable = 'Schedule';
        string leadId = 'lead';
        string leadEmail = 'mounika@in.ey.com';
        string leadName = 'test';
        string oppId = msTeam.RW_Opportunity__c;
        string oppEmail = 'mounika@in.ey.com';
        string oppName = 'oppName';
        string meetingID = msTeam.RW_MeetingID__c;
        string subject = msTeam.RW_Title__c;
                                                      
       
       Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       scheduleMsTeamsMeeting.msIntegration(objLead.Id, 'Lead', startTime, endTime, subject, content, 'Accept','Presales Call');
       Test.stopTest();
        }
    
    static testMethod void scheduleMsTeamsTest2() {
        
    }
}