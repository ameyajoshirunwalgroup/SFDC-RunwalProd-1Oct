global class LockatedApp_PostSalesWrapper {

    public customer customer;
	public List<String> case_status;
	//public PicklistWrapper customer_lifecycle_touchpoint;
    //public PicklistWrapper complaint_type;
	public class customer {
		public String country_code;
		public String mobile_number;
		public String email;
		public String lastname;
		public String firstname;
		public String sap_cust_no;
		public String Customer_Sf_Id;
		public String birth_date;
		public String gender;
        public String pan_card;
		public String aadhar;
		public String gst_number;
		public String company_name;
		public String occupation;
		public String permanent_address;
        public String correspondence_address;
		public List<booking_details> booking_details;
        
	}

	public class booking_details {
        public String bookingId;
		public String is_primary;
		public String registration_date;
		public String booking_date;
		public String handover_date;
		//public String garden_facing;
		public Integer no_of_parkings;
        public String type_of_parking;
		//public List<String> type_of_parking;
		public String configuration_type;
		public Decimal carpet_area;
		public Decimal utility_area;
		public Decimal balcony_area;
        public Decimal rera_carpet_area;
		public String project_name;
		public String rera_project_name;
		public String rera_id;
		public String project_logo;
        public String company_code;
		public String unit;
        public String unit_type;
		public String floor;
		public String tower;
		public Decimal agreement_value;
		public Decimal total_demanded;
		public Decimal total_received;
		public String amount_due;
		public String registration_status;
		public String registration_amount;
		public String stamp_duty_status;
		public String stamp_duty_amount_received;
		public Decimal stamp_duty_amount;
		public String rm_email;
		public String rm_mobile;
		public String rm_name;
        public String ivr_number;
		public String sales_manager_name;
		public String ownership;
		public String status;
        public String booking_amount_paid;
        public String booking_amount_paid_date;
        public String payment_plan_type;
        public String payment_due_on_before;
        public String total_outstanding_a;
        public String total_outstanding_b;
        public String ncf_url;
        public String stamp_duty_paid_by;
		public Decimal grand_total;
		public String booking_number;
        public String homeLoanRmName;
        public String homeLoanRmContact;
        public String homeloan_brochure;
		public List<other_applicants> other_applicants;
		public stages stages;
		public List<payment_receipt> payment_receipt;
        public List<credit_note> credit_note;
		public List<other_charges> other_charges;
		public List<milestones> milestones;
        public List<paymentsDue> paymentsDue;
        public Bank_Details bank_details;
	}

    public class Bank_Details{
        public string principle_acc_number;
        public string principle_acc_name;
        public string principle_ifsc;
        public string principle_bank_name;
        public string principle_branch;
        public string principle_address;
        public string gst_acc_number;
        public string gst_acc_name;
        public string interest_payable_fav;
        public string interest_bank_acc_number;
        public string interest_bank_address;
    }    

	public class other_applicants {
		public String date_of_birth;
		public String address;
		public String aadhar;
		public String pan;
		public String gender;
		public String mobile;
		public String email;
		public String applicant_type;
		public String lastname;
		public String firstname;
        public String gst_number;
		public String company_name;
		public String occupation;
		public String permanent_address;
		public String correspondence_address;
	}

	public class stages {
		public String booking_details_status;
		public String ncf_status;
		public String registration_status;
		public String franking_status;
		public String sales_deed_status;
		public String stamp_duty_status;
		public String oc_status;
		public String possession_status;
        public String payment_9_9_status;
		public String sanction_status;
	}

	public class payment_receipt {
		public String fiscal_year;
		public String sap_document_number;
		public String company_code;
		public String sap_payment_advice_no;
		public Decimal pr_amount;
		public String pr_date;
		public String pr_no;
        public String milestone_name;
        public String bank_name;
        public String payment_date;
	}
    
    public class credit_note {
		public String fiscal_year;
		public String sap_document_number;
		public String company_code;
		public String sap_payment_advice_no;
		public Decimal pr_amount;
		public String pr_date;
		public String pr_no;
        public String milestone_name;
        public String bank_name;
        public String payment_date;
	}

	public class other_charges {
		//public String sap_demand_no;
		public Decimal total_amount;
		//public Integer taxable_amount;
		//public Integer base_amount;
		//public String status;
		//public String triggered_date;
		//public String expected_date;
		public String name;
	}


	public class milestones {
		public String sap_demand_no;
		public Decimal total_amount;
		public Decimal received_amount;
		public Decimal outstanding_amount;
		public Decimal taxable_amount;
		public Decimal base_amount;
		public String status;
		public String triggered_date;
		public String expected_date;
		public String name;
	}
    
    public class paymentsDue {
		public String milestone;
		public String milestone_date;
		public String base_amount;
		public String billed_tds;
		public String tds_received;
		public String payment_received;
		public String total_amount_billed;
		public String total_amount_received;
		public String total_amount_due;
		public String status;
        public String tax_amount;
	}
    
    public List<Category> case_category;

    public class Category{
        public String caseType;
        public String categoryType;
        public String categoryName;
        public List<String> subCategories;
    }
    
    public class PicklistWrapper{
        public Map<String, List<String>> pickListMap;
        public String parentFieldLabel;
        public String childFieldLabel;      
    }	


}