public class WrapPortalData
{
	public Integer ErrorCode;
	public String StatusMessage;
	public List<wrapPDFData> CustDemandPDF;
	public List<wrapPDFData> CustApplicantLedgerPDF;
	public List<wrapPDFData> CustMoneyReceiptPDF;
	public List<wrapPDFData> CustAllotPDF;
	public List<wrapPDFData> CustReminderPDF;

	public class wrapPDFData
	{
		public String APPNO;
		public String OPPORTUNITYCODE;
		public String SRNO;
		public String MRDATE;
		public String MRNO;
		public String DEMAND_PDF_STRING;
		public String APPLICANTLEDGER_PDF_STRING;
		public String MR_PDF_STRING;
		public String Allot_PDF_STRING;
		public String Reminder_PDF_STRING;
	}

	public static WrapPortalData parse(String json) {
        return (WrapPortalData) System.JSON.deserialize(json, WrapPortalData.class);
    }
}