global class WhatsAppFeedbackBotReportsController {
    
    @AuraEnabled(cacheable=true)
    public static String userDetails(){
        User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c);
        return usr.Feedback_Team__c+':'+usr.NPS_Feedback_Team__c + ':'+ usr.Show_CP_Case_Dashboard__c + ':' + usr.Name;
    }
    
  @AuraEnabled(cacheable=true)
    public static Map<Id, String> getUserIdToManagerNameMap() {
        Map<Id, String> userIdToManagerNameMap = new Map<Id, String>();
        List<User> userList = [SELECT Id, Manager.Name FROM User];
        for(User usr : userList) {
            userIdToManagerNameMap.put(usr.Id, usr.ManagerId != null ? usr.Manager.Name : null);
        }

        return userIdToManagerNameMap;
    }
    @AuraEnabled
    public static List<String> campaignDetails(){
        List<String> recordTypesToDisplay = new List<String>{'Customized','Filtered'};
            List<WhatsApp_Campaign__c> camps = [SELECT Id, Name, Campaign_Name__c FROM WhatsApp_Campaign__c WHERE Status__c = 'Campaign Sent' AND RecordType.Name =: recordTypesToDisplay ORDER BY CreatedDate DESC LIMIT 100];
        List<String> campList = new List<String>();
        for(WhatsApp_Campaign__c camp : camps){
            campList.add(camp.Campaign_Name__c);
        }
        return campList;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> campaignFBDetails(String camp){
        List<WhatsApp_Feedback__c> camps = [SELECT Id, Name, Camp_Question_1__c, Camp_Question_2__c, Camp_Question_3__c, Camp_Question_4__c, Camp_Question_5__c, Camp_Question_6__c, Camp_Question_7__c, Camp_Question_8__c, Camp_Question_9__c, Camp_Question_10__c, Camp_Question_11__c, Camp_Question_12__c, Camp_Question_13__c, Camp_Question_14__c, Camp_Question_15__c, Camp_Question_16__c, Camp_Question_17__c, Camp_Question_18__c, Camp_Question_19__c, Camp_Question_20__c, 
                                            Camp_Answer_1__c, Camp_Answer_2__c, Camp_Answer_3__c, Camp_Answer_4__c, Camp_Answer_5__c, Camp_Answer_6__c, Camp_Answer_7__c, Camp_Answer_8__c, Camp_Answer_9__c, Camp_Answer_10__c, Camp_Answer_11__c, Camp_Answer_12__c, Camp_Answer_13__c, Camp_Answer_14__c, Camp_Answer_15__c, Camp_Answer_16__c, Camp_Answer_17__c, Camp_Answer_18__c, Camp_Answer_19__c, Camp_Answer_20__c, 
                                            Campaign_Name__c, NPS__c, Feedback_Type__c, Opportunity__c, Opportunity__r.Name, Project__c, CRN__c FROM WhatsApp_Feedback__c WHERE Campaign_Name__c =: camp];
        return camps;
    }
    
    @AuraEnabled
    public static List<String> campaignFBQuestions(String camp){
        List<WhatsApp_Feedback_Campaign__mdt> feedbackQus = [SELECT Id, Campaign_Name__c, Question_1__c,  Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_1_Type__c, Question_2_Type__c, Question_3_Type__c, Question_4_Type__c, Question_5_Type__c, Question_6_Type__c, Question_7_Type__c, Question_8_Type__c, Question_9_Type__c, Question_10_Type__c, 
                                                             Question_11__c,  Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_11_Type__c, Question_12_Type__c, Question_13_Type__c, Question_14_Type__c, Question_15_Type__c, Question_16_Type__c, Question_17_Type__c, Question_18_Type__c, Question_19_Type__c, Question_20_Type__c
                                                             FROM WhatsApp_Feedback_Campaign__mdt WHERE Campaign_Name__c =: camp LIMIT 1];
        List<String> questions = new List<String>();
        questions.add(feedbackQus[0].Question_1__c);
        questions.add(feedbackQus[0].Question_2__c);
        questions.add(feedbackQus[0].Question_3__c);
        questions.add(feedbackQus[0].Question_4__c);
        questions.add(feedbackQus[0].Question_5__c);
        questions.add(feedbackQus[0].Question_6__c);
        questions.add(feedbackQus[0].Question_7__c);
        questions.add(feedbackQus[0].Question_8__c);
        questions.add(feedbackQus[0].Question_9__c);
        questions.add(feedbackQus[0].Question_10__c);
        questions.add(feedbackQus[0].Question_11__c);
        questions.add(feedbackQus[0].Question_12__c);
        questions.add(feedbackQus[0].Question_13__c);
        questions.add(feedbackQus[0].Question_14__c);
        questions.add(feedbackQus[0].Question_15__c);
        questions.add(feedbackQus[0].Question_16__c);
        questions.add(feedbackQus[0].Question_17__c);
        questions.add(feedbackQus[0].Question_18__c);
        questions.add(feedbackQus[0].Question_19__c);
        questions.add(feedbackQus[0].Question_20__c);
        return questions;
    }
    
    @AuraEnabled
    public static Map<String, Integer> eventReport(String userTeam, String dateRange, String year, String month){
        
        String team = userTeam.split(':')[0];
        String team2 = userTeam.split(':')[1];
        
        Map<String, Integer> countMap = new Map<String, Integer>();
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        //fbList = Database.query(eventReportQueryBuilder(team, dateRange));
        if(year != null && year != '' && month != null && month != ''){
            String qry = yearMonthQueryBuilder(team, year, month);
            fbList = Database.query(qry);
        }else{
            fbList = Database.query(eventReportQueryBuilder(team, dateRange));
        }
        System.debug('fbList: ' + fbList.size());
        List<WhatsApp_Feedback__c> dayOfRegFbList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> dayOfRKeyHandFbList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post60DaysFbList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> salesExpFbList = new List<WhatsApp_Feedback__c>();
        
        for(WhatsApp_Feedback__c fb : fbList){
            if(team2 == 'All' || team2 == 'Sales'){
                if(fb.Feedback_Type__c == 'Sales Experience'){
                    salesExpFbList.add(fb);
                }
            }
            if(team2 == 'All' || team2 == 'CRM'){
                if(fb.Feedback_Type__c == 'Day of Registration'){
                    dayOfRegFbList.add(fb);
                }else if(fb.Feedback_Type__c == 'Day of Possession Handover'){
                    dayOfRKeyHandFbList.add(fb);
                }else if(fb.Feedback_Type__c == 'Post Possession Handover'){
                    post60DaysFbList.add(fb);
                }
            }
            
            
        }
        
        Map<String, Map<String,Integer>> count = new Map<String, Map<String,Integer>>();
        
        Map<String, Integer> dayOfRegcount = new Map<String, Integer>();
        dayOfRegcount.put('Excellent',0);
        dayOfRegcount.put('Very Good',0);
        dayOfRegcount.put('Good',0);
        dayOfRegcount.put('Bad',0);
        for(WhatsApp_Feedback__c fb : dayOfRegFbList){
            if(dayOfRegcount.keySet().contains(fb.Answer_2__c)){
                dayOfRegcount.put(fb.Answer_2__c, dayOfRegcount.get(fb.Answer_2__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_3__c)){
                dayOfRegcount.put(fb.Answer_3__c, dayOfRegcount.get(fb.Answer_3__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_4__c)){
                dayOfRegcount.put(fb.Answer_4__c, dayOfRegcount.get(fb.Answer_4__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_5__c)){
                dayOfRegcount.put(fb.Answer_5__c, dayOfRegcount.get(fb.Answer_5__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_7__c)){
                dayOfRegcount.put(fb.Answer_7__c, dayOfRegcount.get(fb.Answer_7__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_8__c)){
                dayOfRegcount.put(fb.Answer_8__c, dayOfRegcount.get(fb.Answer_8__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_9__c)){
                dayOfRegcount.put(fb.Answer_9__c, dayOfRegcount.get(fb.Answer_9__c)+1);
            }
            if(dayOfRegcount.keySet().contains(fb.Answer_10__c)){
                dayOfRegcount.put(fb.Answer_10__c, dayOfRegcount.get(fb.Answer_10__c)+1);
            }
        }
        System.debug('--dayOfRegcount--');
        System.debug('Excellent Count: ' + dayOfRegcount.get('Excellent'));
        System.debug('Very Good Count: ' + dayOfRegcount.get('Very Good'));
        System.debug('Good Count: ' + dayOfRegcount.get('Good'));
        System.debug('Bad Count: ' + dayOfRegcount.get('Bad'));
        
        countMap.put('dayofReg_Excellent', dayOfRegcount.get('Excellent'));
        countMap.put('dayofReg_Very_Good', dayOfRegcount.get('Very Good'));
        countMap.put('dayofReg_Good', dayOfRegcount.get('Good'));
        countMap.put('dayofReg_Bad', dayOfRegcount.get('Bad'));
        
        Map<String, Integer> dayOfRKeyHandcount = new Map<String, Integer>();
        dayOfRKeyHandcount.put('Excellent',0);
        dayOfRKeyHandcount.put('Very Good',0);
        dayOfRKeyHandcount.put('Good',0);
        dayOfRKeyHandcount.put('Bad',0);
        for(WhatsApp_Feedback__c fb : dayOfRKeyHandFbList){
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_13__c)){
                dayOfRKeyHandcount.put(fb.Answer_13__c, dayOfRKeyHandcount.get(fb.Answer_13__c)+1);
            }
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_14__c)){
                dayOfRKeyHandcount.put(fb.Answer_14__c, dayOfRKeyHandcount.get(fb.Answer_14__c)+1);
            }
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_15__c)){
                dayOfRKeyHandcount.put(fb.Answer_15__c, dayOfRKeyHandcount.get(fb.Answer_15__c)+1);
            }
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_16__c)){
                dayOfRKeyHandcount.put(fb.Answer_16__c, dayOfRKeyHandcount.get(fb.Answer_16__c)+1);
            }
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_17__c)){
                dayOfRKeyHandcount.put(fb.Answer_17__c, dayOfRKeyHandcount.get(fb.Answer_17__c)+1);
            }
            if(dayOfRKeyHandcount.keySet().contains(fb.Answer_18__c)){
                dayOfRKeyHandcount.put(fb.Answer_18__c, dayOfRKeyHandcount.get(fb.Answer_18__c)+1);
            }
        }
        
        countMap.put('dayOfRKeyHand_Excellent', dayOfRKeyHandcount.get('Excellent'));
        countMap.put('dayOfRKeyHand_Very_Good', dayOfRKeyHandcount.get('Very Good'));
        countMap.put('dayOfRKeyHand_Good', dayOfRKeyHandcount.get('Good'));
        countMap.put('dayOfRKeyHand_Bad', dayOfRKeyHandcount.get('Bad'));
        
        Map<String, Integer> post60Dayscount = new Map<String, Integer>();
        post60Dayscount.put('Excellent',0);
        post60Dayscount.put('Very Good',0);
        post60Dayscount.put('Good',0);
        post60Dayscount.put('Bad',0);
        for(WhatsApp_Feedback__c fb : post60DaysFbList){
            if(post60Dayscount.keySet().contains(fb.Answer_21__c)){
                post60Dayscount.put(fb.Answer_21__c, post60Dayscount.get(fb.Answer_21__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_22__c)){
                post60Dayscount.put(fb.Answer_22__c, post60Dayscount.get(fb.Answer_22__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_23__c)){
                post60Dayscount.put(fb.Answer_23__c, post60Dayscount.get(fb.Answer_23__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_24__c)){
                post60Dayscount.put(fb.Answer_24__c, post60Dayscount.get(fb.Answer_24__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_25__c)){
                post60Dayscount.put(fb.Answer_25__c, post60Dayscount.get(fb.Answer_25__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_26__c)){
                post60Dayscount.put(fb.Answer_26__c, post60Dayscount.get(fb.Answer_26__c)+1);
            }
            if(post60Dayscount.keySet().contains(fb.Answer_27__c)){
                post60Dayscount.put(fb.Answer_27__c, post60Dayscount.get(fb.Answer_27__c)+1);
            }
        }
        
        countMap.put('post60Days_Excellent', post60Dayscount.get('Excellent'));
        countMap.put('post60Days_Very_Good', post60Dayscount.get('Very Good'));
        countMap.put('post60Days_Good', post60Dayscount.get('Good'));
        countMap.put('post60Days_Bad', post60Dayscount.get('Bad'));
        
        
        Map<String, Integer> salesExpcount = new Map<String, Integer>();
        salesExpcount.put('Excellent',0);
        salesExpcount.put('Very Good',0);
        salesExpcount.put('Good',0);
        salesExpcount.put('Bad',0);
        for(WhatsApp_Feedback__c fb : salesExpFbList){
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_1__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_1__c, salesExpcount.get(fb.Sales_Experience_Answer_1__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_2__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_2__c, salesExpcount.get(fb.Sales_Experience_Answer_2__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_3__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_3__c, salesExpcount.get(fb.Sales_Experience_Answer_3__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_4__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_4__c, salesExpcount.get(fb.Sales_Experience_Answer_4__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_5__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_5__c, salesExpcount.get(fb.Sales_Experience_Answer_5__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_6__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_6__c, salesExpcount.get(fb.Sales_Experience_Answer_6__c)+1);
            }
            if(salesExpcount.keySet().contains(fb.Sales_Experience_Answer_7__c)){
                salesExpcount.put(fb.Sales_Experience_Answer_7__c, salesExpcount.get(fb.Sales_Experience_Answer_7__c)+1);
            }
        }
        
        countMap.put('salesExp_Excellent', salesExpcount.get('Excellent'));
        countMap.put('salesExp_Very_Good', salesExpcount.get('Very Good'));
        countMap.put('salesExp_Good', salesExpcount.get('Good'));
        countMap.put('salesExp_Bad', salesExpcount.get('Bad'));
        
        countMap.put('overall_Excellent', dayOfRegcount.get('Excellent') + dayOfRKeyHandcount.get('Excellent') + post60Dayscount.get('Excellent') + salesExpcount.get('Excellent')); 
        countMap.put('overall_Very_Good', dayOfRegcount.get('Very Good') + dayOfRKeyHandcount.get('Very Good') + post60Dayscount.get('Very Good') + salesExpcount.get('Very Good')); 
        countMap.put('overall_Good', dayOfRegcount.get('Good') + dayOfRKeyHandcount.get('Good') + post60Dayscount.get('Good') + salesExpcount.get('Good')); 
        countMap.put('overall_Bad', dayOfRegcount.get('Bad') + dayOfRKeyHandcount.get('Bad') + post60Dayscount.get('Bad') + salesExpcount.get('Bad')); 
        return countMap;
    }
    
    public static String eventReportQueryBuilder(String team, String dateRange){
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Answer_2__c, Question_3__c, Answer_3__c, Question_4__c, Answer_4__c, Question_5__c,  Answer_5__c, Question_6__c, Answer_6__c, Question_7__c, Answer_7__c, Question_8__c, Answer_8__c, Question_9__c, Answer_9__c, Question_10__c, Answer_10__c, Question_11__c, Answer_11__c, Question_12__c, Answer_12__c, Question_13__c, Answer_13__c, Question_14__c, Answer_14__c, Question_15__c, Answer_15__c, Question_16__c,  Answer_16__c, Question_17__c, Answer_17__c, Question_18__c, Answer_18__c, Question_19__c, Answer_19__c, Question_20__c, Answer_20__c, Question_21__c, Answer_21__c, Question_22__c, Answer_22__c, Question_23__c, Answer_23__c, Question_24__c, Answer_24__c, Question_25__c, Answer_25__c, Question_26__c, Answer_26__c, Question_27__c, Answer_27__c, Sales_Experience_Answer_1__c, Sales_Experience_Answer_2__c, Sales_Experience_Answer_3__c, Sales_Experience_Answer_4__c, Sales_Experience_Answer_5__c, Sales_Experience_Answer_6__c, Sales_Experience_Answer_7__c, Post_Possession_Frequency__c, Post_Possession_Frequency_Days__c FROM WhatsApp_Feedback__c';
        String teamQry = teamQuery(team);
        
        if(team != null && team != ''){
            qry += ' WHERE ' + teamQry;
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                if(dateRange == 'LAST_N_MONTHS:3'){
                    Date dt = System.today() - 90;
                    qry += ' AND Feedback_Date__c >= '+ dt;
                }else if(dateRange == 'LAST_N_MONTHS:6'){
                    Date dt = System.today() - 180;
                    qry += ' AND Feedback_Date__c >= '+ dt;
                }else{
                    qry += ' AND CreatedDate = '+dateRange;
                }
                qry = qry.replace(' 00:00:00', '');
            }
        }else if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' WHERE Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' WHERE Feedback_Date__c >= '+ dt;
            }else{
                qry += ' WHERE Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }
        qry += ' AND NPS__c != null';
        System.debug('qry: ' + qry);
        return qry;
    }
    
    @AuraEnabled
    public static List<eventData> recordDetails(String fbType, String team, String dateRange, String year, String month){
        
        String feedbackType;
        String eventType;
        
        if(fbType != null){
            List<String> fbTypeSplit = fbType.split('_');
            feedbackType = fbTypeSplit[0];
            eventType = fbTypeSplit[1];
        }
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        
        String qry;
        
        if(feedbackType == 'Day of Registration'){
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_11__c, Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_21__c, Question_22__c, Question_23__c, Question_24__c, Question_25__c, Question_26__c, Question_27__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Answer_7__c, Answer_8__c, Answer_9__c, Answer_10__c, Answer_11__c, Answer_12__c, Answer_13__c, Answer_14__c, Answer_15__c, Answer_16__c, Answer_17__c, Answer_18__c, Answer_19__c, Answer_20__c, Answer_21__c, Answer_22__c, Answer_23__c, Answer_24__c, Answer_25__c, Answer_26__c, Answer_27__c FROM WhatsApp_Feedback__c WHERE Feedback_Type__c = \'Day of Registration\' AND (Answer_2__c =: eventType OR Answer_3__c =: eventType OR Answer_4__c =: eventType OR Answer_5__c =: eventType OR Answer_7__c =: eventType OR Answer_8__c =: eventType OR Answer_9__c =: eventType OR Answer_10__c =: eventType)';
        }else if(feedbackType == 'Day of Possession'){
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_11__c, Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_21__c, Question_22__c, Question_23__c, Question_24__c, Question_25__c, Question_26__c, Question_27__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Answer_7__c, Answer_8__c, Answer_9__c, Answer_10__c, Answer_11__c, Answer_12__c, Answer_13__c, Answer_14__c, Answer_15__c, Answer_16__c, Answer_17__c, Answer_18__c, Answer_19__c, Answer_20__c, Answer_21__c, Answer_22__c, Answer_23__c, Answer_24__c, Answer_25__c, Answer_26__c, Answer_27__c FROM WhatsApp_Feedback__c WHERE Feedback_Type__c = \'Day of Possession Handover\' AND (Answer_13__c =: eventType OR Answer_14__c =: eventType OR Answer_15__c =: eventType OR Answer_16__c =: eventType OR Answer_17__c =: eventType OR Answer_18__c =: eventType)';
        }else if(feedbackType == 'Post 60 Days Possession'){
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_11__c, Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_21__c, Question_22__c, Question_23__c, Question_24__c, Question_25__c, Question_26__c, Question_27__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Answer_7__c, Answer_8__c, Answer_9__c, Answer_10__c, Answer_11__c, Answer_12__c, Answer_13__c, Answer_14__c, Answer_15__c, Answer_16__c, Answer_17__c, Answer_18__c, Answer_19__c, Answer_20__c, Answer_21__c, Answer_22__c, Answer_23__c, Answer_24__c, Answer_25__c, Answer_26__c, Answer_27__c FROM WhatsApp_Feedback__c WHERE Feedback_Type__c = \'Post Possession Handover\' AND (Answer_21__c =: eventType OR Answer_22__c =: eventType OR Answer_23__c =: eventType OR Answer_24__c =: eventType OR Answer_25__c =: eventType OR Answer_26__c =: eventType OR Answer_27__c =: eventType)';
        }else if(feedbackType == 'Sales Experience'){
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Sales_Experience_Answer_1__c, Sales_Experience_Answer_2__c, Sales_Experience_Answer_3__c, Sales_Experience_Answer_4__c, Sales_Experience_Answer_5__c, Sales_Experience_Answer_6__c, Sales_Experience_Answer_7__c, Sales_Experience_Question_1__c, Sales_Experience_Question_2__c, Sales_Experience_Question_3__c, Sales_Experience_Question_4__c, Sales_Experience_Question_5__c, Sales_Experience_Question_6__c, Sales_Experience_Question_7__c FROM WhatsApp_Feedback__c WHERE Feedback_Type__c = \'Sales Experience\' AND (Sales_Experience_Answer_1__c =: eventType OR Sales_Experience_Answer_2__c =: eventType OR Sales_Experience_Answer_3__c =: eventType OR Sales_Experience_Answer_4__c =: eventType OR Sales_Experience_Answer_5__c =: eventType OR Sales_Experience_Answer_6__c =: eventType)';
        }
        System.debug('team: ' + team);
        String teamQry = teamQuery(team);
        qry += ' AND ' + teamQry;
        
        if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else{
                qry += ' AND Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }else if(month != null && year != null && dateRange == 'Custom'){
            Integer yearInt = Integer.valueOf(year);
            Integer monthInt = Integer.valueOf(month);
            qry += ' AND Month__c = ' + monthInt + ' AND Year__c = ' + yearInt;
        }
        System.debug('qry: ' + qry);
        fbList = Database.query(qry);
        List<eventData> dataList = new List<eventData>();
        for(WhatsApp_Feedback__c fb : fbList){
            eventData dt = new eventData();
            dt.recId = fb.Id;
            dt.name = fb.Name;
            dt.crn = fb.CRN__c;
            dt.project = fb.Project__c;
            dt.feedbackType = fb.Feedback_Type__c;
            dt.customer = fb.Opportunity_Name__c;
            dt.oppId = fb.Opportunity__c;
            //dt.mobile = fb.Mobile__c;
            List<String> questions = new List<String>();
            if(fb.Feedback_Type__c == 'Day of Registration'){
                if(fb.Answer_2__c == eventType){
                    questions.add(fb.Question_2__c);
                }
                if(fb.Answer_3__c == eventType){
                    questions.add(fb.Question_3__c);
                }
                if(fb.Answer_4__c == eventType){
                    questions.add(fb.Question_4__c);
                }
                if(fb.Answer_5__c == eventType){
                    questions.add(fb.Question_5__c);
                }
                if(fb.Answer_7__c == eventType){
                    questions.add(fb.Question_7__c);
                }
                if(fb.Answer_8__c == eventType){
                    questions.add(fb.Question_8__c);
                }
                if(fb.Answer_9__c == eventType){
                    questions.add(fb.Question_9__c);
                }
                if(fb.Answer_10__c == eventType){
                    questions.add(fb.Question_10__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }else if(fb.Feedback_Type__c == 'Day of Possession Handover'){
                if(fb.Answer_13__c == eventType){
                    questions.add(fb.Question_13__c);
                }
                if(fb.Answer_14__c == eventType){
                    questions.add(fb.Question_14__c);
                }
                if(fb.Answer_15__c == eventType){
                    questions.add(fb.Question_15__c);
                }
                if(fb.Answer_16__c == eventType){
                    questions.add(fb.Question_16__c);
                }
                if(fb.Answer_17__c == eventType){
                    questions.add(fb.Question_17__c);
                }
                if(fb.Answer_18__c == eventType){
                    questions.add(fb.Question_18__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover'){
                if(fb.Answer_21__c == eventType){
                    questions.add(fb.Question_21__c);
                }
                if(fb.Answer_22__c == eventType){
                    questions.add(fb.Question_22__c);
                }
                if(fb.Answer_23__c == eventType){
                    questions.add(fb.Question_23__c);
                }
                if(fb.Answer_24__c == eventType){
                    questions.add(fb.Question_24__c);
                }
                if(fb.Answer_25__c == eventType){
                    questions.add(fb.Question_25__c);
                }
                if(fb.Answer_26__c == eventType){
                    questions.add(fb.Question_26__c);
                }
                if(fb.Answer_27__c == eventType){
                    questions.add(fb.Question_27__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }else if(fb.Feedback_Type__c == 'Sales Experience'){
                if(fb.Sales_Experience_Answer_1__c == eventType){
                    questions.add(fb.Sales_Experience_Question_1__c);
                }
                if(fb.Sales_Experience_Answer_2__c == eventType){
                    questions.add(fb.Sales_Experience_Question_2__c);
                }
                if(fb.Sales_Experience_Answer_3__c == eventType){
                    questions.add(fb.Sales_Experience_Question_3__c);
                }
                if(fb.Sales_Experience_Answer_4__c == eventType){
                    questions.add(fb.Sales_Experience_Question_4__c);
                }
                if(fb.Sales_Experience_Answer_5__c == eventType){
                    questions.add(fb.Sales_Experience_Question_5__c);
                }
                if(fb.Sales_Experience_Answer_6__c == eventType){
                    questions.add(fb.Sales_Experience_Question_6__c);
                }
                if(fb.Sales_Experience_Answer_7__c == eventType){
                    questions.add(fb.Sales_Experience_Question_7__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }
            
        }
        System.debug('dataList: ' + dataList);
        return dataList;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> npsRecordDetails(String fbType, String team, String dateRange, String year, String month){
        
        String feedbackType;
        String project;
        String npsValue;
        
        if(fbType != null){
            List<String> fbTypeSplit = fbType.split('_');
            project = fbTypeSplit[0];
            feedbackType = fbTypeSplit[1];
            npsValue = fbTypeSplit[2];
        }
        
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE ';
        String teamQry = teamQuery(team);
        
        if(project == 'All Projects'){
            qry += teamQry + ' AND Feedback_Type__c =: feedbackType AND NPS__c =: npsValue';
        }else{
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType AND NPS__c =: npsValue';
        }
        System.debug('qry: ' + qry);
        if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else{
                qry += ' AND Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }else if(dateRange == 'Custom' && month != null && year != null){
            Integer yearInt = Integer.valueOf(year);
            Integer monthInt = Integer.valueOf(month);
            qry += ' AND Month__c = ' + monthInt + ' AND Year__c = ' + yearInt;
        }
        List<WhatsApp_Feedback__c> feedbacks = Database.query(qry);
        return feedbacks;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> npsRecordDetailsPPD(String fbType, String team, String dateRange, String year, String month){
        
        String feedbackType;
        String project;
        String npsValue;
        
        if(fbType != null){
            List<String> fbTypeSplit = fbType.split('_');
            project = fbTypeSplit[0];
            feedbackType = fbTypeSplit[1];
            npsValue = fbTypeSplit[2];
        }
        
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE ';
        String teamQry = teamQuery(team);
        
        if(project == 'All Projects'){
            qry += teamQry + ' AND Feedback_Type__c =: feedbackType';
            
        }else{
            qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType';
        }
        
        if(npsValue == 'promoters'){
            qry += ' AND (NPS__c = \'10\' OR NPS__c = \'09\')';
        }else if(npsValue == 'passives'){
            qry += ' AND (NPS__c = \'08\' OR NPS__c = \'07\')';
        }else if(npsValue == 'detractors'){
            qry += ' AND (NPS__c = \'06\' OR NPS__c = \'05\' OR NPS__c = \'04\' OR NPS__c = \'03\' OR NPS__c = \'02\' OR NPS__c = \'01\')';
        }
        
        System.debug('qry: ' + qry);
        if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else{
                qry += ' AND Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }else if(dateRange == 'Custom' && month != null && year != null){
            Integer yearInt = Integer.valueOf(year);
            Integer monthInt = Integer.valueOf(month);
            qry += ' AND Month__c = ' + monthInt + ' AND Year__c = ' + yearInt;
        }
        List<WhatsApp_Feedback__c> feedbacks = Database.query(qry);
        return feedbacks;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> dayOfRegData(String team, String dateRange, String year, String month, String report, Boolean isExport){
        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Day of Registration\'';
        }else{
            qry = eventReportQueryBuilder(team, dateRange);
            if((team != null && team != '') || (dateRange != null && dateRange != '' && dateRange != 'Custom')){
                qry += ' AND Feedback_Type__c = \'Day of Registration\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Day of Registration\'';
            }
        }
        if(report == 'Event' && isExport == false){
            qry += ' AND Question_Set__c = null';
        }
        System.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    /*@auraEnabled
public static List<WhatsApp_Feedback__c> dayOfRegDataExport(String team, String dateRange, String year, String month){

String qry;
if(year != null && year != '' && month != null && month != ''){
qry = yearMonthQueryBuilder(team, year, month);
qry += ' AND Feedback_Type__c = \'Day of Registration\'';
}else{
qry = eventReportQueryBuilder(team, dateRange);
if((team != null && team != '') || (dateRange != null && dateRange != '' && dateRange != 'Custom')){
qry += ' AND Feedback_Type__c = \'Day of Registration\'';
}else{
qry += ' WHERE Feedback_Type__c = \'Day of Registration\'';
}
}
System.debug('qry: ' + qry);
List<WhatsApp_Feedback__c> fbList = Database.query(qry);
return fbList;
}*/
    
    
    public static String teamQuery(String team){
        List<String> mycityProj = System.label.MyCity_Projects.split(',');
        List<String> gardensProj = System.label.Gardens_Projects.split(',');
        List<String> mumbaiProj = System.label.Mumbai_Projects.split(',');
        List<String> dombivliProj = (System.label.MyCity_Projects + ',' + System.label.Gardens_Projects).split(',');
        if(team == 'MyCity'){
            String mycityProjStr = '';
            for(String st : mycityProj){
                if(mycityProjStr == ''){
                    mycityProjStr += '(Project__c = \''+ st + '\'';
                }else{
                    mycityProjStr += ' OR Project__c = \''+ st + '\'';
                }
            }
            mycityProjStr += ')';
            return mycityProjStr;
        }else if(team == 'Gardens'){
            String gardensProjStr = '';
            for(String st : gardensProj){
                if(gardensProjStr == ''){
                    gardensProjStr += '(Project__c = \''+ st + '\'';
                }else{
                    gardensProjStr += ' OR Project__c = \''+ st + '\'';
                }
            }
            gardensProjStr += ')';
            return gardensProjStr;
        }else if(team == 'Mumbai'){
            String mumbaiProjStr = '';
            for(String st : mumbaiProj){
                if(mumbaiProjStr == ''){
                    mumbaiProjStr += '(Project__c = \''+ st + '\'';
                }else{
                    mumbaiProjStr += ' OR Project__c = \''+ st + '\'';
                }
            }
            mumbaiProjStr += ')';
            return mumbaiProjStr;
        }else if(team == 'Dombivli'){
            String dombivliProjStr = '';
            for(String st : dombivliProj){
                if(dombivliProjStr == ''){
                    dombivliProjStr += '(Project__c = \''+ st + '\'';
                }else{
                    dombivliProjStr += ' OR Project__c = \''+ st + '\'';
                }
            }
            dombivliProjStr += ')';
            return dombivliProjStr;
        }else if(team == 'Admin'){
            String adminStr = 'Project__c != null';
            return adminStr;
        }
        return null;  
    }
      public static String Caseteam(String team){
        List<String> mycityProj = System.label.MyCity_Projects.split(',');
        List<String> gardensProj = System.label.Gardens_Projects.split(',');
        List<String> mumbaiProj = System.label.Mumbai_Projects.split(',');
        List<String> dombivliProj = (System.label.MyCity_Projects + ',' + System.label.Gardens_Projects).split(',');
        if(team == 'MyCity'){
            String mycityProjStr = '';
            for(String st : mycityProj){
                if(mycityProjStr == ''){
                    mycityProjStr += '(RW_Project__r.Name = \''+ st + '\'';
                }else{
                    mycityProjStr += ' OR RW_Project__r.Name = \''+ st + '\'';
                }
            }
            mycityProjStr += ')';
            return mycityProjStr;
        }else if(team == 'Gardens'){
            String gardensProjStr = '';
            for(String st : gardensProj){
                if(gardensProjStr == ''){
                    gardensProjStr += '(RW_Project__r.Name = \''+ st + '\'';
                }else{
                    gardensProjStr += ' OR RW_Project__r.Name = \''+ st + '\'';
                }
            }
            gardensProjStr += ')';
            return gardensProjStr;
        }else if(team == 'Mumbai'){
            String mumbaiProjStr = '';
            for(String st : mumbaiProj){
                if(mumbaiProjStr == ''){
                    mumbaiProjStr += '(RW_Project__r.Name = \''+ st + '\'';
                }else{
                    mumbaiProjStr += ' OR RW_Project__r.Name = \''+ st + '\'';
                }
            }
            mumbaiProjStr += ')';
            return mumbaiProjStr;
        }else if(team == 'Dombivli'){
            String dombivliProjStr = '';
            for(String st : dombivliProj){
                if(dombivliProjStr == ''){
                    dombivliProjStr += '(RW_Project__r.Name = \''+ st + '\'';
                }else{
                    dombivliProjStr += ' OR RW_Project__r.Name = \''+ st + '\'';
                }
            }
            dombivliProjStr += ')';
            return dombivliProjStr;
        }else if(team == 'Admin'){
            String adminStr = 'RW_Project__r.Name != null';
            return adminStr;
        }
        return null;  
    }
    @auraEnabled
    public static List<eventData> overallDayOfRegData(String fbType, String team, String dateRange){
        
        List<String> fbEvntType = fbType.split('_');
        String eventType = fbEvntType[1];
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_11__c, Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_21__c, Question_22__c, Question_23__c, Question_24__c, Question_25__c, Question_26__c, Question_27__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Answer_7__c, Answer_8__c, Answer_9__c, Answer_10__c, Answer_11__c, Answer_12__c, Answer_13__c, Answer_14__c, Answer_15__c, Answer_16__c, Answer_17__c, Answer_18__c, Answer_19__c, Answer_20__c, Answer_21__c, Answer_22__c, Answer_23__c, Answer_24__c, Answer_25__c, Answer_26__c, Answer_27__c FROM WhatsApp_Feedback__c';
        qry += ' WHERE (Answer_2__c =: eventType OR Answer_3__c =: eventType OR Answer_4__c =: eventType OR Answer_5__c =: eventType OR Answer_7__c =: eventType OR Answer_8__c =: eventType OR Answer_9__c =: eventType OR Answer_10__c =: eventType OR Answer_13__c =: eventType OR Answer_14__c =: eventType OR Answer_15__c =: eventType OR Answer_16__c =: eventType OR Answer_17__c =: eventType OR Answer_18__c =: eventType OR Answer_21__c =: eventType OR Answer_22__c =: eventType OR Answer_23__c =: eventType OR Answer_24__c =: eventType OR Answer_25__c =: eventType OR Answer_26__c =: eventType OR Answer_27__c =: eventType)';
        String teamQry = teamQuery(team);
        qry += ' AND ' + teamQry;
        
        if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' AND Feedback_Date__c >= '+ dt;
            }else{
                qry += ' AND Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }
        qry += ' ORDER BY Feedback_Type__c, Project__c DESC';
        System.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        List<eventData> dataList = new List<eventData>();
        for(WhatsApp_Feedback__c fb : fbList){
            eventData dt = new eventData();
            dt.recId = fb.Id;
            dt.name = fb.Name;
            dt.crn = fb.CRN__c;
            dt.project = fb.Project__c;
            dt.feedbackType = fb.Feedback_Type__c;
            dt.customer = fb.Opportunity_Name__c;
            dt.oppId = fb.Opportunity__c;
            //dt.mobile = fb.Mobile__c;
            List<String> questions = new List<String>();
            if(fb.Feedback_Type__c == 'Day of Registration'){
                if(fb.Answer_2__c == eventType){
                    questions.add(fb.Question_2__c);
                }
                if(fb.Answer_3__c == eventType){
                    questions.add(fb.Question_3__c);
                }
                if(fb.Answer_4__c == eventType){
                    questions.add(fb.Question_4__c);
                }
                if(fb.Answer_5__c == eventType){
                    questions.add(fb.Question_5__c);
                }
                if(fb.Answer_7__c == eventType){
                    questions.add(fb.Question_7__c);
                }
                if(fb.Answer_8__c == eventType){
                    questions.add(fb.Question_8__c);
                }
                if(fb.Answer_9__c == eventType){
                    questions.add(fb.Question_9__c);
                }
                if(fb.Answer_10__c == eventType){
                    questions.add(fb.Question_10__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }else if(fb.Feedback_Type__c == 'Day of Possession Handover'){
                if(fb.Answer_13__c == eventType){
                    questions.add(fb.Question_13__c);
                }
                if(fb.Answer_14__c == eventType){
                    questions.add(fb.Question_14__c);
                }
                if(fb.Answer_15__c == eventType){
                    questions.add(fb.Question_15__c);
                }
                if(fb.Answer_16__c == eventType){
                    questions.add(fb.Question_16__c);
                }
                if(fb.Answer_17__c == eventType){
                    questions.add(fb.Question_17__c);
                }
                if(fb.Answer_18__c == eventType){
                    questions.add(fb.Question_18__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover'){
                if(fb.Answer_21__c == eventType){
                    questions.add(fb.Question_21__c);
                }
                if(fb.Answer_22__c == eventType){
                    questions.add(fb.Question_22__c);
                }
                if(fb.Answer_23__c == eventType){
                    questions.add(fb.Question_23__c);
                }
                if(fb.Answer_24__c == eventType){
                    questions.add(fb.Question_24__c);
                }
                if(fb.Answer_25__c == eventType){
                    questions.add(fb.Question_25__c);
                }
                if(fb.Answer_26__c == eventType){
                    questions.add(fb.Question_26__c);
                }
                if(fb.Answer_27__c == eventType){
                    questions.add(fb.Question_27__c);
                }
                dt.questions = questions;
                dataList.add(dt);
            }
        }
        System.debug('dataList: ' + dataList);
        return dataList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> dayOfRegNpsData(String proj, String dateRange, String team, String year, String month){
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Day of Registration\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Day of Registration\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Day of Registration\'';
            }
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        qry += ' AND NPS__c != null';
        System.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        System.debug('fbList: ' + fbList);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> dayofPosData(String team, String dateRange, String year, String month, String report, Boolean isExport){
        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Day of Possession Handover\'';
        }else{
            qry = eventReportQueryBuilder(team, dateRange);
            if((team != null && team != '') || (dateRange != null && dateRange != '')){
                qry += ' AND Feedback_Type__c = \'Day of Possession Handover\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Day of Possession Handover\'';
            }
        }
        if(report == 'Event' && isExport == false){
            qry += ' AND Question_Set__c = null';
        }
        
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> dayofPosNpsData(String proj, String dateRange, String team, String year, String month){
        
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Day of Possession Handover\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Day of Possession Handover\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Day of Possession Handover\'';
            }
        }
        
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        qry += ' AND NPS__c != null';
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> postPosData(String team, String dateRange, String year, String month, String report, Boolean isExport){
        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
        }else{
            qry = eventReportQueryBuilder(team, dateRange);
            if((team != null && team != '') || (dateRange != null && dateRange != '')){
                qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Post Possession Handover\'';
            }
        }
        if(report == 'Event' && isExport == false){
            qry += ' AND Question_Set__c = null';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> postPosNpsData(String proj, String dateRange, String team, String year, String month){
        
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Post Possession Handover\'';
            }
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        qry += ' AND NPS__c != null';
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> salesExpData(String team, String dateRange, String year, String month, String report, Boolean isExport){
        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Sales Experience\'';
        }else{
            qry = eventReportQueryBuilder(team, dateRange);
            if((team != null && team != '') || (dateRange != null && dateRange != '')){
                qry += ' AND Feedback_Type__c = \'Sales Experience\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Sales Experience\'';
            }
        }
        if(report == 'Event' && isExport == false){
            qry += ' AND Question_Set__c = null';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    /*@auraEnabled
public static List<WhatsApp_Feedback__c> salesExpDataExport(String team, String dateRange, String year, String month){

String qry;
if(year != null && year != '' && month != null && month != ''){
qry = yearMonthQueryBuilder(team, year, month);
qry += ' AND Feedback_Type__c = \'Sales Experience\'';
}else{
qry = eventReportQueryBuilder(team, dateRange);
if((team != null && team != '') || (dateRange != null && dateRange != '')){
qry += ' AND Feedback_Type__c = \'Sales Experience\'';
}else{
qry += ' WHERE Feedback_Type__c = \'Sales Experience\'';
}
}
List<WhatsApp_Feedback__c> fbList = Database.query(qry);
return fbList;
}*/
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> salesExpNpsData(String proj, String dateRange, String team, String year, String month){
        
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Sales Experience\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Sales Experience\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Sales Experience\'';
            }
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        qry += ' AND NPS__c != null';
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> caseClosureData(String proj, String dateRange, String team, String year, String month){
        
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Case Closure\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Case Closure\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Case Closure\'';
            }
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj ';
        }
        qry += ' AND NPS__c != null';
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> callDispData(String proj, String dateRange, String team, String year, String month){
        
        String qry;
        String teamQry = teamQuery(team);
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Call Disposition\'';
        }else{
            qry = exportQry('', dateRange);
            System.debug('team: ' + team);
            System.debug('teamQry: ' + teamQry);
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                qry += ' AND Feedback_Type__c = \'Call Disposition\'';
            }else{
                qry += ' WHERE Feedback_Type__c = \'Call Disposition\'';
            }
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj ';
        }
        qry += ' AND NPS__c != null';
        system.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> endOfBotData(String proj, String dateRange, String team){
        String qry = eventReportQueryBuilder('', dateRange);
        String teamQry = teamQuery(team);
        if(dateRange != null && dateRange != ''){
            qry += ' AND Feedback_Type__c = \'End of Bot conversation\'';
        }else{
            qry += ' WHERE Feedback_Type__c = \'End of Bot conversation\'';
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj ';
        }
        qry += ' AND NPS__c != null';
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @AuraEnabled
    public static List<NPSData> npsReport(String userTeam, String dateRange, String year, String month){
        
        String team = userTeam.split(':')[0];
        String team2 = userTeam.split(':')[1];
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        if(year != null && year != '' && month != null && month != ''){
            String qry = yearMonthQueryBuilder(team, year, month);
            fbList = Database.query(qry);
        }else{
            fbList = Database.query(eventReportQueryBuilder(team, dateRange));
        }
        System.debug('fbList size: ' + fbList.size());
        if(fbList.size() == 0){
            return null;
        }
        Map<String, List<WhatsApp_Feedback__c>> projVsFbList = new Map<String, List<WhatsApp_Feedback__c>>();
        projVsFbList.put('All Projects',new List<WhatsApp_Feedback__c>{});
        for(WhatsApp_Feedback__c fb : fbList){
            if(team2 == 'All'){
                if(fb.Feedback_Type__c == 'Day of Possession Handover' || fb.Feedback_Type__c == 'Day of Registration' || fb.Feedback_Type__c == 'Post Possession Handover' || fb.Feedback_Type__c == 'Sales Experience'){
                    if(!projVsFbList.keySet().contains(fb.Project__c)){
                        projVsFbList.put(fb.Project__c, new List<WhatsApp_Feedback__c>{fb});
                    }else{
                        projVsFbList.get(fb.Project__c).add(fb);
                    }
                    projVsFbList.get('All Projects').add(fb);
                }
            }else if(team2 == 'CRM'){
                if(fb.Feedback_Type__c == 'Day of Possession Handover' || fb.Feedback_Type__c == 'Day of Registration' || fb.Feedback_Type__c == 'Post Possession Handover'){
                    if(!projVsFbList.keySet().contains(fb.Project__c)){
                        projVsFbList.put(fb.Project__c, new List<WhatsApp_Feedback__c>{fb});
                    }else{
                        projVsFbList.get(fb.Project__c).add(fb);
                    }
                    projVsFbList.get('All Projects').add(fb);
                }
            }else if(team2 == 'Sales'){
                if(fb.Feedback_Type__c == 'Sales Experience'){
                    if(!projVsFbList.keySet().contains(fb.Project__c)){
                        projVsFbList.put(fb.Project__c, new List<WhatsApp_Feedback__c>{fb});
                    }else{
                        projVsFbList.get(fb.Project__c).add(fb);
                    }
                    projVsFbList.get('All Projects').add(fb);
                }
            }
            /*if(fb.Feedback_Type__c == 'Day of Possession Handover' || fb.Feedback_Type__c == 'Day of Registration' || fb.Feedback_Type__c == 'Post Possession Handover'){
if(!projVsFbList.keySet().contains(fb.Project__c)){
projVsFbList.put(fb.Project__c, new List<WhatsApp_Feedback__c>{fb});
}else{
projVsFbList.get(fb.Project__c).add(fb);
}
projVsFbList.get('All Projects').add(fb);
}*/
            
        }
        List<String> projList = new List<String>(projVsFbList.keySet());
        List<String> orderedProjList = new List<String>();
        projList.sort();
        projList.remove(projList.indexOf('All Projects'));
        orderedProjList.add('All Projects');
        orderedProjList.addAll(projList);
        System.debug('orderedProjList: ' + orderedProjList);
        List<NPSData> NPSDataList = new List<NPSData>();
        for(String proj : orderedProjList){
            NPSData dt = new NPSData();
            dt.project = proj;
            Map<String,List<WhatsApp_Feedback__c>> fbTypeVsFbList = new Map<String,List<WhatsApp_Feedback__c>>();
            /*fbTypeVsFbList.put('Day of Possession Handover', new List<WhatsApp_Feedback__c>{});
fbTypeVsFbList.put('Day of Registration', new List<WhatsApp_Feedback__c>{});
fbTypeVsFbList.put('Post Possession Handover', new List<WhatsApp_Feedback__c>{});*/
            if(team2 == 'All'){
                fbTypeVsFbList.put('Sales Experience', new List<WhatsApp_Feedback__c>{});
                fbTypeVsFbList.put('Day of Registration', new List<WhatsApp_Feedback__c>{});
                fbTypeVsFbList.put('Day of Possession Handover', new List<WhatsApp_Feedback__c>{});
                fbTypeVsFbList.put('Post Possession Handover', new List<WhatsApp_Feedback__c>{});
            }else if(team2 == 'CRM'){
                fbTypeVsFbList.put('Day of Registration', new List<WhatsApp_Feedback__c>{});
                fbTypeVsFbList.put('Day of Possession Handover', new List<WhatsApp_Feedback__c>{});
                fbTypeVsFbList.put('Post Possession Handover', new List<WhatsApp_Feedback__c>{});
            }else if(team2 == 'Sales'){
                fbTypeVsFbList.put('Sales Experience', new List<WhatsApp_Feedback__c>{});
            }
            for(WhatsApp_Feedback__c fb : projVsFbList.get(proj)){
                fbTypeVsFbList.get(fb.Feedback_Type__c).add(fb);
            }
            List<fbTypeNps> fbTypeNpsList = new List<fbTypeNps>();
            fbTypeNpsTotals totals = new fbTypeNpsTotals();
            List<String> fbTypeList = new List<String>(fbTypeVsFbList.keySet());
            //fbTypeList.sort();
            for(String fbType : fbTypeList){
                fbTypeNps nps = new fbTypeNps();
                nps.fbType = fbType;
                for(WhatsApp_Feedback__c f : fbTypeVsFbList.get(fbType)){
                    if(f.NPS__c == '10'){
                        if(nps.nps_10 == null){
                            nps.nps_10 = 1;
                        }else{
                            nps.nps_10 += 1;
                        }
                    }
                    if(f.NPS__c == '09'){
                        if(nps.nps_9 == null){
                            nps.nps_9 = 1;
                        }else{
                            nps.nps_9 += 1;
                        }
                    }
                    if(f.NPS__c == '08'){
                        if(nps.nps_8 == null){
                            nps.nps_8 = 1;
                        }else{
                            nps.nps_8 += 1;
                        }
                    }
                    if(f.NPS__c == '07'){
                        if(nps.nps_7 == null){
                            nps.nps_7 = 1;
                        }else{
                            nps.nps_7 += 1;
                        }
                    }
                    if(f.NPS__c == '06'){
                        if(nps.nps_6 == null){
                            nps.nps_6 = 1;
                        }else{
                            nps.nps_6 += 1;
                        }
                    }
                    if(f.NPS__c == '05'){
                        if(nps.nps_5 == null){
                            nps.nps_5 = 1;
                        }else{
                            nps.nps_5 += 1;
                        }
                    }
                    if(f.NPS__c == '04'){
                        if(nps.nps_4 == null){
                            nps.nps_4 = 1;
                        }else{
                            nps.nps_4 += 1;
                        }
                    }
                    if(f.NPS__c == '03'){
                        if(nps.nps_3 == null){
                            nps.nps_3 = 1;
                        }else{
                            nps.nps_3 += 1;
                        }
                    }
                    if(f.NPS__c == '02'){
                        if(nps.nps_2 == null){
                            nps.nps_2 = 1;
                        }else{
                            nps.nps_2 += 1;
                        }
                    }
                    if(f.NPS__c == '01'){
                        if(nps.nps_1 == null){
                            nps.nps_1 = 1;
                        }else{
                            nps.nps_1 += 1;
                        }
                    }
                }
                Decimal nps1 = (nps.nps_1 != null) ? nps.nps_1 : 0;
                Decimal nps2 = (nps.nps_2 != null) ? nps.nps_2 : 0;
                Decimal nps3 = (nps.nps_3 != null) ? nps.nps_3 : 0;
                Decimal nps4 = (nps.nps_4 != null) ? nps.nps_4 : 0;
                Decimal nps5 = (nps.nps_5 != null) ? nps.nps_5 : 0;
                Decimal nps6 = (nps.nps_6 != null) ? nps.nps_6 : 0;
                Decimal nps7 = (nps.nps_7 != null) ? nps.nps_7 : 0;
                Decimal nps8 = (nps.nps_8 != null) ? nps.nps_8 : 0;
                Decimal nps9 = (nps.nps_9 != null) ? nps.nps_9 : 0;
                Decimal nps10 = (nps.nps_10 != null) ? nps.nps_10 : 0;
                Decimal nps_total = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
                nps.nps_T = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
                System.debug('nps.nps_T: ' + nps.nps_T);
                System.debug('nps10: ' + nps10);
                System.debug('nps9: ' + nps9);
                System.debug('nps_total: ' + nps_total);
                if(nps.nps_T != 0 && nps.nps_T != null){
                    nps.promoters_per = ((nps10 + nps9) != 0) ? ((nps10 + nps9)/nps.nps_T) * 100 : 0;
                    nps.promoters_per = nps.promoters_per.setscale(0,RoundingMode.HALF_UP);
                    nps.passives_per = ((nps8 + nps7) != 0) ? ((nps8 + nps7)/nps.nps_T) * 100 : 0;
                    nps.passives_per = nps.passives_per.setscale(0,RoundingMode.HALF_UP);
                    nps.detractors_per = ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1) != 0) ? ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1)/nps.nps_T) * 100 : 0;
                    nps.detractors_per = nps.detractors_per.setscale(0,RoundingMode.HALF_UP);
                    nps.nps_score = nps.promoters_per - nps.detractors_per;
                }
                fbTypeNpsList.add(nps);
            }
            dt.fbNps = fbTypeNpsList;
            Decimal nps1_T = 0;
            Decimal nps2_T = 0;
            Decimal nps3_T = 0;
            Decimal nps4_T = 0;
            Decimal nps5_T = 0;
            Decimal nps6_T = 0;
            Decimal nps7_T = 0;
            Decimal nps8_T = 0;
            Decimal nps9_T = 0;
            Decimal nps10_T = 0;
            Decimal promotersPer_T = 0;
            Decimal passivesPer_T = 0;
            Decimal detractorsPer_T = 0;
            Decimal npsT_T = 0;
            Decimal npsScore_T = 0;
            for(fbTypeNps fbNps : fbTypeNpsList){
                nps1_T = ((fbNps.nps_1 != null)? fbNps.nps_1 : 0) + nps1_T;
                nps2_T = ((fbNps.nps_2 != null)? fbNps.nps_2 : 0) + nps2_T;
                nps3_T = ((fbNps.nps_3 != null)? fbNps.nps_3 : 0) + nps3_T;
                nps4_T = ((fbNps.nps_4 != null)? fbNps.nps_4 : 0) + nps4_T;
                nps5_T = ((fbNps.nps_5 != null)? fbNps.nps_5 : 0) + nps5_T;
                nps6_T = ((fbNps.nps_6 != null)? fbNps.nps_6 : 0) + nps6_T;
                nps7_T = ((fbNps.nps_7 != null)? fbNps.nps_7 : 0) + nps7_T;
                nps8_T = ((fbNps.nps_8 != null)? fbNps.nps_8 : 0) + nps8_T;
                nps9_T = ((fbNps.nps_9 != null)? fbNps.nps_9 : 0) + nps9_T;
                nps10_T = ((fbNps.nps_10 != null)? fbNps.nps_10 : 0) + nps10_T;
                npsT_T = ((fbNps.nps_T != null)? fbNps.nps_T : 0) + npsT_T;
            }
            totals.nps_1_T = nps1_T;
            totals.nps_2_T = nps2_T;
            totals.nps_3_T = nps3_T;
            totals.nps_4_T = nps4_T;
            totals.nps_5_T = nps5_T;
            totals.nps_6_T = nps6_T;
            totals.nps_7_T = nps7_T;
            totals.nps_8_T = nps8_T;
            totals.nps_9_T = nps9_T;
            totals.nps_10_T = nps10_T;
            totals.nps_T_T = npsT_T;
            if(npsT_T != 0 && npsT_T != null){
                totals.promoters_per_T = ((nps10_T + nps9_T) != 0) ? ((nps10_T + nps9_T)/npsT_T) * 100 : 0;
                totals.promoters_per_T = totals.promoters_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.passives_per_T = ((nps8_T + nps7_T) != 0) ? ((nps8_T + nps7_T)/npsT_T) * 100 : 0;
                totals.passives_per_T = totals.passives_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.detractors_per_T = ((nps6_T + nps5_T + nps4_T + nps3_T + nps2_T + nps1_T) != 0) ? ((nps6_T + nps5_T + nps4_T + nps3_T + nps2_T + nps1_T)/npsT_T) * 100 : 0;
                totals.detractors_per_T = totals.detractors_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.nps_score_T = totals.promoters_per_T - totals.detractors_per_T;
            }
            dt.fbNpsTotals = totals;
            NPSDataList.add(dt);
        }
        System.debug('NPSDataList: ' + NPSDataList);
        return NPSDataList;
    }
    
    @AuraEnabled
    public static List<NPSData> customerInsightsReport(String team, String dateRange, String year, String month){
        System.debug('year: ' + year);
        System.debug('month: ' + month);
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        if(year != null && year != '' && month != null && month != ''){
            String qry = yearMonthQueryBuilder(team, year, month);
            System.debug('qry: ' + qry);
            fbList = Database.query(qry);
        }else{
            fbList = Database.query(eventReportQueryBuilder(team, dateRange));
        }
        System.debug('fbList size: ' + fbList.size());
        if(fbList.size() == 0){
            return null;
        }
        Map<String, List<WhatsApp_Feedback__c>> projVsFbList = new Map<String, List<WhatsApp_Feedback__c>>();
        projVsFbList.put('All Projects',new List<WhatsApp_Feedback__c>{});
        for(WhatsApp_Feedback__c fb : fbList){
            if(fb.Feedback_Type__c == 'Case Closure' || fb.Feedback_Type__c == 'Call Disposition'){
                if(!projVsFbList.keySet().contains(fb.Project__c)){
                    projVsFbList.put(fb.Project__c, new List<WhatsApp_Feedback__c>{fb});
                }else{
                    projVsFbList.get(fb.Project__c).add(fb);
                }
                projVsFbList.get('All Projects').add(fb);
            }
        }
        List<String> projList = new List<String>(projVsFbList.keySet());
        List<String> orderedProjList = new List<String>();
        projList.sort();
        projList.remove(projList.indexOf('All Projects'));
        orderedProjList.add('All Projects');
        orderedProjList.addAll(projList);
        System.debug('orderedProjList: ' + orderedProjList);
        List<NPSData> NPSDataList = new List<NPSData>();
        for(String proj : orderedProjList){
            NPSData dt = new NPSData();
            dt.project = proj;
            Map<String,List<WhatsApp_Feedback__c>> fbTypeVsFbList = new Map<String,List<WhatsApp_Feedback__c>>();
            fbTypeVsFbList.put('Case Closure', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Call Disposition', new List<WhatsApp_Feedback__c>{});
            
            for(WhatsApp_Feedback__c fb : projVsFbList.get(proj)){
                fbTypeVsFbList.get(fb.Feedback_Type__c).add(fb);
            }
            List<fbTypeNps> fbTypeNpsList = new List<fbTypeNps>();
            fbTypeNpsTotals totals = new fbTypeNpsTotals();
            List<String> fbTypeList = new List<String>(fbTypeVsFbList.keySet());
            fbTypeList.sort();
            for(String fbType : fbTypeList){
                fbTypeNps nps = new fbTypeNps();
                nps.fbType = fbType;
                for(WhatsApp_Feedback__c f : fbTypeVsFbList.get(fbType)){
                    if(f.NPS__c == '10'){
                        if(nps.nps_10 == null){
                            nps.nps_10 = 1;
                        }else{
                            nps.nps_10 += 1;
                        }
                    }
                    if(f.NPS__c == '09'){
                        if(nps.nps_9 == null){
                            nps.nps_9 = 1;
                        }else{
                            nps.nps_9 += 1;
                        }
                    }
                    if(f.NPS__c == '08'){
                        if(nps.nps_8 == null){
                            nps.nps_8 = 1;
                        }else{
                            nps.nps_8 += 1;
                        }
                    }
                    if(f.NPS__c == '07'){
                        if(nps.nps_7 == null){
                            nps.nps_7 = 1;
                        }else{
                            nps.nps_7 += 1;
                        }
                    }
                    if(f.NPS__c == '06'){
                        if(nps.nps_6 == null){
                            nps.nps_6 = 1;
                        }else{
                            nps.nps_6 += 1;
                        }
                    }
                    if(f.NPS__c == '05'){
                        if(nps.nps_5 == null){
                            nps.nps_5 = 1;
                        }else{
                            nps.nps_5 += 1;
                        }
                    }
                    if(f.NPS__c == '04'){
                        if(nps.nps_4 == null){
                            nps.nps_4 = 1;
                        }else{
                            nps.nps_4 += 1;
                        }
                    }
                    if(f.NPS__c == '03'){
                        if(nps.nps_3 == null){
                            nps.nps_3 = 1;
                        }else{
                            nps.nps_3 += 1;
                        }
                    }
                    if(f.NPS__c == '02'){
                        if(nps.nps_2 == null){
                            nps.nps_2 = 1;
                        }else{
                            nps.nps_2 += 1;
                        }
                    }
                    if(f.NPS__c == '01'){
                        if(nps.nps_1 == null){
                            nps.nps_1 = 1;
                        }else{
                            nps.nps_1 += 1;
                        }
                    }
                }
                Decimal nps1 = (nps.nps_1 != null) ? nps.nps_1 : 0;
                Decimal nps2 = (nps.nps_2 != null) ? nps.nps_2 : 0;
                Decimal nps3 = (nps.nps_3 != null) ? nps.nps_3 : 0;
                Decimal nps4 = (nps.nps_4 != null) ? nps.nps_4 : 0;
                Decimal nps5 = (nps.nps_5 != null) ? nps.nps_5 : 0;
                Decimal nps6 = (nps.nps_6 != null) ? nps.nps_6 : 0;
                Decimal nps7 = (nps.nps_7 != null) ? nps.nps_7 : 0;
                Decimal nps8 = (nps.nps_8 != null) ? nps.nps_8 : 0;
                Decimal nps9 = (nps.nps_9 != null) ? nps.nps_9 : 0;
                Decimal nps10 = (nps.nps_10 != null) ? nps.nps_10 : 0;
                Decimal nps_total = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
                nps.nps_T = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
                System.debug('nps.nps_T: ' + nps.nps_T);
                System.debug('nps10: ' + nps10);
                System.debug('nps9: ' + nps9);
                System.debug('nps_total: ' + nps_total);
                if(nps.nps_T != 0 && nps.nps_T != null){
                    nps.promoters_per = ((nps10 + nps9) != 0) ? ((nps10 + nps9)/nps.nps_T) * 100 : 0;
                    nps.promoters_per = nps.promoters_per.setscale(0,RoundingMode.HALF_UP);
                    nps.passives_per = ((nps8 + nps7) != 0) ? ((nps8 + nps7)/nps.nps_T) * 100 : 0;
                    nps.passives_per = nps.passives_per.setscale(0,RoundingMode.HALF_UP);
                    nps.detractors_per = ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1) != 0) ? ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1)/nps.nps_T) * 100 : 0;
                    nps.detractors_per = nps.detractors_per.setscale(0,RoundingMode.HALF_UP);
                    nps.nps_score = nps.promoters_per - nps.detractors_per;
                }
                fbTypeNpsList.add(nps);
            }
            dt.fbNps = fbTypeNpsList;
            System.debug('dt: ' + dt);
            Decimal nps1_T = 0;
            Decimal nps2_T = 0;
            Decimal nps3_T = 0;
            Decimal nps4_T = 0;
            Decimal nps5_T = 0;
            Decimal nps6_T = 0;
            Decimal nps7_T = 0;
            Decimal nps8_T = 0;
            Decimal nps9_T = 0;
            Decimal nps10_T = 0;
            Decimal promotersPer_T = 0;
            Decimal passivesPer_T = 0;
            Decimal detractorsPer_T = 0;
            Decimal npsT_T = 0;
            Decimal npsScore_T = 0;
            for(fbTypeNps fbNps : fbTypeNpsList){
                nps1_T = ((fbNps.nps_1 != null)? fbNps.nps_1 : 0) + nps1_T;
                nps2_T = ((fbNps.nps_2 != null)? fbNps.nps_2 : 0) + nps2_T;
                nps3_T = ((fbNps.nps_3 != null)? fbNps.nps_3 : 0) + nps3_T;
                nps4_T = ((fbNps.nps_4 != null)? fbNps.nps_4 : 0) + nps4_T;
                nps5_T = ((fbNps.nps_5 != null)? fbNps.nps_5 : 0) + nps5_T;
                nps6_T = ((fbNps.nps_6 != null)? fbNps.nps_6 : 0) + nps6_T;
                nps7_T = ((fbNps.nps_7 != null)? fbNps.nps_7 : 0) + nps7_T;
                nps8_T = ((fbNps.nps_8 != null)? fbNps.nps_8 : 0) + nps8_T;
                nps9_T = ((fbNps.nps_9 != null)? fbNps.nps_9 : 0) + nps9_T;
                nps10_T = ((fbNps.nps_10 != null)? fbNps.nps_10 : 0) + nps10_T;
                npsT_T = ((fbNps.nps_T != null)? fbNps.nps_T : 0) + npsT_T;
            }
            totals.nps_1_T = nps1_T;
            totals.nps_2_T = nps2_T;
            totals.nps_3_T = nps3_T;
            totals.nps_4_T = nps4_T;
            totals.nps_5_T = nps5_T;
            totals.nps_6_T = nps6_T;
            totals.nps_7_T = nps7_T;
            totals.nps_8_T = nps8_T;
            totals.nps_9_T = nps9_T;
            totals.nps_10_T = nps10_T;
            totals.nps_T_T = npsT_T;
            if(npsT_T != 0 && npsT_T != null){
                totals.promoters_per_T = ((nps10_T + nps9_T) != 0) ? ((nps10_T + nps9_T)/npsT_T) * 100 : 0;
                totals.promoters_per_T = totals.promoters_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.passives_per_T = ((nps8_T + nps7_T) != 0) ? ((nps8_T + nps7_T)/npsT_T) * 100 : 0;
                totals.passives_per_T = totals.passives_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.detractors_per_T = ((nps6_T + nps5_T + nps4_T + nps3_T + nps2_T + nps1_T) != 0) ? ((nps6_T + nps5_T + nps4_T + nps3_T + nps2_T + nps1_T)/npsT_T) * 100 : 0;
                totals.detractors_per_T = totals.detractors_per_T.setscale(0,RoundingMode.HALF_UP);
                totals.nps_score_T = totals.promoters_per_T - totals.detractors_per_T;
            }
            dt.fbNpsTotals = totals;
            NPSDataList.add(dt);
        }
        System.debug('NPSDataList: ' + NPSDataList);
        return NPSDataList;
    }
    
    @AuraEnabled
    public static Map<String, Integer> campaignReport(String camp){
        Map<String, Integer> detailedMap = new Map<String, Integer>();
        
        List<WhatsApp_Feedback__c> campFBs = [SELECT Id, Name, Camp_Question_1__c, Camp_Question_2__c, Camp_Question_3__c, Camp_Question_4__c, Camp_Question_5__c, Camp_Question_6__c, Camp_Question_7__c, Camp_Question_8__c, Camp_Question_9__c, Camp_Question_10__c, Camp_Question_11__c, Camp_Question_12__c, Camp_Question_13__c, Camp_Question_14__c, Camp_Question_15__c, Camp_Question_16__c, Camp_Question_17__c, Camp_Question_18__c, Camp_Question_19__c, Camp_Question_20__c, 
                                              Camp_Answer_1__c, Camp_Answer_2__c, Camp_Answer_3__c, Camp_Answer_4__c, Camp_Answer_5__c, Camp_Answer_6__c, Camp_Answer_7__c, Camp_Answer_8__c, Camp_Answer_9__c, Camp_Answer_10__c, Camp_Answer_11__c, Camp_Answer_12__c, Camp_Answer_13__c, Camp_Answer_14__c, Camp_Answer_15__c, Camp_Answer_16__c, Camp_Answer_17__c, Camp_Answer_18__c, Camp_Answer_19__c, Camp_Answer_20__c, 
                                              Campaign_Name__c, NPS__c, Feedback_Type__c, Opportunity__c, Project__c, CRN__c FROM WhatsApp_Feedback__c WHERE Campaign_Name__c =: camp];
        Map<String, Integer> countMap = new Map<String, Integer>();
        countMap.put('Excellent',0);
        countMap.put('Very Good',0);
        countMap.put('Good',0);
        countMap.put('Bad',0);
        for(WhatsApp_Feedback__c fb : campFBs){
            if(countMap.keySet().contains(fb.Camp_Answer_1__c)){
                countMap.put(fb.Camp_Answer_1__c, countMap.get(fb.Camp_Answer_1__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_2__c)){
                countMap.put(fb.Camp_Answer_2__c, countMap.get(fb.Camp_Answer_2__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_3__c)){
                countMap.put(fb.Camp_Answer_3__c, countMap.get(fb.Camp_Answer_3__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_4__c)){
                countMap.put(fb.Camp_Answer_4__c, countMap.get(fb.Camp_Answer_4__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_5__c)){
                countMap.put(fb.Camp_Answer_5__c, countMap.get(fb.Camp_Answer_5__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_6__c)){
                countMap.put(fb.Camp_Answer_6__c, countMap.get(fb.Camp_Answer_6__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_7__c)){
                countMap.put(fb.Camp_Answer_7__c, countMap.get(fb.Camp_Answer_7__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_8__c)){
                countMap.put(fb.Camp_Answer_8__c, countMap.get(fb.Camp_Answer_8__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_9__c)){
                countMap.put(fb.Camp_Answer_9__c, countMap.get(fb.Camp_Answer_9__c)+1);
            }
            if(countMap.keySet().contains(fb.Camp_Answer_10__c)){
                countMap.put(fb.Camp_Answer_10__c, countMap.get(fb.Camp_Answer_10__c)+1);
            }
        }
        Integer veryGoodCount = countMap.get('Very Good');
        countMap.put('Very_Good', veryGoodCount);
        return countMap;
    }
    
    @AuraEnabled
    public static List<eventData> campaignRecDetails(String camp, String eventType){
        
        List<WhatsApp_Feedback__c> fbList  = [SELECT Id, Name, Camp_Question_1__c, Camp_Question_2__c, Camp_Question_3__c, Camp_Question_4__c, Camp_Question_5__c, Camp_Question_6__c, Camp_Question_7__c, Camp_Question_8__c, Camp_Question_9__c, Camp_Question_10__c, Camp_Question_11__c, Camp_Question_12__c, Camp_Question_13__c, Camp_Question_14__c, Camp_Question_15__c, Camp_Question_16__c, Camp_Question_17__c, Camp_Question_18__c, Camp_Question_19__c, Camp_Question_20__c, 
                                              Camp_Answer_1__c, Camp_Answer_2__c, Camp_Answer_3__c, Camp_Answer_4__c, Camp_Answer_5__c, Camp_Answer_6__c, Camp_Answer_7__c, Camp_Answer_8__c, Camp_Answer_9__c, Camp_Answer_10__c, Camp_Answer_11__c, Camp_Answer_12__c, Camp_Answer_13__c, Camp_Answer_14__c, Camp_Answer_15__c, Camp_Answer_16__c, Camp_Answer_17__c, Camp_Answer_18__c, Camp_Answer_19__c, Camp_Answer_20__c, 
                                              Campaign_Name__c, NPS__c, Feedback_Type__c, Opportunity__c, Opportunity__r.Name, Project__c, CRN__c FROM WhatsApp_Feedback__c 
                                              WHERE Campaign_Name__c =: camp];
        List<eventData> dataList = new List<eventData>();
        Integer count = 0;
        for(WhatsApp_Feedback__c fb : fbList){
            eventData dt = new eventData();
            dt.recId = fb.Id;
            dt.name = fb.Name;
            dt.crn = fb.CRN__c;
            dt.project = fb.Project__c;
            dt.feedbackType = fb.Feedback_Type__c;
            dt.customer = fb.Opportunity__r.Name;
            dt.oppId = fb.Opportunity__c;
            List<String> questions = new List<String>();
            if(fb.Camp_Answer_1__c == eventType){
                questions.add(fb.Camp_Question_1__c);
            }
            if(fb.Camp_Answer_2__c == eventType){
                questions.add(fb.Camp_Question_2__c);
            }
            if(fb.Camp_Answer_3__c == eventType){
                questions.add(fb.Camp_Question_3__c);
            }
            if(fb.Camp_Answer_4__c == eventType){
                questions.add(fb.Camp_Question_4__c);
            }
            if(fb.Camp_Answer_5__c == eventType){
                questions.add(fb.Camp_Question_5__c);
            }
            if(fb.Camp_Answer_6__c == eventType){
                questions.add(fb.Camp_Question_6__c);
            }
            if(fb.Camp_Answer_7__c == eventType){
                questions.add(fb.Camp_Answer_7__c);
            }
            if(fb.Camp_Answer_8__c == eventType){
                questions.add(fb.Camp_Question_8__c);
            }
            if(fb.Camp_Answer_9__c == eventType){
                questions.add(fb.Camp_Question_9__c);
            }
            if(fb.Camp_Answer_10__c == eventType){
                questions.add(fb.Camp_Question_10__c);
            }
            if(fb.Camp_Answer_11__c == eventType){
                questions.add(fb.Camp_Question_11__c);
            }
            if(fb.Camp_Answer_12__c == eventType){
                questions.add(fb.Camp_Question_12__c);
            }
            if(fb.Camp_Answer_13__c == eventType){
                questions.add(fb.Camp_Question_13__c);
            }
            if(fb.Camp_Answer_14__c == eventType){
                questions.add(fb.Camp_Question_14__c);
            }
            if(fb.Camp_Answer_15__c == eventType){
                questions.add(fb.Camp_Question_15__c);
            }
            if(fb.Camp_Answer_16__c == eventType){
                questions.add(fb.Camp_Question_16__c);
            }
            if(fb.Camp_Answer_17__c == eventType){
                questions.add(fb.Camp_Question_17__c);
            }
            if(fb.Camp_Answer_18__c == eventType){
                questions.add(fb.Camp_Question_18__c);
            }
            if(fb.Camp_Answer_19__c == eventType){
                questions.add(fb.Camp_Question_19__c);
            }
            if(fb.Camp_Answer_20__c == eventType){
                questions.add(fb.Camp_Question_20__c);
            }
            if(questions.size() > 0){
                count += 1;
                dt.questions = questions;
                dataList.add(dt);
            }
        }
        if(count > 0){
            return dataList;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static fbTypeNps campaignNPS(String camp){
        
        if(camp == null || camp == ''){
            return null;
        }
        fbTypeNps nps = new fbTypeNps();
        List<WhatsApp_Feedback__c> fbList  = [SELECT Id, Name, Camp_Question_1__c, Camp_Question_2__c, Camp_Question_3__c, Camp_Question_4__c, Camp_Question_5__c, Camp_Question_6__c, Camp_Question_7__c, Camp_Question_8__c, Camp_Question_9__c, Camp_Question_10__c, Camp_Question_11__c, Camp_Question_12__c, Camp_Question_13__c, Camp_Question_14__c, Camp_Question_15__c, Camp_Question_16__c, Camp_Question_17__c, Camp_Question_18__c, Camp_Question_19__c, Camp_Question_20__c, 
                                              Camp_Answer_1__c, Camp_Answer_2__c, Camp_Answer_3__c, Camp_Answer_4__c, Camp_Answer_5__c, Camp_Answer_6__c, Camp_Answer_7__c, Camp_Answer_8__c, Camp_Answer_9__c, Camp_Answer_10__c, Camp_Answer_11__c, Camp_Answer_12__c, Camp_Answer_13__c, Camp_Answer_14__c, Camp_Answer_15__c, Camp_Answer_16__c, Camp_Answer_17__c, Camp_Answer_18__c, Camp_Answer_19__c, Camp_Answer_20__c, 
                                              Campaign_Name__c, NPS__c, Feedback_Type__c, Opportunity__c, Opportunity__r.Name, Project__c, CRN__c FROM WhatsApp_Feedback__c 
                                              WHERE Campaign_Name__c =: camp];
        if(fbList.size() == 0){
            return null;
        }
        nps.fbType = camp;
        for(WhatsApp_Feedback__c f : fbList){
            if(f.NPS__c == '10'){
                if(nps.nps_10 == null){
                    nps.nps_10 = 1;
                }else{
                    nps.nps_10 += 1;
                }
            }
            if(f.NPS__c == '09'){
                if(nps.nps_9 == null){
                    nps.nps_9 = 1;
                }else{
                    nps.nps_9 += 1;
                }
            }
            if(f.NPS__c == '08'){
                if(nps.nps_8 == null){
                    nps.nps_8 = 1;
                }else{
                    nps.nps_8 += 1;
                }
            }
            if(f.NPS__c == '07'){
                if(nps.nps_7 == null){
                    nps.nps_7 = 1;
                }else{
                    nps.nps_7 += 1;
                }
            }
            if(f.NPS__c == '06'){
                if(nps.nps_6 == null){
                    nps.nps_6 = 1;
                }else{
                    nps.nps_6 += 1;
                }
            }
            if(f.NPS__c == '05'){
                if(nps.nps_5 == null){
                    nps.nps_5 = 1;
                }else{
                    nps.nps_5 += 1;
                }
            }
            if(f.NPS__c == '04'){
                if(nps.nps_4 == null){
                    nps.nps_4 = 1;
                }else{
                    nps.nps_4 += 1;
                }
            }
            if(f.NPS__c == '03'){
                if(nps.nps_3 == null){
                    nps.nps_3 = 1;
                }else{
                    nps.nps_3 += 1;
                }
            }
            if(f.NPS__c == '02'){
                if(nps.nps_2 == null){
                    nps.nps_2 = 1;
                }else{
                    nps.nps_2 += 1;
                }
            }
            if(f.NPS__c == '01'){
                if(nps.nps_1 == null){
                    nps.nps_1 = 1;
                }else{
                    nps.nps_1 += 1;
                }
            }
            
            Decimal nps1 = (nps.nps_1 != null) ? nps.nps_1 : 0;
            Decimal nps2 = (nps.nps_2 != null) ? nps.nps_2 : 0;
            Decimal nps3 = (nps.nps_3 != null) ? nps.nps_3 : 0;
            Decimal nps4 = (nps.nps_4 != null) ? nps.nps_4 : 0;
            Decimal nps5 = (nps.nps_5 != null) ? nps.nps_5 : 0;
            Decimal nps6 = (nps.nps_6 != null) ? nps.nps_6 : 0;
            Decimal nps7 = (nps.nps_7 != null) ? nps.nps_7 : 0;
            Decimal nps8 = (nps.nps_8 != null) ? nps.nps_8 : 0;
            Decimal nps9 = (nps.nps_9 != null) ? nps.nps_9 : 0;
            Decimal nps10 = (nps.nps_10 != null) ? nps.nps_10 : 0;
            Decimal nps_total = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
            nps.nps_T = nps1 + nps2 + nps3 + nps4 + nps5 + nps6 + nps7 + nps8 + nps9 + nps10;
            if(nps.nps_T != 0 && nps.nps_T != null){
                nps.promoters_per = ((nps10 + nps9) != 0) ? ((nps10 + nps9)/nps.nps_T) * 100 : 0;
                nps.promoters_per = nps.promoters_per.setscale(0,RoundingMode.HALF_UP);
                nps.passives_per = ((nps8 + nps7) != 0) ? ((nps8 + nps7)/nps.nps_T) * 100 : 0;
                nps.passives_per = nps.passives_per.setscale(0,RoundingMode.HALF_UP);
                nps.detractors_per = ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1) != 0) ? ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1)/nps.nps_T) * 100 : 0;
                nps.detractors_per = nps.detractors_per.setscale(0,RoundingMode.HALF_UP);
                nps.nps_score = nps.promoters_per - nps.detractors_per;
            }
        }
        return nps;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> campNpsRecordDetails(String fbType){
        
        String camp;
        String npsValue;
        
        if(fbType != null){
            List<String> fbTypeSplit = fbType.split('_');
            camp = fbTypeSplit[0];
            npsValue = fbTypeSplit[1];
        }
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Campaign_Name__c =: camp';
        if(npsValue == 'promoters'){
            qry += ' AND (NPS__c = \'10\' OR NPS__c = \'09\')';
        }else if(npsValue == 'passives'){
            qry += ' AND (NPS__c = \'08\' OR NPS__c = \'07\')';
        }else if(npsValue == 'detractors'){
            qry += ' AND (NPS__c = \'06\' OR NPS__c = \'05\' OR NPS__c = \'04\' OR NPS__c = \'03\' OR NPS__c = \'02\' OR NPS__c = \'01\')';
        }else{
            qry += ' AND NPS__c =: npsValue';
        }
        List<WhatsApp_Feedback__c> feedbacks = Database.query(qry);
        return feedbacks;
    }
    
    public static string exportQry(String team, String dateRange){
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Opportunity__c, Feedback_Type__c, Opportunity_Name__c FROM WhatsApp_Feedback__c';
        String teamQry = teamQuery(team);
        
        if(team != null && team != ''){
            qry += ' WHERE ' + teamQry;
            if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
                if(dateRange == 'LAST_N_MONTHS:3'){
                    Date dt = System.today() - 90;
                    qry += ' AND Feedback_Date__c >= '+ dt;
                }else if(dateRange == 'LAST_N_MONTHS:6'){
                    Date dt = System.today() - 180;
                    qry += ' AND Feedback_Date__c >= '+ dt;
                }else{
                    qry += ' AND CreatedDate = '+dateRange;
                }
                qry = qry.replace(' 00:00:00', '');
            }
        }else if(dateRange != null && dateRange != '' && dateRange != 'Custom'){
            if(dateRange == 'LAST_N_MONTHS:3'){
                Date dt = Date.today().addDays(-90);
                System.debug('dt: ' + dt);
                qry += ' WHERE Feedback_Date__c >= '+ dt;
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                Date dt = System.today() - 180;
                qry += ' WHERE Feedback_Date__c >= '+ dt;
            }else{
                qry += ' WHERE Feedback_Date__c = '+dateRange;
            }
            qry = qry.replace(' 00:00:00', '');
        }
        //qry += ' AND NPS__c != null';
        return qry;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> npsExport(String userTeam, String dateRange, String year, String month){
        
        String team = userTeam.split(':')[0];
        String team2 = userTeam.split(':')[1];
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
        }else{
            qry = exportQry(team, dateRange);
        }
        
        //String qry = exportQry(team, dateRange);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        List<WhatsApp_Feedback__c> fbsToExport = new List<WhatsApp_Feedback__c>();
        for(WhatsApp_Feedback__c fb : fbList){
            if(team2 == 'CRM' || team2 == 'All'){
                if(fb.Feedback_Type__c == 'Day of Possession Handover' || fb.Feedback_Type__c == 'Day of Registration' || fb.Feedback_Type__c == 'Post Possession Handover'){
                    fbsToExport.add(fb);
                }
            }
            if(team2 == 'All' || team2 == 'Sales'){
                if(fb.Feedback_Type__c == 'Sales Experience'){
                    fbsToExport.add(fb);
                }
            }
        }
        return fbsToExport;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> custInsExport(String team, String dateRange, String year, String month){
        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = yearMonthQueryBuilder(team, year, month);
        }else{
            qry = exportQry(team, dateRange);
        }
        //String qry = exportQry(team, dateRange);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        List<WhatsApp_Feedback__c> fbsToExport = new List<WhatsApp_Feedback__c>();
        for(WhatsApp_Feedback__c fb : fbList){
            if(fb.Feedback_Type__c == 'Case Closure' || fb.Feedback_Type__c == 'Call Disposition'){
                fbsToExport.add(fb);
            }
        }
        return fbsToExport;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> campaignExport(String camp){
        if(camp == null || camp == ''){
            return null;
        }
        fbTypeNps nps = new fbTypeNps();
        List<WhatsApp_Feedback__c> fbList  = [SELECT Id, Name, Camp_Question_1__c, Camp_Question_2__c, Camp_Question_3__c, Camp_Question_4__c, Camp_Question_5__c, Camp_Question_6__c, Camp_Question_7__c, Camp_Question_8__c, Camp_Question_9__c, Camp_Question_10__c, Camp_Question_11__c, Camp_Question_12__c, Camp_Question_13__c, Camp_Question_14__c, Camp_Question_15__c, Camp_Question_16__c, Camp_Question_17__c, Camp_Question_18__c, Camp_Question_19__c, Camp_Question_20__c, 
                                              Camp_Answer_1__c, Camp_Answer_2__c, Camp_Answer_3__c, Camp_Answer_4__c, Camp_Answer_5__c, Camp_Answer_6__c, Camp_Answer_7__c, Camp_Answer_8__c, Camp_Answer_9__c, Camp_Answer_10__c, Camp_Answer_11__c, Camp_Answer_12__c, Camp_Answer_13__c, Camp_Answer_14__c, Camp_Answer_15__c, Camp_Answer_16__c, Camp_Answer_17__c, Camp_Answer_18__c, Camp_Answer_19__c, Camp_Answer_20__c, 
                                              Campaign_Name__c, NPS__c, Feedback_Type__c, Opportunity__c, Opportunity__r.Name, Project__c, CRN__c FROM WhatsApp_Feedback__c 
                                              WHERE Campaign_Name__c =: camp];
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> npsMonthYear(String team, String year, String month){
        String qry = yearMonthQueryBuilder(team, year, month);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> dayOfPosDataExport(String team, String dateRange, String proj){
        String qry = exportQry('', dateRange);
        String teamQry = teamQuery(team);
        if(dateRange != null && dateRange != ''){
            qry += ' AND Feedback_Type__c = \'Day of Possession Handover\'';
        }else{
            qry += ' WHERE Feedback_Type__c = \'Day of Possession Handover\'';
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> postPosDataExport(String team, String dateRange, String proj){
        String qry = exportQry('', dateRange);
        String teamQry = teamQuery(team);
        if(dateRange != null && dateRange != ''){
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
        }else{
            qry += ' WHERE Feedback_Type__c = \'Post Possession Handover\'';
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> caseClsDataExport(String team, String dateRange, String proj){
        String qry = exportQry('', dateRange);
        String teamQry = teamQuery(team);
        if(dateRange != null && dateRange != ''){
            qry += ' AND Feedback_Type__c = \'Case Closure\'';
        }else{
            qry += ' WHERE Feedback_Type__c = \'Case Closure\'';
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> callDispDataExport(String team, String dateRange, String proj){
        String qry = exportQry('', dateRange);
        String teamQry = teamQuery(team);
        System.debug('proj: ' + proj);
        if(dateRange != null && dateRange != ''){
            qry += ' AND Feedback_Type__c = \'Call Disposition\'';
        }else{
            qry += ' WHERE Feedback_Type__c = \'Call Disposition\'';
        }
        if(proj == 'All Projects'){
            qry += ' AND ' + teamQry;
        }else{
            qry += ' AND Project__c =: proj';
        }
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    public static String yearMonthQueryBuilder(String team, String year, String month){
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Question_2__c, Question_3__c, Question_4__c, Question_5__c, Question_6__c, Question_7__c, Question_8__c, Question_9__c, Question_10__c, Question_11__c, Question_12__c, Question_13__c, Question_14__c, Question_15__c, Question_16__c, Question_17__c, Question_18__c, Question_19__c, Question_20__c, Question_21__c, Question_22__c, Question_23__c, Question_24__c, Question_25__c, Question_26__c, Question_27__c, Answer_2__c, Answer_3__c, Answer_4__c, Answer_5__c, Answer_6__c, Answer_7__c, Answer_8__c, Answer_9__c, Answer_10__c, Answer_11__c, Answer_12__c, Answer_13__c, Answer_14__c, Answer_15__c, Answer_16__c, Answer_17__c, Answer_18__c, Answer_19__c, Answer_20__c, Answer_21__c, Answer_22__c, Answer_23__c, Answer_24__c, Answer_25__c, Answer_26__c, Answer_27__c, Sales_Experience_Answer_1__c, Sales_Experience_Answer_2__c, Sales_Experience_Answer_3__c, Sales_Experience_Answer_4__c, Sales_Experience_Answer_5__c, Sales_Experience_Answer_6__c, Sales_Experience_Answer_7__c, Sales_Experience_Question_1__c, Sales_Experience_Question_2__c, Sales_Experience_Question_3__c, Sales_Experience_Question_4__c, Sales_Experience_Question_5__c, Sales_Experience_Question_6__c, Sales_Experience_Question_7__c, Post_Possession_Frequency__c, Post_Possession_Frequency_Days__c FROM WhatsApp_Feedback__c';
        String teamQry = teamQuery(team);
        if(team != null && team != ''){
            qry += ' WHERE ' + teamQry;
            
            if(year != null && year != '' && month != null && month != ''){
                Integer yearInt = Integer.valueOf(year);
                Integer monthInt = Integer.valueOf(month);
                qry += ' AND Month__c = ' + monthInt + ' AND Year__c = ' + yearInt;
            }
        }else if(year != null && year != '' && month != null && month != ''){
            Integer yearInt = Integer.valueOf(year);
            Integer monthInt = Integer.valueOf(month);
            qry += 'WHERE Month__c = ' + monthInt + ' AND Year__c = ' + yearInt;
        }
        qry += ' AND NPS__c != null';
        return qry;
    }
    
    @auraEnabled
    public static List<npsScore> npsSummaryForYear(String userTeam){
        
        String team = userTeam.split(':')[0];
        String team2 = userTeam.split(':')[1];
        
        Date dt = System.today(); 
        Integer month = dt.Month(); 
        Integer year = dt.Year(); 
        Date lastYearDate = dt.addDays(-365);
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c  FROM WhatsApp_Feedback__c';
        String teamQry = teamQuery(team);
        
        if(team != null && team != ''){
            qry += ' WHERE ' + teamQry;   
        }
        qry += ' AND CreatedDate >=: lastYearDate';
        qry += ' AND NPS__c != null';
        List<Integer> yearList = new List<Integer>();
        List<Integer> monthList = new List<Integer>();
        for(Integer i=0;i<12;i++){
            System.debug('Date: ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month());
            monthList.add(dt.addMonths(-i).Month());
            yearList.add(dt.addMonths(-i).Year());
        }
        
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        if(!Test.isRunningTest()){
            fbList = Database.query(qry);
        }else{
            fbList = [SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c  FROM WhatsApp_Feedback__c LIMIT 10];
        }
        //List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        
        System.debug('fbList: ' + fbList);
        Map<String, Map<Decimal,Integer>> npsScores = new Map<String,Map<Decimal,Integer>>();
        Map<Decimal,Integer> dayOfRegCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> dayOfRegPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> dayOfRegDetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> dayOfPosCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> dayOfPosPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> dayOfPosDetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> postPosCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> postPosPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> postPosDetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> salesExpCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> salesExpPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> salesExpDetractorsCountMap = new Map<Decimal,Integer>();
        
        List<WhatsApp_Feedback__c> dayOfRegList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> dayOfPosList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> postPosList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> salesExpList = new List<WhatsApp_Feedback__c>();
        
        for(WhatsApp_Feedback__c fb : fbList){
            if(team2 == 'All'){
                if(fb.Feedback_Type__c == 'Day of Registration'){
                    dayOfRegList.add(fb);
                }else if(fb.Feedback_Type__c == 'Day of Possession Handover'){
                    dayOfPosList.add(fb);
                }else if(fb.Feedback_Type__c == 'Post Possession Handover'){
                    postPosList.add(fb);
                }else if(fb.Feedback_Type__c == 'Sales Experience'){
                    salesExpList.add(fb);
                }
            }else if(team2 == 'CRM'){
                if(fb.Feedback_Type__c == 'Day of Registration'){
                    dayOfRegList.add(fb);
                }else if(fb.Feedback_Type__c == 'Day of Possession Handover'){
                    dayOfPosList.add(fb);
                }else if(fb.Feedback_Type__c == 'Post Possession Handover'){
                    postPosList.add(fb);
                }
            }else if(team2 == 'Sales'){
                if(fb.Feedback_Type__c == 'Sales Experience'){
                    salesExpList.add(fb);
                }
            }
            
        }
        System.debug('salesExpList: ' + salesExpList);
        for(WhatsApp_Feedback__c fb : dayOfRegList){
            if(dayOfRegCountMap.keySet().contains(fb.Month__c)){
                dayOfRegCountMap.put(fb.Month__c, dayOfRegCountMap.get(fb.Month__c)+1);
            }else{
                dayOfRegCountMap.put(fb.Month__c, 1);
            }
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(dayOfRegPrometorsCountMap.keySet().contains(fb.Month__c)){
                    dayOfRegPrometorsCountMap.put(fb.Month__c, dayOfRegPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    dayOfRegPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(dayOfRegDetractorsCountMap.keySet().contains(fb.Month__c)){
                    dayOfRegDetractorsCountMap.put(fb.Month__c, dayOfRegDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    dayOfRegDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
            
            
        }
        for(WhatsApp_Feedback__c fb : dayOfPosList){
            if(dayOfPosCountMap.keySet().contains(fb.Month__c)){
                dayOfPosCountMap.put(fb.Month__c, dayOfPosCountMap.get(fb.Month__c)+1);
            }else{
                dayOfPosCountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(dayOfPosPrometorsCountMap.keySet().contains(fb.Month__c)){
                    dayOfPosPrometorsCountMap.put(fb.Month__c, dayOfPosPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    dayOfPosPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(dayOfPosDetractorsCountMap.keySet().contains(fb.Month__c)){
                    dayOfPosDetractorsCountMap.put(fb.Month__c, dayOfPosDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    dayOfPosDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : postPosList){
            if(postPosCountMap.keySet().contains(fb.Month__c)){
                postPosCountMap.put(fb.Month__c, postPosCountMap.get(fb.Month__c)+1);
            }else{
                postPosCountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(postPosPrometorsCountMap.keySet().contains(fb.Month__c)){
                    postPosPrometorsCountMap.put(fb.Month__c, postPosPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    postPosPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(postPosDetractorsCountMap.keySet().contains(fb.Month__c)){
                    postPosDetractorsCountMap.put(fb.Month__c, postPosDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    postPosDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        for(WhatsApp_Feedback__c fb : salesExpList){
            if(salesExpCountMap.keySet().contains(fb.Month__c)){
                salesExpCountMap.put(fb.Month__c, salesExpCountMap.get(fb.Month__c)+1);
            }else{
                salesExpCountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(salesExpPrometorsCountMap.keySet().contains(fb.Month__c)){
                    salesExpPrometorsCountMap.put(fb.Month__c, salesExpPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    salesExpPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(salesExpDetractorsCountMap.keySet().contains(fb.Month__c)){
                    salesExpDetractorsCountMap.put(fb.Month__c, salesExpDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    salesExpDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        System.debug('salesExpPrometorsCountMap: ' + salesExpPrometorsCountMap);
        System.debug('salesExpDetractorsCountMap: ' + salesExpDetractorsCountMap);
        System.debug('salesExpCountMap: ' + salesExpCountMap);
        if(team2 == 'All'){
            npsScores.put('Sales Experience',salesExpCountMap);
            npsScores.put('Day Of Registration',dayOfRegCountMap);
            npsScores.put('Day Of Possession',dayOfPosCountMap);
            npsScores.put('Post Possession Handover',postPosCountMap);
        }else if(team2 == 'CRM'){
            npsScores.put('Day Of Registration',dayOfRegCountMap);
            npsScores.put('Day Of Possession',dayOfPosCountMap);
            npsScores.put('Post Possession Handover',postPosCountMap);
        }else if(team2 == 'Sales'){
            npsScores.put('Sales Experience',salesExpCountMap);
        }
        
        System.debug('npsScores: ' + npsScores);
        List<npsScore> scores = new List<npsScore>();
        
        npsScore yearDetails = new npsScore();
        yearDetails.fbType = 'Year';
        yearDetails.month1 = yearList[0];
        yearDetails.month2 = yearList[1];
        yearDetails.month3 = yearList[2];
        yearDetails.month4 = yearList[3];
        yearDetails.month5 = yearList[4];
        yearDetails.month6 = yearList[5];
        yearDetails.month7 = yearList[6];
        yearDetails.month8 = yearList[7];
        yearDetails.month9 = yearList[8];
        yearDetails.month10 = yearList[9];
        yearDetails.month11 = yearList[10];
        yearDetails.month12 = yearList[11];
        scores.add(yearDetails);
        
        npsScore monthDetails = new npsScore();
        monthDetails.fbType = 'Month';
        monthDetails.month1 = monthList[0];
        monthDetails.month2 = monthList[1];
        monthDetails.month3 = monthList[2];
        monthDetails.month4 = monthList[3];
        monthDetails.month5 = monthList[4];
        monthDetails.month6 = monthList[5];
        monthDetails.month7 = monthList[6];
        monthDetails.month8 = monthList[7];
        monthDetails.month9 = monthList[8];
        monthDetails.month10 = monthList[9];
        monthDetails.month11 = monthList[10];
        monthDetails.month12 = monthList[11];
        scores.add(monthDetails);
        
        npsScore dayOfRegScore = new npsScore();
        npsScore dayOfPosScore = new npsScore();
        npsScore postPosScore = new npsScore();
        npsScore salesExpScore = new npsScore();
        
        Decimal salesExpMonth1Count = (salesExpCountMap.get(monthList[0]) != null)? salesExpCountMap.get(monthList[0]) : 0;
        Decimal salesExpMonth1PrometorsCount = (salesExpPrometorsCountMap.get(monthList[0]) != null)? salesExpPrometorsCountMap.get(monthList[0]) : 0;
        Decimal salesExpMonth1DetractorsCount = (salesExpDetractorsCountMap.get(monthList[0]) != null)? salesExpDetractorsCountMap.get(monthList[0]) : 0;
        Decimal salesExpMonth2Count = (salesExpCountMap.get(monthList[1]) != null)? salesExpCountMap.get(monthList[1]) : 0;
        Decimal salesExpMonth2PrometorsCount = (salesExpPrometorsCountMap.get(monthList[1]) != null)? salesExpPrometorsCountMap.get(monthList[1]) : 0;
        Decimal salesExpMonth2DetractorsCount = (salesExpDetractorsCountMap.get(monthList[1]) != null)? salesExpDetractorsCountMap.get(monthList[1]) : 0;
        Decimal salesExpMonth3Count = (salesExpCountMap.get(monthList[2]) != null)? salesExpCountMap.get(monthList[2]) : 0;
        Decimal salesExpMonth3PrometorsCount = (salesExpPrometorsCountMap.get(monthList[2]) != null)? salesExpPrometorsCountMap.get(monthList[2]) : 0;
        Decimal salesExpMonth3DetractorsCount = (salesExpDetractorsCountMap.get(monthList[2]) != null)? salesExpDetractorsCountMap.get(monthList[2]) : 0;
        Decimal salesExpMonth4Count = (salesExpCountMap.get(monthList[3]) != null)? salesExpCountMap.get(monthList[3]) : 0;
        Decimal salesExpMonth4PrometorsCount = (salesExpPrometorsCountMap.get(monthList[3]) != null)? salesExpPrometorsCountMap.get(monthList[3]) : 0;
        Decimal salesExpMonth4DetractorsCount = (salesExpDetractorsCountMap.get(monthList[3]) != null)? salesExpDetractorsCountMap.get(monthList[3]) : 0;
        Decimal salesExpMonth5Count = (salesExpCountMap.get(monthList[4]) != null)? salesExpCountMap.get(monthList[4]) : 0;
        Decimal salesExpMonth5PrometorsCount = (salesExpPrometorsCountMap.get(monthList[4]) != null)? salesExpPrometorsCountMap.get(monthList[4]) : 0;
        Decimal salesExpMonth5DetractorsCount = (salesExpDetractorsCountMap.get(monthList[4]) != null)? salesExpDetractorsCountMap.get(monthList[4]) : 0;
        Decimal salesExpMonth6Count = (salesExpCountMap.get(monthList[5]) != null)? salesExpCountMap.get(monthList[5]) : 0;
        Decimal salesExpMonth6PrometorsCount = (salesExpPrometorsCountMap.get(monthList[5]) != null)? salesExpPrometorsCountMap.get(monthList[5]) : 0;
        Decimal salesExpMonth6DetractorsCount = (salesExpDetractorsCountMap.get(monthList[5]) != null)? salesExpDetractorsCountMap.get(monthList[5]) : 0;
        Decimal salesExpMonth7Count = (salesExpCountMap.get(monthList[6]) != null)? salesExpCountMap.get(monthList[6]) : 0;
        Decimal salesExpMonth7PrometorsCount = (salesExpPrometorsCountMap.get(monthList[6]) != null)? salesExpPrometorsCountMap.get(monthList[6]) : 0;
        Decimal salesExpMonth7DetractorsCount = (salesExpDetractorsCountMap.get(monthList[6]) != null)? salesExpDetractorsCountMap.get(monthList[6]) : 0;
        Decimal salesExpMonth8Count = (salesExpCountMap.get(monthList[7]) != null)? salesExpCountMap.get(monthList[7]) : 0;
        Decimal salesExpMonth8PrometorsCount = (salesExpPrometorsCountMap.get(monthList[7]) != null)? salesExpPrometorsCountMap.get(monthList[7]) : 0;
        Decimal salesExpMonth8DetractorsCount = (salesExpDetractorsCountMap.get(monthList[7]) != null)? salesExpDetractorsCountMap.get(monthList[7]) : 0;
        Decimal salesExpMonth9Count = (salesExpCountMap.get(monthList[8]) != null)? salesExpCountMap.get(monthList[8]) : 0;
        Decimal salesExpMonth9PrometorsCount = (salesExpPrometorsCountMap.get(monthList[8]) != null)? salesExpPrometorsCountMap.get(monthList[8]) : 0;
        Decimal salesExpMonth9DetractorsCount = (salesExpDetractorsCountMap.get(monthList[8]) != null)? salesExpDetractorsCountMap.get(monthList[8]) : 0;
        Decimal salesExpMonth10Count = (salesExpCountMap.get(monthList[9]) != null)? salesExpCountMap.get(monthList[9]) : 0;
        Decimal salesExpMonth10PrometorsCount = (salesExpPrometorsCountMap.get(monthList[9]) != null)? salesExpPrometorsCountMap.get(monthList[9]) : 0;
        Decimal salesExpMonth10DetractorsCount = (salesExpDetractorsCountMap.get(monthList[9]) != null)? salesExpDetractorsCountMap.get(monthList[9]) : 0;
        Decimal salesExpMonth11Count = (salesExpCountMap.get(monthList[10]) != null)? salesExpCountMap.get(monthList[10]) : 0;
        Decimal salesExpMonth11PrometorsCount = (salesExpPrometorsCountMap.get(monthList[10]) != null)? salesExpPrometorsCountMap.get(monthList[10]) : 0;
        Decimal salesExpMonth11DetractorsCount = (salesExpDetractorsCountMap.get(monthList[10]) != null)? salesExpDetractorsCountMap.get(monthList[10]) : 0;
        Decimal salesExpMonth12Count = (salesExpCountMap.get(monthList[11]) != null)? salesExpCountMap.get(monthList[11]) : 0;
        Decimal salesExpMonth12PrometorsCount = (salesExpPrometorsCountMap.get(monthList[11]) != null)? salesExpPrometorsCountMap.get(monthList[11]) : 0;
        Decimal salesExpMonth12DetractorsCount = (salesExpDetractorsCountMap.get(monthList[11]) != null)? salesExpDetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal dayOfRegMonth1Count = (dayOfRegCountMap.get(monthList[0]) != null)? dayOfRegCountMap.get(monthList[0]) : 0;
        Decimal dayOfRegMonth1PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[0]) != null)? dayOfRegPrometorsCountMap.get(monthList[0]) : 0;
        Decimal dayOfRegMonth1DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[0]) != null)? dayOfRegDetractorsCountMap.get(monthList[0]) : 0;
        Decimal dayOfRegMonth2Count = (dayOfRegCountMap.get(monthList[1]) != null)? dayOfRegCountMap.get(monthList[1]) : 0;
        Decimal dayOfRegMonth2PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[1]) != null)? dayOfRegPrometorsCountMap.get(monthList[1]) : 0;
        Decimal dayOfRegMonth2DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[1]) != null)? dayOfRegDetractorsCountMap.get(monthList[1]) : 0;
        Decimal dayOfRegMonth3Count = (dayOfRegCountMap.get(monthList[2]) != null)? dayOfRegCountMap.get(monthList[2]) : 0;
        Decimal dayOfRegMonth3PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[2]) != null)? dayOfRegPrometorsCountMap.get(monthList[2]) : 0;
        Decimal dayOfRegMonth3DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[2]) != null)? dayOfRegDetractorsCountMap.get(monthList[2]) : 0;
        Decimal dayOfRegMonth4Count = (dayOfRegCountMap.get(monthList[3]) != null)? dayOfRegCountMap.get(monthList[3]) : 0;
        Decimal dayOfRegMonth4PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[3]) != null)? dayOfRegPrometorsCountMap.get(monthList[3]) : 0;
        Decimal dayOfRegMonth4DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[3]) != null)? dayOfRegDetractorsCountMap.get(monthList[3]) : 0;
        Decimal dayOfRegMonth5Count = (dayOfRegCountMap.get(monthList[4]) != null)? dayOfRegCountMap.get(monthList[4]) : 0;
        Decimal dayOfRegMonth5PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[4]) != null)? dayOfRegPrometorsCountMap.get(monthList[4]) : 0;
        Decimal dayOfRegMonth5DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[4]) != null)? dayOfRegDetractorsCountMap.get(monthList[4]) : 0;
        Decimal dayOfRegMonth6Count = (dayOfRegCountMap.get(monthList[5]) != null)? dayOfRegCountMap.get(monthList[5]) : 0;
        Decimal dayOfRegMonth6PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[5]) != null)? dayOfRegPrometorsCountMap.get(monthList[5]) : 0;
        Decimal dayOfRegMonth6DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[5]) != null)? dayOfRegDetractorsCountMap.get(monthList[5]) : 0;
        Decimal dayOfRegMonth7Count = (dayOfRegCountMap.get(monthList[6]) != null)? dayOfRegCountMap.get(monthList[6]) : 0;
        Decimal dayOfRegMonth7PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[6]) != null)? dayOfRegPrometorsCountMap.get(monthList[6]) : 0;
        Decimal dayOfRegMonth7DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[6]) != null)? dayOfRegDetractorsCountMap.get(monthList[6]) : 0;
        Decimal dayOfRegMonth8Count = (dayOfRegCountMap.get(monthList[7]) != null)? dayOfRegCountMap.get(monthList[7]) : 0;
        Decimal dayOfRegMonth8PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[7]) != null)? dayOfRegPrometorsCountMap.get(monthList[7]) : 0;
        Decimal dayOfRegMonth8DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[7]) != null)? dayOfRegDetractorsCountMap.get(monthList[7]) : 0;
        Decimal dayOfRegMonth9Count = (dayOfRegCountMap.get(monthList[8]) != null)? dayOfRegCountMap.get(monthList[8]) : 0;
        Decimal dayOfRegMonth9PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[8]) != null)? dayOfRegPrometorsCountMap.get(monthList[8]) : 0;
        Decimal dayOfRegMonth9DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[8]) != null)? dayOfRegDetractorsCountMap.get(monthList[8]) : 0;
        Decimal dayOfRegMonth10Count = (dayOfRegCountMap.get(monthList[9]) != null)? dayOfRegCountMap.get(monthList[9]) : 0;
        Decimal dayOfRegMonth10PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[9]) != null)? dayOfRegPrometorsCountMap.get(monthList[9]) : 0;
        Decimal dayOfRegMonth10DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[9]) != null)? dayOfRegDetractorsCountMap.get(monthList[9]) : 0;
        Decimal dayOfRegMonth11Count = (dayOfRegCountMap.get(monthList[10]) != null)? dayOfRegCountMap.get(monthList[10]) : 0;
        Decimal dayOfRegMonth11PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[10]) != null)? dayOfRegPrometorsCountMap.get(monthList[10]) : 0;
        Decimal dayOfRegMonth11DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[10]) != null)? dayOfRegDetractorsCountMap.get(monthList[10]) : 0;
        Decimal dayOfRegMonth12Count = (dayOfRegCountMap.get(monthList[11]) != null)? dayOfRegCountMap.get(monthList[11]) : 0;
        Decimal dayOfRegMonth12PrometorsCount = (dayOfRegPrometorsCountMap.get(monthList[11]) != null)? dayOfRegPrometorsCountMap.get(monthList[11]) : 0;
        Decimal dayOfRegMonth12DetractorsCount = (dayOfRegDetractorsCountMap.get(monthList[11]) != null)? dayOfRegDetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal dayOfPosMonth1Count = (dayOfPosCountMap.get(monthList[0]) != null)? dayOfPosCountMap.get(monthList[0]) : 0;
        Decimal dayOfPosMonth1PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[0]) != null)? dayOfPosPrometorsCountMap.get(monthList[0]) : 0;
        Decimal dayOfPosMonth1DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[0]) != null)? dayOfPosDetractorsCountMap.get(monthList[0]) : 0;
        Decimal dayOfPosMonth2Count = (dayOfPosCountMap.get(monthList[1]) != null)? dayOfPosCountMap.get(monthList[1]) : 0;
        Decimal dayOfPosMonth2PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[1]) != null)? dayOfPosPrometorsCountMap.get(monthList[1]) : 0;
        Decimal dayOfPosMonth2DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[1]) != null)? dayOfPosDetractorsCountMap.get(monthList[1]) : 0;
        Decimal dayOfPosMonth3Count = (dayOfPosCountMap.get(monthList[2]) != null)? dayOfPosCountMap.get(monthList[2]) : 0;
        Decimal dayOfPosMonth3PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[2]) != null)? dayOfPosPrometorsCountMap.get(monthList[2]) : 0;
        Decimal dayOfPosMonth3DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[2]) != null)? dayOfPosDetractorsCountMap.get(monthList[2]) : 0;
        Decimal dayOfPosMonth4Count = (dayOfPosCountMap.get(monthList[3]) != null)? dayOfPosCountMap.get(monthList[3]) : 0;
        Decimal dayOfPosMonth4PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[3]) != null)? dayOfPosPrometorsCountMap.get(monthList[3]) : 0;
        Decimal dayOfPosMonth4DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[3]) != null)? dayOfPosDetractorsCountMap.get(monthList[3]) : 0;
        Decimal dayOfPosMonth5Count = (dayOfPosCountMap.get(monthList[4]) != null)? dayOfPosCountMap.get(monthList[4]) : 0;
        Decimal dayOfPosMonth5PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[4]) != null)? dayOfPosPrometorsCountMap.get(monthList[4]) : 0;
        Decimal dayOfPosMonth5DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[4]) != null)? dayOfPosDetractorsCountMap.get(monthList[4]) : 0;
        Decimal dayOfPosMonth6Count = (dayOfPosCountMap.get(monthList[5]) != null)? dayOfPosCountMap.get(monthList[5]) : 0;
        Decimal dayOfPosMonth6PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[5]) != null)? dayOfPosPrometorsCountMap.get(monthList[5]) : 0;
        Decimal dayOfPosMonth6DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[5]) != null)? dayOfPosDetractorsCountMap.get(monthList[5]) : 0;
        Decimal dayOfPosMonth7Count = (dayOfPosCountMap.get(monthList[6]) != null)? dayOfPosCountMap.get(monthList[6]) : 0;
        Decimal dayOfPosMonth7PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[6]) != null)? dayOfPosPrometorsCountMap.get(monthList[6]) : 0;
        Decimal dayOfPosMonth7DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[6]) != null)? dayOfPosDetractorsCountMap.get(monthList[6]) : 0;
        Decimal dayOfPosMonth8Count = (dayOfPosCountMap.get(monthList[7]) != null)? dayOfPosCountMap.get(monthList[7]) : 0;
        Decimal dayOfPosMonth8PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[7]) != null)? dayOfPosPrometorsCountMap.get(monthList[7]) : 0;
        Decimal dayOfPosMonth8DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[7]) != null)? dayOfPosDetractorsCountMap.get(monthList[7]) : 0;
        Decimal dayOfPosMonth9Count = (dayOfPosCountMap.get(monthList[8]) != null)? dayOfPosCountMap.get(monthList[8]) : 0;
        Decimal dayOfPosMonth9PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[8]) != null)? dayOfPosPrometorsCountMap.get(monthList[8]) : 0;
        Decimal dayOfPosMonth9DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[8]) != null)? dayOfPosDetractorsCountMap.get(monthList[8]) : 0;
        Decimal dayOfPosMonth10Count = (dayOfPosCountMap.get(monthList[9]) != null)? dayOfPosCountMap.get(monthList[9]) : 0;
        Decimal dayOfPosMonth10PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[9]) != null)? dayOfPosPrometorsCountMap.get(monthList[9]) : 0;
        Decimal dayOfPosMonth10DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[9]) != null)? dayOfPosDetractorsCountMap.get(monthList[9]) : 0;
        Decimal dayOfPosMonth11Count = (dayOfPosCountMap.get(monthList[10]) != null)? dayOfPosCountMap.get(monthList[10]) : 0;
        Decimal dayOfPosMonth11PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[10]) != null)? dayOfPosPrometorsCountMap.get(monthList[10]) : 0;
        Decimal dayOfPosMonth11DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[10]) != null)? dayOfPosDetractorsCountMap.get(monthList[10]) : 0;
        Decimal dayOfPosMonth12Count = (dayOfPosCountMap.get(monthList[11]) != null)? dayOfPosCountMap.get(monthList[11]) : 0;
        Decimal dayOfPosMonth12PrometorsCount = (dayOfPosPrometorsCountMap.get(monthList[11]) != null)? dayOfPosPrometorsCountMap.get(monthList[11]) : 0;
        Decimal dayOfPosMonth12DetractorsCount = (dayOfPosDetractorsCountMap.get(monthList[11]) != null)? dayOfPosDetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal postPosMonth1Count = (postPosCountMap.get(monthList[0]) != null)? postPosCountMap.get(monthList[0]) : 0;
        Decimal postPosMonth1PrometorsCount = (postPosPrometorsCountMap.get(monthList[0]) != null)? postPosPrometorsCountMap.get(monthList[0]) : 0;
        Decimal postPosMonth1DetractorsCount = (postPosDetractorsCountMap.get(monthList[0]) != null)? postPosDetractorsCountMap.get(monthList[0]) : 0;
        Decimal postPosMonth2Count = (postPosCountMap.get(monthList[1]) != null)? postPosCountMap.get(monthList[1]) : 0;
        Decimal postPosMonth2PrometorsCount = (postPosPrometorsCountMap.get(monthList[1]) != null)? postPosPrometorsCountMap.get(monthList[1]) : 0;
        Decimal postPosMonth2DetractorsCount = (postPosDetractorsCountMap.get(monthList[1]) != null)? postPosDetractorsCountMap.get(monthList[1]) : 0;
        Decimal postPosMonth3Count = (postPosCountMap.get(monthList[2]) != null)? postPosCountMap.get(monthList[2]) : 0;
        Decimal postPosMonth3PrometorsCount = (postPosPrometorsCountMap.get(monthList[2]) != null)? postPosPrometorsCountMap.get(monthList[2]) : 0;
        Decimal postPosMonth3DetractorsCount = (postPosDetractorsCountMap.get(monthList[2]) != null)? postPosDetractorsCountMap.get(monthList[2]) : 0;
        Decimal postPosMonth4Count = (postPosCountMap.get(monthList[3]) != null)? postPosCountMap.get(monthList[3]) : 0;
        Decimal postPosMonth4PrometorsCount = (postPosPrometorsCountMap.get(monthList[3]) != null)? postPosPrometorsCountMap.get(monthList[3]) : 0;
        Decimal postPosMonth4DetractorsCount = (postPosDetractorsCountMap.get(monthList[3]) != null)? postPosDetractorsCountMap.get(monthList[3]) : 0;
        Decimal postPosMonth5Count = (postPosCountMap.get(monthList[4]) != null)? postPosCountMap.get(monthList[4]) : 0;
        Decimal postPosMonth5PrometorsCount = (postPosPrometorsCountMap.get(monthList[4]) != null)? postPosPrometorsCountMap.get(monthList[4]) : 0;
        Decimal postPosMonth5DetractorsCount = (postPosDetractorsCountMap.get(monthList[4]) != null)? postPosDetractorsCountMap.get(monthList[4]) : 0;
        Decimal postPosMonth6Count = (postPosCountMap.get(monthList[5]) != null)? postPosCountMap.get(monthList[5]) : 0;
        Decimal postPosMonth6PrometorsCount = (postPosPrometorsCountMap.get(monthList[5]) != null)? postPosPrometorsCountMap.get(monthList[5]) : 0;
        Decimal postPosMonth6DetractorsCount = (postPosDetractorsCountMap.get(monthList[5]) != null)? postPosDetractorsCountMap.get(monthList[5]) : 0;
        Decimal postPosMonth7Count = (postPosCountMap.get(monthList[6]) != null)? postPosCountMap.get(monthList[6]) : 0;
        Decimal postPosMonth7PrometorsCount = (postPosPrometorsCountMap.get(monthList[6]) != null)? postPosPrometorsCountMap.get(monthList[6]) : 0;
        Decimal postPosMonth7DetractorsCount = (postPosDetractorsCountMap.get(monthList[6]) != null)? postPosDetractorsCountMap.get(monthList[6]) : 0;
        Decimal postPosMonth8Count = (postPosCountMap.get(monthList[7]) != null)? postPosCountMap.get(monthList[7]) : 0;
        Decimal postPosMonth8PrometorsCount = (postPosPrometorsCountMap.get(monthList[7]) != null)? postPosPrometorsCountMap.get(monthList[7]) : 0;
        Decimal postPosMonth8DetractorsCount = (postPosDetractorsCountMap.get(monthList[7]) != null)? postPosDetractorsCountMap.get(monthList[7]) : 0;
        Decimal postPosMonth9Count = (postPosCountMap.get(monthList[8]) != null)? postPosCountMap.get(monthList[8]) : 0;
        Decimal postPosMonth9PrometorsCount = (postPosPrometorsCountMap.get(monthList[8]) != null)? postPosPrometorsCountMap.get(monthList[8]) : 0;
        Decimal postPosMonth9DetractorsCount = (postPosDetractorsCountMap.get(monthList[8]) != null)? postPosDetractorsCountMap.get(monthList[8]) : 0;
        Decimal postPosMonth10Count = (postPosCountMap.get(monthList[9]) != null)? postPosCountMap.get(monthList[9]) : 0;
        Decimal postPosMonth10PrometorsCount = (postPosPrometorsCountMap.get(monthList[9]) != null)? postPosPrometorsCountMap.get(monthList[9]) : 0;
        Decimal postPosMonth10DetractorsCount = (postPosDetractorsCountMap.get(monthList[9]) != null)? postPosDetractorsCountMap.get(monthList[9]) : 0;
        Decimal postPosMonth11Count = (postPosCountMap.get(monthList[10]) != null)? postPosCountMap.get(monthList[10]) : 0;
        Decimal postPosMonth11PrometorsCount = (postPosPrometorsCountMap.get(monthList[10]) != null)? postPosPrometorsCountMap.get(monthList[10]) : 0;
        Decimal postPosMonth11DetractorsCount = (postPosDetractorsCountMap.get(monthList[10]) != null)? postPosDetractorsCountMap.get(monthList[10]) : 0;
        Decimal postPosMonth12Count = (postPosCountMap.get(monthList[11]) != null)? postPosCountMap.get(monthList[11]) : 0;
        Decimal postPosMonth12PrometorsCount = (postPosPrometorsCountMap.get(monthList[11]) != null)? postPosPrometorsCountMap.get(monthList[11]) : 0;
        Decimal postPosMonth12DetractorsCount = (postPosDetractorsCountMap.get(monthList[11]) != null)? postPosDetractorsCountMap.get(monthList[11]) : 0;
        
        if(team2 == 'All' || team2 == 'Sales'){
            //npsScore salesExpScore = new npsScore();
            salesExpScore.fbType = 'Sales Experience';
            
            salesExpScore.month1 = (salesExpMonth1Count != 0)? ((salesExpMonth1PrometorsCount*100/salesExpMonth1Count) - (salesExpMonth1DetractorsCount*100/salesExpMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month2 = (salesExpMonth2Count != 0)? ((salesExpMonth2PrometorsCount*100/salesExpMonth2Count) - (salesExpMonth2DetractorsCount*100/salesExpMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month3 = (salesExpMonth3Count != 0)? ((salesExpMonth3PrometorsCount*100/salesExpMonth3Count) - (salesExpMonth3DetractorsCount*100/salesExpMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month4 = (salesExpMonth4Count != 0)? ((salesExpMonth4PrometorsCount*100/salesExpMonth4Count) - (salesExpMonth4DetractorsCount*100/salesExpMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month5 = (salesExpMonth5Count != 0)? ((salesExpMonth5PrometorsCount*100/salesExpMonth5Count) - (salesExpMonth5DetractorsCount*100/salesExpMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month6 = (salesExpMonth6Count != 0)? ((salesExpMonth6PrometorsCount*100/salesExpMonth6Count) - (salesExpMonth6DetractorsCount*100/salesExpMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month7 = (salesExpMonth7Count != 0)? ((salesExpMonth7PrometorsCount*100/salesExpMonth7Count) - (salesExpMonth7DetractorsCount*100/salesExpMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month8 = (salesExpMonth8Count != 0)? ((salesExpMonth8PrometorsCount*100/salesExpMonth8Count) - (salesExpMonth8DetractorsCount*100/salesExpMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month9 = (salesExpMonth9Count != 0)? ((salesExpMonth9PrometorsCount*100/salesExpMonth9Count) - (salesExpMonth9DetractorsCount*100/salesExpMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month10 = (salesExpMonth10Count != 0)? ((salesExpMonth10PrometorsCount*100/salesExpMonth10Count) - (salesExpMonth10DetractorsCount*100/salesExpMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month11 = (salesExpMonth11Count != 0)? ((salesExpMonth10PrometorsCount*100/salesExpMonth11Count) - (salesExpMonth11DetractorsCount*100/salesExpMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            salesExpScore.month12 = (salesExpMonth12Count != 0)? ((salesExpMonth12PrometorsCount*100/salesExpMonth12Count) - (salesExpMonth12DetractorsCount*100/salesExpMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(salesExpScore);
        }
        if(team2 == 'All' || team2 == 'CRM'){
            //npsScore dayOfRegScore = new npsScore();
            dayOfRegScore.fbType = 'Day of Registration';
            
            dayOfRegScore.month1 = (dayOfRegMonth1Count != 0)? ((dayOfRegMonth1PrometorsCount*100/dayOfRegMonth1Count) - (dayOfRegMonth1DetractorsCount*100/dayOfRegMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month2 = (dayOfRegMonth2Count != 0)? ((dayOfRegMonth2PrometorsCount*100/dayOfRegMonth2Count) - (dayOfRegMonth2DetractorsCount*100/dayOfRegMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month3 = (dayOfRegMonth3Count != 0)? ((dayOfRegMonth3PrometorsCount*100/dayOfRegMonth3Count) - (dayOfRegMonth3DetractorsCount*100/dayOfRegMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month4 = (dayOfRegMonth4Count != 0)? ((dayOfRegMonth4PrometorsCount*100/dayOfRegMonth4Count) - (dayOfRegMonth4DetractorsCount*100/dayOfRegMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month5 = (dayOfRegMonth5Count != 0)? ((dayOfRegMonth5PrometorsCount*100/dayOfRegMonth5Count) - (dayOfRegMonth5DetractorsCount*100/dayOfRegMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month6 = (dayOfRegMonth6Count != 0)? ((dayOfRegMonth6PrometorsCount*100/dayOfRegMonth6Count) - (dayOfRegMonth6DetractorsCount*100/dayOfRegMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month7 = (dayOfRegMonth7Count != 0)? ((dayOfRegMonth7PrometorsCount*100/dayOfRegMonth7Count) - (dayOfRegMonth7DetractorsCount*100/dayOfRegMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month8 = (dayOfRegMonth8Count != 0)? ((dayOfRegMonth8PrometorsCount*100/dayOfRegMonth8Count) - (dayOfRegMonth8DetractorsCount*100/dayOfRegMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month9 = (dayOfRegMonth9Count != 0)? ((dayOfRegMonth9PrometorsCount*100/dayOfRegMonth9Count) - (dayOfRegMonth9DetractorsCount*100/dayOfRegMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month10 = (dayOfRegMonth10Count != 0)? ((dayOfRegMonth10PrometorsCount*100/dayOfRegMonth10Count) - (dayOfRegMonth10DetractorsCount*100/dayOfRegMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month11 = (dayOfRegMonth11Count != 0)? ((dayOfRegMonth11PrometorsCount*100/dayOfRegMonth11Count) - (dayOfRegMonth11DetractorsCount*100/dayOfRegMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfRegScore.month12 = (dayOfRegMonth12Count != 0)? ((dayOfRegMonth12PrometorsCount*100/dayOfRegMonth12Count) - (dayOfRegMonth12DetractorsCount*100/dayOfRegMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            
            scores.add(dayOfRegScore);
            
            //npsScore dayOfPosScore = new npsScore();
            dayOfPosScore.fbType = 'Day of Possession Handover';
            
            dayOfPosScore.month1 = (dayOfPosMonth1Count != 0)? ((dayOfPosMonth1PrometorsCount*100/dayOfPosMonth1Count) - (dayOfPosMonth1DetractorsCount*100/dayOfPosMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month2 = (dayOfPosMonth2Count != 0)? ((dayOfPosMonth2PrometorsCount*100/dayOfPosMonth2Count) - (dayOfPosMonth2DetractorsCount*100/dayOfPosMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month3 = (dayOfPosMonth3Count != 0)? ((dayOfPosMonth3PrometorsCount*100/dayOfPosMonth3Count) - (dayOfPosMonth3DetractorsCount*100/dayOfPosMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month4 = (dayOfPosMonth4Count != 0)? ((dayOfPosMonth4PrometorsCount*100/dayOfPosMonth4Count) - (dayOfPosMonth4DetractorsCount*100/dayOfPosMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month5 = (dayOfPosMonth5Count != 0)? ((dayOfPosMonth5PrometorsCount*100/dayOfPosMonth5Count) - (dayOfPosMonth5DetractorsCount*100/dayOfPosMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month6 = (dayOfPosMonth6Count != 0)? ((dayOfPosMonth6PrometorsCount*100/dayOfPosMonth6Count) - (dayOfPosMonth6DetractorsCount*100/dayOfPosMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month7 = (dayOfPosMonth7Count != 0)? ((dayOfPosMonth7PrometorsCount*100/dayOfPosMonth7Count) - (dayOfPosMonth7DetractorsCount*100/dayOfPosMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month8 = (dayOfPosMonth8Count != 0)? ((dayOfPosMonth8PrometorsCount*100/dayOfPosMonth8Count) - (dayOfPosMonth8DetractorsCount*100/dayOfPosMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month9 = (dayOfPosMonth9Count != 0)? ((dayOfPosMonth9PrometorsCount*100/dayOfPosMonth9Count) - (dayOfPosMonth9DetractorsCount*100/dayOfPosMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month10 = (dayOfPosMonth10Count != 0)? ((dayOfPosMonth10PrometorsCount*100/dayOfPosMonth10Count) - (dayOfPosMonth10DetractorsCount*100/dayOfPosMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month11 = (dayOfPosMonth11Count != 0)? ((dayOfPosMonth11PrometorsCount*100/dayOfPosMonth11Count) - (dayOfPosMonth11DetractorsCount*100/dayOfPosMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            dayOfPosScore.month12 = (dayOfPosMonth12Count != 0)? ((dayOfPosMonth12PrometorsCount*100/dayOfPosMonth12Count) - (dayOfPosMonth12DetractorsCount*100/dayOfPosMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            
            scores.add(dayOfPosScore);
            System.debug('dayOfPosScore: ' + dayOfPosScore);
            
            //npsScore postPosScore = new npsScore();
            postPosScore.fbType = 'Post Possession Handover';
            
            postPosScore.month1 = (postPosMonth1Count != 0)? ((postPosMonth1PrometorsCount*100/postPosMonth1Count) - (postPosMonth1DetractorsCount*100/postPosMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month2 = (postPosMonth2Count != 0)? ((postPosMonth2PrometorsCount*100/postPosMonth2Count) - (postPosMonth2DetractorsCount*100/postPosMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month3 = (postPosMonth3Count != 0)? ((postPosMonth3PrometorsCount*100/postPosMonth3Count) - (postPosMonth3DetractorsCount*100/postPosMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month4 = (postPosMonth4Count != 0)? ((postPosMonth4PrometorsCount*100/postPosMonth4Count) - (postPosMonth4DetractorsCount*100/postPosMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month5 = (postPosMonth5Count != 0)? ((postPosMonth5PrometorsCount*100/postPosMonth5Count) - (postPosMonth5DetractorsCount*100/postPosMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month6 = (postPosMonth6Count != 0)? ((postPosMonth6PrometorsCount*100/postPosMonth6Count) - (postPosMonth6DetractorsCount*100/postPosMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month7 = (postPosMonth7Count != 0)? ((postPosMonth7PrometorsCount*100/postPosMonth7Count) - (postPosMonth7DetractorsCount*100/postPosMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month8 = (postPosMonth8Count != 0)? ((postPosMonth8PrometorsCount*100/postPosMonth8Count) - (postPosMonth8DetractorsCount*100/postPosMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month9 = (postPosMonth9Count != 0)? ((postPosMonth9PrometorsCount*100/postPosMonth9Count) - (postPosMonth9DetractorsCount*100/postPosMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month10 = (postPosMonth10Count != 0)? ((postPosMonth10PrometorsCount*100/postPosMonth10Count) - (postPosMonth10DetractorsCount*100/postPosMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month11 = (postPosMonth11Count != 0)? ((postPosMonth11PrometorsCount*100/postPosMonth11Count) - (postPosMonth11DetractorsCount*100/postPosMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            postPosScore.month12 = (postPosMonth12Count != 0)? ((postPosMonth12PrometorsCount*100/postPosMonth12Count) - (postPosMonth12DetractorsCount*100/postPosMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            
			
            scores.add(postPosScore);
        }
        
        
        npsScore totalScore = new npsScore();
        totalScore.fbType = 'Total';
        
        totalScore.month1 = ((salesExpMonth1Count + dayOfRegMonth1Count + dayOfPosMonth1Count + postPosMonth1Count) != 0)? (((salesExpMonth1PrometorsCount + dayOfRegMonth1PrometorsCount + dayOfPosMonth1PrometorsCount + postPosMonth1PrometorsCount)*100/(salesExpMonth1Count + dayOfRegMonth1Count + dayOfPosMonth1Count + postPosMonth1Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth1DetractorsCount + dayOfRegMonth1DetractorsCount + dayOfPosMonth1DetractorsCount + postPosMonth1DetractorsCount)*100/(salesExpMonth1Count + dayOfRegMonth1Count + dayOfPosMonth1Count + postPosMonth1Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month2 = ((salesExpMonth2Count + dayOfRegMonth2Count + dayOfPosMonth2Count + postPosMonth2Count) != 0)? (((salesExpMonth2PrometorsCount + dayOfRegMonth2PrometorsCount + dayOfPosMonth2PrometorsCount + postPosMonth2PrometorsCount)*100/(salesExpMonth2Count + dayOfRegMonth2Count + dayOfPosMonth2Count + postPosMonth2Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth2DetractorsCount + dayOfRegMonth2DetractorsCount + dayOfPosMonth2DetractorsCount + postPosMonth2DetractorsCount)*100/(salesExpMonth2Count + dayOfRegMonth2Count + dayOfPosMonth2Count + postPosMonth2Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month3 = ((salesExpMonth3Count + dayOfRegMonth3Count + dayOfPosMonth3Count + postPosMonth3Count) != 0)? (((salesExpMonth3PrometorsCount + dayOfRegMonth3PrometorsCount + dayOfPosMonth3PrometorsCount + postPosMonth3PrometorsCount)*100/(salesExpMonth3Count + dayOfRegMonth3Count + dayOfPosMonth3Count + postPosMonth3Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth3DetractorsCount + dayOfRegMonth3DetractorsCount + dayOfPosMonth3DetractorsCount + postPosMonth3DetractorsCount)*100/(salesExpMonth3Count + dayOfRegMonth3Count + dayOfPosMonth3Count + postPosMonth3Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month4 = ((salesExpMonth4Count + dayOfRegMonth4Count + dayOfPosMonth4Count + postPosMonth4Count) != 0)? (((salesExpMonth4PrometorsCount + dayOfRegMonth4PrometorsCount + dayOfPosMonth4PrometorsCount + postPosMonth4PrometorsCount)*100/(salesExpMonth4Count + dayOfRegMonth4Count + dayOfPosMonth4Count + postPosMonth4Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth4DetractorsCount + dayOfRegMonth4DetractorsCount + dayOfPosMonth4DetractorsCount + postPosMonth4DetractorsCount)*100/(salesExpMonth4Count + dayOfRegMonth4Count + dayOfPosMonth4Count + postPosMonth4Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month5 = ((salesExpMonth5Count + dayOfRegMonth5Count + dayOfPosMonth5Count + postPosMonth5Count) != 0)? (((salesExpMonth5PrometorsCount + dayOfRegMonth5PrometorsCount + dayOfPosMonth5PrometorsCount + postPosMonth5PrometorsCount)*100/(salesExpMonth5Count + dayOfRegMonth5Count + dayOfPosMonth5Count + postPosMonth5Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth5DetractorsCount + dayOfRegMonth5DetractorsCount + dayOfPosMonth5DetractorsCount + postPosMonth5DetractorsCount)*100/(salesExpMonth5Count + dayOfRegMonth5Count + dayOfPosMonth5Count + postPosMonth5Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month6 = ((salesExpMonth6Count + dayOfRegMonth6Count + dayOfPosMonth6Count + postPosMonth6Count) != 0)? (((salesExpMonth6PrometorsCount + dayOfRegMonth6PrometorsCount + dayOfPosMonth6PrometorsCount + postPosMonth6PrometorsCount)*100/(salesExpMonth6Count + dayOfRegMonth6Count + dayOfPosMonth6Count + postPosMonth6Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth6DetractorsCount + dayOfRegMonth6DetractorsCount + dayOfPosMonth6DetractorsCount + postPosMonth6DetractorsCount)*100/(salesExpMonth6Count + dayOfRegMonth6Count + dayOfPosMonth6Count + postPosMonth6Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month7 = ((salesExpMonth7Count + dayOfRegMonth7Count + dayOfPosMonth7Count + postPosMonth7Count) != 0)? (((salesExpMonth7PrometorsCount + dayOfRegMonth7PrometorsCount + dayOfPosMonth7PrometorsCount + postPosMonth7PrometorsCount)*100/(salesExpMonth7Count + dayOfRegMonth7Count + dayOfPosMonth7Count + postPosMonth7Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth7DetractorsCount + dayOfRegMonth7DetractorsCount + dayOfPosMonth7DetractorsCount + postPosMonth7DetractorsCount)*100/(salesExpMonth7Count + dayOfRegMonth7Count + dayOfPosMonth7Count + postPosMonth7Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month8 = ((salesExpMonth8Count + dayOfRegMonth8Count + dayOfPosMonth8Count + postPosMonth8Count) != 0)? (((salesExpMonth8PrometorsCount + dayOfRegMonth8PrometorsCount + dayOfPosMonth8PrometorsCount + postPosMonth8PrometorsCount)*100/(salesExpMonth8Count + dayOfRegMonth8Count + dayOfPosMonth8Count + postPosMonth8Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth8DetractorsCount + dayOfRegMonth8DetractorsCount + dayOfPosMonth8DetractorsCount + postPosMonth8DetractorsCount)*100/(salesExpMonth8Count + dayOfRegMonth8Count + dayOfPosMonth8Count + postPosMonth8Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month9 = ((salesExpMonth9Count + dayOfRegMonth9Count + dayOfPosMonth9Count + postPosMonth9Count) != 0)? (((salesExpMonth9PrometorsCount + dayOfRegMonth9PrometorsCount + dayOfPosMonth9PrometorsCount + postPosMonth9PrometorsCount)*100/(salesExpMonth9Count + dayOfRegMonth9Count + dayOfPosMonth9Count + postPosMonth9Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((salesExpMonth9DetractorsCount + dayOfRegMonth9DetractorsCount + dayOfPosMonth9DetractorsCount + postPosMonth9DetractorsCount)*100/(salesExpMonth9Count + dayOfRegMonth9Count + dayOfPosMonth9Count + postPosMonth9Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month10 = ((salesExpMonth10Count + dayOfRegMonth10Count + dayOfPosMonth10Count + postPosMonth10Count) != 0)? (((salesExpMonth10PrometorsCount + dayOfRegMonth10PrometorsCount + dayOfPosMonth10PrometorsCount + postPosMonth10PrometorsCount)*100/(salesExpMonth10Count + dayOfRegMonth10Count + dayOfPosMonth10Count + postPosMonth10Count)).setscale(0,RoundingMode.HALF_UP) - 
            				 ((salesExpMonth10DetractorsCount + dayOfRegMonth10DetractorsCount + dayOfPosMonth10DetractorsCount + postPosMonth10DetractorsCount)*100/(salesExpMonth10Count + dayOfRegMonth10Count + dayOfPosMonth10Count + postPosMonth10Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month11 = ((salesExpMonth11Count + dayOfRegMonth11Count + dayOfPosMonth11Count + postPosMonth11Count) != 0)? (((salesExpMonth11PrometorsCount + dayOfRegMonth11PrometorsCount + dayOfPosMonth11PrometorsCount + postPosMonth11PrometorsCount)*100/(salesExpMonth11Count + dayOfRegMonth11Count + dayOfPosMonth11Count + postPosMonth11Count)).setscale(0,RoundingMode.HALF_UP) - 
            				 ((salesExpMonth11DetractorsCount + dayOfRegMonth11DetractorsCount + dayOfPosMonth11DetractorsCount + postPosMonth11DetractorsCount)*100/(salesExpMonth11Count + dayOfRegMonth11Count + dayOfPosMonth11Count + postPosMonth11Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month12 = ((salesExpMonth12Count + dayOfRegMonth12Count + dayOfPosMonth12Count + postPosMonth12Count) != 0)? (((salesExpMonth12PrometorsCount + dayOfRegMonth12PrometorsCount + dayOfPosMonth12PrometorsCount + postPosMonth12PrometorsCount)*100/(salesExpMonth12Count + dayOfRegMonth12Count + dayOfPosMonth12Count + postPosMonth12Count)).setscale(0,RoundingMode.HALF_UP) - 
            				 ((salesExpMonth12DetractorsCount + dayOfRegMonth12DetractorsCount + dayOfPosMonth12DetractorsCount + postPosMonth12DetractorsCount)*100/(salesExpMonth12Count + dayOfRegMonth12Count + dayOfPosMonth12Count + postPosMonth12Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        
        
        scores.add(totalScore);
        System.debug('scores: ' + scores);
        return scores;
    }
    
    
    @auraEnabled
    public static List<npsScore> custInstSummaryForYear(String team){
        
        Date dt = System.today(); 
        Integer month = dt.Month(); 
        Integer year = dt.Year(); 
        Date lastYearDate = dt.addDays(-365);
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c  FROM WhatsApp_Feedback__c';
        String teamQry = teamQuery(team);
        
        if(team != null && team != ''){
            qry += ' WHERE ' + teamQry;   
        }
        qry += ' AND CreatedDate >=: lastYearDate';
        System.debug('qry: ' + qry);
        
        List<Integer> yearList = new List<Integer>();
        List<Integer> monthList = new List<Integer>();
        for(Integer i=0;i<12;i++){
            System.debug('Date: ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month());
            monthList.add(dt.addMonths(-i).Month());
            yearList.add(dt.addMonths(-i).Year());
        }
        
        //List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        if(!Test.isRunningTest()){
            fbList = Database.query(qry);
        }else{
            fbList = [SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c  FROM WhatsApp_Feedback__c LIMIT 10];
        }
        Map<String, Map<Decimal,Integer>> npsScores = new Map<String,Map<Decimal,Integer>>();
        Map<Decimal,Integer> caseClsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> caseClsPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> caseClsDetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> callDispCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> callDispPrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> callDispDetractorsCountMap = new Map<Decimal,Integer>();
        
        List<WhatsApp_Feedback__c> caseClsList = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> callDispList = new List<WhatsApp_Feedback__c>();
        
        for(WhatsApp_Feedback__c fb : fbList){
            if(fb.Feedback_Type__c == 'Case Closure'){
                caseClsList.add(fb);
            }else if(fb.Feedback_Type__c == 'Call Disposition'){
                callDispList.add(fb);
            }
        }
        
        for(WhatsApp_Feedback__c fb : caseClsList){
            if(caseClsCountMap.keySet().contains(fb.Month__c)){
                caseClsCountMap.put(fb.Month__c, caseClsCountMap.get(fb.Month__c)+1);
            }else{
                caseClsCountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(caseClsPrometorsCountMap.keySet().contains(fb.Month__c)){
                    caseClsPrometorsCountMap.put(fb.Month__c, caseClsPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    caseClsPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(caseClsDetractorsCountMap.keySet().contains(fb.Month__c)){
                    caseClsDetractorsCountMap.put(fb.Month__c, caseClsDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    caseClsDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : callDispList){
            if(callDispCountMap.keySet().contains(fb.Month__c)){
                callDispCountMap.put(fb.Month__c, callDispCountMap.get(fb.Month__c)+1);
            }else{
                callDispCountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(callDispPrometorsCountMap.keySet().contains(fb.Month__c)){
                    callDispPrometorsCountMap.put(fb.Month__c, callDispPrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    callDispPrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(callDispDetractorsCountMap.keySet().contains(fb.Month__c)){
                    callDispDetractorsCountMap.put(fb.Month__c, callDispDetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    callDispDetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        npsScores.put('Case Closure',caseClsCountMap);
        npsScores.put('Call Disposition',callDispCountMap);
        System.debug('npsScores: ' + npsScores);
        List<npsScore> scores = new List<npsScore>();
        
        npsScore yearDetails = new npsScore();
        yearDetails.fbType = 'Year';
        yearDetails.month1 = yearList[0];
        yearDetails.month2 = yearList[1];
        yearDetails.month3 = yearList[2];
        yearDetails.month4 = yearList[3];
        yearDetails.month5 = yearList[4];
        yearDetails.month6 = yearList[5];
        yearDetails.month7 = yearList[6];
        yearDetails.month8 = yearList[7];
        yearDetails.month9 = yearList[8];
        yearDetails.month10 = yearList[9];
        yearDetails.month11 = yearList[10];
        yearDetails.month12 = yearList[11];
        scores.add(yearDetails);
        
        npsScore monthDetails = new npsScore();
        monthDetails.fbType = 'Month';
        monthDetails.month1 = monthList[0];
        monthDetails.month2 = monthList[1];
        monthDetails.month3 = monthList[2];
        monthDetails.month4 = monthList[3];
        monthDetails.month5 = monthList[4];
        monthDetails.month6 = monthList[5];
        monthDetails.month7 = monthList[6];
        monthDetails.month8 = monthList[7];
        monthDetails.month9 = monthList[8];
        monthDetails.month10 = monthList[9];
        monthDetails.month11 = monthList[10];
        monthDetails.month12 = monthList[11];
        scores.add(monthDetails);
        
        Decimal caseClsMonth1Count = (caseClsCountMap.get(monthList[0]) != null)? caseClsCountMap.get(monthList[0]) : 0;
        Decimal caseClsMonth1PrometorsCount = (caseClsPrometorsCountMap.get(monthList[0]) != null)? caseClsPrometorsCountMap.get(monthList[0]) : 0;
        Decimal caseClsMonth1DetractorsCount = (caseClsDetractorsCountMap.get(monthList[0]) != null)? caseClsDetractorsCountMap.get(monthList[0]) : 0;
        Decimal caseClsMonth2Count = (caseClsCountMap.get(monthList[1]) != null)? caseClsCountMap.get(monthList[1]) : 0;
        Decimal caseClsMonth2PrometorsCount = (caseClsPrometorsCountMap.get(monthList[1]) != null)? caseClsPrometorsCountMap.get(monthList[1]) : 0;
        Decimal caseClsMonth2DetractorsCount = (caseClsDetractorsCountMap.get(monthList[1]) != null)? caseClsDetractorsCountMap.get(monthList[1]) : 0;
        Decimal caseClsMonth3Count = (caseClsCountMap.get(monthList[2]) != null)? caseClsCountMap.get(monthList[2]) : 0;
        Decimal caseClsMonth3PrometorsCount = (caseClsPrometorsCountMap.get(monthList[2]) != null)? caseClsPrometorsCountMap.get(monthList[2]) : 0;
        Decimal caseClsMonth3DetractorsCount = (caseClsDetractorsCountMap.get(monthList[2]) != null)? caseClsDetractorsCountMap.get(monthList[2]) : 0;
        Decimal caseClsMonth4Count = (caseClsCountMap.get(monthList[3]) != null)? caseClsCountMap.get(monthList[3]) : 0;
        Decimal caseClsMonth4PrometorsCount = (caseClsPrometorsCountMap.get(monthList[3]) != null)? caseClsPrometorsCountMap.get(monthList[3]) : 0;
        Decimal caseClsMonth4DetractorsCount = (caseClsDetractorsCountMap.get(monthList[3]) != null)? caseClsDetractorsCountMap.get(monthList[3]) : 0;
        Decimal caseClsMonth5Count = (caseClsCountMap.get(monthList[4]) != null)? caseClsCountMap.get(monthList[4]) : 0;
        Decimal caseClsMonth5PrometorsCount = (caseClsPrometorsCountMap.get(monthList[4]) != null)? caseClsPrometorsCountMap.get(monthList[4]) : 0;
        Decimal caseClsMonth5DetractorsCount = (caseClsDetractorsCountMap.get(monthList[4]) != null)? caseClsDetractorsCountMap.get(monthList[4]) : 0;
        Decimal caseClsMonth6Count = (caseClsCountMap.get(monthList[5]) != null)? caseClsCountMap.get(monthList[5]) : 0;
        Decimal caseClsMonth6PrometorsCount = (caseClsPrometorsCountMap.get(monthList[5]) != null)? caseClsPrometorsCountMap.get(monthList[5]) : 0;
        Decimal caseClsMonth6DetractorsCount = (caseClsDetractorsCountMap.get(monthList[5]) != null)? caseClsDetractorsCountMap.get(monthList[5]) : 0;
        Decimal caseClsMonth7Count = (caseClsCountMap.get(monthList[6]) != null)? caseClsCountMap.get(monthList[6]) : 0;
        Decimal caseClsMonth7PrometorsCount = (caseClsPrometorsCountMap.get(monthList[6]) != null)? caseClsPrometorsCountMap.get(monthList[6]) : 0;
        Decimal caseClsMonth7DetractorsCount = (caseClsDetractorsCountMap.get(monthList[6]) != null)? caseClsDetractorsCountMap.get(monthList[6]) : 0;
        Decimal caseClsMonth8Count = (caseClsCountMap.get(monthList[7]) != null)? caseClsCountMap.get(monthList[7]) : 0;
        Decimal caseClsMonth8PrometorsCount = (caseClsPrometorsCountMap.get(monthList[7]) != null)? caseClsPrometorsCountMap.get(monthList[7]) : 0;
        Decimal caseClsMonth8DetractorsCount = (caseClsDetractorsCountMap.get(monthList[7]) != null)? caseClsDetractorsCountMap.get(monthList[7]) : 0;
        Decimal caseClsMonth9Count = (caseClsCountMap.get(monthList[8]) != null)? caseClsCountMap.get(monthList[8]) : 0;
        Decimal caseClsMonth9PrometorsCount = (caseClsPrometorsCountMap.get(monthList[8]) != null)? caseClsPrometorsCountMap.get(monthList[8]) : 0;
        Decimal caseClsMonth9DetractorsCount = (caseClsDetractorsCountMap.get(monthList[8]) != null)? caseClsDetractorsCountMap.get(monthList[8]) : 0;
        Decimal caseClsMonth10Count = (caseClsCountMap.get(monthList[9]) != null)? caseClsCountMap.get(monthList[9]) : 0;
        Decimal caseClsMonth10PrometorsCount = (caseClsPrometorsCountMap.get(monthList[9]) != null)? caseClsPrometorsCountMap.get(monthList[9]) : 0;
        Decimal caseClsMonth10DetractorsCount = (caseClsDetractorsCountMap.get(monthList[9]) != null)? caseClsDetractorsCountMap.get(monthList[9]) : 0;
        Decimal caseClsMonth11Count = (caseClsCountMap.get(monthList[10]) != null)? caseClsCountMap.get(monthList[10]) : 0;
        Decimal caseClsMonth11PrometorsCount = (caseClsPrometorsCountMap.get(monthList[10]) != null)? caseClsPrometorsCountMap.get(monthList[10]) : 0;
        Decimal caseClsMonth11DetractorsCount = (caseClsDetractorsCountMap.get(monthList[10]) != null)? caseClsDetractorsCountMap.get(monthList[10]) : 0;
        Decimal caseClsMonth12Count = (caseClsCountMap.get(monthList[11]) != null)? caseClsCountMap.get(monthList[11]) : 0;
        Decimal caseClsMonth12PrometorsCount = (caseClsPrometorsCountMap.get(monthList[11]) != null)? caseClsPrometorsCountMap.get(monthList[11]) : 0;
        Decimal caseClsMonth12DetractorsCount = (caseClsDetractorsCountMap.get(monthList[11]) != null)? caseClsDetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal callDispMonth1Count = (callDispCountMap.get(monthList[0]) != null)? callDispCountMap.get(monthList[0]) : 0;
        Decimal callDispMonth1PrometorsCount = (callDispPrometorsCountMap.get(monthList[0]) != null)? callDispPrometorsCountMap.get(monthList[0]) : 0;
        Decimal callDispMonth1DetractorsCount = (callDispDetractorsCountMap.get(monthList[0]) != null)? callDispDetractorsCountMap.get(monthList[0]) : 0;
        Decimal callDispMonth2Count = (callDispCountMap.get(monthList[1]) != null)? callDispCountMap.get(monthList[1]) : 0;
        Decimal callDispMonth2PrometorsCount = (callDispPrometorsCountMap.get(monthList[1]) != null)? callDispPrometorsCountMap.get(monthList[1]) : 0;
        Decimal callDispMonth2DetractorsCount = (callDispDetractorsCountMap.get(monthList[1]) != null)? callDispDetractorsCountMap.get(monthList[1]) : 0;
        Decimal callDispMonth3Count = (callDispCountMap.get(monthList[2]) != null)? callDispCountMap.get(monthList[2]) : 0;
        Decimal callDispMonth3PrometorsCount = (callDispPrometorsCountMap.get(monthList[2]) != null)? callDispPrometorsCountMap.get(monthList[2]) : 0;
        Decimal callDispMonth3DetractorsCount = (callDispDetractorsCountMap.get(monthList[2]) != null)? callDispDetractorsCountMap.get(monthList[2]) : 0;
        Decimal callDispMonth4Count = (callDispCountMap.get(monthList[3]) != null)? callDispCountMap.get(monthList[3]) : 0;
        Decimal callDispMonth4PrometorsCount = (callDispPrometorsCountMap.get(monthList[3]) != null)? callDispPrometorsCountMap.get(monthList[3]) : 0;
        Decimal callDispMonth4DetractorsCount = (callDispDetractorsCountMap.get(monthList[3]) != null)? callDispDetractorsCountMap.get(monthList[3]) : 0;
        Decimal callDispMonth5Count = (callDispCountMap.get(monthList[4]) != null)? callDispCountMap.get(monthList[4]) : 0;
        Decimal callDispMonth5PrometorsCount = (callDispPrometorsCountMap.get(monthList[4]) != null)? callDispPrometorsCountMap.get(monthList[4]) : 0;
        Decimal callDispMonth5DetractorsCount = (callDispDetractorsCountMap.get(monthList[4]) != null)? callDispDetractorsCountMap.get(monthList[4]) : 0;
        Decimal callDispMonth6Count = (callDispCountMap.get(monthList[5]) != null)? callDispCountMap.get(monthList[5]) : 0;
        Decimal callDispMonth6PrometorsCount = (callDispPrometorsCountMap.get(monthList[5]) != null)? callDispPrometorsCountMap.get(monthList[5]) : 0;
        Decimal callDispMonth6DetractorsCount = (callDispDetractorsCountMap.get(monthList[5]) != null)? callDispDetractorsCountMap.get(monthList[5]) : 0;
        Decimal callDispMonth7Count = (callDispCountMap.get(monthList[6]) != null)? callDispCountMap.get(monthList[6]) : 0;
        Decimal callDispMonth7PrometorsCount = (callDispPrometorsCountMap.get(monthList[6]) != null)? callDispPrometorsCountMap.get(monthList[6]) : 0;
        Decimal callDispMonth7DetractorsCount = (callDispDetractorsCountMap.get(monthList[6]) != null)? callDispDetractorsCountMap.get(monthList[6]) : 0;
        Decimal callDispMonth8Count = (callDispCountMap.get(monthList[7]) != null)? callDispCountMap.get(monthList[7]) : 0;
        Decimal callDispMonth8PrometorsCount = (callDispPrometorsCountMap.get(monthList[7]) != null)? callDispPrometorsCountMap.get(monthList[7]) : 0;
        Decimal callDispMonth8DetractorsCount = (callDispDetractorsCountMap.get(monthList[7]) != null)? callDispDetractorsCountMap.get(monthList[7]) : 0;
        Decimal callDispMonth9Count = (callDispCountMap.get(monthList[8]) != null)? callDispCountMap.get(monthList[8]) : 0;
        Decimal callDispMonth9PrometorsCount = (callDispPrometorsCountMap.get(monthList[8]) != null)? callDispPrometorsCountMap.get(monthList[8]) : 0;
        Decimal callDispMonth9DetractorsCount = (callDispDetractorsCountMap.get(monthList[8]) != null)? callDispDetractorsCountMap.get(monthList[8]) : 0;
        Decimal callDispMonth10Count = (callDispCountMap.get(monthList[9]) != null)? callDispCountMap.get(monthList[9]) : 0;
        Decimal callDispMonth10PrometorsCount = (callDispPrometorsCountMap.get(monthList[9]) != null)? callDispPrometorsCountMap.get(monthList[9]) : 0;
        Decimal callDispMonth10DetractorsCount = (callDispDetractorsCountMap.get(monthList[9]) != null)? callDispDetractorsCountMap.get(monthList[9]) : 0;
        Decimal callDispMonth11Count = (callDispCountMap.get(monthList[10]) != null)? callDispCountMap.get(monthList[10]) : 0;
        Decimal callDispMonth11PrometorsCount = (callDispPrometorsCountMap.get(monthList[10]) != null)? callDispPrometorsCountMap.get(monthList[10]) : 0;
        Decimal callDispMonth11DetractorsCount = (callDispDetractorsCountMap.get(monthList[10]) != null)? callDispDetractorsCountMap.get(monthList[10]) : 0;
        Decimal callDispMonth12Count = (callDispCountMap.get(monthList[11]) != null)? callDispCountMap.get(monthList[11]) : 0;
        Decimal callDispMonth12PrometorsCount = (callDispPrometorsCountMap.get(monthList[11]) != null)? callDispPrometorsCountMap.get(monthList[11]) : 0;
        Decimal callDispMonth12DetractorsCount = (callDispDetractorsCountMap.get(monthList[11]) != null)? callDispDetractorsCountMap.get(monthList[11]) : 0;
        
        npsScore callDispScore = new npsScore();
        callDispScore.fbType = 'Call Disposition';
        
        callDispScore.month1 = (callDispMonth1Count != 0)? ((callDispMonth1PrometorsCount*100/callDispMonth1Count) - (callDispMonth1DetractorsCount*100/callDispMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month2 = (callDispMonth2Count != 0)? ((callDispMonth2PrometorsCount*100/callDispMonth2Count) - (callDispMonth2DetractorsCount*100/callDispMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month3 = (callDispMonth3Count != 0)? ((callDispMonth3PrometorsCount*100/callDispMonth3Count) - (callDispMonth3DetractorsCount*100/callDispMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month4 = (callDispMonth4Count != 0)? ((callDispMonth4PrometorsCount*100/callDispMonth4Count) - (callDispMonth4DetractorsCount*100/callDispMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month5 = (callDispMonth5Count != 0)? ((callDispMonth5PrometorsCount*100/callDispMonth5Count) - (callDispMonth5DetractorsCount*100/callDispMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month6 = (callDispMonth6Count != 0)? ((callDispMonth6PrometorsCount*100/callDispMonth6Count) - (callDispMonth6DetractorsCount*100/callDispMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month7 = (callDispMonth7Count != 0)? ((callDispMonth7PrometorsCount*100/callDispMonth7Count) - (callDispMonth7DetractorsCount*100/callDispMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month8 = (callDispMonth8Count != 0)? ((callDispMonth8PrometorsCount*100/callDispMonth8Count) - (callDispMonth8DetractorsCount*100/callDispMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month9 = (callDispMonth9Count != 0)? ((callDispMonth9PrometorsCount*100/callDispMonth9Count) - (callDispMonth9DetractorsCount*100/callDispMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month10 = (callDispMonth10Count != 0)? ((callDispMonth10PrometorsCount*100/callDispMonth10Count) - (callDispMonth10DetractorsCount*100/callDispMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month11 = (callDispMonth11Count != 0)? ((callDispMonth11PrometorsCount*100/callDispMonth11Count) - (callDispMonth11DetractorsCount*100/callDispMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        callDispScore.month12 = (callDispMonth12Count != 0)? ((callDispMonth12PrometorsCount*100/callDispMonth12Count) - (callDispMonth12DetractorsCount*100/callDispMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        scores.add(callDispScore);
        
        npsScore caseClsScore = new npsScore();
        caseClsScore.fbType = 'Case Closure';
        caseClsScore.month1 = (caseClsMonth1Count != 0)? ((caseClsMonth1PrometorsCount*100/caseClsMonth1Count) - (caseClsMonth1DetractorsCount*100/caseClsMonth1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month2 = (caseClsMonth2Count != 0)? ((caseClsMonth2PrometorsCount*100/caseClsMonth2Count) - (caseClsMonth2DetractorsCount*100/caseClsMonth2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month3 = (caseClsMonth3Count != 0)? ((caseClsMonth3PrometorsCount*100/caseClsMonth3Count) - (caseClsMonth3DetractorsCount*100/caseClsMonth3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month4 = (caseClsMonth4Count != 0)? ((caseClsMonth4PrometorsCount*100/caseClsMonth4Count) - (caseClsMonth4DetractorsCount*100/caseClsMonth4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month5 = (caseClsMonth5Count != 0)? ((caseClsMonth5PrometorsCount*100/caseClsMonth5Count) - (caseClsMonth5DetractorsCount*100/caseClsMonth5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month6 = (caseClsMonth6Count != 0)? ((caseClsMonth6PrometorsCount*100/caseClsMonth6Count) - (caseClsMonth6DetractorsCount*100/caseClsMonth6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month7 = (caseClsMonth7Count != 0)? ((caseClsMonth7PrometorsCount*100/caseClsMonth7Count) - (caseClsMonth7DetractorsCount*100/caseClsMonth7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month8 = (caseClsMonth8Count != 0)? ((caseClsMonth8PrometorsCount*100/caseClsMonth8Count) - (caseClsMonth8DetractorsCount*100/caseClsMonth8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month9 = (caseClsMonth9Count != 0)? ((caseClsMonth9PrometorsCount*100/caseClsMonth9Count) - (caseClsMonth9DetractorsCount*100/caseClsMonth9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month10 = (caseClsMonth10Count != 0)? ((caseClsMonth10PrometorsCount*100/caseClsMonth10Count) - (caseClsMonth10DetractorsCount*100/caseClsMonth10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month11 = (caseClsMonth11Count != 0)? ((caseClsMonth11PrometorsCount*100/caseClsMonth11Count) - (caseClsMonth11DetractorsCount*100/caseClsMonth11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        caseClsScore.month12 = (caseClsMonth12Count != 0)? ((caseClsMonth12PrometorsCount*100/caseClsMonth12Count) - (caseClsMonth12DetractorsCount*100/caseClsMonth12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
        scores.add(caseClsScore);
        
        
        
        npsScore totalScore = new npsScore();
        totalScore.fbType = 'Total';
        
        totalScore.month1 = ((caseClsMonth1Count + callDispMonth1Count) != 0)? (((caseClsMonth1PrometorsCount + callDispMonth1PrometorsCount)*100/(caseClsMonth1Count + callDispMonth1Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth1DetractorsCount + callDispMonth1DetractorsCount)*100/(caseClsMonth1Count + callDispMonth1Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month2 = ((caseClsMonth2Count + callDispMonth2Count) != 0)? (((caseClsMonth2PrometorsCount + callDispMonth2PrometorsCount)*100/(caseClsMonth2Count + callDispMonth2Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth2DetractorsCount + callDispMonth2DetractorsCount)*100/(caseClsMonth2Count + callDispMonth2Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month3 = ((caseClsMonth3Count + callDispMonth3Count) != 0)? (((caseClsMonth3PrometorsCount + callDispMonth3PrometorsCount)*100/(caseClsMonth3Count + callDispMonth3Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth3DetractorsCount + callDispMonth3DetractorsCount)*100/(caseClsMonth3Count + callDispMonth3Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month4 = ((caseClsMonth4Count + callDispMonth4Count) != 0)? (((caseClsMonth4PrometorsCount + callDispMonth4PrometorsCount)*100/(caseClsMonth4Count + callDispMonth4Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth4DetractorsCount + callDispMonth4DetractorsCount)*100/(caseClsMonth4Count + callDispMonth4Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month5 = ((caseClsMonth5Count + callDispMonth5Count) != 0)? (((caseClsMonth5PrometorsCount + callDispMonth5PrometorsCount)*100/(caseClsMonth5Count + callDispMonth5Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth5DetractorsCount + callDispMonth5DetractorsCount)*100/(caseClsMonth5Count + callDispMonth5Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month6 = ((caseClsMonth6Count + callDispMonth6Count) != 0)? (((caseClsMonth6PrometorsCount + callDispMonth6PrometorsCount)*100/(caseClsMonth6Count + callDispMonth6Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth6DetractorsCount + callDispMonth6DetractorsCount)*100/(caseClsMonth6Count + callDispMonth6Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month7 = ((caseClsMonth7Count + callDispMonth7Count) != 0)? (((caseClsMonth7PrometorsCount + callDispMonth7PrometorsCount)*100/(caseClsMonth7Count + callDispMonth7Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth7DetractorsCount + callDispMonth7DetractorsCount)*100/(caseClsMonth7Count + callDispMonth7Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month8 = ((caseClsMonth8Count + callDispMonth8Count) != 0)? (((caseClsMonth8PrometorsCount + callDispMonth8PrometorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth8DetractorsCount + callDispMonth8DetractorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month9 = ((caseClsMonth9Count + callDispMonth9Count) != 0)? (((caseClsMonth9PrometorsCount + callDispMonth9PrometorsCount)*100/(caseClsMonth9Count + callDispMonth9Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth9DetractorsCount + callDispMonth9DetractorsCount)*100/(caseClsMonth9Count + callDispMonth9Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month10 = ((caseClsMonth10Count + callDispMonth10Count) != 0)? (((caseClsMonth10PrometorsCount + callDispMonth10PrometorsCount)*100/(caseClsMonth10Count + callDispMonth10Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth10DetractorsCount + callDispMonth10DetractorsCount)*100/(caseClsMonth10Count + callDispMonth10Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month11 = ((caseClsMonth11Count + callDispMonth11Count) != 0)? (((caseClsMonth11PrometorsCount + callDispMonth11PrometorsCount)*100/(caseClsMonth11Count + callDispMonth11Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth11DetractorsCount + callDispMonth11DetractorsCount)*100/(caseClsMonth11Count + callDispMonth11Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month12 = ((caseClsMonth12Count + callDispMonth12Count) != 0)? (((caseClsMonth12PrometorsCount + callDispMonth12PrometorsCount)*100/(caseClsMonth12Count + callDispMonth12Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((caseClsMonth12DetractorsCount + callDispMonth12DetractorsCount)*100/(caseClsMonth12Count + callDispMonth12Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        
       /* System.debug('caseClsMonth8PrometorsCount: ' + caseClsMonth8PrometorsCount);
        System.debug('callDispMonth8PrometorsCount: ' + callDispMonth8PrometorsCount);
        System.debug('caseClsMonth8DetractorsCount: ' + caseClsMonth8DetractorsCount);
        System.debug('callDispMonth8DetractorsCount: ' + callDispMonth8DetractorsCount);
        System.debug('caseClsMonth8Count: ' + caseClsMonth8Count);
        System.debug('callDispMonth8Count: ' + callDispMonth8Count);
        system.debug('caseClsMonth8PrometorsCount'+caseClsMonth8PrometorsCount);
        system.debug('caseClsMonth8Count'+caseClsMonth8Count);
        System.debug('--pro: ' + ((caseClsMonth8PrometorsCount + callDispMonth8PrometorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)).setscale(0,RoundingMode.HALF_UP));
        System.debug('--pro: ' + ((caseClsMonth8PrometorsCount + callDispMonth8PrometorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)));
        System.debug('--pro: ' + (caseClsMonth8PrometorsCount + callDispMonth8PrometorsCount)*100/(caseClsMonth8Count + callDispMonth8Count));
        System.debug('--Detr: ' + ((caseClsMonth8DetractorsCount + callDispMonth8DetractorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)));
        System.debug('--Detr: ' + ((caseClsMonth8DetractorsCount + callDispMonth8DetractorsCount)*100/(caseClsMonth8Count + callDispMonth8Count)).setscale(0,RoundingMode.HALF_UP));
		*/
        /*totalScore.month1 = (caseClsScore.month1 + callDispScore.month1)/2;
        totalScore.month2 = (caseClsScore.month2 + callDispScore.month2)/2;
        totalScore.month3 = (caseClsScore.month3 + callDispScore.month3)/2;
        totalScore.month4 = (caseClsScore.month4 + callDispScore.month4)/2;
        totalScore.month5 = (caseClsScore.month5 + callDispScore.month5)/2;
        totalScore.month6 = (caseClsScore.month6 + callDispScore.month6)/2;
        totalScore.month7 = (caseClsScore.month7 + callDispScore.month7)/2;
        totalScore.month8 = (caseClsScore.month8 + callDispScore.month8)/2;
        totalScore.month9 = (caseClsScore.month9 + callDispScore.month9)/2;
        totalScore.month10 = (caseClsScore.month10 + callDispScore.month10)/2;
        totalScore.month11 = (caseClsScore.month11 + callDispScore.month11)/2;
        totalScore.month12 = (caseClsScore.month12 + callDispScore.month12)/2;*/
        scores.add(totalScore);
        System.debug('scores: ' + scores);
        return scores;
    }    
    @AuraEnabled(cacheable=true)
    public static List<ProjectFeedbackWrapper> getProjectFeedback(String period,String Year,String Month) {
         Id CustomerFeedbackId= Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
         Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();

         String feedbackTeam = '';
         User currentUser = [SELECT Id, Feedback_Team__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
          if(currentUser != null && currentUser.Feedback_Team__c != null) {
            feedbackTeam = currentUser.Feedback_Team__c;
        }
        String team=Caseteam(feedbackTeam);
        System.debug(team);

        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        
        String querynew;
        List<ProjectFeedbackWrapper> feedbackList = new List<ProjectFeedbackWrapper>();
        Map<String, Map<String, Integer>> RmProjectCase =new Map<String, Map<String, Integer>>();
        // Map<String,Integer> RmCaseCount= New Map<String,Integer>();
        if(String.IsNotBlank(period))
        {
            System.debug('period not blank  :: ' + period);
            if(period=='Custom' && String.IsNotBlank(Year) && String.IsNotBlank(Month))
            {
                System.debug('period not blank 1 :: ' + period);
               querynew = 'SELECT COUNT(Id) cnt, RW_RM_Name__c,Last_Closed_Date__c, RW_Project__r.Name prname FROM Case WHERE CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year + ' AND CALENDAR_MONTH(ClosedDate) = ' + Month +' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') ' +' GROUP BY RW_Project__r.Name, RW_RM_Name__c';
                System.debug(querynew);
            }
            else if(period=='Custom' && String.IsBlank(Year) && String.IsBlank(Month))
            {
               System.debug('period not blank 2 :: ' + period);
                querynew='SELECT COUNT(Id) cnt, RW_RM_Name__c, RW_Project__r.Name prname ' +
                   'FROM Case ' +
                   'WHERE RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') ' +
                   'GROUP BY RW_Project__r.Name, RW_RM_Name__c';

                 System.debug(querynew);
           }else if(period=='Custom' && String.IsNotBlank(Year) && String.IsBlank(Month))
            {
                System.debug('period not blank 1 :: ' + period);
               querynew = 'SELECT COUNT(Id) cnt, RW_RM_Name__c, RW_Project__r.Name prname FROM Case WHERE CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year +' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') ' +' GROUP BY RW_Project__r.Name, RW_RM_Name__c';
                  System.debug(querynew);
            }
            else
            {
                System.debug('period not blank 3 :: ' + period);
                querynew='select Count(Id) cnt,RW_RM_Name__c,RW_Project__r.Name prname from case Where Last_Closed_Date__c='+period+' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') '+' Group by RW_Project__r.Name, RW_RM_Name__c';
                  System.debug('querynew::::'+querynew);
            }
        }
        else
        {
            querynew='SELECT COUNT(Id) cnt, RW_RM_Name__c, RW_Project__r.Name prname ' +
                   'FROM Case ' +
                   'WHERE RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') ' +
                   'GROUP BY RW_Project__r.Name, RW_RM_Name__c';

            
        }
        For(AggregateResult agr : database.query(querynew))
        {
            //RmCaseCount.put((String)agr.get('RW_RM_Name__c'),(Integer)agr.get('cnt'));
            String RMName = (String)agr.get('RW_RM_Name__c');
            String projectKey = (String)agr.get('prname');
            if (!RmProjectCase.containsKey(RMName)) {
                RmProjectCase.put(RMName,new Map<String, Integer>());
            }
            if (!RmProjectCase.get(RMName).containsKey(projectKey)) {
                RmProjectCase.get(RMName).put(projectKey, 0);
            }
            RmProjectCase.get(RMName).put(projectKey,(Integer)agr.get('cnt'));
            
        }
        System.debug('RmProjectCase'+RmProjectCase);
        // Query cases with feedback ratings
        String FeedbackQuery;
        if(String.IsBlank(period))
        {
            FeedbackQuery ='SELECT Id, Current_Stage__c, RW_Project__r.Name, RW_Project__c, Origin, RecordTypeId, ' +
                'CaseNumber, Subject, Ageing__c, OwnerId, Status, RW_Project__r.Name, CreatedDate, ' +
                'Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, ' +
                'CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c ' +
                'FROM Case ' +
                'WHERE RW_Project__c != null ' +
                'AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\')';
        }
        else
        {
          if(period=='Custom' && String.IsNotBlank(Year) && String.IsNotBlank(Month))
          {
            FeedbackQuery ='select id,Current_Stage__c,RW_Project__c,Origin,RecordTypeId,CaseNumber, Subject, Ageing__c,ownerId, Status, RW_Project__r.Name, CreatedDate, Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c  FROM Case  WHERE CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year + ' AND CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month +' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') '+ ' AND RW_Project__c != null ';
          }
            else if(period=='Custom' && String.IsBlank(Year) && String.IsBlank(Month))
            {
         FeedbackQuery ='select id,Current_Stage__c,RW_Project__r.Name,RW_Project__c,Origin,RecordTypeId,CaseNumber, Subject, Ageing__c,ownerId, Status, RW_Project__r.Name, CreatedDate, Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c  FROM Case  WHERE  RW_Project__c != null ';
 
            }
            else if(period=='Custom' && String.IsNotBlank(Year) && String.IsBlank(Month))
            {
            FeedbackQuery ='select id,Current_Stage__c,RW_Project__c,Origin,RecordTypeId,CaseNumber, Subject, Ageing__c,ownerId, Status, RW_Project__r.Name, CreatedDate, Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c FROM Case  WHERE CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year +' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') '+ '  AND RW_Project__c != null';

            }
            else if(period=='Custom' && String.IsBlank(Year) && String.IsNotBlank(Month))
            {
            FeedbackQuery ='select id,Current_Stage__c,RW_Project__c,Origin,RecordTypeId,CaseNumber, Subject, Ageing__c,ownerId, Status, RW_Project__r.Name, CreatedDate, Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c FROM Case  WHERE  CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month +' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') '+ ' AND RW_Project__c != null ';

            }
            else
            {
            FeedbackQuery ='select id,Current_Stage__c,RW_Project__c,Origin,RecordTypeId,CaseNumber, Subject, Ageing__c,ownerId, Status, RW_Project__r.Name, CreatedDate, Account.Name, LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c  FROM Case  WHERE  Last_Closed_Date__c='+period+' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') '+ ' AND RW_Project__c != null ';

            }
        }
       FeedbackQuery += ' AND Status IN (\'Reopened\', \'Case closed\')';
        List<Case> clist =  database.query(FeedbackQuery);
          system.debug('clist::'+clist);
        // Map to store feedback counts for each project and RM
        Map<String, Map<String, Map<String, Integer>>> projectRMMap = new Map<String, Map<String, Map<String, Integer>>>();
        
        // Iterate through cases to aggregate feedback counts
        for (Case c : clist) {
            String project = c.RW_Project__r.Name;
            String rmName = c.RW_RM_Name__c;
            System.debug('Case Status:::'+c.Status);
            // Initialize project map if not exists
            if (!projectRMMap.containsKey(project)) {
                projectRMMap.put(project, new Map<String, Map<String, Integer>>());
            }
            
            Map<String, Map<String, Integer>> rmMap = projectRMMap.get(project);
            
            // Initialize RM map if not exists
            if (!rmMap.containsKey(rmName)) {
                rmMap.put(rmName, new Map<String, Integer>{'totalInteractions' => 0, 'totalHappy' => 0, 'totalUnhappy' => 0, 'totalFair' => 0,'totalReopened'=>0});
            }
            
            Map<String, Integer> rmFeedbackMap = rmMap.get(rmName);
            
            // Update feedback counts based on feedback rating
            Integer totalInteractions = rmFeedbackMap.get('totalInteractions') + 1;
            Integer totalHappy = rmFeedbackMap.get('totalHappy');
            Integer totalUnhappy = rmFeedbackMap.get('totalUnhappy');
            Integer totalFair = rmFeedbackMap.get('totalFair');
            Integer totalReopened=rmFeedbackMap.get('totalReopened');
            
            if (c.CSAT_Feedback_Rating__c == 'Happy') {
                totalHappy++;
            } else if (c.CSAT_Feedback_Rating__c == 'Unhappy') {
                totalUnhappy++;
            } else if (c.CSAT_Feedback_Rating__c == 'Fair') {
                totalFair++;
            }
            if(c.Status=='Reopened')
            {
               totalReopened++ ;
            }
            totalInteractions=totalHappy+totalUnhappy+totalFair;
            // Update RM feedback counts
            rmFeedbackMap.put('totalInteractions', totalInteractions);
            rmFeedbackMap.put('totalHappy', totalHappy);
            rmFeedbackMap.put('totalUnhappy', totalUnhappy);
            rmFeedbackMap.put('totalFair', totalFair);
            rmFeedbackMap.put('totalReopened',totalReopened);
            
            // Update RM map and project map
            rmMap.put(rmName, rmFeedbackMap);
            projectRMMap.put(project, rmMap);
        }
        system.debug('projectRMMap'+projectRMMap);
        // Construct feedbackList from projectRMMap
        for (String project : projectRMMap.keySet()) {
            Map<String, Map<String, Integer>> rmMap = projectRMMap.get(project);
            for (String rmName : rmMap.keySet()) {
                Map<String, Integer> rmFeedbackMap = rmMap.get(rmName);
                feedbackList.add(new ProjectFeedbackWrapper(
                    project,
                    rmName,
                    RmProjectCase.get(rmName).get(project),
                    rmFeedbackMap.get('totalInteractions'),
                    rmFeedbackMap.get('totalHappy'),
                    rmFeedbackMap.get('totalUnhappy'),
                    rmFeedbackMap.get('totalFair'),
                    rmFeedbackMap.get('totalReopened'),
                    clist
                    
                ));
            }
        }
        
        return feedbackList;
      
    }
    
    
    

    @AuraEnabled(cacheable=true)
    public static List<Case> getFilteredCases(String data,String period,String Year,String Month) {
        Id CustomerFeedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        Id CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        map<string,object> unpack = (map<string,object>) JSON.deserializeUntyped(data);
        String query='';
        System.debug(unpack.get('Project Name'));
        
        List<Case> filteredCases = new List<Case>();
        if(String.isNotBlank(String.valueOf(unpack.get('Total case'))))
        {
            query = 'SELECT Id,Ageing__c,ownerId,Tower__c,Unit_Name__c,RecordType.Name,RecordTypeId,CSAT_Feedback_Rating__c,CSAT_Feedback_Remark__c,RW_RM_Name__c, CaseNumber,CreatedDate, Last_Closed_Date__c,RW_Project__r.Name,Subject, Status, Owner.Name, ClosedDate FROM Case WHERE ';
            if (String.isNotBlank(String.valueOf(unpack.get('Project Name')))) {
                query += '  RW_Project__r.Name = \'' + String.valueOf(unpack.get('Project Name')) + '\'';
            }
            if (String.isNotBlank(String.valueOf(unpack.get('RM Name')))) {
                query += ' AND RW_RM_Name__c = \'' + String.valueOf(unpack.get('RM Name')) + '\'';
            }
            if (String.isNotBlank(period)) {
                
                if(period=='Custom')
                {
                    if(String.isNotBlank(Month) && String.isNotBlank(Year))
                    {
                   query += ' AND CALENDAR_YEAR(Last_Closed_Date__c) =' + Year + ' AND CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month ;
  
                    }
                   if(String.isBlank(Month) && String.isNotBlank(Year))
                   {
                   query += ' AND CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year;
                 
                   }
                     if(String.isBlank(Year) && String.isNotBlank(Month))
                   {
                   query += ' AND CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month ;
                 
                   }
                    else
                    {
                   query += ' ';
   
                    }
                }
                else
                {
               query += ' AND Last_Closed_Date__c = ' + period ;

                }
            }
            
            System.debug('query :: '+query);
            
        }
        else
        {
            query = 'SELECT Id,Ageing__c,Tower__c,Unit_Name__c,Last_Closed_Date__c,ownerId,RecordType.Name,RecordTypeId,CSAT_Feedback_Rating__c,CSAT_Feedback_Remark__c,RW_RM_Name__c, CaseNumber,CreatedDate, RW_Project__r.Name,Subject, Status, Owner.Name, ClosedDate FROM Case WHERE CSAT_Feedback_Rating__c != null';
            if (String.isNotBlank(String.valueOf(unpack.get('Project Name')))) {
                query += ' AND RW_Project__r.Name = \'' + String.valueOf(unpack.get('Project Name')) + '\'';
            }
            if (String.isNotBlank(String.valueOf(unpack.get('RM Name')))) {
                query += ' AND RW_RM_Name__c = \'' + String.valueOf(unpack.get('RM Name')) + '\'';
            }
            if (String.isNotBlank(String.valueOf(unpack.get('Status')))) {
                if(String.valueOf(unpack.get('Status'))!='Reopened')
                {
                query += ' AND CSAT_Feedback_Rating__c = \'' + String.valueOf(unpack.get('Status')) + '\'';
                }
                else
                {
                  query += ' AND Status = \'' + String.valueOf(unpack.get('Status')) + '\'';  
                }
            }
            if (String.isNotBlank(period)) {
               
                if(period=='Custom')
                {
 				if(period=='Custom')
                {
                    if(String.isNotBlank(Month) && String.isNotBlank(Year))
                    {
                   query += ' AND CALENDAR_YEAR(Last_Closed_Date__c) = ' + Year + ' AND CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month ;
  
                    }
                   if(String.isBlank(Month) && String.isNotBlank(Year))
                   {
                   query += ' AND CALENDAR_YEAR(Last_Closed_Date__c) =' + Year ;
                 
                   }
                     if(String.isBlank(Year) && String.isNotBlank(Month))
                   {
                   query += ' AND CALENDAR_MONTH(Last_Closed_Date__c) = ' + Month ;
                 
                   }
                    else
                    {
               query += ' ';
   
                    } 
                }}
                else
                {
                query += ' AND Last_Closed_Date__c = ' + period ;
                }
            }
            System.debug('query :: '+query);
            
        }
        System.debug(unpack);
         query += 'AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\') ';
        
        try {
            filteredCases = Database.query(query);
        } catch (Exception ex) {
            // Handle exception
            System.debug('Exception occurred while fetching filtered cases: ' + ex.getMessage());
        }
        
        return filteredCases;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<FeedbackWrapper> getFeedbackData() {
       String feedbackTeam = '';
    Id CustomerFeedbackId;
    Id CustomerId;

    try {
        CustomerFeedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        CustomerId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
    } catch (Exception e) {
        System.debug('Failed to retrieve record type IDs: ' + e.getMessage());
        throw new AuraHandledException('Failed to retrieve record type IDs.');
    }

    User currentUser;
    try {
        currentUser = [SELECT Id, Feedback_Team__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    } catch (Exception e) {
        System.debug('Failed to retrieve current user: ' + e.getMessage());
        throw new AuraHandledException('Failed to retrieve current user.');
    }

    if (currentUser != null && currentUser.Feedback_Team__c != null) {
        feedbackTeam = currentUser.Feedback_Team__c;
    }

    String team = Caseteam(feedbackTeam);
    System.debug('Team: ' + team);

    if (String.isBlank(team)) {
        throw new AuraHandledException('Feedback team cannot be null or empty.');
    }

    List<Case> cases = new List<Case>();
    List<FeedbackWrapper> feedbackList = new List<FeedbackWrapper>();
    Date endDate = Date.today();
    Date startDate = endDate.toStartOfMonth().addMonths(-12);

    String query = 'SELECT Id, CaseNumber, Subject, Ageing__c, OwnerId, Status,Last_Closed_Date__c, ' +
                   'RW_Project__r.Name, CreatedDate, Account.Name, ' +
                   'LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ' +
                   'ClosedDate, CSAT_Feedback_Remark__c, CSAT_Feedback_Rating__c ' +
                   'FROM Case WHERE Last_Closed_Date__c >= :startDate AND Last_Closed_Date__c <= :endDate AND ' + team + 
                   ' AND RecordTypeId IN (\'' + CustomerFeedbackId + '\', \'' + CustomerId + '\')';

    if (startDate != null && endDate != null && !String.isBlank(query)) {
        try {
            cases = Database.query(query);
            System.debug('cases:::::'+cases);
        } catch (QueryException e) {
            System.debug('Query failed: ' + e.getMessage());
            throw new AuraHandledException('Failed to retrieve cases. Please check the query.');
        }
    } else {
        System.debug('Invalid query parameters.');
        throw new AuraHandledException('Invalid query parameters. Please ensure all necessary values are provided.');
    }

    Map<String, List<Case>> monthYearCaseMap = new Map<String, List<Case>>();
    for (Integer i = 0; i < 12; i++) {
        Date monthDate = endDate.toStartOfMonth().addMonths(-i);
        Integer month = monthDate.month();
        Integer year = monthDate.year();
        monthYearCaseMap.put(month + '/' + year, new List<Case>());
    }

    for (Case c : cases) {
        if (c.ClosedDate != null) {
            Integer month = c.ClosedDate.month();
            Integer year = c.ClosedDate.year();
            String key = month + '/' + year;
            if (monthYearCaseMap.containsKey(key)) {
                monthYearCaseMap.get(key).add(c);
            }
        }
    }

    for (String monthYear : monthYearCaseMap.keySet()) {
        List<Case> casesInMonthYear = monthYearCaseMap.get(monthYear);
        Integer totalCases = casesInMonthYear.size();
        Integer happyCases = 0;
        Integer unhappyCases = 0;
        Integer fairCases = 0;
        Integer totalInteractions = 0;
        for (Case c : casesInMonthYear) {
            if (c.CSAT_Feedback_Rating__c == 'Happy') {
                happyCases++;
            } else if (c.CSAT_Feedback_Rating__c == 'Unhappy') {
                unhappyCases++;
            } else if (c.CSAT_Feedback_Rating__c == 'Fair') {
                fairCases++;
            }
        }
        totalInteractions = happyCases + unhappyCases + fairCases;

        String[] parts = monthYear.split('/');
        String month = parts[0];
        String year = parts[1];

        FeedbackWrapper feedbackWrapper = new FeedbackWrapper(month, year, totalCases, totalInteractions, happyCases, unhappyCases, fairCases);
        feedbackList.add(feedbackWrapper);
    }
    return feedbackList;
}
 
    
    

   

     
    public class FeedbackWrapper {
    @AuraEnabled
    public String month { get; set; }
    @AuraEnabled
    public String year { get; set; }
    @AuraEnabled
    public Integer totalInteractions { get; set; }
    @AuraEnabled
    public Integer totalCases { get; set; }
    @AuraEnabled
    public Integer happyCases { get; set; }
    @AuraEnabled
    public Integer unhappyCases { get; set; }
    @AuraEnabled
    public Integer fairCases { get; set; }
    @AuraEnabled
    public Integer ReopenedCases { get; set; }

    public FeedbackWrapper(String month, String year, Integer totalCases, Integer totalInteractions, Integer happyCases, Integer unhappyCases, Integer fairCases) {
        this.month = month;
        this.year = year;
        this.totalInteractions = totalInteractions;
        this.totalCases = totalCases;
        this.happyCases = happyCases;
        this.unhappyCases = unhappyCases;
        this.fairCases = fairCases;
       
    }
}
    
    public class ProjectFeedbackWrapper1 {
        @AuraEnabled public String project;
        @AuraEnabled public String projectID;
        @AuraEnabled public String rmName;
        @AuraEnabled public String rmID;
        @AuraEnabled public Integer TotalCase;
        @AuraEnabled public Integer totalInteractions;
        @AuraEnabled public Integer totalHappy;
        @AuraEnabled public Integer totalUnhappy;
        @AuraEnabled public Integer Fair;
        @AuraEnabled public Integer Reopened;
        @AuraEnabled public List<Case> ExportCase;
        
        
        public ProjectFeedbackWrapper1(String project, String rmName, Integer TotalCase,
                                      Integer totalInteractions, Integer totalHappy, Integer totalUnhappy,Integer Fair,Integer Reopened,List<case> ExportCase) {
                                          this.project = project;
                                          this.TotalCase=TotalCase;
                                          this.rmName = rmName;
                                          this.totalInteractions = totalInteractions;
                                          this.totalHappy = totalHappy;
                                          this.totalUnhappy = totalUnhappy;
                                          this.Fair=Fair;
                                          this.Reopened=Reopened;
                                          this.ExportCase=ExportCase;
                                      }
    }
    
    public class ProjectFeedbackWrapper {
        @AuraEnabled public String project;
        @AuraEnabled public String projectID;
        @AuraEnabled public String rmName;
        @AuraEnabled public String rmID;
        @AuraEnabled public Integer TotalCase;
        @AuraEnabled public Integer totalInteractions;
        @AuraEnabled public Integer totalHappy;
        @AuraEnabled public Integer totalUnhappy;
        @AuraEnabled public Integer Fair;
         @AuraEnabled public Integer Reopened;
        @AuraEnabled public List<Case> ExportCase;

        
        public ProjectFeedbackWrapper(String project, String rmName, Integer TotalCase,
                                      Integer totalInteractions, Integer totalHappy, Integer totalUnhappy,Integer Fair,Integer Reopened,List<case> ExportCase) {
                                          this.project = project;
                                          this.TotalCase=TotalCase;
                                          this.rmName = rmName;
                                          this.totalInteractions = totalInteractions;
                                          this.totalHappy = totalHappy;
                                          this.totalUnhappy = totalUnhappy;
                                          this.Fair=Fair;
                                          this.Reopened=Reopened;
                                          this.ExportCase=ExportCase;
                                      }
    }


    public class npsScore{
        @auraEnabled
        public String fbType;
        @auraEnabled
        public Decimal month1;
        @auraEnabled
        public Decimal month2;
        @auraEnabled
        public Decimal month3;
        @auraEnabled
        public Decimal month4;
        @auraEnabled
        public Decimal month5;
        @auraEnabled
        public Decimal month6;
        @auraEnabled
        public Decimal month7;
        @auraEnabled
        public Decimal month8;
        @auraEnabled
        public Decimal month9;
        @auraEnabled
        public Decimal month10;
        @auraEnabled
        public Decimal month11;
        @auraEnabled
        public Decimal month12;
    }  
    
    public class NPSData{
        @auraEnabled
        public String project;
        @auraEnabled
        public List<fbTypeNps> fbNps;
        @auraEnabled
        public fbTypeNpsTotals fbNpsTotals;
        @auraEnabled
        public Boolean dataPresent;
    }
    
    public class fbTypeNps{
        @auraEnabled
        public String fbType;
        @auraEnabled
        public Decimal nps_10;
        @auraEnabled
        public Decimal nps_9;
        @auraEnabled
        public Decimal nps_8;
        @auraEnabled
        public Decimal nps_7;
        @auraEnabled
        public Decimal nps_6;
        @auraEnabled
        public Decimal nps_5;
        @auraEnabled
        public Decimal nps_4;
        @auraEnabled
        public Decimal nps_3;
        @auraEnabled
        public Decimal nps_2;
        @auraEnabled
        public Decimal nps_1;
        @auraEnabled
        public Decimal nps_T;
        @auraEnabled
        public Decimal promoters_per;
        @auraEnabled
        public Decimal passives_per;
        @auraEnabled
        public Decimal detractors_per;
        @auraEnabled
        public Decimal nps_score;
        @auraEnabled
        public Map<String,Integer> npsCount;
    }
    
    public class fbTypeNpsTotals{
        @auraEnabled
        public Decimal nps_10_T;
        @auraEnabled
        public Decimal nps_9_T;
        @auraEnabled
        public Decimal nps_8_T;
        @auraEnabled
        public Decimal nps_7_T;
        @auraEnabled
        public Decimal nps_6_T;
        @auraEnabled
        public Decimal nps_5_T;
        @auraEnabled
        public Decimal nps_4_T;
        @auraEnabled
        public Decimal nps_3_T;
        @auraEnabled
        public Decimal nps_2_T;
        @auraEnabled
        public Decimal nps_1_T;
        @auraEnabled
        public Decimal nps_T_T;
        @auraEnabled
        public Decimal promoters_per_T;
        @auraEnabled
        public Decimal passives_per_T;
        @auraEnabled
        public Decimal detractors_per_T;
        @auraEnabled
        public Decimal nps_score_T;
        @auraEnabled
        public Map<String,Integer> npsCount_T;
    }
    
    public class eventData{
        @auraEnabled
        public String crn;
        @auraEnabled
        public String feedbackType;
        @auraEnabled
        public String mobile;
        @auraEnabled
        public String customer;
        @auraEnabled
        public String recId;
        @auraEnabled
        public String name;
        @auraEnabled
        public List<String> questions;
        @auraEnabled
        public String project;
        @auraEnabled
        public String oppId;
    }
    
}