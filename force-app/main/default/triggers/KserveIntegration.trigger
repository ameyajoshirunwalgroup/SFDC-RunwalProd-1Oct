trigger KserveIntegration on Lead(After insert) {

        /*Set < Id > leadId = new Set < Id > ();
        system.debug('Inside trigger');
        if (Trigger.isInsert && Trigger.isAfter) {
                for (lead l: Trigger.New) {

                        if (l.Kserve_Integration__c == true && l.LeadSource == 'Digital' && (l.RDS_Country_Code__c == '91' || l.RDS_Country_Code__c == '+91')) { //l.RW_Project__r.Kserve_Integration__c    

                                leadId.add(l.id);
                        }
                        system.debug('leadId:' + leadId);

                }
                if (leadId.size() > 0) {
                        //KserveIntegration.LeadDetails(leadId);
                        System.enqueueJob(new KserveIntegration(leadId));

                }
        }*/

}