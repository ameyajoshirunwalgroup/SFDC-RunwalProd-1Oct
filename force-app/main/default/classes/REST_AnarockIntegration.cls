@RestResource(urlMapping='/Integration/AnarockCRM/*')

global class REST_AnarockIntegration 
{
    @HttpPost
    
    global static REST_result CreateActivity() {
        String data = '';
        REST_result r = new REST_Result();
        System.debug('Request:' + RestContext.request);
        Restrequest request = RestContext.request;
        system.debug('request.requestBody::'+ request.requestBody);
        JSON2Apex jobj ;// = new JSON2Apex() ;
        
         jobj = JSON2Apex.Parse(request.requestBody.toString());
         
         system.debug('request.requestBody.toString()::' + request.requestBody.toString());   
      
        
        system.debug('parser::' + jObj);
        
         string cstoccupation ='';
         string cstdesignation ='';
         string cstcompany_name ='';
         string cstaddress  ='';
         string cstethnicity ='';
         
        if (String.isBlank(request.requestBody.toString())) {
            r.returnCode = 1;
            r.message = 'Unexpected Error Occurred';
            r.RrecordId = null;
            return r;
        } else 
        {
            Integer LeadId = jobj.lead_id;
            String custName = jobj.name;
            String custEmail = jobj.email;
            String custPhone = jobj.phone;
            String custcountrycode = jobj.country_code;
            String custsource = jobj.source;
            String custsubsource = jobj.sub_source;
            //String custPlacement = jobj.placement;
            String custProjectName = jobj.project_name;
            //Boolean custIsDuplicate = jobj.is_duplicate;
            String leadStatus = jobj.lead_status;
            //String campaignName = jobj.campaign_id;
            String medium = jobj.channel_name;
            String agentemail = jobj.agent_email;
            String calltype = jobj.Latest_event_details.event_type;
            Integer eventId = jobj.Latest_event_details.event_id;
            Integer start_time = jobj.Latest_event_details.start_time;
            Integer end_time = jobj.Latest_event_details.end_time;
            
            if(jobj.Extra_details != null) {
            cstoccupation = jobj.Extra_details.occupation ;
            cstdesignation = jobj.Extra_details.designation;
            cstcompany_name = jobj.Extra_details.company_name ;
            cstethnicity =  jobj.Extra_details.ethnicity;
            cstaddress = jobj.Extra_details.address;}
            //string agentname = string.valueOf(jobj.Agent_details );
            //string ReferralDetails = ''; 
            string comments = '';
            String callDetails = '';
           
           
            List<String> temp = new List<String>();
            
            if(jobj.Notes != null) {
            for (JSON2Apex.Notes_Z Note: jobj.Notes) {
            
                String trimmedData = Note.data.replace('"', '');
                string trimmedData1 = string.valueOf(Note.created_at);
                
                String trimmedData2 = '';
                String trimmedData3 = '';
                if(Note.agent_details != null) {
                    trimmedData2 = Note.agent_details.name;
                    trimmedData3 = Note.agent_details.phone;
                }
                
                comments += trimmedData + '. ' + trimmedData1 + '. ' + trimmedData2 + '.' + trimmedData3 + '.\n';
                }
            }
            
           if(jobj.Calls != null){
            for (JSON2Apex.Calls call: jobj.Calls) {
             callDetails = JSON.serialize(jobj.Calls);
            }
          }
            
            boolean newlead = false;
            List < lead > leadlist = new List < lead > ();
            List < Account > accList = new List < Account > ();
            List <Project__c > prjList = new List < Project__c > ();
            prjList = [select ID, Name from Project__c where Name =: custProjectName LIMIT 1 ];
            
            if (prjList == null || prjList.size() == 0) {
                                r.returnCode = 1;
                                r.message = 'Invalid Project Name';
                                r.RrecordId = null;
                                return r;
                        }
            if (custPhone == null || String.isBlank(custPhone)) {
                r.returnCode = 1;
                r.message = 'Mobile No. is required';
                r.RrecordId = null;
                return r;
            } 
            else {
                Id recordId;
                Map<String, AnarockLeadStatusMapping__c> leadStatusMap = AnarockLeadStatusMapping__c.getAll();
                if (LeadId != null  && String.isNotBlank(custName)) 
                {
                    if (custEmail != null && String.isNotBlank(custEmail)){
                        leadlist = [Select Id, name,Status from Lead where(RW_Mobile_No__c =: custPhone or Phone =: custPhone or Email =: custEmail) and isConverted = false];
                        System.debug('Print Leadlist with EmailId'+leadlist);
                    }else {
                        leadlist = [Select Id, name,Status from Lead where(RW_Mobile_No__c =: custPhone or Phone =: custPhone) and isConverted = false];
                        System.debug('Print Leadlist without EmailId'+leadlist);
                    }
                    if (leadlist != null && !leadlist.isEmpty() && leadlist.size() > 0) {
                        String leadS = '';
                        if(leadlist[0].Status == 'Not Sure' && leadStatus != null && leadStatusMap.containsKey(leadStatus))
                            leadS = leadStatusMap.get(leadStatus).SFDC_Lead_Status__c;
                        if(leadS != '')
                            leadlist[0].Status = leadS;
                        leadlist[0].is_serviced__c = false;
                        leadlist[0].Anrock_LeadStatus__c = leadStatus;
                        
                        update leadlist[0];
                        recordId = leadlist[0].Id;
                        system.debug('Record Id from Leadlist' + recordId);
                        
                        // create a task
                        createTask (recordId,custName,custEmail,calltype,custPhone,comments,callDetails,eventId,start_time,end_time,false);
                        
                        r.returnCode = 0;
                        r.message = 'New Enquiry Received on Existing Lead';
                        r.RrecordId = leadlist[0].Id;
                        return r;
                    } else if (leadlist.isEmpty() && leadlist.size() == 0) 
                    {
                        accList = [Select Id, is_serviced__c from Account where(Mobile_No__c =: custPhone or PersonMobilePhone =: custPhone) and IsPersonAccount = true];
                        if (accList != null && !accList.isEmpty() && accList.size() == 1)
                        {
                            
                            accList[0].is_serviced__c = false;
                            update accList[0];
                            recordId = accList[0].Id;
                            
                            //create a task 
                            createTask (recordId,custName,custEmail,calltype,custPhone,comments,callDetails,eventId,start_time,end_time,false);
                            
                            r.returnCode = 0;
                            r.message = 'New Enquiry created on existing Account';
                            r.RrecordId = accList[0].Id;
                            return r;
                        }
                        else 
                        {
                            Lead l = new Lead();
                            l.lastName = custName;
                            l.RW_Mobile_No__c = custPhone;
                            l.Auto_Assign__c = true;
                            l.Email = custEmail;
                            l.RDS_Country_Code__c = custcountrycode;
                            //l.Anarock_Source__c = custsource;
                            //l.Anarock_Sub_Source__c = custsubsource;
                            l.RW_Project__c = prjList[0].id;
                            l.Anrock_LeadStatus__c = leadStatus;
                            l.RW_Occupation__c = cstoccupation;
                            l.RW_Designation__c = cstdesignation ;
                            l.RW_Ethnicity__c = cstethnicity ;
                            l.RW_Company_Name__c = cstcompany_name;  
                            l.Is_Anarock_Lead__c = true;
                            l.Event_Start_Time__c = string.valueOf(start_time) ;
                            l.Lead_ID__c = string.valueOf(LeadId);
                            l.LeadSource = custsource;  
                            l.RW_Lead_Sub_Source__c = custsubsource; 
                            String leadS = '';
                            if(leadStatus != null && leadStatusMap.containsKey(leadStatus))
                                leadS = leadStatusMap.get(leadStatus).SFDC_Lead_Status__c;
                            if(leadS != '')
                                l.Status = leadS;
                            try {
                                insert l;
                                recordId = l.Id;
                                newlead = true;
                                
                                //create a task 
                                createTask (recordId,custName,custEmail,calltype,custPhone,comments,callDetails,eventId,start_time,end_time,newlead);
                                
                                r.returnCode = 0;
                                r.message = 'New Lead has been created';
                                r.RrecordId = l.Id;
                                return r;
                            } catch (exception ex)
                            {
                                System.debug('Lead insertion failed'+ex);
                                r.returnCode = 1;
                                r.message = 'Error occureed while creating a new lead';
                                r.RrecordId = null;
                                return r;
                            }
                            
                        }
                    }
                }    
                
                else {
                    r.returnCode = 1;
                    r.message = 'Something went wrong';
                    r.RrecordId = null;
                    return r;
                }
            }
            
        }
        return r;
    }
    
    global static void createTask (Id recordId1, string custName1,string custEmail1,String calltype1,String custPhone1,
                                   String comments1,string callDetails1,Integer eventId1,integer start_time1,
                                   integer end_time1,boolean isNewLeadCreated) 
    {
        System.debug('Record Id for Lead task creation:' + recordId1);
        task t = new task();
        t.status = 'Completed';
        t.task_type__c = 'Enquiry Received';
        t.Subject = 'New Enquiry Received From Anarock';
        t.Mobile_Number_Webform__c  = custPhone1;
        t.FullName__c = custName1;
        t.Email_Id__c = custEmail1;
        t.Call_Attempt_Status__c = calltype1;
        t.activityDate = System.today();
        t.Call_Time__c = System.Now().format('h:mm a');
        t.Is_Created_through_Anarock__c = true;
        //t.Project__c = custProjectName1 ;
        t.description = comments1; //+' '+strmessage+' '+strcreated_at+' '+strnote_id;
        //t.Address__c  = callDetails1;// saved to call comments field of Activity;
        //t.Latest_Event_Details_from_AnarockCRM__c = 'event_id :'+eventId1+', start_time :'+start_time1+', end_time :'+ end_time1+', event_type :'+ calltype1;  
        
        if(isNewLeadCreated){
            t.new_lead_created__c = true;
        }
        if (recordId1.getSObjectType().getDescribe().getName() == 'Lead') {
            t.whoId = recordId1;
        }
        else if(recordId1.getSObjectType().getDescribe().getName() == 'Account') {
            t.whatId = recordId1;
        }
        else if(recordId1.getSObjectType().getDescribe().getName() == 'Opportunity')
            t.whatId = recordId1;
        else {
            system.debug('ignore the task created');
        }
        try {
            insert t;
            System.debug('task created:' + t.id);
        } catch (Exception ex) {
            System.debug('task insert failed :' + ex.getMessage());
        }
        
    }
    global class REST_result 
    {
        webservice Integer returnCode;
        webservice String message;
        webService String RrecordId;
        
        public REST_result() {
            //cList= null;
        }
    }
    
    
}