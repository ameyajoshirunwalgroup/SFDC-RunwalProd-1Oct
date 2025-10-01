@isTest
public class CustomerLedgerControllerTest {
    @isTest
    private static void testCustomerLedgerController(){
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();  
        //Inserting account
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        objAcc.RecordTypeID=recordTypeId ;
        objAcc.LastName ='TestAccount22';
        objAcc.PersonEmail = 'wc@email.com';
        objAcc.City__c='TestCity';
        objAcc.RW_Zip_Code__c = '9999999';
        objAcc.State__c ='Karnataka';
        objAcc.Country__c ='India';
        objAcc.Mobile_No__c = '9876543212';
        objAcc.Alternate_Email__c = 'wc1@email.com';
        objAcc.Gender__c='Male';
        objAcc.Salutation = 'Mr.';
        objAcc.Birth_Date__c = System.today().addYears(-20); 
        //objAcc.OwnerId = tuser1.Id;
        insert objAcc;
        
        Account acc = [Select Id,PersonEmail,PersonContactId From Account Where Id = :objAcc.Id];
        
        Profile p = [Select Id, Name from Profile where Name = 'Runwal Customer Portal'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'TestUser1',
                              lastName = 'TestUser2',
                              email = uniqueName + '@gmail' +'.com',
                              contactId=acc.PersonContactId,
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = p.id
                             );
        insert tuser;
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        objpr.RW_Project_Location_Videos_Link__c='test';
        objpr.RW_Project_Brochure_PublicUrl__c='test1';
        objpr.RW_SAP_Company_Code__c='5245';
        insert objpr;
        
        Tower__c objTower = new Tower__c();
        objTower.ProjectName__c = objpr.id;
        objTower.Name = 'A';
        objTower.SAP_Plant_Code__c = '111';
        objTower.RW_Terms_And_Conditions__c ='TC';
        insert objTower;
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=acc.PersonEmail;
        //oppRec.StageName='Qualification';
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = acc.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_CUstomer_Number__c='0020009875';
        oppRec.SalesOrder_Number__c ='3262627';
        oppRec.RW_Agreement_Value__c=13425663;
        oppRec.Booking_Feedback_Link__c='654864524';
        oppRec.Portal_Possession_Survey_Link_Id__c='6423874';
        oppRec.RW_Sourcing_Manager__c='Rohit Sharma';
        insert oppRec;
        
        Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = objTower.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser.Id;
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm; 
        
        Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = objTower.Id;
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
        objPUU.Relationship_Manager__c = ObjRm.Id;
        objPUU.Carpet_Area__c = 786;
        insert objPUU;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        objBking.Customer__c =oppRec.Id;
        objBking.Unit_No__c = objPUU.id;
        //objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today().addDays(-1);
        objBking.Sales_Manager__c= tuser.Id;
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
        
        List<Applicant_Details__c> appList = new List<Applicant_Details__c>();
        Applicant_Details__c apt1 = new Applicant_Details__c();
        apt1.Name = 'Applicant 1';
        apt1.First_Name__c='Test';
        apt1.Last_Name__c='Test2';
        apt1.Middle_Name__c='Test3';
        apt1.Permanent_Address__c = 'test address';
        apt1.Opportunity__c = oppRec.Id;
        apt1.Applicant_Number__c = 'Primary Applicant';
        apt1.Subtype_Of_Applicant__c = 'Indian National';
        apt1.Type_Of_Applicant__c= 'Individual Buyer';
        apt1.Booking__c = objBking.Id;
        apt1.DOB__c = Date.today();
        apt1.Office_Address_Line_1__c = 'Office Address Line 1';
        apt1.Mobile_Number__c = '1234567890';
        apt1.Email_Address__c = 'test@test.com';
        apt1.PancardNo__c = 'ABC123456';
        apt1.Address_Proof__c = true;
        apt1.Address_Proof_Document__c = 'Passport';
        apt1.PancardNo__c = 'abc213456';
        apt1.Address_Proof_Number__c='BLYTU0987Y';
        apt1.Type_Of_Origin__c='PIO card';
        apt1.Origin_Details__c='210';
        apt1.PassportNoDetails__c='A9876543';
        apt1.Pan_Card_Number_of_Authority_Signatory__c='NJHYT5678U';
        apt1.Permanent_Address_Line_1__c='test';
        apt1.Permanent_Address_Line_1__c='test1';
        apt1.Permanent_Address_Line_1__c='test2';
        apt1.Country__c='India';
        apt1.State__c='Maharashtra';
        apt1.City__c='Mumbai';
        apt1.Pincode__c=456789;
        appList.add(apt1);
        //insert apt1;
        
        Applicant_Details__c apt2 = new Applicant_Details__c();
        apt2.Name = 'Applicant 2';
        apt2.Permanent_Address__c = 'test address1';
        apt2.Opportunity__c = oppRec.Id;
        apt2.Applicant_Number__c = 'Second Applicant';
        apt2.Subtype_Of_Applicant__c = 'Indian National';
        apt2.Type_Of_Applicant__c= 'Individual Buyer';
        apt2.Booking__c = objBking.Id;
        apt2.DOB__c = Date.today();
        apt2.Office_Address_Line_1__c = 'Office Address Line 2';
        apt2.Mobile_Number__c = '1234567899';
        apt2.Email_Address__c = 'test1@test1.com';
        apt2.Address_Proof__c = true;
        apt2.Address_Proof_Document__c = 'Passport';
        apt2.gender__c = 'Female';
        apt2.Designation_picklist__c = 'Accounting';
        apt2.Occupation__c = 'Admin';
        apt2.PancardNo__c = 'abc213456';
        appList.add(apt2);
        insert appList;
        
        RW_Demand__c demandobj = new RW_Demand__c();
        demandobj.Due_Date__c = system.today();
        demandobj.Booking__c = objBking.Id;
        demandobj.RW_Billing_Document_Number__c='097654567';
        demandobj.RW_Customer_Number__c='002000056';
        demandobj.RW_Demand_Amount__c=2000;
        demandobj.Demand_Date__c= system.today();
        demandobj.RW_Demand_Status__c='Paid';
        demandobj.RW_ODN_Number__c='6666';
        demandobj.RW_Demand_Milestone__c='6437';
        insert demandobj;
        
        RW_Payment_Details__c payDet = new RW_Payment_Details__c();
        payDet.RW_Document_Type__c = 'DE';
        payDet.RW_Payment_Amount__c = 1000;
        payDet.RW_Accounting_Document_Number__c='857565';
        payDet.RW_Bank_Reference_Number__c='77777';
        payDet.RW_Branch_Name__c='Andheri';
        payDet.RW_Clearing_Document_Number__c='8888';
        payDet.RW_Company_Code__c ='1001';
        payDet.RW_Customer_ID__c='002000056';
        payDet.RW_Payment_Date__c=System.today();
        payDet.RW_Document_Type__c='Cheque';
        payDet.Opportunity__c =oppRec.id;
        payDet.RW_Booking__c=objBking.Id;
        payDet.RW_Company_Code__c='2000';
        payDet.RW_Fiscal_Year__c='2020';
        insert payDet;
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=oppRec.id;
        eoiRecord.Tower__c = objTower.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        insert eoiRecord;
        
        
        //List<User> u = [Select id from User where firstname='TestUser1'];
        system.runAs(tuser){
            CustomerLedgerController.getPortalHomeData();
            CustomerLedgerController.getPrincipalPayableAmount(1000000, 5000, 500000, 50000, 0);
            CustomerLedgerController.getGstPayableAmount(500000,500000,5000,0,550000);
            CustomerLedgerController.getCheckProjectTotalAmount(5000,0); 
        }
        
        Map<String,String> DetailMap=new Map<String,String>();         
        DetailMap.put('bookingId', objBking.Id);
        DetailMap.put('OpportunityId', oppRec.Id);
        DetailMap.put('towerId', objTower.Id);
        DetailMap.put('Amount', '100000');
        DetailMap.put('TypeOfAmount','Normal');
        DetailMap.put('ProjectUnit',objPUU.id);
        DetailMap.put('ButtonType','SinglePayment'); 
       CustomerLedgerController.getBillDeskData(DetailMap);
        
        Receipt__c r1 = new Receipt__c();
        r1.Cheque_DD_Amount_Rs__c = 200000;
        r1.Cheque_DD__c = '908888';
        r1.Cheque_DD_Date__c = system.today();
        r1.Project__c = objpr.Id;
        r1.Project_Unit__c = objPUU.Id;
        r1.Opportunity__c = oppRec.Id;
        r1.CheckReceipt__c = true;
        r1.Token_Amount_Receipt__c = true;
        r1.Physically_Cheque_Received__c = true;
        r1.Approval_Status__c = 'Approved';
        r1.Receipt_Date__c = system.today();
        r1.DraweeBank__c = 'Axis Bank';
        r1.Total_Amount__c = 200000;
        r1.Currency__c = 'Indian Rupee';
        r1.Booking__c=objBking.Id;
        insert r1;
        
        String name=r1.Name;
		Map<String,String>  SaveDetailMap=new Map<String,String>();
        SaveDetailMap.put('towerId',objTower.id);
        SaveDetailMap.put('msg','BDSKUATY|'+name +'|U1230002035462|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|22-07-2021 14:22:30|0300|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA|8E2A7079253D64E1954BED58D6CB089BBD85CFA138FE7E83A08C1328C4706F28' );
 		CustomerLedgerController.saveBillDeskData(SaveDetailMap); 
    }

}