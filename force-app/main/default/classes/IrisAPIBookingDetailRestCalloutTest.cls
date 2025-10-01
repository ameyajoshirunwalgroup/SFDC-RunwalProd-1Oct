@isTest
public class IrisAPIBookingDetailRestCalloutTest {
    @testsetup
    public static void setupdata(){
           String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;

           Account Accnt = new Account(              
            RecordTypeID=RecTypeId,                
            FirstName='TestFName',                
            LastName='TestLName',                
            PersonMailingStreet='test@yahoo.com',                
            PersonMailingPostalCode='12345',                
            PersonMailingCity='SFO',                
            PersonEmail='test@yahoo.com',                
            PersonHomePhone='1234567',                
            PersonMobilePhone='12345678'                 
        );          
        
        insert Accnt;
        
        Broker__c br = new Broker__c();
        br.name ='test';
        br.Broker_Pan_No__c ='tyui6uus';
        br.RW_RERA_Registration_Number__c='fghjkl';
        br.RW_CreateFromIRIS__c=true;
        br.RW_IRIS_Sync__c = true;
        insert br;
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test';
        objOpportunity.Walkin_Source__c='Channel Partner';
        objOpportunity.RW_Walkin_Channel_Partner__c = br.id;
        objOpportunity.Sales_Manager__c = 'Deepak Arya';
        objOpportunity.Sourcing_Manager__c = 'Deepak Arya';
        objOpportunity.CloseDate = System.today();
        objOpportunity.AccountId = Accnt.Id; 
        objOpportunity.Status__c = 'Active'; 
        objOpportunity.StageName = 'Qualification'; 
        objOpportunity.RW_Sent_to_IRIS__c = true;
insert objOpportunity;
        
        
           Quotation__c qt = new Quotation__c();
        qt.Agreement_Value__c =10000000;
        qt.Grand_Total__c = 10000000;
        qt.Opportunity__c = objOpportunity.id;
        insert qt;
        Booking__c b = new booking__c();
        b.BrokerIId__c = br.id;
        b.Source_of_Booking__c = 'Channel Partner';
        b.Opportunity__c = objOpportunity.id;
        b.Customer__c = objOpportunity.id;
        b.Quotation__c = qt.id;
        insert b;
        Applicant_Details__c ap = new Applicant_Details__c();
        ap.Salutation__c = 'Mr.';
        ap.First_Name__c ='Iris Firstname';
        ap.Last_Name__c = 'Iris lastname';
        ap.Email_Address__c ='iristest@iris.com';
        ap.Mobile_Number__c = '09990999900';
        ap.PancardNo__c = 'wertt9999s';
        ap.DOB__c = system.today() - 20000;
        ap.Address_Proof_Document__c = 'Passport';
        ap.Address_Proof_Number__c = 'K9990009';
        ap.Type_Of_Applicant__c = 'Individual Buyer';
        ap.Subtype_Of_Applicant__c = 'Indian National';
        ap.Applicant_Number__c = 'Primary Applicant';
        ap.Booking__c = b.id;
        ap.Opportunity__c =  objOpportunity.id;
        insert ap;
        RW_Payment_Details__c pd = new RW_Payment_Details__c();
        pd.RW_Payment_Mode__c= 'Online';
        pd.RW_Instrument_Number__c = 'ertyuio';
        pd.RW_Payment_Date__c = system.today();
        pd.RW_Posting_Date__c =system.today();
        pd.RW_Accounting_Document_Number__c ='262829sis9s9s';
        pd.RW_Bank_Reference_Number__c='sda7yta';
        pd.RW_Booking__c =b.id;
       pd.RW_Company_Code__c='2000';
        pd.RW_Iris_Synced__c =true;
        insert pd;
		RW_Payment_Detail_Item__c	 pdi = new RW_Payment_Detail_Item__c();
        pdi.RW_Amount__c = 100000;
        pdi.RW_Payment_Details__c = pd.Id;
        insert pdi;
        RW_Payment_Details__c pd1 = new RW_Payment_Details__c();
        pd1.RW_Payment_Mode__c= 'Online';
        pd1.RW_Instrument_Number__c = 'ertyuio';
        pd1.RW_Payment_Date__c = system.today();
        pd1.RW_Posting_Date__c =system.today();
        pd1.RW_Accounting_Document_Number__c ='262829sis9s9s';
        pd1.RW_Bank_Reference_Number__c='sda7yta';
        pd1.RW_Booking__c =b.id;
       pd1.RW_Company_Code__c='2000';
        pd1.RW_Iris_Synced__c =false;
        insert pd1;
		RW_Payment_Detail_Item__c	 pdi1 = new RW_Payment_Detail_Item__c();
        pdi1.RW_Amount__c = 100000;
        pdi1.RW_Payment_Details__c = pd1.Id;
        insert pdi1;
    }
    
  @istest
    public static void testbooking(){
      /*  String json=		'{'+
		'	"booking_detail":'+
		'	{'+
		'		"reference_id": "6",'+
		'		"project_unit_id": "5fbceb1062d4a769f80d9821",'+
            '		"lead_id": "RW-000023"}}';
        IrisAPIBookingDetailJson.parse(json);
       */    
        
          test.startTest();
  Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
booking__c b= [select id from booking__c limit 1];
               IrisAPIBookingDetailRestCallout.callIris(new list<id>{b.id});

        test.stopTest();
     
        
      
    }
    
   
}