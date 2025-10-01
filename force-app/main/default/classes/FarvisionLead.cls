public class FarvisionLead
{
    public String SecurityKey {get; set;}
    public String UserToken {get; set;}
    public String LoginID {get; set;}
    public datetime AppDt {get; set;}
    public String Project {get; set;}
    public String Applicant {get; set;}
    public String AppSalutation {get; set;}
    public String ApplicantFirstName {get; set;}
    public String ApplicantMiddleName {get; set;}
    public String ApplicantLastName {get; set;}
    public String ApplicantGender {get; set;}
    public String RelationType {get; set;}
    public String RelativeName {get; set;}
    public datetime DOB {get; set;}
    public String OpportunityCode {get; set;}
    public String Nationality {get; set;}
    public String ResidentStatus {get; set;}
    public String PanNo {get; set;}
    public String PassportNo {get; set;}
    public String CorrSpondAddress1 {get; set;}
    public String CorrSpondAddress2 {get; set;}
    public String CorrSpondAddress3 {get; set;}
    public String CorrSpondCountry {get; set;}
    public String CorrSpondState {get; set;}
    public String CorrSpondCity {get; set;}
    public String CorrSpondPinCode {get; set;}
    public String CorrSpondAddFull {get; set;}
    public String CorrSpondPh1 {get; set;}
    public String CorrSpondPh2 {get; set;}
    public String CorrSpondMob {get; set;}
    public String CorrSpondFax {get; set;}
    public String CorrSpondEmail {get; set;}
    public String PermanentAddress1 {get; set;}
    public String PermanentAddress2 {get; set;}
    public String PermanentAddress3 {get; set;}
    public String PermanentCountry {get; set;}
    public String PermanentState {get; set;}
    public String PermanentCity {get; set;}
    public String PermanentPinCode {get; set;}
    public String PermanentAddressFull {get; set;}
    public String PermanentPhone1 {get; set;}
    public String PermanentPhone2 {get; set;}
    public String PermanentMobNo {get; set;}
    public String PermanentFaxNo {get; set;}
    public String Occupation {get; set;}
    public Decimal AnnualIncome {get; set;}
    public String Designation {get; set;}
    public String Company {get; set;}
    public String OfficeAddress1 {get; set;}
    public String OfficeAddress2 {get; set;}
    public String OfficeAddress3 {get; set;}
    public String OfficeCountry {get; set;}
    public String OfficeState {get; set;}
    public String OfficeCity {get; set;}
    public String OfficePinCode {get; set;}
    public String OfficePh1 {get; set;}
    public String OfficePh2 {get; set;}
    public String OfficeFax {get; set;}
    public String OfficeEmail {get; set;}
    public String CoAppName {get; set;} 
    public String SalesPersonName {get; set;}
    
    public static FarvisionLead parse(String json) {
        return (FarvisionLead) System.JSON.deserialize(json, FarvisionLead.class);
    }
}