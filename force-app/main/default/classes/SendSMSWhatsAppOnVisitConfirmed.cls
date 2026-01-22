public class SendSMSWhatsAppOnVisitConfirmed {
    
    @invocablemethod
    Public static void  SMSWhatsAppOnVisitConfirmed(List<Id> Ids){
        system.debug('Process builder Ids_______ '+ Ids);
        Set<ID> setOfLead = new Set<ID>();
        Set<ID> setOfOpp = new Set<ID>();
        //Opportunity
        Task tsk = [select id,Communication_Type__c,Task_Type__c, Call_Status__c, Call_Proposed_date_of_visit__c, Call_Attempt_Status__c, 
                    Project__c,Project__r.Name, whoId, whatId from Task Where ID In: Ids Limit 1];
        setOfLead.add(tsk.WhoId);
        setOfOpp.add(tsk.WhatId);
        
        Datetime myDateTime =  tsk.Call_Proposed_date_of_visit__c;
        string mydateStr = myDateTime.format('MM/dd/yyyy');
        string myTimeStr = myDateTime.format('hh:mm aa');
        system.debug('____Date_____'+ mydateStr);
        system.debug('____Time_____'+ myTimeStr);  
        
        if(tsk.WhoId != null && tsk.WhoId.getSObjectType()==Lead.sObjectType){
            sendSMSWhatsApp(setOfLead,tsk,mydateStr,myTimeStr);   
        }
        else if(tsk.WhatId != null && tsk.WhatId.getSObjectType()==Opportunity.sObjectType){
            sendSMSWhatsApp(setOfOpp,tsk,mydateStr,myTimeStr);   
        }     
    }
    
    public static void sendSMSWhatsApp(Set<ID> setOfLedOppId, Task tsk,String mydateStr,String myTimeStr){
        system.debug('Task_______ '+ tsk);
        system.debug('setOfLedOppId_______ '+ setOfLedOppId);
        String whatsAppSignature;
        String smsSignature;
        String ledOppMbl;
        String ledOppSource;
        String ledOppCountryCode; //Added by Vinay 13-10-2025
        Lead led;
        Opportunity opp;
        RW_Presales_Communication__c preComm = New RW_Presales_Communication__c();
        
        if(tsk.WhoId != null && tsk.WhoId.getSObjectType()==Lead.sObjectType){
            led = [select Id,Name,RW_Mobile_No__c,LeadSource,RDS_Country_Code__c From Lead WHERE Id=: setOfLedOppId];
            preComm.RW_Lead__c = led.Id;
            ledOppMbl = led.RW_Mobile_No__c;
            ledOppSource = led.LeadSource;
            ledOppCountryCode = led.RDS_Country_Code__c; //Added by Vinay 13-10-2025
        }else if(tsk.WhatId != null && tsk.WhatId.getSObjectType()==Opportunity.sObjectType){
            opp = [select Id,Name,RW_Mobile_No__c,LeadSource,Account.Country_Code__c From Opportunity WHERE Id=: setOfLedOppId];
            preComm.RW_Opportunity__c = opp.Id;
            ledOppMbl = opp.RW_Mobile_No__c;
            ledOppSource = opp.LeadSource;
            ledOppCountryCode = opp.Account.Country_Code__c; //Added by Vinay 13-10-2025
        }
        
        System.debug('led: ' + led);
        System.debug('opp: ' + opp);
        
        if(String.isNotBlank(ledOppSource)){
           /* if(ledOppSource == 'Channel Partner'){
                whatsAppSignature = System.Label.RW_CPSignatureVisitConfirmed;
                smsSignature =  'Team Runwal,'; 
            }else if(ledOppSource != 'Channel Partner'){
                whatsAppSignature = System.Label.RW_NotCPSignatureVisitConfirmed;
                smsSignature = 'Team Presales,';
            }*/
            
            if(tsk.Task_Type__c == 'Presales Call')
            {
                whatsAppSignature = System.Label.RW_NotCPSignatureVisitConfirmed;
                smsSignature = 'Team Presales,';
            }
            else
            {
                whatsAppSignature = System.Label.RW_CPSignatureVisitConfirmed;
                smsSignature =  'Team Runwal,'; 
            }
        }       
        
        system.debug('ledOppMbl_______ '+ ledOppMbl);
        
        If(String.isNotBlank(ledOppMbl)){
            String SMSBody = 'Thank you for confirming your site visit to ' + tsk.Project__r.Name + ' on ' + mydateStr + ' at ' + myTimeStr + ' We look forward to seeing you. With Warm Regards,' + smsSignature + 'Runwal Group'; 
            
            SMS_Schedule_SMS_c__c s = new SMS_Schedule_SMS_c__c();
            s.Name = 'Presales Visit Confirmed';
            s.Immediate__c = True;
            s.Sender_Mobile__c= ledOppMbl;
            s.SMS_Long_text__c= SMSBody;
            insert s; 
            preComm.RW_Visit_Confirmed_Mode_of_Communication__c  = 'SMS';
        }
        
        if(String.isNotBlank(tsk.Project__r.Name) && String.isNotBlank(mydateStr) && String.isNotBlank(myTimeStr) 
           && String.isNotBlank(ledOppMbl) && String.isNotBlank(System.Label.Lead_Visit_Confirmed2_HSM)
           && String.isNotBlank(System.Label.StopWhatsAppOnVisitConfirmed) && System.Label.StopWhatsAppOnVisitConfirmed == 'No'){
               //Added by Vinay 29-10-2021
               if((opp != null && opp.LeadSource != 'Channel Partner') || (led != null && led.LeadSource != 'Channel Partner')){
                    /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(tsk.Project__r.Name, mydateStr, myTimeStr,whatsAppSignature,
                                                              null,null,null,null,null,ledOppMbl,System.Label.Lead_Visit_Confirmed2_HSM);*/
                    /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(tsk.Project__r.Name, mydateStr, myTimeStr,whatsAppSignature,
                                                              null,null,null,null,null,ledOppMbl,'Lead Visit Confirmed2');*/ //Commented by Vinay 13-10-2025
                    if(System.label.Haptik_API_Version == 'New'){ //Added by Vinay 13-10-2025
                        SendWhatsAppMsg.methodToSendWhatsAppMsgNew(tsk.Project__r.Name, mydateStr, myTimeStr,whatsAppSignature,null,null,null,null,null,ledOppCountryCode,ledOppMbl,'Lead Visit Confirmed2');
                    }else{
                        SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(tsk.Project__r.Name, mydateStr, myTimeStr,whatsAppSignature,
                                                              null,null,null,null,null,ledOppMbl,'Lead Visit Confirmed2');
                    }
               		preComm.RW_Visit_Confirmed_Mode_of_Communication__c += ',WhatsApp';
               }
               //Commented by Vinay 29-10-2021
               /*SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg(tsk.Project__r.Name, mydateStr, myTimeStr,whatsAppSignature,
                                                              null,null,null,null,null,ledOppMbl,System.Label.Lead_Visit_Confirmed2_HSM);
               preComm.RW_Visit_Confirmed_Mode_of_Communication__c += ',WhatsApp';*/
               
           }
        
        
        preComm.RW_Visit_Cnfrmed_SMS_WhatsApp_Sent_Date__c = system.now();
        insert preComm;
        System.debug('RW_Presales_Communication__c Record inserted______ ' +preComm);
        
    }
}