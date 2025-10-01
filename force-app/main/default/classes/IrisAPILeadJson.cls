//http://runwal.iris1.selldoapp.com/api/v1/leads
public class IrisAPILeadJson{
	public cls_lead lead;
    public class cls_lead {
   
		public String first_name;
        public String last_name;//Test API
		public String email;	//testapi@sxample.com
		public String phone;	//+919172243224
		public String stage;	//ABC
		public String sitevisit_date;	//24/11/2020
		public String last_revisit_date;	//24/11/2020
		public Integer revisit_count;	//2
		public String manager_id;	//Salesforce broker id Broker
		public String user_id;	//Account Id
		public String project_id;	//runwal
		public String reference_id;	//Opportunity Id
        public String project_unit_id;
	}
	public static IrisAPILeadJson parse(String json){
		return (IrisAPILeadJson) System.JSON.deserialize(json, IrisAPILeadJson.class);
	}
}
	/*static testMethod void testParse() {
		String json=		'{'+
		'    "lead": {'+
		'       "first_name": "Test API",'+
		'       "email": "testapi@sxample.com",'+
		'       "phone": "+919172243224",'+
		'        "stage": "ABC",'+
		'        "sitevisit_date": "24/11/2020",'+
		'        "last_revisit_date": "24/11/2020",'+
		'        "revisit_count": 2,'+
		'        "manager_id": "Salesforce broker id Broker",'+
		'       "user_id": "Account Id",'+
		'       "project_id": "runwal",       '+
		'       "reference_id": "Opportunity Id"'+
		'    }'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/