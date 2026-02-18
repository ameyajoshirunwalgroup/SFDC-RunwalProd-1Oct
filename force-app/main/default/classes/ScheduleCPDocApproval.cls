global class ScheduleCPDocApproval implements Schedulable {
    global void execute(SchedulableContext sc) {
        Date todaysDate = System.today();

        List<Broker__c> pendingForDocApprovalList = [SELECT Id,Latest_RERA_Upload_Status__c,RERA_Valid_till__c,Latest_RERA_Upload_Processed__c
                                                     /*Latest_CC_Upload_Status__c, CC_Valid_till__c, Latest_CC_Upload_Processed__c*/ FROM Broker__c//Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
                                                     WHERE (Latest_RERA_Upload_Status__c = 'Approval Pending' AND 
                                                            RERA_Valid_till__c != null AND 
                                                            RERA_Valid_till__c >= TODAY AND 
                                                            Latest_RERA_Upload_Processed__c = false)
                                                     /*OR (Latest_CC_Upload_Status__c = 'Approval Pending' 
                                                         AND CC_Valid_till__c != null AND 
                                                         CC_Valid_till__c >= TODAY AND 
                                                         Latest_CC_Upload_Processed__c = false)//Commented by Prashant as discussed with team to discard use of CC. 12/12/25.*/];

        List<Broker__c> brokersToUpdate = new List<Broker__c>();

        for (Broker__c br : pendingForDocApprovalList) {
            try {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();

                if (br.Latest_RERA_Upload_Status__c == 'Approval Pending'
                    && br.RERA_Valid_till__c != null
                    && br.RERA_Valid_till__c >= todaysDate
                    && br.Latest_RERA_Upload_Processed__c == false) {

                    req.setComments('Auto-submitted by system for RERA Upload Approval');
                    req.setObjectId(br.Id);
                    req.setProcessDefinitionNameOrId('CP_RERA_Upload_Approval_Process');

                }
                //Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
                /*else if (br.Latest_CC_Upload_Status__c == 'Approval Pending'
                           && br.CC_Valid_till__c != null
                           && br.CC_Valid_till__c >= todaysDate
                           && br.Latest_CC_Upload_Processed__c == false) {

                    req.setComments('Auto-submitted by system for CC Upload Approval');
                    req.setObjectId(br.Id);
                    req.setProcessDefinitionNameOrId('CP_CC_Upload_Approval_Process');
                } */ else {
                    continue;
                }

                Approval.ProcessResult res = Approval.process(req);

                if (res.isSuccess()) {
                    System.debug('Approval submitted: ' + res.getEntityId());

                    if (br.Latest_RERA_Upload_Status__c == 'Approval Pending') {
                        br.Latest_RERA_Upload_Processed__c = true;
                    } /*else if (br.Latest_CC_Upload_Status__c == 'Approval Pending') {
                        br.Latest_CC_Upload_Processed__c = true;
                    }*///Commented by Prashant as discussed with team to discard use of CC. 12/12/25.
                    brokersToUpdate.add(br);

                } else {
                    System.debug('FAILED: ' + res.getEntityId() + ' - ' + res.getInstanceStatus());
                }
            } catch (Exception e) {
                System.debug('Approval submission failed for record: ' + br.Id +
                             ' | Error: ' + e.getMessage());
            }
        }

        if (!brokersToUpdate.isEmpty()) {
            Database.SaveResult[] wiList = Database.update(brokersToUpdate, false);
            for (Database.SaveResult sr : wiList) {
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ':' + err.getMessage());
                    }
                }
            }
        }
    }
}