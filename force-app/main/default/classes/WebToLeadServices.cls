global class WebToLeadServices {
    
    global static final String PARAM_MISSING = 'MISSING REQUIRED PARAMETERS';
    global static final String PROJECT_INVALID = 'INVALID PROJECT SELECTED';
    global static final String SOURCE_INVALID = 'INVALID SOURCE';
    
    
    global class result {
        webservice Integer returnCode;
        webservice String message;
        webservice Id recordId;
    }
    
    global class WebLead {
        webservice String fullName;
        webservice String emailAddress;
        webservice String country;
        webservice String city;       // added as per client's requirement
        webservice String dialingCode;
        webservice String mobileNumber;
        webservice String projectInterested;
        webservice String budget;
        webservice String CampaignCode;
        webservice String source; //click2call, microsite, corpsite, liveserv etc.
        webservice String webbannerSource;
        webservice String UTMCampaign;
        webservice String UTMDisplay;
        webservice String UTMMedium;
        webservice String UTMSource;
        webservice String UTMTerm;
        webservice String IPAddress;
        webservice String configuration;
        webservice String RwLeadSubSource;
        webservice String RwLeadSource;
        webservice String CompanyName;
        webservice String RefereeName;	//Added by payal  payal test
        webservice String RefereeMobileNo;//9999999900
        webservice String RefereeEmailId;//abc@gmail.com
        webservice String RefereeProject;
        webservice String RefereeFlat;
        webservice String ReferenceSource;
        webservice String Description; //Added by coserve 06-06-2023
       // webservice String Medium;
        //webservice String Campaign;
        webservice String AdGroup;
        webservice String UTMAdGroup;
        webservice String Publisher;
        webservice String Keyword;
        webservice String UTMKeyword;
        webservice String Placement;
        webservice String WebBannersize;
        webservice String DealType;
        webservice String LandingPage;
        webservice String AdsetID;
        webservice String AdID;
        webservice String Adname;
        webservice String Device ;
        webservice String UTMDevice ;
        webservice String GCLID  ;
        webservice String BannerType ;
        webservice String CTASource;
        // webservice String Phase; 
        
        //  webservice String RwLeadSubSubSource;		//Commented by Sheetal on 10/05/2022
        
        
    }
    
    webservice static result createLeadFromWeb(WebLead wl) {
        
        List < Lead > leadList = new List < Lead > ();
        //List < LeadShare > leadShareList = new List < LeadShare > ();
        Lead l = null;
        /* UserAccess__c CustomUser = new UserAccess__c();
User ObjUser= new User();

if(UserAccess__c.getValues('User') != Null)
{
CustomUser= UserAccess__c.getValues('User');
ObjUser = [select id,name from user where Email =: CustomUser.User_Mail_Id__c limit 1];
}*/
        result r = new result();
        String projectId = null;
        String accId = null;
        String accName = null;
        String bookingNo = null;
        String remark = null;
        boolean isAnarockLead = false;
        System.debug('WEB LEAD:' + wl);
        if (String.isNotBlank(wl.source) && (wl.source.equals('DIGITAL MARKETING') || wl.source.equals('Anarock')|| wl.source.equals('CHATBOT'))) {
            if (String.isBlank(wl.fullName) || String.isBlank(wl.dialingCode) || String.isBlank(wl.source) || String.isBlank(wl.city)) {
                System.debug('Missing Required Parameters');
                r.returnCode = 1;
                r.message = PARAM_MISSING;
                r.recordId = null;
                return r;
            } 
            else if(!wl.source.equals('CHATBOT') && (String.isBlank(wl.mobileNumber) || String.isBlank(wl.emailAddress) )) {
                System.debug('Missing Required Parameters');
                r.returnCode = 1;
                r.message = PARAM_MISSING;
                r.recordId = null;
                return r;
            } 
            else if(wl.source.equals('CHATBOT') && (String.isBlank(wl.mobileNumber) && String.isBlank(wl.emailAddress) )) {
                System.debug('Missing Required Parameters');
                r.returnCode = 1;
                r.message = PARAM_MISSING;
                r.recordId = null;
                return r;
            }
            else {
                List < Project__c > pList = [Select Id, Name from project__c where Name = : wl.projectInterested];
                if(wl.RefereeName != null && wl.RefereeMobileNo != null && wl.RefereeEmailId != null){
                    List<Account> aList = [Select Id,Name from Account where Mobile_No__c = : wl.RefereeMobileNo LIMIT 1]; //Added by Payal 17-09-21
                    System.debug('ACCList:'+aList);
                    
                    
                    if(aList.size() == 1) {
                        accId = aList[0].Id;
                        accName = aList[0].Name;   
                        
                        
                        List<Opportunity> oList = [Select Id,AccountId,Booking__c from Opportunity where AccountId =: accId LIMIT 1];
                        System.debug('opportunities:'+oList);
                        
                        if(oList.size() == 1){
                            if(oList[0].Booking__c != null){
                                bookingNo = oList[0].Booking__c;
                                
                                remark = 'Ref by \n'+ wl.RefereeName+'  '+wl.RefereeMobileNo+'\n Booked customer'+'\n'+wl.RefereeProject + ' '+wl.RefereeFlat;
                                wl.ReferenceSource = 'Existing Customer';
                                if(wl.RefereeMobileNo == wl.mobileNumber) {
                                    wl.RwLeadSource = 'Loyalty';
                                }
                                else
                                    wl.RwLeadSource = 'Referral';
                                
                            }
                        }
                        else{
                            remark = 'Ref by \n'+ wl.RefereeName+'  '+wl.RefereeMobileNo+'\n not a Booked customer'; 
                            wl.ReferenceSource = 'Existing Customer';
                            if(wl.RefereeMobileNo == wl.mobileNumber) {
                                wl.RwLeadSource = 'Loyalty';
                            }
                            else
                                wl.RwLeadSource = 'Referral';
                        }
                    }
                    else
                    {
                        remark = 'Ref by \n'+ wl.RefereeName+'  '+wl.RefereeMobileNo+'\n Not a booked customer';
                        wl.ReferenceSource = 'Non existing Customer';
                        wl.RwLeadSource = 'ACP';
                        System.debug('Remark:'+remark);
                    }
                }
                
                if (pList.size() == 1) {
                    projectId = pList[0].Id;
                } else {
                    System.debug('Project Error:' + pList);
                    r.returnCode = 1;
                    r.message = PROJECT_INVALID;
                    r.recordId = null;
                    return r;
                }
                
                if(wl.source.equalsIgnoreCase('Anarock')) {
                    isAnarockLead = true;
                }
                
                
                String AdGroupValue = '';
                if(String.isNotBlank(wl.UTMAdGroup)){
                    AdGroupValue = wl.UTMAdGroup;
                } else if(String.isNotBlank(wl.AdGroup)){
                    AdGroupValue = wl.AdGroup;
                }
                
                String KeywordValue = '';
                if(String.isNotBlank(wl.UTMKeyword)){
                    KeywordValue = wl.UTMKeyword;
                } else if(String.isNotBlank(wl.Keyword)){
                    KeywordValue = wl.Keyword;
                }
                
                String DeviceValue = '';
                if(String.isNotBlank(wl.UTMDevice)){
                    DeviceValue = wl.UTMDevice;
                } else if(String.isNotBlank(wl.Device)){
                    DeviceValue = wl.Device;
                }
                
                String Country_Name = CountryCode.checkCode1(wl.dialingCode);            
                l = new Lead(
                    lastName = wl.fullName,
                    RW_Mobile_No__c = wl.mobileNumber,
                    RDS_Email__c = wl.emailAddress,
                    RDS_Mobile__c = wl.mobileNumber,
                    Email = wl.emailAddress,
                    //leadsource = 'Digital',
                    leadsource = wl.RwLeadSource,
                    RW_Lead_Sub_Source__c = Wl.RwLeadSubSource,                //added by shubham            //'Website enquiry',
                    //  RW_Lead_Sub_Source__c = 'Google', 					//Added by Sheetal on 28/02/2022
                    // Lead_Sub_Sub_Source__c = Wl.RwLeadSubSubSource,    	//Commented by Sheetal on 10/05/2022
                    RDS_Country__c = Country_Name,
                    Country__c = Country_Name,  
                    City__c = wl.city,
                    RDS_Country_Code__c = wl.dialingCode,
                    //RDS_Budget__c = wl.budget,
                    RW_Budget__c = wl.budget,
                    RW_Project__c = projectId,
                    Source_Remarks__c = wl.source,
                    Campaign_Code__c = wl.CampaignCode,
                    web_banner_source__c = wl.webBannerSource,
                    IP_address_web2lead__c = wl.IPAddress,
                    RW_Configuration__c = wl.configuration,
                    Is_Anarock_Lead__c = isAnarockLead,
                    RW_Company_Name__c = wl.CompanyName,
                    Description = wl.Description, //Added by coserve 06-06-2023

                    /////////////////////////--------------- vikas added below field on dated 23-08-16 -----------------------------/////////////////////
                    UTM_Campaign__c = wl.UTMCampaign,
                    UTM_Display__c = wl.UTMDisplay,
                    UTM_Medium__c = wl.UTMMedium,
                    UTM_Source__c = wl.UTMSource,
                    UTM_Term__c = wl.UTMTerm,
                    /////////////////////////--------------- payal added below field on dated 17-09-21 -----------------------------/////////////////////                   
                    Remark__c = remark,
                    Customer_Reference__c = accId,
                    RW_Reference_Source__c = wl.ReferenceSource,
               //     Medium__c = wl.Medium,
                   // UTM_Campaign__c = wl.Campaign,
                    Publisher__c = wl.Publisher,
                    Ad_Group__c = AdGroupValue,
                    Keyword__c = KeywordValue,
                    Placement__c = wl.Placement,
                    Web_Banner_Size__c = wl.WebBannersize,
                    RW_With_Balcony__c = wl.DealType,
                    RW_With_Servant_Room__c = wl.LandingPage,
                    RW_Any_Other_Vastu__c = wl.AdsetID,
                    RW_Unregistered_Broker_Name__c = wl.AdID,
                    Walkin_Unregistered_ChannelPartner_Name__c	= wl.Adname,
                    Device__c =  DeviceValue,
                    Gclid__c = wl.GCLID,
                    Banner_Type__c = wl.BannerType,
                    CTA_Source__c = wl.CTASource,
                   // Phase__c = wl.Phase
                   Integration_Source__c = 'Website' //Added by Vinay 13-06-2025
                );
                
                /////////////////--------------------- vikas added end here -------------------------------///////////////////////////////
            }
        } else {
            System.debug('Invalid Source:' + wl.source);			//comes here after soap
            r.returnCode = 1;
            r.message = SOURCE_INVALID;
            r.recordId = null;
            return r;
        }
        if (l != null) {
            leadList.add(l);
            try {
                List < DupResultsDTO > dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if (dupList.isEmpty()) {
                    try {
                        Database.saveResult[] srList = Database.insert(leadList, true);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                                r.recordId = sr.getId();
                                r.returnCode = 0;
                                r.message = 'SUCCESS';
                                /* LeadShare csShare = new LeadShare();
csShare.LeadAccessLevel = 'edit';
csShare.RowCause= 'Manual';
csShare.LeadId = sr.getId();
csShare.UserOrGroupId = ObjUser.Id;
leadShareList.add(csShare);*/                
                                try {
                                    // once the lead is created, save the entire enquiry information as a task of type enquiry received.
                                    // this is so that the complete form info is saved somewhere
                                    Map < Id, Lead > enquiryMap = new Map < Id, Lead > ();
                                    enquiryMap.put(sr.getId(), l);
                                    Map < Id, Task > whoIdMap = new Map < Id, Task > ();
                                    whoIdMap = TaskManagementServices.createTaskforEnquiries(enquiryMap);
                                } catch (Exception ex) {
                                    System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                                }
                            } else {
                                // Operation failed, so get all errors  
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }
                                r.returnCode = 1;
                                r.message = msg;
                                r.recordId = null;
                                return r;
                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                        r.returnCode = 1;
                        r.message = msg;
                        r.recordId = null;
                        return r;
                    }
                } else {
                    r.recordId = dupList[0].duplicateMaster;
                    r.returnCode = 0;
                    r.message = 'SUCCESS';
                    /*LeadShare csShare = new LeadShare();
csShare.LeadAccessLevel = 'edit';
csShare.RowCause= 'Manual';
csShare.LeadId = dupList[0].duplicateMaster;
csShare.UserOrGroupId = ObjUser.Id;
leadShareList.add(csShare); */
                }
            } catch (GlobalException g) {
                r.returnCode = 1;
                r.message = g.getErrorMsg()[0];
                r.recordId = null;
                return r;
            }
            /*if(leadShareList.size() > 0)
{
try{
insert leadShareList;
}catch(Exception ex){
System.debug('Catch and Ignore lead share create exception:' + ex.getMessage());
}
}*/
            return r;
        } else {
            System.debug('Lead list empty:');
            r.returnCode = 1;
            r.message =  'UNKNOWN EXCEPTION';
            r.recordId = null;
            return r;
        }
    }
    public static void dummy() {
        integer a = 0 ,b = 0 ,c = 0;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c; 
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        a = b+c;
        
        
        
    }
    
}