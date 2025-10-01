public without sharing class LoanController{   
    public static void loanInsert(List<Loan__c> listLoans){
        Set<ID> projectIds = new Set<ID>();
        Set<id> SetParent = new Set<id>();
        for(Loan__c ar : listLoans){
            SetParent.add(ar.RW_Booking__c);
        }
        
        Map<Id, Booking__c> bookingMap =new Map<Id,Booking__c>([select id,Wing__c,Project__c,Unit_No__c,Opportunity__c,(select id, name,RW_Project_Name__c, RW_Pari_Passu__c, RW_APF__c, RW_Loan_Record_Status__c from Loans__r),(SELECT Id,RW_Welcome_Call_Status__c,RW_Booking__c FROM Welcome_Calls__r) from Booking__c where id in:SetParent ]);  
        
        for(Booking__c bk : bookingMap.values()){
            
            projectIds.add(bk.Project__c);
        }
        
        Map<ID, Project__c> projMap = New Map<ID, Project__c>([SELECT ID, (SELECT ID,Name,RW_APF__c,RW_Project_Name__c,RW_Bank_Name__c FROM Loans__r),(SELECT ID, Name, RW_Bank_Name__c FROM APF__r) FROM Project__c WHERE ID IN : projectIds]);
        
        List<Loan__c> listOfLoan  = new List<Loan__c>();
        
        
        
        for (Loan__c ar : listLoans){
            Booking__c booking1 = bookingMap.get(ar.RW_Booking__c);
            List<Loan__c> loanList = new List<Loan__c>();
            if(booking1!=null && booking1.Loans__r!=null){
                for( Loan__c loans: booking1.Loans__r){
                    if(loans.RW_Loan_Record_Status__c!='Loan Closed'){
                        loanList.add(loans); 
                    }
                }  
            }
            if(loanList!=null && loanList.size()==1){
                if (loanList[0].RW_Pari_Passu__c == false){                   
                    ar.addError('There is an active Loan record for this Booking');        
                } 
                
            }
            
            if(loanList!=null && loanList.size()==2){
                ar.addError('There are two active Loan record for this Booking');                 
            }
        }
    }
    public static void sendEmailAfterLoanClosed(List<Loan__c> loans, Map<id,Loan__c> oldLoanMap){
        try{
            Set<id> Bookings = new Set<id>();
            Set<id> Loanids = new Set<id>();
            for(Loan__c ar : loans){  
                if(ar.RW_Loan_Record_Status__c == 'Loan Closed'){
                    Bookings.add(ar.RW_Booking__c);
                    Loanids.add(ar.Id);
                }
            }
            
            Map<Id,Loan__c> mapOfloan = new Map<Id,Loan__c>();
            List<Loan__c> loanRecord = [select id, name,RW_Booking__r.Name, RW_Booking__r.Unit_No__r.Name, RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c, RW_Booking__r.Primary_Applicant_Name__c from Loan__c where id IN: Loanids];
            for(Loan__c lc :loanRecord){
                mapOfloan.put(lc.id, lc);
            }
            
            List<Booking__c> bookingRecord = [select id,Name,Project__c,(select id, name,RW_Project_Name__c, RW_Pari_Passu__c, RW_APF__c, RW_Loan_Record_Status__c from Loans__r),Project__r.CRMHead__r.Email,Sales_Manager__r.Email, Unit_No__r.Relationship_Manager__r.RM_Email__c,Project__r.Sales_Site_Head__r.Email from Booking__c where id in:Bookings ];
            List<String> emailsToSend = new List<String>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<String> errorMessages = new List<String>();
            
            string RManager = '';
            string SManger = '';
            string CRMLead = '';
            string SHead = '';
            
            for(Booking__c emails: bookingRecord){
                if(emails.Unit_No__r.Relationship_Manager__r.RM_Email__c !=null){
                    Rmanager =  emails.Unit_No__r.Relationship_Manager__r.RM_Email__c;
                    emailsToSend.add(Rmanager);
                }
                
                if(emails.Sales_Manager__r.Email !=null){
                    SManger = emails.Sales_Manager__r.Email;
                    emailsToSend.add(SManger);
                }
                
                if(emails.Project__r.CRMHead__r.Email !=null){
                    CRMLead = emails.Project__r.CRMHead__r.Email;
                    emailsToSend.add(CRMLead);
                }        
            } 
            
            
            for(Loan__c lc : loans){
                if(lc.RW_Loan_Record_Status__c == 'Loan Closed' && lc.RW_Loan_Record_Status__c != oldLoanMap.get(lc.Id).RW_Loan_Record_Status__c){
                    EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='Loan_Closed'];
                    String htmlBody = template.HtmlValue;
                    String plainTextBody = template.Body;
                    
                    if(mapOfloan.containsKey(lc.Id)){   
                        if( mapOfloan.get(lc.Id).Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.Name}', mapOfloan.get(lc.Id).Name);
                      
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.Name}', '(Loan Name Not Found)');
                        }               
                        if( mapOfloan.get(lc.Id).RW_Booking__r.Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Name}', mapOfloan.get(lc.Id).RW_Booking__r.Name);
                         
                        }else{
                         htmlBody = htmlBody.replace('{Loan__c.RW_Booking__r.Name}', '(Booking Not Found)');
                        }
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Unit_No__r.Name}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name);
                        
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Unit_No__r.Name}', '(Unit No Not Found)');
                        }
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c);
                        
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}', 'Team');
                        }
                        
                        if(mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c);
                                           
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', ' (Customer Not Found)');
                        }                    
                        
                                           
                        
                        if(mapOfloan.get(lc.Id).Name !=null){
                        plainTextBody = plainTextBody.replace('{!Loan__c.Name}', mapOfloan.get(lc.Id).Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.Name}', '(Loan Not Found)');
                        }  
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Name !=null){
                         plainTextBody= plainTextBody.replace('{!Loan__c.RW_Booking__r.Name}', mapOfloan.get(lc.Id).RW_Booking__r.Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Name}', '(Booking Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name !=null){
                          plainTextBody = plainTextBody.replace('{!Loan__c.RW_Unit_No__r.Name}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Unit_No__r.Name}', '(Unit No. Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c !=null){
                          plainTextBody= plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', '(Customer Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c !=null){
                          plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c);
                                                                               
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}', '(RM Not Found)');
                        }
                 
                        
                    }                   
                    
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = emailsToSend;
                    message.subject = template.Subject;
                    message.setTemplateId(template.Id);
                    message.setHtmlBody(htmlBody);   
                    message.setPlainTextBody(plainTextBody);
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);  
                }
                
            }
        }catch(Exception ex){
            
        }
        
    }
    
    public static void SendEmailOnNOCGeneration(List<Loan__c> loans,Map<id,Loan__c> loanOldMap){
        try{
            Set<id> Bookings = new Set<id>();
            Set<id> Loanids = new Set<id>();
            for(Loan__c ar : loans){  
                if(ar.RW_Loan_Record_Status__c == 'NOC Generated'){
                    Bookings.add(ar.RW_Booking__c);
                    Loanids.add(ar.Id);
                }
            }
            
            Map<Id,Loan__c> mapOfloan = new Map<Id,Loan__c>();
            List<Loan__c> loanRecord = [select id,name,RW_Booking__r.Name,RW_Booking__r.Unit_No__r.Name,RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c, RW_Booking__r.Primary_Applicant_Name__c from Loan__c where id IN: Loanids];
            for(Loan__c lc :loanRecord){
                mapOfloan.put(lc.id, lc);
            }
            
            List<Booking__c> bookingRecord = [select id,Name,Project__c,(select id, name,RW_Project_Name__c, RW_Pari_Passu__c, RW_APF__c, RW_Loan_Record_Status__c from Loans__r),Project__r.CRMHead__r.Email,Sales_Manager__r.Email, Unit_No__r.Relationship_Manager__r.RM_Email__c,Project__r.Sales_Site_Head__r.Email from Booking__c where id in:Bookings ];
            List<String> emailsToSend = new List<String>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<String> errorMessages = new List<String>();
            
            string RManager = '';
            string SManger = '';
            string CRMLead = '';
            string SHead = '';
            
            for(Booking__c emails: bookingRecord){
                if(emails.Unit_No__r.Relationship_Manager__r.RM_Email__c !=null){
                    Rmanager =  emails.Unit_No__r.Relationship_Manager__r.RM_Email__c;
                    emailsToSend.add(Rmanager);
                }
                
                if(emails.Sales_Manager__r.Email !=null){
                    SManger = emails.Sales_Manager__r.Email;
                    emailsToSend.add(SManger);
                }
                
                if(emails.Project__r.CRMHead__r.Email !=null){
                    CRMLead = emails.Project__r.CRMHead__r.Email;
                    emailsToSend.add(CRMLead);
                }         
            }
            
            
            
            for(Loan__c lc : loans){
                if(lc.RW_NOC_Generated__c == true && lc.RW_NOC_Generated__c != loanOldMap.get(lc.Id).RW_NOC_Generated__c){
                    EmailTemplate template = [SELECT Id, Name, Subject, HtmlValue, Body, DeveloperName FROM EmailTemplate Where DeveloperName='NOC_Generation'];
                    String htmlBody = template.HtmlValue;
                    String plainTextBody = template.Body;
                   
                     if(mapOfloan.containsKey(lc.Id)){   
                        if( mapOfloan.get(lc.Id).Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.Name}', mapOfloan.get(lc.Id).Name);
                      
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.Name}', '(Loan Name Not Found)');
                        }               
                        if( mapOfloan.get(lc.Id).RW_Booking__r.Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Name}', mapOfloan.get(lc.Id).RW_Booking__r.Name);
                         
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Name}', '(Booking Not Found)');
                        }
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Unit_No__r.Name}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name);
                        
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Unit_No__r.Name}', '(Unit No Not Found)');
                        }
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c);
                        
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}', 'Team');
                        }
                        
                        if(mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c !=null){
                        htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c);
                                           
                        }else{
                         htmlBody = htmlBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', ' (Customer Not Found)');
                        }                    
                        
                                           
                        
                        if(mapOfloan.get(lc.Id).Name !=null){
                        plainTextBody = plainTextBody.replace('{!Loan__c.Name}', mapOfloan.get(lc.Id).Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.Name}', '(Loan Not Found)');
                        }  
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Name !=null){
                         plainTextBody= plainTextBody.replace('{!Loan__c.RW_Booking__r.Name}', mapOfloan.get(lc.Id).RW_Booking__r.Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Name}', '(Booking Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name !=null){
                          plainTextBody = plainTextBody.replace('{!Loan__c.RW_Unit_No__r.Name}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Name);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Unit_No__r.Name}', '(Unit No. Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c !=null){
                          plainTextBody= plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', mapOfloan.get(lc.Id).RW_Booking__r.Primary_Applicant_Name__c);                                                         
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Primary_Applicant_Name__c}', '(Customer Not Found)');
                        }
                        
                         if(mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c !=null){
                          plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}',  mapOfloan.get(lc.Id).RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c);
                                                                               
                        }else{
                         plainTextBody = plainTextBody.replace('{!Loan__c.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Name__c}', '(RM Not Found)');
                        }
                 
                    }     
                    
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    //  message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                    message.toAddresses = emailsToSend;
                    message.subject = template.Subject;
                    message.setTemplateId(template.Id);
                    message.setHtmlBody(htmlBody);   
                    message.setPlainTextBody(plainTextBody);
                    message.setOrgWideEmailAddressId(Utility.getOrgWideEmailAddress());
                    Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    
                }
                
            }
        }catch(Exception ex){
            
        }
    }
    
    
    
    // modified by Aditya (Saasworx)
    public static void updateHLRM(List<Loan__c> newLoan, Map<Id,Loan__c> oldMap){
        List<Loan__c> lnsToUpadte = new List<Loan__c>();
        Set<Id> projectId=new Set<Id>();
        Set<String> bankName = new Set<String>();
        for(Loan__c loanObj:newLoan){
            if((oldMap == Null || (loanObj.RW_Bank_Preference_1__c != oldMap.get(loanObj.Id).RW_Bank_Preference_1__c) || 
                (loanObj.RW_Project_Name__c != oldMap.get(loanObj.Id).RW_Project_Name__c))){
                    if(loanObj.RW_Project_Name__c!=null){
                        projectId.add(loanObj.RW_Project_Name__c);
                    }
                    if(loanObj.RW_Bank_Preference_1__c!=null){
                        bankName.add(loanObj.RW_Bank_Preference_1__c);
                    }
           }
        }
        if(!projectId.isEmpty() && !bankName.isEmpty()){
            List<Home_Loan_RM__c> HLRMs = [SELECT Id, Name, Project__c,Bank_Name__c,Disbursement_RM_User__c, Reporting_1_Email__c, Reporting_2_Email__c,TL_Name__c, TL_Email__c, RM_Email__c FROM Home_Loan_RM__c 
                                          where Project__c IN: projectId and Bank_Name__c IN: bankName];
            Map<String, Home_Loan_RM__c> hlrmMap = new Map<String, Home_Loan_RM__c>();
            for(Home_Loan_RM__c HLRMObj: HLRMs){
                if(HLRMObj.Project__c!=null && HLRMObj.Bank_Name__c!=null){
                    String name = HLRMObj.Bank_Name__c + '-' + HLRMObj.Project__c;
                    hlrmMap.put(name,HLRMObj);
                }
            }
            for(Loan__c loanObj: newLoan){
                if(loanObj.RW_Project_Name__c!=null && loanObj.RW_Bank_Preference_1__c!=null){
                    String name = loanObj.RW_Bank_Preference_1__c + '-' + loanObj.RW_Project_Name__c;
                    if(hlrmMap.containsKey(name)){
                        loanObj.HL_RM__c = hlrmMap.get(name).Id;
                    }
                }
            }
        }
    }
    
    public static void updateBookingFundStatus(Set<Id> bkIds){
        try{
           Map<String, RM_Usernames__c> mapRM = RM_Usernames__c.getall();
            
           List<Booking__c> bkgs = [SELECT Id, Name, RW_RM_Email__c, RM_Name__c FROM Booking__c WHERE Id =: bkIds];
           List<Booking__c> bkgsToUpdate = new List<Booking__c>();
            for(Booking__c bkg : bkgs){
                bkg.Funding_Status__c = 'Self Funded';
                bkg.RW_Loan_Account_Number__c = null;
                bkg.RW_Loan_Amount__c = null;
                bkg.RW_Loan_Bank__c = null;
                bkg.Loan_Bank__c = null;
                bkg.RW_Loan_Sanction_Date__c = null;
                bkgsToUpdate.add(bkg);
            }
            update bkgsToUpdate;
            for(Booking__c bkg : bkgsToUpdate){
                Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
                emailMsg.setToAddresses(new List<String>{bkg.RW_RM_Email__c});
                emailMsg.setccaddresses(new List<String>{mapRM.get(bkg.RM_Name__c).RW_Reporting_1_Email__c, mapRM.get(bkg.RM_Name__c).RW_Reporting_2_Email__c});
                //emailMsg.setSenderDisplayName('Runwal Homes');
                emailMsg.setSubject('Bank to Self Fund');
                String body = 'Dear '+bkg.RM_Name__c+', <br/>';
                body += 'This is to inform you that the Booking <b>'+bkg.Name+'</b> has been changed from Bank Loan to Self Funding.<br/><br/>Thanks<br/>Runwal Homes';
                emailMsg.setHtmlBody(body);
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailMsg});
            }
        }catch(Exception ex){
            
        }
        
    }
    //Added by Vinay 15-02-2021 end
}