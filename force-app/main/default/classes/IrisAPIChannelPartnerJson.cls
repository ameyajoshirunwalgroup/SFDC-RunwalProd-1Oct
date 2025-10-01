public class IrisAPIChannelPartnerJson {

  public Channel_partner channel_partner;

    public class Channel_partner {
       // public String first_name;
       // public String last_name;
       // public String email;
      //  public String phone;
      //  public String reference_id;
      //  public String rera_id;
     //   public String pan_number;
     //   public Integer team_size;
        public String cp_code;
     //   public String company_name;
    }

  public static JSON2Apex parse(String json) {
        return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
}