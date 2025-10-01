@isTest
public class ClonePaymentPlanTest {
    
    @isTest static void clonePlan(){
        
        
        UserRole obj=new UserRole(Name= 'ABC'); 
                                           insert obj;
            
            Profile p1 = [Select Id, Name from Profile where Name = 'System Administrator'];

              /*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
              insert u;*/
        
        String orgId1 = UserInfo.getOrganizationId();
    String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
    String uniqueName1 = orgId1 + dateString1 + randomInt1;
    User tuser1 = new User(  firstname = 'TestUser',
                            lastName = 'TestUser',
                            email = uniqueName1 + '@gmail' +'.com',
                            Username = uniqueName1 + '@test' + orgId1 + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName1.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = p1.id,
                            UserRoleId = obj.Id
                            );
         insert tuser1;
            
         List<User> u1 = [Select id from User where firstname='TestUser'];
        system.runAs(u1[0])
        {    
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
        objAcc.OwnerId = tuser1.Id;
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
        system.debug('*1*');
        //Inserting Project
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
        System.debug('objpr: ' + objpr);
        
        Tower__c tr = new Tower__c();
        tr.Name = 'Test Tower';
        tr.ProjectName__c = objpr.Id;
        insert tr;

        Payment_Plan__c plan = new Payment_Plan__c();
        plan.Name = 'Test Plan';
        plan.Project__c = objpr.Id;
        plan.Plan_Code__c = '001';
        plan.Tower__c = tr.Id;
        insert plan;
        System.debug('plan: ' + plan);
            
        Standard_Pay_Plan_Header__c header = new Standard_Pay_Plan_Header__c();
        header.Project__c = objpr.Id;
        header.Plan_Code__c = plan.Plan_Code__c;
        header.Payment_Plan__c = plan.Id;
        header.Tower__c = tr.Id;
        insert header;
        System.debug('header: ' + header);
            
        
            
          
           
        Standard_Customer_Pay_Plan_Detail__c scppd1 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd1.Standard_Pay_Plan_Header__c = header.Id;
        scppd1.Tower__c = tr.Id;
        scppd1.Is_to_be_Paid__c = 'From Dt. of Booking';
        scppd1.Project__c = objpr.Id;
        insert scppd1;
        System.debug('scppd1: ' + scppd1);
            
        Standard_Customer_Pay_Plan_Detail__c scppd2 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd2.Standard_Pay_Plan_Header__c = header.Id;
        scppd2.Tower__c = tr.Id;
        scppd2.Is_to_be_Paid__c = 'From Dt. of Registration';
        scppd2.Project__c = objpr.Id;
        insert scppd2;
        System.debug('scppd2: ' + scppd2);
            
        Standard_Customer_Pay_Plan_Detail__c scppd3 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd3.Standard_Pay_Plan_Header__c = header.Id;
        scppd3.Tower__c = tr.Id;
        scppd3.Is_to_be_Paid__c = 'Registration';
        scppd3.Project__c = objpr.Id;
        insert scppd3;
        System.debug('scppd3: ' + scppd3);
            
        Project_Construction_Stages__c objPCS = new Project_Construction_Stages__c();
         objPCS.Project__c = objpr.Id;
         objPCS.Name = 'Commencement of Raft/Foundation';
         objPCS.Code__c ='Test';
         objPCS.Description__c='Commencement of Raft/Foundation';
         objPCS.Planned_date_of_completion__c = System.today().addDays(365);
         objPCS.Tower__c = tr.Id;
         objPCS.Sequence_No__c = 1;
         insert objPCS;
            
        Standard_Customer_Pay_Plan_Detail__c scppd4 = new Standard_Customer_Pay_Plan_Detail__c();
        scppd4.Standard_Pay_Plan_Header__c = header.Id;
        scppd4.Tower__c = tr.Id;
        scppd4.Is_to_be_Paid__c = 'Construction Stage';
        scppd4.Project__c = objpr.Id;
        scppd4.Project_Construction_Stages__c = objPCS.Id;
        insert scppd4;
        System.debug('scppd4: ' + scppd4);
            
        Payment_Plan__c clnPlan = plan.clone(false, true, false,false);
        clnPlan.Plan_Code__c = '002';
        clnPlan.Project__c = objpr.Id;
        clnPlan.Tower__c = tr.Id; 
        insert clnPlan;
            
        
            
        }
    }
}