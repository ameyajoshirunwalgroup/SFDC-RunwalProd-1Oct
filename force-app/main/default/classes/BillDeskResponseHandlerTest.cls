@istest
public class BillDeskResponseHandlerTest {

    
    @testSetup
    private static void TestData() 
    {
        
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    	/*User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;*/
        
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
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
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
        
                Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
         Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = towerRec.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser.Id;
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = towerRec.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Relationship_Manager__c = ObjRm.Id;
        objPUU.Carpet_Area__c = 786;
        insert objPUU;
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Project_Unit__c = objPUU.ID;
        insert oppRec;
        
        objPUU.RW_Customer__c = oppRec.Id;
        update objPUU;
        
    }
    
    public static testMethod void  TestOne(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|02|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|D25B0C75959F79B70A82EF91E8321B551DAD72FA26EDF32D6956CB45E67573E7');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|03|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B970BFD98FA7394ADF43C5AC7D597340AF9B49CB74B5EC31C1B0AC75610A16A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|04|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|7CEFF2752ED96CE47D013F0ECF17393190F5270D12F627E1C89CCBC28B7A9024');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|05|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B928153E4C71E6860B6A1B65892ED92BEDF09B82E12CD21F06B6292356656726');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            /* req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|06|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|E124E47D24BD3A0A18514E84FEB34C117D9F85187DFFABE860C0ADC84206A7A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|07|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|C96BAA50FF0C949005F1EE017BEFBB05E3B33AC7ACBBA4D03862DDBA62406FFA');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        	req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|08|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4DB77BE7E84CAB0E5392EE36FBB844F39EE51CCBECA82CCF34C0DE830A9409E4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|09|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|05112415DC5E7C400FE2E2F0142852094108DB225874E290413C922CCCF199F4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|10|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|A9DE679FCBBA06C6BFAB1F6B0C78683507E448E2CD9A63DEE527D9717158B5AF');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();*/
        Test.stopTest();  
    }
    
    public static testMethod void  TestOneVersionTwo(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
           /* BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|02|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|D25B0C75959F79B70A82EF91E8321B551DAD72FA26EDF32D6956CB45E67573E7');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|03|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B970BFD98FA7394ADF43C5AC7D597340AF9B49CB74B5EC31C1B0AC75610A16A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|04|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|7CEFF2752ED96CE47D013F0ECF17393190F5270D12F627E1C89CCBC28B7A9024');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|05|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B928153E4C71E6860B6A1B65892ED92BEDF09B82E12CD21F06B6292356656726');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();*/
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|06|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|E124E47D24BD3A0A18514E84FEB34C117D9F85187DFFABE860C0ADC84206A7A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|07|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|C96BAA50FF0C949005F1EE017BEFBB05E3B33AC7ACBBA4D03862DDBA62406FFA');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        	req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|08|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4DB77BE7E84CAB0E5392EE36FBB844F39EE51CCBECA82CCF34C0DE830A9409E4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|09|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|05112415DC5E7C400FE2E2F0142852094108DB225874E290413C922CCCF199F4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|10|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|A9DE679FCBBA06C6BFAB1F6B0C78683507E448E2CD9A63DEE527D9717158B5AF');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        Test.stopTest();  
    }
    
     public static testMethod void  TestOneVersionThree(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetailsData();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|02|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|D25B0C75959F79B70A82EF91E8321B551DAD72FA26EDF32D6956CB45E67573E7');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|03|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B970BFD98FA7394ADF43C5AC7D597340AF9B49CB74B5EC31C1B0AC75610A16A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|04|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|7CEFF2752ED96CE47D013F0ECF17393190F5270D12F627E1C89CCBC28B7A9024');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|05|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B928153E4C71E6860B6A1B65892ED92BEDF09B82E12CD21F06B6292356656726');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
            /* req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|06|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|E124E47D24BD3A0A18514E84FEB34C117D9F85187DFFABE860C0ADC84206A7A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|07|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|C96BAA50FF0C949005F1EE017BEFBB05E3B33AC7ACBBA4D03862DDBA62406FFA');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        	req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|08|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4DB77BE7E84CAB0E5392EE36FBB844F39EE51CCBECA82CCF34C0DE830A9409E4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|09|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|05112415DC5E7C400FE2E2F0142852094108DB225874E290413C922CCCF199F4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|10|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|A9DE679FCBBA06C6BFAB1F6B0C78683507E448E2CD9A63DEE527D9717158B5AF');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();*/
        Test.stopTest();  
    }
    
     public static testMethod void  TestOneVersionFour(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
           /* BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|02|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|D25B0C75959F79B70A82EF91E8321B551DAD72FA26EDF32D6956CB45E67573E7');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|03|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B970BFD98FA7394ADF43C5AC7D597340AF9B49CB74B5EC31C1B0AC75610A16A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|04|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|7CEFF2752ED96CE47D013F0ECF17393190F5270D12F627E1C89CCBC28B7A9024');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|05|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|B928153E4C71E6860B6A1B65892ED92BEDF09B82E12CD21F06B6292356656726');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetails();*/
             req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|06|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|E124E47D24BD3A0A18514E84FEB34C117D9F85187DFFABE860C0ADC84206A7A1');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
            req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|07|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|C96BAA50FF0C949005F1EE017BEFBB05E3B33AC7ACBBA4D03862DDBA62406FFA');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
        	req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|08|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4DB77BE7E84CAB0E5392EE36FBB844F39EE51CCBECA82CCF34C0DE830A9409E4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|09|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|05112415DC5E7C400FE2E2F0142852094108DB225874E290413C922CCCF199F4');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|10|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|A9DE679FCBBA06C6BFAB1F6B0C78683507E448E2CD9A63DEE527D9717158B5AF');
        	RestContext.request = req;
            BillDeskResponseHandler.insertBillDeskDetailsData();
        Test.stopTest();  
    }
    
    public static testMethod void  TestTwo(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetailsData();
            
        Test.stopTest();  
    }
    
     public static testMethod void  TestThree(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|301000545|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetails();
            BillDeskResponseHandler.insertBillDeskDetailsData();
            
        Test.stopTest();  
    }
    
     public static testMethod void  TestFour(){
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetails();
            BillDeskResponseHandler.insertBillDeskDetailsData();
            
        Test.stopTest();  
    }
    
     public static testMethod void  TestFive(){
        
         List<Tower__c> tow = [Select Name from Tower__c];
         tow[0].Name = 'F';
         update tow[0];
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetails();
         BillDeskResponseHandler.insertBillDeskDetailsData();
            
        Test.stopTest();  
    }
    
    
   
     
    
  /*  public static testMethod void  Test1(){
        
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
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
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
        
                Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
         Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = towerRec.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser.Id;
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = towerRec.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Relationship_Manager__c = ObjRm.Id;
        objPUU.Carpet_Area__c = 786;
        insert objPUU;
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Project_Unit__c = objPUU.ID;
        insert oppRec;
        
        objPUU.RW_Customer__c = oppRec.Id;
        update objPUU;
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        //String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
        req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetails();
            
        Test.stopTest();  
    }
    */
    
     /*public static testMethod void  Test2(){
        
        Profile p = [Select Id, Name from Profile where Name = 'System Administrator'];

    	User u = new User(firstName = 'TestUser1', lastName = 'TestUser2', email='test@gmail.com',Username= 'username1@gmail.com', ProfileId = p.Id, alias= 'alias',EmailEncodingKey='UTF-8', 
                    LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles', LanguageLocaleKey='en_US', Phone='9874561230');
    	insert u;
        
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
        insert objpr;
        
        Tower__c towerRec = new Tower__c();
        towerRec.ProjectName__c = objpr.id;
        towerRec.Name = 'A';
        towerRec.RW_Terms_And_Conditions__c ='TC';
        insert towerRec;
        
        Offer__c offers = new Offer__c();
        offers.Name='TestOffer';
        insert offers;
        
        RW_Sub_Offer__c subOffers = new RW_Sub_Offer__c();
        subOffers.Name= 'TestSubOffer';
        subOffers.RW_Start_Date__c =  System.today();
        subOffers.RW_End_Date__c = System.today().addDays(10);
        subOffers.Project__c = objpr.Id;
        subOffers.Tower__c = towerRec.Id;
        subOffers.Offer__c = offers.id;
        subOffers.RW_Offer_Type__c = 'EOI';
        subOffers.RW_Approval_Status__c = 'Approved';
        insert subOffers;
        
        //Account a = TestDataFactory.createPATemplate('WC Account', 'wc@email.com','9098777',false);
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
        
                Project_Unit_Type__c objPUT = new Project_Unit_Type__c();
        objPUT.RDS_Code__c = '101';
        objPUT.RDS_Project__c = objpr.id;
        insert objPUT;
        
         Relationship_Manager__c ObjRm = new Relationship_Manager__c();
        ObjRm.Tower__c = towerRec.Id;
        ObjRm.Project__c = objpr.Id;
        ObjRm.User__c = tuser.Id;
        ObjRm.Contact_Number__c='9987654323';
        insert ObjRm; 
        
        Project_Unit__c objPUU = new Project_Unit__c();  
        objPUU.Project_Unit_Type__c = objPUT.id; 
        objPUU.TowerName__c = towerRec.Id;
        objPUU.Name = 'TestUnit';      
        objPUU.RW_Project__c = objpr.Id;
        objPUU.RW_Param1__c = '5';
        objPUU.UnitNo__c ='9';
        objPUU.RW_Unit_Status__c ='Available';
        
        objPUU.RW_Base_Rate__c = 3000;
        objPUU.Floor_Rise__c = 0;
        objPUU.RW_PLC__c = 200;
        objPUU.Unit_SAP_Code__c = '1000';
        objPUU.Relationship_Manager__c = ObjRm.Id;
        objPUU.Carpet_Area__c = 786;
        insert objPUU;
        
        
        Opportunity oppRec= new Opportunity();
        oppRec.RW_Project__c=objpr.id;
        oppRec.name='Test 1';
        oppRec.RW_Email__c=a.PersonEmail;
        oppRec.StageName='Qualification';
        oppRec.CloseDate=system.today();
        oppRec.Status__c ='Active';
        oppRec.AccountId = a.Id;
        oppRec.Sales_Manager__c = 'SM2@g.com';
        oppRec.Sourcing_Manager__c='Aniket Sapre';
        oppRec.RW_Sourcing_Head__c='Adrian Dsouza';
        oppRec.RW_Sales_Associate__c='Karthik Chettiar';
        oppRec.RW_Closing_Head__c='Karthik Chettiar';
        oppRec.Walkin_Source__c='Direct';
        oppRec.SAP_Customer_Number__c='0020006618';
        oppRec.SalesOrder_Number__c='3010005457';
        oppRec.RW_Project_Unit__c = objPUU.ID;
        insert oppRec;
        
        objPUU.RW_Customer__c = oppRec.Id;
        update objPUU;
        
         RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        //String str = '{\"msg\": \"BDSKUATY|R-6731|U1230002030862|1|02471247.00|123|NA|01|INR|DIRECT|NA|NA|00.00|19-07-2021 19:10:07|0300|NA|3010005450|0020010005|NA|NA|NA|NA|NA|NA|NA|0335C0B0C05BE0FCAB13F534D998CBFE2FCFD4A631E341BE5650467D94DE8394\"}';
        String body = 'msg=RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B';
        req.requestURI = 'https://runwalhomes.secure.force.com/BillDesk/services/apexrest/BillDeskResponseHandler'; 
        req.httpMethod = 'Post';
        //req.requestBody =Blob.valueOf(body);
         req.params.put('msg', 'RNWLEMPUAT|301836|U1230002051581|1|00342729.00|123|NA|01|INR|DIRECT|NA|NA|00.00|02-08-2021 18:26:53|0300|NA|3010005457|0020006618|Runwal Bliss A-5502|shobha.shetty@hotmail.com|9930998984|9010025680_27.07.2021|BOOKING AMOUNT due by 11.08.2021|NA|NA|4BF3D2CAC838580910CB7CB3A260A58F02C7F8D82CBA633BDA2BD1AF90F2E51B');
        
         req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res; 
        Test.startTest();
            BillDeskResponseHandler.insertBillDeskDetailsData();
            
        Test.stopTest(); 

    }*/
}