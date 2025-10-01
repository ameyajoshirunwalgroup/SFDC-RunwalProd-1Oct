global class Batch_SendEscallationMail implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT id, Subject, ActivityDate from task where ActivityDate <= TODAY AND Status != 'Completed']);
    }
    global void execute(Database.BatchableContext BC,list<task> lstTask)
    {
        if(lstTask!=null && lstTask.size()>0)
        {
            List<Profile> AllPro = [SELECT Id, name FROM Profile WHERE Name='Pre Sales Manager' or Name='System Administrator' or Name='Director']; 
            string Presale;
            string Admin;
            string Directr;
            if(AllPro!=null && AllPro.size()>0)
            {
                for(Profile EachPro : AllPro)
                {
                    if(EachPro.name == 'Pre Sales Manager')
                    Presale = EachPro.id;
                    else if(EachPro.name == 'System Administrator')
                    Admin = EachPro.id;
                    else if(EachPro.name == 'Director')
                    Directr = EachPro.id;
                }
            }
            list<User> AllUser = [select Id, name, Email, ProfileId from user where ProfileId =: Presale or ProfileId =: Admin or ProfileId =: Directr];
            List<string> PresaleUsr = new List<string>();
            List<string> AdminUsr = new List<string>();
            List<string> DirectrUsr = new List<string>();
            List<string> PresaleEmail = new List<string>();
            List<string> AdminEmail = new List<string>();
            List<string> DirectrEmail = new List<string>();
            if(AllUser!=null && AllUser.size()>0)
            {
                for(User EachUsr : AllUser)
                {
                    if(EachUsr.ProfileId == Presale)
                    {
                        PresaleUsr.add(EachUsr.name);
                        PresaleEmail.add(EachUsr.Email);
                    }
                    else if(EachUsr.ProfileId == Admin)
                    {
                        AdminUsr.add(EachUsr.name);
                        AdminEmail.add(EachUsr.Email);
                    }
                    else if(EachUsr.ProfileId == Directr)
                    {
                        DirectrUsr.add(EachUsr.name);
                        DirectrEmail.add(EachUsr.Email);
                    }
                }
            }
            if(lstTask!=null && lstTask.size()>0)
            {
                List<Messaging.SingleEmailMessage> mails2Send = new List<Messaging.SingleEmailMessage>();
                for(task eachTask : lstTask)
                {
                    //system.debug('@eachTask----------'+eachTask.ActivityDate);
                    if(eachTask.ActivityDate == system.today() && PresaleEmail!=null && PresaleEmail.size()>0 && PresaleUsr!=null && PresaleUsr.size()>0)
                    {
                        Messaging.SingleEmailMessage EachMail = new Messaging.SingleEmailMessage();
                        EachMail.setToAddresses(PresaleEmail);
                        EachMail.setReplyTo('adarsha.nanda@saasfocus.com');
                        EachMail.setSenderDisplayName('Runwal Homes');
                        EachMail.setSubject('Escalation Lead');
                        String body = 'Dear '+PresaleUsr[0]+', <br/>';
                        body += 'This is to inform you that the task <b>'+eachTask.Subject+'</b> has been escalated.<br/><br/>Thanks<br/>Runwal Homes';
                        EachMail.setHtmlBody(body);
                        mails2Send.add(EachMail);
                    }
                    if(eachTask.ActivityDate.addDays(1) == system.today() && AdminEmail!=null && AdminEmail.size()>0 && AdminUsr!=null && AdminUsr.size()>0)
                    {
                        Messaging.SingleEmailMessage EachMail = new Messaging.SingleEmailMessage();
                        EachMail.setToAddresses(AdminEmail);
                        EachMail.setReplyTo('adarsha.nanda@saasfocus.com');
                        EachMail.setSenderDisplayName('Runwal Homes');
                        EachMail.setSubject('Escalation Lead');
                        String body = 'Dear '+AdminUsr[0]+', <br/>';
                        body += 'This is to inform you that the task <b>'+eachTask.Subject+'</b> has been escalated.<br/><br/>Thanks<br/>Runwal Homes';
                        EachMail.setHtmlBody(body);
                        mails2Send.add(EachMail);
                    }
                    if(eachTask.ActivityDate.addDays(2) == system.today() && DirectrEmail!=null && DirectrEmail.size()>0 && DirectrUsr!=null && DirectrUsr.size()>0)
                    {
                        Messaging.SingleEmailMessage EachMail = new Messaging.SingleEmailMessage();
                        EachMail.setToAddresses(DirectrEmail);
                        EachMail.setReplyTo('adarsha.nanda@saasfocus.com');
                        EachMail.setSenderDisplayName('Runwal Homes');
                        EachMail.setSubject('Escalation Lead');
                        String body = 'Dear '+DirectrUsr[0]+', <br/>';
                        body += 'This is to inform you that the task <b>'+eachTask.Subject+'</b> has been escalated.<br/><br/>Thanks<br/>Runwal Homes';
                        EachMail.setHtmlBody(body);
                        mails2Send.add(EachMail);
                    }
                }
                try 
                {
                    if(mails2Send!=null)
                    Messaging.sendEmail(mails2Send);    
                }
                catch (exception e)
                {
                    System.debug('exception in mail sending'+e);
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC)
    {

    }
}