public class WrapperIntWaiverAPI {
    public String batch_id {get; set;}
    public String balance {get; set;}
    public String has_more {get; set;}
    
    public List<items> items { get; set; }
    public class items {
        public String project { get; set; }
        public String kunnr { get; set; }
        public String belnr { get; set; }
        public String mlbez { get; set; }
        public String sgtxt { get; set; }
        public String name { get; set; }
        public String unit_no { get; set; }
        public String netdt { get; set; }
        public Decimal recv_dmbtr { get; set; }
        public Decimal recvd_dmbtr { get; set; }
        public Decimal balance { get; set; }
        public Integer int_days { get; set; }
        public Decimal int_amt { get; set; }
        public Decimal net_int_amt { get; set; }
        public Decimal waived_amt { get; set; }
        public String vbeln { get; set; }
        public String fkdat { get; set; }
    }
}