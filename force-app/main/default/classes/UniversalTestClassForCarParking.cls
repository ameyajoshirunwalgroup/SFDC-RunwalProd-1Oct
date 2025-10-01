@istest
public class UniversalTestClassForCarParking {
    @testSetup
    public static void setupdata(){
        //creating the legal entity
        //
        //
        user sitehead = UniversalTestClassSetup.createusers('System Administrator', 'site','headpriject','site.head@runwal.com.uat','site.headtest@runwal.com.uat');
        user salesmanager = UniversalTestClassSetup.createusers('Sales Manager', 'Deepak','Arya','salesmanager@runwal.com.uat','salesmanagertest@runwal.com.uat');
        user rm =UniversalTestClassSetup.createusers('Relationship Manager', 'relationship','Manager','rmanager@runwal.com.uat','rmanagertest@runwal.com.uat');
        UniversalTestClassSetup.assignpm(rm.id,'RM_Permission_Set');
        system.runAs(sitehead){
            
            Legal_Entity__c objlglentity = new Legal_Entity__c();
            objlglentity.Name = 'RS';
            objlglentity.RDS_Company_Code__c='rs';
            objlglentity.RDS_Service_Tax_No__c= '123456789012345';
            objlglentity.RDS_Company_Name__c='111';
            objlglentity.RDS_Address1__c='123';
            objlglentity.RDS_Address2__c='234';
            objlglentity.RDS_City__c='delhi';
            objlglentity.RDS_Pin_Code__c='201301';
            objlglentity.RDS_Phone__c='9953528045';
            objlglentity=RDSCommon.CreateLegalEntity(objlglentity);
            
            //create project
            //
            Project__c objpr = UniversalTestClassSetup.setupproject(sitehead.id,objlglentity.id);
            Car_Parking_Charge__c cp = new Car_Parking_Charge__c();
            cp.Project__c = objpr.id;
            cp.Category__c = 'Additional';
            cp.Status__c = 'Vacant';
            cp.Parking__c = 'Single Open';
            cp.SAP_Material_Code__c = 'abc';
            List<Car_Parking_Charge__c> cps = new List<Car_Parking_Charge__c>();
            cps.add(cp);
            Car_Parking_Charge__c cp1 = new Car_Parking_Charge__c();
            cp1.Project__c = objpr.id;
            cp1.Category__c = 'Additional';
            cp1.Status__c = 'Vacant';
            cp1.Parking__c = 'MLCP';
            cp1.SAP_Material_Code__c = 'abc1';
            cps.add(cp1);
            Car_Parking_Charge__c cp2 = new Car_Parking_Charge__c();
            cp2.Project__c = objpr.id;
            cp2.Category__c = 'Additional';
            cp2.Status__c = 'Vacant';
            cp2.Parking__c = 'Stilt';
            cp2.SAP_Material_Code__c = 'abc2';
            cps.add(cp2);
            Car_Parking_Charge__c cp3 = new Car_Parking_Charge__c();
            cp3.Project__c = objpr.id;
            cp3.Category__c = 'Additional';
            cp3.Status__c = 'Sold';
            cp3.Parking__c = 'Covered Stack';
            cp3.SAP_Material_Code__c = 'abc7';
            cps.add(cp3);
            Car_Parking_Charge__c cp4 = new Car_Parking_Charge__c();
            cp4.Project__c = objpr.id;
            cp4.Category__c = 'Additional';
            cp4.Status__c = 'Vacant';
            cp4.Parking__c = 'Single Covered';
            cp4.SAP_Material_Code__c = 'abcerwe';
                        cps.add(cp4);

                Car_Parking_Charge__c cp5 = new Car_Parking_Charge__c();
            cp5.Project__c = objpr.id;
            cp5.Category__c = 'Additional';
            cp5.Status__c = 'Vacant';
            cp5.Parking__c = 'Tandem Covered';
            cp5.SAP_Material_Code__c = 'abcderwe';
                        cps.add(cp5);

                Car_Parking_Charge__c cp6 = new Car_Parking_Charge__c();
            cp6.Project__c = objpr.id;
            cp6.Category__c = 'Additional';
            cp6.Status__c = 'Vacant';
            cp6.Parking__c = 'Tandem Open';
            cp6.SAP_Material_Code__c = 'abcerdfwe';
                        cps.add(cp6);

            insert cps; 
        }
    }
    
    @istest
    public static void testcarpark(){
        
        List<Car_Parking_Charge__c> cps = [select id from Car_Parking_Charge__c];
        List<Id> carParkingChargeids = new List<id>();
        for(Car_Parking_Charge__c cpc : cps){
            carParkingChargeids.add(cpc.id);
        }
        test.startTest();
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        CarParkingCallout.sendCarPakingList(carParkingChargeids);
        test.stopTest();
    }
    
    @istest
    public static void testInventoryException(){
        Project__c p = [select id from Project__c limit 1];
        List<Car_Parking_Charge__c> cps = [select id from Car_Parking_Charge__c];
        //project unit
        try{
            List<Id> carParkingChargeids = new List<id>();
            for(Car_Parking_Charge__c cpc : cps){
                carParkingChargeids.add(cpc.id);
            }
            Test.startTest();  
            Test.setMock(WebServiceMock.class, new UniversalSAPMockErrorClass());  
            CarParkingCallout.sendCarPakingList(carParkingChargeids);
            test.stopTest();
            
        }
        catch(CalloutException e){
            
            
        }
        
        
    }
    
    @istest
    public static void testcarpark3(){
        Test.setMock(WebServiceMock.class, new UniversalSAPMockClass());
        try{
            List<Car_Parking_Charge__c> cps = [select id from Car_Parking_Charge__c where Parking__c = 'Covered Stack'];
            cps[0].Status__c = 'Vacant';
            test.startTest();
            
            update cps;
            test.stopTest();
        }
        catch(exception e){
            
        }
        /* List<Id> carParkingChargeids = new List<id>();
for(Car_Parking_Charge__c cpc : cps){
carParkingChargeids.add(cpc.id);
}*/
        // CarParkingCallout.sendCarPakingList(carParkingChargeids);
    }
    
}