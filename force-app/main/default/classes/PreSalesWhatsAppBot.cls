@RestResource(urlMapping='/preSalesBot/*')
global without sharing class PreSalesWhatsAppBot {
  
    @HttpGet
    global static Data doGet(){
        Data data = new Data();
        data.aboutUsText = System.Label.About_Us;
        data.aboutUsImage = System.Label.About_Us_Image_Link;
        List<ProjectDetails> projDetails = new List<ProjectDetails>();
        List<Project__c> projects = [SELECT Id, Name, WhatsApp_Bot_Locality__c, Project_Property_Type__c, WhatsApp_Bot_Configuration__c, 
                                     WhatsApp_Bot_Key_Highlights__c, RW_Project_Location_Videos_Link__c,
                                     WhatsApp_Bot_Project_Amenities__c, RW_Floor_Plans__c, RW_Project_Brochure_PublicUrl__c, Site_Address_Map_Link__c,
                                     WhatsApp_Bot_Unit_Plan_Price__c, WhatsApp_Bot_Unit_Plan_Price_Text__c, RW_Project_Brochure_ID__c, 
                                     WhatsApp_Bot_Project_Image_File_Id__c, Floor_Plans_File_Id__c, WhatsApp_Bot_Project_Brochure_Url__c,
                                     WhatsApp_Bot_Unit_Plan_Price_File_Id__c
                                     FROM Project__c WHERE RW_Status__c = 'Active' AND Haptik_Bot_Active__c = true];
        List<String> docIds = new List<String>();
        for(Project__c proj : projects){
            docIds.add(proj.Floor_Plans_File_Id__c);
            docIds.add(proj.WhatsApp_Bot_Project_Image_File_Id__c);
            docIds.add(proj.WhatsApp_Bot_Unit_Plan_Price_File_Id__c);
        }
        
        List<ContentDistribution> distList = [SELECT Id, DistributionPublicUrl, ContentDownloadUrl, ContentVersionId, ContentDocumentId 
                                                    FROM ContentDistribution WHERE ContentDocumentId IN: docIds];
        
        Map<String,String> urlMap = new Map<String,String>();
        for(ContentDistribution dist : distList){
            String finalUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/sfc/dist/version/renditionDownload?rendition=THUMB720BY480&versionId=';
            finalUrl += dist.ContentVersionId + '&operationContext=DELIVERY&contentID=';
            finalUrl += dist.ContentDocumentId;
            String publicUrl = dist.DistributionPublicUrl;
            publicUrl = !String.isEmpty(publicUrl) ? publicUrl.split('/a') [publicUrl.split('/a').size() - 1] : '';
            finalUrl += '&page=0&d=/a' + publicUrl + '&oid=' + UserInfo.getOrganizationId();
            finalUrl += '&filename.png';
            urlMap.put(dist.ContentDocumentId, finalUrl);
        }
        
        System.debug('urlMap: ' + urlMap);
        
        /*String finalUrl = System.Url.getOrgDomainUrl().toExternalForm() + '/sfc/dist/version/renditionDownload?rendition=THUMB720BY480&versionId=';
        finalUrl += distList[0].ContentVersionId + '&operationContext=DELIVERY&contentID=';
        finalUrl += distList[0].ContentDocumentId;
        String publicUrl = distList[0].DistributionPublicUrl;
        publicUrl = !String.isEmpty(publicUrl) ? publicUrl.split('/a') [publicUrl.split('/a').size() - 1] : '';
        finalUrl += '&page=0&d=/a' + publicUrl + '&oid=' + UserInfo.getOrganizationId();
        finalUrl += '&filename.pdf';*/
        
        
        for(Project__c proj : projects){
            ProjectDetails projDet = new ProjectDetails();
            projDet.projectId = proj.Id;
            projDet.projectName = proj.Name;
            /*if(proj.WhatsApp_Bot_Project_Image_Public_URL__c != null && proj.WhatsApp_Bot_Project_Image_Public_URL__c != ''){
                projDet.projectImage = proj.WhatsApp_Bot_Project_Image_Public_URL__c;
            }else{
                projDet.projectImage = urlMap.get(proj.WhatsApp_Bot_Project_Image_File_Id__c);
            }*/
            projDet.projectImage = urlMap.get(proj.WhatsApp_Bot_Project_Image_File_Id__c);
            projDet.keyHighlights = proj.WhatsApp_Bot_Key_Highlights__c;
            projDet.projectVideoTour = proj.RW_Project_Location_Videos_Link__c;
            projDet.projectAmenities = proj.WhatsApp_Bot_Project_Amenities__c;
            if(proj.RW_Floor_Plans__c != null && proj.RW_Floor_Plans__c != ''){
                projDet.floorPlans = proj.RW_Floor_Plans__c;
            }else{
                projDet.floorPlans = urlMap.get(proj.Floor_Plans_File_Id__c);
            }
            //projDet.floorPlans = urlMap.get(proj.Floor_Plans_File_Id__c);
            projDet.projectBrochure = proj.WhatsApp_Bot_Project_Brochure_Url__c;
            projDet.projectLocationMap = proj.Site_Address_Map_Link__c;
            if(proj.WhatsApp_Bot_Configuration__c != null){
                projDet.configurations = new List<String>(proj.WhatsApp_Bot_Configuration__c.split(';'));
                projDet.configurations.sort();
            }
            projDet.locality = proj.WhatsApp_Bot_Locality__c;
            projDet.offerings = proj.Project_Property_Type__c;
            if(proj.WhatsApp_Bot_Unit_Plan_Price__c != null && proj.WhatsApp_Bot_Unit_Plan_Price__c != ''){
                projDet.unitPlanPrice = proj.WhatsApp_Bot_Unit_Plan_Price__c;
            }else{
                projDet.unitPlanPrice = urlMap.get(proj.WhatsApp_Bot_Unit_Plan_Price_File_Id__c);
            }
            //projDet.unitPlanPrice = urlMap.get(proj.WhatsApp_Bot_Unit_Plan_Price_File_Id__c);
            projDet.unitPlanPriceText = proj.WhatsApp_Bot_Unit_Plan_Price_Text__c;
            projDetails.add(projDet);
        }
       	data.projectDetails = projDetails;
        return data;
        
    }
    
    @HttpPost
    global static String doPost(){
        RestRequest req = RestContext.request;
        system.debug(req.requestBody);
        String jsonBody = req.requestBody.toString();
        leadDetails resData = (leadDetails)JSON.deserialize(jsonBody, leadDetails.class);
        List<Lead> leads = [SELECT Id FROM Lead WHERE Conversation_Id__c =: resData.conversationId AND RW_Mobile_No__c =: resData.mobile];
        System.debug('leads: ' + leads);
        Lead ld = new Lead();
        if(leads.size() > 0){
            ld.Id = leads[0].Id;
        }
        ld.LastName = resData.name;
        ld.Email = resData.email;
        ld.RW_Mobile_No__c = resData.mobile;
        ld.RW_Configuration__c = resData.configuration;
        ld.RW_Project__c = (resData.project != '')? resData.project : null;
        ld.Conversation_Id__c = resData.conversationId;
        ld.LeadSource = 'WhatsApp Bot';
        try{
            if(leads.size() > 0){
                upsert ld;
                //TaskManagementServices.createTaskforEnquiries(new Map <Id, Lead>{ld.Id => ld});
            }else{
                List <DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(new List<Lead>{ld}, 'WEB');
                System.debug('dupList: ' + dupList);
                if(dupList.isEmpty()){
                    Database.saveResult[] srList = Database.insert(new List<Lead>{ld}, true);
                    for(Database.SaveResult sr: srList){
                        if(sr.isSuccess()){
                            System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                            try {
                                // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                // this is so that the complete form info is saved somewhere
                                Map <Id, Lead> enquiryMap = new Map <Id, Lead>();
                                enquiryMap.put(sr.getId(), ld);
                                Map <Id, Task> whoIdMap = new Map <Id, Task>();
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
                }else{
                    List<Lead> existingleads = [SELECT Id, LeadSource, LastName, Email, RW_Mobile_No__c, Country__c, RDS_Country_Code__c, 
                                                RW_Lead_Sub_Source__c, RW_Budget__c, RW_Project__c, Description, Banner_Type__c, CTA_Source__c, 
                                                web_banner_size__c, IP_address_web2lead__c, RW_Configuration__c, Is_Anarock_Lead__c, UTM_Campaign__c,
                                                Ad_Group__c, UTM_Medium__c, UTM_Source__c, Placement__c, Device__c, Gclid__c, RW_Unregistered_Broker_Name__c,
                                                Walkin_Unregistered_ChannelPartner_Name__c
                                                FROM Lead WHERE RW_Mobile_No__c =: resData.mobile];
                    TaskManagementServices.createTaskforEnquiries(new Map <Id, Lead>{existingleads[0].Id => existingleads[0]});
                }
            }
           //upsert ld;
           //TaskManagementServices.createTaskforEnquiries(new Map <Id, Lead>{ld.Id => ld});
            return '';
           //return ld.Id;
        }catch(exception e){
            return e.getMessage();
        }
    }
    
    /*global class Data{
        public AboutUs aboutUs;
        public List<String> projectLocality;
        public List<String> ourOfferings;
        public List<ProjectDetails> projectDetails;
        public Configurations configurations;
        public String message;
        
    }*/
    
    public class AboutUs{
        public String aboutUsText;
        public String aboutUsImage;
    }
    /*public class ProjectDetails{
        public string projectName;
        public string projectImage;
        public List<string> keyHighlights;
        public string projectVideoTour;
        public List<string> projectAmenities;
        public string floorPlans;
        public string projectBrochure;
        public string projectLocationMap;
        public List<String> configurationTypes;
        //public Configurations configurations;
    }*/
    
    public class Configurations{
        public string unitPlan;
        public Decimal price;
    }
    
    public class leadDetails{
        public string conversationId;
        public string name;
        public string email;
        public string mobile;
        public string locality;
        public string offering;
        public string configuration;
        public string project;
    }
    
    global class Data{
        public String aboutUsText;
        public String aboutUsImage;
        public List<ProjectDetails> projectDetails;
    }
    
    public class ProjectDetails{
        public string projectId;
        public string projectName;
        public string projectImage;
        public string keyHighlights;
        public string projectVideoTour;
        public string projectAmenities;
        public string floorPlans;
        public string projectBrochure;
        public string projectLocationMap;
        public List<String> configurations;
        public string locality;
        public string offerings;
        public string unitPlanPrice;
        public string unitPlanPriceText;
    }

}