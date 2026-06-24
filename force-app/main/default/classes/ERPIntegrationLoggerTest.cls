@IsTest
public class ERPIntegrationLoggerTest {

    @IsTest
    static void testStandardLogMethod() {

        Test.startTest();

        ERPIntegrationLogger.log(
            'TestClass',
            'testMethod',
            'Test API',
            'BOOK123',
            'EXT123',
            '{"req":"sample"}',
            '{"res":"sample"}',
            'SUCCESS',
            null,
            null
        );

        Test.stopTest();

    }


    @IsTest
    static void testAdvancedLogMethod_WithHttpAndExecutionTime() {

        Test.startTest();

        ERPIntegrationLogger.log(
            'AdvClass',
            'advMethod',
            'Advanced API',
            'BOOK999',
            'EXT999',
            'REQUEST DATA',
            'RESPONSE DATA',
            'FAIL',
            'SYSTEM_EXCEPTION',
            'Something went wrong',
            500,
            2,
            350L
        );

        Test.stopTest();

        
    }


    @IsTest
    static void testSafeStringTruncation() {

        // Create 140k character string
        String longString = '';
        for(Integer i = 0; i < 140000; i++){
            longString += 'A';
        }

        Test.startTest();

        ERPIntegrationLogger.log(
            'LongClass',
            'longMethod',
            'Long API',
            'BOOKLONG',
            'EXTLONG',
            longString,
            longString,
            'SUCCESS',
            null,
            null
        );

        Test.stopTest();

    }


    @IsTest
    static void testNullInputs() {

        Test.startTest();

        ERPIntegrationLogger.log(
            'NullClass',
            'nullMethod',
            'Null API',
            null,
            null,
            null,
            null,
            'FAIL',
            null,
            null
        );

        Test.stopTest();

    }
}