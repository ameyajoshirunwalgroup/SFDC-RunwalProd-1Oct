@isTest
public class BookingFeedbackControllerTest {
	 @isTest
    private static void bookingFeedbackTest (){
        
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        //a.OwnerId=sitehead.Id;
        //a.RecordTypeId =recordTypeId1;
        insert a;
        
        
        Opportunity oppRec= new Opportunity();
        //oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        //objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        //objBking.Unit_No__c = objPUU.id;
        //objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        //objBking.Sales_Manager__c= salesmanager.Id;
        objBking.Status__c ='Booking Confirmed';
        insert objBking;
        
                
        test.startTest();
        pageReference pagRef = page.BookingFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        BookingFeedbackController cf = new BookingFeedbackController();
        cf.objId = objBking.Id;
        cf.cfObj.Customer_Experience__c = 'Good';
        cf.submitFeedback();
        test.stopTest();
    }
    
    @isTest
    private static void caseFeedbackTest (){
        
        Account a = new Account();
        a.FirstName ='TestAccount1';
        a.LastName ='TestAccount2';
        a.PersonEmail = 'wc@email.com';
        a.City__c='TestCity';
        a.RW_Zip_Code__c = '999999';
        a.State__c ='Karnataka';
        a.Country__c ='India';
        a.Mobile_No__c = '9876543212';
        a.Alternate_Email__c = 'wc1@email.com';
        a.Gender__c='Male';
        a.Salutation = 'Mr.';
        a.Birth_Date__c = System.today().addYears(-20);  
        //a.OwnerId=sitehead.Id;
        //a.RecordTypeId =recordTypeId1;
        insert a;
        
        
        Opportunity oppRec= new Opportunity();
        //oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        insert oppRec;
        
        Booking__c objBking = new Booking__c();
        objBking.Customer__c = oppRec.Id;
        //objBking.Project__c = objpr.Id;
        objBking.Opportunity__c = oppRec.Id;
        //objBking.Unit_No__c = objPUU.id;
        //objBking.Quotation__c = q.Id;
        //objBking.Receipts__c = r1.Id;
        objBking.Booking_Date__c = Date.today();
        //objBking.Sales_Manager__c= salesmanager.Id;
        objBking.Status__c ='Booking Confirmed';
        insert objBking;
        
        Case objCase = new Case();
        //objCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        objCase.AccountId = a.Id;
        //objCase.RW_Case_Comming_From_Portal__c = objUser.Id;
        //objCase.RW_Project__c = objProject.Id;
        objCase.RW_RM_Name__c = 'Chayan';
        objCase.Subject = 'testSubject';
        objCase.Description = 'testDescription';
        insert objCase;
        
        test.startTest();
        pageReference pagRef = page.BookingFeedbackForm;
        //System.currentPageReference().getParameters().put('objId', objBking.Id);
        test.setCurrentPage(pagRef);
        BookingFeedbackController cf = new BookingFeedbackController();
        cf.objId = objCase.Id;
        cf.cfObj.Customer_Experience__c = 'Good';
        cf.submitFeedback();
        test.stopTest();
    }
}