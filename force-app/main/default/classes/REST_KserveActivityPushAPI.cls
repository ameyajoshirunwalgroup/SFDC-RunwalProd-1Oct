@RestResource(urlMapping = '/Kserve/ActivityDetails/')
global class REST_KserveActivityPushAPI {
        @HttpPost
        Global static REST_Result ActivityDetails() {
                REST_Result r = new REST_Result();
                system.debug('Request::' + RestContext.Request);

                Restrequest request = RestContext.request;
                system.debug('request.requestBody::' + request.requestBody);

                Rest_KserveActivityDetails_parse objjson;
                if (string.isBlank(request.requestBody.toString())) {
                        r.Returncode = 1;
                        r.Message = 'INVALID REQUEST';
                        return r;
                } else {
                        objjson = Rest_KserveActivityDetails_parse.Parse(request.requestBody.toString());
                        if (String.isEmpty(objjson.AttemptedBy) || String.isEmpty(objjson.ProposedDateofVisit) || String.isEmpty(objjson.ProjectInterested) ||
                                String.isEmpty(objjson.NextActionDate) || String.isEmpty(objjson.CallStatus) || String.isEmpty(objjson.CallComments) ||
                                String.isEmpty(objjson.CommunicationType) || String.isEmpty(objjson.CallDate) || String.isEmpty(objjson.LeadId) || String.isEmpty(objjson.CallTime)) {
                                r.Returncode = 1;
                                r.Message = 'Missing mandatory parameters';
                                return r;
                        } else {
                                string query = 'select id,Name from Project__c where Name LIKE \'%' + objjson.ProjectInterested + '%\'';
                                List < Project__c > lstprj = new List < Project__c > ();
                                lstprj = Database.query(query);
                                if (lstprj.size() == 0) {
                                        r.Returncode = 1;
                                        r.Message = 'INVALID PROJECT NAME';
                                        return r;
                                } else {
                                        List < Lead > lstlead = new List < Lead > ();
                                        lstlead = [Select id,OwnerId from Lead where id =: objjson.LeadId];
                                        if (lstlead.size() == 0) {
                                                r.Returncode = 1;
                                                r.Message = 'INVALID LEAD ID';
                                                return r;
                                        } else {
                                                try {
                                                        Task objtask = new Task();
                                                        objtask.Attempted_By__c = objjson.AttemptedBy;
                                                        objtask.Call_Status__c = objjson.CallStatus;
                                                        objtask.Call_Time__c = objjson.CallTime;
                                                        objtask.Communication_Type__c = objjson.CommunicationType;
                                                        objtask.Next_Action_Date__c = DateTime.parse(objjson.NextActionDate);
                                                        objtask.Call_Proposed_date_of_visit__c = DateTime.parse(objjson.ProposedDateofVisit);
                                                        objtask.Project__c = lstprj[0].id;
                                                        objtask.Call_Time__c = objjson.CallTime;
                                                        objtask.Description = objjson.CallComments;
                                                        objtask.ActivityDate = Date.valueOf(objjson.CallDate);
                                                        objtask.WhoId = objjson.LeadId;
                                                        objtask.Subject = 'Presales Call';
                                                        objtask.Task_Type__c = 'Presales Call';
                                                        objtask.OwnerId = lstlead[0].OwnerId ;
                                                        objtask.Status ='Completed';
                                                        insert objtask;

                                                        r.Returncode = 0;
                                                        r.Message = 'activity created successfully';
                                                        return r;

                                                } catch (Exception e) {
                                                        r.Returncode = 0;
                                                        r.Message = 'Something Went Wrong' + e;
                                                        return r;
                                                }
                                        }

                                }
                        }
                }
                //return r;
        }
        global class REST_Result {
                WebService integer Returncode;
                WebService String Message;
        }
}