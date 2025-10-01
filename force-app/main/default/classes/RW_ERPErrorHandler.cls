public class RW_ERPErrorHandler {
    
    public void afterinsert(List<ERP_Integration_Log__c> errorLogs){
                system.debug(System.Label.RW_Error_Admin_Mail);	

        List<string> adminEmails = System.Label.RW_Error_Admin_Mail.split(',');
        system.debug(adminEmails);	
        String dataErrorTemplate = 'Dear Team, <br/><br/>';
        dataErrorTemplate += 'Below Records have errored out due to data issue in the request, please do the needful<br/><br/><html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>API Type</th><th>Log Link</th></tr>';
        String ExceptionTemplate= 'Dear Team, <br/><br/>';
        ExceptionTemplate +=  'Below Records have errored out due to connection issue to the API, It will be tried to reprocess again<br/><br/><html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>API Type</th><th>Log Link</th></tr>';
        string url = System.Label.RW_Production_Url;
       system.debug(errorLogs+'MK');
        integer errcount =0;
        integer excount = 0;
        for(ERP_Integration_Log__c erp : errorLogs){
            system.debug(erp.id);
                        system.debug(erp.Status__c+' '+erp.Error_Type__c);
system.debug(erp.Status__c == 'Failure' && erp.Error_Type__c == 'Timeout Error');
            if(erp.Status__c == 'Failure' &&erp.Error_Type__c == 'Data Error'){
                errcount++;
                dataErrorTemplate += '<tr><td>'+erp.API_Name__c+'</td><td><a href="'+url+erp.Id+'">View</a></td></tr>';
            }else if(erp.Status__c == 'Failure' && erp.Error_Type__c == 'Timeout Error'){
                excount++;
                ExceptionTemplate +='<tr><td>'+erp.API_Name__c+'</td><td><a href="'+url+erp.Id+'">View</a></td></tr>';
                                system.debug(ExceptionTemplate);

            }
        }
        
        dataErrorTemplate += '</table></body> <br/><br/></html>';
        
        dataErrorTemplate += 'Thanks,<br/>';
        
        dataErrorTemplate += ' Runwal Cares.';
        ExceptionTemplate += '</table></body> <br/><br/></html>';
        
        ExceptionTemplate += 'Thanks,<br/>';
        
        ExceptionTemplate += ' Runwal Cares.';
        String userName = UserInfo.getUserName();
        system.debug(dataErrorTemplate);
                system.debug(ExceptionTemplate);

        User activeUser = [Select Email From User where Username = : userName limit 1];
        system.debug(activeUser);
        String userEmail = activeUser.Email;
        List<string>toAdress = new List<string>();
        List<string>ccAdd = new List<string>();
        ccAdd.addAll(adminEmails) ;
        for(Integer i = ccAdd.size() - 1; i >= 0; i--) {
                 if(ccAdd.size()>0){  
                     if(ccAdd[i].equals(userEmail)) {
                     ccAdd.remove(i);}
                 }
            if(ccAdd.size()>0){
            if(ccAdd[i].equals(userName)) {
                ccAdd.remove(i);
            }
            }
        }
        if(userName != userEmail){
            toAdress.add(userEmail);
            toAdress.add(userName);
        }
        else{
            toAdress.add(userEMail);
        }
        Messaging.SingleEmailMessage[] messages1 =  new List<Messaging.SingleEmailMessage>(); 
        if(errcount>0){
            system.debug('err'+errcount);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.subject ='Error in sending  Data to SAP';
        mail.setHtmlBody(dataErrorTemplate);
        mail.setToAddresses(toAdress);
        mail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
        if(ccAdd.size()>0)
            mail.setCcAddresses(ccAdd);
        messages1.add(mail);
        }
        
        
        if(excount>0){
                        system.debug('ex'+excount);

        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        mail1.subject ='Error in sending  Data to SAP';
        mail1.setHtmlBody(ExceptionTemplate);
        mail1.setToAddresses(adminEmails);
        mail1.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
            messages1.add(mail1);
        }
        if(messages1.size()>0){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages1);
        system.debug('Messaging ' + results[0]);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else 
        {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        }
    }
    public void afterUpdate(List<ERP_Integration_Log__c> errorLogs){
        List<string> adminEmails = System.Label.RW_Error_Admin_Mail.split(',');
        Integer retryCount = Integer.valueOf( SYstem.Label.RW_Max_Retry	);
        String errorReprocessed = 'Dear Team, <br/><br/>';
        errorReprocessed += 'Below Records have been reprocessed successfully<br/><br/><html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>API Type</th><th>Log Link</th></tr>';
        String maxRetry= 'Dear Team, <br/><br/>';
        maxRetry +=  'Below Records have reached max reprocessing count, please contact SAP team<br/><br/><html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><table><tr><th>API Type</th><th>Log Link</th></tr>';
        string url = System.Label.RW_Production_Url;
        integer reprocount = 0;
        integer errCount = 0;
        for(ERP_Integration_Log__c erp : errorLogs){
            if(erp.Status__c == 'Reprocessed'  && erp.Error_Type__c == 'Timeout Error' ){
                errorReprocessed += '<tr><td>'+erp.API_Name__c+'</td><td><a href="'+url+erp.Id+'">View</a></td></tr>';
                reprocount++;
            }else if(erp.Status__c == 'Failure' && erp.Retry_Count__c >= retryCount){
                maxRetry += '<tr><td>'+erp.API_Name__c+'</td><td><a href="'+url+erp.Id+'">View</a></td></tr>';
                errCount++;
            }
        }
             
        
             
        errorReprocessed += '</table></body></html> <br/><br/>';
                errorReprocessed += 'Thanks,<br/>';
                errorReprocessed += ' Runwal Cares.';
        maxRetry += '</table></body></html> <br/><br/>';
                maxRetry += 'Thanks,<br/>';
                maxRetry += ' Runwal Cares.';
        Messaging.SingleEmailMessage[] messages1 =  new List<Messaging.SingleEmailMessage>(); 
        if(reprocount>0){
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.subject ='Below errors are resolved and data is synced with SAP';
        mail.setHtmlBody(errorReprocessed);
        mail.setToAddresses(adminEmails);
        mail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
         messages1.add(mail);
        }
        
         if(errCount>0){
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.subject ='Below errors are reached max retry limit';
        mail.setHtmlBody(maxRetry);
        mail.setToAddresses(adminEmails);
        mail.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
         messages1.add(mail);
        }
         Messaging.SendEmailResult[] results = Messaging.sendEmail(messages1);
      //  system.debug('Messaging ' + results[0]);
        
        if (results.size()>0 && results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else 
        {
            System.debug('The email failed to send: ' + results);
        }
    }
    
}