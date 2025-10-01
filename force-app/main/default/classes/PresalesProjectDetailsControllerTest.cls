@isTest
public class PresalesProjectDetailsControllerTest {
    @testSetup
    private static void PresalesProjectDetailsControllerDataTest() 
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
     //   objpr.RW_Project_Brochure_ID__c = '0691e000000Ak45AAC';
        objpr.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        objpr.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        objpr.Site_Address_Map_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        objpr.RW_LocalityName__c = 'Test';
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
        oppRec.RW_Mobile_No__c='1221122100';
        oppRec.LeadSource='Direct';
        insert oppRec;
        
         Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.LeadSource = 'Reference';
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
        
        Prospect__c ps= new Prospect__c();
        ps.Opportunity__c = oppRec.id;
        ps.Project__c = objpr.id;
        ps.Active__c = true;
        ps.Lead_Source__c = 'Direct';
        insert ps;
        
        Survey__c srvy = new Survey__c();
        srvy.Opportunity__c = oppRec.Id;
      
        insert srvy;
        
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
        cdl.LinkedEntityId =objpr.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Map<String,String> DocDetails = new Map<String,String>();
            DocDetails.put('applicantType','Individual Buyer');
            DocDetails.put('residentialStatus','Indian National');
            //DocDetails.put('bookingId',objBking.id);
            
            DocDetails.put('projectId',objpr.id);
            DocDetails.put('oppId',oppRec.id);
            DocDetails.put('documentType','PAN Card');
            DocDetails.put('documentId',   documents[0].id);
            //DocDetails.put('InspPossId',   insPoss6.Id);
            DocDetails.put('ApplicantNumber','Primary Applicant');
        ProjectBrochureUploadController.getFiles(string.valueOf(documents[0].Id));
        ProjectBrochureUploadController.deleteFiles(string.valueOf(documents[0].Id));
        ProjectBrochureUploadController.getProjectRecord(string.valueOf(objpr.Id));
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = contentVersion.Title;
        cd.ContentVersionId = contentVersion.Id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        //insert cd;
        //ProjectBrochureUploadController.updateBrochureData(DocDetails);
         Contentversion cv = new Contentversion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.ContentDocumentId = oppRec.RW_Project__r.RW_Project_Brochure_ID__c;
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        insert cv;
    
        RW_Presales_Communication__c presaleComm = new RW_Presales_Communication__c();
        presaleComm.RW_Opportunity__c = oppRec.Id;
        presaleComm.RW_Project_Details_Mode_of_Communication__c = 'Email';
        insert presaleComm;
       
    }
    

   
    @isTest static void testCallout() {
        List<Project__c>  objpr = [SELECT Id,RW_Project_Brochure_ID__c FROM Project__c Limit 1];
        system.debug('### objpr objpr '+objpr[0].Id+' $$ brochure id '+objpr[0].RW_Project_Brochure_ID__c );
        List<Account>  acc = [SELECT Id FROM Account Limit 1];
        List<Opportunity>  oppList = [SELECT Id,LeadSource,RW_Mobile_No__c,RW_Email__c,Name,Project_Name__c,RW_Project__r.RW_Project_Brochure_ID__c,
                     RW_Project__r.RW_Project_Brochure_PublicUrl__c,RW_Project__r.RW_Project_Location_Videos_Link__c,
                     RW_Project__r.Site_Address_Map_Link__c FROM Opportunity Limit 1];
        String oppId = oppList[0].Id;
        String opp = 'Opportunity';
        List<Lead> ledList = [SELECT Id,Remark__c,LeadSource,RW_Mobile_No__c,RW_Project__c,Email,Name,Project_Name__c,
                              RW_Project__r.RW_Project_Brochure_ID__c,RW_Project__r.RW_Project_Brochure_PublicUrl__c,
                              RW_Project__r.RW_Project_Location_Videos_Link__c,RW_Project__r.Site_Address_Map_Link__c FROM Lead Limit 1];
        String ledId = ledList[0].Id;
        String led = 'Lead';
        List<Prospect__c> prosList = [SELECT Id,Name,Project__c,Active__c,Opportunity__c,Lead__c,Lead_Source__c FROM Prospect__c Limit 1];
        String prosId = prosList[0].Id;
        String pros = 'Prospect__c';
    
        // Set mock callout class 
        
        String localityName = 'Andheri east';
      
       List<Survey__c> suvyList = [SELECT Id, Name,Survey_Link__c FROM Survey__c Limit 1]; 
     
        
        OTP__c otp = new OTP__c(Project__c =objpr[0].Id
                                ,Customer_Site_Visit_On__c='test',Generated_OTP__c='123',
                   CP_Name__c='Channel Partner Name: INVESTORS CLINIC INFRATECH PVT LTD.');
        insert otp;
        
        Project__c newProject = new Project__c();
        newProject.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.Site_Address_Map_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.RW_LocalityName__c = 'Test2';
        insert newProject;
        
        Project__c newProject2 = new Project__c();
        newProject.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.Site_Address_Map_Link__c = 'https://goo.gl/maps/nr1aAnkzfYK2';
        newProject.RW_LocalityName__c = 'Test3';
        insert newProject2;
        
         List<Id> projectIds = new List<Id>{ newProject.Id, newProject2.Id };
         List<Id> projectId1 = new List<Id>{ newProject.Id};
         List<Id> projectId2 = new List<Id>();
             
             List<ContentVersion> contentVersions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Test Document 1',
                PathOnClient = 'TestDocument1.pdf',
                VersionData = Blob.valueOf('Test content'), 
                FirstPublishLocationId = newProject.Id
            ),
            new ContentVersion(
                Title = 'Test Document 2',
                PathOnClient = 'TestDocument2.pdf',
                VersionData = Blob.valueOf('Test content'), 
                FirstPublishLocationId = newProject2.Id 
            )
        };
        insert contentVersions; 
        
        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'Email'},projectIds);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'WhatsApp'},projectIds);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(oppId,opp, new List<String>{'Email'},projectIds);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(oppId,opp, new List<String>{'WhatsApp'},projectIds);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(prosId,pros, new List<String>{'Email'},projectIds);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(prosId,pros, new List<String>{'WhatsApp'},projectIds);
        
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'Email'},projectId1);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'WhatsApp'},projectId1);
        
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'Email'},projectId2);
        PresalesProjectDetailsController.sendProjectDetailsAsEmail(ledId,led, new List<String>{'WhatsApp'},projectId2);
        
        
        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg('Name', 'Runwal Bliss', localityName, 'https://runwal--uat.my.salesforce.com/', 'https://runwal--uat.my.salesforce.com/', 'https://runwal--uat.my.salesforce.com/',System.Label.Website_URL,'Best Wishes',System.Label.RW_CPContactNumber, '8989898989',System.Label.Lead_Project_Content2_HSM);
        Test.stopTest();
        
    }
     

}