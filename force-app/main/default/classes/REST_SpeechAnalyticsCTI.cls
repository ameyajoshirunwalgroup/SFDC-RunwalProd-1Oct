@RestResource(urlMapping='/Integration/SpeechAnalytics/*') 
global class REST_SpeechAnalyticsCTI {
    
    
	
    @HttpPost
    global static void updateCallSummary(){
        RestRequest req = RestContext.request;
        system.debug('req body--: ' + req.requestBody);
        
        String jsonBody = req.requestBody.toString();
        system.debug('jsonBody: ' + jsonBody);
        jsonBody = jsonBody.replaceAll('\"0\"', '"zero"');
        jsonBody = jsonBody.replaceAll('\"1\"', '"one"');
        system.debug('jsonBody updated: ' + jsonBody);
        CallDetails details = new CallDetails();
        details = (CallDetails)JSON.deserialize(jsonBody, CallDetails.class );
        Datetime dt = Datetime.now();
        List<Task> tsk = [SELECT Id, WhatId, WhoId  FROM Task WHERE CallObject =: details.meta.ucid AND ActivityDate =: Date.valueOf(details.meta.call_date)];    
        Id recId;
        if(tsk.size() > 0){
            recId = (tsk[0].WhatId != null) ? tsk[0].WhatId : tsk[0].WhoId;

            String sobjectType;
            if(recId != null){
                sobjectType = recId.getSObjectType().getDescribe().getName();
            }
            
            
            
            Call_Summary__c cs = new Call_Summary__c();
            cs.Agent__c = details.meta.agent;
            cs.Audio_URL__c = details.meta.audio_url;
            cs.Call_Date__c = Date.valueOf(details.meta.call_date);
            cs.Call_Duration__c = Decimal.valueOf(details.meta.call_duration);
            String[] strTimeSplit = details.meta.call_time.split(':');
            Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),Integer.valueOf(strTimeSplit[2]),0); 
            cs.Call_Time__c = timeChange;
            cs.Call_Type__c = details.meta.call_type;
            cs.Campaign__c = details.meta.campaign;
            cs.Disposition__c = details.meta.disposition;
            cs.File_Id__c = details.meta.file_id;
            cs.Language__c = details.meta.language;
            cs.Skill__c = details.meta.skill;
            cs.Summary__c = details.summary_report.summary_info.summary;
            cs.UC_Id__c = details.meta.ucid;
            cs.User_Id__c = details.meta.user_id;
            cs.User_Name__c = details.meta.username;
            if(tsk[0] != null){
                cs.Task_Id__c = tsk[0].Id;
                cs.Related_To_Id__c = (tsk[0].WhatId != null) ? tsk[0].WhatId : tsk[0].WhoId;
            }
            if(details.transcription.zero != null){
                cs.Transcript_1__c = details.transcription.zero.transcript;
                cs.Call_Transcript_1__c = 'https://runwal--c.vf.force.com/apex/CallTranscript?id='+details.meta.ucid+'&num=zero';
            }
            if(details.transcription.one != null){
                cs.Transcript_2__c = details.transcription.one.transcript;
                cs.Call_Transcript_2__c = 'https://runwal--c.vf.force.com/apex/CallTranscript?id='+details.meta.ucid+'&num=one';
            }
            cs.Call_Sentiment__c = details.summary_report.summary_info.sentiment;
            String topicStr = '';
            for(String str : details.summary_report.summary_info.topic){
                topicStr += str + ', ';
            }
            cs.Topic__c = topicStr;
            if(recId != null){
                if(sobjectType == 'Account'){
                    cs.Account__c = recId;
                }else if(sobjectType == 'Booking__c'){
                    cs.Booking__c = recId;
                }else if(sobjectType == 'Lead'){
                    cs.Lead__c = recId;
                }else if(sobjectType == 'Opportunity'){
                    cs.Opportunity__c = recId;
                }
            }
            
            insert cs;
        }
        
        /*String sobjectType;
        if(recId != null){
            sobjectType = recId.getSObjectType().getDescribe().getName();
        }
        
        
        
        Call_Summary__c cs = new Call_Summary__c();
        cs.Agent__c = details.meta.agent;
        cs.Audio_URL__c = details.meta.audio_url;
        cs.Call_Date__c = Date.valueOf(details.meta.call_date);
        cs.Call_Duration__c = Decimal.valueOf(details.meta.call_duration);
        String[] strTimeSplit = details.meta.call_time.split(':');
        Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),Integer.valueOf(strTimeSplit[2]),0); 
        cs.Call_Time__c = timeChange;
        cs.Call_Type__c = details.meta.call_type;
        cs.Campaign__c = details.meta.campaign;
        cs.Disposition__c = details.meta.disposition;
        cs.File_Id__c = details.meta.file_id;
        cs.Language__c = details.meta.language;
        cs.Skill__c = details.meta.skill;
        cs.Summary__c = details.summary_report.summary_info.summary;
        cs.UC_Id__c = details.meta.ucid;
        cs.User_Id__c = details.meta.user_id;
        cs.User_Name__c = details.meta.username;
        if(tsk[0] != null){
            cs.Task_Id__c = tsk[0].Id;
            cs.Related_To_Id__c = (tsk[0].WhatId != null) ? tsk[0].WhatId : tsk[0].WhoId;
        }
        cs.Transcript_1__c = details.transcription.zero.transcript;
        cs.Transcript_2__c = details.transcription.one.transcript;
        cs.Call_Transcript_1__c = 'https://runwal--c.vf.force.com/apex/CallTranscript?id='+details.meta.ucid+'&num=zero';
        cs.Call_Transcript_2__c = 'https://runwal--c.vf.force.com/apex/CallTranscript?id='+details.meta.ucid+'&num=one';
        cs.Call_Sentiment__c = details.summary_report.summary_info.sentiment;
        String topicStr = '';
        for(String str : details.summary_report.summary_info.topic){
            topicStr += str + ', ';
        }
        cs.Topic__c = topicStr;
        if(recId != null){
            if(sobjectType == 'Account'){
                cs.Account__c = recId;
            }else if(sobjectType == 'Booking__c'){
                cs.Booking__c = recId;
            }else if(sobjectType == 'Lead'){
                cs.Lead__c = recId;
            }else if(sobjectType == 'Opportunity'){
                cs.Opportunity__c = recId;
            }
        }
        
        insert cs;*/
    }
    

    
    public class CallDetails{
        public Meta meta;
        public SummaryReport summary_report;
        public Transcription transcription;
    }
    
    public class Meta{
        public String ucid;
        public String audio_url;
        public String call_type;
        public String file_id;
        public String agent;
        public String call_date;
        public String call_time;
        public String username;
        public String skill;
        public String campaign;
        public String disposition;
        public String conversation_mode;
        public String call_duration;
        public String language;
        public String user_id;
    }
    public class SummaryReport{
        public SummaryInfo summary_info;
    }
    public class SummaryInfo{
        public String summary;
        public String sentiment;
        public List<String> topic;
    }
    public class Transcription{
        public Zero zero;
        public One one;
    }
    public class Zero{
        public String transcript;
    }
    public class One{
        public String transcript;
    }
    
}