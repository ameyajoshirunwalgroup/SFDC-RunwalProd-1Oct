@isTest
public class SendPaymentReminderReporttoRMTest {
    /*@isTest  
static void TaskTest() {
Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
list<Tower__c> t = TestDataFactory.createTowers(1,p.Id);
Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
// List<Opportunity>  oList = New List<Opportunity>();
List<Lead> llist = TestDataFactory.createLead(3);
// List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
Profile pr = [Select Id,Name from Profile where Name = 'NRI Sales Manager'];

Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
List<User> lstUser = new List<User>();
User u1 = new User(LastName = 'Test',
FirstName='Test1 User',
Alias = 'tstU1',
Email = 'testUsr1@stetig.in',
Username = 'testUsr1@stetig.in',
ProfileId = profileId.id,
CTI_Agent_ID__c = 'test.test1',
TimeZoneSidKey = 'America/Los_Angeles',
EmailEncodingKey = 'UTF-8',
LanguageLocaleKey = 'en_US',
LocaleSidKey = 'en_US');
insert u1;

User u = new User();
u.Username = 'test123@stetig.in';
u.LastName = 'Test';
u.ManagerId = u1.Id;
u.Email = 'test@stetig.in';
u.Alias = 'Test';
u.IsActive =true;
u.EmailEncodingKey='UTF-8';
u.LocaleSidKey='en_US';
u.TimeZoneSidKey='America/Los_Angeles';
u.LanguageLocaleKey='en_US';
if(pr.Id != null){
u.ProfileId = pr.Id;
}
insert u;
Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
objPUT.RDS_Code__c = '101';
objPUT.RDS_Project__c = p.id;
insert objPUT;

Relationship_Manager__c ObjRm = new Relationship_Manager__c();
ObjRm.Tower__c = t[0].Id;
ObjRm.Project__c = p.Id;
// ObjRm.User__c = u.Id;
ObjRm.User__c = UserInfo.getUserId();
ObjRm.Contact_Number__c='9987654323';
insert ObjRm;



Project_Location__c pl = new Project_Location__c();
pl.Name = 'Mumbai';
pl.Approver_L1__c = userinfo.getUserId();
pl.Approver_L2__c = userinfo.getUserId();
pl.Location__c = 'Mumbai';
insert pl;

Project__c objpr = new Project__c();
objpr.RW_Project_Code__c = 'T31';
objpr.Name = 'Runwal Bliss';
objpr.RDS_Short_Name__c = 'T';
objpr.Start_Date__c = System.today().addDays(-5);
objpr.RDS_Interest_Rate__c = 12;
objpr.Project_Location__c = pl.id;
insert objpr;
Project_Unit__c objPUU = new Project_Unit__c();  
objPUU.Project_Unit_Type__c = objPUT.id;  
objPUU.Name = 'TestUnit';      
objPUU.RW_Project__c = p.Id;
objPUU.RW_Param1__c = '5';
objPUU.UnitNo__c ='9';
objPUU.RW_Seventh_Day__c=false;
objPUU.RW_Unit_Status__c ='Booked';
objPUU.RW_Booking_Date__c = system.today();
insert objPUU;
Project_Unit_Type__c objPUT1 = new Project_Unit_Type__c();
objPUT1.RDS_Code__c = '101';
objPUT1.RDS_Project__c = objpr.id;
insert objPUT1;

Project_Unit__c objPUU1 = new Project_Unit__c();  
objPUU1.Project_Unit_Type__c = objPUT1.id;  
objPUU1.Name = 'TestUnit1';      
objPUU1.RW_Project__c = objpr.Id;
objPUU1.RW_Param1__c = '5';
objPUU1.UnitNo__c ='10';
objPUU1.RW_Seventh_Day__c=false;
objPUU1.RW_Unit_Status__c ='Booked';
objPUU1.RW_Booking_Date__c = system.today();
insert objPUU1;

Opportunity o = new Opportunity(Name = 'Opp-1',RW_Project_Unit__c = objPUU.Id, RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Unit Booked', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = p.Id,closeDate=System.today(),Call_Rating__c = 0);
insert o;
list<Opportunity> oList = new list<Opportunity>{o};
system.debug(oList[0].Name);                
System.debug('Oplist Size :: ' +oList.size());

Task task = new Task(
Subject = 'Visit Follow Up - Auto',
Status = 'Not Started',
Priority = 'Normal',
ActivityDate = Date.today().addDays(-5)
);
insert task;

Project__c p1 = new Project__c();
p1.Id = p.Id;
p1.CRM_MIS_Head__c = userinfo.getUserId();
p1.CRMHead__c = userinfo.getUserId();
p1.Home_Loan_Email__c = UserInfo.getUserEmail();
update p1;




Quotation__c q = new Quotation__c();
q.Name = 'Q010101';
q.Quote_Status__c = 'Valid';
q.Prepared_Date__c = System.today();
q.Project__c = p.Id;
q.Project_Unit__c = objPUU.Id;
q.FloorNo__c = 11;
q.Opportunity__c = o.Id;
q.Appartment_Configuration__c = '1 BHK';
q.Carpet_Area_Sq_Ft__c = 1200;
q.Token_Amount__c =110000;
q.ST_Token_Amount__c = 1000;
q.Allow_booking_without_full_token__c = TRUE;
q.Agreement_Value__c = 60422880;
q.Agreement_Value_ST__c = 2537761;
q.Tandem_car_park_Additional__c = 0;
q.Tandem_Open_Additional__c= 0;
q.Single_car_park_Additional__c= 0;
q.Single_Open_Additional__c = 0;
q.Stack_Additional__c = 0;
q.MLCP_Additional__c = null;
q.Agreement_Value_for_brokers__c = 10000000;
insert q;   

Booking__c b = new Booking__c();
b.Customer__c = o.Id;
b.Project__c = p.Id;
b.Opportunity__c = o.Id;
b.Unit_No__c = objPUU.id;
b.Quotation__c = q.Id;
b.Booking_Date__c = Date.today();
b.Account__c = acc.Id;
b.Type_of_Client__c = 'Local';
b.Status__c = 'Booking Confirmed';
b.RW_Registration_Done__c = 'No';
b.Exclude_From_Brokerage_Batch__c = false;
b.Source_of_Booking__c = 'Direct';
b.CreatedDate = System.today();
//b.X5_Received__c = true;
b.RW_Total_Receipt_Amount_Received__c = 600000;
b.Allotment_Premium__c = 10000000;
b.RW_Registration_Status__c = 'Registration Completed';
b.RW_Registration_Type__c = 'Offline Registration';
b.RW_Expected_Registration_Date__c = system.today();
b.RW_Registration_Done__c = 'No';
b.RW_Registration_Date__c = null;
b.RW_BRL_Number__c = null;
insert b;

objPUU.Booking__c = b.Id;
update objPUU;
RW_Demand__c dmd2 = new RW_Demand__c();
dmd2.Booking__c =b.id;
dmd2.name= '890890';
dmd2.RW_Billing_Document_Number__c = '890890';
dmd2.RW_Customer_Number__c = '12345678';
insert dmd2;

RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
dmid2.RW_Demand_Item_Amount__c =1000000;
dmid2.RW_Demand__c = dmd2.id;
dmid2.RW_GST_Amount__c = 5000;
dmid2.RW_Legacy_Amount_Paid__c = 5000;
dmid2.RW_Legacy_Demand__c = true;
dmid2.Total_Demand_Item_Amount_Paid__c = 1000000;
insert dmid2;

RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
dmid1.RW_Demand_Item_Amount__c =1000000;
dmid1.RW_Demand__c = dmd2.id;
dmid1.RW_GST_Amount__c = 5000;
dmid1.RW_Legacy_Amount_Paid__c = 5000;
dmid1.RW_Legacy_Demand__c = true;
dmid1.Total_Demand_Item_Amount_Paid__c = 1000000;
insert dmid1;
update b;

Booking__c b1 = new Booking__c();
b1.Customer__c = o.Id;
b1.Project__c = p.Id;
b1.Opportunity__c = o.Id;
b1.Unit_No__c = objPUU.id;
b1.Quotation__c = q.Id;
b1.Booking_Date__c = Date.today();
b1.Account__c = acc.Id;
b1.Type_of_Client__c = 'Local';
b1.Status__c = 'Booking Confirmed';
b1.RW_Registration_Done__c = 'No';
b1.Exclude_From_Brokerage_Batch__c = false;
b1.Source_of_Booking__c = 'Direct';
//b.X5_Received__c = true;
b1.RW_Total_Receipt_Amount_Received__c = 1000000;
b1.Allotment_Premium__c = 10000000;
b1.RW_Registration_Status__c = 'Registration Completed';
b1.RW_Registration_Type__c = 'Offline Registration';
b1.RW_Expected_Registration_Date__c = system.today();
b1.RW_Registration_Done__c = 'No';
b1.CreatedDate = System.today();
b1.RW_Registration_Date__c = null;
b1.RW_BRL_Number__c = null;
insert b1;

RW_Demand__c dmd21 = new RW_Demand__c();
dmd21.Booking__c =b1.id;
dmd21.name= '890890';
dmd21.RW_Billing_Document_Number__c = '890890';
dmd21.RW_Customer_Number__c = '12345678';
insert dmd21;

RW_Demand_Item__c dmid21= new RW_Demand_Item__c();
dmid21.RW_Demand_Item_Amount__c =600000;
dmid21.RW_Demand__c = dmd21.id;
dmid21.RW_GST_Amount__c = 5000;
dmid21.RW_Legacy_Amount_Paid__c = 5000;
dmid21.RW_Legacy_Demand__c = true;
dmid21.Total_Demand_Item_Amount_Paid__c = 600000;
insert dmid21;

RW_Demand_Item__c dmid11 = new RW_Demand_Item__c();
dmid11.RW_Demand_Item_Amount__c =600000;
dmid11.RW_Demand__c = dmd21.id;
dmid11.RW_GST_Amount__c = 5000;
dmid11.RW_Legacy_Amount_Paid__c = 5000;
dmid11.RW_Legacy_Demand__c = true;
dmid11.Total_Demand_Item_Amount_Paid__c = 600000;
insert dmid11;
update b1;

system.debug('RW_Demand_Item_Amount__c'+dmid2.RW_Demand_Item_Amount__c);
system.debug('RW_GST_Amount__c'+dmid2.RW_GST_Amount__c);
system.debug('Demand_Amount__c'+dmd2.Demand_Amount__c);
system.debug('RW_Demand_Amount__c'+dmd2.RW_Demand_Amount__c);
system.debug('RW_Total_Demand_Amount__c'+dmd2.RW_Total_Demand_Amount__c);
system.debug('RW_Total_GST_Amount__c'+dmd2.RW_Total_GST_Amount__c);
system.debug('X5_Received__c'+b.X5_Received__c);
system.debug('RW_Total_Amount_Received_Without_GST__c'+b.RW_Total_Amount_Received_Without_GST__c);
system.debug('Allotment_Premium__c'+b.Allotment_Premium__c);
system.debug('RW_Total_Receipt_Amount_Received__c'+b.RW_Total_Receipt_Amount_Received__c);
system.debug('RW_Total_Demand_Raised__c'+b.RW_Total_Demand_Raised__c);
system.debug('RW_Total_GST_Amount__c'+b.RW_Total_GST_Amount__c);


Test.startTest(); 

BatchforPaymentReminderReporttoRM bb = new BatchforPaymentReminderReporttoRM();
Database.executeBatch(bb, 10);

SchedulePaymentReminderReporttoRM obj1 = new SchedulePaymentReminderReporttoRM();
obj1.execute(null);

Test.stopTest();

}*/
    @isTest  
    static void TaskTest() {
        Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        list<Tower__c> t = TestDataFactory.createTowers(1,p.Id);
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
        // List<Opportunity>  oList = New List<Opportunity>();
        List<Lead> llist = TestDataFactory.createLead(3);
        // List<Opportunity>  oList = TestDataFactory.createOpptyForAccount(acc.Id, p.Id, 2);
        Profile pr = [Select Id,Name from Profile where Name = 'NRI Sales Manager'];
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> lstUser = new List<User>();
        User u1 = new User(LastName = 'Test',
                           FirstName='Test1 User',
                           Alias = 'tstU1',
                           Email = 'testUsr1@stetig.in',
                           Username = 'testUsr1@stetig.in',
                           ProfileId = profileId.id,
                           CTI_Agent_ID__c = 'test.test1',
                           TimeZoneSidKey = 'America/Los_Angeles',
                           EmailEncodingKey = 'UTF-8',
                           LanguageLocaleKey = 'en_US',
                           LocaleSidKey = 'en_US');
        insert u1;
        
        User u = new User();
        u.Username = 'test123@stetig.in';
        u.LastName = 'Test';
        u.ManagerId = u1.Id;
        u.Email = 'test@stetig.in';
        u.Alias = 'Test';
        u.IsActive =true;
        u.EmailEncodingKey='UTF-8';
        u.LocaleSidKey='en_US';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.LanguageLocaleKey='en_US';
        if(pr.Id != null){
            u.ProfileId = pr.Id;
        }
        insert u;
        Opportunity o = new Opportunity(Name = 'Opp-1',RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Unit Booked', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
        insert o;
        list<Opportunity> oList = new list<Opportunity>{o};
            system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
        
        Task task = new Task(
            Subject = 'Visit Follow Up - Auto',
            Status = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(-5)
        );
        insert task;
        
        Project__c p1 = new Project__c();
        p1.Id = p.Id;
        p1.CRM_MIS_Head__c = userinfo.getUserId();
        p1.CRMHead__c = userinfo.getUserId();
        p1.Home_Loan_Email__c = UserInfo.getUserEmail();
        update p1;
        
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = p.id;
        insert objPUT;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = t[0].Id;
        ObjRm.Project__c = p.Id;
        // ObjRm.User__c = u.Id;
        ObjRm.User__c = UserInfo.getUserId();
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;
        objPUU.TowerName__c = t[0].Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = p.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.Relationship_Manager__c=   ObjRm.id;
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = p.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = o.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.MLCP_Additional__c = null;
        q.Agreement_Value_for_brokers__c = 10000000;
        insert q;   
        
        Booking__c b = new Booking__c();
        b.Customer__c = o.Id;
        b.Project__c = p.Id;
        b.Opportunity__c = o.Id;
        b.Unit_No__c = objPUU.id;
        b.Quotation__c = q.Id;
        b.Booking_Date__c = Date.today();
        b.Account__c = acc.Id;
        b.Type_of_Client__c = 'Local';
        b.Status__c = 'Booking Confirmed';
        b.RW_Registration_Done__c = 'No';
        b.Exclude_From_Brokerage_Batch__c = false;
        b.Source_of_Booking__c = 'Direct';
        //b.X5_Received__c = true;
        b.RW_Total_Receipt_Amount_Received__c = 600000;
        b.Allotment_Premium__c = 10000000;
        //b.RW_Registration_Status__c = 'Registration Completed';
        b.RW_Registration_Type__c = 'Offline Registration';
        b.RW_Expected_Registration_Date__c = system.today();
        b.RW_Registration_Done__c = 'No';
        insert b;
        
        RW_Demand__c dmd2 = new RW_Demand__c();
        dmd2.Booking__c =b.id;
        dmd2.name= '890890';
        dmd2.RW_Billing_Document_Number__c = '890890';
        dmd2.RW_Customer_Number__c = '12345678';
        insert dmd2;
        
        RW_Demand_Item__c dmid2= new RW_Demand_Item__c();
        dmid2.RW_Demand_Item_Amount__c =1000000;
        dmid2.RW_Demand__c = dmd2.id;
        dmid2.RW_GST_Amount__c = 5000;
        dmid2.RW_Legacy_Amount_Paid__c = 5000;
        dmid2.RW_Legacy_Demand__c = true;
        dmid2.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid2;
        
        RW_Demand_Item__c dmid1= new RW_Demand_Item__c();
        dmid1.RW_Demand_Item_Amount__c =1000000;
        dmid1.RW_Demand__c = dmd2.id;
        dmid1.RW_GST_Amount__c = 5000;
        dmid1.RW_Legacy_Amount_Paid__c = 5000;
        dmid1.RW_Legacy_Demand__c = true;
        dmid1.Total_Demand_Item_Amount_Paid__c = 1000000;
        insert dmid1;
        update b;
        
        Booking__c b1 = new Booking__c();
        b1.Customer__c = o.Id;
        b1.Project__c = p.Id;
        b1.Opportunity__c = o.Id;
        b1.Unit_No__c = objPUU.id;
        b1.Quotation__c = q.Id;
        b1.Booking_Date__c = Date.today();
        b1.Account__c = acc.Id;
        b1.Type_of_Client__c = 'Local';
        b1.Status__c = 'Booking Confirmed';
        b1.RW_Registration_Done__c = 'No';
        b1.Exclude_From_Brokerage_Batch__c = false;
        b1.Source_of_Booking__c = 'Direct';
        //b.X5_Received__c = true;
        b1.RW_Total_Receipt_Amount_Received__c = 1000000;
        b1.Allotment_Premium__c = 10000000;
        //b1.RW_Registration_Status__c = 'Registration Completed';
        b1.RW_Registration_Type__c = 'Offline Registration';
        b1.RW_Expected_Registration_Date__c = system.today();
        b1.RW_Registration_Done__c = 'No';
        insert b1;
        
        RW_Demand__c dmd21 = new RW_Demand__c();
        dmd21.Booking__c =b1.id;
        dmd21.name= '890890';
        dmd21.RW_Billing_Document_Number__c = '890890';
        dmd21.RW_Customer_Number__c = '12345678';
        insert dmd21;
        
        RW_Demand_Item__c dmid21= new RW_Demand_Item__c();
        dmid21.RW_Demand_Item_Amount__c =600000;
        dmid21.RW_Demand__c = dmd21.id;
        dmid21.RW_GST_Amount__c = 5000;
        dmid21.RW_Legacy_Amount_Paid__c = 5000;
        dmid21.RW_Legacy_Demand__c = true;
        dmid21.Total_Demand_Item_Amount_Paid__c = 600000;
        insert dmid21;
        
        RW_Demand_Item__c dmid11 = new RW_Demand_Item__c();
        dmid11.RW_Demand_Item_Amount__c =600000;
        dmid11.RW_Demand__c = dmd21.id;
        dmid11.RW_GST_Amount__c = 5000;
        dmid11.RW_Legacy_Amount_Paid__c = 5000;
        dmid11.RW_Legacy_Demand__c = true;
        dmid11.Total_Demand_Item_Amount_Paid__c = 600000;
        insert dmid11;
        update b1;
        
        system.debug('RW_Demand_Item_Amount__c'+dmid2.RW_Demand_Item_Amount__c);
        system.debug('RW_GST_Amount__c'+dmid2.RW_GST_Amount__c);
        system.debug('Demand_Amount__c'+dmd2.Demand_Amount__c);
        system.debug('RW_Demand_Amount__c'+dmd2.RW_Demand_Amount__c);
        system.debug('RW_Total_Demand_Amount__c'+dmd2.RW_Total_Demand_Amount__c);
        system.debug('RW_Total_GST_Amount__c'+dmd2.RW_Total_GST_Amount__c);
        system.debug('X5_Received__c'+b.X5_Received__c);
        system.debug('RW_Total_Amount_Received_Without_GST__c'+b.RW_Total_Amount_Received_Without_GST__c);
        system.debug('Allotment_Premium__c'+b.Allotment_Premium__c);
        system.debug('RW_Total_Receipt_Amount_Received__c'+b.RW_Total_Receipt_Amount_Received__c);
        system.debug('RW_Total_Demand_Raised__c'+b.RW_Total_Demand_Raised__c);
        system.debug('RW_Total_GST_Amount__c'+b.RW_Total_GST_Amount__c);
        
        
        Test.startTest(); 
        
        SendPaymentReminderReporttoRM.SendPaymentReminderReporttoRM();
        String cronExp = '0 0 12 * * ?';
        SchedulePaymentReminderReporttoRM scheduler = new SchedulePaymentReminderReporttoRM();
        System.schedule('Test Payment Reminder Scheduler', cronExp, scheduler);
        
        Test.stopTest();
    }        
}