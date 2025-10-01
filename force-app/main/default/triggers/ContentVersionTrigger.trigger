trigger ContentVersionTrigger on ContentVersion (before insert,after insert) {
    List<String> contenDocumentids=new List<String>(); 
    Set<Id> contenDocumentids2=new Set<Id>(); 
    List<String> contenDocumentLinkIds=new List<String>(); 
    List<ContentDocumentLink> contentdocs = new List<ContentDocumentLink>();
    List<ContentDocumentLink> updatecdl = new List<ContentDocumentLink>();
    if(trigger.isbefore)
    {
        for (ContentVersion cv : trigger.new)
        {
            System.debug('inside before conVer'+cv);
            
        }
        
    }
    
    if(trigger.isAfter)
    {
        for (ContentVersion cv : trigger.new)
        {
            contenDocumentids.add(cv.ContentDocumentId);
            System.debug('inside after conVer'+cv);
        }
        
        List<ContentDocumentLink> contDoc = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN: contenDocumentids];
        for(ContentDocumentLink contDocumentLink :contDoc)
        {
            System.debug('before if'+contDocumentLink);
            if(contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Loan__c' || contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName()=='RW_Tower_Construction_Update__c' || contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'TDS__c'  
               || contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Applicant_Details__c' || contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Booking__c' || contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Collateral__c' )
            {
                System.debug('inside for'+contDocumentLink);
                contDocumentLink.ShareType = 'V';
                contDocumentLink.Visibility = 'AllUsers';
                contentdocs.add(contDocumentLink);
                System.debug('inside for end'+contentdocs);
            }
        }
        for(ContentDocumentLink contDocumentLink :contDoc)
        {
            if(contDocumentLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Brokerage_Invoice__c'){
               System.debug('inside for'+contDocumentLink);
                contDocumentLink.ShareType = 'V';
                contDocumentLink.Visibility = 'InternalUsers';
                updatecdl.add(contDocumentLink);
                System.debug('inside for end'+contentdocs);
            }
        }
        
        if(contentdocs.size() >0)
        {
            system.debug('*inside update*'+contentdocs);
            update contentdocs;
        }
        
        if(updatecdl.size() >0 && userinfo.getUserType() != 'PowerPartner')
        {
            system.debug('*inside update updatecdl*'+updatecdl);
            //update updatecdl;
        }
/*  
    List<String> contenDocumentids=new List<String>();   
    List<String> opportunityId=new List<String>(); 
    List<Opportunity> opportunityRecords=new List<Opportunity>(); 
        System.debug('inside After');
    for (ContentVersion cv : trigger.new)
    {
         System.debug('inside After1'+ cv);
        if(cv.Guest_Record_fileupload__c != null)
        {
             System.debug('inside After2');
            contenDocumentids.add(cv.ContentDocumentId);
            System.debug('inside After21'+cv.Id+'**'+cv);
        }
    }
     
        List<ContentDocumentLink> contDoc = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: contenDocumentids];
        for(ContentDocumentLink contDocumentLink :contDoc)
        {
             System.debug('inside After3'+contDocumentLink.LinkedEntityId+'***'+contDocumentLink);
        	opportunityId.add(contDocumentLink.LinkedEntityId);
            System.debug('inside After31'+opportunityId);
        }
        
        List<Opportunity> opp = [SELECT Id,Name,RW_AreFilesVisibleToGuest__c FROM Opportunity WHERE id IN: opportunityId];
        for(Opportunity opportunity : opp)
        {
             System.debug('inside After4');
            opportunity.RW_AreFilesVisibleToGuest__c ='Yes';
            opportunityRecords.add(opportunity);
        }
        
        if(opportunityRecords.size() >0)
        {
            System.debug('inside After5');
        update opportunityRecords;
        }
*/
    } 
    
}