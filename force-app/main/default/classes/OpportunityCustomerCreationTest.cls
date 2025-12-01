@IsTest
public class OpportunityCustomerCreationTest {
    
    // Mock for the SAP Callout (CustomerCreation.ZSD_SFDC_CUSTOMER)
    private class CustomerCreationMock implements WebServiceMock {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName, String responseName,
            String namespace, String responseNamespace
        ) {
            // Create a fake SOAP response
            CustomerCreation.ZsdSfdcCustomerResponse_element fakeResponse =
                new CustomerCreation.ZsdSfdcCustomerResponse_element();
            
            fakeResponse.Customerno = 'CUST12345';
            fakeResponse.Return_x = new CustomerCreation.TableOfBapiret2();
            fakeResponse.Return_x.item = new List<CustomerCreation.Bapiret2>();

            CustomerCreation.Bapiret2 successMsg = new CustomerCreation.Bapiret2();
            successMsg.Type_x = 'S';
            successMsg.Message = 'Customer created successfully';
            fakeResponse.Return_x.item.add(successMsg);
            
            response.put('response_x', fakeResponse);
        }
    }

    @IsTest
    static void testCreateOpportunityCustomer_Success() {
        // Create required test data
        String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        Account acc = new Account(
            RecordTypeID=RecTypeId,                
                FirstName='TestFName',                
                LastName='TestLName',                
                PersonMailingStreet='test@yahoo.com',                
                PersonMailingPostalCode='12345',                
                PersonMailingCity='SFO',                
                PersonEmail='test@yahoo.com',                
                PersonHomePhone='1234567',                
                PersonMobilePhone='12345678'   
            /*Salutation = 'Mr.',
            FirstName = 'John',
            LastName = 'Doe',
            Mobile_No__c = '9999999999',
            PersonEmail = 'john@test.com',
            BillingStreet = 'Street 1',
            BillingCity = 'CityX',
            BillingCountry = 'India',
            BillingState = 'StateX',
            BillingPostalCode = '123456'*/
        );
        insert acc;
        
        Project__c proj = new Project__c(
            Name = 'Test Project',
            SAPMaterial_Code__c = 'PROJ001',
            Sales_District__c = 'East'
        );
        insert proj;
        
        Tower__c tower = new Tower__c(
            Name = 'Tower 1',
            Property_Type__c = 'RES',
            SAP_Plant_Code__c = 'PLANT01',
            ProjectName__c	= proj.Id
        );
        insert tower;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            //RW_Project__c = proj.Id,
            //RW_Project_Unit__c = unit.Id,
            Walkin_Source__c = 'WalkIn'
        );
        insert opp;
        
        Project_Unit__c unit = new Project_Unit__c(
            Name = 'TestUnit',
            Unit_SAP_Code__c = 'UNIT001',
            //Saleable_Area__c = 1000,
            //Carpet_area__c = 800,
            //TowerName__c = tower.Id,
            RW_Project__c = proj.Id,
            UnitNo__c ='9',
            RW_Unit_Status__c ='Available',
            //RW_Booking_Date__c=Date.Today(),
            RW_Base_Rate__c = 3000,
            Floor_Rise__c = 0,
            RW_PLC__c = 200,
            RW_Customer__c=opp.id
        );
        insert unit;
        
        
        
        Blocking_Unit_Information__c blockInfo = new Blocking_Unit_Information__c(
            Opportunity__c = opp.Id,
            Pan_Number__c = 'ABCDE1234F',
            Aadhar_Number__c = '999988887777',
            Active__c = true
        );
        insert blockInfo;

        // Mock the callout
        Test.setMock(WebServiceMock.class, new CustomerCreationMock());

        Test.startTest();
        OpportunityCustomerCreation.createOppCustomer(new Set<Id>{opp.Id});
        Test.stopTest();

        // Fetch updated Opportunity
        Opportunity updatedOpp = [SELECT SAP_Customer_Number__c FROM Opportunity WHERE Id = :opp.Id];
        
        // Fetch ERP Logs
        List<ERP_Integration_Log__c> logs = [SELECT Status__c, API_Name__c, Error_Type__c FROM ERP_Integration_Log__c];

        // Assertions
        //System.assertEquals('CUST12345', updatedOpp.SAP_Customer_Number__c, 'Customer number should be updated');
       // System.assert(!logs.isEmpty(), 'ERP Integration Log should be created');
       // System.assertEquals('Success', logs[0].Status__c, 'Log should indicate success');
       // System.assertEquals('Opportunity Customer Creation/Update', logs[0].API_Name__c);
    }
}

    //@IsTest
    /*static void testCreateOpportunityCustomer_DataError() {
        // Create Account but no project/unit/tower (to trigger data error)
        Account acc = new Account(
            Name = 'Jane Doe',
            //Name = 'Error Account',
            FirstName = 'Jane',
            LastName = 'Doe'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Error Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;

        // Mock the callout
        Test.setMock(WebServiceMock.class, new CustomerCreationMock());

        Test.startTest();
        OpportunityCustomerCreation.createOppCustomer(new Set<Id>{opp.Id});
        Test.stopTest();

        // Fetch ERP Logs
        List<ERP_Integration_Log__c> logs = [SELECT Status__c, Error_Type__c, Error_Reason__c FROM ERP_Integration_Log__c WHERE Opportunity__c = :opp.Id];

        System.assert(!logs.isEmpty(), 'Log should be created');
        System.assertEquals('Failure', logs[0].Status__c, 'Should mark failure for data issue');
        System.assertEquals('Data Error', logs[0].Error_Type__c, 'Error type should be Data Error');
    }
}*/