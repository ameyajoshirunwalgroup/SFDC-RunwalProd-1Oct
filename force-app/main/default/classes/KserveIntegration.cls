public class KserveIntegration implements Queueable, database.allowscallouts {

        public set < Id > leadId;
        public KserveIntegration(set < Id > LeadIds) {
                this.leadId = leadIds;
        }
        public void execute(QueueableContext qc) {
                system.debug('LeadID::' + LeadID);
                Boolean status;
                string messege;
                if (LeadID != null && LeadID.size() > 0) {
                        system.debug('Inside if condition::' + LeadID);

                        if (LeadID != null && LeadID.size() > 0) {
                                List < Lead > lstlead = new List < Lead > ();
                                List < Lead > lst = new List < Lead > ();
                                lstlead = [Select id, name, FirstName, LastName, RW_Mobile_No__c, Phone, RW_Project__c, RW_Project__r.Name, LeadSource,
                                        RW_Lead_Sub_Source__c, OwnerId, RW_Budget__c, RDS_Budget__c, RW_Configuration__c, RW_Time_line__c
                                        from lead where id =: LeadId AND isConverted = false
                                ];
                                system.debug('lstlead' + lstlead);

                                if (lstlead.size() > 0) {

                                        for (Lead l: lstlead) {

                                                String urlparam = 'http://114.143.75.178:7070/elision-dialer/elision-api/main.php?source=SFDC&action=add_lead&custom_fields=Y&list_id=9999';

                                                urlparam += '&crm_leadid=' + l.Id;
                                                urlparam += '&Lead_Owner=' + l.OwnerId;
                                                urlparam += '&Firstname=' + l.FirstName;
                                                urlparam += '&Lastname=' + l.Lastname;
                                                urlparam += '&phone_number=' + l.RW_Mobile_No__c;
                                                urlparam += '&ALTNumber=' + l.Phone;
                                                urlparam += '&Project_Name=' + l.RW_Project__r.Name;
                                                urlparam += '&Lead_Source=' + l.LeadSource;
                                                urlparam += '&Lead_Sub_Source=' + l.RW_Lead_Sub_Source__c;
                                                urlparam += '&Budget=' + l.RW_Budget__c;
                                                urlparam += '&Configuration=' + l.RW_Configuration__c;
                                                urlparam += '&Possession_Timeline=' + l.RW_Time_line__c;

                                                Http httpProtocol = new Http();
                                                HttpRequest request = new HttpRequest();
                                                request.setMethod('GET');
                                                request.setEndpoint(urlparam);
                                                system.debug('request:' + urlparam);
                                                HttpResponse response;
                                                if (!Test.isRunningTest()) {
                                                        response = httpProtocol.send(request);
                                                        System.debug('Response:' + response.getbody());

                                                }
                                                if (!Test.isRunningTest()) {
                                                        JSONParser parser = JSON.createParser(response.getBody());
                                                        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                                                                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                                                        string text = parser.getText();
                                                                        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                                                                                if (text == 'status') {
                                                                                        status = Boolean.valueOf(parser.getText());
                                                                                }
                                                                                if (text == 'message') {
                                                                                        messege = parser.getText();
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                }
                                                if (status == true && messege == 'add_lead LEAD HAS BEEN ADDED') {
                                                        l.Send_to_Kserve__c = true;
                                                        lst.add(l);
                                                }
                                        }
                                        update lst;
                                }
                        }
                }
        }
        public static void dummy() {
                string status;
                integer i;
                boolean show;
                string messege;
                string status1;
                integer i1;
                boolean show1;
                string messege1;

        }

}