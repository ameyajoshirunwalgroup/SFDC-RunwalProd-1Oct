public class DocupilotPayloadPaymentDetailsItem {
  // source field: "Payment_Description"
  @AuraEnabled public String paymentDescription { get; set; }

  // source field: "Payment_Milestone"
  @AuraEnabled public String paymentMilestone { get; set; }

  public Map<String, Object> toMap() {
    Map<String, Object> result = new Map<String, Object>();
    result.put('Payment_Description', paymentDescription);
    result.put('Payment_Milestone', paymentMilestone);
    return result;
  }

}