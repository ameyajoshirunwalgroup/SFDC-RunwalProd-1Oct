@isTest
public class Test_Batch_DemandAgeingNotifications {
  
    @isTest
    public static void TestMethod1(){
        // Setup test data
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create Team Leader user with email
        User teamLeader = new User(
            FirstName = 'Team',
            LastName = 'Leader',
            Email = 'vinit.lasne@ubsdigicloud.com',
            Username = 'teamleader@example.com.test',
            Alias = 'tlead',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = p.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert teamLeader;
        
        // Create project with Team Leader
        Project__c project = new Project__c(
            Name = 'Test Project',
            Team_Leader__c = teamLeader.Id
        );
        insert project;
        
        // Create booking
        Booking__c booking = new Booking__c(
            Project__c = project.Id
        );
        insert booking;
        
        // Create demand with due date in past
        RW_Demand__c demand = new RW_Demand__c(
            Name = 'Test Demand',
            Booking__c = booking.Id,
            RW_Demand_Status__c = 'Due',
            Due_Date__c = Date.today().addDays(-5),
            PTP_Date__c = Date.today().addDays(-3)
        );
        insert demand;
        
        // Create the correct email template
        EmailTemplate emailTemplate;
        try {
            // Use the email template folder (more reliable approach)
            List<Folder> folders = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];
            if(!folders.isEmpty()) {
                emailTemplate = new EmailTemplate(
                    Name = 'Notify TL Regarding Demand Ageing',
                    DeveloperName = 'Notify_TL_Regarding_Demand_Ageing_VF',
                    TemplateType = 'custom',
                    Subject = 'Test Subject',
                    HtmlValue = '<p>This is a test</p>',
                    IsActive = true,
                    FolderId = folders[0].Id
                );
                insert emailTemplate;
            }
        } catch(Exception e) {
            System.debug('Error creating template: ' + e.getMessage());
        }
        
        // Start test context
        Test.startTest();
        // Execute batch
        Batch_DemandAgeingNotifications objBatch = new Batch_DemandAgeingNotifications();
        Id batchId = Database.executeBatch(objBatch);
        Test.stopTest();
        
       
    }
}