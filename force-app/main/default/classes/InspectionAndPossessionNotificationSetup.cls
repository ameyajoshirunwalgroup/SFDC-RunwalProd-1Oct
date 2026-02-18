global class InspectionAndPossessionNotificationSetup{
    
    global static void getInspPossDetails(list<Id> bookingIds){
        
        List<InspectionAndPossession__c> inspPossList = [SELECT Id,Name,Booking__c,Booking__r.Unit_No__r.Name,Booking__r.Project__r.Name, Booking__r.Sales_Manager__r.Email,Booking__r.Project__r.Sales_Site_Head__r.Email,Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, RW_Inspection_Status__c,Booking__r.Unit_No__r.RW_Param4__c,Booking__r.Primary_Applicant_Name__c FROM InspectionAndPossession__c WHERE Booking__c IN: bookingIds];
        
        
        Map<Id, Id> bokingIds= new Map<Id, Id>();
        Map<Id, Id> teamIds= new Map<Id, Id>();
        Map<Id, InspectionAndPossession__c> mapInsps = new Map<Id, InspectionAndPossession__c>();
        Set<string> teamTypSet = new Set<String>(); 
        
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message;  
        
        for(InspectionAndPossession__c insp: inspPossList){
            bokingIds.put(insp.Booking__r.Project__r.Id, insp.Booking__r.Project__r.Id);
            mapInsps.put(insp.Booking__r.Project__r.Id, insp);
            //System.debug('insp.RW_No_due_certificate__c ____' +insp.RW_No_due_certificate__c );
            if(insp.RW_Inspection_Status__c =='Inspection Scheduled' ){
                Set<String> teamSet = new Set<String>{'Project Team', 'RMs', 'CRM Team'};
                    teamTypSet.addAll(teamSet);
                if(teamSet.contains('RMs')){
                    if(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        message = EmailPreparation(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, insp.RW_Inspection_Status__c,insp.Booking__r.Unit_No__r.Name, insp.Booking__r.Project__r.Name, insp.Booking__r.Primary_Applicant_Name__c,insp.Booking__r.Unit_No__r.RW_Param4__c);
                        messages.add(message);
                        
                    }
                }
            }else if(insp.RW_Inspection_Status__c =='Home Score Initiated'){
                Set<String> teamSet = new Set<String>{'Facility Team', 'RMs', 'CRM Team'};
                    teamTypSet.addAll(teamSet);
                if(teamSet.contains('RMs')){
                    if(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        message = EmailPreparation(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, insp.RW_Inspection_Status__c,insp.Booking__r.Unit_No__r.Name, insp.Booking__r.Project__r.Name, insp.Booking__r.Primary_Applicant_Name__c,insp.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message);
                        
                    }
                }
            }else if(insp.RW_Inspection_Status__c =='Home Score Completed'){
                Set<String> teamSet = new Set<String>{'Facility Team', 'RMs', 'CRM Team'};
                    teamTypSet.addAll(teamSet);
                if(teamSet.contains('RMs')){
                    if(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        message = EmailPreparation(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, insp.RW_Inspection_Status__c,insp.Booking__r.Unit_No__r.Name, insp.Booking__r.Project__r.Name,  insp.Booking__r.Primary_Applicant_Name__c,insp.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message);
                        
                    }
                }
            }else if(insp.RW_Inspection_Status__c =='Snagging Initiated'){
                Set<String> teamSet = new Set<String>{'Project Team', 'RMs', 'CRM Team'};
                    teamTypSet.addAll(teamSet);
                if(teamSet.contains('RMs')){
                    if(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        message = EmailPreparation(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, insp.RW_Inspection_Status__c,insp.Booking__r.Unit_No__r.Name, insp.Booking__r.Project__r.Name, insp.Booking__r.Primary_Applicant_Name__c,insp.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message);
                        
                    }
                }
            }else if(insp.RW_Inspection_Status__c =='Snagging Completed'){
                Set<String> teamSet = new Set<String>{'Project Team', 'RMs', 'CRM Team'};
                    teamTypSet.addAll(teamSet);
                if(teamSet.contains('RMs')){
                    if(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null){
                        System.debug('RM____' +insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c );
                        message = EmailPreparation(insp.Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, insp.RW_Inspection_Status__c,insp.Booking__r.Unit_No__r.Name, insp.Booking__r.Project__r.Name, insp.Booking__r.Primary_Applicant_Name__c,insp.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                        
                    }
                }
            }else if(insp.RW_Inspection_Status__c =='Readiness Initiated'){
                Set<String> teamSet = new Set<String>{'Project Team', 'Facility Team', 'CRM Team', 'Team Lead'};
                    teamTypSet.addAll(teamSet);  
            }else if(insp.RW_Inspection_Status__c =='Readiness Completed'){
                Set<String> teamSet = new Set<String>{'Project Team', 'Facility Team', 'CRM Team', 'Team Lead'};
                    teamTypSet.addAll(teamSet);
            }
        }                                                  
        
        
        List<Team__c> teamsList = [SELECT Id, Project__c, Team_Type__c, Name FROM Team__c WHERE Project__c IN: bokingIds.values() AND Team_Type__c IN: teamTypSet];
        
        
        for(Team__c tm: teamsList){
            teamIds.put(tm.Id, tm.Project__c);
            
        } 
        List<Team_Members__c> temMembr = [SELECT Id,Email_Id__c, Name, Approver_Type__c, Counter__c, IsActive__c, Team__c,Team__r.Project__c, User_Active__c, User__c,User__r.Email FROM Team_Members__c WHERE Team__c IN: teamIds.keySet()]; 
        
        
        
        
        for(Team_Members__c temMem: temMembr){ 
            if(bokingIds.get(temMem.Team__r.Project__c) == teamIds.get(temMem.Team__c)){
                InspectionAndPossession__c insprec = mapInsps.get(temMem.Team__r.Project__c);
                
                if(insprec.RW_Inspection_Status__c =='Inspection Scheduled'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else if(insprec.RW_Inspection_Status__c =='Home Score Initiated'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message); 
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else if(insprec.RW_Inspection_Status__c =='Home Score Completed'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else if(insprec.RW_Inspection_Status__c =='Snagging Initiated'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c, insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else  if(insprec.RW_Inspection_Status__c =='Snagging Completed'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else  if(insprec.RW_Inspection_Status__c =='Readiness Initiated'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }else  if(insprec.RW_Inspection_Status__c =='Readiness Completed'){
                    if(temMem.IsActive__c == True){
                        message = EmailPreparation(temMem.User__r.Email, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c );
                        messages.add(message);
                    }else if(String.isNotBlank(temMem.Email_Id__c)){
                        message = EmailPreparation(temMem.Email_Id__c, insprec.RW_Inspection_Status__c,insprec.Booking__r.Unit_No__r.Name,insprec.Booking__r.Project__r.Name, insprec.Booking__r.Primary_Applicant_Name__c,insprec.Booking__r.Unit_No__r.RW_Param4__c ); 
                        messages.add(message); 
                    }
                }
            }
        }
        if(messages.size()> 0){  
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success){
                System.debug('The email was sent successfully.');
            } else{
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
    
    global static Messaging.SingleEmailMessage EmailPreparation(String Email, String Status, String UnitId, String ProjId, String ApplicantName, String UnitNo){
        string body ='';
        string statusInpPoss ='';
        
        if(Status =='Inspection Scheduled'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,Inspection has been Scheduled. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else if(Status == 'Home Score Initiated'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,Project team Initiated the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else if(Status =='Home Score Completed'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,Project team completed the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else  if(Status =='Snagging Initiated'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,Facility team Initiated the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else  if(Status =='Snagging Completed'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,Facility team completed the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else  if(Status =='Readiness Initiated'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,CRM team Initiated the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }else  if(Status =='Readiness Completed'){
            
            statusInpPoss = Status + ' - ' + ApplicantName + ' - ' +  UnitNo;
            
            body = 'Dear All, <br/><br/>';  
            
            body += 'For unit number ' + UnitId + ' in project ' + ProjId + ' ,CRM team completed the inspection process. <br/>';
            
            body += '<br/><br/><br/>';
            
            body += 'Thanks,<br/>';
            
            body += ' Runwal Homes.';
            
        }
        
        // string body = 'body';
        Messaging.SingleEmailMessage message =new Messaging.SingleEmailMessage();
        message.setSubject(statusInpPoss);
        message.sethtmlbody(body);
        message.setUseSignature(false);
        message.setBccSender(false);
        //message.setTemplateId(emailTemplate.id);
        message.saveAsActivity = false;
        message.toaddresses = new string[]{Email};
            return message;
    }
    
}