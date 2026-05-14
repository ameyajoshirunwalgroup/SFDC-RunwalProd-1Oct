public class DocupilotPayloadCarParkingItem {
  // source field: "Parking_Type"
  @AuraEnabled public String parkingType { get; set; }

  // source field: "Podium_No"
  @AuraEnabled public String podiumNo { get; set; }

  // source field: "Length_CarPark"
  @AuraEnabled public String lengthCarpark { get; set; }

  // source field: "Width_CarPark"
  @AuraEnabled public String widthCarpark { get; set; }

  // source field: "Height_CarPark"
  @AuraEnabled public String heightCarpark { get; set; }

  public Map<String, Object> toMap() {
    Map<String, Object> result = new Map<String, Object>();
    result.put('Parking_Type', parkingType);
    result.put('Podium_No', podiumNo);
    result.put('Length_CarPark', lengthCarpark);
    result.put('Width_CarPark', widthCarpark);
    result.put('Height_CarPark', heightCarpark);
    return result;
  }

}