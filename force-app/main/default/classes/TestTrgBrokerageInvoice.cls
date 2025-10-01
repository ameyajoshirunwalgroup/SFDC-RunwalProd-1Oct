@isTest
public class TestTrgBrokerageInvoice 
{
	public static testmethod void TestBI()
    {
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
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 2';
        insert bs;
        
        Brokerage__c b = new Brokerage__c();
        b.Name = 'Base Brokerage';
        b.Brokerage__c = 2;
        b.Brokerage_Amount__c = 272059;
        b.Brokerage_Summary__c = bs.Id;
        b.Opportunity_AV__c = 13602975;
        b.Brokerage_Type__c = 'Base Brokerage';
        insert b;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Invoice_Number__c = '24252';
        bi.Brokerage_Lookup__c = b.Id ;
        bi.Approval_Status_clearing__c = 'Approved By L1';
        bi.Channel_Partner__c = cp.id;
        insert bi;
        
        bi.Invoice_Number__c = '24257';
        update bi;
        
        bi.Approval_Status_clearing__c = 'Approved By L2';
        update bi;
    }
    public static testmethod void TestBI2()
    {
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
        
        Brokerage_Summary__c bs = new Brokerage_Summary__c();
        bs.Applied_Slab_Name__c = 'Slab 2';
        insert bs;
        
        Brokerage__c b = new Brokerage__c();
        b.Name = 'Base Brokerage';
        b.Brokerage__c = 2;
        b.Brokerage_Amount__c = 272059;
        b.Brokerage_Summary__c = bs.Id;
        b.Opportunity_AV__c = 13602975;
        b.Brokerage_Type__c = 'Base Brokerage';
        insert b;
        
        Brokerage_Invoice__c bi = new Brokerage_Invoice__c();
        bi.Invoice_Number__c = '24252';
        bi.Brokerage_Lookup__c = b.Id ;
        bi.Approval_Status_clearing__c = 'Approved By L1';
        bi.Channel_Partner__c = cp.id;
        insert bi;
        
        bi.Approval_Status_clearing__c = 'Approved By L2';
        update bi;
    }
}