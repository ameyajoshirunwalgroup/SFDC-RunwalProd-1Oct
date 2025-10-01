@isTest
public class BlockUnitControllerTest {
    
    @isTest
    static void testBlockUnitSaveDetailsSuccess() {
        Project__c project = new Project__c(
            Name = 'Test Project',
            Sales_Site_Head__c = UserInfo.getUserId(),
            Token_Amount__c = 50000,
            Allow_Blocking_on_Non_Active_Opportunity__c = true
        );
        insert project;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = project.Id;
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c();  
        unit.Project_Unit_Type__c = objPUT.id;  
        unit.Name = 'TestUnit';      
        unit.RW_Project__c = project.Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c ='9';
        unit.RW_Unit_Status__c ='Available';
        unit.Token_Amount__c = 10000;
        insert unit;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            RW_Project__c = project.Id
            //RW_Opportunity_Status__c = 'Active'
        );
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        Test.setCurrentPage(Page.BlockUnit); // Replace with your actual Visualforce page name
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        Test.startTest();
        BlockUnitController controller = new BlockUnitController();
        
        controller.agrementVal = 600000;
        //controller.pendingReason = new List<String>{'Pricing Approval'};
        controller.payMode1 = 'Cheque';
        controller.amount1 = 60000;
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Transaction XYZ';
        
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWhenNoPendingReason() {
        Project__c project = new Project__c(
            Name = 'Test Project',
            Sales_Site_Head__c = UserInfo.getUserId(),
            Token_Amount__c = 50000,
            Allow_Blocking_on_Non_Active_Opportunity__c = true
        );
        insert project;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = project.Id;
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c();  
        unit.Project_Unit_Type__c = objPUT.id;  
        unit.Name = 'TestUnit';      
        unit.RW_Project__c = project.Id;
        unit.RW_Param1__c = '5';
        unit.UnitNo__c ='9';
        unit.RW_Unit_Status__c ='Available';
        unit.Token_Amount__c = 10000;
        insert unit;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            RW_Project__c = project.Id
            //RW_Opportunity_Status__c = 'Active'
        );
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        
        controller.agrementVal = 600000;
        controller.payMode1 = 'Cheque';
        controller.amount1 = 50000;
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Test Details';
        
        Test.startTest();
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWhenPendingReasonIsOthersAndRemarksBlank() {
        Project__c project = new Project__c(
            Name = 'Test Project',
            Sales_Site_Head__c = UserInfo.getUserId(),
            Token_Amount__c = 50000,
            Allow_Blocking_on_Non_Active_Opportunity__c = true
        );
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(
            RDS_Code__c = '101',
            RDS_Project__c = project.Id
        );
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(
            Project_Unit_Type__c = objPUT.id,
            Name = 'TestUnit',
            RW_Project__c = project.Id,
            RW_Param1__c = '5',
            UnitNo__c = '9',
            RW_Unit_Status__c = 'Available',
            Token_Amount__c = 10000
        );
        insert unit;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            RW_Project__c = project.Id
        );
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.pendingReason = new List<String>{'Others'}; // No remarks provided
            controller.amount1 = 60000;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Transaction XYZ';
        
        Test.startTest();
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWithInvalidAadhar() {
        Project__c project = new Project__c(Name = 'Test Project', Sales_Site_Head__c = UserInfo.getUserId(), Token_Amount__c = 50000, Allow_Blocking_on_Non_Active_Opportunity__c = true);
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = project.Id);
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(Project_Unit_Type__c = objPUT.id, Name = 'TestUnit', RW_Project__c = project.Id, RW_Param1__c = '5', UnitNo__c = '9', RW_Unit_Status__c = 'Available', Token_Amount__c = 10000);
        insert unit;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(10), RW_Project__c = project.Id);
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.pendingReason = new List<String>{'Pricing Approval'};
            controller.amount1 = 60000;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Transaction XYZ';
        controller.aadharNumber = '123'; // Invalid aadhar number
        
        Test.startTest();
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWithInvalidPAN() {
        Project__c project = new Project__c(Name = 'Test Project', Sales_Site_Head__c = UserInfo.getUserId(), Token_Amount__c = 50000, Allow_Blocking_on_Non_Active_Opportunity__c = true);
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = project.Id);
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(Project_Unit_Type__c = objPUT.id, Name = 'TestUnit', RW_Project__c = project.Id, RW_Param1__c = '5', UnitNo__c = '9', RW_Unit_Status__c = 'Available', Token_Amount__c = 10000);
        insert unit;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(10), RW_Project__c = project.Id);
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.pendingReason = new List<String>{'Pricing Approval'};
            controller.amount1 = 60000;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Transaction XYZ';
        controller.panNumber = '1234'; // Invalid PAN
        
        Test.startTest();
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWithZeroAmount() {
        Project__c project = new Project__c(Name = 'Test Project', Sales_Site_Head__c = UserInfo.getUserId(), Token_Amount__c = 50000, Allow_Blocking_on_Non_Active_Opportunity__c = true);
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = project.Id);
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(Project_Unit_Type__c = objPUT.id, Name = 'TestUnit', RW_Project__c = project.Id, RW_Param1__c = '5', UnitNo__c = '9', RW_Unit_Status__c = 'Available', Token_Amount__c = 10000);
        insert unit;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(10), RW_Project__c = project.Id);
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.pendingReason = new List<String>{'Pricing Approval'};
            controller.amount1 = 0;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Transaction XYZ';
        
        Test.startTest();
        PageReference result = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testNoOpportunityUpdateWhenAlreadyBlocked() {
        Project__c project = new Project__c(Name = 'Test Project', Sales_Site_Head__c = UserInfo.getUserId(), Token_Amount__c = 50000, Allow_Blocking_on_Non_Active_Opportunity__c = true);
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = project.Id);
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(Project_Unit_Type__c = objPUT.id, Name = 'TestUnit', RW_Project__c = project.Id, RW_Param1__c = '5', UnitNo__c = '9', RW_Unit_Status__c = 'Available', Token_Amount__c = 10000);
        insert unit;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Unit Blocked', CloseDate = Date.today().addDays(10), RW_Project__c = project.Id);
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.dummyMethod();
        controller.pendingReason = new List<String>{'Pricing Approval'};
            controller.amount1 = 10000;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Test Details';
        
        Test.startTest();
        PageReference result = controller.saveAndRedirectToQuotePage();
        PageReference result1 = controller.saveDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testValidationFailsWhenBlockedDateNull() {
        Project__c project = new Project__c(Name = 'Test Project', Sales_Site_Head__c = UserInfo.getUserId(), Token_Amount__c = 50000, Allow_Blocking_on_Non_Active_Opportunity__c = true);
        insert project;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c(RDS_Code__c = '101', RDS_Project__c = project.Id);
        insert objPUT;
        
        Project_Unit__c unit = new Project_Unit__c(Project_Unit_Type__c = objPUT.id, Name = 'TestUnit', RW_Project__c = project.Id, RW_Param1__c = '5', UnitNo__c = '9', RW_Unit_Status__c = 'Available', Token_Amount__c = 10000);
        insert unit;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Site Visit', CloseDate = Date.today().addDays(10), RW_Project__c = project.Id);
        insert opp;
        
        CIF__C cifObj= new CIF__C(
        	Opportunity__c=opp.Id,
            Mode_of_funding__c='Bank Loan',
            Bank_Preference_1__c='Bharati Sahakari Bank',
            Bank_Preference_2__c='Bharati Sahakari Bank',
            Bank_Preference_3__c='Bharati Sahakari Bank'
        );
        insert CifObj;
        
        
        Test.setCurrentPage(Page.BlockUnit);
        ApexPages.currentPage().getParameters().put('unitId', unit.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        
        BlockUnitController controller = new BlockUnitController();
        controller.blockedDate = null; // Force null to test error
        controller.pendingReason = new List<String>{'Pricing Approval'};
            controller.amount1 = 10000;
        controller.payMode1 = 'Cheque';
        controller.payDate1 = Date.today();
        controller.payDetails1 = 'Test Details';
        
        Test.startTest();
         

       PageReference result1 = controller.saveDetails();
        Test.stopTest();
    }
    
}