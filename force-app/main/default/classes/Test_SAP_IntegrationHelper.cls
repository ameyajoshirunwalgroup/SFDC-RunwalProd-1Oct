@isTest
public class Test_SAP_IntegrationHelper {


    @isTest
    static void testInsertLogEntry_ADFCalculation() {
        // Sample Booking record to simulate parent object
        Booking__c booking = new Booking__c(ADF_Opted__c = true);
        insert booking;

        Test.startTest();
        SAP_IntegrationHelper.insertLogEntry('ADF Calculation','Success',booking.Id,null,'Sample Request','Sample Response','No Error', null);
        Test.stopTest();

        List<ERP_Integration_Log__c> logs = [SELECT API_Name__c, Status__c, Booking__c, Request__c, Response__c, Error_Reason__c 
                                             FROM ERP_Integration_Log__c WHERE API_Name__c = 'ADF Calculation'];
        System.assertEquals(1, logs.size());
        
       
    }

    @isTest
    static void testInsertLogEntry_ADFCreditNote() {
        Booking__c booking = new Booking__c(ADF_Opted__c = true);
        insert booking;

        Credit_Note__c creditNote = new Credit_Note__c(Booking__c = booking.Id, Interest_To_Be_Settled__c = 9000.80);
        insert creditNote;

        Test.startTest();
        SAP_IntegrationHelper.insertLogEntry(
            'ADF Credit Note',
            'Failure',
            creditNote.Id,
            booking.Id,
            'Credit Note Request',
            'Credit Note Response',
            'Failed due to XYZ',
            null
        );
        Test.stopTest();

        ERP_Integration_Log__c log = [SELECT Credit_Note__c, Booking__c, API_Name__c, Status__c, Request__c, Response__c, Error_Reason__c 
                                      FROM ERP_Integration_Log__c WHERE API_Name__c = 'ADF Credit Note' LIMIT 1];
        System.assertEquals(creditNote.Id, log.Credit_Note__c);
        System.assertEquals(booking.Id, log.Booking__c);
      
    }

    @isTest
    static void testInsertLogEntry_InterestWaiver() {
         
        Booking__c booking = new Booking__c(ADF_Opted__c = true);
        insert booking;

        RW_Demand__c demand = new RW_Demand__c(
            Name = 'Test Demand',
            Booking__c = booking.Id,
            RW_Demand_Status__c = 'Due',
            Due_Date__c = Date.today().addDays(-5),
            PTP_Date__c = Date.today().addDays(-3)
        );
        insert demand;

        Interest_Waiver__c waiver = new Interest_Waiver__c(Booking__c = booking.Id, Demand__c = demand.Id, Waiver_Amount__c = 90000);
        insert waiver;

        Test.startTest();
        SAP_IntegrationHelper.insertLogEntry(
            'Interest Waiver',
            'Success',
            waiver.Id,
            demand.Id,
            'Waiver Request',
            'Waiver Response',
            '',
            null
        );
        
        Test.stopTest();

        ERP_Integration_Log__c log = [SELECT Interest_Waiver__c, Demand__c, API_Name__c, Status__c, Request__c, Response__c, Error_Reason__c 
                                      FROM ERP_Integration_Log__c WHERE API_Name__c = 'Interest Waiver' LIMIT 1];
        System.assertEquals(waiver.Id, log.Interest_Waiver__c);
        System.assertEquals(demand.Id, log.Demand__c);
     
    }
}