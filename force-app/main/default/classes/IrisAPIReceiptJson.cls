//http://runwal.iris1.selldoapp.com/api/v1/receipts

public class IrisAPIReceiptJson{
	public cls_receipt receipt;
	public class cls_receipt {
		public String reference_id;	//98
		public String receipt_id;	//11521
		public String order_id;	//asdf
		public String payment_mode;	//online
		public String issued_date;	//11/11/2020
		public String issuing_bank;	//ABC
		public String issuing_bank_branch;	//Branch
		public String payment_identifier;	//ABC
		public String tracking_id;	//ABC
		public decimal total_amount;	//30000
		public String status;	//success
		public String payment_gateway;	//Razorpay
		public String processed_on;	//11/11/2020
		public String comments;	//ABC
		public String payment_type;	//token
		public String lead_id;	//RW-000023
	}
    
    public class cls_user_kyc_attributes {
		public String reference_id;	//678
		public String salutation;	//Ms.
		public String first_name;	//Saumeel
		public String last_name;	//Shukla
		public String email;	//somla@gmail.com
		public String phone;	//+919131111465
		public String pan_number;	//AMALL9961B
		public String aadhaar;	//123992101211
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
    
   public class cls_configurations {
		public String config;	//1
	}
	public class cls_preferred_floors {
		public String prefloors;	//1
	}
	public static IrisAPIReceiptJson parse(String json){
		return (IrisAPIReceiptJson) System.JSON.deserialize(json, IrisAPIReceiptJson.class);
	}
}
/*	static testMethod void testParse() {
		String json=		'{'+
		'	"receipt":'+
		'	{'+
		'		"reference_id": "98",'+
		'		"receipt_id": "11521",'+
		'		"order_id": "asdf",'+
		'		"payment_mode": "online",'+
		'		"issued_date": "11/11/2020",'+
		'		"issuing_bank": "ABC",'+
		'		"issuing_bank_branch": "Branch",'+
		'		"payment_identifier": "ABC",'+
		'		"tracking_id": "ABC",'+
		'		"total_amount": 30000,'+
		'		"status": "success",'+
		'		"payment_gateway": "Razorpay",'+
		'		"processed_on": "11/11/2020",'+
		'		"comments": "ABC",'+
		'		"payment_type": "token",'+
		'		"lead_id": "RW-000023"'+
		'	}'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}
}*/