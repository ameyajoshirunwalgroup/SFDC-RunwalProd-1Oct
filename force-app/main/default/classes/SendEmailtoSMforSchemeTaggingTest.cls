@isTest
public class SendEmailtoSMforSchemeTaggingTest {
 @isTest
    static void test1() {
        Project__c project = new Project__c(Name = 'Test Project');
        insert project;
        
         Project__c p = TestDataFactory.createProject('Xanadu_prj','111');
        Account acc = TestDataFactory.createPATemplate('TestPA1' , 'testleada@ozonetest.com', '9876544441', false);
        
        
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Mumbai';
        pl.Approver_L1__c = userinfo.getUserId();
        pl.Approver_L2__c = userinfo.getUserId();
        pl.Location__c = 'Mumbai';
        insert pl;
        
        Brokerage_Scheme__c bscheme = new Brokerage_Scheme__c();
        bscheme.Type__c = 'Both';
        bscheme.Approval_Status__c = 'Approved by Level 2';
        bscheme.Base_Brokerage_for_Local_Bookings__c = 2;
      //  bscheme.Base_Brokerage_for_OS_NRI__c = 3;
        bscheme.Slab_Type__c = 'Count';
        bscheme.Start_Date__c = system.today();
        bscheme.End_Date__c = system.today()+2;
        bscheme.Project_Location__c = pl.Id;
        bscheme.AOP_CP__c = 5;
        insert bscheme;
        
        Brokerage_Slab__c bslab = new Brokerage_Slab__c();
        bslab.Name = 'Slab 1';
        bslab.From__c = 0;
        bslab.To__c = 1;
        bslab.Additional_Brokerage_for_Local_Bookings__c = 0;
        bslab.Additional_Brokerage_for_OS_NRI__c = 0;
        bslab.Brokerage_Scheme__c = bscheme.Id;
        insert bslab;
        
        Brokerage_Slab__c bslab2 = new Brokerage_Slab__c();
        bslab2.Name = 'Slab 1';
        bslab2.From__c = 2;
        bslab2.To__c = null;
        bslab2.Additional_Brokerage_for_Local_Bookings__c = 0.25;
        bslab2.Additional_Brokerage_for_OS_NRI__c = 0.25;
        bslab2.Brokerage_Scheme__c = bscheme.Id;
        insert bslab2;
        
        Scheme_Configuration__c sc = new Scheme_Configuration__c();
        sc.Name = 'Oct';
        sc.Brokerage_Scheme__c = bscheme.Id;
        sc.Project__c = p.id;
        insert sc;
          Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='arduser@testorg.com', isActive = true,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p1.Id, 
                          
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = p.id;
        insert objPUT;
        list<Tower__c> t = TestDataFactory.createTowers(1,p.Id);
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
        objPUU.New_Type__c = 'R50'; 
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.Relationship_Manager__c=   ObjRm.id;
        objPUU.RW_Unit_Status__c ='Available';
        objPUU.RW_Param4__c = 'test 12';
        insert objPUU;
        Opportunity o = new Opportunity(Name = 'Opp-1',Primary_Name__c = 'Test 112',SAP_Customer_Number__c = '123456', SalesOrder_Number__c = '456374',RW_Project_Unit__c = objPUU.Id, RW_CIF_form_number__c = '18787652',Date_Of_Visit__c = system.today().addDays(-2), RW_Sales_Associate__c = 'Test', StageName='Unit Booked', Amount=5000000, AccountId =acc.Id, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project',  RW_Project__c = P.Id,closeDate=System.today(),Call_Rating__c = 0);
        insert o;
        list<Opportunity> oList = new list<Opportunity>{o};
        system.debug(oList[0].Name);                
        System.debug('Oplist Size :: ' +oList.size());
 
        list<Id> blist= new list<Id>();
        Booking__c booking = new Booking__c(
            Opportunity__c = o.id,
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'Local',
            Passback_Amount__c = 1000,
            Sales_Manager__c= UserInfo.getUserId(),
            Brokerage_scheme__c = bscheme.id ,
            Unit_No__c = objPUU.Id,
            Allotment_Premium__c = 5678987
            
        );
        insert booking;
        system.debug('blist'+booking);
        system.debug('blist'+booking.Sales_Manager__r.isActive);
        system.debug('blist'+booking.Booking_Date__c);
        blist.add(booking.id);
        
        
Booking__c booking2 = new Booking__c(
            Opportunity__c = o.id,
            Status__c = 'Booking Confirmed',
            Booking_Date__c = Date.today(),
            Type_of_Client__c = 'Local',
            Passback_Amount__c = 1000,
            Sales_Manager__c=UserInfo.getUserId(),
            Brokerage_scheme__c = bscheme.id ,
     Unit_No__c = objPUU.Id,
    Allotment_Premium__c = 678876
        );
        insert booking2;
        system.debug('blist'+booking);
        system.debug('blist'+booking.Sales_Manager__r.isActive);
        system.debug('blist'+booking.Booking_Date__c);
        	blist.add(booking2.id);
        
        system.debug('blist'+blist);
        
        Test.startTest(); 
        
       SendEmailtoSMforSchemeTagging.SendEmailtoSMforSchemeTagging(blist);
       // SendEmailtoSMforSchemeTagging.dummy();

        Test.stopTest();
        
    }
   
}