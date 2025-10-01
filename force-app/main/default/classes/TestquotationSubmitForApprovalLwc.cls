@isTest
public class TestquotationSubmitForApprovalLwc {
@isTest
 public Static void quotationSubmitForApprovalLwc(){
     Opportunity objcustomer;
        Opportunity objcustomer1;
        Opportunity objcustomer2;
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
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
    
        
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
        
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
         
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 1';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
        Quotation__c q = new Quotation__c();
        q.Name = 'Q010101';
        q.Quote_Status__c = 'Approval Pending';
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
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Discount_Applied__c = true;
        q.Discount_9_Type__c = 'CP Passback';
        q.Level_One_Approver__c = userinfo.getUserId();
        q.Level_Two_Approver__c = userinfo.getUserId();
        
        insert q;
        
     
     
       
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'data.pdf',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink contentlink = New ContentDocumentLink();
        contentlink.LinkedEntityId = q.id;
        contentlink.ContentDocumentId = documents[0].Id;
        contentlink.shareType = 'V';
        insert contentlink;
        test.startTest();
        SubmitForApprovalQuotationLwc.CheckAttachment(contentlink.LinkedEntityId);
        SubmitForApprovalQuotationLwc.SendForApproval('test', q.id);
               
        test.stopTest();        
 }
   @isTest
 public Static void quotationReferralSubmitForApprovalLwc(){
     Opportunity objcustomer;
        Opportunity objcustomer1;
        Opportunity objcustomer2;
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
        objpr.RW_Project_Code__c = 'T32';
        objpr.Name = 'TestProject1';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
          
        objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '105';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
          
        objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id;  
        objPUU.Name = 'TestUnitData';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        insert objPUU;
        
        objPUU1 = new Project_Unit__c();  
        objPUU1.Project_Unit_Type__c = objPUT.id;  
        objPUU1.Name = 'TestUnitData';      
        objPUU1.RW_Project__c = objpr.Id;
        objPUU1.RW_Param1__c = '5';
        objPUU1.UnitNo__c ='10';
        objPUU1.RW_Unit_Status__c ='Available';
        insert objPUU1;
        
        objCP1 = new Car_Parking_Charge__c();
        objCP1.Status__c = 'Vacant';
        objCP1.Category__c = 'Additional';
        objCP1.Parking__c = 'Tandem Covered';
        objCP1.Project__c = objpr.Id;
        insert objCP1;
        
    
        
        Account a = TestDataFactory.createPATemplate('WC1 Account', 'wc1@email.com','90978777',false);
        
        objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 2';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SMM2@g.com';
         
        insert objcustomer;
        
        objcustomer1= new Opportunity();
        objcustomer1.RW_Project__c=objpr.id;
        objcustomer1.name='Test 3';
        objcustomer1.StageName='Qualification';
        //objcustomer1.RW_Project_Unit__c=objPUU1.id;  
        objcustomer1.CloseDate=system.today();
        objcustomer1.Status__c ='Active';
        objcustomer1.AccountId = a.Id;
        //objcustomer1.Duplicate_Project_Unit_Request__c = false;
        //objcustomer1.Release_Unit__c = false;
        insert objcustomer1;
      
        Quotation__c q = new Quotation__c();
        q.Name = 'Q01010101';
        q.Quote_Status__c = 'Approval Pending';
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
        q.Tandem_car_park_Additional__c = 0;
        q.Tandem_Open_Additional__c= 0;
        q.Single_car_park_Additional__c= 0;
        q.Single_Open_Additional__c = 0;
        q.Stack_Additional__c = 0;
        q.Discount_Applied__c = true;
        q.Discount_10_Type__c = 'Referral Passback';
        q.Level_One_Approver__c = userinfo.getUserId();
        q.Level_Two_Approver__c = userinfo.getUserId();
        
        insert q;
        
     
     
       
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'data.pdf',
            VersionData = Blob.valueOf('Test data'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink contentlink = New ContentDocumentLink();
        contentlink.LinkedEntityId = q.id;
        contentlink.ContentDocumentId = documents[0].Id;
        contentlink.shareType = 'V';
        insert contentlink;
        test.startTest();
        SubmitForApprovalQuotationLwc.CheckReferralPassback(contentlink.LinkedEntityId);
        SubmitForApprovalQuotationLwc.ReferralPassbackSendForApproval('test', q.id);
               
        test.stopTest();        
 }
}