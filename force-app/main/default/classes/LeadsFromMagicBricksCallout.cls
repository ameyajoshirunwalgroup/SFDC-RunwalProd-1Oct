public class LeadsFromMagicBricksCallout {
    private static String URL = 'http://rating.magicbricks.com/mbRating/download.xml?key=3V49D2kTrnMg5K70nqFAUw~~~~~~3D~~~~~~3D';
  private static String REQUEST_METHOD   = 'GET';
  private static String STARTDATE_PARAM   = '&startDate=';
  private static String ENDDATE_PARAM   = '&endDate=';
  private static String STARTTIME_PARAM   = '&startTime=';
  private static String ENDTIME_PARAM   = '&endTime=';
  private static String DATEFORMAT     = 'yyyyMMdd';
  private static String TIMEFORMAT     = 'HHmmss';
  private static String STATUS_SUCCESS  = 'success';
  private static String STATUS_ERROR    = 'error';
  private static string RequestedendPoint = '';
  
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
        if ((startDateTime.date().daysBetween(endDateTime.date())) > 5 ){
            System.debug('inside if ');
            startDateTime = endDateTime.addDays(-5);
        }
        
    String endpoint = URL;
    //Add Start date
    endpoint += STARTDATE_PARAM + startDateTime.format(DATEFORMAT);
    
    //Add End date
    endpoint += ENDDATE_PARAM + endDateTime.format(DATEFORMAT);
    
    //Add Start time
    endpoint += STARTTIME_PARAM + startDateTime.format(TIMEFORMAT);
    
    //Add End time
    endpoint += ENDTIME_PARAM + endDateTime.format(TIMEFORMAT);
    
        // Create HTTP request to send.
    Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(REQUEST_METHOD);
        request.setEndPoint(endpoint);
        HttpResponse response = httpProtocol.send(request);
        RequestedendPoint = request.getEndPoint();
    System.debug('Response:' + response.getBody());
    return response;
  }
  
  private static List<Lead> parseHTTPResponse(HTTPResponse response){
    List<Lead> leads;
    Lead lead;
        String pName;
        Map <String, MB_Campaign_Code__c> groupNameCS;
        String isd;
        String mobile;
        String city;
    
        XmlStreamReader reader = new XmlStreamReader(response.getBody());
        Task t = new Task();
        t.activityDate = System.today();
        //t.Call_Time__c = formatTime(system.now()); 
        t.Task_Type__c = 'Debug Magic Bricks';
        t.description = RequestedendPoint;
        t.description += '\n \n' + response.getBody();
        t.status = 'Done';
        t.Subject = 'Debug Magic Bricks';
        insert t;
    //Check the Status
    if (response.getStatusCode() == 200){
      //Proceed only if it is Success
      while (reader.hasNext()){
        if (XmlTag.START_ELEMENT == reader.getEventType()){
          
          if ('leads'.equals(reader.getLocalName())){
            leads = new List<Lead>();
                        groupNameCS = MB_Campaign_Code__c.getAll();
          } else if ('lead'.equals(reader.getLocalName())){
            lead = new Lead();
                     // lead.Enquiry_Mode_System__c = 'Internet';
                      lead.leadsource = 'Property Portals';
                      lead.Integration_Source__c = 'MagicBricks';
                      lead.RW_Lead_Sub_Source__c = 'MagicBricks';
                      lead.Lead_Sub_Source__c = 'MagicBricks';
                      lead.Webbanner_Source__c = 'www.magicbricks.com';
                      //lead.CCU_Source__c = 'Digital';
                      isd = '';
                      mobile = '';
          } else if ('city'.equals(reader.getLocalName())){
                        city = getValueFromTag(reader);
                        if (!String.isBlank(city)){
                          lead.City__c = city;    
                        }
          } else if ('dt'.equals(reader.getLocalName())){
            lead.Received_On__c = parseDate(getValueFromTag(reader));
          } else if ('email'.equals(reader.getLocalName())){
            lead.Email = getValueFromTag (reader);
          } else if ('isd'.equals(reader.getLocalName())){
              isd = getValueFromTag (reader);
          } else if ('mobile'.equals(reader.getLocalName())){
            mobile = getValueFromTag (reader);
          } else if ('msg'.equals(reader.getLocalName())){
            lead.Description = getValueFromTag(reader);
          } else if ('name'.equals(reader.getLocalName())){
            lead.lastName = getValueFromTag(reader);
          } else if ('project' == reader.getLocalName()) {
                    pName = getValueFromTag(reader);
                    if(String.isNotBlank(pName)) {
                        if(groupNameCS.containsKey(pName)) {
                            lead.Projects_Interested__c = groupNameCS.get(pName).Project_Name__c;
                            lead.Campaign_code__c = groupNameCS.get(pName).Campaign_Code__c;
                            List<Project__c> pList = [Select Id, Name from project__c where name = : lead.Projects_Interested__c];
                            if(pList != null && pList.size() ==1) {
                                lead.RW_Project__c = pList[0].Id;
                            }
                        }
                    } 
          }
        }/*else if ('Pid' == reader.getLocalName()) {
                    lead.Campaign_code__c = getValueFromTag(reader);
        }*/else if (XmlTag.END_ELEMENT == reader.getEventType()){
           if ('lead'.equals(reader.getLocalName())){
             //lead.RW_Mobile_No__c = isd + mobile;
             lead.RW_Mobile_No__c = mobile;
             leads.add(lead);
          }  
        }
        reader.next();
      }
      
    } else {
      //TODO What to do if it is an error? Someone should be notified?
      leads = new List<Lead>();
    }
    
    return leads;
  }
  
  private static String getValueFromTag(XMLStreamReader reader) {
        String DataValue;
        while (reader.hasNext()) {
            if (XmlTag.END_ELEMENT == reader.getEventType()) {
                break;
            } else if (XmlTag.CHARACTERS == reader.getEventType() || XmlTag.CDATA == reader.getEventType()) {
                DataValue = reader.getText();
            }
            reader.next();
        }
        return DataValue;
    }
    
    private static Date parseDate (String strDate){
        String rawDate = strDate.substring(0, 4) + '-' + strDate.substring(4, 6) + '-' + strDate.substring(6,8);
        return Date.valueOf(rawDate);
    }
    
    public static String  formatTime(DateTime input) {
        String dt = input.format();
        Integer s = dt.indexOf(' ');
        return dt.substring(s+1);
    }
}