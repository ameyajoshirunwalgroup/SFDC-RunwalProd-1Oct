@isTest
public class CarParkingTriggerHandlerTest {

    @isTest
    static void testRecalculateCounts() {

        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
        cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
        insert objpr;
        
        Opp_Close_Date__c cls = new Opp_Close_Date__c();
        cls.Project_Name__c = 'Test Proj';
        cls.Name = objpr.Id;
        cls.No_of_Days__c = 45;
        insert cls;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        

        // =========================
        // STEP 3: Create Parking Records
        // =========================
        List<Car_Parking_Charge__c> parkingList = new List<Car_Parking_Charge__c>();

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Single Covered'
        ));

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Tandem Covered'
        ));

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Single Covered'
        ));

        insert parkingList;

        // =========================
        // STEP 4: Call Handler
        // =========================
        Test.startTest();

        CarParkingTriggerHandler.recalculateCounts(
            parkingList,
            null,
            true,   // isUnitChange
            true    // isStatusChange
        );

        Test.stopTest();

        // =========================
        // STEP 5: Validate UNIT
        // =========================
        Project_Unit__c updatedUnit = [
            SELECT Single_car_park_Earmarked__c,
                   Tandem_car_park_Earmarked__c
            FROM Project_Unit__c
            WHERE Id = :objPUU.Id
        ];

       
    }
    @isTest
	static void testUpdateScenario() {

    	Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
        cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;
        insert cp;
        
        Account ac = new Account();                        
        ac.Name = cp.Company_Name_As_per_RERA__c;
        ac.CP_Email__c = cp.RW_Email__c;
        ac.Mobile_No__c = cp.RW_Mobile_No__c;
        ac.Channel_Partner__c = cp.id;
        Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
        ac.RecordTypeId = AccCPRecordTypeId;
        insert ac;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Project_Location__c = pl.id;
        insert objpr;
        
        Opp_Close_Date__c cls = new Opp_Close_Date__c();
        cls.Project_Name__c = 'Test Proj';
        cls.Name = objpr.Id;
        cls.No_of_Days__c = 45;
        insert cls;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        

        // =========================
        // STEP 3: Create Parking Records
        // =========================
        List<Car_Parking_Charge__c> parkingList = new List<Car_Parking_Charge__c>();

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Single Covered'
        ));

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Tandem Covered'
        ));

        parkingList.add(new Car_Parking_Charge__c(
            Project__c = objpr.Id,
            Project_Unit__c = objPUU.Id,
            Category__c = 'Earmarked',
            Status__c = 'Vacant',
            Parking__c = 'Single Covered'
        ));

        insert parkingList;
        // Fetch existing data created in your setup
        Car_Parking_Charge__c rec = [
            SELECT Id, Project__c, Project_Unit__c, Status__c, Parking__c
            FROM Car_Parking_Charge__c
            LIMIT 1
        ];
    
        // Get another unit
        Project_Unit__c newUnit = [
            SELECT Id FROM Project_Unit__c
            WHERE Id != :rec.Project_Unit__c
            LIMIT 1
        ];

        Test.startTest();
    
        // 🔥 Trigger BOTH conditions
        rec.Project_Unit__c = newUnit.Id;   // Unit change
        rec.Status__c = 'Booked';           // Status change
    
        update rec;
    
        Test.stopTest();
    
    }
    @isTest
    static void testDeleteScenario() {
    
        List<Car_Parking_Charge__c> records = [
            SELECT Id FROM Car_Parking_Charge__c LIMIT 2
        ];
    
        Test.startTest();
    
        delete records;
    
        Test.stopTest();
    }
    @isTest
    static void testUndeleteScenario() {

        List<Car_Parking_Charge__c> records = new List<Car_Parking_Charge__c>();
    
    	Project_Location__c pl = new Project_Location__c();
            pl.Name = 'Mumbai';
            pl.Approver_L1__c = userinfo.getUserId();
            pl.Approver_L2__c = userinfo.getUserId();
            pl.Location__c = 'Mumbai';
            insert pl;
            
            Broker__c cp = new Broker__c();
            cp.Name = 'Test CP';
            cp.RW_Email__c = 'teststetig43646@stetig.in';
            cp.Individual_CP__c = true;
            cp.RW_CreateFromIRIS__c = true;
            cp.RW_IRIS_Sync__c = true;
            cp.Place_of_Supply__c = 'Maharashtra';
            cp.Channel_Partner_From_CP_Portal__c = true;
            cp.Project__c = 'Runwal Bliss';
            cp.Approver_L1__c = userinfo.getUserId();
            cp.Approver_L2__c = userinfo.getUserId();
            cp.Registration_Complete__c = true;
            cp.RW_Mobile_No__c = '1234567890';
            cp.Broker_Type__c = 'Individual';
            cp.Broker_Pan_No__c = 'ADRPI3525F';
            cp.RW_Mobile_No__c = '1234567890';
            cp.NAME_FIRST__c = 'tets';
            cp.NAME_MIDDLE__c = 'cp';
            cp.NAME_LAST__c = 'test';
            cp.TITLE__c = 'Mr.';
            cp.Account_Number__c = '465446';
            cp.Cheque_DD_Favouring_Name__c = 'test cp';
            cp.IFSC_Code__c = 'BHSHVD';
            cp.Is_NRI_CP__c = false;
            cp.RW_Is_GST_Applicable__c = true;
            cp.Channel_Partner_From_CP_Portal__c =true;
            cp.Company_Name_As_per_RERA__c = cp.NAME_FIRST__c + ' ' + cp.NAME_MIDDLE__c + ' ' + cp.NAME_LAST__c;
            insert cp;
            
            Account ac = new Account();                        
            ac.Name = cp.Company_Name_As_per_RERA__c;
            ac.CP_Email__c = cp.RW_Email__c;
            ac.Mobile_No__c = cp.RW_Mobile_No__c;
            ac.Channel_Partner__c = cp.id;
            Id AccCPRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();                
            ac.RecordTypeId = AccCPRecordTypeId;
            insert ac;
            
            Project__c objpr = new Project__c();
            objpr.RW_Project_Code__c = 'T31';
            objpr.Name = 'Runwal Bliss';
            objpr.RDS_Short_Name__c = 'T';
            objpr.Start_Date__c = System.today().addDays(-5);
            objpr.RDS_Interest_Rate__c = 12;
            objpr.Project_Location__c = pl.id;
            insert objpr;
            
            Opp_Close_Date__c cls = new Opp_Close_Date__c();
            cls.Project_Name__c = 'Test Proj';
            cls.Name = objpr.Id;
            cls.No_of_Days__c = 45;
            insert cls;
            
            Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
            objPUT.RDS_Code__c = '101';
            objPUT.RDS_Project__c = objpr.id;
            insert objPUT;
            
            Project_Unit__c objPUU = new Project_Unit__c();  
            objPUU.Project_Unit_Type__c = objPUT.id;  
            objPUU.Name = 'TestUnit';      
            objPUU.RW_Project__c = objpr.Id;
            objPUU.RW_Param1__c = '5';
            objPUU.UnitNo__c ='9';
            objPUU.RW_Unit_Status__c ='Available';
            insert objPUU;
            
            Project_Unit__c objPUU1 = new Project_Unit__c();  
            objPUU1.Project_Unit_Type__c = objPUT.id;  
            objPUU1.Name = 'TestUnit1';      
            objPUU1.RW_Project__c = objpr.Id;
            objPUU1.RW_Param1__c = '5';
            objPUU1.UnitNo__c ='10';
            objPUU1.RW_Unit_Status__c ='Available';
            insert objPUU1;
    
            records.add(new Car_Parking_Charge__c(
                Project__c = objpr.Id,
                Project_Unit__c = objPUU.Id,
                Category__c = 'Earmarked',
                Status__c = 'Vacant',
                Parking__c = 'Single Covered'
            ));
    
        insert records;
    
        // Delete first
        delete records;
    
        Test.startTest();
    
        // 🔥 Undelete
        undelete records;
    
        Test.stopTest();
    }
}