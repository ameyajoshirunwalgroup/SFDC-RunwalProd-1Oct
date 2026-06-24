public class CPDashboardController {


    @AuraEnabled(cacheable=true)
    public static Integer getUnprocessedCases(String period, String Year, String Month,String new_user){
        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        System.debug('new_user :: ' + new_user);

        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        
        String querynew = '';

        if (String.isNotBlank(period)) {
            if (period == 'Custom' && String.isNotBlank(Year) && String.isNotBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) =' + Year + ' AND CALENDAR_MONTH(CreatedDate) = ' + Month;
            } else if (period == 'Custom' && String.isBlank(Year) && String.isBlank(Month)) {
                querynew = '';
            } else if (period == 'Custom' && String.isNotBlank(Year) && String.isBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) = ' + Year;
            } else {
                querynew = 'CreatedDate = ' + period;
            }
        }

        System.debug('querynew:::::' + querynew);   
        
        String baseQuery = 'SELECT COUNT(Id) UnProcessed_Cases ' +
            'FROM Case ' +
            'WHERE RW_Project__c = null AND RecordTypeId =: CPRecordTypeId AND CreatedDate >= 2024-06-01T00:00:00Z ';
        if (String.isNotBlank(querynew)) {
            baseQuery += ' AND ' + querynew;
        }

        System.debug('baseQuery:::::' + baseQuery);

        List<AggregateResult> results = Database.query(baseQuery);
        System.debug('results:::::' + results);
        Integer unprocessedCases;
        for (AggregateResult ar : results) {
            unprocessedCases = (Integer)ar.get('UnProcessed_Cases');
            System.debug('unprocessedCases'+unprocessedCases);
        }

        return unprocessedCases;
        
    }
     
    @AuraEnabled(cacheable=true)
    public static List<RegisteredProjectCaseCount> getRegisteredCaseCountByProject(String period, String Year, String Month,String new_user) {
        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        System.debug('new_user :: ' + new_user);
        
        //Id CPPortalId = '0121e000000eZaqAAE';
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        system.debug('CPRecordTypeId'+CPRecordTypeId);
        
        String querynew = '';
        
        if (String.isNotBlank(period)) {
            if (period == 'Custom' && String.isNotBlank(Year) && String.isNotBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) =' + Year + ' AND CALENDAR_MONTH(CreatedDate) = ' + Month;
            } else if (period == 'Custom' && String.isBlank(Year) && String.isBlank(Month)) {
                querynew = '';
            } else if (period == 'Custom' && String.isNotBlank(Year) && String.isBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) = ' + Year;
            } else {
                querynew = 'CreatedDate = ' + period;
            }
        }
        
        String userNamePattern = '';
        if (String.isNotBlank(new_user)) {
            List<User> u = [SELECT Id, Name FROM User WHERE Id = :new_user LIMIT 1];
            if (!u.isEmpty()) {
                String userName = u[0].Name;
                System.debug('User Name: ' + userName);
                userNamePattern = '%' + userName + '%';
                System.debug('userNamePattern:::::' + userNamePattern);
            }
        }
        
        System.debug('querynew:::::' + querynew);
        
        String baseQuery = 'SELECT RW_Project__c, COUNT(Id) Registered_Cases, RW_Project__r.Name pname, ' +
            'Current_Stage__c, Status ' +
            'FROM Case ' +
            'WHERE RW_Project__c != null AND ContactId != null AND RecordTypeId = :CPRecordTypeId AND CreatedDate >= 2024-06-01T00:00:00Z';
        
        if (String.isNotBlank(querynew)) {
            baseQuery += ' AND ' + querynew;
        }
        
        
        
        if (String.isNotBlank(userNamePattern)) {
            baseQuery += ' AND Owners__c LIKE :userNamePattern';
        }
        
        baseQuery += ' GROUP BY RW_Project__r.Name, RW_Project__c, Current_Stage__c, Status';
        
        System.debug('baseQuery:::::' + baseQuery);
        List<AggregateResult> results = Database.query(baseQuery);
        
        system.debug('results'+results);
        
        
        // Maps to store aggregated data
        Map<String, RegisteredProjectCaseCount> projectCaseCountsMap = new Map<String, RegisteredProjectCaseCount>();
        RegisteredProjectCaseCount totalCaseCount = new RegisteredProjectCaseCount('Total', 'Total', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
        
        for (AggregateResult ar : results) {
            String projectId = (String)ar.get('RW_Project__c');
            String projectName = (String)ar.get('pname');
            String currentStage = (String)ar.get('Current_Stage__c');
            String status = (String)ar.get('Status');
            Integer registeredCases = (Integer)ar.get('Registered_Cases');
            
            if (!projectCaseCountsMap.containsKey(projectId)) {
                projectCaseCountsMap.put(projectId, new RegisteredProjectCaseCount(
                    projectId, projectName, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
            }
            
            
            
            RegisteredProjectCaseCount projectCaseCount = projectCaseCountsMap.get(projectId);
            projectCaseCount.registeredCases += registeredCases;
            
            // Increment the stage counts and status counts based on the current stage and status
            if (currentStage == 'CP-L1' && status == 'Case Closed') {
                projectCaseCount.stage1 += registeredCases;
            } else if (currentStage == 'CP-L2' && status == 'Case Closed') {
                projectCaseCount.stage2 += registeredCases;
            } else if (currentStage == 'CP-L3' && status == 'Case Closed') {
                projectCaseCount.stage3 += registeredCases;
            } else if (currentStage == 'CP-L4' && status == 'Case Closed') {
                projectCaseCount.stage4 += registeredCases;
            } else if (currentStage == 'CP-L5' && status == 'Case Closed') {
                projectCaseCount.stage5 += registeredCases;
            } else if (currentStage == 'CP-L6' && status == 'Case Closed') {
                projectCaseCount.stage6 += registeredCases;
            } else if (currentStage == 'CP-L7' && status == 'Case Closed') {
                projectCaseCount.stage7 += registeredCases;
            } else if (currentStage == 'CP-L8' && status == 'Case Closed') {
                projectCaseCount.stage8 += registeredCases;
            }



            // Increment the stage counts and status counts based on the current stage and status open
            if (currentStage == 'CP-L1' && status == 'Open') {
                projectCaseCount.openstage1 += registeredCases;
            } else if (currentStage == 'CP-L2' && status == 'Open') {
                projectCaseCount.openstage2 += registeredCases;
            } else if (currentStage == 'CP-L3' && status == 'Open') {
                projectCaseCount.openstage3 += registeredCases;
            } else if (currentStage == 'CP-L4' && status == 'Open') {
                projectCaseCount.openstage4 += registeredCases;
            } else if (currentStage == 'CP-L5' && status == 'Open') {
                projectCaseCount.openstage5 += registeredCases;
            } else if (currentStage == 'CP-L6' && status == 'Open') {
                projectCaseCount.openstage6 += registeredCases;
            } else if (currentStage == 'CP-L7' && status == 'Open') {
                projectCaseCount.openstage7 += registeredCases;
            } else if (currentStage == 'CP-L8' && status == 'Open') {
                projectCaseCount.openstage8 += registeredCases;
            }
            
            if (status == 'Open') {
                projectCaseCount.openregisteredCases += registeredCases;
            } else if (status == 'Case Closed') {
                projectCaseCount.closedregisteredCases += registeredCases;
            }
            
            // Update total counts
            totalCaseCount.registeredCases += registeredCases;
            if (status == 'Open') totalCaseCount.openregisteredCases += registeredCases;
            if (status == 'Case Closed') totalCaseCount.closedregisteredCases += registeredCases;
            
            if (currentStage == 'CP-L1' && status == 'Case Closed') {
                totalCaseCount.stage1 += registeredCases;
            } else if (currentStage == 'CP-L2' && status == 'Case Closed') {
                totalCaseCount.stage2 += registeredCases;
            } else if (currentStage == 'CP-L3' && status == 'Case Closed') {
                totalCaseCount.stage3 += registeredCases;
            } else if (currentStage == 'CP-L4' && status == 'Case Closed') {
                totalCaseCount.stage4 += registeredCases;
            } else if (currentStage == 'CP-L5' && status == 'Case Closed') {
                totalCaseCount.stage5 += registeredCases;
            } else if (currentStage == 'CP-L6' && status == 'Case Closed') {
                totalCaseCount.stage6 += registeredCases;
            } else if (currentStage == 'CP-L7' && status == 'Case Closed') {
                totalCaseCount.stage7 += registeredCases;
            } else if (currentStage == 'CP-L8' && status == 'Case Closed') {
                totalCaseCount.stage8 += registeredCases;
            }

            if (currentStage == 'CP-L1' && status == 'Open') {
                totalCaseCount.openstage1 += registeredCases;
            } else if (currentStage == 'CP-L2' && status == 'Open') {
                totalCaseCount.openstage2 += registeredCases;
            } else if (currentStage == 'CP-L3' && status == 'Open') {
                totalCaseCount.openstage3 += registeredCases;
            } else if (currentStage == 'CP-L4' && status == 'Open') {
                totalCaseCount.openstage4 += registeredCases;
            } else if (currentStage == 'CP-L5' && status == 'Open') {
                totalCaseCount.openstage5 += registeredCases;
            } else if (currentStage == 'CP-L6' && status == 'Open') {
                totalCaseCount.openstage6 += registeredCases;
            } else if (currentStage == 'CP-L7' && status == 'Open') {
                totalCaseCount.openstage7 += registeredCases;
            } else if (currentStage == 'CP-L8' && status == 'Open') {
                totalCaseCount.openstage8 += registeredCases;
            }
        }
        
        List<RegisteredProjectCaseCount> projectCaseCounts = new List<RegisteredProjectCaseCount>(projectCaseCountsMap.values());
        projectCaseCounts.add(totalCaseCount);
        
        System.debug('RegisteredProjectCaseCount data-' + projectCaseCounts);    
        return projectCaseCounts;
    }


    
    @AuraEnabled(cacheable=true)
    public static List<UnRegisteredProjectCaseCount> getUnRegisteredCaseCountByProject(String period, String Year, String Month, String new_user) {
        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        System.debug('new_user :: ' + new_user);
        
        String querynew = '';
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        
        if (String.isNotBlank(period)) {
            if (period == 'Custom' && String.isNotBlank(Year) && String.isNotBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) =' + Year + ' AND CALENDAR_MONTH(CreatedDate) = ' + Month;
            } else if (period == 'Custom' && String.isNotBlank(Year) && String.isBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) = ' + Year;
            } else if (period != 'Custom') {
                querynew = 'CreatedDate = ' + period;
            }
        }
        
        String userNamePattern = '';
        if (String.isNotBlank(new_user)) {
            List<User> u = [SELECT Id, Name FROM User WHERE Id = :new_user LIMIT 1];
            if (!u.isEmpty()) {
                String userName = u[0].Name;
                System.debug('User Name: ' + userName);
                userNamePattern = '%' + userName + '%';
                System.debug('userNamePattern:::::' + userNamePattern);
            }
        }
        
        System.debug('querynew:::::' + querynew);   
        
        String baseQuery = 'SELECT RW_Project__c, COUNT(Id) UnRegistered_Cases, RW_Project__r.name pname, ' +
            'Current_Stage__c, Status ' +
            'FROM Case ' +
            'WHERE RW_Project__c != null AND ContactId = null AND RecordTypeId =: CPRecordTypeId AND CreatedDate >= 2024-06-01T00:00:00Z ';
        if (String.isNotBlank(querynew)) {
            baseQuery += ' AND ' + querynew;
        }
        
        if (String.isNotBlank(userNamePattern)) {
            System.debug('userNamePattern:::::' + userNamePattern);
            baseQuery += ' AND Owners__c LIKE :userNamePattern';
        }
        
        baseQuery += ' GROUP BY RW_Project__r.name, RW_Project__c, Current_Stage__c, Status';
        
        List<AggregateResult> results = Database.query(baseQuery);
        
        Map<String, UnRegisteredProjectCaseCount> projectCaseCountsMap = new Map<String, UnRegisteredProjectCaseCount>();
        UnRegisteredProjectCaseCount totalCaseCount = new UnRegisteredProjectCaseCount('Total', 'Total',  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        
        for (AggregateResult ar : results) {
            String projectId = (String) ar.get('RW_Project__c');
            String projectName = (String) ar.get('pname');
            String currentStage = (String) ar.get('Current_Stage__c');
            String status = (String) ar.get('Status');
            Integer unregisteredCases = (Integer) ar.get('UnRegistered_Cases');
            
            if (!projectCaseCountsMap.containsKey(projectId)) {
                projectCaseCountsMap.put(projectId, new UnRegisteredProjectCaseCount(
                    projectId, projectName,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                ));
            }
            
            UnRegisteredProjectCaseCount projectCaseCount = projectCaseCountsMap.get(projectId);
            projectCaseCount.unregisteredCases += unregisteredCases;
            
            if (currentStage != null && status == 'Case Closed') {
                if (currentStage == 'CP-L1') {
                    projectCaseCount.stage1 += unregisteredCases;
                } else if (currentStage == 'CP-L2') {
                    projectCaseCount.stage2 += unregisteredCases;
                } else if (currentStage == 'CP-L3') {
                    projectCaseCount.stage3 += unregisteredCases;
                } else if (currentStage == 'CP-L4') {
                    projectCaseCount.stage4 += unregisteredCases;
                } else if (currentStage == 'CP-L5') {
                    projectCaseCount.stage5 += unregisteredCases;
                } else if (currentStage == 'CP-L6') {
                    projectCaseCount.stage6 += unregisteredCases;
                } else if (currentStage == 'CP-L7') {
                    projectCaseCount.stage7 += unregisteredCases;
                } else if (currentStage == 'CP-L8') {
                    projectCaseCount.stage8 += unregisteredCases;
                }
            }


            if (currentStage != null && status == 'Open') {
                if (currentStage == 'CP-L1') {
                    projectCaseCount.openstage1 += unregisteredCases;
                } else if (currentStage == 'CP-L2') {
                    projectCaseCount.openstage2 += unregisteredCases;
                } else if (currentStage == 'CP-L3') {
                    projectCaseCount.openstage3 += unregisteredCases;
                } else if (currentStage == 'CP-L4') {
                    projectCaseCount.openstage4 += unregisteredCases;
                } else if (currentStage == 'CP-L5') {
                    projectCaseCount.openstage5 += unregisteredCases;
                } else if (currentStage == 'CP-L6') {
                    projectCaseCount.openstage6 += unregisteredCases;
                } else if (currentStage == 'CP-L7') {
                    projectCaseCount.openstage7 += unregisteredCases;
                } else if (currentStage == 'CP-L8') {
                    projectCaseCount.openstage8 += unregisteredCases;
                }
            }
            
            if (status == 'Open') {
                projectCaseCount.openUnregisteredCases += unregisteredCases;
            } else if (status == 'Case Closed') {
                projectCaseCount.closedUnregisteredCases += unregisteredCases;
            }
            
            // Update total counts
            totalCaseCount.unregisteredCases += unregisteredCases;
            if (status == 'Open') totalCaseCount.openUnregisteredCases += unregisteredCases;
            if (status == 'Case Closed') totalCaseCount.closedUnregisteredCases += unregisteredCases;
            
            if (currentStage != null && status == 'Case Closed') {
                if (currentStage == 'CP-L1') {
                    totalCaseCount.stage1 += unregisteredCases;
                } else if (currentStage == 'CP-L2') {
                    totalCaseCount.stage2 += unregisteredCases;
                } else if (currentStage == 'CP-L3') {
                    totalCaseCount.stage3 += unregisteredCases;
                } else if (currentStage == 'CP-L4') {
                    totalCaseCount.stage4 += unregisteredCases;
                } else if (currentStage == 'CP-L5') {
                    totalCaseCount.stage5 += unregisteredCases;
                } else if (currentStage == 'CP-L6') {
                    totalCaseCount.stage6 += unregisteredCases;
                } else if (currentStage == 'CP-L7') {
                    totalCaseCount.stage7 += unregisteredCases;
                } else if (currentStage == 'CP-L8') {
                    totalCaseCount.stage8 += unregisteredCases;
                }
            }

            if (currentStage != null && status == 'Open') {
                if (currentStage == 'CP-L1') {
                    totalCaseCount.openstage1 += unregisteredCases;
                } else if (currentStage == 'CP-L2') {
                    totalCaseCount.openstage2 += unregisteredCases;
                } else if (currentStage == 'CP-L3') {
                    totalCaseCount.openstage3 += unregisteredCases;
                } else if (currentStage == 'CP-L4') {
                    totalCaseCount.openstage4 += unregisteredCases;
                } else if (currentStage == 'CP-L5') {
                    totalCaseCount.openstage5 += unregisteredCases;
                } else if (currentStage == 'CP-L6') {
                    totalCaseCount.openstage6 += unregisteredCases;
                } else if (currentStage == 'CP-L7') {
                    totalCaseCount.openstage7 += unregisteredCases;
                } else if (currentStage == 'CP-L8') {
                    totalCaseCount.openstage8 += unregisteredCases;
                }
            }
        }
        
        List<UnRegisteredProjectCaseCount> unprojectCaseCounts = new List<UnRegisteredProjectCaseCount>(projectCaseCountsMap.values());
        unprojectCaseCounts.add(totalCaseCount);
        
        System.debug('UnRegisteredProjectCaseCount data-' + unprojectCaseCounts);    
        return unprojectCaseCounts;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getCaseDataBasedonCustomLabel(String period, String Year, String Month,String new_user) {
        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        System.debug('new_user :: ' + new_user);
        String dataLabel = Label.show12MonthsSummaryonCPDashboard;
        System.debug('dataLabel'+dataLabel);
        boolean value;
        if(dataLabel.toUpperCase() == 'TRUE'){
            value =  true;
        }else if(dataLabel.toUpperCase() == 'FALSE'){
            value =  false;
        }
        return value;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<CaseWrapper> getCaseData() {

        List<CaseWrapper> caseList = new List<CaseWrapper>();
        Date endDate = Date.today();
        DateTime currentDate = Datetime.now();
        Date startDate = endDate.toStartOfMonth().addMonths(-12);
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        
        Map<String, List<Case>> monthYearCaseMap = new Map<String, List<Case>>();
        Map<String, List<Case>> unregisteredMonthYearCaseMap = new Map<String, List<Case>>();
        Map<String, List<Case>> totalCasesOpenedMonthYearCaseMap = new Map<String, List<Case>>();
        Map<String, List<Case>> totalCasesClosedMonthYearCaseMap = new Map<String, List<Case>>();
        Map<String, Map<String, List<Case>>> stageMonthYearCaseMap = new Map<String, Map<String, List<Case>>>();
        
        for (Integer i = 0; i < 12; i++) {
            Date monthDate = endDate.toStartOfMonth().addMonths(-i);
            String key = monthDate.month() + '/' + monthDate.year();
            monthYearCaseMap.put(key, new List<Case>());
            system.debug('monthYearCaseMap-------------'+monthYearCaseMap);
            unregisteredMonthYearCaseMap.put(key, new List<Case>());
            totalCasesOpenedMonthYearCaseMap.put(key, new List<Case>());
            totalCasesClosedMonthYearCaseMap.put(key, new List<Case>());
            for (Integer j = 1; j <= 8; j++) {
                if (!stageMonthYearCaseMap.containsKey(key)) {
                    stageMonthYearCaseMap.put(key, new Map<String, List<Case>>());
                }
                stageMonthYearCaseMap.get(key).put('CP-L' + j, new List<Case>());
            }
        }
        
        system.debug('currentDate'+currentDate);
        system.debug('startDate'+startDate);
        String baseQuery = 'SELECT Id, CaseNumber, Subject, Ageing__c, OwnerId, Status,ContactId, ' +
            'RW_Project__r.Name, CreatedDate, Account.Name, ' +
            'LastModifiedBy.Name, RW_RM_Name__c, Owner.Name, ' +
            'ClosedDate,Current_Stage__c,RW_Project__c ' +
            'FROM Case WHERE CreatedDate >= 2024-06-01T00:00:00Z AND CreatedDate >= :startDate AND CreatedDate <= :currentDate ' +
            'AND RW_Project__c != null AND RecordTypeId = :CPRecordTypeId';
        
        system.debug('baseQuery'+baseQuery);
        List<Case> allCases = Database.query(baseQuery);
        
        for (Case c : allCases) {
            String key = c.CreatedDate.month() + '/' + c.CreatedDate.year();
            if (c.ContactId == null) {
                unregisteredMonthYearCaseMap.get(key).add(c);
            } else {
                system.debug('monthYearCaseMap-------------'+monthYearCaseMap);
                monthYearCaseMap.get(key).add(c);
            }
            if (c.Status == 'Open') {
                totalCasesOpenedMonthYearCaseMap.get(key).add(c);
            } else if (c.Status == 'Case Closed') {
                totalCasesClosedMonthYearCaseMap.get(key).add(c);
            }
            if (c.Current_Stage__c != null && c.Current_Stage__c.startsWith('CP-L')) {
                stageMonthYearCaseMap.get(key).get(c.Current_Stage__c).add(c);
            }
        }
        
        for (String monthYear : unregisteredMonthYearCaseMap.keySet()) {
            Integer registeredCases = monthYearCaseMap.get(monthYear).size();
            Integer unregisteredCases = unregisteredMonthYearCaseMap.get(monthYear).size();
            Integer openCases = totalCasesOpenedMonthYearCaseMap.get(monthYear).size();
            Integer closedCases = totalCasesClosedMonthYearCaseMap.get(monthYear).size();
            
            Integer[] stageCases = new Integer[8];            
            for (Integer j = 1; j <= 8; j++) {
                // System.debug('stageMonthYearCaseMap.get(monthYear).get('CP-L' + j).size();'+stageMonthYearCaseMap.get(monthYear).get('CP-L' + j).size(););
                stageCases[j-1] = stageMonthYearCaseMap.get(monthYear).get('CP-L' + j).size();
                System.debug('stageCases[j-1]'+stageCases[j-1]);
                System.debug('stageCases'+stageCases);
            }
            
            String[] parts = monthYear.split('/');
            String month = parts[0];
            String year = parts[1];
            
            CaseWrapper caseWrapper = new CaseWrapper(month, year, registeredCases, unregisteredCases, openCases, closedCases,
                                                      stageCases[0], stageCases[1], stageCases[2], stageCases[3], stageCases[4], stageCases[5], stageCases[6],stageCases[7]);
            System.debug('caseWrapper'+caseWrapper);
            caseList.add(caseWrapper);
        }
        
        return caseList;
    }

    
    
    @AuraEnabled(cacheable=true)
    public static List<totalCaseCount> getTotalCaseCount(String period, String Year, String Month, String new_user) {
        System.debug('period :: ' + period);
        System.debug('Year :: ' + Year);
        System.debug('Month :: ' + Month);
        System.debug('new_user :: ' + new_user);
        
        String querynew = '';
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        
        
        String userNamePattern = '';
        if (String.isNotBlank(new_user)) {
            List<User> u = [SELECT Id, Name FROM User WHERE Id = :new_user LIMIT 1];
            if (!u.isEmpty()) {
                String userName = u[0].Name;
                System.debug('User Name: ' + userName);
                userNamePattern = '%' + userName + '%';
                System.debug('userNamePattern:::::' + userNamePattern);
            }
        }
        
        if (String.isNotBlank(period)) {
            if (period == 'Custom' && String.isNotBlank(Year) && String.isNotBlank(Month)) {
                querynew = ' CALENDAR_YEAR(CreatedDate) =' + Year + ' AND CALENDAR_MONTH(CreatedDate) = ' + Month;
            } else if (period == 'Custom' && String.isBlank(Year) && String.isBlank(Month)) {
                querynew = ''; // No additional filter needed for this case
            } else if (period == 'Custom' && String.isNotBlank(Year) && String.isBlank(Month)) {
                querynew = 'CALENDAR_YEAR(CreatedDate) = ' + Year;
            } else {
                querynew = 'CreatedDate = ' + period;
            }
        }
        
        String baseQuery = 'SELECT RW_Project__c, Current_Stage__c, Status ' +
            'FROM Case ' +
            'WHERE RW_Project__c != null AND RecordTypeId =: CPRecordTypeId AND CreatedDate >= 2024-06-01T00:00:00Z';
        
        if (String.isNotBlank(querynew)) {
            baseQuery += ' AND ' + querynew;
        }
        
        if (String.isNotBlank(userNamePattern)) {
            System.debug('userNamePattern:::::' + userNamePattern);
            baseQuery += ' AND Owners__c LIKE :userNamePattern';
        }
        
        System.debug('Final Query: ' + baseQuery);
        
        List<Case> cases = Database.query(baseQuery);
        
        totalCaseCount totalCaseCounts = new totalCaseCount( 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        
        for (Case c : cases) {
            totalCaseCounts.totalCases += 1;
            
            if (c.Status == 'Open') {
                totalCaseCounts.totalOpenCases += 1;
            } else if (c.Status == 'Case Closed') {
                totalCaseCounts.totalClosedCases += 1;
            }
            
            if (c.Current_Stage__c != null && c.Status == 'Case Closed') {
                if (c.Current_Stage__c == 'CP-L1') {
                    totalCaseCounts.totalStage1Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L2') {
                    totalCaseCounts.totalStage2Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L3') {
                    totalCaseCounts.totalStage3Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L4') {
                    totalCaseCounts.totalStage4Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L5') {
                    totalCaseCounts.totalStage5Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L6') {
                    totalCaseCounts.totalStage6Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L7') {
                    totalCaseCounts.totalStage7Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L8') {
                    totalCaseCounts.totalStage8Cases += 1;
                }
            }

            if (c.Current_Stage__c != null && c.Status == 'Open') {
                if (c.Current_Stage__c == 'CP-L1') {
                    totalCaseCounts.totalOpenStage1Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L2') {
                    totalCaseCounts.totalOpenStage2Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L3') {
                    totalCaseCounts.totalOpenStage3Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L4') {
                    totalCaseCounts.totalOpenStage4Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L5') {
                    totalCaseCounts.totalOpenStage5Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L6') {
                    totalCaseCounts.totalOpenStage6Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L7') {
                    totalCaseCounts.totalOpenStage7Cases += 1;
                } else if (c.Current_Stage__c == 'CP-L8') {
                    totalCaseCounts.totalOpenStage8Cases += 1;
                }
            }
        }
        
        System.debug('totalCaseCount data-' + totalCaseCounts);
        
        List<totalCaseCount> totalCaseCountsList = new List<totalCaseCount>();
        totalCaseCountsList.add(totalCaseCounts);
        
        return totalCaseCountsList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Case> getFilteredCasesNew(String data, String period, String Year, String Month,String new_user) {
        //String Origin = 'Channel Partner Portal';
       system.debug('data'+data);
        system.debug('period'+period);
        system.debug('Year'+Year);
        system.debug('Month'+Month);
        system.debug('new_user'+new_user);
        Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
        Map<String, Object> unpack = (Map<String, Object>) JSON.deserializeUntyped(data);
        String query;
        if (unpack.containsKey('unProcessedCases')) {
            System.debug('Unprocessed cases');
            query = 'SELECT Id, ownerId, CaseNumber,LastModifiedBy.Name,contact.name, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name = null ';
        }else{
            System.debug('Else Unprocessed cases');
            query = 'SELECT Id, ownerId, CaseNumber,LastModifiedBy.Name,contact.name, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name != null ';
        }
        
        List<String> conditions = new List<String>();
        
        // If project name is provided
        if (String.isNotBlank((String)unpack.get('projectName'))) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
        }

        
        
        // Add conditions for Registered cases
        if (unpack.containsKey('Registered')) {
            conditions.add('ContactId != null');
        }
        
        // Add conditions for registered cases based on project
        if (unpack.containsKey('registeredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId != null');
        }
        
        // Add conditions for open registered cases based on project
        if (unpack.containsKey('openregisteredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId != null');
            conditions.add('Status = \'Open\'');
        }
        
        // Add conditions for closed registered cases based on project
        if (unpack.containsKey('closedregisteredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId != null');
            conditions.add('Status = \'Case Closed\'');
        }
        
        
        // Add conditions for total open registered cases based on project
        if (unpack.containsKey('totalopenregistered')) {            
            conditions.add('ContactId != null');
            conditions.add('Status = \'Open\'');
        }
        // Add conditions for total closed registered cases based on project
        if (unpack.containsKey('totalclosedregistered')) {
            conditions.add('ContactId != null');
            conditions.add('Status = \'Case Closed\'');
        }

        for(Integer i = 1; i<= 8; i++){
            // Add conditions for registered current stage 1 cases based on project
            if (unpack.containsKey('stage' + i + '')) {
                System.debug('Inside :- closed stage '+ i);
                if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
                conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
                }
                conditions.add('ContactId != null');
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Case Closed\'');
            }
        }


        for(Integer i = 1; i<= 8; i++){
            // Add conditions for registered current stage 1 cases based on project
            if (unpack.containsKey('openstage' + i + '')) {
                System.debug('Inside :- open stage '+ i);
                if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
                conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
                }
                conditions.add('ContactId != null');
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Open\'');
            }
        }

        for(Integer i = 1; i<= 8; i++){
            // Add conditions for total registered current stage 1 cases based on project
            if (unpack.containsKey('totalstage' + i + 'rcases')) {
                conditions.add('ContactId != null');
                conditions.add('Current_Stage__c = \'CP-L' + i + '\'');
                conditions.add('Status = \'Case Closed\'');
            }
        }

        for(Integer i = 1; i<= 8; i++){
            // Add conditions for unregistered current stage i cases based on project
            if (unpack.containsKey('unstage' + i + '')) {
                if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
                conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
                }
                conditions.add('ContactId = null');
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Case Closed\'');
            }
        }

        for(Integer i = 1; i<= 8; i++){
            // Add conditions for total unregistered current stage 1 cases based on project
            if (unpack.containsKey('totalstage' + i + 'uncases')) {
                conditions.add('ContactId = null');
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Case Closed\'');
            }
        }
        
        for(Integer i=1;i<=8;i++){
            // Add conditions for total current stage i cases based on project
            if (unpack.containsKey('totalopenstage'+ i + 'cases')) {   
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Open\'');
            }
        }
        
        
        // Add conditions for UnRegistered cases
        if (unpack.containsKey('UnRegistered')) {
            conditions.add('ContactId = null');
        }
        
        
        // Add conditions for unregistered cases based on project
        if (unpack.containsKey('unregisteredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId = null');
        }
        
        // Add conditions for open unregistered cases based on project
        if (unpack.containsKey('openunregisteredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId = null');
            conditions.add('Status = \'Open\'');
        }
        
        // Add conditions for closed unregistered cases based on project
        if (unpack.containsKey('closedunregisteredCases')) {
            if(String.escapeSingleQuotes((String)unpack.get('projectName')) != 'Total'){
            conditions.add('RW_Project__r.Name = \'' + String.escapeSingleQuotes((String)unpack.get('projectName')) + '\'');
            }
            conditions.add('ContactId = null');
            conditions.add('Status = \'Case Closed\'');
        }
        
        // Add conditions for Total count(UnRegistered)
        if (unpack.containsKey('Total_Un')) {
            conditions.add('ContactId = null');
        }
        
        // Add conditions for total open unregistered cases based on project
        if (unpack.containsKey('totalopenunregistered')) {            
            conditions.add('ContactId = null');
            conditions.add('Status = \'Open\'');
        }
        // Add conditions for total closed unregistered cases based on project
        if (unpack.containsKey('totalclosedunregistered')) {
            conditions.add('ContactId = null');
            conditions.add('Status = \'Case Closed\'');
        }
        
        // Add conditions for total open cases
        if (unpack.containsKey('totalopencases')) {
            conditions.add('Status = \'Open\'');
        }
        
        // Add conditions for total closed cases
        if (unpack.containsKey('totalclosedcases')) {
            conditions.add('Status = \'Case Closed\'');
        }  


        for(Integer i=1;i<=8;i++){
            // Add conditions for total current stage i cases based on project
            if (unpack.containsKey('totalstage' +i + 'cases')) {
                conditions.add('Current_Stage__c = \'CP-L' + i + '\'');
                conditions.add('Status = \'Case Closed\'');
            }
        } 
        

        for(Integer i=1;i<=8;i++){
            // Add conditions for total current stage i cases based on project
            if (unpack.containsKey('totalOpenStage'+ i + 'Cases')) {   
                conditions.add('Current_Stage__c = \'CP-L' + i + '\''); 
                conditions.add('Status = \'Open\'');
            }
        }
        
        // Add conditions based on the period
        if (String.isNotBlank(period)) {
            if (period == 'Custom') {
                if (String.isNotBlank(Month) && String.isNotBlank(Year)) {
                    conditions.add('CALENDAR_YEAR(CreatedDate) = ' + String.escapeSingleQuotes(Year) + ' AND CALENDAR_MONTH(CreatedDate) = ' + String.escapeSingleQuotes(Month));
                } else if (String.isBlank(Month) && String.isNotBlank(Year)) {
                    conditions.add('CALENDAR_YEAR(CreatedDate) = ' + String.escapeSingleQuotes(Year));
                } else if (String.isBlank(Year) && String.isNotBlank(Month)) {
                    conditions.add('CALENDAR_MONTH(CreatedDate) = ' + String.escapeSingleQuotes(Month));
                }
            } else {
                conditions.add('CreatedDate = ' + String.escapeSingleQuotes(period));
            }
        }
        String userNamePattern = '';
        if (String.isNotBlank(new_user)) {
            List<User> u = [SELECT Id, Name FROM User WHERE Id = :new_user LIMIT 1];
            if (!u.isEmpty()) {
                String userName = u[0].Name;
                System.debug('User Name: ' + userName);
                userNamePattern = '%' + userName + '%';
                System.debug('userNamePattern:::::' + userNamePattern);
            }
        }
        
        if (String.isNotBlank(userNamePattern)) {
            System.debug('userNamePattern:::::' + userNamePattern);
            conditions.add('Owners__c LIKE :userNamePattern');
        }
        
        // Join the conditions
        query += String.join(conditions, ' AND ');
        
        // Default case if project name is not provided
        //if (String.isBlank((String)unpack.get('projectName'))) {
            
            if (unpack.containsKey('unProcessedCases')) {
                System.debug('Unprocessed cases');
                query = 'SELECT Id, Ageing__c,contact.name,LastModifiedBy.Name, ownerId, CaseNumber, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name = null ';
            }else{
                System.debug('Else Unprocessed cases');
                query = 'SELECT Id, Ageing__c,contact.name,LastModifiedBy.Name, ownerId, CaseNumber, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name != null ';
            }
            
            // query = 'SELECT Id, Ageing__c,contact.name,LastModifiedBy.Name, ownerId, CaseNumber, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name != null ';
            
            if (conditions.size() > 0) {
                query += ' AND ' + String.join(conditions, ' AND ');
            }
        //}
        
        System.debug('query :: ' + query);
        query += ' Order by CreatedDate DESC';
        System.debug('query :: ' + query);
        
        List<Case> filteredCases = new List<Case>();
        try {
            filteredCases = Database.query(query);
        } catch (Exception ex) {
            System.debug('Exception occurred while fetching filtered cases: ' + ex.getMessage());
        }
        
        return filteredCases;
    }
    

    // @AuraEnabled(cacheable=true)
    // public static List<Case> getFilteredCasesNew1(String data, String period, String Year, String Month, String new_user) {
    //     system.debug('data' + data);
    //     system.debug('period' + period);
    //     system.debug('Year' + Year);
    //     system.debug('Month' + Month);
    //     system.debug('new_user' + new_user);
        
    //     Id CPRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Channel Partner Portal').getRecordTypeId();
    //     Map<String, Object> unpack = (Map<String, Object>) JSON.deserializeUntyped(data);
    //     String query = 'SELECT Id, ownerId, CaseNumber, LastModifiedBy.Name, contact.name, CreatedDate, ClosedDate, RW_Project__r.Name, Subject, Status, Owner.Name, Current_Stage__c FROM Case WHERE RecordTypeId = :CPRecordTypeId AND RW_Project__r.Name != null ';
    //     List<String> conditions = new List<String>();

    //     String projectName = String.escapeSingleQuotes((String) unpack.get('projectName'));
    //     if (String.isNotBlank(projectName) && projectName != 'Total') {
    //         conditions.add('RW_Project__r.Name = \'' + projectName + '\'');
    //     }
        
    //     if (unpack.containsKey('unProcessedCases')) {
    //         query = 'SELECT Id FROM Case WHERE RW_Project__c = null AND RecordTypeId = :CPRecordTypeId';
    //     }

    //     Map<String, List<String>> filterConditions = new Map<String, List<String>>{
    //         'Registered' => new List<String>{'ContactId != null'},
    //         'registeredCases' => new List<String>{'ContactId != null'},
    //         'openregisteredCases' => new List<String>{'ContactId != null', 'Status = \'Open\''},
    //         'closedregisteredCases' => new List<String>{'ContactId != null', 'Status = \'Case Closed\''},
    //         'totalopenregistered' => new List<String>{'ContactId != null', 'Status = \'Open\''},
    //         'totalclosedregistered' => new List<String>{'ContactId != null', 'Status = \'Case Closed\''},
    //         'stage1' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L1\'', 'Status = \'Case Closed\''},
    //         'stage2' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L2\'', 'Status = \'Case Closed\''},
    //         'stage3' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L3\'', 'Status = \'Case Closed\''},
    //         'stage4' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L4\'', 'Status = \'Case Closed\''},
    //         'stage5' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L5\'', 'Status = \'Case Closed\''},
    //         'stage6' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L6\'', 'Status = \'Case Closed\''},
    //         'stage7' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L7\'', 'Status = \'Case Closed\''},
    //         'totalstage1rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L1\'', 'Status = \'Case Closed\''},
    //         'totalstage2rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L2\'', 'Status = \'Case Closed\''},
    //         'totalstage3rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L3\'', 'Status = \'Case Closed\''},
    //         'totalstage4rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L4\'', 'Status = \'Case Closed\''},
    //         'totalstage5rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L5\'', 'Status = \'Case Closed\''},
    //         'totalstage6rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L6\'', 'Status = \'Case Closed\''},
    //         'totalstage7rcases' => new List<String>{'ContactId != null', 'Current_Stage__c = \'CP-L7\'', 'Status = \'Case Closed\''},
    //         'unstage1' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L1\'', 'Status = \'Case Closed\''},
    //         'unstage2' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L2\'', 'Status = \'Case Closed\''},
    //         'unstage3' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L3\'', 'Status = \'Case Closed\''},
    //         'unstage4' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L4\'', 'Status = \'Case Closed\''},
    //         'unstage5' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L5\'', 'Status = \'Case Closed\''},
    //         'unstage6' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L6\'', 'Status = \'Case Closed\''},
    //         'unstage7' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L7\'', 'Status = \'Case Closed\''},
    //         'totalstage1uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L1\'', 'Status = \'Case Closed\''},
    //         'totalstage2uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L2\'', 'Status = \'Case Closed\''},
    //         'totalstage3uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L3\'', 'Status = \'Case Closed\''},
    //         'totalstage4uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L4\'', 'Status = \'Case Closed\''},
    //         'totalstage5uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L5\'', 'Status = \'Case Closed\''},
    //         'totalstage6uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L6\'', 'Status = \'Case Closed\''},
    //         'totalstage7uncases' => new List<String>{'ContactId = null', 'Current_Stage__c = \'CP-L7\'', 'Status = \'Case Closed\''},
    //         'UnRegistered' => new List<String>{'ContactId = null'},
    //         'unregisteredCases' => new List<String>{'ContactId = null'},
    //         'openunregisteredCases' => new List<String>{'ContactId = null', 'Status = \'Open\''},
    //         'closedunregisteredCases' => new List<String>{'ContactId = null', 'Status = \'Case Closed\''},
    //         'Total_Un' => new List<String>{'ContactId = null'},
    //         'totalopenunregistered' => new List<String>{'ContactId = null', 'Status = \'Open\''},
    //         'totalclosedunregistered' => new List<String>{'ContactId = null', 'Status = \'Case Closed\''},
    //         'totalopencases' => new List<String>{'Status = \'Open\''},
    //         'totalclosedcases' => new List<String>{'Status = \'Case Closed\''},
    //         'totalstage1cases' => new List<String>{'Current_Stage__c = \'CP-L1\'', 'Status = \'Case Closed\''},
    //         'totalstage2cases' => new List<String>{'Current_Stage__c = \'CP-L2\'', 'Status = \'Case Closed\''},
    //         'totalstage3cases' => new List<String>{'Current_Stage__c = \'CP-L3\'', 'Status = \'Case Closed\''},
    //         'totalstage4cases' => new List<String>{'Current_Stage__c = \'CP-L4\'', 'Status = \'Case Closed\''},
    //         'totalstage5cases' => new List<String>{'Current_Stage__c = \'CP-L5\'', 'Status = \'Case Closed\''},
    //         'totalstage6cases' => new List<String>{'Current_Stage__c = \'CP-L6\'', 'Status = \'Case Closed\''},
    //         'totalstage7cases' => new List<String>{'Current_Stage__c = \'CP-L7\'', 'Status = \'Case Closed\''}
    //     };
        
    //     for (String key : unpack.keySet()) {
    //         if (filterConditions.containsKey(key)) {
    //             conditions.addAll(filterConditions.get(key));
    //         }
    //     }

    //     if (conditions.size() > 0) {
    //         query += ' AND ' + String.join(conditions, ' AND ');
    //     }

    //     system.debug('query' + query);

    //     if (period != null) {
    //         String startDate = 'Start_Date__c = \'' + Year + '-' + Month + '-01\'';
    //         String endDate = 'End_Date__c = \'' + Year + '-' + Month + '-30\'';
    //         query += ' AND (' + startDate + ' OR ' + endDate + ')';
    //     }

    //     return Database.query(query);
    // }

    

    


    public class RegisteredProjectCaseCount {
        @AuraEnabled public String projectId { get; set; }
        @AuraEnabled public String projectName { get; set; }
        @AuraEnabled public Integer registeredCases { get; set; }
        @AuraEnabled public Integer openregisteredCases { get; set; }
        @AuraEnabled public Integer closedregisteredCases { get; set; }
        @AuraEnabled public Integer stage1 { get; set; }
        @AuraEnabled public Integer stage2 { get; set; }
        @AuraEnabled public Integer stage3 { get; set; }
        @AuraEnabled public Integer stage4 { get; set; }
        @AuraEnabled public Integer stage5 { get; set; }
        @AuraEnabled public Integer stage6 { get; set; }
        @AuraEnabled public Integer stage7 { get; set; }
        @AuraEnabled public Integer stage8 { get; set; }
        @AuraEnabled public Integer openstage1 { get; set; }
        @AuraEnabled public Integer openstage2 { get; set; }
        @AuraEnabled public Integer openstage3 { get; set; }
        @AuraEnabled public Integer openstage4 { get; set; }
        @AuraEnabled public Integer openstage5 { get; set; }
        @AuraEnabled public Integer openstage6 { get; set; }
        @AuraEnabled public Integer openstage7 { get; set; }
        @AuraEnabled public Integer openstage8 { get; set; }

        public RegisteredProjectCaseCount(String projectId, String projectName, Integer registeredCases,
        Integer openregisteredCases, Integer closedregisteredCases, Integer stage1, Integer stage2, Integer stage3,
        Integer stage4, Integer stage5, Integer stage6, Integer stage7,Integer stage8,Integer openstage1,Integer openstage2,
        Integer openstage3,Integer openstage4,Integer openstage5,Integer openstage6,Integer openstage7,Integer openstage8) {
            this.projectId = projectId;
            this.projectName = projectName;
            this.registeredCases = registeredCases;
            this.openregisteredCases = openregisteredCases;
            this.closedregisteredCases = closedregisteredCases;
            this.stage1 = stage1;
            this.stage2 = stage2;
            this.stage3 = stage3;
            this.stage4 = stage4;
            this.stage5 = stage5;
            this.stage6 = stage6;
            this.stage7 = stage7;
            this.stage8 = stage8;
            this.openstage1 = openstage1;
            this.openstage2 = openstage2;
            this.openstage3 = openstage3;
            this.openstage4 = openstage4;
            this.openstage5 = openstage5;
            this.openstage6 = openstage6;
            this.openstage7 = openstage7;
            this.openstage8 = openstage8;
        }
    }
    
    public class UnRegisteredProjectCaseCount {
        @AuraEnabled public String projectId { get; set; }
        @AuraEnabled public String projectName { get; set; }
        // @AuraEnabled public Integer totalCases { get; set; }
        @AuraEnabled public Integer unregisteredCases { get; set; }
        @AuraEnabled public Integer openunregisteredCases { get; set; }
        @AuraEnabled public Integer closedunregisteredCases { get; set; }
        @AuraEnabled public Integer stage1 { get; set; }
        @AuraEnabled public Integer stage2 { get; set; }
        @AuraEnabled public Integer stage3 { get; set; }
        @AuraEnabled public Integer stage4 { get; set; }
        @AuraEnabled public Integer stage5 { get; set; }
        @AuraEnabled public Integer stage6 { get; set; }
        @AuraEnabled public Integer stage7 { get; set; }
        @AuraEnabled public Integer stage8 { get; set; }
        @AuraEnabled public Integer openstage1 { get; set; }
        @AuraEnabled public Integer openstage2 { get; set; }
        @AuraEnabled public Integer openstage3 { get; set; }
        @AuraEnabled public Integer openstage4 { get; set; }
        @AuraEnabled public Integer openstage5 { get; set; }
        @AuraEnabled public Integer openstage6 { get; set; }
        @AuraEnabled public Integer openstage7 { get; set; }
        @AuraEnabled public Integer openstage8 { get; set; }

        public UnRegisteredProjectCaseCount(String projectId, String projectName,  Integer unregisteredCases,
         Integer openunregisteredCases, Integer closedunregisteredCases,Integer stage1,Integer stage2,Integer stage3,
         Integer stage4,Integer stage5,Integer stage6,Integer stage7,Integer stage8,Integer openstage1,Integer openstage2,
         Integer openstage3,Integer openstage4,Integer openstage5,Integer openstage6,Integer openstage7,Integer openstage8

         ) {
            this.projectId = projectId;
            this.projectName = projectName;
            // this.totalCases = totalCases;
            this.unregisteredCases = unregisteredCases;
            this.openunregisteredCases = openunregisteredCases;
            this.closedunregisteredCases = closedunregisteredCases;
            this.stage1 = stage1;
            this.stage2 = stage2;
            this.stage3 = stage3;
            this.stage4 = stage4;
            this.stage5 = stage5;
            this.stage6 = stage6;
            this.stage7 = stage7;
            this.stage8 = stage8;
            this.openstage1 = openstage1;
            this.openstage2 = openstage2;
            this.openstage3 = openstage3;
            this.openstage4 = openstage4;
            this.openstage5 = openstage5;
            this.openstage6 = openstage6;
            this.openstage7 = openstage7;
            this.openstage8 = openstage8;
        }
    }
    
    public class CaseWrapper {
        @AuraEnabled
        public String month { get; set; }
        @AuraEnabled
        public String year { get; set; }
        @AuraEnabled
        public Integer registeredCases { get; set; }
        @AuraEnabled
        public Integer unregisteredCases { get; set; }
        @AuraEnabled
        public Integer openCases { get; set; }
        @AuraEnabled
        public Integer closedCases { get; set; }
        @AuraEnabled
        public Integer stage1Cases { get; set; }
        @AuraEnabled
        public Integer stage2Cases { get; set; }
        @AuraEnabled
        public Integer stage3Cases { get; set; }
        @AuraEnabled
        public Integer stage4Cases { get; set; }
        @AuraEnabled
        public Integer stage5Cases { get; set; }
        @AuraEnabled
        public Integer stage6Cases { get; set; }
        @AuraEnabled
        public Integer stage7Cases { get; set; }
        @AuraEnabled
        public Integer stage8Cases { get; set; }
        

        public CaseWrapper(String month, String year, Integer registeredCases, Integer unregisteredCases,Integer openCases,
        Integer closedCases,Integer stage1Cases,Integer stage2Cases,Integer stage3Cases,Integer stage4Cases,
        Integer stage5Cases,Integer stage6Cases,Integer stage7Cases,Integer stage8Cases){
            this.month = month;
            this.year = year;
            this.registeredCases = registeredCases;
            this.unregisteredCases = unregisteredCases;
            this.closedCases = closedCases;
            this.openCases = openCases;
            this.stage1Cases = stage1Cases;
            this.stage2Cases = stage2Cases;
            this.stage3Cases = stage3Cases;
            this.stage4Cases = stage4Cases;
            this.stage5Cases = stage5Cases;
            this.stage6Cases = stage6Cases;
            this.stage7Cases = stage7Cases;
            this.stage8Cases = stage8Cases;
        }
    }
    
    
    public class totalCaseCount {        
        @AuraEnabled public Integer totalCases { get; set; }
        @AuraEnabled public Integer totalOpenCases { get; set; }
        @AuraEnabled public Integer totalClosedCases { get; set; }
        @AuraEnabled public Integer totalStage1Cases { get; set; }
        @AuraEnabled public Integer totalStage2Cases { get; set; }
        @AuraEnabled public Integer totalStage3Cases { get; set; }
        @AuraEnabled public Integer totalStage4Cases { get; set; }
        @AuraEnabled public Integer totalStage5Cases { get; set; }
        @AuraEnabled public Integer totalStage6Cases { get; set; }
        @AuraEnabled public Integer totalStage7Cases { get; set; }
        @AuraEnabled public Integer totalStage8Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage1Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage2Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage3Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage4Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage5Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage6Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage7Cases { get; set; }
        @AuraEnabled public Integer totalOpenStage8Cases { get; set; }

        public totalCaseCount(Integer totalCases,Integer totalOpenCases,Integer totalClosedCases,Integer totalStage1Cases,
         Integer totalStage2Cases, Integer totalStage3Cases, Integer totalStage4Cases, Integer totalStage5Cases, 
         Integer totalStage6Cases,Integer totalStage7Cases,Integer totalStage8Cases, Integer totalOpenStage1Cases,
         Integer totalOpenStage2Cases, Integer totalOpenStage3Cases,Integer totalOpenStage4Cases,Integer totalOpenStage5Cases,
         Integer totalOpenStage6Cases,Integer totalOpenStage7Cases,Integer totalOpenStage8Cases) {
            this.totalCases = totalCases;
            this.totalOpenCases = totalOpenCases;
            this.totalClosedCases = totalClosedCases;
            this.totalStage1Cases = totalStage1Cases;
            this.totalStage2Cases = totalStage2Cases;
            this.totalStage3Cases = totalStage3Cases;
            this.totalStage4Cases = totalStage4Cases;
            this.totalStage5Cases = totalStage5Cases;
            this.totalStage6Cases = totalStage6Cases;
            this.totalStage7Cases = totalStage7Cases;
            this.totalStage8Cases = totalStage8Cases;
            this.totalOpenStage1Cases = totalOpenStage1Cases;
            this.totalOpenStage2Cases = totalOpenStage2Cases;
            this.totalOpenStage3Cases = totalOpenStage3Cases;
            this.totalOpenStage4Cases = totalOpenStage4Cases;
            this.totalOpenStage5Cases = totalOpenStage5Cases;
            this.totalOpenStage6Cases = totalOpenStage6Cases;
            this.totalOpenStage7Cases = totalOpenStage7Cases;
            this.totalOpenStage8Cases = totalOpenStage8Cases;
        }
    }
    
    
    

}