// Parser class for SAP CP Brokerage API Response
public class SAPCPBrokerageCreationParser {
    
    public Integer SR_NO;
    public String BUKRS;
    public String LIFNR;
    public String INV_DT;
    public String INV_NO;
    public Decimal TOT_INV_AMT;
    public String HDR_TEXT;
    public String IS_ERROR;
    public String ERR_MSG;
    public String DOC_NO;
    public Decimal TDS_AMT;
    
    // Legacy field names for backward compatibility
    public String SAP_DOC_NO { get { return DOC_NO; } }
    public String SAP_DOC_DT { get { return INV_DT; } }
    public String SAP_POST_DT { get { return INV_DT; } }
    public String SAP_CLR_DT { get { return INV_DT; } }
    public Decimal SAP_TDS { get { return TDS_AMT; } }
    public String ERROR_TEXT { get { return ERR_MSG; } }
    
    // Parse method to handle array response
    public static List<SAPCPBrokerageCreationParser> parseList(String json) {
        return (List<SAPCPBrokerageCreationParser>) System.JSON.deserialize(json, List<SAPCPBrokerageCreationParser>.class);
    }
    
    // Parse method to handle single object (for backward compatibility)
    public static SAPCPBrokerageCreationParser parse(String json) {
        // Check if response is an array or object
        String trimmedJson = json.trim();
        
        if(trimmedJson.startsWith('[')) {
            // It's an array, get the first element
            List<SAPCPBrokerageCreationParser> resultList = parseList(json);
            if(resultList != null && !resultList.isEmpty()) {
                return resultList[0];
            }
            return null;
        } else {
            // It's a single object
            return (SAPCPBrokerageCreationParser) System.JSON.deserialize(json, SAPCPBrokerageCreationParser.class);
        }
    }
}