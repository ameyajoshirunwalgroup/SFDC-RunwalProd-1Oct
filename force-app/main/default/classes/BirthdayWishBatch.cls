global class BirthdayWishBatch implements Database.Batchable < Applicant_Details__c > , Database.AllowsCallouts, Schedulable {

    global Iterable < Applicant_Details__c > start(Database.BatchableContext bc) {

        Date today = System.today();

        system.debug('Today is' + today);
        

        list < Applicant_Details__c > appdelist = [SELECT Id, Name, Email_Address__c, Mobile_Number__c,DOB__c, Booking__c,
            Opportunity__c, OwnerId, Booking__r.Unit_No__r.TowerName__r.RM_Email_Address__c, Applicant_Number__c, Booking__r.RW_Country_Phone_Code__c,
            Booking__r.Project__c, Salutation__c, Booking__r.Primary_Applicant_Name__c FROM Applicant_Details__c
            WHERE Opportunity__r.StageName = 'Unit Booked' AND
            DAY_IN_MONTH(DOB__c) =: today.DAY()
            AND
            CALENDAR_MONTH(DOB__c) =: today.MONTH()
        ];

        system.debug('appdelist :::' + appdelist);
        system.debug('Day:::' + today.DAY());
        system.debug('month:::' + today.MONTH());

        return appdelist;
    }

    global void execute(Database.BatchableContext bc, list < Applicant_Details__c > applist) {
        System.debug('Inside applist:::' + applist);
        if ((applist) != null) {

            list < Messaging.SingleEmailMessage > mail = new list < Messaging.SingleEmailMessage > ();

            list < task> lstTask = new list < task > ();
            List<SMS_Schedule_SMS_c__c> listSMS = new List<SMS_Schedule_SMS_c__c>();
            List<Birthday_Wishes__c> wishes = new List<Birthday_Wishes__c>();

            OrgWideEmailAddress[] owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'greetings@runwal.com']; 
            EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Birthday_Wishes']; //Added by Vinay 06-03-2025
            for (Applicant_Details__c a: applist) {

                Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                list < string > toadd = new list < string > ();
                toadd.add(a.Email_Address__c);
                mail1.settoaddresses(toadd);
				 System.debug('toadd::::' + toadd);
                /*List < String > bccTo = new List < String > {'shobha.shetty@runwal.com', 'vinay.rao@runwal.com'};
                System.debug('bccTo::::' + bccTo);
				mail1.setBccAddresses(bccTo);*/
                if (owea.size() > 0) {
                    mail1.setOrgWideEmailAddressId(owea.get(0).Id);
                }    

                /*mail1.setsubject('Birthday Wishes from Runwal Group');

                //String body = '<html><body style="font-family: arial; font-size: 12pt;"><img  src="https://runwal--uat--c.documentforce.com/servlet/servlet.ImageServer?id=0151e000000KRiV&oid=00D1e0000008lcK&lastMod=1653290058000" height="570" width="350" alt="Happy Birthday"/><br/><br/><br/>';
                String body = '<html><body style="font-family: arial; font-size: 12pt;">Dear ' + a.Salutation__c + ' ' + a.Name + '<br/><br/>';
                body += '<html><body style="font-family: arial; font-size: 12pt;"><img  src="https://runwal--c.ap27.content.force.com/servlet/servlet.ImageServer?id=0155j000000cPxV&oid=00D280000015Emq&lastMod=1653555865000" height="570" width="350" alt="Happy Birthday"/><br/><br/><br/>';
				body += 'Regards, <br/> Runwal Group';

                mail1.sethtmlbody(body);*/
                //Added by Vinay 06-03-2025 Start
                String htmlBody = template.HtmlValue; 
                htmlBody = htmlBody.replace('Customer', a.Salutation__c + ' ' + a.Name);
                String plainTextBody = template.Body;
                mail1.subject = template.Subject;
                mail1.setTemplateId(template.Id);
                mail1.setHtmlBody(htmlBody);   
                mail1.setPlainTextBody(plainTextBody);
                //Added by Vinay 06-03-2025 End
                mail.add(mail1);
                                
                SMS_Schedule_SMS_c__c sms = new SMS_Schedule_SMS_c__c();
                sms.Name = 'Birthday Wishes';
                sms.Immediate__c = true;
                sms.Sender_Mobile__c = a.Mobile_Number__c;
                sms.Opportunity_Lookup__c = a.Opportunity__c;
                sms.SMS_Long_text__c = 'Dear ' + a.Name +  ', the Runwal group wishes you a very happy birthday .May this year be filled with health , happiness & success. We thank you for being a part of the Runwal family' + '\n';
                listSMS.add(sms);
                
                Birthday_Wishes__c bw = new Birthday_Wishes__c();
                bw.Applicant_Name__c = a.Name;
                bw.Applicant_Number__c = a.Applicant_Number__c;
                bw.Booking__c = a.Booking__c;
                bw.DOB__c = a.DOB__c;
                bw.Applicant__c = a.Id;
                bw.Project__c = a.Booking__r.Project__c;
                
                
                 string myphone = '';
                 string mymsg = '';
                 string strURL = ''; 
                List <Vendor__c> vendorlist = new List<Vendor__c>();       
                vendorlist = [SELECT id,Name,Vendor_URL__c,Param_1_Name__c, Param_1_Value__c , Param_2_Name__c, Param_2_Value__c,  Param_3_Name__c, Param_8_Name__c, Param_3_Value__c,Param_5_Name__c, Param_5_Value__c , Param_4_Name__c, Param_4_Value__c , 
                                Param_6_Name__c ,Param_7_Name__c, Param_7_Value__c,  Param_1_Status__c,Param_2_Status__c,Param_3_Status__c,Param_4_Status__c,Param_5_Status__c,Param_6_Status__c,Param_7_Status__c,Param_8_Status__c, Param_8_Value__c
                                FROM Vendor__c WHERE Vendor_Status__c = true  limit 1];
                
                if(a.Mobile_Number__c != null){
                    myphone = a.Mobile_Number__c;
                }       
                mymsg = 'Dear ' + a.Name +  ', the Runwal group wishes you a very happy birthday .May this year be filled with health , happiness & success. We thank you for being a part of the Runwal family' + '\n';
                mymsg = EncodingUtil.URLENCODE(mymsg,'UTF-8');
                mymsg = mymsg.replace('%2B%E2%80%9D','%20');
                mymsg = mymsg.replace('%2B%E2%80%9C','%20');
                
                if(vendorlist[0].Param_1_Status__c == TRUE && vendorlist[0].Param_2_Status__c == TRUE && 
                   vendorlist[0].Param_3_Status__c  == TRUE && vendorlist[0].Param_4_Status__c == TRUE && 
                   vendorlist[0].Param_5_Status__c  == TRUE){        
                        system.debug('Inside 1st IF');
                        strURL = vendorlist[0].Vendor_URL__c + 
                        '?' + vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c+                      
                        '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c+ 
                        '&' + vendorlist[0].Param_3_Name__c + '=' + myphone +  
                        '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c+  
                        '&' + vendorlist[0].Param_5_Name__c + '=' + mymsg +
                        '&' + vendorlist[0].Param_7_Name__c + '=' + vendorlist[0].Param_7_Value__c;
                        
                }
              
                system.debug('strURL in BirthdayWish Class : ' + strURL);  
                                 
                if(!Test.isRunningTest()){
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint (strURL);
                    req.setMethod ('GET');
                    system.debug('req: ' + req);
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('HTTPResponse : '+ res);
                    system.debug('HTTPResponse : '+ res.getBody());
                    system.debug('StatusCode : '+ res.getStatusCode());
                    
                    if(res.getBody() == 'Sent.'){
                        bw.Status__c = 'Sent';
                    }
                    bw.Status_Text__c = res.getBody();
                    wishes.add(bw);

                    SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,a.Booking__r.Primary_Applicant_Name__c,null,null,null,null,null,System.label.Birthday_Wish_Image_Link,'Birthday Wish',a.Booking__r.RW_Country_Phone_Code__c,a.Mobile_Number__c,'Birthday Wish'); // Added by coServe 09-07-2024
                }
                 
            }
            
            Messaging.SendEmailResult[] result = Messaging.sendEmail(mail);
            System.debug('result' + result);
            insert listSMS;
            insert wishes;
        }
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext dc) {

            BirthdayWishBatch b = new BirthdayWishBatch();

        Database.executeBatch(b, 20);
    }
}