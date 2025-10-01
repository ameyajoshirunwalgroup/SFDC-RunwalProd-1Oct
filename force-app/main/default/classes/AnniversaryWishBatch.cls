global class AnniversaryWishBatch implements Database.Batchable < Applicant_Details__c > , Schedulable {

    global Iterable < Applicant_Details__c > start(Database.BatchableContext bc) {

        Date today = system.today();

        system.debug('Today is' + today);

        list < Applicant_Details__c > appdelist = [SELECT Name, Email_Address__c, Mobile_Number__c,
            Opportunity__c, OwnerId, Booking__r.Unit_No__r.TowerName__r.RM_Email_Address__c

            FROM Applicant_Details__c
            WHERE
            DAY_IN_MONTH(Anniversary__c) =: today.DAY()
            AND
            CALENDAR_MONTH(Anniversary__c) =: today.MONTH()
        ];

        system.debug(' inside appdelist :::' + appdelist);
        system.debug('Day:::' + today.DAY());
        system.debug('month:::' + today.MONTH());

        return appdelist;
    }

    global void execute(Database.BatchableContext bc, list < Applicant_Details__c > applist) {

        if ((applist) != null) {

            System.debug(' inside another applist:::' + applist);

            list < Messaging.SingleEmailMessage > mail = new list < Messaging.SingleEmailMessage > ();
           
            list < task> lstTask = new list < task > ();

            for (Applicant_Details__c a: applist) {

                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();

                list < string > toadd = new list < string > ();

                toadd.add(a.Email_Address__c);

                mail1.settoaddresses(toadd);

                List < String > ccTo = new List < String > ();
                if (a.Booking__r.Unit_No__r.TowerName__r.RM_Email_Address__c != null & a.Booking__r.Unit_No__r.TowerName__r.RM_Email_Address__c != '') {
                    ccTo.add(a.Booking__r.Unit_No__r.TowerName__r.RM_Email_Address__c);
                    mail1.setCcAddresses(ccTo);
              
                }
                System.debug('ccTo::::' + ccTo);

                OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'greetings@runwal.com']; 
                System.debug('organization wide emails:' + owea.get(0).Id);
                if (owea.size() > 0) {
                    mail1.setOrgWideEmailAddressId(owea.get(0).Id);
              System.debug('inside from' + owea );      
                }

                

                mail1.setsubject('Anniversary wishes');

              //  string body = '<html><body style="font-family: arial; font-size: 12pt;"><img  src="https://runwal--devsb2--c.cs72.content.force.com/servlet/servlet.ImageServer?id=0155D000000G9N4&oid=00D5D0000004bdf" height="500" width="800" alt="Happy Anniversary"/>';

               string body = '<html><body style="font-family: arial; font-size: 12pt;"><img  src="https://runwal--c.ap7.content.force.com/servlet/servlet.ImageServer?id=0150I000007FEEi&oid=00D280000015Emq&lastMod=1538559344000" height="500" width="800" alt="Happy Anniversary"/>';

                mail1.sethtmlbody(body);

                mail.add(mail1);
                
               System.debug('inside mail1' + mail1);
                
                task t = new task();
                t.WhatId = a.Opportunity__c;
                t.OwnerId = a.OwnerId;
                t.activityDate = System.today();
                t.Call_Time__c = System.Now().format('h:mm a');
                t.status = 'open';
                t.Subject = 'Anniversary Wish';
                t.priority = 'Normal';
               
                t.ReminderDateTime = System.now().addHours(8);

               // t.ReminderDateTime = System.now().addMinutes(2);

                t.IsReminderSet = true;

                //lstTask.add(t);
                
                 System.debug('inside lstTask' + lstTask);
            }
            
           
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mail);
            //insert lstTask;

        }
    }

    global void finish(Database.BatchableContext bc) {}
    global void execute(SchedulableContext dc) {

        AnniversaryWishBatch b = new AnniversaryWishBatch();

        Database.executeBatch(b, 20);
    }
}