public class WelcomeCallEscalationMatrix implements Database.Batchable<sObject>  {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        List<Booking__c> bkgsList = [Select Id,Status__c,Unit_No__r.Relationship_Manager__r.RM_Email__c,
                                     Booking_Date__c, Project__r.Project_CRM_Lead__c From Booking__c 
                                     WHERE Status__c ='Booking Confirmed' AND Booking_Date__c != null  ]; 
        List<Id> idsList = new List<Id>();
        for(Booking__c bkg: bkgsList){
            idsList.add(bkg.Id);
        }
        string query = 'Select Id,RW_Booking__r.Booking_Date__c,RW_Booking__r.Project__c,RW_Booking__c,RW_Welcome_Call_Initiation_date__c,RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c,RW_Welcome_Call_Completed__c From RW_Welcome_Call__c WHERE RW_Welcome_Call_Completed__c = false AND RW_Welcome_Call_Initiation_date__c = null AND RW_Booking__c IN:idsList';
       
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<RW_Welcome_Call__c> wlcList){
        
        system.debug('wlcList____ '+wlcList.size());
        
        if(wlcList!=null && wlcList.size()>0)
        {
            string BookingID;
             List<string> RMEail = new List<string>();
            List<Id> projIds = new List<Id>();
            List<Id> teamIds = new List<Id>();
            // List<string> crmHeads = new List<string>();
            
            Set<String> setBookinids = new Set<String>();
            Set<String> setOfEmailAddrs = new Set<String>();
            for(RW_Welcome_Call__c eachBkng : wlcList){
                projIds.add(eachBkng.RW_Booking__r.Project__c);
                if(eachBkng.RW_Welcome_Call_Initiation_date__c == null ){
                    system.debug('eachBkng.RW_Welcome_Call_Initiation_date__c '+eachBkng.RW_Welcome_Call_Initiation_date__c);
                    system.debug('eachBkng.RW_Booking__r.Booking_Date__c '+eachBkng.RW_Booking__r.Booking_Date__c);
                      DateTime dt = System.now();
					Date myDate = date.newinstance(eachBkng.RW_Booking__r.Booking_Date__c.year(), eachBkng.RW_Booking__r.Booking_Date__c.month(), eachBkng.RW_Booking__r.Booking_Date__c.day());
                    system.debug('myDate '+myDate);
                    system.debug('dt.date().addDays(1) '+dt.date().addDays(-1));
                    if(myDate.addDays(1) == dt.date() ){
                        setOfEmailAddrs.add('Team Lead');
                        system.debug('setOfEmailAddrs '+setOfEmailAddrs); 
                        
                    }
                    if(myDate.addDays(5)  == dt.date()){
                        setOfEmailAddrs.add('CRM Head');
                    }
                    if(myDate.addDays(6) == dt.date() ){
                        setOfEmailAddrs.add('Companies CRM Head');
                    }
                    setBookinids.add(eachBkng.RW_Booking__c);
                    //mapOfbkgs.put(eachBkng.RW_Booking__r.Project__c, eachBkng.RW_Booking__c);
                }
            }
            
            Map<Id, List<Booking__c>> mapOfbkgs = new Map<Id, List<Booking__c>>();
            for(Booking__c bkng: [Select Id,Name,Project__c,Status__c,Booking_Date__c,Unit_No__r.Relationship_Manager__r.Name From Booking__c where Id IN:setBookinids AND Status__c ='Booking Confirmed' AND Booking_Date__c != null]){
                mapOfbkgs.put(bkng.Project__c, new list<Booking__c>{bkng});
            }
            system.debug('setOfEmailAddrs_____ ' +setOfEmailAddrs);
            List<Team__c> teamsList = [SELECT Id, Project__c, Team_Type__c, Name FROM Team__c WHERE Team_Type__c IN: setOfEmailAddrs AND Project__c IN:projIds];
             system.debug('tm_____ ' +teamsList.size());
            for(Team__c tm: teamsList){
                system.debug('tm_____ ' +tm);
        		teamIds.add(tm.Id);
      		}
      List<Team_Members__c> temMembr = [SELECT Id, Name, Approver_Type__c, Counter__c, IsActive__c, Team__c,Team__r.Project__c, User_Active__c, User__c,User__r.Email FROM 
                                         Team_Members__c WHERE Team__c IN: teamIds AND User_Active__c = true];
            system.debug('temMembr_____ ' +temMembr.size());
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>(); 
            for(Team_Members__c  tm: temMembr){
                //crmHeads.add(tm.User__r.Email); 
                system.debug('Team_Members__c_____ ' +tm.User__r.Email);
                string body = '';
                body += '<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black;}</style></head><body><h3>Welcome call doesn’t happen to below bookings<br/></h3><table>';
				body += '<tr><th>Booking Confirmation Date</th><th>Booking Name</th><th>RM Name</th></tr>'; 
                List<Booking__c> bkngList = mapOfbkgs.get(tm.Team__r.Project__c);
                for(Booking__c bkng: bkngList){
                    body += '<tr>';
                    if(bkng.Project__c == tm.Team__r.Project__c){
                        body += '<td>'+bkng.Booking_Date__c+'</td>';
                        body += '<td>'+'<a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/Booking__c/' + bkng.id+ '/view">' + bkng.Name+ '</a></td>';
                        body += '<td>'+bkng.Unit_No__r.Relationship_Manager__r.Name+'</td>';
                    }
                    body += '</tr>';
                }
                body += '</table></body></html>';

                body += '<br/><br/><br/>';
              
                body += 'Thanks,<br/>';
               
                body += ' Runwal Homes.';
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
               // message.setToAddresses(tm.User__r.Email);
                message.toAddresses = new String[] {tm.User__r.Email};
                message.subject = 'Escalation For WelcomeCall';
                message.sethtmlbody(body);
                messages.add(message);
            }
            If(messages.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
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
    }        
    
    public void finish(Database.BatchableContext bc){
        
    }   
}