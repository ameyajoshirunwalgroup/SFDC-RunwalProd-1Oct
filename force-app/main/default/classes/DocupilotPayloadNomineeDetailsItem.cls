public class DocupilotPayloadNomineeDetailsItem {
  // source field: "Nominee_Name"
  @AuraEnabled public String nomineeName { get; set; }

  public Map<String, Object> toMap() {
    Map<String, Object> result = new Map<String, Object>();
    result.put('Nominee_Name', nomineeName);
    return result;
  }

}