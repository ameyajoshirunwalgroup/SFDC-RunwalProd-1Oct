@RestResource(urlMapping='/RMName/*')
global with sharing class RMNameRestService {
  public class Result
      {
          //public string Name {get; set;}
          public string AgentId {get; set;}
          public string Phone {get; set;}
          public Boolean IsError {get; set;}
          public string Message {get; set;}
          public string Uri {get; set;}
      }
             
      @HttpPost
      global static string doPost(string phone)
      {
          system.debug('RM Name-----' + phone);
          Result objResult = new Result();
          try
          {
              map<string, RM_Usernames__c> mapOfRMUsernames = RM_Usernames__c.getAll();
              system.debug('mapOfRMUsernames-----' + mapOfRMUsernames);
              
              //added on 21/12/2016 by adarsh
              list<Opportunity> lstOpp = [select id, RW_RM_Name__c,AccountId 
                                          from Opportunity 
                                          where RW_Mobile_No__c =: phone
                                          and StageName =: 'Unit Booked' order by CreatedDate desc];
              
              if(lstOpp != null && lstOpp.size() > 0)
              {
                  if(lstOpp[0].RW_RM_Name__c != null && mapOfRMUsernames.containsKey(lstOpp[0].RW_RM_Name__c) && 
                        mapOfRMUsernames.get(lstOpp[0].RW_RM_Name__c).RW_Ameyo_Agent_ID__c != null)
                  {
                      list<case> lstCase = [Select Id from Case 
                                              Where AccountId =: lstOpp[0].AccountId 
                                              and Status =: 'Open'
                                           Order by LastModifiedDate Desc];
                                           
                      string baseURI =  System.URL.getSalesforceBaseUrl().toExternalForm() + '/';
                      if(lstCase != null && lstCase.size() > 0)
                      {
                          objResult.Uri = baseURI + lstCase[0].Id;
                      }
                      else
                      {
                          objResult.Uri = baseURI + '500/e?def_account_id=' + lstOpp[0].AccountId;
                          //+'&cas11=Phone(Call%20Center%20CTI)'; commented on 7th April after the discussion with sachin
                      }
                      
                      objResult.Phone = mapOfRMUsernames.get(lstOpp[0].RW_RM_Name__c).RW_Phone__c;
                      objResult.IsError = false;
                      objResult.Message = 'Success';
                      objResult.AgentId = mapOfRMUsernames.get(lstOpp[0].RW_RM_Name__c).RW_Ameyo_Agent_ID__c;
                  }
                  else
                  {
                      objResult.Message = 'Error';
                      objResult.IsError = true;
                      //objResult.AgentId = '';
                      objResult.Message = 'No record found.';
                  }
              }
              
              /*objResult.Phone = phone;
              objResult.IsError = false;
              
              if(objRMUsernames.size() > 0)
              {
                  for(RM_Usernames__c objRM : objRMUsernames)
                  {
                      if(objRM.RW_Phone__c == phone)
                      {
                          objResult.Message = 'Success';
                          objResult.Name = objRM.Name;
                          break;
                      }
                      else
                      {
                          objResult.Message = 'RM not exist.';
                      }
                  }
              }
              else
              {
                  objResult.Message = 'RM not exist.';
              }*/
          }
          catch(exception e)
          {
              system.debug('/RMName/ Exception :: ' + e);
              
              objResult.Phone = phone;
              objResult.Message = 'Error: ' + e;
              objResult.IsError = true;
          }
          
          string jsonResult = System.JSON.serialize(objResult);
          system.debug('jsonResult=====' + jsonResult);
          return jsonResult;
      }
      
      @Httpget
      global static string doPost()
      {
          return 'Ok';
      }
}