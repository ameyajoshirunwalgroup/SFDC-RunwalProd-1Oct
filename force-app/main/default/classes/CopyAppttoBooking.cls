public class CopyAppttoBooking
{
    public static void updateBooking(Applicant_Details__c[] lstApp)
    {
        List<Applicant_Details__c> applicantList = new List<Applicant_Details__c>();
        Map<Id, Applicant_Details__c> ApplicantMap = new Map<Id, Applicant_Details__c>();
        List<Applicant_Details__c> AppList;
        
        system.debug('inside Method Of Netra..................');
        for(Applicant_Details__c App : lstApp)
        {
             if (App.Booking__c != null)
              {
                  ApplicantMap.put(App.Booking__c,App);
                  system.debug('ApplicantMap: ' + ApplicantMap);
              }
        }
        AppList = [SELECT Id,Booking__c,Applicant_Number__c,Email_Address__c FROM Applicant_Details__c WHERE Booking__c IN: ApplicantMap.keySet()];
        system.debug('AppList Netrass: ' + AppList);
        If(AppList.size() > 0 )
        {
            if(AppList[0].Applicant_Number__c == 'Primary Applicant')
            {
                Booking__c objBooking = new Booking__c();
                objBooking.Id = AppList[0].Booking__c;
                objBooking.Primary_Applicant_Email__c = AppList[0].Email_Address__c;
                system.debug('PA Email : ' + objBooking.Primary_Applicant_Email__c);        
                update objBooking;
            }
        }
    }
}