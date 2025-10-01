public class ToolingApiPageController 
{
    public dateTime StartDate{get;set;}
    public dateTime EndDate{get;set;}
    public List<cls_records> devName{get;set;}
    public List<cls_recordsName > triggerNames{get;set;}
    public List<cls_recordsName > apexClassList{get;set;}
    public List<cls_recordsName > emailTempList{get;set;}
    public List<cls_records> customflds{get;set;}
    public list<cls_recordsName> scontrollist{get;set;}
    public List<cls_recordsName > vfpages{get;set;}
    public List<cls_recordsValidationRule> validationRuleList{get;set;}
    public list<cls_recordsPB> processBuilderlist{get;set;}
    public list<cls_recordsName> workflowRuleList{get;set;}
    public list<cls_recordsName> wfFieldUpdateList{get;set;}
    public list<cls_records> wfemailalertList{get;set;}
    public list<cls_recordsName> wfOutboundMsgList{get;set;}
    public list <cls_recordsName> bprocessList{get;set;}
    public list <cls_recordsName> profileList{get;set;}
    public list <cls_recordsName> pgLayoutList{get;set;}
    public list <cls_recordsRecordType> recordTypeList{get;set;}
    public list<cls_records> fieldSetlist{get;set;}
    public list<cls_recordsstaticResource> staticResList{get;set;}
    public string xmlheader {get;set;}
    public string endfile{get;set;}
    public static string strtdate ;
    public  static string tdayDate ;
    //added by karthik on 02/08/2016
    public list<cls_recordsName> lstvisualComponent{get;set;}
    public list<cls_records> lstCustomTabs{get;set;}
    public list<cls_recordsName> lstCustomWeblinks{get;set;}
    public list<cls_recordsName> lstReports{get;set;}
    public list<cls_records> lstDashboards{get;set;}
    public list<cls_recordsName> lstDocuments{get;set;}
    public list<cls_records> lstCustomSettings{get;set;}
    public list<cls_records> lstGroups{get;set;}
    public list<cls_records> lstListViews{get;set;}  
    public list <cls_recordsName> lstPermissionSets{get;set;} 
    public list <cls_recordsName> lstAssignmentRules{get;set;}
    public list<cls_records> lstApprovalProcess{get;set;}    
    public set<string> setCustomSetApiNames;
    //added By Insha..
    public list<cls_recordsLightning> lstAuraApp{get;set;}
    public list<cls_recordsLightning> lstAuraComponent{get;set;}
    public list<cls_recordsLightning> lstAuraEvent{get;set;}
    public list<cls_recordsLightning> lstAuraToken{get;set;}
    public Map<Id,String> mapOfIdVsAuraName;
    //constructor
    public ToolingApiPageController() 
    {
        devName = new List<cls_records>();
        triggerNames= new List<cls_recordsName>();
        apexClassList = new List<cls_recordsName>();
        customflds= new List<cls_records>();
        vfpages=new List<cls_recordsName>();
        fieldSetlist= new List<cls_records>();
        staticResList =new list<cls_recordsstaticResource>();
        workflowRuleList=new List<cls_recordsName>();
        processBuilderlist= new list<cls_recordsPB>();
        emailTempList=new List<cls_recordsName>();
        wfFieldUpdateList=new List<cls_recordsName>();
        validationRuleList=new List<cls_recordsValidationRule>();
        wfemailalertList=new  List<cls_records>();
        wfOutboundMsgList=new List<cls_recordsName>();
        bprocessList=new List<cls_recordsName>();
        pgLayoutList=new List<cls_recordsName>();
        profileList=new List<cls_recordsName>();
        scontrollist=new List<cls_recordsName>();
        lstvisualComponent = new list<cls_recordsName>();  
        lstCustomTabs = new list<cls_records>();  
        lstCustomWeblinks = new list<cls_recordsName>(); 
        lstReports = new list<cls_recordsName>(); 
        lstDashboards = new list<cls_records>();
        lstDocuments = new list<cls_recordsName>(); 
        lstPermissionSets = new list<cls_recordsName>();
        lstAssignmentRules = new list<cls_recordsName>();
        lstCustomSettings = new list<cls_records>();
        lstGroups = new list<cls_records>();
        lstListViews = new list<cls_records>();
        lstApprovalProcess = new list<cls_records>();
        recordTypeList=new List<cls_recordsRecordType>();
        setCustomSetApiNames = new set<string>();
        //added by Insha
        lstAuraApp = new list<cls_recordsLightning>();
        lstAuraComponent = new list<cls_recordsLightning>();
        lstAuraEvent = new list<cls_recordsLightning>();
        lstAuraToken = new list<cls_recordsLightning>();
        mapOfIdVsAuraName=new Map<Id,String>();
        
        xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        if(ApexPages.currentPage().getParameters().get('StartDate')!= null && ApexPages.currentPage().getParameters().get('EndDate')!=null)
        {
            StartDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('StartDate'));
            EndDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('EndDate'));
        }      
    }
    //generate button action
      public PageReference callpage()
      {
        PageReference pg = page.DownloadExcel;
        pg.getParameters().put('StartDate',String.valueOf(StartDate));
        pg.getParameters().put('EndDate',String.valueOf(EndDate));
        return pg;
      }
      //Calling all the lists together through DownloadExcel Page to display all data in excel
        public void downloadExcel()
        {     
            CustomSettings();
            CustomObjects();
            ApexTriggers();
            ApexClass();
            customFields();
            apexPages();
            validationRules();
            EmailTemplates();
            processBuilder();
            WorkFlowRule();
            wfFieldUpdate();
            wfemailAlert();
            wfOutboundMsg();
            businessProcess();
            recordType();
            fieldSet();
            staticResource();
            pgLayouts();
            profiles();
            sControl();
            //added by karthik
            vfComponents();   
            CustomTabs();
            weblinks();
            DisplayReports();
            DisplayDashboards();
            DisplayDocuments();
            DisplayPublicGroups();
            DisplayListViews();
            DisplayPermissionSets();
            DisplayApprovalProcesses();
            DisplayAssignmentRules();
            //added by Insha
            mapOfIdVsAuraName=getMapofIdvsAuraName();
            DisplayLightningBundle();
        }
        //common method to hit http request added by karthik on 03/08/2016
        public string ChecklistResponseGenerator(string subQueary,boolean isToolingAPI)
        {
            if(StartDate!= null && EndDate!=null)
            {
                    strtdate =  StartDate .format('yyyy-MM-dd')+'T'+StartDate .format('hh:mm:ss')+'.000+0000';
                    tdayDate = EndDate.format('yyyy-MM-dd')+'T'+EndDate.format('hh:mm:ss')+'.000+0000';
            }
            string querystr = 'select '+subQueary+' where lastmodifieddate >= '+ strtdate +'and lastmodifieddate <='+tdayDate;
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String domainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            system.debug('********domainUrl:'+domainUrl);
            querystr = encodingutil.urlEncode(querystr, 'UTF-8');
            string strEndpointURL = domainUrl+'/services/data/v36.0/query/?q=';
            if(isToolingAPI == true)
            {
                strEndpointURL = domainUrl+'/services/data/v36.0/tooling/query/?q=';
            }
            req.setEndpoint(strEndpointURL+querystr);
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse res = h.send(req);
            System.debug('List View!!!!!!!!!'+res.getBody());
            string strResponse = res.getBody();
            return strResponse;
        }
        //added by karthik on 04/08/2016
        //To retrieve Approval process
        public void DisplayApprovalProcesses()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,TableEnumOrId,developername,LastModifiedBy.name,Type,State from ProcessDefinition',false);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                lstApprovalProcess.add(objJson);             
            }     
        }
        //This method is used to retrieve Assignment rules
        public void DisplayAssignmentRules()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name,Sobjecttype,Active from AssignmentRule',false);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                lstAssignmentRules.add(objJson);
            }
        }
        //This method is used to retrieve Reports
        public void DisplayReports()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name from Report',false);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                lstReports.add(objJson);
            }
        }
        //This method is used to retrieve Dashboards
        public void DisplayDashboards()
        {
            string strJsonResponse = ChecklistResponseGenerator('DeveloperName,Id,LastModifiedDate,LastModifiedBy.Name from Dashboard',false);
            fromJSONDeveloperName objfromJSONName =  (fromJSONDeveloperName) System.JSON.deserialize(strJsonResponse, fromJSONDeveloperName.class);
            for(cls_records objJson : objfromJSONName.records)
            {
                lstDashboards.add(objJson);
            }
        }
        //This method is used to retrieve documents
        public void DisplayDocuments()
        {
             string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name from Document',false);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                lstDocuments.add(objJson);
            }
        }
        //To retrieve groups
        public void DisplayPublicGroups()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,Type,developername,LastModifiedBy.name from Group',false);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                lstGroups.add(objJson);             
            }     
        }
        //To retrieve Listviews
        public void DisplayListViews()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,sobjectType,developername,LastModifiedBy.name from ListView',false);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                lstListViews.add(objJson);             
            }     
        }
        //This method is used to retrieve permissionsets
        public void DisplayPermissionSets()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name,UserLicenseId from PermissionSet',false);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                lstPermissionSets.add(objJson);
            }
        }
        //Added by karthik on 02/08/2016
        public void vfComponents()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name from Apexcomponent',true);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                lstvisualComponent.add(objJson);
            }
        }
        //To retrieve weblinks
        public void Weblinks()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,DisplayType,Name,LinkType,EntityDefinitionId,LastModifiedBy.name from weblink',true); 
            System.debug('Triggers!!!!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                if(objJson.DisplayType == 'B')
                {
                    objJson.DisplayType = 'Button';
                }
                if(objJson.DisplayType == 'M')
                {
                    objJson.DisplayType = 'MassAction';
                }
                if(objJson.DisplayType == 'L')
                {
                    objJson.DisplayType = 'HyperLink';
                }
                lstCustomWeblinks.add(objJson);
            }
        } 
        
        //To retrieve custom tabs
        public void CustomTabs()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,Id,DeveloperName,LastModifiedBy.name from customtab',true);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom tabs!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONDeveloperName objfromJSONName =  (fromJSONDeveloperName) System.JSON.deserialize(strJsonResponse, fromJSONDeveloperName.class);
            for(cls_records objJson : objfromJSONName.records)
            {
                lstCustomTabs.add(objJson);
            }   
        }         
        //Brings out list of all the CustomSettings in the Current Org that are unmanaged and add to list devName
        public void CustomSettings()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,Id,developername,LastModifiedBy.name,IsCustomSetting from EntityDefinition',true);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                if(objJson.IsCustomSetting == true)
                {
                    lstCustomSettings.add(objJson);
                    setCustomSetApiNames.add(objJson.developername);
                }               
            }     
        }       
     //Brings out list of all the CustomObjects in the Current Org that are unmanaged and add to list devName
        public void CustomObjects()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,Id,developername,LastModifiedBy.name from Customobject',true);         
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                if(setCustomSetApiNames.contains(objJson.developername) == false)
                    devName.add(objJson);
            }     
        }     
      //Brings out list of all the ApexTriggers in the Current Org that are unmanaged and add to list triggerNames
        public void ApexTriggers()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate, Name,LastModifiedBy.name from ApexTrigger',true); 
            System.debug('Triggers!!!!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                triggerNames.add(objJson);
            }
        }
    
      //Brings out list of all the BusinessProcess in the Current Org that are unmanaged and add to list bprocessList     
        public void businessProcess()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate, Name,LastModifiedBy.name from BusinessProcess',true); 
            System.debug('BprocessName!!!!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                bprocessList.add(objJson);
            }     
        }
     //Brings out list of all the Apex Classes in the Current Org that are Valid and add to list apexClassList
        public void ApexClass()
        { 
            String strJsonResponse = ChecklistResponseGenerator('Name , LastModifiedDate,LastModifiedBy.name from ApexClass',true); 
            System.debug('Apex Class!!!!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                apexClassList.add(objJson);
            }
        }  
    //Brings out list of all the Custom Fields in the Current Org that are Managed and add to list customflds.
        public void customFields()
        {
            String strJsonResponse = ChecklistResponseGenerator('DeveloperName,Id,LastModifiedDate,LastModifiedBy.name,TableEnumOrId from CustomField',true); 
            fromJSONCustomFields objfromJSONName =  (fromJSONCustomFields) System.JSON.deserialize(strJsonResponse, fromJSONCustomFields.class);        
            for(cls_records objJson : objfromJSONName.records)
            {
                customflds.add(objJson);
            }      
        }   
    //Brings out list of all the VF Pages in the Current Org & add to list vfpages.
        public void apexPages()
        { 
            String strJsonResponse = ChecklistResponseGenerator('Name , LastModifiedDate,LastModifiedBy.name from ApexPage',true);  
            System.debug('Apex Pages!!!!!!!!!!!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                vfpages.add(objJson);
            }
        }  
    
     //Brings out list of all the Validation Rules in the Current Org that are Managed and add to list validationRuleList.
        public void validationRules()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate, ValidationName,LastModifiedBy.name from ValidationRule',true);  
            fromJSONValidationRule objfromJSON =  (fromJSONValidationRule) System.JSON.deserialize(strJsonResponse, fromJSONValidationRule.class);
            System.debug('custom objects!!!!!!!!!!!!!');
            for(cls_recordsValidationRule objJson : objfromJSON .records)
            {
                validationRuleList.add(objJson);
            } 
        }
    
      //Brings out list of all the Email Templates in the Current Org that are Managed and add to list emailTempList.
        public void EmailTemplates()
        {
            string strJsonResponse = ChecklistResponseGenerator('lastmodifieddate, Name,LastModifiedBy.name from EmailTemplate',true);        
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                emailTempList.add(objJson);
            }       
        }
               
        //Brings out list of all the Process Builder in the Current Org that are Managed and add to list processBuilderlist.       
        public void processBuilder()
        {
            string strJsonResponse = ChecklistResponseGenerator('MasterLabel,status,ManageableState,LastModifiedBy.name from Flow',true);   
            fromJSONPB objfromJSONName =  (fromJSONPB) System.JSON.deserialize(strJsonResponse, fromJSONPB.class);
            for(cls_recordsPB objJson : objfromJSONName.records)
            {
                processBuilderlist.add(objJson);
            }
        }
               
        //Brings out list of all the WorkFlowRule in the Current Org that are Managed and add to list workflowRuleList.
        public void WorkFlowRule()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,lastmodifieddate,LastModifiedBy.name from WorkflowRule',true);
            System.debug('WorkFlows!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName  objJson : objfromJSONName.records)
            {
                workflowRuleList.add(objJson);
            }   
        }
        
        //Brings out list of all the WorkFlow FieldUpdates in the Current Org that are Managed and add to list wfFieldUpdateList.        
        public void wfFieldUpdate()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,lastmodifieddate,LastModifiedBy.name from WorkflowFieldUpdate',true);      
            System.debug('FieldUpdatess!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName  objJson : objfromJSONName.records)
            {
                wfFieldUpdateList.add(objJson);
            }
        }   
        
       //Brings out list of all the WorkFlow FieldUpdates in the Current Org that are Managed and add to list wfFieldUpdateList.    
        public void wfemailAlert()
        {
            string strJsonResponse = ChecklistResponseGenerator('developerName,Id,lastmodifieddate,LastModifiedBy.name from WorkflowAlert',true);    
            System.debug('EmailAlerts!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                wfemailalertList.add(objJson);
            } 
        }
        
        //Brings out list of all the WorkFlow OutboundMessage in the Current Org that are Managed and add to list wfOutboundMsgList.        
        public void wfOutboundMsg()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,lastmodifieddate,LastModifiedBy.name  from WorkflowOutboundMessage',true);
            System.debug('EmailAlerts!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName  objJson : objfromJSONName.records)
            {
                wfOutboundMsgList.add(objJson);
            }
        }
      
        //Brings out list of all the Record Type in the Current Org that are Managed and add to list recordTypeList.        
        public void recordType()
        {
            string strJsonResponse = ChecklistResponseGenerator('DeveloperName, LastModifiedDate, LastModifiedBy.name from FieldSet',true);
            System.debug('RecordType!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONRecordType objfromJSONName =  (fromJSONRecordType) System.JSON.deserialize(strJsonResponse, fromJSONRecordType.class);
            for(cls_recordsRecordType  objJson : objfromJSONName.records)
            {
                recordTypeList.add(objJson);
            }
        }
            
        //Brings out list of all the Field Sets  in the Current Org that are Managed and add to list fieldSetlist.      
        public void fieldSet()
        {
            string strJsonResponse = ChecklistResponseGenerator('DeveloperName,Id,LastModifiedDate, LastModifiedBy.name from FieldSet',true);      
            System.debug('fieldSet!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONDeveloperName objfromJSON = parse(strJsonResponse);
            System.debug('Field Setss!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_records objJson : objfromJSON.records)
            {
                fieldSetlist.add(objJson);
            }
        }
        
        //Brings out list of all the Static Resource  in the Current Org and add to list staticResList.  
        public void staticResource()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,ContentType,LastModifiedby.name from StaticResource',true);
            System.debug('StaticResources!!!!!!!!!!!!!!!'+strJsonResponse);
            fromJSONstaticResoure objfromJSONName =  (fromJSONstaticResoure) System.JSON.deserialize(strJsonResponse, fromJSONstaticResoure.class);
            for(cls_recordsstaticResource  objJson : objfromJSONName.records)
            {
              staticResList.add(objJson);
            }
        }
                      
        //Brings out list of all the S-Controls  in the Current Org that are Managed and add to list scontrollist.     
        public void sControl()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.nAME from Scontrol',true);
            System.debug('sControl!!!!!!!!!!!!!!!'+strJsonResponse);                
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName  objJson : objfromJSONName.records)
            {
              scontrollist.add(objJson);
            }
        }
    
        //Brings out list of all the PageLayouts  in the Current Org that are Managed and add to list pgLayoutList. 
        public void pgLayouts()
        {       
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.name from Layout',true);
            System.debug('pgLayouts!!!!!!!!!'+strJsonResponse);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
              pgLayoutList.add(objJson);
            }          
        }       
        //Brings out list of all the Profiles  in the Current Org  and add to list profileList.             
        public void profiles()
        {
            string strJsonResponse = ChecklistResponseGenerator('Name,LastModifiedDate,LastModifiedBy.Name from profile',true);
            fromJSONName objfromJSONName =  (fromJSONName) System.JSON.deserialize(strJsonResponse, fromJSONName.class);
            for(cls_recordsName objJson : objfromJSONName.records)
            {
                profileList.add(objJson);
            }
        }
       
       
       //This bring all Lightning Applications,Component,Event
       public void DisplayLightningBundle()
        {
            String strJsonResponse = ChecklistResponseGenerator('lastmodifieddate,LastModifiedBy.name,AuraDefinitionBundleId,DefType,Format,Id from AuraDefinition',false);         
            fromJSONLightningBundle objfromJSON =  (fromJSONLightningBundle) System.JSON.deserialize(strJsonResponse, fromJSONLightningBundle.class);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            for(cls_recordsLightning objJson : objfromJSON.records)
            {
                if(objJson.DefType=='APPLICATION' && mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId)!=null )
                  {
                    objJson.Name=mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId);
                    lstAuraApp.add(objJson);  
                    }    
                else if(objJson.DefType=='COMPONENT' && mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId)!=null)
                    {
                    objJson.Name=mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId);
                    lstAuraComponent.add(objJson);
                    }      
                else if(objJson.DefType=='EVENT' && mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId)!=null)
                    {
                    objJson.Name=mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId);
                    lstAuraEvent.add(objJson); 
                    }     
                else if(objJson.DefType=='TOKENS' && mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId)!=null)
                {
                    objJson.Name=mapOfIdVsAuraName.get(objJson.AuraDefinitionBundleId);
                    lstAuraToken.add(objJson);
                }
                       
            }
            system.debug('insha'+  lstAuraApp +'lstAuraEvent' +lstAuraEvent+  'lstAuraComponent'+lstAuraComponent);
        }
        
        public Map<Id,String> getMapofIdvsAuraName()
        {
            String strJsonResponse = ChecklistResponseGenerator('Id,lastmodifieddate,LastModifiedBy.name,DeveloperName from AuraDefinitionBundle',false);         
            fromJSONLightningBundleDevName objfromJSON =  (fromJSONLightningBundleDevName) System.JSON.deserialize(strJsonResponse, fromJSONLightningBundleDevName.class);
            System.debug('custom objects!!!!!!!!!!!!!!!!!'+strJsonResponse);
            Map<Id,String> mapOfreturn = new Map<Id,String>();
            for(cls_recordsLightningDevNames objJson : objfromJSON.records)
            {      
             mapOfreturn.put(objJson.Id,objJson.DeveloperName);          
            }
            system.debug('mapOfreturn'+  mapOfreturn);
            return mapOfreturn;
        }
        
        public class fromJSONName{
        public Integer size;    //227
        public Integer totalSize;   //227
        public boolean done;
        public cls_queryLocator queryLocator;
        public String entityTypeName;   //CustomObject
        public cls_recordsName[] records;
        }
      
          // public fromJSONName parse(String json){
         //   return (fromJSONName) System.JSON.deserialize(json, fromJSONName.class);
       // }
       
        public class fromJSONCustomFields{
        public Integer size;    //2179
        public Integer totalSize;   //2179
        public boolean done;
        public String nextRecordsUrl;   ///services/data/v36.0/tooling/query/01g2800000dtcwMAAQ-2000
        public String queryLocator; //01g2800000dtcwMAAQ-2000
        public String entityTypeName;   //CustomField
        public cls_records[] records;
    }    

        public class fromJSONValidationRule{
                public Integer size;    //5
                public Integer totalSize;   //5
                public boolean done;
                public cls_queryLocator queryLocator;
                public String entityTypeName;   //ValidationRule
                public cls_recordsValidationRule[] records;
        }
        
        //Added By Insha
        public class fromJSONLightningBundle{
                public Integer size;    //5
                public Integer totalSize;   //5
                public boolean done;
                public cls_queryLocator queryLocator;
                public String entityTypeName;   //ValidationRule
                public cls_recordsLightning[] records;
        }

        public class fromJSONLightningBundleDevName{
                public Integer size;    //5
                public Integer totalSize;   //5
                public boolean done;
                public cls_queryLocator queryLocator;
                public String entityTypeName;   //ValidationRule
                public cls_recordsLightningDevNames[] records;
        }
        
        public class fromJSONDeveloperName{
        public Integer size;    //227
        public Integer totalSize;   //227
        public boolean done;
        public cls_queryLocator queryLocator;
        public String entityTypeName;   //CustomObject
        public cls_records[] records;
        }
        
        public fromJSONDeveloperName parse(String json){
            return (fromJSONDeveloperName) System.JSON.deserialize(json, fromJSONDeveloperName.class);
           
        }
        
        public  class cls_queryLocator {
        }   
        
         public class cls_recordsValidationRule {
          public cls_attributes attributes{get;set;}
          public String LastModifiedDate{get;set;} //2015-12-08T10:35:24.000+0000
          public String ValidationName{get;set;}  //Zip_code_must_be_Valid_US_Postal_Code
          public cls_LastModifiedBy LastModifiedBy{get;set;}
        }
        
        public class cls_recordsName 
        {
          public cls_attributes attributes{get;set;}
          public String LastModifiedDate{get;set;} //2016-01-13T12:11:22.000+0000
          public String Name{get;set;} //FileGenMetadata
          public string DisplayType {get;set;}
          public string LinkType {get;set;}
          public string EntityDefinitionId {get;set;}
          public string UserLicenseId {get;set;}     
          public string sobjectType {get;set;}
          public boolean Active{get;set;}
          public cls_LastModifiedBy LastModifiedBy{get;set;}
        }
        public class cls_records 
        {
            public cls_attributes attributes{get;set;}
            public String LastModifiedDate{get;set;}//2016-01-08T06:16:16.000+0000
            public String DeveloperName{get;set;}
            public String Id{get;set;}
            public String TableEnumOrId{get;set;}
            public boolean IsCustomSetting {get;set;}
            public string Type {get;set;}
            public string sobjectType {get;set;}
            public string State {get;set;}
            public cls_LastModifiedBy LastModifiedBy{get;set;}     //Trail
        }
       public class cls_attributes 
       {
            public String type{get;set;} //CustomObject
            public String url{get;set;}  ///services/data/v36.0/tooling/sobjects/CustomObject/01I28000000meZOEAY
        }
        public class fromJSONPB{
        public Integer size;    //1
        public Integer totalSize;   //1
        public boolean done;
        public cls_queryLocator queryLocator;
        public String entityTypeName;   //Flow
        public cls_recordsPB[] records;
    }
       public class cls_recordsPB {
        public cls_attributes attributes;
        public String MasterLabel{get;set;}   //TodayProcess
        public String Status{get;set;}   //Active
        public String ManageableState{get;set;} 
        public cls_LastModifiedBy LastModifiedBy{get;set;}   //unmanaged
        }
        public class cls_LastModifiedBy {
            public cls_attributes attributes{get;set;} 
            public String Name{get;set;}//Ankita Maheshwari
        }
        
        public class fromJSONRecordType{
        public Integer size;    //8
        public Integer totalSize;   //8
        public boolean done;
        public cls_queryLocator queryLocator;
        public String entityTypeName;   //RecordType
        public cls_recordsRecordType[] records;
        }
        public class cls_recordsRecordType {
        public cls_attributes attributes{get;set;} 
        public String Name{get;set;}    //Completion
        public String SobjectType{get;set;}     //Metric
        public String LastModifiedDate{get;set;}    //2015-12-03T05:12:00.000+0000
        public cls_LastModifiedBy LastModifiedBy{get;set;} 
        }
         
        public class fromJSONstaticResoure{
        public Integer size;    //67
        public Integer totalSize;   //67
        public boolean done;
        public cls_queryLocator queryLocator;
        public String entityTypeName;   //StaticResource
        public cls_recordsstaticResource[] records;
        }
        public class cls_recordsstaticResource 
        {
            public cls_attributes attributes{get;set;}
            public String Name{get;set;}    //AceEditor
            public String LastModifiedDate{get;set;}    //2016-01-13T12:47:17.000+0000
            public String ContentType{get;set;} //application/zip
            public cls_LastModifiedBy LastModifiedBy{get;set;}
        }
        public class cls_recordsLightning 
        {
            public String AuraDefinitionBundleId{get;set;}    
            public String Id;
            public String Name{get;set;}
            public String LastModifiedDate{get;set;}    //2016-01-13T12:47:17.000+0000
            public String DefType{get;set;} 
            public cls_LastModifiedBy LastModifiedBy{get;set;}
        }
        public class cls_recordsLightningDevNames 
        {
            public String Id{get;set;}    
            public String LastModifiedDate{get;set;}    //2016-01-13T12:47:17.000+0000
            public String DeveloperName{get;set;} 
            public cls_LastModifiedBy LastModifiedBy{get;set;}
        }
}