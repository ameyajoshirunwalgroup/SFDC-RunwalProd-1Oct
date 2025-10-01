@isTest
public class ProjectBrochureuploadcntrlTest {

    
    private static testMethod void setupdata() {
        
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
      
        
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title='Header_Picture1', 
            PathOnClient ='/Header_Picture1.jpg',
            VersionData = Blob.valueOf('Unit Test ContentVersion Body'), 
            origin = 'H'
        );
        insert contentVersion_1;
       
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Project__c objpr = new Project__c();
        objpr.RW_Project_Brochure_ID__c = documents[0].Id;
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        objpr.Sales_Site_Head__c = tuser.Id;
        objpr.SAPMaterial_Code__c = '1211';
        objpr.Project_CRM_Lead__c = tuser.Id;
        insert objpr;
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objpr.id;
        contentlink.contentdocumentid = contentVersion_2.ContentDocumentId;
        contentlink.ShareType = 'V';
        insert contentlink; 
        Map<String,String> DocDetails = new Map<String,String>();
        DocDetails.put('projectId', objpr.Id);
        DocDetails.put('documentId', contentlink.contentdocumentid);
          ContentDocumentLink contDoc = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink Where 
                                      ContentDocumentId =: DocDetails.get('documentId') AND 
                                     LinkedEntityId =: DocDetails.get('projectId')]; 
        system.debug(contDoc);ProjectBrochureUploadController.updateBrochureData(DocDetails);
        ProjectBrochureUploadController.getFiles(String.valueOf(documents[0].Id));
        ProjectBrochureUploadController.deleteFiles(String.valueOf(documents[0].Id));        
        ProjectBrochureUploadController.getProjectRecord(string.valueOf(objpr.Id));
       
        //
    }
}