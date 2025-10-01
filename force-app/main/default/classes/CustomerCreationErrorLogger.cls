public class CustomerCreationErrorLogger {
    public  CustomerCreation.ZsdSfdcCustomerHd customerHeader;
    public              CustomerCreation.TableOfZsdSfdcCustomerTax customerTaxList;
    public           CustomerCreation.TableOfZsdSfdcCustomerAddress customerAddressList;
    public   CustomerCreation.TableOfZsdsBpContact  coAppList ;
    public               CustomerCreation.TableOfZsdSfdcCustomerComm  commList;
    
    public   CustomerCreationErrorLogger(){
        customerHeader = new CustomerCreation.ZsdSfdcCustomerHd();
        customerTaxList  = new CustomerCreation.TableOfZsdSfdcCustomerTax();
        customerAddressList  = new CustomerCreation.TableOfZsdSfdcCustomerAddress();
        coAppList  = new CustomerCreation.TableOfZsdsBpContact();
        commList = new CustomerCreation.TableOfZsdSfdcCustomerComm();
    }
}