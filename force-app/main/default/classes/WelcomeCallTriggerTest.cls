@isTest
public class WelcomeCallTriggerTest {
	
    @isTest
    public static void welcomeCallTriggerTest1(){
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        user salesmanager = UniversalTestClassSetup.createusers('Sales Manager', 'Deepak','Arya','salesmanager@runwal.com.uat','salesmanagertest@runwal.com.uat');
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        UniversalTestClassSetup.assignpm(rm.id,'RM_Permission_Set');
        
         UserRole obj1=new UserRole(Name= 'ABC'); 
			insert obj1;
        String recordTypeId1  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        sitehead.UserRoleId = obj1.Id;
        update sitehead;
        system.runAs(rm){
               Test.startTest();
               //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        a.OwnerId=sitehead.Id;
        a.RecordTypeId =recordTypeId1;
        insert a;
            
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
        
       Project__c objpr = UniversalTestClassSetup.setupproject(sitehead.id,objlglentity.id);
            
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
       Tower__c objTwr = new Tower__c();
        objTwr.SAP_Plant_Code__c = '100';
        objTwr.Name = 'Test Tower';
        objTwr.ProjectName__c = objpr.Id;
        insert objTwr;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Relationship_Manager__c rms = new Relationship_Manager__c();
        rms.User__c = rm.id;
        rms.Project__c = objpr.id;
        rms.Tower__c = objTwr.id;
        insert rms;           
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTwr.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = oppRec.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Relationship_Manager__c = rms.Id;
        objPUU.Carpet_Area__c= 789;
        insert objPUU;
       
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        //objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        objBking.Sales_Manager__c= salesmanager.Id;
        objBking.Status__c ='Booking Confirmed';
        insert objBking;
    
          RW_Welcome_Call__c wcObj = new RW_Welcome_Call__c();
         wcObj.RW_Booking__c = objBking.Id;
         wcObj.RW_Welcome_Call_Status__c = 'Due';
         //wcObj.Name = 'Test';
         wcObj.RW_Is_welcome_Letter_sent__c = True;
         wcObj.RW_Welcome_Call_Completed__c = false;
         wcObj.RW_Welcome_Call_Initiation_date__c = null;
         wcObj.RW_Welcome_Call_Accepted_date__c = system.today();
         wcObj.RW_Discrepancy_list_shared_via_email__c = True;
         wcObj.RM_email__c = 'test@123.com';
         insert wcObj;
            
         wcObj.RW_Reinitiate_Welcome_Call__c = true;
         update wcObj;
        
         RW_Welcome_Call__c wcObj1 = new RW_Welcome_Call__c();
         wcObj1.RW_Booking__c = objBking.Id;
         wcObj1.RW_Welcome_Call_Status__c = 'Due';
         //wcObj.Name = 'Test';
         wcObj1.RW_Is_welcome_Letter_sent__c = True;
         wcObj1.RW_Welcome_Call_Completed__c = false;
         wcObj1.RW_Welcome_Call_Initiation_date__c = null;
         wcObj1.RW_Welcome_Call_Accepted_date__c = system.today();
         wcObj1.RW_Discrepancy_list_shared_via_email__c = True;
         wcObj1.RM_email__c = 'test@123.com';
         insert wcObj1;
            
        wcObj1.RW_Welcome_Call_Status__c = 'Accept';
         update wcObj1;
        
        RW_Welcome_Call_Remarks__c welRema = new RW_Welcome_Call_Remarks__c();
        welRema.RW_Welcome_Call__c = wcObj.Id;
        welRema.RW_Remarks__c = 'ApplicantName1: Yes~Test7 Test9 Test8~ApplicantName1 % appnme,EmailAddresses1: Yes~shailesh.devare@stetig.in~EmailAddresses1 % email@email.com';
        insert welRema;
        
            
        
        
    }
	}
}