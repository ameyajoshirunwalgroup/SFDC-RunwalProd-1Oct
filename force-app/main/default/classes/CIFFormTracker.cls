@isTest
 public class CIFFormTracker {
     @isTest
         private static void cifsearchPagetest () {
             project__c p = createProject();
             Lead l1 = createleadTemplate1();
             Account a = createPAAccount();
             Opp_Close_Date__c dt = new Opp_Close_Date__c();
             dt.Project_Name__c = 'test';
             dt.Name = p.Id;
             dt.No_of_Days__c = 45;
             insert dt;
             Opportunity o = createOpp(a.Id,p.Id);
             Otp__c otp =validateotp(l1.id,p.Id);
           CIFFormPageController.dummyMethod();
           CIFSearchPageController.dummy();
             
             
             
             test.startTest();
                 pageReference pageRef = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef);
                 CIFSearchPageController cifSearch = new CIFSearchPageController();
                 cifSearch.strProjectId = p.Id;
                 cifSearch.NewLead.RW_Mobile_No__c = '1212121213';
                 cifSearch.NewLead.lastName = 'testlead';
                 cifSearch.NewLead.Email = 'testlead@test.in';
                 cifSearch.directLead();
                 cifSearch.submitOtp();

                 cifSearch.OpportunityId = o.Id;
                 cifSearch.saveMethod();
                 cifSearch.searchAllLead();
                 cifSearch.createEventOnDuplicateOpty();
                 CIFSearchPageController cifSearch1 = new CIFSearchPageController();
                 
                 cifSearch1.strProjectId = p.Id;
                 cifSearch1.NewLead.RW_Mobile_No__c = '1212121212';
                 cifSearch1.saveMethod();
                 cifSearch1.searchAllLead();
                 cifSearch1.createEventOnDuplicateOpty();
                 CIFSearchPageController cifSearch11 = new CIFSearchPageController();
                 Lead l = createleadTemplate1();
                 cifSearch11.strProjectId = p.Id;
                 //cifSearch1.NewLead.RW_Mobile_No__c = '1212121212';
                 cifSearch11.NewLead = l;
                 cifSearch11.saveMethod();
                 cifSearch11.searchAllLead();
                 cifSearch11.goBack();
             	 
                 //cifSearch11.createEventOnDuplicateOpty();
                 
                pageReference pageRef5 = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef5);
                 CIFSearchPageController cifSearch5 = new CIFSearchPageController();
                 cifSearch5.strProjectId = p.Id;
                 cifSearch5.NewLead.RW_Mobile_No__c = '';
                 cifSearch5.NewLead.lastName = '';
                 cifSearch5.NewLead.Email = '';
                 cifSearch5.OpportunityId = o.Id;
                 cifSearch5.saveMethod();
                 cifSearch5.searchAllLead();
                 cifSearch5.createEventOnDuplicateOpty();
             
              pageReference pageRef6 = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef6);
                 CIFSearchPageController cifSearch6 = new CIFSearchPageController();
                 cifSearch6.strProjectId = p.Id;
                 cifSearch6.NewLead.RW_Mobile_No__c = '12121ghg';
                 cifSearch6.NewLead.lastName = 'testlead';
                 cifSearch6.NewLead.Email = 'testlead@test';
                 cifSearch6.OpportunityId = o.Id;
                 cifSearch6.saveMethod();
                 cifSearch6.searchAllLead();
         
                 
               
             test.stopTest();
         }

        @isTest
         private static void cifsearchPagetest1 () {
             project__c p = createProject();
             //Lead l = createleadTemplate1();
             Account a = createPAAccount();
             //Opportunity o = createOpp(a.Id,p.Id);
             test.startTest();
                 pageReference pageRef = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef);
                 CIFSearchPageController cifSearch = new CIFSearchPageController();
                 cifSearch.strProjectId = p.Id;
                 cifSearch.NewLead.RW_Mobile_No__c = '1212121212';
                 cifSearch.NewLead.lastName = 'testlead';
                 cifSearch.NewLead.Email = 'testlead@test.in';
                 cifSearch.saveMethod();
                 cifSearch.searchAllLead();
             	 cifSearch.directLead();
             	 cifSearch.submitOtp();
                 
             test.stopTest();
         } 

         @isTest
         private static void cifsearchPagetest2 () {
             project__c p = createProject();
             //Lead l = createleadTemplate1();
             Account a = createPAAccount();
             Opp_Close_Date__c dt = new Opp_Close_Date__c();
             dt.Project_Name__c = 'test';
             dt.Name = p.Id;
             dt.No_of_Days__c = 45;
             insert dt;
             Opportunity o = createOpp(a.Id,p.Id);
             
             test.startTest();
                
                 
                pageReference pageRef5 = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef5);
                 CIFSearchPageController cifSearch5 = new CIFSearchPageController();
                 cifSearch5.strProjectId = p.Id;
                 cifSearch5.NewLead.RW_Mobile_No__c = '';
                 cifSearch5.NewLead.lastName = '';
                 cifSearch5.NewLead.Email = '';
                 cifSearch5.OpportunityId = o.Id;
                 cifSearch5.saveMethod();
                 cifSearch5.searchAllLead();
                 cifSearch5.createEventOnDuplicateOpty();
             
                 pageReference pageRef6 = page.CIFSearchPage;
                 Test.setCurrentPage(pageRef6);
                 CIFSearchPageController cifSearch6 = new CIFSearchPageController();
                 cifSearch6.strProjectId = p.Id;
                 cifSearch6.NewLead.RW_Mobile_No__c = '12121ghg';
                 cifSearch6.NewLead.lastName = 'testlead';
                 cifSearch6.NewLead.Email = 'testlead@test';
                  cifSearch6.directLead();
             cifSearch6.submitOtp();
                 cifSearch6.OpportunityId = o.Id;
                 cifSearch6.saveMethod();
                 cifSearch6.searchAllLead();
         

               
             test.stopTest();
         }     
         @isTest
         private static void cifMainformserachpageTest() {
             project__c p = createProject();
             Lead l = createleadTemplate1();
           //  Account a = createPAAccount();
             Opp_Close_Date__c dt = new Opp_Close_Date__c();
             dt.Project_Name__c = 'test';
             dt.Name = p.Id;
             dt.No_of_Days__c = 45;
             insert dt;
             //Opportunity o = createOpp(a.Id,p.Id);
            // Prospect__c pro= pros(l.Id,p.Id);
             OTP__c o1 =validateotp(l.Id,p.Id);
             
             test.startTest();
                 pageReference pageRef = page.CIFFormPage;
                 Test.setCurrentPage(pageRef);
                 ApexPages.currentPage().getParameters().put('id',l.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
             	// ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 ApexPages.currentPage().getParameters().put('directLead','true');
                 CIFFormPageController cifForm = new CIFFormPageController();
                 cifForm.CIFObj.Salutation__c ='Mr.';
                 cifForm.CIFObj.Marital_Status__c ='married';
                 cifForm.CIFObj.Ethnicity__c  = 'test';
                 //cifForm.CIFObj.BudgetIn_Cr__c=100;
                 cifForm.CIFObj.Configuration__c='test';
                 cifForm.CIFObj.TimeLine__c= 'Ready Possession';
                 cifForm.CIFObj.Source__c= 'Digital';
                 cifForm.CIFObj.Occupation__c ='test';
             cifForm.CIFObj.CompanyName__c ='test';
                 cifForm.CIFObj.No_of_Children__c= 1;
                 cifForm.CIFObj.Age_of_Child_1__c =string.valueOf(5);
                 cifForm.CIFObj.Configuration__c = '1.5 BHK';
                 cifForm.CIFObj.Purpose__C ='tset';
                 cifForm.CIFObj.Country__c= 'India';
                 cifForm.CIFObj.Spouse_Name__c  ='test';
                 cifForm.CIFObj.Preferred_Location__c = 'test';
                 cifForm.CIFObj.Type_of_Client__c= 'Local';			//Added by Sheetal on 26/04/2022
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=2;
                 cifForm.CIFObj.Age_of_Child_2__c= string.valueOf(10);
                 cifForm.strError='test';
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=3;
                 cifForm.CIFObj.Age_of_Child_3__c= string.valueOf(12);
                 cifForm.strError='test';
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=4;
                 cifForm.CIFObj.Age_of_Child_4__c= string.valueOf(16);
                 cifForm.strError='test';    
                 cifForm.redirectNext();
                 cifForm.strCurrentSource ='partner';
                 cifForm.validateLeadSource();
                 cifForm.strCurrentSource = '';
                 cifForm.validateLeadSource();
                 cifForm.CIFObj.Source__c ='';
                 cifForm.validateLeadSource();
                 cifForm.GoBackToLead();
                 cifForm.NoOtp();
              cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strAccountId = 'test';
              cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strOptyId = 'test';
              cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strotp = 'test';
                 cifForm.otpId = o1.Id;
                 cifForm.hide= false;
                 cifForm.checkbox= true;
                 cifForm.random = false;
                 cifForm.otpgeneratedfor ='test';
                // cifForm.OTPvalidate();
                 cifForm.strSpouseDOB = string.valueOf(system.now());
                 cifForm.changeLocality();
                 
               
                pageReference pageRef1 = page.CIFFormPage;
                 Test.setCurrentPage(pageRef1);
                 //ApexPages.currentPage().getParameters().put('optyid',o.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
             	 ApexPages.currentPage().getParameters().put('directLead','true');
                 CIFFormPageController cifForm1 = new CIFFormPageController();
                 cifForm1.CIFObj.Configuration__c='test';
                 cifForm1.redirectNext();
                 cifForm1.changeLocality();
                 
                 pageReference pageRef11 = page.CIFFormPage;
                 Test.setCurrentPage(pageRef11);
                // ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
             	 ApexPages.currentPage().getParameters().put('directLead','true');
                 CIFFormPageController cifForm11 = new CIFFormPageController();
                 cifForm11.CIFObj.Ethnicity__c = 'test';
                 cifForm11.CIFObj.BudgetIn_Cr__c = 100;
                 cifForm11.CIFObj.Preferred_Location__c = 'test';
                 cifForm11.CIFObj.Configuration__c = '1.5 BHK';
                 cifForm11.CIFObj.TimeLine__c = 'Ready Possession';
                 cifForm11.CIFObj.Source__c = 'Digital';
                 cifForm11.CIFObj.Salutation__c ='Ms';
                 cifForm11.CIFObj.Occupation__c = 'test';
             cifForm11.CIFObj.CompanyName__c= 'Test';
                 cifForm11.CIFObj.Marital_Status__c ='married';
                 cifForm11.CIFObj.No_of_Children__c= 1;
                 cifForm11.CIFObj.Age_of_Child_1__c= string.valueOf(5);
                 cifForm11.CIFObj.Configuration__c ='test';
                 cifForm11.CIFObj.Purpose__C='tset';
                 cifForm11.CIFObj.Country__c = 'NRI';
                 cifForm11.CIFObj.Spouse_Name__c='test';
                 cifForm11.CIFObj.City__c ='delhi';
                 cifForm11.CIFObj.Type_of_Client__c= 'Local';			//Added by Sheetal on 26/04/2022
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=2;
                 cifForm11.CIFObj.Age_of_Child_2__c= string.valueOf(10);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=3;
                 cifForm11.CIFObj.Age_of_Child_3__c= string.valueOf(12);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=4;
                 cifForm11.CIFObj.Age_of_Child_4__c= string.valueOf(16);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.changeLocality();
                 
             test.stopTest();  
             
         }
     
     @isTest
         private static void cifMainformserachpageTest2() {
             project__c p = createProject();
            // Lead l = createleadTemplate1();
             Account a = createPAAccount();
             Opp_Close_Date__c dt = new Opp_Close_Date__c();
             dt.Project_Name__c = 'test';
             dt.Name = p.Id;
             dt.No_of_Days__c = 90;
             insert dt;
             //Opportunity o = createOpp(a.Id,p.Id);
            // Prospect__c pro= pros(l.Id,p.Id);
            // OTP__c o1 =validateotp(l.Id,p.Id);
             
             test.startTest();
                 pageReference pageRef = page.CIFFormPage;
                 Test.setCurrentPage(pageRef);
            //    ApexPages.currentPage().getParameters().put('id',l.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
             	 ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 ApexPages.currentPage().getParameters().put('directLead','true');   
                   //  ApexPages.currentPage().getParameters().put('leadOTP',o1.Generated_OTP__c);
                 CIFFormPageController cifForm = new CIFFormPageController();
                 cifForm.CIFObj.Salutation__c ='Mr.';
                 cifForm.CIFObj.Marital_Status__c ='Single';
                 cifForm.CIFObj.Ethnicity__c  = 'test';
                 cifForm.CIFObj.BudgetIn_Cr__c=100;
                cifForm.CIFObj.Configuration__c='1 BHK';
                cifForm.CIFObj.TimeLine__c= 'Ready Possession';
                 cifForm.CIFObj.Source__c= 'Digital';
                 cifForm.CIFObj.Occupation__c ='test';
               cifForm.CIFObj.CompanyName__c= 'Test';
                 cifForm.CIFObj.No_of_Children__c= 1;
                 cifForm.CIFObj.Age_of_Child_1__c =string.valueOf(5);
                 cifForm.CIFObj.Configuration__c = '1.5 BHK';
                 cifForm.CIFObj.Purpose__C ='tset';
                 cifForm.CIFObj.Country__c= 'India';
                 cifForm.CIFObj.Spouse_Name__c  ='test';
                 cifForm.CIFObj.Preferred_Location__c = 'test';
                 cifForm.CIFObj.Type_of_Client__c= 'Local';			//Added by Sheetal on 26/04/2022
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=2;
                 cifForm.CIFObj.Age_of_Child_2__c= string.valueOf(10);
                 cifForm.strError='test';
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=3;
                 cifForm.CIFObj.Age_of_Child_3__c= string.valueOf(12);
                 cifForm.strError='test';
                 cifForm.redirectNext();
                 cifForm.CIFObj.No_of_Children__c=4;
                 cifForm.CIFObj.Age_of_Child_4__c= string.valueOf(16);
                 cifForm.strError='test';    
                 cifForm.redirectNext();
                 cifForm.strCurrentSource ='partner';
                 cifForm.validateLeadSource();
                 cifForm.strCurrentSource = '';
                 cifForm.validateLeadSource();
                 cifForm.CIFObj.Source__c ='';
                 cifForm.validateLeadSource();
                 cifForm.GoBackToLead();
                 cifForm.NoOtp();
                cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strAccountId = 'test';
                 cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strOptyId = 'test';
                 cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strotp = 'test';
                // cifForm.otpId = o1.Id;
                 cifForm.hide= false;
                 cifForm.checkbox= true;
                 cifForm.random = true;
                 cifForm.otpgeneratedfor ='Presales';
                 cifForm.prefillLeadFromOtp();
                 //cifForm.OTPvalidate();
                 cifForm.strSpouseDOB = string.valueOf(system.now());
                 cifForm.changeLocality();
                 
               
                pageReference pageRef1 = page.CIFFormPage;
                 Test.setCurrentPage(pageRef1);
                // ApexPages.currentPage().getParameters().put('optyid',o.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
                 ApexPages.currentPage().getParameters().put('Accid',a.Id);
             	 ApexPages.currentPage().getParameters().put('directLead','true');
                 CIFFormPageController cifForm1 = new CIFFormPageController();
                 cifForm1.CIFObj.Configuration__c='test';
                 cifForm1.redirectNext();
                 cifForm1.changeLocality();
                 
                 pageReference pageRef11 = page.CIFFormPage;
                 Test.setCurrentPage(pageRef11);
                 ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
             	 ApexPages.currentPage().getParameters().put('directLead','true');
                 CIFFormPageController cifForm11 = new CIFFormPageController();
                 cifForm11.CIFObj.Ethnicity__c = 'test';
                 cifForm11.CIFObj.BudgetIn_Cr__c = 100;
                 cifForm11.CIFObj.Preferred_Location__c = 'test';
                 cifForm11.CIFObj.Configuration__c = '1.5 BHK';
                 cifForm11.CIFObj.TimeLine__c = 'Ready Possession';
                 cifForm11.CIFObj.Source__c = 'Digital';
                 cifForm11.CIFObj.Salutation__c ='Mr.';
                 cifForm11.CIFObj.Occupation__c = 'test';
                  cifForm11.CIFObj.CompanyName__c= 'Test';
                 cifForm11.CIFObj.Marital_Status__c ='married';
                 cifForm11.CIFObj.No_of_Children__c= 1;
                 cifForm11.CIFObj.Age_of_Child_1__c= string.valueOf(5);
                 cifForm11.CIFObj.Configuration__c ='test';
                 cifForm11.CIFObj.Purpose__C='tset';
                 cifForm11.CIFObj.Country__c = 'NRI';
                 cifForm11.CIFObj.Spouse_Name__c='test';
                 cifForm11.CIFObj.City__c ='delhi';
                 cifForm11.CIFObj.Type_of_Client__c= 'Local';			//Added by Sheetal on 26/04/2022
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=2;
                 cifForm11.CIFObj.Age_of_Child_2__c= string.valueOf(10);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=3;
                 cifForm11.CIFObj.Age_of_Child_3__c= string.valueOf(12);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.CIFObj.No_of_Children__c=4;
                 cifForm11.CIFObj.Age_of_Child_4__c= string.valueOf(16);
                 cifForm11.strError='test';
                 cifForm11.redirectNext();
                 cifForm11.changeLocality();
                 
             test.stopTest();  
             
         }
     
     
         @isTest
         private static void cifFormpagetest2 () {
             project__c p = createProject();
             //Lead l = createleadTemplate1();
             Account a = createPAAccount();
             Opportunity o = createOpp(a.Id,p.Id);
             test.startTest();
                 pageReference pageRef1 = page.CIFFormPage;
                 Test.setCurrentPage(pageRef1);
                 ApexPages.currentPage().getParameters().put('optyid',o.Id);
                 ApexPages.currentPage().getParameters().put('projectId',p.Id);
                 ApexPages.currentPage().getParameters().put('Accid',a.Id);
                 CIFFormPageController cifForm1 = new CIFFormPageController();
                 cifForm1.redirectNext();
                 cifForm1.validateLeadSource();
            test.stopTest();  
         }
         
         private static Project__c createProject() {
                Project__c objProject = new Project__c();
                objProject.name = 'test';
                objProject.RW_Status__c = 'Active';
                objProject.RW_Address__c = 'star garden';
                objProject.Site_Address_Map_Link__c = 'www.google.com';
                
                insert objProject ;
            return objProject;
         } 
     
       
     
         private static Lead createleadTemplate1 () {
                Project__c p = createProject(); 
                Lead objLead = new Lead();
                objLead.LastName = 'test';
                objLead.Status = 'Not Sure';
                objLead.Email = 'test@gmail.com';
                objLead.Rating = 'Hot';
                objLead.MobilePhone = '1212121212';
                objLead.RW_Mobile_No__c = '1212121212';
                objLead.LeadSource = 'Digital';
                //objLead.Corporate_Company__c  = 'Other';
                objLead.RW_Lead_Sub_Source__c = 'Facebook';
                objLead.Walkin_Source__c = 'Digital';
                objLead.Walkin_SubSource__c = 'Facebook';
                objLead.Remark__c = 'test remark';
                objLead.RW_Project__c = p.id; 
                objLead.Country__c = 'India';
                objLead.State__c = 'Odisha';
                objLead.City__c = 'Bhubaneshwar';
                objLead.RW_Budget__c = '< 1Cr';
                objLead.RW_Configuration__c = '1.5 BHK';
                objLead.RW_Location__c = 'Airoli';
                objLead.RW_Time_line__c = 'Ready Possession';
                objLead.RW_Date_of_Birth__c = System.today().addDays(-10);
                objLead.RW_Customer_Type__c = 'NRI';
                objLead.RW_Type_of_Client__c = 'Local';			//Added by Sheetal on 26/04/2022
                objLead.RW_Occupation__c = 'test';
                objLead.RW_Ethnicity__c = 'test';
                objLead.RW_Budget_Rs_in_Cr__c = 10000;
                objLead.Spouse_DOB__c = date.valueOf(system.now());
                objLead.RW_Mobile_No__c = string.valueOf(1234567890);
                 objLead.Generated_OTP_On_Lead__c = '12345' ;
                insert objLead;
             return objLead;
               
             
         }
         private static Account createPAAccount () {
                List<RecordType> personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
                Account objAcc = new Account(lastName='portal account', personEmail = 'standarduser@testorg.com', personMobilePhone= '908089900', 
                                    RecordType = personAccountRecordType[0],Mobile_No__c = '1212121212',RW_Customer_Type__c = 'NRI',
                                    RW_Occupation__c = 'test',RW_Ethnicity__c = 'test' ,Birth_Date__c =date.valueOf(system.now().addDays(-10)),
                                             Spouse_DOB__c = date.valueOf(system.now().addDays(-10)),Gender__c='male');
                insert objAcc;
             return objAcc;
         }
         private static Opportunity createOpp (Id accId, Id projId) {
             //Account a = createPAAccount();
             //project__c p = createProject();
             
                Opportunity objOpp = new Opportunity();
                objopp.Name = 'TestOpp';
                objopp.Accountid = accId;
                objopp.CloseDate = System.today().addDays(30);
                objopp.StageName = 'Site Visit';//'Unit Booked';
                objopp.RW_Project__c = projId;
                objopp.Budget_In_Cr__C = 100;
                objopp.RW_Ethnicity__c = 'test';
                objopp.RW_Location__c = 'Airoli';
                objopp.RW_Configuration__c = '1.5 BHK';
                objopp.RW_Time_line__c = 'Ready Possession';
                objopp.Walkin_Source__c = 'Digital';
                objopp.Walkin_SubSource__c = 'Facebook';
                objopp.RW_Type_of_Client__c  = 'Local';			//Added by Sheetal on 26/04/2022
                //objopp.RW_Project_Unit__c = u.Id;
                insert objOpp;
                Opportunity objOppToreturn = [Select id,RW_Project__c,AccountId ,StageName ,RW_Opportunity_Status__c 
                                                      from Opportunity where id =:objOpp.id];
             return objOppToreturn ;
         }
   private static  Prospect__c pros(Id leadId ,Id projId){
        Prospect__c prosobj = new Prospect__c();
        prosobj.Name = 'test';
        prosobj.Sales_Call_Attempt_Date__c = system.now();
        prosobj.Sales_Call_Attempt_Status__c ='visit confirmed';
        prosobj.Last_Call_Attempt_Date__c = system.now();
        prosobj.Last_Call_Attempt_Status__c = 'visit confirmed'; 
        prosobj.Lead__c = leadId;
        prosobj.Project__c = projId;
     insert prosobj;
    return prosobj;}
    
     
     private static OTP__C validateotp(Id leadId, Id projId){
         OTP__c otpobj = new OTP__c();
         otpobj.Lead__c = leadId;
         otpobj.Customer_Site_Visit_On__c = string.valueOf(system.now());
         otpobj.Generated_OTP__c = '12345';
         otpobj.OTP_Generate_For__c = 'Presales';
         otpobj.OTP_Generated_on__c = string.valueOf(system.now());    
         //otpobj.Prospect__c=prosId;
         otpobj.Project__c  =projId;     
          insert otpobj;
           return otpobj;
         
       }
     @isTest
private static void test_LeadPathCoversObjLead() {
    // Create Project
    Project__c proj = new Project__c(Name = 'Test Project');
    insert proj;

    // Create Lead linked to project
    Lead lead = new Lead(
        LastName = 'Test Lead',
        Company = 'Test',
        Status = 'Open - Not Contacted',
        Walkin_Source__c = 'Digital',
        RW_Project__c = proj.Id,
        Country__c = 'India',
        City__c = 'Mumbai',
        State__c = 'MH',
        Email = 'test@example.com',
        RW_Budget__c = '< 1Cr',
        RW_Configuration__c = '2 BHK',
        RW_Time_line__c = 'Immediate',
        RW_Date_of_Birth__c = Date.today().addYears(-30),
        RW_Customer_Type__c = 'Local',
        RW_Type_of_Client__c = 'Local',
        RW_Occupation__c = 'Engineer',
        RW_Ethnicity__c = 'Test',
        Rating = 'Hot',
        MobilePhone = '9999999999',
        RW_Mobile_No__c = '9999999999',
        Generated_OTP_On_Lead__c = '12345'
    );
    insert lead;

    // Create OTP
    OTP__c otp = new OTP__c(
        Generated_OTP__c = '12345',
        Lead__c = lead.Id,
        Project__c = proj.Id
       // OTP_Expired__c = false
    );
    insert otp;

    // Set page parameters – VERY IMPORTANT: Only use `id`, not `Accid`
    PageReference pageRef = Page.CIFFormPage;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', lead.Id);
    ApexPages.currentPage().getParameters().put('projectId', proj.Id);

    // Now construct the controller – objLead should be loaded
    CIFFormPageController controller = new CIFFormPageController();

    // REQUIRED FIELDS for redirectNext to go through all conditions
    controller.CIFObj.Salutation__c = 'Mr.';
    controller.strDOB = '10/10/1990';
    controller.CIFObj.Type_of_Client__c = 'Local';
    controller.CIFObj.Occupation__c = 'Engineer';
    controller.CIFObj.CompanyName__c = 'TCS';
    controller.CIFObj.CompanyNameOther__c = 'Other';
    controller.CIFObj.Ethnicity__c = 'Indian';
    controller.CIFObj.Marital_Status__c = 'Single';
    controller.CIFObj.Budget_In_Lakh__c = 90;
    controller.CIFObj.Configuration__c = '2 BHK';
    controller.CIFObj.TimeLine__c = 'Immediate';
    controller.CIFObj.Purpose__c = 'Investment';
    controller.CIFObj.No_of_Family_Members__c = 4;
    controller.CIFObj.Industry__c = 'IT';
    controller.CIFObj.Distance_To_Office__c = '10 KM';
    controller.CIFObj.Family_Income__c = '20 Lakh';
    controller.CIFObj.No_of_Vehicles__c = '2';
    controller.CIFObj.Four_Wheeler__c = 'Yes';
    controller.CIFObj.Current_Residential_Address__c = 'Mumbai';
    controller.CIFObj.ZipCode__c = '400601';
    controller.CIFObj.Country__c = 'India';

    Test.startTest();
    controller.redirectNext();
    Test.stopTest();

    // Ensure line was executed
   // System.assertNotEquals(null, controller.objLead, 'Lead should not be null');
}
     
  @isTest
private static void cifMainformserachpageTest3() {
    // Step 1: Create project
    Project__c p = new Project__c(Name = 'Test Project');
    insert p;

    // Step 2: Create Person Account with required fields
    Account a = new Account(
        FirstName = 'Test',
        LastName = 'Person',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
        PersonEmail = 'person@example.com',
    
        Country__c = 'India',
        State__c = 'MH',
        City__c = 'Mumbai',

        RW_Occupation__c = 'Engineer',
        RW_Ethnicity__c = 'Test'
    );
    insert a;

    // Step 3: Required setup data
    Opp_Close_Date__c dt = new Opp_Close_Date__c(
        Project_Name__c = 'test',
        Name = p.Id,
        No_of_Days__c = 90
    );
    insert dt;

    Test.startTest();

    // Step 4: Set only Account-related parameters (no 'id' for Lead!)
    PageReference pageRef = Page.CIFFormPage;
    Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().clear();
    ApexPages.currentPage().getParameters().put('Accid', a.Id);
    ApexPages.currentPage().getParameters().put('projectId', p.Id);
    //ApexPages.currentPage().getParameters().put('directLead', 'true');

    // Step 5: Instantiate the controller
    CIFFormPageController cifForm = new CIFFormPageController();

    // Step 6: Confirm account is loaded
    System.assertNotEquals(null, cifForm.objAcc, 'Account must be loaded');

    // Step 7: Populate required fields
    cifForm.CIFObj.Salutation__c = 'Mr.';
    cifForm.CIFObj.Marital_Status__c = 'Single';
    cifForm.CIFObj.Ethnicity__c = 'Test';
    cifForm.CIFObj.BudgetIn_Cr__c = 100;
    cifForm.CIFObj.Configuration__c = '1.5 BHK';
    cifForm.CIFObj.TimeLine__c = 'Ready Possession';
    cifForm.CIFObj.Source__c = 'Digital';
    cifForm.CIFObj.Occupation__c = 'Engineer';
    cifForm.CIFObj.CompanyName__c = 'Test Ltd.';
    cifForm.CIFObj.No_of_Children__c = 4;
    cifForm.CIFObj.Age_of_Child_1__c = '5';
    cifForm.CIFObj.Age_of_Child_2__c = '10';
    cifForm.CIFObj.Age_of_Child_3__c = '12';
    cifForm.CIFObj.Age_of_Child_4__c = '16';
    cifForm.CIFObj.Purpose__C = 'Investment';
    cifForm.CIFObj.Country__c = 'India';
    cifForm.CIFObj.Spouse_Name__c = 'Test Spouse';
    cifForm.CIFObj.Preferred_Location__c = 'test';
    cifForm.CIFObj.Type_of_Client__c = 'Local';

    // Step 8: Go through redirect and change logic
    cifForm.redirectNext();
    cifForm.validateLeadSource();
    cifForm.CIFObj.Source__c = '';
    cifForm.validateLeadSource();
    cifForm.GoBackToLead();
    cifForm.NoOtp();
    cifForm.prefillLeadFromOtp();
    cifForm.strAccountId = a.Id;
    cifForm.prefillLeadFromOtp();
    cifForm.strOptyId = 'test';
    cifForm.prefillLeadFromOtp();
    cifForm.strotp = 'test';
    cifForm.hide = false;
    cifForm.checkbox = true;
    cifForm.random = true;
    cifForm.otpgeneratedfor = 'Presales';
    cifForm.prefillLeadFromOtp();
    cifForm.strSpouseDOB = String.valueOf(System.now());
    cifForm.changeLocality();

    Test.stopTest();
}


@isTest
private static void test_AccountPathLineCovered() {
    // Create required project
    Project__c proj = new Project__c(Name = 'Test Project');
    insert proj;

    // Create person account
    Account acc = new Account(
        FirstName = 'Test',
        LastName = 'Person Account',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
        PersonEmail = 'acc@test.com',
       
        Country__c = 'India',
        State__c = 'MH',
        City__c = 'Mumbai',
       
        RW_Occupation__c = 'IT',
        RW_Ethnicity__c = 'Test'
    );
    insert acc;

    // Set new page and clean parameters (fresh page context)
    PageReference pg = Page.CIFFormPage;
    Test.setCurrentPage(pg);
    ApexPages.currentPage().getParameters().clear(); // ⛔ CLEAR ALL
    ApexPages.currentPage().getParameters().put('Accid', acc.Id); // ✅ Only Account
    ApexPages.currentPage().getParameters().put('projectId', proj.Id);
    ApexPages.currentPage().getParameters().put('directLead', 'true');

    // Now instantiate the controller (AFTER parameters set)
    Test.startTest();
    CIFFormPageController controller = new CIFFormPageController();
    Test.stopTest();

    // Final check: was objAcc initialized?
    System.assertNotEquals(null, controller.objAcc, 'Account should be populated');

    // 🔥 Now the line "else if (objAcc != null && strAccountId != null && strAccountId != '')" must be covered
}

     
     

 }