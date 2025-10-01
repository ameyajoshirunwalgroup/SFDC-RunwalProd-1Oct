public class wrapCase
{
	@AuraEnabled
	public String strCaseSubject { Get; Set; }
	@AuraEnabled
	public String strCaseDescription { Get; Set; }
	@AuraEnabled
	public String strCaseStatus { Get; Set; }
	@AuraEnabled
	public String strCaseRemark { Get; Set; }
	@AuraEnabled
	public String strCaseType { Get; Set; }

	public wrapCase()
	{
		strCaseSubject = '';
		strCaseDescription = '';
		strCaseStatus = '';
		strCaseRemark = '';
		strCaseType = '';
	}
}