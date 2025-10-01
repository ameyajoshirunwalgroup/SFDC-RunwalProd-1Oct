@isTest
    public class testPushDigitalEnquries {
        @isTest
        public static  void getLead(){
            
            String JSONMsg = '{"channel_name":"agent_app","country_code":"+91","email":"someemail10@abc.com","lead_id":922089,"lead_status":"Interested","name":"Rahul","phone":"7057931943","project_name":"Runwal Bliss","agent_email":"rahul1@anarock.com","project_id":76,"created_at":12,"claimed_at":12,"latest_event_details":[{"event_id":552654,"start_time":1540968234,"end_time":1540968534,"event_type":"followu"}],"notes":[{"note_type":"text","data":"Hi note","created_at":12,"agent_id":12,"updated_at":10,"agent_details":{"name":"test","phone":1234567890,"id":23456,"phone_country_id":91}}],"calls":[{"updated_at":12,"to":"+919819619866","start_time":10,"stage":"connected","sid":"asdfa1323fas","id":54321,"from":"+919833591953","end_time":10,"duration_in_sec":10,"action":"test","call_number":"1234567890","first_leg_status":"test","second_leg_status":"test","inserted_at":12345}],"Extra_details":[{"address":"test","ethnicity":"testing","occupation":"self employee","designation":"tester","company_name":"stetig","duplicate_lead_id":101,"gender":"female","max_age":40,"min_age":10,"industry":"test","office_city_id":1070,"annual_income_max":10,"annual_income_min":10,"current_apartment_type":10,"mode_of_payment":"cash","purpose_of_purchase":"end user","current_residence_type":"indian","Referral_data":{"name":"test","phone":"1234567890"}}],"Cp_data":[{"name":"test","phone_with_country_code":"91","firm_name":"stetig","rera_id":"12345","id":12345,"phone_country_id":12,"country_id":23,"phone":"1234567890"}]}';        
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.addParameter('data', JSONMsg);
            req.httpMethod = ('POST');
            req.requestURI = System.label.Site_Url_New + '/Anarock//services/apexrest/Integration/AnarockCRM/'; //Updated the link by Vinay 23-06-2025
            req.requestBody = Blob.valueof(JSONMsg);
            RestContext.request = req;
            RestContext.response = res;
                       
            Lead l= new Lead();
            l.Agent_Name__c= 'test';
            l.Anrock_LeadStatus__c = 'didgital';
            l.Company = 'stetig';
            l.Email = 'test@stetig.in';
            l.IsConverted= false;
            l.Lead_Source__c = 'google';
            l.RW_Mobile_No__c = '1234567890';
            l.Project_Name__c = 'runwal bliss';
            l.LastName = 'test';
            insert l;
            
            Project__c prj = new Project__c();
            prj.Name = 'Runwal Bliss';
            insert prj;
            
            Account a = new Account();
            a.Mobile_No__c = '1234567800';
            a.Name = 'test';
            a.Email_id_Child_1__c = 'test@stetig.in';
            a.Project_Name__c =prj.Id;
            insert a; 
            
            Task tsk = new Task();
            tsk.CallType = 'Inbound';
            tsk.Email_Id__c = 'test@stetig.in';
            tsk.Configuration__c = '1BHK';
            tsk.Event_Status__c ='complete';
            tsk.FullName__c= 'test';
            tsk.Project__c = prj.id;
            tsk.Remarks__c = 'testing';
            
            insert tsk;
            REST_AnarockIntegration.REST_result.CreateActivity();
            a.Is_serviced__c = false;
            update a;
            REST_AnarockIntegration.REST_result.CreateActivity();
            
            String JSONMsg1 = '{"channel_name":"agent_app","country_code":"+91","email":"someemail01@abc.com","lead_id":922089,"lead_status":"Interested","name":"Rahul","phone":null,"project_name":"Runwal Bliss","agent_email":"rahul1@anarock.com","project_id":76,"created_at":12,"claimed_at":12,"latest_event_details":[{"event_id":552654,"start_time":1540968234,"end_time":1540968534,"event_type":"followu"}],"notes":[{"note_type":"text","data":"Hi note","created_at":12,"agent_id":12,"updated_at":10,"agent_details":{"name":"test","phone":1234567890,"id":23456,"phone_country_id":91}}],"calls":[{"updated_at":12,"to":"+919819619866","start_time":10,"stage":"connected","sid":"asdfa1323fas","id":54321,"from":"+919833591953","end_time":10,"duration_in_sec":10,"action":"test","call_number":"1234567890","first_leg_status":"test","second_leg_status":"test","inserted_at":12345}],"Extra_details":[{"address":"test","ethnicity":"testing","occupation":"self employee","designation":"tester","company_name":"stetig","duplicate_lead_id":101,"gender":"female","max_age":40,"min_age":10,"industry":"test","office_city_id":1070,"annual_income_max":10,"annual_income_min":10,"current_apartment_type":10,"mode_of_payment":"cash","purpose_of_purchase":"end user","current_residence_type":"indian","Referral_data":{"name":"test","phone":"1234567890"}}],"Cp_data":[{"name":"test","phone_with_country_code":"91","firm_name":"stetig","rera_id":"12345","id":12345,"phone_country_id":12,"country_id":23,"phone":"1234567890"}]}';        
           RestRequest req1 = new RestRequest();
            RestResponse res1 = new RestResponse();
            req1.addParameter('data', JSONMsg1);
            req1.httpMethod = ('POST');
            req1.requestURI = System.label.Site_Url_New + '/Anarock//services/apexrest/Integration/AnarockCRM/'; //Updated the link by Vinay 23-06-2025
            req1.requestBody = Blob.valueof(JSONMsg1);
            RestContext.request = req1;
            RestContext.response = res1;
            
            REST_AnarockIntegration.REST_result.CreateActivity();
            
            String JSONMsg2 = '{"channel_name":"agent_app","country_code":"+91","email":"someemail6776711@abc.com","lead_id":922089,"lead_status":"Interested","name":"Rahul","phone":"9823393400","project_name":null,"agent_email":"rahul4@anarock.com","project_id":76,"created_at":12,"claimed_at":12,"latest_event_details":[{"event_id":552654,"start_time":1540968234,"end_time":1540968534,"event_type":"followu"}],"notes":[{"note_type":"text","data":"Hi note","created_at":12,"agent_id":12,"updated_at":10,"agent_details":{"name":"test","phone":1234567890,"id":23456,"phone_country_id":91}}],"calls":[{"updated_at":12,"to":"+919819619866","start_time":10,"stage":"connected","sid":"asdfa1323fas","id":54321,"from":"+919833591953","end_time":10,"duration_in_sec":10,"action":"test","call_number":"1234567890","first_leg_status":"test","second_leg_status":"test","inserted_at":12345}],"Extra_details":[{"address":"test","ethnicity":"testing","occupation":"self employee","designation":"tester","company_name":"stetig","duplicate_lead_id":101,"gender":"female","max_age":40,"min_age":10,"industry":"test","office_city_id":1070,"annual_income_max":10,"annual_income_min":10,"current_apartment_type":10,"mode_of_payment":"cash","purpose_of_purchase":"end user","current_residence_type":"indian","Referral_data":{"name":"test","phone":"1234567890"}}],"Cp_data":[{"name":"test","phone_with_country_code":"91","firm_name":"stetig","rera_id":"12345","id":12345,"phone_country_id":12,"country_id":23,"phone":"1234567890"}]}';        
         RestRequest req2 = new RestRequest();
            RestResponse res2 = new RestResponse();
            req2.addParameter('data', JSONMsg2);
            req2.httpMethod = ('POST');
            req2.requestURI = System.label.Site_Url_New + '/Anarock//services/apexrest/Integration/AnarockCRM/'; //Updated the link by Vinay 23-06-2025
            req2.requestBody = Blob.valueof(JSONMsg2);
            RestContext.request = req2;
            RestContext.response = res2;
            
            REST_AnarockIntegration.REST_result.CreateActivity();            
            
            
        }   
        @isTest
        private Static void testPushdata ()  {
        
             Project__c objProject = new Project__c(Name = 'Runwal Gardens',Send_Digital_data_to_Anarock__c = true,Anarock_Campaign_Id__c = 'ABFFF');
             insert objProject;
             
            task t = new task();
            t.status = 'Completed';
            t.task_type__c = 'Enquiry Received';
            t.Subject = 'New Enquiry Received';
            t.Mobile_Number_Webform__c  = '9090111001';
            t.FullName__c = 'test anarock';
            t.Email_Id__c = 'test@testin.co';
            t.Call_Attempt_Status__c = 'Connected';
            t.activityDate = System.today();
            t.Call_Time__c = System.Now().format('h:mm a');
            t.Project__c = objProject.Id;
            insert t;
        }  
    }