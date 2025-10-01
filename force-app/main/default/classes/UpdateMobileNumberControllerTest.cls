@isTest
public class UpdateMobileNumberControllerTest {
    
    @isTest
    public static void mobileNumUploadTest(){
        Account objAcc = new Account();
        objAcc.FirstName ='TestAccount11';
        objAcc.LastName ='TestAccount22';
        objAcc.PersonEmail = 'wc@email.com';
        objAcc.Mobile_No__c = '9876543212';
        insert objAcc;
        
        Opportunity oppRec= new Opportunity();
        oppRec.name='Test 1';
        oppRec.StageName='Unit Booked';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = objAcc.Id;
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
        oppRec.Overall_CRM_Head__c = UserInfo.getUserId();
        oppRec.TL_Name__c = UserInfo.getUserId();
        oppRec.RW_RM_Name__c = 'Aliya Kirkire';
        insert oppRec;
        
        Lead objLead = new Lead();
        objLead.LastName = 'test';
        objLead.Status = 'Not Sure';
        objLead.Email = 'test@gmail.com';
        objLead.Rating = 'Hot';
        objLead.MobilePhone = '1212121212';
        objLead.RW_Mobile_No__c = '1212121212';
        objLead.LeadSource = 'Corporate Company';
        objLead.Remark__c = 'test remark';
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        insert objLead;
        
        Test.startTest();
        UpdateMobileNumberController.updateMobileNumber(oppRec.Id, '9988776655', '9988776655', '+91', 'India');
        UpdateMobileNumberController.updateMobileNumber(objLead.Id, '9988776655', '9988776655', '+91', 'India');
        UpdateMobileNumberController.getCountryCodeList();
        UpdateMobileNumberController.getDialingCountryList();
        UpdateMobileAndEmailController.updateTLonOpportunity(new list<String>{oppRec.Id});        
        UpdateMobileAndEmailController.oppRecord(oppRec.Id);
        UpdateMobileAndEmailController.getCountryCodeList();
        UpdateMobileAndEmailController.getDialingCountryList();
        UpdateMobileAndEmailController.getSecondaryCountryCodeList();
        UpdateMobileAndEmailController.updateMobileNumber(oppRec.Id, '9988776655', '9988776655', '+91', 'India', 'test1@mail.com', 'test2@mail.com', '+91');
        UpdateMobileAndEmailController.updateOriginalFields(new List<String>{oppRec.Id});
        UpdateMobileAndEmailController.clearTempFields(new List<String>{oppRec.Id});
        Test.stopTest();
    }

}