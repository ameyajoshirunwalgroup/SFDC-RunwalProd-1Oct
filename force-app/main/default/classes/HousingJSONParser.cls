public class HousingJSONParser {

    public class HousingJSONWrapper {
        public Long lead_date;
        public String lead_name;
        public String lead_email;
        public String lead_phone;
        public Integer project_id;
        public String project_name;
    }

    
    public static List<HousingJSONWrapper> parse(String json) {
        return (List<HousingJSONWrapper>) System.JSON.deserialize(json, List<HousingJSONWrapper>.class);
    }
}