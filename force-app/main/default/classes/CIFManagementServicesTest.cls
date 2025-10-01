@isTest
public class CIFManagementServicesTest {
    @isTest
    static void testUpdateFeedbackOnCif() {
        Project__c p = TestDataFactory.createProject('Xanadu_prj2','111');   
        
        Lead l1 = new Lead();
        l1.LastName = 'sheetal';
        l1.Email ='ss@radiustest.com' ;
        l1.RW_Mobile_No__c = '820998955';
        l1.RW_Project__c=p.Id;
        insert l1;       
        // Create test data
        CIF__c cif1 = new CIF__c(Name = 'Test CIF 1');
        CIF__c cif2 = new CIF__c(Name = 'Test CIF 2');
        insert new List<CIF__c>{ cif1, cif2 };

        Task task1 = new Task(
            CI_Form__c = cif1.Id,
            Description = 'Feedback provided',
            Status = 'Not Started',Visit_Form_No__c='1233',whoId=l1.id
        );
        Task task2 = new Task(
            CI_Form__c = cif2.Id,
            Status = 'Not Started',Subject = 'New Enquiry Received From:Digital', Description = 'Tet--- phone_number-----'
        );
        insert new List<Task>{ task1, task2 };

        // Call the method
        CIFManagementServices.updateFeedbackOnCif(new List<Task>{ task1, task2 });

        // Verify the results
        cif1 = [SELECT Id, Is_SV_comments_Updated__c FROM CIF__c WHERE Id = :cif1.Id];
        cif2 = [SELECT Id, Is_SV_comments_Updated__c FROM CIF__c WHERE Id = :cif2.Id];

    }

    @isTest
    static void testCreatecase() {
         User u1 = TestDataFactory.createUserSysAdmin('One','Galvatron', 'galvatron456@radius.com', 'galvatron456@radius.com');
        Legal_Entity__c le=New Legal_Entity__c();
        le.Name='Testing';
        // le.SAP_ID__c='Test';
        //le.Project__c=objpr.id;
        insert le;
        Project__c objpr = new Project__c();
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.RDS_Company_Code__c=le.id;
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        //  objpr.Project_Email_id__c = 'test@stetig.in';
        insert objpr;
        Cluster__c clusterObj=new Cluster__c();
        clusterObj.Name='Test';
        insert clusterObj;
        
        Tower__c towerObj = new Tower__c();
        towerObj.Name ='Test Tower';
        towerObj.ProjectName__c = objpr.Id;
        towerObj.Zone_Name__c = clusterObj.Id;
        insert towerObj;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.Name = 'TestUnit';
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit1';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='10';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        
        Account a = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
        insert a;
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c =objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        //objcustomer.Tower__c = towerObj.id;
        objcustomer.RW_Project_Unit__c=objPUU.id;  
        objcustomer.CloseDate=system.today()+90;
        objcustomer.Status__c ='Active';
        //objcustomer.Booking__c=
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        insert objcustomer;
        
        Task task = new Task(
            OwnerId=u1.id,
            Status = 'Open',
            whatId=objcustomer.id,
            Voice_Log_URL__c = 'http://example.com/log'
        );
        insert task;
        task.Voice_Log_URL__c='http://example.com/log1';
        // Call the method
        CIFManagementServices.createcase(new List<Task>{ task });
        //CIFManagementServices.updateDuplicateTask(new List<Task>{ task });

       

      
    }
}