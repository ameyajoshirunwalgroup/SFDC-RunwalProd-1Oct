public class ADFResponseWrapper {
    // wrapper created to store the response
    public String BUSINESSARE;
    public String STATUS;
    public List<FRECORD> FRECORD;
    
    public class FRECORD {
        public String PROJ_CODE;
        public String SALE_ORD;
        public String CUST_CODE;
        public Decimal PROJ_VAL;
        public Decimal TOT_ADV_REC;
        public Decimal TOT_INV_CON;
        public Decimal INT_UTIL;
        public Decimal BAL_ADV;
        public Decimal ELIG_INT;
        public String TIMESTAMP;
    }
}