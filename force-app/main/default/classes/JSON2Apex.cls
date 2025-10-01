public class JSON2Apex {
    public String channel_name {get;set;} 
    public String country_code {get;set;} 
    //public Object email {get;set;}
    public String email {get;set;} 
    //public Object is_duplicate {get;set;} 
    public Integer lead_id {get;set;} 
    public String lead_status {get;set;} 
    public String name {get;set;} 
    public String phone {get;set;} 
    //public Object placement {get;set;} 
    public String project_name {get;set;} 
    public Cp_data cp_data {get;set;} 
    //public Object rating {get;set;} 
    //public Object min_budget {get;set;} 
    //public Object max_budget {get;set;}
    public String source {get;set;} 
    public String sub_source {get;set;} 
    //public Object lead_status_reasons {get;set;} 
    public Extra_details extra_details {get;set;} 
    public Booking_details booking_details {get;set;} 
    public List<Booking_docs> booking_docs {get;set;} 
    public Integer project_id {get;set;} 
    public Integer created_at {get;set;} 
    public Integer claimed_at {get;set;} 
    public String agent_email {get;set;} 
    public Latest_event_details latest_event_details {get;set;} 
    public List<Event_details> event_details {get;set;} 
    public List<Notes_Z> notes {get;set;} 
    public List<Calls> calls {get;set;} 
   

    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {         
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'channel_name') {
                        channel_name = parser.getText();
                    } else if (text == 'country_code') {
                        country_code = parser.getText();
                    } else if (text == 'email') {
                        //email = parser.readValueAs(Object.class);
                        email = parser.getText();
                    } else if (text == 'is_duplicate') {
                       // is_duplicate = parser.readValueAs(Object.class);
                    } else if (text == 'lead_id') {
                        lead_id = parser.getIntegerValue();
                    } else if (text == 'lead_status') {
                        lead_status = parser.getText();
                    } else if (text == 'name') {
                        name = parser.getText();
                    } else if (text == 'phone') {
                        phone = parser.getText();
                    } else if (text == 'placement') {
                       // placement = parser.readValueAs(Object.class);
                    } else if (text == 'project_name') {
                        project_name = parser.getText();
                    } else if (text == 'cp_data') {
                        cp_data = new Cp_data(parser);
                    } else if (text == 'rating') {
                      //  rating = parser.readValueAs(Object.class);
                    } else if (text == 'min_budget') {
                       // min_budget = parser.readValueAs(Object.class);
                    } else if (text == 'max_budget') {
                       // max_budget = parser.readValueAs(Object.class);
                    } else if (text == 'source') {
                        source = parser.getText();
                    } else if (text == 'sub_source') {
                        sub_source = parser.getText();
                    }else if (text == 'lead_status_reasons') {
                       // lead_status_reasons = parser.readValueAs(Object.class);
                    } else if (text == 'extra_details') {
                        extra_details = new Extra_details(parser);
                    } else if (text == 'booking_details') {
                        booking_details = new Booking_details(parser);
                    } else if (text == 'booking_docs') {
                        booking_docs = arrayOfBooking_docs(parser);
                    } else if (text == 'project_id') {
                        project_id = parser.getIntegerValue();
                    } else if (text == 'created_at') {
                        created_at = parser.getIntegerValue();
                    } else if (text == 'claimed_at') {
                        claimed_at = parser.getIntegerValue();
                    } else if (text == 'agent_email') {
                        agent_email = parser.getText();
                    } else if (text == 'latest_event_details') {
                        latest_event_details = new Latest_event_details(parser);
                    } else if (text == 'event_details') {
                        event_details = arrayOfEvent_details(parser);
                    } else if (text == 'notes') {
                        notes = arrayOfNotes_Z(parser);
                    } else if (text == 'calls') {
                        calls = arrayOfCalls(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    
    public class Booking_details {
        public String area {get;set;} 
        public String unit_no {get;set;} 
        public String base_price {get;set;} 
        public String floor_number {get;set;} 
        public String parking_price {get;set;} 
        public String apartment_type {get;set;} 
        public String floor_rise_price {get;set;} 
        public Integer apartment_type_id {get;set;} 

        public Booking_details(JSONParser parser) {
         
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'area') {
                            area = parser.getText();
                        } else if (text == 'unit_no') {
                            unit_no = parser.getText();
                        } else if (text == 'base_price') {
                            base_price = parser.getText();
                        } else if (text == 'floor_number') {
                            floor_number = parser.getText();
                        } else if (text == 'parking_price') {
                            parking_price = parser.getText();
                        } else if (text == 'apartment_type') {
                            apartment_type = parser.getText();
                        } else if (text == 'floor_rise_price') {
                            floor_rise_price = parser.getText();
                        } else if (text == 'apartment_type_id') {
                            apartment_type_id = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Booking_details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Latest_event_details {
        public Integer event_id {get;set;} 
        public Integer start_time {get;set;} 
        public Integer end_time {get;set;} 
        public String event_type {get;set;} 

        public Latest_event_details(JSONParser parser) {
         event_id =0;
         start_time =0;
         end_time =0;
         event_type ='';
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'event_id') {
                            event_id = parser.getIntegerValue();
                        } else if (text == 'start_time') {
                            start_time = parser.getIntegerValue();
                        } else if (text == 'end_time') {
                            end_time = parser.getIntegerValue();
                        } else if (text == 'event_type') {
                            event_type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Latest_event_details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Calls {
        public String action {get;set;} 
        public Agent_details agent_details {get;set;} 
        public String call_number {get;set;} 
        public Integer duration_in_sec {get;set;} 
        public Integer end_time {get;set;} 
        public String first_leg_status {get;set;} 
        public String from_Z {get;set;} 
        public Integer id {get;set;} 
        public Integer inserted_at {get;set;} 
        public string recording_url {get;set;} 
        public String second_leg_status {get;set;} 
        public Integer start_time {get;set;} 
        public String to {get;set;} 
        public Integer updated_at {get;set;} 

        public Calls(JSONParser parser) {
         action ='';
         call_number =''; 
         duration_in_sec =0; 
         end_time =0;
         first_leg_status =''; 
         from_Z ='';
         id =0;
         inserted_at =0;
         recording_url =''; 
         second_leg_status ='';
         start_time =0;
         to ='';
         updated_at=0;
          
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'action') {
                            action = parser.getText();
                        } else if (text == 'agent_details') {
                            agent_details = new Agent_details(parser);
                        } else if (text == 'call_number') {
                            call_number = parser.getText();
                        } else if (text == 'duration_in_sec') {
                            duration_in_sec = parser.getIntegerValue();
                        } else if (text == 'end_time') {
                            end_time = parser.getIntegerValue();
                        } else if (text == 'first_leg_status') {
                            first_leg_status = parser.getText();
                        } else if (text == 'from') {
                            from_Z = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'inserted_at') {
                            inserted_at = parser.getIntegerValue();
                        } else if (text == 'recording_url') {
                            recording_url = parser.getText();
                        } else if (text == 'second_leg_status') {
                            second_leg_status = parser.getText();
                        } else if (text == 'start_time') {
                            start_time = parser.getIntegerValue();
                        } else if (text == 'to') {
                            to = parser.getText();
                        } else if (text == 'updated_at') {
                            updated_at = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Calls consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Locality_hash {

        public Locality_hash(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        {
                            System.debug(LoggingLevel.WARN, 'Locality_hash consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Extra_details {
        public Integer duplicate_lead_id {get;set;} 
        public String gender {get;set;} 
        public Boolean is_nri {get;set;} 
        public String address {get;set;} 
        public Integer max_age {get;set;} 
        public Integer min_age {get;set;} 
        public String industry {get;set;} 
        public String ethnicity {get;set;} 
        public String occupation {get;set;} 
        public String designation {get;set;} 
        public String company_name {get;set;} 
        public List<Integer> possession_in {get;set;} 
        public Referral_data referral_data {get;set;} 
        public Integer office_city_id {get;set;} 
        public String mode_of_payment {get;set;} 
        public Integer annual_income_max {get;set;} 
        public Integer annual_income_min {get;set;} 
        public String purpose_of_purchase {get;set;} 
        public Integer current_apartment_type {get;set;} 
        public String current_residence_type {get;set;} 

        public Extra_details(JSONParser parser) {
         duplicate_lead_id = 0;
         gender ='';
         is_nri = false;
         address ='';
         max_age = 0; 
         min_age = 0;
         industry  = '';
         ethnicity ='';
         occupation  ='';
         designation ='';
         company_name ='';
         List <Integer> possession_in = new List <Integer> (); 
         office_city_id = 0;
         mode_of_payment ='';
         annual_income_max =0;
         annual_income_min  =0;
         purpose_of_purchase ='';
         current_apartment_type =0;
         current_residence_type ='';
         
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'duplicate_lead_id') {
                            duplicate_lead_id = parser.getIntegerValue();
                        } else if (text == 'gender') {
                            gender = parser.getText();
                        } else if (text == 'is_nri') {
                            is_nri = parser.getBooleanValue();
                        } else if (text == 'address') {
                            address = parser.getText();
                        } else if (text == 'max_age') {
                            max_age = parser.getIntegerValue();
                        } else if (text == 'min_age') {
                            min_age = parser.getIntegerValue();
                        } else if (text == 'industry') {
                            industry = parser.getText();
                        } else if (text == 'ethnicity') {
                            ethnicity = parser.getText();
                        } else if (text == 'occupation') {
                            occupation = parser.getText();
                        } else if (text == 'designation') {
                            designation = parser.getText();
                        } else if (text == 'company_name') {
                            company_name = parser.getText();
                        } else if (text == 'possession_in') {
                            possession_in = arrayOfInteger(parser);
                        } else if (text == 'referral_data') {
                            referral_data = new Referral_data(parser);
                        } else if (text == 'office_city_id') {
                            office_city_id = parser.getIntegerValue();
                        } else if (text == 'mode_of_payment') {
                            mode_of_payment = parser.getText();
                        } else if (text == 'annual_income_max') {
                            annual_income_max = parser.getIntegerValue();
                        } else if (text == 'annual_income_min') {
                            annual_income_min = parser.getIntegerValue();
                        } else if (text == 'purpose_of_purchase') {
                            purpose_of_purchase = parser.getText();
                        } else if (text == 'current_apartment_type') {
                            current_apartment_type = parser.getIntegerValue();
                        } else if (text == 'current_residence_type') {
                            current_residence_type = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Extra_details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Referral_data {
        public String name {get;set;} 
        public String phone {get;set;} 

        public Referral_data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Referral_data consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Cp_data {
        public Integer id {get;set;} 
        public String name {get;set;} 
        public string email {get;set;} 
        public String phone_with_country_code {get;set;} 
        public Integer phone_country_id {get;set;} 
        public String firm_name {get;set;} 
        public String rera_id {get;set;} 
        public Locality_hash locality_hash {get;set;} 
        public Locality_hash city_hash {get;set;} 
        public List<Locality_hash> location_info {get;set;} 
        public String phone {get;set;} 
        public Integer country_id {get;set;} 

        public Cp_data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'phone_with_country_code') {
                            phone_with_country_code = parser.getText();
                        } else if (text == 'phone_country_id') {
                            phone_country_id = parser.getIntegerValue();
                        } else if (text == 'firm_name') {
                            firm_name = parser.getText();
                        } else if (text == 'rera_id') {
                            rera_id = parser.getText();
                        } else if (text == 'locality_hash') {
                            locality_hash = new Locality_hash(parser);
                        } else if (text == 'city_hash') {
                            city_hash = new Locality_hash(parser);
                        } else if (text == 'location_info') {
                            location_info = arrayOfLocality_hash(parser);
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'country_id') {
                            country_id = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Cp_data consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Agent_details {
        public Integer id {get;set;} 
        public String name {get;set;} 
        public String phone {get;set;} 
        public Integer phone_country_id {get;set;} 

        public Agent_details(JSONParser parser) {
          id =0;
          name ='';
          phone ='';
          phone_country_id =0;
          
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'phone') {
                            phone = parser.getText();
                        } else if (text == 'phone_country_id') {
                            phone_country_id = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Agent_details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Event_details {
        public Integer event_id {get;set;} 
        public Integer start_time {get;set;} 
        public Integer end_time {get;set;} 
        public String event_type {get;set;} 
        public String event_status {get;set;} 
        public Integer event_created_at {get;set;} 
        public Integer event_updated_at {get;set;} 
        public List<Notes> notes {get;set;} 

        public Event_details(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'event_id') {
                            event_id = parser.getIntegerValue();
                        } else if (text == 'start_time') {
                            start_time = parser.getIntegerValue();
                        } else if (text == 'end_time') {
                            end_time = parser.getIntegerValue();
                        } else if (text == 'event_type') {
                            event_type = parser.getText();
                        } else if (text == 'event_status') {
                            event_status = parser.getText();
                        } else if (text == 'event_created_at') {
                            event_created_at = parser.getIntegerValue();
                        } else if (text == 'event_updated_at') {
                            event_updated_at = parser.getIntegerValue();
                        } else if (text == 'notes') {
                            notes = arrayOfNotes(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Event_details consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Notes {
        public Integer note_id {get;set;} 
        public String note_type {get;set;} 
        public String data {get;set;} 
        public Integer agent_id {get;set;} 
        public Integer created_at {get;set;} 
        public Integer updated_at {get;set;} 
        public Agent_details agent_details {get;set;} 

        public Notes(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'note_id') {
                            note_id = parser.getIntegerValue();
                        } else if (text == 'note_type') {
                            note_type = parser.getText();
                        } else if (text == 'data') {
                            data = parser.getText();
                        } else if (text == 'agent_id') {
                            agent_id = parser.getIntegerValue();
                        } else if (text == 'created_at') {
                            created_at = parser.getIntegerValue();
                        } else if (text == 'updated_at') {
                            updated_at = parser.getIntegerValue();
                        } else if (text == 'agent_details') {
                            agent_details = new Agent_details(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Notes consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Notes_Z {
        public String note_type {get;set;} 
        public String data {get;set;} 
        public Double created_at {get;set;} 
        public Double updated_at {get;set;} 
        public Integer agent_id {get;set;} 
        public Integer note_id {get;set;} 
        public Agent_details agent_details {get;set;} 

        public Notes_Z(JSONParser parser) {
         note_type='';
         data ='';
         created_at=0.0; 
         updated_at =0.0;
         agent_id =0;
         note_id=0;
        
         
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'note_type') {
                            note_type = parser.getText();
                        } else if (text == 'data') {
                            data = parser.getText();
                        } else if (text == 'created_at') {
                            created_at = parser.getDoubleValue();
                        } else if (text == 'updated_at') {
                            updated_at = parser.getDoubleValue();
                        } else if (text == 'agent_id') {
                            agent_id = parser.getIntegerValue();
                        } else if (text == 'note_id') {
                            note_id = parser.getIntegerValue();
                        } else if (text == 'agent_details') {
                            agent_details = new Agent_details(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Notes_Z consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Booking_docs {
        public Integer id {get;set;} 
        public Integer lead_id {get;set;} 
        public String booking_doc_type {get;set;} 
        public String data {get;set;} 
        public String tag {get;set;} 
        public Integer status_id {get;set;} 
        public String created_at {get;set;} 
        public String updated_at {get;set;} 

        public Booking_docs(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getIntegerValue();
                        } else if (text == 'lead_id') {
                            lead_id = parser.getIntegerValue();
                        } else if (text == 'booking_doc_type') {
                            booking_doc_type = parser.getText();
                        } else if (text == 'data') {
                            data = parser.getText();
                        } else if (text == 'tag') {
                            tag = parser.getText();
                        } else if (text == 'status_id') {
                            status_id = parser.getIntegerValue();
                        } else if (text == 'created_at') {
                            created_at = parser.getText();
                        } else if (text == 'updated_at') {
                            updated_at = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Booking_docs consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    public static JSON2Apex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new JSON2Apex(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    

    private static List<Notes> arrayOfNotes(System.JSONParser p) {
        List<Notes> res = new List<Notes>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Notes(p));
        }
        return res;
    }



    private static List<Calls> arrayOfCalls(System.JSONParser p) {
        List<Calls> res = new List<Calls>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Calls(p));
        }
        return res;
    }



    private static List<Integer> arrayOfInteger(System.JSONParser p) {
        List<Integer> res = new List<Integer>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getIntegerValue());
        }
        return res;
    }








    private static List<Notes_Z> arrayOfNotes_Z(System.JSONParser p) {
        List<Notes_Z> res = new List<Notes_Z>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Notes_Z(p));
        }
        return res;
    }



    private static List<Event_details> arrayOfEvent_details(System.JSONParser p) {
        List<Event_details> res = new List<Event_details>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Event_details(p));
        }
        return res;
    }









    private static List<Booking_docs> arrayOfBooking_docs(System.JSONParser p) {
        List<Booking_docs> res = new List<Booking_docs>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Booking_docs(p));
        }
        return res;
    }


    private static List<Locality_hash> arrayOfLocality_hash(System.JSONParser p) {
        List<Locality_hash> res = new List<Locality_hash>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Locality_hash(p));
        }
        return res;
    }




}