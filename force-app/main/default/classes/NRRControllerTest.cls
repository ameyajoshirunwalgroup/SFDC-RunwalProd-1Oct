@isTest
public class NRRControllerTest {
    
    @isTest
    public static void nrrTest1(){
        Opportunity oppRec= new Opportunity();
        oppRec.name='Test 1';
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.RW_Type_of_Client__c = 'Local';
        oppRec.RW_Mobile_No__c = '9874563210';
        oppRec.RW_Email__c = 'test@mail.com';
        insert oppRec;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.GST_Percentage_Discount__c = 2;
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.TowerName__c = objTower.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.Deck_Area__c = 687;
        objPUU.Utility_Area__c = 500;
        objPUU.RW_Param4__c = 'A-5504'; 
        insert objPUU;
        
        Project_Charges__c pc = new Project_Charges__c();
        pc.S_Lumpsum_Charge_Amount__c = 1000;
        pc.Name = 'Development Charges';
        pc.Project__c = objpr.Id;
        insert pc;
        
        NRR__c nrr = new NRR__c();
        nrr.Project_Unit__c = objPUU.Id;
        nrr.Saleable_Area__c = 1234;
        nrr.Base_Price__c = 14000;
        nrr.SD_Impact_Applicable__c = 'Yes';
        nrr.AV_After_2_GST_discount__c = 10000;
        nrr.CP_Pay_out_Referral_payout__c = 1000;
        nrr.Interest_Cost_NPV_Subvention_Deffered__c = 1000;
        nrr.GST_ITC_Benefit__c = 1;
        insert nrr;
        
        Brokerage_Scheme__c bs = new Brokerage_Scheme__c();
        bs.Start_Date__c = Date.today() - 1;
        bs.End_Date__c = Date.today() + 5;
        bs.Approval_Status__c = 'Approved by Level 2';
        bs.Type__c = 'Local';
        insert bs;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Project__c = objpr.Id;
        sc.Tower__c = objTower.Id;
        sc.Brokerage_Scheme__c = bs.Id;
        insert sc;
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', objPUU.id);
        NRRController nr = new NRRController();
        nr.oppId = oppRec.Id;
        NRRController.nrrCheck(objPUU.id, oppRec.Id);
        test.stopTest();
        
    }
    
     @isTest
    public static void nrrTest2(){
        Opportunity oppRec= new Opportunity();
        oppRec.name='Test 1';
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.RW_Mobile_No__c = '9874563210';
        oppRec.RW_Email__c = 'test@mail.com';
        insert oppRec;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.GST_Percentage_Discount__c = 2;
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.TowerName__c = objTower.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.Deck_Area__c = 687;
        objPUU.Utility_Area__c = 500;
        objPUU.RW_Param4__c = 'A-5504'; 
        insert objPUU;
        Project_Charges__c pc = new Project_Charges__c();
        pc.S_Lumpsum_Charge_Amount__c = 1000;
        pc.Name = 'Development Charges';
        pc.Project__c = objpr.Id;
        insert pc;
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('id', objPUU.id);
        //NRRController nr = new NRRController();
        //nr.oppId = oppRec.Id;
        NRRController.nrrCheck(objPUU.id, oppRec.Id);  
        test.stopTest();
        
    }

}