global class GetCurrentLoggedInAgents {
    
    
    //@future(callout=true)
    @InvocableMethod
    public static void getAgentsDetailsForBatch(List<Id> leadIds){
        
        if(System.label.Project_Wise_Auto_Callback == 'Yes'){
            getAgentsDetails(leadIds);
        }else{
        System.debug('getAgentsDetailsForBatch: ');
        
        System.debug('leadIds: ' + leadIds);
        List<Lead> leads = [SELECT Id, Name, OwnerId, RW_Mobile_No__c, Integration_Source__c,RW_Project__c,RW_Project__r.Name,LeadSource,LastName,
                            Email,Country__c,RDS_Country_Code__c,RW_Lead_Sub_Source__c,RW_Budget__c,Description,Banner_Type__c,
                            CTA_Source__c,web_banner_size__c,IP_address_web2lead__c,RW_Configuration__c,Is_Anarock_Lead__c,UTM_Campaign__c,
                            Ad_Group__c,UTM_Medium__c,UTM_Source__c,Placement__c,Device__c,Gclid__c,RW_Unregistered_Broker_Name__c,
                            Walkin_Unregistered_ChannelPartner_Name__c FROM Lead WHERE Id =: leadIds];
        List<String> presalesIds = System.label.Task_Assignment_Users.split(',');
        Map<Id,User> presalesUsers = new Map<Id,User>([SELECT Id, CTI_Agent_ID__c FROM User WHERE Id =: presalesIds]);
        String apiKey = System.label.Ozonetel_API_Key;
        String userName = System.label.Ozonetel_User_Name;
        List<Lead> leadsToUpdate = new List<Lead>();
        
        String endpoint = 'https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/getAgentLogins?api_key=' + apiKey + '&username=' + userName + '&format=json';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(60000);
        Http http = new Http();
        String respBody;
        if(!Test.isRunningTest()){
            HTTPResponse response = http.send(req);
            respBody = response.getBody();
        }else{
            respBody = '{"status":"success","message":[{"AgentId":"Pallavi_Priya","AgentName":"Pallavi Priya","PhoneNumber":"22355","AgentState":"READY","SkillName":"Garden_CRM, Garden_CRM_BOOKINGS, Garden_CRM_COMPLAINTS, Garden_CRM_DEMAND, Garden_CRM_LOAN, Garden_CRM_PAYMENTS, Garden_CRM_POSSESSION, Garden_CRM_REGISTRATION, Garden_CRM_RM"}]}';
        }
        
        System.debug('respBody: ' + respBody);
        //Response res = (Response) JSON.deserialize(respBody, Response.class);
        Response res = new Response();
        if(!respBody.contains('no record found')){
            res = (Response) JSON.deserialize(respBody, Response.class);
        }
        
        if(res.status == 'success'){
            
            List<String> agents = new List<String>(); 
            for(AgentDetails ag : res.message){
                if(ag.AgentState == 'READY'){
                    agents.add(ag.AgentId.toLowercase());
                }
            }
            System.debug('agents: ' + agents);
            
            
            Datetime dt = Date.today();
            Set<String> loggedInUsers = new Set<String>();
            //try{
            List<AggregateResult> auth = [SELECT UsersId FROM AuthSession WHERE  LoginType = 'Application' AND SessionType = 'UI' GROUP BY UsersId];
            for(AggregateResult au : auth){
                loggedInUsers.add(String.valueOf(au.get('UsersId'))); 
            }
            String[] presalesUsrIds = Label.Task_Assignment_Users.split(',');
            List<String> availableUsers = new List<String>();
            for(String st : presalesUsrIds){
                if(loggedInUsers.contains(st)){
                    availableUsers.add(st);
                }
            }
            System.debug('availableUsers: ' + availableUsers);
            //if(availableUsers.size() > 0 || Test.isRunningtest()){
            List<String> availableUsersFinal = new List<String>();
            for(String usr : availableUsers){
                if(agents.contains(presalesUsers.get(usr).CTI_Agent_ID__c.toLowercase())){
                    availableUsersFinal.add(usr);
                }
            }
            System.debug('availableUsersFinal: ' + availableUsersFinal);
            List<Id> loggedInUserIds = new List<Id>();
            String owner;
            List<Lead> leadList = [SELECT Id, OwnerId, RW_Mobile_No__c FROM Lead WHERE LeadSource = 'Digital' AND CreatedDate >: dt ORDER BY CreatedDate ASC];
            List<String> leadIMobileNums = new List<String>();
            List<String> allLeadIds = new List<String>();
            for(Lead ld : leadList){
                leadIMobileNums.add(ld.RW_Mobile_No__c);
                allLeadIds.add(ld.Id);
            }
            
            for(Lead ld: leads){
                System.debug('--: ' + ld.RW_Mobile_No__c);
                System.debug('--: ' + ld.Id);
                System.debug('--: ' + leadIMobileNums);
                System.debug('--: ' + leadIds.indexOf(ld.Id));
                //Integer currentLeadIdIndex = leadList.size() + leads.indexOf(ld);
                Integer currentLeadIdIndex = allLeadIds.indexOf(ld.Id);
                System.debug('--: ' + currentLeadIdIndex);
                if(availableUsersFinal.size() > 0 && currentLeadIdIndex >= 0){ //Added "currentLeadIdIndex >= 0" by Vinay 25-08-205
                    Integer rr = math.mod(currentLeadIdIndex, availableUsersFinal.size());
                    owner= availableUsersFinal[rr];
                    System.debug('--owner: ' + owner);
                }else{
                    String defaultUserId = Label.Presales_Default_User;
                    owner = defaultUserId;
                    System.debug('--owner: ' + owner);
                }
                if(!presalesUsrIds.contains(ld.OwnerId)){
                    ld.OwnerId = owner;
                    System.debug('--owner: ' + owner);
                }
                leadsToUpdate.add(ld);
            }
        }else if(res.status == 'failure'){
            for(Lead ld: leads){
                ld.OwnerId = Label.Presales_Default_User;
                leadsToUpdate.add(ld);
            }
        }
        if(leadsToUpdate.size() > 0){
            update leadsToUpdate;
            sendCustomNotification(leadsToUpdate);
            List<Scheduled_Call__c> schedulesToCreate = new List<Scheduled_Call__c>(); //Added by Vinay 14-08-2025
            Map<Id, Lead> leadMap = new map<Id, Lead>(); //Added by Vinay 26-09-2025
            //if(System.label.Auto_Callback_Projects != 'null'){
                //List<String> autoCallbackProjects = System.label.Auto_Callback_Projects.split(',');
                //if(autoCallbackProjects.size() > 0){
                    for(Lead ld : leadsToUpdate){ //Added by Vinay 14-08-2025
                        //if(ld.Integration_Source__c == 'Website' && ld.RW_Project__c != null && autoCallbackProjects.contains(ld.RW_Project__c)){
                        if(ld.Integration_Source__c == 'Website' && System.label.Allow_Auto_Callback == 'Yes'){
                            Scheduled_Call__c sc = new Scheduled_Call__c();
                            sc.Related_Record_Id__c = ld.Id;
                            sc.Schedule_Date__c = Datetime.now().addSeconds(10);
                            sc.Agent_Id__c = presalesUsers.get(ld.OwnerId).CTI_Agent_ID__c;
                            sc.Lead__c = ld.Id;
                            sc.Related_To__c = 'Lead';
                            schedulesToCreate.add(sc);
                        }
                        if(ld.Integration_Source__c == 'Website'){ //Added by Vinay 26-09-2025
                            leadMap.put(ld.Id, ld);
                        }
                    }
                    insert schedulesToCreate;
                    if(leadMap.keySet().size() > 0){ //Added by Vinay 26-09-2025
                        TaskManagementServices.createTaskforEnquiries(leadMap);
                    }
                //}
            //}
            
            
        }
        //}catch(Exception e){
        //    throw new CommonException('There was an error -'+e.getMessage());
        //}
        }
    }
    
    
    public static void getAgentsDetails(List<Id> leadIds){
        List<Lead> leads = [SELECT Id, Name, OwnerId, RW_Mobile_No__c, Integration_Source__c,RW_Project__c,RW_Project__r.Name,LeadSource,LastName,
                            Email,Country__c,RDS_Country_Code__c,RW_Lead_Sub_Source__c,RW_Budget__c,Description,Banner_Type__c,
                            CTA_Source__c,web_banner_size__c,IP_address_web2lead__c,RW_Configuration__c,Is_Anarock_Lead__c,UTM_Campaign__c,
                            Ad_Group__c,UTM_Medium__c,UTM_Source__c,Placement__c,Device__c,Gclid__c,RW_Unregistered_Broker_Name__c,
                            Walkin_Unregistered_ChannelPartner_Name__c FROM Lead WHERE Id =: leadIds];
        List<String> presalesIds = System.label.Task_Assignment_Users.split(',');
        Map<Id,User> presalesUsers = new Map<Id,User>([SELECT Id, CTI_Agent_ID__c FROM User WHERE Id =: presalesIds]);
        String apiKey = System.label.Ozonetel_API_Key;
        String userName = System.label.Ozonetel_User_Name;
        List<Lead> leadsToUpdate = new List<Lead>();
        
        String endpoint = 'https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/getAgentLogins?api_key=' + apiKey + '&username=' + userName + '&format=json';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setTimeout(60000);
        Http http = new Http();
        String respBody;
        if(!Test.isRunningTest()){
            HTTPResponse response = http.send(req);
            respBody = response.getBody();
        }else{
            respBody = '{"status":"success","message":[{"AgentId":"Pallavi_Priya","AgentName":"Pallavi Priya","PhoneNumber":"22355","AgentState":"READY","SkillName":"Garden_CRM, Garden_CRM_BOOKINGS, Garden_CRM_COMPLAINTS, Garden_CRM_DEMAND, Garden_CRM_LOAN, Garden_CRM_PAYMENTS, Garden_CRM_POSSESSION, Garden_CRM_REGISTRATION, Garden_CRM_RM"}]}';
        }
        
        System.debug('respBody: ' + respBody);
        //Response res = (Response) JSON.deserialize(respBody, Response.class);
        Response res = new Response();
        if(!respBody.contains('no record found')){
            res = (Response) JSON.deserialize(respBody, Response.class);
        }
        
        List<String> agentsInOzonetel = new List<String>(); 
        if(res.status == 'success'){
            for(AgentDetails ag : res.message){
                if(ag.AgentState == 'READY'){
                    agentsInOzonetel.add(ag.AgentId.toLowercase());
                }
            }
        }
        
        
        Datetime dt = Date.today();
        Set<String> agentsInSfdc = new Set<String>();
        //try{
        List<AggregateResult> auth = [SELECT UsersId FROM AuthSession WHERE  LoginType = 'Application' AND SessionType = 'UI' GROUP BY UsersId];
        for(AggregateResult au : auth){
            agentsInSfdc.add(String.valueOf(au.get('UsersId'))); 
        }

        Map<Id,User> sfdcLoginUsers = new Map<Id,User>([SELECT Id,CTI_Agent_ID__c FROM User WHERE Id =: agentsInSfdc]);
        
        Map<String, Auto_Call_Back_Users__c> autoCallbackUsersMap = Auto_Call_Back_Users__c.getall();
        List<String> callBackUsers = new List<String>();
        Map<String, List<String>> projectVsActivePrimaryUsers = new Map<String, List<String>>();
        Map<String, List<String>> projectVsActiveSecondaryUsers = new Map<String, List<String>>();
        for(String proj : autoCallbackUsersMap.keySet()){
            if(autoCallbackUsersMap.get(proj).Active__c){
                List<String> primaryUsers = autoCallbackUsersMap.get(proj).Primary_User_Ids__c.split(',');
                List<String> activePrimary = new List<String>();
                for(String primaryUser : primaryUsers){
                    if(agentsInSfdc.contains(primaryUser) && agentsInOzonetel.contains(sfdcLoginUsers.get(primaryUser).CTI_Agent_ID__c.toLowercase())){
                        activePrimary.add(primaryUser);
                    }
                }
                projectVsActivePrimaryUsers.put(proj,activePrimary);
                
                List<String> secondaryUsers = autoCallbackUsersMap.get(proj).Secondary_User_Ids__c.split(',');
                List<String> activeSecondary = new List<String>();
                for(String secondaryUser : secondaryUsers){
                    if(agentsInSfdc.contains(secondaryUser) && agentsInOzonetel.contains(sfdcLoginUsers.get(secondaryUser).CTI_Agent_ID__c.toLowercase())){
                        activeSecondary.add(secondaryUser);
                    }
                }
                projectVsActiveSecondaryUsers.put(proj,activeSecondary);
            }
        }
        List<String> activePresalesUsers = new List<String>();
        for(String presalesUser : presalesIds){
            if(agentsInSfdc.contains(presalesUser) && agentsInOzonetel.contains(sfdcLoginUsers.get(presalesUser).CTI_Agent_ID__c.toLowercase())){
                activePresalesUsers.add(presalesUser);
            }
        }
        
        List<Lead> leadList = [SELECT Id,OwnerId,RW_Mobile_No__c,RW_Project__r.Name FROM Lead WHERE LeadSource = 'Digital' AND CreatedDate >: dt ORDER BY CreatedDate ASC];
        Map<String, List<String>> projVsLeadMap = new Map<String, List<String>>();
        projVsLeadMap.put('General', new List<String>{});
        for(Lead ld : leadList){
            if(autoCallbackUsersMap.containsKey(ld.RW_Project__r.Name)){
                if(projVsLeadMap.get(ld.RW_Project__r.Name) != null){
                    projVsLeadMap.get(ld.RW_Project__r.Name).add(ld.Id);
                }else{
                    projVsLeadMap.put(ld.RW_Project__r.Name, new List<String>{ld.Id});
                }
            }else{
                projVsLeadMap.get('General').add(ld.Id);
            }
        }
        for(Lead l : leads){
            String owner;
            if(autoCallbackUsersMap.containsKey(l.RW_Project__r.Name) && autoCallbackUsersMap.get(l.RW_Project__r.Name).Active__c){
                Integer currentLeadIdIndex = projVsLeadMap.get(l.RW_Project__r.Name).indexOf(l.Id);
                if(projectVsActivePrimaryUsers.get(l.RW_Project__r.Name).size() > 0){
                    Integer rr = math.mod(currentLeadIdIndex, projectVsActivePrimaryUsers.get(l.RW_Project__r.Name).size());
                	owner= projectVsActivePrimaryUsers.get(l.RW_Project__r.Name)[rr];
                }else if(projectVsActiveSecondaryUsers.get(l.RW_Project__r.Name).size() > 0){
                    Integer rr = math.mod(currentLeadIdIndex, projectVsActiveSecondaryUsers.get(l.RW_Project__r.Name).size());
                	owner= projectVsActiveSecondaryUsers.get(l.RW_Project__r.Name)[rr];
                }else{
                    String defaultUserId = Label.Presales_Default_User;
                    owner = defaultUserId;
                }
            }else if(activePresalesUsers.size() > 0){
                //Integer currentLeadIdIndex = projVsLeadMap.get('General').indexOf(l.Id);
                Integer currentLeadIdIndex = 0;
                if(projVsLeadMap.get('General').size() > 0){
                    currentLeadIdIndex = projVsLeadMap.get('General').indexOf(l.Id);
                }
                Integer rr = math.mod(currentLeadIdIndex, activePresalesUsers.size());
                owner= activePresalesUsers[rr];
            }else{
                owner = Label.Presales_Default_User;
            }
            l.OwnerId = owner;
            leadsToUpdate.add(l);
        }
        if(leadsToUpdate.size() > 0){
            update leadsToUpdate;
            sendCustomNotification(leadsToUpdate);
            List<Scheduled_Call__c> schedulesToCreate = new List<Scheduled_Call__c>(); //Added by Vinay 14-08-2025
            Map<Id, Lead> leadMap = new Map<Id, Lead>(); //Added by Vinay 26-09-2025
            //if(System.label.Auto_Callback_Projects != 'null'){
                //List<String> autoCallbackProjects = System.label.Auto_Callback_Projects.split(',');
                //if(autoCallbackProjects.size() > 0){
                    for(Lead ld : leadsToUpdate){ //Added by Vinay 14-08-2025
                        if(ld.Integration_Source__c == 'Website' && ld.RW_Project__c != null && autoCallbackUsersMap.containsKey(ld.RW_Project__r.Name)){
                            Scheduled_Call__c sc = new Scheduled_Call__c();
                            sc.Related_Record_Id__c = ld.Id;
                            sc.Schedule_Date__c = Datetime.now().addSeconds(10);
                            sc.Agent_Id__c = (sfdcLoginUsers.get(ld.OwnerId) != null)? sfdcLoginUsers.get(ld.OwnerId).CTI_Agent_ID__c : null;
                            sc.Lead__c = ld.Id;
                            sc.Related_To__c = 'Lead';
                            schedulesToCreate.add(sc);
                        }
                        if(ld.Integration_Source__c == 'Website'){ //Added by Vinay 26-09-2025
                            leadMap.put(ld.Id, ld);
                        }
                    }
                    insert schedulesToCreate;
                    if(leadMap.keySet().size() > 0){ //Added by Vinay 26-09-2025
                        TaskManagementServices.createTaskforEnquiries(leadMap);
                    }
                //}
            //}
            
            
        }
    }
    
    /*@future(callout=true)
    public static void getAgentsDetails(List<Id> leadIds){
        
        System.debug('leadIds: ' + leadIds);
        List<Lead> leads = [SELECT Id, Name, OwnerId, RW_Mobile_No__c FROM Lead WHERE Id =: leadIds];
        List<String> presalesIds = System.label.Task_Assignment_Users.split(',');
        Map<Id,User> presalesUsers = new Map<Id,User>([SELECT Id, CTI_Agent_ID__c FROM User WHERE Id =: presalesIds]);
        String apiKey = System.label.Ozonetel_API_Key;
        String userName = System.label.Ozonetel_User_Name;
        
        String endpoint = 'https://in1-ccaas-api.ozonetel.com/cloudAgentRestAPI/index.php/CloudAgent/CloudAgentAPI/getAgentLogins?api_key=' + apiKey + '&username=' + userName + '&format=json';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        String respBody;
        if(!Test.isRunningTest()){
            HTTPResponse response = http.send(req);
            respBody = response.getBody();
        }else{
            respBody = '{"status":"success","message":[{"AgentId":"Pallavi_Priya","AgentName":"Pallavi Priya","PhoneNumber":"22355","AgentState":"ACW","SkillName":"Garden_CRM, Garden_CRM_BOOKINGS, Garden_CRM_COMPLAINTS, Garden_CRM_DEMAND, Garden_CRM_LOAN, Garden_CRM_PAYMENTS, Garden_CRM_POSSESSION, Garden_CRM_REGISTRATION, Garden_CRM_RM"}]}';
        }
        
        
        System.debug('respBody: ' + respBody);
        Response res = (Response) JSON.deserialize(respBody, Response.class);
        
        List<String> agents = new List<String>(); 
        for(AgentDetails ag : res.message){
            if(ag.AgentState == 'READY'){
                agents.add(ag.AgentId);
            }
        }
        System.debug('agents: ' + agents);
        
        
        Datetime dt = Date.today();
        Set<String> loggedInUsers = new Set<String>();
        //try{
        List<AggregateResult> auth = [SELECT UsersId FROM AuthSession WHERE  LoginType = 'Application' AND SessionType = 'UI' GROUP BY UsersId];
        for(AggregateResult au : auth){
            loggedInUsers.add(String.valueOf(au.get('UsersId'))); 
        }
        String[] presalesUsrIds = Label.Task_Assignment_Users.split(',');
        List<String> availableUsers = new List<String>();
        for(String st : presalesUsrIds){
            if(loggedInUsers.contains(st)){
                availableUsers.add(st);
            }
        }
        System.debug('availableUsers: ' + availableUsers);
        //if(availableUsers.size() > 0 || Test.isRunningtest()){
        List<String> availableUsersFinal = new List<String>();
        for(String usr : availableUsers){
            if(agents.contains(presalesUsers.get(usr).CTI_Agent_ID__c)){
                availableUsersFinal.add(usr);
            }
        }
        System.debug('availableUsersFinal: ' + availableUsersFinal);
        List<Id> loggedInUserIds = new List<Id>();
        String owner;
        List<Lead> leadList = [SELECT Id, OwnerId, RW_Mobile_No__c FROM Lead WHERE LeadSource = 'Digital' AND CreatedDate >: dt ORDER BY CreatedDate ASC];
        List<String> leadIMobileNums = new List<String>();
        for(Lead ld : leadList){
            leadIMobileNums.add(ld.RW_Mobile_No__c);
        }
        List<Lead> leadsToUpdate = new List<Lead>();
        for(Lead ld: leads){
            System.debug('--: ' + ld.RW_Mobile_No__c);
            System.debug('--: ' + ld.Id);
            System.debug('--: ' + leadIMobileNums);
            System.debug('--: ' + leadIMobileNums.indexOf(ld.RW_Mobile_No__c));
            Integer currentTskIdIndex = leadList.size() + 1;
            if(availableUsersFinal.size() > 0){
                Integer rr = math.mod(currentTskIdIndex, availableUsersFinal.size());
                owner= availableUsersFinal[rr];
                System.debug('--owner: ' + owner);
            }else{
                String defaultUserId = Label.Presales_Default_User;
                owner = defaultUserId;
                System.debug('--owner: ' + owner);
            }
            if(!presalesUsrIds.contains(ld.OwnerId)){
                ld.OwnerId = owner;
                System.debug('--owner: ' + owner);
            }
            leadsToUpdate.add(ld);
        }
        if(leadsToUpdate.size() > 0){
            update leadsToUpdate;
            sendCustomNotification(leadsToUpdate);
        }
        //}catch(Exception e){
        //    throw new CommonException('There was an error -'+e.getMessage());
        //}
    }*/
    
    public static void sendCustomNotification(List<Lead> leads){
        
        for(Lead ld : leads){
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                       WHERE DeveloperName='Presales_Lead_Assignment'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('A new Lead assigned to you');
            notification.setBody(ld.Name);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(ld.Id);
            notification.send(new Set<String>{ld.OwnerId});
        }
    }
    
    global class Response{
        public String status;
        public List<AgentDetails> message;
    }
    
    global class Message{
        public List<AgentDetails> agentDetails;
    }
    
    public class AgentDetails{
        public String AgentId;
        public String AgentName;
        public String PhoneNumber;
        public String AgentState;
        public String SkillName;
    }
    
}