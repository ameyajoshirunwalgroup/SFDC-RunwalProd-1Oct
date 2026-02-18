@isTest
public class Lockated_CPOfferMasterDetailsTest {
	@isTest
    static void TestCase1(){
        
        Project__c objpr = new Project__c();
        objpr.RW_Project_Code__c = 'T31';
        objpr.Name = 'Runwal Bliss';
        objpr.RDS_Short_Name__c = 'T';
        objpr.Start_Date__c = System.today().addDays(-5);
        objpr.RDS_Interest_Rate__c = 12;
        insert objpr;
        
        list<Offer_Master__c> offlist = new list<Offer_Master__c>();
        Offer_Master__c o = new Offer_Master__c();
        o.Discount_Category__c = 'Monetary';
        o.End_Date__c = system.today()+199;
        o.Offer_calculation__c = 'Lumpsum';
        o.Name = 'Test';
        o.Offer_type__c = 'Non Mandatory';
        o.Offer_Value__c = 5660;
        o.Start_Date__c = system.today()-19;
        o.Project__c = objpr.id;
        offlist.add(o);
        insert offlist;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'GET';
        req.requestURI = '/services/apexrest/cpGetDetails';
        
        RestContext.request = req;
        RestContext.response = res;
        
        // 4️⃣ Call REST method
        Test.startTest();
        Lockated_CPOfferMasterDetails.doGet();
        Test.stopTest();
            
    }
}