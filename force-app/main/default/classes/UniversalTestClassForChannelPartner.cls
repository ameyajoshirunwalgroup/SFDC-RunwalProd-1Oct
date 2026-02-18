@istest
public class UniversalTestClassForChannelPartner {
@testsetup
    public static void setupdata(){
                test.startTest();
            Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
  RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string allstring = '[{ 	"NAME_FIRST__c": "testwmk2", 	"NAME_LAST__c": "mk1e456", 	"Name": "runwal", 	"TITLE__c": "Mr.", 	"STREET__c": "Addressw1", 	"STR_SUPPL1__c": "Addwress2", 	"STR_SUPPL2__c": "Addwress3", 	"Broker_Type__c": "International", 	"City__c": "Mumbai", 	"Country__c": "India", 	"Is_NRI_CP__c": false, 	"Phone_2__c": "9964052499", 	"Pin_Code__c": "456666", 	"RW_Email__c": "manojkrishna.k.s+15@gmail.com", 	"Broker_Pan_No__c": "BLBBK95625V", 	"RW_GST_Number__c": null, 	"RW_Is_GST_Applicable__c": true, 	"RW_Is_RERA_Applicable__c": true, 	"RW_Mobile_No__c": "9987899999", 	"RW_Proof_of_Income__c": "PAN", 	"RW_RERA_Registration_Number__c": "567vvvds5432", 	"State__c": "KARNATAKA", 	"Zone__c": "Kalyan Dombivali", 	"RW_CreateFromIRIS__c": true }]	';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring);
        RestContext.request = req;
        RestContext.response = res; 
        ChannelPartnerRestServices.insertCP();
      system.debug(res.responseBody.toString());
        List<ChannelPartnerRestServices.Response> s= (List<ChannelPartnerRestServices.Response>)json.deserialize(res.responseBody.toString(), List<ChannelPartnerRestServices.Response>.class); 
   
        test.stopTest();
    }
    @istest
    public static void testchannelPartner(){
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new UniversalHttpMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
          List<Broker__c> s = [select id from Broker__c];
         ChannelPartnerTriggerHandler.sendBrokerlist(s[0].id);
          List<Broker__c> lstBroker = [SELECT Name,SAP_CP_Code__c,Aadhar_Card__c,TITLE__c,NAME_FIRST__c,NAME_LAST__c,NAME_MIDDLE__c,Representative_Name__c,
                                     STREET__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,City__c,Pin_Code__c,State__c,
                                     Country__c,RW_Broker_Number__c,RW_Mobile_No__c,RW_Email__c,
                                     RW_NATURE_WORK__c,Legal_Form__c,Is_NRI_CP__c,Broker_Pan_No__c,RW_GST_Number__c,
                                     RW_RERA_Registration_Number__c,Payment_Terms__c,Individual_CP__c,RW_CreateFromIRIS__c FROM Broker__c 
                                     WHERE ID =:s[0].id LIMIT 1];
          // IrisAPIChannelPartnerRestCallout.ChannelPartnerRestCallOutPatch(lstBroker[0]);
     RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
          string allstring1 = '[{ "Id":"'+s[0].id+'",	"NAME_FIRST__c": "testwmk2", 	"NAME_LAST__c": "mk1e456", 	"Name": "", 	"TITLE__c": "Mr.", 	"STREET__c": "Addressw1", 	"STR_SUPPL1__c": "Addwress2", 	"STR_SUPPL2__c": "Addwress3", 	"Broker_Type__c": "International", 	"City__c": "Mumbai", 	"Country__c": "India", 	"Is_NRI_CP__c": false, 	"Phone_2__c": "9964052499", 	"Pin_Code__c": "456666", 	"RW_Email__c": "manojkrishna.k.s+15@gmail.com", 	"Broker_Pan_No__c": "BLBPk95625V", 	"RW_GST_Number__c": null, 	"RW_Is_GST_Applicable__c": true, 	"RW_Is_RERA_Applicable__c": true, 	"RW_Mobile_No__c": "9987899999", 	"RW_Proof_of_Income__c": "PAN", 	"RW_RERA_Registration_Number__c": "567vvvds5432", 	"State__c": "KARNATAKA", 	"Zone__c": "Kalyan Dombivali", 	"RW_CreateFromIRIS__c": true }]	';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring1);
        RestContext.request = req;
        RestContext.response = res;
        SAPChannelPartnerAPICallOut.erpLogList.clear();
        system.debug( SAPChannelPartnerAPICallOut.erpLogList.size());
        ChannelPartnerRestServices.insertCP();
      system.debug(res.responseBody.toString());
        
        IrisAPIChannelPartnerJson f = new IrisAPIChannelPartnerJson();
       string sss = '{"channel_partner":{"cp_code":"sd"}}';
        IrisAPIChannelPartnerJson.parse(sss);
            
        SAPChannelPartnerAPI.BAPIRET2 bapi = new SAPChannelPartnerAPI.BAPIRET2();

        
        test.stopTest();
    
        
    }
    
      @istest
    public static void testchannelPartner1(){
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new UniversalIrisMockClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
          RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string allstring = '[{ 	"NAME_FIRST__c": "testwmk2", "STR_SUPPL3__c":"STR_SUPPL3__c",	"NAME_LAST__c": "mk1e456", 	"Name": "runwal", 	"TITLE__c": "Mr.", 	"STREET__c": "Addressw1", 	"STR_SUPPL1__c": "Addwress2", 	"STR_SUPPL2__c": "Addwress3", 	"Broker_Type__c": "International", 	"City__c": "Mumbai", 	"Country__c": "India", 	"Is_NRI_CP__c": false, 	"Phone_2__c": "9964052499", 	"Pin_Code__c": "456666", 	"RW_Email__c": "manojkrishna.k.s+15@gmail.com", 	"Broker_Pan_No__c": "BLBBK95625V", 	"RW_GST_Number__c": null, 	"RW_Is_GST_Applicable__c": true, 	"RW_Is_RERA_Applicable__c": true, 	"RW_Mobile_No__c": "9987899999", 	"RW_Proof_of_Income__c": "PAN", 	"RW_RERA_Registration_Number__c": "567vvvds5432", 	"State__c": "KARNATAKA", 	"Zone__c": "Kalyan Dombivali", 	"RW_CreateFromIRIS__c": true }]	';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring);
        RestContext.request = req;
        RestContext.response = res; 
        ChannelPartnerRestServices.insertCP();
      system.debug(res.responseBody.toString());
        List<ChannelPartnerRestServices.Response> s= (List<ChannelPartnerRestServices.Response>)json.deserialize(res.responseBody.toString(), List<ChannelPartnerRestServices.Response>.class); 
   
    system.debug(s[0].broker.id);
    //   SAPChannelPartnerAPICallOut.sendBrokerlist(s[0].broker.id);
          List<Broker__c> lstBroker = [SELECT Name,SAP_CP_Code__c,Aadhar_Card__c,TITLE__c,NAME_FIRST__c,NAME_LAST__c,NAME_MIDDLE__c,Representative_Name__c,
                                     STREET__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,City__c,Pin_Code__c,State__c,
                                     Country__c,RW_Broker_Number__c,RW_Mobile_No__c,RW_Email__c,
                                     RW_NATURE_WORK__c,Legal_Form__c,Is_NRI_CP__c,Broker_Pan_No__c,RW_GST_Number__c,
                                     RW_RERA_Registration_Number__c,Payment_Terms__c,Individual_CP__c,RW_CreateFromIRIS__c FROM Broker__c 
                                     WHERE ID =:s[0].broker.id LIMIT 1];
        
   IrisAPIChannelPartnerRestCallout.ChannelPartnerRestCallOutPatch(lstBroker[0]);
           test.stoptest();

    }
       @istest
    public static void testchannelPartner2(){
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new UniversalIrisMockErrorClass());  
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
          RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string allstring = '[{ 	"NAME_FIRST__c": "testwmk2", "STR_SUPPL3__c":"STR_SUPPL3__c",	"NAME_LAST__c": "mk1e456", 	"Name": "runwal", 	"TITLE__c": "Mr.", 	"STREET__c": "Addressw1", 	"STR_SUPPL1__c": "Addwress2", 	"STR_SUPPL2__c": "Addwress3", 	"Broker_Type__c": "International", 	"City__c": "Mumbai", 	"Country__c": "India", 	"Is_NRI_CP__c": false, 	"Phone_2__c": "9964052499", 	"Pin_Code__c": "456666", 	"RW_Email__c": "manojkrishna.k.s+15@gmail.com", 	"Broker_Pan_No__c": "BLBBK95625V", 	"RW_GST_Number__c": null, 	"RW_Is_GST_Applicable__c": true, 	"RW_Is_RERA_Applicable__c": true, 	"RW_Mobile_No__c": "9987899999", 	"RW_Proof_of_Income__c": "PAN", 	"RW_RERA_Registration_Number__c": "567vvvds5432", 	"State__c": "KARNATAKA", 	"Zone__c": "Kalyan Dombivali", 	"RW_CreateFromIRIS__c": true }]	';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(allstring);
        RestContext.request = req;
        RestContext.response = res; 
        ChannelPartnerRestServices.insertCP();
      system.debug(res.responseBody.toString());
        List<ChannelPartnerRestServices.Response> s= (List<ChannelPartnerRestServices.Response>)json.deserialize(res.responseBody.toString(), List<ChannelPartnerRestServices.Response>.class); 
   
    system.debug(s[0].broker.id);
   //    SAPChannelPartnerAPICallOut.sendBrokerlist(s[0].broker.id);
          List<Broker__c> lstBroker = [SELECT Name,SAP_CP_Code__c,Aadhar_Card__c,TITLE__c,NAME_FIRST__c,NAME_LAST__c,NAME_MIDDLE__c,Representative_Name__c,
                                     STREET__c,STR_SUPPL1__c,STR_SUPPL2__c,STR_SUPPL3__c,City__c,Pin_Code__c,State__c,
                                     Country__c,RW_Broker_Number__c,RW_Mobile_No__c,RW_Email__c,
                                     RW_NATURE_WORK__c,Legal_Form__c,Is_NRI_CP__c,Broker_Pan_No__c,RW_GST_Number__c,
                                     RW_RERA_Registration_Number__c,Payment_Terms__c,Individual_CP__c,RW_CreateFromIRIS__c FROM Broker__c 
                                     WHERE ID =:s[0].broker.id LIMIT 1];
   IrisAPIChannelPartnerRestCallout.ChannelPartnerRestCallOutPatch(lstBroker[0]);
          test.stoptest();
  }
    
   


}