@RestResource(urlMapping='/anarockCp/*')
global class AnarockLeadCpCreation {
	
    @HttpPost
    global static String doPost(){
        
        RestRequest req = RestContext.request;
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        LeadCpData data = (LeadCpData)JSON.deserialize(jsonBody, LeadCpData.class);
        
        System.debug('data: ' + data);
        System.debug('lead name: ' + data.leadData.name);
        System.debug('cp name: ' + data.cpData.name);
        
        List<Broker__c> cpList = [SELECT Id FROM Broker__c WHERE Name =: data.cpData.name AND RW_Mobile_No__c =: data.cpData.mobile];
        List<Temp_Channel_Partner__c> tempCpList = [SELECT Id FROM Temp_Channel_Partner__c WHERE Name =: data.cpData.name AND Mobile_No__c =: data.cpData.mobile];
        
        Lead ld = new Lead();
        if(cpList.size() > 0){
            //Lead ld = new Lead();
            ld.LastName = data.leadData.name;
            ld.RW_Mobile_No__c = data.leadData.mobile;
            ld.Email = data.leadData.email;
            ld.RW_Project__c = (data.leadData.projectId != '')? data.leadData.projectId : null;
            ld.LeadSource = 'Channel Partner';
            ld.RW_Broker__c = cpList[0].Id;
            ld.Anarock_Portal__c = true;
            //insert ld;
            //return ld.Id;
        }else if(tempCpList.size() > 0){
			//Lead ld = new Lead();
            ld.LastName = data.leadData.name;
            ld.RW_Mobile_No__c = data.leadData.mobile;
            ld.Email = data.leadData.email;
            ld.RW_Project__c = (data.leadData.projectId != '')? data.leadData.projectId : null;
            ld.Lead_Source__c = 'Temp Channel Partner';
            ld.LeadSource = 'Temp Channel Partner';
            ld.Temp_Channel_Partner__c = tempCpList[0].Id;
            ld.Anarock_Portal__c = true;
            //insert ld; 
            //return ld.Id;
        }else{
            Temp_Channel_Partner__c tempCp = new Temp_Channel_Partner__c();
            tempCp.Name = data.cpData.name;
            tempCp.Mobile_No__c = data.cpData.mobile;
            tempCp.Generated_From_Anarock__c = true;
            tempCp.Email__c = data.cpData.email;
            tempCp.PAN_No__c = data.cpData.pan;
            tempCp.State__c = data.cpData.state;
            insert tempCp;
            
			//Lead ld = new Lead();
            ld.LastName = data.leadData.name;
            ld.RW_Mobile_No__c = data.leadData.mobile;
            ld.Email = data.leadData.email;
            ld.RW_Project__c = (data.leadData.projectId != '')? data.leadData.projectId : null;
            ld.Lead_Source__c = 'Temp Channel Partner';
            ld.LeadSource = 'Temp Channel Partner';
            ld.Temp_Channel_Partner__c = tempCp.Id;
            ld.Anarock_Portal__c = true;
            //insert ld;  
            //return ld.Id;
        }
        if(String.isBlank(ld.RW_Project__c)){  //Added by Vinay 28-08-2025
            ERP_Integration_Log__c log = new ERP_Integration_Log__c();
            log.request__c = 'RW_Mobile_No__c: ' +  ld.RW_Mobile_No__c + ', Email: ' + ld.Email + ', Name: ' + ld.LastName + ', LeadSource: ' + ld.LeadSource;
            log.API_name__c = 'Lead Creation Error';
            log.response__c = 'Project is missing';
            log.Status__c='Failure';
            log.Error_Type__c='Data Error';
            log.Error_Reason__c = 'Project is missing';
            insert log;
            
            return 'Please select the Project';
        }
        try{
            List <DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(new List<Lead>{ld}, 'WEB');
            System.debug('dupList: ' + dupList);
            if(dupList.isEmpty()){
                Database.saveResult[] srList = Database.insert(new List<Lead>{ld}, true);
                return srList[0].getId();
            }
        }catch(exception e){
            return e.getMessage();
        }
        
        /*try{
            List <DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(new List<Lead>{ld}, 'WEB');
            System.debug('dupList: ' + dupList);
            Map <Id, Task> whoIdMap = new Map <Id, Task>();
            if(dupList.isEmpty()){
                Database.saveResult[] srList = Database.insert(new List<Lead>{ld}, true);
                for(Database.SaveResult sr: srList){
                    if(sr.isSuccess()){
                        System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                        try {
                            Map <Id, Lead> enquiryMap = new Map <Id, Lead>();
                            enquiryMap.put(sr.getId(), ld);
                            whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                            System.debug('whoIdMap: ' + whoIdMap);
                        } catch (Exception ex) {
                            System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                        }
                    }else{
                        for(Database.Error err: sr.getErrors()){
                            System.debug('Error: ' + err.getMessage());
                        }                    
                    }
                }
                return srList[0].getId();
            }
        }catch(exception e){
            return e.getMessage();
        }*/
        return 'Task created successfully';
    }
    
    public class LeadCpData{
        public LeadData leadData;
        public CpData cpData;
    }
    
    public class LeadData{
        public String name;
        public String mobile;
        public String projectId;
        public String email;
    }
    public class CpData{
        public String name;
        public String mobile;
        public String email;
        public String state;
        public String pan;
    }
}