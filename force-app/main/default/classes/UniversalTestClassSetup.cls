public class UniversalTestClassSetup {
    
    public static project__c setupproject(id userid, id companycode){
        
        project__c pro = new project__c(
            Allotment_Charges_1__c = 700000,
            Allotment_Charges_2__c = 100000,
            CRMHead__c = userid,
            Customer_Care_Email__c='runwalcare@runwal.com',
            Discount3_Per_Sq_Ft__c=300,
            Discount3_Type__c='Corporate',
            Discount5_Per_Sq_Ft__c=300,
            Discount5_Type__c='NRI',
            Discount6_Per_Sq_Ft__c =100,
            Discount6_Type__c='Floor Rise',
            Discount7_Per_Sq_Ft__c=300,
            Discount7_Type__c='Referral',
            Discount8_Description__c='Other Discount',
            Discount8_Per_Sq_Ft__c=100,
            Discount8_Type__c='Special Offer',
            Discount_Link_Option__c=TRUE,
            Edit_Premium_Rate__c=TRUE,
            GST_Percenatge_Discount_Unit__c=2.5,
            GST_Percentage_Discount__c=2.5,
            Name='Runwal Bliss',
            Overall_CRM_Head__c=userid,
            Project_CRM_Lead__c =userid,
            Project_Property_Type__c='Residential',
            Quotation_Validity__c=10,
            RDS_Company_Code__c = companycode,
            Sales_Site_Head__c =userid,
            SAPMaterial_Code__c='1001' ,NPV__c    =0             
        );
        insert pro;
        return pro;
    }
    
    
    
    public static  tower__c setuptower(id projectid, string towername,String propertytype){
        Tower__c tow = new tower__C(
        Name = towername,
        Property_Type__c= propertytype,
            SAP_Plant_Code__c = '10001',
          ProjectName__c = projectid
  );
        insert tow;
        return tow;
    }
    
    public static Global_Charges__c setupglobalcharger(String Charge_Type,String Code,String Description ,String name,string SAP_condition_type,
                                                       string SAP_Material_Code,String SAP_Material_Type,integer Sequence_No,string Short_Name){
        
        Global_Charges__c gb = new Global_Charges__c(
            Charge_Type__c = Charge_Type,
            Code__c=Code,
          Description__c = Description,
            Name=name,
            SAP_condition_type__c=SAP_condition_type,
            SAP_Material_Code__c=SAP_Material_Code,
            SAP_Material_Type__c=SAP_Material_Type,
 Sequence_No__c=Sequence_No,
        Short_Name__c=Short_Name);
        insert gb;
        return gb;
    }
    public static Project_Charges__c setupprojectcharges(id Chargecode,id prid ,string Name,string S_Charge_Calculated_As,boolean Payment_Plan_Applicable,
                                                       boolean Service_Tax_Applicable_on_this_charge,string Service_Tax_Percentage 
                                               ,string S_Charge_Bucket  ,decimal S_Charge_Percentage,decimal S_Lumpsum_Charge_Amount  ,
                                                        string S_Payable_At){
        Project_Charges__c prc = new Project_Charges__c(
        Active__c=true,
            Charge_Code__c=Chargecode,
            External_Id__c=Name,
            Interest_Applicable_on_this_charge__c =true,
            Project__c = prid,
            Name=Name,
            Applied_This_Charge_To_FA__c=true,
            S_Charge_Calculated_As__c=S_Charge_Calculated_As,
            Payment_Plan_Applicable__c=Payment_Plan_Applicable,
            Remarks__c=Name,
            Service_Tax_Applicable_on_this_charge__c=Service_Tax_Applicable_on_this_charge,
            Service_Tax_Percentage__c=Service_Tax_Percentage,
            S_Charge_Bucket__c=S_Charge_Bucket,
            S_Charge_Percentage__c=S_Charge_Percentage,
            S_Lumpsum_Charge_Amount__c =S_Lumpsum_Charge_Amount,
            S_Payable_At__c=S_Payable_At


            
        );
        insert prc;
        return prc;
    }
    
    
    public static Rate_List__c setupratelist(id pui,decimal Amount,decimal ChargeCost,String Charge_Based_On_Master,string Charge_on_Area_Type,
                                            id Global_Charges,id Project_Charges,id Project,decimal Rate){
        Rate_List__c rl = new Rate_List__c(
        
        Project_Unit__c = pui,
            Amount__c=Amount,
            ChargeCost__c=ChargeCost,
        Charge_Based_On_Master__c=Charge_Based_On_Master,
            Charge_on_Area_Type__c=Charge_on_Area_Type,
            Global_Charges__c=Global_Charges,
            Project_Charges__c=Project_Charges,
            Project__c=Project,
            Rate__c=Rate              
        );
    //    insert rl;
        return rl;
        
    }
    
    public static Project_Unit__c setupprojectunit(){
        Project_Unit__c prj = new Project_Unit__c(
        );
        insert prj;
        return prj;
    }
    public static Standard_Pay_Plan_Header__c setupppheader(id pid,id projectcharge, id pp,id tid,string name,string Plan_Code){
        Standard_Pay_Plan_Header__c spph = new Standard_Pay_Plan_Header__c(
        Project__c =pid,
        Charge_Code__c = projectcharge,
            Payment_Plan__c =pp,
            tower__c =tid,
            Effective_from__c = System.today(),name=name,Plan_Code__c = Plan_Code

        );
        insert spph;
        return spph;
    }
    
    public static  Standard_Customer_Pay_Plan_Detail__c setupSCPPD(Decimal Amount_Value,String Amount,Decimal Calculate_Installment_Amount_as,integer Days_Months_Value,
                                                                  String Days_Months, string Is_to_be_Paid,string Is_to_be,id Project_Construction_Stages,
                                                                  id Project,id Standard_Pay_Plan_Header,id Tower,String Value){
        Standard_Customer_Pay_Plan_Detail__c SCPPD=  new Standard_Customer_Pay_Plan_Detail__c(
           Amount_Value__c=Amount_Value,
            Amount__c=Amount,
            Calculate_Installment_Amount_as__c=Calculate_Installment_Amount_as,
            Days_Months_Value__c=Days_Months_Value,
            Days_Months__c=Days_Months,Is_to_be_Paid__c=Is_to_be_Paid,Is_to_be__c=Is_to_be,
            Project_Construction_Stages__c=Project_Construction_Stages,Project__c=Project,
            Standard_Pay_Plan_Header__c=Standard_Pay_Plan_Header,Tower__c=Tower,Value__c=Value
        );
        
       // insert SCPPD;
        return SCPPD;
    }
    public static Project_Construction_Stages__c setuppcs(string Name,date Planned_date_of_completion,id pid,integer Sequence_No,id Tower){
        Project_Construction_Stages__c pcs = new Project_Construction_Stages__c(
        Name=Name,Planned_date_of_completion__c=Planned_date_of_completion,Project__c=pid,Sequence_No__c=Sequence_No,Tower__c=Tower,Unique_Sequence_No__c=pid+'-'+Sequence_No);
        insert pcs;
        return pcs; 	
    }
    
      public static user createusers(string usertype,string fn, string ln,string email, string username){
        
        Profile p = [Select Id, Name from Profile where Name =:usertype];
        //   UserRole r = new UserRole(DeveloperName = role, Name = role);
        //insert r;
        User u = new User(firstName = fn, lastName = ln, email=email,Username= username, ProfileId = p.Id, alias= ln.substring(0,4),EmailEncodingKey='UTF-8', 
                          LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9876543210');
        insert u;
        return u;
        
    }
    
    public static void assignpm(id uid, string pmname){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: pmname ];
        insert new PermissionSetAssignment(AssigneeId = uid, PermissionSetId = ps.Id);
    }
    public static Team__c createTeams(String Name,id pid,string Team_Type,id tid){
        Team__c tm = new Team__c(
        name=name,
            Project__c =pid,
            Team_Type__c=Team_Type,
            Towerlookup__c=tid
        );
        insert tm;
        return tm;
        
    }
    
    public static void createTeamMembers(id teamid,id userid,string email){
        Team_Members__c tm = new Team_Members__c(Email_Id__c =email,User_Active__c = true,Team__c=teamid,User__c=userid);
        insert tm;
    }
}