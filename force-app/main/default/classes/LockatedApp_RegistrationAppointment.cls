@RestResource(urlMapping='/registration/*')
global without sharing class LockatedApp_RegistrationAppointment {
    
     @HttpGet
    global static void doGet(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String bkgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, Object> errorResult = new Map<String, Object>();
        System.debug('bkgId: ' + bkgId);
        if(String.isBlank(bkgId) || bkgId == 'registration'){
            errorResult.put('status', 'error');
            errorResult.put('message', 'Please pass the Booking Id');
            res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
            res.statusCode = 400;
        }else{
            List<Registration_Schedule__c> regs = [SELECT Id,Address__c,Registration_Schedule_Date__c,Registration_Schedule_Time__c,Venue__c,Booking__r.Unit_No__r.Relationship_Manager__r.Contact_Number__c FROM Registration_Schedule__c WHERE Booking__c =: bkgId AND Active__c = true]; 
            if(regs.size() > 0){
                Schedule sch = new Schedule();
                Appointment app = new Appointment();
                app.appointmentDateTime = String.valueOf(regs[0].Registration_Schedule_Date__c) + ' ' + String.valueOf(regs[0].Registration_Schedule_Time__c);
                Address addr = new Address();
                addr.address = regs[0].Address__c;
                app.registrationAddress = addr;
                Contact con = new Contact();
                con.rmNumber = regs[0].Booking__r.Unit_No__r.Relationship_Manager__r.Contact_Number__c;
                app.contactPerson = con;
                sch.registrationAppointment = app;
                //return sch;
                res.responseBody = Blob.valueOf(JSON.serialize(sch));
                res.statusCode = 200;
            }else{
                errorResult.put('status', 'error');
                errorResult.put('message', 'No Registration appointments found fo this booking');
                res.responseBody = Blob.valueOf(JSON.serialize(errorResult));
                res.statusCode = 400;
            }
            
        }
    }
    
    global class Schedule{
        public Appointment registrationAppointment;
    }
    
    public class Appointment{
        public String appointmentDateTime;
        public Address registrationAddress;
        public Contact contactPerson;
    }
    public class Address{
        public String mapLink;
        public String address;
    }
    public class Contact{
        public String rmNumber;
    }

}