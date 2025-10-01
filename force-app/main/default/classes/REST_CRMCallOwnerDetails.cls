@RestResource(urlMapping='/CRMcall/ownerdetails/')
    global class REST_CRMCallOwnerDetails
    { 
    @HttpPost
    global static REST_Result validMobileNo(string MobileNo)
    {   
        REST_Result r = new REST_Result();
        system.debug('Request::' + RestContext.Request);
        
        map<string, RM_Usernames__c> mapOfRMUsernames = RM_Usernames__c.getAll();
        system.debug('mapOfRMUsernames-----' + mapOfRMUsernames);
        
        List < Account > lstaccount = new List < Account >();
        
            if(string.isBlank(MobileNo) || MobileNo == null ){
                r.returncode = 1;
                r.message='Please Enter a Mobile No'; 
                return r;
            }
            else if(MobileNo.length() != 10){
                r.returncode = 1;
                r.message ='Please Enter Valid Mobile No';
                return r;
            }else {
                
                lstaccount=[Select Id,Name,Mobile_No__c,RM_Name__c,RW_Secondary_Mobile_No__pc,Phone From Account Where Mobile_No__c =:MobileNo OR Phone=: MobileNo];  
                system.debug('lstaccount::' + lstaccount);
                
                if(lstaccount.isEmpty() && lstaccount.size() == 0){
                      r.returncode =1;
                      r.message = 'No Record Found';
                      return r;
                
                }else if(!lstaccount.isEmpty() && lstaccount.size() > 0){
                  system.debug('inside lstaccount:');
                  System.debug('Account RM::' + lstaccount[0].RM_Name__c);
                  system.debug('RM Name::' + mapOfRMUsernames.containsKey(lstaccount[0].RM_Name__c));
                  
                   if(lstaccount[0].RM_Name__c != null && mapOfRMUsernames.containsKey(lstaccount[0].RM_Name__c)){
                        
                        system.debug('inside lstaccount RM Name:' + mapOfRMUsernames.containsKey(lstaccount[0].RM_Name__c));
                        system.debug('inside lstaccount RM agentId:' + mapOfRMUsernames.get(lstaccount[0].RM_Name__c).RW_Ameyo_Agent_ID__c);
                        
                        r.returncode = 0;
                        r.message = 'Account Exist';
                        r.Name = mapOfRMUsernames.get(lstaccount[0].RM_Name__c).Name;
                        r.RecordId = lstaccount[0].id;
                        r.Mobile = mapOfRMUsernames.get(lstaccount[0].RM_Name__c).RW_Mobile_No__c;
                        r.UserId = mapOfRMUsernames.get(lstaccount[0].RM_Name__c).User_Name__c;
                        //r.FirstName = lstUser[0].FirstName;
                        //r.LastName = lstUser[0].LastName;
                        //r.phone = lstUser[0].Phone;
                        return r;
                    }else if(lstaccount[0].RM_Name__c == null){
                          r.returncode = 1;
                          r.message = 'RM Is Not Tagged';
                          return r;
                }else if(lstaccount[0].RM_Name__c != null && !mapOfRMUsernames.containsKey(lstaccount[0].RM_Name__c)){
                        r.returncode = 1;
                        r.message = 'RM is not mapped in custom setting';
                        return r;
                }
             }
                else{
                     r.returncode = 1;
                     r.message = 'Something Went Wrong';
                     return r;
                }
            }
        
          return null;
    }
    Global class REST_Result {
        WebService integer Returncode;
        WebService String Message;
        Webservice string Name;
        WebService string UserId;
        WebService string Mobile;
        WebService string RecordId;
        //WebService string FirstName;
        //WebService string LastName;
        //WebService string Title;
    }
    }