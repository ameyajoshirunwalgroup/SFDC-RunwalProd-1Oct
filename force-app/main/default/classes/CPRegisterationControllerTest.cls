@isTest
public class CPRegisterationControllerTest {

    public class CPRegistrationCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success", "message": "Invitation Sent Successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void CPTest1(){
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP 1';
        cp.RW_Email__c = 'cp1@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;                                                                                                    
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises 1';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Sourcing_Manager__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '9999000001';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ABCDE1001A';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.RERA_Valid_till__c = System.today().addMonths(3);
        insert cp;
        
        Map<Id,String> tempCPIdVsEmailMap = new Map<Id,String>();
        tempCPIdVsEmailMap.put(cp.Id,cp.RW_Email__c);
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        cp.Account__c = ac.Id;
        update cp;
        
        
        list<Broker__c> bkList = new list<Broker__c>();        
        Id TempCPRecordTypeId = Schema.SObjectType.Broker__c.getRecordTypeInfosByName().get('Temp Channel Partner').getRecordTypeId();                
        
        Broker__c b1 = new Broker__c();
        b1.Name = 'Temp CP 1';
        b1.RecordTypeId = TempCPRecordTypeId;
        b1.Broker_Pan_No__c = 'ABCDE1002A';
        b1.Sourcing_Manager__c= UserInfo.getUserId();
        b1.RW_Email__c = 'temp1@gmail.com';
        b1.RW_Mobile_No__c = '9999000002';
        b1.Company_Name__c = 'Test Comp 1';
        bkList.add(b1);
        
        Broker__c b2 = new Broker__c();
        b2.Name = 'Temp CP 2';
        b2.RecordTypeId = TempCPRecordTypeId;
        b2.Broker_Pan_No__c = 'ABCDE1003A';
        b2.Sourcing_Manager__c= UserInfo.getUserId();
        b2.RW_Email__c = 'temp2@gmail.com';
        b2.RW_Mobile_No__c = '9999000003';
        b2.Company_Name__c = 'Test Comp 2';
        bkList.add(b2);
        
        insert bkList;
        
        Broker__c b3 = new Broker__c();
        b3.Name = 'Temp CP 3';
        b3.RecordTypeId = TempCPRecordTypeId;
        b3.Broker_Pan_No__c = 'ABCDE1004A';
        b3.Sourcing_Manager__c= UserInfo.getUserId();
        b3.RW_Email__c = 'temp3@gmail.com';
        b3.RW_Mobile_No__c = '9999000004';
        b3.Company_Name__c = 'Test Comp 3';
        // Note: b3 is left uninserted, matching original code logic
        
        Test.setCreatedDate(b1.Id, System.today().addDays(-7));
        Test.setCreatedDate(b2.Id, System.today().addDays(-15));
        
        Broker__c cp2 = new Broker__c();
        cp2.Name = 'Test CP 2';
        cp2.RW_Email__c = 'cp2@stetig.in';
        cp2.Individual_CP__c = true;
        cp2.RW_CreateFromIRIS__c = true;
        cp2.RW_IRIS_Sync__c = true;
        cp2.Company_Name_As_per_RERA__c = 'Runwal Enterprises 2';
        cp2.Place_of_Supply__c = 'Maharashtra';
        cp2.Channel_Partner_From_CP_Portal__c = true;
        cp2.Project__c = 'Runwal Bliss';
        cp2.Approver_L1__c = userinfo.getUserId();
        cp2.Approver_L2__c = userinfo.getUserId();
        cp2.Registration_Complete__c = true;
        cp2.RW_Mobile_No__c = '9999000005';
        cp2.Broker_Type__c = 'Individual';
        cp2.Broker_Pan_No__c = 'ABCDE1005A';
        cp2.NAME_FIRST__c = 'tets';
        cp2.NAME_MIDDLE__c = 'cp';
        cp2.NAME_LAST__c = 'test';
        cp2.TITLE__c = 'Mr.';
        cp2.Sourcing_Manager__c = userinfo.getUserId();
        cp2.Account_Number__c = '465446';
        cp2.Cheque_DD_Favouring_Name__c = 'test cp';
        cp2.IFSC_Code__c = 'BHSHVD';
        cp2.Is_NRI_CP__c = false;
        cp2.RW_Is_GST_Applicable__c = true;
        
        Broker__c cp3 = new Broker__c();
        cp3.Name = 'Test CP 3';
        cp3.RW_Email__c = 'cp3@stetig.in';
        cp3.Individual_CP__c = true;
        cp3.Company_Name_As_per_RERA__c = 'Runwal Enterprises 3';
        cp3.RW_CreateFromIRIS__c = true;
        cp3.RW_IRIS_Sync__c = true;
        cp3.Place_of_Supply__c = 'Maharashtra';
        cp3.Channel_Partner_From_CP_Portal__c = true;
        cp3.Project__c = 'Runwal Bliss';
        cp3.Approver_L1__c = userinfo.getUserId();
        cp3.Approver_L2__c = userinfo.getUserId();
        cp3.Sourcing_Manager__c = userinfo.getUserId();
        cp3.Registration_Complete__c = true;
        cp3.RW_Mobile_No__c = '9999000006';
        cp3.Broker_Type__c = 'Individual';
        cp3.Broker_Pan_No__c = 'ABCDE1006A';
        cp3.NAME_FIRST__c = 'tets';
        cp3.NAME_MIDDLE__c = 'cp';
        cp3.NAME_LAST__c = 'test';
        cp3.TITLE__c = 'Mr.';
        cp3.Account_Number__c = '465446';
        cp3.Cheque_DD_Favouring_Name__c = 'test cp';
        cp3.IFSC_Code__c = 'BHSHVD';
        cp3.Is_NRI_CP__c = false;
        cp3.RW_Is_GST_Applicable__c = true;
        
        Sobject objRecord = new Broker__c(
            Name = 'Test CP 4',
            RW_Email__c = 'cp4@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Project__c = 'Runwal Bliss',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Registration_Complete__c = true,
            RW_Mobile_No__c = '9999000007',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ABCDE1007A',
            NAME_FIRST__c = 'tets',
            NAME_MIDDLE__c = 'cp',
            NAME_LAST__c = 'test',
            TITLE__c = 'Mr.',
            Account_Number__c = '465446',
            Cheque_DD_Favouring_Name__c = 'test cp',
            IFSC_Code__c = 'BHSHVD',
            Is_NRI_CP__c = false,
            RW_Is_GST_Applicable__c = true,
            Channel_Partner_From_CP_Portal__c =true
        );
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id limit 1];
        
        // Made this Account Mobile number unique too just in case
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9999000050',false); 
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        Team__c t = new Team__c();
        t.Name = 'CP Approvers Team';
        t.Project__c = objpr.id;
        t.Team_Type__c = 'CP Invoice Approver Team';
        insert t;
        
        Team_Members__c tm = new Team_Members__c();
        tm.Approver_Type__c = 'CP MIS';
        tm.Team__c = t.Id;
        tm.User_Active__c = true;
        tm.User__c= userinfo.getUserId();
        insert tm;
            
        
        Team_Members__c tm1 = new Team_Members__c();
        tm1.Approver_Type__c = 'CP Sourcing Head';
        tm1.Team__c = t.Id;
        tm1.User_Active__c = true;
        tm1.User__c= userinfo.getUserId();
        insert tm1;
        
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test Opp 1';
        objcustomer.StageName='Qualification';
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        insert objcustomer;
        
        Collateral__c c = new Collateral__c();
        c.Project__c = objpr.id;
        insert c;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        /*CP_Invoice_Approvers_list_CS__c appcs = new CP_Invoice_Approvers_list_CS__c();
        appcs.Name = 'Test123';
        appcs.CP_MIS__c = '56789';
        appcs.CP_Sourcing_Head__c = '1234567';
        insert appcs;*/
        
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('First Upload Content'));
        
        Test.startTest();
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        
        // Creating User with the exact same email as cp2 so the selfRegister method can find/use it
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1]; 
        User u = new User(
            Alias = 'testu',
            Email = 'cp2@stetig.in',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'cp2@stetig.in' + System.currentTimeMillis()
        );
        insert u;
        
        system.runAs(u){
            CPRegisterationController.selfregister(cp2);
        }
        
        CPRegisterationController.getApprovers('Runwal Bliss');
        CPRegisterationController.pickListValueDynamically(objRecord, 'Broker_Type__c');
        CPRegisterationController.isDuplicateCPExist(null);
        CPRegisterationController.isDuplicateCPExist(cp2);
        CPRegisterationController.isDuplicateCPExist(b1);
        CPRegisterationController.getTempCPData('TEMP-0000');
        CPRegisterationController.getExistingCPData(cp.Id);
        CPRegisterationController.uploadFile(base64,'TestDoc.txt',cp.Id,'PAN Card');
        CPRegisterationController.fetchFiles(cp.Id);
        CPRegisterationController.getProjectList();
        CPRegisterationController.registrationcomplete(cp.id); 
        Test.setMock(HttpCalloutMock.class, new CPRegistrationCalloutMock());
        CPRegisterationController.sendRegistrationLinktoCP(cp.id);
        ScheduleCPEmailson7n15daysaftercreation obj = new ScheduleCPEmailson7n15daysaftercreation();
        obj.execute(null);
        ScheduleCPReminderEmailsprior3Mons obj1 = new ScheduleCPReminderEmailsprior3Mons();
        obj1.execute(null);
        System.enqueueJob(new SendCPEmails(tempCPIdVsEmailMap, 'Temp_CP_creation_Email'));
        CPRegisterationController.updateDocDetailsnSubmitforAppr(true, cp.Id, Date.today()+10, Date.today()+10);
        CPRegisterationController.updateDocDetailsnSubmitforAppr(false, cp.Id, Date.today()+10, Date.today()+10);
        CPRegisterationController.getBrokerDetails(null);
        CPRegisterationController.createTempCP(b3);
        
        Test.stopTest();
    }
    
    @isTest
    public static void CPTest2(){        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP Test 2';
        cp.RW_Email__c = 'cptest2@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises Test2';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Latest_RERA_Upload_Status__c = 'Approval Pending';
        cp.RERA_Valid_till__c = Date.today() + 5;
        cp.Latest_RERA_Upload_Processed__c = false;
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '9999000008';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ABCDE1008A';
        cp.Sourcing_Manager__c = userinfo.getUserId();
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.CC_Valid_till__c = System.today().addMonths(3);
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('First Upload Content'));
        String base642 = EncodingUtil.base64Encode(Blob.valueOf('Second Upload Content'));
        
        Test.startTest();
        CPRegisterationController.uploadFile(base64,'TestDoc.txt',cp.Id,'PAN Card');        
        CPRegisterationController.uploadFile(base642,'TestDoc.txt',cp.Id,'PAN Card');  
        
        CPRegisterationController c = new CPRegisterationController();
        c.dummyMethod();
        ScheduleCPDocApproval obj = new ScheduleCPDocApproval();
        obj.execute(null);
        ScheduleCPReminderEmailsprior3Mons obj1 = new ScheduleCPReminderEmailsprior3Mons();
        obj1.execute(null);
        Test.stopTest();
    }
    
    @isTest
    public static void CPTest3(){        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP Test 3';
        cp.RW_Email__c = 'cptest3@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises Test 3';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Latest_CC_Upload_Status__c = 'Approval Pending';
        cp.CC_Valid_till__c = Date.today() + 5;
        cp.Latest_CC_Upload_Processed__c = false;
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '9999000009';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ABCDE1009A';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        insert cp;
        
        Test.startTest(); 
        ScheduleCPDocApproval obj = new ScheduleCPDocApproval();
        obj.execute(null);        
        Test.stopTest();
    }
}