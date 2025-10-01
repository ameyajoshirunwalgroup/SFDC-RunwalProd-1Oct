public class WrapperInterestWaiverRequest {
    
    //public class WaiverRecord {
        public String bukrs;      // Company Code
        public String werks;      // Plant
        public String kunnr;      // Customer Code
        public String name;       // Customer Name
        public String vbeln;      // Sales Document
        public String floor;
        public String unit_no;
        public String mlbez;      // Milestone Code
        public String mstxt;      // Milestone Text
        public String belnr;      // Accounting Document No.
        public String blart;      // Document Type
        public String bldat;      // Document Date
        public String due_dt;     // Due Date
        public String intr_fr;    // Interest From Date
        public String intr_to;    // Interest To Date
        public Decimal intr_rate; // Interest Rate
        public Decimal base_amt;  // Base Amount
        public Integer nt_due_day;// Net Due Days
        public Decimal intr_amt;  // Interest Amount
        public Decimal wave_amt;  // Waiver Amount
        public Decimal recv_amt;  // Received Amount
        public String remark;     // Remark
   // }

   // public List<WaiverRecord> records;

    // Optional: method to deserialize JSON into wrapper
   /* public static List<WaiverRecord> parse(String jsonString) {
        return (List<WaiverRecord>) JSON.deserialize(jsonString, List<WaiverRecord>.class);
    }*/

}