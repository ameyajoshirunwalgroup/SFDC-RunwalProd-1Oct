@RestResource(urlMapping='/whatsappFb/*')
global without sharing class WhatsAppFeedback {
    
    @HttpGet
    global static List<CustomerDetails> doGet(){
        List<CustomerDetails> custDetails = new List<CustomerDetails>();
        RestRequest req = RestContext.request;
        String reqType =  req.params.get('type');
        String mobile =  req.params.get('mobile');
        String crn =  req.params.get('crn');
        String camp =  req.params.get('camp');
        List<WhatsApp_Feedback_Q_A__mdt> whatsappFbQa = new List<WhatsApp_Feedback_Q_A__mdt>();
        
        if(crn == null  || crn == ''){
            if(reqType == 'Day of Registration'){
                /*List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null AND
                                         Booking__r.RW_Registration_Date__c = null]; */
                List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null];
                
                for(Opportunity opp : opps){
                    CustomerDetails cust = new CustomerDetails();
                    cust.crn = opp.SAP_Customer_Number__c;
                    cust.mobile = opp.RW_Mobile_No__c;
                    cust.unit = opp.RW_Project_Unit__r.Name;
                    custDetails.add(cust);
                }
                return custDetails;
            }else if(reqType == 'Day of Possession Handover'){
                /* List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null AND
                                         Booking__r.RW_Key_handover_date__c = null]; */
               List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null];
                
                for(Opportunity opp : opps){
                    CustomerDetails cust = new CustomerDetails();
                    cust.crn = opp.SAP_Customer_Number__c;
                    cust.mobile = opp.RW_Mobile_No__c;
                    cust.unit = opp.RW_Project_Unit__r.Name;
                    custDetails.add(cust);
                }
                return custDetails;
            }else if(reqType == 'Generic Feedback'){
                WhatsApp_Campaign__c wc;
                
                if(!Test.isRunningTest()){
                    if(camp == 'camp'){
                        wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name = 'camp-0000' LIMIT 1];
                    }else{
                        wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: camp LIMIT 1];
                    }
                }else{
                    wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c LIMIT 1];
                }
                //WhatsApp_Campaign__c wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: camp LIMIT 1];
                CustomerDetails cust = new CustomerDetails();
                if(!wc.Active__c && camp != 'camp'){
                    cust.message = 'Campaign is Inactive';
                    custDetails.add(cust);
                    return custDetails;
                }else{
                    List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null]; 
                
                    for(Opportunity opp : opps){
                        CustomerDetails cust1 = new CustomerDetails();
                        cust1.crn = opp.SAP_Customer_Number__c;
                        cust1.mobile = opp.RW_Mobile_No__c;
                        cust1.unit = opp.RW_Project_Unit__r.Name;
                        custDetails.add(cust1);
                    }
                }
                return custDetails;
            }else{
                List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c != null]; 
                
                for(Opportunity opp : opps){
                    CustomerDetails cust = new CustomerDetails();
                    cust.crn = opp.SAP_Customer_Number__c;
                    cust.mobile = opp.RW_Mobile_No__c;
                    cust.unit = opp.RW_Project_Unit__r.Name;
                    custDetails.add(cust);
                }
                return custDetails;
            }
            
        }else{
            CustomerDetails cust = new CustomerDetails();
            if(reqType == 'Day of Registration'){
                List<WhatsApp_Feedback__c> wfb = [SELECT Id FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobile AND Feedback_Type__c =: reqType AND CRN__c =: crn];
                if(wfb.size() > 0){
                    cust.message = 'Feedback already exists';
                }else{
                    cust.message = 'No Feedback';
                }
            }else if(reqType == 'Day of Possession Handover'){
                List<WhatsApp_Feedback__c> wfb = [SELECT Id FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobile AND Feedback_Type__c =: reqType AND CRN__c =: crn];
                if(wfb.size() > 0){
                    cust.message = 'Feedback already exists';
                }else{
                    cust.message = 'No Feedback';
                }
            }else if(reqType == 'Post Possession Handover'){
                List<WhatsApp_Feedback__c> wfb = [SELECT Id FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobile AND Feedback_Type__c =: reqType AND CRN__c =: crn];
                if(wfb.size() > 0){
                    cust.message = 'Feedback already exists';
                }else{
                    cust.message = 'No Feedback';
                }
            }else if(reqType == 'Call Disposition'){
                List<WhatsApp_Feedback__c> wfb = [SELECT Id FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobile AND Feedback_Type__c =: reqType AND CRN__c =: crn AND CreatedDate <=: Date.today() AND CreatedDate >: (Date.today()-7)];
                if(wfb.size() > 0){
                    cust.message = 'Feedback already exists';
                }else{
                    cust.message = 'No Feedback';
                }
            }else if(reqType == 'Sales Experience'){
                List<WhatsApp_Feedback__c> wfb = [SELECT Id FROM WhatsApp_Feedback__c WHERE Mobile_Number__c =: mobile AND Feedback_Type__c =: reqType AND CRN__c =: crn];
                if(wfb.size() > 0){
                    cust.message = 'Feedback already exists';
                }else{
                    cust.message = 'No Feedback';
                }
            }else if(reqType == 'Generic Feedback' && (camp != null && camp != '')){
                System.debug('Generic Feedback');
                
                WhatsApp_Campaign__c wc;
                
                if(!Test.isRunningTest()){
                    if(camp == 'camp'){
                        wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name = 'camp-0000' LIMIT 1];
                    }else{
                        wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: camp LIMIT 1];
                    }
                }else{
                    wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c LIMIT 1];
                }
                //WhatsApp_Campaign__c wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: camp LIMIT 1];
                
                if(!wc.Active__c && camp != 'camp'){
                    cust.message = 'Campaign is Inactive';
                    custDetails.add(cust);
            		return custDetails;
                }else{
                    List<Opportunity> opps = [SELECT Id, SAP_Customer_Number__c, RW_Mobile_No__c, RW_Project_Unit__r.Name FROM Opportunity 
                                  WHERE RW_Mobile_No__c =: mobile AND StageName = 'Unit Booked' AND SAP_Customer_Number__c =: crn LIMIT 1];
                    if(opps.size() > 0){
                        cust.crn = opps[0].SAP_Customer_Number__c;
                        cust.mobile = opps[0].RW_Mobile_No__c;
                        cust.unit = opps[0].RW_Project_Unit__r.Name;
                        //cust.campaign = camp;
                        cust.campaign = wc.Name;
                        
                        List<WhatsApp_Feedback_Campaign__mdt> feedbackQus = [SELECT Id, Campaign_Name__c, Question_1__c,  Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_1_Type__c, Question_2_Type__c, Question_3_Type__c, Question_4_Type__c, Question_5_Type__c, Question_6_Type__c, Question_7_Type__c, Question_8_Type__c, Question_9_Type__c, Question_10_Type__c, 
                                                                     Question_11__c,  Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_11_Type__c, Question_12_Type__c, Question_13_Type__c, Question_14_Type__c, Question_15_Type__c, Question_16_Type__c, Question_17_Type__c, Question_18_Type__c, Question_19_Type__c, Question_20_Type__c
                                                                     FROM WhatsApp_Feedback_Campaign__mdt WHERE Campaign_Name__c =: wc.Campaign_Name__c LIMIT 1];
                        Map<String,String> questions = new Map<String,String>();
                        List<Question> qus = new List<Question>();
                        
                        if(feedbackQus[0].Question_1__c != null){
                            Question q1 = new Question();
                            q1.question = feedbackQus[0].Question_1__c;
                            q1.questionType = feedbackQus[0].Question_1_Type__c;
                            qus.add(q1);
                        }
                        if(feedbackQus[0].Question_2__c != null){
                            Question q2 = new Question();
                            q2.question = feedbackQus[0].Question_2__c;
                            q2.questionType = feedbackQus[0].Question_2_Type__c;
                            qus.add(q2);
                        }
                        if(feedbackQus[0].Question_3__c != null){
                            Question q3 = new Question();
                            q3.question = feedbackQus[0].Question_3__c;
                            q3.questionType = feedbackQus[0].Question_3_Type__c;
                            qus.add(q3);
                        }
                        if(feedbackQus[0].Question_4__c != null){
                            Question q4 = new Question();
                            q4.question = feedbackQus[0].Question_4__c;
                            q4.questionType = feedbackQus[0].Question_4_Type__c;
                            qus.add(q4);
                        }
                        if(feedbackQus[0].Question_5__c != null){
                            Question q5 = new Question();
                            q5.question = feedbackQus[0].Question_5__c;
                            q5.questionType = feedbackQus[0].Question_5_Type__c;
                            qus.add(q5);
                        }
                        if(feedbackQus[0].Question_6__c != null){
                            Question q6 = new Question();
                            q6.question = feedbackQus[0].Question_6__c;
                            q6.questionType = feedbackQus[0].Question_6_Type__c;
                            qus.add(q6);
                        }
                        if(feedbackQus[0].Question_7__c != null){
                            Question q7 = new Question();
                            q7.question = feedbackQus[0].Question_7__c;
                            q7.questionType = feedbackQus[0].Question_7_Type__c;
                            qus.add(q7);
                        }
                        if(feedbackQus[0].Question_8__c != null){
                            Question q8 = new Question();
                            q8.question = feedbackQus[0].Question_8__c;
                            q8.questionType = feedbackQus[0].Question_8_Type__c;
                            qus.add(q8);
                        }
                        if(feedbackQus[0].Question_9__c != null){
                            Question q9 = new Question();
                            q9.question = feedbackQus[0].Question_9__c;
                            q9.questionType = feedbackQus[0].Question_9_Type__c;
                            qus.add(q9);
                        }
                        if(feedbackQus[0].Question_10__c != null){
                            Question q10 = new Question();
                            q10.question = feedbackQus[0].Question_10__c;
                            q10.questionType = feedbackQus[0].Question_10_Type__c;
                            qus.add(q10);
                        }
                        /*if(feedbackQus[0].Question_11__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_11__c;
                            q.questionType = feedbackQus[0].Question_11_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_12__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_12__c;
                            q.questionType = feedbackQus[0].Question_12_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_13__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_13__c;
                            q.questionType = feedbackQus[0].Question_13_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_14__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_14__c;
                            q.questionType = feedbackQus[0].Question_14_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_15__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_15__c;
                            q.questionType = feedbackQus[0].Question_15_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_16__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_16__c;
                            q.questionType = feedbackQus[0].Question_16_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_17__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_17__c;
                            q.questionType = feedbackQus[0].Question_17_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_18__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_18__c;
                            q.questionType = feedbackQus[0].Question_18_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_19__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_19__c;
                            q.questionType = feedbackQus[0].Question_19_Type__c;
                            qus.add(q);
                        }
                        if(feedbackQus[0].Question_20__c != null){
                            Question q = new Question();
                            q.question = feedbackQus[0].Question_20__c;
                            q.questionType = feedbackQus[0].Question_20_Type__c;
                            qus.add(q);
                        }*/
                        cust.questions = qus;
                    }else{
                        cust.message = 'No customer exist with this CRN & mobile number';
                    }
                    
                }
            }
            custDetails.add(cust);
            return custDetails;
        }
        
       
    }
    
    
    @HttpPost
    global static String doPost(){
        RestRequest req = RestContext.request;
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        FeedbackData data = (FeedbackData)JSON.deserialize(jsonBody, FeedbackData.class);
        System.debug('data: ' + data);
        
        
        if(data.feedbackType == 'End of Bot conversation' || data.feedbackType == 'Case Closure' || data.feedbackType == 'IVR'){
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Feedback_Type__c = (data.feedbackType != 'IVR')? data.feedbackType : 'Call Disposition';
            fb.Mobile_Number__c = data.mobile;
            fb.CRN__c = data.crn;
            fb.Case_Number__c = data.caseNum;
            List<Opportunity> opp;
            if(data.crn != null){
               opp = [SELECT Id FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1]; 
            }
            fb.Opportunity__c = (opp.size() > 0) ? opp[0].Id : null;
            List<String> questions = new List<String>(data.qa.keySet());
            fb.Question_1__c = (questions.size() >= 1 && questions[0] != null) ? questions[0] : null;
            String nps = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }
            fb.Answer_1__c = nps;
            //fb.Answer_1__c = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
            fb.Question_30__c = (questions.size() >= 2 && questions[1] != null) ? questions[1] : null;
            fb.Answer_30__c = (questions.size() >= 2 && questions[1] != null) ? data.qa.get(questions[1]) : null;
            insert fb;
            return 'Successfully submitted your feedback';
        }else if(data.feedbackType == 'Day of Registration'){
            
            /*List<WhatsApp_Feedback_Q_A__mdt> bkgFbQa = [SELECT Id, DeveloperName, Label, Question__c, Answer__c FROM WhatsApp_Feedback_Q_A__mdt WHERE Label = 'Day of Registration - Booking'];
            List<String> bookingQuestions = new List<String>();
            for(WhatsApp_Feedback_Q_A__mdt mdt : bkgFbQa){
                bookingQuestions.add(mdt.Question__c);
            }*/
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Feedback_Type__c = data.feedbackType;
            fb.Mobile_Number__c = data.mobile;
            fb.CRN__c = data.crn;
            List<Opportunity> opp;
            if(data.crn != null){
                opp = [SELECT Id FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1]; 
            }
            fb.Opportunity__c = (opp.size() > 0)? opp[0].Id : null;
            /*Map<String, String> bkgQa = new Map<String, String>();
            Map<String, String> regQa = new Map<String, String>();
            for(String st : data.qa.keySet()){
                if(bookingQuestions.contains(st)){
                    bkgQa.put(st, data.qa.get(st));
                }else{
                    regQa.put(st, data.qa.get(st));
                }
            }
            System.debug('data.qa.keySet: ' + data.qa.keySet());
            System.debug('bkgQa: ' + bkgQa);
            System.debug('regQa: ' + regQa);
            List<String> bkgQuestions = new List<String>(bkgQa.keySet());
            List<String> regQuestions = new List<String>(regQa.keySet());*/
            
            List<String> questions  = new List<String>(data.qa.keySet());
            /*fb.Question_2__c = (bkgQuestions.size() >= 1 && bkgQuestions[0] != null) ? bkgQuestions[0] : null;
            fb.Answer_2__c = (bkgQuestions.size() >= 1 && bkgQuestions[0] != null) ? bkgQa.get(bkgQuestions[0]) : null;
            fb.Question_3__c = (bkgQuestions.size() >= 2 && bkgQuestions[1] != null) ? bkgQuestions[1] : null;
            fb.Answer_3__c = (bkgQuestions.size() >= 2 && bkgQuestions[1] != null) ? bkgQa.get(bkgQuestions[1]) : null;
            fb.Question_4__c = (bkgQuestions.size() >= 3 && bkgQuestions[2] != null) ? bkgQuestions[2] : null;
            fb.Answer_4__c = (bkgQuestions.size() >= 3 && bkgQuestions[2] != null) ? bkgQa.get(bkgQuestions[2]) : null;
            fb.Question_5__c = (bkgQuestions.size() >= 4 && bkgQuestions[3] != null) ? bkgQuestions[3] : null;
            fb.Answer_5__c = (bkgQuestions.size() >= 4 && bkgQuestions[3] != null) ? bkgQa.get(bkgQuestions[3]) : null;
            fb.Question_6__c = (bkgQuestions.size() >= 5 && bkgQuestions[4] != null) ? bkgQuestions[4] : null;
            fb.Answer_6__c = (bkgQuestions.size() >= 5 && bkgQuestions[4] != null) ? bkgQa.get(bkgQuestions[4]) : null;
            fb.Question_7__c = (regQuestions.size() >= 1 && regQuestions[0] != null) ? regQuestions[0] : null;
            fb.Answer_7__c = (regQuestions.size() >= 1 && regQuestions[0] != null) ? regQa.get(regQuestions[0]) : null;
            fb.Question_8__c = (regQuestions.size() >= 2 && regQuestions[1] != null) ? regQuestions[1] : null;
            fb.Answer_8__c = (regQuestions.size() >= 2 && regQuestions[1] != null) ? regQa.get(regQuestions[1]) : null;
            fb.Question_9__c = (regQuestions.size() >= 3 && regQuestions[2] != null) ? regQuestions[2] : null;
            fb.Answer_9__c = (regQuestions.size() >= 3 && regQuestions[2] != null) ? regQa.get(regQuestions[2]) : null;
            fb.Question_10__c = (regQuestions.size() >= 4 && regQuestions[3] != null) ? regQuestions[3] : null;
            fb.Answer_10__c = (regQuestions.size() >= 4 && regQuestions[3] != null) ? regQa.get(regQuestions[3]) : null;
            fb.Question_11__c = (regQuestions.size() >= 5 && regQuestions[4] != null) ? regQuestions[4] : null;
            fb.Answer_11__c = (regQuestions.size() >= 5 && regQuestions[4] != null) ? regQa.get(regQuestions[4]) : null;
            fb.Question_12__c = (regQuestions.size() >= 6 && regQuestions[5] != null) ? regQuestions[5] : null;
            String nps = (regQuestions.size() >= 6 && regQuestions[5] != null) ? regQa.get(regQuestions[5]) : null;*/
            fb.Question_2__c = (questions.size() >= 1 && questions[0] != null) ? questions[0] : null;
            fb.Answer_2__c = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
            fb.Question_3__c = (questions.size() >= 2 && questions[1] != null) ? questions[1] : null;
            fb.Answer_3__c = (questions.size() >= 2 && questions[1] != null) ? data.qa.get(questions[1]) : null;
            fb.Question_4__c = (questions.size() >= 3 && questions[2] != null) ? questions[2] : null;
            fb.Answer_4__c = (questions.size() >= 3 && questions[2] != null) ? data.qa.get(questions[2]) : null;
            fb.Question_5__c = (questions.size() >= 4 && questions[3] != null) ? questions[3] : null;
            fb.Answer_5__c = (questions.size() >= 4 && questions[3] != null) ? data.qa.get(questions[3]) : null;
            fb.Question_6__c = (questions.size() >= 5 && questions[4] != null) ? questions[4] : null;
            String nps = (questions.size() >= 5 && questions[4] != null) ? data.qa.get(questions[4]) : null;
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }
            fb.Answer_6__c = nps;
            //fb.Answer_12__c = nps;
           // fb.Answer_12__c = (regQuestions.size() >= 6 && regQuestions[5] != null) ? regQa.get(regQuestions[5]) : null;
            
            insert fb;
            return 'Successfully submitted your feedback';
            
        }else if(data.feedbackType == 'Day of Possession Handover'){
            
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Feedback_Type__c = data.feedbackType;
            fb.Mobile_Number__c = data.mobile;
            fb.CRN__c = data.crn;
            List<Opportunity> opp;
            if(data.crn != null){
                opp = [SELECT Id FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1];
            }
            fb.Opportunity__c = (opp.size() > 0)? opp[0].Id : null;
            List<String> questions  = new List<String>(data.qa.keySet());
            fb.Question_13__c = (questions.size() >= 1 && questions[0] != null) ? questions[0] : null;
            fb.Answer_13__c = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
            fb.Question_14__c = (questions.size() >= 2 && questions[1] != null) ? questions[1] : null;
            fb.Answer_14__c = (questions.size() >= 2 && questions[1] != null) ? data.qa.get(questions[1]) : null;
            fb.Question_15__c = (questions.size() >= 3 && questions[2] != null) ? questions[2] : null;
            fb.Answer_15__c = (questions.size() >= 3 && questions[2] != null) ? data.qa.get(questions[2]) : null;
            fb.Question_16__c = (questions.size() >= 4 && questions[3] != null) ? questions[3] : null;
            fb.Answer_16__c = (questions.size() >= 4 && questions[3] != null) ? data.qa.get(questions[3]) : null;
            fb.Question_17__c = (questions.size() >= 5 && questions[4] != null) ? questions[4] : null;
            fb.Answer_17__c = (questions.size() >= 5 && questions[4] != null) ? data.qa.get(questions[4]) : null;
            fb.Question_18__c = (questions.size() >= 6 && questions[5] != null) ? questions[5] : null;
            fb.Answer_18__c = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;
            /*fb.Question_19__c = (questions.size() >= 7 && questions[6] != null) ? questions[6] : null;
            fb.Answer_19__c = (questions.size() >= 7 && questions[6] != null) ? data.qa.get(questions[6]) : null;
            fb.Question_20__c = (questions.size() >= 8 && questions[7] != null) ? questions[7] : null;
            //String nps = (questions.size() >= 8 && questions[7] != null) ? data.qa.get(questions[7]) : null;
            String nps = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;*/
            String nps = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }
            fb.Answer_18__c = nps;
            //fb.Answer_20__c = nps;
            //fb.Answer_20__c = (questions.size() >= 8 && questions[7] != null) ? data.qa.get(questions[7]) : null;
            
            insert fb;
            return 'Successfully submitted your feedback';
            
        }else if(data.feedbackType == 'Post Possession Handover'){
            
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Feedback_Type__c = data.feedbackType;
            fb.Mobile_Number__c = data.mobile;
            fb.CRN__c = data.crn;
            List<Opportunity> opp;
            if(data.crn != null){
                opp = [SELECT Id, Booking__r.RW_Key_handover_date__c FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1]; 
            }
            Integer freq;
            if(opp.size() > 0 && opp[0].Booking__r.RW_Key_handover_date__c != null){
                //Integer days = Date.today() - opp[0].Booking__r.RW_Key_handover_date__c;
                Integer days = opp[0].Booking__r.RW_Key_handover_date__c.daysBetween(Date.today());
                if(days >= 360){
                    freq = 360;
                }else if(days >= 270){
                    freq = 270;
                }else if(days >= 180){
                    freq = 180;
                }else if(days >= 120){
                    freq = 120;
                }else if(days >= 60){
                    freq = 60;
                }
            }
            List<WhatsApp_Feedback__c> fbRec = [SELECT Id FROM WhatsApp_Feedback__c WHERE Opportunity__c =: opp[0].Id AND CRN__c =: data.crn AND Feedback_Type__c = 'Post Possession Handover' AND Post_Possession_Frequency__c =: freq];
            if(fbRec.size() == 0){
            
                fb.Opportunity__c = (opp.size() > 0)? opp[0].Id : null;
                List<String> questions  = new List<String>(data.qa.keySet());
                fb.Question_21__c = (questions.size() >= 1 && questions[0] != null) ? questions[0] : null;
                fb.Answer_21__c = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
                fb.Question_22__c = (questions.size() >= 2 && questions[1] != null) ? questions[1] : null;
                fb.Answer_22__c = (questions.size() >= 2 && questions[1] != null) ? data.qa.get(questions[1]) : null;
                fb.Question_23__c = (questions.size() >= 3 && questions[2] != null) ? questions[2] : null;
                fb.Answer_23__c = (questions.size() >= 3 && questions[2] != null) ? data.qa.get(questions[2]) : null;
                fb.Question_24__c = (questions.size() >= 4 && questions[3] != null) ? questions[3] : null;
                fb.Answer_24__c = (questions.size() >= 4 && questions[3] != null) ? data.qa.get(questions[3]) : null;
                fb.Question_25__c = (questions.size() >= 5 && questions[4] != null) ? questions[4] : null;
                fb.Answer_25__c = (questions.size() >= 5 && questions[4] != null) ? data.qa.get(questions[4]) : null;
                fb.Question_26__c = (questions.size() >= 6 && questions[5] != null) ? questions[5] : null;
                fb.Answer_26__c = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;
                fb.Question_27__c = (questions.size() >= 7 && questions[6] != null) ? questions[6] : null;
                fb.Answer_27__c = (questions.size() >= 7 && questions[6] != null) ? data.qa.get(questions[6]) : null;
                fb.Question_28__c = (questions.size() >= 8 && questions[7] != null) ? questions[7] : null;
                fb.Answer_28__c = (questions.size() >= 8 && questions[7] != null) ? data.qa.get(questions[7]) : null;
                fb.Question_29__c = (questions.size() >= 9 && questions[8] != null) ? questions[8] : null;
                String nps = (questions.size() >= 9 && questions[8] != null) ? data.qa.get(questions[8]) : null;
                if(nps != null && nps.length() == 1){
                    nps = '0'+ nps;
                }
                fb.Answer_29__c = nps;
                //fb.Answer_29__c = (questions.size() >= 9 && questions[8] != null) ? data.qa.get(questions[8]) : null;
                fb.Post_Possession_Frequency__c = freq;
                insert fb;
            }
            return 'Successfully submitted your feedback';
            
        }else if(data.feedbackType == 'Sales Experience'){
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Feedback_Type__c = data.feedbackType;
            fb.Mobile_Number__c = data.mobile;
            fb.CRN__c = data.crn;
            List<Opportunity> opp;
            if(data.crn != null){
                opp = [SELECT Id FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1]; 
            }
            fb.Opportunity__c = (opp.size() > 0)? opp[0].Id : null;
            List<String> questions  = new List<String>(data.qa.keySet());
            fb.Sales_Experience_Question_1__c = (questions.size() >= 1 && questions[0] != null) ? questions[0] : null;
            fb.Sales_Experience_Answer_1__c = (questions.size() >= 1 && questions[0] != null) ? data.qa.get(questions[0]) : null;
            fb.Sales_Experience_Question_2__c = (questions.size() >= 2 && questions[1] != null) ? questions[1] : null;
            fb.Sales_Experience_Answer_2__c = (questions.size() >= 2 && questions[1] != null) ? data.qa.get(questions[1]) : null;
            fb.Sales_Experience_Question_3__c = (questions.size() >= 3 && questions[2] != null) ? questions[2] : null;
            fb.Sales_Experience_Answer_3__c = (questions.size() >= 3 && questions[2] != null) ? data.qa.get(questions[2]) : null;
            fb.Sales_Experience_Question_4__c = (questions.size() >= 4 && questions[3] != null) ? questions[3] : null;
            fb.Sales_Experience_Answer_4__c = (questions.size() >= 4 && questions[3] != null) ? data.qa.get(questions[3]) : null;
            fb.Sales_Experience_Question_5__c = (questions.size() >= 5 && questions[4] != null) ? questions[4] : null;
            fb.Sales_Experience_Answer_5__c = (questions.size() >= 5 && questions[4] != null) ? data.qa.get(questions[4]) : null;
            fb.Sales_Experience_Question_6__c = (questions.size() >= 6 && questions[5] != null) ? questions[5] : null;
            //fb.Sales_Experience_Answer_6__c = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;
            String nps = (questions.size() >= 6 && questions[5] != null) ? data.qa.get(questions[5]) : null;
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }
            fb.Sales_Experience_Answer_6__c = nps;
            fb.Sales_Experience_Question_7__c = (questions.size() >= 7 && questions[6] != null) ? questions[6] : null;
            /*String nps = (questions.size() >= 7 && questions[6] != null) ? data.qa.get(questions[6]) : null;
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }*/
            fb.Sales_Experience_Answer_7__c = (questions.size() >= 7 && questions[6] != null) ? data.qa.get(questions[6]) : null;
            //fb.Answer_29__c = (questions.size() >= 9 && questions[8] != null) ? data.qa.get(questions[8]) : null;
            
            insert fb;
            return 'Successfully submitted your feedback';
        }else if(data.feedbackType == 'Generic Feedback'){
            //WhatsApp_Campaign__c wc = [SELECT Id, Name FROM WhatsApp_Campaign__c WHERE Name =: data.campaign LIMIT 1];
            WhatsApp_Campaign__c wc;
            if(!Test.isRunningTest()){
               //wc = [SELECT Id, Name, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: data.campaign LIMIT 1];
               if(data.campaign == 'camp'){
                    wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name = 'camp-0000' LIMIT 1];
                }else{
                    wc = [SELECT Id, Name, Active__c, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Name =: data.campaign LIMIT 1];
                }
            }else{
                wc = [SELECT Id, Name, Campaign_Name__c FROM WhatsApp_Campaign__c LIMIT 1];
            }
            List<String> questions = new List<String>(data.qa.keySet());
            WhatsApp_Feedback__c fb = new WhatsApp_Feedback__c();
            fb.Mobile_Number__c = data.mobile;
            fb.Campaign_Name__c = wc.Campaign_Name__c;
            fb.CRN__c = data.crn;
            fb.Feedback_Type__c = data.feedbackType;
            List<Opportunity> opp;
            if(data.crn != null){
                opp = [SELECT Id FROM Opportunity WHERE SAP_Customer_Number__c =: data.crn LIMIT 1]; 
            }
            fb.Opportunity__c = (opp.size() > 0) ? opp[0].Id : null;
            
            fb.Camp_Question_1__c = (questions.size() > 0 && questions[0] != null)? questions[0] : null;
            fb.Camp_Answer_1__c = (questions.size() > 0 && questions[0] != null)? data.qa.get(questions[0]) : null;
            fb.Camp_Question_2__c = (questions.size() > 1 && questions[1] != null)? questions[1] : null;
            fb.Camp_Answer_2__c = (questions.size() > 1 && questions[1] != null)? data.qa.get(questions[1]) : null;
            fb.Camp_Question_3__c = (questions.size() > 2 && questions[2] != null)? questions[2] : null;
            fb.Camp_Answer_3__c = (questions.size() > 2 && questions[2] != null)? data.qa.get(questions[2]) : null;
            fb.Camp_Question_4__c = (questions.size() > 3 && questions[3] != null)? questions[3] : null;
            fb.Camp_Answer_4__c = (questions.size() > 3 && questions[3] != null)? data.qa.get(questions[3]) : null;
            fb.Camp_Question_5__c = (questions.size() > 4 && questions[4] != null)? questions[4] : null;
            fb.Camp_Answer_5__c = (questions.size() > 4 && questions[4] != null)? data.qa.get(questions[4]) : null;
            fb.Camp_Question_6__c = (questions.size() > 5 && questions[5] != null)? questions[5] : null;
            fb.Camp_Answer_6__c = (questions.size() > 5 && questions[5] != null)? data.qa.get(questions[5]) : null;
            fb.Camp_Question_7__c = (questions.size() > 6 && questions[6] != null)? questions[6] : null;
            fb.Camp_Answer_7__c = (questions.size() > 6 && questions[6] != null)? data.qa.get(questions[6]) : null;
            fb.Camp_Question_8__c = (questions.size() > 7 && questions[7] != null)? questions[7] : null;
            fb.Camp_Answer_8__c = (questions.size() > 7 && questions[7] != null)? data.qa.get(questions[7]) : null;
            fb.Camp_Question_9__c = (questions.size() > 8 && questions[8] != null)? questions[8] : null;
            fb.Camp_Answer_9__c = (questions.size() > 8 && questions[8] != null)? data.qa.get(questions[8]) : null;
            fb.Camp_Question_10__c = (questions.size() > 9 && questions[9] != null)? questions[9] : null;
            fb.Camp_Answer_10__c = (questions.size() > 9 && questions[9] != null)? data.qa.get(questions[9]) : null;
            
            fb.Camp_Question_11__c = (questions.size() > 10 && questions[10] != null)? questions[10] : null;
            fb.Camp_Answer_11__c = (questions.size() > 10 && questions[10] != null)? data.qa.get(questions[10]) : null;
            fb.Camp_Question_12__c = (questions.size() > 11 && questions[11] != null)? questions[11] : null;
            fb.Camp_Answer_12__c = (questions.size() > 11 && questions[11] != null)? data.qa.get(questions[11]) : null;
            fb.Camp_Question_13__c = (questions.size() > 12 && questions[12] != null)? questions[12] : null;
            fb.Camp_Answer_13__c = (questions.size() > 12 && questions[12] != null)? data.qa.get(questions[12]) : null;
            fb.Camp_Question_14__c = (questions.size() > 13 && questions[13] != null)? questions[13] : null;
            fb.Camp_Answer_14__c = (questions.size() > 13 && questions[13] != null)? data.qa.get(questions[13]) : null;
            fb.Camp_Question_15__c = (questions.size() > 14 && questions[14] != null)? questions[14] : null;
            fb.Camp_Answer_15__c = (questions.size() > 14 && questions[14] != null)? data.qa.get(questions[14]) : null;
            fb.Camp_Question_16__c = (questions.size() > 15 && questions[15] != null)? questions[15] : null;
            fb.Camp_Answer_16__c = (questions.size() > 15 && questions[15] != null)? data.qa.get(questions[15]) : null;
            fb.Camp_Question_17__c = (questions.size() > 16 && questions[16] != null)? questions[16] : null;
            fb.Camp_Answer_17__c = (questions.size() > 16 && questions[16] != null)? data.qa.get(questions[16]) : null;
            fb.Camp_Question_18__c = (questions.size() > 17 && questions[17] != null)? questions[17] : null;
            fb.Camp_Answer_18__c = (questions.size() > 17 && questions[17] != null)? data.qa.get(questions[17]) : null;
            fb.Camp_Question_19__c = (questions.size() > 18 && questions[18] != null)? questions[18] : null;
            fb.Camp_Answer_19__c = (questions.size() > 18 && questions[18] != null)? data.qa.get(questions[18]) : null;
            fb.Camp_Question_20__c = (questions.size() > 19 && questions[19] != null)? questions[19] : null;
            fb.Camp_Answer_20__c = (questions.size() > 19 && questions[19] != null)? data.qa.get(questions[19]) : null;
            
            List<String> npsValues = new List<String>{'1','2','3','4','5','6','7','8','9','10'};
            String nps;
            if(npsValues.contains(fb.Camp_Answer_1__c)){
                nps = fb.Camp_Answer_1__c;     
            }else if(npsValues.contains(fb.Camp_Answer_2__c)){
                nps = fb.Camp_Answer_2__c;     
            }else if(npsValues.contains(fb.Camp_Answer_3__c)){
                nps = fb.Camp_Answer_3__c;     
            }else if(npsValues.contains(fb.Camp_Answer_4__c)){
                nps = fb.Camp_Answer_4__c;     
            }else if(npsValues.contains(fb.Camp_Answer_5__c)){
                nps = fb.Camp_Answer_5__c;     
            }else if(npsValues.contains(fb.Camp_Answer_6__c)){
                nps = fb.Camp_Answer_6__c;     
            }else if(npsValues.contains(fb.Camp_Answer_7__c)){
                nps = fb.Camp_Answer_7__c;     
            }else if(npsValues.contains(fb.Camp_Answer_8__c)){
                nps = fb.Camp_Answer_8__c;     
            }else if(npsValues.contains(fb.Camp_Answer_9__c)){
                nps = fb.Camp_Answer_9__c;     
            }else if(npsValues.contains(fb.Camp_Answer_10__c)){
                nps = fb.Camp_Answer_10__c;     
            }else if(npsValues.contains(fb.Camp_Answer_11__c)){
                nps = fb.Camp_Answer_11__c;     
            }else if(npsValues.contains(fb.Camp_Answer_12__c)){
                nps = fb.Camp_Answer_12__c;     
            }else if(npsValues.contains(fb.Camp_Answer_13__c)){
                nps = fb.Camp_Answer_13__c;     
            }else if(npsValues.contains(fb.Camp_Answer_14__c)){
                nps = fb.Camp_Answer_14__c;     
            }else if(npsValues.contains(fb.Camp_Answer_15__c)){
                nps = fb.Camp_Answer_15__c;     
            }else if(npsValues.contains(fb.Camp_Answer_16__c)){
                nps = fb.Camp_Answer_16__c;     
            }else if(npsValues.contains(fb.Camp_Answer_17__c)){
                nps = fb.Camp_Answer_17__c;     
            }else if(npsValues.contains(fb.Camp_Answer_18__c)){
                nps = fb.Camp_Answer_18__c;     
            }else if(npsValues.contains(fb.Camp_Answer_19__c)){
                nps = fb.Camp_Answer_19__c;     
            }else if(npsValues.contains(fb.Camp_Answer_20__c)){
                nps = fb.Camp_Answer_20__c;     
            }
            if(nps != null && nps.length() == 1){
                nps = '0'+ nps;
            }
            fb.Camp_NPS__c = nps;
            insert fb;
            return 'Feedback submitted successfully:- '+ fb.Id;
        }
        return null;
    }
    
    public class FeedbackData{
        String campaign;
        String feedbackType;
        String mobile;
        String crn;
        String caseNum;
        Map<String, String> qa;
    }
    
    global class CustomerDetails{
        String campaign;
        String unit;
        String mobile;
        String crn;
        String message;
        List<Question> questions;
    }
    
    global class Question{
        public String question;
        public String questionType;
    }

}