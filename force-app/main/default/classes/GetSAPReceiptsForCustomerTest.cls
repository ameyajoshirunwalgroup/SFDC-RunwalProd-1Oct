@istest
public class GetSAPReceiptsForCustomerTest {
    
    @istest
    public static void test1(){
        
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        system.runas(sitehead){
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
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
            objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
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
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='123456789';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            RW_Demand__c dmd = new RW_Demand__c();
            dmd.Booking__c =bk.id;
            dmd.name= '12345678';
            dmd.RW_Billing_Document_Number__c = '12345678';
            dmd.RW_Customer_Number__c = '12345678';
            insert dmd;
            RW_Demand_Item__c dmid= new RW_Demand_Item__c();
            dmid.RW_Demand_Item_Amount__c =10000;
            dmid.RW_Demand__c = dmd.id;
            dmid.RW_GST_Amount__c = 1000;
            dmid.RW_Legacy_Amount_Paid__c = 5000;
            dmid.RW_Legacy_Demand__c = true;
            dmid.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid;
            
            RW_Demand__c dmd1 = new RW_Demand__c();
            dmd1.Booking__c =bk.id;
            dmd1.name= '12345679';
            dmd1.RW_Billing_Document_Number__c = '12345679';
            dmd1.RW_Customer_Number__c = '12345678';
            insert dmd1;
            RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
            dmid1.RW_Demand_Item_Amount__c =10000;
            dmid1.RW_Demand__c = dmd1.id;
            dmid1.RW_GST_Amount__c = 1000;
            dmid1.RW_Legacy_Amount_Paid__c = 5000;
            dmid1.RW_Legacy_Demand__c = true;
            dmid1.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid1;
            
            RW_Demand__c dmd2 = new RW_Demand__c();
            dmd2.Booking__c =bk.id;
            dmd2.name= '123456799';
            dmd2.RW_Billing_Document_Number__c = '123456799';
            dmd2.RW_Customer_Number__c = '12345678';
            insert dmd2;
            RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
            dmid2.RW_Demand_Item_Amount__c =10000;
            dmid2.RW_Demand__c = dmd2.id;
            dmid2.RW_GST_Amount__c = 1000;
            dmid2.RW_Legacy_Amount_Paid__c = 5000;
            dmid2.RW_Legacy_Demand__c = true;
            dmid2.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid2;
            
            /*RW_Payment_Details__c pd = new RW_Payment_Details__c();
            pd.RW_Document_Type__c = 'DZ';
            pd.RW_Booking__c =bk.id;
            pd.RW_Accounting_Document_Number__c = '0010000418';
            pd.RW_Instrument_Number__c= 'asd3232';
            pd.RW_Payment_Date__c = system.today();
            pd.RW_Company_Code__c = '1000';
            pd.RW_Fiscal_Year__c = '2020';           
            insert pd;
            
            RW_Payment_Detail_Item__c pdi= new RW_Payment_Detail_Item__c();
            pdi.RW_Amount__c = 1000;
            pdi.RW_Accounting_Document_Number__c= '0010000418';
            pdi.RW_Demand_Item__c = dmid2.id;
            pdi.RW_Payment_Details__c = pd.id;
            insert pdi;*/
            
            GetSAPReceiptsForCustomer.customerReceipts(bk.Id);
        } 
    }
    
    @istest
    public static void test2(){
        
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        system.runas(sitehead){
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
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
            objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
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
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='12345678';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            RW_Demand__c dmd = new RW_Demand__c();
            dmd.Booking__c =bk.id;
            dmd.name= '12345678';
            dmd.RW_Billing_Document_Number__c = '12345678';
            dmd.RW_Customer_Number__c = '12345678';
            insert dmd;
            RW_Demand_Item__c dmid= new RW_Demand_Item__c();
            dmid.RW_Demand_Item_Amount__c =10000;
            dmid.RW_Demand__c = dmd.id;
            dmid.RW_GST_Amount__c = 1000;
            dmid.RW_Legacy_Amount_Paid__c = 5000;
            dmid.RW_Legacy_Demand__c = true;
            dmid.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid;
            
            RW_Demand__c dmd1 = new RW_Demand__c();
            dmd1.Booking__c =bk.id;
            dmd1.name= '12345679';
            dmd1.RW_Billing_Document_Number__c = '12345679';
            dmd1.RW_Customer_Number__c = '12345678';
            insert dmd1;
            RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
            dmid1.RW_Demand_Item_Amount__c =10000;
            dmid1.RW_Demand__c = dmd1.id;
            dmid1.RW_GST_Amount__c = 1000;
            dmid1.RW_Legacy_Amount_Paid__c = 5000;
            dmid1.RW_Legacy_Demand__c = true;
            dmid1.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid1;
            
            RW_Demand__c dmd2 = new RW_Demand__c();
            dmd2.Booking__c =bk.id;
            dmd2.name= '123456799';
            dmd2.RW_Billing_Document_Number__c = '123456799';
            dmd2.RW_Customer_Number__c = '12345678';
            insert dmd2;
            RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
            dmid2.RW_Demand_Item_Amount__c =10000;
            dmid2.RW_Demand__c = dmd2.id;
            dmid2.RW_GST_Amount__c = 1000;
            dmid2.RW_Legacy_Amount_Paid__c = 5000;
            dmid2.RW_Legacy_Demand__c = true;
            dmid2.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid2;
                      
            GetSAPReceiptsForCustomer.customerReceipts(bk.Id);
        } 
        
        
    }
    
    @istest
    public static void test3(){
        
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        system.runas(sitehead){
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
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T35';
            objpr.Name = 'Runwal Bliss';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Company_Code__c = objlglentity.Id;
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Stage__c='Launch';
            objpr.RW_Address__c = '1403, Fantasy Land, Utopia, Planet Mars, OUTERWORLD CODE -11011';
            objpr.Project_Property_Type__c = 'Residential';
            objpr.S_Floor_Rise_Rate__c = 150;
            objpr.S_Applicable_From_Floor__c = 5;
            objpr.S_View1_PLC__c = 10;
            objpr.S_View2_PLC__c = 20;
            objpr.S_View3_PLC__c = 30;
            objpr.NPV__c = 12;
            objpr.S_Ready_Reckoner_Rate__c = 24000;
            objpr.Token_Amount__c = 200000;
            objpr.Service_Tax_Required_On_Token_Amount__c = true;
            objpr.Total_Max_Discount_Allowed__c = 100;
            objpr.Discount1_Type__c = 'General';
            //objpr.Discount1_Effective_Till__c = system.today().addDays(100);
            objpr.Discount1_Per_Sq_Ft__c = 100;
            objpr.Discount2_Type__c = 'Armed Forces';
            objpr.Discount2_Per_Sq_Ft__c = 150;
            objpr.Discount3_Type__c = 'Corporate';
            objpr.Discount3_Per_Sq_Ft__c = 200;
            objpr.Discount4_Type__c = 'Employee';
            objpr.Discount4_Per_Sq_Ft__c = 250;
            objpr.Discount5_Type__c = 'NRI';
            objpr.Discount5_Per_Sq_Ft__c = 300;
            objpr.Discount6_Type__c = 'Physically Challenged';
            objpr.Discount6_Per_Sq_Ft__c = 350;
            objpr.Discount8_Description__c = 'summer offer';
            objpr.Discount8_Type__c = 'Special Offer';
            objpr.Discount8_Per_Sq_Ft__c = 1000;
            objpr.Discount9_Description__c = 'DAM';
            objpr.Discount9_Type__c = 'DAM';
            objpr.Discount9_Per_Sq_Ft__c = 2000;
            //objpr.Discount2_Effective_Till__c = system.today().addDays(100);
            objpr.Discount2_Lumpsum__c = 100000;
            objpr.Allotment_Charges_1__c = 10000;
            objpr.Allotment_Charges_2__c = 10000;
            objpr.Allotment_Charges_3__c = 10000;
            objpr.Allotment_Charges_4__c = 10000;
            objpr.Allotment_Charges_5__c = 10000;
            objpr.Allotment_Charges_6__c = 10000;
            objpr=RDSCommon.CreateProject(objpr);
            
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
            objOpportunity.StageName = 'Unit Booked'; 
            objOpportunity.SAP_Customer_Number__c ='12345678';
            
            objOpportunity.RW_Project__c = objpr.id; 
            objOpportunity=RDSCommon.CreateOpportunity(objOpportunity);
            
            Booking__c bk = new booking__c();
            bk.Customer__c = objOpportunity.id;
            bk.Opportunity__c = objOpportunity.id;
            insert bk;
            objOpportunity.Booking__c = bk.Id;
            update objOpportunity;
            RW_Demand__c dmd = new RW_Demand__c();
            dmd.Booking__c =bk.id;
            dmd.name= '12345678';
            dmd.RW_Billing_Document_Number__c = '12345678';
            dmd.RW_Customer_Number__c = '12345678';
            insert dmd;
            RW_Demand_Item__c dmid= new RW_Demand_Item__c();
            dmid.RW_Demand_Item_Amount__c =10000;
            dmid.RW_Demand__c = dmd.id;
            dmid.RW_GST_Amount__c = 1000;
            dmid.RW_Legacy_Amount_Paid__c = 5000;
            dmid.RW_Legacy_Demand__c = true;
            dmid.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid;
            
            RW_Demand__c dmd1 = new RW_Demand__c();
            dmd1.Booking__c =bk.id;
            dmd1.name= '12345679';
            dmd1.RW_Billing_Document_Number__c = '12345679';
            dmd1.RW_Customer_Number__c = '12345678';
            insert dmd1;
            RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
            dmid1.RW_Demand_Item_Amount__c =10000;
            dmid1.RW_Demand__c = dmd1.id;
            dmid1.RW_GST_Amount__c = 1000;
            dmid1.RW_Legacy_Amount_Paid__c = 5000;
            dmid1.RW_Legacy_Demand__c = true;
            dmid1.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid1;
            
            RW_Demand__c dmd2 = new RW_Demand__c();
            dmd2.Booking__c =bk.id;
            dmd2.name= '123456799';
            dmd2.RW_Billing_Document_Number__c = '123456799';
            dmd2.RW_Customer_Number__c = '12345678';
            insert dmd2;
            RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
            dmid2.RW_Demand_Item_Amount__c =10000;
            dmid2.RW_Demand__c = dmd2.id;
            dmid2.RW_GST_Amount__c = 1000;
            dmid2.RW_Legacy_Amount_Paid__c = 5000;
            dmid2.RW_Legacy_Demand__c = true;
            dmid2.Total_Demand_Item_Amount_Paid__c = 5000;
            insert dmid2;
            
            RW_Payment_Details__c pd = new RW_Payment_Details__c();
            pd.RW_Document_Type__c = 'DZ';
            pd.RW_Booking__c =bk.id;
            pd.RW_Accounting_Document_Number__c = '0010000418';
            pd.RW_Instrument_Number__c= 'asd3232';
            pd.RW_Payment_Date__c = system.today();
            pd.RW_Company_Code__c = '1000';
            pd.RW_Fiscal_Year__c = '2020';           
            insert pd;
            
            RW_Payment_Detail_Item__c pdi= new RW_Payment_Detail_Item__c();
            pdi.RW_Amount__c = 1000;
            pdi.RW_Accounting_Document_Number__c= '0010000418';
            pdi.RW_Demand_Item__c = dmid2.id;
            pdi.RW_Payment_Details__c = pd.id;
            insert pdi;
            
            GetSAPReceiptsForCustomer.customerReceipts(bk.Id);
        }
    }
}