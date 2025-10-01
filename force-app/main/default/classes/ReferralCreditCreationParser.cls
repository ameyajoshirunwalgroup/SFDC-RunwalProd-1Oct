public class ReferralCreditCreationParser {
    public String LIFNR;
    public String DOCUMENT_NO;
    public String DOCUMENT_DT;
    public String status;

	public static ReferralCreditCreationParser parse(String json){
		return (ReferralCreditCreationParser) System.JSON.deserialize(json,ReferralCreditCreationParser.class);
	}
    
}