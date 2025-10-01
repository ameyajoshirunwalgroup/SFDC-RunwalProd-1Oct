@isTest
public class IOMControllerTest {
    
    @isTest
    public static void IOMTest(){
        
        Project__c Pro = new Project__c();
         pro.Name = 'Runwal Test 1';
         pro.RW_Project_Code__c = '180';
         insert pro;
         
         Account acc = new Account();
         acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
         acc.FirstName = 'Chetan';
         acc.LastName = 'Bhuimbar';
         acc.Mobile_No__c = '9879879870';
         acc.PersonEmail = 'sarj@gmail.com';
         insert acc;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test 123';
         opp.AccountId = acc.Id;
         opp.RW_Project__c = pro.Id;
         opp.StageName = 'Qualification';
         opp.CloseDate = system.today();
         opp.RW_Rating__c = 'Hot';
         opp.Remark__c = 'Test 123';
         opp.LeadSource = 'Digital';
         insert opp;
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = pro.id;
        insert objPUT;
         
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = pro.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Customer__c = opp.Id;
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Carpet_Area__c = 786;
        objPUU.RW_Unit_Status__c = 'Booked';
        objPUU.RW_Booking_Date__c = Date.today();
        insert objPUU;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = opp.Id;
        objBking.Project__c = pro.Id;
        objBking.Opportunity__c = opp.Id;
        objBking.Customer__c =opp.Id;
        objBking.Unit_No__c = objPUU.id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Status__c ='Booking Confirmed';
        objBking.RW_Total_Interest_Amount_Waived__c=6736;
        objBking.RW_Total_Collectable_Interest__c=6757;
        objBking.RW_Total_Amount_Collected__c=75757;
        objBking.RW_Total_Amount_Balance__c=75757;
        objBking.RW_Total_TDS_Due__c=56565;
        objBking.Floor__c=3;
        objBking.RW_Agreement_Status__c='Approved';
        objBking.RW_Signed_Agreement_Document_Id__c ='00690000454';
        objBking.Token_Amount__c=2000;
        objBking.Allotment_Premium__c=3000;
        objBking.Source_of_Booking__c='Direct';
        objBking.Carpet_Area__c=23;
        objBking.RW_Registration_Date__c=System.today();
        insert objBking;
        
        
        IOM__c iom = new IOM__c();
        iom.Name = 'Test IOM';
        iom.Comments__c = 'Test Comments';
        insert iom;
        
        IOM_Item__c item = new IOM_Item__c();
        item.IOM__c = iom.Id;
        item.Unit__c = objPUU.Id;
        item.Refund_Amount1__c = 10000;
        insert item;
        
        pageReference pageRef = page.IOMPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',iom.Id);
        IOMController iomCtrl = new IOMController();
        
    }

}