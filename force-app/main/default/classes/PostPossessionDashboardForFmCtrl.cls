public class PostPossessionDashboardForFmCtrl {
    
    @AuraEnabled(cacheable=true)
    public static String getTeam(){
        User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c); 
        String team = usr.Feedback_Team__c+':'+usr.NPS_Feedback_Team__c;
        return team;
    }
   
    @AuraEnabled(cacheable=true)
    public static List<NPSData> getDefaultRecords(String dateRange, String year, String month){
        User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c); 
        //String team = usr.Feedback_Team__c;
        System.debug('dateRange: ' + dateRange);
        System.debug('year: ' + year);
        System.debug('month: ' + month);
        if(dateRange == null){
            dateRange = 'LAST_N_DAYS:30';
        }
        List<NPSData> fbRecords = npsReport(usr.Feedback_Team__c+':'+usr.NPS_Feedback_Team__c, dateRange, year, month);
        return fbRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NPSData> getRecords(String dateRange, String year, String month){
        User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c); 
        String team = usr.Feedback_Team__c;
        System.debug('dateRange: ' + dateRange);
        System.debug('year: ' + year);
        System.debug('month: ' + month);
        List<NPSData> fbRecords = npsReport(usr.Feedback_Team__c+':'+usr.NPS_Feedback_Team__c, dateRange, year, month);
        return fbRecords;
    }
    
    
    @AuraEnabled
    public static List<NPSData> npsReport(String userTeam, String dateRange, String year, String month){
        
        System.debug('dateRange: ' + dateRange);
        System.debug('year: ' + year);
        System.debug('month: ' + month);
        
        String team = userTeam.split(':')[0];
        String team2 = userTeam.split(':')[1];
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            System.debug('--1');
            qry = WhatsAppFeedbackBotReportsController.yearMonthQueryBuilder(team, year, month);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            fbList = Database.query(qry);
        }else{
            System.debug('--2');
            qry = WhatsAppFeedbackBotReportsController.eventReportQueryBuilder(team, dateRange);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            System.debug('qry: ' + qry);
            fbList = Database.query(qry);
        }
        System.debug('fbList size: ' + fbList.size());
        System.debug('fbList : ' + fbList);
        if(fbList.size() == 0){
            return null;
        }
        Map<String, List<WhatsApp_Feedback__c>> projVsFbList = new Map<String, List<WhatsApp_Feedback__c>>();
        projVsFbList.put('All Projects',new List<WhatsApp_Feedback__c>{});
        for(WhatsApp_Feedback__c fb : fbList){
            if(fb.Feedback_Type__c == 'Post Possession Handover'){
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
            fbTypeVsFbList.put('Post Possession Handover 60 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 90 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 120 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 150 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 180 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 210 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 240 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 270 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 300 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 330 days', new List<WhatsApp_Feedback__c>{});
            fbTypeVsFbList.put('Post Possession Handover 360 days', new List<WhatsApp_Feedback__c>{});
            for(WhatsApp_Feedback__c fb : projVsFbList.get(proj)){
                if(fb.Post_Possession_Frequency_Days__c != null && fb.Post_Possession_Frequency_Days__c != 0){
                    fbTypeVsFbList.get(fb.Feedback_Type__c + ' ' + fb.Post_Possession_Frequency_Days__c + ' days').add(fb);
                }else{
                    fbTypeVsFbList.get(fb.Feedback_Type__c + ' 60 days').add(fb);
                }
                
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
                    if(nps.promoters_per > 75){
                        nps.promoters_per_color = 'text-align:center;background-color:#5acf67';
                    }else{
                        nps.promoters_per_color = 'text-align:center;';
                    }
                    nps.passives_per = ((nps8 + nps7) != 0) ? ((nps8 + nps7)/nps.nps_T) * 100 : 0;
                    nps.passives_per = nps.passives_per.setscale(0,RoundingMode.HALF_UP);
                    nps.detractors_per = ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1) != 0) ? ((nps6 + nps5 + nps4 + nps3 + nps2 + nps1)/nps.nps_T) * 100 : 0;
                    nps.detractors_per = nps.detractors_per.setscale(0,RoundingMode.HALF_UP);
                    if(nps.detractors_per > 75){
                        nps.detractors_per_color = 'text-align:center;background-color:#f9898d';
                    }else{
                        nps.detractors_per_color = 'text-align:center;';
                    }
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
    
    /*@auraEnabled(cacheable=true)
    public static List<npsScore> npsSummaryForYear(){
        
        User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c); 
        String team = usr.Feedback_Team__c;
        
        //String team = this.userTeam.split(':')[0];
        //String team2 = this.userTeam.split(':')[1];
        
        Date dt = System.today(); 
        Integer month = dt.Month(); 
        Integer year = dt.Year(); 
        Date lastYearDate = dt.addDays(-365);
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c, Post_Possession_Frequency_Days__c  FROM WhatsApp_Feedback__c';
        String teamQry = WhatsAppFeedbackBotReportsController.teamQuery(team);
        
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
        qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
        if(!Test.isRunningTest()){
            fbList = Database.query(qry);
        }else{
            fbList = [SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c, Post_Possession_Frequency_Days__c  FROM WhatsApp_Feedback__c LIMIT 10];
        }
        //List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        
        System.debug('fbList: ' + fbList);
        Map<String, Map<Decimal,Integer>> npsScores = new Map<String,Map<Decimal,Integer>>();
        Map<Decimal,Integer> post60CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post60PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post60DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post90CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post90PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post90DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post120CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post120PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post120DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post150CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post150PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post150DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post180CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post180PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post180DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post210CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post210PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post210DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post240CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post240PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post240DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post270CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post270PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post270DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post300CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post300PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post300DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post330CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post330PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post330DetractorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post360CountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post360PrometorsCountMap = new Map<Decimal,Integer>();
        Map<Decimal,Integer> post360DetractorsCountMap = new Map<Decimal,Integer>();
        
        List<WhatsApp_Feedback__c> post60List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post90List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post120List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post150List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post180List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post210List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post240List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post270List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post300List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post330List = new List<WhatsApp_Feedback__c>();
        List<WhatsApp_Feedback__c> post360List = new List<WhatsApp_Feedback__c>();
        
        for(WhatsApp_Feedback__c fb : fbList){
            if(fb.Feedback_Type__c == 'Post Possession Handover' && (fb.Post_Possession_Frequency_Days__c == 60 || fb.Post_Possession_Frequency_Days__c == null)){
                post60List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 90){
                post90List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 120){
                post120List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 150){
                post150List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 180){
                post180List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 210){
                post210List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 240){
                post240List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 270){
                post270List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 300){
                post300List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 330){
                post330List.add(fb);
            }else if(fb.Feedback_Type__c == 'Post Possession Handover' && fb.Post_Possession_Frequency_Days__c == 360){
                post360List.add(fb);
            }            
        }
        for(WhatsApp_Feedback__c fb : post60List){
            if(post60CountMap.keySet().contains(fb.Month__c)){
                post60CountMap.put(fb.Month__c, post60CountMap.get(fb.Month__c)+1);
            }else{
                post60CountMap.put(fb.Month__c, 1);
            }
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post60PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post60PrometorsCountMap.put(fb.Month__c, post60PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post60PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post60DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post60DetractorsCountMap.put(fb.Month__c, post60DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post60DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post90List){
            if(post90CountMap.keySet().contains(fb.Month__c)){
                post90CountMap.put(fb.Month__c, post90CountMap.get(fb.Month__c)+1);
            }else{
                post90CountMap.put(fb.Month__c, 1);
            }
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post90PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post90PrometorsCountMap.put(fb.Month__c, post90PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post90PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post90DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post90DetractorsCountMap.put(fb.Month__c, post90DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post90DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post120List){
            if(post120CountMap.keySet().contains(fb.Month__c)){
                post120CountMap.put(fb.Month__c, post120CountMap.get(fb.Month__c)+1);
            }else{
                post120CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post120PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post120PrometorsCountMap.put(fb.Month__c, post120PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post120PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post120DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post120DetractorsCountMap.put(fb.Month__c, post120DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post120DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post150List){
            if(post150CountMap.keySet().contains(fb.Month__c)){
                post150CountMap.put(fb.Month__c, post150CountMap.get(fb.Month__c)+1);
            }else{
                post150CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post150PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post150PrometorsCountMap.put(fb.Month__c, post150PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post150PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post150DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post150DetractorsCountMap.put(fb.Month__c, post150DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post150DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post180List){
            if(post180CountMap.keySet().contains(fb.Month__c)){
                post180CountMap.put(fb.Month__c, post180CountMap.get(fb.Month__c)+1);
            }else{
                post180CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post180PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post180PrometorsCountMap.put(fb.Month__c, post180PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post180PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post180DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post180DetractorsCountMap.put(fb.Month__c, post180DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post180DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        for(WhatsApp_Feedback__c fb : post210List){
            if(post210CountMap.keySet().contains(fb.Month__c)){
                post210CountMap.put(fb.Month__c, post210CountMap.get(fb.Month__c)+1);
            }else{
                post210CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post210PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post210PrometorsCountMap.put(fb.Month__c, post210PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post210PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post210DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post210DetractorsCountMap.put(fb.Month__c, post210DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post210DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        for(WhatsApp_Feedback__c fb : post240List){
            if(post240CountMap.keySet().contains(fb.Month__c)){
                post240CountMap.put(fb.Month__c, post240CountMap.get(fb.Month__c)+1);
            }else{
                post240CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post240PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post240PrometorsCountMap.put(fb.Month__c, post240PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post240PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post240DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post240DetractorsCountMap.put(fb.Month__c, post240DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post240DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        for(WhatsApp_Feedback__c fb : post270List){
            if(post270CountMap.keySet().contains(fb.Month__c)){
                post270CountMap.put(fb.Month__c, post270CountMap.get(fb.Month__c)+1);
            }else{
                post270CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post270PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post270PrometorsCountMap.put(fb.Month__c, post270PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post270PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post270DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post270DetractorsCountMap.put(fb.Month__c, post270DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post270DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        for(WhatsApp_Feedback__c fb : post300List){
            if(post300CountMap.keySet().contains(fb.Month__c)){
                post300CountMap.put(fb.Month__c, post300CountMap.get(fb.Month__c)+1);
            }else{
                post300CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post300PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post300PrometorsCountMap.put(fb.Month__c, post300PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post300PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post300DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post300DetractorsCountMap.put(fb.Month__c, post300DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post300DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post330List){
            if(post330CountMap.keySet().contains(fb.Month__c)){
                post330CountMap.put(fb.Month__c, post330CountMap.get(fb.Month__c)+1);
            }else{
                post330CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post330PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post330PrometorsCountMap.put(fb.Month__c, post330PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post330PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post330DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post330DetractorsCountMap.put(fb.Month__c, post330DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post330DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        for(WhatsApp_Feedback__c fb : post360List){
            if(post360CountMap.keySet().contains(fb.Month__c)){
                post360CountMap.put(fb.Month__c, post360CountMap.get(fb.Month__c)+1);
            }else{
                post360CountMap.put(fb.Month__c, 1);
            }
            
            if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                if(post360PrometorsCountMap.keySet().contains(fb.Month__c)){
                    post360PrometorsCountMap.put(fb.Month__c, post360PrometorsCountMap.get(fb.Month__c)+1);
                }else{
                    post360PrometorsCountMap.put(fb.Month__c, 1);
                }
            }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                if(post360DetractorsCountMap.keySet().contains(fb.Month__c)){
                    post360DetractorsCountMap.put(fb.Month__c, post360DetractorsCountMap.get(fb.Month__c)+1);
                }else{
                    post360DetractorsCountMap.put(fb.Month__c, 1);
                }
            }
        }
        
        npsScores.put('Post Possession Handover 60 days ',post60CountMap);
        npsScores.put('Post Possession Handover 90 days ',post90CountMap);
        npsScores.put('Post Possession Handover 120 days ',post120CountMap);
        npsScores.put('Post Possession Handover 150 days ',post150CountMap);
        npsScores.put('Post Possession Handover 180 days ',post180CountMap);
        npsScores.put('Post Possession Handover 210 days ',post210CountMap);
        npsScores.put('Post Possession Handover 240 days ',post240CountMap);
        npsScores.put('Post Possession Handover 270 days ',post270CountMap);
        npsScores.put('Post Possession Handover 300 days ',post300CountMap);
        npsScores.put('Post Possession Handover 330 days ',post330CountMap);
        npsScores.put('Post Possession Handover 360 days ',post360CountMap);
        
        
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
        

        
        Decimal post60Month1Count = (post60CountMap.get(monthList[0]) != null)? post60CountMap.get(monthList[0]) : 0;
        Decimal post60Month1PrometorsCount = (post60PrometorsCountMap.get(monthList[0]) != null)? post60PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post60Month1DetractorsCount = (post60DetractorsCountMap.get(monthList[0]) != null)? post60DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post60Month2Count = (post60CountMap.get(monthList[1]) != null)? post60CountMap.get(monthList[1]) : 0;
        Decimal post60Month2PrometorsCount = (post60PrometorsCountMap.get(monthList[1]) != null)? post60PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post60Month2DetractorsCount = (post60DetractorsCountMap.get(monthList[1]) != null)? post60DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post60Month3Count = (post60CountMap.get(monthList[2]) != null)? post60CountMap.get(monthList[2]) : 0;
        Decimal post60Month3PrometorsCount = (post60PrometorsCountMap.get(monthList[2]) != null)? post60PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post60Month3DetractorsCount = (post60DetractorsCountMap.get(monthList[2]) != null)? post60DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post60Month4Count = (post60CountMap.get(monthList[3]) != null)? post60CountMap.get(monthList[3]) : 0;
        Decimal post60Month4PrometorsCount = (post60PrometorsCountMap.get(monthList[3]) != null)? post60PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post60Month4DetractorsCount = (post60DetractorsCountMap.get(monthList[3]) != null)? post60DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post60Month5Count = (post60CountMap.get(monthList[4]) != null)? post60CountMap.get(monthList[4]) : 0;
        Decimal post60Month5PrometorsCount = (post60PrometorsCountMap.get(monthList[4]) != null)? post60PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post60Month5DetractorsCount = (post60DetractorsCountMap.get(monthList[4]) != null)? post60DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post60Month6Count = (post60CountMap.get(monthList[5]) != null)? post60CountMap.get(monthList[5]) : 0;
        Decimal post60Month6PrometorsCount = (post60PrometorsCountMap.get(monthList[5]) != null)? post60PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post60Month6DetractorsCount = (post60DetractorsCountMap.get(monthList[5]) != null)? post60DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post60Month7Count = (post60CountMap.get(monthList[6]) != null)? post60CountMap.get(monthList[6]) : 0;
        Decimal post60Month7PrometorsCount = (post60PrometorsCountMap.get(monthList[6]) != null)? post60PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post60Month7DetractorsCount = (post60DetractorsCountMap.get(monthList[6]) != null)? post60DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post60Month8Count = (post60CountMap.get(monthList[7]) != null)? post60CountMap.get(monthList[7]) : 0;
        Decimal post60Month8PrometorsCount = (post60PrometorsCountMap.get(monthList[7]) != null)? post60PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post60Month8DetractorsCount = (post60DetractorsCountMap.get(monthList[7]) != null)? post60DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post60Month9Count = (post60CountMap.get(monthList[8]) != null)? post60CountMap.get(monthList[8]) : 0;
        Decimal post60Month9PrometorsCount = (post60PrometorsCountMap.get(monthList[8]) != null)? post60PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post60Month9DetractorsCount = (post60DetractorsCountMap.get(monthList[8]) != null)? post60DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post60Month10Count = (post60CountMap.get(monthList[9]) != null)? post60CountMap.get(monthList[9]) : 0;
        Decimal post60Month10PrometorsCount = (post60PrometorsCountMap.get(monthList[9]) != null)? post60PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post60Month10DetractorsCount = (post60DetractorsCountMap.get(monthList[9]) != null)? post60DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post60Month11Count = (post60CountMap.get(monthList[10]) != null)? post60CountMap.get(monthList[10]) : 0;
        Decimal post60Month11PrometorsCount = (post60PrometorsCountMap.get(monthList[10]) != null)? post60PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post60Month11DetractorsCount = (post60DetractorsCountMap.get(monthList[10]) != null)? post60DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post60Month12Count = (post60CountMap.get(monthList[11]) != null)? post60CountMap.get(monthList[11]) : 0;
        Decimal post60Month12PrometorsCount = (post60PrometorsCountMap.get(monthList[11]) != null)? post60PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post60Month12DetractorsCount = (post60DetractorsCountMap.get(monthList[11]) != null)? post60DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post90Month1Count = (post90CountMap.get(monthList[0]) != null)? post90CountMap.get(monthList[0]) : 0;
        Decimal post90Month1PrometorsCount = (post90PrometorsCountMap.get(monthList[0]) != null)? post90PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post90Month1DetractorsCount = (post90DetractorsCountMap.get(monthList[0]) != null)? post90DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post90Month2Count = (post90CountMap.get(monthList[1]) != null)? post90CountMap.get(monthList[1]) : 0;
        Decimal post90Month2PrometorsCount = (post90PrometorsCountMap.get(monthList[1]) != null)? post90PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post90Month2DetractorsCount = (post90DetractorsCountMap.get(monthList[1]) != null)? post90DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post90Month3Count = (post90CountMap.get(monthList[2]) != null)? post90CountMap.get(monthList[2]) : 0;
        Decimal post90Month3PrometorsCount = (post90PrometorsCountMap.get(monthList[2]) != null)? post90PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post90Month3DetractorsCount = (post90DetractorsCountMap.get(monthList[2]) != null)? post90DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post90Month4Count = (post90CountMap.get(monthList[3]) != null)? post90CountMap.get(monthList[3]) : 0;
        Decimal post90Month4PrometorsCount = (post90PrometorsCountMap.get(monthList[3]) != null)? post90PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post90Month4DetractorsCount = (post90DetractorsCountMap.get(monthList[3]) != null)? post90DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post90Month5Count = (post90CountMap.get(monthList[4]) != null)? post90CountMap.get(monthList[4]) : 0;
        Decimal post90Month5PrometorsCount = (post90PrometorsCountMap.get(monthList[4]) != null)? post90PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post90Month5DetractorsCount = (post90DetractorsCountMap.get(monthList[4]) != null)? post90DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post90Month6Count = (post90CountMap.get(monthList[5]) != null)? post90CountMap.get(monthList[5]) : 0;
        Decimal post90Month6PrometorsCount = (post90PrometorsCountMap.get(monthList[5]) != null)? post90PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post90Month6DetractorsCount = (post90DetractorsCountMap.get(monthList[5]) != null)? post90DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post90Month7Count = (post90CountMap.get(monthList[6]) != null)? post90CountMap.get(monthList[6]) : 0;
        Decimal post90Month7PrometorsCount = (post90PrometorsCountMap.get(monthList[6]) != null)? post90PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post90Month7DetractorsCount = (post90DetractorsCountMap.get(monthList[6]) != null)? post90DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post90Month8Count = (post90CountMap.get(monthList[7]) != null)? post90CountMap.get(monthList[7]) : 0;
        Decimal post90Month8PrometorsCount = (post90PrometorsCountMap.get(monthList[7]) != null)? post90PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post90Month8DetractorsCount = (post90DetractorsCountMap.get(monthList[7]) != null)? post90DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post90Month9Count = (post90CountMap.get(monthList[8]) != null)? post90CountMap.get(monthList[8]) : 0;
        Decimal post90Month9PrometorsCount = (post90PrometorsCountMap.get(monthList[8]) != null)? post90PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post90Month9DetractorsCount = (post90DetractorsCountMap.get(monthList[8]) != null)? post90DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post90Month10Count = (post90CountMap.get(monthList[9]) != null)? post90CountMap.get(monthList[9]) : 0;
        Decimal post90Month10PrometorsCount = (post90PrometorsCountMap.get(monthList[9]) != null)? post90PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post90Month10DetractorsCount = (post90DetractorsCountMap.get(monthList[9]) != null)? post90DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post90Month11Count = (post90CountMap.get(monthList[10]) != null)? post90CountMap.get(monthList[10]) : 0;
        Decimal post90Month11PrometorsCount = (post90PrometorsCountMap.get(monthList[10]) != null)? post90PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post90Month11DetractorsCount = (post90DetractorsCountMap.get(monthList[10]) != null)? post90DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post90Month12Count = (post90CountMap.get(monthList[11]) != null)? post90CountMap.get(monthList[11]) : 0;
        Decimal post90Month12PrometorsCount = (post90PrometorsCountMap.get(monthList[11]) != null)? post90PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post90Month12DetractorsCount = (post90DetractorsCountMap.get(monthList[11]) != null)? post90DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post120Month1Count = (post120CountMap.get(monthList[0]) != null)? post120CountMap.get(monthList[0]) : 0;
        Decimal post120Month1PrometorsCount = (post120PrometorsCountMap.get(monthList[0]) != null)? post120PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post120Month1DetractorsCount = (post120DetractorsCountMap.get(monthList[0]) != null)? post120DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post120Month2Count = (post120CountMap.get(monthList[1]) != null)? post120CountMap.get(monthList[1]) : 0;
        Decimal post120Month2PrometorsCount = (post120PrometorsCountMap.get(monthList[1]) != null)? post120PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post120Month2DetractorsCount = (post120DetractorsCountMap.get(monthList[1]) != null)? post120DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post120Month3Count = (post120CountMap.get(monthList[2]) != null)? post120CountMap.get(monthList[2]) : 0;
        Decimal post120Month3PrometorsCount = (post120PrometorsCountMap.get(monthList[2]) != null)? post120PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post120Month3DetractorsCount = (post120DetractorsCountMap.get(monthList[2]) != null)? post120DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post120Month4Count = (post120CountMap.get(monthList[3]) != null)? post120CountMap.get(monthList[3]) : 0;
        Decimal post120Month4PrometorsCount = (post120PrometorsCountMap.get(monthList[3]) != null)? post120PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post120Month4DetractorsCount = (post120DetractorsCountMap.get(monthList[3]) != null)? post120DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post120Month5Count = (post120CountMap.get(monthList[4]) != null)? post120CountMap.get(monthList[4]) : 0;
        Decimal post120Month5PrometorsCount = (post120PrometorsCountMap.get(monthList[4]) != null)? post120PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post120Month5DetractorsCount = (post120DetractorsCountMap.get(monthList[4]) != null)? post120DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post120Month6Count = (post120CountMap.get(monthList[5]) != null)? post120CountMap.get(monthList[5]) : 0;
        Decimal post120Month6PrometorsCount = (post120PrometorsCountMap.get(monthList[5]) != null)? post120PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post120Month6DetractorsCount = (post120DetractorsCountMap.get(monthList[5]) != null)? post120DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post120Month7Count = (post120CountMap.get(monthList[6]) != null)? post120CountMap.get(monthList[6]) : 0;
        Decimal post120Month7PrometorsCount = (post120PrometorsCountMap.get(monthList[6]) != null)? post120PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post120Month7DetractorsCount = (post120DetractorsCountMap.get(monthList[6]) != null)? post120DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post120Month8Count = (post120CountMap.get(monthList[7]) != null)? post120CountMap.get(monthList[7]) : 0;
        Decimal post120Month8PrometorsCount = (post120PrometorsCountMap.get(monthList[7]) != null)? post120PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post120Month8DetractorsCount = (post120DetractorsCountMap.get(monthList[7]) != null)? post120DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post120Month9Count = (post120CountMap.get(monthList[8]) != null)? post120CountMap.get(monthList[8]) : 0;
        Decimal post120Month9PrometorsCount = (post120PrometorsCountMap.get(monthList[8]) != null)? post120PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post120Month9DetractorsCount = (post120DetractorsCountMap.get(monthList[8]) != null)? post120DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post120Month10Count = (post120CountMap.get(monthList[9]) != null)? post120CountMap.get(monthList[9]) : 0;
        Decimal post120Month10PrometorsCount = (post120PrometorsCountMap.get(monthList[9]) != null)? post120PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post120Month10DetractorsCount = (post120DetractorsCountMap.get(monthList[9]) != null)? post120DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post120Month11Count = (post120CountMap.get(monthList[10]) != null)? post120CountMap.get(monthList[10]) : 0;
        Decimal post120Month11PrometorsCount = (post120PrometorsCountMap.get(monthList[10]) != null)? post120PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post120Month11DetractorsCount = (post120DetractorsCountMap.get(monthList[10]) != null)? post120DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post120Month12Count = (post120CountMap.get(monthList[11]) != null)? post120CountMap.get(monthList[11]) : 0;
        Decimal post120Month12PrometorsCount = (post120PrometorsCountMap.get(monthList[11]) != null)? post120PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post120Month12DetractorsCount = (post120DetractorsCountMap.get(monthList[11]) != null)? post120DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post150Month1Count = (post150CountMap.get(monthList[0]) != null)? post150CountMap.get(monthList[0]) : 0;
        Decimal post150Month1PrometorsCount = (post150PrometorsCountMap.get(monthList[0]) != null)? post150PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post150Month1DetractorsCount = (post150DetractorsCountMap.get(monthList[0]) != null)? post150DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post150Month2Count = (post150CountMap.get(monthList[1]) != null)? post150CountMap.get(monthList[1]) : 0;
        Decimal post150Month2PrometorsCount = (post150PrometorsCountMap.get(monthList[1]) != null)? post150PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post150Month2DetractorsCount = (post150DetractorsCountMap.get(monthList[1]) != null)? post150DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post150Month3Count = (post150CountMap.get(monthList[2]) != null)? post150CountMap.get(monthList[2]) : 0;
        Decimal post150Month3PrometorsCount = (post150PrometorsCountMap.get(monthList[2]) != null)? post150PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post150Month3DetractorsCount = (post150DetractorsCountMap.get(monthList[2]) != null)? post150DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post150Month4Count = (post150CountMap.get(monthList[3]) != null)? post150CountMap.get(monthList[3]) : 0;
        Decimal post150Month4PrometorsCount = (post150PrometorsCountMap.get(monthList[3]) != null)? post150PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post150Month4DetractorsCount = (post150DetractorsCountMap.get(monthList[3]) != null)? post150DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post150Month5Count = (post150CountMap.get(monthList[4]) != null)? post150CountMap.get(monthList[4]) : 0;
        Decimal post150Month5PrometorsCount = (post150PrometorsCountMap.get(monthList[4]) != null)? post150PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post150Month5DetractorsCount = (post150DetractorsCountMap.get(monthList[4]) != null)? post150DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post150Month6Count = (post150CountMap.get(monthList[5]) != null)? post150CountMap.get(monthList[5]) : 0;
        Decimal post150Month6PrometorsCount = (post150PrometorsCountMap.get(monthList[5]) != null)? post150PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post150Month6DetractorsCount = (post150DetractorsCountMap.get(monthList[5]) != null)? post150DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post150Month7Count = (post150CountMap.get(monthList[6]) != null)? post150CountMap.get(monthList[6]) : 0;
        Decimal post150Month7PrometorsCount = (post150PrometorsCountMap.get(monthList[6]) != null)? post150PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post150Month7DetractorsCount = (post150DetractorsCountMap.get(monthList[6]) != null)? post150DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post150Month8Count = (post150CountMap.get(monthList[7]) != null)? post150CountMap.get(monthList[7]) : 0;
        Decimal post150Month8PrometorsCount = (post150PrometorsCountMap.get(monthList[7]) != null)? post150PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post150Month8DetractorsCount = (post150DetractorsCountMap.get(monthList[7]) != null)? post150DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post150Month9Count = (post150CountMap.get(monthList[8]) != null)? post150CountMap.get(monthList[8]) : 0;
        Decimal post150Month9PrometorsCount = (post150PrometorsCountMap.get(monthList[8]) != null)? post150PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post150Month9DetractorsCount = (post150DetractorsCountMap.get(monthList[8]) != null)? post150DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post150Month10Count = (post150CountMap.get(monthList[9]) != null)? post150CountMap.get(monthList[9]) : 0;
        Decimal post150Month10PrometorsCount = (post150PrometorsCountMap.get(monthList[9]) != null)? post150PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post150Month10DetractorsCount = (post150DetractorsCountMap.get(monthList[9]) != null)? post150DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post150Month11Count = (post150CountMap.get(monthList[10]) != null)? post150CountMap.get(monthList[10]) : 0;
        Decimal post150Month11PrometorsCount = (post150PrometorsCountMap.get(monthList[10]) != null)? post150PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post150Month11DetractorsCount = (post150DetractorsCountMap.get(monthList[10]) != null)? post150DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post150Month12Count = (post150CountMap.get(monthList[11]) != null)? post150CountMap.get(monthList[11]) : 0;
        Decimal post150Month12PrometorsCount = (post150PrometorsCountMap.get(monthList[11]) != null)? post150PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post150Month12DetractorsCount = (post150DetractorsCountMap.get(monthList[11]) != null)? post150DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post180Month1Count = (post180CountMap.get(monthList[0]) != null)? post180CountMap.get(monthList[0]) : 0;
        Decimal post180Month1PrometorsCount = (post180PrometorsCountMap.get(monthList[0]) != null)? post180PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post180Month1DetractorsCount = (post180DetractorsCountMap.get(monthList[0]) != null)? post180DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post180Month2Count = (post180CountMap.get(monthList[1]) != null)? post180CountMap.get(monthList[1]) : 0;
        Decimal post180Month2PrometorsCount = (post180PrometorsCountMap.get(monthList[1]) != null)? post180PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post180Month2DetractorsCount = (post180DetractorsCountMap.get(monthList[1]) != null)? post180DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post180Month3Count = (post180CountMap.get(monthList[2]) != null)? post180CountMap.get(monthList[2]) : 0;
        Decimal post180Month3PrometorsCount = (post180PrometorsCountMap.get(monthList[2]) != null)? post180PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post180Month3DetractorsCount = (post180DetractorsCountMap.get(monthList[2]) != null)? post180DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post180Month4Count = (post180CountMap.get(monthList[3]) != null)? post180CountMap.get(monthList[3]) : 0;
        Decimal post180Month4PrometorsCount = (post180PrometorsCountMap.get(monthList[3]) != null)? post180PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post180Month4DetractorsCount = (post180DetractorsCountMap.get(monthList[3]) != null)? post180DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post180Month5Count = (post180CountMap.get(monthList[4]) != null)? post180CountMap.get(monthList[4]) : 0;
        Decimal post180Month5PrometorsCount = (post180PrometorsCountMap.get(monthList[4]) != null)? post180PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post180Month5DetractorsCount = (post180DetractorsCountMap.get(monthList[4]) != null)? post180DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post180Month6Count = (post180CountMap.get(monthList[5]) != null)? post180CountMap.get(monthList[5]) : 0;
        Decimal post180Month6PrometorsCount = (post180PrometorsCountMap.get(monthList[5]) != null)? post180PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post180Month6DetractorsCount = (post180DetractorsCountMap.get(monthList[5]) != null)? post180DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post180Month7Count = (post180CountMap.get(monthList[6]) != null)? post180CountMap.get(monthList[6]) : 0;
        Decimal post180Month7PrometorsCount = (post180PrometorsCountMap.get(monthList[6]) != null)? post180PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post180Month7DetractorsCount = (post180DetractorsCountMap.get(monthList[6]) != null)? post180DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post180Month8Count = (post180CountMap.get(monthList[7]) != null)? post180CountMap.get(monthList[7]) : 0;
        Decimal post180Month8PrometorsCount = (post180PrometorsCountMap.get(monthList[7]) != null)? post180PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post180Month8DetractorsCount = (post180DetractorsCountMap.get(monthList[7]) != null)? post180DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post180Month9Count = (post180CountMap.get(monthList[8]) != null)? post180CountMap.get(monthList[8]) : 0;
        Decimal post180Month9PrometorsCount = (post180PrometorsCountMap.get(monthList[8]) != null)? post180PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post180Month9DetractorsCount = (post180DetractorsCountMap.get(monthList[8]) != null)? post180DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post180Month10Count = (post180CountMap.get(monthList[9]) != null)? post180CountMap.get(monthList[9]) : 0;
        Decimal post180Month10PrometorsCount = (post180PrometorsCountMap.get(monthList[9]) != null)? post180PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post180Month10DetractorsCount = (post180DetractorsCountMap.get(monthList[9]) != null)? post180DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post180Month11Count = (post180CountMap.get(monthList[10]) != null)? post180CountMap.get(monthList[10]) : 0;
        Decimal post180Month11PrometorsCount = (post180PrometorsCountMap.get(monthList[10]) != null)? post180PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post180Month11DetractorsCount = (post180DetractorsCountMap.get(monthList[10]) != null)? post180DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post180Month12Count = (post180CountMap.get(monthList[11]) != null)? post180CountMap.get(monthList[11]) : 0;
        Decimal post180Month12PrometorsCount = (post180PrometorsCountMap.get(monthList[11]) != null)? post180PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post180Month12DetractorsCount = (post180DetractorsCountMap.get(monthList[11]) != null)? post180DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post270Month1Count = (post270CountMap.get(monthList[0]) != null)? post270CountMap.get(monthList[0]) : 0;
        Decimal post270Month1PrometorsCount = (post270PrometorsCountMap.get(monthList[0]) != null)? post270PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post270Month1DetractorsCount = (post270DetractorsCountMap.get(monthList[0]) != null)? post270DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post270Month2Count = (post270CountMap.get(monthList[1]) != null)? post270CountMap.get(monthList[1]) : 0;
        Decimal post270Month2PrometorsCount = (post270PrometorsCountMap.get(monthList[1]) != null)? post270PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post270Month2DetractorsCount = (post270DetractorsCountMap.get(monthList[1]) != null)? post270DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post270Month3Count = (post270CountMap.get(monthList[2]) != null)? post270CountMap.get(monthList[2]) : 0;
        Decimal post270Month3PrometorsCount = (post270PrometorsCountMap.get(monthList[2]) != null)? post270PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post270Month3DetractorsCount = (post270DetractorsCountMap.get(monthList[2]) != null)? post270DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post270Month4Count = (post270CountMap.get(monthList[3]) != null)? post270CountMap.get(monthList[3]) : 0;
        Decimal post270Month4PrometorsCount = (post270PrometorsCountMap.get(monthList[3]) != null)? post270PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post270Month4DetractorsCount = (post270DetractorsCountMap.get(monthList[3]) != null)? post270DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post270Month5Count = (post270CountMap.get(monthList[4]) != null)? post270CountMap.get(monthList[4]) : 0;
        Decimal post270Month5PrometorsCount = (post270PrometorsCountMap.get(monthList[4]) != null)? post270PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post270Month5DetractorsCount = (post270DetractorsCountMap.get(monthList[4]) != null)? post270DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post270Month6Count = (post270CountMap.get(monthList[5]) != null)? post270CountMap.get(monthList[5]) : 0;
        Decimal post270Month6PrometorsCount = (post270PrometorsCountMap.get(monthList[5]) != null)? post270PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post270Month6DetractorsCount = (post270DetractorsCountMap.get(monthList[5]) != null)? post270DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post270Month7Count = (post270CountMap.get(monthList[6]) != null)? post270CountMap.get(monthList[6]) : 0;
        Decimal post270Month7PrometorsCount = (post270PrometorsCountMap.get(monthList[6]) != null)? post270PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post270Month7DetractorsCount = (post270DetractorsCountMap.get(monthList[6]) != null)? post270DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post270Month8Count = (post270CountMap.get(monthList[7]) != null)? post270CountMap.get(monthList[7]) : 0;
        Decimal post270Month8PrometorsCount = (post270PrometorsCountMap.get(monthList[7]) != null)? post270PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post270Month8DetractorsCount = (post270DetractorsCountMap.get(monthList[7]) != null)? post270DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post270Month9Count = (post270CountMap.get(monthList[8]) != null)? post270CountMap.get(monthList[8]) : 0;
        Decimal post270Month9PrometorsCount = (post270PrometorsCountMap.get(monthList[8]) != null)? post270PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post270Month9DetractorsCount = (post270DetractorsCountMap.get(monthList[8]) != null)? post270DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post270Month10Count = (post270CountMap.get(monthList[9]) != null)? post270CountMap.get(monthList[9]) : 0;
        Decimal post270Month10PrometorsCount = (post270PrometorsCountMap.get(monthList[9]) != null)? post270PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post270Month10DetractorsCount = (post270DetractorsCountMap.get(monthList[9]) != null)? post270DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post270Month11Count = (post270CountMap.get(monthList[10]) != null)? post270CountMap.get(monthList[10]) : 0;
        Decimal post270Month11PrometorsCount = (post270PrometorsCountMap.get(monthList[10]) != null)? post270PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post270Month11DetractorsCount = (post270DetractorsCountMap.get(monthList[10]) != null)? post270DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post270Month12Count = (post270CountMap.get(monthList[11]) != null)? post270CountMap.get(monthList[11]) : 0;
        Decimal post270Month12PrometorsCount = (post270PrometorsCountMap.get(monthList[11]) != null)? post270PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post270Month12DetractorsCount = (post270DetractorsCountMap.get(monthList[11]) != null)? post270DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post210Month1Count = (post210CountMap.get(monthList[0]) != null)? post210CountMap.get(monthList[0]) : 0;
        Decimal post210Month1PrometorsCount = (post210PrometorsCountMap.get(monthList[0]) != null)? post210PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post210Month1DetractorsCount = (post210DetractorsCountMap.get(monthList[0]) != null)? post210DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post210Month2Count = (post210CountMap.get(monthList[1]) != null)? post210CountMap.get(monthList[1]) : 0;
        Decimal post210Month2PrometorsCount = (post210PrometorsCountMap.get(monthList[1]) != null)? post210PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post210Month2DetractorsCount = (post210DetractorsCountMap.get(monthList[1]) != null)? post210DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post210Month3Count = (post210CountMap.get(monthList[2]) != null)? post210CountMap.get(monthList[2]) : 0;
        Decimal post210Month3PrometorsCount = (post210PrometorsCountMap.get(monthList[2]) != null)? post210PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post210Month3DetractorsCount = (post210DetractorsCountMap.get(monthList[2]) != null)? post210DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post210Month4Count = (post210CountMap.get(monthList[3]) != null)? post210CountMap.get(monthList[3]) : 0;
        Decimal post210Month4PrometorsCount = (post210PrometorsCountMap.get(monthList[3]) != null)? post210PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post210Month4DetractorsCount = (post210DetractorsCountMap.get(monthList[3]) != null)? post210DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post210Month5Count = (post210CountMap.get(monthList[4]) != null)? post210CountMap.get(monthList[4]) : 0;
        Decimal post210Month5PrometorsCount = (post210PrometorsCountMap.get(monthList[4]) != null)? post210PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post210Month5DetractorsCount = (post210DetractorsCountMap.get(monthList[4]) != null)? post210DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post210Month6Count = (post210CountMap.get(monthList[5]) != null)? post210CountMap.get(monthList[5]) : 0;
        Decimal post210Month6PrometorsCount = (post210PrometorsCountMap.get(monthList[5]) != null)? post210PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post210Month6DetractorsCount = (post210DetractorsCountMap.get(monthList[5]) != null)? post210DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post210Month7Count = (post210CountMap.get(monthList[6]) != null)? post210CountMap.get(monthList[6]) : 0;
        Decimal post210Month7PrometorsCount = (post210PrometorsCountMap.get(monthList[6]) != null)? post210PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post210Month7DetractorsCount = (post210DetractorsCountMap.get(monthList[6]) != null)? post210DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post210Month8Count = (post210CountMap.get(monthList[7]) != null)? post210CountMap.get(monthList[7]) : 0;
        Decimal post210Month8PrometorsCount = (post210PrometorsCountMap.get(monthList[7]) != null)? post210PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post210Month8DetractorsCount = (post210DetractorsCountMap.get(monthList[7]) != null)? post210DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post210Month9Count = (post210CountMap.get(monthList[8]) != null)? post210CountMap.get(monthList[8]) : 0;
        Decimal post210Month9PrometorsCount = (post210PrometorsCountMap.get(monthList[8]) != null)? post210PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post210Month9DetractorsCount = (post210DetractorsCountMap.get(monthList[8]) != null)? post210DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post210Month10Count = (post210CountMap.get(monthList[9]) != null)? post210CountMap.get(monthList[9]) : 0;
        Decimal post210Month10PrometorsCount = (post210PrometorsCountMap.get(monthList[9]) != null)? post210PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post210Month10DetractorsCount = (post210DetractorsCountMap.get(monthList[9]) != null)? post210DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post210Month11Count = (post210CountMap.get(monthList[10]) != null)? post210CountMap.get(monthList[10]) : 0;
        Decimal post210Month11PrometorsCount = (post210PrometorsCountMap.get(monthList[10]) != null)? post210PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post210Month11DetractorsCount = (post210DetractorsCountMap.get(monthList[10]) != null)? post210DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post210Month12Count = (post210CountMap.get(monthList[11]) != null)? post210CountMap.get(monthList[11]) : 0;
        Decimal post210Month12PrometorsCount = (post210PrometorsCountMap.get(monthList[11]) != null)? post210PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post210Month12DetractorsCount = (post210DetractorsCountMap.get(monthList[11]) != null)? post210DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post240Month1Count = (post240CountMap.get(monthList[0]) != null)? post240CountMap.get(monthList[0]) : 0;
        Decimal post240Month1PrometorsCount = (post240PrometorsCountMap.get(monthList[0]) != null)? post240PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post240Month1DetractorsCount = (post240DetractorsCountMap.get(monthList[0]) != null)? post240DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post240Month2Count = (post240CountMap.get(monthList[1]) != null)? post240CountMap.get(monthList[1]) : 0;
        Decimal post240Month2PrometorsCount = (post240PrometorsCountMap.get(monthList[1]) != null)? post240PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post240Month2DetractorsCount = (post240DetractorsCountMap.get(monthList[1]) != null)? post240DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post240Month3Count = (post240CountMap.get(monthList[2]) != null)? post240CountMap.get(monthList[2]) : 0;
        Decimal post240Month3PrometorsCount = (post240PrometorsCountMap.get(monthList[2]) != null)? post240PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post240Month3DetractorsCount = (post240DetractorsCountMap.get(monthList[2]) != null)? post240DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post240Month4Count = (post240CountMap.get(monthList[3]) != null)? post240CountMap.get(monthList[3]) : 0;
        Decimal post240Month4PrometorsCount = (post240PrometorsCountMap.get(monthList[3]) != null)? post240PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post240Month4DetractorsCount = (post240DetractorsCountMap.get(monthList[3]) != null)? post240DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post240Month5Count = (post240CountMap.get(monthList[4]) != null)? post240CountMap.get(monthList[4]) : 0;
        Decimal post240Month5PrometorsCount = (post240PrometorsCountMap.get(monthList[4]) != null)? post240PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post240Month5DetractorsCount = (post240DetractorsCountMap.get(monthList[4]) != null)? post240DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post240Month6Count = (post240CountMap.get(monthList[5]) != null)? post240CountMap.get(monthList[5]) : 0;
        Decimal post240Month6PrometorsCount = (post240PrometorsCountMap.get(monthList[5]) != null)? post240PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post240Month6DetractorsCount = (post240DetractorsCountMap.get(monthList[5]) != null)? post240DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post240Month7Count = (post240CountMap.get(monthList[6]) != null)? post240CountMap.get(monthList[6]) : 0;
        Decimal post240Month7PrometorsCount = (post240PrometorsCountMap.get(monthList[6]) != null)? post240PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post240Month7DetractorsCount = (post240DetractorsCountMap.get(monthList[6]) != null)? post240DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post240Month8Count = (post240CountMap.get(monthList[7]) != null)? post240CountMap.get(monthList[7]) : 0;
        Decimal post240Month8PrometorsCount = (post240PrometorsCountMap.get(monthList[7]) != null)? post240PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post240Month8DetractorsCount = (post240DetractorsCountMap.get(monthList[7]) != null)? post240DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post240Month9Count = (post240CountMap.get(monthList[8]) != null)? post240CountMap.get(monthList[8]) : 0;
        Decimal post240Month9PrometorsCount = (post240PrometorsCountMap.get(monthList[8]) != null)? post240PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post240Month9DetractorsCount = (post240DetractorsCountMap.get(monthList[8]) != null)? post240DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post240Month10Count = (post240CountMap.get(monthList[9]) != null)? post240CountMap.get(monthList[9]) : 0;
        Decimal post240Month10PrometorsCount = (post240PrometorsCountMap.get(monthList[9]) != null)? post240PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post240Month10DetractorsCount = (post240DetractorsCountMap.get(monthList[9]) != null)? post240DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post240Month11Count = (post240CountMap.get(monthList[10]) != null)? post240CountMap.get(monthList[10]) : 0;
        Decimal post240Month11PrometorsCount = (post240PrometorsCountMap.get(monthList[10]) != null)? post240PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post240Month11DetractorsCount = (post240DetractorsCountMap.get(monthList[10]) != null)? post240DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post240Month12Count = (post240CountMap.get(monthList[11]) != null)? post240CountMap.get(monthList[11]) : 0;
        Decimal post240Month12PrometorsCount = (post240PrometorsCountMap.get(monthList[11]) != null)? post240PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post240Month12DetractorsCount = (post240DetractorsCountMap.get(monthList[11]) != null)? post240DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post300Month1Count = (post300CountMap.get(monthList[0]) != null)? post300CountMap.get(monthList[0]) : 0;
        Decimal post300Month1PrometorsCount = (post300PrometorsCountMap.get(monthList[0]) != null)? post300PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post300Month1DetractorsCount = (post300DetractorsCountMap.get(monthList[0]) != null)? post300DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post300Month2Count = (post300CountMap.get(monthList[1]) != null)? post300CountMap.get(monthList[1]) : 0;
        Decimal post300Month2PrometorsCount = (post300PrometorsCountMap.get(monthList[1]) != null)? post300PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post300Month2DetractorsCount = (post300DetractorsCountMap.get(monthList[1]) != null)? post300DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post300Month3Count = (post300CountMap.get(monthList[2]) != null)? post300CountMap.get(monthList[2]) : 0;
        Decimal post300Month3PrometorsCount = (post300PrometorsCountMap.get(monthList[2]) != null)? post300PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post300Month3DetractorsCount = (post300DetractorsCountMap.get(monthList[2]) != null)? post300DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post300Month4Count = (post300CountMap.get(monthList[3]) != null)? post300CountMap.get(monthList[3]) : 0;
        Decimal post300Month4PrometorsCount = (post300PrometorsCountMap.get(monthList[3]) != null)? post300PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post300Month4DetractorsCount = (post300DetractorsCountMap.get(monthList[3]) != null)? post300DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post300Month5Count = (post300CountMap.get(monthList[4]) != null)? post300CountMap.get(monthList[4]) : 0;
        Decimal post300Month5PrometorsCount = (post300PrometorsCountMap.get(monthList[4]) != null)? post300PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post300Month5DetractorsCount = (post300DetractorsCountMap.get(monthList[4]) != null)? post300DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post300Month6Count = (post300CountMap.get(monthList[5]) != null)? post300CountMap.get(monthList[5]) : 0;
        Decimal post300Month6PrometorsCount = (post300PrometorsCountMap.get(monthList[5]) != null)? post300PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post300Month6DetractorsCount = (post300DetractorsCountMap.get(monthList[5]) != null)? post300DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post300Month7Count = (post300CountMap.get(monthList[6]) != null)? post300CountMap.get(monthList[6]) : 0;
        Decimal post300Month7PrometorsCount = (post300PrometorsCountMap.get(monthList[6]) != null)? post300PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post300Month7DetractorsCount = (post300DetractorsCountMap.get(monthList[6]) != null)? post300DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post300Month8Count = (post300CountMap.get(monthList[7]) != null)? post300CountMap.get(monthList[7]) : 0;
        Decimal post300Month8PrometorsCount = (post300PrometorsCountMap.get(monthList[7]) != null)? post300PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post300Month8DetractorsCount = (post300DetractorsCountMap.get(monthList[7]) != null)? post300DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post300Month9Count = (post300CountMap.get(monthList[8]) != null)? post300CountMap.get(monthList[8]) : 0;
        Decimal post300Month9PrometorsCount = (post300PrometorsCountMap.get(monthList[8]) != null)? post300PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post300Month9DetractorsCount = (post300DetractorsCountMap.get(monthList[8]) != null)? post300DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post300Month10Count = (post300CountMap.get(monthList[9]) != null)? post300CountMap.get(monthList[9]) : 0;
        Decimal post300Month10PrometorsCount = (post300PrometorsCountMap.get(monthList[9]) != null)? post300PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post300Month10DetractorsCount = (post300DetractorsCountMap.get(monthList[9]) != null)? post300DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post300Month11Count = (post300CountMap.get(monthList[10]) != null)? post300CountMap.get(monthList[10]) : 0;
        Decimal post300Month11PrometorsCount = (post300PrometorsCountMap.get(monthList[10]) != null)? post300PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post300Month11DetractorsCount = (post300DetractorsCountMap.get(monthList[10]) != null)? post300DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post300Month12Count = (post300CountMap.get(monthList[11]) != null)? post300CountMap.get(monthList[11]) : 0;
        Decimal post300Month12PrometorsCount = (post300PrometorsCountMap.get(monthList[11]) != null)? post300PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post300Month12DetractorsCount = (post300DetractorsCountMap.get(monthList[11]) != null)? post300DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post330Month1Count = (post330CountMap.get(monthList[0]) != null)? post330CountMap.get(monthList[0]) : 0;
        Decimal post330Month1PrometorsCount = (post330PrometorsCountMap.get(monthList[0]) != null)? post330PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post330Month1DetractorsCount = (post330DetractorsCountMap.get(monthList[0]) != null)? post330DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post330Month2Count = (post330CountMap.get(monthList[1]) != null)? post330CountMap.get(monthList[1]) : 0;
        Decimal post330Month2PrometorsCount = (post330PrometorsCountMap.get(monthList[1]) != null)? post330PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post330Month2DetractorsCount = (post330DetractorsCountMap.get(monthList[1]) != null)? post330DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post330Month3Count = (post330CountMap.get(monthList[2]) != null)? post330CountMap.get(monthList[2]) : 0;
        Decimal post330Month3PrometorsCount = (post330PrometorsCountMap.get(monthList[2]) != null)? post330PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post330Month3DetractorsCount = (post330DetractorsCountMap.get(monthList[2]) != null)? post330DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post330Month4Count = (post330CountMap.get(monthList[3]) != null)? post330CountMap.get(monthList[3]) : 0;
        Decimal post330Month4PrometorsCount = (post330PrometorsCountMap.get(monthList[3]) != null)? post330PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post330Month4DetractorsCount = (post330DetractorsCountMap.get(monthList[3]) != null)? post330DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post330Month5Count = (post330CountMap.get(monthList[4]) != null)? post330CountMap.get(monthList[4]) : 0;
        Decimal post330Month5PrometorsCount = (post330PrometorsCountMap.get(monthList[4]) != null)? post330PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post330Month5DetractorsCount = (post330DetractorsCountMap.get(monthList[4]) != null)? post330DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post330Month6Count = (post330CountMap.get(monthList[5]) != null)? post330CountMap.get(monthList[5]) : 0;
        Decimal post330Month6PrometorsCount = (post330PrometorsCountMap.get(monthList[5]) != null)? post330PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post330Month6DetractorsCount = (post330DetractorsCountMap.get(monthList[5]) != null)? post330DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post330Month7Count = (post330CountMap.get(monthList[6]) != null)? post330CountMap.get(monthList[6]) : 0;
        Decimal post330Month7PrometorsCount = (post330PrometorsCountMap.get(monthList[6]) != null)? post330PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post330Month7DetractorsCount = (post330DetractorsCountMap.get(monthList[6]) != null)? post330DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post330Month8Count = (post330CountMap.get(monthList[7]) != null)? post330CountMap.get(monthList[7]) : 0;
        Decimal post330Month8PrometorsCount = (post330PrometorsCountMap.get(monthList[7]) != null)? post330PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post330Month8DetractorsCount = (post330DetractorsCountMap.get(monthList[7]) != null)? post330DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post330Month9Count = (post330CountMap.get(monthList[8]) != null)? post330CountMap.get(monthList[8]) : 0;
        Decimal post330Month9PrometorsCount = (post330PrometorsCountMap.get(monthList[8]) != null)? post330PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post330Month9DetractorsCount = (post330DetractorsCountMap.get(monthList[8]) != null)? post330DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post330Month10Count = (post330CountMap.get(monthList[9]) != null)? post330CountMap.get(monthList[9]) : 0;
        Decimal post330Month10PrometorsCount = (post330PrometorsCountMap.get(monthList[9]) != null)? post330PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post330Month10DetractorsCount = (post330DetractorsCountMap.get(monthList[9]) != null)? post330DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post330Month11Count = (post330CountMap.get(monthList[10]) != null)? post330CountMap.get(monthList[10]) : 0;
        Decimal post330Month11PrometorsCount = (post330PrometorsCountMap.get(monthList[10]) != null)? post330PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post330Month11DetractorsCount = (post330DetractorsCountMap.get(monthList[10]) != null)? post330DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post330Month12Count = (post330CountMap.get(monthList[11]) != null)? post330CountMap.get(monthList[11]) : 0;
        Decimal post330Month12PrometorsCount = (post330PrometorsCountMap.get(monthList[11]) != null)? post330PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post330Month12DetractorsCount = (post330DetractorsCountMap.get(monthList[11]) != null)? post330DetractorsCountMap.get(monthList[11]) : 0;
        
        Decimal post360Month1Count = (post360CountMap.get(monthList[0]) != null)? post360CountMap.get(monthList[0]) : 0;
        Decimal post360Month1PrometorsCount = (post360PrometorsCountMap.get(monthList[0]) != null)? post360PrometorsCountMap.get(monthList[0]) : 0;
        Decimal post360Month1DetractorsCount = (post360DetractorsCountMap.get(monthList[0]) != null)? post360DetractorsCountMap.get(monthList[0]) : 0;
        Decimal post360Month2Count = (post360CountMap.get(monthList[1]) != null)? post360CountMap.get(monthList[1]) : 0;
        Decimal post360Month2PrometorsCount = (post360PrometorsCountMap.get(monthList[1]) != null)? post360PrometorsCountMap.get(monthList[1]) : 0;
        Decimal post360Month2DetractorsCount = (post360DetractorsCountMap.get(monthList[1]) != null)? post360DetractorsCountMap.get(monthList[1]) : 0;
        Decimal post360Month3Count = (post360CountMap.get(monthList[2]) != null)? post360CountMap.get(monthList[2]) : 0;
        Decimal post360Month3PrometorsCount = (post360PrometorsCountMap.get(monthList[2]) != null)? post360PrometorsCountMap.get(monthList[2]) : 0;
        Decimal post360Month3DetractorsCount = (post360DetractorsCountMap.get(monthList[2]) != null)? post360DetractorsCountMap.get(monthList[2]) : 0;
        Decimal post360Month4Count = (post360CountMap.get(monthList[3]) != null)? post360CountMap.get(monthList[3]) : 0;
        Decimal post360Month4PrometorsCount = (post360PrometorsCountMap.get(monthList[3]) != null)? post360PrometorsCountMap.get(monthList[3]) : 0;
        Decimal post360Month4DetractorsCount = (post360DetractorsCountMap.get(monthList[3]) != null)? post360DetractorsCountMap.get(monthList[3]) : 0;
        Decimal post360Month5Count = (post360CountMap.get(monthList[4]) != null)? post360CountMap.get(monthList[4]) : 0;
        Decimal post360Month5PrometorsCount = (post360PrometorsCountMap.get(monthList[4]) != null)? post360PrometorsCountMap.get(monthList[4]) : 0;
        Decimal post360Month5DetractorsCount = (post360DetractorsCountMap.get(monthList[4]) != null)? post360DetractorsCountMap.get(monthList[4]) : 0;
        Decimal post360Month6Count = (post360CountMap.get(monthList[5]) != null)? post360CountMap.get(monthList[5]) : 0;
        Decimal post360Month6PrometorsCount = (post360PrometorsCountMap.get(monthList[5]) != null)? post360PrometorsCountMap.get(monthList[5]) : 0;
        Decimal post360Month6DetractorsCount = (post360DetractorsCountMap.get(monthList[5]) != null)? post360DetractorsCountMap.get(monthList[5]) : 0;
        Decimal post360Month7Count = (post360CountMap.get(monthList[6]) != null)? post360CountMap.get(monthList[6]) : 0;
        Decimal post360Month7PrometorsCount = (post360PrometorsCountMap.get(monthList[6]) != null)? post360PrometorsCountMap.get(monthList[6]) : 0;
        Decimal post360Month7DetractorsCount = (post360DetractorsCountMap.get(monthList[6]) != null)? post360DetractorsCountMap.get(monthList[6]) : 0;
        Decimal post360Month8Count = (post360CountMap.get(monthList[7]) != null)? post360CountMap.get(monthList[7]) : 0;
        Decimal post360Month8PrometorsCount = (post360PrometorsCountMap.get(monthList[7]) != null)? post360PrometorsCountMap.get(monthList[7]) : 0;
        Decimal post360Month8DetractorsCount = (post360DetractorsCountMap.get(monthList[7]) != null)? post360DetractorsCountMap.get(monthList[7]) : 0;
        Decimal post360Month9Count = (post360CountMap.get(monthList[8]) != null)? post360CountMap.get(monthList[8]) : 0;
        Decimal post360Month9PrometorsCount = (post360PrometorsCountMap.get(monthList[8]) != null)? post360PrometorsCountMap.get(monthList[8]) : 0;
        Decimal post360Month9DetractorsCount = (post360DetractorsCountMap.get(monthList[8]) != null)? post360DetractorsCountMap.get(monthList[8]) : 0;
        Decimal post360Month10Count = (post360CountMap.get(monthList[9]) != null)? post360CountMap.get(monthList[9]) : 0;
        Decimal post360Month10PrometorsCount = (post360PrometorsCountMap.get(monthList[9]) != null)? post360PrometorsCountMap.get(monthList[9]) : 0;
        Decimal post360Month10DetractorsCount = (post360DetractorsCountMap.get(monthList[9]) != null)? post360DetractorsCountMap.get(monthList[9]) : 0;
        Decimal post360Month11Count = (post360CountMap.get(monthList[10]) != null)? post360CountMap.get(monthList[10]) : 0;
        Decimal post360Month11PrometorsCount = (post360PrometorsCountMap.get(monthList[10]) != null)? post360PrometorsCountMap.get(monthList[10]) : 0;
        Decimal post360Month11DetractorsCount = (post360DetractorsCountMap.get(monthList[10]) != null)? post360DetractorsCountMap.get(monthList[10]) : 0;
        Decimal post360Month12Count = (post360CountMap.get(monthList[11]) != null)? post360CountMap.get(monthList[11]) : 0;
        Decimal post360Month12PrometorsCount = (post360PrometorsCountMap.get(monthList[11]) != null)? post360PrometorsCountMap.get(monthList[11]) : 0;
        Decimal post360Month12DetractorsCount = (post360DetractorsCountMap.get(monthList[11]) != null)? post360DetractorsCountMap.get(monthList[11]) : 0;
        
            npsScore post60Score = new npsScore();
            post60Score.fbType = 'Post Possession Handover 60 days';
            post60Score.month1 = (post60Month1Count != 0)? ((post60Month1PrometorsCount*100/post60Month1Count) - (post60Month1DetractorsCount*100/post60Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month2 = (post60Month2Count != 0)? ((post60Month2PrometorsCount*100/post60Month2Count) - (post60Month2DetractorsCount*100/post60Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month3 = (post60Month3Count != 0)? ((post60Month3PrometorsCount*100/post60Month3Count) - (post60Month3DetractorsCount*100/post60Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month4 = (post60Month4Count != 0)? ((post60Month4PrometorsCount*100/post60Month4Count) - (post60Month4DetractorsCount*100/post60Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month5 = (post60Month5Count != 0)? ((post60Month5PrometorsCount*100/post60Month5Count) - (post60Month5DetractorsCount*100/post60Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month6 = (post60Month6Count != 0)? ((post60Month6PrometorsCount*100/post60Month6Count) - (post60Month6DetractorsCount*100/post60Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month7 = (post60Month7Count != 0)? ((post60Month7PrometorsCount*100/post60Month7Count) - (post60Month7DetractorsCount*100/post60Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month8 = (post60Month8Count != 0)? ((post60Month8PrometorsCount*100/post60Month8Count) - (post60Month8DetractorsCount*100/post60Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month9 = (post60Month9Count != 0)? ((post60Month9PrometorsCount*100/post60Month9Count) - (post60Month9DetractorsCount*100/post60Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month10 = (post60Month10Count != 0)? ((post60Month10PrometorsCount*100/post60Month10Count) - (post60Month10DetractorsCount*100/post60Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month11 = (post60Month11Count != 0)? ((post60Month10PrometorsCount*100/post60Month11Count) - (post60Month11DetractorsCount*100/post60Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post60Score.month12 = (post60Month12Count != 0)? ((post60Month12PrometorsCount*100/post60Month12Count) - (post60Month12DetractorsCount*100/post60Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post60Score);
 	
        npsScore post90Score = new npsScore();
            post90Score.fbType = 'Post Possession Handover 90 days';
            post90Score.month1 = (post90Month1Count != 0)? ((post90Month1PrometorsCount*100/post90Month1Count) - (post90Month1DetractorsCount*100/post90Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month2 = (post90Month2Count != 0)? ((post90Month2PrometorsCount*100/post90Month2Count) - (post90Month2DetractorsCount*100/post90Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month3 = (post90Month3Count != 0)? ((post90Month3PrometorsCount*100/post90Month3Count) - (post90Month3DetractorsCount*100/post60Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month4 = (post90Month4Count != 0)? ((post90Month4PrometorsCount*100/post90Month4Count) - (post90Month4DetractorsCount*100/post90Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month5 = (post90Month5Count != 0)? ((post90Month5PrometorsCount*100/post90Month5Count) - (post90Month5DetractorsCount*100/post90Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month6 = (post90Month6Count != 0)? ((post90Month6PrometorsCount*100/post90Month6Count) - (post60Month6DetractorsCount*100/post60Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month7 = (post90Month7Count != 0)? ((post90Month7PrometorsCount*100/post90Month7Count) - (post90Month7DetractorsCount*100/post90Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month8 = (post90Month8Count != 0)? ((post90Month8PrometorsCount*100/post90Month8Count) - (post60Month8DetractorsCount*100/post60Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month9 = (post90Month9Count != 0)? ((post90Month9PrometorsCount*100/post90Month9Count) - (post90Month9DetractorsCount*100/post60Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month10 = (post90Month10Count != 0)? ((post90Month10PrometorsCount*100/post90Month10Count) - (post90Month10DetractorsCount*100/post90Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month11 = (post90Month11Count != 0)? ((post90Month10PrometorsCount*100/post90Month11Count) - (post90Month11DetractorsCount*100/post60Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post90Score.month12 = (post90Month12Count != 0)? ((post90Month12PrometorsCount*100/post90Month12Count) - (post90Month12DetractorsCount*100/post90Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post90Score);
        
        npsScore post120Score = new npsScore();
        post120Score.fbType = 'Post Possession Handover 120 days';
        post120Score.month1 = (post120Month1Count != 0)? ((post120Month1PrometorsCount*100/post120Month1Count) - (post120Month1DetractorsCount*100/post120Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month2 = (post120Month2Count != 0)? ((post120Month2PrometorsCount*100/post120Month2Count) - (post120Month2DetractorsCount*100/post120Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month3 = (post120Month3Count != 0)? ((post120Month3PrometorsCount*100/post120Month3Count) - (post120Month3DetractorsCount*100/post120Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month4 = (post120Month4Count != 0)? ((post120Month4PrometorsCount*100/post120Month4Count) - (post120Month4DetractorsCount*100/post120Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month5 = (post120Month5Count != 0)? ((post120Month5PrometorsCount*100/post120Month5Count) - (post120Month5DetractorsCount*100/post120Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month6 = (post120Month6Count != 0)? ((post120Month6PrometorsCount*100/post120Month6Count) - (post120Month6DetractorsCount*100/post120Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month7 = (post120Month7Count != 0)? ((post120Month7PrometorsCount*100/post120Month7Count) - (post120Month7DetractorsCount*100/post120Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month8 = (post120Month8Count != 0)? ((post120Month8PrometorsCount*100/post120Month8Count) - (post120Month8DetractorsCount*100/post120Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month9 = (post120Month9Count != 0)? ((post120Month9PrometorsCount*100/post120Month9Count) - (post120Month9DetractorsCount*100/post120Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month10 = (post120Month10Count != 0)? ((post120Month10PrometorsCount*100/post120Month10Count) - (post120Month10DetractorsCount*100/post120Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month11 = (post120Month11Count != 0)? ((post120Month10PrometorsCount*100/post120Month11Count) - (post120Month11DetractorsCount*100/post120Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post120Score.month12 = (post120Month12Count != 0)? ((post120Month12PrometorsCount*100/post120Month12Count) - (post120Month12DetractorsCount*100/post120Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post120Score);
        
        npsScore post150Score = new npsScore();
        post150Score.fbType = 'Post Possession Handover 150 days';
        post150Score.month1 = (post150Month1Count != 0)? ((post150Month1PrometorsCount*100/post150Month1Count) - (post150Month1DetractorsCount*100/post150Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month2 = (post150Month2Count != 0)? ((post150Month2PrometorsCount*100/post150Month2Count) - (post150Month2DetractorsCount*100/post150Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month3 = (post150Month3Count != 0)? ((post150Month3PrometorsCount*100/post150Month3Count) - (post150Month3DetractorsCount*100/post150Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month4 = (post150Month4Count != 0)? ((post150Month4PrometorsCount*100/post150Month4Count) - (post150Month4DetractorsCount*100/post150Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month5 = (post150Month5Count != 0)? ((post150Month5PrometorsCount*100/post150Month5Count) - (post150Month5DetractorsCount*100/post150Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month6 = (post150Month6Count != 0)? ((post150Month6PrometorsCount*100/post150Month6Count) - (post150Month6DetractorsCount*100/post150Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month7 = (post150Month7Count != 0)? ((post150Month7PrometorsCount*100/post150Month7Count) - (post150Month7DetractorsCount*100/post150Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month8 = (post150Month8Count != 0)? ((post150Month8PrometorsCount*100/post150Month8Count) - (post150Month8DetractorsCount*100/post150Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month9 = (post150Month9Count != 0)? ((post150Month9PrometorsCount*100/post150Month9Count) - (post150Month9DetractorsCount*100/post150Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month10 = (post150Month10Count != 0)? ((post150Month10PrometorsCount*100/post150Month10Count) - (post150Month10DetractorsCount*100/post150Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month11 = (post150Month11Count != 0)? ((post150Month10PrometorsCount*100/post150Month11Count) - (post150Month11DetractorsCount*100/post150Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post150Score.month12 = (post150Month12Count != 0)? ((post150Month12PrometorsCount*100/post150Month12Count) - (post150Month12DetractorsCount*100/post150Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post150Score);
        
        npsScore post180Score = new npsScore();
        post180Score.fbType = 'Post Possession Handover 180 days';
        post180Score.month1 = (post180Month1Count != 0)? ((post180Month1PrometorsCount*100/post180Month1Count) - (post180Month1DetractorsCount*100/post180Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month2 = (post180Month2Count != 0)? ((post180Month2PrometorsCount*100/post180Month2Count) - (post180Month2DetractorsCount*100/post180Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month3 = (post180Month3Count != 0)? ((post180Month3PrometorsCount*100/post180Month3Count) - (post180Month3DetractorsCount*100/post180Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month4 = (post180Month4Count != 0)? ((post180Month4PrometorsCount*100/post180Month4Count) - (post180Month4DetractorsCount*100/post180Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month5 = (post180Month5Count != 0)? ((post180Month5PrometorsCount*100/post180Month5Count) - (post180Month5DetractorsCount*100/post180Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month6 = (post180Month6Count != 0)? ((post180Month6PrometorsCount*100/post180Month6Count) - (post180Month6DetractorsCount*100/post180Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month7 = (post180Month7Count != 0)? ((post180Month7PrometorsCount*100/post180Month7Count) - (post180Month7DetractorsCount*100/post180Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month8 = (post180Month8Count != 0)? ((post180Month8PrometorsCount*100/post180Month8Count) - (post180Month8DetractorsCount*100/post180Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month9 = (post180Month9Count != 0)? ((post180Month9PrometorsCount*100/post180Month9Count) - (post180Month9DetractorsCount*100/post180Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month10 = (post180Month10Count != 0)? ((post180Month10PrometorsCount*100/post180Month10Count) - (post180Month10DetractorsCount*100/post180Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month11 = (post180Month11Count != 0)? ((post180Month10PrometorsCount*100/post180Month11Count) - (post180Month11DetractorsCount*100/post180Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post180Score.month12 = (post180Month12Count != 0)? ((post180Month12PrometorsCount*100/post180Month12Count) - (post180Month12DetractorsCount*100/post180Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post180Score);
        
        npsScore post210Score = new npsScore();
        post210Score.fbType = 'Post Possession Handover 210 days';
        post210Score.month1 = (post210Month1Count != 0)? ((post210Month1PrometorsCount*100/post210Month1Count) - (post210Month1DetractorsCount*100/post210Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month2 = (post210Month2Count != 0)? ((post210Month2PrometorsCount*100/post210Month2Count) - (post210Month2DetractorsCount*100/post210Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month3 = (post210Month3Count != 0)? ((post210Month3PrometorsCount*100/post210Month3Count) - (post210Month3DetractorsCount*100/post210Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month4 = (post210Month4Count != 0)? ((post210Month4PrometorsCount*100/post210Month4Count) - (post210Month4DetractorsCount*100/post210Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month5 = (post210Month5Count != 0)? ((post210Month5PrometorsCount*100/post210Month5Count) - (post210Month5DetractorsCount*100/post210Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month6 = (post210Month6Count != 0)? ((post210Month6PrometorsCount*100/post210Month6Count) - (post210Month6DetractorsCount*100/post210Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month7 = (post210Month7Count != 0)? ((post210Month7PrometorsCount*100/post210Month7Count) - (post210Month7DetractorsCount*100/post210Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month8 = (post210Month8Count != 0)? ((post210Month8PrometorsCount*100/post210Month8Count) - (post210Month8DetractorsCount*100/post210Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month9 = (post210Month9Count != 0)? ((post210Month9PrometorsCount*100/post210Month9Count) - (post210Month9DetractorsCount*100/post210Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month10 = (post210Month10Count != 0)? ((post210Month10PrometorsCount*100/post210Month10Count) - (post210Month10DetractorsCount*100/post210Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month11 = (post210Month11Count != 0)? ((post210Month10PrometorsCount*100/post210Month11Count) - (post210Month11DetractorsCount*100/post210Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post210Score.month12 = (post210Month12Count != 0)? ((post210Month12PrometorsCount*100/post210Month12Count) - (post210Month12DetractorsCount*100/post210Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post210Score);
        
        npsScore post240Score = new npsScore();
        post240Score.fbType = 'Post Possession Handover 240 days';
        post240Score.month1 = (post240Month1Count != 0)? ((post240Month1PrometorsCount*100/post240Month1Count) - (post240Month1DetractorsCount*100/post240Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month2 = (post240Month2Count != 0)? ((post240Month2PrometorsCount*100/post240Month2Count) - (post240Month2DetractorsCount*100/post240Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month3 = (post240Month3Count != 0)? ((post240Month3PrometorsCount*100/post240Month3Count) - (post240Month3DetractorsCount*100/post240Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month4 = (post240Month4Count != 0)? ((post240Month4PrometorsCount*100/post240Month4Count) - (post240Month4DetractorsCount*100/post240Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month5 = (post240Month5Count != 0)? ((post240Month5PrometorsCount*100/post240Month5Count) - (post240Month5DetractorsCount*100/post240Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month6 = (post240Month6Count != 0)? ((post240Month6PrometorsCount*100/post240Month6Count) - (post240Month6DetractorsCount*100/post240Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month7 = (post240Month7Count != 0)? ((post240Month7PrometorsCount*100/post240Month7Count) - (post240Month7DetractorsCount*100/post240Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month8 = (post240Month8Count != 0)? ((post240Month8PrometorsCount*100/post240Month8Count) - (post240Month8DetractorsCount*100/post240Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month9 = (post240Month9Count != 0)? ((post240Month9PrometorsCount*100/post240Month9Count) - (post240Month9DetractorsCount*100/post240Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month10 = (post240Month10Count != 0)? ((post240Month10PrometorsCount*100/post240Month10Count) - (post240Month10DetractorsCount*100/post240Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month11 = (post240Month11Count != 0)? ((post240Month10PrometorsCount*100/post240Month11Count) - (post240Month11DetractorsCount*100/post240Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post240Score.month12 = (post240Month12Count != 0)? ((post240Month12PrometorsCount*100/post240Month12Count) - (post240Month12DetractorsCount*100/post240Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post240Score);
        
        npsScore post270Score = new npsScore();
        post270Score.fbType = 'Post Possession Handover 270 days';
        post270Score.month1 = (post270Month1Count != 0)? ((post270Month1PrometorsCount*100/post270Month1Count) - (post270Month1DetractorsCount*100/post270Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month2 = (post270Month2Count != 0)? ((post270Month2PrometorsCount*100/post270Month2Count) - (post270Month2DetractorsCount*100/post270Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month3 = (post270Month3Count != 0)? ((post270Month3PrometorsCount*100/post270Month3Count) - (post270Month3DetractorsCount*100/post270Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month4 = (post270Month4Count != 0)? ((post270Month4PrometorsCount*100/post270Month4Count) - (post270Month4DetractorsCount*100/post270Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month5 = (post270Month5Count != 0)? ((post270Month5PrometorsCount*100/post270Month5Count) - (post270Month5DetractorsCount*100/post270Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month6 = (post270Month6Count != 0)? ((post270Month6PrometorsCount*100/post270Month6Count) - (post270Month6DetractorsCount*100/post270Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month7 = (post270Month7Count != 0)? ((post270Month7PrometorsCount*100/post270Month7Count) - (post270Month7DetractorsCount*100/post270Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month8 = (post270Month8Count != 0)? ((post270Month8PrometorsCount*100/post270Month8Count) - (post270Month8DetractorsCount*100/post270Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month9 = (post270Month9Count != 0)? ((post270Month9PrometorsCount*100/post270Month9Count) - (post270Month9DetractorsCount*100/post270Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month10 = (post270Month10Count != 0)? ((post270Month10PrometorsCount*100/post270Month10Count) - (post270Month10DetractorsCount*100/post270Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month11 = (post270Month11Count != 0)? ((post270Month10PrometorsCount*100/post270Month11Count) - (post270Month11DetractorsCount*100/post270Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post270Score.month12 = (post270Month12Count != 0)? ((post270Month12PrometorsCount*100/post270Month12Count) - (post270Month12DetractorsCount*100/post270Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post270Score);
        
        
        
                
        npsScore post360Score = new npsScore();
        post360Score.fbType = 'Post Possession Handover 360 days';
        post360Score.month1 = (post360Month1Count != 0)? ((post360Month1PrometorsCount*100/post360Month1Count) - (post360Month1DetractorsCount*100/post360Month1Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month2 = (post360Month2Count != 0)? ((post360Month2PrometorsCount*100/post360Month2Count) - (post360Month2DetractorsCount*100/post360Month2Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month3 = (post360Month3Count != 0)? ((post360Month3PrometorsCount*100/post360Month3Count) - (post360Month3DetractorsCount*100/post360Month3Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month4 = (post360Month4Count != 0)? ((post360Month4PrometorsCount*100/post360Month4Count) - (post360Month4DetractorsCount*100/post360Month4Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month5 = (post360Month5Count != 0)? ((post360Month5PrometorsCount*100/post360Month5Count) - (post360Month5DetractorsCount*100/post360Month5Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month6 = (post360Month6Count != 0)? ((post360Month6PrometorsCount*100/post360Month6Count) - (post360Month6DetractorsCount*100/post360Month6Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month7 = (post360Month7Count != 0)? ((post360Month7PrometorsCount*100/post360Month7Count) - (post360Month7DetractorsCount*100/post360Month7Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month8 = (post360Month8Count != 0)? ((post360Month8PrometorsCount*100/post360Month8Count) - (post360Month8DetractorsCount*100/post360Month8Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month9 = (post360Month9Count != 0)? ((post360Month9PrometorsCount*100/post360Month9Count) - (post360Month9DetractorsCount*100/post360Month9Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month10 = (post360Month10Count != 0)? ((post360Month10PrometorsCount*100/post360Month10Count) - (post360Month10DetractorsCount*100/post360Month10Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month11 = (post360Month11Count != 0)? ((post360Month10PrometorsCount*100/post360Month11Count) - (post360Month11DetractorsCount*100/post360Month11Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            post360Score.month12 = (post360Month12Count != 0)? ((post360Month12PrometorsCount*100/post360Month12Count) - (post360Month12DetractorsCount*100/post360Month12Count)).setscale(0,RoundingMode.HALF_UP) : 0;
            scores.add(post360Score);
        
        npsScore totalScore = new npsScore();
        totalScore.fbType = 'Total';
        
        totalScore.month1 = ((post60Month1Count + post120Month1Count + post180Month1Count + post270Month1Count + post360Month1Count) != 0)? (((post60Month1PrometorsCount + post120Month1PrometorsCount + post180Month1PrometorsCount + post270Month1PrometorsCount + post360Month1PrometorsCount)*100/(post60Month1Count + post120Month1Count + post180Month1Count + post270Month1Count + post360Month1Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month1DetractorsCount + post120Month1DetractorsCount + post180Month1DetractorsCount + post270Month1DetractorsCount + post360Month1DetractorsCount)*100/(post60Month1Count + post120Month1Count + post180Month1Count + post270Month1Count + post360Month1Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month2 = ((post60Month2Count + post120Month2Count + post180Month2Count + post270Month2Count + post360Month2Count) != 0)? (((post60Month2PrometorsCount + post120Month2PrometorsCount + post180Month2PrometorsCount + post270Month2PrometorsCount + post360Month2PrometorsCount)*100/(post60Month2Count + post120Month2Count + post180Month2Count + post270Month2Count + post360Month2Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month2DetractorsCount + post120Month2DetractorsCount + post180Month2DetractorsCount + post270Month2DetractorsCount + post360Month2DetractorsCount)*100/(post60Month2Count + post120Month2Count + post180Month2Count + post270Month2Count + post360Month2Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month3 = ((post60Month3Count + post120Month3Count + post180Month3Count + post270Month3Count + post360Month3Count) != 0)? (((post60Month3PrometorsCount + post120Month3PrometorsCount + post180Month3PrometorsCount + post270Month3PrometorsCount + post360Month3PrometorsCount)*100/(post60Month3Count + post120Month3Count + post180Month3Count + post270Month3Count + post360Month3Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month3DetractorsCount + post120Month3DetractorsCount + post180Month3DetractorsCount + post270Month3DetractorsCount + post360Month3DetractorsCount)*100/(post60Month3Count + post120Month3Count + post180Month3Count + post270Month3Count + post360Month3Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month4 = ((post60Month4Count + post120Month4Count + post180Month4Count + post270Month4Count + post360Month4Count) != 0)? (((post60Month4PrometorsCount + post120Month4PrometorsCount + post180Month4PrometorsCount + post270Month4PrometorsCount + post360Month4PrometorsCount)*100/(post60Month4Count + post120Month4Count + post180Month4Count + post270Month4Count + post360Month4Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month4DetractorsCount + post120Month4DetractorsCount + post180Month4DetractorsCount + post270Month4DetractorsCount + post360Month4DetractorsCount)*100/(post60Month4Count + post120Month4Count + post180Month4Count + post270Month4Count + post360Month4Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month5 = ((post60Month5Count + post120Month5Count + post180Month5Count + post270Month5Count + post360Month5Count) != 0)? (((post60Month5PrometorsCount + post120Month5PrometorsCount + post180Month5PrometorsCount + post270Month5PrometorsCount + post360Month5PrometorsCount)*100/(post60Month5Count + post120Month5Count + post180Month5Count + post270Month5Count + post360Month5Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month5DetractorsCount + post120Month5DetractorsCount + post180Month5DetractorsCount + post270Month5DetractorsCount + post360Month5DetractorsCount)*100/(post60Month5Count + post120Month5Count + post180Month5Count + post270Month5Count + post360Month5Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month6 = ((post60Month6Count + post120Month6Count + post180Month6Count + post270Month6Count + post360Month6Count) != 0)? (((post60Month6PrometorsCount + post120Month6PrometorsCount + post180Month6PrometorsCount + post270Month6PrometorsCount + post360Month6PrometorsCount)*100/(post60Month6Count + post120Month6Count + post180Month6Count + post270Month6Count + post360Month6Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month6DetractorsCount + post120Month6DetractorsCount + post180Month6DetractorsCount + post270Month6DetractorsCount + post360Month6DetractorsCount)*100/(post60Month6Count + post120Month6Count + post180Month6Count + post270Month6Count + post360Month6Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month7 = ((post60Month7Count + post120Month7Count + post180Month7Count + post270Month7Count + post360Month7Count) != 0)? (((post60Month7PrometorsCount + post120Month7PrometorsCount + post180Month7PrometorsCount + post270Month7PrometorsCount + post360Month7PrometorsCount)*100/(post60Month7Count + post120Month7Count + post180Month7Count + post270Month7Count + post360Month7Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month7DetractorsCount + post120Month7DetractorsCount + post180Month7DetractorsCount + post270Month7DetractorsCount + post360Month7DetractorsCount)*100/(post60Month7Count + post120Month7Count + post180Month7Count + post270Month7Count + post360Month7Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month8 = ((post60Month8Count + post120Month8Count + post180Month8Count + post270Month8Count + post360Month8Count) != 0)? (((post60Month8PrometorsCount + post120Month8PrometorsCount + post180Month8PrometorsCount + post270Month8PrometorsCount + post360Month8PrometorsCount)*100/(post60Month8Count + post120Month8Count + post180Month8Count + post270Month8Count + post360Month8Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month8DetractorsCount + post120Month8DetractorsCount + post180Month8DetractorsCount + post270Month8DetractorsCount + post360Month8DetractorsCount)*100/(post60Month8Count + post120Month8Count + post180Month8Count + post270Month8Count + post360Month8Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month9 = ((post60Month9Count + post120Month9Count + post180Month9Count + post270Month9Count + post360Month9Count) != 0)? (((post60Month9PrometorsCount + post120Month9PrometorsCount + post180Month9PrometorsCount + post270Month9PrometorsCount + post360Month9PrometorsCount)*100/(post60Month9Count + post120Month9Count + post180Month9Count + post270Month9Count + post360Month9Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month9DetractorsCount + post120Month9DetractorsCount + post180Month9DetractorsCount + post270Month9DetractorsCount + post360Month9DetractorsCount)*100/(post60Month9Count + post120Month9Count + post180Month9Count + post270Month9Count + post360Month9Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month10 = ((post60Month10Count + post120Month10Count + post180Month10Count + post270Month10Count + post360Month10Count) != 0)? (((post60Month10PrometorsCount + post120Month10PrometorsCount + post180Month10PrometorsCount + post270Month10PrometorsCount + post360Month10PrometorsCount)*100/(post60Month10Count + post120Month10Count + post180Month10Count + post270Month10Count + post360Month10Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month10DetractorsCount + post120Month10DetractorsCount + post180Month10DetractorsCount + post270Month10DetractorsCount + post360Month10DetractorsCount)*100/(post60Month10Count + post120Month10Count + post180Month10Count + post270Month10Count + post360Month10Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month11 = ((post60Month11Count + post120Month11Count + post180Month11Count + post270Month11Count + post360Month11Count) != 0)? (((post60Month11PrometorsCount + post120Month11PrometorsCount + post180Month11PrometorsCount + post270Month11PrometorsCount + post360Month11PrometorsCount)*100/(post60Month11Count + post120Month11Count + post180Month11Count + post270Month11Count + post360Month11Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month11DetractorsCount + post120Month11DetractorsCount + post180Month11DetractorsCount + post270Month11DetractorsCount + post360Month11DetractorsCount)*100/(post60Month11Count + post120Month11Count + post180Month11Count + post270Month11Count + post360Month11Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        totalScore.month12 = ((post60Month12Count + post120Month12Count + post180Month12Count + post270Month12Count + post360Month12Count) != 0)? (((post60Month12PrometorsCount + post120Month12PrometorsCount + post180Month12PrometorsCount + post270Month12PrometorsCount + post360Month12PrometorsCount)*100/(post60Month12Count + post120Month12Count + post180Month12Count + post270Month12Count + post360Month12Count)).setscale(0,RoundingMode.HALF_UP) - 
            				((post60Month12DetractorsCount + post120Month12DetractorsCount + post180Month12DetractorsCount + post270Month12DetractorsCount + post360Month12DetractorsCount)*100/(post60Month12Count + post120Month12Count + post180Month12Count + post270Month12Count + post360Month12Count)).setscale(0,RoundingMode.HALF_UP)) : 0;
        scores.add(totalScore);
        System.debug('scores: ' + scores);
        return scores;
    }*/
    
    @auraEnabled
    public static List<WhatsApp_Feedback__c> eventWiseData(String team, String dateRange, String year, String month, String eventType){
        
		eventType = eventType.replace('Post Possession Handover ','');
        eventType = eventType.replace(' days','');
		        
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            qry = WhatsAppFeedbackBotReportsController.yearMonthQueryBuilder(team, year, month);
            if(eventType == '60'){
                qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND (Post_Possession_Frequency_Days__c = ' + eventType + ' OR Post_Possession_Frequency_Days__c = null)';
            }else{
                qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND Post_Possession_Frequency_Days__c = ' + eventType;
            }
        }else{
            qry = WhatsAppFeedbackBotReportsController.eventReportQueryBuilder(team, dateRange);
            if((team != null && team != '') || (dateRange != null && dateRange != '' && dateRange != 'Custom')){
                if(eventType == '60'){
                    qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND (Post_Possession_Frequency_Days__c = ' + eventType + ' OR Post_Possession_Frequency_Days__c = null)';
                }else{
                    qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND Post_Possession_Frequency_Days__c = ' + eventType;
                }
            }else{
                if(eventType == '60'){
                    qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND (Post_Possession_Frequency_Days__c = ' + eventType + ' OR Post_Possession_Frequency_Days__c = null)';
                }else{
                    qry += ' AND Feedback_Type__c = \'Post Possession Handover\' AND Post_Possession_Frequency_Days__c = ' + eventType;
                }
            }
        }
        System.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> fbList = Database.query(qry);
        return fbList;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> npsWiseData(String fbType, String team, String dateRange, String year, String month, String project, String nps){
        
        String feedbackType;
        Decimal freq;
        
        if(fbType != null){
            fbType = fbType.replace('Post Possession Handover ','');
        	fbType = fbType.replace(' days','');
            feedbackType = 'Post Possession Handover';
            freq = Decimal.valueOf(fbType);
        }
        
        
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE ';
        String teamQry = WhatsAppFeedbackBotReportsController.teamQuery(team);
        
        if(project == 'All Projects'){
            if(freq == 60){
                qry += teamQry + ' AND Feedback_Type__c =: feedbackType AND (Post_Possession_Frequency_Days__c =: freq OR Post_Possession_Frequency_Days__c = null) AND NPS__c =: nps';
            }else{
                qry += teamQry + ' AND Feedback_Type__c =: feedbackType AND Post_Possession_Frequency_Days__c =: freq AND NPS__c =: nps';
            }
        }else{
            if(freq == 60){
                qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType AND NPS__c =: nps AND (Post_Possession_Frequency_Days__c =: freq OR Post_Possession_Frequency_Days__c = null)';
            }else{
                qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType AND NPS__c =: nps AND Post_Possession_Frequency_Days__c =: freq';
            }
            
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
        System.debug('qry: ' + qry);
        List<WhatsApp_Feedback__c> feedbacks = Database.query(qry);
        return feedbacks;
    }
    
    @AuraEnabled
    public static List<WhatsApp_Feedback__c> npsWiseDataPPD(String fbType, String team, String dateRange, String year, String month, String project, String nps){
        
        String feedbackType;
        Decimal freq;
        
        if(fbType != null){
            fbType = fbType.replace('Post Possession Handover ','');
        	fbType = fbType.replace(' days','');
            feedbackType = 'Post Possession Handover';
            freq = Decimal.valueOf(fbType);
        }
        
        String qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Opportunity__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE ';
        String teamQry = WhatsAppFeedbackBotReportsController.teamQuery(team);
        
        if(project == 'All Projects'){
            if(freq == 60){
                qry += teamQry + ' AND Feedback_Type__c =: feedbackType AND (Post_Possession_Frequency_Days__c =: freq OR Post_Possession_Frequency_Days__c = null)';
            }else{
                qry += teamQry + ' AND Feedback_Type__c =: feedbackType AND Post_Possession_Frequency_Days__c =: freq';
            }
        }else{
            if(freq == 60){
                qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType AND (Post_Possession_Frequency_Days__c =: freq OR Post_Possession_Frequency_Days__c = null)';
            }else{
                qry = 'SELECT Id, Name, Project__c, CRN__c, Opportunity_Name__c, Feedback_Type__c, NPS__c  FROM WhatsApp_Feedback__c WHERE Project__c =: project AND Feedback_Type__c =: feedbackType AND Post_Possession_Frequency_Days__c =: freq';
            }
        }
        
        if(nps == 'promoters'){
            qry += ' AND (NPS__c = \'10\' OR NPS__c = \'09\')';
        }else if(nps == 'passives'){
            qry += ' AND (NPS__c = \'08\' OR NPS__c = \'07\')';
        }else if(nps == 'detractors'){
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
    
    @AuraEnabled(cacheable=true)
    public static List<WhatsApp_Feedback__c> overAllDataExp(String userTeam, String dateRange, String year, String month){
   		        
        List<WhatsApp_Feedback__c> fbList = new List<WhatsApp_Feedback__c>();
        String qry;
        if(year != null && year != '' && month != null && month != ''){
            System.debug('--1');
            qry = WhatsAppFeedbackBotReportsController.yearMonthQueryBuilder(userTeam, year, month);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            fbList = Database.query(qry);
        }else{
            System.debug('--2');
            qry = WhatsAppFeedbackBotReportsController.eventReportQueryBuilder(userTeam, dateRange);
            qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
            System.debug('qry: ' + qry);
            fbList = Database.query(qry);
        }
        System.debug('fbList size: ' + fbList.size());
        System.debug('fbList : ' + fbList);
        return fbList;
    }
    
    
    @auraEnabled(cacheable=true)
    public static List<npsScore> npsSummaryForYear(){
         User usr = [SELECT Id, Feedback_Team__c, NPS_Feedback_Team__c,Show_CP_Case_Dashboard__c,Name FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('usr: ' + usr.Feedback_Team__c); 
        String team = usr.Feedback_Team__c;
        
        Date dt = System.today(); 
        Integer month = dt.Month(); 
        Integer year = dt.Year(); 
        Date lastYearDate = dt.addDays(-365);
        
        String qry;
        qry = 'SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c, Post_Possession_Frequency_Days__c  FROM WhatsApp_Feedback__c';
        String teamQry = WhatsAppFeedbackBotReportsController.teamQuery(team);
        
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
        qry += ' AND Feedback_Type__c = \'Post Possession Handover\'';
        if(!Test.isRunningTest()){
            fbList = Database.query(qry);
        }else{
            fbList = [SELECT Id, Name, Project__c, NPS__c, CRN__c, Mobile_Number__c, Opportunity__c, Opportunity_Name__c, Feedback_Type__c, Month__c, Year__c, Post_Possession_Frequency_Days__c  FROM WhatsApp_Feedback__c LIMIT 10];
        }
        System.debug('fbList: ' + fbList);
        Map<String, Integer> fbCount = new Map<String, Integer>();
        Map<String, Integer> fbPromotorsCount = new Map<String, Integer>();
        Map<String, Integer> fbDetractorsCount = new Map<String, Integer>();
        List<String> frequency = new List<String>{'60', '90', '120', '150', '180', '210', '240', '270', '300', '330', '360'};
        
        Map<String,Integer> countsMap = new Map<String,Integer>();
        for(Integer i=0;i<12;i++){
            for(String freq : frequency){
                fbCount.put('Post ' + freq + ' Days ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month(),0);
                fbPromotorsCount.put('Post ' + freq + ' Days ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month(),0);
                fbDetractorsCount.put('Post ' + freq + ' Days ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month(),0);
            }
        }
        
        for(WhatsApp_Feedback__c fb : fbList){
            System.debug('fb.Post_Possession_Frequency_Days__c: ' + fb.Post_Possession_Frequency_Days__c);
            if(fb.Post_Possession_Frequency_Days__c != null){
                if(fbCount.containsKey('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)){
                    fbCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, fbCount.get('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)+1);
                }else{
                    fbCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, 1);
                }
                if(fb.NPS__c == '10' || fb.NPS__c == '09'){
                    if(fbPromotorsCount.containsKey('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)){
                        fbPromotorsCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, fbPromotorsCount.get('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)+1);
                    }else{
                        fbPromotorsCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, 1);
                    } 
                }else if(fb.NPS__c == '06' || fb.NPS__c == '05' || fb.NPS__c == '04' || fb.NPS__c == '03' || fb.NPS__c == '02' || fb.NPS__c == '01'){
                    if(fbDetractorsCount.containsKey('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)){
                        fbDetractorsCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, fbDetractorsCount.get('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c)+1);
                    }else{
                        fbDetractorsCount.put('Post ' + fb.Post_Possession_Frequency_Days__c + ' Days ' + fb.Year__c + '-' + fb.Month__c, 1);
                    }
                }  
            }
        }
        
        Map<String, Decimal> scoresMap = new Map<String, Decimal>();
        List<npsScore> scores = new List<npsScore>();
        
        /*npsScore yearDetails = new npsScore();
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
        scores.add(monthDetails);*/
        
        Map<String, Decimal> totalScoreMap = new Map<String, Decimal>();
        npsScore totalScr = new npsScore();
        totalScr.fbType = 'Total';
        for(String freq : frequency){
            npsScore scr = new npsScore();
            scr.fbType = 'Post Possession Handover ' + freq + ' Days ';
           
            for(Integer i=0;i<12;i++){
                Decimal score = 0;
                if(fbCount.get('Post ' + freq + ' Days ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month()) != 0){
                    score = (fbPromotorsCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) * 100)/fbCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) - 
                					(fbDetractorsCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) * 100)/fbCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]);
                }

                //if(fbCount.get('Post ' + freq + ' Days ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month()) != 0){
                    
					/*score = (fbPromotorsCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) * 100)/fbCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) - 
                					(fbDetractorsCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]) * 100)/fbCount.get('Post ' + freq + ' Days ' + yearList[i] + '-' + monthList[i]);*/
                                        
                    if(i == 0){
                        scr.month1 = score;
                        if(totalScr.month1 != null){
                            totalScr.month1 += score;
                        }else{
                            totalScr.month1 = score;
                        }
                    }else if(i == 1){
                        scr.month2 = score;
                        if(totalScr.month2 != null){
                            totalScr.month2 += score;
                        }else{
                            totalScr.month2 = score;
                        }
                    }else if(i == 2){
                        scr.month3 = score;
                        if(totalScr.month3 != null){
                            totalScr.month3 += score;
                        }else{
                            totalScr.month3 = score;
                        }
                    }else if(i == 3){
                        scr.month4 = score;
                        if(totalScr.month4 != null){
                            totalScr.month4 += score;
                        }else{
                            totalScr.month4 = score;
                        }
                    }else if(i == 4){
                        scr.month5 = score;
                        if(totalScr.month5 != null){
                            totalScr.month5 += score;
                        }else{
                            totalScr.month5 = score;
                        }
                    }else if(i == 5){
                        scr.month6 = score;
                        if(totalScr.month6 != null){
                            totalScr.month6 += score;
                        }else{
                            totalScr.month6 = score;
                        }
                    }else if(i == 6){
                        scr.month7 = score;
                        if(totalScr.month7 != null){
                            totalScr.month7 += score;
                        }else{
                            totalScr.month7 = score;
                        }
                    }else if(i == 7){
                        scr.month8 = score;
                        if(totalScr.month8 != null){
                            totalScr.month8 += score;
                        }else{
                            totalScr.month8 = score;
                        }
                    }else if(i == 8){
                        scr.month9 = score;
                        if(totalScr.month9 != null){
                            totalScr.month9 += score;
                        }else{
                            totalScr.month9 = score;
                        }
                    }else if(i == 9){
                        scr.month10 = score;
                        if(totalScr.month10 != null){
                            totalScr.month10 += score;
                        }else{
                            totalScr.month10 = score;
                        }
                    }else if(i == 10){
                        scr.month11 = score;
                        if(totalScr.month11 != null){
                            totalScr.month11 += score;
                        }else{
                            totalScr.month11 = score;
                        }
                    }else if(i == 11){
                        scr.month12 = score;
                        if(totalScr.month12 != null){
                            totalScr.month12 += score;
                        }else{
                            totalScr.month12 = score;
                        }
                    }
                //}
            }
            scores.add(scr);
        }
        scores.add(totalScr);
        return scores;
    }
    
    @auraEnabled(cacheable=true)
    public static List<npsScore> npsSummaryYearMonthValues(){

        Date dt = System.today(); 
        
        List<Integer> yearList = new List<Integer>();
        List<Integer> monthList = new List<Integer>();
        for(Integer i=0;i<12;i++){
            System.debug('Date: ' + dt.addMonths(-i).Year() + '-' + dt.addMonths(-i).Month());
            monthList.add(dt.addMonths(-i).Month());
            yearList.add(dt.addMonths(-i).Year());
        }

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
        return scores;
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
        public String promoters_per_color;
        @auraEnabled
        public Decimal passives_per;
        @auraEnabled
        public Decimal detractors_per;
        @auraEnabled
        public String detractors_per_color;
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
    
    
}