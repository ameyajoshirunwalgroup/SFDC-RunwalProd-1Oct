@isTest
private  Class TestVFControllers {
    @isTest
    private static void TaskRelatedListTest() {
        Account acc = createPATemplate('TestPA1' , 'testleada@radiustest.com', '9876544441', false);
        Project__c p = createProject('ONE BKC','111');
        //create Opportunity
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        List<Lead> lList = createLead(1);
        
        Test.startTest();
        Opportunity o = oList[0];
        PageReference page = new PageReference(o.Id);
        System.test.setCurrentpage(page);
        ApexPages.StandardController sc = new ApexPages.StandardController(o);
        TaskRelatedListClass tExtn = new TaskRelatedListClass(sc);
        TaskRelatedListClass.getTasksByType('ALL',o.Id);
        TaskRelatedListClass.isRevisit(o.Id);
        TaskRelatedListClass.getButtonAccess('Site Visit');
        TaskRelatedListClass.isSystemAdmin('Site Visit'); 
        List<String> typeList = tExtn.taskType;
        
        Lead l = llist[0];
        PageReference page1 = new PageReference(l.Id);
        System.test.setCurrentpage(page1);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(l);
        TaskRelatedListClass tExtn1 = new TaskRelatedListClass(sc1);
        TaskRelatedListClass.getTasksByType('ALL',l.Id);
        TaskRelatedListClass.isRevisit(l.Id);
        TaskRelatedListClass.getButtonAccess('Presales Call');
        TaskRelatedListClass.isSystemAdmin('Presales Call'); 
        List<String> typeList1 = tExtn1.taskType;
        Test.stopTest();   
        
    }
    
    
    
    @isTest
    private static void TaskPageTest() {
        
        Test.startTest();
        Account acc = createPATemplate('TestPA1' , 'testleada@radiustest.com', '9876544441', false);
        Project__c p = createProject('ONE BKC','111');
        List<Opportunity>  oList = createOpptyForAccount(acc.Id, p.Id, 1);
        
        /*  List <Car_Parking_Charge__c>  ParkingListToUpdate = new List <Car_Parking_Charge__c>();
List <Car_Parking_Charge__c>  TandemOPENParkingList = new List <Car_Parking_Charge__c>();
List <Car_Parking_Charge__c>  SingleOPENParkingList = new List <Car_Parking_Charge__c>();
List <Car_Parking_Charge__c>  SingleCOVEREDParkingList = new List <Car_Parking_Charge__c>();
List <Car_Parking_Charge__c>  TandemCOVEREDParkingList = new List <Car_Parking_Charge__c>();
List <Car_Parking_Charge__c>  STACKParkingList = new List <Car_Parking_Charge__c>();*/
        
        
        
        
        
        Lead l = createLeadTemplate('BigLead', 'biglead@email.com', '1234567890', false);
        //l.Date_Of_Visit__c = System.today();
        //l.Unique_SVF_Number__c = 'SVF90900';
        l.leadSource = 'Direct';
        l.lead_Sub_Source__c = 'Hoarding';
        l.RW_Budget__c = '< 1Cr';
        l.RW_Configuration__c = '1 BHK';
        l.RW_Time_line__c = 'Ready Possession';
        l.RW_Location__c = 'Airoli';
        
        update l;
        lead cLead = convertLead(l);
        
        PageReference pRef = Page.CallAttemptEditPage2;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('who_id',cLead.Id);
        ApexPages.currentPage().getParameters().put('what_id',cLead.ConvertedOpportunityId);      
        /*Task t = new Task();
        ApexPages.StandardController sc = new ApexPages.StandardController(t);
        CustomTaskControllerClass tExtn = new CustomTaskControllerClass(sc);
        tExtn.save();*
        List<SelectOption> hlrm = tExtn.hlrmNames;
        List<SelectOption> callStatus = tExtn.homeLoanCallStatus;
        List<SelectOption> followUpStatus = tExtn.homeLoanFollowupStatus;*/
        
        List<Task> tList1 = createTasksForOpp(cLead.ConvertedOpportunityId, 1, 'Site Visit');
        PageReference pRef1 = Page.VisitFormEditPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('retURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('cancelURL',cLead.ConvertedOpportunityId);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('id',tList1[0].id);
        Task t1 = tList1[0];
        ApexPages.StandardController sc1 = new ApexPages.StandardController(t1);
        CustomTaskControllerClass tExtn1 = new CustomTaskControllerClass(sc1);
        tExtn1.save();
        tExtn1.cancel();
        tExtn1.Savedoc();
        //tExtn1.dummyMethod();
        //tExtn1.dummyMethod566();
        List<SelectOption> resultOptions = tExtn1.hlrmNames;
        List<SelectOption> resultOptions1 = tExtn1.homeLoanCallStatus;
        List<SelectOption> resultOptions2 = tExtn1.homeLoanFollowupStatus;
        
        
        Test.stopTest();
        
        List<Task> tList2 = createTasksForOpp(oList[0].Id, 1, 'Site Visit');
        PageReference pRef2 = Page.VisitFormViewPage;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('retURL',oList[0].Id);
        ApexPages.currentPage().getParameters().put('cancelURL',oList[0].Id);
        ApexPages.currentPage().getParameters().put('origin','New Call Attempt');
        ApexPages.currentPage().getParameters().put('who_id',acc.Id);
        ApexPages.currentPage().getParameters().put('what_id',oList[0].Id);      
        Task t2 = new Task();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(t2);
        CustomTaskControllerClass tExtn2 = new CustomTaskControllerClass(sc2);
        
    }
    
    @isTest
    private static void SMAssignToProsTest() {
        Project__c p2 = TestDataFactory.createProject('Xanadu_prj2','111');
        Account acc2 = TestDataFactory.createPATemplate('TestPA2' , 'testleada@ozonetest.com', '9876544441', false);
        
        List<Lead> llist2 = TestDataFactory.createLead(3);
        List<Opportunity>  oList2 = TestDataFactory.createOpptyForAccount(acc2.Id, p2.Id, 3);
        
        //system.debug(oList2[0].Name);           
        
        Team__c tm = new Team__c();
        tm.name = 'Prospect Team';
        tm.Project__c = p2.id;
        tm.Team_Type__c = 'Prospect Team';
        insert tm;
        
        Team_Members__c tmm = new Team_Members__c(); 
        tmm.Team__c = tm.id;
        tmm.User_Active__c = true;
        tmm.User__c = UserInfo.getUserId();
        insert tmm;
        
        //List<Task> tList1 = TestDataFactory.createTasksForOpp(oList[0].Id, 2, 'Presales Call');
        //List<Task> tList2 = TestDataFactory.createTasksForOpp(oList[1].Id, 2, 'Site Visit');
        
        
        Project_Location__c pl = new Project_Location__c();
        pl.Name = 'Test';
        pl.Approver_L1__c = UserInfo.getUserId();
        pl.Approver_L2__c = UserInfo.getUserId();
        pl.Location__c = 'Mumbai';
        pl.CP_Category__c = 'P1';
        insert pl;
        
        p2.Project_Location__c = pl.id;
        update p2;
        Broker__c b = new Broker__c();
        b.Name = 'Test';
        b.Unregistered_Channel_Partner__c = true;
        b.AOP_Type__c = 'AOP';
        b.Broker_Pan_No__c = 'AZSDF2321Q';
        insert b;        
        
        Broker__c b1 = new Broker__c();
        b1.Name = 'Test 2';
        b1.Unregistered_Channel_Partner__c = true;
        b1.AOP_Type__c = 'AOP';
        b1.Broker_Pan_No__c = '887766543W';
        insert b1;
        
        Prospect__c ps = new Prospect__c();
        ps.Account__c = acc2.id;
        ps.Project__c = p2.id;
        ps.Active__c = true;
        ps.Channel_Partner__c = b.id;
        insert ps;
        
        Project__c objProj1 = new Project__c();
        objProj1.name = 'test3';
        insert objProj1;
        
        ps.Project__c = objProj1.id;
        ps.Channel_Partner__c = b1.id;
        update ps;
        
        Prospect__c ps3 = new Prospect__c();
        ps3.Account__c = acc2.id;
        ps3.Project__c = p2.id;
        ps3.Active__c = true;
        
        try{
            insert ps3;
        }catch(Exception e){
            
        }
        Prospect__c ps2 = new Prospect__c();
        ps2.Lead__c = llist2[0].id;
        ps2.Project__c = p2.id;
        ps2.Active__c = true;
        insert ps2;
        
        Prospect__c ps4 = new Prospect__c();
        ps4.Lead__c = llist2[0].id;
        ps4.Project__c = p2.id;
        ps4.Active__c = true;
        try{
            insert ps4;
        }catch(Exception e){
            
        }  
        
        PageReference pRef = Page.SMAssignToProspect;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('id',ps.Id);
        SMAssignToProspect smp = new SMAssignToProspect();
        smp.assignSM();
        smp.BackToPage();
        
    }
    
    @isTest
    private static void InventoryViewTest() {
        Client__c cl = TestDataFactory.createClients('Client1');
        
        List<Project__c> p = TestDataFactory.createProjectWithClient(1,'888',cl.Id);
        
        //create Clusters
        List<Cluster__c> cList = TestDataFactory.createClusters(2, p[0].Id);
        
        //create Towers
        List<Tower__c> tList = TestDataFactory.createTowers(2, p[0].Id);
        
        //create Units
        List<Project_Unit__c> uList = TestDataFactory.createUnits(tList[0].Id, p[0].Id);
        
        Test.startTest();
        PageReference pRef = Page.S_InventoryMatrixview;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('projectsent',p[0].Id);
        ApexPages.currentPage().getParameters().put('towersent',tList[0].Id);
        
        S_InventoryMatrix invController = new S_InventoryMatrix();
        invController.selectedVal = p[0].Id;
        invController.SelectedClusterId = cList[0].Id;
        invController.selectedTower = tList[0].Id;
        invController.selectedstatus = '';
        invController.selectedConf = uList[0].Id ;
        invController.sold = true;
        invController.open = true;
        invController.booked = true;
        invController.reserved = true;
        invController.blocked = true;
        
        invController.onebhk = true;
        invController.twobhk = true;
        invController.threebhk = true;
        invController.fourbhk = true;
        invController.fivebhk = true;
        
        //List<SelectOption> cli = invController.getClients;
        List<SelectOption> pl = invController.getProjects;
        //List<SelectOption> cul = invController.getClusterNames;
        List<SelectOption> tl = invController.getTowers;
        //List<SelectOption> pu = invController.getProjectunittype;
        List<Decimal> floorSeq = invController.floorDescSeqList;
        Map<Decimal, List<Project_Unit__c>> UnitMap = invController.JMap;
        //verify towers, projects, units in one floor 
        // System.assertEquals(2,pl.size());
        // System.assertEquals(3,tl.size());
        // System.assertEquals(5, UnitMap.get(1).size());
        
        Test.stopTest();
    }
    /*
@isTest
private static void BookingPageTest() {
Opportunity objcustomer;
Opportunity objcustomer1;
Booking__c objBooking;
Project__c objpr;
Project_Unit__c objPUU;
Project_Unit__c objPUU1;
Project_Unit_Type__c objPUT;
Car_Parking_Charge__c objCP1;
Car_Parking_Charge__c objCP2;

objpr = new Project__c();
objpr.RW_Project_Code__c = 'T31';
objpr.Name = 'TestProject';
objpr.RDS_Short_Name__c = 'T';
objpr.Start_Date__c = System.today().addDays(-5);
objpr.RDS_Interest_Rate__c = 12;
insert objpr;

objPUT = new Project_Unit_Type__c();
objPUT.RDS_Code__c = '101';
objPUT.RDS_Project__c = objpr.id;
insert objPUT;

objPUU = new Project_Unit__c();  
objPUU.Project_Unit_Type__c = objPUT.id;  
objPUU.Name = 'TestUnit';      
objPUU.RW_Project__c = objpr.Id;
objPUU.RW_Param1__c = '5';
objPUU.UnitNo__c ='9';
objPUU.RW_Unit_Status__c ='Available';
insert objPUU;

objPUU1 = new Project_Unit__c();  
objPUU1.Project_Unit_Type__c = objPUT.id;  
objPUU1.Name = 'TestUnit1';      
objPUU1.RW_Project__c = objpr.Id;
objPUU1.RW_Param1__c = '5';
objPUU1.UnitNo__c ='10';
objPUU1.RW_Unit_Status__c ='Available';
insert objPUU1;

objCP1 = new Car_Parking_Charge__c();
objCP1.Status__c = 'Vacant';
objCP1.Category__c = 'Additional';
objCP1.Parking__c = 'Tandem';
objCP1.Project__c = objpr.Id;
insert objCP1;

objCP2 = new Car_Parking_Charge__c();
objCP2.Status__c = 'Vacant';
objCP2.Category__c = 'Additional';
objCP2.Parking__c = 'Single';
objCP2.Project__c = objpr.Id;
insert objCP2;

Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
a.BillingCity = 'Pune';
a.billingState = 'MH';
a.billingCountry = 'India';
update a;
objcustomer= new Opportunity();
objcustomer.RW_Project__c=objpr.id;
objcustomer.name='Test 1';
objcustomer.StageName='Open';
objcustomer.RW_Project_Unit__c=objPUU.id;  
objcustomer.CloseDate=system.today();
objcustomer.Status__c ='Active';
objCustomer.AccountId = a.Id;
insert objcustomer;

objcustomer1= new Opportunity();
objcustomer1.RW_Project__c=objpr.id;
objcustomer1.name='Test 1';
objcustomer1.StageName='Open';
objcustomer1.RW_Project_Unit__c=objPUU1.id;  
objcustomer1.CloseDate=system.today();
objcustomer1.Status__c ='Active';
objcustomer1.AccountId = a.Id;
insert objcustomer1;
// tower creation 
Tower__c t = new Tower__c();
t.Name = 'Tower X';
t.ProjectName__c = objpr.Id;
t = RDSCommon.CreateTower(t);

Project_Construction_Stages__c objPCS1 = new Project_Construction_Stages__c();
objPCS1.Project__c = objpr.Id;
objPCS1.Name = 'At Fit Out Possession';
objPCS1.Code__c ='Test1';
objPCS1.Description__c='At Fit Out Possession';
objPCS1.Planned_date_of_completion__c = System.today().addDays(365);
objPCS1.Tower__c = t.Id;
insert objPCS1;

Quotation__c q = new Quotation__c();
q.Name = 'Q010101';
q.Quote_Status__c = 'Valid';
q.Prepared_Date__c = System.today();
q.Project__c = objpr.Id;
q.Project_Unit__c = objPUU.Id;
q.FloorNo__c = 11;
q.Opportunity__c = objcustomer.Id;
q.Appartment_Configuration__c = '1 BHK';
q.Carpet_Area_Sq_Ft__c = 1200;
q.Token_Amount__c =110000;
q.ST_Token_Amount__c = 1000;
q.Allow_booking_without_full_token__c = TRUE;
q.Agreement_Value__c = 60422880;
q.Agreement_Value_ST__c = 2537761;
q.Tandem_car_park_Additional__c = 1;
q.Single_car_park_Additional__c = 1;
insert q;

Receipt__c r1 = new Receipt__c();
r1.Cheque_DD_Amount_Rs__c = 200000;
r1.Cheque_DD__c = '908888';
r1.Cheque_DD_Date__c = system.today();
r1.Project__c = objpr.Id;
r1.Project_Unit__c = objPUU.Id;
r1.Opportunity__c = objcustomer.Id;
r1.CheckReceipt__c = true;
r1.Token_Amount_Receipt__c = true;
r1.Physically_Cheque_Received__c = true;
r1.Approval_Status__c = 'Approved';
r1.Receipt_Date__c = system.today();
r1.DraweeBank__c = 'Axis Bank';
r1.Total_Amount__c = 200000;
r1.Currency__c = 'Indian Rupee';
insert r1;

Receipt__c r2 = new Receipt__c();
r2.Cheque_DD_Amount_Rs__c = 8400;
r2.Cheque_DD__c = '9088881';
r2.Cheque_DD_Date__c = system.today();
r2.Project__c = objpr.Id;
r2.Project_Unit__c = objPUU.Id;
r2.Opportunity__c = objcustomer.Id;
r2.CheckReceipt__c = true;
r2.Physically_Cheque_Received__c = true;
r2.Approval_Status__c = 'Approved';
r2.Receipt_Date__c = system.today();
r2.DraweeBank__c = 'CITI';
r2.Total_Amount__c = 8400;
r1.Currency__c = 'Indian Rupee';
r2.Token_Amount_ST__c = true;
insert r2;

PageReference rPage = Page.S_PrintReceipt;
Test.setCurrentPage(rPage);

ApexPages.currentPage().getParameters().put('id', r1.id);
ApexPages.currentPage().getParameters().put('letterHead', 'true');
PrintReceipt pr = new PrintReceipt(); 
Receipt_Details__c rd = new Receipt_Details__c();
Project_Charges__c pc = new Project_Charges__c();
pc.Name = 'pc1';
pc.External_Id__c ='';
pc.Active__c = true;
pc.Applied_This_Charge_To_FA__c = true;
insert pc;
//rd.Name = 'RD001';
rd.Amount__c = null;
rd.Receipts__c = r1.id;
//rd.Cheque_number_for_integration__c = '1256';
system.debug('pc.id::: '+pc.id);
rd.Charges__c = pc.id;
rd.For_Service_Tax__c = false;
insert rd;
new PrintReceipt.wrapperclass(rd,rd.Charges__r.Name,rd.For_Service_Tax__c);
pr.ownerName = '';
pr.ownerPhone= '';
pr.ownerEmail= '';
pr.ownerSalutation= '';
pr.legalAddress= '';
pr.legalCity= '';
pr.legalPinCode= '';
pr.legalEntityName= '';


PageReference pRef22 = Page.S_TokenReceipt;
Test.setCurrentPage(pRef22);
Apexpages.currentPage().getParameters().put('id', objcustomer.id);
S_TokenReceiptController rc = new S_TokenReceiptController();
rc.validate();
rc.r.mode__c = 'TDS';
rc.selectInstrument();
rc.r.mode__c = 'Cheque';
rc.selectInstrument();
rc.r.Project_Unit__c = objPUU.id;
rc.getEntityDetails();
List<SelectOption> sl = rc.holdOptions;
rc.unitHeld = 'YES';

rc.unitHoldAction();
rc.r.mode__c = 'Cheque';
rc.r.Receipt_Date__c = system.today();
rc.r.Cheque_DD_Date__c = system.today().addDays(1);
rc.r.DraweeBank__c = 'AXIS';
rc.r.Cheque_DD__c = 'CQ0001';
rc.r.Currency__c = 'Indian Rupee';
rc.r.Amount_Rs__c = 2000000;
rc.entitySelected = 'FLAT COST | VISHWAROOP';
rc.saveReceipt();

PageReference pRef33 = Page.S_TokenReceipt;
Test.setCurrentPage(pRef33);
Apexpages.currentPage().getParameters().put('id', objcustomer.id);
S_TokenReceiptController rc1 = new S_TokenReceiptController();
rc1.validate();
rc1.r.mode__c = 'EFT';
rc1.r.Receipt_Date__c = system.today();
rc1.r.Cheque_DD_Date__c = system.today().addDays(1);
rc1.r.DraweeBank__c = 'AXIS';
rc1.r.Cheque_DD__c = 'CQ0001';
rc1.r.Currency__c = 'Indian Rupee';
rc1.r.Amount_Rs__c = 2000000;
rc1.entitySelected = 'SERVICE TAX | VISHWAROOP';
rc1.saveReceipt();


// Test.startTest();
PageReference pRef = Page.BookingPageForm2;
Test.setCurrentPage(pRef);
ApexPages.currentPage().getParameters().put('optyId',objCustomer.id);
BookingClass bookC = new BookingClass();
List < SelectOption > sq= bookC.getQuote;
//   bookC.getQuoteStatus();
bookC.selectedQuote = q.Id;
bookC.getTokenAmount();
bookC.getReceiptDetails();
////////////////////////////////////////////////////////////////
//objBooking.Customer__c=objcustomer.id;
//objBooking.Opportunity__c = objcustomer.id;
////////////////////////////////////////////////////////////////
bookC.boookingObj.Application_No__c = '1234';
bookC.boookingObj.Future_Correspondence_Contact__c = 'Other';
bookC.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
bookC.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
bookC.applicant.Salutation__c = 'Mr.';
bookC.applicant.Name = 'New Man';
bookC.applicant.DOB__c = system.today();
bookC.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC.applicant.Nationality__c = 'Indian';
bookC.applicant.Pincode__c = 898900;
bookC.applicant.Country__c = 'India';
bookC.applicant.Mobile_Number__c = '909090900';
bookC.applicant.Email_Address__c = 'newman@justnow.com';
bookC.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
bookC.applicant.Subtype_Of_Applicant__c = 'Indian National';
bookC.applicant.Pancard__c = true;
bookC.ServiceTaxCheck = true;
bookC.selectedVal = '';
//bookC.quotationidparam = '';
bookC.save();
Test.startTest();
PageReference pRef1 = Page.BookingPageForm2;
Test.setCurrentPage(pRef1);
ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
ApexPages.currentPage().getParameters().put('projectId',objpr.id);
BookingClass bookC1 = new BookingClass();
List < SelectOption > sq1= bookC1.getQuote;
//  bookC1.getQuoteStatus();
bookC1.getTokenAmount();
bookC1.getReceiptDetails();

// general required fields validation simulation
//bookC1.save();  
bookC1.selectedQuote = q.Id;
bookC1.save();  
bookC1.boookingObj.Application_No__c = '1234';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';
bookC1.save();

bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
bookC1.save();

// applicant1 to required fields validation simulation
bookC1.applicant.Salutation__c = 'Mr.';
bookC1.save();
bookC1.applicant.Name = 'New Man';
bookC1.save();   
bookC1.applicant.DOB__c = system.today();
bookC1.save();
bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant.Pincode__c = 898900;
bookC1.save();
bookC1.applicant.Country__c = 'India';
bookC1.save();
bookC1.applicant.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheck = FALSE; 
bookC1.save();        


// applicant2 to required fields validation simulation
bookC1.applicant2.Name = 'Second Man';
bookC1.save(); 
bookC1.applicant2.DOB__c = system.today();
bookC1.save();
bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant2.Pincode__c = 898900;
bookC1.save();
bookC1.applicant2.Country__c = 'India';
bookC1.save();
bookC1.applicant2.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant2.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant2.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant2.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheckApplicant2 = FALSE;
bookC1.save();

// applicant3 to required fields validation simulation
bookC1.applicant3.Name = 'Second Man';
bookC1.save(); 
bookC1.applicant3.DOB__c = system.today();
bookC1.save();
bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant3.Pincode__c = 898900;
bookC1.save();
bookC1.applicant3.Country__c = 'India';
bookC1.save();
bookC1.applicant3.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
Test.stopTest();

bookC1.applicant3.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant3.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant3.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant3.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheckApplicant3 = FALSE;
bookC1.save();

// applicant4 to required fields validation simulation
bookC1.applicant4.Name = 'Second Man';
bookC1.save(); 
bookC1.applicant4.DOB__c = system.today();
bookC1.save();
bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant4.Pincode__c = 898900;
bookC1.save();
bookC1.applicant4.Country__c = 'India';
bookC1.save();
bookC1.applicant4.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheckApplicant4 = FALSE;
bookC1.save();


// applicant5 to required fields validation simulation
bookC1.applicant5.Name = 'Second Man';
bookC1.save(); 
bookC1.applicant5.DOB__c = system.today();
bookC1.save();
bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();        
bookC1.applicant5.Pincode__c = 898900;
bookC1.save();
bookC1.applicant5.Country__c = 'India';
bookC1.save();

bookC1.applicant5.Mobile_Number__c = '909090900';
bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
bookC1.applicant5.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.applicant5.Subtype_Of_Applicant__c = 'For NRI';
bookC1.applicant5.Subtype_Of_Applicant__c = 'For Company';
bookC1.applicant5.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.addressCheckApplicant5 = FALSE;

////////////////////////////////////////////////////////////////////
bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
////////////////////////////////////////////////////////////////////

/*objPUU.RW_Unit_Status__c = 'Sold';
update objPUU;
PageReference upsPage = Page.updateConsStageNew;
Test.setCurrentPage(upsPage);
Apexpages.currentPage().getParameters().put('Pid',objPr.id);
updateConsStageNew ups = new updateConsStageNew();

List < SelectOption > tList = ups.getTowerSelectList();
ups.towerID = t.Id;
List < SelectOption > stageList = ups.getConstructionSelectList();
list<SelectOption> options = ups.updateOptions;
ups.updateType = 'plannedDate';
ups.plannedDate = system.today().addDays(50);
ups.stageId = objPCS1.id;
ups.save();
Attachment objattch = ups.objattachment;
objattch.name='test';
objattch.ParentId=objPCS1.id;
Blob bodyBlob=Blob.valueOf('test');
objattch.body=bodyBlob;
ups.upload();

ups.towerID = t.Id;
ups.updateType = 'completionDate';
ups.dueDate = system.today();
ups.stageId = objPCS1.id;
ups.save();
ups.dummy();
ups.refresh();
ups.cancel();



}*/
    
    @isTest 
    private static void BookingPageTest1() {
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Service_Tax_Required_On_Token_Amount__c = true;
        insert objpr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Open';
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        insert objcustomer1;
        
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU1.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer1.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Agreement_Value__c = 60422880;
        q.Stamp_Duty__c =10000;
        q.Agreement_Value_ST__c = 2537761;
        insert q;
        
        Test.startTest();      
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer1.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU1.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        //   bookC1.getQuoteStatus();
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
      //commented by digicloud  bookC1.ServiceTaxCheck = true;
        //bookC1.dummyMethod();
        
        
        bookC1.boookingObj.Application_No__c = '1234';
        bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 898900;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Mobile_Number__c = '909090900';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
        bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
        bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
        
        // simulating validation errors of token amount receipt
        bookC1.receiptObj.Mode__c = 'Cheque';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'Demand Draft';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'DD/Pay Order';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'EFT';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'NEFT';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'RTGS';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'TDS';
        //bookC1.save();
        bookC1.receiptObj.Mode__c = 'Pay Order';
        //bookC1.save();
        bookC1.receiptObj.Total_Amount__c = 0;
        //bookC1.Save();
        bookC1.receiptObj.Total_Amount__c = 9000000;
        //bookC1.Save();
        bookC1.receiptObj.Pay_Order__c = 'PO122';
        //bookC1.save();
        bookC1.receiptObj.cheque_DD_Date__c = system.today();
        //bookC1.save();
        bookC1.receiptObj.DraweeBank__c = 'ICICI';
        //bookC1.save();
        bookC1.receiptObj.Branch__c = 'Mumbai';
        bookC1.save();
        
        // simulating service tax receipt capture validation errors
/* commented by digicloud     bookC1.STreceiptObj.Mode__c = 'Cheque';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'DD/Pay Order';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'EFT';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'Demand Draft';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'NEFT';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'RTGS';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'TDS';
        bookC1.save();
        bookC1.STreceiptObj.Mode__c = 'Pay Order';
        bookC1.save();
        bookC1.STreceiptObj.Total_Amount__c = 0;
        bookC1.Save();
        bookC1.STreceiptObj.Total_Amount__c = 9000000;
        bookC1.Save();
        bookC1.STreceiptObj.cheque_DD_Date__c = system.today();
        bookC1.save();
        bookC1.STreceiptObj.Pay_Order__c = 'PO10122';
        bookC1.save();
        bookC1.STreceiptObj.DraweeBank__c = 'ICICI';
        bookC1.save();
        bookC1.STreceiptObj.Branch__c = 'Mumbai';
        */
        //bookC1.save(); //Commented by Vinay 24-04-2025
    //commented by digicloud    bookC1.selectedVal = '';
        //bookC1.quotationidparam = '';
        
        Test.stopTest();
        
    }  
    
    
    @isTest 
    private static void BookingPageTest2() {
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Service_Tax_Required_On_Token_Amount__c = true;
        insert objpr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.New_Floor__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Single';
        objCP2.Project__c = objpr.Id;
        insert objCP2;
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Open';
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        insert objcustomer1;
        
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU1.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer1.Id;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        //q.Tandem_car_park_Additional__c = 1;
        //q.Single_car_park_Additional__c = 1;
        
        insert q;
        
        Test.startTest();      
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer1.id);
        BookingClass bookC1 = new BookingClass();
        bookC1.boookingObj.Opportunity__c = objCustomer1.id;
        List < SelectOption > sq1= bookC1.getQuote;
        bookC1.selectedQuote = q.Id;
        //  bookC1.getQuoteStatus();
        bookC1.getTokenAmount();
        bookC1.getReceiptDetails();
        bookC1.getaddressstatus();
        
        bookC1.boookingObj.Application_No__c = '1234';
        bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';
        bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        bookC1.boookingObj.Future_Correspondence_Contact_Name__c = 'futureman';
        bookC1.boookingObj.Future_Correspondence_Contact_Relation__c = 'Friend';
        
        bookC1.applicant.Salutation__c = 'Mr.';
        bookC1.applicant.Name = 'New Man';
        bookC1.applicant.DOB__c = system.today();
        bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant.Pincode__c = 898900;
        bookC1.applicant.Country__c = 'India';
        bookC1.applicant.Country__c = 'State';
        bookC1.applicant.City__c = 'Mumbai';
        bookC1.applicant.Nationality__c = 'Indian';
        bookC1.applicant.Mobile_Number__c = '909090900';
        bookC1.applicant.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant.PanCard__c = true;
        bookC1.applicant.address_proof__c = true;
        bookC1.applicant.address_proof_document__c = 'PAN Card';
        bookC1.applicant.address_proof_number__c = 'PA0001';
        bookC1.applicant.One_passport_size_color_photograph__c = true;
        
        bookC1.applicant3.Salutation__c = 'Mr.';
        bookC1.applicant3.Name = 'New Man';
        bookC1.applicant3.DOB__c = system.today();
        bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant3.Pincode__c = 898900;
        bookC1.applicant3.Country__c = 'India';
        bookC1.applicant3.Country__c = 'State';
        bookC1.applicant3.City__c = 'Mumbai';
        bookC1.applicant3.Nationality__c = 'Indian';
        bookC1.applicant3.Mobile_Number__c = '909090900';
        bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant3.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant3.PanCard__c = true;
        bookC1.applicant3.address_proof__c = true;
        bookC1.applicant3.address_proof_document__c = 'PAN Card';
        bookC1.applicant3.address_proof_number__c = 'PA0001';
        bookC1.applicant3.One_passport_size_color_photograph__c = true;
        
        bookC1.applicant2.Salutation__c = 'Mr.';
        bookC1.applicant2.Name = 'New Man';
        bookC1.applicant2.DOB__c = system.today();
        bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant2.Pincode__c = 898900;
        bookC1.applicant2.Country__c = 'India';
        bookC1.applicant2.Country__c = 'State';
        bookC1.applicant2.City__c = 'Mumbai';
        bookC1.applicant2.Nationality__c = 'Indian';
        bookC1.applicant2.Mobile_Number__c = '909090900';
        bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant2.PanCard__c = true;
        bookC1.applicant2.address_proof__c = true;
        bookC1.applicant2.address_proof_document__c = 'PAN Card';
        bookC1.applicant2.address_proof_number__c = 'PA0001';
        bookC1.applicant2.One_passport_size_color_photograph__c = true;
        
        bookC1.applicant4.Salutation__c = 'Mr.';
        bookC1.applicant4.Name = 'New Man';
        bookC1.applicant4.DOB__c = system.today();
        bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant4.Pincode__c = 898900;
        bookC1.applicant4.Country__c = 'India';
        bookC1.applicant4.Country__c = 'State';
        bookC1.applicant4.City__c = 'Mumbai';
        bookC1.applicant4.Nationality__c = 'Indian';
        bookC1.applicant4.Mobile_Number__c = '909090900';
        bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant4.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant4.PanCard__c = true;
        bookC1.applicant4.address_proof__c = true;
        bookC1.applicant4.address_proof_document__c = 'PAN Card';
        bookC1.applicant4.address_proof_number__c = 'PA0001';
        bookC1.applicant4.One_passport_size_color_photograph__c = true;
        
        bookC1.applicant5.Salutation__c = 'Mr.';
        bookC1.applicant5.Name = 'New Man';
        bookC1.applicant5.DOB__c = system.today();
        bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC1.applicant5.Pincode__c = 898900;
        bookC1.applicant5.Country__c = 'India';
        bookC1.applicant5.Country__c = 'State';
        bookC1.applicant5.City__c = 'Mumbai';
        bookC1.applicant5.Nationality__c = 'Indian';
        bookC1.applicant5.Mobile_Number__c = '909090900';
        bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
        bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
        bookC1.applicant5.PanCard__c = true;
        bookC1.applicant5.address_proof__c = true;
        bookC1.applicant5.address_proof_document__c = 'PAN Card';
        bookC1.applicant5.address_proof_number__c = 'PA0001';
        bookC1.applicant5.One_passport_size_color_photograph__c = true;
        
        
        bookC1.receiptObj.Mode__c = 'Pay Order';
        bookC1.receiptObj.Total_Amount__c = 9000000;
        bookC1.receiptObj.Pay_Order__c = 'PO122';
        bookC1.receiptObj.cheque_DD_Date__c = system.today();
        bookC1.receiptObj.DraweeBank__c = 'ICICI';
        bookC1.receiptObj.Branch__c = 'Mumbai';
        
      /*  bookC1.STreceiptObj.Mode__c = 'Pay Order';
        bookC1.STreceiptObj.Total_Amount__c = 9000000;
        bookC1.STreceiptObj.cheque_DD_Date__c = system.today();
        bookC1.STreceiptObj.Pay_Order__c = 'PO10122';
        bookC1.STreceiptObj.DraweeBank__c = 'ICICI';
        bookC1.STreceiptObj.Branch__c = 'Mumbai'; commented by digicloud*/
        bookC1.save();
        
        Test.stopTest();
        
    }
    @isTest
    private static void BookingPageTest3() {
        Test.startTest();
        Opportunity objcustomer;
        Opportunity objcustomer1;
        Booking__c objBooking;
        Project__c objpr;
        Project_Unit__c objPUU;
        Project_Unit__c objPUU1;
        Project_Unit_Type__c objPUT;
        Car_Parking_Charge__c objCP1;
        Car_Parking_Charge__c objCP2;
        Car_Parking_Charge__c objCP3;
        Car_Parking_Charge__c objCP4;
        Car_Parking_Charge__c objCP5;
        
        objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        List<Project_Unit__c> units = new List<Project_Unit__c>();
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        //insert objPUU;
        units.add(objPUU);
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        //insert objPUU1;
        units.add(objPUU1);
        insert units;
        
        List<Car_Parking_Charge__c> parkings = new List<Car_Parking_Charge__c>();
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        //insert objCP1;
        parkings.add(objCP1);
        
        objCP2 = new Car_Parking_Charge__c();
        objCP2.Status__c = 'Vacant';
        objCP2.Category__c = 'Additional';
        objCP2.Parking__c = 'Tandem Open';
        objCP2.Project__c = objpr.Id;
        //insert objCP2;
        parkings.add(objCP2);
        
        objCP3 = new Car_Parking_Charge__c();
        objCP3.Status__c = 'Vacant';
        objCP3.Category__c = 'Additional';
        objCP3.Parking__c = 'Single Covered';
        objCP3.Project__c = objpr.Id;
        //insert objCP3;
        parkings.add(objCP3);
        
        objCP4 = new Car_Parking_Charge__c();
        objCP4.Status__c = 'Vacant';
        objCP4.Category__c = 'Additional';
        objCP4.Parking__c = 'Single Open';
        objCP4.Project__c = objpr.Id;
        //insert objCP4;
        parkings.add(objCP4);
        
        objCP5 = new Car_Parking_Charge__c();
        objCP5.Status__c = 'Vacant';
        objCP5.Category__c = 'Additional';
        objCP5.Parking__c = 'Stack';
        objCP5.Project__c = objpr.Id;
        //insert objCP5;
        parkings.add(objCP5);
        insert parkings;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        List<Opportunity> opps = new List<Opportunity>();
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Open';
        objcustomer.RW_Project_Unit__c=objPUU.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        //insert objcustomer;
        opps.add(objcustomer);
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Open';
        objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //insert objcustomer1;
        opps.add(objcustomer1);
        insert opps;
        
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Valid';
        q.Prepared_Date__c = System.today();
        q.Project__c = objpr.Id;
        q.Project_Unit__c = objPUU.Id;
        q.FloorNo__c = 11;
        q.Opportunity__c = objcustomer.Id;
        q.No_of_parking__c = 2;
        q.Appartment_Configuration__c = '1 BHK';
        q.Carpet_Area_Sq_Ft__c = 1200;
        q.Token_Amount__c =110000;
        q.ST_Token_Amount__c = 1000;
        q.Allow_booking_without_full_token__c = TRUE;
        q.Agreement_Value__c = 60422880;
        q.Agreement_Value_ST__c = 2537761;
        //q.Tandem_car_park_Additional__c = 1;
        //q.Tandem_Open_Additional__c= 1;
        //q.Single_car_park_Additional__c= 1;
        //q.Single_Open_Additional__c = 1;
        //q.Stack_Additional__c = 1;
        insert q;
        
        List<Receipt__c> receipts = new List<Receipt__c>();
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = objcustomer.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        //insert r1;
        receipts.add(r1);
        
        Receipt__c r2 = new Receipt__c();
        r2.Cheque_DD_Amount_Rs__c = 8400;
        r2.Cheque_DD__c = '9088881';
        r2.Cheque_DD_Date__c = system.today();
        r2.Project__c = objpr.Id;
        r2.Project_Unit__c = objPUU.Id;
        r2.Opportunity__c = objcustomer.Id;
        r2.CheckReceipt__c = true;
        r2.Physically_Cheque_Received__c = true;
        r2.Approval_Status__c = 'Approved';
        r2.Receipt_Date__c = system.today();
        r2.DraweeBank__c = 'CITI';
        r2.Total_Amount__c = 8400;
        r1.Currency__c = 'Indian Rupee';
        r2.Token_Amount_ST__c = true;
        //insert r2;
        receipts.add(r2);
        insert receipts;
        
        PageReference pRef = Page.BookingPageForm2;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('optyId',objCustomer.id);
        BookingClass bookC = new BookingClass();
        List < SelectOption > sq= bookC.getQuote;
        //   bookC.getQuoteStatus();
        bookC.selectedQuote = q.Id;
        bookC.getTokenAmount();
        bookC.getReceiptDetails();
        ////////////////////////////////////////////////////////////////
        //objBooking.Customer__c=objcustomer.id;
        //objBooking.Opportunity__c = objcustomer.id;
        ////////////////////////////////////////////////////////////////
        bookC.boookingObj.Application_No__c = '1234';
        bookC.boookingObj.Future_Correspondence_Contact__c = 'Other';
        bookC.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
        bookC.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
        bookC.applicant.Salutation__c = 'Mr.';
        bookC.applicant.Name = 'New Man';
        bookC.applicant.DOB__c = system.today();
        bookC.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
        bookC.applicant.Nationality__c = 'Indian';
        bookC.applicant.Pincode__c = 898900;
        bookC.applicant.Country__c = 'India';
        bookC.applicant.Mobile_Number__c = '909090900';
        bookC.applicant.Email_Address__c = 'newman@justnow.com';
        bookC.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
        bookC.applicant.Subtype_Of_Applicant__c = 'Indian National';
        bookC.applicant.Pancard__c = true;
      // commented by digicloud  bookC.ServiceTaxCheck = true;
        bookC.addReciept();
        bookC.save();
        
        
        PageReference pRef1 = Page.BookingPageForm2;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('optyId',objcustomer.id);
        ApexPages.currentPage().getParameters().put('unitId',objPUU.id);
        ApexPages.currentPage().getParameters().put('projectId',objpr.id);
        BookingClass bookC1 = new BookingClass();
        List < SelectOption > sq1= bookC1.getQuote;
        
        //  bookC1.getQuoteStatus();
        /* bookC1.getTokenAmount();
bookC1.getReceiptDetails();
bookC.addReciept();
// general required fields validation simulation
//bookC1.save();  
bookC1.selectedQuote = q.Id;
bookC1.save();  
bookC1.boookingObj.Application_No__c = '1234';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = 'Other';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact_Phone__c = '1234898989';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact_Email__c  = 'future@hereIcome.com';
bookC1.save();

// applicant1 to required fields validation simulation
bookC1.applicant.Salutation__c = 'Mr.';
bookC1.applicant.Name = 'New Man';
bookC1.applicant.DOB__c = system.today();
bookC1.applicant.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.applicant.Pincode__c = 89890;
bookC1.applicant.Country__c = 'India';
bookC1.applicant.Mailing_Country__c= 'India';
bookC1.applicant.Mobile_Number__c = '909090900';
bookC1.applicant.Email_Address__c = 'newman@justnow.com';
bookC1.applicant.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.applicant.Subtype_Of_Applicant__c = 'Indian National';
bookC1.applicant.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.applicant.Subtype_Of_Applicant__c = 'For NRI';
bookC1.applicant.Subtype_Of_Applicant__c = 'For Company';
bookC1.applicant.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.addressCheck = FALSE; 


// applicant2 to required fields validation simulation
bookC1.applicant2.Name = 'Second Man';
bookC1.applicant2.DOB__c = system.today();
bookC1.applicant2.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.applicant2.Pincode__c = 89890;
bookC1.applicant2.Country__c = 'India';
bookC1.applicant2.Mailing_Country__c= 'India';
bookC1.applicant2.Mobile_Number__c = '909090900';
bookC1.applicant2.Email_Address__c = 'newman@justnow.com';
bookC1.applicant2.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.applicant2.Subtype_Of_Applicant__c = 'Indian National';
bookC1.applicant2.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.applicant2.Subtype_Of_Applicant__c = 'For NRI';
bookC1.applicant2.Subtype_Of_Applicant__c = 'For Company';
bookC1.applicant2.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.addressCheckApplicant2 = FALSE;

// applicant3 to required fields validation simulation
bookC1.applicant3.Name = 'Second Man';
bookC1.applicant3.DOB__c = system.today();
bookC1.applicant3.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.applicant3.Pincode__c = 89890;
bookC1.applicant3.Country__c = 'India';
bookC1.applicant3.Mailing_Country__c= 'India';
bookC1.applicant3.Mobile_Number__c = '909090900';
bookC1.applicant3.Email_Address__c = 'newman@justnow.com';
bookC1.applicant3.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.applicant3.Subtype_Of_Applicant__c = 'Indian National';
bookC1.applicant3.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.applicant3.Subtype_Of_Applicant__c = 'For NRI';
bookC1.applicant3.Subtype_Of_Applicant__c = 'For Company';
bookC1.applicant3.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.addressCheckApplicant3 = FALSE;

Test.startTest();
// applicant4 to required fields validation simulation
bookC1.applicant4.Name = 'Second Man';
bookC1.save(); 
bookC1.applicant4.DOB__c = system.today();
bookC1.save();
bookC1.applicant4.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant4.Pincode__c = 89890;
bookC1.save();
bookC1.applicant4.Country__c = 'India';
bookC1.save();
bookC1.applicant4.Mailing_Country__c= 'India';
bookC1.save();
bookC1.applicant4.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant4.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant4.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant4.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheckApplicant4 = FALSE;
bookC1.save();


// applicant5 to required fields validation simulation
bookC1.applicant5.Name = 'Second Man';
bookC1.save();
bookC1.applicant5.DOB__c = system.today();
bookC1.save();
bookC1.applicant5.Permanent_Address__c = 'Pike Street, New World, 45000';
bookC1.save();
bookC1.applicant5.Pincode__c = 89890;
bookC1.save();
bookC1.applicant5.Country__c = 'India';
bookC1.save();
bookC1.applicant5.Mailing_Country__c = 'India';
bookC1.save();
bookC1.applicant5.Mobile_Number__c = '909090900';
bookC1.save();
bookC1.applicant5.Email_Address__c = 'newman@justnow.com';
bookC1.save();
bookC1.applicant5.Type_Of_Applicant__c  = 'Individual Buyer';
bookC1.save();
bookC1.applicant5.Subtype_Of_Applicant__c = 'Indian National';
bookC1.save();
bookC1.applicant5.Subtype_Of_Applicant__c = 'Foreign Nationals Of Indian Origin';
bookC1.save();
bookC1.applicant5.Subtype_Of_Applicant__c = 'For NRI';
bookC1.save();
bookC1.applicant5.Subtype_Of_Applicant__c = 'For Company';
bookC1.save();
bookC1.applicant5.Subtype_Of_Applicant__c = 'Partnership Firm';
bookC1.save();
bookC1.addressCheckApplicant5 = FALSE;
bookC1.save();

////////////////////////////////////////////////////////////////////
bookC1.boookingObj.Future_Correspondence_Contact__c = '1st Applicant';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = '2nd Applicant';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = '3rd Applicant';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = '4th Applicant';
bookC1.save();
bookC1.boookingObj.Future_Correspondence_Contact__c = '5th Applicant';
bookC1.save();*/
        
        ////////////////////////////////////////////////////////////////////
        Test.stopTest();
    }
    /*
@isTest 
private static void applicantdetailtest() {
Opportunity objcustomer1;
Booking__c objBooking;
Project__c objpr;
Project_Unit__c objPUU1;
Project_Unit_Type__c objPUT;

objpr = new Project__c();
objpr.RW_Project_Code__c = 'T31';
objpr.Name = 'TestProject';
objpr.RDS_Short_Name__c = 'T';
objpr.Start_Date__c = System.today().addDays(-5);
objpr.RDS_Interest_Rate__c = 12;
objpr.Service_Tax_Required_On_Token_Amount__c = true;
insert objpr;

objPUT = new Project_Unit_Type__c();
objPUT.RDS_Code__c = '101';
objPUT.RDS_Project__c = objpr.id;
insert objPUT;

objPUU1 = new Project_Unit__c();  
objPUU1.Project_Unit_Type__c = objPUT.id;  
objPUU1.Name = 'TestUnit1';      
objPUU1.RW_Project__c = objpr.Id;
objPUU1.RW_Param1__c = '5';
objPUU1.UnitNo__c ='10';
objPUU1.RW_Unit_Status__c ='Available';
insert objPUU1;

Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);

objcustomer1= new Opportunity();
objcustomer1.RW_Project__c=objpr.id;
objcustomer1.name='Test 1';
objcustomer1.StageName='Open';
objcustomer1.RW_Project_Unit__c=objPUU1.id;  
objcustomer1.CloseDate=system.today();
objcustomer1.Status__c ='Active';
objcustomer1.AccountId = a.Id;
insert objcustomer1;
// tower creation 
Tower__c t = new Tower__c();
t.Name = 'Tower X';
t.ProjectName__c = objpr.Id;
t = RDSCommon.CreateTower(t);

Quotation__c q = new Quotation__c();
q.Name = 'Q010101';
q.Quote_Status__c = 'Valid';
q.Prepared_Date__c = System.today();
q.Project__c = objpr.Id;
q.Project_Unit__c = objPUU1.Id;
q.FloorNo__c = 11;
q.Opportunity__c = objcustomer1.Id;
q.Appartment_Configuration__c = '1 BHK';
q.Carpet_Area_Sq_Ft__c = 1200;
q.Token_Amount__c =110000;
q.ST_Token_Amount__c = 1000;
q.Agreement_Value__c = 60422880;
q.Agreement_Value_ST__c = 2537761;
q.Agreement_Value_D__c = 10000;
q.Other_Charges_Amount_1__c = 1000;
q.Other_Charges_Amount_11__c = 1000;
q.Project_Maintenance_Charges_Amount_1__c = 1000;
q.Other_Charges_Amount_2__c = 1000;
q.Other_Charges_Amount_3__c = 1000;
q.Other_Charges_Amount_4__c  = 1000;
q.Other_Charges_Amount_6__c = 1000;
q.Other_Charges_Amount_7__c = 1000;
q.Other_Charges_Amount_8__c = 1000;
q.Other_Charges_Amount_9__c = 1000;
q.Other_Charges_Amount_14__c = 100;
q.Grand_Total_D__c = 100;
q.Grand_Total__c = 100;
insert q;

objBooking = new Booking__c();
objBooking.Code__c='1234';
objBooking.Reg_No__c='150224';
objBooking.Project__c=objpr.id;
objBooking.Direct__c=true;
objBooking.Broker_Code__c='A-022';
objBooking.Broker_Name__c=' Broker 1';
objBooking.Customer_Name__c='Client';
objBooking.Effective_From__c=system.today();
objBooking.Application_No__c='Ap-01';
objBooking.Status__c='Approved';
objBooking.MG_Effect_Date__c=system.today();
objBooking.MG_Per_Amt_Val__c=222;
objBooking.Customer__c=objcustomer1.id;
objBooking.UnitChange__c=true;
objBooking.Area__c='Noida';
objBooking.Remarks__c='Remarks';
objBooking.Cretaed_On__c=system.today();
objBooking.MG_Months_Year__c='jan-15';
objBooking.MG_Mon_Year_Val__c=50;
objBooking.Unit_No__c=objPUU1.Id;
objBooking.Advance_Registration_Reference_No__c='R-01';
objBooking.Sharing_Per_Amt__c='1000.00';
objBooking.MG_Per_Amt__c='2000.00';
objBooking.Sharing_Per_Amt_Val__c=1400.00;
objBooking.Quotation__c = q.Id;
objBooking.Future_Correspondence_Contact__c = 'First Applicant';
objBooking.Status__c = 'Booking In Process';
objBooking.Opportunity__c = objcustomer1.id;
//objBooking.ownerId = a1.id;
insert objBooking;

// construction stage creation
// two stages are being created
Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
objPCS.Project__c = objpr.Id;
objPCS.Name = 'Commencement of Raft/Foundation';
objPCS.Code__c ='Test';
objPCS.Description__c='Commencement of Raft/Foundation';
objPCS.Planned_date_of_completion__c = System.today().addDays(365);
objPCS.Tower__c = t.Id;
insert objPCS;

// payment plan creation associated to the construction stages
Payment_Plan__c objPaymentPlan = new Payment_Plan__c(); 
objPaymentPlan.Name ='Pay Plan 1';
objPaymentPlan.Project__c = objpr .Id;
objPaymentPlan.Tower__c = t.Id;
insert objPaymentPlan;

// global charges creation
Global_Charges__c ObjGloChrg = new Global_Charges__c();
ObjGloChrg.Name = 'Basic';
ObjGloChrg.Code__c = '011';
ObjGloChrg.Description__c = 'Basic';
ObjGloChrg.Sequence_No__c = 99;
ObjGloChrg.Charge_Type__c = 'Basic';
ObjGloChrg.Nature_of_Charge__c = 'Debtors';
ObjGloChrg=RDSCommon.CreateGlobalCharges(ObjGloChrg);

Project_Charges__c PCharge = new Project_Charges__c();
PCharge.Charge_Code__c = ObjGloChrg.Id;
PCharge.Project__c = objpr.Id;
PCharge.Name = 'Basic';
PCharge.Active__c = true;
PCharge.Applied_This_Charge_To_FA__c = true;
PCharge.S_Charge_Calculated_As__c = 'Rate List at Unit Level';
PCharge.S_Charge_Bucket__c = 'Agreement Value';
PCharge.S_Payable_At__c = 'As per payment milestone';
PCharge.Payment_Plan_Applicable__c = true;
pCharge.Service_Tax_Percentage__c = 'Service Tax 1';
pCharge.Service_Tax_Applicable_on_this_charge__c = true;
PCharge=RDSCommon.CreateProjectCharges(PCharge);

Rate_List_Header__c objRlh = new Rate_List_Header__c();
objRlh.Name = 'Basic RL Header';
objRlh.Project__c = objpr.Id;
objRlh.Project_Charges__c = PCharge.Id;
objRlh.Rate_list__c = 'All Charges';
objRlh.Effective_From__c = system.today().addDays(-3);
objRlh=RDSCommon.CreateRateListHeader(objRlh);

Rate_List__c objRL = new Rate_List__c();
objRL.Rate_List_HeaderID__c = objRlh.Id;
objRL.Project__c = objpr.Id;
objRL.Global_Charges__c = ObjGloChrg.Id;
objRL.Project_Charges__c = PCharge.Id;
objRL.Project_Unit__c = objPUU1.Id;
objRL.Value__c = 2218;
objRL.Rate__c = 23600;
//objRL.Rate_List_Detail__c = objRLd.id;
objRL=RDSCommon.CreateRateList(objRL);

// standard payment plan header creation
Standard_Pay_Plan_Header__c objSPP = new Standard_Pay_Plan_Header__c();
objSPP.Project__c = objpr.Id;
objSPP.Charge_Code__c= PCharge.Id;
objSPP.Payment_Plan__c=objPaymentPlan.id;
objSPP.Name='Basic Header';
objSPP.Plan_Code__c= '89';
objSPP.tower__c = t.ID;
objSPP.Effective_from__c = System.today();
objSPP=RDSCommon.CreateStandardPayPlanHeader(objSPP);

Customer_Pay_Plan_Header__c objCPPH = new Customer_Pay_Plan_Header__c();
objCPPH.Amount__c=1000000.00;
objCPPH.Customer__c=objcustomer1.id; 
objCPPH.Effect_From_Date__c=system.today(); 
objCPPH.Global_Charges__c=ObjGloChrg.id; 
objCPPH.Project__c=objpr.id; 
objCPPH.Project_Unit__c=objPUU1.id; 
objCPPH.Standard_Pay_Plan_Header__c=objSPP.id;
objCPPH.tower__c = t.ID;
objCPPH.Quotation__c = q.id;
objCPPH.PlanDt__c=system.today();
objCPPH.Booking__c = objBooking.id;
insert objCPPH;

Standard_Customer_Pay_Plan_Detail__c    objSPPD4 = new Standard_Customer_Pay_Plan_Detail__c();
objSPPD4.Standard_Pay_Plan_Header__c = objSPP.id;
objSPPD4.Project__c=objpr.id;
objSPPD4.tower__c = t.ID;
objSPPD4.Is_to_be_Paid__c='From Dt. of Booking';
objSPPD4.Days_Months__c='Day(s)';
objSPPD4.Days_Months_Value__c=0;
objSPPD4.Amount__c='Amount';
objSPPD4.Calculate_Installment_Amount_as__c=10;
objSPPD4.Total_Charge_Value_Minus__c = 110000;
objSPPD4.Customer_Pay_Plan_Header__c = objCPPH.Id;
objSPPD4= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD4);

Standard_Customer_Pay_Plan_Detail__c    objSPPD2 = new Standard_Customer_Pay_Plan_Detail__c();
objSPPD2.Standard_Pay_Plan_Header__c = objSPP.id;
objSPPD2.Project__c=objpr.id;
objSPPD2.tower__c = t.ID;
objSPPD2.Is_to_be_Paid__c='Construction Stage';
objSPPD2.Days_Months__c='Day(s)';
objSPPD2.Project_Construction_Stages__c=objPCS.id;
objSPPD2.Days_Months_Value__c=5;
objSPPD2.Amount__c='Percentage';
objSPPD2.Amount_Value__c=40;
objSPPD2.Installment__c = 102;
objSPPD2.Customer_Pay_Plan_Header__c = objCPPH.Id;
objSPPD2= RDSCommon.CreateCustomerPayPlanHeaderDetail(objSPPD2);






Test.startTest(); 



Applicant_Details__c ad1 = new Applicant_Details__c();
ad1.Name = 'A One';
ad1.Type_Of_Applicant__c = 'Individual Buyer';
ad1.Subtype_Of_Applicant__c = 'Indian National';
ad1.One_Passport_Size_Color_Photograph__c = true;
ad1.Permanent_Address__c = 'Perma Addressia';
ad1.Mailing_Address__c = 'Perma Addressia';
ad1.Organization_Address__c = 'Perma Addressia';
ad1.Organisation_Pincode__c = 123456;
ad1.Organisation_Country__c = 'India';
ad1.Email_Address__c = 'a1.one@gmail.com';
ad1.Mobile_Number__c = '989898989';
ad1.DOB__c = system.today().addMonths(-12);
ad1.Booking__c = objBooking.Id;
ad1.Applicant_Number__c = 'Primary Applicant';
insert ad1;

Applicant_Details__c ad2 = new Applicant_Details__c();
ad2.Name = 'A Four';
ad2.Type_Of_Applicant__c = 'Individual Buyer';
ad2.Subtype_Of_Applicant__c = 'Indian National';
ad2.One_Passport_Size_Color_Photograph__c = true;
ad2.Permanent_Address__c = 'Perma Addressia';
ad2.Email_Address__c = 'a2.one@gmail.com';
ad2.Mobile_Number__c = '8080808080';
ad2.DOB__c = system.today().addMonths(-12);
ad2.Booking__c = objBooking.Id;
insert ad2;

// tax slabs creation
Tax_Slab__c taxS = new Tax_Slab__C();
taxS.name = 'GST';
taxS.From_Date__c = System.today().addDays(-10);
taxS.Percentage__c = 12;
taxS = RDSCommon.CreateTaxSlab(taxS);
ApexPages.StandardController sc = new ApexPages.StandardController(q);

CostsheetViewController csv = new CostsheetViewController(sc);
test.stopTest();
}      */
    // creates  a person account with the basic parameters
    public static Account createPATemplate(String accName, String Email, String Mobile, Boolean isMaster) {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(lastName=accName, personEmail = email, personMobilePhone= Mobile, RecordType = personAccountRecordType, MasterRecord__c = isMaster);
        insert a;
        return a;
    }
    
    public static Project__c createProject(String ProjName, String ProjectCode)
    {
        Project__c objProject = new Project__c(Name = ProjName);
        insert objProject;
        return objProject;
    }
    
    // the parameters are set to match the project parameters to fulfill the data needs for opportunity rating calculation
    public static List<Opportunity> createOpptyForAccount(Id  accId, Id ProjId, Integer numOfOpp){
        List<Opportunity> oList = new List<Opportunity>();
        Date closeDate; 
        for(Integer i =0;i<numOfOpp; i++){
            closeDate = Date.newInstance(2015, 8,29);
            Opportunity o = new Opportunity(Name = 'Opp-'+i, StageName='Qualification', Amount=5000000, AccountId =accId, Status__c ='Active', LeadSource = 'Direct', Lead_Sub_source__c = 'Cross Project', RW_Project__c = ProjId,closeDate=System.today()); //S_Budget_In_lacs__c = 5000000,
            oList.add(o);            
        }
        insert oList;
        return oList;
    }
    
    public static List<Lead> createLead(Integer numofLeads) {
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<numofLeads;i++) 
        {
            
            Lead l = new Lead(firstName = 'first' , lastName='radiusLead' + i, Email='radiuslead' +i +'@radiustest.com' , RW_Mobile_No__c='123456789' + i, RW_Location__c = 'Airoli');
            
            leads.add(l);
        }
        insert leads;
        return leads;  
    }
    
    public static List<Task> createTasksForOpp(Id oppId, Integer NumberofTasks, String TaskType) {
        List<task> tList = new List<task>();
        for(Integer i=0; i<NumberofTasks; i++){
            task t = new Task(Subject = 'New Task' + i, Task_Type__c = TaskType, activityDate=System.Today(), whatId = oppId, call_time__c = TaskManagementServices.FormatTime(system.now()) );
            tList.add(t);
        }
        insert tList;
        return tList;
    }
    
    public static Lead createLeadTemplate(String lastName, String email, String mobile, Boolean isMaster) {
        Lead l = new Lead(firstName ='first', lastName= lastName, Email= email , RW_Mobile_No__c= mobile, MasterRecord__c = isMaster, RW_Location__c = 'Airoli');
        insert l;
        return l;  
    }
    
    public static Lead convertLead(Lead l) {
        LeadStatus convertStatus = [
            select MasterLabel
            from LeadStatus
            where IsConverted = true
            limit 1
        ];
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        if (!l.isConverted) {
            Database.LeadConvert lc = new Database.LeadConvert();
            String oppName = l.Name;
            lc.setLeadId(l.Id);
            lc.setOpportunityName(oppName);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            leadConverts.add(lc);
        }
        if (!leadConverts.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(leadConverts);
        }
        lead clead = [Select Id, ConvertedAccountId, ConvertedOpportunityId, IsConverted from Lead where id = :l.Id];
        return clead;
    }
    
    
    
    
}