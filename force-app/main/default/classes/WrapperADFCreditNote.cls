public class WrapperADFCreditNote {
    public List<ADF_CRN_Item> ADF_CRN { get; set; }
    
    public class ADF_CRN_Item {
        public String Customer { get; set; }
        public String Comp_Code { get; set; }
        public String Doc_Date { get; set; }
        public String Pstng_Date { get; set; }
        public String Fisc_Year { get; set; }
        public String Ref_Doc_No { get; set; }
        public String Header_Txt { get; set; }
        public String Item_Text { get; set; }
        public String sCurrency { get; set; }
        public String Amount { get; set; }
    }
}