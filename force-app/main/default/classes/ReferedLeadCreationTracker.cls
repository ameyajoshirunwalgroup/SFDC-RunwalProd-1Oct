@isTest
public class ReferedLeadCreationTracker {

static testmethod void ReferedLeadCreationTest() {


    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
  
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
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
        objpr.CRMHead__c = tuser.Id;
        objpr.Presales_TL__c = tuser.Id;
    	objpr.Loyalty_Head__c = tuser.Id;
        objpr.RW_LocalityName__c = 'test';
        objpr.Site_Address_Map_Link__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7'; 
        objpr.RW_Project_Brochure_PublicUrl__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7';
        objpr.RW_Project_Location_Videos_Link__c = 'https://goo.gl/maps/ZH6QR3jwP3k4d6Cz7';
       
        insert objpr;
    
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
        insert a;
    
        
        List<RW_Referral__c> reffList = new List<RW_Referral__c>();
        RW_Referral__c ref = new RW_Referral__c();
        //ref.RW_Project__c = objpr.Id;
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= objpr.Name;
        ref.Account__c = a.id;
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        reffList.add(ref);
        insert reffList;
        
    
        Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test1@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Reference';
        objLead.LeadSource = 'Digital';
        //objLead.RW_Reference_Source__c = 'Existing Customer Reference';
        objLead.RW_Lead_Sub_Source__c = 'Existing client reference';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = a.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        objLead.RW_Mobile_No__c= '8000000123';
        objLead.RW_Referral_Lead__c= reffList[0].Id;
        //objLead.RW_Batch_Lead_Check__c = True;
        insert objLead;
    
  
       Team__c tem = new Team__c();
        tem.Name = 'Presales TL';
        tem.Project__c = objpr.Id;
        tem.Team_Type__c= 'Presales TL';
        insert tem;
        
        Team_Members__c temMbr = new Team_Members__c();
        temMbr.Team__c = tem.Id;
        temMbr.User__c = tuser.Id;
        temMbr.User_Active__c  =true;
        insert temMbr;
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
    Test.startTest();
    ReferedLeadCreation c = new ReferedLeadCreation();
    Database.executeBatch(c);
    Test.stopTest();

    Database.LeadConvert lc = new database.LeadConvert();  
    lc.setLeadId( objLead.Id );  
    lc.setDoNotCreateOpportunity( false );  
    lc.setConvertedStatus('Interested');  
    Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
    
    system.debug( 'Errors are ' + lcr.getErrors() );  
    
    system.debug( lcr.isSuccess() );
    
    
    objLead.Email = 'test@test.com';
    update objLead;
    //Added newly
    SendEmailWhatsAppToLeadsLimit__c setting = new SendEmailWhatsAppToLeadsLimit__c();
    setting.Name = 'SendEmailWhatsAppLimit';
    setting.Limit__c = 1000;
    insert setting;
    
    SendEmailWhatsAppToLeads leadBatch = new SendEmailWhatsAppToLeads();  
    Database.executeBatch(leadBatch);
    
    List<SendEmailWhatsAppToLeadsLimit__c> lstSendEmailWhatsAppToLeadsLimit = [SELECT Name,Limit__c FROM SendEmailWhatsAppToLeadsLimit__c];
    
    ScheduleEmailWhatsAppToLeads testsche1 = new ScheduleEmailWhatsAppToLeads();
    String sch1 = '0 0 23 * * ?';
    system.schedule('Test status Check1', sch1, testsche1 );
    
    //Ends here
    ReferedLeadCreation refLead = new ReferedLeadCreation();
    Database.executeBatch(refLead);
   
    //SendWhatsAppMsg.genaricMethodToSendWhatsAppMsg('param1', 'param2', 'param3', 'param4', 'param5', 'param6', 'param7','param8','param9', '8989898989', System.Label.Lead_Project_Content_HSM); //Commented by Vinay 29-08-2025
    
    SendWhatsAppOnNewLeadCreation.WhatsAppOnNewLeadCreation(new list<Id>{objLead.Id});
    
}
    
    static testmethod void ReferedLeadCreationTest1() {


    Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];
  
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName = orgId + dateString + randomInt;
    User tuser = new User(  firstname = 'TestUser1',
                            lastName = 'TestUser2',
                            email = uniqueName + orgId+ '@gmail' +'.com',
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
        objpr.CRMHead__c = tuser.Id;
        objpr.Presales_TL__c = tuser.Id;
        objpr.Loyalty_Head__c = tuser.Id;
        insert objpr;
    
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
        insert a;
    
        
        List<RW_Referral__c> reffList = new List<RW_Referral__c>();
        RW_Referral__c ref = new RW_Referral__c();
        //ref.RW_Project__c = objpr.Id;
        ref.RW_Status__c = 'Duplicate';
        ref.RW_First_Name__c ='Test';
        ref.RW_Last_Name__c='Lead';
        ref.RW_Email_Address__c='Test@test.com';
        ref.RW_Project__c= objpr.Name;
        ref.Account__c = a.id;
        ref.RW_Contact_Phone__c = '1221122100';
        ref.RW_Status__c = 'In Process';
        ref.RW_LeadCreated__c = false;
        ref.RW_Duplicate_Lead__c = false;
        reffList.add(ref);
        insert reffList;
        
    
        Lead objLead = new Lead();
        objLead.LastName = 'testLast';
        objLead.Email = 'test1@test.com';
        objLead.RW_Mobile_No__c = '1221122100';
        objLead.Remark__c = 'testRemark';
        objLead.RW_Project__c = objpr.Id;
        objLead.RW_Rating__c = 'Hot';
        objLead.Lead_Source__c = 'Reference';
        objLead.LeadSource = 'Digital';
        //objLead.RW_Reference_Source__c = 'Existing Customer Reference';
        objLead.RW_Lead_Sub_Source__c = 'Existing client reference';
        objLead.Status = 'Not Sure';
        objLead.Customer_Reference__c = a.Id;
        objLead.Country__c = 'India';
        objLead.State__c = 'Odisha';
        objLead.City__c = 'Bhubaneshwar';
        objLead.RW_Budget__c = '< 1Cr';
        objLead.RW_Configuration__c = '1.5 BHK';
        objLead.RW_Location__c = 'MANGLAUR';
        objLead.RW_Time_line__c = 'Ready Possession';
        //objLead.RW_Mobile_No__c= '8000000123';
        objLead.RW_Referral_Lead__c= reffList[0].Id;
        insert objLead;
    
       
       Team__c tem = new Team__c();
        tem.Name = 'Presales TL';
        tem.Project__c = objpr.Id;
        tem.Team_Type__c= 'Presales TL';
        insert tem;
        
        Team_Members__c temMbr = new Team_Members__c();
        temMbr.Team__c = tem.Id;
        temMbr.User__c = tuser.Id;
        temMbr.User_Active__c  =true;
        insert temMbr;
    
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
    Test.startTest();
    ReferedLeadCreation c = new ReferedLeadCreation();
    Database.executeBatch(c);
    Test.stopTest();

    Database.LeadConvert lc = new database.LeadConvert();  
    lc.setLeadId( objLead.Id );  
    lc.setDoNotCreateOpportunity( false );  
    lc.setConvertedStatus('Interested');  
    Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
    
    system.debug( 'Errors are ' + lcr.getErrors() );  
    
    system.debug( lcr.isSuccess() );
    
    
    objLead.Email = 'test@test.com';
    update objLead;
    ReferedLeadCreation refLead = new ReferedLeadCreation();
    
    Database.executeBatch(refLead);
    
   
}
 public static testMethod void testschedule2() {
        Test.StartTest();
     

    	ScheduleReferedLeadCreation testsche = new ScheduleReferedLeadCreation();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        
    
        Test.stopTest();
    }
    

}