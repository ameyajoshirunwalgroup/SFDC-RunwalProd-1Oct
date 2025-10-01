public class JuvlonJson  {

    public String apiKey;
    public String listName;
    public String isUnique;
    public List<Subscribers> subscribers;
   
    public class Subscribers {
       // public String prefix;
        //public String firstName;
        //public String middleName;
        //public String lastName;
        public String email;
      //  public String transactionalOnly;
        public String mobile;
        //public String phone;
      //  public String address;
      //  public String city;
      //  public String state;
       // public String pinCode;
       // public String country;
      //  public String residencePhone;
      //  public String designation;
       // public String company;
      //  public String companyAddress;
      //  public String companyCity;
      //  public String companyState;
     //   public String companyCountry;
     //   public String companyPin;
     //   public String companyPhone;
     //   public String companyFax;
      //  public String birthday;
      //  public String anniversary;
      //  public String referenceNo;
     //   public String extra1;
      //  public String extra2;
      //  public String extra3;
       // public String extra4;
     //   public String extra5;
      //  public String extra6;
       // public String source;
//        public String customField;
        
    }

    
    public static JuvlonJson parse(String json) {
        return (JuvlonJson) System.JSON.deserialize(json, JuvlonJson.class);
    }
}