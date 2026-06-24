/**
 * @RestResource: Lockated_CPEvents
 * @Description: Unified REST API endpoint to fetch CP_Meets events related to a broker.
 *               Returns both upcoming and past events, each with nested details object.
 */
@RestResource(urlMapping='/cpEvents/*')
global without sharing class Lockated_CPEvents {
   
    public static final Id CP_MEET_RECORDTYPE_ID =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('CP_Meets').getRecordTypeId();

    @HttpGet
    global static void doGet() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        res.addHeader('Content-Type', 'application/json');

        try {
            String brokerId = req.params.get('brokerId');
            if (String.isBlank(brokerId)) {
                sendError(res, 400, 'Missing required parameter: brokerId');
                return;
            }

            handleEventsWithDetails(res, brokerId);

        } catch (Exception e) {
            sendError(res, 500, 'Unexpected error occurred: ' + e.getMessage());
        }
    }
    
    @HttpPost
    global static void doPost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug(req.requestBody);
        String cpId = req.params.get('cpId');
        system.debug('cpId -> '+cpId);
        String eventId = req.params.get('eventId');
        system.debug('eventId -> '+eventId);
        String status = req.params.get('status');
        system.debug('status -> '+status);
        String jsonBody = req.requestBody.toString();
        Map<String, Object> errorResult = new Map<String, Object>();
        if(String.isBlank(cpId) || String.isBlank(eventId) || String.isBlank(status)){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass valid CP Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            try{
                // Deserialize the incoming JSON body
                //Input input = (Input)JSON.deserialize(req.requestBody.toString(), Input.class);
                list<Broker__c> brlist = [Select Id,Account__c from Broker__c where Id =: cpid];                
                List<CampaignMember> campaignMembers = [SELECT Id, Additional_Attendees__c, RSVP__c
                                                        FROM CampaignMember 
                                                        WHERE Id =: eventId ];
                system.debug('Inside Try');
                if(!campaignMembers.isEmpty()){
                    system.debug('Campaign members');
                    for(CampaignMember cm : campaignMembers){
                        cm.Additional_Attendees__c = 1;//By default 1 to be passed.
                        if(status == 'Going'){
                            cm.RSVP__c = true;
                        }
                        if(status == 'Not Going'){
                            cm.Declined__c = true;
                        }
                    }
                    system.debug('Update');
                    update campaignMembers;
                    
                    
                res.statusCode = 200; // Created
                res.responseBody = Blob.valueOf(JSON.serialize('Success'));
                }
                
                /*
                
                // Create Lead
                Lead newLead = new Lead();
                newLead.LastName = input.customerName;
                newLead.RW_Mobile_No__c = input.mobileNumber;
                newLead.Email = input.email;
                newLead.RW_Project__c = projList[0].Id;
                //newLead.RW_Project__c = input.projectInterested;
                //newLead.OwnerId = (communityUser != null ? communityUser.Id : UserInfo.getUserId());
                newLead.OwnerId =brlist[0].Sourcing_Manager__c ;
                newLead.RW_Broker__c = brlist[0].Id;
                newLead.Project_Type__c = input.propertyType;
                
                if(brlist[0].RecordType.DeveloperName =='Channel_Partner'){
                    newLead.LeadSource = 'Channel partner';
                }
                if(brlist[0].RecordType.DeveloperName =='Temp_Channel_Partner'){
                    newLead.LeadSource = 'Temp Channel Partner';
                }
                
                insert newLead;
                
                response.status = 'success';
                response.message = 'Lead added successfully';
                response.leadId = newLead.Id;
                res.statusCode = 200; // Created
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            } catch(Exception e) {
                errorResult.status = 'error';
                errorResult.message = e.getMessage();
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            }*/
            }catch(Exception e) {
                errorResult.put('status', 'error');
                errorResult.put('message', e.getMessage());
                res.statusCode = 500;
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            }
        
    }
    }
    

    
    /**
     * @Method: handleEventsWithDetails
     * @Description: Fetches all broker-related campaigns and structures response
     *               into upcoming and past events, each with nested details object.
     */
    public static void handleEventsWithDetails(RestResponse res, String brokerId) {
        List<CampaignMember> brokerMembers = [SELECT Id,CampaignId, RSVP__c FROM CampaignMember WHERE Contact.Account.Channel_Partner__c = :brokerId AND Campaign.RecordTypeId = :CP_MEET_RECORDTYPE_ID AND Campaign.Type__c = 'CP Meets'];

        if (brokerMembers.isEmpty()) {
            sendError(res, 404, 'No campaigns found for the provided brokerId.');
            return;
        }

        Map<Id, CampaignMember> campaignIdVsMemberMap = new Map<Id, CampaignMember>();
        Set<Id> campaignIds = new Set<Id>();
        for (CampaignMember cm : brokerMembers) {
            campaignIdVsMemberMap.put(cm.CampaignId, cm);
            campaignIds.add(cm.CampaignId);
        }

        List<Campaign> brokerCampaigns = [SELECT Id, Name, Event_Date_Time__c, Event_Location__c, Description, Status FROM Campaign WHERE Id IN :campaignIds ORDER BY Event_Date_Time__c DESC];

        List<EventWrapper> upcomingEvents = new List<EventWrapper>();
        List<EventWrapper> pastEvents = new List<EventWrapper>();

        DateTime now = System.now();
		// --- Build Event Response ---
        for (Campaign camp : brokerCampaigns) {
            EventDetail detail = new EventDetail();
            detail.eventId = campaignIdVsMemberMap.get(camp.Id).Id;//this is Campaign member id
            detail.campaignId = camp.Id; //this is campaign id
            detail.title = camp.Name;
            detail.location = camp.Event_Location__c;
            detail.details = camp.Description;
            detail.campaignDate = (camp.Event_Date_Time__c != null) ? camp.Event_Date_Time__c.date() : null;
            detail.campaignTime = (camp.Event_Date_Time__c != null) ? camp.Event_Date_Time__c.format('hh:mm a') : null;
            //detail.status = (campaignIdVsMemberMap.containsKey(camp.Id) && campaignIdVsMemberMap.get(camp.Id) == true) ? 'Going' : 'Not Going';

            // --- Wrapper Object ---
            EventWrapper wrapper = new EventWrapper();
            wrapper.eventId = camp.Id;
            wrapper.details = detail;

            // --- Categorize ---
            if (camp.Event_Date_Time__c != null && camp.Event_Date_Time__c >= now)
                upcomingEvents.add(wrapper);
            else
                pastEvents.add(wrapper);
        }

        FinalResponse finalResponse = new FinalResponse();
        finalResponse.upcomingEvents = upcomingEvents;
        finalResponse.pastEvents = pastEvents;

        res.statusCode = 200;
        res.responseBody = Blob.valueOf(JSON.serialize(finalResponse));
    }

    // --- Helper for error handling ---
    private static void sendError(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        CampaignResponse response = new CampaignResponse();
        response.isSuccess = false;
        response.error_message = message;
        res.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    // --- Wrapper Classes ---
    global class FinalResponse {
        public List<EventWrapper> upcomingEvents;
        public List<EventWrapper> pastEvents;
    }

    global class EventWrapper {
        public String eventId;
        public EventDetail details;
    }

    global class EventDetail {
        public String eventId;
        public String campaignId;
        public String title;
        public String location;
        public String details;
        public Date campaignDate;
        public String campaignTime;
        public String status;
    }

    global class CampaignResponse {
        public Boolean isSuccess;
        public String error_message;
    }
}