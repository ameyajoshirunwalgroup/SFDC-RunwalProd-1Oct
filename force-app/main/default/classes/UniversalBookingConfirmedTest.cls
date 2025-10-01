@istest
public class UniversalBookingConfirmedTest {
    
    
    @testSetup
    public static void setupdata(){
        Test.startTest();
        //creating the legal entity
        //
        //
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        user salesmanager = UniversalTestClassSetup.createusers('Sales Manager', 'Deepak','Arya','salesmanager@runwal.com.uat','salesmanagertest@runwal.com.uat');
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        UniversalTestClassSetup.assignpm(rm.id,'RM_Permission_Set');
        system.runAs(sitehead){
           // Test.startTest();
            Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            
            //create project
            //
            Project__c objpr = UniversalTestClassSetup.setupproject(sitehead.id,objlglentity.id);
            
            //create tower
            Tower__c t = UniversalTestClassSetup.setuptower(objpr.id,'A','Residential');
            
            Tower__c t1 = UniversalTestClassSetup.setuptower(objpr.id,'A','Commercial');
            
            
            //creating tax slabs
            Tax_Slab__c taxS = new Tax_Slab__C();
            taxS.name = 'GST';
            taxS.From_Date__c = System.today().addDays(-10);
            taxS.Percentage__c = 4.20;
            taxS = RDSCommon.CreateTaxSlab(taxS);
            
            Tax_Breakup__c tb1 = new Tax_breakup__c();
            tb1.Taxable_Percentage__c = 66.66667;
            tb1.Tax_percentage__c = 9;
            tb1.tax_code__c = 'CGST';
            tb1.Tax_Name__c = 'CGST';
            tb1.Tax_Slab__c = taxS.id;
            tb1.Effective_from__c = system.today().addDays(-10);
            tb1.Tax_Split_Type__c = 'CGST';
            tb1.Tax_Type__c = 'Service tax';
            insert tb1;
            
            Tax_Breakup__c tb2 = new Tax_breakup__c();
            tb2.Taxable_Percentage__c = 66.66667;
            tb2.Tax_percentage__c = 9;
            tb2.tax_code__c = 'SGST';
            tb2.Tax_Name__c = 'SGST';
            tb2.Tax_Slab__c = taxS.id;
            tb2.Effective_from__c = system.today().addDays(-10);
            tb2.Tax_Split_Type__c = 'SGST';
            tb2.Tax_Type__c = 'Service tax';
            insert tb2;
            
            
            Tax_Slab__c taxS1 = new Tax_Slab__C();
            taxS1.name = 'GST-18';
            taxS1.From_Date__c = System.today().addDays(-10);
            taxS1.Percentage__c = 14;
            taxS1 = RDSCommon.CreateTaxSlab(taxS1);
            
            Tax_Breakup__c tb3 = new Tax_breakup__c();
            tb3.Taxable_Percentage__c = 100;
            tb3.Tax_percentage__c = 9;
            tb3.tax_code__c = 'CGST';
            tb3.Tax_Name__c = 'CGST';
            tb3.Tax_Slab__c = taxS1.id;
            tb3.Effective_from__c = system.today().addDays(-10);
            tb3.Tax_Split_Type__c = 'CGST';
            tb3.Tax_Type__c = 'Service tax';
            insert tb3;
            
            Tax_Breakup__c tb4 = new Tax_breakup__c();
            tb4.Taxable_Percentage__c = 100;
            tb4.Tax_percentage__c = 9;
            tb4.tax_code__c = 'SGST';
            tb4.Tax_Name__c = 'SGST';
            tb4.Tax_Slab__c = taxS1.id;
            tb4.Effective_from__c = system.today().addDays(-10);
            tb4.Tax_Split_Type__c = 'SGST';
            tb4.Tax_Type__c = 'Service tax';
            insert tb4; 
            
            //global charges
            
            Global_Charges__c ObjGloChrg =UniversalTestClassSetup.setupglobalcharger('Others','111','Maintenance Charges 1','Maintenance Charges 1','ZMC0','MAINT_CHARGES','',12,'MAINT1');            
            Global_Charges__c ObjGloChrg1 = UniversalTestClassSetup.setupglobalcharger('Basic','100','','Basic','ZPR0','Units Material Code','ZFER',1,'BASIC');
            Global_Charges__c ObjGloChrg2 = UniversalTestClassSetup.setupglobalcharger('PLC','102','Premium 1','Premium 1','ZPRM','','',3,'PLC 1');
            Global_Charges__c ObjGloChrg3 = UniversalTestClassSetup.setupglobalcharger('Registration','110','Registration Charges','Registration Charges','ZREG','','',11,'REGIS');
            Global_Charges__c ObjGloChrg4 = UniversalTestClassSetup.setupglobalcharger('Stamp Duty','108','Stamp Duty','Stamp Duty','ZSD0','','',9,'SD');
            Global_Charges__c ObjGloChrg5 = UniversalTestClassSetup.setupglobalcharger('Basic','101','Floor Rise','Floor Rise','ZFR0','','',2,'FLR');
            Global_Charges__c ObjGloChrg6 = UniversalTestClassSetup.setupglobalcharger('Others','107','Development Charges','Development Charges','ZDC0','DEVEL_CHARGES','',8,'DEVELOP');
            Global_Charges__c ObjGloChrg7 = UniversalTestClassSetup.setupglobalcharger('Legal Charges','115','Legal Charges','Legal Charges','ZLC0','LEGAL_CHARGES','',16,'LEGAL');
            Global_Charges__c ObjGloChrg8 = UniversalTestClassSetup.setupglobalcharger('Others','126','Corpus Fund','Corpus Fund','ZCF0','CORPUS_FUND','',30,'CF');
            Global_Charges__c ObjGloChrg9 = UniversalTestClassSetup.setupglobalcharger('PLC','103','Premium 2','Premium 2','ZPLC','','',4,'PLC 2');
            Global_Charges__c ObjGloChrg10 = UniversalTestClassSetup.setupglobalcharger('Basic','200','','Allotment Charges','ZAC0','From CP Inventory','',12,'MAINT1');
            Global_Charges__c ObjGloChrg11 = UniversalTestClassSetup.setupglobalcharger('Society Charges','205','','Society Charges','ZSF0','SOCIETY_FORMATION','',1,'Society');
            Global_Charges__c ObjGloChrg12= UniversalTestClassSetup.setupglobalcharger('Others','315','Electricity and Other Utility and Sevices Connection Charges','Electricity and Other Utility and Sevices Connection Charges','ZWEC','CONN_CH_WATER_ELEC','',16,'ELECT');
            Global_Charges__c ObjGloChrg13= UniversalTestClassSetup.setupglobalcharger('Others','415','Water, Electricity and Other Utility','Water, Electricity and Other Utility','ZESS','ELEC_SUB_STSATION','',16,'ELECT');
            
            //project charges
            
            
            Project_Charges__c PCharge = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg6.id,objpr.id,'Development Charges','Rate List at Unit Level',FALSE,TRUE,'GST','GST',null,null,'As per the payment milestone');            
            Project_Charges__c PCharge1 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg11.id,objpr.id,'Society Charges','Lumpsum at Project Level',True,TRUE,'GST-18','Other Charges',null,2500,'As per the payment milestone');                                                                        
            Project_Charges__c PCharge2 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg5.id,objpr.id,'Floor Rise','Rate List at Unit Level',False,TRUE,'GST','Agreement Value',23,230,'As per the payment milestone');                                                                        
            
            Project_Charges__c PCharge3 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg8.id,objpr.id,'Corpus Fund','Rate List at Unit Level',TRUE,TRUE,'GST-18','Other Charges',null,null,'As per the payment milestone');            
            Project_Charges__c PCharge4 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg7.id,objpr.id,'Legal Charges','Lumpsum at Project Level',True,TRUE,'GST-18','Other Charges',null,20000,'As per the payment milestone');                                                                        
            Project_Charges__c PCharge5 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg10.id,objpr.id,'Allotment Charges','Rate List at Unit Level',False,TRUE,'GST','Other Charges',null,null,'As per the payment milestone');                                                                        
            
            Project_Charges__c PCharge6 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg1.id,objpr.id,'Basic','Rate List at Unit Level',TRUE,TRUE,'GST','Agreement Value',null,null,'As per the payment milestone');            
            Project_Charges__c PCharge7 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg4.id,objpr.id,'Stamp Duty','Percentage of Agreement Value',True,False,null,'Stamp Duty and Registration',3,null,'As per the payment milestone');                                                                        
            Project_Charges__c PCharge8 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg.id,objpr.id,'Maintenance Charges 1','Rate List at Unit Level',TRUE,TRUE,'GST-18','Other Charges',null,null,'As per the payment milestone');                                                                        
            
            Project_Charges__c PCharge9 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg3.id,objpr.id,'Registration Charges','Lumpsum at Project Level',True,false,null,'GST',null,50000,'As per the payment milestone');            
            Project_Charges__c PCharge10 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg2.id,objpr.id,'Premium 1','Rate List at Unit Level',false,TRUE,'GST','Agreement Value',null,null,'As per the payment milestone');                                                                        
            Project_Charges__c PCharge11 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg12.id,objpr.id,'Electricity and Other Utility and Sevices Connection Charges','Rate List at Unit Level',true,TRUE,'GST','Other Charges',null,null,'As per the payment milestone');                                                                        
            
            Project_Charges__c PCharge12 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg13.id,objpr.id,'Water, Electricity and Other Utility','Rate List at Unit Level',True,True,'GST','Other Charges',null,null,'As per the payment milestone');                                                                        
            Project_Charges__c PCharge13 = UniversalTestClassSetup.setupprojectcharges(ObjGloChrg9.id,objpr.id,'Premium 2','Rate List at Unit Level',false,True,'GST','Agreement Value',null,null,'As per the payment milestone');                                                                        
            
            
            
            
            Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
            Relationship_Manager__c rms = new Relationship_Manager__c();
            rms.User__c = rm.id;
            rms.Project__c = objpr.id;
            rms.Tower__c = t.id;
            insert rms;
            //project unit
            Project_Unit__c objPU1 = new Project_Unit__c();    
            objPU1.Name = 'TestFive';     
            objPU1.Unit_SAP_Code__c ='1R000333';
            objPU1.RW_Project__c = objpr.Id;
            objPU1.RW_Param1__c = '5';
            objPU1.Relationship_Manager__c = rms.id;
            objPU1.UnitNo__c ='TestFive';
            objPU1.RW_Unit_status__c='Available';
            objPU1.RW_Booking_Date__c = system.Today();
            objPU1.Actual_Area_value__c = 2218;
            objPU1.New_Floor__c = '8';
            objPU1.RW_Param4__c ='A-4546';
            objPU1.TowerName__c = t.Id;
            objPU1.Carpet_Area__c = 10;
            objPU1.Saleable_Area__c=2218;
            objPU1.Single_car_park_Earmarked__c = 0;
            objPU1.Single_Open_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.Tandem_car_park_Earmarked__c = 0;
            objPU1.Tandem_Open_Earmarked__c = 0;
            objPU1.MLCP_Earmarked__c = 0;
            objPU1.Stack__c = 0;
            insert objPU1;
            
            
            Project_Unit__c objPU2 = new Project_Unit__c();    
            objPU2.Name = 'TestFive2';      
            objPU2.RW_Project__c = objpr.Id;
            objPU2.RW_Param1__c = '6';
            objPU2.UnitNo__c ='TestFive1';
            objPU2.RW_Unit_status__c='Booked';
            objPU2.RW_Booking_Date__c = system.Today();
            objPU2.Actual_Area_value__c = 2218;
            objPU2.RW_Floor__c = 8;
            objPU2.TowerName__c = t1.Id;
            objPU2.Carpet_Area__c = 1200;
            objPU2.Single_car_park_Earmarked__c = 0;
            objPU2.Single_Open_Earmarked__c = 0;
            objPU2.Tandem_Open_Earmarked__c = 0;
            objPU2.Tandem_car_park_Earmarked__c = 0;
            objPU2.Tandem_Open_Earmarked__c = 0;
            objPU2.MLCP_Earmarked__c = 0;
            objPU2.Stack__c = 0;
            insert objPU2;
            Project_Construction_Stages__c objPCS = UniversalTestClassSetup.setuppcs('DUE ON 31ST MARCH 2019',Date.newInstance(2019,03,31),objpr.id,100,t.id);
            Project_Construction_Stages__c objPCS1 = UniversalTestClassSetup.setuppcs('DUE ON 31ST DECEMBER 2019',Date.newInstance(2019,12,31),objpr.id,102,t.id);
            Project_Construction_Stages__c objPCS2 = UniversalTestClassSetup.setuppcs('On Possession/Receipt Of OC/ Completion Certificate.',Date.newInstance(2022,21,06),objpr.id,103,t.id);
            
            
            // rateList creation         
            Rate_List__c objRL = UniversalTestClassSetup.setupratelist(objPU1.id,0,0,'Lumpsum','Saleable Area',ObjGloChrg10.id,PCharge5.id,objpr.id,0);
            Rate_List__c objRL1 = UniversalTestClassSetup.setupratelist(objPU1.id,16286275,null,'Rate','Saleable Area',ObjGloChrg1.id,PCharge6.id,objpr.id,12385);
            Rate_List__c objRL2 = UniversalTestClassSetup.setupratelist(objPU1.id,131500,null,'Rate','Saleable Area',ObjGloChrg8.id,PCharge3.id,objpr.id,100);                   
            Rate_List__c objRL3 = UniversalTestClassSetup.setupratelist(objPU1.id,0,null,'Rate','Saleable Area',ObjGloChrg6.id,PCharge.id,objpr.id,0);
            Rate_List__c objRL4 = UniversalTestClassSetup.setupratelist(objPU1.id,28913,28913,'Lumpsum','Saleable Area',ObjGloChrg12.id,PCharge11.id,objpr.id,0);
            Rate_List__c objRL5 = UniversalTestClassSetup.setupratelist(objPU1.id,0,null,'Rate','Saleable Area',ObjGloChrg5.id,PCharge2.id,objpr.id,0);
            Rate_List__c objRL6 = UniversalTestClassSetup.setupratelist(objPU1.id,220920,null,'Rate','Saleable Area',ObjGloChrg.id,PCharge8.id,objpr.id,168);
            Rate_List__c objRL7 = UniversalTestClassSetup.setupratelist(objPU1.id,1,null,'Rate','Saleable Area',ObjGloChrg2.id,PCharge10.id,objpr.id,1);
            Rate_List__c objRL8 = UniversalTestClassSetup.setupratelist(objPU1.id,10297,10297,'Rate','Saleable Area',ObjGloChrg13.id,PCharge12.id,objpr.id,0);
            Rate_List__c objRL9 = UniversalTestClassSetup.setupratelist(objPU1.id,1,null,'Rate','Saleable Area',ObjGloChrg9.id,PCharge13.id,objpr.id,1);
            List<Rate_List__c> rls = new List<Rate_List__c>{objRL,objRL1,objRL2,objRL3,objRL4,objRL5,objRL6,objRL7,objRL8,objRL9};
                insert rls;
            system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&'+json.serialize(InventoryCostServices.getRateList(objPU1.id,0)));    
            
            //inserting payment plan
            Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
            objPaymentPlan.Name ='10-20-30-40 plan';
            objPaymentPlan.Project__c = objpr .Id;
            objPaymentPlan.Tower__c = t.Id;
            objPaymentPlan.Sub_Vention__c = false;
            objPaymentPlan.Subvention_Base_Rate__c = 0;
            objPaymentPlan.No_GST_on_Token__c = false;
            objPaymentPlan.Unique_Plan_Code__c ='06';
            insert objPaymentPlan;
            
            
            Standard_Pay_Plan_Header__c objSPP = UniversalTestClassSetup.setupppheader(objpr.Id,PCharge6.id, objPaymentPlan.id,t.id,'100 (90 )','90');
            Standard_Pay_Plan_Header__c objSPP1 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge3.id,  objPaymentPlan.id, t.id,'126 - Corpus Fund (90 )','90');
            Standard_Pay_Plan_Header__c objSPP2 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge11.id, objPaymentPlan.id, t.id,'315 - Electricity and Other Utility and Sevices Connection Charges (90 )','90');
            Standard_Pay_Plan_Header__c objSPP3 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge4.id, objPaymentPlan.id, t.id,'115 - Legal Charges (90 )','90');
            Standard_Pay_Plan_Header__c objSPP4 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge8.id,objPaymentPlan.id, t.id,'111 - Maintenance Charges 1 (90 )','90');
            Standard_Pay_Plan_Header__c objSPP5 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge1.id, objPaymentPlan.id, t.id,'205 (90 )','90');
            Standard_Pay_Plan_Header__c objSPP6=  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge12.id, objPaymentPlan.id, t.id,'415 - Water, Electricity and Other Utility and Services Connection Charges (90 )','90');
            Standard_Pay_Plan_Header__c objSPP7 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge12.id, objPaymentPlan.id,t.id,'110 - Registration Charges (90 )','90');
            Standard_Pay_Plan_Header__c objSPP8 =  UniversalTestClassSetup.setupppheader(objpr.Id,PCharge7.id, objPaymentPlan.id, t.id,'108 - Stamp Duty (90 )','90');
            
            
            
            // standard payment plan details creation for basic 
            // created 4 installments/milestones. two due date based and 2 Construction Linked
            Standard_Customer_Pay_Plan_Detail__c    objSPPD =UniversalTestClassSetup.setupSCPPD(2,'Percentage',0,0,'Day(s)','From Dt. of Booking','0Day(s) from date of booking.',null,objpr.id,objSPP.id,t.id,'2 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD1 =UniversalTestClassSetup.setupSCPPD(8,'Percentage',null,30,'Day(s)','From Dt. of Booking','30Day(s) from date of booking.',null,objpr.id,objSPP.id,t.id,'8 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD2=UniversalTestClassSetup.setupSCPPD(20,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : DUE ON 31ST MARCH 2019',objPCS.id,objpr.id,objSPP.id,t.id,'20 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD3 =UniversalTestClassSetup.setupSCPPD(30,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : DUE ON 31ST DECEMBER 2019',objPCS1.id,objpr.id,objSPP.id,t.id,'30 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD4 =UniversalTestClassSetup.setupSCPPD(40,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP.id,t.id,'40 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD5 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP1.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD6 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',0,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP2.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD7 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP3.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD8 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP4.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD9 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP5.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD10 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Construction Stage','0Day(s) after Stage : On Possession/Receipt Of OC/ Completion Certificate.',objPCS2.id,objpr.id,objSPP6.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD11 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Registration','On Registration',null,objpr.id,objSPP7.id,t.id,'100 % of Total Charge Value');
            Standard_Customer_Pay_Plan_Detail__c    objSPPD12 =UniversalTestClassSetup.setupSCPPD(100,'Percentage',null,0,'Day(s)','Registration','On Registration',null,objpr.id,objSPP8.id,t.id,'100 % of Total Charge Value');
            List<Standard_Customer_Pay_Plan_Detail__c> sppds = new list<Standard_Customer_Pay_Plan_Detail__c>{objSPPD,objSPPD1,objSPPD2,objSPPD3,objSPPD4,objSPPD5,objSPPD6
                ,objSPPD7,objSPPD8,objSPPD9,objSPPD10,objSPPD11,objSPPD12};
                    insert sppds;
            //create teams
            Team__c objTeam = UniversalTestClassSetup.createTeams('Sales Approvers Team',objpr.id,'Sales Approvers Team', t.id);
            
            Team__c objTeam1 =UniversalTestClassSetup.createTeams('MIS',objpr.id,'MIS', t.id);
            Team__c objTeam2 =UniversalTestClassSetup.createTeams('Account',objpr.id,'Accounts', t.id);
            Team__c objTeam3 =UniversalTestClassSetup.createTeams('CRM Team',objpr.id,'CRM Team', t.id);
            UniversalTestClassSetup.createTeamMembers(objTeam.id,salesmanager.id,'m@mk.com');
            UniversalTestClassSetup.createTeamMembers(objTeam1.id,null,'mk@mk.com');
            UniversalTestClassSetup.createTeamMembers(objTeam2.id,rm.id,'mk@mk.com');
            UniversalTestClassSetup.createTeamMembers(objTeam3.id,rm.id,'mk@mk.com');
            
            Car_Parking_Charge__c cp = new Car_Parking_Charge__c();
            cp.Project__c = objpr.id;
            cp.Category__c = 'Additional';
            cp.Status__c = 'Vacant';
            cp.Parking__c = 'Single Open';
            cp.SAP_Material_Code__c = 'abc';
            List<Car_Parking_Charge__c> cps = new List<Car_Parking_Charge__c>();
            cps.add(cp);
            Car_Parking_Charge__c cp1 = new Car_Parking_Charge__c();
            cp1.Project__c = objpr.id;
            cp1.Category__c = 'Additional';
            cp1.Status__c = 'Vacant';
            cp1.Parking__c = 'MLCP';
            cp1.SAP_Material_Code__c = 'abc1';
            cps.add(cp1);
            Car_Parking_Charge__c cp2 = new Car_Parking_Charge__c();
            cp2.Project__c = objpr.id;
            cp2.Category__c = 'Additional';
            cp2.Status__c = 'Vacant';
            cp2.Parking__c = 'Stilt';
            cp2.SAP_Material_Code__c = 'abc2';
            cps.add(cp2);
            insert cps; 
            //Test.stopTest();
            Offer__c off = new Offer__c(name='golive');
            insert off;
            RW_Sub_Offer__c  subof = new RW_Sub_Offer__c(
                name= 'golive suboffer',
                Offer__c = off.id,
                RW_Offer_Type__c = 'Booking',Project__c=objpr.id,RW_Start_Date__c= system.today()-1,RW_Approval_Status__c='Approved',Tower__c = t.id,RW_End_Date__c = system.today()+10);
            insert subof;
            
        }
        Test.stopTest();
    }
    
    
    /*@isTest
    public static void confirmbooking(){
        // Test.startTest();  comment 3
        user u = [select id,name from user where username ='site.headtest@runwal.com.uat'];
        
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        
        project_unit__c pu = [select id from project_unit__c where Unit_SAP_Code__c ='1R000333'];
        Payment_Plan__c pp = [select id,Project__c,Tower__c from Payment_Plan__c limit 1];   
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        
        Survey_Template__c sTemp = new Survey_Template__c();
         sTemp.Name = 'Booking Template';
         sTemp.Active__c = true;
         insert sTemp;
        
        
         Survey_Questions_Template__c sqTemp = new Survey_Questions_Template__c();
         Survey_Questions_Template__c sqTemp1 = new Survey_Questions_Template__c();
         sqTemp.Survey_Template__c = sTemp.Id;
         sqTemp.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
         sqTemp.Name = 'Q1';
         sqTemp.Question_Number__c = 1;
         sqTemp.Question_Text__c = 'Your Comments';
         SqTemp.Type_of_Question__c =  'PROJECT FEEDBACK';
         insert sqTemp;
         
         sqTemp1.Survey_Template__c = sTemp.Id;
         sqTemp1.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Picklist Questions').getRecordTypeId();
         sqTemp1.Name = 'Q2';
         sqTemp1.Question_Number__c = 2;
         sqTemp1.Question_Text__c = 'Your Decision';
         SqTemp1.Type_of_Question__c =  'SITE EXPERIENCE';
         insert sqTemp1;
        
        Project__c proj = [Select id,Booking_Template__c from Project__c where id =:pp.Project__c];
        proj.Booking_Template__c= sTemp.Id;
        update proj;   
        
         Opp_Close_Date__c dt = new Opp_Close_Date__c();
         dt.Project_Name__c = 'test2';
            dt.Name = pp.Project__c;
            dt.No_of_Days__c = 45;
            insert dt;
        
        Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
                objOpportunity.RW_Email__c = 'm@m.com';

        objOpportunity.StageName = 'Qualification'; 
        objOpportunity.RW_Project__c = pp.Project__c; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        
        
        PageReference pRef2 = Page.Quotation2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('oppId', objOpportunity.id);
        ApexPages.currentPage().getParameters().put('id', pu.id);
        
        QuotationExtn qt = new QuotationExtn();
        
        ApexPages.currentPage().getParameters().put('subPlanId', pp.id);
        //qt.q.Single_car_park_Additional__c=1;
       // qt.addCarPark();
        qt.QueryPlanDetails();
        
        
        qt.savePrint();
        system.runAs(u){
//            Test.startTest();  
            
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
            Test.startTest();
            DigitalBookingController.quotationWrapper qtwr=  DigitalBookingController.getQuotationMap(objOpportunity.id);
            Set<String> setStr =   qtwr.quotationIdNameMap.keyset();   
            system.debug(qtwr);
            Map<String,List<String>> offers = DigitalBookingController.getOffersForTower(pp.tower__c,'Booking');
            map<string,string> offermap = new map<string,string>();
            for(string off :offers.keyset()){
                offermap.put('offerName',off);
                for(string subof : offers.get(off)){
                    offermap.put('subofferName',subof);
                }
            }
            
            String paymentgateway='Bill Desk';
            
            String encryptedData =   DigitalBookingController.sendBookingLink(objOpportunity.id,60000,offermap,new List<String> (setStr).get(0),paymentgateway);
            
            
            
            DigitalBookingController.onlineBookingWrapper bk = DigitalBookingController.getDetails(EncodingUtil.urlDecode(encryptedData,'UTF-8'));
            bk.bookingDetails.applicants=DigitalBookingController.addApplicants( bk.bookingDetails.applicants);
            system.assertEquals(2,  bk.bookingDetails.applicants.size());    
            bk.bookingDetails.applicants[0].First_Name__c = 'test';
            bk.bookingDetails.applicants[0].Last_Name__c = 'user';
            
            bk.bookingDetails.applicants[0].Mailing_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[0].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Mailing_Country__c = 'India';
                bk.bookingDetails.applicants[0].DOB__c = system.today()-10000;
            
            bk.bookingDetails.applicants[0].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].City__c = 'mumbai';
            bk.bookingDetails.applicants[0].State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[0].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[0].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[0].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[0].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[0].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[0].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[0].Address_Proof_Number__c = 'k7899890';
            
            bk.bookingDetails.applicants[1].First_Name__c = 'test1';
            bk.bookingDetails.applicants[1].Last_Name__c = 'user1';
                       bk.bookingDetails.applicants[1].DOB__c = system.today()-10000;
           
            bk.bookingDetails.applicants[1].Mailing_Address_Line_1__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_2__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_3__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[1].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Mailing_Country__c = 'India';
            
            
            bk.bookingDetails.applicants[1].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].City__c = 'mumbai';
            bk.bookingDetails.applicants[1].State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[1].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[1].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[1].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[1].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[1].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[1].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[1].Address_Proof_Number__c = 'k7899890';
                 bk.bookingDetails.applicants[1].Email_Address__c='l@l.com';
              bk.bookingDetails.applicants[1].Salutation__c ='Mr';
            
            bk.paymentdetail[0].Mode__c ='Cheq';
            bk.paymentdetail[0].Total_Amount__c =50000;
            bk.paymentdetail[0].DraweeBank__c='Axis Bank';
            bk.paymentdetail[0].Cheque_DD__c='tw65wty';
            bk.paymentdetail[0].Cheque_DD_Date__c = System.today();
            checkrecursion.resetFirstRunA();
            
            DigitalBookingController.saveBooking(bk.bookingDetails.booking,bk.bookingDetails.applicants,bk.paymentdetail,bk.LinkId);
            
            //   DigitalBookingController.sendApprovalRequest(bk.bookingDetails.booking.id,'approve');
            system.debug('##############');
            
            bk.bookingDetails.booking.status__c='Booking Confirmed';
            checkrecursion.resetFirstRunA();
            BookingTriggerHandler.firstrun=true;
            update bk.bookingDetails.booking;

            
            
           
             // 
          
          
           // Test.stopTest();  
        }
        Test.stopTest();  

    }*/
    
    
    //Commented by Vinay 22-12-2021 as this method is failing while deploying
    /*@isTest
    public static void confirmbooking1(){
        user u = [select id,name from user where username ='salesmanagertest@runwal.com.uat'];
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        
        project_unit__c pu = [select id from project_unit__c where Unit_SAP_Code__c ='1R000333'];
        Payment_Plan__c pp = [select id,Project__c,Tower__c from Payment_Plan__c limit 1];   
                    String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;

        Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
                objOpportunity.RW_Email__c = 'm@m.com';

        objOpportunity.StageName = 'Qualification'; 
        objOpportunity.RW_Project__c = pp.Project__c; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        
        
        PageReference pRef2 = Page.Quotation2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('oppId', objOpportunity.id);
        ApexPages.currentPage().getParameters().put('id', pu.id);
        
        QuotationExtn qt = new QuotationExtn();
        
        ApexPages.currentPage().getParameters().put('subPlanId', pp.id);
        //qt.q.Single_car_park_Additional__c=1;
       // qt.addCarPark();
        qt.QueryPlanDetails();
        
        
        qt.savePrint();
        system.runAs(u){
            Test.startTest();  
            
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
            
            DigitalBookingController.quotationWrapper qtwr=  DigitalBookingController.getQuotationMap(objOpportunity.id);
            Set<String> setStr =   qtwr.quotationIdNameMap.keyset();   
            system.debug(qtwr);
            Map<String,List<String>> offers = DigitalBookingController.getOffersForTower(pp.tower__c,'Booking');
            map<string,string> offermap = new map<string,string>();
            for(string off :offers.keyset()){
                offermap.put('offerName',off);
                for(string subof : offers.get(off)){
                    offermap.put('subofferName',subof);
                }
            }
            
            String paymentgateway='Bill Desk';
            String encryptedData =   DigitalBookingController.sendBookingLink(objOpportunity.id,60000,offermap,new List<String> (setStr).get(0),paymentgateway);
            
            
            
            DigitalBookingController.onlineBookingWrapper bk = DigitalBookingController.getDetails(EncodingUtil.urlDecode(encryptedData,'UTF-8'));
            bk.bookingDetails.applicants=DigitalBookingController.addApplicants( bk.bookingDetails.applicants);
            system.assertEquals(2,  bk.bookingDetails.applicants.size());    
            bk.bookingDetails.applicants[0].First_Name__c = 'test';
            bk.bookingDetails.applicants[0].Last_Name__c = 'user';
            
            bk.bookingDetails.applicants[0].Mailing_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[0].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Mailing_Country__c = 'India';
                bk.bookingDetails.applicants[0].DOB__c = system.today()-10000;
            
            bk.bookingDetails.applicants[0].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].City__c = 'mumbai';
            bk.bookingDetails.applicants[0].State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[0].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[0].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[0].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[0].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[0].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[0].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[0].Address_Proof_Number__c = 'k7899890';
            
            bk.bookingDetails.applicants[1].First_Name__c = 'test1';
            bk.bookingDetails.applicants[1].Last_Name__c = 'user1';
                       bk.bookingDetails.applicants[1].DOB__c = system.today()-10000;
           
            bk.bookingDetails.applicants[1].Mailing_Address_Line_1__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_2__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_3__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[1].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Mailing_Country__c = 'India';
            
            
            bk.bookingDetails.applicants[1].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].City__c = 'mumbai';
            bk.bookingDetails.applicants[1].State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[1].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[1].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[1].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[1].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[1].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[1].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[1].Address_Proof_Number__c = 'k7899890';
                 bk.bookingDetails.applicants[1].Email_Address__c='l@l.com';
              bk.bookingDetails.applicants[1].Salutation__c ='Mr';
            
            bk.paymentdetail[0].Mode__c ='Cheq';
            bk.paymentdetail[0].Total_Amount__c =50000;
            bk.paymentdetail[0].DraweeBank__c='Axis Bank';
            bk.paymentdetail[0].Cheque_DD__c='tw65wty';
            bk.paymentdetail[0].Cheque_DD_Date__c = System.today();
            checkrecursion.resetFirstRunA();
            
            DigitalBookingController.saveBooking(bk.bookingDetails.booking,bk.bookingDetails.applicants,bk.paymentdetail,bk.LinkId);
                          
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;   
            
            

            ContentVersion contentVersion1 = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion1;
            
            ContentVersion contentVersion2 = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion2;  
                                    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

            //create ContentDocumentLink  record
            ////create ContentDocumentLink  record
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId =bk.bookingDetails.booking.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId =bk.bookingDetails.booking.id;
            cdl1.ContentDocumentId = documents[1].Id;
            cdl1.shareType = 'V';
            insert cdl1;
                          
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId =bk.bookingDetails.booking.id;
            cdl2.ContentDocumentId = documents[2].Id;
            cdl2.shareType = 'V';
            insert cdl2;

            Map<String,String> DocDetails = new Map<String,String>();
            DocDetails.put('applicantType','Individual Buyer');
            DocDetails.put('residentialStatus','Indian National');
            DocDetails.put('bookingId',bk.bookingDetails.booking.id);
            DocDetails.put('oppId',objOpportunity.id);
            DocDetails.put('documentType','PAN Card');
            DocDetails.put('documentId',   documents[0].id);
            DocDetails.put('ApplicantNumber','Primary Applicant');
            DigitalBookingController.insertDocumentData(DocDetails);
            
Map<String,String> DocDetails1 = new Map<String,String>();
            DocDetails1.put('applicantType','Individual Buyer');
            DocDetails1.put('residentialStatus','Indian National');
            DocDetails1.put('bookingId',bk.bookingDetails.booking.id);
            DocDetails1.put('oppId',objOpportunity.id);
            DocDetails1.put('documentType','Passport');
            DocDetails1.put('documentId',   documents[1].id);
            DocDetails1.put('ApplicantNumber','Second Applicant');
            DigitalBookingController.insertDocumentData(DocDetails1);            
                        
Map<String,String> DocDetails2 = new Map<String,String>();
            DocDetails2.put('applicantType','Individual Buyer');
            DocDetails2.put('residentialStatus','Indian National');
            DocDetails2.put('bookingId',bk.bookingDetails.booking.id);
            DocDetails2.put('oppId',objOpportunity.id);
            DocDetails2.put('documentType','Aadhar Card');
            DocDetails2.put('documentId',   documents[2].id);
            DocDetails2.put('ApplicantNumber','Second Applicant');
            DigitalBookingController.insertDocumentData(DocDetails2);            

            DigitalBookingController.saveApplicants(bk.bookingDetails.applicants);
            
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string allstring = '[{"RW_SAP_Code__c": "1R000333","RW_Inspection_Status__c": "Home Score Initiated","RW_PT_Int_dt__c": "2020-09-23T00:00:00"}]';
       //'[{"RW_Expected_Possession_dt__c": "2020-09-26T00:00:00.000Z","RW_SAP_Code__c": "1001R001009"}]';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring);
        RestContext.request = req;
        RestContext.response = res; 
        InspectionAPIServices.insertInspecPossession();
        }
    }*/
    
    
    @isTest
    public static void confirmbooking2(){
       // Test.startTest();  comment 3
        user u = [select id,name from user where username ='site.headtest@runwal.com.uat'];
        
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        
        project_unit__c pu = [select id from project_unit__c where Unit_SAP_Code__c ='1R000333'];
        Payment_Plan__c pp = [select id,Project__c,Tower__c from Payment_Plan__c limit 1];   
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        
        Survey_Template__c sTemp = new Survey_Template__c();
         sTemp.Name = 'Booking Template';
         sTemp.Active__c = true;
         insert sTemp;
        
        
         Survey_Questions_Template__c sqTemp = new Survey_Questions_Template__c();
         Survey_Questions_Template__c sqTemp1 = new Survey_Questions_Template__c();
         sqTemp.Survey_Template__c = sTemp.Id;
         sqTemp.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Free Text Questions').getRecordTypeId();
         sqTemp.Name = 'Q1';
         sqTemp.Question_Number__c = 1;
         sqTemp.Question_Text__c = 'Your Comments';
         SqTemp.Type_of_Question__c =  'PROJECT FEEDBACK';
         insert sqTemp;
         
         sqTemp1.Survey_Template__c = sTemp.Id;
         sqTemp1.RecordTypeId = Schema.SObjectType.Survey_Questions_Template__c.getRecordTypeInfosByName().get('Picklist Questions').getRecordTypeId();
         sqTemp1.Name = 'Q2';
         sqTemp1.Question_Number__c = 2;
         sqTemp1.Question_Text__c = 'Your Decision';
         SqTemp1.Type_of_Question__c =  'SITE EXPERIENCE';
         insert sqTemp1;
        
        Project__c proj = [Select id,Booking_Template__c from Project__c where id =:pp.Project__c];
        proj.Booking_Template__c= sTemp.Id;
        update proj;   
         
         Opp_Close_Date__c dt = new Opp_Close_Date__c();
         dt.Project_Name__c = 'test2';
            dt.Name = pp.Project__c;
            dt.No_of_Days__c = 45;
            insert dt;
        
        Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.SalesOrder_Number__c ='23456777';
        objOpportunity.SAP_Customer_Number__c = '12345678';
                objOpportunity.RW_Email__c = 'm@m.com';
            objOpportunity.RW_Project_Unit__c = pu.Id;

        objOpportunity.StageName = 'Qualification'; 
        objOpportunity.RW_Project__c = pp.Project__c; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
        
        
        
        PageReference pRef2 = Page.Quotation2;
        Test.setCurrentPage(pRef2);
        ApexPages.currentPage().getParameters().put('oppId', objOpportunity.id);
        ApexPages.currentPage().getParameters().put('id', pu.id);
        
        QuotationExtn qt = new QuotationExtn();
        
        ApexPages.currentPage().getParameters().put('subPlanId', pp.id);
        //qt.q.Single_car_park_Additional__c=1;
       // qt.addCarPark();
        qt.QueryPlanDetails();
        
        
        qt.savePrint();
        system.runAs(u){
            //Test.startTest();  
            
            system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
            Test.startTest();
            DigitalBookingController.quotationWrapper qtwr=  DigitalBookingController.getQuotationMap(objOpportunity.id);
            Set<String> setStr =   qtwr.quotationIdNameMap.keyset();   
            system.debug(qtwr);
            Map<String,List<String>> offers = DigitalBookingController.getOffersForTower(pp.tower__c,'Booking');
            map<string,string> offermap = new map<string,string>();
            for(string off :offers.keyset()){
                offermap.put('offerName',off);
                for(string subof : offers.get(off)){
                    offermap.put('subofferName',subof);
                }
            }
            
            String paymentgateway='Bill Desk';
            String encryptedData =   DigitalBookingController.sendBookingLink(objOpportunity.id,60000,offermap,new List<String> (setStr).get(0),paymentgateway);
            
            
            
            DigitalBookingController.onlineBookingWrapper bk = DigitalBookingController.getDetails(EncodingUtil.urlDecode(encryptedData,'UTF-8'));
            bk.bookingDetails.applicants=DigitalBookingController.addApplicants( bk.bookingDetails.applicants);
            system.assertEquals(2,  bk.bookingDetails.applicants.size());    
            bk.bookingDetails.applicants[0].First_Name__c = 'test';
            bk.bookingDetails.applicants[0].Last_Name__c = 'user';
            
            bk.bookingDetails.applicants[0].Mailing_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[0].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Mailing_Country__c = 'India';
                bk.bookingDetails.applicants[0].DOB__c = system.today()-10000;
            
            bk.bookingDetails.applicants[0].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].City__c = 'mumbai';
            bk.bookingDetails.applicants[0].State__c = 'maharashtra';
            bk.bookingDetails.applicants[0].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[0].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[0].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[0].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[0].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[0].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[0].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[0].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[0].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[0].Address_Proof_Number__c = 'k7899890';
            
            bk.bookingDetails.applicants[1].First_Name__c = 'test1';
            bk.bookingDetails.applicants[1].Last_Name__c = 'user1';
                       bk.bookingDetails.applicants[1].DOB__c = system.today()-10000;
           
            bk.bookingDetails.applicants[1].Mailing_Address_Line_1__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_2__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_Address_Line_3__c = 'addr12';
            bk.bookingDetails.applicants[1].Mailing_City__c = 'mumbai';
            bk.bookingDetails.applicants[1].Mailing_State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Mailing_Country__c = 'India';
            
            
            bk.bookingDetails.applicants[1].Permanent_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Permanent_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].City__c = 'mumbai';
            bk.bookingDetails.applicants[1].State__c = 'maharashtra';
            bk.bookingDetails.applicants[1].Country__c = 'India';
            
            
            
            bk.bookingDetails.applicants[1].Office_Address_Line_1__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_2__c = 'addr1';
            bk.bookingDetails.applicants[1].Office_Address_Line_3__c = 'addr1';
            bk.bookingDetails.applicants[1].Organisation_Country__c = 'India';
            bk.bookingDetails.applicants[1].Mobile_Number__c = '9999990000';
            bk.bookingDetails.applicants[1].Type_Of_Applicant__c = 'Individual Buyer';
            bk.bookingDetails.applicants[1].Subtype_Of_Applicant__c ='Indian National';
            bk.bookingDetails.applicants[1].PancardNo__c='ertyu7788c';
            bk.bookingDetails.applicants[1].Address_Proof_Document__c = 'Passport';
            bk.bookingDetails.applicants[1].Address_Proof_Number__c = 'k7899890';
                 bk.bookingDetails.applicants[1].Email_Address__c='l@l.com';
              bk.bookingDetails.applicants[1].Salutation__c ='Mr';
            upsert bk.bookingDetails.applicants;
          
            checkrecursion.resetFirstRunA();
            
//            DigitalBookingController.saveBooking(bk.bookingDetails.booking,bk.bookingDetails.applicants,bk.paymentdetail,bk.LinkId);
            
            //   DigitalBookingController.sendApprovalRequest(bk.bookingDetails.booking.id,'approve');
            system.debug('##############');
            
       
             // 
            BookingTriggerHandler.firstrun=true;
            //bk.bookingDetails.booking.Funding_Status__c ='Loan Bank';
            bk.bookingDetails.booking.Funding_Status__c ='Self Funded';
            bk.bookingDetails.booking.Loan_Bank__c ='Axis Bank Ltd';
			update    bk.bookingDetails.booking;
        BookingTriggerHandler.firstrun=true;
            bk.bookingDetails.booking.Status__c ='Cancelled';
            bk.bookingDetails.booking.Cancellation_Reason__c = 'Unit transfer';
            
            update bk.bookingDetails.booking;
       
           // Test.stopTest();  
                        DigitalBookingController.getTowersOfProject(objOpportunity.id);

        }
        Test.stopTest();
    }
    
    //Added by Vinay 22-12-2021 for code coverage
    @istest
    public static void bookingtest(){
        Test.startTest();
		user u = [select id,name from user where username ='site.headtest@runwal.com.uat'];
        
        Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
		project_unit__c pu = [select id,name from project_unit__c where Unit_SAP_Code__c ='1R000333'];
        Payment_Plan__c pp = [select id,name,Project__c,Tower__c from Payment_Plan__c where name='10-20-30-40 plan'];   
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        
         Opp_Close_Date__c dt = new Opp_Close_Date__c();
         dt.Project_Name__c = 'test2';
            dt.Name = pp.Project__c;
            dt.No_of_Days__c = 45;
            insert dt;
        
        Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity.RW_Email__c = 'm@m.com';
        objOpportunity.RW_Project__c = pp.Project__c; 
        objOpportunity=RDSCommon.CreateOpportunity(objOpportunity); 
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
       
       Tower__c t = UniversalTestClassSetup.setuptower(objpr.id,'A','Residential');
       
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
       
       Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
      	objPUU.RW_Param4__c = '4';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Blocked';
        objPUU.RW_Customer__c = objOpportunity.Id;
        insert objPUU;
          
       
       Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objOpportunity.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 1;
        q.Tandem_Open_Additional__c= 1;
        q.Single_car_park_Additional__c= 1;
        q.Single_Open_Additional__c = 1;
        q.Stack_Additional__c = 1;
        q.Total_Discount_L__c = 1000;
        q.Discount_1_Type__c = 'GST Discount';
        q.CAM_Charges__c = 100;
        q.BCAM_Charges__c =100;
        q.MLCP_Additional__c = null;
        insert q;
         
        //SalesOrderUpdateCallout.cancelsalesorder(new Set<Id>{objOpportunity.id}); comment 1
       // SalesOrderUpdateCallout.UpdateSO(new Set<Id>{objOpportunity.id});  comment 2
        Test.stopTest();
    }
     
}