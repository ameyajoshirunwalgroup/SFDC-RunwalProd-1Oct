global class RWCreateCaseByEmail implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        boolean check;
        Map<string,RM_Usernames__c> mapRMUsernames = RM_Usernames__c.getall();
                
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        Case objCase = new Case();
        objCase.origin = 'Email';
        objCase.Priority = 'Medium';
        objCase.Description = email.plainTextBody;
        objCase.subject = email.subject;
        
        System.debug('%%%%email.toAddresses'+email.toAddresses);

        map<string,string> mapRMEmailWRTName = new map<string,string>();
        
        //Added by coServe 07-06-2024 Start
        List<String> profiles = System.label.Case_Owner_Assignment_Profiles.split(',');
        Map<String,String> userEmailVsName = new Map<String,String>();
        for(User usr : [SELECT Id, Name, Email, UserName FROM User WHERE Profile.Name =: profiles AND IsActive = true]){
            userEmailVsName.put(usr.Email, usr.Name);
        }
        //Added by coServe 07-06-2024 End
        
        for(RM_Usernames__c obj : mapRMUsernames.values())
        {
            mapRMEmailWRTName.put(obj.RW_Email__c,obj.name);
        }
        mapRMEmailWRTName.put('customer.care@runwalgroup.in','');
        
        system.debug('@to add________'+email.toAddresses);
        system.debug('@body_______'+email.plainTextBody);
        for(string EachEmail : email.toAddresses)
        {
            system.debug('@to add@@@@@@@@@@@@@________'+email.toAddresses);
             
            //if(mapRMEmailWRTName.containsKey(EachEmail)) //Commented by coServe 07-06-2024
            //{
            //changes
                if(EachEmail == 'greenshelpdesk@runwal.com')
                {
                    objCase.RW_Case_Type__c = 'Complaint';
                    objCase.RW_Complaint_Type__c = 'Post Possession Related';
                    //objCase.RW_RM_Name__c = mapRMEmailWRTName.get(EachEmail); //Commented by coServe 07-06-2024
                    objCase.RW_RM_Name__c = userEmailVsName.get(EachEmail); //Added by coServe 07-06-2024
                     system.debug('test%%%%1111');
                }
                else if(EachEmail == 'customer.care@runwalgroup.in')            
                {
                    objCase.RW_Case_Type__c = 'Complaint';
                    objCase.RW_Complaint_Type__c ='Customer Care'; 
                    system.debug('%%%1');
                } 
             //end
                 else
                 {      
                  system.debug('%%%2');
                     //objCase.RW_RM_Name__c = mapRMEmailWRTName.get(EachEmail); //Commented by coServe 07-06-2024
                     objCase.RW_RM_Name__c = userEmailVsName.get(EachEmail); //Added by coServe 07-06-2024
                 }
            //}
            
        }
        System.debug('RM Name: ' + objCase.RW_RM_Name__c);
          list<Account> lstAccount = [select id,RW_Email__c, isPersonAccount from Account where PersonEmail =: email.fromAddress];
        
        if(lstAccount != null && lstAccount.size() > 0)
        {
            
            
            objCase.Accountid = lstAccount[0].id; 
            //if(lstAccount[0].isPersonAccount)
                //objCase.Contactid = lstAccount[0].id; 
                
            insert objCase;
        }
        return result;
    }
}