//Added by Prashant to Create Referral Credit Record when customer is due.. //// 01-08-2025.////
global class CreateReferralCreditsonDue implements Database.Batchable<sObject>,Schedulable, Database.Stateful {
   
    global Iterable<Booking__c> start(Database.BatchableContext BC) {

        List<Booking__c> bkgs = [SELECT Id, Name, Unit_No__r.Relationship_Manager__r.User__c, Customer__r.SAP_Customer_Number__c, Customer_Reference_Opportunity__r.SAP_Customer_Number__c, 
                                 Customer_Reference_Opportunity__r.Booking__c, Customer_Reference_Flat_No__c, Customer_Reference_Primary_Applicant_Nam__c, Unit_Number__c, 
                                 Primary_Applicant_Name__c, Referral_Amount_to_be_Adjusted__c, Project__r.CRM_MIS_Head__c, Project__r.CRMHead__c, Actual_Referral_Amount__c,
                                 TDS_5_to_be_deducted__c, X1_of_Agreement_Value__c, Referral__c, Source_of_Booking__c, Sub_Source__c, Registration_Status__c, Referral_Passback__c,
                                 X20_Received_Date__c, Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c FROM Booking__c 
                                 WHERE Source_of_Booking__c = 'Referral' AND Sub_Source__c = 'Existing client reference' AND Registration_Status__c = 'Due' AND Referral_Passback__c != 0 AND 
                                 Referral_Passback__c <=1 AND X20_Received_Date__c = TODAY AND Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c != NULL];

        return bkgs;
    }

    global void execute(Database.BatchableContext bc, List<Booking__c> bookings) {
        system.debug('bookings[0].Source_of_Booking__c -> '+ bookings[0].Source_of_Booking__c);
        system.debug('bookings[0].Sub_Source__c -> ' + bookings[0].Sub_Source__c);
        system.debug('bookings[0].Registration_Status__c -> ' + bookings[0].Registration_Status__c);
        system.debug('bookings[0].Referral_Passback__c -> ' + bookings[0].Referral_Passback__c);
        system.debug('bookings[0].X20_Received_Date__c -> ' + bookings[0].X20_Received_Date__c);
        system.debug('bookings[0].Customer_Reference_Opportunity__r -> ' + bookings[0].Customer_Reference_Opportunity__c);
        system.debug('bookings[0].Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c -> ' + bookings[0].Customer_Reference_Opportunity__r.Booking__r.X20_Received_Date__c);
        
        list<Referral_Credits__c> rflist = new list<Referral_Credits__c>();
        for (Booking__c b : bookings) {
            Referral_Credits__c r = new Referral_Credits__c();
            r.Accounts_Head__c = null;//To be Assigned...
            r.Booking_RM__c = b.Unit_No__r.Relationship_Manager__r.User__c;
            r.Booking__c = b.Id;
            r.CRN__c = b.Customer__r.SAP_Customer_Number__c;
            r.Existing_Customer_CRN__c = b.Customer_Reference_Opportunity__r.SAP_Customer_Number__c;
            r.Existing_Customer_Flat_no__c = b.Customer_Reference_Flat_No__c;
            r.Flat_no__c = b.Unit_Number__c;
            r.Name_of_Existing_Customer__c = b.Customer_Reference_Primary_Applicant_Nam__c;
            r.Name_of_New_Customer__c = b.Primary_Applicant_Name__c;
            r.Reference_Booking__c = b.Customer_Reference_Opportunity__r.Booking__c;
            r.Referral_Amount_Due__c = b.Referral_Amount_to_be_Adjusted__c;
            r.Referral_Credit_Approver_L1__c = b.Project__r.CRM_MIS_Head__c;
            r.Referral_Credit_Approver_L2__c = b.Project__r.CRMHead__c;
            r.Referral_In_Rs__c = b.Actual_Referral_Amount__c;
            r.TDS_5_to_be_deducted__c = b.TDS_5_to_be_deducted__c;
            r.X1_of_Agreement_Value__c = b.X1_of_Agreement_Value__c;
            String longText = '';
            longText = 'Customer Referral' +' '+ '('+ b.Primary_Applicant_Name__c +' )' +b.Unit_Number__c +' - '+  b.Referral__c +'%';
            r.long_text1__c = longText;
            rflist.add(r);
        }

        if (!rflist.isEmpty()) {
            system.debug('rflist -->>'+rflist);
            Database.insert(rflist, false);
        }
    }

    global void finish(Database.BatchableContext bc) {}

    global void execute(SchedulableContext sc) {
        CreateReferralCreditsonDue job = new CreateReferralCreditsonDue();
        Database.executeBatch(job, 20);
    }
}