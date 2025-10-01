@isTest
public class CPRegisterationControllerTest {
    @isTest
    public static void CPTest1(){
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;																																	
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Sourcing_Manager__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
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
        b1.Name = 'Test 1';
        b1.RecordTypeId = TempCPRecordTypeId;
        b1.Broker_Pan_No__c = 'ASFGF0909I';
        b1.Sourcing_Manager__c= UserInfo.getUserId();
        b1.RW_Email__c = 'tes8585@gmail.com';
        b1.RW_Mobile_No__c = '1222988889';
        b1.Company_Name__c = 'Test';
        bkList.add(b1);
        
        Broker__c b2 = new Broker__c();
        b2.Name = 'Test 2';
        b2.RecordTypeId = TempCPRecordTypeId;
        b2.Broker_Pan_No__c = 'AWFGF0909I';
        b2.Sourcing_Manager__c= UserInfo.getUserId();
        b2.RW_Email__c = 'tes884585@gmail.com';
        b2.RW_Mobile_No__c = '8787988889';
        b2.Company_Name__c = 'Test';
        bkList.add(b2);
        
        insert bkList;
        
        Broker__c b3 = new Broker__c();
        b3.Name = 'Test 2';
        b3.RecordTypeId = TempCPRecordTypeId;
        b3.Broker_Pan_No__c = 'AWFGF0909I';
        b3.Sourcing_Manager__c= UserInfo.getUserId();
        b3.RW_Email__c = 'tes884585@gmail.com';
        b3.RW_Mobile_No__c = '8787988889';
        b3.Company_Name__c = 'Test';
        
        Test.setCreatedDate(b1.Id, System.today().addDays(-7));
        Test.setCreatedDate(b2.Id, System.today().addDays(-15));
        
        Broker__c cp2 = new Broker__c();
        cp2.Name = 'Test CP';
        cp2.RW_Email__c = 'teststetig43646@stetig.in';
        cp2.Individual_CP__c = true;
        cp2.RW_CreateFromIRIS__c = true;
        cp2.RW_IRIS_Sync__c = true;
        cp2.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
        cp2.Place_of_Supply__c = 'Maharashtra';
        cp2.Channel_Partner_From_CP_Portal__c = true;
        cp2.Project__c = 'Runwal Bliss';
        cp2.Approver_L1__c = userinfo.getUserId();
        cp2.Approver_L2__c = userinfo.getUserId();
        cp2.Registration_Complete__c = true;
        cp2.RW_Mobile_No__c = '1234567890';
        cp2.Broker_Type__c = 'Individual';
        cp2.Broker_Pan_No__c = 'ADRPI3525F';
        cp2.RW_Mobile_No__c = '1234567890';
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
        cp2.Channel_Partner_From_CP_Portal__c =true;
        
        Broker__c cp3 = new Broker__c();
        cp3.Name = 'Test CP';
        cp3.RW_Email__c = 'teststetig43646@stetig.in';
        cp3.Individual_CP__c = true;
        cp3.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
        cp3.RW_CreateFromIRIS__c = true;
        cp3.RW_IRIS_Sync__c = true;
        cp3.Place_of_Supply__c = 'Maharashtra';
        cp3.Channel_Partner_From_CP_Portal__c = true;
        cp3.Project__c = 'Runwal Bliss';
        cp3.Approver_L1__c = userinfo.getUserId();
        cp3.Approver_L2__c = userinfo.getUserId();
        cp3.Sourcing_Manager__c = userinfo.getUserId();
        cp3.Registration_Complete__c = true;
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.Broker_Type__c = 'Individual';
        cp3.Broker_Pan_No__c = 'ADRPI3525Q';
        cp3.RW_Mobile_No__c = '1234567890';
        cp3.NAME_FIRST__c = 'tets';
        cp3.NAME_MIDDLE__c = 'cp';
        cp3.NAME_LAST__c = 'test';
        cp3.TITLE__c = 'Mr.';
        cp3.Account_Number__c = '465446';
        cp3.Cheque_DD_Favouring_Name__c = 'test cp';
        cp3.IFSC_Code__c = 'BHSHVD';
        cp3.Is_NRI_CP__c = false;
        cp3.RW_Is_GST_Applicable__c = true;
        cp3.Channel_Partner_From_CP_Portal__c =true;
        
        
        
        Sobject objRecord = new Broker__c(
            Name = 'Test CP',
            RW_Email__c = 'teststetig43646@stetig.in',
            Individual_CP__c = true,
            RW_CreateFromIRIS__c = true,
            RW_IRIS_Sync__c = true,
            Place_of_Supply__c = 'Maharashtra',
            Project__c = 'Runwal Bliss',
            Approver_L1__c = userinfo.getUserId(),
            Approver_L2__c = userinfo.getUserId(),
            Registration_Complete__c = true,
            RW_Mobile_No__c = '1234567890',
            Broker_Type__c = 'Individual',
            Broker_Pan_No__c = 'ADRPI3525Q',
            NAME_FIRST__c = 'tets',
            NAME_MIDDLE__c = 'cp',
            NAME_LAST__c = 'test',
            TITLE__c = 'Mr.',
            Account_Number__c = '465446',
            Cheque_DD_Favouring_Name__c = 'test cp',
            IFSC_Code__c = 'BHSHVD',
            Is_NRI_CP__c = false,
            RW_Is_GST_Applicable__c = true,
            Channel_Partner_From_CP_Portal__c =true);
        system.debug('cp id -> '+cp.id);
        system.debug('cp id -> '+cp);
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id limit 1];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.RW_Status__c = 'Active';
        insert objpr;
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
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
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = c.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        CP_Invoice_Approvers_list_CS__c appcs = new CP_Invoice_Approvers_list_CS__c();
        appcs.Name = 'Test123';
        appcs.CP_MIS__c = '56789';
        appcs.CP_Sourcing_Head__c = '1234567';
        insert appcs;
        
        String base64 = EncodingUtil.base64Encode(Blob.valueOf('First Upload Content'));
        
        Test.startTest();
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            //CPProfileUpdate.updateChannelPartner(cp);
            //CPProfileUpdate.getopps('Test 1', 'Runwal Bliss','CloseDate','Asc');
            CPRegisterationController.selfregister(cp2);
        }
        //CPBookingController.getCpMandateBookings('test3', 'test4', 'testunit', 'Yes', 'Yes');
        //CPRegisterationController.selfregister(cp);
        //CPRegisterationController.selfregister(cp3);
        CPRegisterationController.getApprovers('Test123');
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
        ScheduleCPEmailson7n15daysaftercreation obj = new ScheduleCPEmailson7n15daysaftercreation();
        obj.execute(null);
        ScheduleCPReminderEmailsprior3Mons obj1 = new ScheduleCPReminderEmailsprior3Mons();
        obj1.execute(null);
        System.enqueueJob(new SendCPEmails(tempCPIdVsEmailMap, 'Temp_CP_creation_Email'));
        CPRegisterationController.updateDocDetailsnSubmitforAppr(true, false, cp.Id, Date.today()+10, Date.today()+10);
        CPRegisterationController.updateDocDetailsnSubmitforAppr(false, true, cp.Id, Date.today()+10, Date.today()+10);
        CPRegisterationController.getBrokerDetails(null);
        CPRegisterationController.createTempCP(b3);
        Test.stopTest();
    }
    
    @isTest
    public static void CPTest2(){        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
		cp.Latest_RERA_Upload_Status__c = 'Approval Pending';
        cp.RERA_Valid_till__c = Date.today() + 5;
        cp.Latest_RERA_Upload_Processed__c = false;
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
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
        cp.Channel_Partner_From_CP_Portal__c =true; 
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
        ScheduleCPDocApproval obj = new ScheduleCPDocApproval();
        obj.execute(null);
        ScheduleCPReminderEmailsprior3Mons obj1 = new ScheduleCPReminderEmailsprior3Mons();
        obj1.execute(null);
        Test.stopTest();
    }
    
    @isTest
    public static void CPTest3(){        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Company_Name_As_per_RERA__c = 'Runwal Enterprises';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
		cp.Latest_CC_Upload_Status__c = 'Approval Pending';
        cp.CC_Valid_till__c = Date.today() + 5;
        cp.Latest_CC_Upload_Processed__c = false;
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true; 
        insert cp;
        
        
        Test.startTest(); 
        ScheduleCPDocApproval obj = new ScheduleCPDocApproval();
        obj.execute(null);
        Test.stopTest();
    }
}