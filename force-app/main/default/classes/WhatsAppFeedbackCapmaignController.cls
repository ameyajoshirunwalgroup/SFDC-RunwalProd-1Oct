public class WhatsAppFeedbackCapmaignController {
    
    
    @AuraEnabled
    public static String whatsAppCapmaign(String campId){
        WhatsApp_Campaign__c wc = [SELECT Id, Name, RecordType.Name, Member_Type__c, Status__c, Active__c, Email_Template__c FROM WhatsApp_Campaign__c WHERE Id =: campId LIMIT 1];
        String response;
        if(wc.RecordType.Name == 'Email'){
            if(wc.Status__c == 'Campaign Sent'){
                    return 'This Campaign was already sent!';
            }else{
                response =  emailCapmaign(wc.Name, wc.Member_Type__c, wc.Email_Template__c);
            }
        }else{
            if(wc.Active__c){
                if(wc.Status__c == 'Campaign Sent'){
                    return 'This Campaign was already sent!';
                }else{
                    if(wc.RecordType.Name == 'Customized'){
                        response =  customizedCapmaign(wc.Name, wc.Member_Type__c);
                    }else if(wc.RecordType.Name == 'Filtered'){
                        response = filteredCapmaign(wc.Name);
                    }
                }
            }else{
                return 'This Campaign is Inactive!';
            }
        }
        return response;
    }
    
    @AuraEnabled
    public static void updateCampaign(String campId, String status){
        WhatsApp_Campaign__c wc = new WhatsApp_Campaign__c();
        wc.Id = campId;
        wc.Status__c = status;
        update wc;
    }
    
    @AuraEnabled
    public static String customizedCapmaign(String campName, String memType){
        System.debug('customizedCapmaign');
        List<WhatsApp_Campaign_Member__c> mems = [SELECT Id, Member_Id__c FROM WhatsApp_Campaign_Member__c WHERE WhatsApp_Campaign__r.Name =: campName];
        List<String> recIds = new List<String>();
        for(WhatsApp_Campaign_Member__c mem : mems){
            recIds.add(mem.Member_Id__c);
        }
        List<String> mobileNums = new List<String>();
        if(memType == 'Opportunity'){
            List<Opportunity> opps = [SELECT Id, Name, RW_Mobile_No__c FROM Opportunity WHERE Id =: recIds];
            for(Opportunity opp : opps){
                mobileNums.add(opp.RW_Mobile_No__c);
            }
        }else if(memType == 'Account'){
            List<Account> accs = [SELECT Id, Mobile_No__c FROM Account WHERE Id =: recIds];
            for(Account acc : accs){
                mobileNums.add(acc.Mobile_No__c);
            }
        }else if(memType == 'Lead'){
            List<Lead> leads = [SELECT Id, RW_Mobile_No__c FROM Lead WHERE Id =: recIds];
            for(Lead ld : leads){
                mobileNums.add(ld.RW_Mobile_No__c);
            }
        }else if(memType == 'Booking'){
            List<Booking__c> bkgs = [SELECT Id, Opportunity__r.RW_Mobile_No__c FROM Booking__c WHERE Id =: recIds];
            for(Booking__c bkg : bkgs){
                mobileNums.add(bkg.Opportunity__r.RW_Mobile_No__c);
            }
        }
        if(mobileNums.size() > 0){
            try{
                for(String mob : mobileNums){
                    System.debug('mob: ' + mob);
                    if(!Test.isRunningTest()){
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,campName,null,null,null,null,null,null,null,'+91',mob,'generic_feedback');
                    }
                    
                }
            }catch(Exception e){
                system.debug('Exception :: '+e);
            }
            
            return 'Success';
        }else{
            return 'Fail';
        }
        
    }
    
    @AuraEnabled
    public static String filteredCapmaign(String campName){
        
        WhatsApp_Campaign__c wc = [SELECT Id, Field_1__c, Field_2__c, Field_3__c, Field_4__c, Operator_1__c, Operator_2__c, Operator_3__c, Operator_4__c, Value_1__c, Value_2__c, Value_3__c, Value_4__c FROM WhatsApp_Campaign__c WHERE Name =: campName LIMIT 1];

        String qry = 'SELECT Id, Name, RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c FROM Opportunity WHERE';
        
        /*String qry;
        if(!Test.isRunningTest()){
            qry = 'SELECT Id, Name, RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c FROM Opportunity WHERE';
        }else{
            qry = 'SELECT Id, Name, RW_Mobile_No__c, Booking__r.RW_Country_Phone_Code__c FROM Opportunity';
        }*/
        
        if(wc.Field_1__c != null){
            qry += ' ' + operator(wc.Field_1__c, wc.Operator_1__c, wc.Value_1__c);
        }
        if(wc.Field_2__c != null){
            qry += ' AND ' + operator(wc.Field_2__c,wc.Operator_2__c, wc.Value_2__c);
        }
        if(wc.Field_3__c != null){
            qry += ' AND ' + operator(wc.Field_3__c, wc.Operator_3__c, wc.Value_3__c);
        }
         if(wc.Field_4__c != null){
            qry += ' AND ' + operator(wc.Field_4__c, wc.Operator_4__c, wc.Value_4__c);
        }
        System.debug('qry: ' + qry);
        List<Opportunity> opps = Database.query(qry);
        System.debug('opp: ' + opps.size());
        System.debug('opp: ' + opps);
        if(opps.size() > 0){
            try{
                for(Opportunity opp : opps){
                    if(!Test.isRunningTest()){
                        SendWhatsAppMsg.methodToSendWhatsAppMsgBatch(null,campName,null,null,null,null,null,null,null,opp.Booking__r.RW_Country_Phone_Code__c,opp.RW_Mobile_No__c,'generic_feedback');
                    }
                    
                }
            }catch(Exception e){
                system.debug('Exception :: '+e);
            }
            
            return 'Success';
        }else{
            return 'Fail';
        }
    }
    
    public static String operator(String fld, String opr, String val){
        String retStr;
        if(opr == 'equals'){
            retStr = fld + ' = ' + '\'' + val + '\'';
        }else if(opr == 'not equal to'){
            retStr =  fld + ' != ' + val;
        }else if(opr == 'starts with'){
            retStr = fld + ' like ' + ''+ val +'%\'';
        }else if(opr == 'contains'){
            retStr = fld + ' like ' + '\'%'+ val +'%\'';
        }else if(opr == 'does not contain'){
            retStr = '(NOT ' + fld + ' like ' + '\'%'+ val +'%\')';
        }else if(opr == 'less than'){
            retStr = fld + ' < ' + val;
        }else if(opr == 'less or equal'){
            retStr = fld + ' <= ' + val;
        }else if(opr == 'greater than'){
            retStr = fld + ' > ' + val;
        }else if(opr == 'greater or equal'){
            retStr = fld + ' >= ' + val;
        }else if(opr == 'includes'){
            List<String> lstVal = val.split(',');
            String newStr;
            for(String str : lstVal){
                if(newStr == null){
                    newStr = '(' + fld + ' = ' + '\'' + str + '\'';
                }else{
                    newStr += ' OR ' + fld + ' = ' + '\'' + str + '\'';
                }  
            }
            newStr += ')';
            //retStr = fld + ' IN: ' + newlstVal;
            retStr = newStr;
        }else if(opr == 'excludes'){
            List<String> lstVal = val.split(',');
            String newStr;
            for(String str : lstVal){
                if(newStr == null){
                    newStr = '(' + fld + ' != ' + '\'' + str + '\'';
                }else{
                    newStr += ' AND ' + fld + ' != ' + '\'' + str + '\'';
                }  
            }
            newStr += ')';
            retStr = newStr;
            //retStr = fld + ' NOT IN: ' + lstVal;
        }
        return retStr;
    }
    
    @AuraEnabled
    public static String emailCapmaign(String campName, String memType, String templateName){
        System.debug('customizedCapmaign');
        List<WhatsApp_Campaign_Member__c> mems = [SELECT Id, Member_Id__c FROM WhatsApp_Campaign_Member__c WHERE WhatsApp_Campaign__r.Name =: campName];
        List<String> recIds = new List<String>();
        for(WhatsApp_Campaign_Member__c mem : mems){
            recIds.add(mem.Member_Id__c);
        }
        List<String> emails = new List<String>();
        if(memType == 'Opportunity'){
            List<Opportunity> opps = [SELECT Id, Name, RW_Email__c FROM Opportunity WHERE Id =: recIds];
            for(Opportunity opp : opps){
                emails.add(opp.RW_Email__c);
            }
        }else if(memType == 'Account'){
            List<Account> accs = [SELECT Id, RW_Email__c FROM Account WHERE Id =: recIds];
            for(Account acc : accs){
                emails.add(acc.RW_Email__c);
            }
        }else if(memType == 'Lead'){
            List<Lead> leads = [SELECT Id, Email FROM Lead WHERE Id =: recIds];
            for(Lead ld : leads){
                emails.add(ld.Email);
            }
        }else if(memType == 'Booking'){
            List<Booking__c> bkgs = [SELECT Id, Primary_Applicant_Email__c FROM Booking__c WHERE Id =: recIds];
            for(Booking__c bkg : bkgs){
                emails.add(bkg.Primary_Applicant_Email__c);
            }
        }
        
        if(emails.size() > 0){
            try{
                Database.executeBatch(new SendCampaignEmailsBatch(emails, templateName), 100);
            }catch(Exception e){
                system.debug('Exception :: '+e);
            }
            return 'Success';
        }else{
            return 'Fail';
        }
        /*if(emails.size() > 0){
            try{
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                String orgEmailAddress = Utility.getOrgWideEmailAddress();
                EmailTemplate template = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where Name =: templateName];
                for(String email : emails){
                    Messaging.SingleEmailMessage Message = new Messaging.SingleEmailMessage();
                    String htmlBody = template.HtmlValue;
                    String plainTextBody = template.Body;
                    message.toAddresses = new List<String>{email};
                    message.subject = template.Subject;
                    message.setTemplateId(template.Id);
                    message.setHtmlBody(htmlBody);   
                    message.setPlainTextBody(plainTextBody);
                    message.setOrgWideEmailAddressId(orgEmailAddress);
                    emailList.add(message);
                }
                if(!Test.isRunningTest()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
                }
            }catch(Exception e){
                system.debug('Exception :: '+e);
            }
            
            return 'Success';
        }else{
            return 'Fail';
        }*/
        
    }

}