@isTest
public class BookingFormControllerTest {
    
    @isTest
    public static void bkgFromTest1(){
                
        String orgId1 = UserInfo.getOrganizationId();
        String dateString1 = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt1 = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName1 = orgId1 + dateString1 + randomInt1;
        User tuser1 = new User(  firstname = 'TestUser',
                               lastName = 'TestUser',
                               email = uniqueName1 + '@gmail' +'.com',
                               Username = uniqueName1 + '@test' + orgId1 + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName1.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               ProfileId = System.label.System_Administrator_Profile_Id
                              );
        insert tuser1;
        
        system.runAs(tuser1){
            Booking__c objBking = new Booking__c();
            objBking.Booking_Date__c = Date.today().addDays(-1);
            objBking.Status__c ='Booking Confirmed';
            insert objBking;
            
            ContentVersion contentVersion = new ContentVersion(
              Title = 'SalarySLip',
              PathOnClient = 'SalarySLip.jpg',
              VersionData = Blob.valueOf('Test Content'),
              IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            Map<String,String> DocDetails1 = new Map<String,String>();
            DocDetails1.put('bookingId',objBking.Id);
            DocDetails1.put('documentId',documents[0].id);
            DocDetails1.put('fileType','Booking Form');
            
            Map<String,String> DocDetails2 = new Map<String,String>();
            DocDetails2.put('bookingId',objBking.Id);
            DocDetails2.put('documentId',documents[0].id);
            DocDetails2.put('fileType','Signed Cost Sheet');
            
            Map<String,String> DocDetails3 = new Map<String,String>();
            DocDetails3.put('bookingId',objBking.Id);
            DocDetails3.put('documentId',documents[0].id);
            DocDetails3.put('fileType','IOM');
            
            Map<String,String> DocDetails4 = new Map<String,String>();
            DocDetails4.put('bookingId',objBking.Id);
            DocDetails4.put('documentId',documents[0].id);
            DocDetails4.put('fileType','Deviation Approvals');
            
            Map<String,String> DocDetails5 = new Map<String,String>();
            DocDetails5.put('bookingId',objBking.Id);
            DocDetails5.put('documentId',documents[0].id);
            DocDetails5.put('fileType','Token Payment Details');
            
            BookingFormController.getBookingRecord(objBking.Id);
            BookingFormController.updateBookingFormData(DocDetails1);
            BookingFormController.updateBookingFormData(DocDetails2);
            BookingFormController.updateBookingFormData(DocDetails3);
            BookingFormController.updateBookingFormData(DocDetails4);
            BookingFormController.updateBookingFormData(DocDetails5);
            BookingFormController.getFiles(new List<String>{documents[0].id});
            BookingFormController.deleteFiles(documents[0].id, 'BookingForm', objBking.Id);
            BookingFormController.deleteFiles(documents[0].id, 'SignedCostSheet', objBking.Id);
            BookingFormController.deleteFiles(documents[0].id, 'iom', objBking.Id);
            BookingFormController.deleteFiles(documents[0].id, 'DeviationApprovals', objBking.Id);
            BookingFormController.deleteFiles(documents[0].id, 'TokenPaymentDetails', objBking.Id);
            BookingFormController.updateCheckBox(objBking.Id, 'true', 'Booking Form');
            BookingFormController.updateCheckBox(objBking.Id, 'true', 'Signed Cost Sheet');
            BookingFormController.updateCheckBox(objBking.Id, 'true', 'IOM');
            BookingFormController.updateCheckBox(objBking.Id, 'true', 'Deviation Approval');
            BookingFormController.updateCheckBox(objBking.Id, 'true', 'Token Payment');
        }
        
    }

}