global class CreateMagicBrickLead {
  public String msg {
    get;
    set;
  }
  public Lead newobj {
    get;
    set;
  }
  public List < Lead > LeadList {
    get;
    set;
  }
  public List < DupResultsDTO > dupList {
    get;
    set;
  }
  public List < Project__c > prolst = new List < Project__c > ();
  public List < MagicBricks_ProjectMaps__c > setting {
    get;
    set;
  }
  public List< MagicBricksAPIKey__c > APIKeySetting {
   get;
   set;
  }
  public string APIKey {
    get;
    set;
  }
  public string Name {
    get;
    set;
  }
  public string MobileNo {
    get;
    set;
  }
  public string EmailID {
    get;
    set;
  }
  public string ProjectName {
    get;
    set;
  }
  public string Source {
    get;
    set;
  }
  public string Comments {
    get;
    set;
  }
 
  public string Medium{
    get;
    set;
  }
  public Map < Id, Lead > enquiryMap {
    get;
    set;
  }
  public Database.saveResult[] srList {
    get;
    set;
  }
  public Database.SaveResult sr {
    get;
    set;
  }
  public Database.Error err {
    get;
    set;
  }

  public CreateMagicBrickLead() {

    msg = '';
    srList = new Database.saveResult[] {};
    setting = new List < MagicBricks_ProjectMaps__c > ();
    APIKeySetting = new List < MagicBricksAPIKey__c > ();
    newobj = new Lead();
    LeadList = new List < Lead > ();
    dupList = new List < DupResultsDTO > ();
    APIKey = ApexPages.currentPage().getParameters().get('APIKey');
    Name = ApexPages.currentPage().getParameters().get('Name');
    MobileNo = ApexPages.currentPage().getParameters().get('MobileNo');
    EmailID = ApexPages.currentPage().getParameters().get('EmailID');
    Source = ApexPages.currentPage().getParameters().get('Source');
    ProjectName = ApexPages.currentPage().getParameters().get('ProjectName');
    Comments = ApexPages.currentPage().getParameters().get('Comments');
    Medium = ApexPages.currentPage().getParameters().get('Medium');

    system.debug('strMobile>> ' + MobileNo);
    system.debug('shortCode ' + ProjectName);

    if (String.isBlank(ProjectName)) {
      ProjectName = 'BLANK';

    }

    setting = [SELECT Id, Name, Project_Name__c from MagicBricks_ProjectMaps__c Where Name = : ProjectName];
    system.debug('setting ' + setting);

    if (setting.size() > 0) {
      System.debug('value of the setting:' + setting[0].Project_Name__c);
      prolst = [SELECT Id, Name from Project__c Where Name = : setting[0].Project_Name__c];
      system.debug('prolst' + prolst);
    } else {
      ProjectName = 'BLANK';
      setting = [SELECT Id, Name, Project_Name__c from MagicBricks_ProjectMaps__c Where Name = : ProjectName];
      prolst = [SELECT Id, Name from Project__c Where Name = : setting[0].Project_Name__c];
    }

    if (prolst.size() > 0) {
      newobj.RW_Project__c  = prolst[0].id;
      // newobj.Projects_of_Interest__c = prolst[0].Name;
    } else {
      system.debug('prolst is empty');
    }
    
    APIKeySetting = [SELECT Id,Name,Key__c from MagicBricksAPIKey__c where Key__c = : APIKey];
    system.debug('APIKeySetting'+ APIKeySetting );
    
    if(APIKeySetting.size() > 0) {
        newobj.APIKey__c = APIKeySetting[0].Key__c ;
    }
        newobj.RW_Mobile_No__c = MobileNo;
        newobj.Web_Banner_Source__c = Source;
        newobj.Email = EmailID;
        newobj.Status = 'Not Sure';
        newobj.LastName = Name;
        newobj.LeadSource = 'Property Portals';
        newobj.RW_Lead_Sub_Source__c = 'MagicBricks';
        newobj.Lead_Sub_Source__c = 'Magic Bricks';
        newobj.medium__c  = 'Online';
      //newobj.root_source__c = rootsource;    
        newobj.Description__c = 'Lead created from Magic Bricks';
        newobj.Integration_Source__c = 'MagicBricks';
        newobj.auto_assign__c = true; // Added by Tejaswini.
        
       
        //LeadList.add(newobj); //Commented by Vinay 28-08-2025
      if(!String.isBlank(newobj.RW_Project__c)){ //Added by Vinay 28-08-2025
          LeadList.add(newobj);
      }else{
          ERP_Integration_Log__c log = new ERP_Integration_Log__c();
          log.request__c = 'RW_Mobile_No__c: ' +  MobileNo + ', Email: ' + EmailID + ', Name: ' + Name + ', Integration_Source__c: MagicBricks, Web_Banner_Source__c: ' + Source;
          log.API_name__c = 'Lead Creation Error';
          log.response__c = 'Project is missing';
          log.Status__c='Failure';
          log.Error_Type__c='Data Error';
          log.Error_Reason__c = 'Project is missing';
          insert log;
      }
  
}

  public void insertlead() {
      if(APIKeySetting.size() > 0) {
            system.debug('inside lead insert method');
            if (LeadList.size() > 0) {
            List < DupResultsDTO > dupList = LeadManagementServices.leadPreProcessing(LeadList, 'WEB');
              system.debug('dupList>>' + dupList);
        
              if (dupList.size() == 0) {
                system.debug('dupList>>' + dupList);
                try {
                  Database.saveResult[] srList = Database.insert(leadList, true);
                    for (Database.SaveResult sr: srList) {
                    if (sr.isSuccess()) {
                      try {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Lead Submited Successfully.'));
                        system.debug('in try block');
                        system.debug('sr.getId()' + sr.getId());
                        Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                        enquiryMap.put(sr.getId(), newobj);
                        Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                        whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                        task t = [Select Id from task where id = : whoIDMap.get(sr.getId()).Id];
                        upsert t;
                       
                      } catch (Exception ex) {
                        System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                      }
                    } else {
                      msg = null;
                      for (Database.Error err: sr.getErrors()) {
                        msg = 'Lead Insert Failed :' + err.getMessage();
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,msg));
                      }
                    }
                  }
                } catch (System.DmlException ex) {
                  system.debug(ex);
                   
                  } catch (Exception ex) {
                  String msg = null;
                  for (Integer i = 0; i < ex.getNumDml(); i++) {
                    msg = 'Lead Insert Failed :' + ex.getMessage();
                    system.debug('msg ' + msg);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error,msg));
                  }
                }
              } 
              else{
                  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'New inquiry has been cretated for your existing Leads'));
              }
              
            } else {
              system.debug('ReqType is not value first');
            }
           
          }
          else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Authorization'));
    }
}
}