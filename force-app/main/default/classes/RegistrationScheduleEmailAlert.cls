/*global class RegistrationScheduleEmailAlert implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc){
        //Date dt = Date.today() + 3;
        Date dt = Date.today();
        return Database.getQueryLocator([SELECT Id, Booking__c, Booking__r.Primary_Applicant_Email__c FROM Registration_Schedule__c WHERE Registration_Schedule_Date__c =: dt AND Active__c = true]);
    }
    
    global void execute(Database.BatchableContext bc, List<Registration_Schedule__c> rsList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String orgEmail = Utility.getOrgWideEmailAddress();
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Registration_Schedule_Email'];
        for(Registration_Schedule__c rs : rsList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setToAddresses(new List<String>{rs.Booking__r.Primary_Applicant_Email__c, 'vinay.kumar.os@runwalgroup.in'});
            mail.setToAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
            mail.setOrgWideEmailAddressId(orgEmail);
            String htmlBody = template.HtmlValue; 
            System.debug('htmlBody: ' + htmlBody);
            if(rs.Registration_Schedule_Date__c != null)
                htmlBody = htmlBody.replace('{schDate}', String.valueOf(rs.Registration_Schedule_Date__c));
            else
                htmlBody = htmlBody.replace('{schDate}', '');
            if(rs.Registration_Schedule_Time__c != null)
            	htmlBody = htmlBody.replace('{schTime}', rs.Registration_Schedule_Time__c);
            else
                htmlBody = htmlBody.replace('{schTime}', '');
            if(rs.Venue__c != null)
            	htmlBody = htmlBody.replace('{venue}', rs.Venue__c);
            else
                htmlBody = htmlBody.replace('{venue}', '');
            mail.subject = template.Subject;
            mail.setTemplateId(template.Id);
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
        }
        Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
    }

	global void finish(Database.BatchableContext bc) {}*/

public class RegistrationScheduleEmailAlert{
    /*public static void schedule(){
        Date dt = Date.today();
        List<Registration_Schedule__c> rsList = [SELECT Id, Booking__c, Booking__r.Primary_Applicant_Email__c, Registration_Schedule_Date__c, Registration_Schedule_Time__c, Venue__c FROM Registration_Schedule__c WHERE Registration_Schedule_Date__c =: dt AND Active__c = true];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String orgEmail = Utility.getOrgWideEmailAddress();
        EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Registration_Schedule'];
        for(Registration_Schedule__c rs : rsList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setToAddresses(new List<String>{rs.Booking__r.Primary_Applicant_Email__c, 'vinay.kumar.os@runwalgroup.in'});
            mail.setToAddresses(new List<String>{'vinay.kumar.os@runwalgroup.in'});
            mail.setOrgWideEmailAddressId(orgEmail);
            String htmlBody = template.HtmlValue; 
            System.debug('htmlBody: ' + htmlBody);
            if(rs.Registration_Schedule_Date__c != null)
                htmlBody = htmlBody.replace('{schDate}', String.valueOf(rs.Registration_Schedule_Date__c));
            else
                htmlBody = htmlBody.replace('{schDate}', '');
            if(rs.Registration_Schedule_Time__c != null)
            	htmlBody = htmlBody.replace('{schTime}', rs.Registration_Schedule_Time__c);
            else
                htmlBody = htmlBody.replace('{schTime}', '');
            if(rs.Venue__c != null)
            	htmlBody = htmlBody.replace('{venue}', rs.Venue__c);
            else
                htmlBody = htmlBody.replace('{venue}', '');
            mail.subject = template.Subject;
            mail.setTemplateId(template.Id);
            mail.setHtmlBody(htmlBody);
            mails.add(mail);
        }
        Messaging.SendEmailResult[] result = Messaging.sendEmail(mails);
    }*/
}