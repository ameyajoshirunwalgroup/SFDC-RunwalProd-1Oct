@isTest
public class TestChannelPartnerUpdateTrigger {
    private static testmethod void ChannelPartnerUpdateTriggerTest(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        
        objBroker.Unregistered_Channel_Partner__c = true;
        Update objBroker;      
        
        
        
    } 
    @isTest
    Public static void ChannelPartnerTriggerTest(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        insert cp;
        
		cp.RW_RERA_Registration_Number__c = '223256789012';
        cp.RW_GST_Number__c = '123456789012345';
        Update cp;       
        
        cp.Approval_Status_Update__c = 'Rejected By L1';
        update cp;
        
    } 
    
    @isTest
    Public static void ChannelPartnerTriggerTest2(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Approval_Status_Update__c = 'Approval Pending';
        insert cp;
        
        CP_Profile_Update__c cpro = new CP_Profile_Update__c();
        cpro.New_CP_Name__c = 'Test';
        cpro.Old_CP_Name__c = 'Test2';
        cpro.Channel_Partner__c = cp.Id;
        insert cpro;
        
        cp.Approval_Status_Update__c = 'Rejected By L1';
        update cp;
        
    }
    
     @isTest
    Public static void ChannelPartnerTriggerTest3(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Approval_Status_Update__c = 'Approval Pending';
        insert cp;
        
        CP_Profile_Update__c cpro = new CP_Profile_Update__c();
        cpro.New_CP_Name__c = 'Test';
        cpro.Old_CP_Name__c = 'Test2';
        cpro.Channel_Partner__c = cp.Id;
        insert cpro;
        
        cp.Approval_Status_Update__c = 'Rejected By L2';
        update cp;
        
    }
	@isTest
    Public static void ChannelPartnerTriggerTest4(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        insert cp;
        
        CP_Profile_Update__c cpro = new CP_Profile_Update__c();
        cpro.New_CP_Name__c = 'Test';
        cpro.Old_CP_Name__c = 'Test2';
        cpro.Channel_Partner__c = cp.Id;
        insert cpro;
        
        cp.RW_RERA_Registration_Number__c = '223256789012';
        Update cp;  
        
    }    
    @isTest
    Public static void ChannelPartnerTriggerTest5(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        insert cp;
        
        cp.Name = 'Test CP 2';
        Update cp;       
        
    } 
    
    @isTest
    Public static void ChannelPartnerTriggerTest6(){
        Broker__c objBroker = new Broker__c();
        objBroker.Broker_Pan_No__c = 'ABCDF34526';
        objBroker.Name = 'Testcp2';
        objBroker.RW_Email__c = 'testcp4@stetig.in';
        objBroker.Dialing_Country1__c = 'India';
        objBroker.Dialing_Country_Code1__c = '+91';
        objBroker.RW_Mobile_No__c = '1112288888';
        objBroker.Unregistered_Channel_Partner__c = true;
        Insert objBroker;      
        
        Broker__c cp = new Broker__c();
        cp.Name = 'Test CP';
        cp.RW_Email__c = 'teststetig@stetig.in';
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
        //cp.RW_RERA_Registration_Number__c = '123256789012';
        cp.RW_Mobile_No__c = '1234567890';
        cp.Approval_Status__c = 'Approved By L2';
        cp.STREET__c = 'street';
        cp.STR_SUPPL1__c = 'street1';
        cp.STR_SUPPL2__c = 'street1';
        cp.STR_SUPPL3__c = 'street1';
        insert cp;
        
        cp.RW_RERA_Registration_Number__c = '223256789012';
        Update cp;  
        
    }    
}