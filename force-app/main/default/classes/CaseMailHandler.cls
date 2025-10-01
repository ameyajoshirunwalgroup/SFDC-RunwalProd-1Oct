public class CaseMailHandler {
     public static void CaseCategorizationMail(Set<Id> CaseId) 
     {
       List<Case> CaseList = [SELECT Id,CaseNumber,ContactEmail,RecordTypeId,RW_Reporting_2_Email__c,Description ,SuppliedEmail,Subject,Status,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Complaint_Sub_Subtype__c,Account.Name,owner.name,ClosedDate,CSAT_Feedback_Remark__c,CSAT_Feedback_Rating__c,Owner.Email  FROM Case WHERE Id IN :CaseId];
       Id feedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
       String bodynew = '';
       List<Messaging.SingleEmailMessage> masterListMailnew = new List<Messaging.SingleEmailMessage>(); 
       Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
        List<String> customertoaddress = new List<String>();
            List<String> customerccaddress = new List<String>();
            List<String> Rmtoaddress = new List<String>();
            
          
       for (Case c : CaseList) {
           if(String.isNotBlank(c.owner.Email))
            {
                Rmtoaddress.add(c.owner.Email);
            }
           email2.setToAddresses(Rmtoaddress);
             if (c.RecordTypeId == feedbackId) {
                 bodynew+='Dear '+ c.Owner.Name+' ,<br/><br/>'+
                'Please Categorise the case by filling fields Complaint Type and Complaint subType <br/><br/>'
                +'Here are the case details for your perusal-<br/><br/>'+
                '<table style="border-collapse: collapse;width: 50%;height: 75px;">'+
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Case ID</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.CaseNumber+'</td>'+
                '</tr>'+
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Primary Category</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.RW_Complaint_Type__c+'</td>'+
                '</tr>'+ 
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Status </th>'+          
                '<th style="border:1px solid;text-align: center;">'+c.Status+'</td>'+
                '</tr>'+ 
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Assigned to</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.Owner.Name+'</td>'+
                '</tr>'+
                
                '</table><br/>'+
                
       'Click on the button to categorize the case. <a href="https://runwal.lightning.force.com/lightning/r/case/' + c.Id + '/view">Click here</a> to Categorise.<br/><br/>';
                 
             }
            email2.setSubject('Runwal : Case #'+c.CaseNumber+'|Categoreise L1/L2 ');
            email2.setHtmlBody(bodynew);
            masterListMailnew.add(email2);
           if (masterListMailnew != null && !masterListMailnew.isEmpty()) {
           // Messaging.sendEmail(masterListMailnew);
        }
       }
     }
    public static void CaseClosureEmailCustomer(Set<Id> CaseId) {
        List<Case> CaseList = [SELECT Id,AccountId,Account.PersonEmail,CaseNumber,ContactEmail,RecordTypeId,RW_Reporting_2_Email__c,Description ,SuppliedEmail,Subject,Status,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Complaint_Sub_Subtype__c,Account.Name,owner.name,ClosedDate,CSAT_Feedback_Remark__c,CSAT_Feedback_Rating__c,Owner.Email  FROM Case WHERE Id IN :CaseId AND Account.Stop_Case_Emails__c = false]; //Added Account.Stop_Case_Emails__c = false by Vinay 17-07-2025 
        String body = '';
        String bodynew = '';
        Boolean CheckAccount=false;
        List<Messaging.SingleEmailMessage> masterListMail = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> masterListMailnew = new List<Messaging.SingleEmailMessage>();
        Id feedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Feedback').getRecordTypeId();
        Id visitfeedbackId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Visit Feedback').getRecordTypeId();
        Id CustomerCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        for (Case c : CaseList) {
             
          
            //String formattedToken = EmailMessages.getFormattedThreadingToken(c.Id);
            List<String> customertoaddress = new List<String>();
            List<String> customerccaddress = new List<String>();
            List<String> Rmtoaddress = new List<String>();
            
            if (String.isNotBlank(c.ContactEmail)){
                customertoaddress.add(c.ContactEmail);
            }
            if (String.isNotBlank(c.SuppliedEmail) && (!c.SuppliedEmail.contains('@runwalgroup.in') || !c.SuppliedEmail.contains('@runwal.com'))  ){
                customertoaddress.add(c.SuppliedEmail);
            }

            if(String.isBlank(c.ContactEmail) && String.isBlank(c.SuppliedEmail)){ // Added by Vinay 08-04-2025
                System.debug('c.Account.PersonEmail: ' + c.Account.PersonEmail);
                customertoaddress.add(c.Account.PersonEmail);
            }
            
            /*if (String.isNotBlank(c.RW_Reporting_2_Email__c)){
                customerccaddress.add(c.RW_Reporting_2_Email__c);
            }
            if(String.isNotBlank(c.owner.Email))
            {
                Rmtoaddress.add(c.owner.Email);
            }*/
            
            if(c.Description == null){
                c.Description = ' ';
            }
            if(customertoaddress.isEmpty()){
                customertoaddress.add('luv.dubey@stetig.in');
            }
             OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress 
                                      where Address =: 'runwalcare@runwalgroup.in'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //Messaging.SingleEmailMessage email2 = new Messaging.SingleEmailMessage();
            email.setToAddresses(customertoaddress);
           // email.setCcAddresses(customerccaddress);
             
            if (owea.size() > 0) {
                email.setOrgWideEmailAddressId(owea[0].id);
            }
           // email2.setToAddresses(Rmtoaddress);
            if (c.RecordTypeId == feedbackId || c.RecordTypeId==CustomerCase) { // Replace 'YOUR_RECORD_TYPE_ID_FOR_FEEDBACK' with the actual Id of your 'Feedback' record type
                email.setSubject('Feedback on Your Recent Call with Our Relationship Manager: [Case #'+c.CaseNumber+']');
                
            } else {
                email.setSubject('Runwal : Case #'+c.CaseNumber+'| Status - Closed. ');
            }
            if (c.RecordTypeId == visitfeedbackId) { // Replace 'YOUR_RECORD_TYPE_ID_FOR_FEEDBACK' with the actual Id of your 'Feedback' record type
                email.setSubject('Visit Interaction Feedback');
                
            } 
            body = '';
            if (c.RecordTypeId == visitfeedbackId) {
                body += 'Dear Customer ,<br/><br/>'+
                    'Greetings from Runwal Group.<br/><br/>'
                    +'We would like to inform you that the below service request has been closed.<br/><br/>'+
                    '<table style="border-collapse: collapse;width: 50%;height: 75px;">'+
                    '<tr style="border:1px solid;">'+
                    '<th style="border:1px solid;">Case ID</th>'+
                    '<th style="border:1px solid;text-align: center;">'+c.CaseNumber+'</td>'+
                    '</tr>'+
                    '<tr style="border:1px solid;">'+
                    '<th style="border:1px solid;">Primary Category</th>'+
                    '<th style="border:1px solid;text-align: center;">'+c.RW_Complaint_Type__c+'</td>'+
                    '</tr>'+ 
                    '<tr style="border:1px solid;">'+
                    '<th style="border:1px solid;">Status </th>'+          
                    '<th style="border:1px solid;text-align: center;">'+c.Status+'</td>'+
                    '</tr>'+ 
                    '<tr style="border:1px solid;">'+
                    '<th style="border:1px solid;">Assigned to</th>'+
                    '<th style="border:1px solid;text-align: center;">'+c.Owner.Name+'</td>'+
                    '</tr>'+
                    
                    '</table><br/>'+
                    'Your feedback is very valuable to us, as it helps us serve you better. Please <a href="https://runwal.my.salesforce-sites.com/csat/VisitFeedbackPage?id=' + c.Id + '">click here</a> to share your feedback.<br/><br/>'
                    +
                    'Feel free to contact your Relationship Manager if you have any questions/concerns:<br/><br/>'+
                    'Thank you for choosing Runwal Group!</b><br/>'+
                    'Warm Regards,<br/>'+
                    'Runwal CRM Team<br/>';
            }
            else
            {
                 body = '';
                body += 'Dear Valued Customer,<br/><br/>';
                body += 'Greetings from Runwal Group!<br/><br/>';
                body += 'We trust that our relationship manager, ' + c.Owner.Name + ', successfully resolved your query. We would greatly appreciate your feedback on your recent interaction.<br/><br/>';
                body += 'Please click on the link below to provide your valuable feedback:<br/>';
                body += '<a href="https://runwal.my.salesforce-sites.com/csat/CaseFeedbackForm?id=' + c.Id + '">click here</a><br/><br/>';
                body += 'Your feedback is crucial as it helps us enhance our service quality.<br/><br/>';
                body += 'Thank you for choosing Runwal Group! We look forward to receiving your feedback.<br/><br/>';
                body += 'Warm Regards,<br/>';
                body += 'Runwal CRM Team<br/>';

            }
           
            email.setHtmlBody(body); 
            masterListMail.add(email);
            c.CSAT_Feedback_Status__c = 'Sent To Customer'; //Added by Vinay 09-04-2025
           
        }
        
            Messaging.sendEmail(masterListMail);
      
        
           }              
    public static void CaseIsReopened(Set<Id> CaseId) {
        Boolean CheckAccount=false;
        System.debug('inside reopened case mail');
        List<Case> CaseList = [SELECT Id,CaseNumber,RW_Reporting_2_Email__c,owner.Email,Description,ContactEmail,SuppliedEmail,Subject,Status,RW_Complaint_Type__c,RW_Complaint_SubType__c,RW_Complaint_Sub_Subtype__c,Account.Name,owner.name,ClosedDate,CSAT_Feedback_Remark__c,CSAT_Feedback_Rating__c,
                               Account.PersonEmail FROM Case WHERE Id IN :CaseId];
        
        List<Messaging.SingleEmailMessage> masterListMail = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress 
                                      where Address =: 'runwalcare@runwalgroup.in'];
        Map<Id, String> ownerIdToManagerEmail = new Map<Id, String>();
        Set<Id> caseOwnerIds = new Set<Id>();
        for (Case c : CaseList) {
            caseOwnerIds.add(c.OwnerId);
        }
        System.debug('inside reopened case mail2');
        // Query for Case Owner's Manager Email
        // u.ManagerId ?? ''
        for (User u : [SELECT Id, Email, Manager.Email FROM User WHERE Id IN :caseOwnerIds]) {
            ownerIdToManagerEmail.put(u.Id, u.Manager.Email ?? '');
        }          
        
        for (Case c : CaseList) {
           
             System.debug('inside reopened case loop');
            // String formattedToken = EmailMessages.getFormattedThreadingToken(c.Id);
            List<String> customertoaddress = new List<String>();
            List<String> customerccaddress = new List<String>();
            
           
            if (String.isNotBlank(c.owner.Email) && c.SuppliedEmail != null && (!c.SuppliedEmail.contains('@runwalgroup.in') || !c.SuppliedEmail.contains('@runwal.com')) ){ //Added (c.SuppliedEmail != null) by coServe 04-10-2024
                customertoaddress.add(c.owner.Email);
            }
            
           /* if (String.isNotBlank(c.RW_Reporting_2_Email__c)){
                customerccaddress.add(c.RW_Reporting_2_Email__c);
            }*/
            if (ownerIdToManagerEmail.containsKey(c.OwnerId) && c.SuppliedEmail != null && (!c.SuppliedEmail.contains('@runwalgroup.in') || !c.SuppliedEmail.contains('@runwal.com'))) { //Added (c.SuppliedEmail != null) by coServe 07-10-2024
                String managerEmail = ownerIdToManagerEmail.get(c.OwnerId);
                if (String.isNotBlank(managerEmail)) {
                    customerccaddress.add(managerEmail);
                }
            }
            
            if(c.Description == null){
                c.Description = ' ';
            }
            if(customertoaddress.isEmpty()){
                //customertoaddress.add('luv.dubey@stetig.in'); //Commented by Vinay 31-12-2024
                customertoaddress.add(c.Account.PersonEmail); //Added by Vinay 31-12-2024
            }
            Messaging.SingleEmailMessage emailToMember = new Messaging.SingleEmailMessage();
            //Messaging.SingleEmailMessage emailToCC = new Messaging.SingleEmailMessage();
            
            if (owea.size() > 0) {
                emailToMember.setOrgWideEmailAddressId(owea[0].Id);
                //emailToCC.setOrgWideEmailAddressId(owea[0].Id);
            }
            
            emailToMember.setToAddresses(customertoaddress);
           // emailToCC.setToAddresses(customerccaddress);
             emailToMember.setCcAddresses(customerccaddress);
            
            emailToMember.setSubject('Runwal : Case #'+c.CaseNumber+'| Status - Reopened. '); 
            //emailToCC.setSubject('Runwal : Case #'+c.CaseNumber+'| Status - Reopened. '); 
            
            String body = '';
            body += 'Dear Customer ,<br/><br/>'+
                'Greetings from Runwal Group.<br/><br/>'
                +'We would like to inform you that your below service request has been reopened.<br/><br/>'+
                '<table style="border-collapse: collapse;width: 50%;height: 75px;">'+
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Case ID</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.CaseNumber+'</td>'+
                '</tr>'+
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Primary Category</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.RW_Complaint_Type__c+'</td>'+
                '</tr>'+   
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Status </th>'+          
                '<th style="border:1px solid;text-align: center;">'+c.Status+'</td>'+
                '</tr>'+ 
                '<tr style="border:1px solid;">'+
                '<th style="border:1px solid;">Assigned to</th>'+
                '<th style="border:1px solid;text-align: center;">'+c.Owner.Name+'</td>'+
                '</tr>'+
                
                '</table><br/>'+
                'Feel free to contact your Relationship Manager if you have any questions/concerns.<br/>'+
                'Thank you for choosing Runwal Group<br/><br/>'+
                'Warm Regards,<br/>'+
                'Runwal CRM Team<br/>';
            
            emailToMember.setHtmlBody(body); 
           // emailToCC.setHtmlBody(body);
            
            masterListMail.add(emailToMember);
            //masterListMail.add(emailToCC);
        }
       
            Messaging.sendEmail(masterListMail);
       
        
    }  
    
    
    public static void UpdateL3(Set<Id> CaseId){
        List<Case> CaseList = [SELECT Id,Current_Stage__c  FROM Case WHERE Id IN :CaseId];
        List<Case>UpdateList = new List<Case>();        
        
        for (Case c : CaseList) {
            c.Current_Stage__c = 'CP-L3';
            UpdateList.add(c); 
        }
        
        update UpdateList;
        
        
    }
   public static void UpdateLastCloseDate(Set<Id> CaseId){
        List<Case> CaseList = [SELECT Id,Last_Closed_Date__c,ClosedDate  FROM Case WHERE Id IN :CaseId];
        List<Case>UpdateList = new List<Case>();        
        
        for (Case c : CaseList) {
            c.Last_Closed_Date__c = c.ClosedDate;
            UpdateList.add(c); 
        }
        
        update UpdateList;
        
        
    }
 
}