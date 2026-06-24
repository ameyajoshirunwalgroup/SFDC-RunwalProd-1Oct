public class DocupilotPayloadApplicantsDetailsItem {
  // source field: "Applicant_Name"
  @AuraEnabled public String applicantName { get; set; }

  // source field: "Applicant_PAN"
  @AuraEnabled public String applicantPan { get; set; }

  public Map<String, Object> toMap() {
    Map<String, Object> result = new Map<String, Object>();
    result.put('Applicant_Name', applicantName);
    result.put('Applicant_PAN', applicantPan);
    return result;
  }

}