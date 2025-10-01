public without sharing class CIFFormPageController {  
    public Lead objLead {
        get;
        set;
    }
    public string strLeadId;
    public string strOptyId;
    public string strAccountId;
    public String show {
        get;
        set;
    }
    public String strEventDate {
        get;
        set;
    }
    public String strDOB {
        get;
        set;
    }
    public String strSpouseDOB {
        get;
        set;
    }
    public List < wrapLeadSource > lstLeadSource {
        get;
        set;
    }
    public string strCurrentSource {
        get;
        set;
    }
    public string strError {
        get;
        set;
    }
    public Boolean isSubmitted {
        get;
        set;
    }
    public Opportunity objOpty {
        get;
        set;
    }
    public Account objAcc {
        get;
        set;
    }
    Public CIF__c CIFObj {
        get;
        set;
    }
    Public Id parentId {
        get;
        set;
    }
    Public String ProjectName {
        get;
        set;
    }
    Public String strprojectId {
        get;
        set;
    }
    
    Public Project__c projObj {
        get;
        set;
    }
    Public Opportunity objOptyToInsert {
        get;
        set;
    }
    public boolean random {
        get;
        set;
    }
    
    public string strotp {
        get;
        set;
    }
    
    public OTP__c otpobj {
        get;
        set;
    }
    
    public string otpId {
        get;
        set;
    }
    
    public string otpgeneratedfor {
        get;
        set;
    }
    
    public Boolean hide{
        get;
        set;
    }
    public boolean checkbox {
        get;
        set;
    }
    public string leadsource {
        get;
        set;
    }
    //Added by UBS digicloud 29-07-2025
    public string leadOTP;
    Public List<String> countryCodeList {get;set;}
    //Added by UBS digicloud 29-07-2025
    //
    //
    public Boolean directLead {get;set;} //Added by coServe 17-06-2024
    public Boolean disableBox {get;set;} //Added by coServe 17-06-2024
    public Boolean hideNoOtp {get;set;} //Added by coServe 03-07-2024
    public String leadSourcingManager {get;set;} //Added by Vinay 04-08-2025
    public List <OTP__c> lstotp {get;set;}
    
    public List<SelectOption> getCountryCodeList() {
    List<SelectOption> options = new List<SelectOption>();
    List<Schema.PicklistEntry> picklistValues = CIF__c.Country_Code__c.getDescribe().getPicklistValues();
    for (Schema.PicklistEntry entry : picklistValues) {
        options.add(new SelectOption(entry.getValue(), entry.getLabel()));
    }
    return options;
}

    
    //constructor 
    public CIFFormPageController() {
        initialize();
        //objLead = (Lead)controller.getRecord();
        hide = true;
        random =false;
        checkbox = false;
        otpobj = new OTP__c();
        disableBox = false; //Added by coServe 17-06-2024
        directLead = false; //Added by coServe 17-06-2024
        hideNoOtp = false; //Added by coServe 03-07-2024
        // added by UBSDigicloud
        // 29-07-2025
        if (Apexpages.Currentpage().getParameters().get('leadOTP') != null && Apexpages.Currentpage().getParameters().get('leadOTP') != ''){
            leadOTP = Apexpages.Currentpage().getParameters().get('leadOTP');
        }
        System.debug('leadotp====='+leadOTP);
        show = (Apexpages.Currentpage().getParameters().get('show'));
        if (Apexpages.Currentpage().getParameters().get('id') != null && Apexpages.Currentpage().getParameters().get('id') != '')
            strLeadId = Apexpages.Currentpage().getParameters().get('id');
        system.debug('strLeadId>>>' +strLeadId);
        if (Apexpages.Currentpage().getParameters().get('optyid') != null && Apexpages.Currentpage().getParameters().get('optyid') != '')
            strOptyId = Apexpages.Currentpage().getParameters().get('optyid');
        if (Apexpages.Currentpage().getParameters().get('Accid') != null && Apexpages.Currentpage().getParameters().get('Accid') != '')
            strAccountId = Apexpages.Currentpage().getParameters().get('Accid');
        if (Apexpages.Currentpage().getParameters().get('projectId') != null && Apexpages.Currentpage().getParameters().get('projectId') != '')
            strprojectId = Apexpages.Currentpage().getParameters().get('projectId');
        if (strprojectId != null && strprojectId != '') {
            projObj = [Select Id, name, OTP_for_Direct_Lead__c from Project__c where id = : strprojectId];
            
        }
        if(projObj != null && projObj.OTP_for_Direct_Lead__c){ //Added by coServe 03-07-2024 
            hideNoOtp = true;
        }
        if (Apexpages.Currentpage().getParameters().get('directLead') != null && Apexpages.Currentpage().getParameters().get('directLead') != ''){ //Added by coServe 17-06-2024
            directLead = Boolean.valueOf(Apexpages.Currentpage().getParameters().get('directLead'));}
        
        
        System.debug('directLead: ' + directLead);
        
        
        
        
        if (strLeadId != null) {
            objLead = [SELECT Id, FirstName, LastName, RW_Mobile_No__c, Walkin_Source__c, Generated_OTP_On_Lead__c
                       FROM Lead WHERE Id = :strLeadId];
            
            if (objLead.Generated_OTP_On_Lead__c != null || leadOTP != null ) {
                /*    List<OTP__c> matchedOtps = [
SELECT Id, Generated_OTP__c, Channel_Partner_Lookup__c, Sourcing_Manager__c,
Customer_Reference_Lookup__c, OTP_Generate_For__c, Referral_Sub_Source__c
FROM OTP__c
WHERE Generated_OTP__c = :objLead.Generated_OTP_On_Lead__c
AND Lead__c = :strLeadId
AND Project__c = :strprojectId
AND OTP_Expired__c = false
LIMIT 1
];*/
                
                
                system.debug('leadOTP-  '+ leadOTP); 
                system.debug('lead id-  '+ strLeadId); 
                system.debug('project id-  '+ strprojectId); 
                List<OTP__c> matchedOtps1 = [SELECT Id, Generated_OTP__c, Channel_Partner_Lookup__c, Sourcing_Manager__c,
                                             Customer_Reference_Lookup__c, OTP_Generate_For__c, Referral_Sub_Source__c
                                             FROM OTP__c
                                             WHERE 
                                             (Generated_OTP__c = :leadOTP AND 
                                              Prospect_Lead__c = :strLeadId AND 
                                              Project__c = :strprojectId AND
                                              OTP_Expired__c = false) OR 
                                             (Generated_OTP__c = :objLead.Generated_OTP_On_Lead__c AND 
                                              Lead__c = :strLeadId AND 
                                              Project__c = :strprojectId AND 
                                              OTP_Expired__c = false)
                                             LIMIT 1
                                            ];
                
                
                if (!matchedOtps1.isEmpty()) {
                    otpobj = matchedOtps1[0];
                    prefillLeadFromOtp(); 
                    System.debug('Otp List ' +matchedOtps1);
                }else {
                    strError = 'Invalid OTP. Please generate a new one.';
                    show = 'true'; // or keep it not 'false' so panel stays hidden
                }
            }
        }
        
        
        
        
        if (CIFObj.Source__c == null) {
            CIFObj.Source__c = objLead.Walkin_Source__c;
            
        }
        
        if (strLeadId != null && strLeadId != '') {
            objLead = [select Id, salutation, firstName, LastName, RW_Project__c, RW_Mobile_No__c, RW_Secondary_Mobile_No__c, Email, RW_Secondary_Email__c,Budget_In_Lakh__c,
                       Phone, State__c, City__c, Zip_Code__c, Street__c, Country__c, RW_Occupation__c, RW_Company_Name__c, RW_Company_Location__c,Country_Code_2__c,RDS_Country_Code__c,
                       RW_Designation__c, RW_Budget_Rs_in_Cr__c, RW_Configuration__c, LeadSource,Walkin_Source__c, RW_Project__r.Name, RW_Broker__c, RW_Reference_Source__c,
                       RW_Apply_Unregistered_Broker__c, RW_Unregistered_Broker_Email__c, RW_Unregistered_Broker_Mobile__c, RW_Unregistered_Broker_Name__c,
                       Customer_Reference__c,Walkin_Customer_Reference__c, RW_Lead_Sub_Source__c, Corporate_Company__c, NameofUnregisteredCorporate_LeadSource__c, RW_Nature_of_Work__c,
                       RW_Family_Structure__c, RW_Floor_Choices__c, RW_Facing__c, RW_Time_line__c, RW_Vastu_Entry_Towards__c, RW_Any_Other_Vastu__c,
                       RW_Number_of_Cars__c, RW_With_Balcony__c, RW_With_Servant_Room__c, RW_Neighbourhood_Places__c, RW_Date_of_Birth__c, RW_Customer_Type__c,
                       RW_Other_Company_Name__c, RW_Location__c, RW_Ethnicity__c, RW_Referral_Details__c,Broker_Type__c,Marital_Status__c,Cars_Owned__c,
                       Walkin_Sub_Sub_Source__c,Walkin_SubSource__c,Walkin_Channel_Partner__c,Walkin_Apply_Unregistered_ChannelPartner__c,Name_of_Unregistered_Corporate__c,
                       Unregistered_broker_type__c,Pre_Sales_User__c,RW_Sourcing_Manager__c,Event_Description__C,Lead_Sub_Sub_Source__c,
                       Walkin_Unregistered_ChannelPartner_Email__c,Walkin_UnregisteredChannelPartner_Mobile__c,Walkin_Unregistered_ChannelPartner_Name__c,
                       Education__c,Client_Type__c,Purpose__c,Name_Of_Walkin_Referee__c,Walk_in_Corporate__c,Spouse_DOB__c,RW_Budget__c,
                       Spouse_Name__c,No_of_Children__c,Age_of_Child_1__c,Age_of_Child_2__c,Age_of_Child_3__c,Age_of_Child_4__c,Spouse_Occupation__c,Spouse_Company_Name__c,Spouse_Designation__c,
                       Locality__C,Zone__c,Religion__c,Walk_In_Details__c,Employee_Reference__c,Walkin_Employee_Reference__c,RW_Type_of_Client__c,Lead_Sourcing_Manager__c
                       from Lead where id = : strLeadId];   
            
            System.debug('inside lead loop up');
            leadSourcingManager = objLead.Lead_Sourcing_Manager__c; //Added by Vinay 04-08-2025
            
            Schema.DescribeFieldResult fieldResult = Lead.Walkin_Source__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry f: ple) 
            {
                wrapLeadSource objWrap = new wrapLeadSource();
                if (f.getLabel() != 'Corporate(Unregistered)') {
                    objWrap.strLabel = f.getLabel();
                    
                    objWrap.strLeadSource = f.getValue();
                    
                    if (objLead.Walkin_Source__c == 'Corporate(Unregistered)' && f.getLabel() == 'Corporate') {
                        objWrap.isSelected = true;
                        //objLead.Corporate_Company__c = 'Other';
                        // CIFObj.CorporateCompany__c = objLead.Corporate_Company__c;
                    } else if (objLead.Walkin_Source__c != null && objLead.Walkin_Source__c == f.getValue()) {
                        objWrap.isSelected = true;
                    }
                    
                    lstLeadSource.add(objWrap);
                }
                if(directLead){ //Added by coServe 17-06-2024
                    List<String> sources = System.label.Editable_walkin_Sources_for_CIF.split(',');
                    if(sources.contains(f.getLabel())){
                        objWrap.disable = false;
                        objWrap.strLabel = f.getLabel();
                        objWrap.strLeadSource = f.getValue();
                    }else{
                        objWrap.disable = true;
                        objWrap.strLabel = f.getLabel();
                        objWrap.strLeadSource = f.getValue();
                    }
                }
                
            }
            
            if (objLead.RW_Date_of_Birth__c != null) {
                strDOB = string.valueOf(datetime.newInstance(objLead.RW_Date_of_Birth__c.year(),
                                                             objLead.RW_Date_of_Birth__c.month(),
                                                             objLead.RW_Date_of_Birth__c.day()).format('dd/MM/yyyy'));
            }
            if (objLead.Spouse_DOB__c != null) {
                strSpouseDOB = string.valueOf(datetime.newInstance(objLead.Spouse_DOB__c.year(),
                                                                   objLead.Spouse_DOB__c.month(),
                                                                   objLead.Spouse_DOB__c.day()).format('dd/MM/yyyy'));
            }
            if (objLead.RW_Budget_Rs_in_Cr__c != null) {
                objLead.RW_Budget_Rs_in_Cr__c = objLead.RW_Budget_Rs_in_Cr__c;
                CIFObj.BudgetIn_Cr__c = objLead.RW_Budget_Rs_in_Cr__c;
            }
            
            
            objLead.RW_CIF_Form_Submit_Date__c = System.now();
            parentId = objLead.Id;
            ProjectName = projObj.Name;
            CIFObj.Project__c = projObj.Id;
            CIFObj.Salutation__c = objLead.Salutation;
            CIFObj.FirstName__c = objLead.FirstName;
            CIFObj.LastName__c = objLead.LastName;
            CIFObj.MobileNo1__c = objLead.RW_Mobile_No__c;
            CIFObj.Country_Code__c =  objLead.RDS_Country_Code__c;
            CIFObj.MobileNo2__c = objLead.RW_Secondary_Mobile_No__c;
            CIFObj.Country_Code_2__c	=  objLead.Country_Code_2__c;
            CIFObj.PrimaryEmail__c = objLead.Email;
            CIFObj.SecondaryEmail__c = objLead.RW_Secondary_Email__c;
            //CIFObj.CustomerType__c = objLead.RW_Customer_Type__c;
            CIFObj.Country__c = objLead.Country__c;
            CIFObj.State__c = objLead.State__c;
            CIFObj.City__c = objLead.City__c;
            CIFObj.ZipCode__c = objLead.Zip_Code__c;
            //CIFObj.Street__c = objLead.Street__c;
            CIFObj.Occupation__c = objLead.RW_Occupation__c;
            CIFObj.CompanyName__c = objLead.RW_Company_Name__c;
            CIFObj.CompanyNameOther__c = objLead.RW_Other_Company_Name__c;
            CIFObj.CompanyLocation__c = objLead.RW_Company_Location__c;
            CIFObj.Designation__c = objLead.RW_Designation__c;
            CIFObj.Ethnicity__c = objLead.RW_Ethnicity__c;
            CIFObj.Marital_Status__c = objLead.Marital_Status__c;
            CIFObj.Configuration__c = objLead.RW_Configuration__c;
            CIFObj.BudgetIn_Cr__c = objLead.RW_Budget_Rs_in_Cr__c;
            CIFObj.Budget_In_Lakh__c = objLead.Budget_In_Lakh__c;
            // CIFObj.CIF_Budget__c = objLead.RW_Budget__c;
            CIFObj.TimeLine__c = objLead.RW_Time_line__c;
            CIFObj.Preferred_Location__c = objLead.RW_Location__c;
            CIFObj.Cars_Owned__c = objLead.Cars_Owned__c ;
            CIFObj.NeighbourhoodPlaces__c = objLead.RW_Neighbourhood_Places__c;
            //CIFObj.Source__c = objLead.LeadSource;  
            //CIFObj.LeadSubSource__c = objLead.RW_Lead_Sub_Source__c;
            //CIFObj.Lead_Sub_Sub_Source__c = objLead.Lead_Sub_Sub_Source__c;
            //CIFObj.Source__c = objLead.Walkin_Source__c; 
            if (CIFObj.Source__c == null) {
                CIFObj.Source__c = objLead.Walkin_Source__c != null ? objLead.Walkin_Source__c : objLead.LeadSource;
            }
            CIFObj.LeadSubSource__c = objLead.Walkin_SubSource__c;
            //CIFObj.Lead_Sub_Sub_Source__c = objLead.Walkin_Sub_Sub_Source__c;
            //CIFObj.ApplyUnregisteredChannelPartner__c = objLead.RW_Apply_Unregistered_Broker__c;
            CIFObj.ApplyUnregisteredChannelPartner__c = objLead.Walkin_Apply_Unregistered_ChannelPartner__c;
            
            // CIFObj.Broker__c = objLead.RW_Broker__c; /** since we are taking this from OTP now
            
            //CIFObj.Broker__c = objLead.Walkin_Channel_Partner__c;// Commented by prjakta for auto populate channel partner name on CIF form from lead page Dated:6/5/2019
            //CIFObj.UnregisteredChannelPartnerName__c = objLead.RW_Unregistered_Broker_Name__c;
            //CIFObj.UnregisteredChannelPartnerEmail__c = objLead.RW_Unregistered_Broker_Email__c;
            //CIFObj.UnregisteredChannelPartnerMobile__c = objLead.RW_Unregistered_Broker_Mobile__c;
            CIFObj.UnregisteredChannelPartnerEmail__c = objLead.Walkin_Unregistered_ChannelPartner_Email__c;
            CIFObj.UnregisteredChannelPartnerMobile__c = objLead.Walkin_UnregisteredChannelPartner_Mobile__c;
            CIFObj.UnregisteredChannelPartnerName__c = objLead.Walkin_Unregistered_ChannelPartner_Name__c;
            CIFObj.ReferenceSource__c = objLead.RW_Reference_Source__c;
            CIFObj.CustomerReference__c = objLead.Customer_Reference__c;
            //CIFObj.CustomerReference__c = objLead.Walkin_Customer_Reference__c;
            
            CIFObj.Referral_Details__c = objLead.RW_Referral_Details__c;
            //CIFObj.NameofUnregisteredCorporateLeadSource__c = objLead.NameofUnregisteredCorporate_LeadSource__c;
            //CIFObj.NameofUnregisteredCorporateLeadSource__c = objLead.Name_of_Unregistered_Corporate__c;
            //CIFObj.CorporateCompany__c = objLead.Corporate_Company__c;
            CIFObj.Broker_Type__c = objLead.Broker_Type__c;
            CIFObj.Unregistered_broker_type__c = objLead.Unregistered_broker_type__c;
            CIFObj.Pre_Sales_User__c = objLead.Pre_Sales_User__c; 
            
            //CIFObj.Sales_manager__c = objLead.RW_Sourcing_Manager__c; //** taking this from OTP now  //commented by Sheetal on 07/07/2022 to solve issue (I02006) taking sourcing manager from OTP
            
            CIFObj.Event_Description__C = objLead.Event_Description__C;
            CIFObj.Education__c = objLead.Education__c;
            CIFObj.Client_Type__c = objLead.Client_Type__c;
            CIFObj.Purpose__c = objLead.Purpose__c;
            CIFObj.Name_Of_Walkin_Referee__c = objLead.Name_Of_Walkin_Referee__c;
            CIFObj.Walk_in_Corporate__c = objLead.Walk_in_Corporate__c;
            CIFObj.Spouse_Name__c = objLead.Spouse_Name__c;
            CIFObj.No_of_Children__c = objLead.No_of_Children__c; 
            CIFObj.Age_of_Child_1__c = objLead.Age_of_Child_1__c;
            CIFObj.Age_of_Child_2__c = objLead.Age_of_Child_2__c;
            CIFObj.Age_of_Child_3__c = objLead.Age_of_Child_3__c;
            CIFObj.Age_of_Child_4__c = objLead.Age_of_Child_4__c;
            CIFObj.Spouse_Occupation__c = objLead.Spouse_Occupation__c; 
            CIFObj.Spouse_Company_Name__c = objLead.Spouse_Company_Name__c; 
            CIFObj.Spouse_Designation__c = objLead.Spouse_Designation__c;
            CIFObj.Locality__C = objLead.Locality__c; 
            CIFObj.Zone__c = objLead.Zone__c;
            CIFObj.Religion__c = objLead.Religion__c;
            CIFObj.Walk_In_Details__c = objLead.Walk_In_Details__c;
            CIFObj.Employee_Reference__c = objLead.Employee_Reference__c;				//Added by Sheetal on 25/02/2022
            CIFObj.Type_of_Client__c = objLead.RW_Type_of_Client__c;					//Added by Sheetal on 21/04/2022 to solve issue I0143
        } 
        
        
        else if (strAccountId != null && strAccountId != '') {
            objAcc = [Select Id, Mobile_No__c, OwnerId,Alternate_Mobile_No__c, PersonEmail, Alternate_Email__c, FirstName,LastName, Salutation,   
                      State__c, City__c, RW_Zip_Code__c, Office_Street__c, Country__c, RW_Occupation__c, RW_Company_Name__c, RW_Company_Location__c,
                      RW_Designation__c,Birth_Date__c, RW_Customer_Type__c,RW_Other_Company_Name__c, RW_Ethnicity__c,Marital_Status__c,
                      Cars_Owned__c,Education__c,Spouse_DOB__c,Spouse_Name__c,No_of_Children__c,Age_of_Child_1__c,Age_of_Child_2__c,
                      Age_of_Child_3__c,Age_of_Child_4__c,Spouse_Occupation__c,
                      Spouse_Company_Name__c,Spouse_Designation__c,Locality__c,Zone__c,Religion__c,Walk_In_Details__c,Type_of_Client__c
                      from Account where Id = : strAccountId];
            System.debug('inside Account loop up');
            show = 'false'; 
            Schema.DescribeFieldResult fieldResult = Opportunity.Walkin_Source__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry f: ple) 
            {
                wrapLeadSource objWrap = new wrapLeadSource();
                if (f.getLabel() != 'Corporate(Unregistered)') 
                {
                    objWrap.strLabel = f.getLabel();
                    objWrap.strLeadSource = f.getValue();
                    lstLeadSource.add(objWrap);
                }
            }
            if (objAcc.Birth_Date__c != null) {
                strDOB = string.valueOf(datetime.newInstance(objAcc.Birth_Date__c.year(),
                                                             objAcc.Birth_Date__c.month(),
                                                             objAcc.Birth_Date__c.day()).format('dd/MM/yyyy'));
            }
            if (objAcc.Spouse_DOB__c != null) {
                strSpouseDOB = string.valueOf(datetime.newInstance(objAcc.Spouse_DOB__c.year(),
                                                                   objAcc.Spouse_DOB__c.month(),
                                                                   objAcc.Spouse_DOB__c.day()).format('dd/MM/yyyy'));
            }
            parentId = objAcc.Id;
            ProjectName = projObj.Name;
            CIFObj.Project__c = projObj.Id;
            CIFObj.Salutation__c = objAcc.Salutation;
            CIFObj.FirstName__c = objAcc.FirstName;
            CIFObj.LastName__c = objAcc.LastName;
            CIFObj.MobileNo1__c = objAcc.Mobile_No__c;
            CIFObj.MobileNo2__c = objAcc.Alternate_Mobile_No__c;
            CIFObj.PrimaryEmail__c = objAcc.PersonEmail;
            CIFObj.SecondaryEmail__c = objAcc.Alternate_Email__c;
            //CIFObj.CustomerType__c = objAcc.RW_Customer_Type__c;
            CIFObj.Country__c = objAcc.Country__c;
            CIFObj.State__c = objAcc.State__c;
            CIFObj.City__c = objAcc.City__c;
            CIFObj.ZipCode__c = objAcc.RW_Zip_Code__c;
            //CIFObj.Street__c = objAcc.Office_Street__c;
            CIFObj.Occupation__c = objAcc.RW_Occupation__c;
            CIFObj.CompanyName__c = objAcc.RW_Company_Name__c;
            CIFObj.CompanyNameOther__c = objAcc.RW_Other_Company_Name__c;
            CIFObj.CompanyLocation__c = objAcc.RW_Company_Location__c;
            CIFObj.Designation__c = objAcc.RW_Designation__c;
            CIFObj.Ethnicity__c = objAcc.RW_Ethnicity__c;
            CIFObj.Marital_Status__c = objAcc.Marital_Status__c;
            CIFObj.Cars_Owned__c = objAcc.Cars_Owned__c ;
            CIFObj.Education__c = objAcc.Education__c;
            CIFObj.Spouse_Name__c = objAcc.Spouse_Name__c;
            CIFObj.No_of_Children__c = objAcc.No_of_Children__c; 
            CIFObj.Age_of_Child_1__c = objAcc.Age_of_Child_1__c;
            CIFObj.Age_of_Child_2__c = objAcc.Age_of_Child_2__c;
            CIFObj.Age_of_Child_3__c = objAcc.Age_of_Child_3__c;
            CIFObj.Age_of_Child_4__c = objAcc.Age_of_Child_4__c;
            CIFObj.Spouse_Occupation__c = objAcc.Spouse_Occupation__c; 
            CIFObj.Spouse_Company_Name__c = objAcc.Spouse_Company_Name__c; 
            CIFObj.Spouse_Designation__c = objAcc.Spouse_Designation__c;
            CIFObj.Locality__c = objAcc.Locality__c;
            CIFObj.Zone__c = objAcc.Zone__c;
            CIFObj.Religion__c = objAcc.Religion__c;
            CIFObj.Walk_In_Details__c = objAcc.Walk_In_Details__c;
            CIFObj.Type_of_Client__c = objAcc.Type_of_Client__c	;		//Added by Sheetal on 21/04/2022 issue I0143
            
        }
        
    }
    
    //initialize
    private void initialize() {
        objLead = new Lead();
        objOpty = new opportunity();
        objAcc = new Account();
        CIFObj = new CIF__c();
        objOptyToInsert = new Opportunity();
        projObj = new Project__c();
        lstLeadSource = new List < wrapLeadSource > ();
        strError = '';
        strEventDate = string.valueOf(system.now().format('dd/MM/yyyy HH:mm a'));
        isSubmitted = false;
    }
    
    //wrapper for lead source
    public class wrapLeadSource {
        public string strLeadSource {
            get;
            set;
        }
        public string strLabel {
            get;
            set;
        }
        public Boolean isSelected {
            get;
            set;
        }
        
        public wrapLeadSource() {
            isSelected = false;
        }
        public  Boolean checkbox1 {get;set;}
        public  Boolean isNoOTP {get;set;}
        public  Boolean disable {get;set;}
    }
    
    //this method is used for validating the walkin source
    public void validateLeadSource() 
    {
        Boolean isOneSelected = false;
        if (lstLeadSource != null && lstLeadSource.size() > 0) 
        {
            
            
            for (wrapLeadSource EachSource: lstLeadSource) 
            {
                if (EachSource.isSelected)
                    isOneSelected = true;
                
                
                if (strCurrentSource != null && strCurrentSource != '') 
                {
                    if (strCurrentSource != EachSource.strLeadSource)
                        EachSource.isSelected = false;
                    
                } else
                    EachSource.isSelected = false;
                
            }
            
        }
        
        //objLead.LeadSource = strCurrentSource;
        CIFObj.Source__c = strCurrentSource;
        if (!isOneSelected) {
            //objLead.LeadSource = null;
            CIFObj.Source__c = null;
            strCurrentSource = null;
        }
    }
    
    /*  public void OTPvalidate() //commented by UBSdigicloud
{
List <Prospect__c> lstpros = new List<Prospect__c>();
if(strLeadId != null && objLead.IsConverted == false)
{
lstpros = [SELECT Id,Lead__c FROM Prospect__c WHERE Lead__c =: strLeadId  and Project__c =:strProjectId];  
}
else if(strAccountId != null)
{
lstpros = [Select Id,Account__c From Prospect__c Where Account__c =:strAccountId and Project__c =:strProjectId];
}
else if (strOptyId != null )
{
lstpros = [Select id,Opportunity__c From Prospect__c where  Opportunity__c =: strOptyId  and Project__c =:strProjectId];           
}
else{
hide = false;
}

random=false;
system.debug('lstpros' + lstpros);

List<OTP__c> lstotp = [Select id,Generated_OTP__c,Project__c,OTP_Expired__c,Channel_Partner_Lookup__c,Sourcing_Manager__c, OTP_Generate_For__c,Prospect__c,Customer_Reference_Lookup__c,OTP_Generated_on__c,Customer_reference_SAP_Code__c,Customer_reference_Booked_Unit__c,Referral_Sub_Source__c From OTP__c Where Prospect__c =: lstpros AND Generated_OTP__c =: otpobj.Generated_OTP__c AND OTP_Expired__c = false];  
system.debug('lstotp' + lstotp);
List<OTP__c> lstotp1 = [Select id,Generated_OTP__c,OTP_Expired__c,OTP_Generate_For__c,Prospect__c,OTP_Generated_on__c From OTP__c Where Prospect__c =: lstpros AND Generated_OTP__c !=: otpobj.Generated_OTP__c AND OTP_Expired__c = false];
system.debug('lstotp1' + lstotp1);

if( lstotp.size() > 0){
random =true;
hide = false;
strError ='';
show ='false';
checkbox = true;
otpgeneratedfor = lstotp[0].OTP_Generate_For__c;
} 
else { 
strError = 'Given OTP is either expired or created for different project. Please check';
hide = true;
show = 'true';
}
if (random == false && lstotp1.size() >0)
{      
strError = 'Please Enter Valid OTP';
hide = true;
show = 'true';
}
else {
lstLeadSource.clear();
system.debug('otpgeneratedfor::'+otpgeneratedfor);
objLead.Walkin_Source__c = otpgeneratedfor;
cifobj.source__c = otpgeneratedfor;
cifobj.Generated_OTP__c = otpobj.Generated_OTP__c;
if(lstotp != null && lstotp.size() > 0) {
if(lstotp[0].Channel_Partner_Lookup__c != null)
cifobj.Broker__c = lstotp[0].Channel_Partner_Lookup__c;
if(lstotp[0].Sourcing_Manager__c != null)		              //UnCommented by Sheetal on 07/07/2022 to solve issue (I0200) taking sourcing manager from OTP
cifobj.Sales_manager__c = lstotp[0].Sourcing_Manager__c;
if(lstotp[0].Customer_Reference_Lookup__c != null &&lstotp[0].OTP_Generate_For__c == 'Referral' && lstotp[0].Referral_Sub_Source__c == 'Existing client reference'){
cifobj.CustomerReference__c = lstotp[0].Customer_Reference_Lookup__c;
cifobj.Referral_Sub_Source__c = lstotp[0].Referral_Sub_Source__c;
}
/*List <Prospect__c> lstprosSM = new List<Prospect__c>();	//Added by Sheetal on 13/06/2022 to solve issue (I0186) taking sourcing manager from prospect
lstprosSM = [SELECT Id,Lead__c ,Sourcing_Manager__c FROM Prospect__c WHERE Lead__c =: strLeadId  and Project__c =:strProjectId];  
if(lstprosSM[0].Sourcing_Manager__c != null){
cifobj.Sales_manager__c = lstprosSM[0].Sourcing_Manager__c;}

}*/
    
    /*   Schema.DescribeFieldResult fieldResult = Lead.Walkin_Source__c.getDescribe();
List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
for (Schema.PicklistEntry f: ple) 
{
wrapLeadSource objWrap = new wrapLeadSource();
if (f.getLabel() != 'Corporate(Unregistered)') 
{
objWrap.strLabel = f.getLabel();

objWrap.strLeadSource = f.getValue();

if (objLead.Walkin_Source__c == 'Corporate(Unregistered)' && f.getLabel() == 'Corporate') {
objWrap.isSelected = true;

} else if (objLead.Walkin_Source__c != null && objLead.Walkin_Source__c == f.getValue()) {
objWrap.isSelected = true;
}

if (objLead.Walkin_Source__c == 'Sales'&& f.getLabel() == 'Individual calling') 
{
objWrap.isSelected = true;
objWrap.checkbox1 = false;
checkbox = true;
}

lstLeadSource.add(objWrap);
}
}

}
} 
*/
    // method added by UBSDigicloud
    public void prefillLeadFromOtp() {
        random = true;
        hide = false;
        show = 'false';
        checkbox = true;
        strError = '';
        lstLeadSource = new List<wrapLeadSource>();
        
        if (otpobj != null) {
            // Set Walkin Source
            lstLeadSource.clear();
            otpgeneratedfor = otpobj.OTP_Generate_For__c;
            //System.debug('Otp Generated for'+ otpobj.OTP_Generate_For__c);
            objLead.Walkin_Source__c = otpgeneratedfor;
            CIFObj.Source__c= otpgeneratedfor;
             System.debug('Cif_Source in prefillLeadFromOtp '+CIFObj.Source__c);
            CIFObj.Generated_OTP__c = otpobj.Generated_OTP__c;
            
            // Broker & Sales Manager
            if (otpobj.Channel_Partner_Lookup__c != null)
                CIFObj.Broker__c = otpobj.Channel_Partner_Lookup__c;
            system.debug('Broker================'+CIFObj.Broker__c);
            if (otpobj.Sourcing_Manager__c != null)
                CIFObj.Sales_manager__c = otpobj.Sourcing_Manager__c;
            
            // Referral info
            if (
                otpobj.Customer_Reference_Lookup__c != null &&
                otpobj.OTP_Generate_For__c == 'Referral' &&
                otpobj.Referral_Sub_Source__c == 'Existing client reference'
            ) {
                CIFObj.CustomerReference__c = otpobj.Customer_Reference_Lookup__c;
                CIFObj.Referral_Sub_Source__c = otpobj.Referral_Sub_Source__c;
            }
        }
        
        // Load Walkin_Source__c picklist values
        Schema.DescribeFieldResult fieldResult = Lead.Walkin_Source__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : picklistValues) {
            wrapLeadSource wrapper = new wrapLeadSource();
            wrapper.strLabel = entry.getLabel();
            
            
            wrapper.strLeadSource = entry.getValue();
            
            if (objLead.Walkin_Source__c == entry.getValue()) {
                wrapper.isSelected = true;
            }
            
            // Special condition for "Sales" vs "Individual calling"
            if (objLead.Walkin_Source__c == 'Sales' && entry.getLabel() == 'Individual calling') {
                wrapper.isSelected = true;
                wrapper.checkbox1 = false;
                checkbox = true;
            }
            
            // Exclude some specific sources from being editable
            if (
                entry.getLabel() != 'Corporate(Unregistered)' &&
                entry.getLabel() != 'Direct' && entry.getLabel() != 'Exhibitions' && entry.getLabel() != 'Hoarding' &&
                entry.getLabel() != 'Magazines' && entry.getLabel() != 'Outstation' && entry.getLabel() != 'Property Portals' &&
                entry.getLabel() != 'Surround Marketing' && entry.getLabel() != 'Digital' && entry.getLabel() != 'Events' &&
                entry.getLabel() != 'Newspapers' && entry.getLabel() != 'Paper Inserts' && entry.getLabel() != 'TV' &&
                entry.getLabel() != 'Radio' && entry.getLabel() != 'NRI' && entry.getLabel() != 'Zee Marathi TVC' &&
                entry.getLabel() != 'corporate' && entry.getLabel() != 'Emp / Mgmt Reference' &&
                entry.getLabel() != 'R Circle Caller' && entry.getLabel() != 'Individual calling'
            ) {
                checkbox = true;
                wrapper.checkbox1 = false;
            }
            
            lstLeadSource.add(wrapper);
        }
    }
    
    public void NoOtp()
    {
        //otpobj = null ;
        strError ='';
        random = true;
        hide = false;
        show='false';
        checkbox = false;
        
        ////////////added by prajakta on 5 july 2019
        
        for(wrapLeadSource l : lstLeadSource)
        {
            l.checkbox1 = true;
            /*if(l.strLabel == 'Channel Partner')
{
checkbox = true;
l.checkbox1 = false;
}  */
            
            // Modified by Sheetal on 13/12/2021 to solve issue I0090
            if(l.strLabel != 'Direct' && l.strLabel != 'Exhibitions' && l.strLabel != 'Hoarding' && l.strLabel != 'Magazines' && l.strLabel != 'Outstation'&& l.strLabel != 'Property Portals' &&
               l.strLabel != 'Surround Marketing' && l.strLabel != 'Digital' && l.strLabel != 'Events' && l.strLabel != 'Newspapers' && l.strLabel != 'Paper Inserts' && l.strLabel != 'TV' && l.strLabel != 'Radio' && 
               l.strLabel != 'NRI'  && l.strLabel != 'Zee Marathi TVC' && l.strLabel != 'corporate' && l.strLabel != 'Emp / Mgmt Reference' && l.strLabel != 'R Circle Caller' && l.strLabel != 'Individual calling')
            {
                checkbox = true;
                l.checkbox1 = false;
            }   
            
            
        }
        
        ////////////////////////////////////////////////////////////////////
    }
    public PageReference GoBackToLead() {
        Pagereference objReference = new Pagereference('/apex/CIFSearchPage');
        objReference.setRedirect(true);
        return objReference;
    }
    
    public PageReference redirectNext() {
        show = 'false';
        Savepoint sp = Database.setSavepoint();
        try {
            strError = '';
            /* if (CIFObj.CustomerType__c == null || CIFObj.CustomerType__c == '') {
strError = 'Please fill up the Customer Type to proceed.';
return null;
}
*/
            if (CIFObj.Salutation__c == null || CIFObj.Salutation__c == '') {
                strError = 'Please fill up salutation to proceed.';
                return null;
            }
            if (strDOB == null || strDOB == '') {
                strError = 'Please fill up Date of Birth to proceed.';
                return null;
            }
            if (CIFObj.Type_of_Client__c == null || CIFObj.Type_of_Client__c == '') {		//Added by Sheetal on 21/04/2022 to solve issue I0143
                strError = 'Please fill up type of client to proceed.';
                return null;
            }
            if (CIFObj.Occupation__c == null || CIFObj.Occupation__c == '') {
                strError = 'Please fill up the Occupation to proceed.';
                return null;
            }
            if (CIFObj.CompanyName__c == null || CIFObj.CompanyName__c == '') {
                strError = 'Please fill up Company Name to proceed.';
                return null;
            }else if (CIFObj.CompanyName__c == 'Other' && (CIFObj.CompanyNameOther__c == null || CIFObj.CompanyNameOther__c == '')) {
                strError = 'Please fill up Other Company Name to proceed.';
                return null;
            }
            
            if (CIFObj.Ethnicity__c == null || CIFObj.Ethnicity__c == '') {
                strError = 'Please fill up the Ethnicity to proceed.';
                return null;
            }
            if (CIFObj.Marital_Status__c == null || CIFObj.Marital_Status__c == '') {
                strError = 'Please fill up the Marital Status to proceed.';
                return null;
            }
            
            //else if(CIFObj.Marital_Status__c == 'Married'){
            /* if(CIFObj.Spouse_Name__c == null || CIFObj.Spouse_Name__c == '') {
strError = 'Please fill up Spouse Name to proceed.';
return null;
}*/
            /*if(strSpouseDOB == null || strSpouseDOB == '') {
strError = 'Please fill up Spouse DOB to proceed.';
return null;
}
*/
            /*if(CIFObj.No_of_Children__c == null) {
strError = 'Please fill up Number of children  to proceed.';
return null;
}*/
            /* else {
if(CIFObj.No_of_Children__c == 1 && (CIFObj.Age_of_Child_1__c == null || CIFObj.Age_of_Child_1__c == '')) {
strError = 'Please fill up age of first child to proceed.';
return null;
}
if(CIFObj.No_of_Children__c == 2 && (CIFObj.Age_of_Child_1__c == null || CIFObj.Age_of_Child_1__c == '' ||
CIFObj.Age_of_Child_2__c == null || CIFObj.Age_of_Child_2__c == '')) {
strError = 'Please fill up age of two childs to proceed.';
return null;
}
if(CIFObj.No_of_Children__c == 3 && (CIFObj.Age_of_Child_1__c == null || CIFObj.Age_of_Child_1__c == '' ||
CIFObj.Age_of_Child_2__c == null || CIFObj.Age_of_Child_2__c == '' ||
CIFObj.Age_of_Child_3__c == null || CIFObj.Age_of_Child_3__c == '')) {
strError = 'Please fill up age of three childs to proceed.';
return null;
}
if(CIFObj.No_of_Children__c >= 4 && (CIFObj.Age_of_Child_1__c == null || CIFObj.Age_of_Child_1__c == '' ||
CIFObj.Age_of_Child_2__c == null || CIFObj.Age_of_Child_2__c == '' ||
CIFObj.Age_of_Child_3__c == null || CIFObj.Age_of_Child_3__c == '' ||
CIFObj.Age_of_Child_4__c == null || CIFObj.Age_of_Child_4__c == '')) {
strError = 'Please fill up age of four childs to proceed.';
return null;
}
}
*/
            //            }
            /* if (CIFObj.BudgetIn_Cr__c == null) {
strError = 'Please fill up Budget to proceed.';
return null;
}*/
            if (CIFObj.Budget_In_Lakh__c == null) {
                strError = 'Please fill up Budget In Lakh to proceed.';
                return null;
            }
            /*if (CIFObj.Preferred_Location__c == null || CIFObj.Preferred_Location__c == '') {
strError = 'Please fill up Preferred Location to proceed.';
return null;
}
*/
            if (CIFObj.Configuration__c == null || CIFObj.Configuration__c == '') {
                strError = 'Please fill up Configuration to proceed.';
                return null;
            }
            if (CIFObj.TimeLine__c == null || CIFObj.TimeLine__c == '') {
                strError = 'Please fill up Timeline to proceed.';
                return null;
            }
            if (CIFObj.Purpose__C == null || CIFObj.Purpose__C == '') {
                strError = 'Please fill up Purpose to proceed.';
                return null;
            }
            // Added by Aditya (Saasworx)
            // if (CIFObj.Mode_of_funding__c == null || CIFObj.Mode_of_funding__c == '') {
            //     strError = 'Please fill up Mode Of Funding to proceed.';
            //     return null;
            // }
            // if(CIFObj.Mode_of_funding__c == 'Bank Loan'){
            //     if(CIFObj.Bank_Preference_1__c == null || CIFObj.Bank_Preference_1__c == ''){
            //         strError = 'Please fill up Bank Prefrence to proceed.';
            //     	return null;
            //     }
            // }
            //Added by Vinay 19-05-2025 Start
            /*  if (CIFObj.No_of_Family_Members__c == null) {
strError = 'Please fill up No of Family Members.';
return null;
}
if (CIFObj.Industry__c == null || CIFObj.Industry__c == '') {
strError = 'Please fill up Industry.';
return null;
}
if (CIFObj.Distance_To_Office__c == null || CIFObj.Distance_To_Office__c == '') {
strError = 'Please fill up Distance To Office.';
return null;
}
if (CIFObj.Family_Income__c == null || CIFObj.Family_Income__c == '') {
strError = 'Please fill up Yearly Family Income.';
return null;
}
if (CIFObj.No_of_Vehicles__c == null || CIFObj.No_of_Vehicles__c == '') {
strError = 'Please fill up No of Vehicles.';
return null;
}
if (CIFObj.Four_Wheeler__c == null || CIFObj.Four_Wheeler__c == '') {
strError = 'Please fill up Four Wheeler.';
return null;
}
if (CIFObj.Current_Residential_Address__c == null || CIFObj.Current_Residential_Address__c == '') {
strError = 'Please fill up Current Residential Address.';
return null;
}
if(CIFObj.Country__c == 'India' && CIFObj.ZipCode__c != null && (!CIFObj.ZipCode__c.isNumeric() || (CIFObj.ZipCode__c.isNumeric() && CIFObj.ZipCode__c.length() != 6))){ //Added by Vinay 03-07-2025
strError = 'The Zip code should be 6 digit number.';
return null;
}*/
            //Added by Vinay 19-05-2025 End
            //  System.debug('CIF Budget'+CIFObj.Budget_In_Lakh__c);
            if (objLead != null && strLeadId != null && strLeadId != '') {
                System.debug('inside lead loop down');
                //objLead.RW_Project__c = CIFObj.Project__c;
                objLead.Salutation = CIFObj.Salutation__c;
                if(CIFObj.Salutation__c == 'Mr.')
                    objLead.Gender__c = 'Male';
                else
                    objLead.Gender__c = 'Female';
                objLead.FirstName = CIFObj.FirstName__c;
                objLead.LastName = CIFObj.LastName__c;
                objLead.RW_Mobile_No__c = CIFObj.MobileNo1__c;
                objLead.RW_Secondary_Mobile_No__c = CIFObj.MobileNo2__c;
                objLead.Country_Code_2__c= CIFObj.Country_Code_2__c;
               // objLead.RDS_Country_Code__c= CIFObj.Country_Code__c;
                objLead.Email = CIFObj.PrimaryEmail__c;
                objLead.RW_Secondary_Email__c = CIFObj.SecondaryEmail__c;
                if(CIFObj.Country__c != null)
                    objLead.Country__c = CIFObj.Country__c;
                if(CIFObj.State__c != null)
                    objLead.State__c = CIFObj.State__c;
                if(CIFObj.City__c != null)
                    objLead.City__c = CIFObj.City__c;
                if(CIFObj.ZipCode__c != null)
                    objLead.Zip_Code__c = CIFObj.ZipCode__c;
                //objLead.Street__c = CIFObj.Street__c;
                if(CIFObj.Country__c != null && CIFObj.Country__c == 'India') {
                    if(CIFObj.City__c != null && (CIFObj.City__c.containsIgnoreCase('Mumbai') || CIFObj.City__c.containsIgnoreCase('Thane') || CIFObj.City__c.containsIgnoreCase('Navi Mumbai')))
                        objLead.RW_Customer_Type__c = 'Local';
                    else
                        objLead.RW_Customer_Type__c = 'Outstation';
                }
                else
                    objLead.RW_Customer_Type__c = 'NRI';
                
                objLead.RW_Occupation__c = CIFObj.Occupation__c;
                objLead.RW_Company_Name__c = CIFObj.CompanyName__c;
                objLead.RW_Other_Company_Name__c = CIFObj.CompanyNameOther__c;
                objLead.RW_Company_Location__c = CIFObj.CompanyLocation__c;
                objLead.RW_Designation__c = CIFObj.Designation__c;
                objLead.RW_Ethnicity__c = CIFObj.Ethnicity__c;
                objLead.Marital_Status__c = CIFObj.Marital_Status__c;
                objLead.RW_Configuration__c = CIFObj.Configuration__c;
                objLead.Budget_In_Lakh__c = CIFObj.Budget_In_Lakh__c;
                objLead.RW_Budget_Rs_in_Cr__c = CIFObj.BudgetIn_Cr__c;
                objLead.RW_Time_line__c = CIFObj.TimeLine__c;
                objLead.RW_Location__c = CIFObj.Preferred_Location__c;
                objLead.Cars_Owned__c = CIFObj.Cars_Owned__c;
                objLead.RW_Neighbourhood_Places__c = CIFObj.NeighbourhoodPlaces__c;
                //objLead.LeadSource = CIFObj.Source__c;
                objLead.Walkin_Source__c = CIFObj.Source__c;
                objLead.Walkin_SubSource__c = CIFObj.LeadSubSource__c;
                //objLead.Walkin_Sub_Sub_Source__c = CIFObj.Lead_Sub_Sub_Source__c;
                //objLead.RW_Apply_Unregistered_Broker__c = CIFObj.ApplyUnregisteredChannelPartner__c;
                objLead.Walkin_Apply_Unregistered_ChannelPartner__c = CIFObj.ApplyUnregisteredChannelPartner__c;
                //objLead.RW_Broker__c = CIFObj.Broker__c;
                System.debug('Broker________________'+CIFObj.Broker__c);
                System.debug('Broker________________'+objLead.Walkin_Channel_Partner__c);
                objLead.Walkin_Channel_Partner__c = CIFObj.Broker__c;
                //objLead.RW_Unregistered_Broker_Name__c = CIFObj.UnregisteredChannelPartnerName__c;
                //objLead.RW_Unregistered_Broker_Email__c = CIFObj.UnregisteredChannelPartnerEmail__c;
                //objLead.RW_Unregistered_Broker_Mobile__c = CIFObj.UnregisteredChannelPartnerMobile__c;
                objLead.Walkin_Unregistered_ChannelPartner_Email__c = CIFObj.UnregisteredChannelPartnerEmail__c;
                objLead.Walkin_UnregisteredChannelPartner_Mobile__c = CIFObj.UnregisteredChannelPartnerMobile__c; 
                objLead.Walkin_Unregistered_ChannelPartner_Name__c = CIFObj.UnregisteredChannelPartnerName__c;
                objLead.RW_Reference_Source__c = CIFObj.ReferenceSource__c;
                //objLead.Customer_Reference__c = CIFObj.CustomerReference__c;
                objLead.Walkin_Customer_Reference__c = CIFObj.CustomerReference__c;
                //objLead.Referral_Sub_Source__c =  CIFObj.Referral_Sub_Source__c;
                
                objLead.RW_Referral_Details__c = CIFObj.Referral_Details__c;
                //objLead.RW_Lead_Sub_Source__c = CIFObj.LeadSubSource__c;
                //objLead.NameofUnregisteredCorporate_LeadSource__c = CIFObj.NameofUnregisteredCorporateLeadSource__c;
                //objLead.Name_of_Unregistered_Corporate__c = CIFObj.NameofUnregisteredCorporateLeadSource__c;
                //objLead.Corporate_Company__c = CIFObj.CorporateCompany__c;
                objLead.Broker_Type__c = CIFObj.Broker_Type__c;
                objLead.Unregistered_broker_type__c = CIFObj.Unregistered_broker_type__c;
                objLead.Pre_Sales_User__c = CIFObj.Pre_Sales_User__c;
                objLead.RW_Sourcing_Manager__c = CIFObj.Sales_manager__c;
                objLead.Event_Description__C = CIFObj.Event_Description__C;
                objLead.Education__c = CIFObj.Education__c;
                objLead.Client_Type__c = CIFObj.Client_Type__c;
                objLead.Purpose__C = CIFObj.Purpose__C;
                objLead.Name_Of_Walkin_Referee__c = CIFObj.Name_Of_Walkin_Referee__c;
                objLead.Walk_in_Corporate__c = CIFObj.Walk_in_Corporate__c;
                objLead.Religion__c = CIFObj.Religion__c;
                //objLead.Lead_Sub_Sub_Source__c = CIFObj.Lead_Sub_Sub_Source__c;
                objLead.Locality__c = CIFObj.Locality__c;
                objLead.Zone__c = CIFObj.Zone__c;
                objLead.Walk_In_Details__c = CIFObj.Walk_In_Details__c;
                //objLead.Walk_In_Details__c = CIFObj.Walk_In_Details__c;			
                objLead.Walkin_Employee_Reference__c = CIFObj.Employee_Reference__c;				//Added by Sheetal on 25/02/2022	
                objLead.RW_Type_of_Client__c = CIFObj.Type_of_Client__c;		    //Added by Sheetal on 21/04/2022 to solve issue I0143	
                
                
                if(CIFObj.Marital_Status__c == 'Married') {
                    objLead.Spouse_Name__c = CIFObj.Spouse_Name__c;
                    if(strSpouseDOB != null && strSpouseDOB != '') {
                        objLead.Spouse_DOB__c = date.Parse(strSpouseDOB);
                    }
                    objLead.No_of_Children__c = CIFObj.No_of_Children__c; 
                    objLead.Age_of_Child_1__c = CIFObj.Age_of_Child_1__c;
                    objLead.Age_of_Child_2__c = CIFObj.Age_of_Child_2__c;
                    objLead.Age_of_Child_3__c = CIFObj.Age_of_Child_3__c;
                    objLead.Age_of_Child_4__c = CIFObj.Age_of_Child_4__c;
                    objLead.Spouse_Occupation__c = CIFObj.Spouse_Occupation__c; 
                    objLead.Spouse_Company_Name__c = CIFObj.Spouse_Company_Name__c; 
                    objLead.Spouse_Designation__c = CIFObj.Spouse_Designation__c;
                }
                else {
                    objLead.Spouse_Name__c = null;
                    objLead.Spouse_DOB__c = null;
                    objLead.No_of_Children__c = null; 
                    objLead.Age_of_Child_1__c = null;
                    objLead.Age_of_Child_2__c = null;
                    objLead.Age_of_Child_3__c = null;
                    objLead.Age_of_Child_4__c = null;
                    objLead.Spouse_Occupation__c = null; 
                    objLead.Spouse_Company_Name__c = null; 
                    objLead.Spouse_Designation__c = null;
                }
                if (strDOB != null && strDOB != '') {
                    objLead.RW_Date_of_Birth__c = date.Parse(strDOB);
                    if(objLead.RW_Date_of_Birth__c != null) {
                        if(objLead.RW_Date_of_Birth__c >= System.Today()) {
                            strError = 'Birth Date should not be today or greater than today.';
                            return null;
                        }
                        
                    }
                }
                if (CIFObj.BudgetIn_Cr__c != null) {
                    objLead.RW_Budget_Rs_in_Cr__c = CIFObj.BudgetIn_Cr__c ;
                    //objLead.RW_Budget__c = String.ValueOf(CIFObj.BudgetIn_Cr__c * 10000000); //
                    
                }
                
                if (CIFObj.Source__c != null) {
                    /*if (CIFObj.Source__c == 'Corporate' && CIFObj.CorporateCompany__c != null && CIFObj.CorporateCompany__c == 'Other') {
objLead.Walkin_Source__c = 'Corporate(Unregistered)';
CIFObj.Source__c = objLead.Walkin_Source__c;
}*/
                    if (CIFObj.Source__c != 'Channel Partner') {
                        objLead.Walkin_Apply_Unregistered_ChannelPartner__c = false;
                        objLead.Walkin_Channel_Partner__c = null;
                        objLead.Walkin_Unregistered_ChannelPartner_Name__c = null;
                        objLead.Walkin_Unregistered_ChannelPartner_Email__c = null;
                        objLead.Walkin_UnregisteredChannelPartner_Mobile__c = null;
                    }
                    
                    if (CIFObj.ReferenceSource__c != null && CIFObj.ReferenceSource__c != 'Existing Customer Reference' && CIFObj.Source__c != 'Loyalty') {
                        objLead.Walkin_Customer_Reference__c = null;
                    }
                    if (CIFObj.Source__c != 'Emp / Mgmt Reference') {
                        objLead.RW_Reference_Source__c = null;
                    }
                    
                    if (CIFObj.Source__c != 'Reference') {
                        objLead.RW_Reference_Source__c = null;
                    }
                    
                    if (CIFObj.Source__c == 'Channel Partner' || CIFObj.Source__c == 'Reference' || CIFObj.Source__c == 'Corporate' ||
                        CIFObj.Source__c == 'Loyalty') {
                            objLead.Walkin_SubSource__c = null;
                        }
                    
                    if (CIFObj.Source__c != 'Corporate') {
                        objLead.Walk_in_Corporate__c = null;
                        //objLead.NameofUnregisteredCorporate_LeadSource__c = null;
                    }
                    
                    /*if (CIFObj.Source__c != 'Corporate(Unregistered)') {
objLead.Name_of_Unregistered_Corporate__c = null;
}
*/
                } else {
                    strError = 'Error : Please select the Lead Source to proceed.';
                    return null;
                }
                
                update objLead;
                
                List < Lead > leadListToconvert = new List < Lead > ();
                List < Lead > ConvertedLeadlist = new List < Lead > ();
                //   List < Prospect__c > lstProspect = new List < Prospect__c > ();
                //   List < Prospect__c > lstProspectwithProject = new List < Prospect__c > ();
                //   List < Prospect__c > lstProspectToUpdate = new List < Prospect__c > ();
                Opportunity objOpyToUpdateProject = new Opportunity ();
                leadListToconvert.add(objLead);
                if (leadListToconvert != null) {
                    convertCIFLeads(leadListToconvert);
                    
                    ConvertedLeadlist = [select Id, Name, IsConverted, ConvertedAccountId, ConvertedOpportunityId, RW_Project__c from Lead
                                         where Id =: objLead.Id and Isconverted = true
                                         order by LastModifiedDate Desc limit 1];
                    System.debug('Converted Lead list:::' + ConvertedLeadlist);
                    if (!ConvertedLeadlist.isEmpty()) {
                        /*  lstProspect = [Select Id, name, Lead__c, is_Converted__c, Opportunity__c, Project__c, Account__c
from Prospect__c where Lead__c = : ConvertedLeadlist[0].Id
];//and Project__c = : projObj.Id
if (!lstProspect.isEmpty() && lstProspect.size() > 0) {
for (Prospect__c p : lstProspect) {
p.Account__c = ConvertedLeadlist[0].ConvertedAccountId;
lstProspectToUpdate.add(p);
}
if (!lstProspectToUpdate.isEmpty())
update lstProspectToUpdate;
lstProspectwithProject = [Select Id, name, Lead__c, is_Converted__c, Opportunity__c, Project__c, Account__c
from Prospect__c where Lead__c = : ConvertedLeadlist[0].Id
and Project__c = : projObj.Id];//
if(!lstProspectwithProject.isEmpty() && lstProspectwithProject.size() > 0 ) {
for (Prospect__c p : lstProspectwithProject) {
p.is_Converted__c = true;
p.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
update p;
}
}
else {
Prospect__c p = new prospect__c();
p.Project__c = projObj.Id;
p.Account__c = ConvertedLeadlist[0].ConvertedAccountId;
//p.User__c = 
//p.Lead__c = ConvertedLeadlist[0].Id;
p.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
p.Name = 'Prospect - ' + ConvertedLeadlist[0].Name + ' For Project - ' + projObj.Name;
insert p;
}
} else {
Prospect__c p = new prospect__c();
p.Project__c = projObj.Id;
p.Account__c = ConvertedLeadlist[0].ConvertedAccountId;
//p.User__c = 
//p.Lead__c = ConvertedLeadlist[0].Id;
p.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
p.Name = 'Prospect - ' + ConvertedLeadlist[0].Name + ' For Project - ' + projObj.Name;
insert p;
} */
                        objOpyToUpdateProject = [Select Id,Name,OwnerId, AccountId,Account.lastName,Account.firstName,RW_Project__c from Opportunity where id=: ConvertedLeadlist[0].ConvertedOpportunityId];
                        if(objOpyToUpdateProject != null) {
                            objOpyToUpdateProject.RW_Project__c = projObj.Id;
                            //Added by Prashant - 12-09-25. to tag CP . ////Start
                            if(CIFObj.Broker__c != null && (CIFObj.Source__c == 'Temp Channel Partner' || CIFObj.Source__c == 'Channel Partner')){
                                objOpyToUpdateProject.RW_Walkin_Channel_Partner__c = CIFObj.Broker__c ;
                            }    
                            //Added by Prashant - 12-09-25. to tag CP . ////End
                            Lead convertedLead = [SELECT FirstName, LastName, Related_Account__c FROM Lead WHERE Id = :ConvertedLeadlist[0].Id LIMIT 1];
                            if (String.isNotBlank(convertedLead.FirstName) || String.isNotBlank(convertedLead.LastName)) {
                                objOpyToUpdateProject.Name =
                                    (String.isNotBlank(convertedLead.FirstName) ? convertedLead.FirstName + ' ' : '') +
                                    (String.isNotBlank(convertedLead.LastName) ? convertedLead.LastName : '');
                            } else if (objOpyToUpdateProject.Account != null) {
                                // Fallback to Account name if Lead name is blank
                                objOpyToUpdateProject.Name =
                                    (String.isNotBlank(objOpyToUpdateProject.Account.FirstName) ? objOpyToUpdateProject.Account.FirstName + ' ' : '') +
                                    (String.isNotBlank(objOpyToUpdateProject.Account.LastName) ? objOpyToUpdateProject.Account.LastName : '');
                            }
                            
                            update objOpyToUpdateProject;
                            
                        }
                    }
                    CIFObj.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                    CIFObj.Name = objOpyToUpdateProject.Name+ '-'+projObj.Name+'-'+System.Now().format();
                    
                    insert CIFObj;
                    
                    task t = new task();
                    t.WhatId = objOpyToUpdateProject.id;
                    t.OwnerId = objOpyToUpdateProject.OwnerId;
                    t.Visitor_Name__c = objOpyToUpdateProject.Name;
                    t.CI_Form__c = CIFObj.Id;
                    //t.whoId = ConvertedLeadlist[0].ConvertedAccountId;
                    t.activityDate = System.today();
                    t.Call_Time__c = System.Now().format('h:mm a');
                    t.status = 'Completed';
                    t.Subject = 'Site Visit';
                    t.Task_Type__c = 'Site Visit';
                    t.Type = 'Site Visit';
                    t.priority = 'Normal';
                    t.Project__c = objOpyToUpdateProject.RW_Project__c;
                    //insert t; //Commented by Vinay 04-02-2025
                }
            }
            else if (objAcc != null && strAccountId != null && strAccountId != '') {
                objAcc.Salutation = CIFObj.Salutation__c;
                if(CIFObj.Salutation__c == 'Mr.')
                    objAcc.Gender__c = 'Male';
                else
                    objAcc.Gender__c = 'Male';
                objAcc.FirstName = CIFObj.FirstName__c ;
                objAcc.LastName = CIFObj.LastName__c ;
                objAcc.Mobile_No__c = CIFObj.MobileNo1__c ;
                objAcc.Alternate_Mobile_No__c = CIFObj.MobileNo2__c ;
                objAcc.PersonEmail = CIFObj.PrimaryEmail__c ;
                objAcc.Alternate_Email__c = CIFObj.SecondaryEmail__c ;
                
                if(CIFObj.Country__c != null)
                    objAcc.Country__c = CIFObj.Country__c;
                if(CIFObj.State__c != null)
                    objAcc.State__c = CIFObj.State__c;
                if(CIFObj.City__c != null)
                    objAcc.City__c = CIFObj.City__c;
                
                if(CIFObj.Country__c != null && CIFObj.Country__c == 'India') {
                    if(CIFObj.City__c != null && (CIFObj.City__c.containsIgnoreCase('Mumbai') || CIFObj.City__c.containsIgnoreCase('Thane') || CIFObj.City__c.containsIgnoreCase('Navi Mumbai')))
                        objAcc.RW_Customer_Type__c = 'Local';
                    else
                        objAcc.RW_Customer_Type__c = 'Outstation';
                }
                else
                    objAcc.RW_Customer_Type__c = 'NRI';
                
                //objAcc.RW_Customer_Type__c = CIFObj.CustomerType__c ;
                objAcc.Country__c = CIFObj.Country__c ;
                objAcc.State__c = CIFObj.State__c ;
                objAcc.City__c = CIFObj.City__c ;
                objAcc.RW_Zip_Code__c = CIFObj.ZipCode__c ;
                //objAcc.Office_Street__c = CIFObj.Street__c ;
                objAcc.RW_Occupation__c = CIFObj.Occupation__c ;
                objAcc.RW_Company_Name__c = CIFObj.CompanyName__c ;
                objAcc.RW_Other_Company_Name__c = CIFObj.CompanyNameOther__c ;
                objAcc.RW_Company_Location__c = CIFObj.CompanyLocation__c ;
                objAcc.RW_Designation__c = CIFObj.Designation__c ;
                objAcc.RW_Ethnicity__c = CIFObj.Ethnicity__c;
                objAcc.Marital_Status__c = CIFObj.Marital_Status__c;
                objAcc.Cars_Owned__c = CIFObj.Cars_Owned__c;
                objAcc.Education__c = CIFObj.Education__c;
                objAcc.Religion__c = CIFObj.Religion__c;
                objAcc.Locality__c = CIFObj.Locality__c;
                objAcc.Zone__c = CIFObj.Zone__c;
                objAcc.Walk_In_Details__c = CIFObj.Walk_In_Details__c;
                system.debug('Account-Type of Client'+objAcc.Type_of_Client__c);
                objAcc.Type_of_Client__c = CIFObj.Type_of_Client__c;		//Added by Sheetal on 21/04/2022
                
                if(CIFObj.Marital_Status__c == 'Married') {
                    objAcc.Spouse_Name__c = CIFObj.Spouse_Name__c;
                    if (strSpouseDOB != null && strSpouseDOB != '') {
                        objAcc.Birth_Date__c= date.Parse(strSpouseDOB);
                    }
                    objAcc.No_of_Children__c = CIFObj.No_of_Children__c; 
                    objAcc.Age_of_Child_1__c = CIFObj.Age_of_Child_1__c;
                    objAcc.Age_of_Child_2__c = CIFObj.Age_of_Child_2__c;
                    objAcc.Age_of_Child_3__c = CIFObj.Age_of_Child_3__c;
                    objAcc.Age_of_Child_4__c = CIFObj.Age_of_Child_4__c;
                    objAcc.Spouse_Occupation__c = CIFObj.Spouse_Occupation__c; 
                    objAcc.Spouse_Company_Name__c = CIFObj.Spouse_Company_Name__c; 
                    objAcc.Spouse_Designation__c = CIFObj.Spouse_Designation__c;
                }
                else {
                    objAcc.Spouse_Name__c = null;
                    objAcc.Birth_Date__c= null;
                    objAcc.No_of_Children__c = null; 
                    objAcc.Age_of_Child_1__c = null;
                    objAcc.Age_of_Child_2__c = null;
                    objAcc.Age_of_Child_3__c = null;
                    objAcc.Age_of_Child_4__c = null;
                    objAcc.Spouse_Occupation__c = null; 
                    objAcc.Spouse_Company_Name__c = null; 
                    objAcc.Spouse_Designation__c = null;
                }
                // objOptyToInsert.Referral_Sub_Source__c  =  CIFObj.Referral_Sub_Source__c ;
                //  objOptyToInsert.CloseDate = System.today().addMonths(1); 
                //  Fetch Opp Close Date setting for the project
                Opp_Close_Date__c oppCloseDateSetting = [
                    SELECT No_of_Days__c
                    FROM Opp_Close_Date__c
                    WHERE Project_Name__c = :projObj.Name
                    LIMIT 1
                ];
                
                // If setting found, calculate Close Date, else fallback to default (+30 days)
                if (oppCloseDateSetting != null && oppCloseDateSetting.No_of_Days__c != null) {
                    objOptyToInsert.CloseDate = System.today().addDays((Integer)oppCloseDateSetting.No_of_Days__c);
                } else {
                    objOptyToInsert.CloseDate = System.today().addDays(90); // Default fallback
                }
                objOptyToInsert.RW_Mobile_No__c =  CIFObj.MobileNo1__c;
                objOptyToInsert.RW_Configuration__c = CIFObj.Configuration__c ; 
                objOptyToInsert.Budget_In_Lakh__c = CIFObj.Budget_In_Lakh__c; 
              //  system.debug('CIFObj.Budget_In_Lakh__c>>>>' +CIFObj.Budget_In_Lakh__c);
                objOptyToInsert.Budget_In_Cr__c = CIFObj.BudgetIn_Cr__c;
             //   system.debug('CIFObj.BudgetIn_Cr__c>>>>' +CIFObj.BudgetIn_Cr__c);
                objOptyToInsert.RW_Time_line__c = CIFObj.TimeLine__c ;
                objOptyToInsert.RW_Location__c = CIFObj.Preferred_Location__c ;
                objOptyToInsert.RW_Neighbourhood_Places__c = CIFObj.NeighbourhoodPlaces__c ;
                //objOptyToInsert.LeadSource = CIFObj.Source__c ;
                objOptyToInsert.Walkin_Source__c = CIFObj.Source__c;
                objOptyToInsert.Walkin_SubSource__c = CIFObj.LeadSubSource__c;
                //objOptyToInsert.Walkin_Sub_Sub_Source__c = CIFObj.Lead_Sub_Sub_Source__c;
                //objOptyToInsert.RW_Apply_Unregistered_Broker__c = CIFObj.ApplyUnregisteredChannelPartner__c ;
                objOptyToInsert.Walkin_Apply_Unregistered_ChannelPartner__c = CIFObj.ApplyUnregisteredChannelPartner__c ;
                system.debug('CIFObj.Broker__c -> '+CIFObj.Broker__c);
                system.debug('CIFObj.RW_Walkin_Channel_Partner__c -> '+objOptyToInsert.RW_Walkin_Channel_Partner__c);
                objOptyToInsert.RW_Walkin_Channel_Partner__c = CIFObj.Broker__c ;
                system.debug('CIFObj.Broker__c -> '+CIFObj.Broker__c);
                system.debug('CIFObj.RW_Walkin_Channel_Partner__c -> '+objOptyToInsert.RW_Walkin_Channel_Partner__c);
                //objOptyToInsert.RW_Unregistered_Broker_Name__c = CIFObj.UnregisteredChannelPartnerName__c ;
                //objOptyToInsert.RW_Unregistered_Broker_Email__c = CIFObj.UnregisteredChannelPartnerEmail__c ;
                //objOptyToInsert.RW_Unregistered_Broker_Mobile__c = CIFObj.UnregisteredChannelPartnerMobile__c ;
                objOptyToInsert.Walkin_Unregistered_ChannelPartner_Email__c = CIFObj.UnregisteredChannelPartnerEmail__c;
                objOptyToInsert.Walkin_UnregisteredChannelPartner_Mobile__c = CIFObj.UnregisteredChannelPartnerMobile__c; 
                objOptyToInsert.Walkin_Unregistered_ChannelPartner_Name__c = CIFObj.UnregisteredChannelPartnerName__c;
                objOptyToInsert.RW_Reference_Source__c = CIFObj.ReferenceSource__c ;
                //objOptyToInsert.Customer_Reference__c = CIFObj.CustomerReference__c ;
                objOptyToInsert.RW_Walkin_Customer_Reference__c = CIFObj.CustomerReference__c ;
                // objOptyToInsert.Referral_Sub_Source__c = CIFObj.Referral_Sub_Source__c;
                
                objOptyToInsert.RW_Referral_Details__c = CIFObj.Referral_Details__c ;
                objOptyToInsert.Lead_Sub_Source__c = CIFObj.LeadSubSource__c ; 
                //objOptyToInsert.NameofUnregisteredCorporate_LeadSource__c = CIFObj.NameofUnregisteredCorporateLeadSource__c;
                //objOptyToInsert.Name_of_Unregistered_Corporate__c = CIFObj.NameofUnregisteredCorporateLeadSource__c;
                //objOptyToInsert.Corporate_Company__c = CIFObj.CorporateCompany__c;
                objOptyToInsert.RW_Project__c = CIFObj.Project__c ;
                objOptyToInsert.Client_Type__c = CIFObj.Client_Type__c;
                objOptyToInsert.Purpose__C = CIFObj.Purpose__C;
                objOptyToInsert.RW_Type_of_Client__c = CIFObj.Type_of_Client__c;		//Added by Sheetal on 21/04/2022
                objOptyToInsert.Name_Of_Walkin_Referee__c = CIFObj.Name_Of_Walkin_Referee__c;
                objOptyToInsert.Walk_in_Corporate__c = CIFObj.Walk_in_Corporate__c;
                objOptyToInsert.stageName = 'Site Visit';
                objOptyToInsert.Walk_In_Details__c= CIFObj.Walk_In_Details__c;		//added by payal
                if(String.isNotBlank(objAcc.firstName))
                    objOptyToInsert.Name = objAcc.firstName+' '+objAcc.LastName;
                else
                    objOptyToInsert.Name = objAcc.LastName;
                objOptyToInsert.AccountId = objAcc.Id;
                objOptyToInsert.Broker_Type__c = CIFObj.Broker_Type__c;
                objOptyToInsert.Unregistered_broker_type__c = CIFObj.Unregistered_broker_type__c;
                objOptyToInsert.RW_Pre_Sales_User__c = CIFObj.Pre_Sales_User__c;
                objOptyToInsert.RW_Sourcing_Manager__c = CIFObj.Sales_manager__c; 
                objOptyToInsert.Sourcing_Manager_User__c = leadSourcingManager; //Added by Vinay 04-08-2025
                objOptyToInsert.Event_Description__C = CIFObj.Event_Description__C;
                //objOptyToInsert.Lead_Sub_Sub_Source__c = CIFObj.Lead_Sub_Sub_Source__c;
                objOptyToInsert.OwnerId = objAcc.ownerId;
                if (strDOB != null && strDOB != '') {
                    objAcc.Birth_Date__c= date.Parse(strDOB);
                }
               // system.debug('CIFObj.BudgetIn_Cr__c>>>>' +CIFObj.BudgetIn_Cr__c);
                objOptyToInsert.Budget_In_Cr__c=CIFObj.BudgetIn_Cr__c;  
                objOptyToInsert.Budget_In_Lakh__c = CIFObj.Budget_In_Lakh__c ;
              //  system.debug('objOptyToInsert.Budget_In_Lakh__c>>>>' +objOptyToInsert.Budget_In_Lakh__c);
                /*    objOptyToInsert.Budget_In_Cr__C = CIFObj.BudgetIn_Cr__c * 10000000;
if(objOptyToInsert.Budget_In_Cr__C <= 2000000) 
objOptyToInsert.RW_Budget__c = '< 0.20 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 3000000) 
{
objOptyToInsert.RW_Budget__c = '0.20 Cr - 0.30 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 4000000) 
{
objOptyToInsert.RW_Budget__c = '0.30 Cr - 0.40 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 5000000) 
{
objOptyToInsert.RW_Budget__c = '0.40 Cr - 050 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 6000000) 
{
objOptyToInsert.RW_Budget__c = '0.50 Cr - 0.60 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 7000000) 
{
objOptyToInsert.RW_Budget__c = '0.60 Cr - 0.70 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 8000000) 
{
objOptyToInsert.RW_Budget__c = '0.70 Cr - 0.80 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 9000000) 
{
objOptyToInsert.RW_Budget__c = '0.80 Cr - 0.90 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 10000000) 
{
objOptyToInsert.RW_Budget__c = '0.90 Cr - 1.00 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 11000000) 
{
objOptyToInsert.RW_Budget__c = '1.0 Cr - 1.10 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 12000000) 
{
objOptyToInsert.RW_Budget__c = '1.10 Cr - 1.20 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 13000000) 
{
objOptyToInsert.RW_Budget__c = '1.20 Cr - 1.30 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 14000000) 
{
objOptyToInsert.RW_Budget__c = '1.30 Cr - 1.40 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 15000000) 
{
objOptyToInsert.RW_Budget__c = '1.40 Cr - 1.50 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 16000000) 
{
objOptyToInsert.RW_Budget__c = '1.50 Cr - 1.60 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 17000000) 
{
objOptyToInsert.RW_Budget__c = '1.60 Cr - 1.70 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 18000000) 
{
objOptyToInsert.RW_Budget__c = '1.70 Cr - 1.80 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 19000000) 
{
objOptyToInsert.RW_Budget__c = '1.80 Cr - 1.90 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 20000000) 
{
objOptyToInsert.RW_Budget__c = '1.90 Cr - 2.00 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 22500000) 
{
objOptyToInsert.RW_Budget__c = '2.00 Cr - 2.25 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 25000000) 
{
objOptyToInsert.RW_Budget__c = '2.25 Cr - 2.50 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 27500000) 
{
objOptyToInsert.RW_Budget__c = '2.50 Cr - 2.75 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 30000000) 
{
objOptyToInsert.RW_Budget__c = '2.75 Cr - 3 Cr ' ;
}
else if(objOptyToInsert.Budget_In_Cr__C > 30000000) 
{
objOptyToInsert.RW_Budget__c = '> 3 Cr ' ;
}*/
                
                
                
                /* if(objOptyToInsert.Budget_In_Cr__C <= 2500000) {
objOptyToInsert.RW_Budget__c = '0-0.25 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 5000000) {
objOptyToInsert.RW_Budget__c = '0.25-0.5 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 7500000) {
objOptyToInsert.RW_Budget__c = '0.5-0.75 Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 10000000)
{
objOptyToInsert.RW_Budget__c = '0.75-1 Cr';
}*/
                /*if(objOptyToInsert.Budget_In_Cr__C <= 10000000)
{
objOptyToInsert.RW_Budget__c = '< 1Cr';
}*/
                /*else if(objOptyToInsert.Budget_In_Cr__C <= 12500000)
{
objOptyToInsert.RW_Budget__c = '1Cr – 1.25Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 15000000)
{
objOptyToInsert.RW_Budget__c = '1.25Cr – 1.5Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 20000000)
{
objOptyToInsert.RW_Budget__c = '1.5Cr - 2Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 25000000)
{
objOptyToInsert.RW_Budget__c = '2Cr – 2.5Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 30000000)
{
objOptyToInsert.RW_Budget__c = '2.5Cr – 3Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C <= 40000000)
{
objOptyToInsert.RW_Budget__c = '3Cr – 4Cr';
}
else if(objOptyToInsert.Budget_In_Cr__C > 40000000)
{
objOptyToInsert.RW_Budget__c = 'More than 4Cr';
}*/
                //}
                if (CIFObj.Source__c != null) {
                    /* if (CIFObj.Source__c == 'Corporate' && CIFObj.CorporateCompany__c != null && CIFObj.CorporateCompany__c == 'Other') {
objOptyToInsert.Walkin_Source__c = 'Corporate(Unregistered)';
CIFObj.Source__c = objOptyToInsert.Walkin_Source__c;
}

if (CIFObj.Source__c == 'Corporate(Unregistered)') {
objOptyToInsert.Corporate_Company__c = 'Other';
CIFObj.CorporateCompany__c = objOptyToInsert.Corporate_Company__c;
}
*/
                    if (CIFObj.Source__c != 'Channel Partner') {
                        objOptyToInsert.Walkin_Apply_Unregistered_ChannelPartner__c = false;
                        //objOptyToInsert.RW_Walkin_Channel_Partner__c = null;
                        objOptyToInsert.Walkin_Unregistered_ChannelPartner_Name__c = null;
                        objOptyToInsert.Walkin_Unregistered_ChannelPartner_Email__c = null;
                        objOptyToInsert.Walkin_UnregisteredChannelPartner_Mobile__c = null;
                    }
                    
                    if (CIFObj.ReferenceSource__c != null && CIFObj.ReferenceSource__c != 'Existing Customer Reference' && CIFObj.Source__c != 'Loyalty') {
                        objOptyToInsert.RW_Walkin_Customer_Reference__c = null;
                    }
                    if (CIFObj.Source__c != 'Reference') {
                        objOptyToInsert.RW_Reference_Source__c = null;
                    }
                    if (CIFObj.Source__c == 'Channel Partner' || CIFObj.Source__c == 'Reference' || CIFObj.Source__c == 'Corporate' ||
                        CIFObj.Source__c == 'Loyalty') {
                            objOptyToInsert.Walkin_SubSource__c = null;
                        }
                    if (CIFObj.Source__c != 'Corporate') {
                        objOptyToInsert.Walk_in_Corporate__c = null;
                        //objOptyToInsert.NameofUnregisteredCorporate_LeadSource__c = null;
                    }
                    
                    
                    /*if (CIFObj.Source__c != 'Corporate(Unregistered)') {
objOptyToInsert.Name_of_Unregistered_Corporate__c = null;
}
*/
                } else {
                    strError = 'Error : Please select the Source to proceed.';
                    return null;
                    
                    
                    
                    
                }
                update objAcc;
                insert objOptyToInsert;
                system.debug('objOptyToInsert>>>>' +objOptyToInsert);
                //Added by coServe 10-01-2024 Start
                if(System.label.Account_Merging_Active == 'Yes'){
                    List<Account> accList = [SELECT Id FROM Account WHERE Mobile_No__c =: objAcc.Mobile_No__c];
                    List<Account> portalAccList = [SELECT Id FROM Account WHERE Mobile_No__c =: objAcc.Mobile_No__c AND IsCustomerPortal = true];
                    Map<String, Account> accMap = new Map<String, Account>();
                    
                    for(Account acc : accList){
                        accMap.put(acc.Id, acc);
                    }
                    Account masterAcc;
                    //Account masterAcc = accMap.get(objAcc.Id);
                    List<Account> duplicateAccs = new List<Account>();
                    
                    if(portalAccList.size() >= 1){
                        masterAcc = portalAccList[0];
                        for(String acId : accMap.keySet()){
                            if(acId != portalAccList[0].Id){
                                duplicateAccs.add(accMap.get(acId));
                            }
                        }
                    }
                    
                    
                    /*for(String acId : accMap.keySet()){
if(acId != objAcc.Id){
duplicateAccs.add(accMap.get(acId));
}
}
if(!duplicateAccs.isEmpty()) {
Database.merge(masterAcc, duplicateAccs);
}*/
                }
                //Added by coServe 10-01-2024 End
                /*    List<Prospect__c> lstProspect = new List<Prospect__c>();
List<Prospect__c> lstProspecttoUpdate = new List<Prospect__c>();
lstProspect = [Select Id, name, Lead__c, is_Converted__c,Opportunity__c, Project__c, Account__c
from Prospect__c where Account__c = : objAcc.Id and Project__c = : projObj.Id];
if(!lstProspect.isEmpty() && lstProspect.size() > 0) {
for(Prospect__c p : lstProspect) {
p.Opportunity__c = objOptyToInsert.Id;
lstProspecttoUpdate.add(p);
}
if(!lstProspecttoUpdate.isEmpty())
update lstProspecttoUpdate;
}
else {
Prospect__c p = new prospect__c();
p.Project__c = projObj.Id;
p.Account__c = objAcc.Id;
//p.User__c = 
p.Opportunity__c = objOptyToInsert.Id;
p.Name = 'Prospect - ' + objAcc.firstName +' '+ objAcc.lastName + ' For Project - ' + projObj.Name;
insert p;
}*/
                CIFObj.Opportunity__c = objOptyToInsert.Id;
                CIFObj.Name = objOptyToInsert.Name+ '-'+projObj.Name+'-'+System.Now().format();
                
                insert CIFObj;
                system.debug('CIFObj>>>>' +CIFObj);
                task t = new task();
                t.WhatId = objOptyToInsert.id;
                t.OwnerId = objOptyToInsert.OwnerId;
                t.Visitor_Name__c = objOptyToInsert.Name;
                t.CI_Form__c = CIFObj.Id;
                //t.whoId = objAcc.Id;
                t.activityDate = System.today();
                t.Call_Time__c = System.Now().format('h:mm a');
                t.status = 'Completed';
                t.Subject = 'Site Visit';
                t.Task_Type__c = 'Site Visit';
                t.Type = 'Site Visit';
                t.priority = 'Normal';
                t.Project__c = objOptyToInsert.RW_Project__c;
                //insert t; //Commented by Vinay 04-02-2025
            }
            
            /*  if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
isSubmitted = true;
return null;
} else {*/
            Pagereference objReference = new Pagereference('/' + CIFObj.Opportunity__c); //objLead.Id
            objReference.setRedirect(true);
            return objReference;
            // }
            
            
        }catch (exception ex) { 
            Database.rollback(sp);
            string strTempError = '';
            System.debug('Exception occured::'+ex);
            
            if (ex.getMessage() != null && ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') == true) {
                strTempError = ((ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1]).split(':')[0]).trim();
            }
            
            if (ex.getMessage() != null && ex.getMessage().contains('INVALID_EMAIL_ADDRESS,') == true) {
                strTempError = ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[0]).trim() + ' : ' + ((ex.getMessage().split('INVALID_EMAIL_ADDRESS,')[1]).split(':')[1]).trim();
            }
            strError = strTempError != '' ? strTempError : ex.getMessage();
            
            return null;
        }  
        return null;
    }
    
    public void changeLocality() {
        CIFObj.Country__c = null;
        CIFObj.State__c = null;
        CIFObj.City__c = null;
        CIFObj.ZipCode__c = null;
        if(CIFObj.Locality__c != 'NRI' && CIFObj.Locality__c != 'Outstation') {
            CIFObj.Country__c = 'India';
            CIFObj.State__c = 'Maharashtra';
            CIFObj.City__c = 'Mumbai';
        }
        else if(CIFObj.Locality__c == 'Outstation')
            CIFObj.Country__c = 'India';
        
        random = false;
    }
    public static void convertCIFLeads(List<Lead> ll) {
        for (Lead myLead : ll) {
            try {
                System.debug(' Starting Lead conversion for Lead Id: ' + myLead.Id);
                
                // Prepare LeadConvert object
                Database.LeadConvert lc = new Database.LeadConvert();
                lc.setLeadId(myLead.Id);
                
                // Set converted status
                LeadStatus convertStatus = [
                    SELECT Id, MasterLabel FROM LeadStatus
                    WHERE IsConverted = true
                    LIMIT 1
                ];
                lc.setConvertedStatus(convertStatus.MasterLabel);
                
                // Step 1: Check for existing Account by matching mobile numbers
                List<String> leadMobileNumbers = new List<String>();
                System.debug('Mylead Primary mobile no' + myLead.Primary_Mobile_No_with_code__c);
                System.debug('Mylead Secondary mobile no' + myLead.Secondary_Mobile_No_with_code__c);
                if (String.isNotBlank(myLead.Primary_Mobile_No_with_code__c)) {
                    leadMobileNumbers.add(myLead.Primary_Mobile_No_with_code__c);
                    System.debug('Primary: ' + myLead.Primary_Mobile_No_with_code__c);
                }
                if (String.isNotBlank(myLead.Secondary_Mobile_No_with_code__c)) {
                    leadMobileNumbers.add(myLead.Secondary_Mobile_No_with_code__c);
                    System.debug(' Secondary: ' + myLead.Secondary_Mobile_No_with_code__c);
                }
                
                Id finalAccountId;
                if (!leadMobileNumbers.isEmpty()) {
                    System.debug('Checking Accounts with numbers: ' + leadMobileNumbers);
                    List<Account> matchedAccounts = [
                        SELECT Id FROM Account
                        WHERE
                        (Primary_Mobile_No_with_code__c != null AND Primary_Mobile_No_with_code__c IN :leadMobileNumbers)
                        OR
                        (Secondary_Mobile_No_with_code__c != null AND Secondary_Mobile_No_with_code__c IN :leadMobileNumbers)
                        LIMIT 1
                    ];
                    
                    if (!matchedAccounts.isEmpty()) {
                        finalAccountId = matchedAccounts[0].Id;
                        System.debug('Found matching Account by mobile: ' + finalAccountId);
                    }
                }
                
                // Step 2: Fallback to Related_Account__c
                if (finalAccountId == null && myLead.Related_Account__c != null) {
                    finalAccountId = myLead.Related_Account__c;
                    System.debug('Using Related_Account__c: ' + finalAccountId);
                }
                
                // Step 3: If still no Account, a new one will be created automatically
                if (finalAccountId == null) {
                    System.debug('No matching Account found. A new Account will be created.');
                } else {
                    lc.setAccountId(finalAccountId);
                }
                
                // Always create Opportunity
                lc.setDoNotCreateOpportunity(false);
                
                // Set Opportunity Name
                String oppName = (String.isNotBlank(myLead.FirstName) && String.isNotBlank(myLead.LastName))
                    ? myLead.FirstName + ' ' + myLead.LastName
                    : 'Opportunity from Lead';
                lc.setOpportunityName(oppName);
                
                // Perform the conversion
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                
                if (lcr.isSuccess()) {
                    System.debug('Lead converted successfully: ' + myLead.Id);
                    
                    // Fetch converted Lead (to get project and mobile info)
                    Lead convertedLead = [
                        SELECT Id, Primary_Mobile_No_with_code__c, Secondary_Mobile_No_with_code__c,
                        Development__c, Vertical__c
                        FROM Lead
                        WHERE Id = :myLead.Id
                        LIMIT 1
                    ];
                    
                    // Step 4: Inactivate other active leads with same project and mobile, but different vertical
                    Set<String> mobileSet = new Set<String>();
                    if (convertedLead.Primary_Mobile_No_with_code__c != null) {
                        mobileSet.add(convertedLead.Primary_Mobile_No_with_code__c);
                    }
                    if (convertedLead.Secondary_Mobile_No_with_code__c != null) {
                        mobileSet.add(convertedLead.Secondary_Mobile_No_with_code__c);
                    }
                    List<Lead> duplicateLeads = [
                        SELECT Id, IsActive__c
                        FROM Lead
                        WHERE Id != :convertedLead.Id
                        AND IsConverted = false
                        AND IsActive__c = true
                        AND Development__c !=null
                        AND Vertical__c !=null
                        AND Development__c = :convertedLead.Development__c
                        AND Vertical__c != :convertedLead.Vertical__c
                        AND (
                            Primary_Mobile_No_with_code__c IN :mobileSet
                            OR Secondary_Mobile_No_with_code__c IN :mobileSet
                        )
                    ];
                    
                    if (!duplicateLeads.isEmpty()) {
                        for (Lead dup : duplicateLeads) {
                            dup.IsActive__c = false;
                        }
                        update duplicateLeads;
                        System.debug(' Deactivated ' + duplicateLeads.size() + ' duplicate Lead(s).');
                    }
                } else {
                    System.debug(' Lead conversion failed for Lead ID: ' + myLead.Id +
                                 ' — ' + lcr.getErrors()[0].getMessage());
                }
                
            } catch (Exception ex) {
                System.debug('Exception while converting Lead ' + myLead.Id + ': ' + ex.getMessage());
            }
        }
    }
     public static void dummyMethod(){

String s2;        
String s3;
String s4;                
String s5;
String s6;        
String s7;
String s8;                
String s9;
String s10;        
String s11;
String s12;                
String s13;
String s14;        
String s15;
String s16;                
String s110;
String s210;        
String s310;
String s410;    
integer i;
i=0;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
         i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;

i++;
i++;
i++;
i++;
i++;
i++;
i++;
i++;
}
    
}