@isTest
public class ReceiptTriggerTest {
    
    @isTest
    public static void receiptTest1(){
        
        Test.StartTest();
        Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
        Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
        opp.Applicant_Name__c='XYZ';
        opp.RW_Sales_Associate__c='A Aastha Tripathi';
        insert opp;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        
        Relationship_Manager__c rms = new Relationship_Manager__c();
        rms.User__c = rm.id;
        rms.Project__c = objpr.id;
        rms.Tower__c = towerRec.id;
        insert rms;      
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.Relationship_Manager__c = rms.id;
        objPUU1.TowerName__c = towerRec.Id;
        insert objPUU1;
        
        Booking__c  objBooking1=new Booking__c();
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
        objBooking1.OwnerId = rm.Id;
        insert objBooking1;
        
        Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        insert teamMembers;
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=opp.id;
        eoiRecord.Tower__c = towerRec.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.OwnerId = rm.Id;
        insert eoiRecord;
        
        Receipt__c receipt1 = new Receipt__c();
        receipt1.Opportunity__c=opp.id;
        receipt1.Booking__c=objBooking1.Id;
        receipt1.Payment_Gateway__c = 'BillDesk';
        receipt1.Receipt_Status__c = 'Success';
        receipt1.RW_Payment_Collection_Type__c = 'Customer Portal - Flat Cost';
        receipt1.Amount_Rs__c=500000.00;
        receipt1.Total_Amount__c=999999;
        receipt1.Cheque_DD__c='U1237062533345';
        receipt1.Mode__c='Digital';
        receipt1.Receipt_Date__c = system.today();
        insert receipt1;
        
        Receipt__c receipt2 = new Receipt__c();
        receipt2.Opportunity__c=opp.id;
        receipt2.Booking__c=objBooking1.Id;
        receipt2.EOI__c=eoiRecord.id;
        receipt2.RW_Payment_Refunded__c=true;
        receipt2.Payment_Gateway__c = 'BillDesk';
        receipt2.Receipt_Status__c = 'Success';
        receipt2.RW_Payment_Collection_Type__c = 'EOI';
        receipt2.Amount_Rs__c=500000.00;
        receipt2.Total_Amount__c=999999;
        receipt2.Cheque_DD__c='U1237062533345';
        receipt2.Mode__c='Digital';
        receipt2.Receipt_Date__c = system.today();
        receipt2.Cheque_DD_Date__c=system.today();
        receipt2.DraweeBank__c = 'Test Bank';
        insert receipt2;
        
        receipt2.Physically_Cheque_Received__c=  true;
        update receipt2;
        Test.StopTest();
    }
    
    @isTest
    public static void receiptTest2(){
        
        Test.StartTest();
        Project__c  objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'TestProject';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        Project_Unit_Type__c    objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777123',false);
        
        Opportunity opp= new Opportunity();
        opp.RW_Project__c=objpr.id;
        opp.name='Test ReceiptTrigger';
        opp.StageName='Qualification';
        opp.CloseDate=system.today();
        opp.Status__c ='Active';
        opp.AccountId = a.Id;
        opp.Sales_Manager__c = 'SM2@g.com';
        opp.Primary_Name__c='ABC';
        opp.Applicant_Name__c='XYZ';
        opp.RW_Sales_Associate__c='A Aastha Tripathi';
        insert opp;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        
        Relationship_Manager__c rms = new Relationship_Manager__c();
        rms.User__c = rm.id;
        rms.Project__c = objpr.id;
        rms.Tower__c = towerRec.id;
        insert rms;      
        
        Project_Unit__c objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnit1';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        objPUU1.Relationship_Manager__c = rms.id;
        objPUU1.TowerName__c = towerRec.Id;
        insert objPUU1;
        
        Booking__c  objBooking1=new Booking__c();
        objBooking1.Opportunity__c=opp.id;
        objBooking1.Unit_No__c=objPUU1.id;
        objBooking1.Project__c=objpr.id;
        objBooking1.OwnerId = rm.Id;
        insert objBooking1;
        
        Team__c teamRec = new Team__c();
        teamRec.Team_Type__c ='MIS';
        teamRec.Project__c = objpr.Id;
        insert teamRec;
        
        Team_Members__c teamMembers = new Team_Members__c();
        teamMembers.Team__c =teamRec.Id;
        teamMembers.Email_Id__c ='ishumittal5@gmail.com';
        insert teamMembers;
        
        RW_EOI__c eoiRecord = new RW_EOI__c();
        eoiRecord.Opportunity__c=opp.id;
        eoiRecord.Tower__c = towerRec.id;
        eoiRecord.RW_Primary_First_Name__c = 'Test1';
        eoiRecord.RW_Primary_Last_Name__c='Test2';
        eoiRecord.RW_EOI_Acknowledgement_Sent_Date_Time__c = SYstem.now();
        eoiRecord.RW_Primary_Email__c = 'test@gmail.com';
        eoiRecord.RW_Status__c = 'EOI Cancelled - Refund pending';
        eoiRecord.RW_Mailing_Address_Line_1__c='Addr1';
        eoiRecord.RW_Mailing_Address_Line_2__c='Addr2';
        eoiRecord.RW_Mailing_Address_Line_3__c='Addr3';
        eoiRecord.RW_Mailing_Pin__c='675432';
        eoiRecord.RW_Mailing_City__c='Mumbai';
        eoiRecord.RW_Mailing_Country__c='India';
        eoiRecord.RW_Mailing_State__c='Maharashtra';
        eoiRecord.RW_Gender__c='Male';
        eoiRecord.RW_Type_Of_Applicant__c = 'Individual Buyer';
        eoiRecord.RW_Residential_Status__c='Indian National';
        eoiRecord.RW_Date_of_Birth__c = System.today().addDays(-40);
        eoiRecord.RW_Primary_PAN_Details__c = 'BHYTR5678H';
        eoiRecord.RW_Document_Proof__c = 'Aadhar Card';
        eoiRecord.RW_Document_Number__c = '187654356789876';
        eoiRecord.OwnerId = rm.Id;
        insert eoiRecord;
        
        Receipt__c receipt3 = new Receipt__c();
        receipt3.Opportunity__c=opp.id;
        receipt3.Booking__c=objBooking1.Id;
        receipt3.EOI__c=eoiRecord.id;
        receipt3.RW_Payment_Refunded__c=true;
        receipt3.Payment_Gateway__c = 'BillDesk';
        receipt3.Receipt_Status__c = 'Success';
        receipt3.RW_Payment_Collection_Type__c = 'Booking';
        receipt3.Cheque_DD_Date__c=system.today();
        receipt3.Amount_Rs__c=500000.00;
        receipt3.Total_Amount__c=999999;
        receipt3.Cheque_DD__c='U1237062533345';
        receipt3.Mode__c='Digital';
        receipt3.Receipt_Date__c = system.today();
        insert receipt3;
        
        Receipt__c receipt4 = new Receipt__c();
        receipt4.Opportunity__c=opp.id;
        receipt4.Booking__c=objBooking1.Id;
        receipt4.EOI__c=eoiRecord.id;
        receipt4.Payment_Gateway__c = 'BillDesk';
        receipt4.Receipt_Status__c = 'Success';
        receipt4.RW_Payment_Collection_Type__c = 'SAP Demands';
        receipt4.Cheque_DD_Date__c=system.today();
        receipt4.Amount_Rs__c=500000.00;
        receipt4.Total_Amount__c=999999;
        receipt4.Cheque_DD__c='U1237062533345';
        receipt4.Mode__c='Digital';
        receipt4.Receipt_Date__c = system.today();
        insert receipt4;
        
        Test.StopTest();
    }
}