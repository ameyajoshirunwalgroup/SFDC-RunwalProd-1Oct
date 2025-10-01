public class LeadsFromHousingComCallOut {
  private static String URL =  'https://leads.housing.com/api/v0/get-builder-leads?';
  private static String REQUEST_METHOD   = 'GET';
  private static String STARTDATE_PARAM   = '&start_date=';
  private static String ENDDATE_PARAM   = '&end_date=';
  private static String CURRENTTIME_PARAM   = '&current_time=';
  private static String HASH_PARAM   = '&hash=';
  private static String PROFILEID_PARAM   = '&id=9400993';
  private static string RequestedendPoint = '';
  private static string privateKey = '05e734e65a6accc6fcd4b530d6bad03d';
  
  public static List<Lead> getLeads(DateTime startDateTime, DateTime endDateTime) {
    //Generate and send the HTTP request
    HTTPResponse response = sendHTTPRequest(startDateTime, endDateTime);
    
    //Parse the HTTP response
    return parseHTTPResponse(response);
  }
  private static HTTPResponse sendHTTPRequest(DateTime startDateTime, DateTime endDateTime){
      //For first scheduled trigger the startDateTime will be null.
        if (startDateTime == NULL){
            startDateTime = DateTime.now().addMinutes(-60);
        }
        
        //Cannot retrieve data which is older than 5 days
       /** if ((startDateTime.date().daysBetween(endDateTime.date())) > 5 ){
            System.debug('inside if ');
            startDateTime = endDateTime.addDays(-5);
        } **/
        Long startdate = startDateTime.getTime() /1000;
        Long endDate = endDateTime.getTime() /1000;
        Datetime gmt = Datetime.Now() ;
        Long currentTime = gmt.getTime()/ 1000;
        Blob secret = crypto.generateMac('HmacSHA256' , Blob.valueOf(String.valueOf(currentTime)), blob.valueOf(privateKey));
        String tempHash = EncodingUtil.convertToHex(secret);
        System.debug('StartDate::'+startDate);
        System.debug('Enddate::'+endDate);
        String endpoint = URL;
        //Add Start date
        endpoint += STARTDATE_PARAM + startdate;
        
        //Add End date
        endpoint += ENDDATE_PARAM + endDate;
        
        //Add Current time
        endpoint += CURRENTTIME_PARAM  + currentTime;
        
        //Add Hash 
        endpoint += HASH_PARAM  + tempHash;
        
        //Add profileid 
        endpoint += PROFILEID_PARAM;
        System.debug('EndPoint::'+endpoint);
        // Create HTTP request to send.
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(REQUEST_METHOD);
        request.setEndPoint(endpoint);
        HttpResponse response = httpProtocol.send(request);
        RequestedendPoint = request.getEndPoint();
        System.debug('Response:' + response.getBody());
        System.debug('Response:' + response);
        
    return response;
        
  }
  private static List<Lead> parseHTTPResponse(HTTPResponse response) {
        List<Lead> leads;
        Lead lead;
        String pName;
        Map <String, Group_Name__c> groupNameCS;
        String mobile;
        String city;
        
        //XmlStreamReader reader = new XmlStreamReader(response.getBody());
        Task t = new Task();
        t.activityDate = System.today();
        t.Call_Time__c = formatTime(system.now()); 
        t.Task_Type__c = 'Debug Housing.com';
        t.description = RequestedendPoint;
        t.description += '\n \n' + response.getBody();
        t.status = 'Done';
        t.Subject = 'Housing.com';
        insert t;
        
        List<HousingJSONParser.HousingJSONWrapper> housingLeadList =  new List<HousingJSONParser.HousingJSONWrapper>();
        housingLeadList = HousingJSONParser.parse(response.getBody());
        System.debug('housing lead list Size:' + housingLeadList.size());
        System.debug('housing lead list:' + housingLeadList);
        //Check the Status
        if (response.getStatusCode() == 200){
            if(!housingLeadList.isEmpty()) {
                 leads = new List<Lead>();
                 groupNameCS = Group_Name__c.getAll();
                 for(HousingJSONParser.HousingJSONWrapper hLead : housingLeadList) {
                    lead = new Lead();
                      lead.leadsource = 'Property Portals';
                      lead.Integration_Source__c = 'Housing.com';
                      lead.RW_Lead_Sub_Source__c = 'Housing.com';
                      lead.Lead_Sub_Source__c = 'Housing.com';
                      lead.Webbanner_Source__c = 'www.Housing.com';
                    if(hLead.lead_date != null) {
                      lead.Received_On__c = Date.ValueOf(DateTime.newInstance(hLead.lead_date*1000));
                    }    
                    if(hLead.lead_email != null)
                        lead.Email = hLead.lead_email;
                    if(hLead.lead_name != null)
                        lead.lastName = hLead.lead_name;
                    if(hLead.lead_phone != null)
                        lead.RW_Mobile_No__c = hLead.lead_phone;
                    if(hLead.project_id != null)
                        lead.Campaign_code__c = String.valueOf(hLead.project_id);
                    if(hLead.project_name != null) {
                        hLead.project_name = hLead.project_name.removeEnd(' ');
                        pName = hLead.project_name;
                            if(String.isNotBlank(pName)) {
                                if(groupNameCS.containsKey(pName)) {
                                    lead.Projects_Interested__c = groupNameCS.get(pName).Project_Name__c;
                                    List<Project__c> pList = [Select Id, Name from project__c where name = : lead.Projects_Interested__c]; //
                                    if(pList != null && pList.size() ==1) {
                                        lead.RW_Project__c = pList[0].Id;
                                    }
                                }
                            } 
                    }
                    leads.add(lead);
                 }
            } else {
                //TODO What to do if it is an error? Someone should be notified?
                  leads = new List<Lead>();
            }
        }
        System.debug('LeadList::'+leads);
        System.debug('LeadList size::'+leads.size());
    return leads;
  }
  // returns the time from the datetime field in the user's locale
    // if the input was 17/1/2016 12:30 AM, returns 12:30 AM as a string
    public static String  formatTime(DateTime input) {
        String dt = input.format();
        Integer s = dt.indexOf(' ');
        return dt.substring(s+1);
    }
    private static Date parseDate (String strDate){
        String rawDate = strDate.substring(0, 4) + '-' + strDate.substring(4, 6) + '-' + strDate.substring(6,8);
        return Date.valueOf(rawDate);
    }
}