@RestResource(urlMapping='/getAgentId/*')

global class Rest_getAgentdetails {
    @Httppost
    global static Rest_Result Rest_getAgentdetails(String Mobile, String CampaignName, String DID)       
    {
        
        system.debug('Mobile=='+Mobile);
        Rest_Result r = new Rest_Result();   
        
        List<Account> AccList = new List<Account>();
        List<User> UserList = new List<User>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        // Added by coServe 28-06-2024 Start
        oppList = [SELECT Id, Name, AccountId, Booking__r.Unit_No__r.Relationship_Manager__r.User__c FROM Opportunity WHERE RW_Mobile_No__c =: Mobile AND StageName = 'Unit Booked' ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
        if(oppList.size() > 0){
            AccList = [Select Id, Name, RM_Name__c, Mobile_No__c From Account Where Id =: oppList[0].AccountId];
        }else{
            AccList = [Select Id, Name, /*Presales_Agent__r.Name,*/RM_Name__c, Mobile_No__c From Account 
                       Where Mobile_No__c =:Mobile];
        }
        // Added by coServe 28-06-2024 End
        
        /*if(!Test.isRunningTest()){ // Added by coServe 07-05-2024
            oppList = [SELECT Id, Name, AccountId, Booking__r.Unit_No__r.Relationship_Manager__r.User__c FROM Opportunity WHERE RW_Mobile_No__c =: Mobile AND StageName = 'Unit Booked' ORDER BY Booking__r.Booking_Date__c DESC LIMIT 1];
            if(oppList.size() > 0){
                AccList = [Select Id, Name, RM_Name__c, Mobile_No__c From Account Where Id =: oppList[0].AccountId];
            }else{
                AccList = [Select Id, Name, RM_Name__c, Mobile_No__c From Account 
                  Where Mobile_No__c =:Mobile];
            }
        }else{
            AccList = [Select Id, Name, RM_Name__c, Mobile_No__c From Account 
                  Where Mobile_No__c =:Mobile];
        }*/
        
        
        //AccList = [Select Id, Name, /*Presales_Agent__r.Name,*/RM_Name__c, Mobile_No__c From Account 
                  //Where Mobile_No__c =:Mobile]; // Commented by coServe 07-05-2024
        
        //AccList = [Select Id, Name, RM_Name__c, Mobile_No__c From Account Where Id =: oppList[0].AccountId]; // Added by coServe 07-05-2024
       system.debug('Account:'+AccList);
        
        If(AccList.Size() >0 && AccList.Size() != Null){
            //If(OpList[0].Presales_Agent__c != Null){
                 //UserList = [Select Id, Name, CTI_Agent_ID__c, Ozontel_UserName__c,Campaign_Name__c, Phone
                   //          From User Where Name =: AccList[0].RM_Name__c and isActive =: true/*Presales_Agent__r.Name*/];
            //}else{}
            if(oppList.size() > 0){ //Added by coServe 28-06-2024
                UserList = [Select Id, Name, CTI_Agent_ID__c, Ozontel_UserName__c,Campaign_Name__c, Phone                 
                        From User Where Id =: oppList[0].Booking__r.Unit_No__r.Relationship_Manager__r.User__c and isActive =: true]; 
            }else{
                UserList = [Select Id, Name, CTI_Agent_ID__c, Ozontel_UserName__c,Campaign_Name__c, Phone                
                             From User Where Name =: AccList[0].RM_Name__c and isActive =: true/*Presales_Agent__r.Name*/];
            }
          system.debug('User:'+UserList);
            If(UserList.Size()>0 && UserList.Size() != Null){
           system.debug('im in UserList'+UserList[0].CTI_Agent_ID__c);
                IF(UserList[0].CTI_Agent_ID__c != Null){
                    system.debug('Agent ID:');
                    r.agentid = UserList[0].CTI_Agent_ID__c;           //OzoneTel AgentId
                    r.Agent_username = UserList[0].Ozontel_UserName__c;
                    r.Campaign_name = UserList[0].campaign_name__c;
                    r.Agent_Mobile = UserList[0].Phone;
                    r.status = 200;
                    r.message = 'Success';  
                    return r;
                }else{
                    r.status = 300;
                    r.message = 'AgentId not found ';  
                    return r;
                }
            }else{
                r.status = 400;
                r.message = 'Agent not found ';  
                return r;
            }
        }else{
            r.status = 500;
            r.message = 'record not found ';  
            return r;
        }
        
    }
    
    global class Rest_Result{
        global Integer status ;
        global String message ; 
        global String agentid;
        global String Agent_username;
        global String Campaign_name;
        global String Agent_Mobile;
    }
}