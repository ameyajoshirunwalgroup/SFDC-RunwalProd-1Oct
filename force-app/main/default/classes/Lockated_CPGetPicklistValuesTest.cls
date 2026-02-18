@IsTest
public class Lockated_CPGetPicklistValuesTest {

    @IsTest
    static void testDoGet() {
        Test.startTest();
        Lockated_CPGetPicklistValues.ResponseWrapper res =
            Lockated_CPGetPicklistValues.doGet();
        Test.stopTest();

    }

   

    @IsTest
    static void testGetDependentPicklist() {
        Lockated_CPGetPicklistValues.PicklistWrapper pw =
            Lockated_CPGetPicklistValues.getDependentPicklist(
                'Case',
                'Case_Category__c',
                'Case_Sub_Category__c'
            );

    }

    @IsTest
    static void testThreeLevelPicklistNew() {
        Map<String, Map<String, List<String>>> hierarchy =
            Lockated_CPGetPicklistValues.getThreeLevelPicklistNew(
                'Lead',
                'Country__c',
                'State__c',
                'City__c'
            );

    }

    @IsTest
    static void testBase64Helpers() {
        String bits = Lockated_CPGetPicklistValues.base64ToBits('A');

        String binary = Lockated_CPGetPicklistValues.decimalToBinary(5);
    }
}