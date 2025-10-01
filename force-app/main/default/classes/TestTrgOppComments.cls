@isTest
public class TestTrgOppComments 
{
    public static testmethod void TestOppComments(){
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig43646@stetig.in';
        cp.Individual_CP__c = true;
        cp.RW_CreateFromIRIS__c = true;
        cp.RW_IRIS_Sync__c = true;
        cp.Place_of_Supply__c = 'Maharashtra';
        cp.Channel_Partner_From_CP_Portal__c = true;
        cp.Project__c = 'Runwal Bliss';
        cp.Approver_L1__c = userinfo.getUserId();
        cp.Approver_L2__c = userinfo.getUserId();
        cp.Registration_Complete__c = true;
        cp.RW_Mobile_No__c = '1234567890';
        cp.Broker_Type__c = 'Individual';
        cp.Broker_Pan_No__c = 'ADRPI3525F';
        cp.RW_Mobile_No__c = '1234567890';
        cp.NAME_FIRST__c = 'tets';
        cp.NAME_MIDDLE__c = 'cp';
        cp.NAME_LAST__c = 'test';
        cp.TITLE__c = 'Mr.';
        cp.Account_Number__c = '465446';
        cp.Cheque_DD_Favouring_Name__c = 'test cp';
        cp.IFSC_Code__c = 'BHSHVD';
        cp.Is_NRI_CP__c = false;
        cp.RW_Is_GST_Applicable__c = true;
        cp.Channel_Partner_From_CP_Portal__c =true;
        insert cp;
        
        
        
        Account cpaccount = [Select Id,Name,Channel_Partner__c from Account where Channel_Partner__c =: cp.Id];
        Account a = TestDataFactory.createPATemplate('WC Account', 'wc@stetig.in.com','9098777',false);
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        Opportunity objcustomer= new Opportunity();
        objcustomer.RW_Project__c=objpr.id;
        objcustomer.name='Test 1';
        objcustomer.StageName='Qualification';
        //objcustomer.RW_Project_Unit__c=objPUU1.id;  
        objcustomer.CloseDate=system.today();
        objcustomer.Status__c ='Active';
        objCustomer.AccountId = a.Id;
        objcustomer.Sales_Manager__c = 'SM2@g.com';
        objcustomer.RW_Type_of_Client__c = 'Local';
        objcustomer.Channel_Partner_Account__c = cpaccount.Id;
        objcustomer.RW_Walkin_Channel_Partner__c = cp.Id;
        objcustomer.Walkin_Source__c = 'Channel Partner';
        insert objcustomer;
        
        List<Id> acId = new List<Id>();
        acId.add(cpaccount.id);
        EnableCPPortaluser.EnableCustomerCommunityUser(acId);
        system.debug('cpAccount:::'+cpaccount);
        User u = [Select Id,name from User where Email =: 'teststetig43646@stetig.in'];
        system.runAs(u){
            Opportunity_Comment__c oc = new Opportunity_Comment__c();
            oc.Comment__c = 'Test';
            oc.Opportunity__c = objcustomer.id;
            insert oc;
        }
        Opportunity_Comment__c oc2 = new Opportunity_Comment__c();
            oc2.Comment__c = 'Test';
            oc2.Opportunity__c = objcustomer.id;
            insert oc2;
    }
}