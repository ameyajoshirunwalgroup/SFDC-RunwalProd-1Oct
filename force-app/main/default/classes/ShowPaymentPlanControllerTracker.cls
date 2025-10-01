@istest
public class ShowPaymentPlanControllerTracker
{
      static testMethod void myUnitTest() 
     {
           Legal_Entity__c objlglentity = new Legal_Entity__c();
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
            
            /* Broker__c objBroK = new Broker__c();
             objBroK.Broker_Code__c = '12346';
             objBroK.Broker_Name__c = 'Brokname';
             objBroK.Status__c = 'Actives';
             objBroK=RDSCommon.CreateBroker(objBroK);
            */
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'TestProject';
            //objpr.Short_Name__c = 'Tp';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Stage__c='Launch';
            objpr=RDSCommon.CreateProject(objpr);
            
            Project_Unit_Type__c objProjectUnitType = new Project_Unit_Type__c();
            objProjectUnitType.name='ONE BHK';
            objProjectUnitType.RDS_Project__c =objpr.id;
            //objProjectUnitType.isServiceTaxApplicable__c =true;
             objProjectUnitType=RDSCommon.CreateProjectUnitType(objProjectUnitType);
              
             Unit_Number_Structure__c objUn = new Unit_Number_Structure__c();
             objUn.Name = 'testUN';
             objUn.Description__c = 'Desc';
             objUn.Sequence_No__c = 2;
            // objUn.Sorting_No__c = 2;
             objUn.Project__c = objpr.Id;
             objUn.Maximum_Length__c = 2;
             objUn.Delimiter__c = '/';
             objUn=RDSCommon.CreateUnitNumberStructure(objUn);
             
             
             Global_Charges__c ObjGloChrg = new Global_Charges__c();
             ObjGloChrg.Name = 'Basic';
             ObjGloChrg.Code__c = '011';
             ObjGloChrg.Description__c = 'SERVICE TAX';
             ObjGloChrg.Sequence_No__c = 99;
             ObjGloChrg.Charge_Type__c = 'Tax';
             ObjGloChrg.Nature_of_Charge__c = 'Debtors';
             ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);
             
             Project_Charges__c PCharge = new Project_Charges__c();
             PCharge.Charge_Code__c = ObjGloChrg.Id;
             PCharge.Project__c = objpr.Id;
             PCharge.Name = 'Basic';
             PCharge.Active__c = true;
             PCharge.Applied_This_Charge_To_FA__c = true;
             PCharge=RDSCommon.CreateProjectCharges(PCharge);
             
             
             Project_Unit__c objPU1 = new Project_Unit__c();    
             objPU1.Name = 'TestFive';      
             objPU1.RW_Project__c = objpr.Id;
             objPU1.Project_Unit_Type__c=objProjectUnitType.id;
             objPU1.RW_Param1__c = '5';
             objPU1.UnitNo__c ='TestFive';
             objPU1.RW_Unit_status__c='Booked';
             objPU1.RW_Booking_Date__c = System.Today();
             objPU1.Actual_Area_value__c = 200;
             //objPU1.Customer__c = objac.Id;
             objPU1=RDSCommon.CreateProjectUnit(objPU1);
              
              Account objac = new Account();
             objac.FirstName = 'saurabh';
             objac.LastName = 'Naudiyal';
             
             objac=RDSCommon.CreateAccount(objac);
            
            
             Project_Unit__c objPU = new Project_Unit__c();    
             objPU.Name = 'TestanotherFive';      
             objPU.RW_Project__c = objpr.Id;
             objPU.Project_Unit_Type__c=objProjectUnitType.id;
             objPU.RW_Param1__c = '5';
             //objPU.UnitNo__c ='TestanotherFive';
             objPU.RW_Unit_status__c='Booked';
             objPU.RW_Booking_date__c = System.Today();
             objPU.Actual_Area_value__c = 200;
             //objPU.Customers__c= objac.Id;
             objPU =RDSCommon.CreateProjectUnit(objPU);
             
             Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
            objPaymentPlan.Name ='Basic';
            objPaymentPlan.Project__c = objpr .Id;
            insert objPaymentPlan;
             
             Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
             objSPP.Project__c = objpr.Id;
             objSPP.Charge_Code__c= PCharge.Id;
             objSPP.Payment_Plan__c=objPaymentPlan.id;
             objSPP.Name='fdr';
             objSPP.Plan_Code__c= '89';
             objSPP.Effective_from__c = System.today();
             objSPP=RDSCommon.CreateStandardPayPlanHeader(objSPP);
              
             Opportunity objOpportunity = new Opportunity();
             objOpportunity.Name = 'Test';
             objOpportunity.CloseDate = System.today();
             objOpportunity.AccountId = objac.Id; 
             objOpportunity.Status__c = 'Active'; 
             objOpportunity.StageName = 'Qualification'; 
             objOpportunity.RW_Project__c = objpr.Id; 
             //objOpportunity.Project_Unit__c = objProjUnit.Id;
              objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
              
             Customer_Pay_Plan_Header__c objCustomerPayPlanHeader = new Customer_Pay_Plan_Header__c();
             objCustomerPayPlanHeader.Project_Unit__c = objPU1.Id ;
             objCustomerPayPlanHeader.PlanCode__c = '12';
             objCustomerPayPlanHeader.PlanDt__c = system.today();
             //objCustomerPayPlanHeader.Effect_From_Date__c =  system.today();
             objCustomerPayPlanHeader.Standard_Pay_Plan_Header__c =objSPP.Id;
             objCustomerPayPlanHeader.Effect_To_Date__c = null;
             objCustomerPayPlanHeader.Global_Charges__c=ObjGloChrg.id;
             objCustomerPayPlanHeader.Customer__c =objOpportunity.Id ;
             objCustomerPayPlanHeader.Amount__c = 1000;
             objCustomerPayPlanHeader=RDSCommon.CreateCustomerPayPlanHeader(objCustomerPayPlanHeader);
             
             
             Standard_Customer_Pay_Plan_Detail__c    objSPPD = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD.Standard_Pay_Plan_Header__c = objSPP.id;
            // objSPPD.Customer_Pay_Plan_Header__c = objCustomerPayPlanHeader.Id ;
             objSPPD.Project__c=objpr.id;
             objSPPD.Is_to_be_Paid__c='From Dt. of Booking';
             objSPPD.Days_Months__c='Day(s)';
             objSPPD.Days_Months_Value__c=5;
             objSPPD.Amount__c='Amount';
             objSPPD.Amount_Value__c=30;
             objSPPD.Installment__c = 100;
             objSPPD.Due_Date__c = System.today().Adddays(-1);
             objSPPD=RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD);
             
              Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
             objPCS.Project__c = objpr.Id;
             objPCS.Code__c ='Test';
             objPCS.Description__c='Testt';
             insert objPCS;
              Standard_Customer_Pay_Plan_Detail__c    objSPPD2 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD2.Standard_Pay_Plan_Header__c = objSPP.id;
            // objSPPD.Customer_Pay_Plan_Header__c = objCustomerPayPlanHeader.Id ;
             objSPPD2.Project__c=objpr.id;
             objSPPD2.Is_to_be_Paid__c='Construction Stage';
             objSPPD2.Days_Months__c='Day(s)';
             objSPPD2.Project_Construction_Stages__c=objPCS.id;
             objSPPD2.Days_Months_Value__c=5;
             objSPPD2.Amount__c='Amount';
             objSPPD2.Amount_Value__c=30;
             objSPPD2.Installment__c = 100;
             objSPPD2.Due_Date__c = System.today().Adddays(-1);
             objSPPD2=RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD2);
             
             Standard_Customer_Pay_Plan_Detail__c    objSPPD3 = new Standard_Customer_Pay_Plan_Detail__c();
             objSPPD3.Standard_Pay_Plan_Header__c = objSPP.id;
            // objSPPD.Customer_Pay_Plan_Header__c = objCustomerPayPlanHeader.Id ;
             objSPPD3.Project__c=objpr.id;
             objSPPD3.Is_to_be_Paid__c='From Dt. of Registration';
             objSPPD3.Days_Months__c='Day(s)';
             //objSPPD3.Project_Construction_Stages__c=objPCS.id;
             objSPPD3.Days_Months_Value__c=5;
             objSPPD3.Amount__c='Amount';
             objSPPD3.Amount_Value__c=30;
             objSPPD3.Installment__c = 100;
             objSPPD3.Registration_Linked__c = true;
             objSPPD3.Due_Date__c = System.today().Adddays(-1);
             objSPPD3=RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD3);
  
         
            ApexPages.currentPage().getParameters().put('id',objPaymentPlan.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(objPaymentPlan); 
            ShowPaymentPlanController objStandardCustomerPayPlanDetail  = new ShowPaymentPlanController(controller);
      
          
      }
}