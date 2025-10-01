trigger NameConfirmationTrigger on Name_Confirmation_Form__c (before insert,before update,after update) 
{
	ByPassTriggers__mdt[] byPasstrigMappings = [SELECT Id,Label, ByPassTrigger__c,Object_Name__c FROM ByPassTriggers__mdt];
   Boolean byPassTriggerExceution = false;
   for(ByPassTriggers__mdt bypass : byPasstrigMappings)
   {
       if(bypass.Object_Name__c == 'Name_Confirmation_Form__c' && bypass.ByPassTrigger__c)
       {
          byPassTriggerExceution = true;
       }
   }
   
      Map<Id,List<Name_Confirmation_Form__c>> ncfBookingMap = new Map<Id,List<Name_Confirmation_Form__c>>();
      Map<Id,Booking__c> BookingMap = new Map<Id,Booking__c>();
     Set<Id> BookingRecordIds = new Set<Id>();
     for(Name_Confirmation_Form__c ncfRec : Trigger.New)
        {
            BookingRecordIds.add(ncfRec.Booking__c);
            
            
        }
    
    List<Booking__c> bookingRecs = [Select id,name,Customer__c,(Select id,RW_Active_NCF__c from Name_Confirmation_Forms__r) from Booking__c where id IN :BookingRecordIds  ];
    for(Booking__c bookrec : bookingRecs)
    {    
        ncfBookingMap.put(bookrec.Id,bookrec.Name_Confirmation_Forms__r);
        BookingMap.put(bookrec.Id,bookrec);
    }
    
    for(Name_Confirmation_Form__c ncfRecords : Trigger.New)
        {
            if(ncfRecords.RW_Active_NCF__c)
            {
                if(ncfBookingMap.ContainsKey(ncfRecords.Booking__c))
                {
                    for(Name_Confirmation_Form__c existingncf : ncfBookingMap.get(ncfRecords.Booking__c))
                    {
                        if(existingncf.RW_Active_NCF__c && ncfRecords.Id != existingncf.Id)
                        {
                            ncfRecords.addError('There can only be one active NCF at any point of time');
                        }
                    }
                }
            }
        }

    if(Trigger.isBefore)
    {
    for(Name_Confirmation_Form__c ncfRecord : Trigger.New)
        {
            if(ncfRecord.Opportunity__c == null)
            {
                if(BookingMap.ContainsKey(ncfRecord.Booking__c))
                {
                   ncfRecord.Opportunity__c =  BookingMap.get(ncfRecord.Booking__c).Customer__c;
                }
            }
            
        }
    }
    Set<Id> ncfRecordIds = new Set<Id>();
    Map<String,Name_Confirmation_Form__c> ncfMap = new Map<String,Name_Confirmation_Form__c>();
    Set<Id> BookingIds = new Set<Id>();
	system.debug('MK'+byPassTriggerExceution);
    if(!byPassTriggerExceution)
    {
   if(Trigger.isUpdate && Trigger.isafter)
    {
        for(Name_Confirmation_Form__c ncf : Trigger.New)
        {
            if(ncf.RW_Verified__c  && ncf.RW_Verified__c != Trigger.OldMap.get(ncf.Id).RW_Verified__c)
            {
            ncfRecordIds.add(ncf.Id);
            ncfMap.put(ncf.Booking__c,ncf);
            BookingIds.add(ncf.Booking__c);
            }
        }
        Map<String,Applicant_Details__c> appDetailMap =new Map<String,Applicant_Details__c>();
        List<Applicant_Details__c> applicantDetailsList = new List<Applicant_Details__c>();
        List<Applicant_Details__c> appDetails = [Select Id,Applicant_Number__c,Booking__c,Type_Of_Applicant__c,Subtype_Of_Applicant__c,PancardNo__c,Address_Proof_Document__c,Address_Proof_Number__c,Type_Of_Origin__c,Origin_Details__c,PassportNoDetails__c,Pan_Card_Number_of_Authority_Signatory__c,First_Name__c,Last_Name__c,Middle_Name__c,Mobile_Number__c,Email_Address__c,State__c,Country__c,City__c,Pincode__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,Permanent_Address_Line_3__c,DOB__c from Applicant_Details__c Where Applicant_Number__c='Primary Applicant' and Booking__c IN :BookingIds and Applicant_Status__c='Active' ];
        for(Applicant_Details__c appdet : appDetails)
        {
            appDetailMap.put(appdet.Booking__c, appdet);
        }
        
        for(String ncfbookingId : ncfMap.keySet())
        {
            if(appDetailMap.containsKey(ncfbookingId))
            {
                appDetailMap.get(ncfbookingId).Type_Of_Applicant__c= ncfMap.get(ncfbookingId).Type_Of_Applicant__c;
                appDetailMap.get(ncfbookingId).Subtype_Of_Applicant__c = ncfMap.get(ncfbookingId).Subtype_Of_Applicant__c;
                appDetailMap.get(ncfbookingId).PancardNo__c = ncfMap.get(ncfbookingId).PancardNo__c;
                appDetailMap.get(ncfbookingId).Address_Proof_Document__c = ncfMap.get(ncfbookingId).Address_Proof_Document__c;
                appDetailMap.get(ncfbookingId).Address_Proof_Number__c = ncfMap.get(ncfbookingId).Address_Proof_Number__c;
                appDetailMap.get(ncfbookingId).Type_Of_Origin__c=ncfMap.get(ncfbookingId).Type_Of_Origin__c;
                appDetailMap.get(ncfbookingId).Origin_Details__c=ncfMap.get(ncfbookingId).Origin_Details__c;
                appDetailMap.get(ncfbookingId).PassportNoDetails__c =ncfMap.get(ncfbookingId).PassportNoDetails__c;
                appDetailMap.get(ncfbookingId).Pan_Card_Number_of_Authority_Signatory__c = ncfMap.get(ncfbookingId).Pan_Card_Number_of_Authority_Signatory__c;
                appDetailMap.get(ncfbookingId).First_Name__c= ncfMap.get(ncfbookingId).RW_Primary_First_Name__c;
                appDetailMap.get(ncfbookingId).Last_Name__c= ncfMap.get(ncfbookingId).RW_Primary_Last_Name__c;
                appDetailMap.get(ncfbookingId).Middle_Name__c= ncfMap.get(ncfbookingId).RW_Primary_Middle_Name__c;
                appDetailMap.get(ncfbookingId).Mobile_Number__c = ncfMap.get(ncfbookingId).RW_Primary_Mobile_Number__c;
                appDetailMap.get(ncfbookingId).Email_Address__c = ncfMap.get(ncfbookingId).RW_Primary_Email__c;
                appDetailMap.get(ncfbookingId).Country__c =ncfMap.get(ncfbookingId).RW_Primary_Country__c;
                appDetailMap.get(ncfbookingId).State__c = ncfMap.get(ncfbookingId).RW_Primary_State__c;
                appDetailMap.get(ncfbookingId).City__c= ncfMap.get(ncfbookingId).RW_Primary_City__c;
                appDetailMap.get(ncfbookingId).Pincode__c =ncfMap.get(ncfbookingId).RW_Primary_Pincode__c;
                appDetailMap.get(ncfbookingId).Permanent_Address_Line_1__c = ncfMap.get(ncfbookingId).RW_Primary_Permanent_Address_Line_1__c;
                appDetailMap.get(ncfbookingId).Permanent_Address_Line_2__c = ncfMap.get(ncfbookingId).RW_Primary_Permanent_Address_Line_2__c;
                appDetailMap.get(ncfbookingId).Permanent_Address_Line_3__c = ncfMap.get(ncfbookingId).RW_Primary_Permanent_Address_Line_3__c;
                appDetailMap.get(ncfbookingId).DOB__c= ncfMap.get(ncfbookingId).RW_Primary_DOB__c;
				if (ncfMap.get(ncfbookingId).RW_Primary_First_Name__c != '' && ncfMap.get(ncfbookingId).RW_Primary_First_Name__c != null && ncfMap.get(ncfbookingId).RW_Primary_Last_Name__c != '' && ncfMap.get(ncfbookingId).RW_Primary_Last_Name__c != null) {
                    if (ncfMap.get(ncfbookingId).RW_Primary_Middle_Name__c != null) {
                        appDetailMap.get(ncfbookingId).Name = ncfMap.get(ncfbookingId).RW_Primary_First_Name__c + ' ' + ncfMap.get(ncfbookingId).RW_Primary_Middle_Name__c + ' ' + ncfMap.get(ncfbookingId).RW_Primary_Last_Name__c;
                    } else {
                        appDetailMap.get(ncfbookingId).Name = ncfMap.get(ncfbookingId).RW_Primary_First_Name__c + ' ' + ncfMap.get(ncfbookingId).RW_Primary_Last_Name__c;
                    }
            }
                
                applicantDetailsList.add(appDetailMap.get(ncfbookingId));
            }
        }
        
        if(applicantDetailsList.size() >0)
        {
            Update applicantDetailsList;
        }
    }
    }
}