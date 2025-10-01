global class PossessionReconciliationEmail implements Database.Batchable<sObject> , Database.Stateful, Schedulable {
    
    public String project;
    public String bookingStatus;
    public List<String> towers;
    public Date startDate;
    public Date endDate;
    public String emailTemplate;
    public Possession_Reconciliation__c posRec;
    
    public String bkgsProcessed = '';
    public Integer count = 0;
    
    global PossessionReconciliationEmail(Possession_Reconciliation__c pr){
        this.project = pr.Project__c;
        this.bookingStatus = pr.Booking_Status__c;
        this.towers = pr.Towers__c.split(',');
        this.startDate = pr.Start_Date1__c;
        this.endDate = pr.End_Date__c;
        this.emailTemplate = pr.Email_Template__c;
        this.posRec = pr;
    }
        
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        if(posRec.End_Date__c >= Date.today()){
            if(!Test.isRunningTest()){
                return Database.getQueryLocator([SELECT Id, Name, RW_Project_Name__c, Unit_No__r.TowerName__r.Name, Primary_Applicant_Email__c,
                                                 Primary_Applicant_Name__c FROM Booking__c WHERE RW_Project_Name__c =: project AND 
                                                 Unit_No__r.TowerName__r.Name =: towers AND Status__c =: bookingStatus AND
                                                 RW_Key_handover_date__c = null]);
            }else{
                return Database.getQueryLocator([SELECT Id, Name, RW_Project_Name__c, Unit_No__r.TowerName__r.Name, Primary_Applicant_Email__c,
                                                 Primary_Applicant_Name__c FROM Booking__c LIMIT 10]);
            }
        }else{
            return Database.getQueryLocator([SELECT Id, Name, RW_Project_Name__c, Unit_No__r.TowerName__r.Name, Primary_Applicant_Email__c,
                                             Primary_Applicant_Name__c FROM Booking__c LIMIT 0]);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<Booking__c> bList){
        System.debug('bList.size(): ' + bList.size());
        if(bList.size()>0){
            OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address =: System.label.Possession_Reconciliation_Email];
            list<Messaging.SingleEmailMessage> messages = new list <Messaging.SingleEmailMessage>();
            list<Messaging.SendEmailResult> results = new list <Messaging.SendEmailResult>();
            List<Possession_Reconciliation_Log__c> logs = new List<Possession_Reconciliation_Log__c>();
            EmailTemplate template = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE 
                                      Name =: posRec.Email_Template__c];
            for(Booking__c bk : bList){
                String htmlBody = template.HtmlValue;
            	String plainTextBody = template.Body;
                Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
                if(bk.Primary_Applicant_Name__c !=null){
                    htmlBody = htmlBody.replace('{!Booking__c.Primary_Applicant_Name__c}', bk.Primary_Applicant_Name__c);
                }
                message.toAddresses = new List<String>{bk.Primary_Applicant_Email__c};
                //message.toAddresses = new List<String>{'vinaykumar.v@coservesolutions.com'};
                message.subject = template.Subject;
                message.setTemplateId(template.Id);
                message.setHtmlBody(htmlBody);   
                message.setOrgWideEmailAddressId(owea[0].Id);
                message.setReplyTo(System.label.Possession_Reconciliation_Email);
                message.setWhatId(bk.Id);
                messages.add(message);
                
                Possession_Reconciliation_Log__c prlog = new Possession_Reconciliation_Log__c();
                prlog.Email_Template__c = posRec.Email_Template__c;
                prlog.Schedule_Running_Date__c = Date.today();
                prlog.Possession_Reconciliation__c = posRec.Id;
                prlog.Booking__c = bk.Id;
                prlog.Status__c = 'Sent';
                prlog.Project_Name__c = posRec.Project__c;
                logs.add(prlog);
            }
            System.debug('messages.size(): ' + messages.size());
            if(!Test.isRunningTest()){
                //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                results = Messaging.sendEmail(messages);
                insert logs;
            }
        }
    }
    global void finish(Database.BatchableContext bc) {
        if(posRec.End_Date__c != null && posRec.End_Date__c <= Date.today()){
            String name = 'PossessionReconciliationEmail- ' + posRec.Project__c;
            //if(!Test.isRunningTest()){
                CronTrigger jobRecord = [SELECT  Id FROM CronTrigger  where CronJobDetail.Name =: name];
				System.abortJob(jobRecord.Id);
            //}
        }
    }
    
    global void execute(SchedulableContext dc) {
        PossessionReconciliationEmail b = new PossessionReconciliationEmail(posRec);
        Database.executeBatch(b, 1);
    }
}