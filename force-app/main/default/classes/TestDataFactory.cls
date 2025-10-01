@isTest
public with sharing class TestDataFactory {
    
    // creating the complete structure of a project 
    // with project charges, legal entities, towers
    // construction stages, payment plan
    public static Map<String,Id> createMasterProject(String pName) {
            Map<String,Id> recordIdMap = new Map<String,Id>();
            // Legal Entity Creation
    /*        Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name ='RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            recordIdMap.put('LEGAL ENTITY',objlglentity.Id);
            
            // Broker Creation
             Broker__c objBroK = new Broker__c();
             objBroK.Broker_Code__c = '12346';
             objBroK.Broker_Name__c = 'Brokname';
             objBroK.Status__c = 'Actives';
             objBroK=RDSCommon.CreateBroker(objBroK);   */
             
            // Project Creation
            Project__c objpr = new Project__c();
            //objpr.Project_Code__c = 'T35';
            objpr.Name = pName;
            //objpr.Start_Date__c = System.today().addDays(-5);
       //     objpr.RDS_Company_Code__c = objlglentity.Id;
            //objpr.RDS_Interest_Rate__c = 12;
            //objpr.Project_Stage__c='Launch';
            //objpr.Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            //objpr.Project_Property_Type__c = 'Residential';
            //objpr.S_Floor_Rise_Rate__c = 150;
            //objpr.S_Applicable_From_Floor__c = 5;
            //objpr.S_View1_PLC__c = 10;
            //objpr.S_View2_PLC__c = 20;
            //objpr.S_View3_PLC__c = 30;
            //objpr.NPV__c = 12;
            //objpr.S_Ready_Reckoner_Rate__c = 24000;
            //objpr.Token_Amount__c = 200000;
            //objpr.Service_Tax_Required_On_Token_Amount__c = true;
            //objpr.Total_Max_Discount_Allowed__c = 100;
            //objpr.Discount1_Type__c = 'NRI Discount';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            //objpr.Discount1_Per_Sq_Ft__c = 1000;
            //objpr.Discount2_Type__c = 'Festive Discount';
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            //objpr.Discount2_Lumpsum__c = 100000;
            //objpr.Allotment_Charges_1__c = 10000;
            //objpr.Allotment_Charges_2__c = 10000;
            //objpr.Allotment_Charges_3__c = 10000;
            //objpr.Allotment_Charges_4__c = 10000;
            //objpr.Allotment_Charges_5__c = 10000;
            //objpr=RDSCommon.CreateProject(objpr);
            //recordIdMap.put('PROJECT',objpr.Id);
            
            // Configuration type creation
            /*Project_Unit_Type__c objProjectUnitType = new Project_Unit_Type__c();
            objProjectUnitType.name='ONE BHK';
            objProjectUnitType.RDS_Project__c =objpr.id;
            objProjectUnitType=RDSCommon.CreateProjectUnitType(objProjectUnitType);
            */
              
     /*         // Unit structure creation
             Unit_Number_Structure__c objUn = new Unit_Number_Structure__c();
             objUn.Name = 'testUN';
             objUn.Description__c = 'Desc';
             objUn.Sequence_No__c = 2;
             objUn.Project__c = objpr.Id;
             objUn.Maximum_Length__c = 2;
             objUn.Delimiter__c = '/';
             objUn=RDSCommon.CreateUnitNumberStructure(objUn);
            // tower creation 
             Tower__c t = new Tower__c();
             t.Name = 'Tower X';
             t.ProjectName__c = objpr.Id;
             t = RDSCommon.CreateTower(t);
             recordIdMap.put('TOWER',t.Id);
             
             // tax slabs creation
             Tax_Slab__c taxS = new Tax_Slab__C();
             taxS.name = 'Service Tax 1';
             taxS.From_Date__c = System.today().addDays(-10);
             taxS.Percentage__c = 4.20;
             taxS = RDSCommon.CreateTaxSlab(taxS);
             
             Tax_Slab__c taxS1 = new Tax_Slab__C();
             taxS1.name = 'Service Tax 2';
             taxS1.From_Date__c = System.today().addDays(-10);
             taxS1.Percentage__c = 14;
             taxS1 = RDSCommon.CreateTaxSlab(taxS1);
             // global charges creation
             Global_Charges__c ObjGloChrg = new Global_Charges__c();
             ObjGloChrg.Name = 'Basic';
             ObjGloChrg.Code__c = '011';
             ObjGloChrg.Description__c = 'Basic';
             ObjGloChrg.Sequence_No__c = 99;
             ObjGloChrg.Charge_Type__c = 'Basic';
             ObjGloChrg.Nature_of_Charge__c = 'Debtors';
             ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
             
             Global_Charges__c ObjGloChrg1 = new Global_Charges__c();
             ObjGloChrg1.Name = 'Club Membership';
             ObjGloChrg1.Code__c = '012';
             ObjGloChrg1.Description__c = 'Club Membership';
             ObjGloChrg1.Sequence_No__c = 100;
             ObjGloChrg1.Charge_Type__c = 'Society Charges';
             ObjGloChrg1.Nature_of_Charge__c = 'Debtors';
             ObjGloChrg1=RDSCommon.CreateGlobalCharges(ObjGloChrg1);
             
             Global_Charges__c ObjGloChrg2 = new Global_Charges__c();
             ObjGloChrg2.Name = 'Tax Charge';
             ObjGloChrg2.Code__c = '015';
             ObjGloChrg2.Description__c = 'SERVICE TAX';
             ObjGloChrg2.Sequence_No__c = 105;
             ObjGloChrg2.Charge_Type__c = 'Tax';
             ObjGloChrg2.Nature_of_Charge__c = 'Debtors';
             ObjGloChrg2=RDSCommon.CreateGlobalCharges(ObjGloChrg2);
             
             // project charges creation
             // one basic
             // other is club membership, both are active.
             // one is lumpsum at project level and basic is based on ratelist defined for that unit
             Project_Charges__c PCharge = new Project_Charges__c();
             PCharge.Charge_Code__c = ObjGloChrg.Id;
             PCharge.Project__c = objpr.Id;
             PCharge.Name = 'Basic';
             PCharge.Active__c = true;
             PCharge.Applied_This_Charge_To_FA__c = true;
             PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
             PCharge.S_Charge_Bucket__c = 'Agreement Value';
             PCharge.S_Payable_At__c = 'As per payment milestone';
             PCharge.Payment_Plan_Applicable__c = true;
             pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
             pCharge.Service_Tax_Applicable_on_this_charge__c = true;
             PCharge=RDSCommon.CreateProjectCharges(PCharge);
             
             Project_Charges__c PCharge1 = new Project_Charges__c();
             PCharge1.Charge_Code__c = ObjGloChrg1.Id;
             PCharge1.Project__c = objpr.Id;
             PCharge1.Name = 'Club Membership';
             PCharge1.Active__c = true;
             PCharge1.Applied_This_Charge_To_FA__c = true;
             PCharge1.S_Charge_Calculated_As__c = 'Lumpsum at Project Level';
             pCharge1.S_Lumpsum_Charge_Amount__c = 100000;
             PCharge1.S_Charge_Bucket__c = 'Society Charges';
             PCharge1.S_Payable_At__c = 'At Possession';
             PCharge1.Payment_Plan_Applicable__c = true;
             PCharge1.Service_Tax_Percentage__c = 'Service Tax 2';
             PCharge1.Service_Tax_Applicable_on_this_charge__c = true;
             PCharge1=RDSCommon.CreateProjectCharges(PCharge1);
             
             // unit creation associated to project and tower
             Project_Unit__c objPU1 = new Project_Unit__c();    
             objPU1.Name = 'TestFive';      
             objPU1.Project__c = objpr.Id;
             objPU1.Project_Unit_Type__c=objProjectUnitType.id;
             objPU1.Param1__c = '5';
             objPU1.UnitNo__c ='TestFive';
             objPU1.Unit_status__c='Booked';
             objPU1.Actual_Area_value__c = 2218;
             objPU1.TowerName__c = t.Id;
             objPU1.Single_car_park_Earmarked__c = 0;
             objPU1.Single_Open_Earmarked__c = 0;
             objPU1.Tandem_Open_Earmarked__c = 0;
             objPU1.Tandem_car_park_Earmarked__c = 0;
             objPU1.Tandem_Open_Earmarked__c = 0;
             objPU1.Stack__c = 0;
             objPU1=RDSCommon.CreateProjectUnit(objPU1);
             recordIdMap.put('UNIT',objPU1.Id);    */
             
             // account creation 
             Account objac = new Account();
             objac.FirstName = 'Shock';
             objac.LastName = 'Wave';
        //     objac.Project__c = objpr.Id;
            // objac.Correspondence_Address__c = 'Delhi';
             //objac.Category__c = 'General';
          //   objac.Unit__c = objPU1.Id;
             objac=RDSCommon.CreateAccount(objac);
             recordIdMap.put('ACCOUNT',objac.Id);
             
             // opportunity creation              
             Opportunity objOpportunity = new Opportunity();
             objOpportunity.Name = 'Test';
             objOpportunity.CloseDate = System.today();
             objOpportunity.AccountId = objac.Id; 
             objOpportunity.Status__c = 'Active'; 
             objOpportunity.StageName = 'Opportunity Identified'; 
             objOpportunity.RW_Project__c = objpr.Id; 
             objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
             recordIdMap.put('OPPORTUNITY',objOpportunity.Id);
            
    /*         // construction stage creation
             // two stages are being created
             Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
             objPCS.Project__c = objpr.Id;
             objPCS.Name = 'Commencement of Raft/Foundation';
             objPCS.Code__c ='Test';
             objPCS.Description__c='Commencement of Raft/Foundation';
             objPCS.Planned_date_of_completion__c = System.today().addDays(365);
             objPCS.Tower__c = t.Id;
             insert objPCS;
             
             Project_Construction_Stages__c objPCS1 = new Project_Construction_Stages__c();
             objPCS1.Project__c = objpr.Id;
             objPCS1.Name = 'At Fit Out Possession';
             objPCS1.Code__c ='Test1';
             objPCS1.Description__c='At Fit Out Possession';
             objPCS1.Planned_date_of_completion__c = System.today().addDays(365);
             objPCS1.Tower__c = t.Id;
             insert objPCS1;
             
             // rateList creation
             Rate_List_Header__c objRlh = new Rate_List_Header__c();
             objRlh.Name = 'Basic RL Header';
             objRlh.Project__c = objpr.Id;
             objRlh.Project_Charges__c = PCharge.Id;
             objRlh.Rate_list__c = 'All Charges';
             objRlh.Effective_From__c = system.today().addDays(-3);
             objRlh=RDSCommon.CreateRateListHeader(objRlh);
             
             Rate_List_Detail__c objRld = new Rate_List_Detail__c();
             objRld.Name = 'Basic RL Detail';
             objRld.Charge_Based_On__c = 'Rate';
             objRld.Percent__c = 23600;
             objRld.Project__c = objpr.Id;
             objRld.Rate_List_Header__c = objRlh.id;
             objRld = RDSCommon.CreateRateListHeader(objRld);
             
             Rate_List__c objRL = new Rate_List__c();
             objRL.Rate_List_HeaderID__c = objRlh.Id;
             objRL.Project__c = objpr.Id;
             objRL.Global_Charges__c = ObjGloChrg.Id;
             objRL.Project_Charges__c = PCharge.Id;
             objRL.Project_Unit__c = objPU1.Id;
             objRL.Value__c = 2218;
             objRL.Rate__c = 23600;
             objRL.Rate_List_Detail__c = objRLd.id;
             objRL=RDSCommon.CreateRateList(objRL);
             
             // payment plan creation associated to the construction stages
             Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
             objPaymentPlan.Name ='Pay Plan 1';
             objPaymentPlan.Project__c = objpr .Id;
             objPaymentPlan.Tower__c = t.Id;
             insert objPaymentPlan;
             recordIdMap.put('PAYPLAN',objPaymentPlan.Id);
             
             // standard payment plan header creation
             Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
             objSPP.Project__c = objpr.Id;
             objSPP.Charge_Code__c= PCharge.Id;
             objSPP.Payment_Plan__c=objPaymentPlan.id;
             objSPP.Name='Basic Header';
             objSPP.Plan_Code__c= '89';
             objSPP.tower__c = t.ID;
             objSPP.Effective_from__c = System.today();
             objSPP=RDSCommon.CreateStandardPayPlanHeader(objSPP);
             
             Standard_Pay_Plan_Header__c objSPP1 = new Standard_Pay_Plan_Header__c();
             objSPP1.Project__c = objpr.Id;
             objSPP1.tower__c = t.ID;
             objSPP1.Charge_Code__c= PCharge1.Id;
             objSPP1.Payment_Plan__c=objPaymentPlan.id;
             objSPP1.Name='Club Header';
             objSPP1.Plan_Code__c= '90';
             objSPP1.Effective_from__c = System.today();
             objSPP1=RDSCommon.CreateStandardPayPlanHeader(objSPP1);
             
             // standard payment plan details creation for basic 
             // created 4 installments/milestones. two due date based and 2 Construction Linked
             Standard_Customer_Pay_Plan_Detail__c    objSPPD = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD.Standard_Pay_Plan_Header__c = objSPP.id;
             objSPPD.Project__c=objpr.id;
             objSPPD.tower__c = t.ID;
             objSPPD.Is_to_be_Paid__c='From Dt. of Booking';
             objSPPD.Days_Months__c='Day(s)';
             objSPPD.Days_Months_Value__c=5;
             objSPPD.Amount__c='Amount';
             objSPPD.Amount_Value__c=110000;
             objSPPD.Installment__c = 100;
             objSPPD= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD);
             
             Standard_Customer_Pay_Plan_Detail__c    objSPPD4 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD4.Standard_Pay_Plan_Header__c = objSPP.id;
             objSPPD4.Project__c=objpr.id;
             objSPPD4.tower__c = t.ID;
             objSPPD4.Is_to_be_Paid__c='From Dt. of Booking';
             objSPPD4.Days_Months__c='Day(s)';
             objSPPD4.Days_Months_Value__c=0;
             objSPPD4.Amount__c='Amount';
             objSPPD4.Calculate_Installment_Amount_as__c=10;
             objSPPD4.Total_Charge_Value_Minus__c = 110000;
             objSPPD4= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD4);
             
              Standard_Customer_Pay_Plan_Detail__c    objSPPD2 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD2.Standard_Pay_Plan_Header__c = objSPP.id;
             objSPPD2.Project__c=objpr.id;
             objSPPD2.tower__c = t.ID;
             objSPPD2.Is_to_be_Paid__c='Construction Stage';
             objSPPD2.Days_Months__c='Day(s)';
             objSPPD2.Project_Construction_Stages__c=objPCS.id;
             objSPPD2.Days_Months_Value__c=5;
             objSPPD2.Amount__c='Percentage';
             objSPPD2.Amount_Value__c=40;
             objSPPD2.Installment__c = 102;
             objSPPD2= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD2);
             
             Standard_Customer_Pay_Plan_Detail__c    objSPPD3 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD3.Standard_Pay_Plan_Header__c = objSPP.id;
             objSPPD3.Project__c=objpr.id;
             objSPPD3.tower__c = t.ID;
             objSPPD3.Is_to_be_Paid__c='Construction Stage';
             objSPPD3.Days_Months__c='Day(s)';
             objSPPD3.Project_Construction_Stages__c=objPCS1.id;
             objSPPD3.Days_Months_Value__c=5;
             objSPPD3.Amount__c='Percentage';
             objSPPD3.Amount_Value__c=50;
             objSPPD3.Installment__c = 103;
             objSPPD3= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD3);
             
             // detail record for club member ship charges
             // collected 100% in a single installment on fit out possession
             Standard_Customer_Pay_Plan_Detail__c    objSPPD5 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD5.Standard_Pay_Plan_Header__c = objSPP1.id;
             objSPPD5.Project__c=objpr.id;
             objSPPD5.tower__c = t.ID;
             objSPPD5.Is_to_be_Paid__c='Construction Stage';
             objSPPD5.Days_Months__c='Day(s)';
             objSPPD5.Project_Construction_Stages__c=objPCS1.id;
             objSPPD5.Days_Months_Value__c=5;
             objSPPD5.Amount__c='Percentage';
             objSPPD5.Amount_Value__c=100;
             objSPPD5.Installment__c = 100;
             objSPPD5= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD5);
             
             //create the approvers team
             Team__c objTeam = new Team__c();
             objTeam.Name = 'Sales Approvers Team';
             objTeam.Project__c = objpr.id;
             objTeam.Team_Type__c = 'Sales Approvers Team';
             objTeam.Tower__c = t.id;
             insert objTeam;
             
             //create users
             User a1 = createUserSysAdmin('One','Galvatron', 'galvatron1@radius.com', 'galvatron1@radius.com');
             User a2 = createUserSysAdmin('Two','Galvatron', 'galvatron2@radius.com', 'galvatron2@radius.com');
             User a3 = createUserSysAdmin('Three','Galvatron', 'galvatron3@radius.com', 'galvatron3@radius.com');
             
             // insert team as team members
             Team_Members__c tm1 = new Team_Members__c();
             tm1.Team__c = objTeam.Id;
             tm1.User_Active__c = true;
             tm1.Approver_Type__c = 'First Level';
             tm1.User__c = a1.id;
             insert tm1;
             recordIdMap.put('APPROVER1',tm1.Id);
             
             Team_Members__c tm2 = new Team_Members__c();
             tm2.Team__c = objTeam.Id;
             tm2.User_Active__c = true;
             tm2.Approver_Type__c = 'Second Level';
             tm2.User__c = a2.id;
             insert tm2;
             recordIdMap.put('APPROVER2',tm2.Id);
             
             Team_Members__c tm3 = new Team_Members__c();
             tm3.Team__c = objTeam.Id;
             tm3.User_Active__c = true;
             tm3.Approver_Type__c = 'Third Level';
             tm3.User__c = a3.id;
             insert tm3;
            recordIdMap.put('APPROVER3',tm3.Id);     */
            
            return recordIdMap;    
  } 
  public static List<Lead> createLead(Integer numofLeads) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numofLeads;i++) 
        {
            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , RW_Mobile_No__c='123456789' + i, RW_Budget__c = '< 1Cr', RW_Configuration__c = '1 BHK', RW_Time_line__c = 'Ready Possession', RW_Location__c = 'Airoli',call_rating__c = 0);
            
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
  
  
  
  /// Create lead for project sms field by vikas
  
   public static List<Lead> createLeadProject(Integer numofLeads, Id ProjectId) {
    List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numofLeads;i++) {
            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i, RW_Project__c = ProjectId);
            
            leads.add(l);
        }
        insert leads;
        return leads;  
  }
  
  public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , mobilePhone= mobile,RW_Mobile_No__c= mobile, MasterRecord__c = isMaster);
        insert l;
        return l;  
  }


public static Lead createLeadTemplateA(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster);
        insert l;
        return l;   
    }
    
    public static Lead createLeadTemplateB(String lastName, String email, String mobile, Boolean isMaster, String campaignCode, String country) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode);//, RW_Country__c = country 
        insert l;
        return l;   
    }
    
    public static Lead createLeadTemplateE(String lastName, String email, String altEmail, String mobile, Boolean isMaster) {
        Lead l = new Lead(lastName= lastName, Email= email , mobilePhone= mobile,   RW_Mobile_No__c= mobile,RDS_Alternate_Email_Id__c = altemail, MasterRecord__c = isMaster);
        insert l;
        return l;  
    }
      
    public static Lead createLeadTemplateF(String lastName, String email, String mobile, String altMobile, Boolean isMaster) {
            Lead l = new Lead(lastName= lastName, Email= email , RW_Mobile_No__c= mobile,mobilePhone= mobile, phone= altMobile, MasterRecord__c = isMaster);
            insert l;
            return l;  
    }





  // creates  a person account with the basic parameters
  public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
    RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile,Mobile_No__c = Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster);
    insert a;
    return a;
  }
 
 
   // creates  a person account with the CAMPAIGN  AND CHANNEL parameters
    public static Account createPATemplateB(String accName, String Email, String Mobile, Boolean isMaster,String campaignCode) {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile,Mobile_No__c = Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode);
        insert a;
        return a;
    }

    // creates  a person account with the CAMPAIGN  AND CHANNEL parameters and alternate contact details
    public static Account createPATemplateAlt(String accName, String Email, String Mobile, Boolean isMaster,String campaignCode) {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, Alternate_Email__c = email, phone= Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster, Campaign_Code__c = campaignCode );
        insert a;
        return a;
  }
  
     //create Campaign with CampaignCode
      public static Campaign createCampaignCC(String cName, String Type) {
        Campaign c = new Campaign(Name = cName, Type = Type, isActive = true);
        insert c;
        Campaign cnew = [Select Id, Name, Type from Campaign where id= : c.id];//Campaign_Code__C
        return cnew;
    }
    //create Campaign with CampaignCode
    public static Campaign createCampaignCCNew(String cName, String Type, String ccCode) {
        Campaign c = new Campaign(Name = cName, Type = Type, isActive = true, Digital_Maketing_Campaign_Code__c=ccCode);
        insert c;
        Campaign cnew = [Select Id, Name,  Digital_Maketing_Campaign_Code__c,Type from Campaign where id= : c.id];//Campaign_Code__C
        return cnew;
    }
 
 
  
 public static User createUserSysAdmin(string fn, string ln, string username, string email) {
    
    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = p.Id, alias= ln.substring(0,7),EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    insert u;
    return u;
    
  }
  
  public static Lead convertLead(Lead l) {
    LeadStatus convertStatus = [
            select MasterLabel
            from LeadStatus
            where IsConverted = true
            limit 1
       ];
       List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
       if (!l.isConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            String oppName = l.Name;
             lc.setLeadId(l.Id);
             lc.setOpportunityName(oppName);
             lc.setConvertedStatus(convertStatus.MasterLabel);
             leadConverts.add(lc);
        }
       if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
       }
       lead clead = [Select Id, ConvertedAccountId, ConvertedOpportunityId, IsConverted from Lead where id = :l.Id];
       return clead;
  }
  
  public static Project__c createProject(String ProjName, String ProjectCode)
    {
        Project__c objProject = new Project__c(Name = ProjName);//, Project_Code__c = projectCode
        insert objProject;
        return objProject;
    }
   public static Client__c createClients(String ClientName)
    { 
        Client__c clobj = new Client__c(Name = ClientName);
        insert clobj;
        return clobj;
    }
    
     public static List<Project__c> createProjectWithClient(Integer numOfProjects, String ProjectCode, Id clientId)
    {
        List<Project__c> pList = new list<Project__c>();
        for(Integer i=0;i<numOfProjects;i++){
            Project__c p = new Project__c(Name='Project'+i);//Project_Code__c = projectCode,,  ClientLookup__c= clientId
            pList.add(p);
        }
        insert pList;
        List<Project__c> newList1 = [Select Id, Name from Project__c where Id in :pList];//ClientLookup__c, ClientLookup__r.Id 
        return newList1;
    }
    
    // Create project for lead to store text sms field into project///
     public static Project__c createProjectforLead(String ProjName, String ProjectCode, String Thankyoutxt, String Noncontactxt)
    {
        Project__c objProject = new Project__c(Name = ProjName);//Project_Code__c = projectCode, ,Thank_You_Text__c= Thankyoutxt, Non_Contactable_Text__c=Noncontactxt
        insert objProject;
        return objProject;
    }
        
      public static List<Cluster__c> createClusters(Integer numOfClusters, Id projId){
        List<Cluster__c> cList = new list<Cluster__c>();
        for(Integer i=0;i<numOfClusters;i++){
            Cluster__c c = new Cluster__c(Name='Cluster'+i, Project__c = projId);
            cList.add(c);
        }
        insert cList;
        List<Cluster__c> newList = [Select Id, Name,Project__c, Project__r.Id from Cluster__c where Id in :cList];
        return newList;
    }
 
    public static List<Tower__c> createTowers(Integer numOfTowers, Id projId){
        List<Tower__c> tList = new list<Tower__c>();
        for(Integer i=0;i<numOfTowers;i++){
            Tower__c t = new Tower__c(Name='Tower'+i, ProjectName__c = projId);
            tList.add(t);
        }
        insert tList;
        List<Tower__c> newList = [Select Id, Name,ProjectName__c, ProjectName__r.Id from Tower__c where Id in :tList];
        return newList;
    }
    
    public static Project_Unit__c createProjectUnit(Id projId)
    {
        Project_Unit__c objProjUnit = new Project_Unit__c(Name = 'Test Project Unit', RW_Unit_Status__c = 'Vacant',RW_Project__c = projId);
        insert objProjUnit;
        return objProjUnit;
    }
    
    public static List<Project_Unit__c> createUnits(Id TowerId, Id pId){
            // Configuration type creation
            Project_Unit_Type__c objProjectUnitType1 = new Project_Unit_Type__c();
            objProjectUnitType1.name='ONE BHK';
            objProjectUnitType1.RDS_Project__c =pId;
            objProjectUnitType1=RDSCommon.CreateProjectUnitType(objProjectUnitType1);
            // Configuration type creation
            Project_Unit_Type__c objProjectUnitType2 = new Project_Unit_Type__c();
            objProjectUnitType2.name='TWO BHK';
            objProjectUnitType2.RDS_Project__c =pId;
            objProjectUnitType2=RDSCommon.CreateProjectUnitType(objProjectUnitType2);
            // Configuration type creation
            Project_Unit_Type__c objProjectUnitType3 = new Project_Unit_Type__c();
            objProjectUnitType3.name='THREE BHK';
            objProjectUnitType3.RDS_Project__c =pId;
            objProjectUnitType3=RDSCommon.CreateProjectUnitType(objProjectUnitType3);
            // Configuration type creation
            Project_Unit_Type__c objProjectUnitType4 = new Project_Unit_Type__c();
            objProjectUnitType4.name='FOUR BHK';
            objProjectUnitType4.RDS_Project__c =pId;
            objProjectUnitType4=RDSCommon.CreateProjectUnitType(objProjectUnitType4);
            // Configuration type creation
            Project_Unit_Type__c objProjectUnitType5 = new Project_Unit_Type__c();
            objProjectUnitType5.name='FIVE BHK';
            objProjectUnitType5.RDS_Project__c =pId;
            objProjectUnitType5=RDSCommon.CreateProjectUnitType(objProjectUnitType5);
        List<Project_Unit__c> uList = new list<Project_Unit__c>();    
        Integer numOfFloor = 10;
        Integer UnitsPerFloor = 5;
        for(Integer i=1;i<=numOfFloor;i++){
            for(Integer j=0; j<UnitsPerFloor; j++){
                Project_Unit__c u = new Project_Unit__c();
                u.RW_Floor__c = i;
                u.Actual_Area_value__c = 1000;
                u.RW_Project__c = pId;
                //u.Reserved__c = false;
                u.RW_Param1__c = 'trtft';
                u.RW_Param2__c = '76453';
                u.RW_Param3__c = '14253'; 
                u.RW_Param4__c = 'MLKJ6'; 
                u.RW_Param5__c = '784KL';
                u.RW_Delimeter__c = 'JUH';
                if(j==1){
                    u.RW_Unit_Status__c = 'Open';
                    u.Project_Unit_Type__c = objProjectUnitType1.Id;
                    u.Name = String.valueOf((u.RW_Floor__c*100) + 1);
                    u.UnitNo__c =  String.valueOf((u.RW_Floor__c*100) + 1);    
                    u.TowerName__c = TowerId;
                }else if(j==2){
                    u.RW_Unit_Status__c = 'Blocked';
                    u.Project_Unit_Type__c = objProjectUnitType2.Id;
                    u.Name = String.valueOf((u.RW_Floor__c*100) + 2);
                    u.UnitNo__c =  String.valueOf((u.RW_Floor__c*100) + 2);
                    u.TowerName__c = TowerId;
                }else if(j==3){
                    u.RW_Unit_Status__c = 'Sold';
                    u.Project_Unit_Type__c = objProjectUnitType3.Id;
                    u.Name = String.valueOf((u.RW_Floor__c*100) + 3);
                    u.UnitNo__c =  String.valueOf((u.RW_Floor__c*100) + 3);
                    u.TowerName__c = TowerId;
                }else if(j==4){
                    u.RW_Unit_Status__c = 'Reserved';
                    u.Project_Unit_Type__c = objProjectUnitType4.Id;
                    u.Name = String.valueOf((u.RW_Floor__c*100) + 4);
                    u.UnitNo__c =  String.valueOf((u.RW_Floor__c*100) + 4);
                    u.TowerName__c = TowerId;
                }else{
                    u.RW_Unit_Status__c = 'Booked';
                    u.RW_Booking_Date__c = System.Today();
                    u.Project_Unit_Type__c = objProjectUnitType5.Id;
                    u.Name = String.valueOf((u.RW_Floor__c*100) + 5);
                    u.UnitNo__c =  String.valueOf((u.RW_Floor__c*100) + 5);
                    u.TowerName__c = TowerId;
                }
                uList.add(u);
            }
        }
        insert uList;
        
        return uList;
    }     

  // the parameters are set to match the project parameters to fulfill the data needs for opportunity rating calculation
    public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
        List<Opportunity> oList = new List<Opportunity>();
         List<Opportunity> oList2 = new List<Opportunity>();
        Date closeDate; 
        for(Integer i =0;i<numOfOpp; i++){
            closeDate = Date.newInstance(2015, 8,29);
            Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = ProjId,closeDate=System.today(),Call_Rating__c = 0);
            oList.add(o);            
        }
        Opportunity o1 = new Opportunity(Name = 'Opp-2', StageName='Unit Booked', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = ProjId,closeDate=System.today(),Call_Rating__c = 0,Last_Call__c ='Missed Call');
        insert o1;  
        oList2.add(o1);
        MAP<Id,Opportunity> OppMap = new MAP<Id,Opportunity>();
        OppMap.putall(oList);
        if(Oppmap.size()>0){
            insert Oppmap.values();
        }
         for(Opportunity Opp1 : OppMap.values()) 
        {
            oList2.add(Opp1);
        }
        
       //insert oList;
        return oList2;
    }
 
 
 // Create oppty for account with sub marketing as Cross project
   public static List<Opportunity> createOpptyForAccountCross(Id  accId, Id ProjId, Integer numOfOpp){
    List<Opportunity> oList = new List<Opportunity>();
    Date closeDate; 
    for(Integer i =0;i<numOfOpp; i++){
      closeDate = Date.newInstance(2015, 8,29);
      Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Opportunity Identified', Amount=5000000, AccountId =accId, Status__c ='Active');
      oList.add(o);            
    }
    insert oList;
    return oList;
  }
 
 
  
  public static List<Task> createTasksForOpp(Id oppId, Integer NumberofTasks, String TaskType) {
    List<task> tList = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
      tList.add(t);
    }
    insert tList;
    return tList;
  }
  
    public static List<Task> createTasksForOppWithStatus(Id oppId, Integer NumberofTasks, String TaskType, String callAttemptStatus,String previousCallStatus) {
    List<task> tList = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()),   Call_Attempt_Status__c = callAttemptStatus, Previous_Call_Attempt_Status__c=PreviousCallStatus);
      tList.add(t);
    }
    insert tList;
    return tList;
  }
 
  
   public static List<Task> createTasksForLead(Id leadId, Integer NumberofTasks, String TaskType) {
    List<task> tList = new List<task>();
     List<task> tList2 = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()), Next_Action_Date__c = System.Today() );
      tList.add(t);
    }
    task t2 = new Task(Subject = 'New Task -2 ' , Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()), Next_Action_Date__c = System.Today() );
       tList2.add(t2);
       MAP<Id,Task> TaskMap = new MAP<Id,Task>();
       TaskMap.putall(tList);
       if(TaskMap.size()>0){
           insert TaskMap.values();
       }
       for(Task Opp1 : TaskMap.values()) 
       {
           tList2.add(Opp1);
       }
       
      // insert tList;
       return tList2;
  }
  
     public static List<Task> createTasksForLeadWithStatus (Id leadId, Integer NumberofTasks, String TaskType, String callAttemptStatus,String PreviousCallStatus) {
    List<task> tList = new List<task>();
     List<task> tList2 = new List<task>();
    for(Integer i=0; i<NumberofTasks; i++){
      task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()), Call_Attempt_Status__c = callAttemptStatus,Previous_Call_Attempt_Status__c=PreviousCallStatus );
      tList.add(t);
    }
     task t2 = new Task(Subject = 'New Task - 2' , Task_Type__c = TaskType, activityDate=System.Today(), whoId = leadId, call_time__c = TaskManagementServices.FormatTime(system.now()), Call_Attempt_Status__c = callAttemptStatus,Previous_Call_Attempt_Status__c=PreviousCallStatus );
      tList2.add(t2);
       MAP<Id,Task> TaskMap = new MAP<Id,Task>();
        TaskMap.putall(tList);
        if(TaskMap.size()>0){
            insert TaskMap.values();
        }
         for(Task Opp1 : TaskMap.values()) 
        {
            tList2.add(Opp1);
        }
      
   // insert tList;
    return tList2;
  }
  
  

      // For Sending Brochure Attachment. added by Netra. - 19/04/2016
     /** public static void createProjAttachment(Id projId)
      {
            ProjectAttachments__c pat = new ProjectAttachments__c(Name='Attachement-1', AttachmentType__c = 'Brochure', latest__C = true, ProjectName__c=projId);
            insert pat;
            String bodyStr = '\n\n Brochure for project' + projId + ' attached';
            Attachment att=new Attachment();
            att.Body=Blob.valueOf(bodyStr);
            att.Name='Att_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
            att.parentId=pat.id;
            insert att;                         
      }
      // For Sending Brochure Attachment. added by Netra. - 19/04/2016
      public static void createEmailTemplate(String tName, String subject, String Body, String devName)
      {
            EmailTemplate et = new EmailTemplate(Name=tName, Subject=subject, Body=body,developerName = devName);
            et.FolderId = UserInfo.getUserId();
            et.TemplateType ='Text';
            insert et;
      }
     */   

       public static SMS_Schedule_SMS_c__c createSMSRecord(Id oppId){
       SMS_Schedule_SMS_c__c s = new SMS_Schedule_SMS_c__c();
       s.Context_Record__c = oppId;
       s.Immediate__c = True;
       s.Sender_Mobile__c= '919823475883';
       s.SMS_Long_text__c= 'Message from test class';
       insert s;
       return s;
       
   
   }
   
   // Create Quotation
   
 
   
  /** public static List<Quotation__c> createQuote(Project__c p, Project_Unit__c u, Id oppId, Integer numofq) {
    List< Quotation__c > quotes = new List<Quotation__c>();
        for(Integer i=0;i<numofq;i++) 
        {
            
            Quotation__c q = new Quotation__c(    //firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , mobilePhone='123456789' + i);
            
            Name = 'Xanadu Quotation',
            Opportunity__c = oppId,
            Saleable__c = 1000,
            Project__c = p.Id,//'a00R0000008TsBq'
            //Project__r.Name = 'Test Project',
           // Date Prepared_Date__c = '25/5/2016',
            Zone__c = 'Test Cluster',
            Wing__c = 'Tower A',
            Appartment_Configuration__c = 'SMALL OFFICE',
            FloorNo__c = 1,
            Project_Unit__c = u.Id,
            //Project_Unit__r.Name = 'UNIT 104',
            Base_Rate_PSF__c = 14500,
            Base_Rate_L__c = 17400000,
            Premium_Charges_Description_1__c = 'Sea View',
            Premium_Charges_Description_2__c = 'Lake View',
            Premium_Charges_Description_3__c = 'Garden View',
            Premium_Charges_Description_4__c = 'Skyline View',
            Premium_Charges_Amount_1__c = 75.00,
            Premium_Charges_Amount_2__c = 80.00,
            Premium_Charges_Amount_3__c = 50.00,
            Premium_Charges_Amount_4__c = 100.00,
            Floor_Rise_PSF__c = 2100,
            Floor_Rise_L__c = 2520000,
            Carpet_Area_Sq_Ft__c = 790,
            Infrastructure_charges__c = 300000,
            //Development_Charges_PSF__c = 27,
            Development_Charges_L__c = 27000,
            Stamp_Duty__c = 206130.00,
            Stamp_Duty_D__c = 0,
            Registration_Charges__c = 39000,
            MVAT__c = 62500,
            MVAT_ST__c = 0,
            MVAT_D__c = 0,
            MVAT_ST_D__c = 0,
            Service_Taxes_Total__c = 1268614,
            Service_Taxes_Total_D__c = 0,
            Project_Specific_Charges_Amount_1__c = 103065.00,
            Project_Specific_Charges_Amount_2__c = 0.00,
            Project_Specific_Charges_Amount_3__c = 0.00,
            Project_Specific_Charges_Description_1__c = 'MMRDA Charges',
            Project_Specific_Charges_Description_2__c = 'MMRDA1 Charges',
            Project_Specific_Charges_Description_3__c = 'MMRDA2 Charges',
            Legal_Charges__c = 50000,
            Legal_Charges_ST__c = 7250,
            Club_Membership_Charges__c = 0,
            Club_Membership_ST__c = 0,
            Other_Charges_Amount_1__c = 100000.00,
            Other_Charges_Amount_2__c = 50000.00,
            Other_Charges_Amount_3__c = 50000.00,
            Other_Charges_Category_1__c = 'Other Charges',
            Other_Charges_Category_2__c = 'Other Charges',
            Other_Charges_Category_3__c = 'Other Charges',
            Other_Charges_Desc_1__c = 'Ultimate Organization formation & related charges',
            Other_Charges_Desc_2__c = 'Legal Charges',
            Other_Charges_Desc_3__c = 'Electric and Water',
            Other_Charges_Desc_4__c = 'Piped Gas',
            Other_Charges_Desc_5__c = 'Club Membership Charges',
            Other_Charges_Desc_6__c = 'Annual Club Membership Charges for 18 months#',
            Other_Charges_Desc_7__c = 'Electricity Deposit Reimbursement',
            Other_Charges_Desc_8__c = 'Land Under Construction (LUC) Reimbursement*',
            Other_Charges_Desc_9__c = 'Advance Property Charges for a period of 18 months*#',
            Other_Charges_Desc_10__c = 'Building Protection Deposit',
            Other_Charges_Desc_11__c = '',
            Other_Charges_Desc_12__c = '',
            Other_Charges_Desc_13__c = '',
            Other_Charges_Desc_14__c = '',
            Other_Charges_Amount_4__c = 150000.00,
            Other_Charges_Amount_5__c = 200000.00,
            Other_Charges_Amount_6__c = 100000.00,
            Other_Charges_Amount_7__c = 100000.00,
            Other_Charges_Amount_8__c = 100000.00,
            Other_Charges_Amount_9__c = 100000.00,
            Other_Charges_Amount_10__c = 100000.00,
            
            Proj_Maint_Charges_Desc_1__c = 'X1 charges @ Rs.Y1 for Z1 months',
            Proj_Maint_Charges_Desc_2__c = 'X2 charges @ Rs.Y2 for Z2 months',
            Proj_Maint_Charges_Desc_3__c = 'X3 charges @ Rs.Y3 for Z3 months',
            Project_Maintenance_Charges_Amount_1__c = 100000.00,
            Project_Maintenance_Charges_Amount_2__c = 200000.00,
            Project_Maintenance_Charges_Amount_3__c = 300000.00,
           // Service_Tax_Total__c = 1064655.00,
            Discount_1_Type__c = 'Total Discount',
            Discount_2_Type__c = 'Total Discount',
            Discount_1_PSF__c = 0,
            Discount_2_PSF__c = 0,
            Other_Charges_Amount_11__c = 0.00,
            Other_Charges_Amount_12__c = 0.00,
            Other_Charges_Amount_13__c = 0.00,
            Other_Charges_Amount_14__c = 0.00);
           
            quotes.add(q);
        }
        insert quotes;
        return quotes;  
    }
 **/
     
   /**  
    public static List<Booking__c> createBookingNew(Opportunity opp, Id quoteId, Id projectId,Id unitId,Integer numofb)
    {
    
        List< Booking__c> bks = new List<Booking__c>();
        for(Integer i=0;i<numofb;i++) 
        {
            Booking__c bookingrecord = new Booking__c();
            
            bookingrecord.Booking_Date__c   = system.today();
            bookingrecord.Application_No__c = '123';
            bookingrecord.Opportunity__c =opp.Id ;
            //bookingrecord.Opportunity__r.Account.salutation =opp.Account.salutation;
            //bookingrecord.Opportunity__r.Account.Name =opp.Account.Name;
            bookingrecord.No_of_Parking__c = 1;
           // bookingrecord.Opportunity__r.Account.BillingAddress = opp.Account.BillingAddress;
            bookingrecord.Allotment_Premium__c = 41375000;
            bookingrecord.Source_of_Booking__c = 'Direct';
            bookingrecord.Booking_Source_Details__c ='abcdefg';
            bookingrecord.Sub_Source__c = 'Hoardings';
            bookingrecord.Date_for_offer_of_Possession__c =system.today();
            /*bookingrecord.Opportunity__r.Account.BillingStreet = 'xxx road';
            bookingrecord.Opportunity__r.Account.BillingCity = 'Pune';
            bookingrecord.Opportunity__r.Account.BillingState = 'Maharshtra';
            bookingrecord.Opportunity__r.Account.BillingPostalCode = '411255';
            bookingrecord.Opportunity__r.Account.BillingCountry ='India';
            bookingrecord.Opportunity__r.Account.Mobile__c ='92414141';
            bookingrecord.Opportunity__r.Account.Alternate_number_1__c = '6514444';
            bookingrecord.Opportunity__r.Mailing_Address__c ='zzzz xxx yyy';
            bookingrecord.Opportunity__r.Account.PersonEmail = 'abc@gmail.com';
            bookingrecord.Opportunity__r.Account.Pan__c ='951951951';
            bookingrecord.Opportunity__r.Account.Resident_Status__c ='zzz';
            bookingrecord.Opportunity__r.Other_Applicants_Name__c = 'other applicant';
            bookingrecord.Project__c = projectId;
            bookingrecord.Unit_No__c = unitId;
            //bookingrecord.Project__r.Name = 'Test Project';
            //bookingrecord.Unit_No__r.Name = 'UNIT 102';
            //bookingrecord.Unit_No__r.Carpet_Area__c = 1200;
            //bookingrecord.Unit_No__r.Configuration__c ='2 BHK';
            bookingrecord.Future_Correspondence_Contact_Name__c = 'nnkkdd';
            
            bks.add(bookingrecord);
        }
        insert bks;
        return bks;
    } 
    */
  /**  public static Receipt__c createReceipt(Id bookingId, Id quoteId, Id unitId)
    {
        Receipt__c receiptrecord = new Receipt__c();
        receiptrecord.Mode__c = 'Cheque';
        receiptrecord.Cheque_DD__c = '234';
        receiptrecord.Total_Amount__c = 123456;
        receiptrecord.DraweeBank__c = 'SBI';
        receiptrecord.Receipt_Date__c = System.today();
        receiptrecord.Token_Amount_ST__c = True;
        receiptrecord.Token_Amount_Receipt__c = False;
        
        insert receiptrecord ;
        return receiptrecord ;

    }
    **/
    /*public static List <Applicant_Details__c> createApplicant(Id bk,Integer numofApp)
    {
        List< Applicant_Details__c> apps = new List<Applicant_Details__c>();
        for(Integer i=0;i<numofApp;i++) 
        {
            Applicant_Details__c app1 = new Applicant_Details__c(Name = 'my Name',Mobile_Number__c ='9360197219',Email_Address__c='a@gmail.com',Landline_Number__c='24157896',Applicant_Number__c='Primary Applicant',Booking__c=bk,Pincode__c=123456,Country__c='India',City__c='Pune',State__c='Maharashtra',Permanent_Address__c='ABC Road',PancardNo__c='121136588');
            apps.add(app1);
        }
        insert apps ;
        return apps ;
    }
    
    public static Global_Charges__c creategobalCharges(String code)
    {
        Global_Charges__c gc1 = new Global_Charges__c(Name = 'Basic', Sequence_No__c = 1, Code__c = code);  
        insert gc1 ;
        return gc1 ;     
    }
    
    public static Customer_Pay_Plan_Header__c createCPPH2(Id qId,Global_Charges__c gc1)
    {
        Customer_Pay_Plan_Header__c pm1 = new Customer_Pay_Plan_Header__c(Quotation__c = qId,Global_Charges__c = gc1.Id);
        insert pm1;
        return pm1;  
    }
        
    public static Customer_Pay_Plan_Header__c createCPPH(Id BookingId,Global_Charges__c gc1)
    {
        Customer_Pay_Plan_Header__c pm1 = new Customer_Pay_Plan_Header__c(Booking__c = BookingId,Global_Charges__c = gc1.Id);
        insert pm1;
        return pm1;  
    }
     
     public static List <Standard_Customer_Pay_Plan_Detail__c>  createscppd(Customer_Pay_Plan_Header__c cpph,Integer numofscppd)
     {
         List<Standard_Customer_Pay_Plan_Detail__c> scpphList = new List<Standard_Customer_Pay_Plan_Detail__c>();
         for(Integer i=0;i<numofscppd;i++)
         {
             Standard_Customer_Pay_Plan_Detail__c stdPPH = new Standard_Customer_Pay_Plan_Detail__c();
             stdPPH.Customer_Pay_Plan_Header__c = cpph.Id;
             stdPPH.Is_to_be_Paid__c = 'From Dt. of Booking';
             stdPPH.Days_Months_Value__c = 0;
             stdPPH.Days_Months__c = 'Day(s)';
             stdPPH.Is_to_be__c='0Day(s) from date of booking.';
             stdPPH.Installment__c = 12000;
             stdPPH.Amount_Value__c = 100000;
             stdPPH.Due_Date__c = system.today();
             stdPPH.Service_Tax_Amount_Q__c = 10000;
             scpphList.add(stdPPH);
         }
         
             insert scpphList ;
             return scpphList ; 
     }
   */
  
  
  
  
   
}