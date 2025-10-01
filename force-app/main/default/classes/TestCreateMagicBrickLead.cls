@isTest
public class TestCreateMagicBrickLead {
  @isTest(SeeAllData = true)
  public static void LeadTest() {   
    
    Project__c projObj = new Project__c();
    projObj.Name = 'Test Project';
    projObj.RW_Project_Code__c= '312';
    insert projObj;
    
    MagicBricksAPIKey__c keyObj1 = new MagicBricksAPIKey__c();
    keyObj1.Name = 'Test Key1';
    keyObj1.Key__c = 'Test Key1';
    insert keyObj1;
    
    Lead leadObj = new Lead();
    leadObj.APIKey__c = keyObj1.Id;
    leadObj.LastName = 'Test Lead';
    leadObj.RW_Mobile_No__c = '9963259012';
    leadObj.Email = 'test123@stetig.in';
    leadObj.Web_Banner_Source__c = 'www.test.in';
    leadObj.RW_Project__c = projObj.id;
   // leadObj.Req_type__c = 'Integration';
    leadobj.LeadSource = 'Property Portals';
    leadobj.RW_Lead_Sub_Source__c = 'MagicBricks';
    leadobj.Lead_Sub_Source__c = 'Magic Bricks';
    leadObj.medium__c = 'Online';
 //   leadObj.Integration_Source__c = 'MagicBricks';
    insert leadObj;

    MagicBricks_ProjectMaps__c csObj1 = new MagicBricks_ProjectMaps__c();
    csObj1.Name = 'Test Project';
    csObj1.Project_Name__c = 'Test Project';
    insert csObj1;

    Test.startTest();

    PageReference pRef = Page.MagicBricksPage;
    Test.setCurrentPage(pRef);
    ApexPages.currentPage().getParameters().put('APIKey', 'Test Key1'); 
    ApexPages.currentPage().getParameters().put('MobileNo', '9963259013');
    ApexPages.currentPage().getParameters().put('EmailID', 'test457@stetig.in');
    ApexPages.currentPage().getParameters().put('SourceURL', 'www.test.in');
    ApexPages.currentPage().getParameters().put('ProjectName', 'Test Project');
    //ApexPages.currentPage().getParameters().put('ReqType','Integration');
    ApexPages.currentPage().getParameters().put('Name', 'Test Sulekha');
    ApexPages.currentPage().getParameters().put('medium', 'Online');
    // ApexPages.currentPage().getParameters().put('rootsource','Mailer'); 

    CreateMagicBrickLead CML1 = new CreateMagicBrickLead();
    CML1.insertlead();
    
    
    Test.stopTest();
  }
  @isTest(SeeAllData = true)
  public static void LeadTest1() {

        Project__c projObj = new Project__c();
        projObj.Name = 'Test Project1';
        projObj.RW_Project_Code__c = '777';
        insert projObj;
        
        MagicBricksAPIKey__c keyObj1 = new MagicBricksAPIKey__c();
        keyObj1.Name = 'Test Key1';
        keyObj1.Key__c = 'Test Key1';
        insert keyObj1;
        
        MagicBricks_ProjectMaps__c csObj1 = new MagicBricks_ProjectMaps__c();
        csObj1.Name = 'Test Project';
        csObj1.Project_Name__c = 'Test Project';
        insert csObj1;
        
        // Project Creation
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T35';
        objpr.Name = 'Test';
        insert objpr;
        
        // account creation 
        Account objac = new Account();
        objac.FirstName = 'Shock';
        objac.LastName = 'Wave';
        objac.PersonMobilePhone = '9999998888';
        objac.PersonEmail = 'test@test.in';
//      objac.Correspondence_Address__c = 'Delhi';
//        objac.Category__c = 'General';    
        insert objac;
        
      Opp_Close_Date__c cls = new Opp_Close_Date__c();
      cls.Name = objpr.Id;
      cls.No_of_Days__c = 30;
      insert cls;
      
        // opportunity creation              
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = objac.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Opportunity Identified'; 
        objOpportunity.RW_Project__c = objpr.Id;
 //       objOpportunity.Follow_Up_DateS__c = system.today(); 
        insert objOpportunity;
        
        Test.startTest();
        
        PageReference pRef1 = Page.MagicBricksPage;
        Test.setCurrentPage(pRef1);
        ApexPages.currentPage().getParameters().put('APIKey', 'Test Key1'); 
        ApexPages.currentPage().getParameters().put('MobileNo', '9999998888');
        ApexPages.currentPage().getParameters().put('EmailID', 'test@test.in');
        ApexPages.currentPage().getParameters().put('SourceURL', 'www.test.in');
        ApexPages.currentPage().getParameters().put('ProjectName', 'Test Project');
        //ApexPages.currentPage().getParameters().put('ReqType','Integration');
        ApexPages.currentPage().getParameters().put('Name', 'Shock Wave');
        ApexPages.currentPage().getParameters().put('medium', 'Online');
        // ApexPages.currentPage().getParameters().put('rootsource','Mailer'); 
    
        CreateMagicBrickLead CML2 = new CreateMagicBrickLead();
        CML2.insertlead();
        
        Test.stopTest();
     
    }

}