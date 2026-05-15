public with sharing class MarketingDashboardController {

    private static final String K_TARGET_LEADS = 'targetLeads';
    private static final String K_ACTUAL_LEADS = 'actualLeads';
    private static final String K_TARGET_WALKINS = 'targetWalkins';
    private static final String K_ACTUAL_WALKINS = 'actualWalkins';
    private static final String K_TARGET_BKG_UNITS = 'targetBookingUnits';
    private static final String K_ACTUAL_BKG_UNITS = 'actualBookingUnits';
    private static final String K_TARGET_BKG_REV = 'targetBookingRev';
    private static final String K_ACTUAL_BKG_REV = 'actualBookingRev';

    private static Integer parseYear(String year) {
        if (String.isBlank(year)) {
            throw new AuraHandledException('Year is required');
        }
        Integer y = Integer.valueOf(year);
        if (y < 2000 || y > 2100) {
            throw new AuraHandledException('Year out of range');
        }
        return y;
    }
    private static Integer parseMonth(String month) {
        if (String.isBlank(month)) return null;
        Integer m = Integer.valueOf(month);
        if (m < 1 || m > 12) throw new AuraHandledException('Month out of range');
        return m;
    }
    private static Decimal calculatePercent(Decimal achieved, Decimal target) {
        if (target == null || target == 0 || achieved == null) return 0;
        return (achieved / target * 100).setScale(2, RoundingMode.HALF_UP);
    }
    private static Decimal toCrores(Decimal amount) {
        if (amount == null) return 0;
        return (amount / 10000000).setScale(2, RoundingMode.HALF_UP);
    }

    @AuraEnabled(cacheable=true)
    public static List<ProjectWrapper> getProjects(String table) {
        List<ProjectWrapper> projectList = new List<ProjectWrapper>();
        projectList.add(new ProjectWrapper('All', 'All'));
        for(Project__c proj : [SELECT Id, Name FROM Project__c WHERE RW_Status__c = 'Active' ORDER BY Name]){
            if(table == 'table5'){
                projectList.add(new ProjectWrapper(proj.Name, proj.Name));
            }else{
                if(proj.Name != 'Runwal Garden City'){
                    projectList.add(new ProjectWrapper(proj.Name, proj.Name));
                }
            }
        }
        return projectList;
    }

    public class ProjectWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public ProjectWrapper(String value, String label) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled
    public static List<Map<String, Object>> getTableData(String tableType, String year, List<String> months, List<String> sources, String dateRange, String project) {
        Integer selYear;
        Integer selMonth;

        System.debug('months: ' + months);
        System.debug('sources: ' + sources);
        String month = (months != null && months.size() > 0)? months[0] : '';
        String source = (sources != null && sources.size() > 0)? sources[0] : '';
        
        /*try {
            selYear = parseYear(year);
            selMonth = parseMonth(month);
        } catch (Exception e) {
            return new List<Map<String, Object>>();
        }*/
        

        switch on tableType {
            when 'table1' { return getLeadWalkinBookingLogic(year, months, source, project); }
            when 'table2' { return getLeadStatusLogic(year, months, sources, dateRange, project); }
            when 'table3' { return getJunkPercentageLogic(sources, dateRange, project, year, months); }
            when 'table4' { return getWalkinToBookingConversionLogic(sources, dateRange, project, year, months); }
            when 'table5' { return getDigitalBudgetLogic(year, months, project); }
            when 'table6' { return getMediaSummaryLogic(year, months, sources, dateRange, project); }
            when 'table7' { return spendsTable(year, months, sources, dateRange, project); }
            when else { return new List<Map<String, Object>>(); }
        }
    }

    private static String queryFilterBuilder(String table, String objName, String source, String project, String dateRange, String year, List<String> months){
        Integer year_Int = (year != '')? Integer.valueOf(year) : null;
        List<Integer> months_Int = new List<Integer>();
        for(String mnth : months){
            months_Int.add(Integer.valueOf(mnth));
        }
        System.debug('months: ' + months);
        System.debug('months: ' + months.size());
        String qry = '';
        if(table == 'table1'){
            List<String> leadSources;
            if(source == 'Digital'){
                leadSources = new List<String>{'Digital','Facebook','Property Portals'};
            }else if(source == 'Direct'){
                leadSources = new List<String>{'Direct','Events','Exhibitions','Hoarding','Magazines','Newspapers','Paper Inserts','Radio','Surround Marketing','TV'};
            }else if(source == 'Presales/Direct'){
                leadSources = new List<String>{'Presales','Individual calling','Corporate' };
            }
            if(objName == 'Company_Target__c'){
                qry += ' WHERE Projects__c != null AND Projects__r.Name != \'Runwal Garden City\' AND Projects__r.RW_Status__c = \'Active\'';
                qry += ' AND (of_Leads__c != null OR Walkins_Target__c != null OR Booking_count_target__c != null)';
                if(source != null && source != ''){
                    qry += ' AND Verticals__c =: vertical';
                }
                if(year != null && year != ''){
                    qry += ' AND Year__c =: year';
                    if(months.size() > 0){
                        qry += ' AND Month__c IN: months';
                    }
                }
                if(project != 'All'){
                    qry += ' AND Projects__r.Name =: project';
                }
            }
            if(objName == 'Lead'){
                qry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
                if(leadSources != null && leadSources.size() > 0){
                    qry += ' AND LeadSource IN: leadSources';
                }
                if(year != null && year != ''){
                    qry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
                    if(months != null && months.size() > 0){
                        qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
                    }
                }
                if(project != 'All'){
                    qry += ' AND RW_Project__r.Name =: project';
                }
            }
            if(objName == 'Opportunity'){
                qry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
                if(leadSources != null && leadSources.size() > 0){
                    qry += ' AND LeadSource IN: leadSources';
                }
                if(year != null && year != ''){
                    qry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
                    if(months != null && months.size() > 0){
                        qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
                    }
                }
                if(project != 'All'){
                    qry += ' AND RW_Project__r.Name =: project';
                }
            }
            if(objName == 'Booking__c'){
                qry += ' WHERE Project__c != null AND Project__r.RW_Status__c = \'Active\' AND Project__r.Name != \'Runwal Garden City\'';
                if(leadSources != null && leadSources.size() > 0){
                    qry += ' AND Opportunity__r.LeadSource IN: leadSources';
                }
                if(year != null && year != ''){
                    qry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
                    if(months != null && months.size() > 0){
                        qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
                    }
                }
                if(project != 'All'){
                    qry += ' AND Project__r.Name =: project';
                }
            }
        }
        return qry;
    }

    private static List<Map<String, Object>> getLeadWalkinBookingLogic(String year, List<String> months, String vertical, String project) {
        System.debug('--selected Project: ' + project);
        Map<String, Map<String, Decimal>> projectDataMap = new Map<String, Map<String, Decimal>>();
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        System.debug('vertical: ' + vertical);
        List<String> leadSources;
        if(vertical == 'Digital'){
            leadSources = new List<String>{'Digital','Facebook','Property Portals'};
        }else if(vertical == 'Direct'){
            leadSources = new List<String>{'Direct','Events','Exhibitions','Hoarding','Magazines','Newspapers','Paper Inserts','Radio','Surround Marketing','TV'};
        }else if(vertical == 'Presales/Direct'){
            leadSources = new List<String>{'Presales','Individual calling','Corporate' };
        }

        Decimal totalLeadTarget = 0, totalLeadAchieved = 0;
        Decimal totalWalkinTarget = 0, totalWalkinAchieved = 0;
        Decimal totalBookingUnitTarget = 0, totalBookingUnitAchieved = 0;
        Decimal totalBookingRevTarget = 0, totalBookingRevAchieved = 0;
    
        Integer year_Int = (year != '')? Integer.valueOf(year) : null;
        //Integer month_Int = String.isBlank(month) ? null : Integer.valueOf(month);
        List<Integer> months_Int = new List<Integer>();
        for(String mnth : months){
            months_Int.add(Integer.valueOf(mnth));
        }

        System.debug('year: ' + year);
        System.debug('months: ' + months);
        System.debug('vertical: ' + vertical);
        String targetQry = 'SELECT Id, Projects__r.Name, of_Leads__c, Walkins_Target__c, Booking_count_target__c, Target_in_Cr__c, Verticals__c FROM Company_Target__c';
        /*targetQry += ' WHERE Projects__c != null AND Projects__r.Name != \'Runwal Garden City\' AND Projects__r.RW_Status__c = \'Active\'';
        targetQry += ' AND (of_Leads__c != null OR Walkins_Target__c != null OR Booking_count_target__c != null)';
        if(vertical != null && vertical != ''){
            targetQry += ' AND Verticals__c =: vertical';
        }
        if(year != null){
            targetQry += ' AND Year__c =: year';
            if(months != null){
                targetQry += ' AND Month__c IN: months';
            }
        }
        if(project != 'All'){
            targetQry += ' AND Projects__r.Name =: project';
        }*/
        targetQry += queryFilterBuilder('table1', 'Company_Target__c', vertical, project, '', year, months);
        System.debug('targetQry: ' + targetQry);
        List<Company_Target__c> targets = Database.query(targetQry);
        
        for (Company_Target__c t : targets) {
            if (!projectDataMap.containsKey(t.Projects__r.Name)){
                projectDataMap.put(t.Projects__r.Name, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Map<String, Decimal> m = projectDataMap.get(t.Projects__r.Name);
            m.put(K_TARGET_LEADS, t.of_Leads__c);
            m.put(K_TARGET_WALKINS, t.Walkins_Target__c);
            m.put(K_TARGET_BKG_UNITS, t.Booking_count_target__c);
            m.put(K_TARGET_BKG_REV, t.Target_in_Cr__c);
        }

        /*String leadQry = 'SELECT RW_Project__r.Name proj, COUNT(Id) total FROM Lead';
        leadQry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(leadSources != null){
            leadQry += ' AND LeadSource IN: leadSources';
        }
        if(year != null){
            leadQry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            if(months != null){
                leadQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project';
        }
        leadQry += queryFilterBuilder('table1', 'Lead', vertical, project, '', year, months);
        //leadQry += ' GROUP BY RW_Project__r.Name';
        System.debug('leadQry: ' + leadQry);
        List<AggregateResult> leadAgg = Database.query(leadQry);

        
        
        for (AggregateResult ar : leadAgg) {
            String projName = (String)ar.get('proj');
            if (!projectDataMap.containsKey(projName)){
                projectDataMap.put(projName, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Long cnt = (Long)ar.get('total');
            projectDataMap.get(projName).put(K_ACTUAL_LEADS, (cnt == null ? 0 : Decimal.valueOf(cnt)));
        }

        String oppQry = 'SELECT RW_Project__r.Name proj, COUNT(Id) total FROM Opportunity';
        oppQry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(leadSources != null){
            oppQry += ' AND LeadSource IN: leadSources';
        }
        if(year != null){
            oppQry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            if(months != null){
                oppQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            oppQry += ' AND RW_Project__r.Name =: project';
        }
        oppQry += queryFilterBuilder('table1', 'Opportunity', vertical, project, '', year, months);
        //oppQry += ' GROUP BY RW_Project__r.Name';
        System.debug('oppQry: ' + oppQry);
        List<AggregateResult> oppAgg = Database.query(oppQry);
        
        for (AggregateResult ar : oppAgg) {
            String projName = (String)ar.get('proj');
            if (!projectDataMap.containsKey(projName)){
                projectDataMap.put(projName, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Long cnt = (Long)ar.get('total');
            projectDataMap.get(projName).put(K_ACTUAL_WALKINS, (cnt == null ? 0 : Decimal.valueOf(cnt)));
        }

        String bkgQry = 'SELECT Project__r.Name proj, COUNT(Id) units, SUM(Allotment_Premium__c) rev FROM Booking__c';
        bkgQry += ' WHERE Project__c != null AND Project__r.RW_Status__c = \'Active\' AND Project__r.Name != \'Runwal Garden City\'';
        if(leadSources != null){
            bkgQry += ' AND Opportunity__r.LeadSource IN: leadSources';
        }
        if(year != null){
            bkgQry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            if(months != null){
                bkgQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            bkgQry += ' AND Project__r.Name =: project';
        }
        bkgQry += queryFilterBuilder('table1', 'Booking__c', vertical, project, '', year, months);
        //bkgQry += ' GROUP BY Project__r.Name';
        System.debug('bkgQry: ' + bkgQry);
        List<AggregateResult> bkgAgg = Database.query(bkgQry);
        
        for (AggregateResult ar : bkgAgg) {
            String projName = (String)ar.get('proj');
            if (!projectDataMap.containsKey(projName)){
                projectDataMap.put(projName, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Long units = (Long)ar.get('units');
            Decimal rev = (Decimal)ar.get('rev');
            Map<String, Decimal> m = projectDataMap.get(projName);
            m.put(K_ACTUAL_BKG_UNITS, (units == null ? 0 : Decimal.valueOf(units)));
            m.put(K_ACTUAL_BKG_REV, toCrores(rev));
        }*/


        //////////////////////////////////////
        String leadQry1 = 'SELECT Id, CreatedDate, RW_Project__r.Name, LeadSource, IsConverted, ConvertedOpportunityId, ConvertedDate FROM Lead';
        leadQry1 += queryFilterBuilder('table1', 'Lead', vertical, project, '', year, months);
        System.debug('leadQry1: ' + leadQry1);
        List<Lead> leadList =  Database.query(leadQry1);
        System.debug('leadList: ' + leadList.size());
        Map<String, Decimal> leadMap = new Map<String, Decimal>();
        Map<String, Decimal> oppMap = new Map<String, Decimal>();
        Map<String, Decimal> bkgMap = new Map<String, Decimal>();
        Map<String, Decimal> revenueMap = new Map<String, Decimal>();
        for(Lead ld : leadList){
            System.debug('leadId: ' + ld.Id);
            if(!leadMap.containsKey(ld.RW_Project__r.Name)){
                leadMap.put(ld.RW_Project__r.Name, 1);
            }else{
                leadMap.put(ld.RW_Project__r.Name, leadMap.get(ld.RW_Project__r.Name) + 1);
            }
        }
        System.debug('leadMap: ' + leadMap);

        for(String proj : leadMap.keySet()){
            if (!projectDataMap.containsKey(proj)){
                projectDataMap.put(proj, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            projectDataMap.get(proj).put(K_ACTUAL_LEADS, (leadMap.get(proj) == null ? 0 : leadMap.get(proj)));
        }
        
        List<String> oppIds = new List<String>();
        System.debug('months: ' + months);
        for(Lead ld : leadList){
            System.debug('ConvertedDate: ' + ld.ConvertedDate);
            if(ld.ConvertedDate != null){
                Integer leadMonth = ld.CreatedDate.month();
                Integer leadYear  = ld.CreatedDate.year();
                Integer convertedMonth = ld.ConvertedDate.month();
                Integer convertedYear  = ld.ConvertedDate.year();
                System.debug('convertedMonth: ' + convertedMonth);
                if(months != null && months.size() > 0){
                    if(leadYear == convertedYear && months.contains(String.valueOf(convertedMonth))){
                        oppIds.add(ld.ConvertedOpportunityId);
                    }
                }else{
                    if(leadYear == convertedYear){
                        oppIds.add(ld.ConvertedOpportunityId);
                    }
                }
                
            }
        }
        System.debug('oppIds: ' + oppIds);
        if(oppIds.size() > 0){
            List<Opportunity> filteredOppList = [SELECT Id, LeadSource, RW_Project__r.Name, CreatedDate, Booking__c, Booking__r.RW_Booking_Confirmed_Date__c, Booking__r.Allotment_Premium__c, Booking__r.Status__c FROM Opportunity WHERE Id =: oppIds];
            List<String> bkgIds = new List<String>();
            for(Opportunity opp : filteredOppList){
                if(opp.Booking__c != null && opp.Booking__r.Status__c == 'Booking Confirmed' && opp.Booking__r.RW_Booking_Confirmed_Date__c != null){
                    Integer oppMonth = opp.CreatedDate.month();
                    Integer oppYear  = opp.CreatedDate.year();
                    Integer bkgMonth = opp.Booking__r.RW_Booking_Confirmed_Date__c.month();
                    Integer bkgYear  = opp.Booking__r.RW_Booking_Confirmed_Date__c.year();
                    if(months != null && months.size() > 0){
                        if(oppYear == bkgYear && months.contains(String.valueOf(bkgMonth))){
                            bkgIds.add(opp.Booking__c);
                            if(!bkgMap.containsKey(opp.RW_Project__r.Name)){
                                bkgMap.put(opp.RW_Project__r.Name, 1);
                            }else{
                                bkgMap.put(opp.RW_Project__r.Name, bkgMap.get(opp.RW_Project__r.Name) + 1);
                            }
                            if(!revenueMap.containsKey(opp.RW_Project__r.Name)){
                                revenueMap.put(opp.RW_Project__r.Name, opp.Booking__r.Allotment_Premium__c);
                            }else{
                                revenueMap.put(opp.RW_Project__r.Name, revenueMap.get(opp.RW_Project__r.Name) + opp.Booking__r.Allotment_Premium__c);
                            }
                        }
                    }else{
                        if(oppYear == bkgYear){
                            bkgIds.add(opp.Booking__c);
                            if(!bkgMap.containsKey(opp.RW_Project__r.Name)){
                                bkgMap.put(opp.RW_Project__r.Name, 1);
                            }else{
                                bkgMap.put(opp.RW_Project__r.Name, bkgMap.get(opp.RW_Project__r.Name) + 1);
                            }
                            if(!revenueMap.containsKey(opp.RW_Project__r.Name)){
                                revenueMap.put(opp.RW_Project__r.Name, opp.Booking__r.Allotment_Premium__c);
                            }else{
                                revenueMap.put(opp.RW_Project__r.Name, revenueMap.get(opp.RW_Project__r.Name) + opp.Booking__r.Allotment_Premium__c);
                            }
                        }
                    }
                }
                if(!oppMap.containsKey(opp.RW_Project__r.Name)){
                    oppMap.put(opp.RW_Project__r.Name, 1);
                }else{
                    oppMap.put(opp.RW_Project__r.Name, oppMap.get(opp.RW_Project__r.Name) + 1);
                }
            }
        }

        for(String proj : oppMap.keySet()){
            if (!projectDataMap.containsKey(proj)){
                projectDataMap.put(proj, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Long cnt = (Long)oppMap.get(proj);
            projectDataMap.get(proj).put(K_ACTUAL_WALKINS, (cnt == null ? 0 : Decimal.valueOf(cnt)));
        }
        for(String proj : bkgMap.keySet()){
            if (!projectDataMap.containsKey(proj)){
                projectDataMap.put(proj, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Long units = (Long)bkgMap.get(proj);
            Map<String, Decimal> m = projectDataMap.get(proj);
            m.put(K_ACTUAL_BKG_UNITS, (units == null ? 0 : Decimal.valueOf(units)));
        }
        for(String proj : revenueMap.keySet()){
            if (!projectDataMap.containsKey(proj)){
                projectDataMap.put(proj, new Map<String, Decimal>{
                    K_TARGET_LEADS => 0, K_ACTUAL_LEADS => 0,
                    K_TARGET_WALKINS => 0, K_ACTUAL_WALKINS => 0,
                    K_TARGET_BKG_UNITS => 0, K_ACTUAL_BKG_UNITS => 0,
                    K_TARGET_BKG_REV => 0, K_ACTUAL_BKG_REV => 0
                });
            }
            Decimal rev = (Decimal)revenueMap.get(proj);
            Map<String, Decimal> m = projectDataMap.get(proj);
            m.put(K_ACTUAL_BKG_REV, toCrores(rev));
        }

        /////////////////////////////////////

        for (String projName : projectDataMap.keySet()) {
            Map<String, Decimal> metrics = projectDataMap.get(projName);
            Map<String, Object> row = new Map<String, Object>();
            //if(metrics.get(K_TARGET_LEADS) == 0 && metrics.get(K_TARGET_WALKINS) == 0 && metrics.get(K_TARGET_BKG_UNITS) == 0){
            //    continue;
            //}
            row.put('project', projName);
            row.put('leadTarget', metrics.get(K_TARGET_LEADS));
            row.put('leadAchieved', metrics.get(K_ACTUAL_LEADS));
            row.put('leadPercentage', calculatePercent(metrics.get(K_ACTUAL_LEADS), metrics.get(K_TARGET_LEADS)));
            
            row.put('walkinTarget', metrics.get(K_TARGET_WALKINS));
            row.put('walkinAchieved', metrics.get(K_ACTUAL_WALKINS));
            row.put('walkinPercentage', calculatePercent(metrics.get(K_ACTUAL_WALKINS), metrics.get(K_TARGET_WALKINS)));
            
            row.put('bookingUnitTarget', metrics.get(K_TARGET_BKG_UNITS));
            row.put('bookingUnitAchieved', metrics.get(K_ACTUAL_BKG_UNITS));
            row.put('bookingUnitPercentage', calculatePercent(metrics.get(K_ACTUAL_BKG_UNITS), metrics.get(K_TARGET_BKG_UNITS)));
    
            row.put('bookingRevTarget', metrics.get(K_TARGET_BKG_REV));
            row.put('bookingRevAchieved', metrics.get(K_ACTUAL_BKG_REV));
            row.put('bookingRevPercentage', calculatePercent(metrics.get(K_ACTUAL_BKG_REV), metrics.get(K_TARGET_BKG_REV)));
            
            row.put('conversion', calculatePercent(metrics.get(K_ACTUAL_BKG_UNITS), metrics.get(K_ACTUAL_WALKINS)));

            totalLeadTarget += (metrics.get(K_TARGET_LEADS) != null ? metrics.get(K_TARGET_LEADS) : 0);
            totalLeadAchieved += (metrics.get(K_ACTUAL_LEADS) != null ? metrics.get(K_ACTUAL_LEADS) : 0);
            totalWalkinTarget += (metrics.get(K_TARGET_WALKINS) != null ? metrics.get(K_TARGET_WALKINS) : 0);
            totalWalkinAchieved += (metrics.get(K_ACTUAL_WALKINS) != null ? metrics.get(K_ACTUAL_WALKINS) : 0);
            totalBookingUnitTarget += (metrics.get(K_TARGET_BKG_UNITS) != null ? metrics.get(K_TARGET_BKG_UNITS) : 0);
            totalBookingUnitAchieved += (metrics.get(K_ACTUAL_BKG_UNITS) != null ? metrics.get(K_ACTUAL_BKG_UNITS) : 0);
            totalBookingRevTarget += (metrics.get(K_TARGET_BKG_REV) != null ? metrics.get(K_TARGET_BKG_REV) : 0);
            totalBookingRevAchieved += (metrics.get(K_ACTUAL_BKG_REV) != null ? metrics.get(K_ACTUAL_BKG_REV) : 0);
    
            finalResult.add(row);
        }

        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotal', true);
        
        totalRow.put('leadTarget', totalLeadTarget);
        totalRow.put('leadAchieved', totalLeadAchieved);
        totalRow.put('leadPercentage', calculatePercent(totalLeadAchieved, totalLeadTarget));
        totalRow.put('walkinTarget', totalWalkinTarget);
        totalRow.put('walkinAchieved', totalWalkinAchieved);
        totalRow.put('walkinPercentage', calculatePercent(totalWalkinAchieved, totalWalkinTarget));
        totalRow.put('bookingUnitTarget', totalBookingUnitTarget);
        totalRow.put('bookingUnitAchieved', totalBookingUnitAchieved);
        totalRow.put('bookingUnitPercentage', calculatePercent(totalBookingUnitAchieved, totalBookingUnitTarget));
        totalRow.put('bookingRevTarget', totalBookingRevTarget);
        totalRow.put('bookingRevAchieved', totalBookingRevAchieved);
        totalRow.put('bookingRevPercentage', calculatePercent(totalBookingRevAchieved, totalBookingRevTarget));
        
        finalResult.add(totalRow);

        return finalResult;
    }   
    
    private static List<Map<String, Object>> getLeadStatusLogic(String year, List<String> months, List<String> sources, String dateRange, String project) {

        System.debug('sources:  ' + sources);
        System.debug('months:  ' + months);
        Integer year_Int = (year != '')? Integer.valueOf(year) : null; 
        /*Integer month_Int;
        if(month != null && month != ''){
            month_Int = Integer.valueOf(month);
        }*/
        List<Integer> months_Int = new List<Integer>();
        for(String mnth : months){
            months_Int.add(Integer.valueOf(mnth));
        }
        List<String> allStatuses = new List<String>();
        Schema.DescribeFieldResult fieldResult = Lead.Status.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            allStatuses.add(entry.getLabel());
        }

      
        String qry = 'SELECT RW_Project__r.Name proj, Status st, COUNT(Id) total FROM Lead WHERE RW_Project__c != null AND RW_Project__r.Name != \'Runwal Garden City\'';
        //qry += ' AND LeadSource =: source';
        qry += ' AND Status =: allStatuses';
        if(sources != null && sources.size() > 0){
            qry += ' AND LeadSource IN: sources';
        }
        if(dateRange != 'Custom'){
            qry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            qry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            if(months != null && months.size() > 0){
                qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        qry += ' GROUP BY RW_Project__r.Name, Status';
        List<AggregateResult> groupedResults = Database.query(qry);
        

        // 3. Map to hold Project Rows: Key = Project Name, Value = Map of Status counts
        Map<String, Map<String, Integer>> projectStatusMap = new Map<String, Map<String, Integer>>();
        Map<String, Integer> grandTotals = new Map<String, Integer>();
        for(String s : allStatuses) grandTotals.put(s, 0);
        grandTotals.put('Total', 0);

        for (AggregateResult ar : groupedResults) {
            String projectName = (String)ar.get('proj');
            String status = (String)ar.get('st');
            Long totalL = (Long)ar.get('total');
            Integer count = (totalL == null ? 0 : Integer.valueOf(String.valueOf(totalL)));

            if (!projectStatusMap.containsKey(projectName)) { 
                Map<String, Integer> statusCounts = new Map<String, Integer>();
                for (String s : allStatuses) {
                    statusCounts.put(s, 0);
                }
                statusCounts.put('Total', 0); 
                projectStatusMap.put(projectName, statusCounts);
            }

            
            projectStatusMap.get(projectName).put(status, count);
            Integer currentTotal = projectStatusMap.get(projectName).get('Total');
            projectStatusMap.get(projectName).put('Total', currentTotal + count);
            System.debug('status: ' + status);
            System.debug('grandTotals: ' + grandTotals);
            System.debug('grandTotals.get(status): ' + grandTotals.get(status));
            grandTotals.put(status, grandTotals.get(status) + count);
            grandTotals.put('Total', grandTotals.get('Total') + count);
        }

       
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        for (String proj : projectStatusMap.keySet()) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('project', proj);
            
            Map<String, Integer> counts = projectStatusMap.get(proj);
            for (String s : counts.keySet()) {
                
                String fieldKey = s.replaceAll('[^a-zA-Z0-9]', '');
                row.put(fieldKey, counts.get(s));
            }
            finalResult.add(row);
        }
        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotalRow', true); 
        for (String s : grandTotals.keySet()) {
            totalRow.put(s.replaceAll('[^a-zA-Z0-9]', ''), grandTotals.get(s));
        }
        finalResult.add(totalRow);

        return finalResult;
    }


    private static List<Map<String, Object>> getJunkPercentageLogic(List<String> sources, String dateRange, String project, String year, List<String> months){
        if(year == ''){
            return getJunkPercentageLast12Months(sources, dateRange, project, year, months);
        }else{
            return getJunkPercentageForDateRange(sources, dateRange, project, year, months);
        }
    }
    private static List<Map<String, Object>> getJunkPercentageLast12Months(List<String> sources, String dateRange, String project, String year, List<String> months) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<String, Map<String, Decimal>> projectMonthlyData = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> grandTotalJunk = new Map<String, Decimal>();
        Map<String, Decimal> grandTotalLeads = new Map<String, Decimal>();
        
       
        List<String> monthKeys = new List<String>();
        Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        
       
        String leadQry = 'SELECT Id,CreatedDate,RW_Project__r.Name,Status FROM Lead';
        leadQry += ' WHERE CreatedDate >= :startDate AND RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        String leadHistoryQry = 'SELECT LeadId, Field, OldValue, NewValue, CreatedDate FROM LeadHistory';
        leadHistoryQry += '  WHERE Field = \'Status\' AND CreatedDate >: startDate';
        if(sources !=  null && sources.size() > 0){
            leadQry += ' AND LeadSource IN: sources';
            leadHistoryQry += ' AND Lead.LeadSource IN: sources';
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project'; 
            leadHistoryQry += ' AND Lead.RW_Project__r.Name =: project'; 
        }
        List<Lead> leads = Database.query(leadQry);
        List<Id> leadIds = new List<Id>();
        for(Lead ld : leads){
            leadIds.add(ld.Id);
        }
        leadHistoryQry += ' AND Lead.Id =: leadIds';
        List<LeadHistory> historyList = Database.query(leadHistoryQry);
        
        List<LeadHistory> junkStatusHistory = new List<LeadHistory>();
        for (LeadHistory lh : historyList) {
            if (lh.NewValue != null && String.valueOf(lh.NewValue) == 'Junk') {
                junkStatusHistory.add(lh);
            }
        }
        Map<Id,Date> junkDateMap = new Map<Id,Date>();
        for(LeadHistory leadHist : junkStatusHistory){
            junkDateMap.put(leadHist.LeadId, Date.valueOf(leadHist.CreatedDate));
        }
        System.debug('junkDateMap: ' + junkDateMap);
        List<Id> filteredLeadIds = new List<Id>();
        Map<String,List<Lead>> projVsLeadsMap = new Map<String, List<Lead>>();
        Map<String, Map<String,Decimal>> projMonthlyMap = new Map<String, Map<String,Decimal>>();
        Map<String, Decimal> monthlyTotalMap = new Map<String, Decimal>();
        Map<String, Decimal> monthlyJunkMap = new Map<String, Decimal>();
        for(Lead ld : leads){
            if(!projVsLeadsMap.containsKey(ld.RW_Project__r.Name)){
                projVsLeadsMap.put(ld.RW_Project__r.Name, new List<Lead>{ld});
            }else{
                projVsLeadsMap.get(ld.RW_Project__r.Name).add(ld);
            }
            
        }
        for(String proj : projVsLeadsMap.keySet()){
            Map<String,Decimal> monthlyMap = new Map<String, Decimal>();
            for(Lead ld : projVsLeadsMap.get(proj)){
                if(monthlyTotalMap.containsKey(ld.CreatedDate.month() + '-' + ld.CreatedDate.year())){
                    monthlyTotalMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year(), monthlyTotalMap.get(ld.CreatedDate.month() + '-' + ld.CreatedDate.year()) + 1);
                }else{
                    monthlyTotalMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year(), 1);
                }

                if(!monthlyMap.containsKey(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total')){
                    monthlyMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total', 1);
                    System.debug('--if monthlyMap: ' + monthlyMap);
                }else{
                    monthlyMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total', monthlyMap.get((ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total')) + 1);
                    System.debug('--els monthlyMap: ' + monthlyMap);
                }
                System.debug('project: ' + proj);
                System.debug('Month val_total: ' +  ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total');
                System.debug('count _total: ' + monthlyMap.get((ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_total')));
                System.debug('monthlyMap: ' + monthlyMap);
                if(junkDateMap.containsKey(ld.Id)){
                    Integer leadMonth = ld.CreatedDate.month();
                    Integer leadYear  = ld.CreatedDate.year();
                    Integer junkMonth = junkDateMap.get(ld.Id).month();
                    Integer junkYear  = junkDateMap.get(ld.Id).year();
                    if(leadYear == junkYear && leadMonth == junkMonth){
                        System.debug('--junk Lead--');
                        filteredLeadIds.add(ld.Id);
                        if(!monthlyMap.containsKey(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk')){
                            monthlyMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk', 1);
                            System.debug('Month val: ' +  ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk');
                        }else{
                            monthlyMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk', monthlyMap.get((ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk')) + 1);
                        }
                        System.debug('count : ' + monthlyMap.get((ld.CreatedDate.month() + '-' + ld.CreatedDate.year() + '_junk')));
                        
                        System.debug('monthlyMap1: ' + monthlyMap);
                        if(monthlyJunkMap.containsKey(ld.CreatedDate.month() + '-' + ld.CreatedDate.year())){
                            monthlyJunkMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year(), monthlyJunkMap.get(ld.CreatedDate.month() + '-' + ld.CreatedDate.year()) + 1);
                        }else{
                            monthlyJunkMap.put(ld.CreatedDate.month() + '-' + ld.CreatedDate.year(), 1);
                        }
                    }
                    System.debug('monthlyMap2: ' + monthlyMap);
                }
                System.debug('monthlyMap3: ' + monthlyMap);
            }
            projMonthlyMap.put(proj, monthlyMap);
        }
        System.debug('projMonthlyMap: ' + projMonthlyMap);
        projectMonthlyData = projMonthlyMap;
        
        System.debug('filteredLeadIds: ' + filteredLeadIds);
        
        for (String proj : projectMonthlyData.keySet()) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('project', proj);
            
            
            for (Integer i = 0; i < 12; i++) {
                Date d = startDate.addMonths(i);
                String mKey = d.month() + '-' + d.year();
                Decimal junk = projectMonthlyData.get(proj).get(mKey + '_junk');
                System.debug('--junk: ' + junk);
                Decimal total = projectMonthlyData.get(proj).get(mKey + '_total');
                System.debug('--total: ' + total);
                Decimal percentage = (total != null && total > 0) ? 
                                    (junk != null ? (junk / total * 100).setScale(2) : 0) : 0;
                
                row.put('month' + i, percentage);
            }
            System.debug('row: ' + row);
            finalResult.add(row);
        }
        System.debug('finalResult: ' + finalResult);
        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotalRow', true);
        for (Integer i = 0; i < 12; i++) {
            Date d = startDate.addMonths(i);
            String mKey = d.month() + '-' + d.year();
            //totalRow.put('month' + i, calculatePercent(grandTotalJunk.get(mKey), grandTotalLeads.get(mKey)));
            totalRow.put('month' + i, calculatePercent(monthlyJunkMap.get(mKey), monthlyTotalMap.get(mKey)));
        }
        finalResult.add(totalRow);
        return finalResult;
    }

    private static List<Map<String, Object>> getJunkPercentageForDateRange(List<String> sources, String dateRange, String project, String year, List<String> months) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<String, Map<String, Decimal>> projectMonthlyData = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> grandTotalJunk = new Map<String, Decimal>();
        Map<String, Decimal> grandTotalLeads = new Map<String, Decimal>();
        
        Integer year_Int = (year != '')? Integer.valueOf(year) : null;
        List<Integer> months_Int = new List<Integer>();
        for(String mnth : months){
            months_Int.add(Integer.valueOf(mnth));
        }

        
        //List<String> monthKeys = new List<String>();
        //Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        
       
        String leadQry = 'SELECT Id,CreatedDate,RW_Project__r.Name,Status FROM Lead';
        leadQry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        String leadHistoryQry = 'SELECT LeadId, Field, OldValue, NewValue, CreatedDate FROM LeadHistory';
        leadHistoryQry += '  WHERE Field = \'Status\'';
        if(sources != null && sources.size() > 0){
            leadQry += ' AND LeadSource IN: sources';
            leadHistoryQry += ' AND Lead.LeadSource IN: sources';
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project'; 
            leadHistoryQry += ' AND Lead.RW_Project__r.Name =: project'; 
        }
        if(year != null && year != ''){
            leadQry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            leadHistoryQry += ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            if(months != null && months.size() > 0){
                leadQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
                leadHistoryQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        List<Lead> leads = Database.query(leadQry);
        List<LeadHistory> historyList = Database.query(leadHistoryQry);
        List<LeadHistory> junkStatusHistory = new List<LeadHistory>();
        for (LeadHistory lh : historyList) {
            if (lh.NewValue != null && String.valueOf(lh.NewValue) == 'Junk') {
                junkStatusHistory.add(lh);
            }
        }
        Map<Id,Date> junkDateMap = new Map<Id,Date>();
        for(LeadHistory leadHist : junkStatusHistory){
            junkDateMap.put(leadHist.LeadId, Date.valueOf(leadHist.CreatedDate));
        }
        System.debug('junkDateMap: ' + junkDateMap);
        List<Id> filteredLeadIds = new List<Id>();
        Map<String,List<Lead>> projVsLeadsMap = new Map<String, List<Lead>>();
        Map<String, Map<String,Decimal>> projMonthlyMap = new Map<String, Map<String,Decimal>>();
        Map<String, Decimal> monthlyTotalMap = new Map<String, Decimal>();
        Map<String, Decimal> monthlyJunkMap = new Map<String, Decimal>();
        for(Lead ld : leads){
            if(!projVsLeadsMap.containsKey(ld.RW_Project__r.Name)){
                projVsLeadsMap.put(ld.RW_Project__r.Name, new List<Lead>{ld});
            }else{
                projVsLeadsMap.get(ld.RW_Project__r.Name).add(ld);
            }
            
        }
        Decimal totalLeads = 0;
        Decimal totalJunkLeads = 0;
        for(String proj : projVsLeadsMap.keySet()){
            Decimal junkCount = 0;
            Map<String,Decimal> projLeadMap = new Map<String, Decimal>();
            for(Lead ld : projVsLeadsMap.get(proj)){
                totalLeads += 1;
                if(junkDateMap.containsKey(ld.Id)){
                    Integer leadMonth = ld.CreatedDate.month();
                    Integer leadYear  = ld.CreatedDate.year();
                    Integer junkMonth = junkDateMap.get(ld.Id).month();
                    Integer junkYear  = junkDateMap.get(ld.Id).year();
                    /*if(leadYear == junkYear && leadMonth == junkMonth){
                        junkCount += 1;
                        totalJunkLeads += 1;
                    }*/
                    if(months != null && months.size() > 0){
                        if(leadYear == junkYear && months.contains(String.valueOf(junkMonth))){
                            junkCount += 1;
                            totalJunkLeads += 1;
                        }
                    }else if(leadYear == junkYear){
                        junkCount += 1;
                        totalJunkLeads += 1;
                    }
                }
            }
            projLeadMap.put('total', projVsLeadsMap.get(proj).size());
            projLeadMap.put('junk', junkCount);
            projectMonthlyData.put(proj, projLeadMap);
        }
        
        system.debug('projectMonthlyData: ' + projectMonthlyData);

        
        for (String proj : projectMonthlyData.keySet()) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('project', proj);
            Decimal junk = projectMonthlyData.get(proj).get('junk');
            System.debug('--junk: ' + junk);
            Decimal total = projectMonthlyData.get(proj).get('total');
            System.debug('--total: ' + total);
            Decimal percentage = (total != null && total > 0) ? (junk != null ? (junk / total * 100).setScale(2) : 0) : 0;
            System.debug('--percentage: ' + percentage);
            row.put('month', percentage);
            System.debug('row: ' + row);
            finalResult.add(row);
        }
        System.debug('finalResult: ' + finalResult);
        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotalRow', true);
        totalRow.put('month', calculatePercent(totalJunkLeads, totalLeads));
        finalResult.add(totalRow);
        System.debug('finalResult: ' + finalResult);
        return finalResult;
    }
    
    private static List<Map<String, Object>> getDigitalBudgetLogic(String year, List<String> months, String project) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<String,String> monthMap = new Map<String, String>{'1' => 'January', '2' => 'February', '3' => 'March', '4' => 'April', '5' => 'May', '6' => 'June', '7' => 'July', '8' => 'August', '9' => 'September', '10' => 'October', '11' => 'November', '12' => 'December'};
    
        
        String budgetQuery = 'SELECT Spends_Planned__c, Budget_in_Cr__c, Balance_Amount__c, Balance_Days__c, Project__r.Name, Month__c, Year__c,Actual_Expenses_EIPL__c,Actual_Expenses_EREPL__c,Actual_Expenses_HHPL__c,Actual_Expenses_HHPL_2__c,Actual_Expenses_Horizon__c,Actual_Expenses_REPL__c,Actual_Expenses_RREPL__c,Actual_Expenses_RRPL__c,Actual_Expenses_SIPL__c,Actual_Expenses_WACL__c,Actual_Expenses_WRPL__c ' +
                         'FROM Budget_vs_Expenses__c WHERE WBS_name_as_per_SAP__c = \'Digital advertising\' AND Project__c != null AND Project__r.RW_Status__c = \'Active\' AND Year__c =: year';
        
        if (months != null && months.size() > 0){ 
            List<String> mnths = new List<String>();
            for(String m : months){
                mnths.add(monthMap.get(m));
            }
            budgetQuery += ' AND Month__c IN: mnths'; 
        }
        if(project != 'All'){
            budgetQuery += ' AND Project__r.Name =: project';
        }

        Map<String, Object> totalrow = new Map<String, Object>();
        totalrow.put('project', 'Total');
        Decimal totalPlanned = 0;
        Decimal totalApproved = 0;
        Decimal totalActual = 0;
        Decimal totalBalanceAmount = 0;
        Integer totalBalanceDays = 0;

        Map<String, List<Budget_vs_Expenses__c>> projVsBudgetMap = new Map<String, List<Budget_vs_Expenses__c>>();
        for(Budget_vs_Expenses__c b : Database.query(budgetQuery)){
            if(!projVsBudgetMap.containsKey(b.Project__r.Name)){
                projVsBudgetMap.put(b.Project__r.Name, new List<Budget_vs_Expenses__c>{b});
            }
            projVsBudgetMap.get(b.Project__r.Name).add(b);
        }
        for(String proj : projVsBudgetMap.keySet()){
            Map<String, Object> row = new Map<String, Object>();
            Decimal planned = 0;
            Decimal approved = 0;
            Decimal actual = 0;
            Decimal balance = 0;
            Integer days = 0;
            for(Budget_vs_Expenses__c b : projVsBudgetMap.get(proj)){
                Decimal actualSpends = (b.Actual_Expenses_EIPL__c != null)? b.Actual_Expenses_EIPL__c : 0;
                actualSpends += (b.Actual_Expenses_EREPL__c != null)? b.Actual_Expenses_EREPL__c : 0;
                actualSpends += (b.Actual_Expenses_HHPL__c != null)? b.Actual_Expenses_HHPL__c : 0;
                actualSpends += (b.Actual_Expenses_HHPL_2__c != null)? b.Actual_Expenses_HHPL_2__c : 0;
                actualSpends += (b.Actual_Expenses_Horizon__c != null)? b.Actual_Expenses_Horizon__c : 0;
                actualSpends += (b.Actual_Expenses_REPL__c != null)? b.Actual_Expenses_REPL__c : 0;
                actualSpends += (b.Actual_Expenses_RREPL__c != null)? b.Actual_Expenses_RREPL__c : 0;
                actualSpends += (b.Actual_Expenses_RRPL__c != null)? b.Actual_Expenses_RRPL__c : 0;
                actualSpends += (b.Actual_Expenses_SIPL__c != null)? b.Actual_Expenses_SIPL__c : 0;
                actualSpends += (b.Actual_Expenses_WACL__c != null)? b.Actual_Expenses_WACL__c : 0;
                actualSpends += (b.Actual_Expenses_WRPL__c != null)? b.Actual_Expenses_WRPL__c : 0;

                Decimal balanceAmount = (b.Budget_in_Cr__c != null ? b.Budget_in_Cr__c : 0) - actualSpends;

                planned += (b.Spends_Planned__c != null)? b.Spends_Planned__c : 0;
                approved += (b.Budget_in_Cr__c != null)? b.Budget_in_Cr__c : 0;
                actual += actualSpends;
                balance += balanceAmount;
                days += (b.Balance_Days__c != null)? Integer.valueOf(b.Balance_Days__c) : 0;
            }
            row.put('project', proj); 
            row.put('planned', planned);
            row.put('approved', approved);
            row.put('actual', actual);
            row.put('balanceAmount', balance);
            row.put('balanceDays', days);

            totalPlanned += planned;
            totalApproved += approved;
            totalActual += actual;
            totalBalanceAmount += balance;
            totalBalanceDays += days;

            finalResult.add(row);
        }
        
        totalrow.put('project', 'Total'); 
        totalrow.put('planned', totalPlanned);
        totalrow.put('approved', totalApproved);
        totalrow.put('actual', totalActual);
        totalrow.put('balanceAmount', totalBalanceAmount);
        totalrow.put('balanceDays', totalBalanceDays);
        finalResult.add(totalrow);
        return finalResult;
    }
    

    private static List<Map<String, Object>> getMediaSummaryLogic(String year, List<String> months, List<String> sources, String dateRange, String project) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
    
        Integer selYear = (year != '')? Integer.valueOf(year) : null;
        List<Integer> selMonths = new List<Integer>();
        if(months != null && months.size() > 0){
            for(String month : months){
                selMonths.add(Integer.valueOf(month));
            }
        }


        List<String> mediaCategories;
        if(sources != null && sources.size() > 0){
            mediaCategories = sources;
        }else{
            mediaCategories = new List<String>{
                'Hoarding', 'Newspapers', 'Digital', 'Presales', 'Channel Partner', 'Referral', 'Loyalty', 'Employee / Managemen'
            };
        }
        System.debug('sources: ' + sources);
        System.debug('mediaCategories: ' + mediaCategories);
        
        Map<String, Map<String, Decimal>> mediaMap = new Map<String, Map<String, Decimal>>();
        for(String m : mediaCategories) {
            mediaMap.put(m, new Map<String, Decimal>{
                'leads'=>0, 'walkins'=>0, 'bookings'=>0
            });
        }

        
        String leadQry = 'SELECT LeadSource src, COUNT(Id) total FROM Lead WHERE IsConverted = false AND LeadSource != null AND CALENDAR_YEAR(CreatedDate) = :selYear';
        leadQry += ' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources.size() > 0){
            leadQry += ' AND LeadSource IN: sources';
        }else{
            leadQry += ' AND LeadSource IN: mediaCategories';
        }
        if(dateRange != 'Custom'){
            leadQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            leadQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                leadQry += ' AND CALENDAR_MONTH(CreatedDate) IN: selMonths';
            }
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project';
        }
        leadQry += ' GROUP BY LeadSource';
        List<AggregateResult> leadMediaAgg = Database.query(leadQry);
       
        for(AggregateResult ar : leadMediaAgg) {
            String src = (String)ar.get('src');
            if(mediaMap.containsKey(src)) {
                mediaMap.get(src).put('leads', (Decimal)ar.get('total'));
            }
        }

       
        String oppQry = 'SELECT LeadSource src, COUNT(Id) total FROM Opportunity WHERE LeadSource != null AND CALENDAR_YEAR(CreatedDate) = :selYear';
        oppQry += ' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources.size() > 0){
            oppQry += ' AND LeadSource IN: sources';
        }else{
            oppQry += ' AND LeadSource IN: mediaCategories';
        }
        if(dateRange != 'Custom'){
            oppQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            oppQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                oppQry += ' AND CALENDAR_MONTH(CreatedDate) IN: selMonths';
            }
        }
        if(project != 'All'){
            oppQry += ' AND RW_Project__r.Name =: project';
        }
        oppQry += ' GROUP BY LeadSource';
        List<AggregateResult> oppMediaAgg = Database.query(oppQry);
       
        for(AggregateResult ar : oppMediaAgg) {
            String src = (String)ar.get('src');
            if(mediaMap.containsKey(src)) {
                mediaMap.get(src).put('walkins', (Decimal)ar.get('total'));
            }
        }

        
        String bkgQry = 'SELECT Opportunity__r.LeadSource src, COUNT(Id) total, SUM(Allotment_Premium__c) rev FROM Booking__c WHERE Opportunity__r.LeadSource != null';
        bkgQry += ' AND Project__r.Name != \'Runwal Garden City\'';
        if(sources.size() > 0){
            bkgQry += ' AND Opportunity__r.LeadSource IN: sources';
        }else{
            bkgQry += ' AND Opportunity__r.LeadSource IN: mediaCategories';
        }
        if(dateRange != 'Custom'){
            bkgQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            bkgQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                bkgQry += ' AND CALENDAR_MONTH(CreatedDate) IN: selMonths';
            }
        }
        if(project != 'All'){
            bkgQry += ' AND Project__r.Name =: project';
        }
        bkgQry += ' GROUP BY Opportunity__r.LeadSource';
        System.debug('bkgQry: ' + bkgQry);
        List<AggregateResult> bkgMediaAgg = Database.query(bkgQry);
        

        Decimal grandTotalRev = 0;

        for(AggregateResult ar : bkgMediaAgg) {
            String src = (String)ar.get('src');
            if(mediaMap.containsKey(src)) {
                mediaMap.get(src).put('bookings', (Decimal)ar.get('total'));
                grandTotalRev += (ar.get('rev') != null)? (Decimal)ar.get('rev') / 10000000 : 0; 
            }
        }

        
        
        Decimal totalSpends = Decimal.valueOf(calculateSpends(project, dateRange, year, months, 'table6')); 
        
        
        
        Decimal spendPct = grandTotalRev > 0 ? (totalSpends / grandTotalRev * 100).setScale(2) : 0;
        
        
        for (String m : mediaCategories) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('media', m);
            row.put('leads', mediaMap.get(m).get('leads'));
            row.put('walkins', mediaMap.get(m).get('walkins'));
            row.put('bookings', mediaMap.get(m).get('bookings'));
            row.put('globalRev', grandTotalRev.setScale(2));
            row.put('globalSpnd', totalSpends.setScale(4));
            row.put('spndPct', spendPct);
            finalResult.add(row);
        }
        return finalResult;
    }

    public static String calculateSpends(String project, String dateRange, String year, List<String> months, String table){
        Map<Integer,String> monthMap = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
        Map<Integer, Integer> monthDaysMap = new Map<Integer, Integer>{1 => 31, 2 => 28, 3 => 31, 4 => 30, 5 => 31, 6 => 30, 7 => 31, 8 => 31, 9 => 30, 10 => 31, 11 => 30, 12 => 31};
        Map<String, Integer> monthStrDaysMap = new Map<String, Integer>{'January' => 31, 'February' => 28, 'March' => 31, 'April' => 30, 'May' => 31, 'June' => 30, 'July' => 31, 'August' => 31, 'September' => 30, 'October' => 31, 'November' => 30, 'December' => 31};
        String qry = 'SELECT Id, Spends_Planned__c, Year__c, Month__c, Project__r.Name FROM Budget_vs_Expenses__c';
        qry += ' WHERE Spends_Planned__c != null AND Project__c != null AND Project__r.Name != \'Runwal Garden City\'';

        List<String> yearList = new List<String>();
        List<String> monthList = new List<String>();
        Map<String, Integer> multiplierMap = new Map<String, Integer>(); 
        if(dateRange != 'Custom'){
            Integer yearVal;
            Integer monthVal;
            Integer dayVal;
            Decimal multiplier = 0;
            
            
            yearVal = Date.today().year();
            monthVal = Date.today().month();
            dayVal = Date.today().day();
            if(dateRange == 'LAST_N_DAYS:7'){
                if(dayVal - 7 >= 0){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), 7);
                    
                }else{
                    if(monthVal != 1){
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 7 - dayVal);
                    }else{
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(12), 7 - dayVal);
                    }
                }
            }else if(dateRange == 'LAST_N_DAYS:15'){
                if(dayVal - 15 >= 0){
                    multiplierMap.put(monthMap.get(monthVal), 15);
                   
                }else{
                    if(monthVal != 1){
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 15 - dayVal);
                    }else{
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(12), 15 - dayVal);
                    }
                }
            }else if(dateRange == 'LAST_N_DAYS:30'){
                if(dayVal - 30 >= 0){
                    multiplierMap.put(monthMap.get(monthVal), 30);
                    
                }else{
                    if(monthVal == 1){
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(12), 15 - dayVal);
                    }else if(monthVal == 3 && (dayVal == 1)){
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 1);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 28);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 1);
                    }else{
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), dayVal);
                        multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 15 - dayVal);
                    }
                }
            }else if(dateRange == 'LAST_MONTH'){
                if(monthVal == 1){
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                }else{
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 0);
                }
            }else if(dateRange == 'LAST_N_MONTHS:3'){
                if(monthVal == 1){
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                }else if(monthVal == 2){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                }else if(monthVal == 3){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                }else{
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 3), 0);
                }
            }else if(dateRange == 'LAST_N_MONTHS:6'){
                if(monthVal == 1){
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(8), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(7), 0);
                }else if(monthVal == 2){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(8), 0);
                }else if(monthVal == 3){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(9), 0);
                }else if(monthVal == 4){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                }else if(monthVal == 5){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                }else if(monthVal == 6){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(5), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                }else{
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 1), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 3), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 4), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 5), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal - 6), 0);
                }
            }else if(dateRange == 'THIS_MONTH'){
                multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(monthVal), 0);
            }else if(dateRange == 'THIS_FISCAL_YEAR'){
                if(monthVal >= 4){
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(5), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(6), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(7), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(8), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal + 1) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal + 1) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal + 1) + '_' + monthMap.get(3), 0);
                }else{
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(5), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(6), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(7), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(8), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 0);
                }
            }else if(dateRange == 'LAST_FISCAL_YEAR'){
                if(monthVal >= 4){
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(5), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(6), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(7), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(8), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal) + '_' + monthMap.get(3), 0);
                }else{
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(4), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(5), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(6), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(7), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(8), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(9), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(10), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(11), 0);
                    multiplierMap.put(String.valueOf(yearVal - 2) + '_' + monthMap.get(12), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(1), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(2), 0);
                    multiplierMap.put(String.valueOf(yearVal - 1) + '_' + monthMap.get(3), 0);
                }
            }
            if(multiplierMap != null){
                for(String yearMonth : multiplierMap.keySet()){
                    List<String> yearMonthSplit = yearMonth.split('_');
                    if(yearMonthSplit.size() > 1){
                        yearList.add(yearMonthSplit[0]);
                        monthList.add(yearMonthSplit[1]);
                    }
                }
                qry += ' AND Year__c =: yearList AND Month__c =: monthList';
            }
        }else if(year != null && year != ''){
            qry += ' AND Year__c =: year';
            if(months != null && months.size() > 0){
                List<String> mnths = new List<String>();
                for(String month : months){
                    mnths.add(monthMap.get(Integer.valueOf(month)));
                }
                //String mnth = monthMap.get(Integer.valueOf(month));
                qry += ' AND Month__c IN: mnths';
            }
        }
        if(project != 'All'){
            qry += ' AND Project__r.Name =: project';
        }
        System.debug('project: ' + project);
        System.debug('dateRange: ' + dateRange);
        System.debug('year: ' + year);
        System.debug('months: ' + months);
        System.debug('yearList: ' + yearList);
        System.debug('monthList: ' + monthList);
        System.debug('multiplierMap: ' + multiplierMap);
        System.debug('qry: ' + qry);
        if(table == 'table6'){
            List<Budget_vs_Expenses__c> budgets = Database.query(qry);
            System.debug('budgets: ' + budgets.size());
            System.debug('budgets: ' + budgets);
            Decimal spends = 0;
            Decimal spends_custom = 0;
            Map<String, Decimal> budgetMap = new Map<String, Decimal>();
            for(Budget_vs_Expenses__c b : budgets){
                budgetMap.put(b.Year__c + '_' + b.Month__c, (b.Spends_Planned__c / monthStrDaysMap.get(b.Month__c)));
                spends_custom += b.Spends_Planned__c;
            }
            if(dateRange != 'Custom'){
                for(String yearMonth : multiplierMap.keySet()){
                    if(budgetMap.get(yearMonth) != null){
                        if(multiplierMap.get(yearMonth) > 0){
                            spends += (budgetMap.get(yearMonth) * multiplierMap.get(yearMonth));
                        }else{
                            spends += budgetMap.get(yearMonth);
                        }
                    }
                }
            }else{
                spends = spends_custom;
            }
            
            spends = spends / 10000000;
            System.debug('spends: ' + spends);
            return String.valueOf(spends);
        }else if(table == 'table7'){
            return qry + '#' + yearList + '#' + monthList ;
        }else{
            return null;
        }
    }
    

    private static List<Map<String, Object>> spendsTable(String year, List<String> months, List<String> sources, String dateRange, String project) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<Integer,String> monthMap = new Map<Integer, String>{1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December'};
        //String mnth = monthMap.get(Integer.valueOf(month));
        Integer selYear = (year != '')? Integer.valueOf(year) : null;
        Integer selMonth;
        List<Integer> months_Int = new List<Integer>();
        if(months != null && months.size() > 0){
            for(String month : months){
                months_Int.add(Integer.valueOf(month));
            }
        }
        Map<String, Map<String, Decimal>> mediaMap = new Map<String, Map<String, Decimal>>();
        
        String leadQry = 'SELECT RW_Project__r.Name proj, COUNT(Id) total FROM Lead WHERE IsConverted = false AND LeadSource != null';
        leadQry += ' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            leadQry += ' AND LeadSource IN: sources';
        }
        if(dateRange != 'Custom'){
            leadQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            leadQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                leadQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project';
        }
        leadQry += ' GROUP BY RW_Project__r.Name';
        List<AggregateResult> leadMediaAgg = Database.query(leadQry);
       
        for(AggregateResult ar : leadMediaAgg) {
            String proj = (String)ar.get('proj');
            if(mediaMap.containsKey(proj)) {
                mediaMap.get(proj).put('leads', (Decimal)ar.get('total'));
            }else{
                mediaMap.put(proj, new Map<String, Decimal>{'leads' => (Decimal)ar.get('total')});
            }
        }

        
        String oppQry = 'SELECT RW_Project__r.Name proj, COUNT(Id) total FROM Opportunity WHERE LeadSource != null';
        oppQry += ' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            oppQry += ' AND LeadSource IN: sources';
        }
        if(dateRange != 'Custom'){
            oppQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            oppQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                oppQry += ' AND CALENDAR_MONTH(CreatedDate) =: months_Int';
            }
        }
        if(project != 'All'){
            oppQry += ' AND RW_Project__r.Name =: project';
        }
        oppQry += ' GROUP BY RW_Project__r.Name';
        List<AggregateResult> oppMediaAgg = Database.query(oppQry);
       
        for(AggregateResult ar : oppMediaAgg) {
            String proj = (String)ar.get('proj');
            if(mediaMap.containsKey(proj)) {
                mediaMap.get(proj).put('walkins', (Decimal)ar.get('total'));
            }else{
                mediaMap.put(proj, new Map<String, Decimal>{'walkins' => (Decimal)ar.get('total')});
            }
        }

        
        String bkgQry = 'SELECT Project__r.Name proj, COUNT(Id) total, SUM(Allotment_Premium__c) rev FROM Booking__c WHERE Opportunity__r.LeadSource != null';
        bkgQry += ' AND Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            bkgQry += ' AND Opportunity__r.LeadSource IN: sources';
        }
        if(dateRange != 'Custom'){
            bkgQry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            bkgQry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                bkgQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        if(project != 'All'){
            bkgQry += ' AND Project__r.Name =: project';
        }
        bkgQry += ' GROUP BY Project__r.Name';
        System.debug('bkgQry: ' + bkgQry);
        List<AggregateResult> bkgMediaAgg = Database.query(bkgQry);

        for(AggregateResult ar : bkgMediaAgg) {
            String proj = (String)ar.get('proj');
            if(mediaMap.containsKey(proj)) {
                mediaMap.get(proj).put('bookings', (Decimal)ar.get('total'));
            }else{
                mediaMap.put(proj, new Map<String, Decimal>{'bookings' => (Decimal)ar.get('total')});
            }
        }

        String spendsQry = calculateSpends(project, dateRange, year, months, 'table7'); 
        List<String> splitstr = spendsQry.split('#');
        System.debug('spendsQry: ' + spendsQry);
        String qry = splitstr[0];

        String yearStr = splitstr[1].replace('(', '').replace(')', '');
        List<String> yearList = new List<String>();
        for(String y : yearStr.split(',')) {
            yearList.add(y.trim());
        }

        String monthStr = splitstr[2].replace('(', '').replace(')', '');
        List<String> monthList = new List<String>();
        for(String m : monthStr.split(',')) {
            monthList.add(m.trim());
        }
        List<String> mnths = new List<String>();
        if(months != null && months.size() > 0){
            for(String month : months){
                mnths.add(monthMap.get(Integer.valueOf(month)));
            }
        }
        List<Budget_vs_Expenses__c> spends = Database.query(qry);
        Map<String, Decimal> projSpendsMap = new Map<String, Decimal>();
        for(Budget_vs_Expenses__c spend :  spends){
            System.debug('spend: ' + spend);
            if(projSpendsMap.containsKey(spend.Project__r.Name)){
                projSpendsMap.put(spend.Project__r.Name, projSpendsMap.get(spend.Project__r.Name) + spend.Spends_Planned__c);
            }else{
                projSpendsMap.put(spend.Project__r.Name, spend.Spends_Planned__c);
            }
        }
        
        
        List<ProjectWrapper> projects = getProjects('table7');
        List<String> projList = new List<String>();
        for(ProjectWrapper proj : projects){
            projList.add(proj.label);
        }
        for (String proj : projList) {
            System.debug('projSpendsMap.get(proj): ' + projSpendsMap.get(proj));
            System.debug('mediaMap.get(proj): ' + mediaMap.get(proj));
            if( mediaMap.get(proj) != null){
                Decimal spendsVal = (projSpendsMap.get(proj) != null)? projSpendsMap.get(proj) : 0;
                Map<String, Object> row = new Map<String, Object>();
                row.put('project', proj);
                row.put('spends', spendsVal);
                if(mediaMap.get(proj).get('leads') != null){
                    row.put('leads', mediaMap.get(proj).get('leads'));
                    row.put('cpl', (spendsVal / mediaMap.get(proj).get('leads')).setScale(2));
                }else{
                    row.put('leads', 0);
                    row.put('cpl', 0);
                }
                if(mediaMap.get(proj).get('walkins') != null){
                    row.put('walkins', mediaMap.get(proj).get('walkins'));
                    row.put('cpw', (spendsVal / mediaMap.get(proj).get('walkins')).setScale(2));
                }else{
                    row.put('walkins', 0);
                    row.put('cpw', 0);
                }
                if(mediaMap.get(proj).get('bookings') != null){
                    row.put('bookings', mediaMap.get(proj).get('bookings'));
                    row.put('cpb', (spendsVal / mediaMap.get(proj).get('bookings')).setScale(2));
                }else{
                    row.put('bookings', 0);
                    row.put('cpb', 0);
                }
                System.debug('row: ' + row);
                finalResult.add(row);
            }
        }
        System.debug('finalResult: ' + finalResult);
        return finalResult;
    }

    private static List<Map<String, Object>> getWalkinToBookingConversionLogic(List<String> sources,  String dateRange, String project, String year, List<String> months){
        if(dateRange == ''){
            return walkinToBookingLast12Months(sources, project);
        }else{
            return walkinToBookingForDateRange(sources, dateRange, project, year, months);
        }
    }

    private static List<Map<String, Object>> walkinToBookingLast12Months(List<String> sources, String project) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<String, Map<String, Decimal>> projectMonthlyData = new Map<String, Map<String, Decimal>>();
        
        
        Map<String, Decimal> globalWalkinCount = new Map<String, Decimal>();
        Map<String, Decimal> globalBookingCount = new Map<String, Decimal>();
        
        Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        List<String> leadSources = new List<String>{'Presales','Digital'};
        System.debug('sources: ' + sources);
        String qry = 'SELECT Id,CreatedDate,RW_Project__r.Name,Booking__c,Booking__r.CreatedDate,Booking__r.RW_Booking_Confirmed_Date__c,Booking__r.Status__c FROM Opportunity';
        qry += ' WHERE CreatedDate >= :startDate AND RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            qry += ' AND LeadSource IN: sources';
        }
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        List<Opportunity> oppList = Database.query(qry);
       
        Map<String,List<Opportunity>> projVsOppMap = new Map<String, List<Opportunity>>();
        Map<String, Map<String,Decimal>> projMonthlyMap = new Map<String, Map<String,Decimal>>();
        Map<String, Decimal> monthlyOppMap = new Map<String, Decimal>();
        Map<String, Decimal> monthlyBkgMap = new Map<String, Decimal>();
        for(Opportunity opp : oppList){
            if(!projVsOppMap.containsKey(opp.RW_Project__r.Name)){
                projVsOppMap.put(opp.RW_Project__r.Name, new List<Opportunity>{opp});
            }else{
                projVsOppMap.get(opp.RW_Project__r.Name).add(opp);
            }
            
        }
        for(String proj : projVsOppMap.keySet()){
            Map<String,Decimal> monthlyMap = new Map<String, Decimal>();
            System.debug('proj: ' + proj);
            for(Opportunity opp : projVsOppMap.get(proj)){
                if(monthlyOppMap.containsKey(opp.CreatedDate.month() + '-' + opp.CreatedDate.year())){
                    monthlyOppMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year(), monthlyOppMap.get(opp.CreatedDate.month() + '-' + opp.CreatedDate.year()) + 1);
                }else{
                    monthlyOppMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year(), 1);
                }
                if(!monthlyMap.containsKey(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_walkin')){
                    monthlyMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_walkin', 1);
                }else{
                    monthlyMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_walkin', monthlyMap.get((opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_walkin')) + 1);
                }
                System.debug('monthlyOppMap: ' + monthlyOppMap);
                System.debug('monthlyMap _walkin: ' + monthlyMap);
                if(opp.Booking__c != null &&  opp.Booking__r.Status__c == 'Booking Confirmed' && opp.Booking__r.RW_Booking_Confirmed_Date__c != null){
                    Integer oppMonth = opp.CreatedDate.month();
                    Integer oppYear  = opp.CreatedDate.year();
                    Integer bkgMonth = opp.Booking__r.RW_Booking_Confirmed_Date__c.month();
                    Integer bkgYear  = opp.Booking__r.RW_Booking_Confirmed_Date__c.year();
                    if(oppYear == bkgYear && oppMonth == bkgMonth){
                        if(!monthlyMap.containsKey(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_booking')){
                            monthlyMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_booking', 1);
                        }else{
                            monthlyMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_booking', monthlyMap.get((opp.CreatedDate.month() + '-' + opp.CreatedDate.year() + '_booking')) + 1);
                        }
                        if(monthlyBkgMap.containsKey(opp.CreatedDate.month() + '-' + opp.CreatedDate.year())){
                            monthlyBkgMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year(), monthlyBkgMap.get(opp.CreatedDate.month() + '-' + opp.CreatedDate.year()) + 1);
                        }else{
                            monthlyBkgMap.put(opp.CreatedDate.month() + '-' + opp.CreatedDate.year(), 1);
                        }
                        System.debug('monthlyBkgMap: ' + monthlyOppMap);
                        System.debug('monthlyMap _booking: ' + monthlyMap);
                    }
                }
            }
            projMonthlyMap.put(proj, monthlyMap);
        }
        projectMonthlyData = projMonthlyMap;
        for (String proj : projectMonthlyData.keySet()) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('project', proj);
            
            
            for (Integer i = 0; i < 12; i++) {
                Date d = startDate.addMonths(i);
                String mKey = d.month() + '-' + d.year();
                Decimal converted = projectMonthlyData.get(proj).get(mKey + '_booking');
                System.debug('--_booking: ' + converted);
                Decimal total = projectMonthlyData.get(proj).get(mKey + '_walkin');
                System.debug('--_walkin: ' + total);
                Decimal percentage = (total != null && total > 0) ? 
                                    (converted != null ? (converted / total * 100).setScale(2) : 0) : 0;
                
                row.put('month' + i, percentage);
            }
            System.debug('row: ' + row);
            finalResult.add(row);
        }
        System.debug('finalResult: ' + finalResult);
        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotalRow', true);
        for (Integer i = 0; i < 12; i++) {
            Date d = startDate.addMonths(i);
            String mKey = d.month() + '-' + d.year();
            
            System.debug('Total Bkgs ' + mKey + ' : ' + monthlyBkgMap.get(mKey));
            System.debug('Total opps ' + mKey + ' : ' + monthlyOppMap.get(mKey));
            System.debug('Total % : ' + calculatePercent(monthlyBkgMap.get(mKey), monthlyOppMap.get(mKey)));
            totalRow.put('month' + i, calculatePercent(monthlyBkgMap.get(mKey), monthlyOppMap.get(mKey)));
        }
        finalResult.add(totalRow);
        return finalResult;
        
    }
    private static List<Map<String, Object>> walkinToBookingForDateRange(List<String> sources, String dateRange, String project, String year, List<String> months) {
        List<Map<String, Object>> finalResult = new List<Map<String, Object>>();
        Map<String, Map<String, Decimal>> projectMonthlyData = new Map<String, Map<String, Decimal>>();
        Integer selYear = (year != '')? Integer.valueOf(year) : null;
        Integer selMonth;
        List<Integer> months_Int = new List<Integer>();
        if(months != null && months.size() > 0){
            for(String m : months){
                months_Int.add(Integer.valueOf(m));
            }
        }
        Map<String, Decimal> globalWalkinCount = new Map<String, Decimal>();
        Map<String, Decimal> globalBookingCount = new Map<String, Decimal>();
        
        Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        List<String> leadSources = new List<String>{'Presales','Digital'};
        System.debug('source: ' + sources);
        String qry = 'SELECT Id,CreatedDate,RW_Project__r.Name,Booking__c,Booking__r.CreatedDate FROM Opportunity';
        qry += ' WHERE CreatedDate >= :startDate AND RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            qry += ' AND LeadSource IN: sources';
        }
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        if(dateRange != 'Custom'){
            qry += ' AND CreatedDate = ' + daterange;
        }else if(year != null && year != ''){
            qry += ' AND CALENDAR_YEAR(CreatedDate) =: selYear';
            if(months != null && months.size() > 0){
                qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
        }
        List<Opportunity> oppList = Database.query(qry);
        Map<String,List<Opportunity>> projVsOppMap = new Map<String, List<Opportunity>>();
        Map<String, Map<String,Decimal>> projMonthlyMap = new Map<String, Map<String,Decimal>>();
        Map<String, Decimal> monthlyOppMap = new Map<String, Decimal>();
        Map<String, Decimal> monthlyBkgMap = new Map<String, Decimal>();
        for(Opportunity opp : oppList){
            if(!projVsOppMap.containsKey(opp.RW_Project__r.Name)){
                projVsOppMap.put(opp.RW_Project__r.Name, new List<Opportunity>{opp});
            }else{
                projVsOppMap.get(opp.RW_Project__r.Name).add(opp);
            }
            
        }
        Decimal totalOpps = 0;
        Decimal totalBookings = 0;
        for(String proj : projVsOppMap.keySet()){
            Decimal bookingsCount = 0;
            Map<String,Decimal> walkinToBookingMap = new Map<String, Decimal>();
            System.debug('proj: ' + proj);
            for(Opportunity opp : projVsOppMap.get(proj)){
                totalOpps += 1;
                if(opp.Booking__c != null){
                    Integer oppMonth = opp.CreatedDate.month();
                    Integer oppYear  = opp.CreatedDate.year();
                    Integer bkgMonth = opp.Booking__r.CreatedDate.month();
                    Integer bkgYear  = opp.Booking__r.CreatedDate.year();
                    if(oppYear == bkgYear && oppMonth == bkgMonth){
                        bookingsCount += 1;
                        totalBookings += 1;
                    }
                }
            }
            walkinToBookingMap.put('walkin', projVsOppMap.get(proj).size());
            walkinToBookingMap.put('booking', bookingsCount);
            projectMonthlyData.put(proj, walkinToBookingMap);
        }
        for (String proj : projectMonthlyData.keySet()) {
            Map<String, Object> row = new Map<String, Object>();
            row.put('project', proj);
            
            Decimal converted = projectMonthlyData.get(proj).get('booking');
            System.debug('--_booking: ' + converted);
            Decimal total = projectMonthlyData.get(proj).get('walkin');
            System.debug('--_walkin: ' + total);
            Decimal percentage = (total != null && total > 0) ? (converted != null ? (converted / total * 100).setScale(2) : 0) : 0;
            
            row.put('month', percentage);
            
            System.debug('row: ' + row);
            finalResult.add(row);
        }
        System.debug('finalResult: ' + finalResult);
        Map<String, Object> totalRow = new Map<String, Object>();
        totalRow.put('project', 'Total');
        totalRow.put('isTotalRow', true);
        totalRow.put('month', calculatePercent(totalBookings, totalOpps));
        finalResult.add(totalRow);
        return finalResult;
        
    }
    

    @AuraEnabled
    public static Map<String, String> generateCSV(String tableType, String year, List<String> months, List<String> sources, String dateRange, String project){
        Map<String, String> csvFiles = new Map<String, String>();
        String vertical = (sources != null && sources.size() > 0)? sources[0] : '';
        List<String> leadSources;
        if(vertical == 'Digital'){
            leadSources = new List<String>{'Digital','Facebook','Property Portals'};
        }else if(vertical == 'Direct'){
            leadSources = new List<String>{'Direct','Events','Exhibitions','Hoarding','Magazines','Newspapers','Paper Inserts','Radio','Surround Marketing','TV'};
        }else if(vertical == 'Presales/Direct'){
            leadSources = new List<String>{'Presales','Individual calling','Corporate' };
        }
        Integer year_Int = (year != null && year != '')? Integer.valueOf(year) : null;
        //Integer month_Int = String.isBlank(month) ? null : Integer.valueOf(month);
        List<Integer> months_Int = new List<Integer>();
        for(String mnth : months){
            months_Int.add(Integer.valueOf(mnth));
        }
        if(tableType == 'table1'){
            String leadQry1 = 'SELECT Id, FirstName, LastName, Status, CreatedDate, RW_Project__r.Name, LeadSource, IsConverted, ConvertedOpportunityId, ConvertedDate, ConvertedOpportunity.StageName, ConvertedOpportunity.Booking__c, ConvertedOpportunity.Booking__r.Status__c, ConvertedOpportunity.Booking__r.RW_Booking_Confirmed_Date__c, ConvertedOpportunity.Booking__r.Allotment_Premium__c FROM Lead';
            leadQry1 += queryFilterBuilder('table1', 'Lead', vertical, project, '', year, months);
            System.debug('leadQry1: ' + leadQry1);
            List<Lead> leadList =  Database.query(leadQry1);

            String leadCSV = 'Project Name,Lead Id,FirstName,LastName,LeadSource,Status,Converted?,Converted Date,Opportunity Id,Stage Name,Booking Id,Booking Status,Booking Confirmed Date,Allotment Premium\n';
            
            if(leadList.size() > 0){
                for(Lead ld : leadList){
                    leadCSV += escapeCSV(ld.RW_Project__r.Name) + ',' +
                            escapeCSV(ld.Id) + ',' +
                            escapeCSV(ld.FirstName) + ',' +
                            escapeCSV(ld.LastName) + ',' +
                            escapeCSV(ld.LeadSource) + ',' +
                            escapeCSV(ld.Status) + ',' +
                            escapeCSV(String.valueOf(ld.IsConverted)) + ',' +
                            escapeCSV(String.valueOf(ld.ConvertedDate)) + ',' +
                            escapeCSV(ld.ConvertedOpportunityId) + ',' +
                            escapeCSV(ld.ConvertedOpportunity.StageName) + ',' +
                            escapeCSV(ld.ConvertedOpportunity.Booking__c) + ',' +
                            escapeCSV(ld.ConvertedOpportunity.Booking__r.Status__c) + ',' +
                            escapeCSV(String.valueOf(ld.ConvertedOpportunity.Booking__r.RW_Booking_Confirmed_Date__c)) + ',' +
                            escapeCSV(String.valueOf(ld.ConvertedOpportunity.Booking__r.Allotment_Premium__c)) + '\n';
                }
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
        }
        if(tableType == 'table2'){
            String leadCSV = 'Id,FirstName,LastName,LeadSource,Status,Project Name\n';
        
            String qry = 'SELECT Id, FirstName, LastName, LeadSource, Status, RW_Project__r.Name FROM Lead WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\'';
            if(project != 'All'){
                qry += ' AND RW_Project__r.Name =: project';
            }
            if(year != null && year != ''){
                qry +=  ' AND CALENDAR_YEAR(CreatedDate) =: year_Int';
            }
            if(months != null && months.size() > 0){
                qry +=  ' AND CALENDAR_MONTH(CreatedDate) IN: months_Int';
            }
            if(sources != null && sources.size() > 0){
                qry += ' AND LeadSource IN: source';
            }
            System.debug('qry: ' + qry);
            List<Lead> leads = Database.query(qry);
            if(leads.size() > 0){
                for(Lead ld : leads){
                    leadCSV += escapeCSV(ld.Id) + ',' +
                            escapeCSV(ld.FirstName) + ',' +
                            escapeCSV(ld.LastName) + ',' +
                            escapeCSV(ld.LeadSource) + ',' +
                            escapeCSV(ld.Status) + ',' +
                            escapeCSV(ld.RW_Project__r.Name) + '\n';
                }
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
        }else if(tableType == 'table3'){
            String leadCSV = table3Data(tableType, year_Int, months_Int, sources, dateRange, project);
            if(leadCSV != null){
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
        }else if(tableType == 'table4'){
            String opportunityCSV = table4Data(tableType, year_Int, months_Int, sources, dateRange, project);
            if(opportunityCSV != null){
                csvFiles.put('Opportunities.csv', EncodingUtil.base64Encode(Blob.valueOf(opportunityCSV)));
            }
        }else if(tableType == 'table5'){
            String budgetCSV = budgetData(tableType, year, months, dateRange, project);
            if(budgetCSV != null){
                csvFiles.put('Budget Vs Expenses.csv', EncodingUtil.base64Encode(Blob.valueOf(budgetCSV)));
            }
        }

        return csvFiles;      
    }
    

   /* @AuraEnabled
    public static Map<String, String> generateCSV1(String tableType, String year, String month, String source, String dateRange, String project) {
        Integer year_Int = (year != null && year != '')? Integer.valueOf(year) : null;
        Integer month_Int = (month != null && month != '')? Integer.valueOf(month) : null;
        Map<String, String> csvFiles = new Map<String, String>();
        if(tableType == 'table1' || tableType == 'table6' || tableType == 'table7'){
            String leadCSV = leadsData(tableType, year_Int, month_Int, source, dateRange, project);
            String opportunityCSV = opportunitiesData(tableType, year_Int, month_Int, source, dateRange, project);
            String bookingCSV = bookingsData(tableType, year_Int, month_Int, source, dateRange, project);
            if(leadCSV != null){
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
            if(opportunityCSV != null){
                csvFiles.put('Opportunities.csv', EncodingUtil.base64Encode(Blob.valueOf(opportunityCSV)));
            }
            if(bookingCSV != null){
                csvFiles.put('Bookings.csv', EncodingUtil.base64Encode(Blob.valueOf(bookingCSV)));
            }
        }else if(tableType == 'table2'){
            String leadCSV = leadsData(tableType, year_Int, month_Int, source, dateRange, project);
            if(leadCSV != null){
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
        }else if(tableType == 'table3'){
            String leadCSV = table3Data(tableType, year_Int, month_Int, source, dateRange, project);
            if(leadCSV != null){
                csvFiles.put('Leads.csv', EncodingUtil.base64Encode(Blob.valueOf(leadCSV)));
            }
        }else if(tableType == 'table4'){
            String opportunityCSV = table4Data(tableType, year_Int, month_Int, source, dateRange, project);
            if(opportunityCSV != null){
                csvFiles.put('Opportunities.csv', EncodingUtil.base64Encode(Blob.valueOf(opportunityCSV)));
            }
        }else if(tableType == 'table5'){
            String budgetCSV = budgetData(tableType, year, month, dateRange, project);
            if(budgetCSV != null){
                csvFiles.put('Budget Vs Expenses.csv', EncodingUtil.base64Encode(Blob.valueOf(budgetCSV)));
            }
        }
        return csvFiles;
    }*/

    

    private static String table3Data(String tableType, Integer year, List<Integer> months, List<String> sources, String dateRange, String project){
        
        Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        String leadQry = 'SELECT Id,FirstName,LastName,LeadSource,CreatedDate,RW_Project__r.Name,Status FROM Lead';
        leadQry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        String leadHistoryQry = 'SELECT LeadId, Field, OldValue, NewValue, CreatedDate FROM LeadHistory';
        leadHistoryQry += '  WHERE Field = \'Status\'';
        if(sources != null && sources.size() > 0){
            leadQry += ' AND LeadSource IN: sources';
            leadHistoryQry += ' AND Lead.LeadSource IN: sources';
        }
        if(project != 'All'){
            leadQry += ' AND RW_Project__r.Name =: project'; 
            leadHistoryQry += ' AND Lead.RW_Project__r.Name =: project'; 
        } 
        if(year != null){
            leadQry += ' AND CALENDAR_YEAR(CreatedDate) =: year';
            leadHistoryQry += ' AND CALENDAR_YEAR(CreatedDate) =: year';
            if(months != null && months.size() > 0){
                leadQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months';
                leadHistoryQry += ' AND CALENDAR_MONTH(CreatedDate) IN: months';
            }
        }else{
            leadQry += ' AND CreatedDate >=: startDate';
            leadHistoryQry += ' AND Lead.CreatedDate >=: startDate';
        }
        List<Lead> leads = Database.query(leadQry);
        List<LeadHistory> historyList = Database.query(leadHistoryQry);
        List<LeadHistory> junkStatusHistory = new List<LeadHistory>();
        for (LeadHistory lh : historyList) {
            if (lh.NewValue != null && String.valueOf(lh.NewValue) == 'Junk') {
                junkStatusHistory.add(lh);
            }
        }
        Map<Id,Date> junkDateMap = new Map<Id,Date>();
        for(LeadHistory leadHist : junkStatusHistory){
            junkDateMap.put(leadHist.LeadId, Date.valueOf(leadHist.CreatedDate));
        }
        List<Lead> filteredLeads = new List<Lead>();
        for(Lead ld : leads){
            if(junkDateMap.get(ld.Id) != null){
                Integer leadMonth = ld.CreatedDate.month();
                Integer leadYear  = ld.CreatedDate.year();
                Integer junkMonth = junkDateMap.get(ld.Id).month();
                Integer junkYear  = junkDateMap.get(ld.Id).year();
                /*if(leadYear == junkYear && leadMonth == junkMonth){
                    filteredLeads.add(ld);
                }*/
                if(months != null && months.size() > 0){
                    if(leadYear == junkYear && months.contains(junkMonth)){
                        filteredLeads.add(ld);
                    }
                }else if(leadYear == junkYear){
                    filteredLeads.add(ld);
                }
            }
        }
        String leadCSV = 'Id,FirstName,LastName,LeadSource,Status,Project Name,Created Date,Converted Date\n';
        if(leads.size() > 0){
            for(Lead ld : leads){
                leadCSV += escapeCSV(ld.Id) + ',' +
                           escapeCSV(ld.FirstName) + ',' +
                           escapeCSV(ld.LastName) + ',' +
                           escapeCSV(ld.LeadSource) + ',' +
                           escapeCSV(ld.Status) + ',' +
                           escapeCSV(ld.RW_Project__r.Name) + ',' +
                           escapeCSV(String.valueOf(ld.CreatedDate)) + ',' +
                           escapeCSV(String.valueOf(junkDateMap.get(ld.Id))) + '\n';
            }
            return leadCSV;
        }else{
            return null;
        }
    }

    private static String table4Data(String tableType, Integer year, List<Integer> months, List<String> sources, String dateRange, String project){
        Date startDate = Date.today().addMonths(-11).toStartOfMonth();
        List<String> leadSources = new List<String>{'Presales','Digital'};
        System.debug('sources: ' + sources);
        String qry = 'SELECT Id,Name,CreatedDate,StageName,LeadSource,RW_Project__r.Name,Booking__c,Booking__r.CreatedDate,Booking__r.RW_Booking_Confirmed_Date__c,Booking__r.Status__c FROM Opportunity';
        qry += ' WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\' AND RW_Project__r.Name != \'Runwal Garden City\'';
        if(sources != null && sources.size() > 0){
            qry += ' AND LeadSource IN: sources';
        }
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        if(dateRange != 'Custom' && dateRange != ''){
            qry += ' AND CreatedDate = ' + daterange;
        }else if(dateRange == ''){
            qry += ' AND CreatedDate >=: startDate';
        }else if(year != null){
            qry += ' AND CALENDAR_YEAR(CreatedDate) =: year';
            if(months != null && months.size() > 0){
                qry += ' AND CALENDAR_MONTH(CreatedDate) IN: months';
            }
        }
        List<Opportunity> oppList = Database.query(qry);
        List<Opportunity> filteredOpps = new List<Opportunity>();
        for(Opportunity opp : oppList){
            if(opp.Booking__c != null && opp.Booking__r.Status__c == 'Booking Confirmed' && opp.Booking__r.RW_Booking_Confirmed_Date__c != null){
                Integer oppMonth = opp.CreatedDate.month();
                Integer oppYear  = opp.CreatedDate.year();
                Integer bkgMonth = opp.Booking__r.RW_Booking_Confirmed_Date__c.month();
                Integer bkgYear  = opp.Booking__r.RW_Booking_Confirmed_Date__c.year();
                if(oppYear == bkgYear && oppMonth == bkgMonth){
                    filteredOpps.add(opp);
                }
            }
        }
        String opportunityCSV = 'Id,Name,StageName,LeadSource,Project Name,Opportunity Created Date,Booking Confirmed Date\n';
        if(oppList.size() > 0){
            for(Opportunity opp : oppList){
                opportunityCSV += escapeCSV(opp.Id) + ',' +
                           escapeCSV(opp.Name) + ',' +
                           escapeCSV(opp.StageName) + ',' +
                           escapeCSV(opp.LeadSource) + ',' +
                           escapeCSV(opp.RW_Project__r.Name) + ',' +
                           escapeCSV(String.valueOf(opp.CreatedDate)) + ',' +
                           escapeCSV(String.valueOf(opp.Booking__r.RW_Booking_Confirmed_Date__c)) + '\n';
            }
            return opportunityCSV;
        }else{
            return null;
        }
    }

    private static String leadsData(String tableType, Integer year, Integer month, String source, String dateRange, String project){
        String leadCSV = 'Id,FirstName,LastName,LeadSource,Status,Project Name\n';
        
        String qry = 'SELECT Id, FirstName, LastName, LeadSource, Status, RW_Project__r.Name FROM Lead WHERE IsConverted = false AND RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\'';
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        if(year != null){
            qry +=  ' AND CALENDAR_YEAR(CreatedDate) = ' +  year;
        }
        if(month != null){
            qry +=  ' AND CALENDAR_MONTH(CreatedDate) = ' +  month;
        }
        if(source != ''){
            qry += ' AND LeadSource =: source';
        }else if(tableType == 'table6' && source == ''){
            List<String> mediaCategories = new List<String>{
                'Hoarding', 'Newspapers', 'Digital', 'Presales', 'Channel Partner', 'Referral', 'Loyalty', 'Employee / Managemen'
            };
            qry += ' AND LeadSource IN: mediaCategories';    
        }
        System.debug('qry: ' + qry);
        List<Lead> leads = Database.query(qry);
        if(leads.size() > 0){
            for(Lead ld : leads){
                leadCSV += escapeCSV(ld.Id) + ',' +
                           escapeCSV(ld.FirstName) + ',' +
                           escapeCSV(ld.LastName) + ',' +
                           escapeCSV(ld.LeadSource) + ',' +
                           escapeCSV(ld.Status) + ',' +
                           escapeCSV(ld.RW_Project__r.Name) + '\n';
            }
            return leadCSV;
        }else{
            return null;
        }
    }

    private static String opportunitiesData(String tableType, Integer year, Integer month, String source, String dateRange, String project){
        String opportunityCSV = 'Id,Name,StageName,LeadSource,Project Name\n';
        String qry = 'SELECT Id, Name, StageName, LeadSource, RW_Project__r.Name FROM Opportunity WHERE RW_Project__c != null AND RW_Project__r.RW_Status__c = \'Active\'';
        if(project != 'All'){
            qry += ' AND RW_Project__r.Name =: project';
        }
        if(year != null){
            qry +=  ' AND CALENDAR_YEAR(CreatedDate) = ' +  year;
        }
        if(month != null){
            qry +=  ' AND CALENDAR_MONTH(CreatedDate) = ' +  month;
        }
        if(source != ''){
            qry += ' AND LeadSource =: source';
        }
        if(tableType == 'table1'){
            qry += ' AND LeadSource =: source';
        }else if(tableType == 'table6'){
            List<String> mediaCategories = new List<String>{
                'Hoarding', 'Newspapers', 'Digital', 'Presales', 'Channel Partner', 'Referral', 'Loyalty', 'Employee / Managemen'
            };
            qry += ' AND LeadSource IN: mediaCategories';    
        }
        List<Opportunity> opportunities = Database.query(qry);
        if(opportunities.size() > 0){
            for(Opportunity opp : opportunities){
                opportunityCSV += escapeCSV(opp.Id) + ',' +
                           escapeCSV(opp.Name) + ',' +
                           escapeCSV(opp.StageName) + ',' +
                           escapeCSV(opp.LeadSource) + ',' +
                           escapeCSV(opp.RW_Project__r.Name) + '\n';
            }
            return opportunityCSV;
        }else{
            return null;
        }
    }

    private static String bookingsData(String tableType, Integer year, Integer month, String source, String dateRange, String project){
        String bookingsCSV = 'Id,Name,Status,LeadSource,Project Name\n';
        String qry = 'SELECT Id, Name, Status__c, Opportunity__r.LeadSource, Project__r.Name FROM Booking__c WHERE  Project__c != null AND Project__r.RW_Status__c = \'Active\'';
        if(project != 'All'){
            qry += ' AND Project__r.Name =: project';
        }
        if(year != null){
            qry +=  ' AND CALENDAR_YEAR(CreatedDate) = ' +  year;
        }
        if(month != null){
            qry +=  ' AND CALENDAR_MONTH(CreatedDate) = ' +  month;
        }
        if(source != ''){
            qry += ' AND Opportunity__r.LeadSource =: source';
        }
        if(tableType == 'table1'){
            qry += ' AND Opportunity__r.LeadSource =: source';
        }else if(tableType == 'table6'){
            List<String> mediaCategories = new List<String>{
                'Hoarding', 'Newspapers', 'Digital', 'Presales', 'Channel Partner', 'Referral', 'Loyalty', 'Employee / Managemen'
            };
            qry += ' AND Opportunity__r.LeadSource IN: mediaCategories';    
        }
        List<Booking__c> bookings = Database.query(qry);
        
        if(bookings.size() > 0){
            for(Booking__c bkg : bookings){
                bookingsCSV += escapeCSV(bkg.Id) + ',' +
                           escapeCSV(bkg.Name) + ',' +
                           escapeCSV(bkg.Status__c) + ',' +
                           escapeCSV(bkg.Opportunity__r.LeadSource) + ',' +
                           escapeCSV(bkg.Project__r.Name) + '\n';
            }
            return bookingsCSV;
        }else{
            return null;
        }
    }

    private static String budgetData(String tableType, String year, List<String> months, String dateRange, String project){
        Map<String,String> monthMap = new Map<String, String>{'1' => 'January', '2' => 'February', '3' => 'March', '4' => 'April', '5' => 'May', '6' => 'June', '7' => 'July', '8' => 'August', '9' => 'September', '10' => 'October', '11' => 'November', '12' => 'December'};
        String budgetCSV = 'Id,Name,Project Name,Year,Month,Spends Planned,BUdget(Cr),Balance Amount(Cr),Balance Days,Actual Expenses EIPL,Actual Expenses EREPL,Actula Expenses HHPL,Actula Expenses HHPL 2,Actula Expenses Horizon,Actual Expenses REPL,Actual Expenses RREPL,Actual Expenses RRPL,Actual Expenses SIPL,Actual Expenses WACL,Actual Expenses WRPL\n';
        String qry = 'SELECT Id,Name,Spends_Planned__c, Budget_in_Cr__c, Balance_Amount__c, Balance_Days__c, Project__r.Name, Month__c, Year__c,Actual_Expenses_EIPL__c,Actual_Expenses_EREPL__c,Actual_Expenses_HHPL__c,Actual_Expenses_HHPL_2__c,Actual_Expenses_Horizon__c,Actual_Expenses_REPL__c,Actual_Expenses_RREPL__c,Actual_Expenses_RRPL__c,Actual_Expenses_SIPL__c,Actual_Expenses_WACL__c,Actual_Expenses_WRPL__c ' +
                         'FROM Budget_vs_Expenses__c WHERE WBS_name_as_per_SAP__c = \'Digital advertising\' AND Project__c != null AND Project__r.RW_Status__c = \'Active\' AND Year__c =: year ';
        if (months != null && months.size() > 0){ 
            List<String> mnths = new List<String>();
            for(String m : months){
                mnths.add(monthMap.get(m));
            }
            qry += ' AND Month__c IN: mnths'; 
        }
        List<Budget_vs_Expenses__c> budgetList = Database.query(qry);
        
        if(budgetList.size() > 0){
            for(Budget_vs_Expenses__c budget : budgetList){
                budgetCSV += escapeCSV(budget.Id) + ',' +
                           escapeCSV(budget.Name) + ',' +
                           escapeCSV(budget.Project__r.Name) + ',' +
                           escapeCSV(budget.Year__c) + ',' +
                           escapeCSV(budget.Month__c) + ',' +
                           escapeCSV(String.valueOf(budget.Spends_Planned__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Budget_in_Cr__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Balance_Amount__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Balance_Days__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_EIPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_EREPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_HHPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_HHPL_2__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_Horizon__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_REPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_RREPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_RRPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_SIPL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_WACL__c)) + ',' +
                           escapeCSV(String.valueOf(budget.Actual_Expenses_WRPL__c)) + '\n';
            }
            return budgetCSV;
        }else{
            return null;
        }
    }

    

    private static String escapeCSV(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        value = value.replace('"', '""');
        if (value.contains(',') || value.contains('"') || value.contains('\n')) {
            value = '"' + value + '"';
        }
        return value;
    }

}