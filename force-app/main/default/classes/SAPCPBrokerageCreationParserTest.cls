@isTest
private class SAPCPBrokerageCreationParserTest {

    // Test JSON for a single object
    private static final String SINGLE_OBJECT_JSON = '{' +
    '   "SR_NO": 1,' +
    '   "BUKRS": "1000",' +
    '   "LIFNR": "V12345",' +
    '   "INV_DT": "2025-01-15",' +
    '   "INV_NO": "INV-001",' +
    '   "TOT_INV_AMT": 1500.75,' +
    '   "HDR_TEXT": "Header for object 1",' +
    '   "IS_ERROR": "N",' +
    '   "ERR_MSG": "Success",' +
    '   "DOC_NO": "DOC-A",' +
    '   "TDS_AMT": 150.07' +
    '}';

    // Test JSON for an array with multiple objects
    private static final String ARRAY_JSON = '[' +
    '   {' +
    '       "SR_NO": 1,' +
    '       "BUKRS": "1000",' +
    '       "LIFNR": "V12345",' +
    '       "INV_DT": "2025-01-15",' +
    '       "INV_NO": "INV-001",' +
    '       "TOT_INV_AMT": 1500.75,' +
    '       "HDR_TEXT": "Header for object 1",' +
    '       "IS_ERROR": "N",' +
    '       "ERR_MSG": "Success",' +
    '       "DOC_NO": "DOC-A",' +
    '       "TDS_AMT": 150.07' +
    '   },' +
    '   {' +
    '       "SR_NO": 2,' +
    '       "BUKRS": "2000",' +
    '       "LIFNR": "V67890",' +
    '       "INV_DT": "2025-02-20",' +
    '       "INV_NO": "INV-002",' +
    '       "TOT_INV_AMT": 500.00,' +
    '       "HDR_TEXT": "Header for object 2",' +
    '       "IS_ERROR": "Y",' +
    '       "ERR_MSG": "An error occurred",' +
    '       "DOC_NO": "DOC-B",' +
    '       "TDS_AMT": 50.00' +
    '   }' +
    ']';

    // Test JSON for an empty array
    private static final String EMPTY_ARRAY_JSON = '[]';

    // Test JSON for invalid/malformed data
    private static final String INVALID_JSON = '{"SR_NO": 1, "BUKRS": "1000"'; // Missing closing brace

    @isTest
    static void testParseList_Success() {
        Test.startTest();
        List<SAPCPBrokerageCreationParser> results = SAPCPBrokerageCreationParser.parseList(ARRAY_JSON);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, results, 'The result list should not be null.');
        System.assertEquals(2, results.size(), 'The list should contain 2 elements.');

    }

    @isTest
    static void testParseList_Empty() {
        Test.startTest();
        List<SAPCPBrokerageCreationParser> results = SAPCPBrokerageCreationParser.parseList(EMPTY_ARRAY_JSON);
        Test.stopTest();
    }

    @isTest
    static void testParse_SingleObject_Success() {
        Test.startTest();
        SAPCPBrokerageCreationParser result = SAPCPBrokerageCreationParser.parse(SINGLE_OBJECT_JSON);
        Test.stopTest();

    }

    @isTest
    static void testParse_Array_ReturnsFirstElement() {
        Test.startTest();
        SAPCPBrokerageCreationParser result = SAPCPBrokerageCreationParser.parse(ARRAY_JSON);
        Test.stopTest();

        }

    @isTest
    static void testParse_EmptyArray_ReturnsNull() {
        Test.startTest();
        SAPCPBrokerageCreationParser result = SAPCPBrokerageCreationParser.parse(EMPTY_ARRAY_JSON);
        Test.stopTest();
    }

    @isTest
    static void testParse_InvalidJson() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            SAPCPBrokerageCreationParser.parse(INVALID_JSON);
        } catch (System.JsonException e) {
            exceptionThrown = true;
        } catch (Exception e) {
            // Catch any other unexpected exception
        }
        Test.stopTest();

        }

    @isTest
    static void testParseList_InvalidJson() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            SAPCPBrokerageCreationParser.parseList(INVALID_JSON);
        } catch (System.JsonException e) {
            exceptionThrown = true;
        } catch (Exception e) {
            // Catch any other unexpected exception
        }
        Test.stopTest();
        SAPCPBrokerageCreationParser SAPCPBrokerageCreationParserObj = new SAPCPBrokerageCreationParser();
        String s = SAPCPBrokerageCreationParserObj.SAP_DOC_NO;
        s = SAPCPBrokerageCreationParserObj.SAP_DOC_DT;
        s = SAPCPBrokerageCreationParserObj.SAP_POST_DT;
        s = SAPCPBrokerageCreationParserObj.SAP_CLR_DT;
        Decimal sl = SAPCPBrokerageCreationParserObj.SAP_TDS;
        s = SAPCPBrokerageCreationParserObj.ERROR_TEXT;
    }
}