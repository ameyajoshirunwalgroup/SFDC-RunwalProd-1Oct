trigger Apptrig on Applicant_Details__c (After insert, After update) 
{
    
    ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
    Boolean byPassTriggerExceution = false;
    for(ByPassTriggers__mdt bypass : byPasstrigMappings)
    {
        if(bypass.Object_Name__c == 'Applicant_Details__c' && bypass.ByPassTrigger__c)
        {
            byPassTriggerExceution = true;
        }
    }
    if(!byPassTriggerExceution)
    {
        list<Applicant_Details__c> lstApp = new list<Applicant_Details__c>(trigger.new);
        system.debug('lstTask ' +lstApp);
        CopyApptoOpty.updateOPTY(lstApp);
        CopyAppttoBooking.updateBooking(lstApp);
        
        
        set<Id> applicantIds = new Set<Id>();
        set<Id> opportunityIds = new Set<Id>();
        if(Trigger.isUpdate)
        {
            List<LockatedApp_UserDetailUpdate.ApplicantUpdateWrap> appUpdateWrapperList = new List<LockatedApp_UserDetailUpdate.ApplicantUpdateWrap>(); //Added by Vinay 30-12-2025
            List<Id> addressChangedApplicantIds = new List<Id>(); //Added by Vinay 14-01-2026
            List<Id> phoneChangedApplicantIds = new List<Id>(); //Added by Vinay 14-01-2026
            for(Applicant_Details__c app : trigger.new)
            {
                system.debug('*inside for 1*');
                system.debug(app.id);
                if(app.Address_Proof_Document__c != trigger.oldMap.get(app.Id).Address_Proof_Document__c
                   || app.Salutation__c != trigger.oldMap.get(app.Id).Salutation__c
                   || app.First_Name__c != trigger.oldMap.get(app.Id).First_Name__c
                   || app.Middle_Name__c != trigger.oldMap.get(app.Id).Middle_Name__c
                   || app.Last_Name__c != trigger.oldMap.get(app.Id).Last_Name__c
                   || app.gender__c != trigger.oldMap.get(app.Id).gender__c 
                   || app.Marital_Status__c != trigger.oldMap.get(app.Id).Marital_Status__c
                   || app.Nationality_Picklist__c != trigger.oldMap.get(app.Id).Nationality_Picklist__c
                   || app.Occupation__c != trigger.oldMap.get(app.Id).Occupation__c
                   || app.Designation__c != trigger.oldMap.get(app.Id).Designation__c
                   || app.Subtype_Of_Applicant__c != trigger.oldMap.get(app.Id).Subtype_Of_Applicant__c
                   || app.DOB__c != trigger.oldMap.get(app.Id).DOB__c
                   || app.Organization_Name__c != trigger.oldMap.get(app.Id).Organization_Name__c
                   || app.PancardNo__c != trigger.oldMap.get(app.Id).PancardNo__c
                   || app.Address_Proof_Number__c != trigger.oldMap.get(app.Id).Address_Proof_Number__c
                   || app.PassportNoDetails__c != trigger.oldMap.get(app.Id).PassportNoDetails__c
                   || app.Mailing_Address_Line_1__c != trigger.oldMap.get(app.Id).Mailing_Address_Line_1__c
                   || app.Mailing_Address_Line_2__c != trigger.oldMap.get(app.Id).Mailing_Address_Line_2__c
                   || app.Mailing_Address_Line_3__c != trigger.oldMap.get(app.Id).Mailing_Address_Line_3__c
                   || app.Mailing_Pincode__c != trigger.oldMap.get(app.Id).Mailing_Pincode__c
                   || app.Mailing_City__c != trigger.oldMap.get(app.Id).Mailing_City__c
                   || app.Mailing_Country__c != trigger.oldMap.get(app.Id).Mailing_Country__c
                   || app.Mailing_State__c != trigger.oldMap.get(app.Id).Mailing_State__c
                   || app.permanent_Address_Line_1__c != trigger.oldMap.get(app.Id).permanent_Address_Line_1__c
                   || app.permanent_Address_Line_2__c != trigger.oldMap.get(app.Id).permanent_Address_Line_2__c
                   || app.permanent_Address_Line_3__c != trigger.oldMap.get(app.Id).permanent_Address_Line_3__c
                   || app.permanent_Address_Line_3__c != trigger.oldMap.get(app.Id).permanent_Address_Line_3__c
                   || app.Pincode__c != trigger.oldMap.get(app.Id).Pincode__c
                   || app.City__c != trigger.oldMap.get(app.Id).City__c
                   || app.Country__c != trigger.oldMap.get(app.Id).Country__c
                   || app.State__c != trigger.oldMap.get(app.Id).State__c
                   || app.Office_Address_Line_1__c != trigger.oldMap.get(app.Id).Office_Address_Line_1__c
                   || app.Office_Address_Line_2__c != trigger.oldMap.get(app.Id).Office_Address_Line_2__c
                   || app.Office_Address_Line_3__c != trigger.oldMap.get(app.Id).Office_Address_Line_3__c
                   || app.Organisation_Pincode__c != trigger.oldMap.get(app.Id).Organisation_Pincode__c
                   || app.Organisation_Country__c != trigger.oldMap.get(app.Id).Organisation_Country__c
                   || app.Email_Address__c != trigger.oldMap.get(app.Id).Email_Address__c
                   || app.Applicant_Number__c != trigger.oldMap.get(app.Id).Applicant_Number__c
                   || app.Mobile_Number__c != trigger.oldMap.get(app.Id).Mobile_Number__c
                  )
                {
                    system.debug('*inside added*');
                    applicantIds.add(app.Id);
                }
                //Added by Vinay 07-01-2026 Start
                LockatedApp_UserDetailUpdate.ApplicantUpdateWrap applicantUpdateWrapper = new LockatedApp_UserDetailUpdate.ApplicantUpdateWrap();
                Boolean appMobileOrEmailUpdated = false;
                if(app.Mobile_Number__c != null && app.Mobile_Number__c != trigger.oldMap.get(app.Id).Mobile_Number__c){
                    applicantUpdateWrapper.primaryMobileChanged = true;
                    applicantUpdateWrapper.oldPrimaryMobile = Trigger.oldMap.get(app.Id).Mobile_Number__c;
                    applicantUpdateWrapper.newPrimaryMobile = app.Mobile_Number__c; 
                    appMobileOrEmailUpdated = true;
                }
                if(app.Email_Address__c != null && app.Email_Address__c != trigger.oldMap.get(app.Id).Email_Address__c){
                    applicantUpdateWrapper.primaryEmailChanged = true;
                    applicantUpdateWrapper.oldPrimaryEmail = Trigger.oldMap.get(app.Id).Email_Address__c;
                    applicantUpdateWrapper.newPrimaryEmail = app.Email_Address__c; 
                    appMobileOrEmailUpdated = true;
                }
                if(app.Secondary_Mobile_Number__c != null && (app.Secondary_Mobile_Number__c != Trigger.oldMap.get(app.Id).Secondary_Mobile_Number__c)){ // Added by Vinay 30-12-2025
                    applicantUpdateWrapper.secondaryMobileChanged = true;
                    applicantUpdateWrapper.oldSecondaryMobile = Trigger.oldMap.get(app.Id).Secondary_Mobile_Number__c;
                    applicantUpdateWrapper.newSecondaryMobile = app.Secondary_Mobile_Number__c;
                    appMobileOrEmailUpdated = true;
                }
                if(appMobileOrEmailUpdated == true){
                    appUpdateWrapperList.add(applicantUpdateWrapper);
                    applicantUpdateWrapper.applicantId = app.Id;
                }
                //Added by Vinay 07-01-2026 End
                
                if(app.Permanent_Address__c != null && app.Permanent_Address__c != Trigger.oldMap.get(app.Id).Permanent_Address__c ||
                  app.Permanent_Address_Line_1__c != null && app.Permanent_Address_Line_1__c != Trigger.oldMap.get(app.Id).Permanent_Address_Line_1__c ||
                  app.Permanent_Address_Line_2__c != null && app.Permanent_Address_Line_2__c != Trigger.oldMap.get(app.Id).Permanent_Address_Line_2__c ||
                  app.Permanent_Address_Line_3__c != null && app.Permanent_Address_Line_3__c != Trigger.oldMap.get(app.Id).Permanent_Address_Line_3__c){  //Added by Vinay 14-01-2026
                    addressChangedApplicantIds.add(app.Id);
                }
                if(app.Mobile_Number__c != null && app.Mobile_Number__c != Trigger.oldMap.get(app.Id).Mobile_Number__c){ //Added by Vinay 14-01-2026
                    phoneChangedApplicantIds.add(app.Id);
                }
            }
            if(appUpdateWrapperList.size() > 0){ //Added by Vinay 07-01-2026
                system.enqueuejob(new LockatedApp_UserDetailUpdate(appUpdateWrapperList));
            }
            if(addressChangedApplicantIds.size() > 0){ //Added by Vinay 14-01-2026
               LockatedApp_Notifications.correspondenceAddressChangeNotification(addressChangedApplicantIds); // Added by Vinay 14-01-2026 
            }
            if(phoneChangedApplicantIds.size() > 0){ //Added by Vinay 14-01-2026
                LockatedApp_Notifications.phoneNumberChangeNotification(phoneChangedApplicantIds); // Added by Vinay 14-01-2026
            }
            Map<Id,Id> BookingOppMap = new Map<Id,Id>();
            List<String> status = new List<String>{'Booking Confirmed','Booking Registered','Unit Booked','UnProcessed'};
                List<Applicant_Details__c> appDetails = [Select Booking__c ,Booking__r.RW_Registration_Status__c,Booking__r.Status__c, Booking__r.Customer__c,Booking__r.Customer__r.SAP_Customer_Number__c from Applicant_Details__c where Id IN:applicantIds ];
            for(Applicant_Details__c appd : appDetails)
            {
                system.debug('*status*'+appd.Booking__r.Status__c);
                if(appd.Booking__r.Customer__r.SAP_Customer_Number__c != null && status.contains(appd.Booking__r.Status__c) && appd.Booking__r.RW_Registration_Status__c != 'Registration Completed')
                    opportunityIds.add(appd.Booking__r.Customer__c);
            }
            if(opportunityIds.size() >0)
                CustomerUpdateCallout.afterUpdateApplicant(opportunityIds);
        }
        
        
        if(Trigger.isInsert)
        {
            List<Id> appIds = new List<Id>(); //Added by Vinay 13-01-2026
            for(Applicant_Details__c app : trigger.new)
            {
                system.debug('*inside for 1*');
                system.debug(app.id);
                if(app.Address_Proof_Document__c != null || app.Salutation__c != null || app.First_Name__c != null || app.Middle_Name__c != null || app.Last_Name__c != null || app.gender__c != null || app.Marital_Status__c != null
                   || app.Nationality_Picklist__c != null || app.Occupation__c != null || app.Designation__c != null || app.Subtype_Of_Applicant__c != null || app.DOB__c != null || app.Organization_Name__c != null
                   || app.PancardNo__c != null || app.Address_Proof_Number__c != null || app.PassportNoDetails__c != null
                   || app.Mailing_Address_Line_1__c != null|| app.Mailing_Address_Line_2__c != null || app.Mailing_Address_Line_3__c != null || app.Mailing_Pincode__c != null
                   || app.Mailing_City__c != null || app.Mailing_Country__c != null
                   || app.Mailing_State__c != null || app.permanent_Address_Line_1__c != null || app.permanent_Address_Line_2__c != null
                   || app.permanent_Address_Line_3__c != null || app.permanent_Address_Line_3__c != null
                   || app.Pincode__c != null || app.City__c != null
                   || app.Country__c != null || app.State__c != null || app.Office_Address_Line_1__c != null || app.Office_Address_Line_2__c != null
                   || app.Office_Address_Line_3__c != null || app.Organisation_Pincode__c != null
                   || app.Organisation_Country__c != null || app.Email_Address__c != null
                  )
                {
                    system.debug('*inside added*');
                    applicantIds.add(app.Id);
                }
                
                if(app.Mobile_Number__c != null && app.Email_Address__c != null){ //Added by Vinay 13-01-2026
                    appIds.add(app.Id);
                }
            }
            Map<Id,Id> BookingOppMap = new Map<Id,Id>();
            List<String> status = new List<String>{'Booking Confirmed','Booking Registered','Unit Booked','UnProcessed'};
                List<Applicant_Details__c> appDetails = [Select Booking__c ,Booking__r.RW_Registration_Status__c,Booking__r.Status__c, Booking__r.Customer__c,Booking__r.Customer__r.SAP_Customer_Number__c from Applicant_Details__c where Id IN:applicantIds ];
            for(Applicant_Details__c appd : appDetails)
            {
                system.debug('*status*'+appd.Booking__r.Status__c);
                if(appd.Booking__r.Customer__r.SAP_Customer_Number__c != null && status.contains(appd.Booking__r.Status__c) && appd.Booking__r.RW_Registration_Status__c != 'Registration Completed')
                    opportunityIds.add(appd.Booking__r.Customer__c);
            }
            if(opportunityIds.size() >0)
                CustomerUpdateCallout.afterUpdateApplicant(opportunityIds);
            
            if(appIds.size() > 0){ //Added by Vinay 13-01-2026
                CreateUserWhenUnitBooked.createuserWhenApplicantCreated(appIds);
            }
            
        }
    }
}