@RestResource(urlMapping='/CallSummary/*')
global with sharing class CallSummaryRestService {
    
    @HttpPost
    global static ResponseWrapper handleCallSummary() {
        RestRequest req = RestContext.request;
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            String requestBody = req.requestBody.toString();
            System.debug('requestBody: ' + requestBody);
            
            if (String.isBlank(requestBody)) {
                response.success = false;
                response.message = 'Payload body is empty.';
                RestContext.response.statusCode = 400;
                return response;
            }
            
            CallSummaryPayload data = CallSummaryPayload.parse(requestBody);
            System.debug('data: ' + data); 

            String ucid = data.meta != null ? (String.isNotBlank(data.meta.monitorUCID)? data.meta.monitorUCID : null) : null;
            if (ucid == null) {
                response.success = false;
                response.message = 'Please pass valid monitorUCID';
                RestContext.response.statusCode = 400;
                return response;
            }
            Call_Summary__c cs = (String.isNotBlank(ucid))? ((existingCallSummary(ucid) != null)? existingCallSummary(ucid) : new Call_Summary__c()) : new Call_Summary__c();

            //String relatedRecId = (String.isNotBlank(ucid))? fetchRelatedId(ucid) : null; //Commented by Vinay 25-09-2026
            RelatedRecordsWrapper relatedRecWrap = fetchRelatedRecordIds(ucid); //Added by Vinay 25-09-2026
            //String objName = (relatedRecId != null)? Id.valueOf(relatedRecId).getSObjectType().getDescribe().getName() : ''; //Commented by Vinay 25-09-2026
            String objName = (relatedRecWrap.relatedRecId != null)? Id.valueOf(relatedRecWrap.relatedRecId).getSObjectType().getDescribe().getName() : ''; //Added by Vinay 25-09-2026

            //Call_Summary__c cs = new Call_Summary__c();
            if(objName == 'Opportunity'){
                //cs.Opportunity__c = relatedRecId; //Commented by Vinay 25-09-2026
                cs.Opportunity__c = relatedRecWrap.relatedRecId; //Added by Vinay 25-09-2026
            }else if(objName == 'Booking__c'){
                //cs.Booking__c = relatedRecId; //Commented by Vinay 25-09-2026
                cs.Booking__c = relatedRecWrap.relatedRecId; //Added by Vinay 25-09-2026
            }
            cs.Case__c = relatedRecWrap.caseId; //Added by Vinay 25-09-2026
            cs.Task_Id__c = relatedRecWrap.taskId; //Added by Vinay 25-09-2026
            cs.Task_Subject__c = relatedRecWrap.taskSubject; //Added by Vinay 25-09-2026
            
            if(data.meta != null){
                cs.Monitor_UCID__c = data.meta.monitorUCID;
                cs.Caller_ID__c = data.meta.CallerID;
                cs.Agent_Id__c = data.meta.AgentID;
                cs.Type__c = data.meta.Type;
                cs.Start_Time__c = (String.isNotBlank(data.meta.StartTime) && isValidDateTimeFormat(data.meta.StartTime))? Datetime.valueOf(data.meta.StartTime) : null;
                cs.End_Time__c = (String.isNotBlank(data.meta.EndTime) && isValidDateTimeFormat(data.meta.StartTime))? Datetime.valueOf(data.meta.EndTime) : null;
                cs.Agent__c = data.meta.AgentName;
                cs.Campaign_Name__c = data.meta.Campaign;
                cs.Skill__c = data.meta.Skill;
                cs.Call_Date__c = (String.isNotBlank(data.meta.CallDate) && isValidDateFormat(data.meta.CallDate))? Date.valueOf(data.meta.CallDate) : null;
                cs.Talk_Time__c = data.meta.TalkTime;
                cs.Hold_Time__c = data.meta.HoldTime;
                cs.Call_Duration__c = (String.isNotBlank(data.meta.Duration))? calculateDurationInSec(data.meta.Duration) : null;
                //cs.Call_Duration__c = (String.isNotBlank(data.meta.Duration))? Decimal.valueOf(data.meta.Duration) : null;
                cs.Comments__c = data.meta.Comments;
                cs.Disposition__c = data.meta.Disposition;
                cs.UUI__c = data.meta.UUI;
                cs.Audio_URL__c = data.meta.AudioFile;
            }


            if (data.audit_report != null) {
                processAuditReportPayload(data, cs);
                response.message = 'Audit Report processed successfully for UCID: ' + ucid;
            } else if (data.summary_report != null) {
                processVocReportPayload(data, cs);
                response.message = 'VOC Report processed successfully for UCID: ' + ucid;
            } else {
                response.message = 'Generic Call Report processed for UCID: ' + ucid;
            }
            System.debug('cs: ' + cs);
            upsert cs;
            response.success = true;
            response.monitorUCID = ucid;
            RestContext.response.statusCode = 200;
            
        } catch (Exception ex) {
            response.success = false;
            response.message = 'Error processing request: ' + ex.getMessage();
            RestContext.response.statusCode = 500;
        }
        
        return response;
    }
    
    private static void processAuditReportPayload(CallSummaryPayload data, Call_Summary__c cs) {
        if(data.audit_report != null && data.audit_report.audit_summary != null){
            cs.Audit_Summary__c = data.audit_report.audit_summary.summary;
            cs.Training_Needs__c = (data.audit_report.audit_summary.training_needs_identification != null)? convertListToString(data.audit_report.audit_summary.training_needs_identification) : null;
            cs.Areas_of_Improvement__c = data.audit_report.audit_summary.areas_of_improvement;
        }
        if(data.audit_report.call_score != null){
            cs.Call_Score__c = data.audit_report.call_score.score;
            cs.Call_Score_Fatal__c = data.audit_report.call_score.score_fatal;
            cs.Call_Score_Total__c = data.audit_report.call_score.score_total;
            cs.Call_Score_Max__c = data.audit_report.call_score.score_max;
        }
        /*if(data.audit_report.categories_scores != null){
            cs.Closing_Pleasentries__c = data.audit_report.categories_scores.closing_pleasentries;
            cs.Relevant_Probing__c = data.audit_report.categories_scores.opening_pleasantries;
            cs.Complaince__c = data.audit_report.categories_scores.complaince;
            cs.Soft_Skills__c = data.audit_report.categories_scores.soft_skills;
            cs.Opening_Pleasantries__c = data.audit_report.categories_scores.opening_pleasantries;
            cs.Call_Etiquette__c = data.audit_report.categories_scores.call_etiquette;
            cs.Sales_Skills__c = data.audit_report.categories_scores.sales_skills;
        }*/
        if(data.audit_report.categories_scores != null){
            cs.Closing_Pleasentries__c = data.audit_report.categories_scores.get('closing_pleasentries');
            cs.Relevant_Probing__c = data.audit_report.categories_scores.get('opening_pleasantries');
            cs.Complaince__c = data.audit_report.categories_scores.get('complaince');
            cs.Soft_Skills__c = data.audit_report.categories_scores.get('soft_skills');
            cs.Opening_Pleasantries__c = data.audit_report.categories_scores.get('opening_pleasantries');
            cs.Call_Etiquette__c = data.audit_report.categories_scores.get('call_etiquette');
            cs.Sales_Skills__c = data.audit_report.categories_scores.get('sales_skills');
        }
        /*if(data.audit_report.attribute_scores != null){
            cs.Opening_Greeting__c = data.audit_report.attribute_scores.call_opening_greetings;
            cs.Open_Within_6Sec__c = data.audit_report.attribute_scores.call_opening_3sec;
            cs.Opening_Brand__c = data.audit_report.attribute_scores.brand_name_check;
            cs.Opening_SelfIntro__c = data.audit_report.attribute_scores.opening_selfintro;
            cs.Caling_Purpose__c = data.audit_report.attribute_scores.caling_purpose;
            cs.Configurations_Carpetarea_Check__c = data.audit_report.attribute_scores.configurations_carpetarea_check;
            cs.Purchaising_Purpose__c = data.audit_report.attribute_scores.purchaising_purpose;
            cs.Customer_Preferred_Location__c = data.audit_report.attribute_scores.customer_preferred_location;
            cs.Posession_Timeline__c  = data.audit_report.attribute_scores.posession_timeline;
            cs.Appointment_Check__c = data.audit_report.attribute_scores.appointment_check;
            cs.Customer_Location_Check__c = data.audit_report.attribute_scores.customer_location_check;
            cs.Key_Usps_Of_The_Project__c = data.audit_report.attribute_scores.key_usps_of_the_project;
            cs.Objection_Handling_Check__c = data.audit_report.attribute_scores.objection_handling_check;
            cs.Two_Ways_Communication_Check__c = data.audit_report.attribute_scores.two_ways_communication_check;
            cs.Site_Visit_Pitch_Check__c = data.audit_report.attribute_scores.site_visit_pitch_check;
            cs.Budget_Check__c = data.audit_report.attribute_scores.budget_check;
            cs.Scheduled_Callback_Pitch_Check__c = data.audit_report.attribute_scores.scheduled_callback_pitch_check;
            cs.Family_Walkin_Check__c = data.audit_report.attribute_scores.family_walkin_check;
            cs.Reminder_Call_Pitch_Check__c = data.audit_report.attribute_scores.reminder_call_pitch_check;
            cs.Urgencey_Creation__c = data.audit_report.attribute_scores.urgencey_creation;
            cs.Empathy__c = data.audit_report.attribute_scores.empathy_check;
            cs.Pace_Of_Speech__c = data.audit_report.attribute_scores.pace_of_speech;
            cs.Clarity_Of_Speech__c = data.audit_report.attribute_scores.clarity_of_speech;
            cs.Politeness_Check__c = data.audit_report.attribute_scores.politeness_check;
            cs.Advisor_Confidence__c = data.audit_report.attribute_scores.confidence_check;
            cs.No_Fillers__c = data.audit_report.attribute_scores.fillers_avoid_agent;
            cs.Agent_Check_For_Interest__c = data.audit_report.attribute_scores.agent_check_for_interest;
            cs.Personalization__c = data.audit_report.attribute_scores.personalization;
            cs.Interruption_Avoidence__c = data.audit_report.attribute_scores.interruption_avoidence;
            cs.Active_Listening__c = data.audit_report.attribute_scores.active_listeining;
            cs.Energy_Level__c = data.audit_report.attribute_scores.tone_energy;
            cs.Rudeness_Avoidence_Check__c = data.audit_report.attribute_scores.rudeness_avoidence_check;
            cs.Abusiveness_Avoidence_Check__c = data.audit_report.attribute_scores.abusiveness_avoidence_check;
            cs.Sarcasm_Avoidence_Check__c = data.audit_report.attribute_scores.sarcasm_avoidence_check;
            cs.Casualness_Check__c = data.audit_report.attribute_scores.casualness_check;
            cs.Argument_Avoidence_Check__c = data.audit_report.attribute_scores.argument_avoidence_check;
            cs.Agent_Call_Disconnect_Avoidence_Check__c = data.audit_report.attribute_scores.agent_call_disconnect_avoidence_check;
            cs.Summarization__c = data.audit_report.attribute_scores.summarization;
            cs.Closing_Thanks__c = data.audit_report.attribute_scores.thanking_closing;
            cs.Closing_Brand__c = data.audit_report.attribute_scores.closing_branding;
            cs.Closing_Selfintro__c = data.audit_report.attribute_scores.closing_selfintro;
            cs.Hold_Placing__c = data.audit_report.attribute_scores.hold_placing;
            cs.Hold_Thanking__c = data.audit_report.attribute_scores.hold_thanking;
            cs.Force_Site_Visit_Check__c = data.audit_report.attribute_scores.force_site_visit_check;   
        }*/

        if(data.audit_report.attribute_scores != null){

            cs.Opening_Greeting__c = data.audit_report.attribute_scores.get('call_opening_greetings');
            cs.Open_Within_6Sec__c = data.audit_report.attribute_scores.get('call_opening_3sec');
            cs.Opening_Brand__c = data.audit_report.attribute_scores.get('brand_name_check');
            cs.Opening_SelfIntro__c = data.audit_report.attribute_scores.get('opening_selfintro');
            cs.Caling_Purpose__c = data.audit_report.attribute_scores.get('caling_purpose');
            cs.Configurations_Carpetarea_Check__c = data.audit_report.attribute_scores.get('configurations_carpetarea_check');
            cs.Purchaising_Purpose__c = data.audit_report.attribute_scores.get('purchaising_purpose');
            cs.Customer_Preferred_Location__c = data.audit_report.attribute_scores.get('customer_preferred_location');
            cs.Posession_Timeline__c  = data.audit_report.attribute_scores.get('posession_timeline');
            cs.Appointment_Check__c = data.audit_report.attribute_scores.get('appointment_check');
            cs.Customer_Location_Check__c = data.audit_report.attribute_scores.get('customer_location_check');
            cs.Key_Usps_Of_The_Project__c = data.audit_report.attribute_scores.get('key_usps_of_the_project');
            cs.Objection_Handling_Check__c = data.audit_report.attribute_scores.get('objection_handling_check');
            cs.Two_Ways_Communication_Check__c = data.audit_report.attribute_scores.get('two_ways_communication_check');
            cs.Site_Visit_Pitch_Check__c = data.audit_report.attribute_scores.get('site_visit_pitch_check');
            cs.Budget_Check__c = data.audit_report.attribute_scores.get('budget_check');
            cs.Scheduled_Callback_Pitch_Check__c = data.audit_report.attribute_scores.get('scheduled_callback_pitch_check');
            cs.Family_Walkin_Check__c = data.audit_report.attribute_scores.get('family_walkin_check');
            cs.Reminder_Call_Pitch_Check__c = data.audit_report.attribute_scores.get('reminder_call_pitch_check');
            cs.Urgencey_Creation__c = data.audit_report.attribute_scores.get('urgencey_creation');
            cs.Empathy__c = data.audit_report.attribute_scores.get('empathy_check');
            cs.Pace_Of_Speech__c = data.audit_report.attribute_scores.get('pace_of_speech');
            cs.Clarity_Of_Speech__c = data.audit_report.attribute_scores.get('clarity_of_speech');
            cs.Politeness_Check__c = data.audit_report.attribute_scores.get('politeness_check');
            cs.Advisor_Confidence__c = data.audit_report.attribute_scores.get('confidence_check');
            cs.No_Fillers__c = data.audit_report.attribute_scores.get('fillers_avoid_agent');
            cs.Agent_Check_For_Interest__c = data.audit_report.attribute_scores.get('agent_check_for_interest');
            cs.Personalization__c = data.audit_report.attribute_scores.get('personalization');
            cs.Interruption_Avoidence__c = data.audit_report.attribute_scores.get('interruption_avoidence');
            cs.Active_Listening__c = data.audit_report.attribute_scores.get('active_listeining');
            cs.Energy_Level__c = data.audit_report.attribute_scores.get('tone_energy');
            cs.Rudeness_Avoidence_Check__c = data.audit_report.attribute_scores.get('rudeness_avoidence_check');
            cs.Abusiveness_Avoidence_Check__c = data.audit_report.attribute_scores.get('abusiveness_avoidence_check');
            cs.Sarcasm_Avoidence_Check__c = data.audit_report.attribute_scores.get('sarcasm_avoidence_check');
            cs.Casualness_Check__c = data.audit_report.attribute_scores.get('casualness_check');
            cs.Argument_Avoidence_Check__c = data.audit_report.attribute_scores.get('argument_avoidence_check');
            cs.Agent_Call_Disconnect_Avoidence_Check__c = data.audit_report.attribute_scores.get('agent_call_disconnect_avoidence_check');
            cs.Summarization__c = data.audit_report.attribute_scores.get('summarization');
            cs.Closing_Thanks__c = data.audit_report.attribute_scores.get('thanking_closing');
            cs.Closing_Brand__c = data.audit_report.attribute_scores.get('closing_branding');
            cs.Closing_Selfintro__c = data.audit_report.attribute_scores.get('closing_selfintro');
            cs.Hold_Placing__c = data.audit_report.attribute_scores.get('hold_placing');
            cs.Hold_Thanking__c = data.audit_report.attribute_scores.get('hold_thanking');
            cs.Force_Site_Visit_Check__c = data.audit_report.attribute_scores.get('force_site_visit_check'); 
        }
    }
    
    private static void processVocReportPayload(CallSummaryPayload data, Call_Summary__c cs) {
        if(data.custom_report != null){
            cs.Custom_Report__c = String.valueOf(data.custom_report);
            cs.Primary_Intent__c = data.custom_report.primary_intent;
            cs.Sub_Reason__c = data.custom_report.sub_reason;
            cs.Contact_Attempt_Count__c = data.custom_report.contact_attempt_count;
            cs.Customer_Lifecycle_Stage__c = data.custom_report.customer_lifecycle_stage;
            cs.Escalation_Threat__c = data.custom_report.escalation_threat;
            cs.Agent_Escalated_To_Specialist_Team__c = data.custom_report.agent_escalated_to_specialist_team;
            cs.Customer_Sentiment_Start__c = data.custom_report.customer_sentiment_start;
            cs.Customer_Sentiment_End__c = data.custom_report.customer_sentiment_end;
            cs.Issue_Resolved_On_Call__c = data.custom_report.issue_resolved_on_call;
            cs.Customer_Pacified__c = data.custom_report.customer_pacified;
            cs.Agent_Used_Scripted_Language__c = data.custom_report.agent_used_scripted_language;
            cs.Agent_Coaching_Flag__c = data.custom_report.agent_coaching_flag;
            cs.Key_Customer_Pain_Points__c = (data.custom_report.key_customer_pain_points != null)? convertListToString(data.custom_report.key_customer_pain_points) : null;
            cs.VOC_Highlights__c = (data.custom_report.voc_highlights != null)? convertListToString(data.custom_report.voc_highlights) : null;
            cs.Call_Summary__c = data.custom_report.call_summary;
        }
        if(data.summary_report != null && data.summary_report.summary_info != null){
            cs.VOC_Summary__c = data.summary_report.summary_info.summary;
            cs.Call_Sentiment__c = data.summary_report.summary_info.sentiment;
            cs.Topics_List__c = (data.summary_report.summary_info.topic != null)? convertListToString(data.summary_report.summary_info.topic) : null;
            cs.Topic_Descriptions__c = (data.summary_report.summary_info.topic_description != null)? convertListToString(data.summary_report.summary_info.topic_description) : null;
        }
        if(data.transcription_report != null && data.transcription_report.turnwise != null){
            cs.Transcription_Report__c = '';
            for(Map<String, String> details : data.transcription_report.turnwise){
                cs.Transcription_Report__c += 'Channel: ' + details.get('channel');
                cs.Transcription_Report__c += ', Start: ' + details.get('start');
                cs.Transcription_Report__c += ', End: ' + details.get('end');
                cs.Transcription_Report__c += ', Transcript: ' + details.get('transcript');
                cs.Transcription_Report__c += ';\n';
            }
        }
        //cs.Transcription_Report__c = (data.transcription_report != null)? String.valueOf(data.transcription_report) : null;
        cs.conversation__c = (String.isNotBlank(data.conversation_translated))? data.conversation_translated : null;
    }

    public static Decimal calculateDurationInSec(String duration){
        if(duration == null) return null;
        List<String> parts = duration.split(':');
        Decimal secs;
        if(parts.size() == 3){
            secs = (Integer.valueOf(parts[0]) * 60 * 60) + (Integer.valueOf(parts[1]) * 60) + Integer.valueOf(parts[2]);
        }
        return secs;
    }

    public static String convertListToString(List<String> strList){
        String str = '';
        for(String st : strList){
            str += (str == '')? st : (', ' + st);
            //str += ', ' + st;
        }
        return str;
    }

    /*public static String fetchRelatedId(String ucid){ //Commented by Vinay 25-09-2026
        List<Task> tasks = [SELECT Id, WhatId FROM Task WHERE CallObject =: ucid ORDER By CreatedDate DESC];
        String recId;
        if(tasks.size() > 0 && tasks[0].WhatId != null){
            recId = tasks[0].WhatId;
        }
        return recId;
    }*/
    
    public static RelatedRecordsWrapper fetchRelatedRecordIds(String ucid){ //Added by Vinay 25-09-2026
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE CallObject =: ucid ORDER By CreatedDate DESC];
        RelatedRecordsWrapper relatedRecWrap = new RelatedRecordsWrapper(); 
        if(tasks.size() > 0){
            String taskLink = '/'+tasks[0].Id;
            List<Case> cases = [SELECT Id FROM Case WHERE Task_Link__c =: taskLink];
            relatedRecWrap.taskId = tasks[0].Id; 
            relatedRecWrap.taskSubject = tasks[0].Subject; 
            relatedRecWrap.relatedRecId = (tasks[0].WhatId != null)? tasks[0].WhatId : null; 
            relatedRecWrap.caseId = (cases.size() > 0)? cases[0].Id : null; 
        }
        return relatedRecWrap;
    }

    public static Boolean isValidDateTimeFormat(String dateTimeStr) {
        if (String.isBlank(dateTimeStr)) {
            return false;
        }
        Pattern p = Pattern.compile('^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$');
        Matcher m = p.matcher(dateTimeStr);
        return m.matches();
    }

    public static Boolean isValidDateFormat(String dateStr) {
        if (String.isBlank(dateStr)) {
            return false;
        }
        Pattern p = Pattern.compile('^\\d{4}-\\d{2}-\\d{2}$');
        Matcher m = p.matcher(dateStr);
        return m.matches();
    }

    public static Call_Summary__c existingCallSummary(String ucid){
        List<Call_Summary__c> callSummaries = [SELECT Id FROM Call_Summary__c WHERE Monitor_UCID__c =: ucid Order by CreatedDate DESC LIMIT 1];
        return (callSummaries.size() > 0)?  callSummaries[0] : null;
    }
    
    global class ResponseWrapper {
        public Boolean success;
        public String message;
        public String monitorUCID;
    }
    
    public class RelatedRecordsWrapper { //Added by Vinay 25-09-2026
        public String taskId;
        public String taskSubject;
        public String caseId;
        public String relatedRecId;
    }
}