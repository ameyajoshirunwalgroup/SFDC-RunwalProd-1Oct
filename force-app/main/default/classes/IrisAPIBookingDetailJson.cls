//http://runwal.iris1.selldoapp.com/api/v1/booking_details
public class IrisAPIBookingDetailJson{
	public cls_booking_detail booking_detail;
	public class cls_booking_detail {
		public String reference_id;	//6
		public String project_unit_id;	//5fbceb1062d4a769f80d9821
		public String lead_id;	//RW-000023
        public Decimal agreement_price;
        public Decimal all_inclusive_price;
		public cls_receipts_attributes[] receipts_attributes;
		public cls_primary_user_kyc_attributes primary_user_kyc_attributes;
        public cls_tasks_attributes tasks_attributes;
        //Added by Mounika on 08Feb2021 New fields updated by Sell.do
        public String blocking_amount; // New field added, Mandatory
        public String booked_on; // New field added, Mandatory, Format: dd/mm/YYYY
        public String saleable; // New field added, Mandatory
        public String carpet; // New field added, Mandatory
        //Ends here
	}
	public class cls_receipts_attributes {
		public String reference_id;	//1114
		//public String receipt_id;	//11123
	//	public String order_id;	//asdf
		//public String payment_mode;	//online
		public String issued_date;	//11/11/2020
	//	public String issuing_bank;	//ABC
	//	public String issuing_bank_branch;	//Branch
		public String payment_identifier;	//ABC
	//	public String tracking_id;	//ABC
		public Decimal total_amount;	//30000
		public String status;	//success
		//public String payment_gateway;	//Razorpay
		public String processed_on;	//11/11/2020
	//	public String comments;	//ABC
		//public String payment_type;	//token
	}
	public class cls_primary_user_kyc_attributes {
		public String reference_id;	//14
		public String salutation;	//Ms.
		public String first_name;	//Aakruti
		public String last_name;	//Shitut
		public String email;	//asdfgg@gmail.com
		public String phone;	//+919213232343
		public String pan_number;	//DMABD9961V
		public String aadhaar;	//123412271134
		public String dob;	//12/08/1980
		public cls_configurations[] configurations;
		public cls_preferred_floors[] preferred_floors;
		public Integer budget;	//123456
		public String anniversary;	//11/11/1995
		public String education_qualification;	//ABC
		public String designation;	//ABC
		public String customer_company_name;	//ABC
		public Integer number_of_units;	//1
		public String comments;	//ABC
		public String lead_id;	//RW-L0001
		public boolean nri;
		public String oci;	//ABC
		public boolean poa;
		public String poa_details;	//ABC
		public String poa_details_phone_no;	//ABC
		public boolean is_company;
		public String gstn;	//ABC
		public String company_name;	//ABC
		public boolean existing_customer;
		public String existing_customer_name;	//ABC
		public String existing_customer_project;	//ABC
	}
    public class cls_tasks_attributes {
       public boolean registration_done;
    }
	public class cls_configurations {
		public String conf; //0;	//1
	}
	public class cls_preferred_floors {
		public String flr;//0;	//1
	}
	/*public static IrisAPIBookingDetailJson parse(String json){
		return (IrisAPIBookingDetailJson) System.JSON.deserialize(json, IrisAPIBookingDetailJson.class);
	}*/
}

/*	static testMethod void testParse() {
		String json=		'{'+
		'	"booking_detail":'+
		'	{'+
		'		"reference_id": "6",'+
		'		"project_unit_id": "5fbceb1062d4a769f80d9821",'+
		'		"lead_id": "RW-000023",'+
		'		"receipts_attributes":'+
		'		['+
		'			{'+
		'				"reference_id": "1114",'+
		'				"receipt_id": "11123",'+
		'				"order_id": "asdf",'+
		'				"payment_mode": "online",'+
		'				"issued_date": "11/11/2020",'+
		'				"issuing_bank": "ABC",'+
		'				"issuing_bank_branch": "Branch",'+
		'				"payment_identifier": "ABC",'+
		'				"tracking_id": "ABC",'+
		'				"total_amount": 30000,'+
		'				"status": "success",'+
		'				"payment_gateway": "Razorpay",'+
		'				"processed_on": "11/11/2020",'+
		'				"comments": "ABC",'+
		'				"payment_type": "token"'+
		'			},'+
		'			{'+
		'				"reference_id": "117",'+
		'				"receipt_id": "11127",'+
		'				"order_id": "asdf",'+
		'				"payment_mode": "online",'+
		'				"issued_date": "11/11/2020",'+
		'				"issuing_bank": "ABC",'+
		'				"issuing_bank_branch": "Branch",'+
		'				"payment_identifier": "ABC",'+
		'				"tracking_id": "ABC",'+
		'				"total_amount": 2333332,'+
		'				"status": "success",'+
		'				"payment_gateway": "Razorpay",'+
		'				"processed_on": "11/11/2020",'+
		'				"comments": "ABC",'+
		'				"payment_type": "ba_1"'+
		'			}'+
		'		],'+
		'		"primary_user_kyc_attributes":'+
		'		{'+
		'			"reference_id": "14",'+
		'			"salutation": "Ms.",'+
		'			"first_name": "Aakruti",'+
		'			"last_name": "Shitut",'+
		'			"email": "asdfgg@gmail.com",'+
		'			"phone": "+919213232343",'+
		'			"pan_number": "DMABD9961V",'+
		'			"aadhaar": "123412271134",'+
		'			"dob": "12/08/1980",'+
		'			"configurations": ["1", "1.5"],'+
		'			"preferred_floors": ["1"],'+
		'			"budget": 123456,'+
		'			"anniversary": "11/11/1995",'+
		'			"education_qualification": "ABC",'+
		'			"designation": "ABC",'+
		'			"customer_company_name": "ABC",'+
		'			"number_of_units": 1,'+
		'			"comments": "ABC",'+
		'			"lead_id": "RW-L0001",'+
		'			"nri": true,'+
		'			"oci": "ABC",'+
		'			"poa": true,'+
		'			"poa_details": "ABC",'+
		'			"poa_details_phone_no": "ABC",'+
		'			"is_company": true,'+
		'			"gstn": "ABC",'+
		'			"company_name": "ABC",'+
		'			"existing_customer": true,'+
		'			"existing_customer_name": "ABC",'+
		'			"existing_customer_project": "ABC"'+
		'		}'+
		'	}'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/