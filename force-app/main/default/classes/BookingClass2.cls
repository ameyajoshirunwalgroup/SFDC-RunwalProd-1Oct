public class BookingClass2 {
    
    public static void updateAccount(Applicant_Details__c applicant, Account acc){
        if(String.isNotBlank(applicant.Salutation__c) && acc.Salutation != applicant.Salutation__c)
            acc.Salutation = applicant.Salutation__c;
        if(String.isNotBlank(applicant.First_Name__c) && acc.FirstName != applicant.First_Name__c)
            acc.FirstName = applicant.First_Name__c;
        if(String.isNotBlank(applicant.Middle_Name__c) && String.isNotBlank(applicant.Last_Name__c) && acc.LastName != (applicant.Middle_Name__c + ' ' + applicant.Last_Name__c))
            acc.LastName = applicant.Middle_Name__c + ' ' + applicant.Last_Name__c;
        else if(String.isBlank(applicant.Middle_Name__c) && String.isNotBlank(applicant.Last_Name__c) && acc.LastName != applicant.Last_Name__c)
            acc.LastName = applicant.Last_Name__c;
        if(applicant.Pincode__c != null && acc.RW_Zip_Code__c != String.valueOf(applicant.Pincode__c))
            acc.RW_Zip_Code__c = String.valueOf(applicant.Pincode__c);
        if(String.isNotBlank(applicant.Permanent_Address__c) && acc.Current_Residential_Address__c != applicant.Permanent_Address__c)
            acc.Current_Residential_Address__c = applicant.Permanent_Address__c;
        if(String.isNotBlank(applicant.Organization_Name__c) && acc.RW_Company_Name__c != applicant.Organization_Name__c)
            acc.RW_Company_Name__c = applicant.Organization_Name__c;
        if(String.isNotBlank(applicant.Designation__c) && acc.RW_Designation__c != applicant.Designation__c)
            acc.RW_Designation__c = applicant.Designation__c;
        update acc;
    }
    
}