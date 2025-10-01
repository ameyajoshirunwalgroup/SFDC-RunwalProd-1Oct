public class Rest_KserveActivityDetails_parse {

	public String AttemptedBy {get;set;} 
	public String ProposedDateofVisit {get;set;} 
	public String ProjectInterested {get;set;} 
	public String NextActionDate {get;set;} 
	public String CallStatus {get;set;} 
	public String CallComments {get;set;} 
	public String CommunicationType {get;set;} 
	public String CallDate {get;set;} 
	public String CallTime {get;set;} 
	public String LeadId {get;set;} 

	public Rest_KserveActivityDetails_parse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'AttemptedBy') {
						AttemptedBy = parser.getText();
					} else if (text == 'ProposedDateofVisit') {
						ProposedDateofVisit = parser.getText();
					} else if (text == 'ProjectInterested') {
						ProjectInterested = parser.getText();
					} else if (text == 'NextActionDate') {
						NextActionDate = parser.getText();
					} else if (text == 'CallStatus') {
						CallStatus = parser.getText();
					} else if (text == 'CallComments') {
						CallComments = parser.getText();
					} else if (text == 'CommunicationType') {
						CommunicationType = parser.getText();
					} else if (text == 'CallDate') {
						CallDate = parser.getText();
					} else if (text == 'CallTime') {
						CallTime = parser.getText();
					} else if (text == 'LeadId') {
						LeadId = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'Rest_KserveActivityDetails_parse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static Rest_KserveActivityDetails_parse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new Rest_KserveActivityDetails_parse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	


}