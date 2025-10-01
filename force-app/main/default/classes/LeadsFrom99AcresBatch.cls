global class LeadsFrom99AcresBatch implements Database.Batchable <sObject>, Schedulable, Database.AllowsCallouts {
    global List < Lead > start(Database.BatchableContext BC) {
        List < Lead > llist = new List < Lead > ();
        llist = getmy99Response();
        return llist;
    }

    global void execute(Database.BatchableContext BC, List < Lead > scope) {
        
        for (lead l: scope) {
            List < Lead > leadList = new List < Lead > ();
            System.debug('L from loop:' + l);
            database.DMLOptions dmo = new database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            dmo.EmailHeader.triggerUserEmail = true;
            l.setOptions(dmo);
            //leadList.add(l); //Commented by Vinay 28-08-2025
            if(!String.isBlank(l.RW_Project__c)){ //Added by Vinay 28-08-2025
                leadList.add(l);
            }else{
                ERP_Integration_Log__c log = new ERP_Integration_Log__c();
                log.request__c = 'RW_Mobile_No__c: ' +  l.RW_Mobile_No__c + ', Email: ' + l.Email + ', Name: ' + l.LastName + ', Integration_Source__c: 99 Acres';
                log.API_name__c = 'Lead Creation Error';
                log.response__c = 'Project is missing';
                log.Status__c='Failure';
                log.Error_Type__c='Data Error';
                log.Error_Reason__c = 'Project is missing';
                insert log;
            }
            try {
                List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if (dupList.isEmpty()) {
                    try {
                        Database.saveResult[] srList = Database.insert(leadList, true);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                try {
                                    System.debug('Here: 1');
                                    // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                    // this is so that the complete form info is saved somewhere
                                    Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                    enquiryMap.put(sr.getId(), l);
                                    Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                    whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                                    
                                } catch (Exception ex) {
                                    System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                                }
                            } else {
                                // Operation failed, so get all errors  
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }

                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                    }
                }
            } catch (GlobalException g) {

            }
        }
    }

    global void finish(Database.BatchableContext BC) {}

    public static List < Lead > getmy99Response() {
        Http httpProtocol = new Http();
        // Create HTTP request to send.
        HttpRequest request = new HttpRequest();
       // String endpoint = 'http://www.99acres.com/99api/v1/getmy99Response/OeAuXClO43hwseaXEQ/uid/';		//Commented by Sheetal on 04/07/2022
          String endpoint = 'https://www.99acres.com/99api/v1/getmy99Response/OeAuXClO43hwseaXEQ/uid/';		//Added by Sheetal on 04/07/2022

      //  Integer m = Math.mod(DateTime.now().minute(), 10);
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument(null, null);
        w.writeStartElement(null, 'query', null);
        w.writeStartElement(null, 'user_name', null);
        w.writeCharacters('runwalhomes99');
        w.writeEndElement();
        w.writeStartElement(null, 'pswd', null);
        w.writeCharacters('runwal99');
        w.writeEndElement();
        w.writeStartElement(null, 'start_date', null);
        w.writeCharacters(DateTime.now().addMinutes(-25).addSeconds(-DateTime.now().second()).format('yyyy-MM-dd HH:mm:ss'));
        w.writeEndElement();
        w.writeStartElement(null, 'end_date', null);
        w.writeCharacters(DateTime.now().addMinutes(-10).addSeconds(-DateTime.now().second()).format('yyyy-MM-dd HH:mm:ss'));
        w.writeEndElement();
        w.writeEndElement();
        w.writeEndDocument();

        String xmlOutput = w.getXmlString();

        w.close();
        String xmlOutput1 = 'xml=' + xmlOutput;

        System.debug('XML request:' + xmlOutput1);
        request.setMethod('POST');
        request.setEndPoint(endpoint);
        request.setBody(xmlOutput1);
        List < Lead > leadList = new List<Lead>();
        if(!Test.isRunningTest()) { // can't make callouts during test methods
            HttpResponse response = httpProtocol.send(request);
            System.debug('RESPONSE:' + response.getBody());
            XmlStreamReader reader = new XmlStreamReader(response.getBody());
            Task t = new Task();
            t.activityDate = System.today();
            //t.Call_Time__c = formatTime(system.now()); 
            t.Task_Type__c = 'Debug 99 Acres';
            t.description = xmlOutput1;
            t.description += '\n \n' + response.getBody();
            if(t.Description.length() > 32000) {
                t.description = t.description.subString(0,31999);
            }
            t.status = 'Done';
            t.Subject = 'Debug 99 Acres';
            insert t;
            leadList = readResponse(reader);
        }
        if(Test.isRunningTest()) { // simulation of response for test methods
            String response = 
            '<Xml ActionStatus="true"> ' +
            '<Resp>' +
            '<QryDtl ResType="S2M" QueryId="C2V_CONFIG_SLOTS-138573">' +
            '<CmpctLabl><![CDATA[3BHK Residential Apartment]]></CmpctLabl>' +
            '<QryInfo><![CDATA[]]></QryInfo>' +
            '<RcvdOn><![CDATA[2016-04-30 12:25:59]]></RcvdOn>' +
            '<ProjId><![CDATA[119883]]></ProjId>' +
            '<ProjName><![CDATA[Runwal Bliss]]></ProjName>' +
            '</QryDtl>' +
            '<CntctDtl>' +
            '<Name><![CDATA[Kumar Priyam]]></Name>' +
            '<Email><![CDATA[kumar.priyamk@gmail.com]]></Email>' +
            '<Phone><![CDATA[+91-9916336789]]></Phone>' +
            '</CntctDtl>' +
            '</Resp>' +
            '</Xml>';

            XmlStreamReader reader = new XmlStreamReader(response);
            leadList = readResponse(reader);
        }
        return leadList;
    }

    public static List < lead > readResponse(XmlStreamReader reader) {
        Integer count = 0;
        String projId;
        Lead ll;
        List < Lead > leadList = new List < Lead > ();
        Map<String, Group_Name__c> groupNameCS = Group_Name__c.getAll();
        String pName = '';
        while (reader.hasNext()) {
           // System.debug('Event:' + reader.getEventType());
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if ('Resp' == reader.getLocalName()) {
                    ll = new Lead();
                     // lead.Enquiry_Mode_System__c = 'Internet';
                      ll.leadsource = 'Property Portals';
                      ll.Integration_Source__c = '99 Acres';
                      ll.RW_Lead_Sub_Source__c= '99 Acres';
                      ll.Lead_Sub_Source__c = '99 Acres';
                      ll.Webbanner_Source__c = 'www.99acres.com';
                      
                }
                if ('RcvdOn' == reader.getLocalName()) {
                    List < String > dateString = getValueFromTag(reader).split(' ');
                    // ll.Received_On__c = Date.ValueOf(dateString[0]);
                }
                if ('ProjName' == reader.getLocalName()) {
                    pName = getValueFromTag(reader);
                    if(String.isNotBlank(pName)) {
                        if(groupNameCS.containsKey(pName)) {
                            ll.Projects_Interested__c = groupNameCS.get(pName).Project_Name__c;
                            List<Project__c> pList = [Select Id, Name from project__c where name = : ll.Projects_Interested__c];
                            if(pList != null && pList.size() ==1) {
                                ll.RW_Project__c = pList[0].Id;
                            }
                        }
                    } 
                }
                if ('CmpctLabl' == reader.getLocalName()) {
                    ll.description = getValueFromTag(reader);
                }
                if ('QryInfo' == reader.getLocalName()) {
                    ll.description += getValueFromTag(reader);
                }
                if ('ProjId' == reader.getLocalName()) {
                    ll.Campaign_code__c = getValueFromTag(reader);
                }
                if ('Name' == reader.getLocalName()) {
                    ll.lastName = getValueFromTag(reader);
                }
                if ('Email' == reader.getLocalName()) {
                    ll.email = getValueFromTag(reader);
                }
                if ('Phone' == reader.getLocalName()) {
                    List < String > mobileString = getValueFromTag(reader).split('-');
                    ll.RW_Mobile_No__c = mobileString[1];
                    ll.RDS_Country_Code__c=mobileString[0];
                                        
                    if (ll.RDS_Country_Code__c !='+91') {
                    ll.is_NRI__c=True;
                        }
                }
                
            } else if (reader.getEventType() == XmlTag.END_ELEMENT) {
                // Is the next element an end tag? If yes is it an Resp or an Xml tag?
                // Resp refers to completion a single lead specific data 
                // write the lead to the list and set ll to null
                // System.debug('end tag name:' + reader.getLocalName());
                if ('Resp' == reader.getLocalName()) {
                    leadList.add(ll);
                    ll = null;
                }
                if ('Xml' == reader.getLocalName()) {
                    // If you find end tag called xml, push the lead record in list
                   // System.debug('Here:break');
                    break;
                }

            }
            pName = '';
            reader.next();
        }
        System.debug('Lead List:' + leadList);
        return leadList;
    }

    // This is an extra function to read data between opening and closing tag. 
    // It will return the string of value from between tags
    public static string getValueFromTag(XMLStreamReader reader) {
        String DataValue;
        while (reader.hasNext()) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS || reader.getEventType() == XmlTag.CDATA) {
                DataValue = reader.getText();
            }
            reader.next();
        }
        System.debug('Data value:' + dataValue);
        return DataValue;
    }
    
    // returns the time from the datetime field in the user's locale
    // if the input was 17/1/2016 12:30 AM, returns 12:30 AM as a string
    public static String  formatTime(DateTime input) {
        String dt = input.format();
        Integer s = dt.indexOf(' ');
        return dt.substring(s+1);
    }
    
    global void execute(SchedulableContext sc) {
      LeadsFrom99AcresBatch b = new LeadsFrom99AcresBatch(); 
      database.executebatch(b,1);
    }   
    
}