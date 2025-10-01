public class SAPCPInvoiceCreationParser {
	public String SAP_DOC_NO;
    public String SAP_DOC_DT;
    public String SAP_POST_DT;
    public String SAP_CLR_DT;
    public String SAP_TDS;
    public String ERROR_TEXT;
	public static SAPCPInvoiceCreationParser parse(String json){
		return (SAPCPInvoiceCreationParser) System.JSON.deserialize(json, SAPCPInvoiceCreationParser.class);
	}

}