public class DocupilotPayload {
  // source field: "Applicants Details"
  @AuraEnabled public List<DocupilotPayloadApplicantsDetailsItem> applicantsDetails { get; set; }

  // source field: "Customer_Address"
  @AuraEnabled public String customerAddress { get; set; }

  // source field: "Tower"
  @AuraEnabled public String tower { get; set; }

  // source field: "Is_Bare_Shell"
  @AuraEnabled public String isBareShell { get; set; }

  // source field: "Unit_No"
  @AuraEnabled public String unitNo { get; set; }

  // source field: "Floor"
  @AuraEnabled public String floor { get; set; }

  // source field: "Carpet_Area_in_SqFt"
  @AuraEnabled public String carpetAreaInSqft { get; set; }

  // source field: "Deck_Area_in_SqFt"
  @AuraEnabled public String deckAreaInSqft { get; set; }

  // source field: "Utility_Area_in_SqFt"
  @AuraEnabled public String utilityAreaInSqft { get; set; }

  // source field: "Service_Are_in_SqFt"
  @AuraEnabled public String serviceAreInSqft { get; set; }

  // source field: "Service_Area"
  @AuraEnabled public String serviceArea { get; set; }

  // source field: "Car_Parking"
  @AuraEnabled public List<DocupilotPayloadCarParkingItem> carParking { get; set; }

  // source field: "Agreement_Value"
  @AuraEnabled public String agreementValue { get; set; }

  // source field: "Type"
  @AuraEnabled public String type { get; set; }

  // source field: "Email_Address"
  @AuraEnabled public String emailAddress { get; set; }

  // source field: "Nominee_Name"
  @AuraEnabled public String nomineeName { get; set; }

  // source field: "Payment_Details"
  @AuraEnabled public List<DocupilotPayloadPaymentDetailsItem> paymentDetails { get; set; }

  // source field: "Electric_Receiving_Substation"
  @AuraEnabled public String electricReceivingSubstation { get; set; }

  // source field: "Legal_Charges"
  @AuraEnabled public String legalCharges { get; set; }

  // source field: "Electric_Water_Connection_MGL_Connection"
  @AuraEnabled public String electricWaterConnectionMglConnection { get; set; }

  // source field: "Society_Formation"
  @AuraEnabled public String societyFormation { get; set; }

  // source field: "BCAM_Charges_Rate"
  @AuraEnabled public String bcamChargesRate { get; set; }

  // source field: "Total_RERA_Area_in_SqFt"
  @AuraEnabled public String totalReraAreaInSqft { get; set; }

  // source field: "CCAM_Charges_Rate"
  @AuraEnabled public String ccamChargesRate { get; set; }

  // source field: "Corpus_Fund"
  @AuraEnabled public String corpusFund { get; set; }

  // source field: "Amount_Received"
  @AuraEnabled public String amountReceived { get; set; }

  // source field: "Plinth_Area"
  @AuraEnabled public String plinthArea { get; set; }

  // source field: "Colour_Washed"
  @AuraEnabled public String colourWashed { get; set; }

  // source field: "RERA_Certificate_Registration_No"
  @AuraEnabled public String reraCertificateRegistrationNo { get; set; }

  // source field: "RERA_Certificate_Registration_Date"
  @AuraEnabled public String reraCertificateRegistrationDate { get; set; }

  // source field: "Total_FSI"
  @AuraEnabled public String totalFsi { get; set; }

  // source field: "Whole_Project_FSI"
  @AuraEnabled public String wholeProjectFsi { get; set; }

  // source field: "Tower_Name"
  @AuraEnabled public String towerName { get; set; }

  // source field: "No_Of_Parkings"
  @AuraEnabled public String noOfParkings { get; set; }

  // source field: "Balance_Amount"
  @AuraEnabled public String balanceAmount { get; set; }

  // source field: "Received_Percent"
  @AuraEnabled public String receivedPercent { get; set; }

  // source field: "Possession_Date"
  @AuraEnabled public String possessionDate { get; set; }

  // source field: "Other_Charges"
  @AuraEnabled public String otherCharges { get; set; }

  // source field: "Security_Deposit"
  @AuraEnabled public String securityDeposit { get; set; }

  // source field: "Infrastructure_Charges"
  @AuraEnabled public String infrastructureCharges { get; set; }

  public Map<String, Object> toMap() {
    Map<String, Object> result = new Map<String, Object>();
    result.put('Applicants Details', mapApplicantsdetails());
    result.put('Customer_Address', customerAddress);
    result.put('Tower', tower);
    result.put('Is_Bare_Shell', isBareShell);
    result.put('Unit_No', unitNo);
    result.put('Floor', floor);
    result.put('Carpet_Area_in_SqFt', carpetAreaInSqft);
    result.put('Deck_Area_in_SqFt', deckAreaInSqft);
    result.put('Utility_Area_in_SqFt', utilityAreaInSqft);
    result.put('Service_Are_in_SqFt', serviceAreInSqft);
    result.put('Service_Area', serviceArea);
    result.put('Car_Parking', mapCarparking());
    result.put('Agreement_Value', agreementValue);
    result.put('Type', type);
    result.put('Email_Address', emailAddress);
    result.put('Nominee_Name', nomineeName);
    result.put('Payment_Details', mapPaymentdetails());
    result.put('Electric_Receiving_Substation', electricReceivingSubstation);
    result.put('Legal_Charges', legalCharges);
    result.put('Electric_Water_Connection_MGL_Connection', electricWaterConnectionMglConnection);
    result.put('Society_Formation', societyFormation);
    result.put('BCAM_Charges_Rate', bcamChargesRate);
    result.put('Total_RERA_Area_in_SqFt', totalReraAreaInSqft);
    result.put('CCAM_Charges_Rate', ccamChargesRate);
    result.put('Corpus_Fund', corpusFund);
    result.put('Amount_Received', amountReceived);
    result.put('Plinth_Area', plinthArea);
    result.put('Colour_Washed', colourWashed);
    result.put('RERA_Certificate_Registration_No', reraCertificateRegistrationNo);
    result.put('RERA_Certificate_Registration_Date', reraCertificateRegistrationDate);
    result.put('Total_FSI', totalFsi);
    result.put('Whole_Project_FSI', wholeProjectFsi);
    result.put('Tower_Name', towerName);
    result.put('No_Of_Parkings', noOfParkings);
    result.put('Balance_Amount', balanceAmount);
    result.put('Received_Percent', receivedPercent);
    result.put('Possession_Date', possessionDate);
    result.put('Other_Charges', otherCharges);
    result.put('Security_Deposit', securityDeposit);
    result.put('Infrastructure_Charges', infrastructureCharges);
    return result;
  }

  private List<Object> mapApplicantsdetails() {
    if (applicantsDetails == null) {
      return null;
    }

    List<Object> result = new List<Object>();
    for (DocupilotPayloadApplicantsDetailsItem item : applicantsDetails) {
      result.add(item == null ? null : item.toMap());
    }
    return result;
  }

  private List<Object> mapCarparking() {
    if (carParking == null) {
      return null;
    }

    List<Object> result = new List<Object>();
    for (DocupilotPayloadCarParkingItem item : carParking) {
      result.add(item == null ? null : item.toMap());
    }
    return result;
  }

  private List<Object> mapPaymentdetails() {
    if (paymentDetails == null) {
      return null;
    }

    List<Object> result = new List<Object>();
    for (DocupilotPayloadPaymentDetailsItem item : paymentDetails) {
      result.add(item == null ? null : item.toMap());
    }
    return result;
  }

}