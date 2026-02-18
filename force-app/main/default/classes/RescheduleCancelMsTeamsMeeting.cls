public class RescheduleCancelMsTeamsMeeting{
    
    ///This method is to get CriticalNonCriticalLineItems from custom meta data
    @AuraEnabled
    public static RW_MS_Teams__c msTeamRecord(String MsRecordID){
        RW_MS_Teams__c msTeam =  [SELECT Id, Name, RW_Start_Time__c, RW_End_Time__c, RW_Opportunity__c, RW_URL_Recording__c,RW_Lead__c, RW_Status__c, RW_Title__c, RW_MeetingID__c, RW_Lead__r.Email, RW_Lead__r.Name,RW_Opportunity__r.RW_Email__c, RW_Opportunity__r.Name,RW_Meeting_Content__c,RW_Object_Type__c FROM RW_MS_Teams__c where Id =: MsRecordID];
        return msTeam;
    }
    
    @AuraEnabled
    public static RW_MS_Teams__c reScheduleMSMeeting(Id MsRecordID, string sobjecttype, Datetime startTime, Datetime endTime,string content, string btnLable, string leadId,string leadEmail, string leadName, string oppId,string oppEmail, string oppName, string meetingID, string subject){
        
        /*  RW_MS_Teams__c msTeam = [SELECT Id, Name, RW_Start_Time__c, RW_End_Time__c, RW_Opportunity__c, RW_URL_Recording__c, 
RW_Lead__c, RW_Status__c, RW_Title__c, RW_MeetingID__c, RW_Lead__r.Email, RW_Lead__r.Name,
RW_Opportunity__r.RW_Email__c, RW_Opportunity__r.Name,RW_Meeting_Content__c FROM 
RW_MS_Teams__c where Id =: MsRecordID];*/
        
        RW_MS_Teams__c msTem = new RW_MS_Teams__c(Id = MsRecordID);  
        
        if(btnLable == 'Reschedule'){ 
            String startTimeFormatted = startTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            
            String endTimeFormatted = endTime.format('yyyy-MM-dd\'T\'HH:mm:ss');
            
            //Json from
            JsonClsReSchedule objJson  = new JsonClsReSchedule();
            objJson.subject = subject;
            
            JsonClsReSchedule.cls_body clsBdy = new JsonClsReSchedule.cls_body();
            clsBdy.contentType = 'HTML';
            clsBdy.content = content;
            objJson.body = clsBdy;
            JsonClsReSchedule.cls_start clsStart = new JsonClsReSchedule.cls_start();
            clsStart.dateTime_start = startTimeFormatted;
            clsStart.timeZone = 'India Standard Time';
            objJson.start = clsStart;
            JsonClsReSchedule.cls_end clsEnd = new JsonClsReSchedule.cls_end();
            clsEnd.dateTime_End = endTimeFormatted;
            clsEnd.timeZone = 'India Standard Time';
            objJson.end_end = clsEnd;
            JsonClsReSchedule.cls_location clsLoc = new JsonClsReSchedule.cls_location();
            clsLoc.displayName = 'online';
            objJson.location = clsLoc;
            list<JsonClsReSchedule.cls_attendees> listAtten = new list<JsonClsReSchedule.cls_attendees>();
            JsonClsReSchedule.cls_attendees clsAtt = new JsonClsReSchedule.cls_attendees();
            JsonClsReSchedule.cls_emailAddress emailAdd = new JsonClsReSchedule.cls_emailAddress();
            if(!String.isBlank(leadId)){
                emailAdd.address = leadEmail;
                emailAdd.name = leadName;                           
            }else if(!String.isBlank(oppId)){
                emailAdd.address = oppEmail;
                emailAdd.name = oppName;     
            }
            clsAtt.emailAddress = emailAdd;
            clsAtt.type = 'required';
            listAtten.add(clsAtt);
            objJson.attendees = listAtten;
            objJson.allowNewTimeProposals = true;
            objJson.isOnlineMeeting = true;
            objJson.onlineMeetingProvider = 'teamsForBusiness';
            objJson.id = meetingID;
            
            string str = System.JSON.serialize(objJson);
            String targetDateTimeStart = 'dateTime_start';
            String targetDateTimeEnd = 'dateTime_End';
            String targetEnd = 'end_end';
            String replaceDateTime = 'dateTime';
            String replaceEnd = 'end';
            str = str.replace(targetDateTimeStart, replaceDateTime);
            str = str.replace(targetDateTimeEnd, replaceDateTime);
            str = str.replace(targetEnd, replaceEnd);
            
            String meetingIdResch = 'callout:MS_Teams/v1.0/me/events/'+meetingID;
            
            //callout
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req.setMethod('PATCH');
            req.setHeader('Content-Type',  'application/json');
            req.setHeader('Accept', 'application/json'); 
            req.setEndpoint(meetingIdResch);
            req.setBody(str);
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200){
                
                msTem.RW_Title__c = subject;
                msTem.RW_Start_Time__c = startTime;
                msTem.RW_End_Time__c = endTime;
                msTem.RW_Status__c = btnLable;
                msTem.RW_Meeting_Content__c = content;
                msTem.RW_MeetingID__c = meetingID;
                msTem.RW_OnlineMeeting_JoinUrl__c = '';
                //msTem.RW_OnlineMeeting_JoinUrl__c = respJsonSchedule.onlineMeeting.joinUrl;
                system.debug('### sobjecttype '+sobjecttype);
                If(sobjecttype == 'Lead'){
                    msTem.RW_Lead__c = leadId;
                }else if(sobjecttype == 'Opportunity'){
                    msTem.RW_Opportunity__c = oppId;
                }
                
                update msTem;   
            } 
        }
        return msTem;                                              
    }
    
    @AuraEnabled
    public static RW_MS_Teams__c cancelMSMeeting(Id MsRecordID, string sobjecttype, string btnLable,string meetingID){
        
        RW_MS_Teams__c msTem = new RW_MS_Teams__c(Id = MsRecordID); 
        
        if(btnLable == 'Cancel'){
            JsonClsReSchedule objJson  = new JsonClsReSchedule();
            //objJson.Comment = 'Cancelling this Meeting';
            string josnBody = System.JSON.serialize(objJson);
            
            //callout
            if(meetingID != null){
                String meetingIdCancel = 'callout:MS_Teams/v1.0/me/events/'+meetingID+'/cancel';
                Http http = new Http();
                HttpRequest req = new HttpRequest(); 
                req.setMethod('POST');
                req.setHeader('Content-Type',  'application/json');
                req.setHeader('Accept', 'application/json'); 
                req.setEndpoint(meetingIdCancel);//callout:MS_Teams/events
                req.setBody(josnBody);
                HTTPResponse res = http.send(req);
                
                
                if(res.getStatusCode() == 202){
                    
                    msTem.RW_Status__c = btnLable;
                    update msTem;  
                }
            }
            
        }
        return msTem;
    }
}