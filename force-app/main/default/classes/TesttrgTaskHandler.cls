@isTest
public class TesttrgTaskHandler {
    
    @isTest(SeeAllData=false)
    private static void TestCreateTask(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        lstUser.add(new User(LastName = 'Test',
                             FirstName='Test1 User',
                             Alias = 'tstU1',
                             Email = 'testUsr1@stetig.in',
                             Username = 'testUsr1@stetig.in',
                             ProfileId = profileId.id,
                             CTI_Agent_ID__c = 'test.test1',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US',
                             Phone = '4567569354',
                             Offline_Agent_Name__c = 'Pranay'
                            ));
        lstUser.add(new User(LastName = 'Test2',
                             FirstName='Test User2',
                             Alias = 'tstU2',
                             Email = 'testUsr2@stetig.in',
                             Username = 'testUsr2@stetig.in',
                             ProfileId = profileId.id,
                             department='presales',
                             CTI_Agent_ID__c = 'test.test2',
                             TimeZoneSidKey = 'America/Los_Angeles',
                             EmailEncodingKey = 'UTF-8',
                             LanguageLocaleKey = 'en_US',
                             LocaleSidKey = 'en_US'));
        insert lstUser;
        
        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        
        Campaign campaign=new Campaign();
        campaign=new Campaign(name='Inbound_918068442375',isactive=true,TollFree_Number__c='918068442375',Digital_Maketing_Campaign_Code__c='918068442375', Primary_Project__c = objProject.Id);
        insert campaign;
        
        task t = new task();
        t.status = 'In-Progress';
        t.OwnerId = lstUser[0].id;
        t.Subject = 'Missed Call';
        t.Call_Attempt_Status__c = 'Missed Call';
        t.status = 'Completed';
        t.WhoId = objLead.id;
        t.Priority = 'Normal';
        t.Call_Attempt_Status__c = 'Completed'; 
        t.Lead_Account_Name__c = objLead.Name;
        t.Type_Of_Meeting__c = 'callType';
        t.Voice_Log_URL__c = 'recordingFile';
        t.Call_Status__c = 'callStatus';
        t.Campaign_Name_from_CTI__c = 'CampaignNameCTI';
        t.Visit_Form_No__c = 'did';
        t.Remarks__c = 'UUI';
        t.CallObject = 'ucid';
        t.Attempted_By__c = lstUser[0].Name;
        t.CallType__c = 'Outbound';
        t.Communication_Type__c = 'Outbound Call';
        insert t;
        
        task t1 = new task();
        t1.Subject = 'New Task';
        t1.Task_Type__c = 'Sales Call';
        t1.activityDate = System.Today();
        t1.WhoId = objLead.Id;
        t1.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        t1.call_time__c = TaskManagementServices.FormatTime(system.now());
        t1.ActivityDate__c = '25/05/2021';
        t1.ActivityDate = System.Today();
        t1.Next_Action_Date__c = System.Today();
        t1.CallType = 'Inbound';
        insert t1;

        t1.CallType = 'Outbound';
        t1.Next_Action_Date__c = System.Today() + 1; //Added by Vinay 12-08-2025
        update t1;
        
    }

    @isTest
    private static void testTask(){

        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;

        Task tsk = new Task();
        tsk.WhoId = objLead.Id;
        tsk.Disposition_Type__c = 'Success';
        tsk.Subject = 'New Enquiry Received From:Digital';
        tsk.Description = 'phone_number';
        insert tsk;
        
    }
    
    @isTest
    private static void testScheduleCall1(){ //Added by Vinay 18-08-2025

        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;

        Scheduled_Call__c sc = new Scheduled_Call__c();
        sc.Related_Record_Id__c = objLead.Id;
        sc.Schedule_Date__c = System.Today();
        insert sc;
        
        Id PresalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        
        List<Task> tskList = new List<Task>();
        Task tsk = new Task();
        tsk.WhoId = objLead.Id;
        tsk.Disposition_Type__c = 'Success';
        tsk.Subject = 'New Enquiry Received From:Digital';
        tsk.Description = 'phone_number';
        tsk.Next_Action_Date__c = System.Today() + 1;
        tsk.Task_Type__c = 'Presales Call';
        tsk.RecordTypeId = PresalesRecordTypeId;
        insert tsk;
        
        ScheduleOzonetelCalls.callSchedule(new List<Task>{tsk});
    }
    
    @isTest
    private static void testScheduleCall2(){ //Added by Vinay 18-08-2025

        Project__c objProject = new Project__c();
        objProject.name = 'test';
        objProject.RW_Status__c = 'Active';
        insert objProject ;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test12@gmail.com';
        objLead.MobilePhone = '9243562121';
        objLead.RW_Mobile_No__c = '9243562121';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.RW_Project__c = objProject.id; 
        objLead.CP_Lead_Status__c = 'Active';
        objLead.IsConverted = false;
        insert objLead;
        
        Id PresalesRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Presales Task').getRecordTypeId();
        
        List<Task> tskList = new List<Task>();
        Task tsk = new Task();
        tsk.WhoId = objLead.Id;
        tsk.Disposition_Type__c = 'Success';
        tsk.Subject = 'New Enquiry Received From:Digital';
        tsk.Description = 'phone_number';
        tsk.Next_Action_Date__c = System.Today() + 1;
        tsk.Task_Type__c = 'Presales Call';
        tsk.RecordTypeId = PresalesRecordTypeId;
        insert tsk;
        
        ScheduleOzonetelCalls.callSchedule(new List<Task>{tsk});
    }
}