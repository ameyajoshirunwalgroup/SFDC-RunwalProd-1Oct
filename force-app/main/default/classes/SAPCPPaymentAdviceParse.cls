public class SAPCPPaymentAdviceParse {
	public String PDF;	//8813_Customer_Ledger.PDF
	public static SAPCPPaymentAdviceParse parse(String json){
		return (SAPCPPaymentAdviceParse) System.JSON.deserialize(json, SAPCPPaymentAdviceParse.class);
	}

}