@RestResource(urlMapping='/ActiveProjectDetails/*')
global with sharing class ProjectInfoService {

    @HttpGet
    global static void getActiveProjects() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        try {
            List<Project__c> activeProjects = [
                SELECT Name, CP_Helpdesk_1_Contact__c, CP_Helpdesk_2_Contact__c
                FROM Project__c 
                WHERE RW_Status__c = 'Active'
            ];

            // Use Map<String, Object> for the top-level structure
            Map<String, Object> responseMap = new Map<String, Object>();

            for (Project__c proj : activeProjects) {
                // Nested map holds the specific fields for each project
                Map<String, String> details = new Map<String, String>();
                details.put('CP_Helpdesk_1_Contact__c', proj.CP_Helpdesk_1_Contact__c);
                details.put('CP_Helpdesk_2_Contact__c', proj.CP_Helpdesk_2_Contact__c);
                
                // Adding to the Object map using Project Name as the key
                responseMap.put(proj.Name, details);
            }

            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            res.statusCode = 200;

        } catch (Exception e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{
                'error' => e.getMessage()
            }));
            res.statusCode = 500;
        }
    }
}