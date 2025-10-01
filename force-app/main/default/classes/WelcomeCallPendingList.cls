public class WelcomeCallPendingList implements Database.Batchable<sObject>{
	
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> listStatus = new list<String>{'Reject','Due','Reinitiate','Hold'};
        List<String> bookingConfirmedList = new list<String>{'Booking Confirmed'};    
        string query = 'SELECT Id,Name,RW_Applicant1_Primary_Applicant_Name__c,RW_Welcome_Call_Status__c,Welcome_Call_Pending__c,RW_Booking__r.Opportunity__r.Name,RW_Booking__r.Wing__c,RW_Booking__r.Project__r.Name,RW_Booking__r.Unit_No__r.RW_Param4__c,RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c,CreatedDate,RW_Booking__c,RW_Booking__r.Name,RW_Welcome_Call_Completed__c From RW_Welcome_Call__c where RW_Welcome_Call_Status__c IN:listStatus AND RW_Welcome_Call_Completed__c = false And RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null AND RW_Booking__r.Status__c IN:bookingConfirmedList';
       return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<RW_Welcome_Call__c> welCallList){
        system.debug('###welCallList '+welCallList.size());
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage>(); 
       
        set<String> rmmailids = new set<string>();
        Map<String, List<RW_Welcome_Call__c>> mapOfRMMails = new Map<String, List<RW_Welcome_Call__c>>();
        List<RW_Welcome_Call__c> listWelcalls = new List<RW_Welcome_Call__c>();
        for(RW_Welcome_Call__c welCall: welCallList){
            
            if(welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != null && welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c != ''){
                system.debug('emails '+welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c);

                if(mapOfRMMails.containsKey(welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c)){
                    system.debug('###welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c '+welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c);
                    mapOfRMMails.get(welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c).add(welCall);
                }else{
                   mapOfRMMails.put(welCall.RW_Booking__r.Unit_No__r.Relationship_Manager__r.RM_Email__c, new RW_Welcome_Call__c[]{welCall});
                }
                
             }   
        }
        system.debug('mapOfRMMails.keySet()____ '+mapOfRMMails.size());
        system.debug('mapOfRMMails.values size____ '+mapOfRMMails.values().size());
        for(String emailAddrss: mapOfRMMails.keySet()){
            if(emailAddrss != null && emailAddrss != ''){
            List<RW_Welcome_Call__c> listOfWcCalls = mapOfRMMails.get(emailAddrss);
                system.debug('listOfWcCalls____ '+listOfWcCalls.size());
                if(listOfWcCalls.size()>0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                system.debug('emailAddrss____'+emailAddrss);
                mail.toaddresses = new String[] {emailAddrss};
                mail.subject ='WelcomeCall Assignment';
                    
                string body = 'Dear RM,';
                    
                body += 'Please find the below WelcomeCall Assignment.';
                
                body += '<html><head><style>table{border-collapse: collapse;}table, td, th {border: 1px solid black; text-align: left;}</style></head><body><table>';
                
                body += '<tr><th> PROJECT </th><th> OPPORTUNITY </th><th> BOOKING NAME </th><th> WELCOMECALL NAME </th><th> WELCOMECALL STATUS </th><th> TOWER </th><th> UNIT </th><th> PENDING FROM[DAYS] </th><th> APPLICANT NAME </th></tr>';
                for(RW_Welcome_Call__c welCall: listOfWcCalls){
                    system.debug('welCall____'+welCall);
            
                      body += '<tr>';
                    
                      body += '<td>'+ welCall.RW_Booking__r.Project__r.Name +'</td>';
                    
                      body += '<td>'+ welCall.RW_Booking__r.Opportunity__r.Name +'</td>';
                     
                      body += '<td>'+ welCall.RW_Booking__r.Name +'</td>';
                    
                      body += '<td><a href="'+Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/RW_Welcome_Call__c/' +welCall.id+ '/view">' + welCall.Name +'</a></td>';
                      
                      body += '<td>'+ welCall.RW_Welcome_Call_Status__c +'</td>';
                     
                      body += '<td>'+ welCall.RW_Booking__r.Wing__c +'</td>';
                    
                      body += '<td>'+ welCall.RW_Booking__r.Unit_No__r.RW_Param4__c +'</td>';
                    
                      body += '<td>'+ welCall.Welcome_Call_Pending__c +'</td>';
                    
                      body += '<td>'+ welCall.RW_Applicant1_Primary_Applicant_Name__c +'</td>';
                      
                      body += '</tr>';
                }
                 
                body += '</table></body></html>';
        
                    body += '<br/><br/><br/>';
                  
                    body += 'Thanks,<br/>';
                   
                    body += ' Runwal Homes.';
                    
                    mail.sethtmlbody(body);
                messages.add(mail);
            }
        }
        }
        if(messages.size()> 0){
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
    public void finish(Database.BatchableContext bc){
        
    }
}